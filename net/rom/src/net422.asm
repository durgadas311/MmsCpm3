VERS1 set 86 ; February 9, 1983  15:58	drm  "NET422.ASM"
 if VERS1 gt VERS
VERS set VERS1
 endif

; All nodes have equal responsibilty, no Requestor/Server determination.

; Response$time * 14.75 (uS) = timeout for response.
response$time equ 102  ;1505 microseconds


CONTENTION:
	lxi	sp,stack
	call	LEDoff	;turn LEDs off.
	call	LEDred
start$net:
	mvi	a,00001000b
	sta	chAwr1	;interupt on first character of message.
	call	setrcv	;setup receiver
	lxi	h,eops
	res	0,m

*********************************************************
*  Server or Requestor or whatever (node)		*
*********************************************************
SERVER:
	lhld	deadct0
	shld	deadctr
sv0b:	call	unlatch ;
	jnz	sv1	;
sv0a:	mvi	b,40	;make loop 40 times as long...
sv0:	in	ctrl	;idle line detection.
	ani	IDLE	;	;flag "heard" yet ??
	jnz	sv1	;
	djnz	sv0	;to this point...450 uS

	call	chkeop	;Keep Host interface active...

	lhld	deadctr ;
	dcx	h	;
	shld	deadctr ;
	mov	a,h	;
	ora	l	;
	jnz	sv0a	; +15.5 = 465.5 uS, times HL... 238mS to 15 sec.
	lxi	h,stshdr+4
	res	4,m
	jmp	sv2a	;network is dead, assume TOKEN-0

sv1:	in	ctrl	;now wait for line to IDLE (message finished)
	ani	IDLE	; ; should "chkeop" be call here?
	jnz	sv1	; ;
	call	LATCH	;set IDLE latch.
;
; Process messages to/from Host.
;
	lda	Z89flg	;did the Host send us a message ?
	ora	a
	jz	hm0
	lda	ch2hdr	;what kind of message was it??
	ani	11110000b
	jm	hm2	;illegal message code from Host.
	jz	hm1	;
	cpi	70h	;Debug command
	jz	godbg
	cpi	60h	;Execute command
	jz	gldng
	cpi	30h	;status requests don't go out on network...
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
	lda	ch2hdr		;function code
	stx	a,CODE
	lda	ch2hdr+4	;destination
	stx	a,DEST
	lda	maddr
	stx	a,SORC
	lhld	ch2hdr+1
	lxi	d,DATA		; add in header
	dad	d		;
	shld	ch2siz
	mvi	a,true
	sta	outflg
	jmp	hm2

hm1:	mvi	a,true
	sta	stsflg
hm2:	mvi	a,false
	sta	Z89flg
	sta	ch2flg
	lxi	h,ch2hdr
	lxi	d,hdrsiz
	mvi	c,ch2ba
	call	setdma

hm0:	lda	cp89	;is ch3 to Host free??
	ora	a
	jnz	hm3
	lda	rspflg
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
	sta	cpnhdr+4
	ldx	a,CODE
	sta	cpnhdr
	lxi	d,0
	ani	11110000b
	jz	su0	;CP/NET messages require no further processing.
	cpi	10h	;Execute code
	jz	su1
	cpi	20h	;request for code.
	jz	su2





su2:	ldx	a,DATA
	sta	cpnhdr+3
	jmp	su0

su1:	ldx	a,CODE
	cpi	10h	;execute locally...
	jz	ldngo1
	mvi	e,2	;count 2 bytes that are the address for code.
	ldx	c,DATA
	ldx	b,DATA+1
	sbcd	cpnhdr+5
su0:
	lhld	altaddr
	dad	d
	lxi	b,DATA
	dad	b
	shld	ch3adr
	lxi	h,cpnhdr
	shld	ch3hda
	lhld	cpnhdr+1
	ora	a	;
	dsbc	d	;
	shld	cpnhdr+1
	shld	ch3siz
	mvi	a,true
	sta	cp89
	jmp	hm3

hm4:	lxi	h,rsphdr
	shld	ch3hda
	lxi	h,0
	shld	ch3siz
	mvi	a,true
	sta	cp89
	jmp	hm3
hm5:	lxi	h,stshdr
	shld	ch3hda
	lhld	stshdr+1
	shld	ch3siz
	lxi	h,net$table
	shld	ch3adr
	mvi	a,true
	sta	cp89

hm3:			;setup and start again....
	jmp	SERVER

godbg:	call	shut$down
	lxi	h,dbgm
	call	msgout
	jmp	debug

