; Z89/Z90 Monitor EPROM 444-84B, by Magnolia Microsystems
; Z89/Z90/H8-Z80 Monitor EPROM 444-84D, June 29, 2019, drm
VERN	equ	13h	; version 1.3

	maclib	z80
	$*macro

CR	equ	13
LF	equ	10
BEL	equ	7
ESC	equ	27
TRM	equ	0
DEL	equ	127

GIDE$DA	equ	060h	; GIDE data port
GIDE$ER	equ	061h	; GIDE error register
GIDE$SC	equ	062h	; GIDE sector count
GIDE$SE	equ	063h	; GIDE sector number
GIDE$CL	equ	064h	; GIDE cylinder low
GIDE$CH	equ	065h	; GIDE cylinder high
GIDE$DH	equ	066h	; GIDE drive/head
GIDE$CS	equ	067h	; GIDE command/status

; WIZNET/NVRAM (SPI adapter) defines
spi	equ	40h	; base port
spi$dat	equ	spi+0
spi$ctl	equ	spi+1	; must be spi$dat+1
spi$sta	equ	spi+1

WZSCS	equ	01b	; /SCS for WIZNET
NVSCS	equ	10b	; /SCS for NVRAM

; NVRAM constants
; NVRAM/SEEPROM commands
NVRD	equ	00000011b
NVWR	equ	00000010b
RDSR	equ	00000101b
WREN	equ	00000110b
; NVRAM/SEEPROM status bits
WIP	equ	00000001b

; WIZNET constants
nsocks	equ	8
sock0	equ	000$01$000b	; base pattern for Sn_ regs
txbuf0	equ	000$10$100b	; base pattern for Tx buffer
rxbuf0	equ	000$11$000b	; base pattern for Rx buffer

; common regs
gar	equ	1
subr	equ	5
shar	equ	9
sipr	equ	15
ir	equ	21
sir	equ	23
pmagic	equ	29

; socket regs, relative
sn$mr	equ	0
sn$cr	equ	1
sn$ir	equ	2
sn$sr	equ	3
sn$prt	equ	4
sn$dipr	equ	12
sn$dprt	equ	16
sn$txwr	equ	36
sn$rxrsr equ	38
sn$rxrd	equ	40

; socket commands
OPEN	equ	01h
CONNECT	equ	04h
SEND	equ	20h
RECV	equ	40h

; socket status
SOKINIT	equ	13h
ESTABLISHED equ	17h

	org	2280h
server:	ds	1	; SID, dest of send
nodeid:	ds	1	; our node id
cursok:	ds	1	; current socket select patn
curptr:	ds	2	; into chip mem
msgptr:	ds	2
msglen:	ds	2
totlen:	ds	2
dma:	ds	2

	org	2300h
msgbuf:	ds	0
msg$fmt: ds	1
msg$did: ds	1
msg$sid: ds	1
msg$fnc: ds	1
msg$siz: ds	1
msg$dat: ds	128

	org	2400h
nvbuf:	ds	512

; Legacy devices and defines

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
l2156h:	ds	6	; cmdbuf for SASI, segoff for GIDE
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
if ((high int1$cont) <> 0)
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
if	($ <> 0066h)
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
	jmp	error	; fatal error... not defined

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
; C = desired port pattern, 00=Z17/Z37, 01=Z47, 10=Z67, 11=undefined
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
btdig:	; boot by phys drive number, E=0
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

gotnum:	; Boot N... "N" in D
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
	mvi	a,0c3h
	sta	bootbf	; mark "no string"
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
nodig:	; boot by letter... Boot alpha-
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
	mov	e,a	; single digit (0..9)
luboot1:
	call	conin
	cmp	c
	jrz	goboot
	cpi	':'	; Boot alpha-dig:str
	jrz	colon
	cpi	' '	; cosmetic spaces?
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
	mov	a,b
	sta	bootbf	; bootbf: <len> <string...> as in CP/M cmd buf
	xra	a	; TRM - string terminator
btstr1:	; use stack as char array...
	push	psw
	inx	sp	; undo half of push
	dcx	h
	mov	a,m
	djnz	btstr1
; D=Phys Drive base number, E=Unit number
; (or, D=Phys Drive unit, E=0)
goboot:
	call	crlf
goboot0:
	lxi	h,error
	push	h
	call	h17init
	mov	a,e
	sta	AIO$UNI	; relative unit num
	add	d
	sta	l2034h	; boot phys drv unit num
	mov	a,d
	cpi	3	; 0,1,2
	jrc	bz17	; Z17 boot
	; 3,4 not used?
	sui	5
	cpi	4	; 5,6,7,8
	jrc	bz47	; Z47 boot
	jmp	exboot	;

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
	mvi	a,00001111b	; all outputs ON
	out	0ech		; OUT2=1 hides 16C2550 intr enable diff
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

