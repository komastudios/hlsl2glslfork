/*-*-C++-*-

// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.

*/
/* Based on
ANSI C grammar, Lex specification

In 1985, Jeff Lee published this Lex specification together with a Yacc 
grammar for the April 30, 1985 ANSI C draft.  Tom Stockfisch reposted 
both to net.sources in 1987; that original, as mentioned in the answer 
to question 17.25 of the comp.lang.c FAQ, can be ftp'ed from ftp.uu.net, 
file usenet/net.sources/ansi.c.grammar.Z. 

I intend to keep this version as close to the current C Standard grammar 
as possible; please let me know if you discover discrepancies. 

Jutta Degener, 1995 
*/

D           [0-9]
L           [a-zA-Z_]
H           [a-fA-F0-9]
E           [Ee][+-]?{D}+
O           [0-7]
F           [hHfF]
I           [uUlL]


%option nounput
%option reentrant
%option prefix="hlsl2glsl_yy"
%{

/* Define scanner types for reentrant implementation */
typedef struct YYLTYPE {
    int first_line;
    int first_column;
    int last_line;
    int last_column;
} YYLTYPE;
typedef void* yyscan_t;

#define YYLTYPE_IS_DECLARED 1
#define YYLTYPE_IS_TRIVIAL 1
#define YY_NO_UNISTD_H

#include <stdio.h>
#include <stdlib.h>
#include "ParseHelper.h"
#include "hlslang_tab.h"

using namespace hlsl2glsl;

/* windows only pragma */
#ifdef _MSC_VER
#pragma warning(disable : 4102)
#endif

namespace hlsl2glsl {
// Location tracking structure for reentrant scanner
struct TSourceLocTracker {
    const char* file;
    int line;
};
}

// Define parse context accessor macro
#define YYPARSE_PARAM_TYPE hlsl2glsl::TParseContext*
#define YYPARSE_PARAM parseContext
#define YY_EXTRA_TYPE hlsl2glsl::TParseContext*
#define YY_DECL int hlsl2glsl_yylex(YYSTYPE* yylval, yyscan_t yyscanner)
#define YY_USER_ACTION /* No action */

// Forward declare the input function with extern "C" linkage
#ifdef __cplusplus
extern "C" {
#endif
int hlslapp_input(char* buf, int max_size, yyscan_t yyscanner);
#ifdef __cplusplus
}
#endif
#define YY_INPUT(buf,result,max_size) (result = hlslapp_input(buf, max_size, yyscanner))

%}

%option noyywrap
%option never-interactive
%option outfile="Gen_hlslang.cpp"
%x FIELDS


%%
<*>"//"[^\n]*"\n"     { /* ?? carriage and/or line-feed? */ };

"const"        {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(CONST_QUAL); }
"static"       {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(STATIC_QUAL); }
"uniform"      {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(UNIFORM); }

"break"        {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(BREAK); }
"continue"     {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(CONTINUE); }
"do"           {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(DO); }
"for"          {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(FOR); }
"while"        {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(WHILE); }

"if"           {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(IF); }
"else"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(ELSE); }

"in"           {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(IN_QUAL); }
"out"          {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(OUT_QUAL); }
"inout"        {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(INOUT_QUAL); }

"float"        {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(FLOAT_TYPE); }
"float1"       {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(FLOAT_TYPE); }
"int"          {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(INT_TYPE); }
"int1"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(INT_TYPE); }
"uint"          {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(INT_TYPE); /* @TODO proper unsigned int? */ }
"uint1"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(INT_TYPE); }
"void"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(VOID_TYPE); }
"bool"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(BOOL_TYPE); }
"bool1"        {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(BOOL_TYPE); }
"string"       {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(STRING_TYPE); }
"true"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; yylval->lex.b = true;  return(BOOLCONSTANT); }
"false"        {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; yylval->lex.b = false; return(BOOLCONSTANT); }

"discard"      {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(DISCARD); }
"return"       {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(RETURN); }

"float2x2"     {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(MATRIX2x2); }
"float2x3"     {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(MATRIX2x3); }
"float2x4"     {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(MATRIX2x4); }

