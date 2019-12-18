; Disassembly of XREF.COM
; Original may have been PL/M or PL/I

cpm	equ	0
bdos	equ	5
deffcb	equ	005ch
defdma	equ	0080h
cmdlin	equ	0080h

cr	equ	13
lf	equ	10
eof	equ	26

conin	equ	1
conout	equ	2
auxin	equ	3
auxout	equ	4
lstout	equ	5
const	equ	11
print	equ	9
version	equ	12
open	equ	15
close	equ	16
delete	equ	19
read	equ	20
write	equ	21
make	equ	22
rename	equ	23
setdma	equ	26

	org	00100h
L0100:	lxi	b,512		;; 0100: 01 00 02    ...
	call	L2169		;; 0103: cd 69 21    .i.
	call	L1576		;; 0106: cd 76 15    .v.
	shld	L2fd8		;; 0109: 22 d8 2f    "./
	lxi	h,L2f51		;; 010c: 21 51 2f    .Q/
	lxi	d,L2bf2		;; 010f: 11 f2 2b    ..+
	mvi	a,080h		;; 0112: 3e 80       >.
	mvi	b,001h		;; 0114: 06 01       ..
	call	L1a63		;; 0116: cd 63 1a    .c.
	lxi	h,L2d4b		;; 0119: 21 4b 2d    .K-
	mvi	m,000h		;; 011c: 36 00       6.
	lhld	L2fd8		;; 011e: 2a d8 2f    *./
	mvi	e,002h		;; 0121: 1e 02       ..
	mov	c,e		;; 0123: 4b          K
	mvi	a,010h		;; 0124: 3e 10       >.
	call	L1958		;; 0126: cd 58 19    .X.
	xchg			;; 0129: eb          .
	mov	b,a		;; 012a: 47          G
	lxi	h,L2bf3		;; 012b: 21 f3 2b    ..+
	mvi	a,002h		;; 012e: 3e 02       >.
	call	L1979		;; 0130: cd 79 19    .y.
	jnz	L0143		;; 0133: c2 43 01    .C.
	lxi	h,L2f51		;; 0136: 21 51 2f    .Q/
	lxi	d,L2bf5		;; 0139: 11 f5 2b    ..+
	mvi	a,080h		;; 013c: 3e 80       >.
	mvi	b,001h		;; 013e: 06 01       ..
	call	L1a63		;; 0140: cd 63 1a    .c.
L0143:	lxi	h,L2bf5		;; 0143: 21 f5 2b    ..+
	lxi	d,L2f51		;; 0146: 11 51 2f    .Q/
	mvi	a,001h		;; 0149: 3e 01       >.
	call	L1972		;; 014b: cd 72 19    .r.
	jnz	L0196		;; 014e: c2 96 01    ...
	call	L15f4		;; 0151: cd f4 15    ...
	push	h		;; 0154: e5          .
	lxi	h,0ff00h	;; 0155: 21 00 ff    ...
	pop	d		;; 0158: d1          .
	mov	a,l		;; 0159: 7d          }
	ana	e		;; 015a: a3          .
	mov	l,a		;; 015b: 6f          o
	mov	a,h		;; 015c: 7c          |
	ana	d		;; 015d: a2          .
	mov	h,a		;; 015e: 67          g
	mov	a,l		;; 015f: 7d          }
	ora	h		;; 0160: b4          .
	jz	L0196		;; 0161: ca 96 01    ...
	lxi	h,L23bb		;; 0164: 21 bb 23    ..#
	shld	L2fd8		;; 0167: 22 d8 2f    "./
	lxi	h,L2fe8		;; 016a: 21 e8 2f    ../
	call	L16e8		;; 016d: cd e8 16    ...
	sui	000h		;; 0170: d6 00       ..
	jnz	L0196		;; 0172: c2 96 01    ...
	lxi	h,L2fea		;; 0175: 21 ea 2f    ../
	call	L16f8		;; 0178: cd f8 16    ...
	sui	000h		;; 017b: d6 00       ..
	jz	L0196		;; 017d: ca 96 01    ...
	lxi	h,L2fee		;; 0180: 21 ee 2f    ../
	lxi	d,L2bf6		;; 0183: 11 f6 2b    ..+
	mvi	a,080h		;; 0186: 3e 80       >.
	mvi	b,00eh		;; 0188: 06 0e       ..
	call	L1a63		;; 018a: cd 63 1a    .c.
	lxi	h,L2fec		;; 018d: 21 ec 2f    ../
	call	L14b7		;; 0190: cd b7 14    ...
	call	L157e		;; 0193: cd 7e 15    .~.
L0196:	call	L1567		;; 0196: cd 67 15    .g.
	shld	L2c42		;; 0199: 22 42 2c    "B,
	call	L1555		;; 019c: cd 55 15    .U.
	shld	L2d47		;; 019f: 22 47 2d    "G-
	lxi	h,L2cc5		;; 01a2: 21 c5 2c    ..,
	lxi	d,L2c04		;; 01a5: 11 04 2c    ..,
	mvi	a,080h		;; 01a8: 3e 80       >.
	mvi	b,00ah		;; 01aa: 06 0a       ..
	call	L1a63		;; 01ac: cd 63 1a    .c.
	lxi	h,L306f		;; 01af: 21 6f 30    .o0
	call	L14b7		;; 01b2: cd b7 14    ...
	call	L15ea		;; 01b5: cd ea 15    ...
	ora	a		;; 01b8: b7          .
	jp	L01bf		;; 01b9: f2 bf 01    ...
	call	L0558		;; 01bc: cd 58 05    .X.
L01bf:	call	L03f4		;; 01bf: cd f4 03    ...
	lda	L2d46		;; 01c2: 3a 46 2d    :F-
	ora	a		;; 01c5: b7          .
	jp	L01df		;; 01c6: f2 df 01    ...
	lxi	h,L2cc5		;; 01c9: 21 c5 2c    ..,
	lxi	d,L2c0e		;; 01cc: 11 0e 2c    ..,
	mvi	a,080h		;; 01cf: 3e 80       >.
	mvi	b,00dh		;; 01d1: 06 0d       ..
	call	L1a63		;; 01d3: cd 63 1a    .c.
	lxi	h,L3071		;; 01d6: 21 71 30    .q0
	call	L14b7		;; 01d9: cd b7 14    ...
	call	L157e		;; 01dc: cd 7e 15    .~.
L01df:	lhld	L2d47		;; 01df: 2a 47 2d    *G-
	xra	a		;; 01e2: af          .
	mov	m,a		;; 01e3: 77          w
	inx	h		;; 01e4: 23          #
	mov	m,a		;; 01e5: 77          w
L01e6:	lda	L2d46		;; 01e6: 3a 46 2d    :F-
	ora	a		;; 01e9: b7          .
	jm	L0203		;; 01ea: fa 03 02    ...
	call	L15ea		;; 01ed: cd ea 15    ...
	ora	a		;; 01f0: b7          .
	jp	L01f7		;; 01f1: f2 f7 01    ...
	call	L0558		;; 01f4: cd 58 05    .X.
L01f7:	lxi	h,L3073		;; 01f7: 21 73 30    .s0
	call	L05a1		;; 01fa: cd a1 05    ...
	call	L03f4		;; 01fd: cd f4 03    ...
	jmp	L01e6		;; 0200: c3 e6 01    ...

L0203:	lxi	h,L2d46		;; 0203: 21 46 2d    .F-
	mvi	m,0		;; 0206: 36 00       6.
	lhld	L2d47		;; 0208: 2a 47 2d    *G-
	lxi	d,-6		;; 020b: 11 fa ff    ...
	dad	d		;; 020e: 19          .
	push	h		;; 020f: e5          .
	lhld	L2d47		;; 0210: 2a 47 2d    *G-
	mov	e,m		;; 0213: 5e          ^
	inx	h		;; 0214: 23          #
	mov	d,m		;; 0215: 56          V
	xchg			;; 0216: eb          .
	inx	h		;; 0217: 23          #
	dad	h		;; 0218: 29          )
	dad	h		;; 0219: 29          )
	dad	h		;; 021a: 29          )
	pop	d		;; 021b: d1          .
	dad	d		;; 021c: 19          .
	shld	L2d49		;; 021d: 22 49 2d    "I-
	lhld	L2c42		;; 0220: 2a 42 2c    *B,
	push	h		;; 0223: e5          .
	lhld	L2d47		;; 0224: 2a 47 2d    *G-
	mov	e,m		;; 0227: 5e          ^
	inx	h		;; 0228: 23          #
	mov	d,m		;; 0229: 56          V
	xchg			;; 022a: eb          .
	dad	h		;; 022b: 29          )
	dad	h		;; 022c: 29          )
	pop	d		;; 022d: d1          .
	call	L1b57		;; 022e: cd 57 1b    .W.
	dcx	h		;; 0231: 2b          +
	shld	L2c42		;; 0232: 22 42 2c    "B,
	lhld	L2c42		;; 0235: 2a 42 2c    *B,
	mvi	a,002h		;; 0238: 3e 02       >.
	push	h		;; 023a: e5          .
	mov	l,a		;; 023b: 6f          o
	add	a		;; 023c: 87          .
	sbb	a		;; 023d: 9f          .
	mov	h,a		;; 023e: 67          g
	pop	d		;; 023f: d1          .
	call	L1b11		;; 0240: cd 11 1b    ...
	shld	L2c40		;; 0243: 22 40 2c    "@,
	call	L03f4		;; 0246: cd f4 03    ...
	lda	L2d46		;; 0249: 3a 46 2d    :F-
	ora	a		;; 024c: b7          .
	jp	L0266		;; 024d: f2 66 02    .f.
	lxi	h,L2cc5		;; 0250: 21 c5 2c    ..,
	lxi	d,L2c1b		;; 0253: 11 1b 2c    ..,
	mvi	a,080h		;; 0256: 3e 80       >.
	mvi	b,00dh		;; 0258: 06 0d       ..
	call	L1a63		;; 025a: cd 63 1a    .c.
	lxi	h,L3079		;; 025d: 21 79 30    .y0
	call	L14b7		;; 0260: cd b7 14    ...
	call	L157e		;; 0263: cd 7e 15    .~.
L0266:	lxi	h,L307b		;; 0266: 21 7b 30    .{0
	call	L11fa		;; 0269: cd fa 11    ...
	lxi	h,L2bf2		;; 026c: 21 f2 2b    ..+
	lxi	d,L2f51		;; 026f: 11 51 2f    .Q/
	mvi	a,001h		;; 0272: 3e 01       >.
	call	L1972		;; 0274: cd 72 19    .r.
	sui	001h		;; 0277: d6 01       ..
	sbb	a		;; 0279: 9f          .
	sta	L2d4b		;; 027a: 32 4b 2d    2K-
	lhld	L2d49		;; 027d: 2a 49 2d    *I-
	xra	a		;; 0280: af          .
	mov	m,a		;; 0281: 77          w
	inx	h		;; 0282: 23          #
	mov	m,a		;; 0283: 77          w
	sta	L2f50		;; 0284: 32 50 2f    2P/
	mvi	a,018h		;; 0287: 3e 18       >.
	sta	L2f4f		;; 0289: 32 4f 2f    2O/
	xra	a		;; 028c: af          .
	sta	L2f4e		;; 028d: 32 4e 2f    2N/
	lxi	h,L2fda		;; 0290: 21 da 2f    ../
	lxi	d,L2c28		;; 0293: 11 28 2c    .(,
	mvi	a,008h		;; 0296: 3e 08       >.
	mvi	b,001h		;; 0298: 06 01       ..
	call	L1a74		;; 029a: cd 74 1a    .t.
	lxi	h,0		;; 029d: 21 00 00    ...
	shld	L2d4e		;; 02a0: 22 4e 2d    "N-
L02a3:	lda	L2d46		;; 02a3: 3a 46 2d    :F-
	ora	a		;; 02a6: b7          .
	jm	L03d5		;; 02a7: fa d5 03    ...
	call	L15ea		;; 02aa: cd ea 15    ...
	ora	a		;; 02ad: b7          .
	jp	L02b4		;; 02ae: f2 b4 02    ...
	call	L0558		;; 02b1: cd 58 05    .X.
L02b4:	lxi	h,L2c44		;; 02b4: 21 44 2c    .D,
	mvi	e,001h		;; 02b7: 1e 01       ..
	mvi	c,005h		;; 02b9: 0e 05       ..
	call	L194c		;; 02bb: cd 4c 19    .L.
	xchg			;; 02be: eb          .
	mov	b,a		;; 02bf: 47          G
	lxi	h,L2c29		;; 02c0: 21 29 2c    .),
	mvi	a,005h		;; 02c3: 3e 05       >.
	call	L1979		;; 02c5: cd 79 19    .y.
	jnz	L030c		;; 02c8: c2 0c 03    ...
	lda	L23ba		;; 02cb: 3a ba 23    :.#
	ora	a		;; 02ce: b7          .
	jp	L02e2		;; 02cf: f2 e2 02    ...
	lxi	h,L23ba		;; 02d2: 21 ba 23    ..#
	mvi	m,000h		;; 02d5: 36 00       6.
	lxi	h,L2f51		;; 02d7: 21 51 2f    .Q/
	lxi	d,L2c44		;; 02da: 11 44 2c    .D,
	mvi	a,080h		;; 02dd: 3e 80       >.
	call	L1a5f		;; 02df: cd 5f 1a    ._.
L02e2:	lda	L2f4f		;; 02e2: 3a 4f 2f    :O/
	lxi	h,L2f4e		;; 02e5: 21 4e 2f    .N/
	sub	m		;; 02e8: 96          .
	jp	L02f2		;; 02e9: f2 f2 02    ...
	lda	L2f4e		;; 02ec: 3a 4e 2f    :N/
	sta	L2f4f		;; 02ef: 32 4f 2f    2O/
L02f2:	xra	a		;; 02f2: af          .
	sta	L2f4e		;; 02f3: 32 4e 2f    2N/
	lxi	h,L2f50		;; 02f6: 21 50 2f    .P/
	inr	m		;; 02f9: 34          4
	lxi	h,L307d		;; 02fa: 21 7d 30    .}0
	call	L11fa		;; 02fd: cd fa 11    ...
	call	L03f4		;; 0300: cd f4 03    ...
	lxi	h,L307f		;; 0303: 21 7f 30    ..0
	call	L11fa		;; 0306: cd fa 11    ...
	jmp	L03cf		;; 0309: c3 cf 03    ...

L030c:	lhld	L2d4c		;; 030c: 2a 4c 2d    *L-
	inx	h		;; 030f: 23          #
	shld	L2d4c		;; 0310: 22 4c 2d    "L-
	lxi	h,L3081		;; 0313: 21 81 30    ..0
	call	L0941		;; 0316: cd 41 09    .A.
	lxi	h,L2fe2		;; 0319: 21 e2 2f    ../
	mvi	b,006h		;; 031c: 06 06       ..
	call	L1a2a		;; 031e: cd 2a 1a    .*.
	lxi	h,L2fe2		;; 0321: 21 e2 2f    ../
	mvi	e,002h		;; 0324: 1e 02       ..
	mvi	c,005h		;; 0326: 0e 05       ..
	mvi	a,006h		;; 0328: 3e 06       >.
	call	L1958		;; 032a: cd 58 19    .X.
	push	h		;; 032d: e5          .
	lxi	h,L2fda		;; 032e: 21 da 2f    ../
	mvi	e,002h		;; 0331: 1e 02       ..
	mvi	c,005h		;; 0333: 0e 05       ..
	push	psw		;; 0335: f5          .
	mvi	a,008h		;; 0336: 3e 08       >.
	call	L1958		;; 0338: cd 58 19    .X.
	pop	b		;; 033b: c1          .
	pop	d		;; 033c: d1          .
	call	L1a74		;; 033d: cd 74 1a    .t.
	lxi	h,L2c44		;; 0340: 21 44 2c    .D,
	mvi	e,001h		;; 0343: 1e 01       ..
	mov	c,e		;; 0345: 4b          K
	call	L194c		;; 0346: cd 4c 19    .L.
	xchg			;; 0349: eb          .
	mov	b,a		;; 034a: 47          G
	lxi	h,L2c2e		;; 034b: 21 2e 2c    ..,
	mvi	a,001h		;; 034e: 3e 01       >.
	call	L1979		;; 0350: cd 79 19    .y.
	jnz	L039d		;; 0353: c2 9d 03    ...
	lda	L2f4f		;; 0356: 3a 4f 2f    :O/
	lxi	h,L2f4e		;; 0359: 21 4e 2f    .N/
	sub	m		;; 035c: 96          .
	jp	L0366		;; 035d: f2 66 03    .f.
	lda	L2f4e		;; 0360: 3a 4e 2f    :N/
	sta	L2f4f		;; 0363: 32 4f 2f    2O/
L0366:	xra	a		;; 0366: af          .
	sta	L2f4e		;; 0367: 32 4e 2f    2N/
	lxi	h,L2fda		;; 036a: 21 da 2f    ../
	mvi	e,001h		;; 036d: 1e 01       ..
	mvi	c,007h		;; 036f: 0e 07       ..
	mvi	a,008h		;; 0371: 3e 08       >.
	call	L1958		;; 0373: cd 58 19    .X.
	call	L1a17		;; 0376: cd 17 1a    ...
	lxi	h,L2c2e		;; 0379: 21 2e 2c    ..,
	mvi	b,001h		;; 037c: 06 01       ..
	call	L19df		;; 037e: cd df 19    ...
	lxi	h,L2cc5		;; 0381: 21 c5 2c    ..,
	mvi	b,080h		;; 0384: 06 80       ..
	call	L1a40		;; 0386: cd 40 1a    .@.
	lxi	h,L2c44		;; 0389: 21 44 2c    .D,
	mvi	e,001h		;; 038c: 1e 01       ..
	mov	c,e		;; 038e: 4b          K
	call	L194c		;; 038f: cd 4c 19    .L.
	lxi	d,L2c28		;; 0392: 11 28 2c    .(,
	mvi	b,001h		;; 0395: 06 01       ..
	call	L1a74		;; 0397: cd 74 1a    .t.
	jmp	L03ae		;; 039a: c3 ae 03    ...

L039d:	lxi	h,L2f4e		;; 039d: 21 4e 2f    .N/
	inr	m		;; 03a0: 34          4
	lxi	h,L2cc5		;; 03a1: 21 c5 2c    ..,
	lxi	d,L2fda		;; 03a4: 11 da 2f    ../
	mvi	a,080h		;; 03a7: 3e 80       >.
	mvi	b,008h		;; 03a9: 06 08       ..
	call	L1a63		;; 03ab: cd 63 1a    .c.
L03ae:	lxi	h,L3083		;; 03ae: 21 83 30    ..0
	call	L11fa		;; 03b1: cd fa 11    ...
	lxi	h,L3085		;; 03b4: 21 85 30    ..0
	call	L11fa		;; 03b7: cd fa 11    ...
	lxi	h,L3087		;; 03ba: 21 87 30    ..0
	call	L096e		;; 03bd: cd 6e 09    .n.
	lxi	h,L2d4e		;; 03c0: 21 4e 2d    .N-
	mov	a,m		;; 03c3: 7e          ~
	inx	h		;; 03c4: 23          #
	ora	m		;; 03c5: b6          .
	jz	L03cf		;; 03c6: ca cf 03    ...
	lxi	h,L308d		;; 03c9: 21 8d 30    ..0
	call	L0b83		;; 03cc: cd 83 0b    ...
L03cf:	call	L03f4		;; 03cf: cd f4 03    ...
	jmp	L02a3		;; 03d2: c3 a3 02    ...

L03d5:	lxi	h,L3099		;; 03d5: 21 99 30    ..0
	call	L0eac		;; 03d8: cd ac 0e    ...
	lxi	h,L2c44		;; 03db: 21 44 2c    .D,
	lxi	d,L2c2f		;; 03de: 11 2f 2c    ./,
	mvi	a,080h		;; 03e1: 3e 80       >.
	mvi	b,001h		;; 03e3: 06 01       ..
	call	L1a63		;; 03e5: cd 63 1a    .c.
	lxi	h,L30a3		;; 03e8: 21 a3 30    ..0
	call	L11fa		;; 03eb: cd fa 11    ...
	call	L157e		;; 03ee: cd 7e 15    .~.
	jmp	L0555		;; 03f1: c3 55 05    .U.

L03f4:	lxi	h,0		;; 03f4: 21 00 00    ...
	dad	sp		;; 03f7: 39          9
	shld	L30ab		;; 03f8: 22 ab 30    ".0
	lda	L23ed		;; 03fb: 3a ed 23    :.#
	ora	a		;; 03fe: b7          .
	jp	L045a		;; 03ff: f2 5a 04    .Z.
	lxi	h,L23ed		;; 0402: 21 ed 23    ..#
	mvi	m,000h		;; 0405: 36 00       6.
	lxi	h,L23c7		;; 0407: 21 c7 23    ..#
	shld	L2fd8		;; 040a: 22 d8 2f    "./
	call	L1572		;; 040d: cd 72 15    .r.
	push	h		;; 0410: e5          .
	lhld	L2fd8		;; 0411: 2a d8 2f    *./
	pop	d		;; 0414: d1          .
	mvi	a,024h		;; 0415: 3e 24       >$
	mov	b,a		;; 0417: 47          G
	call	L1a74		;; 0418: cd 74 1a    .t.
	lxi	h,L23d0		;; 041b: 21 d0 23    ..#
	lxi	d,L23ee		;; 041e: 11 ee 23    ..#
	mvi	a,003h		;; 0421: 3e 03       >.
	mov	b,a		;; 0423: 47          G
	call	L1a74		;; 0424: cd 74 1a    .t.
	lxi	h,L23ee		;; 0427: 21 ee 23    ..#
	lxi	d,L2c30		;; 042a: 11 30 2c    .0,
	mvi	a,003h		;; 042d: 3e 03       >.
	mov	b,a		;; 042f: 47          G
	call	L1a74		;; 0430: cd 74 1a    .t.
	lxi	h,L23d3		;; 0433: 21 d3 23    ..#
	mvi	m,000h		;; 0436: 36 00       6.
	lxi	h,L23e7		;; 0438: 21 e7 23    ..#
	mvi	m,000h		;; 043b: 36 00       6.
	lxi	h,L23c7		;; 043d: 21 c7 23    ..#
	shld	L30a9		;; 0440: 22 a9 30    ".0
	lxi	h,L30a7		;; 0443: 21 a7 30    ..0
	call	fopen		;; 0446: cd 06 16    ...
	sui	0ffh		;; 0449: d6 ff       ..
	jnz	L0454		;; 044b: c2 54 04    .T.
	lxi	h,L2d46		;; 044e: 21 46 2d    .F-
	mvi	m,080h		;; 0451: 36 80       6.
	ret			;; 0453: c9          .

L0454:	lxi	h,L0801		;; 0454: 21 01 08    ...
	shld	L23eb		;; 0457: 22 eb 23    ".#
L045a:	lxi	h,L2c44		;; 045a: 21 44 2c    .D,
	mvi	m,000h		;; 045d: 36 00       6.
	lxi	h,L30a5		;; 045f: 21 a5 30    ..0
	mvi	m,000h		;; 0462: 36 00       6.
L0464:	lda	L30a5		;; 0464: 3a a5 30    :.0
	ora	a		;; 0467: b7          .
	jm	L047d		;; 0468: fa 7d 04    .}.
	call	L0490		;; 046b: cd 90 04    ...
	push	psw		;; 046e: f5          .
	inx	sp		;; 046f: 33          3
	mvi	a,001h		;; 0470: 3e 01       >.
	lxi	h,L2c44		;; 0472: 21 44 2c    .D,
	mvi	b,080h		;; 0475: 06 80       ..
	call	L19a7		;; 0477: cd a7 19    ...
	jmp	L0464		;; 047a: c3 64 04    .d.

L047d:	ret			;; 047d: c9          .

L047e:	lhld	L30ab		;; 047e: 2a ab 30    *.0
	sphl			;; 0481: f9          .
	call	L1bc6		;; 0482: cd c6 1b    ...
	lxi	h,L2d46		;; 0485: 21 46 2d    .F-
	mvi	m,080h		;; 0488: 36 80       6.
	lxi	h,L23ed		;; 048a: 21 ed 23    ..#
	mvi	m,080h		;; 048d: 36 80       6.
	ret			;; 048f: c9          .

L0490:	lhld	L23eb		;; 0490: 2a eb 23    *.#
	inx	h		;; 0493: 23          #
	shld	L23eb		;; 0494: 22 eb 23    ".#
	lhld	L23eb		;; 0497: 2a eb 23    *.#
	lxi	b,0f7ffh	;; 049a: 01 ff f7    ...
	dad	b		;; 049d: 09          .
	mov	a,h		;; 049e: 7c          |
	ora	a		;; 049f: b7          .
	jm	L052e		;; 04a0: fa 2e 05    ...
	lxi	h,00001h	;; 04a3: 21 01 00    ...
	shld	L30ae		;; 04a6: 22 ae 30    ".0
	mov	a,l		;; 04a9: 7d          }
	sta	L30ad		;; 04aa: 32 ad 30    2.0
L04ad:	lxi	h,L30ad		;; 04ad: 21 ad 30    ..0
	mvi	a,010h		;; 04b0: 3e 10       >.
	sub	m		;; 04b2: 96          .
	jm	L04f8		;; 04b3: fa f8 04    ...
	lxi	h,L23f0		;; 04b6: 21 f0 23    ..#
	push	h		;; 04b9: e5          .
	lhld	L30ae		;; 04ba: 2a ae 30    *.0
	pop	d		;; 04bd: d1          .
	dad	d		;; 04be: 19          .
	shld	L30b2		;; 04bf: 22 b2 30    ".0
	lxi	h,L30b0		;; 04c2: 21 b0 30    ..0
	call	fstdma		;; 04c5: cd 55 16    .U.
	lxi	h,L23c7		;; 04c8: 21 c7 23    ..#
	shld	L30b6		;; 04cb: 22 b6 30    ".0
	lxi	h,L30b4		;; 04ce: 21 b4 30    ..0
	call	fread		;; 04d1: cd 2b 16    .+.
	sui	000h		;; 04d4: d6 00       ..
	jz	L04e7		;; 04d6: ca e7 04    ...
	lxi	h,L23f0		;; 04d9: 21 f0 23    ..#
	push	h		;; 04dc: e5          .
	lhld	L30ae		;; 04dd: 2a ae 30    *.0
	pop	d		;; 04e0: d1          .
	dad	d		;; 04e1: 19          .
	mvi	m,01ah		;; 04e2: 36 1a       6.
	jmp	L04f8		;; 04e4: c3 f8 04    ...

L04e7:	lhld	L30ae		;; 04e7: 2a ae 30    *.0
	lxi	b,00080h	;; 04ea: 01 80 00    ...
	dad	b		;; 04ed: 09          .
	shld	L30ae		;; 04ee: 22 ae 30    ".0
	lxi	h,L30ad		;; 04f1: 21 ad 30    ..0
	inr	m		;; 04f4: 34          4
	jmp	L04ad		;; 04f5: c3 ad 04    ...

L04f8:	lxi	h,00001h	;; 04f8: 21 01 00    ...
	shld	L23eb		;; 04fb: 22 eb 23    ".#
	lda	L2bf1		;; 04fe: 3a f1 2b    :.+
	ora	a		;; 0501: b7          .
	jp	L052e		;; 0502: f2 2e 05    ...
	lxi	h,L2bf1		;; 0505: 21 f1 2b    ..+
	mvi	m,000h		;; 0508: 36 00       6.
	lda	L23f1		;; 050a: 3a f1 23    :.#
	sui	00dh		;; 050d: d6 0d       ..
	sui	001h		;; 050f: d6 01       ..
	sbb	a		;; 0511: 9f          .
	push	psw		;; 0512: f5          .
	lda	L23f2		;; 0513: 3a f2 23    :.#
	sui	00ah		;; 0516: d6 0a       ..
	sui	001h		;; 0518: d6 01       ..
	sbb	a		;; 051a: 9f          .
	pop	b		;; 051b: c1          .
	ana	b		;; 051c: a0          .
	push	psw		;; 051d: f5          .
	lda	L23f3		;; 051e: 3a f3 23    :.#
	sui	01ah		;; 0521: d6 1a       ..
	sui	001h		;; 0523: d6 01       ..
	sbb	a		;; 0525: 9f          .
	pop	b		;; 0526: c1          .
	ana	b		;; 0527: a0          .
	jp	L052e		;; 0528: f2 2e 05    ...
	jmp	L047e		;; 052b: c3 7e 04    .~.

L052e:	lxi	h,L23f0		;; 052e: 21 f0 23    ..#
	push	h		;; 0531: e5          .
	lhld	L23eb		;; 0532: 2a eb 23    *.#
	pop	d		;; 0535: d1          .
	dad	d		;; 0536: 19          .
	mov	a,m		;; 0537: 7e          ~
	sta	L30ad		;; 0538: 32 ad 30    2.0
	lda	L30ad		;; 053b: 3a ad 30    :.0
	sui	00ah		;; 053e: d6 0a       ..
	sui	001h		;; 0540: d6 01       ..
	sbb	a		;; 0542: 9f          .
	sta	L30a5		;; 0543: 32 a5 30    2.0
	lda	L30ad		;; 0546: 3a ad 30    :.0
	sui	01ah		;; 0549: d6 1a       ..
	jnz	L0551		;; 054b: c2 51 05    .Q.
	jmp	L047e		;; 054e: c3 7e 04    .~.

L0551:	lda	L30ad		;; 0551: 3a ad 30    :.0
	ret			;; 0554: c9          .

L0555:	jmp	L059e		;; 0555: c3 9e 05    ...

L0558:	lda	L2d4b		;; 0558: 3a 4b 2d    :K-
	ora	a		;; 055b: b7          .
	jp	L0587		;; 055c: f2 87 05    ...
	call	L157a		;; 055f: cd 7a 15    .z.
	shld	L2fd8		;; 0562: 22 d8 2f    "./
	lxi	h,L30b8		;; 0565: 21 b8 30    ..0
	call	fstdma		;; 0568: cd 55 16    .U.
	call	L1572		;; 056b: cd 72 15    .r.
	shld	L2fd8		;; 056e: 22 d8 2f    "./
	lhld	L2fd8		;; 0571: 2a d8 2f    *./
	lxi	d,00009h	;; 0574: 11 09 00    ...
	dad	d		;; 0577: 19          .
	lxi	d,L2c33		;; 0578: 11 33 2c    .3,
	mvi	a,003h		;; 057b: 3e 03       >.
	mov	b,a		;; 057d: 47          G
	call	L1a74		;; 057e: cd 74 1a    .t.
	lxi	h,L30ba		;; 0581: 21 ba 30    ..0
	call	fdelet		;; 0584: cd 23 16    .#.
L0587:	lxi	h,L2c44		;; 0587: 21 44 2c    .D,
	lxi	d,L2c36		;; 058a: 11 36 2c    .6,
	mvi	a,080h		;; 058d: 3e 80       >.
	mvi	b,00ah		;; 058f: 06 0a       ..
	call	L1a63		;; 0591: cd 63 1a    .c.
	lxi	h,L30bc		;; 0594: 21 bc 30    ..0
	call	L14b7		;; 0597: cd b7 14    ...
	call	L157e		;; 059a: cd 7e 15    .~.
	ret			;; 059d: c9          .

L059e:	call	L22b2		;; 059e: cd b2 22    .."
L05a1:	lxi	d,L30f4		;; 05a1: 11 f4 30    ..0
	mvi	c,006h		;; 05a4: 0e 06       ..
L05a6:	mov	a,m		;; 05a6: 7e          ~
	inx	h		;; 05a7: 23          #
	stax	d		;; 05a8: 12          .
	inx	d		;; 05a9: 13          .
	dcr	c		;; 05aa: 0d          .
	jnz	L05a6		;; 05ab: c2 a6 05    ...
	lhld	L30f8		;; 05ae: 2a f8 30    *.0
	mov	e,m		;; 05b1: 5e          ^
	inx	h		;; 05b2: 23          #
	mov	d,m		;; 05b3: 56          V
	xchg			;; 05b4: eb          .
	shld	L30fc		;; 05b5: 22 fc 30    ".0
	lhld	L30f6		;; 05b8: 2a f6 30    *.0
	mov	e,m		;; 05bb: 5e          ^
	inx	h		;; 05bc: 23          #
	mov	d,m		;; 05bd: 56          V
	xchg			;; 05be: eb          .
	shld	L30fa		;; 05bf: 22 fa 30    ".0
	call	L0895		;; 05c2: cd 95 08    ...
	lxi	h,L3110		;; 05c5: 21 10 31    ..1
	shld	L3102		;; 05c8: 22 02 31    ".1
	lxi	h,L3132		;; 05cb: 21 32 31    .21
	mvi	m,000h		;; 05ce: 36 00       6.
	mvi	a,001h		;; 05d0: 3e 01       >.
	sta	L3136		;; 05d2: 32 36 31    261
	sta	L3135		;; 05d5: 32 35 31    251
	lda	L3121		;; 05d8: 3a 21 31    :.1
	sta	L313a		;; 05db: 32 3a 31    2:1
