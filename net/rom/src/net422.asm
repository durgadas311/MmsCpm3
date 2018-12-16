VERS1 set 35 ; (Dec 14, 2018 21:34) drm  "NET422.ASM"
 if VERS1 gt VERS
VERS set VERS1
 endif

; All nodes have equal responsibilty, no Requestor/Server determination.

; Response$time * 14.75 (uS) = timeout for response.
response$time equ 102  ;1505 microseconds

start$net:
	di
	mvi	a,00001000b
	sta	chAwr1	;interupt on first character of message.
	call	setrcv	;setup receiver
	ei

*********************************************************
*  Server or Requestor or whatever (node)		*
*********************************************************
SERVER:
	lhld	deadct0
	shld	deadctr
	in	ctrl
	ani	IDLE
	mov	c,a
sv0a:
	mvi	b,10
sv0b:
	push	b
	call	chkeop	;Keep Host interface active...
	pop	b
	in	ctrl	;idle line detection.
	ani	IDLE	;	;flag "heard" yet ??
	cmp	c
	jnz	SERVER
	djnz	sv0b	;to this point...450 uS
	di
	lhld	deadctr	;
	dcx	h	;
	shld	deadctr	;
	ei
	mov	a,h	;
	ora	l	;
	jnz	sv0a	; +15.5 = 465.5 uS, times HL... 238mS to 15 sec.
	lxi	h,stshdr+ZDE+1
	res	4,m
	call	sv2a	;network is dead, assume TOKEN-0
	jmp	SERVER

chkeop:
	lda	dbgflg
	ora	a
	cnz	debug
	lxi	h,eops
	di
	in	dmastat
	ani	1111b
	ora	m
	mov	m,a
	ei
	ani	0100b	;did channel 2 EOP ?
	jz	ce0
	lda	from89
	ora	a
	jz	ce3
	mvi	a,false
	sta	from89
	lda	ch2hdr+ZCODE
	ani	11111100b
	cpi	EXEC
	lhld	ch2hdr+ZHL
	jz	ce4
	lhld	ch2pri
	lxi	d,DATA	;setup CP/NET message
	dad	d
ce4:	lded	ch2hdr+ZBC
	mov	a,d
	ora	e
	jz	ce3
	mvi	c,ch2ba
	di
	call	setdma
	mvi	a,2
	out	mask
	lxi	h,eops
	res	2,m
	ei
	jmp	ce0
ce3:			;we just finish receiving a message from Z89.
	lda	ch2hdr+ZCODE	;what kind of message was it??
	ani	11110000b
	jm	hm2	;illegal message code from Host.
	cpi	GDBG
	jz	godbg
	cpi	EXEC
	jz	gldng
	cpi	NSTS
	jz	hm1
	di		;swap buffers to save message untill we have a chance
	lhld	ch2pri	;to send it out.
	xchg		;
	lhld	ch2alt	;
	shld	ch2pri	;
	xchg		;
	shld	ch2alt	;valid message
	mvi	a,false
	sta	outflg
	ei
	lixd	ch2alt
	lda	maddr
	stx	a,SORC
	lda	ch2hdr+ZCODE	;function code
	stx	a,CODE
	lda	ch2hdr+ZDE+1	;destination
	stx	a,DEST
	lhld	ch2hdr+ZBC
	lxi	d,DATA		; add in header
	dad	d		;
	shld	ch2siz
	mvi	a,true
	sta	outflg
	jmp	hm2

; Get network status.
; Local operation only, just return most recent token.
hm1:	mvi	a,true
	sta	stsflg
	lda	ch2hdr+ZDE+1	;set new node type?
	ani	00fh
	jz	hm2	; no, leave type alone
	rlc
	rlc
	rlc
	rlc
	sta	ntype
;	jmp	hm2

hm2:	mvi	a,true
	sta	from89
	lxi	h,ch2hdr
	lxi	d,hdrsiz
	mvi	c,ch2ba
	di
	call	setdma
	mvi	a,2
	out	mask
	lxi	h,eops
	res	2,m
	ei
ce0:	lxi	h,eops
	di
	in	dmastat
	ani	1111b
	ora	m
	mov	m,a
	ei
	ani	1000b
	jz	hm3
	lda	to89
	ora	a
	jz	ce1
	mvi	a,false
	sta	to89
	lded	ch3siz
	mov	a,e
	ora	d
	jz	ce1
	lhld	ch3adr
	mvi	c,ch3ba
	di
	call	setdma
	mvi	a,3
	out	mask
	lxi	h,eops
	res	3,m
	ei
	jmp	hm3

