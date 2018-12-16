; Z89/Z90 Monitor EPROM 444-84B, by Magnolia Microsystems
VERN	equ	11h	; version 1.1

	maclib	z80
	$*macro

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
ctl$F0:	ds	1	; - 02009h
	ds	17
ticcnt:	ds	2	; - 0201bh
monstk:	ds	2	; - 0201dh
intvec:
vrst1:	ds	3	; rst1 jmp vector - 0201fh
vrst2:	ds	3	; rst2 jmp vector - 02022h
vrst3:	ds	3	; rst3 jmp vector - 02025h
vrst4:	ds	3	; rst4 jmp vector - 02028h
vrst5:	ds	3	; rst5 jmp vector - 0202bh
vrst6:	ds	3	; rst6 jmp vector - 0202eh
vrst7:	ds	3	; rst7 jmp vector - 02031h
l2034h:	ds	2	; - 02034h
ctl$F2:	ds	1	; - 02036h GPP template/image
l2037h:	ds	2	; - 02037h
	ds	7
l2040h:	ds	8
D$CONST: ds	88+20	; - 02048h	disk constants
DECNT:	ds	1	; - 020b4h
	ds	124
AIO$UNI: ds	1	; - 02131h
cmdbuf:	ds	6	; SASI command buffer
resbuf:	ds	2	; SASI result buffer
	ds	22
cport:	ds	1	; - 02150h
	ds	1
SEC$CNT:	ds	1	; - 02152h
l2153h:	ds	1
	ds	2
l2156h:	ds	6	; ??? for SASI?
	ds	292
bootbf:	ds	0	; - 02280h

memtest	equ	03000h
ramboot	equ	0c000h

; Start of ROM code
	org	00000h

rombeg:
rst0:	jmp	init

bootms:	db	'oot ',TRM

rst1:	call	intsetup
	lhld	ticcnt
	jmp	int1$cont
if ((high int1$cont) != 0)
	.error "Overlapped NOP error"
endif

rst2	equ	$-1	; must be a nop...
	call	intsetup
	ldax	d
	jmp	int2$cont

rst3:	jmp	vrst3

goms:	db	'o ',TRM
	db	0,0

rst4:	jmp	vrst4

	db	0,0,0,0,0

rst5:	jmp	vrst5
delayx:
	jmp	delay

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
	lxi	h,ctl$F2
	ora	m
	out	0f2h ; simulate some H8 features
nmi$xit2:
	pop	psw
nmi$xit:
	pop	h
	xthl
	retn

int1$1:
	ldax	b
	rrc
	cc	vrst1
intret:
	pop	psw
	pop	psw
	pop	b
	pop	d
	pop	h
nulint:
	ei
	ret

int1$cont:
	inx	h
	shld	ticcnt
	lxi	b,ctl$F0
	ldax	b
	out	0f0h
	ani	020h
	jrnz	intret
	dcx	b
int1$0:
	ldax	b
	ral
	jrc	int1$1
	lxi	h,10
	dad	sp
	mov	e,m
	inx	h
	mov	d,m
	dcx	d
	ldax	d
	cpi	076h	; HLT
	jrnz	int1$1
	call	belout
	mvi	a,'H'
	call	conout
re$entry:		; re-entry point for errors, etc.
	lxi	h,ctl$F0
	mvi	m,0f0h	; !beep, 2mS, MON, !SI
	lhld	monstk
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
	ani	01011111b ; toupper
	lxi	h,cmdtab
	mvi	b,5
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
	db	0

	; patched-out code?
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
	jmp	z47$dati

cmdpc:
	lxi	h,pcms
	call	msgout
	lxi	h,12
	dad	sp
	mov	e,m
	inx	h
	mov	d,m
	xchg
	call	inhexcr
	jrc	cmdpc0
	call	adrnl
	call	inhexcr
	rnc
cmdpc0:
	xchg
cmdpc1:
	mvi	d,CR
	jmp	adrin

cmdgo:
	lxi	h,goms
	call	msgout
	lxi	h,13
	dad	sp
	call	inhexcr
	cc	cmdpc1	; read HEX until CR
	call	crlf
	mvi	a,0d0h	; no-beep, 2mS, !MON, !single-step
	jr	cmdgo0
	di
	lda	ctl$F0
	xri	010h	; toggle single-step
	out	0f0h
