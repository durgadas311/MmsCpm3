; A config util for WizNET 550 devices, attached in parallel-SPI interface
;
; Commands:
;	n <id>			Set node ID
;	g <ip>			Set gateway IP addr
;	s <ip>			Set sub-network mask
;	i <ip>			Set node IP addr
;	m <ma>			Set node h/w addr
;	0 <id> <ip> <pt>	Set sock 0

	maclib	z80

wiz	equ	10h	; base port of H8-WIZ550io

wiz$dat	equ	wiz+0
wiz$ctl	equ	wiz+1
wiz$sts	equ	wiz+1

SCS	equ	1	; ctl port
BSY	equ	1	; sts port

WRITE	equ	00000100b

GAR	equ	1	; offset of GAR, etc.
SUBR	equ	5
SHAR	equ	9
SIPR	equ	15
PMAGIC	equ	29	; used for node ID

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

; Socket SR values
CLOSED	equ	00h

; Socket CR commands
DISCON	equ	08h

CR	equ	13
LF	equ	10

cpm	equ	0
bdos	equ	5
cmd	equ	0080h

print	equ	9
getver	equ	12
cfgtbl	equ	69

	org	00100h

	jmp	start

idmsg:	db	'Node ID:  $'
gwmsg:	db	'Gateway:  $'
ntmsg:	db	'Subnet:   $'
mcmsg:	db	'MAC:      $'
ipmsg:	db	'IP Addr:  $'

usage:	db	'Usage: WIZCFG {G|I|S ipadr}',CR,LF
	db	'       WIZCFG {M macadr}',CR,LF
	db	'       WIZCFG {N cid}',CR,LF
	db	'       WIZCFG {0|1|2|3 sid ipadr port}',CR,LF,'$'
done:	db	'Set',CR,LF,'$'
sock:	db	'Socket '
sokn:	db	'N: $'
ncfg:	db	'- Not Configured',CR,LF,'$'

start:
	sspd	usrstk
	lxi	sp,stack
	mvi	c,getver
	call	bdos
	mov	a,h
	ani	02h
	jz	nocpnt
	ori	0ffh
	sta	cpnet
	mvi	c,cfgtbl
	call	bdos
	shld	netcfg
nocpnt:
	lda	cmd
	ora	a
	jz	show

	lxi	h,cmd
	mov	b,m
	inx	h
pars0:
	mov	a,m
	cpi	' '
	jnz	pars1
	inx	h
	djnz	pars0
	jmp	show

pars1:
	mov	c,a
	call	skipb
	jc	help
	mov	a,c
	cpi 	'G'
	lxix	gw
	lxi	d,GAR
	jz	pars2
	cpi 	'I'
	lxix	ip
	lxi	d,SIPR
	jz	pars2
	cpi 	'S'
	lxix	msk
	lxi	d,SUBR
	jz	pars2
	cpi 	'M'
	jz	pars3
	cpi 	'N'
	jz	pars4
	cpi	'0'
	jc	help
	cpi	'7'+1
	jnc	help

; Parse new Socket config
	sta	sokn
	; parse <srvid> <ipadr> <port>
	mvi	c,0	; NUL won't ever be seen
	call	parshx
	jc	help
	mvi	a,31h
	sta	nskpt
	mov	a,d	; server ID
	sta	nskpt+1
	call	skipb
	jc	help
	lxix	nskip
	call	parsadr
	jc	help
	call	skipb
	jc	help
	call	parsnm
	jc	help
	mov	a,d
	sta	nskdpt
	mov	a,e
	sta	nskdpt+1
; Now prepare to update socket config
	; set Sn_MR separate, to avoid writing CR and SR...
	mvi	a,1	; TCP
	sta	sokmr
	lda	sokn
	sui	'0'
	rlc
	rlc
	rlc		; xxx00000
	ori	SOCK0	; xxx01000
	mov	d,a
	mvi	e,SnMR
	push	d
	lxi	h,sokmr
	mvi	b,1
	call	wizset	; force TCP/IP mode
	; Get current values, cleanup as needed
	lxi	h,sokregs
	mvi	e,SnMR
	mvi	b,soklen
	call	wizget
	lxi	h,sokmac
	lxi	d,nskmac
	lxi	b,6
	ldir
	lda	sokpt
	cpi	31h
	jnz	ntcpnet	; don't care about CP/NET either
	lda	cpnet
	ora	a
	jz	ntcpnet	; skip CFGTBL cleanup if not CP/NET
	; remove all refs to this server...
	lda	sokpt+1	; server node ID
	mov	c,a
	lhld	netcfg
	mvi	b,18	; 16 drives, CON:, LST:
	inx	h
	inx	h
