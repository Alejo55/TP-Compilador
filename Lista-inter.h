#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define TRUE 1
#define FALSE 0

typedef struct s_nodo_l_str{
char cadena[100];
struct s_nodo_l_str *sig;
}t_nodo_l_str;

typedef t_nodo_l_str* t_lista_cod_inter;

void crear_lista_inter (t_lista_cod_inter *dirLista);
int insertar_en_lista_inter (t_lista_cod_inter *dirLista, char *cadena);
int extraer_primero_de_lista_inter ( t_lista_cod_inter *dirLista, char *cadena);
int buscar_y_actualizar_inter ( t_lista_cod_inter *dirLista, int numCelda, char* cadenaReemplazo );
int lista_inter_vacia(t_lista_cod_inter *dirLista);
