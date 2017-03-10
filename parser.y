%{
#include <stdlib.h>
#include <stdio.h>
#include "tab_symboles.h"
#include <string.h>

void yyerror(char *s);
int yylex(void);

//table des instructions
char* instr[256][4];
int ip = 0;

void add_instr3(char* op, char* opr1, char* opr2, char* opr3){
	if (ip < 256) {
		instr[ip][0] = op;
		instr[ip][1] = opr1;
		instr[ip][2] = opr2;
		instr[ip][3] = opr3;
		ip++;
	} else {
		printf("Erreur ! Overflow table instructions ! \n");
		exit(1);
	}
}

void add_instr2(char* op, char* opr1, char* opr2){
	char buf1[5], buf2[5];
	if (ip < 256) {
		instr[ip][0] = op;
		instr[ip][1] = opr1;
		instr[ip][2] = opr2;
		ip++;
	} else {
		printf("Erreur ! Overflow table instructions ! \n");
		exit(1);
	}
}

void add_instruction(char* op, int s1, int s3){
	char* buf = malloc(5); 
	char* buf2 = malloc(5); 
	char* buf3 = malloc(5);
	sprintf(buf, "%d", tab_sym[s1].adr) ; 
	add_instr2("LOAD", "R0", buf); 
	sprintf(buf2, "%d", tab_sym[s3].adr);
	add_instr2("LOAD", "R1", buf2); 
	free_last_tmp(); 
	free_last_tmp();
	add_instr3(op,"R0","R0","R1"); 
	ajout_tmp(); 
	sprintf(buf3, "%d", tab_sym[tmp].adr);
	add_instr2("STORE", buf3, "R0"); 
}

/* Print du tableau (Test)*/
void init_tab(){
	int i, j;
	for (i=0; i<256; i++){
		for (j=0; j<4; j++){
			instr[i][j] = NULL;
		}
	}
}

void print_tab(){
	int i=0, j;
	while (instr[i][0] != NULL){
		for (j=0; j<4; j++){
			if (instr[i][j] != NULL)
				printf("%s ", instr[i][j]);
		}
		printf("\n");
		i++;
	}
}

void save_tab(){
	FILE* fichier;
	fichier = fopen("instrASM.txt","w");
	int i=0, j;
	while (instr[i][0] != NULL){
		for (j=0; j<4; j++){
			if (instr[i][j] != NULL)
				fprintf(fichier, "%s ", instr[i][j]);
		}
		fprintf(fichier, "\n");
		i++;
	}
	fclose(fichier);
}

//les registres
int reg[3]= {0,1,2};
int r=0;

int use_reg(){
	if (r<3){ 
		return reg[r++];
	} else {
		printf("Dépassement nombre de registres !\n");
		exit(1);
	}
}

void free_reg(){
	if (r>0) {
		r--;
	} else {
		printf("Impossible de décrémenter, déjà à 0 ! \n");
		exit(1);
	}
}

void free_all(){
	r = 0;
}


%}
%union 	{int nb; char* str;};
%token 	tInclude tMain tIf tElse tWhile tAo tAf tPo tPf tPv tEqu tVir tStar tPlus tMinus tRet tInt tEquEqu tAnd tOr tConst blancs lettre chiffre tPrint tCo tCf tDot tDiv tNot tInf tSup tInfEqu tSupEqu
%token	<nb>	tNb
%token	<str> tId
%type		<nb>  tAo
%type		<nb>	E
%left		tOr tAnd
%right	tEquEqu
%left		tPlus tMinus
%left		tDiv tStar
%left		tPo tPf
%right	tEqu
%start	Prog						

%%
Prog : Main 
	  | Fonctions Main
     ;
Fonctions : Fonction Fonctions
		  	| /*empty*/ 
			;
Fonction : tInt tId tPo Args tPf Body
		 ;
Main : tInt tMain tPo tPf Body		 
     ;
Args : tInt tId ArgsN
	 	|  /*empty*/ 
		;
ArgsN :	tVir tInt tId ArgsN
	  	|  /*empty*/ 
		;
Body : tAo {$1 = sym;} Instrs Return {sym = $1;} tAf
	 ;
Instrs : Aff tPv Instrs 
	   | Invoc tPv Instrs 
		| If Instrs 
		| Decl tPv Instrs
		| While Instrs 
		| Print Instrs 
		| /*empty*/
	   	;
