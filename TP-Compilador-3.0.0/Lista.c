#include "Lista.h"


void crearLista(t_lista *l)
{
    *l = NULL;
}

int insertarFinalLista(t_lista *l, t_lexema lex)
{
    t_nodo *nue;

    // AVANZAR EN LISTA HASTA EL FINAL
    while(*l)
        l = &(*l)->sig;

    ///RESERVA MEMORIA PARA NUE
    nue = (t_nodo*)malloc(sizeof(t_nodo));
    if(!nue)
        return 0;

    strcpy(nue->lexema.nombre, lex.nombre);
    strcpy(nue->lexema.tipoDato, lex.tipoDato);
    strcpy(nue->lexema.valor, lex.valor);
    strcpy(nue->lexema.longitud, lex.longitud);

    nue->sig = NULL;

    ///ENGANCHE
    *l = nue;

    return 1;
}

int sacarPrimeroLista(t_lista *l, t_lexema *lex)
{
    t_nodo *aux = *l;

    if(!aux)
        return 0;

    *l = aux->sig;
    
    strcpy(lex->nombre, aux->lexema.nombre);
    strcpy(lex->tipoDato, aux->lexema.tipoDato);
    strcpy(lex->valor, aux->lexema.valor);
    strcpy(lex->longitud, aux->lexema.longitud);
    
    free(aux);

    return 1;
}

int buscarEnlista(const t_lista *l, const char *nombre, t_lexema *lex)
{
    while(*l && strcmp( (*l)->lexema.nombre, nombre ) != 0)
    {
        l = &(*l)->sig;
    }

    if (*l)
    {
        strcpy(lex->nombre, (*l)->lexema.nombre);
        strcpy(lex->tipoDato, (*l)->lexema.tipoDato);
        strcpy(lex->valor, (*l)->lexema.valor);
        strcpy(lex->longitud, (*l)->lexema.longitud);
        return 1;
    }
    
    return 0;
}

int listaVacia(const t_lista *l)
{
    return *l == NULL;
}

void vaciarLista(t_lista *l)
{
    t_nodo *elim;

    while(*l)
    {
        elim = *l;
        *l = elim->sig;
        free(elim);
    }
}

void buscarYactualizar(t_lista* lista, const char* nombre, const char* tipo_Dato)
{
    t_nodo* actual = *lista;
    
    while (actual != NULL) {
        if (strcmp(actual->lexema.nombre, nombre) == 0) 
        {
            strcpy(actual->lexema.tipoDato, tipo_Dato);
            return; // Elemento encontrado y actualizado, salir de la función
        }
        actual = actual->sig;
    }
}

void duplicarLista( t_lista *dirListaOriginal, t_lista *dirListaDuplicado )
{
    *dirListaDuplicado=NULL;
    while(*dirListaOriginal != NULL)
    {
        insertarFinalLista( dirListaDuplicado, (*dirListaOriginal)->lexema );
        dirListaOriginal= &((*dirListaOriginal)->sig);
    }
}