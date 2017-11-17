%{

#include <stdio.h>

// stuff from flex that bison needs to know about:
//extern "C" int yylex();
//extern "C" int yyparse();
extern FILE *yyin;
extern int yylineno;
extern char* yytext;

void yyerror(const char *s);

FILE *fout;
%}

%union {
	int ival;
	float rval;
	_Bool bval;
	char* id;
  char cval;
}

// define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the union:



%token PROGRAM_KW STRUCT_KW CONST_KW INT_KW REAL_KW CHAR_KW BOOL_KW IF_KW THEN_KW ELSE_KW SWITCH_KW DEFAULT_KW WHEN_KW RETURN_KW BREAK_KW OR_KW AND_KW XOR_KW ALSO_KW NOT_KW GT_KW LT_KW LE_KW EQ_KW GE_KW NE_KW PLUS_KW MINUS_KW MULT_KW DIV_KW MOD_KW QUEST_MARK ASSIGN_PLUS ASSIGN_MINUS ASSIGN_MULT ASSIGN_DIV INC_KW DEC_KW CASE_KW END_KW
%token <ival> INT_NUM
%token <rval> REAL_NUM
%token <bval> BOOL_CONSTANT
%token <id> IDENTIFIER
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
%right THEN_KW
%right ELSE_KW

%%

// this is the actual grammar that bison will parse, but for right now it's just
// something silly to echo to the screen what bison gets from flex.  We'll
// make a real one shortly:

program : PROGRAM_KW IDENTIFIER declist
	{
		fprintf(fout, "%d: Rule 1 \t\t program -> PROGRAM_KW IDENTIFIER declist \n", yylineno) ;
	};

declist : declist dec
	{
		fprintf(fout, "%d: Rule 2.1 \t\t declist -> declist dec \n", yylineno) ;
	};
	|  dec
	{
		fprintf(fout, "%d: Rule 2.2 \t\t declist -> dec \n", yylineno) ;
	};

dec : structdec
	{
		fprintf(fout, "%d: Rule 3.1 \t\t dec -> structdec \n", yylineno) ;
	};
	|	 vardec
	{
		fprintf(fout, "%d: Rule 3.2 \t\t dec -> vardec \n", yylineno) ;
	};
	| funcdec
	{
		fprintf(fout, "%d: Rule 3.3 \t\t dec -> funcdec \n", yylineno) ;
	};

structdec : STRUCT_KW IDENTIFIER '{' localdec '}'
  {
    fprintf(fout, "%d: Rule 4 \t\t structdec -> STRUCT_KW IDENTIFIER { localdec } \n", yylineno);
  };

localdec : localdec limitedvardec
  {
    fprintf(fout, "%d: Rule 5.1 \t\t localdec -> localdec limitedvardec \n", yylineno);
  };
  | /* empty */
  {
    fprintf(fout, "%d: Rule 5.2 \t\t localdec -> e \n", yylineno);
  };

limitedvardec : limitedvartype varsdecs ';'
  {
    fprintf(fout, "%d: Rule 6 \t\t limitedvardec -> limitedvartype varsdecs ; \n", yylineno);
  };

limitedvartype : CONST_KW type
  {
    fprintf(fout, "%d: Rule 7.1 \t\t limitedvartype -> CONST_KW type \n", yylineno);
  };
  | type
  {
    fprintf(fout, "%d: Rule 7.2 \t\t limitedvartype -> type \n", yylineno);
  };

type : INT_KW
  {
    fprintf(fout, "%d: Rule 8.1 \t\t type -> INT_KW \n", yylineno);
  };
  | REAL_KW
  {
    fprintf(fout, "%d: Rule8.2 \t\t type : REAL_KW \n", yylineno);
  };
  | CHAR_KW
  {
    fprintf(fout, "%d: Rule 8.3 \t\t type : CHAR_KW \n", yylineno);
  };
  | BOOL_KW
  {
    fprintf(fout, "%d: Rule 8.4 \t\t type : BOOL_KW \n", yylineno);
  };

vardec : type varsdecs ';'
  {
    fprintf(fout, "%d: Rule 9 \t\t vardec -> type varsdecs ;\n", yylineno);
  };