cmdgo0:
	sta	ctl$F0
	pop	h
	jmp	intret

int2$cont:
	ori	010h	; disable single-step
	out	0f0h
	stax	d
	ani	020h	; MON active?
	jnz	start	; break to monitor code
	jmp	vrst2	; else chain to (possible) user code.

take$5:
	mvi	a,5	; 5 seconds
take$A:
	lxi	h,timeout
	shld	vrst1+1
	sta	SEC$CNT
	mvi	a,1
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
error:
	lhld	monstk
	sphl
	lxi	h,qmsg
	call	msgout
	lxi	h,nulint
	shld	vrst1+1
	sta	l2008h
	in	0f2h
	ani	00000011b
	jrnz	error0
	out	07fh
error0:
	jmp	re$entry

chkauto:
	lxi	h,l2153h	; auto-boot disable?
	in	0f2h
	mov	d,a
	xri	080h	; toggle auto-boot
	ora	m
	rm		; auto-boot OFF
	mov	m,d	; ensure we only fail once... and only on power-up?
	call	gtdfbt
	lxi	h,autbms
	call	msgout
	lxi	sp,bootbf
	jmp	goboot0

autbms:	db	'Auto Boot',TRM

; determine device for port 078H
; return phy drv number in D.
gtdev1:
	mvi	d,0	; Z17
	in	0f2h
gtdev0:
	ani	00000011b	; port 078H device
	rz		; Z17 (or Z37)
	cpi	01b
	mvi	d,5
	rz		; Z47
	cpi	10b
	mvi	d,3
	rz		; Z67/MMS77320
	mvi	d,60
	ret		; MMS77422 Network

; determine device for port 078H
; return phy drv number in D.
gtdev2:
	mvi	d,46	; Z37
	in	0f2h
	rrc
	rrc
	jr	gtdev0	; rest are same

; determine default boot device.
gtdfbt:
	lxi	d,0
	in	0f2h
	ani	01110000b	; default boot selection
	cpi	00100000b	; device at 07CH
	jrz	gtdev1
	cpi	00110000b	; device at 078H
	jrz	gtdev2
	jmp	gtdvtb		; get MMS device

; Check SW501 for installed device.
; C = desired port pattern, 00=Z17/Z37, 01=Z47, 10=Z67, 11=77422
; returns base I/O port adr in B.
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

; hack to support 3 drives on H17
m$sdp:
	mvi	a,10
	sta	DECNT
	lda	AIO$UNI
	push	psw	; 0,1,2
	adi	-2	;
	aci	3	; 1,2,4
	jmp	R$SDP+10	; hacked R.SDP for 3-drives

inport0:
	ora	a	; NC
; input from cport+CY
inportx:
	push	b
	lda	cport
	aci	0
	mov	c,a
	inp	a
	pop	b
	ret

delay:
	push	h
	lxi	h,ticcnt
	add	m
delay0:
	cmp	m
	jrnz	delay0
	pop	h
	ret

digerr:
	call	belout
	jr	btdig0
; Got a digit in boot command, parse it
btdig:
	call	conout	; echo digit
	ani	00fh	; convert to binary
	mov	d,a
btdig0:
	call	conin	; get another, until term char (C)
	cmp	c
	jrz	gotnum
	cpi	'0'
	jrc	digerr
	cpi	'9'+1
	jrnc	digerr
	call	conout
	ani	00fh
	mvi	b,10	; add 10 times, i.e. D = (D * 10) + A
btdig1:
	add	d
	jc	error
	djnz	btdig1
	mov	d,a
	cpi	200
	jnc	error
	jr	btdig0

gotnum:
	mov	a,d
	cpi	5
	jc	goboot
	cpi	9
	jnc	goboot
	adi	200	; modify 5..8 to not conflict
	mov	d,a
	jmp	goboot

cmdboot:
	lxi	h,bootms
	call	msgout	; complete (B)oot
	lxi	sp,bootbf
	call	gtdfbt
	mvi	c,CR	; end input on CR
	jr	boot0
