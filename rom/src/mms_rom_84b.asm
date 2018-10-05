; Z89/Z90 Monitor EPROM 444-84B, by Magnolia Microsystems

	maclib	z80

CR	equ	13
LF	equ	10
BEL	equ	7
ESC	equ	27
TRM	equ	0
DEL	equ	127

	org	01800h	; H17 Floppy ROM routines
	ds	1014
R$ABORT: ds	35	;00011011.11110110	033.366	R.ABORT
CLOCK:	ds	38	;00011100.00011001	034.031 CLOCK
R$READ:	ds	499	;00011100.00111111	034.077	R.READ
R$SDP:	ds	107	;			034.062 R.SDP
R$WHD:	ds	28	;00011110.10011101	036.235	R.WHD
R$WNH:	ds	161	;00011110.10111001	036.271	R.WNH
R$CONST: ds	88	;00011111.01011010	037.132	R.CONST
	ds	78

; RAM variables, some defined by H17 Floppy ROM
	org	02000h
ramstart:
	ds	3
l2003h:	ds	1	; - 02003h
l2004h:	ds	1	; - 02004h
	ds	3
l2008h:	ds	1	; - 02008h
l2009h:	ds	1	; - 02009h
	ds	17
ticcnt:	ds	2	; - 0201bh
l201dh:	ds	2	; - 0201dh
intvec:
vrst1:	ds	3	; rst1 jmp vector - 0201fh
vrst2:	ds	3	; rst2 jmp vector - 02022h
vrst3:	ds	3	; rst3 jmp vector - 02025h
vrst4:	ds	3	; rst4 jmp vector - 02028h
vrst5:	ds	3	; rst5 jmp vector - 0202bh
vrst6:	ds	3	; rst6 jmp vector - 0202eh
vrst7:	ds	3	; rst7 jmp vector - 02031h
l2034h:	ds	2	; - 02034h
l2036h:	ds	1	; - 02036h GPP template/image
l2037h:	ds	2	; - 02037h
	ds	7
l2040h:	ds	8
l2048h:	ds	62	; - 02048h	disk constants
l2086h:	ds	2	; - 02086h
	ds	44
DECNT:	ds	1	; - 020b4h
	ds	124
AIO$UNI: ds	1	; - 02131h
l2132h:	ds	2
l2134h:	ds	2
l2136h:	ds	2
l2138h:	ds	2
	ds	22
cport:	ds	1	; - 02150h
	ds	1
SEC$CNT:	ds	1	; - 02152h
l2153h:	ds	1
	ds	2
l2156h:	ds	2
l2158h:	ds	2
l215ah:	ds	2
	ds	292
bootbf:	ds	0	; - 02280h

ramboot	equ	0c000h

; Start of ROM code
	org	00000h

rombeg:
rst0:	jmp	init

bootms:	db	'oot ',TRM

rst1:	call	intsetup
	lhld	ticcnt
	jmp	l00b9h

rst2	equ	$-1	; must be a nop...
	call	intsetup
	ldax	d
	jmp	l0180h

rst3:	jmp	vrst3

goms:	db	'o ',TRM
	db	0,0

rst4:	jmp	vrst4

	db	0,0,0,0,0

rst5:	jmp	vrst5
s002bh:
	jmp	l0260h

qmsg:	db	'?',TRM

rst6:	jmp	vrst6

	db	0,0,0,0,0

rst7:	jmp	vrst7

subms:	db	'ubstitute ',TRM
pcms:	db	'rogram Counter ',TRM
mtms:	db	'emory test',TRM

	rept	0066h-$
	db	0
	endm
if	($ != 0066h)
	.error	"NMI location missed"
endif

nmi:
	xthl	; save HL and pop RETADR
	push	h	; put RETADR in new position
	push	psw
	dcx	h
	mov	a,m		; check cause of NMI
	cpi	0f0h	; H8 front-panel port
	jrz	port$f0
	cpi	0f1h	; H8 port
	jrz	port$ign
	cpi	0fah	; H8...
	jrz	port$ign
	cpi	0fbh	; H8...
	jrnz	nmi$xit2
port$ign:	; ports 0F1H, 0FAH, 0FBH.
	dcx	h
	mov	a,m
	cpi	0d3h	; OUT
	jrz	nmi$xit2
	cpi	0dbh	; IN
	jrnz	nmi$xit2
	; IN 0F1H, 0FAH or 0FBH...
	pop	psw
	mvi	a,000h	; these ports "return" 000h
	jr	nmi$xit	; exit NMI

port$f0:	; H8 front panel port...
	dcx	h
	mov	a,m
	cpi	0dbh	; IN
	jrnz	not$in
	pop	psw
	mvi	a,0ffh	; simulate input of 0ffh
	jr	nmi$xit
not$in:
	cpi	0d3h	; OUT
	jrnz	nmi$xit2
	pop	psw	; byte to output to 0F0H...
	push	psw	; _  7 6 5 4 3 2 1 0
	ral		; 7  6 5 4 3 2 1 0 _
	ral		; 6  5 4 3 2 1 0 _ 7
	cma		; 6  5'4'3'2'1'0'_ 7'
	ral		; 5' 4'3'2'1'0'_ 7'6
	rlc		; 4' 3'2'1'0'_ 7'6 5'
	ani	003h	; _  _ _ _ _ _ _ 6 5'
	lxi	h,l2036h
	ora	m
	out	0f2h ; simulate some H8 features
nmi$xit2:
	pop	psw
nmi$xit:
	pop	h
	xthl
	retn

l00adh:
	ldax	b
	rrc
	cc	vrst1
l00b2h:
	pop	psw
	pop	psw
	pop	b
	pop	d
	pop	h
nulint:
	ei
	ret

l00b9h:
	inx	h
	shld	ticcnt
	lxi	b,l2008h+1
	ldax	b
	out	0f0h
	ani	020h
	jrnz	l00b2h
	dcx	b
l00c8h:
	ldax	b
	ral
	jrc	l00adh
	lxi	h,10
	dad	sp
	mov	e,m
	inx	h
	mov	d,m
	dcx	d
	ldax	d
	cpi	076h	; HLT
	jrnz	l00adh
	call	belout
	mvi	a,'H'
	call	conout
re$entry:		; re-entry point for errors, etc.
	lxi	h,l2008h+1
	mvi	m,0f0h
	lhld	l201dh
	sphl
	call	belout
	;jmp	start

start:
	ei
	lxi	h,start
	push	h
	lxi	h,prompt
	call	msgout
prloop:
	call	coninx
l00fbh:
	ani	05fh ; toupper
	lxi	h,cmdtab
	mvi	b,005h
cmloop:
	cmp	m
	inx	h
	jrz	docmd
	inx	h
	inx	h
	djnz	cmloop
	mov	c,a
	call	xcmds
	call	belout
	jr	prloop
docmd:
	call	conout
	mov	a,m
	inx	h
	mov	h,m
	mov	l,a
	pchl