L05de:	lda	L313a		;; 05de: 3a 3a 31    ::1
	lxi	h,L3135		;; 05e1: 21 35 31    .51
	sub	m		;; 05e4: 96          .
	jm	L0889		;; 05e5: fa 89 08    ...
	lxi	h,L3121		;; 05e8: 21 21 31    ..1
	lda	L3135		;; 05eb: 3a 35 31    :51
	push	h		;; 05ee: e5          .
	mov	l,a		;; 05ef: 6f          o
	add	a		;; 05f0: 87          .
	sbb	a		;; 05f1: 9f          .
	mov	h,a		;; 05f2: 67          g
	pop	d		;; 05f3: d1          .
	dad	d		;; 05f4: 19          .
	mov	a,m		;; 05f5: 7e          ~
	sta	L3137		;; 05f6: 32 37 31    271
	lda	L3132		;; 05f9: 3a 32 31    :21
	ora	a		;; 05fc: b7          .
	jp	L0608		;; 05fd: f2 08 06    ...
	lxi	h,L3132		;; 0600: 21 32 31    .21
	mvi	m,000h		;; 0603: 36 00       6.
	jmp	L087b		;; 0605: c3 7b 08    .{.

L0608:	lda	L3137		;; 0608: 3a 37 31    :71
	lxi	h,L3136		;; 060b: 21 36 31    .61
	sub	m		;; 060e: 96          .
	sui	005h		;; 060f: d6 05       ..
	sta	L3138		;; 0611: 32 38 31    281
	lhld	L30f4		;; 0614: 2a f4 30    *.0
	lda	L3136		;; 0617: 3a 36 31    :61
	adi	005h		;; 061a: c6 05       ..
	push	h		;; 061c: e5          .
	mov	l,a		;; 061d: 6f          o
	lda	L3138		;; 061e: 3a 38 31    :81
	mov	c,a		;; 0621: 4f          O
	xchg			;; 0622: eb          .
	pop	h		;; 0623: e1          .
	call	L194c		;; 0624: cd 4c 19    .L.
	xchg			;; 0627: eb          .
	mov	b,a		;; 0628: 47          G
	lxi	h,L3110		;; 0629: 21 10 31    ..1
	mvi	a,010h		;; 062c: 3e 10       >.
	call	L1a63		;; 062e: cd 63 1a    .c.
	lda	L3138		;; 0631: 3a 38 31    :81
	adi	002h		;; 0634: c6 02       ..
	mov	l,a		;; 0636: 6f          o
	add	a		;; 0637: 87          .
	sbb	a		;; 0638: 9f          .
	mov	h,a		;; 0639: 67          g
	mvi	a,002h		;; 063a: 3e 02       >.
	push	h		;; 063c: e5          .
	mov	l,a		;; 063d: 6f          o
	add	a		;; 063e: 87          .
	sbb	a		;; 063f: 9f          .
	mov	h,a		;; 0640: 67          g
	pop	d		;; 0641: d1          .
	call	L1b11		;; 0642: cd 11 1b    ...
	mov	a,l		;; 0645: 7d          }
	sta	L3138		;; 0646: 32 38 31    281
	lhld	L30fa		;; 0649: 2a fa 30    *.0
	xchg			;; 064c: eb          .
	lda	L3138		;; 064d: 3a 38 31    :81
	mov	l,a		;; 0650: 6f          o
	add	a		;; 0651: 87          .
	sbb	a		;; 0652: 9f          .
	mov	h,a		;; 0653: 67          g
	call	L1b57		;; 0654: cd 57 1b    .W.
	shld	L30fa		;; 0657: 22 fa 30    ".0
	lhld	L30be		;; 065a: 2a be 30    *.0
	xchg			;; 065d: eb          .
	lda	L3138		;; 065e: 3a 38 31    :81
	mov	l,a		;; 0661: 6f          o
	add	a		;; 0662: 87          .
	sbb	a		;; 0663: 9f          .
	mov	h,a		;; 0664: 67          g
	dad	d		;; 0665: 19          .
	inx	h		;; 0666: 23          #
	inx	h		;; 0667: 23          #
	inx	h		;; 0668: 23          #
	inx	h		;; 0669: 23          #
	shld	L30be		;; 066a: 22 be 30    ".0
	lhld	L30fa		;; 066d: 2a fa 30    *.0
	xchg			;; 0670: eb          .
	lhld	L30be		;; 0671: 2a be 30    *.0
	call	L1b57		;; 0674: cd 57 1b    .W.
	jp	L0696		;; 0677: f2 96 06    ...
	lhld	L30f4		;; 067a: 2a f4 30    *.0
	lxi	d,L30c0		;; 067d: 11 c0 30    ..0
	mvi	a,080h		;; 0680: 3e 80       >.
	mvi	b,017h		;; 0682: 06 17       ..
	call	L1a63		;; 0684: cd 63 1a    .c.
	lhld	L30f4		;; 0687: 2a f4 30    *.0
	shld	L313b		;; 068a: 22 3b 31    ";1
	lxi	h,L313b		;; 068d: 21 3b 31    .;1
	call	L14b7		;; 0690: cd b7 14    ...
	call	L157e		;; 0693: cd 7e 15    .~.
L0696:	mvi	a,001h		;; 0696: 3e 01       >.
	sta	L3139		;; 0698: 32 39 31    291
	lxi	h,L3110		;; 069b: 21 10 31    ..1
	mov	l,m		;; 069e: 6e          n
	mvi	h,000h		;; 069f: 26 00       &.
	mov	a,l		;; 06a1: 7d          }
	sta	L313d		;; 06a2: 32 3d 31    2=1
L06a5:	lda	L313d		;; 06a5: 3a 3d 31    :=1
	lxi	h,L3139		;; 06a8: 21 39 31    .91
	sub	m		;; 06ab: 96          .
	jm	L0700		;; 06ac: fa 00 07    ...
	lhld	L3102		;; 06af: 2a 02 31    *.1
	lda	L3139		;; 06b2: 3a 39 31    :91
	push	h		;; 06b5: e5          .
	mov	l,a		;; 06b6: 6f          o
	add	a		;; 06b7: 87          .
	sbb	a		;; 06b8: 9f          .
	mov	h,a		;; 06b9: 67          g
	pop	d		;; 06ba: d1          .
	dad	d		;; 06bb: 19          .
	shld	L3100		;; 06bc: 22 00 31    ".1
	lhld	L3100		;; 06bf: 2a 00 31    *.1
	mov	a,m		;; 06c2: 7e          ~
	mov	l,a		;; 06c3: 6f          o
	add	a		;; 06c4: 87          .
	sbb	a		;; 06c5: 9f          .
	mov	h,a		;; 06c6: 67          g
	lxi	b,0ff9fh	;; 06c7: 01 9f ff    ...
	dad	b		;; 06ca: 09          .
	mov	a,h		;; 06cb: 7c          |
	ora	a		;; 06cc: b7          .
	jm	L06da		;; 06cd: fa da 06    ...
	lhld	L3100		;; 06d0: 2a 00 31    *.1
	mvi	a,0dfh		;; 06d3: 3e df       >.
	ana	m		;; 06d5: a6          .
	mov	m,a		;; 06d6: 77          w
	jmp	L06f9		;; 06d7: c3 f9 06    ...

L06da:	lhld	L3100		;; 06da: 2a 00 31    *.1
	mov	a,m		;; 06dd: 7e          ~
	sui	03fh		;; 06de: d6 3f       .?
	jnz	L06eb		;; 06e0: c2 eb 06    ...
	lhld	L3100		;; 06e3: 2a 00 31    *.1
	mvi	m,05fh		;; 06e6: 36 5f       6_
	jmp	L06f9		;; 06e8: c3 f9 06    ...

L06eb:	lhld	L3100		;; 06eb: 2a 00 31    *.1
	mov	a,m		;; 06ee: 7e          ~
	sui	040h		;; 06ef: d6 40       .@
	jnz	L06f9		;; 06f1: c2 f9 06    ...
	lhld	L3100		;; 06f4: 2a 00 31    *.1
	mvi	m,060h		;; 06f7: 36 60       6`
L06f9:	lxi	h,L3139		;; 06f9: 21 39 31    .91
	inr	m		;; 06fc: 34          4
	jmp	L06a5		;; 06fd: c3 a5 06    ...

L0700:	lhld	L30fc		;; 0700: 2a fc 30    *.0
	dcx	h		;; 0703: 2b          +
	dcx	h		;; 0704: 2b          +
	push	h		;; 0705: e5          .
	lhld	L30fa		;; 0706: 2a fa 30    *.0
	dad	h		;; 0709: 29          )
	pop	d		;; 070a: d1          .
	dad	d		;; 070b: 19          .
	shld	L3100		;; 070c: 22 00 31    ".1
	lhld	L3100		;; 070f: 2a 00 31    *.1
	lxi	d,L3110		;; 0712: 11 10 31    ..1
	mvi	a,010h		;; 0715: 3e 10       >.
	call	L1a5f		;; 0717: cd 5f 1a    ._.
	lhld	L30fc		;; 071a: 2a fc 30    *.0
	mov	e,m		;; 071d: 5e          ^
	inx	h		;; 071e: 23          #
	mov	d,m		;; 071f: 56          V
	xchg			;; 0720: eb          .
	shld	L3133		;; 0721: 22 33 31    "31
	lhld	L30fc		;; 0724: 2a fc 30    *.0
	mov	e,m		;; 0727: 5e          ^
	inx	h		;; 0728: 23          #
	mov	d,m		;; 0729: 56          V
	xchg			;; 072a: eb          .
	inx	h		;; 072b: 23          #
	xchg			;; 072c: eb          .
	mov	m,d		;; 072d: 72          r
	dcx	h		;; 072e: 2b          +
	mov	m,e		;; 072f: 73          s
	lhld	L3100		;; 0730: 2a 00 31    *.1
	push	h		;; 0733: e5          .
	lhld	L30fc		;; 0734: 2a fc 30    *.0
	lxi	d,0fffah	;; 0737: 11 fa ff    ...
	dad	d		;; 073a: 19          .
	push	h		;; 073b: e5          .
	lhld	L30fc		;; 073c: 2a fc 30    *.0
	mov	e,m		;; 073f: 5e          ^
	inx	h		;; 0740: 23          #
	mov	d,m		;; 0741: 56          V
	xchg			;; 0742: eb          .
	dad	h		;; 0743: 29          )
	dad	h		;; 0744: 29          )
	dad	h		;; 0745: 29          )
	pop	d		;; 0746: d1          .
	dad	d		;; 0747: 19          .
	pop	d		;; 0748: d1          .
	mov	m,e		;; 0749: 73          s
	inx	h		;; 074a: 23          #
	mov	m,d		;; 074b: 72          r
	lhld	L30f4		;; 074c: 2a f4 30    *.0
	lda	L3136		;; 074f: 3a 36 31    :61
	mov	e,a		;; 0752: 5f          _
	mvi	c,004h		;; 0753: 0e 04       ..
	call	L194c		;; 0755: cd 4c 19    .L.
	push	h		;; 0758: e5          .
	lhld	L30fc		;; 0759: 2a fc 30    *.0
	lxi	d,0fffch	;; 075c: 11 fc ff    ...
	dad	d		;; 075f: 19          .
	push	psw		;; 0760: f5          .
	push	h		;; 0761: e5          .
	lhld	L30fc		;; 0762: 2a fc 30    *.0
	mov	e,m		;; 0765: 5e          ^
	inx	h		;; 0766: 23          #
	mov	d,m		;; 0767: 56          V
	xchg			;; 0768: eb          .
	dad	h		;; 0769: 29          )
	dad	h		;; 076a: 29          )
	dad	h		;; 076b: 29          )
	pop	d		;; 076c: d1          .
	dad	d		;; 076d: 19          .
	pop	b		;; 076e: c1          .
	pop	d		;; 076f: d1          .
	mvi	a,004h		;; 0770: 3e 04       >.
	call	L1a74		;; 0772: cd 74 1a    .t.
	lhld	L30fc		;; 0775: 2a fc 30    *.0
	push	h		;; 0778: e5          .
	lhld	L30fc		;; 0779: 2a fc 30    *.0
	mov	e,m		;; 077c: 5e          ^
	inx	h		;; 077d: 23          #
	mov	d,m		;; 077e: 56          V
	xchg			;; 077f: eb          .
	dad	h		;; 0780: 29          )
	dad	h		;; 0781: 29          )
	dad	h		;; 0782: 29          )
	pop	d		;; 0783: d1          .
	dad	d		;; 0784: 19          .
	xra	a		;; 0785: af          .
	mov	m,a		;; 0786: 77          w
	inx	h		;; 0787: 23          #
	mov	m,a		;; 0788: 77          w
	lxi	h,L3133		;; 0789: 21 33 31    .31
	cmp	m		;; 078c: be          .
	inx	h		;; 078d: 23          #
	sbb	m		;; 078e: 9e          .
	jp	L0860		;; 078f: f2 60 08    .`.
	lhld	L30fc		;; 0792: 2a fc 30    *.0
	lxi	d,0fffah	;; 0795: 11 fa ff    ...
	dad	d		;; 0798: 19          .
	push	h		;; 0799: e5          .
	lhld	L3133		;; 079a: 2a 33 31    *31
	dad	h		;; 079d: 29          )
	dad	h		;; 079e: 29          )
	dad	h		;; 079f: 29          )
	pop	d		;; 07a0: d1          .
	dad	d		;; 07a1: 19          .
	mov	e,m		;; 07a2: 5e          ^
	inx	h		;; 07a3: 23          #
	mov	d,m		;; 07a4: 56          V
	xchg			;; 07a5: eb          .
	lxi	d,L3110		;; 07a6: 11 10 31    ..1
	call	L196a		;; 07a9: cd 6a 19    .j.
	jnc	L0860		;; 07ac: d2 60 08    .`.
	lhld	L30fc		;; 07af: 2a fc 30    *.0
	lxi	d,0fffah	;; 07b2: 11 fa ff    ...
	dad	d		;; 07b5: 19          .
	push	h		;; 07b6: e5          .
	lhld	L30fc		;; 07b7: 2a fc 30    *.0
	mov	e,m		;; 07ba: 5e          ^
	inx	h		;; 07bb: 23          #
	mov	d,m		;; 07bc: 56          V
	xchg			;; 07bd: eb          .
	dad	h		;; 07be: 29          )
	dad	h		;; 07bf: 29          )
	dad	h		;; 07c0: 29          )
	pop	d		;; 07c1: d1          .
	dad	d		;; 07c2: 19          .
	shld	L3104		;; 07c3: 22 04 31    ".1
	lhld	L3104		;; 07c6: 2a 04 31    *.1
	xchg			;; 07c9: eb          .
	lxi	h,L3108		;; 07ca: 21 08 31    ..1
	mvi	a,008h		;; 07cd: 3e 08       >.
	mov	b,a		;; 07cf: 47          G
	call	L1a74		;; 07d0: cd 74 1a    .t.
	lhld	L30fc		;; 07d3: 2a fc 30    *.0
	lxi	d,0fffah	;; 07d6: 11 fa ff    ...
	dad	d		;; 07d9: 19          .
	push	h		;; 07da: e5          .
	lhld	L3133		;; 07db: 2a 33 31    *31
	dad	h		;; 07de: 29          )
	dad	h		;; 07df: 29          )
	dad	h		;; 07e0: 29          )
	pop	d		;; 07e1: d1          .
	dad	d		;; 07e2: 19          .
	shld	L3106		;; 07e3: 22 06 31    ".1
	lhld	L3106		;; 07e6: 2a 06 31    *.1
	push	h		;; 07e9: e5          .
	lhld	L3104		;; 07ea: 2a 04 31    *.1
	pop	d		;; 07ed: d1          .
	mvi	a,008h		;; 07ee: 3e 08       >.
	mov	b,a		;; 07f0: 47          G
	call	L1a74		;; 07f1: cd 74 1a    .t.
	lhld	L3133		;; 07f4: 2a 33 31    *31
	dcx	h		;; 07f7: 2b          +
	shld	L3133		;; 07f8: 22 33 31    "31
L07fb:	lhld	L30fc		;; 07fb: 2a fc 30    *.0
	lxi	d,0fffah	;; 07fe: 11 fa ff    ...
L0801:	dad	d		;; 0801: 19          .
	push	h		;; 0802: e5          .
	lhld	L3133		;; 0803: 2a 33 31    *31
	dad	h		;; 0806: 29          )
	dad	h		;; 0807: 29          )
	dad	h		;; 0808: 29          )
	pop	d		;; 0809: d1          .
	dad	d		;; 080a: 19          .
	mov	e,m		;; 080b: 5e          ^
	inx	h		;; 080c: 23          #
	mov	d,m		;; 080d: 56          V
	xchg			;; 080e: eb          .
	lxi	d,L3110		;; 080f: 11 10 31    ..1
	call	L196a		;; 0812: cd 6a 19    .j.
	rar			;; 0815: 1f          .
	lxi	h,L3133		;; 0816: 21 33 31    .31
	push	psw		;; 0819: f5          .
	xra	a		;; 081a: af          .
	cmp	m		;; 081b: be          .
	inx	h		;; 081c: 23          #
	sbb	m		;; 081d: 9e          .
	pop	b		;; 081e: c1          .
	ana	b		;; 081f: a0          .
	jp	L0854		;; 0820: f2 54 08    .T.
	lhld	L3106		;; 0823: 2a 06 31    *.1
	shld	L3104		;; 0826: 22 04 31    ".1
	lhld	L30fc		;; 0829: 2a fc 30    *.0
	lxi	d,0fffah	;; 082c: 11 fa ff    ...
	dad	d		;; 082f: 19          .
	push	h		;; 0830: e5          .
	lhld	L3133		;; 0831: 2a 33 31    *31
	dad	h		;; 0834: 29          )
	dad	h		;; 0835: 29          )
	dad	h		;; 0836: 29          )
	pop	d		;; 0837: d1          .
	dad	d		;; 0838: 19          .
	shld	L3106		;; 0839: 22 06 31    ".1
	lhld	L3106		;; 083c: 2a 06 31    *.1
	push	h		;; 083f: e5          .
	lhld	L3104		;; 0840: 2a 04 31    *.1
	pop	d		;; 0843: d1          .
	mvi	a,008h		;; 0844: 3e 08       >.
	mov	b,a		;; 0846: 47          G
	call	L1a74		;; 0847: cd 74 1a    .t.
	lhld	L3133		;; 084a: 2a 33 31    *31
	dcx	h		;; 084d: 2b          +
	shld	L3133		;; 084e: 22 33 31    "31
	jmp	L07fb		;; 0851: c3 fb 07    ...

L0854:	lhld	L3106		;; 0854: 2a 06 31    *.1
	lxi	d,L3108		;; 0857: 11 08 31    ..1
	mvi	a,008h		;; 085a: 3e 08       >.
	mov	b,a		;; 085c: 47          G
	call	L1a74		;; 085d: cd 74 1a    .t.
L0860:	lda	L3137		;; 0860: 3a 37 31    :71
	inr	a		;; 0863: 3c          <
	lxi	h,L3121		;; 0864: 21 21 31    ..1
	push	psw		;; 0867: f5          .
	lda	L3135		;; 0868: 3a 35 31    :51
	push	h		;; 086b: e5          .
	mov	l,a		;; 086c: 6f          o
	add	a		;; 086d: 87          .
	sbb	a		;; 086e: 9f          .
	mov	h,a		;; 086f: 67          g
	inx	h		;; 0870: 23          #
	pop	d		;; 0871: d1          .
	dad	d		;; 0872: 19          .
	pop	psw		;; 0873: f1          .
	sub	m		;; 0874: 96          .
	sui	001h		;; 0875: d6 01       ..
	sbb	a		;; 0877: 9f          .
	sta	L3132		;; 0878: 32 32 31    221
L087b:	lda	L3137		;; 087b: 3a 37 31    :71
	inr	a		;; 087e: 3c          <
	sta	L3136		;; 087f: 32 36 31    261
	lxi	h,L3135		;; 0882: 21 35 31    .51
	inr	m		;; 0885: 34          4
	jmp	L05de		;; 0886: c3 de 05    ...

L0889:	lhld	L30fa		;; 0889: 2a fa 30    *.0
	push	h		;; 088c: e5          .
	lhld	L30f6		;; 088d: 2a f6 30    *.0
	pop	d		;; 0890: d1          .
	mov	m,e		;; 0891: 73          s
	inx	h		;; 0892: 23          #
	mov	m,d		;; 0893: 72          r
	ret			;; 0894: c9          .

L0895:	xra	a		;; 0895: af          .
	sta	L3142		;; 0896: 32 42 31    2B1
	inr	a		;; 0899: 3c          <
	sta	L3141		;; 089a: 32 41 31    2A1
	lxi	h,L30d7		;; 089d: 21 d7 30    ..0
	mvi	a,003h		;; 08a0: 3e 03       >.
	call	L1925		;; 08a2: cd 25 19    .%.
	call	L175e		;; 08a5: cd 5e 17    .^.
	mov	a,l		;; 08a8: 7d          }
	sta	L3143		;; 08a9: 32 43 31    2C1
L08ac:	lda	L3143		;; 08ac: 3a 43 31    :C1
	lxi	h,L3141		;; 08af: 21 41 31    .A1
	sub	m		;; 08b2: 96          .
	jm	L0924		;; 08b3: fa 24 09    .$.
	lhld	L30f4		;; 08b6: 2a f4 30    *.0
	lda	L3141		;; 08b9: 3a 41 31    :A1
	mov	e,a		;; 08bc: 5f          _
	mvi	c,001h		;; 08bd: 0e 01       ..
	call	L194c		;; 08bf: cd 4c 19    .L.
	xchg			;; 08c2: eb          .
	mov	b,a		;; 08c3: 47          G
	lxi	h,L313e		;; 08c4: 21 3e 31    .>1
	mvi	a,001h		;; 08c7: 3e 01       >.
	call	L1a74		;; 08c9: cd 74 1a    .t.
	lxi	h,L30d9		;; 08cc: 21 d9 30    ..0
	lxi	d,L313e		;; 08cf: 11 3e 31    .>1
	mvi	b,001h		;; 08d2: 06 01       ..
	mov	a,b		;; 08d4: 78          x
	call	L1979		;; 08d5: cd 79 19    .y.
	sui	001h		;; 08d8: d6 01       ..
	sbb	a		;; 08da: 9f          .
	lxi	h,L30da		;; 08db: 21 da 30    ..0
	lxi	d,L313e		;; 08de: 11 3e 31    .>1
	mvi	b,001h		;; 08e1: 06 01       ..
	push	psw		;; 08e3: f5          .
	mov	a,b		;; 08e4: 78          x
	call	L1979		;; 08e5: cd 79 19    .y.
	sui	001h		;; 08e8: d6 01       ..
	sbb	a		;; 08ea: 9f          .
	pop	b		;; 08eb: c1          .
	ora	b		;; 08ec: b0          .
	jp	L091d		;; 08ed: f2 1d 09    ...
	lxi	h,L3142		;; 08f0: 21 42 31    .B1
	inr	m		;; 08f3: 34          4
	lda	L3141		;; 08f4: 3a 41 31    :A1
	lxi	h,L3121		;; 08f7: 21 21 31    ..1
	push	psw		;; 08fa: f5          .
	lda	L3142		;; 08fb: 3a 42 31    :B1
	push	h		;; 08fe: e5          .
	mov	l,a		;; 08ff: 6f          o
	add	a		;; 0900: 87          .
	sbb	a		;; 0901: 9f          .
	mov	h,a		;; 0902: 67          g
	pop	d		;; 0903: d1          .
	dad	d		;; 0904: 19          .
	pop	psw		;; 0905: f1          .
	mov	m,a		;; 0906: 77          w
	lxi	h,L30da		;; 0907: 21 da 30    ..0
	lxi	d,L313e		;; 090a: 11 3e 31    .>1
	mvi	b,001h		;; 090d: 06 01       ..
	mov	a,b		;; 090f: 78          x
	call	L1979		;; 0910: cd 79 19    .y.
	jnz	L091d		;; 0913: c2 1d 09    ...
	lda	L3142		;; 0916: 3a 42 31    :B1
	sta	L3121		;; 0919: 32 21 31    2.1
	ret			;; 091c: c9          .

L091d:	lxi	h,L3141		;; 091d: 21 41 31    .A1
	inr	m		;; 0920: 34          4
	jmp	L08ac		;; 0921: c3 ac 08    ...

L0924:	lhld	L30f4		;; 0924: 2a f4 30    *.0
	lxi	d,L30db		;; 0927: 11 db 30    ..0
	mvi	a,080h		;; 092a: 3e 80       >.
	mvi	b,019h		;; 092c: 06 19       ..
	call	L1a63		;; 092e: cd 63 1a    .c.
	lhld	L30f4		;; 0931: 2a f4 30    *.0
	shld	L3144		;; 0934: 22 44 31    "D1
	lxi	h,L3144		;; 0937: 21 44 31    .D1
	call	L14b7		;; 093a: cd b7 14    ...
	call	L157e		;; 093d: cd 7e 15    .~.
	ret			;; 0940: c9          .

L0941:	mov	e,m		;; 0941: 5e          ^
	inx	h		;; 0942: 23          #
	mov	d,m		;; 0943: 56          V
	xchg			;; 0944: eb          .
	shld	L3146		;; 0945: 22 46 31    "F1
	lhld	L3146		;; 0948: 2a 46 31    *F1
	mov	e,m		;; 094b: 5e          ^
	inx	h		;; 094c: 23          #
	mov	d,m		;; 094d: 56          V
	xchg			;; 094e: eb          .
	mvi	a,009h		;; 094f: 3e 09       >.
	call	L188d		;; 0951: cd 8d 18    ...
	lxi	h,L3148		;; 0954: 21 48 31    .H1
	mvi	b,009h		;; 0957: 06 09       ..
	call	L1a2a		;; 0959: cd 2a 1a    .*.
	lxi	h,L3148		;; 095c: 21 48 31    .H1
	mvi	e,004h		;; 095f: 1e 04       ..
	mvi	c,006h		;; 0961: 0e 06       ..
	mvi	a,009h		;; 0963: 3e 09       >.
	call	L1958		;; 0965: cd 58 19    .X.
	call	L1a17		;; 0968: cd 17 1a    ...
	jmp	L1a93		;; 096b: c3 93 1a    ...

L096e:	lxi	d,L31e6		;; 096e: 11 e6 31    ..1
	mvi	c,006h		;; 0971: 0e 06       ..
L0973:	mov	a,m		;; 0973: 7e          ~
	inx	h		;; 0974: 23          #
	stax	d		;; 0975: 12          .
	inx	d		;; 0976: 13          .
	dcr	c		;; 0977: 0d          .
	jnz	L0973		;; 0978: c2 73 09    .s.
	lxi	h,0		;; 097b: 21 00 00    ...
	dad	sp		;; 097e: 39          9
	shld	L3202		;; 097f: 22 02 32    ".2
	lxi	h,L31ec		;; 0982: 21 ec 31    ..1
	shld	L31ed		;; 0985: 22 ed 31    ".1
	lxi	h,L31ef		;; 0988: 21 ef 31    ..1
	mvi	m,080h		;; 098b: 36 80       6.
	lhld	L31e8		;; 098d: 2a e8 31    *.1
	xra	a		;; 0990: af          .
	mov	m,a		;; 0991: 77          w
	inx	h		;; 0992: 23          #
	mov	m,a		;; 0993: 77          w
	lhld	L31e6		;; 0994: 2a e6 31    *.1
	mov	l,m		;; 0997: 6e          n
	mov	h,a		;; 0998: 67          g
	lxi	b,0ffefh	;; 0999: 01 ef ff    ...
	dad	b		;; 099c: 09          .
	mov	a,h		;; 099d: 7c          |
	ora	a		;; 099e: b7          .
	jp	L09a3		;; 099f: f2 a3 09    ...
	ret			;; 09a2: c9          .

L09a3:	lhld	L31e6		;; 09a3: 2a e6 31    *.1
	mvi	e,001h		;; 09a6: 1e 01       ..
	mov	c,e		;; 09a8: 4b          K
	call	L194c		;; 09a9: cd 4c 19    .L.
	xchg			;; 09ac: eb          .
	mov	b,a		;; 09ad: 47          G
	lxi	h,L31e3		;; 09ae: 21 e3 31    ..1
	mvi	a,001h		;; 09b1: 3e 01       >.
	call	L1979		;; 09b3: cd 79 19    .y.
	jnz	L09ba		;; 09b6: c2 ba 09    ...
	ret			;; 09b9: c9          .

L09ba:	call	L0afc		;; 09ba: cd fc 0a    ...
	lxi	h,L31ec		;; 09bd: 21 ec 31    ..1
	mvi	b,001h		;; 09c0: 06 01       ..
	call	L1a2a		;; 09c2: cd 2a 1a    .*.
L09c5:	lhld	L31ed		;; 09c5: 2a ed 31    *.1
	mov	a,m		;; 09c8: 7e          ~
	mov	l,a		;; 09c9: 6f          o
	add	a		;; 09ca: 87          .
	sbb	a		;; 09cb: 9f          .
	mov	h,a		;; 09cc: 67          g
	lxi	d,L3151		;; 09cd: 11 51 31    .Q1
	dad	d		;; 09d0: 19          .
	mov	a,m		;; 09d1: 7e          ~
	mov	l,a		;; 09d2: 6f          o
	add	a		;; 09d3: 87          .
	sbb	a		;; 09d4: 9f          .
	mov	h,a		;; 09d5: 67          g
	dad	h		;; 09d6: 29          )
	lxi	d,L31d1		;; 09d7: 11 d1 31    ..1
	dad	d		;; 09da: 19          .
	mov	e,m		;; 09db: 5e          ^
	inx	h		;; 09dc: 23          #
	mov	d,m		;; 09dd: 56          V
	xchg			;; 09de: eb          .
	pchl			;; 09df: e9          .

L09e0:	lhld	L31e8		;; 09e0: 2a e8 31    *.1
	mov	e,m		;; 09e3: 5e          ^
	inx	h		;; 09e4: 23          #
	mov	d,m		;; 09e5: 56          V
	xchg			;; 09e6: eb          .
	inx	h		;; 09e7: 23          #
	xchg			;; 09e8: eb          .
	mov	m,d		;; 09e9: 72          r
	dcx	h		;; 09ea: 2b          +
	mov	m,e		;; 09eb: 73          s
	call	L0b48		;; 09ec: cd 48 0b    .H.
	lxi	h,L31f0		;; 09ef: 21 f0 31    ..1
	lxi	d,L31ec		;; 09f2: 11 ec 31    ..1
	mvi	a,010h		;; 09f5: 3e 10       >.
	mvi	b,001h		;; 09f7: 06 01       ..
	call	L1a63		;; 09f9: cd 63 1a    .c.
	call	L0afc		;; 09fc: cd fc 0a    ...
	lxi	h,L31ec		;; 09ff: 21 ec 31    ..1
	mvi	b,001h		;; 0a02: 06 01       ..
	call	L1a2a		;; 0a04: cd 2a 1a    .*.
	mvi	a,001h		;; 0a07: 3e 01       >.
	sta	L3201		;; 0a09: 32 01 32    2.2
L0a0c:	lhld	L31ed		;; 0a0c: 2a ed 31    *.1
	mov	a,m		;; 0a0f: 7e          ~
	mov	l,a		;; 0a10: 6f          o
	add	a		;; 0a11: 87          .
	sbb	a		;; 0a12: 9f          .
	mov	h,a		;; 0a13: 67          g
	lxi	d,L3151		;; 0a14: 11 51 31    .Q1
	dad	d		;; 0a17: 19          .
	mov	a,m		;; 0a18: 7e          ~
	sui	003h		;; 0a19: d6 03       ..
	jm	L0a59		;; 0a1b: fa 59 0a    .Y.
	lxi	h,L31e4		;; 0a1e: 21 e4 31    ..1
	lxi	d,L31ec		;; 0a21: 11 ec 31    ..1
	mvi	b,001h		;; 0a24: 06 01       ..
	mov	a,b		;; 0a26: 78          x
	call	L1979		;; 0a27: cd 79 19    .y.
	jz	L0a4b		;; 0a2a: ca 4b 0a    .K.
	lxi	h,L3201		;; 0a2d: 21 01 32    ..2
	inr	m		;; 0a30: 34          4
	call	L0b48		;; 0a31: cd 48 0b    .H.
	lda	L3201		;; 0a34: 3a 01 32    :.2
	sui	011h		;; 0a37: d6 11       ..
	jp	L0a4b		;; 0a39: f2 4b 0a    .K.
	lxi	h,L31ec		;; 0a3c: 21 ec 31    ..1
	push	h		;; 0a3f: e5          .
	lxi	h,L31f0		;; 0a40: 21 f0 31    ..1
	pop	d		;; 0a43: d1          .
	mvi	b,010h		;; 0a44: 06 10       ..
	mvi	a,001h		;; 0a46: 3e 01       >.
	call	L19c1		;; 0a48: cd c1 19    ...
L0a4b:	call	L0afc		;; 0a4b: cd fc 0a    ...
	lxi	h,L31ec		;; 0a4e: 21 ec 31    ..1
	mvi	b,001h		;; 0a51: 06 01       ..
	call	L1a2a		;; 0a53: cd 2a 1a    .*.
	jmp	L0a0c		;; 0a56: c3 0c 0a    ...

L0a59:	lhld	L31ea		;; 0a59: 2a ea 31    *.1
	lxi	d,0ffefh	;; 0a5c: 11 ef ff    ...
	dad	d		;; 0a5f: 19          .
	push	h		;; 0a60: e5          .
	lhld	L31e8		;; 0a61: 2a e8 31    *.1
	mov	e,m		;; 0a64: 5e          ^
	inx	h		;; 0a65: 23          #
	mov	d,m		;; 0a66: 56          V
	xchg			;; 0a67: eb          .
	lxi	d,00011h	;; 0a68: 11 11 00    ...
	call	L1aaf		;; 0a6b: cd af 1a    ...
	pop	d		;; 0a6e: d1          .
	dad	d		;; 0a6f: 19          .
	lxi	d,L31f0		;; 0a70: 11 f0 31    ..1
	mvi	a,010h		;; 0a73: 3e 10       >.
	call	L1a5f		;; 0a75: cd 5f 1a    ._.
	jmp	L09c5		;; 0a78: c3 c5 09    ...

L0a7b:	lhld	L31ed		;; 0a7b: 2a ed 31    *.1
	mov	a,m		;; 0a7e: 7e          ~
	mov	l,a		;; 0a7f: 6f          o
	add	a		;; 0a80: 87          .
	sbb	a		;; 0a81: 9f          .
	mov	h,a		;; 0a82: 67          g
	lxi	d,L3151		;; 0a83: 11 51 31    .Q1
	dad	d		;; 0a86: 19          .
	mov	a,m		;; 0a87: 7e          ~
	sui	003h		;; 0a88: d6 03       ..
	jm	L0a9b		;; 0a8a: fa 9b 0a    ...
	call	L0afc		;; 0a8d: cd fc 0a    ...
	lxi	h,L31ec		;; 0a90: 21 ec 31    ..1
	mvi	b,001h		;; 0a93: 06 01       ..
	call	L1a2a		;; 0a95: cd 2a 1a    .*.
	jmp	L0a7b		;; 0a98: c3 7b 0a    .{.

L0a9b:	jmp	L09c5		;; 0a9b: c3 c5 09    ...

L0a9e:	call	L0afc		;; 0a9e: cd fc 0a    ...
	lxi	h,L31ec		;; 0aa1: 21 ec 31    ..1
	mvi	b,001h		;; 0aa4: 06 01       ..
	call	L1a2a		;; 0aa6: cd 2a 1a    .*.
L0aa9:	lxi	h,L31e5		;; 0aa9: 21 e5 31    ..1
	lxi	d,L31ec		;; 0aac: 11 ec 31    ..1
	mvi	b,001h		;; 0aaf: 06 01       ..
	mov	a,b		;; 0ab1: 78          x
	call	L1979		;; 0ab2: cd 79 19    .y.
	jz	L0ac6		;; 0ab5: ca c6 0a    ...
	call	L0afc		;; 0ab8: cd fc 0a    ...
	lxi	h,L31ec		;; 0abb: 21 ec 31    ..1
	mvi	b,001h		;; 0abe: 06 01       ..
	call	L1a2a		;; 0ac0: cd 2a 1a    .*.
	jmp	L0aa9		;; 0ac3: c3 a9 0a    ...

L0ac6:	call	L0afc		;; 0ac6: cd fc 0a    ...
	lxi	h,L31ec		;; 0ac9: 21 ec 31    ..1
	mvi	b,001h		;; 0acc: 06 01       ..
	call	L1a2a		;; 0ace: cd 2a 1a    .*.
L0ad1:	lhld	L31ed		;; 0ad1: 2a ed 31    *.1
	mov	a,m		;; 0ad4: 7e          ~
	mov	l,a		;; 0ad5: 6f          o
	add	a		;; 0ad6: 87          .
	sbb	a		;; 0ad7: 9f          .
	mov	h,a		;; 0ad8: 67          g
	lxi	d,L3151		;; 0ad9: 11 51 31    .Q1
	dad	d		;; 0adc: 19          .
	mov	a,m		;; 0add: 7e          ~
	sui	004h		;; 0ade: d6 04       ..
	jm	L0af1		;; 0ae0: fa f1 0a    ...
	call	L0afc		;; 0ae3: cd fc 0a    ...
	lxi	h,L31ec		;; 0ae6: 21 ec 31    ..1
	mvi	b,001h		;; 0ae9: 06 01       ..
	call	L1a2a		;; 0aeb: cd 2a 1a    .*.
	jmp	L0ad1		;; 0aee: c3 d1 0a    ...

L0af1:	jmp	L09c5		;; 0af1: c3 c5 09    ...

L0af4:	lhld	L3202		;; 0af4: 2a 02 32    *.2
	sphl			;; 0af7: f9          .
	call	L1bc6		;; 0af8: cd c6 1b    ...
	ret			;; 0afb: c9          .

L0afc:	lda	L31ef		;; 0afc: 3a ef 31    :.1
	ora	a		;; 0aff: b7          .
	jp	L0b20		;; 0b00: f2 20 0b    . .
	lxi	h,L31ef		;; 0b03: 21 ef 31    ..1
	mvi	m,000h		;; 0b06: 36 00       6.
	lxi	h,00011h	;; 0b08: 21 11 00    ...
	shld	L31dd		;; 0b0b: 22 dd 31    ".1
	lhld	L31e6		;; 0b0e: 2a e6 31    *.1
	mov	l,m		;; 0b11: 6e          n
	mvi	h,000h		;; 0b12: 26 00       &.
	shld	L31df		;; 0b14: 22 df 31    ".1
	lhld	L31e6		;; 0b17: 2a e6 31    *.1
	shld	L31e1		;; 0b1a: 22 e1 31    ".1
	jmp	L0b27		;; 0b1d: c3 27 0b    .'.

L0b20:	lhld	L31dd		;; 0b20: 2a dd 31    *.1
	inx	h		;; 0b23: 23          #
	shld	L31dd		;; 0b24: 22 dd 31    ".1
L0b27:	lhld	L31df		;; 0b27: 2a df 31    *.1
	xchg			;; 0b2a: eb          .
	lhld	L31dd		;; 0b2b: 2a dd 31    *.1
	call	L1b57		;; 0b2e: cd 57 1b    .W.
	jp	L0b37		;; 0b31: f2 37 0b    .7.
	jmp	L0af4		;; 0b34: c3 f4 0a    ...

L0b37:	lhld	L31e1		;; 0b37: 2a e1 31    *.1
	push	h		;; 0b3a: e5          .
	lhld	L31dd		;; 0b3b: 2a dd 31    *.1
	pop	d		;; 0b3e: d1          .
	dad	d		;; 0b3f: 19          .
	mvi	a,001h		;; 0b40: 3e 01       >.
	call	L1a17		;; 0b42: cd 17 1a    ...
	jmp	L1a93		;; 0b45: c3 93 1a    ...

L0b48:	lhld	L31ed		;; 0b48: 2a ed 31    *.1
	mov	a,m		;; 0b4b: 7e          ~
	mov	l,a		;; 0b4c: 6f          o
	add	a		;; 0b4d: 87          .
	sbb	a		;; 0b4e: 9f          .
	mov	h,a		;; 0b4f: 67          g
	lxi	b,0ff9fh	;; 0b50: 01 9f ff    ...
	dad	b		;; 0b53: 09          .
	mov	a,h		;; 0b54: 7c          |
	ora	a		;; 0b55: b7          .
	jm	L0b63		;; 0b56: fa 63 0b    .c.
	lxi	h,L31ec		;; 0b59: 21 ec 31    ..1
	mvi	a,0dfh		;; 0b5c: 3e df       >.
	ana	m		;; 0b5e: a6          .
	mov	m,a		;; 0b5f: 77          w
	jmp	L0b82		;; 0b60: c3 82 0b    ...

L0b63:	lxi	h,L31ec		;; 0b63: 21 ec 31    ..1
	mov	a,m		;; 0b66: 7e          ~
	sui	03fh		;; 0b67: d6 3f       .?
	jnz	L0b74		;; 0b69: c2 74 0b    .t.
	lxi	h,L31ec		;; 0b6c: 21 ec 31    ..1
	mvi	m,05fh		;; 0b6f: 36 5f       6_
	jmp	L0b82		;; 0b71: c3 82 0b    ...

L0b74:	lxi	h,L31ec		;; 0b74: 21 ec 31    ..1
	mov	a,m		;; 0b77: 7e          ~
	sui	040h		;; 0b78: d6 40       .@
	jnz	L0b82		;; 0b7a: c2 82 0b    ...
	lxi	h,L31ec		;; 0b7d: 21 ec 31    ..1
	mvi	m,060h		;; 0b80: 36 60       6`
