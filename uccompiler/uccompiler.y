%{
	#include <stdio.h>
	#include <string.h>
	#include "ast.h"


	int yylex (void);
	void yyerror(char* s);
	extern int yyleng;
	extern int sintaxeError;
	node *root = NULL;
	node *aux = NULL;
	node *auxStatList = NULL;
	node *auxSpecial =  NULL;
	node *auxDeclarator = NULL;
	node *auxFunctionBody = NULL;
	node *auxID = NULL;
	node *typespec = NULL;

%}


%union{
 	int value;
    struct node *paN;
    char* str; 
}

%token <paN> RESERVED
%token <paN> CHAR
%token <paN> WHILE
%token <paN> IF
%token <paN> INT
%token <paN> SHORT
%token <paN> DOUBLE
%token <paN> RETURN
%token <paN> VOID
%token <str> INTLIT
%token <str> CHRLIT 
%token <str> REALLIT
%token <str> ID
%token <paN> BITWISEAND
%token <paN> BITWISEOR
%token <paN> BITWISEXOR
%token <paN> AND
%token <paN> ASSIGN
%token <paN> MUL 
%token <paN> COMMA
%token <paN> DIV
%token <paN> EQ
%token <paN> GE
%token <paN> GT
%token <paN> LBRACE
%token <paN> LE
%token <paN> LPAR
%token <paN> LT
%token <paN> MINUS
%token <paN> MOD
%token <paN> NE 
%token <paN> NOT
%token <paN> OR
%token <paN> PLUS
%token <paN> RBRACE
%token <paN> RPAR
%token <paN> SEMI

%nonassoc NOTELSE
%nonassoc ELSE

%start  Program
%left   COMMA
%right  ASSIGN
%left   OR 
%left   AND 
%left   BITWISEOR
%left   BITWISEXOR
%left   BITWISEAND
%left   EQ NE
%left   LT GT LE GE
%left   PLUS MINUS
%left   MUL DIV MOD
%right  NOT UNARY

%type  <paN> FunctionsAndDeclarations									

%type  <paN> auxFunctionAndDeclarations
%type  <paN> FunctionDefinition
%type  <paN> FunctionBody
%type  <paN> DeclarationsAndStatements
%type  <paN> FunctionDeclaration
%type  <paN> FunctionDeclarator
%type  <paN> ParameterList
%type  <paN> auxParameterList
%type  <paN> ParameterDeclaration
%type  <paN> Declaration
%type  <paN> auxDeclaration
%type  <paN> TypeSpec
%type  <paN> Declarator
%type  <paN> Statement
%type  <paN> ErrorStatement
%type  <paN> auxStat
%type  <paN> Expr
%type  <paN> expr2
%type  <paN> exproc
%type  <paN> Program




%%

Program: FunctionsAndDeclarations  {$$ = root = newNode("Program", NULL,0,0); putChildren($$, $1);}
		;

FunctionsAndDeclarations: 	FunctionDefinition auxFunctionAndDeclarations  {$$ = $1; putBrothers($1, $2);}								
							|FunctionDeclaration auxFunctionAndDeclarations	{$$ = $1; putBrothers($1, $2);}

							|Declaration auxFunctionAndDeclarations	{$$ = $1; putBrothers($1, $2);}						
							;
auxFunctionAndDeclarations:	FunctionDefinition auxFunctionAndDeclarations   	{$$ = $1; putBrothers($1, $2);}
							|FunctionDeclaration auxFunctionAndDeclarations 	{$$ = $1; putBrothers($1, $2);}
							|Declaration auxFunctionAndDeclarations 	{$$ = $1; putBrothers($1, $2);}
																	
							|%empty 										{$$ =NULL;}												
							;

FunctionDefinition:		TypeSpec FunctionDeclarator FunctionBody 	{$$ = newNode("FuncDefinition",NULL,0,0);putChildren($$,$1);																								putBrothers($1,$2);putBrothers($1,$3);}	 				
						;

FunctionBody:	LBRACE RBRACE									{$$ = newNode("FuncBody",NULL,0,0);}
				|LBRACE DeclarationsAndStatements RBRACE		{$$ = newNode("FuncBody",NULL,0,0); putChildren($$, $2);}
				


DeclarationsAndStatements:	Statement DeclarationsAndStatements {if($1){
																	$$ = $1; 
																	putBrothers($1,$2);
																	}
																else{ 
																	$$ = $2;
																	}
																}
							| Declaration DeclarationsAndStatements {$$ = $1; putBrothers($1,$2);}
						

							| Statement 		{$$ = $1;}
								
							| Declaration 		 {$$ = $1;}
						
							;

