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
#include <list>
#include "llist.h"
#include <csignal>
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

// char symbolTable[1000][50];
int wrong=0;
int nextquad = 0;
int num = 0; // temporary variable numbers

void yyerror(const char *s);

FILE *fout;

enum {
    TYPE_UNKNOWN = -1,
    TYPE_INT = 0,
    TYPE_REAL = 1,
    TYPE_CHAR = 2,
    TYPE_BOOL = 3
};

void split(const string &s, char delim, vector<string> &elems) {
    stringstream ss;
    ss.str(s);
    string item;
    while (getline(ss, item, delim)) {
        elems.push_back(item);
    }
    if (elems.empty()) elems.push_back(s);
}

vector<string> split(const string &s, char delim) {
    vector<string> elems;
    split(s, delim, elems);
    return elems;
}

/*** Symbol Table ***/
struct symbolTableEntry {
    string id;
    int type;
    bool is_array = false;
    vector <symbolTableEntry> *forward = NULL;
    vector <symbolTableEntry> *backward = NULL;
    int uid = 0;
};

int cursor = 0;
vector<symbolTableEntry*> symbolTable;

int symbolTableInsert(string _id, int _type, bool _isArray) {
    symbolTableEntry* ste = new symbolTableEntry;
    if (_id[0] == '#') _id = _id.substr(1);
    ste->id = _id;
    ste->type = _type;
    ste->is_array = _isArray;
    ste->uid = cursor;
    symbolTable.push_back(ste);
    return cursor++;
}

symbolTableEntry* symbolTableLookup(const string& _id) {
    for (auto& ste : symbolTable) {
        if (ste->id == _id) {
            return ste;
        }
    }
    return nullptr;
}

string printSymbolTable() {
    std::string s;
    for(auto& ste : symbolTable) {
        std::string arr = (ste->is_array) ? "*" : "";
        switch(ste->type) {
        case TYPE_INT:
            s += "\tint " + arr + ste->id + ";\n";
            break;
        case TYPE_BOOL:
            s += "\tchar " + arr + "b" + ste->id + ";\n";
            break;
        case TYPE_REAL:
            s += "\tdouble " + arr + ste->id + ";\n";
            break;
        case TYPE_CHAR:
            s += "\tchar " + arr + ste->id + ";\n";
            break;
        }
    }
    return s;
}

char* newTemp(int _type, bool _isArray) {
    string* name = new string{"temp"};
    *name += std::to_string(num++);
    symbolTableInsert(*name, _type, _isArray);
    return const_cast<char*>(name->c_str());
}

llist* makelist(int _data) {
    node* n = create_node(_data);
    llist* l = new llist;
    l->head = n;
    l->tail = nullptr;
    return l;
}

// END_OF_SYMBOL_TABLE

/*** Quadruples ***/

