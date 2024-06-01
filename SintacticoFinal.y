%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "Lista.h"
#include "Lista-inter.h"
#include "Pila.h"


// VARIABLES 
FILE *yyin;

int num_celda_actual=0;
bool operadorOr = false;
bool operadorNot = false;
char branchComparador[10];

t_lexema lexGlobal;

t_lista listaTS;
t_lista_cod_inter listaIntermedia;

t_pila pCeldas;
t_pila pCondicion;
t_pila pId;
t_pila pVar;
t_pila pTipoDatoExp;


// FUNCIONES
int yylex();
int yyerror();

void crearPilas();
int generarCodigoIntermedio();
int volcarTSenArchivo();

void act_Tipodato();

void insertar_en_polaca(char* cadena);
void apilarCelda();
char* desapilarCelda();
void actualizarCelda(char* celdaActualizar, int valor);

int buscarId_en_TS(char* nombre);
void accionSemanticaAsig();
void completarAsignacion();

void guardarBranchComparador(char* branch);
void compararYBranch();
void compararYBranchComb();
void accionSemanticaCmp();

void verificarCondicionYActualizarCelda();
void verificarCondicionYActualizarCeldaSeleccion();

void bifurcacion_sino();
void actualizar_bif_sino();

void verificarTDExp();

void verificarIdUp(char* id1, char* id2);

%}

%union {
	char str_val[100];
}


%token INIT              
%token MIENTRAS          
%token SI                
%token SINO              
%token ESCRIBIR          
%token LEER              
%token T_FLOAT           
%token T_INT            
%token T_STRING     
%token CONTAR_PRIMOS
%token UNTIL_LOOP     

%token OP_ASIG           
%token OP_SUM            
%token OP_RES            
%token OP_MUL            
%token OP_DIV            
%token OP_COMP_IGUAL     
%token OP_COMP_DIST      
%token OP_COMP_MAYOR     
%token OP_COMP_MAYOR_IG  
%token OP_COMP_MENOR     
%token OP_COMP_MENOR_IG  
%token OP_AND            
%token OP_OR             
%token OP_NOT           

%token LLAVE_A           
%token LLAVE_C   
%token CORCHETE_A
%token CORCHETE_C        
%token PAR_A             
%token PAR_C             
%token COMA              
%token DOS_PUNTOS        

%token <str_val> CONST_ENT         
%token <str_val> CONST_REAL        
%token <str_val> CONST_STR         

%token <str_val> ID

/* START SYMBOL */
%start comienzo

%%

comienzo:           programa                                        { printf("\nCOMPILACION EXITOSA!!!\n"); }
;

programa:           INIT LLAVE_A declaracion LLAVE_C bloque         { printf("\n<PROGRAMA> -> init llave_a <DECLARACION> llave_c <BLOQUE>"); }
;

declaracion:        declaracion lista_dec DOS_PUNTOS tipodato       { printf("\n<DECLARACION> -> <DECLARACION> <LISTA_DEC> dos_puntos <TIPODATO>");act_Tipodato(); }
                    | lista_dec DOS_PUNTOS tipodato                 { printf("\n<DECLARACION> -> <LISTA_DEC> dos_puntos <TIPODATO>"); act_Tipodato();}
;

lista_dec:          lista_dec COMA ID                               { printf("\n<LISTA_DEC> -> <LISTA_DEC> coma id"); apilar(&pVar, $3); }
                    | ID                                            { printf("\n<LISTA_DEC> -> id"); apilar(&pVar, $1); }
;

tipodato:           T_FLOAT                                         { printf("\n<TIPODATO> -> t_float"); apilar(&pVar, "Float"); }
                    | T_STRING                                      { printf("\n<TIPODATO> -> t_string"); apilar(&pVar, "String"); }
                    | T_INT                                         { printf("\n<TIPODATO> -> t_int"); apilar(&pVar, "Int"); }
;

bloque:             bloque sentencia                                { printf("\n<BLOQUE> -> <BLOQUE> <SENTENCIA>"); }
                    | sentencia                                     { printf("\n<BLOQUE> -> <SENTENCIA>"); }
;