ldngo1: call	shut$down
	lhld	altaddr
	lxi	d,DATA
	dad	d
	mov	e,m	;address for code...
	inx	h
	mov	d,m
	push	d
	inx	h	;HL points to code in buffer
	lbcd	cpnhdr+1
	dcx	b
	dcx	b
	ldir	;move code to executable address
	ret	;jump to code.

gldng:	call	shut$down
	lhld	ch2hdr+5	;address for code
	push	h
	xchg
	lhld	ch2pri
	lbcd	ch2hdr+1	;length of code
	ldir
	ret	;go to code

shut$down:
	mvi	a,1
	out	cmdB
	lxi	h,chBwr1
	mov	a,m
	ani	00000100b
	mov	m,a
	out	cmdB	;all interupts off
	xra	a
	sta	chAwr1	;all chA interupts off
	lxi	h,null
	shld	TxEB
	shld	RxAB
	call	setrcv
	mvi	a,0
	jmp	setmask ;mask DMA channel 0

;*******************************************************************
;

RDRA:		;interupt on first character of message received.
	push	psw
	push	b
	push	d
	push	h
	pushix
	pushiy
rd0:	in	ctrl	;now wait for line to IDLE (message finished)
	ani	IDLE	;
	jnz	rd0	;
	mvi	a,1	;RR1 has EOF status (message completed)
	out	cmdA
	in	cmdA
	mov	h,a
	mvi	a,00110000b	;error reset
	out	cmdA
	mvi	a,0
	call	setmask ;shut off channel 0
	mvi	a,1
	out	cmdA
	lxi	h,chAwr1
	mov	a,m
	ani	11100111b
	mov	m,a
	out	cmdA	;shut off interupt on receiver.
	mvi	a,00111000b	;return-from-interupt, to turn off "special
	out	cmdA		;"receive condition" interupt pending.
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
	cpi	0ffh	;RESET
	jz	CONTENTION
	ani	11110000b
	jp	sv6	;pass message to interpreter.
	cpi	0e0h	;POLL
	jz	sv4	;send ACK and continue monitoring
	cpi	0d0h	;TOKEN0
	jz	sv5	;get net.table and do buss-master stuff

sv17:	call	LEDred	;;
	call	setrcv	;
;	jmp	xitmsg	;
xitmsg: di
	mvi	a,1
	out	cmdA
	lxi	h,chAwr1
	mov	a,m
	ori	00001000b
	mov	m,a
	out	cmdA	;turn interupt-on-first-char on.
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

sv2a:	lxi	h,RESmsg
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
	mvi	m,online
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
	mov	a,c			;
	cz	poll$node	;contention is checked here.

	call	findSERVER
	jm	sv2
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
	jnz	wm12
wm13:	in	ctrl
	ani	IDLE		;message on line??
	jnz	wm12
	dcx	d
	mov	a,d
	ora	e
	jnz	wm13
	stc
	jmp	LATCH	;setup "idle" latch again
wm12:	in	ctrl
	ani	IDLE
	jnz	wm12		;wait for message to finish.
	jmp	LATCH	;setup "idle" latch again


setup89:	;(IX)=(ch0addr)
	ldx	a,DEST	;check if message was global.
	sui	255
	sbb	a	;make bolean...00=global, FF=not-global.
	ani	1	;0=global, 1=not-global.
	mov	b,a
	lda	cpnflg	;is a message still waiting for z89?
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
	lxi	b,-(DATA+2)	;length of header + CRC bytes
	dad	b
	shld	cpnhdr+1

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
	lxi	h,ch2bf    ;
	call	send
	sta	rsphdr+3
	ora	a
	cnz	LEDred
	mvi	a,true
	sta	RSPflg
	mvi	a,false
	sta	outflg
	xra	a	;clear [CY]
	ret

s890:	stc
	ret

chkeop: lxi	h,eops
	in	dmastat
	ani	1111b
	ora	m
	mov	m,a
	bit	2,a	;did channel 2 EOP ?
	jz	ce0
	lda	ch2flg	;was it the header that just finished ?
	ora	a
	jnz	ce3
	mvi	a,true
	sta	ch2flg
	lhld	ch2alt
	lxi	d,DATA	;setup CP/NET message
	dad	d
	lded	ch2siz
	mvi	c,ch2ba
	call	setdma
	mvi	a,2
	out	mask
	lxi	h,eops
	res	2,m
	jmp	ce0
ce3:			;we just finish receiving a message from Z89.
	mvi	a,true
	sta	Z89flg
	mvi	a,false
	sta	ch2flg