unsupm:	db	'Unsupp CPU speed',TRM

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
	jr	conout

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
	jr	conout

; Special entry points expected by HDOS, or maybe Heath CP/M boot.
	rept	0613h-$
	db	0
	endm
if	($ <> 0613h)
	.error "HDOS entry overrun 0613h"
endif
	jmp	z47$dato ; Must be at 0613
	db	0
	jmp	z47$cmdo ; Must be at 0617

; Heath/Zenith device boot table
bootb1:
	db	'B',0	; Z17
	db	'C',46	; Z37
	db	'D',5	; Z47
	db	'E',3	; Z67
	db	0

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
	cpi	'R'	; set baud Rate
	jz	setbr
	cpi	'V'	; eprom Version
	jz	prtver
	ret

; D=Phys Drive base, E=Unit
; (or D=Phys Drive unit, E=0)
exboot:
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
	db	29,8
	dw	bm316
	db	40,1
	dw	bm318
	db	46,4
	dw	bz37
	db	60,1
	dw	bwiznet
	db	70,9
	dw	bgide
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
	db	70	; -101---- GIDE disk part 0
	db	60	; -110---- WIZNET Network
	db	0feh	; -111---- redirect to I/O board dipsw

auxbt:	; default boot redirect (aux dipsw) bits 11100000b
	db	0ffh	; 000----- none (was MMS 77314 Corvus)
	db	0ffh	; 001----- none (was MMS 77314 REMEX (Z47))
	db	0ffh	; 010----- none
	db	37	; 011----- MMS 77317 XCOMP
	db	60	; 100----- WIZNET Network
	db	168	; 101----- MMS 77320 SASI
	db	70	; 110----- GIDE disk
	db	0ffh	; 111----- none

bootb2:
	db	'I',29		; MMS 77316 8"
	db	'J',33		; MMS 77316 5"
	db	'M',40		; MMS 77318 RAM-disk
	db	'O',168		; SASI ctrl 0
	db	'P',172		; SASI ctrl 1
	db	'Q',176		; SASI ctrl 2
	db	'R',180		; SASI ctrl 3
	db	'S',184		; SASI ctrl 4
	db	'T',188		; SASI ctrl 5
	db	'U',192		; SASI ctrl 6
	db	'V',196		; SASI ctrl 7
	db	'W',60		; WIZNET Network
	db	'X',70		; GIDE ctrl/disk
	db	0

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
; GIDE HDD boot
bgide:
	cpi	9 ; 9 partitons, max
	rnc
	; Partition is passed to bootloader, but we need
	; segment offset before we can start.
	pop	d	; error return address
	pop	b	; possible string
	push	b
	push	d
	; parse a single letter
	lxi	h,0	; def segment off
	mov	a,c
	cpi	0c3h	; JMP means no string present
	jrz	nostr
	mov	a,b
	ora	a	; limit to 1 char?
	rnz
	mov	a,c
	ani	5fh
	sui	'A'	; 000sssss = segment ID
	rc
	rlc
	rlc
	rlc		; sssss000 = segoff: 0000 sssss000 00000000 00000000
	mov	h,a	; swap for little endian SHLD/LHLD
nostr:	shld	l2156h	; l2156h[0]=27:24, l2156h[1]=23:16
	mov	a,l
	ori	11100000b	; LBA mode + std "1" bits
	out	GIDE$DH	; LBA 27:4, drive 0, LBA mode
	mov	a,h
	out	GIDE$CH	; LBA 23:16
	xra	a
	out	GIDE$CL	; LBA 15:8
	out	GIDE$SE	; LBA 7:0
	mvi	a,10
	out	GIDE$SC	; 10 sectors (standard boot length)
	mvi	a,20h	; READ SECTORS
	out	GIDE$CS
	lxi	h,bootbf
	mvi	c,GIDE$DA
	mvi	e,10
	mvi	b,0	; should always be 0 after inir
bgide0:
	in	GIDE$CS
	bit	7,a	; busy
	jrnz	bgide0
	bit	0,a	; error
	rnz
	bit	6,a	; ready
	rz
	bit	3,a	; DRQ
	jrz	bgide0
	inir	; 256 bytes
	inir	; 512 bytes
	dcr	e
	jrnz	bgide0
	; final status check?
	pop	h	; adj stack for possible string
	jmp	hwboot

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
; WIZNET WIZ850io (Network) boot loader

