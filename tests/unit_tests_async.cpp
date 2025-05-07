#include "unit_tests_common.h"

#include <thread>
#include <future>

using namespace ::testing;

namespace {

constexpr const char* kVertexShaderSrc = R"""(
float4x4 matrix_mvp;
float4x4 matrix_normal;

void main (float4 vertex : POSITION, out float4 overtex : POSITION, float3 normal : NORMAL, out float3 onormal : TEXCOORD0)
{
    overtex = mul (matrix_mvp, vertex);
    onormal = mul ((float3x3)matrix_normal, normal);
}
)""";

constexpr const char* kFragmentShaderSrc = R"""(
sampler2DShadow shadowmap;

fixed4 main (float4 uv : TEXCOORD0) : COLOR0
{
	float s1 = shadow2D (shadowmap, uv.xyz);
	float s2 = shadow2Dproj (shadowmap, uv);

	s1 = tex2D (shadowmap, uv.xyz);
	s2 = tex2Dproj (shadowmap, uv);

	return s1 + s2;
}
)""";

using CompilerResult = std::pair<bool, std::string>;

CompilerResult CompileShader(EShLanguage type, ETargetVersion targetVersion, const std::string& shaderSrc)
{
    unsigned options = 0;

    ShUserPrefixTable prefixTable {};
    prefixTable.prefix = "";

    static EAttribSemantic userAttribSemantics[] = {
        EAttrSemPosition,
        EAttrSemNormal,
    };
    static const char* userAttribNames[] = {
        "a_position",
        "a_normal",
    };

    std::unique_ptr<hlsl2glsl::HlslCrossCompiler, decltype(&Hlsl2Glsl_DestructCompiler)> parser(
        Hlsl2Glsl_ConstructCompilerUserPrefix(type, &prefixTable), &Hlsl2Glsl_DestructCompiler);
    Hlsl2Glsl_SetUserAttributeNames(parser.get(),
        userAttribSemantics, userAttribNames, std::size(userAttribSemantics));
    int parseOk = Hlsl2Glsl_Parse (parser.get(), shaderSrc.c_str(),
        targetVersion, nullptr, options);
    std::string infoLog = Hlsl2Glsl_GetInfoLog(parser.get());
    if (parseOk) {
        int translateOk = Hlsl2Glsl_Translate (parser.get(), "main", targetVersion, options);
        infoLog = Hlsl2Glsl_GetInfoLog(parser.get());
        if (translateOk) {
            std::string text = GetCompiledShaderText(parser.get());
            return std::make_pair(true, text);
        }
    }
    return std::make_pair(false, infoLog);
}

class Hlsl2GlslAsyncTest : public TestWithParam<std::tuple<size_t, bool>>
{
public:
    ETargetVersion targetVersion { ETargetGLSL_ES_100 };

    void SetUp() override;
    void TearDown() override;