cmdtab:
	db	'G'
	dw	cmdgo
	db	'S'
	dw	cmdsub
	db	'P'
	dw	cmdpc
	db	'B'
	dw	cmdboot
	db	'M'
	dw	cmdmt

	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	jmp	l0419h

cmdpc:
	lxi	h,pcms
	call	msgout
	lxi	h,12
	dad	sp
	mov	e,m
	inx	h
	mov	d,m
	xchg
	call	s056dh
	jrc	l0154h
	call	adrnl
	call	s056dh
	rnc
l0154h:
	xchg
s0155h:
	mvi	d,00dh
	jmp	adrin
cmdgo:
	lxi	h,goms
	call	msgout
	lxi	h,13
	dad	sp
	call	s056dh
	cc	s0155h
	call	crlf
	mvi	a,0d0h
	jr	l0179h
	di
	lda	l2009h
	xri	010h
	out	0f0h
l0179h:
	sta	l2009h
	pop	h
	jmp	l00b2h

l0180h:
	ori	010h
	out	0f0h
	stax	d
	ani	020h
	jnz	start
	jmp	vrst2

take$5:
	mvi	a,5	; 5 seconds
take$A:
	lxi	h,timeout
	shld	vrst1+1
	sta	SEC$CNT
	mvi	a,001h
	sta	l2008h
	ei
	ret

timeout:
	lxi	h,ticcnt
	xra	a
	ora	m
	rnz
	inx	h
	mov	a,m
	rrc
	rc
	; every 512 ticks... 1024mS
	lxi	h,SEC$CNT
	dcr	m
	rnz
l01aeh:
	lhld	l201dh
	sphl
	lxi	h,qmsg
	call	msgout
	lxi	h,nulint
	shld	vrst1+1
	sta	l2008h
	in	0f2h
	ani	003h
	jrnz	l01c9h
	out	07fh
l01c9h:
	jmp	re$entry

s01cch:
	lxi	h,l2153h	; auto-boot disable?
	in	0f2h
	mov	d,a
	xri	080h
	ora	m
	rm
	mov	m,d	; ensure we only fail once... and only on power-up?
	call	gtdfbt
	lxi	h,autbms
	call	msgout
	lxi	sp,bootbf
	jmp	l034dh

autbms:	db	'Auto Boot',TRM

gtdev1:
	mvi	d,0
	in	0f2h
l01f4h:
	ani	003h
	rz		; Z17 (or Z37)
	cpi	001h
	mvi	d,5
	rz		; Z47
	cpi	002h
	mvi	d,3
	rz		; Z67/MMS77320
	mvi	d,60
	ret		; MMS77422 Network

gtdev2:
	mvi	d,46	; Z37
	in	0f2h
	rrc
	rrc
	jr	l01f4h

gtdfbt:
	lxi	d,0
	in	0f2h
	ani	070h
	cpi	020h
	jrz	gtdev1
	cpi	030h
	jrz	gtdev2
	jmp	gtdvtb

getport:
	mvi	b,07ch
	in	0f2h
	ani	003h
	cmp	c
	rz
	mvi	b,078h
	in	0f2h
	rrc
	rrc
	ani	003h
	cmp	c
	rz
	pop	h	; discard return address
s501er:
	lxi	h,s501ms
	jmp	msgout

s501ms:	db	'SW501 wrong ',TRM

m$sdp:
	mvi	a,10
	sta	DECNT
	lda	AIO$UNI
	push	psw
	adi	-2
	aci	3
	jmp	R$SDP+10	; hacked R.SDP for 3-drives
s0254h:
	ora	a
l0255h:
	push	b
	lda	cport
	aci	000h
	mov	c,a
	inp	a
	pop	b
	ret
l0260h:
	push	h
	lxi	h,ticcnt
	add	m
l0265h:
	cmp	m
	jrnz	l0265h
	pop	h
	ret
l026ah:
	call	belout
l026dh:
	jr	l0275h
l026fh:
	call	conout
	ani	00fh
	mov	d,a
l0275h:
	call	conin
	cmp	c
	jrz	l0298h
	cpi	'0'
	jrc	l026ah
	cpi	'9'+1
	jrnc	l026ah
	call	conout
	ani	00fh
	mvi	b,10
l028ah:
	add	d
	jc	l01aeh
	djnz	l028ah
	mov	d,a
	cpi	200
	jnc	l01aeh
	jr	l0275h
l0298h:
	mov	a,d
	cpi	5
	jc	goboot
	cpi	9
	jnc	goboot
	adi	200
	mov	d,a
	jmp	goboot

cmdboot:
	lxi	h,bootms
	call	msgout
	lxi	sp,bootbf
	call	gtdfbt
l02b5h:
	mvi	c,CR
	jr	l02bch
bterr:
	call	belout
l02bch:
	call	conin
	cmp	c
	jz	goboot
	mvi	e,0
	cpi	'0'
	jrc	nodig
	cpi	'9'+1
	jrc	l026fh
nodig:
	ani	05fh ; toupper
	cpi	'Z'+1
	jrnc	bterr
	cpi	'A'
	jrc	bterr
	call	conout
	call	conout
	cpi	'B'
	jrc	gotit
	lxi	h,bootb1
	mov	b,a
luboot:
	mov	a,m
	inx	h
	mov	d,m
	inx	h
	cmp	b
	jrz	gotit
	ora	a
	jrnz	luboot
	mvi	d,0
	call	s0854h
	jc	l01aeh
gotit:
	mvi	a,'-'
	call	conout
	jr	l0301h

l02feh:
	call	belout
l0301h:
	call	conin
	cmp	c
	jrz	goboot
	cpi	'9'+1
	jrz	l0332h
	cpi	' '
	jrz	l032dh
	cpi	'0'
	jrc	l02feh
	cpi	'9'+1
	jrnc	l02feh
	call	conout
	sui	'0'
	mov	e,a
l031dh:
	call	conin
	cmp	c
	jrz	goboot
	cpi	'9'+1
	jrz	l0332h
	cpi	' '
	jrz	l032dh
	mvi	a,7
l032dh:
	call	conout
	jr	l031dh
l0332h:	; get arbitrary string as last boot param
	mvi	b,0
	lxi	h,bootbf
l0337h:
	call	conout
	call	conin
	inr	b
	inx	h
	mov	m,a
	cmp	c
	jrnz	l0337h
	xra	a	; TRM - string terminator
l0344h:	; use stack as char array...
	push	psw
	inx	sp	; undo half of push
	dcx	h
	mov	a,m
	djnz	l0344h
goboot:
	call	crlf
l034dh:
	lxi	h,l01aeh
	push	h
	call	s07aeh
	mov	a,e
	sta	AIO$UNI
	add	d
	sta	l2034h
	mov	a,d
	cpi	003h
	jrc	bz17	; Z17 boot
	sui	5
	cpi	4
	jrc	bz47	; Z47 boot
	jmp	l0804h

