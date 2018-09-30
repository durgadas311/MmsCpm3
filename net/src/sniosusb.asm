; SNIOS for Noberto's H89 USB/SERIAL board,
; Specifically, the FT245R chip.
; http://koyado.com/Heathkit/H-89_USB_Serial.html
;
	maclib z80

USBPORT equ	0d8h
STSPORT equ	0dah

USBRXR	equ	00000010b	; Rx data available in FIFO
USBTXR	equ	00000001b	; Tx space available in FIFO

	public	NTWKIN, NTWKST, CNFTBL, SNDMSG, RCVMSG, NTWKER, NTWKBT, CFGTBL

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
active		equ	0001$0000b	; slave logged in on network
rcverr		equ	0000$0010b	; error in received message
senderr 	equ	0000$0001b	; unable to send message

;	Utility Procedures
;
	page
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
	call	SNDMSG
	ora	a
	jnz	initerr
	lxi	b,msgbuf
	call	RCVMSG
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

sendhex:
	push	psw
	rrc
	rrc
	rrc
	rrc
	call	senddig
	pop	psw
senddig:
	ani	0fh
	adi	90h
	daa
	aci	40h
	daa
sendbyt:
	mov	c,a
sendb0:
	in	STSPORT
	ani	USBTXR
	jz	sendb0
	mov	a,c
	out	USBPORT	; probably can't ever overrun?
	ret		; if not, should make this in-line

; HL = message header
sendhdr:
	mvi	a,'+'	; start of message - SYNC
	call	sendbyt
	mvi	a,'+'	; two sync bytes...
	call	sendbyt
	mvi	b,5
sendh0:
	mov	a,m
	call	sendhex
	inx	h
	dcr	b
	jnz	sendh0
	xra	a
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
	mov	h,b
	mov	l,c		; HL = message address
	push	h
	popix
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
	mvi	a,'-'
	call	sendbyt
	mvi	a,'-'
	call	sendbyt
	xra	a
	ret
initerr:
	mvi	a,0ffh
	ret

recvhdr:
	mvi	b,5
recvh0:
	call	recvhex
	rc
	mov	m,a
	inx	h
	dcr	b
	jnz	recvh0
	ret

recvhex:
	call	recvdig
	rc
	rlc
	rlc
	rlc
	rlc
	mov	e,a
	call	recvdig
	rc
	ora	e
	ret

recvdig:
	call	recvbyt
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
	mov	h,b
	mov	l,c		; HL = message address
	push	h
	popix
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
	ldx	b,4 ; msg siz field (-1)
	inr	b   ; might be 0, but that means 256
	call	recvh0
	jc	recev2
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
	ret

	end
