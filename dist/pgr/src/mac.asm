; Disassembly of MAC.COM

; ASCII non-printable characters
cr	equ	13
lf	equ	10
tab	equ	9
ff	equ	12
eof	equ	26
del	equ	127

; BDOS function numbers
conout	equ	2
lstout	equ	5
print	equ	9
seldsk	equ	14
open	equ	15
close	equ	16
delete	equ	19
read	equ	20
write	equ	21
make	equ	22
curdsk	equ	25
setdma	equ	26

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

	org	00100h
	jmp	L0128		;; 0100: c3 28 01    .(.

	db	' COPYRIGHT (C) 1977 DIGITAL RESEARCH '

L0128:	lxi	sp,stack	;; 0128: 31 00 31    1.1
	xra	a		;; 012b: af          .
	sta	pass		;; 012c: 32 4f 30    2O0
	sta	L305a		;; 012f: 32 5a 30    2Z0
	call	L2580		;; 0132: cd 80 25    ..%
	call	L1c03		;; 0135: cd 03 1c    ...
	lxi	h,0		;; 0138: 21 00 00    ...
	shld	L11d6		;; 013b: 22 d6 11    "..
L013e:	call	L1c4b		;; 013e: cd 4b 1c    .K.
	xra	a		;; 0141: af          .
	sta	L2ea3		;; 0142: 32 a3 2e    2..
	mvi	a,000h		;; 0145: 3e 00       >.
	sta	L2ea4		;; 0147: 32 a4 2e    2..
	lhld	memtop		;; 014a: 2a 4d 30    *M0
	shld	L2f24		;; 014d: 22 24 2f    "$/
	call	L1603		;; 0150: cd 03 16    ...
	call	L2583		;; 0153: cd 83 25    ..%
	lxi	h,0		;; 0156: 21 00 00    ...
	shld	L11c3		;; 0159: 22 c3 11    "..
	shld	L11de		;; 015c: 22 de 11    "..
	lda	Rflag		;; 015f: 3a 67 30    :g0
	ora	a		;; 0162: b7          .
	jz	L0169		;; 0163: ca 69 01    .i.
	lxi	h,256		;; 0166: 21 00 01    ...
L0169:	shld	curadr		;; 0169: 22 50 30    "P0
	shld	linadr		;; 016c: 22 52 30    "R0
	shld	L11c7		;; 016f: 22 c7 11    "..
	xra	a		;; 0172: af          .
	sta	L11cd		;; 0173: 32 cd 11    2..
L0176:	call	L1606		;; 0176: cd 06 16    ...
L0179:	lda	L3005		;; 0179: 3a 05 30    :.0
	cpi	002h		;; 017c: fe 02       ..
	jz	L0176		;; 017e: ca 76 01    .v.
	cpi	004h		;; 0181: fe 04       ..
	jnz	L01cb		;; 0183: c2 cb 01    ...
	lda	tokbuf+1		;; 0186: 3a 09 30    :.0
	cpi	'$'		;; 0189: fe 24       .$
	jnz	L0dd5		;; 018b: c2 d5 0d    ...
	call	L0eea		;; 018e: cd ea 0e    ...
	jnz	L0e20		;; 0191: c2 20 0e    . .
	lda	L305b		;; 0194: 3a 5b 30    :[0
	mvi	b,000h		;; 0197: 06 00       ..
	cpi	'-'		;; 0199: fe 2d       .-
	jz	L01ac		;; 019b: ca ac 01    ...
	mvi	b,003h		;; 019e: 06 03       ..
	cpi	'+'		;; 01a0: fe 2b       .+
	jz	L01ac		;; 01a2: ca ac 01    ...
	mvi	b,007h		;; 01a5: 06 07       ..
	cpi	'*'		;; 01a7: fe 2a       .*
	jnz	L0e20		;; 01a9: c2 20 0e    . .
L01ac:	push	b		;; 01ac: c5          .
	call	L1606		;; 01ad: cd 06 16    ...
	pop	b		;; 01b0: c1          .
	lda	L305b		;; 01b1: 3a 5b 30    :[0
	lxi	h,Mflag		;; 01b4: 21 5f 30    ._0
	cpi	'M'		;; 01b7: fe 4d       .M
	jz	L01c4		;; 01b9: ca c4 01    ...
	lxi	h,L3066		;; 01bc: 21 66 30    .f0
	cpi	'P'		;; 01bf: fe 50       .P
	jnz	L0e20		;; 01c1: c2 20 0e    . .
L01c4:	mov	m,b		;; 01c4: 70          p
	call	L1606		;; 01c5: cd 06 16    ...
	jmp	L0c09		;; 01c8: c3 09 0c    ...

L01cb:	cpi	001h		;; 01cb: fe 01       ..
	jnz	L0e20		;; 01cd: c2 20 0e    . .
	call	L2106		;; 01d0: cd 06 21    ...
	jz	L040d		;; 01d3: ca 0d 04    ...
	call	L1c06		;; 01d6: cd 06 1c    ...
	call	L1c09		;; 01d9: cd 09 1c    ...
	jnz	L01ec		;; 01dc: c2 ec 01    ...
	call	L1c0c		;; 01df: cd 0c 1c    ...
	lda	pass		;; 01e2: 3a 4f 30    :O0
	ora	a		;; 01e5: b7          .
	cnz	Perror		;; 01e6: c4 9c 11    ...
	jmp	L03e9		;; 01e9: c3 e9 03    ...

L01ec:	call	L1c12		;; 01ec: cd 12 1c    ...
	cpi	6		;; 01ef: fe 06       ..
	jnz	L03e9		;; 01f1: c2 e9 03    ...
	lxi	h,0		;; 01f4: 21 00 00    ...
	shld	L11e0		;; 01f7: 22 e0 11    "..
	lda	pass		;; 01fa: 3a 4f 30    :O0
	ora	a		;; 01fd: b7          .
	jz	L020f		;; 01fe: ca 0f 02    ...
L0201:	call	L1c18		;; 0201: cd 18 1c    ...
	xchg			;; 0204: eb          .
	lhld	cursym		;; 0205: 2a 56 30    *V0
	mov	a,l		;; 0208: 7d          }
	sub	e		;; 0209: 93          .
	mov	a,h		;; 020a: 7c          |
	sbb	d		;; 020b: 9a          .
	jc	L023c		;; 020c: da 3c 02    .<.
L020f:	call	L0272		;; 020f: cd 72 02    .r.
	call	L160c		;; 0212: cd 0c 16    ...
	call	L02aa		;; 0215: cd aa 02    ...
	jnz	L02c1		;; 0218: c2 c1 02    ...
	lhld	L11c3		;; 021b: 2a c3 11    *..
	mov	a,h		;; 021e: 7c          |
	ora	l		;; 021f: b5          .
	cnz	Serror		;; 0220: c4 b4 11    ...
	lda	pass		;; 0223: 3a 4f 30    :O0
	ora	a		;; 0226: b7          .
	jnz	L025f		;; 0227: c2 5f 02    ._.
	call	L0291		;; 022a: cd 91 02    ...
	call	L1c48		;; 022d: cd 48 1c    .H.
	call	L1c0c		;; 0230: cd 0c 1c    ...
	lhld	cursym		;; 0233: 2a 56 30    *V0
	shld	L11c3		;; 0236: 22 c3 11    "..
	jmp	pMACRO		;; 0239: c3 99 06    ...

L023c:	lhld	cursym		;; 023c: 2a 56 30    *V0
	shld	L11e0		;; 023f: 22 e0 11    "..
	call	L1c45		;; 0242: cd 45 1c    .E.
	call	L1c09		;; 0245: cd 09 1c    ...
	jz	L0256		;; 0248: ca 56 02    .V.
	call	L1c12		;; 024b: cd 12 1c    ...
	cpi	6		;; 024e: fe 06       ..
	jnz	L02bb		;; 0250: c2 bb 02    ...
	jmp	L0201		;; 0253: c3 01 02    ...

L0256:	call	L160c		;; 0256: cd 0c 16    ...
	call	L02aa		;; 0259: cd aa 02    ...
	jnz	L02bb		;; 025c: c2 bb 02    ...
L025f:	lhld	L11e0		;; 025f: 2a e0 11    *..
	xchg			;; 0262: eb          .
	lhld	L11d8		;; 0263: 2a d8 11    *..
	call	compr1		;; 0266: cd dd 0e    ...
	jnz	L02bb		;; 0269: c2 bb 02    ...
	shld	L11c3		;; 026c: 22 c3 11    "..
	jmp	pMACRO		;; 026f: c3 99 06    ...

; copy name (tokbuf) onto heap (struct symbol.name[0])
L0272:	lhld	nxheap		;; 0272: 2a 4b 30    *K0
	push	h		;; 0275: e5          .
	shld	L3058		;; 0276: 22 58 30    "X0
	lxi	h,tokbuf		;; 0279: 21 08 30    ..0
	mov	c,m		;; 027c: 4e          N
	mov	b,c		;; 027d: 41          A
L027e:	inx	h		;; 027e: 23          #
	mov	a,m		;; 027f: 7e          ~
	push	b		;; 0280: c5          .
	push	h		;; 0281: e5          .
	call	L1c27		;; 0282: cd 27 1c    .'.
	pop	h		;; 0285: e1          .
	pop	b		;; 0286: c1          .
	dcr	c		;; 0287: 0d          .
	jnz	L027e		;; 0288: c2 7e 02    .~.
	pop	h		;; 028b: e1          .
	mov	m,b		;; 028c: 70          p
	shld	nxheap		;; 028d: 22 4b 30    "K0
	ret			;; 0290: c9          .

; copy name out of heap (symbol.name) into tokbuf
L0291:	lhld	nxheap		;; 0291: 2a 4b 30    *K0
	mov	c,m		;; 0294: 4e          N
	shld	L3058		;; 0295: 22 58 30    "X0
	lxi	h,tokbuf		;; 0298: 21 08 30    ..0
	mov	m,c		;; 029b: 71          q
L029c:	inx	h		;; 029c: 23          #
	push	b		;; 029d: c5          .
	push	h		;; 029e: e5          .
	call	L1c2a		;; 029f: cd 2a 1c    .*.
	pop	h		;; 02a2: e1          .
	pop	b		;; 02a3: c1          .
	mov	m,a		;; 02a4: 77          w
	dcr	c		;; 02a5: 0d          .
	jnz	L029c		;; 02a6: c2 9c 02    ...
	ret			;; 02a9: c9          .

L02aa:	lda	L3005		;; 02aa: 3a 05 30    :.0
	cpi	005h		;; 02ad: fe 05       ..
	rnz			;; 02af: c0          .
	call	L2106		;; 02b0: cd 06 21    ...
	rnz			;; 02b3: c0          .
	cpi	eof		;; 02b4: fe 1a       ..
	rnz			;; 02b6: c0          .
	mov	a,b		;; 02b7: 78          x
	cpi	tab		;; 02b8: fe 09       ..
	ret			;; 02ba: c9          .

L02bb:	call	Perror		;; 02bb: cd 9c 11    ...
	jmp	L0dd5		;; 02be: c3 d5 0d    ...

L02c1:	lhld	cursym		;; 02c1: 2a 56 30    *V0
	push	h		;; 02c4: e5          .
	call	L0ef4		;; 02c5: cd f4 0e    ...
	lhld	linadr		;; 02c8: 2a 52 30    *R0
	lda	Mflag		;; 02cb: 3a 5f 30    :_0
	ora	a		;; 02ce: b7          .
	cz	prnadr		;; 02cf: cc 8d 0f    ...
	pop	h		;; 02d2: e1          .
	shld	cursym		;; 02d3: 22 56 30    "V0
	call	L1c1e		;; 02d6: cd 1e 1c    ...
	sta	L11c2		;; 02d9: 32 c2 11    2..
	lhld	memtop		;; 02dc: 2a 4d 30    *M0
	push	h		;; 02df: e5          .
	ora	a		;; 02e0: b7          .
	jz	L0372		;; 02e1: ca 72 03    .r.
	jmp	L0300		;; 02e4: c3 00 03    ...

L02e7:	cpi	';'		;; 02e7: fe 3b       .;
	rz			;; 02e9: c8          .
	cpi	cr		;; 02ea: fe 0d       ..
	rz			;; 02ec: c8          .
L02ed:	cpi	lf		;; 02ed: fe 0a       ..
	rz			;; 02ef: c8          .
	cpi	eof		;; 02f0: fe 1a       ..
	rz			;; 02f2: c8          .
	cpi	'!'		;; 02f3: fe 21       ..
	ret			;; 02f5: c9          .

L02f6:	lda	L11c2		;; 02f6: 3a c2 11    :..
	ora	a		;; 02f9: b7          .
	jz	L0372		;; 02fa: ca 72 03    .r.
	call	L160c		;; 02fd: cd 0c 16    ...
L0300:	lda	L3005		;; 0300: 3a 05 30    :.0
	cpi	004h		;; 0303: fe 04       ..
	jnz	L0346		;; 0305: c2 46 03    .F.
	lda	tokbuf+1		;; 0308: 3a 09 30    :.0
	call	L02e7		;; 030b: cd e7 02    ...
	jz	L0365		;; 030e: ca 65 03    .e.
	cpi	'%'		;; 0311: fe 25       .%
	jnz	L033b		;; 0313: c2 3b 03    .;.
	call	L0d6d		;; 0316: cd 6d 0d    .m.
	shld	L11dc		;; 0319: 22 dc 11    "..
	mvi	a,0ffh		;; 031c: 3e ff       >.
	sta	L11db		;; 031e: 32 db 11    2..
	lda	L3005		;; 0321: 3a 05 30    :.0
	cpi	004h		;; 0324: fe 04       ..
	jnz	L0362		;; 0326: c2 62 03    .b.
	lda	tokbuf+1		;; 0329: 3a 09 30    :.0
	push	psw		;; 032c: f5          .
	xra	a		;; 032d: af          .
	sta	tokbuf		;; 032e: 32 08 30    2.0
	call	L0d0e		;; 0331: cd 0e 0d    ...
	call	L03db		;; 0334: cd db 03    ...
	pop	psw		;; 0337: f1          .
	jmp	L0357		;; 0338: c3 57 03    .W.

L033b:	cpi	','		;; 033b: fe 2c       .,
	jnz	L0346		;; 033d: c2 46 03    .F.
	call	L03d7		;; 0340: cd d7 03    ...
	jmp	L02f6		;; 0343: c3 f6 02    ...

L0346:	call	L03db		;; 0346: cd db 03    ...
	call	L1606		;; 0349: cd 06 16    ...
	lda	L3005		;; 034c: 3a 05 30    :.0
	cpi	004h		;; 034f: fe 04       ..
	jnz	L0362		;; 0351: c2 62 03    .b.
	lda	tokbuf+1		;; 0354: 3a 09 30    :.0
L0357:	call	L02e7		;; 0357: cd e7 02    ...
	jz	L0365		;; 035a: ca 65 03    .e.
	cpi	','		;; 035d: fe 2c       .,
	jz	L02f6		;; 035f: ca f6 02    ...
L0362:	call	Serror		;; 0362: cd b4 11    ...
L0365:	lda	L11c2		;; 0365: 3a c2 11    :..
	ora	a		;; 0368: b7          .
	jz	L0372		;; 0369: ca 72 03    .r.
	call	L03d7		;; 036c: cd d7 03    ...
	jmp	L0365		;; 036f: c3 65 03    .e.

L0372:	lhld	L3058		;; 0372: 2a 58 30    *X0
	inx	h		;; 0375: 23          #
	push	h		;; 0376: e5          .
L0377:	lxi	h,L305b		;; 0377: 21 5b 30    .[0
	mov	a,m		;; 037a: 7e          ~
	call	L02ed		;; 037b: cd ed 02    ...
	jz	L0387		;; 037e: ca 87 03    ...
	call	L1606		;; 0381: cd 06 16    ...
	jmp	L0377		;; 0384: c3 77 03    .w.

L0387:	xra	a		;; 0387: af          .
	mov	m,a		;; 0388: 77          w
	sta	L2f14		;; 0389: 32 14 2f    2./
	call	L03ac		;; 038c: cd ac 03    ...
	lda	L11cd		;; 038f: 3a cd 11    :..
	sta	L2f54		;; 0392: 32 54 2f    2T/
	call	L1c2d		;; 0395: cd 2d 1c    .-.
	pop	h		;; 0398: e1          .
	shld	L2ef4		;; 0399: 22 f4 2e    "..
	pop	h		;; 039c: e1          .
	shld	L2f24		;; 039d: 22 24 2f    "$/
	xra	a		;; 03a0: af          .
	sta	L2f14		;; 03a1: 32 14 2f    2./
	mvi	a,001h		;; 03a4: 3e 01       >.
	sta	L2ea4		;; 03a6: 32 a4 2e    2..
	jmp	L0176		;; 03a9: c3 76 01    .v.

L03ac:	lda	L2ea3		;; 03ac: 3a a3 2e    :..
	ora	a		;; 03af: b7          .
	jz	L03b8		;; 03b0: ca b8 03    ...
	lxi	h,prnbuf+5	;; 03b3: 21 91 2f    ../
	mvi	m,'+'		;; 03b6: 36 2b       6+
L03b8:	call	L2595		;; 03b8: cd 95 25    ..%
	mvi	a,010h		;; 03bb: 3e 10       >.
	sta	L3004		;; 03bd: 32 04 30    2.0
	ret			;; 03c0: c9          .

L03c1:	lda	L2ea3		;; 03c1: 3a a3 2e    :..
	ora	a		;; 03c4: b7          .
	jz	Berror		;; 03c5: ca ae 11    ...
	lda	L2ea4		;; 03c8: 3a a4 2e    :..
	cpi	003h		;; 03cb: fe 03       ..
	rnc			;; 03cd: d0          .
	cpi	001h		;; 03ce: fe 01       ..
	rz			;; 03d0: c8          .
	call	L1c30		;; 03d1: cd 30 1c    .0.
	jmp	L03c1		;; 03d4: c3 c1 03    ...

L03d7:	xra	a		;; 03d7: af          .
	sta	tokbuf		;; 03d8: 32 08 30    2.0
L03db:	call	L1c39		;; 03db: cd 39 1c    .9.
	call	L1c24		;; 03de: cd 24 1c    .$.
	call	L1c3c		;; 03e1: cd 3c 1c    .<.
	lxi	h,L11c2		;; 03e4: 21 c2 11    ...
	dcr	m		;; 03e7: 35          5
	ret			;; 03e8: c9          .

L03e9:	lhld	L11c3		;; 03e9: 2a c3 11    *..
	mov	a,l		;; 03ec: 7d          }
	ora	h		;; 03ed: b4          .
	cnz	Lerror		;; 03ee: c4 a2 11    ...
	lhld	cursym		;; 03f1: 2a 56 30    *V0
	shld	L11c3		;; 03f4: 22 c3 11    "..
	call	L1606		;; 03f7: cd 06 16    ...
	lda	L3005		;; 03fa: 3a 05 30    :.0
	cpi	004h		;; 03fd: fe 04       ..
	jnz	L0179		;; 03ff: c2 79 01    .y.
	lda	tokbuf+1		;; 0402: 3a 09 30    :.0
	cpi	':'		;; 0405: fe 3a       .:
	jnz	L0179		;; 0407: c2 79 01    .y.
	jmp	L0176		;; 040a: c3 76 01    .v.

L040d:	cpi	01ah		;; 040d: fe 1a       ..
	jnz	L0c21		;; 040f: c2 21 0c    ...
	; pseudo-ops... B is index
	mov	e,b		;; 0412: 58          X
	mvi	d,0		;; 0413: 16 00       ..
	dcx	d		;; 0415: 1b          .
	lxi	h,poptbl	;; 0416: 21 20 04    . .
	dad	d		;; 0419: 19          .
	dad	d		;; 041a: 19          .
	mov	e,m		;; 041b: 5e          ^
	inx	h		;; 041c: 23          #
	mov	h,m		;; 041d: 66          f
	mov	l,e		;; 041e: 6b          k
	pchl			;; 041f: e9          .

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
	dw	pASEG	; 17 - not supported
	dw	pCSEG	; 18 CSEG - not supported
	dw	pDSEG	; 19 DSEG - not supported
	dw	pNAME	; 20 NAME - not supported
	dw	pPAGE	; 21 PAGE
	dw	pEXITM	; 22 EXITM
	dw	pEXTRN	; 23 EXTRN - not supported
	dw	pLOCAL	; 24 LOCAL
	dw	pNPAGE	; 25 INPAGE - not supported
	dw	pMACLI	; 26 MACLIB
	dw	pPUBLI	; 27 PUBLIC - not supported
	dw	pSTKLN	; 28 STKLN - not supported

pDB:	call	L0ef4		;; 0458: cd f4 0e    ...
L045b:	call	L1606		;; 045b: cd 06 16    ...
	lda	L3005		;; 045e: 3a 05 30    :.0
	cpi	003h		;; 0461: fe 03       ..
	jnz	L0489		;; 0463: c2 89 04    ...
	lda	tokbuf		;; 0466: 3a 08 30    :.0
	dcr	a		;; 0469: 3d          =
	jz	L0489		;; 046a: ca 89 04    ...
	mov	b,a		;; 046d: 47          G
	inr	b		;; 046e: 04          .
	inr	b		;; 046f: 04          .
	lxi	h,tokbuf+1		;; 0470: 21 09 30    ..0
L0473:	dcr	b		;; 0473: 05          .
	jz	L0483		;; 0474: ca 83 04    ...
	push	b		;; 0477: c5          .
	mov	b,m		;; 0478: 46          F
	inx	h		;; 0479: 23          #
	push	h		;; 047a: e5          .
	call	asmbyt		;; 047b: cd 32 0f    .2.
	pop	h		;; 047e: e1          .
	pop	b		;; 047f: c1          .
	jmp	L0473		;; 0480: c3 73 04    .s.

L0483:	call	L1606		;; 0483: cd 06 16    ...
	jmp	L0496		;; 0486: c3 96 04    ...

L0489:	call	L1203		;; 0489: cd 03 12    ...
	lhld	L3049		;; 048c: 2a 49 30    *I0
	call	chkbyh		;; 048f: cd 7c 0d    .|.
	mov	b,l		;; 0492: 45          E
	call	asmbyt		;; 0493: cd 32 0f    .2.
L0496:	call	synadr		;; 0496: cd e3 0e    ...
	call	L0d56		;; 0499: cd 56 0d    .V.
	cpi	','		;; 049c: fe 2c       .,
	jz	L045b		;; 049e: ca 5b 04    .[.
	jmp	L0dd5		;; 04a1: c3 d5 0d    ...

pDS:	call	L0ef4		;; 04a4: cd f4 0e    ...
	call	prnbeg		;; 04a7: cd 8a 0f    ...
	call	L0d6d		;; 04aa: cd 6d 0d    .m.
	xchg			;; 04ad: eb          .
	lhld	linadr		;; 04ae: 2a 52 30    *R0
	dad	d		;; 04b1: 19          .
	shld	linadr		;; 04b2: 22 52 30    "R0
	shld	curadr		;; 04b5: 22 50 30    "P0
	jmp	L0dd5		;; 04b8: c3 d5 0d    ...

pDW:	call	L0ef4		;; 04bb: cd f4 0e    ...
L04be:	call	L0d6d		;; 04be: cd 6d 0d    .m.
	push	h		;; 04c1: e5          .
	mov	b,l		;; 04c2: 45          E
	call	asmbyt		;; 04c3: cd 32 0f    .2.
	pop	h		;; 04c6: e1          .
	mov	b,h		;; 04c7: 44          D
	call	asmbyt		;; 04c8: cd 32 0f    .2.
	call	synadr		;; 04cb: cd e3 0e    ...
	call	L0d56		;; 04ce: cd 56 0d    .V.
	cpi	','		;; 04d1: fe 2c       .,
	jz	L04be		;; 04d3: ca be 04    ...
	jmp	L0dd5		;; 04d6: c3 d5 0d    ...

pEND:	call	L0ef4		;; 04d9: cd f4 0e    ...
	call	prnbeg		;; 04dc: cd 8a 0f    ...
	lda	curerr		;; 04df: 3a 8c 2f    :./
	cpi	' '		;; 04e2: fe 20       . 
	jnz	L0dd5		;; 04e4: c2 d5 0d    ...
	call	L0d6d		;; 04e7: cd 6d 0d    .m.
	lda	curerr		;; 04ea: 3a 8c 2f    :./
	cpi	' '		;; 04ed: fe 20       . 
	jnz	L04f5		;; 04ef: c2 f5 04    ...
	shld	L11c7		;; 04f2: 22 c7 11    "..
L04f5:	mvi	a,' '		;; 04f5: 3e 20       > 
	sta	curerr		;; 04f7: 32 8c 2f    2./
	lda	L11cd		;; 04fa: 3a cd 11    :..
	ora	a		;; 04fd: b7          .
	cnz	Berror		;; 04fe: c4 ae 11    ...
	call	L1606		;; 0501: cd 06 16    ...
	lda	L3005		;; 0504: 3a 05 30    :.0
	cpi	004h		;; 0507: fe 04       ..
	jnz	L0e20		;; 0509: c2 20 0e    . .
	lda	tokbuf+1		;; 050c: 3a 09 30    :.0
	cpi	lf		;; 050f: fe 0a       ..
	jnz	L0e20		;; 0511: c2 20 0e    . .
	jmp	L0e2d		;; 0514: c3 2d 0e    .-.

pENDIF:	call	L0ef4		;; 0517: cd f4 0e    ...
	call	L09b2		;; 051a: cd b2 09    ...
	jmp	L0c09		;; 051d: c3 09 0c    ...

pENDM:	push	b		;; 0520: c5          .
	call	L0ef4		;; 0521: cd f4 0e    ...
	call	L03c1		;; 0524: cd c1 03    ...
	lxi	h,prnbuf+5	;; 0527: 21 91 2f    ../
	mvi	m,'+'		;; 052a: 36 2b       6+
	lda	L2ea4		;; 052c: 3a a4 2e    :..
	cpi	003h		;; 052f: fe 03       ..
	jnc	L053b		;; 0531: d2 3b 05    .;.
	pop	b		;; 0534: c1          .
	call	L1c3f		;; 0535: cd 3f 1c    .?.
	jmp	L0616		;; 0538: c3 16 06    ...

L053b:	lhld	L2f24		;; 053b: 2a 24 2f    *$/
	push	h		;; 053e: e5          .
	lhld	L2eb4		;; 053f: 2a b4 2e    *..
	shld	L2f24		;; 0542: 22 24 2f    "$/
	call	L1c3f		;; 0545: cd 3f 1c    .?.
	pop	h		;; 0548: e1          .
	shld	L2f24		;; 0549: 22 24 2f    "$/
	pop	psw		;; 054c: f1          .
	cpi	6		;; 054d: fe 06       ..
	jnz	L0616		;; 054f: c2 16 06    ...
L0552:	lda	L2ea4		;; 0552: 3a a4 2e    :..
	cpi	6		;; 0555: fe 06       ..
	jnz	L056c		;; 0557: c2 6c 05    .l.
	lhld	L2eb4		;; 055a: 2a b4 2e    *..
	mov	e,m		;; 055d: 5e          ^
	inx	h		;; 055e: 23          #
	mov	d,m		;; 055f: 56          V
	mov	a,e		;; 0560: 7b          {
	ora	d		;; 0561: b2          .
	jz	L0616		;; 0562: ca 16 06    ...
	dcx	d		;; 0565: 1b          .
	mov	m,d		;; 0566: 72          r
	dcx	h		;; 0567: 2b          +
	mov	m,e		;; 0568: 73          s
	jmp	L0635		;; 0569: c3 35 06    .5.

L056c:	lhld	L2eb4		;; 056c: 2a b4 2e    *..
	mov	e,m		;; 056f: 5e          ^
	inx	h		;; 0570: 23          #
	mov	d,m		;; 0571: 56          V
	ldax	d		;; 0572: 1a          .
	cpi	cr		;; 0573: fe 0d       ..
	jz	L0616		;; 0575: ca 16 06    ...
	ora	a		;; 0578: b7          .
	jz	L0593		;; 0579: ca 93 05    ...
	lda	L2ea4		;; 057c: 3a a4 2e    :..
	cpi	003h		;; 057f: fe 03       ..
	jnz	L05a0		;; 0581: c2 a0 05    ...
	ldax	d		;; 0584: 1a          .
	inx	d		;; 0585: 13          .
	mov	m,d		;; 0586: 72          r
	dcx	h		;; 0587: 2b          +
	mov	m,e		;; 0588: 73          s
	lxi	h,tokbuf		;; 0589: 21 08 30    ..0
	mvi	m,001h		;; 058c: 36 01       6.
	inx	h		;; 058e: 23          #
	mov	m,a		;; 058f: 77          w
	jmp	L059a		;; 0590: c3 9a 05    ...

L0593:	mvi	a,cr		;; 0593: 3e 0d       >.
	stax	d		;; 0595: 12          .
	xra	a		;; 0596: af          .
	sta	tokbuf		;; 0597: 32 08 30    2.0
L059a:	call	L1c39		;; 059a: cd 39 1c    .9.
	jmp	L0606		;; 059d: c3 06 06    ...

L05a0:	lxi	h,L2f65		;; 05a0: 21 65 2f    .e/
	mov	a,m		;; 05a3: 7e          ~
	push	psw		;; 05a4: f5          .
	mvi	m,000h		;; 05a5: 36 00       6.
	lxi	h,L305b		;; 05a7: 21 5b 30    .[0
	mov	a,m		;; 05aa: 7e          ~
	push	psw		;; 05ab: f5          .
	mvi	m,000h		;; 05ac: 36 00       6.
	xchg			;; 05ae: eb          .
	shld	L2ef4		;; 05af: 22 f4 2e    "..
	mov	a,m		;; 05b2: 7e          ~
	sui	','		;; 05b3: d6 2c       .,
	jnz	L05c5		;; 05b5: c2 c5 05    ...
	inx	h		;; 05b8: 23          #
	push	h		;; 05b9: e5          .
	lxi	h,tokbuf		;; 05ba: 21 08 30    ..0
	mov	m,a		;; 05bd: 77          w
	call	L1c39		;; 05be: cd 39 1c    .9.
	pop	h		;; 05c1: e1          .
	jmp	L05f0		;; 05c2: c3 f0 05    ...

L05c5:	push	h		;; 05c5: e5          .
	call	L160c		;; 05c6: cd 0c 16    ...
	pop	d		;; 05c9: d1          .
	call	L11e4		;; 05ca: cd e4 11    ...
	jmp	L05d0		;; 05cd: c3 d0 05    ...

L05d0:	call	L1c39		;; 05d0: cd 39 1c    .9.
	lhld	L2ef4		;; 05d3: 2a f4 2e    *..
	mov	a,m		;; 05d6: 7e          ~
	ora	a		;; 05d7: b7          .
	jnz	L05e0		;; 05d8: c2 e0 05    ...
	mvi	m,cr		;; 05db: 36 0d       6.
	jmp	L05f7		;; 05dd: c3 f7 05    ...

L05e0:	lhld	L11e2		;; 05e0: 2a e2 11    *..
	push	h		;; 05e3: e5          .
	call	L1606		;; 05e4: cd 06 16    ...
	lda	tokbuf+1		;; 05e7: 3a 09 30    :.0
	cpi	','		;; 05ea: fe 2c       .,
	cnz	Serror		;; 05ec: c4 b4 11    ...
	pop	h		;; 05ef: e1          .
L05f0:	call	L11ee		;; 05f0: cd ee 11    ...
	xra	a		;; 05f3: af          .
	sta	L2f66		;; 05f4: 32 66 2f    2f/
L05f7:	xchg			;; 05f7: eb          .
	lhld	L2eb4		;; 05f8: 2a b4 2e    *..
	mov	m,e		;; 05fb: 73          s
	inx	h		;; 05fc: 23          #
	mov	m,d		;; 05fd: 72          r
	pop	psw		;; 05fe: f1          .
	sta	L305b		;; 05ff: 32 5b 30    2[0
	pop	psw		;; 0602: f1          .
	sta	L2f65		;; 0603: 32 65 2f    2e/
L0606:	lhld	L2eb4		;; 0606: 2a b4 2e    *..
	inx	h		;; 0609: 23          #
	shld	L3058		;; 060a: 22 58 30    "X0
	call	L1c24		;; 060d: cd 24 1c    .$.
	call	L1c3c		;; 0610: cd 3c 1c    .<.
	jmp	L0635		;; 0613: c3 35 06    .5.

L0616:	call	L03ac		;; 0616: cd ac 03    ...
	lhld	L2f24		;; 0619: 2a 24 2f    *$/
	shld	memtop		;; 061c: 22 4d 30    "M0
	call	L1c30		;; 061f: cd 30 1c    .0.
	lda	L2f54		;; 0622: 3a 54 2f    :T/
	sta	L11cd		;; 0625: 32 cd 11    2..
	lda	L2f14		;; 0628: 3a 14 2f    :./
	sta	L305b		;; 062b: 32 5b 30    2[0
	ora	a		;; 062e: b7          .
	cnz	L1609		;; 062f: c4 09 16    ...
	jmp	L0176		;; 0632: c3 76 01    .v.

L0635:	mvi	a,010h		;; 0635: 3e 10       >.
	sta	L3004		;; 0637: 32 04 30    2.0
	lhld	L2ed4		;; 063a: 2a d4 2e    *..
	shld	L2ef4		;; 063d: 22 f4 2e    "..
	xra	a		;; 0640: af          .
	sta	L305b		;; 0641: 32 5b 30    2[0
	jmp	L0176		;; 0644: c3 76 01    .v.

L0647:	push	psw		;; 0647: f5          .
	lhld	linadr		;; 0648: 2a 52 30    *R0
	push	h		;; 064b: e5          .
	call	L0d6d		;; 064c: cd 6d 0d    .m.
	shld	linadr		;; 064f: 22 52 30    "R0
	call	prnadr		;; 0652: cd 8d 0f    ...
	pop	h		;; 0655: e1          .
	shld	linadr		;; 0656: 22 52 30    "R0
	pop	psw		;; 0659: f1          .
	lxi	h,prnbuf+6	;; 065a: 21 92 2f    ../
	mov	m,a		;; 065d: 77          w
	ret			;; 065e: c9          .

pEQU:	call	L0eea		;; 065f: cd ea 0e    ...
	jz	L0e20		;; 0662: ca 20 0e    . .
	mvi	a,'='		;; 0665: 3e 3d       >=
	call	L0647		;; 0667: cd 47 06    .G.
	lhld	linadr		;; 066a: 2a 52 30    *R0
	push	h		;; 066d: e5          .
	lhld	L3049		;; 066e: 2a 49 30    *I0
	shld	linadr		;; 0671: 22 52 30    "R0
	call	L0ef4		;; 0674: cd f4 0e    ...
	pop	h		;; 0677: e1          .
	shld	linadr		;; 0678: 22 52 30    "R0
	jmp	L0dd5		;; 067b: c3 d5 0d    ...

pIF:	call	L0ef4		;; 067e: cd f4 0e    ...
	call	L0d6d		;; 0681: cd 6d 0d    .m.
	lda	curerr		;; 0684: 3a 8c 2f    :./
	cpi	' '		;; 0687: fe 20       . 
	jnz	L08c1		;; 0689: c2 c1 08    ...
	mov	a,l		;; 068c: 7d          }
	rar			;; 068d: 1f          .
	mvi	a,001h		;; 068e: 3e 01       >.
	jnc	L08c1		;; 0690: d2 c1 08    ...
	call	L099e		;; 0693: cd 9e 09    ...
	jmp	L0dd5		;; 0696: c3 d5 0d    ...

pMACRO:	call	L0eea		;; 0699: cd ea 0e    ...
	jnz	L06a5		;; 069c: c2 a5 06    ...
	call	Lerror		;; 069f: cd a2 11    ...
	jmp	L0dd5		;; 06a2: c3 d5 0d    ...

L06a5:	lda	pass		;; 06a5: 3a 4f 30    :O0
	ora	a		;; 06a8: b7          .
	jz	L06c8		;; 06a9: ca c8 06    ...
	lhld	cursym		;; 06ac: 2a 56 30    *V0
	xchg			;; 06af: eb          .
	lhld	L11d8		;; 06b0: 2a d8 11    *..
	call	compr1		;; 06b3: cd dd 0e    ...
	jz	L06bf		;; 06b6: ca bf 06    ...
	call	Perror		;; 06b9: cd 9c 11    ...
	jmp	L06cd		;; 06bc: c3 cd 06    ...

L06bf:	call	L1c18		;; 06bf: cd 18 1c    ...
	shld	L11d8		;; 06c2: 22 d8 11    "..
	jmp	L06cd		;; 06c5: c3 cd 06    ...

L06c8:	mvi	a,6		;; 06c8: 3e 06       >.
	call	L1c0f		;; 06ca: cd 0f 1c    ...
L06cd:	xra	a		;; 06cd: af          .
	sta	L11da		;; 06ce: 32 da 11    2..
	lda	pass		;; 06d1: 3a 4f 30    :O0
	ora	a		;; 06d4: b7          .
	cz	L1c1b		;; 06d5: cc 1b 1c    ...
L06d8:	call	L1606		;; 06d8: cd 06 16    ...
	lda	L3005		;; 06db: 3a 05 30    :.0
	cpi	001h		;; 06de: fe 01       ..
	jnz	L0701		;; 06e0: c2 01 07    ...
	lda	pass		;; 06e3: 3a 4f 30    :O0
	ora	a		;; 06e6: b7          .
	cz	L1c21		;; 06e7: cc 21 1c    ...
	lxi	h,L11da		;; 06ea: 21 da 11    ...
	inr	m		;; 06ed: 34          4
	call	L1606		;; 06ee: cd 06 16    ...
	lda	L3005		;; 06f1: 3a 05 30    :.0
	cpi	004h		;; 06f4: fe 04       ..
	jnz	L0701		;; 06f6: c2 01 07    ...
	lda	tokbuf+1		;; 06f9: 3a 09 30    :.0
	cpi	','		;; 06fc: fe 2c       .,
	jz	L06d8		;; 06fe: ca d8 06    ...
L0701:	mvi	a,001h		;; 0701: 3e 01       >.
	call	L0722		;; 0703: cd 22 07    .".
	jz	L0e34		;; 0706: ca 34 0e    .4.
	lda	pass		;; 0709: 3a 4f 30    :O0
	ora	a		;; 070c: b7          .
	lda	L11da		;; 070d: 3a da 11    :..
	cz	L1c1b		;; 0710: cc 1b 1c    ...
	jmp	L0c09		;; 0713: c3 09 0c    ...

L0716:	cpi	tab		;; 0716: fe 09       ..
	rz			;; 0718: c8          .
	cpi	010h		;; 0719: fe 10       ..
	rz			;; 071b: c8          .
	cpi	00eh		;; 071c: fe 0e       ..
	rz			;; 071e: c8          .
	cpi	00fh		;; 071f: fe 0f       ..
	ret			;; 0721: c9          .

L0722:	sta	L305c		;; 0722: 32 5c 30    2\0
L0725:	lda	L3005		;; 0725: 3a 05 30    :.0
	cpi	004h		;; 0728: fe 04       ..
	jnz	L073d		;; 072a: c2 3d 07    .=.
	lda	tokbuf+1		;; 072d: 3a 09 30    :.0
	cpi	cr		;; 0730: fe 0d       ..
	jz	L0746		;; 0732: ca 46 07    .F.
	cpi	'!'		;; 0735: fe 21       ..
	jz	L0746		;; 0737: ca 46 07    .F.
	cpi	eof		;; 073a: fe 1a       ..
	rz			;; 073c: c8          .
L073d:	call	Serror		;; 073d: cd b4 11    ...
	call	L1606		;; 0740: cd 06 16    ...
	jmp	L0725		;; 0743: c3 25 07    .%.

L0746:	lhld	L3058		;; 0746: 2a 58 30    *X0
	shld	L3060		;; 0749: 22 60 30    "`0
	mvi	a,001h		;; 074c: 3e 01       >.
	sta	L305a		;; 074e: 32 5a 30    2Z0
	call	L1606		;; 0751: cd 06 16    ...
L0754:	lhld	L3058		;; 0754: 2a 58 30    *X0
	shld	L11e0		;; 0757: 22 e0 11    "..
	call	L1606		;; 075a: cd 06 16    ...
	lda	L3005		;; 075d: 3a 05 30    :.0
	cpi	004h		;; 0760: fe 04       ..
	jnz	L076b		;; 0762: c2 6b 07    .k.
	lda	tokbuf+1		;; 0765: 3a 09 30    :.0
	cpi	eof		;; 0768: fe 1a       ..
	rz			;; 076a: c8          .
L076b:	cpi	001h		;; 076b: fe 01       ..
	jnz	L0754		;; 076d: c2 54 07    .T.
	call	L2106		;; 0770: cd 06 21    ...
	jnz	L0754		;; 0773: c2 54 07    .T.
	push	psw		;; 0776: f5          .
	lda	L305c		;; 0777: 3a 5c 30    :\0
	cpi	001h		;; 077a: fe 01       ..
	jnz	L07a6		;; 077c: c2 a6 07    ...
	lda	pass		;; 077f: 3a 4f 30    :O0
	ora	a		;; 0782: b7          .
	jnz	L07a6		;; 0783: c2 a6 07    ...
	lda	tokbuf		;; 0786: 3a 08 30    :.0
	dcr	a		;; 0789: 3d          =
	jz	L07a6		;; 078a: ca a6 07    ...
	dcr	c		;; 078d: 0d          .
	jz	L07a6		;; 078e: ca a6 07    ...
	push	b		;; 0791: c5          .
	lhld	L11e0		;; 0792: 2a e0 11    *..
	shld	L3058		;; 0795: 22 58 30    "X0
	call	L2109		;; 0798: cd 09 21    ...
	call	L1c27		;; 079b: cd 27 1c    .'.
	lda	L305b		;; 079e: 3a 5b 30    :[0
	ora	a		;; 07a1: b7          .
	cnz	L1c27		;; 07a2: c4 27 1c    .'.
	pop	b		;; 07a5: c1          .
L07a6:	pop	psw		;; 07a6: f1          .
	cpi	eof		;; 07a7: fe 1a       ..
	jnz	L0754		;; 07a9: c2 54 07    .T.
	mov	a,b		;; 07ac: 78          x
	call	L0716		;; 07ad: cd 16 07    ...
	jnz	L07bb		;; 07b0: c2 bb 07    ...
	lxi	h,L305a		;; 07b3: 21 5a 30    .Z0
	inr	m		;; 07b6: 34          4
	rz			;; 07b7: c8          .
	jmp	L0754		;; 07b8: c3 54 07    .T.

L07bb:	cpi	6		;; 07bb: fe 06       ..
	jnz	L0754		;; 07bd: c2 54 07    .T.
	lxi	h,L305a		;; 07c0: 21 5a 30    .Z0
	dcr	m		;; 07c3: 35          5
	jnz	L0754		;; 07c4: c2 54 07    .T.
	lda	L305c		;; 07c7: 3a 5c 30    :\0
	cpi	001h		;; 07ca: fe 01       ..
	jnz	L07f6		;; 07cc: c2 f6 07    ...
	lxi	h,0		;; 07cf: 21 00 00    ...
	shld	L11c3		;; 07d2: 22 c3 11    "..
	lda	L305d		;; 07d5: 3a 5d 30    :]0
	ora	a		;; 07d8: b7          .
	jz	L07e5		;; 07d9: ca e5 07    ...
	lxi	h,0		;; 07dc: 21 00 00    ...
	call	L1c15		;; 07df: cd 15 1c    ...
	jmp	L07f1		;; 07e2: c3 f1 07    ...

L07e5:	lhld	L11d6		;; 07e5: 2a d6 11    *..
	call	L1c15		;; 07e8: cd 15 1c    ...
	lhld	cursym		;; 07eb: 2a 56 30    *V0
	shld	L11d6		;; 07ee: 22 d6 11    "..
L07f1:	lda	pass		;; 07f1: 3a 4f 30    :O0
	ora	a		;; 07f4: b7          .
	rnz			;; 07f5: c0          .
L07f6:	lhld	L3058		;; 07f6: 2a 58 30    *X0
	mov	a,m		;; 07f9: 7e          ~
	cpi	cr		;; 07fa: fe 0d       ..
	cnz	Serror		;; 07fc: c4 b4 11    ...
	lhld	L3058		;; 07ff: 2a 58 30    *X0
	mvi	m,cr		;; 0802: 36 0d       6.
	xra	a		;; 0804: af          .
	call	L1c27		;; 0805: cd 27 1c    .'.
	xra	a		;; 0808: af          .
	inr	a		;; 0809: 3c          <
	ret			;; 080a: c9          .

pORG:	call	L0d6d		;; 080b: cd 6d 0d    .m.
	lda	curerr		;; 080e: 3a 8c 2f    :./
	cpi	' '		;; 0811: fe 20       . 
	jnz	L0dd5		;; 0813: c2 d5 0d    ...
	lda	Rflag		;; 0816: 3a 67 30    :g0
	ora	a		;; 0819: b7          .
	jz	L0821		;; 081a: ca 21 08    ...
	lxi	d,256		;; 081d: 11 00 01    ...
	dad	d		;; 0820: 19          .
L0821:	shld	linadr		;; 0821: 22 52 30    "R0
	shld	curadr		;; 0824: 22 50 30    "P0
	call	L0ef4		;; 0827: cd f4 0e    ...
	call	prnbeg		;; 082a: cd 8a 0f    ...
	jmp	L0dd5		;; 082d: c3 d5 0d    ...

pSET:	call	L0eea		;; 0830: cd ea 0e    ...
	jz	L0e20		;; 0833: ca 20 0e    . .
	call	L1c12		;; 0836: cd 12 1c    ...
	ora	a		;; 0839: b7          .
	jz	L0842		;; 083a: ca 42 08    .B.
	cpi	005h		;; 083d: fe 05       ..
	cnz	Lerror		;; 083f: c4 a2 11    ...
L0842:	mvi	a,005h		;; 0842: 3e 05       >.
	call	L1c0f		;; 0844: cd 0f 1c    ...
	mvi	a,'#'		;; 0847: 3e 23       >#
	call	L0647		;; 0849: cd 47 06    .G.
	call	L0eea		;; 084c: cd ea 0e    ...
	lhld	L3049		;; 084f: 2a 49 30    *I0
	call	L1c15		;; 0852: cd 15 1c    ...
	lxi	h,0		;; 0855: 21 00 00    ...
	shld	L11c3		;; 0858: 22 c3 11    "..
	jmp	L0dd5		;; 085b: c3 d5 0d    ...

pTITLE:	call	L0ef4		;; 085e: cd f4 0e    ...
	call	L1606		;; 0861: cd 06 16    ...
	lda	L3005		;; 0864: 3a 05 30    :.0
	cpi	003h		;; 0867: fe 03       ..
	jnz	L0e20		;; 0869: c2 20 0e    . .
	lda	L305a		;; 086c: 3a 5a 30    :Z0
	ora	a		;; 086f: b7          .
	jnz	L0e20		;; 0870: c2 20 0e    . .
	lxi	h,tokbuf		;; 0873: 21 08 30    ..0
	mov	c,m		;; 0876: 4e          N
	xchg			;; 0877: eb          .
	lhld	nxheap		;; 0878: 2a 4b 30    *K0
	lda	pass		;; 087b: 3a 4f 30    :O0
	ora	a		;; 087e: b7          .
	jnz	L089f		;; 087f: c2 9f 08    ...
	shld	L3062		;; 0882: 22 62 30    "b0
	dcx	h		;; 0885: 2b          +
	shld	L3058		;; 0886: 22 58 30    "X0
L0889:	mov	a,c		;; 0889: 79          y
	ora	a		;; 088a: b7          .
	jz	L089b		;; 088b: ca 9b 08    ...
	inx	d		;; 088e: 13          .
	ldax	d		;; 088f: 1a          .
	dcr	c		;; 0890: 0d          .
	push	d		;; 0891: d5          .
	push	b		;; 0892: c5          .
	call	L1c27		;; 0893: cd 27 1c    .'.
	pop	b		;; 0896: c1          .
	pop	d		;; 0897: d1          .
	jmp	L0889		;; 0898: c3 89 08    ...

L089b:	xra	a		;; 089b: af          .
	call	L1c27		;; 089c: cd 27 1c    .'.
L089f:	jmp	L0c09		;; 089f: c3 09 0c    ...

pELSE:	call	L0ef4		;; 08a2: cd f4 0e    ...
	call	L09b2		;; 08a5: cd b2 09    ...
	cpi	001h		;; 08a8: fe 01       ..
	mvi	a,002h		;; 08aa: 3e 02       >.
	jz	L08c1		;; 08ac: ca c1 08    ...
	call	Berror		;; 08af: cd ae 11    ...
	jmp	L0c09		;; 08b2: c3 09 0c    ...

L08b5:	cpi	tab		;; 08b5: fe 09       ..
	rz			;; 08b7: c8          .
	cpi	00eh		;; 08b8: fe 0e       ..
	rz			;; 08ba: c8          .
	cpi	00fh		;; 08bb: fe 0f       ..
	rz			;; 08bd: c8          .
	cpi	010h		;; 08be: fe 10       ..
	ret			;; 08c0: c9          .

L08c1:	sta	L11ca		;; 08c1: 32 ca 11    2..
	xra	a		;; 08c4: af          .
	sta	L11cb		;; 08c5: 32 cb 11    2..
	sta	L11cc		;; 08c8: 32 cc 11    2..
L08cb:	lda	L3005		;; 08cb: 3a 05 30    :.0
	cpi	004h		;; 08ce: fe 04       ..
	jnz	L08f1		;; 08d0: c2 f1 08    ...
	lda	tokbuf+1		;; 08d3: 3a 09 30    :.0
	cpi	cr		;; 08d6: fe 0d       ..
	jnz	L08e1		;; 08d8: c2 e1 08    ...
	call	L1606		;; 08db: cd 06 16    ...
	jmp	L08f7		;; 08de: c3 f7 08    ...

L08e1:	cpi	'!'		;; 08e1: fe 21       ..
	jz	L08f7		;; 08e3: ca f7 08    ...
	cpi	eof		;; 08e6: fe 1a       ..
	jnz	L08f1		;; 08e8: c2 f1 08    ...
	call	Berror		;; 08eb: cd ae 11    ...
	jmp	L0e2d		;; 08ee: c3 2d 0e    .-.

L08f1:	call	L1606		;; 08f1: cd 06 16    ...
	jmp	L08cb		;; 08f4: c3 cb 08    ...

L08f7:	call	L1606		;; 08f7: cd 06 16    ...
	lda	L3005		;; 08fa: 3a 05 30    :.0
	cpi	002h		;; 08fd: fe 02       ..
	cz	L1606		;; 08ff: cc 06 16    ...
	lda	L3005		;; 0902: 3a 05 30    :.0
	cpi	001h		;; 0905: fe 01       ..
	jnz	L08cb		;; 0907: c2 cb 08    ...
	call	L2106		;; 090a: cd 06 21    ...
	jz	L0934		;; 090d: ca 34 09    .4.
	call	L1606		;; 0910: cd 06 16    ...
	lda	L3005		;; 0913: 3a 05 30    :.0
	cpi	004h		;; 0916: fe 04       ..
	jnz	L0926		;; 0918: c2 26 09    .&.
	lda	tokbuf+1		;; 091b: 3a 09 30    :.0
	cpi	':'		;; 091e: fe 3a       .:
	jnz	L08cb		;; 0920: c2 cb 08    ...
	call	L1606		;; 0923: cd 06 16    ...
L0926:	lda	L3005		;; 0926: 3a 05 30    :.0
	cpi	001h		;; 0929: fe 01       ..
	jnz	L08cb		;; 092b: c2 cb 08    ...
	call	L2106		;; 092e: cd 06 21    ...
	jnz	L08cb		;; 0931: c2 cb 08    ...
L0934:	cpi	eof		;; 0934: fe 1a       ..
	jnz	L08cb		;; 0936: c2 cb 08    ...
	mov	a,b		;; 0939: 78          x
	cpi	008h		;; 093a: fe 08       ..
	jnz	L0949		;; 093c: c2 49 09    .I.
	lxi	h,L11cb		;; 093f: 21 cb 11    ...
	inr	m		;; 0942: 34          4
	cz	Oerror		;; 0943: cc a8 11    ...
	jmp	L08cb		;; 0946: c3 cb 08    ...

L0949:	cpi	cr		;; 0949: fe 0d       ..
	jnz	L0965		;; 094b: c2 65 09    .e.
	lda	L11cb		;; 094e: 3a cb 11    :..
	ora	a		;; 0951: b7          .
	jnz	L08cb		;; 0952: c2 cb 08    ...
	lda	L11ca		;; 0955: 3a ca 11    :..
	cpi	002h		;; 0958: fe 02       ..
	cz	Berror		;; 095a: cc ae 11    ...
	mvi	a,002h		;; 095d: 3e 02       >.
	call	L099e		;; 095f: cd 9e 09    ...
	jmp	L0c09		;; 0962: c3 09 0c    ...

L0965:	cpi	005h		;; 0965: fe 05       ..
	jnz	L097d		;; 0967: c2 7d 09    .}.
	lxi	h,L11cb		;; 096a: 21 cb 11    ...
	mov	a,m		;; 096d: 7e          ~
	dcr	m		;; 096e: 35          5
	ora	a		;; 096f: b7          .
	jnz	L08cb		;; 0970: c2 cb 08    ...
	lda	L11cc		;; 0973: 3a cc 11    :..
	ora	a		;; 0976: b7          .
	cnz	Berror		;; 0977: c4 ae 11    ...
	jmp	L0c09		;; 097a: c3 09 0c    ...

L097d:	call	L08b5		;; 097d: cd b5 08    ...
	jnz	L098d		;; 0980: c2 8d 09    ...
	lxi	h,L11cc		;; 0983: 21 cc 11    ...
	inr	m		;; 0986: 34          4
	cz	Oerror		;; 0987: cc a8 11    ...
	jmp	L08cb		;; 098a: c3 cb 08    ...

L098d:	cpi	6		;; 098d: fe 06       ..
	jnz	L08cb		;; 098f: c2 cb 08    ...
	lxi	h,L11cc		;; 0992: 21 cc 11    ...
	mov	a,m		;; 0995: 7e          ~
	dcr	m		;; 0996: 35          5
	ora	a		;; 0997: b7          .
	jnz	L08cb		;; 0998: c2 cb 08    ...
	jmp	pENDM		;; 099b: c3 20 05    . .

L099e:	mov	b,a		;; 099e: 47          G
	lxi	h,L11cd		;; 099f: 21 cd 11    ...
	mov	a,m		;; 09a2: 7e          ~
	cpi	008h		;; 09a3: fe 08       ..
	jnc	Oerror		;; 09a5: d2 a8 11    ...
	inr	m		;; 09a8: 34          4
	mov	e,a		;; 09a9: 5f          _
	mvi	d,0		;; 09aa: 16 00       ..
	lxi	h,L11ce		;; 09ac: 21 ce 11    ...
	dad	d		;; 09af: 19          .
	mov	m,b		;; 09b0: 70          p
	ret			;; 09b1: c9          .

L09b2:	lxi	h,L11cd		;; 09b2: 21 cd 11    ...
	mov	a,m		;; 09b5: 7e          ~
	ora	a		;; 09b6: b7          .
	jz	Berror		;; 09b7: ca ae 11    ...
	dcr	m		;; 09ba: 35          5
	mov	e,m		;; 09bb: 5e          ^
	mvi	d,0		;; 09bc: 16 00       ..
	lxi	h,L11ce		;; 09be: 21 ce 11    ...
	dad	d		;; 09c1: 19          .
	mov	a,m		;; 09c2: 7e          ~
	ret			;; 09c3: c9          .

pIRP:	mvi	a,005h		;; 09c4: 3e 05       >.
	jmp	L09cb		;; 09c6: c3 cb 09    ...

pIRPC:	mvi	a,003h		;; 09c9: 3e 03       >.
L09cb:	sta	L305c		;; 09cb: 32 5c 30    2\0
	call	L0ef4		;; 09ce: cd f4 0e    ...
	call	L1606		;; 09d1: cd 06 16    ...
	lda	L3005		;; 09d4: 3a 05 30    :.0
	cpi	001h		;; 09d7: fe 01       ..
	jnz	L0a4e		;; 09d9: c2 4e 0a    .N.
	lhld	nxheap		;; 09dc: 2a 4b 30    *K0
	shld	L11c5		;; 09df: 22 c5 11    "..
	dcx	h		;; 09e2: 2b          +
	shld	L3058		;; 09e3: 22 58 30    "X0
	lda	tokbuf		;; 09e6: 3a 08 30    :.0
	cpi	010h		;; 09e9: fe 10       ..
	jc	L09f0		;; 09eb: da f0 09    ...
	mvi	a,010h		;; 09ee: 3e 10       >.
L09f0:	adi	003h		;; 09f0: c6 03       ..
	call	L1c27		;; 09f2: cd 27 1c    .'.
	xra	a		;; 09f5: af          .
	call	L1c27		;; 09f6: cd 27 1c    .'.
	call	L1c21		;; 09f9: cd 21 1c    ...
	call	L1606		;; 09fc: cd 06 16    ...
	lda	L3005		;; 09ff: 3a 05 30    :.0
	cpi	004h		;; 0a02: fe 04       ..
	jnz	L0a4e		;; 0a04: c2 4e 0a    .N.
	lda	tokbuf+1		;; 0a07: 3a 09 30    :.0
	cpi	','		;; 0a0a: fe 2c       .,
	jnz	L0a4e		;; 0a0c: c2 4e 0a    .N.
	call	L160c		;; 0a0f: cd 0c 16    ...
	lda	tokbuf		;; 0a12: 3a 08 30    :.0
	ora	a		;; 0a15: b7          .
	jnz	L0a1f		;; 0a16: c2 1f 0a    ...
	call	L1606		;; 0a19: cd 06 16    ...
	jmp	L0a3e		;; 0a1c: c3 3e 0a    .>.

L0a1f:	call	L0c0f		;; 0a1f: cd 0f 0c    ...
	jz	L0a3e		;; 0a22: ca 3e 0a    .>.
	lxi	h,tokbuf		;; 0a25: 21 08 30    ..0
	mov	c,m		;; 0a28: 4e          N
L0a29:	inx	h		;; 0a29: 23          #
	mov	a,m		;; 0a2a: 7e          ~
	push	b		;; 0a2b: c5          .
	push	h		;; 0a2c: e5          .
	call	L1c27		;; 0a2d: cd 27 1c    .'.
	pop	h		;; 0a30: e1          .
	pop	b		;; 0a31: c1          .
	dcr	c		;; 0a32: 0d          .
	jnz	L0a29		;; 0a33: c2 29 0a    .).
	mvi	a,cr		;; 0a36: 3e 0d       >.
	call	L1c27		;; 0a38: cd 27 1c    .'.
	call	L1606		;; 0a3b: cd 06 16    ...
L0a3e:	xra	a		;; 0a3e: af          .
	call	L1c27		;; 0a3f: cd 27 1c    .'.
	lhld	nxheap		;; 0a42: 2a 4b 30    *K0
	shld	cursym		;; 0a45: 22 56 30    "V0
	lda	L305c		;; 0a48: 3a 5c 30    :\0
	jmp	L0a78		;; 0a4b: c3 78 0a    .x.

L0a4e:	call	Serror		;; 0a4e: cd b4 11    ...
	lda	L305c		;; 0a51: 3a 5c 30    :\0
	call	L0722		;; 0a54: cd 22 07    .".
	jmp	L0c09		;; 0a57: c3 09 0c    ...

pREPT:	call	L0d6d		;; 0a5a: cd 6d 0d    .m.
	push	h		;; 0a5d: e5          .
	mov	a,l		;; 0a5e: 7d          }
	lhld	nxheap		;; 0a5f: 2a 4b 30    *K0
	shld	L11c5		;; 0a62: 22 c5 11    "..
	dcx	h		;; 0a65: 2b          +
	shld	L3058		;; 0a66: 22 58 30    "X0
	call	L1c27		;; 0a69: cd 27 1c    .'.
	pop	psw		;; 0a6c: f1          .
	call	L1c27		;; 0a6d: cd 27 1c    .'.
	lhld	nxheap		;; 0a70: 2a 4b 30    *K0
	shld	cursym		;; 0a73: 22 56 30    "V0
	mvi	a,6		;; 0a76: 3e 06       >.
L0a78:	call	L0722		;; 0a78: cd 22 07    .".
	jz	L0e34		;; 0a7b: ca 34 0e    .4.
	call	L03ac		;; 0a7e: cd ac 03    ...
	call	L1606		;; 0a81: cd 06 16    ...
	lda	L11cd		;; 0a84: 3a cd 11    :..
	sta	L2f54		;; 0a87: 32 54 2f    2T/
	lda	L305b		;; 0a8a: 3a 5b 30    :[0
	cpi	lf		;; 0a8d: fe 0a       ..
	jnz	L0a93		;; 0a8f: c2 93 0a    ...
	xra	a		;; 0a92: af          .
L0a93:	sta	L2f14		;; 0a93: 32 14 2f    2./
	call	L1c2d		;; 0a96: cd 2d 1c    .-.
	lhld	memtop		;; 0a99: 2a 4d 30    *M0
	shld	L2f24		;; 0a9c: 22 24 2f    "$/
L0a9f:	lhld	L3058		;; 0a9f: 2a 58 30    *X0
	xchg			;; 0aa2: eb          .
	lxi	h,L11c5		;; 0aa3: 21 c5 11    ...
	mov	a,e		;; 0aa6: 7b          {
	sub	m		;; 0aa7: 96          .
	inx	h		;; 0aa8: 23          #
	mov	a,d		;; 0aa9: 7a          z
	sbb	m		;; 0aaa: 9e          .
	xchg			;; 0aab: eb          .
	jc	L0abf		;; 0aac: da bf 0a    ...
	mov	a,m		;; 0aaf: 7e          ~
	dcx	h		;; 0ab0: 2b          +
	shld	L3058		;; 0ab1: 22 58 30    "X0
	lhld	memtop		;; 0ab4: 2a 4d 30    *M0
	dcx	h		;; 0ab7: 2b          +
	shld	memtop		;; 0ab8: 22 4d 30    "M0
	mov	m,a		;; 0abb: 77          w
	jmp	L0a9f		;; 0abc: c3 9f 0a    ...

L0abf:	inx	h		;; 0abf: 23          #
	shld	nxheap		;; 0ac0: 22 4b 30    "K0
	lhld	memtop		;; 0ac3: 2a 4d 30    *M0
	shld	L2eb4		;; 0ac6: 22 b4 2e    "..
	nop			;; 0ac9: 00          .
	lda	L305c		;; 0aca: 3a 5c 30    :\0
	cpi	6		;; 0acd: fe 06       ..
	jz	L0add		;; 0acf: ca dd 0a    ...
	mov	c,m		;; 0ad2: 4e          N
	mvi	b,0		;; 0ad3: 06 00       ..
	mov	e,l		;; 0ad5: 5d          ]
	mov	d,h		;; 0ad6: 54          T
	dad	b		;; 0ad7: 09          .
	xchg			;; 0ad8: eb          .
	mov	m,e		;; 0ad9: 73          s
	inx	h		;; 0ada: 23          #
	mov	m,d		;; 0adb: 72          r
	dcx	h		;; 0adc: 2b          +
L0add:	push	h		;; 0add: e5          .
	lhld	cursym		;; 0ade: 2a 56 30    *V0
	xchg			;; 0ae1: eb          .
	lhld	L11c5		;; 0ae2: 2a c5 11    *..
	mov	a,e		;; 0ae5: 7b          {
	sub	l		;; 0ae6: 95          .
	mov	e,a		;; 0ae7: 5f          _
	mov	a,d		;; 0ae8: 7a          z
	sbb	h		;; 0ae9: 9c          .
	mov	d,a		;; 0aea: 57          W
	pop	h		;; 0aeb: e1          .
	dad	d		;; 0aec: 19          .
	shld	L2ed4		;; 0aed: 22 d4 2e    "..
	lda	L305c		;; 0af0: 3a 5c 30    :\0
	sta	L2ea4		;; 0af3: 32 a4 2e    2..
	jmp	L0552		;; 0af6: c3 52 05    .R.

pASEG:	jmp	L0c06		;; 0af9: c3 06 0c    ...

pCSEG:	jmp	L0c06		;; 0afc: c3 06 0c    ...

pDSEG:	jmp	L0c06		;; 0aff: c3 06 0c    ...

pNAME:	jmp	L0c06		;; 0b02: c3 06 0c    ...

pPAGE:	call	L0ef4		;; 0b05: cd f4 0e    ...
	call	L1606		;; 0b08: cd 06 16    ...
	call	L0c0f		;; 0b0b: cd 0f 0c    ...
	jz	L0b25		;; 0b0e: ca 25 0b    .%.
	call	L1203		;; 0b11: cd 03 12    ...
	lhld	L3049		;; 0b14: 2a 49 30    *I0
	lda	curerr		;; 0b17: 3a 8c 2f    :./
	cpi	' '		;; 0b1a: fe 20       . 
	jnz	L0dd5		;; 0b1c: c2 d5 0d    ...
	call	L25aa		;; 0b1f: cd aa 25    ..%
	jmp	L0dd5		;; 0b22: c3 d5 0d    ...

L0b25:	call	L03ac		;; 0b25: cd ac 03    ...
	lda	pass		;; 0b28: 3a 4f 30    :O0
	ora	a		;; 0b2b: b7          .
	cnz	L25ad		;; 0b2c: c4 ad 25    ..%
	jmp	L0dd5		;; 0b2f: c3 d5 0d    ...

pEXITM:	jmp	pENDM		;; 0b32: c3 20 05    . .

pEXTRN:	jmp	L0c06		;; 0b35: c3 06 0c    ...

pLOCAL:	lda	L2ea3		;; 0b38: 3a a3 2e    :..
	ora	a		;; 0b3b: b7          .
	jz	L0ba2		;; 0b3c: ca a2 0b    ...
L0b3f:	call	L1606		;; 0b3f: cd 06 16    ...
	lda	L3005		;; 0b42: 3a 05 30    :.0
	cpi	001h		;; 0b45: fe 01       ..
	jnz	L0ba2		;; 0b47: c2 a2 0b    ...
	lhld	nxheap		;; 0b4a: 2a 4b 30    *K0
	push	h		;; 0b4d: e5          .
	dcx	h		;; 0b4e: 2b          +
	shld	L3058		;; 0b4f: 22 58 30    "X0
	call	L1c21		;; 0b52: cd 21 1c    ...
	xra	a		;; 0b55: af          .
	sta	L11db		;; 0b56: 32 db 11    2..
	inr	a		;; 0b59: 3c          <
	sta	tokbuf		;; 0b5a: 32 08 30    2.0
	lhld	L11de		;; 0b5d: 2a de 11    *..
	inx	h		;; 0b60: 23          #
	shld	L11de		;; 0b61: 22 de 11    "..
	shld	L11dc		;; 0b64: 22 dc 11    "..
	call	L0d0e		;; 0b67: cd 0e 0d    ...
	lda	tokbuf+2		;; 0b6a: 3a 0a 30    :.0
	cpi	'0'		;; 0b6d: fe 30       .0
	cnz	Oerror		;; 0b6f: c4 a8 11    ...
	lxi	h,'??'		;; 0b72: 21 3f 3f    .??
	shld	tokbuf+1		;; 0b75: 22 09 30    ".0
	call	L1c39		;; 0b78: cd 39 1c    .9.
	pop	h		;; 0b7b: e1          .
	shld	nxheap		;; 0b7c: 22 4b 30    "K0
	dcx	h		;; 0b7f: 2b          +
	shld	L3058		;; 0b80: 22 58 30    "X0
	call	L1c24		;; 0b83: cd 24 1c    .$.
	call	L1c3c		;; 0b86: cd 3c 1c    .<.
	call	L1606		;; 0b89: cd 06 16    ...
	call	L0c0f		;; 0b8c: cd 0f 0c    ...
	jz	L0dd5		;; 0b8f: ca d5 0d    ...
	lda	L3005		;; 0b92: 3a 05 30    :.0
	cpi	004h		;; 0b95: fe 04       ..
	jnz	L0ba2		;; 0b97: c2 a2 0b    ...
	lda	tokbuf+1		;; 0b9a: 3a 09 30    :.0
	cpi	','		;; 0b9d: fe 2c       .,
	jz	L0b3f		;; 0b9f: ca 3f 0b    .?.
L0ba2:	call	Serror		;; 0ba2: cd b4 11    ...
	jmp	L0dd5		;; 0ba5: c3 d5 0d    ...

pNPAGE:	jmp	L0c06		;; 0ba8: c3 06 0c    ...

pMACLI:	call	L0ef4		;; 0bab: cd f4 0e    ...
	lhld	L11d6		;; 0bae: 2a d6 11    *..
	mov	a,l		;; 0bb1: 7d          }
	ora	h		;; 0bb2: b4          .
	jnz	L0bfa		;; 0bb3: c2 fa 0b    ...
	lda	L305d		;; 0bb6: 3a 5d 30    :]0
	ora	a		;; 0bb9: b7          .
	jnz	L0bfa		;; 0bba: c2 fa 0b    ...
	call	L1606		;; 0bbd: cd 06 16    ...
	lda	pass		;; 0bc0: 3a 4f 30    :O0
	ora	a		;; 0bc3: b7          .
	jnz	L0c09		;; 0bc4: c2 09 0c    ...
	lda	L3005		;; 0bc7: 3a 05 30    :.0
	cpi	001h		;; 0bca: fe 01       ..
	jnz	L0bfa		;; 0bcc: c2 fa 0b    ...
	call	libfie		;; 0bcf: cd a4 25    ..%
	lda	Lflag		;; 0bd2: 3a 65 30    :e0
	ora	a		;; 0bd5: b7          .
	cnz	L25ad		;; 0bd6: c4 ad 25    ..%
L0bd9:	call	L1606		;; 0bd9: cd 06 16    ...
	lda	L3005		;; 0bdc: 3a 05 30    :.0
	cpi	004h		;; 0bdf: fe 04       ..
	jnz	L0bd9		;; 0be1: c2 d9 0b    ...
	lda	tokbuf+1		;; 0be4: 3a 09 30    :.0
	cpi	cr		;; 0be7: fe 0d       ..
	jz	L0bf1		;; 0be9: ca f1 0b    ...
	cpi	eof		;; 0bec: fe 1a       ..
	jnz	L0bd9		;; 0bee: c2 d9 0b    ...
L0bf1:	call	L03ac		;; 0bf1: cd ac 03    ...
	call	L25a7		;; 0bf4: cd a7 25    ..%
	jmp	L0176		;; 0bf7: c3 76 01    .v.

L0bfa:	call	Serror		;; 0bfa: cd b4 11    ...
	jmp	L0dd5		;; 0bfd: c3 d5 0d    ...

pPUBLI:	jmp	L0c06		;; 0c00: c3 06 0c    ...

pSTKLN:	jmp	L0c06		;; 0c03: c3 06 0c    ...

L0c06:	call	Nerror		;; 0c06: cd ba 11    ...
	;
L0c09:	call	L1606		;; 0c09: cd 06 16    ...
	jmp	L0dd5		;; 0c0c: c3 d5 0d    ...

L0c0f:	lda	L3005		;; 0c0f: 3a 05 30    :.0
	cpi	004h		;; 0c12: fe 04       ..
	rnz			;; 0c14: c0          .
	lda	tokbuf+1		;; 0c15: 3a 09 30    :.0
	cpi	cr		;; 0c18: fe 0d       ..
	rz			;; 0c1a: c8          .
	cpi	'!'		;; 0c1b: fe 21       ..
	rz			;; 0c1d: c8          .
	cpi	';'		;; 0c1e: fe 3b       .;
	ret			;; 0c20: c9          .

L0c21:	sui	01ch		;; 0c21: d6 1c       ..
	cpi	02ah	;***BUG***	;; 0c23: fe 2a       .*
	jnc	L0e20		;; 0c25: d2 20 0e    . .
	; 1ch-2ah - instructions
	mov	e,a		;; 0c28: 5f          _
	mvi	d,0		;; 0c29: 16 00       ..
	lxi	h,instbl	;; 0c2b: 21 35 0c    .5.
	dad	d		;; 0c2e: 19          .
	dad	d		;; 0c2f: 19          .
	mov	e,m		;; 0c30: 5e          ^
	inx	h		;; 0c31: 23          #
	mov	h,m		;; 0c32: 66          f
	mov	l,e		;; 0c33: 6b          k
	pchl			;; 0c34: e9          .

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
opnone:	call	asmbyt		;; 0c53: cd 32 0f    .2.
	call	L1606		;; 0c56: cd 06 16    ...
	jmp	L0cfb		;; 0c59: c3 fb 0c    ...

; opcode with regpair set 1,word
opX1W:	call	L0da0		;; 0c5c: cd a0 0d    ...
	call	L0dbb		;; 0c5f: cd bb 0d    ...
	call	asmref		;; 0c62: cd b5 0d    ...
	jmp	L0cfb		;; 0c65: c3 fb 0c    ...

; opcode with regpair set 1 (B,D,H,SP)
opX1:	call	L0da0		;; 0c68: cd a0 0d    ...
	jmp	L0cfb		;; 0c6b: c3 fb 0c    ...

; opcode with regpair set 2 (B,D,H,PSW)
opX2:	call	L0d96		;; 0c6e: cd 96 0d    ...
	cpi	038h		;; 0c71: fe 38       .8
	jz	L0c7b		;; 0c73: ca 7b 0c    .{.
	ani	008h		;; 0c76: e6 08       ..
	cnz	Rerror		;; 0c78: c4 82 11    ...
L0c7b:	mov	a,c		;; 0c7b: 79          y
	ani	030h		;; 0c7c: e6 30       .0
	ora	b		;; 0c7e: b0          .
	jmp	L0cf8		;; 0c7f: c3 f8 0c    ...

; opcode with word - exec target, jump/call
opW1:	call	asmbyt		;; 0c82: cd 32 0f    .2.
	call	asmref		;; 0c85: cd b5 0d    ...
	jmp	L0cfb		;; 0c88: c3 fb 0c    ...

; opcode with two single-reg operands (reg,reg) (00tttsss)
opRR:	call	L0d96		;; 0c8b: cd 96 0d    ...
	ora	b		;; 0c8e: b0          .
	mov	b,a		;; 0c8f: 47          G
	call	L0dbb		;; 0c90: cd bb 0d    ...
	call	L0d8b		;; 0c93: cd 8b 0d    ...
	ora	b		;; 0c96: b0          .
	jmp	L0cf8		;; 0c97: c3 f8 0c    ...

; opcode with reg,byte operands, move imm (00rrr000)
opRB:	call	L0d96		;; 0c9a: cd 96 0d    ...
	ora	b		;; 0c9d: b0          .
	call	asmbya		;; 0c9e: cd 31 0f    .1.
	call	L0dbb		;; 0ca1: cd bb 0d    ...
	call	L0daf		;; 0ca4: cd af 0d    ...
	jmp	L0cfb		;; 0ca7: c3 fb 0c    ...

; opcode with byte (imm) operand
opB1:	call	asmbyt		;; 0caa: cd 32 0f    .2.
	call	L0daf		;; 0cad: cd af 0d    ...
	jmp	L0cfb		;; 0cb0: c3 fb 0c    ...

; opcode with regpair set 3 (B,D) (000x0000)
opX3:	call	L0d96		;; 0cb3: cd 96 0d    ...
	ani	028h		;; 0cb6: e6 28       .(
	cnz	Rerror		;; 0cb8: c4 82 11    ...
	mov	a,c		;; 0cbb: 79          y
	ani	010h		;; 0cbc: e6 10       ..
	ora	b		;; 0cbe: b0          .
	jmp	L0cf8		;; 0cbf: c3 f8 0c    ...

; opcode with word (data target)
opW2:	call	asmbyt		;; 0cc2: cd 32 0f    .2.
	call	asmref		;; 0cc5: cd b5 0d    ...
	jmp	L0cfb		;; 0cc8: c3 fb 0c    ...

; opcode with reg, arith/logic (00000rrr)
opR1:	call	L0d8b		;; 0ccb: cd 8b 0d    ...
	ora	b		;; 0cce: b0          .
	jmp	L0cf8		;; 0ccf: c3 f8 0c    ...

; opcode with reg, increment/decrement (00rrr000)
opR2:	call	L0d96		;; 0cd2: cd 96 0d    ...
	ora	b		;; 0cd5: b0          .
	jmp	L0cf8		;; 0cd6: c3 f8 0c    ...

; opcode with reg-pair set 4 (B,D,H,SP), increment/decrement (00xx0000)
opX4:	call	L0d96		;; 0cd9: cd 96 0d    ...
	ani	008h		;; 0cdc: e6 08       ..
	cnz	Rerror		;; 0cde: c4 82 11    ...
	mov	a,c		;; 0ce1: 79          y
	ani	030h		;; 0ce2: e6 30       .0
	ora	b		;; 0ce4: b0          .
	jmp	L0cf8		;; 0ce5: c3 f8 0c    ...

; opcode with number (0-7), restart instructions
; NOTE: same code as opR2
opN:	call	L0d96		;; 0ce8: cd 96 0d    ...
	ora	b		;; 0ceb: b0          .
	jmp	L0cf8		;; 0cec: c3 f8 0c    ...

; opcode with byte, input/output port
; NOTE: same code as opB1
opB2:	call	asmbyt		;; 0cef: cd 32 0f    .2.
	call	L0daf		;; 0cf2: cd af 0d    ...
	jmp	L0cfb		;; 0cf5: c3 fb 0c    ...

L0cf8:	call	asmbya		;; 0cf8: cd 31 0f    .1.
L0cfb:	call	L0ef4		;; 0cfb: cd f4 0e    ...
	call	synadr		;; 0cfe: cd e3 0e    ...
	jmp	L0dd5		;; 0d01: c3 d5 0d    ...

L0d04:	dw	10000
	dw	1000
	dw	100
	dw	10
	dw	1

; convert number in (L11dc) to ASCII decimal string appended to tokbuf.
; leading zeros suppressed. destructive to L11dc.
L0d0e:	mvi	b,5		;; 0d0e: 06 05       ..
	lxi	h,L0d04		;; 0d10: 21 04 0d    ...
L0d13:	mov	e,m		;; 0d13: 5e          ^
	inx	h		;; 0d14: 23          #
	mov	d,m		;; 0d15: 56          V
	inx	h		;; 0d16: 23          #
	push	h		;; 0d17: e5          .
	lhld	L11dc		;; 0d18: 2a dc 11    *..
	mvi	c,'0'		;; 0d1b: 0e 30       .0
L0d1d:	mov	a,l		;; 0d1d: 7d          }
	sub	e		;; 0d1e: 93          .
	mov	l,a		;; 0d1f: 6f          o
	mov	a,h		;; 0d20: 7c          |
	sbb	d		;; 0d21: 9a          .
	mov	h,a		;; 0d22: 67          g
	jc	L0d2a		;; 0d23: da 2a 0d    .*.
	inr	c		;; 0d26: 0c          .
	jmp	L0d1d		;; 0d27: c3 1d 0d    ...

L0d2a:	dad	d		;; 0d2a: 19          .
	shld	L11dc		;; 0d2b: 22 dc 11    "..
	lda	L11db		;; 0d2e: 3a db 11    :..
	ora	a		;; 0d31: b7          .
	jz	L0d44		;; 0d32: ca 44 0d    .D.
	mov	a,b		;; 0d35: 78          x
	dcr	a		;; 0d36: 3d          =
	jz	L0d44		;; 0d37: ca 44 0d    .D.
	mov	a,c		;; 0d3a: 79          y
	cpi	'0'		;; 0d3b: fe 30       .0
	jz	L0d50		;; 0d3d: ca 50 0d    .P.
	xra	a		;; 0d40: af          .
	sta	L11db		;; 0d41: 32 db 11    2..
L0d44:	lxi	h,tokbuf		;; 0d44: 21 08 30    ..0
	mov	e,m		;; 0d47: 5e          ^
	inr	m		;; 0d48: 34          4
	mvi	d,0		;; 0d49: 16 00       ..
	lxi	h,tokbuf+1		;; 0d4b: 21 09 30    ..0
	dad	d		;; 0d4e: 19          .
	mov	m,c		;; 0d4f: 71          q
L0d50:	pop	h		;; 0d50: e1          .
	dcr	b		;; 0d51: 05          .
	jnz	L0d13		;; 0d52: c2 13 0d    ...
	ret			;; 0d55: c9          .

L0d56:	lda	L3005		;; 0d56: 3a 05 30    :.0
	cpi	004h		;; 0d59: fe 04       ..
	cnz	Derror		;; 0d5b: c4 96 11    ...
	lda	tokbuf+1		;; 0d5e: 3a 09 30    :.0
	cpi	','		;; 0d61: fe 2c       .,
	rz			;; 0d63: c8          .
	cpi	';'		;; 0d64: fe 3b       .;
	rz			;; 0d66: c8          .
	cpi	cr		;; 0d67: fe 0d       ..
	cnz	Derror		;; 0d69: c4 96 11    ...
	ret			;; 0d6c: c9          .

L0d6d:	push	b		;; 0d6d: c5          .
	call	L1606		;; 0d6e: cd 06 16    ...
	call	L1203		;; 0d71: cd 03 12    ...
	lhld	L3049		;; 0d74: 2a 49 30    *I0
	pop	b		;; 0d77: c1          .
	ret			;; 0d78: c9          .

; check if value can be stored in a byte
chkbyt:	call	L0d6d		;; 0d79: cd 6d 0d    .m.
chkbyh:	mov	a,h		;; 0d7c: 7c          |
	ora	a		;; 0d7d: b7          .
	mov	a,l		;; 0d7e: 7d          }
	rz			;; 0d7f: c8          .
	inr	h		;; 0d80: 24          $
	jnz	L0d86		;; 0d81: c2 86 0d    ...
	ora	a		;; 0d84: b7          .
	rm			;; 0d85: f8          .
L0d86:	call	Verror		;; 0d86: cd 8c 11    ...
	mov	l,a		;; 0d89: 6f          o
	ret			;; 0d8a: c9          .

L0d8b:	call	chkbyt		;; 0d8b: cd 79 0d    .y.
	cpi	008h		;; 0d8e: fe 08       ..
	cnc	Verror		;; 0d90: d4 8c 11    ...
	ani	007h		;; 0d93: e6 07       ..
	ret			;; 0d95: c9          .

L0d96:	call	L0d8b		;; 0d96: cd 8b 0d    ...
	ral			;; 0d99: 17          .
	ral			;; 0d9a: 17          .
	ral			;; 0d9b: 17          .
	ani	038h		;; 0d9c: e6 38       .8
	mov	c,a		;; 0d9e: 4f          O
	ret			;; 0d9f: c9          .

L0da0:	call	L0d96		;; 0da0: cd 96 0d    ...
	ani	008h		;; 0da3: e6 08       ..
	cnz	Rerror		;; 0da5: c4 82 11    ...
	mov	a,c		;; 0da8: 79          y
	ani	030h		;; 0da9: e6 30       .0
	ora	b		;; 0dab: b0          .
	jmp	asmbya		;; 0dac: c3 31 0f    .1.

L0daf:	call	chkbyt		;; 0daf: cd 79 0d    .y.
	jmp	asmbya		;; 0db2: c3 31 0f    .1.

asmref:	call	L0d6d		;; 0db5: cd 6d 0d    .m.
	jmp	asmadr		;; 0db8: c3 58 0f    .X.

L0dbb:	push	psw		;; 0dbb: f5          .
	push	b		;; 0dbc: c5          .
	lda	L3005		;; 0dbd: 3a 05 30    :.0
	cpi	004h		;; 0dc0: fe 04       ..
	jnz	L0dcd		;; 0dc2: c2 cd 0d    ...
	lda	tokbuf+1		;; 0dc5: 3a 09 30    :.0
	cpi	','		;; 0dc8: fe 2c       .,
	jz	L0dd2		;; 0dca: ca d2 0d    ...
L0dcd:	mvi	a,'C'		;; 0dcd: 3e 43       >C
	call	setere		;; 0dcf: cd 98 25    ..%
L0dd2:	pop	b		;; 0dd2: c1          .
	pop	psw		;; 0dd3: f1          .
	ret			;; 0dd4: c9          .

L0dd5:	call	L0ef4		;; 0dd5: cd f4 0e    ...
	lda	L3005		;; 0dd8: 3a 05 30    :.0
	cpi	004h		;; 0ddb: fe 04       ..
	jnz	L0e20		;; 0ddd: c2 20 0e    . .
	lda	tokbuf+1		;; 0de0: 3a 09 30    :.0
	cpi	cr		;; 0de3: fe 0d       ..
	jnz	L0dee		;; 0de5: c2 ee 0d    ...
	call	L1606		;; 0de8: cd 06 16    ...
	jmp	L0176		;; 0deb: c3 76 01    .v.

L0dee:	cpi	';'		;; 0dee: fe 3b       .;
	jnz	L0e16		;; 0df0: c2 16 0e    ...
	call	L0ef4		;; 0df3: cd f4 0e    ...
L0df6:	call	L1606		;; 0df6: cd 06 16    ...
	lda	L3005		;; 0df9: 3a 05 30    :.0
	cpi	004h		;; 0dfc: fe 04       ..
	jnz	L0df6		;; 0dfe: c2 f6 0d    ...
	lda	tokbuf+1		;; 0e01: 3a 09 30    :.0
	cpi	lf		;; 0e04: fe 0a       ..
	jz	L0176		;; 0e06: ca 76 01    .v.
	cpi	eof		;; 0e09: fe 1a       ..
	jz	L0e2d		;; 0e0b: ca 2d 0e    .-.
	cpi	'!'		;; 0e0e: fe 21       ..
	jz	L0176		;; 0e10: ca 76 01    .v.
	jmp	L0df6		;; 0e13: c3 f6 0d    ...

L0e16:	cpi	'!'		;; 0e16: fe 21       ..
	jz	L0176		;; 0e18: ca 76 01    .v.
	cpi	eof		;; 0e1b: fe 1a       ..
	jz	L0e2d		;; 0e1d: ca 2d 0e    .-.
L0e20:	call	Serror		;; 0e20: cd b4 11    ...
	jmp	L0df6		;; 0e23: c3 f6 0d    ...

subtra:	mov	a,e		;; 0e26: 7b          {
	sub	l		;; 0e27: 95          .
	mov	l,a		;; 0e28: 6f          o
	mov	a,d		;; 0e29: 7a          z
	sbb	h		;; 0e2a: 9c          .
	mov	h,a		;; 0e2b: 67          g
	ret			;; 0e2c: c9          .

L0e2d:	lda	L2ea3		;; 0e2d: 3a a3 2e    :..
	ora	a		;; 0e30: b7          .
	jz	L0e37		;; 0e31: ca 37 0e    .7.
L0e34:	call	Berror		;; 0e34: cd ae 11    ...
L0e37:	xra	a		;; 0e37: af          .
	sta	L305a		;; 0e38: 32 5a 30    2Z0
	lxi	h,pass		;; 0e3b: 21 4f 30    .O0
	mov	a,m		;; 0e3e: 7e          ~
	inr	m		;; 0e3f: 34          4
	ora	a		;; 0e40: b7          .
	jnz	L0e6c		;; 0e41: c2 6c 0e    .l.
	lxi	h,0ffffh	;; 0e44: 21 ff ff    ...
	shld	L11d8		;; 0e47: 22 d8 11    "..
L0e4a:	lhld	L11d6		;; 0e4a: 2a d6 11    *..
	mov	a,h		;; 0e4d: 7c          |
	ora	l		;; 0e4e: b5          .
	jz	L013e		;; 0e4f: ca 3e 01    .>.
	shld	cursym		;; 0e52: 22 56 30    "V0
	push	h		;; 0e55: e5          .
	call	L1c18		;; 0e56: cd 18 1c    ...
	xthl			;; 0e59: e3          .
	push	h		;; 0e5a: e5          .
	lhld	L11d8		;; 0e5b: 2a d8 11    *..
	call	L1c15		;; 0e5e: cd 15 1c    ...
	pop	h		;; 0e61: e1          .
	shld	L11d8		;; 0e62: 22 d8 11    "..
	pop	h		;; 0e65: e1          .
	shld	L11d6		;; 0e66: 22 d6 11    "..
	jmp	L0e4a		;; 0e69: c3 4a 0e    .J.

; finish-up assembly...
L0e6c:	call	L1606		;; 0e6c: cd 06 16    ...
	call	prnbeg		;; 0e6f: cd 8a 0f    ...
	lxi	h,prnbuf+5	;; 0e72: 21 91 2f    ../
	mvi	m,cr		;; 0e75: 36 0d       6.
	lxi	h,prnbuf+1	;; 0e77: 21 8d 2f    ../
	call	msgcre		;; 0e7a: cd 92 25    ..%
	lda	Sflag		;; 0e7d: 3a 5e 30    :^0
	ora	a		;; 0e80: b7          .
	jz	L0e8f		;; 0e81: ca 8f 0e    ...
	; generate symbol output/file
	mvi	a,1		;; 0e84: 3e 01       >.
	sta	L2ea4		;; 0e86: 32 a4 2e    2..
	call	L25a1		;; 0e89: cd a1 25    ..%
	call	L0fb1		;; 0e8c: cd b1 0f    ...
L0e8f:	lhld	nxheap		;; 0e8f: 2a 4b 30    *K0
	xchg			;; 0e92: eb          .
	lhld	syheap		;; 0e93: 2a 54 30    *T0
	call	subtra		;; 0e96: cd 26 0e    .&.
	push	h		;; 0e99: e5          .
	lhld	memtop		;; 0e9a: 2a 4d 30    *M0
	xchg			;; 0e9d: eb          .
	lhld	syheap		;; 0e9e: 2a 54 30    *T0
	call	subtra		;; 0ea1: cd 26 0e    .&.
	mov	e,h		;; 0ea4: 5c          \
	mvi	d,0		;; 0ea5: 16 00       ..
	pop	h		;; 0ea7: e1          .
	call	divide		;; 0ea8: cd 09 12    ...
	xchg			;; 0eab: eb          .
	call	prnadr		;; 0eac: cd 8d 0f    ...
	lxi	h,prnbuf+5	;; 0eaf: 21 91 2f    ../
	lxi	d,L0ec0		;; 0eb2: 11 c0 0e    ...
L0eb5:	ldax	d		;; 0eb5: 1a          .
	ora	a		;; 0eb6: b7          .
	jz	L0ece		;; 0eb7: ca ce 0e    ...
	mov	m,a		;; 0eba: 77          w
	inx	h		;; 0ebb: 23          #
	inx	d		;; 0ebc: 13          .
	jmp	L0eb5		;; 0ebd: c3 b5 0e    ...

L0ec0:	db	'H USE FACTOR',0dh,0

L0ece:	lxi	h,prnbuf+2	;; 0ece: 21 8e 2f    ../
	call	msgcre		;; 0ed1: cd 92 25    ..%
	lhld	L11c7		;; 0ed4: 2a c7 11    *..
	shld	curadr		;; 0ed7: 22 50 30    "P0
	jmp	hexfne		;; 0eda: c3 9e 25    ..%

compr1:	mov	a,d		;; 0edd: 7a          z
	cmp	h		;; 0ede: bc          .
	rnz			;; 0edf: c0          .
	mov	a,e		;; 0ee0: 7b          {
	cmp	l		;; 0ee1: bd          .
	ret			;; 0ee2: c9          .

synadr:	lhld	curadr		;; 0ee3: 2a 50 30    *P0
	shld	linadr		;; 0ee6: 22 52 30    "R0
	ret			;; 0ee9: c9          .

L0eea:	lhld	L11c3		;; 0eea: 2a c3 11    *..
	shld	cursym		;; 0eed: 22 56 30    "V0
	call	L1c09		;; 0ef0: cd 09 1c    ...
	ret			;; 0ef3: c9          .

L0ef4:	call	L0eea		;; 0ef4: cd ea 0e    ...
	rz			;; 0ef7: c8          .
	lxi	h,0		;; 0ef8: 21 00 00    ...
	shld	L11c3		;; 0efb: 22 c3 11    "..
	lda	pass		;; 0efe: 3a 4f 30    :O0
	ora	a		;; 0f01: b7          .
	jnz	L0f1b		;; 0f02: c2 1b 0f    ...
	call	L1c12		;; 0f05: cd 12 1c    ...
	push	psw		;; 0f08: f5          .
	ani	007h		;; 0f09: e6 07       ..
	cnz	Lerror		;; 0f0b: c4 a2 11    ...
	pop	psw		;; 0f0e: f1          .
	ori	001h		;; 0f0f: f6 01       ..
	call	L1c0f		;; 0f11: cd 0f 1c    ...
	lhld	linadr		;; 0f14: 2a 52 30    *R0
	call	L1c15		;; 0f17: cd 15 1c    ...
	ret			;; 0f1a: c9          .

L0f1b:	call	L1c12		;; 0f1b: cd 12 1c    ...
	ani	007h		;; 0f1e: e6 07       ..
	cz	Perror		;; 0f20: cc 9c 11    ...
	call	L1c18		;; 0f23: cd 18 1c    ...
	xchg			;; 0f26: eb          .
	lhld	linadr		;; 0f27: 2a 52 30    *R0
	call	compr1		;; 0f2a: cd dd 0e    ...
	cnz	Perror		;; 0f2d: c4 9c 11    ...
	ret			;; 0f30: c9          .

; assemble byte, in A, to output files (PRN, HEX
asmbya:	mov	b,a		;; 0f31: 47          G
; assemble byte, in B, to output files (PRN, HEX)
asmbyt:	push	b		;; 0f32: c5          .
	lda	pass		;; 0f33: 3a 4f 30    :O0
	ora	a		;; 0f36: b7          .
	mov	a,b		;; 0f37: 78          x
	cnz	hexpte		;; 0f38: c4 9b 25    ..%
	lda	prnbuf+1	;; 0f3b: 3a 8d 2f    :./
	cpi	' '		;; 0f3e: fe 20       . 
	lhld	linadr		;; 0f40: 2a 52 30    *R0
	cz	prnadr		;; 0f43: cc 8d 0f    ...
	lda	prncol		;; 0f46: 3a c9 11    :..
	cpi	16		;; 0f49: fe 10       ..
	pop	b		;; 0f4b: c1          .
	mov	a,b		;; 0f4c: 78          x
	cc	prnhex		;; 0f4d: dc 7a 0f    .z.
	lhld	curadr		;; 0f50: 2a 50 30    *P0
	inx	h		;; 0f53: 23          #
	shld	curadr		;; 0f54: 22 50 30    "P0
	ret			;; 0f57: c9          .

; assemble address (HL) to output files (PRN, HEX)
asmadr:	push	h		;; 0f58: e5          .
	mov	b,l		;; 0f59: 45          E
	call	asmbyt		;; 0f5a: cd 32 0f    .2.
	pop	h		;; 0f5d: e1          .
	mov	b,h		;; 0f5e: 44          D
	jmp	asmbyt		;; 0f5f: c3 32 0f    .2.

hexdig:	adi	'0'		;; 0f62: c6 30       .0
	cpi	'9'+1		;; 0f64: fe 3a       .:
	rc			;; 0f66: d8          .
	adi	'A'-'9'-1	;; 0f67: c6 07       ..
	ret			;; 0f69: c9          .

L0f6a:	call	hexdig		;; 0f6a: cd 62 0f    .b.
	lxi	h,prncol		;; 0f6d: 21 c9 11    ...
	mov	e,m		;; 0f70: 5e          ^
	mvi	d,0		;; 0f71: 16 00       ..
	inr	m		;; 0f73: 34          4
	lxi	h,prnbuf		;; 0f74: 21 8c 2f    ../
	dad	d		;; 0f77: 19          .
	mov	m,a		;; 0f78: 77          w
	ret			;; 0f79: c9          .

prnhex:	push	psw		;; 0f7a: f5          .
	rar			;; 0f7b: 1f          .
	rar			;; 0f7c: 1f          .
	rar			;; 0f7d: 1f          .
	rar			;; 0f7e: 1f          .
	ani	00fh		;; 0f7f: e6 0f       ..
	call	L0f6a		;; 0f81: cd 6a 0f    .j.
	pop	psw		;; 0f84: f1          .
	ani	00fh		;; 0f85: e6 0f       ..
	jmp	L0f6a		;; 0f87: c3 6a 0f    .j.

; put address (linadr) in PRN file buffer
prnbeg:	lhld	linadr		;; 0f8a: 2a 52 30    *R0
; put address (HL) in PRN file buffer
prnadr:	xchg			;; 0f8d: eb          .
	lxi	h,prncol		;; 0f8e: 21 c9 11    ...
	push	h		;; 0f91: e5          .
	mvi	m,1		;; 0f92: 36 01       6.
	mov	a,d		;; 0f94: 7a          z
	push	d		;; 0f95: d5          .
	call	prnhex		;; 0f96: cd 7a 0f    .z.
	pop	d		;; 0f99: d1          .
	mov	a,e		;; 0f9a: 7b          {
	call	prnhex		;; 0f9b: cd 7a 0f    .z.
	pop	h		;; 0f9e: e1          .
	inr	m		;; 0f9f: 34          4
	ret			;; 0fa0: c9          .

hashch:	sui	'A'		;; 0fa1: d6 41       .A
	cpi	'Z'-'A'+1	;; 0fa3: fe 1a       ..
	mov	e,a		;; 0fa5: 5f          _
	rc			;; 0fa6: d8          .
	adi	'A'		;; 0fa7: c6 41       .A
	cpi	'?'		;; 0fa9: fe 3f       .?
	mvi	e,'['-'A'	;; 0fab: 1e 1a       ..
	rz			;; 0fad: c8          .
	mvi	e,'\'-'A'	;; 0fae: 1e 1b       ..
	ret			;; 0fb0: c9          .

L0fb1:	xra	a		;; 0fb1: af          .
	sta	L2ea5		;; 0fb2: 32 a5 2e    2..
	sta	prncol		;; 0fb5: 32 c9 11    2..
	lhld	syheap		;; 0fb8: 2a 54 30    *T0
	shld	cursym		;; 0fbb: 22 56 30    "V0
	; init symtab hash to 0...
	lxi	h,symtab	;; 0fbe: 21 ac 2e    ...
	mvi	c,56		;; 0fc1: 0e 38       .8
	xra	a		;; 0fc3: af          .
L0fc4:	mov	m,a		;; 0fc4: 77          w
	inx	h		;; 0fc5: 23          #
	dcr	c		;; 0fc6: 0d          .
	jnz	L0fc4		;; 0fc7: c2 c4 0f    ...
	;
L0fca:	lhld	cursym		;; 0fca: 2a 56 30    *V0
	xchg			;; 0fcd: eb          .
	lhld	nxheap		;; 0fce: 2a 4b 30    *K0
	mov	a,e		;; 0fd1: 7b          {
	sub	l		;; 0fd2: 95          .
	mov	a,d		;; 0fd3: 7a          z
	sbb	h		;; 0fd4: 9c          .
	jnc	L10a4		;; 0fd5: d2 a4 10    ...
	lhld	L3062		;; 0fd8: 2a 62 30    *b0
	call	compr1		;; 0fdb: cd dd 0e    ...
	dcx	h		;; 0fde: 2b          +
	shld	L3058		;; 0fdf: 22 58 30    "X0
	jz	L0ffd		;; 0fe2: ca fd 0f    ...
	call	L1c12		;; 0fe5: cd 12 1c    ...
	cpi	6		;; 0fe8: fe 06       ..
	jnz	L100b		;; 0fea: c2 0b 10    ...
	call	L1c1e		;; 0fed: cd 1e 1c    ...
L0ff0:	ora	a		;; 0ff0: b7          .
	jz	L0ffd		;; 0ff1: ca fd 0f    ...
	dcr	a		;; 0ff4: 3d          =
	push	psw		;; 0ff5: f5          .
	call	L1c24		;; 0ff6: cd 24 1c    .$.
	pop	psw		;; 0ff9: f1          .
	jmp	L0ff0		;; 0ffa: c3 f0 0f    ...

L0ffd:	call	L1c2a		;; 0ffd: cd 2a 1c    .*.
	ora	a		;; 1000: b7          .
	jnz	L0ffd		;; 1001: c2 fd 0f    ...
	lhld	L3058		;; 1004: 2a 58 30    *X0
	inx	h		;; 1007: 23          #
	jmp	L109e		;; 1008: c3 9e 10    ...

L100b:	lxi	h,L2ea4		;; 100b: 21 a4 2e    ...
	cmp	m		;; 100e: be          .
	jnz	L1090		;; 100f: c2 90 10    ...
	lhld	cursym		;; 1012: 2a 56 30    *V0
	shld	L2eaa		;; 1015: 22 aa 2e    "..
	inx	h		;; 1018: 23          #
	shld	L3058		;; 1019: 22 58 30    "X0
	call	L1c24		;; 101c: cd 24 1c    .$.
	lda	Qflag		;; 101f: 3a 64 30    :d0
	ora	a		;; 1022: b7          .
	jnz	L103c		;; 1023: c2 3c 10    .<.
	lda	tokbuf		;; 1026: 3a 08 30    :.0
	cpi	002h		;; 1029: fe 02       ..
	jc	L103c		;; 102b: da 3c 10    .<.
	lxi	h,tokbuf+1		;; 102e: 21 09 30    ..0
	mov	a,m		;; 1031: 7e          ~
	cpi	'?'		;; 1032: fe 3f       .?
	jnz	L103c		;; 1034: c2 3c 10    .<.
	inx	h		;; 1037: 23          #
	cmp	m		;; 1038: be          .
	jz	L1090		;; 1039: ca 90 10    ...
; lookup symbol/string?
L103c:	lda	tokbuf+1		;; 103c: 3a 09 30    :.0
	call	hashch		;; 103f: cd a1 0f    ...
	lxi	h,symtab		;; 1042: 21 ac 2e    ...
	mvi	d,0		;; 1045: 16 00       ..
	dad	d		;; 1047: 19          .
	dad	d		;; 1048: 19          .
L1049:	shld	curhsh		;; 1049: 22 a8 2e    "..
	mov	e,m		;; 104c: 5e          ^
	inx	h		;; 104d: 23          #
	mov	d,m		;; 104e: 56          V
	xchg			;; 104f: eb          .
	shld	cursym		;; 1050: 22 56 30    "V0
	mov	a,l		;; 1053: 7d          }
	ora	h		;; 1054: b4          .
	jz	nxtsym		;; 1055: ca 7b 10    .{.
	inx	h		;; 1058: 23          #
	inx	h		;; 1059: 23          #
	mov	a,m		;; 105a: 7e          ~
	ani	00fh		;; 105b: e6 0f       ..
	inr	a		;; 105d: 3c          <
	mov	c,a		;; 105e: 4f          O
	lxi	d,tokbuf		;; 105f: 11 08 30    ..0
	mov	b,m		;; 1062: 46          F
L1063:	inx	d		;; 1063: 13          .
	inx	h		;; 1064: 23          #
	ldax	d		;; 1065: 1a          .
	cmp	m		;; 1066: be          .
	jc	nxtsym		;; 1067: da 7b 10    .{.
	jnz	L1075		;; 106a: c2 75 10    .u.
	dcr	b		;; 106d: 05          .
	jz	nxtsym		;; 106e: ca 7b 10    .{.
	dcr	c		;; 1071: 0d          .
	jnz	L1063		;; 1072: c2 63 10    .c.
	; found symbol match, or insertion point
L1075:	lhld	cursym		;; 1075: 2a 56 30    *V0
	jmp	L1049		;; 1078: c3 49 10    .I.

; locate next symbol in chain
nxtsym:	lhld	cursym		;; 107b: 2a 56 30    *V0
	xchg			;; 107e: eb          .
	lhld	L2eaa		;; 107f: 2a aa 2e    *..
	shld	cursym		;; 1082: 22 56 30    "V0
	mov	m,e		;; 1085: 73          s
	inx	h		;; 1086: 23          #
	mov	m,d		;; 1087: 72          r
	dcx	h		;; 1088: 2b          +
	xchg			;; 1089: eb          .
	lhld	curhsh		;; 108a: 2a a8 2e    *..
	mov	m,e		;; 108d: 73          s
	inx	h		;; 108e: 23          #
	mov	m,d		;; 108f: 72          r
L1090:	lhld	cursym		;; 1090: 2a 56 30    *V0
	inx	h		;; 1093: 23          #
	inx	h		;; 1094: 23          #
	mov	a,m		;; 1095: 7e          ~
	ani	00fh		;; 1096: e6 0f       ..
	adi	004h		;; 1098: c6 04       ..
	mov	e,a		;; 109a: 5f          _
	mvi	d,0		;; 109b: 16 00       ..
	dad	d		;; 109d: 19          .
L109e:	shld	cursym		;; 109e: 22 56 30    "V0
	jmp	L0fca		;; 10a1: c3 ca 0f    ...

L10a4:	lxi	h,symtab		;; 10a4: 21 ac 2e    ...
	shld	curhsh		;; 10a7: 22 a8 2e    "..
	mvi	a,01ch		;; 10aa: 3e 1c       >.
	sta	L2ea7		;; 10ac: 32 a7 2e    2..
L10af:	lhld	curhsh		;; 10af: 2a a8 2e    *..
	mov	e,m		;; 10b2: 5e          ^
	inx	h		;; 10b3: 23          #
	mov	d,m		;; 10b4: 56          V
	inx	h		;; 10b5: 23          #
	shld	curhsh		;; 10b6: 22 a8 2e    "..
	xchg			;; 10b9: eb          .
	shld	cursym		;; 10ba: 22 56 30    "V0
L10bd:	lhld	cursym		;; 10bd: 2a 56 30    *V0
	mov	a,l		;; 10c0: 7d          }
	ora	h		;; 10c1: b4          .
	jz	L1164		;; 10c2: ca 64 11    .d.
	inx	h		;; 10c5: 23          #
	inx	h		;; 10c6: 23          #
	mov	a,m		;; 10c7: 7e          ~
	ani	00fh		;; 10c8: e6 0f       ..
	inr	a		;; 10ca: 3c          <
	sta	L2ea6		;; 10cb: 32 a6 2e    2..
	mov	b,a		;; 10ce: 47          G
	lhld	cursym		;; 10cf: 2a 56 30    *V0
	inx	h		;; 10d2: 23          #
	inx	h		;; 10d3: 23          #
	shld	L3058		;; 10d4: 22 58 30    "X0
	lda	L2ea5		;; 10d7: 3a a5 2e    :..
	ora	a		;; 10da: b7          .
	jz	L10fa		;; 10db: ca fa 10    ...
	mvi	a,tab		;; 10de: 3e 09       >.
	call	prnchr		;; 10e0: cd 75 11    .u.
	lxi	h,L2ea5		;; 10e3: 21 a5 2e    ...
	mov	a,m		;; 10e6: 7e          ~
	ani	0f8h		;; 10e7: e6 f8       ..
	adi	008h		;; 10e9: c6 08       ..
	mov	m,a		;; 10eb: 77          w
	ani	00fh		;; 10ec: e6 0f       ..
	jz	L10fa		;; 10ee: ca fa 10    ...
	mvi	a,008h		;; 10f1: 3e 08       >.
	add	m		;; 10f3: 86          .
	mov	m,a		;; 10f4: 77          w
	mvi	a,tab		;; 10f5: 3e 09       >.
	call	prnchr		;; 10f7: cd 75 11    .u.
L10fa:	lda	L2ea5		;; 10fa: 3a a5 2e    :..
	add	b		;; 10fd: 80          .
	adi	5		;; 10fe: c6 05       ..
	cpi	80		;; 1100: fe 50       .P
	jc	L1127		;; 1102: da 27 11    .'.
L1105:	lxi	h,prncol		;; 1105: 21 c9 11    ...
	dcr	m		;; 1108: 35          5
	mov	e,m		;; 1109: 5e          ^
	mvi	d,0		;; 110a: 16 00       ..
	dcx	d		;; 110c: 1b          .
	lxi	h,prnbuf		;; 110d: 21 8c 2f    ../
	dad	d		;; 1110: 19          .
	mov	a,m		;; 1111: 7e          ~
	cpi	tab		;; 1112: fe 09       ..
	jz	L1105		;; 1114: ca 05 11    ...
	lxi	h,prncol		;; 1117: 21 c9 11    ...
	mov	a,m		;; 111a: 7e          ~
	mvi	m,0		;; 111b: 36 00       6.
	sta	L3004		;; 111d: 32 04 30    2.0
	call	L2595		;; 1120: cd 95 25    ..%
	xra	a		;; 1123: af          .
	sta	L2ea5		;; 1124: 32 a5 2e    2..
L1127:	call	L1c18		;; 1127: cd 18 1c    ...
	push	h		;; 112a: e5          .
	mov	a,h		;; 112b: 7c          |
	call	prnhex		;; 112c: cd 7a 0f    .z.
	pop	h		;; 112f: e1          .
	mov	a,l		;; 1130: 7d          }
	call	prnhex		;; 1131: cd 7a 0f    .z.
	mvi	a,' '		;; 1134: 3e 20       > 
	call	prnchr		;; 1136: cd 75 11    .u.
	lxi	h,L2ea5		;; 1139: 21 a5 2e    ...
	mov	a,m		;; 113c: 7e          ~
	adi	5		;; 113d: c6 05       ..
	mov	m,a		;; 113f: 77          w
	lda	L2ea6		;; 1140: 3a a6 2e    :..
L1143:	ora	a		;; 1143: b7          .
	jz	L1157		;; 1144: ca 57 11    .W.
	dcr	a		;; 1147: 3d          =
	push	psw		;; 1148: f5          .
	call	L1c2a		;; 1149: cd 2a 1c    .*.
	call	prnchr		;; 114c: cd 75 11    .u.
	lxi	h,L2ea5		;; 114f: 21 a5 2e    ...
	inr	m		;; 1152: 34          4
	pop	psw		;; 1153: f1          .
	jmp	L1143		;; 1154: c3 43 11    .C.

L1157:	lhld	cursym		;; 1157: 2a 56 30    *V0
	mov	e,m		;; 115a: 5e          ^
	inx	h		;; 115b: 23          #
	mov	d,m		;; 115c: 56          V
	xchg			;; 115d: eb          .
	shld	cursym		;; 115e: 22 56 30    "V0
	jmp	L10bd		;; 1161: c3 bd 10    ...

L1164:	lxi	h,L2ea7		;; 1164: 21 a7 2e    ...
	dcr	m		;; 1167: 35          5
	jnz	L10af		;; 1168: c2 af 10    ...
	lda	prncol		;; 116b: 3a c9 11    :..
	sta	L3004		;; 116e: 32 04 30    2.0
	call	L2595		;; 1171: cd 95 25    ..%
	ret			;; 1174: c9          .

prnchr:	lxi	h,prncol		;; 1175: 21 c9 11    ...
	mov	e,m		;; 1178: 5e          ^
	mvi	d,0		;; 1179: 16 00       ..
	inr	m		;; 117b: 34          4
	lxi	h,prnbuf		;; 117c: 21 8c 2f    ../
	dad	d		;; 117f: 19          .
	mov	m,a		;; 1180: 77          w
	ret			;; 1181: c9          .

Rerror:	push	psw		;; 1182: f5          .
	push	b		;; 1183: c5          .
	mvi	a,'R'		;; 1184: 3e 52       >R
	call	setere		;; 1186: cd 98 25    ..%
	pop	b		;; 1189: c1          .
	pop	psw		;; 118a: f1          .
	ret			;; 118b: c9          .

Verror:	push	psw		;; 118c: f5          .
	push	h		;; 118d: e5          .
	mvi	a,'V'		;; 118e: 3e 56       >V
	call	setere		;; 1190: cd 98 25    ..%
	pop	h		;; 1193: e1          .
	pop	psw		;; 1194: f1          .
	ret			;; 1195: c9          .

Derror:	push	psw		;; 1196: f5          .
	mvi	a,'D'		;; 1197: 3e 44       >D
	jmp	L11bd		;; 1199: c3 bd 11    ...

Perror:	push	psw		;; 119c: f5          .
	mvi	a,'P'		;; 119d: 3e 50       >P
	jmp	L11bd		;; 119f: c3 bd 11    ...

Lerror:	push	psw		;; 11a2: f5          .
	mvi	a,'L'		;; 11a3: 3e 4c       >L
	jmp	L11bd		;; 11a5: c3 bd 11    ...

Oerror:	push	psw		;; 11a8: f5          .
	mvi	a,'O'		;; 11a9: 3e 4f       >O
	jmp	L11bd		;; 11ab: c3 bd 11    ...

Berror:	push	psw		;; 11ae: f5          .
	mvi	a,'B'		;; 11af: 3e 42       >B
	jmp	L11bd		;; 11b1: c3 bd 11    ...

Serror:	push	psw		;; 11b4: f5          .
	mvi	a,'S'		;; 11b5: 3e 53       >S
	jmp	L11bd		;; 11b7: c3 bd 11    ...

Nerror:	push	psw		;; 11ba: f5          .
	mvi	a,'N'		;; 11bb: 3e 4e       >N
L11bd:	call	setere		;; 11bd: cd 98 25    ..%
	pop	psw		;; 11c0: f1          .
	ret			;; 11c1: c9          .

L11c2:	db	0
L11c3:	db	0,0
L11c5:	db	0,0
L11c7:	db	0,0
prncol:	db	0
L11ca:	db	0
L11cb:	db	0
L11cc:	db	0
L11cd:	db	0
L11ce:	db	0,0,0,0,0,0,0,0
L11d6:	db	0,0
L11d8:	db	0,0
L11da:	db	0
L11db:	db	0
L11dc:	db	0,0
L11de:	db	0,0
L11e0:	db	0,0
L11e2:	db	0,0

L11e4:	lhld	L11e2		;; 11e4: 2a e2 11    *..
	call	compr1		;; 11e7: cd dd 0e    ...
	rnz			;; 11ea: c0          .
	mvi	m,0		;; 11eb: 36 00       6.
	ret			;; 11ed: c9          .

L11ee:	shld	L2ef4		;; 11ee: 22 f4 2e    "..
	mov	a,m		;; 11f1: 7e          ~
	cpi	cr		;; 11f2: fe 0d       ..
	rnz			;; 11f4: c0          .
	mvi	m,0		;; 11f5: 36 00       6.
	ret			;; 11f7: c9          .

	db	0,0
	db	0afh,0,0,0,14h,13h ; serial number?

; Module begin L1200
L1200:	jmp	L1600		;; 0c3h,0,16h
L1203:	jmp	L142d		;; 1203: c3 2d 14    .-.
	jmp	L131e		;; 1206: c3 1e 13    ...
divide:	jmp	div16		;; 1209: c3 e8 12    ...

L120c:	db	0

; some sort of dual stack/fifo - 10 bytes/entries
L120d:	db	0,0,0,0,0,0,0,0,0,0
L1217:	db	0,0,0,0,0,0,0,0,0,0

; some sort of stack/fifo - 8 entries
L1221:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

L1231:	db	0	; L120d "sp"
L1232:	db	0	; L1221 "sp"

; "push" HL into L1221 "fifo stack"
; "stack" wraps after 8 entries...
L1233:	xchg			;; 1233: eb          .
	lxi	h,L1232		;; 1234: 21 32 12    .2.
	mov	a,m		;; 1237: 7e          ~
	cpi	16		;; 1238: fe 10       ..
	jc	L1242		;; 123a: da 42 12    .B.
	call	Eerror		;; 123d: cd e4 15    ...
	mvi	m,0		;; 1240: 36 00       6.
L1242:	mov	a,m		;; 1242: 7e          ~
	inr	m		;; 1243: 34          4
	inr	m		;; 1244: 34          4
	mov	c,a		;; 1245: 4f          O
	mvi	b,0		;; 1246: 06 00       ..
	lxi	h,L1221		;; 1248: 21 21 12    ...
	dad	b		;; 124b: 09          .
	mov	m,e		;; 124c: 73          s
	inx	h		;; 124d: 23          #
	mov	m,d		;; 124e: 72          r
	ret			;; 124f: c9          .

; push bytes onto parallel stacks L120d, L1217
; A => L120d, B => L1217
L1250:	push	psw		;; 1250: f5          .
	lxi	h,L1231		;; 1251: 21 31 12    .1.
	mov	a,m		;; 1254: 7e          ~
	cpi	10		;; 1255: fe 0a       ..
	jc	L125f		;; 1257: da 5f 12    ._.
	mvi	m,0		;; 125a: 36 00       6.
	call	Eerror		;; 125c: cd e4 15    ...
L125f:	mov	e,m		;; 125f: 5e          ^
	mvi	d,0		;; 1260: 16 00       ..
	inr	m		;; 1262: 34          4
	pop	psw		;; 1263: f1          .
	lxi	h,L120d		;; 1264: 21 0d 12    ...
	dad	d		;; 1267: 19          .
	mov	m,a		;; 1268: 77          w
	lxi	h,L1217		;; 1269: 21 17 12    ...
	dad	d		;; 126c: 19          .
	mov	m,b		;; 126d: 70          p
	ret			;; 126e: c9          .

; "pop" HL off L1221 "fifo stack"
L126f:	lxi	h,L1232		;; 126f: 21 32 12    .2.
	mov	a,m		;; 1272: 7e          ~
	ora	a		;; 1273: b7          .
	jnz	L127e		;; 1274: c2 7e 12    .~.
	call	Eerror		;; 1277: cd e4 15    ...
	lxi	h,0		;; 127a: 21 00 00    ...
	ret			;; 127d: c9          .

L127e:	dcr	m		;; 127e: 35          5
	dcr	m		;; 127f: 35          5
	mov	c,m		;; 1280: 4e          N
	mvi	b,0		;; 1281: 06 00       ..
	lxi	h,L1221		;; 1283: 21 21 12    ...
	dad	b		;; 1286: 09          .
	mov	c,m		;; 1287: 4e          N
	inx	h		;; 1288: 23          #
	mov	h,m		;; 1289: 66          f
	mov	l,c		;; 128a: 69          i
	ret			;; 128b: c9          .

L128c:	call	L126f		;; 128c: cd 6f 12    .o.
	xchg			;; 128f: eb          .
	call	L126f		;; 1290: cd 6f 12    .o.
	ret			;; 1293: c9          .

L1294:	mov	l,a		;; 1294: 6f          o
	mvi	h,0		;; 1295: 26 00       &.
	dad	h		;; 1297: 29          )
	lxi	d,L12a1		;; 1298: 11 a1 12    ...
	dad	d		;; 129b: 19          .
	mov	e,m		;; 129c: 5e          ^
	inx	h		;; 129d: 23          #
	mov	h,m		;; 129e: 66          f
	mov	l,e		;; 129f: 6b          k
	pchl			;; 12a0: e9          .

L12a1:	dw	L1339	; 0
	dw	L1342	; 1
	dw	L1349	; 2
	dw	L134f	; 3
	dw	L135b	; 4
	dw	L136f	; 5
	dw	L1376	; 6
	dw	L1380	; 7
	dw	L138f	; 8
	dw	L139b	; 9
	dw	L13a8	; 10
	dw	L13b4	; 11
	dw	L13bb	; 12
	dw	L13c2	; 13
	dw	L13da	; 14
	dw	L13e1	; 15
	dw	L13ed	; 16
	dw	L13f9	; 17
	dw	L1405	; 18
	dw	L140c	; 19
	dw	Eerror	; 20

L12cb:	call	L128c		;; 12cb: cd 8c 12    ...
	mov	a,d		;; 12ce: 7a          z
	ora	a		;; 12cf: b7          .
	jnz	L12d7		;; 12d0: c2 d7 12    ...
	mov	a,e		;; 12d3: 7b          {
	cpi	17		;; 12d4: fe 11       ..
	rc			;; 12d6: d8          .
L12d7:	call	Eerror		;; 12d7: cd e4 15    ...
	mvi	a,16		;; 12da: 3e 10       >.
	ret			;; 12dc: c9          .

L12dd:	xra	a		;; 12dd: af          .
	sub	l		;; 12de: 95          .
	mov	l,a		;; 12df: 6f          o
	mvi	a,0		;; 12e0: 3e 00       >.
	sbb	h		;; 12e2: 9c          .
	mov	h,a		;; 12e3: 67          g
	ret			;; 12e4: c9          .

L12e5:	call	L128c		;; 12e5: cd 8c 12    ...
; some sort of division operation
div16:	xchg			;; 12e8: eb          .
	shld	L131b		;; 12e9: 22 1b 13    "..
	lxi	h,L131d		;; 12ec: 21 1d 13    ...
	mvi	m,17		;; 12ef: 36 11       6.
	lxi	b,0		;; 12f1: 01 00 00    ...
	push	b		;; 12f4: c5          .
	xra	a		;; 12f5: af          .
L12f6:	mov	a,e		;; 12f6: 7b          {
	ral			;; 12f7: 17          .
	mov	e,a		;; 12f8: 5f          _
	mov	a,d		;; 12f9: 7a          z
	ral			;; 12fa: 17          .
	mov	d,a		;; 12fb: 57          W
	dcr	m		;; 12fc: 35          5
	pop	h		;; 12fd: e1          .
	rz			;; 12fe: c8          .
	mvi	a,0		;; 12ff: 3e 00       >.
	aci	0		;; 1301: ce 00       ..
	dad	h		;; 1303: 29          )
	mov	b,h		;; 1304: 44          D
	add	l		;; 1305: 85          .
	lhld	L131b		;; 1306: 2a 1b 13    *..
	sub	l		;; 1309: 95          .
	mov	c,a		;; 130a: 4f          O
	mov	a,b		;; 130b: 78          x
	sbb	h		;; 130c: 9c          .
	mov	b,a		;; 130d: 47          G
	push	b		;; 130e: c5          .
	jnc	L1314		;; 130f: d2 14 13    ...
	dad	b		;; 1312: 09          .
	xthl			;; 1313: e3          .
L1314:	lxi	h,L131d		;; 1314: 21 1d 13    ...
	cmc			;; 1317: 3f          ?
	jmp	L12f6		;; 1318: c3 f6 12    ...

L131b:	db	0,0
L131d:	db	0

L131e:	mov	b,h		;; 131e: 44          D
	mov	c,l		;; 131f: 4d          M
	lxi	h,0		;; 1320: 21 00 00    ...
L1323:	xra	a		;; 1323: af          .
	mov	a,b		;; 1324: 78          x
	rar			;; 1325: 1f          .
	mov	b,a		;; 1326: 47          G
	mov	a,c		;; 1327: 79          y
	rar			;; 1328: 1f          .
	mov	c,a		;; 1329: 4f          O
	jc	L1332		;; 132a: da 32 13    .2.
	ora	b		;; 132d: b0          .
	rz			;; 132e: c8          .
	jmp	L1333		;; 132f: c3 33 13    .3.

L1332:	dad	d		;; 1332: 19          .
L1333:	xchg			;; 1333: eb          .
	dad	h		;; 1334: 29          )
	xchg			;; 1335: eb          .
	jmp	L1323		;; 1336: c3 23 13    .#.

L1339:	call	L128c		;; 1339: cd 8c 12    ...
	call	L131e		;; 133c: cd 1e 13    ...
	jmp	L1411		;; 133f: c3 11 14    ...

L1342:	call	L12e5		;; 1342: cd e5 12    ...
	xchg			;; 1345: eb          .
	jmp	L1411		;; 1346: c3 11 14    ...

L1349:	call	L12e5		;; 1349: cd e5 12    ...
	jmp	L1411		;; 134c: c3 11 14    ...

L134f:	call	L12cb		;; 134f: cd cb 12    ...
L1352:	ora	a		;; 1352: b7          .
	jz	L1411		;; 1353: ca 11 14    ...
	dad	h		;; 1356: 29          )
	dcr	a		;; 1357: 3d          =
	jmp	L1352		;; 1358: c3 52 13    .R.

L135b:	call	L12cb		;; 135b: cd cb 12    ...
L135e:	ora	a		;; 135e: b7          .
	jz	L1411		;; 135f: ca 11 14    ...
	push	psw		;; 1362: f5          .
	xra	a		;; 1363: af          .
	mov	a,h		;; 1364: 7c          |
	rar			;; 1365: 1f          .
	mov	h,a		;; 1366: 67          g
	mov	a,l		;; 1367: 7d          }
	rar			;; 1368: 1f          .
	mov	l,a		;; 1369: 6f          o
	pop	psw		;; 136a: f1          .
	dcr	a		;; 136b: 3d          =
	jmp	L135e		;; 136c: c3 5e 13    .^.

L136f:	call	L128c		;; 136f: cd 8c 12    ...
L1372:	dad	d		;; 1372: 19          .
	jmp	L1411		;; 1373: c3 11 14    ...

L1376:	call	L128c		;; 1376: cd 8c 12    ...
	xchg			;; 1379: eb          .
	call	L12dd		;; 137a: cd dd 12    ...
	jmp	L1372		;; 137d: c3 72 13    .r.

L1380:	call	L126f		;; 1380: cd 6f 12    .o.
L1383:	call	L12dd		;; 1383: cd dd 12    ...
	jmp	L1411		;; 1386: c3 11 14    ...

L1389:	mov	a,d		;; 1389: 7a          z
	cmp	h		;; 138a: bc          .
	rnz			;; 138b: c0          .
	mov	a,e		;; 138c: 7b          {
	cmp	l		;; 138d: bd          .
	ret			;; 138e: c9          .

L138f:	call	L128c		;; 138f: cd 8c 12    ...
	call	L1389		;; 1392: cd 89 13    ...
	jnz	L13d4		;; 1395: c2 d4 13    ...
	jmp	L13ce		;; 1398: c3 ce 13    ...

L139b:	call	L128c		;; 139b: cd 8c 12    ...
L139e:	mov	a,l		;; 139e: 7d          }
	sub	e		;; 139f: 93          .
	mov	a,h		;; 13a0: 7c          |
	sbb	d		;; 13a1: 9a          .
	jc	L13ce		;; 13a2: da ce 13    ...
	jmp	L13d4		;; 13a5: c3 d4 13    ...

L13a8:	call	L128c		;; 13a8: cd 8c 12    ...
L13ab:	call	L1389		;; 13ab: cd 89 13    ...
	jz	L13ce		;; 13ae: ca ce 13    ...
	jmp	L139e		;; 13b1: c3 9e 13    ...

L13b4:	call	L128c		;; 13b4: cd 8c 12    ...
	xchg			;; 13b7: eb          .
	jmp	L139e		;; 13b8: c3 9e 13    ...

L13bb:	call	L128c		;; 13bb: cd 8c 12    ...
	xchg			;; 13be: eb          .
	jmp	L13ab		;; 13bf: c3 ab 13    ...

L13c2:	call	L128c		;; 13c2: cd 8c 12    ...
	call	L1389		;; 13c5: cd 89 13    ...
	jnz	L13ce		;; 13c8: c2 ce 13    ...
	jmp	L13d4		;; 13cb: c3 d4 13    ...

L13ce:	lxi	h,0ffffh	;; 13ce: 21 ff ff    ...
	jmp	L1411		;; 13d1: c3 11 14    ...

L13d4:	lxi	h,0		;; 13d4: 21 00 00    ...
	jmp	L1411		;; 13d7: c3 11 14    ...

L13da:	call	L126f		;; 13da: cd 6f 12    .o.
	inx	h		;; 13dd: 23          #
	jmp	L1383		;; 13de: c3 83 13    ...

L13e1:	call	L128c		;; 13e1: cd 8c 12    ...
	mov	a,d		;; 13e4: 7a          z
	ana	h		;; 13e5: a4          .
	mov	h,a		;; 13e6: 67          g
	mov	a,e		;; 13e7: 7b          {
	ana	l		;; 13e8: a5          .
	mov	l,a		;; 13e9: 6f          o
	jmp	L1411		;; 13ea: c3 11 14    ...

L13ed:	call	L128c		;; 13ed: cd 8c 12    ...
	mov	a,d		;; 13f0: 7a          z
	ora	h		;; 13f1: b4          .
	mov	h,a		;; 13f2: 67          g
	mov	a,e		;; 13f3: 7b          {
	ora	l		;; 13f4: b5          .
	mov	l,a		;; 13f5: 6f          o
	jmp	L1411		;; 13f6: c3 11 14    ...

L13f9:	call	L128c		;; 13f9: cd 8c 12    ...
	mov	a,d		;; 13fc: 7a          z
	xra	h		;; 13fd: ac          .
	mov	h,a		;; 13fe: 67          g
	mov	a,e		;; 13ff: 7b          {
	xra	l		;; 1400: ad          .
	mov	l,a		;; 1401: 6f          o
	jmp	L1411		;; 1402: c3 11 14    ...

L1405:	call	L126f		;; 1405: cd 6f 12    .o.
	mov	l,h		;; 1408: 6c          l
	jmp	L140f		;; 1409: c3 0f 14    ...

L140c:	call	L126f		;; 140c: cd 6f 12    .o.
L140f:	mvi	h,0		;; 140f: 26 00       &.
L1411:	jmp	L1233		;; 1411: c3 33 12    .3.

endstm:	lda	L3005		;; 1414: 3a 05 30    :.0
	cpi	004h		;; 1417: fe 04       ..
	rnz			;; 1419: c0          .
	lda	tokbuf+1		;; 141a: 3a 09 30    :.0
	cpi	cr		;; 141d: fe 0d       ..
	rz			;; 141f: c8          .
	cpi	';'		;; 1420: fe 3b       .;
	rz			;; 1422: c8          .
	cpi	'!'		;; 1423: fe 21       ..
	ret			;; 1425: c9          .

endtok:	call	endstm		;; 1426: cd 14 14    ...
	rz			;; 1429: c8          .
	cpi	','		;; 142a: fe 2c       .,
	ret			;; 142c: c9          .

L142d:	xra	a		;; 142d: af          .
	sta	L1231		;; 142e: 32 31 12    21.
	sta	L1232		;; 1431: 32 32 12    22.
	dcr	a		;; 1434: 3d          =
	sta	L120c		;; 1435: 32 0c 12    2..
	lxi	h,0		;; 1438: 21 00 00    ...
	shld	L3049		;; 143b: 22 49 30    "I0
L143e:	call	endtok		;; 143e: cd 26 14    .&.
	jnz	L1471		;; 1441: c2 71 14    .q.
; "pop" something and process it... until empty
L1444:	lxi	h,L1231		;; 1444: 21 31 12    .1.
	mov	a,m		;; 1447: 7e          ~
	ora	a		;; 1448: b7          .
	jz	L145c		;; 1449: ca 5c 14    .\.
	dcr	m		;; 144c: 35          5
	mov	e,a		;; 144d: 5f          _
	dcr	e		;; 144e: 1d          .
	mvi	d,0		;; 144f: 16 00       ..
	lxi	h,L120d		;; 1451: 21 0d 12    ...
	dad	d		;; 1454: 19          .
	mov	a,m		;; 1455: 7e          ~
	call	L1294		;; 1456: cd 94 12    ...
	jmp	L1444		;; 1459: c3 44 14    .D.

L145c:	lda	L1232		;; 145c: 3a 32 12    :2.
	cpi	2		;; 145f: fe 02       ..
	cnz	Eerror		;; 1461: c4 e4 15    ...
	lda	curerr		;; 1464: 3a 8c 2f    :./
	cpi	' '		;; 1467: fe 20       . 
	rnz			;; 1469: c0          .
	lhld	L1221		;; 146a: 2a 21 12    *..
	shld	L3049		;; 146d: 22 49 30    "I0
	ret			;; 1470: c9          .

; get 1 or 2 chars from tokbuf buffer (error if 0 or >2)
L1471:	lda	curerr		;; 1471: 3a 8c 2f    :./
	cpi	' '		;; 1474: fe 20       . 
	jnz	L15d0		;; 1476: c2 d0 15    ...
	lda	L3005		;; 1479: 3a 05 30    :.0
	cpi	003h		;; 147c: fe 03       ..
	jnz	L149d		;; 147e: c2 9d 14    ...
	lda	tokbuf		;; 1481: 3a 08 30    :.0
	ora	a		;; 1484: b7          .
	cz	Eerror		;; 1485: cc e4 15    ...
	cpi	003h		;; 1488: fe 03       ..
	cnc	Eerror		;; 148a: d4 e4 15    ...
	mvi	d,0		;; 148d: 16 00       ..
	lxi	h,tokbuf+1		;; 148f: 21 09 30    ..0
	mov	e,m		;; 1492: 5e          ^
	inx	h		;; 1493: 23          #
	dcr	a		;; 1494: 3d          =
	jz	L1499		;; 1495: ca 99 14    ...
	mov	d,m		;; 1498: 56          V
L1499:	xchg			;; 1499: eb          .
	jmp	L15cd		;; 149a: c3 cd 15    ...

L149d:	cpi	002h		;; 149d: fe 02       ..
	jnz	L14a8		;; 149f: c2 a8 14    ...
	lhld	L3006		;; 14a2: 2a 06 30    *.0
	jmp	L15cd		;; 14a5: c3 cd 15    ...

L14a8:	call	L2106		;; 14a8: cd 06 21    ...
	jnz	L158d		;; 14ab: c2 8d 15    ...
	cpi	25		;; 14ae: fe 19       ..
	jnc	L1582		;; 14b0: d2 82 15    ...
	cpi	24		;; 14b3: fe 18       ..
	jnz	L14f1		;; 14b5: c2 f1 14    ...
	call	L160c		;; 14b8: cd 0c 16    ...
	call	endstm		;; 14bb: cd 14 14    ...
	jz	L14e8		;; 14be: ca e8 14    ...
	lda	L3005		;; 14c1: 3a 05 30    :.0
	cpi	003h		;; 14c4: fe 03       ..
	jnz	L14d9		;; 14c6: c2 d9 14    ...
	lda	tokbuf		;; 14c9: 3a 08 30    :.0
	ora	a		;; 14cc: b7          .
	jnz	L14d9		;; 14cd: c2 d9 14    ...
	call	L1606		;; 14d0: cd 06 16    ...
	call	endtok		;; 14d3: cd 26 14    .&.
	jz	L14e8		;; 14d6: ca e8 14    ...
L14d9:	call	L160c		;; 14d9: cd 0c 16    ...
	call	endstm		;; 14dc: cd 14 14    ...
	jnz	L14d9		;; 14df: c2 d9 14    ...
	lxi	h,0		;; 14e2: 21 00 00    ...
	jmp	L14eb		;; 14e5: c3 eb 14    ...

L14e8:	lxi	h,0ffffh	;; 14e8: 21 ff ff    ...
L14eb:	call	L15d6		;; 14eb: cd d6 15    ...
	jmp	L143e		;; 14ee: c3 3e 14    .>.

L14f1:	cpi	20		;; 14f1: fe 14       ..
	mov	c,a		;; 14f3: 4f          O
	lda	L120c		;; 14f4: 3a 0c 12    :..
	jnz	L1507		;; 14f7: c2 07 15    ...
	ora	a		;; 14fa: b7          .
	cz	Eerror		;; 14fb: cc e4 15    ...
	mvi	a,0ffh		;; 14fe: 3e ff       >.
	sta	L120c		;; 1500: 32 0c 12    2..
	mov	a,c		;; 1503: 79          y
	jmp	L1555		;; 1504: c3 55 15    .U.

L1507:	ora	a		;; 1507: b7          .
	jnz	L1560		;; 1508: c2 60 15    .`.
L150b:	push	b		;; 150b: c5          .
	lda	L1231		;; 150c: 3a 31 12    :1.
	ora	a		;; 150f: b7          .
	jz	L1530		;; 1510: ca 30 15    .0.
	mov	e,a		;; 1513: 5f          _
	dcr	e		;; 1514: 1d          .
	mvi	d,0		;; 1515: 16 00       ..
	lxi	h,L1217		;; 1517: 21 17 12    ...
	dad	d		;; 151a: 19          .
	mov	a,m		;; 151b: 7e          ~
	cmp	b		;; 151c: b8          .
	jc	L1530		;; 151d: da 30 15    .0.
	lxi	h,L1231		;; 1520: 21 31 12    .1.
	mov	m,e		;; 1523: 73          s
	lxi	h,L120d		;; 1524: 21 0d 12    ...
	dad	d		;; 1527: 19          .
	mov	a,m		;; 1528: 7e          ~
	call	L1294		;; 1529: cd 94 12    ...
	pop	b		;; 152c: c1          .
	jmp	L150b		;; 152d: c3 0b 15    ...

L1530:	pop	b		;; 1530: c1          .
	mov	a,c		;; 1531: 79          y
	cpi	21		;; 1532: fe 15       ..
	jnz	L1555		;; 1534: c2 55 15    .U.
	lxi	h,L1231		;; 1537: 21 31 12    .1.
	mov	a,m		;; 153a: 7e          ~
	ora	a		;; 153b: b7          .
	jz	L154e		;; 153c: ca 4e 15    .N.
	dcr	a		;; 153f: 3d          =
	mov	m,a		;; 1540: 77          w
	mov	e,a		;; 1541: 5f          _
	mvi	d,0		;; 1542: 16 00       ..
	lxi	h,L120d		;; 1544: 21 0d 12    ...
	dad	d		;; 1547: 19          .
	mov	a,m		;; 1548: 7e          ~
	cpi	20		;; 1549: fe 14       ..
	jz	L1551		;; 154b: ca 51 15    .Q.
L154e:	call	Eerror		;; 154e: cd e4 15    ...
L1551:	xra	a		;; 1551: af          .
	jmp	L155a		;; 1552: c3 5a 15    .Z.

L1555:	call	L1250		;; 1555: cd 50 12    .P.
	mvi	a,0ffh		;; 1558: 3e ff       >.
L155a:	sta	L120c		;; 155a: 32 0c 12    2..
	jmp	L15d0		;; 155d: c3 d0 15    ...

L1560:	mov	a,c		;; 1560: 79          y
	cpi	5		;; 1561: fe 05       ..
	jz	L15d0		;; 1563: ca d0 15    ...
	cpi	6		;; 1566: fe 06       ..
	jnz	L1570		;; 1568: c2 70 15    .p.
	inr	a		;; 156b: 3c          <
	mov	c,a		;; 156c: 4f          O
	jmp	L150b		;; 156d: c3 0b 15    ...

L1570:	cpi	14		;; 1570: fe 0e       ..
	jz	L150b		;; 1572: ca 0b 15    ...
	cpi	18		;; 1575: fe 12       ..
	jz	L150b		;; 1577: ca 0b 15    ...
	cpi	19		;; 157a: fe 13       ..
	cnz	Eerror		;; 157c: c4 e4 15    ...
	jmp	L150b		;; 157f: c3 0b 15    ...

L1582:	cpi	26		;; 1582: fe 1a       ..
	cz	Eerror		;; 1584: cc e4 15    ...
	mov	l,b		;; 1587: 68          h
	mvi	h,0		;; 1588: 26 00       &.
	jmp	L15cd		;; 158a: c3 cd 15    ...

L158d:	lda	L3005		;; 158d: 3a 05 30    :.0
	cpi	004h		;; 1590: fe 04       ..
	jnz	L15ac		;; 1592: c2 ac 15    ...
	lda	tokbuf+1		;; 1595: 3a 09 30    :.0
	cpi	'$'		;; 1598: fe 24       .$
	jz	L15a6		;; 159a: ca a6 15    ...
	call	Eerror		;; 159d: cd e4 15    ...
	lxi	h,0		;; 15a0: 21 00 00    ...
	jmp	L15cd		;; 15a3: c3 cd 15    ...

L15a6:	lhld	linadr		;; 15a6: 2a 52 30    *R0
	jmp	L15cd		;; 15a9: c3 cd 15    ...

L15ac:	call	L1c06		;; 15ac: cd 06 1c    ...
	call	L1c09		;; 15af: cd 09 1c    ...
	jnz	L15c0		;; 15b2: c2 c0 15    ...
	mvi	a,'P'		;; 15b5: 3e 50       >P
	call	setere		;; 15b7: cd 98 25    ..%
	call	L1c0c		;; 15ba: cd 0c 1c    ...
	jmp	L15ca		;; 15bd: c3 ca 15    ...

L15c0:	call	L1c12		;; 15c0: cd 12 1c    ...
	ani	007h		;; 15c3: e6 07       ..
	mvi	a,'U'		;; 15c5: 3e 55       >U
	cz	setere		;; 15c7: cc 98 25    ..%
L15ca:	call	L1c18		;; 15ca: cd 18 1c    ...
L15cd:	call	L15d6		;; 15cd: cd d6 15    ...
L15d0:	call	L1606		;; 15d0: cd 06 16    ...
	jmp	L143e		;; 15d3: c3 3e 14    .>.

L15d6:	lda	L120c		;; 15d6: 3a 0c 12    :..
	ora	a		;; 15d9: b7          .
	cz	Eerror		;; 15da: cc e4 15    ...
	xra	a		;; 15dd: af          .
	sta	L120c		;; 15de: 32 0c 12    2..
	jmp	L1233		;; 15e1: c3 33 12    .3.

Eerror:	push	h		;; 15e4: e5          .
	mvi	a,'E'		;; 15e5: 3e 45       >E
	call	setere		;; 15e7: cd 98 25    ..%
	pop	h		;; 15ea: e1          .
	ret			;; 15eb: c9          .

	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

; Module begin L1600
L1600:	jmp	L1c00		;; 1600: c3 00 1c    ...
L1603:	jmp	L17f1		;; 1603: c3 f1 17    ...
L1606:	jmp	L18b3		;; 1606: c3 b3 18    ...
L1609:	jmp	L1666		;; 1609: c3 66 16    .f.
L160c:	jmp	L1afc		;; 160c: c3 fc 1a    ...

L160f:	db	1ah
L1610:	db	0,0,0
L1613:	db	0,0,0
L1616:	db	0
L1617:	db	1
L1618:	db	1ah

L1619:	lda	L2ea3		;; 1619: 3a a3 2e    :..
	ora	a		;; 161c: b7          .
	jz	L164f		;; 161d: ca 4f 16    .O.
	lhld	L2ef4		;; 1620: 2a f4 2e    *..
	mov	a,m		;; 1623: 7e          ~
	ora	a		;; 1624: b7          .
	jnz	L1648		;; 1625: c2 48 16    .H.
	lda	L2ea4		;; 1628: 3a a4 2e    :..
	cpi	002h		;; 162b: fe 02       ..
	jz	L163d		;; 162d: ca 3d 16    .=.
	lxi	h,L1618		;; 1630: 21 18 16    ...
	inr	m		;; 1633: 34          4
	mvi	a,0		;; 1634: 3e 00       >.
	rnz			;; 1636: c0          .
	call	L1be7		;; 1637: cd e7 1b    ...
	call	L2595		;; 163a: cd 95 25    ..%
L163d:	call	L1c30		;; 163d: cd 30 1c    .0.
	lda	L2f14		;; 1640: 3a 14 2f    :./
	ora	a		;; 1643: b7          .
	rnz			;; 1644: c0          .
	jmp	L1619		;; 1645: c3 19 16    ...

L1648:	inx	h		;; 1648: 23          #
	shld	L2ef4		;; 1649: 22 f4 2e    "..
	jmp	L20d8		;; 164c: c3 d8 20    .. 

L164f:	call	L2586		;; 164f: cd 86 25    ..%
L1652:	sta	L1618		;; 1652: 32 18 16    2..
	mov	b,a		;; 1655: 47          G
	lda	L3005		;; 1656: 3a 05 30    :.0
	cpi	003h		;; 1659: fe 03       ..
	mov	a,b		;; 165b: 78          x
	rz			;; 165c: c8          .
	cpi	'a'		;; 165d: fe 61       .a
	rc			;; 165f: d8          .
	cpi	'z'+1		;; 1660: fe 7b       .{
	rnc			;; 1662: d0          .
	ani	05fh		;; 1663: e6 5f       ._
	ret			;; 1665: c9          .

L1666:	push	psw		;; 1666: f5          .
	cpi	cr		;; 1667: fe 0d       ..
	jz	L1687		;; 1669: ca 87 16    ...
	cpi	lf		;; 166c: fe 0a       ..
	jz	L1687		;; 166e: ca 87 16    ...
	lda	L3004		;; 1671: 3a 04 30    :.0
	cpi	120		;; 1674: fe 78       .x
	jnc	L1687		;; 1676: d2 87 16    ...
	mov	e,a		;; 1679: 5f          _
	mvi	d,0		;; 167a: 16 00       ..
	inr	a		;; 167c: 3c          <
	sta	L3004		;; 167d: 32 04 30    2.0
	lxi	h,prnbuf	;; 1680: 21 8c 2f    ../
	dad	d		;; 1683: 19          .
	pop	psw		;; 1684: f1          .
	mov	m,a		;; 1685: 77          w
	ret			;; 1686: c9          .

L1687:	pop	psw		;; 1687: f1          .
	ret			;; 1688: c9          .

L1689:	lda	L2f65		;; 1689: 3a 65 2f    :e/
	call	L1853		;; 168c: cd 53 18    .S.
	rnz			;; 168f: c0          .
	lda	L2f65		;; 1690: 3a 65 2f    :e/
	call	L1839		;; 1693: cd 39 18    .9.
	ret			;; 1696: c9          .

L1697:	xra	a		;; 1697: af          .
	sta	L2f66		;; 1698: 32 66 2f    2f/
	sta	L2f64		;; 169b: 32 64 2f    2d/
	call	L1619		;; 169e: cd 19 16    ...
	sta	L2f65		;; 16a1: 32 65 2f    2e/
	lda	L3005		;; 16a4: 3a 05 30    :.0
	cpi	6		;; 16a7: fe 06       ..
	rz			;; 16a9: c8          .
	lda	L2f65		;; 16aa: 3a 65 2f    :e/
	cpi	128		;; 16ad: fe 80       ..
	jc	L16c6		;; 16af: da c6 16    ...
	call	L210c		;; 16b2: cd 0c 21    ...
	sta	L2f66		;; 16b5: 32 66 2f    2f/
	lxi	d,L2f67		;; 16b8: 11 67 2f    .g/
L16bb:	mov	a,m		;; 16bb: 7e          ~
	stax	d		;; 16bc: 12          .
	inx	h		;; 16bd: 23          #
	inx	d		;; 16be: 13          .
	dcr	b		;; 16bf: 05          .
	jnz	L16bb		;; 16c0: c2 bb 16    ...
	jmp	L16e5		;; 16c3: c3 e5 16    ...

L16c6:	call	L1853		;; 16c6: cd 53 18    .S.
	rz			;; 16c9: c8          .
L16ca:	call	L1689		;; 16ca: cd 89 16    ...
	jz	L16f0		;; 16cd: ca f0 16    ...
	lxi	h,L2f66		;; 16d0: 21 66 2f    .f/
	mov	a,m		;; 16d3: 7e          ~
	cpi	15		;; 16d4: fe 0f       ..
	jnc	L16ee		;; 16d6: d2 ee 16    ...
	inr	m		;; 16d9: 34          4
	lxi	h,L2f67		;; 16da: 21 67 2f    .g/
	mov	e,a		;; 16dd: 5f          _
	mvi	d,0		;; 16de: 16 00       ..
	dad	d		;; 16e0: 19          .
	lda	L2f65		;; 16e1: 3a 65 2f    :e/
	mov	m,a		;; 16e4: 77          w
L16e5:	call	L1619		;; 16e5: cd 19 16    ...
	sta	L2f65		;; 16e8: 32 65 2f    2e/
	jmp	L16ca		;; 16eb: c3 ca 16    ...

L16ee:	xra	a		;; 16ee: af          .
	ret			;; 16ef: c9          .

L16f0:	xra	a		;; 16f0: af          .
	inr	a		;; 16f1: 3c          <
	ret			;; 16f2: c9          .

L16f3:	lhld	cursym		;; 16f3: 2a 56 30    *V0
	shld	L1613		;; 16f6: 22 13 16    "..
	call	L1c33		;; 16f9: cd 33 1c    .3.
	call	L1c36		;; 16fc: cd 36 1c    .6.
	rnz			;; 16ff: c0          .
	lhld	L1613		;; 1700: 2a 13 16    *..
	shld	cursym		;; 1703: 22 56 30    "V0
	ret			;; 1706: c9          .

L1707:	xra	a		;; 1707: af          .
	sta	L1617		;; 1708: 32 17 16    2..
L170b:	lxi	h,L1617		;; 170b: 21 17 16    ...
	inr	m		;; 170e: 34          4
	jnz	L171d		;; 170f: c2 1d 17    ...
	call	L1bdb		;; 1712: cd db 1b    ...
	lxi	h,L2f66		;; 1715: 21 66 2f    .f/
	mvi	m,0		;; 1718: 36 00       6.
	shld	L2ef4		;; 171a: 22 f4 2e    "..
L171d:	lxi	h,L2f66		;; 171d: 21 66 2f    .f/
	mov	a,m		;; 1720: 7e          ~
	ora	a		;; 1721: b7          .
	jz	L1735		;; 1722: ca 35 17    .5.
	dcr	m		;; 1725: 35          5
	lxi	h,L2f64		;; 1726: 21 64 2f    .d/
	mov	e,m		;; 1729: 5e          ^
	inr	m		;; 172a: 34          4
	mvi	d,0		;; 172b: 16 00       ..
	lxi	h,L2f67		;; 172d: 21 67 2f    .g/
	dad	d		;; 1730: 19          .
	mov	a,m		;; 1731: 7e          ~
	jmp	L1666		;; 1732: c3 66 16    .f.

L1735:	lda	L2ea3		;; 1735: 3a a3 2e    :..
	ora	a		;; 1738: b7          .
	lda	L2f65		;; 1739: 3a 65 2f    :e/
	jnz	L174a		;; 173c: c2 4a 17    .J.
	mov	b,a		;; 173f: 47          G
	ora	a		;; 1740: b7          .
	jnz	L1777		;; 1741: c2 77 17    .w.
	call	L1619		;; 1744: cd 19 16    ...
	jmp	L1666		;; 1747: c3 66 16    .f.

L174a:	ora	a		;; 174a: b7          .
	jz	L177f		;; 174b: ca 7f 17    ...
	cpi	'^'		;; 174e: fe 5e       .^
	jnz	L176c		;; 1750: c2 6c 17    .l.
	call	L1697		;; 1753: cd 97 16    ...
	mvi	b,'^'		;; 1756: 06 5e       .^
	jnz	L177b		;; 1758: c2 7b 17    .{.
	lda	L2f65		;; 175b: 3a 65 2f    :e/
	cpi	'&'		;; 175e: fe 26       .&
	jnz	L177b		;; 1760: c2 7b 17    .{.
	lxi	h,L2f66		;; 1763: 21 66 2f    .f/
	inr	m		;; 1766: 34          4
	inx	h		;; 1767: 23          #
	mov	m,a		;; 1768: 77          w
	jmp	L1777		;; 1769: c3 77 17    .w.

L176c:	cpi	'&'		;; 176c: fe 26       .&
	jz	L179e		;; 176e: ca 9e 17    ...
	mov	b,a		;; 1771: 47          G
	cpi	del		;; 1772: fe 7f       ..
	jz	L17b1		;; 1774: ca b1 17    ...
L1777:	xra	a		;; 1777: af          .
	sta	L2f65		;; 1778: 32 65 2f    2e/
L177b:	mov	a,b		;; 177b: 78          x
	jmp	L1666		;; 177c: c3 66 16    .f.

L177f:	call	L1697		;; 177f: cd 97 16    ...
	jz	L170b		;; 1782: ca 0b 17    ...
	lda	L2f65		;; 1785: 3a 65 2f    :e/
	cpi	'&'		;; 1788: fe 26       .&
	jz	L1795		;; 178a: ca 95 17    ...
	lda	L3005		;; 178d: 3a 05 30    :.0
	cpi	003h		;; 1790: fe 03       ..
	jz	L170b		;; 1792: ca 0b 17    ...
L1795:	call	L16f3		;; 1795: cd f3 16    ...
	jz	L170b		;; 1798: ca 0b 17    ...
	jmp	L17bd		;; 179b: c3 bd 17    ...

L179e:	call	L1697		;; 179e: cd 97 16    ...
	mvi	b,'&'		;; 17a1: 06 26       .&
	jz	L177b		;; 17a3: ca 7b 17    .{.
	call	L16f3		;; 17a6: cd f3 16    ...
	mvi	b,'&'		;; 17a9: 06 26       .&
	jz	L177b		;; 17ab: ca 7b 17    .{.
	jmp	L17bd		;; 17ae: c3 bd 17    ...

L17b1:	call	L1697		;; 17b1: cd 97 16    ...
	jz	L170b		;; 17b4: ca 0b 17    ...
	call	L16f3		;; 17b7: cd f3 16    ...
	jz	L170b		;; 17ba: ca 0b 17    ...
L17bd:	lxi	h,L2f65		;; 17bd: 21 65 2f    .e/
	mov	a,m		;; 17c0: 7e          ~
	cpi	'&'		;; 17c1: fe 26       .&
	jnz	L17c8		;; 17c3: c2 c8 17    ...
	mvi	a,del		;; 17c6: 3e 7f       >.
L17c8:	mvi	m,0		;; 17c8: 36 00       6.
	sta	L2f14		;; 17ca: 32 14 2f    2./
	call	L1c2d		;; 17cd: cd 2d 1c    .-.
	lxi	h,L2ea4		;; 17d0: 21 a4 2e    ...
	mvi	m,002h		;; 17d3: 36 02       6.
	lhld	memtop		;; 17d5: 2a 4d 30    *M0
	shld	L2f24		;; 17d8: 22 24 2f    "$/
	call	L1c42		;; 17db: cd 42 1c    .B.
	shld	L2ef4		;; 17de: 22 f4 2e    "..
	xra	a		;; 17e1: af          .
	sta	L2f66		;; 17e2: 32 66 2f    2f/
	lhld	L1613		;; 17e5: 2a 13 16    *..
	shld	cursym		;; 17e8: 22 56 30    "V0
	call	L1697		;; 17eb: cd 97 16    ...
	jmp	L170b		;; 17ee: c3 0b 17    ...

L17f1:	call	L180e		;; 17f1: cd 0e 18    ...
	sta	L2f66		;; 17f4: 32 66 2f    2f/
	sta	L2f65		;; 17f7: 32 65 2f    2e/
	sta	L305b		;; 17fa: 32 5b 30    2[0
	sta	L3004		;; 17fd: 32 04 30    2.0
	mvi	a,lf		;; 1800: 3e 0a       >.
	sta	L160f		;; 1802: 32 0f 16    2..
	call	L2595		;; 1805: cd 95 25    ..%
	mvi	a,010h		;; 1808: 3e 10       >.
	sta	L3004		;; 180a: 32 04 30    2.0
	ret			;; 180d: c9          .

L180e:	xra	a		;; 180e: af          .
	sta	tokbuf		;; 180f: 32 08 30    2.0
	sta	L1610		;; 1812: 32 10 16    2..
	ret			;; 1815: c9          .

L1816:	lxi	h,tokbuf		;; 1816: 21 08 30    ..0
	mov	a,m		;; 1819: 7e          ~
	cpi	64		;; 181a: fe 40       .@
	jc	L1824		;; 181c: da 24 18    .$.
	mvi	m,0		;; 181f: 36 00       6.
	call	L1bdb		;; 1821: cd db 1b    ...
L1824:	mov	e,m		;; 1824: 5e          ^
	mvi	d,0		;; 1825: 16 00       ..
	inr	m		;; 1827: 34          4
	inx	h		;; 1828: 23          #
	dad	d		;; 1829: 19          .
	lda	L305b		;; 182a: 3a 5b 30    :[0
	mov	m,a		;; 182d: 77          w
	ret			;; 182e: c9          .

L182f:	mov	a,m		;; 182f: 7e          ~
	cpi	'$'		;; 1830: fe 24       .$
	rnz			;; 1832: c0          .
	xra	a		;; 1833: af          .
	mov	m,a		;; 1834: 77          w
	ret			;; 1835: c9          .

; is char '0'-'9'?
L1836:	lda	L305b		;; 1836: 3a 5b 30    :[0
L1839:	sui	'0'		;; 1839: d6 30       .0
	cpi	'9'-'0'+1	;; 183b: fe 0a       ..
	ral			;; 183d: 17          .
	ani	001h		;; 183e: e6 01       ..
	ret			;; 1840: c9          .

; is char 'A'-'F'?
L1841:	call	L1836		;; 1841: cd 36 18    .6.
	rnz			;; 1844: c0          .
	lda	L305b		;; 1845: 3a 5b 30    :[0
	sui	'A'		;; 1848: d6 41       .A
	cpi	'F'-'A'+1	;; 184a: fe 06       ..
	ral			;; 184c: 17          .
	ani	001h		;; 184d: e6 01       ..
	ret			;; 184f: c9          .

; is first char of symbol valid?
L1850:	lda	L305b		;; 1850: 3a 5b 30    :[0
L1853:	cpi	'?'		;; 1853: fe 3f       .?
	jz	L1865		;; 1855: ca 65 18    .e.
	cpi	'@'		;; 1858: fe 40       .@
	jz	L1865		;; 185a: ca 65 18    .e.
	sui	'A'		;; 185d: d6 41       .A
	cpi	'Z'-'A'+1		;; 185f: fe 1a       ..
	ral			;; 1861: 17          .
	ani	001h		;; 1862: e6 01       ..
	ret			;; 1864: c9          .

L1865:	ora	a		;; 1865: b7          .
	ret			;; 1866: c9          .

L1867:	call	L1850		;; 1867: cd 50 18    .P.
	rnz			;; 186a: c0          .
	call	L1836		;; 186b: cd 36 18    .6.
	ret			;; 186e: c9          .

; is char end-of-field?
L186f:	cpi	' '		;; 186f: fe 20       . 
	rnc			;; 1871: d0          .
	cpi	tab		;; 1872: fe 09       ..
	rz			;; 1874: c8          .
	cpi	cr		;; 1875: fe 0d       ..
	rz			;; 1877: c8          .
	cpi	lf		;; 1878: fe 0a       ..
	rz			;; 187a: c8          .
	cpi	eof		;; 187b: fe 1a       ..
	rz			;; 187d: c8          .
	jmp	L1be1		;; 187e: c3 e1 1b    ...

L1881:	call	L1707		;; 1881: cd 07 17    ...
	call	L186f		;; 1884: cd 6f 18    .o.
	sta	L305b		;; 1887: 32 5b 30    2[0
	lda	L305a		;; 188a: 3a 5a 30    :Z0
	ora	a		;; 188d: b7          .
	jz	L18a6		;; 188e: ca a6 18    ...
	lda	L305c		;; 1891: 3a 5c 30    :\0
	cpi	001h		;; 1894: fe 01       ..
	jnz	L18a0		;; 1896: c2 a0 18    ...
	lda	pass		;; 1899: 3a 4f 30    :O0
	ora	a		;; 189c: b7          .
	jnz	L18a6		;; 189d: c2 a6 18    ...
L18a0:	lda	L305b		;; 18a0: 3a 5b 30    :[0
	call	L1c27		;; 18a3: cd 27 1c    .'.
L18a6:	lda	L305b		;; 18a6: 3a 5b 30    :[0
	ret			;; 18a9: c9          .

; is char end-of-statement?
L18aa:	cpi	cr		;; 18aa: fe 0d       ..
	rz			;; 18ac: c8          .
	cpi	eof		;; 18ad: fe 1a       ..
	rz			;; 18af: c8          .
	cpi	'!'		;; 18b0: fe 21       ..
	ret			;; 18b2: c9          .

L18b3:	call	L180e		;; 18b3: cd 0e 18    ...
L18b6:	xra	a		;; 18b6: af          .
	sta	L3005		;; 18b7: 32 05 30    2.0
	lda	L305b		;; 18ba: 3a 5b 30    :[0
	cpi	tab		;; 18bd: fe 09       ..
	jz	L1952		;; 18bf: ca 52 19    .R.
	cpi	';'		;; 18c2: fe 3b       .;
	jnz	L192f		;; 18c4: c2 2f 19    ./.
	mvi	a,6		;; 18c7: 3e 06       >.
	sta	L3005		;; 18c9: 32 05 30    2.0
	lda	L305a		;; 18cc: 3a 5a 30    :Z0
	ora	a		;; 18cf: b7          .
	jz	L193f		;; 18d0: ca 3f 19    .?.
	lda	L305c		;; 18d3: 3a 5c 30    :\0
	cpi	001h		;; 18d6: fe 01       ..
	jnz	L18e2		;; 18d8: c2 e2 18    ...
	lda	pass		;; 18db: 3a 4f 30    :O0
	ora	a		;; 18de: b7          .
	jnz	L193f		;; 18df: c2 3f 19    .?.
L18e2:	call	L1881		;; 18e2: cd 81 18    ...
	cpi	';'		;; 18e5: fe 3b       .;
	jnz	L1942		;; 18e7: c2 42 19    .B.
	lhld	L3060		;; 18ea: 2a 60 30    *`0
	xchg			;; 18ed: eb          .
	lhld	L3058		;; 18ee: 2a 58 30    *X0
	dcx	h		;; 18f1: 2b          +
	dcx	h		;; 18f2: 2b          +
L18f3:	mov	a,e		;; 18f3: 7b          {
	cmp	l		;; 18f4: bd          .
	jnz	L18fd		;; 18f5: c2 fd 18    ...
	mov	a,d		;; 18f8: 7a          z
	cmp	h		;; 18f9: bc          .
	jz	L1911		;; 18fa: ca 11 19    ...
L18fd:	mov	a,m		;; 18fd: 7e          ~
	cpi	lf		;; 18fe: fe 0a       ..
	jnz	L1908		;; 1900: c2 08 19    ...
	dcx	h		;; 1903: 2b          +
	dcx	h		;; 1904: 2b          +
	jmp	L1911		;; 1905: c3 11 19    ...

L1908:	cpi	' '+1		;; 1908: fe 21       ..
	jnc	L1911		;; 190a: d2 11 19    ...
	dcx	h		;; 190d: 2b          +
	jmp	L18f3		;; 190e: c3 f3 18    ...

L1911:	shld	L3058		;; 1911: 22 58 30    "X0
	lda	L305a		;; 1914: 3a 5a 30    :Z0
	push	psw		;; 1917: f5          .
	xra	a		;; 1918: af          .
	sta	L305a		;; 1919: 32 5a 30    2Z0
L191c:	call	L1881		;; 191c: cd 81 18    ...
	call	L18aa		;; 191f: cd aa 18    ...
	jnz	L191c		;; 1922: c2 1c 19    ...
	call	L1c27		;; 1925: cd 27 1c    .'.
	pop	psw		;; 1928: f1          .
	sta	L305a		;; 1929: 32 5a 30    2Z0
	jmp	L1958		;; 192c: c3 58 19    .X.

L192f:	lda	L305b		;; 192f: 3a 5b 30    :[0
	cpi	'*'		;; 1932: fe 2a       .*
	jnz	L194b		;; 1934: c2 4b 19    .K.
	lda	L160f		;; 1937: 3a 0f 16    :..
	cpi	lf		;; 193a: fe 0a       ..
	jnz	L194b		;; 193c: c2 4b 19    .K.
L193f:	call	L1881		;; 193f: cd 81 18    ...
L1942:	call	L18aa		;; 1942: cd aa 18    ...
	jz	L1958		;; 1945: ca 58 19    .X.
	jmp	L193f		;; 1948: c3 3f 19    .?.

L194b:	ori	020h		;; 194b: f6 20       . 
	cpi	020h		;; 194d: fe 20       . 
	jnz	L1958		;; 194f: c2 58 19    .X.
L1952:	call	L1881		;; 1952: cd 81 18    ...
	jmp	L18b6		;; 1955: c3 b6 18    ...

L1958:	xra	a		;; 1958: af          .
	sta	L3005		;; 1959: 32 05 30    2.0
	call	L1850		;; 195c: cd 50 18    .P.
	jz	L1967		;; 195f: ca 67 19    .g.
	mvi	a,001h		;; 1962: 3e 01       >.
	jmp	L19a3		;; 1964: c3 a3 19    ...

L1967:	call	L1836		;; 1967: cd 36 18    .6.
	jz	L1972		;; 196a: ca 72 19    .r.
	mvi	a,002h		;; 196d: 3e 02       >.
	jmp	L19a3		;; 196f: c3 a3 19    ...

L1972:	lda	L305b		;; 1972: 3a 5b 30    :[0
	cpi	''''		;; 1975: fe 27       .'
	jnz	L1983		;; 1977: c2 83 19    ...
	xra	a		;; 197a: af          .
	sta	L305b		;; 197b: 32 5b 30    2[0
	mvi	a,003h		;; 197e: 3e 03       >.
	jmp	L19a3		;; 1980: c3 a3 19    ...

L1983:	cpi	lf		;; 1983: fe 0a       ..
	jnz	L19a1		;; 1985: c2 a1 19    ...
	lda	L2ea3		;; 1988: 3a a3 2e    :..
	ora	a		;; 198b: b7          .
	jz	L1994		;; 198c: ca 94 19    ...
	mvi	a,'+'		;; 198f: 3e 2b       >+
	sta	prnbuf+5	;; 1991: 32 91 2f    2./
L1994:	call	L2595		;; 1994: cd 95 25    ..%
	lxi	h,curerr	;; 1997: 21 8c 2f    ../
	mvi	m,' '		;; 199a: 36 20       6 
	mvi	a,010h		;; 199c: 3e 10       >.
	sta	L3004		;; 199e: 32 04 30    2.0
L19a1:	mvi	a,004h		;; 19a1: 3e 04       >.
L19a3:	sta	L3005		;; 19a3: 32 05 30    2.0
L19a6:	lda	L305b		;; 19a6: 3a 5b 30    :[0
	sta	L160f		;; 19a9: 32 0f 16    2..
	ora	a		;; 19ac: b7          .
	cnz	L1816		;; 19ad: c4 16 18    ...
	call	L1881		;; 19b0: cd 81 18    ...
	lda	L3005		;; 19b3: 3a 05 30    :.0
	cpi	004h		;; 19b6: fe 04       ..
	jnz	L1a06		;; 19b8: c2 06 1a    ...
	lda	L305a		;; 19bb: 3a 5a 30    :Z0
	ora	a		;; 19be: b7          .
	rnz			;; 19bf: c0          .
	lda	tokbuf+1		;; 19c0: 3a 09 30    :.0
	cpi	'='		;; 19c3: fe 3d       .=
	jnz	L19ce		;; 19c5: c2 ce 19    ...
	lxi	h,'EQ'		;; 19c8: 21 45 51    .EQ
	jmp	L19f9		;; 19cb: c3 f9 19    ...

L19ce:	cpi	'<'		;; 19ce: fe 3c       .<
	jnz	L19e4		;; 19d0: c2 e4 19    ...
	lxi	h,'LT'		;; 19d3: 21 4c 54    .LT
	lda	L305b		;; 19d6: 3a 5b 30    :[0
	cpi	'='		;; 19d9: fe 3d       .=
	jnz	L19f9		;; 19db: c2 f9 19    ...
	lxi	h,'LE'		;; 19de: 21 4c 45    .LE
	jmp	L19f5		;; 19e1: c3 f5 19    ...

L19e4:	cpi	'>'		;; 19e4: fe 3e       .>
	rnz			;; 19e6: c0          .
	lxi	h,'GT'		;; 19e7: 21 47 54    .GT
	lda	L305b		;; 19ea: 3a 5b 30    :[0
	cpi	'='		;; 19ed: fe 3d       .=
	jnz	L19f9		;; 19ef: c2 f9 19    ...
	lxi	h,'GE'		;; 19f2: 21 47 45    .GE
L19f5:	xra	a		;; 19f5: af          .
	sta	L305b		;; 19f6: 32 5b 30    2[0
L19f9:	shld	tokbuf+1		;; 19f9: 22 09 30    ".0
	lxi	h,tokbuf		;; 19fc: 21 08 30    ..0
	inr	m		;; 19ff: 34          4
	mvi	a,001h		;; 1a00: 3e 01       >.
	sta	L3005		;; 1a02: 32 05 30    2.0
	ret			;; 1a05: c9          .

L1a06:	lxi	h,L305b		;; 1a06: 21 5b 30    .[0
	lda	L3005		;; 1a09: 3a 05 30    :.0
	cpi	001h		;; 1a0c: fe 01       ..
	jnz	L1a1e		;; 1a0e: c2 1e 1a    ...
	call	L182f		;; 1a11: cd 2f 18    ./.
	jz	L19a6		;; 1a14: ca a6 19    ...
	call	L1867		;; 1a17: cd 67 18    .g.
	jnz	L19a6		;; 1a1a: c2 a6 19    ...
	ret			;; 1a1d: c9          .

; determine number base... from suffix
L1a1e:	cpi	002h		;; 1a1e: fe 02       ..
	jnz	L1ab4		;; 1a20: c2 b4 1a    ...
	call	L182f		;; 1a23: cd 2f 18    ./.
	jz	L19a6		;; 1a26: ca a6 19    ...
	call	L1841		;; 1a29: cd 41 18    .A.
	jnz	L19a6		;; 1a2c: c2 a6 19    ...
	lda	L305b		;; 1a2f: 3a 5b 30    :[0
	cpi	'O'		;; 1a32: fe 4f       .O
	jz	L1a3c		;; 1a34: ca 3c 1a    .<.
	cpi	'Q'		;; 1a37: fe 51       .Q
	jnz	L1a41		;; 1a39: c2 41 1a    .A.
L1a3c:	mvi	a,8		;; 1a3c: 3e 08       >.
	jmp	L1a48		;; 1a3e: c3 48 1a    .H.

L1a41:	cpi	'H'		;; 1a41: fe 48       .H
	jnz	L1a52		;; 1a43: c2 52 1a    .R.
	mvi	a,16		;; 1a46: 3e 10       >.
L1a48:	sta	L1610		;; 1a48: 32 10 16    2..
	xra	a		;; 1a4b: af          .
	sta	L305b		;; 1a4c: 32 5b 30    2[0
	jmp	L1a6d		;; 1a4f: c3 6d 1a    .m.

L1a52:	lda	L160f		;; 1a52: 3a 0f 16    :..
	cpi	'B'		;; 1a55: fe 42       .B
	jnz	L1a5f		;; 1a57: c2 5f 1a    ._.
	mvi	a,2		;; 1a5a: 3e 02       >.
	jmp	L1a66		;; 1a5c: c3 66 1a    .f.

L1a5f:	cpi	'D'		;; 1a5f: fe 44       .D
	mvi	a,10		;; 1a61: 3e 0a       >.
	jnz	L1a6a		;; 1a63: c2 6a 1a    .j.
L1a66:	lxi	h,tokbuf		;; 1a66: 21 08 30    ..0
	dcr	m		;; 1a69: 35          5
L1a6a:	sta	L1610		;; 1a6a: 32 10 16    2..
L1a6d:	lxi	h,0		;; 1a6d: 21 00 00    ...
	shld	L3006		;; 1a70: 22 06 30    ".0
	lxi	h,tokbuf		;; 1a73: 21 08 30    ..0
	mov	c,m		;; 1a76: 4e          N
	inx	h		;; 1a77: 23          #
L1a78:	mov	a,m		;; 1a78: 7e          ~
	inx	h		;; 1a79: 23          #
	cpi	'A'		;; 1a7a: fe 41       .A
	jnc	L1a84		;; 1a7c: d2 84 1a    ...
	sui	'0'		;; 1a7f: d6 30       .0
	jmp	L1a86		;; 1a81: c3 86 1a    ...

L1a84:	sui	'A'-10		;; 1a84: d6 37       .7
L1a86:	push	h		;; 1a86: e5          .
	push	b		;; 1a87: c5          .
	mov	c,a		;; 1a88: 4f          O
	lxi	h,L1610		;; 1a89: 21 10 16    ...
	cmp	m		;; 1a8c: be          .
	cnc	L1bd5		;; 1a8d: d4 d5 1b    ...
	mvi	b,0		;; 1a90: 06 00       ..
	mov	a,m		;; 1a92: 7e          ~
	lhld	L3006		;; 1a93: 2a 06 30    *.0
	xchg			;; 1a96: eb          .
	lxi	h,0		;; 1a97: 21 00 00    ...
L1a9a:	ora	a		;; 1a9a: b7          .
	jz	L1aa9		;; 1a9b: ca a9 1a    ...
	rar			;; 1a9e: 1f          .
	jnc	L1aa3		;; 1a9f: d2 a3 1a    ...
	dad	d		;; 1aa2: 19          .
L1aa3:	xchg			;; 1aa3: eb          .
	dad	h		;; 1aa4: 29          )
	xchg			;; 1aa5: eb          .
	jmp	L1a9a		;; 1aa6: c3 9a 1a    ...

L1aa9:	dad	b		;; 1aa9: 09          .
	shld	L3006		;; 1aaa: 22 06 30    ".0
	pop	b		;; 1aad: c1          .
	pop	h		;; 1aae: e1          .
	dcr	c		;; 1aaf: 0d          .
	jnz	L1a78		;; 1ab0: c2 78 1a    .x.
	ret			;; 1ab3: c9          .

L1ab4:	lda	L305b		;; 1ab4: 3a 5b 30    :[0
	cpi	cr		;; 1ab7: fe 0d       ..
	jz	L1bdb		;; 1ab9: ca db 1b    ...
	cpi	''''		;; 1abc: fe 27       .'
	jnz	L19a6		;; 1abe: c2 a6 19    ...
	call	L1881		;; 1ac1: cd 81 18    ...
	cpi	''''		;; 1ac4: fe 27       .'
	rnz			;; 1ac6: c0          .
	jmp	L19a6		;; 1ac7: c3 a6 19    ...

L1aca:	lda	L305b		;; 1aca: 3a 5b 30    :[0
	ora	a		;; 1acd: b7          .
	rz			;; 1ace: c8          .
	cpi	' '		;; 1acf: fe 20       . 
	rz			;; 1ad1: c8          .
	cpi	tab		;; 1ad2: fe 09       ..
	ret			;; 1ad4: c9          .

L1ad5:	lda	L305b		;; 1ad5: 3a 5b 30    :[0
	cpi	','		;; 1ad8: fe 2c       .,
	rz			;; 1ada: c8          .
	cpi	';'		;; 1adb: fe 3b       .;
	rz			;; 1add: c8          .
	cpi	'%'		;; 1ade: fe 25       .%
	rz			;; 1ae0: c8          .
L1ae1:	lda	L305b		;; 1ae1: 3a 5b 30    :[0
	cpi	cr		;; 1ae4: fe 0d       ..
	rz			;; 1ae6: c8          .
	cpi	eof		;; 1ae7: fe 1a       ..
	rz			;; 1ae9: c8          .
	cpi	'!'		;; 1aea: fe 21       ..
	ret			;; 1aec: c9          .

L1aed:	lda	L305b		;; 1aed: 3a 5b 30    :[0
	cpi	';'		;; 1af0: fe 3b       .;
	rz			;; 1af2: c8          .
	cpi	' '		;; 1af3: fe 20       . 
	rz			;; 1af5: c8          .
	cpi	tab		;; 1af6: fe 09       ..
	rz			;; 1af8: c8          .
	cpi	','		;; 1af9: fe 2c       .,
	ret			;; 1afb: c9          .

L1afc:	call	L180e		;; 1afc: cd 0e 18    ...
	xra	a		;; 1aff: af          .
	sta	L3005		;; 1b00: 32 05 30    2.0
	sta	L1616		;; 1b03: 32 16 16    2..
L1b06:	call	L1aca		;; 1b06: cd ca 1a    ...
	jnz	L1b12		;; 1b09: c2 12 1b    ...
	call	L1881		;; 1b0c: cd 81 18    ...
	jmp	L1b06		;; 1b0f: c3 06 1b    ...

L1b12:	call	L1ad5		;; 1b12: cd d5 1a    ...
	jnz	L1b2f		;; 1b15: c2 2f 1b    ./.
	mvi	a,004h		;; 1b18: 3e 04       >.
	sta	L3005		;; 1b1a: 32 05 30    2.0
	jmp	L1bc9		;; 1b1d: c3 c9 1b    ...

L1b20:	lda	L305b		;; 1b20: 3a 5b 30    :[0
	sta	L160f		;; 1b23: 32 0f 16    2..
	call	L1881		;; 1b26: cd 81 18    ...
	lda	L3005		;; 1b29: 3a 05 30    :.0
	cpi	004h		;; 1b2c: fe 04       ..
	rz			;; 1b2e: c8          .
L1b2f:	call	L1ae1		;; 1b2f: cd e1 1a    ...
	jnz	L1b47		;; 1b32: c2 47 1b    .G.
	lda	L3005		;; 1b35: 3a 05 30    :.0
	cpi	003h		;; 1b38: fe 03       ..
	cz	L1bd5		;; 1b3a: cc d5 1b    ...
	lda	L1616		;; 1b3d: 3a 16 16    :..
	ora	a		;; 1b40: b7          .
	cnz	L1bd5		;; 1b41: c4 d5 1b    ...
	jmp	L1bcf		;; 1b44: c3 cf 1b    ...

L1b47:	lda	L3005		;; 1b47: 3a 05 30    :.0
	cpi	003h		;; 1b4a: fe 03       ..
	jnz	L1b6c		;; 1b4c: c2 6c 1b    .l.
	lda	L305b		;; 1b4f: 3a 5b 30    :[0
	cpi	''''		;; 1b52: fe 27       .'
	jnz	L1bc9		;; 1b54: c2 c9 1b    ...
	call	L1816		;; 1b57: cd 16 18    ...
	call	L1881		;; 1b5a: cd 81 18    ...
	lda	L305b		;; 1b5d: 3a 5b 30    :[0
	cpi	''''		;; 1b60: fe 27       .'
	jz	L1b20		;; 1b62: ca 20 1b    . .
	xra	a		;; 1b65: af          .
	sta	L3005		;; 1b66: 32 05 30    2.0
	jmp	L1b2f		;; 1b69: c3 2f 1b    ./.

L1b6c:	lda	L305b		;; 1b6c: 3a 5b 30    :[0
	cpi	''''		;; 1b6f: fe 27       .'
	jnz	L1b7c		;; 1b71: c2 7c 1b    .|.
	mvi	a,003h		;; 1b74: 3e 03       >.
	sta	L3005		;; 1b76: 32 05 30    2.0
	jmp	L1bc9		;; 1b79: c3 c9 1b    ...

L1b7c:	cpi	'^'		;; 1b7c: fe 5e       .^
	jnz	L1b97		;; 1b7e: c2 97 1b    ...
	call	L1881		;; 1b81: cd 81 18    ...
	lda	L305b		;; 1b84: 3a 5b 30    :[0
	cpi	tab		;; 1b87: fe 09       ..
	jz	L1bc9		;; 1b89: ca c9 1b    ...
	cpi	' '		;; 1b8c: fe 20       . 
	jnc	L1bc9		;; 1b8e: d2 c9 1b    ...
	call	L1be1		;; 1b91: cd e1 1b    ...
	jmp	L1bcf		;; 1b94: c3 cf 1b    ...

L1b97:	cpi	'<'		;; 1b97: fe 3c       .<
	jnz	L1ba8		;; 1b99: c2 a8 1b    ...
	lxi	h,L1616		;; 1b9c: 21 16 16    ...
	mov	a,m		;; 1b9f: 7e          ~
	inr	m		;; 1ba0: 34          4
	ora	a		;; 1ba1: b7          .
	jz	L1b20		;; 1ba2: ca 20 1b    . .
	jmp	L1bc9		;; 1ba5: c3 c9 1b    ...

L1ba8:	cpi	'>'		;; 1ba8: fe 3e       .>
	jnz	L1bbc		;; 1baa: c2 bc 1b    ...
	lxi	h,L1616		;; 1bad: 21 16 16    ...
	mov	a,m		;; 1bb0: 7e          ~
	ora	a		;; 1bb1: b7          .
	jz	L1bc9		;; 1bb2: ca c9 1b    ...
	dcr	m		;; 1bb5: 35          5
	jz	L1b20		;; 1bb6: ca 20 1b    . .
	jmp	L1bc9		;; 1bb9: c3 c9 1b    ...

L1bbc:	lda	L1616		;; 1bbc: 3a 16 16    :..
	ora	a		;; 1bbf: b7          .
	jnz	L1bc9		;; 1bc0: c2 c9 1b    ...
	call	L1aed		;; 1bc3: cd ed 1a    ...
	jz	L1bcf		;; 1bc6: ca cf 1b    ...
L1bc9:	call	L1816		;; 1bc9: cd 16 18    ...
	jmp	L1b20		;; 1bcc: c3 20 1b    . .

L1bcf:	mvi	a,005h		;; 1bcf: 3e 05       >.
	sta	L3005		;; 1bd1: 32 05 30    2.0
	ret			;; 1bd4: c9          .

L1bd5:	push	psw		;; 1bd5: f5          .
	mvi	a,'V'		;; 1bd6: 3e 56       >V
	jmp	L1bed		;; 1bd8: c3 ed 1b    ...

L1bdb:	push	psw		;; 1bdb: f5          .
	mvi	a,'O'		;; 1bdc: 3e 4f       >O
	jmp	L1bed		;; 1bde: c3 ed 1b    ...

L1be1:	push	psw		;; 1be1: f5          .
	mvi	a,'I'		;; 1be2: 3e 49       >I
	jmp	L1bed		;; 1be4: c3 ed 1b    ...

L1be7:	push	psw		;; 1be7: f5          .
	mvi	a,'B'		;; 1be8: 3e 42       >B
	jmp	L1bed		;; 1bea: c3 ed 1b    ...

L1bed:	push	b		;; 1bed: c5          .
	push	h		;; 1bee: e5          .
	call	setere		;; 1bef: cd 98 25    ..%
	pop	h		;; 1bf2: e1          .
	pop	b		;; 1bf3: c1          .
	pop	psw		;; 1bf4: f1          .
	ret			;; 1bf5: c9          .

	pop	psw		;; 1bf6: f1          .
	ret			;; 1bf7: c9          .

	db	0,0,0,0,0,0,0,0

; Module begin L1c00
L1c00:	jmp	L2100		;; 1c00: c3 00 21    ...
L1c03:	jmp	L1d51		;; 1c03: c3 51 1d    .Q.
L1c06:	jmp	L1ea9		;; 1c06: c3 a9 1e    ...
L1c09:	jmp	L1e89		;; 1c09: c3 89 1e    ...
L1c0c:	jmp	L1f02		;; 1c0c: c3 02 1f    ...
L1c0f:	jmp	L2012		;; 1c0f: c3 12 20    .. 
L1c12:	jmp	L2024		;; 1c12: c3 24 20    .$ 
L1c15:	jmp	L203f		;; 1c15: c3 3f 20    .? 
L1c18:	jmp	L2048		;; 1c18: c3 48 20    .H 
L1c1b:	jmp	L2059		;; 1c1b: c3 59 20    .Y 
L1c1e:	jmp	L2060		;; 1c1e: c3 60 20    .` 
L1c21:	jmp	L2065		;; 1c21: c3 65 20    .e 
L1c24:	jmp	L2092		;; 1c24: c3 92 20    .. 
L1c27:	jmp	L20bc		;; 1c27: c3 bc 20    .. 
L1c2a:	jmp	L20b2		;; 1c2a: c3 b2 20    .. 
L1c2d:	jmp	L1d7e		;; 1c2d: c3 7e 1d    .~.
L1c30:	jmp	L1dc5		;; 1c30: c3 c5 1d    ...
L1c33:	jmp	L1e8f		;; 1c33: c3 8f 1e    ...
L1c36:	jmp	L1e47		;; 1c36: c3 47 1e    .G.
L1c39:	jmp	L1f87		;; 1c39: c3 87 1f    ...
L1c3c:	jmp	L1fa5		;; 1c3c: c3 a5 1f    ...
L1c3f:	jmp	L1fbb		;; 1c3f: c3 bb 1f    ...
L1c42:	jmp	L1ff0		;; 1c42: c3 f0 1f    ...
L1c45:	jmp	L1ef8		;; 1c45: c3 f8 1e    ...
L1c48:	jmp	L1e1a		;; 1c48: c3 1a 1e    ...
L1c4b:	jmp	L1d66		;; 1c4b: c3 66 1d    .f.

L1c4e:	db	44h,3fh,0b2h,3ch,1eh,3dh,0c7h,3dh,0a1h,3ah,0,0,65h,3eh,0,0,3fh,3bh,20h,3eh
	db	0,0,3ch,3eh,89h,3bh,20h,3ch,59h,3dh,32h,3dh,3,3eh,0e8h,3bh,0fah,3ch,0,0,0,0,0b7h
	db	3dh,0,0,52h,3eh,0dch,3eh,0e5h,3eh,0,0,0,0,46h,3eh,0dch,3bh,0,0,9ch
	db	3eh,47h,3dh,0,0,0,0,0,0,0,0,93h,3dh,0c6h,3ch,15h,3dh,0,0,0aeh,3dh
	db	91h,3eh,0beh,3dh,0,0,0,0,0,0,0,0,73h,3bh,0a5h,3dh,50h,3dh,0,0,0,0,0,0
	db	2ah,3eh,4,3dh,24h,3fh,50h,3ah,2dh,3fh,5dh,3eh,2ah,3ch,15h,3ch,0,0,81h,3dh,8ah,3dh,0,0,0e5h,3ch
	db	0ffh,3bh,0,0,9ch,3dh,81h,3eh,89h,3eh,79h,3eh,0ah,3ch,55h,3ch,0feh,3ah,3fh,3ch,6bh,3ch
	db	0ddh,3ah,0f4h,3bh,0,0,0,0,0,0,0c6h,3eh,0,0,0,0,0,0,9,3bh
	db	0e8h,3ah,0dh,3dh,93h,3bh,0fbh,3eh,5,3fh,0,0,0,0,0eeh,3eh,50h,3fh,0
	db	0,0aah,3ch,0f9h,3dh,1ah,3fh,0b2h,3eh,0bch,3eh,0efh,3dh,0,0
	db	0dbh,3ch,0d1h,3ch,0,0,69h,3bh,0,0,0,0,0,0,0,0,0,0,0,0,6dh,3dh,16h
	db	3eh,0,0,0,0,63h,3dh,0e5h,3dh,0a8h,3eh,6fh,3eh,76h,3ch,0dbh,3dh,0bch,3ch
	db	0a8h,3bh,38h,3fh
L1d4e:	db	1
L1d4f:	dw	L1c4e

L1d51:	lxi	h,L1c4e		;; 1d51: 21 4e 1c    .N.
	mvi	b,256/2		;; 1d54: 06 80       ..
	xra	a		;; 1d56: af          .
L1d57:	mov	m,a		;; 1d57: 77          w
	inx	h		;; 1d58: 23          #
	mov	m,a		;; 1d59: 77          w
	inx	h		;; 1d5a: 23          #
	dcr	b		;; 1d5b: 05          .
	jnz	L1d57		;; 1d5c: c2 57 1d    .W.
	lxi	h,0		;; 1d5f: 21 00 00    ...
	shld	cursym		;; 1d62: 22 56 30    "V0
	ret			;; 1d65: c9          .

L1d66:	lxi	h,L2e83		;; 1d66: 21 83 2e    ...
	mvi	b,32/2		;; 1d69: 06 10       ..
	xra	a		;; 1d6b: af          .
L1d6c:	mov	m,a		;; 1d6c: 77          w
	inx	h		;; 1d6d: 23          #
	mov	m,a		;; 1d6e: 77          w
	inx	h		;; 1d6f: 23          #
	dcr	b		;; 1d70: 05          .
	jnz	L1d6c		;; 1d71: c2 6c 1d    .l.
	ret			;; 1d74: c9          .

	call	L1e1a		;; 1d75: cd 1a 1e    ...
	ani	00fh		;; 1d78: e6 0f       ..
	sta	L1d4e		;; 1d7a: 32 4e 1d    2N.
	ret			;; 1d7d: c9          .

L1d7e:	lxi	h,L2ea3		;; 1d7e: 21 a3 2e    ...
	mov	a,m		;; 1d81: 7e          ~
	cpi	15		;; 1d82: fe 0f       ..
	jnc	Berro2		;; 1d84: d2 15 1e    ...
	inr	m		;; 1d87: 34          4
	mov	e,m		;; 1d88: 5e          ^
	mvi	d,0		;; 1d89: 16 00       ..
	lxi	h,L2ea4		;; 1d8b: 21 a4 2e    ...
	mov	a,m		;; 1d8e: 7e          ~
	dad	d		;; 1d8f: 19          .
	mov	m,a		;; 1d90: 77          w
	lxi	h,L2ed4		;; 1d91: 21 d4 2e    ...
	call	L1dbc		;; 1d94: cd bc 1d    ...
	lxi	h,L2eb4		;; 1d97: 21 b4 2e    ...
	call	L1dbc		;; 1d9a: cd bc 1d    ...
	lxi	h,L2ef4		;; 1d9d: 21 f4 2e    ...
	call	L1dbc		;; 1da0: cd bc 1d    ...
	lxi	h,L2f14		;; 1da3: 21 14 2f    ../
	mov	a,m		;; 1da6: 7e          ~
	dad	d		;; 1da7: 19          .
	mov	m,a		;; 1da8: 77          w
	lxi	h,L2f24		;; 1da9: 21 24 2f    .$/
	call	L1dbc		;; 1dac: cd bc 1d    ...
	lxi	h,L2f44		;; 1daf: 21 44 2f    .D/
	mov	a,m		;; 1db2: 7e          ~
	dad	d		;; 1db3: 19          .
	mov	m,a		;; 1db4: 77          w
	lxi	h,L2f54		;; 1db5: 21 54 2f    .T/
	mov	a,m		;; 1db8: 7e          ~
	dad	d		;; 1db9: 19          .
	mov	m,a		;; 1dba: 77          w
	ret			;; 1dbb: c9          .

L1dbc:	mov	c,m		;; 1dbc: 4e          N
	inx	h		;; 1dbd: 23          #
	mov	b,m		;; 1dbe: 46          F
	dad	d		;; 1dbf: 19          .
	dad	d		;; 1dc0: 19          .
	mov	m,b		;; 1dc1: 70          p
	dcx	h		;; 1dc2: 2b          +
	mov	m,c		;; 1dc3: 71          q
	ret			;; 1dc4: c9          .

L1dc5:	lxi	h,L2ea3		;; 1dc5: 21 a3 2e    ...
	mov	a,m		;; 1dc8: 7e          ~
	ora	a		;; 1dc9: b7          .
	jz	Berro2		;; 1dca: ca 15 1e    ...
	push	h		;; 1dcd: e5          .
	mov	e,m		;; 1dce: 5e          ^
	mvi	d,0		;; 1dcf: 16 00       ..
	lxi	h,L2ea4		;; 1dd1: 21 a4 2e    ...
	call	L1e04		;; 1dd4: cd 04 1e    ...
	lxi	h,L2ed4		;; 1dd7: 21 d4 2e    ...
	call	L1e0a		;; 1dda: cd 0a 1e    ...
	lxi	h,L2eb4		;; 1ddd: 21 b4 2e    ...
	call	L1e0a		;; 1de0: cd 0a 1e    ...
	lxi	h,L2ef4		;; 1de3: 21 f4 2e    ...
	call	L1e0a		;; 1de6: cd 0a 1e    ...
	lxi	h,L2f14		;; 1de9: 21 14 2f    ../
	call	L1e04		;; 1dec: cd 04 1e    ...
	lxi	h,L2f24		;; 1def: 21 24 2f    .$/
	call	L1e0a		;; 1df2: cd 0a 1e    ...
	lxi	h,L2f44		;; 1df5: 21 44 2f    .D/
	call	L1e04		;; 1df8: cd 04 1e    ...
	lxi	h,L2f54		;; 1dfb: 21 54 2f    .T/
	call	L1e04		;; 1dfe: cd 04 1e    ...
	pop	h		;; 1e01: e1          .
	dcr	m		;; 1e02: 35          5
	ret			;; 1e03: c9          .

L1e04:	push	h		;; 1e04: e5          .
	dad	d		;; 1e05: 19          .
	mov	a,m		;; 1e06: 7e          ~
	pop	h		;; 1e07: e1          .
	mov	m,a		;; 1e08: 77          w
	ret			;; 1e09: c9          .

L1e0a:	push	h		;; 1e0a: e5          .
	dad	d		;; 1e0b: 19          .
	dad	d		;; 1e0c: 19          .
	mov	c,m		;; 1e0d: 4e          N
	inx	h		;; 1e0e: 23          #
	mov	b,m		;; 1e0f: 46          F
	pop	h		;; 1e10: e1          .
	mov	m,c		;; 1e11: 71          q
	inx	h		;; 1e12: 23          #
	mov	m,b		;; 1e13: 70          p
	ret			;; 1e14: c9          .

Berro2:	mvi	a,'B'		;; 1e15: 3e 42       >B
	jmp	setere		;; 1e17: c3 98 25    ..%

L1e1a:	lxi	h,tokbuf		;; 1e1a: 21 08 30    ..0
	shld	L20d6		;; 1e1d: 22 d6 20    ". 
L1e20:	lhld	L20d6		;; 1e20: 2a d6 20    *. 
	mov	b,m		;; 1e23: 46          F
	xra	a		;; 1e24: af          .
L1e25:	inx	h		;; 1e25: 23          #
	add	m		;; 1e26: 86          .
	dcr	b		;; 1e27: 05          .
	jnz	L1e25		;; 1e28: c2 25 1e    .%.
	ani	07fh		;; 1e2b: e6 7f       ..
	sta	L1d4e		;; 1e2d: 32 4e 1d    2N.
	ret			;; 1e30: c9          .

	mov	b,a		;; 1e31: 47          G
	lhld	cursym		;; 1e32: 2a 56 30    *V0
	inx	h		;; 1e35: 23          #
	inx	h		;; 1e36: 23          #
	mov	a,m		;; 1e37: 7e          ~
	ani	0f0h		;; 1e38: e6 f0       ..
	ora	b		;; 1e3a: b0          .
	mov	m,a		;; 1e3b: 77          w
	ret			;; 1e3c: c9          .

L1e3d:	lhld	cursym		;; 1e3d: 2a 56 30    *V0
	inx	h		;; 1e40: 23          #
	inx	h		;; 1e41: 23          #
	mov	a,m		;; 1e42: 7e          ~
	ani	00fh		;; 1e43: e6 0f       ..
	inr	a		;; 1e45: 3c          <
	ret			;; 1e46: c9          .

L1e47:	call	L1e89		;; 1e47: cd 89 1e    ...
	rz			;; 1e4a: c8          .
	xchg			;; 1e4b: eb          .
	lxi	b,0		;; 1e4c: 01 00 00    ...
	lda	L2ea4		;; 1e4f: 3a a4 2e    :..
	cpi	001h		;; 1e52: fe 01       ..
	jz	L1e74		;; 1e54: ca 74 1e    .t.
	lxi	h,L2ea3		;; 1e57: 21 a3 2e    ...
	mov	c,m		;; 1e5a: 4e          N
	mvi	b,0		;; 1e5b: 06 00       ..
	lxi	h,L2ea4		;; 1e5d: 21 a4 2e    ...
	dad	b		;; 1e60: 09          .
L1e61:	mov	a,c		;; 1e61: 79          y
	ora	a		;; 1e62: b7          .
	jz	L1e71		;; 1e63: ca 71 1e    .q.
	mov	a,m		;; 1e66: 7e          ~
	cpi	001h		;; 1e67: fe 01       ..
	jz	L1e74		;; 1e69: ca 74 1e    .t.
	dcx	b		;; 1e6c: 0b          .
	dcx	h		;; 1e6d: 2b          +
	jmp	L1e61		;; 1e6e: c3 61 1e    .a.

L1e71:	inr	a		;; 1e71: 3c          <
	xchg			;; 1e72: eb          .
	ret			;; 1e73: c9          .

L1e74:	lxi	h,L2f24		;; 1e74: 21 24 2f    .$/
	dad	b		;; 1e77: 09          .
	dad	b		;; 1e78: 09          .
	mov	a,e		;; 1e79: 7b          {
	sub	m		;; 1e7a: 96          .
	mov	a,d		;; 1e7b: 7a          z
	inx	h		;; 1e7c: 23          #
	sbb	m		;; 1e7d: 9e          .
	jc	L1e89		;; 1e7e: da 89 1e    ...
	lxi	h,0		;; 1e81: 21 00 00    ...
	shld	cursym		;; 1e84: 22 56 30    "V0
	xra	a		;; 1e87: af          .
	ret			;; 1e88: c9          .

L1e89:	lhld	cursym		;; 1e89: 2a 56 30    *V0
	mov	a,l		;; 1e8c: 7d          }
	ora	h		;; 1e8d: b4          .
	ret			;; 1e8e: c9          .

L1e8f:	lxi	h,L2f66		;; 1e8f: 21 66 2f    .f/
	shld	L20d6		;; 1e92: 22 d6 20    ". 
	call	L1e20		;; 1e95: cd 20 1e    . .
	lda	L1d4e		;; 1e98: 3a 4e 1d    :N.
	ani	00fh		;; 1e9b: e6 0f       ..
	sta	L1d4e		;; 1e9d: 32 4e 1d    2N.
	lxi	h,L2e83		;; 1ea0: 21 83 2e    ...
	shld	L1d4f		;; 1ea3: 22 4f 1d    "O.
	jmp	L1eb8		;; 1ea6: c3 b8 1e    ...

L1ea9:	call	L1e1a		;; 1ea9: cd 1a 1e    ...
	lxi	h,L1c4e		;; 1eac: 21 4e 1c    .N.
	shld	L1d4f		;; 1eaf: 22 4f 1d    "O.
	lxi	h,tokbuf		;; 1eb2: 21 08 30    ..0
	shld	L20d6		;; 1eb5: 22 d6 20    ". 
L1eb8:	lhld	L20d6		;; 1eb8: 2a d6 20    *. 
	mov	a,m		;; 1ebb: 7e          ~
	cpi	011h		;; 1ebc: fe 11       ..
	jc	L1ec3		;; 1ebe: da c3 1e    ...
	mvi	m,010h		;; 1ec1: 36 10       6.
L1ec3:	lxi	h,L1d4e		;; 1ec3: 21 4e 1d    .N.
	mov	e,m		;; 1ec6: 5e          ^
	mvi	d,000h		;; 1ec7: 16 00       ..
	lhld	L1d4f		;; 1ec9: 2a 4f 1d    *O.
	dad	d		;; 1ecc: 19          .
	dad	d		;; 1ecd: 19          .
	mov	e,m		;; 1ece: 5e          ^
	inx	h		;; 1ecf: 23          #
	mov	h,m		;; 1ed0: 66          f
	mov	l,e		;; 1ed1: 6b          k
L1ed2:	shld	cursym		;; 1ed2: 22 56 30    "V0
	call	L1e89		;; 1ed5: cd 89 1e    ...
	rz			;; 1ed8: c8          .
	call	L1e3d		;; 1ed9: cd 3d 1e    .=.
	lhld	L20d6		;; 1edc: 2a d6 20    *. 
	cmp	m		;; 1edf: be          .
	jnz	L1ef8		;; 1ee0: c2 f8 1e    ...
	mov	b,a		;; 1ee3: 47          G
	inx	h		;; 1ee4: 23          #
	xchg			;; 1ee5: eb          .
	lhld	cursym		;; 1ee6: 2a 56 30    *V0
	inx	h		;; 1ee9: 23          #
	inx	h		;; 1eea: 23          #
	inx	h		;; 1eeb: 23          #
L1eec:	ldax	d		;; 1eec: 1a          .
	cmp	m		;; 1eed: be          .
	jnz	L1ef8		;; 1eee: c2 f8 1e    ...
	inx	d		;; 1ef1: 13          .
	inx	h		;; 1ef2: 23          #
	dcr	b		;; 1ef3: 05          .
	jnz	L1eec		;; 1ef4: c2 ec 1e    ...
	ret			;; 1ef7: c9          .

L1ef8:	lhld	cursym		;; 1ef8: 2a 56 30    *V0
	mov	e,m		;; 1efb: 5e          ^
	inx	h		;; 1efc: 23          #
	mov	d,m		;; 1efd: 56          V
	xchg			;; 1efe: eb          .
	jmp	L1ed2		;; 1eff: c3 d2 1e    ...

L1f02:	lxi	h,tokbuf		;; 1f02: 21 08 30    ..0
	mov	e,m		;; 1f05: 5e          ^
	mvi	d,000h		;; 1f06: 16 00       ..
	lhld	nxheap		;; 1f08: 2a 4b 30    *K0
	shld	cursym		;; 1f0b: 22 56 30    "V0
	dad	d		;; 1f0e: 19          .
	lxi	d,5		;; 1f0f: 11 05 00    ...
	dad	d		;; 1f12: 19          .
	xchg			;; 1f13: eb          .
	lhld	memtop		;; 1f14: 2a 4d 30    *M0
	mov	a,e		;; 1f17: 7b          {
	sub	l		;; 1f18: 95          .
	mov	a,d		;; 1f19: 7a          z
	sbb	h		;; 1f1a: 9c          .
	xchg			;; 1f1b: eb          .
	jnc	L1ff3		;; 1f1c: d2 f3 1f    ...
	shld	nxheap		;; 1f1f: 22 4b 30    "K0
	lxi	h,L1c4e		;; 1f22: 21 4e 1c    .N.
	shld	L1d4f		;; 1f25: 22 4f 1d    "O.
	call	L1f31		;; 1f28: cd 31 1f    .1.
	xra	a		;; 1f2b: af          .
	inx	h		;; 1f2c: 23          #
	mov	m,a		;; 1f2d: 77          w
	inx	h		;; 1f2e: 23          #
	mov	m,a		;; 1f2f: 77          w
	ret			;; 1f30: c9          .

L1f31:	lhld	cursym		;; 1f31: 2a 56 30    *V0
	xchg			;; 1f34: eb          .
	lxi	h,L1d4e		;; 1f35: 21 4e 1d    .N.
	mov	c,m		;; 1f38: 4e          N
	mvi	b,0		;; 1f39: 06 00       ..
	lhld	L1d4f		;; 1f3b: 2a 4f 1d    *O.
	dad	b		;; 1f3e: 09          .
	dad	b		;; 1f3f: 09          .
	mov	c,m		;; 1f40: 4e          N
	inx	h		;; 1f41: 23          #
	mov	b,m		;; 1f42: 46          F
	mov	m,d		;; 1f43: 72          r
	dcx	h		;; 1f44: 2b          +
	mov	m,e		;; 1f45: 73          s
	xchg			;; 1f46: eb          .
	mov	m,c		;; 1f47: 71          q
	inx	h		;; 1f48: 23          #
	mov	m,b		;; 1f49: 70          p
	lxi	d,tokbuf		;; 1f4a: 11 08 30    ..0
	ldax	d		;; 1f4d: 1a          .
	cpi	17		;; 1f4e: fe 11       ..
	jc	L1f55		;; 1f50: da 55 1f    .U.
	mvi	a,16		;; 1f53: 3e 10       >.
L1f55:	mov	b,a		;; 1f55: 47          G
	dcr	a		;; 1f56: 3d          =
	inx	h		;; 1f57: 23          #
	mov	m,a		;; 1f58: 77          w
L1f59:	inx	h		;; 1f59: 23          #
	inx	d		;; 1f5a: 13          .
	ldax	d		;; 1f5b: 1a          .
	mov	m,a		;; 1f5c: 77          w
	dcr	b		;; 1f5d: 05          .
	jnz	L1f59		;; 1f5e: c2 59 1f    .Y.
	ret			;; 1f61: c9          .

L1f62:	lhld	memtop		;; 1f62: 2a 4d 30    *M0
	xchg			;; 1f65: eb          .
	lxi	h,tokbuf		;; 1f66: 21 08 30    ..0
	mov	l,m		;; 1f69: 6e          n
	mvi	h,0		;; 1f6a: 26 00       &.
	dad	b		;; 1f6c: 09          .
	mov	a,e		;; 1f6d: 7b          {
	sub	l		;; 1f6e: 95          .
	mov	l,a		;; 1f6f: 6f          o
	mov	a,d		;; 1f70: 7a          z
	sbb	h		;; 1f71: 9c          .
	mov	h,a		;; 1f72: 67          g
	shld	cursym		;; 1f73: 22 56 30    "V0
	xchg			;; 1f76: eb          .
	lxi	h,nxheap		;; 1f77: 21 4b 30    .K0
	mov	a,e		;; 1f7a: 7b          {
	sub	m		;; 1f7b: 96          .
	inx	h		;; 1f7c: 23          #
	mov	a,d		;; 1f7d: 7a          z
	sbb	m		;; 1f7e: 9e          .
	jc	L1ff3		;; 1f7f: da f3 1f    ...
	xchg			;; 1f82: eb          .
	shld	memtop		;; 1f83: 22 4d 30    "M0
	ret			;; 1f86: c9          .

L1f87:	lxi	b,1		;; 1f87: 01 01 00    ...
	call	L1f62		;; 1f8a: cd 62 1f    .b.
	lhld	memtop		;; 1f8d: 2a 4d 30    *M0
	xchg			;; 1f90: eb          .
	lxi	h,tokbuf		;; 1f91: 21 08 30    ..0
	mov	c,m		;; 1f94: 4e          N
L1f95:	inx	h		;; 1f95: 23          #
	mov	a,c		;; 1f96: 79          y
	ora	a		;; 1f97: b7          .
	jz	L1fa2		;; 1f98: ca a2 1f    ...
	dcr	c		;; 1f9b: 0d          .
	mov	a,m		;; 1f9c: 7e          ~
	stax	d		;; 1f9d: 12          .
	inx	d		;; 1f9e: 13          .
	jmp	L1f95		;; 1f9f: c3 95 1f    ...

L1fa2:	xra	a		;; 1fa2: af          .
	stax	d		;; 1fa3: 12          .
	ret			;; 1fa4: c9          .

L1fa5:	lxi	b,3		;; 1fa5: 01 03 00    ...
	call	L1f62		;; 1fa8: cd 62 1f    .b.
	lxi	h,L2e83		;; 1fab: 21 83 2e    ...
	shld	L1d4f		;; 1fae: 22 4f 1d    "O.
	call	L1f31		;; 1fb1: cd 31 1f    .1.
	lda	L1d4e		;; 1fb4: 3a 4e 1d    :N.
	call	L2012		;; 1fb7: cd 12 20    .. 
	ret			;; 1fba: c9          .

L1fbb:	lhld	memtop		;; 1fbb: 2a 4d 30    *M0
	xchg			;; 1fbe: eb          .
	lxi	h,L2f24		;; 1fbf: 21 24 2f    .$/
	mov	a,e		;; 1fc2: 7b          {
	sub	m		;; 1fc3: 96          .
	inx	h		;; 1fc4: 23          #
	mov	a,d		;; 1fc5: 7a          z
	sbb	m		;; 1fc6: 9e          .
	rnc			;; 1fc7: d0          .
	xchg			;; 1fc8: eb          .
	shld	cursym		;; 1fc9: 22 56 30    "V0
	call	L2024		;; 1fcc: cd 24 20    .$ 
	mov	e,a		;; 1fcf: 5f          _
	mvi	d,0		;; 1fd0: 16 00       ..
	lxi	h,L2e83		;; 1fd2: 21 83 2e    ...
	dad	d		;; 1fd5: 19          .
	dad	d		;; 1fd6: 19          .
	xchg			;; 1fd7: eb          .
	lhld	cursym		;; 1fd8: 2a 56 30    *V0
	mov	a,m		;; 1fdb: 7e          ~
	stax	d		;; 1fdc: 12          .
	inx	h		;; 1fdd: 23          #
	mov	a,m		;; 1fde: 7e          ~
	inx	d		;; 1fdf: 13          .
	stax	d		;; 1fe0: 12          .
	call	L2031		;; 1fe1: cd 31 20    .1 
L1fe4:	mov	a,m		;; 1fe4: 7e          ~
	ora	a		;; 1fe5: b7          .
	inx	h		;; 1fe6: 23          #
	jnz	L1fe4		;; 1fe7: c2 e4 1f    ...
	shld	memtop		;; 1fea: 22 4d 30    "M0
	jmp	L1fbb		;; 1fed: c3 bb 1f    ...

L1ff0:	jmp	L2031		;; 1ff0: c3 31 20    .1 

L1ff3:	lxi	h,L1ffc		;; 1ff3: 21 fc 1f    ...
	call	msgcre		;; 1ff6: cd 92 25    ..%
	jmp	hexfne		;; 1ff9: c3 9e 25    ..%

L1ffc:	db	'SYMBOL TABLE OVERFLOW',0dh

L2012:	ral			;; 2012: 17          .
	ral			;; 2013: 17          .
	ral			;; 2014: 17          .
	ral			;; 2015: 17          .
	ani	0f0h		;; 2016: e6 f0       ..
	mov	b,a		;; 2018: 47          G
	lhld	cursym		;; 2019: 2a 56 30    *V0
	inx	h		;; 201c: 23          #
	inx	h		;; 201d: 23          #
	mov	a,m		;; 201e: 7e          ~
	ani	00fh		;; 201f: e6 0f       ..
	ora	b		;; 2021: b0          .
	mov	m,a		;; 2022: 77          w
	ret			;; 2023: c9          .

L2024:	lhld	cursym		;; 2024: 2a 56 30    *V0
	inx	h		;; 2027: 23          #
	inx	h		;; 2028: 23          #
	mov	a,m		;; 2029: 7e          ~
	rar			;; 202a: 1f          .
	rar			;; 202b: 1f          .
	rar			;; 202c: 1f          .
	rar			;; 202d: 1f          .
	ani	00fh		;; 202e: e6 0f       ..
	ret			;; 2030: c9          .

L2031:	call	L1e3d		;; 2031: cd 3d 1e    .=.
	lhld	cursym		;; 2034: 2a 56 30    *V0
	mov	e,a		;; 2037: 5f          _
	mvi	d,0		;; 2038: 16 00       ..
	dad	d		;; 203a: 19          .
	inx	h		;; 203b: 23          #
	inx	h		;; 203c: 23          #
	inx	h		;; 203d: 23          #
	ret			;; 203e: c9          .

L203f:	push	h		;; 203f: e5          .
	call	L2031		;; 2040: cd 31 20    .1 
	pop	d		;; 2043: d1          .
	mov	m,e		;; 2044: 73          s
	inx	h		;; 2045: 23          #
	mov	m,d		;; 2046: 72          r
	ret			;; 2047: c9          .

L2048:	call	L2031		;; 2048: cd 31 20    .1 
	mov	e,m		;; 204b: 5e          ^
	inx	h		;; 204c: 23          #
	mov	d,m		;; 204d: 56          V
	xchg			;; 204e: eb          .
	ret			;; 204f: c9          .

L2050:	call	L2031		;; 2050: cd 31 20    .1 
	inx	h		;; 2053: 23          #
	inx	h		;; 2054: 23          #
	shld	L3058		;; 2055: 22 58 30    "X0
	ret			;; 2058: c9          .

L2059:	push	psw		;; 2059: f5          .
	call	L2050		;; 205a: cd 50 20    .P 
	pop	psw		;; 205d: f1          .
	mov	m,a		;; 205e: 77          w
	ret			;; 205f: c9          .

L2060:	call	L2050		;; 2060: cd 50 20    .P 
	mov	a,m		;; 2063: 7e          ~
	ret			;; 2064: c9          .

L2065:	call	L1e1a		;; 2065: cd 1a 1e    ...
	ani	00fh		;; 2068: e6 0f       ..
	add	a		;; 206a: 87          .
	add	a		;; 206b: 87          .
	add	a		;; 206c: 87          .
	add	a		;; 206d: 87          .
	mov	c,a		;; 206e: 4f          O
	lxi	h,tokbuf		;; 206f: 21 08 30    ..0
	mov	a,m		;; 2072: 7e          ~
	cpi	17		;; 2073: fe 11       ..
	jc	L207a		;; 2075: da 7a 20    .z 
	mvi	m,16		;; 2078: 36 10       6.
L207a:	mov	a,m		;; 207a: 7e          ~
	dcr	a		;; 207b: 3d          =
	ora	c		;; 207c: b1          .
	call	L20bc		;; 207d: cd bc 20    .. 
	lxi	h,tokbuf		;; 2080: 21 08 30    ..0
	mov	c,m		;; 2083: 4e          N
L2084:	inx	h		;; 2084: 23          #
	mov	a,m		;; 2085: 7e          ~
	push	b		;; 2086: c5          .
	push	h		;; 2087: e5          .
	call	L20bc		;; 2088: cd bc 20    .. 
	pop	h		;; 208b: e1          .
	pop	b		;; 208c: c1          .
	dcr	c		;; 208d: 0d          .
	jnz	L2084		;; 208e: c2 84 20    .. 
	ret			;; 2091: c9          .

L2092:	call	L20b2		;; 2092: cd b2 20    .. 
	mov	c,a		;; 2095: 4f          O
	rlc			;; 2096: 07          .
	rlc			;; 2097: 07          .
	rlc			;; 2098: 07          .
	rlc			;; 2099: 07          .
	ani	00fh		;; 209a: e6 0f       ..
	sta	L1d4e		;; 209c: 32 4e 1d    2N.
	mov	a,c		;; 209f: 79          y
	ani	00fh		;; 20a0: e6 0f       ..
	inr	a		;; 20a2: 3c          <
	mov	c,a		;; 20a3: 4f          O
	lxi	d,tokbuf		;; 20a4: 11 08 30    ..0
	stax	d		;; 20a7: 12          .
L20a8:	call	L20b2		;; 20a8: cd b2 20    .. 
	inx	d		;; 20ab: 13          .
	stax	d		;; 20ac: 12          .
	dcr	c		;; 20ad: 0d          .
	jnz	L20a8		;; 20ae: c2 a8 20    .. 
	ret			;; 20b1: c9          .

L20b2:	lhld	L3058		;; 20b2: 2a 58 30    *X0
	inx	h		;; 20b5: 23          #
	shld	L3058		;; 20b6: 22 58 30    "X0
	mov	a,m		;; 20b9: 7e          ~
	ret			;; 20ba: c9          .

	ret			;; 20bb: c9          .

L20bc:	mov	c,a		;; 20bc: 4f          O
	lhld	L3058		;; 20bd: 2a 58 30    *X0
	inx	h		;; 20c0: 23          #
	xchg			;; 20c1: eb          .
	lhld	memtop		;; 20c2: 2a 4d 30    *M0
	mov	a,e		;; 20c5: 7b          {
	sub	l		;; 20c6: 95          .
	mov	a,d		;; 20c7: 7a          z
	sbb	h		;; 20c8: 9c          .
	jnc	L1ff3		;; 20c9: d2 f3 1f    ...
	xchg			;; 20cc: eb          .
	shld	L3058		;; 20cd: 22 58 30    "X0
	mov	m,c		;; 20d0: 71          q
	inx	h		;; 20d1: 23          #
	shld	nxheap		;; 20d2: 22 4b 30    "K0
	ret			;; 20d5: c9          .

L20d6:	dw	022ebh

L20d8:	cpi	','		;; 20d8: fe 2c       .,
	jnz	L1652		;; 20da: c2 52 16    .R.
	shld	L11e2		;; 20dd: 22 e2 11    "..
	jmp	L1652		;; 20e0: c3 52 16    .R.

	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0dah,96h,7,0dh,0cah,96h,7,0c3h,80h
	db	7,0,0,0,0,0,0

; Module begin L2100 - parser (assembler)
L2100:	jmp	L2600		;; 2100: c3 00 26    ..&
	jmp	L2380		;; 2103: c3 80 23    ..#
L2106:	jmp	L240d		;; 2106: c3 0d 24    ..$
L2109:	jmp	L2462		;; 2109: c3 62 24    .b$
L210c:	jmp	L247b		;; 210c: c3 7b 24    .{$

L210f:	db	0fch

L2110:	dw	tok1	; 1-char tokens
	dw	tok2	; 2-char tokens
	dw	tok3	; 3-char tokens
	dw	tok4	; 4-char tokens
	dw	tok5	; 5-char tokens
	dw	tok6	; 6-char tokens

	dw	L2282

L211e:	dw	L2288	; 1-char token flags
	dw	L22a8	; 2-char token flags
	dw	L22c6	; 3-char token flags
	dw	L2334	; 4-char token flags
	dw	L235c	; 5-char token flags
	dw	L236a	; 6-char token flags

tok1:	db	0dh,'(',')','*','+',',','-','/','A','B','C','D','E','H','L','M'
num1	equ	$-tok1

tok2:	db	'DB','DI','DS','DW','EI','EQ','GE','GT','IF','IN','LE','LT','NE','OR','SP'
num2	equ	($-tok2)/2

tok3:	db	'ACI','ADC','ADD','ADI','ANA','AND','ANI','CMA','CMC'
	db	'CMP','CPI','DAA','DAD','DCR','DCX','END','EQU','HLT','INR'
	db	'INX','IRP','JMP','LDA','LOW','LXI','MOD','MOV','MVI','NOP'
	db	'NOT','NUL','ORA','ORG','ORI','OUT','POP','PSW','RAL','RAR'
	db	'RET','RLC','RRC','RST','SBB','SBI','SET','SHL','SHR','STA'
	db	'STC','SUB','SUI','XOR','XRA','XRI'
num3	equ	($-tok3)/3

tok4:	db	'ASEG','CALL','CSEG','DSEG','ELSE','ENDM','HIGH','IRPC','LDAX'
	db	'LHLD','NAME','PAGE','PCHL','PUSH'
	db	'REPT','SHLD','SPHL','STAX','XCHG','XTHL'
num4	equ	($-tok4)/4

tok5:	db	'ENDIF','EXITM','EXTRN','LOCAL','MACRO','STKLN','TITLE'
num5	equ	($-tok5)/5

tok6:	db	'INPAGE','MACLIB','PUBLIC'
num6	equ	($-tok6)/6

L2282:	db	num1
L2283:	db	num2,num3,num4,num5,num6

; token flags (and opcode base)
L2288:	db	17h,0ah	; CR
	db	14h,14h	; l-paren
	db	15h,1eh	; r-paren
	db	0,50h	; asterisk
	db	5,46h	; plus
	db	16h,0ah	; comma
	db	6,46h	; minus
	db	1,50h	; slash
	db	19h,7	; 'A'
	db	19h,0	; 'B'
	db	19h,1	; 'C'
	db	19h,2	; 'D'
	db	19h,3	; 'E'
	db	19h,4	; 'H'
	db	19h,5	; 'L'
	db	19h,6	; 'M'

L22a8:	db	1ah,1		; DB
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

L22c6:	db	23h,0ceh	; ACI
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

L2334:	db	1ah,0dh		; ASEG - ***BUG*** should be 1ah,11h
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

L235c:	db	1ah,5		; ENDIF
	db	1ah,16h		; EXITM
	db	1ah,17h		; EXTRN
	db	1ah,18h		; LOCAL
	db	1ah,9		; MACRO
	db	1ah,1ch		; STKLN
	db	1ah,0ch		; TITLE

L236a:	db	1ah,19h		; INPAGE
	db	1ah,1ah		; MACLIB
	db	1ah,1bh		; PUBLIC

; J(MP), R(ET), C(ALL) condition codes
L2370:	db	'NZ','Z ','NC','C ','PO','PE','P ','M '

L2380:	mvi	e,0ffh		;; 2380: 1e ff       ..
	inr	b		;; 2382: 04          .
	mvi	c,0		;; 2383: 0e 00       ..
L2385:	xra	a		;; 2385: af          .
	mov	a,b		;; 2386: 78          x
	add	c		;; 2387: 81          .
	rar			;; 2388: 1f          .
	cmp	e		;; 2389: bb          .
	jz	L23c1		;; 238a: ca c1 23    ..#
	mov	e,a		;; 238d: 5f          _
	push	h		;; 238e: e5          .
	push	d		;; 238f: d5          .
	push	b		;; 2390: c5          .
	push	h		;; 2391: e5          .
	mov	b,d		;; 2392: 42          B
	mov	c,b		;; 2393: 48          H
	mvi	d,0		;; 2394: 16 00       ..
	lxi	h,0		;; 2396: 21 00 00    ...
L2399:	dad	d		;; 2399: 19          .
	dcr	b		;; 239a: 05          .
	jnz	L2399		;; 239b: c2 99 23    ..#
	pop	d		;; 239e: d1          .
	dad	d		;; 239f: 19          .
	lxi	d,tokbuf+1		;; 23a0: 11 09 30    ..0
L23a3:	ldax	d		;; 23a3: 1a          .
	cmp	m		;; 23a4: be          .
	inx	d		;; 23a5: 13          .
	inx	h		;; 23a6: 23          #
	jnz	L23b3		;; 23a7: c2 b3 23    ..#
	dcr	c		;; 23aa: 0d          .
	jnz	L23a3		;; 23ab: c2 a3 23    ..#
	pop	b		;; 23ae: c1          .
	pop	d		;; 23af: d1          .
	pop	h		;; 23b0: e1          .
	mov	a,e		;; 23b1: 7b          {
	ret			;; 23b2: c9          .

L23b3:	pop	b		;; 23b3: c1          .
	pop	d		;; 23b4: d1          .
	pop	h		;; 23b5: e1          .
	jc	L23bd		;; 23b6: da bd 23    ..#
	mov	c,e		;; 23b9: 4b          K
	jmp	L2385		;; 23ba: c3 85 23    ..#

L23bd:	mov	b,e		;; 23bd: 43          C
	jmp	L2385		;; 23be: c3 85 23    ..#

L23c1:	xra	a		;; 23c1: af          .
	inr	a		;; 23c2: 3c          <
	ret			;; 23c3: c9          .

; parse conditional jump, call, or return
L23c4:	lda	tokbuf+1		;; 23c4: 3a 09 30    :.0
	lxi	b,0c220h	;; 23c7: 01 20 c2    . .
	cpi	'J'		;; 23ca: fe 4a       .J
	rz			;; 23cc: c8          .
	mvi	b,0c4h		;; 23cd: 06 c4       ..
	cpi	'C'		;; 23cf: fe 43       .C
	rz			;; 23d1: c8          .
	lxi	b,0c01ch	;; 23d2: 01 1c c0    ...
	cpi	'R'		;; 23d5: fe 52       .R
	ret			;; 23d7: c9          .

L23d8:	lda	tokbuf		;; 23d8: 3a 08 30    :.0
	cpi	004h		;; 23db: fe 04       ..
	jnc	L240a		;; 23dd: d2 0a 24    ..$
	cpi	003h		;; 23e0: fe 03       ..
	jz	L23ef		;; 23e2: ca ef 23    ..#
	cpi	002h		;; 23e5: fe 02       ..
	jnz	L240a		;; 23e7: c2 0a 24    ..$
	lxi	h,tokbuf+3		;; 23ea: 21 0b 30    ..0
	mvi	m,' '		;; 23ed: 36 20       6 
L23ef:	lxi	b,8		;; 23ef: 01 08 00    ...
	lxi	d,L2370		;; 23f2: 11 70 23    .p#
L23f5:	lxi	h,tokbuf+2		;; 23f5: 21 0a 30    ..0
	ldax	d		;; 23f8: 1a          .
	cmp	m		;; 23f9: be          .
	inx	d		;; 23fa: 13          .
	jnz	L2402		;; 23fb: c2 02 24    ..$
	ldax	d		;; 23fe: 1a          .
	inx	h		;; 23ff: 23          #
	cmp	m		;; 2400: be          .
	rz			;; 2401: c8          .
L2402:	inx	d		;; 2402: 13          .
	inr	b		;; 2403: 04          .
	dcr	c		;; 2404: 0d          .
	jnz	L23f5		;; 2405: c2 f5 23    ..#
	inr	c		;; 2408: 0c          .
	ret			;; 2409: c9          .

L240a:	xra	a		;; 240a: af          .
	inr	a		;; 240b: 3c          <
	ret			;; 240c: c9          .

L240d:	lda	tokbuf		;; 240d: 3a 08 30    :.0
	mov	c,a		;; 2410: 4f          O
	dcr	a		;; 2411: 3d          =
	mov	e,a		;; 2412: 5f          _
	mvi	d,0		;; 2413: 16 00       ..
	push	d		;; 2415: d5          .
	cpi	6		;; 2416: fe 06       ..
	jnc	L245e		;; 2418: d2 5e 24    .^$
	lxi	h,L2282		;; 241b: 21 82 22    .."
	dad	d		;; 241e: 19          .
	mov	b,m		;; 241f: 46          F
	lxi	h,L2110		;; 2420: 21 10 21    ...
	dad	d		;; 2423: 19          .
	dad	d		;; 2424: 19          .
	mov	d,m		;; 2425: 56          V
	inx	h		;; 2426: 23          #
	mov	h,m		;; 2427: 66          f
	mov	l,d		;; 2428: 6a          j
	mov	d,c		;; 2429: 51          Q
	call	L2380		;; 242a: cd 80 23    ..#
	jnz	L2447		;; 242d: c2 47 24    .G$
	sta	L210f		;; 2430: 32 0f 21    2..
	pop	d		;; 2433: d1          .
	lxi	h,L211e		;; 2434: 21 1e 21    ...
	dad	d		;; 2437: 19          .
	dad	d		;; 2438: 19          .
	mov	e,m		;; 2439: 5e          ^
	inx	h		;; 243a: 23          #
	mov	d,m		;; 243b: 56          V
	mov	l,a		;; 243c: 6f          o
	mvi	h,0		;; 243d: 26 00       &.
	dad	h		;; 243f: 29          )
	dad	d		;; 2440: 19          .
	xra	a		;; 2441: af          .
	mov	c,a		;; 2442: 4f          O
	mov	a,m		;; 2443: 7e          ~
	inx	h		;; 2444: 23          #
	mov	b,m		;; 2445: 46          F
	ret			;; 2446: c9          .

L2447:	pop	d		;; 2447: d1          .
	call	L23c4		;; 2448: cd c4 23    ..#
	rnz			;; 244b: c0          .
	push	b		;; 244c: c5          .
	call	L23d8		;; 244d: cd d8 23    ..#
	mov	a,b		;; 2450: 78          x
	pop	b		;; 2451: c1          .
	rnz			;; 2452: c0          .
	ora	a		;; 2453: b7          .
	ral			;; 2454: 17          .
	ral			;; 2455: 17          .
	ral			;; 2456: 17          .
	ora	b		;; 2457: b0          .
	mov	b,a		;; 2458: 47          G
	mov	a,c		;; 2459: 79          y
	cmp	a		;; 245a: bf          .
	mvi	c,001h		;; 245b: 0e 01       ..
	ret			;; 245d: c9          .

L245e:	pop	d		;; 245e: d1          .
	xra	a		;; 245f: af          .
	inr	a		;; 2460: 3c          <
	ret			;; 2461: c9          .

L2462:	lxi	h,tokbuf		;; 2462: 21 08 30    ..0
	mov	c,m		;; 2465: 4e          N
	dcr	c		;; 2466: 0d          .
	lxi	h,L2283		;; 2467: 21 83 22    .."
	xra	a		;; 246a: af          .
L246b:	dcr	c		;; 246b: 0d          .
	jz	L2474		;; 246c: ca 74 24    .t$
	add	m		;; 246f: 86          .
	inx	h		;; 2470: 23          #
	jmp	L246b		;; 2471: c3 6b 24    .k$

L2474:	lxi	h,L210f		;; 2474: 21 0f 21    ...
	add	m		;; 2477: 86          .
	ori	080h		;; 2478: f6 80       ..
	ret			;; 247a: c9          .

L247b:	ani	07fh		;; 247b: e6 7f       ..
	lxi	h,L2499		;; 247d: 21 99 24    ..$
	mov	e,a		;; 2480: 5f          _
	mvi	d,0		;; 2481: 16 00       ..
	dad	d		;; 2483: 19          .
	dad	d		;; 2484: 19          .
	mov	e,m		;; 2485: 5e          ^
	inx	h		;; 2486: 23          #
	mov	a,m		;; 2487: 7e          ~
	rar			;; 2488: 1f          .
	rar			;; 2489: 1f          .
	rar			;; 248a: 1f          .
	rar			;; 248b: 1f          .
	ani	00fh		;; 248c: e6 0f       ..
	mov	b,a		;; 248e: 47          G
	mov	a,m		;; 248f: 7e          ~
	ani	00fh		;; 2490: e6 0f       ..
	mov	d,a		;; 2492: 57          W
	lxi	h,tok2		;; 2493: 21 3a 21    .:.
	dad	d		;; 2496: 19          .
	mov	a,b		;; 2497: 78          x
	ret			;; 2498: c9          .

; length and offset of each token, relative to tok2
L2499:	dw	2000h
	dw	2002h
	dw	2004h
	dw	2006h
	dw	2008h
	dw	200ah
	dw	200ch
	dw	200eh
	dw	2010h
	dw	2012h
	dw	2014h
	dw	2016h
	dw	2018h
	dw	201ah
	dw	201ch
	dw	301eh
	dw	3021h
	dw	3024h
	dw	3027h
	dw	302ah
	dw	302dh
	dw	3030h
	dw	3033h
	dw	3036h
	dw	3039h
	dw	303ch
	dw	303fh
	dw	3042h
	dw	3045h
	dw	3048h
	dw	304bh
	dw	304eh
	dw	3051h
	dw	3054h
	dw	3057h
	dw	305ah
	dw	305dh
	dw	3060h
	dw	3063h
	dw	3066h
	dw	3069h
	dw	306ch
	dw	306fh
	dw	3072h
	dw	3075h
	dw	3078h
	dw	307bh
	dw	307eh
	dw	3081h
	dw	3084h
	dw	3087h
	dw	308ah
	dw	308dh
	dw	3090h
	dw	3093h
	dw	3096h
	dw	3099h
	dw	309ch
	dw	309fh
	dw	30a2h
	dw	30a5h
	dw	30a8h
	dw	30abh
	dw	30aeh
	dw	30b1h
	dw	30b4h
	dw	30b7h
	dw	30bah
	dw	30bdh
	dw	30c0h
	dw	40c3h
	dw	40c7h
	dw	40cbh
	dw	40cfh
	dw	40d3h
	dw	40d7h
	dw	40dbh
	dw	40dfh
	dw	40e3h
	dw	40e7h
	dw	40ebh
	dw	40efh
	dw	40f3h
	dw	40f7h
	dw	40fbh
	dw	40ffh
	dw	4103h
	dw	4107h
	dw	410bh
	dw	410fh
	dw	5113h
	dw	5118h
	dw	511dh
	dw	5122h
	dw	5127h
	dw	512ch
	dw	5131h
	dw	6136h
	dw	613ch
	dw	6142h

	; ghost code from DS...
	dw	3058h
	db	22h,0bdh,11h	;; 2563: 22 bd 11    "..
	db	0cdh,06h,16h	;; 2566: cd 06 16    ...
	db	0c3h,57h,07h	;; 2569: c3 57 07    .W.

	db	'z{|}'
	xra	a		;; 2570: af          .
	mov	c,a		;; 2571: 4f          O
	mov	a,m		;; 2572: 7e          ~
	inx	h		;; 2573: 23          #
	mov	b,m		;; 2574: 46          F
	ret			;; 2575: c9          .

	mov	a,c		;; 2576: 79          y
	mvi	c,001h		;; 2577: 0e 01       ..
	cmp	a		;; 2579: bf          .
	ret			;; 257a: c9          .

	db	'SEAR'
	db	' '

; Module start L2580 - I/O, OS?
L2580:	jmp	osinit		;; 2580: c3 f6 26    ..&
L2583:	jmp	L2905		;; 2583: c3 05 29    ..)
L2586:	jmp	L294c		;; 2586: c3 4c 29    .L)
	jmp	prnput		;; 2589: c3 0e 2a    ..*
	jmp	hexput		;; 258c: c3 95 2a    ..*
	jmp	chrout		;; 258f: c3 c9 2a    ..*
msgcre:	jmp	msgcr		;; 2592: c3 78 26    .x&
L2595:	jmp	L2b74		;; 2595: c3 74 2b    .t+
setere:	jmp	seterr		;; 2598: c3 21 2c    ..,
hexpte:	jmp	hexpt0		;; 259b: c3 a3 2d    ..-
hexfne:	jmp	hexpt2		;; 259e: c3 8b 2c    ..,
L25a1:	jmp	L2c49		;; 25a1: c3 49 2c    .I,
libfie:	jmp	libfil		;; 25a4: c3 a1 26    ..&
L25a7:	jmp	L26e1		;; 25a7: c3 e1 26    ..&
L25aa:	jmp	L2b4d		;; 25aa: c3 4d 2b    .M+
L25ad:	jmp	L2af9		;; 25ad: c3 f9 2a    ..*

L25b0:	db	80h,0,0	; line number, ASCII ("000")
paglin:	db	0	; max PRN lines/page (0=infinit)
curlin:	db	0	; current PRN line (in page)
Fflag:	db	0	; $[+-*]1 flag
hexadr:	db	0,0
hexlen:	db	0
L25b9:	db	0,0,0,0,19h,0,0,0,'7',0eh,1ah,0c3h,5,0,11h,80h
curdrv:	db	0	; current disk (any op)
asmsrc:	db	0c3h	; source - ASM "$Ax"
prndst:	db	0c2h	; dest for PRN "$Px"
symdst:	db	'%'	; dest for SYM "$Sx"
hexdst:	db	21h	; dest for HEX "$Hx"
libsrc:	db	'I'	; src libs LIB "$Lx"
L25cf:	db	'%'
dmaidx:	db	0beh,0c8h
L25d2:	db	'w'

; FCB for ASM
asmfcb:	db	'_',0eh,0eh,0cdh,5,0,0c9h,':J','ASM'
	db	0,'PE',0,0c3h,0cdh,'%:L%',0c3h,0cdh,'%:M%',0c3h,0cdh,'%'
	db	':'
	db	0

L25f4:	db	0,4
L25f6:	db	0,0

; FCB for PRN and SYM
prnfcb:	db	4,0cdh,'I*~#',0feh,0dh
L2600:	db	0ffh	;something is wrong here - module termination?
	db	'PRN',0,'FTYPE',0,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	db	0ffh,0ffh,0ffh,0ffh,'s'
	db	0

prnidx:	db	0,0
L261b:	db	0ffh,0ffh

; FCB for HEX
hexfcb:	db	0ffh,0,0,0,0ffh,0ffh,0ffh,0ffh,0ffh,'HEX',0,0ffh,0ffh,'&FTYP'
	db	'E',0,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0

hexidx:	db	0,0

L2640:	db	0ffh,0ffh

L2642:	mvi	c,setdma	;; 2642: 0e 1a       ..
	jmp	bdos		;; 2644: c3 05 00    ...

L2647:	lxi	d,defdma	;; 2647: 11 80 00    ...
	jmp	L2642		;; 264a: c3 42 26    .B&

seldrv:	lxi	h,curdrv		;; 264d: 21 c9 25    ..%
	cmp	m		;; 2650: be          .
	rz			;; 2651: c8          .
	mov	m,a		;; 2652: 77          w
	mov	e,a		;; 2653: 5f          _
	mvi	c,seldsk	;; 2654: 0e 0e       ..
	call	bdos		;; 2656: cd 05 00    ...
	ret			;; 2659: c9          .

setasm:	lda	asmsrc		;; 265a: 3a ca 25    :.%
	jmp	seldrv		;; 265d: c3 4d 26    .M&

setprn:	lda	prndst		;; 2660: 3a cb 25    :.%
	jmp	seldrv		;; 2663: c3 4d 26    .M&

setsym:	lda	symdst		;; 2666: 3a cc 25    :.%
	jmp	seldrv		;; 2669: c3 4d 26    .M&

sethex:	lda	hexdst		;; 266c: 3a cd 25    :.%
	jmp	seldrv		;; 266f: c3 4d 26    .M&

setlib:	lda	libsrc		;; 2672: 3a ce 25    :.%
	jmp	seldrv		;; 2675: c3 4d 26    .M&

; print string until CR, add LF
msgcr:	mov	a,m		;; 2678: 7e          ~
	call	chrout		;; 2679: cd c9 2a    ..*
	mov	a,m		;; 267c: 7e          ~
	inx	h		;; 267d: 23          #
	cpi	cr		;; 267e: fe 0d       ..
	jnz	msgcr		;; 2680: c2 78 26    .x&
	mvi	a,lf		;; 2683: 3e 0a       >.
	call	chrout		;; 2685: cd c9 2a    ..*
	ret			;; 2688: c9          .

; Copy cmdline FCB basename to (HL)
L2689:	lxi	d,deffcb	;; 2689: 11 5c 00    .\.
	mvi	b,9		;; 268c: 06 09       ..
L268e:	ldax	d		;; 268e: 1a          .
	cpi	'?'		;; 268f: fe 3f       .?
	jz	L293d		;; 2691: ca 3d 29    .=)
	cpi	'$'		;; 2694: fe 24       .$
	jz	L293d		;; 2696: ca 3d 29    .=)
	mov	m,a		;; 2699: 77          w
	inx	h		;; 269a: 23          #
	inx	d		;; 269b: 13          .
	dcr	b		;; 269c: 05          .
	jnz	L268e		;; 269d: c2 8e 26    ..&
	ret			;; 26a0: c9          .

; setup LIB FCB, open it
libfil:	lxi	h,deffcb	;; 26a1: 21 5c 00    .\.
	mvi	m,0		;; 26a4: 36 00       6.
	lxi	d,tokbuf		;; 26a6: 11 08 30    ..0
	ldax	d		;; 26a9: 1a          .
	cpi	9		;; 26aa: fe 09       ..
	jc	L26b1		;; 26ac: da b1 26    ..&
	mvi	a,8		;; 26af: 3e 08       >.
L26b1:	mov	b,a		;; 26b1: 47          G
	mov	c,a		;; 26b2: 4f          O
L26b3:	inx	d		;; 26b3: 13          .
	inx	h		;; 26b4: 23          #
	ldax	d		;; 26b5: 1a          .
	mov	m,a		;; 26b6: 77          w
	dcr	c		;; 26b7: 0d          .
	jnz	L26b3		;; 26b8: c2 b3 26    ..&
	mvi	a,8		;; 26bb: 3e 08       >.
	sub	b		;; 26bd: 90          .
	mov	c,a		;; 26be: 4f          O
	inr	c		;; 26bf: 0c          .
L26c0:	inx	h		;; 26c0: 23          #
	dcr	c		;; 26c1: 0d          .
	jz	L26ca		;; 26c2: ca ca 26    ..&
	mvi	m,' '		;; 26c5: 36 20       6 
	jmp	L26c0		;; 26c7: c3 c0 26    ..&

L26ca:	mvi	m,'L'		;; 26ca: 36 4c       6L
	inx	h		;; 26cc: 23          #
	mvi	m,'I'		;; 26cd: 36 49       6I
	inx	h		;; 26cf: 23          #
	mvi	m,'B'		;; 26d0: 36 42       6B
	inx	h		;; 26d2: 23          #
	xra	a		;; 26d3: af          .
	mov	m,a		;; 26d4: 77          w
	sta	deffcb+32	;; 26d5: 32 7c 00    2|.
	call	setlib		;; 26d8: cd 72 26    .r&
	lxi	d,deffcb	;; 26db: 11 5c 00    .\.
	jmp	openf		;; 26de: c3 75 27    .u'

L26e1:	mvi	a,0ffh		;; 26e1: 3e ff       >.
	sta	L305d		;; 26e3: 32 5d 30    2]0
	lxi	h,128		;; 26e6: 21 80 00    ...
	shld	dmaidx		;; 26e9: 22 d0 25    ".%
	lxi	h,L305b		;; 26ec: 21 5b 30    .[0
	mov	a,m		;; 26ef: 7e          ~
	sta	L25cf		;; 26f0: 32 cf 25    2.%
	xra	a		;; 26f3: af          .
	mov	m,a		;; 26f4: 77          w
	ret			;; 26f5: c9          .

osinit:	call	L2647		;; 26f6: cd 47 26    .G&
	lxi	h,L2cd3		;; 26f9: 21 d3 2c    ..,
	call	msgcr		;; 26fc: cd 78 26    .x&
	mvi	a,56		;; 26ff: 3e 38       >8
	sta	paglin		;; 2701: 32 b3 25    2.%
	xra	a		;; 2704: af          .
	sta	curlin		;; 2705: 32 b4 25    2.%
	lxi	h,0		;; 2708: 21 00 00    ...
	shld	L3062		;; 270b: 22 62 30    "b0
	lhld	bdos+1		;; 270e: 2a 06 00    *..
	shld	memtop		;; 2711: 22 4d 30    "M0
	lxi	h,buffer	;; 2714: 21 00 31    ..1
	shld	L25f6		;; 2717: 22 f6 25    ".%
	lxi	d,1024		;; 271a: 11 00 04    ...
	dad	d		;; 271d: 19          .
	shld	L261b		;; 271e: 22 1b 26    ".&
	lxi	d,768		;; 2721: 11 00 03    ...
	dad	d		;; 2724: 19          .
	shld	L2640		;; 2725: 22 40 26    "@&
	lxi	d,768		;; 2728: 11 00 03    ...
	dad	d		;; 272b: 19          .
	inx	h		;; 272c: 23          #
	shld	nxheap		;; 272d: 22 4b 30    "K0
	shld	syheap		;; 2730: 22 54 30    "T0
	jmp	parcmd		;; 2733: c3 ea 27    ..'

; output char to console, suppressing blanks
L2736:	cpi	' '		;; 2736: fe 20       . 
	rz			;; 2738: c8          .
	push	b		;; 2739: c5          .
	push	h		;; 273a: e5          .
	mov	e,a		;; 273b: 5f          _
	mvi	c,conout	;; 273c: 0e 02       ..
	call	bdos		;; 273e: cd 05 00    ...
	pop	h		;; 2741: e1          .
	pop	b		;; 2742: c1          .
	ret			;; 2743: c9          .

; output C chars from HL to console, suppressing blanks
L2744:	inx	h		;; 2744: 23          #
	mov	a,m		;; 2745: 7e          ~
	call	L2736		;; 2746: cd 36 27    .6'
	dcr	c		;; 2749: 0d          .
	jnz	L2744		;; 274a: c2 44 27    .D'
	ret			;; 274d: c9          .

; display file name, incl. drive, then '-' and msg from HL
filerr:	push	h		;; 274e: e5          .
	xchg			;; 274f: eb          .
	lda	curdrv		;; 2750: 3a c9 25    :.%
	adi	'A'		;; 2753: c6 41       .A
	call	L2736		;; 2755: cd 36 27    .6'
	mvi	a,':'		;; 2758: 3e 3a       >:
	call	L2736		;; 275a: cd 36 27    .6'
	mvi	c,8		;; 275d: 0e 08       ..
	call	L2744		;; 275f: cd 44 27    .D'
	mvi	a,'.'		;; 2762: 3e 2e       >.
	call	L2736		;; 2764: cd 36 27    .6'
	mvi	c,3		;; 2767: 0e 03       ..
	call	L2744		;; 2769: cd 44 27    .D'
	mvi	a,'-'		;; 276c: 3e 2d       >-
	call	L2736		;; 276e: cd 36 27    .6'
	pop	h		;; 2771: e1          .
	jmp	msgcr		;; 2772: c3 78 26    .x&

openf:	mvi	c,open		;; 2775: 0e 0f       ..
	push	d		;; 2777: d5          .
	call	bdos		;; 2778: cd 05 00    ...
	cpi	0ffh		;; 277b: fe ff       ..
	pop	d		;; 277d: d1          .
	rnz			;; 277e: c0          .
	lxi	h,L2ce8		;; 277f: 21 e8 2c    ..,
	call	filerr		;; 2782: cd 4e 27    .N'
	jmp	cpm		;; 2785: c3 00 00    ...

closef:	mvi	c,close		;; 2788: 0e 10       ..
	push	d		;; 278a: d5          .
	call	bdos		;; 278b: cd 05 00    ...
	cpi	0ffh		;; 278e: fe ff       ..
	pop	d		;; 2790: d1          .
	rnz			;; 2791: c0          .
	lxi	h,L2d6b		;; 2792: 21 6b 2d    .k-
	call	msgcr		;; 2795: cd 78 26    .x&
	jmp	cpm		;; 2798: c3 00 00    ...

deletf:	mvi	c,delete	;; 279b: 0e 13       ..
	jmp	bdos		;; 279d: c3 05 00    ...

makef:	mvi	c,make		;; 27a0: 0e 16       ..
	push	d		;; 27a2: d5          .
	call	bdos		;; 27a3: cd 05 00    ...
	cpi	0ffh		;; 27a6: fe ff       ..
	pop	d		;; 27a8: d1          .
	rnz			;; 27a9: c0          .
	lxi	h,L2cff		;; 27aa: 21 ff 2c    ..,
	call	filerr		;; 27ad: cd 4e 27    .N'
	jmp	cpm		;; 27b0: c3 00 00    ...

isfile:	lda	prndst		;; 27b3: 3a cb 25    :.%
	cpi	DRVNUL		;; 27b6: fe 19       ..
	rz			;; 27b8: c8          .
	cpi	DRVCON		;; 27b9: fe 17       ..
	rz			;; 27bb: c8          .
	cpi	DRVLST		;; 27bc: fe 0f       ..
	ret			;; 27be: c9          .

; expand TAB char
L27bf:	cpi	tab		;; 27bf: fe 09       ..
	jnz	L27d2		;; 27c1: c2 d2 27    ..'
L27c4:	mvi	a,' '		;; 27c4: 3e 20       > 
	call	L27d2		;; 27c6: cd d2 27    ..'
	lda	L25d2		;; 27c9: 3a d2 25    :.%
	ani	007h		;; 27cc: e6 07       ..
	jnz	L27c4		;; 27ce: c2 c4 27    ..'
	ret			;; 27d1: c9          .

L27d2:	push	psw		;; 27d2: f5          .
	mov	e,a		;; 27d3: 5f          _
	mvi	c,lstout	;; 27d4: 0e 05       ..
	call	bdos		;; 27d6: cd 05 00    ...
	pop	psw		;; 27d9: f1          .
	lxi	h,L25d2		;; 27da: 21 d2 25    ..%
	cpi	lf		;; 27dd: fe 0a       ..
	jnz	L27e5		;; 27df: c2 e5 27    ..'
	mvi	m,0		;; 27e2: 36 00       6.
	ret			;; 27e4: c9          .

; count printable chars
L27e5:	cpi	' '		;; 27e5: fe 20       . 
	rc			;; 27e7: d8          .
	inr	m		;; 27e8: 34          4
	ret			;; 27e9: c9          .

; parse commandline buffer
parcmd:	xra	a		;; 27ea: af          .
	; set all defaults
	sta	L25d2		;; 27eb: 32 d2 25    2.%
	sta	L305d		;; 27ee: 32 5d 30    2]0
	sta	Lflag		;; 27f1: 32 65 30    2e0
	sta	Qflag		;; 27f4: 32 64 30    2d0
	sta	Rflag		;; 27f7: 32 67 30    2g0
	sta	Fflag		;; 27fa: 32 b5 25    2.%
	lda	deffcb		;; 27fd: 3a 5c 00    :\.
	cpi	' '		;; 2800: fe 20       . 
	jz	L293d		;; 2802: ca 3d 29    .=)
	mvi	c,curdsk	;; 2805: 0e 19       ..
	call	bdos		;; 2807: cd 05 00    ...
	lxi	h,curdrv	;; 280a: 21 c9 25    ..%
	mov	m,a		;; 280d: 77          w
	inx	h		;; 280e: 23          #
	mov	m,a		;; 280f: 77          w
	inx	h		;; 2810: 23          #
	mov	m,a		;; 2811: 77          w
	inx	h		;; 2812: 23          #
	mov	m,a		;; 2813: 77          w
	inx	h		;; 2814: 23          #
	mov	m,a		;; 2815: 77          w
	inx	h		;; 2816: 23          #
	mov	m,a		;; 2817: 77          w
	inx	h		;; 2818: 23          #
	mvi	a,1		;; 2819: 3e 01       >.
	sta	Sflag		;; 281b: 32 5e 30    2^0
	sta	Mflag		;; 281e: 32 5f 30    2_0
	; see if options specified
	lda	deffcb+17	;; 2821: 3a 6d 00    :m.
	cpi	'$'		;; 2824: fe 24       .$
	jnz	L28c8		;; 2826: c2 c8 28    ..(
	lxi	h,cmdlin+1	;; 2829: 21 81 00    ...
L282c:	mov	a,m		;; 282c: 7e          ~
	inx	h		;; 282d: 23          #
	cpi	'$'		;; 282e: fe 24       .$
	jnz	L282c		;; 2830: c2 2c 28    .,(
L2833:	mov	a,m		;; 2833: 7e          ~
	ora	a		;; 2834: b7          .
	jz	L28c8		;; 2835: ca c8 28    ..(
	inx	h		;; 2838: 23          #
	cpi	' '		;; 2839: fe 20       . 
	jz	L2833		;; 283b: ca 33 28    .3(
	lxi	d,asmsrc	;; 283e: 11 ca 25    ..%
	cpi	'A'		;; 2841: fe 41       .A
	jz	L28a9		;; 2843: ca a9 28    ..(
	inx	d		;; 2846: 13          .
	cpi	'P'		;; 2847: fe 50       .P
	jz	L28a9		;; 2849: ca a9 28    ..(
	inx	d		;; 284c: 13          .
	cpi	'S'		;; 284d: fe 53       .S
	jz	L28a9		;; 284f: ca a9 28    ..(
	inx	d		;; 2852: 13          .
	cpi	'H'		;; 2853: fe 48       .H
	jz	L28a9		;; 2855: ca a9 28    ..(
	inx	d		;; 2858: 13          .
	cpi	'L'		;; 2859: fe 4c       .L
	jz	L28a9		;; 285b: ca a9 28    ..(
	inx	d		;; 285e: 13          .
	mvi	b,007h		;; 285f: 06 07       ..
	cpi	'*'		;; 2861: fe 2a       .*
	jz	L2874		;; 2863: ca 74 28    .t(
	mvi	b,003h		;; 2866: 06 03       ..
	cpi	'+'		;; 2868: fe 2b       .+
	jz	L2874		;; 286a: ca 74 28    .t(
	mvi	b,000h		;; 286d: 06 00       ..
	cpi	'-'		;; 286f: fe 2d       .-
	jnz	cmderr		;; 2871: c2 b6 28    ..(
L2874:	lxi	d,Sflag		;; 2874: 11 5e 30    .^0
	mov	a,m		;; 2877: 7e          ~
	cpi	'S'		;; 2878: fe 53       .S
	jz	L28a3		;; 287a: ca a3 28    ..(
	inx	d		;; 287d: 13          .
	cpi	'M'		;; 287e: fe 4d       .M
	jz	L28a3		;; 2880: ca a3 28    ..(
	lxi	d,Lflag		;; 2883: 11 65 30    .e0
	cpi	'L'		;; 2886: fe 4c       .L
	jz	L28a3		;; 2888: ca a3 28    ..(
	lxi	d,Qflag		;; 288b: 11 64 30    .d0
	cpi	'Q'		;; 288e: fe 51       .Q
	jz	L28a3		;; 2890: ca a3 28    ..(
	lxi	d,Rflag		;; 2893: 11 67 30    .g0
	cpi	'R'		;; 2896: fe 52       .R
	jz	L28a3		;; 2898: ca a3 28    ..(
	lxi	d,Fflag		;; 289b: 11 b5 25    ..%
	cpi	'1'		;; 289e: fe 31       .1
	jnz	cmderr		;; 28a0: c2 b6 28    ..(
L28a3:	mov	a,b		;; 28a3: 78          x
	stax	d		;; 28a4: 12          .
	inx	h		;; 28a5: 23          #
	jmp	L2833		;; 28a6: c3 33 28    .3(

L28a9:	mov	a,m		;; 28a9: 7e          ~
	sui	'A'		;; 28aa: d6 41       .A
	cpi	'Z'-'A'+1	;; 28ac: fe 1a       ..
	jnc	cmderr		;; 28ae: d2 b6 28    ..(
	stax	d		;; 28b1: 12          .
	inx	h		;; 28b2: 23          #
	jmp	L2833		;; 28b3: c3 33 28    .3(

; syntax error in commandline
cmderr:	inx	h		;; 28b6: 23          #
	mvi	m,cr		;; 28b7: 36 0d       6.
	lxi	h,L2d29		;; 28b9: 21 29 2d    .)-
	call	msgcr		;; 28bc: cd 78 26    .x&
	lxi	h,cmdlin+1	;; 28bf: 21 81 00    ...
	call	msgcr		;; 28c2: cd 78 26    .x&
	jmp	cpm		;; 28c5: c3 00 00    ...

L28c8:	lxi	h,asmfcb		;; 28c8: 21 d3 25    ..%
	call	L2689		;; 28cb: cd 89 26    ..&
	lxi	h,prnfcb	;; 28ce: 21 f8 25    ..%
	push	h		;; 28d1: e5          .
	call	L2689		;; 28d2: cd 89 26    ..&
	pop	h		;; 28d5: e1          .
	call	isfile		;; 28d6: cd b3 27    ..'
	jz	L28e9		;; 28d9: ca e9 28    ..(
	push	h		;; 28dc: e5          .
	push	h		;; 28dd: e5          .
	call	setprn		;; 28de: cd 60 26    .`&
	pop	d		;; 28e1: d1          .
	call	deletf		;; 28e2: cd 9b 27    ..'
	pop	d		;; 28e5: d1          .
	call	makef		;; 28e6: cd a0 27    ..'
L28e9:	lda	hexdst		;; 28e9: 3a cd 25    :.%
	cpi	DRVNUL		;; 28ec: fe 19       ..
	jz	L2904		;; 28ee: ca 04 29    ..)
	lxi	h,hexfcb	;; 28f1: 21 1d 26    ..&
	push	h		;; 28f4: e5          .
	push	h		;; 28f5: e5          .
	call	L2689		;; 28f6: cd 89 26    ..&
	call	sethex		;; 28f9: cd 6c 26    .l&
	pop	d		;; 28fc: d1          .
	call	deletf		;; 28fd: cd 9b 27    ..'
	pop	d		;; 2900: d1          .
	call	makef		;; 2901: cd a0 27    ..'
L2904:	ret			;; 2904: c9          .

L2905:	lxi	h,L25b0		;; 2905: 21 b0 25    ..%
	mvi	m,'0'		;; 2908: 36 30       60
	inx	h		;; 290a: 23          #
	mvi	m,'0'		;; 290b: 36 30       60
	inx	h		;; 290d: 23          #
	mvi	m,'0'		;; 290e: 36 30       60
	inx	h		;; 2910: 23          #
	mvi	a,0ffh		;; 2911: 3e ff       >.
	sta	L3066		;; 2913: 32 66 30    2f0
	lxi	h,0		;; 2916: 21 00 00    ...
	shld	prnidx		;; 2919: 22 19 26    ".&
	lda	pass		;; 291c: 3a 4f 30    :O0
	ora	a		;; 291f: b7          .
	cnz	L2af9		;; 2920: c4 f9 2a    ..*
	lxi	h,1024		;; 2923: 21 00 04    ...
	shld	L25f4		;; 2926: 22 f4 25    ".%
	xra	a		;; 2929: af          .
	sta	asmfcb+12	;; 292a: 32 df 25    2.%
	sta	asmfcb+32	;; 292d: 32 f3 25    2.%
	sta	hexlen		;; 2930: 32 b8 25    2.%
	call	setasm		;; 2933: cd 5a 26    .Z&
	lxi	d,asmfcb		;; 2936: 11 d3 25    ..%
	call	openf		;; 2939: cd 75 27    .u'
	ret			;; 293c: c9          .

L293d:	lxi	h,L2d12		;; 293d: 21 12 2d    ..-
	call	msgcr		;; 2940: cd 78 26    .x&
	jmp	cpm		;; 2943: c3 00 00    ...

compar:	mov	a,d		;; 2946: 7a          z
	cmp	h		;; 2947: bc          .
	rnz			;; 2948: c0          .
	mov	a,e		;; 2949: 7b          {
	cmp	l		;; 294a: bd          .
	ret			;; 294b: c9          .

L294c:	push	b		;; 294c: c5          .
	push	d		;; 294d: d5          .
	push	h		;; 294e: e5          .
	lda	L305d		;; 294f: 3a 5d 30    :]0
	ora	a		;; 2952: b7          .
	jz	L29a2		;; 2953: ca a2 29    ..)
	lhld	dmaidx		;; 2956: 2a d0 25    *.%
	lxi	d,128		;; 2959: 11 80 00    ...
	call	compar		;; 295c: cd 46 29    .F)
	jnz	L2977		;; 295f: c2 77 29    .w)
	lxi	h,0		;; 2962: 21 00 00    ...
	shld	dmaidx		;; 2965: 22 d0 25    ".%
	call	setlib		;; 2968: cd 72 26    .r&
	mvi	c,read		;; 296b: 0e 14       ..
	lxi	d,deffcb	;; 296d: 11 5c 00    .\.
	call	bdos		;; 2970: cd 05 00    ...
	ora	a		;; 2973: b7          .
	jnz	L2989		;; 2974: c2 89 29    ..)
L2977:	lhld	dmaidx		;; 2977: 2a d0 25    *.%
	inx	h		;; 297a: 23          #
	shld	dmaidx		;; 297b: 22 d0 25    ".%
	dcx	h		;; 297e: 2b          +
	lxi	d,defdma	;; 297f: 11 80 00    ...
	dad	d		;; 2982: 19          .
	mov	a,m		;; 2983: 7e          ~
	cpi	eof		;; 2984: fe 1a       ..
	jnz	L29ff		;; 2986: c2 ff 29    ..)
L2989:	lda	L2ea3		;; 2989: 3a a3 2e    :..
	ora	a		;; 298c: b7          .
	sta	L305d		;; 298d: 32 5d 30    2]0
	jz	L29a2		;; 2990: ca a2 29    ..)
	call	setlib		;; 2993: cd 72 26    .r&
	lxi	d,deffcb	;; 2996: 11 5c 00    .\.
	lxi	h,L2d7e		;; 2999: 21 7e 2d    .~-
	call	filerr		;; 299c: cd 4e 27    .N'
	jmp	cpm		;; 299f: c3 00 00    ...

L29a2:	lhld	L25f4		;; 29a2: 2a f4 25    *.%
	lxi	d,1024		;; 29a5: 11 00 04    ...
	call	compar		;; 29a8: cd 46 29    .F)
	jnz	L29f0		;; 29ab: c2 f0 29    ..)
	call	setasm		;; 29ae: cd 5a 26    .Z&
	lxi	h,0		;; 29b1: 21 00 00    ...
	shld	L25f4		;; 29b4: 22 f4 25    ".%
	mvi	b,8		;; 29b7: 06 08       ..
	lhld	L25f6		;; 29b9: 2a f6 25    *.%
L29bc:	push	b		;; 29bc: c5          .
	push	h		;; 29bd: e5          .
	xchg			;; 29be: eb          .
	call	L2642		;; 29bf: cd 42 26    .B&
	mvi	c,read		;; 29c2: 0e 14       ..
	lxi	d,asmfcb		;; 29c4: 11 d3 25    ..%
	call	bdos		;; 29c7: cd 05 00    ...
	pop	h		;; 29ca: e1          .
	lxi	d,128		;; 29cb: 11 80 00    ...
	dad	d		;; 29ce: 19          .
	pop	b		;; 29cf: c1          .
	ora	a		;; 29d0: b7          .
	jnz	L29db		;; 29d1: c2 db 29    ..)
	dcr	b		;; 29d4: 05          .
	jnz	L29bc		;; 29d5: c2 bc 29    ..)
	jmp	L29ed		;; 29d8: c3 ed 29    ..)

L29db:	cpi	003h		;; 29db: fe 03       ..
	jnc	L2a05		;; 29dd: d2 05 2a    ..*
	dcr	b		;; 29e0: 05          .
	jz	L29ed		;; 29e1: ca ed 29    ..)
	mvi	c,128		;; 29e4: 0e 80       ..
