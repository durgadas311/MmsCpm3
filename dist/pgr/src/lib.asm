; Disassembly of LIB.COM
; Originally Written in PL/M

cpm	equ	0
bdos	equ	5
deffcb	equ	005ch
defdma	equ	0080h
cmdlin	equ	0080h

cr	equ	13
lf	equ	10

conout	equ	2
const	equ	11
print	equ	9
open	equ	15
close	equ	16
delete	equ	19
read	equ	20
write	equ	21
make	equ	22
rename	equ	23
setdma	equ	26

	org	00100h
	jmp	L019e		;; 0100: c3 9e 01    ...

	db	'COPYRIGHT (C) 1980 DIGITAL RESEARCH ',0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0afh,0,0,0,14h,13h	; serial number

relsfx:	db	'REL'
irlsfx:	db	'IRL'
L018d:	db	'FATAL ERROR$'
L0199:	db	1,'l'
L019b:	db	'$'
L019c:	db	1,'l'

L019e:	lxi	sp,stack	;; 019e: 31 f0 19    1..
	call	L0a0d		;; 01a1: cd 0d 0a    ...
	call	L13ba		;; 01a4: cd ba 13    ...
	lxi	h,cmdbuf	;; 01a7: 21 12 1d    ...
	shld	cmdptr		;; 01aa: 22 b0 1a    "..
	lxi	h,L1ace		;; 01ad: 21 ce 1a    ...
	mvi	m,0		;; 01b0: 36 00       6.
	mvi	c,1		;; 01b2: 0e 01       ..
	call	L1302		;; 01b4: cd 02 13    ...
	call	L0793		;; 01b7: cd 93 07    ...
	lhld	cmdptr		;; 01ba: 2a b0 1a    *..
	mov	a,m		;; 01bd: 7e          ~
	cpi	'='		;; 01be: fe 3d       .=
	jnz	L01de		;; 01c0: c2 de 01    ...
	lda	L1abe		;; 01c3: 3a be 1a    :..
	lxi	h,L1abf		;; 01c6: 21 bf 1a    ...
	ora	m		;; 01c9: b6          .
	rar			;; 01ca: 1f          .
	jnc	L01d4		;; 01cb: d2 d4 01    ...
	lxi	b,L1af8		;; 01ce: 01 f8 1a    ...
	call	exitms		;; 01d1: cd a3 0a    ...
L01d4:	lxi	h,L1ab8		;; 01d4: 21 b8 1a    ...
	mvi	m,1		;; 01d7: 36 01       6.
	mvi	c,0		;; 01d9: 0e 00       ..
	call	L1302		;; 01db: cd 02 13    ...
L01de:	lda	L1ab8		;; 01de: 3a b8 1a    :..
	cma			;; 01e1: 2f          /
	rar			;; 01e2: 1f          .
	jnc	L021c		;; 01e3: d2 1c 02    ...
	lda	L1ab7		;; 01e6: 3a b7 1a    :..
	rar			;; 01e9: 1f          .
	jnc	L0206		;; 01ea: d2 06 02    ...
	lda	L1abe		;; 01ed: 3a be 1a    :..
	lxi	h,L1abf		;; 01f0: 21 bf 1a    ...
	ora	m		;; 01f3: b6          .
	rar			;; 01f4: 1f          .
	jnc	L01fe		;; 01f5: d2 fe 01    ...
	lxi	b,L1af8		;; 01f8: 01 f8 1a    ...
	call	exitms		;; 01fb: cd a3 0a    ...
L01fe:	lxi	h,L1ab8		;; 01fe: 21 b8 1a    ...
	mvi	m,1		;; 0201: 36 01       6.
	jmp	L021c		;; 0203: c3 1c 02    ...

L0206:	lda	L1aba		;; 0206: 3a ba 1a    :..
	lxi	h,L1ab6		;; 0209: 21 b6 1a    ...
	ora	m		;; 020c: b6          .
	lxi	h,L1ab9		;; 020d: 21 b9 1a    ...
	ora	m		;; 0210: b6          .
	cma			;; 0211: 2f          /
	rar			;; 0212: 1f          .
	jnc	L021c		;; 0213: d2 1c 02    ...
	lxi	b,L1af8		;; 0216: 01 f8 1a    ...
	call	exitms		;; 0219: cd a3 0a    ...
L021c:	call	L043c		;; 021c: cd 3c 04    .<.
	call	L09f9		;; 021f: cd f9 09    ...
	call	L04a7		;; 0222: cd a7 04    ...
	call	cpm		;; 0225: cd 00 00    ...
	ei			;; 0228: fb          .
	hlt			;; 0229: 76          v
L022a:	lxi	h,L1b0a		;; 022a: 21 0a 1b    ...
	mov	m,e		;; 022d: 73          s
	dcx	h		;; 022e: 2b          +
	mov	m,b		;; 022f: 70          p
	dcx	h		;; 0230: 2b          +
	mov	m,c		;; 0231: 71          q
	mvi	a,00ch		;; 0232: 3e 0c       >.
	lxi	d,memtop		;; 0234: 11 00 1a    ...
	call	subxxa		;; 0237: cd 8d 19    ...
	shld	L1ab4		;; 023a: 22 b4 1a    "..
L023d:	lxi	b,L1a02		;; 023d: 01 02 1a    ...
	lxi	d,L1ab4		;; 0240: 11 b4 1a    ...
	call	L1980		;; 0243: cd 80 19    ...
	jc	L0281		;; 0246: da 81 02    ...
	lhld	L1ab4		;; 0249: 2a b4 1a    *..
	mvi	a,007h		;; 024c: 3e 07       >.
	ana	m		;; 024e: a6          .
	lxi	h,L1b0a		;; 024f: 21 0a 1b    ...
	cmp	m		;; 0252: be          .
	jnz	L0271		;; 0253: c2 71 02    .q.
	lhld	L1b08		;; 0256: 2a 08 1b    *..
	push	h		;; 0259: e5          .
	lxi	b,00006h	;; 025a: 01 06 00    ...
	lhld	L1ab4		;; 025d: 2a b4 1a    *..
	dad	b		;; 0260: 09          .
	mov	b,h		;; 0261: 44          D
	mov	c,l		;; 0262: 4d          M
	lhld	L1b0a		;; 0263: 2a 0a 1b    *..
	xchg			;; 0266: eb          .
	call	compar		;; 0267: cd 31 16    .1.
	rar			;; 026a: 1f          .
	jnc	L0271		;; 026b: d2 71 02    .q.
	mvi	a,001h		;; 026e: 3e 01       >.
	ret			;; 0270: c9          .

L0271:	mvi	a,00ch		;; 0271: 3e 0c       >.
	lxi	d,L1ab4		;; 0273: 11 b4 1a    ...
	call	subxxa		;; 0276: cd 8d 19    ...
	xchg			;; 0279: eb          .
	dcx	h		;; 027a: 2b          +
	mov	m,e		;; 027b: 73          s
	inx	h		;; 027c: 23          #
	mov	m,d		;; 027d: 72          r
	jmp	L023d		;; 027e: c3 3d 02    .=.

L0281:	mvi	a,000h		;; 0281: 3e 00       >.
	ret			;; 0283: c9          .

L0284:	lxi	h,L1b10		;; 0284: 21 10 1b    ...
	mov	m,d		;; 0287: 72          r
	dcx	h		;; 0288: 2b          +
	mov	m,e		;; 0289: 73          s
	dcx	h		;; 028a: 2b          +
	mov	m,c		;; 028b: 71          q
	dcx	h		;; 028c: 2b          +
	pop	d		;; 028d: d1          .
	pop	b		;; 028e: c1          .
	mov	m,c		;; 028f: 71          q
	dcx	h		;; 0290: 2b          +
	pop	b		;; 0291: c1          .
	mov	m,b		;; 0292: 70          p
	dcx	h		;; 0293: 2b          +
	mov	m,c		;; 0294: 71          q
	push	d		;; 0295: d5          .
	mvi	a,00ch		;; 0296: 3e 0c       >.
	lxi	d,L1a02		;; 0298: 11 02 1a    ...
	call	subxxa		;; 029b: cd 8d 19    ...
	shld	L1ab4		;; 029e: 22 b4 1a    "..
	lxi	h,L1b11		;; 02a1: 21 11 1b    ...
	mvi	m,000h		;; 02a4: 36 00       6.
L02a6:	mvi	a,00bh		;; 02a6: 3e 0b       >.
	lxi	h,L1b11		;; 02a8: 21 11 1b    ...
	cmp	m		;; 02ab: be          .
	jc	L02c2		;; 02ac: da c2 02    ...
	lhld	L1b11		;; 02af: 2a 11 1b    *..
	mvi	h,000h		;; 02b2: 26 00       &.
	xchg			;; 02b4: eb          .
	lhld	L1ab4		;; 02b5: 2a b4 1a    *..
	dad	d		;; 02b8: 19          .
	mvi	m,000h		;; 02b9: 36 00       6.
	lxi	h,L1b11		;; 02bb: 21 11 1b    ...
	inr	m		;; 02be: 34          4
	jnz	L02a6		;; 02bf: c2 a6 02    ...
L02c2:	lda	L1b0e		;; 02c2: 3a 0e 1b    :..
	ani	001h		;; 02c5: e6 01       ..
	rrc			;; 02c7: 0f          .
	lxi	h,L1b0d		;; 02c8: 21 0d 1b    ...
	ora	m		;; 02cb: b6          .
	lhld	L1ab4		;; 02cc: 2a b4 1a    *..
	mov	m,a		;; 02cf: 77          w
	lhld	L1b0d		;; 02d0: 2a 0d 1b    *..
	lxi	b,00006h	;; 02d3: 01 06 00    ...
	push	h		;; 02d6: e5          .
	lhld	L1ab4		;; 02d7: 2a b4 1a    *..
	dad	b		;; 02da: 09          .
	xchg			;; 02db: eb          .
	lhld	L1b0b		;; 02dc: 2a 0b 1b    *..
	mov	b,h		;; 02df: 44          D
	mov	c,l		;; 02e0: 4d          M
	pop	h		;; 02e1: e1          .
L02e2:	ldax	b		;; 02e2: 0a          .
	stax	d		;; 02e3: 12          .
	inx	b		;; 02e4: 03          .
	inx	d		;; 02e5: 13          .
	dcr	l		;; 02e6: 2d          -
	jnz	L02e2		;; 02e7: c2 e2 02    ...
	lxi	b,00004h	;; 02ea: 01 04 00    ...
	lhld	L1ab4		;; 02ed: 2a b4 1a    *..
	dad	b		;; 02f0: 09          .
	push	h		;; 02f1: e5          .
	lhld	L1b0f		;; 02f2: 2a 0f 1b    *..
	xchg			;; 02f5: eb          .
	pop	h		;; 02f6: e1          .
	mov	m,e		;; 02f7: 73          s
	inx	h		;; 02f8: 23          #
	mov	m,d		;; 02f9: 72          r
	lhld	L1ab4		;; 02fa: 2a b4 1a    *..
	shld	L1a02		;; 02fd: 22 02 1a    "..
	lxi	b,L1a04		;; 0300: 01 04 1a    ...
	lxi	d,L1a02		;; 0303: 11 02 1a    ...
	call	L1980		;; 0306: cd 80 19    ...
	jnc	L0312		;; 0309: d2 12 03    ...
	lhld	L1a02		;; 030c: 2a 02 1a    *..
	shld	L1a04		;; 030f: 22 04 1a    "..
L0312:	ret			;; 0312: c9          .

L0313:	lda	L1ab7		;; 0313: 3a b7 1a    :..
	rar			;; 0316: 1f          .
	jnc	L032a		;; 0317: d2 2a 03    .*.
	mvi	l,12		;; 031a: 2e 0c       ..
	lxi	d,reltmp	;; 031c: 11 54 1a    .T.
	lxi	b,irltmp	;; 031f: 01 75 1a    .u.
L0322:	ldax	b		;; 0322: 0a          .
	stax	d		;; 0323: 12          .
	inx	b		;; 0324: 03          .
	inx	d		;; 0325: 13          .
	dcr	l		;; 0326: 2d          -
	jnz	L0322		;; 0327: c2 22 03    .".
L032a:	mvi	l,12		;; 032a: 2e 0c       ..
	lxi	d,irltmp	;; 032c: 11 75 1a    .u.
	lxi	b,L1a06		;; 032f: 01 06 1a    ...
L0332:	ldax	b		;; 0332: 0a          .
	stax	d		;; 0333: 12          .
	inx	b		;; 0334: 03          .
	inx	d		;; 0335: 13          .
	dcr	l		;; 0336: 2d          -
	jnz	L0332		;; 0337: c2 32 03    .2.
	lda	irltmp+9	;; 033a: 3a 7e 1a    :~.
	cpi	' '		;; 033d: fe 20       . 
	jnz	L036c		;; 033f: c2 6c 03    .l.
	lda	L1ab7		;; 0342: 3a b7 1a    :..
	rar			;; 0345: 1f          .
	jnc	L035c		;; 0346: d2 5c 03    .\.
	mvi	l,3		;; 0349: 2e 03       ..
	lxi	d,irltmp+9	;; 034b: 11 7e 1a    .~.
	lxi	b,irlsfx		;; 034e: 01 8a 01    ...
L0351:	ldax	b		;; 0351: 0a          .
	stax	d		;; 0352: 12          .
	inx	b		;; 0353: 03          .
	inx	d		;; 0354: 13          .
	dcr	l		;; 0355: 2d          -
	jnz	L0351		;; 0356: c2 51 03    .Q.
	jmp	L036c		;; 0359: c3 6c 03    .l.

L035c:	mvi	l,3		;; 035c: 2e 03       ..
	lxi	d,irltmp+9	;; 035e: 11 7e 1a    .~.
	lxi	b,relsfx	;; 0361: 01 87 01    ...
L0364:	ldax	b		;; 0364: 0a          .
	stax	d		;; 0365: 12          .
	inx	b		;; 0366: 03          .
	inx	d		;; 0367: 13          .
	dcr	l		;; 0368: 2d          -
	jnz	L0364		;; 0369: c2 64 03    .d.
L036c:	lxi	b,irltmp	;; 036c: 01 75 1a    .u.
	call	fdelet		;; 036f: cd 70 18    .p.
	mvi	l,12		;; 0372: 2e 0c       ..
	lxi	d,reltmp+16	;; 0374: 11 64 1a    .d.
	lxi	b,irltmp	;; 0377: 01 75 1a    .u.
L037a:	ldax	b		;; 037a: 0a          .
	stax	d		;; 037b: 12          .
	inx	b		;; 037c: 03          .
	inx	d		;; 037d: 13          .
	dcr	l		;; 037e: 2d          -
	jnz	L037a		;; 037f: c2 7a 03    .z.
	lxi	b,reltmp	;; 0382: 01 54 1a    .T.
	call	frenam		;; 0385: cd d6 18    ...
	ret			;; 0388: c9          .

L0389:	lxi	h,00000h	;; 0389: 21 00 00    ...
	shld	L1aaa		;; 038c: 22 aa 1a    "..
	lxi	b,irltmp		;; 038f: 01 75 1a    .u.
	call	fstart		;; 0392: cd e2 17    ...
	lhld	L19fa		;; 0395: 2a fa 19    *..
	mov	c,l		;; 0398: 4d          M
	call	L0b3a		;; 0399: cd 3a 0b    .:.
	lhld	L19fb		;; 039c: 2a fb 19    *..
	mov	c,l		;; 039f: 4d          M
	call	L0b3a		;; 03a0: cd 3a 0b    .:.
	lxi	h,L1b12		;; 03a3: 21 12 1b    ...
	mvi	m,000h		;; 03a6: 36 00       6.
L03a8:	mvi	a,07dh		;; 03a8: 3e 7d       >}
	lxi	h,L1b12		;; 03aa: 21 12 1b    ...
	cmp	m		;; 03ad: be          .
	jc	L03c0		;; 03ae: da c0 03    ...
	mvi	c,000h		;; 03b1: 0e 00       ..
	call	L0b3a		;; 03b3: cd 3a 0b    .:.
	lda	L1b12		;; 03b6: 3a 12 1b    :..
	inr	a		;; 03b9: 3c          <
	sta	L1b12		;; 03ba: 32 12 1b    2..
	jnz	L03a8		;; 03bd: c2 a8 03    ...
