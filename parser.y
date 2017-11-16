%{

#include <stdio.h>

// stuff from flex that bison needs to know about:
//extern "C" int yylex();
//extern "C" int yyparse();
extern FILE *yyin;
extern int yylineno;
extern char* yytext;

voIDENTIFIER yyerror(const char *s);

FILE *fout;
%}
// Bison fundamentally works by asking flex to get the next token, which it
// returns as an object of type "yystype".  But tokens could be of any
// arbitrary data type!  So we deal with that in Bison by defining a C union
// holding each of the types of tokens that Flex could return, and have Bison
// use that union instead of "int" for the definition of "yystype":
%union {
	int ival;
	float rval;
	_Bool bval;
	char* IDENTIFIER;
  char cval;
}

// define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the union:



%token PROGRAM_KW STRUCT_KW CONST_KW INT_KW REAL_KW CHAR_KW BOOL_KW IF_KW THEN_KW ELSE_KW SWITCH_KW DEFAULT_KW WHEN_KW RETURN_KW BREAK_KW OR_KW AND_KW XOR_KW ALSO_KW NOT_KW GT_KW LT_KW LE_KW EQ_KW GE_KW NE_KW PLUS_KW MINUS_KW MULT_KW DIV_KW MOD_KW QUEST_MARK ASSIGN_PLUS ASSIGN_MINUS ASSIGN_MULT ASSIGN_DIV INC_KW DEC_KW CASE_KW END_KW
%token <ival> INT_NUM
%token <rval> REAL_NUM
%token <bval> BOOL_CONSTANT
%token <IDENTIFIER> IDENTIFIER
%token <cval> CHAR_CONSTANT

%left AND_KW OR_KW
%left XOR_KW ALSO_KW
%right '='
%left EQ_KW
%left LT_KW GT_KW
%left LE_KW GE_KW
%left MULT_KW DIV_KW
%left PLUS_KW MINUS_KW

%right NOT_KW
%left THEN_KW
%left ELSE_KW

%%

// this is the actual grammar that bison will parse, but for right now it's just
// something silly to echo to the screen what bison gets from flex.  We'll
// make a real one shortly:

barname : PROGRAM_KW IDENTIFIER declist
	{
		fprintf(fout, "Rule 1 \t\t program -> PROGRAM_KW IDENTIFIER declist \n") ;
	};

declist : declist dec
	{
		fprintf(fout, "Rule 2.1 \t\t declist -> declist dec \n") ;
	};
	|  dec
	{
		fprintf(fout, "Rule 2.2 \t\t declist -> dec \n") ;
	};

dec : structdec
	{
		fprintf(fout, "Rule 3.1 \t\t dec -> structdec \n") ;
	};
	|	 vardec
	{
		fprintf(fout, "Rule 3.2 \t\t dec -> vardec \n") ;
	};
	| funcdec
	{
		fprintf(fout, "Rule 3.3 \t\t dec -> funcdec \n") ;
	};

structdec : STRUCT_KW IDENTIFIER '{' localdec '}'
  {
    fprintf(fout, "Rule 4 \t\t structdec -> STRUCT_KW IDENTIFIER { localdec } \n");
  };

localdec : localdec limitedvardec
  {
    fprintf(fout, "Rule 5.1 \t\t localdec -> localdec limitedvardec \n");
  };
  | /* empty */
  {
    fprintf(fout, "Rule 5.2 \t\t localdec -> e \n");
  };

limitedvardec : limitedvartype varsdecs ';'
  {
    fprintf(fout, "Rule 6 \t\t limitedvardec -> limitedvartype varsdecs ; \n");
  };

limitedvartype : CONST_KW type
  {
    fprintf(fout, "Rule 7.1 \t\t limitedvartype -> CONST_KW type \n");
  };
  | type
  {
    fprintf(fout, "Rule 7.2 \t\t limitedvartype -> type \n");
  };

type : INT_KW
  {
    fprintf(fout, "Rule 8.1 \t\t type -> INT_KW \n");
  };
  | REAL_KW
  {
    fprintf(fout, "Rule8.2 \t\t type : REAL_KW \n");
  };
  | CHAR_KW
  {
    fprintf(fout, "Rule 8.3 \t\t type : CHAR_KW \n");
  };
  | BOOL_KW
  {
    fprintf(fout, "Rule 8.4 \t\t type : BOOL_KW \n");
  };

vardec : type varsdecs ';'
  {
    fprintf(fout, "Rule 9 \t\t vardec -> type varsdecs ;\n");
  };

