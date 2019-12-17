; MAC.COM - main module

	maclib	m1200
	maclib	m1600
	maclib	m1c00
	maclib	m2100
	maclib	m2580
	maclib	macg

	; for patch
	public	L11e2

	;org	00100h
	cseg
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
	lda	L3009		;; 0186: 3a 09 30    :.0
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
	cpi	006h		;; 01ef: fe 06       ..
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
	cpi	006h		;; 024e: fe 06       ..
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

L0272:	lhld	L304b		;; 0272: 2a 4b 30    *K0
	push	h		;; 0275: e5          .
	shld	L3058		;; 0276: 22 58 30    "X0
	lxi	h,L3008		;; 0279: 21 08 30    ..0
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
	shld	L304b		;; 028d: 22 4b 30    "K0
	ret			;; 0290: c9          .

L0291:	lhld	L304b		;; 0291: 2a 4b 30    *K0
	mov	c,m		;; 0294: 4e          N
	shld	L3058		;; 0295: 22 58 30    "X0
	lxi	h,L3008		;; 0298: 21 08 30    ..0
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
	lda	L3009		;; 0308: 3a 09 30    :.0
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
	lda	L3009		;; 0329: 3a 09 30    :.0
	push	psw		;; 032c: f5          .
	xra	a		;; 032d: af          .
	sta	L3008		;; 032e: 32 08 30    2.0
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
	lda	L3009		;; 0354: 3a 09 30    :.0
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
	sta	L3008		;; 03d8: 32 08 30    2.0
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
	lda	L3009		;; 0402: 3a 09 30    :.0
	cpi	':'		;; 0405: fe 3a       .:
	jnz	L0179		;; 0407: c2 79 01    .y.
	jmp	L0176		;; 040a: c3 76 01    .v.

L040d:	cpi	01ah		;; 040d: fe 1a       ..
	jnz	L0c21		;; 040f: c2 21 0c    ...
	; pseudo-ops... B is index
	mov	e,b		;; 0412: 58          X
	mvi	d,000h		;; 0413: 16 00       ..
	dcx	d		;; 0415: 1b          .
	lxi	h,L0420		;; 0416: 21 20 04    . .
	dad	d		;; 0419: 19          .
	dad	d		;; 041a: 19          .
	mov	e,m		;; 041b: 5e          ^
	inx	h		;; 041c: 23          #
	mov	h,m		;; 041d: 66          f
	mov	l,e		;; 041e: 6b          k
	pchl			;; 041f: e9          .

; pseudo-op table
L0420:	dw	pDB	; 1 DB
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
	lda	L3008		;; 0466: 3a 08 30    :.0
	dcr	a		;; 0469: 3d          =
	jz	L0489		;; 046a: ca 89 04    ...
	mov	b,a		;; 046d: 47          G
	inr	b		;; 046e: 04          .
	inr	b		;; 046f: 04          .
	lxi	h,L3009		;; 0470: 21 09 30    ..0
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
	call	L0d7c		;; 048f: cd 7c 0d    .|.
	mov	b,l		;; 0492: 45          E
	call	asmbyt		;; 0493: cd 32 0f    .2.
L0496:	call	L0ee3		;; 0496: cd e3 0e    ...
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
	call	L0ee3		;; 04cb: cd e3 0e    ...
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
	lda	L3009		;; 050c: 3a 09 30    :.0
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
	cpi	006h		;; 054d: fe 06       ..
	jnz	L0616		;; 054f: c2 16 06    ...
L0552:	lda	L2ea4		;; 0552: 3a a4 2e    :..
	cpi	006h		;; 0555: fe 06       ..
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
	lxi	h,L3008		;; 0589: 21 08 30    ..0
	mvi	m,001h		;; 058c: 36 01       6.
	inx	h		;; 058e: 23          #
	mov	m,a		;; 058f: 77          w
	jmp	L059a		;; 0590: c3 9a 05    ...

L0593:	mvi	a,cr		;; 0593: 3e 0d       >.
	stax	d		;; 0595: 12          .
	xra	a		;; 0596: af          .
	sta	L3008		;; 0597: 32 08 30    2.0
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
	sui	02ch		;; 05b3: d6 2c       .,
	jnz	L05c5		;; 05b5: c2 c5 05    ...
	inx	h		;; 05b8: 23          #
	push	h		;; 05b9: e5          .
	lxi	h,L3008		;; 05ba: 21 08 30    ..0
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
	lda	L3009		;; 05e7: 3a 09 30    :.0
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