L03c0:	lxi	b,L2392		;; 03c0: 01 92 23    ..#
	push	b		;; 03c3: c5          .
	lxi	d,irltmp		;; 03c4: 11 75 1a    .u.
	lxi	b,00080h	;; 03c7: 01 80 00    ...
	call	wrfile		;; 03ca: cd 7b 17    .{.
	lxi	b,irltmp		;; 03cd: 01 75 1a    .u.
	call	fdone		;; 03d0: cd 12 18    ...
	ret			;; 03d3: c9          .

L03d4:	mvi	a,000h		;; 03d4: 3e 00       >.
	lxi	h,L1aa6		;; 03d6: 21 a6 1a    ...
	call	L1998		;; 03d9: cd 98 19    ...
	jnc	L042c		;; 03dc: d2 2c 04    .,.
	lxi	b,reltmp		;; 03df: 01 54 1a    .T.
	call	fstart		;; 03e2: cd e2 17    ...
L03e5:	mvi	a,000h		;; 03e5: 3e 00       >.
	lxi	d,L1aa6		;; 03e7: 11 a6 1a    ...
	call	subxxa		;; 03ea: cd 8d 19    ...
	ora	l		;; 03ed: b5          .
	jz	L0429		;; 03ee: ca 29 04    .).
	lxi	b,relbuf		;; 03f1: 01 92 1f    ...
	push	b		;; 03f4: c5          .
	lhld	relsiz		;; 03f5: 2a 96 1a    *..
	mov	b,h		;; 03f8: 44          D
	mov	c,l		;; 03f9: 4d          M
	lxi	d,reltmp		;; 03fa: 11 54 1a    .T.
	call	rdfile		;; 03fd: cd 54 17    .T.
	shld	L1b13		;; 0400: 22 13 1b    "..
	lxi	b,relbuf		;; 0403: 01 92 1f    ...
	push	b		;; 0406: c5          .
	lxi	d,00080h	;; 0407: 11 80 00    ...
	lhld	L1b13		;; 040a: 2a 13 1b    *..
	call	mult		;; 040d: cd 25 19    .%.
	mov	b,h		;; 0410: 44          D
	mov	c,l		;; 0411: 4d          M
	lxi	d,irltmp		;; 0412: 11 75 1a    .u.
	call	wrfile		;; 0415: cd 7b 17    .{.
	lxi	b,L1b13		;; 0418: 01 13 1b    ...
	lxi	d,L1aa6		;; 041b: 11 a6 1a    ...
	call	L1980		;; 041e: cd 80 19    ...
	xchg			;; 0421: eb          .
	dcx	h		;; 0422: 2b          +
	mov	m,e		;; 0423: 73          s
	inx	h		;; 0424: 23          #
	mov	m,d		;; 0425: 72          r
	jmp	L03e5		;; 0426: c3 e5 03    ...

L0429:	jmp	L043b		;; 0429: c3 3b 04    .;.

L042c:	lxi	b,L2792		;; 042c: 01 92 27    ..'
	push	b		;; 042f: c5          .
	lhld	L1aa2		;; 0430: 2a a2 1a    *..
	mov	b,h		;; 0433: 44          D
	mov	c,l		;; 0434: 4d          M
	lxi	d,irltmp		;; 0435: 11 75 1a    .u.
	call	wrfile		;; 0438: cd 7b 17    .{.
L043b:	ret			;; 043b: c9          .

L043c:	lxi	b,L1a04		;; 043c: 01 04 1a    ...
	lxi	d,memtop		;; 043f: 11 00 1a    ...
	call	L1980		;; 0442: cd 80 19    ...
	jnc	L044e		;; 0445: d2 4e 04    .N.
	lhld	memtop		;; 0448: 2a 00 1a    *..
	shld	L1a04		;; 044b: 22 04 1a    "..
L044e:	lxi	b,L2792		;; 044e: 01 92 27    ..'
	lxi	d,L1a04		;; 0451: 11 04 1a    ...
	call	L1985		;; 0454: cd 85 19    ...
	xchg			;; 0457: eb          .
	mvi	a,080h		;; 0458: 3e 80       >.
	call	subxa		;; 045a: cd 76 19    .v.
	lxi	d,0ff80h	;; 045d: 11 80 ff    ...
	call	andx		;; 0460: cd f2 18    ...
	shld	L1aa0		;; 0463: 22 a0 1a    "..
	lda	L1a06		;; 0466: 3a 06 1a    :..
	sta	reltmp		;; 0469: 32 54 1a    2T.
	sta	irltmp		;; 046c: 32 75 1a    2u.
	lda	L1ab7		;; 046f: 3a b7 1a    :..
	rar			;; 0472: 1f          .
	jnc	L0499		;; 0473: d2 99 04    ...
	lxi	b,irltmp		;; 0476: 01 75 1a    .u.
	call	fnew		;; 0479: cd 9f 17    ...
	lxi	h,L1b15		;; 047c: 21 15 1b    ...
	mvi	m,001h		;; 047f: 36 01       6.
L0481:	mvi	a,080h		;; 0481: 3e 80       >.
	lxi	h,L1b15		;; 0483: 21 15 1b    ...
	cmp	m		;; 0486: be          .
	jc	L0499		;; 0487: da 99 04    ...
	mvi	c,000h		;; 048a: 0e 00       ..
	call	L0b3a		;; 048c: cd 3a 0b    .:.
	lda	L1b15		;; 048f: 3a 15 1b    :..
	inr	a		;; 0492: 3c          <
	sta	L1b15		;; 0493: 32 15 1b    2..
	jnz	L0481		;; 0496: c2 81 04    ...
L0499:	lda	L1ab8		;; 0499: 3a b8 1a    :..
	rar			;; 049c: 1f          .
	jnc	L04a6		;; 049d: d2 a6 04    ...
	lxi	b,reltmp		;; 04a0: 01 54 1a    .T.
	call	fnew		;; 04a3: cd 9f 17    ...
L04a6:	ret			;; 04a6: c9          .

L04a7:	lda	L1ab7		;; 04a7: 3a b7 1a    :..
	lxi	h,L1ab8		;; 04aa: 21 b8 1a    ...
	ora	m		;; 04ad: b6          .
	cma			;; 04ae: 2f          /
	rar			;; 04af: 1f          .
	jnc	L04b4		;; 04b0: d2 b4 04    ...
	ret			;; 04b3: c9          .

L04b4:	lda	L1ab8		;; 04b4: 3a b8 1a    :..
	rar			;; 04b7: 1f          .
	jnc	L0514		;; 04b8: d2 14 05    ...
	mvi	c,09eh		;; 04bb: 0e 9e       ..
	call	L0c8d		;; 04bd: cd 8d 0c    ...
L04c0:	mvi	a,07fh		;; 04c0: 3e 7f       >.
	lxi	d,L1aa2		;; 04c2: 11 a2 1a    ...
	call	andyya		;; 04c5: cd f9 18    ...
	mvi	a,000h		;; 04c8: 3e 00       >.
	call	subax		;; 04ca: cd 6c 19    .l.
	ora	l		;; 04cd: b5          .
	jz	L04d9		;; 04ce: ca d9 04    ...
	mvi	c,01ah		;; 04d1: 0e 1a       ..
	call	L0c8d		;; 04d3: cd 8d 0c    ...
	jmp	L04c0		;; 04d6: c3 c0 04    ...

L04d9:	mvi	a,000h		;; 04d9: 3e 00       >.
	lxi	h,L1aa6		;; 04db: 21 a6 1a    ...
	call	L1998		;; 04de: cd 98 19    ...
	sbb	a		;; 04e1: 9f          .
	push	psw		;; 04e2: f5          .
	lda	L1ab7		;; 04e3: 3a b7 1a    :..
	cma			;; 04e6: 2f          /
	pop	b		;; 04e7: c1          .
	mov	c,b		;; 04e8: 48          H
	ora	c		;; 04e9: b1          .
	rar			;; 04ea: 1f          .
	jnc	L0514		;; 04eb: d2 14 05    ...
	lhld	L1aa2		;; 04ee: 2a a2 1a    *..
	xchg			;; 04f1: eb          .
	lxi	h,00080h	;; 04f2: 21 80 00    ...
	call	divhl		;; 04f5: cd 06 19    ...
	lhld	L1aa6		;; 04f8: 2a a6 1a    *..
	dad	d		;; 04fb: 19          .
	shld	L1aa6		;; 04fc: 22 a6 1a    "..
	lxi	b,L2792		;; 04ff: 01 92 27    ..'
	push	b		;; 0502: c5          .
	lhld	L1aa2		;; 0503: 2a a2 1a    *..
	mov	b,h		;; 0506: 44          D
	mov	c,l		;; 0507: 4d          M
	lxi	d,reltmp		;; 0508: 11 54 1a    .T.
	call	wrfile		;; 050b: cd 7b 17    .{.
	lxi	b,reltmp		;; 050e: 01 54 1a    .T.
	call	fdone		;; 0511: cd 12 18    ...
L0514:	lda	L1ab7		;; 0514: 3a b7 1a    :..
	rar			;; 0517: 1f          .
	jnc	L056c		;; 0518: d2 6c 05    .l.
	call	L0baa		;; 051b: cd aa 0b    ...
	call	L0be4		;; 051e: cd e4 0b    ...
	mvi	c,0feh		;; 0521: 0e fe       ..
	call	L0b3a		;; 0523: cd 3a 0b    .:.
L0526:	mvi	a,07fh		;; 0526: 3e 7f       >.
	lxi	d,L1aaa		;; 0528: 11 aa 1a    ...
	call	andyya		;; 052b: cd f9 18    ...
	mvi	a,000h		;; 052e: 3e 00       >.
	call	subax		;; 0530: cd 6c 19    .l.
	ora	l		;; 0533: b5          .
	jz	L053f		;; 0534: ca 3f 05    .?.
	mvi	c,01ah		;; 0537: 0e 1a       ..
	call	L0b3a		;; 0539: cd 3a 0b    .:.
	jmp	L0526		;; 053c: c3 26 05    .&.

L053f:	lxi	b,L2392		;; 053f: 01 92 23    ..#
	push	b		;; 0542: c5          .
	lhld	L1aaa		;; 0543: 2a aa 1a    *..
	mov	b,h		;; 0546: 44          D
	mov	c,l		;; 0547: 4d          M
	lxi	d,irltmp		;; 0548: 11 75 1a    .u.
	call	wrfile		;; 054b: cd 7b 17    .{.
	lda	irltmp+12		;; 054e: 3a 81 1a    :..
	sta	L19fa		;; 0551: 32 fa 19    2..
	lda	irltmp+32		;; 0554: 3a 95 1a    :..
	sta	L19fb		;; 0557: 32 fb 19    2..
	call	L03d4		;; 055a: cd d4 03    ...
	lxi	b,irltmp		;; 055d: 01 75 1a    .u.
	call	fdone		;; 0560: cd 12 18    ...
	call	L0389		;; 0563: cd 89 03    ...
	lxi	b,reltmp		;; 0566: 01 54 1a    .T.
	call	fdelet		;; 0569: cd 70 18    .p.
L056c:	call	L0313		;; 056c: cd 13 03    ...
	ret			;; 056f: c9          .

L0570:	lhld	L1ab4		;; 0570: 2a b4 1a    *..
	mvi	a,040h		;; 0573: 3e 40       >@
	ana	m		;; 0575: a6          .
	mov	c,a		;; 0576: 4f          O
	mvi	a,000h		;; 0577: 3e 00       >.
	sub	c		;; 0579: 91          .
	sbb	a		;; 057a: 9f          .
	ret			;; 057b: c9          .

L057c:	lhld	L1ab4		;; 057c: 2a b4 1a    *..
	mvi	a,040h		;; 057f: 3e 40       >@
	ora	m		;; 0581: b6          .
	lhld	L1ab4		;; 0582: 2a b4 1a    *..
	mov	m,a		;; 0585: 77          w
	ret			;; 0586: c9          .

L0587:	lhld	L1ab4		;; 0587: 2a b4 1a    *..
	mov	a,m		;; 058a: 7e          ~
	rlc			;; 058b: 07          .
	ret			;; 058c: c9          .

L058d:	lxi	h,L1b17		;; 058d: 21 17 1b    ...
	mov	m,e		;; 0590: 73          s
	dcx	h		;; 0591: 2b          +
	mov	m,c		;; 0592: 71          q
	lxi	d,00080h	;; 0593: 11 80 00    ...
	lhld	L1b16		;; 0596: 2a 16 1b    *..
	mvi	h,000h		;; 0599: 26 00       &.
	call	mult		;; 059b: cd 25 19    .%.
	push	h		;; 059e: e5          .
	lhld	L1b17		;; 059f: 2a 17 1b    *..
	mvi	h,000h		;; 05a2: 26 00       &.
	pop	b		;; 05a4: c1          .
	dad	b		;; 05a5: 09          .
	ret			;; 05a6: c9          .

L05a7:	lxi	d,128		;; 05a7: 11 80 00    ...
	lhld	relfcb+12	;; 05aa: 2a 1e 1a    *..
	mvi	h,0		;; 05ad: 26 00       &.
	call	mult		;; 05af: cd 25 19    .%.
	push	h		;; 05b2: e5          .
	lhld	relfcb+32	;; 05b3: 2a 32 1a    *2.
	mvi	h,0		;; 05b6: 26 00       &.
	pop	b		;; 05b8: c1          .
	dad	b		;; 05b9: 09          .
	shld	L1aac		;; 05ba: 22 ac 1a    "..
	lxi	b,relbuf	;; 05bd: 01 92 1f    ...
	push	b		;; 05c0: c5          .
	lhld	relsiz		;; 05c1: 2a 96 1a    *..
	mov	b,h		;; 05c4: 44          D
	mov	c,l		;; 05c5: 4d          M
	lxi	d,relfcb	;; 05c6: 11 12 1a    ...
	call	rdfile		;; 05c9: cd 54 17    .T.
	xchg			;; 05cc: eb          .
	lhld	L1aac		;; 05cd: 2a ac 1a    *..
	dad	d		;; 05d0: 19          .
	dcx	h		;; 05d1: 2b          +
	shld	L1aae		;; 05d2: 22 ae 1a    "..
	ret			;; 05d5: c9          .

L05d6:	lxi	b,libbuf	;; 05d6: 01 92 1d    ...
	push	b		;; 05d9: c5          .
	lhld	libsiz		;; 05da: 2a 9b 1a    *..
	mov	b,h		;; 05dd: 44          D
	mov	c,l		;; 05de: 4d          M
	lxi	d,libfcb	;; 05df: 11 33 1a    .3.
	call	rdfile		;; 05e2: cd 54 17    .T.
	shld	tmpptr		;; 05e5: 22 fe 19    "..
	ret			;; 05e8: c9          .

L05e9:	lxi	h,L1b18+1		;; 05e9: 21 19 1b    ...
	mov	m,b		;; 05ec: 70          p
	dcx	h		;; 05ed: 2b          +
	mov	m,c		;; 05ee: 71          q
	mvi	c,7		;; 05ef: 0e 07       ..
	lxi	h,L1b18		;; 05f1: 21 18 1b    ...
	call	shrxx		;; 05f4: cd 5c 19    .\.
	xchg			;; 05f7: eb          .
	inx	h		;; 05f8: 23          #
	mov	m,e		;; 05f9: 73          s
	mvi	a,07fh		;; 05fa: 3e 7f       >.
	lxi	d,L1b18		;; 05fc: 11 18 1b    ...
	call	andyya		;; 05ff: cd f9 18    ...
	xchg			;; 0602: eb          .
	lxi	h,L1b1b		;; 0603: 21 1b 1b    ...
	mov	m,e		;; 0606: 73          s
	lda	relfcb+12		;; 0607: 3a 1e 1a    :..
	dcx	h		;; 060a: 2b          +
	cmp	m		;; 060b: be          .
	jz	L0626		;; 060c: ca 26 06    .&.
	lda	L1b1a		;; 060f: 3a 1a 1b    :..
	sta	relfcb+12		;; 0612: 32 1e 1a    2..
	lxi	b,relfcb		;; 0615: 01 12 1a    ...
	call	fopen		;; 0618: cd 80 18    ...
	cpi	0ffh		;; 061b: fe ff       ..
	jnz	L0626		;; 061d: c2 26 06    .&.
	lxi	b,L018d		;; 0620: 01 8d 01    ...
	call	exitms		;; 0623: cd a3 0a    ...
L0626:	lda	L1b1b		;; 0626: 3a 1b 1b    :..
	sta	relfcb+32		;; 0629: 32 32 1a    22.
	call	L05a7		;; 062c: cd a7 05    ...
	ret			;; 062f: c9          .

L0630:	lxi	h,L1b1e		;; 0630: 21 1e 1b    ...
	mov	m,e		;; 0633: 73          s
	dcx	h		;; 0634: 2b          +
	mov	m,c		;; 0635: 71          q
	dcx	h		;; 0636: 2b          +
	pop	d		;; 0637: d1          .
	pop	b		;; 0638: c1          .
	mov	m,c		;; 0639: 71          q
	push	d		;; 063a: d5          .
	lhld	L1b1c		;; 063b: 2a 1c 1b    *..
	mov	c,l		;; 063e: 4d          M
	lhld	L1b1d		;; 063f: 2a 1d 1b    *..
	xchg			;; 0642: eb          .
	call	L058d		;; 0643: cd 8d 05    ...
	shld	L1b1f		;; 0646: 22 1f 1b    "..
	lxi	b,L1aac		;; 0649: 01 ac 1a    ...
	lxi	d,L1b1f		;; 064c: 11 1f 1b    ...
	call	L1980		;; 064f: cd 80 19    ...
	sbb	a		;; 0652: 9f          .
	lxi	d,L1aae		;; 0653: 11 ae 1a    ...
	lxi	b,L1b1f		;; 0656: 01 1f 1b    ...
	push	psw		;; 0659: f5          .
	call	L1980		;; 065a: cd 80 19    ...
	sbb	a		;; 065d: 9f          .
	pop	b		;; 065e: c1          .
	mov	c,b		;; 065f: 48          H
	ora	c		;; 0660: b1          .
	rar			;; 0661: 1f          .
	jnc	L066d		;; 0662: d2 6d 06    .m.
	lhld	L1b1f		;; 0665: 2a 1f 1b    *..
	mov	b,h		;; 0668: 44          D
	mov	c,l		;; 0669: 4d          M
	call	L05e9		;; 066a: cd e9 05    ...
L066d:	lxi	b,L1aac		;; 066d: 01 ac 1a    ...
	lxi	d,L1b1f		;; 0670: 11 1f 1b    ...
	call	L1980		;; 0673: cd 80 19    ...
	lxi	d,128		;; 0676: 11 80 00    ...
	call	mult		;; 0679: cd 25 19    .%.
	push	h		;; 067c: e5          .
	lhld	L1b1e		;; 067d: 2a 1e 1b    *..
	mvi	h,0		;; 0680: 26 00       &.
	pop	b		;; 0682: c1          .
	dad	b		;; 0683: 09          .
	shld	relidx		;; 0684: 22 99 1a    "..
	lxi	h,relbit		;; 0687: 21 98 1a    ...
	mvi	m,0		;; 068a: 36 00       6.
	ret			;; 068c: c9          .

L068d:	call	L057c		;; 068d: cd 7c 05    .|.
	lhld	L1ab4		;; 0690: 2a b4 1a    *..
	inx	h		;; 0693: 23          #
	lda	L1ac4		;; 0694: 3a c4 1a    :..
	mov	m,a		;; 0697: 77          w
	lhld	L1ab4		;; 0698: 2a b4 1a    *..
	inx	h		;; 069b: 23          #
	inx	h		;; 069c: 23          #
	lda	L1ac5		;; 069d: 3a c5 1a    :..
	mov	m,a		;; 06a0: 77          w
	lxi	b,00003h	;; 06a1: 01 03 00    ...
	lhld	L1ab4		;; 06a4: 2a b4 1a    *..
	dad	b		;; 06a7: 09          .
	lda	L1ac6		;; 06a8: 3a c6 1a    :..
	mov	m,a		;; 06ab: 77          w
	ret			;; 06ac: c9          .

L06ad:	lxi	h,L19fd		;; 06ad: 21 fd 19    ...
	mvi	m,001h		;; 06b0: 36 01       6.
	lxi	h,L1ac3		;; 06b2: 21 c3 1a    ...
	mvi	m,001h		;; 06b5: 36 01       6.
L06b7:	call	L105c		;; 06b7: cd 5c 10    .\.
	sta	L1b21		;; 06ba: 32 21 1b    2..
	sui	002h		;; 06bd: d6 02       ..
	adi	0ffh		;; 06bf: c6 ff       ..
	sbb	a		;; 06c1: 9f          .
	push	psw		;; 06c2: f5          .
	lda	L1b21		;; 06c3: 3a 21 1b    :..
	sui	00fh		;; 06c6: d6 0f       ..
	adi	0ffh		;; 06c8: c6 ff       ..
	sbb	a		;; 06ca: 9f          .
	pop	b		;; 06cb: c1          .
	mov	c,b		;; 06cc: 48          H
	ana	c		;; 06cd: a1          .
	rar			;; 06ce: 1f          .
	jnc	L06d5		;; 06cf: d2 d5 06    ...
	jmp	L06b7		;; 06d2: c3 b7 06    ...

L06d5:	lda	L1b21		;; 06d5: 3a 21 1b    :..
	cpi	00fh		;; 06d8: fe 0f       ..
	jnz	L06e5		;; 06da: c2 e5 06    ...
	lxi	h,L1ad1		;; 06dd: 21 d1 1a    ...
	mvi	m,06ch		;; 06e0: 36 6c       6l
	dcx	h		;; 06e2: 2b          +
	mvi	m,001h		;; 06e3: 36 01       6.
L06e5:	lhld	L1ad0		;; 06e5: 2a d0 1a    *..
	xchg			;; 06e8: eb          .
	lxi	b,L1ad1		;; 06e9: 01 d1 1a    ...
	call	L022a		;; 06ec: cd 2a 02    .*.
	rar			;; 06ef: 1f          .
	jnc	L06f6		;; 06f0: d2 f6 06    ...
	call	L068d		;; 06f3: cd 8d 06    ...
L06f6:	ret			;; 06f6: c9          .

L06f7:	lxi	h,L19fd		;; 06f7: 21 fd 19    ...
	mvi	m,001h		;; 06fa: 36 01       6.
L06fc:	call	L105c		;; 06fc: cd 5c 10    .\.
	cpi	00eh		;; 06ff: fe 0e       ..
	jz	L0707		;; 0701: ca 07 07    ...
	jmp	L06fc		;; 0704: c3 fc 06    ...

L0707:	ret			;; 0707: c9          .

L0708:	lxi	b,4		;; 0708: 01 04 00    ...
	lhld	L1ab4		;; 070b: 2a b4 1a    *..
	dad	b		;; 070e: 09          .
	mov	e,m		;; 070f: 5e          ^
	inx	h		;; 0710: 23          #
	mov	d,m		;; 0711: 56          V
	xchg			;; 0712: eb          .
	shld	L1b22		;; 0713: 22 22 1b    "".
	lxi	h,libfcb	;; 0716: 21 33 1a    .3.
	shld	L1b22+2		;; 0719: 22 24 1b    "$.
	lxi	b,L1b22		;; 071c: 01 22 1b    .".
	call	L1413		;; 071f: cd 13 14    ...
	xchg			;; 0722: eb          .
	lxi	h,-1		;; 0723: 21 ff ff    ...
	call	subx		;; 0726: cd 6f 19    .o.
	jc	L0732		;; 0729: da 32 07    .2.
	lxi	b,L1af8		;; 072c: 01 f8 1a    ...
	call	exitms		;; 072f: cd a3 0a    ...
L0732:	lda	libfcb+9	;; 0732: 3a 3c 1a    :<.
	cpi	' '		;; 0735: fe 20       . 
	jnz	L074a		;; 0737: c2 4a 07    .J.
	mvi	l,3		;; 073a: 2e 03       ..
	lxi	d,libfcb+9	;; 073c: 11 3c 1a    .<.
	lxi	b,relsfx	;; 073f: 01 87 01    ...
L0742:	ldax	b		;; 0742: 0a          .
	stax	d		;; 0743: 12          .
	inx	b		;; 0744: 03          .
	inx	d		;; 0745: 13          .
	dcr	l		;; 0746: 2d          -
	jnz	L0742		;; 0747: c2 42 07    .B.
L074a:	lxi	b,libfcb	;; 074a: 01 33 1a    .3.
	call	fstart		;; 074d: cd e2 17    ...
	lxi	h,libflg	;; 0750: 21 fc 19    ...
	mvi	m,1		;; 0753: 36 01       6.
	inx	h		;; 0755: 23          #
	mvi	m,0		;; 0756: 36 00       6.
	lxi	h,libbit	;; 0758: 21 9d 1a    ...
	mvi	m,8		;; 075b: 36 08       6.
	push	h		;; 075d: e5          .
	lhld	libsiz		;; 075e: 2a 9b 1a    *..
	xchg			;; 0761: eb          .
	pop	h		;; 0762: e1          .
	inx	h	; libidx = libsiz
	mov	m,e		;; 0764: 73          s
	inx	h		;; 0765: 23          #
	mov	m,d		;; 0766: 72          r
	lxi	h,L1ac7		;; 0767: 21 c7 1a    ...
	mvi	m,1		;; 076a: 36 01       6.
L076c:	call	L105c		;; 076c: cd 5c 10    .\.
	cpi	00fh		;; 076f: fe 0f       ..
	jz	L0777		;; 0771: ca 77 07    .w.
	jmp	L076c		;; 0774: c3 6c 07    .l.

L0777:	lxi	h,libflg	;; 0777: 21 fc 19    ...
	mvi	m,0		;; 077a: 36 00       6.
	ret			;; 077c: c9          .

L077d:	lxi	h,L1ac7		;; 077d: 21 c7 1a    ...
	mvi	m,1		;; 0780: 36 01       6.
	lxi	h,L19fd		;; 0782: 21 fd 19    ...
	mvi	m,0		;; 0785: 36 00       6.
L0787:	call	L105c		;; 0787: cd 5c 10    .\.
	cpi	00eh		;; 078a: fe 0e       ..
	jz	L0792		;; 078c: ca 92 07    ...
	jmp	L0787		;; 078f: c3 87 07    ...

L0792:	ret			;; 0792: c9          .

L0793:	mvi	l,12		;; 0793: 2e 0c       ..
	lxi	d,L1a06		;; 0795: 11 06 1a    ...
	lxi	b,relfcb	;; 0798: 01 12 1a    ...
L079b:	ldax	b		;; 079b: 0a          .
	stax	d		;; 079c: 12          .
	inx	b		;; 079d: 03          .
	inx	d		;; 079e: 13          .
	dcr	l		;; 079f: 2d          -
	jnz	L079b		;; 07a0: c2 9b 07    ...
	ret			;; 07a3: c9          .

L07a4:	lxi	h,L1b26		;; 07a4: 21 26 1b    .&.
	mvi	m,001h		;; 07a7: 36 01       6.
L07a9:	lda	L1ad8		;; 07a9: 3a d8 1a    :..
	lxi	h,L1b26		;; 07ac: 21 26 1b    .&.
	cmp	m		;; 07af: be          .
	jc	L07cc		;; 07b0: da cc 07    ...
	lda	L1b26		;; 07b3: 3a 26 1b    :&.
	dcr	a		;; 07b6: 3d          =
	mov	c,a		;; 07b7: 4f          O
	mvi	b,000h		;; 07b8: 06 00       ..
	lxi	h,L1ad9		;; 07ba: 21 d9 1a    ...
	dad	b		;; 07bd: 09          .
	mov	c,m		;; 07be: 4e          N
	call	chrout		;; 07bf: cd 2c 18    .,.
	lda	L1b26		;; 07c2: 3a 26 1b    :&.
	inr	a		;; 07c5: 3c          <
	sta	L1b26		;; 07c6: 32 26 1b    2&.
	jnz	L07a9		;; 07c9: c2 a9 07    ...
L07cc:	ret			;; 07cc: c9          .

L07cd:	lhld	L1ad8		;; 07cd: 2a d8 1a    *..
	xchg			;; 07d0: eb          .
	lxi	b,L1ad9		;; 07d1: 01 d9 1a    ...
	call	L022a		;; 07d4: cd 2a 02    .*.
	push	psw		;; 07d7: f5          .
	call	L0570		;; 07d8: cd 70 05    .p.
	pop	b		;; 07db: c1          .
	mov	c,b		;; 07dc: 48          H
	ana	c		;; 07dd: a1          .
	rar			;; 07de: 1f          .
	jnc	L07fe		;; 07df: d2 fe 07    ...
	lhld	L1ab4		;; 07e2: 2a b4 1a    *..
	inx	h		;; 07e5: 23          #
	mov	c,m		;; 07e6: 4e          N
	push	b		;; 07e7: c5          .
	lhld	L1ab4		;; 07e8: 2a b4 1a    *..
	inx	h		;; 07eb: 23          #
	inx	h		;; 07ec: 23          #
	lxi	b,00003h	;; 07ed: 01 03 00    ...
	push	h		;; 07f0: e5          .
	lhld	L1ab4		;; 07f1: 2a b4 1a    *..
	dad	b		;; 07f4: 09          .
	mov	e,m		;; 07f5: 5e          ^
	pop	h		;; 07f6: e1          .
	mov	c,m		;; 07f7: 4e          N
	call	L0630		;; 07f8: cd 30 06    .0.
	jmp	L084a		;; 07fb: c3 4a 08    .J.

L07fe:	call	L06ad		;; 07fe: cd ad 06    ...
	lxi	b,L1ad0		;; 0801: 01 d0 1a    ...
	push	b		;; 0804: c5          .
	mvi	e,002h		;; 0805: 1e 02       ..
	lxi	b,L0199		;; 0807: 01 99 01    ...
	call	compar		;; 080a: cd 31 16    .1.
	rar			;; 080d: 1f          .
	jnc	L0820		;; 080e: d2 20 08    . .
	lxi	b,L1aec		;; 0811: 01 ec 1a    ...
	call	msgout		;; 0814: cd 47 18    .G.
	call	L07a4		;; 0817: cd a4 07    ...
	lxi	b,L019b		;; 081a: 01 9b 01    ...
	call	exitms		;; 081d: cd a3 0a    ...
L0820:	lxi	b,L1ad0		;; 0820: 01 d0 1a    ...
	push	b		;; 0823: c5          .
	ldax	b		;; 0824: 0a          .
	inr	a		;; 0825: 3c          <
	mov	e,a		;; 0826: 5f          _
	lxi	b,L1ad8		;; 0827: 01 d8 1a    ...
	call	compar		;; 082a: cd 31 16    .1.
	rar			;; 082d: 1f          .
	jnc	L0844		;; 082e: d2 44 08    .D.
	lhld	L1ac4		;; 0831: 2a c4 1a    *..
	push	h		;; 0834: e5          .
	lhld	L1ac5		;; 0835: 2a c5 1a    *..
	mov	c,l		;; 0838: 4d          M
	lhld	L1ac6		;; 0839: 2a c6 1a    *..
	xchg			;; 083c: eb          .
	call	L0630		;; 083d: cd 30 06    .0.
	ret			;; 0840: c9          .

	jmp	L0847		;; 0841: c3 47 08    .G.

L0844:	call	L06f7		;; 0844: cd f7 06    ...
L0847:	jmp	L07fe		;; 0847: c3 fe 07    ...

L084a:	ret			;; 084a: c9          .

L084b:	lxi	h,L1b27		;; 084b: 21 27 1b    .'.
	mov	m,c		;; 084e: 71          q
	lda	L1ac0		;; 084f: 3a c0 1a    :..
	rar			;; 0852: 1f          .
	jnc	L0877		;; 0853: d2 77 08    .w.
	lhld	L1acb		;; 0856: 2a cb 1a    *..
	push	h		;; 0859: e5          .
	lhld	L1acc		;; 085a: 2a cc 1a    *..
	mov	c,l		;; 085d: 4d          M
	mvi	e,000h		;; 085e: 1e 00       ..
	call	L0630		;; 0860: cd 30 06    .0.
	lhld	relsiz		;; 0863: 2a 96 1a    *..
	shld	relidx		;; 0866: 22 99 1a    "..
	lxi	h,relbit		;; 0869: 21 98 1a    ...
	mvi	m,8		;; 086c: 36 08       6.
	call	L077d		;; 086e: cd 7d 07    .}.
	lxi	h,L1ac0		;; 0871: 21 c0 1a    ...
	mvi	m,0		;; 0874: 36 00       6.
	ret			;; 0876: c9          .

L0877:	lda	L1b27		;; 0877: 3a 27 1b    :'.
	rar			;; 087a: 1f          .
	jnc	L0884		;; 087b: d2 84 08    ...
	call	L07cd		;; 087e: cd cd 07    ...
	jmp	L0887		;; 0881: c3 87 08    ...

L0884:	call	L06ad		;; 0884: cd ad 06    ...
L0887:	lxi	b,L1ad0		;; 0887: 01 d0 1a    ...
	push	b		;; 088a: c5          .
	mvi	e,2		;; 088b: 1e 02       ..
	lxi	b,L019c		;; 088d: 01 9c 01    ...
	call	compar		;; 0890: cd 31 16    .1.
	rar			;; 0893: 1f          .
	jnc	L0898		;; 0894: d2 98 08    ...
	ret			;; 0897: c9          .

L0898:	lhld	L1ad0		;; 0898: 2a d0 1a    *..
	xchg			;; 089b: eb          .
	lxi	b,L1ad1		;; 089c: 01 d1 1a    ...
	call	L022a		;; 089f: cd 2a 02    .*.
	push	psw		;; 08a2: f5          .
	call	L0587		;; 08a3: cd 87 05    ...
	pop	b		;; 08a6: c1          .
	mov	c,b		;; 08a7: 48          H
	ana	c		;; 08a8: a1          .
	rar			;; 08a9: 1f          .
	jnc	L08c5		;; 08aa: d2 c5 08    ...
	lxi	b,00004h	;; 08ad: 01 04 00    ...
	lhld	L1ab4		;; 08b0: 2a b4 1a    *..
	dad	b		;; 08b3: 09          .
	mvi	a,000h		;; 08b4: 3e 00       >.
	call	L1998		;; 08b6: cd 98 19    ...
	jnc	L08bf		;; 08b9: d2 bf 08    ...
	call	L0708		;; 08bc: cd 08 07    ...
L08bf:	call	L06f7		;; 08bf: cd f7 06    ...
	jmp	L08df		;; 08c2: c3 df 08    ...

L08c5:	lda	L1b27		;; 08c5: 3a 27 1b    :'.
	cma			;; 08c8: 2f          /
	rar			;; 08c9: 1f          .
	jnc	L08dc		;; 08ca: d2 dc 08    ...
	lhld	L1ac4		;; 08cd: 2a c4 1a    *..
	push	h		;; 08d0: e5          .
	lhld	L1ac5		;; 08d1: 2a c5 1a    *..
	mov	c,l		;; 08d4: 4d          M
	lhld	L1ac6		;; 08d5: 2a c6 1a    *..
	xchg			;; 08d8: eb          .
	call	L0630		;; 08d9: cd 30 06    .0.
L08dc:	call	L077d		;; 08dc: cd 7d 07    .}.
L08df:	ret			;; 08df: c9          .

L08e0:	lxi	b,L1ad0		;; 08e0: 01 d0 1a    ...
	push	b		;; 08e3: c5          .
	ldax	b		;; 08e4: 0a          .
	inr	a		;; 08e5: 3c          <
	mov	e,a		;; 08e6: 5f          _
	lxi	b,L1ad8		;; 08e7: 01 d8 1a    ...
	call	compar		;; 08ea: cd 31 16    .1.
	rar			;; 08ed: 1f          .
	jnc	L08f2		;; 08ee: d2 f2 08    ...
	ret			;; 08f1: c9          .

L08f2:	mvi	c,000h		;; 08f2: 0e 00       ..
	call	L084b		;; 08f4: cd 4b 08    .K.
	jmp	L08e0		;; 08f7: c3 e0 08    ...

	ret			;; 08fa: c9          .

L08fb:	lxi	h,L1acb		;; 08fb: 21 cb 1a    ...
	mvi	m,000h		;; 08fe: 36 00       6.
	inx	h		;; 0900: 23          #
	mvi	m,000h		;; 0901: 36 00       6.
	inx	h		;; 0903: 23          #
	mvi	m,0		;; 0904: 36 00       6.
	lda	relfcb+9		;; 0906: 3a 1b 1a    :..
	cpi	' '		;; 0909: fe 20       . 
	jnz	L091e		;; 090b: c2 1e 09    ...
	mvi	l,3		;; 090e: 2e 03       ..
	lxi	d,relfcb+9	;; 0910: 11 1b 1a    ...
	lxi	b,relsfx	;; 0913: 01 87 01    ...
L0916:	ldax	b		;; 0916: 0a          .
	stax	d		;; 0917: 12          .
	inx	b		;; 0918: 03          .
	inx	d		;; 0919: 13          .
	dcr	l		;; 091a: 2d          -
	jnz	L0916		;; 091b: c2 16 09    ...
L091e:	lxi	b,relfcb+9	;; 091e: 01 1b 1a    ...
	push	b		;; 0921: c5          .
	mvi	e,3		;; 0922: 1e 03       ..
	lxi	b,irlsfx	;; 0924: 01 8a 01    ...
	call	compar		;; 0927: cd 31 16    .1.
	sta	L1b28		;; 092a: 32 28 1b    2(.
	lxi	b,relfcb		;; 092d: 01 12 1a    ...
	call	fstart		;; 0930: cd e2 17    ...
	lda	L1b28		;; 0933: 3a 28 1b    :(.
	rar			;; 0936: 1f          .
	jnc	L097f		;; 0937: d2 7f 09    ...
	lxi	b,defdma	;; 093a: 01 80 00    ...
	push	b		;; 093d: c5          .
	lxi	d,relfcb		;; 093e: 11 12 1a    ...
	lxi	b,128		;; 0941: 01 80 00    ...
	call	rdfile		;; 0944: cd 54 17    .T.
	mov	a,l		;; 0947: 7d          }
	rar			;; 0948: 1f          .
	jnc	L094c		;; 0949: d2 4c 09    .L.
L094c:	lda	defdma		;; 094c: 3a 80 00    :..
	sta	L1acb		;; 094f: 32 cb 1a    2..
	lda	defdma+1	;; 0952: 3a 81 00    :..
	sta	L1acc		;; 0955: 32 cc 1a    2..
	lxi	h,relfcb+12	;; 0958: 21 1e 1a    ...
	lda	L1acb		;; 095b: 3a cb 1a    :..
	cmp	m		;; 095e: be          .
	jz	L0979		;; 095f: ca 79 09    .y.
	lda	L1acb		;; 0962: 3a cb 1a    :..
	sta	relfcb+12	;; 0965: 32 1e 1a    2..
	lxi	b,relfcb		;; 0968: 01 12 1a    ...
	call	fopen		;; 096b: cd 80 18    ...
	cpi	0ffh		;; 096e: fe ff       ..
	jnz	L0979		;; 0970: c2 79 09    .y.
	lxi	b,L1ae0		;; 0973: 01 e0 1a    ...
	call	exitms		;; 0976: cd a3 0a    ...
L0979:	lda	L1acc		;; 0979: 3a cc 1a    :..
	sta	relfcb+32	;; 097c: 32 32 1a    22.
L097f:	lxi	h,0		;; 097f: 21 00 00    ...
	shld	L1aac		;; 0982: 22 ac 1a    "..
	shld	L1aae		;; 0985: 22 ae 1a    "..
	lhld	relsiz		;; 0988: 2a 96 1a    *..
	shld	relidx		;; 098b: 22 99 1a    "..
	lxi	h,relbit		;; 098e: 21 98 1a    ...
	mvi	m,8		;; 0991: 36 08       6.
	ret			;; 0993: c9          .

L0994:	call	L08fb		;; 0994: cd fb 08    ...
	lxi	h,L1acf		;; 0997: 21 cf 1a    ...
	mvi	m,0		;; 099a: 36 00       6.
	lda	L1abf		;; 099c: 3a bf 1a    :..
	rar			;; 099f: 1f          .
	jnc	L09e8		;; 09a0: d2 e8 09    ...
	lhld	cmdptr		;; 09a3: 2a b0 1a    *..
	shld	L1b29		;; 09a6: 22 29 1b    ").
	lhld	L1ac1		;; 09a9: 2a c1 1a    *..
	shld	cmdptr		;; 09ac: 22 b0 1a    "..
L09af:	call	L112a		;; 09af: cd 2a 11    .*.
	mvi	c,001h		;; 09b2: 0e 01       ..
	call	L084b		;; 09b4: cd 4b 08    .K.
	lda	L1abc		;; 09b7: 3a bc 1a    :..
	rar			;; 09ba: 1f          .
	jnc	L09d4		;; 09bb: d2 d4 09    ...
	call	L112a		;; 09be: cd 2a 11    .*.
	lda	L1ad8		;; 09c1: 3a d8 1a    :..
	cpi	000h		;; 09c4: fe 00       ..
	jnz	L09d1		;; 09c6: c2 d1 09    ...
	lxi	h,L1ad8		;; 09c9: 21 d8 1a    ...
	mvi	m,001h		;; 09cc: 36 01       6.
	inx	h		;; 09ce: 23          #
	mvi	m,06ch		;; 09cf: 36 6c       6l
L09d1:	call	L08e0		;; 09d1: cd e0 08    ...
L09d4:	lda	L1acf		;; 09d4: 3a cf 1a    :..
	rar			;; 09d7: 1f          .
	jnc	L09e2		;; 09d8: d2 e2 09    ...
	lhld	L1b29		;; 09db: 2a 29 1b    *).
	shld	cmdptr		;; 09de: 22 b0 1a    "..
	ret			;; 09e1: c9          .

L09e2:	jmp	L09af		;; 09e2: c3 af 09    ...

	jmp	L09f8		;; 09e5: c3 f8 09    ...

L09e8:	lxi	h,L1ad9		;; 09e8: 21 d9 1a    ...
	mvi	m,06ch		;; 09eb: 36 6c       6l
	dcx	h		;; 09ed: 2b          +
	mvi	m,001h		;; 09ee: 36 01       6.
	lxi	h,L1ad0		;; 09f0: 21 d0 1a    ...
	mvi	m,000h		;; 09f3: 36 00       6.
	call	L08e0		;; 09f5: cd e0 08    ...
L09f8:	ret			;; 09f8: c9          .

L09f9:	call	L0994		;; 09f9: cd 94 09    ...
	lda	L1ace		;; 09fc: 3a ce 1a    :..
	rar			;; 09ff: 1f          .
	jnc	L0a04		;; 0a00: d2 04 0a    ...
	ret			;; 0a03: c9          .

L0a04:	mvi	c,000h		;; 0a04: 0e 00       ..
	call	L1302		;; 0a06: cd 02 13    ...
	jmp	L09f9		;; 0a09: c3 f9 09    ...

	ret			;; 0a0c: c9          .

L0a0d:	lxi	b,L19f0		;; 0a0d: 01 f0 19    ...
	call	msgout		;; 0a10: cd 47 18    .G.
	mvi	l,128		;; 0a13: 2e 80       ..
	lxi	d,cmdbuf		;; 0a15: 11 12 1d    ...
	lxi	b,cmdlin	;; 0a18: 01 80 00    ...
L0a1b:	ldax	b		;; 0a1b: 0a          .
	stax	d		;; 0a1c: 12          .
	inx	b		;; 0a1d: 03          .
	inx	d		;; 0a1e: 13          .
	dcr	l		;; 0a1f: 2d          -
	jnz	L0a1b		;; 0a20: c2 1b 0a    ...
	lxi	h,cmdbuf		;; 0a23: 21 12 1d    ...
	shld	cmdptr		;; 0a26: 22 b0 1a    "..
	lxi	h,deffcb	;; 0a29: 21 5c 00    .\.
	shld	cmdptr+2		;; 0a2c: 22 b2 1a    "..
	lxi	h,bdos+1	;; 0a2f: 21 06 00    ...
	shld	tmpptr		;; 0a32: 22 fe 19    "..
	lhld	tmpptr		;; 0a35: 2a fe 19    *..
	mov	e,m		;; 0a38: 5e          ^
	inx	h		;; 0a39: 23          #
	mov	d,m		;; 0a3a: 56          V
	xchg			;; 0a3b: eb          .
	shld	memtop		;; 0a3c: 22 00 1a    "..
	ret			;; 0a3f: c9          .

L0a40:	db	'   $'
L0a44:	lxi	h,L1c5e		;; 0a44: 21 5e 1c    .^.
	mov	m,c		;; 0a47: 71          q
	mvi	a,009h		;; 0a48: 3e 09       >.
	lxi	h,L1c5e		;; 0a4a: 21 5e 1c    .^.
	cmp	m		;; 0a4d: be          .
	jc	L0a5d		;; 0a4e: da 5d 0a    .].
	lda	L1c5e		;; 0a51: 3a 5e 1c    :^.
	adi	030h		;; 0a54: c6 30       .0
	mov	c,a		;; 0a56: 4f          O
	call	chrout		;; 0a57: cd 2c 18    .,.
	jmp	L0a68		;; 0a5a: c3 68 0a    .h.

L0a5d:	lda	L1c5e		;; 0a5d: 3a 5e 1c    :^.
	sui	00ah		;; 0a60: d6 0a       ..
	adi	041h		;; 0a62: c6 41       .A
	mov	c,a		;; 0a64: 4f          O
	call	chrout		;; 0a65: cd 2c 18    .,.
L0a68:	ret			;; 0a68: c9          .

L0a69:	lxi	h,L1c5f		;; 0a69: 21 5f 1c    ._.
	mov	m,c		;; 0a6c: 71          q
	lda	L1c5f		;; 0a6d: 3a 5f 1c    :_.
	ani	0f8h		;; 0a70: e6 f8       ..
	rar			;; 0a72: 1f          .
	rar			;; 0a73: 1f          .
	rar			;; 0a74: 1f          .
	rar			;; 0a75: 1f          .
	mov	c,a		;; 0a76: 4f          O
	call	L0a44		;; 0a77: cd 44 0a    .D.
	lda	L1c5f		;; 0a7a: 3a 5f 1c    :_.
	ani	00fh		;; 0a7d: e6 0f       ..
	mov	c,a		;; 0a7f: 4f          O
	call	L0a44		;; 0a80: cd 44 0a    .D.
	ret			;; 0a83: c9          .

L0a84:	lxi	h,L1c61		;; 0a84: 21 61 1c    .a.
	mov	m,b		;; 0a87: 70          p
	dcx	h		;; 0a88: 2b          +
	mov	m,c		;; 0a89: 71          q
	mvi	a,0ffh		;; 0a8a: 3e ff       >.
	lxi	d,L1c60		;; 0a8c: 11 60 1c    .`.
	call	andyya		;; 0a8f: cd f9 18    ...
	mov	c,l		;; 0a92: 4d          M
	call	L0a69		;; 0a93: cd 69 0a    .i.
	mvi	c,008h		;; 0a96: 0e 08       ..
	lxi	h,L1c60		;; 0a98: 21 60 1c    .`.
	call	shrxx		;; 0a9b: cd 5c 19    .\.
	mov	c,l		;; 0a9e: 4d          M
	call	L0a69		;; 0a9f: cd 69 0a    .i.
	ret			;; 0aa2: c9          .

exitms:	lxi	h,L1c63		;; 0aa3: 21 63 1c    .c.
	mov	m,b		;; 0aa6: 70          p
	dcx	h		;; 0aa7: 2b          +
	mov	m,c		;; 0aa8: 71          q
	lhld	L1c62		;; 0aa9: 2a 62 1c    *b.
	mov	b,h		;; 0aac: 44          D
	mov	c,l		;; 0aad: 4d          M
	call	msgout		;; 0aae: cd 47 18    .G.
	call	cpm		;; 0ab1: cd 00 00    ...
	ret			;; 0ab4: c9          .

L0ab5:	lxi	h,L1c65		;; 0ab5: 21 65 1c    .e.
	mov	m,b		;; 0ab8: 70          p
	dcx	h		;; 0ab9: 2b          +
	mov	m,c		;; 0aba: 71          q
	mvi	c,008h		;; 0abb: 0e 08       ..
	lxi	h,L1c64		;; 0abd: 21 64 1c    .d.
	call	shrxx		;; 0ac0: cd 5c 19    .\.
	xchg			;; 0ac3: eb          .
	mvi	c,008h		;; 0ac4: 0e 08       ..
	dcx	h		;; 0ac6: 2b          +
	push	d		;; 0ac7: d5          .
	call	shlxx		;; 0ac8: cd 4a 19    .J.
	pop	d		;; 0acb: d1          .
	call	orx		;; 0acc: cd 3c 19    .<.
	ret			;; 0acf: c9          .

L0ad0:	lxi	h,L1c68		;; 0ad0: 21 68 1c    .h.
	mov	m,d		;; 0ad3: 72          r
	dcx	h		;; 0ad4: 2b          +
	mov	m,e		;; 0ad5: 73          s
	dcx	h		;; 0ad6: 2b          +
	mov	m,c		;; 0ad7: 71          q
	lhld	L1c66		;; 0ad8: 2a 66 1c    *f.
	mvi	h,000h		;; 0adb: 26 00       &.
	lxi	b,L1b34		;; 0add: 01 34 1b    .4.
	dad	b		;; 0ae0: 09          .
	mov	c,m		;; 0ae1: 4e          N
	call	chrout		;; 0ae2: cd 2c 18    .,.
	lhld	L1c67		;; 0ae5: 2a 67 1c    *g.
	mov	b,h		;; 0ae8: 44          D
	mov	c,l		;; 0ae9: 4d          M
	call	L0ab5		;; 0aea: cd b5 0a    ...
	mov	b,h		;; 0aed: 44          D
	mov	c,l		;; 0aee: 4d          M
	call	L0a84		;; 0aef: cd 84 0a    ...
	mvi	c,020h		;; 0af2: 0e 20       . 
	call	chrout		;; 0af4: cd 2c 18    .,.
	ret			;; 0af7: c9          .

L0af8:	lhld	L1b33		;; 0af8: 2a 33 1b    *3.
	mvi	h,000h		;; 0afb: 26 00       &.
	lxi	b,L1b2b		;; 0afd: 01 2b 1b    .+.
	dad	h		;; 0b00: 29          )
	dad	b		;; 0b01: 09          .
	mvi	a,00fh		;; 0b02: 3e 0f       >.
	call	andxxa		;; 0b04: cd fa 18    ...
	mvi	a,000h		;; 0b07: 3e 00       >.
	call	subax		;; 0b09: cd 6c 19    .l.
	ora	l		;; 0b0c: b5          .
	sui	001h		;; 0b0d: d6 01       ..
	sbb	a		;; 0b0f: 9f          .
	lxi	h,L1b43		;; 0b10: 21 43 1b    .C.
	ora	m		;; 0b13: b6          .
	rar			;; 0b14: 1f          .
	jnc	L0b39		;; 0b15: d2 39 0b    .9.
	call	crlf		;; 0b18: cd 3c 18    .<.
	mvi	c,020h		;; 0b1b: 0e 20       . 
	call	chrout		;; 0b1d: cd 2c 18    .,.
	lhld	L1b33		;; 0b20: 2a 33 1b    *3.
	mvi	h,000h		;; 0b23: 26 00       &.
	lxi	b,L1b2b		;; 0b25: 01 2b 1b    .+.
	dad	h		;; 0b28: 29          )
	dad	b		;; 0b29: 09          .
	mov	e,m		;; 0b2a: 5e          ^
	inx	h		;; 0b2b: 23          #
	mov	d,m		;; 0b2c: 56          V
	lhld	L1b33		;; 0b2d: 2a 33 1b    *3.
	mov	c,l		;; 0b30: 4d          M
	call	L0ad0		;; 0b31: cd d0 0a    ...
	mvi	c,020h		;; 0b34: 0e 20       . 
	call	chrout		;; 0b36: cd 2c 18    .,.
