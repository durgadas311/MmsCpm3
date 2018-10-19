;****************************************************************
; X/2-H8 Banked Memory Test Program		 		*
;****************************************************************
	maclib z80

true	equ -1
false	equ not true

cr	equ 13
lf	equ 10
bell	equ 7

cpm	equ	0000h
bdos	equ	0005h
cmd	equ	0080h
ctl	equ	0007h	; TODO: where is this?

; BDOS functions
msgout	equ	9
vers	equ	12

mmu	equ	000h	; Trionyx X/2-H8 Bank Switch Board

	org	100h

tstbuf:	ds	0

	mvi	c,vers
	call	bdos
	mov	a,l
	cpi	22h
	jnz	cpm3
	lxi	h,cmd
	mov	a,m
	ora	a
	jz	start
skip:	inx	h
	mov	a,m
	cpi	' '
	jz	skip
	ani	11011111b	; toupper
	cpi	'C'
	jnz	start
	sta	cont
	jmp	start

cpm3:	lxi	d,cpmerr
	mvi	c,msgout
	jmp	bdos	; return to CCP (LOADER)

cpmerr:	db	cr,lf,bell,'Requires CP/M 2.2 - only!$'

	; cheat: avoid having to relocate code here
	org	4000h
cont:	db	0	; continuous mode
gpp:	db	0
patptr:	dw	0

start:
	lxi	sp,stack

	; setup pattern buffer
	mvi	a,10h
	lxi	h,patbuf
	shld	patptr
	mvi	b,0	; 0 == 256
bnkck1:
	mov	m,a
	inx	h
	adi	1
	daa
	djnz	bnkck1

	di
	; ensure banks initialized... risks?
	; if we are not already in bank 0, this will crash
	mvi	a,00011111b
	out	mmu
	mvi	a,00101111b
	out	mmu
	mvi	a,00111111b
	out	mmu
	mvi	a,00000000b
	out	mmu
	lda	ctl
	sta	gpp

again:

	; copy diff pattern to each bank
	lxix	banks
	call	bnksetup	; bank 0
	lxi	b,16
	dadx	b
	call	bnksetup	; bank 1
	lxi	b,16
	dadx	b
	call	bnksetup	; bank 2
	lxi	b,16
	dadx	b
	call	bnksetup	; bank 3

	lxix	banks
	; check pattern in each bank
	call	bnktest	; bank 0
	lxi	b,16
	dadx	b
	call	bnktest	; bank 1
	lxi	b,16
	dadx	b
	call	bnktest	; bank 2
	lxi	b,16
	dadx	b
	call	bnktest	; bank 3
	lxix	banks	; must restore bank 0...
	ldx	a,+1
	out	mmu
	ldx	a,+2
	out	mmu
	ei

	lda	cont
	ora	a
	jz	done
	lhld	patptr
	lxi	d,4
	dad	d
	mov	a,l
	sui	LOW patbuf
	cpi	64
	jc	agn0
	lxi	h,patbuf
agn0:
	shld	patptr
	; TODO: clear results?
	di
	lda	ctl
	sta	gpp
	jmp	again

done:
	; report results...
	lxix	banks
	mvi	b,4
done0:
	ldx	a,+0
	adi	'0'
	sta	res0
	ldx	a,+3
	lxi	h,res1
	call	decout
	ldx	a,+4
	lxi	h,res2
	call	hexout
	ldx	a,+5
	lxi	h,res3
	call	decout
	ldx	a,+6
	lxi	h,res4
	call	hexout
	push	b
	pushix
	lxi	d,result
	mvi	c,msgout
	call	bdos
	popix
	pop	b
	lxi	d,16
	dadx	d
	djnz	done0

	jmp	cpm

; leading zeroes blanked - must preserve B
decout:
	mvi	c,0
	mvi	d,100
	call	divide
	mvi	d,10
	call	divide
	adi	'0'
	mov	m,a
	inx	h
	ret

divide:	mvi	e,0
div0:	sub	d
	inr	e
	jrnc	div0
	add	d
	dcr	e
	jrnz	div1
	bit	0,c
	jrnz	div1
	mvi	m,' '
	inx	h
	ret
div1:	setb	0,c
	push	psw	; remainder
	mvi	a,'0'
	add	e
	mov	m,a
	inx	h
	pop	psw	; remainder
	ret

hexout:	push	psw
	rlc
	rlc
	rlc
	rlc
	call	hex0
	pop	psw
hex0:	ani	0fh
	adi	90h
	daa
	aci	40h
	daa
	mov	m,a
	inx	h
	ret

result:	db	'Bank '
res0:	db	'x copy 1: '
res1:	db	'nnn '
res2:	db	'hh copy 2: '
res3:	db	'nnn '
res4:	db	'hh',cr,lf,'$'

bnksetup
	ldx	a,+1
	out	mmu
	ldx	a,+2
	out	mmu
	lhld	patptr
	ldx	e,+0
	mvi	d,0
	dad	d
	lxi	d,tstbuf
	lxi	b,128
	ldir
	ret

bnktest:
	ldx	a,+1
	out	mmu
	ldx	a,+2
	out	mmu
	lhld	patptr
	ldx	e,+0
	mvi	d,0
	dad	d
	push	h	; pattern
	lxi	d,tstbuf
	call	bnkck9
	jz	ok1
	inrx	+3
	ldx	a,+4
	ora	a
	jnz	more1
	stx	e,+4
more1:
	call	bnkck7
	jz	ok1
	inrx	+3
	jmp	more1
ok1:
	lxi	h,tstbuf
	lxi	d,cpybuf
	lxi	b,128
	ldir
	pop	h	; pattern
	lxi	d,cpybuf
	call	bnkck9
	jz	ok2
	inrx	+5
	ldx	a,+6
	ora	a
	jnz	more2
	mov	a,e
	sub	LOW cpybuf
	stx	a,+6
more2:
	call	bnkck7
	jz	ok2
	inrx	+5
	jmp	more2
ok2:
	ret

bnkck9:
	mvi	b,128
bnkck8:
	ldax	d
	cmp	m
	rnz
bnkck7:
	inx	h
	inx	d
	djnz	bnkck8
	ret

banks:
	db	0	; bank ID - bank 0
	db	00111111b,00000000b	; bank select, assumes sequence
	db	0,0,0,0,0,0,0,0,0,0,0,0,0 ; results
 if ($-banks) != 16
	.error "Wrong struct length"
 endif

	db	1	; bank ID - bank 1
	db	00000001b,00011110b	; bank select, assumes sequence
	db	0,0,0,0,0,0,0,0,0,0,0,0,0 ; results

	db	2	; bank ID - bank 2
	db	00011111b,00101110b	; bank select, assumes sequence
	db	0,0,0,0,0,0,0,0,0,0,0,0,0 ; results

	db	3	; bank ID - bank 3
	db	00101111b,00111110b	; bank select, assumes sequence
	db	0,0,0,0,0,0,0,0,0,0,0,0,0 ; results

patbuf:	ds	256
cpybuf:	ds	256

	ds	256
stack:	ds	0

	end
