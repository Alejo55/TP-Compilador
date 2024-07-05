#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct
{
    char nombre[100];
    char tipoDato[100];
    char valor[100];
    char longitud[100];
}t_lexema;

typedef struct s_nodo
{
    t_lexema lexema;
    struct s_nodo *sig;
}t_nodo;

typedef t_nodo *t_lista;


void crearLista(t_lista *l);

int insertarFinalLista(t_lista *l, t_lexema lex);

int sacarPrimeroLista(t_lista *l, t_lexema *lex);

int buscarEnlista(const t_lista *l, const char *nombre, t_lexema *lex);

int listaVacia(const t_lista *l);

void vaciarLista(t_lista *l);

void buscarYactualizar(t_lista* lista, const char* nombre, const char* tipo_Dato);

void duplicarLista( t_lista *dirListaOriginal, t_lista *dirListaDuplicado );
