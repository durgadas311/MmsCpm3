;****************************************************************
; Z180-MMU Memory Test Program			 		*
; stand-alone version                		 		*
; Continuous, exhaustive.					*
;****************************************************************
; Assume the low 16K has already been tested - we run there.
	$*MACRO
rev	equ	'2'

	maclib	z180
;	maclib	ram	; doesn't work with REL files...
ctl$F2	equ	2036h

true	equ -1
false	equ not true

cr	equ	13
lf	equ	10
bs	equ	8
bell	equ	7

buf16K	equ	4000h	; assumes normal ROM CBAR

; Z180 MMU registers
mmu$cbr	equ	38h
mmu$bbr	equ	39h
mmu$cbar equ	3ah

	cseg
begin:
	lxi	sp,stack
	lxi	d,signon
	call	msgout
	jmp	start

cont:	db	0	; continuous mode

seed0:	db	0
seed:	db	0
maxpg:	db	0
pgnum:	db	0
bbr:	db	0

; We are running at 3000h which should be 03000h physical RAM.
; Assuming that CBAR is set for C000/4000.
mmu$init:
	di
	in0	a,mmu$bbr	; the only register we change...
	sta	bbr
	ei
	ret

mmu$deinit:
	di
	lda	bbr
	out0	a,mmu$bbr
	ei
	ret

selpg:	add	a
	add	a	; convert to 4K page number
	sui	4	; offset for location 4000h
	out0	a,mmu$bbr
	ret

; IX=current bank results
; HL=ref buffer
; DE=test buffer
; BC=count
compare:
	ldax	d
	cmp	m
	jrz	comp0
	inrx	+1
	jrnz	comp1
	dcrx	+1	; hold at 255
comp1:
	ldx	a,+2
	inr	a
	jrnz	comp0
	stx	e,+2
comp0:
	inx	h
	inx	d
	dcx	b
	mov	a,b
	ora	c
	jrnz	compare
	ldx	a,+1
	ora	a
	ret

; A=seed (BCD)
setpat:
	lxi	h,buf16K
	lxi	b,16*1024
setpat0:
	mov	m,a
	inx	h
	adi	1
	daa
	mov	e,a
	dcx	b
	mov	a,b
	ora	c
	mov	a,e
	jrnz	setpat0
	ret

; A=seed (BCD), IX=bank results
chkpat:
	lxi	h,buf16K
	lxi	b,16*1024
chkpat0:
	cmp	m
	jrz	chkpat1
	inrx	+1
	jrnz	chkpat2
	dcrx	+1	; hold at 255
chkpat2:
	ldx	e,+2
	inr	e
	jrnz	chkpat1
	stx	l,+2
chkpat1:
	inx	h
	adi	1
	daa
	mov	e,a
	dcx	b
	mov	a,b
	ora	c
	mov	a,e
	jrnz	chkpat0
	ldx	a,+1
	ora	a
	ret

start:
	di	; completely isolate ourself...
	lda	ctl$F2
	ani	00010100b
	ori	00100000b
	out	0f2h	; ORG0 on (ROM off), everything else as in RESET
	call	mmu$init

	; probe memory size - assume 512K if 1M not present.
	; We can't access top 32K of RAM (used by EEPROM).
	mvi	a,3dh	; last possible page (1M - 32K)
	sta	maxpg
	call	selpg
	lxi	h,buf16k
	mov	a,m
	inr	m
	cmp	m
	jrnz	ok
	mvi	a,1fh	; last page of 512K
	sta	maxpg
ok:	lxi	d,note
	call	msgout
	lda	maxpg
	cpi	20h
	lxi	d,t512k
	jrc	sm
	lxi	d,t1m
sm:	call	msgout
over:
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
	; initialize buffer to detect errors
	mvi	a,099h
	call	setpat

	; start testing at page 1 (0 contains this program)
	lxix	banks
	lda	seed0
	sta	seed
	mvi	a,1	; page number
	sta	pgnum
loop1:
	lda	seed
	stx	a,+0
	mov	c,a
	adi	1
	daa
	sta	seed
	lda	pgnum
	call	selpg
	mov	a,c
	call	setpat
	lxi	d,4
	dadx	d
	call	progress
	lda	maxpg
	mov	c,a
	lda	pgnum
	inr	a
	sta	pgnum
	inr	c
	cmp	c
	jc	loop1
	; Now can check write...
	lxix	banks
	lda	seed0
	sta	seed
	mvi	a,1	; page number
	sta	pgnum
loop2:
	lda	seed
	stx	a,+0
	mov	c,a
	adi	1
	daa
	sta	seed
	lda	pgnum
	call	selpg
	mov	a,c
	call	chkpat
	lxi	d,4
	dadx	d
	call	progress
	lda	maxpg
	mov	c,a
	lda	pgnum
	inr	a
	sta	pgnum
	inr	c
	cmp	c
	jc	loop2

	; done with one pass, report results...
	lxix	banks
	mvi	a,1
	sta	pgnum
	mvi	b,0
done0:
	ldx	a,+1	; num errs
	ora	a
	jz	done1
	inr	b
	lda	pgnum
	lxi	h,res0
	call	decout	; destroys C, DE
	ldx	a,+0
	lxi	h,res1
	call	hexout
	ldx	a,+1
	lxi	h,res2
	call	decout	; destroys C, DE
	ldx	a,+2
	lxi	h,res3
	call	hexout
	push	b
	pushix
	lxi	d,result
	call	msgout
	popix
	pop	b
done1:	lxi	d,4
	dadx	d
	lda	maxpg
	mov	c,a
	inr	c
	lda	pgnum
	inr	a
	sta	pgnum
	cmp	c
	jc	done0
	mov	a,b
	ora	a
	jrnz	dover	; already reported results
	lxi	h,noerr
	lda	seed0
	call	hexout
	lxi	d,noerr
	call	msgout
	; TODO: restore and return to monitor
dover:	; do test again...
	lda	seed0
	adi	1
	daa
	sta	seed0
	jmp	over

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

msgout:	ldax	d
	ora	a
	rz
	inx	d
	call	conout
	jr	msgout

conout:	push	psw
cono0:	in	0edh
	ani	00100000b
	jrz	cono0
	pop	psw
	out	0e8h
	ret

progress:
	lxi	h,spinx
	inr	m
	mov	a,m
	ani	00000011b
	mov	c,a
	mvi	b,0
	lxi	h,spin
	dad	b
	mov	a,m
	call	conout
	mvi	a,bs
	call	conout
	ret

spinx:	db	0
spin:	db	'-','\','|','/'

result:	db	'Page'
res0:	db	'nnn patn '
res1:	db	'hh errs '
res2:	db	'nnn '
res3:	db	'hh',cr,lf,0

noerr:	db	'hh: No errors found.',cr,lf,0
signon:	db	'RAM Test Z180 rev ',rev,cr,lf,0
note:	db	'Memory size ',0
t512k:	db	'512K',cr,lf,0
t1m:	db	'1M',cr,lf,0

banks:
	ds	64*4	; pattern seed or 0FFH, num errs, 1st err, n/u
lenbnks	equ	$-banks

	ds	256
stack:	ds	0

	end	begin
