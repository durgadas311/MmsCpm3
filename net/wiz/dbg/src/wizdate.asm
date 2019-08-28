; Get time/date from a remote server over WIZ850io and display it.
;
	maclib z80

BDOS	equ	0005h
CMDLN	equ	0080h

; BDOS functions
CONOUT	equ	2
PRINT	equ	9
GETVER	equ	12

; CP/NET NDOS functions
NSEND	equ	66
NRECV	equ	67

	org	0100h
	jmp	start

vers:	dw	0

gettime: db	0, 0, 2, 105, 0, 0
gottime: db	1, 2, 0, 105, 4, 0, 0, 0, 0, 0 ; just prediction of what will be received

; assume < 100
decout:
	mvi	b,'0'
decot0:
	sui	10
	jc	decot1
	inr	b
	jmp	decot0
decot1:
	adi	10
	adi	'0'
	push	psw
	mov	a,b
	call	prout
	pop	psw
	jmp	prout

; Keeps number in HL - caller must preserve/init
; Returns CY for invalid
hexnum:
	sui	'0'
	rc
	cpi	9+1
	jnc	hexnm1
hexnm2:
	dad	h
	dad	h
	dad	h
	dad	h
	ora	l
	mov	l,a
	ret
hexnm1:
	sui	'A'-'9'
	rc
	cpi	5+1
	cmc
	rc
	adi	10
	jmp	hexnm2

hexout:
	push	psw
	rrc
	rrc
	rrc
	rrc
	call	hexdig
	pop	psw
hexdig:
	call	tohex
prout:
	mov	e,a
	mvi	c,CONOUT
	jmp	BDOS

tohex:
	ani	0fh
	adi	90h
	daa
	aci	40h
	daa
	ret

wdays:	db	'Sun$Mon$Tue$Wed$Thu$Fri$Sat$'

; HL = CP/M Date-time field, w/o seconds
; Print date and time to console.
prdate:
	mov	e,m
	inx	h
	mov	d,m
	inx	h
	push	h
	push	d
	xchg
	call	weekdy
	add	a
	add	a	; *4
	mov	c,a
	mvi	b,0
	lxi	h,wdays
	dad	b
	xchg
	call	xitmsg
	mvi	a,' '
	call	prout
	pop	d
; compute year
	mvi	c,78	; base year, epoch, binary
	mvi	b,078h	; year, BCD
	; special-case date=0...
	mov	a,e
	ora	d
	jnz	prdat0
	inx	d
prdat0:
	lxi	h,365
	mov	a,c
	ani	03h	; Not strictly true, but works until year 2100...
	jnz	prdat1
	inx	h
prdat1:	push	h
	ora	a
	dsbc	d
	pop	h
	jnc	prdat2	; done computing year...
	xchg
	ora	a
	dsbc	d
	xchg
	inr	c
	mov	a,b
	adi	1
	daa
	mov	b,a
	jmp	prdat0
prdat2:	; DE = days within year 'C'
	push	b	; save (2-digit) year, B = BCD, C = binary (until 2155)
	lxi	h,month0+24
	mov	a,c
	ani	03h
	jnz	prdat3
	lxi	h,month1+24
prdat3:	; compute month, DE = days in year,HL = mon-yr-days table adj for leap
	mvi	b,12
prdat4:
	dcx	h
	dcx	h
	dcr	b
	jm	prdat5	; should never happen...
	push	h
	push	d
	mov	a,m
	inx	h
	mov	h,m
	mov	l,a
		; DE = days in year, HL = ytd[month]
	ora	a
	dsbc	d
	mov	a,l	; potential remainder (neg)
	pop	d
	pop	h
	jnc	prdat4
