; Boot Module for WizNet
	maclib	ram
	maclib	core
	maclib	z80

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
sn$resv8 equ	29	; reserved
sn$txwr	equ	36
sn$rxrsr equ	38
sn$rxrd	equ	40
sn$kpalvtr equ	47

NvKPALVTR equ	sn$resv8 ; place to stash keep-alive in nvram

; socket commands
OPEN	equ	01h
CONNECT	equ	04h
DISC	equ	08h
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

	org	1000h
first:	db	HIGH (last-first)	; +0: num pages
	db	HIGH first		; +1: ORG page
	db	60,1	; +2,+3: phy drv base, num

	jmp	init	; +4: init entry
	jmp	boot	; +7: boot entry

	db	'W'	; +10: Boot command letter
	db	5	; +11: front panel key
	db	40h	; +12: port, 0 if variable
	db	10010001b,10001100b,10011101b	; +13: FP display ("NET")
	db	'WizNet',0	; +16: mnemonic string

init:
	pushix
	mvi	a,0c3h
	lxi	h,wizsr
	sta	sndrcv
	shld	sndrcv+1
	lxi	h,wizopn
	sta	wizopen
	shld	wizopen+1
	lxi	h,wizcls
	shld	wizclose	; not a jump
	call	wizcfg	; configure chip from nvram
	popix
	rc
	sta	nodeid ; our slave (client) ID
	xra	a	; NC
	ret

getwiz1:
	mvi	a,WZSCS
	out	spi$ctl
	mvi	c,spi$dat
	xra	a
	outp	a	; hi adr always 0
	outp	e
	res	2,d
	outp	d
	inp	a	; prime MISO
	inp	a
	push	psw
	inr	c	; ctl port
	xra	a
	outp	a	; clear SCS
	pop	psw
	ret

putwiz1:
	push	psw
	mvi	a,WZSCS
	out	spi$ctl
	mvi	c,spi$dat
	xra	a
	outp	a	; hi adr always 0
	outp	e
	setb	2,d
	outp	d
	pop	psw
	outp	a	; data
	inr	c	; ctl port
	xra	a
	outp	a	; clear SCS
	ret

; Get 16-bit value from chip
; Prereq: IDM_AR0 already set, auto-incr on
; Entry: A=value for IDM_AR1
; Return: HL=register pair contents
getwiz2:
	mvi	a,WZSCS
	out	spi$ctl
	mvi	c,spi$dat
	xra	a
	outp	a	; hi adr always 0
	outp	e
	res	2,d
	outp	d
	inp	a	; prime MISO
	inp	h	; data
	inp	l	; data
	inr	c	; ctl port
	xra	a
	outp	a	; clear SCS
	ret

; HL = output data, E = off, D = BSB, B = len
wizset:
	mvi	a,WZSCS
	out	spi$ctl
	mvi	c,spi$dat
	xra	a
	outp	a	; hi adr always 0
	outp	e
	setb	2,d
	outp	d
	outir
	inr	c	; ctl port
	xra	a
	outp	a	; clear SCS
	ret

; Put 16-bit value to chip
; Prereq: IDM_AR0 already set, auto-incr on
; Entry: A=value for IDM_AR1
;        HL=register pair contents
putwiz2:
	mvi	a,WZSCS
	out	spi$ctl
	mvi	c,spi$dat
	xra	a
	outp	a	; hi adr always 0
	outp	e
	setb	2,d
	outp	d
	outp	h	; data to write
	outp	l
	inr	c	; ctl port
	xra	a
	outp	a	; clear SCS
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
	xra	a
	outp	a	; hi adr always 0
	outp	e
	outp	d
	outp	b	; command
	inr	c	; ctl port
	xra	a
	outp	a	; clear SCS
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
	xra	a
	outp	a	; clear SCS
	ret

; HL=socket relative pointer (RX_RD)
; DE=length
; Destroys IDM_AR0, IDM_AR1
; length always <= 133 bytes, never overflows OUTIR/INIR
cpyin:
	mvi	b,rxbuf0
	call	cpsetup	;
	inp	a	; prime MISO
	mov	b,e	; fraction of page
	inir		; recv data
	shld	msgptr
	inr	c	; ctl port
	xra	a
	outp	a	; clear SCS
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

; D=socket BSB, C=bits to check
; Return: A=status reg
wizist:	lxi	h,32000
wst0:	push	b	; C has status bits to check
	push	h
	mov	l,c
	call	wizsts
	pop	h
	pop	b
	mov	b,a
	ana	c
	jrnz	wst1
	dcx	h
	mov	a,h
	ora	l
	jrnz	wst0
	stc
	ret