L0b39:	ret			;; 0b39: c9          .

L0b3a:	lxi	h,L1c69		;; 0b3a: 21 69 1c    .i.
	mov	m,c		;; 0b3d: 71          q
	lhld	L1aaa		;; 0b3e: 2a aa 1a    *..
	lxi	b,L2392		;; 0b41: 01 92 23    ..#
	dad	b		;; 0b44: 09          .
	lda	L1c69		;; 0b45: 3a 69 1c    :i.
	mov	m,a		;; 0b48: 77          w
	lhld	L1aaa		;; 0b49: 2a aa 1a    *..
	inx	h		;; 0b4c: 23          #
	shld	L1aaa		;; 0b4d: 22 aa 1a    "..
	xchg			;; 0b50: eb          .
	lxi	h,L1aa8		;; 0b51: 21 a8 1a    ...
	call	L199b		;; 0b54: cd 9b 19    ...
	jc	L0b6f		;; 0b57: da 6f 0b    .o.
	lxi	b,L2392		;; 0b5a: 01 92 23    ..#
	push	b		;; 0b5d: c5          .
	lhld	L1aa8		;; 0b5e: 2a a8 1a    *..
	mov	b,h		;; 0b61: 44          D
	mov	c,l		;; 0b62: 4d          M
	lxi	d,irltmp	;; 0b63: 11 75 1a    .u.
	call	wrfile		;; 0b66: cd 7b 17    .{.
	lxi	h,00000h	;; 0b69: 21 00 00    ...
	shld	L1aaa		;; 0b6c: 22 aa 1a    "..
L0b6f:	ret			;; 0b6f: c9          .

L0b70:	lhld	relidx		;; 0b70: 2a 99 1a    *..
	xchg			;; 0b73: eb          .
	lxi	h,00080h	;; 0b74: 21 80 00    ...
	call	divhl		;; 0b77: cd 06 19    ...
	lhld	L1aac		;; 0b7a: 2a ac 1a    *..
	dad	d		;; 0b7d: 19          .
	shld	L1b44		;; 0b7e: 22 44 1b    "D.
	lhld	relidx		;; 0b81: 2a 99 1a    *..
	xchg			;; 0b84: eb          .
	call	divbc		;; 0b85: cd 08 19    ...
	xchg			;; 0b88: eb          .
	lxi	h,L1ac6		;; 0b89: 21 c6 1a    ...
	mov	m,e		;; 0b8c: 73          s
	lhld	L1b44		;; 0b8d: 2a 44 1b    *D.
	xchg			;; 0b90: eb          .
	call	divbc		;; 0b91: cd 08 19    ...
	lxi	h,L1ac4		;; 0b94: 21 c4 1a    ...
	mov	m,e		;; 0b97: 73          s
	lhld	L1b44		;; 0b98: 2a 44 1b    *D.
	xchg			;; 0b9b: eb          .
	call	divbc		;; 0b9c: cd 08 19    ...
	xchg			;; 0b9f: eb          .
	lxi	h,L1ac5		;; 0ba0: 21 c5 1a    ...
	mov	m,e		;; 0ba3: 73          s
	lxi	h,L1ac3		;; 0ba4: 21 c3 1a    ...
	mvi	m,000h		;; 0ba7: 36 00       6.
	ret			;; 0ba9: c9          .

L0baa:	lhld	L1aa2		;; 0baa: 2a a2 1a    *..
	xchg			;; 0bad: eb          .
	lxi	h,00080h	;; 0bae: 21 80 00    ...
	call	divhl		;; 0bb1: cd 06 19    ...
	lhld	L1aa6		;; 0bb4: 2a a6 1a    *..
	dad	d		;; 0bb7: 19          .
	shld	L1b44		;; 0bb8: 22 44 1b    "D.
	lhld	L1aa2		;; 0bbb: 2a a2 1a    *..
	xchg			;; 0bbe: eb          .
	call	divbc		;; 0bbf: cd 08 19    ...
	xchg			;; 0bc2: eb          .
	lxi	h,L1aca		;; 0bc3: 21 ca 1a    ...
	mov	m,e		;; 0bc6: 73          s
	lhld	L1b44		;; 0bc7: 2a 44 1b    *D.
	xchg			;; 0bca: eb          .
	call	divbc		;; 0bcb: cd 08 19    ...
	lxi	h,L1ac8		;; 0bce: 21 c8 1a    ...
	mov	m,e		;; 0bd1: 73          s
	lhld	L1b44		;; 0bd2: 2a 44 1b    *D.
	xchg			;; 0bd5: eb          .
	call	divbc		;; 0bd6: cd 08 19    ...
	xchg			;; 0bd9: eb          .
	lxi	h,L1ac9		;; 0bda: 21 c9 1a    ...
	mov	m,e		;; 0bdd: 73          s
	lxi	h,L1ac7		;; 0bde: 21 c7 1a    ...
	mvi	m,000h		;; 0be1: 36 00       6.
	ret			;; 0be3: c9          .

L0be4:	lhld	L1ac8		;; 0be4: 2a c8 1a    *..
	mov	c,l		;; 0be7: 4d          M
	call	L0b3a		;; 0be8: cd 3a 0b    .:.
	lhld	L1ac9		;; 0beb: 2a c9 1a    *..
	mov	c,l		;; 0bee: 4d          M
	call	L0b3a		;; 0bef: cd 3a 0b    .:.
	lhld	L1aca		;; 0bf2: 2a ca 1a    *..
	mov	c,l		;; 0bf5: 4d          M
	call	L0b3a		;; 0bf6: cd 3a 0b    .:.
	ret			;; 0bf9: c9          .

L0bfa:	mvi	c,008h		;; 0bfa: 0e 08       ..
	call	getbts		;; 0bfc: cd 7f 15    ...
	push	psw		;; 0bff: f5          .
	mvi	c,008h		;; 0c00: 0e 08       ..
	call	getbts		;; 0c02: cd 7f 15    ...
	mov	c,a		;; 0c05: 4f          O
	mvi	b,000h		;; 0c06: 06 00       ..
	mov	h,b		;; 0c08: 60          `
	mov	l,c		;; 0c09: 69          i
	mvi	c,008h		;; 0c0a: 0e 08       ..
	call	shlx		;; 0c0c: cd 4e 19    .N.
	pop	psw		;; 0c0f: f1          .
	call	orxa		;; 0c10: cd 39 19    .9.
	ret			;; 0c13: c9          .

L0c14:	mvi	c,002h		;; 0c14: 0e 02       ..
	call	getbts		;; 0c16: cd 7f 15    ...
	sta	L1b38		;; 0c19: 32 38 1b    28.
	call	L0bfa		;; 0c1c: cd fa 0b    ...
	shld	L1b39		;; 0c1f: 22 39 1b    "9.
	ret			;; 0c22: c9          .

L0c23:	mvi	c,003h		;; 0c23: 0e 03       ..
	call	getbts		;; 0c25: cd 7f 15    ...
	sta	L1b3b		;; 0c28: 32 3b 1b    2;.
	lxi	h,L1c6a		;; 0c2b: 21 6a 1c    .j.
	mvi	m,001h		;; 0c2e: 36 01       6.
L0c30:	lda	L1b3b		;; 0c30: 3a 3b 1b    :;.
	lxi	h,L1c6a		;; 0c33: 21 6a 1c    .j.
	cmp	m		;; 0c36: be          .
	jc	L0c55		;; 0c37: da 55 0c    .U.
	mvi	c,008h		;; 0c3a: 0e 08       ..
	call	getbts		;; 0c3c: cd 7f 15    ...
	push	psw		;; 0c3f: f5          .
	lda	L1c6a		;; 0c40: 3a 6a 1c    :j.
	dcr	a		;; 0c43: 3d          =
	mov	c,a		;; 0c44: 4f          O
	mvi	b,000h		;; 0c45: 06 00       ..
	lxi	h,L1b3c		;; 0c47: 21 3c 1b    .<.
	dad	b		;; 0c4a: 09          .
	pop	b		;; 0c4b: c1          .
	mov	c,b		;; 0c4c: 48          H
	mov	m,c		;; 0c4d: 71          q
	lxi	h,L1c6a		;; 0c4e: 21 6a 1c    .j.
	inr	m		;; 0c51: 34          4
	jnz	L0c30		;; 0c52: c2 30 0c    .0.
L0c55:	ret			;; 0c55: c9          .

L0c56:	lhld	L1b38		;; 0c56: 2a 38 1b    *8.
	mov	c,l		;; 0c59: 4d          M
	lhld	L1b39		;; 0c5a: 2a 39 1b    *9.
	xchg			;; 0c5d: eb          .
	call	L0ad0		;; 0c5e: cd d0 0a    ...
	ret			;; 0c61: c9          .

L0c62:	lxi	h,L1c6b		;; 0c62: 21 6b 1c    .k.
	mvi	m,001h		;; 0c65: 36 01       6.
L0c67:	lda	L1b3b		;; 0c67: 3a 3b 1b    :;.
	lxi	h,L1c6b		;; 0c6a: 21 6b 1c    .k.
	cmp	m		;; 0c6d: be          .
	jc	L0c87		;; 0c6e: da 87 0c    ...
	lda	L1c6b		;; 0c71: 3a 6b 1c    :k.
	dcr	a		;; 0c74: 3d          =
	mov	c,a		;; 0c75: 4f          O
	mvi	b,000h		;; 0c76: 06 00       ..
	lxi	h,L1b3c		;; 0c78: 21 3c 1b    .<.
	dad	b		;; 0c7b: 09          .
	mov	c,m		;; 0c7c: 4e          N
	call	chrout		;; 0c7d: cd 2c 18    .,.
	lxi	h,L1c6b		;; 0c80: 21 6b 1c    .k.
	inr	m		;; 0c83: 34          4
	jnz	L0c67		;; 0c84: c2 67 0c    .g.
L0c87:	mvi	c,020h		;; 0c87: 0e 20       . 
	call	chrout		;; 0c89: cd 2c 18    .,.
	ret			;; 0c8c: c9          .

L0c8d:	lxi	h,L1c6c		;; 0c8d: 21 6c 1c    .l.
	mov	m,c		;; 0c90: 71          q
	lhld	L1aa2		;; 0c91: 2a a2 1a    *..
	lxi	b,L2792		;; 0c94: 01 92 27    ..'
	dad	b		;; 0c97: 09          .
	lda	L1c6c		;; 0c98: 3a 6c 1c    :l.
	mov	m,a		;; 0c9b: 77          w
	lhld	L1aa2		;; 0c9c: 2a a2 1a    *..
	inx	h		;; 0c9f: 23          #
	shld	L1aa2		;; 0ca0: 22 a2 1a    "..
	xchg			;; 0ca3: eb          .
	lxi	h,L1aa0		;; 0ca4: 21 a0 1a    ...
	call	L199b		;; 0ca7: cd 9b 19    ...
	jc	L0cd3		;; 0caa: da d3 0c    ...
	lxi	b,L2792		;; 0cad: 01 92 27    ..'
	push	b		;; 0cb0: c5          .
	lhld	L1aa0		;; 0cb1: 2a a0 1a    *..
	mov	b,h		;; 0cb4: 44          D
	mov	c,l		;; 0cb5: 4d          M
	lxi	d,reltmp		;; 0cb6: 11 54 1a    .T.
	call	wrfile		;; 0cb9: cd 7b 17    .{.
	lhld	L1aa0		;; 0cbc: 2a a0 1a    *..
	xchg			;; 0cbf: eb          .
	lxi	h,00080h	;; 0cc0: 21 80 00    ...
	call	divhl		;; 0cc3: cd 06 19    ...
	lhld	L1aa6		;; 0cc6: 2a a6 1a    *..
	dad	d		;; 0cc9: 19          .
	shld	L1aa6		;; 0cca: 22 a6 1a    "..
	lxi	h,00000h	;; 0ccd: 21 00 00    ...
	shld	L1aa2		;; 0cd0: 22 a2 1a    "..
L0cd3:	ret			;; 0cd3: c9          .

L0cd4:	lxi	h,L1c6e		;; 0cd4: 21 6e 1c    .n.
	mov	m,e		;; 0cd7: 73          s
	dcx	h		;; 0cd8: 2b          +
	mov	m,c		;; 0cd9: 71          q
	lda	L1ac7		;; 0cda: 3a c7 1a    :..
	rar			;; 0cdd: 1f          .
	jnc	L0ce4		;; 0cde: d2 e4 0c    ...
	call	L0baa		;; 0ce1: cd aa 0b    ...
L0ce4:	lda	L1c6e		;; 0ce4: 3a 6e 1c    :n.
	lxi	h,L1aa4		;; 0ce7: 21 a4 1a    ...
	add	m		;; 0cea: 86          .
	mov	c,a		;; 0ceb: 4f          O
	mvi	a,008h		;; 0cec: 3e 08       >.
	cmp	c		;; 0cee: b9          .
	jnc	L0d0f		;; 0cef: d2 0f 0d    ...
	lxi	h,L1aa4		;; 0cf2: 21 a4 1a    ...
	mvi	a,008h		;; 0cf5: 3e 08       >.
	sub	m		;; 0cf7: 96          .
	mov	c,a		;; 0cf8: 4f          O
	lda	L1c6e		;; 0cf9: 3a 6e 1c    :n.
	sub	c		;; 0cfc: 91          .
	sta	L1c6e		;; 0cfd: 32 6e 1c    2n.
	mov	c,a		;; 0d00: 4f          O
	lxi	h,L1c6d		;; 0d01: 21 6d 1c    .m.
	call	shrm		;; 0d04: cd 54 19    .T.
	lxi	h,L1aa5		;; 0d07: 21 a5 1a    ...
	ora	m		;; 0d0a: b6          .
	mov	m,a		;; 0d0b: 77          w
	call	L0d26		;; 0d0c: cd 26 0d    .&.
L0d0f:	call	L0d38		;; 0d0f: cd 38 0d    .8.
	lxi	h,L1aa5		;; 0d12: 21 a5 1a    ...
	ora	m		;; 0d15: b6          .
	mov	m,a		;; 0d16: 77          w
	lda	L1c6f		;; 0d17: 3a 6f 1c    :o.
	sta	L1aa4		;; 0d1a: 32 a4 1a    2..
	cpi	008h		;; 0d1d: fe 08       ..
	jnz	L0d25		;; 0d1f: c2 25 0d    .%.
	call	L0d26		;; 0d22: cd 26 0d    .&.
L0d25:	ret			;; 0d25: c9          .

L0d26:	lhld	L1aa5		;; 0d26: 2a a5 1a    *..
	mov	c,l		;; 0d29: 4d          M
	call	L0c8d		;; 0d2a: cd 8d 0c    ...
	lxi	h,L1aa5		;; 0d2d: 21 a5 1a    ...
	mvi	m,000h		;; 0d30: 36 00       6.
	lxi	h,L1aa4		;; 0d32: 21 a4 1a    ...
	mvi	m,000h		;; 0d35: 36 00       6.
	ret			;; 0d37: c9          .

L0d38:	lda	L1c6e		;; 0d38: 3a 6e 1c    :n.
	lxi	h,L1aa4		;; 0d3b: 21 a4 1a    ...
	add	m		;; 0d3e: 86          .
	sta	L1c6f		;; 0d3f: 32 6f 1c    2o.
	cpi	008h		;; 0d42: fe 08       ..
	jnz	L0d4b		;; 0d44: c2 4b 0d    .K.
	lda	L1c6d		;; 0d47: 3a 6d 1c    :m.
	ret			;; 0d4a: c9          .

L0d4b:	lxi	h,L1c6f		;; 0d4b: 21 6f 1c    .o.
	mvi	a,008h		;; 0d4e: 3e 08       >.
	sub	m		;; 0d50: 96          .
	mov	c,a		;; 0d51: 4f          O
	lxi	h,L1c6d		;; 0d52: 21 6d 1c    .m.
	call	shlm		;; 0d55: cd 43 19    .C.
	ret			;; 0d58: c9          .

L0d59:	lxi	h,L1c70		;; 0d59: 21 70 1c    .p.
	mov	m,c		;; 0d5c: 71          q
	lhld	L1c70		;; 0d5d: 2a 70 1c    *p.
	mov	c,l		;; 0d60: 4d          M
	mvi	e,008h		;; 0d61: 1e 08       ..
	call	L0cd4		;; 0d63: cd d4 0c    ...
	ret			;; 0d66: c9          .

L0d67:	lxi	h,L1c72		;; 0d67: 21 72 1c    .r.
	mov	m,b		;; 0d6a: 70          p
	dcx	h		;; 0d6b: 2b          +
	mov	m,c		;; 0d6c: 71          q
	lhld	L1c71		;; 0d6d: 2a 71 1c    *q.
	mov	a,l		;; 0d70: 7d          }
	mov	c,a		;; 0d71: 4f          O
	call	L0d59		;; 0d72: cd 59 0d    .Y.
	lhld	L1c71		;; 0d75: 2a 71 1c    *q.
	mov	a,h		;; 0d78: 7c          |
	mov	c,a		;; 0d79: 4f          O
	call	L0d59		;; 0d7a: cd 59 0d    .Y.
	ret			;; 0d7d: c9          .

L0d7e:	lhld	L1b38		;; 0d7e: 2a 38 1b    *8.
	mov	c,l		;; 0d81: 4d          M
	mvi	e,002h		;; 0d82: 1e 02       ..
	call	L0cd4		;; 0d84: cd d4 0c    ...
	lhld	L1b39		;; 0d87: 2a 39 1b    *9.
	mov	b,h		;; 0d8a: 44          D
	mov	c,l		;; 0d8b: 4d          M
	call	L0d67		;; 0d8c: cd 67 0d    .g.
	ret			;; 0d8f: c9          .

L0d90:	lhld	L1b3b		;; 0d90: 2a 3b 1b    *;.
	mov	c,l		;; 0d93: 4d          M
	mvi	e,003h		;; 0d94: 1e 03       ..
	call	L0cd4		;; 0d96: cd d4 0c    ...
	lxi	h,L1c73		;; 0d99: 21 73 1c    .s.
	mvi	m,001h		;; 0d9c: 36 01       6.
L0d9e:	lda	L1b3b		;; 0d9e: 3a 3b 1b    :;.
	lxi	h,L1c73		;; 0da1: 21 73 1c    .s.
	cmp	m		;; 0da4: be          .
	jc	L0dbe		;; 0da5: da be 0d    ...
	lda	L1c73		;; 0da8: 3a 73 1c    :s.
	dcr	a		;; 0dab: 3d          =
	mov	c,a		;; 0dac: 4f          O
	mvi	b,000h		;; 0dad: 06 00       ..
	lxi	h,L1b3c		;; 0daf: 21 3c 1b    .<.
	dad	b		;; 0db2: 09          .
	mov	c,m		;; 0db3: 4e          N
	call	L0d59		;; 0db4: cd 59 0d    .Y.
	lxi	h,L1c73		;; 0db7: 21 73 1c    .s.
	inr	m		;; 0dba: 34          4
	jnz	L0d9e		;; 0dbb: c2 9e 0d    ...
L0dbe:	ret			;; 0dbe: c9          .

L0dbf:	call	L0be4		;; 0dbf: cd e4 0b    ...
	lxi	h,L1c74		;; 0dc2: 21 74 1c    .t.
	mvi	m,001h		;; 0dc5: 36 01       6.
L0dc7:	lda	L1b3b		;; 0dc7: 3a 3b 1b    :;.
	lxi	h,L1c74		;; 0dca: 21 74 1c    .t.
	cmp	m		;; 0dcd: be          .
	jc	L0de7		;; 0dce: da e7 0d    ...
	lda	L1c74		;; 0dd1: 3a 74 1c    :t.
	dcr	a		;; 0dd4: 3d          =
	mov	c,a		;; 0dd5: 4f          O
	mvi	b,000h		;; 0dd6: 06 00       ..
	lxi	h,L1b3c		;; 0dd8: 21 3c 1b    .<.
	dad	b		;; 0ddb: 09          .
	mov	c,m		;; 0ddc: 4e          N
	call	L0b3a		;; 0ddd: cd 3a 0b    .:.
	lxi	h,L1c74		;; 0de0: 21 74 1c    .t.
	inr	m		;; 0de3: 34          4
	jnz	L0dc7		;; 0de4: c2 c7 0d    ...
L0de7:	mvi	c,0feh		;; 0de7: 0e fe       ..
	call	L0b3a		;; 0de9: cd 3a 0b    .:.
	ret			;; 0dec: c9          .

L0ded:	mvi	c,008h		;; 0ded: 0e 08       ..
	call	getbts		;; 0def: cd 7f 15    ...
	sta	L1c75		;; 0df2: 32 75 1c    2u.
	lda	L19fd		;; 0df5: 3a fd 19    :..
	rar			;; 0df8: 1f          .
	jnc	L0dfd		;; 0df9: d2 fd 0d    ...
	ret			;; 0dfc: c9          .

L0dfd:	lda	L1ab6		;; 0dfd: 3a b6 1a    :..
	rar			;; 0e00: 1f          .
	jnc	L0e2a		;; 0e01: d2 2a 0e    .*.
	call	L0af8		;; 0e04: cd f8 0a    ...
	lhld	L1c75		;; 0e07: 2a 75 1c    *u.
	mov	c,l		;; 0e0a: 4d          M
	call	L0a69		;; 0e0b: cd 69 0a    .i.
	mvi	c,020h		;; 0e0e: 0e 20       . 
	call	chrout		;; 0e10: cd 2c 18    .,.
	lhld	L1b33		;; 0e13: 2a 33 1b    *3.
	mvi	h,000h		;; 0e16: 26 00       &.
	lxi	b,L1b2b		;; 0e18: 01 2b 1b    .+.
	dad	h		;; 0e1b: 29          )
	dad	b		;; 0e1c: 09          .
	mov	c,m		;; 0e1d: 4e          N
	inx	h		;; 0e1e: 23          #
	mov	b,m		;; 0e1f: 46          F
	inx	b		;; 0e20: 03          .
	dcx	h		;; 0e21: 2b          +
	mov	m,c		;; 0e22: 71          q
	inx	h		;; 0e23: 23          #
	mov	m,b		;; 0e24: 70          p
	lxi	h,L1b43		;; 0e25: 21 43 1b    .C.
	mvi	m,000h		;; 0e28: 36 00       6.
L0e2a:	lda	L1ab8		;; 0e2a: 3a b8 1a    :..
	rar			;; 0e2d: 1f          .
	jnc	L0e3f		;; 0e2e: d2 3f 0e    .?.
	mvi	e,001h		;; 0e31: 1e 01       ..
	mvi	c,000h		;; 0e33: 0e 00       ..
	call	L0cd4		;; 0e35: cd d4 0c    ...
	lhld	L1c75		;; 0e38: 2a 75 1c    *u.
	mov	c,l		;; 0e3b: 4d          M
	call	L0d59		;; 0e3c: cd 59 0d    .Y.
L0e3f:	ret			;; 0e3f: c9          .

L0e40:	lxi	h,L1c76		;; 0e40: 21 76 1c    .v.
	mov	m,c		;; 0e43: 71          q
	call	L0bfa		;; 0e44: cd fa 0b    ...
	shld	L1c77		;; 0e47: 22 77 1c    "w.
	lda	L19fd		;; 0e4a: 3a fd 19    :..
	rar			;; 0e4d: 1f          .
	jnc	L0e52		;; 0e4e: d2 52 0e    .R.
	ret			;; 0e51: c9          .

L0e52:	lda	L1ab6		;; 0e52: 3a b6 1a    :..
	rar			;; 0e55: 1f          .
	jnc	L0e95		;; 0e56: d2 95 0e    ...
	call	L0af8		;; 0e59: cd f8 0a    ...
	lhld	L1c76		;; 0e5c: 2a 76 1c    *v.
	mov	c,l		;; 0e5f: 4d          M
	lhld	L1c77		;; 0e60: 2a 77 1c    *w.
	xchg			;; 0e63: eb          .
	call	L0ad0		;; 0e64: cd d0 0a    ...
	lhld	L1b33		;; 0e67: 2a 33 1b    *3.
	mvi	h,000h		;; 0e6a: 26 00       &.
	lxi	b,L1b2b		;; 0e6c: 01 2b 1b    .+.
	dad	h		;; 0e6f: 29          )
	dad	b		;; 0e70: 09          .
	mov	c,m		;; 0e71: 4e          N
	inx	h		;; 0e72: 23          #
	mov	b,m		;; 0e73: 46          F
	inx	b		;; 0e74: 03          .
	inx	b		;; 0e75: 03          .
	dcx	h		;; 0e76: 2b          +
	mov	m,c		;; 0e77: 71          q
	inx	h		;; 0e78: 23          #
	mov	m,b		;; 0e79: 70          p
	lhld	L1b33		;; 0e7a: 2a 33 1b    *3.
	mvi	h,000h		;; 0e7d: 26 00       &.
	lxi	b,L1b2b		;; 0e7f: 01 2b 1b    .+.
	dad	h		;; 0e82: 29          )
	dad	b		;; 0e83: 09          .
	mvi	a,00fh		;; 0e84: 3e 0f       >.
	call	andxxa		;; 0e86: cd fa 18    ...
	mvi	a,001h		;; 0e89: 3e 01       >.
	call	subax		;; 0e8b: cd 6c 19    .l.
	ora	l		;; 0e8e: b5          .
	sui	001h		;; 0e8f: d6 01       ..
	sbb	a		;; 0e91: 9f          .
	sta	L1b43		;; 0e92: 32 43 1b    2C.
L0e95:	lda	L1ab8		;; 0e95: 3a b8 1a    :..
	rar			;; 0e98: 1f          .
	jnc	L0eb4		;; 0e99: d2 b4 0e    ...
	mvi	e,001h		;; 0e9c: 1e 01       ..
	mvi	c,001h		;; 0e9e: 0e 01       ..
	call	L0cd4		;; 0ea0: cd d4 0c    ...
	lhld	L1c76		;; 0ea3: 2a 76 1c    *v.
	mov	c,l		;; 0ea6: 4d          M
	mvi	e,002h		;; 0ea7: 1e 02       ..
	call	L0cd4		;; 0ea9: cd d4 0c    ...
	lhld	L1c77		;; 0eac: 2a 77 1c    *w.
	mov	b,h		;; 0eaf: 44          D
	mov	c,l		;; 0eb0: 4d          M
	call	L0d67		;; 0eb1: cd 67 0d    .g.
L0eb4:	ret			;; 0eb4: c9          .

L0eb5:	lxi	h,L1c79		;; 0eb5: 21 79 1c    .y.
	mov	m,c		;; 0eb8: 71          q
	lda	L1c79		;; 0eb9: 3a 79 1c    :y.
	sui	005h		;; 0ebc: d6 05       ..
	sbb	a		;; 0ebe: 9f          .
	cma			;; 0ebf: 2f          /
	push	psw		;; 0ec0: f5          .
	lda	L1c79		;; 0ec1: 3a 79 1c    :y.
	sui	00fh		;; 0ec4: d6 0f       ..
	adi	0ffh		;; 0ec6: c6 ff       ..
	sbb	a		;; 0ec8: 9f          .
	pop	b		;; 0ec9: c1          .
	mov	c,b		;; 0eca: 48          H
	ana	c		;; 0ecb: a1          .
	rar			;; 0ecc: 1f          .
	jnc	L0ed3		;; 0ecd: d2 d3 0e    ...
	call	L0c14		;; 0ed0: cd 14 0c    ...
L0ed3:	mvi	a,008h		;; 0ed3: 3e 08       >.
	lxi	h,L1c79		;; 0ed5: 21 79 1c    .y.
	cmp	m		;; 0ed8: be          .
	jc	L0edf		;; 0ed9: da df 0e    ...
	call	L0c23		;; 0edc: cd 23 0c    .#.
L0edf:	lda	L1c79		;; 0edf: 3a 79 1c    :y.
	cpi	00eh		;; 0ee2: fe 0e       ..
	jnz	L0f19		;; 0ee4: c2 19 0f    ...
	lda	libflg		;; 0ee7: 3a fc 19    :..
	rar			;; 0eea: 1f          .
	jnc	L0f05		;; 0eeb: d2 05 0f    ...
L0eee:	lda	libbit		;; 0eee: 3a 9d 1a    :..
	cpi	008h		;; 0ef1: fe 08       ..
	jz	L0f02		;; 0ef3: ca 02 0f    ...
	mvi	c,001h		;; 0ef6: 0e 01       ..
	call	getbts		;; 0ef8: cd 7f 15    ...
	rar			;; 0efb: 1f          .
	jnc	L0eff		;; 0efc: d2 ff 0e    ...
L0eff:	jmp	L0eee		;; 0eff: c3 ee 0e    ...

L0f02:	jmp	L0f19		;; 0f02: c3 19 0f    ...

L0f05:	lda	relbit		;; 0f05: 3a 98 1a    :..
	cpi	8		;; 0f08: fe 08       ..
	jz	L0f19		;; 0f0a: ca 19 0f    ...
	mvi	c,1		;; 0f0d: 0e 01       ..
	call	getbts		;; 0f0f: cd 7f 15    ...
	rar			;; 0f12: 1f          .
	jnc	L0f16		;; 0f13: d2 16 0f    ...
L0f16:	jmp	L0f05		;; 0f16: c3 05 0f    ...

L0f19:	lda	L1c79		;; 0f19: 3a 79 1c    :y.
	cpi	002h		;; 0f1c: fe 02       ..
	jnz	L0f38		;; 0f1e: c2 38 0f    .8.
	lhld	L1b3b		;; 0f21: 2a 3b 1b    *;.
	lxi	d,L1ad1		;; 0f24: 11 d1 1a    ...
	lxi	b,L1b3c		;; 0f27: 01 3c 1b    .<.
L0f2a:	ldax	b		;; 0f2a: 0a          .
	stax	d		;; 0f2b: 12          .
	inx	b		;; 0f2c: 03          .
	inx	d		;; 0f2d: 13          .
	dcr	l		;; 0f2e: 2d          -
	jnz	L0f2a		;; 0f2f: c2 2a 0f    .*.
	lda	L1b3b		;; 0f32: 3a 3b 1b    :;.
	sta	L1ad0		;; 0f35: 32 d0 1a    2..
L0f38:	lda	L19fd		;; 0f38: 3a fd 19    :..
	rar			;; 0f3b: 1f          .
	jnc	L0f40		;; 0f3c: d2 40 0f    .@.
	ret			;; 0f3f: c9          .

L0f40:	lda	L1ab6		;; 0f40: 3a b6 1a    :..
	rar			;; 0f43: 1f          .
	jnc	L0fc5		;; 0f44: d2 c5 0f    ...
	call	crlf		;; 0f47: cd 3c 18    .<.
	lxi	h,L1b43		;; 0f4a: 21 43 1b    .C.
	mvi	m,001h		;; 0f4d: 36 01       6.
	lhld	L1c79		;; 0f4f: 2a 79 1c    *y.
	mvi	h,000h		;; 0f52: 26 00       &.
	lxi	b,L1c3e		;; 0f54: 01 3e 1c    .>.
	dad	h		;; 0f57: 29          )
	dad	b		;; 0f58: 09          .
	mov	c,m		;; 0f59: 4e          N
	inx	h		;; 0f5a: 23          #
	mov	b,m		;; 0f5b: 46          F
	call	msgout		;; 0f5c: cd 47 18    .G.
	mvi	a,008h		;; 0f5f: 3e 08       >.
	lxi	h,L1c79		;; 0f61: 21 79 1c    .y.
	cmp	m		;; 0f64: be          .
	jc	L0f6b		;; 0f65: da 6b 0f    .k.
	call	L0c62		;; 0f68: cd 62 0c    .b.
L0f6b:	lda	L1c79		;; 0f6b: 3a 79 1c    :y.
	sui	005h		;; 0f6e: d6 05       ..
	sbb	a		;; 0f70: 9f          .
	cma			;; 0f71: 2f          /
	push	psw		;; 0f72: f5          .
	lda	L1c79		;; 0f73: 3a 79 1c    :y.
	sui	00fh		;; 0f76: d6 0f       ..
	adi	0ffh		;; 0f78: c6 ff       ..
	sbb	a		;; 0f7a: 9f          .
	pop	b		;; 0f7b: c1          .
	mov	c,b		;; 0f7c: 48          H
	ana	c		;; 0f7d: a1          .
	rar			;; 0f7e: 1f          .
	jnc	L0f85		;; 0f7f: d2 85 0f    ...
	call	L0c56		;; 0f82: cd 56 0c    .V.
L0f85:	lda	L1c79		;; 0f85: 3a 79 1c    :y.
	cpi	00bh		;; 0f88: fe 0b       ..
	jnz	L0fa6		;; 0f8a: c2 a6 0f    ...
	lda	L1b38		;; 0f8d: 3a 38 1b    :8.
	sta	L1b33		;; 0f90: 32 33 1b    23.
	lhld	L1b33		;; 0f93: 2a 33 1b    *3.
	mvi	h,000h		;; 0f96: 26 00       &.
	lxi	b,L1b2b		;; 0f98: 01 2b 1b    .+.
	dad	h		;; 0f9b: 29          )
	dad	b		;; 0f9c: 09          .
	push	h		;; 0f9d: e5          .
	lhld	L1b39		;; 0f9e: 2a 39 1b    *9.
	xchg			;; 0fa1: eb          .
	pop	h		;; 0fa2: e1          .
	mov	m,e		;; 0fa3: 73          s
	inx	h		;; 0fa4: 23          #
	mov	m,d		;; 0fa5: 72          r
L0fa6:	lda	L1c79		;; 0fa6: 3a 79 1c    :y.
	cpi	00eh		;; 0fa9: fe 0e       ..
	jnz	L0fc5		;; 0fab: c2 c5 0f    ...
	lxi	h,00000h	;; 0fae: 21 00 00    ...
	shld	L1b2b		;; 0fb1: 22 2b 1b    "+.
	shld	L1b2d		;; 0fb4: 22 2d 1b    "-.
	shld	L1b2f		;; 0fb7: 22 2f 1b    "/.
	shld	L1b31		;; 0fba: 22 31 1b    "1.
	lxi	h,L1b33		;; 0fbd: 21 33 1b    .3.
	mvi	m,001h		;; 0fc0: 36 01       6.
	call	crlf		;; 0fc2: cd 3c 18    .<.
L0fc5:	lda	L1aba		;; 0fc5: 3a ba 1a    :..
	rar			;; 0fc8: 1f          .
	jnc	L0fe0		;; 0fc9: d2 e0 0f    ...
	lda	L1c79		;; 0fcc: 3a 79 1c    :y.
	cpi	000h		;; 0fcf: fe 00       ..
	jnz	L0fe0		;; 0fd1: c2 e0 0f    ...
	call	crlf		;; 0fd4: cd 3c 18    .<.
	lxi	b,L0a40		;; 0fd7: 01 40 0a    .@.
	call	msgout		;; 0fda: cd 47 18    .G.
	call	L0c62		;; 0fdd: cd 62 0c    .b.
L0fe0:	lda	L1aba		;; 0fe0: 3a ba 1a    :..
	lxi	h,L1ab9		;; 0fe3: 21 b9 1a    ...
	ora	m		;; 0fe6: b6          .
	rar			;; 0fe7: 1f          .
	jnc	L0ff9		;; 0fe8: d2 f9 0f    ...
	lda	L1c79		;; 0feb: 3a 79 1c    :y.
	cpi	002h		;; 0fee: fe 02       ..
	jnz	L0ff9		;; 0ff0: c2 f9 0f    ...
	call	crlf		;; 0ff3: cd 3c 18    .<.
	call	L0c62		;; 0ff6: cd 62 0c    .b.
L0ff9:	lda	L1ab8		;; 0ff9: 3a b8 1a    :..
	rar			;; 0ffc: 1f          .
	jnc	L1049		;; 0ffd: d2 49 10    .I.
	lda	L1c79		;; 1000: 3a 79 1c    :y.
	cpi	00fh		;; 1003: fe 0f       ..
	jnc	L102f		;; 1005: d2 2f 10    ./.
	mvi	e,003h		;; 1008: 1e 03       ..
	mvi	c,004h		;; 100a: 0e 04       ..
	call	L0cd4		;; 100c: cd d4 0c    ...
	lhld	L1c79		;; 100f: 2a 79 1c    *y.
	mov	c,l		;; 1012: 4d          M
	mvi	e,004h		;; 1013: 1e 04       ..
	call	L0cd4		;; 1015: cd d4 0c    ...
	lda	L1c79		;; 1018: 3a 79 1c    :y.
	cpi	005h		;; 101b: fe 05       ..
	jc	L1023		;; 101d: da 23 10    .#.
	call	L0d7e		;; 1020: cd 7e 0d    .~.
L1023:	mvi	a,008h		;; 1023: 3e 08       >.
	lxi	h,L1c79		;; 1025: 21 79 1c    .y.
	cmp	m		;; 1028: be          .
	jc	L102f		;; 1029: da 2f 10    ./.
	call	L0d90		;; 102c: cd 90 0d    ...
L102f:	lda	L1c79		;; 102f: 3a 79 1c    :y.
	cpi	00eh		;; 1032: fe 0e       ..
	jnz	L1049		;; 1034: c2 49 10    .I.
L1037:	lda	L1aa4		;; 1037: 3a a4 1a    :..
	cpi	000h		;; 103a: fe 00       ..
	jz	L1049		;; 103c: ca 49 10    .I.
	mvi	e,001h		;; 103f: 1e 01       ..
	mvi	c,000h		;; 1041: 0e 00       ..
	call	L0cd4		;; 1043: cd d4 0c    ...
	jmp	L1037		;; 1046: c3 37 10    .7.

L1049:	lda	L1ab7		;; 1049: 3a b7 1a    :..
	rar			;; 104c: 1f          .
	jnc	L105b		;; 104d: d2 5b 10    .[.
	lda	L1c79		;; 1050: 3a 79 1c    :y.
	cpi	000h		;; 1053: fe 00       ..
	jnz	L105b		;; 1055: c2 5b 10    .[.
	call	L0dbf		;; 1058: cd bf 0d    ...
L105b:	ret			;; 105b: c9          .

L105c:	mvi	c,001h		;; 105c: 0e 01       ..
	call	getbts		;; 105e: cd 7f 15    ...
	cpi	000h		;; 1061: fe 00       ..
	jnz	L106f		;; 1063: c2 6f 10    .o.
	call	L0ded		;; 1066: cd ed 0d    ...
	mvi	a,013h		;; 1069: 3e 13       >.
	ret			;; 106b: c9          .

	jmp	L10a1		;; 106c: c3 a1 10    ...

L106f:	mvi	c,002h		;; 106f: 0e 02       ..
	call	getbts		;; 1071: cd 7f 15    ...
	sta	L1c7a		;; 1074: 32 7a 1c    2z.
	mov	c,a		;; 1077: 4f          O
	mvi	a,000h		;; 1078: 3e 00       >.
	cmp	c		;; 107a: b9          .
	jnc	L108e		;; 107b: d2 8e 10    ...
	lhld	L1c7a		;; 107e: 2a 7a 1c    *z.
	mov	c,l		;; 1081: 4d          M
	call	L0e40		;; 1082: cd 40 0e    .@.
	lda	L1c7a		;; 1085: 3a 7a 1c    :z.
	adi	00fh		;; 1088: c6 0f       ..
	ret			;; 108a: c9          .

	jmp	L10a1		;; 108b: c3 a1 10    ...

L108e:	mvi	c,004h		;; 108e: 0e 04       ..
	call	getbts		;; 1090: cd 7f 15    ...
	sta	L1c7a		;; 1093: 32 7a 1c    2z.
	lhld	L1c7a		;; 1096: 2a 7a 1c    *z.
	mov	c,l		;; 1099: 4d          M
	call	L0eb5		;; 109a: cd b5 0e    ...
	lda	L1c7a		;; 109d: 3a 7a 1c    :z.
	ret			;; 10a0: c9          .

L10a1:	ret			;; 10a1: c9          .

L10a2:	db	0
L10a3:	db	',=',0,'>)-',0ffh
L10aa:	db	',)',0ffh
L10ad:	db	',>',0ffh
L10b0:	db	',=',0,0ffh
L10b4:	lhld	cmdptr		;; 10b4: 2a b0 1a    *..
	inx	h		;; 10b7: 23          #
	shld	cmdptr		;; 10b8: 22 b0 1a    "..
	ret			;; 10bb: c9          .

L10bc:	lxi	h,L1c7c		;; 10bc: 21 7c 1c    .|.
	mov	m,b		;; 10bf: 70          p
	dcx	h		;; 10c0: 2b          +
	mov	m,c		;; 10c1: 71          q
L10c2:	lhld	L1c7b		;; 10c2: 2a 7b 1c    *{.
	mov	a,m		;; 10c5: 7e          ~
	cpi	0ffh		;; 10c6: fe ff       ..
	jz	L10e5		;; 10c8: ca e5 10    ...
	lhld	cmdptr		;; 10cb: 2a b0 1a    *..
	push	h		;; 10ce: e5          .
	lhld	L1c7b		;; 10cf: 2a 7b 1c    *{.
	pop	b		;; 10d2: c1          .
	ldax	b		;; 10d3: 0a          .
	cmp	m		;; 10d4: be          .
	jnz	L10db		;; 10d5: c2 db 10    ...
	mvi	a,000h		;; 10d8: 3e 00       >.
	ret			;; 10da: c9          .

L10db:	lhld	L1c7b		;; 10db: 2a 7b 1c    *{.
	inx	h		;; 10de: 23          #
	shld	L1c7b		;; 10df: 22 7b 1c    "{.
	jmp	L10c2		;; 10e2: c3 c2 10    ...

L10e5:	mvi	a,001h		;; 10e5: 3e 01       >.
	ret			;; 10e7: c9          .

L10e8:	call	L10b4		;; 10e8: cd b4 10    ...
	lhld	cmdptr		;; 10eb: 2a b0 1a    *..
	mov	a,m		;; 10ee: 7e          ~
	sui	03eh		;; 10ef: d6 3e       .>
	sui	001h		;; 10f1: d6 01       ..
	sbb	a		;; 10f3: 9f          .
	push	psw		;; 10f4: f5          .
	mov	a,m		;; 10f5: 7e          ~
	sui	02ch		;; 10f6: d6 2c       .,
	sui	001h		;; 10f8: d6 01       ..
	sbb	a		;; 10fa: 9f          .
	pop	b		;; 10fb: c1          .
	mov	c,b		;; 10fc: 48          H
	ora	c		;; 10fd: b1          .
	rar			;; 10fe: 1f          .
	jnc	L110a		;; 10ff: d2 0a 11    ...
	lxi	h,L1abd		;; 1102: 21 bd 1a    ...
	mvi	m,001h		;; 1105: 36 01       6.
	jmp	L1129		;; 1107: c3 29 11    .).

L110a:	lxi	h,deffcb	;; 110a: 21 5c 00    .\.
	shld	cmdptr+2	;; 110d: 22 b2 1a    "..
	lxi	b,cmdptr	;; 1110: 01 b0 1a    ...
	call	L1413		;; 1113: cd 13 14    ...
	shld	cmdptr		;; 1116: 22 b0 1a    "..
	xchg			;; 1119: eb          .
	lxi	h,0fffeh	;; 111a: 21 fe ff    ...
	call	subx		;; 111d: cd 6f 19    .o.
	jc	L1129		;; 1120: da 29 11    .).
	lxi	b,L1af8		;; 1123: 01 f8 1a    ...
	call	exitms		;; 1126: cd a3 0a    ...
L1129:	ret			;; 1129: c9          .

L112a:	lxi	h,L1abc		;; 112a: 21 bc 1a    ...
	mvi	m,000h		;; 112d: 36 00       6.
	lxi	h,L1ad8		;; 112f: 21 d8 1a    ...
	mvi	m,000h		;; 1132: 36 00       6.
	call	L10b4		;; 1134: cd b4 10    ...
L1137:	lxi	b,L10a3		;; 1137: 01 a3 10    ...
	call	L10bc		;; 113a: cd bc 10    ...
	rar			;; 113d: 1f          .
	jnc	L1169		;; 113e: d2 69 11    .i.
	lhld	cmdptr		;; 1141: 2a b0 1a    *..
	push	h		;; 1144: e5          .
	lhld	L1ad8		;; 1145: 2a d8 1a    *..
	mvi	h,000h		;; 1148: 26 00       &.
	lxi	b,L1ad9		;; 114a: 01 d9 1a    ...
	dad	b		;; 114d: 09          .
	pop	d		;; 114e: d1          .
	ldax	d		;; 114f: 1a          .
	mov	m,a		;; 1150: 77          w
	lda	L1ad8		;; 1151: 3a d8 1a    :..
	inr	a		;; 1154: 3c          <
	sta	L1ad8		;; 1155: 32 d8 1a    2..
	cpi	007h		;; 1158: fe 07       ..
	jc	L1163		;; 115a: da 63 11    .c.
	lxi	b,L1af8		;; 115d: 01 f8 1a    ...
	call	exitms		;; 1160: cd a3 0a    ...
L1163:	call	L10b4		;; 1163: cd b4 10    ...
	jmp	L1137		;; 1166: c3 37 11    .7.

L1169:	lhld	cmdptr		;; 1169: 2a b0 1a    *..
	mov	a,m		;; 116c: 7e          ~
	cpi	02dh		;; 116d: fe 2d       .-
	jnz	L1177		;; 116f: c2 77 11    .w.
	lxi	h,L1abc		;; 1172: 21 bc 1a    ...
	mvi	m,001h		;; 1175: 36 01       6.
L1177:	lhld	cmdptr		;; 1177: 2a b0 1a    *..
	mov	a,m		;; 117a: 7e          ~
	cpi	029h		;; 117b: fe 29       .)
	jnz	L1185		;; 117d: c2 85 11    ...
	lxi	h,L1acf		;; 1180: 21 cf 1a    ...
	mvi	m,001h		;; 1183: 36 01       6.
L1185:	ret			;; 1185: c9          .

L1186:	lda	L1abf		;; 1186: 3a bf 1a    :..
	rar			;; 1189: 1f          .
	jnc	L1193		;; 118a: d2 93 11    ...
	lxi	b,L1af8		;; 118d: 01 f8 1a    ...
	call	exitms		;; 1190: cd a3 0a    ...
L1193:	lxi	h,L1abf		;; 1193: 21 bf 1a    ...
	mvi	m,001h		;; 1196: 36 01       6.
	lhld	cmdptr		;; 1198: 2a b0 1a    *..
	shld	L1ac1		;; 119b: 22 c1 1a    "..
L119e:	lhld	cmdptr		;; 119e: 2a b0 1a    *..
	mov	a,m		;; 11a1: 7e          ~
	cpi	029h		;; 11a2: fe 29       .)
	jz	L1207		;; 11a4: ca 07 12    ...
	call	L112a		;; 11a7: cd 2a 11    .*.
	lda	L1ad8		;; 11aa: 3a d8 1a    :..
	cpi	000h		;; 11ad: fe 00       ..
	jnz	L11ba		;; 11af: c2 ba 11    ...
	lxi	h,L1ac0		;; 11b2: 21 c0 1a    ...
	mvi	m,001h		;; 11b5: 36 01       6.
	jmp	L11d8		;; 11b7: c3 d8 11    ...

L11ba:	lhld	L1ad8		;; 11ba: 2a d8 1a    *..
	xchg			;; 11bd: eb          .
	lxi	b,L1ad9		;; 11be: 01 d9 1a    ...
	call	L022a		;; 11c1: cd 2a 02    .*.
	rar			;; 11c4: 1f          .
	jc	L11d8		;; 11c5: da d8 11    ...
	lxi	b,L1ad9		;; 11c8: 01 d9 1a    ...
	push	b		;; 11cb: c5          .
	lhld	L1ad8		;; 11cc: 2a d8 1a    *..
	push	h		;; 11cf: e5          .
	lxi	d,00000h	;; 11d0: 11 00 00    ...
	mvi	c,000h		;; 11d3: 0e 00       ..
	call	L0284		;; 11d5: cd 84 02    ...
L11d8:	lda	L1abc		;; 11d8: 3a bc 1a    :..
	rar			;; 11db: 1f          .
	jnc	L11f4		;; 11dc: d2 f4 11    ...
	call	L112a		;; 11df: cd 2a 11    .*.
	lda	L1ad8		;; 11e2: 3a d8 1a    :..
	cpi	000h		;; 11e5: fe 00       ..
	jnz	L11f4		;; 11e7: c2 f4 11    ...
	lxi	h,L1ad8		;; 11ea: 21 d8 1a    ...
	mvi	m,001h		;; 11ed: 36 01       6.
	lxi	h,L1ad9		;; 11ef: 21 d9 1a    ...
	mvi	m,06ch		;; 11f2: 36 6c       6l
L11f4:	lxi	b,L10aa		;; 11f4: 01 aa 10    ...
	call	L10bc		;; 11f7: cd bc 10    ...
	rar			;; 11fa: 1f          .
	jnc	L1204		;; 11fb: d2 04 12    ...
	lxi	b,L1af8		;; 11fe: 01 f8 1a    ...
	call	exitms		;; 1201: cd a3 0a    ...
L1204:	jmp	L119e		;; 1204: c3 9e 11    ...

L1207:	ret			;; 1207: c9          .

L1208:	lxi	h,L1abe		;; 1208: 21 be 1a    ...
	mvi	m,001h		;; 120b: 36 01       6.
L120d:	lhld	cmdptr		;; 120d: 2a b0 1a    *..
	mov	a,m		;; 1210: 7e          ~
	cpi	03eh		;; 1211: fe 3e       .>
	jz	L12a4		;; 1213: ca a4 12    ...
	lhld	cmdptr		;; 1216: 2a b0 1a    *..
	inx	h		;; 1219: 23          #
	shld	L1c7d		;; 121a: 22 7d 1c    "}.
	lxi	h,L1abd		;; 121d: 21 bd 1a    ...
	mvi	m,000h		;; 1220: 36 00       6.
	call	L112a		;; 1222: cd 2a 11    .*.
	lda	L1ad8		;; 1225: 3a d8 1a    :..
	cpi	000h		;; 1228: fe 00       ..
	jnz	L1233		;; 122a: c2 33 12    .3.
	lxi	b,L1af8		;; 122d: 01 f8 1a    ...
	call	exitms		;; 1230: cd a3 0a    ...
L1233:	lhld	cmdptr		;; 1233: 2a b0 1a    *..
	mov	a,m		;; 1236: 7e          ~
	cpi	03dh		;; 1237: fe 3d       .=
	jnz	L1258		;; 1239: c2 58 12    .X.
	lxi	h,L1abb		;; 123c: 21 bb 1a    ...
	mvi	m,001h		;; 123f: 36 01       6.
	lhld	cmdptr		;; 1241: 2a b0 1a    *..
	inx	h		;; 1244: 23          #
	shld	L1c7d		;; 1245: 22 7d 1c    "}.
	call	L10e8		;; 1248: cd e8 10    ...
	lda	L1abd		;; 124b: 3a bd 1a    :..
	rar			;; 124e: 1f          .
	jnc	L1258		;; 124f: d2 58 12    .X.
	lxi	h,00000h	;; 1252: 21 00 00    ...
	shld	L1c7d		;; 1255: 22 7d 1c    "}.
L1258:	lhld	L1ad8		;; 1258: 2a d8 1a    *..
	xchg			;; 125b: eb          .
	lxi	b,L1ad9		;; 125c: 01 d9 1a    ...
	call	L022a		;; 125f: cd 2a 02    .*.
	rar			;; 1262: 1f          .
	jnc	L1280		;; 1263: d2 80 12    ...
	lxi	b,00004h	;; 1266: 01 04 00    ...
	lhld	L1ab4		;; 1269: 2a b4 1a    *..
	dad	b		;; 126c: 09          .
	push	h		;; 126d: e5          .
	lhld	L1c7d		;; 126e: 2a 7d 1c    *}.
	xchg			;; 1271: eb          .
	pop	h		;; 1272: e1          .
	mov	m,e		;; 1273: 73          s
	inx	h		;; 1274: 23          #
	mov	m,d		;; 1275: 72          r
	lhld	L1ab4		;; 1276: 2a b4 1a    *..
	mvi	a,080h		;; 1279: 3e 80       >.
	ora	m		;; 127b: b6          .
	mov	m,a		;; 127c: 77          w
	jmp	L1291		;; 127d: c3 91 12    ...

L1280:	lxi	b,L1ad9		;; 1280: 01 d9 1a    ...
	push	b		;; 1283: c5          .
	lhld	L1ad8		;; 1284: 2a d8 1a    *..
	push	h		;; 1287: e5          .
	lhld	L1c7d		;; 1288: 2a 7d 1c    *}.
	xchg			;; 128b: eb          .
	mvi	c,001h		;; 128c: 0e 01       ..
	call	L0284		;; 128e: cd 84 02    ...
L1291:	lxi	b,L10ad		;; 1291: 01 ad 10    ...
	call	L10bc		;; 1294: cd bc 10    ...
	rar			;; 1297: 1f          .
	jnc	L12a1		;; 1298: d2 a1 12    ...
	lxi	b,L1af8		;; 129b: 01 f8 1a    ...
	call	exitms		;; 129e: cd a3 0a    ...
L12a1:	jmp	L120d		;; 12a1: c3 0d 12    ...

L12a4:	ret			;; 12a4: c9          .

L12a5:	call	L10b4		;; 12a5: cd b4 10    ...
L12a8:	lhld	cmdptr		;; 12a8: 2a b0 1a    *..
	mov	a,m		;; 12ab: 7e          ~
	cpi	05dh		;; 12ac: fe 5d       .]
	jz	L1301		;; 12ae: ca 01 13    ...
	lhld	cmdptr		;; 12b1: 2a b0 1a    *..
	mov	a,m		;; 12b4: 7e          ~
	cpi	044h		;; 12b5: fe 44       .D
	jnz	L12c2		;; 12b7: c2 c2 12    ...
	lxi	h,L1ab6		;; 12ba: 21 b6 1a    ...
	mvi	m,001h		;; 12bd: 36 01       6.
	jmp	L12fb		;; 12bf: c3 fb 12    ...

L12c2:	lhld	cmdptr		;; 12c2: 2a b0 1a    *..
	mov	a,m		;; 12c5: 7e          ~
	cpi	049h		;; 12c6: fe 49       .I
	jnz	L12d3		;; 12c8: c2 d3 12    ...
	lxi	h,L1ab7		;; 12cb: 21 b7 1a    ...
	mvi	m,001h		;; 12ce: 36 01       6.
	jmp	L12fb		;; 12d0: c3 fb 12    ...

L12d3:	lhld	cmdptr		;; 12d3: 2a b0 1a    *..
	mov	a,m		;; 12d6: 7e          ~
	cpi	'M'		;; 12d7: fe 4d       .M
	jnz	L12e4		;; 12d9: c2 e4 12    ...
	lxi	h,L1ab9		;; 12dc: 21 b9 1a    ...
	mvi	m,1		;; 12df: 36 01       6.
	jmp	L12fb		;; 12e1: c3 fb 12    ...

L12e4:	lhld	cmdptr		;; 12e4: 2a b0 1a    *..
	mov	a,m		;; 12e7: 7e          ~
	cpi	'P'		;; 12e8: fe 50       .P
	jnz	L12f5		;; 12ea: c2 f5 12    ...
	lxi	h,L1aba		;; 12ed: 21 ba 1a    ...
	mvi	m,001h		;; 12f0: 36 01       6.
	jmp	L12fb		;; 12f2: c3 fb 12    ...

L12f5:	lxi	b,L1af8		;; 12f5: 01 f8 1a    ...
	call	exitms		;; 12f8: cd a3 0a    ...
L12fb:	call	L10b4		;; 12fb: cd b4 10    ...
	jmp	L12a8		;; 12fe: c3 a8 12    ...

L1301:	ret			;; 1301: c9          .

L1302:	lxi	h,L1c7f		;; 1302: 21 7f 1c    ...
	mov	m,c		;; 1305: 71          q
	lxi	h,L1abe		;; 1306: 21 be 1a    ...
	mvi	m,0		;; 1309: 36 00       6.
	lxi	h,L1abf		;; 130b: 21 bf 1a    ...
	mvi	m,0		;; 130e: 36 00       6.
	lhld	memtop		;; 1310: 2a 00 1a    *..
	shld	L1a02		;; 1313: 22 02 1a    "..
	call	L10b4		;; 1316: cd b4 10    ...
	lxi	h,relfcb	;; 1319: 21 12 1a    ...
	shld	cmdptr+2	;; 131c: 22 b2 1a    "..
	lxi	b,cmdptr	;; 131f: 01 b0 1a    ...
	call	L1413		;; 1322: cd 13 14    ...
	shld	cmdptr		;; 1325: 22 b0 1a    "..
	xchg			;; 1328: eb          .
	lxi	h,-2		;; 1329: 21 fe ff    ...
	call	subx		;; 132c: cd 6f 19    .o.
	jc	L1338		;; 132f: da 38 13    .8.
	lxi	b,L1af8		;; 1332: 01 f8 1a    ...
	call	exitms		;; 1335: cd a3 0a    ...
L1338:	mvi	a,0		;; 1338: 3e 00       >.
	lxi	d,cmdptr	;; 133a: 11 b0 1a    ...
	call	subxxa		;; 133d: cd 8d 19    ...
	ora	l		;; 1340: b5          .
	jnz	L134a		;; 1341: c2 4a 13    .J.
	lxi	h,L10a2		;; 1344: 21 a2 10    ...
	shld	cmdptr		;; 1347: 22 b0 1a    "..
L134a:	lxi	b,L10b0		;; 134a: 01 b0 10    ...
	call	L10bc		;; 134d: cd bc 10    ...
	rar			;; 1350: 1f          .
	jnc	L138d		;; 1351: d2 8d 13    ...
	lhld	cmdptr		;; 1354: 2a b0 1a    *..
	mov	a,m		;; 1357: 7e          ~
	cpi	'('		;; 1358: fe 28       .(
	jnz	L1363		;; 135a: c2 63 13    .c.
	call	L1186		;; 135d: cd 86 11    ...
	jmp	L1387		;; 1360: c3 87 13    ...

L1363:	lhld	cmdptr		;; 1363: 2a b0 1a    *..
	mov	a,m		;; 1366: 7e          ~
	cpi	'<'		;; 1367: fe 3c       .<
	jnz	L1372		;; 1369: c2 72 13    .r.
	call	L1208		;; 136c: cd 08 12    ...
	jmp	L1387		;; 136f: c3 87 13    ...

L1372:	lhld	cmdptr		;; 1372: 2a b0 1a    *..
	mov	a,m		;; 1375: 7e          ~
	cpi	'['		;; 1376: fe 5b       .[
	jnz	L1381		;; 1378: c2 81 13    ...
	call	L12a5		;; 137b: cd a5 12    ...
	jmp	L1387		;; 137e: c3 87 13    ...

L1381:	lxi	b,L1af8		;; 1381: 01 f8 1a    ...
	call	exitms		;; 1384: cd a3 0a    ...
L1387:	call	L10b4		;; 1387: cd b4 10    ...
	jmp	L134a		;; 138a: c3 4a 13    .J.

L138d:	lhld	cmdptr		;; 138d: 2a b0 1a    *..
	mov	a,m		;; 1390: 7e          ~
	cpi	0		;; 1391: fe 00       ..
	jnz	L139e		;; 1393: c2 9e 13    ...
	lxi	h,L1ace		;; 1396: 21 ce 1a    ...
	mvi	m,1		;; 1399: 36 01       6.
	jmp	L13b9		;; 139b: c3 b9 13    ...

L139e:	lhld	cmdptr		;; 139e: 2a b0 1a    *..
	mov	a,m		;; 13a1: 7e          ~
	sui	'='		;; 13a2: d6 3d       .=
	sui	001h		;; 13a4: d6 01       ..
	sbb	a		;; 13a6: 9f          .
	push	psw		;; 13a7: f5          .
	lda	L1c7f		;; 13a8: 3a 7f 1c    :..
	cma			;; 13ab: 2f          /
	pop	b		;; 13ac: c1          .
	mov	c,b		;; 13ad: 48          H
	ana	c		;; 13ae: a1          .
	rar			;; 13af: 1f          .
	jnc	L13b9		;; 13b0: d2 b9 13    ...
	lxi	b,L1af8		;; 13b3: 01 f8 1a    ...
	call	exitms		;; 13b6: cd a3 0a    ...
L13b9:	ret			;; 13b9: c9          .

L13ba:	lxi	h,L1ace		;; 13ba: 21 ce 1a    ...
	mvi	m,0		;; 13bd: 36 00       6.
	mvi	c,1		;; 13bf: 0e 01       ..
	call	L1302		;; 13c1: cd 02 13    ...
L13c4:	lda	L1ace		;; 13c4: 3a ce 1a    :..
	rar			;; 13c7: 1f          .
	jc	L13d3		;; 13c8: da d3 13    ...
	mvi	c,0		;; 13cb: 0e 00       ..
	call	L1302		;; 13cd: cd 02 13    ...
	jmp	L13c4		;; 13d0: c3 c4 13    ...

L13d3:	ret			;; 13d3: c9          .

delims:	db	cr,' =.:<>_[],()'

; return (L1c80 < ' ' ? '\r' : toupper(L1c80))
touppr:	lxi	h,L1c80		;; 13e1: 21 80 1c    ...
	mov	m,c		;; 13e4: 71          q
	lda	L1c80		;; 13e5: 3a 80 1c    :..
	cpi	' '		;; 13e8: fe 20       . 
	jnc	L13f0		;; 13ea: d2 f0 13    ...
	mvi	a,cr		;; 13ed: 3e 0d       >.
	ret			;; 13ef: c9          .

; return toupper(L1c80)
L13f0:	lda	L1c80		;; 13f0: 3a 80 1c    :..
	sui	'a'		;; 13f3: d6 61       .a
	sbb	a		;; 13f5: 9f          .
	cma			;; 13f6: 2f          /
	push	psw		;; 13f7: f5          .
	mvi	a,'z'		;; 13f8: 3e 7a       >z
	lxi	h,L1c80		;; 13fa: 21 80 1c    ...
	sub	m		;; 13fd: 96          .
	sbb	a		;; 13fe: 9f          .
	cma			;; 13ff: 2f          /
	pop	b		;; 1400: c1          .
	mov	c,b		;; 1401: 48          H
	ana	c		;; 1402: a1          .
	rar			;; 1403: 1f          .
	jnc	L140f		;; 1404: d2 0f 14    ...
	lda	L1c80		;; 1407: 3a 80 1c    :..
	ani	05fh		;; 140a: e6 5f       ._
	sta	L1c80		;; 140c: 32 80 1c    2..
L140f:	lda	L1c80		;; 140f: 3a 80 1c    :..
	ret			;; 1412: c9          .

; parse command, input is (inptr), output (outptr) (filespec)
; BC={inptr,outptr}
; return HL={ 0, -1, &inptr[inidx] }
; -1		= error
; 0		= end
; &inptr[inidx] = more follows
L1413:	lxi	h,L1c81+1		;; 1413: 21 82 1c    ...
	mov	m,b		;; 1416: 70          p
	dcx	h		;; 1417: 2b          +
	mov	m,c		;; 1418: 71          q
	lhld	L1c81		;; 1419: 2a 81 1c    *..
	mov	e,m		;; 141c: 5e          ^
	inx	h		;; 141d: 23          #
	mov	d,m		;; 141e: 56          V
	xchg			;; 141f: eb          .
	shld	inptr		;; 1420: 22 83 1c    "..
	lhld	L1c81		;; 1423: 2a 81 1c    *..
	inx	h		;; 1426: 23          #
	inx	h		;; 1427: 23          #
	mov	e,m		;; 1428: 5e          ^
	inx	h		;; 1429: 23          #
	mov	d,m		;; 142a: 56          V
	xchg			;; 142b: eb          .
	shld	outptr		;; 142c: 22 85 1c    "..
	lxi	h,curchr		;; 142f: 21 87 1c    ...
	mvi	m,' '		;; 1432: 36 20       6 
	lxi	h,outidx		;; 1434: 21 89 1c    ...
	mvi	m,0		;; 1437: 36 00       6.
	dcx	h		;; 1439: 2b          +
	mvi	m,-1	; inidx = -1
	; fill with '           ',0,0,0,0
L143c:	lda	outidx		;; 143c: 3a 89 1c    :..
	cpi	15		;; 143f: fe 0f       ..
	jnc	L1457		;; 1441: d2 57 14    .W.
	lda	outidx		;; 1444: 3a 89 1c    :..
	cpi	11		;; 1447: fe 0b       ..
	jnz	L1451		;; 1449: c2 51 14    .Q.
	lxi	h,curchr	;; 144c: 21 87 1c    ...
	mvi	m,0		;; 144f: 36 00       6.
L1451:	call	putchr		;; 1451: cd 6c 15    .l.
	jmp	L143c		;; 1454: c3 3c 14    .<.

L1457:	lhld	outptr		;; 1457: 2a 85 1c    *..
	mvi	m,0		;; 145a: 36 00       6.
	; skip blanks...
L145c:	call	getchr		;; 145c: cd 2b 15    .+.
L145f:	lda	curchr		;; 145f: 3a 87 1c    :..
	cpi	' '		;; 1462: fe 20       . 
	jnz	L146d		;; 1464: c2 6d 14    .m.
	call	getchr		;; 1467: cd 2b 15    .+.
	jmp	L145f		;; 146a: c3 5f 14    ._.

L146d:	call	isdlim		;; 146d: cd 41 15    .A.
	rar			;; 1470: 1f          .
	jnc	L1478		;; 1471: d2 78 14    .x.
	lxi	h,-1		;; 1474: 21 ff ff    ...
	ret			;; 1477: c9          .

L1478:	lxi	h,outidx		;; 1478: 21 89 1c    ...
	mvi	m,0		;; 147b: 36 00       6.
L147d:	call	isdlim		;; 147d: cd 41 15    .A.
	rar			;; 1480: 1f          .
	jc	L1499		;; 1481: da 99 14    ...
	lda	outidx		;; 1484: 3a 89 1c    :..
	cpi	8		;; 1487: fe 08       ..
	jc	L1490		;; 1489: da 90 14    ...
	lxi	h,-1		;; 148c: 21 ff ff    ...
	ret			;; 148f: c9          .

L1490:	call	putchr		;; 1490: cd 6c 15    .l.
	call	getchr		;; 1493: cd 2b 15    .+.
	jmp	L147d		;; 1496: c3 7d 14    .}.

L1499:	lda	curchr		;; 1499: 3a 87 1c    :..
	cpi	':'		;; 149c: fe 3a       .:
	jnz	L14e4		;; 149e: c2 e4 14    ...
	lhld	outptr		;; 14a1: 2a 85 1c    *..
	mov	a,m		;; 14a4: 7e          ~
	sui	0		;; 14a5: d6 00       ..
	sui	1		;; 14a7: d6 01       ..
	sbb	a		;; 14a9: 9f          .
	push	psw		;; 14aa: f5          .
	lda	outidx		;; 14ab: 3a 89 1c    :..
	sui	1		;; 14ae: d6 01       ..
	sui	1		;; 14b0: d6 01       ..
	sbb	a		;; 14b2: 9f          .
	pop	b		;; 14b3: c1          .
	mov	c,b		;; 14b4: 48          H
	ana	c		;; 14b5: a1          .
	rar			;; 14b6: 1f          .
	jc	L14be		;; 14b7: da be 14    ...
	lxi	h,-1		;; 14ba: 21 ff ff    ...
	ret			;; 14bd: c9          .

L14be:	lhld	outptr		;; 14be: 2a 85 1c    *..
	inx	h		;; 14c1: 23          #
	mov	a,m		;; 14c2: 7e          ~
	sui	'A'		;; 14c3: d6 41       .A
	inr	a		;; 14c5: 3c          <
	lhld	outptr		;; 14c6: 2a 85 1c    *..
	mov	m,a		;; 14c9: 77          w
	mov	c,a		;; 14ca: 4f          O
	mvi	a,'Z'-'A'+1	;; 14cb: 3e 1a       >.
	cmp	c		;; 14cd: b9          .
	jnc	L14d5		;; 14ce: d2 d5 14    ...
	lxi	h,-1		;; 14d1: 21 ff ff    ...
	ret			;; 14d4: c9          .

L14d5:	lhld	outidx		;; 14d5: 2a 89 1c    *..
	mvi	h,0		;; 14d8: 26 00       &.
	xchg			;; 14da: eb          .
	lhld	outptr		;; 14db: 2a 85 1c    *..
	dad	d		;; 14de: 19          .
	mvi	m,' '		;; 14df: 36 20       6 
	jmp	L1527		;; 14e1: c3 27 15    .'.

L14e4:	lxi	h,outidx		;; 14e4: 21 89 1c    ...
	mvi	m,8		;; 14e7: 36 08       6.
	lda	curchr		;; 14e9: 3a 87 1c    :..
	cpi	'.'		;; 14ec: fe 2e       ..
	jnz	L1510		;; 14ee: c2 10 15    ...
	call	getchr		;; 14f1: cd 2b 15    .+.
L14f4:	call	isdlim		;; 14f4: cd 41 15    .A.
	rar			;; 14f7: 1f          .
	jc	L1510		;; 14f8: da 10 15    ...
	lda	outidx		;; 14fb: 3a 89 1c    :..
	cpi	11		;; 14fe: fe 0b       ..
	jc	L1507		;; 1500: da 07 15    ...
	lxi	h,-1		;; 1503: 21 ff ff    ...
	ret			;; 1506: c9          .

L1507:	call	putchr		;; 1507: cd 6c 15    .l.
	call	getchr		;; 150a: cd 2b 15    .+.
	jmp	L14f4		;; 150d: c3 f4 14    ...

L1510:	lda	curchr		;; 1510: 3a 87 1c    :..
	cpi	cr		;; 1513: fe 0d       ..
	jnz	L151c		;; 1515: c2 1c 15    ...
	lxi	h,0		;; 1518: 21 00 00    ...
	ret			;; 151b: c9          .

L151c:	lhld	inidx		;; 151c: 2a 88 1c    *..
	mvi	h,0		;; 151f: 26 00       &.
	xchg			;; 1521: eb          .
	lhld	inptr		;; 1522: 2a 83 1c    *..
	dad	d		;; 1525: 19          .
	ret			;; 1526: c9          .

L1527:	jmp	L145c		;; 1527: c3 5c 14    .\.

	ret			;; 152a: c9          .

; curchr = touppr((*inptr)[++inidx])
getchr:	lda	inidx		;; 152b: 3a 88 1c    :..
	inr	a		;; 152e: 3c          <
	sta	inidx		;; 152f: 32 88 1c    2..
	mov	c,a		;; 1532: 4f          O
	mvi	b,0		;; 1533: 06 00       ..
	lhld	inptr		;; 1535: 2a 83 1c    *..
	dad	b		;; 1538: 09          .
	mov	c,m		;; 1539: 4e          N
	call	touppr		;; 153a: cd e1 13    ...
	sta	curchr		;; 153d: 32 87 1c    2..
	ret			;; 1540: c9          .

isdlim:	lxi	h,L1c8a		;; 1541: 21 8a 1c    ...
	; for 0 to 12...
	; return (index(delims, curchr) >= 0)
	mvi	m,0		;; 1544: 36 00       6.
L1546:	mvi	a,12		;; 1546: 3e 0c       >.
	lxi	h,L1c8a		;; 1548: 21 8a 1c    ...
	cmp	m		;; 154b: be          .
	jc	L1569		;; 154c: da 69 15    .i.
	lhld	L1c8a		;; 154f: 2a 8a 1c    *..
	mvi	h,0		;; 1552: 26 00       &.
	lxi	b,delims		;; 1554: 01 d4 13    ...
	dad	b		;; 1557: 09          .
	lda	curchr		;; 1558: 3a 87 1c    :..
	cmp	m		;; 155b: be          .
	jnz	L1562		;; 155c: c2 62 15    .b.
	mvi	a,1		;; 155f: 3e 01       >.
	ret			;; 1561: c9          .

L1562:	lxi	h,L1c8a		;; 1562: 21 8a 1c    ...
	inr	m		;; 1565: 34          4
	jnz	L1546		;; 1566: c2 46 15    .F.
L1569:	mvi	a,0		;; 1569: 3e 00       >.
	ret			;; 156b: c9          .

; (*outptr)[++outidx] = curchr
putchr:	lda	outidx		;; 156c: 3a 89 1c    :..
	inr	a		;; 156f: 3c          <
	sta	outidx		;; 1570: 32 89 1c    2..
	mov	c,a		;; 1573: 4f          O
	mvi	b,0		;; 1574: 06 00       ..
	lhld	outptr		;; 1576: 2a 85 1c    *..
	dad	b		;; 1579: 09          .
	lda	curchr		;; 157a: 3a 87 1c    :..
	mov	m,a		;; 157d: 77          w
	ret			;; 157e: c9          .

; get C bits from REL or LIB file...
getbts:	lda	libflg		;; 157f: 3a fc 19    :..
	rar			;; 1582: 1f          .
	jc	L15e4		;; 1583: da e4 15    ...
	mvi	b,0		;; 1586: 06 00       ..
L1588:	lxi	h,relbit	;; 1588: 21 98 1a    ...
	inr	m		;; 158b: 34          4
	mov	a,m		;; 158c: 7e          ~
	cpi	1		;; 158d: fe 01       ..
	jz	L15b6		;; 158f: ca b6 15    ...
	cpi	9		;; 1592: fe 09       ..
	jc	L15c2		;; 1594: da c2 15    ...
	mvi	m,1		;; 1597: 36 01       6.
	lhld	relidx		;; 1599: 2a 99 1a    *..
	inx	h		;; 159c: 23          #
	shld	relidx		;; 159d: 22 99 1a    "..
	xchg			;; 15a0: eb          .
	lhld	relsiz		;; 15a1: 2a 96 1a    *..
	mov	a,e		;; 15a4: 7b          {
	sub	l		;; 15a5: 95          .
	mov	a,d		;; 15a6: 7a          z
	sbb	h		;; 15a7: 9c          .
	jc	L15b6		;; 15a8: da b6 15    ...
	lxi	h,0		;; 15ab: 21 00 00    ...
	shld	relidx		;; 15ae: 22 99 1a    "..
	push	b		;; 15b1: c5          .
	call	L05a7		;; 15b2: cd a7 05    ...
	pop	b		;; 15b5: c1          .
L15b6:	lhld	relidx		;; 15b6: 2a 99 1a    *..
	xchg			;; 15b9: eb          .
	lxi	h,relbuf	;; 15ba: 21 92 1f    ...
	dad	d		;; 15bd: 19          .
	mov	a,m		;; 15be: 7e          ~
	sta	relbyt		;; 15bf: 32 8b 1c    2..
L15c2:	mov	a,b		;; 15c2: 78          x
	rlc			;; 15c3: 07          .
	ani	0feh		;; 15c4: e6 fe       ..
	mov	b,a		;; 15c6: 47          G
	lda	relbyt		;; 15c7: 3a 8b 1c    :..
	rlc			;; 15ca: 07          .
	sta	relbyt		;; 15cb: 32 8b 1c    2..
	ani	001h		;; 15ce: e6 01       ..
	ora	b		;; 15d0: b0          .
	mov	b,a		;; 15d1: 47          G
	lda	L1ac3		;; 15d2: 3a c3 1a    :..
	rar			;; 15d5: 1f          .
	jnc	L15de		;; 15d6: d2 de 15    ...
	push	b		;; 15d9: c5          .
	call	L0b70		;; 15da: cd 70 0b    .p.
	pop	b		;; 15dd: c1          .
L15de:	dcr	c		;; 15de: 0d          .
	jnz	L1588		;; 15df: c2 88 15    ...
	mov	a,b		;; 15e2: 78          x
	ret			;; 15e3: c9          .

L15e4:	mvi	b,0		;; 15e4: 06 00       ..
L15e6:	lxi	h,libbit	;; 15e6: 21 9d 1a    ...
	inr	m		;; 15e9: 34          4
	mov	a,m		;; 15ea: 7e          ~
	cpi	9		;; 15eb: fe 09       ..
	jc	L161b		;; 15ed: da 1b 16    ...
	mvi	m,1		;; 15f0: 36 01       6.
	lhld	libidx		;; 15f2: 2a 9e 1a    *..
	inx	h		;; 15f5: 23          #
	shld	libidx		;; 15f6: 22 9e 1a    "..
	xchg			;; 15f9: eb          .
	lhld	libsiz		;; 15fa: 2a 9b 1a    *..
	mov	a,e		;; 15fd: 7b          {
	sub	l		;; 15fe: 95          .
	mov	a,d		;; 15ff: 7a          z
	sbb	h		;; 1600: 9c          .
	jc	L160f		;; 1601: da 0f 16    ...
	lxi	h,0		;; 1604: 21 00 00    ...
	shld	libidx		;; 1607: 22 9e 1a    "..
	push	b		;; 160a: c5          .
	call	L05d6		;; 160b: cd d6 05    ...
	pop	b		;; 160e: c1          .
L160f:	lhld	libidx		;; 160f: 2a 9e 1a    *..
	xchg			;; 1612: eb          .
	lxi	h,libbuf	;; 1613: 21 92 1d    ...
	dad	d		;; 1616: 19          .
	mov	a,m		;; 1617: 7e          ~
	sta	libbyt		;; 1618: 32 8c 1c    2..
L161b:	mov	a,b		;; 161b: 78          x
	rlc			;; 161c: 07          .
	ani	0feh		;; 161d: e6 fe       ..
	mov	b,a		;; 161f: 47          G
	lda	libbyt		;; 1620: 3a 8c 1c    :..
	rlc			;; 1623: 07          .
	sta	libbyt		;; 1624: 32 8c 1c    2..
	ani	001h		;; 1627: e6 01       ..
	ora	b		;; 1629: b0          .
	mov	b,a		;; 162a: 47          G
	dcr	c		;; 162b: 0d          .
	jnz	L15e6		;; 162c: c2 e6 15    ...
	mov	a,b		;; 162f: 78          x
	ret			;; 1630: c9          .

; compare bytes at (BC) to (TOS), length E
compar:	mov	a,e		;; 1631: 7b          {
	pop	h		;; 1632: e1          .
	xthl			;; 1633: e3          .
	mov	e,a		;; 1634: 5f          _
L1635:	ldax	b		;; 1635: 0a          .
	cmp	m		;; 1636: be          .
	jnz	L1643		;; 1637: c2 43 16    .C.
	inx	b		;; 163a: 03          .
	inx	h		;; 163b: 23          #
	dcr	e		;; 163c: 1d          .
	jnz	L1635		;; 163d: c2 35 16    .5.
	mvi	a,001h		;; 1640: 3e 01       >.
	ret			;; 1642: c9          .

L1643:	xra	a		;; 1643: af          .
	ret			;; 1644: c9          .

nulmsg:	db	'$'

; print filename. skip blanks and insert '.'
fprint:	lxi	h,L1cde+1	;; 1646: 21 df 1c    ...
	mov	m,b		;; 1649: 70          p
	dcx	h		;; 164a: 2b          +
	mov	m,c		;; 164b: 71          q
	lxi	h,L1ce0		;; 164c: 21 e0 1c    ...
	; for 1 to 11...
	mvi	m,1		;; 164f: 36 01       6.
L1651:	mvi	a,11		;; 1651: 3e 0b       >.
	lxi	h,L1ce0		;; 1653: 21 e0 1c    ...
	cmp	m		;; 1656: be          .
	jc	L168c		;; 1657: da 8c 16    ...
	lhld	L1ce0		;; 165a: 2a e0 1c    *..
	mvi	h,0		;; 165d: 26 00       &.
	xchg			;; 165f: eb          .
	lhld	L1cde		;; 1660: 2a de 1c    *..
	dad	d		;; 1663: 19          .
	mov	a,m		;; 1664: 7e          ~
	cpi	' '		;; 1665: fe 20       . 
	jz	L1678		;; 1667: ca 78 16    .x.
	lhld	L1ce0		;; 166a: 2a e0 1c    *..
	mvi	h,0		;; 166d: 26 00       &.
	xchg			;; 166f: eb          .
	lhld	L1cde		;; 1670: 2a de 1c    *..
	dad	d		;; 1673: 19          .
	mov	c,m		;; 1674: 4e          N
	call	chrout		;; 1675: cd 2c 18    .,.
L1678:	lda	L1ce0		;; 1678: 3a e0 1c    :..
	cpi	8		;; 167b: fe 08       ..
	jnz	L1685		;; 167d: c2 85 16    ...
	mvi	c,'.'		;; 1680: 0e 2e       ..
	call	chrout		;; 1682: cd 2c 18    .,.
L1685:	lxi	h,L1ce0		;; 1685: 21 e0 1c    ...
	inr	m		;; 1688: 34          4
	jnz	L1651		;; 1689: c2 51 16    .Q.
L168c:	ret			;; 168c: c9          .

; print error message then filename, fatal error (exit)
errfil:	lxi	h,L1ce3+1	;; 168d: 21 e4 1c    ...
	mov	m,d		;; 1690: 72          r
	dcx	h		;; 1691: 2b          +
	mov	m,e		;; 1692: 73          s
	dcx	h		;; 1693: 2b          +
	mov	m,b		;; 1694: 70          p
	dcx	h		;; 1695: 2b          +
	mov	m,c		;; 1696: 71          q
	lhld	L1ce1		;; 1697: 2a e1 1c    *..
	mov	b,h		;; 169a: 44          D
	mov	c,l		;; 169b: 4d          M
	call	msgout		;; 169c: cd 47 18    .G.
	lhld	L1ce3		;; 169f: 2a e3 1c    *..
	mov	b,h		;; 16a2: 44          D
	mov	c,l		;; 16a3: 4d          M
	call	fprint		;; 16a4: cd 46 16    .F.
	lxi	b,nulmsg	;; 16a7: 01 45 16    .E.
	call	exitms		;; 16aa: cd a3 0a    ...
	ret			;; 16ad: c9          .

; read or write a file E=read(0)/write(1)
; E=write flag, BC=fcb, (S1)=byte count? (S2)=buffer
; allow abort (console input).
rwfile:	lxi	h,rwflag	;; 16ae: 21 eb 1c    ...
	mov	m,e		;; 16b1: 73          s
	dcx	h		;; 16b2: 2b          +
	mov	m,b		;; 16b3: 70          p
	dcx	h		;; 16b4: 2b          +
	mov	m,c		;; 16b5: 71          q
	dcx	h		;; 16b6: 2b          +
	pop	d		;; 16b7: d1          .
	pop	b		;; 16b8: c1          .
	mov	m,b		;; 16b9: 70          p
	dcx	h		;; 16ba: 2b          +
	mov	m,c		;; 16bb: 71          q
	dcx	h		;; 16bc: 2b          +
	pop	b		;; 16bd: c1          .
	mov	m,b		;; 16be: 70          p
	dcx	h		;; 16bf: 2b          +
	mov	m,c		;; 16c0: 71          q
	push	d		;; 16c1: d5          .
	call	chrst		;; 16c2: cd 57 18    .W.
	rar			;; 16c5: 1f          .
	jnc	L16cf		;; 16c6: d2 cf 16    ...
	lxi	b,L1c8d		;; 16c9: 01 8d 1c    ...
	call	exitms		;; 16cc: cd a3 0a    ...
L16cf:	lxi	h,0		;; 16cf: 21 00 00    ...
	shld	reccnt		;; 16d2: 22 dc 1c    "..
L16d5:	mvi	a,128		;; 16d5: 3e 80       >.
	lxi	d,rwbyts	;; 16d7: 11 e7 1c    ...
	call	subxxa		;; 16da: cd 8d 19    ...
	xchg			;; 16dd: eb          .
	dcx	h		;; 16de: 2b          +
	mov	m,e		;; 16df: 73          s
	inx	h		;; 16e0: 23          #
	mov	m,d		;; 16e1: 72          r
	lxi	h,-128		;; 16e2: 21 80 ff    ...
	call	subx		;; 16e5: cd 6f 19    .o.
	ora	l		;; 16e8: b5          .
	jz	resdma		;; 16e9: ca 4d 17    .M.
	lhld	rwdma		;; 16ec: 2a e5 1c    *..
	mov	b,h		;; 16ef: 44          D
	mov	c,l		;; 16f0: 4d          M
	call	fstdma		;; 16f1: cd 60 18    .`.
	lda	rwflag		;; 16f4: 3a eb 1c    :..
	cpi	0		;; 16f7: fe 00       ..
	jnz	fwrrec		;; 16f9: c2 24 17    .$.
	; file read branch...
	lhld	rwfcb		;; 16fc: 2a e9 1c    *..
	mov	b,h		;; 16ff: 44          D
	mov	c,l		;; 1700: 4d          M
	call	fread		;; 1701: cd 90 18    ...
	mov	c,a		;; 1704: 4f          O
	mvi	a,0		;; 1705: 3e 00       >.
	cmp	c		;; 1707: b9          .
	jnc	L1721		;; 1708: d2 21 17    ...
	mvi	a,0		;; 170b: 3e 00       >.
	lxi	d,reccnt	;; 170d: 11 dc 1c    ...
	call	subxxa		;; 1710: cd 8d 19    ...
	ora	l		;; 1713: b5          .
	jnz	L1720		;; 1714: c2 20 17    . .
	lxi	b,L1c95		;; 1717: 01 95 1c    ...
	call	exitms		;; 171a: cd a3 0a    ...
	jmp	L1721		;; 171d: c3 21 17    ...

L1720:	ret			;; 1720: c9          .

L1721:	jmp	L1739		;; 1721: c3 39 17    .9.

; write one record, update pointers/counters
fwrrec:	lhld	rwfcb		;; 1724: 2a e9 1c    *..
	mov	b,h		;; 1727: 44          D
	mov	c,l		;; 1728: 4d          M
	call	fwrite		;; 1729: cd a0 18    ...
	mov	c,a		;; 172c: 4f          O
	mvi	a,0		;; 172d: 3e 00       >.
	cmp	c		;; 172f: b9          .
	jnc	L1739		;; 1730: d2 39 17    .9.
	lxi	b,L1ca5		;; 1733: 01 a5 1c    ...
	call	exitms		;; 1736: cd a3 0a    ...
L1739:	lxi	d,128		;; 1739: 11 80 00    ...
	lhld	rwdma		;; 173c: 2a e5 1c    *..
	dad	d		;; 173f: 19          .
	shld	rwdma		;; 1740: 22 e5 1c    "..
	lhld	reccnt		;; 1743: 2a dc 1c    *..
	inx	h		;; 1746: 23          #
	shld	reccnt		;; 1747: 22 dc 1c    "..
	jmp	L16d5		;; 174a: c3 d5 16    ...

resdma:	lxi	b,defdma	;; 174d: 01 80 00    ...
	call	fstdma		;; 1750: cd 60 18    .`.
	ret			;; 1753: c9          .

rdfile:	lxi	h,rdfcb+1	;; 1754: 21 f1 1c    ...
	mov	m,d		;; 1757: 72          r
	dcx	h		;; 1758: 2b          +
	mov	m,e		;; 1759: 73          s
	dcx	h		;; 175a: 2b          +
	mov	m,b		;; 175b: 70          p
	dcx	h		;; 175c: 2b          +
	mov	m,c		;; 175d: 71          q
	dcx	h		;; 175e: 2b          +
	pop	d		;; 175f: d1          .
	pop	b		;; 1760: c1          .
	mov	m,b		;; 1761: 70          p
	dcx	h		;; 1762: 2b          +
	mov	m,c		;; 1763: 71          q
	push	d		;; 1764: d5          .
	lhld	rddma		;; 1765: 2a ec 1c    *..
	push	h		;; 1768: e5          .
	lhld	rdbyts		;; 1769: 2a ee 1c    *..
	push	h		;; 176c: e5          .
	lhld	rdfcb		;; 176d: 2a f0 1c    *..
	mov	b,h		;; 1770: 44          D
	mov	c,l		;; 1771: 4d          M
	mvi	e,0		;; 1772: 1e 00       ..
	call	rwfile		;; 1774: cd ae 16    ...
	lhld	reccnt		;; 1777: 2a dc 1c    *..
	ret			;; 177a: c9          .

wrfile:	lxi	h,wrfcb+1	;; 177b: 21 f7 1c    ...
	mov	m,d		;; 177e: 72          r
	dcx	h		;; 177f: 2b          +
	mov	m,e		;; 1780: 73          s
	dcx	h		;; 1781: 2b          +
	mov	m,b		;; 1782: 70          p
	dcx	h		;; 1783: 2b          +
	mov	m,c		;; 1784: 71          q
	dcx	h		;; 1785: 2b          +
	pop	d		;; 1786: d1          .
	pop	b		;; 1787: c1          .
	mov	m,b		;; 1788: 70          p
	dcx	h		;; 1789: 2b          +
	mov	m,c		;; 178a: 71          q
	push	d		;; 178b: d5          .
	lhld	wrdma		;; 178c: 2a f2 1c    *..
	push	h		;; 178f: e5          .
	lhld	wrbyts		;; 1790: 2a f4 1c    *..
	push	h		;; 1793: e5          .
	lhld	wrfcb		;; 1794: 2a f6 1c    *..
	mov	b,h		;; 1797: 44          D
	mov	c,l		;; 1798: 4d          M
	mvi	e,1		;; 1799: 1e 01       ..
	call	rwfile		;; 179b: cd ae 16    ...
	ret			;; 179e: c9          .

fnew:	lxi	h,L1cf8+1	;; 179f: 21 f9 1c    ...
	mov	m,b		;; 17a2: 70          p
	dcx	h		;; 17a3: 2b          +
	mov	m,c		;; 17a4: 71          q
	lhld	L1cf8		;; 17a5: 2a f8 1c    *..
	mov	b,h		;; 17a8: 44          D
	mov	c,l		;; 17a9: 4d          M
	call	fdelet		;; 17aa: cd 70 18    .p.
	lxi	h,L1cfa		;; 17ad: 21 fa 1c    ...
	; fill fcb[12..31] with 0...
	mvi	m,12		;; 17b0: 36 0c       6.
L17b2:	mvi	a,32		;; 17b2: 3e 20       > 
	lxi	h,L1cfa		;; 17b4: 21 fa 1c    ...
	cmp	m		;; 17b7: be          .
	jc	L17ce		;; 17b8: da ce 17    ...
	lhld	L1cfa		;; 17bb: 2a fa 1c    *..
	mvi	h,0		;; 17be: 26 00       &.
	xchg			;; 17c0: eb          .
	lhld	L1cf8		;; 17c1: 2a f8 1c    *..
	dad	d		;; 17c4: 19          .
	mvi	m,0		;; 17c5: 36 00       6.
	lxi	h,L1cfa		;; 17c7: 21 fa 1c    ...
	inr	m		;; 17ca: 34          4
	jnz	L17b2		;; 17cb: c2 b2 17    ...
L17ce:	lhld	L1cf8		;; 17ce: 2a f8 1c    *..
	mov	b,h		;; 17d1: 44          D
	mov	c,l		;; 17d2: 4d          M
	call	fmake		;; 17d3: cd b0 18    ...
	cpi	0ffh		;; 17d6: fe ff       ..
	jnz	L17e1		;; 17d8: c2 e1 17    ...
	lxi	b,L1cc3		;; 17db: 01 c3 1c    ...
	call	exitms		;; 17de: cd a3 0a    ...
L17e1:	ret			;; 17e1: c9          .

fstart:	lxi	h,L1cfb+1	;; 17e2: 21 fc 1c    ...
	mov	m,b		;; 17e5: 70          p
	dcx	h		;; 17e6: 2b          +
	mov	m,c		;; 17e7: 71          q
	lxi	b,12		;; 17e8: 01 0c 00    ...
	lhld	L1cfb		;; 17eb: 2a fb 1c    *..
	dad	b		;; 17ee: 09          .
	mvi	m,0		;; 17ef: 36 00       6.
	lxi	b,32		;; 17f1: 01 20 00    . .
	lhld	L1cfb		;; 17f4: 2a fb 1c    *..
	dad	b		;; 17f7: 09          .
	mvi	m,0		;; 17f8: 36 00       6.
	lhld	L1cfb		;; 17fa: 2a fb 1c    *..
	mov	b,h		;; 17fd: 44          D
	mov	c,l		;; 17fe: 4d          M
	call	fopen		;; 17ff: cd 80 18    ...
	cpi	0ffh		;; 1802: fe ff       ..
	jnz	L1811		;; 1804: c2 11 18    ...
	lhld	L1cfb		;; 1807: 2a fb 1c    *..
	xchg			;; 180a: eb          .
	lxi	b,L1cd2		;; 180b: 01 d2 1c    ...
	call	errfil		;; 180e: cd 8d 16    ...
L1811:	ret			;; 1811: c9          .

fdone:	lxi	h,L1cfd+1	;; 1812: 21 fe 1c    ...
	mov	m,b		;; 1815: 70          p
	dcx	h		;; 1816: 2b          +
	mov	m,c		;; 1817: 71          q
	lhld	L1cfd		;; 1818: 2a fd 1c    *..
	mov	b,h		;; 181b: 44          D
	mov	c,l		;; 181c: 4d          M
	call	fclose		;; 181d: cd c0 18    ...
	cpi	0ffh		;; 1820: fe ff       ..
	jnz	L182b		;; 1822: c2 2b 18    .+.
	lxi	b,L1cb6		;; 1825: 01 b6 1c    ...
	call	exitms		;; 1828: cd a3 0a    ...
L182b:	ret			;; 182b: c9          .

chrout:	lxi	h,L1cff		;; 182c: 21 ff 1c    ...
	mov	m,c		;; 182f: 71          q
	lhld	L1cff		;; 1830: 2a ff 1c    *..
	mvi	h,0		;; 1833: 26 00       &.
	xchg			;; 1835: eb          .
	mvi	c,conout	;; 1836: 0e 02       ..
	call	bdosa		;; 1838: cd e6 18    ...
	ret			;; 183b: c9          .

crlf:	mvi	c,cr		;; 183c: 0e 0d       ..
	call	chrout		;; 183e: cd 2c 18    .,.
	mvi	c,lf		;; 1841: 0e 0a       ..
	call	chrout		;; 1843: cd 2c 18    .,.
	ret			;; 1846: c9          .

msgout:	lxi	h,L1d00+1		;; 1847: 21 01 1d    ...
	mov	m,b		;; 184a: 70          p
	dcx	h		;; 184b: 2b          +
	mov	m,c		;; 184c: 71          q
	lhld	L1d00		;; 184d: 2a 00 1d    *..
	xchg			;; 1850: eb          .
	mvi	c,print		;; 1851: 0e 09       ..
	call	bdosa		;; 1853: cd e6 18    ...
	ret			;; 1856: c9          .

chrst:	lxi	d,0		;; 1857: 11 00 00    ...
	mvi	c,const		;; 185a: 0e 0b       ..
	call	bdosb		;; 185c: cd e9 18    ...
	ret			;; 185f: c9          .

fstdma:	lxi	h,L1d02+1	;; 1860: 21 03 1d    ...
	mov	m,b		;; 1863: 70          p
	dcx	h		;; 1864: 2b          +
	mov	m,c		;; 1865: 71          q
	lhld	L1d02		;; 1866: 2a 02 1d    *..
	xchg			;; 1869: eb          .
	mvi	c,setdma	;; 186a: 0e 1a       ..
	call	bdosa		;; 186c: cd e6 18    ...
	ret			;; 186f: c9          .

fdelet:	lxi	h,L1d04+1	;; 1870: 21 05 1d    ...
	mov	m,b		;; 1873: 70          p
	dcx	h		;; 1874: 2b          +
	mov	m,c		;; 1875: 71          q
	lhld	L1d04		;; 1876: 2a 04 1d    *..
	xchg			;; 1879: eb          .
	mvi	c,delete	;; 187a: 0e 13       ..
	call	bdosb		;; 187c: cd e9 18    ...
	ret			;; 187f: c9          .

fopen:	lxi	h,L1d06+1	;; 1880: 21 07 1d    ...
	mov	m,b		;; 1883: 70          p
	dcx	h		;; 1884: 2b          +
	mov	m,c		;; 1885: 71          q
	lhld	L1d06		;; 1886: 2a 06 1d    *..
	xchg			;; 1889: eb          .
	mvi	c,open		;; 188a: 0e 0f       ..
	call	bdosb		;; 188c: cd e9 18    ...
	ret			;; 188f: c9          .

fread:	lxi	h,L1d08+1	;; 1890: 21 09 1d    ...
	mov	m,b		;; 1893: 70          p
	dcx	h		;; 1894: 2b          +
	mov	m,c		;; 1895: 71          q
	lhld	L1d08		;; 1896: 2a 08 1d    *..
	xchg			;; 1899: eb          .
	mvi	c,read		;; 189a: 0e 14       ..
	call	bdosb		;; 189c: cd e9 18    ...
	ret			;; 189f: c9          .

fwrite:	lxi	h,L1d0a+1	;; 18a0: 21 0b 1d    ...
	mov	m,b		;; 18a3: 70          p
	dcx	h		;; 18a4: 2b          +
	mov	m,c		;; 18a5: 71          q
	lhld	L1d0a		;; 18a6: 2a 0a 1d    *..
	xchg			;; 18a9: eb          .
	mvi	c,write		;; 18aa: 0e 15       ..
	call	bdosb		;; 18ac: cd e9 18    ...
	ret			;; 18af: c9          .

fmake:	lxi	h,L1d0c+1	;; 18b0: 21 0d 1d    ...
	mov	m,b		;; 18b3: 70          p
	dcx	h		;; 18b4: 2b          +
	mov	m,c		;; 18b5: 71          q
	lhld	L1d0c		;; 18b6: 2a 0c 1d    *..
	xchg			;; 18b9: eb          .
	mvi	c,make		;; 18ba: 0e 16       ..
	call	bdosb		;; 18bc: cd e9 18    ...
	ret			;; 18bf: c9          .

; BC=fcb
fclose:	lxi	h,L1d0e+1	;; 18c0: 21 0f 1d    ...
	mov	m,b		;; 18c3: 70          p
	dcx	h		;; 18c4: 2b          +
	mov	m,c		;; 18c5: 71          q
	lxi	b,defdma	;; 18c6: 01 80 00    ...
	call	fstdma		;; 18c9: cd 60 18    .`.
	lhld	L1d0e		;; 18cc: 2a 0e 1d    *..
	xchg			;; 18cf: eb          .
	mvi	c,close		;; 18d0: 0e 10       ..
	call	bdosb		;; 18d2: cd e9 18    ...
	ret			;; 18d5: c9          .

; BC=fcb
frenam:	lxi	h,L1d10+1	;; 18d6: 21 11 1d    ...
	mov	m,b		;; 18d9: 70          p
	dcx	h		;; 18da: 2b          +
	mov	m,c		;; 18db: 71          q
	lhld	L1d10		;; 18dc: 2a 10 1d    *..
	xchg			;; 18df: eb          .
	mvi	c,rename	;; 18e0: 0e 17       ..
	call	bdosb		;; 18e2: cd e9 18    ...
	ret			;; 18e5: c9          .

bdosa:	jmp	bdos		;; 18e6: c3 05 00    ...

bdosb:	jmp	bdos		;; 18e9: c3 05 00    ...

	jmp	bdos		;; 18ec: c3 05 00    ...

; HL &= A
	mov	e,a		;; 18ef: 5f          _
	mvi	d,0		;; 18f0: 16 00       ..
; HL &= DE
andx:	mov	a,e		;; 18f2: 7b          {
	ana	l		;; 18f3: a5          .
	mov	l,a		;; 18f4: 6f          o
	mov	a,d		;; 18f5: 7a          z
	ana	h		;; 18f6: a4          .
	mov	h,a		;; 18f7: 67          g
	ret			;; 18f8: c9          .

; HL = A & *(DE)
andyya:	xchg			;; 18f9: eb          .
; HL = A & *(HL)
andxxa:	mov	e,a		;; 18fa: 5f          _
	mvi	d,0		;; 18fb: 16 00       ..
	xchg			;; 18fd: eb          .
	ldax	d		;; 18fe: 1a          .
	ana	l		;; 18ff: a5          .
	mov	l,a		;; 1900: 6f          o
	inx	d		;; 1901: 13          .
	ldax	d		;; 1902: 1a          .
	ana	h		;; 1903: a4          .
	mov	h,a		;; 1904: 67          g
	ret			;; 1905: c9          .

; divide by HL?
divhl:	mov	b,h		;; 1906: 44          D
	mov	c,l		;; 1907: 4d          M
; divide by BC?
divbc:	lxi	h,0		;; 1908: 21 00 00    ...
	mvi	a,16		;; 190b: 3e 10       >.
L190d:	push	psw		;; 190d: f5          .
	dad	h		;; 190e: 29          )
	xchg			;; 190f: eb          .
	sub	a		;; 1910: 97          .
	dad	h		;; 1911: 29          )
	xchg			;; 1912: eb          .
	adc	l		;; 1913: 8d          .
	sub	c		;; 1914: 91          .
	mov	l,a		;; 1915: 6f          o
	mov	a,h		;; 1916: 7c          |
	sbb	b		;; 1917: 98          .
	mov	h,a		;; 1918: 67          g
	inx	d		;; 1919: 13          .
	jnc	L191f		;; 191a: d2 1f 19    ...
	dad	b		;; 191d: 09          .
	dcx	d		;; 191e: 1b          .