getwiz1:
	mvi	a,WZSCS
	out	spi$ctl
	mvi	c,spi$dat
	outz	; hi adr byte always 0
	outp	e
	res	2,d
	outp	d
	inz	; prime MISO
	inp	a
	inr	c	; ctl port
	outz		; clear SCS
	ret

putwiz1:
	push	psw
	mvi	a,WZSCS
	out	spi$ctl
	pop	psw
	mvi	c,spi$dat
	outz	; hi adr byte always 0
	outp	e
	setb	2,d
	outp	d
	outp	a	; data
	inr	c	; ctl port
	outz		; clear SCS
	ret

; Get 16-bit value from chip
; Prereq: IDM_AR0 already set, auto-incr on
; Entry: A=value for IDM_AR1
; Return: HL=register pair contents
getwiz2:
	mvi	a,WZSCS
	out	spi$ctl
	mvi	c,spi$dat
	outz	; hi adr byte always 0
	outp	e
	res	2,d
	outp	d
	inz	; prime MISO
	inp	h	; data
	inp	l	; data
	inr	c	; ctl port
	outz		; clear SCS
	ret

; HL = output data, E = off, D = BSB, B = len
wizset:
	mvi	a,WZSCS
	out	spi$ctl
	mvi	c,spi$dat
	outz		; hi adr always 0
	outp	e
	setb	2,d
	outp	d
	outir
	inr	c	; ctl port
	outz		; clear SCS
	ret

; Put 16-bit value to chip
; Prereq: IDM_AR0 already set, auto-incr on
; Entry: A=value for IDM_AR1
;        HL=register pair contents
putwiz2:
	mvi	a,WZSCS
	out	spi$ctl
	mvi	c,spi$dat
	outz	; hi adr byte always 0
	outp	e
	setb	2,d
	outp	d
	outp	h	; data to write
	outp	l
	inr	c	; ctl port
	outz		; clear SCS
	ret

; Issue command, wait for complete
; D=Socket ctl byte
; Returns: A=Sn_SR
wizcmd:	mov	b,a
	mvi	e,sn$cr
	setb	2,d
	mvi	a,WZSCS
	out	spi$ctl
	mvi	c,spi$dat
	outz	; hi adr byte always 0
	outp	e
	outp	d
	outp	b	; command
	inr	c	; ctl port
	outz		; clear SCS
wc0:	call	getwiz1
	ora	a
	jrnz	wc0
	mvi	e,sn$sr
	call	getwiz1
	ret

; HL=socket relative pointer (TX_WR)
; DE=length (preserved, not used)
; Returns: HL=msgptr, C=spi$dat
cpsetup:
	mvi	a,WZSCS
	out	spi$ctl
	mvi	c,spi$dat
	outp	h
	outp	l
	lda	cursok
	ora	b
	outp	a
	lhld	msgptr
	ret

; length always <= 133 bytes, never overflows OUTIR/INIR
cpyout:
	mvi	b,txbuf0
	call	cpsetup
	mov	b,e	; length
	outir		; send data
	shld	msgptr
	inr	c	; ctl port
	outz		; clear SCS
	ret

; HL=socket relative pointer (RX_RD)
; DE=length
; Destroys IDM_AR0, IDM_AR1
; length always <= 133 bytes, never overflows OUTIR/INIR
cpyin:
	mvi	b,rxbuf0
	call	cpsetup	;
	inz	; prime MISO
	mov	b,e	; fraction of page
	inir		; recv data
	shld	msgptr
	inr	c	; ctl port
	outz		; clear SCS
	ret

; L=bits to reset
; D=socket base
wizsts:
	mvi	e,sn$ir
	call	getwiz1	; destroys C
	push	psw
	ana	l
	jrz	ws0	; don't reset if not set (could race)
	mov	a,l
	call	putwiz1
ws0:	pop	psw
	ret

;	WIZNET boot routine
;
bwiznet:
	push	d
	; extract optional string. must do it now, before we
	; overwrite bootbf.
	lxi	h,bootbf
	mov	a,m
	mov	c,a
	; we send N+1 bytes, NUL term
	sta	msg$siz
	mvi	b,0
	lxi	d,msg$dat
	ldir
	xra	a
	stax	d	; NUL term
	pop	d
	mov	a,e	; server id, 0..9
	sta	server
	; look at WIZNET hard, init as needed
	lxi	d,pmagic	; D = 0 (comm regs), E = PMAGIC offset
	call	getwiz1
	ora	a
	cz	wizcfg	; configure chip from nvram
	rc
	sta	nodeid ; our slave (client) ID
	; locate server node id in chip's socket regs.
	;
	mvi	b,nsocks
	lxi	d,(sock0 shl 8) + sn$prt