L29e6:	mvi	m,eof		;; 29e6: 36 1a       6.
	inx	h		;; 29e8: 23          #
	dcr	c		;; 29e9: 0d          .
	jnz	L29e6		;; 29ea: c2 e6 29    ..)
L29ed:	call	L2647		;; 29ed: cd 47 26    .G&
L29f0:	lhld	L25f6		;; 29f0: 2a f6 25    *.%
	xchg			;; 29f3: eb          .
	lhld	L25f4		;; 29f4: 2a f4 25    *.%
	push	h		;; 29f7: e5          .
	inx	h		;; 29f8: 23          #
	shld	L25f4		;; 29f9: 22 f4 25    ".%
	pop	h		;; 29fc: e1          .
	dad	d		;; 29fd: 19          .
	mov	a,m		;; 29fe: 7e          ~
L29ff:	pop	h		;; 29ff: e1          .
	pop	d		;; 2a00: d1          .
	pop	b		;; 2a01: c1          .
	ani	07fh		;; 2a02: e6 7f       ..
	ret			;; 2a04: c9          .

L2a05:	lxi	h,L2d3c		;; 2a05: 21 3c 2d    .<-
	call	msgcr		;; 2a08: cd 78 26    .x&
	jmp	cpm		;; 2a0b: c3 00 00    ...

