%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lex.yy.c"
#include "cleanBuffer.c"
FILE *arqc;
FILE *arqh;

%}
%union {
	char *strval;
}

%token <strval>COMPARATOR
%token <strval>SYSTEMTOK 				
%token <strval>OUTTOK 						
%token <strval>PRINTLNTOK 					
%token <strval>QUOTE 	
%token <strval>INT
%token <strval>DOUBLE
%token <strval>CHAR
%token <strval>FLOAT
%token <strval>CLASS
%token <strval>IF
%token <strval>ELSE
%token <strval>ELSEIF
%token <strval>NUMBER
%token <strval> NAME
%token <strval>NAMECLASS
%token <strval>QUOTEDTEXT
%token <strval>DOT
%token <strval>DOTCOMMA
%token <strval>COMMA
%token <strval>OPARENTHESES
%token <strval>EPARENTHESES
%token <strval>OBRACKET
%token <strval>EBRACKET

%{
char str1 [1000];
char buffer [1000];
%}

%%

inicio:
	
	|inicio print
	|inicio class
	|inicio chamada_metodo_estatico
	|inicio chamada_metodo_parametro
	|inicio chamada_metodo
	|inicio metodo
	|inicio if_rule
	|inicio ready_parameters_list
	|inicio typevariable
	|inicio typeparameter
	|inicio name_recursive
	|inicio typeparameter //tem que ser tirado
	|inicio parameters //tem que ser tirado
	|inicio	parameters_list //tem que ser tirado
	|inicio	string //tem que ser tirado
;

print:
	| SYSTEMTOK DOT OUTTOK DOT PRINTLNTOK OPARENTHESES string EPARENTHESES DOTCOMMA//ver com o professor pra pegar o que tiver entre os 
	{
	char *javaprint = (char *) malloc(1 + strlen($<strval>6)+ strlen($<strval>7)+ strlen($<strval>8)+ strlen($<strval>9) );
	strcpy(javaprint,"printf");	
	strcat(javaprint,$<strval>6);
	strcat(javaprint,$<strval>7);
	strcat(javaprint,$<strval>8);
	strcat(javaprint,$<strval>9);	
	printf("javaprint reconhecido reconhecido %s\n", javaprint);
	//fprintf(arqh,"%s\n", javaprint);
	$<strval>$ = javaprint;
	}
;

class:
	CLASS NAMECLASS OBRACKET class_content EBRACKET
	{
		printf("reconheceu o class\n");
		strcpy(buffer, yytext);
		fprintf(arqh,"typedef struct %s%s\n%s\n%s_%s\n",$2,$3,$<strval>4,$5,$2);
	}
;

class_content:
	variables 
	{
	$<strval>$ = $<strval>1;
	}
	|metodo
	{
	$<strval>$ = $<strval>1;	
	}
	|variables metodo
	{
	char *classcontent = (char *) malloc(1 + strlen($<strval>1)+ strlen($<strval>2) );
	strcpy(classcontent,$<strval>1);
	strcat(classcontent,$<strval>2);
	printf("%s do classcontent\n",classcontent);
	//fprintf(arqh,"%s ",parameterstr);
	$<strval>$ = classcontent; 		
	printf("classcontent reconhecido\n");	
	}
;


variables:
	typevariable
	{
	$<strval>$ = $<strval>1;
	}	
	|variables typevariable
	{
	char *variable = (char *) malloc(1 + strlen($<strval>1)+ strlen($<strval>2));
	strcpy(variable,$<strval>1);
	strcat(variable,"\n");
	strcat(variable,$<strval>2);	
	strcat(variable,"\n");
	$<strval>$ = variable;
	}
;

chamada_metodo_estatico:
	NAMECLASS DOT chamada_metodo ready_parameters_list
	{
		printf("reconheceu a chamada de metodo estático com parametros\n");			
	}
;

if_rule:
	IF OPARENTHESES id COMPARATOR id EPARENTHESES OBRACKET if_content EBRACKET
	{
	char *ifrule = (char *) malloc(1 + strlen($<strval>1)+ strlen($<strval>2)+ strlen($<strval>3)+
	strlen($<strval>4)+ strlen($<strval>5)+ strlen($<strval>6)+ strlen($<strval>7)+ strlen($<strval>8)+
	strlen($<strval>9));
	strcpy(ifrule,$<strval>1);
	strcat(ifrule,$<strval>2);
	strcat(ifrule,$<strval>3);
	strcat(ifrule,$<strval>4);
	strcat(ifrule,$<strval>5);
	strcat(ifrule,$<strval>6);
	strcat(ifrule,$<strval>7);
	strcat(ifrule,"\n");
	strcat(ifrule,$<strval>8);
	strcat(ifrule,"\n");
	strcat(ifrule,$<strval>9);
	printf("ifrule reconhecido reconhecido %s\n", ifrule);
	//fprintf(arqh,"%s\n", ifrule);
	$<strval>$ = ifrule;
	}

