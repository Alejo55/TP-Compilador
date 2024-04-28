%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "Lista.h"

FILE *yyin;
extern t_lista lista;

int yylex();
int yyerror();

int volcarTSenArchivo();

%}

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

%token CONST_ENT         
%token CONST_REAL        
%token CONST_STR         

%token ID

/* START SYMBOL */
%start comienzo

%%

comienzo:           programa                                        { printf("\nCOMPILACION EXITOSA!!!\n"); }
;

programa:           INIT LLAVE_A declaracion LLAVE_C bloque         { printf("\n<PROGRAMA> -> init llave_a <DECLARACION> llave_c <BLOQUE>"); }
;

declaracion:        declaracion lista_dec DOS_PUNTOS tipodato       { printf("\n<DECLARACION> -> <DECLARACION> <LISTA_DEC> dos_puntos <TIPODATO>"); }
                    | lista_dec DOS_PUNTOS tipodato                 { printf("\n<DECLARACION> -> <LISTA_DEC> dos_puntos <TIPODATO>"); }
;

lista_dec:          lista_dec COMA ID                               { printf("\n<LISTA_DEC> -> <LISTA_DEC> coma id"); }
                    | ID                                            { printf("\n<LISTA_DEC> -> id"); }
;

tipodato:           T_FLOAT                                         { printf("\n<TIPODATO> -> t_float"); }
                    | T_STRING                                      { printf("\n<TIPODATO> -> t_string"); }
                    | T_INT                                         { printf("\n<TIPODATO> -> t_int"); }
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

asignacion:         lista_asig expresion                            { printf("\n<ASIGNACION> -> <LISTA_ASIG> <EXPRESION>"); }
                    | lista_asig CONST_STR                          { printf("\n<ASIGNACION> -> <LISTA_ASIG> const_str"); }
                    | lista_asig funcion_cp                         { printf("\n<ASIGNACION> -> <LISTA_ASIG> <FUNCION_CP>"); }
;

lista_asig:         lista_asig ID OP_ASIG                           { printf("\n<LISTA_ASIG> -> <LISTA_ASIG> id op_asig"); }
                    | ID OP_ASIG                                    { printf("\n<LISTA_ASIG> -> id op_asig"); }
;

funcion_cp:         CONTAR_PRIMOS PAR_A CORCHETE_A lista_primos CORCHETE_C PAR_C      { printf("\n<FUNCION_CP> -> contar_primos par_a corchete_a <LISTA_PRIMOS> corchete_c par_c"); }  
;

lista_primos:       lista_primos COMA expresion                     { printf("\n<LISTA_PRIMOS> -> <LISTA_PRIMOS> coma <EXPRESION>"); }
                    | expresion                                     { printf("\n<LISTA_PRIMOS> -> <EXPRESION>"); }
;

funcion_up:         UNTIL_LOOP PAR_A CONST_ENT OP_COMP_MAYOR ID COMA ID OP_ASIG expresion PAR_C       { printf("\n<FUNCION_UP> -> until_loop par_a const_ent op_comp_mayor id coma id op_asig <EXPRESION> par_c"); }
;

entrada:            LEER PAR_A ID PAR_C                             { printf("\n<ENTRADA> -> leer par_a id par_c"); }
;

salida:             ESCRIBIR PAR_A CONST_STR PAR_C                  { printf("\n<SALIDA> -> escribir par_a const_str par_c"); }
                    | ESCRIBIR PAR_A ID PAR_C                       { printf("\n<SALIDA> -> escribir par_a id par_c"); }
;

ciclo:              MIENTRAS PAR_A condicion PAR_C LLAVE_A bloque LLAVE_C       { printf("\n<CICLO> -> mientras par_a <CONDICION> par_c llave_a <BLOQUE> llave_c"); }
;

seleccion:          sel_simple                                                  { printf("\n<SELECCION> -> <SEL_SIMPLE>"); }    
                    | sel_simple SINO LLAVE_A bloque LLAVE_C                    { printf("\n<SELECCION> -> <SEL_SIMPLE> sino llave_a <BLOQUE> llave_c"); }
;