nb1:
	call	getwiz2	; destroys C,HL
	mov	a,h
	cpi	31h
	jrnz	nb0
	lda	server
	cmp	l
	jrz	nb2	; found server socket
nb0:
	mvi	a,001$00$000b
	add	d	; next socket
	mov	d,a
	djnz	nb1
	ret	; error: server not configured
nb2:	; D = server socket BSB
	mov	a,d
	ani	11100000b
	sta	cursok
	mvi	e,sn$sr
	call	getwiz1
	cpi	ESTABLISHED
	jrz	nb3	; ready to rock-n-roll...
	; try to open...
	cpi	SOKINIT
	jrz	nb4
	mvi	a,OPEN
	call	wizcmd
	cpi	SOKINIT
	rnz	; failed to open (init)
nb4:	mvi	a,CONNECT
	call	wizcmd
	cpi	ESTABLISHED
	rnz	; failed to open (connect)
nb3:
	mvi	a,1	; FNC for "boot me"
	sta	msg$fnc
	; string already setup
loop:
	mvi	a,020h	; FMT for client boot messages
	sta	msg$fmt
	call	sndrcv
	rc	; network failure
	lda	msg$fmt
	cpi	021h	; FMT for server boot responses
	rnz
	; TODO: verify SID?
	lda	msg$fnc
	ora	a
	rz	; NAK - error
	dcr	a
	jrz	ldmsg
	dcr	a
	jrz	stdma
	dcr	a
	jrz	load
	dcr	a
	rnz	; unsupported FNC
	; done: execute boot code
	; TODO: enable ORG0 (MMS77318?)
	lhld	msg$dat
	pchl
load:	lhld	dma
	xchg
	lxi	h,msg$dat
	lxi	b,128
	ldir
ack:	xra	a	; FNC 0 = ACK
	sta	msg$fnc
	jr	loop
stdma:	lhld	msg$dat
	shld	dma
	jr	ack
ldmsg:	lxi	h,msg$dat
ldm0:	mov	a,m
	inx	h
	cpi	'$'
	jrz	ack
	call	conout
	jr	ldm0

; Wait for message response, with timeout.
; D = socket BSB (preserved).
check:
	lxi	h,32000	; do check for sane receive time...
chk0:	push	h
	mvi	l,00000100b	; RECV data available bit
	call	wizsts
	ana	l	; RECV data available
	jrnz	chk4	; D=socket
	pop	h
	dcx	h
	mov	a,h
	ora	l
	jrnz	chk0
	stc	; CY = error
	ret
chk4:	pop	h
	ret

;	Send Message on Network, receive response
;	msgbuf setup with FMT, FNC, LEN, data
;	msg len always <= 128 (133 total) bytes.
sndrcv:			; BC = message addr
	; TODO: drain/flush receiver
; begin send phase
	lxi	h,msgbuf
	shld	msgptr
	lda	cursok
	ori	sock0
	mov	d,a
	; D=socket patn
	lda	server
	sta	msg$did	; Set Server ID (dest) in header
	lda	nodeid
	sta	msg$sid	; Set Slave ID (src) in header
	lda	msg$siz	; msg siz (-1)
	adi	5+1	; hdr, +1 for (-1)
	mov	l,a
	mvi	h,0
	shld	msglen
	mvi	e,sn$txwr
	call	getwiz2
	shld	curptr
	lhld	msglen
	lbcd	curptr
	dad	b
	mvi	e,sn$txwr
	call	putwiz2
	; send data
	lhld	msglen
	xchg
	lhld	curptr
	call	cpyout
	lda	cursok
	ori	sock0
	mov	d,a
	mvi	a,SEND
	call	wizcmd
	; ignore Sn_SR?
	mvi	l,00010000b	; SEND_OK bit
	call	wizsts
	cma	; want "0" on success
	ana	l	; SEND_OK
	stc
	rnz	; CY = failure (here: send failed)
; begin recv phase - loop
	lda	cursok	; is D still socket BSB?
	ori	sock0
	mov	d,a
;	Receive Message from Network
	lxi	h,msgbuf
	shld	msgptr
	call	check	; check for recv within timeout
	jrc	rerr
	lxi	h,0
	shld	totlen
