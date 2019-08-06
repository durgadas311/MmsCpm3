; SNIOS for WIZ810MJ/WIZ812MJ
;
	maclib	z80

	public	NTWKIN, NTWKST, CNFTBL, SNDMSG, RCVMSG, NTWKER, NTWKBT, NTWKDN, CFGTBL

wiz	equ	10h	; base port
wiz$mr	equ	wiz+0
wiz$arh	equ	wiz+1
wiz$arl	equ	wiz+2
wiz$dr	equ	wiz+3

; common regs
ir	equ	21
rmsr	equ	26
tmsr	equ	27
pmagic	equ	41

; socket regs, relative
sn$prt	equ	4
sn$cr	equ	1
sn$ir	equ	2
sn$sr	equ	3
sn$txwr	equ	36
sn$rxrsr equ	38
sn$rxrd	equ	40

; socket commands
OPEN	equ	01h
CONNECT	equ	04h
SEND	equ	20h
RECV	equ	40h

; socket status
INIT	equ	13h
ESTABLISHED equ	17h

	cseg
;	Slave Configuration Table
CFGTBL:
	ds	1		; network status byte
	ds	1		; slave processor ID number
	ds	2		; A:	Disk device	+2
	ds	2		; B:	"
	ds	2		; C:	"
	ds	2		; D:	"
	ds	2		; E:	"
	ds	2		; F:	"
	ds	2		; G:	"
	ds	2		; H:	"
	ds	2		; I:	"
	ds	2		; J:	"
	ds	2		; K:	"
	ds	2		; L:	"
	ds	2		; M:	"
	ds	2		; N:	"
	ds	2		; O:	"
	ds	2		; P:	"

	ds	2		; console device	+34

	ds	2		; list device:		+36...
	ds	1		;	buffer index	+2
	db	0		;	FMT		+3
	db	0		;	DID		+4
	db	0ffh		;	SID (CP/NOS must still initialize)
	db	5		;	FNC		+6
	db	0		;	SIZ		+7
	ds	1		;	MSG(0)	List number	+8
	ds	128		;	MSG(1) ... MSG(128)	+9...

;	Network Status Byte Equates
;
active		equ	0001$0000b	; slave logged in on network
rcverr		equ	0000$0010b	; error in received message
senderr 	equ	0000$0001b	; unable to send message

srvtbl:	ds	4	; SID, per socket

rxbase:	ds	8	; RX base and top addrs (hi bytes)
txbase:	ds	8	; TX base and top addrs (hi bytes)

cursok:	db	0	; current socket
curbas:	db	0
curtop:	db	0
curptr:	dw	0	; into chip mem
curseg:	dw	0	; bytes until wrap
msgptr:	dw	0
msglen:	dw	0
totlen:	dw	0

getwiz1:
	mov	a,d
	out	wiz$arh
	mov	a,e
	out	wiz$arl
	in	wiz$dr
	ret

; Get 16-bit value from chip
; Prereq: IDM_AR0 already set, auto-incr on
; Entry: A=value for IDM_AR1
; Return: HL=register pair contents
getwiz2:
	out	wiz$arl
	in	wiz$dr
	mov	h,a
	in	wiz$dr
	mov	l,a
	ret

; Put 16-bit value to chip
; Prereq: IDM_AR0 already set, auto-incr on
; Entry: A=value for IDM_AR1
;        HL=register pair contents
putwiz2:
	out	wiz$arl
	mov	a,h
	out	wiz$dr
	mov	a,l
	out	wiz$dr
	ret

; Issue command, wait for complete
; Prereq: IDM_AR0=desired socket base
; Returns: A=Sn_SR
wizcmd:	push	psw
	in	wiz$mr
	ani	11111101b	; auto-incr off
	out	wiz$mr
	mvi	a,sn$cr
	out	wiz$arl
	pop	psw
	out	wiz$dr
