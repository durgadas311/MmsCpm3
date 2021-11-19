; MPMLDR program code
; Linked with ldrbdos,ldrbios,ldrXXX (disk driver XXX).
; Re-written from mpmldr.plm using CP/M3 ldrprog.asm
; and uses Z80 instructions.

	maclib	z80

	public	loader
	extrn	bdos

CR	equ	13
LF	equ	10
TAB	equ	9
BS	equ	8
BEL	equ	7
DEL	equ	127

conout	equ	2
print	equ	9
reset	equ	13
open	equ	15
read	equ	20
setdma	equ	26

	cseg
	org	0100h	; shouldn't be here, but for backward compat
loader:
	jmp	start

	db	'COPYRIGHT (C) 1981, DIGITAL RESEARCH '
	db	'654321'	; space for s/n

start:
	; usage: MPMLDR [$B] [sys-file]
	; TODO: implement debug break?
	; TODO: implement alternate MPM.SYS filename?
	mvi	c,reset
	call	bdos
	lxi	d,signon
	mvi	c,print
	call	bdos
	mvi	c,open
	lxi	d,mpmsys
	call	bdos
	cpi	0ffh
	lxi	d,fnfmsg
	jz	die
	lxi	d,sysbuf
	call	st$dma
	call	rd$file	; load first of system data
	lxi	d,sysbuf+128
	call	st$dma
	call	rd$file	; load rest of system data

	lda	sysbuf+0	; mem$top
	mov	h,a
	mvi	l,0
	shld	sysdat
	shld	cur$top
	lxi	d,msg1
	mvi	c,print
	call	bdos
	lda	sysbuf+1	; nmb$cns
	call	printnib
	lxi	d,msg2
	mvi	c,print
	call	bdos
	lda	sysbuf+2	; brkpt$RST
	call	printnib
	lxi	d,msg3
	mvi	c,print
	call	bdos
	lxi	h,syst$dat
	lded	cur$top
	lxi	b,256
	call	printitems
	lda	sysbuf+1	; nmb$cns
	dcr	a
	ora	a
	rrc
	ora	a
	rrc
	inr	a
	mov	h,a
	mvi	l,0
	shld	prev$top
	xchg
	lhld	cur$top
	ora	a
	dsbc	d
	shld	cur$top
	xchg
	lxi	h,tmpd$dat
	lbcd	prev$top
	call	printitems
	lda	sysbuf+3	; sys$call$stks
	ora	a
	jrz	mldr0
	lda	sysbuf+15	; nmb$mem$seg
	sui	2
	ani	11111100b
	rrc
	rrc
	inr	a
	mov	h,a
	mvi	l,0
	shld	prev$top
	xchg
	lhld	cur$top
	ora	a
	dsbc	d
	shld	cur$top	; cur$top = cur$top - (prev$top := (shr(nmb$mem$seg-2,2)+1)*256);
	xchg
	lxi	h,usrs$stk
	lbcd	prev$top
	call	printitems
mldr0:
	; load from sysdat downward...
	lhld	sysdat
	shld	cur$top
	lxi	h,2-1
loop:
	inx	h
	shld	cur$record
	lded	sysbuf+120	; nmb$records
	ora	a
	dsbc	d
	jz	break
	lhld	cur$top
	lxi	d,-128
	dad	d
	shld	cur$top
	xchg
	call	st$dma
	call	rd$file
	lhld	cur$record
	jmp	loop
break:
	; done loading system...
	lda	sysdat+11	; xdos$base
	mov	h,a
	mvi	l,0
	shld	entry$point

	call	display$OS
	call	display$mem$map
	lxi	h,sysbuf
	lded	sysdat
	lxi	b,256
	ldir
	; exec MP/M... TODO: setup a minimal stack?
	lhld	entry$point
	pchl

st$dma:
	mvi	c,setdma
	call	bdos
	ret

rd$file:
	mvi	c,read
	lxi	d,mpmsys
	call	bdos
	ora	a
	lxi	d,rdemsg
	rz	
	; fall-through to die()
die:
	mvi	c,print
	call	bdos
	di
	hlt

; Print A in decimal
printdecimal:
	mvi	d,100
	call	divide
	mvi	d,10
	call	divide
	adi	'0'
	jmp	chrout

; (8-bit) Divide A by D, prints quotient digit
; Returns A=remainder
divide:	mvi	e,0
div0:	sub	d
	inr	e
	jrnc	div0
	add	d
	dcr	e
	push	psw	; remainder
	mvi	a,'0'
	add	e
	call	chrout
	pop	psw	; remainder
	ret

crlf:	mvi	a,CR
	call	chrout
	mvi	a,LF
	jmp	chrout

; Display 0..15 from A as HEX digit
printnib:
	ani	0fh
	adi	90h
	daa
	aci	40h
	daa