bz17:
	add	e
	cpi	003h
	rnc	; invalid Z17 drive
	sta	AIO$UNI
	in	0f2h
	ani	003h
	jnz	s501er	; no Z17 installed
	mvi	a,07ch
	sta	cport
	lxi	h,m$sdp
	shld	l2086h
	mvi	a,10
	mov	b,a	; B = 10, one full revolution?
	call	take$A	; error after 10 seconds...
	call	m$sdp	; hacked R.SDP - setup dev parms (select drive)
bz17$0:
	call	R$WHD	; WHD - wait hole detect
	call	R$WNH	; WNH - wait no hole
	djnz	bz17$0	; essentially hang until user inserts a disk...
	call	R$ABORT	; R.ABORT - reset everything
	lxi	d,bootbf	; DMA address
	lxi	b,00900h	; B = 9 (num sectors), C = 0 (residual bytes to read)
	lxi	h,0		; track/sector number to start
	call	R$READ
	rc
	pop	h
hxboot:
	lxi	h,CLOCK	; CLOCK - standard 2mS handler
	shld	vrst1+1 ; normal TICK intr routine
	jmp	bootbf	; run boot code...

bz47:
	add	e
	cpi	004h
	rnc
	rrc
	rrc
	rrc
	inr	a
	mov	e,a
	mvi	c,001h
	call	getport
	mov	a,b
	sta	cport
	call	take$5	; error out after 5 seconds...
	mvi	a,002h
	call	s040bh
	mvi	a,002h
	call	s03feh
	mov	a,e
	call	s03fah
	call	l0419h
	ani	00ch
	rrc
	rrc
	inr	a
	mov	b,a
	mvi	a,001h
l03dch:
	add	a
	djnz	l03dch
	rar
	mov	b,a
	lxi	h,bootbf
	push	b
	call	s0422h
	pop	b
	inr	e
	call	s0422h
	call	s0254h
	ani	001h
	rnz
l03f3h:
	xra	a
	sta	l2008h
	jmp	hxboot

s03fah:
	mvi	d,080h
	jr	l0400h
s03feh:
	mvi	d,020h
l0400h:
	stc
	push	psw
l0402h:
	call	s0254h
l0405h:
	ana	d
	jrz	l0402h
	pop	psw
	jr	l040ch
s040bh:
	ora	a
l040ch:
	push	b
	mov	b,a
	lda	cport
	aci	0
	mov	c,a
	mov	a,b
	outp	a
	pop	b
	ret

l0419h:
	call	s0254h
	rlc
	jrnc	l0419h
	jmp	l0255h

s0422h:
	mvi	a,007h
	call	s03feh
	xra	a
	call	s03fah
	mov	a,e
	call	s03fah
l042fh:
	mvi	c,080h
l0431h:
	call	l0419h
	mov	m,a
	inx	h
	dcr	c
	jrnz	l0431h
	dcr	b
	jrnz	l042fh
	ret

; Heath/Zenith device boot table
bootb1:
	db	'B',0	; Z17
	db	'C',46	; Z37
	db	'D',5	; Z47
	db	'E',3	; Z67
	db	0

; ROM start point - initialize everything
init:
	; find amount of RAM
	lxi	h,ramstart-0100h
ramsiz:
	inr	h
	mov	a,m
	inr	m
	cmp	m
	mov	m,a
	jrnz	ramsiz
	dcx	h
	sphl		; set SP to top of RAM (-1)
	push	h	; save top on stack
	lxi	h,re$entry
	push	h
	; determine H19 BAUD, by experimentation
	mvi	c,003h	; br38400
baud0:
	mvi	a,083h
	out	0ebh
	xra	a
	out	0e9h
	mov	a,c
	out	0e8h
	rlc
	mov	c,a
	mvi	a,003h
	out	0ebh
	xra	a
	out	0e9h
	in	0e8h
	lxi	h,initms	; ask H19 for response...
	call	msgout
	mvi	b,25	; loop 6400 times... let Rx overrun...
baud1:
	dcr	a
	jrnz	baud1	; 4096 cycles each
	djnz	baud1	; +13 * 25... 102725 cycles, about 50mS
	in	0edh
	rar
	in	0e8h
	ral
	sui	097h
	jrnz	baud0
	inx	h
	call	msgout
	mvi	b,15	; 15*256 = 3840 loops
baud2:
	dcr	a
	jrnz	baud2
	djnz	baud2
	; compute checksum, compare
	lxi	b,rombeg
	exx
	lxi	d,romend-rst0
	lxi	h,0
	mvi	b,0
cksum0:
	exx
	ldax	b
	inx	b
	exx
	mov	c,a
	dad	b
	dcx	d
	mov	a,d
	ora	e
	jnz	cksum0
	lded	chksum
	dsbc	d
	jz	rom$ok
	lxi	h,erprom
msg$die:
	call	msgout
	di
	hlt
rom$ok:
	xra	a
	sta	l2153h
	sta	l2036h	; 2mS, Org0 OFF
	mvi	a,0c9h	; RET
	sta	l2004h
	lxi	h,05000h
	shld	l2008h
	rst	1	; kick-start clock
	lxi	h,ticcnt
	lxi	d,0280h-440	; tuned to produce ~0x280 for 2.048MHz
	mov	a,m
tick:	; wait for next tick of clock...
	cmp	m
	jrz	tick
	adi	5	; +10mS (actually, +8mS from new tick)
l04d8h:
	inx	d	; count CPU cycles for 8mS...
	cmp	m	; but note: 2mS interrupt overhead,
	cmp	m	; so count will be low.
	jrnz	l04d8h	; each loop = 32 cycles
	mov	a,d
	cpi	002h	; min 9984 cycles... 1.248MHz...
			; max 18144 cycles... 2.268MHz
	jrz	intsetup
	; Unsupported CPU speed...
	lxi	h,unsupm
	call	msgout

intsetup:
	xthl
	push	d
	push	b
	push	psw
	xchg
	lxi	h,10
	dad	sp
	push	h
	push	d
	lxi	d,l2009h
	ldax	d
	cma
	ani	030h
	rz
	lxi	h,2
	dad	sp
	shld	l201dh
	ret

initms:	db	080h,ESC,'[?2h',ESC,'Z',TRM
	db	ESC,'z',TRM

unsupm:	db	'Unsupported CPU speed',TRM

cmdsub:
	lxi	h,subms
	call	msgout
	lxi	h,l2003h
	mvi	d,CR
	call	adrin
	xchg
l0534h:
	call	adrnl
	mov	a,m
	call	hexout
	call	spout
l053eh:
	call	hexin
	jrnc	l055ch
	cpi	CR
	jrz	l0553h
	cpi	'-'
	jrz	l0556h
	cpi	'.'
	rz
	call	belout
	jr	l053eh
l0553h:
	inx	h
	jr	l0534h
