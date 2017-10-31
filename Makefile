
main : lex.o
	cc -o main lex.o -ll

lex.o : lex.c
	cc -c -o lex.o lex.c

lex.c : lexer.lex
	lex -t lex.lex > lex.c

clean :
	rm -rf main lex.o lex.c