chrout:	mov	e,a
	mvi	c,conout
	jmp	bdos

; Display byte from A in HEX
printhex:
	push	psw
	rrc
	rrc
	rrc
	rrc
	call	printnib
	pop	psw
	jmp	printnib

; Display 16-bit value HL in HEX, blank prefix and 'H' suffix
printaddr:
	push	h
	mvi	a,' '
	call	chrout
	mvi	a,' '
	call	chrout
	pop	h
	push	h
	mov	a,h
	call	printhex
	pop	h
	mov	a,l
	jmp	printhex

; Print string HL, for B chars.
printstring:
	push	h
	push	b
	mov	a,m
	call	chrout
	pop	b
	pop	h
	inx	h
	djnz	printstring
	ret

; Print filename field HL (11 chars)
printname:
	mvi	b,11
	jmp	printstring

; HL=name (11-chars)
; DE=base addr
; BC=length/size
printitems:
	push	b
	push	d
	call	printname
	pop	h
	call	printaddr
	pop	h
	call	printaddr
	jmp	crlf

display$OS:
	lxi	h,xios$tbl
	lda	sysbuf+7	; xios$jmp$tbl$base
	mov	d,a
	mvi	e,0
	lxi	b,100h
	call	printitems
	
	lxi	h,resbdos
	lda	sysbuf+8	; resbdos$base
	mov	d,a
	mvi	e,0
	lda	sysbuf+7	; xios$jmp$tbl$base
	sub	d
	mov	b,a
	mov	c,e	; 0
	call	printitems

	lxi	h,xdos$spr
	lda	sysbuf+11	; xdos$base
	mov	d,a
	mvi	e,0
	lda	sysbuf+8	; resbdos$base
	sub	d
	mov	b,a
	mov	c,e	; 0
	call	printitems

	lda	sysbuf+125	; nmb$rsps
	ora	a
	jz	no$rsps
	lhld	sysbuf+254	; rspl
	lda	sysbuf+11	; xdos$base
	; HL=sysdat.rspl = first RSP in linked list
	ora	a
	call	printrsps
no$rsps:
	lxi	h,bnkxios
	lda	sysbuf+13	; bnkxios$base
	mov	d,a
	mvi	e,0
	lda	sysbuf+12	; rsp$base
	sub	d
	mov	b,a
	mov	c,e	; 0
	call	printitems

	lxi	h,bnkbdos
	lda	sysbuf+14	; bnkbdos$base
	mov	d,a
	mvi	e,0
	lda	sysbuf+13	; bnkxios$base
	sub	d
	mov	b,a
	mov	c,e	; 0
	call	printitems

	lxi	h,bnkxdos
	lda	sysbuf+242	; bnkxdos$base
	mov	d,a
	mvi	e,0
	lda	sysbuf+14	; bnkbdos$base
	sub	d
	mov	b,a
	mov	c,e	; 0
	call	printitems

	lxi	h,tmp$spr
	lda	sysbuf+247	; tmp$base
	mov	d,a
	mvi	e,0
	lda	sysbuf+242	; bnkxdos$base
	sub	d
	mov	b,a
	mov	c,e	; 0
	call	printitems
	lda	sysbuf+248	; nmb$brsps
	ora	a
	jz	no$brss
	lhld	sysbuf+250	; brspl
	lda	sysbuf+247	; tmp$base
	; HL=sysdat.rspl = first RSP in linked list
	stc
	call	printrsps
	lda	sysbuf+249	; brsp$base
	jr	so$brss
no$brss:
	lda	sysbuf+247	; tmp$base
so$brss:
	sta	base
	lhld	sysbuf+189	; total$list$items
	mov	e,l
	mov	d,h
	dad	h	; *2
	dad	h	; *4
	dad	d	; *5
	dad	h	; *10
	lxi	d,255
	dad	d	; round up
	sub	h	; base - high (total$list$items*10 + 255)
	sta	cntr
	lxi	h,lcksts$dat
	mov	d,a
	mvi	e,0
	lda	base
	sub	d
	mov	b,a
	mov	c,e	; 0
	call	printitems
	lda	sysbuf+1	; nmb$cns
	ora	a
	jz	no$cns
	mov	c,a
	lda	cntr
	sta	base
	sub	c
	sta	cntr
	lxi	h,console$dat
	mov	d,a
	mvi	e,0
	lda	base
	sub	d
	mov	b,a
	mov	c,e	; 0
	call	printitems
no$cns:
	ret

display$mem$map:
	lxi	d,dashes
	mvi	c,print
	call	bdos
	lxi	d,sysmsg
	lda	sysbuf+15	; nmb$mem$seg
	mov	b,a
	lxi	h,sysbuf+16	; mem$seg$tbl