prnput:	push	b		;; 2a0e: c5          .
	mov	b,a		;; 2a0f: 47          G
	lda	prndst		;; 2a10: 3a cb 25    :.%
	cpi	DRVNUL		;; 2a13: fe 19       ..
	jz	L2a37		;; 2a15: ca 37 2a    .7*
	cpi	DRVCON		;; 2a18: fe 17       ..
	jnz	L2a24		;; 2a1a: c2 24 2a    .$*
	mov	a,b		;; 2a1d: 78          x
	call	chrout		;; 2a1e: cd c9 2a    ..*
	jmp	L2a37		;; 2a21: c3 37 2a    .7*

L2a24:	push	d		;; 2a24: d5          .
	push	h		;; 2a25: e5          .
	cpi	DRVLST		;; 2a26: fe 0f       ..
	mov	a,b		;; 2a28: 78          x
	jnz	L2a32		;; 2a29: c2 32 2a    .2*
	call	L27bf		;; 2a2c: cd bf 27    ..'
	jmp	L2a35		;; 2a2f: c3 35 2a    .5*

L2a32:	call	L2a39		;; 2a32: cd 39 2a    .9*
L2a35:	pop	h		;; 2a35: e1          .
	pop	d		;; 2a36: d1          .
L2a37:	pop	b		;; 2a37: c1          .
	ret			;; 2a38: c9          .

