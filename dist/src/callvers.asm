	; CALLVERS program

bdos	equ	5			; entry point for BDOS
prtstr	equ	9			; print string function
vers	equ	12			; get version function
cr	equ	0dh			; carriage return
lf	equ	0ah			; line feed

	org	100h
	mvi 	d,5			; Perform 5 times
loop:	push	d			; save counter
	mvi 	c,prtstr 
	lxi 	d,call$msg		; print call message
	call 	bdos
	mvi 	c,vers 
	call 	bdos			; try to get version #
					; CALLVERS will intercept
	mov 	a,l 
	sta	curvers
	pop 	d
	dcr 	d			; decrement counter
	jnz 	loop
	mvi 	c,0
	jmp 	bdos
call$msg:
	db	cr,lf,'**** CALLVERS **** $'
curvers	db	0
	end
