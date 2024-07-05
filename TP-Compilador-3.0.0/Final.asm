include macros2.asm
include number.asm

.MODEL LARGE
.386
.STACK 200h

MAXTEXTSIZE equ 40

.DATA

	x	dd	?
	z	dd	?
	a	dd	?
	b	dd	?
	c	dd	?
	var_entera	dd	?
	variable1	dd	?
	var_flotante	dd	?
	y	db	MAXTEXTSIZE dup (?),'$'
	p1	db	MAXTEXTSIZE dup (?),'$'
	var_cadena	db	MAXTEXTSIZE dup (?),'$'
	_cte_23	dd	23.0
	@auxAsigNum	dd	?
	_cte_neg15_6	dd	-15.6
	_cte_0_6	dd	0.6
	_cte_5_0	dd	5.0
	_cte_hola	db	"hola",'$', 36 dup (?)
	@auxAsigString	db	MAXTEXTSIZE dup (?),'$'
	_cte_2	dd	2.0
	_cte_1	dd	1.0
	_cte_3	dd	3.0
	_cte_30	dd	30.0
	_cte_60	dd	60.0
	_cte_10	dd	10.0
	_cte_42	dd	42.0
	_cte_5	dd	5.0
	_cte_Pepe	db	"Pepe",'$', 36 dup (?)
	_cte_pepito	db	"pepito",'$', 34 dup (?)
	_cte_123	dd	123.0
	_cte_a_es_mas_grande_que_b	db	"a es mas grande que b",'$', 19 dup (?)
	_cte_200	dd	200.0
	_cte_hola_Mundo	db	"hola Mundo",'$', 30 dup (?)
	_cte_Ingresar_cte_string	db	"Ingresar cte string",'$', 21 dup (?)
	_cte_cte_string_ingresada_es	db	"cte string ingresada es",'$', 17 dup (?)
	_cte_neg53	dd	-53.0
	_cte_7	dd	7.0
	@auxCP	dd	0.0
	_cte_Resultado_CP_es	db	"Resultado CP es",'$', 25 dup (?)
	_cte_15	dd	15.0
	_cte_11	dd	11.0
	_cte_resultado_de_x_en_UP_es	db	"resultado de x en UP es",'$', 17 dup (?)
	@auxAssembler10	dd	?
	@auxAssembler9	dd	?
	@auxAssembler8	dd	?
	@auxAssembler7	dd	?
	@auxAssembler6	dd	?
	@auxAssembler5	dd	?
	@auxAssembler4	dd	?
	@auxAssembler3	dd	?
	@auxAssembler2	dd	?
	@auxAssembler1	dd	?
	@auxAssembler0	dd	?

.CODE


START:
	MOV AX, @DATA
	MOV DS, AX
	MOV es,ax


	FLD _cte_23
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP x
	FLD _cte_neg15_6
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP variable1
	FLD _cte_0_6
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP variable1
	FLD _cte_5_0
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP variable1
	MOV SI, OFFSET _cte_hola
	MOV DI, OFFSET @auxAsigString
	CALL COPIAR
	MOV SI, OFFSET @auxAsigString
	MOV DI, OFFSET y
	CALL COPIAR
	FLD _cte_2
	FLD _cte_1
	FMUL
	FSTP @auxAssembler0
	FLD @auxAssembler0
	FLD _cte_3
	FADD
	FSTP @auxAssembler1
	FLD @auxAssembler1
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP a
	FLD @auxAsigNum
	FSTP x
	FLD @auxAsigNum
	FSTP z
	FLD _cte_30
	FLD z
	FSUB
	FSTP @auxAssembler2
	FLD @auxAssembler2
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP x
	DisplayFloat x, 0
	newLine
	FLD _cte_60
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP x
	FLD x
	FCOMP _cte_10
	FSTSW AX
	SAHF
	JGE ET_75
	FLD _cte_23
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP x
	JMP ET_81
ET_75:
	FLD _cte_42
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP x
ET_81:
	DisplayFloat x, 0
	newLine
	FLD x
	FCOMP _cte_10
	FSTSW AX
	SAHF
	JLE ET_101
	FLD x
	FCOMP _cte_23
	FSTSW AX
	SAHF
	JGE ET_101
	FLD _cte_23
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP x
	JMP ET_107
ET_101:
	FLD _cte_42
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP x
ET_107:
	FLD _cte_5
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP a
	FLD _cte_3
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP b
	FLD b
	FCOMP a
	FSTSW AX
	SAHF
	JL ET_129
	FLD x
	FCOMP z
	FSTSW AX
	SAHF
	JLE ET_133
ET_129:
	displayString _cte_Pepe
	newLine
	JMP ET_139
ET_133:
	MOV SI, OFFSET _cte_pepito
	MOV DI, OFFSET @auxAsigString
	CALL COPIAR
	MOV SI, OFFSET @auxAsigString
	MOV DI, OFFSET y
	CALL COPIAR