L0b82:	ret			;; 0b82: c9          .

L0b83:	lxi	d,L3259		;; 0b83: 11 59 32    .Y2
	mvi	c,00ch		;; 0b86: 0e 0c       ..
L0b88:	mov	a,m		;; 0b88: 7e          ~
	inx	h		;; 0b89: 23          #
	stax	d		;; 0b8a: 12          .
	inx	d		;; 0b8b: 13          .
	dcr	c		;; 0b8c: 0d          .
	jnz	L0b88		;; 0b8d: c2 88 0b    ...
	lhld	L325f		;; 0b90: 2a 5f 32    *_2
	mov	e,m		;; 0b93: 5e          ^
	inx	h		;; 0b94: 23          #
	mov	d,m		;; 0b95: 56          V
	xchg			;; 0b96: eb          .
	shld	L3265		;; 0b97: 22 65 32    "e2
	lhld	L3263		;; 0b9a: 2a 63 32    *c2
	mov	e,m		;; 0b9d: 5e          ^
	inx	h		;; 0b9e: 23          #
	mov	d,m		;; 0b9f: 56          V
	xchg			;; 0ba0: eb          .
	shld	L3267		;; 0ba1: 22 67 32    "g2
	lxi	h,00001h	;; 0ba4: 21 01 00    ...
	shld	L32ea		;; 0ba7: 22 ea 32    ".2
	lhld	L325b		;; 0baa: 2a 5b 32    *[2
	mov	e,m		;; 0bad: 5e          ^
	inx	h		;; 0bae: 23          #
	mov	d,m		;; 0baf: 56          V
	xchg			;; 0bb0: eb          .
	shld	L32f1		;; 0bb1: 22 f1 32    ".2
L0bb4:	lhld	L32f1		;; 0bb4: 2a f1 32    *.2
	xchg			;; 0bb7: eb          .
	lhld	L32ea		;; 0bb8: 2a ea 32    *.2
	call	L1b57		;; 0bbb: cd 57 1b    .W.
	jm	L0cf4		;; 0bbe: fa f4 0c    ...
	lhld	L325d		;; 0bc1: 2a 5d 32    *]2
	lxi	d,0ffefh	;; 0bc4: 11 ef ff    ...
	dad	d		;; 0bc7: 19          .
	push	h		;; 0bc8: e5          .
	lhld	L32ea		;; 0bc9: 2a ea 32    *.2
	lxi	d,00011h	;; 0bcc: 11 11 00    ...
	call	L1aaf		;; 0bcf: cd af 1a    ...
	pop	d		;; 0bd2: d1          .
	dad	d		;; 0bd3: 19          .
	shld	L32f3		;; 0bd4: 22 f3 32    ".2
	lxi	h,L32f3		;; 0bd7: 21 f3 32    ..2
	call	L0cf5		;; 0bda: cd f5 0c    ...
	lda	L32f0		;; 0bdd: 3a f0 32    :.2
	ora	a		;; 0be0: b7          .
	jp	L0cea		;; 0be1: f2 ea 0c    ...
	lhld	L3265		;; 0be4: 2a 65 32    *e2
	push	h		;; 0be7: e5          .
	lhld	L32ec		;; 0be8: 2a ec 32    *.2
	dad	h		;; 0beb: 29          )
	dad	h		;; 0bec: 29          )
	dad	h		;; 0bed: 29          )
	pop	d		;; 0bee: d1          .
	dad	d		;; 0bef: 19          .
	mov	a,m		;; 0bf0: 7e          ~
	inx	h		;; 0bf1: 23          #
	ora	m		;; 0bf2: b6          .
	jnz	L0c12		;; 0bf3: c2 12 0c    ...
	lhld	L3267		;; 0bf6: 2a 67 32    *g2
	mov	e,m		;; 0bf9: 5e          ^
	inx	h		;; 0bfa: 23          #
	mov	d,m		;; 0bfb: 56          V
	xchg			;; 0bfc: eb          .
	inx	h		;; 0bfd: 23          #
	push	h		;; 0bfe: e5          .
	lhld	L3265		;; 0bff: 2a 65 32    *e2
	push	h		;; 0c02: e5          .
	lhld	L32ec		;; 0c03: 2a ec 32    *.2
	dad	h		;; 0c06: 29          )
	dad	h		;; 0c07: 29          )
	dad	h		;; 0c08: 29          )
	pop	d		;; 0c09: d1          .
	dad	d		;; 0c0a: 19          .
	pop	d		;; 0c0b: d1          .
	mov	m,e		;; 0c0c: 73          s
	inx	h		;; 0c0d: 23          #
	mov	m,d		;; 0c0e: 72          r
	jmp	L0c63		;; 0c0f: c3 63 0c    .c.

L0c12:	lhld	L3265		;; 0c12: 2a 65 32    *e2
	push	h		;; 0c15: e5          .
	lhld	L32ec		;; 0c16: 2a ec 32    *.2
	dad	h		;; 0c19: 29          )
	dad	h		;; 0c1a: 29          )
	dad	h		;; 0c1b: 29          )
	pop	d		;; 0c1c: d1          .
	dad	d		;; 0c1d: 19          .
	mov	e,m		;; 0c1e: 5e          ^
	inx	h		;; 0c1f: 23          #
	mov	d,m		;; 0c20: 56          V
	xchg			;; 0c21: eb          .
	shld	L32ee		;; 0c22: 22 ee 32    ".2
L0c25:	lhld	L3267		;; 0c25: 2a 67 32    *g2
	push	h		;; 0c28: e5          .
	lhld	L32ee		;; 0c29: 2a ee 32    *.2
	dad	h		;; 0c2c: 29          )
	dad	h		;; 0c2d: 29          )
	pop	d		;; 0c2e: d1          .
	dad	d		;; 0c2f: 19          .
	mov	a,m		;; 0c30: 7e          ~
	inx	h		;; 0c31: 23          #
	ora	m		;; 0c32: b6          .
	jz	L0c4b		;; 0c33: ca 4b 0c    .K.
	lhld	L3267		;; 0c36: 2a 67 32    *g2
	push	h		;; 0c39: e5          .
	lhld	L32ee		;; 0c3a: 2a ee 32    *.2
	dad	h		;; 0c3d: 29          )
	dad	h		;; 0c3e: 29          )
	pop	d		;; 0c3f: d1          .
	dad	d		;; 0c40: 19          .
	mov	e,m		;; 0c41: 5e          ^
	inx	h		;; 0c42: 23          #
	mov	d,m		;; 0c43: 56          V
	xchg			;; 0c44: eb          .
	shld	L32ee		;; 0c45: 22 ee 32    ".2
	jmp	L0c25		;; 0c48: c3 25 0c    .%.

L0c4b:	lhld	L3267		;; 0c4b: 2a 67 32    *g2
	mov	e,m		;; 0c4e: 5e          ^
	inx	h		;; 0c4f: 23          #
	mov	d,m		;; 0c50: 56          V
	xchg			;; 0c51: eb          .
	inx	h		;; 0c52: 23          #
	push	h		;; 0c53: e5          .
	lhld	L3267		;; 0c54: 2a 67 32    *g2
	push	h		;; 0c57: e5          .
	lhld	L32ee		;; 0c58: 2a ee 32    *.2
	dad	h		;; 0c5b: 29          )
	dad	h		;; 0c5c: 29          )
	pop	d		;; 0c5d: d1          .
	dad	d		;; 0c5e: 19          .
	pop	d		;; 0c5f: d1          .
	mov	m,e		;; 0c60: 73          s
	inx	h		;; 0c61: 23          #
	mov	m,d		;; 0c62: 72          r
L0c63:	lhld	L3267		;; 0c63: 2a 67 32    *g2
	mov	e,m		;; 0c66: 5e          ^
	inx	h		;; 0c67: 23          #
	mov	d,m		;; 0c68: 56          V
	xchg			;; 0c69: eb          .
	inx	h		;; 0c6a: 23          #
	xchg			;; 0c6b: eb          .
	mov	m,d		;; 0c6c: 72          r
	dcx	h		;; 0c6d: 2b          +
	mov	m,e		;; 0c6e: 73          s
	lhld	L3261		;; 0c6f: 2a 61 32    *a2
	mov	e,m		;; 0c72: 5e          ^
	inx	h		;; 0c73: 23          #
	mov	d,m		;; 0c74: 56          V
	xchg			;; 0c75: eb          .
	push	h		;; 0c76: e5          .
	lhld	L3267		;; 0c77: 2a 67 32    *g2
	mov	e,m		;; 0c7a: 5e          ^
	inx	h		;; 0c7b: 23          #
	mov	d,m		;; 0c7c: 56          V
	xchg			;; 0c7d: eb          .
	pop	d		;; 0c7e: d1          .
	call	L1b57		;; 0c7f: cd 57 1b    .W.
	jp	L0c9b		;; 0c82: f2 9b 0c    ...
	lxi	h,L3269		;; 0c85: 21 69 32    .i2
	lxi	d,L3237		;; 0c88: 11 37 32    .72
	mvi	a,080h		;; 0c8b: 3e 80       >.
	mvi	b,021h		;; 0c8d: 06 21       ..
	call	L1a63		;; 0c8f: cd 63 1a    .c.
	lxi	h,L32f9		;; 0c92: 21 f9 32    ..2
	call	L14b7		;; 0c95: cd b7 14    ...
	call	L157e		;; 0c98: cd 7e 15    .~.
L0c9b:	lhld	L32ea		;; 0c9b: 2a ea 32    *.2
	dcx	h		;; 0c9e: 2b          +
	mov	a,h		;; 0c9f: 7c          |
	ora	l		;; 0ca0: b5          .
	jnz	L0cb4		;; 0ca1: c2 b4 0c    ...
	lhld	L3259		;; 0ca4: 2a 59 32    *Y2
	mov	e,m		;; 0ca7: 5e          ^
	inx	h		;; 0ca8: 23          #
	mov	d,m		;; 0ca9: 56          V
	xchg			;; 0caa: eb          .
	call	L1b4f		;; 0cab: cd 4f 1b    .O.
	shld	L32ee		;; 0cae: 22 ee 32    ".2
	jmp	L0cbe		;; 0cb1: c3 be 0c    ...

L0cb4:	lhld	L3259		;; 0cb4: 2a 59 32    *Y2
	mov	e,m		;; 0cb7: 5e          ^
	inx	h		;; 0cb8: 23          #
	mov	d,m		;; 0cb9: 56          V
	xchg			;; 0cba: eb          .
	shld	L32ee		;; 0cbb: 22 ee 32    ".2
L0cbe:	lhld	L32ee		;; 0cbe: 2a ee 32    *.2
	push	h		;; 0cc1: e5          .
	lhld	L3267		;; 0cc2: 2a 67 32    *g2
	dcx	h		;; 0cc5: 2b          +
	dcx	h		;; 0cc6: 2b          +
	push	h		;; 0cc7: e5          .
	lhld	L3267		;; 0cc8: 2a 67 32    *g2
	mov	e,m		;; 0ccb: 5e          ^
	inx	h		;; 0ccc: 23          #
	mov	d,m		;; 0ccd: 56          V
	xchg			;; 0cce: eb          .
	dad	h		;; 0ccf: 29          )
	dad	h		;; 0cd0: 29          )
	pop	d		;; 0cd1: d1          .
	dad	d		;; 0cd2: 19          .
	pop	d		;; 0cd3: d1          .
	mov	m,e		;; 0cd4: 73          s
	inx	h		;; 0cd5: 23          #
	mov	m,d		;; 0cd6: 72          r
	lhld	L3267		;; 0cd7: 2a 67 32    *g2
	push	h		;; 0cda: e5          .
	lhld	L3267		;; 0cdb: 2a 67 32    *g2
	mov	e,m		;; 0cde: 5e          ^
	inx	h		;; 0cdf: 23          #
	mov	d,m		;; 0ce0: 56          V
	xchg			;; 0ce1: eb          .
	dad	h		;; 0ce2: 29          )
	dad	h		;; 0ce3: 29          )
	pop	d		;; 0ce4: d1          .
	dad	d		;; 0ce5: 19          .
	xra	a		;; 0ce6: af          .
	mov	m,a		;; 0ce7: 77          w
	inx	h		;; 0ce8: 23          #
	mov	m,a		;; 0ce9: 77          w
L0cea:	lhld	L32ea		;; 0cea: 2a ea 32    *.2
	inx	h		;; 0ced: 23          #
	shld	L32ea		;; 0cee: 22 ea 32    ".2
	jmp	L0bb4		;; 0cf1: c3 b4 0b    ...

L0cf4:	ret			;; 0cf4: c9          .

L0cf5:	lxi	d,L32fb		;; 0cf5: 11 fb 32    ..2
	mvi	c,006h		;; 0cf8: 0e 06       ..
L0cfa:	mov	a,m		;; 0cfa: 7e          ~
	inx	h		;; 0cfb: 23          #
	stax	d		;; 0cfc: 12          .
	inx	d		;; 0cfd: 13          .
	dcr	c		;; 0cfe: 0d          .
	jnz	L0cfa		;; 0cff: c2 fa 0c    ...
	lhld	L32fd		;; 0d02: 2a fd 32    *.2
	mvi	m,000h		;; 0d05: 36 00       6.
	lhld	L32fb		;; 0d07: 2a fb 32    *.2
	mvi	e,002h		;; 0d0a: 1e 02       ..
	mvi	c,001h		;; 0d0c: 0e 01       ..
	call	L194c		;; 0d0e: cd 4c 19    .L.
	xchg			;; 0d11: eb          .
	mov	b,a		;; 0d12: 47          G
	lxi	h,L3258		;; 0d13: 21 58 32    .X2
	mvi	a,001h		;; 0d16: 3e 01       >.
	call	L1979		;; 0d18: cd 79 19    .y.
	jnz	L0d43		;; 0d1b: c2 43 0d    .C.
	lhld	L32fb		;; 0d1e: 2a fb 32    *.2
	shld	L3301		;; 0d21: 22 01 33    ".3
	lhld	L3301		;; 0d24: 2a 01 33    *.3
	inx	h		;; 0d27: 23          #
	mov	a,m		;; 0d28: 7e          ~
	push	psw		;; 0d29: f5          .
	mvi	a,00fh		;; 0d2a: 3e 0f       >.
	pop	b		;; 0d2c: c1          .
	ana	b		;; 0d2d: a0          .
	lxi	h,L3305		;; 0d2e: 21 05 33    ..3
	mov	m,a		;; 0d31: 77          w
	lda	L3305		;; 0d32: 3a 05 33    :.3
	mov	l,a		;; 0d35: 6f          o
	add	a		;; 0d36: 87          .
	sbb	a		;; 0d37: 9f          .
	mov	h,a		;; 0d38: 67          g
	lxi	d,L3204		;; 0d39: 11 04 32    ..2
	dad	d		;; 0d3c: 19          .
	mov	a,m		;; 0d3d: 7e          ~
	ora	a		;; 0d3e: b7          .
	jp	L0d43		;; 0d3f: f2 43 0d    .C.
	ret			;; 0d42: c9          .

L0d43:	lda	L3214		;; 0d43: 3a 14 32    :.2
	ora	a		;; 0d46: b7          .
	jp	L0dac		;; 0d47: f2 ac 0d    ...
	lxi	h,L3214		;; 0d4a: 21 14 32    ..2
	mvi	m,000h		;; 0d4d: 36 00       6.
	lhld	L3265		;; 0d4f: 2a 65 32    *e2
	mov	e,m		;; 0d52: 5e          ^
	inx	h		;; 0d53: 23          #
	mov	d,m		;; 0d54: 56          V
	xchg			;; 0d55: eb          .
	inx	h		;; 0d56: 23          #
	shld	L3307		;; 0d57: 22 07 33    ".3
	lxi	h,L3307		;; 0d5a: 21 07 33    ..3
	shld	L3301		;; 0d5d: 22 01 33    ".3
	xra	a		;; 0d60: af          .
	sta	L3305		;; 0d61: 32 05 33    2.3
L0d64:	lxi	h,L3305		;; 0d64: 21 05 33    ..3
	mvi	a,010h		;; 0d67: 3e 10       >.
	sub	m		;; 0d69: 96          .
	jm	L0dac		;; 0d6a: fa ac 0d    ...
	lhld	L3307		;; 0d6d: 2a 07 33    *.3
	dcx	h		;; 0d70: 2b          +
	dcx	h		;; 0d71: 2b          +
	mov	a,h		;; 0d72: 7c          |
	ora	a		;; 0d73: b7          .
	jp	L0d80		;; 0d74: f2 80 0d    ...
	lxi	h,00001h	;; 0d77: 21 01 00    ...
	shld	L3307		;; 0d7a: 22 07 33    ".3
	jmp	L0d91		;; 0d7d: c3 91 0d    ...

L0d80:	lhld	L3307		;; 0d80: 2a 07 33    *.3
	mvi	a,002h		;; 0d83: 3e 02       >.
	push	h		;; 0d85: e5          .
	mov	l,a		;; 0d86: 6f          o
	add	a		;; 0d87: 87          .
	sbb	a		;; 0d88: 9f          .
	mov	h,a		;; 0d89: 67          g
	pop	d		;; 0d8a: d1          .
	call	L1b11		;; 0d8b: cd 11 1b    ...
	shld	L3307		;; 0d8e: 22 07 33    ".3
L0d91:	lhld	L3307		;; 0d91: 2a 07 33    *.3
	lda	L3305		;; 0d94: 3a 05 33    :.3
	push	h		;; 0d97: e5          .
	mov	l,a		;; 0d98: 6f          o
	add	a		;; 0d99: 87          .
	sbb	a		;; 0d9a: 9f          .
	mov	h,a		;; 0d9b: 67          g
	dad	h		;; 0d9c: 29          )
	lxi	d,L3215		;; 0d9d: 11 15 32    ..2
	dad	d		;; 0da0: 19          .
	pop	d		;; 0da1: d1          .
	mov	m,e		;; 0da2: 73          s
	inx	h		;; 0da3: 23          #
	mov	m,d		;; 0da4: 72          r
	lxi	h,L3305		;; 0da5: 21 05 33    ..3
	inr	m		;; 0da8: 34          4
	jmp	L0d64		;; 0da9: c3 64 0d    .d.

L0dac:	lxi	h,00001h	;; 0dac: 21 01 00    ...
	shld	L330b		;; 0daf: 22 0b 33    ".3
	lhld	L3265		;; 0db2: 2a 65 32    *e2
	mov	e,m		;; 0db5: 5e          ^
	inx	h		;; 0db6: 23          #
	mov	d,m		;; 0db7: 56          V
	xchg			;; 0db8: eb          .
	shld	L3309		;; 0db9: 22 09 33    ".3
	xra	a		;; 0dbc: af          .
	sta	L3305		;; 0dbd: 32 05 33    2.3
	lhld	L3215		;; 0dc0: 2a 15 32    *.2
	shld	L3307		;; 0dc3: 22 07 33    ".3
	lxi	h,L3307		;; 0dc6: 21 07 33    ..3
	shld	L3301		;; 0dc9: 22 01 33    ".3
L0dcc:	lhld	L330b		;; 0dcc: 2a 0b 33    *.3
	xchg			;; 0dcf: eb          .
	lhld	L3309		;; 0dd0: 2a 09 33    *.3
	call	L1b57		;; 0dd3: cd 57 1b    .W.
	jp	L0e5f		;; 0dd6: f2 5f 0e    ._.
	lxi	h,L3305		;; 0dd9: 21 05 33    ..3
	inr	m		;; 0ddc: 34          4
	lda	L3305		;; 0ddd: 3a 05 33    :.3
	mov	l,a		;; 0de0: 6f          o
	add	a		;; 0de1: 87          .
	sbb	a		;; 0de2: 9f          .
	mov	h,a		;; 0de3: 67          g
	dad	h		;; 0de4: 29          )
	lxi	d,L3215		;; 0de5: 11 15 32    ..2
	dad	d		;; 0de8: 19          .
	mov	e,m		;; 0de9: 5e          ^
	inx	h		;; 0dea: 23          #
	mov	d,m		;; 0deb: 56          V
	xchg			;; 0dec: eb          .
	shld	L330d		;; 0ded: 22 0d 33    ".3
	lhld	L3265		;; 0df0: 2a 65 32    *e2
	lxi	d,0fffah	;; 0df3: 11 fa ff    ...
	dad	d		;; 0df6: 19          .
	push	h		;; 0df7: e5          .
	lhld	L3307		;; 0df8: 2a 07 33    *.3
	dad	h		;; 0dfb: 29          )
	dad	h		;; 0dfc: 29          )
	dad	h		;; 0dfd: 29          )
	pop	d		;; 0dfe: d1          .
	dad	d		;; 0dff: 19          .
	mov	e,m		;; 0e00: 5e          ^
	inx	h		;; 0e01: 23          #
	mov	d,m		;; 0e02: 56          V
	xchg			;; 0e03: eb          .
	shld	L3303		;; 0e04: 22 03 33    ".3
	lhld	L32fb		;; 0e07: 2a fb 32    *.2
	push	h		;; 0e0a: e5          .
	lhld	L3303		;; 0e0b: 2a 03 33    *.3
	pop	d		;; 0e0e: d1          .
	call	L196a		;; 0e0f: cd 6a 19    .j.
	jnc	L0e2f		;; 0e12: d2 2f 0e    ./.
	lhld	L3307		;; 0e15: 2a 07 33    *.3
	dcx	h		;; 0e18: 2b          +
	shld	L3309		;; 0e19: 22 09 33    ".3
	lhld	L330b		;; 0e1c: 2a 0b 33    *.3
	xchg			;; 0e1f: eb          .
	lhld	L330d		;; 0e20: 2a 0d 33    *.3
	dad	d		;; 0e23: 19          .
	shld	L3307		;; 0e24: 22 07 33    ".3
	lxi	h,L3306		;; 0e27: 21 06 33    ..3
	mvi	m,080h		;; 0e2a: 36 80       6.
	jmp	L0e5c		;; 0e2c: c3 5c 0e    .\.

L0e2f:	lhld	L3303		;; 0e2f: 2a 03 33    *.3
	push	h		;; 0e32: e5          .
	lhld	L32fb		;; 0e33: 2a fb 32    *.2
	pop	d		;; 0e36: d1          .
	call	L196a		;; 0e37: cd 6a 19    .j.
	jnc	L0e59		;; 0e3a: d2 59 0e    .Y.
	lhld	L3307		;; 0e3d: 2a 07 33    *.3
	inx	h		;; 0e40: 23          #
	shld	L330b		;; 0e41: 22 0b 33    ".3
	lhld	L3309		;; 0e44: 2a 09 33    *.3
	xchg			;; 0e47: eb          .
	lhld	L330d		;; 0e48: 2a 0d 33    *.3
	call	L1b57		;; 0e4b: cd 57 1b    .W.
	shld	L3307		;; 0e4e: 22 07 33    ".3
	lxi	h,L3306		;; 0e51: 21 06 33    ..3
	mvi	m,000h		;; 0e54: 36 00       6.
	jmp	L0e5c		;; 0e56: c3 5c 0e    .\.

L0e59:	jmp	L0e9b		;; 0e59: c3 9b 0e    ...

L0e5c:	jmp	L0dcc		;; 0e5c: c3 cc 0d    ...

L0e5f:	lda	L3306		;; 0e5f: 3a 06 33    :.3
	ora	a		;; 0e62: b7          .
	jp	L0e6f		;; 0e63: f2 6f 0e    .o.
	lhld	L3309		;; 0e66: 2a 09 33    *.3
	shld	L3307		;; 0e69: 22 07 33    ".3
	jmp	L0e75		;; 0e6c: c3 75 0e    .u.

L0e6f:	lhld	L330b		;; 0e6f: 2a 0b 33    *.3
	shld	L3307		;; 0e72: 22 07 33    ".3