dmm0:
	push	b
	push	h
	mvi	c,print
	call	bdos
	pop	h
	mov	d,m	; mem$seg$tbl(nrec).base
	inx	h
	mvi	e,0
	push	h
	xchg
	call	printaddr
	pop	h
	mov	d,m	; mem$seg$tbl(nrec).size
	inx	h
	mvi	e,0
	push	h
	xchg
	call	printaddr
	lda	sysbuf+4	; bank$switched
	ora	a
	jz	dmm1
	lxi	d,bnkmsg
	mvi	c,print
	call	bdos
	pop	h
	push	h
	inx	h
	mov	a,m	; mem$seg$tbl(nrec).bank
	call	printdecimal
dmm1:
	call	crlf
	pop	h
	pop	b
	lxi	d,usrmsg
	inx	h
	inx	h
	djnz	dmm0
	ret

; Print RSP/BRS linked list
; HL=first RSP in linked list, A=end page (next item page)
; CY=BRS
printrsps:
	mov	b,a
	ral	; get CY
	ani	1
	sta	context
	xchg
	lxi	h,rspsadr	; array...
	mvi	c,0
rsps0:
	mov	m,e
	inx	h
	mov	m,d
	inx	h
	mov	a,e
	ora	d
	jz	rsps1
	inr	c
	xchg
	lda	context
	ora	a
	jrz	rsps3
	inx	h
	inx	h
rsps3:
	mov	a,m
	inx	h
	mov	h,m
	mov	l,a
	xchg
	jmp	rsps0
; Got all, terminate list and print them backward
rsps1:
	dcx	h
	mov	m,b
	dcx	h
	push	h
	popix
rsps2:
	dcr	c
	rm
	pushix
	push	b
	ldx	l,+0
	ldx	h,+1
	ldx	e,-2
	ldx	d,-1
	ora	a
	dsbc	d	; rspsadr(cntr+1)-rspsadr(cntr)
	mov	c,l
	mov	b,h
	ldx	l,-2
	ldx	h,-1
	lda	context
	ora	a
	lxi	d,6+2	; if BRS, +4
	jrz	rsps4
	lxi	d,4
rsps4:
	dad	d	; point to RSP name
	call	mvname	; returns HL=name-buffer
	ldx	e,-2
	ldx	d,-1	; rspsadr(cntr)
	call	printitems
	pop	b
	popix
	dcxix
	dcxix
	jmp	rsps2

; move 8-chars (7-bit) from HL to (context)
mvname:
	push	b
	mvi	b,8
	lda	context
	ora	a
	lxi	d,xxxx$rsp
	jrz	mvn1
	lxi	d,xxxx$brs
mvn1:	push	d
mvn0:
	mov	a,m
	ani	01111111b
	stax	d
	inx	h
	inx	d
	djnz	mvn0
	pop	h	; string in HL
	pop	b
	ret

context: db	0
xxxx$rsp:	db	'        RSP'
xxxx$brs:	db	'        BRS'

sysdat:		dw	0
cur$top:	dw	0
prev$top:	dw	0
cur$record:	dw	0
entry$point:	dw	0
rspsadr:	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
base:	db	0
cntr:	db	0

syst$dat:	db	'SYSTEM  DAT'
tmpd$dat:	db	'TMPD    DAT'
usrs$stk:	db	'USERSYS STK'
xios$tbl:	db	'XIOSJMP TBL'
resbdos:	db	'RESBDOS SPR'
xdos$spr:	db	'XDOS    SPR'
bnkxios:	db	'BNKXIOS SPR'
bnkbdos:	db	'BNKBDOS SPR'
bnkxdos:	db	'BNKXDOS SPR'
tmp$spr:	db	'TMP     SPR'
lcksts$dat:	db	'LCKLSTS DAT'
console$dat:	db	'CONSOLE DAT'
dashes:		db	'-------------------------',CR,LF,'$'
sysmsg:		db	'MP/M II Sys','$'
usrmsg:		db	'Memseg  Usr','$'
bnkmsg:		db	'  Bank ','$'

mpmsys:
	db	0,'MPM     SYS',0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0

signon:
	db	CR,LF,'MP/M II V2.0 Loader   '
	db	CR,LF,'Copyright (C) 1981, Digital Research',CR,LF,'$'
fnfmsg:
	db	CR,LF,'error: File not found: MPM.SYS'
	db	CR,LF,'$'

rdemsg:
	db	CR,LF,'error: Read failure: MPM.SYS'
	db	CR,LF,'$'

msg1:	db	CR,LF,'Nmb of consoles     =  $'
msg2:	db	CR,LF,'Breakpoint RST #    =  $'
msg3:	db	CR,LF,'Memory Segment Table:',CR,LF,'$'

sysbuf:	ds	256

	end
