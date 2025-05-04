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
%{
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
int yy_input(char* buf, int max_size, yyscan_t yyscanner);
thread_local TSourceLoc lexlineno = { 0, 0 };
}

extern int yyparse(hlsl2glsl::TParseContext*, yyscan_t yyscanner);
#define YY_DECL int yylex(YYSTYPE * yylval_param, hlsl2glsl::TParseContext& parseContext, yyscan_t yyscanner)

 
#define YY_INPUT(buf,result,max_size) (result = hlsl2glsl::yy_input(buf, max_size, yyscanner))

%}

%option noyywrap
%option never-interactive
%option yylineno reentrant bison-bridge
%option outfile="Gen_hlslang.cpp"
%x FIELDS


%%
<*>"//"[^\n]*"\n"     { /* ?? carriage and/or line-feed? */ };

"const"        {  yylval_param->lex.line = lexlineno; return(CONST_QUAL); }
"static"       {  yylval_param->lex.line = lexlineno; return(STATIC_QUAL); }
"uniform"      {  yylval_param->lex.line = lexlineno; return(UNIFORM); }

"break"        {  yylval_param->lex.line = lexlineno; return(BREAK); }
"continue"     {  yylval_param->lex.line = lexlineno; return(CONTINUE); }
"do"           {  yylval_param->lex.line = lexlineno; return(DO); }
"for"          {  yylval_param->lex.line = lexlineno; return(FOR); }
"while"        {  yylval_param->lex.line = lexlineno; return(WHILE); }

"if"           {  yylval_param->lex.line = lexlineno; return(IF); }
"else"         {  yylval_param->lex.line = lexlineno; return(ELSE); }

"in"           {  yylval_param->lex.line = lexlineno; return(IN_QUAL); }
"out"          {  yylval_param->lex.line = lexlineno; return(OUT_QUAL); }
"inout"        {  yylval_param->lex.line = lexlineno; return(INOUT_QUAL); }

"float"        {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(FLOAT_TYPE); }
"float1"       {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(FLOAT_TYPE); }
"int"          {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(INT_TYPE); }
"int1"         {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(INT_TYPE); }
"uint"          {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(INT_TYPE); /* @TODO proper unsigned int? */ }
"uint1"         {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(INT_TYPE); }
"void"         {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(VOID_TYPE); }
"bool"         {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(BOOL_TYPE); }
"bool1"        {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(BOOL_TYPE); }
"string"       {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(STRING_TYPE); }
"true"         {  yylval_param->lex.line = lexlineno; yylval_param->lex.b = true;  return(BOOLCONSTANT); }
"false"        {  yylval_param->lex.line = lexlineno; yylval_param->lex.b = false; return(BOOLCONSTANT); }

"discard"      {  yylval_param->lex.line = lexlineno; return(DISCARD); }
"return"       {  yylval_param->lex.line = lexlineno; return(RETURN); }

"float2x2"     {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(MATRIX2x2); }
"float2x3"     {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(MATRIX2x3); }
"float2x4"     {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(MATRIX2x4); }

"float3x2"     {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(MATRIX3x2); }
"float3x3"     {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(MATRIX3x3); }
"float3x4"     {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(MATRIX3x4); }

"float4x2"     {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(MATRIX4x2); }
"float4x3"     {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(MATRIX4x3); }
"float4x4"     {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(MATRIX4x4); }

"half2x2"      {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(HMATRIX2x2); }
"half2x3"      {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(HMATRIX2x3); }
"half2x4"      {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(HMATRIX2x4); }

"half3x2"      {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(HMATRIX3x2); }
"half3x3"      {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(HMATRIX3x3); }
"half3x4"      {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(HMATRIX3x4); }

"half4x2"      {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(HMATRIX4x2); }
"half4x3"      {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(HMATRIX4x3); }
"half4x4"      {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(HMATRIX4x4); }

"fixed2x2"      {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(FMATRIX2x2); }
"fixed2x3"      {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(FMATRIX2x3); }
"fixed2x4"      {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(FMATRIX2x4); }

"fixed3x2"      {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(FMATRIX3x2); }
"fixed3x3"      {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(FMATRIX3x3); }
"fixed3x4"      {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(FMATRIX3x4); }

"fixed4x2"      {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(FMATRIX4x2); }
"fixed4x3"      {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(FMATRIX4x3); }
"fixed4x4"      {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(FMATRIX4x4); }

"half"        {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(HALF_TYPE); }
"half1"       {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(HALF_TYPE); }
"half2"         {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return (HVEC2); }
"half3"         {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return (HVEC3); }
"half4"         {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return (HVEC4); }

