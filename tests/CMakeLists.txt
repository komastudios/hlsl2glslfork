if(BUILD_TESTING)
    if (CMAKE_C_COMPILER_ID STREQUAL "GNU" OR CMAKE_C_COMPILER_ID MATCHES "Clang")
        add_compile_options(-Wall -Wextra -Wshadow -Wpedantic
                -Wconversion -Wno-gcc-compat
                -Wno-sign-conversion
                -Wno-unused-parameter
                -Wno-unused-function
                -Wuninitialized -Wmissing-field-initializers
                -Wno-gnu-zero-variadic-macro-arguments
                -Wno-overlength-strings)
        add_compile_options(-Werror)
    endif()

    add_executable(hlsl2glsl_unit_tests
            unit_tests.cpp
            unit_tests_async.cpp)
    set_property(TARGET hlsl2glsl_unit_tests PROPERTY CXX_STANDARD 17)
    set_property(TARGET hlsl2glsl_unit_tests PROPERTY CXX_STANDARD_REQUIRED ON)
    target_link_libraries(hlsl2glsl_unit_tests hlsl2glsl gtest gmock gtest_main)

    add_test(NAME Hlsl2GlslUnitTests
            COMMAND hlsl2glsl_unit_tests
            WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}")
endif()
