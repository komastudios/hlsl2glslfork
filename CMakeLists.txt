cmake_minimum_required(VERSION 3.24)

project(hlsl2glslfork C CXX)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake")

if(PROJECT_IS_TOP_LEVEL)
  include(ExtractSymbols)
  include(Sanitizers)
endif()

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_VISIBILITY_PRESET hidden)

option(CMAKE_POSITION_INDEPENDENT_CODE "Build position independent code" ON)
option(BUILD_SHARED_LIBS "Build shared libraries" OFF)
option(BUILD_HLSL2GLSLTEST "Build the test executable" ON)
option(BUILD_TESTING "Build unit tests" ON)

option(HLSL2GLSL_EXTRACT_SYMBOLS "Extract symbols from the library" OFF)

find_package(BISON 3.0 REQUIRED)
find_package(FLEX REQUIRED)

set(HLSLANG_SRC_DIR   ${CMAKE_CURRENT_SOURCE_DIR}/hlslang/MachineIndependent)
set(HLSLANG_BIN_DIR   ${CMAKE_CURRENT_BINARY_DIR})

file(MAKE_DIRECTORY ${HLSLANG_BIN_DIR})

bison_target(
  HlslangParser
  ${HLSLANG_SRC_DIR}/hlslang.y
  ${HLSLANG_BIN_DIR}/hlslang_tab.cpp
  DEFINES_FILE ${HLSLANG_BIN_DIR}/hlslang_tab.h
  COMPILE_FLAGS "-v -d"
)

flex_target(HlslangLexer ${HLSLANG_SRC_DIR}/hlslang.l ${HLSLANG_BIN_DIR}/Gen_hlslang.cpp)
add_flex_bison_dependency(HlslangLexer HlslangParser)

set(HEADER_FILES
  hlslang/Include/BaseTypes.h
  hlslang/Include/Common.h
  hlslang/Include/InfoSink.h
  hlslang/Include/InitializeGlobals.h
  hlslang/Include/InitializeParseContext.h
  hlslang/Include/intermediate.h
  hlslang/Include/PoolAlloc.h
  hlslang/Include/Types.h
  hlslang/MachineIndependent/SymbolTable.h
)
source_group("Header Files" FILES ${HEADER_FILES})


set(GLSL_CODE_GEN_FILES 
  hlslang/GLSLCodeGen/glslCommon.cpp
  hlslang/GLSLCodeGen/glslCommon.h
  hlslang/GLSLCodeGen/glslFunction.cpp
  hlslang/GLSLCodeGen/glslFunction.h
  hlslang/GLSLCodeGen/glslOutput.cpp
  hlslang/GLSLCodeGen/glslOutput.h
  hlslang/GLSLCodeGen/glslStruct.cpp
  hlslang/GLSLCodeGen/glslStruct.h
  hlslang/GLSLCodeGen/glslSymbol.cpp
  hlslang/GLSLCodeGen/glslSymbol.h
  hlslang/GLSLCodeGen/hlslCrossCompiler.cpp
  hlslang/GLSLCodeGen/hlslCrossCompiler.h
  hlslang/GLSLCodeGen/hlslLinker.cpp
  hlslang/GLSLCodeGen/hlslLinker.h
  hlslang/GLSLCodeGen/hlslSupportLib.cpp
  hlslang/GLSLCodeGen/hlslSupportLib.h
  hlslang/GLSLCodeGen/propagateMutable.cpp
  hlslang/GLSLCodeGen/propagateMutable.h
  hlslang/GLSLCodeGen/typeSamplers.cpp
  hlslang/GLSLCodeGen/typeSamplers.h
)
source_group("GLSL Code Gen" FILES ${GLSL_CODE_GEN_FILES})

set(MACHINE_INDEPENDENT_FILES
  hlslang/MachineIndependent/HLSL2GLSL.cpp
  hlslang/MachineIndependent/hlslang.l
  hlslang/MachineIndependent/hlslang.y
  hlslang/MachineIndependent/InfoSink.cpp
  hlslang/MachineIndependent/Initialize.cpp
  hlslang/MachineIndependent/Initialize.h
  hlslang/MachineIndependent/Intermediate.cpp
  hlslang/MachineIndependent/intermOut.cpp
  hlslang/MachineIndependent/IntermTraverse.cpp
  hlslang/MachineIndependent/localintermediate.h
  #hlslang/MachineIndependent/parseConst.cpp
  hlslang/MachineIndependent/ParseHelper.cpp
  hlslang/MachineIndependent/ParseHelper.h
  hlslang/MachineIndependent/PoolAlloc.cpp
  hlslang/MachineIndependent/RemoveTree.cpp
  hlslang/MachineIndependent/RemoveTree.h
  hlslang/MachineIndependent/SymbolTable.cpp
  hlslang/MachineIndependent/SymbolTable.h
  hlslang/MachineIndependent/ConstantFolding.cpp
)

source_group("Machine Independent" FILES ${MACHINE_INDEPENDENT_FILES})

set(MACHINE_INDEPENDENT_CPP_FILES
  hlslang/MachineIndependent/preprocessor/mojoshader_common.cpp
  hlslang/MachineIndependent/preprocessor/mojoshader_internal.h
  hlslang/MachineIndependent/preprocessor/mojoshader_lexer.cpp
  hlslang/MachineIndependent/preprocessor/mojoshader_preprocessor.cpp
  hlslang/MachineIndependent/preprocessor/mojoshader.cpp
  hlslang/MachineIndependent/preprocessor/mojoshader.h
  hlslang/MachineIndependent/preprocessor/sourceloc.cpp
  hlslang/MachineIndependent/preprocessor/sourceloc.h
)

