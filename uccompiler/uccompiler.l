/*Jorge Martins 2015199193*/
/* Yevgen Zhydkykh 2015236771 */
%{
	#include "y.tab.h"
	#include "ast.h"

	int flag = 0;
	int yacc = 0; 
	int coluna = 1;
	int linha = 1;
	int colunaInicioComent = 1;
	int linhaInicioComent = 1 ;
	int sintaxeError = 0;
	extern node* root;
	
%}

%option nounput
%option noinput
%X COMENTARIOS COMENTARIO UNTERMINATED


NUMERO				[0-9]+
LETRA				[a-z|A-Z]
MAIUSCULAS			[A-Z]
MINUSCULAS			[a-z]
WHITESPACE			[ ]
COMENTARIOM			(.|\n)*
COMENTARIOALINHA			[^\n]*	
RESERVADAS			"["|"]"|"++"|"--"|"auto"|"break"|"case"|"const"|"continue"|"default"|"do"|"enum"|"extern"|"float"|"for"|"goto"|"inline"|"long"|"register"|"restrict"|"signed"|"sizeof"|"static"|"struct"|"switch"|"typedef"|"union"|"unsigned"|"volatile"|"_Bool"|"_Complex"|"_Imaginary"
EXPOENTE			[eE][+-]?{NUMERO}


%%
"/*"							{BEGIN COMENTARIOS;linhaInicioComent = linha;colunaInicioComent = coluna;coluna+=yyleng;}
<COMENTARIOS>("\r"|"\n"|"\r\n"|"\n\r")	{linha++; coluna = 1;}
<COMENTARIOS>"*/"				{BEGIN 0;coluna+=yyleng;}
<COMENTARIOS><<EOF>>			{BEGIN 0;{printf("Line %d, col %d: unterminated comment\n",linhaInicioComent,colunaInicioComent);}}
<COMENTARIOS>.					{coluna+=yyleng;;}

"//"							{BEGIN COMENTARIO;linhaInicioComent = linha;colunaInicioComent = coluna;coluna+=yyleng;}
<COMENTARIO>("\r"|"\n"|"\r\n"|"\n\r")	{BEGIN 0; linha++; coluna = 1;}
<COMENTARIO><<EOF>>				{BEGIN 0;}
<COMENTARIO>.					{coluna+=yyleng;;}


{RESERVADAS}					{coluna+=yyleng; if(flag==1) printf("RESERVED(%s)\n",yytext);if(yacc==1) return RESERVED;}