bterr:
	call	belout
boot0:
	call	conin
	cmp	c
	jz	goboot
	mvi	e,0
	cpi	'0'
	jrc	nodig
	cpi	'9'+1
	jrc	btdig
nodig:
	ani	05fh ; toupper
	cpi	'Z'+1
	jrnc	bterr
	cpi	'A'
	jrc	bterr
	call	conout
	call	conout
	cpi	'B'
	jrc	gotit	; 'A' is synonym for default
	lxi	h,bootb1	; Heath/Zenith device letters
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
	call	mmslookup
	jc	error
gotit:
	mvi	a,'-'	; next is optional unit number...
	call	conout
	jr	luboot0

lunerr:
	call	belout
luboot0:
	call	conin
	cmp	c
	jrz	goboot
	cpi	':'
	jrz	colon
	cpi	' '
	jrz	space
	cpi	'0'
	jrc	lunerr
	cpi	'9'+1
	jrnc	lunerr
	call	conout
	sui	'0'
	mov	e,a
luboot1:
	call	conin
	cmp	c
	jrz	goboot
	cpi	':'
	jrz	colon
	cpi	' '
	jrz	space
	mvi	a,BEL
space:
	call	conout
	jr	luboot1

colon:	; get arbitrary string as last boot param
	mvi	b,0
	lxi	h,bootbf
btstr0:
	call	conout
	call	conin
	inr	b
	inx	h
	mov	m,a
	cmp	c
	jrnz	btstr0
	xra	a	; TRM - string terminator
btstr1:	; use stack as char array...
	push	psw
	inx	sp	; undo half of push
	dcx	h
	mov	a,m
	djnz	btstr1
goboot:
	call	crlf
goboot0:
	lxi	h,error
	push	h
	call	h17init
	mov	a,e
	sta	AIO$UNI
	add	d
	sta	l2034h
	mov	a,d
	cpi	3	; 0,1,2
	jrc	bz17	; Z17 boot
	; 3,4 not used?
	sui	5
	cpi	4	; 5,6,7,8
	jrc	bz47	; Z47 boot
	jmp	exboot

bz17:
	add	e
	cpi	3
	rnc	; invalid Z17 drive
	sta	AIO$UNI
	in	0f2h
	ani	00000011b
	jnz	s501er	; no Z17 installed
	mvi	a,07ch
	sta	cport
	lxi	h,m$sdp
	shld	D$CONST+62
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
	mvi	c,01b
	call	getport
	mov	a,b
	sta	cport
	call	take$5	; error out after 5 seconds...
	mvi	a,2
	call	outport0
	mvi	a,2
	call	z47$cmdo
	mov	a,e
	call	z47$dato
	call	z47$dati
	ani	00ch
	rrc
	rrc
	inr	a
	mov	b,a
	mvi	a,1
bz47$0:
	add	a
	djnz	bz47$0
	rar
	mov	b,a
	lxi	h,bootbf
	push	b
	call	z47$read
	pop	b
	inr	e
	call	z47$read
	call	inport0
	ani	001h
	rnz
hwboot:
	xra	a
	sta	l2008h
	jmp	hxboot

z47$dato:
	mvi	d,080h	; TR - date transfer request
	jr	z47$out0
z47$cmdo:
	mvi	d,020h	; DONE
z47$out0:
	stc
	push	psw
z47$wt0:
	call	inport0
	ana	d
	jrz	z47$wt0
	pop	psw
	jr	z47$out1
outport0:
	ora	a
z47$out1:
	push	b
	mov	b,a
	lda	cport
	aci	0
	mov	c,a
	mov	a,b
	outp	a
	pop	b
	ret

z47$dati:
	call	inport0
	rlc	; TR
	jrnc	z47$dati
	jmp	inportx	; CY=1, input cport+1

z47$read:
	mvi	a,7	; read thru buffer command
	call	z47$cmdo
	xra	a
	call	z47$dato	; params
	mov	a,e
	call	z47$dato	; params
z47$rd0:
	mvi	c,128