sel_simple:         SI PAR_A condicion PAR_C LLAVE_A bloque LLAVE_C             { printf("\n<SEL_SIMPLE> -> si par_a <CONDICION> par_c llave_a <BLOQUE> llave_c"); }
;

condicion:          cond_simple                                                 { printf("\n<CONDICION> -> <COND_SIMPLE>"); }
                    | cond_simple op_combinacion cond_simple                    { printf("\n<CONDICION> -> <COND_SIMPLE> <OP_COMBINACION> <COND_SIMPLE>"); }
				    | OP_NOT cond_simple                                        { printf("\n<CONDICION> -> op_not <COND_SIMPLE>"); } 
;

cond_simple:        expresion comparador expresion                              { printf("\n<COND_SIMPLE> -> <EXPRESION> <COMPARADOR> <EXPRESION>"); }
;

op_combinacion:     OP_AND                                                      { printf("\n<OP_COMBINACION> -> op_and"); }
				    | OP_OR                                                     { printf("\n<OP_COMBINACION> -> op_or"); }
;

comparador:         OP_COMP_IGUAL						                        { printf("\n<COMPARADOR> -> op_comp_igual"); }
				    | OP_COMP_DIST						                        { printf("\n<COMPARADOR> -> op_comp_dist"); }
				    | OP_COMP_MAYOR						                        { printf("\n<COMPARADOR> -> op_comp_mayor"); }
				    | OP_COMP_MAYOR_IG					                        { printf("\n<COMPARADOR> -> op_comp_mayor_ig"); }
				    | OP_COMP_MENOR						                        { printf("\n<COMPARADOR> -> op_comp_menor"); }
				    | OP_COMP_MENOR_IG					                        { printf("\n<COMPARADOR> -> op_comp_menor_ig"); }
;

expresion:          expresion OP_SUM termino			                        { printf("\n<EXPRESION> -> <EXPRESION> op_sum <TERMINO>"); }
			        | expresion OP_RES termino			                        { printf("\n<EXPRESION> -> <EXPRESION> op_res <TERMINO>"); }
			        | termino							                        { printf("\n<EXPRESION> -> <TERMINO>"); }
;

termino:            termino OP_MUL factor				                        { printf("\n<TERMINO> -> <TERMINO> op_mul <FACTOR>"); }
			        | termino OP_DIV factor				                        { printf("\n<TERMINO> -> <TERMINO> op_div <FACTOR>"); }
			        | factor							                        { printf("\n<TERMINO> -> <FACTOR>"); }
;

factor:             PAR_A expresion PAR_C					                    { printf("\n<FACTOR> -> par_a <EXPRESION> par_c"); }
		            | ID										                { printf("\n<FACTOR> -> id"); }
		            | CONST_ENT									                { printf("\n<FACTOR> -> const_ent"); }
		            | CONST_REAL								                { printf("\n<FACTOR> -> const_real"); }
;

%%

int main (int argc, char* argv[]){
    if( (yyin = fopen(argv[1], "rt")) == NULL ){
        printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
        return 1;
    }
    else{
        printf("\nEl archivo %s se abrio correctamente\n", argv[1]);
        yyparse();
        if (volcarTSenArchivo())
            printf("\nArchivo 'symbol-table.txt' cargado con TS");
        else
            printf("\nNo se pudo abrir el archivo 'symbol-table.txt'");
    }
    printf("\nFinalizo la lectura del archivo %s \n", argv[1]);
    fclose(yyin);
    return 0;
}

int yyerror()
{
	printf("\nERROR SINTACTICO\n");
	exit(1);
}

int volcarTSenArchivo()
{
    FILE *file = fopen("symbol-table.txt", "w+");
    t_lexema lexemaRecuperado;

    if(!file)
        return 0;

    fprintf(file, "%-41s || %-10s || %-51s || %-9s\n", "NOMBRE", "TIPODATO", "VALOR", "LONGITUD");
    while( ! listaVacia(&lista) )
    {
        sacarPrimeroLista(&lista, &lexemaRecuperado);
        fprintf(file, "%-41s || %-10s || %-51s || %-9s\n", lexemaRecuperado.nombre, lexemaRecuperado.tipoDato, lexemaRecuperado.valor, lexemaRecuperado.longitud );
    }
    fclose(file);

    return 1;
}