;

if_content:
	print
	{
	$<strval>$ = $<strval>1;
	}
;

id:
	NAME
	{
	$<strval>$ = $1;
	}
	|NUMBER
	{
	$<strval>$ = $1;
	}
;

chamada_metodo_parametro:
	chamada_metodo ready_parameters_list
	{
		printf("reconheceu a chamada de metodos com parametros\n");			
	}
;

chamada_metodo:
	NAME DOT NAME 
	{
		printf("reconheceu a chamada de metodos\n");			
	}
	|NAME DOT chamada_metodo
	{
		printf("reconheceu a chamada de metodos\n");			
	}
;

string:
	QUOTEDTEXT 

	{ 
	$<strval>$ = $1;
	printf("string reconhecida %s\n",$1);
	}
;


metodo:
	typeparameter ready_parameters_list OBRACKET if_rule EBRACKET
	
	{
	char *methodc = (char *) malloc(1 + strlen($<strval>1)+ strlen($<strval>2)+ strlen($<strval>3)+
	strlen($<strval>4)+ strlen($<strval>5));
	strcpy(methodc,$<strval>1);
	strcat(methodc,$<strval>2);
	strcat(methodc,"\n");
	strcat(methodc,$<strval>3);
	strcat(methodc,"\n");
	strcat(methodc,$<strval>4);
	strcat(methodc,"\n");
	strcat(methodc,$<strval>5);
	printf("metodo reconhecido reconhecido %s\n", methodc);
	fprintf(arqc,"%s\n", methodc);
	$<strval>$ = methodc;
	//inserir no .h
	char *methodh = (char *) malloc(1 + strlen($<strval>1)+ strlen($<strval>2));
	strcpy(methodh,$<strval>1);
	strcat(methodh,$<strval>2);
	fprintf(arqh,"%s\n", methodh);	
	}
	|NAME ready_parameters_list
	{
	char *method = (char *) malloc(1 + strlen($<strval>1)+ strlen($<strval>2) );
	strcpy(method,$<strval>1);
	strcat(method,$<strval>2);
	printf("%s do method\n",method);
	fprintf(arqh,"%s ",method);
	$<strval>$ = method; 		
	printf("metodo reconhecido\n");
	}
;

ready_parameters_list:
	OPARENTHESES parameters_list EPARENTHESES
	{
	char *readyparameters = (char *) malloc(1 + strlen($<strval>1)+ strlen($<strval>2)+ strlen($<strval>3));
	strcpy(readyparameters,$<strval>1);
	strcat(readyparameters,$<strval>2);
	strcat(readyparameters,$<strval>3);	
	printf("multiple ready parameter list reconhecido %s\n", readyparameters);
	//fprintf(arqh,"%s\n",readyparameters);
	$<strval>$ = readyparameters;
	}
;

parameters_list:
	parameters
	{	
	$<strval>$ = $<strval>1;
	printf("parameter list reconhecido %s\n",$<strval>1);
	}	
	|parameters_list COMMA parameters
	{
	char *recursiveparameters = (char *) malloc(1 + strlen($<strval>1)+ strlen($<strval>2)+ strlen($<strval>3));
	strcpy(recursiveparameters,$<strval>1);
	strcat(recursiveparameters,$<strval>2);
	strcat(recursiveparameters,$<strval>3);	
	printf("multiple parameter list reconhecido %s\n", $<strval>1);
	//fprintf(arqh,"%s\n",recursiveparameters);
	$<strval>$ = recursiveparameters;
	}
;

parameters:

	typeparameter
	{
	$<strval>$ = $<strval>1;
	printf("type parameter reconhecido %s\n", $<strval>1);
	}
	|NAME
	{
	$<strval>$ = $<strval>1;
	printf("NAME reconhecido\n");
	}
;

typevariable:
	inttypevariable
	{
	$<strval>$ = $<strval>1;
	}
	|doubletypevariable
	{
	$<strval>$ = $<strval>1;
	}	
	|chartypevariable
	{
	$<strval>$ = $<strval>1;
	}
	|floattypevariable
	{
	$<strval>$ = $<strval>1;
	}
;

inttypevariable:
	INT NAME DOTCOMMA
	{
	 fprintf(arqc,"%s %s%s\n",$1,$2,$3);
	char *variablestr = (char *) malloc(1 + strlen($1)+ strlen($2)+ strlen($3));
	strcpy(variablestr,$1);
	strcat(variablestr,$2);
	strcat(variablestr,$3);
	printf("%s do inttyvariables\n",variablestr);
	//fprintf(arqh,"%s ",parameterstr);
	$<strval>$ = variablestr; 
	}
