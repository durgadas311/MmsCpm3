; A config util for WizNET 550 devices, attached in parallel-SPI interface
; Sets config into NVRAM, unless 'w' option prefix to set to WIZ850io directly.
; interactive stand-alone version.
VERN	equ	01h

	extrn	wizcfg,wizcfg0,wizcmd,wizget,wizset,wizclose,setsok,settcp
	extrn	gkeep,skeep
	extrn	cksum32,vcksum,scksum,nvget

	public	nvbuf	; for wizcfg routine

	maclib	z80

CR	equ	13
LF	equ	10
TAB	equ	9
BS	equ	8
BEL	equ	7
CTLC	equ	3

	cseg

	jmp	start

	dseg
idmsg:	db	'Node ID:  ',0
gwmsg:	db	'Gateway:  ',0
ntmsg:	db	'Subnet:   ',0
mcmsg:	db	'MAC:      ',0
ipmsg:	db	'IP Addr:  ',0
sock:	db	'Socket '
sokn:	db	       '_: ',0

quest3:	db	TAB
quest2:	db	TAB
quest:	db	TAB,'? ',0

usage:	db	'WIZCFG v'
	db	(VERN SHR 4)+'0','.',(VERN AND 0fh)+'0'
	db	CR,LF,0

done:	db	'Set',CR,LF,0
ncfg:	db	'Not Configured',TAB,0
nverr:	db	'NVRAM block not initialized',CR,LF,0
newbuf:	db	'Initializing new NVRAM block',CR,LF,0
nchg:	db	'No changes to config',CR,LF,0
qsave:	db	'Save changes? ',0
mabrt:	db	CR,LF,'WIZCFG aborted',CR,LF,0

	cseg
start:
	lxi	sp,stack
	; TODO: scan for 'W'?
	;lda	cmd
	;ora	a
	;jz	show

	; read in currrent config (pick source)
	lda	direct
	ora	a
	jz	nvshow

; get config from WIZ850io...
	call	nvbinit	; fill buf with FF
	lxi	h,nvbuf
	lxi	d,0	; offset +0, BSB=0
	mvi	b,32	; entire block
	call	wizget
	lxi	h,nvbuf+32	; socket array area
	mvi	d,SOCK0	; BSB 08h = Socket 0 Register Block
	mvi	e,0	; offset +0
	mvi	b,8	; num sockets
save0:	push	b
	push	h
	mvi	b,32	; save all between, restore skips
	call	wizget	; HL = next block
	call	gkeep
	popix
	stx	a,NvKPALVTR
	pop	b
	mvi	a,001$00$000b	; socket BSB incr value
	add	d
	mov	d,a
	djnz	save0
	jr	over

; get config from NVRAM...
nvshow:
	call	nvgetb	; inits buf if needed
	jr	over
over0:	mvi	a,BEL
	call	chrout
; interate over all possible settings, prompting for new values...
over:
	; Node ID
	lda	nvbuf+PMAGIC
	call	shid
	lxi	d,quest3
	call	msgout
	call	linin
	jc	abort
	mov	a,c
	ora	a
	jrz	next1	; no change
	lxi	h,cmdlin
	mov	b,c
	call	parshx
	jc	over0
	mov	a,d
	sta	nvbuf+PMAGIC
	mvi	a,1
	sta	dirty
	jr	next1

over1:	mvi	a,BEL
	call	chrout
next1:	; IP Addr
	lxi	h,nvbuf+SIPR
	lxi	d,ipmsg
	call	ship
	lxi	d,quest2
	call	msgout
	call	linin
	jc	abort
	mov	a,c
	ora	a
	jrz	next2	; no change
	lxi	h,cmdlin
	mov	b,c
	lxix	nvbuf+SIPR
	call	parsadr
	jrc	over1
	mvi	a,1
	sta	dirty
	jr	next2

over2:	mvi	a,BEL
	call	chrout
next2:	;Subnet
	lxi	h,nvbuf+SUBR
	lxi	d,ntmsg
	call	ship
	lxi	d,quest2
	call	msgout
	call	linin
	jc	abort
	mov	a,c
	ora	a
	jrz	next3	; no change
	lxi	h,cmdlin
	mov	b,c
	lxix	nvbuf+SUBR
	call	parsadr
	jrc	over2
	mvi	a,1
	sta	dirty
	jr	next3