l0556h:
	call	conout
	dcx	h
	jr	l0534h
l055ch:
	mvi	m,000h
l055eh:
	call	conout
	call	hexbin
	rld
	call	s056dh
	jrnc	l0553h
	jr	l055eh
s056dh:
	call	conin
	cpi	CR
	rz
	call	hexchk
	cmc
	rc
	call	belout
	jr	s056dh
l057dh:
	call	s01cch
	call	nulfn
coninx:
	in	0edh
	rrc
	jrnc	l057dh
conin:
	in	0edh
	rrc
	jrnc	conin
	in	0e8h
	ani	07fh
	cpi	DEL
	jz	re$entry
	ret

belout:
	mvi	a,BEL
conout:
	push	psw
conot1:
	in	0edh
	ani	00100000b
	jrz	conot1
	pop	psw
	out	0e8h
	ret

; D=term char (e.g. '.' for Substitute)
; HL=location to store address
adrin:
	push	h
	lxi	h,0
adrin0:
	cnc	conin
	call	hexchk
	jrc	adrin1
	call	conout
	call	hexbin
	dad	h
	dad	h
	dad	h
	dad	h
	ora	l
	mov	l,a
	jr	adrin0
adrin1:
	cmp	d
	jrz	adrin2
	call	belout
	ora	a
	jr	adrin0
adrin2:
	call	conout
	xchg
	pop	h
	mov	m,d
	dcx	h
	mov	m,e
	ret

hexbin:
	sui	'9'+1
	jrnc	hexbi0
	adi	7
hexbi0:
	adi	3
	ret

hexin:
	call	conin
hexchk:
	cpi	'0'
	rc	
	cpi	'9'+1
	cmc
	rnc
	ani	05fh	; toupper
	cpi	'A'
	rc	
	cpi	'F'+1
	cmc
	ret

adrnl:
	call	crlf
adrout:
	mov	a,h
	call	hexout
	mov	a,l
	call	hexout
spout:
	mvi	a,' '
	jmp	conout

hexout:
	push	psw
	rlc
	rlc
	rlc
	rlc
	call	hexdig
	pop	psw
hexdig:
	ani	00fh
	adi	090h
	daa
	aci	040h
	daa
	jmp	conout

; Special entry points expected by HDOS, or maybe Heath CP/M boot.
	rept	0613h-$
	db	0
	endm
if	($ != 0613h)
	.error "HDOS entry overrun 0613h"
endif
	jmp	s03fah ; Must be at 0613
	db	0
	jmp	s03feh ; Must be at 0617

waitcr:
	call	conin
	cpi	CR
	jrnz	waitcr
crlf:
	mvi	a,CR
	call	conout
	mvi	a,LF
	jmp	conout

msgout:
	mov	a,m
	ora	a
	rz
	call	conout
	inx	h
	jr	msgout

cserr:
	lxi	h,cserms
	jmp	msgout

cserms:	db	BEL,'Checksum error',TRM

topms:	db	'Top of Memory: ',TRM

cmdmt:
	lxi	h,mtms
	call	msgout
	call	waitcr
	lxi	h,topms
	call	msgout
	lxi	h,0
	dad	sp
	mov	a,h
	inr	a
	jrz	l0673h
	sui	020h
l0673h:
	mov	h,a
	mvi	l,0
	dcx	h
	sui	'0'
	mov	e,a
	call	adrout
	call	crlf
	mvi	d,000h
	mvi	c,030h
	mvi	b,000h
	exx
	lxi	h,l06b3h
	lxi	d,02ff1h	; 03000h - (l06c2h-l06b3h)
	lxi	b,s07aeh-l06b3h
	ldir
	lxi	d,03000h
	lxi	h,l06c2h
	mvi	c,s07aeh-l06c2h
	xra	a
	exaf
	xra	a
l069dh:
	add	m
	exaf
	xchg
	add	m
	exaf
	xchg
	inx	h
	inx	d
	dcr	c
	jnz	l069dh
	mov	c,a
	exaf
	cmp	c
	jnz	cserr
	di
	jmp	02ff8h	; 03000h - (l06c2h-l06bah)

; Start of relocated code...
l06b3h:	db	04h,0ch,04h,08h,0ch,08h,20h

l06bah:
	lxi	h,02ff1h	; 03000h - (l06c2h-l06b3h)
	lxi	b,0700h + 0f2h	; length of unlock sequence, GPIO port
	outir
l06c2h:		; lands at 03000h - retained relocated code
	exx
	mov	h,d
	mvi	l,000h
	mov	a,b
	exx
	mov	c,a
	mvi	b,002h
l06cbh:
	mov	a,c
	rlc
	rlc
	rlc
	rlc
	mov	c,a
	ani	00fh
	adi	090h
	daa
	aci	040h
	daa
	out	0e8h
l06dbh:
	in	0edh
	ani	020h
	jrz	l06dbh
	dcr	b
	jrnz	l06cbh
	mvi	a,00dh
	out	0e8h
	exx
	mov	a,b
l06eah:
	mov	m,a
	adi	001h
	daa
	inr	l
	jrnz	l06eah
	inr	h
	dcr	c
	jrnz	l06eah
	mov	a,h
	sub	d
	mov	c,a
	mov	h,d
	mvi	l,000h
	mov	a,b
l06fch:
	cmp	m
	jrnz	l0745h
	adi	001h
	daa
	inr	l
	jrnz	l06fch
	inr	h
	dcr	c
	jrnz	l06fch
	exx
	lxi	h,03000h
	lxi	d,0
	lxi	b,s07aeh-l06c2h
	exx
	mov	a,d
	xri	030h
	mov	d,a
	jrz	l071dh
	mov	c,e
	jr	l0727h
l071dh:
	mvi	c,030h
	mvi	a,001h
	add	b
	daa
	mov	b,a
	exx
	xchg
	exx
l0727h:
	exx
	ldir
	mov	a,d
	ani	0f0h
	mov	h,a
	mvi	l,000h
	mvi	c,s07aeh-l06c2h
	xra	a
l0733h:
	add	m
	inx	h
	dcr	c
	jrnz	l0733h
	mov	c,a
	exaf
	cmp	c
	jrnz	l0786h
	exaf
	mov	a,d
	ani	0f0h
	mov	h,a
	mvi	l,000h
	pchl
l0745h:
	xra	m
	mov	d,a
	mvi	a,00ah
	out	0e8h
l074bh:
	in	0edh
	ani	020h
	jrz	l074bh
	mvi	c,002h
	mvi	b,004h
l0755h:
	mov	a,h
	rlc
	rlc
	rlc
	rlc
	ani	00fh
	adi	090h
	daa
	aci	040h
	daa
	out	0e8h
l0764h:
	in	0edh
	ani	020h
	jrz	l0764h
	dad	h
	dad	h
	dad	h
	dad	h
	djnz	l0755h
	mvi	a,020h
	out	0e8h