;

doubletypevariable:
	DOUBLE NAME DOTCOMMA
	{
	fprintf(arqc,"%s %s%s\n",$1,$2,$3);
	char *variablestr = (char *) malloc(1 + strlen($1)+ strlen($2)+ strlen($3));
	strcpy(variablestr,$1);
	strcat(variablestr,$2);
	strcat(variablestr,$3);
	printf("%s do doubletyvariables\n",variablestr);
	//fprintf(arqh,"%s ",parameterstr);
	$<strval>$ = variablestr; 
	}
;

chartypevariable:
	CHAR NAME DOTCOMMA
	{
	fprintf(arqc,"%s %s%s\n",$1,$2,$3);
	char *variablestr = (char *) malloc(1 + strlen($1)+ strlen($2)+ strlen($3));
	strcpy(variablestr,$1);
	strcat(variablestr,$2);
	strcat(variablestr,$3);
	printf("%s do chartyvariables\n",variablestr);
	//fprintf(arqh,"%s ",parameterstr);
	$<strval>$ = variablestr;
	}
;
	
floattypevariable:
	FLOAT NAME DOTCOMMA
	{
	fprintf(arqc,"%s %s%s\n",$1,$2,$3);
	char *variablestr = (char *) malloc(1 + strlen($1)+ strlen($2)+ strlen($3));
	strcpy(variablestr,$1);
	strcat(variablestr,$2);
	strcat(variablestr,$3);
	printf("%s do floattyvariables\n",variablestr);
	//fprintf(arqh,"%s ",parameterstr);
	$<strval>$ = variablestr;
	}
;

typeparameter:
	inttypeparameter
	{
	$<strval>$ = $<strval>1;
	printf("%s do typeparameter\n",$<strval>1);
	}	
	|doubletypeparameter
	|chartypeparameter
	|floattypeparameter
;

inttypeparameter:
	INT NAME
	{
	//printf("%s %s ", $1,$2);
	char *parameterstr = (char *) malloc(1 + strlen($1)+ strlen($2) );
	strcpy(parameterstr,$1);
	strcat(parameterstr,$2);
	printf("%s do inttypeparameter\n",parameterstr);
	//fprintf(arqh,"%s ",parameterstr);
	$<strval>$ = parameterstr; 
	}
;

doubletypeparameter:
	DOUBLE NAME
	{
	printf("DOUBLE NAME reconhecido\n");
	char *parameterstr = (char *) malloc(1 + strlen($1)+ strlen($2) );
	strcpy(parameterstr,$1);
	strcat(parameterstr,$2);
	printf("%s\n",parameterstr);
	//fprintf(arqh,"%s ",parameterstr);
	$<strval>$ = parameterstr; 	
	}
;

chartypeparameter:
	CHAR NAME
	{
	printf("CHAR NAME reconhecido\n");
	char *parameterstr = (char *) malloc(1 + strlen($1)+ strlen($2) );
	strcpy(parameterstr,$1);
	strcat(parameterstr,$2);
	printf("%s\n",parameterstr);
	//fprintf(arqh,"%s ",parameterstr);
	$<strval>$ = parameterstr; 
	}
	
;

floattypeparameter:
	FLOAT NAME
	{
	printf("FLOAT NAME reconhecido\n");
	char *parameterstr = (char *) malloc(1 + strlen($1)+ strlen($2) );
	strcpy(parameterstr,$1);
	strcat(parameterstr,$2);
	printf("%s\n",parameterstr);
	//fprintf(arqh,"%s ",parameterstr);
	$<strval>$ = parameterstr; 
	}
;

name_recursive:
	NAME
	|name_recursive COMMA NAME
;

%%

int yywrap(void){
	return 1;
}

int yyerror(char *s){
	printf("%s\n", s);
}

int main(int argc, char** argv){
	
	FILE *input = fopen("Aluno.java", "r");
	if(!input){
		fprintf(stderr,"arquivo nao encontrado");
		return -1;
	}
	yyin = input;
	do{
		arqc = fopen ("teste.c","w");//criar arquivo com permissão de escrita
		arqh = fopen ("teste.h","w");//criar arquivo com permissão de escrita
		fflush (arqc);//limpa o buffer 
		fflush (arqh);//limpa o buffer 
	
		fprintf(arqc, "#include <stdio.h> \n");
		fprintf(arqc, "#include <stdlib.h> \n");
		fprintf(arqc, "int main (){ \n");

		yyparse();

		fprintf(arqc, "\n}");

		fclose(arqc);//nao pode mais escrever
		fclose(arqh);//nao pode mais escreve	

	}while(!feof(yyin));

	return 0;

}

