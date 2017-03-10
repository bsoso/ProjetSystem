%{

#include <stdio.h>
#include <stdlib.h>

#include "y.tab.h"

%}

blancs	[\t\n ]+
char		[A-Za-z]
nombre	[0-9]+
nbExp		[0-9]+e[0-9]+
nbDec		[0-9]+\.[0-9]+
id 		{char}({char}|{nombre}|_)*


%%
"main"		{return tMain;}
"if"			{return tIf;}
"else"		{return tElse;}
"while"		{return tWhile;}
"int"			{return tInt;}
"const"		{return tConst;}

"{"			{return tAo;}
"}"			{return tAf;}
"("			{return tPo;}
")"			{return tPf;}
"["			{return tCo;}
"]"			{return tCf;}

";"			{return tPv;}
","			{return tVir;}
"."			{return tDot;}

"="			{return tEqu;}

"/"			{return tDiv;}
"*"			{return tStar;}
"+"			{return tPlus;}
"-"			{return tMinus;}

"return"		{return tRet;}
"printf"		{return tPrint;}

"!"			{return tNot;}
"=="			{return tEquEqu;}
"&&"			{return tAnd;}
"||"			{return tOr;}
"<"			{return tInf;}
">"			{return tSup;}
"<="			{return tInfEqu;}
">="			{return tSupEqu;}

{nbExp}		{yylval.nb = atof(yytext); return tNb;}
{nbDec}		{yylval.nb = atof(yytext); return tNb;}
{nombre}		{yylval.nb = atoi(yytext); return tNb;}
{id}			{yylval.str = strdup(yytext); return tId;}
{blancs}		;
. 				return yytext[0];
%%