varsdecs : primiryvardec
  {
    fprintf(fout, "Rule 10.1 \t\t varsdecs -> primiryvardec \n");
  };
  | varsdecs ',' primiryvardec
  {
    fprintf(fout, "Rule 10.1 \t\t varsdecs -> varsdecs , primiryvardec \n");
  };

primiryvardec : varIDENTIFIERdec
  {
    fprintf(fout, "Rule 11.1 \t\t primiryvardec -> varIDENTIFIERdec \n");
  };
  | varIDENTIFIERdec '=' simpleexp
  {
    fprintf(fout, "Rule 11.2 \t\t primiryvardec -> varIDENTIFIERdec = simpleexp \n");
  };

varIDENTIFIERdec : IDENTIFIER
  {
    fprintf(fout, "Rule 6 \t\t varIDENTIFIERdec -> IDENTIFIER \n");
  };
  | IDENTIFIER '[' INT_NUM ']'
  {
    fprintf(fout, "Rule 6 \t\t varIDENTIFIERdec -> IDENTIFIER [ INT_NUM ] \n");
  };

funcdec : type IDENTIFIER '(' arg ')' sentence
  {
    fprintf(fout, "Rule 6 \t\t funcdec -> type IDENTIFIER ( arg ) sentence \n");
  };
  | IDENTIFIER '(' arg ')' sentence
  {
    fprintf(fout, "Rule 6 \t\t funcdec -> IDENTIFIER ( arg ) sentence \n");
  };

arg : args
  {
    fprintf(fout, "Rule 6 \t\t arg -> args \n");
  };
  | /* empty */
  {
    fprintf(fout, "Rule 6 \t\t arg : e \n");
  };

args : args ';' argstype
  {
    fprintf(fout, "Rule 6 \t\t args -> args ; argstype \n");
  };
  | argstype
  {
    fprintf(fout, "Rule 6 \t\t args -> argstype \n");
  };

argstype : type argsIDENTIFIER
  {
    fprintf(fout, "Rule 6 \t\t argstype -> type argsIDENTIFIER \n");
  };

argsIDENTIFIER : argsIDENTIFIER ',' argIDENTIFIER
  {
    fprintf(fout, "Rule 6 \t\t argsIDENTIFIER -> argsIDENTIFIER , argIDENTIFIER \n");
  };
  | argIDENTIFIER
  {
    fprintf(fout, "Rule 6 \t\t argsIDENTIFIER -> argIDENTIFIER \n");
  };

argIDENTIFIER : IDENTIFIER
  {
    fprintf(fout, "Rule 6 \t\t argIDENTIFIER -> IDENTIFIER \n");
  };
  | IDENTIFIER '[' ']'
  {
    fprintf(fout, "Rule 6 \t\t argIDENTIFIER : IDENTIFIER [ ] \n");
  };

sentence : compSent
  {
    fprintf(fout, "Rule 6 \t\t sentence -> compSent \n");
  };
  | exprSent
  {
    fprintf(fout, "Rule 6 \t\t sentence -> exprSent \n");
  };
  | selectSent
  {
    fprintf(fout, "Rule 6 \t\t sentence -> selectSent \n");
  };
  | repeatSent
  {
    fprintf(fout, "Rule 6 \t\t sentence -> repeatSent \n");
  };
  | returnSent
  {
    fprintf(fout, "Rule 6 \t\t sentence -> returnSent \n");
  };
  | breakSent
  {
    fprintf(fout, "Rule 6 \t\t sentence -> breakSent \n");
  };

compSent : '{' localdec sentences '}'
  {
    fprintf(fout, "Rule 6 \t\t compSent -> { localdec sentences } \n");
  };

sentences : sentences sentence
  {
    fprintf(fout, "Rule 6 \t\t sentences -> sentences sentence \n");
  };
  | /* empty */
  {
    fprintf(fout, "Rule 6 \t\t sentences -> e \n");
  };

exprSent : expr ';'
  {
    fprintf(fout, "Rule 6 \t\t exprSent -> expr ; \n");
  };
  | ';'
  {
    fprintf(fout, "Rule 6 \t\t exprSent -> ; \n");
  };

selectSent : IF_KW simpleexp THEN_KW sentence
  {
    fprintf(fout, "Rule 6 \t\t selectSent -> IF_KW simpleexp THEN_KW sentence \n");
  };
  | IF_KW simpleexp THEN_KW sentence ELSE_KW sentence
  {
    fprintf(fout, "Rule 6 \t\t selectSent -> IF_KW simpleexp THEN_KW sentence ELSE_KW sentence \n");
  };
  | SWITCH_KW '(' simpleexp ')' caseelement defaultelement END_KW
  {
    fprintf(fout, "Rule 6 \t\t selectSent -> SWITCH_KW '(' simpleexp ')' caseelement defaultelement END_KW \n");
  };

