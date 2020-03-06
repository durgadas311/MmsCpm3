; Standalone utility to dump core for CP/M 3 (H8x512K) on VDIP1
; linked with vdip1.rel
	extrn	strcpy,strcmp
	extrn	vdcmd,vdend,vdrd,vdmsg,vdout,sync,runout
	public	vdbuf

CR	equ	13
LF	equ	10

	maclib	z80
	aseg

; H8x512K MMU constants
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

; ROM hooks...
conop	equ	0026h	; pointer, not vector
ctl$F0	equ	2009h
ctl$F2	equ	2036h

; e.g. org 3000h...
	cseg
begin:	di
	; TODO: init VDIP1...
	lxi	h,ctl$F0
	mov	a,m
	sta	sav$F0
	ori	01000000b	; 2mS back on
	mov	m,a
	out	0f0h
	ei	; TODO: will ROM leave MMU alone?
	call	runout
	call	sync
	jc	vderr

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
	lxi	h,vdbuf
	call	vdcmd
	jc	nferr
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
	call	conout
	pop	h
	jmp	loop1
gotpg:
	lda	pagex
	inr	a
	sta	pagex
	cpi	13	; done after pages 0-12
	jnc	done
	jmp	loop0
done:
	jr	exit	; now safe to return directly

conout:
	lhld	conop
	pchl

; Create "unity" page mapping, enable MMU
mmu$init:
	di
	mvi	a,0	; page 0
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
	lxi	d,fail
	call	msgout
exit:	lxi	h,clf
	call	vdcmd
	lda	sav$F0
	sta	ctl$F0
	out	0f0h
mmu$deinit:
	di
	mvi	a,0
	out	rd00k	; disables MMU, forces 64K
	ei
	jmp	0

nferr:	lxi	d,operr
errout:	call	msgout
	lda	sav$F0
	sta	ctl$F0
	out	0f0h
	jmp	0
vderr:	lxi	d,nterr
	jr	errout

map$page:
	lda	pagex	; page we're on
	ori	ena
	out	rd48k
	ret

; DE=string, NUL term
msgout:	ldax	d
	ora	a
	rz
	call	conout
	inx	d
	jr	msgout

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

pagex:	db	0
sav$F0:	db	0

clf:	db	'clf',CR,0
wrf:	db	'wrf ',0,0,2,0,CR,0	; 512 byte writes
opw:	db	'opw ',0
def:	db	'coredump.out',0

fail:	db	'!',CR,LF,'* dump failed *',CR,LF,0
operr:	db	'* file open failed *',CR,LF,0
nterr:	db	'* VDIP1 init failed *',CR,LF,0

vdbuf:	ds	128

	end