# -------------------------------------------------------------------
#  OS-specific files & flags
# -------------------------------------------------------------------
if(WIN32)
  set(OSDEPENDENT_DIR
          ${CMAKE_CURRENT_SOURCE_DIR}/hlslang/OSDependent/Windows)
  set(OSDEPENDENT_FILES
          ${OSDEPENDENT_DIR}/osinclude.h
          ${OSDEPENDENT_DIR}/ossource.cpp
          ${OSDEPENDENT_DIR}/unistd.h
  )
  set(OSDEPENDENT_INCLUDE_DIR ${OSDEPENDENT_DIR})

  # add_definitions(-D_HAS_ITERATOR_DEBUGGING=0
  #         -D_SECURE_SCL=0
  #         -D_CRT_SECURE_NO_WARNINGS)
  set(TEST_LIBS opengl32)

elseif(APPLE)
  set(OSDEPENDENT_DIR
          ${CMAKE_CURRENT_SOURCE_DIR}/hlslang/OSDependent/Mac)
  set(OSDEPENDENT_FILES
          ${OSDEPENDENT_DIR}/osinclude.h
          ${OSDEPENDENT_DIR}/ossource.cpp
  )
  set(OSDEPENDENT_INCLUDE_DIR ${OSDEPENDENT_DIR})

  find_library(COCOA_LIBRARY Cocoa REQUIRED)
  find_library(OPENGL_LIBRARY OpenGL REQUIRED)
  set(TEST_LIBS ${COCOA_LIBRARY} ${OPENGL_LIBRARY})
else()
  # assume UNIX / Linux
  set(OSDEPENDENT_DIR
          ${CMAKE_CURRENT_SOURCE_DIR}/hlslang/OSDependent/Linux)
  set(OSDEPENDENT_FILES
          ${OSDEPENDENT_DIR}/osinclude.h
          ${OSDEPENDENT_DIR}/ossource.cpp
  )
  set(OSDEPENDENT_INCLUDE_DIR ${OSDEPENDENT_DIR})

  # set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ggdb")
  set(TEST_LIBS GL glut GLEW pthread)
endif()

# -------------------------------------------------------------------
#  add the library
# -------------------------------------------------------------------
add_library(hlsl2glsl
  ${HEADER_FILES}
  ${GLSL_CODE_GEN_FILES}
  ${MACHINE_INDEPENDENT_FILES}
  ${MACHINE_INDEPENDENT_CPP_FILES}
  ${OSDEPENDENT_FILES}
  ${BISON_HlslangParser_OUTPUTS}
  ${FLEX_HlslangLexer_OUTPUTS}
)

if (BUILD_SHARED_LIBS)
  target_compile_definitions(hlsl2glsl PUBLIC HLSL2GLSL_SHARED)
  target_compile_definitions(hlsl2glsl PRIVATE HLSL2GLSL_IMPLEMENTATION)
endif()

target_include_directories(hlsl2glsl
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
)

target_include_directories(hlsl2glsl
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/hlslang
    ${CMAKE_CURRENT_SOURCE_DIR}/hlslang/MachineIndependent
    ${OSDEPENDENT_DIR}
)

if(HLSL2GLSL_EXTRACT_SYMBOLS)
  target_extract_symbols(hlsl2glsl "${CMAKE_CURRENT_BINARY_DIR}/symbols.txt" "${CMAKE_SOURCE_DIR}/tools")
endif()

# -------------------------------------------------------------------
#  test executable
# -------------------------------------------------------------------
if(BUILD_HLSL2GLSLTEST)
  add_executable(hlsl2glsltest tests/hlsl2glsltest/hlsl2glsltest.cpp)
  target_link_libraries(hlsl2glsltest PRIVATE hlsl2glsl ${TEST_LIBS})
endif()

# -------------------------------------------------------------------
#  nice targets in IDEs
# -------------------------------------------------------------------
source_group("Header Files" FILES ${HEADER_FILES})
source_group("GLSL Code Gen" FILES ${GLSL_CODE_GEN_FILES})
source_group("Machine Independent" FILES ${MACHINE_INDEPENDENT_FILES})
source_group("Machine Independent\\CPP" FILES ${MACHINE_INDEPENDENT_CPP_FILES})
source_group("OSDependent" FILES ${OSDEPENDENT_FILES})

# -------------------------------------------------------------------
#  installation
# -------------------------------------------------------------------
install(TARGETS hlsl2glsl
        EXPORT hlsl2glslTargets
        ARCHIVE   DESTINATION lib          # .lib / .a
        LIBRARY   DESTINATION lib          # .so / .dylib
        RUNTIME   DESTINATION bin          # .exe on Windows
        INCLUDES  DESTINATION include      # for -I<install‐prefix>/include
)

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/
        DESTINATION include
        FILES_MATCHING PATTERN "*.h"
        PATTERN ".svn" EXCLUDE
)

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/hlslang/Include/
        DESTINATION include/hlslang
        FILES_MATCHING PATTERN "*.h"
        PATTERN ".svn" EXCLUDE
)

install(EXPORT hlsl2glslTargets
        NAMESPACE hlsl2glsl::
        DESTINATION lib/cmake/hlsl2glsl
)

if (BUILD_TESTING)
  enable_testing()
  include(FetchContent)

  FetchContent_Declare(
          googletest
          GIT_REPOSITORY https://github.com/google/googletest.git
          GIT_TAG        v1.17.0
  )
  FetchContent_MakeAvailable(googletest)
endif()

add_subdirectory(tests)
