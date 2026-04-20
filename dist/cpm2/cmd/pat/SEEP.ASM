;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This program is intended to be used from within a submit file to turn the  ;
;^P toggle on and off, although it may also be invoked from the console.  If ;
; the ^P toggle is off, this program turns it on; if on, it turns it off. In ;
; either event, it issues an appropriate message to the console which is also;
; echoed on the list device.
;
; The program calculates the location of the ^P toggle in the BDOS by getting;
; the BDOS address from the jump instruction located at 0005h in page zero   ;
; and adding 307h to that address. It then does an exclusive or of the toggle;
;byte to turn on or off ^P.

; NOTE: If xsub is to be active in the submit file, ^P must be turned on     ;
; BEFORE executing xsub. To turn off ^P in a submit file in which xsub is    ;
; active, execute a program that deactivates xsub, such as the DEXSUB program;
; which is listed following this program.                                    ;
;                 Doug Huskey & Dave Brown II                                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	org	0100h		;stay above base page
bdos	equ	5h		;BDOS jump instruction
bdosa	equ	bdos+1		;BDOS entry address
pstr	equ	9		;print string function
testoff	equ	2feh		;offest for verification
listcp	equ	0dh		;^P offset in page
mvic	equ	3eh		;MVI C,x instruction
cr	equ	0dh		;carriage return
lf	equ	0ah		;line feed

	lhld	bdosa		;pick up address of BDOS
	lxi	d,testoff	;offset of ^P page
	dad	d		;HL = compare area in BDOS
	lxi	d,string	;DE = compare string
compare:
	ldax	d		;is character a 0?
	ora	a		;
	jz	ok		;yes, we're done
	cmp	m		;is BDOS same as string?
	inx	h		;next byte
	inx	d		;
	jz	compare		;compare next byte if not finished
				;else loop for next byte
error:	mvi	c,pstr		;print error message
	lxi	d,errormsg	;
	jmp	bdos		;return to CCP from BDOS
ok:	mvi	l,listcp	;listcp page offset
	mvi	a,1		;toggle ^P byte on or off
	sub	m		;true = 1, false = 0
	mov	m,a		;put results back in memory
	cpi	0h		;see if on or off
	jz	othermsg	;to issue appropriate message
	lxi	d,onmsg		;^P turned on
	jmp	print		;go around
othermsg:
	lxi	d,offmsg	;^P turned off
print:	mvi	c,pstr		;print sign-on message
	jmp	bdos

onmsg:	db	cr,lf,'(^P turned on)$'
offmsg: db	cr,lf,'(^P turned off)$'
errormsg:
	db	cr,lf,'Unable to find BDOS$'
string:	db	ret,mvic,1,jmp,0
	end
