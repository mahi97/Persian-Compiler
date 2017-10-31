%option noyywrap

%{

#include <stdio.h>
#include <stdlib.h>

FILE *fout;
int charcount=0, linecount=0, wordcount=0, commentcount=0, whitespace=0, wrong=0;
int install_id(char* next) {return 0;}

%}

ragham (۰|۱|۲|۳|۴|۵|۶|۷|۸|۹|[0-9])
harf (ض|ص|ث|ق|ف|غ|ع|ه|خ|ح|ج|چ|گ|ک|م|ن|ت|ا|ل|ب|ی|س|ش|ظ|ط|ز|ر|ذ|د|پ|و|ژ|آ|ـ)
BOOLEAN_CONSTANT_TRUE (درست)
BOOLEAN_CONSTANT_FALSE (غلط)

barname_KW (برنامه)
sakhtar_KW (ساختار)
sabet_KW   (ثابت)

INT_KW     (صحیح)
FLOAT_KW   (اعشاری)
CHAR_KW    (حرف)
BOOL_KW    (منطقی)

IF_KW   (اگر)
THEN_KW (آنگاه)
ELSE_KW (وگرنه)
SWITCH_KW (کلید)
DEFAULT_KW (پیشفرض)
WHEN_KW (وقتی)
RETURN_KW (برگرد)
BREAK_KW (بشکن)
OR_KW (یا)
AND_KW (و)
XOR_KW (یاوگرنه)
ALSO_KW (وهمچنین)
NOT_KW (خلاف)

AMALGAR_RABTI_GT (>)
AMALGAR_RABTI_LT (<)
AMALGAR_RABTI_LE (<=)
AMALGAR_RABTI_EQ (==)
AMALGAR_RABTI_GE (>=)
AMALGAR_RABTI_NE (!=)

AMALGAR_RIAZI_PLUS  (\+)
AMALGAR_RIAZI_MINUS (-)
AMALGAR_RIAZI_MULTP (\*)
AMALGAR_RIAZI_DIVID (\/)
AMALGAR_RIAZI_MOD   (%)

AMALGAR_YEGANI_NEG (-)
AMALGAR_YEGANI_STR (\*)
AMALGAR_YEGANI_QTM (\?)

AMALGAR_INC (\+\+)
AMALGAR_DEC (--)

AMALGAR_MEGDARDEHI_SADE    (=)
AMALGAR_MEGDARDEHI_JAM     (\+=)
AMALGAR_MEGDARDEHI_MENHA   (-=)
AMALGAR_MEGDARDEHI_ZARB    (\*=)
AMALGAR_MEGDARDEHI_TAGHSIM (\/=)




SHENASE {harf}({harf}|{ragham})*
ADAD {ragham}+
HARFE_SABET \'{harf}\'
JAYEKHALI (\ |\t)*
NOGHTE_VIRGUL (;|؛)
COMMA (,|،)
PUNCT [\(\)\{\}\.]
COMMENT (\/\/.*)|(\/\*(.|\n)*\*\/)

%%

{barname_KW} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "barname_KW\t-\n"); wordcount++;}
{sakhtar_KW}    {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "sakhtar_KW\t-\n"); wordcount++;}
{sabet_KW}      {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "sabet_KW\t-\n");   wordcount++;}
{INT_KW}     {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "TYPE_KW\tint\n");      wordcount++;}
{FLOAT_KW}   {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "TYPE_KW\tfloat\n");      wordcount++;}
{CHAR_KW}    {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "TYPE_KW\tchar\n");      wordcount++;}
{BOOL_KW}    {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "TYPE_KW\tbool\n");      wordcount++;}
{IF_KW}      {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "IF_KW\t-\n");         wordcount++;}
{THEN_KW}    {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "THEN_KW\t-\n");         wordcount++;}
{ELSE_KW}    {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "ELSE_KW\t-\n");         wordcount++;}
{SWITCH_KW}  {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "SWITCH_KW\t-\n");         wordcount++;}
{DEFAULT_KW} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "DEFAULT_KW\t-\n");         wordcount++;}
{WHEN_KW}    {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "WHEN_KW\t-\n");         wordcount++;}
{RETURN_KW}  {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "RETURN_KW\t-\n");         wordcount++;}
{BREAK_KW}   {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "BREAK_KW\t-\n");         wordcount++;}
{OR_KW}      {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "LOGIC_OP\tOR\n");         wordcount++;}
{AND_KW}     {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "LOGIC_OP\tAND\n");         wordcount++;}
{XOR_KW}     {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "LOGIC_OP\tXOR\n");         wordcount++;}
{ALSO_KW}    {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "LOGIC_OP\tALSO\n");         wordcount++;}
{NOT_KW}     {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "LOGIC_OP\tNOT\n");         wordcount++;}