sentencia:          asignacion                                      { printf("\n<SENTENCIA> -> <ASIGNACION>"); }
                    | funcion_up                                    { printf("\n<SENTENCIA> -> <FUNCION_UP>"); }
                    | entrada                                       { printf("\n<SENTENCIA> -> <ENTRADA>"); }
                    | salida                                        { printf("\n<SENTENCIA> -> <SALIDA>"); }
                    | ciclo                                         { printf("\n<SENTENCIA> -> <CICLO>"); }
                    | seleccion                                     { printf("\n<SENTENCIA> -> <SELECCION>"); }
                    
;

asignacion:         lista_asig expresion                            { printf("\n<ASIGNACION> -> <LISTA_ASIG> <EXPRESION>"); apilar(&pVar, desapilar(&pTipoDatoExp)); accionSemanticaAsig(); completarAsignacion(); }
                    | lista_asig CONST_STR                          { printf("\n<ASIGNACION> -> <LISTA_ASIG> const_str"); apilar(&pVar, "String"); accionSemanticaAsig(); insertar_en_polaca($2); completarAsignacion(); }
                    | ID OP_ASIG funcion_cp                         { printf("\n<ASIGNACION> -> id op_asig <FUNCION_CP>"); insertar_en_polaca($1); insertar_en_polaca(":="); }
;

lista_asig:         lista_asig ID OP_ASIG                           { printf("\n<LISTA_ASIG> -> <LISTA_ASIG> id op_asig"); apilar(&pVar, $2); apilar(&pId, $2); buscarId_en_TS($2); }
                    | ID OP_ASIG                                    { printf("\n<LISTA_ASIG> -> id op_asig"); apilar(&pVar, $1); apilar(&pId, $1); buscarId_en_TS($1); }
;

funcion_cp:         CONTAR_PRIMOS PAR_A CORCHETE_A lista_primos CORCHETE_C PAR_C      { printf("\n<FUNCION_CP> -> contar_primos par_a corchete_a <LISTA_PRIMOS> corchete_c par_c"); }  
;

lista_primos:       lista_primos COMA expresion                     { printf("\n<LISTA_PRIMOS> -> <LISTA_PRIMOS> coma <EXPRESION>"); insertar_en_polaca("CP"); }
                    | expresion                                     { printf("\n<LISTA_PRIMOS> -> <EXPRESION>"); insertar_en_polaca("CP"); }
;

funcion_up:         UNTIL_LOOP  { apilarCelda(); insertar_en_polaca("UP"); } 
                    PAR_A CONST_ENT OP_COMP_MAYOR ID   { insertar_en_polaca($4); guardarBranchComparador("BGT"); insertar_en_polaca($6); compararYBranch(); } 
                    COMA ID OP_ASIG expresion PAR_C    { printf("\n<FUNCION_UP> -> until_loop par_a const_ent op_comp_mayor id coma id op_asig <EXPRESION> par_c"); 
                                                        verificarIdUp($6, $9); insertar_en_polaca($9); insertar_en_polaca(":="); insertar_en_polaca("BI"); 
                                                        actualizarCelda(desapilarCelda(), num_celda_actual+1); insertar_en_polaca(desapilarCelda()); }
;

entrada:            LEER PAR_A ID PAR_C                         { printf("\n<ENTRADA> -> leer par_a id par_c"); buscarId_en_TS($3); insertar_en_polaca($3); insertar_en_polaca("LEER"); }
;

salida:             ESCRIBIR PAR_A CONST_STR PAR_C              { printf("\n<SALIDA> -> escribir par_a const_str par_c"); insertar_en_polaca($3); insertar_en_polaca("ESCRIBIR"); }
                    | ESCRIBIR PAR_A ID PAR_C                   { printf("\n<SALIDA> -> escribir par_a id par_c"); buscarId_en_TS($3); insertar_en_polaca($3); insertar_en_polaca("ESCRIBIR"); }
;

ciclo:              MIENTRAS { apilarCelda(); insertar_en_polaca("ET"); } 
                    PAR_A condicion PAR_C LLAVE_A bloque {insertar_en_polaca("BI");verificarCondicionYActualizarCelda();insertar_en_polaca(desapilarCelda());} 
                    LLAVE_C { printf("\n<CICLO> -> mientras par_a <CONDICION> par_c llave_a <BLOQUE> llave_c"); }