ce0:	bit	3,m	;did channel 3 EOP ?
	jz	ce1
	lda	ch3flg	;was it the header that just went out ?
	ora	a
	jz	ce12
	cma
	sta	ch3flg	;indicate that the header has been taken.
	mvi	a,false
	sta	cp89
	lded	ch3siz
	mov	a,e
	ora	d
	jz	ce1
	lhld	ch3adr
ce8:	mvi	c,ch3ba
	call	setdma
	mvi	a,3
	out	mask
	lxi	h,eops
	res	3,m
ce1:	mov	a,m
	ret

ce12:	lda	cp89
	ora	a
	jz	ce1
	mvi	a,true
	sta	ch3flg
	lhld	ch3hda
	lxi	d,hdrsiz
	jmp	ce8


setdma: out	clrBP
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
	out	Adat	;send first character		;
	xra	a					; 5
	out	mask	;un mask DMA			;12=17=4.25 usec.
	out	cmdA	;send 0 to select wr0
	mvi	a,11000000b
	out	cmdA	;send reset TxU command <-------;this MUST occure
	lxi	h,eops		;			;before the last byte!
	res	0,m		;
se0:	call	chkeop		;wait for transmission to complete.
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
	add	a	;multiply by 2
se4:	dcr	a	;wait 2 character times (16 ones)
	jnz	se4
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
	sui	ACK
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
	bit	7,m	;is node off-line?
	rz		;don't give it a demerit then.
	inr	m	;count one demerrit.
	ret

gr1:	mvi	a,1
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
	cpi	0f2h	;printer-server busy
	jz	gr4
	sui	0f0h
	jz	gr2
	dcr	a
	mvi	a,2	;NAK received
	rz 
	mvi	a,5
	jmp	gr3	;if response wasn't ACK or NAK.

gr4:	ldx	a,DATA	;get node that caused BSY
	ori	10000000b	;differentiate it from error codes
gr2:	lxi	h,srvtbl
	dad	b
	mvi	m,online	;reset demerrit count to 0
	lxi	h,stshdr+4
	setb	4,m
	ret

setrcv:
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
	xra	a
	out	cmdA
	mvi	a,00110000b	;error reset
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
	cpi	online
	jz	fs1
fs3:	inx	h
	mov	a,c
	inr	a
	ani	00111111b	;MOD 64
	mov	c,a
	jnz	fs2
	xchg
fs2:	djnz	fs0
setnxs: lxi	h,srvtbl
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
	ori	100b	;set mask bit = 1
	mov	d,a
	lxi	b,(dmacomd)+(comd)*256	;command and port to re-enable DMA
	mvi	a,comd+100b	;command to disable DMA
	out	dmacomd ;the clock is ticking...lets finish as fast as possible
	mov	a,d
	out	mask	;mask the requested channel
	outp	b	;re-enable DMA. Elapsed time: 7.75 microseconds
	ret

*******************************************************************
**
*******************************************************************

printer$server:
;	ldx	c,DATA+SID
;	mvi	b,0
;	lxi	h,SEQtbl
;	dad	b
;	mov	a,m
;	inr	a
;	cmpx	DATA+SEQ
;	jnz	sv4	;give ACK but nothing more...????
;
	ldx	a,DATA+FNC	;get CP/NET function number
	cpi	05h	;list output function
	jnz	ps4	;ACK irrelevant functions to keep requestor happy.
	lxi	h,prtflg	;owner of the printer.
	mov	a,m
	cpi	255	;is printer un-owned?
	ldx	a,SORC
	jz	ps7
	cmp	m
	jnz	ps8
ps7:	mov	m,a	;mark current owner of printer.
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
	lxi	d,buffer
	ora	a
	dsbc	d	;compute index value
	shld	prtpt0	;set pointer
	di
	lxi	h,endlst	;see if the SIO needs to be re-started
	mov	a,m
	mvi	m,0
	ora	a
	cnz	chBTxE
	ei
	mvi	a,-10
	sta	retry	;flag response message when TOKEN comes around.
	jmp	sv4	;acknowledge message

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
	mviy	01h,DATA+FMT	;FMT=01
	mviy	01h,CODE	;
	mviy	1,DATA+SIZ	;SIZ=2 bytes
	mviy	0,DATA+MSG	;
	mviy	0,DATA+MSG+1	;MSG=0000
	lda	maddr		;put our address as source
	sty	a,SORC		;
	sty	a,DATA+SID	;
;	mvi	b,0		;node address is still in (C).
;	lxi	h,SEQtbl
;	dad	b		;
;	inr	m		;
;	mov	a,m		;
;	sty	a,DATA+SEQ	;
	mvi	a,-10
	sta	retflg
	jmp	sv4		;ACK message

