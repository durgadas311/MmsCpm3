;****************************************************************
; H8-512K Banked Memory Test Program		 		*
; stand-alone version                		 		*
;****************************************************************
	$*MACRO
rev	equ	'3'

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

mmu	equ	000h	; H8-512K Bank Switch Board base port
rd00K	equ	mmu+0
rd16K	equ	mmu+1
rd32K	equ	mmu+2
rd48K	equ	mmu+3
wr00K	equ	mmu+4
wr16K	equ	mmu+5
wr32K	equ	mmu+6
wr48K	equ	mmu+7
rd00KH	equ	mmu+8
rd16KH	equ	mmu+9
rd32KH	equ	mmu+10
rd48KH	equ	mmu+11
wr00KH	equ	mmu+12
wr16KH	equ	mmu+13
wr32KH	equ	mmu+14
wr48KH	equ	mmu+15


buf16K	equ	4000h

	cseg
begin:
	lxi	sp,stack
	mvi	a,mmu
	lxi	h,port
	call	hexout
	lxi	d,signon
	call	msgout
; TODO: scan for 'C'?
 if 1
	lxi	h,2280h
	mov	b,m	; len
	inx	h
skipb:	mov	a,m
	inx	h
	ora	a
	jrz	skp1
	cpi	' '
	jrz	skp0
	djnz	skipb
	jr	skp1
skp0:	mov	a,m
	ani	01011111b
	cpi	'C'
	jrnz	skp1
	sta	cont
skp1:
 endif
	jmp	start

cont:	db	0	; continuous mode

seed:	db	0
pgnum:	db	0
err0:	db	0
count:	dw	0
errflg:	db	0
chip:   db  0

; If current mapping is not the default/disabled,
; things will likely crash here.
mmu$init:
	di
	mvi	a,0	; page 0
	out	rd00KH
	out	wr00KH
	out	rd16KH
	out	wr16KH
	out	rd32KH
	out	wr32KH
	out	rd48KH
	out	wr48KH
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
	out	rd00KH
	out	wr00KH
	out	rd16KH
	out	wr16KH
	out	rd32KH
	out	wr32KH
	out	rd48KH
	out	wr48KH
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

	call	mmu$init

loop0:
	lxix	banks
	; First check if low 4 pages work (3, actually)
	lxi	h,0000h
	mvi	a,0	; page 0
	call	minchk
	sta	err0
	lxi	d,4
	dadx	d
	lxi	h,4000h
	mvi	a,1	; page 1 - no-op
	call	minchk
	mov	c,a
	lda	err0
	ora	c
	sta	err0
	lxi	d,4
	dadx	d
	lxi	h,8000h
	mvi	a,2	; page 2
	call	minchk
	mov	c,a
	lda	err0
	ora	c
	sta	err0
	lxi	d,4
	dadx	d
	lxi	h,0c000h
	mvi	a,3	; page 3
	call	minchk
	mov	c,a
	lda	err0
	ora	c
	sta	err0
	jnz	nommu
	lxi	d,4
	dadx	d
	; Now can do write tests...
	mvi	a,SEED0
	sta	seed

	; prepare to write all pages in all chips

	mvi a, 0 ; chip number
	sta chip
	mvi a,4 ; page number -- first chip is special
	jp  loop1d
loop1c:
	mvi	a,0	; page number -- subsequent chip pages start at page0
loop1d:
	sta	pgnum
loop1:
	lda	seed
	stx	a,+0
	mov	c,a
	adi	1
	daa
	sta	seed

    ; set the high register
	lda chip
	rrc
	rrc
	ani 03h
	ori 080h
	out	rd16KH
	out	wr16KH

    lda pgnum
	mov b, a
    lda chip
	ani 03h
    rlc
	rlc
	rlc
	rlc
	rlc
	ora b

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

	lda chip
	inr a
	sta chip
	cpi 16
	jc  loop1c

	; prepare to read all pages in all chips
	; Now can check write...
	lxix	banks+4*4
	mvi	a,SEED0
	sta	seed
	mvi a, 0 ; chip number
	sta chip
	mvi a,4 ; page number - first chip is special
	jp loop2d
