;	title	mcd80d
	CSEG
;	September 14, 1982

	EXTRN	INITDIR

;	EXECUTION BEGINS HERE
;
;	JMP 	around	; JMP inserted by LINK

;	PATCH AREA, DATE, VERSION & SERIAL NOS.

patch1:	shld 777ah
	shld 7a7ch
	jmp 0d01h

patch2:	lxi h,4661h
	push h
	mvi m,'c'	; low 4663h
	inx h
	mvi m,'F'	; high 4663h
	pop h
	call 1003h	; never returns (exit)

;	dw	0,0,0,0,0,0,0,0
	dw	0,0,0,0,0; 0,0,0
	dw	0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0
	db	0
	db	'CP/M Version 3.0'
	db	'COPYRIGHT 1982, '
	db	'DIGITAL RESEARCH'
	db	'151282'	; version date day-month-year
	db	0,0,0,3		; patch bit map
	db	'654321'	; Serial no.
around:
	db	0,0,0

	END