cln0:	mov	a,m
	ora	a
	jp	ntnet	; device not networked
	inx	h
	mov	a,m
	cmp	c	; same server?
	jnz	ntnet1
	xra	a
	mov	m,a
	dcx	h
	mov	m,a
ntnet:	inx	h
ntnet1:	inx	h
	djnz	cln0
ntcpnet:
	lda	sokmr+SnSR
	cpi	CLOSED
	jz	ntopn
	pop	d
	push	d
	mvi	a,DISCON
	call	wizcmd
	; don't care about results?
ntopn:	lxi	h,newsok
	pop	d
	mvi	e,SnPORT
	mvi	b,soklen-SnPORT
	jmp	setit

pars4:
	call	parshx
	jc	help
	mov	a,d
	sta	wizmag
	lxi	h,wizmag
	lxi	d,PMAGIC
	mvi	b,1
	jmp	setit

pars3:
	lxix	mac
	pushix
	call	parsmac
	pop	h
	jc	help
	lxi	d,SHAR
	mvi	b,6
	jmp	setit

pars2:
	pushix
	push	d
	call	parsadr
	pop	d
	pop	h
	jc	help
	mvi	b,4
	; got it...
setit:
	call	wizset

	;lxi	d,done
	;mvi	c,print
	;call	bdos

exit:
	jmp	cpm

help:
	lxi	d,usage
	mvi	c,print
	call	bdos
	jmp	exit

wizcmd:
	push	psw
	mvi	a,SCS
	out	wiz$ctl
	xra	a
	out	wiz$dat
	mvi	a,SnCR
	out	wiz$dat
	mov	a,d
	ori	WRITE
	out	wiz$dat
	pop	psw
	out	wiz$dat	; start command
	xra	a	;
	out	wiz$ctl
wc0:
	mvi	a,SCS
	out	wiz$ctl
	xra	a
	out	wiz$dat
	mvi	a,SnCR
	out	wiz$dat
	mov	a,d
	out	wiz$dat
	in	wiz$dat	; prime pump
	in	wiz$dat
	push	psw
	xra	a	;
	out	wiz$ctl
	pop	psw
	ora	a
	jnz	wc0
	ret

wizget:
	mvi	a,SCS
	out	wiz$ctl
	xra	a	; hi adr always 0
	out	wiz$dat
	mov	a,e
	out	wiz$dat
	mov	a,d
	out	wiz$dat
	in	wiz$dat	; prime pump
	mvi	c,wiz$dat
	inir
	xra	a	; not SCS
	out	wiz$ctl
	ret

wizset:
	mvi	a,SCS
	out	wiz$ctl
	xra	a	; hi adr always 0
	out	wiz$dat
	mov	a,e
	out	wiz$dat
	mov	a,d
	ori	WRITE
	out	wiz$dat
	mvi	c,wiz$dat
	outir
	xra	a	; not SCS
	out	wiz$ctl
	ret