****************************************************************************

PAKsend:
	lda	retry	;has message been sent successfully ?
	ora	a	; (or have we given up trying?)
	jz	s890a	;then we have nothing to send
ps1:	lxi	h,PAKmsg
	lxi	d,9
	call	send
	ora	a	;success?
	jz	ps2
	lxi	h,retry
	inr	m
	ret		;A=error code

ps2:	sta	retry	;zero retry counter.
	ret		;return A=0

s890a:	lda	retflg
	ora	a
	jz	s890
	lxi	h,RETmsg
	lxi	d,10
	call	send
	ora	a
	jz	s890b
	lxi	h,retflg
	inr	m
	ret

s890b:	sta	retflg
	ret

****************************************************************************

chr1st: push	psw
	push	h
	push	d
	push	b
	in	Bdat
	ani	7fh
	cpi	cr
	jnz	err
	lxi	h,chr2nd
	shld	RxAB
	lxi	h,mms
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
	jmp	smsg0
smsg1:	res	7,b	;mod 32K
	sbcd	prtpt0
	lxi	h,endlst
	mov	a,m
	mvi	m,0
	ora	a
	cnz	chBTxE
smxit:	pop	b
	pop	d
	pop	h
	pop	psw
	ei
	reti

chr2nd: push	psw
	push	h
	push	d
	push	b
	in	Bdat
	ani	5fh	;convert to upper case, strip off parity.
	cpi	'D'
	jz	godbg
	cpi	'B'
	jnz	err
	lxi	h,chr3rd
	shld	RxAB
	lxi	h,boot
	jmp	smsg

chr3rd: push	psw
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
	jmp	smsg

chr4th: push	psw
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
	lbcd	prtpt0
	lxi	h,buffer
	dad	b
	mov	m,a
	inx	b
	jmp	smsg1

bootn:	mvi	a,'0'
	jmp	xboot

chr5th: push	psw
	push	h
	push	d
	push	b
	in	Bdat
	ani	7fh
	cpi	cr
	jnz	err
	lda	pflag
xboot:	sui	'0'
	sta	ch2hdr+4	;destination
	lhld	ch2pri
	mvi	m,0	;device code 0, 77422 board
	mvi	a,true
	sta	Z89flg	;flag message ready (pretend we just received it from)
	mvi	a,20h	;		    (host			     )
	sta	ch2hdr	;command: boot
	lxi	h,1
	shld	ch2hdr+1
	jmp	smxit

err:	xra	a
	sta	pflag
	lxi	h,chr1st
	shld	RxAB
	lxi	h,errm
	jmp	smsg

mms:	db	cr,lf,' MMS-net: ',253
boot:	db	'Boot ',253
nm:	db	'NN-',253
errm:	db	cr,lf,bel,'?',253
dbgm:	db	'Debug',0


LEDred: mvi	a,RED
	jmp	LEDxon

LEDgrn: mvi	a,GREEN
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

xsft:	ret		;software interupt null routine

rstB:	exaf
	mvi	a,00110000b
	out	cmdB
	exaf
null:	ei		;do-nothing interupt handler
	reti

tic:	out	0e0h	;turn interupt off
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
	mvi	a,254
	jz	bf0
	lxi	h,buffer	;base address of buffer
	dad	d
	inx	d
	res	7,d	;mod 32K, 32K buffer
	sded	prtpt1
	mov	a,m
	cpi	255	;end of file?
	jnz	bf1
	sded	prtpt0	;stop further output.
	sta	prtflg	;free printer.
	mvi	a,ffeed ;separate print-out from possible subsequent printout.
bf1:	out	Bdat	;send to SIO
	exx
	exaf
	ei
	reti		; xx.x microseconds, this path.

bf0:	sta	endlst
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
	dw	rdrA	;channel A RCA	(triggers message handler)
	dw	null	;spcl rcv (error conditions)
	dw	null	; ;Not used, Cannot occur
	dw	null	; ;
	dw	null	; ;
	dw	null	; ;
	dw	null	; ;
	dw	null	; ;
	dw	null	; ;
	dw	tic	;tic from host

vecsft: jmp	xsft	; RST 1
	jmp	xsft	; RST 2
	jmp	xsft	; RST 3
	jmp	xsft	; RST 4
	jmp	xsft	; RST 5
	jmp	xsft	; RST 6
	jmp	xsft	; RST 7
	jmp	xsft	; NMI	(not usable)


;------- end of NET422.ASM ----------
