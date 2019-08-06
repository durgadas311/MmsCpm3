; SNIOS for Noberto's H8 USB board,
; Specifically, the FT245R chip.
; http://koyado.com/Heathkit/H-8_USB.html
; default/presumed port at 0b0h
;
	maclib z80

USBPORT equ	0b0h
STSPORT equ	0b2h

USBRXR	equ	00000010b	; Rx data available in FIFO
USBTXR	equ	00000001b	; Tx space available in FIFO

	public	NTWKIN, NTWKST, CNFTBL, SNDMSG, RCVMSG, NTWKER, NTWKBT, NTWKDN, CFGTBL

	cseg

;	Slave Configuration Table
CFGTBL:
	db	0		; network status byte
	ds	1		; slave processor ID number
	ds	2		; A:  Disk device
	ds	2		; B:   "
	ds	2		; C:   "
	ds	2		; D:   "
	ds	2		; E:   "
	ds	2		; F:   "
	ds	2		; G:   "
	ds	2		; H:   "
	ds	2		; I:   "
	ds	2		; J:   "
	ds	2		; K:   "
	ds	2		; L:   "
	ds	2		; M:   "
	ds	2		; N:   "
	ds	2		; O:   "
	ds	2		; P:   "

	ds	2		; console device

	ds	2		; list device:
	ds	1		;	buffer index
msgbuf:
	db	0		;	FMT
	db	0		;	DID
	db	0ffh		;	SID (CP/NOS must still initialize)
	db	5		;	FNC
	ds	1		;	SIZ
	ds	1		;	MSG(0)	List number
	ds	128		;	MSG(1) ... MSG(128)

hostid:	db	0

;	Network Status Byte Equates
;
active		equ	00010000b	; slave logged in on network
rcverr		equ	00000010b	; error in received message
senderr 	equ	00000001b	; unable to send message

;	Utility Procedures
;
;	page
;	Network Initialization
NTWKIN:
	call	check	; confirm h/w exists...
	jc	initerr
	; TODO: how to get slave ID?
	; Send "BDOS Func 255" message to other end,
	; Response will tell us our, and their, node ID
	lxix	msgbuf
	mvix	0,+0	; FMT
	mvix	0ffh,+3	; BDOS Func
	mvix	0,+4	; Size
	lxi	b,msgbuf
	call	sndmsg0	; avoid active check
	ora	a
	jnz	initerr
	lxi	b,msgbuf
	call	rcvmsg0	; avoid active check
	ora	a
	jnz	initerr
	lxix	msgbuf
	ldx	b,+1	; our node ID
	ldx	c,+2	; host node ID
	lxix	CFGTBL
	mvi	a,active
	stx	a,+0	; network status byte
	stx	b,+1	; our slave (client) ID
	mov	a,c
	sta	hostid
	xra	a
	sta	CFGTBL+36+7	; clear SIZ - discard LST output
	ret

;	Network Status
NTWKST:
	lda	CFGTBL+0
	mov	b,a
	ani	not (rcverr+senderr)
	sta	CFGTBL+0
	mov	a,b
	ret

;	Return Configuration Table Address
CNFTBL:
	lxi	h,CFGTBL
	ret

; Destroys E,C
sendhex:
	mov	e,a
	rrc
	rrc
	rrc
	rrc
	call	senddig
	mov	a,e
senddig:
	ani	0fh
	adi	90h
	daa
	aci	40h
	daa
	; jmp sendbyt
; Destroys C
sendbyt:
	mov	c,a
sendb0:
	in	STSPORT
	ani	USBTXR
	jz	sendb0
	mov	a,c
	out	USBPORT	; probably can't ever overrun?
	ret		; if not, should make this in-line

; IY = message header, HL = crc
; Destroys B,C,E,D
sendhdr:
	mvi	a,'+'	; start of message - SYNC
	call	sendbyt	; destroys C
	mvi	a,'+'	; two sync bytes...
	call	sendbyt	; destroys C
	lxi	h,0ffffh	; init CRC
	mvi	b,5
sendh0:
	ldy	a,+0
	inxiy
	mov	d,a
	call	sendhex	; destroys E,C,A
	mov	a,d
	call	crc	; destroys E,C,A
	dcr	b
	jnz	sendh0
	xra	a
	ret

POLY	equ	8408h
; HL = cumulative CRC, A = new byte (used)
; Destroys C,E,A
crc:
	mvi	e,8
