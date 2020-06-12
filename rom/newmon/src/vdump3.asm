; Standalone utility to dump core for CP/M 3 (H8x512K) on VDIP1
; linked with vdip1.rel
	extrn	strcpy,strcmp
	extrn	vdcmd,vdend,vdrd,vdmsg,vdout,sync,runout
	public	vdbuf

CR	equ	13
LF	equ	10

	maclib	z180
	maclib	core
	aseg
	maclib	ram

; Z180 MMU constants - Z180 only
mmu$cbr	equ	38h
mmu$bbr	equ	39h
mmu$cbar equ	3ah

; H8x512K MMU constants - Z80 only
mmu	equ	0	; base port
rd	equ	0
wr	equ	4
pg0k	equ	0
pg16k	equ	1
pg32k	equ	2
pg48k	equ	3
ena	equ	80h
rd00k	equ	mmu+rd+pg0k
rd16k	equ	mmu+rd+pg16k
rd32k	equ	mmu+rd+pg32k
rd48k	equ	mmu+rd+pg48k
wr00k	equ	mmu+wr+pg0k
wr16k	equ	mmu+wr+pg16k
wr32k	equ	mmu+wr+pg32k
wr48k	equ	mmu+wr+pg48k

; e.g. org 3000h...
	cseg
begin:	di
	lhld	0ffeh	; product code...
	mov	a,l
	ani	1	; 0=FrontPanel
	sta	nofp
	call	set2ms
	call	runout
	call	sync
	jc	vderr
	call	cpu$type
	sta	z180
	ora	a
	mvi	a,13	; H8-512K needs 13 pages
	jrz	beg0
	mvi	a,15	; covers all of CP/M 3 on Z180
beg0:	sta	npages

	lxi	h,opw
	lxi	d,vdbuf
	call	strcpy
	; look for optional filename...
	lxi	h,2280h
	mov	b,m	; len
	inx	h
chkfil:	mov	a,m
	inx	h
	ora	a
	jrz	nofil
	cpi	' '
	jrz	gotfil	; already skipped blank...
	djnz	chkfil
nofil:	lxi	h,def
gotfil:
	call	strcpy	; does not incl CR
	mvi	a,CR
	stax	d
start:
	lxi	h,vdbuf	; opw
	call	vdcmd
	jc	nferr
	lxi	h,sek	; truncate, effectively
	call	vdcmd
	; ignore error?
	; setup/activate MMU
	call	mmu$init
	; from here on, must exit via exit

	; just map each page into pg48k and dump from there
	xra	a
	sta	pagex
loop0:
	call	map$page
	lxi	h,0c000h	; page 48K
loop1:
	xchg
	call	vdwr
	xchg
	jc	error
	mov	a,h
	ora	l
	jz	gotpg
	mov	a,h
	ani	0fh	; at 4K boundary?
	ora	l
	jnz	loop1
	push	h
	mvi	a,'.'
	call	chrout
	pop	h
	jmp	loop1
gotpg:
	mvi	a,'.'
	call	chrout
	lda	pagex
	inr	a
	sta	pagex
	lxi	h,npages
	cmp	m	; done after num pages
	jnc	done
	jmp	loop0	; A=pagex
done:
	lxi	h,fini
	call	msgout
	jr	exit	; now safe to return directly

chrout:
	lhld	conout
	pchl

; Create "unity" page mapping, enable MMU
mmu$init:
	di
	lda	z180
	ora	a
	jrz	min0
	; TODO: Z180 MMU init
	mvi	a,1100$1100b	; com1 at C000 (bnk disabled)
	out0	a,mmu$cbar
	ei
	ret
min0:	mvi	a,0	; page 0
	out	rd00k
	out	wr00k
	inr	a
	out	rd16k
	out	wr16k
	inr	a
	out	rd32k
	out	wr32k
	inr	a
	ori	ena
	out	rd48k
	out	wr48k
	ei
	ret

error:
	lxi	h,fail
	call	msgout
exit:	lxi	h,clf
	call	vdcmd
	call	res2ms
mmu$deinit:	; never returns...
	di
	lda	z180
	ora	a
	jrz	mdi0
	; TODO: Z180 de-init
	xra	a
	out0	a,mmu$cbar
	jr	fin
mdi0:	mvi	a,0
	out	rd00k	; disables MMU, forces 64K
fin:
	lhld	retmon
	pchl

nferr:	lxi	h,operr
errout:	call	msgout
	lda	sav$F0
	sta	ctl$F0
	out	0f0h
	jmp	0
vderr:	lxi	d,nterr
	jr	errout

map$page:
	lda	z180
	ora	a
	lda	pagex	; 16K page we're on
	jrz	mp0
	; convert to 4K page adr
	; offset by C000...
	add	a
	add	a
	sui	0ch	; might be negative
	out0	a,mmu$cbr
	ret
mp0:	ori	ena
	out	rd48k
	ret

; DE=data buffer (dma adr)
; Returns DE=next
vdwr:	lxi	h,wrf
	call	vdmsg
	lxi	b,512
vdwr0:	ldax	d
	call	vdout
	inx	d
	dcx	b
	mov	a,b
	ora	c
	jrnz	vdwr0
	push	d
	call	vdend
	pop	d
	ret	; CY=error

; returns FF if running on Z180, 00 if Z80
cpu$type:
	mvi	a,1
	mlt	b	; a.k.a. alt NEG on Z80
	sui	0ffh	; Z180: CY(02), Z80: NC(00)
	sbb	a	; Z180: FF, Z80: 00
	ret

; Turn on 2mS clock.
; This assumes the "no FP" monitor never turns on 2mS clock,
; or at least that F2 and F3 bits match.
set2ms:	di
	lda	nofp
	ora	a
	jrnz	nofp1
	lxi	h,ctl$F0
	mov	a,m
	sta	sav$F0
	ori	01000000b	; 2mS back on
	mov	m,a
	out	0f0h
	jr	set2ms1
nofp1:	lxi	h,ctl$F2
	mov	a,m
	sta	sav$F2
	ori	00000010b	; 2mS CLK
	mov	m,a
	out	0f2h
	ani	00000010b	; double-enable
	out	0f3h
set2ms1:
	ei	; TODO: will ROM leave MMU alone?
	ret

; restore previous 2mS clock state
res2ms:
	lda	nofp
	ora	a
	jrnz	nofp2
	lda	sav$F0
	sta	ctl$F0
	out	0f0h
	ret
nofp2:	lda	sav$F2
	sta	ctl$F2
	out	0f2h
	ani	00000010b	; double-enable
	out	0f3h
	ret

pagex:	db	0
sav$F0:	db	0
sav$F2:	db	0
z180:	db	0
nofp:	db	0
npages:	db	0

clf:	db	'clf',CR,0
wrf:	db	'wrf ',0,0,2,0,CR,0	; 512 byte writes
sek:	db	'sek ',0,0,0,0,CR,0	; do not append
opw:	db	'opw ',0
def:	db	'coredump.out',0

fini:	db	CR,LF,'vdump3 finished.',CR,LF,0
fail:	db	'!',CR,LF,'* dump failed *',CR,LF,0
operr:	db	'* file open failed *',CR,LF,0
nterr:	db	'* VDIP1 init failed *',CR,LF,0

vdbuf:	ds	128

	end