L2a39:	lhld	prnidx		;; 2a39: 2a 19 26    *.&
	xchg			;; 2a3c: eb          .
	lhld	L261b		;; 2a3d: 2a 1b 26    *.&
	dad	d		;; 2a40: 19          .
	mov	m,a		;; 2a41: 77          w
	xchg			;; 2a42: eb          .
	inx	h		;; 2a43: 23          #
	shld	prnidx		;; 2a44: 22 19 26    ".&
	xchg			;; 2a47: eb          .
	lxi	h,768		;; 2a48: 21 00 03    ...
	call	compar		;; 2a4b: cd 46 29    .F)
	rnz			;; 2a4e: c0          .
	call	setprn		;; 2a4f: cd 60 26    .`&
	lxi	h,0		;; 2a52: 21 00 00    ...
	shld	prnidx		;; 2a55: 22 19 26    ".&
	lhld	L261b		;; 2a58: 2a 1b 26    *.&
	lxi	d,prnfcb	;; 2a5b: 11 f8 25    ..%
	mvi	b,6		;; 2a5e: 06 06       ..
L2a60:	mov	a,m		;; 2a60: 7e          ~
	cpi	eof		;; 2a61: fe 1a       ..
	jz	L2a85		;; 2a63: ca 85 2a    ..*
	push	b		;; 2a66: c5          .
	push	d		;; 2a67: d5          .
	push	h		;; 2a68: e5          .
	xchg			;; 2a69: eb          .
	call	L2642		;; 2a6a: cd 42 26    .B&
	pop	h		;; 2a6d: e1          .
	lxi	d,128		;; 2a6e: 11 80 00    ...
	dad	d		;; 2a71: 19          .
	pop	d		;; 2a72: d1          .
	push	d		;; 2a73: d5          .
	push	h		;; 2a74: e5          .
	mvi	c,write		;; 2a75: 0e 15       ..
	call	bdos		;; 2a77: cd 05 00    ...
	pop	h		;; 2a7a: e1          .
	pop	d		;; 2a7b: d1          .
	pop	b		;; 2a7c: c1          .
	ora	a		;; 2a7d: b7          .
	jnz	L2a8c		;; 2a7e: c2 8c 2a    ..*
	dcr	b		;; 2a81: 05          .
	jnz	L2a60		;; 2a82: c2 60 2a    .`*