L0e75:	lhld	L3265		;; 0e75: 2a 65 32    *e2
	lxi	d,0fffah	;; 0e78: 11 fa ff    ...
	dad	d		;; 0e7b: 19          .
	push	h		;; 0e7c: e5          .
	lhld	L3307		;; 0e7d: 2a 07 33    *.3
	dad	h		;; 0e80: 29          )
	dad	h		;; 0e81: 29          )
	dad	h		;; 0e82: 29          )
	pop	d		;; 0e83: d1          .
	dad	d		;; 0e84: 19          .
	mov	e,m		;; 0e85: 5e          ^
	inx	h		;; 0e86: 23          #
	mov	d,m		;; 0e87: 56          V
	xchg			;; 0e88: eb          .
	shld	L3303		;; 0e89: 22 03 33    ".3
	lhld	L32fb		;; 0e8c: 2a fb 32    *.2
	push	h		;; 0e8f: e5          .
	lhld	L3303		;; 0e90: 2a 03 33    *.3
	pop	d		;; 0e93: d1          .
	call	L196a		;; 0e94: cd 6a 19    .j.
	jz	L0e9b		;; 0e97: ca 9b 0e    ...
	ret			;; 0e9a: c9          .

L0e9b:	lhld	L32fd		;; 0e9b: 2a fd 32    *.2
	mvi	m,080h		;; 0e9e: 36 80       6.
	lhld	L3307		;; 0ea0: 2a 07 33    *.3
	push	h		;; 0ea3: e5          .
	lhld	L32ff		;; 0ea4: 2a ff 32    *.2
	pop	d		;; 0ea7: d1          .
	mov	m,e		;; 0ea8: 73          s
	inx	h		;; 0ea9: 23          #
	mov	m,d		;; 0eaa: 72          r
	ret			;; 0eab: c9          .

L0eac:	lxi	d,L3319		;; 0eac: 11 19 33    ..3
	mvi	c,00ah		;; 0eaf: 0e 0a       ..
L0eb1:	mov	a,m		;; 0eb1: 7e          ~
	inx	h		;; 0eb2: 23          #
	stax	d		;; 0eb3: 12          .
	inx	d		;; 0eb4: 13          .
	dcr	c		;; 0eb5: 0d          .
	jnz	L0eb1		;; 0eb6: c2 b1 0e    ...
	lhld	L331f		;; 0eb9: 2a 1f 33    *.3
	mov	e,m		;; 0ebc: 5e          ^
	inx	h		;; 0ebd: 23          #
	mov	d,m		;; 0ebe: 56          V
	xchg			;; 0ebf: eb          .
	shld	L3323		;; 0ec0: 22 23 33    "#3
	lhld	L3321		;; 0ec3: 2a 21 33    *.3
	mov	e,m		;; 0ec6: 5e          ^
	inx	h		;; 0ec7: 23          #
	mov	d,m		;; 0ec8: 56          V
	xchg			;; 0ec9: eb          .
	shld	L3325		;; 0eca: 22 25 33    "%3
	lxi	h,000ffh	;; 0ecd: 21 ff 00    ...
	xra	a		;; 0ed0: af          .
	call	L200c		;; 0ed1: cd 0c 20    .. 
	jmp	L0fb7		;; 0ed4: c3 b7 0f    ...

	mvi	a,001h		;; 0ed7: 3e 01       >.
	sta	L332e		;; 0ed9: 32 2e 33    2.3
	lhld	L3319		;; 0edc: 2a 19 33    *.3
	mov	a,m		;; 0edf: 7e          ~
	ora	a		;; 0ee0: b7          .
	jz	L0f9f		;; 0ee1: ca 9f 0f    ...
	lhld	L3319		;; 0ee4: 2a 19 33    *.3
	inr	m		;; 0ee7: 34          4
	lhld	L3319		;; 0ee8: 2a 19 33    *.3
	mov	a,m		;; 0eeb: 7e          ~
	mov	l,a		;; 0eec: 6f          o
	add	a		;; 0eed: 87          .
	sbb	a		;; 0eee: 9f          .
	mov	h,a		;; 0eef: 67          g
	shld	L3395		;; 0ef0: 22 95 33    ".3
	lxi	h,L3393		;; 0ef3: 21 93 33    ..3
	call	L0941		;; 0ef6: cd 41 09    .A.
	lxi	h,L332f		;; 0ef9: 21 2f 33    ./3
	mvi	b,006h		;; 0efc: 06 06       ..
	call	L1a2a		;; 0efe: cd 2a 1a    .*.
	lxi	h,L332f		;; 0f01: 21 2f 33    ./3
	mvi	e,004h		;; 0f04: 1e 04       ..
	mvi	c,001h		;; 0f06: 0e 01       ..
	mvi	a,006h		;; 0f08: 3e 06       >.
	call	L1958		;; 0f0a: cd 58 19    .X.
	xchg			;; 0f0d: eb          .
	mov	b,a		;; 0f0e: 47          G
	lxi	h,L3313		;; 0f0f: 21 13 33    ..3
	mvi	a,001h		;; 0f12: 3e 01       >.
	call	L1979		;; 0f14: cd 79 19    .y.
	jnz	L0f2e		;; 0f17: c2 2e 0f    ...
	lxi	h,L332f		;; 0f1a: 21 2f 33    ./3
	mvi	e,004h		;; 0f1d: 1e 04       ..
	mvi	c,001h		;; 0f1f: 0e 01       ..
	mvi	a,006h		;; 0f21: 3e 06       >.
	call	L1958		;; 0f23: cd 58 19    .X.
	lxi	d,L3314		;; 0f26: 11 14 33    ..3
	mvi	b,001h		;; 0f29: 06 01       ..
	call	L1a74		;; 0f2b: cd 74 1a    .t.
L0f2e:	lxi	h,L332f		;; 0f2e: 21 2f 33    ./3
	mvi	e,005h		;; 0f31: 1e 05       ..
	mvi	c,001h		;; 0f33: 0e 01       ..
	mvi	a,006h		;; 0f35: 3e 06       >.
	call	L1958		;; 0f37: cd 58 19    .X.
	xchg			;; 0f3a: eb          .
	mov	b,a		;; 0f3b: 47          G
	lxi	h,L3313		;; 0f3c: 21 13 33    ..3
	mvi	a,001h		;; 0f3f: 3e 01       >.
	call	L1979		;; 0f41: cd 79 19    .y.
	jnz	L0f5b		;; 0f44: c2 5b 0f    .[.
	lxi	h,L332f		;; 0f47: 21 2f 33    ./3
	mvi	e,005h		;; 0f4a: 1e 05       ..
	mvi	c,001h		;; 0f4c: 0e 01       ..
	mvi	a,006h		;; 0f4e: 3e 06       >.
	call	L1958		;; 0f50: cd 58 19    .X.
	lxi	d,L3314		;; 0f53: 11 14 33    ..3
	mvi	b,001h		;; 0f56: 06 01       ..
	call	L1a74		;; 0f58: cd 74 1a    .t.
L0f5b:	lhld	L331d		;; 0f5b: 2a 1d 33    *.3
	xchg			;; 0f5e: eb          .
	lxi	h,L3315		;; 0f5f: 21 15 33    ..3
	mvi	a,001h		;; 0f62: 3e 01       >.
	call	L1700		;; 0f64: cd 00 17    ...
	mov	a,l		;; 0f67: 7d          }
	sta	L3392		;; 0f68: 32 92 33    2.3
	lda	L3392		;; 0f6b: 3a 92 33    :.3
	ora	a		;; 0f6e: b7          .
	jz	L0f90		;; 0f6f: ca 90 0f    ...
	lxi	h,L332f		;; 0f72: 21 2f 33    ./3
	mvi	e,004h		;; 0f75: 1e 04       ..
	mvi	a,006h		;; 0f77: 3e 06       >.
	call	L1953		;; 0f79: cd 53 19    .S.
	push	h		;; 0f7c: e5          .
	lhld	L331d		;; 0f7d: 2a 1d 33    *.3
	push	psw		;; 0f80: f5          .
	lda	L3392		;; 0f81: 3a 92 33    :.3
	inr	a		;; 0f84: 3c          <
	mov	e,a		;; 0f85: 5f          _
	mvi	c,003h		;; 0f86: 0e 03       ..
	call	L194c		;; 0f88: cd 4c 19    .L.
	pop	b		;; 0f8b: c1          .
	pop	d		;; 0f8c: d1          .
	call	L1a74		;; 0f8d: cd 74 1a    .t.
L0f90:	lhld	L331d		;; 0f90: 2a 1d 33    *.3
	shld	L3397		;; 0f93: 22 97 33    ".3
	lxi	h,L3397		;; 0f96: 21 97 33    ..3
	call	L11fa		;; 0f99: cd fa 11    ...
	jmp	L0fb6		;; 0f9c: c3 b6 0f    ...

L0f9f:	lhld	L331d		;; 0f9f: 2a 1d 33    *.3
	lxi	d,L3311		;; 0fa2: 11 11 33    ..3
	mvi	a,080h		;; 0fa5: 3e 80       >.
	call	L1a5f		;; 0fa7: cd 5f 1a    ._.
	lhld	L331d		;; 0faa: 2a 1d 33    *.3
	shld	L3399		;; 0fad: 22 99 33    ".3
	lxi	h,L3399		;; 0fb0: 21 99 33    ..3
	call	L11fa		;; 0fb3: cd fa 11    ...
L0fb6:	ret			;; 0fb6: c9          .

L0fb7:	lxi	h,L333b		;; 0fb7: 21 3b 33    .;3
	shld	L3339		;; 0fba: 22 39 33    "93
	lxi	h,L3316		;; 0fbd: 21 16 33    ..3
	push	h		;; 0fc0: e5          .
	lhld	L331d		;; 0fc1: 2a 1d 33    *.3
	pop	d		;; 0fc4: d1          .
	mvi	b,080h		;; 0fc5: 06 80       ..
	mvi	a,001h		;; 0fc7: 3e 01       >.
	call	L19c1		;; 0fc9: cd c1 19    ...
	lxi	h,000ffh	;; 0fcc: 21 ff 00    ...
	xra	a		;; 0fcf: af          .
	call	L1d74		;; 0fd0: cd 74 1d    .t.
	lxi	h,L333c		;; 0fd3: 21 3c 33    .<3
	shld	L3335		;; 0fd6: 22 35 33    "53
	lxi	h,L334c		;; 0fd9: 21 4c 33    .L3
	lxi	d,L3313		;; 0fdc: 11 13 33    ..3
	mvi	a,001h		;; 0fdf: 3e 01       >.
	mov	b,a		;; 0fe1: 47          G
	call	L1a74		;; 0fe2: cd 74 1a    .t.
	lxi	h,L3351		;; 0fe5: 21 51 33    .Q3
	lxi	d,L3313		;; 0fe8: 11 13 33    ..3
	mvi	a,001h		;; 0feb: 3e 01       >.
	mov	b,a		;; 0fed: 47          G
	call	L1a74		;; 0fee: cd 74 1a    .t.
	lxi	h,0		;; 0ff1: 21 00 00    ...
	shld	L3327		;; 0ff4: 22 27 33    "'3
	xra	a		;; 0ff7: af          .
	sta	L332e		;; 0ff8: 32 2e 33    2.3
L0ffb:	lhld	L3327		;; 0ffb: 2a 27 33    *'3
	push	h		;; 0ffe: e5          .
	lhld	L3323		;; 0fff: 2a 23 33    *#3
	mov	e,m		;; 1002: 5e          ^
	inx	h		;; 1003: 23          #
	mov	d,m		;; 1004: 56          V
	xchg			;; 1005: eb          .
	pop	d		;; 1006: d1          .
	call	L1b57		;; 1007: cd 57 1b    .W.
	jp	L119c		;; 100a: f2 9c 11    ...
	lhld	L3327		;; 100d: 2a 27 33    *'3
	inx	h		;; 1010: 23          #
	shld	L3327		;; 1011: 22 27 33    "'3
	lhld	L3323		;; 1014: 2a 23 33    *#3
	lxi	d,0fffah	;; 1017: 11 fa ff    ...
	dad	d		;; 101a: 19          .
	push	h		;; 101b: e5          .
	lhld	L3327		;; 101c: 2a 27 33    *'3
	dad	h		;; 101f: 29          )
	dad	h		;; 1020: 29          )
	dad	h		;; 1021: 29          )
	pop	d		;; 1022: d1          .
	dad	d		;; 1023: 19          .
	mov	e,m		;; 1024: 5e          ^
	inx	h		;; 1025: 23          #
	mov	d,m		;; 1026: 56          V
	xchg			;; 1027: eb          .
	push	h		;; 1028: e5          .
	lxi	h,L333c		;; 1029: 21 3c 33    .<3
	pop	d		;; 102c: d1          .
	mvi	a,010h		;; 102d: 3e 10       >.
	call	L1a70		;; 102f: cd 70 1a    .p.
	lxi	h,00001h	;; 1032: 21 01 00    ...
	shld	L3329		;; 1035: 22 29 33    ")3
L1038:	lhld	L3329		;; 1038: 2a 29 33    *)3
	lxi	b,0ffefh	;; 103b: 01 ef ff    ...
	dad	b		;; 103e: 09          .
	mov	a,h		;; 103f: 7c          |
	ora	a		;; 1040: b7          .
	jp	L1086		;; 1041: f2 86 10    ...
	lhld	L3335		;; 1044: 2a 35 33    *53
	dcx	h		;; 1047: 2b          +
	push	h		;; 1048: e5          .
	lhld	L3329		;; 1049: 2a 29 33    *)3
	pop	d		;; 104c: d1          .
	dad	d		;; 104d: 19          .
	shld	L3337		;; 104e: 22 37 33    "73
	lhld	L3337		;; 1051: 2a 37 33    *73
	mov	a,m		;; 1054: 7e          ~
	sui	020h		;; 1055: d6 20       . 
	jnz	L105d		;; 1057: c2 5d 10    .].
	jmp	L1086		;; 105a: c3 86 10    ...

L105d:	lhld	L3337		;; 105d: 2a 37 33    *73
	mov	a,m		;; 1060: 7e          ~
	sui	05fh		;; 1061: d6 5f       ._
	jnz	L106e		;; 1063: c2 6e 10    .n.
	lhld	L3337		;; 1066: 2a 37 33    *73
	mvi	m,03fh		;; 1069: 36 3f       6?
	jmp	L107c		;; 106b: c3 7c 10    .|.

L106e:	lhld	L3337		;; 106e: 2a 37 33    *73
	mov	a,m		;; 1071: 7e          ~
	sui	060h		;; 1072: d6 60       .`
	jnz	L107c		;; 1074: c2 7c 10    .|.
	lhld	L3337		;; 1077: 2a 37 33    *73
	mvi	m,040h		;; 107a: 36 40       6@
L107c:	lhld	L3329		;; 107c: 2a 29 33    *)3
	inx	h		;; 107f: 23          #
	shld	L3329		;; 1080: 22 29 33    ")3
	jmp	L1038		;; 1083: c3 38 10    .8.

L1086:	lhld	L3323		;; 1086: 2a 23 33    *#3
	lxi	d,0fffch	;; 1089: 11 fc ff    ...
	dad	d		;; 108c: 19          .
	push	h		;; 108d: e5          .
	lhld	L3327		;; 108e: 2a 27 33    *'3
	dad	h		;; 1091: 29          )
	dad	h		;; 1092: 29          )
	dad	h		;; 1093: 29          )
	pop	d		;; 1094: d1          .
	dad	d		;; 1095: 19          .
	push	h		;; 1096: e5          .
	lxi	h,L334d		;; 1097: 21 4d 33    .M3
	pop	d		;; 109a: d1          .
	mvi	a,004h		;; 109b: 3e 04       >.
	mov	b,a		;; 109d: 47          G
	call	L1a74		;; 109e: cd 74 1a    .t.
	lhld	L3323		;; 10a1: 2a 23 33    *#3
	push	h		;; 10a4: e5          .
	lhld	L3327		;; 10a5: 2a 27 33    *'3
	dad	h		;; 10a8: 29          )
	dad	h		;; 10a9: 29          )
	dad	h		;; 10aa: 29          )
	pop	d		;; 10ab: d1          .
	dad	d		;; 10ac: 19          .
	mov	e,m		;; 10ad: 5e          ^
	inx	h		;; 10ae: 23          #
	mov	d,m		;; 10af: 56          V
	xchg			;; 10b0: eb          .
	shld	L3329		;; 10b1: 22 29 33    ")3
	xra	a		;; 10b4: af          .
	sta	L332d		;; 10b5: 32 2d 33    2-3
L10b8:	lxi	h,L3329		;; 10b8: 21 29 33    .)3
	mov	a,m		;; 10bb: 7e          ~
	inx	h		;; 10bc: 23          #
	ora	m		;; 10bd: b6          .
	jz	L1196		;; 10be: ca 96 11    ...
	lda	L332d		;; 10c1: 3a 2d 33    :-3
	sui	00ah		;; 10c4: d6 0a       ..
	jnz	L10ea		;; 10c6: c2 ea 10    ...
	call	L119f		;; 10c9: cd 9f 11    ...
	lxi	h,L333c		;; 10cc: 21 3c 33    .<3
	lxi	d,L3313		;; 10cf: 11 13 33    ..3
	mvi	a,010h		;; 10d2: 3e 10       >.
	mvi	b,001h		;; 10d4: 06 01       ..
	call	L1a74		;; 10d6: cd 74 1a    .t.
	lxi	h,L334d		;; 10d9: 21 4d 33    .M3
	lxi	d,L3313		;; 10dc: 11 13 33    ..3
	mvi	a,004h		;; 10df: 3e 04       >.
	mvi	b,001h		;; 10e1: 06 01       ..
	call	L1a74		;; 10e3: cd 74 1a    .t.
	xra	a		;; 10e6: af          .
	sta	L332d		;; 10e7: 32 2d 33    2-3
L10ea:	lxi	h,L332d		;; 10ea: 21 2d 33    .-3
	inr	m		;; 10ed: 34          4
	lhld	L3325		;; 10ee: 2a 25 33    *%3
	dcx	h		;; 10f1: 2b          +
	dcx	h		;; 10f2: 2b          +
	push	h		;; 10f3: e5          .
	lhld	L3329		;; 10f4: 2a 29 33    *)3
	dad	h		;; 10f7: 29          )
	dad	h		;; 10f8: 29          )
	pop	d		;; 10f9: d1          .
	dad	d		;; 10fa: 19          .
	mov	e,m		;; 10fb: 5e          ^
	inx	h		;; 10fc: 23          #
	mov	d,m		;; 10fd: 56          V
	xchg			;; 10fe: eb          .
	shld	L332b		;; 10ff: 22 2b 33    "+3
	lda	L332c		;; 1102: 3a 2c 33    :,3
	ora	a		;; 1105: b7          .
	jp	L1131		;; 1106: f2 31 11    .1.
	lxi	h,L3351		;; 1109: 21 51 33    .Q3
	lda	L332d		;; 110c: 3a 2d 33    :-3
	push	h		;; 110f: e5          .
	mov	l,a		;; 1110: 6f          o
	add	a		;; 1111: 87          .
	sbb	a		;; 1112: 9f          .
	mov	h,a		;; 1113: 67          g
	lxi	d,00006h	;; 1114: 11 06 00    ...
	call	L1aaf		;; 1117: cd af 1a    ...
	pop	d		;; 111a: d1          .
	dad	d		;; 111b: 19          .
	lxi	d,L3315		;; 111c: 11 15 33    ..3
	mvi	a,001h		;; 111f: 3e 01       >.
	mov	b,a		;; 1121: 47          G
	call	L1a74		;; 1122: cd 74 1a    .t.
	lhld	L332b		;; 1125: 2a 2b 33    *+3
	call	L1b4f		;; 1128: cd 4f 1b    .O.
	shld	L332b		;; 112b: 22 2b 33    "+3
	jmp	L114d		;; 112e: c3 4d 11    .M.

L1131:	lxi	h,L3351		;; 1131: 21 51 33    .Q3
	lda	L332d		;; 1134: 3a 2d 33    :-3
	push	h		;; 1137: e5          .
	mov	l,a		;; 1138: 6f          o
	add	a		;; 1139: 87          .
	sbb	a		;; 113a: 9f          .
	mov	h,a		;; 113b: 67          g
	lxi	d,00006h	;; 113c: 11 06 00    ...
	call	L1aaf		;; 113f: cd af 1a    ...
	pop	d		;; 1142: d1          .
	dad	d		;; 1143: 19          .
	lxi	d,L3313		;; 1144: 11 13 33    ..3
	mvi	a,001h		;; 1147: 3e 01       >.
	mov	b,a		;; 1149: 47          G
	call	L1a74		;; 114a: cd 74 1a    .t.
L114d:	lxi	h,L3390		;; 114d: 21 90 33    ..3
	call	L0941		;; 1150: cd 41 09    .A.
	lxi	h,L332f		;; 1153: 21 2f 33    ./3
	mvi	b,006h		;; 1156: 06 06       ..
	call	L1a2a		;; 1158: cd 2a 1a    .*.
	lxi	h,L332f		;; 115b: 21 2f 33    ./3
	mvi	e,002h		;; 115e: 1e 02       ..
	mvi	a,006h		;; 1160: 3e 06       >.
	call	L1953		;; 1162: cd 53 19    .S.
	push	h		;; 1165: e5          .
	lxi	h,L334c		;; 1166: 21 4c 33    .L3
	push	psw		;; 1169: f5          .
	lda	L332d		;; 116a: 3a 2d 33    :-3
	push	h		;; 116d: e5          .
	mov	l,a		;; 116e: 6f          o
	add	a		;; 116f: 87          .
	sbb	a		;; 1170: 9f          .
	mov	h,a		;; 1171: 67          g
	lxi	d,00006h	;; 1172: 11 06 00    ...
	call	L1aaf		;; 1175: cd af 1a    ...
	pop	d		;; 1178: d1          .
	dad	d		;; 1179: 19          .
	pop	b		;; 117a: c1          .
	pop	d		;; 117b: d1          .
	mvi	a,005h		;; 117c: 3e 05       >.
	call	L1a74		;; 117e: cd 74 1a    .t.
	lhld	L3325		;; 1181: 2a 25 33    *%3
	push	h		;; 1184: e5          .
	lhld	L3329		;; 1185: 2a 29 33    *)3
	dad	h		;; 1188: 29          )
	dad	h		;; 1189: 29          )
	pop	d		;; 118a: d1          .
	dad	d		;; 118b: 19          .
	mov	e,m		;; 118c: 5e          ^
	inx	h		;; 118d: 23          #
	mov	d,m		;; 118e: 56          V
	xchg			;; 118f: eb          .
	shld	L3329		;; 1190: 22 29 33    ")3
	jmp	L10b8		;; 1193: c3 b8 10    ...

L1196:	call	L119f		;; 1196: cd 9f 11    ...
	jmp	L0ffb		;; 1199: c3 fb 0f    ...

L119c:	jmp	L11f6		;; 119c: c3 f6 11    ...

L119f:	lxi	h,L332e		;; 119f: 21 2e 33    ..3
	inr	m		;; 11a2: 34          4
	lhld	L331b		;; 11a3: 2a 1b 33    *.3
	mov	a,m		;; 11a6: 7e          ~
	lxi	h,L332e		;; 11a7: 21 2e 33    ..3
	sub	m		;; 11aa: 96          .
	jp	L11b5		;; 11ab: f2 b5 11    ...
	lxi	h,000ffh	;; 11ae: 21 ff 00    ...
	xra	a		;; 11b1: af          .
	call	L1d74		;; 11b2: cd 74 1d    .t.
L11b5:	lda	L332d		;; 11b5: 3a 2d 33    :-3
	mov	l,a		;; 11b8: 6f          o
	add	a		;; 11b9: 87          .
	sbb	a		;; 11ba: 9f          .
	mov	h,a		;; 11bb: 67          g
	lxi	d,00006h	;; 11bc: 11 06 00    ...
	call	L1aaf		;; 11bf: cd af 1a    ...
	mov	a,l		;; 11c2: 7d          }
	lxi	h,L333b		;; 11c3: 21 3b 33    .;3
	mov	m,a		;; 11c6: 77          w
	lxi	h,L333b		;; 11c7: 21 3b 33    .;3
	mov	a,m		;; 11ca: 7e          ~
	adi	018h		;; 11cb: c6 18       ..
	mov	m,a		;; 11cd: 77          w
	lhld	L3339		;; 11ce: 2a 39 33    *93
	lda	L333b		;; 11d1: 3a 3b 33    :;3
	dcr	a		;; 11d4: 3d          =
	mov	e,a		;; 11d5: 5f          _
	mvi	c,002h		;; 11d6: 0e 02       ..
	call	L194c		;; 11d8: cd 4c 19    .L.
	lxi	d,L3317		;; 11db: 11 17 33    ..3
	mvi	b,002h		;; 11de: 06 02       ..
	call	L1a74		;; 11e0: cd 74 1a    .t.
	lhld	L3339		;; 11e3: 2a 39 33    *93
	xchg			;; 11e6: eb          .
	lxi	h,L339d		;; 11e7: 21 9d 33    ..3
	mvi	a,080h		;; 11ea: 3e 80       >.
	call	L1a5f		;; 11ec: cd 5f 1a    ._.
	lxi	h,L339b		;; 11ef: 21 9b 33    ..3
	call	L11fa		;; 11f2: cd fa 11    ...
	ret			;; 11f5: c9          .

L11f6:	call	L1c10		;; 11f6: cd 10 1c    ...
	ret			;; 11f9: c9          .

L11fa:	mov	e,m		;; 11fa: 5e          ^
	inx	h		;; 11fb: 23          #
	mov	d,m		;; 11fc: 56          V
	xchg			;; 11fd: eb          .
	shld	L3c87		;; 11fe: 22 87 3c    ".<
	lda	L3446		;; 1201: 3a 46 34    :F4
	ora	a		;; 1204: b7          .
	jp	L12b1		;; 1205: f2 b1 12    ...
	lxi	h,L3446		;; 1208: 21 46 34    .F4
	mvi	m,000h		;; 120b: 36 00       6.
	lhld	L3c87		;; 120d: 2a 87 3c    *.<
	mvi	e,001h		;; 1210: 1e 01       ..
	mov	c,e		;; 1212: 4b          K
	call	L194c		;; 1213: cd 4c 19    .L.
	xchg			;; 1216: eb          .
	mov	b,a		;; 1217: 47          G
	lxi	h,L3c48		;; 1218: 21 48 3c    .H<
	mvi	a,001h		;; 121b: 3e 01       >.
	call	L1979		;; 121d: cd 79 19    .y.
	jnz	L122b		;; 1220: c2 2b 12    .+.
	lxi	h,L3445		;; 1223: 21 45 34    .E4
	mvi	m,080h		;; 1226: 36 80       6.
	jmp	L12b0		;; 1228: c3 b0 12    ...

L122b:	lxi	h,L3445		;; 122b: 21 45 34    .E4
	mvi	m,000h		;; 122e: 36 00       6.
	lxi	h,L341e		;; 1230: 21 1e 34    ..4
	shld	L3c8c		;; 1233: 22 8c 3c    ".<
	call	L1572		;; 1236: cd 72 15    .r.
	push	h		;; 1239: e5          .
	lhld	L3c8c		;; 123a: 2a 8c 3c    *.<
	pop	d		;; 123d: d1          .
	mvi	a,024h		;; 123e: 3e 24       >$
	mov	b,a		;; 1240: 47          G
	call	L1a74		;; 1241: cd 74 1a    .t.
	lxi	h,L3427		;; 1244: 21 27 34    .'4
	lxi	d,L3c49		;; 1247: 11 49 3c    .I<
	mvi	a,003h		;; 124a: 3e 03       >.
	mov	b,a		;; 124c: 47          G
	call	L1a74		;; 124d: cd 74 1a    .t.
	lxi	h,L342a		;; 1250: 21 2a 34    .*4
	mvi	m,000h		;; 1253: 36 00       6.
	lxi	h,L343e		;; 1255: 21 3e 34    .>4
	mvi	m,000h		;; 1258: 36 00       6.
	call	L157a		;; 125a: cd 7a 15    .z.
	shld	L3c8c		;; 125d: 22 8c 3c    ".<
	lxi	h,L3c8f		;; 1260: 21 8f 3c    ..<
	call	fstdma		;; 1263: cd 55 16    .U.
	lxi	h,L341e		;; 1266: 21 1e 34    ..4
	shld	L3c93		;; 1269: 22 93 3c    ".<
	lxi	h,L3c91		;; 126c: 21 91 3c    ..<
	call	fdelet		;; 126f: cd 23 16    .#.
	lxi	h,L341e		;; 1272: 21 1e 34    ..4
	shld	L3c97		;; 1275: 22 97 3c    ".<
	lxi	h,L3c95		;; 1278: 21 95 3c    ..<
	call	fmake		;; 127b: cd 3b 16    .;.
	sui	0ffh		;; 127e: d6 ff       ..
	jnz	L12aa		;; 1280: c2 aa 12    ...
	lxi	h,L3c4c		;; 1283: 21 4c 3c    .L<
	mvi	a,011h		;; 1286: 3e 11       >.
	call	L1a17		;; 1288: cd 17 1a    ...
	lxi	h,L341f		;; 128b: 21 1f 34    ..4
	mvi	b,008h		;; 128e: 06 08       ..
	call	L19df		;; 1290: cd df 19    ...
	lhld	L3c87		;; 1293: 2a 87 3c    *.<
	mvi	b,080h		;; 1296: 06 80       ..
	call	L1a40		;; 1298: cd 40 1a    .@.
	lhld	L3c87		;; 129b: 2a 87 3c    *.<
	shld	L3c99		;; 129e: 22 99 3c    ".<
	lxi	h,L3c99		;; 12a1: 21 99 3c    ..<
	call	L14b7		;; 12a4: cd b7 14    ...
	call	L157e		;; 12a7: cd 7e 15    .~.
L12aa:	lxi	h,0		;; 12aa: 21 00 00    ...
	shld	L3442		;; 12ad: 22 42 34    "B4
L12b0:	ret			;; 12b0: c9          .

L12b1:	lhld	L3c87		;; 12b1: 2a 87 3c    *.<
	shld	L3c8c		;; 12b4: 22 8c 3c    ".<
	lhld	L3c87		;; 12b7: 2a 87 3c    *.<
	xchg			;; 12ba: eb          .
	lxi	h,L3c5d		;; 12bb: 21 5d 3c    .]<
	mvi	a,001h		;; 12be: 3e 01       >.
	call	L1972		;; 12c0: cd 72 19    .r.
	sui	001h		;; 12c3: d6 01       ..
	sbb	a		;; 12c5: 9f          .
	sta	L3c8e		;; 12c6: 32 8e 3c    2.<
	lda	L3445		;; 12c9: 3a 45 34    :E4
	ora	a		;; 12cc: b7          .
	jp	L12dd		;; 12cd: f2 dd 12    ...
	lda	L3c8e		;; 12d0: 3a 8e 3c    :.<
	ora	a		;; 12d3: b7          .
	jp	L12d8		;; 12d4: f2 d8 12    ...
	ret			;; 12d7: c9          .

L12d8:	mvi	a,008h		;; 12d8: 3e 08       >.
	sta	L3c8a		;; 12da: 32 8a 3c    2.<
L12dd:	mvi	a,001h		;; 12dd: 3e 01       >.
	sta	L3c8b		;; 12df: 32 8b 3c    2.<
	lhld	L3c87		;; 12e2: 2a 87 3c    *.<
	mov	l,m		;; 12e5: 6e          n
	mvi	h,000h		;; 12e6: 26 00       &.
	mov	a,l		;; 12e8: 7d          }
	sta	L3c9b		;; 12e9: 32 9b 3c    2.<
L12ec:	lda	L3c9b		;; 12ec: 3a 9b 3c    :.<
	lxi	h,L3c8b		;; 12ef: 21 8b 3c    ..<
	sub	m		;; 12f2: 96          .
	jm	L1371		;; 12f3: fa 71 13    .q.
	lda	L3445		;; 12f6: 3a 45 34    :E4
	ora	a		;; 12f9: b7          .
	jp	L1354		;; 12fa: f2 54 13    .T.
	lhld	L3c8c		;; 12fd: 2a 8c 3c    *.<
	lda	L3c8b		;; 1300: 3a 8b 3c    :.<
	push	h		;; 1303: e5          .
	mov	l,a		;; 1304: 6f          o
	add	a		;; 1305: 87          .
	sbb	a		;; 1306: 9f          .
	mov	h,a		;; 1307: 67          g
	pop	d		;; 1308: d1          .
	dad	d		;; 1309: 19          .
	xchg			;; 130a: eb          .
	lxi	h,L3c89		;; 130b: 21 89 3c    ..<
	mvi	a,001h		;; 130e: 3e 01       >.
	mov	b,a		;; 1310: 47          G
	call	L1a74		;; 1311: cd 74 1a    .t.
	lxi	h,L3c5e		;; 1314: 21 5e 3c    .^<
	lxi	d,L3c89		;; 1317: 11 89 3c    ..<
	mvi	b,001h		;; 131a: 06 01       ..
	mov	a,b		;; 131c: 78          x
	call	L1979		;; 131d: cd 79 19    .y.
	jnz	L133b		;; 1320: c2 3b 13    .;.
L1323:	lxi	h,L3c8a		;; 1323: 21 8a 3c    ..<
	xra	a		;; 1326: af          .
	sub	m		;; 1327: 96          .
	jp	L1338		;; 1328: f2 38 13    .8.
	lxi	h,L3c8a		;; 132b: 21 8a 3c    ..<
	dcr	m		;; 132e: 35          5
	lxi	h,L3c9c		;; 132f: 21 9c 3c    ..<
	call	L159b		;; 1332: cd 9b 15    ...
	jmp	L1323		;; 1335: c3 23 13    .#.

L1338:	jmp	L1345		;; 1338: c3 45 13    .E.

L133b:	lxi	h,L3c9e		;; 133b: 21 9e 3c    ..<
	call	L159b		;; 133e: cd 9b 15    ...
	lxi	h,L3c8a		;; 1341: 21 8a 3c    ..<
	dcr	m		;; 1344: 35          5
L1345:	lda	L3c8a		;; 1345: 3a 8a 3c    :.<
	ora	a		;; 1348: b7          .
	jnz	L1351		;; 1349: c2 51 13    .Q.
	mvi	a,008h		;; 134c: 3e 08       >.
	sta	L3c8a		;; 134e: 32 8a 3c    2.<
L1351:	jmp	L136a		;; 1351: c3 6a 13    .j.

L1354:	lhld	L3c8c		;; 1354: 2a 8c 3c    *.<
	lda	L3c8b		;; 1357: 3a 8b 3c    :.<
	push	h		;; 135a: e5          .
	mov	l,a		;; 135b: 6f          o
	add	a		;; 135c: 87          .
	sbb	a		;; 135d: 9f          .
	mov	h,a		;; 135e: 67          g
	pop	d		;; 135f: d1          .
	dad	d		;; 1360: 19          .
	shld	L3ca0		;; 1361: 22 a0 3c    ".<
	lxi	h,L3ca0		;; 1364: 21 a0 3c    ..<
	call	L13ed		;; 1367: cd ed 13    ...
L136a:	lxi	h,L3c8b		;; 136a: 21 8b 3c    ..<
	inr	m		;; 136d: 34          4
	jmp	L12ec		;; 136e: c3 ec 12    ...

L1371:	lda	L3c8e		;; 1371: 3a 8e 3c    :.<
	ora	a		;; 1374: b7          .
	jm	L137c		;; 1375: fa 7c 13    .|.
	ret			;; 1378: c9          .

	jmp	L13ea		;; 1379: c3 ea 13    ...

L137c:	mvi	a,001h		;; 137c: 3e 01       >.
	sta	L3c8b		;; 137e: 32 8b 3c    2.<
	lxi	h,L3c60		;; 1381: 21 60 3c    .`<
	mvi	a,003h		;; 1384: 3e 03       >.
	call	L1925		;; 1386: cd 25 19    .%.
	call	L175e		;; 1389: cd 5e 17    .^.
	mov	a,l		;; 138c: 7d          }
	sta	L3ca2		;; 138d: 32 a2 3c    2.<