varsdecs : primiryvardec
  {
    fprintf(fout, "%d: Rule 10.1 \t\t varsdecs -> primiryvardec \n", yylineno);
  };
  | varsdecs ',' primiryvardec
  {
    fprintf(fout, "%d: Rule 10.1 \t\t varsdecs -> varsdecs , primiryvardec \n", yylineno);
  };

primiryvardec : varIDdec
  {
    fprintf(fout, "%d: Rule 11.1 \t\t primiryvardec -> varIDdec \n", yylineno);
  };
  | varIDdec '=' simpleexp
  {
    fprintf(fout, "%d: Rule 11.2 \t\t primiryvardec -> varIDdec = simpleexp \n", yylineno);
  };

varIDdec : IDENTIFIER
  {
    fprintf(fout, "%d: Rule 12.1 \t\t varIDdec -> IDENTIFIER \n", yylineno);
  };
  | IDENTIFIER '[' INT_NUM ']'
  {
    fprintf(fout, "%d: Rule 12.2 \t\t varIDdec -> IDENTIFIER [ INT_NUM ] \n", yylineno);
  };

funcdec : type IDENTIFIER '(' arg ')' sentence
  {
    fprintf(fout, "%d: Rule 13.1 \t\t funcdec -> type IDENTIFIER ( arg ) sentence \n", yylineno);
  };
  | IDENTIFIER '(' arg ')' sentence
  {
    fprintf(fout, "%d: Rule 13.2 \t\t funcdec -> IDENTIFIER ( arg ) sentence \n", yylineno);
  };

arg : args
  {
    fprintf(fout, "%d: Rule 14.1 \t\t arg -> args \n", yylineno);
  };
  | /* empty */
  {
    fprintf(fout, "%d: Rule 14.2 \t\t arg : e \n", yylineno);
  };

args : args ';' argstype
  {
    fprintf(fout, "%d: Rule 15.1 \t\t args -> args ; argstype \n", yylineno);
  };
  | argstype
  {
    fprintf(fout, "%d: Rule 15.2 \t\t args -> argstype \n", yylineno);
  };

argstype : type argsID
  {
    fprintf(fout, "%d: Rule 16 \t\t argstype -> type argsID \n", yylineno);
  };

argsID : argsID ',' argID
  {
    fprintf(fout, "Rule 17.1 \t\t argsID -> argsID , argID \n");
  };
  | argID
  {
    fprintf(fout, "Rule 17.2 \t\t argsID -> argID \n");
  };

argID : IDENTIFIER
  {
    fprintf(fout, "Rule 18.1 \t\t argID -> IDENTIFIER \n");
  };
  | IDENTIFIER '[' ']'
  {
    fprintf(fout, "Rule 18.2 \t\t argID : IDENTIFIER [ ] \n");
  };

sentence : compSent
  {
    fprintf(fout, "Rule 19.1 \t\t sentence -> compSent \n");
  };
  | exprSent
  {
    fprintf(fout, "Rule 19.2 \t\t sentence -> exprSent \n");
  };
  | selectSent
  {
    fprintf(fout, "Rule 19.3 \t\t sentence -> selectSent \n");
  };
  | repeatSent
  {
    fprintf(fout, "Rule 19.4 \t\t sentence -> repeatSent \n");
  };
  | returnSent
  {
    fprintf(fout, "Rule 19.5 \t\t sentence -> returnSent \n");
  };
  | breakSent
  {
    fprintf(fout, "Rule 19.6 \t\t sentence -> breakSent \n");
  };

compSent : '{' localdec sentences '}'
  {
    fprintf(fout, "Rule 20 \t\t compSent -> { localdec sentences } \n");
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
    fprintf(fout, "Rule 6 \t\t variable -> IDENTIFIER \n");
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
  fclose(fout);
  printf("Finished\n");
}

void yyerror(const char *s) {
	fprintf(fout, "**Error: Line %d near token '%s' --> Message: %s **\n", yylineno,yytext ,s);
	printf("**Error: Line %d near token '%s' --> Message: %s **\n", yylineno,yytext, s);
	// might as well halt now:
	//exit(-1);
}
