%option noyywrap

%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "parser.tab.h"

char symbolTable[100][50];
int wrong=0;
int cursor = 0;

int install_id(char* next) {

	for (int i = 0; i < cursor; i++) {
		if (strcmp(next, symbolTable[i]) == 0) {
			return i;
		}
	}

	strcpy(symbolTable[cursor], next);
	return cursor++;
}

// int toNum(char* INT_NUM) {
// 	int i = 0;
// 	int count = 0;
// 	int res[50];
// 	while(INT_NUM[i] != '\0') {
// 		int num = INT_NUM[i];
// 		if (num >= 0 && num <= 255) {
// 			res[count] = atoi(&INT_NUM[i]);
// 			count++;
// 		} else {
// 			if (num != -37) {
// 				res[count] = num + 80;
// 				count++;
// 			}
// 		}
// 		i++;
// 	}
// 	int r = 0;
// 	for (int j = 0; j < count; j++) {
// 		r += res[j]*pow(10,count-j-1);
// 	}
// 	return r;
// }

char* toChar(char* harf) {
	if (strcmp(harf, "\'\\n\'") == 0) {
		return "newline";
	} else if ( strcmp(harf, "\'\\0\'") == 0 || strcmp(harf, "\'\\۰\'") == 0 ) {
		return "null";
	} else {
		int idxToDel = 1;
		memmove(&harf[idxToDel], &harf[idxToDel + 1], strlen(harf) - idxToDel);
		return harf;
	}
}

%}

ZERO (0|۰)
DIGIT (۰|۱|۲|۳|۴|۵|۶|۷|۸|۹|[0-9])
NONZERO_DIGIT (۱|۲|۳|۴|۵|۶|۷|۸|۹|[1-9])

harf (_|ض|ص|ث|ق|ف|غ|ع|ه|خ|ح|ج|چ|گ|ک|م|ن|ت|ا|ل|ب|ی|س|ش|ظ|ط|ز|ر|ذ|د|پ|و|ژ|آ|ـ)
BOOLEAN_CONSTANT_TRUE (درست)
BOOLEAN_CONSTANT_FALSE (غلط)

PROGRAM_KW (برنامه)
STRUCT_KW (ساختار)
CONST_KW   (ثابت)

INT_KW     (صحیح)
REAL_KW   (اعشاری)
CHAR_KW    (حرف)
BOOL_KW    (منطقی)

IF_KW   (اگر)
THEN_KW (آنگاه)
ELSE_KW (وگرنه)
SWITCH_KW (کلید)
DEFAULT_KW (پیشفرض)
CASE_KW (حالت)
END_KW (تمام)
WHEN_KW (وقتی)
RETURN_KW (برگردان)
BREAK_KW (بشکن)
OR_KW (یا)
AND_KW (و)
XOR_KW (یاوگرنه)
ALSO_KW (وهمچنین)
NOT_KW (خلاف)

GT_KW (>)
LT_KW (<)
LE_KW (<=)
EQ_KW (==)
GE_KW (>=)

PLUS_KW  (\+)
MINUS_KW (-)
MULT_KW (\*)
DIV_KW (\/)
MOD_KW   (%)

AMALGAR_YEGANI_NEG (-)
AMALGAR_YEGANI_STR (\*)
QUEST_MARK (\?)

INC_KW (\+\+)
DEC_KW (--)

ASSIGN_OP    (=)
ASSIGN_PLUS     (\+=)
ASSIGN_MINUS   (-=)
ASSIGN_MULT    (\*=)
ASSIGN_DIV (\/=)

IDENTIFIER {harf}({harf}|{DIGIT})*

JAYEKHALI (\ |\t)*
NOGHTE_VIRGUL (;|؛)
COMMA (,|،)
PARANTES_BAZ   [\(]
PARANTES_BASTE [\)]
AQULAD_BAZ     [\{]
AQULAD_BASTE   [\}]
DOT_PUNC (\.)
DDOT_PUNC (\:)
BRUCKET_BAZ (\[)
BRUCKET_BASTE (\])
COMMENT (\/\/.*)|(\/\*(.|\n)*\*\/)

HARFE_SABET \'{harf}\'
HARFE_SABET_KHAS (\'\\{harf}\'|\'\\0\'|\'\\n\'|\'\\۰\')

INT_NUM [-]?{ZERO}|({NONZERO_DIGIT}{DIGIT}*)
REAL_NUM [-]?({DIGIT}*\.{DIGIT}+|{DIGIT}+)
CHAR_CONSTANT {HARFE_SABET}|{HARFE_SABET_KHAS}
BOOL_CONSTANT {BOOLEAN_CONSTANT_TRUE}|{BOOLEAN_CONSTANT_FALSE}

%%

{COMMENT} {}

{PROGRAM_KW} {return PROGRAM_KW;}
{STRUCT_KW}  {return STRUCT_KW;}
{CONST_KW}   {return CONST_KW;}
{INT_KW}     {return INT_KW;}
{REAL_KW}    {return REAL_KW;}
{CHAR_KW}    {return CHAR_KW;}
{BOOL_KW}    {return BOOL_KW;}
{IF_KW}      {return IF_KW;}
{THEN_KW}    {return THEN_KW;}
{ELSE_KW}    {return ELSE_KW;}
{SWITCH_KW}  {return SWITCH_KW;}
{END_KW}     {return END_KW;}
{DEFAULT_KW} {return DEFAULT_KW;}
{WHEN_KW}    {return WHEN_KW;}
{RETURN_KW}  {return RETURN_KW;}
{BREAK_KW}   {return BREAK_KW;}
{OR_KW}      {return OR_KW;}
{AND_KW}     {return AND_KW;}
{XOR_KW}     {return XOR_KW;}
{ALSO_KW}    {return ALSO_KW;}
{NOT_KW}     {return NOT_KW;}


{BOOL_CONSTANT} {return BOOL_CONSTANT;}
{CHAR_CONSTANT} {return CHAR_CONSTANT;}
{INT_NUM} {return INT_NUM;}
{REAL_NUM} {return REAL_NUM;}

{IDENTIFIER}    {install_id(yytext); return IDENTIFIER;}

{GT_KW} {return GT_KW;}
{LT_KW} {return LT_KW;}
{LE_KW} {return LE_KW;}
{EQ_KW} {return EQ_KW;}
{GE_KW} {return GE_KW;}

{PLUS_KW}  {return PLUS_KW;}
{MINUS_KW} {return MINUS_KW;}
{MULT_KW} {return MULT_KW;}
{DIV_KW} {return DIV_KW;}
{MOD_KW}   {return MOD_KW;}

{QUEST_MARK} {return QUEST_MARK;}

{INC_KW} {return INC_KW;}
{DEC_KW} {return DEC_KW;}

{ASSIGN_OP}    {return '=';}
{ASSIGN_PLUS}     {return ASSIGN_PLUS;}
{ASSIGN_MINUS}   {return ASSIGN_MINUS;}
{ASSIGN_MULT}    {return ASSIGN_MULT;}
{ASSIGN_DIV} {return ASSIGN_DIV;}

{DOT_PUNC}       {return '.';}
{DDOT_PUNC}      {return ':';}
{NOGHTE_VIRGUL} {return ';';}
{COMMA} {return ',';}

{AQULAD_BAZ}     {return '{';}
{AQULAD_BASTE}   {return '}';}
{BRUCKET_BAZ}   {return '[';}
{BRUCKET_BASTE} {return ']';}
{PARANTES_BASTE} {return ')';}
{PARANTES_BAZ}   {return '(';}

[\n] {++yylineno;}

. {}
