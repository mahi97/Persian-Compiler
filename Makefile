all : lex parse compiler run
debug : lex parser-debug compiler run

parse :
	bison -d parser.y

parser-debug :
	bison --verbose -d parser.y

compiler:
	clang++ -std=c++14 lex.yy.c llist.cpp llist.h parser.tab.h parser.tab.c

lex : lex.lex
	flex lex.lex

run :
	./a.out

clean :
	rm -rf a.out lex.o lex.c output.txt parser.tab.h parser.tab.c lex.yy.c parser.output
