
main : lex.o
	cc -o main lex.o -ll

lex.o : lex.c
	cc -c -o lex.o lex.c

clean :
	rm -rf main lex.o