over3:	mvi	a,BEL
	call	chrout
next3:	; Gateway IP
	lxi	h,nvbuf+GAR
	lxi	d,gwmsg
	call	ship
	lxi	d,quest2
	call	msgout
	call	linin
	jc	abort
	mov	a,c
	ora	a
	jrz	next4	; no change
	lxi	h,cmdlin
	mov	b,c
	lxix	nvbuf+GAR
	call	parsadr
	jrc	over3
	mvi	a,1
	sta	dirty
	jr	next4

over4:	mvi	a,BEL
	call	chrout
next4:	; MAC address
	lxi	h,nvbuf+SHAR
	call	shmac
	lxi	d,quest
	call	msgout
	call	linin
	jc	abort
	mov	a,c
	ora	a
	jrz	next5	; no change
	lxi	h,cmdlin
	mov	b,c
	lxix	nvbuf+SHAR
	call	parsmac
	jrc	over4
	mvi	a,1
	sta	dirty
next5:	; now the sockets
	mvi	b,nsock
	lxix	nvbuf+32	; start of sockets
	mvi	a,'0'
	sta	sokn
	jr	soklup

over5:	mvi	a,BEL
	call	chrout
soklup:	
	push	b
	call	showsok
	lxi	d,quest
	call	msgout
	call	linin
	jc	abort
	mov	a,c
	ora	a
	jrz	next6	; NC also
	; TODO: allow de-config?
	lxi	h,cmdlin
	mov	b,c
	call	parsok
	mvi	a,1	; must preserve CY
	sta	dirty	;
next6:	pop	b
	jrc	over5
	lxi	d,32
	dadx	d
	lda	sokn
	inr	a
	sta	sokn
	djnz	soklup
; collected all changes...
	lda	dirty
	ora	a
	jz	nochg
	; prompt to save changes...
	lxi	d,qsave
	call	msgout
	call	linin
	jrc	exit
	lda	cmdlin
	cpi	'Y'
	jrnz	exit
	lda	direct
	jrnz	savwiz
	call	nvsetit
	jr	exit
savwiz:
	call	wizcfg0	; config WIZ850io from nvbuf
	; no error possible?
	jr	exit

nochg:	lxi	d,nchg
	call	msgout
exit:	jmp	0

abort:	lxi	d,mabrt
	call	msgout
	jmp	0

; Parse new Socket config
; IX=socket ptr, HL=cmdlin, B=len
parsok:
	; parse <srvid> <ipadr> <port>
	mvi	c,0	; NUL won't ever be seen
	call	parshx
	rc	; non-destructive error
	mvix	31h,SnPORT
	stx	d,SnPORT+1	; server ID
	call	skipb
	rc
	pushix
	lxi	d,SnDIPR
	dadx	d
	call	parsadr	; non-destructive on error
	popix
	rc
	call	skipb
	rc
	call	parsnm
	rc	; non-destructive error
	stx	d,SnDPORT
	stx	e,SnDPORT+1
	; optional keep-alive timeout
	mvix	0,NvKPALVTR
	call	skipb
	jrc	nokp
	mov	a,b
	ora	a
	cnz	parsnm
	rc	; non-destructive error
	call	div5
	mov	a,d
	ora	a
	jz	nokp0
	mvi	e,0ffh	; max keepalive
nokp0:	stx	e,NvKPALVTR
nokp:	ora	a	; NC
	ret

nvsetit:
	lxix	nvbuf
	call	scksum
	lxi	h,0	; WIZNET uses 512 bytes at 0000 in NVRAM
	lxi	d,512
	call	nvset
	ret

; Convert 'sokn' (ASCII digit) to socket BSB
getsokn:
	lda	sokn
	sui	'0'
	rrc
	rrc
	rrc		; xxx00000
	ori	SOCK0	; xxx01000
	ret

; Must show unconfigured sockets, to allow config
; IX=socket ptr, 'sokn' already set
showsok:
	lxi	d,sock
	call	msgout
	ldx	a,SnPORT
	cpi	31h
	jrnz	nosok
	ldx	a,SnPORT+1
	call	hexout
	mvi	a,' '
	call	chrout
	pushix
	pop	h
	lxi	d,SnDIPR
	dad	d
	call	ipout
	mvi	a,' '
	call	chrout
	ldx	d,SnDPORT
	ldx	e,SnDPORT+1
	call	dec16
	mvi	a,' '
	call	chrout
	ldx	a,NvKPALVTR
	call	mult5
	call	dec16
	ret