l0774h:
	in	0edh
	ani	020h
	jrz	l0774h
	dcr	c
	xchg
	mvi	b,002h
	jrnz	l0755h
	mvi	a,02ah
	out	0e8h
	jr	l079ah
l0786h:
	in	0edh
	ani	020h
	jrz	l0786h
	mvi	a,00ah
	out	0e8h
l0790h:
	in	0edh
	ani	020h
	jrz	l0790h
	mvi	a,021h
	out	0e8h
l079ah:
	in	0edh
	ani	020h
	jrz	l079ah
	xra	a
	mvi	b,0fah
l07a3h:
	dcr	a
	jrnz	l07a3h
	djnz	l07a3h
	mvi	a,007h
	out	0e8h
	jr	l079ah
; End of relocated code

s07aeh:
	di
	xra	a
	out	07fh
	push	d
	lxi	h,l2009h
	mvi	m,0d0h
	lxi	h,R$CONST
	lxi	d,l2048h
	lxi	b,88
	ldir
	mov	l,e
	mov	h,d
	inx	d
	mvi	c,30
	mov	m,a
	ldir	; fill l20a0h...
	inr	a
	lxi	h,intvec	; vector area
l07cfh:
	mvi	m,0c3h
	inx	h
	mvi	m,LOW (nulint-rst0)
	inx	h
	mvi	m,HIGH (nulint-rst0)
	inx	h
	add	a
	jp	l07cfh
	pop	d
	ret

prompt:	db	CR,LF,'MMS: ',TRM
	db	'(c) 1982 MMS'

nulfn:
	ret

xcmds:
	mov	a,c
	cpi	'T'	; Terminal mode
	jz	termod
	cpi	'R'	; set baud Rate
	jz	setbr
	cpi	'V'	; eprom Version
	jz	prtver
	ret

l0804h:
	mov	a,d
	sui	200
	jrc	l080ah
	mov	d,a
l080ah:
	lxi	h,l0864h
l080dh:
	mov	a,d
	sub	m
	inx	h
	cmp	m
	jrc	l081bh
	mov	a,m
	inx	h
	inx	h
	inx	h
	ora	a
	jrnz	l080dh
	ret
l081bh:
	inx	h
l081ch:
	mov	c,m
l081dh:
	inx	h
	mov	h,m
	mov	l,c
l0820h:
	add	e
	pchl

gtdvtb:
	in	0f2h
	ani	070h
	rlc
	rlc
	rlc
	rlc
	lxi	h,defbt
s082dh:
	add	l
	mov	l,a
	mvi	a,000h
	adc	h
	mov	h,a
	mov	a,m
	cpi	0ffh
	rz
	cpi	0feh
	jz	l083eh
	mov	d,a
l083dh:
	ret
l083eh:
	in	05ch
	ani	0e0h
	rlc
	rlc
	rlc
	lxi	h,auxbt
	call	s082dh
l084bh:
	rz
	in	05ch
	ani	01ch
	rrc
	rrc
	mov	e,a
	ret

s0854h:
	lxi	h,bootb2
l0857h:
	mov	a,m
	inx	h
	mov	d,m
	inx	h
	cmp	b
	rz
	ora	a
	jrnz	l0857h
	mvi	d,000h
	stc
	ret

; disk device/drive table
l0864h:
	db	3,2
	dw	bz67
	db	5,4
	dw	bm314r
	db	15,9
	dw	bm314c
	db	29,8
	dw	bm316
	db	37,1
	dw	bm317
	db	40,1
	dw	bm318
	db	46,4
	dw	bz37
	db	60,1
	dw	bm422
	db	168,4
	dw	bm320
	db	172,4
	dw	bm320
	db	176,4
	dw	bm320
	db	180,4
	dw	bm320
	db	184,4
	dw	bm320
	db	188,4
	dw	bm320
	db	192,4
	dw	bm320
	db	196,4
	dw	bm320
	dw	0

defbt:	; default boot table... port F2 bits 01110000b
	db	33	; -000---- MMS 5" floppy 0
	db	29	; -001---- MMS 8" floppy 0
	db	0ffh	; -010---- n/a  (port 7CH)
	db	0ffh	; -011---- n/a  (port 78H)
	db	0ffh	; -100---- none
	db	0ffh	; -101---- none
	db	60	; -110---- MMS 77422 Network
	db	0feh	; -111---- redirect to I/O board dipsw

auxbt:	; default boot redirect (aux dipsw) bits 11100000b
	db	15	; 000----- MMS 77314 Corvus
	db	200+5	; 001----- MMS 77314 REMEX (Z47)
	db	0ffh	; 010----- none
	db	37	; 011----- MMS 77317 XCOMP
	db	60	; 100----- MMS 77422 Network
	db	168	; 101----- MMS 77320 SASI
	db	0ffh	; 110----- none
	db	0ffh	; 111----- none

bootb2:
	db	'G',200+5	; MMS 77314 REMEX (a.k.a. Z47)
	db	'H',15		; MMS 77314 Corvus
	db	'I',29		; MMS 77316 8"
	db	'J',33		; MMS 77316 5"
	db	'K',37		; MMS 77317 XCOMP
	db	'M',40		; MMS 77318 RAM-disk
	db	'N',60		; MMS 77422 Network
	db	'O',168		; SASI ctrl 0
	db	'P',172		; SASI ctrl 1
	db	'Q',176		; SASI ctrl 2
	db	'R',180		; SASI ctrl 3
	db	'S',184		; SASI ctrl 4
	db	'T',188		; SASI ctrl 5
	db	'U',192		; SASI ctrl 6
	db	'V',196		; SASI ctrl 7
	db	0

bm314c:
	mov	d,a
	mvi	a,10
	call	take$A
	in	058h
	ani	080h
	rnz
	mvi	b,000h
	in	058h
	mov	c,a
	mvi	a,0ffh
	out	059h
bm314$0:
	in	058h
	cmp	c
	jrnz	bm314$1
	djnz	bm314$0
	ret
bm314$1:
	mvi	b,000h
bm314$2:
	xthl
	xthl
	mvi	a,0ffh
	out	059h
bm314$3:
	in	058h
	rrc
	jrc	bm314$3
	rrc
	jrc	bm314$4
	djnz	bm314$2
	ret
bm314$4:
	call	s098ch
	cpi	08fh
	rnz
	lxiy	bootbf
	mov	a,d
	cpi	9
	rnc
	mov	d,a
	add	a
	add	d
	mov	c,a
	mvi	b,0
	dady	b
	lxix	bootbf
	lxi	b,256
	lxi	d,0
	call	s0943h
	rc
	ldy	a,+0
	ral
	rc
	ldy	c,+0
	ldy	d,+1
	ldy	e,+2
	lxix	bootbf
	mvi	b,2
	call	s0943h
	rc
	jmp	l03f3h

