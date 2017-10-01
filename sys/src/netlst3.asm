VERS equ '3 ' ; October 5, 1983  15:37	mjm  "NETLST3.ASM"
	maclib	Z80

;*****************************************************
;**** CP/M 3.1 LST: module for network		 *****
;****  Copyright (C) 1983 Magnolia microsystems  *****
;*****************************************************

false	equ	0
true	equ	not false

cpm	equ	0

cr	equ	13
lf	equ	10
bell	equ	7

port	equ	0f2h

; Relative positions of message elements
SEQ	equ	0
FMT	equ	1
DID	equ	2
SID	equ	3
FNC	equ	4
SIZ	equ	5
MSG	equ	6	;message starts at frame+6

 extrn	bnkdos,wbtrap,@cbnk,?bnksl,?dvtbl

dev0	equ	204
ndev	equ	1

	cseg
	dw	thread
	db	dev0,ndev
	jmp	init
	jmp	inst
	jmp	input
	jmp	outst
	jmp	output
	dw	string
	dw	chrtbl
	dw	xmodes

string: db	'LST: ',0,'- on MMS-net ',0,'v3.10'
	dw	VERS
	db	'$'

serverID: db	5
	jmp	sendmsg
	jmp	netstat

xmodes: db	00000010b,0,0	;xmodes disabled
porta:	db	0	;part of "xmodes"

	ds	32
netstk: ds	0
usrstk: ds	2

sendmsg:
	mov	h,b
	mov	l,c
	lxi	d,msgbuf+FMT
	lxi	b,MSG+257-FMT
	ldir
	lxi	b,msgbuf+FMT
	lxi	h,sendmsg0
bnkcall:
	sspd	usrstk
	lxi	sp,netstk
	mvi	a,0
	call	?bnksl
	call	icall
	push	psw	;status of send
	mvi	a,1
	call	?bnksl
	pop	psw
	lspd	usrstk
	ret

netstat:
	lxi	h,Netsta-cnfgsz ;must be first instruction in routine.
	lxi	h,netstat0
	jr	bnkcall

icall:	pchl

rcvmsg: ds	1	;SEQ
	ds	1	;FMT
	ds	1	;DID
	ds	1	;SID
	ds	1	;FNC
	ds	1	;SIZ
	ds	257	;actual message

msgbuf: ds	MSG+257

Netsta: 		; ;normally appended to end of CNFGTB, but
maddr:	  db	0	; ;we need to make the common segment small.
nstat:	  db	0	; ;
sndsts:   db	0	; ;
srsts:	  db	0	; ; bit0=cpflag, bit1=mailflag, 2=sndsts, 3=netsts
rmsg:	  dw	rcvmsg	; ; address of buffer that contains the mail.
Nettbl:   ds	65	; ;

thread	equ	$

	dseg

errmsg: db	cr,lf,bell,'xmit error$'

chrtbl: db	'NETLST',0000$0010b,0	;can do output (no input).

init:	in	port
	mvi	c,07cH
	ani	11b
	cpi	11b
	jrz	re0
	mvi	c,078h
	in	port
	ani	1100b
	cpi	1100b
	jrz	re0
	mvi	c,40h
re0:	mov	a,c
	sta	porta
	xra	a
	sta	srsts
	sta	sndsts
	call	runout	;clear any characters stacked up in DMA buffer.
	lda	serverID
	sta	lstID+1
	lxi	h,bnkdos	;Patch BNKBDOS to give us access to
	lxi	d,04b7h 	; ctrl-P Off.
	dad	d
	lxi	b,ctrlP
	mvi	m,(JMP)
	inx	h
	mov	m,c
	inx	h
	mov	m,b
	lhld	wbtrap	;trap warm boots from BIOS
	lxi	d,warm$boot
	sded	wbtrap
	mov	a,h
	ora	l	;anybody else before us?
	jrz	ini0
	shld	chain0+1
	mvi	a,(JMP)
	sta	chain0
