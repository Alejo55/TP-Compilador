%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
#include "Lista.h"

#define LONG_MAX_ID 30
#define LONG_MAX_STRING 40
#define ENT_MIN -32768
#define ENT_MAX 32767
#define MY_FLT_MIN -3.40282347e38
#define MY_FLT_MAX 3.40282347e38

t_lista lista;

int verificarRangoEntero(char* ptr);
int verificarRangoReal(char* ptr);
int verificarLongitudString(char* ptr);
int verificarLongitudID(char *ptr);

void crearListaTS();
void agregarLexema(char *simboloNombre, char* tipoDato, char* valor, char* longitud);
void agregarLexemaString(char *simboloNombre);
void agregarLexemaNum(char* simboloNombre);

void errorLexico();

%}


/* SECCION DE OPCIONES */
%option noyywrap
%option yylineno


/* SECCION CONJUNTOS Y REGEX */
DIGITO              [0-9]
DIGITONOZERO        [1-9]
LETRAMINUS          [a-z]
LETRAMAYUS          [A-Z]
GUION_BAJO          ["_"]
PUNTO               ["."]

/* Id y Constantes */
ID                  {LETRAMINUS}({LETRAMINUS}|{LETRAMAYUS}|{DIGITO}|{GUION_BAJO})*
CONST_ENT           (-?{DIGITONOZERO}{DIGITO}*)|0
CONST_REAL          -?(({DIGITO}+{PUNTO}{DIGITO}*)|({DIGITO}*{PUNTO}{DIGITO}+))
CONST_STR           \"[^"]*\"

/* Operadores */
OP_ASIG             ":="
OP_SUM              "+"
OP_RES              "-"
OP_MUL              "*"
OP_DIV              "/"
OP_COMP_IGUAL       "=="
OP_COMP_DIST        "<>"
OP_COMP_MAYOR       ">"
OP_COMP_MAYOR_IG    ">="
OP_COMP_MENOR       "<"
OP_COMP_MENOR_IG    "<="
OP_AND              "AND"
OP_OR               "OR"
OP_NOT              "NOT"

/* Caracteres de apertura, de cierre y otros */
LLAVE_A             "{"
LLAVE_C             "}"
CORCHETE_A          "["
CORCHETE_C          "]"
PAR_A               "("
PAR_C               ")"
COMA                ","
DOS_PUNTOS          ":"

/* Palabras reservadas */
INIT                "init"
MIENTRAS            "mientras"   
SI                  "si"
SINO                "sino"
ESCRIBIR            "escribir"
LEER                "leer"
T_FLOAT             "Float"
T_INT               "Int"
T_STRING            "String"
CONTAR_PRIMOS       "ContarPrimos"
UNTIL_LOOP          "UntilLoop"

/* Comentarios */ 
COMENTARIO          "*-"[^-]*"-*"
COMENTARIO_ANIDADO  "*-"[^-]*{COMENTARIO}[^-]*"-*"


/* SECCION REGLAS */
%%

{INIT}              {crearListaTS(); return INIT;}
{MIENTRAS}          {return MIENTRAS;}   
{SI}                {return SI;}
{SINO}              {return SINO;}
{ESCRIBIR}          {return ESCRIBIR;}
{LEER}              {return LEER;}
{T_FLOAT}           {return T_FLOAT;}
{T_INT}             {return T_INT;}
{T_STRING}          {return T_STRING;}
{CONTAR_PRIMOS}     {return CONTAR_PRIMOS;}
{UNTIL_LOOP}        {return UNTIL_LOOP;}

{OP_ASIG}           {return OP_ASIG;}
{OP_SUM}            {return OP_SUM;}
{OP_RES}            {return OP_RES;}
{OP_MUL}            {return OP_MUL;}
{OP_DIV}            {return OP_DIV;}
{OP_COMP_IGUAL}     {return OP_COMP_IGUAL;}
{OP_COMP_DIST}      {return OP_COMP_DIST;}
{OP_COMP_MAYOR}     {return OP_COMP_MAYOR;}
{OP_COMP_MAYOR_IG}  {return OP_COMP_MAYOR_IG;}
{OP_COMP_MENOR}     {return OP_COMP_MENOR;}
{OP_COMP_MENOR_IG}  {return OP_COMP_MENOR_IG;}
{OP_AND}            {return OP_AND;}
{OP_OR}             {return OP_OR;}
{OP_NOT}            {return OP_NOT;}