prdat5:	; B = month, 0-11; A = -dom
	neg
	push	psw
	inr	b
	mov	a,b
	call	decout
	mvi	e,'/'
	mvi	c,CONOUT
	call	BDOS
	pop	psw
	call	decout
	mvi	e,'/'
	mvi	c,CONOUT
	call	BDOS
	pop	b
	mov	a,b	; already BCD
	call	hexout
	mvi	e,' '
	mvi	c,CONOUT
	call	BDOS
	pop	h	; -> BCD hours
	mov	a,m
	inx	h
	push	h
	call	hexout
	mvi	e,':'
	mvi	c,CONOUT
	call	BDOS
	pop	h	; -> BCD minutes
	mov	a,m
	inx	h
	push	h
	call	hexout
	mvi	e,':'
	mvi	c,CONOUT
	call	BDOS
	pop	h	; -> BCD seconds
	mov	a,m
	jmp	hexout

;		J   F   M   A   M   J   J   A   S   O   N   D
month0:	dw	 0, 31, 59, 90,120,151,181,212,243,273,304,334
month1:	dw	 0, 31, 60, 91,121,152,182,213,244,274,305,335

start:
	mvi	c,GETVER
	call	BDOS
	shld	vers
	lxi	h,CMDLN
	mov	c,m
	inx	h
sid1:
	mov	a,m
	cpi	' '
	jnz	sid0
	inx	h
	dcr	c
	jnz	sid1
	jmp	start1 ; no params, use defaults

sid0:	; scan hex number as server ID
	xchg
	lxi	h,0
sid2:
	ldax	d
	inx	d
	call	hexnum
	jc	sid3
	dcr	c
	jnz	sid2
sid3:
	mov	a,l
	sta	gettime+1

start1:
	lhld	vers
	mvi	a,2	; bit for CP/Net
	ana	h
	jz	nocpnet

	lxi	d,gettime
	mvi	c,NSEND
	call	BDOS
	ora	a
	jnz	error
	lxi	d,gottime
	mvi	c,NRECV
	call	BDOS
	ora	a
	jnz	error
	jmp	shwtime

nocpnet:
	lda	NTWKIN
	cpi	0c9h	; RET
	jz	error2
	call	NTWKIN
	lxi	b, gettime
	call	SNDMSG
	ora	a
	jnz	error

	lxi	b, gottime
	call	RCVMSG
	ora	a
	jnz	error
shwtime:
	lxi	d,done
	mvi	c,PRINT
	call	BDOS
	lxi	h,gottime+5
	call	prdate
	ret

; From DATE.PLM: week$day = (word$value + base$day - 1) mod 7;
;                base$day  lit '0',
weekdy:	dcx	h	; 1/1/78 is "0" (Sun), -1 for offset
	lxi	d,7000
	ora	a
wd0:	dsbc	d
	jrnc	wd0
	dad	d
	lxi	d,700
	ora	a
wd1:	dsbc	d
	jrnc	wd1
	dad	d
	lxi	d,70
	ora	a
wd2:	dsbc	d
	jrnc	wd2
	dad	d
	lxi	d,7
	ora	a
wd3:	dsbc	d
	jrnc	wd3
	dad	d
	mov	a,l
	ret

error:
	lxi	d,errmsg
	jmp	xitmsg

error2:
	lxi	d,errcpn
;	jmp	xitmsg

xitmsg:
	mvi	c,PRINT
	call	BDOS
	ret

done:	db	'Remote Time is: $'
errmsg: db	7,'Error retrieving network time.$'
errcpn: db	7,'This program requires CP/NET.$'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SNIOS for H8-WIZ550io
;

wiz	equ	40h	; base port
wiz$dat	equ	wiz+0
wiz$ctl	equ	wiz+1
wiz$sta	equ	wiz+1

nsocks	equ	8

SCS	equ	1	; ctl port
BSY	equ	1	; sts port

sock0	equ	000$01$000b	; base pattern for Sn_ regs
txbuf0	equ	000$10$100b	; base pattern for Tx buffer
rxbuf0	equ	000$11$000b	; base pattern for Rx buffer

