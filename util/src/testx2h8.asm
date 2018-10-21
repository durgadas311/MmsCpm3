;****************************************************************
; X/2-H8 Banked Memory Test Program		 		*
;****************************************************************
rev	equ	'3'

	maclib z80

true	equ -1
false	equ not true

useldir	equ	true
delay	equ	0

cr	equ 13
lf	equ 10
bell	equ 7

cpm	equ	0000h
bdos	equ	0005h
cmd	equ	0080h
ctl	equ	000dh

; ctl port bit to twiddle...
errbit	equ	01000000b	; H17 side select
ctlport	equ	0f2h		;

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
 if delay
	call	sleep
 endif
	lda	ctl
	sta	gpp

again:
	lda	gpp
	ori	errbit
	out	ctlport
	lda	gpp
	out	ctlport

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
 if delay
	call	sleep
 endif
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
	; verify pattern was not corrupted...
	mvi	a,10h
	lxix	patcnt
	mvi	e,0
	lxi	h,patbuf
	mvi	b,0	; 0 == 256
done1:
	cmp	m
	jz	done2
	inrx	+0
	ldx	c,+1
	inr	c
	jnz	done2
	stx	e,+1
done2:
	inx	h
	inr	e
	adi	1
	daa
	djnz	done1

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
	ldx	a,+7
	lxi	h,res5
	call	decout
	ldx	a,+8
	lxi	h,res6
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
	lda	patcnt
	lxi	h,pat1
	call	decout
	lda	paterr
	lxi	h,pat2
	call	hexout
	lxi	d,patchk
	mvi	c,msgout
	call	bdos

	jmp	cpm

 if delay
sleep:
	lxi	b,delay
slp0:
	dcx	b
	mov	a,b
	ora	c
	jnz	slp0
	ret
 endif

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
res4:	db	'hh xref: '
res5:	db	'nnn '
res6:	db	'hh',cr,lf,'$'

patchk:	db	'Pattern Check: '
pat1:	db	'nnn '
pat2:	db	'hh    Rev: ',rev,cr,lf,'$'

bnksetup:
	ldx	a,+1
	out	mmu
	ldx	a,+2
	out	mmu
 if delay
	call	sleep
 endif
	lhld	patptr
	ldx	e,+0
	mvi	d,0
	dad	d	; HL = pattern
	lxi	d,tstbuf
	lxi	b,128
 if useldir
	ldir
 else
	call	doldir
 endif
	ret

bnktest:
	ldx	a,+1
	out	mmu
	ldx	a,+2
	out	mmu
 if delay
	call	sleep
 endif
	lhld	patptr
	ldx	e,+0
	mvi	d,0
	dad	d	; HL = pattern
	push	h
	lxi	d,tstbuf
	call	bnkck9
	jz	ok1
	inrx	+3
	ldx	a,+4
	inr	a
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
 if useldir
	ldir
 else
	call	doldir
 endif
	lxi	h,cpybuf
	lxi	d,tstbuf
	call	bnkck9
	jz	ok2
	inrx	+5
	ldx	a,+6
	inr	a
	jnz	more2
	stx	e,+6
more2:
	call	bnkck7
	jz	ok2
	inrx	+5
	jmp	more2
ok2:
	pop	h
	lxi	d,cpybuf
	call	bnkck9
	jz	ok3
	inrx	+7
	ldx	a,+8
	inr	a
	jnz	more3
	mov	a,e
	sui	LOW cpybuf
	stx	a,+8
more3:
	call	bnkck7
	jz	ok3
	inrx	+7
	jmp	more3
ok3:
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
	xra	a
	ret

 if useldir
 else
doldir:
	mov	a,m
	stax	d
	inx	h
	inx	d
	dcx	b
	mov	a,b
	ora	c
	jnz	doldir
	ret
 endif

banks:
	db	0	; bank ID - bank 0
	db	00111111b,00000000b	; bank select, assumes sequence
	db	0,0ffh,0,0ffh,0,0ffh,0,0,0,0,0,0,0 ; results
 if ($-banks) != 16
	.error "Wrong struct length"
 endif

	db	1	; bank ID - bank 1
	db	00000001b,00011110b	; bank select, assumes sequence
	db	0,0ffh,0,0ffh,0,0ffh,0,0,0,0,0,0,0 ; results

	db	2	; bank ID - bank 2
	db	00011111b,00101110b	; bank select, assumes sequence
	db	0,0ffh,0,0ffh,0,0ffh,0,0,0,0,0,0,0 ; results

	db	3	; bank ID - bank 3
	db	00101111b,00111110b	; bank select, assumes sequence
	db	0,0ffh,0,0ffh,0,0ffh,0,0,0,0,0,0,0 ; results

patcnt:	db	0
paterr:	db	0ffh

patbuf:	ds	256
cpybuf:	ds	256

	ds	256
stack:	ds	0

	end