;

seleccion:          sel_simple                                                              { printf("\n<SELECCION> -> <SEL_SIMPLE>"); }    
                    | sel_simple {bifurcacion_sino();} SINO LLAVE_A bloque LLAVE_C          { printf("\n<SELECCION> -> <SEL_SIMPLE> sino llave_a <BLOQUE> llave_c"); actualizar_bif_sino(); }
;

sel_simple:         SI PAR_A condicion PAR_C LLAVE_A bloque LLAVE_C             { printf("\n<SEL_SIMPLE> -> si par_a <CONDICION> par_c llave_a <BLOQUE> llave_c"); verificarCondicionYActualizarCeldaSeleccion(); }
;

condicion:          cond_simple                                                                 { printf("\n<CONDICION> -> <COND_SIMPLE>"); compararYBranch(); apilar(&pCondicion, "SIMPLE");}
                    | cond_simple op_combinacion {compararYBranch();} cond_simple               { printf("\n<CONDICION> -> <COND_SIMPLE> <OP_COMBINACION> <COND_SIMPLE>"); compararYBranchComb(); }
				    | OP_NOT cond_simple                                                        { printf("\n<CONDICION> -> op_not <COND_SIMPLE>"); operadorNot=true; compararYBranch(); apilar(&pCondicion, "NOT");} 
;

cond_simple:        expresion comparador expresion                              { printf("\n<COND_SIMPLE> -> <EXPRESION> <COMPARADOR> <EXPRESION>"); accionSemanticaCmp(); }
;

op_combinacion:     OP_AND                                                      { printf("\n<OP_COMBINACION> -> op_and"); apilar(&pCondicion, "AND"); }
				    | OP_OR                                                     { printf("\n<OP_COMBINACION> -> op_or"); operadorOr=true; apilar(&pCondicion, "OR"); }
;

comparador:         OP_COMP_IGUAL						                        { printf("\n<COMPARADOR> -> op_comp_igual"); guardarBranchComparador("BNE"); }
				    | OP_COMP_DIST						                        { printf("\n<COMPARADOR> -> op_comp_dist"); guardarBranchComparador("BEQ"); }
				    | OP_COMP_MAYOR						                        { printf("\n<COMPARADOR> -> op_comp_mayor"); guardarBranchComparador("BLE"); }
				    | OP_COMP_MAYOR_IG					                        { printf("\n<COMPARADOR> -> op_comp_mayor_ig"); guardarBranchComparador("BLT"); }
				    | OP_COMP_MENOR						                        { printf("\n<COMPARADOR> -> op_comp_menor"); guardarBranchComparador("BGE"); }
				    | OP_COMP_MENOR_IG					                        { printf("\n<COMPARADOR> -> op_comp_menor_ig"); guardarBranchComparador("BGT"); }
;

expresion:          expresion OP_SUM termino			                        { printf("\n<EXPRESION> -> <EXPRESION> op_sum <TERMINO>"); verificarTDExp(); insertar_en_polaca("+"); }
			        | expresion OP_RES termino			                        { printf("\n<EXPRESION> -> <EXPRESION> op_res <TERMINO>"); verificarTDExp(); insertar_en_polaca("-"); }
			        | termino							                        { printf("\n<EXPRESION> -> <TERMINO>"); }
;

termino:            termino OP_MUL factor				                        { printf("\n<TERMINO> -> <TERMINO> op_mul <FACTOR>"); verificarTDExp(); insertar_en_polaca("*"); }
			        | termino OP_DIV factor				                        { printf("\n<TERMINO> -> <TERMINO> op_div <FACTOR>"); verificarTDExp(); insertar_en_polaca("/"); }
			        | factor							                        { printf("\n<TERMINO> -> <FACTOR>"); }
;

factor:             PAR_A expresion PAR_C					                    { printf("\n<FACTOR> -> par_a <EXPRESION> par_c"); }
		            | ID										                { printf("\n<FACTOR> -> id"); buscarId_en_TS($1); apilar(&pTipoDatoExp, lexGlobal.tipoDato); insertar_en_polaca($1); }
		            | CONST_ENT									                { printf("\n<FACTOR> -> const_ent "); apilar(&pTipoDatoExp, "Int"); insertar_en_polaca($1); }
		            | CONST_REAL								                { printf("\n<FACTOR> -> const_real"); apilar(&pTipoDatoExp, "Float"); insertar_en_polaca($1);}