L191f:	pop	psw		;; 191f: f1          .
	dcr	a		;; 1920: 3d          =
	jnz	L190d		;; 1921: c2 0d 19    ...
	ret			;; 1924: c9          .

; multiply?
mult:	mov	b,h		;; 1925: 44          D
	mov	c,l		;; 1926: 4d          M
	lxi	h,0		;; 1927: 21 00 00    ...
	mvi	a,16		;; 192a: 3e 10       >.
L192c:	dad	h		;; 192c: 29          )
	xchg			;; 192d: eb          .
	dad	h		;; 192e: 29          )
	xchg			;; 192f: eb          .
	jnc	L1934		;; 1930: d2 34 19    .4.
	dad	b		;; 1933: 09          .
L1934:	dcr	a		;; 1934: 3d          =
	jnz	L192c		;; 1935: c2 2c 19    .,.
	ret			;; 1938: c9          .

; HL |= A
orxa:	mov	e,a		;; 1939: 5f          _
	mvi	d,0		;; 193a: 16 00       ..
; HL |= DE
orx:	mov	a,e		;; 193c: 7b          {
	ora	l		;; 193d: b5          .
	mov	l,a		;; 193e: 6f          o
	mov	a,d		;; 193f: 7a          z
	ora	h		;; 1940: b4          .
	mov	h,a		;; 1941: 67          g
	ret			;; 1942: c9          .

; A = *(HL) << C
shlm:	mov	a,m		;; 1943: 7e          ~
L1944:	add	a		;; 1944: 87          .
	dcr	c		;; 1945: 0d          .
	jnz	L1944		;; 1946: c2 44 19    .D.
	ret			;; 1949: c9          .

; HL = *(HL) << C
shlxx:	mov	e,m		;; 194a: 5e          ^
	inx	h		;; 194b: 23          #
	mov	d,m		;; 194c: 56          V
	xchg			;; 194d: eb          .
; HL <<= C
shlx:	dad	h		;; 194e: 29          )
	dcr	c		;; 194f: 0d          .
	jnz	shlx		;; 1950: c2 4e 19    .N.
	ret			;; 1953: c9          .