{BOOLEAN_CONSTANT_TRUE} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "BOOL_CONSTANT\t%s\n", "true");         wordcount++;}
{BOOLEAN_CONSTANT_FALSE} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "BOOL_CONSTANT\t%s\n", "false");         wordcount++;}
{HARFE_SABET} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "CHAR_CONSTANT\t%s\n", yytext);}

{SHENASE}    {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "ID\t%d\n", install_id(yytext));         wordcount++;}
{ADAD} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "NUM\t-\n");}
{COMMENT} commentcount++;

{AMALGAR_RABTI_GT} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "RELATIVE_OP\t%s\n", "GT");         wordcount++;}
{AMALGAR_RABTI_LT} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "RELATIVE_OP\t%s\n", "LT");         wordcount++;}
{AMALGAR_RABTI_LE} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "RELATIVE_OP\t%s\n", "LE");         wordcount++;}
{AMALGAR_RABTI_EQ} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "RELATIVE_OP\t%s\n", "EQ");         wordcount++;}
{AMALGAR_RABTI_GE} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "RELATIVE_OP\t%s\n", "GE");         wordcount++;}
{AMALGAR_RABTI_NE} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "RELATIVE_OP\t%s\n", "NE");         wordcount++;}

{AMALGAR_RIAZI_PLUS}  {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "MATH_OP\t%s\n", "plus");         wordcount++;}
{AMALGAR_RIAZI_MINUS} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "MATH_OP\t%s\n", "minus");         wordcount++;}
{AMALGAR_RIAZI_MULTP} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "MATH_OP\t%s\n", "multiply");         wordcount++;}
{AMALGAR_RIAZI_DIVID} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "MATH_OP\t%s\n", "divide");         wordcount++;}
{AMALGAR_RIAZI_MOD} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "MATH_OP\t%s\n", "mod");         wordcount++;}

{AMALGAR_YEGANI_NEG} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "UNARY_OP\t%s\n", "negetive");         wordcount++;}
{AMALGAR_YEGANI_STR} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "UNARY_OP\t%s\n", "star");         wordcount++;}
{AMALGAR_YEGANI_QTM} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "UNARY_OP\t%s\n", "question");         wordcount++;}

{AMALGAR_INC} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "C_OP\t%s\n", "PP");         wordcount++;}
{AMALGAR_DEC} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "C_OP\t%s\n", "MM");         wordcount++;}

{AMALGAR_MEGDARDEHI_SADE}    {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "ASSIGN_OP\t%s\n", "normal");         wordcount++;}
{AMALGAR_MEGDARDEHI_JAM}     {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "ASSIGN_OP\t%s\n", "plus");         wordcount++;}
{AMALGAR_MEGDARDEHI_MENHA}   {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "ASSIGN_OP\t%s\n", "minus");         wordcount++;}
{AMALGAR_MEGDARDEHI_ZARB}    {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "ASSIGN_OP\t%s\n", "multiply");         wordcount++;}
{AMALGAR_MEGDARDEHI_TAGHSIM} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "ASSIGN_OP\t%s\n", "divide");         wordcount++;}


{JAYEKHALI} whitespace++;

{NOGHTE_VIRGUL} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "PUNC\tsemi-colon\n");}
{COMMA} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "PUNC\tcomma\n");}
{PUNCT} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "PUNC\t%s\n", yytext);}

. {{fprintf(fout, "\t%s\t", yytext); fprintf(fout, "WRONG\t-\n");}}

%%

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {

	yyin = fopen("input.txt", "r");
	fout = fopen("output.txt", "w");
	fprintf(fout, "\n LEXER \n");
	fprintf(fout, "\tRegEx\tToken\tAttVal\n\n");
    if(yyin) {
      	yylex();
		fclose(yyin);
	}
        fclose(fout);
	printf("There were %d chars \n \
	 in %d line \n \
	 and %d persian harf\n \
	 %d whitespace \n \
	 %d wrong stuff \n",
	 charcount,
	 linecount,
	 wordcount,
	 whitespace,
	 wrong);
	return 0;
}