    [[nodiscard]] std::pair<bool, std::string> compileShader(EShLanguage type, const std::string& shaderSrc) const;
};

void Hlsl2GlslAsyncTest::SetUp()
{
    int success = Hlsl2Glsl_Initialize();
    if (!success)
    {
        throw std::runtime_error { "failed to initialize HLSL2GLSL" };
    }
}

void Hlsl2GlslAsyncTest::TearDown()
{
    Hlsl2Glsl_Shutdown();
}

std::pair<bool, std::string> Hlsl2GlslAsyncTest::compileShader(EShLanguage type, const std::string& shaderSrc) const
{
    ETargetVersion version = targetVersion;

    size_t asyncTasks = std::get<0>(GetParam());
    bool synchronized = std::get<1>(GetParam());
    if (asyncTasks == 0) {
        return CompileShader(type, version, shaderSrc);
    }

    struct Thread
    {
        std::thread thread;
        std::mutex mutex;
        std::string src;
        CompilerResult result;
        std::exception_ptr error;
    };

    std::vector<std::unique_ptr<Thread>> threads;
    threads.resize(asyncTasks);

    static std::mutex gMutex;
    for (auto& t : threads) {
        t = std::make_unique<Thread>();
        t->src = shaderSrc;
        t->thread = std::thread([pThread=t.get(), type, version, synchronized]
        {
            std::unique_lock lk(synchronized ? gMutex : pThread->mutex);
            try {
                pThread->result = CompileShader(type, version, pThread->src);
            }
            catch (...) {
                pThread->error = std::current_exception();
            }
        });
    }

    std::optional<CompilerResult> result;
    std::vector<std::exception_ptr> errors;
    for (auto& t : threads) {
        try
        {
            t->thread.join();
            if (t->error) {
                errors.push_back(t->error);
            }
            if (!result.has_value()) {
                result = std::make_optional(t->result);
            }
            else {
                if (result->first != t->result.first || result->second != t->result.second) {
                    throw std::runtime_error { "async error: inconsistent results" };
                }
            }
        }
        catch (...)
        {
            errors.push_back(std::current_exception());
        }
    }

    return result.has_value() ? *result : std::make_pair(false, "async error: no valid result");
}

// NOLINTNEXTLINE
TEST_P(Hlsl2GlslAsyncTest, VertexShaderES2)
{
    targetVersion = ETargetGLSL_ES_100;
    TEST_COMPILE_SHADER(VERTEX_SHADER, kVertexShaderSrc,
R"""(
mat3 l_constructMat3_mf4x4( mat4 m) {
  return mat3( vec3( m[0]), vec3( m[1]), vec3( m[2]));
}
uniform highp mat4 matrix_mvp;
#line 3
uniform highp mat4 matrix_normal;
#line 5
void at_main( in highp vec4 vertex, out highp vec4 overtex, in highp vec3 normal, out highp vec3 onormal ) {
    #line 7
    overtex = (matrix_mvp * vertex);
    onormal = (l_constructMat3_mf4x4( matrix_normal) * normal);
}
attribute highp vec4 a_position;
attribute highp vec3 a_normal;
varying highp vec3 v_TEXCOORD0;
void main() {
    highp vec4 t_overtex;
    highp vec3 t_onormal;
    at_main( vec4(a_position), t_overtex, vec3(a_normal), t_onormal);
    gl_Position = vec4(t_overtex);
    v_TEXCOORD0 = vec3(t_onormal);
}

// uniforms:
// matrix_mvp:<none> type 21 arrsize 0
// matrix_normal:<none> type 21 arrsize 0
)""");
}

// NOLINTNEXTLINE
TEST_P(Hlsl2GlslAsyncTest, VertexShaderES3)
{
    targetVersion = ETargetGLSL_ES_300;
    TEST_COMPILE_SHADER(VERTEX_SHADER, kVertexShaderSrc,
R"""(
uniform highp mat4 matrix_mvp;
#line 3
uniform highp mat4 matrix_normal;
#line 5
void at_main( in highp vec4 vertex, out highp vec4 overtex, in highp vec3 normal, out highp vec3 onormal ) {
    #line 7
    overtex = (matrix_mvp * vertex);
    onormal = (mat3( matrix_normal) * normal);
}
in highp vec4 a_position;
in highp vec3 a_normal;
out highp vec3 v_TEXCOORD0;
void main() {
    highp vec4 t_overtex;
    highp vec3 t_onormal;
    at_main( vec4(a_position), t_overtex, vec3(a_normal), t_onormal);
    gl_Position = vec4(t_overtex);
    v_TEXCOORD0 = vec3(t_onormal);
}

// uniforms:
// matrix_mvp:<none> type 21 arrsize 0
// matrix_normal:<none> type 21 arrsize 0
)""");
}

// NOLINTNEXTLINE
TEST_P(Hlsl2GlslAsyncTest, FragmentShaderES2)
{
    targetVersion = ETargetGLSL_ES_100;
    TEST_COMPILE_SHADER(FRAGMENT_SHADER, kFragmentShaderSrc,
R"""(
#extension GL_EXT_shadow_samplers : require
float l_shadow2D(sampler2DShadow s, vec3 coord) { return shadow2DEXT (s, coord); }
float l_shadow2Dproj(sampler2DShadow s, vec4 coord) { return shadow2DProjEXT (s, coord); }
uniform lowp sampler2DShadow shadowmap;
#line 4
#line 4
lowp vec4 at_main( in highp vec4 uv ) {
    highp float s1 = l_shadow2D( shadowmap, uv.xyz);
    highp float s2 = l_shadow2Dproj( shadowmap, uv);
    #line 9
    s1 = float( shadow2D( shadowmap, uv.xyz));
    s2 = float( shadow2DProj( shadowmap, uv));
    return vec4( (s1 + s2));
}
varying highp vec4 v_TEXCOORD0;
void main() {
    lowp vec4 _retval;
    _retval = at_main( vec4(v_TEXCOORD0));
    gl_FragData[0] = vec4(_retval);
}

// uniforms:
// shadowmap:<none> type 26 arrsize 0
)""");
}

// NOLINTNEXTLINE
TEST_P(Hlsl2GlslAsyncTest, FragmentShaderES3)
{
    targetVersion = ETargetGLSL_ES_300;
    TEST_COMPILE_SHADER(FRAGMENT_SHADER, kFragmentShaderSrc,
R"""(
float l_shadow2D(mediump sampler2DShadow s, vec3 coord) { return texture (s, coord); }
float l_shadow2Dproj(mediump sampler2DShadow s, vec4 coord) { return textureProj (s, coord); }
uniform lowp sampler2DShadow shadowmap;
#line 4
#line 4
lowp vec4 at_main( in highp vec4 uv ) {
    highp float s1 = l_shadow2D( shadowmap, uv.xyz);
    highp float s2 = l_shadow2Dproj( shadowmap, uv);
    #line 9
    s1 = float( texture( shadowmap, uv.xyz));
    s2 = float( textureProj( shadowmap, uv));
    return vec4( (s1 + s2));
}
in highp vec4 v_TEXCOORD0;
void main() {
    lowp vec4 _retval;
    _retval = at_main( vec4(v_TEXCOORD0));
    gl_FragData[0] = vec4(_retval);
}

// uniforms:
// shadowmap:<none> type 26 arrsize 0
)""");
}

// NOLINTNEXTLINE
TEST_P(Hlsl2GlslAsyncTest, SyntaxError)
{
    const char* kInvalidShaderSrc = R"""(
#line 1 "undefined-type-in.txt"
#line 1 "undefined-type-in.hlsl"
void main(out float4 overtex : POSITION)
    {
        bloat4 b(1.f, 1.f, 1.f, 1.f);
        overtex = float4(b.x,b.y,b,z,b.w);
    }
)""";

    TEST_COMPILE_SHADER_ERROR(VERTEX_SHADER, kInvalidShaderSrc,
        "undefined-type-in.hlsl(3): ERROR: 'bloat4' : undeclared identifier \n"
        "undefined-type-in.hlsl(3): ERROR: 'b' : syntax error syntax error \n"
    );
}

// NOLINTNEXTLINE
TEST_P(Hlsl2GlslAsyncTest, ReservedWord)
{
    const char* kInvalidShaderSrc = R"""(
#line 1 "undefined-type-in.txt"
#line 1 "undefined-type-in.hlsl"
void main(out float4 asm : POSITION)
    {
        float4 b(1.f, 1.f, 1.f, 1.f);
        asm = float4(b.x,b.y,b,z,b.w);
    }
)""";

    TEST_COMPILE_SHADER_ERROR(VERTEX_SHADER, kInvalidShaderSrc,
        "undefined-type-in.hlsl(1): ERROR: 'asm' : Reserved word. \n"
        "undefined-type-in.hlsl(1): ERROR: 'asm' : syntax error syntax error \n"
    );
}

// NOLINTNEXTLINE
INSTANTIATE_TEST_SUITE_P(AsyncJobsSynchronized,
                         Hlsl2GlslAsyncTest,
                         testing::Combine(
                             testing::Values(1, 2, 4),
                             testing::Values(true)
                         ));

// NOLINTNEXTLINE
INSTANTIATE_TEST_SUITE_P(AsyncJobs,
                         Hlsl2GlslAsyncTest,
                         testing::Combine(
                             testing::Values(0, 1, 4, 8, 16, 32, 64, 256),
                             testing::Values(false)
                         ));

} // namespace