// // Quadruple
/*  ______________________________________________________________________________
  * |                                                                              |
  * |                                  Quadruples                                  |
  * |______________________________________________________________________________|
  * |              Statement             | Operation |    Arg0   |  Arg1 |  Result |
  * |____________________________________|___________|___________|_______|_________|
  * |               goto L               |    goto   |           |       |    L    |
  * |       if BOOLEAN then goto L       |   check   |  BOOLEAN  |       |    L    |
  * |             E = E1 < E2            |     <     |     E1    |   E2  |    E    |
  * |            E = E1 <= E2            |     <=    |     E1    |   E2  |    E    |
  * |             E = E1 > E2            |     >     |     E1    |   E2  |    E    |
  * |            E = E1 >= E2            |     >=    |     E1    |   E2  |    E    |
  * |            E = E1 == E2            |     ==    |     E1    |   E2  |    E    |
  * |            E = E1 <> E2            |     <>    |     E1    |   E2  |    E    |
  * |             E = E1 + E2            |     +     |     E1    |   E2  |    E    |
  * |             E = E1 - E2            |     -     |     E1    |   E2  |    E    |
  * |             E = E1 * E2            |     *     |     E1    |   E2  |    E    |
  * |             E = E1 / E2            |     /     |     E1    |   E2  |    E    |
  * |             E = E1 % E2            |     %     |     E1    |   E2  |    E    |
  * |               E = -E1              |    usub   |     E1    |       |    E    |
  * |               E = *E1              |  asterisk |     E1    |       |    E    |
  * |               E = ?E1              |   quest   |     E1    |       |    E    |
  * |               E = E1               |     =     |     E1    |       |    E    |
  * |            E = (TYPE) E1           |    cast   |     E1    |  TYPE |    E    |
  * |               TYPE E               |    init   |           |  TYPE |    E    |
  * |         printf("E = E.val")        |   iprint  |           |       |   int   |
  * |         printf("E = E.val")        |   rprint  |           |       |   real  |
  * |         printf("E = E.val")        |   cprint  |           |       |   char  |
  * |         printf("E = E.val")        |   bprint  |           |       | boolean |
  * |  printf("E[PLACE] = E[INDEX].val") |  aiprint  |   PLACE   | INDEX |   int   |
  * |  printf("E[PLACE] = E[INDEX].val") |  arprint  |   PLACE   | INDEX |   real  |
  * |  printf("E[PLACE] = E[INDEX].val") |  acprint  |   PLACE   | INDEX |   char  |
  * |  printf("E[PLACE] = E[INDEX].val") |  abprint  |   PLACE   | INDEX | boolean |
  * | NAME = malloc(sizeOf(TYPE) * SIZE) |   malloc  |    TYPE   |  SIZE |   NAME  |
  * |          *(E + INDEX) = E1         |    []=    |     E1    | INDEX |    E    |
  * |          E = *(E1 + INDEX)         |    =[]    |     E1    | INDEX |    E    |
  * |____________________________________|___________|___________|_______|_________|
  */

struct Quadruple
{
    Quadruple(string _op, string _arg1, string _arg2, string _res) :
        operation(_op),
        arg1(_arg1),
        arg2(_arg2),
        result(_res)
    {

    }
    string operation;
    string arg1;
    string arg2;
    string result;
};

vector <Quadruple*> quadruples;

void emit(string _op, string _arg1, string _arg2, string _result) {
    nextquad++;
    quadruples.push_back(new Quadruple(_op, _arg1, _arg2, _result));
}

void backpatch(struct llist* _head, int _label) {
    struct node* current;
    for (current = _head->head; current != nullptr; current = current->next) {
        quadruples[current->data]->result = _label;
    }
}

void fillQuad(int i, int j, string _data) {
    switch(j) {
    case 0:
        quadruples[i]->operation = _data;
        break;
    case 1:
        quadruples[i]->arg1      = _data;
        break;
    case 2:
        quadruples[i]->arg2      = _data;
        break;
    case 3:
        quadruples[i]->result    = _data;
        break;
    default:
        printf("Wrong index%d\n", j);
    }
}