caseelement : CASE_KW INT_NUM ':' sentence ';'
  {
    fprintf(fout, "Rule 6 \t\t caseelement -> CASE_KW INT_NUM : sentence ; \n");
  };
  | caseelement CASE_KW INT_NUM ':' sentence ';'
  {
    fprintf(fout, "Rule 6 \t\t caseelement -> caseelement CASE_KW INT_NUM : sentence ; \n");
  };

defaultelement : DEFAULT_KW ':' sentence ';'
  {
    fprintf(fout, "Rule 6 \t\t defaultelement -> DEFAULT_KW : sentence ; \n");
  };
  | /* empty */
  {
    fprintf(fout, "Rule 6 \t\t defaultelement -> e \n");
  };

repeatSent : WHEN_KW '(' simpleexp ')' sentence
  {
    fprintf(fout, "Rule 6 \t\t repeatSent -> WHEN_KW '(' simpleexp ')' sentence \n");
  };

returnSent : RETURN_KW ';'
  {
    fprintf(fout, "Rule 6 \t\t returnSent -> RETURN_KW ; \n");
  };

breakSent : BREAK_KW ';'
  {
    fprintf(fout, "Rule 6 \t\t breakSent -> BREAK_KW ; \n");
  };

expr : variable '=' expr
  {
    fprintf(fout, "Rule 6 \t\t expr -> variable = expr \n");
  };
  | variable ASSIGN_PLUS expr
  {
    fprintf(fout, "Rule 6 \t\t expr -> variable += expr \n");
  };
  | variable ASSIGN_MINUS expr
  {
    fprintf(fout, "Rule 6 \t\t expr -> variable -= expr \n");
  };
  | variable ASSIGN_MULT expr
  {
    fprintf(fout, "Rule 6 \t\t expr -> variable *= expr \n");
  };
  | variable ASSIGN_DIV expr
  {
    fprintf(fout, "Rule 6 \t\t expr -> variable /= expr \n");
  };
  | variable INC_KW
  {
    fprintf(fout, "Rule 6 \t\t expr -> variable ++ \n");
  };
  | variable DEC_KW expr
  {
    fprintf(fout, "Rule 6 \t\t expr -> variable -- \n");
  };
  | simpleexp
  {
    fprintf(fout, "Rule 6 \t\t expr -> simpleexp \n");
  };

simpleexp : simpleexp OR_KW simpleexp
  {
    fprintf(fout, "Rule 6 \t\t simpleexp -> simpleexp OR simpleexp \n");
  };
  | simpleexp AND_KW simpleexp
  {
    fprintf(fout, "Rule 6 \t\t simpleexp -> simpleexp AND simpleexp \n");
  };
  | simpleexp XOR_KW simpleexp
  {
    fprintf(fout, "Rule 6 \t\t simpleexp -> simpleexp XOR simpleexp \n");
  };
  | simpleexp ALSO_KW simpleexp
  {
    fprintf(fout, "Rule 6 \t\t simpleexp -> simpleexp ALSO simpleexp \n");
  };
  | NOT_KW simpleexp
  {
    fprintf(fout, "Rule 6 \t\t simpleexp -> NOT simpleexp \n");
  };
  | relativeexp
  {
    fprintf(fout, "Rule 6 \t\t simpleexp -> relativeexp \n");
  };

relativeexp : arthlogicexpr
  {
    fprintf(fout, "Rule 6 \t\t relativeexp -> arthlogicexpr \n");
  };
  | arthlogicexpr relativeop arthlogicexpr
  {
    fprintf(fout, "Rule 6 \t\t relativeexp -> arthlogicexpr relativeop arthlogicexpr \n");
  };

relativeop : LT_KW
  {
    fprintf(fout, "Rule 6 \t\t relativeop -> < \n");
  };
  | LE_KW
  {
    fprintf(fout, "Rule 6 \t\t relativeop -> <= \n");
  };
  | EQ_KW
  {
    fprintf(fout, "Rule 6 \t\t relativeop -> == \n");
  };
  | GE_KW
  {
    fprintf(fout, "Rule 6 \t\t relativeop -> >= \n");
  };
  | GT_KW
  {
    fprintf(fout, "Rule 6 \t\t relativeop -> > \n");
  };