; A = *(HL) >> C
shrm:	mov	a,m		;; 1954: 7e          ~
L1955:	ora	a		;; 1955: b7          .
	rar			;; 1956: 1f          .
	dcr	c		;; 1957: 0d          .
	jnz	L1955		;; 1958: c2 55 19    .U.
	ret			;; 195b: c9          .

; HL = *(HL) >> C
shrxx:	mov	e,m		;; 195c: 5e          ^
	inx	h		;; 195d: 23          #
	mov	d,m		;; 195e: 56          V
	xchg			;; 195f: eb          .
; HL >>= C
shrx:	mov	a,h		;; 1960: 7c          |
	ora	a		;; 1961: b7          .
	rar			;; 1962: 1f          .
	mov	h,a		;; 1963: 67          g
	mov	a,l		;; 1964: 7d          }
	rar			;; 1965: 1f          .
	mov	l,a		;; 1966: 6f          o
	dcr	c		;; 1967: 0d          .
	jnz	shrx		;; 1968: c2 60 19    .`.
	ret			;; 196b: c9          .

; HL = A - HL
subax:	mov	e,a		;; 196c: 5f          _
	mvi	d,0		;; 196d: 16 00       ..
; HL = DE - HL
subx:	mov	a,e		;; 196f: 7b          {
	sub	l		;; 1970: 95          .
	mov	l,a		;; 1971: 6f          o
	mov	a,d		;; 1972: 7a          z
	sbb	h		;; 1973: 9c          .
	mov	h,a		;; 1974: 67          g
	ret			;; 1975: c9          .

; HL = DE - A
subxa:	mov	c,a		;; 1976: 4f          O
	mvi	b,0		;; 1977: 06 00       ..
	mov	a,e		;; 1979: 7b          {
	sub	c		;; 197a: 91          .
	mov	l,a		;; 197b: 6f          o
	mov	a,d		;; 197c: 7a          z
	sbb	b		;; 197d: 98          .
	mov	h,a		;; 197e: 67          g
	ret			;; 197f: c9          .

; HL = *(DE) - *(BC)
L1980:	mov	l,c		;; 1980: 69          i
	mov	h,b		;; 1981: 60          `
	mov	c,m		;; 1982: 4e          N
	inx	h		;; 1983: 23          #
	mov	b,m		;; 1984: 46          F