L1390:	lda	L3ca2		;; 1390: 3a a2 3c    :.<
	lxi	h,L3c8b		;; 1393: 21 8b 3c    ..<
	sub	m		;; 1396: 96          .
	jm	L13a7		;; 1397: fa a7 13    ...
	lxi	h,L3ca3		;; 139a: 21 a3 3c    ..<
	call	L13ed		;; 139d: cd ed 13    ...
	lxi	h,L3c8b		;; 13a0: 21 8b 3c    ..<
	inr	m		;; 13a3: 34          4
	jmp	L1390		;; 13a4: c3 90 13    ...

L13a7:	lxi	h,L3444		;; 13a7: 21 44 34    .D4
	mvi	m,080h		;; 13aa: 36 80       6.
	lxi	h,L3ca5		;; 13ac: 21 a5 3c    ..<
	call	L13ed		;; 13af: cd ed 13    ...
	lxi	h,L341e		;; 13b2: 21 1e 34    ..4
	shld	L3ca9		;; 13b5: 22 a9 3c    ".<
	lxi	h,L3ca7		;; 13b8: 21 a7 3c    ..<
	call	fclose		;; 13bb: cd 0e 16    ...
	sui	0ffh		;; 13be: d6 ff       ..
	jnz	L13ea		;; 13c0: c2 ea 13    ...
	lxi	h,L3c63		;; 13c3: 21 63 3c    .c<
	mvi	a,012h		;; 13c6: 3e 12       >.
	call	L1a17		;; 13c8: cd 17 1a    ...
	lxi	h,L341f		;; 13cb: 21 1f 34    ..4
	mvi	b,008h		;; 13ce: 06 08       ..
	call	L19df		;; 13d0: cd df 19    ...
	lhld	L3c87		;; 13d3: 2a 87 3c    *.<
	mvi	b,080h		;; 13d6: 06 80       ..
	call	L1a40		;; 13d8: cd 40 1a    .@.
	lhld	L3c87		;; 13db: 2a 87 3c    *.<
	shld	L3cab		;; 13de: 22 ab 3c    ".<
	lxi	h,L3cab		;; 13e1: 21 ab 3c    ..<
	call	L14b7		;; 13e4: cd b7 14    ...
	call	L157e		;; 13e7: cd 7e 15    .~.
L13ea:	jmp	L14b6		;; 13ea: c3 b6 14    ...

L13ed:	mov	e,m		;; 13ed: 5e          ^
	inx	h		;; 13ee: 23          #
	mov	d,m		;; 13ef: 56          V
	xchg			;; 13f0: eb          .
	shld	L3cad		;; 13f1: 22 ad 3c    ".<
	lhld	L3442		;; 13f4: 2a 42 34    *B4
	inx	h		;; 13f7: 23          #
	shld	L3442		;; 13f8: 22 42 34    "B4
	lda	L3444		;; 13fb: 3a 44 34    :D4
	ora	a		;; 13fe: b7          .
	jp	L141e		;; 13ff: f2 1e 14    ...
	lhld	L3442		;; 1402: 2a 42 34    *B4
	push	h		;; 1405: e5          .
	lxi	h,00080h	;; 1406: 21 80 00    ...
	pop	d		;; 1409: d1          .
	call	L1b11		;; 140a: cd 11 1b    ...
	mov	a,l		;; 140d: 7d          }
	sta	L3c47		;; 140e: 32 47 3c    2G<
	lda	L3c47		;; 1411: 3a 47 3c    :G<
	ora	a		;; 1414: b7          .
	jz	L141e		;; 1415: ca 1e 14    ...
	lxi	h,L0801		;; 1418: 21 01 08    ...
	shld	L3442		;; 141b: 22 42 34    "B4
L141e:	lhld	L3442		;; 141e: 2a 42 34    *B4
	lxi	b,0f7ffh	;; 1421: 01 ff f7    ...
	dad	b		;; 1424: 09          .
	mov	a,h		;; 1425: 7c          |
	ora	a		;; 1426: b7          .
	jm	L14a5		;; 1427: fa a5 14    ...
	lxi	h,00001h	;; 142a: 21 01 00    ...
	shld	L3cb0		;; 142d: 22 b0 3c    ".<
	mov	a,l		;; 1430: 7d          }
	sta	L3caf		;; 1431: 32 af 3c    2.<
	lda	L3c47		;; 1434: 3a 47 3c    :G<
	sta	L3cb2		;; 1437: 32 b2 3c    2.<
L143a:	lda	L3cb2		;; 143a: 3a b2 3c    :.<
	lxi	h,L3caf		;; 143d: 21 af 3c    ..<
	sub	m		;; 1440: 96          .
	jm	L149f		;; 1441: fa 9f 14    ...
	lxi	h,L3446		;; 1444: 21 46 34    .F4
	push	h		;; 1447: e5          .
	lhld	L3cb0		;; 1448: 2a b0 3c    *.<
	pop	d		;; 144b: d1          .
	dad	d		;; 144c: 19          .
	shld	L3cb5		;; 144d: 22 b5 3c    ".<
	lxi	h,L3cb3		;; 1450: 21 b3 3c    ..<
	call	fstdma		;; 1453: cd 55 16    .U.
	lxi	h,L341e		;; 1456: 21 1e 34    ..4
	shld	L3cb9		;; 1459: 22 b9 3c    ".<
	lxi	h,L3cb7		;; 145c: 21 b7 3c    ..<
	call	fwrite		;; 145f: cd 33 16    .3.
	sui	000h		;; 1462: d6 00       ..
	jz	L148e		;; 1464: ca 8e 14    ...
	lxi	h,L3c75		;; 1467: 21 75 3c    .u<
	mvi	a,012h		;; 146a: 3e 12       >.
	call	L1a17		;; 146c: cd 17 1a    ...
	lxi	h,L341f		;; 146f: 21 1f 34    ..4
	mvi	b,008h		;; 1472: 06 08       ..
	call	L19df		;; 1474: cd df 19    ...
	lhld	L3c87		;; 1477: 2a 87 3c    *.<
	mvi	b,080h		;; 147a: 06 80       ..
	call	L1a40		;; 147c: cd 40 1a    .@.
	lhld	L3c87		;; 147f: 2a 87 3c    *.<
	shld	L3cbb		;; 1482: 22 bb 3c    ".<
	lxi	h,L3cbb		;; 1485: 21 bb 3c    ..<
	call	L14b7		;; 1488: cd b7 14    ...
	call	L157e		;; 148b: cd 7e 15    .~.
L148e:	lhld	L3cb0		;; 148e: 2a b0 3c    *.<
	lxi	b,00080h	;; 1491: 01 80 00    ...
	dad	b		;; 1494: 09          .
	shld	L3cb0		;; 1495: 22 b0 3c    ".<
	lxi	h,L3caf		;; 1498: 21 af 3c    ..<
	inr	m		;; 149b: 34          4
	jmp	L143a		;; 149c: c3 3a 14    .:.

L149f:	lxi	h,00001h	;; 149f: 21 01 00    ...
	shld	L3442		;; 14a2: 22 42 34    "B4
L14a5:	lhld	L3cad		;; 14a5: 2a ad 3c    *.<
	mov	a,m		;; 14a8: 7e          ~
	lxi	h,L3446		;; 14a9: 21 46 34    .F4
	push	psw		;; 14ac: f5          .
	push	h		;; 14ad: e5          .
	lhld	L3442		;; 14ae: 2a 42 34    *B4
	pop	d		;; 14b1: d1          .
	dad	d		;; 14b2: 19          .
	pop	psw		;; 14b3: f1          .
	mov	m,a		;; 14b4: 77          w
	ret			;; 14b5: c9          .

L14b6:	ret			;; 14b6: c9          .

L14b7:	mov	e,m		;; 14b7: 5e          ^
	inx	h		;; 14b8: 23          #
	mov	d,m		;; 14b9: 56          V
	xchg			;; 14ba: eb          .
	shld	L3cbe		;; 14bb: 22 be 3c    ".<
	mvi	a,001h		;; 14be: 3e 01       >.
	sta	L3cc0		;; 14c0: 32 c0 3c    2.<
	lhld	L3cbe		;; 14c3: 2a be 3c    *.<
	mov	l,m		;; 14c6: 6e          n
	mvi	h,000h		;; 14c7: 26 00       &.
	mov	a,l		;; 14c9: 7d          }
	sta	L3cc1		;; 14ca: 32 c1 3c    2.<
L14cd:	lda	L3cc1		;; 14cd: 3a c1 3c    :.<
	lxi	h,L3cc0		;; 14d0: 21 c0 3c    ..<
	sub	m		;; 14d3: 96          .
	jm	L14fa		;; 14d4: fa fa 14    ...
	lhld	L3cbe		;; 14d7: 2a be 3c    *.<
	lda	L3cc0		;; 14da: 3a c0 3c    :.<
	mov	e,a		;; 14dd: 5f          _
	mvi	c,001h		;; 14de: 0e 01       ..
	call	L194c		;; 14e0: cd 4c 19    .L.
	xchg			;; 14e3: eb          .
	mov	b,a		;; 14e4: 47          G
	lxi	h,L3cc4		;; 14e5: 21 c4 3c    ..<
	mvi	a,001h		;; 14e8: 3e 01       >.
	call	L1a74		;; 14ea: cd 74 1a    .t.
	lxi	h,L3cc2		;; 14ed: 21 c2 3c    ..<
	call	L1586		;; 14f0: cd 86 15    ...
	lxi	h,L3cc0		;; 14f3: 21 c0 3c    ..<
	inr	m		;; 14f6: 34          4
	jmp	L14cd		;; 14f7: c3 cd 14    ...

L14fa:	lxi	h,L3cc5		;; 14fa: 21 c5 3c    ..<
	call	L1586		;; 14fd: cd 86 15    ...
	ret			;; 1500: c9          .

L1501:	mov	e,m		;; 1501: 5e          ^
	inx	h		;; 1502: 23          #
	mov	d,m		;; 1503: 56          V
	xchg			;; 1504: eb          .
	mov	e,m		;; 1505: 5e          ^
	ret			;; 1506: c9          .

L1507:	call	L1501		;; 1507: cd 01 15    ...
	inx	h		;; 150a: 23          #
	mov	d,m		;; 150b: 56          V
	ret			;; 150c: c9          .

getver:	push	h		;; 150d: e5          .
	mvi	c,version	;; 150e: 0e 0c       ..
	call	bdos		;; 1510: cd 05 00    ...
	pop	h		;; 1513: e1          .
	ret			;; 1514: c9          .

L1515:	call	getver		;; 1515: cd 0d 15    ...
	cpi	014h		;; 1518: fe 14       ..
	rnc			;; 151a: d0          .
	jmp	L1524		;; 151b: c3 24 15    .$.

L151e:	call	getver		;; 151e: cd 0d 15    ...
	cpi	022h		;; 1521: fe 22       ."
	rnc			;; 1523: d0          .
L1524:	lxi	d,L152f		;; 1524: 11 2f 15    ./.
	mvi	c,print		;; 1527: 0e 09       ..
	call	bdos		;; 1529: cd 05 00    ...
	jmp	cpm		;; 152c: c3 00 00    ...

L152f:	db	0dh,0ah,'Later CP/M or MP/M Version Required$'

L1555:	lhld	L3d23		;; 1555: 2a 23 3d    *#=
	ret			;; 1558: c9          .

L1559:	lhld	00006h		;; 1559: 2a 06 00    *..
	xchg			;; 155c: eb          .
	lhld	L3d23		;; 155d: 2a 23 3d    *#=
	mov	a,e		;; 1560: 7b          {
	sub	l		;; 1561: 95          .
	mov	l,a		;; 1562: 6f          o
	mov	a,d		;; 1563: 7a          z
	sbb	h		;; 1564: 9c          .
	mov	h,a		;; 1565: 67          g
	ret			;; 1566: c9          .

L1567:	call	L1559		;; 1567: cd 59 15    .Y.
	mov	a,h		;; 156a: 7c          |
	ora	a		;; 156b: b7          .
	rar			;; 156c: 1f          .
	mov	h,a		;; 156d: 67          g
	mov	a,l		;; 156e: 7d          }
	rar			;; 156f: 1f          .
	mov	l,a		;; 1570: 6f          o
	ret			;; 1571: c9          .

L1572:	lxi	h,deffcb	;; 1572: 21 5c 00    .\.
	ret			;; 1575: c9          .

L1576:	lxi	h,deffcb+16	;; 1576: 21 6c 00    .l.
	ret			;; 1579: c9          .

L157a:	lxi	h,00080h	;; 157a: 21 80 00    ...
	ret			;; 157d: c9          .

L157e:	jmp	cpm		;; 157e: c3 00 00    ...

	mvi	c,conin		;; 1581: 0e 01       ..
	jmp	L158d		;; 1583: c3 8d 15    ...

L1586:	mvi	c,conout	;; 1586: 0e 02       ..
	jmp	L159d		;; 1588: c3 9d 15    ...

	mvi	c,auxin		;; 158b: 0e 03       ..
L158d:	call	bdos		;; 158d: cd 05 00    ...
	pop	h		;; 1590: e1          .
	push	psw		;; 1591: f5          .
	inx	sp		;; 1592: 33          3
	mvi	a,001h		;; 1593: 3e 01       >.
	pchl			;; 1595: e9          .

	mvi	c,auxout	;; 1596: 0e 04       ..
	jmp	L159d		;; 1598: c3 9d 15    ...

L159b:	mvi	c,lstout	;; 159b: 0e 05       ..
L159d:	call	L1501		;; 159d: cd 01 15    ...
	jmp	bdos		;; 15a0: c3 05 00    ...

	lxi	h,L15af		;; 15a3: 21 af 15    ...
	push	h		;; 15a6: e5          .
	lhld	cpm+1		;; 15a7: 2a 01 00    *..
	lxi	d,6		;; 15aa: 11 06 00    ...
	dad	d		;; 15ad: 19          .
	pchl			;; 15ae: e9          .

L15af:	pop	h		;; 15af: e1          .
	push	psw		;; 15b0: f5          .
	inx	sp		;; 15b1: 33          3
	mvi	a,001h		;; 15b2: 3e 01       >.
	pchl			;; 15b4: e9          .

	call	L1501		;; 15b5: cd 01 15    ...
	mov	c,e		;; 15b8: 4b          K
	lhld	cpm+1		;; 15b9: 2a 01 00    *..
	lxi	d,9		;; 15bc: 11 09 00    ...
	dad	d		;; 15bf: 19          .
	pchl			;; 15c0: e9          .

	lxi	h,L15ef		;; 15c1: 21 ef 15    ...
	push	h		;; 15c4: e5          .
	lhld	cpm+1		;; 15c5: 2a 01 00    *..
	lxi	d,3		;; 15c8: 11 03 00    ...
	dad	d		;; 15cb: 19          .
	pchl			;; 15cc: e9          .

	mvi	c,007h		;; 15cd: 0e 07       ..
	jmp	bdos		;; 15cf: c3 05 00    ...

	call	L1501		;; 15d2: cd 01 15    ...
	mvi	c,008h		;; 15d5: 0e 08       ..
	jmp	bdos		;; 15d7: c3 05 00    ...

	call	L1507		;; 15da: cd 07 15    ...
	mvi	c,print		;; 15dd: 0e 09       ..
	jmp	bdos		;; 15df: c3 05 00    ...

	call	L1507		;; 15e2: cd 07 15    ...
	mvi	c,00ah		;; 15e5: 0e 0a       ..
	jmp	bdos		;; 15e7: c3 05 00    ...

L15ea:	mvi	c,const		;; 15ea: 0e 0b       ..
	call	bdos		;; 15ec: cd 05 00    ...
L15ef:	ora	a		;; 15ef: b7          .
	rz			;; 15f0: c8          .
	mvi	a,0ffh		;; 15f1: 3e ff       >.
	ret			;; 15f3: c9          .

L15f4:	mvi	c,version	;; 15f4: 0e 0c       ..
	jmp	bdos		;; 15f6: c3 05 00    ...

	mvi	c,00dh		;; 15f9: 0e 0d       ..
	jmp	bdos		;; 15fb: c3 05 00    ...

	call	L1501		;; 15fe: cd 01 15    ...
	mvi	c,00eh		;; 1601: 0e 0e       ..
	jmp	bdos		;; 1603: c3 05 00    ...

fopen:	call	L1507		;; 1606: cd 07 15    ...
	mvi	c,open		;; 1609: 0e 0f       ..
	jmp	bdos		;; 160b: c3 05 00    ...

fclose:	call	L1507		;; 160e: cd 07 15    ...
	mvi	c,close		;; 1611: 0e 10       ..
	jmp	bdos		;; 1613: c3 05 00    ...

	call	L1507		;; 1616: cd 07 15    ...
	mvi	c,011h		;; 1619: 0e 11       ..
	jmp	bdos		;; 161b: c3 05 00    ...

	mvi	c,012h		;; 161e: 0e 12       ..
	jmp	bdos		;; 1620: c3 05 00    ...

fdelet:	call	L1507		;; 1623: cd 07 15    ...
	mvi	c,delete	;; 1626: 0e 13       ..
	jmp	bdos		;; 1628: c3 05 00    ...

fread:	call	L1507		;; 162b: cd 07 15    ...
	mvi	c,read		;; 162e: 0e 14       ..
	jmp	bdos		;; 1630: c3 05 00    ...

fwrite:	call	L1507		;; 1633: cd 07 15    ...
	mvi	c,write		;; 1636: 0e 15       ..
	jmp	bdos		;; 1638: c3 05 00    ...

fmake:	call	L1507		;; 163b: cd 07 15    ...
	mvi	c,make		;; 163e: 0e 16       ..
	jmp	bdos		;; 1640: c3 05 00    ...

	call	L1507		;; 1643: cd 07 15    ...
	mvi	c,017h		;; 1646: 0e 17       ..
	jmp	bdos		;; 1648: c3 05 00    ...

	mvi	c,018h		;; 164b: 0e 18       ..
	jmp	bdos		;; 164d: c3 05 00    ...

	mvi	c,019h		;; 1650: 0e 19       ..
	jmp	bdos		;; 1652: c3 05 00    ...

fstdma:	call	L1507		;; 1655: cd 07 15    ...
	mvi	c,setdma	;; 1658: 0e 1a       ..
	jmp	bdos		;; 165a: c3 05 00    ...

	mvi	c,01bh		;; 165d: 0e 1b       ..
	jmp	bdos		;; 165f: c3 05 00    ...

	call	L1515		;; 1662: cd 15 15    ...
	mvi	c,01ch		;; 1665: 0e 1c       ..
	jmp	bdos		;; 1667: c3 05 00    ...

	call	L1515		;; 166a: cd 15 15    ...
	mvi	c,01dh		;; 166d: 0e 1d       ..
	jmp	bdos		;; 166f: c3 05 00    ...

	call	L1515		;; 1672: cd 15 15    ...
	call	L1507		;; 1675: cd 07 15    ...
	mvi	c,01eh		;; 1678: 0e 1e       ..
	jmp	bdos		;; 167a: c3 05 00    ...

	call	L1515		;; 167d: cd 15 15    ...
	mvi	c,01fh		;; 1680: 0e 1f       ..
	jmp	bdos		;; 1682: c3 05 00    ...

	call	L1515		;; 1685: cd 15 15    ...
	mvi	e,0ffh		;; 1688: 1e ff       ..
	mvi	c,020h		;; 168a: 0e 20       . 
	jmp	bdos		;; 168c: c3 05 00    ...

	call	L1515		;; 168f: cd 15 15    ...
	call	L1501		;; 1692: cd 01 15    ...
	mvi	c,020h		;; 1695: 0e 20       . 
	jmp	bdos		;; 1697: c3 05 00    ...

	call	L1515		;; 169a: cd 15 15    ...
	call	L1507		;; 169d: cd 07 15    ...
	mvi	c,021h		;; 16a0: 0e 21       ..
	jmp	bdos		;; 16a2: c3 05 00    ...

	call	L1515		;; 16a5: cd 15 15    ...
	call	L1507		;; 16a8: cd 07 15    ...
	mvi	c,022h		;; 16ab: 0e 22       ."
	jmp	bdos		;; 16ad: c3 05 00    ...

	call	L1515		;; 16b0: cd 15 15    ...
	call	L1507		;; 16b3: cd 07 15    ...
	mvi	c,023h		;; 16b6: 0e 23       .#
	jmp	bdos		;; 16b8: c3 05 00    ...

	call	L1515		;; 16bb: cd 15 15    ...
	call	L1507		;; 16be: cd 07 15    ...
	mvi	c,024h		;; 16c1: 0e 24       .$
	jmp	bdos		;; 16c3: c3 05 00    ...

	call	L151e		;; 16c6: cd 1e 15    ...
	call	L1507		;; 16c9: cd 07 15    ...
	mvi	c,025h		;; 16cc: 0e 25       .%
	jmp	bdos		;; 16ce: c3 05 00    ...

	call	L151e		;; 16d1: cd 1e 15    ...
	call	L1507		;; 16d4: cd 07 15    ...
	mvi	c,028h		;; 16d7: 0e 28       .(
	jmp	bdos		;; 16d9: c3 05 00    ...

L16dc:	mov	e,m		;; 16dc: 5e          ^
	inx	h		;; 16dd: 23          #
	mov	d,m		;; 16de: 56          V
	xchg			;; 16df: eb          .
	mov	e,m		;; 16e0: 5e          ^
	ret			;; 16e1: c9          .

L16e2:	call	L16dc		;; 16e2: cd dc 16    ...
	inx	h		;; 16e5: 23          #
	mov	d,m		;; 16e6: 56          V
	ret			;; 16e7: c9          .

L16e8:	call	L16e2		;; 16e8: cd e2 16    ...
	mvi	c,087h		;; 16eb: 0e 87       ..
	jmp	bdos		;; 16ed: c3 05 00    ...

	call	L16e2		;; 16f0: cd e2 16    ...
	mvi	c,089h		;; 16f3: 0e 89       ..
	jmp	bdos		;; 16f5: c3 05 00    ...

L16f8:	call	L16e2		;; 16f8: cd e2 16    ...
	mvi	c,08ah		;; 16fb: 0e 8a       ..
	jmp	bdos		;; 16fd: c3 05 00    ...

L1700:	xchg			;; 1700: eb          .
	mov	b,m		;; 1701: 46          F
	xchg			;; 1702: eb          .
	inx	d		;; 1703: 13          .
	jmp	L1707		;; 1704: c3 07 17    ...

L1707:	ora	a		;; 1707: b7          .
	jz	L1733		;; 1708: ca 33 17    .3.
	mov	c,a		;; 170b: 4f          O
	inr	b		;; 170c: 04          .
	dcr	b		;; 170d: 05          .
	jz	L1733		;; 170e: ca 33 17    .3.
	push	b		;; 1711: c5          .
L1712:	push	b		;; 1712: c5          .
	push	d		;; 1713: d5          .
	push	h		;; 1714: e5          .
L1715:	ldax	d		;; 1715: 1a          .
	cmp	m		;; 1716: be          .
	jnz	L172a		;; 1717: c2 2a 17    .*.
	inx	d		;; 171a: 13          .
	inx	h		;; 171b: 23          #
	dcr	c		;; 171c: 0d          .
	jz	L1737		;; 171d: ca 37 17    .7.
	dcr	b		;; 1720: 05          .
	jnz	L1715		;; 1721: c2 15 17    ...
	pop	h		;; 1724: e1          .
	pop	d		;; 1725: d1          .
	pop	b		;; 1726: c1          .
	jmp	L1732		;; 1727: c3 32 17    .2.

L172a:	pop	h		;; 172a: e1          .
	pop	d		;; 172b: d1          .
	pop	b		;; 172c: c1          .
	inx	d		;; 172d: 13          .
	dcr	b		;; 172e: 05          .
	jnz	L1712		;; 172f: c2 12 17    ...
L1732:	pop	b		;; 1732: c1          .
L1733:	xra	a		;; 1733: af          .
	mov	h,a		;; 1734: 67          g
	mov	l,h		;; 1735: 6c          l
	ret			;; 1736: c9          .

L1737:	pop	h		;; 1737: e1          .
	pop	d		;; 1738: d1          .
	pop	b		;; 1739: c1          .
	pop	psw		;; 173a: f1          .
	sub	b		;; 173b: 90          .
	inr	a		;; 173c: 3c          <
	mov	l,a		;; 173d: 6f          o
	mvi	h,000h		;; 173e: 26 00       &.
	ret			;; 1740: c9          .

L1741:	pop	h		;; 1741: e1          .
	shld	L3cc7		;; 1742: 22 c7 3c    ".<
	mvi	b,000h		;; 1745: 06 00       ..
	mvi	a,006h		;; 1747: 3e 06       >.
	call	L17f1		;; 1749: cd f1 17    ...
	lhld	L3cc7		;; 174c: 2a c7 3c    *.<
	pchl			;; 174f: e9          .

	pop	h		;; 1750: e1          .
	shld	L3cc9		;; 1751: 22 c9 3c    ".<
	call	L1741		;; 1754: cd 41 17    .A.
	call	L176e		;; 1757: cd 6e 17    .n.
	lhld	L3cc9		;; 175a: 2a c9 3c    *.<
	pchl			;; 175d: e9          .

L175e:	pop	h		;; 175e: e1          .
	shld	L3cc9		;; 175f: 22 c9 3c    ".<
	call	L1741		;; 1762: cd 41 17    .A.
	call	L176e		;; 1765: cd 6e 17    .n.
	push	h		;; 1768: e5          .
	lhld	L3cc9		;; 1769: 2a c9 3c    *.<
	xthl			;; 176c: e3          .
	ret			;; 176d: c9          .

L176e:	lxi	b,00002h	;; 176e: 01 02 00    ...
	push	psw		;; 1771: f5          .
	push	b		;; 1772: c5          .
	mov	b,a		;; 1773: 47          G
	lxi	h,00006h	;; 1774: 21 06 00    ...
	dad	sp		;; 1777: 39          9
	xchg			;; 1778: eb          .
	lxi	h,0		;; 1779: 21 00 00    ...
L177c:	mov	a,b		;; 177c: 78          x
	ora	a		;; 177d: b7          .
	jz	L17ca		;; 177e: ca ca 17    ...
	ldax	d		;; 1781: 1a          .
	cpi	020h		;; 1782: fe 20       . 
	jz	L17c5		;; 1784: ca c5 17    ...
	cpi	02bh		;; 1787: fe 2b       .+
	jnz	L1797		;; 1789: c2 97 17    ...
L178c:	xthl			;; 178c: e3          .
	inr	h		;; 178d: 24          $
	dcr	h		;; 178e: 25          %
	jnz	L1b5e		;; 178f: c2 5e 1b    .^.
	mov	h,a		;; 1792: 67          g
	xthl			;; 1793: e3          .
	jmp	L17c5		;; 1794: c3 c5 17    ...

L1797:	cpi	02dh		;; 1797: fe 2d       .-
	jz	L178c		;; 1799: ca 8c 17    ...
	cpi	030h		;; 179c: fe 30       .0
	jm	L1b5e		;; 179e: fa 5e 1b    .^.
	cpi	03ah		;; 17a1: fe 3a       .:
	jp	L1b5e		;; 17a3: f2 5e 1b    .^.
	sui	030h		;; 17a6: d6 30       .0
	push	d		;; 17a8: d5          .
	mov	d,h		;; 17a9: 54          T
	mov	e,l		;; 17aa: 5d          ]
	dad	h		;; 17ab: 29          )
	jc	L1b5e		;; 17ac: da 5e 1b    .^.
	dad	h		;; 17af: 29          )
	jc	L1b5e		;; 17b0: da 5e 1b    .^.
	dad	d		;; 17b3: 19          .
	jc	L1b5e		;; 17b4: da 5e 1b    .^.
	dad	h		;; 17b7: 29          )
	jc	L1b5e		;; 17b8: da 5e 1b    .^.
	add	l		;; 17bb: 85          .
	mov	l,a		;; 17bc: 6f          o
	mov	a,h		;; 17bd: 7c          |
	aci	000h		;; 17be: ce 00       ..
	mov	h,a		;; 17c0: 67          g
	jc	L1b5e		;; 17c1: da 5e 1b    .^.
	pop	d		;; 17c4: d1          .
L17c5:	inx	d		;; 17c5: 13          .
	dcr	b		;; 17c6: 05          .
	jmp	L177c		;; 17c7: c3 7c 17    .|.

L17ca:	pop	d		;; 17ca: d1          .
	mov	a,e		;; 17cb: 7b          {
	cpi	002h		;; 17cc: fe 02       ..
	jz	L17da		;; 17ce: ca da 17    ...
	inr	h		;; 17d1: 24          $
	dcr	h		;; 17d2: 25          %
	jnz	L1b5e		;; 17d3: c2 5e 1b    .^.
	mov	a,l		;; 17d6: 7d          }
	jmp	L17db		;; 17d7: c3 db 17    ...

L17da:	mov	a,h		;; 17da: 7c          |
L17db:	add	a		;; 17db: 87          .
	jc	L1b5e		;; 17dc: da 5e 1b    .^.
	mov	a,d		;; 17df: 7a          z
	cpi	02dh		;; 17e0: fe 2d       .-
	cz	L1b4f		;; 17e2: cc 4f 1b    .O.
	xchg			;; 17e5: eb          .
	pop	psw		;; 17e6: f1          .
	pop	b		;; 17e7: c1          .
	mov	l,a		;; 17e8: 6f          o
	mvi	h,000h		;; 17e9: 26 00       &.
	dad	sp		;; 17eb: 39          9
	sphl			;; 17ec: f9          .
	xchg			;; 17ed: eb          .
	push	b		;; 17ee: c5          .
	mov	a,l		;; 17ef: 7d          }
	ret			;; 17f0: c9          .