wc0:	in	wiz$dr
	ora	a
	jrnz	wc0
	in	wiz$mr
	ori	00000010b	; auto-incr on
	out	wiz$mr
	mvi	a,sn$sr
	out	wiz$arl
	in	wiz$dr
	ret

; B=Server ID, preserves HL
; returns DE=socket base (if NC)
getsrv:
	mvi	c,4
	lxi	d,srvtbl
gs1:
	ldax	d
	inx	d
	cmp	b
	jrz	gs0
	dcr	c
	jrnz	gs1
	stc	; not found
	ret
gs0:	; found...
	mvi	a,4
	sub	c	; socket num
	sta	cursok
	adi	04h
	out	wiz$arh
	mvi	a,sn$sr
	out	wiz$arl
	in	wiz$dr
	cpi	ESTABLISHED
	rz
	cpi	INIT
	jrz	gs3
	; try to open socket...
	mvi	a,OPEN
	call	wizcmd
	cpi	INIT
	jrnz	gs2
gs3:	mvi	a,CONNECT
	call	wizcmd
	cpi	ESTABLISHED
	rz
gs2:	stc	; failed to open
	ret

; HL=socket relative pointer (TX_WR)
; DE=length
; Destroys IDM_AR0, IDM_AR1
cpyout:
	lda	curbas
	add	h
	out	wiz$arh
	mov	a,l
	out	wiz$arl
	lhld	msgptr
	mvi	c,wiz$dr
	mov	b,e	; fraction of page
	mov	a,e
	ora	a
	jrz	co0	; exactly 256
	outir		; do partial page
	; B is now 0 (256 bytes)
	mov	a,d
	ora	a
	jrz	co1
co0:	outir	; 256 (more) bytes to xfer
co1:	shld	msgptr
	ret

; HL=socket relative pointer (RX_RD)
; DE=length
; Destroys IDM_AR0, IDM_AR1
cpyin:
	lda	curbas
	add	h
	out	wiz$arh
	mov	a,l
	out	wiz$arl
	lhld	msgptr
	mvi	c,wiz$dr
	mov	b,e	; fraction of page
	mov	a,e
	ora	a
	jrz	ci0	; exactly 256
	inir		; do partial page
	; B is now 0 (256 bytes)
	mov	a,d
	ora	a
	jrz	ci1
ci0:	inir	; 256 (more) bytes to xfer
ci1:	shld	msgptr
	ret

; C=bits to reset
; D=socket base
wizsts:
	mov	a,d
	out	wiz$arh
wizsts1:	; IDM_AR0 already set
	mvi	a,sn$ir
	out	wiz$arl
	in	wiz$dr
	push	psw
	ana	c
	jrz	ws0	; don't reset if not set (could race)
	mvi	a,sn$ir	; must reset due to auto-incr
	out	wiz$arl
	mov	a,c
	out	wiz$dr
ws0:	pop	psw
	ret

;	Utility Procedures
;
;	Network Initialization
NTWKIN:
	lxix	CFGTBL
	lxi	d,pmagic
	call	getwiz1
	ora	a
	jz	err
	stx	a,+1 ; our slave (client) ID
	mvi	a,active
	stx	a,+0 ; network status byte
	xra	a
	sta	CFGTBL+36+7
	jmp	NTWKBT	; load data

;	Network Status
NTWKST:
	lda	CFGTBL+0
	mov	b,a
	ani	not (rcverr+senderr)
	sta	CFGTBL+0
	mov	a,b
	ret

;	Return Configuration Table Address
;	Still need this for BDOS func 69
CNFTBL:
	lxi	h,CFGTBL
	ret