L06c8:	mvi	a,006h		;; 06c8: 3e 06       >.
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
	lda	L3009		;; 06f9: 3a 09 30    :.0
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
	lda	L3009		;; 072d: 3a 09 30    :.0
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
L0757:	shld	L11e0		;; 0757: 22 e0 11    "..
	call	L1606		;; 075a: cd 06 16    ...
	lda	L3005		;; 075d: 3a 05 30    :.0
	cpi	004h		;; 0760: fe 04       ..
	jnz	L076b		;; 0762: c2 6b 07    .k.
	lda	L3009		;; 0765: 3a 09 30    :.0
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
	lda	L3008		;; 0786: 3a 08 30    :.0
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

L07bb:	cpi	006h		;; 07bb: fe 06       ..
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
	lxi	h,L3008		;; 0873: 21 08 30    ..0
	mov	c,m		;; 0876: 4e          N
	xchg			;; 0877: eb          .
	lhld	L304b		;; 0878: 2a 4b 30    *K0
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
	lda	L3009		;; 08d3: 3a 09 30    :.0
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
	lda	L3009		;; 091b: 3a 09 30    :.0
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

L098d:	cpi	006h		;; 098d: fe 06       ..
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
	mvi	d,000h		;; 09aa: 16 00       ..
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
	mvi	d,000h		;; 09bc: 16 00       ..
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
	lhld	L304b		;; 09dc: 2a 4b 30    *K0
	shld	L11c5		;; 09df: 22 c5 11    "..
	dcx	h		;; 09e2: 2b          +
	shld	L3058		;; 09e3: 22 58 30    "X0
	lda	L3008		;; 09e6: 3a 08 30    :.0
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
	lda	L3009		;; 0a07: 3a 09 30    :.0
	cpi	','		;; 0a0a: fe 2c       .,
	jnz	L0a4e		;; 0a0c: c2 4e 0a    .N.
	call	L160c		;; 0a0f: cd 0c 16    ...
	lda	L3008		;; 0a12: 3a 08 30    :.0
	ora	a		;; 0a15: b7          .
	jnz	L0a1f		;; 0a16: c2 1f 0a    ...
	call	L1606		;; 0a19: cd 06 16    ...
	jmp	L0a3e		;; 0a1c: c3 3e 0a    .>.