string printQuadruple()
{
    std::string s;
    for(int i = 0;i < quadruples.size();i++)
    {
        s += "L" + std::to_string(i) + ": ";
        if (quadruples[i] -> operation == "+") {
            s += quadruples[i] -> result + " = " + quadruples[i] -> arg1 + " + " + quadruples[i] -> arg2 + ";\n";
        } else if(quadruples[i] -> operation == "-") {
            s += quadruples[i] -> result + " = " + quadruples[i] -> arg1 + " - " + quadruples[i] -> arg2 + ";\n";
        } else if(quadruples[i] -> operation == "*") {
            s += quadruples[i] -> result + " = " + quadruples[i] -> arg1 + " * " + quadruples[i] -> arg2 + ";\n";
        } else if(quadruples[i] -> operation == "/") {
            s += quadruples[i] -> result + " = " + quadruples[i] -> arg1 + " / " + quadruples[i] -> arg2 + ";\n";
        } else if(quadruples[i] -> operation == "%") {
            s += quadruples[i] -> result + " = " + quadruples[i] -> arg1 + " % " + quadruples[i] -> arg2 + ";\n";
        } else if(quadruples[i] -> operation == "ifgoto") {
            s +=  std::string("if") + " ( " + quadruples[i] -> arg1 +" ) " + "goto " + "L" + quadruples[i] -> result + ";\n";
        } else if(quadruples[i] -> operation == "goto") {
            s += std::string("goto ") + "L" + quadruples[i] -> result + ";\n";
        } else if(quadruples[i] -> operation == "=") {
            s += quadruples[i] -> result + " = " + quadruples[i] -> arg1 + ";\n";
        } else if(quadruples[i] -> operation == "<") {
            s += quadruples[i] -> result + " = (" + quadruples[i] -> arg1 + "<" + quadruples[i] -> arg2 + ") ;\n";
        } else if(quadruples[i] -> operation == "<=") {
            s += quadruples[i] -> result + " = (" + quadruples[i] -> arg1 + "<=" + quadruples[i] -> arg2 + ") ;\n";
        } else if(quadruples[i] -> operation == "==") {
            s += quadruples[i] -> result + " = (" + quadruples[i] -> arg1 + "==" + quadruples[i] -> arg2 + ") ;\n";
        } else if(quadruples[i] -> operation == ">") {
            s += quadruples[i] -> result + " = (" + quadruples[i] -> arg1 + ">" + quadruples[i] -> arg2 + ") ;\n";
        } else if(quadruples[i] -> operation == ">=") {
            s += quadruples[i] -> result + " = (" + quadruples[i] -> arg1 + ">=" + quadruples[i] -> arg2 + ") ;\n";
        } else if(quadruples[i] -> operation == "usub") {
            s += quadruples[i] -> result + " = " + "-1 * " + quadruples[i] -> arg1 + ";\n";
        } else if(quadruples[i] -> operation == "asterisk") {
            s += quadruples[i] -> result + " = " + "sizeof(" + quadruples[i] -> arg1 + ")/sizeof(" + quadruples[i] -> arg1 + "[0]) ;\n";
        } else if(quadruples[i] -> operation == "quest") {
            s += quadruples[i] -> result + " = " + "ud(0, " + quadruples[i] -> arg1 + ") ;\n";
        } else {
            s+= quadruples[i]->operation + ";\n";
        }
    }
    return s;
}

// END_OF_QUADRUPLES

void generateInterCode() {
    FILE* interCode;
    interCode = fopen("mahi.c", "w");
    if (fout == NULL) {
        printf("Error opening file!\n");
        return;
    }
    fprintf(interCode, "#include <stdio.h>\n");
    fprintf(interCode, "#include <time.h>\n");
    fprintf(interCode, "#include <stdlib.h>\n");
    fprintf(interCode, "#include <stack.h>\n\n");
    fprintf(interCode, "int ud(int rL, int rH) {\n\tdouble mR = rand()/(1.0 + RAND_MAX);\n\tint r = rH - rL + 1;\n\tint mRS = (mR * r) + rL;\n\treturn mrS;\n}\n\n");
    fprintf(interCode, "void main() {\n");
    fprintf(interCode, "/* SYMBOL TABLE */\n");
    fprintf(interCode, "%s\n", printSymbolTable().c_str());
    fprintf(interCode, "/*  Quadruples  */\n");
    fprintf(interCode, "%s\n", printQuadruple().c_str());

    fclose(interCode);

}

%}

%union {
    struct {

        int type;
        char* place;
        char* code;
        struct llist* truelist;
        struct llist* falselist;
        int quad;
    } E;
}

// define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the union:
%token PROGRAM_KW STRUCT_KW CONST_KW INT_KW REAL_KW CHAR_KW BOOL_KW IF_KW THEN_KW ELSE_KW SWITCH_KW DEFAULT_KW WHEN_KW RETURN_KW BREAK_KW OR_KW AND_KW XOR_KW ALSO_KW NOT_KW GT_KW LT_KW LE_KW EQ_KW GE_KW PLUS_KW MINUS_KW MULT_KW DIV_KW MOD_KW QUEST_MARK ASSIGN_PLUS ASSIGN_MINUS ASSIGN_MULT ASSIGN_DIV INC_KW DEC_KW CASE_KW END_KW
%token <E> INT_NUM
%token <E> REAL_NUM
%token <E> BOOL_CONSTANT_TRUE
%token <E> BOOL_CONSTANT_FALSE
%token <E> IDENTIFIER
%token <E> CHAR_CONSTANT