ini0:	call	nws
	lda	maddr	;node address
	sta	cnfgtb+1
	sta	sid1
	xra	a
	sta	bsyflg
	lxi	h,?dvtbl-36H	;move console jump vectors to local storage
	lxi	d,const
	lxi	b,9
	ldir
	jr	listoff

outst:
inst:	xra	a	;LST: device always ready.
	dcr	a
input:	ret	 

output:
	lda	lstmsg
	cpi	255
	jrnz	lo3
	xra	a
	sta	lstmsg
lo3:	lxi	h,lstbuf
	add	l
	mov	l,a
	mvi	a,0
	adc	h
	mov	h,a
	mov	m,c
	lda	lstmsg
	inr	a
	sta	lstmsg+SIZ
	mov	a,c
	cpi	255
	jrz	lo4
	lda	lstmsg
	inr	a
	cpi	128
	jrc	lo1
	xra	a
lo4:	sta	lstmsg
	lxi	b,lstmsg+1
	lda	serverID
	sta	lstID+1
	sta	lstmsg+DID
	call	sendmsg0
	ora	a
	jz	recvmsg ;wait for response from printer-server
ntwkerr:
	lxi	d,errmsg
	call	msgout
	mvi	a,true
	sta	abtflg
	jmp	cpm

listoff:
	lda	lstmsg	;should we flush the LST: buffer and detatch ?
	cpi	255
	rz
	lda	abtflg
	ora	a
	jrnz	lo0
	mvi	c,255
	jr	output

lo0:	lxi	h,abtflg
	mvi	m,false
lo1:	sta	lstmsg
	ret

ctrlP:	ani	1
	mov	m,a
	rnz		;if we just turned ^P on, no need to detatch printer.
	push	h
	push	d
	push	b
	call	listoff
	pop	b
	pop	d
	pop	h
	xra	a
	ret

warm$boot:
	call	nws
	lda	maddr	;node address
	sta	cnfgtb+1
	sta	sid1
	xra	a
	sta	bsyflg
	call	listoff
	lxi	h,srsts
	bit	1,m
	jrz	chain0
	res	1,m
	lda	rcvmsg+SID
	call	decout
	shld	nnum0
	lxi	d,mlmsg
	call	msgout
	lda	rcvmsg+SIZ
	mov	l,a
	mvi	h,0
	inx	h
	lxi	d,rcvmsg+MSG
	dad	d
	mvi	m,'$'
	call	msgout	;DE=message
chain0: ret ! nop ! nop ;space for "JMP nnnn"

mlmsg:	db	cr,lf
nnum0:	db	'xx>$'

recvmsg:
	lda	nstat
	ani	00010000b
	rz
re$receive:
	mvi	a,0001b ;wait for cpnet message.
	call	get$frames
	lda	xbuf+SID
	cpi	64
	jnc	rec1
	mov	c,a
	mvi	b,0
	lxi	h,SEQtbl
	dad	b
	lda	xbuf+SEQ
	bit	7,a
	jz	rec0
	xra	m
	ani	00001111b
	jz	re$receive
	lda	xbuf+SEQ
rec0:	ani	00001111b
	mov	b,a
	mov	a,m
	ani	11110000b
	ora	b
	mov	m,a
rec1:	lxi	h,srsts
	res	0,m
	xra	a
	ret

sendmsg0:
	dcx	b	;add in SEQ byte
	ldax	b	;save what was there,
	sta	savseq
	sbcd	savmsg