"fixed"        {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(FIXED_TYPE); }
"fixed1"       {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return(FIXED_TYPE); }
"fixed2"         {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return (FVEC2); }
"fixed3"         {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return (FVEC3); }
"fixed4"         {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return (FVEC4); }

"float2"         {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return (VEC2); }
"float3"         {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return (VEC3); }
"float4"         {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return (VEC4); }
"int2"        {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return (IVEC2); }
"int3"        {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return (IVEC3); }
"int4"        {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return (IVEC4); }
"uint2"        {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return (IVEC2); /* @TODO proper unsigned type? */ }
"uint3"        {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return (IVEC3); }
"uint4"        {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return (IVEC4); }
"bool2"        {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return (BVEC2); }
"bool3"        {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return (BVEC3); }
"bool4"        {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return (BVEC4); }

"vector"        {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return (VECTOR); }
"matrix"        {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return (MATRIX); }
"register"        {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return (REGISTER); }

"sampler1D"       {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return SAMPLER1D; }
"sampler1DShadow" {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return SAMPLER1DSHADOW; }
"sampler2D"       {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return SAMPLER2D; }
"sampler2DShadow" {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return SAMPLER2DSHADOW; }
"sampler2DArray"  {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return SAMPLER2DARRAY; }
"sampler2D_half"  {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return SAMPLER2D_HALF; }
"sampler2D_float" {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return SAMPLER2D_FLOAT; }
"sampler3D"       {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return SAMPLER3D; }
"samplerRECT"     {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return SAMPLERRECT; }
"samplerRECTShadow"     {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return SAMPLERRECTSHADOW; }

"sampler"       {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return SAMPLERGENERIC; }
"samplerCUBE"     {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return SAMPLERCUBE; }
"samplerCUBE_half"     {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return SAMPLERCUBE_HALF; }
"samplerCUBE_float"    {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return SAMPLERCUBE_FLOAT; }

"texture"       {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return TEXTURE; }
"texture2D"       {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return TEXTURE; }
"texture3D"       {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return TEXTURE; }
"textureRECT"     {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return TEXTURE; }
"textureCUBE"     {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return TEXTURE; }
"sampler_state"   {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = true; return SAMPLERSTATE; }

"struct"       {  yylval_param->lex.line = lexlineno; return(STRUCT); }

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
   yylval_param->lex.line = lexlineno; 
   yylval_param->lex.string = NewPoolTString(yytext); 
   return PaIdentOrType(*yylval_param->lex.string, parseContext, yylval_param->lex.symbol); 
}

{D}+{E}{F}?           { yylval_param->lex.line = lexlineno; yylval_param->lex.f = static_cast<float>(atof(yytext)); return(FLOATCONSTANT); }
{D}+"."{D}*({E})?{F}? { yylval_param->lex.line = lexlineno; yylval_param->lex.f = static_cast<float>(atof(yytext)); return(FLOATCONSTANT); }
"."{D}+({E})?{F}?     { yylval_param->lex.line = lexlineno; yylval_param->lex.f = static_cast<float>(atof(yytext)); return(FLOATCONSTANT); }
{D}+{F}               { yylval_param->lex.line = lexlineno; yylval_param->lex.f = static_cast<float>(atof(yytext)); return(FLOATCONSTANT); }

0[xX]{H}+{I}?         { yylval_param->lex.line = lexlineno; yylval_param->lex.i = strtol(yytext, 0, 0); return(INTCONSTANT); }
0{O}+{I}?             { yylval_param->lex.line = lexlineno; yylval_param->lex.i = strtol(yytext, 0, 0); return(INTCONSTANT); }
0{D}+{I}?             { yylval_param->lex.line = lexlineno; parseContext.error(lexlineno, "Invalid Octal number.", yytext, "", ""); parseContext.recover(); return 0;}
{D}+{I}?              { yylval_param->lex.line = lexlineno; yylval_param->lex.i = strtol(yytext, 0, 0); return(INTCONSTANT); }





"/*"            {  int ret = PaParseComment(yylval_param->lex.line, parseContext, &yyscanner); if (!ret) return ret; }