z47$rd1:
	call	z47$dati
	mov	m,a
	inx	h
	dcr	c
	jrnz	z47$rd1
	dcr	b
	jrnz	z47$rd0
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
	lxi	d,romend-rombeg
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
	sta	ctl$F2	; 2mS, Org0 OFF
	mvi	a,0c9h	; RET
	sta	l2004h
	lxi	h,05000h	; 0, (beep, 2mS, !MON, !SI)
	shld	l2008h
	rst	1	; kick-start clock
	lxi	h,ticcnt
	lxi	d,0280h-440	; tuned to produce ~0x280 for 2.048MHz
	mov	a,m
tick0:	; wait for next tick of clock...
	cmp	m
	jrz	tick0
	adi	5	; +10mS (actually, +8mS from new tick)
tick1:
	inx	d	; count CPU cycles for 8mS...
	cmp	m	; but note: 2mS interrupt overhead,
	cmp	m	; so count will be low.
	jrnz	tick1	; each loop = 32 cycles
	mov	a,d
	cpi	2	; min 9984 cycles... 1.248MHz...
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
	lxi	d,ctl$F0
	ldax	d
	cma
	ani	030h
	rz
	lxi	h,2
	dad	sp
	shld	monstk
	ret

initms:	db	080h,ESC,'[?2h',ESC,'Z',TRM
	db	ESC,'z',TRM

unsupm:	db	'Unsupported CPU speed',TRM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Substitute command
cmdsub:
	lxi	h,subms
	call	msgout
	lxi	h,l2003h
	mvi	d,CR
	call	adrin
	xchg
cmdsub0:
	call	adrnl
	mov	a,m
	call	hexout
	call	spout
cmdsub1:
	call	hexin
	jrnc	cmdsub4
	cpi	CR
	jrz	cmdsub2
	cpi	'-'
	jrz	cmdsub3
	cpi	'.'
	rz
	call	belout
	jr	cmdsub1
cmdsub2:
	inx	h
	jr	cmdsub0
cmdsub3:
	call	conout
	dcx	h
	jr	cmdsub0
cmdsub4:
	mvi	m,000h
cmdsub5:
	call	conout
	call	hexbin
	rld
	call	inhexcr
	jrnc	cmdsub2
	jr	cmdsub5

inhexcr:
	call	conin
	cpi	CR
	rz
	call	hexchk
	cmc
	rc
	call	belout
	jr	inhexcr

; This loop checks for auto boot while waiting for command input.
; Theoretically, one could flip the auto-boot dipsw at the MMS: prompt?
coninx0:
	call	chkauto
	call	nulfn	; some patched-out code?
coninx:
	in	0edh
	rrc
	jrnc	coninx0
conin:
	in	0edh
	rrc
	jrnc	conin
	in	0e8h
	ani	07fh
	cpi	DEL	; DEL key restarts from anywhere?
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
	jmp	z47$dato ; Must be at 0613
	db	0
	jmp	z47$cmdo ; Must be at 0617

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Memory Test command
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
	jrz	cmdmt0
	sui	020h
cmdmt0:
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
	lxi	h,mtest0
	lxi	d,memtest - (mtest1-mtest0)
	lxi	b,mtestZ-mtest0
	ldir
	lxi	d,memtest
	lxi	h,mtest1
	mvi	c,mtestZ-mtest1
	xra	a
	exaf
	xra	a
cmdmt1:
	add	m
	exaf
	xchg
	add	m
	exaf
	xchg
	inx	h
	inx	d
	dcr	c
	jnz	cmdmt1
	mov	c,a
	exaf
	cmp	c
	jnz	cserr
	di
	jmp	memtest - (mtest1-mtest)

;------------------------------------------------
; Start of relocated code...
; Memory Test routine, position-endependent
;
mtest0:	db	04h,0ch,04h,08h,0ch,08h,20h

mtest:
	lxi	h,memtest - (mtest1-mtest0)
	lxi	b,0700h + 0f2h	; length of unlock sequence, GPIO port
	outir
mtest1:		; lands at 03000h - retained relocated code
	exx
	mov	h,d
	mvi	l,0
	mov	a,b
	exx
	mov	c,a
	mvi	b,2