nosok:	lxi	d,ncfg
	call	msgout
	ret

hwout:
	mvi	b,6
	mvi	c,':'
hw0:	mov	a,m
	call	hexout
	dcr	b
	rz
	mov	a,c
	call	chrout
	inx	h
	jmp	hw0

ipout:
	mvi	b,4
	mvi	c,'.'
ip0:	mov	a,m
	call	decout
	dcr	b
	rz
	mov	a,c
	call	chrout
	inx	h
	jmp	ip0

crlf:
	mvi	a,CR
	call	chrout
	mvi	a,LF
	jmp	chrout

dec16:
	xchg	; remainder in HL
	mvi	c,0
	lxi	d,10000
	call	div16
	lxi	d,1000
	call	div16
	lxi	d,100
	call	div16
	lxi	d,10
	call	div16
	mov	a,l
	adi	'0'
	call	chrout
	ret

div16:	mvi	b,0
dv0:	ora	a
	dsbc	d
	inr	b
	jrnc	dv0
	dad	d
	dcr	b
	jrnz	dv1
	bit	0,c
	jrnz	dv1
	ret
dv1:	setb	0,c
	mvi	a,'0'
	add	b
	call	chrout
	ret

; A=number to print
; leading zeroes blanked - must preserve B
decout:
	push	b
	mvi	c,0
	mvi	d,100
	call	divide
	mvi	d,10
	call	divide
	adi	'0'
	call	chrout
	pop	b
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
	ret
div1:	setb	0,c
	push	psw	; remainder
	mvi	a,'0'
	add	e
	call	chrout
	pop	psw	; remainder
	ret

; brute-force divide DE by 5
; Return: DE=quotient (remainder lost)
div5:	push	h
	push	b
	xchg
	lxi	b,5
	lxi	d,0
	ora	a
div50:	dsbc	b
	jc	div51
	inx	d
	jmp	div50
div51:	pop	b
	pop	h
	ret

; Multiply A by 5, result in DE
mult5:	xchg	; save HL
	mov	l,a
	mvi	h,0
	dad	h	; *2
	dad	h	; *4
	add	l	; *5
	mov	l,a
	mvi	a,0
	adc	h
	mov	h,a
	xchg	; result to DE, restore HL
	ret

hexout:
	push	psw
	rrc
	rrc
	rrc
	rrc
	call	hexdig
	pop	psw
	;jmp	hexdig
hexdig:
	ani	0fh
	adi	90h
	daa
	aci	40h
	daa
	jmp	chrout

skipb1:	; skip character, then skip blanks
	inx	h
	dcr	b
skipb:	; skip blanks
	mov	a,b
	ora	a
	stc
	rz
skip0:	mov	a,m
	cpi	' '
	rnz	; no carry?
	inx	h
	djnz	skip0
	stc
	ret

; IX=destination
; parse into temp, for non-destructive error exits
parsmac:
	lxiy	temp
	mvi	c,':'
pm00:
	call	parshx
	rc
	sty	d,+0
	jz	pm1	; hit term char
	; TODO: check for 6 bytes...
	; now copy into place
	lxiy	temp
	ldy	a,+0
	stx	a,+0
	ldy	a,+1
	stx	a,+1
	ldy	a,+2
	stx	a,+2
	ldy	a,+3
	stx	a,+3
	ldy	a,+4
	stx	a,+4
	ldy	a,+5
	stx	a,+5
	ora	a	; NC, no error
	ret
pm1:
	inxiy
	inx	h	; skip ':'
	djnz	pm00
	; error if ends here...
	stc
	ret

; C=term char
; returns CY if error, Z if term char, NZ end of text
; returns D=value
parshx:
	mvi	d,0
pm0:	mov	a,m
	cmp	c
	rz
	cpi	' '
	jrz	nzret
	sui	'0'
	rc
	cpi	'9'-'0'+1
	jrc	pm3
	sui	'A'-'0'
	rc
	cpi	'F'-'A'+1
	cmc
	rc
	adi	10