; End of transfer processing???
; if (didrsp) didrsp=false;
; else {
;	if (didsts) didsts=false;
;	else if (didalt) didalt=false;
; }
ce1:	lda	didrsp
	ora	a
	jz	ce1a
	mvi	a,false
	sta	didrsp
	jmp	ce1c
; if (didsts) didsts=false;
; else if (didalt) didalt=false;
ce1a:	lda	didsts
	ora	a
	jz	ce1b
	mvi	a,false
	sta	didsts
	jmp	ce1c
ce1b:	lda	didalt
	ora	a
	jz	ce1c
	mvi	a,false
	sta	didalt
ce1c:	lda	rspflg
	ora	a
	jnz	hm4
	lda	stsflg
	ora	a
	jnz	hm5
	lda	cpnflg
	ora	a
	jz	hm3

	lixd	altaddr
	ldx	a,SORC
	sta	cpnhdr+ZDE+1
	ldx	a,CODE
	sta	cpnhdr+ZCODE
	lhld	altaddr
	lxi	b,DATA
	dad	b
	shld	ch3adr
	lxix	cpnhdr
	mvi	a,true
	sta	didalt
	mvi	a,false
	sta	cpnflg
	jmp	hm6

hm4:	lxix	rsphdr
	mvi	a,true
	sta	didrsp
	mvi	a,false
	sta	rspflg
	jmp	hm6

hm5:	lxix	stshdr
	lxi	h,nxt$sp
	shld	ch3adr
	mvi	a,true
	sta	didsts
	mvi	a,false
	sta	stsflg
;	jmp	hm6

hm6:	sixd	ch3hda
	ldx	e,ZBC
	ldx	d,ZBC+1
	lxi	h,1
	ora	a
	dsbc	d
	jnz	hm7
	inx	d
	stx	e,ZBC
	stx	d,ZBC+1
hm7:	sded	ch3siz
	mvi	a,true
	sta	to89
	lhld	ch3hda
	lxi	d,hdrsiz
	mvi	c,ch3ba
	di
	call	setdma
	mvi	a,0011b
	out	mask
	lxi	h,eops
	res	3,m
	ei
hm3:	lda	cpnflg
	ora	a
	rz
	lixd	altaddr
	ldx	a,CODE
	cpi	NBOOT
	jz	btfail
	ani	11110001b
	cpi	EXE422
	jz	ldngo1
	ret

godbg:	lda	ch2hdr+ZCODE
	ani	1111b
	mov	c,a
	add	a
	add	c	; *3
	mov	l,a	;
	mvi	h,0	; HL=vector in page 0
	lbcd	ch2hdr+ZDE
	lded	ch2hdr+ZHL
	call	gohl
	jmp	hm2

	pop	h
	xthl
gohl:	pchl

btfail:	lxi	h,bootf
	di
	call	smsg
	ei
	mvi	a,false
	sta	cpnflg
	sta	didalt
	ret

bootf:	db	cr,lf,'Boot failed',0fdh

; Load/run code locally
ldngo1:	ldx	a,CODE
	lhld	altaddr
	lxi	d,DATA
	dad	d
	mov	e,m	;address for code...
	inx	h
	mov	d,m
	push	d	; possible RET (goto) address
	cpi	014h
	jz	lg2	; goto only, do not load
	inx	h	;HL points to code in buffer
	lbcd	cpnhdr+ZBC
	dcx	b
	dcx	b
	ldir
	cpi	012h	; load+goto
	jnz	lg2
	pop	d	; do not jump to code
lg2:	mvi	a,false
	sta	cpnflg
	sta	didalt
	ret

gldng:	lda	ch2hdr+ZCODE
	ani	00000011b
	jnz	hm2
	lhld	ch2hdr+ZHL
	call	gohl
	jmp	hm2	;if code returns cleany, keep going

;*******************************************************************
;

rstA:
	push	psw
	push	b
	push	d
	push	h
	pushix
	pushiy
	sspd	spcstk
	call	unlatch
	call	wait$r2
	lhld	deadct0
	shld	deadctr
	mvi	a,1
	out	cmdA
	in	cmdA
	mov	h,a
	mvi	a,00110000b
	out	cmdA
	mvi	a,0
	call	setmask
	mvi	a,038h
	out	cmdA
	mvi	a,1
	out	cmdA
	lda	chAwr1
	ani	11100111b
	sta	chAwr1
	out	cmdA
	ei
	lixd	ch0addr
	ldx	a,SORC	;destination of next message (response) is the source
	sta	destin	;of the message we just received.
	bit	6,h	;check for CRC error.
	jnz	sv17	;what if the error was the address field?? So we
			;should not respond to CRC errors. (let timeout do it)
	bit	5,h	;overrun - DMA failure.
	jnz	sv3	;;call LEDred

	call	LEDoff	;reset error indicator

	out	clrBP
	in	ch0wc
	mov	e,a
	in	ch0wc
	mov	d,a	;DE=channel 0 ending word-count
	lxi	h,bufsiz*256-1
	ora	a
	dsbc	d	;compute network length of message
	shld	ch0size
	ldx	a,CODE	;get code field
	cpi	RESET
	jz	CONTENTION
	cpi	POLL
	jz	sv4
	cpi	TOKEN
	jz	sv5
	ani	11110000b
	jp	sv6	;pass message to interpreter.