;	Send Message on Network
SNDMSG:			; BC = message addr
	sbcd	msgptr
	lixd	msgptr
	ldx	b,+1	; SID - destination
	call	getsrv
	jrc	serr
	; DE=socket
	lda	CFGTBL+1
	stx	a,+2	; Set Slave ID in header
	ldx	a,+4	; msg siz (-1)
	adi	5+1	; hdr, +1 for (-1)
	mov	l,a
	mvi	a,0
	aci	0
	mov	h,a	; HL=msg length
	shld	msglen
	call	tx$setup
	lhld	msglen
	lbcd	curptr
	dad	b
	lda	curtop
	dcr	a
	ana	h
	mov	h,a	; HL=new TX_WR
	mvi	a,sn$txwr
	call	putwiz2
	mov	a,h	; nxt
	cmp	b	; nxt-cur
	jrnc	nowrap
	lhld	curseg
	xchg
	lhld	msglen
	ora	a
	dsbc	d
	shld	msglen
	lhld	curptr
	call	cpyout
	lxi	h,0
	shld	curptr
nowrap:
	; send data
	lhld	msglen
	xchg
	lhld	curptr
	call	cpyout
	lda	cursok
	adi	04h
	out	wiz$arh
	mvi	a,SEND
	call	wizcmd
	; ignore Sn_SR?
	mvi	c,00010000b	; SEND_OK bit
	call	wizsts1
	cma	; want "0" on success
	ana	c	; SEND_OK
	rz
serr:	lda	CFGTBL
	ori	senderr
	sta	CFGTBL
	mvi	a,0ffh
	ret

; TODO: also check/OPEN sockets?
; That would result in all sockets always being open...
; At least check all, if none are ESTABLISHED then error immediately
check:
	lxi	d,sn$sr+0400h
	mvi	b,4
chk2:	call	getwiz1
	cpi	ESTABLISHED
	jrz	chk3
	inr	d	; next socket
	djnz	chk2
	stc
	ret
chk3:	lxi	h,32000	; do check for sane receive time...
chk0:	mvi	d,04h	; socket base
	mvi	b,4
	mvi	c,00000100b	; RECV data available bit
chk1:	call	wizsts
	ana	c	; RECV data available
	rnz	; D=socket
	inr	d	; next socket
	djnz	chk1
	dcx	h
	mov	a,h
	ora	l
	jrnz	chk0
	stc
	ret

;	Receive Message from Network
RCVMSG:			; BC = message addr
	sbcd	msgptr
	lixd	msgptr
	call	check	; locates socket that is ready
	; DE=socket
	jrc	rerr
	call	rx$setup
	lxi	h,0
	shld	totlen
rm0:	; IDM_AR0 must be socket base...
	mvi	a,sn$rxrsr	; length
	call	getwiz2
	mov	a,h
	ora	l
	jrz	rm0
	shld	msglen		; not CP/NET msg len
	; DE destroyed...
	xchg		; DE=Sn_RX_RSR
	lhld	totlen
	ora	a
	dsbc	d
	shld	totlen	; might be negative...
	mvi	a,sn$rxrd	; pointer
	call	getwiz2
	shld	curptr
	xchg	; DE=Sn_RX_RD, HL=Sn_RX_RSR
	dad	d
	lda	curtop
	dcr	a
	ana	h	; nxt
	mov	h,a	; HL=nxt RD
	mvi	a,sn$rxrd
	call	putwiz2
	mov	a,h
	cmp	d	; nxt-cur
	jrnc	nowrp2
	ora	l
	jrz	nowrp2	; exact wrap
	lda	curtop
	mov	h,a
	mvi	l,0
	lbcd	curptr
	ora	a
	dsbc	b	; HL=num bytes until wrap
	;shld	curseg
	xchg	; DE=curseg
	lhld	msglen
	ora	a
	dsbc	d
	shld	msglen
	mov	l,c	; curptr
	mov	h,b	;
	call	cpyin	; destroys IDM_AR0, IDM_AR1
	lxi	h,0
	shld	curptr
