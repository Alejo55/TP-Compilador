@echo off

flex LexicoFinal.l
echo "FLEX Compilo La especificacion lexica del archivo LexicoFinal.l (Se creo un archivo lex.yy.c)"

bison -dyv SintacticoFinal.y
echo "BISON Compilo La especificacion sintactica del archivo SintacticoFinal.y (Se crearon los archivos y.tab.c, y.tab.h, y.output)"

gcc.exe lex.yy.c y.tab.c Lista.c Pila.c Lista-inter.c -o lyc-compiler-3.0.0.exe
echo "Se compilaron los archivos correspondientes utilizando GCC (Se creo un archivo lyc-compiler-3.0.0.exe)"

lyc-compiler-3.0.0.exe test.txt
echo "Se ejecuto el programa compilado lyc-compiler-3.0.0.exe sobre el archivo test.txt"

del lex.yy.c
del y.tab.c
del y.tab.h
del y.output

echo "Se borraron los archivos generados en todo este proceso, finalizando ... "

pause