L17f1:	mov	c,a		;; 17f1: 4f          O
	lxi	h,0		;; 17f2: 21 00 00    ...
	dad	sp		;; 17f5: 39          9
	lxi	d,-18		;; 17f6: 11 ee ff    ...
	xchg			;; 17f9: eb          .
	dad	d		;; 17fa: 19          .
	sphl			;; 17fb: f9          .
	push	b		;; 17fc: c5          .
	mvi	b,00ah		;; 17fd: 06 0a       ..
L17ff:	ldax	d		;; 17ff: 1a          .
	mov	m,a		;; 1800: 77          w
	inx	d		;; 1801: 13          .
	inx	h		;; 1802: 23          #
	dcr	b		;; 1803: 05          .
	jnz	L17ff		;; 1804: c2 ff 17    ...
	pop	b		;; 1807: c1          .
	mvi	m,030h		;; 1808: 36 30       60
	inx	h		;; 180a: 23          #
	mvi	m,030h		;; 180b: 36 30       60
	lxi	h,00009h	;; 180d: 21 09 00    ...
	dad	sp		;; 1810: 39          9
	mov	a,m		;; 1811: 7e          ~
	mvi	d,020h		;; 1812: 16 20       . 
	ora	a		;; 1814: b7          .
	jp	L182e		;; 1815: f2 2e 18    ...
	mvi	d,008h		;; 1818: 16 08       ..
	lxi	h,00002h	;; 181a: 21 02 00    ...
	dad	sp		;; 181d: 39          9
	stc			;; 181e: 37          7
L181f:	mvi	a,09ah		;; 181f: 3e 9a       >.
	cmc			;; 1821: 3f          ?
	sbb	m		;; 1822: 9e          .
	adi	000h		;; 1823: c6 00       ..
	daa			;; 1825: 27          '
	mov	m,a		;; 1826: 77          w
	inx	h		;; 1827: 23          #
	dcr	d		;; 1828: 15          .
	jnz	L181f		;; 1829: c2 1f 18    ...
	mvi	d,02dh		;; 182c: 16 2d       .-
L182e:	lxi	h,00002h	;; 182e: 21 02 00    ...
	dad	sp		;; 1831: 39          9
	mvi	e,010h		;; 1832: 1e 10       ..
L1834:	mov	a,m		;; 1834: 7e          ~
	call	L1873		;; 1835: cd 73 18    .s.
	jz	L1847		;; 1838: ca 47 18    .G.
	mov	a,m		;; 183b: 7e          ~
	rar			;; 183c: 1f          .
	rar			;; 183d: 1f          .
	rar			;; 183e: 1f          .
	rar			;; 183f: 1f          .
	inx	h		;; 1840: 23          #
	call	L1873		;; 1841: cd 73 18    .s.
	jnz	L1834		;; 1844: c2 34 18    .4.
L1847:	lxi	h,0000ah	;; 1847: 21 0a 00    ...
	dad	sp		;; 184a: 39          9
	mvi	e,011h		;; 184b: 1e 11       ..
L184d:	mov	a,m		;; 184d: 7e          ~
	cpi	02eh		;; 184e: fe 2e       ..
	jnz	L1859		;; 1850: c2 59 18    .Y.
	dcx	h		;; 1853: 2b          +
	mvi	m,030h		;; 1854: 36 30       60
	jmp	L1865		;; 1856: c3 65 18    .e.

L1859:	cpi	030h		;; 1859: fe 30       .0
	jnz	L1865		;; 185b: c2 65 18    .e.
	mvi	m,020h		;; 185e: 36 20       6 
	inx	h		;; 1860: 23          #
	dcr	e		;; 1861: 1d          .
	jnz	L184d		;; 1862: c2 4d 18    .M.
L1865:	dcx	h		;; 1865: 2b          +
	mov	m,d		;; 1866: 72          r
	mvi	a,01ch		;; 1867: 3e 1c       >.
	sub	c		;; 1869: 91          .
	mov	l,a		;; 186a: 6f          o
	mvi	h,000h		;; 186b: 26 00       &.
	dad	sp		;; 186d: 39          9
	pop	d		;; 186e: d1          .
	mov	a,c		;; 186f: 79          y
	sphl			;; 1870: f9          .
	xchg			;; 1871: eb          .
	pchl			;; 1872: e9          .

L1873:	push	h		;; 1873: e5          .
	push	psw		;; 1874: f5          .
	mvi	a,011h		;; 1875: 3e 11       >.
	add	e		;; 1877: 83          .
	mov	l,a		;; 1878: 6f          o
	mvi	h,000h		;; 1879: 26 00       &.
	dad	sp		;; 187b: 39          9
	pop	psw		;; 187c: f1          .
	ani	00fh		;; 187d: e6 0f       ..
	adi	030h		;; 187f: c6 30       .0
	mov	m,a		;; 1881: 77          w
	dcx	h		;; 1882: 2b          +
	dcr	b		;; 1883: 05          .
	jnz	L188a		;; 1884: c2 8a 18    ...
	dcr	e		;; 1887: 1d          .
	mvi	m,02eh		;; 1888: 36 2e       6.
L188a:	pop	h		;; 188a: e1          .
	dcr	e		;; 188b: 1d          .
	ret			;; 188c: c9          .

L188d:	pop	b		;; 188d: c1          .
	xchg			;; 188e: eb          .
	cma			;; 188f: 2f          /
	inr	a		;; 1890: 3c          <
	mov	l,a		;; 1891: 6f          o
	mvi	h,0ffh		;; 1892: 26 ff       &.
	dad	sp		;; 1894: 39          9
	sphl			;; 1895: f9          .
	cma			;; 1896: 2f          /
	inr	a		;; 1897: 3c          <
	mov	h,a		;; 1898: 67          g
L1899:	cpi	006h		;; 1899: fe 06       ..
	jnc	L18a3		;; 189b: d2 a3 18    ...
	dcx	sp		;; 189e: 3b          ;
	inr	a		;; 189f: 3c          <
	jmp	L1899		;; 18a0: c3 99 18    ...

L18a3:	push	b		;; 18a3: c5          .
	push	h		;; 18a4: e5          .
	push	psw		;; 18a5: f5          .
	push	d		;; 18a6: d5          .
	lxi	h,00007h	;; 18a7: 21 07 00    ...
	dad	sp		;; 18aa: 39          9
	mov	e,a		;; 18ab: 5f          _
	mvi	d,000h		;; 18ac: 16 00       ..
	dad	d		;; 18ae: 19          .
	push	h		;; 18af: e5          .
L18b0:	mvi	m,020h		;; 18b0: 36 20       6 
	dcx	h		;; 18b2: 2b          +
	dcr	a		;; 18b3: 3d          =
	jnz	L18b0		;; 18b4: c2 b0 18    ...
	pop	d		;; 18b7: d1          .
	pop	h		;; 18b8: e1          .
	mov	b,h		;; 18b9: 44          D
	mov	c,l		;; 18ba: 4d          M
	push	b		;; 18bb: c5          .
	dad	h		;; 18bc: 29          )
	jnc	L18c7		;; 18bd: d2 c7 18    ...
	xra	a		;; 18c0: af          .
	sub	c		;; 18c1: 91          .
	mov	c,a		;; 18c2: 4f          O
	mvi	a,000h		;; 18c3: 3e 00       >.
	sbb	b		;; 18c5: 98          .
	mov	b,a		;; 18c6: 47          G
L18c7:	lxi	h,00001h	;; 18c7: 21 01 00    ...
	call	L18f0		;; 18ca: cd f0 18    ...
	ldax	d		;; 18cd: 1a          .
	cpi	020h		;; 18ce: fe 20       . 
	jnz	L18d6		;; 18d0: c2 d6 18    ...
	mvi	a,030h		;; 18d3: 3e 30       >0
	stax	d		;; 18d5: 12          .
L18d6:	pop	psw		;; 18d6: f1          .
	ora	a		;; 18d7: b7          .
	jp	L18e5		;; 18d8: f2 e5 18    ...
L18db:	dcx	d		;; 18db: 1b          .
	ldax	d		;; 18dc: 1a          .
	cpi	020h		;; 18dd: fe 20       . 
	jnz	L18db		;; 18df: c2 db 18    ...
	mvi	a,02dh		;; 18e2: 3e 2d       >-
	stax	d		;; 18e4: 12          .
L18e5:	pop	b		;; 18e5: c1          .
	pop	psw		;; 18e6: f1          .
L18e7:	cmp	b		;; 18e7: b8          .
	rnc			;; 18e8: d0          .
	pop	h		;; 18e9: e1          .
	dcr	b		;; 18ea: 05          .
	inx	sp		;; 18eb: 33          3
	push	h		;; 18ec: e5          .
	jmp	L18e7		;; 18ed: c3 e7 18    ...

L18f0:	push	h		;; 18f0: e5          .
	push	d		;; 18f1: d5          .
	mov	d,h		;; 18f2: 54          T
	mov	e,l		;; 18f3: 5d          ]
	dad	d		;; 18f4: 19          .
	dad	h		;; 18f5: 29          )
	dad	d		;; 18f6: 19          .
	dad	h		;; 18f7: 29          )
	pop	d		;; 18f8: d1          .
	dcx	d		;; 18f9: 1b          .
	cnc	L18f0		;; 18fa: d4 f0 18    ...
	inx	d		;; 18fd: 13          .
	pop	h		;; 18fe: e1          .
	push	h		;; 18ff: e5          .
	xra	a		;; 1900: af          .
	sub	l		;; 1901: 95          .
	mov	l,c		;; 1902: 69          i
	mov	c,a		;; 1903: 4f          O
	mvi	a,000h		;; 1904: 3e 00       >.
	sbb	h		;; 1906: 9c          .
	mov	h,b		;; 1907: 60          `
	mov	b,a		;; 1908: 47          G
	mvi	a,030h		;; 1909: 3e 30       >0
L190b:	dad	b		;; 190b: 09          .
	jnc	L1913		;; 190c: d2 13 19    ...
	inr	a		;; 190f: 3c          <
	jmp	L190b		;; 1910: c3 0b 19    ...

L1913:	pop	b		;; 1913: c1          .
	dad	b		;; 1914: 09          .
	mov	b,h		;; 1915: 44          D
	mov	c,l		;; 1916: 4d          M
	stax	d		;; 1917: 12          .
	cpi	030h		;; 1918: fe 30       .0
	rnz			;; 191a: c0          .
	dcx	d		;; 191b: 1b          .
	ldax	d		;; 191c: 1a          .
	inx	d		;; 191d: 13          .
	cpi	020h		;; 191e: fe 20       . 
	rnz			;; 1920: c0          .
	mvi	a,020h		;; 1921: 3e 20       > 
	stax	d		;; 1923: 12          .
	ret			;; 1924: c9          .

L1925:	inr	a		;; 1925: 3c          <
	pop	b		;; 1926: c1          .
	xchg			;; 1927: eb          .
	lxi	h,0fff8h	;; 1928: 21 f8 ff    ...
	dad	sp		;; 192b: 39          9
	sphl			;; 192c: f9          .
	push	b		;; 192d: c5          .
	mvi	b,008h		;; 192e: 06 08       ..
	inr	a		;; 1930: 3c          <
	ora	a		;; 1931: b7          .
	rar			;; 1932: 1f          .
	mov	c,a		;; 1933: 4f          O
L1934:	ldax	d		;; 1934: 1a          .
	mov	m,a		;; 1935: 77          w
	inx	d		;; 1936: 13          .
	inx	h		;; 1937: 23          #
	dcr	b		;; 1938: 05          .
	rz			;; 1939: c8          .
	dcr	c		;; 193a: 0d          .
	jnz	L1934		;; 193b: c2 34 19    .4.
	ora	a		;; 193e: b7          .
	mvi	a,099h		;; 193f: 3e 99       >.
	jm	L1945		;; 1941: fa 45 19    .E.
	xra	a		;; 1944: af          .
L1945:	mov	m,a		;; 1945: 77          w
	inx	h		;; 1946: 23          #
	dcr	b		;; 1947: 05          .
	rz			;; 1948: c8          .
	jmp	L1945		;; 1949: c3 45 19    .E.

L194c:	mov	a,m		;; 194c: 7e          ~
	inx	h		;; 194d: 23          #
	jmp	L1958		;; 194e: c3 58 19    .X.

	mov	a,m		;; 1951: 7e          ~
	inx	h		;; 1952: 23          #
L1953:	mov	d,a		;; 1953: 57          W
	sub	e		;; 1954: 93          .
	inr	a		;; 1955: 3c          <
	mov	c,a		;; 1956: 4f          O
	mov	a,d		;; 1957: 7a          z
L1958:	cmp	e		;; 1958: bb          .
	jnc	L195d		;; 1959: d2 5d 19    .].
	mov	e,a		;; 195c: 5f          _
L195d:	mvi	d,000h		;; 195d: 16 00       ..
	dad	d		;; 195f: 19          .
	dcx	h		;; 1960: 2b          +
	sub	e		;; 1961: 93          .
	inr	a		;; 1962: 3c          <
	cmp	c		;; 1963: b9          .
	jnc	L1968		;; 1964: d2 68 19    .h.
	mov	c,a		;; 1967: 4f          O
L1968:	mov	a,c		;; 1968: 79          y
	ret			;; 1969: c9          .

L196a:	ldax	d		;; 196a: 1a          .
	inx	d		;; 196b: 13          .
	mov	b,a		;; 196c: 47          G
	mov	a,m		;; 196d: 7e          ~
	inx	h		;; 196e: 23          #
	jmp	L1979		;; 196f: c3 79 19    .y.

L1972:	xchg			;; 1972: eb          .
	mov	b,m		;; 1973: 46          F
	xchg			;; 1974: eb          .
	inx	d		;; 1975: 13          .
	jmp	L1979		;; 1976: c3 79 19    .y.

L1979:	mov	c,a		;; 1979: 4f          O
	ora	b		;; 197a: b0          .
	rz			;; 197b: c8          .
	inr	c		;; 197c: 0c          .
	dcr	c		;; 197d: 0d          .
	jz	L1993		;; 197e: ca 93 19    ...
	inr	b		;; 1981: 04          .
	dcr	b		;; 1982: 05          .
	jz	L199f		;; 1983: ca 9f 19    ...
L1986:	ldax	d		;; 1986: 1a          .
	sub	m		;; 1987: 96          .
	rnz			;; 1988: c0          .
	inx	d		;; 1989: 13          .
	inx	h		;; 198a: 23          #
	dcr	b		;; 198b: 05          .
	jz	L199d		;; 198c: ca 9d 19    ...
	dcr	c		;; 198f: 0d          .
	jnz	L1986		;; 1990: c2 86 19    ...
L1993:	ldax	d		;; 1993: 1a          .
	sui	020h		;; 1994: d6 20       . 
	rnz			;; 1996: c0          .
	inx	d		;; 1997: 13          .
	dcr	b		;; 1998: 05          .
	jnz	L1993		;; 1999: c2 93 19    ...
	ret			;; 199c: c9          .

L199d:	dcr	c		;; 199d: 0d          .
	rz			;; 199e: c8          .
L199f:	mvi	a,020h		;; 199f: 3e 20       > 
	sub	m		;; 19a1: 96          .
	rnz			;; 19a2: c0          .
	inx	h		;; 19a3: 23          #
	jmp	L199d		;; 19a4: c3 9d 19    ...

L19a7:	xchg			;; 19a7: eb          .
	lxi	h,00002h	;; 19a8: 21 02 00    ...
	dad	sp		;; 19ab: 39          9
	push	h		;; 19ac: e5          .
	mov	c,a		;; 19ad: 4f          O
	add	l		;; 19ae: 85          .
	mov	l,a		;; 19af: 6f          o
	mvi	a,000h		;; 19b0: 3e 00       >.
	adc	h		;; 19b2: 8c          .
	mov	h,a		;; 19b3: 67          g
	xthl			;; 19b4: e3          .
	xchg			;; 19b5: eb          .
	mov	a,c		;; 19b6: 79          y
	call	L19c1		;; 19b7: cd c1 19    ...
	pop	h		;; 19ba: e1          .
	pop	d		;; 19bb: d1          .
	sphl			;; 19bc: f9          .
	xchg			;; 19bd: eb          .
	pchl			;; 19be: e9          .

	ldax	d		;; 19bf: 1a          .
	inx	d		;; 19c0: 13          .
L19c1:	push	h		;; 19c1: e5          .
	push	psw		;; 19c2: f5          .
	mov	a,m		;; 19c3: 7e          ~
	push	psw		;; 19c4: f5          .
	inx	h		;; 19c5: 23          #
	add	l		;; 19c6: 85          .
	mov	l,a		;; 19c7: 6f          o
	mvi	a,000h		;; 19c8: 3e 00       >.
	adc	h		;; 19ca: 8c          .
	mov	h,a		;; 19cb: 67          g
	mov	a,b		;; 19cc: 78          x
	pop	b		;; 19cd: c1          .
	sub	b		;; 19ce: 90          .
	mov	b,a		;; 19cf: 47          G
	pop	psw		;; 19d0: f1          .
	cmp	b		;; 19d1: b8          .
	jnc	L19d6		;; 19d2: d2 d6 19    ...
	mov	b,a		;; 19d5: 47          G
L19d6:	call	L1a74		;; 19d6: cd 74 1a    .t.
	pop	h		;; 19d9: e1          .
	add	m		;; 19da: 86          .
	mov	m,a		;; 19db: 77          w
	ret			;; 19dc: c9          .

	mov	b,m		;; 19dd: 46          F
	inx	h		;; 19de: 23          #
L19df:	xchg			;; 19df: eb          .
	pop	h		;; 19e0: e1          .
	shld	L3ccb		;; 19e1: 22 cb 3c    ".<
	xchg			;; 19e4: eb          .
	push	psw		;; 19e5: f5          .
	mov	a,b		;; 19e6: 78          x
	call	L1a17		;; 19e7: cd 17 1a    ...
	call	L19f1		;; 19ea: cd f1 19    ...
	lhld	L3ccb		;; 19ed: 2a cb 3c    *.<
	pchl			;; 19f0: e9          .

L19f1:	lxi	h,00002h	;; 19f1: 21 02 00    ...
	dad	sp		;; 19f4: 39          9
	mov	b,a		;; 19f5: 47          G
	add	l		;; 19f6: 85          .
	mov	e,a		;; 19f7: 5f          _
	mvi	a,000h		;; 19f8: 3e 00       >.
	adc	h		;; 19fa: 8c          .
	mov	d,a		;; 19fb: 57          W
	inx	d		;; 19fc: 13          .
	ldax	d		;; 19fd: 1a          .
	add	b		;; 19fe: 80          .
	mov	c,a		;; 19ff: 4f          O
	mov	h,d		;; 1a00: 62          b
	mov	l,e		;; 1a01: 6b          k
	dcx	h		;; 1a02: 2b          +
	dcx	h		;; 1a03: 2b          +
	inr	b		;; 1a04: 04          .
	dcr	b		;; 1a05: 05          .
	jz	L1a11		;; 1a06: ca 11 1a    ...
L1a09:	mov	a,m		;; 1a09: 7e          ~
	stax	d		;; 1a0a: 12          .
	dcx	d		;; 1a0b: 1b          .
	dcx	h		;; 1a0c: 2b          +
	dcr	b		;; 1a0d: 05          .
	jnz	L1a09		;; 1a0e: c2 09 1a    ...
L1a11:	pop	h		;; 1a11: e1          .
	pop	d		;; 1a12: d1          .
	mov	a,c		;; 1a13: 79          y
	pchl			;; 1a14: e9          .

	mov	a,m		;; 1a15: 7e          ~
	inx	h		;; 1a16: 23          #
L1a17:	ora	a		;; 1a17: b7          .
	rz			;; 1a18: c8          .
	pop	b		;; 1a19: c1          .
	xchg			;; 1a1a: eb          .
	cma			;; 1a1b: 2f          /
	inr	a		;; 1a1c: 3c          <
	mov	l,a		;; 1a1d: 6f          o
	mvi	h,0ffh		;; 1a1e: 26 ff       &.
	dad	sp		;; 1a20: 39          9
	sphl			;; 1a21: f9          .
	push	b		;; 1a22: c5          .
	cma			;; 1a23: 2f          /
	inr	a		;; 1a24: 3c          <
	mov	b,a		;; 1a25: 47          G
	call	L1a74		;; 1a26: cd 74 1a    .t.
	ret			;; 1a29: c9          .

L1a2a:	push	psw		;; 1a2a: f5          .
	mov	c,a		;; 1a2b: 4f          O
	mov	a,b		;; 1a2c: 78          x
	mov	b,c		;; 1a2d: 41          A
	xchg			;; 1a2e: eb          .
	lxi	h,00004h	;; 1a2f: 21 04 00    ...
	dad	sp		;; 1a32: 39          9
	xchg			;; 1a33: eb          .
	call	L1a74		;; 1a34: cd 74 1a    .t.
	pop	h		;; 1a37: e1          .
	mov	l,h		;; 1a38: 6c          l
	mvi	h,000h		;; 1a39: 26 00       &.
	pop	d		;; 1a3b: d1          .
	dad	sp		;; 1a3c: 39          9
	sphl			;; 1a3d: f9          .
	xchg			;; 1a3e: eb          .
	pchl			;; 1a3f: e9          .

L1a40:	cmp	b		;; 1a40: b8          .
	jnc	L1a45		;; 1a41: d2 45 1a    .E.
	mov	b,a		;; 1a44: 47          G
L1a45:	push	psw		;; 1a45: f5          .
	push	h		;; 1a46: e5          .
	inx	h		;; 1a47: 23          #
	xchg			;; 1a48: eb          .
	lxi	h,00006h	;; 1a49: 21 06 00    ...
	dad	sp		;; 1a4c: 39          9
	xchg			;; 1a4d: eb          .
	mov	c,a		;; 1a4e: 4f          O
	mov	a,b		;; 1a4f: 78          x
	mov	b,c		;; 1a50: 41          A
	call	L1a74		;; 1a51: cd 74 1a    .t.
	pop	h		;; 1a54: e1          .
	mov	m,a		;; 1a55: 77          w
	pop	psw		;; 1a56: f1          .
	mov	l,a		;; 1a57: 6f          o
	mvi	h,000h		;; 1a58: 26 00       &.
	pop	d		;; 1a5a: d1          .
	dad	sp		;; 1a5b: 39          9
	sphl			;; 1a5c: f9          .
	xchg			;; 1a5d: eb          .
	pchl			;; 1a5e: e9          .

L1a5f:	xchg			;; 1a5f: eb          .
	mov	b,m		;; 1a60: 46          F
	inx	h		;; 1a61: 23          #
	xchg			;; 1a62: eb          .
L1a63:	push	h		;; 1a63: e5          .
	inx	h		;; 1a64: 23          #
	cmp	b		;; 1a65: b8          .
	jc	L1a6a		;; 1a66: da 6a 1a    .j.
	mov	a,b		;; 1a69: 78          x
L1a6a:	call	L1a74		;; 1a6a: cd 74 1a    .t.
	pop	h		;; 1a6d: e1          .
	mov	m,a		;; 1a6e: 77          w
	ret			;; 1a6f: c9          .

L1a70:	xchg			;; 1a70: eb          .
	mov	b,m		;; 1a71: 46          F
	xchg			;; 1a72: eb          .
	inx	d		;; 1a73: 13          .
L1a74:	cmp	b		;; 1a74: b8          .
	jnc	L1a79		;; 1a75: d2 79 1a    .y.
	mov	b,a		;; 1a78: 47          G
L1a79:	push	psw		;; 1a79: f5          .
	mov	c,a		;; 1a7a: 4f          O
	dcr	b		;; 1a7b: 05          .
	inr	b		;; 1a7c: 04          .
	jz	L1a89		;; 1a7d: ca 89 1a    ...
L1a80:	ldax	d		;; 1a80: 1a          .
	mov	m,a		;; 1a81: 77          w
	inx	d		;; 1a82: 13          .
	inx	h		;; 1a83: 23          #
	dcr	c		;; 1a84: 0d          .
	dcr	b		;; 1a85: 05          .
	jnz	L1a80		;; 1a86: c2 80 1a    ...
L1a89:	pop	psw		;; 1a89: f1          .
	inr	c		;; 1a8a: 0c          .
L1a8b:	dcr	c		;; 1a8b: 0d          .
	rz			;; 1a8c: c8          .
	mvi	m,020h		;; 1a8d: 36 20       6 
	inx	h		;; 1a8f: 23          #
	jmp	L1a8b		;; 1a90: c3 8b 1a    ...

L1a93:	ora	a		;; 1a93: b7          .
	rz			;; 1a94: c8          .
	mov	l,a		;; 1a95: 6f          o
	mvi	h,000h		;; 1a96: 26 00       &.
	dad	sp		;; 1a98: 39          9
	mov	b,h		;; 1a99: 44          D
	mov	c,l		;; 1a9a: 4d          M
	push	psw		;; 1a9b: f5          .
	mov	e,m		;; 1a9c: 5e          ^
	inx	h		;; 1a9d: 23          #
	mov	d,m		;; 1a9e: 56          V
	push	d		;; 1a9f: d5          .
	inx	h		;; 1aa0: 23          #
	mov	e,a		;; 1aa1: 5f          _
L1aa2:	dcx	b		;; 1aa2: 0b          .
	dcx	h		;; 1aa3: 2b          +
	ldax	b		;; 1aa4: 0a          .
	mov	m,a		;; 1aa5: 77          w
	dcr	e		;; 1aa6: 1d          .
	jnz	L1aa2		;; 1aa7: c2 a2 1a    ...
	pop	d		;; 1aaa: d1          .
	pop	psw		;; 1aab: f1          .
	sphl			;; 1aac: f9          .
	xchg			;; 1aad: eb          .
	pchl			;; 1aae: e9          .

L1aaf:	mov	a,e		;; 1aaf: 7b          {
	mov	b,l		;; 1ab0: 45          E
	push	h		;; 1ab1: e5          .
	call	L1ae3		;; 1ab2: cd e3 1a    ...
	xthl			;; 1ab5: e3          .
	push	h		;; 1ab6: e5          .
	mov	b,h		;; 1ab7: 44          D
	call	L1ae3		;; 1ab8: cd e3 1a    ...
	xthl			;; 1abb: e3          .
	push	h		;; 1abc: e5          .
	mov	a,d		;; 1abd: 7a          z
	mov	b,l		;; 1abe: 45          E
	call	L1ae3		;; 1abf: cd e3 1a    ...
	xthl			;; 1ac2: e3          .
	mov	b,h		;; 1ac3: 44          D
	call	L1ae3		;; 1ac4: cd e3 1a    ...
	mov	e,h		;; 1ac7: 5c          \
	mov	h,l		;; 1ac8: 65          e
	mvi	l,000h		;; 1ac9: 2e 00       ..
	pop	b		;; 1acb: c1          .
	dad	b		;; 1acc: 09          .
	jnc	L1ad1		;; 1acd: d2 d1 1a    ...
	inx	d		;; 1ad0: 13          .
L1ad1:	pop	b		;; 1ad1: c1          .
	dad	b		;; 1ad2: 09          .
	jnc	L1ad7		;; 1ad3: d2 d7 1a    ...
	inx	d		;; 1ad6: 13          .
L1ad7:	mov	d,e		;; 1ad7: 53          S
	mov	e,h		;; 1ad8: 5c          \
	mov	h,l		;; 1ad9: 65          e
	mvi	l,000h		;; 1ada: 2e 00       ..
	pop	b		;; 1adc: c1          .
	dad	b		;; 1add: 09          .
	jnc	L1ae2		;; 1ade: d2 e2 1a    ...
	inx	d		;; 1ae1: 13          .
L1ae2:	ret			;; 1ae2: c9          .

L1ae3:	mvi	l,000h		;; 1ae3: 2e 00       ..
	mov	c,b		;; 1ae5: 48          H
	mov	b,l		;; 1ae6: 45          E
	mov	h,a		;; 1ae7: 67          g
	dad	h		;; 1ae8: 29          )
	jnc	L1aed		;; 1ae9: d2 ed 1a    ...
	dad	b		;; 1aec: 09          .
L1aed:	dad	h		;; 1aed: 29          )
	jnc	L1af2		;; 1aee: d2 f2 1a    ...
	dad	b		;; 1af1: 09          .
L1af2:	dad	h		;; 1af2: 29          )
	jnc	L1af7		;; 1af3: d2 f7 1a    ...
	dad	b		;; 1af6: 09          .
L1af7:	dad	h		;; 1af7: 29          )
	jnc	L1afc		;; 1af8: d2 fc 1a    ...
	dad	b		;; 1afb: 09          .
L1afc:	dad	h		;; 1afc: 29          )
	jnc	L1b01		;; 1afd: d2 01 1b    ...
	dad	b		;; 1b00: 09          .
L1b01:	dad	h		;; 1b01: 29          )
	jnc	L1b06		;; 1b02: d2 06 1b    ...
	dad	b		;; 1b05: 09          .
L1b06:	dad	h		;; 1b06: 29          )
	jnc	L1b0b		;; 1b07: d2 0b 1b    ...
	dad	b		;; 1b0a: 09          .
L1b0b:	dad	h		;; 1b0b: 29          )
	jnc	L1b10		;; 1b0c: d2 10 1b    ...
	dad	b		;; 1b0f: 09          .
L1b10:	ret			;; 1b10: c9          .

L1b11:	mov	a,d		;; 1b11: 7a          z
	xra	h		;; 1b12: ac          .
	push	psw		;; 1b13: f5          .
	mov	a,h		;; 1b14: 7c          |
	ora	a		;; 1b15: b7          .
	cp	L1b4f		;; 1b16: f4 4f 1b    .O.
	mov	b,h		;; 1b19: 44          D
	mov	c,l		;; 1b1a: 4d          M
	xchg			;; 1b1b: eb          .
	mov	a,h		;; 1b1c: 7c          |
	ora	a		;; 1b1d: b7          .
	cm	L1b4f		;; 1b1e: fc 4f 1b    .O.
	call	L1b29		;; 1b21: cd 29 1b    .).
	pop	psw		;; 1b24: f1          .
	cm	L1b4f		;; 1b25: fc 4f 1b    .O.
	ret			;; 1b28: c9          .

L1b29:	xchg			;; 1b29: eb          .
	mov	a,b		;; 1b2a: 78          x
	ora	c		;; 1b2b: b1          .
	mvi	a,003h		;; 1b2c: 3e 03       >.
	jz	L1b7e		;; 1b2e: ca 7e 1b    .~.
	lxi	h,0		;; 1b31: 21 00 00    ...
	mvi	a,010h		;; 1b34: 3e 10       >.
L1b36:	xchg			;; 1b36: eb          .
	dad	h		;; 1b37: 29          )
	jnc	L1b3c		;; 1b38: d2 3c 1b    .<.
	inx	d		;; 1b3b: 13          .
L1b3c:	xchg			;; 1b3c: eb          .
	push	h		;; 1b3d: e5          .
	dad	b		;; 1b3e: 09          .
	jnc	L1b44		;; 1b3f: d2 44 1b    .D.
	inx	d		;; 1b42: 13          .
	xthl			;; 1b43: e3          .
L1b44:	pop	h		;; 1b44: e1          .
	dcr	a		;; 1b45: 3d          =
	jz	L1b4d		;; 1b46: ca 4d 1b    .M.
	dad	h		;; 1b49: 29          )
	jmp	L1b36		;; 1b4a: c3 36 1b    .6.

L1b4d:	xchg			;; 1b4d: eb          .
	ret			;; 1b4e: c9          .

L1b4f:	xra	a		;; 1b4f: af          .
	sub	l		;; 1b50: 95          .
	mov	l,a		;; 1b51: 6f          o
	mvi	a,000h		;; 1b52: 3e 00       >.
	sbb	h		;; 1b54: 9c          .
	mov	h,a		;; 1b55: 67          g
	ret			;; 1b56: c9          .

L1b57:	mov	a,e		;; 1b57: 7b          {
	sub	l		;; 1b58: 95          .
	mov	l,a		;; 1b59: 6f          o
	mov	a,d		;; 1b5a: 7a          z
	sbb	h		;; 1b5b: 9c          .
	mov	h,a		;; 1b5c: 67          g
	ret			;; 1b5d: c9          .

L1b5e:	lxi	h,L1b64		;; 1b5e: 21 64 1b    .d.
	jmp	L1d84		;; 1b61: c3 84 1d    ...

; parameter structure...
L1b64:	dw	L1b6c
	dw	L1b6d
	dw	L1b6e
	dw	L1b70
; parameter data...
L1b6c:	db	0
L1b6d:	db	1
L1b6e:	dw	00000h
L1b70:	dw	L1b72

L1b72:	db	' Conversion',0

L1b7e:	sta	L1b90		;; 1b7e: 32 90 1b    2..
	lxi	h,L1b87		;; 1b81: 21 87 1b    ...
	jmp	L1d84		;; 1b84: c3 84 1d    ...

L1b87:	dw	L1b8f
	dw	L1b90
	dw	L1b91
	dw	L1b93
L1b8f:	db	4
L1b90:	db	1
L1b91:	db	0,0
L1b93:	db	0,0
	push	h		;; 1b95: e5          .
	push	psw		;; 1b96: f5          .
	lhld	L3d25		;; 1b97: 2a 25 3d    *%=
	mov	a,h		;; 1b9a: 7c          |
	ora	l		;; 1b9b: b5          .
	jz	L1bc3		;; 1b9c: ca c3 1b    ...
	push	h		;; 1b9f: e5          .
	mov	e,m		;; 1ba0: 5e          ^
	inx	h		;; 1ba1: 23          #
	mov	d,m		;; 1ba2: 56          V
	xchg			;; 1ba3: eb          .
	shld	L3d25		;; 1ba4: 22 25 3d    "%=
	xchg			;; 1ba7: eb          .
	inx	h		;; 1ba8: 23          #
	inx	h		;; 1ba9: 23          #
	inx	h		;; 1baa: 23          #
	mov	e,m		;; 1bab: 5e          ^
	inx	h		;; 1bac: 23          #
	mov	d,m		;; 1bad: 56          V
	inx	h		;; 1bae: 23          #
	mov	c,m		;; 1baf: 4e          N
	inx	h		;; 1bb0: 23          #
	mov	b,m		;; 1bb1: 46          F
L1bb2:	mov	a,b		;; 1bb2: 78          x
	ora	c		;; 1bb3: b1          .
	jz	L1bbf		;; 1bb4: ca bf 1b    ...
	dcx	b		;; 1bb7: 0b          .
	inx	h		;; 1bb8: 23          #
	mov	a,m		;; 1bb9: 7e          ~
	stax	d		;; 1bba: 12          .
	inx	d		;; 1bbb: 13          .
	jmp	L1bb2		;; 1bbc: c3 b2 1b    ...

L1bbf:	pop	h		;; 1bbf: e1          .
	call	L1cc6		;; 1bc0: cd c6 1c    ...
L1bc3:	pop	psw		;; 1bc3: f1          .
	pop	h		;; 1bc4: e1          .
	ret			;; 1bc5: c9          .

L1bc6:	lhld	L3d25		;; 1bc6: 2a 25 3d    *%=
	mov	a,h		;; 1bc9: 7c          |
	ora	l		;; 1bca: b5          .
	jz	L1bed		;; 1bcb: ca ed 1b    ...
	push	h		;; 1bce: e5          .
	mov	e,m		;; 1bcf: 5e          ^
	inx	h		;; 1bd0: 23          #
	mov	d,m		;; 1bd1: 56          V
	inx	h		;; 1bd2: 23          #
	mov	c,m		;; 1bd3: 4e          N
	inx	h		;; 1bd4: 23          #
	mov	b,m		;; 1bd5: 46          F
	lxi	h,00004h	;; 1bd6: 21 04 00    ...
	dad	sp		;; 1bd9: 39          9
	mov	a,c		;; 1bda: 79          y
	sub	l		;; 1bdb: 95          .
	mov	a,b		;; 1bdc: 78          x
	sbb	h		;; 1bdd: 9c          .
	pop	h		;; 1bde: e1          .
	jnc	L1bed		;; 1bdf: d2 ed 1b    ...
	xchg			;; 1be2: eb          .
	shld	L3d25		;; 1be3: 22 25 3d    "%=
	xchg			;; 1be6: eb          .
	call	L1cc6		;; 1be7: cd c6 1c    ...
	jmp	L1bc6		;; 1bea: c3 c6 1b    ...

L1bed:	lda	L234c		;; 1bed: 3a 4c 23    :L#
	ora	a		;; 1bf0: b7          .
	jz	L1c0a		;; 1bf1: ca 0a 1c    ...
	lxi	h,00002h	;; 1bf4: 21 02 00    ...
	dad	sp		;; 1bf7: 39          9
	xchg			;; 1bf8: eb          .
	lxi	h,L238d		;; 1bf9: 21 8d 23    ..#
	mov	a,e		;; 1bfc: 7b          {
	sub	m		;; 1bfd: 96          .
	mov	a,d		;; 1bfe: 7a          z
	inx	h		;; 1bff: 23          #
	sbb	m		;; 1c00: 9e          .
	jc	L1c0a		;; 1c01: da 0a 1c    ...
	call	L20e5		;; 1c04: cd e5 20    .. 
	jmp	L1bed		;; 1c07: c3 ed 1b    ...

L1c0a:	lxi	h,00001h	;; 1c0a: 21 01 00    ...
	jmp	L1c13		;; 1c0d: c3 13 1c    ...

L1c10:	lxi	h,00002h	;; 1c10: 21 02 00    ...
L1c13:	dad	sp		;; 1c13: 39          9
	xchg			;; 1c14: eb          .
L1c15:	lda	L235d		;; 1c15: 3a 5d 23    :]#
	ora	a		;; 1c18: b7          .
	rz			;; 1c19: c8          .
	mov	c,a		;; 1c1a: 4f          O
	mvi	b,000h		;; 1c1b: 06 00       ..
	lxi	h,L235e		;; 1c1d: 21 5e 23    .^#
	dcx	b		;; 1c20: 0b          .
	dad	b		;; 1c21: 09          .
	dad	b		;; 1c22: 09          .
	mov	a,e		;; 1c23: 7b          {
	sub	m		;; 1c24: 96          .
	inx	h		;; 1c25: 23          #
	mov	a,d		;; 1c26: 7a          z
	sbb	m		;; 1c27: 9e          .
	rc			;; 1c28: d8          .
	lxi	h,L235d		;; 1c29: 21 5d 23    .]#
	dcr	m		;; 1c2c: 35          5
	jmp	L1c15		;; 1c2d: c3 15 1c    ...

	inx	h		;; 1c30: 23          #
	mov	a,l		;; 1c31: 7d          }
	ani	0feh		;; 1c32: e6 fe       ..
	mov	c,a		;; 1c34: 4f          O
	mov	b,h		;; 1c35: 44          D
	lhld	L3d23		;; 1c36: 2a 23 3d    *#=
L1c39:	mov	a,m		;; 1c39: 7e          ~
	rar			;; 1c3a: 1f          .
	jnc	L1c72		;; 1c3b: d2 72 1c    .r.
L1c3e:	inx	h		;; 1c3e: 23          #
	inx	h		;; 1c3f: 23          #
	mov	a,m		;; 1c40: 7e          ~
	inx	h		;; 1c41: 23          #
	mov	h,m		;; 1c42: 66          f
	mov	l,a		;; 1c43: 6f          o
	ora	h		;; 1c44: b4          .
	jnz	L1c39		;; 1c45: c2 39 1c    .9.
	lxi	h,L1c4e		;; 1c48: 21 4e 1c    .N.
	jmp	L1d84		;; 1c4b: c3 84 1d    ...

L1c4e:	dw	L1c56
	dw	L1c57
	dw	L1c58
	dw	L1c5a
L1c56:	db	0
L1c57:	db	7
L1c58:	db	0,0
L1c5a:	dw	L1c5c
L1c5c:	db	' Free Space Exhausted',0
L1c72:	push	h		;; 1c72: e5          .
	inx	h		;; 1c73: 23          #
	inx	h		;; 1c74: 23          #
	mov	e,m		;; 1c75: 5e          ^
	inx	h		;; 1c76: 23          #
	mov	d,m		;; 1c77: 56          V
	inx	h		;; 1c78: 23          #
	mov	a,e		;; 1c79: 7b          {
	sub	l		;; 1c7a: 95          .
	mov	e,a		;; 1c7b: 5f          _
	mov	a,d		;; 1c7c: 7a          z
	sbb	h		;; 1c7d: 9c          .
	mov	d,a		;; 1c7e: 57          W
	jc	L1d3b		;; 1c7f: da 3b 1d    .;.
	mov	a,e		;; 1c82: 7b          {
	sub	c		;; 1c83: 91          .
	mov	e,a		;; 1c84: 5f          _
	mov	a,d		;; 1c85: 7a          z
	sbb	b		;; 1c86: 98          .
	mov	d,a		;; 1c87: 57          W
	pop	h		;; 1c88: e1          .
	jc	L1c3e		;; 1c89: da 3e 1c    .>.
	inr	m		;; 1c8c: 34          4
	mov	a,d		;; 1c8d: 7a          z
	ora	a		;; 1c8e: b7          .
	jnz	L1c98		;; 1c8f: c2 98 1c    ...
	mov	a,e		;; 1c92: 7b          {
	cpi	006h		;; 1c93: fe 06       ..
	jc	L1cc1		;; 1c95: da c1 1c    ...
L1c98:	push	h		;; 1c98: e5          .
	inx	h		;; 1c99: 23          #
	inx	h		;; 1c9a: 23          #
	mov	e,m		;; 1c9b: 5e          ^
	inx	h		;; 1c9c: 23          #
	mov	d,m		;; 1c9d: 56          V
	inx	h		;; 1c9e: 23          #
	dad	b		;; 1c9f: 09          .
	xchg			;; 1ca0: eb          .
	xthl			;; 1ca1: e3          .
	push	h		;; 1ca2: e5          .
	inx	h		;; 1ca3: 23          #
	inx	h		;; 1ca4: 23          #
	mov	m,e		;; 1ca5: 73          s
	inx	h		;; 1ca6: 23          #
	mov	m,d		;; 1ca7: 72          r
	xchg			;; 1ca8: eb          .
	pop	d		;; 1ca9: d1          .
	mov	m,e		;; 1caa: 73          s
	inx	h		;; 1cab: 23          #
	mov	m,d		;; 1cac: 72          r
	inx	h		;; 1cad: 23          #
	xchg			;; 1cae: eb          .
	xthl			;; 1caf: e3          .
	xchg			;; 1cb0: eb          .
	mov	m,e		;; 1cb1: 73          s
	inx	h		;; 1cb2: 23          #
	mov	m,d		;; 1cb3: 72          r
	dcx	h		;; 1cb4: 2b          +
	dcx	h		;; 1cb5: 2b          +
	dcx	h		;; 1cb6: 2b          +
	xchg			;; 1cb7: eb          .
	mov	a,m		;; 1cb8: 7e          ~
	ani	001h		;; 1cb9: e6 01       ..
	mov	m,e		;; 1cbb: 73          s
	ora	m		;; 1cbc: b6          .
	mov	m,a		;; 1cbd: 77          w
	inx	h		;; 1cbe: 23          #
	mov	m,d		;; 1cbf: 72          r
	pop	h		;; 1cc0: e1          .
L1cc1:	inx	h		;; 1cc1: 23          #
	inx	h		;; 1cc2: 23          #
	inx	h		;; 1cc3: 23          #
	inx	h		;; 1cc4: 23          #
	ret			;; 1cc5: c9          .

L1cc6:	mov	a,l		;; 1cc6: 7d          }
	ora	h		;; 1cc7: b4          .
	rz			;; 1cc8: c8          .
	xchg			;; 1cc9: eb          .
	lhld	L3d23		;; 1cca: 2a 23 3d    *#=
	mov	a,l		;; 1ccd: 7d          }
	sub	e		;; 1cce: 93          .
	mov	a,h		;; 1ccf: 7c          |
	sbb	d		;; 1cd0: 9a          .
	jnc	L1d35		;; 1cd1: d2 35 1d    .5.
	lhld	00006h		;; 1cd4: 2a 06 00    *..
	mov	a,e		;; 1cd7: 7b          {
	sub	l		;; 1cd8: 95          .
	mov	a,d		;; 1cd9: 7a          z
	sbb	h		;; 1cda: 9c          .
	jnc	L1d35		;; 1cdb: d2 35 1d    .5.
	xchg			;; 1cde: eb          .
	dcx	h		;; 1cdf: 2b          +
	mov	b,m		;; 1ce0: 46          F
	dcx	h		;; 1ce1: 2b          +
	mov	c,m		;; 1ce2: 4e          N
	dcx	h		;; 1ce3: 2b          +
	mov	d,m		;; 1ce4: 56          V
	dcx	h		;; 1ce5: 2b          +
	dcr	m		;; 1ce6: 35          5
	mov	e,m		;; 1ce7: 5e          ^
	mov	a,e		;; 1ce8: 7b          {
	rar			;; 1ce9: 1f          .
	jc	L1d3b		;; 1cea: da 3b 1d    .;.
	mov	a,e		;; 1ced: 7b          {
	sub	l		;; 1cee: 95          .
	mov	a,d		;; 1cef: 7a          z
	sbb	h		;; 1cf0: 9c          .
	jnc	L1d3b		;; 1cf1: d2 3b 1d    .;.
	mov	a,l		;; 1cf4: 7d          }
	sub	c		;; 1cf5: 91          .
	mov	a,h		;; 1cf6: 7c          |
	sbb	b		;; 1cf7: 98          .
	jnc	L1d3b		;; 1cf8: d2 3b 1d    .;.
	mov	a,e		;; 1cfb: 7b          {
	ora	d		;; 1cfc: b2          .
	jz	L1d15		;; 1cfd: ca 15 1d    ...
	ldax	d		;; 1d00: 1a          .
	rar			;; 1d01: 1f          .
	jc	L1d15		;; 1d02: da 15 1d    ...
	mov	l,c		;; 1d05: 69          i
	mov	h,b		;; 1d06: 60          `
	mov	a,m		;; 1d07: 7e          ~
	ani	001h		;; 1d08: e6 01       ..
	mov	m,e		;; 1d0a: 73          s
	ora	m		;; 1d0b: b6          .
	mov	m,a		;; 1d0c: 77          w
	inx	h		;; 1d0d: 23          #
	mov	m,d		;; 1d0e: 72          r
	xchg			;; 1d0f: eb          .
	inx	h		;; 1d10: 23          #
	inx	h		;; 1d11: 23          #
	mov	m,c		;; 1d12: 71          q
	inx	h		;; 1d13: 23          #
	mov	m,b		;; 1d14: 70          p
