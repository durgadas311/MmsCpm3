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
loader:
	mvi c,reset	;0200 0e 0d . .
	call bdos	;0202	cd fb 02 	. . . 
	mvi c,open	;0205 0e 0f . .
	lxi d,cpm3sys	;0207 11 8b 02 . . .
	call bdos	;020a	cd fb 02 	. . . 
	cpi 0ffh	;020d fe ff . .
	lxi d,fnfmsg	;020f 11 af 02 . . .
	jz die		;0212 ca 84 02 . . .
	lxi d,dmabuf	;0215 11 80 00 . . .
	call st$dma	;0218	cd 71 02 	. q . 
	call rd$file	; load header

	lxi h,dmabuf	;021e 21 80 00 ! . .
	lxi d,header	;0221 11 f5 02 . . .
	mvi c,6		;0224 0e 06 . .
memcpy:
	mov a,m		;0226 7e ~
	stax d		;0227 12 .
	inx d		;0228 13 .
	inx h		;0229 23 #
	dcr c		;022a 0d .
	jnz memcpy	;022b c2 26 02 . & .

	call rd$file	; load message (optional)
	mvi c,msgout	;0231 0e 09 . .
	lxi d,dmabuf	;0233 11 80 00 . . .
	call bdos	;0236	cd fb 02 	. . . 
	lda respgs	;0239 3a f6 02 : . .
	mov h,a		;023c 67 g
	lda restop	;023d 3a f5 02 : . .
	call loadit	;0240	cd 55 02 	. U . 
	lda bnkpgs	;0243 3a f8 02 : . .
	ora a		;0246 b7 .
	jz nobnk	;0247 ca 51 02 . Q .
	mov h,a		;024a 67 g
	lda bnktop	;024b 3a f7 02 : . .
	call loadit	;024e	cd 55 02 	. U . 
nobnk:
	lhld osntry	;0251 2a f9 02 * . .
	pchl 		;0254 e9 .

; H = num pages to load, A = starting (top) page.
; Loads records *backward* into memory.
loadit:
	ora a		;0255 b7 .
	mov d,a		;0256 57 W
	mvi e,0		;0257 1e 00 . .
	mov a,h		;0259 7c |
	ral		;025a 17 .
	mov h,a		;025b 67 g
nxtrec:
	xchg 		;025c eb .
	lxi b,-128	;025d 01 80 ff . . .
	dad b		;0260 09 .
	xchg 		;0261 eb .
	push d		;0262 d5 .
	push h		;0263 e5 .
	call st$dma	;0264	cd 71 02 	. q . 
	call rd$file	;0267	cd 77 02 	. w . 
	pop h		;026a e1 .
	pop d		;026b d1 .
	dcr h		;026c 25 %
	jnz nxtrec	;026d c2 5c 02 . \ .
	ret		;0270	c9 	. 

st$dma:
	mvi c,setdma	;0271 0e 1a . .
	call bdos	;0273	cd fb 02 	. . . 
	ret		;0276	c9 	. 

rd$file:
	mvi c,read	;0277 0e 14 . .
	lxi d,cpm3sys	;0279 11 8b 02 . . .
	call bdos	;027c	cd fb 02 	. . . 
	ora a		;027f b7 .
	lxi d,rdemsg	;0280 11 d3 02 . . .
	rz 		;0283 c8 .
	; fall-through to die()
die:
	mvi c,msgout	;0284 0e 09 . .
	call bdos	;0286	cd fb 02 	. . . 
	di		;0289	f3 	. 
	hlt		;028a 76 v

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

; load/run params
header:
restop:	db	0	; top page for RES	00
respgs:	db	0	; num pages		0f
bnktop:	db	0	; top page for BNK	e0
bnkpgs:	db	0	; num pages		4e
osntry:	dw	0	; entry point (cboot)	f700

	end