If : tIf tPo E tPf Body Else
	;
Else : tElse Body 
	 	| /*empty*/
		;
E :  tId					{char* buf = malloc(5); char* buf2 = malloc(5) ;  
  							sprintf(buf, "%d", find_sym($1)); 
							if (tab_sym[find_sym($1)].init == 1){ 
								add_instr2("LOAD", "R0",buf) ; ajout_tmp();
								sprintf(buf2, "%d", tab_sym[tmp].adr);  
								add_instr2("STORE", buf2, "R0"); 
								$$=tab_sym[tmp].adr;
							} else {
								printf("Erreur ! Variable non initialisée !\n");
								exit(1);
							};}
  	
	| tNb					{char* buf = malloc(5); char* buf2 = malloc(5) ; 
							sprintf(buf, "%d", $1); 
							add_instr2("AFC", "R0", buf); ajout_tmp(); 
							sprintf(buf2, "%d", tab_sym[tmp].adr); 
							add_instr2("STORE", buf2, "R0"); 
							$$=tab_sym[tmp].adr;}
	| E tEquEqu E			{add_instruction("EQU", $1, $3); $$=tab_sym[tmp].adr; }
	| E tInf E				{add_instruction("INF", $1, $3); $$=tab_sym[tmp].adr; }
	| E tInfEqu E			{add_instruction("INFE", $1, $3); $$=tab_sym[tmp].adr; }
	| E tSup E				{add_instruction("SUP", $1, $3); $$=tab_sym[tmp].adr; }
	| E tSupEqu E			{add_instruction("SUPEQU", $1, $3); $$=tab_sym[tmp].adr; }
	| Invoc
	| tPo E tPf				{$$=$2;}
	| E tPlus E				{add_instruction("ADD", $1, $3); $$=tab_sym[tmp].adr; }	
	| E tMinus E			{add_instruction("SOU", $1, $3); $$=tab_sym[tmp].adr; }	
	| E tStar E				{add_instruction("MUL", $1, $3); $$=tab_sym[tmp].adr; }		
	| E tDiv E				{add_instruction("DIV", $1, $3); $$=tab_sym[tmp].adr; }	
	;	
While : tWhile tPo E tPf Body	
	  ;	
Invoc : tId tPo Params tPf	
	  ;
Params : E ParamsN
	   	| /*empty*/ 
		;
ParamsN : tVir E ParamsN
		| /*empty*/
		;
Decl : tInt Decl1	Decln
		;
Decl1 : tId 	 			{ajout_sym($1);printf("sym = %d   var stockée = %s\n",sym, tab_sym[sym].id);}

	  	| tId tEqu E		{ajout_sym_init($1);
								char* buf = malloc(5); char* buf2 = malloc(5);
								sprintf(buf, "%d", $3);
								add_instr2("LOAD", "R0", buf); free_last_tmp();
								sprintf(buf2, "%d", find_sym($1));
								add_instr2("STORE", buf2, "R0");}
		;
Decln : tVir Decl1 Decln
		| /*empty*/
		;
Aff : tId tEqu E		{ajout_init($1);
							char* buf = malloc(5); char* buf2 = malloc(5);
							sprintf(buf, "%d", $3);
							add_instr2("LOAD", "R0", buf); free_last_tmp();
							sprintf(buf2, "%d", find_sym($1));
							add_instr2("STORE", buf2, "R0");
							add_instr2("","","");}
	;
Print : tPrint tPo tId tPf tPv	{char* buf = malloc(5); char* buf2 = malloc(5) ;  
				  							sprintf(buf, "%d", find_sym($1)); 
											add_instr2("LOAD", "R0",buf) ; ajout_tmp();
											sprintf(buf2, "%d", tab_sym[tmp].adr);  
											add_instr2("STORE", buf2, "R0"); 
											$$=tab_sym[tmp].adr;}
	  ;
Return : tRet tNb tPv 
	   ;

%%
void yyerror(char *s) {
  	fprintf(stderr, "%s \n", s);
}

int main() {

	printf("Début du parser\n");
	init_tab();
	yyparse();
	printf("\n----------------------------------------------\nDébut print tab\n\n");
	print_tab();
	save_tab();
	return 0;
}
