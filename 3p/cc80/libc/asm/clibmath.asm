; May 9, 1984  15:40  drm  "CLIBMATH.ASM"

;generated from LISTREL1 output of CLIBRARY.REL
;modified for use with RMAC (no ".","$" or "_" in labels)
; changed "$" to "@@", changed "_" to "?".
; (all "." labels duplicated with "@", so were deleted)

	public c?math
	public e@t,e@2,c@gt,c@le,c@lt,c@ge,c@uge,c@ule,c@ugt
	public c@ult,c@tst,c@asr,c@usr,c@asl,c@com,c@not,c@sxt,c@mult
	public c@udv,c@div,c@neg,o@,x@,a@,e@0,e@,n@,s@,s@1,g@,q@
	public @switc,h@

	extrn @@end

	cseg
c?math: org	0

	; .OR.
o@:	pop	b	;return address
	pop	d	;parameter in DE
	push	b
	mov	a,l	; HL=HL|DE
	ora	e	;
	mov	l,a	;
	mov	a,h	;
	ora	d	;
	mov	h,a	;
	ret

	; .XOR.
x@:	pop	b
	pop	d
	push	b
	mov	a,l
	xra	e
	mov	l,a
	mov	a,h
	xra	d
	mov	h,a
	ret

	; .AND.
a@:	pop	b
	pop	d
	push	b
	mov	a,l
	ana	e
	mov	l,a
	mov	a,h
	ana	d
	mov	h,a
	ret

	;force .TRUE. or .FALSE.
e@0:	mov	a,h
	ora	l
	rz
	;set .TRUE.
e@t:	lxi	h,0	;make .TRUE.
	;increment
e@2:	inr	l	;( 0001 )
	ret

	; .EQ.
e@:	pop	b
	pop	d
	push	b
	mov	a,h
	cmp	d
	mov	a,l
	lxi	h,0	;.FALSE.
	jnz	L0038
	cmp	e
	jnz	L0038
	inr	l	;.TRUE.
	ret
L0038:	xra	a
	ret

	; .NOT.
c@not:	mov	a,h
	ora	l	;if .FALSE.
	jz	e@2	;set .TRUE.
	lxi	h,0	;else set .FALSE.
	xra	a
	ret

	; .NE.
n@:	pop	b
	pop	d
	push	b
	mov	a,h
	cmp	d
	mov	a,l
	lxi	h,1
	rnz
	cmp	e
	rnz
	dcr	l
	ret

	; .GE.
c@ge:	xchg
	; .LE.
c@le:	mov	a,d
	cmp	h
	jnz	L0064
	mov	a,e
	cmp	l
	jnz	L006F
	lxi	h,0
	inr	l
	ret

	; .GT.
c@gt:	xchg
	; .LT.
c@lt:	mov	a,d
L0064:	xra	h
	jm	L0075
	mov	a,d
	cmp	h
	jnz	L006F
	mov	a,e
	cmp	l
L006F:	lxi	h,1	;set .TRUE.
	rc
L0073:	dcr	l	;set .FALSE.
	ret

L0075:	mov	a,h
	ana	a
	lxi	h,1	;set .TRUE.
	jm	L0073
	ora	l
	ret

	;
c@tst:	mov	a,h
	xri	80h
	mov	h,a
	dad	d
	ret

	;
c@uge:	xchg
	;
c@ule:	mov	a,h
	cmp	d
	jnz	L008D
	mov	a,l
	cmp	e
L008D:	lxi	h,1	;set .TRUE.
	jnc	L0095
	dcr	l
	ret
L0095:	ora	l
	ret

	;
c@ugt:	xchg
	;
c@ult:	mov	a,d
	cmp	h
	jnz	L009F
	mov	a,e
	cmp	l
L009F:	lxi	h,1	;set .TRUE.
	rc
	dcr	l
	ret

	;
c@asr:	xchg
L00A6:	mov	a,h	;extend sign thru shift...
	ral		;
L00A8:	dcr	e
	rm
	mov	a,h
	rar
	mov	h,a
	mov	a,l
	rar
	mov	l,a
	jmp	L00A6

	;
c@usr:	xchg
	xra	a
	jmp	L00A8

	;
c@asl:	xchg
L00B9:	dcr	e
	rm
	dad	h
	jmp	L00B9

	; subtract
s@:	pop	b
	pop	d
	push	b
	;
s@1:	mov	a,e
	sub	l
	mov	l,a
	mov	a,d
	sbb	h
	mov	h,a
	ret

	; negate
c@neg:	dcx	h
	; 1s compliment
c@com:	mov	a,h
	cma
	mov	h,a
	mov	a,l
	cma
	mov	l,a
	ret

	; get 8 bit value (sign extended)
g@:	mov	a,m
	; sign-extend A into HL
c@sxt:	mov	l,a	;test sign of 8 bit value
	rlc
	sbb	a	;make 00 of FF based on sign
	mov	h,a
	ret

	; get HL from pointer HL
h@:	mov	a,m
	inx	h
	mov	h,m
	mov	l,a
	ret

	; put HL into pointer
q@:	xchg
	pop	h	;return address
	xthl		;get paramter, put ret.adr back on stack
	mov	m,e
	inx	h
	mov	m,d
	xchg
	ret

	; SWITCH command
@switc: xchg
	pop	h
L00E6:	mov	c,m
	inx	h
	mov	b,m
	inx	h
	mov	a,b
	ora	c
	jz	L00FD
	mov	a,m
	inx	h
	cmp	e
	mov	a,m
	inx	h
	jnz	L00E6
	cmp	d
	jnz	L00E6
	mov	h,b
	mov	l,c
L00FD:	pchl

	; multiply
c@mult: mov	b,h
	mov	c,l
	lxi	h,0
	mov	a,d
	ora	a
	mvi	a,16
	jnz	L010D
	mov	d,e
	mov	e,h
	rrc	; 8
L010D:	dad	h
	xchg
	dad	h
	xchg
	jnc	L0115
	dad	b
L0115:	dcr	a
	jnz	L010D
	ret

	; unsigned division
c@udv:	xra	a
	push	psw
	jmp	L012A

	; division
c@div:	mov	a,d
	xra	h
	push	psw
	xra	h
	xchg
	cm	c@neg
	xchg
	mov	a,h
	ora	a
L012A:	cp	c@neg
	mov	c,l
	mov	b,h
	lxi	h,0
	mov	a,b
	inr	a
	jnz	L013E
	mov	a,d
	add	c
	mvi	a,16
	jc	L0143
L013E:	mov	l,d
	mov	d,e
	mov	e,h
	mvi	a,8
L0143:	dad	h
	xchg
	dad	h
	xchg
	jnc	L014B
	inx	h
L014B:	push	h
	dad	b
	pop	h
	jnc	L0153
	dad	b
	inx	d
L0153:	dcr	a
	jnz	L0143
	xchg
	pop	psw
	rp
	xchg
	call	c@neg
	xchg
	jmp	c@neg
	ret

	end