CONTENTION:
	call	LEDoff
sv17:	call	LEDred
sv17b:	call	setrcv
xitmsg:	call	unlatch
	di
	mvi	a,1
	out	cmdA
	lxi	h,chAwr1
	mov	a,m
	ori	00001000b
	mov	m,a
	out	cmdA	;turn interupt-on-first-char on.
	lspd	spcstk
	popiy
	popix
	pop	h
	pop	d
	pop	b
	pop	psw
	ei
	ret

sv3:	call	LEDred	;;
	call	sendNAK
	jmp	xitmsg

sv4:	call	sendACK
	jmp	xitmsg

ps8:	call	sendBSY
	jmp	xitmsg

sv6:	in	ctrl	;test jumper for "printer server"
	ani	10000000b
	jz	printer$server
	call	setup89 	;sends ACK, or NAK if Z89 full
	jmp	xitmsg

sv2a:	di
	push	psw
	push	b
	push	d
	push	h
	pushix
	pushiy
	sspd	spcstk
	call	unlatch
	lxi	h,chAwr5
	mvi	a,5
	out	cmdA
	mov	a,m
	ori	10001010b	; DTR, RTS, TxEna
	out	cmdA
	mvi	a,5
	out	cmdA
	mov	a,m
	ori	10000010b	; DTR, RTS (TxDis)
	out	cmdA
	lda	ltime
	add	a
	add	a
sv2a0:	dcr	a
	jnz	sv2a0	; transmit some flag/sync chars
	mvi	a,5
	out	cmdA
	mov	a,m
	out	cmdA	; !DTR, !RTS, TxDis
	call	LATCH
	mvi	a,1
	out	cmdA
	lxi	h,chAwr1
	mov	a,m
	ani	11100111b
	mov	m,a
	out	cmdA
	ei
	lxi	h,RESmsg
	lxi	d,3
	call	send
	jmp	sv2
sv5:			; TOKEN-0, we own the network...
	call	sendACK ;sets IDLE latch before returning...
	lhld	ch0addr ;set NET.TABLE and go...
	lxi	d,DATA
	dad	d
	lxi	d,net$table
	lxi	b,tk0ml-DATA
	ldir
	lxi	h,srvtbl
	lda	maddr
	mov	e,a
	mvi	d,0
	dad	d
	lda	ntype
	mov	m,a
sv2:	call	LEDgrn		;assume TOKEN-0
	call	send89	;contention is checked here...

	lda	nxt$sp			;Poll for new additions to network
	mov	c,a			;
	inr	a			;
	ani	00111111b		;
	sta	nxt$sp	;set next node to poll
	mvi	b,0			;
	lxi	h,srvtbl		;
	dad	b			;
	mov	a,m			;
	ani	11110000b		;
	jnz	sv21	; node is online
	mov	a,m
	inr	a
	ani	00001111b
	mov	m,a
	mov	a,c			;
	call	poll$node	;contention is checked here.

sv21:	call	findSERVER
	jm	sv22
	lxi	h,TOKEN0msg
	mov	m,a	;set DID
	lxi	d,tk0ml
	call	send	;contention is checked here.
	ora	a
	jnz	sv16	;keep TOKEN if anything went wrong...
	call	setnxs	;reset next-server pointer.
	call	LEDoff	;
	jmp	xitmsg	;

sv16:	call	LEDred
	jmp	sv2

sv22:	call	chkeop
	jmp	sv2

unlatch:
	in	ctrl	;save currently latched state of IDLE signal.
	ani	IDLE	;
	push	psw	;
	lxi	h,ctl$image	;Allow IDLE bit to follow network status
	mov	a,m		;
	ani	not ILAT	;
	mov	m,a		;
	out	ctrl		;
	pop	psw	;return previously latched state
	ret		;

wait$r: lxi	d,response$time ;counter of "how long to wait".
	call	unlatch
	jnz	wait$r2