L2a85:	call	L2647		;; 2a85: cd 47 26    .G&
	ret			;; 2a88: c9          .

	jmp	L2a60		;; 2a89: c3 60 2a    .`*

L2a8c:	lxi	h,L2d53		;; 2a8c: 21 53 2d    .S-
	call	msgcr		;; 2a8f: cd 78 26    .x&
	jmp	L2cb6		;; 2a92: c3 b6 2c    ..,

hexput:	push	b		;; 2a95: c5          .
	push	d		;; 2a96: d5          .
	push	h		;; 2a97: e5          .
	call	hexpt		;; 2a98: cd 9f 2a    ..*
	pop	h		;; 2a9b: e1          .
	pop	d		;; 2a9c: d1          .
	pop	b		;; 2a9d: c1          .
L2a9e:	ret			;; 2a9e: c9          .

hexpt:	lhld	hexidx		;; 2a9f: 2a 3e 26    *>&
	xchg			;; 2aa2: eb          .
	lhld	L2640		;; 2aa3: 2a 40 26    *@&
	dad	d		;; 2aa6: 19          .
	mov	m,a		;; 2aa7: 77          w
	xchg			;; 2aa8: eb          .
	inx	h		;; 2aa9: 23          #
	shld	hexidx		;; 2aaa: 22 3e 26    ">&
	xchg			;; 2aad: eb          .
	lxi	h,768		;; 2aae: 21 00 03    ...
	call	compar		;; 2ab1: cd 46 29    .F)
	rnz			;; 2ab4: c0          .
	call	sethex		;; 2ab5: cd 6c 26    .l&
	lxi	h,0		;; 2ab8: 21 00 00    ...
	shld	hexidx		;; 2abb: 22 3e 26    ">&
	lhld	L2640		;; 2abe: 2a 40 26    *@&
	lxi	d,hexfcb	;; 2ac1: 11 1d 26    ..&
	mvi	b,6		;; 2ac4: 06 06       ..
	jmp	L2a60		;; 2ac6: c3 60 2a    .`*

