#pragma once

#include "hlsl2glsl.h"

#include "gtest/gtest.h"
#include "gmock/gmock.h"

#include <string_view>
#include <iostream>
#include <utility>
#include <stdexcept>
#include <optional>
#include <array>

#define VERTEX_SHADER EShLangVertex
#define FRAGMENT_SHADER EShLangFragment

#define TEST_COMPILE_SHADER(type, src, expected) \
    auto [success, output] = compileShader(type, src); \
    EXPECT_TRUE(success) << "failed to compile shader: " << output; \
    EXPECT_EQ(TrimStr(expected), TrimStr(output)) << \
    "//------------------------------------------------------------\n" << \
    output << \
    "//------------------------------------------------------------\n";
#define TEST_COMPILE_SHADER_ERROR(type, src, expected) \
    auto [success, output] = compileShader(type, src); \
    EXPECT_FALSE(success) << "expected error"; \
    EXPECT_EQ(TrimStr(expected), TrimStr(output)) << \
    "//------------------------------------------------------------\n" << \
    output << \
    "//------------------------------------------------------------\n";

constexpr std::string_view kWhitespaceCharacters { " \n\r\t" };

constexpr std::string_view TrimLeft(std::string_view source)
{
    const auto idx = source.find_first_not_of(kWhitespaceCharacters);
    return idx != std::string_view::npos ? source.substr(idx) : std::string_view{};
}

constexpr std::string_view TrimRight(std::string_view source)
{
    const auto idx = source.find_last_not_of(kWhitespaceCharacters);
    return idx != std::string_view::npos ? source.substr(0, idx+1) : std::string_view{};
}

constexpr std::string_view TrimStr(std::string_view source)
{
    return TrimRight(TrimLeft(source));
}

inline std::string GetCompiledShaderText(ShHandle parser)
{
    std::string txt = Hlsl2Glsl_GetShader (parser);

    int count = Hlsl2Glsl_GetUniformCount (parser);
    if (count > 0)
    {
        const ShUniformInfo* uni = Hlsl2Glsl_GetUniformInfo(parser);
        txt += "\n// uniforms:\n";
        for (int i = 0; i < count; ++i)
        {
            char buf[1000];
            snprintf(buf,1000,"// %s:%s type %d arrsize %d", uni[i].name, uni[i].semantic?uni[i].semantic:"<none>", uni[i].type, uni[i].arraySize);
            txt += buf;

            if (uni[i].registerSpec)
            {
                txt += " register ";
                txt += uni[i].registerSpec;
            }

            txt += "\n";
        }
    }

    return txt;
}
