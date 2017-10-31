%option noyywrap
%{
#include <stdio.h>
#include <stdlib.h>

FILE *fout;

char symbol_table[100][50];
int counter=0;
int install_id(char* next)
{
}
%}

LETTER [a-zA-Z]
DIGIT [0-9]
PUNCT [(),;:]

PROGRAM_KW (program)
INTEGER_KW (int)
OR_KW "or else"
ASSIGN (:=)
IF_KW (if)

PLUS [+]
MINUS [-]

LT [<]
LE (<=)

BOOL_CONSTANT "true"|"false"
IDENTIFIER {LETTER}+|{LETTER}({LETTER}|{DIGIT})*

%%

{PROGRAM_KW} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "PROGRAM_KW\t-\n");}
{INTEGER_KW} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "INTEGER_KW\t-\n");}
{OR_KW} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "LOGIC_OP_KW\tOR\n");}
{ASSIGN} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "ASSIGN_KW\t-\n");}
{IF_KW} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "IF_KW\t-\n");}

{PLUS} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "MATH_OP_KW\tPLUS\n");}
{MINUS} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "MATH_OP_KW\tMINUS\n");}

{LT} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "REL_OP_KW\tLT\n");}
{LE} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "REL_OP_KW\tLE\n");}

{BOOL_CONSTANT} {fprintf(fout, "\t%s\t", yytext);fprintf(fout, "BOOL_CONSTANT\t");fprintf(fout, "%s\n", yytext);}

{IDENTIFIER} {fprintf(fout, "\t%s\t", yytext);fprintf(fout, "IDENTIFIER\t");fprintf(fout, "%d\n", install_id(yytext));}

. {}

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
    return 0;
}