wm13:	in	ctrl
	ani	IDLE		;message on line??
	jnz	wait$r2
	dcx	d
	mov	a,d
	ora	e
	jnz	wm13
	stc
	jmp	LATCH	;setup "idle" latch again

wait$r2:
	lxi	d,33
wm12:	in	ctrl
	ani	IDLE
	jz	LATCH
	dcx	d
	mov	a,d
	ora	e
	jnz	wm12		;wait for message to finish.
	stc
	jmp	LATCH	;setup "idle" latch again


setup89:	;(IX)=(ch0addr)
	ldx	a,DEST	;check if message was global.
	sui	255
	sbb	a	;make bolean...00=global, FF=not-global.
	ani	1	;0=global, 1=not-global.
	mov	b,a
	lda	cpnflg	;is a message still waiting for z89?
	lxi	h,didalt
	ora	m
	cma
	ani	0010b	;0=overrun, 2=o.k.
			;(B)=global flag, 0/1
	ora	b	;0=overrun and global,
	jz	setrcv	;don't respond to global messages.
	dcr	a	;1=overrun and not global (send NAK)
	jz	sendNAK 	;don't overrun z89
	lhld	ch0addr 	;"sendACK" will setup receiver to (ch0addr)
	xchg			;so we must save our message in (altaddr) to
	lhld	altaddr 	;prevent it from being overwritten by TOKEN0.
	shld	ch0addr 	;	(or whatever)
	xchg			;
	shld	altaddr 	;
	dcr	a	;2=o.k. but global (no response)
	push	psw
	cz	setrcv
	pop	psw
	cnz	sendACK 	;sets up receiver. uses (ch0addr)
	lhld	ch0size
	lxi	b,-(DATA+1)	;length of header + CRC bytes
	dad	b
	shld	cpnhdr+ZBC

	mvi	a,true
	sta	cpnflg
	ret

send89:
	in	ctrl
	ani	10000000b
	jz	PAKsend
	lda	outflg	;see if there is a message ready to go out.
	ora	a
	jz	s890	;flag if there are no messages
	lhld	ch2alt
	lded	ch2siz
	call	send
	sta	rsphdr+ZDE	; status of send
	lxi	h,rspflg
	mvi	m,true
	lxi	h,outflg
	mvi	m,false
	ora	a
	rz	; no error
	rm	; busy
	cpi	2	; NAK
	rz
	jmp	LEDred

s890:	stc
	ret


setdma:	out	clrBP
	outp	l
	outp	h
	inr	c
	dcx	d
	outp	e
	outp	d
	ret

sendBSY:
	lda	prtflg
	sta	BSYmsg+DATA
	lxi	h,BSYmsg
	lxi	d,4
	jmp	sn1

sendACK:
	lxi	h,ACKmsg
	jmp	sn0

sendNAK:
	lxi	h,NAKmsg
sn0:	lxi	d,3
sn1:	lda	destin
	mov	m,a
;	jmp	send
;
send:	in	ctrl
	ani	IDLE
	jnz	CONTENTION	;error: network is not idle (it should be)
	push	h
	push	d
	lxi	h,ctl$image	;un-latch IDLE signal during transmit so we
	mov	a,m		;don't see our own transmission as "contention"
	ani	not ILAT
	mov	m,a
	out	ctrl
	mvi	a,3
	out	cmdA
	lxi	h,chAwr3
	mvi	a,11111110b	;disable receiver
	ana	m
	mov	m,a
	out	cmdA
	mvi	a,0
	call	setmask 	;shut off DMA
	mvi	a,1
	out	cmdA
	lxi	h,chAwr1
	mov	a,m
	ani	00011111b
	ori	11000000b	;set RDY to Tx mode
	mov	m,a
	out	cmdA
	mvi	a,5
	out	cmdA
	lxi	h,chAwr5
	mov	a,m
	ori	10001010b	;Tx Enable, RTS/DTR on
	mov	m,a
	out	cmdA		;transmitter starts sending flags...
	xra	a		;
	out	cmdA		;
	mvi	a,10000000b	;reset Tx CRC generater
	out	cmdA		;
	lda	ltime		;
se3:	dcr	a		;
	jnz	se3		;
	pop	d		;
	pop	h		;
	mov	a,m	;first character to be sent...Destination I.D.
	inx	h		;
	dcx	d		;
	mov	b,m	;save message code.
	mov	c,a	;and destination (may be global - "FF")
	push	b	;---save on stack.
	mvi	c,ch0ba 	;
	push	psw		;
	mvi	a,010010$00b	;DMA send mode
	out	mode		;
	call	setdma		;
	pop	psw		;
	di
	out	Adat	;send first character		;
	xra	a					; 5
	out	mask	;un mask DMA			;12=17=4.25 usec.
	out	cmdA	;send 0 to select wr0
	mvi	a,11000000b
	out	cmdA	;send reset TxU command <-------;this MUST occure
	ei
	lxi	h,eops		;			;before the last byte!
	res	0,m		;