mtest2:
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
mtest3:
	in	0edh
	ani	020h
	jrz	mtest3
	dcr	b
	jrnz	mtest2
	mvi	a,CR
	out	0e8h
	exx
	mov	a,b
mtest4:
	mov	m,a
	adi	1
	daa
	inr	l
	jrnz	mtest4
	inr	h
	dcr	c
	jrnz	mtest4
	mov	a,h
	sub	d
	mov	c,a
	mov	h,d
	mvi	l,0
	mov	a,b
mtest5:
	cmp	m
	jrnz	mtest9
	adi	1
	daa
	inr	l
	jrnz	mtest5
	inr	h
	dcr	c
	jrnz	mtest5
	exx
	lxi	h,memtest
	lxi	d,0
	lxi	b,mtestZ-mtest1
	exx
	mov	a,d
	xri	030h
	mov	d,a
	jrz	mtest6
	mov	c,e
	jr	mtest7
mtest6:
	mvi	c,030h
	mvi	a,001h
	add	b
	daa
	mov	b,a
	exx
	xchg
	exx
mtest7:
	exx
	ldir
	mov	a,d
	ani	0f0h
	mov	h,a
	mvi	l,0
	mvi	c,mtestZ-mtest1
	xra	a
mtest8:
	add	m
	inx	h
	dcr	c
	jrnz	mtest8
	mov	c,a
	exaf
	cmp	c
	jrnz	mtestE
	exaf
	mov	a,d
	ani	0f0h
	mov	h,a
	mvi	l,0
	pchl
mtest9:
	xra	m
	mov	d,a
	mvi	a,LF
	out	0e8h
mtestA:
	in	0edh
	ani	020h
	jrz	mtestA
	mvi	c,2
	mvi	b,4
mtestB:
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
mtestC:
	in	0edh
	ani	020h
	jrz	mtestC
	dad	h
	dad	h
	dad	h
	dad	h
	djnz	mtestB
	mvi	a,' '
	out	0e8h
mtestD:
	in	0edh
	ani	020h
	jrz	mtestD
	dcr	c
	xchg
	mvi	b,002h
	jrnz	mtestB
	mvi	a,'*'
	out	0e8h
	jr	mtestG
mtestE:
	in	0edh
	ani	020h
	jrz	mtestE
	mvi	a,LF
	out	0e8h
mtestF:
	in	0edh
	ani	020h
	jrz	mtestF
	mvi	a,'!'
	out	0e8h
mtestG:
	in	0edh
	ani	020h
	jrz	mtestG
	xra	a
	mvi	b,0fah
mtestH:
	dcr	a
	jrnz	mtestH
	djnz	mtestH
	mvi	a,BEL
	out	0e8h
	jr	mtestG
; End of relocated code
mtestZ	equ	$
;------------------------------------------------

; returns with interrupts disabled
h17init:
	di
	xra	a
	out	07fh
	push	d
	lxi	h,ctl$F0
	mvi	m,0d0h	; !beep, 2mS, !mon, !SI
	lxi	h,R$CONST
	lxi	d,D$CONST
	lxi	b,88
	ldir
	mov	l,e
	mov	h,d
	inx	d
	mvi	c,30
	mov	m,a
	ldir	; fill l20a0h...
	inr	a	; A=1
	lxi	h,intvec	; vector area
h17ini0:
	mvi	m,0c3h
	inx	h
	mvi	m,LOW (nulint-rst0)
	inx	h
	mvi	m,HIGH (nulint-rst0)
	inx	h
	add	a	; shift left, count 7
	jp	h17ini0
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

exboot:
	mov	a,d
	sui	200
	jrc	exboot0	; < 200
	mov	d,a	; MMS 77314 REMEX (Z47)
exboot0:
	lxi	h,devtbl
exboot1:
	mov	a,d
	sub	m
	inx	h
	cmp	m
	jrc	exboot2
	mov	a,m
	inx	h
	inx	h
	inx	h
	ora	a
	jrnz	exboot1
	ret

exboot2:	; found device, jump to handler
	inx	h
	mov	c,m
	inx	h
	mov	h,m
	mov	l,c
	add	e
	pchl