;

%%

int main (int argc, char* argv[]){
    crearLista(&listaTS);
    crear_lista_inter(&listaIntermedia);
    crearPilas();
    if( (yyin = fopen(argv[1], "rt")) == NULL ){
        printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
        return 1;
    }
    else{
        printf("\nEl archivo %s se abrio correctamente\n", argv[1]);
        yyparse();
        generarCodigoIntermedio();
        if (volcarTSenArchivo())
            printf("\nArchivo symbol-table.txt cargado con TS");
        else
            printf("\nNo se pudo abrir el archivo 'symbol-table.txt'");
    }

    printf("\nFinalizo la lectura del archivo %s \n\n", argv[1]);
    fclose(yyin);
    return 0;
}

int yyerror()
{
	printf("\nERROR SINTACTICO\n");
	exit(1);
}

void crearPilas()
{
    crearPila(&pCeldas);
    crearPila(&pCondicion);
    crearPila(&pId);
    crearPila(&pVar);
    crearPila(&pTipoDatoExp);
}

int generarCodigoIntermedio()
{
    FILE *file = fopen("intermediate-code.txt", "w+");
    char nombre[100];

    if(!file)
        return 0;

    while( !lista_inter_vacia(&listaIntermedia) )
    {
        extraer_primero_de_lista_inter(&listaIntermedia, nombre);
        fprintf(file, "%s|",nombre);
    }
    fclose(file);

    return 1;
}

int volcarTSenArchivo()
{
    FILE *file = fopen("symbol-table.txt", "w+");
    t_lexema lexemaRecuperado;

    if(!file)
        return 0;

    fprintf(file, "%-41s || %-15s || %-51s || %-9s\n", "NOMBRE", "TIPODATO", "VALOR", "LONGITUD");
    while( ! listaVacia(&listaTS) )
    {
        sacarPrimeroLista(&listaTS, &lexemaRecuperado);
        fprintf(file, "%-41s || %-15s || %-51s || %-9s\n", lexemaRecuperado.nombre, lexemaRecuperado.tipoDato, lexemaRecuperado.valor, lexemaRecuperado.longitud );
    }
    fclose(file);

    return 1;
}

void act_Tipodato()
{
    char* tipo_dato;
    char* var;
    t_lexema lexTS;

    tipo_dato = desapilar(&pVar);
    while(!pilaVacia(&pVar))
    {
        var = desapilar(&pVar);
        if(strcmp(var, "Int")!=0 && strcmp(var, "String")!=0 && strcmp(var,"Float")!=0)
        {
            buscarEnlista(&listaTS, var, &lexTS);

            if(strcmp(lexTS.tipoDato, "") == 0)
                buscarYactualizar(&listaTS, var, tipo_dato);
            else
            {
                printf("\n %s: variable declarada previamente\n", var);
                exit(1);
            }
        }
        else
            tipo_dato = var;
    }
}

void insertar_en_polaca(char* cadena)
{
    insertar_en_lista_inter(&listaIntermedia, cadena);
	num_celda_actual++;
}

void apilarCelda()
{
    char celdaActual[20];
    sprintf(celdaActual,"%d",num_celda_actual);
    apilar(&pCeldas,celdaActual);
}

char* desapilarCelda()
{
    return desapilar(&pCeldas);
}

void actualizarCelda(char* celdaActualizar, int valor)
{
    char valorCelda[20];
    sprintf(valorCelda,"%d",valor);
    buscar_y_actualizar_inter(&listaIntermedia,atoi(celdaActualizar),valorCelda);
}

int buscarId_en_TS(char* nombre)
{
    buscarEnlista(&listaTS, nombre, &lexGlobal);

    if(strcmp(lexGlobal.tipoDato, "")!=0)
        return 1; 
    else
    {
        printf("\nError: %s no fue declarada\n");
        exit(1);
    }
}