se0:	in	dmastat		;wait for transmission to complete.
	ani	1111b
	ora	m
	mov	m,a
	ani	0001b
	jz	se0
	mvi	b,8	;EOP preceeds last flag by 4 characters, + 4 flags.
se1:	lda	ltime
se2:	dcr	a	;wait untill a few flags have been sent...
	jnz	se2
	djnz	se1
	mvi	a,5
	out	cmdA
	lxi	h,chAwr5
	mov	a,m
	ani	11110111b	;disable Tx, starts TxD marking.
	mov	m,a
	out	cmdA
	lda	ltime
	add	a
	add	a
se4:	dcr	a
	jnz	se4	; drain Tx?
	pop	b	;restore message code and destination.
	call	getresponse	;(does NOT set IDLE latch.)
	push	psw
	call	setrcv
	pop	psw
LATCH:	push	psw	;save response status (or zero)
	lxi	h,ctl$image
	mov	a,m
	ori	ILAT
	mov	m,a
	out	ctrl	;setup IDLE detection again
	pop	psw	;this is the byte to send back to Z89
	ret

getresponse:	;(B) must have the code of the previously sent message.
	mov	a,b	;and (C) must have the destination address.
	sui	ACK	; base code for confirmations
	ani	11110000b	;ACK-type messagess get no response.
	rz
	mov	a,c	;see if message is "global"
	sui	255
	rz		;if it is, it does not get a response.
	mvi	b,0	;(BC)=16 bit node address (0-63)
	push	b
	call	setrcv
	call	wait$r
	pop	b
	jnc	gr1
	mvi	a,1	;timout error code
gr3:	lxi	h,srvtbl
	dad	b
	mov	b,a
	mov	a,m
	ani	11110000b
	mov	c,a
	mov	a,b
	rz
	mov	a,m
	inr	a
	ani	00001111b
	jz	gr6
	ora	c
gr6:	mov	m,a
	mov	a,b
	ret

gr1:	mvi	a,1	; BC=node address
	out	cmdA
	in	cmdA
	mov	h,a
	bit	7,h	;EOF means message was for us.
	mvi	a,4	;code for "response was not for us"
	jz	gr3	;if message was not for us, assume timeout.
	mov	a,h
	ani	01100000b	;CRC error or DMA failure.
	mvi	a,3	;CRC error code
	rnz
	lixd	ch0addr
	ldx	a,CODE
	cpi	BSY	;printer-server busy
	jz	gr4
	sui	ACK	;0=succes (ACK)
	jz	gr2	;update net.table
	dcr	a
	mvi	a,2	;NAK received
	rz
	mvi	a,5	;protocol error,
	jmp	gr3	;if response wasn't ACK or NAK.

gr4:	ldx	a,DATA	;get node that caused BSY
	ori	10000000b	;differentiate it from error codes
gr2:	lxi	h,srvtbl
	dad	b
	mov	b,a
	; A node might have been polled, come online, and received the token
	; since we last had the token, so our net.table might be out of date.
	; adjust our copy of net.table, until we get the token again.
	mov	a,m
	ani	11110000b
	jnz	gr5
	mvi	a,TUNK	;node was not online, reset demerrit count to 0
gr5:	mov	m,a
	mov	a,b
	lxi	h,stshdr+ZDE+1
	setb	4,m
	ret

setrcv:
	xra	a
	out	cmdA
	mvi	a,5
	out	cmdA
	lxi	h,chAwr5
	mov	a,m
	ani	01110101b	;TX disable, RTS/DTR off
	mov	m,a
	out	cmdA
	mvi	a,0
	call	setmask ;shut off DMA channel 0.
	mvi	a,010001$00b	;receive mode
	out	mode
	lhld	ch0addr
	lxi	d,bufsiz*256
	mvi	c,ch0ba
	call	setdma		;setup DMA to receive from network
	mvi	a,00110000b
	out	cmdA
	mvi	a,1	;wr1: setup RDY signal
	out	cmdA
	lxi	h,chAwr1
	mvi	a,11100000b	;READY (DREQ) on receive characters
	ora	m
	mov	m,a
	out	cmdA
	mvi	a,3	;wr3: Startup receiver
	out	cmdA
	lxi	h,chAwr3
	mvi	a,00010101b	;Enable, Enter Hunt Phase, Address Search.
	ora	m
	mov	m,a
	out	cmdA
	mvi	a,0
	out	mask	;un-mask DMA channel 0
	ret