nowrp2:
	lhld	msglen
	xchg
	lhld	curptr
	call	cpyin	; destroys IDM_AR0, IDM_AR1
	lda	cursok
	adi	04h
	out	wiz$arh
	mvi	a,RECV
	call	wizcmd
	; ignore Sn_SR?
	lhld	totlen	; might be neg (first pass)
	mov	a,h
	ora	a
	jp	rm1
	; can we guarantee at least msg hdr?
	ldx	a,+4	; msg siz (-1)
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

rerr:	lda	CFGTBL
	ori	rcverr
	sta	CFGTBL
err:	mvi	a,0ffh
NTWKER:	ret

NTWKBT:	; NETWORK WARM START
	lda	CFGTBL
	ani	active
	jz	NTWKIN	; will end up back here, on success
	in	wiz$mr
	ori	00000010b	; auto-incr
	out	wiz$mr
	; load socket server IDs
	mvi	c,4
	mvi	d,04h	; base of sock regs
	lxi	h,srvtbl
nb1:
	mov	a,d
	out	wiz$arh
	mvi	a,sn$prt
	out	wiz$arl
	in	wiz$dr
	cpi	31h
	mvi	a,0ffh
	jrnz	nb0
	in	wiz$dr	; continuation
nb0:	mov	m,a
	inx	h
	inr	d	; next socket
	dcr	c
	jrnz	nb1
	; compute socket buffers
	xra	a
	out	wiz$arh
	mvi	a,rmsr
	out	wiz$arl
	in	wiz$dr	; get RMSR
	mvi	d,60h	; RX memory base
	lxi	h,rxbase
	call	setbuf
	; compute TX bases, TMSR is RMSR+1
	in	wiz$dr	; auto-incr makes this TMSR
	mvi	d,40h	; TX memory base
	lxi	h,txbase
	call	setbuf
	xra	a
	ret

; Compute base and top for all 4 sockets
; HL=rxbase, D=60h, A=RMSR or
; HL=txbase, D=40h, A=TMSR
setbuf:
	mvi	b,4
sb0:	mov	m,d	; base addr
	inx	h
	mov	c,a
	call	comp	; A=04h,08h,10h,20h
	mov	m,a	; top addr offset (size)
	inx	h
	add	d	; next memory chunk
	mov	d,a
	mov	a,c
	ani	11111100b
	rrc
	rrc
	djnz	sb0
	ret

; compute (1024 << A)
; Uses A and E only.
comp:	ani	00000011b	; (1 << A) Kbytes
	mov	e,a
	ora	a
	mvi	a,04h	; 1K
	rz
cmp0:	add	a
	dcr	e
	jrnz	cmp0
	ret

; IDM_AR0=socket base
; Sets curptr, curbas, curtop, curseg
; Returns: HL=space before wrap
tx$setup:
	mvi	a,sn$txwr
	call	getwiz2
	shld	curptr
	lda	cursok
	add	a	; 2 bytes/entry
	lxi	h,txbase
	mov	c,a
	mvi	b,0
	dad	b
	mov	a,m	; base page
	sta	curbas
	inx	h
	mov	a,m	; top page
	sta	curtop
	mov	h,a
	mvi	l,0
	lbcd	curptr
	ora	a
	dsbc	b	; HL=num bytes until wrap
	shld	curseg
	; never carry? never zero?
	ret

; DE=socket base (preserved)
; IDM_AR0=socket base
; Sets curbas, curtop
rx$setup:
	mvi	a,sn$ir
	out	wiz$arl
	mvi	a,00000100b	; RECV data available bit
	out	wiz$dr	; reset status bit
	mov	a,d
	ani	00000011b	; socket num
	add	a	; 2 bytes/entry
	lxi	h,rxbase
	mov	c,a
	mvi	b,0
	dad	b
	mov	a,m	; base page
	sta	curbas
	inx	h
	mov	a,m	; top page
	sta	curtop
	ret

NTWKDN:	; TODO: close all sockets
	xra	a
	ret

	end
