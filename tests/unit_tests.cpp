#include "unit_tests_common.h"

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

class Hlsl2GlslTest : public ::testing::Test
{
public:
    ETargetVersion targetVersion { ETargetGLSL_ES_100 };
    std::array<ShHandle, EShLangCount> compilerHandles {};

    void SetUp() override;
    void TearDown() override;

    [[nodiscard]] std::pair<bool, std::string> compileShader(EShLanguage type, const std::string& shaderSrc) const;
};

void Hlsl2GlslTest::SetUp()
{
    int success = Hlsl2Glsl_Initialize();
    if (!success)
    {
        throw std::runtime_error { "failed to initialize HLSL2GLSL" };
    }

    for (size_t i=0;i<compilerHandles.size();++i) {
        compilerHandles[i] = Hlsl2Glsl_ConstructCompiler(static_cast<EShLanguage>(i));
    }
}

void Hlsl2GlslTest::TearDown()
{
    for (auto& hnd : compilerHandles) {
        Hlsl2Glsl_DestructCompiler(hnd);
        hnd = nullptr;
    }

    Hlsl2Glsl_Shutdown();
}

std::pair<bool, std::string> Hlsl2GlslTest::compileShader(EShLanguage type, const std::string& shaderSrc) const
{
    unsigned options = 0;
    int parseOk = Hlsl2Glsl_Parse (compilerHandles[type], shaderSrc.c_str(),
        targetVersion, nullptr, options);
    std::string infoLog = Hlsl2Glsl_GetInfoLog(compilerHandles[type]);
    if (parseOk) {
        int translateOk = Hlsl2Glsl_Translate (compilerHandles[type], "main", targetVersion, options);
        infoLog = Hlsl2Glsl_GetInfoLog(compilerHandles[type]);
        if (translateOk) {
            std::string text = GetCompiledShaderText(compilerHandles[type]);
            return std::make_pair(true, text);
        }
    }
    return std::make_pair(false, infoLog);
}

// NOLINTNEXTLINE
TEST_F(Hlsl2GlslTest, VertexShaderES2)
{
    targetVersion = ETargetGLSL_ES_100;
    TEST_COMPILE_SHADER(VERTEX_SHADER, kVertexShaderSrc,
R"""(
mat3 xll_constructMat3_mf4x4( mat4 m) {
  return mat3( vec3( m[0]), vec3( m[1]), vec3( m[2]));
}
uniform highp mat4 matrix_mvp;
#line 3
uniform highp mat4 matrix_normal;
#line 5
void xlat_main( in highp vec4 vertex, out highp vec4 overtex, in highp vec3 normal, out highp vec3 onormal ) {
    #line 7
    overtex = (matrix_mvp * vertex);
    onormal = (xll_constructMat3_mf4x4( matrix_normal) * normal);
}
attribute highp vec4 xlat_attrib_POSITION;
attribute highp vec3 xlat_attrib_NORMAL;
varying highp vec3 xlv_TEXCOORD0;
void main() {
    highp vec4 xlt_overtex;
    highp vec3 xlt_onormal;
    xlat_main( vec4(xlat_attrib_POSITION), xlt_overtex, vec3(xlat_attrib_NORMAL), xlt_onormal);
    gl_Position = vec4(xlt_overtex);
    xlv_TEXCOORD0 = vec3(xlt_onormal);
}

// uniforms:
// matrix_mvp:<none> type 21 arrsize 0
// matrix_normal:<none> type 21 arrsize 0
)""");
}

// NOLINTNEXTLINE
TEST_F(Hlsl2GlslTest, VertexShaderES3)
{
    targetVersion = ETargetGLSL_ES_300;
    TEST_COMPILE_SHADER(VERTEX_SHADER, kVertexShaderSrc,
R"""(
uniform highp mat4 matrix_mvp;
#line 3
uniform highp mat4 matrix_normal;
#line 5
void xlat_main( in highp vec4 vertex, out highp vec4 overtex, in highp vec3 normal, out highp vec3 onormal ) {
    #line 7
    overtex = (matrix_mvp * vertex);
    onormal = (mat3( matrix_normal) * normal);
}
in highp vec4 xlat_attrib_POSITION;
in highp vec3 xlat_attrib_NORMAL;
out highp vec3 xlv_TEXCOORD0;
void main() {
    highp vec4 xlt_overtex;
    highp vec3 xlt_onormal;
    xlat_main( vec4(xlat_attrib_POSITION), xlt_overtex, vec3(xlat_attrib_NORMAL), xlt_onormal);
    gl_Position = vec4(xlt_overtex);
    xlv_TEXCOORD0 = vec3(xlt_onormal);
}

// uniforms:
// matrix_mvp:<none> type 21 arrsize 0
// matrix_normal:<none> type 21 arrsize 0
)""");
}

// NOLINTNEXTLINE
TEST_F(Hlsl2GlslTest, FragmentShaderES2)
{
    targetVersion = ETargetGLSL_ES_100;
    TEST_COMPILE_SHADER(FRAGMENT_SHADER, kFragmentShaderSrc,
R"""(
#extension GL_EXT_shadow_samplers : require
float xll_shadow2D(sampler2DShadow s, vec3 coord) { return shadow2DEXT (s, coord); }
float xll_shadow2Dproj(sampler2DShadow s, vec4 coord) { return shadow2DProjEXT (s, coord); }
uniform lowp sampler2DShadow shadowmap;
#line 4
#line 4
lowp vec4 xlat_main( in highp vec4 uv ) {
    highp float s1 = xll_shadow2D( shadowmap, uv.xyz);
    highp float s2 = xll_shadow2Dproj( shadowmap, uv);
    #line 9
    s1 = float( shadow2D( shadowmap, uv.xyz));
    s2 = float( shadow2DProj( shadowmap, uv));
    return vec4( (s1 + s2));
}
varying highp vec4 xlv_TEXCOORD0;
void main() {
    lowp vec4 xl_retval;
    xl_retval = xlat_main( vec4(xlv_TEXCOORD0));
    gl_FragData[0] = vec4(xl_retval);
}

// uniforms:
// shadowmap:<none> type 26 arrsize 0
)""");
}

// NOLINTNEXTLINE
TEST_F(Hlsl2GlslTest, FragmentShaderES3)
{
    targetVersion = ETargetGLSL_ES_300;
    TEST_COMPILE_SHADER(FRAGMENT_SHADER, kFragmentShaderSrc,
R"""(
float xll_shadow2D(mediump sampler2DShadow s, vec3 coord) { return texture (s, coord); }
float xll_shadow2Dproj(mediump sampler2DShadow s, vec4 coord) { return textureProj (s, coord); }
uniform lowp sampler2DShadow shadowmap;
#line 4
#line 4
lowp vec4 xlat_main( in highp vec4 uv ) {
    highp float s1 = xll_shadow2D( shadowmap, uv.xyz);
    highp float s2 = xll_shadow2Dproj( shadowmap, uv);
    #line 9
    s1 = float( texture( shadowmap, uv.xyz));
    s2 = float( textureProj( shadowmap, uv));
    return vec4( (s1 + s2));
}
in highp vec4 xlv_TEXCOORD0;
void main() {
    lowp vec4 xl_retval;
    xl_retval = xlat_main( vec4(xlv_TEXCOORD0));
    gl_FragData[0] = vec4(xl_retval);
}

// uniforms:
// shadowmap:<none> type 26 arrsize 0
)""");
}

} // namespace