s0943h:
	mvi	a,012h
	call	s0982h
	mov	a,c
	add	a
	add	a
	add	a
	add	a
	inr	a
	call	s0982h
	mov	a,e
	call	s0982h
	mov	a,d
	call	s0982h
l0959h:
	in	058h
	ani	002h
	jrz	l0959h
	mvi	a,008h
l0961h:
	dcr	a
	jnz	l0961h
	call	s098ch
	rlc
	rc
	mvi	l,080h
l096ch:
	call	s098ch
	stx	a,+000h
	inxix
	dcr	l
	jrnz	l096ch
	inr	e
	jrnz	l097eh
	inr	d
	jrnz	l097eh
	inr	c
l097eh:
	djnz	s0943h
	ora	a
	ret

; Corvus I/O
s0982h:
	push	psw
l0983h:
	in	058h
	rar
	jrc	l0983h
	pop	psw
	out	059h
	ret

s098ch:
	in	058h
	rar
	jrc	s098ch
	in	059h
	ret
bm316:
	lxi	h,l0a0ch
	shld	vrst6+1
	cpi	008h
	rnc
	ori	028h
	mov	d,a
	out	038h
	xra	a
	out	0f2h
	mvi	a,00bh
	call	s0a07h
	lxi	b,0cf08h
l09adh:
	in	03ch
	rlc
	jrnc	l09b7h
	dcx	b
	mov	a,b
	ora	c
	jrnz	l09adh
l09b7h:
	in	03ch
	ani	099h
	rnz
	mvi	e,019h
l09beh:
	lxi	h,bootbf
	xra	a
l09c2h:
	inr	a
	out	03eh
	lxi	b,003fh
	mvi	a,088h
	call	s09e5h
	ani	0bfh
	mov	a,d
	out	038h
	jz	l09dch
	xri	040h
	mov	d,a
	dcr	e
	jrnz	l09beh
	ret
l09dch:
	in	03eh
	cpi	002h
	jrc	l09c2h
	jmp	l03f3h
s09e5h:
	push	psw
	mov	a,d
	ani	044h
	jrnz	l09fah
	mov	a,d
	ani	0dfh
	out	038h
	pop	psw
	out	03ch
	ei
	hlt
l09f5h:
	ini
	jmp	l09f5h
l09fah:
	mov	a,d
	out	038h
	pop	psw
	out	03ch
s0a00h:
	ei
l0a01h:
	hlt
	ini
	jmp	l0a01h
s0a07h:
	out	03ch
s0a09h:
	ei
l0a0ah:
	jr	l0a0ah
l0a0ch:
	pop	psw
	in	03ch
	ei
	ret
bz37:
	lxi	h,l0a97h
	shld	vrst4+1
	dcx	h
	shld	l2037h
	cpi	004h
	rnc
	inr	a
	mvi	l,008h
l0a21h:
	dad	h
	dcr	a
	jrnz	l0a21h
	out	079h
	in	0f2h
	ani	00ch
	rnz
	mvi	a,078h
	sta	cport
	mvi	a,0d0h
	out	07ah
	mov	a,l
	ori	008h
	mov	d,a
	out	078h
	inr	d
	mvi	e,019h
	mvi	a,5
	call	take$A
	lxi	b,0147bh
l0a46h:
	in	07ah
	xra	b
	ani	002h
	jrz	l0a46h
	djnz	l0a46h
l0a4fh:
	lxi	h,bootbf
	mvi	a,001h
	out	079h
	out	07ah
	mov	a,d
	out	078h
	mvi	b,004h
l0a5dh:
	xra	a
	out	079h
	mvi	a,040h
	out	07ah
	call	s0a09h
	djnz	l0a5dh
	xra	a
	out	079h
	mvi	a,00bh
	out	07ah
	call	s0a09h
	mov	a,d
	xri	004h
	mov	d,a
	ori	002h
	out	078h
	mvi	a,09ch
	out	07ah
	call	s0a00h
	ani	0efh
	jrnz	l0a93h
	mov	a,h
	cpi	02ch
	jrc	l0a93h
	mvi	a,008h
	out	078h
	pop	h
	jmp	l03f3h
l0a93h:
	dcr	e
	jrnz	l0a4fh
	ret
l0a97h:
	in	07ah
	xthl
	lhld	l2037h
	xthl
	ei
	ret
bm317:
	ora	a
	rnz
	out	04ch
	out	048h
	out	049h
	call	s0b65h
	lxi	h,l0b76h
	mov	a,m
	out	04ch
	inx	h
	mov	a,m
	out	04dh
	inx	h
	mvi	c,04eh
l0ab8h:
	mov	a,m
	ora	a
	jrz	l0ad0h
	inx	h
	mov	b,a
	ral
	jrc	l0ac5h
	outir
	jr	l0ab8h
l0ac5h:
	ora	a
	rar
	mov	b,a
	mov	a,m
	inx	h
l0acah:
	out	04eh
	djnz	l0acah
	jr	l0ab8h
l0ad0h:
	mvi	a,041h
	out	049h
	mvi	a,002h
	out	048h
	call	s0b34h
	rnz
	call	s0af4h
	rnz
	mvi	a,002h
	out	04ch
	xra	a
	out	04dh
	mov	b,a
	mvi	c,04eh
	lxi	h,bootbf
	in	04eh
	inir
	jmp	l03f3h
s0af4h:
	mvi	d,00ah
	mvi	a,004h
	out	04ch
	mvi	a,0eah
	out	04dh
	mvi	b,004h
	xra	a
l0b01h:
	out	04eh
	djnz	l0b01h
l0b05h:
	call	s0b56h
	rnz
	xra	a
	out	04ch
	mvi	a,0d7h
	out	04dh
	mvi	a,008h
	out	04ch
l0b14h:
	in	04ch
	rrc
	jnc	l0b14h
	nop
	in	04ch
	mov	b,a
	xra	a
	out	04ch
	mov	a,b
	ani	00eh
	mov	b,a
	in	048h
	ani	002h
	cnz	s0b5dh
	ora	b
	rz
	dcr	d
	jrnz	l0b05h
l0b31h:
	ori	001h
	ret
s0b34h:
	mvi	b,000h
l0b36h:
	in	048h
	ani	004h
	xri	004h
	rz
	dcr	b
	jrz	l0b31h
	xra	a
	out	04bh
	inr	a
	out	04ah
	mvi	a,003h
	out	048h
	call	s0b50h
	jmp	l0b36h
s0b50h:
	in	048h
	ral
	jrnc	s0b50h
	ret
s0b56h:
	in	048h
	ani	001h
	xri	001h
	ret
s0b5dh:
	xra	a
	out	049h
	mvi	a,041h
	out	049h
	ret
s0b65h:
	xra	a
	call	s0b6bh
	mvi	a,001h
s0b6bh:
	out	04ch
	mvi	b,080h
	mvi	a,00fh
l0b71h:
	out	04eh
	djnz	l0b71h
	ret

RPT	equ	80h