; Returns NZ if found, D=phy drv
gtdvtb:
	in	0f2h
	ani	01110000b	; default boot device
	rlc
	rlc
	rlc
	rlc
	lxi	h,defbt
gtdvtb0:
	add	l
	mov	l,a
	mvi	a,0
	adc	h
	mov	h,a
	mov	a,m
	cpi	0ffh
	rz	; no device
	cpi	0feh
	jz	gtdvtb1	; extended dipsw
	mov	d,a
	ret	; NZ

gtdvtb1:
	in	05ch
	ani	11100000b	; device
	rlc
	rlc
	rlc
	lxi	h,auxbt
	call	gtdvtb0
	rz	; no device
	in	05ch
	ani	00011100b	; LUN
	rrc
	rrc
	mov	e,a	; D=phy drv, E=LUN
	ret

; lookup letter in MMS table
mmslookup:
	lxi	h,bootb2
mmslk0:
	mov	a,m
	inx	h
	mov	d,m
	inx	h
	cmp	b
	rz
	ora	a
	jrnz	mmslk0
	mvi	d,0
	stc
	ret

; disk device/drive table by phy drv
devtbl:
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MMS 77314 Corvus boot
bm314c:
	mov	d,a
	mvi	a,10
	call	take$A
	in	058h
	ani	080h
	rnz
	mvi	b,0
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
	mvi	b,0
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
	call	cvs$dat
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
	call	cvs$read
	rc
	ldy	a,+0
	ral
	rc
	ldy	c,+0
	ldy	d,+1
	ldy	e,+2
	lxix	bootbf
	mvi	b,2	; retry count?
	call	cvs$read
	rc
	jmp	hwboot

cvs$read:
	mvi	a,012h	; read command
	call	cvs$cmd
	mov	a,c
	add	a
	add	a
	add	a
	add	a
	inr	a
	call	cvs$cmd	; command params
	mov	a,e
	call	cvs$cmd	; command params
	mov	a,d
	call	cvs$cmd	; command params
cvs$rd0:
	in	058h
	ani	002h	; done
	jrz	cvs$rd0
	mvi	a,8
cvs$rd1:
	dcr	a
	jnz	cvs$rd1
	call	cvs$dat
	rlc	; error bit
	rc
	mvi	l,128
cvs$rd2:
	call	cvs$dat
	stx	a,+0
	inxix
	dcr	l
	jrnz	cvs$rd2
	inr	e
	jrnz	cvs$rd3
	inr	d
	jrnz	cvs$rd3
	inr	c
cvs$rd3:
	djnz	cvs$read
	ora	a
	ret

; Corvus I/O
cvs$cmd:
	push	psw
cvs$cmd0:
	in	058h
	rar
	jrc	cvs$cmd0
	pop	psw
	out	059h
	ret

cvs$dat:
	in	058h
	rar
	jrc	cvs$dat
	in	059h
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MMS 77316 Floppy boot
bm316:
	lxi	h,int316
	shld	vrst6+1
	cpi	008h
	rnc
	ori	028h
	mov	d,a
	out	038h
	xra	a
	out	0f2h	; 2mS intr off
	mvi	a,00bh	; home/restore to track 0
	call	cmd316
	lxi	b,53000
bm316$0:
	in	03ch
	rlc
	jrnc	bm316$1
	dcx	b
	mov	a,b
	ora	c
	jrnz	bm316$0
bm316$1:
	in	03ch
	ani	099h
	rnz
	mvi	e,019h
bm316$2:
	lxi	h,bootbf
	xra	a
bm316$3:
	inr	a
	out	03eh
	lxi	b,003fh
	mvi	a,088h
	call	rd316
	ani	0bfh
	mov	a,d
	out	038h
	jz	bm316$4
	xri	040h
	mov	d,a
	dcr	e
	jrnz	bm316$2
	ret
bm316$4:
	in	03eh
	cpi	002h
	jrc	bm316$3
	jmp	hwboot

rd316:
	push	psw
	mov	a,d
	ani	044h
	jrnz	rd316$5
	; 8" DD read special case
	mov	a,d
	ani	0dfh
	out	038h
	pop	psw
	out	03ch
	ei
	hlt	; wait for first byte
