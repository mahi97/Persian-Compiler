%option noyywrap

%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <math.h>
#include "parser.tab.h"

char* lexID;
int lexNum;
double lexReal;
char* lexChar;
bool lexBool;

double toReal(char* real_num) {
	int i = 0;
	int count = 0,count2 = 0;
	int res[50];
	bool intPart = true;

	int n1 = real_num[i];
	int n2 = real_num[i+1];

	while((n1 == 37 && n2 == -80) || real_num[i] == '0') {
		i++;
		n1 = real_num[i];
		n2 = real_num[i+1];
	}

	while(real_num[i] != '\0') {
		if (real_num[i] == '.') {
			intPart = false;
			i++;
			continue;
		}
		if (intPart) {
			int num = real_num[i];
			if (num >= 0 && num <= 255) {
				res[count] = real_num[i] - '0';
				count++;
			} else {
				if (num != -37) {
					res[count] = num + 80;
					count++;
				}
			}
		} else {
			int num = real_num[i];
			if (num >= 0 && num <= 255) {
				res[count+count2] = real_num[i] - '0';
				count2++;
			} else {
				if (num != -37) {
					res[count+count2] = num + 80;
					count2++;
				}
			}
		}
		i++;

	}
	double r = 0;
	for (int j = 0; j < count; j++) {
		r += res[j] * pow(10,count-j-1);
	}
	for (int j = 0; j < count2; j++) {
		r += res[count + j] * pow(0.1,j+1);
	}
	return r;
}

int toNum(char* int_num) {
	int i = 0;
	int count = 0;
	int res[50];

	int n1 = int_num[i];
	int n2 = int_num[i+1];

	while((n1 == 37 && n2 == -80) || int_num[i] == '0') {
		i++;
		n1 = int_num[i];
		n2 = int_num[i+1];
	}

	while(int_num[i] != '\0') {
		int num = int_num[i];
		if (num >= 0 && num <= 255) {
			res[count] = int_num[i] - '0';
			count++;
		} else {
			if (num != -37) {
				res[count] = num + 80;
				count++;
			}
		}
		i++;
	}
	int r = 0;
	for (int j = 0; j < count; j++) {
		r += res[j]*pow(10,count-j-1);
	}
	return r;
}

char* toChar(char* harf) {
	char* result;
	if (strcmp(harf, "\'\\n\'") == 0) {
		return harf;
	} else if ( strcmp(harf, "\'\\0\'") == 0 || strcmp(harf, "\'\\۰\'") == 0 ) {
		return "\'\\0\'";
	} else {
		int idxToDel = 1;
		if (harf[0] == '\'')
		memmove(&harf[idxToDel], &harf[idxToDel + 1], strlen(harf) - idxToDel);
		result = harf;
	}
	int type = -1;
	int cnt = 0;
	char* result2 = new char[100];
	for (int i = 0; i < strlen(result); i++) {
		int r = result[i];
		if (r > 0 && r < 256) {
			result2[cnt++] = r;
			continue;
		}
		else if (r == -37) {
			type = 0;
			continue;
		} else if (r == -38) {
			type = 1;
			continue;
		} else if (r == -39) {
			type = 2;
			continue;
		} else if (r == -40) {
			type = 3;
			continue;
		} 
		else {
			switch(type) {
				case 0:
				if (r >= -80) r += 80; // handle numbers
				else r += 193;
				break;
				case 1:
				r += 193;
				break;
				case 2:
				if (r == -66) r += 161; // handle pe :D
				else r += 193;
				break;
				case 3:
				r += 191;
				break;
			}
		}	
		result2[cnt++] = r;
	}
	result2[cnt] = '\0';
	return result2;
}



%}

ZERO (0|۰)
DIGIT (۰|۱|۲|۳|۴|۵|۶|۷|۸|۹|[0-9])
NONZERO_DIGIT (۱|۲|۳|۴|۵|۶|۷|۸|۹|[1-9])
UNDER (ـ)
harf (ض|ص|ث|ق|ف|غ|ع|ه|خ|ح|ج|چ|گ|ک|م|ن|ت|ا|ل|ب|ی|س|ش|ظ|ط|ز|ر|ذ|د|پ|و|ژ|آ|{UNDER})
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
QUEST_MARK (\?|؟)

INC_KW (\+\+)
DEC_KW (--)

ASSIGN_OP    (=)
ASSIGN_PLUS     (\+=)
ASSIGN_MINUS   (-=)
ASSIGN_MULT    (\*=)
ASSIGN_DIV (\/=)


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

IDENTIFIER {harf}({harf}|{DIGIT})*

HARFE_SABET \'{harf}\'
HARFE_SABET_KHAS (\'\\{harf}\'|\'\\0\'|\'\\n\'|\'\\۰\')

INT_NUM [-]?{ZERO}|({NONZERO_DIGIT}{DIGIT}*)
REAL_NUM [-]?({DIGIT}*\.{DIGIT}+|{DIGIT}+)
CHAR_CONSTANT {HARFE_SABET}|{HARFE_SABET_KHAS}

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
{CASE_KW}    {return CASE_KW;}
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


{BOOLEAN_CONSTANT_TRUE} {return BOOL_CONSTANT_TRUE;}
{BOOLEAN_CONSTANT_FALSE} {return BOOL_CONSTANT_FALSE;}
{CHAR_CONSTANT} {lexChar = toChar(yytext); return CHAR_CONSTANT;}
{INT_NUM} {lexNum = toNum(yytext); return INT_NUM;}
{REAL_NUM} {lexReal = toReal(yytext); return REAL_NUM;}

{IDENTIFIER}    {lexID = new char[strlen(yytext)];
				 strcpy(lexID,toChar(yytext));
				 return IDENTIFIER;
				}

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
