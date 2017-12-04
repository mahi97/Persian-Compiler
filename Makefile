all : lex parse compiler run
debug : lex parser-debug compiler run

parse :
	bison -d parser.y

parser-debug :
	bision --verbose -d parser.y

compiler:
	g++ -std=c++14 lex.yy.c  parser.tab.h parser.tab.c -o parser.out

lex : lex.lex
	flex lex.lex

run :
	./parser.out

clean :
	rm -rf parser.out lex.o lex.c output.txt parser.tab.h parser.tab.c lex.yy.c parser.output