; HL = *(DE) - BC
L1985:	ldax	d		;; 1985: 1a          .
	sub	c		;; 1986: 91          .
	mov	l,a		;; 1987: 6f          o
	inx	d		;; 1988: 13          .
	ldax	d		;; 1989: 1a          .
	sbb	b		;; 198a: 98          .
	mov	h,a		;; 198b: 67          g
	ret			;; 198c: c9          .

; HL = *(DE) - A
subxxa:	mov	l,a		;; 198d: 6f          o
	mvi	h,0		;; 198e: 26 00       &.
	ldax	d		;; 1990: 1a          .
	sub	l		;; 1991: 95          .
	mov	l,a		;; 1992: 6f          o
	inx	d		;; 1993: 13          .
	ldax	d		;; 1994: 1a          .
	sbb	h		;; 1995: 9c          .
	mov	h,a		;; 1996: 67          g
	ret			;; 1997: c9          .

; HL = A - *(DE)
L1998:	mov	e,a		;; 1998: 5f          _
	mvi	d,0		;; 1999: 16 00       ..
; HL = DE - *(HL)
L199b:	mov	a,e		;; 199b: 7b          {
	sub	m		;; 199c: 96          .
	mov	e,a		;; 199d: 5f          _
	mov	a,d		;; 199e: 7a          z
	inx	h		;; 199f: 23          #
	sbb	m		;; 19a0: 9e          .
	mov	d,a		;; 19a1: 57          W
	xchg			;; 19a2: eb          .
	ret			;; 19a3: c9          .

	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
stack:	ds	0

L19f0:	db	'LIB 1.1',0dh,0ah,'$'
L19fa:	db	0
L19fb:	db	0
libflg:	db	0	; 0 for REL file, 1 for LIB file
L19fd:	db	0
tmpptr:	db	0,0
memtop:	db	0,0
L1a02:	db	0,0
L1a04:	db	0ffh,0ffh

L1a06:	db	0,0,0,0,0,0,0,0,0,0,0,0

relfcb:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0

libfcb:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0

reltmp:	db	0,'REL     $$$',0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0

irltmp:	db	0,'IRL     $$$',0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0

relsiz:	dw	1024	; size of relbuf
relbit:	db	0
relidx:	db	0,0

libsiz:	dw	512	; size of libbuf
libbit:	db	0
libidx:	db	0,0

L1aa0:	db	0,0
L1aa2:	db	0,0
L1aa4:	db	0
L1aa5:	db	0
L1aa6:	db	0,0
L1aa8:	db	0,4
L1aaa:	db	0,0
L1aac:	db	0,0
L1aae:	db	0,0
; parameters for L1413
cmdptr:	db	0,0	; input string pointer
	db	0,0	; output (filespec, FCB) pointer

L1ab4:	db	0,0
L1ab6:	db	0
L1ab7:	db	0
L1ab8:	db	0
L1ab9:	db	0
L1aba:	db	0
L1abb:	db	0
L1abc:	db	0
L1abd:	db	0
L1abe:	db	0
L1abf:	db	0
L1ac0:	db	0
L1ac1:	db	0,0
L1ac3:	db	0
L1ac4:	db	0
L1ac5:	db	0
L1ac6:	db	0
L1ac7:	db	0
L1ac8:	db	0
L1ac9:	db	0
L1aca:	db	0
L1acb:	db	0
L1acc:	db	0,0
L1ace:	db	0
L1acf:	db	0
L1ad0:	db	0
L1ad1:	db	0,0,0,0,0,0,0
L1ad8:	db	0
L1ad9:	db	0,0,0,0,0,0,0
L1ae0:	db	'INDEX ERROR$'
L1aec:	db	'NO MODULE: $'
L1af8:	db	'SYNTAX ERROR$',0,0,0
L1b08:	db	0,0
L1b0a:	db	0
L1b0b:	db	0,0
L1b0d:	db	0
L1b0e:	db	0
L1b0f:	db	0
L1b10:	db	0
L1b11:	db	0
L1b12:	db	0
L1b13:	db	0,0
L1b15:	db	0
L1b16:	db	0
L1b17:	db	0
L1b18:	db	0,0
L1b1a:	db	0
L1b1b:	db	0
L1b1c:	db	0
L1b1d:	db	0
L1b1e:	db	0
L1b1f:	db	0,0
L1b21:	db	0

L1b22:	db	0,0
	db	0,0

L1b26:	db	0
L1b27:	db	0
L1b28:	db	0
L1b29:	db	0,0
L1b2b:	db	0,0
L1b2d:	db	0,0
L1b2f:	db	0,0
L1b31:	db	0,0
L1b33:	db	1
L1b34:	db	'APDC'
L1b38:	db	0
L1b39:	db	0,0
L1b3b:	db	0
L1b3c:	db	0,0,0,0,0,0,0
L1b43:	db	0
L1b44:	db	0,0
L1b46:	db	'entry symbol $'
L1b54:	db	'select common block $'
L1b69:	db	'program name $'
L1b77:	db	'request $'
L1b80:	db	'error 4 $'
L1b89:	db	'define common size $'
L1b9d:	db	'chain external $'
L1bad:	db	'define entry point $'
L1bc1:	db	'error 8 $'
L1bca:	db	'external + offset $'
L1bdd:	db	'define data size $'
L1bef:	db	'set program counter $'
L1c04:	db	'chain address $'
L1c13:	db	'define program size $'
L1c28:	db	'end program $'
L1c35:	db	'end file$'
L1c3e:	dw	L1b46
	dw	L1b54
	dw	L1b69
	dw	L1b77
	dw	L1b80
	dw	L1b89
	dw	L1b9d
	dw	L1bad
	dw	L1bc1
	dw	L1bca
	dw	L1bdd
	dw	L1bef
	dw	L1c04
	dw	L1c13
	dw	L1c28
	dw	L1c35
L1c5e:	db	0
L1c5f:	db	0
L1c60:	db	0
L1c61:	db	0
L1c62:	db	0
L1c63:	db	0
L1c64:	db	0
L1c65:	db	0
L1c66:	db	0
L1c67:	db	0
L1c68:	db	0
L1c69:	db	0
L1c6a:	db	0
L1c6b:	db	0
L1c6c:	db	0
L1c6d:	db	0
L1c6e:	db	0
L1c6f:	db	0
L1c70:	db	0
L1c71:	db	0
L1c72:	db	0
L1c73:	db	0
L1c74:	db	0
L1c75:	db	0
L1c76:	db	0
L1c77:	db	0,0
L1c79:	db	0
L1c7a:	db	0
L1c7b:	db	0
L1c7c:	db	0
L1c7d:	db	0,0
L1c7f:	db	0
L1c80:	db	0

L1c81:	db	0,0
inptr:	db	0,0
outptr:	db	0,0
curchr:	db	0
inidx:	db	0
outidx:	db	0

L1c8a:	db	0
relbyt:	db	0
libbyt:	db	0
L1c8d:	db	'ABORTED$'
L1c95:	db	'DISK READ ERROR$'
L1ca5:	db	'DISK WRITE ERROR$'
L1cb6:	db	'CANNOT CLOSE$'
L1cc3:	db	'DIRECTORY FULL$'
L1cd2:	db	'NO FILE: $'

; local variables for rwfile()?
reccnt:	db	1ah,1ah
L1cde:	db	1ah,1ah
L1ce0:	db	1ah

L1ce1:	db	1ah,1ah
L1ce3:	db	1ah,1ah
; params for rwfile()
rwdma:	db	1ah,1ah
rwbyts:	db	1ah,1ah
rwfcb:	db	1ah,1ah
rwflag:	db	1ah
; params for rdfile()
rddma:	db	1ah,1ah
rdbyts:	db	1ah,1ah
rdfcb:	db	1ah,1ah
; params for wrfile()
wrdma:	db	1ah,1ah
wrbyts:	db	1ah,1ah
wrfcb:	db	1ah,1ah

L1cf8:	db	1ah,1ah
L1cfa:	db	1ah
L1cfb:	db	1ah,1ah
L1cfd:	db	1ah,1ah
L1cff:	db	1ah
L1d00:	ds	2
L1d02:	ds	2
L1d04:	ds	2
L1d06:	ds	2
L1d08:	ds	2
L1d0a:	ds	2
L1d0c:	ds	2
L1d0e:	ds	2
L1d10:	ds	2
cmdbuf:	ds	128
libbuf:	ds	512
relbuf:	ds	1024
L2392:	ds	1024
L2792:	ds	0
	end