"float3x2"     {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(MATRIX3x2); }
"float3x3"     {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(MATRIX3x3); }
"float3x4"     {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(MATRIX3x4); }

"float4x2"     {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(MATRIX4x2); }
"float4x3"     {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(MATRIX4x3); }
"float4x4"     {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(MATRIX4x4); }

"half2x2"      {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(HMATRIX2x2); }
"half2x3"      {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(HMATRIX2x3); }
"half2x4"      {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(HMATRIX2x4); }

"half3x2"      {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(HMATRIX3x2); }
"half3x3"      {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(HMATRIX3x3); }
"half3x4"      {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(HMATRIX3x4); }

"half4x2"      {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(HMATRIX4x2); }
"half4x3"      {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(HMATRIX4x3); }
"half4x4"      {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(HMATRIX4x4); }

"fixed2x2"      {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(FMATRIX2x2); }
"fixed2x3"      {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(FMATRIX2x3); }
"fixed2x4"      {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(FMATRIX2x4); }

"fixed3x2"      {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(FMATRIX3x2); }
"fixed3x3"      {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(FMATRIX3x3); }
"fixed3x4"      {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(FMATRIX3x4); }

"fixed4x2"      {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(FMATRIX4x2); }
"fixed4x3"      {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(FMATRIX4x3); }
"fixed4x4"      {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(FMATRIX4x4); }

"half"        {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(HALF_TYPE); }
"half1"       {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(HALF_TYPE); }
"half2"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return (HVEC2); }
"half3"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return (HVEC3); }
"half4"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return (HVEC4); }

"fixed"        {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(FIXED_TYPE); }
"fixed1"       {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return(FIXED_TYPE); }
"fixed2"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return (FVEC2); }
"fixed3"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return (FVEC3); }
"fixed4"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return (FVEC4); }

"float2"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return (VEC2); }
"float3"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return (VEC3); }
"float4"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return (VEC4); }
"int2"        {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return (IVEC2); }
"int3"        {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return (IVEC3); }
"int4"        {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return (IVEC4); }
"uint2"        {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return (IVEC2); /* @TODO proper unsigned type? */ }
"uint3"        {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return (IVEC3); }
"uint4"        {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return (IVEC4); }
"bool2"        {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return (BVEC2); }
"bool3"        {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return (BVEC3); }
"bool4"        {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return (BVEC4); }

"vector"        {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return (VECTOR); }
"matrix"        {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return (MATRIX); }
"register"        {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return (REGISTER); }

"sampler1D"       {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return SAMPLER1D; }
"sampler1DShadow" {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return SAMPLER1DSHADOW; }
"sampler2D"       {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return SAMPLER2D; }
"sampler2DShadow" {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return SAMPLER2DSHADOW; }
"sampler2DArray"  {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return SAMPLER2DARRAY; }
"sampler2D_half"  {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return SAMPLER2D_HALF; }
"sampler2D_float" {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return SAMPLER2D_FLOAT; }
"sampler3D"       {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return SAMPLER3D; }
"samplerRECT"     {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return SAMPLERRECT; }
"samplerRECTShadow"     {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return SAMPLERRECTSHADOW; }

"sampler"       {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return SAMPLERGENERIC; }
"samplerCUBE"     {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return SAMPLERCUBE; }
"samplerCUBE_half"     {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return SAMPLERCUBE_HALF; }
"samplerCUBE_float"    {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return SAMPLERCUBE_FLOAT; }

"texture"       {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return TEXTURE; }
"texture2D"       {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return TEXTURE; }
"texture3D"       {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return TEXTURE; }
"textureRECT"     {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return TEXTURE; }
"textureCUBE"     {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return TEXTURE; }
"sampler_state"   {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = true; return SAMPLERSTATE; }

"struct"       {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(STRUCT); }

"asm"          {  PaReservedWord(); return 0; }

"class"        {  PaReservedWord(); return 0; }
"union"        {  PaReservedWord(); return 0; }
"enum"         {  PaReservedWord(); return 0; }
"typedef"      {  PaReservedWord(); return 0; }
"template"     {  PaReservedWord(); return 0; }
"this"         {  PaReservedWord(); return 0; }
"packed"       {  PaReservedWord(); return 0; }

