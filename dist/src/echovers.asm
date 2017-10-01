	; ECHOVERS RSX

pstring	equ	9			; string print function
cr	equ	0dh
lf	equ	0ah
;
;		RSX PREFIX STRUCTURE
;
	db	0,0,0,0,0,0		; room for serial number
	jmp	ftest			; begin of program
next	db	0c3H			; jump
        dw	0			; next module in line
prev:	dw	0			; previous module
remov:	db	0ffh			; remove flag set
nonbnk:	db	0
	db	'ECHOVERS'
space:	ds	3

ftest:					; is this function 12?
	mov 	a,c 
	cpi 	12 
	jz 	begin			; yes - intercept
        jmp 	next			; some other function 

begin:
	lxi 	h,0	
	dad 	sp 			;save stack
	shld 	ret$stack
	lxi 	sp,loc$stack

	mvi 	c,pstring 
	lxi 	d,test$msg		; print message
	call 	next			; call BDOS

	lhld 	ret$stack 		; restore user stack
	sphl
	lxi 	h,0031h			; return version number = 0031h
	ret

test$msg:
	db	cr,lf,'**** ECHOVERS **** $'
ret$stack:	
	dw	0
	ds	32			; 16 level stack
loc$stack:
	end