l0b76h:
	db	0	;out 4C
	db	0d7h	;out 4D
	db	2,	040h,041h	; -> 4E
	db	RPT+3,	040h	; 3x040h -> 4E
	db	RPT+12,	06dh	; 12x06dh -> 4E
	db	1,	063h
	db	RPT+4,	065h
	db	RPT+2,	067h
	db	1,	049h
	db	RPT+2,	040h
	db	RPT+12,	06dh
	db	3,	063h,0e7h,067h
	db	RPT+7,	00fh
	db	2,	040h,041h
	db	RPT+3,	040h
	db	RPT+12,	06dh
	db	1,	063h
	db	RPT+2,	065h
	db	RPT+2,	060h
	db	RPT+2,	067h
	db	1,	00fh
	db	0

bm320:
	cpi	4 ; 4 units per controller, max
	rnc
	mov	e,a	; relative drive num
	mov	a,d ; phy drv
	sui	168
	ani	0fch	; Controller num
	rrc
	rrc
	mov	d,e ; D = relative drive num
	mov	e,a ; E = controller num
	mov	a,d
	jmp	bsasi

bz67:
	cpi	2
	rnc	
	mvi	e,0	; Controller 0 only
bsasi:
	rrc
	rrc
	rrc
	db 0ddh
	mov h,a	; movxh	a	; 0xx00000 = relative drive num (LUN)
	mvi	c,2
	call	getport
	rnz
	mov	a,b
	sta	cport
	inr	a
	mov	c,a
	xra	a
	outp	a
	lxi	h,0		; zero-out command buffer
	shld	l2132h
	shld	l2134h
	shld	l2136h
	shld	l2156h	; zero-out ...
	shld	l2158h
	sta	l215ah
	mov	d,e
	mvi	a,004h
	ora	a
	ei
l0be7h:
	rz
	call	s002bh
	mvi	e,000h
	call	s0c0ah
	mvi	a,0ffh
	jrc	l0be7h
	mvi	e,001h
	call	s0c0ah
	rc
	lxi	h,0800ah
	shld	l2136h
	mvi	e,008h
	call	s0c0ah
	rc
	pop	h
	jmp	l03f3h

s0c0ah:
	di
	db 0ddh
	mov l,e	; movxl	e	; controller num
	sixd	l2132h
	mvi	b,000h
	mvi	e,006h
	lxi	h,0
l0c18h:
	inp	a
	ani	008h
	cmp	b
	jrz	l0c29h
	dcx	h
	mov	a,l
	ora	h
	jrnz	l0c18h
	dcr	e
	jrnz	l0c18h
	stc
	ret
l0c29h:
	mov	a,b
	xri	008h
	jrz	l0c3eh
	mov	b,a
	dcr	c
	xra	a
	outp	a
	inr	c
	inr	c
	outp	d
	dcr	c
	mvi	a,040h
	outp	a
	jr	l0c18h
l0c3eh:
	mvi	a,002h
	outp	a
	lxi	h,l2132h
l0c45h:
	inp	a
	bit	7,a
	jrz	l0c45h
	bit	4,a
	jrz	l0c59h
	bit	6,a
	jrz	l0c6ch
	dcr	c
	outi
	inr	c
	jr	l0c45h
l0c59h:
	lxi	h,bootbf
l0c5ch:
	inp	a
	bit	7,a
	jrz	l0c5ch
	bit	4,a
	jrnz	l0c6ch
	dcr	c
	ini
	inr	c
	jr	l0c5ch
l0c6ch:
	inp	a
	ani	0d0h
	cpi	090h
	jrnz	l0c6ch
	dcr	c
	inp	l
	inr	c
l0c78h:
	inp	h
	mov	a,h
	ani	0e0h
	cpi	0a0h
	jrnz	l0c78h
	shld	l2138h
	dcr	c
	inp	a
	inr	c
	ei
	ora	a
	stc
	rnz
	bit	0,l
	rnz
	bit	1,l
	rnz
	bit	1,h
	rnz
	xra	a
	ret
bm314r:
	cpi	004h
	rnc
	rrc
	rrc
	rrc
	inr	a
	mov	d,a
	mvi	a,5
	call	take$A
	in	05bh
	ani	004h
	rnz
	out	05bh
bm314$5:
	in	05bh
	ral
	jrc	bm314$5
bm314$6:
	mvi	a,007h
	out	05ah
	xra	a
	call	s0d0ch
	mov	a,d
	call	s0d0ch
bm314$7:
	in	05bh
	ani	080h
	jrz	bm314$7
bm314$8:
	in	05bh
	ani	040h
	jrnz	bm314$8
	in	05bh
	ani	010h
	rnz
	lxi	h,bootbf
	mvi	b,080h
	mvi	c,05ah
bm314$9:
	in	05bh
	ani	040h
	jrnz	bm314$9
	ini
	jrnz	bm314$9
	mvi	b,000h
bm314$A:
	in	05bh
	ani	040h
	jrz	bm314$B
	djnz	bm314$A
	in	05bh
	ani	010h
	rnz
	inr	d
	mov	a,d
	ani	00fh
	cpi	003h
	jrc	bm314$6
	jmp	l03f3h
bm314$B:
	mvi	b,080h
bm314$D:
	in	05bh
	ani	040h
	jrnz	bm314$D
	ini
	jrnz	bm314$D
	in	05bh
	ani	010h
	rnz
	jmp	l03f3h

s0d0ch:
	push	psw
l0d0dh:
	in	05bh
	ani	060h
	jrnz	l0d0dh
	pop	psw
	out	05ah
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MMS 77318 (RAM-disk) boot
bm318:
	di
	lxi	h,l318rt
	lxi	d,ramboot
	lxi	b,l318sz
	ldir
	jmp	ramboot

; MMS 77318 (RAM-disk) boot loader - relocated to ramboot
l318rt:
	lxi	h,ramboot+l318lo
	mvi	b,l318lz
	mvi	c,0f2h
	outir	; unlock memory and select OS image bank
	lda	0
	cpi	0c3h	; JMP - does OS look good?
	jz	0	; start OS
	outi	; re-select ROM bank
	ei
	ret	; return to monitor (boot error)

; 77318 Unlock and select bank "E" (16K common + "bank 1")
; NOTE: "22h" should not be there, left-over cruft from CP/M unlock.
l318lo	equ	$-l318rt
l318ul:	db	04h,0ch,04h,08h,0ch,08h,22h,10h
l318lz	equ	$-l318ul
	db	0	; fall-back to ROM on error...
l318sz	equ	$-l318rt
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MMS 77422 (Network) boot loader
bm422:
	lxix	bootbf
	mvix	0b1h,+0 ; Boot code = B1
	stx	e,+4	; Unit number
	mvi	c,3
	call	getport
	rnz
	mov	a,b
	sta	cport
	lxi	h,int422
	shld	vrst5+1
	ei
	call	syn422
	lxi	h,0	; delay count for "ready"
	lda	cport	; Port
	mov	c,a
	inr	c