crc0:	mov	c,a
	xra	l	; clears CY
	rarr	h
	rarr	l
	ani	1
	jz	crc1
	mvi	a,LOW POLY
	xra	l
	mov	l,a
	mvi	a,HIGH POLY
	xra	h
	mov	h,a
crc1:	mov	a,c
	rar	; no need to worry about CY in,
	dcr	e
	jnz	crc0
	ora	a	; but must not leave CY on return
	ret

check:
	; do check for sane hardware...
	lxi	h,0
	mvi	e,3	; approx 4.5 sec @ 2MHz
check0:
	in	STSPORT	; 11
	ani	USBTXR	; 7, also NC
	rnz		; 5 (11)
	dcx	h	; 6
	mov	a,h	; 4
	ora	l	; 4
	jnz	check0	; 10 = 47, * 65536 = 3080192 = 1.504 sec
	dcr	e	; 4
	jnz	check0	; 10
	stc
	ret

;	Send Message on Network
SNDMSG:			; BC = message addr
	lda	CFGTBL	; status
	ani	active
	jz	initerr
sndmsg0:
	push	b
	popix
	push	b
	popiy
	lda	CFGTBL+1	; our ID
	stx	a,+2		; ensure SID is correct
	call	sendhdr
	ora	a
	jnz	initerr
	; HL points to payload now...
	ldx	b,+4	; msg siz field (-1)
	inr	b	; might be 0, but that means 256
	call	sendh0
	ora	a
	jnz	initerr
	mov	a,l	; send CRC
	call	sendhex	;
	mov	a,h	;
	call	sendhex	;
	mvi	a,'-'
	call	sendbyt
	mvi	a,'-'
	call	sendbyt
	xra	a
	ret
initerr:
	mvi	a,0ffh
	ret

; IY = recv buffer, B = len
; HL = crc, destroys B,C,E
recvhdr:
	lxi	h,0ffffh	; init CRC
	mvi	b,5
recvh0:
	call	recvhex	; destroys E,C
	rc
	sty	a,+0
	inxiy
	call	crc	; destroys E,C
	dcr	b
	jnz	recvh0
	ret

; Destroys E,C
; Returns Hex value in A
recvhex:
	call	recvdig ; destroys C
	rc
	rlc
	rlc
	rlc
	rlc
	mov	e,a
	call	recvdig ; destroys C
	rc
	ora	e
	ret

recvdig:
	call	recvbyt ; destroys C
	rc
	sui	'0'
	rc
	cpi	10
	jnc	recvd1
	ora	a
	ret
recvd1:
	sui	'A'-'0'
	rc
	adi	10
	ret

; When using this, each byte must be coming soon...
; Destroys C
; Returns character in A
recvbyt:
	mvi	c,0
recvb0:
	in	STSPORT
	ani	USBRXR
	jnz	recvb1
	dcr	c
	jnz	recvb0
	stc
	ret	; CY, plus A not '-'
recvb1:
	in USBPORT
	ret

;	Receive Message from Network
;	Wait for "++" sequence, discarding characters, then save message.
;	TODO: need timeout? Must be long timeout...
RCVMSG:			; BC = message addr
	lda	CFGTBL	; status
	ani	active
	jz	initerr
rcvmsg0:
	push	b
	popix		; IX = message pointer
	push	b
	popiy		; IY = message address (++)
recev1:
	mvi	b,2
recev0:
	in	STSPORT
	ani	USBRXR
	jz	recev0
	in	USBPORT
	cpi	'+'
	jnz	recev1	; reset count, too
	dcr	b
	jnz	recev0
	; got SYNC "++", now just input bytes and decode - until "--"
	call	recvhdr
	jc	recev2
	ldx	b,+4 ; msg siz field (-1)
	inr	b   ; might be 0, but that means 256
	call	recvh0
	jc	recev2
	call	recvhex	; destroys C,E
	jc	recev2
	call	crc	; destroys C,E
	call	recvhex	; destroys C,E
	jc	recev2
	call	crc	; destroys C,E
	mov	a,h
	ora	l
	jnz	recev2
	; Now confirm we get "--" EOM
	call	recvbyt
	cpi	'-'
	jnz	recev2
	call	recvbyt
	cpi	'-'
	jnz	recev2
	xra	a
	ret
recev2:
	mvi	a,0ffh
NTWKER:
	ret

;
NTWKBT:
 
;	This procedure is called each time the CCP is
;	reloaded from disk.
NTWKDN:
	xra	a
	ret

	end
