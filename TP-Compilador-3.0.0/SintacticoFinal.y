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
void completarAsignacionNum();
void completarAsignacionString();
void agregarAuxAsigTS(char* auxNombre, char* auxTipo, char* auxValor);

void guardarBranchComparador(char* branch);
void compararYBranch();
void compararYBranchComb();
void accionSemanticaCmp();

void insertarEtiqueta();

void verificarCondicionYActualizarCelda();
void verificarCondicionYActualizarCeldaSeleccion();

void bifurcacion_sino();
void actualizar_bif_sino();

void verificarTDExp();

void verificarIdUp(char* id1, char* id2);

//VARIABLES ASSEMBLER
int numAuxActual = 0;
int numCeldaAssembler = 0;
int tamInicialAssembler = 30000;
char* codAssembler = NULL;

t_lista listaTSDup;
t_lista_cod_inter listaIntermediaDup;
t_lista_cod_inter listaEtiq; //t_lista_cod_inter me sirve para tener una lista de etiquetas ya que solo manejare cadenas
t_pila pOperando;
t_pila pAuxAssembler;

// FUNCIONES ASSEMBLER
int genera_assembler();
void agregar_cabecera_assembler(FILE *arch);
void generar_cuerpo_assembler();
int buscarEtiqFinal();
void insertar_en_TS_aux_assembler();
void agregar_seccion_de_variables( FILE * archivoAssembler );
void agregar_inicio_de_codigo_assembler(FILE* arch);
void agregar_cuerpo_assembler(FILE* arch);
void agregar_final_de_codigo_assembler(FILE *arch);
void inicializarCodAssembler();
void agregarTextoAssembler(const char *texto);
void procesarCeldaAssembler();
void extraerCeldaAssembler(char* celda);
void escribirEtiquetaAssembler(char* etiqueta);
int esOperando(char* celda);
void operacionMatAssembler(char* instruccionMat);
char* generarAuxiliar();
void asignacionAssembler();
void comparacionAssembler();
char* obtenerJump(char* celda);
void BIAssembler();
void opEscribirAssembler();
void opLeerAssembler();
void CPAssembler();


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

comienzo:           programa                                        { printf("\nCOMPILACION EXITOSA!!!\n"); genera_assembler(); }
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

asignacion:         lista_asig expresion                            { printf("\n<ASIGNACION> -> <LISTA_ASIG> <EXPRESION>"); apilar(&pVar, desapilar(&pTipoDatoExp)); accionSemanticaAsig(); completarAsignacionNum(); }
                    | lista_asig CONST_STR                          { printf("\n<ASIGNACION> -> <LISTA_ASIG> const_str"); apilar(&pVar, "String"); accionSemanticaAsig(); insertar_en_polaca($2); completarAsignacionString(); }
                    | ID OP_ASIG funcion_cp                         { printf("\n<ASIGNACION> -> id op_asig <FUNCION_CP>"); insertar_en_polaca("@auxCP"); insertar_en_polaca($1); insertar_en_polaca(":="); }
;

lista_asig:         lista_asig ID OP_ASIG                           { printf("\n<LISTA_ASIG> -> <LISTA_ASIG> id op_asig"); apilar(&pVar, $2); apilar(&pId, $2); buscarId_en_TS($2); }
                    | ID OP_ASIG                                    { printf("\n<LISTA_ASIG> -> id op_asig"); apilar(&pVar, $1); apilar(&pId, $1); buscarId_en_TS($1); }
;

funcion_cp:         CONTAR_PRIMOS PAR_A CORCHETE_A lista_primos CORCHETE_C PAR_C      { printf("\n<FUNCION_CP> -> contar_primos par_a corchete_a <LISTA_PRIMOS> corchete_c par_c"); }  
;

lista_primos:       lista_primos COMA expresion                     { printf("\n<LISTA_PRIMOS> -> <LISTA_PRIMOS> coma <EXPRESION>"); insertar_en_polaca("CP"); }
                    | expresion                                     { printf("\n<LISTA_PRIMOS> -> <EXPRESION>"); insertar_en_polaca("CP"); agregarAuxAsigTS("@auxCP", "Float", "0.0");}
;

funcion_up:         UNTIL_LOOP  { apilarCelda(); insertarEtiqueta(); } 
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

