#include "ast.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <limits.h>
#include <stdarg.h>
#include <float.h>

node* newNode(char *id,char *value,int linha,int coluna){

	node *newNode;
	newNode = (node*)malloc(sizeof(node));


	if(newNode == 0){
		printf("ERROR ALLCOATING MEMORY, EXITING\n");
		exit(0);
	}

	newNode->id = (char*)strdup(id);
	

	if(newNode->id == 0){
		printf("ERROR ALLCOATING MEMORY, EXITING\n");
		exit(0);
	}
	
	newNode->value = NULL;
	
	if(value != NULL){
		newNode->value = (char*)strdup(value);

		if(newNode->id == 0){
			printf("ERROR ALLCOATING MEMORY, EXITING\n");
			exit(0);
		}
	}
	newNode->children = NULL;
	newNode->brother = NULL;
	newNode->linha = linha;
	newNode->coluna=coluna;
	return newNode;
}

void putChildren (node *father,node *son){
	if(father == NULL || son == NULL) return;
	father->children = son;
}

void putBrothers(node *bigBrother,node *smallBrother){
	if(bigBrother == NULL || smallBrother == NULL) return;
	while(bigBrother->brother != NULL){
		bigBrother = bigBrother -> brother;
	}
	bigBrother -> brother = smallBrother;
}
void freeToken( node *token){
	if(token == NULL) return;
	if(token->value != NULL)
		free((char*)token->value);
	if(token->id != NULL)
		free((char*)token->id);
	free(token);
}
void printAST(node *root,int nPontos) {
	if(root == NULL) return ;
	if(root->value != NULL) {
		for(int i = 0; i<nPontos;i++){
			printf(".");
		}
		printf("%s(%s)\n",root->id,root->value);
	}
	else if(root->value == NULL){
		for(int i = 0; i<nPontos;i++){
			printf(".");
		}
		printf("%s\n",root->id);
	}
	else {

	}
	printAST(root->children,nPontos+2);
	printAST(root->brother,nPontos);

}

void deletAST(node *root){
	if(root != NULL){
		if(root->children != NULL){
				deletAST(root->children);
		}
		if(root -> brother != NULL){
				deletAST(root->brother);
		}
		freeToken(root);
	}
}
void typeSpec(node *type,node *list){
	node * aux;
	
	while(list != NULL){
		aux  = newNode(type->id, type->value);
		putBrothers(aux, list->children);
		putChildren(list, aux);
		list = list->brother;
	}

}

