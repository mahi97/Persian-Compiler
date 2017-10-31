%{
	int charcount=0,linecount=0;
%}

%%

. charcount++;
\n {linecount++; charcount++;}

%%

int main() {
	yylex();
	printf("There were %d characters in %d lines\n", charcount, linecount);
}