L1d15:	ldax	b		;; 1d15: 0a          .
	rar			;; 1d16: 1f          .
	rc			;; 1d17: d8          .
	mov	l,c		;; 1d18: 69          i
	mov	h,b		;; 1d19: 60          `
	mov	c,m		;; 1d1a: 4e          N
	inx	h		;; 1d1b: 23          #
	mov	b,m		;; 1d1c: 46          F
	inx	h		;; 1d1d: 23          #
	mov	e,m		;; 1d1e: 5e          ^
	inx	h		;; 1d1f: 23          #
	mov	d,m		;; 1d20: 56          V
	xchg			;; 1d21: eb          .
	mov	a,m		;; 1d22: 7e          ~
	rar			;; 1d23: 1f          .
	jnc	L1d3b		;; 1d24: d2 3b 1d    .;.
	mov	m,c		;; 1d27: 71          q
	inr	m		;; 1d28: 34          4
	inx	h		;; 1d29: 23          #
	mov	m,b		;; 1d2a: 70          p
	dcx	h		;; 1d2b: 2b          +
	xchg			;; 1d2c: eb          .
	mov	l,c		;; 1d2d: 69          i
	mov	h,b		;; 1d2e: 60          `
	inx	h		;; 1d2f: 23          #
	inx	h		;; 1d30: 23          #
	mov	m,e		;; 1d31: 73          s
	inx	h		;; 1d32: 23          #
	mov	m,d		;; 1d33: 72          r
	ret			;; 1d34: c9          .

L1d35:	lxi	d,L1d41		;; 1d35: 11 41 1d    .A.
	jmp	L22cd		;; 1d38: c3 cd 22    .."

L1d3b:	lxi	d,L1d5d		;; 1d3b: 11 5d 1d    .].
	jmp	L22cd		;; 1d3e: c3 cd 22    .."

L1d41:	db	0dh,0ah,'FREE Request Out-of-Range$'
L1d5d:	db	0dh,0ah,'Free Space Overwrite$'

L1d74:	mov	b,a		;; 1d74: 47          G
	lxi	d,0		;; 1d75: 11 00 00    ...
	mov	c,e		;; 1d78: 4b          K
	cpi	005h		;; 1d79: fe 05       ..
	jnc	L1d9c		;; 1d7b: d2 9c 1d    ...
	mov	c,l		;; 1d7e: 4d          M
	mov	h,d		;; 1d7f: 62          b
	mov	l,e		;; 1d80: 6b          k
	jmp	L1d9c		;; 1d81: c3 9c 1d    ...

L1d84:	call	L1f69		;; 1d84: cd 69 1f    .i.
	mov	b,m		;; 1d87: 46          F
	call	L1f68		;; 1d88: cd 68 1f    .h.
	mov	c,m		;; 1d8b: 4e          N
	push	b		;; 1d8c: c5          .
	call	L1f68		;; 1d8d: cd 68 1f    .h.
	mov	c,m		;; 1d90: 4e          N
	inx	h		;; 1d91: 23          #
	mov	b,m		;; 1d92: 46          F
	push	b		;; 1d93: c5          .
	call	L1f68		;; 1d94: cd 68 1f    .h.
	mov	e,m		;; 1d97: 5e          ^
	inx	h		;; 1d98: 23          #
	mov	d,m		;; 1d99: 56          V
	pop	h		;; 1d9a: e1          .
	pop	b		;; 1d9b: c1          .
L1d9c:	shld	L23ad		;; 1d9c: 22 ad 23    ".#
	mov	a,c		;; 1d9f: 79          y
	sta	L23ac		;; 1da0: 32 ac 23    2.#
	push	b		;; 1da3: c5          .
	push	d		;; 1da4: d5          .
	push	h		;; 1da5: e5          .
	mov	a,b		;; 1da6: 78          x
	cpi	005h		;; 1da7: fe 05       ..
	jnc	L1daf		;; 1da9: d2 af 1d    ...
	mov	l,c		;; 1dac: 69          i
	mvi	h,000h		;; 1dad: 26 00       &.
L1daf:	call	L20a9		;; 1daf: cd a9 20    .. 
	jz	L1de6		;; 1db2: ca e6 1d    ...
	lxi	d,L1dba		;; 1db5: 11 ba 1d    ...
	push	d		;; 1db8: d5          .
	pchl			;; 1db9: e9          .

L1dba:	pop	h		;; 1dba: e1          .
	pop	d		;; 1dbb: d1          .
	pop	b		;; 1dbc: c1          .
	mov	a,b		;; 1dbd: 78          x
	cpi	008h		;; 1dbe: fe 08       ..
	jnz	L1dc6		;; 1dc0: c2 c6 1d    ...
	mvi	a,0ffh		;; 1dc3: 3e ff       >.
	ret			;; 1dc5: c9          .

L1dc6:	cpi	005h		;; 1dc6: fe 05       ..
	jc	L1de9		;; 1dc8: da e9 1d    ...
	xchg			;; 1dcb: eb          .
	lxi	h,L234a		;; 1dcc: 21 4a 23    .J#
	mov	a,e		;; 1dcf: 7b          {
	sub	m		;; 1dd0: 96          .
	rnz			;; 1dd1: c0          .
	inx	h		;; 1dd2: 23          #
	mov	a,d		;; 1dd3: 7a          z
	sub	m		;; 1dd4: 96          .
	rnz			;; 1dd5: c0          .
	lhld	L238b		;; 1dd6: 2a 8b 23    *.#
	push	h		;; 1dd9: e5          .
	lhld	L238d		;; 1dda: 2a 8d 23    *.#
	push	h		;; 1ddd: e5          .
	call	L20e5		;; 1dde: cd e5 20    .. 
	pop	h		;; 1de1: e1          .
	pop	d		;; 1de2: d1          .
	sphl			;; 1de3: f9          .
	xchg			;; 1de4: eb          .
	pchl			;; 1de5: e9          .

L1de6:	pop	h		;; 1de6: e1          .
	pop	d		;; 1de7: d1          .
	pop	b		;; 1de8: c1          .
L1de9:	mov	a,b		;; 1de9: 78          x
	sui	008h		;; 1dea: d6 08       ..
	rz			;; 1dec: c8          .
	mov	a,c		;; 1ded: 79          y
	ora	a		;; 1dee: b7          .
	mov	a,b		;; 1def: 78          x
	jp	L1df5		;; 1df0: f2 f5 1d    ...
	ora	a		;; 1df3: b7          .
	rz			;; 1df4: c8          .
L1df5:	push	d		;; 1df5: d5          .
	push	h		;; 1df6: e5          .
	push	b		;; 1df7: c5          .
	push	psw		;; 1df8: f5          .
	call	L1e4d		;; 1df9: cd 4d 1e    .M.
	pop	psw		;; 1dfc: f1          .
	mov	e,a		;; 1dfd: 5f          _
	mvi	d,000h		;; 1dfe: 16 00       ..
	lxi	h,L1f85		;; 1e00: 21 85 1f    ...
	dad	d		;; 1e03: 19          .
	dad	d		;; 1e04: 19          .
	mov	e,m		;; 1e05: 5e          ^
	inx	h		;; 1e06: 23          #
	mov	d,m		;; 1e07: 56          V
	xchg			;; 1e08: eb          .
	call	L1ea4		;; 1e09: cd a4 1e    ...
	call	L1e47		;; 1e0c: cd 47 1e    .G.
	mvi	a,028h		;; 1e0f: 3e 28       >(
	call	L1e49		;; 1e11: cd 49 1e    .I.
	pop	b		;; 1e14: c1          .
	mov	a,c		;; 1e15: 79          y
	call	L1e80		;; 1e16: cd 80 1e    ...
	mvi	a,029h		;; 1e19: 3e 29       >)
	call	L1e49		;; 1e1b: cd 49 1e    .I.
	pop	h		;; 1e1e: e1          .
	mov	a,h		;; 1e1f: 7c          |
	ora	l		;; 1e20: b5          .
	jz	L1e2a		;; 1e21: ca 2a 1e    .*.
	call	L1e3c		;; 1e24: cd 3c 1e    .<.
	call	L1f11		;; 1e27: cd 11 1f    ...
L1e2a:	pop	h		;; 1e2a: e1          .
	mov	a,h		;; 1e2b: 7c          |
	ora	l		;; 1e2c: b5          .
	jz	L1e36		;; 1e2d: ca 36 1e    .6.
	call	L1e3c		;; 1e30: cd 3c 1e    .<.
	call	L1ea4		;; 1e33: cd a4 1e    ...
L1e36:	call	L1eb6		;; 1e36: cd b6 1e    ...
	jmp	L22b2		;; 1e39: c3 b2 22    .."

L1e3c:	push	h		;; 1e3c: e5          .
	mvi	a,02ch		;; 1e3d: 3e 2c       >,
	call	L1e49		;; 1e3f: cd 49 1e    .I.
	call	L1e47		;; 1e42: cd 47 1e    .G.
	pop	h		;; 1e45: e1          .
	ret			;; 1e46: c9          .

L1e47:	mvi	a,020h		;; 1e47: 3e 20       > 
L1e49:	mov	e,a		;; 1e49: 5f          _
	jmp	L214f		;; 1e4a: c3 4f 21    .O.

L1e4d:	mvi	e,00dh		;; 1e4d: 1e 0d       ..
	call	L214f		;; 1e4f: cd 4f 21    .O.
	mvi	e,00ah		;; 1e52: 1e 0a       ..
	jmp	L214f		;; 1e54: c3 4f 21    .O.

L1e57:	ani	00fh		;; 1e57: e6 0f       ..
	adi	030h		;; 1e59: c6 30       .0
	cpi	03ah		;; 1e5b: fe 3a       .:
	jc	L1e49		;; 1e5d: da 49 1e    .I.
	adi	007h		;; 1e60: c6 07       ..
	jmp	L1e49		;; 1e62: c3 49 1e    .I.

L1e65:	push	psw		;; 1e65: f5          .
	rrc			;; 1e66: 0f          .
	rrc			;; 1e67: 0f          .
	rrc			;; 1e68: 0f          .
	rrc			;; 1e69: 0f          .
	call	L1e57		;; 1e6a: cd 57 1e    .W.
	pop	psw		;; 1e6d: f1          .
	jmp	L1e57		;; 1e6e: c3 57 1e    .W.

L1e71:	push	h		;; 1e71: e5          .
	call	L1e47		;; 1e72: cd 47 1e    .G.
	pop	h		;; 1e75: e1          .
	push	h		;; 1e76: e5          .
	mov	a,h		;; 1e77: 7c          |
	call	L1e65		;; 1e78: cd 65 1e    .e.
	pop	h		;; 1e7b: e1          .
	mov	a,l		;; 1e7c: 7d          }
	jmp	L1e65		;; 1e7d: c3 65 1e    .e.

L1e80:	cpi	00ah		;; 1e80: fe 0a       ..
	jc	L1e90		;; 1e82: da 90 1e    ...
	mvi	c,064h		;; 1e85: 0e 64       .d
	cmp	c		;; 1e87: b9          .
	cnc	L1e92		;; 1e88: d4 92 1e    ...
	mvi	c,00ah		;; 1e8b: 0e 0a       ..
	call	L1e92		;; 1e8d: cd 92 1e    ...
L1e90:	mvi	c,001h		;; 1e90: 0e 01       ..
L1e92:	mvi	b,000h		;; 1e92: 06 00       ..
L1e94:	cmp	c		;; 1e94: b9          .
	jc	L1e9d		;; 1e95: da 9d 1e    ...
	sub	c		;; 1e98: 91          .
	inr	b		;; 1e99: 04          .
	jmp	L1e94		;; 1e9a: c3 94 1e    ...

L1e9d:	push	psw		;; 1e9d: f5          .
	mov	a,b		;; 1e9e: 78          x
	call	L1e57		;; 1e9f: cd 57 1e    .W.
	pop	psw		;; 1ea2: f1          .
	ret			;; 1ea3: c9          .

L1ea4:	mov	c,m		;; 1ea4: 4e          N
	inr	c		;; 1ea5: 0c          .
L1ea6:	dcr	c		;; 1ea6: 0d          .
	rz			;; 1ea7: c8          .
	inx	h		;; 1ea8: 23          #
	mov	a,m		;; 1ea9: 7e          ~
	ora	a		;; 1eaa: b7          .
	rz			;; 1eab: c8          .
	push	b		;; 1eac: c5          .
	push	h		;; 1ead: e5          .
	call	L1e49		;; 1eae: cd 49 1e    .I.
	pop	h		;; 1eb1: e1          .
	pop	b		;; 1eb2: c1          .
	jmp	L1ea6		;; 1eb3: c3 a6 1e    ...

L1eb6:	lxi	h,L1f77		;; 1eb6: 21 77 1f    .w.
	call	L1ea4		;; 1eb9: cd a4 1e    ...
	lhld	L3d1d		;; 1ebc: 2a 1d 3d    *.=
	xchg			;; 1ebf: eb          .
	lxi	h,00002h	;; 1ec0: 21 02 00    ...
	dad	sp		;; 1ec3: 39          9
	mov	a,e		;; 1ec4: 7b          {
	sub	l		;; 1ec5: 95          .
	mov	e,a		;; 1ec6: 5f          _
	mov	a,d		;; 1ec7: 7a          z
	sbb	h		;; 1ec8: 9c          .
	jnz	L1ed7		;; 1ec9: c2 d7 1e    ...
	mov	a,e		;; 1ecc: 7b          {
	ora	a		;; 1ecd: b7          .
	rar			;; 1ece: 1f          .
	jc	L1ed7		;; 1ecf: da d7 1e    ...
	cpi	009h		;; 1ed2: fe 09       ..
	jc	L1eeb		;; 1ed4: da eb 1e    ...
L1ed7:	call	L1ee9		;; 1ed7: cd e9 1e    ...
	call	L1e47		;; 1eda: cd 47 1e    .G.
	mvi	a,023h		;; 1edd: 3e 23       >#
	call	L1e49		;; 1edf: cd 49 1e    .I.
	lhld	L3d1d		;; 1ee2: 2a 1d 3d    *.=
	lxi	d,0fff8h	;; 1ee5: 11 f8 ff    ...
	dad	d		;; 1ee8: 19          .
L1ee9:	mvi	a,004h		;; 1ee9: 3e 04       >.
L1eeb:	ora	a		;; 1eeb: b7          .
	rz			;; 1eec: c8          .
	dcr	a		;; 1eed: 3d          =
	mov	e,m		;; 1eee: 5e          ^
	inx	h		;; 1eef: 23          #
	mov	d,m		;; 1ef0: 56          V
	inx	h		;; 1ef1: 23          #
	push	h		;; 1ef2: e5          .
	push	psw		;; 1ef3: f5          .
	xchg			;; 1ef4: eb          .
	call	L1e71		;; 1ef5: cd 71 1e    .q.
	pop	psw		;; 1ef8: f1          .
	pop	h		;; 1ef9: e1          .
	jmp	L1eeb		;; 1efa: c3 eb 1e    ...

L1efd:	call	L1f02		;; 1efd: cd 02 1f    ...
	mvi	a,03ah		;; 1f00: 3e 3a       >:
L1f02:	push	h		;; 1f02: e5          .
	ani	07fh		;; 1f03: e6 7f       ..
	cpi	020h		;; 1f05: fe 20       . 
	jnc	L1f0c		;; 1f07: d2 0c 1f    ...
	mvi	a,03fh		;; 1f0a: 3e 3f       >?
L1f0c:	call	L1e49		;; 1f0c: cd 49 1e    .I.
	pop	h		;; 1f0f: e1          .
	ret			;; 1f10: c9          .

L1f11:	push	h		;; 1f11: e5          .
	lxi	h,L1f6f		;; 1f12: 21 6f 1f    .o.
	call	L1ea4		;; 1f15: cd a4 1e    ...
	pop	h		;; 1f18: e1          .
	push	h		;; 1f19: e5          .
	lxi	d,0001fh	;; 1f1a: 11 1f 00    ...
	dad	d		;; 1f1d: 19          .
	call	L1ea4		;; 1f1e: cd a4 1e    ...
	mvi	a,03dh		;; 1f21: 3e 3d       >=
	call	L1e49		;; 1f23: cd 49 1e    .I.
	pop	h		;; 1f26: e1          .
	mov	e,m		;; 1f27: 5e          ^
	inx	h		;; 1f28: 23          #
	mov	d,m		;; 1f29: 56          V
	xchg			;; 1f2a: eb          .
	mov	a,h		;; 1f2b: 7c          |
	ora	a		;; 1f2c: b7          .
	jnz	L1f41		;; 1f2d: c2 41 1f    .A.
	mov	a,l		;; 1f30: 7d          }
	cpi	006h		;; 1f31: fe 06       ..
	jc	L1f38		;; 1f33: da 38 1f    .8.
	mvi	l,006h		;; 1f36: 2e 06       ..
L1f38:	dad	h		;; 1f38: 29          )
	dad	h		;; 1f39: 29          )
	lxi	d,L1ff0		;; 1f3a: 11 f0 1f    ...
	dad	d		;; 1f3d: 19          .
	jmp	L1ea4		;; 1f3e: c3 a4 1e    ...

L1f41:	inx	h		;; 1f41: 23          #
	mov	b,m		;; 1f42: 46          F
	dcr	b		;; 1f43: 05          .
	mvi	a,041h		;; 1f44: 3e 41       >A
	add	b		;; 1f46: 80          .
	inr	b		;; 1f47: 04          .
	cnz	L1efd		;; 1f48: c4 fd 1e    ...
	mvi	a,00bh		;; 1f4b: 3e 0b       >.
L1f4d:	inx	h		;; 1f4d: 23          #
	push	psw		;; 1f4e: f5          .
	cpi	003h		;; 1f4f: fe 03       ..
	jnz	L1f5c		;; 1f51: c2 5c 1f    .\.
	mov	a,m		;; 1f54: 7e          ~
	cpi	020h		;; 1f55: fe 20       . 
	mvi	a,02eh		;; 1f57: 3e 2e       >.
	cnz	L1f02		;; 1f59: c4 02 1f    ...
L1f5c:	mov	a,m		;; 1f5c: 7e          ~
	cpi	020h		;; 1f5d: fe 20       . 
	cnz	L1f02		;; 1f5f: c4 02 1f    ...
	pop	psw		;; 1f62: f1          .
	dcr	a		;; 1f63: 3d          =
	rz			;; 1f64: c8          .
	jmp	L1f4d		;; 1f65: c3 4d 1f    .M.

L1f68:	xchg			;; 1f68: eb          .
L1f69:	mov	e,m		;; 1f69: 5e          ^
	inx	h		;; 1f6a: 23          #
	mov	d,m		;; 1f6b: 56          V
	inx	h		;; 1f6c: 23          #
	xchg			;; 1f6d: eb          .
	ret			;; 1f6e: c9          .

L1f6f:	db	' File: ',0
L1f77:	db	' ',0dh,0ah,'Traceback:',0
L1f85:	dw	L1f95
	dw	L1f9c
	dw	L1fac
	dw	L1fb6
	dw	L1fc1
	dw	L1fce
	dw	L1fdb
	dw	L1feb
