; Disassembly of RMAC.COM

; ASCII non-printable characters
cr	equ	13
lf	equ	10
tab	equ	9
ff	equ	12
eof	equ	26
del	equ	127

; BDOS function numbers
conin	equ	1
conout	equ	2
lstout	equ	5
print	equ	9
const	equ	11
getver	equ	12
seldsk	equ	14
open	equ	15
close	equ	16
delete	equ	19
read	equ	20
write	equ	21
make	equ	22
curdsk	equ	25
setdma	equ	26
; MP/M-II XDOS functions
openq	equ	135
creadq	equ	138
delay	equ	141

; System page-0 addresses
cpm	equ	0
bdos	equ	5
deffcb	equ	05ch
defdma	equ	080h
cmdlin	equ	080h

; special drive types
DRVNUL	equ	'Z'-'A'
DRVCON	equ	'X'-'A'
DRVLST	equ	'P'-'A'	; should be 'Y'...
; Drive source/dest:
; $Ax = ASM from A-P
; $Sx = SYM to A-P,X,Y,Z
; $Px = PRN to A-P,X,Y,Z
; $Hx = HEX to A-P,Z
; $Lx = LIB from A-P
; $+L $-L = LIB listing
; $*M $+M $-M = macro expansions
; $+Q $-Q = local symbols
; $+R $-R = REL file options?
; $+S $-S = symbol table (to PRN)
; $+1 $-1 = pass one listing

; Symbol table structure
;	struct symbol {
;		struct symbol *next; // on hash chain
;		uint8_t len;	// name length, -1
;		uint8_t type;	// segment, flags
;		char name[];	// defined by 'len'
;		uint16_t addr;	// address/value
;	};
;	// bits in type field:
;	#define SF_SEG 0x07	// segment 0-3, 6=extrn
;	#define SF_EXT 0x04	// external/imported - seg unknown
;	#define SF_PUB 0x08	// exported/public symbol
;	#define SF_SYM 0x10	// symbol/label (else common block)
;	#define SF_MAC 0x20	// macro def (full value, not bit)
;	#define SF_SET 0x40	// "temp" symbol? used in SET
; Each hash chain is sorted (inserted) alphanumerically
;
;	struct param {	// macro parameters
;		uint8_t len;
;		uint8_t type;	// flags different?
;		char name[];	// param name (local)
;	};
;	struct element {	// one macro element (line)
;		uint8_t len;	// not length - TBD
;		uint8_t op;	// opcode, ORed w/80h
;		char line[];	// CR-LF terminated
;	};
;	struct macro {	// macro definition
;		struct symbol def;	// the name of the macro, type=0x20
;		uint8_t npar;	// number of parameters
;		// zero or more of these...
;		struct param parms[];
;		// macro template, split into lines (statements?)
;		struct element tmplt[];
;		uint8_t nul;	// must be "00"
;	};

	org	00100h
	jmp	L01a8		;; 0100: c3 a8 01    ...

	db	' COPYRIGHT (C) 1980 DIGITAL RESEARCH '

; patches?
patch1:	cpi	040h		;; 0128: fe 40       .@
	cnz	Lerror		;; 012a: c4 e7 15    ...
	ret			;; 012d: c9          .

patch2:	lda	L350a		;; 012e: 3a 0a 35    :.5
	ani	003h		;; 0131: e6 03       ..
	ori	040h		;; 0133: f6 40       .@
	call	settyp		;; 0135: cd 16 25    ..%
	jmp	L1002		;; 0138: c3 02 10    ...

	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0afh,0,0,0,14h,13h	; serial number?

L01a8:	lxi	sp,stack	;; 01a8: 31 b4 35    1.5
	xra	a		;; 01ab: af          .
	sta	pass		;; 01ac: 32 15 35    2.5
	sta	L3527		;; 01af: 32 27 35    2'5
	call	osinit		;; 01b2: cd 68 2b    .h+
	call	L2255		;; 01b5: cd 55 22    .U"
	lxi	h,0		;; 01b8: 21 00 00    ...
	shld	L161c		;; 01bb: 22 1c 16    "..
	shld	L162a		;; 01be: 22 2a 16    "*.
	shld	L3513		;; 01c1: 22 13 35    ".5
L01c4:	call	L226a		;; 01c4: cd 6a 22    .j"
	xra	a		;; 01c7: af          .
	sta	L3375		;; 01c8: 32 75 33    2u3
	mvi	a,000h		;; 01cb: 3e 00       >.
	sta	L3376		;; 01cd: 32 76 33    2v3
	lhld	memtop		;; 01d0: 2a 11 35    *.5
	shld	L33f8		;; 01d3: 22 f8 33    ".3
	call	L1d2d		;; 01d6: cd 2d 1d    .-.
	call	L2da9		;; 01d9: cd a9 2d    ..-
	lda	pass		;; 01dc: 3a 15 35    :.5
	ora	a		;; 01df: b7          .
	cnz	relini		;; 01e0: c4 5a 10    .Z.
	lxi	h,0		;; 01e3: 21 00 00    ...
	shld	curlbl		;; 01e6: 22 08 16    "..
	shld	locseq		;; 01e9: 22 24 16    "$.
	shld	curadr		;; 01ec: 22 16 35    ".5
	shld	asgadr		;; 01ef: 22 18 35    ".5
	shld	csgadr		;; 01f2: 22 1a 35    ".5
	shld	dsgadr		;; 01f5: 22 1c 35    ".5
	shld	cmnadr		;; 01f8: 22 1e 35    ".5
	shld	L160c		;; 01fb: 22 0c 16    "..
	shld	L350d		;; 01fe: 22 0d 35    ".5
	xra	a		;; 0201: af          .
	sta	L1613		;; 0202: 32 13 16    2..
	sta	L160e		;; 0205: 32 0e 16    2..
	mvi	a,001h		;; 0208: 3e 01       >.
	sta	curseg		;; 020a: 32 20 35    2 5
L020d:	call	L1dff		;; 020d: cd ff 1d    ...
L0210:	lda	curctx		;; 0210: 3a c4 34    :.4
	cpi	2		;; 0213: fe 02       ..
	jz	L020d		;; 0215: ca 0d 02    ...
	cpi	4		;; 0218: fe 04       ..
	jnz	L0262		;; 021a: c2 62 02    .b.
	; state "4" ... operand?
	lda	tokbuf+1	;; 021d: 3a c8 34    :.4
	cpi	'$'		;; 0220: fe 24       .$
	jnz	L1002		;; 0222: c2 02 10    ...
	; "$-MACRO", etc...
	call	getlbl		;; 0225: cd f3 11    ...
	jnz	Serro2		;; 0228: c2 4d 10    .M.
	lda	curchr		;; 022b: 3a 28 35    :(5
	mvi	b,000h		;; 022e: 06 00       ..
	cpi	'-'		;; 0230: fe 2d       .-
	jz	L0243		;; 0232: ca 43 02    .C.
	mvi	b,003h		;; 0235: 06 03       ..
	cpi	'+'		;; 0237: fe 2b       .+
	jz	L0243		;; 0239: ca 43 02    .C.
	mvi	b,007h		;; 023c: 06 07       ..
	cpi	'*'		;; 023e: fe 2a       .*
	jnz	Serro2		;; 0240: c2 4d 10    .M.
L0243:	push	b		;; 0243: c5          .
	call	L1dff		;; 0244: cd ff 1d    ...
	pop	b		;; 0247: c1          .
	lda	curchr		;; 0248: 3a 28 35    :(5
	lxi	h,Mflag		;; 024b: 21 2c 35    .,5
	cpi	'M'		;; 024e: fe 4d       .M
	jz	L025b		;; 0250: ca 5b 02    .[.
	lxi	h,Pflag		;; 0253: 21 33 35    .35
	cpi	'P'		;; 0256: fe 50       .P
	jnz	Serro2		;; 0258: c2 4d 10    .M.
L025b:	mov	m,b		;; 025b: 70          p
	call	L1dff		;; 025c: cd ff 1d    ...
	jmp	L0e25		;; 025f: c3 25 0e    .%.

; not state "2" or "4"...
L0262:	cpi	1		;; 0262: fe 01       ..
	jnz	Serro2		;; 0264: c2 4d 10    .M.
	; state "1" - label or opcode
	call	keywrd		;; 0267: cd dd 28    ..(
	jz	L04a1		;; 026a: ca a1 04    ...
	; must be statement label - try to create symbol
	call	look7		;; 026d: cd a3 23    ..#
	call	isNULL		;; 0270: cd 76 23    .v#
	jnz	L0283		;; 0273: c2 83 02    ...
	; no symbol exists - create one
	call	newsym		;; 0276: cd 00 24    ..$
	lda	pass		;; 0279: 3a 15 35    :.5
	ora	a		;; 027c: b7          .
	cnz	Perror		;; 027d: c4 e1 15    ...
	jmp	L047d		;; 0280: c3 7d 04    .}.

; symbol exists - make certain it is compatible
L0283:	call	symtyp		;; 0283: cd 1e 25    ..%
	cpi	020h		;; 0286: fe 20       . 
	jnz	L047d		;; 0288: c2 7d 04    .}.
	; a macro def - expand it...
	lxi	h,0		;; 028b: 21 00 00    ...
	shld	L1626		;; 028e: 22 26 16    "&.
	lda	pass		;; 0291: 3a 15 35    :.5
	ora	a		;; 0294: b7          .
	jz	L02a6		;; 0295: ca a6 02    ...
L0298:	call	getval		;; 0298: cd 3e 25    .>%
	xchg			;; 029b: eb          .
	lhld	cursym		;; 029c: 2a 23 35    *#5
	mov	a,l		;; 029f: 7d          }
	sub	e		;; 02a0: 93          .
	mov	a,h		;; 02a1: 7c          |
	sbb	d		;; 02a2: 9a          .
	jc	L02d3		;; 02a3: da d3 02    ...
L02a6:	call	putnam		;; 02a6: cd 09 03    ...
	call	L2056		;; 02a9: cd 56 20    .V 
	call	L0341		;; 02ac: cd 41 03    .A.
	jnz	L0358		;; 02af: c2 58 03    .X.
	lhld	curlbl		;; 02b2: 2a 08 16    *..
	mov	a,h		;; 02b5: 7c          |
	ora	l		;; 02b6: b5          .
	cnz	Serror		;; 02b7: c4 f9 15    ...
	lda	pass		;; 02ba: 3a 15 35    :.5
	ora	a		;; 02bd: b7          .
	jnz	L02f6		;; 02be: c2 f6 02    ...
	call	getnam		;; 02c1: cd 28 03    .(.
	call	tokcks		;; 02c4: cd 15 23    ..#
	call	newsym		;; 02c7: cd 00 24    ..$
	lhld	cursym		;; 02ca: 2a 23 35    *#5
	shld	curlbl		;; 02cd: 22 08 16    "..
	jmp	pMACRO		;; 02d0: c3 41 07    .A.

L02d3:	lhld	cursym		;; 02d3: 2a 23 35    *#5
	shld	L1626		;; 02d6: 22 26 16    "&.
	call	L23f6		;; 02d9: cd f6 23    ..#
	call	isNULL		;; 02dc: cd 76 23    .v#
	jz	L02ed		;; 02df: ca ed 02    ...
	call	symtyp		;; 02e2: cd 1e 25    ..%
	cpi	32		;; 02e5: fe 20       . 
	jnz	L0352		;; 02e7: c2 52 03    .R.
	jmp	L0298		;; 02ea: c3 98 02    ...

L02ed:	call	L2056		;; 02ed: cd 56 20    .V 
	call	L0341		;; 02f0: cd 41 03    .A.
	jnz	L0352		;; 02f3: c2 52 03    .R.
L02f6:	lhld	L1626		;; 02f6: 2a 26 16    *&.
	xchg			;; 02f9: eb          .
	lhld	L161e		;; 02fa: 2a 1e 16    *..
	call	compr1		;; 02fd: cd e6 11    ...
	jnz	L0352		;; 0300: c2 52 03    .R.
	shld	curlbl		;; 0303: 22 08 16    "..
	jmp	pMACRO		;; 0306: c3 41 07    .A.

; copy name (tokbuf) onto heap (struct symbol.name[0])
putnam:	lhld	nxheap		;; 0309: 2a 0f 35    *.5
	push	h		;; 030c: e5          .
	shld	tmpptr		;; 030d: 22 25 35    "%5
	lxi	h,tokbuf	;; 0310: 21 c7 34    ..4
	mov	c,m		;; 0313: 4e          N
	mov	b,c		;; 0314: 41          A
L0315:	inx	h		;; 0315: 23          #
	mov	a,m		;; 0316: 7e          ~
	push	b		;; 0317: c5          .
	push	h		;; 0318: e5          .
	call	puttmp		;; 0319: cd ab 25    ..%
	pop	h		;; 031c: e1          .
	pop	b		;; 031d: c1          .
	dcr	c		;; 031e: 0d          .
	jnz	L0315		;; 031f: c2 15 03    ...
	pop	h		;; 0322: e1          .
	mov	m,b		;; 0323: 70          p
	shld	nxheap		;; 0324: 22 0f 35    ".5
	ret			;; 0327: c9          .

; copy name out of heap (symbol.name) into tokbuf
getnam:	lhld	nxheap		;; 0328: 2a 0f 35    *.5
	mov	c,m		;; 032b: 4e          N
	shld	tmpptr		;; 032c: 22 25 35    "%5
	lxi	h,tokbuf	;; 032f: 21 c7 34    ..4
	mov	m,c		;; 0332: 71          q
L0333:	inx	h		;; 0333: 23          #
	push	b		;; 0334: c5          .
	push	h		;; 0335: e5          .
	call	gettmp		;; 0336: cd a2 25    ..%
	pop	h		;; 0339: e1          .
	pop	b		;; 033a: c1          .
	mov	m,a		;; 033b: 77          w
	dcr	c		;; 033c: 0d          .
	jnz	L0333		;; 033d: c2 33 03    .3.
	ret			;; 0340: c9          .

; parse current statement/opcode
; return ZR if it is MACRO
L0341:	lda	curctx		;; 0341: 3a c4 34    :.4
	cpi	005h		;; 0344: fe 05       ..
	rnz			;; 0346: c0          .
	call	keywrd		;; 0347: cd dd 28    ..(
	rnz			;; 034a: c0          .
	cpi	01ah	; pseudo ops?
	rnz			;; 034d: c0          .
	mov	a,b		;; 034e: 78          x
	cpi	009h	; MACRO definition
	ret			;; 0351: c9          .

L0352:	call	Perror		;; 0352: cd e1 15    ...
	jmp	L1002		;; 0355: c3 02 10    ...

L0358:	lhld	cursym		;; 0358: 2a 23 35    *#5
	push	h		;; 035b: e5          .
	call	L11fd		;; 035c: cd fd 11    ...
	lda	Mflag		;; 035f: 3a 2c 35    :,5
	ora	a		;; 0362: b7          .
	cz	prnbeg		;; 0363: cc 6f 13    .o.
	pop	h		;; 0366: e1          .
	shld	cursym		;; 0367: 22 23 35    "#5
	call	macpct		;; 036a: cd 56 25    .V%
	sta	L1607		;; 036d: 32 07 16    2..
	lhld	memtop		;; 0370: 2a 11 35    *.5
	push	h		;; 0373: e5          .
	ora	a		;; 0374: b7          .
	jz	L0406		;; 0375: ca 06 04    ...
	jmp	L0394		;; 0378: c3 94 03    ...

L037b:	cpi	';'		;; 037b: fe 3b       .;
	rz			;; 037d: c8          .
	cpi	cr		;; 037e: fe 0d       ..
	rz			;; 0380: c8          .
L0381:	cpi	lf		;; 0381: fe 0a       ..
	rz			;; 0383: c8          .
	cpi	eof		;; 0384: fe 1a       ..
	rz			;; 0386: c8          .
	cpi	'!'		;; 0387: fe 21       ..
	ret			;; 0389: c9          .

L038a:	lda	L1607		;; 038a: 3a 07 16    :..
	ora	a		;; 038d: b7          .
	jz	L0406		;; 038e: ca 06 04    ...
	call	L2056		;; 0391: cd 56 20    .V 
L0394:	lda	curctx		;; 0394: 3a c4 34    :.4
	cpi	004h		;; 0397: fe 04       ..
	jnz	L03da		;; 0399: c2 da 03    ...
	lda	tokbuf+1	;; 039c: 3a c8 34    :.4
	call	L037b		;; 039f: cd 7b 03    .{.
	jz	L03f9		;; 03a2: ca f9 03    ...
	cpi	'%'		;; 03a5: fe 25       .%
	jnz	L03cf		;; 03a7: c2 cf 03    ...
	; macro param is expression (numeric value)
	call	L0f89		;; 03aa: cd 89 0f    ...
	shld	fmtval		;; 03ad: 22 22 16    "".
	mvi	a,0ffh		;; 03b0: 3e ff       >.
	sta	fmtsup		;; 03b2: 32 21 16    2..
	lda	curctx		;; 03b5: 3a c4 34    :.4
	cpi	004h		;; 03b8: fe 04       ..
	jnz	L03f6		;; 03ba: c2 f6 03    ...
	lda	tokbuf+1	;; 03bd: 3a c8 34    :.4
	push	psw		;; 03c0: f5          .
	xra	a		;; 03c1: af          .
	sta	tokbuf		;; 03c2: 32 c7 34    2.4
	call	fmtnum		;; 03c5: cd 2a 0f    .*.
	call	L046f		;; 03c8: cd 6f 04    .o.
	pop	psw		;; 03cb: f1          .
	jmp	L03eb		;; 03cc: c3 eb 03    ...

L03cf:	cpi	','		;; 03cf: fe 2c       .,
	jnz	L03da		;; 03d1: c2 da 03    ...
	call	L046b		;; 03d4: cd 6b 04    .k.
	jmp	L038a		;; 03d7: c3 8a 03    ...

L03da:	call	L046f		;; 03da: cd 6f 04    .o.
	call	L1dff		;; 03dd: cd ff 1d    ...
	lda	curctx		;; 03e0: 3a c4 34    :.4
	cpi	004h		;; 03e3: fe 04       ..
	jnz	L03f6		;; 03e5: c2 f6 03    ...
	lda	tokbuf+1	;; 03e8: 3a c8 34    :.4
L03eb:	call	L037b		;; 03eb: cd 7b 03    .{.
	jz	L03f9		;; 03ee: ca f9 03    ...
	cpi	','		;; 03f1: fe 2c       .,
	jz	L038a		;; 03f3: ca 8a 03    ...
L03f6:	call	Serror		;; 03f6: cd f9 15    ...
L03f9:	lda	L1607		;; 03f9: 3a 07 16    :..
	ora	a		;; 03fc: b7          .
	jz	L0406		;; 03fd: ca 06 04    ...
	call	L046b		;; 0400: cd 6b 04    .k.
	jmp	L03f9		;; 0403: c3 f9 03    ...

L0406:	lhld	tmpptr		;; 0406: 2a 25 35    *%5
	inx	h		;; 0409: 23          #
	push	h		;; 040a: e5          .
L040b:	lxi	h,curchr		;; 040b: 21 28 35    .(5
	mov	a,m		;; 040e: 7e          ~
	call	L0381		;; 040f: cd 81 03    ...
	jz	L041b		;; 0412: ca 1b 04    ...
	call	L1dff		;; 0415: cd ff 1d    ...
	jmp	L040b		;; 0418: c3 0b 04    ...

L041b:	xra	a		;; 041b: af          .
	mov	m,a		;; 041c: 77          w
	sta	L33e8		;; 041d: 32 e8 33    2.3
	call	L0440		;; 0420: cd 40 04    .@.
	lda	L1613		;; 0423: 3a 13 16    :..
	sta	L3428		;; 0426: 32 28 34    2(4
	call	L2279		;; 0429: cd 79 22    .y"
	pop	h		;; 042c: e1          .
	shld	L33c6		;; 042d: 22 c6 33    ".3
	pop	h		;; 0430: e1          .
	shld	L33f8		;; 0431: 22 f8 33    ".3
	xra	a		;; 0434: af          .
	sta	L33e8		;; 0435: 32 e8 33    2.3
	mvi	a,001h		;; 0438: 3e 01       >.
	sta	L3376		;; 043a: 32 76 33    2v3
	jmp	L020d		;; 043d: c3 0d 02    ...

L0440:	lda	L3375		;; 0440: 3a 75 33    :u3
	ora	a		;; 0443: b7          .
	jz	L044c		;; 0444: ca 4c 04    .L.
	lxi	h,prnbuf+5	;; 0447: 21 50 34    .P4
	mvi	m,'+'		;; 044a: 36 2b       6+
L044c:	call	L3028		;; 044c: cd 28 30    .(0
	mvi	a,010h		;; 044f: 3e 10       >.
	sta	L34c3		;; 0451: 32 c3 34    2.4
	ret			;; 0454: c9          .

; "pop" until L3376[0] is >2 or 1
; called by ENDM
L0455:	lda	L3375		;; 0455: 3a 75 33    :u3
	ora	a		;; 0458: b7          .
	jz	Berror		;; 0459: ca f3 15    ...
	lda	L3376		;; 045c: 3a 76 33    :v3
	cpi	003h		;; 045f: fe 03       ..
	rnc			;; 0461: d0          .
	cpi	001h		;; 0462: fe 01       ..
	rz			;; 0464: c8          .
	; if L3376[0] is 2 or 0...
	call	L22c0		;; 0465: cd c0 22    .."
	jmp	L0455		;; 0468: c3 55 04    .U.

L046b:	xra	a		;; 046b: af          .
	sta	tokbuf		;; 046c: 32 c7 34    2.4
L046f:	call	strdup		;; 046f: cd 8b 24    ..$
	call	getstr		;; 0472: cd 87 25    ..%
	call	symdup		;; 0475: cd a9 24    ..$
	lxi	h,L1607		;; 0478: 21 07 16    ...
	dcr	m		;; 047b: 35          5
	ret			;; 047c: c9          .

L047d:	lhld	curlbl		;; 047d: 2a 08 16    *..
	mov	a,l		;; 0480: 7d          }
	ora	h		;; 0481: b4          .
	cnz	Lerror		;; 0482: c4 e7 15    ...
	lhld	cursym		;; 0485: 2a 23 35    *#5
	shld	curlbl		;; 0488: 22 08 16    "..
	call	L1dff		;; 048b: cd ff 1d    ...
	lda	curctx		;; 048e: 3a c4 34    :.4
	cpi	004h		;; 0491: fe 04       ..
	jnz	L0210		;; 0493: c2 10 02    ...
	lda	tokbuf+1	;; 0496: 3a c8 34    :.4
	cpi	':'		;; 0499: fe 3a       .:
	jnz	L0210		;; 049b: c2 10 02    ...
	jmp	L020d		;; 049e: c3 0d 02    ...

L04a1:	cpi	01ah		;; 04a1: fe 1a       ..
	jnz	L0e3d		;; 04a3: c2 3d 0e    .=.
	; pseudo-ops... B is index
	mov	e,b		;; 04a6: 58          X
	mvi	d,0		;; 04a7: 16 00       ..
	dcx	d		;; 04a9: 1b          .
	lxi	h,poptbl	;; 04aa: 21 b4 04    ...
	dad	d		;; 04ad: 19          .
	dad	d		;; 04ae: 19          .
	mov	e,m		;; 04af: 5e          ^
	inx	h		;; 04b0: 23          #
	mov	h,m		;; 04b1: 66          f
	mov	l,e		;; 04b2: 6b          k
	pchl			;; 04b3: e9          .

; pseudo-op table
poptbl:	dw	pDB	; 1 DB
	dw	pDS	; 2 DS
	dw	pDW	; 3 DW
	dw	pEND	; 4 END
	dw	pENDIF	; 5 ENDIF
	dw	pENDM	; 6 ENDM
	dw	pEQU	; 7 EQU
	dw	pIF	; 8 IF
	dw	pMACRO	; 9 MACRO
	dw	pORG	; 10 ORG
	dw	pSET	; 11 SET
	dw	pTITLE	; 12 TITLE
	dw	pELSE	; 13 ELSE
	dw	pIRP	; 14 IRP
	dw	pIRPC	; 15 IRPC
	dw	pREPT	; 16 REPT
	dw	pASEG	; 17 ASEG
	dw	pCSEG	; 18 CSEG
	dw	pDSEG	; 19 DSEG
	dw	pNAME	; 20 NAME
	dw	pPAGE	; 21 PAGE
	dw	pEXITM	; 22 EXITM
	dw	pEXTRN	; 23 EXTRN
	dw	pLOCAL	; 24 LOCAL
	dw	pNPAGE	; 25 INPAGE
	dw	pMACLI	; 26 MACLIB
	dw	pPUBLI	; 27 PUBLIC
	dw	pSTKLN	; 28 STKLN
	dw	pCOMMO	; 29 COMMON

pDB:	call	L11fd		;; 04ee: cd fd 11    ...
L04f1:	call	L1dff		;; 04f1: cd ff 1d    ...
	lda	curctx		;; 04f4: 3a c4 34    :.4
	cpi	003h		;; 04f7: fe 03       ..
	jnz	L051f		;; 04f9: c2 1f 05    ...
	lda	tokbuf		;; 04fc: 3a c7 34    :.4
	dcr	a		;; 04ff: 3d          =
	jz	L051f		;; 0500: ca 1f 05    ...
	mov	b,a		;; 0503: 47          G
	inr	b		;; 0504: 04          .
	inr	b		;; 0505: 04          .
	lxi	h,tokbuf+1	;; 0506: 21 c8 34    ..4
L0509:	dcr	b		;; 0509: 05          .
	jz	L0519		;; 050a: ca 19 05    ...
	push	b		;; 050d: c5          .
	mov	b,m		;; 050e: 46          F
	inx	h		;; 050f: 23          #
	push	h		;; 0510: e5          .
	call	asmbyt		;; 0511: cd 49 12    .I.
	pop	h		;; 0514: e1          .
	pop	b		;; 0515: c1          .
	jmp	L0509		;; 0516: c3 09 05    ...

L0519:	call	L1dff		;; 0519: cd ff 1d    ...
	jmp	L052c		;; 051c: c3 2c 05    .,.

L051f:	call	L1915		;; 051f: cd 15 19    ...
	lhld	L3508		;; 0522: 2a 08 35    *.5
	call	chkbyh		;; 0525: cd 98 0f    ...
	mov	b,l		;; 0528: 45          E
	call	asmbyt		;; 0529: cd 49 12    .I.
L052c:	call	synadr		;; 052c: cd ec 11    ...
	call	L0f72		;; 052f: cd 72 0f    .r.
	cpi	','		;; 0532: fe 2c       .,
	jz	L04f1		;; 0534: ca f1 04    ...
	jmp	L1002		;; 0537: c3 02 10    ...

pDS:	call	L11fd		;; 053a: cd fd 11    ...
	call	prnbeg		;; 053d: cd 6f 13    .o.
	call	L0f89		;; 0540: cd 89 0f    ...
	xchg			;; 0543: eb          .
	push	d		;; 0544: d5          .
	call	getadr		;; 0545: cd 6e 32    .n2
	pop	d		;; 0548: d1          .
	dad	d		;; 0549: 19          .
	shld	curadr		;; 054a: 22 16 35    ".5
	call	setadr		;; 054d: cd 7e 32    .~2
	call	relloc		;; 0550: cd ec 0b    ...
	jmp	L1002		;; 0553: c3 02 10    ...

pDW:	call	L11fd		;; 0556: cd fd 11    ...
L0559:	call	asmref		;; 0559: cd da 0f    ...
	call	synadr		;; 055c: cd ec 11    ...
	call	L0f72		;; 055f: cd 72 0f    .r.
	cpi	','		;; 0562: fe 2c       .,
	jz	L0559		;; 0564: ca 59 05    .Y.
	jmp	L1002		;; 0567: c3 02 10    ...

pEND:	call	L11fd		;; 056a: cd fd 11    ...
	call	prnbeg		;; 056d: cd 6f 13    .o.
	call	savseg		;; 0570: cd d1 0b    ...
	lda	curerr		;; 0573: 3a 4b 34    :K4
	cpi	' '		;; 0576: fe 20       . 
	jnz	L1002		;; 0578: c2 02 10    ...
	call	L0f89		;; 057b: cd 89 0f    ...
	lda	curerr		;; 057e: 3a 4b 34    :K4
	cpi	' '		;; 0581: fe 20       . 
	jnz	L058f		;; 0583: c2 8f 05    ...
	shld	L160c		;; 0586: 22 0c 16    "..
	lda	L350a		;; 0589: 3a 0a 35    :.5
	sta	L160e		;; 058c: 32 0e 16    2..
L058f:	mvi	a,' '		;; 058f: 3e 20       > 
	sta	curerr		;; 0591: 32 4b 34    2K4
	lda	L1613		;; 0594: 3a 13 16    :..
	ora	a		;; 0597: b7          .
	cnz	Berror		;; 0598: c4 f3 15    ...
	call	L1dff		;; 059b: cd ff 1d    ...
	lda	curctx		;; 059e: 3a c4 34    :.4
	cpi	004h		;; 05a1: fe 04       ..
	jnz	Serro2		;; 05a3: c2 4d 10    .M.
	lda	tokbuf+1	;; 05a6: 3a c8 34    :.4
	cpi	lf		;; 05a9: fe 0a       ..
	jnz	Serro2		;; 05ab: c2 4d 10    .M.
	jmp	L1111		;; 05ae: c3 11 11    ...

pENDIF:	call	L11fd		;; 05b1: cd fd 11    ...
	call	L0a67		;; 05b4: cd 67 0a    .g.
	jmp	L0e25		;; 05b7: c3 25 0e    .%.

pENDM:	push	b		;; 05ba: c5          .
	call	L11fd		;; 05bb: cd fd 11    ...
	call	L0455		;; 05be: cd 55 04    .U.
	lxi	h,prnbuf+5	;; 05c1: 21 50 34    .P4
	mvi	m,'+'		;; 05c4: 36 2b       6+
	lda	L3376		;; 05c6: 3a 76 33    :v3
	cpi	003h		;; 05c9: fe 03       ..
	jnc	L05d5		;; 05cb: d2 d5 05    ...
	pop	b		;; 05ce: c1          .
	call	L24bf		;; 05cf: cd bf 24    ..$
	jmp	L06bd		;; 05d2: c3 bd 06    ...

L05d5:	lhld	L33f8		;; 05d5: 2a f8 33    *.3
	push	h		;; 05d8: e5          .
	lhld	L3386		;; 05d9: 2a 86 33    *.3
	shld	L33f8		;; 05dc: 22 f8 33    ".3
	call	L24bf		;; 05df: cd bf 24    ..$
	pop	h		;; 05e2: e1          .
	shld	L33f8		;; 05e3: 22 f8 33    ".3
	pop	psw		;; 05e6: f1          .
	cpi	6		;; 05e7: fe 06       ..
	jnz	L06bd		;; 05e9: c2 bd 06    ...
L05ec:	lda	L3376		;; 05ec: 3a 76 33    :v3
	cpi	6		;; 05ef: fe 06       ..
	jnz	L0606		;; 05f1: c2 06 06    ...
	lhld	L3386		;; 05f4: 2a 86 33    *.3
	mov	e,m		;; 05f7: 5e          ^
	inx	h		;; 05f8: 23          #
	mov	d,m		;; 05f9: 56          V
	mov	a,e		;; 05fa: 7b          {
	ora	d		;; 05fb: b2          .
	jz	L06bd		;; 05fc: ca bd 06    ...
	dcx	d		;; 05ff: 1b          .
	mov	m,d		;; 0600: 72          r
	dcx	h		;; 0601: 2b          +
	mov	m,e		;; 0602: 73          s
	jmp	L06dc		;; 0603: c3 dc 06    ...

L0606:	lhld	L3386		;; 0606: 2a 86 33    *.3
	mov	e,m		;; 0609: 5e          ^
	inx	h		;; 060a: 23          #
	mov	d,m		;; 060b: 56          V
	ldax	d		;; 060c: 1a          .
	cpi	cr		;; 060d: fe 0d       ..
	jz	L06bd		;; 060f: ca bd 06    ...
	ora	a		;; 0612: b7          .
	jz	L062d		;; 0613: ca 2d 06    .-.
	lda	L3376		;; 0616: 3a 76 33    :v3
	cpi	003h		;; 0619: fe 03       ..
	jnz	L063a		;; 061b: c2 3a 06    .:.
	ldax	d		;; 061e: 1a          .
	inx	d		;; 061f: 13          .
	mov	m,d		;; 0620: 72          r
	dcx	h		;; 0621: 2b          +
	mov	m,e		;; 0622: 73          s
	lxi	h,tokbuf	;; 0623: 21 c7 34    ..4
	mvi	m,001h		;; 0626: 36 01       6.
	inx	h		;; 0628: 23          #
	mov	m,a		;; 0629: 77          w
	jmp	L0634		;; 062a: c3 34 06    .4.

L062d:	mvi	a,cr		;; 062d: 3e 0d       >.
	stax	d		;; 062f: 12          .
	xra	a		;; 0630: af          .
	sta	tokbuf		;; 0631: 32 c7 34    2.4
L0634:	call	strdup		;; 0634: cd 8b 24    ..$
	jmp	L06ad		;; 0637: c3 ad 06    ...

L063a:	lxi	h,L3439		;; 063a: 21 39 34    .94
	mov	a,m		;; 063d: 7e          ~
	push	psw		;; 063e: f5          .
	mvi	m,0		;; 063f: 36 00       6.
	lxi	h,curchr		;; 0641: 21 28 35    .(5
	mov	a,m		;; 0644: 7e          ~
	push	psw		;; 0645: f5          .
	mvi	m,0		;; 0646: 36 00       6.
	xchg			;; 0648: eb          .
	shld	L33c6		;; 0649: 22 c6 33    ".3
	mov	a,m		;; 064c: 7e          ~
	sui	','		;; 064d: d6 2c       .,
	jnz	L065f		;; 064f: c2 5f 06    ._.
	inx	h		;; 0652: 23          #
	push	h		;; 0653: e5          .
	lxi	h,tokbuf	;; 0654: 21 c7 34    ..4
	mov	m,a		;; 0657: 77          w
	call	strdup		;; 0658: cd 8b 24    ..$
	pop	h		;; 065b: e1          .
	jmp	L068f		;; 065c: c3 8f 06    ...

L065f:	push	h		;; 065f: e5          .
	call	L2056		;; 0660: cd 56 20    .V 
	pop	d		;; 0663: d1          .
	lhld	L33e6		;; 0664: 2a e6 33    *.3
	call	compr1		;; 0667: cd e6 11    ...
	jnz	L066f		;; 066a: c2 6f 06    .o.
	mvi	m,0		;; 066d: 36 00       6.
L066f:	call	strdup		;; 066f: cd 8b 24    ..$
	lhld	L33c6		;; 0672: 2a c6 33    *.3
	mov	a,m		;; 0675: 7e          ~
	ora	a		;; 0676: b7          .
	jnz	L067f		;; 0677: c2 7f 06    ...
	mvi	m,cr		;; 067a: 36 0d       6.
	jmp	L069e		;; 067c: c3 9e 06    ...

L067f:	lhld	L33e6		;; 067f: 2a e6 33    *.3
	push	h		;; 0682: e5          .
	call	L1dff		;; 0683: cd ff 1d    ...
	lda	tokbuf+1	;; 0686: 3a c8 34    :.4
	cpi	','		;; 0689: fe 2c       .,
	cnz	Serror		;; 068b: c4 f9 15    ...
	pop	h		;; 068e: e1          .
L068f:	shld	L33c6		;; 068f: 22 c6 33    ".3
	mov	a,m		;; 0692: 7e          ~
	cpi	cr		;; 0693: fe 0d       ..
	jnz	L069a		;; 0695: c2 9a 06    ...
	mvi	m,0		;; 0698: 36 00       6.
L069a:	xra	a		;; 069a: af          .
	sta	L343a		;; 069b: 32 3a 34    2:4
L069e:	xchg			;; 069e: eb          .
	lhld	L3386		;; 069f: 2a 86 33    *.3
	mov	m,e		;; 06a2: 73          s
	inx	h		;; 06a3: 23          #
	mov	m,d		;; 06a4: 72          r
	pop	psw		;; 06a5: f1          .
	sta	curchr		;; 06a6: 32 28 35    2(5
	pop	psw		;; 06a9: f1          .
	sta	L3439		;; 06aa: 32 39 34    294
L06ad:	lhld	L3386		;; 06ad: 2a 86 33    *.3
	inx	h		;; 06b0: 23          #
	shld	tmpptr		;; 06b1: 22 25 35    "%5
	call	getstr		;; 06b4: cd 87 25    ..%
	call	symdup		;; 06b7: cd a9 24    ..$
	jmp	L06dc		;; 06ba: c3 dc 06    ...

L06bd:	call	L0440		;; 06bd: cd 40 04    .@.
	lhld	L33f8		;; 06c0: 2a f8 33    *.3
	shld	memtop		;; 06c3: 22 11 35    ".5
	call	L22c0		;; 06c6: cd c0 22    .."
	lda	L3428		;; 06c9: 3a 28 34    :(4
	sta	L1613		;; 06cc: 32 13 16    2..
	lda	L33e8		;; 06cf: 3a e8 33    :.3
	sta	curchr		;; 06d2: 32 28 35    2(5
	ora	a		;; 06d5: b7          .
	cnz	L1ba2		;; 06d6: c4 a2 1b    ...
	jmp	L020d		;; 06d9: c3 0d 02    ...

L06dc:	mvi	a,010h		;; 06dc: 3e 10       >.
	sta	L34c3		;; 06de: 32 c3 34    2.4
	lhld	L33a6		;; 06e1: 2a a6 33    *.3
	shld	L33c6		;; 06e4: 22 c6 33    ".3
	xra	a		;; 06e7: af          .
	sta	curchr		;; 06e8: 32 28 35    2(5
	jmp	L020d		;; 06eb: c3 0d 02    ...

; send address followed by char in A to PRN output
L06ee:	push	psw		;; 06ee: f5          .
	call	L0f89		;; 06ef: cd 89 0f    ...
	call	prnadr		;; 06f2: cd 72 13    .r.
	pop	psw		;; 06f5: f1          .
	lxi	h,prnbuf+6	;; 06f6: 21 51 34    .Q4
	mov	m,a		;; 06f9: 77          w
	ret			;; 06fa: c9          .

pEQU:	call	getlbl		;; 06fb: cd f3 11    ...
	jz	Serro2		;; 06fe: ca 4d 10    .M.
	mvi	a,'='		;; 0701: 3e 3d       >=
	call	L06ee		;; 0703: cd ee 06    ...
	call	getadr		;; 0706: cd 6e 32    .n2
	push	h		;; 0709: e5          .
	lhld	L3508		;; 070a: 2a 08 35    *.5
	call	setadr		;; 070d: cd 7e 32    .~2
	call	L11fd		;; 0710: cd fd 11    ...
	call	symtyp		;; 0713: cd 1e 25    ..%
	ani	11111100b	;; 0716: e6 fc       ..
	lxi	h,L350a		;; 0718: 21 0a 35    ..5
	ora	m		;; 071b: b6          .
	call	settyp		;; 071c: cd 16 25    ..%
	pop	h		;; 071f: e1          .
	call	setadr		;; 0720: cd 7e 32    .~2
	jmp	L1002		;; 0723: c3 02 10    ...

pIF:	call	L11fd		;; 0726: cd fd 11    ...
	call	L0f89		;; 0729: cd 89 0f    ...
	lda	curerr		;; 072c: 3a 4b 34    :K4
	cpi	' '		;; 072f: fe 20       . 
	jnz	L0976		;; 0731: c2 76 09    .v.
	mov	a,l		;; 0734: 7d          }
	rar			;; 0735: 1f          .
	mvi	a,001h		;; 0736: 3e 01       >.
	jnc	L0976		;; 0738: d2 76 09    .v.
	call	L0a53		;; 073b: cd 53 0a    .S.
	jmp	L1002		;; 073e: c3 02 10    ...

pMACRO:	call	getlbl		;; 0741: cd f3 11    ...
	jnz	L074d		;; 0744: c2 4d 07    .M.
	call	Lerror		;; 0747: cd e7 15    ...
	jmp	L1002		;; 074a: c3 02 10    ...

; compile macro definition
L074d:	lda	pass		;; 074d: 3a 15 35    :.5
	ora	a		;; 0750: b7          .
	jz	L0770		;; 0751: ca 70 07    .p.
	lhld	cursym		;; 0754: 2a 23 35    *#5
	xchg			;; 0757: eb          .
	lhld	L161e		;; 0758: 2a 1e 16    *..
	call	compr1		;; 075b: cd e6 11    ...
	jz	L0767		;; 075e: ca 67 07    .g.
	call	Perror		;; 0761: cd e1 15    ...
	jmp	L0775		;; 0764: c3 75 07    .u.

L0767:	call	getval		;; 0767: cd 3e 25    .>%
	shld	L161e		;; 076a: 22 1e 16    "..
	jmp	L0775		;; 076d: c3 75 07    .u.

; construct macro definition
L0770:	mvi	a,020h		;; 0770: 3e 20       > 
	call	settyp		;; 0772: cd 16 25    ..%
L0775:	xra	a		;; 0775: af          .
	sta	L1620		;; 0776: 32 20 16    2 .
	lda	pass		;; 0779: 3a 15 35    :.5
	ora	a		;; 077c: b7          .
	cz	setmpc		;; 077d: cc 4f 25    .O%
; extract parameter name, repeat if ','
L0780:	call	L1dff		;; 0780: cd ff 1d    ...
	lda	curctx		;; 0783: 3a c4 34    :.4
	cpi	001h		;; 0786: fe 01       ..
	jnz	L07a9		;; 0788: c2 a9 07    ...
	lda	pass		;; 078b: 3a 15 35    :.5
	ora	a		;; 078e: b7          .
	cz	putstr		;; 078f: cc 5b 25    .[%
	lxi	h,L1620		;; 0792: 21 20 16    . .
	inr	m		;; 0795: 34          4
	call	L1dff		;; 0796: cd ff 1d    ...
	lda	curctx		;; 0799: 3a c4 34    :.4
	cpi	004h		;; 079c: fe 04       ..
	jnz	L07a9		;; 079e: c2 a9 07    ...
	lda	tokbuf+1	;; 07a1: 3a c8 34    :.4
	cpi	','		;; 07a4: fe 2c       .,
	jz	L0780		;; 07a6: ca 80 07    ...
L07a9:	mvi	a,001h		;; 07a9: 3e 01       >.
	call	L07ca		;; 07ab: cd ca 07    ...
	jz	L1118		;; 07ae: ca 18 11    ...
	lda	pass		;; 07b1: 3a 15 35    :.5
	ora	a		;; 07b4: b7          .
	lda	L1620		;; 07b5: 3a 20 16    : .
	cz	setmpc		;; 07b8: cc 4f 25    .O%
	jmp	L0e25		;; 07bb: c3 25 0e    .%.

L07be:	cpi	tab		;; 07be: fe 09       ..
	rz			;; 07c0: c8          .
	cpi	010h		;; 07c1: fe 10       ..
	rz			;; 07c3: c8          .
	cpi	00eh		;; 07c4: fe 0e       ..
	rz			;; 07c6: c8          .
	cpi	00fh		;; 07c7: fe 0f       ..
	ret			;; 07c9: c9          .

L07ca:	sta	L3529		;; 07ca: 32 29 35    2)5
L07cd:	lda	curctx		;; 07cd: 3a c4 34    :.4
	cpi	004h		;; 07d0: fe 04       ..
	jnz	L07e5		;; 07d2: c2 e5 07    ...
	lda	tokbuf+1	;; 07d5: 3a c8 34    :.4
	cpi	cr		;; 07d8: fe 0d       ..
	jz	L07ee		;; 07da: ca ee 07    ...
	cpi	'!'		;; 07dd: fe 21       ..
	jz	L07ee		;; 07df: ca ee 07    ...
	cpi	eof		;; 07e2: fe 1a       ..
	rz			;; 07e4: c8          .
L07e5:	call	Serror		;; 07e5: cd f9 15    ...
	call	L1dff		;; 07e8: cd ff 1d    ...
	jmp	L07cd		;; 07eb: c3 cd 07    ...

L07ee:	lhld	tmpptr		;; 07ee: 2a 25 35    *%5
	shld	L352d		;; 07f1: 22 2d 35    "-5
	mvi	a,001h		;; 07f4: 3e 01       >.
	sta	L3527		;; 07f6: 32 27 35    2'5
	call	L1dff		;; 07f9: cd ff 1d    ...
L07fc:	lhld	tmpptr		;; 07fc: 2a 25 35    *%5
	shld	L1626		;; 07ff: 22 26 16    "&.
	call	L1dff		;; 0802: cd ff 1d    ...
	lda	curctx		;; 0805: 3a c4 34    :.4
	cpi	004h		;; 0808: fe 04       ..
	jnz	L0813		;; 080a: c2 13 08    ...
	lda	tokbuf+1	;; 080d: 3a c8 34    :.4
	cpi	eof		;; 0810: fe 1a       ..
	rz			;; 0812: c8          .
L0813:	cpi	001h		;; 0813: fe 01       ..
	jnz	L07fc		;; 0815: c2 fc 07    ...
	call	keywrd		;; 0818: cd dd 28    ..(
	jnz	L07fc		;; 081b: c2 fc 07    ...
	push	psw		;; 081e: f5          .
	lda	L3529		;; 081f: 3a 29 35    :)5
	cpi	001h		;; 0822: fe 01       ..
	jnz	L084e		;; 0824: c2 4e 08    .N.
	lda	pass		;; 0827: 3a 15 35    :.5
	ora	a		;; 082a: b7          .
	jnz	L084e		;; 082b: c2 4e 08    .N.
	lda	tokbuf		;; 082e: 3a c7 34    :.4
	dcr	a		;; 0831: 3d          =
	jz	L084e		;; 0832: ca 4e 08    .N.
	dcr	c		;; 0835: 0d          .
	jz	L084e		;; 0836: ca 4e 08    .N.
	push	b		;; 0839: c5          .
	lhld	L1626		;; 083a: 2a 26 16    *&.
	shld	tmpptr		;; 083d: 22 25 35    "%5
	call	L2932		;; 0840: cd 32 29    .2)
	call	puttmp		;; 0843: cd ab 25    ..%
	lda	curchr		;; 0846: 3a 28 35    :(5
	ora	a		;; 0849: b7          .
	cnz	puttmp		;; 084a: c4 ab 25    ..%
	pop	b		;; 084d: c1          .
L084e:	pop	psw		;; 084e: f1          .
	cpi	eof		;; 084f: fe 1a       ..
	jnz	L07fc		;; 0851: c2 fc 07    ...
	mov	a,b		;; 0854: 78          x
	call	L07be		;; 0855: cd be 07    ...
	jnz	L0863		;; 0858: c2 63 08    .c.
	lxi	h,L3527		;; 085b: 21 27 35    .'5
	inr	m		;; 085e: 34          4
	rz			;; 085f: c8          .
	jmp	L07fc		;; 0860: c3 fc 07    ...

L0863:	cpi	6		;; 0863: fe 06       ..
	jnz	L07fc		;; 0865: c2 fc 07    ...
	lxi	h,L3527		;; 0868: 21 27 35    .'5
	dcr	m		;; 086b: 35          5
	jnz	L07fc		;; 086c: c2 fc 07    ...
	lda	L3529		;; 086f: 3a 29 35    :)5
	cpi	001h		;; 0872: fe 01       ..
	jnz	L089e		;; 0874: c2 9e 08    ...
	lxi	h,0		;; 0877: 21 00 00    ...
	shld	curlbl		;; 087a: 22 08 16    "..
	lda	L352a		;; 087d: 3a 2a 35    :*5
	ora	a		;; 0880: b7          .
	jz	L088d		;; 0881: ca 8d 08    ...
	lxi	h,0		;; 0884: 21 00 00    ...
	call	putval		;; 0887: cd 35 25    .5%
	jmp	L0899		;; 088a: c3 99 08    ...

L088d:	lhld	L161c		;; 088d: 2a 1c 16    *..
	call	putval		;; 0890: cd 35 25    .5%
	lhld	cursym		;; 0893: 2a 23 35    *#5
	shld	L161c		;; 0896: 22 1c 16    "..
L0899:	lda	pass		;; 0899: 3a 15 35    :.5
	ora	a		;; 089c: b7          .
	rnz			;; 089d: c0          .
L089e:	lhld	tmpptr		;; 089e: 2a 25 35    *%5
	mov	a,m		;; 08a1: 7e          ~
	cpi	cr		;; 08a2: fe 0d       ..
	cnz	Serror		;; 08a4: c4 f9 15    ...
	lhld	tmpptr		;; 08a7: 2a 25 35    *%5
	mvi	m,cr		;; 08aa: 36 0d       6.
	xra	a		;; 08ac: af          .
	call	puttmp		;; 08ad: cd ab 25    ..%
	xra	a		;; 08b0: af          .
	inr	a		;; 08b1: 3c          <
	ret			;; 08b2: c9          .

pORG:	call	L0f89		;; 08b3: cd 89 0f    ...
	lda	curerr		;; 08b6: 3a 4b 34    :K4
	cpi	' '		;; 08b9: fe 20       . 
	jnz	L1002		;; 08bb: c2 02 10    ...
	shld	curadr		;; 08be: 22 16 35    ".5
	call	setadr		;; 08c1: cd 7e 32    .~2
	call	L11fd		;; 08c4: cd fd 11    ...
	call	prnbeg		;; 08c7: cd 6f 13    .o.
	call	relloc		;; 08ca: cd ec 0b    ...
	jmp	L1002		;; 08cd: c3 02 10    ...

pSET:	call	getlbl		;; 08d0: cd f3 11    ...
	jz	Serro2		;; 08d3: ca 4d 10    .M.
	call	symtyp		;; 08d6: cd 1e 25    ..%
	ora	a		;; 08d9: b7          .
	jz	L08e2		;; 08da: ca e2 08    ...
	ani	11111100b	;; 08dd: e6 fc       ..
	call	patch1		;; 08df: cd 28 01    .(.
;	cpi	040h
;	cnz	Lerror
;	ret
L08e2:	mvi	a,040h		;; 08e2: 3e 40       >@
	call	settyp		;; 08e4: cd 16 25    ..%
	mvi	a,'#'		;; 08e7: 3e 23       >#
	call	L06ee		;; 08e9: cd ee 06    ...
	call	getlbl		;; 08ec: cd f3 11    ...
	lhld	L3508		;; 08ef: 2a 08 35    *.5
	call	putval		;; 08f2: cd 35 25    .5%
	lxi	h,0		;; 08f5: 21 00 00    ...
	shld	curlbl		;; 08f8: 22 08 16    "..
	jmp	patch2		;; 08fb: c3 2e 01    ...

pTITLE:	lxi	h,L352f		;; 08fe: 21 2f 35    ./5
	shld	L162c		;; 0901: 22 2c 16    ",.
L0904:	call	L11fd		;; 0904: cd fd 11    ...
	call	L1dff		;; 0907: cd ff 1d    ...
	lda	curctx		;; 090a: 3a c4 34    :.4
	cpi	003h		;; 090d: fe 03       ..
	jnz	Serro2		;; 090f: c2 4d 10    .M.
	lda	L3527		;; 0912: 3a 27 35    :'5
	ora	a		;; 0915: b7          .
	jnz	Serro2		;; 0916: c2 4d 10    .M.
	lhld	L162c		;; 0919: 2a 2c 16    *,.
	mov	a,m		;; 091c: 7e          ~
	inx	h		;; 091d: 23          #
	ora	m		;; 091e: b6          .
	jnz	L0954		;; 091f: c2 54 09    .T.
	lda	pass		;; 0922: 3a 15 35    :.5
	ora	a		;; 0925: b7          .
	jnz	L0954		;; 0926: c2 54 09    .T.
	lxi	h,tokbuf	;; 0929: 21 c7 34    ..4
	mov	c,m		;; 092c: 4e          N
	push	h		;; 092d: e5          .
	lhld	nxheap		;; 092e: 2a 0f 35    *.5
	xchg			;; 0931: eb          .
	lhld	L162c		;; 0932: 2a 2c 16    *,.
	mov	m,e		;; 0935: 73          s
	inx	h		;; 0936: 23          #
	mov	m,d		;; 0937: 72          r
	xchg			;; 0938: eb          .
	dcx	h		;; 0939: 2b          +
	shld	tmpptr		;; 093a: 22 25 35    "%5
	pop	d		;; 093d: d1          .
L093e:	mov	a,c		;; 093e: 79          y
	ora	a		;; 093f: b7          .
	jz	L0950		;; 0940: ca 50 09    .P.
	inx	d		;; 0943: 13          .
	ldax	d		;; 0944: 1a          .
	dcr	c		;; 0945: 0d          .
	push	d		;; 0946: d5          .
	push	b		;; 0947: c5          .
	call	puttmp		;; 0948: cd ab 25    ..%
	pop	b		;; 094b: c1          .
	pop	d		;; 094c: d1          .
	jmp	L093e		;; 094d: c3 3e 09    .>.

L0950:	xra	a		;; 0950: af          .
	call	puttmp		;; 0951: cd ab 25    ..%
L0954:	jmp	L0e25		;; 0954: c3 25 0e    .%.

pELSE:	call	L11fd		;; 0957: cd fd 11    ...
	call	L0a67		;; 095a: cd 67 0a    .g.
	cpi	001h		;; 095d: fe 01       ..
	mvi	a,002h		;; 095f: 3e 02       >.
	jz	L0976		;; 0961: ca 76 09    .v.
	call	Berror		;; 0964: cd f3 15    ...
	jmp	L0e25		;; 0967: c3 25 0e    .%.

L096a:	cpi	tab		;; 096a: fe 09       ..
	rz			;; 096c: c8          .
	cpi	00eh		;; 096d: fe 0e       ..
	rz			;; 096f: c8          .
	cpi	00fh		;; 0970: fe 0f       ..
	rz			;; 0972: c8          .
	cpi	010h		;; 0973: fe 10       ..
	ret			;; 0975: c9          .

L0976:	sta	L1610		;; 0976: 32 10 16    2..
	xra	a		;; 0979: af          .
	sta	L1611		;; 097a: 32 11 16    2..
	sta	L1612		;; 097d: 32 12 16    2..
L0980:	lda	curctx		;; 0980: 3a c4 34    :.4
	cpi	004h		;; 0983: fe 04       ..
	jnz	L09a6		;; 0985: c2 a6 09    ...
	lda	tokbuf+1	;; 0988: 3a c8 34    :.4
	cpi	cr		;; 098b: fe 0d       ..
	jnz	L0996		;; 098d: c2 96 09    ...
	call	L1dff		;; 0990: cd ff 1d    ...
	jmp	L09ac		;; 0993: c3 ac 09    ...

L0996:	cpi	'!'		;; 0996: fe 21       ..
	jz	L09ac		;; 0998: ca ac 09    ...
	cpi	eof		;; 099b: fe 1a       ..
	jnz	L09a6		;; 099d: c2 a6 09    ...
	call	Berror		;; 09a0: cd f3 15    ...
	jmp	L1111		;; 09a3: c3 11 11    ...

L09a6:	call	L1dff		;; 09a6: cd ff 1d    ...
	jmp	L0980		;; 09a9: c3 80 09    ...

L09ac:	call	L1dff		;; 09ac: cd ff 1d    ...
	lda	curctx		;; 09af: 3a c4 34    :.4
	cpi	002h		;; 09b2: fe 02       ..
	cz	L1dff		;; 09b4: cc ff 1d    ...
	lda	curctx		;; 09b7: 3a c4 34    :.4
	cpi	001h		;; 09ba: fe 01       ..
	jnz	L0980		;; 09bc: c2 80 09    ...
	call	keywrd		;; 09bf: cd dd 28    ..(
	jz	L09e9		;; 09c2: ca e9 09    ...
	call	L1dff		;; 09c5: cd ff 1d    ...
	lda	curctx		;; 09c8: 3a c4 34    :.4
	cpi	004h		;; 09cb: fe 04       ..
	jnz	L09db		;; 09cd: c2 db 09    ...
	lda	tokbuf+1	;; 09d0: 3a c8 34    :.4
	cpi	':'		;; 09d3: fe 3a       .:
	jnz	L0980		;; 09d5: c2 80 09    ...
	call	L1dff		;; 09d8: cd ff 1d    ...
L09db:	lda	curctx		;; 09db: 3a c4 34    :.4
	cpi	001h		;; 09de: fe 01       ..
	jnz	L0980		;; 09e0: c2 80 09    ...
	call	keywrd		;; 09e3: cd dd 28    ..(
	jnz	L0980		;; 09e6: c2 80 09    ...
L09e9:	cpi	eof		;; 09e9: fe 1a       ..
	jnz	L0980		;; 09eb: c2 80 09    ...
	mov	a,b		;; 09ee: 78          x
	cpi	008h		;; 09ef: fe 08       ..
	jnz	L09fe		;; 09f1: c2 fe 09    ...
	lxi	h,L1611		;; 09f4: 21 11 16    ...
	inr	m		;; 09f7: 34          4
	cz	Oerror		;; 09f8: cc ed 15    ...
	jmp	L0980		;; 09fb: c3 80 09    ...

L09fe:	cpi	cr		;; 09fe: fe 0d       ..
	jnz	L0a1a		;; 0a00: c2 1a 0a    ...
	lda	L1611		;; 0a03: 3a 11 16    :..
	ora	a		;; 0a06: b7          .
	jnz	L0980		;; 0a07: c2 80 09    ...
	lda	L1610		;; 0a0a: 3a 10 16    :..
	cpi	002h		;; 0a0d: fe 02       ..
	cz	Berror		;; 0a0f: cc f3 15    ...
	mvi	a,002h		;; 0a12: 3e 02       >.
	call	L0a53		;; 0a14: cd 53 0a    .S.
	jmp	L0e25		;; 0a17: c3 25 0e    .%.

L0a1a:	cpi	005h		;; 0a1a: fe 05       ..
	jnz	L0a32		;; 0a1c: c2 32 0a    .2.
	lxi	h,L1611		;; 0a1f: 21 11 16    ...
	mov	a,m		;; 0a22: 7e          ~
	dcr	m		;; 0a23: 35          5
	ora	a		;; 0a24: b7          .
	jnz	L0980		;; 0a25: c2 80 09    ...
	lda	L1612		;; 0a28: 3a 12 16    :..
	ora	a		;; 0a2b: b7          .
	cnz	Berror		;; 0a2c: c4 f3 15    ...
	jmp	L0e25		;; 0a2f: c3 25 0e    .%.

L0a32:	call	L096a		;; 0a32: cd 6a 09    .j.
	jnz	L0a42		;; 0a35: c2 42 0a    .B.
	lxi	h,L1612		;; 0a38: 21 12 16    ...
	inr	m		;; 0a3b: 34          4
	cz	Oerror		;; 0a3c: cc ed 15    ...
	jmp	L0980		;; 0a3f: c3 80 09    ...

L0a42:	cpi	6		;; 0a42: fe 06       ..
	jnz	L0980		;; 0a44: c2 80 09    ...
	lxi	h,L1612		;; 0a47: 21 12 16    ...
	mov	a,m		;; 0a4a: 7e          ~
	dcr	m		;; 0a4b: 35          5
	ora	a		;; 0a4c: b7          .
	jnz	L0980		;; 0a4d: c2 80 09    ...
	jmp	pENDM		;; 0a50: c3 ba 05    ...

L0a53:	mov	b,a		;; 0a53: 47          G
	lxi	h,L1613		;; 0a54: 21 13 16    ...
	mov	a,m		;; 0a57: 7e          ~
	cpi	008h		;; 0a58: fe 08       ..
	jnc	Oerror		;; 0a5a: d2 ed 15    ...
	inr	m		;; 0a5d: 34          4
	mov	e,a		;; 0a5e: 5f          _
	mvi	d,0		;; 0a5f: 16 00       ..
	lxi	h,L1614		;; 0a61: 21 14 16    ...
	dad	d		;; 0a64: 19          .
	mov	m,b		;; 0a65: 70          p
	ret			;; 0a66: c9          .

L0a67:	lxi	h,L1613		;; 0a67: 21 13 16    ...
	mov	a,m		;; 0a6a: 7e          ~
	ora	a		;; 0a6b: b7          .
	jz	Berror		;; 0a6c: ca f3 15    ...
	dcr	m		;; 0a6f: 35          5
	mov	e,m		;; 0a70: 5e          ^
	mvi	d,0		;; 0a71: 16 00       ..
	lxi	h,L1614		;; 0a73: 21 14 16    ...
	dad	d		;; 0a76: 19          .
	mov	a,m		;; 0a77: 7e          ~
	ret			;; 0a78: c9          .

pIRP:	mvi	a,005h		;; 0a79: 3e 05       >.
	jmp	L0a80		;; 0a7b: c3 80 0a    ...

pIRPC:	mvi	a,003h		;; 0a7e: 3e 03       >.
L0a80:	sta	L3529		;; 0a80: 32 29 35    2)5
	call	L11fd		;; 0a83: cd fd 11    ...
	call	L1dff		;; 0a86: cd ff 1d    ...
	lda	curctx		;; 0a89: 3a c4 34    :.4
	cpi	001h		;; 0a8c: fe 01       ..
	jnz	L0b03		;; 0a8e: c2 03 0b    ...
	lhld	nxheap		;; 0a91: 2a 0f 35    *.5
	shld	L160a		;; 0a94: 22 0a 16    "..
	dcx	h		;; 0a97: 2b          +
	shld	tmpptr		;; 0a98: 22 25 35    "%5
	lda	tokbuf		;; 0a9b: 3a c7 34    :.4
	cpi	16		;; 0a9e: fe 10       ..
	jc	L0aa5		;; 0aa0: da a5 0a    ...
	mvi	a,16		;; 0aa3: 3e 10       >.
L0aa5:	adi	4		;; 0aa5: c6 04       ..
	call	puttmp		;; 0aa7: cd ab 25    ..%
	xra	a		;; 0aaa: af          .
	call	puttmp		;; 0aab: cd ab 25    ..%
	call	putstr		;; 0aae: cd 5b 25    .[%
	call	L1dff		;; 0ab1: cd ff 1d    ...
	lda	curctx		;; 0ab4: 3a c4 34    :.4
	cpi	004h		;; 0ab7: fe 04       ..
	jnz	L0b03		;; 0ab9: c2 03 0b    ...
	lda	tokbuf+1	;; 0abc: 3a c8 34    :.4
	cpi	','		;; 0abf: fe 2c       .,
	jnz	L0b03		;; 0ac1: c2 03 0b    ...
	call	L2056		;; 0ac4: cd 56 20    .V 
	lda	tokbuf		;; 0ac7: 3a c7 34    :.4
	ora	a		;; 0aca: b7          .
	jnz	L0ad4		;; 0acb: c2 d4 0a    ...
	call	L1dff		;; 0ace: cd ff 1d    ...
	jmp	L0af3		;; 0ad1: c3 f3 0a    ...

L0ad4:	call	L0e2b		;; 0ad4: cd 2b 0e    .+.
	jz	L0af3		;; 0ad7: ca f3 0a    ...
	lxi	h,tokbuf	;; 0ada: 21 c7 34    ..4
	mov	c,m		;; 0add: 4e          N
L0ade:	inx	h		;; 0ade: 23          #
	mov	a,m		;; 0adf: 7e          ~
	push	b		;; 0ae0: c5          .
	push	h		;; 0ae1: e5          .
	call	puttmp		;; 0ae2: cd ab 25    ..%
	pop	h		;; 0ae5: e1          .
	pop	b		;; 0ae6: c1          .
	dcr	c		;; 0ae7: 0d          .
	jnz	L0ade		;; 0ae8: c2 de 0a    ...
	mvi	a,cr		;; 0aeb: 3e 0d       >.
	call	puttmp		;; 0aed: cd ab 25    ..%
	call	L1dff		;; 0af0: cd ff 1d    ...
L0af3:	xra	a		;; 0af3: af          .
	call	puttmp		;; 0af4: cd ab 25    ..%
	lhld	nxheap		;; 0af7: 2a 0f 35    *.5
	shld	cursym		;; 0afa: 22 23 35    "#5
	lda	L3529		;; 0afd: 3a 29 35    :)5
	jmp	L0b2d		;; 0b00: c3 2d 0b    .-.

L0b03:	call	Serror		;; 0b03: cd f9 15    ...
	lda	L3529		;; 0b06: 3a 29 35    :)5
	call	L07ca		;; 0b09: cd ca 07    ...
	jmp	L0e25		;; 0b0c: c3 25 0e    .%.

pREPT:	call	L0f89		;; 0b0f: cd 89 0f    ...
	push	h		;; 0b12: e5          .
	mov	a,l		;; 0b13: 7d          }
	lhld	nxheap		;; 0b14: 2a 0f 35    *.5
	shld	L160a		;; 0b17: 22 0a 16    "..
	dcx	h		;; 0b1a: 2b          +
	shld	tmpptr		;; 0b1b: 22 25 35    "%5
	call	puttmp		;; 0b1e: cd ab 25    ..%
	pop	psw		;; 0b21: f1          .
	call	puttmp		;; 0b22: cd ab 25    ..%
	lhld	nxheap		;; 0b25: 2a 0f 35    *.5
	shld	cursym		;; 0b28: 22 23 35    "#5
	mvi	a,6		;; 0b2b: 3e 06       >.
L0b2d:	call	L07ca		;; 0b2d: cd ca 07    ...
	jz	L1118		;; 0b30: ca 18 11    ...
	call	L0440		;; 0b33: cd 40 04    .@.
	call	L1dff		;; 0b36: cd ff 1d    ...
	lda	L1613		;; 0b39: 3a 13 16    :..
	sta	L3428		;; 0b3c: 32 28 34    2(4
	lda	curchr		;; 0b3f: 3a 28 35    :(5
	cpi	lf		;; 0b42: fe 0a       ..
	jnz	L0b48		;; 0b44: c2 48 0b    .H.
	xra	a		;; 0b47: af          .
L0b48:	sta	L33e8		;; 0b48: 32 e8 33    2.3
	call	L2279		;; 0b4b: cd 79 22    .y"
	lhld	memtop		;; 0b4e: 2a 11 35    *.5
	shld	L33f8		;; 0b51: 22 f8 33    ".3
L0b54:	lhld	tmpptr		;; 0b54: 2a 25 35    *%5
	xchg			;; 0b57: eb          .
	lxi	h,L160a		;; 0b58: 21 0a 16    ...
	mov	a,e		;; 0b5b: 7b          {
	sub	m		;; 0b5c: 96          .
	inx	h		;; 0b5d: 23          #
	mov	a,d		;; 0b5e: 7a          z
	sbb	m		;; 0b5f: 9e          .
	xchg			;; 0b60: eb          .
	jc	L0b74		;; 0b61: da 74 0b    .t.
	mov	a,m		;; 0b64: 7e          ~
	dcx	h		;; 0b65: 2b          +
	shld	tmpptr		;; 0b66: 22 25 35    "%5
	lhld	memtop		;; 0b69: 2a 11 35    *.5
	dcx	h		;; 0b6c: 2b          +
	shld	memtop		;; 0b6d: 22 11 35    ".5
	mov	m,a		;; 0b70: 77          w
	jmp	L0b54		;; 0b71: c3 54 0b    .T.

L0b74:	inx	h		;; 0b74: 23          #
	shld	nxheap		;; 0b75: 22 0f 35    ".5
	lhld	memtop		;; 0b78: 2a 11 35    *.5
	shld	L3386		;; 0b7b: 22 86 33    ".3
	lda	L3529		;; 0b7e: 3a 29 35    :)5
	cpi	6		;; 0b81: fe 06       ..
	jz	L0b91		;; 0b83: ca 91 0b    ...
	mov	c,m		;; 0b86: 4e          N
	mvi	b,0		;; 0b87: 06 00       ..
	mov	e,l		;; 0b89: 5d          ]
	mov	d,h		;; 0b8a: 54          T
	dad	b		;; 0b8b: 09          .
	xchg			;; 0b8c: eb          .
	mov	m,e		;; 0b8d: 73          s
	inx	h		;; 0b8e: 23          #
	mov	m,d		;; 0b8f: 72          r
	dcx	h		;; 0b90: 2b          +
L0b91:	push	h		;; 0b91: e5          .
	lhld	cursym		;; 0b92: 2a 23 35    *#5
	xchg			;; 0b95: eb          .
	lhld	L160a		;; 0b96: 2a 0a 16    *..
	mov	a,e		;; 0b99: 7b          {
	sub	l		;; 0b9a: 95          .
	mov	e,a		;; 0b9b: 5f          _
	mov	a,d		;; 0b9c: 7a          z
	sbb	h		;; 0b9d: 9c          .
	mov	d,a		;; 0b9e: 57          W
	pop	h		;; 0b9f: e1          .
	dad	d		;; 0ba0: 19          .
	shld	L33a6		;; 0ba1: 22 a6 33    ".3
	lda	L3529		;; 0ba4: 3a 29 35    :)5
	sta	L3376		;; 0ba7: 32 76 33    2v3
	jmp	L05ec		;; 0baa: c3 ec 05    ...

pASEG:	call	savseg		;; 0bad: cd d1 0b    ...
	mvi	a,000h		;; 0bb0: 3e 00       >.
	jmp	pxSEG		;; 0bb2: c3 c2 0b    ...

pCSEG:	call	savseg		;; 0bb5: cd d1 0b    ...
	mvi	a,001h		;; 0bb8: 3e 01       >.
	jmp	pxSEG		;; 0bba: c3 c2 0b    ...

pDSEG:	call	savseg		;; 0bbd: cd d1 0b    ...
	mvi	a,002h		;; 0bc0: 3e 02       >.
pxSEG:	sta	curseg		;; 0bc2: 32 20 35    2 5
	call	getadr		;; 0bc5: cd 6e 32    .n2
	shld	curadr		;; 0bc8: 22 16 35    ".5
	call	relloc		;; 0bcb: cd ec 0b    ...
	jmp	L0e25		;; 0bce: c3 25 0e    .%.

; save info on current segment (only needed for COMMON).
; called when current segment is about to change.
savseg:	lda	curseg		;; 0bd1: 3a 20 35    : 5
	cpi	003h		;; 0bd4: fe 03       ..
	rnz			;; 0bd6: c0          .
	lhld	cursym		;; 0bd7: 2a 23 35    *#5
	push	h		;; 0bda: e5          .
	lhld	L350d		;; 0bdb: 2a 0d 35    *.5
	shld	cursym		;; 0bde: 22 23 35    "#5
	lhld	cmnadr		;; 0be1: 2a 1e 35    *.5
	call	putval		;; 0be4: cd 35 25    .5%
	pop	h		;; 0be7: e1          .
	shld	cursym		;; 0be8: 22 23 35    "#5
	ret			;; 0beb: c9          .

relloc:	lda	pass		;; 0bec: 3a 15 35    :.5
	ora	a		;; 0bef: b7          .
	rz			;; 0bf0: c8          .
	mvi	c,04bh	; set location counter
	call	rel7bs		;; 0bf3: cd 42 13    .B.
	call	getadr		;; 0bf6: cd 6e 32    .n2
	lda	curseg		;; 0bf9: 3a 20 35    : 5
	mov	c,a		;; 0bfc: 4f          O
	xchg			;; 0bfd: eb          .
	call	reladr		;; 0bfe: cd 30 13    .0.
	ret			;; 0c01: c9          .

pNAME:	lxi	h,L162a		;; 0c02: 21 2a 16    .*.
	shld	L162c		;; 0c05: 22 2c 16    ",.
	jmp	L0904		;; 0c08: c3 04 09    ...

pPAGE:	call	L11fd		;; 0c0b: cd fd 11    ...
	call	L1dff		;; 0c0e: cd ff 1d    ...
	call	L0e2b		;; 0c11: cd 2b 0e    .+.
	jz	L0c2b		;; 0c14: ca 2b 0c    .+.
	call	L1915		;; 0c17: cd 15 19    ...
	lhld	L3508		;; 0c1a: 2a 08 35    *.5
	lda	curerr		;; 0c1d: 3a 4b 34    :K4
	cpi	' '		;; 0c20: fe 20       . 
	jnz	L1002		;; 0c22: c2 02 10    ...
	call	L3001		;; 0c25: cd 01 30    ..0
	jmp	L1002		;; 0c28: c3 02 10    ...

L0c2b:	call	L0440		;; 0c2b: cd 40 04    .@.
	lda	pass		;; 0c2e: 3a 15 35    :.5
	ora	a		;; 0c31: b7          .
	cnz	L2fa8		;; 0c32: c4 a8 2f    ../
	jmp	L1002		;; 0c35: c3 02 10    ...

pEXITM:	jmp	pENDM		;; 0c38: c3 ba 05    ...

pEXTRN:	mvi	a,004h		;; 0c3b: 3e 04       >.
	sta	pubext		;; 0c3d: 32 29 16    2).
	jmp	L0d10		;; 0c40: c3 10 0d    ...

pLOCAL:	lda	L3375		;; 0c43: 3a 75 33    :u3
	ora	a		;; 0c46: b7          .
	jz	L0cad		;; 0c47: ca ad 0c    ...
L0c4a:	call	L1dff		;; 0c4a: cd ff 1d    ...
	lda	curctx		;; 0c4d: 3a c4 34    :.4
	cpi	001h		;; 0c50: fe 01       ..
	jnz	L0cad		;; 0c52: c2 ad 0c    ...
	; save name (tokbuf) onto heap
	lhld	nxheap		;; 0c55: 2a 0f 35    *.5
	push	h		;; 0c58: e5          .
	dcx	h		;; 0c59: 2b          +
	shld	tmpptr		;; 0c5a: 22 25 35    "%5
	call	putstr		;; 0c5d: cd 5b 25    .[%
	; create temp/local name
	xra	a		;; 0c60: af          .
	sta	fmtsup		;; 0c61: 32 21 16    2..
	inr	a		;; 0c64: 3c          <
	sta	tokbuf		;; 0c65: 32 c7 34    2.4
	lhld	locseq		;; 0c68: 2a 24 16    *$.
	inx	h		;; 0c6b: 23          #
	shld	locseq		;; 0c6c: 22 24 16    "$.
	shld	fmtval		;; 0c6f: 22 22 16    "".
	call	fmtnum		;; 0c72: cd 2a 0f    .*.
	lda	tokbuf+2	;; 0c75: 3a c9 34    :.4
	cpi	'0'		;; 0c78: fe 30       .0
	cnz	Oerror		;; 0c7a: c4 ed 15    ...
	lxi	h,'??'		;; 0c7d: 21 3f 3f    .??
	shld	tokbuf+1	;; 0c80: 22 c8 34    ".4
	; tokbuf = sprintf("??%04d", ++locseq);
	call	strdup		;; 0c83: cd 8b 24    ..$
	; restore name to tokbuf
	pop	h		;; 0c86: e1          .
	shld	nxheap		;; 0c87: 22 0f 35    ".5
	dcx	h		;; 0c8a: 2b          +
	shld	tmpptr		;; 0c8b: 22 25 35    "%5
	call	getstr		;; 0c8e: cd 87 25    ..%
	; tokbuf = string(tmpptr)
	call	symdup		;; 0c91: cd a9 24    ..$
	; next LOCAL name... if any
	call	L1dff		;; 0c94: cd ff 1d    ...
	call	L0e2b		;; 0c97: cd 2b 0e    .+.
	jz	L1002		;; 0c9a: ca 02 10    ...
	lda	curctx		;; 0c9d: 3a c4 34    :.4
	cpi	004h		;; 0ca0: fe 04       ..
	jnz	L0cad		;; 0ca2: c2 ad 0c    ...
	lda	tokbuf+1	;; 0ca5: 3a c8 34    :.4
	cpi	','		;; 0ca8: fe 2c       .,
	jz	L0c4a		;; 0caa: ca 4a 0c    .J.
L0cad:	call	Serror		;; 0cad: cd f9 15    ...
	jmp	L1002		;; 0cb0: c3 02 10    ...

pNPAGE:	jmp	L0e22		;; 0cb3: c3 22 0e    .".

pMACLI:	call	L11fd		;; 0cb6: cd fd 11    ...
	lhld	L161c		;; 0cb9: 2a 1c 16    *..
	mov	a,l		;; 0cbc: 7d          }
	ora	h		;; 0cbd: b4          .
	jnz	L0d05		;; 0cbe: c2 05 0d    ...
	lda	L352a		;; 0cc1: 3a 2a 35    :*5
	ora	a		;; 0cc4: b7          .
	jnz	L0d05		;; 0cc5: c2 05 0d    ...
	call	L1dff		;; 0cc8: cd ff 1d    ...
	lda	pass		;; 0ccb: 3a 15 35    :.5
	ora	a		;; 0cce: b7          .
	jnz	L0e25		;; 0ccf: c2 25 0e    .%.
	lda	curctx		;; 0cd2: 3a c4 34    :.4
	cpi	001h		;; 0cd5: fe 01       ..
	jnz	L0d05		;; 0cd7: c2 05 0d    ...
	call	libfil		;; 0cda: cd 13 2b    ..+
	lda	Lflag		;; 0cdd: 3a 32 35    :25
	ora	a		;; 0ce0: b7          .
	cnz	L2fa8		;; 0ce1: c4 a8 2f    ../
L0ce4:	call	L1dff		;; 0ce4: cd ff 1d    ...
	lda	curctx		;; 0ce7: 3a c4 34    :.4
	cpi	004h		;; 0cea: fe 04       ..
	jnz	L0ce4		;; 0cec: c2 e4 0c    ...
	lda	tokbuf+1	;; 0cef: 3a c8 34    :.4
	cpi	cr		;; 0cf2: fe 0d       ..
	jz	L0cfc		;; 0cf4: ca fc 0c    ...
	cpi	eof		;; 0cf7: fe 1a       ..
	jnz	L0ce4		;; 0cf9: c2 e4 0c    ...
L0cfc:	call	L0440		;; 0cfc: cd 40 04    .@.
	call	L2b53		;; 0cff: cd 53 2b    .S+
	jmp	L020d		;; 0d02: c3 0d 02    ...

L0d05:	call	Serror		;; 0d05: cd f9 15    ...
	jmp	L1002		;; 0d08: c3 02 10    ...

pPUBLI:	mvi	a,008h		;; 0d0b: 3e 08       >.
	sta	pubext		;; 0d0d: 32 29 16    2).
L0d10:	call	L11fd		;; 0d10: cd fd 11    ...
L0d13:	call	L1dff		;; 0d13: cd ff 1d    ...
	lda	curctx		;; 0d16: 3a c4 34    :.4
	cpi	001h		;; 0d19: fe 01       ..
	jnz	L0d84		;; 0d1b: c2 84 0d    ...
	call	look7		;; 0d1e: cd a3 23    ..#
	call	isNULL		;; 0d21: cd 76 23    .v#
	jnz	L0d3a		;; 0d24: c2 3a 0d    .:.
	; create "unknown" public symbol
	lda	pass		;; 0d27: 3a 15 35    :.5
	ora	a		;; 0d2a: b7          .
	cnz	Perror		;; 0d2b: c4 e1 15    ...
	call	newsym		;; 0d2e: cd 00 24    ..$
	lda	pubext		;; 0d31: 3a 29 16    :).
	call	settyp		;; 0d34: cd 16 25    ..%
	jmp	L0d6b		;; 0d37: c3 6b 0d    .k.

; public symbol already exists...
L0d3a:	call	symtyp		;; 0d3a: cd 1e 25    ..%
	mov	b,a		;; 0d3d: 47          G
	ani	020h		;; 0d3e: e6 20       . 
	jz	L0d49		;; 0d40: ca 49 0d    .I.
	; symbol is a macro... error...
	call	Perror		;; 0d43: cd e1 15    ...
	jmp	L0d6b		;; 0d46: c3 6b 0d    .k.

L0d49:	lda	pubext		;; 0d49: 3a 29 16    :).
	ora	b		;; 0d4c: b0          .
	call	settyp		;; 0d4d: cd 16 25    ..%
	lda	pubext		;; 0d50: 3a 29 16    :).
	cpi	004h		;; 0d53: fe 04       ..
	jz	L0d63		;; 0d55: ca 63 0d    .c.
	call	symtyp		;; 0d58: cd 1e 25    ..%
	ani	010h		;; 0d5b: e6 10       ..
	cz	Lerror		;; 0d5d: cc e7 15    ...
	jmp	L0d6b		;; 0d60: c3 6b 0d    .k.

L0d63:	call	symtyp		;; 0d63: cd 1e 25    ..%
	ani	010h		;; 0d66: e6 10       ..
	cnz	Lerror		;; 0d68: c4 e7 15    ...
; if (pubext == 004h && sym->type <> SF_SYM ||
;     pubext <> 004h && sym->type == SF_SYM) Lerror();
; if (pubext == 004h && sym->type == SF_SYM ||
;     pubext <> 004h && sym->type <> SF_SYM)...
L0d6b:	call	L1dff		;; 0d6b: cd ff 1d    ...
	call	L0e2b		;; 0d6e: cd 2b 0e    .+.
	jz	L1002		;; 0d71: ca 02 10    ...
	lda	curctx		;; 0d74: 3a c4 34    :.4
	cpi	004h		;; 0d77: fe 04       ..
	jnz	L0d84		;; 0d79: c2 84 0d    ...
	lda	tokbuf+1	;; 0d7c: 3a c8 34    :.4
	cpi	','		;; 0d7f: fe 2c       .,
	jz	L0d13		;; 0d81: ca 13 0d    ...
L0d84:	call	Serror		;; 0d84: cd f9 15    ...
	jmp	L1002		;; 0d87: c3 02 10    ...

pSTKLN:	jmp	L0e22		;; 0d8a: c3 22 0e    .".

pCOMMO:	call	savseg		;; 0d8d: cd d1 0b    ...
	call	L1dff		;; 0d90: cd ff 1d    ...
	lda	curctx		;; 0d93: 3a c4 34    :.4
	cpi	004h		;; 0d96: fe 04       ..
	jnz	L0e09		;; 0d98: c2 09 0e    ...
	lda	tokbuf+1	;; 0d9b: 3a c8 34    :.4
	cpi	'/'		;; 0d9e: fe 2f       ./
	jnz	L0e09		;; 0da0: c2 09 0e    ...
	call	L1dff		;; 0da3: cd ff 1d    ...
	lda	curctx		;; 0da6: 3a c4 34    :.4
	cpi	001h		;; 0da9: fe 01       ..
	jnz	L0e09		;; 0dab: c2 09 0e    ...
	lda	pass		;; 0dae: 3a 15 35    :.5
	ora	a		;; 0db1: b7          .
	jnz	L0dd5		;; 0db2: c2 d5 0d    ...
	call	newsym		;; 0db5: cd 00 24    ..$
	lhld	cursym		;; 0db8: 2a 23 35    *#5
	mov	e,m		;; 0dbb: 5e          ^
	inx	h		;; 0dbc: 23          #
	mov	d,m		;; 0dbd: 56          V
	lhld	symptr		;; 0dbe: 2a 53 22    *S"
	mov	m,e		;; 0dc1: 73          s
	inx	h		;; 0dc2: 23          #
	mov	m,d		;; 0dc3: 72          r
	lhld	L3513		;; 0dc4: 2a 13 35    *.5
	xchg			;; 0dc7: eb          .
	lhld	cursym		;; 0dc8: 2a 23 35    *#5
	mov	m,e		;; 0dcb: 73          s
	inx	h		;; 0dcc: 23          #
	mov	m,d		;; 0dcd: 72          r
	dcx	h		;; 0dce: 2b          +
	shld	L3513		;; 0dcf: 22 13 35    ".5
	jmp	L0de1		;; 0dd2: c3 e1 0d    ...

L0dd5:	call	L237c		;; 0dd5: cd 7c 23    .|#
	call	isNULL		;; 0dd8: cd 76 23    .v#
	cz	Perror		;; 0ddb: cc e1 15    ...
	lhld	cursym		;; 0dde: 2a 23 35    *#5
L0de1:	shld	L350d		;; 0de1: 22 0d 35    ".5
	call	L1dff		;; 0de4: cd ff 1d    ...
	lda	curctx		;; 0de7: 3a c4 34    :.4
	cpi	004h		;; 0dea: fe 04       ..
	jnz	L0e09		;; 0dec: c2 09 0e    ...
	lda	tokbuf+1	;; 0def: 3a c8 34    :.4
	cpi	'/'		;; 0df2: fe 2f       ./
	jnz	L0e09		;; 0df4: c2 09 0e    ...
	lxi	h,0		;; 0df7: 21 00 00    ...
	shld	cmnadr		;; 0dfa: 22 1e 35    ".5
	lda	pass		;; 0dfd: 3a 15 35    :.5
	ora	a		;; 0e00: b7          .
	cnz	L0e0f		;; 0e01: c4 0f 0e    ...
	mvi	a,003h		;; 0e04: 3e 03       >.
	jmp	pxSEG		;; 0e06: c3 c2 0b    ...

L0e09:	call	Serror		;; 0e09: cd f9 15    ...
	jmp	L0e25		;; 0e0c: c3 25 0e    .%.

L0e0f:	mvi	c,041h	; select common block
	call	rel7bs		;; 0e11: cd 42 13    .B.
	call	symlen		;; 0e14: cd 2c 23    .,#
	lhld	cursym		;; 0e17: 2a 23 35    *#5
	lxi	b,4		;; 0e1a: 01 04 00    ...
	dad	b		;; 0e1d: 09          .
	call	relsym		;; 0e1e: cd d6 12    ...
	ret			;; 0e21: c9          .

L0e22:	call	Nerror		;; 0e22: cd ff 15    ...
	;
L0e25:	call	L1dff		;; 0e25: cd ff 1d    ...
	jmp	L1002		;; 0e28: c3 02 10    ...

L0e2b:	lda	curctx		;; 0e2b: 3a c4 34    :.4
	cpi	004h		;; 0e2e: fe 04       ..
	rnz			;; 0e30: c0          .
	lda	tokbuf+1	;; 0e31: 3a c8 34    :.4
	cpi	cr		;; 0e34: fe 0d       ..
	rz			;; 0e36: c8          .
	cpi	'!'		;; 0e37: fe 21       ..
	rz			;; 0e39: c8          .
	cpi	';'		;; 0e3a: fe 3b       .;
	ret			;; 0e3c: c9          .

; must be machine opcode?
L0e3d:	sui	01ch		;; 0e3d: d6 1c       ..
	cpi	02ah	;***BUG***	;; 0e3f: fe 2a       .*
	jnc	Serro2		;; 0e41: d2 4d 10    .M.
	; 1ch-2ah - instructions
	mov	e,a		;; 0e44: 5f          _
	mvi	d,0		;; 0e45: 16 00       ..
	lxi	h,instbl	;; 0e47: 21 51 0e    .Q.
	dad	d		;; 0e4a: 19          .
	dad	d		;; 0e4b: 19          .
	mov	e,m		;; 0e4c: 5e          ^
	inx	h		;; 0e4d: 23          #
	mov	h,m		;; 0e4e: 66          f
	mov	l,e		;; 0e4f: 6b          k
	pchl			;; 0e50: e9          .

; instructions
instbl:	dw	opnone	; 1ch - no operand
	dw	opX1W	; 1dh - LXI
	dw	opX1	; 1eh - DAD
	dw	opX2	; 1fh - PUSH/POP
	dw	opW1	; 20h - JMP/CALL
	dw	opRR	; 21h - MOV
	dw	opRB	; 22h - MVI
	dw	opB1	; 23h - arith/logic imm
	dw	opX3	; 24h - LDAX/STAX
	dw	opW2	; 25h - LDA/STA/LHLD/SHLD
	dw	opR1	; 26h - arith/logic reg
	dw	opR2	; 27h - INR/DCR
	dw	opX4	; 28h - INX/DCX
	dw	opN	; 29h - RST
	dw	opB2	; 2ah - IN/OUT

; opcode with no operands
opnone:	call	asmbyt		;; 0e6f: cd 49 12    .I.
	call	L1dff		;; 0e72: cd ff 1d    ...
	jmp	L0f17		;; 0e75: c3 17 0f    ...

; opcode with regpair set 1,word
opX1W:	call	L0fc5		;; 0e78: cd c5 0f    ...
	call	L0fe8		;; 0e7b: cd e8 0f    ...
	call	asmref		;; 0e7e: cd da 0f    ...
	jmp	L0f17		;; 0e81: c3 17 0f    ...

; opcode with regpair set 1 (B,D,H,SP)
opX1:	call	L0fc5		;; 0e84: cd c5 0f    ...
	jmp	L0f17		;; 0e87: c3 17 0f    ...

; opcode with regpair set 2 (B,D,H,PSW)
opX2:	call	L0fbb		;; 0e8a: cd bb 0f    ...
	cpi	038h		;; 0e8d: fe 38       .8
	jz	L0e97		;; 0e8f: ca 97 0e    ...
	ani	008h		;; 0e92: e6 08       ..
	cnz	Rerror		;; 0e94: c4 c7 15    ...
L0e97:	mov	a,c		;; 0e97: 79          y
	ani	030h		;; 0e98: e6 30       .0
	ora	b		;; 0e9a: b0          .
	jmp	L0f14		;; 0e9b: c3 14 0f    ...

; opcode with word - exec target, jump/call
opW1:	call	asmbyt		;; 0e9e: cd 49 12    .I.
	call	asmref		;; 0ea1: cd da 0f    ...
	jmp	L0f17		;; 0ea4: c3 17 0f    ...

; opcode with two single-reg operands (reg,reg) (00tttsss)
opRR:	call	L0fbb		;; 0ea7: cd bb 0f    ...
	ora	b		;; 0eaa: b0          .
	mov	b,a		;; 0eab: 47          G
	call	L0fe8		;; 0eac: cd e8 0f    ...
	call	L0fb0		;; 0eaf: cd b0 0f    ...
	ora	b		;; 0eb2: b0          .
	jmp	L0f14		;; 0eb3: c3 14 0f    ...

; opcode with reg,byte operands, move imm (00rrr000)
opRB:	call	L0fbb		;; 0eb6: cd bb 0f    ...
	ora	b		;; 0eb9: b0          .
	call	asmbya		;; 0eba: cd 48 12    .H.
	call	L0fe8		;; 0ebd: cd e8 0f    ...
	call	L0fd4		;; 0ec0: cd d4 0f    ...
	jmp	L0f17		;; 0ec3: c3 17 0f    ...

; opcode with byte (imm) operand
opB1:	call	asmbyt		;; 0ec6: cd 49 12    .I.
	call	L0fd4		;; 0ec9: cd d4 0f    ...
	jmp	L0f17		;; 0ecc: c3 17 0f    ...

; opcode with regpair set 3 (B,D) (000x0000)
opX3:	call	L0fbb		;; 0ecf: cd bb 0f    ...
	ani	028h		;; 0ed2: e6 28       .(
	cnz	Rerror		;; 0ed4: c4 c7 15    ...
	mov	a,c		;; 0ed7: 79          y
	ani	010h		;; 0ed8: e6 10       ..
	ora	b		;; 0eda: b0          .
	jmp	L0f14		;; 0edb: c3 14 0f    ...

; opcode with word (data target)
opW2:	call	asmbyt		;; 0ede: cd 49 12    .I.
	call	asmref		;; 0ee1: cd da 0f    ...
	jmp	L0f17		;; 0ee4: c3 17 0f    ...

; opcode with reg, arith/logic (00000rrr)
opR1:	call	L0fb0		;; 0ee7: cd b0 0f    ...
	ora	b		;; 0eea: b0          .
	jmp	L0f14		;; 0eeb: c3 14 0f    ...

; opcode with reg, increment/decrement (00rrr000)
opR2:	call	L0fbb		;; 0eee: cd bb 0f    ...
	ora	b		;; 0ef1: b0          .
	jmp	L0f14		;; 0ef2: c3 14 0f    ...

; opcode with reg-pair set 4 (B,D,H,SP), increment/decrement (00xx0000)
opX4:	call	L0fbb		;; 0ef5: cd bb 0f    ...
	ani	008h		;; 0ef8: e6 08       ..
	cnz	Rerror		;; 0efa: c4 c7 15    ...
	mov	a,c		;; 0efd: 79          y
	ani	030h		;; 0efe: e6 30       .0
	ora	b		;; 0f00: b0          .
	jmp	L0f14		;; 0f01: c3 14 0f    ...

; opcode with number (0-7), restart instructions
; NOTE: same code as opR2
opN:	call	L0fbb		;; 0f04: cd bb 0f    ...
	ora	b		;; 0f07: b0          .
	jmp	L0f14		;; 0f08: c3 14 0f    ...

; opcode with byte, input/output port
; NOTE: same code as opB1
opB2:	call	asmbyt		;; 0f0b: cd 49 12    .I.
	call	L0fd4		;; 0f0e: cd d4 0f    ...
	jmp	L0f17		;; 0f11: c3 17 0f    ...

L0f14:	call	asmbya		;; 0f14: cd 48 12    .H.
L0f17:	call	L11fd		;; 0f17: cd fd 11    ...
	call	synadr		;; 0f1a: cd ec 11    ...
	jmp	L1002		;; 0f1d: c3 02 10    ...

L0f20:	dw	10000
	dw	1000
	dw	100
	dw	10
	dw	1

; convert number in (fmtval) to ASCII decimal string appended to tokbuf.
; leading zeros suppressed if fmtsup != 0. destructive to fmtval and fmtsup.
fmtnum:	mvi	b,5
	lxi	h,L0f20		;; 0f2c: 21 20 0f    . .
L0f2f:	mov	e,m		;; 0f2f: 5e          ^
	inx	h		;; 0f30: 23          #
	mov	d,m		;; 0f31: 56          V
	inx	h		;; 0f32: 23          #
	push	h		;; 0f33: e5          .
	lhld	fmtval		;; 0f34: 2a 22 16    *".
	mvi	c,'0'		;; 0f37: 0e 30       .0
L0f39:	mov	a,l		;; 0f39: 7d          }
	sub	e		;; 0f3a: 93          .
	mov	l,a		;; 0f3b: 6f          o
	mov	a,h		;; 0f3c: 7c          |
	sbb	d		;; 0f3d: 9a          .
	mov	h,a		;; 0f3e: 67          g
	jc	L0f46		;; 0f3f: da 46 0f    .F.
	inr	c		;; 0f42: 0c          .
	jmp	L0f39		;; 0f43: c3 39 0f    .9.

L0f46:	dad	d		;; 0f46: 19          .
	shld	fmtval		;; 0f47: 22 22 16    "".
	lda	fmtsup		;; 0f4a: 3a 21 16    :..
	ora	a		;; 0f4d: b7          .
	jz	L0f60		;; 0f4e: ca 60 0f    .`.
	mov	a,b		;; 0f51: 78          x
	dcr	a		;; 0f52: 3d          =
	jz	L0f60		;; 0f53: ca 60 0f    .`.
	mov	a,c		;; 0f56: 79          y
	cpi	'0'		;; 0f57: fe 30       .0
	jz	L0f6c		;; 0f59: ca 6c 0f    .l.
	xra	a		;; 0f5c: af          .
	sta	fmtsup		;; 0f5d: 32 21 16    2..
L0f60:	lxi	h,tokbuf	;; 0f60: 21 c7 34    ..4
	mov	e,m		;; 0f63: 5e          ^
	inr	m		;; 0f64: 34          4
	mvi	d,0		;; 0f65: 16 00       ..
	lxi	h,tokbuf+1	;; 0f67: 21 c8 34    ..4
	dad	d		;; 0f6a: 19          .
	mov	m,c		;; 0f6b: 71          q
L0f6c:	pop	h		;; 0f6c: e1          .
	dcr	b		;; 0f6d: 05          .
	jnz	L0f2f		;; 0f6e: c2 2f 0f    ./.
	ret			;; 0f71: c9          .

L0f72:	lda	curctx		;; 0f72: 3a c4 34    :.4
	cpi	004h		;; 0f75: fe 04       ..
	cnz	Derror		;; 0f77: c4 db 15    ...
	lda	tokbuf+1	;; 0f7a: 3a c8 34    :.4
	cpi	','		;; 0f7d: fe 2c       .,
	rz			;; 0f7f: c8          .
	cpi	';'		;; 0f80: fe 3b       .;
	rz			;; 0f82: c8          .
	cpi	cr		;; 0f83: fe 0d       ..
	cnz	Derror		;; 0f85: c4 db 15    ...
	ret			;; 0f88: c9          .

; evaluate current expression?
; returns HL=value (also L3508).
L0f89:	push	b		;; 0f89: c5          .
	call	L1dff		;; 0f8a: cd ff 1d    ...
	call	L1915		;; 0f8d: cd 15 19    ...
	lhld	L3508		;; 0f90: 2a 08 35    *.5
	pop	b		;; 0f93: c1          .
	ret			;; 0f94: c9          .

; check if value can be stored in a byte
chkbyt:	call	L0f89		;; 0f95: cd 89 0f    ...
chkbyh:	lda	L350a		;; 0f98: 3a 0a 35    :.5
	ani	007h		;; 0f9b: e6 07       ..
	jnz	L0faa		;; 0f9d: c2 aa 0f    ...
	mov	a,h		;; 0fa0: 7c          |
	ora	a		;; 0fa1: b7          .
	mov	a,l		;; 0fa2: 7d          }
	rz			;; 0fa3: c8          .
	inr	h		;; 0fa4: 24          $
	jnz	L0faa		;; 0fa5: c2 aa 0f    ...
	ora	a		;; 0fa8: b7          .
	rm			;; 0fa9: f8          .
L0faa:	call	Verror		;; 0faa: cd d1 15    ...
	xra	a		;; 0fad: af          .
	mov	l,a		;; 0fae: 6f          o
	ret			;; 0faf: c9          .

L0fb0:	call	chkbyt		;; 0fb0: cd 95 0f    ...
	cpi	008h		;; 0fb3: fe 08       ..
	cnc	Verror		;; 0fb5: d4 d1 15    ...
	ani	007h		;; 0fb8: e6 07       ..
	ret			;; 0fba: c9          .

L0fbb:	call	L0fb0		;; 0fbb: cd b0 0f    ...
	ral			;; 0fbe: 17          .
	ral			;; 0fbf: 17          .
	ral			;; 0fc0: 17          .
	ani	038h		;; 0fc1: e6 38       .8
	mov	c,a		;; 0fc3: 4f          O
	ret			;; 0fc4: c9          .

L0fc5:	call	L0fbb		;; 0fc5: cd bb 0f    ...
	ani	008h		;; 0fc8: e6 08       ..
	cnz	Rerror		;; 0fca: c4 c7 15    ...
	mov	a,c		;; 0fcd: 79          y
	ani	030h		;; 0fce: e6 30       .0
	ora	b		;; 0fd0: b0          .
	jmp	asmbya		;; 0fd1: c3 48 12    .H.

L0fd4:	call	chkbyt		;; 0fd4: cd 95 0f    ...
	jmp	asmbya		;; 0fd7: c3 48 12    .H.

asmref:	call	L0f89		;; 0fda: cd 89 0f    ...
	lda	L350a		;; 0fdd: 3a 0a 35    :.5
	ani	004h		;; 0fe0: e6 04       ..
	jnz	asmext		;; 0fe2: c2 6e 12    .n.
	jmp	asmadr		;; 0fe5: c3 ab 12    ...

L0fe8:	push	psw		;; 0fe8: f5          .
	push	b		;; 0fe9: c5          .
	lda	curctx		;; 0fea: 3a c4 34    :.4
	cpi	004h		;; 0fed: fe 04       ..
	jnz	L0ffa		;; 0fef: c2 fa 0f    ...
	lda	tokbuf+1	;; 0ff2: 3a c8 34    :.4
	cpi	','		;; 0ff5: fe 2c       .,
	jz	L0fff		;; 0ff7: ca ff 0f    ...
L0ffa:	mvi	a,'C'		;; 0ffa: 3e 43       >C
	call	seterr		;; 0ffc: cd d5 30    ..0
L0fff:	pop	b		;; 0fff: c1          .
	pop	psw		;; 1000: f1          .
	ret			;; 1001: c9          .

L1002:	call	L11fd		;; 1002: cd fd 11    ...
	lda	curctx		;; 1005: 3a c4 34    :.4
	cpi	004h		;; 1008: fe 04       ..
	jnz	Serro2		;; 100a: c2 4d 10    .M.
	lda	tokbuf+1	;; 100d: 3a c8 34    :.4
	cpi	cr		;; 1010: fe 0d       ..
	jnz	L101b		;; 1012: c2 1b 10    ...
	call	L1dff		;; 1015: cd ff 1d    ...
	jmp	L020d		;; 1018: c3 0d 02    ...

L101b:	cpi	';'		;; 101b: fe 3b       .;
	jnz	L1043		;; 101d: c2 43 10    .C.
	call	L11fd		;; 1020: cd fd 11    ...
L1023:	call	L1dff		;; 1023: cd ff 1d    ...
	lda	curctx		;; 1026: 3a c4 34    :.4
	cpi	004h		;; 1029: fe 04       ..
	jnz	L1023		;; 102b: c2 23 10    .#.
	lda	tokbuf+1	;; 102e: 3a c8 34    :.4
	cpi	lf		;; 1031: fe 0a       ..
	jz	L020d		;; 1033: ca 0d 02    ...
	cpi	eof		;; 1036: fe 1a       ..
	jz	L1111		;; 1038: ca 11 11    ...
	cpi	'!'		;; 103b: fe 21       ..
	jz	L020d		;; 103d: ca 0d 02    ...
	jmp	L1023		;; 1040: c3 23 10    .#.

L1043:	cpi	'!'		;; 1043: fe 21       ..
	jz	L020d		;; 1045: ca 0d 02    ...
	cpi	eof		;; 1048: fe 1a       ..
	jz	L1111		;; 104a: ca 11 11    ...
Serro2:	call	Serror		;; 104d: cd f9 15    ...
	jmp	L1023		;; 1050: c3 23 10    .#.

subtra:	mov	a,e		;; 1053: 7b          {
	sub	l		;; 1054: 95          .
	mov	l,a		;; 1055: 6f          o
	mov	a,d		;; 1056: 7a          z
	sbb	h		;; 1057: 9c          .
	mov	h,a		;; 1058: 67          g
	ret			;; 1059: c9          .

; Initial data to REL file
relini:	mvi	c,042h	; program name
	call	rel7bs		;; 105c: cd 42 13    .B.
	lhld	L162a		;; 105f: 2a 2a 16    **.
	mov	a,l		;; 1062: 7d          }
	ora	h		;; 1063: b4          .
	jnz	L106a		;; 1064: c2 6a 10    .j.
	lxi	h,deffcb+1	;; 1067: 21 5d 00    .].
L106a:	push	h		;; 106a: e5          .
	mvi	c,0		;; 106b: 0e 00       ..
L106d:	mov	a,m		;; 106d: 7e          ~
	ori	020h		;; 106e: f6 20       . 
	cpi	020h		;; 1070: fe 20       . 
	jz	L107d		;; 1072: ca 7d 10    .}.
	inr	c		;; 1075: 0c          .
	inx	h		;; 1076: 23          #
	mov	a,c		;; 1077: 79          y
	cpi	6		;; 1078: fe 06       ..
	jnz	L106d		;; 107a: c2 6d 10    .m.
L107d:	pop	h		;; 107d: e1          .
	mov	a,c		;; 107e: 79          y
	call	relsym		;; 107f: cd d6 12    ...
	mvi	a,001h		;; 1082: 3e 01       >.
	sta	L1628		;; 1084: 32 28 16    2(.
	mvi	a,008h		;; 1087: 3e 08       >.
	sta	L3376		;; 1089: 32 76 33    2v3
	call	L1396		;; 108c: cd 96 13    ...
	call	L10e2		;; 108f: cd e2 10    ...
	lhld	L3513		;; 1092: 2a 13 35    *.5
L1095:	mov	a,h		;; 1095: 7c          |
	ora	l		;; 1096: b5          .
	jz	L10c2		;; 1097: ca c2 10    ...
	push	h		;; 109a: e5          .
	mvi	c,045h	; define common size
	call	rel7bs		;; 109d: cd 42 13    .B.
	pop	h		;; 10a0: e1          .
	push	h		;; 10a1: e5          .
	shld	cursym		;; 10a2: 22 23 35    "#5
	call	getval		;; 10a5: cd 3e 25    .>%
	xchg			;; 10a8: eb          .
	mvi	c,000h		;; 10a9: 0e 00       ..
	call	reladr		;; 10ab: cd 30 13    .0.
	call	symlen		;; 10ae: cd 2c 23    .,#
	pop	h		;; 10b1: e1          .
	push	h		;; 10b2: e5          .
	lxi	b,4		;; 10b3: 01 04 00    ...
	dad	b		;; 10b6: 09          .
	call	relsym		;; 10b7: cd d6 12    ...
	pop	h		;; 10ba: e1          .
	mov	e,m		;; 10bb: 5e          ^
	inx	h		;; 10bc: 23          #
	mov	d,m		;; 10bd: 56          V
	xchg			;; 10be: eb          .
	jmp	L1095		;; 10bf: c3 95 10    ...

L10c2:	call	L10e2		;; 10c2: cd e2 10    ...
	mvi	c,04ah	; define data size
	call	rel7bs		;; 10c7: cd 42 13    .B.
	mvi	c,000h	; abs "address"
	lhld	dsgadr		;; 10cc: 2a 1c 35    *.5
	xchg			;; 10cf: eb          .
	call	reladr		;; 10d0: cd 30 13    .0.
	mvi	c,04dh	; define prog size
	call	rel7bs		;; 10d5: cd 42 13    .B.
	mvi	c,001h	; prog-relative "address"
	lhld	csgadr		;; 10da: 2a 1a 35    *.5
	xchg			;; 10dd: eb          .
	call	reladr		;; 10de: cd 30 13    .0.
	ret			;; 10e1: c9          .

L10e2:	lxi	h,0		;; 10e2: 21 00 00    ...
	shld	L162e		;; 10e5: 22 2e 16    "..
L10e8:	lhld	L3513		;; 10e8: 2a 13 35    *.5
	mov	a,l		;; 10eb: 7d          }
	ora	h		;; 10ec: b4          .
	jz	L110a		;; 10ed: ca 0a 11    ...
	shld	cursym		;; 10f0: 22 23 35    "#5
	push	h		;; 10f3: e5          .
	mov	e,m		;; 10f4: 5e          ^
	inx	h		;; 10f5: 23          #
	mov	d,m		;; 10f6: 56          V
	xchg			;; 10f7: eb          .
	shld	L3513		;; 10f8: 22 13 35    ".5
	lhld	L162e		;; 10fb: 2a 2e 16    *..
	xchg			;; 10fe: eb          .
	pop	h		;; 10ff: e1          .
	mov	m,e		;; 1100: 73          s
	inx	h		;; 1101: 23          #
	mov	m,d		;; 1102: 72          r
	dcx	h		;; 1103: 2b          +
	shld	L162e		;; 1104: 22 2e 16    "..
	jmp	L10e8		;; 1107: c3 e8 10    ...

L110a:	lhld	L162e		;; 110a: 2a 2e 16    *..
	shld	L3513		;; 110d: 22 13 35    ".5
	ret			;; 1110: c9          .

L1111:	lda	L3375		;; 1111: 3a 75 33    :u3
	ora	a		;; 1114: b7          .
	jz	L111b		;; 1115: ca 1b 11    ...
L1118:	call	Berror		;; 1118: cd f3 15    ...
L111b:	xra	a		;; 111b: af          .
	sta	L3527		;; 111c: 32 27 35    2'5
	lxi	h,pass		;; 111f: 21 15 35    ..5
	mov	a,m		;; 1122: 7e          ~
	inr	m		;; 1123: 34          4
	ora	a		;; 1124: b7          .
	jnz	L1150		;; 1125: c2 50 11    .P.
	lxi	h,0ffffh	;; 1128: 21 ff ff    ...
	shld	L161e		;; 112b: 22 1e 16    "..
L112e:	lhld	L161c		;; 112e: 2a 1c 16    *..
	mov	a,h		;; 1131: 7c          |
	ora	l		;; 1132: b5          .
	jz	L01c4		;; 1133: ca c4 01    ...
	shld	cursym		;; 1136: 22 23 35    "#5
	push	h		;; 1139: e5          .
	call	getval		;; 113a: cd 3e 25    .>%
	xthl			;; 113d: e3          .
	push	h		;; 113e: e5          .
	lhld	L161e		;; 113f: 2a 1e 16    *..
	call	putval		;; 1142: cd 35 25    .5%
	pop	h		;; 1145: e1          .
	shld	L161e		;; 1146: 22 1e 16    "..
	pop	h		;; 1149: e1          .
	shld	L161c		;; 114a: 22 1c 16    "..
	jmp	L112e		;; 114d: c3 2e 11    ...

; finish-up assembly...
L1150:	call	L1dff		;; 1150: cd ff 1d    ...
	call	prnbeg		;; 1153: cd 6f 13    .o.
	lxi	h,prnbuf+5	;; 1156: 21 50 34    .P4
	mvi	m,cr		;; 1159: 36 0d       6.
	lxi	h,prnbuf+1	;; 115b: 21 4c 34    .L4
	call	msgcr		;; 115e: cd ea 2a    ..*
	; REL file fixup...
	mvi	a,002h		;; 1161: 3e 02       >.
	sta	L1628		;; 1163: 32 28 16    2(.
	mvi	a,008h		;; 1166: 3e 08       >.
	sta	L3376		;; 1168: 32 76 33    2v3
	call	L1396		;; 116b: cd 96 13    ...
	mvi	a,003h		;; 116e: 3e 03       >.
	sta	L1628		;; 1170: 32 28 16    2(.
	mvi	a,004h		;; 1173: 3e 04       >.
	sta	L3376		;; 1175: 32 76 33    2v3
	call	L1396		;; 1178: cd 96 13    ...
	mvi	c,04eh	; end module (program)
	call	rel7bs		;; 117d: cd 42 13    .B.
	lda	L160e		;; 1180: 3a 0e 16    :..
	mov	c,a		;; 1183: 4f          O
	lhld	L160c		;; 1184: 2a 0c 16    *..
	xchg			;; 1187: eb          .
	call	reladr		;; 1188: cd 30 13    .0.
	lda	Sflag		;; 118b: 3a 2b 35    :+5
	ora	a		;; 118e: b7          .
	jz	L1198		;; 118f: ca 98 11    ...
	; generate symbol output/file
	call	L30fd		;; 1192: cd fd 30    ..0
	call	L14c4		;; 1195: cd c4 14    ...
L1198:	lhld	nxheap		;; 1198: 2a 0f 35    *.5
	xchg			;; 119b: eb          .
	lhld	syheap		;; 119c: 2a 21 35    *.5
	call	subtra		;; 119f: cd 53 10    .S.
	push	h		;; 11a2: e5          .
	lhld	memtop		;; 11a3: 2a 11 35    *.5
	xchg			;; 11a6: eb          .
	lhld	syheap		;; 11a7: 2a 21 35    *.5
	call	subtra		;; 11aa: cd 53 10    .S.
	mov	e,h		;; 11ad: 5c          \
	mvi	d,0		;; 11ae: 16 00       ..
	pop	h		;; 11b0: e1          .
	call	divide		;; 11b1: cd 67 17    .g.
	xchg			;; 11b4: eb          .
	call	prnadr		;; 11b5: cd 72 13    .r.
	lxi	h,prnbuf+5	;; 11b8: 21 50 34    .P4
	lxi	d,L11c9		;; 11bb: 11 c9 11    ...
L11be:	ldax	d		;; 11be: 1a          .
	ora	a		;; 11bf: b7          .
	jz	L11d7		;; 11c0: ca d7 11    ...
	mov	m,a		;; 11c3: 77          w
	inx	h		;; 11c4: 23          #
	inx	d		;; 11c5: 13          .
	jmp	L11be		;; 11c6: c3 be 11    ...

L11c9:	db	'H USE FACTOR',0dh,0

L11d7:	lxi	h,prnbuf+2	;; 11d7: 21 4d 34    .M4
	call	msgcr		;; 11da: cd ea 2a    ..*
	lhld	L160c		;; 11dd: 2a 0c 16    *..
	shld	curadr		;; 11e0: 22 16 35    ".5
	jmp	relfin		;; 11e3: c3 41 31    .A1

compr1:	mov	a,d		;; 11e6: 7a          z
	cmp	h		;; 11e7: bc          .
	rnz			;; 11e8: c0          .
	mov	a,e		;; 11e9: 7b          {
	cmp	l		;; 11ea: bd          .
	ret			;; 11eb: c9          .

synadr:	lhld	curadr		;; 11ec: 2a 16 35    *.5
	call	setadr		;; 11ef: cd 7e 32    .~2
	ret			;; 11f2: c9          .

getlbl:	lhld	curlbl		;; 11f3: 2a 08 16    *..
	shld	cursym		;; 11f6: 22 23 35    "#5
	call	isNULL		;; 11f9: cd 76 23    .v#
	ret			;; 11fc: c9          .

L11fd:	call	getlbl		;; 11fd: cd f3 11    ...
	rz			;; 1200: c8          .
	lxi	h,0		;; 1201: 21 00 00    ...
	shld	curlbl		;; 1204: 22 08 16    "..
	lda	pass		;; 1207: 3a 15 35    :.5
	ora	a		;; 120a: b7          .
	jnz	L1228		;; 120b: c2 28 12    .(.
	call	symtyp		;; 120e: cd 1e 25    ..%
	push	psw		;; 1211: f5          .
	ani	11110011b	;; 1212: e6 f3       ..
	cnz	Lerror		;; 1214: c4 e7 15    ...
	pop	psw		;; 1217: f1          .
	; mark symbol as defined... set seg,adr
	ori	010h		;; 1218: f6 10       ..
	lxi	h,curseg	;; 121a: 21 20 35    . 5
	ora	m		;; 121d: b6          .
	call	settyp		;; 121e: cd 16 25    ..%
	call	getadr		;; 1221: cd 6e 32    .n2
	call	putval		;; 1224: cd 35 25    .5%
	ret			;; 1227: c9          .

L1228:	call	symtyp		;; 1228: cd 1e 25    ..%
	ora	a		;; 122b: b7          .
	cz	Perror		;; 122c: cc e1 15    ...
	call	symtyp		;; 122f: cd 1e 25    ..%
	ani	014h		;; 1232: e6 14       ..
	cpi	014h		;; 1234: fe 14       ..
	cz	Lerror		;; 1236: cc e7 15    ...
	call	getval		;; 1239: cd 3e 25    .>%
	push	h		;; 123c: e5          .
	call	getadr		;; 123d: cd 6e 32    .n2
	pop	d		;; 1240: d1          .
	call	compr1		;; 1241: cd e6 11    ...
	cnz	Perror		;; 1244: c4 e1 15    ...
	ret			;; 1247: c9          .

; assemble byte, in A, to REL and PRN files
asmbya:	mov	b,a		;; 1248: 47          G
; assemble byte, in B, to REL and PRN files
asmbyt:	push	b		;; 1249: c5          .
	lda	pass		;; 124a: 3a 15 35    :.5
	ora	a		;; 124d: b7          .
	mov	a,b		;; 124e: 78          x
	cnz	relabs		;; 124f: c4 c9 12    ...
	pop	b		;; 1252: c1          .
; assemble byte, in B, to PRN file only
prnbyt:	push	b		;; 1253: c5          .
	lda	prnbuf+1	;; 1254: 3a 4c 34    :L4
	cpi	' '		;; 1257: fe 20       . 
	cz	prnbeg		;; 1259: cc 6f 13    .o.
	lda	prncol		;; 125c: 3a 0f 16    :..
	cpi	16		;; 125f: fe 10       ..
	pop	b		;; 1261: c1          .
	mov	a,b		;; 1262: 78          x
	cc	prnhex		;; 1263: dc 5f 13    ._.
	lhld	curadr		;; 1266: 2a 16 35    *.5
	inx	h		;; 1269: 23          #
	shld	curadr		;; 126a: 22 16 35    ".5
	ret			;; 126d: c9          .

; assemble an external reference, possibly plus offset
; must daisy-chain references...
asmext:	lda	pass		;; 126e: 3a 15 35    :.5
	ora	a		;; 1271: b7          .
	jz	prnadx		;; 1272: ca bd 12    ...
	lhld	L3508		;; 1275: 2a 08 35    *.5
	mov	a,h		;; 1278: 7c          |
	ora	l		;; 1279: b5          .
	jz	L1289		;; 127a: ca 89 12    ...
	push	h		;; 127d: e5          .
	mvi	c,049h	; external plus offset
	call	rel7bs		;; 1280: cd 42 13    .B.
	mvi	c,000h	; abs offset
	pop	d		;; 1285: d1          .
	call	reladr		;; 1286: cd 30 13    .0.
L1289:	call	getval		;; 1289: cd 3e 25    .>%
	push	h		;; 128c: e5          .
	call	symtyp		;; 128d: cd 1e 25    ..%
	mov	c,a		;; 1290: 4f          O
	pop	d		;; 1291: d1          .
	call	relref		;; 1292: cd f5 12    ...
	call	symtyp		;; 1295: cd 1e 25    ..%
	ani	0fch		;; 1298: e6 fc       ..
	mov	c,a		;; 129a: 4f          O
	lda	curseg		;; 129b: 3a 20 35    : 5
	ora	c		;; 129e: b1          .
	call	settyp		;; 129f: cd 16 25    ..%
	lhld	curadr		;; 12a2: 2a 16 35    *.5
	call	putval		;; 12a5: cd 35 25    .5%
	jmp	prnadx		;; 12a8: c3 bd 12    ...

; assemble address (HL) to output files (PRN, REL)
asmadr:	lda	pass		;; 12ab: 3a 15 35    :.5
	ora	a		;; 12ae: b7          .
	jz	prnadx		;; 12af: ca bd 12    ...
	lda	L350a		;; 12b2: 3a 0a 35    :.5
	mov	c,a		;; 12b5: 4f          O
	lhld	L3508		;; 12b6: 2a 08 35    *.5
	xchg			;; 12b9: eb          .
	call	relref		;; 12ba: cd f5 12    ...
prnadx:	lhld	L3508		;; 12bd: 2a 08 35    *.5
	push	h		;; 12c0: e5          .
	mov	b,l		;; 12c1: 45          E
	call	prnbyt		;; 12c2: cd 53 12    .S.
	pop	b		;; 12c5: c1          .
	jmp	prnbyt		;; 12c6: c3 53 12    .S.

; send abs 8-bit item to REL
; A=value
relabs:	push	psw		;; 12c9: f5          .
	mvi	c,0		;; 12ca: 0e 00       ..
	mvi	e,1		;; 12cc: 1e 01       ..
	call	relbts		;; 12ce: cd 8e 32    ..2
	pop	psw		;; 12d1: f1          .
	mov	c,a		;; 12d2: 4f          O
	jmp	rel8bs		;; 12d3: c3 3d 13    .=.

; send name (string) to REL. force <= 6 (symbol length)
; A=len, HL=string
relsym:	cpi	7		;; 12d6: fe 07       ..
	jc	L12dd		;; 12d8: da dd 12    ...
	mvi	a,6		;; 12db: 3e 06       >.
L12dd:	mov	c,a		;; 12dd: 4f          O
	push	b		;; 12de: c5          .
	push	h		;; 12df: e5          .
	mvi	e,3		;; 12e0: 1e 03       ..
	call	relbts		;; 12e2: cd 8e 32    ..2
	pop	h		;; 12e5: e1          .
	pop	d		;; 12e6: d1          .
L12e7:	mov	c,m		;; 12e7: 4e          N
	push	h		;; 12e8: e5          .
	push	d		;; 12e9: d5          .
	call	rel8bs		;; 12ea: cd 3d 13    .=.
	pop	d		;; 12ed: d1          .
	pop	h		;; 12ee: e1          .
	inx	h		;; 12ef: 23          #
	dcr	e		;; 12f0: 1d          .
	jnz	L12e7		;; 12f1: c2 e7 12    ...
	ret			;; 12f4: c9          .

; send address reference to REL
; C=reloc type, DE=value
relref:	mov	a,c		;; 12f5: 79          y
	ani	003h		;; 12f6: e6 03       ..
	jnz	L1304		;; 12f8: c2 04 13    ...
	; special link item...
	push	d		;; 12fb: d5          .
	mov	a,e		;; 12fc: 7b          {
	call	relabs		;; 12fd: cd c9 12    ...
	pop	psw		;; 1300: f1          .
	jmp	relabs		;; 1301: c3 c9 12    ...

L1304:	cpi	003h		;; 1304: fe 03       ..
	jnz	L1323		;; 1306: c2 23 13    .#.
	; common relative address
	push	d		;; 1309: d5          .
	lhld	L350d		;; 130a: 2a 0d 35    *.5
	xchg			;; 130d: eb          .
	lhld	L350b		;; 130e: 2a 0b 35    *.5
	call	compr1		;; 1311: cd e6 11    ...
	jz	L1320		;; 1314: ca 20 13    . .
	shld	cursym		;; 1317: 22 23 35    "#5
	shld	L350d		;; 131a: 22 0d 35    ".5
	call	L0e0f		;; 131d: cd 0f 0e    ...
L1320:	pop	d		;; 1320: d1          .
	mvi	c,003h		;; 1321: 0e 03       ..
L1323:	push	d		;; 1323: d5          .
	push	b		;; 1324: c5          .
	mvi	c,1		;; 1325: 0e 01       ..
	mvi	e,1		;; 1327: 1e 01       ..
	call	relbts		;; 1329: cd 8e 32    ..2
	pop	b		;; 132c: c1          .
	jmp	reladx		;; 132d: c3 31 13    .1.

; send 16 bits (address) to REL, prefixed with segment (2-bit)
; C=segment, DE=value
reladr:	push	d		;; 1330: d5          .
reladx:	mvi	e,2		;; 1331: 1e 02       ..
	call	relbts		;; 1333: cd 8e 32    ..2
	pop	b		;; 1336: c1          .
	push	b		;; 1337: c5          .
	call	rel8bs		;; 1338: cd 3d 13    .=.
	pop	b		;; 133b: c1          .
	mov	c,b		;; 133c: 48          H
rel8bs:	mvi	e,8		;; 133d: 1e 08       ..
	jmp	relbts		;; 133f: c3 8e 32    ..2

rel7bs:	mvi	e,7		;; 1342: 1e 07       ..
	jmp	relbts		;; 1344: c3 8e 32    ..2

hexdig:	adi	'0'		;; 1347: c6 30       .0
	cpi	'9'+1		;; 1349: fe 3a       .:
	rc			;; 134b: d8          .
	adi	'A'-'9'-1	;; 134c: c6 07       ..
	ret			;; 134e: c9          .

L134f:	call	hexdig		;; 134f: cd 47 13    .G.
	lxi	h,prncol	;; 1352: 21 0f 16    ...
	mov	e,m		;; 1355: 5e          ^
	mvi	d,0		;; 1356: 16 00       ..
	inr	m		;; 1358: 34          4
	lxi	h,prnbuf	;; 1359: 21 4b 34    .K4
	dad	d		;; 135c: 19          .
	mov	m,a		;; 135d: 77          w
	ret			;; 135e: c9          .

prnhex:	push	psw		;; 135f: f5          .
	rar			;; 1360: 1f          .
	rar			;; 1361: 1f          .
	rar			;; 1362: 1f          .
	rar			;; 1363: 1f          .
	ani	00fh		;; 1364: e6 0f       ..
	call	L134f		;; 1366: cd 4f 13    .O.
	pop	psw		;; 1369: f1          .
	ani	00fh		;; 136a: e6 0f       ..
	jmp	L134f		;; 136c: c3 4f 13    .O.

; put address (linadr) in PRN file buffer
prnbeg:	call	getadr		;; 136f: cd 6e 32    .n2
; put address (HL) in PRN file buffer
prnadr:	xchg			;; 1372: eb          .
	lxi	h,prncol	;; 1373: 21 0f 16    ...
	push	h		;; 1376: e5          .
	mvi	m,1		;; 1377: 36 01       6.
	mov	a,d		;; 1379: 7a          z
	push	d		;; 137a: d5          .
	call	prnhex		;; 137b: cd 5f 13    ._.
	pop	d		;; 137e: d1          .
	mov	a,e		;; 137f: 7b          {
	call	prnhex		;; 1380: cd 5f 13    ._.
	pop	h		;; 1383: e1          .
	inr	m		;; 1384: 34          4
	ret			;; 1385: c9          .

; returns E = hash(A)
hashch:	sui	'A'		;; 1386: d6 41       .A
	cpi	'Z'-'A'+1	;; 1388: fe 1a       ..
	mov	e,a		;; 138a: 5f          _
	rc			;; 138b: d8          .
	adi	'A'		;; 138c: c6 41       .A
	cpi	'?'		;; 138e: fe 3f       .?
	mvi	e,'['-'A'	;; 1390: 1e 1a       ..
	rz			;; 1392: c8          .
	mvi	e,'\'-'A'	;; 1393: 1e 1b       ..
	ret			;; 1395: c9          .

; make a pass through all symbols? sort them?
L1396:	lhld	syheap		;; 1396: 2a 21 35    *.5
	shld	cursym		;; 1399: 22 23 35    "#5
L139c:	lhld	cursym		;; 139c: 2a 23 35    *#5
	xchg			;; 139f: eb          .
	lhld	nxheap		;; 13a0: 2a 0f 35    *.5
	mov	a,e		;; 13a3: 7b          {
	sub	l		;; 13a4: 95          .
	mov	a,d		;; 13a5: 7a          z
	sbb	h		;; 13a6: 9c          .
	rnc			;; 13a7: d0          .
	lhld	L352f		;; 13a8: 2a 2f 35    */5
	call	compr1		;; 13ab: cd e6 11    ...
	dcx	h		;; 13ae: 2b          +
	shld	tmpptr		;; 13af: 22 25 35    "%5
	jz	L13da		;; 13b2: ca da 13    ...
	lhld	L162a		;; 13b5: 2a 2a 16    **.
	call	compr1		;; 13b8: cd e6 11    ...
	dcx	h		;; 13bb: 2b          +
	shld	tmpptr		;; 13bc: 22 25 35    "%5
	jz	L13da		;; 13bf: ca da 13    ...
	call	symtyp		;; 13c2: cd 1e 25    ..%
	cpi	020h		;; 13c5: fe 20       . 
	jnz	L13e8		;; 13c7: c2 e8 13    ...
	; MACRO - skip to next...
	call	macpct		;; 13ca: cd 56 25    .V%
L13cd:	ora	a		;; 13cd: b7          .
	jz	L13da		;; 13ce: ca da 13    ...
	; macro params...
	dcr	a		;; 13d1: 3d          =
	push	psw		;; 13d2: f5          .
	; get len,flags
	call	getstr		;; 13d3: cd 87 25    ..%
	pop	psw		;; 13d6: f1          .
	jmp	L13cd		;; 13d7: c3 cd 13    ...

; past macro params, now skip template
L13da:	call	gettmp		;; 13da: cd a2 25    ..%
	ora	a		;; 13dd: b7          .
	jnz	L13da		;; 13de: c2 da 13    ...
	lhld	tmpptr		;; 13e1: 2a 25 35    *%5
	inx	h		;; 13e4: 23          #
	jmp	L14be		;; 13e5: c3 be 14    ...

L13e8:	lxi	h,L3376		;; 13e8: 21 76 33    .v3
	ana	m		;; 13eb: a6          .
	jz	L14b2		;; 13ec: ca b2 14    ...
	lda	L1628		;; 13ef: 3a 28 16    :(.
	mvi	b,0		;; 13f2: 06 00       ..
	mov	c,a		;; 13f4: 4f          O
	lxi	h,L13ff		;; 13f5: 21 ff 13    ...
	dad	b		;; 13f8: 09          .
	dad	b		;; 13f9: 09          .
	mov	e,m		;; 13fa: 5e          ^
	inx	h		;; 13fb: 23          #
	mov	d,m		;; 13fc: 56          V
	xchg			;; 13fd: eb          .
	pchl			;; 13fe: e9          .

L13ff:	dw	L1434	; n/a
	dw	L1407	; entry symbol
	dw	L140f	; define entry point
	dw	L1414	; chain external

; entry symbol: sym
L1407:	mvi	c,040h		;; 1407: 0e 40       .@
	call	rel7bs		;; 1409: cd 42 13    .B.
	jmp	L1425		;; 140c: c3 25 14    .%.

; define entry point: adr, sym
L140f:	mvi	c,047h		;; 140f: 0e 47       .G
	jmp	L1416		;; 1411: c3 16 14    ...

; chain external: adr, sym
L1414:	mvi	c,046h		;; 1414: 0e 46       .F
L1416:	call	rel7bs		;; 1416: cd 42 13    .B.
	call	getval		;; 1419: cd 3e 25    .>%
	push	h		;; 141c: e5          .
	call	symtyp		;; 141d: cd 1e 25    ..%
	pop	d		;; 1420: d1          .
	mov	c,a		;; 1421: 4f          O
	call	reladr		;; 1422: cd 30 13    .0.
L1425:	lhld	cursym		;; 1425: 2a 23 35    *#5
	inx	h		;; 1428: 23          #
	inx	h		;; 1429: 23          #
	mov	a,m		;; 142a: 7e          ~
	inr	a		;; 142b: 3c          <
	inx	h		;; 142c: 23          #
	inx	h		;; 142d: 23          #
	call	relsym		;; 142e: cd d6 12    ...
	jmp	L14b2		;; 1431: c3 b2 14    ...

L1434:	lhld	cursym		;; 1434: 2a 23 35    *#5
	shld	prvsym		;; 1437: 22 7c 33    "|3
	inx	h		;; 143a: 23          #
	shld	tmpptr		;; 143b: 22 25 35    "%5
	call	getstr		;; 143e: cd 87 25    ..%
	lda	Qflag		;; 1441: 3a 31 35    :15
	ora	a		;; 1444: b7          .
	jnz	L145e		;; 1445: c2 5e 14    .^.
	lda	tokbuf		;; 1448: 3a c7 34    :.4
	cpi	2		;; 144b: fe 02       ..
	jc	L145e		;; 144d: da 5e 14    .^.
	lxi	h,tokbuf+1	;; 1450: 21 c8 34    ..4
	mov	a,m		;; 1453: 7e          ~
	cpi	'?'		;; 1454: fe 3f       .?
	jnz	L145e		;; 1456: c2 5e 14    .^.
	inx	h		;; 1459: 23          #
	cmp	m		;; 145a: be          .
	; skip '??' symbols
	jz	L14b2		;; 145b: ca b2 14    ...
; lookup symbol/string?
L145e:	lda	tokbuf+1	;; 145e: 3a c8 34    :.4
	call	hashch		;; 1461: cd 86 13    ...
	lxi	h,symtab	;; 1464: 21 7e 33    .~3
	mvi	d,0		;; 1467: 16 00       ..
	dad	d		;; 1469: 19          .
	dad	d		;; 146a: 19          .
L146b:	shld	curhsh		;; 146b: 22 7a 33    "z3
	mov	e,m		;; 146e: 5e          ^
	inx	h		;; 146f: 23          #
	mov	d,m		;; 1470: 56          V
	xchg			;; 1471: eb          .
	shld	cursym		;; 1472: 22 23 35    "#5
	mov	a,l		;; 1475: 7d          }
	ora	h		;; 1476: b4          .
	jz	nxtsym		;; 1477: ca 9d 14    ...
	inx	h		;; 147a: 23          #
	inx	h		;; 147b: 23          #
	mov	a,m		;; 147c: 7e          ~
	inr	a		;; 147d: 3c          <
	mov	c,a		;; 147e: 4f          O
	lxi	d,tokbuf	;; 147f: 11 c7 34    ..4
	ldax	d		;; 1482: 1a          .
	mov	b,a		;; 1483: 47          G
	inx	h		;; 1484: 23          #
L1485:	inx	d		;; 1485: 13          .
	inx	h		;; 1486: 23          #
	ldax	d		;; 1487: 1a          .
	cmp	m		;; 1488: be          .
	jc	nxtsym		;; 1489: da 9d 14    ...
	jnz	L1497		;; 148c: c2 97 14    ...
	dcr	b		;; 148f: 05          .
	jz	nxtsym		;; 1490: ca 9d 14    ...
	dcr	c		;; 1493: 0d          .
	jnz	L1485		;; 1494: c2 85 14    ...
	; found symbol match, or insertion point
L1497:	lhld	cursym		;; 1497: 2a 23 35    *#5
	jmp	L146b		;; 149a: c3 6b 14    .k.

; locate next symbol in chain
nxtsym:	lhld	cursym		;; 149d: 2a 23 35    *#5
	xchg			;; 14a0: eb          .
	lhld	prvsym		;; 14a1: 2a 7c 33    *|3
	shld	cursym		;; 14a4: 22 23 35    "#5
	mov	m,e		;; 14a7: 73          s
	inx	h		;; 14a8: 23          #
	mov	m,d		;; 14a9: 72          r
	dcx	h		;; 14aa: 2b          +
	xchg			;; 14ab: eb          .
	lhld	curhsh		;; 14ac: 2a 7a 33    *z3
	mov	m,e		;; 14af: 73          s
	inx	h		;; 14b0: 23          #
	mov	m,d		;; 14b1: 72          r
L14b2:	lhld	cursym		;; 14b2: 2a 23 35    *#5
	inx	h		;; 14b5: 23          #
	inx	h		;; 14b6: 23          #
	mov	a,m		;; 14b7: 7e          ~
	adi	5		;; 14b8: c6 05       ..
	mov	e,a		;; 14ba: 5f          _
	mvi	d,0		;; 14bb: 16 00       ..
	dad	d		;; 14bd: 19          .
L14be:	shld	cursym		;; 14be: 22 23 35    "#5
	jmp	L139c		;; 14c1: c3 9c 13    ...

L14c4:	mvi	a,014h		;; 14c4: 3e 14       >.
	sta	L3376		;; 14c6: 32 76 33    2v3
	xra	a		;; 14c9: af          .
	sta	L3377		;; 14ca: 32 77 33    2w3
	sta	prncol		;; 14cd: 32 0f 16    2..
	sta	L1628		;; 14d0: 32 28 16    2(.
	; clear symtab hash table
	lxi	h,symtab	;; 14d3: 21 7e 33    .~3
	mvi	c,28*2		;; 14d6: 0e 38       .8
	xra	a		;; 14d8: af          .
L14d9:	mov	m,a		;; 14d9: 77          w
	inx	h		;; 14da: 23          #
	dcr	c		;; 14db: 0d          .
	jnz	L14d9		;; 14dc: c2 d9 14    ...
	call	L1396		;; 14df: cd 96 13    ...
	; list 
	lxi	h,symtab	;; 14e2: 21 7e 33    .~3
	shld	curhsh		;; 14e5: 22 7a 33    "z3
	mvi	a,28		;; 14e8: 3e 1c       >.
	sta	L3379		;; 14ea: 32 79 33    2y3
L14ed:	lhld	curhsh		;; 14ed: 2a 7a 33    *z3
	mov	e,m		;; 14f0: 5e          ^
	inx	h		;; 14f1: 23          #
	mov	d,m		;; 14f2: 56          V
	inx	h		;; 14f3: 23          #
	shld	curhsh		;; 14f4: 22 7a 33    "z3
	xchg			;; 14f7: eb          .
	shld	cursym		;; 14f8: 22 23 35    "#5
L14fb:	lhld	cursym		;; 14fb: 2a 23 35    *#5
	mov	a,l		;; 14fe: 7d          }
	ora	h		;; 14ff: b4          .
	jz	L15a9		;; 1500: ca a9 15    ...
	inx	h		;; 1503: 23          #
	inx	h		;; 1504: 23          #
	mov	a,m		;; 1505: 7e          ~
	inr	a		;; 1506: 3c          <
	sta	L3378		;; 1507: 32 78 33    2x3
	mov	b,a		;; 150a: 47          G
	lhld	cursym		;; 150b: 2a 23 35    *#5
	inx	h		;; 150e: 23          #
	inx	h		;; 150f: 23          #
	inx	h		;; 1510: 23          #
	shld	tmpptr		;; 1511: 22 25 35    "%5
	lda	L3377		;; 1514: 3a 77 33    :w3
	ora	a		;; 1517: b7          .
	jz	L1537		;; 1518: ca 37 15    .7.
	mvi	a,tab		;; 151b: 3e 09       >.
	call	prnchr		;; 151d: cd ba 15    ...
	lxi	h,L3377		;; 1520: 21 77 33    .w3
	mov	a,m		;; 1523: 7e          ~
	ani	0f8h		;; 1524: e6 f8       ..
	adi	008h		;; 1526: c6 08       ..
	mov	m,a		;; 1528: 77          w
	ani	00fh		;; 1529: e6 0f       ..
	jz	L1537		;; 152b: ca 37 15    .7.
	mvi	a,008h		;; 152e: 3e 08       >.
	add	m		;; 1530: 86          .
	mov	m,a		;; 1531: 77          w
	mvi	a,tab		;; 1532: 3e 09       >.
	call	prnchr		;; 1534: cd ba 15    ...
L1537:	lda	L3377		;; 1537: 3a 77 33    :w3
	add	b		;; 153a: 80          .
	adi	5		;; 153b: c6 05       ..
	cpi	80		;; 153d: fe 50       .P
	jc	L1564		;; 153f: da 64 15    .d.
L1542:	lxi	h,prncol	;; 1542: 21 0f 16    ...
	dcr	m		;; 1545: 35          5
	mov	e,m		;; 1546: 5e          ^
	mvi	d,0		;; 1547: 16 00       ..
	dcx	d		;; 1549: 1b          .
	lxi	h,prnbuf	;; 154a: 21 4b 34    .K4
	dad	d		;; 154d: 19          .
	mov	a,m		;; 154e: 7e          ~
	cpi	tab		;; 154f: fe 09       ..
	jz	L1542		;; 1551: ca 42 15    .B.
	lxi	h,prncol	;; 1554: 21 0f 16    ...
	mov	a,m		;; 1557: 7e          ~
	mvi	m,0		;; 1558: 36 00       6.
	sta	L34c3		;; 155a: 32 c3 34    2.4
	call	L3028		;; 155d: cd 28 30    .(0
	xra	a		;; 1560: af          .
	sta	L3377		;; 1561: 32 77 33    2w3
L1564:	call	symtyp		;; 1564: cd 1e 25    ..%
	ani	004h		;; 1567: e6 04       ..
	lxi	h,0		;; 1569: 21 00 00    ...
	cz	getval		;; 156c: cc 3e 25    .>%
	push	h		;; 156f: e5          .
	mov	a,h		;; 1570: 7c          |
	call	prnhex		;; 1571: cd 5f 13    ._.
	pop	h		;; 1574: e1          .
	mov	a,l		;; 1575: 7d          }
	call	prnhex		;; 1576: cd 5f 13    ._.
	mvi	a,' '		;; 1579: 3e 20       > 
	call	prnchr		;; 157b: cd ba 15    ...
	lxi	h,L3377		;; 157e: 21 77 33    .w3
	mov	a,m		;; 1581: 7e          ~
	adi	5		;; 1582: c6 05       ..
	mov	m,a		;; 1584: 77          w
	lda	L3378		;; 1585: 3a 78 33    :x3
L1588:	ora	a		;; 1588: b7          .
	jz	L159c		;; 1589: ca 9c 15    ...
	dcr	a		;; 158c: 3d          =
	push	psw		;; 158d: f5          .
	call	gettmp		;; 158e: cd a2 25    ..%
	call	prnchr		;; 1591: cd ba 15    ...
	lxi	h,L3377		;; 1594: 21 77 33    .w3
	inr	m		;; 1597: 34          4
	pop	psw		;; 1598: f1          .
	jmp	L1588		;; 1599: c3 88 15    ...

; cursym = cursym->next
L159c:	lhld	cursym		;; 159c: 2a 23 35    *#5
	mov	e,m		;; 159f: 5e          ^
	inx	h		;; 15a0: 23          #
	mov	d,m		;; 15a1: 56          V
	xchg			;; 15a2: eb          .
	shld	cursym		;; 15a3: 22 23 35    "#5
	jmp	L14fb		;; 15a6: c3 fb 14    ...

L15a9:	lxi	h,L3379		;; 15a9: 21 79 33    .y3
	dcr	m		;; 15ac: 35          5
	jnz	L14ed		;; 15ad: c2 ed 14    ...
	lda	prncol		;; 15b0: 3a 0f 16    :..
	sta	L34c3		;; 15b3: 32 c3 34    2.4
	call	L3028		;; 15b6: cd 28 30    .(0
	ret			;; 15b9: c9          .

prnchr:	lxi	h,prncol	;; 15ba: 21 0f 16    ...
	mov	e,m		;; 15bd: 5e          ^
	mvi	d,0		;; 15be: 16 00       ..
	inr	m		;; 15c0: 34          4
	lxi	h,prnbuf	;; 15c1: 21 4b 34    .K4
	dad	d		;; 15c4: 19          .
	mov	m,a		;; 15c5: 77          w
	ret			;; 15c6: c9          .

Rerror:	push	psw		;; 15c7: f5          .
	push	b		;; 15c8: c5          .
	mvi	a,'R'		;; 15c9: 3e 52       >R
	call	seterr		;; 15cb: cd d5 30    ..0
	pop	b		;; 15ce: c1          .
	pop	psw		;; 15cf: f1          .
	ret			;; 15d0: c9          .

Verror:	push	psw		;; 15d1: f5          .
	push	h		;; 15d2: e5          .
	mvi	a,'V'		;; 15d3: 3e 56       >V
	call	seterr		;; 15d5: cd d5 30    ..0
	pop	h		;; 15d8: e1          .
	pop	psw		;; 15d9: f1          .
	ret			;; 15da: c9          .

Derror:	push	psw		;; 15db: f5          .
	mvi	a,'D'		;; 15dc: 3e 44       >D
	jmp	L1602		;; 15de: c3 02 16    ...

Perror:	push	psw		;; 15e1: f5          .
	mvi	a,'P'		;; 15e2: 3e 50       >P
	jmp	L1602		;; 15e4: c3 02 16    ...

Lerror:	push	psw		;; 15e7: f5          .
	mvi	a,'L'		;; 15e8: 3e 4c       >L
	jmp	L1602		;; 15ea: c3 02 16    ...

Oerror:	push	psw		;; 15ed: f5          .
	mvi	a,'O'		;; 15ee: 3e 4f       >O
	jmp	L1602		;; 15f0: c3 02 16    ...

Berror:	push	psw		;; 15f3: f5          .
	mvi	a,'B'		;; 15f4: 3e 42       >B
	jmp	L1602		;; 15f6: c3 02 16    ...

Serror:	push	psw		;; 15f9: f5          .
	mvi	a,'S'		;; 15fa: 3e 53       >S
	jmp	L1602		;; 15fc: c3 02 16    ...

Nerror:	push	psw		;; 15ff: f5          .
	mvi	a,'N'		;; 1600: 3e 4e       >N
L1602:	call	seterr		;; 1602: cd d5 30    ..0
	pop	psw		;; 1605: f1          .
	ret			;; 1606: c9          .

L1607:	db	0
curlbl:	db	0,0	; current statement's label
L160a:	db	0,0
L160c:	db	0,0
L160e:	db	0
prncol:	db	0
L1610:	db	0
L1611:	db	0
L1612:	db	0
L1613:	db	0
L1614:	db	0,0,0,0,0,0,0,0
L161c:	db	0,0
L161e:	db	0,0
L1620:	db	0
fmtsup:	db	0
fmtval:	db	0,0
locseq:	db	0,0
L1626:	db	0,0
L1628:	db	0
pubext:	db	0	; public (08h) vs. extrn (04h)
L162a:	db	0,0
L162c:	db	0,0
L162e:	db	0,0

; Module begin L1200

L1630:	db	0
; some sort of dual stack/fifo - 10 bytes/entries
L1631:	db	0,0,0,0,0,0,0,0,0,0
L163b:	db	0,0,0,0,0,0,0,0,0,0

; some sort of stack/fifo - 8 entries, adr+seg
L1645:	dw	0,0,0,0,0,0,0,0
L1655:	db	0,0,0,0,0,0,0,0
L165d:	dw	0,0,0,0,0,0,0,0

L166d:	db	0
L166e:	db	0
L166f:	db	0
L1670:	db	0,0
L1672:	db	0,0
L1674:	db	0	; L1631 "sp"
L1675:	db	0	; L1645 "sp"
L1676:	db	0,0

; "push" HL into L1645 "stack", with L166d,L350b
; "stack" wraps after 8 entries...
L1678:	xchg			;; 1678: eb          .
	lxi	h,L1675		;; 1679: 21 75 16    .u.
	mov	a,m		;; 167c: 7e          ~
	cpi	8		;; 167d: fe 08       ..
	jc	L1687		;; 167f: da 87 16    ...
	call	Eerror		;; 1682: cd 4b 1b    .K.
	mvi	m,0		;; 1685: 36 00       6.
L1687:	mov	c,m		;; 1687: 4e          N
	inr	m		;; 1688: 34          4
	mvi	b,0		;; 1689: 06 00       ..
	lxi	h,L1645		;; 168b: 21 45 16    .E.
	dad	b		;; 168e: 09          .
	dad	b		;; 168f: 09          .
	mov	m,e		;; 1690: 73          s
	inx	h		;; 1691: 23          #
	mov	m,d		;; 1692: 72          r
	lxi	h,L1655		;; 1693: 21 55 16    .U.
	dad	b		;; 1696: 09          .
	lda	L166d		;; 1697: 3a 6d 16    :m.
	ani	007h		;; 169a: e6 07       ..
	mov	m,a		;; 169c: 77          w
	lhld	L350b		;; 169d: 2a 0b 35    *.5
	xchg			;; 16a0: eb          .
	lxi	h,L165d		;; 16a1: 21 5d 16    .].
	dad	b		;; 16a4: 09          .
	dad	b		;; 16a5: 09          .
	mov	m,e		;; 16a6: 73          s
	inx	h		;; 16a7: 23          #
	mov	m,d		;; 16a8: 72          r
	ret			;; 16a9: c9          .

; push bytes onto parallel stacks L1631, L163b
; A => L1631, B => L163b
L16aa:	push	psw		;; 16aa: f5          .
	lxi	h,L1674		;; 16ab: 21 74 16    .t.
	mov	a,m		;; 16ae: 7e          ~
	cpi	10		;; 16af: fe 0a       ..
	jc	L16b9		;; 16b1: da b9 16    ...
	mvi	m,0		;; 16b4: 36 00       6.
	call	Eerror		;; 16b6: cd 4b 1b    .K.
L16b9:	mov	e,m		;; 16b9: 5e          ^
	mvi	d,0		;; 16ba: 16 00       ..
	inr	m		;; 16bc: 34          4
	pop	psw		;; 16bd: f1          .
	lxi	h,L1631		;; 16be: 21 31 16    .1.
	dad	d		;; 16c1: 19          .
	mov	m,a		;; 16c2: 77          w
	lxi	h,L163b		;; 16c3: 21 3b 16    .;.
	dad	d		;; 16c6: 19          .
	mov	m,b		;; 16c7: 70          p
	ret			;; 16c8: c9          .

; "pop" HL off L1645 "fifo stack"
L16c9:	lxi	h,L1675		;; 16c9: 21 75 16    .u.
	mov	a,m		;; 16cc: 7e          ~
	ora	a		;; 16cd: b7          .
	jnz	L16d9		;; 16ce: c2 d9 16    ...
	call	Eerror		;; 16d1: cd 4b 1b    .K.
	lxi	h,0		;; 16d4: 21 00 00    ...
	xra	a		;; 16d7: af          .
	ret			;; 16d8: c9          .

L16d9:	dcr	m		;; 16d9: 35          5
	mov	c,m		;; 16da: 4e          N
	mvi	b,0		;; 16db: 06 00       ..
	lxi	h,L1645		;; 16dd: 21 45 16    .E.
	dad	b		;; 16e0: 09          .
	dad	b		;; 16e1: 09          .
	mov	a,m		;; 16e2: 7e          ~
	inx	h		;; 16e3: 23          #
	mov	h,m		;; 16e4: 66          f
	mov	l,a		;; 16e5: 6f          o
	push	h		;; 16e6: e5          .
	lxi	h,L1655		;; 16e7: 21 55 16    .U.
	dad	b		;; 16ea: 09          .
	mov	a,m		;; 16eb: 7e          ~
	sta	L166e		;; 16ec: 32 6e 16    2n.
	push	d		;; 16ef: d5          .
	lxi	h,L165d		;; 16f0: 21 5d 16    .].
	dad	b		;; 16f3: 09          .
	dad	b		;; 16f4: 09          .
	mov	e,m		;; 16f5: 5e          ^
	inx	h		;; 16f6: 23          #
	mov	d,m		;; 16f7: 56          V
	xchg			;; 16f8: eb          .
	shld	L1670		;; 16f9: 22 70 16    "p.
	pop	d		;; 16fc: d1          .
	pop	h		;; 16fd: e1          .
	ret			;; 16fe: c9          .

L16ff:	call	L16c9		;; 16ff: cd c9 16    ...
	cpi	0		;; 1702: fe 00       ..
	cnz	Eerror		;; 1704: c4 4b 1b    .K.
	ret			;; 1707: c9          .

L1708:	call	L16ff		;; 1708: cd ff 16    ...
	sta	L166f		;; 170b: 32 6f 16    2o.
	xchg			;; 170e: eb          .
	call	L16ff		;; 170f: cd ff 16    ...
	ret			;; 1712: c9          .

L1713:	mov	l,a		;; 1713: 6f          o
	mvi	h,0		;; 1714: 26 00       &.
	dad	h		;; 1716: 29          )
	lxi	d,L1720		;; 1717: 11 20 17    . .
	dad	d		;; 171a: 19          .
	mov	e,m		;; 171b: 5e          ^
	inx	h		;; 171c: 23          #
	mov	h,m		;; 171d: 66          f
	mov	l,e		;; 171e: 6b          k
	pchl			;; 171f: e9          .

L1720:	dw	L17b8	; 0
	dw	L17c1	; 1
	dw	L17c8	; 2
	dw	L17ce	; 3
	dw	L17da	; 4
	dw	L17ee	; 5
	dw	L17fc	; 6
	dw	L184e	; 7
	dw	L185d	; 8
	dw	L1869	; 9
	dw	L1876	; 10
	dw	L1882	; 11
	dw	L1889	; 12
	dw	L1890	; 13
	dw	L18a8	; 14
	dw	L18af	; 15
	dw	L18bb	; 16
	dw	L18c7	; 17
	dw	L18d3	; 18
	dw	L18da	; 19
	dw	Eerror	; 20

L174a:	call	L1708		;; 174a: cd 08 17    ...
	mov	a,d		;; 174d: 7a          z
	ora	a		;; 174e: b7          .
	jnz	L1756		;; 174f: c2 56 17    .V.
	mov	a,e		;; 1752: 7b          {
	cpi	17		;; 1753: fe 11       ..
	rc			;; 1755: d8          .
L1756:	call	Eerror		;; 1756: cd 4b 1b    .K.
	mvi	a,16		;; 1759: 3e 10       >.
	ret			;; 175b: c9          .

L175c:	xra	a		;; 175c: af          .
	sub	l		;; 175d: 95          .
	mov	l,a		;; 175e: 6f          o
	mvi	a,0		;; 175f: 3e 00       >.
	sbb	h		;; 1761: 9c          .
	mov	h,a		;; 1762: 67          g
	ret			;; 1763: c9          .

L1764:	call	L1708		;; 1764: cd 08 17    ...
; some sort of division operation
divide:	xchg			;; 1767: eb          .
	shld	L179a		;; 1768: 22 9a 17    "..
	lxi	h,L179c		;; 176b: 21 9c 17    ...
	mvi	m,17		;; 176e: 36 11       6.
	lxi	b,0		;; 1770: 01 00 00    ...
	push	b		;; 1773: c5          .
	xra	a		;; 1774: af          .
L1775:	mov	a,e		;; 1775: 7b          {
	ral			;; 1776: 17          .
	mov	e,a		;; 1777: 5f          _
	mov	a,d		;; 1778: 7a          z
	ral			;; 1779: 17          .
	mov	d,a		;; 177a: 57          W
	dcr	m		;; 177b: 35          5
	pop	h		;; 177c: e1          .
	rz			;; 177d: c8          .
	mvi	a,0		;; 177e: 3e 00       >.
	aci	0		;; 1780: ce 00       ..
	dad	h		;; 1782: 29          )
	mov	b,h		;; 1783: 44          D
	add	l		;; 1784: 85          .
	lhld	L179a		;; 1785: 2a 9a 17    *..
	sub	l		;; 1788: 95          .
	mov	c,a		;; 1789: 4f          O
	mov	a,b		;; 178a: 78          x
	sbb	h		;; 178b: 9c          .
	mov	b,a		;; 178c: 47          G
	push	b		;; 178d: c5          .
	jnc	L1793		;; 178e: d2 93 17    ...
	dad	b		;; 1791: 09          .
	xthl			;; 1792: e3          .
L1793:	lxi	h,L179c		;; 1793: 21 9c 17    ...
	cmc			;; 1796: 3f          ?
	jmp	L1775		;; 1797: c3 75 17    .u.

L179a:	db	0,0
L179c:	db	0

L179d:	mov	b,h		;; 179d: 44          D
	mov	c,l		;; 179e: 4d          M
	lxi	h,0		;; 179f: 21 00 00    ...
L17a2:	xra	a		;; 17a2: af          .
	mov	a,b		;; 17a3: 78          x
	rar			;; 17a4: 1f          .
	mov	b,a		;; 17a5: 47          G
	mov	a,c		;; 17a6: 79          y
	rar			;; 17a7: 1f          .
	mov	c,a		;; 17a8: 4f          O
	jc	L17b1		;; 17a9: da b1 17    ...
	ora	b		;; 17ac: b0          .
	rz			;; 17ad: c8          .
	jmp	L17b2		;; 17ae: c3 b2 17    ...

L17b1:	dad	d		;; 17b1: 19          .
L17b2:	xchg			;; 17b2: eb          .
	dad	h		;; 17b3: 29          )
	xchg			;; 17b4: eb          .
	jmp	L17a2		;; 17b5: c3 a2 17    ...

L17b8:	call	L1708		;; 17b8: cd 08 17    ...
	call	L179d		;; 17bb: cd 9d 17    ...
	jmp	L18df		;; 17be: c3 df 18    ...

L17c1:	call	L1764		;; 17c1: cd 64 17    .d.
	xchg			;; 17c4: eb          .
	jmp	L18df		;; 17c5: c3 df 18    ...

L17c8:	call	L1764		;; 17c8: cd 64 17    .d.
	jmp	L18df		;; 17cb: c3 df 18    ...

L17ce:	call	L174a		;; 17ce: cd 4a 17    .J.
L17d1:	ora	a		;; 17d1: b7          .
	jz	L18df		;; 17d2: ca df 18    ...
	dad	h		;; 17d5: 29          )
	dcr	a		;; 17d6: 3d          =
	jmp	L17d1		;; 17d7: c3 d1 17    ...

L17da:	call	L174a		;; 17da: cd 4a 17    .J.
L17dd:	ora	a		;; 17dd: b7          .
	jz	L18df		;; 17de: ca df 18    ...
	push	psw		;; 17e1: f5          .
	xra	a		;; 17e2: af          .
	mov	a,h		;; 17e3: 7c          |
	rar			;; 17e4: 1f          .
	mov	h,a		;; 17e5: 67          g
	mov	a,l		;; 17e6: 7d          }
	rar			;; 17e7: 1f          .
	mov	l,a		;; 17e8: 6f          o
	pop	psw		;; 17e9: f1          .
	dcr	a		;; 17ea: 3d          =
	jmp	L17dd		;; 17eb: c3 dd 17    ...

L17ee:	call	L16ff		;; 17ee: cd ff 16    ...
	sta	L166f		;; 17f1: 32 6f 16    2o.
	xchg			;; 17f4: eb          .
	call	L16c9		;; 17f5: cd c9 16    ...
L17f8:	dad	d		;; 17f8: 19          .
	jmp	L18df		;; 17f9: c3 df 18    ...

L17fc:	call	L16c9		;; 17fc: cd c9 16    ...
	sta	L166f		;; 17ff: 32 6f 16    2o.
	push	psw		;; 1802: f5          .
	xchg			;; 1803: eb          .
	lhld	L1670		;; 1804: 2a 70 16    *p.
	shld	L1672		;; 1807: 22 72 16    "r.
	call	L16c9		;; 180a: cd c9 16    ...
	pop	b		;; 180d: c1          .
	mov	c,a		;; 180e: 4f          O
	mov	a,b		;; 180f: 78          x
	ani	004h		;; 1810: e6 04       ..
	cnz	Eerror		;; 1812: c4 4b 1b    .K.
	mov	a,b		;; 1815: 78          x
	ani	003h		;; 1816: e6 03       ..
	jz	L1847		;; 1818: ca 47 18    .G.
	mov	a,c		;; 181b: 79          y
	ani	004h		;; 181c: e6 04       ..
	cnz	Eerror		;; 181e: c4 4b 1b    .K.
	mov	a,b		;; 1821: 78          x
	ani	003h		;; 1822: e6 03       ..
	mov	b,a		;; 1824: 47          G
	mov	a,c		;; 1825: 79          y
	ani	003h		;; 1826: e6 03       ..
	cmp	b		;; 1828: b8          .
	jz	L1830		;; 1829: ca 30 18    .0.
	call	Eerror		;; 182c: cd 4b 1b    .K.
	ret			;; 182f: c9          .

L1830:	cpi	003h		;; 1830: fe 03       ..
	jnz	L1847		;; 1832: c2 47 18    .G.
	push	h		;; 1835: e5          .
	push	d		;; 1836: d5          .
	lhld	L1670		;; 1837: 2a 70 16    *p.
	xchg			;; 183a: eb          .
	lhld	L1672		;; 183b: 2a 72 16    *r.
	mov	a,l		;; 183e: 7d          }
	sub	e		;; 183f: 93          .
	mov	a,h		;; 1840: 7c          |
	sbb	d		;; 1841: 9a          .
	cnz	Eerror		;; 1842: c4 4b 1b    .K.
	pop	d		;; 1845: d1          .
	pop	h		;; 1846: e1          .
L1847:	xchg			;; 1847: eb          .
	call	L175c		;; 1848: cd 5c 17    .\.
	jmp	L17f8		;; 184b: c3 f8 17    ...

L184e:	call	L16ff		;; 184e: cd ff 16    ...
L1851:	call	L175c		;; 1851: cd 5c 17    .\.
	jmp	L18df		;; 1854: c3 df 18    ...

L1857:	mov	a,d		;; 1857: 7a          z
	cmp	h		;; 1858: bc          .
	rnz			;; 1859: c0          .
	mov	a,e		;; 185a: 7b          {
	cmp	l		;; 185b: bd          .
	ret			;; 185c: c9          .

L185d:	call	L1708		;; 185d: cd 08 17    ...
	call	L1857		;; 1860: cd 57 18    .W.
	jnz	L18a2		;; 1863: c2 a2 18    ...
	jmp	L189c		;; 1866: c3 9c 18    ...

L1869:	call	L1708		;; 1869: cd 08 17    ...
L186c:	mov	a,l		;; 186c: 7d          }
	sub	e		;; 186d: 93          .
	mov	a,h		;; 186e: 7c          |
	sbb	d		;; 186f: 9a          .
	jc	L189c		;; 1870: da 9c 18    ...
	jmp	L18a2		;; 1873: c3 a2 18    ...

L1876:	call	L1708		;; 1876: cd 08 17    ...
L1879:	call	L1857		;; 1879: cd 57 18    .W.
	jz	L189c		;; 187c: ca 9c 18    ...
	jmp	L186c		;; 187f: c3 6c 18    .l.

L1882:	call	L1708		;; 1882: cd 08 17    ...
	xchg			;; 1885: eb          .
	jmp	L186c		;; 1886: c3 6c 18    .l.

L1889:	call	L1708		;; 1889: cd 08 17    ...
	xchg			;; 188c: eb          .
	jmp	L1879		;; 188d: c3 79 18    .y.

L1890:	call	L1708		;; 1890: cd 08 17    ...
	call	L1857		;; 1893: cd 57 18    .W.
	jnz	L189c		;; 1896: c2 9c 18    ...
	jmp	L18a2		;; 1899: c3 a2 18    ...

L189c:	lxi	h,0ffffh	;; 189c: 21 ff ff    ...
	jmp	L18df		;; 189f: c3 df 18    ...

L18a2:	lxi	h,0		;; 18a2: 21 00 00    ...
	jmp	L18df		;; 18a5: c3 df 18    ...

L18a8:	call	L16ff		;; 18a8: cd ff 16    ...
	inx	h		;; 18ab: 23          #
	jmp	L1851		;; 18ac: c3 51 18    .Q.

L18af:	call	L1708		;; 18af: cd 08 17    ...
	mov	a,d		;; 18b2: 7a          z
	ana	h		;; 18b3: a4          .
	mov	h,a		;; 18b4: 67          g
	mov	a,e		;; 18b5: 7b          {
	ana	l		;; 18b6: a5          .
	mov	l,a		;; 18b7: 6f          o
	jmp	L18df		;; 18b8: c3 df 18    ...

L18bb:	call	L1708		;; 18bb: cd 08 17    ...
	mov	a,d		;; 18be: 7a          z
	ora	h		;; 18bf: b4          .
	mov	h,a		;; 18c0: 67          g
	mov	a,e		;; 18c1: 7b          {
	ora	l		;; 18c2: b5          .
	mov	l,a		;; 18c3: 6f          o
	jmp	L18df		;; 18c4: c3 df 18    ...

L18c7:	call	L1708		;; 18c7: cd 08 17    ...
	mov	a,d		;; 18ca: 7a          z
	xra	h		;; 18cb: ac          .
	mov	h,a		;; 18cc: 67          g
	mov	a,e		;; 18cd: 7b          {
	xra	l		;; 18ce: ad          .
	mov	l,a		;; 18cf: 6f          o
	jmp	L18df		;; 18d0: c3 df 18    ...

L18d3:	call	L16ff		;; 18d3: cd ff 16    ...
	mov	l,h		;; 18d6: 6c          l
	jmp	L18dd		;; 18d7: c3 dd 18    ...

L18da:	call	L16ff		;; 18da: cd ff 16    ...
L18dd:	mvi	h,0		;; 18dd: 26 00       &.
L18df:	lda	L166f		;; 18df: 3a 6f 16    :o.
	mov	c,a		;; 18e2: 4f          O
	lda	L166e		;; 18e3: 3a 6e 16    :n.
	sub	c		;; 18e6: 91          .
	sta	L166d		;; 18e7: 32 6d 16    2m.
	push	h		;; 18ea: e5          .
	lhld	L1670		;; 18eb: 2a 70 16    *p.
	shld	L350b		;; 18ee: 22 0b 35    ".5
	pop	h		;; 18f1: e1          .
	xra	a		;; 18f2: af          .
	sta	L166e		;; 18f3: 32 6e 16    2n.
	sta	L166f		;; 18f6: 32 6f 16    2o.
	jmp	L1678		;; 18f9: c3 78 16    .x.

endstm:	lda	curctx		;; 18fc: 3a c4 34    :.4
	cpi	004h		;; 18ff: fe 04       ..
	rnz			;; 1901: c0          .
	lda	tokbuf+1	;; 1902: 3a c8 34    :.4
	cpi	cr		;; 1905: fe 0d       ..
	rz			;; 1907: c8          .
	cpi	';'		;; 1908: fe 3b       .;
	rz			;; 190a: c8          .
	cpi	'!'		;; 190b: fe 21       ..
	ret			;; 190d: c9          .

endtok:	call	endstm		;; 190e: cd fc 18    ...
	rz			;; 1911: c8          .
	cpi	','		;; 1912: fe 2c       .,
	ret			;; 1914: c9          .

L1915:	xra	a		;; 1915: af          .
	sta	L1674		;; 1916: 32 74 16    2t.
	sta	L1675		;; 1919: 32 75 16    2u.
	sta	L350a		;; 191c: 32 0a 35    2.5
	sta	L166f		;; 191f: 32 6f 16    2o.
	dcr	a		;; 1922: 3d          =
	sta	L1630		;; 1923: 32 30 16    20.
	lxi	h,0		;; 1926: 21 00 00    ...
	shld	L3508		;; 1929: 22 08 35    ".5
	shld	L350b		;; 192c: 22 0b 35    ".5
L192f:	xra	a		;; 192f: af          .
	sta	L166d		;; 1930: 32 6d 16    2m.
	call	endtok		;; 1933: cd 0e 19    ...
	jnz	L197b		;; 1936: c2 7b 19    .{.
; "pop" something and process it... until empty
L1939:	lxi	h,L1674		;; 1939: 21 74 16    .t.
	mov	a,m		;; 193c: 7e          ~
	ora	a		;; 193d: b7          .
	jz	L1951		;; 193e: ca 51 19    .Q.
	dcr	m		;; 1941: 35          5
	mov	e,a		;; 1942: 5f          _
	dcr	e		;; 1943: 1d          .
	mvi	d,0		;; 1944: 16 00       ..
	lxi	h,L1631		;; 1946: 21 31 16    .1.
	dad	d		;; 1949: 19          .
	mov	a,m		;; 194a: 7e          ~
	call	L1713		;; 194b: cd 13 17    ...
	jmp	L1939		;; 194e: c3 39 19    .9.

L1951:	lda	L1675		;; 1951: 3a 75 16    :u.
	cpi	1		;; 1954: fe 01       ..
	cnz	Eerror		;; 1956: c4 4b 1b    .K.
	lda	curerr		;; 1959: 3a 4b 34    :K4
	cpi	' '		;; 195c: fe 20       . 
	rnz			;; 195e: c0          .
	lhld	L1645		;; 195f: 2a 45 16    *E.
	shld	L3508		;; 1962: 22 08 35    ".5
	lda	L1655		;; 1965: 3a 55 16    :U.
	sta	L350a		;; 1968: 32 0a 35    2.5
	lhld	L165d		;; 196b: 2a 5d 16    *].
	shld	L350b		;; 196e: 22 0b 35    ".5
	cpi	004h		;; 1971: fe 04       ..
	rnz			;; 1973: c0          .
	lhld	L1676		;; 1974: 2a 76 16    *v.
	shld	cursym		;; 1977: 22 23 35    "#5
	ret			;; 197a: c9          .

; get 1 or 2 chars from Lxxxx buffer (error if 0 or >2)
L197b:	lda	curerr		;; 197b: 3a 4b 34    :K4
	cpi	' '		;; 197e: fe 20       . 
	jnz	L1b24		;; 1980: c2 24 1b    .$.
	lda	curctx		;; 1983: 3a c4 34    :.4
	cpi	003h		;; 1986: fe 03       ..
	jnz	L19a7		;; 1988: c2 a7 19    ...
	lda	tokbuf		;; 198b: 3a c7 34    :.4
	ora	a		;; 198e: b7          .
	cz	Eerror		;; 198f: cc 4b 1b    .K.
	cpi	003h		;; 1992: fe 03       ..
	cnc	Eerror		;; 1994: d4 4b 1b    .K.
	mvi	d,0		;; 1997: 16 00       ..
	lxi	h,tokbuf+1	;; 1999: 21 c8 34    ..4
	mov	e,m		;; 199c: 5e          ^
	inx	h		;; 199d: 23          #
	dcr	a		;; 199e: 3d          =
	jz	L19a3		;; 199f: ca a3 19    ...
	mov	d,m		;; 19a2: 56          V
L19a3:	xchg			;; 19a3: eb          .
	jmp	L1b04		;; 19a4: c3 04 1b    ...

L19a7:	cpi	002h		;; 19a7: fe 02       ..
	jnz	L19b2		;; 19a9: c2 b2 19    ...
	lhld	L34c5		;; 19ac: 2a c5 34    *.4
	jmp	L1b04		;; 19af: c3 04 1b    ...

L19b2:	call	keywrd		;; 19b2: cd dd 28    ..(
	jnz	L1a97		;; 19b5: c2 97 1a    ...
	cpi	25		;; 19b8: fe 19       ..
	jnc	L1a8c		;; 19ba: d2 8c 1a    ...
	cpi	24		;; 19bd: fe 18       ..
	jnz	L19fb		;; 19bf: c2 fb 19    ...
	call	L2056		;; 19c2: cd 56 20    .V 
	call	endstm		;; 19c5: cd fc 18    ...
	jz	L19f2		;; 19c8: ca f2 19    ...
	lda	curctx		;; 19cb: 3a c4 34    :.4
	cpi	003h		;; 19ce: fe 03       ..
	jnz	L19e3		;; 19d0: c2 e3 19    ...
	lda	tokbuf		;; 19d3: 3a c7 34    :.4
	ora	a		;; 19d6: b7          .
	jnz	L19e3		;; 19d7: c2 e3 19    ...
	call	L1dff		;; 19da: cd ff 1d    ...
	call	endtok		;; 19dd: cd 0e 19    ...
	jz	L19f2		;; 19e0: ca f2 19    ...
L19e3:	call	L2056		;; 19e3: cd 56 20    .V 
	call	endstm		;; 19e6: cd fc 18    ...
	jnz	L19e3		;; 19e9: c2 e3 19    ...
	lxi	h,0		;; 19ec: 21 00 00    ...
	jmp	L19f5		;; 19ef: c3 f5 19    ...

L19f2:	lxi	h,0ffffh	;; 19f2: 21 ff ff    ...
L19f5:	call	L1b2a		;; 19f5: cd 2a 1b    .*.
	jmp	L192f		;; 19f8: c3 2f 19    ./.

L19fb:	cpi	20		;; 19fb: fe 14       ..
	mov	c,a		;; 19fd: 4f          O
	lda	L1630		;; 19fe: 3a 30 16    :0.
	jnz	L1a11		;; 1a01: c2 11 1a    ...
	ora	a		;; 1a04: b7          .
	cz	Eerror		;; 1a05: cc 4b 1b    .K.
	mvi	a,0ffh		;; 1a08: 3e ff       >.
	sta	L1630		;; 1a0a: 32 30 16    20.
	mov	a,c		;; 1a0d: 79          y
	jmp	L1a5f		;; 1a0e: c3 5f 1a    ._.

L1a11:	ora	a		;; 1a11: b7          .
	jnz	L1a6a		;; 1a12: c2 6a 1a    .j.
L1a15:	push	b		;; 1a15: c5          .
	lda	L1674		;; 1a16: 3a 74 16    :t.
	ora	a		;; 1a19: b7          .
	jz	L1a3a		;; 1a1a: ca 3a 1a    .:.
	mov	e,a		;; 1a1d: 5f          _
	dcr	e		;; 1a1e: 1d          .
	mvi	d,0		;; 1a1f: 16 00       ..
	lxi	h,L163b		;; 1a21: 21 3b 16    .;.
	dad	d		;; 1a24: 19          .
	mov	a,m		;; 1a25: 7e          ~
	cmp	b		;; 1a26: b8          .
	jc	L1a3a		;; 1a27: da 3a 1a    .:.
	lxi	h,L1674		;; 1a2a: 21 74 16    .t.
	mov	m,e		;; 1a2d: 73          s
	lxi	h,L1631		;; 1a2e: 21 31 16    .1.
	dad	d		;; 1a31: 19          .
	mov	a,m		;; 1a32: 7e          ~
	call	L1713		;; 1a33: cd 13 17    ...
	pop	b		;; 1a36: c1          .
	jmp	L1a15		;; 1a37: c3 15 1a    ...

L1a3a:	pop	b		;; 1a3a: c1          .
	mov	a,c		;; 1a3b: 79          y
	cpi	21		;; 1a3c: fe 15       ..
	jnz	L1a5f		;; 1a3e: c2 5f 1a    ._.
	lxi	h,L1674		;; 1a41: 21 74 16    .t.
	mov	a,m		;; 1a44: 7e          ~
	ora	a		;; 1a45: b7          .
	jz	L1a58		;; 1a46: ca 58 1a    .X.
	dcr	a		;; 1a49: 3d          =
	mov	m,a		;; 1a4a: 77          w
	mov	e,a		;; 1a4b: 5f          _
	mvi	d,0		;; 1a4c: 16 00       ..
	lxi	h,L1631		;; 1a4e: 21 31 16    .1.
	dad	d		;; 1a51: 19          .
	mov	a,m		;; 1a52: 7e          ~
	cpi	20		;; 1a53: fe 14       ..
	jz	L1a5b		;; 1a55: ca 5b 1a    .[.
L1a58:	call	Eerror		;; 1a58: cd 4b 1b    .K.
L1a5b:	xra	a		;; 1a5b: af          .
	jmp	L1a64		;; 1a5c: c3 64 1a    .d.

L1a5f:	call	L16aa		;; 1a5f: cd aa 16    ...
	mvi	a,0ffh		;; 1a62: 3e ff       >.
L1a64:	sta	L1630		;; 1a64: 32 30 16    20.
	jmp	L1b24		;; 1a67: c3 24 1b    .$.

L1a6a:	mov	a,c		;; 1a6a: 79          y
	cpi	5		;; 1a6b: fe 05       ..
	jz	L1b24		;; 1a6d: ca 24 1b    .$.
	cpi	6		;; 1a70: fe 06       ..
	jnz	L1a7a		;; 1a72: c2 7a 1a    .z.
	inr	a		;; 1a75: 3c          <
	mov	c,a		;; 1a76: 4f          O
	jmp	L1a15		;; 1a77: c3 15 1a    ...

L1a7a:	cpi	14		;; 1a7a: fe 0e       ..
	jz	L1a15		;; 1a7c: ca 15 1a    ...
	cpi	18		;; 1a7f: fe 12       ..
	jz	L1a15		;; 1a81: ca 15 1a    ...
	cpi	19		;; 1a84: fe 13       ..
	cnz	Eerror		;; 1a86: c4 4b 1b    .K.
	jmp	L1a15		;; 1a89: c3 15 1a    ...

L1a8c:	cpi	26		;; 1a8c: fe 1a       ..
	cz	Eerror		;; 1a8e: cc 4b 1b    .K.
	mov	l,b		;; 1a91: 68          h
	mvi	h,0		;; 1a92: 26 00       &.
	jmp	L1b04		;; 1a94: c3 04 1b    ...

L1a97:	lda	curctx		;; 1a97: 3a c4 34    :.4
	cpi	004h		;; 1a9a: fe 04       ..
	jnz	L1ac2		;; 1a9c: c2 c2 1a    ...
	lda	tokbuf+1		;; 1a9f: 3a c8 34    :.4
	cpi	'$'		;; 1aa2: fe 24       .$
	jz	L1ab0		;; 1aa4: ca b0 1a    ...
	call	Eerror		;; 1aa7: cd 4b 1b    .K.
	lxi	h,0		;; 1aaa: 21 00 00    ...
	jmp	L1b04		;; 1aad: c3 04 1b    ...

L1ab0:	lhld	L350d		;; 1ab0: 2a 0d 35    *.5
	shld	L350b		;; 1ab3: 22 0b 35    ".5
	call	getadr		;; 1ab6: cd 6e 32    .n2
	lda	curseg		;; 1ab9: 3a 20 35    : 5
	sta	L166d		;; 1abc: 32 6d 16    2m.
	jmp	L1b04		;; 1abf: c3 04 1b    ...

L1ac2:	call	look7		;; 1ac2: cd a3 23    ..#
	call	isNULL		;; 1ac5: cd 76 23    .v#
	jnz	L1ad6		;; 1ac8: c2 d6 1a    ...
	mvi	a,'U'		;; 1acb: 3e 55       >U
	call	seterr		;; 1acd: cd d5 30    ..0
	lxi	h,0		;; 1ad0: 21 00 00    ...
	jmp	L1b04		;; 1ad3: c3 04 1b    ...

L1ad6:	call	symtyp		;; 1ad6: cd 1e 25    ..%
	sta	L166d		;; 1ad9: 32 6d 16    2m.
	ani	004h		;; 1adc: e6 04       ..
	jz	L1aea		;; 1ade: ca ea 1a    ...
	lhld	cursym		;; 1ae1: 2a 23 35    *#5
	shld	L1676		;; 1ae4: 22 76 16    "v.
	jmp	L1b04		;; 1ae7: c3 04 1b    ...

L1aea:	lda	L166d		;; 1aea: 3a 6d 16    :m.
	ani	050h		;; 1aed: e6 50       .P
	mvi	a,'U'		;; 1aef: 3e 55       >U
	cz	seterr		;; 1af1: cc d5 30    ..0
	call	symtyp		;; 1af4: cd 1e 25    ..%
	ani	003h		;; 1af7: e6 03       ..
	cpi	003h		;; 1af9: fe 03       ..
	jnz	L1b01		;; 1afb: c2 01 1b    ...
	call	L1b34		;; 1afe: cd 34 1b    .4.
L1b01:	call	getval		;; 1b01: cd 3e 25    .>%
L1b04:	lda	L166d		;; 1b04: 3a 6d 16    :m.
	ani	004h		;; 1b07: e6 04       ..
	jz	L1b14		;; 1b09: ca 14 1b    ...
	lxi	h,0		;; 1b0c: 21 00 00    ...
	mvi	a,004h		;; 1b0f: 3e 04       >.
	sta	L166d		;; 1b11: 32 6d 16    2m.
L1b14:	call	L1b2a		;; 1b14: cd 2a 1b    .*.
	xra	a		;; 1b17: af          .
	sta	L1630		;; 1b18: 32 30 16    20.
	sta	L166d		;; 1b1b: 32 6d 16    2m.
	lxi	h,0		;; 1b1e: 21 00 00    ...
	shld	L350b		;; 1b21: 22 0b 35    ".5
L1b24:	call	L1dff		;; 1b24: cd ff 1d    ...
	jmp	L192f		;; 1b27: c3 2f 19    ./.

L1b2a:	lda	L1630		;; 1b2a: 3a 30 16    :0.
	ora	a		;; 1b2d: b7          .
	cz	Eerror		;; 1b2e: cc 4b 1b    .K.
	jmp	L1678		;; 1b31: c3 78 16    .x.

L1b34:	lhld	cursym		;; 1b34: 2a 23 35    *#5
	mov	b,h		;; 1b37: 44          D
	mov	c,l		;; 1b38: 4d          M
	lhld	L3513		;; 1b39: 2a 13 35    *.5
L1b3c:	shld	L350b		;; 1b3c: 22 0b 35    ".5
	mov	a,l		;; 1b3f: 7d          }
	sub	c		;; 1b40: 91          .
	mov	a,h		;; 1b41: 7c          |
	sbb	b		;; 1b42: 98          .
	rc			;; 1b43: d8          .
	mov	e,m		;; 1b44: 5e          ^
	inx	h		;; 1b45: 23          #
	mov	d,m		;; 1b46: 56          V
	xchg			;; 1b47: eb          .
	jmp	L1b3c		;; 1b48: c3 3c 1b    .<.

Eerror:	push	h		;; 1b4b: e5          .
	mvi	a,'E'		;; 1b4c: 3e 45       >E
	call	seterr		;; 1b4e: cd d5 30    ..0
	pop	h		;; 1b51: e1          .
	ret			;; 1b52: c9          .

; Module begin L1600

L1b53:	db	0
L1b54:	db	0,0,0
L1b57:	db	0,0,0
adepth:	db	0	; angle-bracket nest depth (macro param
L1b5b:	db	0
L1b5c:	db	0

L1b5d:	lda	L3375		;; 1b5d: 3a 75 33    :u3
	ora	a		;; 1b60: b7          .
	jz	L1b9b		;; 1b61: ca 9b 1b    ...
	lhld	L33c6		;; 1b64: 2a c6 33    *.3
	mov	a,m		;; 1b67: 7e          ~
	ora	a		;; 1b68: b7          .
	jnz	L1b8c		;; 1b69: c2 8c 1b    ...
	lda	L3376		;; 1b6c: 3a 76 33    :v3
	cpi	002h		;; 1b6f: fe 02       ..
	jz	L1b81		;; 1b71: ca 81 1b    ...
	lxi	h,L1b5c		;; 1b74: 21 5c 1b    .\.
	inr	m		;; 1b77: 34          4
	mvi	a,0		;; 1b78: 3e 00       >.
	rnz			;; 1b7a: c0          .
	call	Berro3		;; 1b7b: cd 41 21    .A.
	call	L3028		;; 1b7e: cd 28 30    .(0
L1b81:	call	L22c0		;; 1b81: cd c0 22    .."
	lda	L33e8		;; 1b84: 3a e8 33    :.3
	ora	a		;; 1b87: b7          .
	rnz			;; 1b88: c0          .
	jmp	L1b5d		;; 1b89: c3 5d 1b    .].

L1b8c:	inx	h		;; 1b8c: 23          #
	shld	L33c6		;; 1b8d: 22 c6 33    ".3
	cpi	','		;; 1b90: fe 2c       .,
	jnz	L1b9e		;; 1b92: c2 9e 1b    ...
	shld	L33e6		;; 1b95: 22 e6 33    ".3
	jmp	L1b9e		;; 1b98: c3 9e 1b    ...

L1b9b:	call	L2df1		;; 1b9b: cd f1 2d    ..-
L1b9e:	sta	L1b5c		;; 1b9e: 32 5c 1b    2\.
	ret			;; 1ba1: c9          .

; put a char in PRN line buffer, strip CR/LF.
; trims any past 120 cols.
L1ba2:	push	psw		;; 1ba2: f5          .
	cpi	cr		;; 1ba3: fe 0d       ..
	jz	L1bc3		;; 1ba5: ca c3 1b    ...
	cpi	lf		;; 1ba8: fe 0a       ..
	jz	L1bc3		;; 1baa: ca c3 1b    ...
	lda	L34c3		;; 1bad: 3a c3 34    :.4
	cpi	120		;; 1bb0: fe 78       .x
	jnc	L1bc3		;; 1bb2: d2 c3 1b    ...
	mov	e,a		;; 1bb5: 5f          _
	mvi	d,0		;; 1bb6: 16 00       ..
	inr	a		;; 1bb8: 3c          <
	sta	L34c3		;; 1bb9: 32 c3 34    2.4
	lxi	h,prnbuf	;; 1bbc: 21 4b 34    .K4
	dad	d		;; 1bbf: 19          .
	pop	psw		;; 1bc0: f1          .
	mov	m,a		;; 1bc1: 77          w
	ret			;; 1bc2: c9          .

L1bc3:	pop	psw		;; 1bc3: f1          .
	ret			;; 1bc4: c9          .

L1bc5:	lda	L3439		;; 1bc5: 3a 39 34    :94
	call	L1d9c		;; 1bc8: cd 9c 1d    ...
	rnz			;; 1bcb: c0          .
	lda	L3439		;; 1bcc: 3a 39 34    :94
	call	L1d7f		;; 1bcf: cd 7f 1d    ...
	ret			;; 1bd2: c9          .

; get macro op, copy opcode string into buffer...
L1bd3:	xra	a		;; 1bd3: af          .
	sta	L343a		;; 1bd4: 32 3a 34    2:4
	sta	L3438		;; 1bd7: 32 38 34    284
	call	L1b5d		;; 1bda: cd 5d 1b    .].
	sta	L3439		;; 1bdd: 32 39 34    294
	lda	curctx		;; 1be0: 3a c4 34    :.4
	cpi	6		;; 1be3: fe 06       ..
	rz			;; 1be5: c8          .
	lda	L3439		;; 1be6: 3a 39 34    :94
	cpi	128		;; 1be9: fe 80       ..
	jc	L1c02		;; 1beb: da 02 1c    ...
	call	L294b		;; 1bee: cd 4b 29    .K)
	sta	L343a		;; 1bf1: 32 3a 34    2:4
	lxi	d,L343b		;; 1bf4: 11 3b 34    .;4
L1bf7:	mov	a,m		;; 1bf7: 7e          ~
	stax	d		;; 1bf8: 12          .
	inx	h		;; 1bf9: 23          #
	inx	d		;; 1bfa: 13          .
	dcr	b		;; 1bfb: 05          .
	jnz	L1bf7		;; 1bfc: c2 f7 1b    ...
	jmp	L1c21		;; 1bff: c3 21 1c    ...

L1c02:	call	L1d9c		;; 1c02: cd 9c 1d    ...
	rz			;; 1c05: c8          .
L1c06:	call	L1bc5		;; 1c06: cd c5 1b    ...
	jz	L1c2c		;; 1c09: ca 2c 1c    .,.
	lxi	h,L343a		;; 1c0c: 21 3a 34    .:4
	mov	a,m		;; 1c0f: 7e          ~
	cpi	15		;; 1c10: fe 0f       ..
	jnc	L1c2a		;; 1c12: d2 2a 1c    .*.
	inr	m		;; 1c15: 34          4
	lxi	h,L343b		;; 1c16: 21 3b 34    .;4
	mov	e,a		;; 1c19: 5f          _
	mvi	d,0		;; 1c1a: 16 00       ..
	dad	d		;; 1c1c: 19          .
	lda	L3439		;; 1c1d: 3a 39 34    :94
	mov	m,a		;; 1c20: 77          w
L1c21:	call	L1b5d		;; 1c21: cd 5d 1b    .].
	sta	L3439		;; 1c24: 32 39 34    294
	jmp	L1c06		;; 1c27: c3 06 1c    ...

L1c2a:	xra	a		;; 1c2a: af          .
	ret			;; 1c2b: c9          .

L1c2c:	xra	a		;; 1c2c: af          .
	inr	a		;; 1c2d: 3c          <
	ret			;; 1c2e: c9          .

L1c2f:	lhld	cursym		;; 1c2f: 2a 23 35    *#5
	shld	L1b57		;; 1c32: 22 57 1b    "W.
	call	look4		;; 1c35: cd 89 23    ..#
	call	L2334		;; 1c38: cd 34 23    .4#
	rnz			;; 1c3b: c0          .
	lhld	L1b57		;; 1c3c: 2a 57 1b    *W.
	shld	cursym		;; 1c3f: 22 23 35    "#5
	ret			;; 1c42: c9          .

; returns with current char in A
nxtchr:	xra	a		;; 1c43: af          .
	sta	L1b5b		;; 1c44: 32 5b 1b    2[.
L1c47:	lxi	h,L1b5b		;; 1c47: 21 5b 1b    .[.
	inr	m		;; 1c4a: 34          4
	jnz	L1c59		;; 1c4b: c2 59 1c    .Y.
	; overflowed counter... line too long?
	call	Oerro2		;; 1c4e: cd 35 21    .5.
	lxi	h,L343a		;; 1c51: 21 3a 34    .:4
	mvi	m,0		;; 1c54: 36 00       6.
	shld	L33c6		;; 1c56: 22 c6 33    ".3
L1c59:	lxi	h,L343a		;; 1c59: 21 3a 34    .:4
	mov	a,m		;; 1c5c: 7e          ~
	ora	a		;; 1c5d: b7          .
	jz	L1c71		;; 1c5e: ca 71 1c    .q.
	dcr	m		;; 1c61: 35          5
	lxi	h,L3438		;; 1c62: 21 38 34    .84
	mov	e,m		;; 1c65: 5e          ^
	inr	m		;; 1c66: 34          4
	mvi	d,0		;; 1c67: 16 00       ..
	lxi	h,L343b		;; 1c69: 21 3b 34    .;4
	dad	d		;; 1c6c: 19          .
	mov	a,m		;; 1c6d: 7e          ~
	jmp	L1ba2		;; 1c6e: c3 a2 1b    ...

L1c71:	lda	L3375		;; 1c71: 3a 75 33    :u3
	ora	a		;; 1c74: b7          .
	lda	L3439		;; 1c75: 3a 39 34    :94
	jnz	L1c86		;; 1c78: c2 86 1c    ...
	mov	b,a		;; 1c7b: 47          G
	ora	a		;; 1c7c: b7          .
	jnz	L1cb3		;; 1c7d: c2 b3 1c    ...
	call	L1b5d		;; 1c80: cd 5d 1b    .].
	jmp	L1ba2		;; 1c83: c3 a2 1b    ...

L1c86:	ora	a		;; 1c86: b7          .
	jz	L1cbb		;; 1c87: ca bb 1c    ...
	cpi	'^'		;; 1c8a: fe 5e       .^
	jnz	L1ca8		;; 1c8c: c2 a8 1c    ...
	; caret escapes...
	call	L1bd3		;; 1c8f: cd d3 1b    ...
	mvi	b,'^'		;; 1c92: 06 5e       .^
	jnz	L1cb7		;; 1c94: c2 b7 1c    ...
	lda	L3439		;; 1c97: 3a 39 34    :94
	cpi	'&'		;; 1c9a: fe 26       .&
	jnz	L1cb7		;; 1c9c: c2 b7 1c    ...
	lxi	h,L343a		;; 1c9f: 21 3a 34    .:4
	inr	m		;; 1ca2: 34          4
	inx	h		;; 1ca3: 23          #
	mov	m,a		;; 1ca4: 77          w
	jmp	L1cb3		;; 1ca5: c3 b3 1c    ...

L1ca8:	cpi	'&'		;; 1ca8: fe 26       .&
	jz	L1cda		;; 1caa: ca da 1c    ...
	mov	b,a		;; 1cad: 47          G
	cpi	del		;; 1cae: fe 7f       ..
	jz	L1ced		;; 1cb0: ca ed 1c    ...
L1cb3:	xra	a		;; 1cb3: af          .
	sta	L3439		;; 1cb4: 32 39 34    294
L1cb7:	mov	a,b		;; 1cb7: 78          x
	jmp	L1ba2		;; 1cb8: c3 a2 1b    ...

L1cbb:	call	L1bd3		;; 1cbb: cd d3 1b    ...
	jz	L1c47		;; 1cbe: ca 47 1c    .G.
	lda	L3439		;; 1cc1: 3a 39 34    :94
	cpi	'&'		;; 1cc4: fe 26       .&
	jz	L1cd1		;; 1cc6: ca d1 1c    ...
	lda	curctx		;; 1cc9: 3a c4 34    :.4
	cpi	003h		;; 1ccc: fe 03       ..
	jz	L1c47		;; 1cce: ca 47 1c    .G.
L1cd1:	call	L1c2f		;; 1cd1: cd 2f 1c    ./.
	jz	L1c47		;; 1cd4: ca 47 1c    .G.
	jmp	L1cf9		;; 1cd7: c3 f9 1c    ...

L1cda:	call	L1bd3		;; 1cda: cd d3 1b    ...
	mvi	b,'&'		;; 1cdd: 06 26       .&
	jz	L1cb7		;; 1cdf: ca b7 1c    ...
	call	L1c2f		;; 1ce2: cd 2f 1c    ./.
	mvi	b,'&'		;; 1ce5: 06 26       .&
	jz	L1cb7		;; 1ce7: ca b7 1c    ...
	jmp	L1cf9		;; 1cea: c3 f9 1c    ...

L1ced:	call	L1bd3		;; 1ced: cd d3 1b    ...
	jz	L1c47		;; 1cf0: ca 47 1c    .G.
	call	L1c2f		;; 1cf3: cd 2f 1c    ./.
	jz	L1c47		;; 1cf6: ca 47 1c    .G.
L1cf9:	lxi	h,L3439		;; 1cf9: 21 39 34    .94
	mov	a,m		;; 1cfc: 7e          ~
	cpi	'&'		;; 1cfd: fe 26       .&
	jnz	L1d04		;; 1cff: c2 04 1d    ...
	mvi	a,del		;; 1d02: 3e 7f       >.
L1d04:	mvi	m,0		;; 1d04: 36 00       6.
	sta	L33e8		;; 1d06: 32 e8 33    2.3
	call	L2279		;; 1d09: cd 79 22    .y"
	lxi	h,L3376		;; 1d0c: 21 76 33    .v3
	mvi	m,002h		;; 1d0f: 36 02       6.
	lhld	memtop		;; 1d11: 2a 11 35    *.5
	shld	L33f8		;; 1d14: 22 f8 33    ".3
	call	symval		;; 1d17: cd f4 24    ..$
	shld	L33c6		;; 1d1a: 22 c6 33    ".3
	xra	a		;; 1d1d: af          .
	sta	L343a		;; 1d1e: 32 3a 34    2:4
	lhld	L1b57		;; 1d21: 2a 57 1b    *W.
	shld	cursym		;; 1d24: 22 23 35    "#5
	call	L1bd3		;; 1d27: cd d3 1b    ...
	jmp	L1c47		;; 1d2a: c3 47 1c    .G.

L1d2d:	call	clrtok		;; 1d2d: cd 4a 1d    .J.
	sta	L343a		;; 1d30: 32 3a 34    2:4
	sta	L3439		;; 1d33: 32 39 34    294
	sta	curchr		;; 1d36: 32 28 35    2(5
	sta	L34c3		;; 1d39: 32 c3 34    2.4
	mvi	a,lf		;; 1d3c: 3e 0a       >.
	sta	L1b53		;; 1d3e: 32 53 1b    2S.
	call	L3028		;; 1d41: cd 28 30    .(0
	mvi	a,010h		;; 1d44: 3e 10       >.
	sta	L34c3		;; 1d46: 32 c3 34    2.4
	ret			;; 1d49: c9          .

clrtok:	xra	a		;; 1d4a: af          .
	sta	tokbuf		;; 1d4b: 32 c7 34    2.4
	sta	L1b54		;; 1d4e: 32 54 1b    2T.
	ret			;; 1d51: c9          .

L1d52:	lxi	h,tokbuf	;; 1d52: 21 c7 34    ..4
	mov	a,m		;; 1d55: 7e          ~
	cpi	64		;; 1d56: fe 40       .@
	jc	L1d60		;; 1d58: da 60 1d    .`.
	mvi	m,0		;; 1d5b: 36 00       6.
	call	Oerro2		;; 1d5d: cd 35 21    .5.
L1d60:	mov	e,m		;; 1d60: 5e          ^
	mvi	d,0		;; 1d61: 16 00       ..
	inr	m		;; 1d63: 34          4
	inx	h		;; 1d64: 23          #
	dad	d		;; 1d65: 19          .
	lda	curchr		;; 1d66: 3a 28 35    :(5
	mov	c,a		;; 1d69: 4f          O
	lda	curctx		;; 1d6a: 3a c4 34    :.4
	cpi	003h		;; 1d6d: fe 03       ..
	mov	a,c		;; 1d6f: 79          y
	cnz	touppr		;; 1d70: c4 44 28    .D(
	mov	m,a		;; 1d73: 77          w
	ret			;; 1d74: c9          .

L1d75:	mov	a,m		;; 1d75: 7e          ~
	cpi	'$'		;; 1d76: fe 24       .$
	rnz			;; 1d78: c0          .
	xra	a		;; 1d79: af          .
	mov	m,a		;; 1d7a: 77          w
	ret			;; 1d7b: c9          .

; is char '0'-'9'?
; returns .TRUE. if digit
isdig:	lda	curchr		;; 1d7c: 3a 28 35    :(5
L1d7f:	sui	'0'		;; 1d7f: d6 30       .0
	cpi	'9'-'0'+1	;; 1d81: fe 0a       ..
	ral			;; 1d83: 17          .
	ani	001h		;; 1d84: e6 01       ..
	ret			;; 1d86: c9          .

; is char 'A'-'F'?
; returns .TRUE. if hex alpha
L1d87:	call	isdig		;; 1d87: cd 7c 1d    .|.
	rnz			;; 1d8a: c0          .
	lda	curchr		;; 1d8b: 3a 28 35    :(5
	call	touppr		;; 1d8e: cd 44 28    .D(
	sui	'A'		;; 1d91: d6 41       .A
	cpi	'F'-'A'+1	;; 1d93: fe 06       ..
	ral			;; 1d95: 17          .
	ani	001h		;; 1d96: e6 01       ..
	ret			;; 1d98: c9          .

; is first char of symbol valid?
; returns .TRUE. if valid symbol start
issym:	lda	curchr		;; 1d99: 3a 28 35    :(5
L1d9c:	cpi	'?'		;; 1d9c: fe 3f       .?
	jz	L1db1		;; 1d9e: ca b1 1d    ...
	cpi	'@'		;; 1da1: fe 40       .@
	jz	L1db1		;; 1da3: ca b1 1d    ...
	call	touppr		;; 1da6: cd 44 28    .D(
	sui	'A'		;; 1da9: d6 41       .A
	cpi	'Z'-'A'+1	;; 1dab: fe 1a       ..
	ral			;; 1dad: 17          .
	ani	001h		;; 1dae: e6 01       ..
	ret			;; 1db0: c9          .

L1db1:	ora	a		;; 1db1: b7          .
	ret			;; 1db2: c9          .

L1db3:	call	issym		;; 1db3: cd 99 1d    ...
	rnz			;; 1db6: c0          .
	call	isdig		;; 1db7: cd 7c 1d    .|.
	ret			;; 1dba: c9          .

; check for valid (first?) char
; sets 'I' error if not
validc:	cpi	' '		;; 1dbb: fe 20       . 
	rnc			;; 1dbd: d0          .
	cpi	tab		;; 1dbe: fe 09       ..
	rz			;; 1dc0: c8          .
	cpi	cr		;; 1dc1: fe 0d       ..
	rz			;; 1dc3: c8          .
	cpi	lf		;; 1dc4: fe 0a       ..
	rz			;; 1dc6: c8          .
	cpi	eof		;; 1dc7: fe 1a       ..
	rz			;; 1dc9: c8          .
	jmp	Ierror		;; 1dca: c3 3b 21    .;.

getchr:	call	nxtchr		;; 1dcd: cd 43 1c    .C.
	call	validc		;; 1dd0: cd bb 1d    ...
	sta	curchr		;; 1dd3: 32 28 35    2(5
	lda	L3527		;; 1dd6: 3a 27 35    :'5
	ora	a		;; 1dd9: b7          .
	jz	L1df2		;; 1dda: ca f2 1d    ...
	lda	L3529		;; 1ddd: 3a 29 35    :)5
	cpi	001h		;; 1de0: fe 01       ..
	jnz	L1dec		;; 1de2: c2 ec 1d    ...
	lda	pass		;; 1de5: 3a 15 35    :.5
	ora	a		;; 1de8: b7          .
	jnz	L1df2		;; 1de9: c2 f2 1d    ...
L1dec:	lda	curchr		;; 1dec: 3a 28 35    :(5
	call	puttmp		;; 1def: cd ab 25    ..%
L1df2:	lda	curchr		;; 1df2: 3a 28 35    :(5
	ret			;; 1df5: c9          .

; is char end-of-statement?
isEOS:	cpi	cr		;; 1df6: fe 0d       ..
	rz			;; 1df8: c8          .
	cpi	eof		;; 1df9: fe 1a       ..
	rz			;; 1dfb: c8          .
	cpi	'!'		;; 1dfc: fe 21       ..
	ret			;; 1dfe: c9          .

; parse one token?
L1dff:	call	clrtok		;; 1dff: cd 4a 1d    .J.
L1e02:	xra	a		;; 1e02: af          .
	sta	curctx		;; 1e03: 32 c4 34    2.4
	lda	curchr		;; 1e06: 3a 28 35    :(5
	cpi	tab		;; 1e09: fe 09       ..
	jz	L1e9e		;; 1e0b: ca 9e 1e    ...
	cpi	';'		;; 1e0e: fe 3b       .;
	jnz	L1e7b		;; 1e10: c2 7b 1e    .{.
	; entering comment...
	mvi	a,6		;; 1e13: 3e 06       >.
	sta	curctx		;; 1e15: 32 c4 34    2.4
	lda	L3527		;; 1e18: 3a 27 35    :'5
	ora	a		;; 1e1b: b7          .
	jz	L1e8b		;; 1e1c: ca 8b 1e    ...
	lda	L3529		;; 1e1f: 3a 29 35    :)5
	cpi	001h		;; 1e22: fe 01       ..
	jnz	L1e2e		;; 1e24: c2 2e 1e    ...
	lda	pass		;; 1e27: 3a 15 35    :.5
	ora	a		;; 1e2a: b7          .
	jnz	L1e8b		;; 1e2b: c2 8b 1e    ...
L1e2e:	call	getchr		;; 1e2e: cd cd 1d    ...
	cpi	';'		;; 1e31: fe 3b       .;
	jnz	L1e8e		;; 1e33: c2 8e 1e    ...
	lhld	L352d		;; 1e36: 2a 2d 35    *-5
	xchg			;; 1e39: eb          .
	lhld	tmpptr		;; 1e3a: 2a 25 35    *%5
	dcx	h		;; 1e3d: 2b          +
	dcx	h		;; 1e3e: 2b          +
L1e3f:	mov	a,e		;; 1e3f: 7b          {
	cmp	l		;; 1e40: bd          .
	jnz	L1e49		;; 1e41: c2 49 1e    .I.
	mov	a,d		;; 1e44: 7a          z
	cmp	h		;; 1e45: bc          .
	jz	L1e5d		;; 1e46: ca 5d 1e    .].
L1e49:	mov	a,m		;; 1e49: 7e          ~
	cpi	lf		;; 1e4a: fe 0a       ..
	jnz	L1e54		;; 1e4c: c2 54 1e    .T.
	dcx	h		;; 1e4f: 2b          +
	dcx	h		;; 1e50: 2b          +
	jmp	L1e5d		;; 1e51: c3 5d 1e    .].

L1e54:	cpi	' '+1		;; 1e54: fe 21       ..
	jnc	L1e5d		;; 1e56: d2 5d 1e    .].
	dcx	h		;; 1e59: 2b          +
	jmp	L1e3f		;; 1e5a: c3 3f 1e    .?.

L1e5d:	shld	tmpptr		;; 1e5d: 22 25 35    "%5
	lda	L3527		;; 1e60: 3a 27 35    :'5
	push	psw		;; 1e63: f5          .
	xra	a		;; 1e64: af          .
	sta	L3527		;; 1e65: 32 27 35    2'5
	; discard chars until EOS
L1e68:	call	getchr		;; 1e68: cd cd 1d    ...
	call	isEOS		;; 1e6b: cd f6 1d    ...
	jnz	L1e68		;; 1e6e: c2 68 1e    .h.
	call	puttmp		;; 1e71: cd ab 25    ..%
	pop	psw		;; 1e74: f1          .
	sta	L3527		;; 1e75: 32 27 35    2'5
	jmp	L1ea4		;; 1e78: c3 a4 1e    ...

L1e7b:	lda	curchr		;; 1e7b: 3a 28 35    :(5
	cpi	'*'		;; 1e7e: fe 2a       .*
	jnz	L1e97		;; 1e80: c2 97 1e    ...
	lda	L1b53		;; 1e83: 3a 53 1b    :S.
	cpi	lf		;; 1e86: fe 0a       ..
	jnz	L1e97		;; 1e88: c2 97 1e    ...
L1e8b:	call	getchr		;; 1e8b: cd cd 1d    ...
L1e8e:	call	isEOS		;; 1e8e: cd f6 1d    ...
	jz	L1ea4		;; 1e91: ca a4 1e    ...
	jmp	L1e8b		;; 1e94: c3 8b 1e    ...

L1e97:	ori	020h		;; 1e97: f6 20       . 
	cpi	020h		;; 1e99: fe 20       . 
	jnz	L1ea4		;; 1e9b: c2 a4 1e    ...
L1e9e:	call	getchr		;; 1e9e: cd cd 1d    ...
	jmp	L1e02		;; 1ea1: c3 02 1e    ...

L1ea4:	xra	a		;; 1ea4: af          .
	sta	curctx		;; 1ea5: 32 c4 34    2.4
	call	issym		;; 1ea8: cd 99 1d    ...
	jz	L1eb3		;; 1eab: ca b3 1e    ...
	; parsing a symbol (or opcode?)
	mvi	a,001h		;; 1eae: 3e 01       >.
	jmp	L1eef		;; 1eb0: c3 ef 1e    ...

L1eb3:	call	isdig		;; 1eb3: cd 7c 1d    .|.
	jz	L1ebe		;; 1eb6: ca be 1e    ...
	; parsing a numeric value
	mvi	a,002h		;; 1eb9: 3e 02       >.
	jmp	L1eef		;; 1ebb: c3 ef 1e    ...

L1ebe:	lda	curchr		;; 1ebe: 3a 28 35    :(5
	cpi	''''		;; 1ec1: fe 27       .'
	jnz	L1ecf		;; 1ec3: c2 cf 1e    ...
	; parsing a quoted string...
	xra	a		;; 1ec6: af          .
	sta	curchr		;; 1ec7: 32 28 35    2(5
	mvi	a,003h		;; 1eca: 3e 03       >.
	jmp	L1eef		;; 1ecc: c3 ef 1e    ...

L1ecf:	cpi	lf		;; 1ecf: fe 0a       ..
	jnz	L1eed		;; 1ed1: c2 ed 1e    ...
	; what is LF for?
	lda	L3375		;; 1ed4: 3a 75 33    :u3
	ora	a		;; 1ed7: b7          .
	jz	L1ee0		;; 1ed8: ca e0 1e    ...
	mvi	a,'+'		;; 1edb: 3e 2b       >+
	sta	prnbuf+5	;; 1edd: 32 50 34    2P4
L1ee0:	call	L3028		;; 1ee0: cd 28 30    .(0
	lxi	h,curerr	;; 1ee3: 21 4b 34    .K4
	mvi	m,' '		;; 1ee6: 36 20       6 
	mvi	a,010h		;; 1ee8: 3e 10       >.
	sta	L34c3		;; 1eea: 32 c3 34    2.4
	; next state after LF???
L1eed:	mvi	a,004h		;; 1eed: 3e 04       >.
L1eef:	sta	curctx		;; 1eef: 32 c4 34    2.4
L1ef2:	lda	curchr		;; 1ef2: 3a 28 35    :(5
	sta	L1b53		;; 1ef5: 32 53 1b    2S.
	ora	a		;; 1ef8: b7          .
	cnz	L1d52		;; 1ef9: c4 52 1d    .R.
	call	getchr		;; 1efc: cd cd 1d    ...
	lda	curctx		;; 1eff: 3a c4 34    :.4
	cpi	004h		;; 1f02: fe 04       ..
	jnz	L1f5a		;; 1f04: c2 5a 1f    .Z.
	lda	L3527		;; 1f07: 3a 27 35    :'5
	ora	a		;; 1f0a: b7          .
	rnz			;; 1f0b: c0          .
	lda	tokbuf+1	;; 1f0c: 3a c8 34    :.4
	cpi	'='		;; 1f0f: fe 3d       .=
	jnz	L1f1a		;; 1f11: c2 1a 1f    ...
	lxi	h,'EQ'		;; 1f14: 21 45 51    .EQ
	jmp	L1f4d		;; 1f17: c3 4d 1f    .M.

L1f1a:	cpi	'<'		;; 1f1a: fe 3c       .<
	jnz	L1f38		;; 1f1c: c2 38 1f    .8.
	lxi	h,'LE'		;; 1f1f: 21 4c 45    .LE
	lda	curchr		;; 1f22: 3a 28 35    :(5
	cpi	'='		;; 1f25: fe 3d       .=
	jz	L1f49		;; 1f27: ca 49 1f    .I.
	lxi	h,'NE'		;; 1f2a: 21 4e 45    .NE
	cpi	'>'		;; 1f2d: fe 3e       .>
	jz	L1f49		;; 1f2f: ca 49 1f    .I.
	lxi	h,'LT'		;; 1f32: 21 4c 54    .LT
	jmp	L1f4d		;; 1f35: c3 4d 1f    .M.

L1f38:	cpi	'>'		;; 1f38: fe 3e       .>
	rnz			;; 1f3a: c0          .
	lxi	h,'GT'		;; 1f3b: 21 47 54    .GT
	lda	curchr		;; 1f3e: 3a 28 35    :(5
	cpi	'='		;; 1f41: fe 3d       .=
	jnz	L1f4d		;; 1f43: c2 4d 1f    .M.
	lxi	h,'GE'		;; 1f46: 21 47 45    .GE
L1f49:	xra	a		;; 1f49: af          .
	sta	curchr		;; 1f4a: 32 28 35    2(5
L1f4d:	shld	tokbuf+1	;; 1f4d: 22 c8 34    ".4
	lxi	h,tokbuf	;; 1f50: 21 c7 34    ..4
	inr	m		;; 1f53: 34          4
	mvi	a,001h		;; 1f54: 3e 01       >.
	sta	curctx		;; 1f56: 32 c4 34    2.4
	ret			;; 1f59: c9          .

L1f5a:	lxi	h,curchr		;; 1f5a: 21 28 35    .(5
	lda	curctx		;; 1f5d: 3a c4 34    :.4
	cpi	001h		;; 1f60: fe 01       ..
	jnz	L1f72		;; 1f62: c2 72 1f    .r.
	call	L1d75		;; 1f65: cd 75 1d    .u.
	jz	L1ef2		;; 1f68: ca f2 1e    ...
	call	L1db3		;; 1f6b: cd b3 1d    ...
	jnz	L1ef2		;; 1f6e: c2 f2 1e    ...
	ret			;; 1f71: c9          .

; determine number base... from suffix
L1f72:	cpi	002h		;; 1f72: fe 02       ..
	jnz	L200e		;; 1f74: c2 0e 20    .. 
	call	L1d75		;; 1f77: cd 75 1d    .u.
	jz	L1ef2		;; 1f7a: ca f2 1e    ...
	call	L1d87		;; 1f7d: cd 87 1d    ...
	jnz	L1ef2		;; 1f80: c2 f2 1e    ...
	lda	curchr		;; 1f83: 3a 28 35    :(5
	call	touppr		;; 1f86: cd 44 28    .D(
	cpi	'O'		;; 1f89: fe 4f       .O
	jz	L1f93		;; 1f8b: ca 93 1f    ...
	cpi	'Q'		;; 1f8e: fe 51       .Q
	jnz	L1f98		;; 1f90: c2 98 1f    ...
L1f93:	mvi	a,8		;; 1f93: 3e 08       >.
	jmp	L1f9f		;; 1f95: c3 9f 1f    ...

L1f98:	cpi	'H'		;; 1f98: fe 48       .H
	jnz	L1fa9		;; 1f9a: c2 a9 1f    ...
	mvi	a,16		;; 1f9d: 3e 10       >.
L1f9f:	sta	L1b54		;; 1f9f: 32 54 1b    2T.
	xra	a		;; 1fa2: af          .
	sta	curchr		;; 1fa3: 32 28 35    2(5
	jmp	L1fc7		;; 1fa6: c3 c7 1f    ...

L1fa9:	lda	L1b53		;; 1fa9: 3a 53 1b    :S.
	call	touppr		;; 1fac: cd 44 28    .D(
	cpi	'B'		;; 1faf: fe 42       .B
	jnz	L1fb9		;; 1fb1: c2 b9 1f    ...
	mvi	a,2		;; 1fb4: 3e 02       >.
	jmp	L1fc0		;; 1fb6: c3 c0 1f    ...

L1fb9:	cpi	'D'		;; 1fb9: fe 44       .D
	mvi	a,10		;; 1fbb: 3e 0a       >.
	jnz	L1fc4		;; 1fbd: c2 c4 1f    ...
L1fc0:	lxi	h,tokbuf	;; 1fc0: 21 c7 34    ..4
	dcr	m		;; 1fc3: 35          5
L1fc4:	sta	L1b54		;; 1fc4: 32 54 1b    2T.
L1fc7:	lxi	h,0		;; 1fc7: 21 00 00    ...
	shld	L34c5		;; 1fca: 22 c5 34    ".4
	lxi	h,tokbuf	;; 1fcd: 21 c7 34    ..4
	mov	c,m		;; 1fd0: 4e          N
	inx	h		;; 1fd1: 23          #
L1fd2:	mov	a,m		;; 1fd2: 7e          ~
	inx	h		;; 1fd3: 23          #
	cpi	'A'		;; 1fd4: fe 41       .A
	jnc	L1fde		;; 1fd6: d2 de 1f    ...
	sui	'0'		;; 1fd9: d6 30       .0
	jmp	L1fe0		;; 1fdb: c3 e0 1f    ...

L1fde:	sui	'A'-10		;; 1fde: d6 37       .7
L1fe0:	push	h		;; 1fe0: e5          .
	push	b		;; 1fe1: c5          .
	mov	c,a		;; 1fe2: 4f          O
	lxi	h,L1b54		;; 1fe3: 21 54 1b    .T.
	cmp	m		;; 1fe6: be          .
	cnc	Verro2		;; 1fe7: d4 2f 21    ./.
	mvi	b,0		;; 1fea: 06 00       ..
	mov	a,m		;; 1fec: 7e          ~
	lhld	L34c5		;; 1fed: 2a c5 34    *.4
	xchg			;; 1ff0: eb          .
	lxi	h,0		;; 1ff1: 21 00 00    ...
L1ff4:	ora	a		;; 1ff4: b7          .
	jz	L2003		;; 1ff5: ca 03 20    .. 
	rar			;; 1ff8: 1f          .
	jnc	L1ffd		;; 1ff9: d2 fd 1f    ...
	dad	d		;; 1ffc: 19          .
L1ffd:	xchg			;; 1ffd: eb          .
	dad	h		;; 1ffe: 29          )
	xchg			;; 1fff: eb          .
	jmp	L1ff4		;; 2000: c3 f4 1f    ...

L2003:	dad	b		;; 2003: 09          .
	shld	L34c5		;; 2004: 22 c5 34    ".4
	pop	b		;; 2007: c1          .
	pop	h		;; 2008: e1          .
	dcr	c		;; 2009: 0d          .
	jnz	L1fd2		;; 200a: c2 d2 1f    ...
	ret			;; 200d: c9          .

L200e:	lda	curchr		;; 200e: 3a 28 35    :(5
	cpi	cr		;; 2011: fe 0d       ..
	jz	Oerro2		;; 2013: ca 35 21    .5.
	cpi	''''		;; 2016: fe 27       .'
	jnz	L1ef2		;; 2018: c2 f2 1e    ...
	call	getchr		;; 201b: cd cd 1d    ...
	cpi	''''		;; 201e: fe 27       .'
	rnz			;; 2020: c0          .
	jmp	L1ef2		;; 2021: c3 f2 1e    ...

iswhts:	lda	curchr		;; 2024: 3a 28 35    :(5
	ora	a		;; 2027: b7          .
	rz			;; 2028: c8          .
	cpi	' '		;; 2029: fe 20       . 
	rz			;; 202b: c8          .
	cpi	tab		;; 202c: fe 09       ..
	ret			;; 202e: c9          .

isetok:	lda	curchr		;; 202f: 3a 28 35    :(5
	cpi	','		;; 2032: fe 2c       .,
	rz			;; 2034: c8          .
	cpi	';'		;; 2035: fe 3b       .;
	rz			;; 2037: c8          .
	cpi	'%'		;; 2038: fe 25       .%
	rz			;; 203a: c8          .
isestm:	lda	curchr		;; 203b: 3a 28 35    :(5
	cpi	cr		;; 203e: fe 0d       ..
	rz			;; 2040: c8          .
	cpi	eof		;; 2041: fe 1a       ..
	rz			;; 2043: c8          .
	cpi	'!'		;; 2044: fe 21       ..
	ret			;; 2046: c9          .

L2047:	lda	curchr		;; 2047: 3a 28 35    :(5
	cpi	';'		;; 204a: fe 3b       .;
	rz			;; 204c: c8          .
	cpi	' '		;; 204d: fe 20       . 
	rz			;; 204f: c8          .
	cpi	tab		;; 2050: fe 09       ..
	rz			;; 2052: c8          .
	cpi	','		;; 2053: fe 2c       .,
	ret			;; 2055: c9          .

; start processing line/statement
L2056:	call	clrtok		;; 2056: cd 4a 1d    .J.
	xra	a		;; 2059: af          .
	sta	curctx		;; 205a: 32 c4 34    2.4
	sta	adepth		;; 205d: 32 5a 1b    2Z.
L2060:	call	iswhts		;; 2060: cd 24 20    .$ 
	jnz	L206c		;; 2063: c2 6c 20    .l 
	call	getchr		;; 2066: cd cd 1d    ...
	jmp	L2060		;; 2069: c3 60 20    .` 

; first non-whitespace character...
L206c:	call	isetok		;; 206c: cd 2f 20    ./ 
	jnz	L2089		;; 206f: c2 89 20    .. 
	mvi	a,004h		;; 2072: 3e 04       >.
	sta	curctx		;; 2074: 32 c4 34    2.4
	jmp	L2123		;; 2077: c3 23 21    .#.

L207a:	lda	curchr		;; 207a: 3a 28 35    :(5
	sta	L1b53		;; 207d: 32 53 1b    2S.
	call	getchr		;; 2080: cd cd 1d    ...
	lda	curctx		;; 2083: 3a c4 34    :.4
	cpi	004h		;; 2086: fe 04       ..
	rz			;; 2088: c8          .
L2089:	call	isestm		;; 2089: cd 3b 20    .; 
	jnz	L20a1		;; 208c: c2 a1 20    .. 
	lda	curctx		;; 208f: 3a c4 34    :.4
	cpi	003h		;; 2092: fe 03       ..
	cz	Verro2		;; 2094: cc 2f 21    ./.
	lda	adepth		;; 2097: 3a 5a 1b    :Z.
	ora	a		;; 209a: b7          .
	cnz	Verro2		;; 209b: c4 2f 21    ./.
	jmp	L2129		;; 209e: c3 29 21    .).

L20a1:	lda	curctx		;; 20a1: 3a c4 34    :.4
	cpi	003h		;; 20a4: fe 03       ..
	jnz	L20c6		;; 20a6: c2 c6 20    .. 
	; in context of quoted string...
	lda	curchr		;; 20a9: 3a 28 35    :(5
	cpi	''''		;; 20ac: fe 27       .'
	jnz	L2123		;; 20ae: c2 23 21    .#.
	; end of quoted string... maybe
	call	L1d52		;; 20b1: cd 52 1d    .R.
	call	getchr		;; 20b4: cd cd 1d    ...
	lda	curchr		;; 20b7: 3a 28 35    :(5
	cpi	''''		;; 20ba: fe 27       .'
	jz	L207a		;; 20bc: ca 7a 20    .z 
	; yes, end of string
	xra	a		;; 20bf: af          .
	sta	curctx		;; 20c0: 32 c4 34    2.4
	jmp	L2089		;; 20c3: c3 89 20    .. 

L20c6:	lda	curchr		;; 20c6: 3a 28 35    :(5
	cpi	''''		;; 20c9: fe 27       .'
	jnz	L20d6		;; 20cb: c2 d6 20    .. 
	; quoted string param...
	mvi	a,003h		;; 20ce: 3e 03       >.
	sta	curctx		;; 20d0: 32 c4 34    2.4
	jmp	L2123		;; 20d3: c3 23 21    .#.

L20d6:	cpi	'^'		;; 20d6: fe 5e       .^
	jnz	L20f1		;; 20d8: c2 f1 20    .. 
	; special char escape... (really only blank/tab)
	call	getchr		;; 20db: cd cd 1d    ...
	lda	curchr		;; 20de: 3a 28 35    :(5
	cpi	tab		;; 20e1: fe 09       ..
	jz	L2123		;; 20e3: ca 23 21    .#.
	cpi	' '		;; 20e6: fe 20       . 
	jnc	L2123		;; 20e8: d2 23 21    .#.
	call	Ierror		;; 20eb: cd 3b 21    .;.
	jmp	L2129		;; 20ee: c3 29 21    .).

L20f1:	cpi	'<'		;; 20f1: fe 3c       .<
	jnz	L2102		;; 20f3: c2 02 21    ...
	; macro param form: <param>  (nesting allowed)
	lxi	h,adepth		;; 20f6: 21 5a 1b    .Z.
	mov	a,m		;; 20f9: 7e          ~
	inr	m		;; 20fa: 34          4
	ora	a		;; 20fb: b7          .
	jz	L207a		;; 20fc: ca 7a 20    .z 
	jmp	L2123		;; 20ff: c3 23 21    .#.

L2102:	cpi	'>'		;; 2102: fe 3e       .>
	jnz	L2116		;; 2104: c2 16 21    ...
	lxi	h,adepth		;; 2107: 21 5a 1b    .Z.
	mov	a,m		;; 210a: 7e          ~
	ora	a		;; 210b: b7          .
	jz	L2123		;; 210c: ca 23 21    .#.
	dcr	m		;; 210f: 35          5
	jz	L207a		;; 2110: ca 7a 20    .z 
	jmp	L2123		;; 2113: c3 23 21    .#.

L2116:	lda	adepth		;; 2116: 3a 5a 1b    :Z.
	ora	a		;; 2119: b7          .
	jnz	L2123		;; 211a: c2 23 21    .#.
	call	L2047		;; 211d: cd 47 20    .G 
	jz	L2129		;; 2120: ca 29 21    .).
L2123:	call	L1d52		;; 2123: cd 52 1d    .R.
	jmp	L207a		;; 2126: c3 7a 20    .z 

L2129:	mvi	a,005h		;; 2129: 3e 05       >.
	sta	curctx		;; 212b: 32 c4 34    2.4
	ret			;; 212e: c9          .

Verro2:	push	psw		;; 212f: f5          .
	mvi	a,'V'		;; 2130: 3e 56       >V
	jmp	L2147		;; 2132: c3 47 21    .G.

Oerro2:	push	psw		;; 2135: f5          .
	mvi	a,'O'		;; 2136: 3e 4f       >O
	jmp	L2147		;; 2138: c3 47 21    .G.

Ierror:	push	psw		;; 213b: f5          .
	mvi	a,'I'		;; 213c: 3e 49       >I
	jmp	L2147		;; 213e: c3 47 21    .G.

Berro3:	push	psw		;; 2141: f5          .
	mvi	a,'B'		;; 2142: 3e 42       >B
	jmp	L2147		;; 2144: c3 47 21    .G.

L2147:	push	b		;; 2147: c5          .
	push	h		;; 2148: e5          .
	call	seterr		;; 2149: cd d5 30    ..0
	pop	h		;; 214c: e1          .
	pop	b		;; 214d: c1          .
	pop	psw		;; 214e: f1          .
	ret			;; 214f: c9          .

; Module begin L1c00

; alternate space, larger, temp list of symbols
; symbols stored by hash - 7-bit hash (128 entries).
hash7:	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0

hshidx:	db	0	; current index into temp list
hshtbl:	dw	0	; pointer to temp symbol list
symptr:	dw	0	; saved pointer into list

L2255:	lxi	h,hash7		;; 2255: 21 50 21    .P.
	mvi	b,256/2		;; 2258: 06 80       ..
	xra	a		;; 225a: af          .
L225b:	mov	m,a		;; 225b: 77          w
	inx	h		;; 225c: 23          #
	mov	m,a		;; 225d: 77          w
	inx	h		;; 225e: 23          #
	dcr	b		;; 225f: 05          .
	jnz	L225b		;; 2260: c2 5b 22    .["
	lxi	h,0		;; 2263: 21 00 00    ...
	shld	cursym		;; 2266: 22 23 35    "#5
	ret			;; 2269: c9          .

; initialize/reset hash4[]
L226a:	lxi	h,hash4		;; 226a: 21 55 33    .U3
	mvi	b,32/2		;; 226d: 06 10       ..
	xra	a		;; 226f: af          .
L2270:	mov	m,a		;; 2270: 77          w
	inx	h		;; 2271: 23          #
	mov	m,a		;; 2272: 77          w
	inx	h		;; 2273: 23          #
	dcr	b		;; 2274: 05          .
	jnz	L2270		;; 2275: c2 70 22    .p"
	ret			;; 2278: c9          .

; move array[0] to array[++L3375], foreach array
; "push"
L2279:	lxi	h,L3375		;; 2279: 21 75 33    .u3
	mov	a,m		;; 227c: 7e          ~
	cpi	15		;; 227d: fe 0f       ..
	jnc	Berro2		;; 227f: d2 10 23    ..#
	inr	m		;; 2282: 34          4
	mov	e,m		;; 2283: 5e          ^
	mvi	d,0		;; 2284: 16 00       ..
	lxi	h,L3376		;; 2286: 21 76 33    .v3
	mov	a,m		;; 2289: 7e          ~
	dad	d		;; 228a: 19          .
	mov	m,a		;; 228b: 77          w
	lxi	h,L33a6		;; 228c: 21 a6 33    ..3
	call	movwrd		;; 228f: cd b7 22    .."
	lxi	h,L3386		;; 2292: 21 86 33    ..3
	call	movwrd		;; 2295: cd b7 22    .."
	lxi	h,L33c6		;; 2298: 21 c6 33    ..3
	call	movwrd		;; 229b: cd b7 22    .."
	lxi	h,L33e8		;; 229e: 21 e8 33    ..3
	mov	a,m		;; 22a1: 7e          ~
	dad	d		;; 22a2: 19          .
	mov	m,a		;; 22a3: 77          w
	lxi	h,L33f8		;; 22a4: 21 f8 33    ..3
	call	movwrd		;; 22a7: cd b7 22    .."
	lxi	h,L3418		;; 22aa: 21 18 34    ..4
	mov	a,m		;; 22ad: 7e          ~
	dad	d		;; 22ae: 19          .
	mov	m,a		;; 22af: 77          w
	lxi	h,L3428		;; 22b0: 21 28 34    .(4
	mov	a,m		;; 22b3: 7e          ~
	dad	d		;; 22b4: 19          .
	mov	m,a		;; 22b5: 77          w
	ret			;; 22b6: c9          .

movwrd:	mov	c,m		;; 22b7: 4e          N
	inx	h		;; 22b8: 23          #
	mov	b,m		;; 22b9: 46          F
	dad	d		;; 22ba: 19          .
	dad	d		;; 22bb: 19          .
	mov	m,b		;; 22bc: 70          p
	dcx	h		;; 22bd: 2b          +
	mov	m,c		;; 22be: 71          q
	ret			;; 22bf: c9          .

; move array[L3375--] to array[0], foreach array
; "pop"
L22c0:	lxi	h,L3375		;; 22c0: 21 75 33    .u3
	mov	a,m		;; 22c3: 7e          ~
	ora	a		;; 22c4: b7          .
	jz	Berro2		;; 22c5: ca 10 23    ..#
	push	h		;; 22c8: e5          .
	mov	e,m		;; 22c9: 5e          ^
	mvi	d,0		;; 22ca: 16 00       ..
	lxi	h,L3376		;; 22cc: 21 76 33    .v3
	call	L22ff		;; 22cf: cd ff 22    .."
	lxi	h,L33a6		;; 22d2: 21 a6 33    ..3
	call	L2305		;; 22d5: cd 05 23    ..#
	lxi	h,L3386		;; 22d8: 21 86 33    ..3
	call	L2305		;; 22db: cd 05 23    ..#
	lxi	h,L33c6		;; 22de: 21 c6 33    ..3
	call	L2305		;; 22e1: cd 05 23    ..#
	lxi	h,L33e8		;; 22e4: 21 e8 33    ..3
	call	L22ff		;; 22e7: cd ff 22    .."
	lxi	h,L33f8		;; 22ea: 21 f8 33    ..3
	call	L2305		;; 22ed: cd 05 23    ..#
	lxi	h,L3418		;; 22f0: 21 18 34    ..4
	call	L22ff		;; 22f3: cd ff 22    .."
	lxi	h,L3428		;; 22f6: 21 28 34    .(4
	call	L22ff		;; 22f9: cd ff 22    .."
	pop	h		;; 22fc: e1          .
	dcr	m		;; 22fd: 35          5
	ret			;; 22fe: c9          .

; move byte
L22ff:	push	h		;; 22ff: e5          .
	dad	d		;; 2300: 19          .
	mov	a,m		;; 2301: 7e          ~
	pop	h		;; 2302: e1          .
	mov	m,a		;; 2303: 77          w
	ret			;; 2304: c9          .

; move word
L2305:	push	h		;; 2305: e5          .
	dad	d		;; 2306: 19          .
	dad	d		;; 2307: 19          .
	mov	c,m		;; 2308: 4e          N
	inx	h		;; 2309: 23          #
	mov	b,m		;; 230a: 46          F
	pop	h		;; 230b: e1          .
	mov	m,c		;; 230c: 71          q
	inx	h		;; 230d: 23          #
	mov	m,b		;; 230e: 70          p
	ret			;; 230f: c9          .

Berro2:	mvi	a,'B'		;; 2310: 3e 42       >B
	jmp	seterr		;; 2312: c3 d5 30    ..0

; compute 7-bit checksum of string in tokbuf.
; checksum stored in hshidx, returned in A.
; checksum a.k.a. hash
tokcks:	lxi	h,tokbuf		;; 2315: 21 c7 34    ..4
	shld	tokptr		;; 2318: 22 c9 25    ".%
ptrcks:	lhld	tokptr		;; 231b: 2a c9 25    *.%
	mov	b,m		;; 231e: 46          F
	xra	a		;; 231f: af          .
L2320:	inx	h		;; 2320: 23          #
	add	m		;; 2321: 86          .
	dcr	b		;; 2322: 05          .
	jnz	L2320		;; 2323: c2 20 23    . #
	ani	07fh		;; 2326: e6 7f       ..
	sta	hshidx		;; 2328: 32 50 22    2P"
	ret			;; 232b: c9          .

; get cursym->len + 1
symlen:	lhld	cursym		;; 232c: 2a 23 35    *#5
	inx	h		;; 232f: 23          #
	inx	h		;; 2330: 23          #
	mov	a,m		;; 2331: 7e          ~
	inr	a		;; 2332: 3c          <
	ret			;; 2333: c9          .

L2334:	call	isNULL		;; 2334: cd 76 23    .v#
	rz			;; 2337: c8          .
	xchg			;; 2338: eb          .
	lxi	b,0		;; 2339: 01 00 00    ...
	lda	L3376		;; 233c: 3a 76 33    :v3
	cpi	001h		;; 233f: fe 01       ..
	jz	L2361		;; 2341: ca 61 23    .a#
	lxi	h,L3375		;; 2344: 21 75 33    .u3
	mov	c,m		;; 2347: 4e          N
	mvi	b,0		;; 2348: 06 00       ..
	lxi	h,L3376		;; 234a: 21 76 33    .v3
	dad	b		;; 234d: 09          .
L234e:	mov	a,c		;; 234e: 79          y
	ora	a		;; 234f: b7          .
	jz	L235e		;; 2350: ca 5e 23    .^#
	mov	a,m		;; 2353: 7e          ~
	cpi	001h		;; 2354: fe 01       ..
	jz	L2361		;; 2356: ca 61 23    .a#
	dcx	b		;; 2359: 0b          .
	dcx	h		;; 235a: 2b          +
	jmp	L234e		;; 235b: c3 4e 23    .N#

L235e:	inr	a		;; 235e: 3c          <
	xchg			;; 235f: eb          .
	ret			;; 2360: c9          .

L2361:	lxi	h,L33f8		;; 2361: 21 f8 33    ..3
	dad	b		;; 2364: 09          .
	dad	b		;; 2365: 09          .
	mov	a,e		;; 2366: 7b          {
	sub	m		;; 2367: 96          .
	mov	a,d		;; 2368: 7a          z
	inx	h		;; 2369: 23          #
	sbb	m		;; 236a: 9e          .
	jc	isNULL		;; 236b: da 76 23    .v#
	lxi	h,0		;; 236e: 21 00 00    ...
	shld	cursym		;; 2371: 22 23 35    "#5
	xra	a		;; 2374: af          .
	ret			;; 2375: c9          .

isNULL:	lhld	cursym		;; 2376: 2a 23 35    *#5
	mov	a,l		;; 2379: 7d          }
	ora	h		;; 237a: b4          .
	ret			;; 237b: c9          .

L237c:	lxi	h,L3513		;; 237c: 21 13 35    ..5
	shld	hshtbl		;; 237f: 22 51 22    "Q"
	xra	a		;; 2382: af          .
	sta	hshidx		;; 2383: 32 50 22    2P"
	jmp	L23ac		;; 2386: c3 ac 23    ..#

; lookup symbol in "local" list (hash4)
look4:	lxi	h,L343a		;; 2389: 21 3a 34    .:4
	shld	tokptr		;; 238c: 22 c9 25    ".%
	call	ptrcks		;; 238f: cd 1b 23    ..#
	lda	hshidx		;; 2392: 3a 50 22    :P"
	ani	00fh		;; 2395: e6 0f       ..
	sta	hshidx		;; 2397: 32 50 22    2P"
	lxi	h,hash4		;; 239a: 21 55 33    .U3
	shld	hshtbl		;; 239d: 22 51 22    "Q"
	jmp	L23b2		;; 23a0: c3 b2 23    ..#

; lookup symbol using hash (7-bit checksum).
; this is the main set of all symbols.
look7:	call	tokcks		;; 23a3: cd 15 23    ..#
	lxi	h,hash7		;; 23a6: 21 50 21    .P.
	shld	hshtbl		;; 23a9: 22 51 22    "Q"
L23ac:	lxi	h,tokbuf	;; 23ac: 21 c7 34    ..4
	shld	tokptr		;; 23af: 22 c9 25    ".%
L23b2:	lhld	tokptr		;; 23b2: 2a c9 25    *.%
	mov	a,m		;; 23b5: 7e          ~
	cpi	17		;; 23b6: fe 11       ..
	jc	L23bd		;; 23b8: da bd 23    ..#
	mvi	m,16		;; 23bb: 36 10       6.
L23bd:	lxi	h,hshidx	;; 23bd: 21 50 22    .P"
	mov	e,m		;; 23c0: 5e          ^
	mvi	d,0		;; 23c1: 16 00       ..
	lhld	hshtbl		;; 23c3: 2a 51 22    *Q"
	dad	d		;; 23c6: 19          .
	dad	d		;; 23c7: 19          .
	mov	e,m		;; 23c8: 5e          ^
	inx	h		;; 23c9: 23          #
	mov	h,m		;; 23ca: 66          f
	mov	l,e		;; 23cb: 6b          k
	; start at head of hash chain
L23cc:	shld	cursym		;; 23cc: 22 23 35    "#5
	call	isNULL		;; 23cf: cd 76 23    .v#
	rz			;; 23d2: c8          .
	call	symlen		;; 23d3: cd 2c 23    .,#
	lhld	tokptr		;; 23d6: 2a c9 25    *.%
	cmp	m		;; 23d9: be          .
	jnz	L23f6		;; 23da: c2 f6 23    ..#
	mov	b,a		;; 23dd: 47          G
	inx	h		;; 23de: 23          #
	xchg			;; 23df: eb          .
	lhld	cursym		;; 23e0: 2a 23 35    *#5
	inx	h		;; 23e3: 23          #
	inx	h		;; 23e4: 23          #
	inx	h		;; 23e5: 23          #
	inx	h		;; 23e6: 23          #
L23e7:	ldax	d		;; 23e7: 1a          .
	call	touppr		;; 23e8: cd 44 28    .D(
	cmp	m		;; 23eb: be          .
	jnz	L23f6		;; 23ec: c2 f6 23    ..#
	inx	d		;; 23ef: 13          .
	inx	h		;; 23f0: 23          #
	dcr	b		;; 23f1: 05          .
	jnz	L23e7		;; 23f2: c2 e7 23    ..#
	ret			;; 23f5: c9          .

; cursym = cursym->next
L23f6:	lhld	cursym		;; 23f6: 2a 23 35    *#5
	mov	e,m		;; 23f9: 5e          ^
	inx	h		;; 23fa: 23          #
	mov	d,m		;; 23fb: 56          V
	xchg			;; 23fc: eb          .
	jmp	L23cc		;; 23fd: c3 cc 23    ..#

; create symbol from tokbuf
; already known to not exist in hash7.
newsym:	lxi	h,tokbuf		;; 2400: 21 c7 34    ..4
	mov	e,m		;; 2403: 5e          ^
	mvi	d,0		;; 2404: 16 00       ..
	; cursym = alloc(sizeof(struct symbol) + tokbuf[0]);
	lhld	nxheap		;; 2406: 2a 0f 35    *.5
	shld	cursym		;; 2409: 22 23 35    "#5
	dad	d		;; 240c: 19          .
	lxi	d,6		;; 240d: 11 06 00    ...
	dad	d		;; 2410: 19          .
	xchg			;; 2411: eb          .
	; check for out of memory...
	lhld	memtop		;; 2412: 2a 11 35    *.5
	mov	a,e		;; 2415: 7b          {
	sub	l		;; 2416: 95          .
	mov	a,d		;; 2417: 7a          z
	sbb	h		;; 2418: 9c          .
	xchg			;; 2419: eb          .
	jnc	L24f7		;; 241a: d2 f7 24    ..$
	; allocated...
	shld	nxheap		;; 241d: 22 0f 35    ".5
	lxi	h,hash7		;; 2420: 21 50 21    .P.
	shld	hshtbl		;; 2423: 22 51 22    "Q"
	call	symini		;; 2426: cd 2f 24    ./$
	xra	a		;; 2429: af          .
	inx	h		;; 242a: 23          #
	mov	m,a		;; 242b: 77          w
	inx	h		;; 242c: 23          #
	mov	m,a		;; 242d: 77          w
	ret			;; 242e: c9          .

; add cursym to (hshtbl)[hshidx], initialize it.
; already known to not exist there.
symini:	lhld	cursym		;; 242f: 2a 23 35    *#5
	xchg			;; 2432: eb          .
	lxi	h,hshidx	;; 2433: 21 50 22    .P"
	mov	c,m		;; 2436: 4e          N
	mvi	b,0		;; 2437: 06 00       ..
	lhld	hshtbl		;; 2439: 2a 51 22    *Q"
	dad	b		;; 243c: 09          .
	dad	b		;; 243d: 09          .
	shld	symptr		;; 243e: 22 53 22    "S"
	mov	c,m		;; 2441: 4e          N
	inx	h		;; 2442: 23          #
	mov	b,m		;; 2443: 46          F
	; BC = hshtbl[hash]
	mov	m,d		;; 2444: 72          r
	dcx	h		;; 2445: 2b          +
	mov	m,e		;; 2446: 73          s
	; hshtbl[hash] = cursym
	xchg			;; 2447: eb          .
	mov	m,c		;; 2448: 71          q
	inx	h		;; 2449: 23          #
	mov	m,b		;; 244a: 70          p
	; cursym->next = BC
	; copy tokbuf into cursym->name
	; cursym->len = tokbuf[0] - 1
	; cursym->type = 0
	lxi	d,tokbuf	;; 244b: 11 c7 34    ..4
	ldax	d		;; 244e: 1a          .
	cpi	17		;; 244f: fe 11       ..
	jc	L2456		;; 2451: da 56 24    .V$
	mvi	a,16		;; 2454: 3e 10       >.
L2456:	mov	b,a		;; 2456: 47          G
	dcr	a		;; 2457: 3d          =
	inx	h		;; 2458: 23          #
	mov	m,a		;; 2459: 77          w
	inx	h		;; 245a: 23          #
	mvi	m,0		;; 245b: 36 00       6.
L245d:	inx	h		;; 245d: 23          #
	inx	d		;; 245e: 13          .
	ldax	d		;; 245f: 1a          .
	mov	m,a		;; 2460: 77          w
	dcr	b		;; 2461: 05          .
	jnz	L245d		;; 2462: c2 5d 24    .]$
	ret			;; 2465: c9          .

; "push" tokbuf string onto memtop "stack",
; phase I: alloc space and check overflow.
; cursym points to space.
; memtop -= <length>
L2466:	lhld	memtop		;; 2466: 2a 11 35    *.5
	xchg			;; 2469: eb          .
	lxi	h,tokbuf	;; 246a: 21 c7 34    ..4
	mov	l,m		;; 246d: 6e          n
	mvi	h,0		;; 246e: 26 00       &.
	dad	b		;; 2470: 09          .
	; hl = length(tokbuf) + bc
	mov	a,e		;; 2471: 7b          {
	sub	l		;; 2472: 95          .
	mov	l,a		;; 2473: 6f          o
	mov	a,d		;; 2474: 7a          z
	sbb	h		;; 2475: 9c          .
	mov	h,a		;; 2476: 67          g
	shld	cursym		;; 2477: 22 23 35    "#5
	; cursym = memtop - (length(tokbuf) + bc)
	xchg			;; 247a: eb          .
	; make certain memtop does not collide with nxheap
	lxi	h,nxheap	;; 247b: 21 0f 35    ..5
	mov	a,e		;; 247e: 7b          {
	sub	m		;; 247f: 96          .
	inx	h		;; 2480: 23          #
	mov	a,d		;; 2481: 7a          z
	sbb	m		;; 2482: 9e          .
	jc	L24f7		;; 2483: da f7 24    ..$
	xchg			;; 2486: eb          .
	shld	memtop		;; 2487: 22 11 35    ".5
	ret			;; 248a: c9          .

; create temp string (off memtop) from tokbuf.
; cursym = strdup(tokbuf)
strdup:	lxi	b,1		;; 248b: 01 01 00    ...
	call	L2466		;; 248e: cd 66 24    .f$
	lhld	memtop		;; 2491: 2a 11 35    *.5
	xchg			;; 2494: eb          .
	lxi	h,tokbuf	;; 2495: 21 c7 34    ..4
	mov	c,m		;; 2498: 4e          N
L2499:	inx	h		;; 2499: 23          #
	mov	a,c		;; 249a: 79          y
	ora	a		;; 249b: b7          .
	jz	L24a6		;; 249c: ca a6 24    ..$
	dcr	c		;; 249f: 0d          .
	mov	a,m		;; 24a0: 7e          ~
	stax	d		;; 24a1: 12          .
	inx	d		;; 24a2: 13          .
	jmp	L2499		;; 24a3: c3 99 24    ..$

L24a6:	xra	a		;; 24a6: af          .
	stax	d		;; 24a7: 12          .
	ret			;; 24a8: c9          .

symdup:	lxi	b,4		;; 24a9: 01 04 00    ...
	call	L2466		;; 24ac: cd 66 24    .f$
	lxi	h,hash4		;; 24af: 21 55 33    .U3
	shld	hshtbl		;; 24b2: 22 51 22    "Q"
	call	symini		;; 24b5: cd 2f 24    ./$
	lda	hshidx		;; 24b8: 3a 50 22    :P"
	call	settyp		;; 24bb: cd 16 25    ..%
	ret			;; 24be: c9          .

L24bf:	lhld	memtop		;; 24bf: 2a 11 35    *.5
	xchg			;; 24c2: eb          .
	lxi	h,L33f8		;; 24c3: 21 f8 33    ..3
	mov	a,e		;; 24c6: 7b          {
	sub	m		;; 24c7: 96          .
	inx	h		;; 24c8: 23          #
	mov	a,d		;; 24c9: 7a          z
	sbb	m		;; 24ca: 9e          .
	rnc			;; 24cb: d0          .
	xchg			;; 24cc: eb          .
	shld	cursym		;; 24cd: 22 23 35    "#5
	call	symtyp		;; 24d0: cd 1e 25    ..%
	mov	e,a		;; 24d3: 5f          _
	mvi	d,0		;; 24d4: 16 00       ..
	lxi	h,hash4		;; 24d6: 21 55 33    .U3
	dad	d		;; 24d9: 19          .
	dad	d		;; 24da: 19          .
	xchg			;; 24db: eb          .
	; set hash4[type] = cursym->next
	lhld	cursym		;; 24dc: 2a 23 35    *#5
	mov	a,m		;; 24df: 7e          ~
	stax	d		;; 24e0: 12          .
	inx	h		;; 24e1: 23          #
	mov	a,m		;; 24e2: 7e          ~
	inx	d		;; 24e3: 13          .
	stax	d		;; 24e4: 12          .
	call	symadr		;; 24e5: cd 26 25    .&%
L24e8:	mov	a,m		;; 24e8: 7e          ~
	ora	a		;; 24e9: b7          .
	inx	h		;; 24ea: 23          #
	jnz	L24e8		;; 24eb: c2 e8 24    ..$
	shld	memtop		;; 24ee: 22 11 35    ".5
	jmp	L24bf		;; 24f1: c3 bf 24    ..$

symval:	jmp	symadr		;; 24f4: c3 26 25    .&%

L24f7:	lxi	h,L2500		;; 24f7: 21 00 25    ..%
	call	msgcr		;; 24fa: cd ea 2a    ..*
	jmp	relfin		;; 24fd: c3 41 31    .A1

L2500:	db	'SYMBOL TABLE OVERFLOW',0dh

; set value of cursym->type
settyp:	lhld	cursym		;; 2516: 2a 23 35    *#5
	inx	h		;; 2519: 23          #
	inx	h		;; 251a: 23          #
	inx	h		;; 251b: 23          #
	mov	m,a		;; 251c: 77          w
	ret			;; 251d: c9          .

; get value of cursym->type
symtyp:	lhld	cursym		;; 251e: 2a 23 35    *#5
	inx	h		;; 2521: 23          #
	inx	h		;; 2522: 23          #
	inx	h		;; 2523: 23          #
	mov	a,m		;; 2524: 7e          ~
	ret			;; 2525: c9          .

; return &cursym->addr
symadr:	call	symlen		;; 2526: cd 2c 23    .,#
	lhld	cursym		;; 2529: 2a 23 35    *#5
	mov	e,a		;; 252c: 5f          _
	mvi	d,0		;; 252d: 16 00       ..
	dad	d		;; 252f: 19          .
	inx	h		;; 2530: 23          #
	inx	h		;; 2531: 23          #
	inx	h		;; 2532: 23          #
	inx	h		;; 2533: 23          #
	ret			;; 2534: c9          .

; set cursym->addr to HL
putval:	push	h		;; 2535: e5          .
	call	symadr		;; 2536: cd 26 25    .&%
	pop	d		;; 2539: d1          .
	mov	m,e		;; 253a: 73          s
	inx	h		;; 253b: 23          #
	mov	m,d		;; 253c: 72          r
	ret			;; 253d: c9          .

; return cursym->addr
getval:	call	symadr		;; 253e: cd 26 25    .&%
	mov	e,m		;; 2541: 5e          ^
	inx	h		;; 2542: 23          #
	mov	d,m		;; 2543: 56          V
	xchg			;; 2544: eb          .
	ret			;; 2545: c9          .

; set tmpptr = cursym + sizeof(struct symbol)
; point to macro definition extension.
symend:	call	symadr		;; 2546: cd 26 25    .&%
	inx	h		;; 2549: 23          #
	inx	h		;; 254a: 23          #
	shld	tmpptr		;; 254b: 22 25 35    "%5
	ret			;; 254e: c9          .

; set the macro def param count
setmpc:	push	psw		;; 254f: f5          .
	call	symend		;; 2550: cd 46 25    .F%
	pop	psw		;; 2553: f1          .
	mov	m,a		;; 2554: 77          w
	ret			;; 2555: c9          .

; macro def parameter count
macpct:	call	symend		;; 2556: cd 46 25    .F%
	mov	a,m		;; 2559: 7e          ~
	ret			;; 255a: c9          .

; copy name out of tokbuf into tmpptr (&symbol->len).
; truncate tokbuf to 16 characters.
; tokbuf: <len> <char>...
; dest:   <len-1> <hash4> <char>...
putstr:	call	tokcks		;; 255b: cd 15 23    ..#
	ani	00fh		;; 255e: e6 0f       ..
	push	psw		;; 2560: f5          .
	lxi	h,tokbuf	;; 2561: 21 c7 34    ..4
	mov	a,m		;; 2564: 7e          ~
	cpi	17		;; 2565: fe 11       ..
	jc	L256c		;; 2567: da 6c 25    .l%
	mvi	m,16		;; 256a: 36 10       6.
L256c:	mov	a,m		;; 256c: 7e          ~
	dcr	a		;; 256d: 3d          =
	call	puttmp		;; 256e: cd ab 25    ..%
	pop	psw		;; 2571: f1          .
	call	puttmp		;; 2572: cd ab 25    ..%
	lxi	h,tokbuf	;; 2575: 21 c7 34    ..4
	mov	c,m		;; 2578: 4e          N
L2579:	inx	h		;; 2579: 23          #
	mov	a,m		;; 257a: 7e          ~
	push	b		;; 257b: c5          .
	push	h		;; 257c: e5          .
	call	puttmp		;; 257d: cd ab 25    ..%
	pop	h		;; 2580: e1          .
	pop	b		;; 2581: c1          .
	dcr	c		;; 2582: 0d          .
	jnz	L2579		;; 2583: c2 79 25    .y%
	ret			;; 2586: c9          .

; copy name out of tmpptr (&symbol->len) into tokbuf.
; also saves symbol->type to hshidx.
; source: <len-1> <hash4> <char>...
; tokbuf: <len> <char>... ; hshidx=<hash4>
getstr:	call	gettmp		;; 2587: cd a2 25    ..%
	push	psw		;; 258a: f5          .
	call	gettmp		;; 258b: cd a2 25    ..%
	sta	hshidx		;; 258e: 32 50 22    2P"
	pop	psw		;; 2591: f1          .
	inr	a		;; 2592: 3c          <
	mov	c,a		;; 2593: 4f          O
	lxi	d,tokbuf	;; 2594: 11 c7 34    ..4
	stax	d		;; 2597: 12          .
L2598:	call	gettmp		;; 2598: cd a2 25    ..%
	inx	d		;; 259b: 13          .
	stax	d		;; 259c: 12          .
	dcr	c		;; 259d: 0d          .
	jnz	L2598		;; 259e: c2 98 25    ..%
	ret			;; 25a1: c9          .

; get next byte from tmpptr (A = *++tmpptr)
gettmp:	lhld	tmpptr		;; 25a2: 2a 25 35    *%5
	inx	h		;; 25a5: 23          #
	shld	tmpptr		;; 25a6: 22 25 35    "%5
	mov	a,m		;; 25a9: 7e          ~
	ret			;; 25aa: c9          .

; put byte to next tmpptr (*++tmpptr = toupper(A))
; also resets nxheap = tmpptr + 1
puttmp:	mov	c,a		;; 25ab: 4f          O
	lhld	tmpptr		;; 25ac: 2a 25 35    *%5
	inx	h		;; 25af: 23          #
	xchg			;; 25b0: eb          .
	lhld	memtop		;; 25b1: 2a 11 35    *.5
	mov	a,e		;; 25b4: 7b          {
	sub	l		;; 25b5: 95          .
	mov	a,d		;; 25b6: 7a          z
	sbb	h		;; 25b7: 9c          .
	jnc	L24f7		;; 25b8: d2 f7 24    ..$
	xchg			;; 25bb: eb          .
	shld	tmpptr		;; 25bc: 22 25 35    "%5
	mov	a,c		;; 25bf: 79          y
	call	touppr		;; 25c0: cd 44 28    .D(
	mov	m,a		;; 25c3: 77          w
	inx	h		;; 25c4: 23          #
	shld	nxheap		;; 25c5: 22 0f 35    ".5
	ret			;; 25c8: c9          .

; Module begin L2100 - parser (assembler)

tokptr:	dw	0
L25cb:	db	0

L25cc:	dw	tok1	; 1-char tokens
	dw	tok2	; 2-char tokens
	dw	tok3	; 3-char tokens
	dw	tok4	; 4-char tokens
	dw	tok5	; 5-char tokens
	dw	tok6	; 6-char tokens

	dw	L2744

L25da:	dw	L274a	; 1-char token flags
	dw	L276a	; 2-char token flags
	dw	L2788	; 3-char token flags
	dw	L27f6	; 4-char token flags
	dw	L281e	; 5-char token flags
	dw	L282c	; 6-char token flags

tok1:	db	cr,'(',')','*','+',',','-','/','A','B','C','D','E','H','L','M'
num1	equ	($-tok1)

tok2:	db	'DB','DI','DS','DW','EI','EQ','GE','GT','IF','IN','LE','LT','NE','OR','SP'
num2	equ	($-tok2)/2

tok3:	db	'ACI','ADC','ADD','ADI','ANA','AND','ANI','CMA','CMC'
	db	'CMP','CPI','DAA','DAD','DCR','DCX','END','EQU','HLT','INR'
	db	'INX','IRP','JMP','LDA','LOW','LXI','MOD','MOV','MVI','NOP'
	db	'NOT','NUL','ORA','ORG','ORI','OUT','POP','PSW','RAL','RAR'
	db	'RET','RLC','RRC','RST','SBB','SBI','SET','SHL','SHR','STA'
	db	'STC','SUB','SUI','XOR','XRA','XRI'
num3	equ	($-tok3)/3

tok4:	db	'ASEG','CALL','CSEG','DSEG','ELSE','ENDM','HIGH','IRPC','LDAX','LHLD'
	db	'NAME','PAGE','PCHL','PUSH','REPT','SHLD','SPHL','STAX','XCHG','XTHL'
num4	equ	($-tok4)/4

tok5:	db	'ENDIF','EXITM','EXTRN','LOCAL'
	db	'MACRO','STKLN','TITLE'
num5	equ	($-tok5)/5

tok6:	db	'COMMON','INPAGE','MACLIB','PUBLIC'
num6	equ	($-tok6)/6

L2744:	db	num1
L2745:	db	num2,num3,num4,num5,num6

; token flags (and opcode base)
L274a:	db	17h,0ah		; CR
	db	14h,14h		; l-paren
	db	15h,1eh		; r-paren
	db	0,50h		; asterisk
	db	5,46h		; plus
	db	16h,0ah		; comma
	db	6,46h		; minus
	db	1,50h		; slash
	db	19h,7		; 'A'
	db	19h,0		; 'B'
	db	19h,1		; 'C'
	db	19h,2		; 'D'
	db	19h,3		; 'E'
	db	19h,4		; 'H'
	db	19h,5		; 'L'
	db	19h,6		; 'M'

L276a:	db	1ah,1		; DB
	db	1ch,0f3h	; DI
	db	1ah,2		; DS
	db	1ah,3		; DW
	db	1ch,0fbh	; EI
	db	8,41h		; EQ
	db	0ch,41h		; GE
	db	0bh,41h		; GT
	db	1ah,8		; IF
	db	2ah,0dbh	; IN
	db	0ah,41h		; LE
	db	9,41h		; LT
	db	0dh,41h		; NE
	db	10h,28h		; OR
	db	19h,6		; SP

L2788:	db	23h,0ceh	; ACI
	db	26h,88h		; ADC
	db	26h,80h		; ADD
	db	23h,0c6h	; ADI
	db	26h,0a0h	; ANA
	db	0fh,32h		; AND
	db	23h,0e6h	; ANI
	db	1ch,2fh		; CMA
	db	1ch,3fh		; CMC
	db	26h,0b8h	; CMP
	db	23h,0feh	; CPI
	db	1ch,27h		; DAA
	db	1eh,9		; DAD
	db	27h,5		; DCR
	db	28h,0bh		; DCX
	db	1ah,4		; END
	db	1ah,7		; EQU
	db	1ch,76h		; HLT
	db	27h,4		; INR
	db	28h,3		; INX
	db	1ah,0eh		; IRP
	db	20h,0c3h	; JMP
	db	25h,3ah		; LDA
	db	13h,1eh		; LOW
	db	1dh,1		; LXI
	db	2,50h		; MOD
	db	21h,40h		; MOV
	db	22h,6		; MVI
	db	1ch,0		; NOP
	db	0eh,3ch		; NOT
	db	18h,0		; NUL
	db	26h,0b0h	; ORA
	db	1ah,0ah		; ORG
	db	23h,0f6h	; ORI
	db	2ah,0d3h	; OUT
	db	1fh,0c1h	; POP
	db	19h,6		; PSW
	db	1ch,17h		; RAL
	db	1ch,1fh		; RAR
	db	1ch,0c9h	; RET
	db	1ch,7		; RLC
	db	1ch,0fh		; RRC
	db	29h,0c7h	; RST
	db	26h,98h		; SBB
	db	23h,0deh	; SBI
	db	1ah,0bh		; SET
	db	3,50h		; SHL
	db	4,50h		; SHR
	db	25h,32h		; STA
	db	1ch,37h		; STC
	db	26h,90h		; SUB
	db	23h,0d6h	; SUI
	db	11h,28h		; XOR
	db	26h,0a8h	; XRA
	db	23h,0eeh	; XRI

L27f6:	db	1ah,11h		; ASEG
	db	20h,0cdh	; CALL
	db	1ah,12h		; CSEG
	db	1ah,13h		; DSEG
	db	1ah,0dh		; ELSE
	db	1ah,6		; ENDM
	db	12h,1eh		; HIGH
	db	1ah,0fh		; IRPC
	db	24h,0ah		; LDAX
	db	25h,2ah		; LHLD
	db	1ah,14h		; NAME
	db	1ah,15h		; PAGE
	db	1ch,0e9h	; PCHL
	db	1fh,0c5h	; PUSH
	db	1ah,10h		; REPT
	db	25h,22h		; SHLD
	db	1ch,0f9h	; SPHL
	db	24h,2		; STAX
	db	1ch,0ebh	; XCHG
	db	1ch,0e3h	; XTHL

L281e:	db	1ah,5		; ENDIF
	db	1ah,16h		; EXITM
	db	1ah,17h		; EXTRN
	db	1ah,18h		; LOCAL
	db	1ah,9		; MACRO
	db	1ah,1ch		; STKLN
	db	1ah,0ch		; TITLE

L282c:	db	1ah,1dh		; COMMON
	db	1ah,19h		; INPAGE
	db	1ah,1ah		; MACLIB
	db	1ah,1bh		; PUBLIC

; J(MP), R(ET), C(ALL) condition codes
L2834:	db	'NZ','Z ','NC','C ','PO','PE','P ','M '

touppr:	cpi	'a'		;; 2844: fe 61       .a
	rc			;; 2846: d8          .
	cpi	'z'+1		;; 2847: fe 7b       .{
	rnc			;; 2849: d0          .
	ani	0dfh		;; 284a: e6 df       ..
	ret			;; 284c: c9          .

; search for token in list, based on length. list is sorted.
; D=token length (1-6), HL=token list (for length), B=num in list
; returns
L284d:	mvi	e,0ffh		;; 284d: 1e ff       ..
	inr	b		;; 284f: 04          .
	mvi	c,0		;; 2850: 0e 00       ..
L2852:	xra	a		;; 2852: af          .
	mov	a,b		;; 2853: 78          x
	add	c		;; 2854: 81          .
	rar			;; 2855: 1f          .
	cmp	e		;; 2856: bb          .
	jz	L2891		;; 2857: ca 91 28    ..(
	mov	e,a		;; 285a: 5f          _
	push	h		;; 285b: e5          .
	push	d		;; 285c: d5          .
	push	b		;; 285d: c5          .
	push	h		;; 285e: e5          .
	mov	b,d		;; 285f: 42          B
	mov	c,b		;; 2860: 48          H
	mvi	d,0		;; 2861: 16 00       ..
	lxi	h,0		;; 2863: 21 00 00    ...
L2866:	dad	d		;; 2866: 19          .
	dcr	b		;; 2867: 05          .
	jnz	L2866		;; 2868: c2 66 28    .f(
	pop	d		;; 286b: d1          .
	dad	d		;; 286c: 19          .
	lxi	d,tokbuf+1	;; 286d: 11 c8 34    ..4
L2870:	ldax	d		;; 2870: 1a          .
	call	touppr		;; 2871: cd 44 28    .D(
	cmp	m		;; 2874: be          .
	inx	d		;; 2875: 13          .
	inx	h		;; 2876: 23          #
	jnz	L2883		;; 2877: c2 83 28    ..(
	dcr	c		;; 287a: 0d          .
	jnz	L2870		;; 287b: c2 70 28    .p(
	pop	b		;; 287e: c1          .
	pop	d		;; 287f: d1          .
	pop	h		;; 2880: e1          .
	mov	a,e		;; 2881: 7b          {
	ret			;; 2882: c9          .

L2883:	pop	b		;; 2883: c1          .
	pop	d		;; 2884: d1          .
	pop	h		;; 2885: e1          .
	jc	L288d		;; 2886: da 8d 28    ..(
	mov	c,e		;; 2889: 4b          K
	jmp	L2852		;; 288a: c3 52 28    .R(

L288d:	mov	b,e		;; 288d: 43          C
	jmp	L2852		;; 288e: c3 52 28    .R(

L2891:	xra	a		;; 2891: af          .
	inr	a		;; 2892: 3c          <
	ret			;; 2893: c9          .

; parse conditional jump, call, or return
L2894:	lda	tokbuf+1	;; 2894: 3a c8 34    :.4
	lxi	b,0c220h	;; 2897: 01 20 c2    . .
	cpi	'J'		;; 289a: fe 4a       .J
	rz			;; 289c: c8          .
	mvi	b,0c4h		;; 289d: 06 c4       ..
	cpi	'C'		;; 289f: fe 43       .C
	rz			;; 28a1: c8          .
	lxi	b,0c01ch	;; 28a2: 01 1c c0    ...
	cpi	'R'		;; 28a5: fe 52       .R
	ret			;; 28a7: c9          .

; parse condition code (Jcc/Ccc/Rcc).
L28a8:	lda	tokbuf		;; 28a8: 3a c7 34    :.4
	cpi	004h		;; 28ab: fe 04       ..
	jnc	L28da		;; 28ad: d2 da 28    ..(
	cpi	003h		;; 28b0: fe 03       ..
	jz	L28bf		;; 28b2: ca bf 28    ..(
	cpi	002h		;; 28b5: fe 02       ..
	jnz	L28da		;; 28b7: c2 da 28    ..(
	lxi	h,tokbuf+3	;; 28ba: 21 ca 34    ..4
	mvi	m,' '		;; 28bd: 36 20       6 
L28bf:	lxi	b,8		;; 28bf: 01 08 00    ...
	lxi	d,L2834		;; 28c2: 11 34 28    .4(
L28c5:	lxi	h,tokbuf+2	;; 28c5: 21 c9 34    ..4
	ldax	d		;; 28c8: 1a          .
	cmp	m		;; 28c9: be          .
	inx	d		;; 28ca: 13          .
	jnz	L28d2		;; 28cb: c2 d2 28    ..(
	ldax	d		;; 28ce: 1a          .
	inx	h		;; 28cf: 23          #
	cmp	m		;; 28d0: be          .
	rz			;; 28d1: c8          .
L28d2:	inx	d		;; 28d2: 13          .
	inr	b		;; 28d3: 04          .
	dcr	c		;; 28d4: 0d          .
	jnz	L28c5		;; 28d5: c2 c5 28    ..(
	inr	c		;; 28d8: 0c          .
	ret			;; 28d9: c9          .

L28da:	xra	a		;; 28da: af          .
	inr	a		;; 28db: 3c          <
	ret			;; 28dc: c9          .

; parse current token, return "flags" bytes in B, A.
; returns NZ if no match found.
keywrd:	lda	tokbuf		;; 28dd: 3a c7 34    :.4
	mov	c,a		;; 28e0: 4f          O
	dcr	a		;; 28e1: 3d          =
	mov	e,a		;; 28e2: 5f          _
	mvi	d,0		;; 28e3: 16 00       ..
	push	d		;; 28e5: d5          .
	cpi	6		;; 28e6: fe 06       ..
	jnc	L292e		;; 28e8: d2 2e 29    ..)
	lxi	h,L2744		;; 28eb: 21 44 27    .D'
	dad	d		;; 28ee: 19          .
	mov	b,m		;; 28ef: 46          F
	lxi	h,L25cc		;; 28f0: 21 cc 25    ..%
	dad	d		;; 28f3: 19          .
	dad	d		;; 28f4: 19          .
	mov	d,m		;; 28f5: 56          V
	inx	h		;; 28f6: 23          #
	mov	h,m		;; 28f7: 66          f
	mov	l,d		;; 28f8: 6a          j
	mov	d,c		;; 28f9: 51          Q
	call	L284d		;; 28fa: cd 4d 28    .M(
	jnz	L2917		;; 28fd: c2 17 29    ..)
	sta	L25cb		;; 2900: 32 cb 25    2.%
	pop	d		;; 2903: d1          .
	lxi	h,L25da		;; 2904: 21 da 25    ..%
	dad	d		;; 2907: 19          .
	dad	d		;; 2908: 19          .
	mov	e,m		;; 2909: 5e          ^
	inx	h		;; 290a: 23          #
	mov	d,m		;; 290b: 56          V
	mov	l,a		;; 290c: 6f          o
	mvi	h,0		;; 290d: 26 00       &.
	dad	h		;; 290f: 29          )
	dad	d		;; 2910: 19          .
	xra	a		;; 2911: af          .
	mov	c,a		;; 2912: 4f          O
	mov	a,m		;; 2913: 7e          ~
	inx	h		;; 2914: 23          #
	mov	b,m		;; 2915: 46          F
	ret			;; 2916: c9          .

; check for Jcc, Ccc, Rcc...
L2917:	pop	d		;; 2917: d1          .
	call	L2894	; parse Jcc/Ccc/Rcc
	rnz		; no match
	push	b		;; 291c: c5          .
	call	L28a8	; parse cc
	mov	a,b		;; 2920: 78          x
	pop	b		;; 2921: c1          .
	rnz		; not a valid cc
	ora	a		;; 2923: b7          .
	ral			;; 2924: 17          .
	ral			;; 2925: 17          .
	ral			;; 2926: 17          .
	ora	b		;; 2927: b0          .
	mov	b,a	; B=merged cc/opcode
	mov	a,c	; C={20h (Jcc/Ccc), 1ch (Rcc)}
	cmp	a	; force ZR status
	mvi	c,001h		;; 292b: 0e 01       ..
	ret			;; 292d: c9          .

L292e:	pop	d		;; 292e: d1          .
	xra	a		;; 292f: af          .
	inr	a		;; 2930: 3c          <
	ret			;; 2931: c9          .

L2932:	lxi	h,tokbuf	;; 2932: 21 c7 34    ..4
	mov	c,m		;; 2935: 4e          N
	dcr	c		;; 2936: 0d          .
	lxi	h,L2745		;; 2937: 21 45 27    .E'
	xra	a		;; 293a: af          .
L293b:	dcr	c		;; 293b: 0d          .
	jz	L2944		;; 293c: ca 44 29    .D)
	add	m		;; 293f: 86          .
	inx	h		;; 2940: 23          #
	jmp	L293b		;; 2941: c3 3b 29    .;)

L2944:	lxi	h,L25cb		;; 2944: 21 cb 25    ..%
	add	m		;; 2947: 86          .
	ori	080h		;; 2948: f6 80       ..
	ret			;; 294a: c9          .

L294b:	ani	07fh		;; 294b: e6 7f       ..
	lxi	h,L2969		;; 294d: 21 69 29    .i)
	mov	e,a		;; 2950: 5f          _
	mvi	d,0		;; 2951: 16 00       ..
	dad	d		;; 2953: 19          .
	dad	d		;; 2954: 19          .
	mov	e,m		;; 2955: 5e          ^
	inx	h		;; 2956: 23          #
	mov	a,m		;; 2957: 7e          ~
	rar			;; 2958: 1f          .
	rar			;; 2959: 1f          .
	rar			;; 295a: 1f          .
	rar			;; 295b: 1f          .
	ani	00fh		;; 295c: e6 0f       ..
	mov	b,a		;; 295e: 47          G
	mov	a,m		;; 295f: 7e          ~
	ani	00fh		;; 2960: e6 0f       ..
	mov	d,a		;; 2962: 57          W
	lxi	h,tok2		;; 2963: 21 f6 25    ..%
	dad	d		;; 2966: 19          .
	mov	a,b		;; 2967: 78          x
	ret			;; 2968: c9          .

; length and offset of each token, relative to tok2
L2969:	dw	2000h	; 0
	dw	2002h	; 1
	dw	2004h	; 2
	dw	2006h	; 3
	dw	2008h	; 4
	dw	200ah	; 5
	dw	200ch	; 6
	dw	200eh	; 7
	dw	2010h	; 8
	dw	2012h	; 9
	dw	2014h	; 10
	dw	2016h	; 11
	dw	2018h	; 12
	dw	201ah	; 13
	dw	201ch	; 14
	dw	301eh	; 15
	dw	3021h	; 16
	dw	3024h	; 17
	dw	3027h	; 18
	dw	302ah	; 19
	dw	302dh	; 20
	dw	3030h	; 21
	dw	3033h	; 22
	dw	3036h	; 23
	dw	3039h	; 24
	dw	303ch	; 25
	dw	303fh	; 26
	dw	3042h	; 27
	dw	3045h	; 28
	dw	3048h	; 29
	dw	304bh	; 30
	dw	304eh	; 31
	dw	3051h	; 32
	dw	3054h	; 33
	dw	3057h	; 34
	dw	305ah	; 35
	dw	305dh	; 36
	dw	3060h	; 37
	dw	3063h	; 38
	dw	3066h	; 39
	dw	3069h	; 40
	dw	306ch	; 41
	dw	306fh	; 42
	dw	3072h	; 43
	dw	3075h	; 44
	dw	3078h	; 45
	dw	307bh	; 46
	dw	307eh	; 47
	dw	3081h	; 48
	dw	3084h	; 49
	dw	3087h	; 50
	dw	308ah	; 51
	dw	308dh	; 52
	dw	3090h	; 53
	dw	3093h	; 54
	dw	3096h	; 55
	dw	3099h	; 56
	dw	309ch	; 57
	dw	309fh	; 58
	dw	30a2h	; 59
	dw	30a5h	; 60
	dw	30a8h	; 61
	dw	30abh	; 62
	dw	30aeh	; 63
	dw	30b1h	; 64
	dw	30b4h	; 65
	dw	30b7h	; 66
	dw	30bah	; 67
	dw	30bdh	; 68
	dw	30c0h	; 69
	dw	40c3h	; 70
	dw	40c7h	; 71
	dw	40cbh	; 72
	dw	40cfh	; 73
	dw	40d3h	; 74
	dw	40d7h	; 75
	dw	40dbh	; 76
	dw	40dfh	; 77
	dw	40e3h	; 78
	dw	40e7h	; 79
	dw	40ebh	; 80
	dw	40efh	; 81
	dw	40f3h	; 82
	dw	40f7h	; 83
	dw	40fbh	; 84
	dw	40ffh	; 85
	dw	4103h	; 86
	dw	4107h	; 87
	dw	410bh	; 88
	dw	410fh	; 89
	dw	5113h	; 90
	dw	5118h	; 91
	dw	511dh	; 92
	dw	5122h	; 93
	dw	5127h	; 94
	dw	512ch	; 95
	dw	5131h	; 96
	dw	6136h	; 97
	dw	613ch	; 98
	dw	6142h	; 99
	dw	6148h	; 100

; Module start L2580 - I/O, OS?

L2a33:	db	0,0,0	; line number, ASCII ("000")
paglin:	db	0	; max PRN lines/page (0=infinit)
curlin:	db	0	; current PRN line (in page)
Fflag:	db	0	; $[+-*]1 flag
L2a39:	db	0
L2a3a:	db	0
curdrv:	db	0	; current disk (any op)
asmsrc:	db	0	; source - ASM "$Ax"
prndst:	db	0	; dest for PRN "$Px"
symdst:	db	0	; dest for SYM "$Sx"
reldst:	db	0	; dest for REL "$Rx"
libsrc:	db	0	; src libs LIB "$Lx"

L2a41:	db	0
dmaidx:	db	0
	db	0
L2a44:	db	0

; FCB for ASM (by any suffix)
asmfcb:	db	0,0,0,0,0,0,0,0,0,'ASM',0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0

L2a66	dw	1024
L2a68	dw	0

; FCB for PRN and SYM
prnfcb	db	0,0,0,0,0,0,0,0,0,'PRN',0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0

prnidx:	dw	0
L2a8d:	dw	0

; FCB for REL
relfcb:	db	0,0,0,0,0,0,0,0,0,'REL',0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0

hexidx:	dw	0

L2ab2:	dw	0

L2ab4:	mvi	c,setdma
	jmp	bdos		;; 2ab6: c3 05 00    ...

L2ab9:	lxi	d,defdma	;; 2ab9: 11 80 00    ...
	jmp	L2ab4		;; 2abc: c3 b4 2a    ..*

seldrv:	lxi	h,curdrv	;; 2abf: 21 3b 2a    .;*
	cmp	m		;; 2ac2: be          .
	rz			;; 2ac3: c8          .
	mov	m,a		;; 2ac4: 77          w
	mov	e,a		;; 2ac5: 5f          _
	mvi	c,seldsk	;; 2ac6: 0e 0e       ..
	call	bdos		;; 2ac8: cd 05 00    ...
	ret			;; 2acb: c9          .

setasm:	lda	asmsrc		;; 2acc: 3a 3c 2a    :<*
	jmp	seldrv		;; 2acf: c3 bf 2a    ..*

setprn:	lda	prndst		;; 2ad2: 3a 3d 2a    :=*
	jmp	seldrv		;; 2ad5: c3 bf 2a    ..*

setsym:	lda	symdst		;; 2ad8: 3a 3e 2a    :>*
	jmp	seldrv		;; 2adb: c3 bf 2a    ..*

setrel:	lda	reldst		;; 2ade: 3a 3f 2a    :?*
	jmp	seldrv		;; 2ae1: c3 bf 2a    ..*

setlib:	lda	libsrc		;; 2ae4: 3a 40 2a    :@*
	jmp	seldrv		;; 2ae7: c3 bf 2a    ..*

; print string until CR, add LF
msgcr:	mov	a,m		;; 2aea: 7e          ~
	call	chrout		;; 2aeb: cd 78 2f    .x/
	mov	a,m		;; 2aee: 7e          ~
	inx	h		;; 2aef: 23          #
	cpi	cr		;; 2af0: fe 0d       ..
	jnz	msgcr		;; 2af2: c2 ea 2a    ..*
	mvi	a,lf		;; 2af5: 3e 0a       >.
	call	chrout		;; 2af7: cd 78 2f    .x/
	ret			;; 2afa: c9          .

; Copy cmdline FCB basename to (HL)
L2afb:	lxi	d,deffcb	;; 2afb: 11 5c 00    .\.
	mvi	b,9		;; 2afe: 06 09       ..
L2b00:	ldax	d		;; 2b00: 1a          .
	cpi	'?'		;; 2b01: fe 3f       .?
	jz	L2de2		;; 2b03: ca e2 2d    ..-
	cpi	'$'		;; 2b06: fe 24       .$
	jz	L2de2		;; 2b08: ca e2 2d    ..-
	mov	m,a		;; 2b0b: 77          w
	inx	h		;; 2b0c: 23          #
	inx	d		;; 2b0d: 13          .
	dcr	b		;; 2b0e: 05          .
	jnz	L2b00		;; 2b0f: c2 00 2b    ..+
	ret			;; 2b12: c9          .

; setup LIB FCB, open it
libfil:	lxi	h,deffcb	;; 2b13: 21 5c 00    .\.
	mvi	m,0		;; 2b16: 36 00       6.
	lxi	d,tokbuf	;; 2b18: 11 c7 34    ..4
	ldax	d		;; 2b1b: 1a          .
	cpi	9		;; 2b1c: fe 09       ..
	jc	L2b23		;; 2b1e: da 23 2b    .#+
	mvi	a,8		;; 2b21: 3e 08       >.
L2b23:	mov	b,a		;; 2b23: 47          G
	mov	c,a		;; 2b24: 4f          O
L2b25:	inx	d		;; 2b25: 13          .
	inx	h		;; 2b26: 23          #
	ldax	d		;; 2b27: 1a          .
	mov	m,a		;; 2b28: 77          w
	dcr	c		;; 2b29: 0d          .
	jnz	L2b25		;; 2b2a: c2 25 2b    .%+
	mvi	a,8		;; 2b2d: 3e 08       >.
	sub	b		;; 2b2f: 90          .
	mov	c,a		;; 2b30: 4f          O
	inr	c		;; 2b31: 0c          .
L2b32:	inx	h		;; 2b32: 23          #
	dcr	c		;; 2b33: 0d          .
	jz	L2b3c		;; 2b34: ca 3c 2b    .<+
	mvi	m,' '		;; 2b37: 36 20       6 
	jmp	L2b32		;; 2b39: c3 32 2b    .2+

L2b3c:	mvi	m,'L'		;; 2b3c: 36 4c       6L
	inx	h		;; 2b3e: 23          #
	mvi	m,'I'		;; 2b3f: 36 49       6I
	inx	h		;; 2b41: 23          #
	mvi	m,'B'		;; 2b42: 36 42       6B
	inx	h		;; 2b44: 23          #
	xra	a		;; 2b45: af          .
	mov	m,a		;; 2b46: 77          w
	sta	deffcb+32	;; 2b47: 32 7c 00    2|.
	call	setlib		;; 2b4a: cd e4 2a    ..*
	lxi	d,deffcb	;; 2b4d: 11 5c 00    .\.
	jmp	openf		;; 2b50: c3 e7 2b    ..+

L2b53:	mvi	a,0ffh		;; 2b53: 3e ff       >.
	sta	L352a		;; 2b55: 32 2a 35    2*5
	lxi	h,128		;; 2b58: 21 80 00    ...
	shld	dmaidx		;; 2b5b: 22 42 2a    "B*
	lxi	h,curchr		;; 2b5e: 21 28 35    .(5
	mov	a,m		;; 2b61: 7e          ~
	sta	L2a41		;; 2b62: 32 41 2a    2A*
	xra	a		;; 2b65: af          .
	mov	m,a		;; 2b66: 77          w
	ret			;; 2b67: c9          .

osinit:	call	L2ab9		;; 2b68: cd b9 2a    ..*
	lxi	h,L319c		;; 2b6b: 21 9c 31    ..1
	call	msgcr		;; 2b6e: cd ea 2a    ..*
	mvi	a,56		;; 2b71: 3e 38       >8
	sta	paglin		;; 2b73: 32 36 2a    26*
	xra	a		;; 2b76: af          .
	sta	curlin		;; 2b77: 32 37 2a    27*
	lxi	h,0		;; 2b7a: 21 00 00    ...
	shld	L352f		;; 2b7d: 22 2f 35    "/5
	lhld	bdos+1		;; 2b80: 2a 06 00    *..
	shld	memtop		;; 2b83: 22 11 35    ".5
	lxi	h,buffer	;; 2b86: 21 b4 35    ..5
	shld	L2a68		;; 2b89: 22 68 2a    "h*
	lxi	d,1024		;; 2b8c: 11 00 04    ...
	dad	d		;; 2b8f: 19          .
	shld	L2a8d		;; 2b90: 22 8d 2a    ".*
	lxi	d,768		;; 2b93: 11 00 03    ...
	dad	d		;; 2b96: 19          .
	shld	L2ab2		;; 2b97: 22 b2 2a    ".*
	lxi	d,768		;; 2b9a: 11 00 03    ...
	dad	d		;; 2b9d: 19          .
	inx	h		;; 2b9e: 23          #
	shld	nxheap		;; 2b9f: 22 0f 35    ".5
	shld	syheap		;; 2ba2: 22 21 35    ".5
	jmp	parcmd		;; 2ba5: c3 5c 2c    .\,

; output char to console, suppressing blanks
L2ba8:	cpi	' '		;; 2ba8: fe 20       . 
	rz			;; 2baa: c8          .
	push	b		;; 2bab: c5          .
	push	h		;; 2bac: e5          .
	mov	e,a		;; 2bad: 5f          _
	mvi	c,conout	;; 2bae: 0e 02       ..
	call	bdos		;; 2bb0: cd 05 00    ...
	pop	h		;; 2bb3: e1          .
	pop	b		;; 2bb4: c1          .
	ret			;; 2bb5: c9          .

; output C chars from HL to console, suppressing blanks
L2bb6:	inx	h		;; 2bb6: 23          #
	mov	a,m		;; 2bb7: 7e          ~
	call	L2ba8		;; 2bb8: cd a8 2b    ..+
	dcr	c		;; 2bbb: 0d          .
	jnz	L2bb6		;; 2bbc: c2 b6 2b    ..+
	ret			;; 2bbf: c9          .

; display file name, incl. drive, then '-' and msg from HL
filerr:	push	h		;; 2bc0: e5          .
	xchg			;; 2bc1: eb          .
	lda	curdrv		;; 2bc2: 3a 3b 2a    :;*
	adi	'A'		;; 2bc5: c6 41       .A
	call	L2ba8		;; 2bc7: cd a8 2b    ..+
	mvi	a,':'		;; 2bca: 3e 3a       >:
	call	L2ba8		;; 2bcc: cd a8 2b    ..+
	mvi	c,8		;; 2bcf: 0e 08       ..
	call	L2bb6		;; 2bd1: cd b6 2b    ..+
	mvi	a,'.'		;; 2bd4: 3e 2e       >.
	call	L2ba8		;; 2bd6: cd a8 2b    ..+
	mvi	c,3		;; 2bd9: 0e 03       ..
	call	L2bb6		;; 2bdb: cd b6 2b    ..+
	mvi	a,'-'		;; 2bde: 3e 2d       >-
	call	L2ba8		;; 2be0: cd a8 2b    ..+
	pop	h		;; 2be3: e1          .
	jmp	msgcr		;; 2be4: c3 ea 2a    ..*

openf:	mvi	c,open		;; 2be7: 0e 0f       ..
	push	d		;; 2be9: d5          .
	call	bdos		;; 2bea: cd 05 00    ...
	cpi	0ffh		;; 2bed: fe ff       ..
	pop	d		;; 2bef: d1          .
	rnz			;; 2bf0: c0          .
	lxi	h,L31b0		;; 2bf1: 21 b0 31    ..1
	call	filerr		;; 2bf4: cd c0 2b    ..+
	jmp	cpm		;; 2bf7: c3 00 00    ...

closef:	mvi	c,close		;; 2bfa: 0e 10       ..
	push	d		;; 2bfc: d5          .
	call	bdos		;; 2bfd: cd 05 00    ...
	cpi	0ffh		;; 2c00: fe ff       ..
	pop	d		;; 2c02: d1          .
	rnz			;; 2c03: c0          .
	lxi	h,L3233		;; 2c04: 21 33 32    .32
	call	msgcr		;; 2c07: cd ea 2a    ..*
	jmp	cpm		;; 2c0a: c3 00 00    ...

deletf:	mvi	c,delete	;; 2c0d: 0e 13       ..
	jmp	bdos		;; 2c0f: c3 05 00    ...

makef:	mvi	c,make		;; 2c12: 0e 16       ..
	push	d		;; 2c14: d5          .
	call	bdos		;; 2c15: cd 05 00    ...
	cpi	0ffh		;; 2c18: fe ff       ..
	pop	d		;; 2c1a: d1          .
	rnz			;; 2c1b: c0          .
	lxi	h,L31c7		;; 2c1c: 21 c7 31    ..1
	call	filerr		;; 2c1f: cd c0 2b    ..+
	jmp	cpm		;; 2c22: c3 00 00    ...

isfile:	lda	prndst		;; 2c25: 3a 3d 2a    :=*
	cpi	DRVNUL		;; 2c28: fe 19       ..
	rz			;; 2c2a: c8          .
	cpi	DRVCON		;; 2c2b: fe 17       ..
	rz			;; 2c2d: c8          .
	cpi	DRVLST		;; 2c2e: fe 0f       ..
	ret			;; 2c30: c9          .

; expand TAB char
L2c31:	cpi	tab		;; 2c31: fe 09       ..
	jnz	L2c44		;; 2c33: c2 44 2c    .D,
L2c36:	mvi	a,' '		;; 2c36: 3e 20       > 
	call	L2c44		;; 2c38: cd 44 2c    .D,
	lda	L2a44		;; 2c3b: 3a 44 2a    :D*
	ani	007h		;; 2c3e: e6 07       ..
	jnz	L2c36		;; 2c40: c2 36 2c    .6,
	ret			;; 2c43: c9          .

L2c44:	push	psw		;; 2c44: f5          .
	mov	e,a		;; 2c45: 5f          _
	mvi	c,lstout	;; 2c46: 0e 05       ..
	call	bdos		;; 2c48: cd 05 00    ...
	pop	psw		;; 2c4b: f1          .
	lxi	h,L2a44		;; 2c4c: 21 44 2a    .D*
	cpi	lf		;; 2c4f: fe 0a       ..
	jnz	L2c57		;; 2c51: c2 57 2c    .W,
	mvi	m,0		;; 2c54: 36 00       6.
	ret			;; 2c56: c9          .

; count printable chars
L2c57:	cpi	' '		;; 2c57: fe 20       . 
	rc			;; 2c59: d8          .
	inr	m		;; 2c5a: 34          4
	ret			;; 2c5b: c9          .

; parse commandline buffer
parcmd:	xra	a		;; 2c5c: af          .
	; set all defaults
	sta	L2a44		;; 2c5d: 32 44 2a    2D*
	sta	L352a		;; 2c60: 32 2a 35    2*5
	sta	Lflag		;; 2c63: 32 32 35    225
	sta	Qflag		;; 2c66: 32 31 35    215
	sta	Fflag		;; 2c69: 32 38 2a    28*
	lda	deffcb		;; 2c6c: 3a 5c 00    :\.
	cpi	' '		;; 2c6f: fe 20       . 
	jz	L2de2		;; 2c71: ca e2 2d    ..-
	mvi	c,curdsk	;; 2c74: 0e 19       ..
	call	bdos		;; 2c76: cd 05 00    ...
	sta	curdrv		;; 2c79: 32 3b 2a    2;*
	sta	libsrc		;; 2c7c: 32 40 2a    2@*
	mov	c,a		;; 2c7f: 4f          O
	lda	deffcb		;; 2c80: 3a 5c 00    :\.
	ora	a		;; 2c83: b7          .
	jz	L2c8b		;; 2c84: ca 8b 2c    ..,
	dcr	a		;; 2c87: 3d          =
	jmp	L2c8c		;; 2c88: c3 8c 2c    ..,

L2c8b:	mov	a,c		;; 2c8b: 79          y
L2c8c:	lxi	h,asmsrc	;; 2c8c: 21 3c 2a    .<*
	mov	m,a		;; 2c8f: 77          w
	inx	h		;; 2c90: 23          #
	mov	m,a		;; 2c91: 77          w
	inx	h		;; 2c92: 23          #
	mov	m,a		;; 2c93: 77          w
	inx	h		;; 2c94: 23          #
	mov	m,a		;; 2c95: 77          w
	inx	h		;; 2c96: 23          #
	mvi	a,1		;; 2c97: 3e 01       >.
	sta	Sflag		;; 2c99: 32 2b 35    2+5
	sta	Mflag		;; 2c9c: 32 2c 35    2,5
	; see if options specified
	lda	deffcb+17	;; 2c9f: 3a 6d 00    :m.
	cpi	'$'		;; 2ca2: fe 24       .$
	jnz	L2d3e		;; 2ca4: c2 3e 2d    .>-
	lxi	h,cmdlin+1	;; 2ca7: 21 81 00    ...
L2caa:	mov	a,m		;; 2caa: 7e          ~
	inx	h		;; 2cab: 23          #
	cpi	'$'		;; 2cac: fe 24       .$
	jnz	L2caa		;; 2cae: c2 aa 2c    ..,
L2cb1:	mov	a,m		;; 2cb1: 7e          ~
	ora	a		;; 2cb2: b7          .
	jz	L2d3e		;; 2cb3: ca 3e 2d    .>-
	inx	h		;; 2cb6: 23          #
	cpi	' '		;; 2cb7: fe 20       . 
	jz	L2cb1		;; 2cb9: ca b1 2c    ..,
	lxi	d,asmsrc	;; 2cbc: 11 3c 2a    .<*
	cpi	'A'		;; 2cbf: fe 41       .A
	jz	L2d1f		;; 2cc1: ca 1f 2d    ..-
	inx	d		;; 2cc4: 13          .
	cpi	'P'		;; 2cc5: fe 50       .P
	jz	L2d1f		;; 2cc7: ca 1f 2d    ..-
	inx	d		;; 2cca: 13          .
	cpi	'S'		;; 2ccb: fe 53       .S
	jz	L2d1f		;; 2ccd: ca 1f 2d    ..-
	inx	d		;; 2cd0: 13          .
	cpi	'R'		;; 2cd1: fe 52       .R
	jz	L2d1f		;; 2cd3: ca 1f 2d    ..-
	inx	d		;; 2cd6: 13          .
	cpi	'L'		;; 2cd7: fe 4c       .L
	jz	L2d1f		;; 2cd9: ca 1f 2d    ..-
	inx	d		;; 2cdc: 13          .
	mvi	b,007h		;; 2cdd: 06 07       ..
	cpi	'*'		;; 2cdf: fe 2a       .*
	jz	L2cf2		;; 2ce1: ca f2 2c    ..,
	mvi	b,003h		;; 2ce4: 06 03       ..
	cpi	'+'		;; 2ce6: fe 2b       .+
	jz	L2cf2		;; 2ce8: ca f2 2c    ..,
	mvi	b,000h		;; 2ceb: 06 00       ..
	cpi	'-'		;; 2ced: fe 2d       .-
	jnz	cmderr		;; 2cef: c2 2c 2d    .,-
L2cf2:	lxi	d,Sflag		;; 2cf2: 11 2b 35    .+5
	mov	a,m		;; 2cf5: 7e          ~
	cpi	'S'		;; 2cf6: fe 53       .S
	jz	L2d19		;; 2cf8: ca 19 2d    ..-
	inx	d		;; 2cfb: 13          .
	cpi	'M'		;; 2cfc: fe 4d       .M
	jz	L2d19		;; 2cfe: ca 19 2d    ..-
	lxi	d,Lflag		;; 2d01: 11 32 35    .25
	cpi	'L'		;; 2d04: fe 4c       .L
	jz	L2d19		;; 2d06: ca 19 2d    ..-
	lxi	d,Qflag		;; 2d09: 11 31 35    .15
	cpi	'Q'		;; 2d0c: fe 51       .Q
	jz	L2d19		;; 2d0e: ca 19 2d    ..-
	lxi	d,Fflag		;; 2d11: 11 38 2a    .8*
	cpi	'1'		;; 2d14: fe 31       .1
	jnz	cmderr		;; 2d16: c2 2c 2d    .,-
L2d19:	mov	a,b		;; 2d19: 78          x
	stax	d		;; 2d1a: 12          .
	inx	h		;; 2d1b: 23          #
	jmp	L2cb1		;; 2d1c: c3 b1 2c    ..,

L2d1f:	mov	a,m		;; 2d1f: 7e          ~
	sui	'A'		;; 2d20: d6 41       .A
	cpi	'Z'-'A'+1	;; 2d22: fe 1a       ..
	jnc	cmderr		;; 2d24: d2 2c 2d    .,-
	stax	d		;; 2d27: 12          .
	inx	h		;; 2d28: 23          #
	jmp	L2cb1		;; 2d29: c3 b1 2c    ..,

; syntax error in commandline
cmderr:	inx	h		;; 2d2c: 23          #
	mvi	m,cr		;; 2d2d: 36 0d       6.
	lxi	h,L31f1		;; 2d2f: 21 f1 31    ..1
	call	msgcr		;; 2d32: cd ea 2a    ..*
	lxi	h,cmdlin+1	;; 2d35: 21 81 00    ...
	call	msgcr		;; 2d38: cd ea 2a    ..*
	jmp	cpm		;; 2d3b: c3 00 00    ...

L2d3e:	lxi	h,asmfcb	;; 2d3e: 21 45 2a    .E*
	call	L2afb		;; 2d41: cd fb 2a    ..*
	lxi	d,deffcb+9	;; 2d44: 11 65 00    .e.
	ldax	d		;; 2d47: 1a          .
	cpi	' '		;; 2d48: fe 20       . 
	lxi	h,asmfcb+9	;; 2d4a: 21 4e 2a    .N*
	mvi	b,3		;; 2d4d: 06 03       ..
	cnz	L2b00		;; 2d4f: c4 00 2b    ..+
	call	L2dcb		;; 2d52: cd cb 2d    ..-
	lxi	h,prnfcb	;; 2d55: 21 6a 2a    .j*
	push	h		;; 2d58: e5          .
	call	L2afb		;; 2d59: cd fb 2a    ..*
	pop	h		;; 2d5c: e1          .
	call	isfile		;; 2d5d: cd 25 2c    .%,
	jz	L2d72		;; 2d60: ca 72 2d    .r-
	push	h		;; 2d63: e5          .
	push	h		;; 2d64: e5          .
	mvi	m,0		;; 2d65: 36 00       6.
	call	setprn		;; 2d67: cd d2 2a    ..*
	pop	d		;; 2d6a: d1          .
	call	deletf		;; 2d6b: cd 0d 2c    ..,
	pop	d		;; 2d6e: d1          .
	call	makef		;; 2d6f: cd 12 2c    ..,
; If any destination needs LST:, acquire it on MP/M-II
L2d72:	lda	prndst		;; 2d72: 3a 3d 2a    :=*
	cpi	DRVLST		;; 2d75: fe 0f       ..
	jz	L2d82		;; 2d77: ca 82 2d    ..-
	lda	symdst		;; 2d7a: 3a 3e 2a    :>*
	cpi	DRVLST		;; 2d7d: fe 0f       ..
	jnz	L2d85		;; 2d7f: c2 85 2d    ..-
L2d82:	call	acqlst		;; 2d82: cd ca 32    ..2
;
L2d85:	lda	reldst		;; 2d85: 3a 3f 2a    :?*
	cpi	DRVNUL		;; 2d88: fe 19       ..
	jz	L2da8		;; 2d8a: ca a8 2d    ..-
	lxi	h,relfcb		;; 2d8d: 21 8f 2a    ..*
	push	h		;; 2d90: e5          .
	push	h		;; 2d91: e5          .
	call	L2afb		;; 2d92: cd fb 2a    ..*
	call	setrel		;; 2d95: cd de 2a    ..*
	pop	d		;; 2d98: d1          .
	xra	a		;; 2d99: af          .
	sta	L2a3a		;; 2d9a: 32 3a 2a    2:*
	sta	L2a39		;; 2d9d: 32 39 2a    29*
	stax	d		;; 2da0: 12          .
	call	deletf		;; 2da1: cd 0d 2c    ..,
	pop	d		;; 2da4: d1          .
	call	makef		;; 2da5: cd 12 2c    ..,
L2da8:	ret			;; 2da8: c9          .

L2da9:	lxi	h,L2a33		;; 2da9: 21 33 2a    .3*
	mvi	m,'0'		;; 2dac: 36 30       60
	inx	h		;; 2dae: 23          #
	mvi	m,'0'		;; 2daf: 36 30       60
	inx	h		;; 2db1: 23          #
	mvi	m,'0'		;; 2db2: 36 30       60
	inx	h		;; 2db4: 23          #
	mvi	a,0ffh		;; 2db5: 3e ff       >.
	sta	Pflag		;; 2db7: 32 33 35    235
	lxi	h,0		;; 2dba: 21 00 00    ...
	shld	prnidx		;; 2dbd: 22 8b 2a    ".*
	lda	pass		;; 2dc0: 3a 15 35    :.5
	ora	a		;; 2dc3: b7          .
	rz			;; 2dc4: c8          .
	call	L2fa8		;; 2dc5: cd a8 2f    ../
	jmp	L2dcb		;; 2dc8: c3 cb 2d    ..-

L2dcb:	lxi	h,1024		;; 2dcb: 21 00 04    ...
	shld	L2a66		;; 2dce: 22 66 2a    "f*
	xra	a		;; 2dd1: af          .
	sta	asmfcb+12	;; 2dd2: 32 51 2a    2Q*
	sta	asmfcb+32	;; 2dd5: 32 65 2a    2e*
	call	setasm		;; 2dd8: cd cc 2a    ..*
	lxi	d,asmfcb	;; 2ddb: 11 45 2a    .E*
	call	openf		;; 2dde: cd e7 2b    ..+
	ret			;; 2de1: c9          .

L2de2:	lxi	h,L31da		;; 2de2: 21 da 31    ..1
	call	msgcr		;; 2de5: cd ea 2a    ..*
	jmp	cpm		;; 2de8: c3 00 00    ...

compar:	mov	a,d		;; 2deb: 7a          z
	cmp	h		;; 2dec: bc          .
	rnz			;; 2ded: c0          .
	mov	a,e		;; 2dee: 7b          {
	cmp	l		;; 2def: bd          .
	ret			;; 2df0: c9          .

L2df1:	push	b		;; 2df1: c5          .
	push	d		;; 2df2: d5          .
	push	h		;; 2df3: e5          .
	lda	L352a		;; 2df4: 3a 2a 35    :*5
	ora	a		;; 2df7: b7          .
	jz	L2e47		;; 2df8: ca 47 2e    .G.
	lhld	dmaidx		;; 2dfb: 2a 42 2a    *B*
	lxi	d,128		;; 2dfe: 11 80 00    ...
	call	compar		;; 2e01: cd eb 2d    ..-
	jnz	L2e1c		;; 2e04: c2 1c 2e    ...
	lxi	h,0		;; 2e07: 21 00 00    ...
	shld	dmaidx		;; 2e0a: 22 42 2a    "B*
	call	setlib		;; 2e0d: cd e4 2a    ..*
	mvi	c,read		;; 2e10: 0e 14       ..
	lxi	d,deffcb	;; 2e12: 11 5c 00    .\.
	call	bdos		;; 2e15: cd 05 00    ...
	ora	a		;; 2e18: b7          .
	jnz	L2e2e		;; 2e19: c2 2e 2e    ...
L2e1c:	lhld	dmaidx		;; 2e1c: 2a 42 2a    *B*
	inx	h		;; 2e1f: 23          #
	shld	dmaidx		;; 2e20: 22 42 2a    "B*
	dcx	h		;; 2e23: 2b          +
	lxi	d,defdma	;; 2e24: 11 80 00    ...
	dad	d		;; 2e27: 19          .
	mov	a,m		;; 2e28: 7e          ~
	cpi	eof		;; 2e29: fe 1a       ..
	jnz	L2ea4		;; 2e2b: c2 a4 2e    ...
L2e2e:	lda	L3375		;; 2e2e: 3a 75 33    :u3
	ora	a		;; 2e31: b7          .
	sta	L352a		;; 2e32: 32 2a 35    2*5
	jz	L2e47		;; 2e35: ca 47 2e    .G.
	call	setlib		;; 2e38: cd e4 2a    ..*
	lxi	d,deffcb	;; 2e3b: 11 5c 00    .\.
	lxi	h,L3246		;; 2e3e: 21 46 32    .F2
	call	filerr		;; 2e41: cd c0 2b    ..+
	jmp	cpm		;; 2e44: c3 00 00    ...

L2e47:	lhld	L2a66		;; 2e47: 2a 66 2a    *f*
	lxi	d,1024		;; 2e4a: 11 00 04    ...
	call	compar		;; 2e4d: cd eb 2d    ..-
	jnz	L2e95		;; 2e50: c2 95 2e    ...
	call	setasm		;; 2e53: cd cc 2a    ..*
	lxi	h,0		;; 2e56: 21 00 00    ...
	shld	L2a66		;; 2e59: 22 66 2a    "f*
	mvi	b,8		;; 2e5c: 06 08       ..
	lhld	L2a68		;; 2e5e: 2a 68 2a    *h*
L2e61:	push	b		;; 2e61: c5          .
	push	h		;; 2e62: e5          .
	xchg			;; 2e63: eb          .
	call	L2ab4		;; 2e64: cd b4 2a    ..*
	mvi	c,read		;; 2e67: 0e 14       ..
	lxi	d,asmfcb	;; 2e69: 11 45 2a    .E*
	call	bdos		;; 2e6c: cd 05 00    ...
	pop	h		;; 2e6f: e1          .
	lxi	d,128		;; 2e70: 11 80 00    ...
	dad	d		;; 2e73: 19          .
	pop	b		;; 2e74: c1          .
	ora	a		;; 2e75: b7          .
	jnz	L2e80		;; 2e76: c2 80 2e    ...
	dcr	b		;; 2e79: 05          .
	jnz	L2e61		;; 2e7a: c2 61 2e    .a.
	jmp	L2e92		;; 2e7d: c3 92 2e    ...

L2e80:	cpi	003h		;; 2e80: fe 03       ..
	jnc	L2eaa		;; 2e82: d2 aa 2e    ...
	dcr	b		;; 2e85: 05          .
	jz	L2e92		;; 2e86: ca 92 2e    ...
	mvi	c,128		;; 2e89: 0e 80       ..
L2e8b:	mvi	m,eof		;; 2e8b: 36 1a       6.
	inx	h		;; 2e8d: 23          #
	dcr	c		;; 2e8e: 0d          .
	jnz	L2e8b		;; 2e8f: c2 8b 2e    ...
L2e92:	call	L2ab9		;; 2e92: cd b9 2a    ..*
L2e95:	lhld	L2a68		;; 2e95: 2a 68 2a    *h*
	xchg			;; 2e98: eb          .
	lhld	L2a66		;; 2e99: 2a 66 2a    *f*
	push	h		;; 2e9c: e5          .
	inx	h		;; 2e9d: 23          #
	shld	L2a66		;; 2e9e: 22 66 2a    "f*
	pop	h		;; 2ea1: e1          .
	dad	d		;; 2ea2: 19          .
	mov	a,m		;; 2ea3: 7e          ~
L2ea4:	pop	h		;; 2ea4: e1          .
	pop	d		;; 2ea5: d1          .
	pop	b		;; 2ea6: c1          .
	ani	07fh		;; 2ea7: e6 7f       ..
	ret			;; 2ea9: c9          .

L2eaa:	lxi	h,L3204		;; 2eaa: 21 04 32    ..2
	call	msgcr		;; 2ead: cd ea 2a    ..*
	jmp	cpm		;; 2eb0: c3 00 00    ...

prnput:	push	b		;; 2eb3: c5          .
	mov	b,a		;; 2eb4: 47          G
	lda	prndst		;; 2eb5: 3a 3d 2a    :=*
	cpi	DRVNUL		;; 2eb8: fe 19       ..
	jz	L2edc		;; 2eba: ca dc 2e    ...
	cpi	DRVCON		;; 2ebd: fe 17       ..
	jnz	L2ec9		;; 2ebf: c2 c9 2e    ...
	mov	a,b		;; 2ec2: 78          x
	call	chrout		;; 2ec3: cd 78 2f    .x/
	jmp	L2edc		;; 2ec6: c3 dc 2e    ...

L2ec9:	push	d		;; 2ec9: d5          .
	push	h		;; 2eca: e5          .
	cpi	DRVLST		;; 2ecb: fe 0f       ..
	mov	a,b		;; 2ecd: 78          x
	jnz	L2ed7		;; 2ece: c2 d7 2e    ...
	call	L2c31		;; 2ed1: cd 31 2c    .1,
	jmp	L2eda		;; 2ed4: c3 da 2e    ...

L2ed7:	call	L2ede		;; 2ed7: cd de 2e    ...
L2eda:	pop	h		;; 2eda: e1          .
	pop	d		;; 2edb: d1          .
L2edc:	pop	b		;; 2edc: c1          .
	ret			;; 2edd: c9          .

L2ede:	lhld	prnidx		;; 2ede: 2a 8b 2a    *.*
	xchg			;; 2ee1: eb          .
	lhld	L2a8d		;; 2ee2: 2a 8d 2a    *.*
	dad	d		;; 2ee5: 19          .
	mov	m,a		;; 2ee6: 77          w
	xchg			;; 2ee7: eb          .
	inx	h		;; 2ee8: 23          #
	shld	prnidx		;; 2ee9: 22 8b 2a    ".*
	xchg			;; 2eec: eb          .
	lxi	h,768		;; 2eed: 21 00 03    ...
	call	compar		;; 2ef0: cd eb 2d    ..-
	rnz			;; 2ef3: c0          .
	call	setprn		;; 2ef4: cd d2 2a    ..*
	lxi	h,0		;; 2ef7: 21 00 00    ...
	shld	prnidx		;; 2efa: 22 8b 2a    ".*
	lhld	L2a8d		;; 2efd: 2a 8d 2a    *.*
	lxi	d,prnfcb	;; 2f00: 11 6a 2a    .j*
	mvi	b,6		;; 2f03: 06 06       ..
L2f05:	push	h		;; 2f05: e5          .
	lxi	h,relfcb	;; 2f06: 21 8f 2a    ..*
	call	compar		;; 2f09: cd eb 2d    ..-
	pop	h		;; 2f0c: e1          .
	jz	L2f16		;; 2f0d: ca 16 2f    ../
	mov	a,m		;; 2f10: 7e          ~
	cpi	eof		;; 2f11: fe 1a       ..
	jz	L2f35		;; 2f13: ca 35 2f    .5/
L2f16:	push	b		;; 2f16: c5          .
	push	d		;; 2f17: d5          .
	push	h		;; 2f18: e5          .
	xchg			;; 2f19: eb          .
	call	L2ab4		;; 2f1a: cd b4 2a    ..*
	pop	h		;; 2f1d: e1          .
	lxi	d,128		;; 2f1e: 11 80 00    ...
	dad	d		;; 2f21: 19          .
	pop	d		;; 2f22: d1          .
	push	d		;; 2f23: d5          .
	push	h		;; 2f24: e5          .
	mvi	c,write		;; 2f25: 0e 15       ..
	call	bdos		;; 2f27: cd 05 00    ...
	pop	h		;; 2f2a: e1          .
	pop	d		;; 2f2b: d1          .
	pop	b		;; 2f2c: c1          .
	ora	a		;; 2f2d: b7          .
	jnz	L2f39		;; 2f2e: c2 39 2f    .9/
	dcr	b		;; 2f31: 05          .
	jnz	L2f05		;; 2f32: c2 05 2f    ../
L2f35:	call	L2ab9		;; 2f35: cd b9 2a    ..*
	ret			;; 2f38: c9          .

L2f39:	lxi	h,L321b		;; 2f39: 21 1b 32    ..2
	call	msgcr		;; 2f3c: cd ea 2a    ..*
	jmp	L317f		;; 2f3f: c3 7f 31    ..1

hexput:	push	b		;; 2f42: c5          .
	push	d		;; 2f43: d5          .
	push	h		;; 2f44: e5          .
	call	hexpt		;; 2f45: cd 4c 2f    .L/
	pop	h		;; 2f48: e1          .
	pop	d		;; 2f49: d1          .
	pop	b		;; 2f4a: c1          .
	ret			;; 2f4b: c9          .

hexpt:	lhld	hexidx		;; 2f4c: 2a b0 2a    *.*
	xchg			;; 2f4f: eb          .
	lhld	L2ab2		;; 2f50: 2a b2 2a    *.*
	dad	d		;; 2f53: 19          .
	mov	m,a		;; 2f54: 77          w
	xchg			;; 2f55: eb          .
	inx	h		;; 2f56: 23          #
	shld	hexidx		;; 2f57: 22 b0 2a    ".*
	xchg			;; 2f5a: eb          .
	lxi	h,768		;; 2f5b: 21 00 03    ...
	call	compar		;; 2f5e: cd eb 2d    ..-
	rnz			;; 2f61: c0          .
	mvi	b,6		;; 2f62: 06 06       ..
L2f64:	push	b		;; 2f64: c5          .
	call	setrel		;; 2f65: cd de 2a    ..*
	lxi	h,0		;; 2f68: 21 00 00    ...
	shld	hexidx		;; 2f6b: 22 b0 2a    ".*
	lhld	L2ab2		;; 2f6e: 2a b2 2a    *.*
	lxi	d,relfcb	;; 2f71: 11 8f 2a    ..*
	pop	b		;; 2f74: c1          .
	jmp	L2f05		;; 2f75: c3 05 2f    ../

; print char
chrout:	push	b		;; 2f78: c5          .
	push	d		;; 2f79: d5          .
	push	h		;; 2f7a: e5          .
	mvi	c,conout	;; 2f7b: 0e 02       ..
	mov	e,a		;; 2f7d: 5f          _
	call	bdos		;; 2f7e: cd 05 00    ...
	pop	h		;; 2f81: e1          .
	pop	d		;; 2f82: d1          .
	pop	b		;; 2f83: c1          .
	ret			;; 2f84: c9          .

; increment a 3-digit ASCII numeric field
L2f85:	lxi	h,L2a33+2	;; 2f85: 21 35 2a    .5*
	mvi	c,3		;; 2f88: 0e 03       ..
L2f8a:	mov	a,m		;; 2f8a: 7e          ~
	inr	a		;; 2f8b: 3c          <
	mov	m,a		;; 2f8c: 77          w
	cpi	'9'+1		;; 2f8d: fe 3a       .:
	jc	L2f99		;; 2f8f: da 99 2f    ../
	mvi	m,'0'		;; 2f92: 36 30       60
	dcx	h		;; 2f94: 2b          +
	dcr	c		;; 2f95: 0d          .
	jnz	L2f8a		;; 2f96: c2 8a 2f    ../
L2f99:	lxi	h,L2a33		;; 2f99: 21 33 2a    .3*
	mvi	c,3		;; 2f9c: 0e 03       ..
L2f9e:	mov	a,m		;; 2f9e: 7e          ~
	call	prnput		;; 2f9f: cd b3 2e    ...
	inx	h		;; 2fa2: 23          #
	dcr	c		;; 2fa3: 0d          .
	jnz	L2f9e		;; 2fa4: c2 9e 2f    ../
	ret			;; 2fa7: c9          .

L2fa8:	lda	paglin		;; 2fa8: 3a 36 2a    :6*
	ora	a		;; 2fab: b7          .
	rz			;; 2fac: c8          .
	lda	Pflag		;; 2fad: 3a 33 35    :35
	ora	a		;; 2fb0: b7          .
	rz			;; 2fb1: c8          .
	mvi	a,ff		;; 2fb2: 3e 0c       >.
	call	prnput		;; 2fb4: cd b3 2e    ...
	xra	a		;; 2fb7: af          .
	sta	curlin		;; 2fb8: 32 37 2a    27*
	lhld	L352f		;; 2fbb: 2a 2f 35    */5
	mov	a,l		;; 2fbe: 7d          }
	ora	h		;; 2fbf: b4          .
	rz			;; 2fc0: c8          .
	lxi	h,L319c		;; 2fc1: 21 9c 31    ..1
L2fc4:	mov	a,m		;; 2fc4: 7e          ~
	cpi	cr		;; 2fc5: fe 0d       ..
	jz	L2fd1		;; 2fc7: ca d1 2f    ../
	call	prnput		;; 2fca: cd b3 2e    ...
	inx	h		;; 2fcd: 23          #
	jmp	L2fc4		;; 2fce: c3 c4 2f    ../

L2fd1:	mvi	a,tab		;; 2fd1: 3e 09       >.
	call	prnput		;; 2fd3: cd b3 2e    ...
	mvi	a,'#'		;; 2fd6: 3e 23       >#
	call	prnput		;; 2fd8: cd b3 2e    ...
	call	L2f85		;; 2fdb: cd 85 2f    ../
	mvi	a,tab		;; 2fde: 3e 09       >.
	call	prnput		;; 2fe0: cd b3 2e    ...
	lhld	L352f		;; 2fe3: 2a 2f 35    */5
L2fe6:	mov	a,m		;; 2fe6: 7e          ~
	ora	a		;; 2fe7: b7          .
	jz	L2ff2		;; 2fe8: ca f2 2f    ../
	call	prnput		;; 2feb: cd b3 2e    ...
	inx	h		;; 2fee: 23          #
	jmp	L2fe6		;; 2fef: c3 e6 2f    ../

L2ff2:	mvi	a,cr		;; 2ff2: 3e 0d       >.
	call	prnput		;; 2ff4: cd b3 2e    ...
	mvi	a,lf		;; 2ff7: 3e 0a       >.
	call	prnput		;; 2ff9: cd b3 2e    ...
	mvi	a,lf		;; 2ffc: 3e 0a       >.
	jmp	prnput		;; 2ffe: c3 b3 2e    ...

L3001:	mov	a,l		;; 3001: 7d          }
	sta	paglin		;; 3002: 32 36 2a    26*
	lxi	h,curlin	;; 3005: 21 37 2a    .7*
	sub	m		;; 3008: 96          .
	rnc			;; 3009: d0          .
	jmp	L2fa8		;; 300a: c3 a8 2f    ../

L300d:	mov	c,a		;; 300d: 4f          O
	call	prnput		;; 300e: cd b3 2e    ...
	lda	curerr		;; 3011: 3a 4b 34    :K4
	cpi	' '		;; 3014: fe 20       . 
	rz			;; 3016: c8          .
	lda	pass		;; 3017: 3a 15 35    :.5
	cpi	002h		;; 301a: fe 02       ..
	rz			;; 301c: c8          .
	lda	prndst		;; 301d: 3a 3d 2a    :=*
	cpi	DRVCON		;; 3020: fe 17       ..
	rz			;; 3022: c8          .
	mov	a,c		;; 3023: 79          y
	call	chrout		;; 3024: cd 78 2f    .x/
	ret			;; 3027: c9          .

L3028:	lda	Fflag		;; 3028: 3a 38 2a    :8*
	lxi	h,pass		;; 302b: 21 15 35    ..5
	ora	m		;; 302e: b6          .
	jnz	L3049		;; 302f: c2 49 30    .I0
	lda	Lflag		;; 3032: 3a 32 35    :25
	lxi	h,L352a		;; 3035: 21 2a 35    .*5
	ana	m		;; 3038: a6          .
	jnz	L3097		;; 3039: c2 97 30    ..0
	mov	a,m		;; 303c: 7e          ~
	ora	a		;; 303d: b7          .
	jz	L30c4		;; 303e: ca c4 30    ..0
	lda	curerr		;; 3041: 3a 4b 34    :K4
	cpi	' '		;; 3044: fe 20       . 
	jz	L30c4		;; 3046: ca c4 30    ..0
L3049:	lxi	h,curerr	;; 3049: 21 4b 34    .K4
	mov	a,m		;; 304c: 7e          ~
	cpi	' '		;; 304d: fe 20       . 
	jnz	L3097		;; 304f: c2 97 30    ..0
	lda	Pflag		;; 3052: 3a 33 35    :35
	ora	a		;; 3055: b7          .
	jz	L30c4		;; 3056: ca c4 30    ..0
	lda	prnbuf+5	;; 3059: 3a 50 34    :P4
	cpi	'+'		;; 305c: fe 2b       .+
	jnz	L3097		;; 305e: c2 97 30    ..0
	lda	Mflag		;; 3061: 3a 2c 35    :,5
	ora	a		;; 3064: b7          .
	jz	L30c4		;; 3065: ca c4 30    ..0
	cpi	003h		;; 3068: fe 03       ..
	jz	L3097		;; 306a: ca 97 30    ..0
	lda	prnbuf+6	;; 306d: 3a 51 34    :Q4
	cpi	'#'		;; 3070: fe 23       .#
	jz	L30c4		;; 3072: ca c4 30    ..0
	lda	prnbuf+1	;; 3075: 3a 4c 34    :L4
	cpi	' '		;; 3078: fe 20       . 
	jz	L30c4		;; 307a: ca c4 30    ..0
	lda	Mflag		;; 307d: 3a 2c 35    :,5
	dcr	a		;; 3080: 3d          =
	jz	L3097		;; 3081: ca 97 30    ..0
	lxi	d,16		;; 3084: 11 10 00    ...
L3087:	dcx	d		;; 3087: 1b          .
	lxi	h,prnbuf	;; 3088: 21 4b 34    .K4
	dad	d		;; 308b: 19          .
	mov	a,m		;; 308c: 7e          ~
	cpi	' '		;; 308d: fe 20       . 
	jz	L3087		;; 308f: ca 87 30    ..0
	inx	d		;; 3092: 13          .
	lxi	h,L34c3		;; 3093: 21 c3 34    ..4
	mov	m,e		;; 3096: 73          s
L3097:	lxi	h,curlin	;; 3097: 21 37 2a    .7*
	push	h		;; 309a: e5          .
	mov	a,m		;; 309b: 7e          ~
	lxi	h,paglin	;; 309c: 21 36 2a    .6*
	sub	m		;; 309f: 96          .
	cnc	L2fa8		;; 30a0: d4 a8 2f    ../
	pop	h		;; 30a3: e1          .
	inr	m		;; 30a4: 34          4
	lda	L34c3		;; 30a5: 3a c3 34    :.4
	lxi	h,prnbuf	;; 30a8: 21 4b 34    .K4
L30ab:	ora	a		;; 30ab: b7          .
	jz	L30ba		;; 30ac: ca ba 30    ..0
	mov	b,a		;; 30af: 47          G
	mov	a,m		;; 30b0: 7e          ~
	call	L300d		;; 30b1: cd 0d 30    ..0
	inx	h		;; 30b4: 23          #
	mov	a,b		;; 30b5: 78          x
	dcr	a		;; 30b6: 3d          =
	jmp	L30ab		;; 30b7: c3 ab 30    ..0

L30ba:	mvi	a,cr		;; 30ba: 3e 0d       >.
	call	L300d		;; 30bc: cd 0d 30    ..0
	mvi	a,lf		;; 30bf: 3e 0a       >.
	call	L300d		;; 30c1: cd 0d 30    ..0
L30c4:	xra	a		;; 30c4: af          .
	sta	L34c3		;; 30c5: 32 c3 34    2.4
	lxi	h,prnbuf	;; 30c8: 21 4b 34    .K4
	mvi	a,120		;; 30cb: 3e 78       >x
L30cd:	mvi	m,' '		;; 30cd: 36 20       6 
	inx	h		;; 30cf: 23          #
	dcr	a		;; 30d0: 3d          =
	jnz	L30cd		;; 30d1: c2 cd 30    ..0
	ret			;; 30d4: c9          .

seterr:	mov	b,a		;; 30d5: 47          G
	lxi	h,curerr	;; 30d6: 21 4b 34    .K4
	mov	a,m		;; 30d9: 7e          ~
	cpi	' '		;; 30da: fe 20       . 
	rnz			;; 30dc: c0          .
	mov	m,b		;; 30dd: 70          p
	ret			;; 30de: c9          .

L30df:	call	isfile		;; 30df: cd 25 2c    .%,
	rz			;; 30e2: c8          .
L30e3:	lhld	prnidx		;; 30e3: 2a 8b 2a    *.*
	mov	a,l		;; 30e6: 7d          }
	ora	h		;; 30e7: b4          .
	jz	L30f3		;; 30e8: ca f3 30    ..0
	mvi	a,eof		;; 30eb: 3e 1a       >.
	call	prnput		;; 30ed: cd b3 2e    ...
	jmp	L30e3		;; 30f0: c3 e3 30    ..0

L30f3:	call	setprn		;; 30f3: cd d2 2a    ..*
	lxi	d,prnfcb	;; 30f6: 11 6a 2a    .j*
	call	closef		;; 30f9: cd fa 2b    ..+
	ret			;; 30fc: c9          .

; SYM file setup - uses same facilities as PRN
L30fd:	lda	Sflag		;; 30fd: 3a 2b 35    :+5
	cpi	003h		;; 3100: fe 03       ..
	jz	L2fa8		;; 3102: ca a8 2f    ../
	call	L30df		;; 3105: cd df 30    ..0
	lxi	h,prnfcb+9	;; 3108: 21 73 2a    .s*
	mvi	m,'S'		;; 310b: 36 53       6S
	inx	h		;; 310d: 23          #
	mvi	m,'Y'		;; 310e: 36 59       6Y
	inx	h		;; 3110: 23          #
	mvi	m,'M'		;; 3111: 36 4d       6M
	inx	h		;; 3113: 23          #
	xra	a		;; 3114: af          .
	mov	m,a		;; 3115: 77          w
	lxi	h,prnfcb+32	;; 3116: 21 8a 2a    ..*
	mov	m,a		;; 3119: 77          w
	; should be calling setsym?
	lda	symdst		;; 311a: 3a 3e 2a    :>*
	sta	prndst		;; 311d: 32 3d 2a    2=*
	lxi	h,0		;; 3120: 21 00 00    ...
	shld	prnidx		;; 3123: 22 8b 2a    ".*
	call	isfile		;; 3126: cd 25 2c    .%,
	jz	L2fa8		;; 3129: ca a8 2f    ../
	xra	a		;; 312c: af          .
	sta	paglin		;; 312d: 32 36 2a    26*
	call	setprn		;; 3130: cd d2 2a    ..*
	lxi	d,prnfcb	;; 3133: 11 6a 2a    .j*
	push	d		;; 3136: d5          .
	xra	a		;; 3137: af          .
	stax	d		;; 3138: 12          .
	call	deletf		;; 3139: cd 0d 2c    ..,
	pop	d		;; 313c: d1          .
	call	makef		;; 313d: cd 12 2c    ..,
	ret			;; 3140: c9          .

; ensure REL file ends on byte boundary...
; i.e. flush last partial byte.
; then add END FILE tage.
relfin:	call	L30df		;; 3141: cd df 30    ..0
	lda	reldst		;; 3144: 3a 3f 2a    :?*
	cpi	DRVNUL		;; 3147: fe 19       ..
	jz	L317f		;; 3149: ca 7f 31    ..1
L314c:	lda	L2a3a		;; 314c: 3a 3a 2a    ::*
	ora	a		;; 314f: b7          .
	jz	L315a		;; 3150: ca 5a 31    .Z1
	xra	a		;; 3153: af          .
	call	relbit		;; 3154: cd ac 32    ..2
	jmp	L314c		;; 3157: c3 4c 31    .L1

; END of program - REL EOF
L315a:	mvi	c,09eh	; end file (plus a "0" bit)
	mvi	e,8		;; 315c: 1e 08       ..
	call	relbts		;; 315e: cd 8e 32    ..2
	; pad record with eof chars...
L3161:	lhld	hexidx		;; 3161: 2a b0 2a    *.*
	mov	a,l		;; 3164: 7d          }
	ora	h		;; 3165: b4          .
	jz	L317f		;; 3166: ca 7f 31    ..1
	mov	a,l		;; 3169: 7d          }
	ani	07fh		;; 316a: e6 7f       ..
	jz	L3177		;; 316c: ca 77 31    .w1
	mvi	a,eof		;; 316f: 3e 1a       >.
	call	hexput		;; 3171: cd 42 2f    .B/
	jmp	L3161		;; 3174: c3 61 31    .a1

L3177:	mov	a,l		;; 3177: 7d          }
	ral			;; 3178: 17          .
	mov	a,h		;; 3179: 7c          |
	ral			;; 317a: 17          .
	mov	b,a		;; 317b: 47          G
	call	L2f64		;; 317c: cd 64 2f    .d/
L317f:	nop	; patch?	;; 317f: 00          .
	nop			;; 3180: 00          .
	nop			;; 3181: 00          .
	lda	reldst		;; 3182: 3a 3f 2a    :?*
	cpi	DRVNUL		;; 3185: fe 19       ..
	jz	L3193		;; 3187: ca 93 31    ..1
	call	setrel		;; 318a: cd de 2a    ..*
	lxi	d,relfcb	;; 318d: 11 8f 2a    ..*
	call	closef		;; 3190: cd fa 2b    ..+
; end of assembly...
L3193:	lxi	h,endmsg	;; 3193: 21 5b 32    .[2
	call	msgcr		;; 3196: cd ea 2a    ..*
	jmp	cpm		;; 3199: c3 00 00    ...

L319c:	db	'CP/M RMAC ASSEM 1.1',0dh
L31b0:	db	'NO SOURCE FILE PRESENT',0dh
L31c7:	db	'NO DIRECTORY SPACE',0dh
L31da:	db	'SOURCE FILE NAME ERROR',0dh
L31f1:	db	'INVALID PARAMETER:',0dh
L3204:	db	'SOURCE FILE READ ERROR',0dh
L321b:	db	'OUTPUT FILE WRITE ERROR',0dh
L3233:	db	'CANNOT CLOSE FILES',0dh
L3246:	db	'UNBALANCED MACRO LIB',0dh
endmsg:	db	'END OF ASSEMBLY',0dh

	db	0,0,0

; get current address for segment curseg
getadr:	lda	curseg		;; 326e: 3a 20 35    : 5
	mov	c,a		;; 3271: 4f          O
	mvi	b,0		;; 3272: 06 00       ..
	lxi	h,segtbl	;; 3274: 21 18 35    ..5
	dad	b		;; 3277: 09          .
	dad	b		;; 3278: 09          .
	mov	a,m		;; 3279: 7e          ~
	inx	h		;; 327a: 23          #
	mov	h,m		;; 327b: 66          f
	mov	l,a		;; 327c: 6f          o
	ret			;; 327d: c9          .

; set current address for segment curseg
setadr:	lda	curseg		;; 327e: 3a 20 35    : 5
	mov	c,a		;; 3281: 4f          O
	mvi	b,0		;; 3282: 06 00       ..
	xchg			;; 3284: eb          .
	lxi	h,segtbl	;; 3285: 21 18 35    ..5
	dad	b		;; 3288: 09          .
	dad	b		;; 3289: 09          .
	mov	m,e		;; 328a: 73          s
	inx	h		;; 328b: 23          #
	mov	m,d		;; 328c: 72          r
	ret			;; 328d: c9          .

; emit REL bits, high (Eth) bit first.
; E=num bits, C=bit pattern
relbts:	lda	reldst		;; 328e: 3a 3f 2a    :?*
	cpi	DRVNUL		;; 3291: fe 19       ..
	rz			;; 3293: c8          .
	push	d		;; 3294: d5          .
	dcr	e		;; 3295: 1d          .
	mov	a,c		;; 3296: 79          y
	jz	L329f		;; 3297: ca 9f 32    ..2
L329a:	rrc			;; 329a: 0f          .
	dcr	e		;; 329b: 1d          .
	jnz	L329a		;; 329c: c2 9a 32    ..2
L329f:	ani	001h		;; 329f: e6 01       ..
	push	b		;; 32a1: c5          .
	call	relbit		;; 32a2: cd ac 32    ..2
	pop	b		;; 32a5: c1          .
	pop	d		;; 32a6: d1          .
	dcr	e		;; 32a7: 1d          .
	jnz	relbts		;; 32a8: c2 8e 32    ..2
	ret			;; 32ab: c9          .

; Add bit to REL output, flush when 8 bits
; A=bit
relbit:	mov	b,a		;; 32ac: 47          G
	lda	L2a39		;; 32ad: 3a 39 2a    :9*
	rlc			;; 32b0: 07          .
	ora	b		;; 32b1: b0          .
	sta	L2a39		;; 32b2: 32 39 2a    29*
	lxi	h,L2a3a		;; 32b5: 21 3a 2a    .:*
	inr	m		;; 32b8: 34          4
	mvi	a,8		;; 32b9: 3e 08       >.
	cmp	m		;; 32bb: be          .
	rnz			;; 32bc: c0          .
	mvi	m,0		;; 32bd: 36 00       6.
	lda	L2a39		;; 32bf: 3a 39 2a    :9*
	call	hexpt		;; 32c2: cd 4c 2f    .L/
	xra	a		;; 32c5: af          .
	sta	L2a39		;; 32c6: 32 39 2a    29*
	ret			;; 32c9: c9          .

; Acquire LST device (shared on MP/M-II)
acqlst:	call	osvers		;; 32ca: cd fd 32    ..2
	dcr	h		;; 32cd: 25          %
	rnz			;; 32ce: c0          .
	; MP/M... acquire printer...
	lxi	d,lstque	;; 32cf: 11 23 33    .#3
	push	d		;; 32d2: d5          .
	call	opnque		;; 32d3: cd 02 33    ..3
	pop	d		;; 32d6: d1          .
	call	crdque		;; 32d7: cd 07 33    ..3
	ora	a		;; 32da: b7          .
	rz			;; 32db: c8          .
	lxi	d,waitms	;; 32dc: 11 2f 33    ./3
	call	prmsg		;; 32df: cd 0c 33    ..3
L32e2:	call	sleep1		;; 32e2: cd 11 33    ..3
	call	chkcon		;; 32e5: cd 19 33    ..3
	ora	a		;; 32e8: b7          .
	cnz	getcon		;; 32e9: c4 1e 33    ..3
	lxi	d,lstque	;; 32ec: 11 23 33    .#3
	call	crdque		;; 32ef: cd 07 33    ..3
	ora	a		;; 32f2: b7          .
	jnz	L32e2		;; 32f3: c2 e2 32    ..2
	lxi	d,rdymsg	;; 32f6: 11 45 33    .E3
	call	prmsg		;; 32f9: cd 0c 33    ..3
	ret			;; 32fc: c9          .

osvers:	mvi	c,getver	;; 32fd: 0e 0c       ..
	jmp	bdos		;; 32ff: c3 05 00    ...

opnque:	mvi	c,openq		;; 3302: 0e 87       ..
	jmp	bdos		;; 3304: c3 05 00    ...

crdque:	mvi	c,creadq	;; 3307: 0e 8a       ..
	jmp	bdos		;; 3309: c3 05 00    ...

prmsg:	mvi	c,print		;; 330c: 0e 09       ..
	jmp	bdos		;; 330e: c3 05 00    ...

sleep1:	mvi	c,delay		;; 3311: 0e 8d       ..
	lxi	d,1		;; 3313: 11 01 00    ...
	jmp	bdos		;; 3316: c3 05 00    ...

chkcon:	mvi	c,const		;; 3319: 0e 0b       ..
	jmp	bdos		;; 331b: c3 05 00    ...

getcon:	mvi	c,conin		;; 331e: 0e 01       ..
	jmp	bdos		;; 3320: c3 05 00    ...

lstque:	db	0,0,0,0,'MXList  '
waitms:	db	'WAITING FOR PRINTER',0dh,0ah,'$'
rdymsg:	db	'PRINTER READY',0dh,0ah,'$'

; space for temp list of symbols? LOCAL symbols - with translation
; hashed by 4-bit checksum of symbol->name (16 entries)
hash4:	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

; this memory may be used differently by diff modules
; (e.g. union {...})
L3375:	db	0	; index into L3376, L3386, L33a6, L33c6, L33e8
L3376:	db	0
L3377:	db	0
L3378:	db	0
L3379:	db	0
curhsh:	db	0,0	; current hash pointer (symbol being looked up)
prvsym:	db	0,0
; hash table for symbols, hashed by first char (symbol->name[0] - 'A'),
; with special handling for '@' and '?'.
symtab:	dw	0,0,0,0

; 16-entry hash table
L3386:	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
; 16-entry hash table
L33a6:	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
; 16-entry hash table
L33c6:	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

L33e6:	db	0,0

L33e8:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
; 16-entry hash table
L33f8:	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
L3418:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
L3428:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

L3438:	db	0
L3439:	db	0
L343a:	db	0	; token storage (len, chars...)
L343b:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

; staging buffer for PRN line
prnbuf:
curerr:	db	0	; error code
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

L34c3:	db	0
curctx:	db	0	; current parser context:
			; 0 =
			; 1 =
			; 2 =
			; 3 = quoted string?
			; 4 =
			; 5 =
			; 6 = comment
L34c5:	dw	0

tokbuf:	db	0	; current token/opcode (len, chrs...)
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0

L3508:	dw	0
L350a:	db	0
L350b:	db	0,0
L350d:	db	0,0
nxheap:	db	0,0	; next address to allocate from
memtop:	db	0,0	; end of TPA
L3513:	dw	0	; very short temp list of symbols
pass:	db	0	; assembler pass number (0/1)
curadr:	db	0,0	; prog addr where current byte is (to go)
; table of addresses, by segment (i.e. linadr[seg])
segtbl:
asgadr:	db	0,0	; aseg
csgadr:	db	0,0	; cseg
dsgadr:	db	0,0	; dseg
cmnadr:	db	0,0	; common?

curseg:	db	0
syheap:	db	0,0	; point to free mem for symbols
cursym:	db	0,0	; current symbol being examined
tmpptr:	db	0,0
L3527:	db	0
curchr:	db	0
L3529:	db	0
L352a:	db	0
Sflag:	db	0	; $[+-]S flag
Mflag:	db	0	; $[+-*]M flag (also statements)
L352d:	db	0,0
L352f:	db	0,0
Qflag:	db	0	; $[+-]Q flag
Lflag:	db	0	; $[+-]L flag
Pflag:	db	0	; $[+-*]P statements

	; ds 128
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0
stack:	ds	0

buffer:	; the rest of memory...
; end of program memory... free-form buffer space (heap) follows...
	db	1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah
	db	1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah
	db	1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah
	db	1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah
	db	1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah
	db	1ah
	end