rm0:	; D must be socket base...
	mvi	e,sn$rxrsr	; length
	call	getwiz2
	mov	a,h
	ora	l
	jrz	rm0
	shld	msglen		; not CP/NET msg len
	mvi	e,sn$rxrd	; pointer
	call	getwiz2
	shld	curptr
	lbcd	msglen	; BC=Sn_RX_RSR
	lhld	totlen
	ora	a
	dsbc	b
	shld	totlen	; might be negative...
	lbcd	curptr
	lhld	msglen	; BC=Sn_RX_RD, HL=Sn_RX_RSR
	dad	b	; HL=nxt RD
	mvi	e,sn$rxrd
	call	putwiz2
	; DE destroyed...
	lded	msglen
	lhld	curptr
	call	cpyin
	lda	cursok
	ori	sock0
	mov	d,a
	mvi	a,RECV
	call	wizcmd
	; ignore Sn_SR?
	lhld	totlen	; might be neg (first pass)
	mov	a,h
	ora	a
	jp	rm1
	; can we guarantee at least msg hdr?
	lda	msg$siz	; msg siz (-1)
	adi	5+1	; header, +1 for (-1)
	mov	e,a
	mvi	a,0
	adc	a
	mov	d,a	; true msg len
	dad	d	; subtract what we already have
	jrnc	rerr	; something is wrong, if still neg
	shld	totlen
	mov	a,h
rm1:	ora	l
	jnz	rm0
	ret	; success (A=0)

rerr:
err:	xra	a
	dcr	a	; NZ
	ret

; Try to read NVRAM config for WIZNET.
; Returns: A = node id (PMAGIC) or CY if error (no config)
wizcfg:	; restore config from NVRAM
	lxi	h,0
	lxi	d,512
	call	nvget
	call	vcksum
	stc
	rnz	; checksum wrong - no config available
	lxi	h,nvbuf+gar
	mvi	d,0
	mvi	e,gar
	mvi	b,18	; GAR+SUBR+SHAR+SIPR
	call	wizset
	lxi	h,nvbuf+pmagic
	mvi	d,0
	mvi	e,pmagic
	mvi	b,1
	call	wizset
	lxix	nvbuf+32	; start of socket0 data
	mvi	d,SOCK0
	mvi	b,8
rest0:
	push	b
	ldx	a,sn$prt
	cpi	31h
	jrnz	rest1	; skip unconfigured sockets
	mvi	e,sn$prt
	mvi	b,2
	call	setsok
	mvi	e,sn$dipr
	mvi	b,6	; DIPR and DPORT
	call	setsok
rest1:
	lxi	b,32
	dadx	b
	mvi	a,001$00$000b	; socket BSB incr value
	add	d
	mov	d,a
	pop	b
	djnz	rest0
	lda	nvbuf+pmagic	; our node id
	ora	a	; NC
	ret

; IX = base data buffer for socket, D = socket BSB, E = offset, B = length
; destroys HL, B, C
setsok:
	pushix
	pop	h
	push	d
	mvi	d,0
	dad	d	; HL points to data in 'buf'
	pop	d
	call	wizset
	ret

; Set socket MR to TCP.
; D = socket BSB (result of "getsokn")
; Destroys all registers except D.
settcp:
	mvi	a,1	; TCP mode
	mvi	e,sn$mr
	jmp	putwiz1	; force TCP/IP mode

cksum32:
	lxi	h,0
	lxi	d,0
cks0:	ldx	a,+0
	inxix
	add	e
	mov	e,a
	jrnc	cks1
	inr	d
	jrnz	cks1
	inr	l
	jrnz	cks1
	inr	h
cks1:	dcx	b
	mov	a,b
	ora	c
	jrnz	cks0
	ret

; Validates checksum in 'buf'
; return: NZ on error
vcksum:
	lxix	nvbuf
	lxi	b,508
	call	cksum32
	lbcd	nvbuf+510
	ora	a
	dsbc	b
	rnz
	lbcd	nvbuf+508
	xchg
	dsbc	b	; CY is clear
	ret

; Get a block of data from NVRAM to 'buf'
; HL = nvram address, DE = length (always multiple of 256)
nvget:
	mvi	a,NVSCS
	out	spi$ctl
	mvi	a,NVRD
	out	spi$dat
	mov	a,h
	out	spi$dat
	mov	a,l
	out	spi$dat
	in	spi$dat	; prime pump
	mvi	c,spi$dat
	lxi	h,nvbuf
	mov	b,e
nvget0:	inir	; B = 0 after
	dcr	d
	jrnz	nvget0
	xra	a	; not SCS
	out	spi$ctl
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set BAUD command
setber:
	mvi	a,BEL
	call	conout
	pop	h
	ret

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
	dw	063fch	; checksum...

if	($ <> 1000h)
	.error "i2732 ROM overrun"
endif
	end
