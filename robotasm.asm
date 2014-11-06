section .data
errFile:	db	"No se pudo abrir el archivo", 10, 0
format:		db	"%d", 10, 0
count:		db	0
bufSize:	dd	6

section	.bss
buf:	resb	6
letter:	resd	1
fd:	resd	1
digit:	resd	1

section .text	
	extern	shoulderAngle
	extern	elbowAngle
	extern	glutPostRedisplay
	extern	glutTimerFunc
	extern	printf

	global	iniciaCiclo
	global	specialKey

iteracion: 
	push	ebp
	mov	ebp,	esp
	push	ebx
	push	edi
	push	esi

	mov	eax,	3h ; read code
	mov	ebx,	[fd]
	mov	ecx,	buf
	mov	edx,	[bufSize]
	int	80h

	cmp	eax,	[bufSize]
	jl	iteracionExit
	
	mov	eax,	4h ; write code
	mov	ebx,	1 ; stdin
	int	80h

	mov	ecx,	[buf]
	and	ecx,	0000ffh
	mov	[letter],ecx

	mov	dword	[digit],    0h

	mov	esi,    [buf+2]
	and	esi,	0000ffh
	sub	esi,	30h
	lea	esi,    [esi*4 + esi]
	lea	esi,    [esi*4  + esi]
	shl	esi,    2
	add	[digit],	esi

	mov	esi,    [buf+3]
	and	esi,	0000ffh
	sub	esi,	30h
	lea	esi,    [esi*4 + esi]
	shl	esi,    1
	add	[digit],	esi	
	
	mov	esi,    [buf+4]
	and	esi,	0000ffh
	sub	esi,	30h	
	add	[digit],	esi

	mov	esi,	[letter]
	
	;le switch
	cmp	esi,	41h ;A
	jne	switch1
	mov	ecx,	[shoulderAngle]
	add	ecx,	[digit]

	cmp	ecx,	360
	jl	endShoSwitch
	mov 	esi,	1
	jmp	modulo
	
switch1:
	cmp	esi,	42h ;B
	jne	switch2
	mov	ecx,	[shoulderAngle]
	sub	ecx,	[digit]

	cmp	ecx,	-360
	jg	endShoSwitch
	mov 	esi,	1
	jmp	modulo

switch2:	
	cmp	esi,	49h ;I
	jne	switch3
	mov	ecx,	[elbowAngle]
	add	ecx,	[digit]

	cmp	ecx,	360
	jl	endElSwitch
	mov 	esi,	0
	jmp	modulo

switch3:
	mov	ecx,	[elbowAngle]
	sub	ecx,	[digit]

	cmp	ecx,	-360
	jg	endElSwitch
	mov 	esi,	0
	jmp	modulo

endSwitch:
	call	glutPostRedisplay
	push	iteracion
	push	1000
	call	glutTimerFunc
	add	esp,	8
	
iteracionExit:
	pop	esi
	pop	edi
	pop	ebx
	mov	esp,	ebp
	pop	ebp
	ret

iniciaCiclo:
	push	ebp
	mov	ebp,	esp
	push	ebx

	mov	eax,	5h 
	mov	ebx,	[ebp+8] ;mando el param
	mov	ecx,	0 ; read only
	mov	edx,	0777 
	int	80h
	
	cmp	eax,	0 
	jge	cont ; si devolvio -1 hay un error
	mov	eax,	4h; write code
	mov	ebx,	2 ; sterr
	mov	ecx,	errFile ; buffer
	mov	edx,	29
	int	80h	
	jmp	openErrExit

cont:
	mov	[fd],	eax
	mov	byte	[count],0

	push	iteracion
	push	1000
	call	glutTimerFunc
	add	esp,	8
	

cicloExit:
	mov	eax,	0
	jmp	ex
openErrExit:
	mov	eax,	1
	jmp	ex
ex:
	pop	ebx
	mov	esp,	ebp
	pop	ebp
	ret

specialKey:
	mov	edx,	[esp+4] ; guardo param
	
	cmp	edx,	64h
	jne	case2
	
	;caso left
	mov	ecx,	[elbowAngle]
	add	ecx,	5

	cmp	ecx,	360
	jl	caseElExit
	mov	esi,	2
	jmp	modulo

case2:
	cmp	edx,	66h
	jne	case3
	
	; caso right
	mov	ecx,	[elbowAngle]
	sub	ecx,	5

	cmp	ecx,	-360
	jg	caseElExit
	mov	esi,	2
	jmp	modulo

caseElExit:
	mov	[elbowAngle],	ecx
	jmp	modExit

case3:
	cmp	edx,	65h
	jne	case4
	
	;caso up
	mov	ecx,	[shoulderAngle]
	add	ecx,	5

	cmp	ecx,	360
	jl	caseShoExit
	mov	esi,	3
	jmp	modulo

case4:
	cmp	edx,	67h
	jne	def
	
	;case down
	mov	ecx,	[shoulderAngle]
	sub	ecx,	5

	cmp	ecx,	-360
	jg	caseShoExit
	mov	esi,	3
	jmp	modulo

caseShoExit:
	mov	[shoulderAngle],	ecx
	jmp	modExit

def:
	mov	eax,	0
	ret

modExit:
	call	glutPostRedisplay
	mov	eax,	0
	ret

; codigo compartido por iteracion y specialKey
; ew
modulo:
	mov	eax,	ecx
	cdq
	mov	ecx,	360
	idiv	ecx
	mov	ecx,	edx
	cmp	esi,	0
	je	endElSwitch
	cmp	esi,	1
	je	endShoSwitch
	cmp	esi,	2
	je	endElSpecial
	jmp	endShoSpecial
endElSwitch:
	mov	[elbowAngle],	ecx
	jmp	endSwitch
endShoSwitch:
	mov	[shoulderAngle],ecx
	jmp	endSwitch
endElSpecial:
	mov	[elbowAngle],	ecx
	jmp	modExit
endShoSpecial:
	mov	[shoulderAngle],ecx
	jmp	modExit
