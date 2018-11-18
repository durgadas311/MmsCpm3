;****************************************************************
; H8-512K Banked Memory Test Program		 		*
;****************************************************************
rev	equ	'1'

; NOTE: This does not test every single bit in memory,
; but does confirm that 32 unique 16K pages can be mapped
; into block 4000H.

SEED0	equ	0	; initial pattern seed

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

; BDOS functions
msgout	equ	9
vers	equ	12

mmu	equ	000h	; H8-512K Bank Switch Board base port
rd00K	equ	mmu+0
rd16K	equ	mmu+1
rd32K	equ	mmu+2
rd48K	equ	mmu+3
wr00K	equ	mmu+4
wr16K	equ	mmu+5
wr32K	equ	mmu+6
wr48K	equ	mmu+7

	org	100h

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

cont:	db	0	; continuous mode

seed:	db	0
pgnum:	db	0

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

; A=page num, HL=ref buf
minchk:
	ori	080h
	out	rd16K	; map into 16K
	out	wr16K	; (not used - yet)
	lxi	d,buf16K
	mvi	b,128
	call	compare
	ret

; IX=current bank results
; HL=ref buffer
; DE=test buffer
; B=count
compare:
	ldax	d
	cmp	m
	jrz	comp0
	inrx	+1
	ldx	a,+2
	inr	a
	jrnz	comp0
	stx	e,+2
comp0:
	inx	h
	inx	d
	djnz	compare
	ldx	a,+1
	ora	a
	ret

; A=seed (BCD)
setpat:
	lxi	h,buf16K
	mvi	b,128
setpat0:
	mov	m,a
	inx	h
	adi	1
	daa
	djnz	setpat0
	ret

; A=seed (BCD), IX=bank results
chkpat:
	lxi	h,buf16K
	mvi	b,128
chkpat0:
	cmp	m
	jrz	chkpat1
	inrx	+1
	ldx	e,+2
	inr	e
	jrnz	chkpat1
	stx	l,+2
chkpat1:
	inx	h
	adi	1
	daa
	djnz	chkpat0
	ldx	a,+1
	ora	a
	ret

start:
	lxi	sp,stack

	; setup results buffer
	lxi	h,banks
	mvi	m,0ffh	; pattern (none)
	inx	h
	mvi	m,0	; num errs
	inx	h
	mvi	m,0ffh	; 1st err
	inx	h
	mvi	m,0	; not used
	dcx	h
	dcx	h
	dcx	h
	lxi	d,banks+4
	lxi	b,lenbnks-4
	ldir

	call	mmu$init

	lxix	banks
	; First check if low 4 pages work (3, actually)
	lxi	h,0000h
	mvi	a,0	; page 0
	call	minchk
	lxi	d,4
	dadx	d
	lxi	h,4000h
	mvi	a,1	; page 1 - no-op
	call	minchk
	lxi	d,4
	dadx	d
	lxi	h,8000h
	mvi	a,2	; page 2
	call	minchk
	lxi	d,4
	dadx	d
	lxi	h,0c000h
	mvi	a,3	; page 3
	call	minchk
	lxi	d,4
	dadx	d
	; Now can do write tests...
	mvi	a,SEED0
	sta	seed
	mvi	a,4	; page number
	sta	pgnum
loop1:
	lda	seed
	stx	a,+0
	mov	c,a
	adi	1
	daa
	sta	seed
	lda	pgnum
	ori	080h
	out	rd16K	; map into 16K
	out	wr16K	; both RD and WR
	mov	a,c
	call	setpat
	lxi	d,4
	dadx	d
	lda	pgnum
	inr	a
	sta	pgnum
	cpi	32
	jc	loop1
	; Now can check write...
	lxix	banks+4*4
	mvi	a,SEED0
	sta	seed
	mvi	a,4	; page number
	sta	pgnum
loop2:
	lda	seed
	stx	a,+0
	mov	c,a
	adi	1
	daa
	sta	seed
	lda	pgnum
	ori	080h
	out	rd16K	; map into 16K
	out	wr16K	; both RD and WR
	mov	a,c
	call	chkpat
	lxi	d,4
	dadx	d
	lda	pgnum
	inr	a
	sta	pgnum
	cpi	32
	jc	loop2

	; done with MMU, report results...
	call	mmu$deinit

	lxix	banks
	xra	a
	sta	pgnum
	mvi	b,0
done0:
	ldx	a,+1	; num errs
	ora	a
	jz	done1
	inr	b
	lda	pgnum
	lxi	h,res0
	call	decout
	ldx	a,+0
	lxi	h,res1
	call	hexout
	ldx	a,+1
	lxi	h,res2
	call	decout
	ldx	a,+2
	lxi	h,res3
	call	hexout
	push	b
	pushix
	lxi	d,result
	mvi	c,msgout
	call	bdos
	popix
	pop	b
done1:	lxi	d,4
	dadx	d
	lda	pgnum
	inr	a
	sta	pgnum
	cpi	32
	jc	done0
	mov	a,b
	ora	a
	jnz	cpm	; already reported results
	lxi	d,noerr
	mvi	c,msgout
	call	bdos
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

result:	db	'Page'
res0:	db	'nnn patn '
res1:	db	'hh errs '
res2:	db	'nnn '
res3:	db	'hh',cr,lf,'$'

noerr:	db	'No errors found.',cr,lf,'$'

banks:
	ds	32*4	; pattern seed or 0FFH, num errs, 1st err, n/u
lenbnks	equ	$-banks

	ds	256
stack:	ds	0

	org	4000h
buf16K:	ds	0

	end