; common regs
ir	equ	21
sir	equ	23
pmagic	equ	29

; socket regs, relative
sn$cr	equ	1
sn$ir	equ	2
sn$sr	equ	3
sn$prt	equ	4
sn$txwr	equ	36
sn$rxrsr equ	38
sn$rxrd	equ	40

; socket commands
OPEN	equ	01h
CONNECT	equ	04h
CLOSE	equ	08h	; DISCONNECT, actually
SEND	equ	20h
RECV	equ	40h

; socket status
CLOSED	equ	00h
INIT	equ	13h
ESTAB	equ	17h

CFGTBL:	db	0	; status
	db	0	; our node ID

;	Network Status Byte Equates
;
active	equ	0001$0000b	; slave logged in on network
rcverr	equ	0000$0010b	; error in received message
senderr	equ	0000$0001b	; unable to send message

srvtbl:	ds	nsocks	; SID, per socket

cursok:	db	0	; current socket select patn
curptr:	dw	0	; into chip mem
msgptr:	dw	0
msglen:	dw	0
totlen:	dw	0

getwiz1:
	mvi	a,SCS
	out	wiz$ctl
	mvi	c,wiz$dat
	xra	a
	outp	a	; hi adr byte always 0
	outp	e
	res	2,d
	outp	d
	inp	a	; prime MISO
	inp	a
	push	psw
	xra	a
	out	wiz$ctl	; clear SCS
	pop	psw
	ret

putwiz1:
	push	psw
	mvi	a,SCS
	out	wiz$ctl
	mvi	c,wiz$dat
	xra	a
	outp	a	; hi adr byte always 0
	outp	e
	setb	2,d
	outp	d
	pop	psw
	outp	a	; data
	xra	a
	out	wiz$ctl	; clear SCS
	ret

; Get 16-bit value from chip
; Prereq: IDM_AR0 already set, auto-incr on
; Entry: A=value for IDM_AR1
; Return: HL=register pair contents
getwiz2:
	mvi	a,SCS
	out	wiz$ctl
	mvi	c,wiz$dat
	xra	a
	outp	a	; hi adr byte always 0
	outp	e
	res	2,d
	outp	d
	inp	h	; prime MISO
	inp	h	; data
	inp	l	; data
	; A still 00
	out	wiz$ctl	; clear SCS
	ret

; Put 16-bit value to chip
; Prereq: IDM_AR0 already set, auto-incr on
; Entry: A=value for IDM_AR1
;        HL=register pair contents
putwiz2:
	mvi	a,SCS
	out	wiz$ctl
	mvi	c,wiz$dat
	xra	a
	outp	a	; hi adr byte always 0
	outp	e
	setb	2,d
	outp	d
	outp	h	; data to write
	outp	l
	; A still 00
	out	wiz$ctl	; clear SCS
	ret

; Issue command, wait for complete
; D=Socket ctl byte
; Returns: A=Sn_SR
wizcmd:	mov	b,a
	mvi	e,sn$cr
	setb	2,d
	mvi	a,SCS
	out	wiz$ctl
	mvi	c,wiz$dat
	xra	a
	outp	a	; hi adr byte always 0
	outp	e
	outp	d
	outp	b	; command
	; A still 00
	out	wiz$ctl	; clear SCS
wc0:	call	getwiz1
	ora	a
	jrnz	wc0
	mvi	e,sn$sr
	call	getwiz1
	ret

; wait for socket state
; D=socket, C=bits (destroys B)
; returns A=Sn_IR - before any bits are reset
wizist:	lxi	h,32000
wst0:	push	b
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

; B=Server ID, preserves HL
; returns DE=socket base (if NC)
; ...do not open sockets...
getsrv:
	mvi	c,nsocks
	lxi	d,srvtbl
gs1:
	ldax	d
	cmp	b
	jrz	gs0
	inx	d
	dcr	c
	jrnz	gs1
	stc	; not found
	ret
