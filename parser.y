%{

#include <cstdio>
#include <cstdlib>
#include <vector>
#include <fstream>
#include <iostream>
#include <string>
#include <cstring>
#include <sstream>
#include <cstring>
using namespace std;


// stuff from flex that bison needs to know about:
// extern "C" int yylex();
// extern "C" int yyparse();
extern FILE *yyin;
extern int yylineno;
extern char* yytext;
extern char* lexID;
extern int lexNum;
extern double lexReal;
extern char* lexChar;
extern bool lexBool;
extern int yylex(void);

char symbolTable[100][50];
int wrong=0;
int cursor = 0;

int num = 0; // temporary variable numbers

int install_id(char* next) {
  for (int i = 0; i < cursor; i++) {
    if (strcmp(next, symbolTable[i]) == 0) {
      return i;
    }
  }

  strcpy(symbolTable[cursor], next);
  return cursor++;
}


void yyerror(const char *s);

FILE *fout;

enum {
  TYPE_UNKNOWN = -1,
  TYPE_INT = 0,
  TYPE_REAL = 1,
  TYPE_CHAR = 2,
  TYPE_BOOL = 3
};

/*** Symbol Table ***/


struct symbolTableEntry {
    string id;
    string type;
    bool is_array = false;
    vector <symbolTableEntry> *forward = NULL;
    vector <symbolTableEntry> *backward = NULL;
    int uid = 0;
};

void symbolTableInsert(string* _id, int _type, bool _isArray) {

}

symbolTableEntry symbolTableLookup(string* _id) {
  symbolTableEntry a;
  return a;
}

char* newTemp(int _type, bool _isArray) {
  string* name = new string{"temp"};
  name += num++;
  symbolTableInsert(name, _type, _isArray);
  char* c = (char*) malloc(sizeof(char) * 100);
  strcpy(c,symbolTableLookup(name).id.c_str());
  return c;
}


%}

%union {
  struct {

    int type;
    char* place;
  } E;
}

// define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the union:
%token PROGRAM_KW STRUCT_KW CONST_KW INT_KW REAL_KW CHAR_KW BOOL_KW IF_KW THEN_KW ELSE_KW SWITCH_KW DEFAULT_KW WHEN_KW RETURN_KW BREAK_KW OR_KW AND_KW XOR_KW ALSO_KW NOT_KW GT_KW LT_KW LE_KW EQ_KW GE_KW PLUS_KW MINUS_KW MULT_KW DIV_KW MOD_KW QUEST_MARK ASSIGN_PLUS ASSIGN_MINUS ASSIGN_MULT ASSIGN_DIV INC_KW DEC_KW CASE_KW END_KW
%token <E> INT_NUM
%token <E> REAL_NUM
%token <E> BOOL_CONSTANT
%token <E> IDENTIFIER
%token <E> CHAR_CONSTANT

%type <E> idetifier_type
%type <E> int_type
%type <E> real_type
%type <E> bool_type
%type <E> char_type
%type <E> program declist dec structdec localdec limitedvardec limitedvartype type vardec varsdecs primiryvardec varIDdec funcdec arg args argstype argsID argID sentence compSent sentences exprSent selectSent caseelement defaultelement repeatSent returnSent argsVector constant argVector call breakSent unvar expr simpleexp variable relativeexp relativeop arthlogicexpr unaryexpr unaryop opera
%right THEN_KW
%right ELSE_KW
%left XOR_KW OR_KW
%right '='
%left AND_KW ALSO_KW
%left EQ_KW LT_KW GT_KW LE_KW GE_KW
%left PLUS_KW MINUS_KW
%left MULT_KW DIV_KW MOD_KW
%right NOT_KW

%%

// this is the actual grammar that bison will parse, but for right now it's just
// something silly to echo to the screen what bison gets from flex.  We'll
// make a real one shortly:

program : PROGRAM_KW idetifier_type declist
	{
		fprintf(fout, "Rule 1 \t\t program -> PROGRAM_KW idetifier_type declist \n") ;
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

structdec : STRUCT_KW idetifier_type '{' localdec '}'
  {
    fprintf(fout, "%d: Rule 4 \t\t structdec -> STRUCT_KW idetifier_type { localdec } \n", yylineno);
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
    fprintf(fout, "%d: Rule 8.2 \t\t type : REAL_KW \n", yylineno);
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
    fprintf(fout, "%d: Rule 10.2 \t\t varsdecs -> varsdecs , primiryvardec \n", yylineno);
  };

primiryvardec : varIDdec
  {
    fprintf(fout, "%d: Rule 11.1 \t\t primiryvardec -> varIDdec \n", yylineno);
  };
  | varIDdec '=' simpleexp
  {
    fprintf(fout, "%d: Rule 11.2 \t\t primiryvardec -> varIDdec = simpleexp \n", yylineno);
  };

varIDdec : idetifier_type
  {
    fprintf(fout, "%d: Rule 12.1 \t\t varIDdec -> idetifier_type \n", yylineno);
  };
  | idetifier_type '[' int_type ']'
  {
    fprintf(fout, "%d: Rule 12.2 \t\t varIDdec -> idetifier_type [ int_type ] \n", yylineno);
  };

funcdec : type idetifier_type '(' arg ')' sentence
  {
    fprintf(fout, "%d: Rule 13.1 \t\t funcdec -> type idetifier_type ( arg ) sentence \n", yylineno);
  };
  | idetifier_type '(' arg ')' sentence
  {
    fprintf(fout, "%d: Rule 13.2 \t\t funcdec -> idetifier_type ( arg ) sentence \n", yylineno);
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

argID : idetifier_type
  {
    fprintf(fout, "Rule 18.1 \t\t argID -> idetifier_type \n");
  };
  | idetifier_type '[' ']'
  {
    fprintf(fout, "Rule 18.2 \t\t argID : idetifier_type [ ] \n");
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
    fprintf(fout, "Rule 41 \t\t compSent -> { localdec sentences } \n");
  };

sentences : sentences sentence
  {
    fprintf(fout, "Rule 42 \t\t sentences -> sentences sentence \n");
  };
  | /* empty */
  {
    fprintf(fout, "Rule 43 \t\t sentences -> e \n");
  };

exprSent : expr ';'
  {
    fprintf(fout, "Rule 44 \t\t exprSent -> expr ; \n");
  };
  | ';'
  {
    fprintf(fout, "Rule 45 \t\t exprSent -> ; \n");
  };

selectSent : IF_KW simpleexp THEN_KW sentence
  {
    fprintf(fout, "Rule 46 \t\t selectSent -> IF_KW simpleexp THEN_KW sentence \n");
  };
  | IF_KW simpleexp THEN_KW sentence ELSE_KW sentence
  {
    fprintf(fout, "Rule 47 \t\t selectSent -> IF_KW simpleexp THEN_KW sentence ELSE_KW sentence \n");
  };
  | SWITCH_KW '(' simpleexp ')' caseelement defaultelement END_KW
  {
    fprintf(fout, "Rule 48 \t\t selectSent -> SWITCH_KW '(' simpleexp ')' caseelement defaultelement END_KW \n");
  };

caseelement : CASE_KW int_type ':' sentence ';'
  {
    fprintf(fout, "Rule 49 \t\t caseelement -> CASE_KW int_type : sentence ; \n");
  };
  | caseelement CASE_KW int_type ':' sentence ';'
  {
    fprintf(fout, "Rule 50 \t\t caseelement -> caseelement CASE_KW int_type : sentence ; \n");
  };

defaultelement : DEFAULT_KW ':' sentence ';'
  {
    fprintf(fout, "Rule 51 \t\t defaultelement -> DEFAULT_KW : sentence ; \n");
  };
  | /* empty */
  {
    fprintf(fout, "Rule 52 \t\t defaultelement -> e \n");
  };

repeatSent : WHEN_KW '(' simpleexp ')' sentence
  {
    fprintf(fout, "Rule 53 \t\t repeatSent -> WHEN_KW '(' simpleexp ')' sentence \n");
  };

returnSent : RETURN_KW expr ';'
  {
    fprintf(fout, "Rule 54 \t\t returnSent -> RETURN_KW ; \n");
  };

breakSent : BREAK_KW ';'
  {
    fprintf(fout, "Rule 55 \t\t breakSent -> BREAK_KW ; \n");
  };

expr : variable '=' expr M
  {
	if($3.type == boolean)
	{
	  backpatch($3.truelist,$4.quad);
      backpatch($3.falselist,$4.quad + 2);
	  emit($1.place '=' '1');
	  emit('goto' $4.quad + 3);
	  emit($1.place '=' '0');
	}else
	{
	}
    fprintf(fout, "Rule 56 \t\t expr -> variable = expr \n");
  };
  | variable ASSIGN_PLUS expr M
  {
	if($3.type == boolean)
	{
	  backpatch($3.truelist,$4.quad);
      backpatch($3.falselist,$4.quad + 1);
	  emit($1.place '=' $1.place '+' '1');

	}else
	{
	}
    fprintf(fout, "Rule 57 \t\t expr -> variable += expr \n");
  };
  | variable ASSIGN_MINUS expr M
  {
	if($3.type == boolean)
	{
	  backpatch($3.truelist,$4.quad);
      backpatch($3.falselist,$4.quad + 1);
	  emit($1.place '=' $1.place '-' '1');
	}else
	{
	}
    fprintf(fout, "Rule 58 \t\t expr -> variable -= expr \n");
  };
  | variable ASSIGN_MULT expr M
  {
	if($3.type == boolean)
	{
	  backpatch($3.truelist,$4.quad + 1);
      backpatch($3.falselist,$4.quad);
	  emit($1.place '=' '0');
	}else
	{
	}
    fprintf(fout, "Rule 59 \t\t expr -> variable *= expr \n");
  };
  | variable ASSIGN_DIV expr M
  {
	if($3.type == boolean)
	{
	//error because % 0 and % 1 can not be defined
	}else
	{
	}
    fprintf(fout, "Rule 60 \t\t expr -> variable /= expr \n");
  };
  | variable INC_KW
  {
    fprintf(fout, "Rule 61 \t\t expr -> variable ++ \n");
  };
  | variable DEC_KW expr
  {
    fprintf(fout, "Rule 62 \t\t expr -> variable -- \n");
  };
  | simpleexp
  {
	$$.truelist = $1.truelist;
	$$.falselist = $1.falselist;
	$$.type = $1.type;
	fprintf(fout, "Rule 63 \t\t expr -> simpleexp \n");
  };


simpleexp : simpleexp OR_KW M simpleexp
  {
    backpatch($1.falselist,$3.quad);
	$$.truelist = merge($1.truelist,$4.truelist);
	$$.falselist = $4.falselist;
	$$.type = boolean;
    fprintf(fout, "Rule 64 \t\t simpleexp -> simpleexp OR simpleexp \n");
  };
  | simpleexp AND_KW M simpleexp
  {
	backpatch($1.truelist,$3.quad);
	$$.truelist = $4.truelist;
	$$.falselist = merge($1.falselist,$4.falselist);
    $$.type = boolean;
	fprintf(fout, "Rule 65 \t\t simpleexp -> simpleexp AND simpleexp \n");
  };
  | simpleexp XOR_KW simpleexp
  {
    fprintf(fout, "Rule 66 \t\t simpleexp -> simpleexp XOR simpleexp \n");
  };
  | simpleexp ALSO_KW simpleexp
  {
    fprintf(fout, "Rule 67 \t\t simpleexp -> simpleexp ALSO simpleexp \n");
  };
  | NOT_KW simpleexp
  {
	$$.truelist = $2.falselist;
	$$.falselist = $2.truelist;
	$$.type = boolean;
    fprintf(fout, "Rule 68 \t\t simpleexp -> NOT simpleexp \n");
  };
  | relativeexp
  {
	$$.turelist = $1.truelist;
	$$.falselist = $2.falselist;
	$$.type = boolean;
    fprintf(fout, "Rule 69 \t\t simpleexp -> relativeexp \n");
  };

relativeexp : arthlogicexpr
  {
	$$.truelist = $1.truelist;
	$$.falselist = $2.falselist;
    fprintf(fout, "Rule 70 \t\t relativeexp -> arthlogicexpr \n");
  };
  | arthlogicexpr relativeop arthlogicexpr
  {
	$$.truelist = makelist(nextquad);
    $$.falselist = makelist(nextquad + 1);
	emit('if' $1.place $2.op $3.place 'goto' unknown);
	emit('goto' unknown);
	fprintf(fout, "Rule 71 \t\t relativeexp -> arthlogicexpr relativeop arthlogicexpr \n");
  };

relativeop : LT_KW
  {
    fprintf(fout, "Rule 72 \t\t relativeop -> < \n");
  };
  | LE_KW
  {
    fprintf(fout, "Rule 73 \t\t relativeop -> <= \n");
  };
  | EQ_KW
  {
    fprintf(fout, "Rule 74 \t\t relativeop -> == \n");
  };
  | GE_KW
  {
    fprintf(fout, "Rule 75 \t\t relativeop -> >= \n");
  };
  | GT_KW
  {
    fprintf(fout, "Rule 76 \t\t relativeop -> > \n");
  };

arthlogicexpr : unaryexpr
  {
    fprintf(fout, "Rule 77 \t\t arthlogicexpr -> unaryexpr \n");
  };
  | arthlogicexpr PLUS_KW arthlogicexpr
  {
    fprintf(fout, "Rule 78 \t\t arthlogicexpr -> arthlogicexpr arthop arthlogicexpr \n");
  };
  | arthlogicexpr  MINUS_KW arthlogicexpr
  {

	fprintf(fout, "Rule 78 \t\t arthlogicexpr -> arthlogicexpr arthop arthlogicexpr \n");
  };
  | arthlogicexpr  MULT_KW arthlogicexpr
  {
	fprintf(fout, "Rule 78 \t\t arthlogicexpr -> arthlogicexpr arthop arthlogicexpr \n");
  };
  | arthlogicexpr  DIV_KW arthlogicexpr
  {
	fprintf(fout, "Rule 78 \t\t arthlogicexpr -> arthlogicexpr arthop arthlogicexpr \n");
  };
  | arthlogicexpr  MOD_KW arthlogicexpr
  {
	fprintf(fout, "Rule 78 \t\t arthlogicexpr -> arthlogicexpr arthop arthlogicexpr \n");
  };

unaryexpr :  unaryop unaryexpr
  {
    fprintf(fout, "Rule 84 \t\t unaryexpr ->  unaryop unaryexpr \n");
  };
  | opera
  {
    fprintf(fout, "Rule 85 \t\t unaryexpr ->  opera \n");
  };

unaryop : MINUS_KW
  {
    fprintf(fout, "Rule 86 \t\t unaryop -> - \n");
  };
  | MULT_KW
  {
    fprintf(fout, "Rule 87 \t\t unaryop -> * \n");
  };
  | QUEST_MARK
  {
    fprintf(fout, "Rule 88 \t\t unaryop -> ? \n");
  };

opera : variable
  {
    fprintf(fout, "Rule 89 \t\t opera -> variable \n");
  };
  | unvar
  {
    fprintf(fout, "Rule 90 \t\t opera -> unvar \n");
  };

variable : idetifier_type
  {
    fprintf(fout, "Rule 91 \t\t variable -> idetifier_type \n");
  };
  | variable '[' expr ']'
  {
    fprintf(fout, "Rule 92 \t\t variable -> variable [ expr ] \n");
  };
  | variable '.' idetifier_type
  {
    fprintf(fout, "Rule 93 \t\t variable : variable . idetifier_type \n");
  };

unvar : '(' expr ')'
  {
    fprintf(fout, "Rule 94 \t\t unvar -> ( expr ) \n");
  };
  | call
  {
    fprintf(fout, "Rule 95 \t\t unvar -> call \n");
  };
  | constant
  {
    fprintf(fout, "Rule 96 \t\t unvar : constant \n");
  };

call : idetifier_type '(' argVector ')'
  {
    fprintf(fout, "Rule 97 \t\t call -> idetifier_type '(' argVector ')' \n");
  };

argVector : argsVector
  {
    fprintf(fout, "Rule 98 \t\t argVector -> argsVector \n");
  };
  | /* empty */
  {
    fprintf(fout, "Rule 99 \t\t argVector -> e \n");
  };

argsVector : argsVector ',' expr
  {
    fprintf(fout, "Rule 100 \t\t argsVector -> argsVector , expr \n");
  };
  | expr
  {
    fprintf(fout, "Rule 101 \t\t argsVector -> expr \n");
  };

constant : int_type
  {
    fprintf(fout, "Rule 102 \t\t constant : int_type \n");
  };
  | real_type
  {
    fprintf(fout, "Rule 103 \t\t constant : real_type \n");
  };
  | char_type
  {
    fprintf(fout, "Rule 104 \t\t constant : CHAR_CONSTANT \n");
  };
  | bool_type
  {
    fprintf(fout, "Rule 105 \t\t constant : BOOLEAN_CONSTANT \n");
  };

int_type : INT_NUM {
  $$.type = TYPE_INT;
  // place = newTemp(INT_NUM,false);
};

real_type : REAL_NUM {
  $$.type = TYPE_REAL;
  // $$.place = newTemp(REAL_NUM,false);
};

char_type : CHAR_CONSTANT {
  $$.type = TYPE_CHAR;
  // $$.place = newTemp(CHAR_CONSTANT,false);
};

bool_type : BOOL_CONSTANT {
  $$.type = TYPE_BOOL;
  // $$.place = newTemp(BOOL_CONSTANT,false);
};

idetifier_type : IDENTIFIER {
  $$.place = lexID;

};

M : /* empty */
  {
  $$.quad = nextquad;
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