rd316$8: ini
	jmp	rd316$8

rd316$5:
	mov	a,d
	out	038h
	pop	psw
	out	03ch
hlt$ini: ei
rd316$0: hlt
	ini
	jmp	rd316$0

cmd316:
	out	03ch
ei$spin: ei
	jr	$-1	; wait for intr to break us out

int316:	pop	psw
	in	03ch
	ei
	ret

bz37:
	lxi	h,intz37
	shld	vrst4+1
	dcx	h
	shld	l2037h
	cpi	004h
	rnc
	inr	a
	mvi	l,008h
bz37$0:
	dad	h
	dcr	a
	jrnz	bz37$0
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
	lxi	b,0147bh	; mask, port
bz37$1:
	in	07ah
	xra	b
	ani	002h
	jrz	bz37$1
	djnz	bz37$1
bz37$2:
	lxi	h,bootbf
	mvi	a,001h
	out	079h
	out	07ah
	mov	a,d
	out	078h
	mvi	b,004h
bz37$3:
	xra	a
	out	079h
	mvi	a,040h
	out	07ah
	call	ei$spin
	djnz	bz37$3
	xra	a
	out	079h
	mvi	a,00bh
	out	07ah
	call	ei$spin
	mov	a,d
	xri	004h
	mov	d,a
	ori	002h
	out	078h
	mvi	a,09ch
	out	07ah
	call	hlt$ini
	ani	0efh
	jrnz	bz37$4
	mov	a,h
	cpi	02ch
	jrc	bz37$4
	mvi	a,008h
	out	078h
	pop	h
	jmp	hwboot
bz37$4:
	dcr	e
	jrnz	bz37$2
	ret

intz37:	in	07ah
	xthl
	lhld	l2037h
	xthl
	ei
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MMS 77317 XCOM HDD boot
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
bm317$0:
	mov	a,m
	ora	a
	jrz	bm317$3
	inx	h
	mov	b,a
	ral
	jrc	bm317$1
	outir
	jr	bm317$0
bm317$1:
	ora	a
	rar
	mov	b,a
	mov	a,m
	inx	h
bm317$2:
	out	04eh
	djnz	bm317$2
	jr	bm317$0
; done with OUT "program"
bm317$3:
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
	jmp	hwboot

s0af4h:
	mvi	d,00ah
	mvi	a,004h
	out	04ch
	mvi	a,0eah
	out	04dh
	mvi	b,4
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
	mvi	b,0
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
	mvi	b,128
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MMS 77320 SASI HDD boot
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
	mvi	c,10b
	call	getport
	rnz
	mov	a,b
	sta	cport
	inr	a
	mov	c,a
	xra	a
	outp	a
	lxi	h,0		; zero-out command buffer
	shld	cmdbuf
	shld	cmdbuf+2
	shld	cmdbuf+4
	shld	l2156h	; zero-out ...
	shld	l2156h+2
	sta	l2156h+4
	mov	d,e
	mvi	a,4	; delay 8mS, also NZ
	ora	a
	ei
bsasi0:
	rz
	call	delayx
	mvi	e,0	; Test Drive Ready
	call	sasi$cmd
	mvi	a,255	; longer delay on retry...
	jrc	bsasi0
	mvi	e,1	; Recalibrate (Home)
	call	sasi$cmd
	rc
	lxi	h,0800ah	; 10 sectors, retry
	shld	cmdbuf+4
	mvi	e,8	; Read
	call	sasi$cmd
	rc
	pop	h
	jmp	hwboot

; send SASI read command, get results
sasi$cmd:
	di
	db 0ddh	; undocumented Z80 instruction
	mov l,e	; movxl	e	; SASI command
	sixd	cmdbuf
	mvi	b,0	; wait for "not BUSY" first
	mvi	e,6	;
	lxi	h,0	; 0x060000 loop/timeout count
sscmd0:
	inp	a
	ani	00001000b
	cmp	b
	jrz	sscmd1
	dcx	h
	mov	a,l
	ora	h
	jrnz	sscmd0
	dcr	e
	jrnz	sscmd0
	stc
	ret