"+="            {  yylval_param->lex.line = lexlineno; return(ADD_ASSIGN); }
"-="            {  yylval_param->lex.line = lexlineno; return(SUB_ASSIGN); }
"*="            {  yylval_param->lex.line = lexlineno; return(MUL_ASSIGN); }
"/="            {  yylval_param->lex.line = lexlineno; return(DIV_ASSIGN); }
"%="            {  yylval_param->lex.line = lexlineno; return(MOD_ASSIGN); }
"<<="           {  yylval_param->lex.line = lexlineno; return(LEFT_ASSIGN); }
">>="           {  yylval_param->lex.line = lexlineno; return(RIGHT_ASSIGN); }
"&="            {  yylval_param->lex.line = lexlineno; return(AND_ASSIGN); }
"^="            {  yylval_param->lex.line = lexlineno; return(XOR_ASSIGN); }
"|="            {  yylval_param->lex.line = lexlineno; return(OR_ASSIGN); }

"++"            {  yylval_param->lex.line = lexlineno; return(INC_OP); }
"--"            {  yylval_param->lex.line = lexlineno; return(DEC_OP); }
"&&"            {  yylval_param->lex.line = lexlineno; return(AND_OP); }
"||"            {  yylval_param->lex.line = lexlineno; return(OR_OP); }
"^^"            {  yylval_param->lex.line = lexlineno; return(XOR_OP); }
"<="            {  yylval_param->lex.line = lexlineno; return(LE_OP); }
">="            {  yylval_param->lex.line = lexlineno; return(GE_OP); }
"=="            {  yylval_param->lex.line = lexlineno; return(EQ_OP); }
"!="            {  yylval_param->lex.line = lexlineno; return(NE_OP); }
"<<"            {  yylval_param->lex.line = lexlineno; return(LEFT_OP); }
">>"            {  yylval_param->lex.line = lexlineno; return(RIGHT_OP); }
";"         {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = false; return(SEMICOLON); }
"{"      {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = false; return(LEFT_BRACE); }
"}"      {  yylval_param->lex.line = lexlineno; return(RIGHT_BRACE); }
","         {  yylval_param->lex.line = lexlineno; if (parseContext.inTypeParen) parseContext.lexAfterType = false; return(COMMA); }
":"         {  yylval_param->lex.line = lexlineno; return(COLON); }
"="         {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = false; return(EQUAL); }
"("         {  yylval_param->lex.line = lexlineno; parseContext.lexAfterType = false; parseContext.inTypeParen = true; return(LEFT_PAREN); }
")"         {  yylval_param->lex.line = lexlineno; parseContext.inTypeParen = false; return(RIGHT_PAREN); }
"["      {  yylval_param->lex.line = lexlineno; return(LEFT_BRACKET); }
"]"      {  yylval_param->lex.line = lexlineno; return(RIGHT_BRACKET); }
"."         { BEGIN(FIELDS);  return(DOT); }
"!"         {  yylval_param->lex.line = lexlineno; return(BANG); }
"-"         {  yylval_param->lex.line = lexlineno; return(DASH); }
"~"         {  yylval_param->lex.line = lexlineno; return(TILDE); }
"+"         {  yylval_param->lex.line = lexlineno; return(PLUS); }
"*"         {  yylval_param->lex.line = lexlineno; return(STAR); }
"/"         {  yylval_param->lex.line = lexlineno; return(SLASH); }
"%"         {  yylval_param->lex.line = lexlineno; return(PERCENT); }
"<"         {  yylval_param->lex.line = lexlineno; return(LEFT_ANGLE); }
">"         {  yylval_param->lex.line = lexlineno; return(RIGHT_ANGLE); }
"|"         {  yylval_param->lex.line = lexlineno; return(VERTICAL_BAR); }
"^"         {  yylval_param->lex.line = lexlineno; return(CARET); }
"&"         {  yylval_param->lex.line = lexlineno; return(AMPERSAND); }
"?"         {  yylval_param->lex.line = lexlineno; return(QUESTION); }

\"[^\"]*\"  {  yylval_param->lex.line = lexlineno; return(STRINGCONSTANT); }

<FIELDS>{L}({L}|{D})* { 
BEGIN(INITIAL);      
    yylval_param->lex.line = lexlineno;     
    yylval_param->lex.string = NewPoolTString(yytext); 
    return FIELD_SELECTION; }
<FIELDS>[ \t\v\f\r] {}


[ \t\v\n\f\r]   {  }
<*><<EOF>> { (&parseContext)->AfterEOF = true; return YY_NULL; }
<*>.    { parseContext.infoSink.info << "FLEX: Unknown char " << yytext << "\n";
          return 0; }

%%


#include "preprocessor/mojoshader.h"
#define __MOJOSHADER_INTERNAL__ 1
#include "preprocessor/mojoshader_internal.h"
#include <cstring>

//thread_local hlmojo_Preprocessor* g_cpp;
//thread_local TParseContext* g_parseContext;