L1f95:	db	' ERROR',0
L1f9c:	db	' FIXED OVERFLOW',0
L1fac:	db	' OVERFLOW',0
L1fb6:	db	' UNDERFLOW',0
L1fc1:	db	' ZERO DIVIDE',0
L1fce:	db	' END OF FILE',0
L1fdb:	db	' UNDEFINED FILE',0
L1feb:	db	' KEY',0
L1ff0:	db	3,'NUL',3,'CON',3,'CON',3,'RDR',3,'PUN',3,'LST',3,'BAD'
L200c:	mov	b,a		;; 200c: 47          G
	xchg			;; 200d: eb          .
	lxi	h,L235d		;; 200e: 21 5d 23    .]#
	mov	a,m		;; 2011: 7e          ~
	cpi	010h		;; 2012: fe 10       ..
	jc	L2038		;; 2014: da 38 20    .8 
	lxi	d,L201d		;; 2017: 11 1d 20    .. 
	jmp	L22cd		;; 201a: c3 cd 22    .."

L201d:	db	0dh,0ah,'Condition Stack Overflow$'
L2038:	inr	m		;; 2038: 34          4
	mov	c,a		;; 2039: 4f          O
	mov	a,b		;; 203a: 78          x
	mvi	b,000h		;; 203b: 06 00       ..
	lxi	h,L3ccd		;; 203d: 21 cd 3c    ..<
	dad	b		;; 2040: 09          .
	dad	b		;; 2041: 09          .
	dad	b		;; 2042: 09          .
	dad	b		;; 2043: 09          .
	dad	b		;; 2044: 09          .
	mov	m,a		;; 2045: 77          w
	inx	h		;; 2046: 23          #
	mov	m,e		;; 2047: 73          s
	inx	h		;; 2048: 23          #
	mov	m,d		;; 2049: 72          r
	inx	h		;; 204a: 23          #
	pop	d		;; 204b: d1          .
	push	d		;; 204c: d5          .
	inx	d		;; 204d: 13          .
	inx	d		;; 204e: 13          .
	inx	d		;; 204f: 13          .
	mov	m,e		;; 2050: 73          s
	inx	h		;; 2051: 23          #
	mov	m,d		;; 2052: 72          r
	lxi	h,00002h	;; 2053: 21 02 00    ...
	dad	sp		;; 2056: 39          9
	xchg			;; 2057: eb          .
	lxi	h,L235e		;; 2058: 21 5e 23    .^#
	dad	b		;; 205b: 09          .
	dad	b		;; 205c: 09          .
	mov	m,e		;; 205d: 73          s
	inx	h		;; 205e: 23          #
	mov	m,d		;; 205f: 72          r
	ret			;; 2060: c9          .

	xchg			;; 2061: eb          .
	lxi	h,L235d		;; 2062: 21 5d 23    .]#
	mov	c,m		;; 2065: 4e          N
	mvi	b,000h		;; 2066: 06 00       ..
	lxi	h,L3ccd		;; 2068: 21 cd 3c    ..<
	dad	b		;; 206b: 09          .
	dad	b		;; 206c: 09          .
	dad	b		;; 206d: 09          .
	dad	b		;; 206e: 09          .
	dad	b		;; 206f: 09          .
	inr	c		;; 2070: 0c          .
L2071:	dcr	c		;; 2071: 0d          .
	rz			;; 2072: c8          .
	inr	b		;; 2073: 04          .
	dcx	h		;; 2074: 2b          +
	dcx	h		;; 2075: 2b          +
	dcx	h		;; 2076: 2b          +
	dcx	h		;; 2077: 2b          +
	dcx	h		;; 2078: 2b          +
	cmp	m		;; 2079: be          .
	jnz	L2071		;; 207a: c2 71 20    .q 
	inx	h		;; 207d: 23          #
	mov	a,e		;; 207e: 7b          {
	cmp	m		;; 207f: be          .
	jnz	L208a		;; 2080: c2 8a 20    .. 
	inx	h		;; 2083: 23          #
	mov	a,d		;; 2084: 7a          z
	cmp	m		;; 2085: be          .
	jz	L208f		;; 2086: ca 8f 20    .. 
	dcx	h		;; 2089: 2b          +
L208a:	dcx	h		;; 208a: 2b          +
	mov	a,m		;; 208b: 7e          ~
	jmp	L2071		;; 208c: c3 71 20    .q 

L208f:	dcx	h		;; 208f: 2b          +
	dcx	h		;; 2090: 2b          +
	xchg			;; 2091: eb          .
	lxi	h,L235d		;; 2092: 21 5d 23    .]#
	dcr	m		;; 2095: 35          5
	lxi	h,00005h	;; 2096: 21 05 00    ...
	dad	d		;; 2099: 19          .
L209a:	dcr	b		;; 209a: 05          .
	rz			;; 209b: c8          .
	mvi	c,005h		;; 209c: 0e 05       ..
L209e:	mov	a,m		;; 209e: 7e          ~
	stax	d		;; 209f: 12          .
	inx	h		;; 20a0: 23          #
	inx	d		;; 20a1: 13          .
	dcr	c		;; 20a2: 0d          .
	jnz	L209e		;; 20a3: c2 9e 20    .. 
	jmp	L209a		;; 20a6: c3 9a 20    .. 

L20a9:	xchg			;; 20a9: eb          .
	lxi	h,L235d		;; 20aa: 21 5d 23    .]#
	mov	c,m		;; 20ad: 4e          N
	mvi	b,000h		;; 20ae: 06 00       ..
	lxi	h,L3ccd		;; 20b0: 21 cd 3c    ..<
	dad	b		;; 20b3: 09          .
	dad	b		;; 20b4: 09          .
	dad	b		;; 20b5: 09          .
	dad	b		;; 20b6: 09          .
	dad	b		;; 20b7: 09          .
	inr	c		;; 20b8: 0c          .
L20b9:	dcr	c		;; 20b9: 0d          .
	rz			;; 20ba: c8          .
	dcx	h		;; 20bb: 2b          +
	dcx	h		;; 20bc: 2b          +
	dcx	h		;; 20bd: 2b          +
	dcx	h		;; 20be: 2b          +
	dcx	h		;; 20bf: 2b          +
	cmp	m		;; 20c0: be          .
	jnz	L20b9		;; 20c1: c2 b9 20    .. 
	inx	h		;; 20c4: 23          #
	mov	a,m		;; 20c5: 7e          ~
	inx	h		;; 20c6: 23          #
	ora	m		;; 20c7: b6          .
	jz	L20dd		;; 20c8: ca dd 20    .. 
	dcx	h		;; 20cb: 2b          +
	mov	a,e		;; 20cc: 7b          {
	cmp	m		;; 20cd: be          .
	jnz	L20d8		;; 20ce: c2 d8 20    .. 
	inx	h		;; 20d1: 23          #
	mov	a,d		;; 20d2: 7a          z
	cmp	m		;; 20d3: be          .
	jz	L20dd		;; 20d4: ca dd 20    .. 
	dcx	h		;; 20d7: 2b          +
L20d8:	dcx	h		;; 20d8: 2b          +
	mov	a,m		;; 20d9: 7e          ~
	jmp	L20b9		;; 20da: c3 b9 20    .. 

L20dd:	inx	h		;; 20dd: 23          #
	mov	e,m		;; 20de: 5e          ^
	inx	h		;; 20df: 23          #
	mov	d,m		;; 20e0: 56          V
	xchg			;; 20e1: eb          .
	xra	a		;; 20e2: af          .
	dcr	a		;; 20e3: 3d          =
	ret			;; 20e4: c9          .

L20e5:	lxi	h,L234c		;; 20e5: 21 4c 23    .L#
	mov	a,m		;; 20e8: 7e          ~
	ora	a		;; 20e9: b7          .
	rz			;; 20ea: c8          .
	push	h		;; 20eb: e5          .
	call	L2139		;; 20ec: cd 39 21    .9.
	pop	h		;; 20ef: e1          .
	dcr	m		;; 20f0: 35          5
	lda	L234c		;; 20f1: 3a 4c 23    :L#
	ora	a		;; 20f4: b7          .
	rz			;; 20f5: c8          .
	mov	e,a		;; 20f6: 5f          _
	mvi	d,000h		;; 20f7: 16 00       ..
	dcx	d		;; 20f9: 1b          .
	lxi	h,L234d		;; 20fa: 21 4d 23    .M#
	dad	d		;; 20fd: 19          .
	dad	d		;; 20fe: 19          .
	mov	e,m		;; 20ff: 5e          ^
	inx	h		;; 2100: 23          #
	mov	d,m		;; 2101: 56          V
	xchg			;; 2102: eb          .
	shld	L234a		;; 2103: 22 4a 23    "J#
	lxi	d,L237e		;; 2106: 11 7e 23    .~#
	mvi	c,02eh		;; 2109: 0e 2e       ..
L210b:	mov	a,m		;; 210b: 7e          ~
	stax	d		;; 210c: 12          .
	inx	h		;; 210d: 23          #
	inx	d		;; 210e: 13          .
	dcr	c		;; 210f: 0d          .
	jnz	L210b		;; 2110: c2 0b 21    ...
	lhld	L239b		;; 2113: 2a 9b 23    *.#
	dad	h		;; 2116: 29          )
	dad	h		;; 2117: 29          )
	dad	h		;; 2118: 29          )
	dad	h		;; 2119: 29          )
	dad	h		;; 211a: 29          )
	lxi	d,L23b1		;; 211b: 11 b1 23    ..#
	mvi	c,009h		;; 211e: 0e 09       ..
L2120:	dad	h		;; 2120: 29          )
	mov	a,h		;; 2121: 7c          |
	stax	d		;; 2122: 12          .
	inx	d		;; 2123: 13          .
	dcr	c		;; 2124: 0d          .
	jnz	L2120		;; 2125: c2 20 21    . .
	lhld	L237e		;; 2128: 2a 7e 23    *~#
	mov	a,h		;; 212b: 7c          |
	ora	a		;; 212c: b7          .
	rnz			;; 212d: c0          .
	mov	a,l		;; 212e: 7d          }
	cpi	003h		;; 212f: fe 03       ..
	rnc			;; 2131: d0          .
	lhld	concol		;; 2132: 2a af 23    *.#
	shld	L2382		;; 2135: 22 82 23    ".#
	ret			;; 2138: c9          .

L2139:	lda	L234c		;; 2139: 3a 4c 23    :L#
	ora	a		;; 213c: b7          .
	rz			;; 213d: c8          .
	lhld	L234a		;; 213e: 2a 4a 23    *J#
	lxi	d,L237e		;; 2141: 11 7e 23    .~#
	mvi	c,01fh		;; 2144: 0e 1f       ..
L2146:	ldax	d		;; 2146: 1a          .
	mov	m,a		;; 2147: 77          w
	inx	d		;; 2148: 13          .
	inx	h		;; 2149: 23          #
	dcr	c		;; 214a: 0d          .
	jnz	L2146		;; 214b: c2 46 21    .F.
	ret			;; 214e: c9          .

L214f:	lhld	concol		;; 214f: 2a af 23    *.#
	mov	a,e		;; 2152: 7b          {
	cpi	' '		;; 2153: fe 20       . 
	jnc	L2160		;; 2155: d2 60 21    .`.
	cpi	cr		;; 2158: fe 0d       ..
	jnz	L2164		;; 215a: c2 64 21    .d.
	lxi	h,0		;; 215d: 21 00 00    ...
L2160:	inx	h		;; 2160: 23          #
	shld	concol		;; 2161: 22 af 23    ".#
L2164:	mvi	c,conout	;; 2164: 0e 02       ..
	jmp	bdos		;; 2166: c3 05 00    ...

L2169:	jmp	L2196		;; 2169: c3 96 21    ...

	db	'Copyright (c) 1980 Digital Research, v1.3 '
L2196:	lxi	h,0		;; 2196: 21 00 00    ...
	shld	L3d21		;; 2199: 22 21 3d    ".=
	shld	L3d1f		;; 219c: 22 1f 3d    ".=
	shld	L3d25		;; 219f: 22 25 3d    "%=
	xra	a		;; 21a2: af          .
	sta	L235d		;; 21a3: 32 5d 23    2]#
	sta	L234c		;; 21a6: 32 4c 23    2L#
	lhld	L3d27		;; 21a9: 2a 27 3d    *'=
	dad	b		;; 21ac: 09          .
	jc	L21d5		;; 21ad: da d5 21    ...
	pop	d		;; 21b0: d1          .
	sphl			;; 21b1: f9          .
	shld	L3d1d		;; 21b2: 22 1d 3d    ".=
	push	d		;; 21b5: d5          .
	lxi	b,0		;; 21b6: 01 00 00    ...
	mov	m,c		;; 21b9: 71          q
	inx	h		;; 21ba: 23          #
	mov	m,b		;; 21bb: 70          p
	inx	h		;; 21bc: 23          #
	inx	h		;; 21bd: 23          #
	mov	a,l		;; 21be: 7d          }
	ani	0feh		;; 21bf: e6 fe       ..
	mov	l,a		;; 21c1: 6f          o
	shld	L3d23		;; 21c2: 22 23 3d    "#=
	xchg			;; 21c5: eb          .
	lhld	00006h		;; 21c6: 2a 06 00    *..
	mov	a,l		;; 21c9: 7d          }
	ani	0feh		;; 21ca: e6 fe       ..
	mov	l,a		;; 21cc: 6f          o
	ani	0f8h		;; 21cd: e6 f8       ..
	sub	e		;; 21cf: 93          .
	mov	a,h		;; 21d0: 7c          |
	sbb	d		;; 21d1: 9a          .
	jnc	L21db		;; 21d2: d2 db 21    ...
L21d5:	lxi	d,L22d5		;; 21d5: 11 d5 22    .."
	jmp	L22cd		;; 21d8: c3 cd 22    .."

L21db:	xra	a		;; 21db: af          .
	dcx	h		;; 21dc: 2b          +
	mov	m,a		;; 21dd: 77          w
	dcx	h		;; 21de: 2b          +
	mov	m,a		;; 21df: 77          w
	dcx	h		;; 21e0: 2b          +
	mov	m,d		;; 21e1: 72          r
	dcx	h		;; 21e2: 2b          +
	mov	m,e		;; 21e3: 73          s
	inr	m		;; 21e4: 34          4
	xchg			;; 21e5: eb          .
	mov	m,a		;; 21e6: 77          w
	inx	h		;; 21e7: 23          #
	mov	m,a		;; 21e8: 77          w
	inx	h		;; 21e9: 23          #
	mov	m,e		;; 21ea: 73          s
	inx	h		;; 21eb: 23          #
	mov	m,d		;; 21ec: 72          r
	mvi	c,019h		;; 21ed: 0e 19       ..
	call	bdos		;; 21ef: cd 05 00    ...
	inr	a		;; 21f2: 3c          <
	sta	L3d29		;; 21f3: 32 29 3d    2)=
	ret			;; 21f6: c9          .

	push	h		;; 21f7: e5          .
	dcx	h		;; 21f8: 2b          +
	dcx	h		;; 21f9: 2b          +
	xchg			;; 21fa: eb          .
	lhld	L3d21		;; 21fb: 2a 21 3d    *.=
	xchg			;; 21fe: eb          .
	mov	m,e		;; 21ff: 73          s
	inx	h		;; 2200: 23          #
	mov	m,d		;; 2201: 72          r
	pop	h		;; 2202: e1          .
	shld	L3d21		;; 2203: 22 21 3d    ".=
	lhld	L3d1f		;; 2206: 2a 1f 3d    *.=
	inx	h		;; 2209: 23          #
	shld	L3d1f		;; 220a: 22 1f 3d    ".=
	ret			;; 220d: c9          .

; write records to file and close it
L220e:	xchg			;; 220e: eb          .
	lhld	L3d1f		;; 220f: 2a 1f 3d    *.=
	mov	b,h		;; 2212: 44          D
	mov	c,l		;; 2213: 4d          M
	lxi	h,L3d21		;; 2214: 21 21 3d    ..=
L2217:	mov	a,b		;; 2217: 78          x
	ora	c		;; 2218: b1          .
	rz			;; 2219: c8          .
	mov	a,m		;; 221a: 7e          ~
	cmp	e		;; 221b: bb          .
	jnz	L22a8		;; 221c: c2 a8 22    .."
	inx	h		;; 221f: 23          #
	ora	m		;; 2220: b6          .
	rz			;; 2221: c8          .
	mov	a,m		;; 2222: 7e          ~
	dcx	h		;; 2223: 2b          +
	cmp	d		;; 2224: ba          .
	jnz	L22a8		;; 2225: c2 a8 22    .."
	xchg			;; 2228: eb          .
	push	h		;; 2229: e5          .
	dcx	h		;; 222a: 2b          +
	mov	b,m		;; 222b: 46          F
	dcx	h		;; 222c: 2b          +
	mov	c,m		;; 222d: 4e          N
	pop	h		;; 222e: e1          .
	xchg			;; 222f: eb          .
	mov	m,c		;; 2230: 71          q
	inx	h		;; 2231: 23          #
	mov	m,b		;; 2232: 70          p
	lhld	L3d1f		;; 2233: 2a 1f 3d    *.=
	dcx	h		;; 2236: 2b          +
	shld	L3d1f		;; 2237: 22 1f 3d    ".=
	ldax	d		;; 223a: 1a          .
	ora	a		;; 223b: b7          .
	jz	L22a3		;; 223c: ca a3 22    .."
	cpi	003h		;; 223f: fe 03       ..
	jnc	L22a6		;; 2241: d2 a6 22    .."
	lxi	b,0		;; 2244: 01 00 00    ...
	dcr	a		;; 2247: 3d          =
	jnz	L2259		;; 2248: c2 59 22    .Y"
	lxi	h,0002bh	;; 224b: 21 2b 00    .+.
	dad	d		;; 224e: 19          .
	mov	a,m		;; 224f: 7e          ~
	ani	07fh		;; 2250: e6 7f       ..
	mov	c,a		;; 2252: 4f          O
	mov	a,m		;; 2253: 7e          ~
	ral			;; 2254: 17          .
	inx	h		;; 2255: 23          #
	mov	a,m		;; 2256: 7e          ~
	ral			;; 2257: 17          .
	mov	b,a		;; 2258: 47          G
L2259:	lxi	h,0000eh	;; 2259: 21 0e 00    ...
	dad	d		;; 225c: 19          .
	mvi	a,080h		;; 225d: 3e 80       >.
	sub	c		;; 225f: 91          .
	ani	07fh		;; 2260: e6 7f       ..
	mov	m,a		;; 2262: 77          w
	lxi	h,0002fh	;; 2263: 21 2f 00    ./.
	dad	d		;; 2266: 19          .
	inx	d		;; 2267: 13          .
; B=records, C=bytes (0-127)
L2268:	mov	a,b		;; 2268: 78          x
	ora	a		;; 2269: b7          .
	jnz	L2281		;; 226a: c2 81 22    .."
	mov	a,c		;; 226d: 79          y
	ora	a		;; 226e: b7          .
	jz	L229e		;; 226f: ca 9e 22    .."
	push	h		;; 2272: e5          .
	dad	b		;; 2273: 09          .
	mvi	a,128		;; 2274: 3e 80       >.
	sub	c		;; 2276: 91          .
	mov	c,a		;; 2277: 4f          O
L2278:	mvi	m,eof		;; 2278: 36 1a       6.
	inx	h		;; 227a: 23          #
	dcr	c		;; 227b: 0d          .
	jnz	L2278		;; 227c: c2 78 22    .x"
	pop	h		;; 227f: e1          .
	inr	b		;; 2280: 04          .
L2281:	dcr	b		;; 2281: 05          .
	push	b		;; 2282: c5          .
	push	h		;; 2283: e5          .
	lxi	b,128		;; 2284: 01 80 00    ...
	dad	b		;; 2287: 09          .
	xthl			;; 2288: e3          .
	push	d		;; 2289: d5          .
	xchg			;; 228a: eb          .
	mvi	c,setdma	;; 228b: 0e 1a       ..
	call	bdos		;; 228d: cd 05 00    ...
	pop	d		;; 2290: d1          .
	push	d		;; 2291: d5          .
	mvi	c,write		;; 2292: 0e 15       ..
	call	bdos		;; 2294: cd 05 00    ...
	pop	d		;; 2297: d1          .
	pop	h		;; 2298: e1          .
	pop	b		;; 2299: c1          .
	ora	a		;; 229a: b7          .
	jz	L2268		;; 229b: ca 68 22    .h"
L229e:	mvi	c,close		;; 229e: 0e 10       ..
	call	bdos		;; 22a0: cd 05 00    ...
L22a3:	xra	a		;; 22a3: af          .
	dcr	a		;; 22a4: 3d          =
	ret			;; 22a5: c9          .

L22a6:	xra	a		;; 22a6: af          .
	ret			;; 22a7: c9          .

L22a8:	dcx	b		;; 22a8: 0b          .
	mov	a,m		;; 22a9: 7e          ~
	inx	h		;; 22aa: 23          #
	mov	h,m		;; 22ab: 66          f
	mov	l,a		;; 22ac: 6f          o
	dcx	h		;; 22ad: 2b          +
	dcx	h		;; 22ae: 2b          +
	jmp	L2217		;; 22af: c3 17 22    .."

L22b2:	lxi	h,L3d1f		;; 22b2: 21 1f 3d    ..=
	mov	a,m		;; 22b5: 7e          ~
	inx	h		;; 22b6: 23          #
	ora	m		;; 22b7: b6          .
	jz	L22ca		;; 22b8: ca ca 22    .."
	lhld	L3d21		;; 22bb: 2a 21 3d    *.=
	call	L220e		;; 22be: cd 0e 22    .."
	jnz	L22b2		;; 22c1: c2 b2 22    .."
	lxi	d,L22eb		;; 22c4: 11 eb 22    .."
	jmp	L22cd		;; 22c7: c3 cd 22    .."

L22ca:	lxi	d,L22fd		;; 22ca: 11 fd 22    .."
L22cd:	mvi	c,print		;; 22cd: 0e 09       ..
	call	bdos		;; 22cf: cd 05 00    ...
	jmp	cpm		;; 22d2: c3 00 00    ...

L22d5:	db	0dh,0ah,'Insufficient Memory$'
L22eb:	db	0dh,0ah,'Invalid I/O List'
L22fd:	db	0dh,0ah,'End of Execution$',12h,'#',1,0,'d',0,0,0,1,0,'d',0
	db	0,0,0,0,0,'(Copyright (c) 1980 Digital Research V1.3'

L234a:	db	0,0
L234c:	db	0
L234d:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
L235d:	db	0
L235e:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0
L237e:	db	0,0,0,0
L2382:	db	0,0,0,0,0,0,0,0,0
L238b:	db	0,0
L238d:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0
L239b:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
L23ac:	db	0
L23ad:	db	0,0
concol:	dw	1
L23b1:	db	0,0,0,0,0,0,0,0,0
L23ba:	db	80h
L23bb:	db	0,0,0,0,'MXList  '
L23c7:	db	0,0,0,0,0,0,0,0,0
L23d0:	db	0,0,0
L23d3:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
L23e7:	db	0,0,0,0
L23eb:	db	0,0
L23ed:	db	80h
L23ee:	db	'SY'
L23f0:	db	'M'
L23f1:	db	0
L23f2:	db	0
L23f3:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0
L2bf1:	db	80h
L2bf2:	db	'd'
L2bf3:	db	'$P'
L2bf5:	db	'l'
L2bf6:	db	'PRINTER busy',0dh,0ah
L2c04:	db	'XREF 1.3',0dh,0ah
L2c0e:	db	'no SYM file',0dh,0ah
L2c1b:	db	'no PRN file',0dh,0ah
L2c28:	db	' '
L2c29:	db	0ch,'CP/M'
L2c2e:	db	0ch
L2c2f:	db	1ah
L2c30:	db	'PRN'
L2c33:	db	'XRF'
L2c36:	db	'ABORTED.',0dh,0ah
L2c40:	db	'  '
L2c42:	db	'  '
L2c44:	db	'                                                           '
	db	'                                                     ',0,0
	db	0,0,0,0,0,0,0,'V',0cdh,81h,0c9h,0,0,9,91h
L2cc5:	dcx	h		;; 2cc5: 2b          +
	adc	e		;; 2cc6: 8b          .
	ret			;; 2cc7: c9          .

	stax	b		;; 2cc8: 02          .
	sub	l		;; 2cc9: 95          .
	ret			;; 2cca: c9          .

	db	0,5,0,0,' ',1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah
	db	1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,'1',1ah,1ah,10h,'@+',8
	db	0d3h,8,0d3h,0,0,0ffh,1eh,3,5,'>',0,17h,8dh,0,4,0,0ddh,0,0a7h
	db	0d0h,0ch,0bh,0ah,0ch,6,1,4,7,8,9,0ah,0bh,0ch,0,0ch,3,1,6,3
	db	13h,14h,'FG',80h,'1',0fah,'"z',0b2h,'*',94h,0e0h,0,0,85h,'Q'
	db	14h,0d5h,'S',0d4h,' c',0f4h,'E5T',0f5h,9,'@',0,1,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0
L2d46:	db	0
L2d47:	db	0,0
L2d49:	db	0,0
L2d4b:	db	0
L2d4c:	db	0,0
L2d4e:	db	0,0
L2d50:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
L2f4e:	db	0
L2f4f:	db	0
L2f50:	db	0
L2f51:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
L2fd8:	db	0,0
L2fda:	db	0,0,0,0,0,0,0,0
L2fe2:	db	0,0,0,0,0,0
L2fe8:	dw	L2fd8
L2fea:	dw	L2fd8
L2fec:	dw	L2fee
L2fee:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0
L306f:	dw	L2cc5
L3071:	dw	L2cc5
L3073:	dw	L2c44
	dw	L2c42
	dw	L2d47
L3079:	dw	L2cc5
L307b:	dw	L2f51
L307d:	dw	L2c44
L307f:	dw	L2c44
L3081:	dw	L2d4c
L3083:	dw	L2cc5
L3085:	dw	L2c44
L3087:	dw	L2c44
	dw	L2d4e
	dw	L2d50
L308d:	dw	L2d4c
	dw	L2d4e
	dw	L2d50
	dw	L2d47
	dw	L2c40
	dw	L2d49
L3099:	dw	L2f50
	dw	L2f4f
	dw	L2f51
	dw	L2d47
	dw	L2d49
L30a3:	dw	L2c44
L30a5:	dw	00000h
L30a7:	dw	L30a9
L30a9:	dw	00000h
L30ab:	dw	00000h
L30ad:	db	0
L30ae:	db	0,0
L30b0:	dw	L30b2
L30b2:	dw	00000h
L30b4:	dw	L30b6
L30b6:	dw	00000h
L30b8:	dw	L2fd8
L30ba:	dw	L2fd8
L30bc:	dw	L2c44
L30be:	db	2,0
L30c0:	db	'symbol table overflow',0dh,0ah
L30d7:	db	'''',1
L30d9:	db	9
L30da:	db	0dh
L30db:	db	'invalid SYM file format',0dh,0ah
L30f4:	db	0,0
L30f6:	db	0,0
L30f8:	db	0,0
L30fa:	db	0,0
L30fc:	db	0,0,0,0
L3100:	db	0,0
L3102:	db	0,0
L3104:	db	0,0
L3106:	db	0,0
L3108:	db	0,0,0,0,0,0,0,0
L3110:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
L3121:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
L3132:	db	0
L3133:	db	0,0
L3135:	db	0
L3136:	db	0
L3137:	db	0
L3138:	db	0
L3139:	db	0
L313a:	db	0
L313b:	db	0,0
L313d:	db	0
L313e:	db	0,0,0
L3141:	db	0
L3142:	db	0
L3143:	db	0
L3144:	db	0,0
L3146:	db	0,0
L3148:	db	0,0,0,0,0,0,0,0,0
L3151:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,5,0,0,2,0,0,0,0,0,0,0,0,3,3,3,3,3,3,3,3,3,3,0,1
	db	0,0,0,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
	db	4,0,0,0,0,0,0,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
	db	4,4,4,0,0,0,0,0
L31d1:	dw	L09ba
	dw	L0af4
	dw	L0a9e
	dw	L0a7b
	dw	L09e0
	dw	L09ba
L31dd:	db	0,0
L31df:	db	0,0
L31e1:	db	0,0
L31e3:	db	'*'
L31e4:	db	'$'
L31e5:	db	''''
L31e6:	db	0,0
L31e8:	db	0,0
L31ea:	db	0,0
L31ec:	db	0
L31ed:	db	0,0
L31ef:	db	0
L31f0:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
L3201:	db	0
L3202:	db	0,0
L3204:	db	0,80h,80h,80h,80h,80h,0,0,80h,0,0,0,80h,80h,0,0
L3214:	db	80h
L3215:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0
L3237:	db	'symbol table reference overflow',0dh,0ah
L3258:	db	' '
L3259:	db	0,0
L325b:	db	0,0
L325d:	db	0,0
L325f:	db	0,0
L3261:	db	0,0
L3263:	db	0,0
L3265:	db	0,0
L3267:	db	0,0
L3269:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0
L32ea:	db	0,0
L32ec:	db	0,0
L32ee:	db	0,0
L32f0:	db	0
L32f1:	db	0,0
L32f3:	db	0,0
	dw	L32f0
	dw	L32ec
L32f9:	dw	L3269
L32fb:	db	0,0
L32fd:	db	0,0
L32ff:	db	0,0
L3301:	db	0,0
L3303:	db	0,0
L3305:	db	0
L3306:	db	0
L3307:	db	0,0
L3309:	db	0,0
L330b:	db	0,0
L330d:	db	0,0,0,0
L3311:	db	1,0ch
L3313:	db	' '
L3314:	db	'0'
L3315:	db	'#'
L3316:	db	0ah
L3317:	db	0dh,0ah
L3319:	db	0,0
L331b:	db	0,0
L331d:	db	0,0
L331f:	db	0,0
L3321:	db	0,0
L3323:	db	0,0
L3325:	db	0,0
L3327:	db	0,0
L3329:	db	0,0
L332b:	db	0
L332c:	db	0
L332d:	db	0
L332e:	db	0
L332f:	db	0,0,0,0,0,0
L3335:	db	0,0
L3337:	db	0,0
L3339:	db	0,0
L333b:	db	0
L333c:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
L334c:	db	0
L334d:	db	0,0,0,0
L3351:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0
L3390:	dw	L332b
L3392:	db	0
L3393:	dw	L3395
L3395:	db	0,0
L3397:	db	0,0
L3399:	db	0,0
L339b:	dw	L339d
L339d:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0
L341e:	db	0
L341f:	db	0,0,0,0,0,0,0,0
L3427:	db	0,0,0
L342a:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
L343e:	db	0,0,0,0
L3442:	db	0,0
L3444:	db	0
L3445:	db	0
L3446:	db	80h
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0
L3c47:	db	10h
L3c48:	db	'l'
L3c49:	db	'XRF'
L3c4c:	db	'.XRF make error',0dh,0ah
L3c5d:	db	1ah
L3c5e:	db	9
L3c5f:	db	' '
L3c60:	db	'''',1
L3c62:	db	1ah
L3c63:	db	'.XRF close error',0dh,0ah
L3c75:	db	'.XRF write error',0dh,0ah
L3c87:	db	0,0
L3c89:	db	0
L3c8a:	db	0
L3c8b:	db	0
L3c8c:	db	0,0
L3c8e:	db	0
L3c8f:	dw	L3c8c
L3c91:	dw	L3c93
L3c93:	dw	00000h
L3c95:	dw	L3c97
L3c97:	db	0,0
L3c99:	db	0,0
L3c9b:	db	0
L3c9c:	dw	L3c5f
L3c9e:	dw	L3c89
L3ca0:	db	0,0
L3ca2:	db	0
L3ca3:	dw	L3c62
L3ca5:	dw	L3c62
L3ca7:	dw	L3ca9
L3ca9:	db	0,0
L3cab:	db	0,0
L3cad:	db	0,0
L3caf:	db	0
L3cb0:	db	0,0
L3cb2:	db	0
L3cb3:	dw	L3cb5
L3cb5:	db	0,0
L3cb7:	dw	L3cb9
L3cb9:	db	0,0
L3cbb:	db	0,0
L3cbd:	db	0dh
L3cbe:	db	0,0
L3cc0:	db	0
L3cc1:	db	0
L3cc2:	dw	L3cc4
L3cc4:	db	0
L3cc5:	dw	L3cbd
L3cc7:	db	0,0
L3cc9:	db	0,0
L3ccb:	db	0,0
L3ccd:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
L3d1d:	db	0,0
L3d1f:	db	0,0
L3d21:	db	0,0
L3d23:	db	0,0
L3d25:	db	0,0
L3d27:	dw	L3d2a
L3d29:	db	0
L3d2a:	db	1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah
	db	1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah
	db	1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah
	db	1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah
	db	1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah
	db	1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah
	end