pm3:
	ani	0fh
	mov	e,a
	mov	a,d
	add	a
	rc
	add	a
	rc
	add	a
	rc
	add	a
	rc
	add	e	; carry not possible
	mov	d,a
	inx	h
	djnz	pm0
nzret:
	xra	a
	inr	a	; NZ
	ret

; IX=destination
; Parse into temp location, so errors are non-destructive
parsadr:
	lxiy	temp
	mvi	c,'.'
pa00:
	mvi	d,0
pa0:	mov	a,m
	cmp	c
	jz	pa1
	cpi	' '
	jz	pa2
	cpi	'0'
	rc
	cpi	'9'+1
	cmc
	rc
	ani	0fh
	mov	e,a
	mov	a,d
	add	a	; *2
	add	a	; *4
	add	d	; *5
	add	a	; *10
	add	e
	rc
	mov	d,a
	inx	h
	djnz	pa0
pa2:
	; TODO: check for 4 bytes...
	sty	d,+0
	; now copy value into place
	lxiy	temp
	ldy	a,+0
	stx	a,+0
	ldy	a,+1
	stx	a,+1
	ldy	a,+2
	stx	a,+2
	ldy	a,+3
	stx	a,+3
	ora	a	; NC, no error
	ret

pa1:
	sty	d,+0
	inxiy
	inx	h	; skip '.'
	djnz	pa00
	; error if ends here... (string ends in '.')
	stc
	ret

; Parse a 16-bit (max) decimal number
parsnm:
	lxi	d,0
pd0:	mov	a,m
	cpi	' '
	rz
	cpi	'0'
	rc
	cpi	'9'+1
	cmc
	rc
	ani	0fh
	push	h
	mov	h,d
	mov	l,e
	dad	h	; *2
	jc	pd1
	dad	h	; *4
	jc	pd1
	dad	d	; *5
	jc	pd1
	dad	h	; *10
	jc	pd1
	mov	e,a
	mvi	d,0
	dad	d
	xchg
	pop	h
	rc
	inx	h
	djnz	pd0
	ora	a	; NC
	ret

pd1:	pop	h
	ret	; CY still set

; Get a block of data from NVRAM to 'buf'
; Verify checksum, init block if needed.
nvgetb:
	lxix	nvbuf
	lxi	h,0
	lxi	d,512
	call	nvget
	call	vcksum
	rz	; chksum OK, ready to update/use
	lxi	d,newbuf
	call	msgout
nvbinit:
	lxi	h,nvbuf
	mvi	m,0ffh
	mov	d,h
	mov	e,l
	inx	h
	lxi	b,512-1
	ldir
	ret

if 0
; NOTE: this delay varies with CPU clock speed.
msleep:
	push	h
mslp0:	push	psw
	lxi	h,79	; ~1mS at 2.048MHz (200uS at 10.24MHz)
mslp1:	dcx	h
	mov	a,h
	ora	l
	jrnz	mslp1
	pop	psw
	dcr	a
	jrnz	mslp0
	pop	h
	ret
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; These defines should be in a common file...
spi	equ	40h

spi?dat	equ	spi+0
spi?ctl	equ	spi+1
spi?sts	equ	spi+1

NVSCS	equ	10b	; H8xSPI SCS for NVRAM

; Standard W5500 register offsets
GAR	equ	1	; offset of GAR, etc.
SUBR	equ	5
SHAR	equ	9
SIPR	equ	15
PMAGIC	equ	29	; used for node ID

nsock	equ	8
SOCK0	equ	000$01$000b
SOCK1	equ	001$01$000b
SOCK2	equ	010$01$000b
SOCK3	equ	011$01$000b
SOCK4	equ	100$01$000b
SOCK5	equ	101$01$000b
SOCK6	equ	110$01$000b
SOCK7	equ	111$01$000b

SnMR	equ	0
SnCR	equ	1
SnIR	equ	2
SnSR	equ	3
SnPORT	equ	4
SnDIPR	equ	12
SnDPORT	equ	16
SnRESV1 equ     20      ; 0x14 reserved
SnRESV2 equ     23      ; 0x17 reserved
SnRESV3 equ     24      ; 0x18 reserved
SnRESV4 equ     25      ; 0x19 reserved
SnRESV5 equ     26      ; 0x1a reserved
SnRESV6 equ     27      ; 0x1b reserved
SnRESV7 equ     28      ; 0x1c reserved
SnRESV8 equ     29      ; 0x1d reserved
SnTXBUF	equ	31	; TXBUF_SIZE