{LLAVE_A}           {return LLAVE_A;}
{LLAVE_C}           {return LLAVE_C;}
{CORCHETE_A}        {return CORCHETE_A;}
{CORCHETE_C}        {return CORCHETE_C;}
{PAR_A}             {return PAR_A;}
{PAR_C}             {return PAR_C;}
{COMA}              {return COMA;}
{DOS_PUNTOS}        {return DOS_PUNTOS;}

{CONST_ENT}         {verificarRangoEntero(yytext); agregarLexemaNum(yytext); return CONST_ENT;}
{CONST_REAL}        {verificarRangoReal(yytext); agregarLexemaNum(yytext); return CONST_REAL;}
{CONST_STR}         {verificarLongitudString(yytext); agregarLexemaString(yytext); return CONST_STR;}

{ID}                {verificarLongitudID(yytext); agregarLexema(yytext, "", "",""); return ID;}

{COMENTARIO_ANIDADO}   
{COMENTARIO}  

"\n"      		
"\t"
"\n\t"
" "             		
"\r\n"
.                   errorLexico(); 

%%


/* SECCION CODIGO */

int verificarRangoEntero(char* ptr)
{
    int value = atoi(ptr);
    if (value < ENT_MIN || value > ENT_MAX)
    {
        printf("\nERROR: Constante entera fuera de rango: %s\n", yytext);
        exit(1);
    }
    return 0;
}

int verificarRangoReal(char* ptr)
{
    float value = atof(ptr);
    if (value < MY_FLT_MIN || value > MY_FLT_MAX)
    {
        printf("\nERROR: Constante real fuera de rango: %s\n", yytext);
        exit(1);
    }
    return 0;
}

int verificarLongitudString(char* ptr)
{
    int longitud = strlen(ptr) - 2; // - 2 para desestimar comillas.
    if (longitud > LONG_MAX_STRING)
    {
        printf("\nERROR: Longitud maxima de String superada (%d): %s\n", LONG_MAX_STRING, yytext);
        exit(1);
    }
    return 0;
}

int verificarLongitudID(char *ptr)
{
    int longitud = strlen(ptr);
    if (longitud > LONG_MAX_ID)
    {
        printf("\nERROR: Longitud maxima de ID superada (%d): %s\n", LONG_MAX_ID, yytext);
        exit(1);
    }
    return 0;
}

void crearListaTS()
{
    crearLista(&lista);
}

void agregarLexemaString(char *simboloNombre)
{
    int longitud;
    char nombreString[100];
    char valor[100];
    char strLongitud[3];
    int j=0, i=0, ocurrencias=0;

    // Copiar el guión bajo al inicio de nombreString
    nombreString[0] = '_';
    nombreString[1] = '\0';    

    while(ocurrencias < 2 )
    {
        if(simboloNombre[i] != '"')
        {
            valor[j]= simboloNombre[i];
            j++;
        }
        else
            ocurrencias++;

        i++;
    }
    valor[j] = '\0';

    strcat(nombreString, valor);
    longitud = strlen(valor);
    sprintf(strLongitud, "%d", longitud);

    agregarLexema(nombreString, "", valor, strLongitud);
}

void agregarLexemaNum(char* simboloNombre)
{
    char nombreNum[100];
    
    nombreNum[0] = '_';
    nombreNum[1] = '\0';
    strcat(nombreNum, simboloNombre);

    agregarLexema(nombreNum, "", simboloNombre, "");
}

void agregarLexema(char *simboloNombre, char *tipoDato, char *valor, char *longitud)
{
    t_lexema lex;
    if( !buscarEnlista(&lista, simboloNombre, &lex) )
    {
        strcpy(lex.nombre, simboloNombre);
        strcpy(lex.tipoDato, tipoDato);
        strcpy(lex.valor, valor);
        strcpy(lex.longitud, longitud);
        insertarFinalLista(&lista, lex);
    }
}

void errorLexico()
{
	printf("\nERROR LEXICO: Caracter no reconocido: %s\n", yytext);
	exit(1);
}