ET_139:
	MOV SI, OFFSET _cte_pepito
	MOV DI, OFFSET @auxAsigString
	CALL COPIAR
	MOV SI, OFFSET @auxAsigString
	MOV DI, OFFSET y
	CALL COPIAR
	displayString y
	newLine
	FLD z
	FCOMP _cte_123
	FSTSW AX
	SAHF
	JLE ET_165
	FLD x
	FCOMP _cte_2
	FSTSW AX
	SAHF
	JL ET_165
	FLD _cte_23
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP x
ET_165:
	FLD _cte_3
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP a
	FLD _cte_1
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP b
ET_175:
	FLD a
	FCOMP b
	FSTSW AX
	SAHF
	JLE ET_193
	displayString _cte_a_es_mas_grande_que_b
	newLine
	FLD b
	FLD _cte_1
	FADD
	FSTP @auxAssembler3
	FLD @auxAssembler3
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP b
	JMP ET_175
ET_193:
	FLD z
	FCOMP _cte_23
	FSTSW AX
	SAHF
	JE ET_216
ET_198:
	FLD z
	FCOMP _cte_23
	FSTSW AX
	SAHF
	JE ET_214
	FLD z
	FLD _cte_1
	FADD
	FSTP @auxAssembler4
	FLD @auxAssembler4
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP z
	JMP ET_198
ET_214:
ET_216:
	FLD a
	FCOMP b
	FSTSW AX
	SAHF
	JLE ET_246
ET_220:
	FLD b
	FCOMP _cte_10
	FSTSW AX
	SAHF
	JG ET_236
	FLD b
	FLD _cte_1
	FADD
	FSTP @auxAssembler5
	FLD @auxAssembler5
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP b
	JMP ET_220
ET_236:
	FLD a
	FLD _cte_1
	FADD
	FSTP @auxAssembler6
	FLD @auxAssembler6
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP a
	JMP ET_214
ET_246:
	FLD _cte_1
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP x
	FLD _cte_1
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP a
	FLD _cte_200
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP b
ET_264:
	FLD x
	FCOMP a
	FSTSW AX
	SAHF
	JNE ET_275
	FLD b
	FCOMP _cte_200
	FSTSW AX
	SAHF
	JNE ET_287
ET_275:
	displayString _cte_hola_Mundo
	newLine
	FLD b
	FLD _cte_1
	FADD
	FSTP @auxAssembler7
	FLD @auxAssembler7
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP b
	JMP ET_264
ET_287:
	FLD x
	FCOMP z
	FSTSW AX
	SAHF
	JE ET_334
	FLD z
	FCOMP x
	FSTSW AX
	SAHF
	JGE ET_316
ET_298:
	FLD z
	FCOMP x
	FSTSW AX
	SAHF
	JGE ET_314
	FLD z
	FLD _cte_1
	FADD
	FSTP @auxAssembler8
	FLD @auxAssembler8
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP z
	JMP ET_298
ET_314:
	JMP ET_332
ET_316:
	FLD z
	FCOMP x
	FSTSW AX
	SAHF
	JLE ET_332
	FLD x
	FLD _cte_1
	FADD
	FSTP @auxAssembler9
	FLD @auxAssembler9
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP x
	JMP ET_316
ET_332:
	JMP ET_287
ET_334:
	displayString _cte_Ingresar_cte_string
	newLine
	getString p1
	newLine
	displayString _cte_cte_string_ingresada_es
	newLine
	displayString p1
	newLine
	FLD _cte_3
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP x
	FLD @auxAsigNum
	FSTP z
	FLD _cte_2
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP b
	FLD @auxAsigNum
	FSTP a
	FLD _cte_neg53
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP c
	MOV EAX, _cte_7
	CALL ES_PRIMO
	FLD @auxCP
	FSTP x
	displayString _cte_Resultado_CP_es
	newLine
	DisplayFloat x, 0
	newLine
	FLD _cte_15
	FSTP @auxAsigNum
	FLD @auxAsigNum
	FSTP x
ET_381:
	FLD _cte_11
	FCOMP x
	FSTSW AX
	SAHF
	JG ET_394
	FLD x
	FLD _cte_3
	FDIV
	FSTP @auxAssembler10
	FLD @auxAssembler10
	FSTP x
	JMP ET_381
ET_394:
	displayString _cte_resultado_de_x_en_UP_es
	newLine
	DisplayFloat x, 0
	newLine
	MOV AX, 4C00h
	INT 21h



STRLEN PROC NEAR
	mov bx, 0
STRL01:
	cmp BYTE PTR [SI+BX],'$'
	je STREND
	inc BX
	jmp STRL01
STREND:
	ret
STRLEN ENDP

COPIAR PROC NEAR
	call STRLEN
	cmp bx,MAXTEXTSIZE
	jle COPIARSIZEOK
	mov bx,MAXTEXTSIZE
COPIARSIZEOK:
	mov cx,bx
	cld
	rep movsb
	mov al,'$'
	mov BYTE PTR [DI],al
	ret
COPIAR ENDP

ES_PRIMO PROC NEAR
	cmp eax, 2
	jb CASO_NO_PRIMO
	je CASO_PRIMO
	mov ebx, eax
	mov ecx, 2
CHEQUEAR_DIVISOR:
	mov eax, ecx
	mul ecx
	cmp eax, ebx
	ja CASO_PRIMO
	mov eax, ebx
	xor edx, edx
	div ecx
	cmp edx, 0
	je CASO_NO_PRIMO
	inc ecx
	jmp CHEQUEAR_DIVISOR
CASO_NO_PRIMO:
	ret
CASO_PRIMO:
	fld @auxCP
	fld1
	fadd
	fstp @auxCP
	ret
ES_PRIMO endp

END START