; print char
chrout:	push	b		;; 2ac9: c5          .
	push	d		;; 2aca: d5          .
	push	h		;; 2acb: e5          .
	mvi	c,conout	;; 2acc: 0e 02       ..
	mov	e,a		;; 2ace: 5f          _
	call	bdos		;; 2acf: cd 05 00    ...
	pop	h		;; 2ad2: e1          .
	pop	d		;; 2ad3: d1          .
	pop	b		;; 2ad4: c1          .
	ret			;; 2ad5: c9          .

; increment a 3-digit ASCII numeric field
L2ad6:	lxi	h,L25b0+2	;; 2ad6: 21 b2 25    ..%
	mvi	c,3		;; 2ad9: 0e 03       ..
L2adb:	mov	a,m		;; 2adb: 7e          ~
	inr	a		;; 2adc: 3c          <
	mov	m,a		;; 2add: 77          w
	cpi	'9'+1		;; 2ade: fe 3a       .:
	jc	L2aea		;; 2ae0: da ea 2a    ..*
	mvi	m,'0'		;; 2ae3: 36 30       60
	dcx	h		;; 2ae5: 2b          +
	dcr	c		;; 2ae6: 0d          .
	jnz	L2adb		;; 2ae7: c2 db 2a    ..*
L2aea:	lxi	h,L25b0		;; 2aea: 21 b0 25    ..%
	mvi	c,3		;; 2aed: 0e 03       ..