bm422$0:
	inp	a
	ani	00000100b
	jnz	bm422$1
	dcx	h
	mov	a,h
	ora	l
	jnz	bm422$0
	ret
bm422$1:
	lxi	h,bootbf
	lxi	d,7
	call	snd422
	mvi	a,0d6h	; D6 = send status
	call	get422
	ldx	a,+1	; error code
	ora	a
	rnz	 ; abort if error
	mvi	a,0b0h	; B0 = Boot response
	call	get422
	ldx	l,+5	; Code address
	ldx	h,+6	;
	ldx	e,+1	; Code length
	ldx	d,+2	;
	ldx	a,+3	; error code
	ora	a
	rnz	; abort if error
	push	h	; return to code address...
	jmp	rcv422	; get the boot code... (OS code?)

; Wait for network message type in A,
; must watch for stray CP/NET messages and discard
get422:
	push	psw
get422$0:
	lxi	h,bootbf
	lxi	d,7
	call	rcv422
	ldx	a,+0
	pop	b
	cmp	b
	rz	; got desired message type
	push	b
	ani	11110001b
	cpi	0c0h	; CP/Net message
	jrnz	get422$0
	lxi	h,bootbf	; Receive and discard...
	ldx	e,+1
	ldx	d,+2
	call	rcv422
	jmp	get422$0

; Gobble data until we reach a sync point
syn422:
	lxi	d,0		; delay count
	lxi	h,l0de6h
	lda	cport	; port
	mov	c,a
syn422$0:
	inp	a
	inr	c
	inp	a
	dcr	c
	ani	00001000b	; sync?
	rz
	dcx	d	; timeout
	mov	a,d
	ora	e
	jnz	syn422$0
	ret

l0de6h: db	0,0,0

snd422:
	mov	a,e
	ora	a
	mov	e,d
	jz	snd422$0
	inr	e	; round up to 256-byte page
snd422$0:
	mov	b,a
	lda	cport
	mov	c,a
snd422$1:
	inr	c
snd422$2:
	inp	a
	ani	00000100b
	jz	snd422$2
	dcr	c
	outi
	jnz	snd422$1
	dcr	e
	jnz	snd422$1
	ret

rcv422:
	dcx	d
	mov	a,e
	ora	a
	mov	e,d
	jrz	rcv422$0
	inr	e
rcv422$0:
	mov	b,a
	lda	cport	; port
	mov	c,a
rcv422$1:
	inr	c
rcv422$2:
	inp	a
	ani	00001000b	; rcv data ready...
	jrz	rcv422$2
	dcr	c
	ini
	jnz	rcv422$1
	dcr	e
	jrnz	rcv422$1
rcv422$3:
	inp	a		; keep tugging on data port until interrupt
	jr	rcv422$3	; wait for completion...

; Interrupt handler for MMS 77422
int422:
	inr	c
	outp	a	; reset?
	dcr	c
	ini		; one last data byte???
	pop	b	; discard INT addr
	ei
	ret	; return to caller of rcv422

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Terminal mode - shuttle I/O between H19 and serial port
; since both ports operate at the same speed, don't need
; to check ready as often.
termod:
	lxi	h,terms
	call	msgout
	call	waitcr
termfl:
	in	0edh
	ani	01100000b
	cpi	01100000b
	jnz	termfl	; wait for output to flush
	in	0ebh
	ori	10000000b
	out	0ebh
	out	0dbh
	in	0e8h
	out	0d8h
	in	0e9h
	out	0d9h
	in	0ebh
	ani	01111111b
	out	0ebh
	out	0dbh
	xra	a
	out	0d9h
	in	0d8h
	mvi	a,00fh
	out	0dch
termlp:
	in	0ddh
	ani	00000001b
	jz	terml0
	in	0d8h
	out	0e8h
terml0:
	in	0edh
	ani	00000001b
	jz	termlp
	in	0e8h
	out	0d8h
	jmp	termlp

terms:	db	'Terminal Mode',TRM

setber:
	mvi	a,BEL
	call	conout
	pop	h
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set BAUD command
setbr:
	lxi	h,ratems
	call	msgout
	call	conin
	ani	11011111b	; toupper
	mov	c,a
	call	conout
	sui	'A'
	cpi	'O'-'A'
	jnc	setber
	mov	e,a
	mvi	d,0
	lxi	h,brtab
	dad	d
	dad	d
	dad	d
	dad	d
	mov	e,m
	inx	h
	mov	d,m	; DE=baud divisor
	inx	h
	mov	a,m
	inx	h
	mov	h,m
	mov	l,a	; HL=rate string
	call	msgout
	lxi	h,baudms
	call	msgout
	call	waitcr
	mvi	a,ESC
	call	conout
	mvi	a,'r' ; Set Baud
	call	conout
	mov	a,c ; Baud value
	call	conout
setbrf:
	in	0edh
	ani	01100000b
	cpi	01100000b
	jnz	setbrf	; flush output
	lxi	b,4000	; delay value ~43mS
setbr0:
	dcx	b
	mov	a,b
	ora	c
	jnz	setbr0
	in	0ebh
	ori	10000000b	; divsor latch enable
	out	0ebh
	mov	a,e
	out	0e8h
	mov	a,d
	out	0e9h
	in	0ebh
	ani	01111111b	; divisor latch disable
	out	0ebh
	pop	h
	ret

ratems:	db	'Rate - ',TRM

brtab:
	dw	1047,	br110
	dw	768,	br150
	dw	384,	br300
	dw	192,	br600
	dw	96,	br1200
	dw	64,	br1800
	dw	58,	br2000
	dw	48,	br2400
	dw	32,	br3600
	dw	24,	br4800
	dw	16,	br7200
	dw	12,	br9600
	dw	6,	br19200
	dw	3,	br38400

br110:	db	' (110',TRM
br150:	db	' (150',TRM
br300:	db	' (300',TRM
br600:	db	' (600',TRM
br1200:	db	' (1200',TRM
br1800:	db	' (1800',TRM
br2000:	db	' (2000',TRM
br2400:	db	' (2400',TRM
br3600:	db	' (3600',TRM
br4800:	db	' (4800',TRM
br7200:	db	' (7200',TRM
br9600:	db	' (9600',TRM
br19200: db	' (19200',TRM
br38400: db	' (38400',TRM
baudms:	db	' baud)',TRM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Print ROM version command
prtver:
	lxi	h,versms
	call	msgout
	lda	vers
	call	hexout
	pop	h
	ret

versms:	db	'Version ',TRM
vers:	db	010h	; version byte... "1.0"

erprom:	db	CR,LF,BEL,'EPROM err',TRM

	rept	1000h-$-4
	db	0ffh
	endm
romend:
	dw	0
chksum:
	dw	099b6h	; checksum...

if	($ != 1000h)
	.error "i2732 ROM overrun"
endif
	end