gs0:	; found...
	mvi	a,nsocks
	sub	c	; socket num 00000sss
	rrc		; s00000ss
	rrc		; ss00000s
	rrc		; sss00000
	sta	cursok
	ori	sock0	; sss01000
	mov	d,a
	mvi	e,sn$sr
	call	getwiz1
	cpi	ESTAB
	rz
	stc	; failed to open
	ret

; HL=socket relative pointer (TX_WR)
; DE=length
; Returns: HL=msgptr, C=wiz$dat
cpsetup:
	mvi	a,SCS
	out	wiz$ctl
	mvi	c,wiz$dat
	outp	h
	outp	l
	lda	cursok
	ora	b
	outp	a
	lhld	msgptr
	ret

cpyout:
	mvi	b,txbuf0
	call	cpsetup
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
	xra	a
	out	wiz$ctl	; clear SCS
	ret

; HL=socket relative pointer (RX_RD)
; DE=length
; Destroys IDM_AR0, IDM_AR1
cpyin:
	mvi	b,rxbuf0
	call	cpsetup	;
	inp	a	; prime MISO
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
	xra	a
	out	wiz$ctl	; clear SCS
	ret

; L=bits to reset
; D=socket base
; Destroys C,E
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
	jmp	ntwkbt0	; load data

;	Send Message on Network
SNDMSG:			; BC = message addr
	sbcd	msgptr
	lixd	msgptr
	ldx	b,+1	; SID - destination
	call	getsrv
	jrc	serr
	; D=socket patn
	lda	CFGTBL+1
	stx	a,+2	; Set Slave ID in header
	ldx	a,+4	; msg siz (-1)
	adi	5+1	; hdr, +1 for (-1)
	mov	l,a
	mvi	a,0
	aci	0
	mov	h,a	; HL=msg length
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
	mvi	c,00011010b	; SEND_OK, DISCON, or TIMEOUT bit
	call	wizist
	cma	; want "0" on success
	ani	00010000b	; SEND_OK
	rz	; else TIMEOUT/DISCON
serr:	lda	CFGTBL
	ori	senderr
	sta	CFGTBL
	mvi	a,0ffh
	ret

; TODO: also check/OPEN sockets?
; That would result in all sockets always being open...
; At least check all, if none are ESTAB then error immediately
check:
	lxi	d,(sock0 shl 8) + sn$sr
	mvi	b,nsocks
chk2:	call	getwiz1
	cpi	ESTAB
	jrz	chk3
	mvi	a,001$00$000b
	add	d	; next socket
	mov	d,a
	djnz	chk2
	stc
	ret
chk3:	lxi	h,32000	; do check for sane receive time...
chk0:	mvi	d,sock0
	mvi	b,nsocks
	push	h
	mvi	l,00000100b	; RECV data available bit
chk1:	call	wizsts
	ana	l	; RECV data available
	jrnz	chk4	; D=socket
	mvi	a,001$00$000b
	add	d	; next socket
	mov	d,a
	djnz	chk1
	pop	h
	dcx	h
	mov	a,h
	ora	l
	jrnz	chk0
	stc
	ret
chk4:	pop	h
	ret

;	Receive Message from Network
RCVMSG:			; BC = message addr
	sbcd	msgptr
	lixd	msgptr
	call	check	; locates socket that is ready
	; D=socket
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

ntwkbt0:
	; load socket server IDs based on WIZ550io current config
	mvi	b,nsocks
	lxi	d,(sock0 shl 8) + sn$prt
	lxi	h,srvtbl
nb1:
	push	h
	call	getwiz2	; destroys C,HL
	mov	a,h
	cpi	31h
	mvi	a,0ffh
	jrnz	nb0
	mov	a,l	; server ID
nb0:	pop	h
	mov	m,a
	inx	h
	mvi	a,001$00$000b
	add	d	; next socket
	mov	d,a
	djnz	nb1
	xra	a
	ret

	end