ciclo:              MIENTRAS { apilarCelda(); insertarEtiqueta(); } 
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
    crearPila(&pOperando);
    crearPila(&pAuxAssembler);
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

void completarAsignacionNum()
{
    insertar_en_polaca("@auxAsigNum");
    insertar_en_polaca(":=");
    while(!pilaVacia(&pId))
    {
        insertar_en_polaca("@auxAsigNum");
        insertar_en_polaca(desapilar(&pId));
        insertar_en_polaca(":=");
    }

    agregarAuxAsigTS("@auxAsigNum", "Float", "");
}

void completarAsignacionString()
{
    insertar_en_polaca("@auxAsigString");
    insertar_en_polaca(":=");
    while(!pilaVacia(&pId))
    {
        insertar_en_polaca("@auxAsigString");
        insertar_en_polaca(desapilar(&pId));
        insertar_en_polaca(":=");
    }

    agregarAuxAsigTS("@auxAsigString", "String", "");
}

void agregarAuxAsigTS(char* auxNombre, char* auxTipo, char* auxValor)
{
    t_lexema lex;
    if( !buscarEnlista(&listaTS, auxNombre, &lex) )
    {
        strcpy(lex.nombre, auxNombre);
        strcpy(lex.tipoDato, auxTipo);
        strcpy(lex.valor, auxValor);
        strcpy(lex.longitud, "");
        insertarFinalLista(&listaTS, lex);
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

void insertarEtiqueta()
{
    char etiqueta[100];
    sprintf(etiqueta, "ET_%d", num_celda_actual); 
    insertar_en_polaca(etiqueta);
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




// ASSEMBLER

int genera_assembler()
{
    FILE* archivoAssembler = fopen("Final.asm", "w+");
  	if(!archivoAssembler)
		return 0;

    duplicar_lista_cod_intermedio(&listaIntermedia, &listaIntermediaDup);
    crear_lista_inter(&listaEtiq);
    inicializarCodAssembler();
    
    agregar_cabecera_assembler(archivoAssembler);
    
    //PRIMERO SE TIENE QUE PROCESAR TODO PARA QUE SE GENEREN LOS AUXILIARES EXTRAS Q IRAN LUEGO A LA TS
    generar_cuerpo_assembler();

    insertar_en_TS_aux_assembler();
    duplicarLista(&listaTS, &listaTSDup);
    agregar_seccion_de_variables(archivoAssembler);

    agregar_inicio_de_codigo_assembler(archivoAssembler);

    agregar_cuerpo_assembler(archivoAssembler);
    
    agregar_final_de_codigo_assembler(archivoAssembler);

    // Liberar memoria asignada a codAssembler al final de todo
    free(codAssembler);
    fclose(archivoAssembler);

    return 1;
}

void agregar_cabecera_assembler(FILE *arch)
{
  fprintf(arch, "include macros2.asm\ninclude number.asm\n\n.MODEL LARGE\n.386\n.STACK 200h\n\nMAXTEXTSIZE equ 40");
}

void generar_cuerpo_assembler()
{
    char etiqueta[100];
    int etiqFinal;

    while( !lista_inter_vacia(&listaIntermediaDup) )
        procesarCeldaAssembler();

    etiqFinal = buscarEtiqFinal();
    if(etiqFinal != -1)
    {
        sprintf(etiqueta, "ET_%d", etiqFinal);
        escribirEtiquetaAssembler(etiqueta);
    }
}

int buscarEtiqFinal()
{
    int etiqMayor = -1;
    int etiqActual = 0;
    char etiq[100];
    char aux[100];

    while(!lista_inter_vacia(&listaEtiq))
    {
        extraer_primero_de_lista_inter(&listaEtiq, etiq);
        char* pos = strchr(etiq, '_');
        strcpy(aux, pos+1);
        etiqActual = atoi(aux);
        if(etiqActual > etiqMayor)
            etiqMayor = etiqActual;
    }

    return etiqMayor;
}

void insertar_en_TS_aux_assembler()
{
    t_lexema lex;
    char* nombreAux;
    //LOS AUXILIARES VAN A SER DE OPERACIONES MATEMATICAS, X LO Q SOLO SERAN NUMERICOS

    if(!buscarEnlista(&listaTS, "@auxCP", &lex))
    {
        strcpy(lex.nombre, "@auxCP");
        strcpy(lex.tipoDato, "Float");
        strcpy(lex.valor, "0.0");
        strcpy(lex.longitud, "");
        insertarFinalLista(&listaTS, lex);
    }

    while( !pilaVacia(&pAuxAssembler) )
    {
        nombreAux = desapilar(&pAuxAssembler);
        strcpy(lex.nombre, nombreAux);
        strcpy(lex.tipoDato, "Float");
        strcpy(lex.valor, "");
        strcpy(lex.longitud, "");
        insertarFinalLista(&listaTS, lex);
    }
}

void agregar_seccion_de_variables( FILE * archivoAssembler )
{
    int maxTextSize=40;
    t_lexema lex;

	fprintf(archivoAssembler, "\n\n.DATA\n");
    int bytesRestantes;
    char cadenaResul[10];

    while( !listaVacia(&listaTSDup) )
    {
        sacarPrimeroLista(&listaTSDup, &lex);
        if( !strcmp(lex.tipoDato, "String") || !strcmp(lex.tipoDato, "CTE_STRING") )
        {
            if( !strcmp(lex.valor, "") )
                fprintf(archivoAssembler, "\n\t%s\tdb\tMAXTEXTSIZE dup (?),'$'", lex.nombre);
            else
            {
                bytesRestantes = maxTextSize - atoi(lex.longitud);
                itoa(bytesRestantes,cadenaResul,10);
                fprintf(archivoAssembler, "\n\t%s\tdb\t%s,'$', %s dup (?)", lex.nombre, lex.valor, cadenaResul);
            }
        }
        else
        {
            if( !strcmp(lex.valor, "") )
                fprintf(archivoAssembler, "\n\t%s\tdd\t?", lex.nombre);
            else
                fprintf(archivoAssembler, "\n\t%s\tdd\t%s", lex.nombre, lex.valor);
        }
    }
}

void agregar_inicio_de_codigo_assembler(FILE* arch)
{
	fprintf(arch, "\n\n.CODE\n\n\nSTART:\n\tMOV AX, @DATA\n\tMOV DS, AX\n\tMOV es,ax\n\n");
}

void agregar_cuerpo_assembler(FILE* arch)
{
    fprintf(arch, codAssembler);
}

void agregar_final_de_codigo_assembler(FILE *arch)
{
    fprintf(arch, "\n\tMOV AX, 4C00h\n\tINT 21h\n");

    //// PROCEDIMIENTOS NECESARIOS PARA ASIGNACION DE STRINGS ////
    fprintf(arch, "\n\n\nSTRLEN PROC NEAR\n\tmov bx, 0\nSTRL01:\n\tcmp BYTE PTR [SI+BX],'$'\n\tje STREND\n\tinc BX\n\tjmp STRL01\nSTREND:\n\tret\nSTRLEN ENDP\n");
	
	fprintf(arch, "\nCOPIAR PROC NEAR\n\tcall STRLEN\n\tcmp bx,MAXTEXTSIZE\n\tjle COPIARSIZEOK\n\tmov bx,MAXTEXTSIZE\nCOPIARSIZEOK:\n\tmov cx,bx\n\tcld\n\trep movsb\n\tmov al,'$'\n\tmov BYTE PTR [DI],al\n\tret\nCOPIAR ENDP\n");

    //// PROCEDIMIENTO ES_PRIMO ////
    fprintf(arch, "\nES_PRIMO PROC NEAR\n\tcmp eax, 2\n\tjb CASO_NO_PRIMO\n\tje CASO_PRIMO\n\tmov ebx, eax\n\tmov ecx, 2\nCHEQUEAR_DIVISOR:\n\tmov eax, ecx\n\tmul ecx\n\tcmp eax, ebx\n\tja CASO_PRIMO\n\tmov eax, ebx\n\txor edx, edx\n\tdiv ecx\n\tcmp edx, 0\n\tje CASO_NO_PRIMO\n\tinc ecx\n\tjmp CHEQUEAR_DIVISOR\nCASO_NO_PRIMO:\n\tret\nCASO_PRIMO:\n\tfld @auxCP\n\tfld1\n\tfadd\n\tfstp @auxCP\n\tret\nES_PRIMO endp\n");

	fprintf(arch, "\nEND START\n");
}

void inicializarCodAssembler()
{
    codAssembler = (char *)malloc(tamInicialAssembler * sizeof(char));
    
    if (codAssembler == NULL) {
        fprintf(stderr, "\nError al asignar memoria\n");
        exit(1);
    }
    
    // Inicializar la cadena con un terminador nulo.
    codAssembler[0] = '\0';
}

// Función auxiliar para agregar texto a la cadena.
void agregarTextoAssembler(const char *texto)
{
    int nuevaLongitud = strlen(codAssembler) + strlen(texto) + 1;
    if (nuevaLongitud > tamInicialAssembler) {
        tamInicialAssembler = nuevaLongitud;
        char *nuevoCodAssembler = (char *)realloc(codAssembler, tamInicialAssembler * sizeof(char));
        if (nuevoCodAssembler == NULL) {
            fprintf(stderr, "\nError al redimensionar memoria\n");
            free(codAssembler);
            exit(1);
        }
        codAssembler = nuevoCodAssembler;
    }
    strcat(codAssembler, texto);
}

void procesarCeldaAssembler()
{
    char celda[100];
    
    extraerCeldaAssembler(celda);
    
    if (esOperando(celda))
    {
        apilar(&pOperando, celda);
    }
    else if ( strcmp(celda, "+")==0 )
    {
       operacionMatAssembler("FADD");
    }
    else if ( strcmp(celda, "-")==0 )
    {
        operacionMatAssembler("FSUB");
    }
    else if ( strcmp(celda, "*")==0 )
    {
        operacionMatAssembler("FMUL");
    }
    else if ( strcmp(celda, "/")==0 )
    {
        operacionMatAssembler("FDIV");
    }
    else if ( strcmp(celda, ":=")==0 )
    {
        asignacionAssembler();
    }
    else if ( strcmp(celda, "CMP")==0 )
    {
        comparacionAssembler();
    }
    else if ( strncmp(celda, "ET_", 3)==0 ) 
    // Me servira sobre todo para while, donde se vuelve atras, entonces ya la dejo escrita
    // Distinto si el salto es a celda posterior, primero guardo en lista y recien cuando llego a esa celda escribo
    {
        escribirEtiquetaAssembler(celda);
    }
    else if ( strcmp(celda, "BI")==0 )
    {
        BIAssembler();
    }
    else if ( strcmp(celda, "ESCRIBIR")==0 )
    {
        opEscribirAssembler();
    }
    else if ( strcmp(celda, "LEER")==0 )
    {
        opLeerAssembler();
    }
    else if ( strcmp(celda, "CP")==0 )
    {
        CPAssembler();
    }    
}

void extraerCeldaAssembler(char* celda)
{
    char etiqueta[100];
    extraer_primero_de_lista_inter(&listaIntermediaDup, celda);
    
    sprintf(etiqueta, "ET_%d", numCeldaAssembler);
    if (buscar_lista_inter(&listaEtiq, etiqueta)) // Si hay una etiqueta asociada a la celda actual
        escribirEtiquetaAssembler(etiqueta);

    numCeldaAssembler++;
}

void escribirEtiquetaAssembler(char* etiqueta)
{
    char buffer[100];
    char subcadena[100];

    sprintf(subcadena, "%s:", etiqueta);
    if(strstr(codAssembler, subcadena) == NULL)
    {
        sprintf(buffer, "\n%s:", etiqueta);
        agregarTextoAssembler(buffer);
    }
}

int esOperando(char* celda)
{
    t_lexema lex;
    return buscarEnlista(&listaTS, celda, &lex);
}

void operacionMatAssembler(char* instruccionMat)
{
    char buffer[100];
    char* opDer = desapilar(&pOperando);
    char* opIzq = desapilar(&pOperando);
    char* auxNuevo = generarAuxiliar();

    sprintf(buffer, "\n\tFLD %s\n\tFLD %s\n\t%s\n\tFSTP %s", opIzq, opDer, instruccionMat, auxNuevo);
    agregarTextoAssembler(buffer);
    apilar(&pOperando, auxNuevo);
}

char* generarAuxiliar()
{
    static char auxNuevo[20];
    sprintf(auxNuevo, "@auxAssembler%d", numAuxActual);
    apilar(&pAuxAssembler, auxNuevo);
    numAuxActual++;
    return auxNuevo;
}

void asignacionAssembler()
{
    char buffer[100];
    t_lexema lex;
    char* var = desapilar(&pOperando);
    char* valor = desapilar(&pOperando);

    // Si es string, deberia buscarlo en listaTS para chequearlo ya que varia la asignacion
    buscarEnlista(&listaTS, valor, &lex);  

    if( strcmp(lex.tipoDato, "CTE_STRING")==0 || strcmp(lex.tipoDato, "String")==0 )
        /// SI= SOURCE INDEX = inicio de cadena de origen , DI = DESTINATION INDEX = inicio de cadena de destino
		sprintf(buffer, "\n\tMOV SI, OFFSET %s\n\tMOV DI, OFFSET %s\n\tCALL COPIAR", valor, var); /// INDICO A SI LA VARIABLE DE ORIGEN Y A DI LA VARIABLE DE DESTINO
    else
        sprintf(buffer, "\n\tFLD %s\n\tFSTP %s", valor, var);
    
    agregarTextoAssembler(buffer);
}

void comparacionAssembler()
{
    char buffer[100];
    char celda[100];
    char etiqueta[100];
    char* opDer = desapilar(&pOperando);
    char* opIzq = desapilar(&pOperando);

    extraerCeldaAssembler(celda);
    char* jump = obtenerJump(celda);

    extraerCeldaAssembler(celda);
    sprintf(etiqueta, "ET_%s", celda); // Me servira para saber a donde saltar (posterior a donde estoy parado)
    if(!buscar_lista_inter(&listaEtiq, etiqueta))
        insertar_en_lista_inter(&listaEtiq, etiqueta); // Inserto etiqueta para que cuando llegue a su celda, la detecte y la escriba

    sprintf(buffer, "\n\tFLD %s\n\tFCOMP %s\n\tFSTSW AX\n\tSAHF\n\t%s %s", opIzq, opDer, jump, etiqueta);
    agregarTextoAssembler(buffer);
}

char* obtenerJump(char* celda)
{
    if(!strcmp(celda, "BNE"))
        return "JNE";
    if(!strcmp(celda, "BEQ"))
        return "JE";
    if(!strcmp(celda, "BLE"))
        return "JLE";
    if(!strcmp(celda, "BGT"))
        return "JG";
    if(!strcmp(celda, "BLT"))
        return "JL";
    if(!strcmp(celda, "BGE"))
        return "JGE";
}

void BIAssembler()
{
    char celda[100];
    char etiqueta[100];
    char buffer[100];

    extraerCeldaAssembler(celda);
    sprintf(etiqueta, "ET_%s", celda);
    sprintf(buffer, "\n\tJMP %s", etiqueta);
    agregarTextoAssembler(buffer);

    if(!buscar_lista_inter(&listaEtiq,etiqueta))
    {
        insertar_en_lista_inter(&listaEtiq, etiqueta);
    }
}

void opEscribirAssembler()
{
    char buffer[100];
    t_lexema lex;
    char* operando = desapilar(&pOperando); // recordar que puede ser cteString o variable numerica

    buscarEnlista(&listaTS, operando, &lex);
    if( strcmp(lex.tipoDato, "CTE_STRING")==0 || strcmp(lex.tipoDato, "String")==0 )
        sprintf(buffer, "\n\tdisplayString %s\n\tnewLine", operando);
    else if( strcmp(lex.tipoDato, "Int")==0 )
        sprintf(buffer, "\n\tDisplayFloat %s, 0\n\tnewLine", operando);
    else if( strcmp(lex.tipoDato, "Float")==0 )
        sprintf(buffer, "\n\tDisplayFloat %s, 2\n\tnewLine", operando);

    agregarTextoAssembler(buffer);
}

void opLeerAssembler()
{
    char buffer[100];
    t_lexema lex;
    char* operando = desapilar(&pOperando); // recordar que puede ser id de cualquier tipo

    buscarEnlista(&listaTS, operando, &lex);
    if( strcmp(lex.tipoDato, "String")==0 )
        sprintf(buffer, "\n\tgetString %s\n\tnewLine", operando);
    else if( strcmp(lex.tipoDato, "Int")==0 || strcmp(lex.tipoDato, "Float")==0 )
        sprintf(buffer, "\n\tGetFloat %s\n\tnewLine", operando);

    agregarTextoAssembler(buffer);
}

void CPAssembler()
{
    char buffer[100];
    char* operando = desapilar(&pOperando);

    sprintf(buffer, "\n\tMOV EAX, %s\n\tCALL ES_PRIMO", operando);
    agregarTextoAssembler(buffer);
}

