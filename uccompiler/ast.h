#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <ctype.h>

typedef struct  node{
	char *id;
	char *value;
	struct  node *brother;
	struct  node *children;
	int linha,coluna;
}node;

node* newNode(char *id,char *value,int linha,int coluna);
void putChildren(node *father,node *son);
void putBrothers(node *bigBrother,node *smallBrother);
void freeToken(node *token);
void printAST(node *root,int nPontos);
void deletAST(node *root);
void typeSpec(node *type,node *list);