wst1:	mov	a,b
	ret

;	WIZNET boot routine
;
boot:
	; extract optional string. must do it now, before we
	; overwrite bootbf.
	lxi	d,msg$dat	; target for string
	lxi	h,bootbf
	xra	a
	sta	msg$siz
	mov	a,m
	cpi	0c3h	; no string
	jrz	nb5
	inr	a	; include len byte
	mov	c,a
	; we send N+1 bytes, NUL term
	sta	msg$siz
	mvi	b,0
	ldir
nb5:	xra	a
	stax	d	; NUL term
	lda	AIO$UNI	; server id, 0..9
	sta	server
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
	call	wizopn
	rc	; any error
	mvi	a,1	; FNC for "boot me"
	sta	msg$fnc
	; string already setup
loop:
	mvi	a,0b0h	; FMT for client boot messages
	sta	msg$fmt
	call	wizsr
	rc	; network failure
	lda	msg$fmt
	cpi	0b1h	; FMT for server boot responses
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
	call	wizcls
	lhld	msg$dat
	pchl
load:	lhld	dma
	xchg
	lxi	h,msg$dat
	lxi	b,128
	ldir
	xchg
	shld	dma
ack:	xra	a	; FNC 0 = ACK
	sta	msg$fnc
	sta	msg$siz
	jr	loop
stdma:	lhld	msg$dat
	shld	dma
	jr	ack
ldmsg:	call	crlf
	lxi	h,msg$dat
ldm0:	mov	a,m
	inx	h
	cpi	'$'
	jrz	ack
	call	chrout
	jr	ldm0

; must preserve HL
chrout:	liyd	conout
	pciy

; D = server socket BSB
wizopn:
	mvi	e,sn$sr
	call	getwiz1
	cpi	ESTABLISHED
	rz	; ready to rock-n-roll...
	; try to open...
	cpi	SOKINIT
	jrz	nb4
	mvi	a,OPEN
	call	wizcmd
	cpi	SOKINIT
	stc
	rnz	; failed to open (init)
nb4:	mvi	e,sn$ir	; ensure no lingering bits...
	mvi	a,00011111b
	call	putwiz1
	mvi	a,CONNECT
	call	wizcmd
	mvi	c,00001011b	; CON, DISCON, or TIMEOUT
	call	wizist	; returns when one is set, or CY
	rc
	ani	00000001b	; need CON
	sui	00000001b	; CY if bit is 0
	ret

wizcls:
	lda	cursok
	ori	sock0
	mov	d,a
	mvi	a,DISC
	call	wizcmd
	mvi	c,00001010b	; DISCON, or TIMEOUT
	call	wizist	; returns when one is set, or CY
	ret	; don't care which result?

;	Send Message on Network, receive response
;	msgbuf setup with FMT, FNC, LEN, data
;	msg len always <= 128 (133 total) bytes.
wizsr:			; BC = message addr
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
	mvi	c,00011010b	; SEND_OK bit, TIMEOUT, DISConnect
	call	wizist
	rc
	ani	00010000b	; SEND_OK
	stc
	rz
; begin recv phase - loop
	lda	cursok	; is D still socket BSB?
	ori	sock0
	mov	d,a
;	Receive Message from Network
	lxi	h,msgbuf
	shld	msgptr
	mvi	c,00000110b	; RECV, DISC
	call	wizist	; check for recv within timeout
	jrc	rerr
	ani	00000100b	; RECV
	jrz	rerr
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
	jrnz	rm0
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
	lda	nvbuf+pmagic
	mvi	e,pmagic
	call	putwiz1
	lxix	nvbuf+32	; start of socket0 data
	mvi	d,SOCK0
	mvi	b,8
rest0:
	push	b
	ldx	a,sn$prt
	cpi	31h
	jrnz	rest1	; skip unconfigured sockets
	mvi	a,1	; TCP mode
	mvi	e,sn$mr
	call	putwiz1	; force TCP/IP mode
	ldx	a,NvKPALVTR
	mvi	e,sn$kpalvtr
	ora	a
	cnz	putwiz1
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
	mov	a,b	;
	ora	c	; check first half zero
	dsbc	b
	rnz
	lbcd	nvbuf+508
	ora	b	;
	ora	c	; check second half zero
	xchg
	dsbc	b
	rnz
	ora	a	; was checksum all zero?
	jrz	vcksm0
	xra	a	; ZR
	ret
vcksm0:	inr	a	; NZ
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

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm
if ($ > 1800h)
	.error	'Module overflow'
endif

last:	end