findSERVER:
	lhld	nxsrva
	lda	nxsrvn	;0-63, excl ourself
	lxi	d,srvtbl
	mvi	b,64+1
	mov	c,a
	jmp	fs3
fs0:	mov	a,m
	ani	11110000b	;strip off counter
	jnz	fs1
fs3:	inx	h
	mov	a,c
	inr	a
	ani	00111111b	;MOD 64
	mov	c,a
	jnz	fs2
	xchg
fs2:	djnz	fs0
setnxs:	lxi	h,srvtbl
	lda	maddr
	mov	c,a
	mvi	b,0
	dad	b
	shld	nxsrva
	sta	nxsrvn
	dcr	b	;signal no other SERVERs with [MI]
	ret

fs1:	lda	maddr
	cmp	c
	jz	fs3
	mov	a,c
	ora	a	;signal active SERVER by [PL]
	shld	nxsrva
	sta	nxsrvn
	ret

poll$node:
	lxi	h,POLLmsg
	mov	m,a
	lxi	d,3
	call	send	;"send" updates node table.
	cpi	2
	rc
	jmp	LEDred

setmask:
	di
	ori	100b	;set mask bit = 1
	mov	d,a
	lxi	b,(dmacomd)+(comd)*256	;command and port to re-enable DMA
	mvi	a,comd+100b	;command to disable DMA
	out	dmacomd ;the clock is ticking...lets finish as fast as possible
	mov	a,d
	out	mask	;mask the requested channel
	outp	b	;re-enable DMA. Elapsed time: 7.75 microseconds
	ei
	ret

*******************************************************************
**
*******************************************************************

printer$server:
	ldx	c,DATA+SID
	mvi	b,0
	mov	a,c
	cpi	255
	jz	sv17b
	ldx	a,CODE
	cpi	CPNET
	jnz	sv4
	mov	a,c
	cpi	64
	jnc	ps9
	lxi	h,SEQtbl
	dad	b
	bitx	7,DATA+SEQ
	jz	ps6
	mov	a,m
	xorx	DATA+SEQ
	ani	00fh
	jz	sv4
ps6:	ldx	a,DATA+SEQ
	ani	00001111b
	mov	b,a
	mov	a,m
	ani	11110000b
	ora	b
	mov	m,a
ps9:	ldx	a,DATA+FNC	;get CP/NET function number
	cpi	05h	;list output function
	jnz	ps4	;ACK irrelevant functions to keep requestor happy.
	lxi	h,prtflg	;owner of the printer.
	mov	a,m
	cpi	255	;is printer un-owned?
	ldx	a,SORC
	jz	ps10
	cmp	m
	jnz	ps8	; someone else
ps10:	mov	m,a	;mark current owner of printer.
	sta	PAKmsg+DEST	;
	sta	PAKmsg+DATA+DID ;set CP/NET DID
;
; NOTE: we only have one printer, so we will ignore the "Server list device #"
;
	ldx	e,DATA+SIZ	;CP/NET SIZ field
	mvi	d,0		;DE = length of buffer
	lhld	ch0addr
	lxi	b,DATA+MSG+1
	dad	b	;point to actual data for printer.
	push	h
;------- message setup routine for circular buffer
; DE=length of data to be output.
	lhld	prtpt1	;output pointer
	lbcd	prtpt0	;input pointer
	ora	a
	dsbc	b
	jz	cb2	;buffer is empty, 256 byte message can't overflow.
	res	7,h	; assuming 32K buffer
	dsbc	d	;compare to space needed
	jc	ps8	;if not enough space, send BSY response.
cb2:	lxi	h,32*1024		; (BC=input pointer)
	dsbc	b	;HL=bytes untill wrap point
	push	h	;
	dsbc	d	;HL=
	jnc	cb0	;
	mov	a,h
	cma
	mov	h,a
	mov	a,l
	cma
	mov	l,a
	inx	h	;negate HL
	xchg		;DE=bytes in 2nd move.
	lxi	h,buffer
	dad	b	;HL=start address to move to.
	pop	b	;BC=bytes in 1st move.
	xchg		;HL=bytes in 2nd move, DE=dest.address for 1st move.
	xthl		;HL=message buffer address
	call	memtomem	;move data
	lxi	b,0	;BC=0=index to start of buffer (wrap-around)
	pop	d	;DE=number of bytes
	push	h	;TOS=message buffer address (cont.)
	jmp	cb1