%type <E> idetifier_type
%type <E> int_type
%type <E> real_type
%type <E> bool_type
%type <E> char_type
%type <E> program declist dec structdec localdec limitedvardec limitedvartype type vardec varsdecs primiryvardec varIDdec funcdec arg args argstype argsID argID sentence compSent sentences exprSent selectSent caseelement defaultelement repeatSent returnSent argsVector constant argVector call breakSent unvar expr simpleexp variable relativeexp relativeop arthlogicexpr unaryexpr unaryop opera
%type <E> M
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
    printf("Mahi\n");
    generateInterCode();
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
    vector<string> tokens = split($2.code, ',');
    for(auto& token : tokens) {
        symbolTableInsert(token, $1.type, (token[0] == '#'));
    }
};

limitedvartype : CONST_KW type
{
    $$.type = $2.type;
    fprintf(fout, "%d: Rule 7.1 \t\t limitedvartype -> CONST_KW type \n", yylineno);
};
| type
{
    $$.type = $1.type;
    fprintf(fout, "%d: Rule 7.2 \t\t limitedvartype -> type \n", yylineno);
};

type : INT_KW
{
    $$.type = TYPE_INT;
    fprintf(fout, "%d: Rule 8.1 \t\t type -> INT_KW \n", yylineno);
};
| REAL_KW
{
    $$.type = TYPE_REAL;
    fprintf(fout, "%d: Rule 8.2 \t\t type : REAL_KW \n", yylineno);
};
| CHAR_KW
{
    $$.type = TYPE_CHAR;
    fprintf(fout, "%d: Rule 8.3 \t\t type : CHAR_KW \n", yylineno);
};
| BOOL_KW
{
    $$.type = TYPE_BOOL;
    fprintf(fout, "%d: Rule 8.4 \t\t type : BOOL_KW \n", yylineno);
};

vardec : type varsdecs ';'
{
    vector<string> tokens = split($2.code, ',');
    for(auto& token : tokens) {
        symbolTableInsert(token, $1.type, (token[0] == '#'));
    }
    fprintf(fout, "%d: Rule 9 \t\t vardec -> type varsdecs ;\n", yylineno);
};

varsdecs : primiryvardec
{
    fprintf(fout, "%d: Rule 10.1 \t\t varsdecs -> primiryvardec \n", yylineno);
    $$.code = new char[100];
    strcpy($$.code,$1.place);

};
| varsdecs ',' primiryvardec
{
    fprintf(fout, "%d: Rule 10.2 \t\t varsdecs -> varsdecs , primiryvardec \n", yylineno);
    char *tt = new char[100];
    strcpy(tt, $1.code);
    $$.code = strcat(strcat(tt, ","), $3.place);
};

primiryvardec : varIDdec
{
    fprintf(fout, "%d: Rule 11.1 \t\t primiryvardec -> varIDdec \n", yylineno);
    $$.place = $1.place;

};
| varIDdec '=' simpleexp
{
    fprintf(fout, "%d: Rule 11.2 \t\t primiryvardec -> varIDdec = simpleexp \n", yylineno);
    $$.place = $1.place;
    // emit("=", $3.place, "", $1.place);
};