void accionSemanticaAsig()
{
    char* tipo_dato = desapilar(&pVar);
    char* var;
    t_lexema lex;

    while(!pilaVacia(&pVar))
    {
        var = desapilar(&pVar);
        buscarEnlista(&listaTS, var, &lex);

        if(strcmp(lex.tipoDato, tipo_dato)!=0)
        {
            printf("\nError: %s es de tipo: %s, no se le puede asignar un tipo: %s \n",lex.nombre, lex.tipoDato, tipo_dato);
            exit(1);
        }
    }
}

void completarAsignacion()
{
    insertar_en_polaca("@auxAsig");
    insertar_en_polaca(":=");
    while(!pilaVacia(&pId))
    {
        insertar_en_polaca("@auxAsig");
        insertar_en_polaca(desapilar(&pId));
        insertar_en_polaca(":=");
    }
}

void guardarBranchComparador(char* branch)
{
    strcpy(branchComparador, branch);
}

void compararYBranch()
{
    insertar_en_polaca("CMP");
    if (operadorOr || operadorNot)
    {
        if(!strcmp(branchComparador, "BNE"))
            strcpy(branchComparador, "BEQ");
        else if(!strcmp(branchComparador, "BEQ"))
            strcpy(branchComparador, "BNE");
        else if(!strcmp(branchComparador, "BLE"))
            strcpy(branchComparador, "BGT");
        else if(!strcmp(branchComparador, "BGT"))
            strcpy(branchComparador, "BLE");
        else if(!strcmp(branchComparador, "BLT"))
            strcpy(branchComparador, "BGE");
        else if(!strcmp(branchComparador, "BGE"))
            strcpy(branchComparador, "BLT");
        
        operadorNot=false;
    }
    insertar_en_polaca(branchComparador);
    apilarCelda();
    insertar_en_polaca("");
}

void compararYBranchComb()
{
    insertar_en_polaca("CMP");
    insertar_en_polaca(branchComparador);
    if(operadorOr)
    {
        char* celda = desapilarCelda();
        actualizarCelda(celda, num_celda_actual+1);
        operadorOr=false;
    }
    apilarCelda();
    insertar_en_polaca("");
}

void accionSemanticaCmp()
{
    char* td1 = desapilar(&pTipoDatoExp);
    char* td2 = desapilar(&pTipoDatoExp);

    if( strcmp(td1, "String") == 0 || strcmp(td2, "String") == 0 )
    {
        printf("\nError: Id de tipo String en comparacion\n");
        exit(1);
    }
}

void verificarCondicionYActualizarCelda()
{
    actualizarCelda(desapilarCelda(), num_celda_actual+1);

    if( strcmp(desapilar(&pCondicion), "AND") == 0 )
        actualizarCelda(desapilarCelda(), num_celda_actual+1);
}

void verificarCondicionYActualizarCeldaSeleccion()
{
    actualizarCelda(desapilarCelda(), num_celda_actual+2);

    if( strcmp(desapilar(&pCondicion), "AND") == 0 )
        actualizarCelda(desapilarCelda(), num_celda_actual+2);
}

void bifurcacion_sino()
{
    insertar_en_polaca("BI");
    apilarCelda();
    insertar_en_polaca("");
}

void actualizar_bif_sino()
{
    actualizarCelda(desapilarCelda(), num_celda_actual);
}

void verificarTDExp()
{
    char* td1 = desapilar(&pTipoDatoExp);
    char* td2 = desapilar(&pTipoDatoExp);
    
    if( strcmp(td1, "String") != 0 && strcmp(td1, "String") != 0 )
        if( strcmp(td1, "Float") == 0 ||  strcmp(td2, "Float") == 0 )
            apilar(&pTipoDatoExp, "Float");
        else
            apilar(&pTipoDatoExp, "Int");
    else
    {
        printf("\nError: Id de tipo String en expresion matematica\n");
        exit(1);
    }
}

void verificarIdUp(char* id1, char* id2)
{
    t_lexema lex;
    buscarEnlista(&listaTS, id1, &lex);
    if (strcmp(id1, id2) != 0)
    {
        printf("\nError: %s distinto de %s. Se esperaba que sea el mismo.\n", id1, id2);
        exit(1);
    }
    if (strcmp(lex.tipoDato, "String") == 0)
    {
        printf("\nError: %s no puede ser tipo String.\n", id1);
        exit(1);
    }
}