cb0:	pop	h	;DE=bytes to move, BC=index to start move
cb1:	lxi	h,buffer
	dad	b	;start address
	mov	c,e
	mov	b,d
	pop	d	;DE=message buffer address, data to output.
	xchg
	call	memtomem	;move data to circular buffer
	xchg
	dcx	h
	mov	a,m
	cpi	255
	jnz	cb3
	sta	prtflg
	dcx	h
	mov	a,m
	cpi	254
	jz	cb4
	inx	h
	mvi	m,ffeed
cb3:	inx	h
cb4:	lxi	d,buffer
	ora	a
	dsbc	d	;compute index value
	res	7,h
	shld	prtpt0	;set pointer
	di
	lxi	h,endlst	;see if the SIO needs to be re-started
	mov	a,m
	mvi	m,0
	ora	a
	cnz	chBTxE
	ei
	lxiy	PAKmsg
	lxi	d,retry
	ldy	c,DEST
	jmp	ps5

memtomem:	;memory-to-memory DMA block move.
	mvi	a,100001$00b	;
	out	mode	;set ch0 to block mode
	inr	a
	out	mode	;and ch1 to block mode
	mvi	a,comd+01b	;select memory-to-memory, address change.
	out	dmacomd
	push	d	;destination address
	push	b	;length of transfer
	mov	e,c
	mov	d,b	;length in DE
	mvi	c,ch0ba ;(source address in HL)
	call	setdma	;setup ch0
	inx	d	;"setdma" does a DCX D
	dad	d	;point to end of source buffer
	pop	d	;length in DE
	xthl		;destination in HL (save end of source buffer)
	mvi	c,ch1ba ;
	call	setdma	;setup ch1
	inx	d	;
	dad	d	;point to end of destination
	mvi	a,100b
	out	dreq	;start transfer. we will have control when finished.
	xchg
	pop	h
	ret		;transfer completed

ps4:			;build return frame to satisfy CP/NET.
	lda	retflg
	ora	a
	jnz	sv3	;NAK if we can't handle this many messages
	lxiy	RETmsg
	ldx	a,DATA+FNC	;
	sty	a,DATA+FNC	;same function number
	ldx	c,SORC		;send to source of this message.
	sty	c,DEST		;NOTE: node address is transfered in (C)
	sty	a,DATA+DID	;
	mviy	01h,DATA+FMT	;FMT=01, CP/NET response
	mviy	01h,CODE	;
	mviy	1,DATA+SIZ	;SIZ=2 bytes
	mviy	0,DATA+MSG	;
	mviy	0,DATA+MSG+1	;MSG=0000
	lda	maddr		;put our address as source
	sty	a,SORC		;
	sty	a,DATA+SID	;
	lxi	d,retflg
ps5:	mvi	b,0		;node address is still in (C).
	lxi	h,SEQtbl
	dad	b		;
	mov	a,m		;
	rlc
	rlc
	rlc
	rlc
	ani	00001111b
	sty	a,DATA+SEQ	;
	mvi	a,010h
	add	m
	mov	m,a
	mvi	a,-10
	stax	d
	jmp	sv4		;ACK message

****************************************************************************

PAKsend:
	lxi	b,retry	;has message been sent successfully ?
	ldax	b
	ora	a	; (or have we given up trying?)
	jz	s890a	;then we have nothing to send
	lxi	h,PAKmsg
	lxi	d,9
ps3:	push	b
	push	h
	call	send
	popix
	setx	7,DATA+SEQ
	pop	h
	ora	a	;success?
	jz	ps2
	inr	m
	rnz		;A=error code
	push	psw
	mvi	a,true
	sta	prtflg
	mvi	a,ffeed
	di
	call	schr
	ei
	pop	psw
	ret		;A=error code

ps2:	mov	m,a	;zero retry counter.
	ret		;return A=0

s890a:	lxi	b,retflg
	ldax	b
	ora	a
	jz	s890
	lxi	h,RETmsg
	lxi	d,10
	jmp	ps3

chr1st:	push	psw
	push	h
	push	d
	push	b
	in	Bdat
	ani	7fh
	cpi	cr
	jnz	smxit
	lxi	h,chr2nd
	shld	RxAB
	lxi	h,mms
imsg:	call	smsg
smxit:	pop	b
	pop	d
	pop	h
	pop	psw
	ei
	reti

smsg:
	lbcd	prtpt0	;start where last message (if any) left off.
	lxi	d,buffer
	xchg
	dad	b
	xchg
smsg0:	mov	a,m
	cpi	253
	jz	smsg1
	stax	d
	inx	d
	inx	h
	inx	b
	bit	7,b
	jz	smsg0
	res	7,b	;mod 32K
	lxi	d,buffer
	jmp	smsg0