loop2c:
	mvi	a,0	; page number - subsequent chip pages start at page0
loop2d:
	sta	pgnum
loop2:
	lda	seed
	stx	a,+0
	mov	c,a
	adi	1
	daa
	sta	seed

    ; set the high register
	lda chip
	rrc
	rrc
	ani 03h
	ori 080h
	out	rd16KH
	out	wr16KH

    lda pgnum
	mov b, a
    lda chip
	ani 03h 
    rlc
	rlc
	rlc
	rlc
	rlc
	ora b

	ori	080h
	out	rd16K	; map into 16K
	out	wr16K	; both RD and WR
	mov	a,c
	call	chkpat
	lda	errflg
	orx	+1
	sta	errflg
	lxi	d,4
	dadx	d
	lda	pgnum
	inr	a
	sta	pgnum
	cpi	32
	jc	loop2

	lda chip
	inr a
	sta chip
	cpi 16
	jc  loop2c

	lda	cont
	ora	a
	jrz	done
	call	conchk
	jrc	done
	lhld	count
	inx	h
	shld	count
	call	wrdout
	jmp	loop0
done:
nommu:
	; done with MMU, report results...
	call	mmu$deinit

	lxix	banks
   
    mvi a, 0
	sta chip
done0c:
	xra	a
	sta	pgnum
	mvi	b,0
done0:
	ldx	a,+1	; num errs
	ora	a
	jz	done1
	inr	b
	lda chip
	lxi h, resz
	call	decout
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
	call	msgout
	popix
	pop	b
done1:	lxi	d,4
	dadx	d
	lda	pgnum
	inr	a
	sta	pgnum
	cpi	4
	jnz	done2
	lda	err0
	ora	a
	jnz	nommu0
	lda	pgnum
done2:
	cpi 32
	jc	done0

	lda chip
	inr a
	sta chip
	cpi 16
	jc  done0c

	mov	a,b
	ora	a
	jrnz	cpm	; already reported results
	lxi	d,noerr
	call	msgout
	; TODO: restore and return to monitor
	jr	cpm

nommu0:	lxi	d,mmuerr
	call	msgout
	; TODO: restore and return to monitor
	;jr	cpm

; restore and return to monitor...
cpm:	di
	xra	a
	out	0f2h
	mvi	a,0dfh
	out	0f0h
	jmp	0

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

; print XXXX[*]<CR>
wrdout:	mov	a,h
	call	bytout
	mov	a,l
	call	bytout
	lda	errflg
	ora	a
	jrz	wrdout0
	mvi	a,'*'
	call	conout
wrdout0:
	mvi	a,CR
	jr	conout

bytout:	push	psw
	rlc
	rlc
	rlc
	rlc
	call	byt0
	pop	psw
byt0:	ani	0fh
	adi	90h
	daa
	aci	40h
	daa
	jr	conout

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

conchk:	in	0edh
	ani	00000001b
	rz
	in	0e8h
	mvi	a,CR
	call	conout
	mvi	a,LF
	call	conout
	stc
	ret

result:   db  'Chip'
resz:	db	'nnn Page '
res0:	db	'nnn patn '
res1:	db	'hh errs '
res2:	db	'nnn '
res3:	db	'hh',cr,lf,0

noerr:	db	'No errors found.',cr,lf,0
mmuerr:	db	'Aborting test: No MMU?',cr,lf,0
signon:	db	'Test H8-8MEG rev ',rev,' port '
port:	db	'hh',cr,lf,0

banks:
	ds	32*4*16	; pattern seed or 0FFH, num errs, 1st err, n/u
lenbnks	equ	$-banks

	ds	256
stack:	ds	0

	end	begin