sm0:	mvi	a,10
	sta	retr
	lda	nstat
	ani	00010000b
	rz
	lxi	h,SIZ	;point to size field
	dad	b
	mov	l,m
	mvi	h,0
	lxi	d,MSG+1 	;add 5 bytes for header, plus bias
	dad	d
	shld	leno
	push	h
	push	b
	lxi	h,FMT
	dad	b
	mov	a,m
	sta	funco
	lxi	h,DID
	dad	b
	mov	a,m
	sta	xbo+1
	cpi	64
	jrnc	retry$send
	lxi	h,SEQtbl
	add	l
	mov	l,a
	mvi	a,0
	adc	h
	mov	h,a
	mov	a,m
	rlc
	rlc
	rlc
	rlc
	ani	00001111b
	stax	b
	mvi	a,00010000b
	add	m
	mov	m,a
retry$send:
	call	put	;send header
	pop	h
	pop	d
	push	d
	push	h
	call	put422	;send data
	lxi	h,srsts
	res	2,m	;prevent false-triggering
	mvi	a,0100b ;wait for sndsts
	call	get$frames
	pop	h
	pop	d
	setb	7,m
	lda	sndsts
	ora	a	;indicate that at least the message got to the 77422.
	jrz	msgok
	jm	prtbsy
	lda	retr
	dcr	a
	sta	retr
	jrz	error
	push	d
	push	h
	jr	retry$send
error:	xra	a
	dcr	a
	jr	me0

msgok:	sta	bsyflg	;A=0
me0:	push	psw
	lda	savseq
	lhld	savmsg
	mov	m,a	;restore what was at SEQ
	pop	psw
	ret

retr:	db	0

savseq: db	0
savmsg: dw	0

bsyflg: db	0
abtflg: db	0

bsymsg: db	cr,lf,'Printer owned by node '
nnum:	db	'xx, waiting.$'

prtbsy: lda	bsyflg
	ora	a
	jrnz	bsy0
	cma
	sta	bsyflg
	lda	sndsts
	ani	00111111b	;get node number that owns printer
	lxi	h,maddr
	cmp	m	;do we own the printer?
	jrz	bsy2	;then its just busy, don't display message.
	call	decout
	shld	nnum
	lxi	d,bsymsg
	call	msgout
bsy0:	call	const
	ora	a
	jrnz	abtbsy
bsy2:	lxi	h,8600	;wait awhile before trying again. (approx 100 mS)
bsy1:	dcx	h
	mov	a,h
	ora	l
	jrnz	bsy1
	lbcd	savmsg
	jmp	sm0

abtbsy: call	conin
	xra	a
	call	msgok
	mvi	a,true
	sta	abtflg
	jmp	cpm

decout: cpi	100
	jrc	do0
	mvi	a,99
do0:	mvi	c,0
do1:	inr	c
	sui	10
	jrnc	do1
	adi	10
	dcr	c
	adi	'0'
	mov	h,a
	mov	a,c
	adi	'0'
	mov	l,a
	ret

msgout: ldax	d
	cpi	'$'
	rz
	inx	d
	push	d
	mov	c,a
	call	conout
	pop	d
	jr	msgout

;
; Copy of bios jump vectors to the console routines-filled in at initialization
;

const:	jmp	0
conin:	jmp	0
conout: jmp	0

netstat0:
nws:	push	psw
	mvi	a,030h	;request network status
	sta	funco
	mvi	a,9	;code for "CP/M net"
	sta	xbo+1
	lxi	h,0
	shld	leno
	call	put
	lxi	h,srsts
	res	3,m
	mvi	a,1000b ;wait for netsts
	call	get$frames	;get response
	pop	psw
	ret

get$frames:
	lxi	h,srsts
	mov	b,a
	ana	m
	rnz		;quit if frame has been received
	push	b	;POP PSW will put mask in A again.
	call	get
	lda	func
	cpi	030h	;status frame
	jrz	nsts
	cpi	038h	;send status frame
	jrz	ssts
	cpi	002h	;unsolicited message. (does not terminate routine)
	jrz	mail
	cpi	001h	;CP/NET response
	jrz	cpnet
gf1:	lded	rBC
	lxi	h,xbuf
	call	get422
gf0:	pop	psw
	jr	get$frames