varIDdec : idetifier_type
{
    $$.place = $1.place;
    fprintf(fout, "%d: Rule 12.1 \t\t varIDdec -> idetifier_type \n", yylineno);
};
| idetifier_type '[' int_type ']'
{
    fprintf(fout, "%d: Rule 12.2 \t\t varIDdec -> idetifier_type [ int_type ] \n", yylineno);
    $$.place = new char[100];
    strcpy($$.place,"#");
    strcat($$.place,$1.place);
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

expr : variable '=' expr
{
    fprintf(fout, "Rule 56 \t\t expr -> variable = expr \n");
    if($3.type == TYPE_BOOL) {
        backpatch($3.truelist,nextquad);
        backpatch($3.falselist,nextquad + 2);
        emit("=", "1", "", $1.place);
        emit("goto", "", "", std::to_string(nextquad + 3));
        emit("=", "0", "",$1.place);
    } else {
        $$.type = $1.type;
        emit("=", $3.place, "", $1.place);
    }
};
| variable ASSIGN_PLUS expr
{
    if($3.type == TYPE_BOOL) {
        backpatch($3.truelist,nextquad);
        backpatch($3.falselist,nextquad + 1);
        emit("+", $1.place, "1", $1.place);

    } else {
        $$.type = $1.type;
        emit("+", $3.place, $1.place, $1.place);
    }
    fprintf(fout, "Rule 57 \t\t expr -> variable += expr \n");
};
| variable ASSIGN_MINUS expr
{
    $$.place = newTemp($1.type, false);
    $$.type = $1.type;
    backpatch($3.truelist,nextquad + 1);
    backpatch($3.falselist,nextquad);
    emit("=", $1.place, "0", $$.place);
    emit("=", $1.place, "1", $3.place);
    emit("-", $1.place, $3.place, $1.place);
    fprintf(fout, "Rule 58 \t\t expr -> variable -= expr \n");
};
| variable ASSIGN_MULT expr
{
    $$.place = newTemp($1.type, false);
    $$.type = $1.type;
    backpatch($3.truelist,nextquad + 1);
    backpatch($3.falselist,nextquad);
    emit("=", "0", "", $3.place);
    emit("=", "1", "", $3.place);
    emit("*", $1.place, $3.place, $1.place);
    fprintf(fout, "Rule 59 \t\t expr -> variable *= expr \n");
};
| variable ASSIGN_DIV expr
{
    $$.place = newTemp($1.type, false);
    $$.type = $1.type;
    backpatch($3.truelist,nextquad+1);
    backpatch($3.falselist, nextquad);
    emit("=","0","", $3.place);
    emit("=","1","", $3.place);
    emit("/", $1.place, $3.place, $$.place);
    emit("/", $1.place, $3.place, $1.place);
    fprintf(fout, "Rule 60 \t\t expr -> variable /= expr \n");
};
| variable INC_KW
{
    $$.place = newTemp($1.type, false);
    fprintf(fout, "Rule 61 \t\t expr -> variable ++ \n");
    $$.type = $1.type;
    emit("+", $1.place, "1", $$.place);
    emit("+", $1.place, "1", $1.place);
};
| variable DEC_KW
{
    fprintf(fout, "Rule 62 \t\t expr -> variable -- \n");
    $$.place = newTemp($1.type, false);
    $$.type = $1.type;
    emit("-", $1.place, "1", $$.place);
    emit("-", $1.place, "1", $1.place);
};
| simpleexp
{
    fprintf(fout, "Rule 63 \t\t expr -> simpleexp \n");
    $$.type = $1.type;
    $$.place = $1.place;
    $$.truelist = $1.truelist;
    $$.falselist = $1.falselist;
};


simpleexp : simpleexp OR_KW M simpleexp
{
    fprintf(fout, "Rule 64 \t\t simpleexp -> simpleexp OR simpleexp \n");
    $$.place = newTemp(TYPE_BOOL, false);
    backpatch($1.falselist,$3.quad);
    $$.truelist = merge_lists($1.truelist,$4.truelist);
    $$.falselist = $4.falselist;
    $$.type = TYPE_BOOL;
};
| simpleexp AND_KW M simpleexp
{
    fprintf(fout, "Rule 65 \t\t simpleexp -> simpleexp AND simpleexp \n");
    $$.place = newTemp(TYPE_BOOL, false);
    backpatch($1.truelist,$3.quad);
    $$.truelist = $4.truelist;
    $$.falselist = merge_lists($1.falselist,$4.falselist);
    $$.type = TYPE_BOOL;
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
    fprintf(fout, "Rule 68 \t\t simpleexp -> NOT simpleexp \n");
    $$.place = newTemp(TYPE_BOOL, false);
    $$.type = TYPE_BOOL;
    $$.truelist = $2.falselist;
    $$.falselist = $2.truelist;
};
| relativeexp
{
    fprintf(fout, "Rule 69 \t\t simpleexp -> relativeexp \n");
    $$.type = $1.type;
    $$.place = $1.place;
    $$.truelist = $1.truelist;
    $$.falselist = $1.falselist;
};

relativeexp : arthlogicexpr
{
    fprintf(fout, "Rule 70 \t\t relativeexp -> arthlogicexpr \n");
    $$.type = $1.type;
    $$.place = $1.place;
    $$.truelist = $1.truelist;
    $$.falselist = $1.falselist;
};
| arthlogicexpr relativeop arthlogicexpr
{
    fprintf(fout, "Rule 71 \t\t relativeexp -> arthlogicexpr relativeop arthlogicexpr \n");
    $$.place = newTemp(TYPE_BOOL, false);
    $$.type = TYPE_BOOL;
    $$.truelist = makelist(nextquad + 1);
    $$.falselist = makelist(nextquad + 2);
    emit($2.place, $1.place, $3.place, $$.place);
    emit("ifgoto", $$.place,"", std::to_string(nextquad + 2));
    emit("goto", "", "", std::to_string(nextquad + 1));
};

relativeop : LT_KW
{
    fprintf(fout, "Rule 72 \t\t relativeop -> < \n");
    $$.place = new char[3];
    strcpy($$.place,"<");
};
| LE_KW
{
    fprintf(fout, "Rule 73 \t\t relativeop -> <= \n");
    $$.place = new char[3];
    strcpy($$.place,"<=");
};
| EQ_KW
{
    fprintf(fout, "Rule 74 \t\t relativeop -> == \n");
    $$.place = new char[3];
    strcpy($$.place,"==");
};
| GE_KW
{
    fprintf(fout, "Rule 75 \t\t relativeop -> >= \n");
    $$.place = new char[3];
    strcpy($$.place,">=");
};
| GT_KW
{
    fprintf(fout, "Rule 76 \t\t relativeop -> > \n");
    $$.place = new char[3];
    strcpy($$.place,">");
};

arthlogicexpr : unaryexpr
{
    fprintf(fout, "Rule 77 \t\t arthlogicexpr -> unaryexpr \n");
    $$.type = $1.type;
    $$.place = $1.place;
    $$.truelist = $1.truelist;
    $$.falselist = $1.falselist;
};
| arthlogicexpr PLUS_KW arthlogicexpr
{
    fprintf(fout, "Rule 78 \t\t arthlogicexpr -> arthlogicexpr PLUS_KW arthlogicexpr \n");
    $$.place = newTemp($1.type, false);
    $$.truelist = makelist(nextquad + 1);
    $$.falselist = makelist(nextquad + 2);
    emit("+", $1.place, $3.place, $$.place);
    emit("ifgoto", $$.place, "", std::to_string(nextquad + 2));
    emit("goto", "", "", std::to_string(nextquad + 1));
};
| arthlogicexpr MINUS_KW arthlogicexpr
{
    fprintf(fout, "Rule 78 \t\t arthlogicexpr -> arthlogicexpr MINUS_KW arthlogicexpr \n");
    $$.place = newTemp($1.type, false);
    $$.truelist = makelist(nextquad + 1);
    $$.falselist = makelist(nextquad + 2);
    emit("-", $1.place, $3.place, $$.place);
    emit("ifgoto", $$.place, "", std::to_string(nextquad + 2));
    emit("goto", "", "", std::to_string(nextquad + 1));
};
| arthlogicexpr MULT_KW arthlogicexpr
{
    fprintf(fout, "Rule 78 \t\t arthlogicexpr -> arthlogicexpr MULT_KW arthlogicexpr \n");
    $$.place = newTemp($1.type, false);
    $$.truelist = makelist(nextquad + 1);
    $$.falselist = makelist(nextquad + 2);
    emit("*", $1.place, $3.place, $$.place);
    emit("ifgoto", $$.place, "", std::to_string(nextquad + 2));
    emit("goto", "", "", std::to_string(nextquad + 1));
};
| arthlogicexpr DIV_KW arthlogicexpr
{
    fprintf(fout, "Rule 78 \t\t arthlogicexpr -> arthlogicexpr DIV_KW arthlogicexpr \n");
    $$.place = newTemp($1.type, false);
    $$.truelist = makelist(nextquad + 1);
    $$.falselist = makelist(nextquad + 2);
    emit("-", $1.place, $3.place, $$.place);
    emit("ifgoto", $$.place, "", std::to_string(nextquad + 2));
    emit("goto", "", "", std::to_string(nextquad + 1));
};
| arthlogicexpr MOD_KW arthlogicexpr
{
    fprintf(fout, "Rule 78 \t\t arthlogicexpr -> arthlogicexpr MOD_KW arthlogicexpr \n");
    $$.place = newTemp($1.type, false);
    $$.truelist = makelist(nextquad + 1);
    $$.falselist = makelist(nextquad + 2);
    emit("%", $1.place, $3.place, $$.place);
    emit("ifgoto", $$.place, "", std::to_string(nextquad + 2));
    emit("goto", "", "", std::to_string(nextquad + 1));
};

unaryexpr :  unaryop unaryexpr
{
    if ($1.type == TYPE_UNKNOWN) {
        $$.place = newTemp($2.type, false);
        $$.type = $2.type;
        $$.truelist = $2.truelist;
        $$.falselist = $2.falselist;
        emit($1.place, $2.place, "", $$.place);
    }
    else {
        $$.place = newTemp($1.type, false);
        $$.type = $1.type;
        $$.truelist = makelist(nextquad + 1);
        $$.falselist = makelist(nextquad + 2);
        emit($1.place, $2.place, "", $$.place);
        emit("ifgoto", $$.place, "", std::to_string(nextquad + 2));
        emit("goto", "", "", std::to_string(nextquad + 1));

    }
    fprintf(fout, "Rule 84 \t\t unaryexpr ->  unaryop unaryexpr \n");
};
| opera
{
    $$.type = $1.type;
    $$.place = $1.place;
    $$.truelist = $1.truelist;
    $$.falselist = $1.falselist;
    fprintf(fout, "Rule 85 \t\t unaryexpr ->  opera \n");
};

unaryop : MINUS_KW
{
    fprintf(fout, "Rule 86 \t\t unaryop -> - \n");
    $$.place = new char[10];
    $$.type = TYPE_UNKNOWN;
    strcpy($$.place,"usub");
};
| MULT_KW
{
    fprintf(fout, "Rule 87 \t\t unaryop -> * \n");
    $$.place = new char[10];
    $$.type = TYPE_INT;
    strcpy($$.place,"asterisk");
};
| QUEST_MARK
{
    fprintf(fout, "Rule 88 \t\t unaryop -> ? \n");
    $$.place = new char[10];
    $$.type = TYPE_INT;
    strcpy($$.place,"quest");
};

opera : variable
{
    fprintf(fout, "Rule 89 \t\t opera -> variable \n");
    $$.place = $1.place;
};
| unvar
{
    fprintf(fout, "Rule 90 \t\t opera -> unvar \n");
    $$.type = $1.type;
    $$.place = $1.place;
    $$.truelist = $1.truelist;
    $$.falselist = $1.falselist;
};

variable : idetifier_type
{
    fprintf(fout, "Rule 91 \t\t variable -> idetifier_type \n");
    symbolTableEntry* temp = symbolTableLookup($1.place);
    if (temp == nullptr) {
      printf("%d : Error! %s is not declared.\n", yylineno, $1.place);
    } else {
        $$.place = $1.place;
        $$.type  = temp->type;
        $$.truelist = makelist(nextquad + 1);
        $$.falselist = makelist(nextquad + 2);
        emit("ifgoto", $$.place, "", std::to_string(nextquad + 2));
        emit("goto", "", "", std::to_string(nextquad + 1));
    }
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
    $$.type = $2.type;
    $$.place = $2.place;
    $$.truelist = $2.truelist;
    $$.falselist = $2.falselist;
};
| call
{
    fprintf(fout, "Rule 95 \t\t unvar -> call \n");
};
| constant
{
    fprintf(fout, "Rule 96 \t\t unvar : constant \n");
    $$.type = $1.type;
    $$.place = $1.place;
    $$.truelist = $1.truelist;
    $$.falselist = $1.falselist;
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
    $$.place = $1.place;
    $$.type  = $1.type;

};

constant : int_type
{
    fprintf(fout, "Rule 102 \t\t constant : int_type \n");
    $$.type = $1.type;
    $$.place = $1.place;
    $$.truelist = $1.truelist;
    $$.falselist = $1.falselist;
};
| real_type
{
    fprintf(fout, "Rule 103 \t\t constant : real_type \n");
    $$.type = $1.type;
    $$.place = $1.place;
    $$.truelist = $1.truelist;
    $$.falselist = $1.falselist;
};
| char_type
{
    fprintf(fout, "Rule 104 \t\t constant : char_type \n");
    $$.type = $1.type;
    $$.place = $1.place;
    $$.truelist = $1.truelist;
    $$.falselist = $1.falselist;
};
| bool_type
{
    fprintf(fout, "Rule 105 \t\t constant : bool_type \n");
    $$.type = $1.type;
    $$.place = $1.place;
    $$.truelist = $1.truelist;
    $$.falselist = $1.falselist;
};

int_type : INT_NUM {
    fprintf(fout, "Rule 106 \t\t int_type : INT_NUM \n");

    $$.type = TYPE_INT;
    $$.place = newTemp(TYPE_INT,false);
    $$.truelist = makelist(nextquad + 1);
    $$.falselist = makelist(nextquad + 2);
    emit("=", std::to_string(lexNum), "", $$.place);
    emit("ifgoto", $$.place, "", std::to_string(nextquad + 2));
    emit("goto", "", "", std::to_string(nextquad + 1));
};

real_type : REAL_NUM {
    fprintf(fout, "Rule 107 \t\t real_type : REAL_NUM \n");

    $$.type = TYPE_REAL;
    $$.place = newTemp(TYPE_REAL,false);
    $$.truelist = makelist(nextquad + 1);
    $$.falselist = makelist(nextquad + 2);
    emit("=", std::to_string(lexReal), "", $$.place);
    emit("ifgoto", $$.place, "", std::to_string(nextquad + 2));
    emit("goto", "", "", std::to_string(nextquad + 1));
};

char_type : CHAR_CONSTANT {

    fprintf(fout, "Rule 108 \t\t char_type : CHAR_CONSTANT \n");
    $$.type = TYPE_CHAR;
    $$.place = newTemp(TYPE_CHAR,false);
    $$.truelist = makelist(nextquad + 1);
    $$.falselist = makelist(nextquad + 2);
    emit("=", std::string(lexChar), "", $$.place);
    emit("ifgoto", $$.place, "", std::to_string(nextquad + 2));
    emit("goto", "", "", std::to_string(nextquad + 1));
};

bool_type : BOOL_CONSTANT_FALSE {

    fprintf(fout, "Rule 109 \t\t bool_type : BOOL_CONSTANT_FALSE \n");
    $$.type = TYPE_BOOL;
    $$.place = newTemp(TYPE_BOOL,false);
    $$.truelist = makelist(nextquad + 1);
    $$.falselist = makelist(nextquad + 2);
    emit("=", "0", "", $$.place);
    emit("ifgoto", $$.place, "", std::to_string(nextquad + 2));
    emit("goto", "", "", std::to_string(nextquad + 1));

};
| BOOL_CONSTANT_TRUE {

    fprintf(fout, "Rule 110 \t\t bool_type : BOOL_CONSTANT_TRUE \n");
    $$.type = TYPE_BOOL;
    $$.place = newTemp(TYPE_BOOL,false);
    $$.truelist = makelist(nextquad + 1);
    $$.falselist = makelist(nextquad + 2);
    emit("=", "1", "", $$.place);
    emit("ifgoto", $$.place, "", std::to_string(nextquad + 2));
    emit("goto", "", "", std::to_string(nextquad + 1));
}


idetifier_type : IDENTIFIER {
    fprintf(fout, "Rule 111 \t\t idetifier_type : IDENTIFIER \n");
    $$.place = lexID;
    $$.type  = TYPE_UNKNOWN;
};

M : /* empty */
{
fprintf(fout, "Rule 112 \t\t M : empty \n");
$$.quad = nextquad;
};

%%

void handle(int signal) {
    fclose(fout);
    exit(1);
}

int main() {

    signal(11, handle);
    signal(SIGINT, handle);
    signal(SIGABRT, handle);
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
