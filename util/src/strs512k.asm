;****************************************************************
; H8-512K Banked Memory Stress Test Program		 		*
;****************************************************************
rev	equ	'2'

; NOTE: This program does a continuous stress test of one
; page mapped into segment 4000H.

SEED0	equ	0	; initial pattern seed

buf16K	equ	16*1024
buf32K	equ	32*1024

	maclib z80

true	equ -1
false	equ not true

cr	equ 13
lf	equ 10
bell	equ 7

cpm	equ	0000h
bdos	equ	0005h
cmd	equ	0080h
ctl	equ	000dh

ctlport	equ	0f2h
errbit	equ	01000000b	; H17 side-select

console	equ	0e8h		; console INS8250 port, already setup

; BDOS functions
conin	equ	1
msgout	equ	9
vers	equ	12

mmu	equ	050h	; H8-512K Bank Switch Board base port
rd00K	equ	mmu+0
rd16K	equ	mmu+1
rd32K	equ	mmu+2
rd48K	equ	mmu+3
wr00K	equ	mmu+4
wr16K	equ	mmu+5
wr32K	equ	mmu+6
wr48K	equ	mmu+7

	org	100h

	mvi	a,1
	sta	pgnum
	mvi	a,mmu
	lxi	h,port
	call	hexout
	lxi	d,signon
	mvi	c,msgout
	call	bdos
	mvi	c,vers
	call	bdos
	mov	a,l
	cpi	22h
	jnz	cpm3
	jmp	start

invprm:	lxi	d,pgerr
	jmp	errout

cpm3:	lxi	d,cpmerr
errout:	mvi	c,msgout
	jmp	bdos	; return to CCP (LOADER)

cpmerr:	db	cr,lf,bell,'Requires CP/M 2.2 - only!$'
pgerr:	db	cr,lf,bell,'Invalid/Illegal page number. Use 1,4-31.$' 

seed:	db	0
pgnum:	db	0
err0:	db	0

; If current mapping is not the default/disabled,
; things will likely crash here.
mmu$init:
	di
	mvi	a,0	; page 0
	out	rd00K
	out	wr00K
	inr	a
	out	rd16K
	out	wr16K
	inr	a
	out	rd32K
	out	wr32K
	inr	a
	ori	080h	; MMU enable
	out	rd48K
	out	wr48K
	ei
	ret

mmu$deinit:
	di
	; leave 080h off, disable MMU and force "pass-thru" mapping.
	; really, only one OUT needs to be done, but just restore all.
	; overkill, since we only ever changed rd/wr16K.
	mvi	a,0
	out	rd00K
	out	wr00K
	inr	a
	out	rd16K
	out	wr16K
	inr	a
	out	rd32K
	out	wr32K
	inr	a
	out	rd48K
	out	wr48K
	ei
	ret

start:
	lxi	sp,stack
	call	mmu$init
	mvi	c,SEED0	; for now, just free-run seed since
			; a BCD pattern won't repreat in a binary
			; address space, at least not often.
	di

tst4:	lda	pgnum
	ori	80h
	out	rd16K	; map into 16K
	out	wr16K	;

tst1:	lxi	h,buf16K
tst0:	mov	m,c
	mov	a,m
	cmp	c
	jz	byteok
	lda	ctl
	ori	errbit
	out	ctlport
	lda	ctl
	out	ctlport
	lda	err0
	inr	a
	jz	byteok	; prevent overflow
	sta	err0
byteok:	mov	a,c
	adi	1
	daa
	mov	c,a
	inx	h
	mov	a,h
	cpi	high buf32K
	jc	tst0
	; buffer wrap...
	mov	a,c	; bump seed, to avoid all even
	adi	1
	daa
	mov	c,a
	in	console+5
	ani	1	; RxD ready
	jnz	done
	lda	pgnum
	cpi	1
	jnz	tst2
	inr	a
	inr	a
tst2:	inr	a
	cpi	32
	jc	tst3
	mvi	a,1
tst3:	sta	pgnum
	jmp	tst4

; done with test... user intervention...
done:	call	mmu$deinit	; enables intrs
	mvi	c,conin
	call	bdos
	lda	err0
	lxi	h,res1
	call	decout
	lda	pgnum
	lxi	h,res0
	call	decout
	lxi	d,result
	mvi	c,msgout
	call	bdos
	jmp	cpm

; HL=>text number, leading blanks skipped. stops at NUL or non-numeric (CY).
; Returns DE=number, CY for overflow/error
decin:
di0:	mov	a,m
	ora	a
	rz
	inx	h
	cpi	' '
	jz	di0
	dcx	h
	lxi	d,0
di1:	mov	a,m
	ora	a
	rz
	cpi	' '
	rz
	cpi	'0'
	rc
	cpi	'9'+1
	cmc
	rc
	xchg
	mov	c,l
	mov	b,h
	dad	h	; *2
	jc	di2
	dad	h	; *4
	jc	di2
	dad	b	; *5
	jc	di2
	dad	h	; *10
	jc	di2
	sui	'0'
	mov	c,a
	mvi	b,0
	dad	b
	xchg
	inx	h
	jmp	di1
di2:	mov	l,c
	mov	h,b
	xchg
	stc
	ret

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

result:	db	'Stopped at page'
res0:	db	'nnn at 4000H errs '
res1:	db	'nnn ',cr,lf,'$'

signon:	db	'Stress H8-512K rev ',rev,' port '
port:	db	'hh all pages 1,4-31',cr,lf,'$'

	ds	256
stack:	ds	0

	end