L0a1f:	call	L0c0f		;; 0a1f: cd 0f 0c    ...
	jz	L0a3e		;; 0a22: ca 3e 0a    .>.
	lxi	h,L3008		;; 0a25: 21 08 30    ..0
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
	lhld	L304b		;; 0a42: 2a 4b 30    *K0
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
	lhld	L304b		;; 0a5f: 2a 4b 30    *K0
	shld	L11c5		;; 0a62: 22 c5 11    "..
	dcx	h		;; 0a65: 2b          +
	shld	L3058		;; 0a66: 22 58 30    "X0
	call	L1c27		;; 0a69: cd 27 1c    .'.
	pop	psw		;; 0a6c: f1          .
	call	L1c27		;; 0a6d: cd 27 1c    .'.
	lhld	L304b		;; 0a70: 2a 4b 30    *K0
	shld	cursym		;; 0a73: 22 56 30    "V0
	mvi	a,006h		;; 0a76: 3e 06       >.
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
	shld	L304b		;; 0ac0: 22 4b 30    "K0
	lhld	memtop		;; 0ac3: 2a 4d 30    *M0
	shld	L2eb4		;; 0ac6: 22 b4 2e    "..
	nop			;; 0ac9: 00          .
	lda	L305c		;; 0aca: 3a 5c 30    :\0
	cpi	006h		;; 0acd: fe 06       ..
	jz	L0add		;; 0acf: ca dd 0a    ...
	mov	c,m		;; 0ad2: 4e          N
	mvi	b,000h		;; 0ad3: 06 00       ..
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
	lhld	L304b		;; 0b4a: 2a 4b 30    *K0
	push	h		;; 0b4d: e5          .
	dcx	h		;; 0b4e: 2b          +
	shld	L3058		;; 0b4f: 22 58 30    "X0
	call	L1c21		;; 0b52: cd 21 1c    ...
	xra	a		;; 0b55: af          .
	sta	L11db		;; 0b56: 32 db 11    2..
	inr	a		;; 0b59: 3c          <
	sta	L3008		;; 0b5a: 32 08 30    2.0
	lhld	L11de		;; 0b5d: 2a de 11    *..
	inx	h		;; 0b60: 23          #
	shld	L11de		;; 0b61: 22 de 11    "..
	shld	L11dc		;; 0b64: 22 dc 11    "..
	call	L0d0e		;; 0b67: cd 0e 0d    ...
	lda	L300a		;; 0b6a: 3a 0a 30    :.0
	cpi	'0'		;; 0b6d: fe 30       .0
	cnz	Oerror		;; 0b6f: c4 a8 11    ...
	lxi	h,'??'		;; 0b72: 21 3f 3f    .??
	shld	L3009		;; 0b75: 22 09 30    ".0
	call	L1c39		;; 0b78: cd 39 1c    .9.
	pop	h		;; 0b7b: e1          .
	shld	L304b		;; 0b7c: 22 4b 30    "K0
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
	lda	L3009		;; 0b9a: 3a 09 30    :.0
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
	lda	L3009		;; 0be4: 3a 09 30    :.0
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
	lda	L3009		;; 0c15: 3a 09 30    :.0
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
	mvi	d,000h		;; 0c29: 16 00       ..
	lxi	h,L0c35		;; 0c2b: 21 35 0c    .5.
	dad	d		;; 0c2e: 19          .
	dad	d		;; 0c2f: 19          .
	mov	e,m		;; 0c30: 5e          ^
	inx	h		;; 0c31: 23          #
	mov	h,m		;; 0c32: 66          f
	mov	l,e		;; 0c33: 6b          k
	pchl			;; 0c34: e9          .

L0c35:	dw	opnone	; 1ch - no operand
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
	call	L0db5		;; 0c62: cd b5 0d    ...
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
	call	L0db5		;; 0c85: cd b5 0d    ...
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
	call	L0f31		;; 0c9e: cd 31 0f    .1.
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
	call	L0db5		;; 0cc5: cd b5 0d    ...
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

L0cf8:	call	L0f31		;; 0cf8: cd 31 0f    .1.
L0cfb:	call	L0ef4		;; 0cfb: cd f4 0e    ...
	call	L0ee3		;; 0cfe: cd e3 0e    ...
	jmp	L0dd5		;; 0d01: c3 d5 0d    ...

L0d04:	dw	10000
	dw	1000
	dw	100
	dw	10
	dw	1

; convert (L11dc) to decimal (ASCII) in buffer L3008.
; suppress leading zeros.
L0d0e:	mvi	b,005h		;; 0d0e: 06 05       ..
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
L0d44:	lxi	h,L3008		;; 0d44: 21 08 30    ..0
	mov	e,m		;; 0d47: 5e          ^
	inr	m		;; 0d48: 34          4
	mvi	d,0		;; 0d49: 16 00       ..
	lxi	h,L3009		;; 0d4b: 21 09 30    ..0
	dad	d		;; 0d4e: 19          .
	mov	m,c		;; 0d4f: 71          q
L0d50:	pop	h		;; 0d50: e1          .
	dcr	b		;; 0d51: 05          .
	jnz	L0d13		;; 0d52: c2 13 0d    ...
	ret			;; 0d55: c9          .

L0d56:	lda	L3005		;; 0d56: 3a 05 30    :.0
	cpi	004h		;; 0d59: fe 04       ..
	cnz	Derror		;; 0d5b: c4 96 11    ...
	lda	L3009		;; 0d5e: 3a 09 30    :.0
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

L0d79:	call	L0d6d		;; 0d79: cd 6d 0d    .m.
L0d7c:	mov	a,h		;; 0d7c: 7c          |
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

L0d8b:	call	L0d79		;; 0d8b: cd 79 0d    .y.
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
	jmp	L0f31		;; 0dac: c3 31 0f    .1.

L0daf:	call	L0d79		;; 0daf: cd 79 0d    .y.
	jmp	L0f31		;; 0db2: c3 31 0f    .1.

L0db5:	call	L0d6d		;; 0db5: cd 6d 0d    .m.
	jmp	asmadr		;; 0db8: c3 58 0f    .X.