namespace hlsl2glsl {

const TSourceLoc gNullSourceLoc = { NULL, 0 };

static int cpp_get_token (hlmojo_Preprocessor* pp, char* buf, int maxSize, hlsl2glsl::TParseContext* parseContext)
{
	const char *tokstr = NULL;
	unsigned int len = 0;
	Token token = TOKEN_UNKNOWN;
	tokstr = hlmojo_preprocessor_nexttoken (pp, &len, &token);
	if (tokstr == NULL)
		return 0;
		
	if (hlmojo_preprocessor_outofmemory(pp))
	{
		parseContext->error (gNullSourceLoc, "out of memory", "", "");
		GlobalParseContext->recover();
		buf[0] = 0;
		return 0;
	}	
	
	unsigned int line = 0;
	const char* fname = hlmojo_preprocessor_sourcepos (pp, &line);
	TSourceLoc loc;
	loc.file = fname;
	loc.line = line;
	SetLineNumber (loc, lexlineno);
	
	if (token == TOKEN_PREPROCESSING_ERROR)
	{
		parseContext->error (lexlineno, tokstr, "", "");
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
			memcpy (buf, tokstr, len+1);
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

int yy_input(char* buf, int max_size, yyscan_t yyscanner)
{
	int len;

	// Get the parse context from the scanner
    hlsl2glsl::TParseContext* parseContext = (hlsl2glsl::TParseContext*)yyget_extra(yyscanner);

    // Check if we have a valid preprocessor for this context
    void* pp = nullptr;
    if (parseContext) {
        pp = parseContext->preprocessor;
    }

    if (!pp) {
        return 0;
    }

    if ((len = hlsl2glsl::cpp_get_token(static_cast<hlmojo_Preprocessor*>(pp), buf, max_size, parseContext)) == 0)
        return 0;
    if (len >= max_size)
        YY_FATAL_ERROR( "input buffer overflow, can't enlarge buffer because scanner uses REJECT" );

    //debug code to dump the token stream to stdout
    //buf[len] = '\0';
    //printf( ":: %s\n", buf);

    buf[len] = ' ';
	return len+1;
}

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
	
	MOJOSHADER_hlslang_includeOpen openCallback = NULL;
    MOJOSHADER_hlslang_includeClose closeCallback = NULL;
	void* data = NULL;
	if (callbacks) {
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
        int scannerStatus = yylex_init(&scanner);
        if (scannerStatus != 0) {
            throw std::runtime_error("Failed to initialize scanner");
        }
        scannerInitialized = true;

        // Set extra data (parse context) for the scanner
        yyset_extra(&parseContextLocal, scanner);

        if (sourceLen >= 0) {
            // Call the parser with the scanner
            // The parser will call yylex with the scanner
            yyparse(parseContextLocal, scanner);

            if (parseContextLocal.recoveredFromError || parseContextLocal.numErrors > 0)
                result = 1;
            else
                result = 0;
        }
        else {
            result = 0;
        }
    }
    catch (const std::exception& e) {
        result = 1;
        // Error already set in parse context or default error returned
    }

    // Always clean up resources, even if there was an error
    if (scannerInitialized) {
        yylex_destroy(scanner);
    }

    if (pp) {
        hlmojo_preprocessor_end(pp);
    }

    parseContextLocal.preprocessor = nullptr;

    return result;
}

// Parser error handling: match Bison error calls (parseContext, scanner, message)
void yyerror(TParseContext& parseContext, void* /*scanner*/, const char *s)
{ 
    // Report syntax error; scanner parameter unused
    parseContext.error(lexlineno, "syntax error", "", s, "");
    parseContext.recover();
}

void PaReservedWord()
{
    // GlobalParseContext->error(lexlineno, "Reserved word.", yytext, "", "");
    GlobalParseContext->error(lexlineno, "Reserved word.", "", "", "");
    GlobalParseContext->recover();
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

int PaParseComment(TSourceLoc &lineno, TParseContext& parseContextLocal, void* scanner)
{
    int transitionFlag = 0;
    int nextChar;
    yyscan_t* yyscanner = static_cast<yyscan_t*>(scanner);
    
    while (transitionFlag != 2) {
        nextChar = yyinput(*yyscanner);
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
            parseContextLocal.error(lexlineno, "End of shader found before end of comment.", "", "", "");
            GlobalParseContext->recover();
            return YY_NULL; 
        default :  /* Any other character will be a part of the comment */
            transitionFlag = 0;
        }
    }
    return 1;
}


void setInitialState()
{
    // yy_start = 1;
}

} // namespace hlsl2glsl