mail:	lded	rBC
	lxi	h,rcvmsg
	call	get422
	lxi	h,srsts
	setb	1,m
	jr	gf0

cpnet:	lxi	h,srsts
	setb	0,m
	jr	gf1

ssts:	lxi	h,srsts
	setb	2,m
	lda	rDE
	sta	sndsts
	jr	gf0

nsts:	lhld	rDE
	shld	Netsta
	lxi	h,nettbl
	lded	rBC
	call	get422
	lxi	h,srsts
	setb	3,m
	jr	gf0

put:	lxi	h,funco
	lxi	d,7
; Byte count (DE) must be greater than 1.
put422: mov	a,e	;must handle blocks larger than 256 bytes
	ora	a	;(Z80 OUTIR/INIR cannot)
	mov	e,d
	jrz	pu3
	inr	e
pu3:	mov	b,a
	lda	porta
	mov	c,a
pu1:	inr	c
pu0:	inp	a
	ani	0100b	;check channel 2 for idle
	jrz	pu0
	dcr	c
	outi		;send first byte
	jrnz	pu1
	dcr	e
	jrnz	pu1
	ret

runout: lda	porta
	mov	c,a
ro0:	inr	c
	inp	a	;
	bit	1,a	;
	jnz	dummyINT5
	ani	1000b
	rz		;no characters waiting
	dcr	c
	inp	a
	jr	ro0

INT5:	outp	a	;this routine will usually terminate "get422".
	dcr	c
	ini		;get last byte of transfer.
	ret		;and return to caller.


dummyINT5:
	outp	a	;turn off interupt
	dcr	c
	inp	a	;possible last character (discard it)
	ret

get:	lxi	h,func
	lxi	d,7
; byte count (DE) must be greater than 1.
get422: mov	a,d
	ora	e
	rz
	mov	a,e	;must handle blocks larger than 256 bytes
	ora	a	;(Z80 OUTIR/INIR cannot)
	mov	e,d
	jrz	ge6
	inr	e
ge6:	mov	b,a
	lda	porta
	mov	c,a
ge1:	inr	c
ge0:	inp	a
	bit	1,a
	jnz	INT5
	ani	1000b	;check channel 3 for idle
	jrz	ge0
	dcr	c
	ini		;get the characters.
	jrnz	ge1
	dcr	e
	jrnz	ge1
ge2:	inr	c	;double check: is interupt set on 77422 ?
ge3:	inp	a
	bit	1,a	;
	jnz	dummyINT5
	ani	1000b
	jrz	ge3
	dcr	c	;
ge5:	inp	a	;At this point we have all the characters we want but
	jr	ge2	;the 77422 still has more to send (or it would have
			;interupted us before this point) so we must continue
			;to take characters untill it interupts us.


;Network output header:
funco:	ds	1	;
leno:	ds	2	;
xbo:	ds	2	;
	ds	2	;

;Network input header:
func:	ds	1	;function code
rBC:	ds	2	;message size (bytes)
rDE:	ds	2	;
rHL:	ds	2	;

xbuf:	ds	MSG+257

SEQtbl: db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

cnfgtb: db	0	;network status
	db	0	;node address
	db	0,0	;drives A:-P: network status
	db	0,0	;
	db	0,0	;
	db	0,0	;
	db	0,0	;
	db	0,0	;
	db	0,0	;
	db	0,0	;
	db	0,0	;
	db	0,0	;
	db	0,0	;
	db	0,0	;
	db	0,0	;
	db	0,0	;
	db	0,0	;
	db	0,0	;
	db	0,0	;CON: local
lstid:	db	80h,0	;LST: networked
lstmsg: db	255	;LST: index
	db	00h	;FMT
	db	0	;DID
sid1:	db	0	;SID
	db	05h	;FNC
	db	0	;SIZ
	db	0	;device number
lstbuf: 		;LST: buffer (128 bytes)
 db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
cnfgsz equ $-cnfgtb

	end