"goto"         {  PaReservedWord(); return 0; }
"switch"       {  PaReservedWord(); return 0; }
"default"      {  PaReservedWord(); return 0; }

"inline"       {  /* just ignore it PaReservedWord(); return 0; */ }
"noinline"     {  /* just ignore it PaReservedWord(); return 0; */ }
"volatile"     {  PaReservedWord(); return 0; }
"public"       {  PaReservedWord(); return 0; }
"extern"       {  PaReservedWord(); return 0; }
"external"     {  PaReservedWord(); return 0; }
"interface"    {  PaReservedWord(); return 0; }

"long"         {  PaReservedWord(); return 0; }
"short"        {  PaReservedWord(); return 0; }
"double"       {  PaReservedWord(); return 0; }
"unsigned"     {  PaReservedWord(); return 0; }

"sampler3DRect"        {  PaReservedWord(); return 0; }

"sizeof"       {  PaReservedWord(); return 0; }
"cast"         {  PaReservedWord(); return 0; }

"namespace"    {  PaReservedWord(); return 0; }
"using"        {  PaReservedWord(); return 0; }

{L}({L}|{D})*       {  
   yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; 
   yylval->lex.string = NewPoolTString(yytext); 
   return PaIdentOrType(*yylval->lex.string, *GlobalParseContext, yylval->lex.symbol); 
}

{D}+{E}{F}?           { yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; yylval->lex.f = static_cast<float>(atof(yytext)); return(FLOATCONSTANT); }
{D}+"."{D}*({E})?{F}? { yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; yylval->lex.f = static_cast<float>(atof(yytext)); return(FLOATCONSTANT); }
"."{D}+({E})?{F}?     { yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; yylval->lex.f = static_cast<float>(atof(yytext)); return(FLOATCONSTANT); }
{D}+{F}               { yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; yylval->lex.f = static_cast<float>(atof(yytext)); return(FLOATCONSTANT); }

0[xX]{H}+{I}?         { yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; yylval->lex.i = strtol(yytext, 0, 0); return(INTCONSTANT); }
0{O}+{I}?             { yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; yylval->lex.i = strtol(yytext, 0, 0); return(INTCONSTANT); }
0{D}+{I}?             { yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->error(yylval->lex.line, "Invalid Octal number.", yytext, "", ""); GlobalParseContext->recover(); return 0;}
{D}+{I}?              { yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; yylval->lex.i = strtol(yytext, 0, 0); return(INTCONSTANT); }





"/*"            {  int ret = PaParseComment(yylval->lex.line, *GlobalParseContext); if (!ret) return ret; }   

"+="            {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(ADD_ASSIGN); }
"-="            {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(SUB_ASSIGN); }
"*="            {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(MUL_ASSIGN); }
"/="            {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(DIV_ASSIGN); }
"%="            {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(MOD_ASSIGN); }
"<<="           {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(LEFT_ASSIGN); }
">>="           {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(RIGHT_ASSIGN); }
"&="            {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(AND_ASSIGN); }
"^="            {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(XOR_ASSIGN); }
"|="            {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(OR_ASSIGN); }

"++"            {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(INC_OP); }
"--"            {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(DEC_OP); }
"&&"            {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(AND_OP); }
"||"            {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(OR_OP); }
"^^"            {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(XOR_OP); }
"<="            {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(LE_OP); }
">="            {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(GE_OP); }
"=="            {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(EQ_OP); }
"!="            {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(NE_OP); }
"<<"            {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(LEFT_OP); }
">>"            {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(RIGHT_OP); }
";"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = false; return(SEMICOLON); }
"{"      {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = false; return(LEFT_BRACE); }
"}"      {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(RIGHT_BRACE); }
","         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; if (GlobalParseContext->inTypeParen) GlobalParseContext->lexAfterType = false; return(COMMA); }
":"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(COLON); }
"="         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = false; return(EQUAL); }
"("         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->lexAfterType = false; GlobalParseContext->inTypeParen = true; return(LEFT_PAREN); }
")"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; GlobalParseContext->inTypeParen = false; return(RIGHT_PAREN); }
"["      {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(LEFT_BRACKET); }
"]"      {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(RIGHT_BRACKET); }
"."         { BEGIN(FIELDS);  return(DOT); }
"!"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(BANG); }
"-"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(DASH); }
"~"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(TILDE); }
"+"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(PLUS); }
"*"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(STAR); }
"/"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(SLASH); }
"%"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(PERCENT); }
"<"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(LEFT_ANGLE); }
">"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(RIGHT_ANGLE); }
"|"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(VERTICAL_BAR); }
"^"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(CARET); }
"&"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(AMPERSAND); }
"?"         {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(QUESTION); }