L0dbb:	push	psw		;; 0dbb: f5          .
	push	b		;; 0dbc: c5          .
	lda	L3005		;; 0dbd: 3a 05 30    :.0
	cpi	004h		;; 0dc0: fe 04       ..
	jnz	L0dcd		;; 0dc2: c2 cd 0d    ...
	lda	L3009		;; 0dc5: 3a 09 30    :.0
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
	lda	L3009		;; 0de0: 3a 09 30    :.0
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
	lda	L3009		;; 0e01: 3a 09 30    :.0
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
	mvi	a,001h		;; 0e84: 3e 01       >.
	sta	L2ea4		;; 0e86: 32 a4 2e    2..
	call	L25a1		;; 0e89: cd a1 25    ..%
	call	L0fb1		;; 0e8c: cd b1 0f    ...
L0e8f:	lhld	L304b		;; 0e8f: 2a 4b 30    *K0
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

L0ee3:	lhld	curadr		;; 0ee3: 2a 50 30    *P0
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
L0f31:	mov	b,a		;; 0f31: 47          G
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
	cpi	'0'+10		;; 0f64: fe 3a       .:
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
	lhld	L304b		;; 0fce: 2a 4b 30    *K0
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
	cpi	006h		;; 0fe8: fe 06       ..
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
	lda	L3008		;; 1026: 3a 08 30    :.0
	cpi	002h		;; 1029: fe 02       ..
	jc	L103c		;; 102b: da 3c 10    .<.
	lxi	h,L3009		;; 102e: 21 09 30    ..0
	mov	a,m		;; 1031: 7e          ~
	cpi	'?'		;; 1032: fe 3f       .?
	jnz	L103c		;; 1034: c2 3c 10    .<.
	inx	h		;; 1037: 23          #
	cmp	m		;; 1038: be          .
	jz	L1090		;; 1039: ca 90 10    ...
; lookup symbol/string?
L103c:	lda	L3009		;; 103c: 3a 09 30    :.0
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
	lxi	d,L3008		;; 105f: 11 08 30    ..0
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
	mvi	a,009h		;; 10de: 3e 09       >.
	call	L1175		;; 10e0: cd 75 11    .u.
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
	mvi	a,009h		;; 10f5: 3e 09       >.
	call	L1175		;; 10f7: cd 75 11    .u.
L10fa:	lda	L2ea5		;; 10fa: 3a a5 2e    :..
	add	b		;; 10fd: 80          .
	adi	005h		;; 10fe: c6 05       ..
	cpi	'P'		;; 1100: fe 50       .P
	jc	L1127		;; 1102: da 27 11    .'.
L1105:	lxi	h,prncol		;; 1105: 21 c9 11    ...
	dcr	m		;; 1108: 35          5
	mov	e,m		;; 1109: 5e          ^
	mvi	d,000h		;; 110a: 16 00       ..
	dcx	d		;; 110c: 1b          .
	lxi	h,prnbuf		;; 110d: 21 8c 2f    ../
	dad	d		;; 1110: 19          .
	mov	a,m		;; 1111: 7e          ~
	cpi	009h		;; 1112: fe 09       ..
	jz	L1105		;; 1114: ca 05 11    ...
	lxi	h,prncol		;; 1117: 21 c9 11    ...
	mov	a,m		;; 111a: 7e          ~
	mvi	m,000h		;; 111b: 36 00       6.
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
	call	L1175		;; 1136: cd 75 11    .u.
	lxi	h,L2ea5		;; 1139: 21 a5 2e    ...
	mov	a,m		;; 113c: 7e          ~
	adi	005h		;; 113d: c6 05       ..
	mov	m,a		;; 113f: 77          w
	lda	L2ea6		;; 1140: 3a a6 2e    :..
L1143:	ora	a		;; 1143: b7          .
	jz	L1157		;; 1144: ca 57 11    .W.
	dcr	a		;; 1147: 3d          =
	push	psw		;; 1148: f5          .
	call	L1c2a		;; 1149: cd 2a 1c    .*.
	call	L1175		;; 114c: cd 75 11    .u.
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

L1175:	lxi	h,prncol		;; 1175: 21 c9 11    ...
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

	db	0,0,0afh,0,0,0,14h,13h ; serial number?
	end
