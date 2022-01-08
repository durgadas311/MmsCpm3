	title	'MP/M II V2.0 CLBDOS Procedures'
	name	'clbdos'
	dseg
@@clbdos:
	public	@@clbdos
	cseg
@clbdos:
	public	@clbdos

;/*
;  Copyright (C) 1979,1980,1981
;  Digital Research
;  P.O. Box 579
;  Pacific Grove, CA 93950
;
;  Revised:
;    14 Sept 81 by Thomas Rolander
;*/


		;  open:
open:
		;    procedure (fcb$adr) byte reentrant public;
	public	open
		;      declare fcb$adr address;
		;      declare fcb based fcb$adr fcb$descriptor;
		;  
	mov	d,b
	mov	e,c
	mvi	c,15
	jmp	mon2
		;      return mon2 (15,fcb$adr);
		;    end open;
		;  
		;  close:
close:
		;    procedure (fcb$adr) reentrant public;
	public	close
		;      declare fcb$adr address;
		;      declare ret byte;
		;  
	mov	d,b
	mov	e,c
	mvi	c,16
	jmp	mon2
		;      ret = mon2 (16,fcb$adr);
		;    end close;
		;  
		;  readbf:
readbf:
		;    procedure (fcb$adr) byte reentrant public;
	public	readbf
		;      declare fcb$adr address;
		;  
	mov	d,b
	mov	e,c
	mvi	c,20
	jmp	mon2
		;      return mon2 (20,fcb$adr);
		;    end readbf;
		;  
		;  init:
init:
		;    procedure reentrant public;
	public	init
		;
	mvi	c,13
	jmp	mon1
		;      call mon1 (13,0);
		;    end init;
		;
		;  set$dma:
setdma:
		;    procedure (dma$adr) public;
	public	setdma
		;      declare dma$adr address;
		;
	mov	d,b
	mov	e,c
	mvi	c,26
	jmp	mon1
		;      call mon1 (26,dma$adr);
		;    end set$dma;
		;
		;  flshbf:
flshbf:
		;    procedure public;
	public	flshbf
		;
	mvi	c,48
	jmp	mon1
		;      call mon1 (48,0);
		;    end flshbf;
		;
		;  lo:
lo:
		;    procedure (char) reentrant public;
	public	lo
		;      declare char byte;
		;
	mov	e,c
	mvi	c,5
	jmp	mon1
		;      call mon1 (5,char);
		;    end lo;
		;
		;  co:
co:
		;    procedure (char) reentrant public;
	public	co
		;      declare char byte;
		;
	mov	e,c
	mvi	c,2
	jmp	mon1
		;      call mon1 (2,char);
		;    end co;
		;
		;  ci:
ci:
		;    procedure byte reentrant public;
	public	ci
		;
	mvi	c,1
	jmp	mon2
		;      return mon2 (1,0);
		;    end ci;
		;
		;  rawci:
rawci:
		;    procedure byte reentrant public;
	public	rawci
		;
	mvi	c,6
	mvi	e,0ffh
	jmp	mon2
		;      return mon2 (6,0ffh);
		;    end rawci;
		;
		;  rawlst:
rawlst:
		;    procedure (string$address) reentrant public;
		;      declare string$address address;
		;      declare char based string$address byte;
	public	rawlst
		;
		;      do while char <> '$';
	ldax	b
	cpi	'$'
	rz
	push	b
	mvi	c,6
	mov	e,a
	call	mon1
		;        call mon1 (6,char);
	pop	b
	inx	b
	jmp	rawlst
		;      end;
		;    end rawlst;
		;
		;  print$buffer:
printb:
		;    procedure (bufferadr) reentrant public;
	public	printb
		;      declare bufferadr address;
		;
	mov	d,b
	mov	e,c
	mvi	c,9
	jmp	mon1
		;      call mon1 (9,bufferadr);
		;    end print$buffer;
		;
		;  read$buffer:
readbu:
		;    procedure (bufferadr) reentrant public;
	public	readbu
		;      declare bufferadr address;
		;
	mov	d,b
	mov	e,c
	mvi	c,10
	jmp	mon1
		;      call mon1 (10,bufferadr);
		;    end read$buffer;
		;
		;  crlf:
crlf:
		;    procedure reentrant public;
	public	crlf
		;
		;      call co (0DH);
	mvi	c,0dh
	call	co
		;      call co (0AH);
	mvi	c,0ah
	jmp	co
		;    end crlf;
		;

terminate	equ	143

	public	endp
endp:
	push	psw
	push	b
	push	d
	push	h
	mvi	c,terminate	;143
	lxi	d,0
	call	xbdos
	pop	h
	pop	d
	pop	b
	pop	psw
	ret

	public	exitr
	extrn	indisp
exitr:
	lda	indisp
	ora	a
	jz	exitregion	;exit region only if not in dispatcher
	ret

xiosoffset	equ	33h

	public	xiosms
xiosms:
	jmp	$-$
	public	xiospl
xiospl:
	jmp	$-$
	public	strclk
strclk:
	jmp	$-$
	public	stpclk
stpclk:
	jmp	$-$
;	public	exitr
exitregion:
	jmp	$-$
	public	maxcns
maxcns:
	jmp	$-$
;	public	sysinit
;sysinit:
	jmp	$-$
	public	xidle
xidle:
	jmp	$-$

	extrn	sysdat,datapg
	public	syinit
syinit:
	mvi	l,252
	lxi	d,datapg
	mov	m,e
	inx	h
	mov	m,d		; datapg[252] = system data pg adr
	lxi	h,mpmtop
	mvi	l,-6
	lxi	d,xjmptbl
	mvi	b,6
moveloop:
	ldax	d
	mov	m,a
	inx	d
	inx	h
	dcr	b
	jnz	moveloop
	inx	h
	mov	e,m
	inx	h
	mov	d,m
	xchg
	shld	xbdosadr
	xchg
	inx	h
	inx	h
	mov	e,m
	inx	h
	mov	d,m
	inx	h
	push	h
	lxi	h,xiosoffset
	dad	d
			; copy XIOS jump table
	mvi	b,24	; 8 entries * 3 bytes
	lxi	d,xiosms
mvxiostbl:
	mov	a,m
	stax	d
	inx	h
	inx	d
	dcr	b
	jnz	mvxiostbl

	extrn	dspsvz80,dsprsz80

	lxi	h,-3
	dad	d
	mvi	a,0c3h
	cmp	m	;is XIOS idle routine present?
	jz	idleok
	mov	m,a
	lxi	d,pdisp
	inx	h
	mov	m,e
	inx	h
	mov	m,d
idleok:
	lhld	sysdat
	mvi	l,5
	mov	a,m
	ora	a
	jz	notz80	;test z80 flag in sys dat page
	xra	a
	sta	dspsvz80
	lxi	h,0
	shld	dspsvz80+1
	sta	dsprsz80
	shld	dsprsz80+1
notz80:

	lhld	sysdat	;passed parameter, HL = sysdat
	ret

	public	nfxdos
nfxdos:
	extrn	xdos,pdisp
xjmptbl:
	jmp	xdos
	jmp	pdisp

	public	xbdos
xbdos:
	public	mon1,mon2
mon1:
mon2:
	lhld	xbdosadr
	pchl

	dseg
xbdosadr:
	ds	2

	ds	3	; make room for BDOS external jump table
	ds	3

mpmtop:
	db	0	; force byte at end of mpm nucleus module

	end