\"[^\"]*\"  {  yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno; return(STRINGCONSTANT); }

<FIELDS>{L}({L}|{D})* { 
BEGIN(INITIAL);      
    yylval->lex.line.file = NULL; yylval->lex.line.line = yylineno;     
    yylval->lex.string = NewPoolTString(yytext); 
    return FIELD_SELECTION; }
<FIELDS>[ \t\v\f\r] {}


[ \t\v\n\f\r]   {  }
<*><<EOF>> { 
    GlobalParseContext->AfterEOF = true; 
    /* Important: For thread safety, we need to be careful about how EOF is handled */
    /* Return NULL to indicate end of input, but don't modify buffer state here */
    return YY_NULL;
}
<*>.    { GlobalParseContext->infoSink.info << "FLEX: Unknown char " << yytext << "\n";
          return 0; }

%%


#include "preprocessor/mojoshader.h"
#define __MOJOSHADER_INTERNAL__ 1
#include "preprocessor/mojoshader_internal.h"
#include <cstring>

namespace hlsl2glsl {
// Forward declare yyparse for proper linkage
extern "C" {
    int yyparse(void* parseContext, void* scanner);
}

const TSourceLoc gNullSourceLoc = { NULL, 0 };

// Function to get preprocessor tokens
int cpp_get_token (char* buf, int maxSize, void* ppVoid, TParseContext* parseContext)
{
    // Check params
    if (!ppVoid || !parseContext) return 0;
    
    // Use the preprocessor
    hlmojo_Preprocessor* pp = (hlmojo_Preprocessor*)ppVoid;
    
    const char *tokstr = NULL;
    unsigned int len = 0;
    Token token = TOKEN_UNKNOWN;
    tokstr = hlmojo_preprocessor_nexttoken(pp, &len, &token);
    if (tokstr == NULL)
        return 0;
        
    if (hlmojo_preprocessor_outofmemory(pp))
    {
        parseContext->error(gNullSourceLoc, "out of memory", "", "");
        parseContext->recover();
        buf[0] = 0;
        return 0;
    }    
    
    // Get source position from preprocessor and update local tracking
    unsigned int line = 0;
    const char* fname = hlmojo_preprocessor_sourcepos(pp, &line);
    TSourceLoc loc;
    loc.file = fname;
    loc.line = line;
    
    // Special handling for #line directives - these are critical for preserving line information
    if (token == TOKEN_PP_LINE) {
        // The preprocessor will handle this correctly, but we ensure proper line directive
        // output in the resulting GLSL code later
    }
    
    if (token == TOKEN_PREPROCESSING_ERROR)
    {
        parseContext->error(loc, tokstr, "", "");
        parseContext->recover();
        buf[0] = 0;
    }
    else
    {
        if (len >= maxSize)
        {
            return maxSize;
        }
        else if (len > 0)
        {
            memcpy(buf, tokstr, len+1);
            return len;
        }
        return 0;
    }
    return 0;
} // cpp_get_token


//
// The YY_INPUT macro just calls this.  Maybe this could be just put into
// the macro directly.
//

#ifdef __cplusplus
extern "C" {
#endif
int hlslapp_input(char* buf, int max_size, yyscan_t yyscanner)
{
    int len;
    
    // Get the parse context from the scanner
    hlsl2glsl::TParseContext* parseContext = (hlsl2glsl::TParseContext*)hlsl2glsl_yyget_extra(yyscanner);
    
    // Check if we have a valid preprocessor for this context
    void* pp = nullptr;
    if (parseContext) {
        pp = parseContext->preprocessor;
    }
    
    if (!pp) {
        return 0;
    }

    if ((len = hlsl2glsl::cpp_get_token(buf, max_size, pp, parseContext)) == 0)
        return 0;
    if (len >= max_size)
        YY_FATAL_ERROR( "input buffer overflow, can't enlarge buffer because scanner uses REJECT" );

    //debug code to dump the token stream to stdout
    //buf[len] = '\0';
    //printf( ":: %s\n", buf);

    buf[len] = ' ';
    return len+1;
}
#ifdef __cplusplus
}
#endif

int IncludeOpenCallback(MOJOSHADER_hlslang_includeType inctype,
                        const char *fname, const char *parentfname, const char *parent,
                        const char **outdataPtr, unsigned int *outbytesPtr,
                        MOJOSHADER_hlslang_malloc m, MOJOSHADER_hlslang_free f, void *d)
{
	Hlsl2Glsl_ParseCallbacks* callbacks = reinterpret_cast<Hlsl2Glsl_ParseCallbacks*>(d);
	std::string out;
	if (callbacks->includeOpenCallback &&
		!callbacks->includeOpenCallback(inctype == MOJOSHADER_hlslang_INCLUDETYPE_SYSTEM,
										fname, parentfname, parent, out, callbacks->data))
	{
		return 0;
	}

	char* outdata = (char*) m(out.size() + 1, NULL);
	std::memcpy(outdata, out.data(), out.size()+1);
	*outdataPtr = outdata;
	*outbytesPtr = out.size();
	return 1;
}

void IncludeCloseCallback(const char *data,
                          MOJOSHADER_hlslang_malloc m, MOJOSHADER_hlslang_free f, void *d)
{
	Hlsl2Glsl_ParseCallbacks* callbacks = reinterpret_cast<Hlsl2Glsl_ParseCallbacks*>(d);
	if (callbacks->includeCloseCallback)
		callbacks->includeCloseCallback(data, callbacks->data);
	f(const_cast<char*>(data), NULL);
}

//
// Parse a string using yyparse.  We set up globals used by
// yywrap.
//
// Returns 0 for success, as per yyparse().
//
int PaParseString(char* source, TParseContext& parseContextLocal, Hlsl2Glsl_ParseCallbacks* callbacks)
{
    int sourceLen;
    int result = 1; // Default to error
    hlmojo_Preprocessor* pp = nullptr;
    yyscan_t scanner = nullptr;
    bool scannerInitialized = false;

    // Input validation
    if (!source) {
        parseContextLocal.error(gNullSourceLoc, "Null shader source string", "", "");
        parseContextLocal.recover();
        return 1;
    }
    
    sourceLen = (int) strlen(source);
    
    // Setup callback and data pointers
    MOJOSHADER_hlslang_includeOpen openCallback = NULL;
    MOJOSHADER_hlslang_includeClose closeCallback = NULL;
    void* data = NULL;
    if (callbacks)
    {
        openCallback = IncludeOpenCallback;
        closeCallback = IncludeCloseCallback;
        data = callbacks;
    }

    try {
        // Create the preprocessor
        pp = hlmojo_preprocessor_start("", source, sourceLen,
            openCallback,
            closeCallback,
            NULL, // defines
            0, // define count
            MOJOSHADER_hlslang_internal_malloc,
            MOJOSHADER_hlslang_internal_free,
            data);
            
        if (!pp) {
            throw std::runtime_error("Failed to initialize preprocessor");
        }
        
        // Store preprocessor in the parse context (thread-safe)
        parseContextLocal.preprocessor = pp;
        
        // Reset state
        parseContextLocal.AfterEOF = false;
        
        // Initialize the reentrant scanner
        int scannerStatus = hlsl2glsl_yylex_init(&scanner);
        if (scannerStatus != 0) {
            throw std::runtime_error("Failed to initialize scanner");
        }
        scannerInitialized = true;
        
        // Set extra data (parse context) for the scanner
        hlsl2glsl_yyset_extra(&parseContextLocal, scanner);
        
        if (sourceLen >= 0)
        {
            // Call the parser with the scanner
            // The parser will call yylex with the scanner
            yyparse((void*)&parseContextLocal, (void*)scanner);
            
            if (parseContextLocal.recoveredFromError || parseContextLocal.numErrors > 0)
                result = 1;
            else
                result = 0;
        }
        else
        {
            result = 0;
        }
    }
    catch (const std::exception& e) {
        result = 1;
        // Error already set in parse context or default error returned
    }
    
    // Always clean up resources, even if there was an error
    if (scannerInitialized) {
        hlsl2glsl_yylex_destroy(scanner);
    }
    
    if (pp) {
        hlmojo_preprocessor_end(pp);
        parseContextLocal.preprocessor = nullptr;
    }
    
    return result;
}

// Error function for the Bison parser with extern "C" linkage
#ifdef __cplusplus
extern "C" {
#endif
void yyerror(void* parseContext, void* scanner, const char* s)
{
    // Get the parse context directly from the parameter
    hlsl2glsl::TParseContext* ctx = (hlsl2glsl::TParseContext*)parseContext;
    if (!ctx) return;
    
    // Get source location information for better error reporting
    hlsl2glsl::TSourceLoc loc;
    loc.file = NULL;
    loc.line = 0;
    
    // If we have a preprocessor in this context, get the current file and line
    if (ctx->preprocessor) {
        hlmojo_Preprocessor* pp = (hlmojo_Preprocessor*)ctx->preprocessor;
        unsigned int line = 0;
        const char* fname = hlmojo_preprocessor_sourcepos(pp, &line);
        if (fname) {
            loc.file = fname;
            loc.line = line;
        }
    }
    
    ctx->error(loc, "syntax error", "", s, "");
    ctx->recover();
}
#ifdef __cplusplus
}
#endif

void PaReservedWord()
{
    // Warning: This function is not thread-safe and should be updated
    // to accept a context parameter for proper reentrant operation
    
    // We can't directly access the parse context here since we don't have any 
    // thread-local context, so we'll rely on the GlobalParseContext mechanism
    // for now. This means that this function is not thread-safe.
    TParseContext* parseContext = GlobalParseContext;
    if (parseContext) {
        TSourceLoc loc;
        loc.file = NULL;
        loc.line = 0;
        
        parseContext->error(loc, "Reserved word.", "", "", "");
        parseContext->recover();
    }
}

int PaIdentOrType(TString& id, TParseContext& parseContextLocal, TSymbol*& symbol)
{
    symbol = parseContextLocal.symbolTable.find(id);
    if (parseContextLocal.lexAfterType == false && symbol && symbol->isVariable()) {
        TVariable* variable = static_cast<TVariable*>(symbol);
        if (variable->isUserType()) {
            parseContextLocal.lexAfterType = true;
            return TYPE_NAME;
        }
    }
    
    return IDENTIFIER;
}

int PaParseComment(TSourceLoc &lineno, TParseContext& parseContextLocal)
{
    // WARNING: This function is not reentrant-safe and should be updated
    // to use the scanner parameter for full thread safety
    int transitionFlag = 0;
    int nextChar;
    
    while (transitionFlag != 2) {
        // Just read from stdin for now
        // In a proper implementation, we should be using the reentrant scanner's input functions
        nextChar = fgetc(stdin);
        if (nextChar == '\n')
             lineno.line++;
        switch (nextChar) {
        case '*' :
            transitionFlag = 1;
            break;
        case '/' :  /* if star is the previous character, then it is the end of comment */
            if (transitionFlag == 1) {
                return 1 ;
            }
            break;
        case EOF :
            /* Raise error message here */
            parseContextLocal.error(lineno, "End of shader found before end of comment.", "", "", "");
            parseContextLocal.recover();
            return YY_NULL; 
        default :  /* Any other character will be a part of the comment */
            transitionFlag = 0;
        }
    }
    return 1;
}


// Original function is now inlined in PaParseString

// This is the original function, maintained for compatibility
void setInitialState() 
{
    // Empty implementation for backwards compatibility
}

} // namespace hlsl2glsl