sscmd1:
	mov	a,b
	xri	00001000b	; wait for BUSY
	jrz	sscmd2		; got BUSY...
	mov	b,a
	dcr	c
	xra	a
	outp	a
	inr	c
	inr	c
	outp	d
	dcr	c
	mvi	a,040h	; SELECT
	outp	a
	jr	sscmd0	; wait for BUSY now...

sscmd2:
	mvi	a,002h	; enable INTR
	outp	a
	lxi	h,cmdbuf
sscmd3:
	inp	a
	bit	7,a	; REQ
	jrz	sscmd3
	bit	4,a	; CMD
	jrz	sscmd4
	bit	6,a	; MSG
	jrz	sscmd6
	dcr	c
	outi		; output command byte
	inr	c
	jr	sscmd3

sscmd4:
	lxi	h,bootbf
sscmd5:
	inp	a
	bit	7,a	; REQ
	jrz	sscmd5
	bit	4,a	; CMD - indicates data done
	jrnz	sscmd6
	dcr	c
	ini		; input data byte
	inr	c
	jr	sscmd5
sscmd6:
	inp	a
	ani	0d0h	; REQ, OUT, CMD
	cpi	090h	; must be REQ, CMD
	jrnz	sscmd6	; wait for it...
	dcr	c
	inp	l	; result 0
	inr	c
sscmd7:
	inp	h	; status
	mov	a,h
	ani	0e0h	; REG, OUT, MSG
	cpi	0a0h	; must be REQ, MSG
	jrnz	sscmd7
	shld	resbuf	; command results
	dcr	c
	inp	a	; last data byte
	inr	c
	ei
	ora	a
	stc
	rnz		; error
	bit	0,l	; SASI error bit
	rnz
	bit	1,l	; or other error?
	rnz
	bit	1,h	; ACK
	rnz
	xra	a	; success
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MMS 77314 REMEX boot
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
	call	rmxout
	mov	a,d
	call	rmxout
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
	jmp	hwboot

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
	jmp	hwboot

rmxout:
	push	psw
rmxout0:
	in	05bh
	ani	060h
	jrnz	rmxout0
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
	mvix	020h,+0 ; Boot code = 20
	stx	e,+4	; Unit number (server)
	mvix	1,+1	; BC=0001, length
	mvix	0,+2	;
	mvix	1,+7	; device code, Z89
	mvi	c,11b
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
	mvi	a,038h	; 38 = send status
	call	get422
	ldx	a,+3	; error code
	ora	a
	rnz	 ; abort if error
bm422$2:
	mvi	a,011h	; 1x = Boot response
	call	get422
	ldx	l,+5	; Code address
	ldx	h,+6	;
	push	h	; return address, code entry
	ldx	e,+1	; Code length
	ldx	d,+2	;
	mov	a,e
	ora	d
	cnz	rcv422	; get code, if any
	ldx	a,+0
	cpi	13h	; load only - no execute
	rnz		; jump to code
	pop	h	; discard unused addr
	jmp	bm422$2	; keep receiving until execute

; Wait for network message type in A,
; must watch for stray CP/NET messages and discard
get422:
	push	psw
get422$0:
	lxi	h,bootbf
	lxi	d,7
	call	rcv422
	ldx	a,+0
	ani	11111001b
	pop	b
	cmp	b
	rz	; got desired message type
	push	b
	cpi	000h	; CP/Net message
	jrnz	get422$0
	lxi	h,bootbf	; Receive and discard...
	ldx	e,+1
	ldx	d,+2
	call	rcv422
	jmp	get422$0

; Gobble data until we reach a sync point
syn422:
	lxi	d,0		; delay count
	lxi	h,nowhere
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

nowhere: db	0,0,0

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
vers:	db	VERN	; version byte... "1.0"

erprom:	db	CR,LF,BEL,'EPROM err',TRM

	rept	1000h-$-4
	db	0ffh
	endm
romend:
	dw	0
chksum:
	dw	089f3h	; checksum...

if	($ != 1000h)
	.error "i2732 ROM overrun"
endif
	end