char 							{coluna+=yyleng; if(flag==1) printf("CHAR\n");if(yacc==1) return CHAR;}
else							{coluna+=yyleng; if(flag==1) printf("ELSE\n");if(yacc==1) return ELSE;}
while							{coluna+=yyleng; if(flag==1) printf("WHILE\n");if(yacc==1) return WHILE;}
if 								{coluna+=yyleng; if(flag==1) printf("IF\n");if(yacc==1) return IF;}
int 							{coluna+=yyleng; if(flag==1) printf("INT\n");if(yacc==1) return INT;}
short 							{coluna+=yyleng; if(flag==1) printf("SHORT\n");if(yacc==1) return SHORT;}
double 							{coluna+=yyleng; if(flag==1) printf("DOUBLE\n");if(yacc==1) return DOUBLE;}
return 							{coluna+=yyleng; if(flag==1) printf("RETURN\n");if(yacc==1) return RETURN;}
void 							{coluna+=yyleng; if(flag==1) printf("VOID\n");if(yacc==1) return VOID;}
{NUMERO}						{coluna+=yyleng; if(flag==1) printf("INTLIT(%s)\n",yytext);if(yacc==1) {yylval.str=(char*)strdup(yytext); return INTLIT;}}
\'[^\n\'\\]\'|\'\\n\'|\'\\t\'|\'\\\\\'|\'\\\'\'|\'\\\"\'|\'\\[0-7]{1,3}\'   						{coluna+=yyleng; if(flag==1) printf("CHRLIT(%s)\n",yytext);if(yacc==1) { yylval.str=(char*)strdup(yytext); return CHRLIT;}}
\'([^\n'\\]|\\.)*\'				{printf("Line %d, col %d: invalid char constant (%s)\n",linha,coluna,yytext);coluna+=yyleng;}
\'								{BEGIN UNTERMINATED;linhaInicioComent = linha;colunaInicioComent = coluna;coluna+=yyleng;}
<UNTERMINATED>[^\t\n\r]			{coluna +=yyleng;;}
<UNTERMINATED>("\t"|" ")			{BEGIN 0;{printf("Line %d, col %d: unterminated char constant\n",linhaInicioComent,colunaInicioComent);coluna +=yyleng;}}
<UNTERMINATED>("\n|\r"|"\r\n")	{BEGIN 0;{printf("Line %d, col %d: unterminated char constant\n",linhaInicioComent,colunaInicioComent);linha++;coluna=1;}}
<COMENTARIOS><EOF>			{BEGIN 0;{printf("Line %d, col %d: unterminated char constant\n",linhaInicioComent,colunaInicioComent);}}							
{NUMERO}"."{NUMERO}?{EXPOENTE}?|"."{NUMERO}{EXPOENTE}?|{NUMERO}{EXPOENTE}				{coluna+=yyleng; if(flag==1) printf("REALLIT(%s)\n",yytext);if(yacc==1) { yylval.str=(char*)strdup(yytext); return REALLIT;}}
[A-Za-z\_][0-9A-Za-z\_]*		{coluna+=yyleng; if(flag==1) printf("ID(%s)\n",yytext);if(yacc==1) { yylval.str=(char*)strdup(yytext); return ID;}}
"&"  							{coluna+=yyleng; if(flag==1) printf("BITWISEAND\n");if(yacc==1) return BITWISEAND;}
"|"  							{coluna+=yyleng; if(flag==1) printf("BITWISEOR\n");if(yacc==1) return BITWISEOR;}
"^"  							{coluna+=yyleng; if(flag==1) printf("BITWISEXOR\n");if(yacc==1) return BITWISEXOR;}
"&&" 							{coluna+=yyleng; if(flag==1) printf("AND\n");if(yacc==1) return AND;}
"="								{coluna+=yyleng; if(flag==1) printf("ASSIGN\n");if(yacc==1)return ASSIGN;}
"*"								{coluna+=yyleng; if(flag==1) printf("MUL\n");if(yacc==1) return MUL;}
","								{coluna+=yyleng; if(flag==1) printf("COMMA\n");if(yacc==1) return COMMA;}
"/"								{coluna+=yyleng; if(flag==1) printf("DIV\n");if(yacc==1) return DIV;}
"=="							{coluna+=yyleng; if(flag==1) printf("EQ\n");if(yacc==1) return EQ;}
">="							{coluna+=yyleng; if(flag==1) printf("GE\n");if(yacc==1) return GE;}
">"								{coluna+=yyleng; if(flag==1) printf("GT\n");if(yacc==1) return GT;}
"{"								{coluna+=yyleng; if(flag==1) printf("LBRACE\n");if(yacc==1) return LBRACE;}
"<="							{coluna+=yyleng; if(flag==1) printf("LE\n");if(yacc==1) return LE;}
"("								{coluna+=yyleng; if(flag==1) printf("LPAR\n");if(yacc==1) return LPAR;}
"<"								{coluna+=yyleng; if(flag==1) printf("LT\n");if(yacc==1) return LT;}
"-"								{coluna+=yyleng; if(flag==1) printf("MINUS\n");if(yacc==1) return MINUS;}
"%"								{coluna+=yyleng; if(flag==1) printf("MOD\n");if(yacc==1) return MOD;}
"!="							{coluna+=yyleng; if(flag==1) printf("NE\n");if(yacc==1) return NE;}
"!"								{coluna+=yyleng; if(flag==1) printf("NOT\n");if(yacc==1) return NOT;}
"||"							{coluna+=yyleng; if(flag==1) printf("OR\n");if(yacc==1) return OR;}
"+"								{coluna+=yyleng; if(flag==1) printf("PLUS\n");if(yacc==1) return PLUS;}
"}"								{coluna+=yyleng; if(flag==1) printf("RBRACE\n");if(yacc==1) return RBRACE;}
")"								{coluna+=yyleng; if(flag==1) printf("RPAR\n");if(yacc==1) return RPAR;}
";"								{coluna+=yyleng; if(flag==1) printf("SEMI\n"); if(yacc==1) return SEMI;}	
"\n"|"\r"|"\r\n"				{linha++;coluna=1;}		;
"\t"							{coluna+=yyleng;yylval.str=(char*)strdup(yytext);}
" "								{coluna+=yyleng;yylval.str=(char*)strdup(yytext);}
<<eof>>							{coluna+=1;return 0;}
 .								{printf("Line %d, col %d: illegal character (%s)\n",linha,coluna,yytext);coluna+=yyleng;}
												

%%
int yywrap(){
	return 1;
}

void yyerror(char *s) {
    sintaxeError=1;
    printf ("Line %d, col %d: %s: %s\n" ,linha,(int)(coluna-yyleng),s , yytext);
}

int main(int argc, char *argv[]){
	if(argc>1){
    if (strcmp(argv[1],"-l")==0){
        flag=1;
        yylex();
    }
    if (strcmp(argv[1],"-t")==0){
    	yacc = 1;
        yyparse();
        if(sintaxeError!=1){
            printAST(root,0);
            }
        }

    }
else{
	yacc = 1 ; 
    yyparse();
	}
	deletAST(root);
	yylex_destroy();
	return 0;

}