arthlogicexpr : unaryexpr
  {
    fprintf(fout, "Rule 6 \t\t arthlogicexpr -> unaryexpr \n");
  };
  | arthlogicexpr arthop arthlogicexpr
  {
    fprintf(fout, "Rule 6 \t\t arthlogicexpr -> arthlogicexpr arthop arthlogicexpr \n");
  };

arthop : PLUS_KW
  {
    fprintf(fout, "Rule 6 \t\t arthop -> + \n");
  };
  | MINUS_KW
  {
    fprintf(fout, "Rule 6 \t\t arthop -> -  \n");
  };
  | MULT_KW
  {
    fprintf(fout, "Rule 6 \t\t arthop -> *  \n");
  };
  | DIV_KW
  {
    fprintf(fout, "Rule 6 \t\t arthop -> /  \n");
  };
  | MOD_KW
  {
    fprintf(fout, "Rule 6 \t\t arthop -> MOD_KW  \n");
  };

unaryexpr :  unaryop unaryexpr
  {
    fprintf(fout, "Rule 6 \t\t unaryexpr ->  unaryop unaryexpr \n");
  };
  | opera
  {
    fprintf(fout, "Rule 6 \t\t unaryexpr ->  opera \n");
  };

unaryop : MINUS_KW
  {
    fprintf(fout, "Rule 6 \t\t unaryop -> - \n");
  };
  | MULT_KW
  {
    fprintf(fout, "Rule 6 \t\t unaryop -> * \n");
  };
  | QUEST_MARK
  {
    fprintf(fout, "Rule 6 \t\t unaryop -> ? \n");
  };

opera : variable
  {
    fprintf(fout, "Rule 6 \t\t opera -> variable \n");
  };
  | unvar
  {
    fprintf(fout, "Rule 6 \t\t opera -> unvar \n");
  };

variable : IDENTIFIER
  {
    fprintf(fout, "Rule 6 \t\t variable : IDENTIFIER \n");
  };
  | variable '[' expr ']'
  {
    fprintf(fout, "Rule 6 \t\t variable -> variable [ expr ] \n");
  };
  | variable '.' IDENTIFIER
  {
    fprintf(fout, "Rule 6 \t\t variable : variable . IDENTIFIER \n");
  };

unvar : '(' expr ')'
  {
    fprintf(fout, "Rule 6 \t\t unvar -> ( expr ) \n");
  };
  | call
  {
    fprintf(fout, "Rule 6 \t\t unvar -> call \n");
  };
  | constant
  {
    fprintf(fout, "Rule 6 \t\t unvar : constant \n");
  };

call : IDENTIFIER '(' argVector ')'
  {
    fprintf(fout, "Rule 6 \t\t call -> IDENTIFIER '(' argVector ')' \n");
  };

argVector : argsVector
  {
    fprintf(fout, "Rule 6 \t\t argVector -> argsVector \n");
  };
  | /* empty */
  {
    fprintf(fout, "Rule 6 \t\t argVector -> e \n");
  };

argsVector : argsVector ',' expr
  {
    fprintf(fout, "Rule 6 \t\t argsVector -> argsVector , expr \n");
  };
  | expr
  {
    fprintf(fout, "Rule 6 \t\t argsVector -> expr \n");
  };

constant : INT_NUM
  {
    fprintf(fout, "Rule 6 \t\t constant : INT_NUM \n");
  };
  | REAL_NUM
  {
    fprintf(fout, "Rule 6 \t\t constant : REAL_NUM \n");
  };
  | CHAR_CONSTANT
  {
    fprintf(fout, "Rule 6 \t\t constant : CHAR_CONSTANT \n");
  };
  | BOOL_CONSTANT
  {
    fprintf(fout, "Rule 6 \t\t constant : BOOLEAN_CONSTANT \n");
  };

%%

int main() {
	// open a file handle to a particular file:
	yyin = fopen("input.txt", "r");

	fout = fopen("output.txt", "w");
	fprintf(fout, "\n \t \t \t PARSER \n");
	fprintf(fout, "Rule No. --> Rule Description \n");

	if (fout == NULL)
	{
		printf("Error opening file!\n");
		//exit(1);
	}
	// make sure it is valIDENTIFIER:
	else if (!yyin) {
		printf("Error opening file!\n");
		//exit(1);
	}
	// set flex to read from it instead of defaulting to STDIN:

	// parse through the input until there is no more:
	else
		yyparse();
}

voIDENTIFIER yyerror(const char *s) {
	fprintf(fout, "**Error: Line %d near token '%s' --> Message: %s **\n", yylineno,yytext ,s);
	printf("**Error: Line %d near token '%s' --> Message: %s **\n", yylineno,yytext, s);
	// might as well halt now:
	//exit(-1);
}