L2aef:	mov	a,m		;; 2aef: 7e          ~
	call	prnput		;; 2af0: cd 0e 2a    ..*
	inx	h		;; 2af3: 23          #
	dcr	c		;; 2af4: 0d          .
	jnz	L2aef		;; 2af5: c2 ef 2a    ..*
	ret			;; 2af8: c9          .

L2af9:	lda	paglin		;; 2af9: 3a b3 25    :.%
	ora	a		;; 2afc: b7          .
	rz			;; 2afd: c8          .
	mvi	a,ff		;; 2afe: 3e 0c       >.
	call	prnput		;; 2b00: cd 0e 2a    ..*
	xra	a		;; 2b03: af          .
	sta	curlin		;; 2b04: 32 b4 25    2.%
	lhld	L3062		;; 2b07: 2a 62 30    *b0
	mov	a,l		;; 2b0a: 7d          }
	ora	h		;; 2b0b: b4          .
	rz			;; 2b0c: c8          .
	lxi	h,L2cd3		;; 2b0d: 21 d3 2c    ..,
L2b10:	mov	a,m		;; 2b10: 7e          ~
	cpi	cr		;; 2b11: fe 0d       ..
	jz	L2b1d		;; 2b13: ca 1d 2b    ..+
	call	prnput		;; 2b16: cd 0e 2a    ..*
	inx	h		;; 2b19: 23          #
	jmp	L2b10		;; 2b1a: c3 10 2b    ..+

