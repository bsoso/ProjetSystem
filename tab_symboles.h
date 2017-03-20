#ifndef TAB_SYMBOLES_H
#define TAB_SYMBOLES_H

#include <stdlib.h>
#include <stdio.h>

//variables de la table des symboles
// col 1 = id ; col 2 = init ; col 3 = @ ; col 4 = profondeur
struct symbole{
	char* id;
	char init;
	int adr;
	short profondeur;
};

struct symbole tab_sym[256];

//Fonctions partie symbole
int sym;
int getSym();
void setSym(int val);
void ajout_sym(char*);
void ajout_sym_init(char*);
int find_sym(char *);	// retourne l'adresse de l'id passé en paramètre
//void del_sym();
void ajout_init (char*);

//Fonctions partie temporaire
int tmp;
void ajout_tmp();
//int find_tmp(char*);		// retourne l'adresse de l'id passé en paramètre  (Est-il vraiment nécessaire si on travaille uniquement sur la'indice)
void free_last_tmp();






#endif