show:
	lxi	h,comregs
	lxi	d,GAR
	mvi	b,comlen
	call	wizget
	lxi	h,wizmag
	lxi	d,PMAGIC
	mvi	b,1
	call	wizget

	lxi	d,idmsg
	mvi	c,print
	call	bdos
	lda	wizmag
	call	hexout
	mvi	a,'H'
	call	chrout
	call	crlf

	lxi	d,ipmsg
	mvi	c,print
	call	bdos
	lxi	h,ip
	call	ipout
	call	crlf

	lxi	d,gwmsg
	mvi	c,print
	call	bdos
	lxi	h,gw
	call	ipout
	call	crlf

	lxi	d,ntmsg
	mvi	c,print
	call	bdos
	lxi	h,msk
	call	ipout
	call	crlf

	lxi	d,mcmsg
	mvi	c,print
	call	bdos
	lxi	h,mac
	call	hwout
	call	crlf

	lxi	h,sokregs
	lxi	d,SOCK0 shl 8
	mvi	b,soklen
	call	wizget
	mvi	e,0
	call	showsok

	lxi	h,sokregs
	lxi	d,SOCK1 shl 8
	mvi	b,soklen
	call	wizget
	mvi	e,1
	call	showsok

	lxi	h,sokregs
	lxi	d,SOCK2 shl 8
	mvi	b,soklen
	call	wizget
	mvi	e,2
	call	showsok

	lxi	h,sokregs
	lxi	d,SOCK3 shl 8
	mvi	b,soklen
	call	wizget
	mvi	e,3
	call	showsok

	lxi	h,sokregs
	lxi	d,SOCK4 shl 8
	mvi	b,soklen
	call	wizget
	mvi	e,4
	call	showsok

	lxi	h,sokregs
	lxi	d,SOCK5 shl 8
	mvi	b,soklen
	call	wizget
	mvi	e,5
	call	showsok

	lxi	h,sokregs
	lxi	d,SOCK6 shl 8
	mvi	b,soklen
	call	wizget
	mvi	e,6
	call	showsok

	lxi	h,sokregs
	lxi	d,SOCK7 shl 8
	mvi	b,soklen
	call	wizget
	mvi	e,7
	call	showsok

	jmp	exit

showsok:
	mov	a,e
	adi	'0'
	sta	sokn
	lxi	d,sock
	mvi	c,print
	call	bdos
	lda	sokpt
	cpi	31h
	jnz	nocfg
	lda	sokpt+1
	call	hexout
	mvi	a,'H'
	call	chrout
	mvi	a,' '
	call	chrout
	lxi	h,sokip
	call	ipout
	mvi	a,' '
	call	chrout
	lda	sokdpt
	mov	d,a
	lda	sokdpt+1
	mov	e,a
	call	dec16
	call	crlf
	ret

nocfg:	lxi	d,ncfg
	mvi	c,print
	call	bdos
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

chrout:
	push	h
	push	d
	push	b
	mov	e,a
	mvi	c,002h
	call	bdos
	pop	b
	pop	d
	pop	h
	ret

getsts:
	mvi	c,044h
	call	bdos
	ret

getcfg:
	mvi	c,045h
	call	bdos
	ret

crlf:
	mvi	a,CR
	call	chrout
	mvi	a,LF
	call	chrout
	ret

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

skipb:
	inx	h	; skip option letter
	dcr	b
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
parsmac:
	mvi	c,':'
pm00:
	call	parshx
	rc
	jz	pm1	; hit term char
	; TODO: check for 6 bytes...
	stx	d,+0
	ora	a	; NC
	ret
pm1:
	stx	d,+0
	inxix
	inx	h
	djnz	pm00
	; error if ends here...
	stc
	ret


; C=term char
; returns CY if error, Z if term char, NZ end of text
parshx:
	mvi	d,0
pm0:	mov	a,m
	cmp	c
	rz
	cpi	' '
	jz	nzret
	sui	'0'
	rc
	cpi	'9'-'0'+1
	jc	pm3
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
parsadr:
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
	stx	d,+0
	ora	a
	ret

pa1:
	stx	d,+0
	inxix
	inx	h
	djnz	pa00
	; error if ends here...
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

	ds	40
stack:	ds	0
usrstk:	dw	0

cpnet:	db	0
netcfg:	dw	0

wizmag:	db	0	; used as client (node) ID

comregs:
gw:	ds	4
msk:	ds	4
mac:	ds	6
ip:	ds	4
comlen	equ	$-comregs

sokregs:
sokmr:	ds	4	; MR, CR, IR, SR
sokpt:	ds	2	; PORT
sokmac:	ds	6	; DHAR
sokip:	ds	4	; DIPR
sokdpt:	ds	2	; DPORT
soklen	equ	$-sokregs

newsok:
nskpt:	ds	2	; PORT
nskmac:	ds	6	; DHAR
nskip:	ds	4	; DIPR
nskdpt:	ds	2	; DPORT
nsklen	equ	$-sokregs

	end
