; CPM3LDR program code

	maclib	z80

	public	loader
	extrn	bdos

CR	equ	13
LF	equ	10
TAB	equ	9
BS	equ	8
BEL	equ	7
DEL	equ	127

; locations in page-0
rst1	equ	0008h
ticker	equ	000bh
gpbyte	equ	000dh
l000eh	equ	000eh
dmabuf	equ	0080h

msgout	equ	9
reset	equ	13
open	equ	15
read	equ	20
setdma	equ	26

	cseg
	org	0100h
loader:
	mvi c,reset
	call bdos
	mvi c,open
	lxi d,cpm3sys
	call bdos
	cpi 0ffh
	lxi d,fnfmsg
	jz die
	lxi d,dmabuf
	call st$dma
	call rd$file	; load header

	lxi h,dmabuf
	lxi d,header
	mvi c,6
memcpy:
	mov a,m
	stax d
	inx d
	inx h
	dcr c
	jnz memcpy

	call rd$file	; load message (optional)
	mvi c,msgout
	lxi d,dmabuf
	call bdos
	lda respgs
	mov h,a
	lda restop
	call loadit
	lda bnkpgs
	ora a
	jz nobnk
	mov h,a
	lda bnktop
	call loadit
nobnk:
	lhld osntry
	pchl 

; H = num pages to load, A = starting (top) page.
; Loads records *backward* into memory.
loadit:
	ora a
	mov d,a
	mvi e,0
	mov a,h
	ral
	mov h,a
nxtrec:
	xchg 
	lxi b,-128
	dad b
	xchg 
	push d
	push h
	call st$dma
	call rd$file
	pop h
	pop d
	dcr h
	jnz nxtrec
	ret

st$dma:
	mvi c,setdma
	call bdos
	ret

rd$file:
	mvi c,read
	lxi d,cpm3sys
	call bdos
	ora a
	lxi d,rdemsg
	rz 
	; fall-through to die()
die:
	mvi c,msgout
	call bdos
	di
	hlt

cpm3sys:
	db	0,'CPM3    SYS',0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0

fnfmsg:
	db	CR,LF,'error: File not found: CPM3.SYS'
	db	CR,LF,'$'

rdemsg:
	db	CR,LF,'error: Read failure: CPM3.SYS'
	db	CR,LF,'$'

; load/run params from file header
header:	;		element use		e.g.
restop:	db	0	; top page for RES	00
respgs:	db	0	; num pages		0f
bnktop:	db	0	; top page for BNK	e0
bnkpgs:	db	0	; num pages		4e
osntry:	dw	0	; entry point (cboot)	f700

	end