smsg1:	sbcd	prtpt0
	lxi	h,endlst
	mov	a,m
	mvi	m,0
	ora	a
	rz
	jmp	chBTxE

schr:	lbcd	prtpt0
	lxi	h,buffer
	dad	b
	mov	m,a
	inx	b
	res	7,b
	jmp	smsg1

chr2nd:	push	psw
	push	h
	push	d
	push	b
	in	Bdat
	ani	5fh	;convert to upper case, strip off parity.
	cpi	'D'
	jz	entdbg
	cpi	'B'
	jnz	err
	lxi	h,chr3rd
	shld	RxAB
	lxi	h,boot
	jmp	imsg

chr3rd:	push	psw
	push	h
	push	d
	push	b
	in	Bdat
	ani	5fh
	cpi	cr
	jz	bootn
	cpi	'N'
	jnz	err
	lxi	h,chr4th
	shld	RxAB
	lxi	h,nm
	jmp	imsg

chr4th:	push	psw
	push	h
	push	d
	push	b
	in	Bdat
	ani	7fh
	cpi	cr
	jz	bootn
	cpi	'0'
	jc	err
	cpi	'9'+1
	jnc	err
	lxi	h,chr5th
	shld	RxAB
	sta	pflag
cont:	call	schr
	jmp	smxit

bootn:	mvi	a,'0'
	jmp	xboot

chr5th:	push	psw
	push	h
	push	d
	push	b
	in	Bdat
	ani	7fh
	cpi	cr
	jnz	err
	lda	pflag
xboot:	push	psw
	mvi	a,2
	call	setmask
	pop	psw
	sui	'0'
	sta	ch2hdr+ZDE+1	;destination
	lhld	ch2pri
	lxi	d,DATA
	dad	d
	mvi	m,0	;device code 0, 77422 board
	lxi	h,eops
	setb	2,m
	mvi	a,RBOOT
	sta	ch2hdr+ZCODE	;command: boot
	lxi	h,1
	shld	ch2hdr+ZBC
	mvi	a,false
	sta	from89
	lxi	h,chr1st
	shld	RxAB
	mvi	a,cr
	jmp	cont

entdbg:
	mvi	a,true
	sta	dbgflg
	lxi	h,chr1st
	shld	RxAB
	mvi	a,'D'
	jmp	cont

err:	xra	a
	sta	pflag
	lxi	h,chr1st
	shld	RxAB
	lxi	h,errm
	jmp	imsg

mms:	db	cr,lf,' MMS-net: ',253
boot:	db	'Boot ',253
nm:	db	'NN-',253
errm:	db	cr,lf,bel,'?',253

LEDred:	mvi	a,RED
	jmp	LEDxon

LEDgrn:	mvi	a,GREEN
LEDxon: lxi	h,ctl$image
	ora	m
	mov	m,a
	out	ctrl
	ret

LEDoff: lxi	h,ctl$image
	mov	a,m
	ani	OFF		;RED+GREEN off
	mov	m,a
	out	ctrl
	ret

**********************************************************
** Interupt service.
**********************************************************

rstB:	exaf
	mvi	a,00110000b
	out	cmdB
	exaf
null:	ei		;do-nothing interupt handler
	reti

tic:	out	ch2rd	;turn interupt off
	ei
	reti

chBTxE:
;------- interupt routine for circular buffer ------------
	exx
	exaf
	lhld	prtpt0	;input pointer (into buffer)
	lded	prtpt1	;output pointer (out of buffer)
	ora	a
	dsbc	d
	jz	bf0
	lxi	h,buffer	;base address of buffer
	dad	d
	inx	d
	res	7,d	;mod 32K, 32K buffer
	sded	prtpt1
	mov	a,m
	out	Bdat	;send to SIO
	exx
	exaf
	ei
	reti		; xx.x microseconds, this path.

bf0:	mvi	a,254
	sta	endlst
	mvi	a,00101000b
	out	cmdB
	exx
	exaf
	ei
	reti

**********************************************************
** Data constants
**********************************************************

intvec: dw	chBTxE	;channel B TBE
	dw	null	;status: EOP, IV3, sync
	dw	chr1st	;channel B RCA
	dw	rstB	;spcl rcv
	dw	null	;channel A TBE	(handled by DMA)
	dw	null	;status   (error conditions TxU, ABORT)
	dw	null	;channel A RCA	(triggers message handler)
	dw	rstA	;spcl rcv (error conditions)
	dw	null	; ;Not used, Cannot occur
	dw	null	; ;
	dw	null	; ;
	dw	null	; ;
	dw	null	; ;
	dw	null	; ;
	dw	0	; ;
	dw	tic	;tic from host

;------- end of NET422.ASM ----------