NvKPALVTR equ	SnRESV8	; where to stash keepalive in NVRAM
SnKPALVTR equ	47	; Keep alive timeout, 5s units

; Socket SR values
CLOSED	equ	00h

; Socket CR commands
DISCON	equ	08h

; Standard NVRAM defines

; NVRAM/SEEPROM commands
NVRD	equ	00000011b
NVWR	equ	00000010b
RDSR	equ	00000101b
WREN	equ	00000110b
; NVRAM/SEEPROM status bits
WIP	equ	00000001b

; Put block of data to NVRAM from 'buf'
; HL = nvram address, DE = length
; Must write in 128-byte blocks (pages).
; HL must be 128-byte aligned, DE must be multiple of 128
nvset:
	push	h
	lxi	h,nvbuf	; HL = buf, TOS = nvadr
	mvi	c,spi?ctl
nvset0:
	; wait for WIP=0...
	mvi	a,NVSCS
	outp	a
	mvi	a,RDSR
	out	spi?dat
	in	spi?dat	; prime pump
	in	spi?dat	; status register
	push	psw
	xra	a
	outp	a	; not SCS
	pop	psw
	ani	WIP
	jrnz	nvset0
	mvi	a,NVSCS
	outp	a
	mvi	a,WREN
	out	spi?dat
	xra	a
	outp	a	; not SCS
	mvi	a,NVSCS
	outp	a
	mvi	a,NVWR
	out	spi?dat
	xthl	; get nvadr
	mov	a,h
	out	spi?dat
	mov	a,l
	out	spi?dat
	lxi	b,128
	dad	b	; update nvadr
	xchg
	ora	a
	dsbc	b	; update length
	xchg
	xthl	; get buf adr
	mov	b,c	; B = 128
	mvi	c,spi?dat
	outir		; HL = next page in 'buf'
	mvi	c,spi?ctl
	xra	a
	outp	a	; not SCS
;	mvi	a,50
;	call	msleep	; wait for WIP to go "1"?
	mov	a,e
	ora	d
	jrnz	nvset0
	pop	h
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; A = PMAGIC
shid:	push	psw
	lxi	d,idmsg
	call	msgout
	pop	psw
	jmp	hexout

; HL = IP addr, DE = prefix msg
ship:	push	h
	call	msgout
	pop	h
	jmp	ipout

; HL = mac addr
shmac:	push	h
	lxi	d,mcmsg
	call	msgout
	pop	h
	jmp	hwout

msgout:	ldax	d
	ora	a
	rz
	inx	d
	call	conout
	jr	msgout

chrout:
conout:	push	psw
cono0:	in	0edh
	ani	00100000b
	jrz	cono0
	pop	psw
	out	0e8h
	ret

linix:	mvi	m,0	; terminate buffer
	jmp	crlf

; input a line from console, allow backspace
; returns C=num chars
linin:
	lxi	h,cmdlin
	mvi	c,0	; count chars
lini0	call	conin
	cpi	CR
	jrz	linix
	cpi	CTLC	; cancel
	stc
	rz
	cpi	BS
	jrz	backup
	cpi	' '
	jrc	chrnak
	cpi	'A'
	jrc	chrok
	ani	01011111b	; toupper
	cpi	'Z'+1
	jrnc	chrnak
chrok:	mov	m,a
	inx	h
	inr	c
	jm	chrovf	; 128 chars max
	call	conout
	jr	lini0
chrovf:	dcx	h
	dcr	c
chrnak:	mvi	a,BEL
	call	conout
	jr	lini0
backup:
	mov	a,c
	ora	a
	jrz	lini0
	dcr	c
	dcx	h
	mvi	a,BS
	call	conout
	mvi	a,' '
	call	conout
	mvi	a,BS
	call	conout
	jr	lini0

conin:	in	0edh
	ani	00000001b
	jrz	conin
	in	0e8h
	ani	01111111b
	ret

	dseg
	ds	40
stack:	ds	0

temp:	db	0,0,0,0,0,0	; space for IP or MAC addr
	db	0,0,0,0,0,0	; pad for error entry?
direct:	db	0
dirty:	db	0

cmdlin:	ds	128

nvbuf:	ds	512

	end
