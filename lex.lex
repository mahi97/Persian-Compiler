%option noyywrap

%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char symbolTable[100][50];
FILE *fout;
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
PARANTES_BAZ   [\(]
PARANTES_BASTE [\)]
AQULAD_BAZ     [\{]
AQULAD_BASTE   [\}]
DOT_PUNC (\.)
DDOT_PUNC (\:)
BRUCKET_BAZ (\[)
BRUCKET_BASTE (\])
COMMENT (\/\/.*)|(\/\*(.|\n)*\*\/)

%%

{barname_KW} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "barname_KW\t-\n");   }
{sakhtar_KW} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "sakhtar_KW\t-\n");   }
{sabet_KW}   {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "sabet_KW\t-\n");     }
{INT_KW}     {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "TYPE_KW\tint\n");    }
{FLOAT_KW}   {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "TYPE_KW\tfloat\n");  }
{CHAR_KW}    {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "TYPE_KW\tchar\n");   }
{BOOL_KW}    {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "TYPE_KW\tbool\n");   }
{IF_KW}      {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "IF_KW\t-\n");        }
{THEN_KW}    {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "THEN_KW\t-\n");      }
{ELSE_KW}    {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "ELSE_KW\t-\n");      }
{SWITCH_KW}  {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "SWITCH_KW\t-\n");    }
{DEFAULT_KW} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "DEFAULT_KW\t-\n");   }
{WHEN_KW}    {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "WHEN_KW\t-\n");      }
{RETURN_KW}  {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "RETURN_KW\t-\n");    }
{BREAK_KW}   {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "BREAK_KW\t-\n");     }
{OR_KW}      {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "LOGIC_OP\tOR\n");    }
{AND_KW}     {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "LOGIC_OP\tAND\n");   }
{XOR_KW}     {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "LOGIC_OP\tXOR\n");   }
{ALSO_KW}    {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "LOGIC_OP\tALSO\n");  }
{NOT_KW}     {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "LOGIC_OP\tNOT\n");   }

{BOOLEAN_CONSTANT_TRUE} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "BOOL_CONSTANT\t%s\n", "true");  }
{BOOLEAN_CONSTANT_FALSE} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "BOOL_CONSTANT\t%s\n", "false");}
{HARFE_SABET} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "CHAR_CONSTANT\t%s\n", yytext);}

{SHENASE}    {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "ID\t%d\n", install_id(yytext));}
{ADAD} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "NUM\t-\n");}
{COMMENT} {}

{AMALGAR_RABTI_GT} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "RELATIVE_OP\t%s\n", "GT"); }
{AMALGAR_RABTI_LT} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "RELATIVE_OP\t%s\n", "LT"); }
{AMALGAR_RABTI_LE} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "RELATIVE_OP\t%s\n", "LE"); }
{AMALGAR_RABTI_EQ} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "RELATIVE_OP\t%s\n", "EQ"); }
{AMALGAR_RABTI_GE} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "RELATIVE_OP\t%s\n", "GE"); }
{AMALGAR_RABTI_NE} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "RELATIVE_OP\t%s\n", "NE"); }

{AMALGAR_RIAZI_PLUS}  {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "MATH_OP\t%s\n", "plus");     }
{AMALGAR_RIAZI_MINUS} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "MATH_OP\t%s\n", "minus");    }
{AMALGAR_RIAZI_MULTP} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "MATH_OP\t%s\n", "multiply"); }
{AMALGAR_RIAZI_DIVID} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "MATH_OP\t%s\n", "divide");   }
{AMALGAR_RIAZI_MOD} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "MATH_OP\t%s\n", "mod");        }

{AMALGAR_YEGANI_NEG} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "UNARY_OP\t%s\n", "negetive"); }
{AMALGAR_YEGANI_STR} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "UNARY_OP\t%s\n", "star");     }
{AMALGAR_YEGANI_QTM} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "UNARY_OP\t%s\n", "question"); }

{AMALGAR_INC} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "C_OP\t%s\n", "PP"); }
{AMALGAR_DEC} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "C_OP\t%s\n", "MM"); }

{AMALGAR_MEGDARDEHI_SADE}    {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "ASSIGN_OP\t%s\n", "normal");   }
{AMALGAR_MEGDARDEHI_JAM}     {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "ASSIGN_OP\t%s\n", "plus");     }
{AMALGAR_MEGDARDEHI_MENHA}   {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "ASSIGN_OP\t%s\n", "minus");    }
{AMALGAR_MEGDARDEHI_ZARB}    {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "ASSIGN_OP\t%s\n", "multiply"); }
{AMALGAR_MEGDARDEHI_TAGHSIM} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "ASSIGN_OP\t%s\n", "divide");   }


{JAYEKHALI} {}

{NOGHTE_VIRGUL} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "PUNC\tsemi-colon\n");}
{COMMA} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "PUNC\tcomma\n");}
{PARANTES_BAZ}   {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "PARANTES_OPEN\t-\n");}
{PARANTES_BASTE} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "PARANTES_CLOSE\t-\n");}
{AQULAD_BAZ}     {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "BRACE_OPEN\t-\n");}
{AQULAD_BASTE}   {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "BRACE_CLOSE\t-\n");}
{DOT_PUNC}       {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "DOT_PUNC\t-\n");}
{DDOT_PUNC}      {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "DDOT_PUNC\t-\n");}

{BRUCKET_BAZ}   {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "BRUCKET_OPEN\t-\n");}
{BRUCKET_BASTE} {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "BRUCKET_CLOSE\t-\n");}

. {fprintf(fout, "\t%s\t", yytext); fprintf(fout, "WRONG\t-\n");wrong++;}

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
	printf("There were %d wrong stuff \n", wrong);
	return 0;
}