FunctionDeclaration:	TypeSpec FunctionDeclarator SEMI								{$$ = newNode("FuncDeclaration",NULL,0,0);putChildren($$,$1);		
																					putBrothers($1,$2);}						;

FunctionDeclarator:		ID LPAR ParameterList RPAR											{$$ = newNode("Id",$1,$3->linha,$3->coluna);putBrothers($$,$3);free((char*)$1);}										
						;

ParameterList: 			ParameterDeclaration 								{$$ = newNode("ParamList",NULL,0,0);putChildren($$,$1);}
						|ParameterDeclaration auxParameterList				{$$ = newNode("ParamList",NULL,0,0);putChildren($$,$1)																				;putBrothers($1,$2);}
						;

auxParameterList:	COMMA ParameterDeclaration												{$$ = $2;}					
					|COMMA ParameterDeclaration auxParameterList							{$$ = $2;putBrothers($2,$3);}
					;

ParameterDeclaration :	TypeSpec {$$ = newNode("ParamDeclaration", NULL,0,0); putChildren($$, $1);}
 						|TypeSpec ID {$$ = newNode("ParamDeclaration", NULL,0,0); putChildren($$, $1); auxID = newNode("Id",$2,$2->linha,$2->coluna);putBrothers($1, auxID);free((char*)$2);}
 						;

Declaration:	TypeSpec Declarator SEMI 					{$$ = newNode("Declaration",NULL,0,0);putChildren($$,$1);putBrothers($1,$2);}
				|TypeSpec  Declarator auxDeclaration SEMI	{$$ = newNode("Declaration",NULL,0,0);putChildren($$,$1);putBrothers($1,$2);typeSpec($1,$3);												putBrothers($$,$3);}
				|error SEMI 								{$$ = newNode("NULL",NULL,0,0);}
				;

auxDeclaration:	COMMA Declarator auxDeclaration  	{$$ = newNode("Declaration",NULL,0,0);putChildren($$,$2);putBrothers($$,$3);}
				|COMMA Declarator 					{$$ = newNode("Declaration",NULL,0,0);putChildren($$,$2);}
				;

TypeSpec:	CHAR 											{$$ = newNode("Char",NULL,0,0);}
			| INT 											{$$ = newNode("Int",NULL,0,0);}
			| VOID 											{$$ = newNode("Void",NULL,0,0);}
			| SHORT 										{$$ = newNode("Short",NULL,0,0);}
			| DOUBLE										{$$ = newNode("Double",NULL,0,0);}
			;



Declarator :ID 														{$$ = newNode("Id", $1,$1->linha,$2->coluna);free((char*)$1);}
			|ID ASSIGN Expr											{$$ = newNode("Id", $1,$1->linha,$2->coluna); putBrothers($$, $3);free((char*)$1);}
			;


Statement: 	SEMI													{$$ = NULL;}
			|Expr SEMI												{$$ = $1;}
			|LBRACE RBRACE  										{$$ = NULL;}
			|LBRACE auxStat RBRACE   								{if($2 != NULL && $2->brother !=NULL)
																			 {$$ = newNode("StatList", NULL,0,0); 
																			 putChildren($$,$2);}
																	else{$$ = $2;}
																	}
			|IF LPAR Expr RPAR ErrorStatement %prec NOTELSE  			{
																		$$ = newNode("If",NULL,$1->linha,$1->coluna);
																		putChildren($$,$3);
																		if($5)
																			putBrothers($3,$5);
																		else
																			putBrothers($3,newNode("Null", NULL,0,0));
																		auxSpecial=newNode("Null",NULL,0,0);
																		putBrothers($3,auxSpecial);
																		}
			|IF LPAR Expr RPAR ErrorStatement ELSE  ErrorStatement	{$$ = newNode("If",NULL,$1->linha,$1->coluna);
																	putChildren($$,$3);
																	if($5)
																		putBrothers($3,$5);
																	else
																		putBrothers($3,newNode("Null", NULL0,0));
																	if($7)
																		putBrothers($3,$7);
																	else
																		putBrothers($3,newNode("Null", NULL0,0));
																	}

			|WHILE LPAR Expr RPAR ErrorStatement     				{$$ = newNode("While",NULL,$1->linha,$1->coluna);
																	putChildren($$,$3);
																	if($5)
																		putBrothers($3,$5);
																	else
																		putBrothers($3,newNode("Null", NULL,0,0));
																	}    		
			|RETURN SEMI											{$$ = newNode("Return",NULL,$1->linha,$1->coluna);auxSpecial=newNode("Null",NULL);putChildren(																	$$,auxSpecial);}
			|RETURN Expr SEMI										{$$ = newNode("Return",NULL,$1->linha,$1->coluna);putChildren($$,$2);}
			|LBRACE error RBRACE									{$$ = newNode("Null",NULL,0,0);}

			
			;