; what is this? append " # ..."?
L2b1d:	mvi	a,tab		;; 2b1d: 3e 09       >.
	call	prnput		;; 2b1f: cd 0e 2a    ..*
	mvi	a,'#'		;; 2b22: 3e 23       >#
	call	prnput		;; 2b24: cd 0e 2a    ..*
	call	L2ad6		;; 2b27: cd d6 2a    ..*
	mvi	a,tab		;; 2b2a: 3e 09       >.
	call	prnput		;; 2b2c: cd 0e 2a    ..*
	lhld	L3062		;; 2b2f: 2a 62 30    *b0
L2b32:	mov	a,m		;; 2b32: 7e          ~
	ora	a		;; 2b33: b7          .
	jz	L2b3e		;; 2b34: ca 3e 2b    .>+
	call	prnput		;; 2b37: cd 0e 2a    ..*
	inx	h		;; 2b3a: 23          #
	jmp	L2b32		;; 2b3b: c3 32 2b    .2+

L2b3e:	mvi	a,cr		;; 2b3e: 3e 0d       >.
	call	prnput		;; 2b40: cd 0e 2a    ..*
	mvi	a,lf		;; 2b43: 3e 0a       >.
	call	prnput		;; 2b45: cd 0e 2a    ..*
	mvi	a,lf		;; 2b48: 3e 0a       >.
	jmp	prnput		;; 2b4a: c3 0e 2a    ..*

L2b4d:	mov	a,l		;; 2b4d: 7d          }
	sta	paglin		;; 2b4e: 32 b3 25    2.%
	lxi	h,curlin	;; 2b51: 21 b4 25    ..%
	sub	m		;; 2b54: 96          .
	rnc			;; 2b55: d0          .
	jmp	L2af9		;; 2b56: c3 f9 2a    ..*

L2b59:	mov	c,a		;; 2b59: 4f          O
	call	prnput		;; 2b5a: cd 0e 2a    ..*
	lda	curerr		;; 2b5d: 3a 8c 2f    :./
	cpi	' '		;; 2b60: fe 20       . 
	rz			;; 2b62: c8          .
	lda	pass		;; 2b63: 3a 4f 30    :O0
	cpi	002h		;; 2b66: fe 02       ..
	rz			;; 2b68: c8          .
	lda	prndst		;; 2b69: 3a cb 25    :.%
	cpi	DRVCON		;; 2b6c: fe 17       ..
	rz			;; 2b6e: c8          .
	mov	a,c		;; 2b6f: 79          y
	call	chrout		;; 2b70: cd c9 2a    ..*
	ret			;; 2b73: c9          .

L2b74:	lda	Fflag		;; 2b74: 3a b5 25    :.%
	lxi	h,pass		;; 2b77: 21 4f 30    .O0
	ora	m		;; 2b7a: b6          .
	jnz	L2b95		;; 2b7b: c2 95 2b    ..+
	lda	Lflag		;; 2b7e: 3a 65 30    :e0
	lxi	h,L305d		;; 2b81: 21 5d 30    .]0
	ana	m		;; 2b84: a6          .
	jnz	L2be3		;; 2b85: c2 e3 2b    ..+
	mov	a,m		;; 2b88: 7e          ~
	ora	a		;; 2b89: b7          .
	jz	L2c10		;; 2b8a: ca 10 2c    ..,
	lda	curerr		;; 2b8d: 3a 8c 2f    :./
	cpi	' '		;; 2b90: fe 20       . 
	jz	L2c10		;; 2b92: ca 10 2c    ..,
L2b95:	lxi	h,curerr	;; 2b95: 21 8c 2f    ../
	mov	a,m		;; 2b98: 7e          ~
	cpi	' '		;; 2b99: fe 20       . 
	jnz	L2be3		;; 2b9b: c2 e3 2b    ..+
	lda	L3066		;; 2b9e: 3a 66 30    :f0
	ora	a		;; 2ba1: b7          .
	jz	L2c10		;; 2ba2: ca 10 2c    ..,
	lda	prnbuf+5	;; 2ba5: 3a 91 2f    :./
	cpi	'+'		;; 2ba8: fe 2b       .+
	jnz	L2be3		;; 2baa: c2 e3 2b    ..+
	lda	Mflag		;; 2bad: 3a 5f 30    :_0
	ora	a		;; 2bb0: b7          .
	jz	L2c10		;; 2bb1: ca 10 2c    ..,
	cpi	003h		;; 2bb4: fe 03       ..
	jz	L2be3		;; 2bb6: ca e3 2b    ..+
	lda	prnbuf+6	;; 2bb9: 3a 92 2f    :./
	cpi	'#'		;; 2bbc: fe 23       .#
	jz	L2c10		;; 2bbe: ca 10 2c    ..,
	lda	prnbuf+1	;; 2bc1: 3a 8d 2f    :./
	cpi	' '		;; 2bc4: fe 20       . 
	jz	L2c10		;; 2bc6: ca 10 2c    ..,
	lda	Mflag		;; 2bc9: 3a 5f 30    :_0
	dcr	a		;; 2bcc: 3d          =
	jz	L2be3		;; 2bcd: ca e3 2b    ..+
	lxi	d,16		;; 2bd0: 11 10 00    ...
L2bd3:	dcx	d		;; 2bd3: 1b          .
	lxi	h,prnbuf	;; 2bd4: 21 8c 2f    ../
	dad	d		;; 2bd7: 19          .
	mov	a,m		;; 2bd8: 7e          ~
	cpi	' '		;; 2bd9: fe 20       . 
	jz	L2bd3		;; 2bdb: ca d3 2b    ..+
	inx	d		;; 2bde: 13          .
	lxi	h,L3004		;; 2bdf: 21 04 30    ..0
	mov	m,e		;; 2be2: 73          s
L2be3:	lxi	h,curlin	;; 2be3: 21 b4 25    ..%
	push	h		;; 2be6: e5          .
	mov	a,m		;; 2be7: 7e          ~
	lxi	h,paglin	;; 2be8: 21 b3 25    ..%
	sub	m		;; 2beb: 96          .
	cnc	L2af9		;; 2bec: d4 f9 2a    ..*
	pop	h		;; 2bef: e1          .
	inr	m		;; 2bf0: 34          4
	lda	L3004		;; 2bf1: 3a 04 30    :.0
	lxi	h,prnbuf	;; 2bf4: 21 8c 2f    ../
L2bf7:	ora	a		;; 2bf7: b7          .
	jz	L2c06		;; 2bf8: ca 06 2c    ..,
	mov	b,a		;; 2bfb: 47          G
	mov	a,m		;; 2bfc: 7e          ~
	call	L2b59		;; 2bfd: cd 59 2b    .Y+
	inx	h		;; 2c00: 23          #
	mov	a,b		;; 2c01: 78          x
	dcr	a		;; 2c02: 3d          =
	jmp	L2bf7		;; 2c03: c3 f7 2b    ..+

L2c06:	mvi	a,cr		;; 2c06: 3e 0d       >.
	call	L2b59		;; 2c08: cd 59 2b    .Y+
	mvi	a,lf		;; 2c0b: 3e 0a       >.
	call	L2b59		;; 2c0d: cd 59 2b    .Y+
L2c10:	xra	a		;; 2c10: af          .
	sta	L3004		;; 2c11: 32 04 30    2.0
	lxi	h,prnbuf	;; 2c14: 21 8c 2f    ../
	mvi	a,120		;; 2c17: 3e 78       >x
L2c19:	mvi	m,' '		;; 2c19: 36 20       6 
	inx	h		;; 2c1b: 23          #
	dcr	a		;; 2c1c: 3d          =
	jnz	L2c19		;; 2c1d: c2 19 2c    ..,
	ret			;; 2c20: c9          .

seterr:	mov	b,a		;; 2c21: 47          G
	lxi	h,curerr	;; 2c22: 21 8c 2f    ../
	mov	a,m		;; 2c25: 7e          ~
	cpi	' '		;; 2c26: fe 20       . 
	rnz			;; 2c28: c0          .
	mov	m,b		;; 2c29: 70          p
	ret			;; 2c2a: c9          .

L2c2b:	call	isfile		;; 2c2b: cd b3 27    ..'
	rz			;; 2c2e: c8          .
L2c2f:	lhld	prnidx		;; 2c2f: 2a 19 26    *.&
	mov	a,l		;; 2c32: 7d          }
	ora	h		;; 2c33: b4          .
	jz	L2c3f		;; 2c34: ca 3f 2c    .?,
	mvi	a,eof		;; 2c37: 3e 1a       >.
	call	prnput		;; 2c39: cd 0e 2a    ..*
	jmp	L2c2f		;; 2c3c: c3 2f 2c    ./,

L2c3f:	call	setprn		;; 2c3f: cd 60 26    .`&
	lxi	d,prnfcb	;; 2c42: 11 f8 25    ..%
	call	closef		;; 2c45: cd 88 27    ..'
	ret			;; 2c48: c9          .

; SYM file setup - uses same facilities as PRN
L2c49:	lda	Sflag		;; 2c49: 3a 5e 30    :^0
	cpi	003h		;; 2c4c: fe 03       ..
	jz	L2af9		;; 2c4e: ca f9 2a    ..*
	call	L2c2b		;; 2c51: cd 2b 2c    .+,
	lxi	h,prnfcb+9	;; 2c54: 21 01 26    ..&
	mvi	m,'S'		;; 2c57: 36 53       6S
	inx	h		;; 2c59: 23          #
	mvi	m,'Y'		;; 2c5a: 36 59       6Y
	inx	h		;; 2c5c: 23          #
	mvi	m,'M'		;; 2c5d: 36 4d       6M
	inx	h		;; 2c5f: 23          #
	xra	a		;; 2c60: af          .
	mov	m,a		;; 2c61: 77          w
	lxi	h,prnfcb+32	;; 2c62: 21 18 26    ..&
	mov	m,a		;; 2c65: 77          w
	; should be calling setsym?
	lda	symdst		;; 2c66: 3a cc 25    :.%
	sta	prndst		;; 2c69: 32 cb 25    2.%
	lxi	h,0		;; 2c6c: 21 00 00    ...
	shld	prnidx		;; 2c6f: 22 19 26    ".&
	call	isfile		;; 2c72: cd b3 27    ..'
	jz	L2af9		;; 2c75: ca f9 2a    ..*
	xra	a		;; 2c78: af          .
	sta	paglin		;; 2c79: 32 b3 25    2.%
	call	setprn		;; 2c7c: cd 60 26    .`&
	lxi	d,prnfcb	;; 2c7f: 11 f8 25    ..%
	push	d		;; 2c82: d5          .
	call	deletf		;; 2c83: cd 9b 27    ..'
	pop	d		;; 2c86: d1          .
	call	makef		;; 2c87: cd a0 27    ..'
	ret			;; 2c8a: c9          .

; ensure HEX file ends properly...
; then add END FILE tage.
hexpt2:	call	L2c2b		;; 2c8b: cd 2b 2c    .+,
	lda	hexdst		;; 2c8e: 3a cd 25    :.%
	cpi	DRVNUL		;; 2c91: fe 19       ..
	jz	L2cb6		;; 2c93: ca b6 2c    ..,
	lda	hexlen		;; 2c96: 3a b8 25    :.%
	ora	a		;; 2c99: b7          .
	cnz	hexlin		;; 2c9a: c4 0f 2e    ...
	lhld	curadr		;; 2c9d: 2a 50 30    *P0
	shld	hexadr		;; 2ca0: 22 b6 25    ".%
	call	hexlin		;; 2ca3: cd 0f 2e    ...
L2ca6:	lhld	hexidx		;; 2ca6: 2a 3e 26    *>&
	mov	a,l		;; 2ca9: 7d          }
	ora	h		;; 2caa: b4          .
	jz	L2cb6		;; 2cab: ca b6 2c    ..,
	mvi	a,eof		;; 2cae: 3e 1a       >.
	call	hexput		;; 2cb0: cd 95 2a    ..*
	jmp	L2ca6		;; 2cb3: c3 a6 2c    ..,

L2cb6:	nop	; patch?	;; 2cb6: 00          .
	nop			;; 2cb7: 00          .
	nop			;; 2cb8: 00          .
	lda	hexdst		;; 2cb9: 3a cd 25    :.%
	cpi	DRVNUL		;; 2cbc: fe 19       ..
	jz	L2cca		;; 2cbe: ca ca 2c    ..,
	call	sethex		;; 2cc1: cd 6c 26    .l&
	lxi	d,hexfcb	;; 2cc4: 11 1d 26    ..&
	call	closef		;; 2cc7: cd 88 27    ..'
; end of assembly...
L2cca:	lxi	h,endmsg	;; 2cca: 21 93 2d    ..-
	call	msgcr		;; 2ccd: cd 78 26    .x&
	jmp	cpm		;; 2cd0: c3 00 00    ...

L2cd3:	db	'CP/M MACRO ASSEM 2.0',0dh
L2ce8:	db	'NO SOURCE FILE PRESENT',0dh
L2cff:	db	'NO DIRECTORY SPACE',0dh
L2d12:	db	'SOURCE FILE NAME ERROR',0dh
L2d29:	db	'INVALID PARAMETER:',0dh
L2d3c:	db	'SOURCE FILE READ ERROR',0dh
L2d53:	db	'OUTPUT FILE WRITE ERROR',0dh
L2d6b:	db	'CANNOT CLOSE FILES',0dh
L2d7e:	db	'UNBALANCED MACRO LIB',0dh
endmsg:	db	'END OF ASSEMBLY',0dh

hexpt0:	push	b		;; 2da3: c5          .
	mov	b,a		;; 2da4: 47          G
	lda	hexdst		;; 2da5: 3a cd 25    :.%
	cpi	DRVNUL		;; 2da8: fe 19       ..
	mov	a,b		;; 2daa: 78          x
	jz	L2def		;; 2dab: ca ef 2d    ..-
	push	d		;; 2dae: d5          .
	push	psw		;; 2daf: f5          .
	lxi	h,hexlen	;; 2db0: 21 b8 25    ..%
	mov	a,m		;; 2db3: 7e          ~
	ora	a		;; 2db4: b7          .
	jz	L2ddb		;; 2db5: ca db 2d    ..-
	cpi	16		;; 2db8: fe 10       ..
	jc	hexpt1		;; 2dba: da c3 2d    ..-
	call	hexlin		;; 2dbd: cd 0f 2e    ...
	jmp	L2ddb		;; 2dc0: c3 db 2d    ..-

hexpt1:	lhld	curadr		;; 2dc3: 2a 50 30    *P0
	xchg			;; 2dc6: eb          .
	lhld	hexadr		;; 2dc7: 2a b6 25    *.%
	mov	c,a		;; 2dca: 4f          O
	mvi	b,0		;; 2dcb: 06 00       ..
	dad	b		;; 2dcd: 09          .
	mov	a,e		;; 2dce: 7b          {
	cmp	l		;; 2dcf: bd          .
	jnz	L2dd8		;; 2dd0: c2 d8 2d    ..-
	mov	a,d		;; 2dd3: 7a          z
	cmp	h		;; 2dd4: bc          .
	jz	L2de1		;; 2dd5: ca e1 2d    ..-
L2dd8:	call	hexlin		;; 2dd8: cd 0f 2e    ...
L2ddb:	lhld	curadr		;; 2ddb: 2a 50 30    *P0
	shld	hexadr		;; 2dde: 22 b6 25    ".%
L2de1:	lxi	h,hexlen	;; 2de1: 21 b8 25    ..%
	mov	e,m		;; 2de4: 5e          ^
	inr	m		;; 2de5: 34          4
	mvi	d,0		;; 2de6: 16 00       ..
	lxi	h,L25b9		;; 2de8: 21 b9 25    ..%
	dad	d		;; 2deb: 19          .
	pop	psw		;; 2dec: f1          .
	mov	m,a		;; 2ded: 77          w
	pop	d		;; 2dee: d1          .
L2def:	pop	b		;; 2def: c1          .
	ret			;; 2df0: c9          .

; send byte to HEX file, checksum in D
hexbyt:	push	psw		;; 2df1: f5          .
	rrc			;; 2df2: 0f          .
	rrc			;; 2df3: 0f          .
	rrc			;; 2df4: 0f          .
	rrc			;; 2df5: 0f          .
	ani	00fh		;; 2df6: e6 0f       ..
	call	L2e06		;; 2df8: cd 06 2e    ...
	pop	psw		;; 2dfb: f1          .
	push	psw		;; 2dfc: f5          .
	ani	00fh		;; 2dfd: e6 0f       ..
	call	L2e06		;; 2dff: cd 06 2e    ...
	pop	psw		;; 2e02: f1          .
	add	d		;; 2e03: 82          .
	mov	d,a		;; 2e04: 57          W
	ret			;; 2e05: c9          .

L2e06:	adi	090h		;; 2e06: c6 90       ..
	daa			;; 2e08: 27          '
	aci	040h		;; 2e09: ce 40       .@
	daa			;; 2e0b: 27          '
	jmp	hexput		;; 2e0c: c3 95 2a    ..*

; output one line of HEX file.
; (hexlen)=num bytes, (hexadr)=address
; uses D for checksum
hexlin:	mvi	a,':'		;; 2e0f: 3e 3a       >:
	call	hexput		;; 2e11: cd 95 2a    ..*
	lxi	h,hexlen	;; 2e14: 21 b8 25    ..%
	mov	e,m		;; 2e17: 5e          ^
	xra	a		;; 2e18: af          .
	mov	d,a		;; 2e19: 57          W
	mov	m,a		;; 2e1a: 77          w
	lhld	hexadr		;; 2e1b: 2a b6 25    *.%
	mov	a,e		;; 2e1e: 7b          {
	call	hexbyt		;; 2e1f: cd f1 2d    ..-
	mov	a,h		;; 2e22: 7c          |
	call	hexbyt		;; 2e23: cd f1 2d    ..-
	mov	a,l		;; 2e26: 7d          }
	call	hexbyt		;; 2e27: cd f1 2d    ..-
	xra	a		;; 2e2a: af          .
	call	hexbyt		;; 2e2b: cd f1 2d    ..-
	mov	a,e		;; 2e2e: 7b          {
	ora	a		;; 2e2f: b7          .
	jz	L2e3f		;; 2e30: ca 3f 2e    .?.
	lxi	h,L25b9		;; 2e33: 21 b9 25    ..%
L2e36:	mov	a,m		;; 2e36: 7e          ~
	inx	h		;; 2e37: 23          #
	call	hexbyt		;; 2e38: cd f1 2d    ..-
	dcr	e		;; 2e3b: 1d          .
	jnz	L2e36		;; 2e3c: c2 36 2e    .6.
L2e3f:	xra	a		;; 2e3f: af          .
	sub	d		;; 2e40: 92          .
	call	hexbyt		;; 2e41: cd f1 2d    ..-
	mvi	a,cr		;; 2e44: 3e 0d       >.
	call	hexput		;; 2e46: cd 95 2a    ..*
	mvi	a,lf		;; 2e49: 3e 0a       >.
	call	hexput		;; 2e4b: cd 95 2a    ..*
	ret			;; 2e4e: c9          .

	call	L2a9e		;; 2e4f: cd 9e 2a    ..*
	mvi	a,lf		;; 2e52: 3e 0a       >.
	call	L2a9e		;; 2e54: cd 9e 2a    ..*
	ret			;; 2e57: c9          .

	db	0f7h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0efh,0ffh,0ffh,0ffh,0ffh
	db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
L2e83:	db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,'w',0f7h,0ffh,0ffh
	db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
L2ea3:	db	0ffh
L2ea4:	db	0ffh
L2ea5:	db	0ffh
L2ea6:	db	0ffh
L2ea7:	db	0ffh
curhsh:	db	0ffh,0ffh	; current hash pointer (symbol being looked up)
L2eaa:	db	0ffh,0ffh
; hash table for symbols?
symtab:	db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
L2eb4:	db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
L2ed4:	db	0ffh,0ffh,0ffh,'s',0f7h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
L2ef4:	db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	ds	20
L2f14:	ds	16
L2f24:	ds	32
L2f44:	ds	16
L2f54:	ds	16
L2f64:	ds	1
L2f65:	ds	1
L2f66:	ds	1
L2f67:	ds	37

; staging buffer for PRN line
prnbuf:
curerr:	ds	1	; error code
	ds	119

L3004:	ds	1
L3005:	ds	1
L3006:	ds	2

tokbuf:	ds	1	; current token/opcode (len, chrs...)
	ds	64

L3049:	ds	2
nxheap:	ds	2
memtop:	ds	2	; end of TPA
pass:	ds	1	; assembler pass number (0/1)
curadr:	ds	2	; prog addr where current byte is (to go)
linadr:	ds	2	; prog addr where current ASM line started

syheap:	ds	2	; point to free mem for symbols
cursym:	ds	2	; current symbol being examined
L3058:	ds	2
L305a:	ds	1
L305b:	ds	1
L305c:	ds	1
L305d:	ds	1
Sflag:	ds	1	; $[+-]S flag
Mflag:	ds	1	; $[+-*]M flag
L3060:	ds	2
L3062:	ds	2
Qflag:	ds	1	; $[+-]Q flag
Lflag:	ds	1	; $[+-]L flag
L3066:	ds	1
Rflag:	ds	1	; $[+-]R flag = "reloc" ORG 0 instead of 0100h

	ds	152
stack:	ds	0
buffer:	; the rest of memory...

	end