ErrorStatement:		Statement       {$$ = $1;}
                    |error SEMI 	{$$ = newNode("NULL",NULL,0,0);}
                    ;

auxStat:	
			auxStat	ErrorStatement    {if( $1 != NULL ){$$ = $1;putBrothers($1,$2);} else {$$ = $2;} }

			|ErrorStatement		{$$ = $1;}										
			;
Expr : Expr COMMA Expr {$$ = newNode("Comma",NULL,$2->linha,$2->coluna);putChildren($$,$1);putBrothers($1,$3);}
		| expr2 {$$=$1;}

expr2:	expr2 ASSIGN expr2 		{$$ = newNode("Store",NULL);putChildren($$,$1);putBrothers($1,$3);}				
		|expr2 PLUS expr2			{$$ = newNode("Add",NULL);putChildren($$,$1);putBrothers($1,$3);}				
		|expr2 MINUS expr2		{$$ = newNode("Sub",NULL);putChildren($$,$1);putBrothers($1,$3);}				
		|expr2 MUL expr2			{$$ = newNode("Mul",NULL);putChildren($$,$1);putBrothers($1,$3);}			
		|expr2 DIV expr2			{$$ = newNode("Div",NULL);putChildren($$,$1);putBrothers($1,$3);}			
		|expr2 MOD expr2			{$$ = newNode("Mod",NULL);putChildren($$,$1);putBrothers($1,$3);}			
		|expr2 OR expr2			{$$ = newNode("Or",NULL);putChildren($$,$1);putBrothers($1,$3);}			
		|expr2 AND expr2			{$$ = newNode("And",NULL);putChildren($$,$1);putBrothers($1,$3);}			
		|expr2 BITWISEAND expr2	{$$ = newNode("BitWiseAnd",NULL);putChildren($$,$1);putBrothers($1,$3);}			
		|expr2 BITWISEOR expr2	{$$ = newNode("BitWiseOr",NULL);putChildren($$,$1);putBrothers($1,$3);}			
		|expr2 BITWISEXOR expr2	{$$ = newNode("BitWiseXor",NULL);putChildren($$,$1);putBrothers($1,$3);}			
		|expr2 EQ expr2			{$$ = newNode("Eq",NULL);putChildren($$,$1);putBrothers($1,$3);}			
		|expr2 NE expr2			{$$ = newNode("Ne",NULL);putChildren($$,$1);putBrothers($1,$3);}			
		|expr2 LE expr2			{$$ = newNode("Le",NULL);putChildren($$,$1);putBrothers($1,$3);}			
		|expr2 GE expr2			{$$ = newNode("Ge",NULL);putChildren($$,$1);putBrothers($1,$3);}			
		|expr2 LT expr2			{$$ = newNode("Lt",NULL);putChildren($$,$1);putBrothers($1,$3);}			
		|expr2 GT expr2			{$$ = newNode("Gt",NULL);putChildren($$,$1);putBrothers($1,$3);}		
		|PLUS expr2	%prec UNARY		{$$ = newNode("Plus",NULL);putChildren($$,$2);}			
		|MINUS expr2 %prec UNARY			{$$ = newNode("Minus",NULL);putChildren($$,$2);}			
		|NOT expr2				{$$ = newNode("Not",NULL);putChildren($$,$2);}
		|ID LPAR  RPAR  		{$$ = newNode("Call", NULL);aux = newNode("Id",$1);putChildren($$,aux);free((char*)$1);}
		|ID LPAR exproc  RPAR	{$$ = newNode("Call", NULL);aux = newNode("Id",$1);putChildren($$,aux);putBrothers(aux,$3);free((char*)$1);}
		|ID  					{$$ = newNode("Id", $1);free((char*)$1);}	
		|INTLIT					{$$ = newNode("IntLit", $1);free((char*)$1);}			
		|CHRLIT					{$$ = newNode("ChrLit", $1);free((char*)$1);}		
		|REALLIT				{$$ = newNode("RealLit", $1);free((char*)$1);}	
		|LPAR Expr RPAR         {$$ = $2;}    				
		|ID LPAR error RPAR 	{$$ = newNode("NULL",NULL);}			
		|LPAR error RPAR  		{$$ = newNode("NULL",NULL);}
		; 


exproc : exproc COMMA expr2 {$$ = $1;putBrothers($1,$3);}
		|expr2 {$$ = $1;}
%%