; Disassembly of LINK.COM
; Orioginally written in PL/I? PL/M?

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
linin	equ	10
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
getsda	equ	154

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

;	struct symbol {
;		struct symbol *next;
;		uint8_t	f1:1;	//?
;		uint8_t	f2:1;	//?
;		uint8_t	slen:6;	// total struct len (incl optional)
;		uint16_t val;	//?
;		uint8_t f3:1;
;		uint8_t seg:2;
;		uint8_t len:5;	// name[] len
;		char name[]
;		uint16_t opt;	// optional?
;	};
;
;	struct tmpfile {
;		uint16_t f1;	// +0
;		uint16_t f2;	// +2
;		uint16_t f3;	// +4 length
;		uint16_t f4;	// +6 address
;		uint16_t f5;	// +8
;		uint16_t f6;	// +10 max record?
;		uint8_t f8;	// +12
;		uint8_t f9;	// +13 init/create flag?
;		uint8_t fcb[33]; // +14 struct fcb...
;	};

	org	00100h
	jmp	L01a7		;; 0100: c3 a7 01    ...

	db	'COPYRIGHT (C) 1980 DIGITAL RESEARCH ',0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0afh,0,0,0,14h,13h
L0187:	db	'?'
L0188:	db	0
L0189:	db	0,4
L018b:	db	0,' '
L018d:	db	0,18h
L018f:	db	0,2
L0191:	db	'OVL'
L0194:	db	cr,lf,cr,lf,'LINKING $'
L01a1:	db	cr,lf,'$'
L01a4:	db	'   '

L01a7:	lxi	sp,stack	;; 01a7: 31 4c 39    1L9
	lxi	b,L394d		;; 01aa: 01 4d 39    .M9
	call	pagmsg		;; 01ad: cd c8 02    ...
	call	L07d9		;; 01b0: cd d9 07    ...
	lxi	h,L398e		;; 01b3: 21 8e 39    ..9
	mvi	m,000h		;; 01b6: 36 00       6.
	call	L0677		;; 01b8: cd 77 06    .w.
	lda	prlflg		;; 01bb: 3a 6f 39    :o9
	sui	000h		;; 01be: d6 00       ..
	adi	0ffh		;; 01c0: c6 ff       ..
	sbb	a		;; 01c2: 9f          .
	lxi	h,L398d		;; 01c3: 21 8d 39    ..9
	ana	m		;; 01c6: a6          .
	rar			;; 01c7: 1f          .
	jnc	L01ce		;; 01c8: d2 ce 01    ...
	call	prtcmd		;; 01cb: cd 44 08    .D.
L01ce:	call	L03c1		;; 01ce: cd c1 03    ...
	lda	L0188		;; 01d1: 3a 88 01    :..
	rar			;; 01d4: 1f          .
	jnc	L01ea		;; 01d5: d2 ea 01    ...
	lxi	h,1024		;; 01d8: 21 00 04    ...
	shld	L018b		;; 01db: 22 8b 01    "..
	shld	L018d		;; 01de: 22 8d 01    "..
	lxi	h,256		;; 01e1: 21 00 01    ...
	shld	L0189		;; 01e4: 22 89 01    "..
	shld	L018f		;; 01e7: 22 8f 01    "..
L01ea:	call	L02e1		;; 01ea: cd e1 02    ...
	lxi	h,bdos+1	;; 01ed: 21 06 00    ...
	shld	L39a4		;; 01f0: 22 a4 39    ".9
	lhld	L39a4		;; 01f3: 2a a4 39    *.9
	mov	e,m		;; 01f6: 5e          ^
	inx	h		;; 01f7: 23          #
	mov	d,m		;; 01f8: 56          V
	xchg			;; 01f9: eb          .
	shld	L39a6		;; 01fa: 22 a6 39    ".9
	shld	L3a71		;; 01fd: 22 71 3a    "q:
	lda	intdst		;; 0200: 3a 75 39    :u9
	cpi	000h		;; 0203: fe 00       ..
	jz	L020b		;; 0205: ca 0b 02    ...
	call	L03a5		;; 0208: cd a5 03    ...
L020b:	call	L36e8		;; 020b: cd e8 36    ..6
	lhld	L018f		;; 020e: 2a 8f 01    *..
	xchg			;; 0211: eb          .
	lhld	L3b3d		;; 0212: 2a 3d 3b    *=;
	dad	d		;; 0215: 19          .
	shld	L3a60		;; 0216: 22 60 3a    "`:
	shld	L3a62		;; 0219: 22 62 3a    "b:
	lxi	b,L3a71		;; 021c: 01 71 3a    .q:
	lxi	d,L3a62		;; 021f: 11 62 3a    .b:
	call	subxxx		;; 0222: cd 9e 38    ..8
	jc	L022e		;; 0225: da 2e 02    ...
	lxi	b,L39ca		;; 0228: 01 ca 39    ..9
	call	L36e2		;; 022b: cd e2 36    ..6
L022e:	lxi	b,L3a60		;; 022e: 01 60 3a    .`:
	lxi	d,L3a71		;; 0231: 11 71 3a    .q:
	call	subxxx		;; 0234: cd 9e 38    ..8
	shld	L39a8		;; 0237: 22 a8 39    ".9
	call	L037c		;; 023a: cd 7c 03    .|.
	lxi	h,L398e		;; 023d: 21 8e 39    ..9
	mvi	m,001h		;; 0240: 36 01       6.
	call	L0677		;; 0242: cd 77 06    .w.
	call	L316a		;; 0245: cd 6a 31    .j1
	lda	L398d		;; 0248: 3a 8d 39    :.9
	rar			;; 024b: 1f          .
	jnc	L0252		;; 024c: d2 52 02    .R.
	call	L1f2c		;; 024f: cd 2c 1f    .,.
L0252:	call	cpm		;; 0252: cd 00 00    ...
	ei			;; 0255: fb          .
	hlt			;; 0256: 76          v

outchr:	lxi	h,L3c16		;; 0257: 21 16 3c    ..<
	mov	m,c		;; 025a: 71          q
	lda	condst		;; 025b: 3a 74 39    :t9
	cpi	'X'		;; 025e: fe 58       .X
	jnz	L026d		;; 0260: c2 6d 02    .m.
	lhld	L3c16		;; 0263: 2a 16 3c    *.<
	mov	c,l		;; 0266: 4d          M
	call	chrout		;; 0267: cd 78 36    .x6
	jmp	L027c		;; 026a: c3 7c 02    .|.

L026d:	lda	condst		;; 026d: 3a 74 39    :t9
	cpi	'Y'		;; 0270: fe 59       .Y
	jnz	L027c		;; 0272: c2 7c 02    .|.
	lhld	L3c16		;; 0275: 2a 16 3c    *.<
	mov	c,l		;; 0278: 4d          M
	call	lstchr		;; 0279: cd 7e 36    .~6
L027c:	ret			;; 027c: c9          .

outmsg:	lxi	h,L3c17+1		;; 027d: 21 18 3c    ..<
	mov	m,b		;; 0280: 70          p
	dcx	h		;; 0281: 2b          +
	mov	m,c		;; 0282: 71          q
L0283:	lhld	L3c17		;; 0283: 2a 17 3c    *.<
	mov	a,m		;; 0286: 7e          ~
	cpi	'$'		;; 0287: fe 24       .$
	jz	L029d		;; 0289: ca 9d 02    ...
	lhld	L3c17		;; 028c: 2a 17 3c    *.<
	mov	c,m		;; 028f: 4e          N
	call	outchr		;; 0290: cd 57 02    .W.
	lhld	L3c17		;; 0293: 2a 17 3c    *.<
	inx	h		;; 0296: 23          #
	shld	L3c17		;; 0297: 22 17 3c    ".<
	jmp	L0283		;; 029a: c3 83 02    ...

L029d:	ret			;; 029d: c9          .

newpag:	lda	condst		;; 029e: 3a 74 39    :t9
	cpi	'Y'		;; 02a1: fe 59       .Y
	jnz	L02b1		;; 02a3: c2 b1 02    ...
	lxi	h,L3973		;; 02a6: 21 73 39    .s9
	mvi	m,0		;; 02a9: 36 00       6.
	lxi	b,L394c		;; 02ab: 01 4c 39    .L9
	call	outmsg		;; 02ae: cd 7d 02    .}.
L02b1:	ret			;; 02b1: c9          .

; output char, on first time call newpag
putchr:	lxi	h,L3c19		;; 02b2: 21 19 3c    ..<
	mov	m,c		;; 02b5: 71          q
	lda	L3973		;; 02b6: 3a 73 39    :s9
	rar			;; 02b9: 1f          .
	jnc	L02c0		;; 02ba: d2 c0 02    ...
	call	newpag		;; 02bd: cd 9e 02    ...
L02c0:	lhld	L3c19		;; 02c0: 2a 19 3c    *.<
	mov	c,l		;; 02c3: 4d          M
	call	outchr		;; 02c4: cd 57 02    .W.
	ret			;; 02c7: c9          .

pagmsg:	lxi	h,L3c1a+1	;; 02c8: 21 1b 3c    ..<
	mov	m,b		;; 02cb: 70          p
	dcx	h		;; 02cc: 2b          +
	mov	m,c		;; 02cd: 71          q
	lda	L3973		;; 02ce: 3a 73 39    :s9
	rar			;; 02d1: 1f          .
	jnc	L02d8		;; 02d2: d2 d8 02    ...
	call	newpag		;; 02d5: cd 9e 02    ...
L02d8:	lhld	L3c1a		;; 02d8: 2a 1a 3c    *.<
	mov	b,h		;; 02db: 44          D
	mov	c,l		;; 02dc: 4d          M
	call	outmsg		;; 02dd: cd 7d 02    .}.
	ret			;; 02e0: c9          .

L02e1:	lda	L0188		;; 02e1: 3a 88 01    :..
	rar			;; 02e4: 1f          .
	jnc	L030a		;; 02e5: d2 0a 03    ...
	lhld	L3a2e		;; 02e8: 2a 2e 3a    *.:
	inx	h		;; 02eb: 23          #
	shld	L3b6e		;; 02ec: 22 6e 3b    "n;
	push	h		;; 02ef: e5          .
	lhld	L3b72		;; 02f0: 2a 72 3b    *r;
	pop	b		;; 02f3: c1          .
	dad	b		;; 02f4: 09          .
	shld	L3b96		;; 02f5: 22 96 3b    ".;
	push	h		;; 02f8: e5          .
	lhld	L3b9a		;; 02f9: 2a 9a 3b    *.;
	pop	b		;; 02fc: c1          .
	dad	b		;; 02fd: 09          .
	shld	L3bbe		;; 02fe: 22 be 3b    ".;
	push	h		;; 0301: e5          .
	lhld	L3bc2		;; 0302: 2a c2 3b    *.;
	pop	b		;; 0305: c1          .
	dad	b		;; 0306: 09          .
	shld	L3be6		;; 0307: 22 e6 3b    ".;
L030a:	lhld	L0189		;; 030a: 2a 89 01    *..
	dcx	h		;; 030d: 2b          +
	shld	L3aac		;; 030e: 22 ac 3a    ".:
	lhld	L0189		;; 0311: 2a 89 01    *..
	shld	L3aae		;; 0314: 22 ae 3a    ".:
	lda	L0188		;; 0317: 3a 88 01    :..
	rar			;; 031a: 1f          .
	jnc	L032c		;; 031b: d2 2c 03    .,.
	lhld	L3bea		;; 031e: 2a ea 3b    *.;
	xchg			;; 0321: eb          .
	lhld	L3be6		;; 0322: 2a e6 3b    *.;
	dad	d		;; 0325: 19          .
	shld	L3ab0		;; 0326: 22 b0 3a    ".:
	jmp	L0333		;; 0329: c3 33 03    .3.

L032c:	lhld	L3a2e		;; 032c: 2a 2e 3a    *.:
	inx	h		;; 032f: 23          #
	shld	L3ab0		;; 0330: 22 b0 3a    ".:
L0333:	lhld	L018b		;; 0333: 2a 8b 01    *..
	dcx	h		;; 0336: 2b          +
	shld	L3adb		;; 0337: 22 db 3a    ".:
	lhld	L018b		;; 033a: 2a 8b 01    *..
	shld	L3add		;; 033d: 22 dd 3a    ".:
	lhld	L0189		;; 0340: 2a 89 01    *..
	xchg			;; 0343: eb          .
	lhld	L3ab0		;; 0344: 2a b0 3a    *.:
	dad	d		;; 0347: 19          .
	shld	L3adf		;; 0348: 22 df 3a    ".:
	lhld	L018d		;; 034b: 2a 8d 01    *..
	dcx	h		;; 034e: 2b          +
	shld	L3b0a		;; 034f: 22 0a 3b    ".;
	lhld	L018d		;; 0352: 2a 8d 01    *..
	shld	L3b0c		;; 0355: 22 0c 3b    ".;
	lhld	L018b		;; 0358: 2a 8b 01    *..
	xchg			;; 035b: eb          .
	lhld	L3adf		;; 035c: 2a df 3a    *.:
	dad	d		;; 035f: 19          .
	shld	L3b0e		;; 0360: 22 0e 3b    ".;
	lhld	L018f		;; 0363: 2a 8f 01    *..
	dcx	h		;; 0366: 2b          +
	shld	L3b39		;; 0367: 22 39 3b    "9;
	lhld	L018f		;; 036a: 2a 8f 01    *..
	shld	L3b3b		;; 036d: 22 3b 3b    ";;
	lhld	L018d		;; 0370: 2a 8d 01    *..
	xchg			;; 0373: eb          .
	lhld	L3b0e		;; 0374: 2a 0e 3b    *.;
	dad	d		;; 0377: 19          .
	shld	L3b3d		;; 0378: 22 3d 3b    "=;
	ret			;; 037b: c9          .

L037c:	lxi	h,segmnt		;; 037c: 21 5d 3a    .]:
	mvi	m,000h		;; 037f: 36 00       6.
L0381:	mvi	a,003h		;; 0381: 3e 03       >.
	lxi	h,segmnt		;; 0383: 21 5d 3a    .]:
	cmp	m		;; 0386: be          .
	jc	L03a4		;; 0387: da a4 03    ...
	lhld	segmnt		;; 038a: 2a 5d 3a    *]:
	mvi	h,000h		;; 038d: 26 00       &.
	lxi	b,L3b66		;; 038f: 01 66 3b    .f;
	dad	h		;; 0392: 29          )
	dad	b		;; 0393: 09          .
	mov	c,m		;; 0394: 4e          N
	inx	h		;; 0395: 23          #
	mov	b,m		;; 0396: 46          F
	call	L348b		;; 0397: cd 8b 34    ..4
	call	rstfil		;; 039a: cd db 31    ..1
	lxi	h,segmnt		;; 039d: 21 5d 3a    .]:
	inr	m		;; 03a0: 34          4
	jnz	L0381		;; 03a1: c2 81 03    ...
L03a4:	ret			;; 03a4: c9          .

L03a5:	lda	intdst		;; 03a5: 3a 75 39    :u9
	sta	L3ab8		;; 03a8: 32 b8 3a    2.:
	sta	L3ae7		;; 03ab: 32 e7 3a    2.:
	sta	L3b16		;; 03ae: 32 16 3b    2.;
	sta	L3b45		;; 03b1: 32 45 3b    2E;
	sta	L3b75		;; 03b4: 32 75 3b    2u;
	sta	L3b9d		;; 03b7: 32 9d 3b    2.;
	sta	L3bc5		;; 03ba: 32 c5 3b    2.;
	sta	L3bed		;; 03bd: 32 ed 3b    2.;
	ret			;; 03c0: c9          .

L03c1:	lxi	h,L3a44		;; 03c1: 21 44 3a    .D:
	mvi	m,0		;; 03c4: 36 00       6.
	dcx	h		;; 03c6: 2b          +
	mvi	m,0		;; 03c7: 36 00       6.
	lxi	h,L3a45		;; 03c9: 21 45 3a    .E:
	mvi	m,0		;; 03cc: 36 00       6.
	lxi	h,256		;; 03ce: 21 00 01    ...
	shld	L3970		;; 03d1: 22 70 39    "p9
	lxi	h,0		;; 03d4: 21 00 00    ...
	shld	L396d		;; 03d7: 22 6d 39    "m9
	mov	a,l		;; 03da: 7d          }
	sta	prlflg		;; 03db: 32 6f 39    2o9
	lxi	h,L397a		;; 03de: 21 7a 39    .z9
	mvi	m,1		;; 03e1: 36 01       6.
	sta	libdst		;; 03e3: 32 76 39    2v9
	sta	symdst		;; 03e6: 32 78 39    2x9
	sta	objdst		;; 03e9: 32 77 39    2w9
	lxi	h,condst		;; 03ec: 21 74 39    .t9
	mvi	m,'X'		;; 03ef: 36 58       6X
	ret			;; 03f1: c9          .

L03f2:	lxi	h,00000h	;; 03f2: 21 00 00    ...
	shld	L3a79		;; 03f5: 22 79 3a    "y:
	shld	L3a7b		;; 03f8: 22 7b 3a    "{:
	shld	L3a7d		;; 03fb: 22 7d 3a    "}:
	shld	L3a7f		;; 03fe: 22 7f 3a    ".:
	shld	L3a81		;; 0401: 22 81 3a    ".:
	shld	L3a83		;; 0404: 22 83 3a    ".:
	shld	L3a85		;; 0407: 22 85 3a    ".:
	shld	L3a87		;; 040a: 22 87 3a    ".:
	shld	L3a89		;; 040d: 22 89 3a    ".:
	shld	L3a8b		;; 0410: 22 8b 3a    ".:
	shld	L3a8d		;; 0413: 22 8d 3a    ".:
	shld	L3a8f		;; 0416: 22 8f 3a    ".:
	shld	L3a91		;; 0419: 22 91 3a    ".:
	shld	L3a93		;; 041c: 22 93 3a    ".:
	shld	L3a95		;; 041f: 22 95 3a    ".:
	shld	L3a97		;; 0422: 22 97 3a    ".:
	shld	L3a69		;; 0425: 22 69 3a    "i:
	shld	L3a6b		;; 0428: 22 6b 3a    "k:
	shld	L3a6d		;; 042b: 22 6d 3a    "m:
	shld	L3a6f		;; 042e: 22 6f 3a    "o:
	mov	a,l		;; 0431: 7d          }
	sta	L3a99		;; 0432: 32 99 3a    2.:
	lxi	h,L3a9a		;; 0435: 21 9a 3a    ..:
	mvi	m,001h		;; 0438: 36 01       6.
	inx	h		;; 043a: 23          #
	mvi	m,002h		;; 043b: 36 02       6.
	inx	h		;; 043d: 23          #
	mvi	m,003h		;; 043e: 36 03       6.
	lhld	L39a6		;; 0440: 2a a6 39    *.9
	shld	L3a71		;; 0443: 22 71 3a    "q:
	sta	L3a43		;; 0446: 32 43 3a    2C:
	sta	L3a44		;; 0449: 32 44 3a    2D:
	sta	L3a45		;; 044c: 32 45 3a    2E:
	sta	L3a52		;; 044f: 32 52 3a    2R:
	lxi	h,0ffffh	;; 0452: 21 ff ff    ...
	shld	L3a58		;; 0455: 22 58 3a    "X:
	mov	l,a		;; 0458: 6f          o
	mvi	h,000h		;; 0459: 26 00       &.
	shld	L3a5a		;; 045b: 22 5a 3a    "Z:
	call	L037c		;; 045e: cd 7c 03    .|.
	lxi	h,0ffffh	;; 0461: 21 ff ff    ...
	shld	L3a73		;; 0464: 22 73 3a    "s:
	lxi	h,00000h	;; 0467: 21 00 00    ...
	shld	L3b70		;; 046a: 22 70 3b    "p;
	shld	L3b98		;; 046d: 22 98 3b    ".;
	shld	L3bc0		;; 0470: 22 c0 3b    ".;
	shld	L3be8		;; 0473: 22 e8 3b    ".;
	shld	L3aaa		;; 0476: 22 aa 3a    ".:
	shld	L3ad9		;; 0479: 22 d9 3a    ".:
	shld	L3b08		;; 047c: 22 08 3b    ".;
	shld	L3b37		;; 047f: 22 37 3b    "7;
	lhld	L0189		;; 0482: 2a 89 01    *..
	dcx	h		;; 0485: 2b          +
	shld	L3aac		;; 0486: 22 ac 3a    ".:
	lhld	L018b		;; 0489: 2a 8b 01    *..
	dcx	h		;; 048c: 2b          +
	shld	L3adb		;; 048d: 22 db 3a    ".:
	lhld	L018d		;; 0490: 2a 8d 01    *..
	dcx	h		;; 0493: 2b          +
	shld	L3b0a		;; 0494: 22 0a 3b    ".;
	lhld	L018f		;; 0497: 2a 8f 01    *..
	dcx	h		;; 049a: 2b          +
	shld	L3b39		;; 049b: 22 39 3b    "9;
	lxi	h,1		;; 049e: 21 01 00    ...
	shld	L3ab2		;; 04a1: 22 b2 3a    ".:
	shld	L3ae1		;; 04a4: 22 e1 3a    ".:
	shld	L3b10		;; 04a7: 22 10 3b    ".;
	shld	L3b3f		;; 04aa: 22 3f 3b    "?;
	lxi	h,0		;; 04ad: 21 00 00    ...
	shld	L3ab4		;; 04b0: 22 b4 3a    ".:
	shld	L3ae3		;; 04b3: 22 e3 3a    ".:
	shld	L3b12		;; 04b6: 22 12 3b    ".;
	shld	L3b41		;; 04b9: 22 41 3b    "A;
	ret			;; 04bc: c9          .

L04bd:	lda	L398f		;; 04bd: 3a 8f 39    :.9
	cpi	000h		;; 04c0: fe 00       ..
	jnz	L04c9		;; 04c2: c2 c9 04    ...
	lhld	L3a62		;; 04c5: 2a 62 3a    *b:
	ret			;; 04c8: c9          .

L04c9:	lda	L398f		;; 04c9: 3a 8f 39    :.9
	dcr	a		;; 04cc: 3d          =
	mov	l,a		;; 04cd: 6f          o
	mvi	h,000h		;; 04ce: 26 00       &.
	dad	h		;; 04d0: 29          )
	dad	h		;; 04d1: 29          )
	lxi	b,L3990		;; 04d2: 01 90 39    ..9
	dad	b		;; 04d5: 09          .
	lxi	b,00002h	;; 04d6: 01 02 00    ...
	dad	b		;; 04d9: 09          .
	mov	e,m		;; 04da: 5e          ^
	inx	h		;; 04db: 23          #
	mov	d,m		;; 04dc: 56          V
	xchg			;; 04dd: eb          .
	ret			;; 04de: c9          .

L04df:	lxi	h,L3c1d		;; 04df: 21 1d 3c    ..<
	mov	m,b		;; 04e2: 70          p
	dcx	h		;; 04e3: 2b          +
	mov	m,c		;; 04e4: 71          q
	lxi	h,L3c1e		;; 04e5: 21 1e 3c    ..<
	mvi	m,000h		;; 04e8: 36 00       6.
L04ea:	mvi	a,07fh		;; 04ea: 3e 7f       >.
	lxi	h,L3c1e		;; 04ec: 21 1e 3c    ..<
	cmp	m		;; 04ef: be          .
	jc	L0534		;; 04f0: da 34 05    .4.
L04f3:	lhld	L3c1e		;; 04f3: 2a 1e 3c    *.<
	mvi	h,000h		;; 04f6: 26 00       &.
	lxi	b,L3c5e		;; 04f8: 01 5e 3c    .^<
	dad	h		;; 04fb: 29          )
	dad	b		;; 04fc: 09          .
	xchg			;; 04fd: eb          .
	lxi	b,L3c1c		;; 04fe: 01 1c 3c    ..<
	call	subxxx		;; 0501: cd 9e 38    ..8
	jc	L052d		;; 0504: da 2d 05    .-.
	lhld	L3c1e		;; 0507: 2a 1e 3c    *.<
	mvi	h,000h		;; 050a: 26 00       &.
	lxi	b,L3c5e		;; 050c: 01 5e 3c    .^<
	dad	h		;; 050f: 29          )
	dad	b		;; 0510: 09          .
	mov	e,m		;; 0511: 5e          ^
	inx	h		;; 0512: 23          #
	mov	d,m		;; 0513: 56          V
	xchg			;; 0514: eb          .
	shld	cursym		;; 0515: 22 64 3a    "d:
	call	getnxt		;; 0518: cd 4d 13    .M.
	push	h		;; 051b: e5          .
	lhld	L3c1e		;; 051c: 2a 1e 3c    *.<
	mvi	h,000h		;; 051f: 26 00       &.
	lxi	b,L3c5e		;; 0521: 01 5e 3c    .^<
	dad	h		;; 0524: 29          )
	dad	b		;; 0525: 09          .
	pop	b		;; 0526: c1          .
	mov	m,c		;; 0527: 71          q
	inx	h		;; 0528: 23          #
	mov	m,b		;; 0529: 70          p
	jmp	L04f3		;; 052a: c3 f3 04    ...

L052d:	lxi	h,L3c1e		;; 052d: 21 1e 3c    ..<
	inr	m		;; 0530: 34          4
	jnz	L04ea		;; 0531: c2 ea 04    ...
L0534:	ret			;; 0534: c9          .

L0535:	lhld	L398f		;; 0535: 2a 8f 39    *.9
	mvi	h,000h		;; 0538: 26 00       &.
	dad	h		;; 053a: 29          )
	dad	h		;; 053b: 29          )
	lxi	b,L3990		;; 053c: 01 90 39    ..9
	dad	b		;; 053f: 09          .
	lxi	b,00002h	;; 0540: 01 02 00    ...
	dad	b		;; 0543: 09          .
	push	h		;; 0544: e5          .
	lhld	L3a60		;; 0545: 2a 60 3a    *`:
	xchg			;; 0548: eb          .
	pop	h		;; 0549: e1          .
	mov	m,e		;; 054a: 73          s
	inx	h		;; 054b: 23          #
	mov	m,d		;; 054c: 72          r
	lxi	d,127		;; 054d: 11 7f 00    ...
	lhld	L3a41		;; 0550: 2a 41 3a    *A:
	dad	d		;; 0553: 19          .
	lxi	d,-128		;; 0554: 11 80 ff    ...
	call	L3829		;; 0557: cd 29 38    .)8
	shld	L3970		;; 055a: 22 70 39    "p9
	push	h		;; 055d: e5          .
	lhld	L398f		;; 055e: 2a 8f 39    *.9
	mvi	h,000h		;; 0561: 26 00       &.
	dad	h		;; 0563: 29          )
	dad	h		;; 0564: 29          )
	lxi	b,L3990		;; 0565: 01 90 39    ..9
	dad	b		;; 0568: 09          .
	pop	b		;; 0569: c1          .
	mov	m,c		;; 056a: 71          q
	inx	h		;; 056b: 23          #
	mov	m,b		;; 056c: 70          p
	ret			;; 056d: c9          .

L056e:	lda	L398f		;; 056e: 3a 8f 39    :.9
	inr	a		;; 0571: 3c          <
	sta	L398f		;; 0572: 32 8f 39    2.9
	mov	c,a		;; 0575: 4f          O
	mvi	a,005h		;; 0576: 3e 05       >.
	cmp	c		;; 0578: b9          .
	jnc	L057f		;; 0579: d2 7f 05    ...
	call	prtcmd		;; 057c: cd 44 08    .D.
L057f:	ret			;; 057f: c9          .

L0580:	lda	L398f		;; 0580: 3a 8f 39    :.9
	dcr	a		;; 0583: 3d          =
	sta	L398f		;; 0584: 32 8f 39    2.9
	cpi	0ffh		;; 0587: fe ff       ..
	jnz	L058f		;; 0589: c2 8f 05    ...
	call	prtcmd		;; 058c: cd 44 08    .D.
L058f:	lda	L398e		;; 058f: 3a 8e 39    :.9
	rar			;; 0592: 1f          .
	jc	L0597		;; 0593: da 97 05    ...
	ret			;; 0596: c9          .

L0597:	lhld	L398f		;; 0597: 2a 8f 39    *.9
	mvi	h,000h		;; 059a: 26 00       &.
	dad	h		;; 059c: 29          )
	dad	h		;; 059d: 29          )
	lxi	b,L3990		;; 059e: 01 90 39    ..9
	push	h		;; 05a1: e5          .
	dad	b		;; 05a2: 09          .
	mov	e,m		;; 05a3: 5e          ^
	inx	h		;; 05a4: 23          #
	mov	d,m		;; 05a5: 56          V
	xchg			;; 05a6: eb          .
	shld	L3970		;; 05a7: 22 70 39    "p9
	pop	h		;; 05aa: e1          .
	dad	b		;; 05ab: 09          .
	lxi	b,00002h	;; 05ac: 01 02 00    ...
	dad	b		;; 05af: 09          .
	mov	e,m		;; 05b0: 5e          ^
	inx	h		;; 05b1: 23          #
	mov	d,m		;; 05b2: 56          V
	xchg			;; 05b3: eb          .
	shld	L3a60		;; 05b4: 22 60 3a    "`:
	lhld	L3a60		;; 05b7: 2a 60 3a    *`:
	mov	b,h		;; 05ba: 44          D
	mov	c,l		;; 05bb: 4d          M
	call	L04df		;; 05bc: cd df 04    ...
	ret			;; 05bf: c9          .

L05c0:	lxi	h,L398d		;; 05c0: 21 8d 39    ..9
	mvi	m,001h		;; 05c3: 36 01       6.
	inx	h		;; 05c5: 23          #
	mov	a,m		;; 05c6: 7e          ~
	rar			;; 05c7: 1f          .
	jnc	L05ce		;; 05c8: d2 ce 05    ...
	call	L03f2		;; 05cb: cd f2 03    ...
L05ce:	call	getfil		;; 05ce: cd ac 0c    ...
	mvi	l,12		;; 05d1: 2e 0c       ..
	lxi	d,L3a22		;; 05d3: 11 22 3a    .":
	lxi	b,deffcb	;; 05d6: 01 5c 00    .\.
L05d9:	ldax	b		;; 05d9: 0a          .
	stax	d		;; 05da: 12          .
	inx	b		;; 05db: 03          .
	inx	d		;; 05dc: 13          .
	dcr	l		;; 05dd: 2d          -
	jnz	L05d9		;; 05de: c2 d9 05    ...
	lda	L3a2b		;; 05e1: 3a 2b 3a    :+:
	cpi	' '		;; 05e4: fe 20       . 
	jnz	L05f9		;; 05e6: c2 f9 05    ...
	mvi	l,003h		;; 05e9: 2e 03       ..
	lxi	d,L3a2b		;; 05eb: 11 2b 3a    .+:
	lxi	b,L0191		;; 05ee: 01 91 01    ...
L05f1:	ldax	b		;; 05f1: 0a          .
	stax	d		;; 05f2: 12          .
	inx	b		;; 05f3: 03          .
	inx	d		;; 05f4: 13          .
	dcr	l		;; 05f5: 2d          -
	jnz	L05f1		;; 05f6: c2 f1 05    ...
L05f9:	lda	L398e		;; 05f9: 3a 8e 39    :.9
	rar			;; 05fc: 1f          .
	jnc	L0612		;; 05fd: d2 12 06    ...
	lxi	b,L0194		;; 0600: 01 94 01    ...
	call	pagmsg		;; 0603: cd c8 02    ...
	lxi	b,L3a22		;; 0606: 01 22 3a    .":
	call	L3512		;; 0609: cd 12 35    ..5
	lxi	b,L01a1		;; 060c: 01 a1 01    ...
	call	pagmsg		;; 060f: cd c8 02    ...
L0612:	lhld	L3a2e		;; 0612: 2a 2e 3a    *.:
	mov	a,m		;; 0615: 7e          ~
	cpi	'='		;; 0616: fe 3d       .=
	jnz	L061e		;; 0618: c2 1e 06    ...
	call	getfil		;; 061b: cd ac 0c    ...
L061e:	lda	L398e		;; 061e: 3a 8e 39    :.9
	rar			;; 0621: 1f          .
	jnc	L0628		;; 0622: d2 28 06    .(.
	call	L27e6		;; 0625: cd e6 27    ..'
L0628:	lhld	L3a2e		;; 0628: 2a 2e 3a    *.:
	mov	a,m		;; 062b: 7e          ~
	sui	'('		;; 062c: d6 28       .(
	adi	0ffh		;; 062e: c6 ff       ..
	sbb	a		;; 0630: 9f          .
	lhld	L3a2e		;; 0631: 2a 2e 3a    *.:
	push	psw		;; 0634: f5          .
	mov	a,m		;; 0635: 7e          ~
	sui	')'		;; 0636: d6 29       .)
	adi	0ffh		;; 0638: c6 ff       ..
	sbb	a		;; 063a: 9f          .
	pop	b		;; 063b: c1          .
	mov	c,b		;; 063c: 48          H
	ana	c		;; 063d: a1          .
	rar			;; 063e: 1f          .
	jnc	L065e		;; 063f: d2 5e 06    .^.
	lhld	L3a2e		;; 0642: 2a 2e 3a    *.:
	mov	a,m		;; 0645: 7e          ~
	cpi	','		;; 0646: fe 2c       .,
	jz	L064e		;; 0648: ca 4e 06    .N.
	call	prtcmd		;; 064b: cd 44 08    .D.
L064e:	call	getfil		;; 064e: cd ac 0c    ...
	lda	L398e		;; 0651: 3a 8e 39    :.9
	rar			;; 0654: 1f          .
	jnc	L065b		;; 0655: d2 5b 06    .[.
	call	L27e6		;; 0658: cd e6 27    ..'
L065b:	jmp	L0628		;; 065b: c3 28 06    .(.

L065e:	lda	L398e		;; 065e: 3a 8e 39    :.9
	rar			;; 0661: 1f          .
	jnc	L0676		;; 0662: d2 76 06    .v.
	call	L2843		;; 0665: cd 43 28    .C(
	call	L2910		;; 0668: cd 10 29    ..)
	lxi	h,prlflg		;; 066b: 21 6f 39    .o9
	mvi	m,004h		;; 066e: 36 04       6.
	call	L1f3e		;; 0670: cd 3e 1f    .>.
	call	L0535		;; 0673: cd 35 05    .5.
L0676:	ret			;; 0676: c9          .

L0677:	lxi	h,L4286		;; 0677: 21 86 42    ..B
	shld	L3a2e		;; 067a: 22 2e 3a    ".:
	call	getfil		;; 067d: cd ac 0c    ...
	mvi	l,12		;; 0680: 2e 0c       ..
	lxi	d,L3a22		;; 0682: 11 22 3a    .":
	lxi	b,deffcb	;; 0685: 01 5c 00    .\.
L0688:	ldax	b		;; 0688: 0a          .
	stax	d		;; 0689: 12          .
	inx	b		;; 068a: 03          .
	inx	d		;; 068b: 13          .
	dcr	l		;; 068c: 2d          -
	jnz	L0688		;; 068d: c2 88 06    ...
	lhld	L3a2e		;; 0690: 2a 2e 3a    *.:
	mov	a,m		;; 0693: 7e          ~
	cpi	'='		;; 0694: fe 3d       .=
	jnz	L069f		;; 0696: c2 9f 06    ...
	call	getfil		;; 0699: cd ac 0c    ...
	jmp	L06af		;; 069c: c3 af 06    ...

L069f:	mvi	l,3		;; 069f: 2e 03       ..
	lxi	d,L3a2b		;; 06a1: 11 2b 3a    .+:
	lxi	b,L01a4		;; 06a4: 01 a4 01    ...
L06a7:	ldax	b		;; 06a7: 0a          .
	stax	d		;; 06a8: 12          .
	inx	b		;; 06a9: 03          .
	inx	d		;; 06aa: 13          .
	dcr	l		;; 06ab: 2d          -
	jnz	L06a7		;; 06ac: c2 a7 06    ...
L06af:	lda	L398e		;; 06af: 3a 8e 39    :.9
	rar			;; 06b2: 1f          .
	jnc	L06b9		;; 06b3: d2 b9 06    ...
	call	L27e6		;; 06b6: cd e6 27    ..'
L06b9:	lhld	L3a2e		;; 06b9: 2a 2e 3a    *.:
	mov	a,m		;; 06bc: 7e          ~
	sui	000h		;; 06bd: d6 00       ..
	adi	0ffh		;; 06bf: c6 ff       ..
	sbb	a		;; 06c1: 9f          .
	lhld	L3a2e		;; 06c2: 2a 2e 3a    *.:
	push	psw		;; 06c5: f5          .
	mov	a,m		;; 06c6: 7e          ~
	sui	028h		;; 06c7: d6 28       .(
	adi	0ffh		;; 06c9: c6 ff       ..
	sbb	a		;; 06cb: 9f          .
	pop	b		;; 06cc: c1          .
	mov	c,b		;; 06cd: 48          H
	ana	c		;; 06ce: a1          .
	rar			;; 06cf: 1f          .
	jnc	L06ef		;; 06d0: d2 ef 06    ...
	lhld	L3a2e		;; 06d3: 2a 2e 3a    *.:
	mov	a,m		;; 06d6: 7e          ~
	cpi	','		;; 06d7: fe 2c       .,
	jz	L06df		;; 06d9: ca df 06    ...
	call	prtcmd		;; 06dc: cd 44 08    .D.
L06df:	call	getfil		;; 06df: cd ac 0c    ...
	lda	L398e		;; 06e2: 3a 8e 39    :.9
	rar			;; 06e5: 1f          .
	jnc	L06ec		;; 06e6: d2 ec 06    ...
	call	L27e6		;; 06e9: cd e6 27    ..'
L06ec:	jmp	L06b9		;; 06ec: c3 b9 06    ...

L06ef:	lda	objdst		;; 06ef: 3a 77 39    :w9
	sta	L3979		;; 06f2: 32 79 39    2y9
	lda	L398e		;; 06f5: 3a 8e 39    :.9
	rar			;; 06f8: 1f          .
	jnc	L0746		;; 06f9: d2 46 07    .F.
	lda	L398d		;; 06fc: 3a 8d 39    :.9
	rar			;; 06ff: 1f          .
	jnc	L0706		;; 0700: d2 06 07    ...
	call	L2819		;; 0703: cd 19 28    ..(
L0706:	call	L2843		;; 0706: cd 43 28    .C(
	call	L3786		;; 0709: cd 86 37    ..7
	lda	L398d		;; 070c: 3a 8d 39    :.9
	rar			;; 070f: 1f          .
	jnc	L0716		;; 0710: d2 16 07    ...
	call	L2910		;; 0713: cd 10 29    ..)
L0716:	lda	prlflg		;; 0716: 3a 6f 39    :o9
	sui	002h		;; 0719: d6 02       ..
	sui	001h		;; 071b: d6 01       ..
	sbb	a		;; 071d: 9f          .
	push	psw		;; 071e: f5          .
	lda	prlflg		;; 071f: 3a 6f 39    :o9
	sui	003h		;; 0722: d6 03       ..
	sui	001h		;; 0724: d6 01       ..
	sbb	a		;; 0726: 9f          .
	pop	b		;; 0727: c1          .
	mov	c,b		;; 0728: 48          H
	ora	c		;; 0729: b1          .
	rar			;; 072a: 1f          .
	jnc	L0734		;; 072b: d2 34 07    .4.
	lxi	h,00000h	;; 072e: 21 00 00    ...
	shld	L3970		;; 0731: 22 70 39    "p9
L0734:	call	L1f3e		;; 0734: cd 3e 1f    .>.
	lda	prlflg		;; 0737: 3a 6f 39    :o9
	sta	L398a		;; 073a: 32 8a 39    2.9
	lhld	L3970		;; 073d: 2a 70 39    *p9
	shld	L398b		;; 0740: 22 8b 39    ".9
	call	L0535		;; 0743: cd 35 05    .5.
L0746:	lhld	L3a2e		;; 0746: 2a 2e 3a    *.:
	mov	a,m		;; 0749: 7e          ~
	cpi	'('		;; 074a: fe 28       .(
	jnz	L0790		;; 074c: c2 90 07    ...
L074f:	lhld	L3a2e		;; 074f: 2a 2e 3a    *.:
	mov	a,m		;; 0752: 7e          ~
	cpi	000h		;; 0753: fe 00       ..
	jz	L0790		;; 0755: ca 90 07    ...
	call	L056e		;; 0758: cd 6e 05    .n.
	call	L05c0		;; 075b: cd c0 05    ...
L075e:	lhld	L3a2e		;; 075e: 2a 2e 3a    *.:
	mov	a,m		;; 0761: 7e          ~
	cpi	')'		;; 0762: fe 29       .)
	jnz	L0770		;; 0764: c2 70 07    .p.
	call	L0580		;; 0767: cd 80 05    ...
	call	skipb		;; 076a: cd d0 08    ...
	jmp	L075e		;; 076d: c3 5e 07    .^.

L0770:	lhld	L3a2e		;; 0770: 2a 2e 3a    *.:
	mov	a,m		;; 0773: 7e          ~
	sui	000h		;; 0774: d6 00       ..
	adi	0ffh		;; 0776: c6 ff       ..
	sbb	a		;; 0778: 9f          .
	lhld	L3a2e		;; 0779: 2a 2e 3a    *.:
	push	psw		;; 077c: f5          .
	mov	a,m		;; 077d: 7e          ~
	sui	'('		;; 077e: d6 28       .(
	adi	0ffh		;; 0780: c6 ff       ..
	sbb	a		;; 0782: 9f          .
	pop	b		;; 0783: c1          .
	mov	c,b		;; 0784: 48          H
	ana	c		;; 0785: a1          .
	rar			;; 0786: 1f          .
	jnc	L078d		;; 0787: d2 8d 07    ...
	call	prtcmd		;; 078a: cd 44 08    .D.
L078d:	jmp	L074f		;; 078d: c3 4f 07    .O.

L0790:	lda	L398f		;; 0790: 3a 8f 39    :.9
	cpi	000h		;; 0793: fe 00       ..
	jz	L079b		;; 0795: ca 9b 07    ...
	call	prtcmd		;; 0798: cd 44 08    .D.
L079b:	ret			;; 079b: c9          .

L079c:	mvi	c,'*'		;; 079c: 0e 2a       .*
	call	putchr		;; 079e: cd b2 02    ...
	lxi	h,cmdlin	;; 07a1: 21 80 00    ...
	mvi	m,126		;; 07a4: 36 7e       6~
	lxi	b,cmdlin	;; 07a6: 01 80 00    ...
	call	getlin		;; 07a9: cd 84 36    ..6
	lhld	cmdlin+1	;; 07ac: 2a 81 00    *..
	mvi	h,0		;; 07af: 26 00       &.
	lxi	b,cmdlin+2	;; 07b1: 01 82 00    ...
	dad	b		;; 07b4: 09          .
	mvi	m,0		;; 07b5: 36 00       6.
	lda	cmdlin+1	;; 07b7: 3a 81 00    :..
	inr	a		;; 07ba: 3c          <
	mov	l,a		;; 07bb: 6f          o
	push	h		;; 07bc: e5          .
	lhld	L3a2e		;; 07bd: 2a 2e 3a    *.:
	inx	h		;; 07c0: 23          #
	xchg			;; 07c1: eb          .
	lxi	b,cmdlin+2	;; 07c2: 01 82 00    ...
	pop	h		;; 07c5: e1          .
L07c6:	ldax	b		;; 07c6: 0a          .
	stax	d		;; 07c7: 12          .
	inx	b		;; 07c8: 03          .
	inx	d		;; 07c9: 13          .
	dcr	l		;; 07ca: 2d          -
	jnz	L07c6		;; 07cb: c2 c6 07    ...
	mvi	c,cr		;; 07ce: 0e 0d       ..
	call	putchr		;; 07d0: cd b2 02    ...
	mvi	c,lf		;; 07d3: 0e 0a       ..
	call	putchr		;; 07d5: cd b2 02    ...
	ret			;; 07d8: c9          .

L07d9:	lxi	h,L4287		;; 07d9: 21 87 42    ..B
	shld	L3a2e		;; 07dc: 22 2e 3a    ".:
	mvi	l,128		;; 07df: 2e 80       ..
	lxi	d,L4286		;; 07e1: 11 86 42    ..B
	lxi	b,defdma	;; 07e4: 01 80 00    ...
L07e7:	ldax	b		;; 07e7: 0a          .
	stax	d		;; 07e8: 12          .
	inx	b		;; 07e9: 03          .
	inx	d		;; 07ea: 13          .
	dcr	l		;; 07eb: 2d          -
	jnz	L07e7		;; 07ec: c2 e7 07    ...
L07ef:	lhld	L3a2e		;; 07ef: 2a 2e 3a    *.:
	mov	a,m		;; 07f2: 7e          ~
	cpi	0		;; 07f3: fe 00       ..
	jz	L080e		;; 07f5: ca 0e 08    ...
	lhld	L3a2e		;; 07f8: 2a 2e 3a    *.:
	mov	a,m		;; 07fb: 7e          ~
	cpi	'&'		;; 07fc: fe 26       .&
	jnz	L0804		;; 07fe: c2 04 08    ...
	call	L079c		;; 0801: cd 9c 07    ...
L0804:	lhld	L3a2e		;; 0804: 2a 2e 3a    *.:
	inx	h		;; 0807: 23          #
	shld	L3a2e		;; 0808: 22 2e 3a    ".:
	jmp	L07ef		;; 080b: c3 ef 07    ...

L080e:	ret			;; 080e: c9          .

delims:	db	0dh,' =.:<>[],()'

L081b:	db	'?$'

; convert to upper case
; also neuters ctrl chars
touppr:	lxi	h,L3c20		;; 081d: 21 20 3c    . <
	mov	m,c		;; 0820: 71          q
	lda	L3c20		;; 0821: 3a 20 3c    : <
	cpi	' '		;; 0824: fe 20       . 
	jnc	L082c		;; 0826: d2 2c 08    .,.
	mvi	a,cr		;; 0829: 3e 0d       >.
	ret			;; 082b: c9          .

L082c:	lda	L3c20		;; 082c: 3a 20 3c    : <
	sui	'a'		;; 082f: d6 61       .a
	mov	c,a		;; 0831: 4f          O
	mvi	a,'z'-'a'	;; 0832: 3e 19       >.
	cmp	c		;; 0834: b9          .
	jc	L0840		;; 0835: da 40 08    .@.
	lda	L3c20		;; 0838: 3a 20 3c    : <
	ani	05fh		;; 083b: e6 5f       ._
	sta	L3c20		;; 083d: 32 20 3c    2 <
L0840:	lda	L3c20		;; 0840: 3a 20 3c    : <
	ret			;; 0843: c9          .

; print the commandline, for error purposes
prtcmd:	lxi	h,L4288		;; 0844: 21 88 42    ..B
	shld	L3c21		;; 0847: 22 21 3c    ".<
L084a:	lxi	d,L3a2e		;; 084a: 11 2e 3a    ..:
	lxi	b,L3c21		;; 084d: 01 21 3c    ..<
	call	subxxx		;; 0850: cd 9e 38    ..8
	jc	L0883		;; 0853: da 83 08    ...
	lhld	L3c21		;; 0856: 2a 21 3c    *.<
	mov	c,m		;; 0859: 4e          N
	call	touppr		;; 085a: cd 1d 08    ...
	mov	c,a		;; 085d: 4f          O
	call	putchr		;; 085e: cd b2 02    ...
	lhld	L3c21		;; 0861: 2a 21 3c    *.<
	mov	a,m		;; 0864: 7e          ~
	cpi	'&'		;; 0865: fe 26       .&
	jnz	L0879		;; 0867: c2 79 08    .y.
	mvi	c,cr		;; 086a: 0e 0d       ..
	call	putchr		;; 086c: cd b2 02    ...
	mvi	c,lf		;; 086f: 0e 0a       ..
	call	putchr		;; 0871: cd b2 02    ...
	mvi	c,'*'		;; 0874: 0e 2a       .*
	call	putchr		;; 0876: cd b2 02    ...
L0879:	lhld	L3c21		;; 0879: 2a 21 3c    *.<
	inx	h		;; 087c: 23          #
	shld	L3c21		;; 087d: 22 21 3c    ".<
	jmp	L084a		;; 0880: c3 4a 08    .J.

L0883:	lxi	b,L081b		;; 0883: 01 1b 08    ...
	call	L36e2		;; 0886: cd e2 36    ..6
	ret			;; 0889: c9          .

isdlim:	lxi	h,L3c23		;; 088a: 21 23 3c    .#<
	mvi	m,0		;; 088d: 36 00       6.
L088f:	mvi	a,11		;; 088f: 3e 0b       >.
	lxi	h,L3c23		;; 0891: 21 23 3c    .#<
	cmp	m		;; 0894: be          .
	jc	L08b2		;; 0895: da b2 08    ...
	lhld	L3c23		;; 0898: 2a 23 3c    *#<
	mvi	h,0		;; 089b: 26 00       &.
	lxi	b,delims	;; 089d: 01 0f 08    ...
	dad	b		;; 08a0: 09          .
	lda	curchr		;; 08a1: 3a 1f 3c    :.<
	cmp	m		;; 08a4: be          .
	jnz	L08ab		;; 08a5: c2 ab 08    ...
	mvi	a,1		;; 08a8: 3e 01       >.
	ret			;; 08aa: c9          .

L08ab:	lxi	h,L3c23		;; 08ab: 21 23 3c    .#<
	inr	m		;; 08ae: 34          4
	jnz	L088f		;; 08af: c2 8f 08    ...
L08b2:	mvi	a,0		;; 08b2: 3e 00       >.
	ret			;; 08b4: c9          .

getchr:	lhld	L3a2e		;; 08b5: 2a 2e 3a    *.:
	inx	h		;; 08b8: 23          #
	shld	L3a2e		;; 08b9: 22 2e 3a    ".:
	lhld	L3a2e		;; 08bc: 2a 2e 3a    *.:
	mov	c,m		;; 08bf: 4e          N
	call	touppr		;; 08c0: cd 1d 08    ...
	sta	curchr		;; 08c3: 32 1f 3c    2.<
	cpi	'&'		;; 08c6: fe 26       .&
	jz	L08cc		;; 08c8: ca cc 08    ...
	ret			;; 08cb: c9          .

L08cc:	jmp	getchr		;; 08cc: c3 b5 08    ...

	ret			;; 08cf: c9          .

skipb:	call	getchr		;; 08d0: cd b5 08    ...
L08d3:	lda	curchr		;; 08d3: 3a 1f 3c    :.<
	cpi	' '		;; 08d6: fe 20       . 
	jnz	L08e1		;; 08d8: c2 e1 08    ...
	call	getchr		;; 08db: cd b5 08    ...
	jmp	L08d3		;; 08de: c3 d3 08    ...

L08e1:	ret			;; 08e1: c9          .

; parse filename, put in deffcb
inifcb:	lxi	h,curchr	;; 08e2: 21 1f 3c    ..<
	mvi	m,' '		;; 08e5: 36 20       6 
	lxi	h,L3c25		;; 08e7: 21 25 3c    .%<
	mvi	m,0		;; 08ea: 36 00       6.
	dcx	h		;; 08ec: 2b          +
	mvi	m,0ffh		;; 08ed: 36 ff       6.
L08ef:	lda	L3c25		;; 08ef: 3a 25 3c    :%<
	cpi	15		;; 08f2: fe 0f       ..
	jnc	L090a		;; 08f4: d2 0a 09    ...
	lda	L3c25		;; 08f7: 3a 25 3c    :%<
	cpi	11		;; 08fa: fe 0b       ..
	jnz	L0904		;; 08fc: c2 04 09    ...
	lxi	h,curchr		;; 08ff: 21 1f 3c    ..<
	mvi	m,0		;; 0902: 36 00       6.
L0904:	call	putfcb		;; 0904: cd b8 09    ...
	jmp	L08ef		;; 0907: c3 ef 08    ...

L090a:	lxi	h,deffcb	;; 090a: 21 5c 00    .\.
	mvi	m,0		;; 090d: 36 00       6.
L090f:	call	skipb		;; 090f: cd d0 08    ...
	call	isdlim		;; 0912: cd 8a 08    ...
	rar			;; 0915: 1f          .
	jnc	L091d		;; 0916: d2 1d 09    ...
	lxi	h,-1		;; 0919: 21 ff ff    ...
	ret			;; 091c: c9          .

L091d:	lxi	h,L3c25		;; 091d: 21 25 3c    .%<
	mvi	m,0		;; 0920: 36 00       6.
L0922:	call	isdlim		;; 0922: cd 8a 08    ...
	rar			;; 0925: 1f          .
	jc	L093e		;; 0926: da 3e 09    .>.
	lda	L3c25		;; 0929: 3a 25 3c    :%<
	cpi	8		;; 092c: fe 08       ..
	jc	L0935		;; 092e: da 35 09    .5.
	lxi	h,-1		;; 0931: 21 ff ff    ...
	ret			;; 0934: c9          .

L0935:	call	putfcb		;; 0935: cd b8 09    ...
	call	getchr		;; 0938: cd b5 08    ...
	jmp	L0922		;; 093b: c3 22 09    .".

L093e:	lda	curchr		;; 093e: 3a 1f 3c    :.<
	cpi	':'		;; 0941: fe 3a       .:
	jnz	L0984		;; 0943: c2 84 09    ...
	lda	deffcb		;; 0946: 3a 5c 00    :\.
	sui	000h		;; 0949: d6 00       ..
	sui	001h		;; 094b: d6 01       ..
	sbb	a		;; 094d: 9f          .
	push	psw		;; 094e: f5          .
	lda	L3c25		;; 094f: 3a 25 3c    :%<
	sui	001h		;; 0952: d6 01       ..
	sui	001h		;; 0954: d6 01       ..
	sbb	a		;; 0956: 9f          .
	pop	b		;; 0957: c1          .
	mov	c,b		;; 0958: 48          H
	ana	c		;; 0959: a1          .
	rar			;; 095a: 1f          .
	jc	L0962		;; 095b: da 62 09    .b.
	lxi	h,-1		;; 095e: 21 ff ff    ...
	ret			;; 0961: c9          .

L0962:	lda	deffcb+1	;; 0962: 3a 5d 00    :].
	sui	'A'		;; 0965: d6 41       .A
	inr	a		;; 0967: 3c          <
	sta	deffcb		;; 0968: 32 5c 00    2\.
	mov	c,a		;; 096b: 4f          O
	mvi	a,'Z'-'A'+1	;; 096c: 3e 1a       >.
	cmp	c		;; 096e: b9          .
	jnc	L0976		;; 096f: d2 76 09    .v.
	lxi	h,-1		;; 0972: 21 ff ff    ...
	ret			;; 0975: c9          .

L0976:	lhld	L3c25		;; 0976: 2a 25 3c    *%<
	mvi	h,0		;; 0979: 26 00       &.
	lxi	b,deffcb	;; 097b: 01 5c 00    .\.
	dad	b		;; 097e: 09          .
	mvi	m,' '		;; 097f: 36 20       6 
	jmp	L09b4		;; 0981: c3 b4 09    ...

L0984:	lxi	h,L3c25		;; 0984: 21 25 3c    .%<
	mvi	m,8		;; 0987: 36 08       6.
	lda	curchr		;; 0989: 3a 1f 3c    :.<
	cpi	'.'		;; 098c: fe 2e       ..
	jnz	L09b0		;; 098e: c2 b0 09    ...
	call	getchr		;; 0991: cd b5 08    ...
L0994:	call	isdlim		;; 0994: cd 8a 08    ...
	rar			;; 0997: 1f          .
	jc	L09b0		;; 0998: da b0 09    ...
	lda	L3c25		;; 099b: 3a 25 3c    :%<
	cpi	11		;; 099e: fe 0b       ..
	jc	L09a7		;; 09a0: da a7 09    ...
	lxi	h,-1		;; 09a3: 21 ff ff    ...
	ret			;; 09a6: c9          .

L09a7:	call	putfcb		;; 09a7: cd b8 09    ...
	call	getchr		;; 09aa: cd b5 08    ...
	jmp	L0994		;; 09ad: c3 94 09    ...

L09b0:	lxi	h,0		;; 09b0: 21 00 00    ...
	ret			;; 09b3: c9          .

L09b4:	jmp	L090f		;; 09b4: c3 0f 09    ...

	ret			;; 09b7: c9          .

; put byte in deffcb[++L3c25]
putfcb:	lda	L3c25		;; 09b8: 3a 25 3c    :%<
	inr	a		;; 09bb: 3c          <
	sta	L3c25		;; 09bc: 32 25 3c    2%<
	mov	c,a		;; 09bf: 4f          O
	mvi	b,0		;; 09c0: 06 00       ..
	lxi	h,deffcb	;; 09c2: 21 5c 00    .\.
	dad	b		;; 09c5: 09          .
	lda	curchr		;; 09c6: 3a 1f 3c    :.<
	mov	m,a		;; 09c9: 77          w
	ret			;; 09ca: c9          .

L09cb:	lda	curchr		;; 09cb: 3a 1f 3c    :.<
	sui	'0'		;; 09ce: d6 30       .0
	mov	c,a		;; 09d0: 4f          O
	mvi	a,'9'-'0'	;; 09d1: 3e 09       >.
	cmp	c		;; 09d3: b9          .
	jc	L09e5		;; 09d4: da e5 09    ...
	lda	curchr		;; 09d7: 3a 1f 3c    :.<
	sui	'0'		;; 09da: d6 30       .0
	sta	curchr		;; 09dc: 32 1f 3c    2.<
	mvi	a,1		;; 09df: 3e 01       >.
	ret			;; 09e1: c9          .

	jmp	L09fe		;; 09e2: c3 fe 09    ...

L09e5:	lda	curchr		;; 09e5: 3a 1f 3c    :.<
	sui	'A'		;; 09e8: d6 41       .A
	mov	c,a		;; 09ea: 4f          O
	mvi	a,'F'-'A'	;; 09eb: 3e 05       >.
	cmp	c		;; 09ed: b9          .
	jc	L09fe		;; 09ee: da fe 09    ...
	lda	curchr		;; 09f1: 3a 1f 3c    :.<
	sui	'A'		;; 09f4: d6 41       .A
	adi	10		;; 09f6: c6 0a       ..
	sta	curchr		;; 09f8: 32 1f 3c    2.<
	mvi	a,1		;; 09fb: 3e 01       >.
	ret			;; 09fd: c9          .

L09fe:	mvi	a,0		;; 09fe: 3e 00       >.
	ret			;; 0a00: c9          .

L0a01:	lxi	h,0		;; 0a01: 21 00 00    ...
	shld	L3c26		;; 0a04: 22 26 3c    "&<
	call	getchr		;; 0a07: cd b5 08    ...
L0a0a:	call	isdlim		;; 0a0a: cd 8a 08    ...
	rar			;; 0a0d: 1f          .
	jc	L0a36		;; 0a0e: da 36 0a    .6.
	call	L09cb		;; 0a11: cd cb 09    ...
	rar			;; 0a14: 1f          .
	jnc	L0a2d		;; 0a15: d2 2d 0a    .-.
	lhld	L3c26		;; 0a18: 2a 26 3c    *&<
	dad	h		;; 0a1b: 29          )
	dad	h		;; 0a1c: 29          )
	dad	h		;; 0a1d: 29          )
	dad	h		;; 0a1e: 29          )
	push	h		;; 0a1f: e5          .
	lhld	curchr		;; 0a20: 2a 1f 3c    *.<
	mvi	h,0		;; 0a23: 26 00       &.
	pop	b		;; 0a25: c1          .
	dad	b		;; 0a26: 09          .
	shld	L3c26		;; 0a27: 22 26 3c    "&<
	jmp	L0a30		;; 0a2a: c3 30 0a    .0.

L0a2d:	call	prtcmd		;; 0a2d: cd 44 08    .D.
L0a30:	call	getchr		;; 0a30: cd b5 08    ...
	jmp	L0a0a		;; 0a33: c3 0a 0a    ...

L0a36:	lhld	L3c26		;; 0a36: 2a 26 3c    *&<
	ret			;; 0a39: c9          .

isdrv:	lda	curchr		;; 0a3a: 3a 1f 3c    :.<
	sui	'A'		;; 0a3d: d6 41       .A
	mov	c,a		;; 0a3f: 4f          O
	mvi	a,15		;; 0a40: 3e 0f       >.
	sub	c		;; 0a42: 91          .
	sbb	a		;; 0a43: 9f          .
	cma			;; 0a44: 2f          /
	ret			;; 0a45: c9          .

; get option A-P
getA2P:	call	getchr		;; 0a46: cd b5 08    ...
	call	isdrv		;; 0a49: cd 3a 0a    .:.
	rar			;; 0a4c: 1f          .
	jnc	L0a57		;; 0a4d: d2 57 0a    .W.
	lda	curchr		;; 0a50: 3a 1f 3c    :.<
	sui	'A'		;; 0a53: d6 41       .A
	inr	a		;; 0a55: 3c          <
	ret			;; 0a56: c9          .

L0a57:	call	prtcmd		;; 0a57: cd 44 08    .D.
	ret			;; 0a5a: c9          .

getAPZ:	call	getchr		;; 0a5b: cd b5 08    ...
	call	isdrv		;; 0a5e: cd 3a 0a    .:.
	rar			;; 0a61: 1f          .
	jnc	L0a6c		;; 0a62: d2 6c 0a    .l.
	lda	curchr		;; 0a65: 3a 1f 3c    :.<
	sui	'A'		;; 0a68: d6 41       .A
	inr	a		;; 0a6a: 3c          <
	ret			;; 0a6b: c9          .

L0a6c:	lda	curchr		;; 0a6c: 3a 1f 3c    :.<
	cpi	'Z'		;; 0a6f: fe 5a       .Z
	jnz	L0a77		;; 0a71: c2 77 0a    .w.
	mvi	a,'Z'		;; 0a74: 3e 5a       >Z
	ret			;; 0a76: c9          .

L0a77:	call	prtcmd		;; 0a77: cd 44 08    .D.
	ret			;; 0a7a: c9          .

getXYZ:	call	getchr		;; 0a7b: cd b5 08    ...
	lda	curchr		;; 0a7e: 3a 1f 3c    :.<
	sui	'X'		;; 0a81: d6 58       .X
	mov	c,a		;; 0a83: 4f          O
	mvi	a,'Z'-'X'	;; 0a84: 3e 02       >.
	cmp	c		;; 0a86: b9          .
	jc	L0a8e		;; 0a87: da 8e 0a    ...
	lda	curchr		;; 0a8a: 3a 1f 3c    :.<
	ret			;; 0a8d: c9          .

L0a8e:	call	prtcmd		;; 0a8e: cd 44 08    .D.
	ret			;; 0a91: c9          .

getops:	lda	curchr		;; 0a92: 3a 1f 3c    :.<
	sui	']'		;; 0a95: d6 5d       .]
	adi	0ffh		;; 0a97: c6 ff       ..
	sbb	a		;; 0a99: 9f          .
	push	psw		;; 0a9a: f5          .
	lda	curchr		;; 0a9b: 3a 1f 3c    :.<
	sui	cr		;; 0a9e: d6 0d       ..
	adi	0ffh		;; 0aa0: c6 ff       ..
	sbb	a		;; 0aa2: 9f          .
	pop	b		;; 0aa3: c1          .
	mov	c,b		;; 0aa4: 48          H
	ana	c		;; 0aa5: a1          .
	rar			;; 0aa6: 1f          .
	jnc	L0ca0		;; 0aa7: d2 a0 0c    ...
	call	skipb		;; 0aaa: cd d0 08    ...
	lda	curchr		;; 0aad: 3a 1f 3c    :.<
	cpi	'S'		;; 0ab0: fe 53       .S
	jnz	L0ac0		;; 0ab2: c2 c0 0a    ...
	lxi	h,L3a5f		;; 0ab5: 21 5f 3a    ._:
	mvi	m,1		;; 0ab8: 36 01       6.
	call	getchr		;; 0aba: cd b5 08    ...
	jmp	L0c9d		;; 0abd: c3 9d 0c    ...

L0ac0:	lda	curchr		;; 0ac0: 3a 1f 3c    :.<
	cpi	'B'		;; 0ac3: fe 42       .B
	jnz	L0ad8		;; 0ac5: c2 d8 0a    ...
	lxi	h,L3972		;; 0ac8: 21 72 39    .r9
	mvi	m,001h		;; 0acb: 36 01       6.
	lxi	h,prlflg		;; 0acd: 21 6f 39    .o9
	mvi	m,003h		;; 0ad0: 36 03       6.
	call	getchr		;; 0ad2: cd b5 08    ...
	jmp	L0c9d		;; 0ad5: c3 9d 0c    ...

L0ad8:	lda	curchr		;; 0ad8: 3a 1f 3c    :.<
	cpi	'P'		;; 0adb: fe 50       .P
	jnz	L0aee		;; 0add: c2 ee 0a    ...
	lxi	h,L3a43		;; 0ae0: 21 43 3a    .C:
	mvi	m,001h		;; 0ae3: 36 01       6.
	call	L0a01		;; 0ae5: cd 01 0a    ...
	shld	L3a46		;; 0ae8: 22 46 3a    "F:
	jmp	L0c9d		;; 0aeb: c3 9d 0c    ...

L0aee:	lda	curchr		;; 0aee: 3a 1f 3c    :.<
	cpi	'D'		;; 0af1: fe 44       .D
	jnz	L0b04		;; 0af3: c2 04 0b    ...
	lxi	h,L3a44		;; 0af6: 21 44 3a    .D:
	mvi	m,001h		;; 0af9: 36 01       6.
	call	L0a01		;; 0afb: cd 01 0a    ...
	shld	L3a48		;; 0afe: 22 48 3a    "H:
	jmp	L0c9d		;; 0b01: c3 9d 0c    ...

L0b04:	lda	curchr		;; 0b04: 3a 1f 3c    :.<
	cpi	'L'		;; 0b07: fe 4c       .L
	jnz	L0b15		;; 0b09: c2 15 0b    ...
	call	L0a01		;; 0b0c: cd 01 0a    ...
	shld	L3970		;; 0b0f: 22 70 39    "p9
	jmp	L0c9d		;; 0b12: c3 9d 0c    ...

L0b15:	lda	curchr		;; 0b15: 3a 1f 3c    :.<
	cpi	'M'		;; 0b18: fe 4d       .M
	jnz	L0b26		;; 0b1a: c2 26 0b    .&.
	call	L0a01		;; 0b1d: cd 01 0a    ...
	shld	L396d		;; 0b20: 22 6d 39    "m9
	jmp	L0c9d		;; 0b23: c3 9d 0c    ...

L0b26:	lda	curchr		;; 0b26: 3a 1f 3c    :.<
	cpi	'O'		;; 0b29: fe 4f       .O
	jnz	L0b7a		;; 0b2b: c2 7a 0b    .z.
	call	getchr		;; 0b2e: cd b5 08    ...
	lda	curchr		;; 0b31: 3a 1f 3c    :.<
	cpi	'P'		;; 0b34: fe 50       .P
	jnz	L0b41		;; 0b36: c2 41 0b    .A.
	lxi	h,prlflg		;; 0b39: 21 6f 39    .o9
	mvi	m,1		;; 0b3c: 36 01       6.
	jmp	L0b74		;; 0b3e: c3 74 0b    .t.

L0b41:	lda	curchr		;; 0b41: 3a 1f 3c    :.<
	cpi	'C'		;; 0b44: fe 43       .C
	jnz	L0b51		;; 0b46: c2 51 0b    .Q.
	lxi	h,prlflg		;; 0b49: 21 6f 39    .o9
	mvi	m,0		;; 0b4c: 36 00       6.
	jmp	L0b74		;; 0b4e: c3 74 0b    .t.

L0b51:	lda	curchr		;; 0b51: 3a 1f 3c    :.<
	cpi	'R'		;; 0b54: fe 52       .R
	jnz	L0b61		;; 0b56: c2 61 0b    .a.
	lxi	h,prlflg		;; 0b59: 21 6f 39    .o9
	mvi	m,2		;; 0b5c: 36 02       6.
	jmp	L0b74		;; 0b5e: c3 74 0b    .t.

L0b61:	lda	curchr		;; 0b61: 3a 1f 3c    :.<
	cpi	'S'		;; 0b64: fe 53       .S
	jnz	L0b71		;; 0b66: c2 71 0b    .q.
	lxi	h,prlflg		;; 0b69: 21 6f 39    .o9
	mvi	m,3		;; 0b6c: 36 03       6.
	jmp	L0b74		;; 0b6e: c3 74 0b    .t.

L0b71:	call	prtcmd		;; 0b71: cd 44 08    .D.
L0b74:	call	getchr		;; 0b74: cd b5 08    ...
	jmp	L0c9d		;; 0b77: c3 9d 0c    ...

L0b7a:	lda	curchr		;; 0b7a: 3a 1f 3c    :.<
	cpi	'A'		;; 0b7d: fe 41       .A
	jnz	L0b8d		;; 0b7f: c2 8d 0b    ...
	lxi	h,L0188		;; 0b82: 21 88 01    ...
	mvi	m,001h		;; 0b85: 36 01       6.
	call	getchr		;; 0b87: cd b5 08    ...
	jmp	L0c9d		;; 0b8a: c3 9d 0c    ...

L0b8d:	lda	curchr		;; 0b8d: 3a 1f 3c    :.<
	cpi	'Q'		;; 0b90: fe 51       .Q
	jnz	L0ba0		;; 0b92: c2 a0 0b    ...
	lxi	h,L397a		;; 0b95: 21 7a 39    .z9
	mvi	m,000h		;; 0b98: 36 00       6.
	call	getchr		;; 0b9a: cd b5 08    ...
	jmp	L0c9d		;; 0b9d: c3 9d 0c    ...

L0ba0:	lda	curchr		;; 0ba0: 3a 1f 3c    :.<
	cpi	'G'		;; 0ba3: fe 47       .G
	jnz	L0be2		;; 0ba5: c2 e2 0b    ...
	lxi	h,L3a45		;; 0ba8: 21 45 3a    .E:
	mvi	m,1		;; 0bab: 36 01       6.
	call	getchr		;; 0bad: cd b5 08    ...
	lxi	h,L3a51		;; 0bb0: 21 51 3a    .Q:
	mvi	m,0		;; 0bb3: 36 00       6.
L0bb5:	call	isdlim		;; 0bb5: cd 8a 08    ...
	rar			;; 0bb8: 1f          .
	jc	L0bdf		;; 0bb9: da df 0b    ...
	mvi	a,5		;; 0bbc: 3e 05       >.
	lxi	h,L3a51		;; 0bbe: 21 51 3a    .Q:
	cmp	m		;; 0bc1: be          .
	jnc	L0bc8		;; 0bc2: d2 c8 0b    ...
	call	prtcmd		;; 0bc5: cd 44 08    .D.
L0bc8:	lhld	L3a51		;; 0bc8: 2a 51 3a    *Q:
	mvi	h,0		;; 0bcb: 26 00       &.
	lxi	b,L3a4a		;; 0bcd: 01 4a 3a    .J:
	dad	b		;; 0bd0: 09          .
	lda	curchr		;; 0bd1: 3a 1f 3c    :.<
	mov	m,a		;; 0bd4: 77          w
	lxi	h,L3a51		;; 0bd5: 21 51 3a    .Q:
	inr	m		;; 0bd8: 34          4
	call	getchr		;; 0bd9: cd b5 08    ...
	jmp	L0bb5		;; 0bdc: c3 b5 0b    ...

L0bdf:	jmp	L0c9d		;; 0bdf: c3 9d 0c    ...

L0be2:	lda	curchr		;; 0be2: 3a 1f 3c    :.<
	cpi	'$'		;; 0be5: fe 24       .$
	jnz	L0c66		;; 0be7: c2 66 0c    .f.
	call	skipb		;; 0bea: cd d0 08    ...
L0bed:	lda	curchr		;; 0bed: 3a 1f 3c    :.<
	sui	','		;; 0bf0: d6 2c       .,
	adi	0ffh		;; 0bf2: c6 ff       ..
	sbb	a		;; 0bf4: 9f          .
	push	psw		;; 0bf5: f5          .
	lda	curchr		;; 0bf6: 3a 1f 3c    :.<
	sui	']'		;; 0bf9: d6 5d       .]
	adi	0ffh		;; 0bfb: c6 ff       ..
	sbb	a		;; 0bfd: 9f          .
	pop	b		;; 0bfe: c1          .
	mov	c,b		;; 0bff: 48          H
	ana	c		;; 0c00: a1          .
	rar			;; 0c01: 1f          .
	jnc	L0c63		;; 0c02: d2 63 0c    .c.
	lda	curchr		;; 0c05: 3a 1f 3c    :.<
	cpi	'C'		;; 0c08: fe 43       .C
	jnz	L0c16		;; 0c0a: c2 16 0c    ...
	call	getXYZ		;; 0c0d: cd 7b 0a    .{.
	sta	condst		;; 0c10: 32 74 39    2t9
	jmp	L0c5d		;; 0c13: c3 5d 0c    .].

L0c16:	lda	curchr		;; 0c16: 3a 1f 3c    :.<
	cpi	'I'		;; 0c19: fe 49       .I
	jnz	L0c27		;; 0c1b: c2 27 0c    .'.
	call	getA2P		;; 0c1e: cd 46 0a    .F.
	sta	intdst		;; 0c21: 32 75 39    2u9
	jmp	L0c5d		;; 0c24: c3 5d 0c    .].

L0c27:	lda	curchr		;; 0c27: 3a 1f 3c    :.<
	cpi	'L'		;; 0c2a: fe 4c       .L
	jnz	L0c38		;; 0c2c: c2 38 0c    .8.
	call	getA2P		;; 0c2f: cd 46 0a    .F.
	sta	libdst		;; 0c32: 32 76 39    2v9
	jmp	L0c5d		;; 0c35: c3 5d 0c    .].

L0c38:	lda	curchr		;; 0c38: 3a 1f 3c    :.<
	cpi	'O'		;; 0c3b: fe 4f       .O
	jnz	L0c49		;; 0c3d: c2 49 0c    .I.
	call	getAPZ		;; 0c40: cd 5b 0a    .[.
	sta	objdst		;; 0c43: 32 77 39    2w9
	jmp	L0c5d		;; 0c46: c3 5d 0c    .].

L0c49:	lda	curchr		;; 0c49: 3a 1f 3c    :.<
	cpi	'S'		;; 0c4c: fe 53       .S
	jnz	L0c5a		;; 0c4e: c2 5a 0c    .Z.
	call	getAPZ		;; 0c51: cd 5b 0a    .[.
	sta	symdst		;; 0c54: 32 78 39    2x9
	jmp	L0c5d		;; 0c57: c3 5d 0c    .].

L0c5a:	call	prtcmd		;; 0c5a: cd 44 08    .D.
L0c5d:	call	skipb		;; 0c5d: cd d0 08    ...
	jmp	L0bed		;; 0c60: c3 ed 0b    ...

L0c63:	jmp	L0c9d		;; 0c63: c3 9d 0c    ...

L0c66:	lda	curchr		;; 0c66: 3a 1f 3c    :.<
	cpi	'N'		;; 0c69: fe 4e       .N
	jnz	L0c9a		;; 0c6b: c2 9a 0c    ...
	call	getchr		;; 0c6e: cd b5 08    ...
	lda	curchr		;; 0c71: 3a 1f 3c    :.<
	cpi	'L'		;; 0c74: fe 4c       .L
	jnz	L0c81		;; 0c76: c2 81 0c    ...
	lxi	h,condst	;; 0c79: 21 74 39    .t9
	mvi	m,'Z'		;; 0c7c: 36 5a       6Z
	jmp	L0c94		;; 0c7e: c3 94 0c    ...

L0c81:	lda	curchr		;; 0c81: 3a 1f 3c    :.<
	cpi	'R'		;; 0c84: fe 52       .R
	jnz	L0c91		;; 0c86: c2 91 0c    ...
	lxi	h,symdst	;; 0c89: 21 78 39    .x9
	mvi	m,'Z'		;; 0c8c: 36 5a       6Z
	jmp	L0c94		;; 0c8e: c3 94 0c    ...

L0c91:	call	prtcmd		;; 0c91: cd 44 08    .D.
L0c94:	call	getchr		;; 0c94: cd b5 08    ...
	jmp	L0c9d		;; 0c97: c3 9d 0c    ...

L0c9a:	call	prtcmd		;; 0c9a: cd 44 08    .D.
L0c9d:	jmp	getops		;; 0c9d: c3 92 0a    ...

L0ca0:	lda	curchr		;; 0ca0: 3a 1f 3c    :.<
	cpi	cr		;; 0ca3: fe 0d       ..
	jz	L0cab		;; 0ca5: ca ab 0c    ...
	call	getchr		;; 0ca8: cd b5 08    ...
L0cab:	ret			;; 0cab: c9          .

getfil:	lxi	h,L3a5f		;; 0cac: 21 5f 3a    ._:
	mvi	m,0		;; 0caf: 36 00       6.
	call	inifcb		;; 0cb1: cd e2 08    ...
	lxi	d,-1		;; 0cb4: 11 ff ff    ...
	call	subx		;; 0cb7: cd 97 38    ..8
	ora	l		;; 0cba: b5          .
	jnz	L0cc1		;; 0cbb: c2 c1 0c    ...
	call	prtcmd		;; 0cbe: cd 44 08    .D.
L0cc1:	lda	curchr		;; 0cc1: 3a 1f 3c    :.<
	cpi	' '		;; 0cc4: fe 20       . 
	jnz	L0ccc		;; 0cc6: c2 cc 0c    ...
	call	skipb		;; 0cc9: cd d0 08    ...
L0ccc:	lda	curchr		;; 0ccc: 3a 1f 3c    :.<
	cpi	'['		;; 0ccf: fe 5b       .[
	jnz	L0cd7		;; 0cd1: c2 d7 0c    ...
	call	getops		;; 0cd4: cd 92 0a    ...
L0cd7:	lda	curchr		;; 0cd7: 3a 1f 3c    :.<
	cpi	' '		;; 0cda: fe 20       . 
	jnz	L0ce2		;; 0cdc: c2 e2 0c    ...
	call	skipb		;; 0cdf: cd d0 08    ...
L0ce2:	ret			;; 0ce2: c9          .

L0ce3:	lhld	L3a1d		;; 0ce3: 2a 1d 3a    *.:
	inx	h		;; 0ce6: 23          #
	shld	L3a1d		;; 0ce7: 22 1d 3a    ".:
	xchg			;; 0cea: eb          .
	lxi	h,L3a1f		;; 0ceb: 21 1f 3a    ..:
	call	L38b9		;; 0cee: cd b9 38    ..8
	jc	L0d09		;; 0cf1: da 09 0d    ...
	lxi	h,0		;; 0cf4: 21 00 00    ...
	shld	L3a1d		;; 0cf7: 22 1d 3a    ".:
	lxi	b,L4086		;; 0cfa: 01 86 40    ..@
	push	b		;; 0cfd: c5          .
	lhld	L3a1f		;; 0cfe: 2a 1f 3a    *.:
	mov	b,h		;; 0d01: 44          D
	mov	c,l		;; 0d02: 4d          M
	lxi	d,L39fc		;; 0d03: 11 fc 39    ..9
	call	rdfile		;; 0d06: cd 8f 35    ..5
L0d09:	lhld	L3a1d		;; 0d09: 2a 1d 3a    *.:
	lxi	b,L4086		;; 0d0c: 01 86 40    ..@
	dad	b		;; 0d0f: 09          .
	mov	a,m		;; 0d10: 7e          ~
	ret			;; 0d11: c9          .

L0d12:	call	L0ce3		;; 0d12: cd e3 0c    ...
	lxi	h,L39fa		;; 0d15: 21 fa 39    ..9
	add	m		;; 0d18: 86          .
	sta	L3c28		;; 0d19: 32 28 3c    2(<
	call	L0ce3		;; 0d1c: cd e3 0c    ...
	lxi	h,L39fb		;; 0d1f: 21 fb 39    ..9
	add	m		;; 0d22: 86          .
	sta	L3c29		;; 0d23: 32 29 3c    2)<
	cpi	080h		;; 0d26: fe 80       ..
	jc	L0d37		;; 0d28: da 37 0d    .7.
	lda	L3c29		;; 0d2b: 3a 29 3c    :)<
	sui	080h		;; 0d2e: d6 80       ..
	sta	L3c29		;; 0d30: 32 29 3c    2)<
	lxi	h,L3c28		;; 0d33: 21 28 3c    .(<
	inr	m		;; 0d36: 34          4
L0d37:	call	L0ce3		;; 0d37: cd e3 0c    ...
	sta	L3c2a		;; 0d3a: 32 2a 3c    2*<
	ret			;; 0d3d: c9          .

L0d3e:	call	L0d12		;; 0d3e: cd 12 0d    ...
	lxi	h,rellen		;; 0d41: 21 a1 3a    ..:
	mvi	m,000h		;; 0d44: 36 00       6.
L0d46:	call	L0ce3		;; 0d46: cd e3 0c    ...
	sta	L3c2d		;; 0d49: 32 2d 3c    2-<
	cpi	0feh		;; 0d4c: fe fe       ..
	jnc	L0d73		;; 0d4e: d2 73 0d    .s.
	lhld	rellen		;; 0d51: 2a a1 3a    *.:
	mvi	h,000h		;; 0d54: 26 00       &.
	lxi	b,rellab		;; 0d56: 01 a2 3a    ..:
	dad	b		;; 0d59: 09          .
	lda	L3c2d		;; 0d5a: 3a 2d 3c    :-<
	mov	m,a		;; 0d5d: 77          w
	lda	rellen		;; 0d5e: 3a a1 3a    :.:
	inr	a		;; 0d61: 3c          <
	sta	rellen		;; 0d62: 32 a1 3a    2.:
	cpi	008h		;; 0d65: fe 08       ..
	jc	L0d70		;; 0d67: da 70 0d    .p.
	lxi	b,L3da9		;; 0d6a: 01 a9 3d    ..=
	call	L36e2		;; 0d6d: cd e2 36    ..6
L0d70:	jmp	L0d46		;; 0d70: c3 46 0d    .F.

L0d73:	ret			;; 0d73: c9          .

L0d74:	lxi	d,00080h	;; 0d74: 11 80 00    ...
	lhld	L3c28		;; 0d77: 2a 28 3c    *(<
	mvi	h,000h		;; 0d7a: 26 00       &.
	call	mult		;; 0d7c: cd 5c 38    .\8
	push	h		;; 0d7f: e5          .
	lhld	L3c29		;; 0d80: 2a 29 3c    *)<
	mvi	h,000h		;; 0d83: 26 00       &.
	pop	b		;; 0d85: c1          .
	dad	b		;; 0d86: 09          .
	shld	L3c2b		;; 0d87: 22 2b 3c    "+<
	xchg			;; 0d8a: eb          .
	lxi	h,L39f6		;; 0d8b: 21 f6 39    ..9
	call	L38b9		;; 0d8e: cd b9 38    ..8
	sbb	a		;; 0d91: 9f          .
	cma			;; 0d92: 2f          /
	lxi	d,L39f8		;; 0d93: 11 f8 39    ..9
	lxi	b,L3c2b		;; 0d96: 01 2b 3c    .+<
	push	psw		;; 0d99: f5          .
	call	subxxx		;; 0d9a: cd 9e 38    ..8
	sbb	a		;; 0d9d: 9f          .
	cma			;; 0d9e: 2f          /
	pop	b		;; 0d9f: c1          .
	mov	c,b		;; 0da0: 48          H
	ana	c		;; 0da1: a1          .
	rar			;; 0da2: 1f          .
	jnc	L0dc4		;; 0da3: d2 c4 0d    ...
	lxi	b,L39f6		;; 0da6: 01 f6 39    ..9
	lxi	d,L3c2b		;; 0da9: 11 2b 3c    .+<
	call	subxxx		;; 0dac: cd 9e 38    ..8
	lxi	d,00080h	;; 0daf: 11 80 00    ...
	call	mult		;; 0db2: cd 5c 38    .\8
	push	h		;; 0db5: e5          .
	lhld	L3c2a		;; 0db6: 2a 2a 3c    **<
	mvi	h,000h		;; 0db9: 26 00       &.
	pop	b		;; 0dbb: c1          .
	dad	b		;; 0dbc: 09          .
	dcx	h		;; 0dbd: 2b          +
	shld	L3a31		;; 0dbe: 22 31 3a    "1:
	jmp	L0dfc		;; 0dc1: c3 fc 0d    ...

L0dc4:	lxi	h,deffcb+12	;; 0dc4: 21 68 00    .h.
	lda	L3c28		;; 0dc7: 3a 28 3c    :(<
	cmp	m		;; 0dca: be          .
	jz	L0dea		;; 0dcb: ca ea 0d    ...
	lda	L3c28		;; 0dce: 3a 28 3c    :(<
	sta	deffcb+12	;; 0dd1: 32 68 00    2h.
	lxi	b,deffcb	;; 0dd4: 01 5c 00    .\.
	call	fopen		;; 0dd7: cd 95 36    ..6
	cpi	0ffh		;; 0dda: fe ff       ..
	jnz	L0de5		;; 0ddc: c2 e5 0d    ...
	lxi	b,L3da9		;; 0ddf: 01 a9 3d    ..=
	call	L36e2		;; 0de2: cd e2 36    ..6
L0de5:	lxi	h,deffcb+32	;; 0de5: 21 7c 00    .|.
	mvi	m,0ffh		;; 0de8: 36 ff       6.
L0dea:	lda	L3c29		;; 0dea: 3a 29 3c    :)<
	sta	deffcb+32	;; 0ded: 32 7c 00    2|.
	call	L202f		;; 0df0: cd 2f 20    ./ 
	lhld	L3c2a		;; 0df3: 2a 2a 3c    **<
	mvi	h,000h		;; 0df6: 26 00       &.
	dcx	h		;; 0df8: 2b          +
	shld	L3a31		;; 0df9: 22 31 3a    "1:
L0dfc:	ret			;; 0dfc: c9          .

L0dfd:	lhld	L3a1f		;; 0dfd: 2a 1f 3a    *.:
	shld	L3a1d		;; 0e00: 22 1d 3a    ".:
	call	L0d3e		;; 0e03: cd 3e 0d    .>.
L0e06:	mvi	a,0		;; 0e06: 3e 00       >.
	lxi	h,rellen	;; 0e08: 21 a1 3a    ..:
	cmp	m		;; 0e0b: be          .
	jnc	L0e2a		;; 0e0c: d2 2a 0e    .*.
	lxi	h,L3a5e		;; 0e0f: 21 5e 3a    .^:
	mvi	m,0		;; 0e12: 36 00       6.
	call	L222b		;; 0e14: cd 2b 22    .+"
	lda	L3a5e		;; 0e17: 3a 5e 3a    :^:
	rar			;; 0e1a: 1f          .
	jnc	L0e24		;; 0e1b: d2 24 0e    .$.
	call	L0d74		;; 0e1e: cd 74 0d    .t.
	call	L2738		;; 0e21: cd 38 27    .8'
L0e24:	call	L0d3e		;; 0e24: cd 3e 0d    .>.
	jmp	L0e06		;; 0e27: c3 06 0e    ...

L0e2a:	ret			;; 0e2a: c9          .

L0e2b:	lxi	b,6		;; 0e2b: 01 06 00    ...
	lhld	L3c30		;; 0e2e: 2a 30 3c    *0<
	dad	b		;; 0e31: 09          .
	mov	a,m		;; 0e32: 7e          ~
	rar			;; 0e33: 1f          .
	jc	L0e4c		;; 0e34: da 4c 0e    .L.
	lxi	b,7		;; 0e37: 01 07 00    ...
	lhld	L3c30		;; 0e3a: 2a 30 3c    *0<
	dad	b		;; 0e3d: 09          .
	mov	b,h		;; 0e3e: 44          D
	mov	c,l		;; 0e3f: 4d          M
	call	frcnew		;; 0e40: cd 42 35    .B5
	lxi	b,6		;; 0e43: 01 06 00    ...
	lhld	L3c30		;; 0e46: 2a 30 3c    *0<
	dad	b		;; 0e49: 09          .
	mvi	m,1		;; 0e4a: 36 01       6.
L0e4c:	lhld	L3c30		;; 0e4c: 2a 30 3c    *0<
	mov	c,m		;; 0e4f: 4e          N
	inx	h		;; 0e50: 23          #
	mov	b,m		;; 0e51: 46          F
	push	b		;; 0e52: c5          .
	lxi	b,4		;; 0e53: 01 04 00    ...
	lhld	L3c30		;; 0e56: 2a 30 3c    *0<
	dad	b		;; 0e59: 09          .
	lxi	b,7		;; 0e5a: 01 07 00    ...
	push	h		;; 0e5d: e5          .
	lhld	L3c30		;; 0e5e: 2a 30 3c    *0<
	dad	b		;; 0e61: 09          .
	xthl			;; 0e62: e3          .
	mov	c,m		;; 0e63: 4e          N
	inx	h		;; 0e64: 23          #
	mov	b,m		;; 0e65: 46          F
	pop	d		;; 0e66: d1          .
	call	wrfile		;; 0e67: cd 94 35    ..5
	ret			;; 0e6a: c9          .

L0e6b:	lxi	h,L3c32		;; 0e6b: 21 32 3c    .2<
	mov	m,c		;; 0e6e: 71          q
	lhld	L3c30		;; 0e6f: 2a 30 3c    *0<
	inx	h		;; 0e72: 23          #
	inx	h		;; 0e73: 23          #
	mov	c,m		;; 0e74: 4e          N
	inx	h		;; 0e75: 23          #
	mov	b,m		;; 0e76: 46          F
	lhld	L3c2e		;; 0e77: 2a 2e 3c    *.<
	dad	b		;; 0e7a: 09          .
	lda	L3c32		;; 0e7b: 3a 32 3c    :2<
	mov	m,a		;; 0e7e: 77          w
	lhld	L3c30		;; 0e7f: 2a 30 3c    *0<
	inx	h		;; 0e82: 23          #
	inx	h		;; 0e83: 23          #
	mov	c,m		;; 0e84: 4e          N
	inx	h		;; 0e85: 23          #
	mov	b,m		;; 0e86: 46          F
	inx	b		;; 0e87: 03          .
	dcx	h		;; 0e88: 2b          +
	mov	m,c		;; 0e89: 71          q
	inx	h		;; 0e8a: 23          #
	mov	m,b		;; 0e8b: 70          p
	push	b		;; 0e8c: c5          .
	lxi	b,00004h	;; 0e8d: 01 04 00    ...
	lhld	L3c30		;; 0e90: 2a 30 3c    *0<
	dad	b		;; 0e93: 09          .
	pop	d		;; 0e94: d1          .
	call	L38b9		;; 0e95: cd b9 38    ..8
	jc	L0ea9		;; 0e98: da a9 0e    ...
	call	L0e2b		;; 0e9b: cd 2b 0e    .+.
	lhld	L3c30		;; 0e9e: 2a 30 3c    *0<
	inx	h		;; 0ea1: 23          #
	inx	h		;; 0ea2: 23          #
	mvi	a,000h		;; 0ea3: 3e 00       >.
	mov	m,a		;; 0ea5: 77          w
	inx	h		;; 0ea6: 23          #
	mvi	m,000h		;; 0ea7: 36 00       6.
L0ea9:	ret			;; 0ea9: c9          .

L0eaa:	lxi	h,L3c34		;; 0eaa: 21 34 3c    .4<
	mov	m,b		;; 0ead: 70          p
	dcx	h		;; 0eae: 2b          +
	mov	m,c		;; 0eaf: 71          q
	lhld	L3c33		;; 0eb0: 2a 33 3c    *3<
	mov	a,l		;; 0eb3: 7d          }
	mov	c,a		;; 0eb4: 4f          O
	call	L0e6b		;; 0eb5: cd 6b 0e    .k.
	lhld	L3c33		;; 0eb8: 2a 33 3c    *3<
	mov	a,h		;; 0ebb: 7c          |
	mov	c,a		;; 0ebc: 4f          O
	call	L0e6b		;; 0ebd: cd 6b 0e    .k.
	ret			;; 0ec0: c9          .

L0ec1:	lhld	L3c30		;; 0ec1: 2a 30 3c    *0<
	mov	c,m		;; 0ec4: 4e          N
	inx	h		;; 0ec5: 23          #
	mov	b,m		;; 0ec6: 46          F
	push	b		;; 0ec7: c5          .
	lxi	b,00004h	;; 0ec8: 01 04 00    ...
	lhld	L3c30		;; 0ecb: 2a 30 3c    *0<
	dad	b		;; 0ece: 09          .
	lxi	b,00007h	;; 0ecf: 01 07 00    ...
	push	h		;; 0ed2: e5          .
	lhld	L3c30		;; 0ed3: 2a 30 3c    *0<
	dad	b		;; 0ed6: 09          .
	xthl			;; 0ed7: e3          .
	mov	c,m		;; 0ed8: 4e          N
	inx	h		;; 0ed9: 23          #
	mov	b,m		;; 0eda: 46          F
	pop	d		;; 0edb: d1          .
	call	rdfile		;; 0edc: cd 8f 35    ..5
	ret			;; 0edf: c9          .

L0ee0:	lhld	L3c30		;; 0ee0: 2a 30 3c    *0<
	inx	h		;; 0ee3: 23          #
	inx	h		;; 0ee4: 23          #
	mov	c,m		;; 0ee5: 4e          N
	inx	h		;; 0ee6: 23          #
	mov	b,m		;; 0ee7: 46          F
	inx	b		;; 0ee8: 03          .
	dcx	h		;; 0ee9: 2b          +
	mov	m,c		;; 0eea: 71          q
	inx	h		;; 0eeb: 23          #
	mov	m,b		;; 0eec: 70          p
	push	b		;; 0eed: c5          .
	lxi	b,00004h	;; 0eee: 01 04 00    ...
	lhld	L3c30		;; 0ef1: 2a 30 3c    *0<
	dad	b		;; 0ef4: 09          .
	pop	d		;; 0ef5: d1          .
	call	L38b9		;; 0ef6: cd b9 38    ..8
	jc	L0f0a		;; 0ef9: da 0a 0f    ...
	call	L0ec1		;; 0efc: cd c1 0e    ...
	lhld	L3c30		;; 0eff: 2a 30 3c    *0<
	inx	h		;; 0f02: 23          #
	inx	h		;; 0f03: 23          #
	mvi	a,000h		;; 0f04: 3e 00       >.
	mov	m,a		;; 0f06: 77          w
	inx	h		;; 0f07: 23          #
	mvi	m,000h		;; 0f08: 36 00       6.
L0f0a:	lhld	L3c30		;; 0f0a: 2a 30 3c    *0<
	inx	h		;; 0f0d: 23          #
	inx	h		;; 0f0e: 23          #
	mov	c,m		;; 0f0f: 4e          N
	inx	h		;; 0f10: 23          #
	mov	b,m		;; 0f11: 46          F
	lhld	L3c2e		;; 0f12: 2a 2e 3c    *.<
	dad	b		;; 0f15: 09          .
	mov	a,m		;; 0f16: 7e          ~
	ret			;; 0f17: c9          .

L0f18:	call	L0ee0		;; 0f18: cd e0 0e    ...
	push	psw		;; 0f1b: f5          .
	call	L0ee0		;; 0f1c: cd e0 0e    ...
	mov	c,a		;; 0f1f: 4f          O
	mvi	b,000h		;; 0f20: 06 00       ..
	mov	h,b		;; 0f22: 60          `
	mov	l,c		;; 0f23: 69          i
	mvi	c,008h		;; 0f24: 0e 08       ..
	call	shlx		;; 0f26: cd 7e 38    .~8
	pop	psw		;; 0f29: f1          .
	call	orxa		;; 0f2a: cd 70 38    .p8
	ret			;; 0f2d: c9          .

L0f2e:	lxi	h,L3c36		;; 0f2e: 21 36 3c    .6<
	mov	m,b		;; 0f31: 70          p
	dcx	h		;; 0f32: 2b          +
	mov	m,c		;; 0f33: 71          q
	lhld	L3c35		;; 0f34: 2a 35 3c    *5<
	shld	L3c30		;; 0f37: 22 30 3c    "0<
	mov	e,m		;; 0f3a: 5e          ^
	inx	h		;; 0f3b: 23          #
	mov	d,m		;; 0f3c: 56          V
	xchg			;; 0f3d: eb          .
	shld	L3c2e		;; 0f3e: 22 2e 3c    ".<
	ret			;; 0f41: c9          .

L0f42:	mvi	c,0ffh		;; 0f42: 0e ff       ..
	call	L0e6b		;; 0f44: cd 6b 0e    .k.
	lxi	b,6		;; 0f47: 01 06 00    ...
	lhld	L3c30		;; 0f4a: 2a 30 3c    *0<
	dad	b		;; 0f4d: 09          .
	mov	a,m		;; 0f4e: 7e          ~
	rar			;; 0f4f: 1f          .
	jnc	L0f99		;; 0f50: d2 99 0f    ...
L0f53:	lhld	L3c30		;; 0f53: 2a 30 3c    *0<
	inx	h		;; 0f56: 23          #
	inx	h		;; 0f57: 23          #
	mvi	a,000h		;; 0f58: 3e 00       >.
	call	L38b6		;; 0f5a: cd b6 38    ..8
	ora	l		;; 0f5d: b5          .
	jz	L0f69		;; 0f5e: ca 69 0f    .i.
	mvi	c,01ah		;; 0f61: 0e 1a       ..
	call	L0e6b		;; 0f63: cd 6b 0e    .k.
	jmp	L0f53		;; 0f66: c3 53 0f    .S.

L0f69:	lxi	b,00007h	;; 0f69: 01 07 00    ...
	lhld	L3c30		;; 0f6c: 2a 30 3c    *0<
	dad	b		;; 0f6f: 09          .
	mov	b,h		;; 0f70: 44          D
	mov	c,l		;; 0f71: 4d          M
	call	endfil		;; 0f72: cd 76 35    .v5
	lxi	b,00007h	;; 0f75: 01 07 00    ...
	lhld	L3c30		;; 0f78: 2a 30 3c    *0<
	dad	b		;; 0f7b: 09          .
	mov	b,h		;; 0f7c: 44          D
	mov	c,l		;; 0f7d: 4d          M
	call	L3564		;; 0f7e: cd 64 35    .d5
	lxi	b,00004h	;; 0f81: 01 04 00    ...
	lhld	L3c30		;; 0f84: 2a 30 3c    *0<
	dad	b		;; 0f87: 09          .
	push	h		;; 0f88: e5          .
	lhld	L3c30		;; 0f89: 2a 30 3c    *0<
	inx	h		;; 0f8c: 23          #
	inx	h		;; 0f8d: 23          #
	xthl			;; 0f8e: e3          .
	mov	c,m		;; 0f8f: 4e          N
	inx	h		;; 0f90: 23          #
	mov	b,m		;; 0f91: 46          F
	pop	h		;; 0f92: e1          .
	mov	m,c		;; 0f93: 71          q
	inx	h		;; 0f94: 23          #
	mov	m,b		;; 0f95: 70          p
	jmp	L0fa4		;; 0f96: c3 a4 0f    ...

L0f99:	lhld	L3c30		;; 0f99: 2a 30 3c    *0<
	inx	h		;; 0f9c: 23          #
	inx	h		;; 0f9d: 23          #
	lxi	b,0ffffh	;; 0f9e: 01 ff ff    ...
	mov	m,c		;; 0fa1: 71          q
	inx	h		;; 0fa2: 23          #
	mov	m,b		;; 0fa3: 70          p
L0fa4:	ret			;; 0fa4: c9          .

L0fa5:	lhld	L3a75		;; 0fa5: 2a 75 3a    *u:
	inx	h		;; 0fa8: 23          #
	mov	e,m		;; 0fa9: 5e          ^
	inx	h		;; 0faa: 23          #
	mov	d,m		;; 0fab: 56          V
	xchg			;; 0fac: eb          .
	ret			;; 0fad: c9          .

L0fae:	lxi	b,00003h	;; 0fae: 01 03 00    ...
	lhld	L3a75		;; 0fb1: 2a 75 3a    *u:
	dad	b		;; 0fb4: 09          .
	mov	e,m		;; 0fb5: 5e          ^
	inx	h		;; 0fb6: 23          #
	mov	d,m		;; 0fb7: 56          V
	xchg			;; 0fb8: eb          .
	ret			;; 0fb9: c9          .

L0fba:	lxi	b,5		;; 0fba: 01 05 00    ...
	lhld	L3a75		;; 0fbd: 2a 75 3a    *u:
	dad	b		;; 0fc0: 09          .
	mov	e,m		;; 0fc1: 5e          ^
	inx	h		;; 0fc2: 23          #
	mov	d,m		;; 0fc3: 56          V
	xchg			;; 0fc4: eb          .
	ret			;; 0fc5: c9          .

	lhld	L3a75		;; 0fc6: 2a 75 3a    *u:
	mov	a,m		;; 0fc9: 7e          ~
	ani	0feh		;; 0fca: e6 fe       ..
	rar			;; 0fcc: 1f          .
	rar			;; 0fcd: 1f          .
	ani	001h		;; 0fce: e6 01       ..
	ret			;; 0fd0: c9          .

L0fd1:	lhld	L3a75		;; 0fd1: 2a 75 3a    *u:
	mov	a,m		;; 0fd4: 7e          ~
	ani	0fch		;; 0fd5: e6 fc       ..
	rar			;; 0fd7: 1f          .
	rar			;; 0fd8: 1f          .
	rar			;; 0fd9: 1f          .
	ani	001h		;; 0fda: e6 01       ..
	ret			;; 0fdc: c9          .

L0fdd:	lhld	L3a75		;; 0fdd: 2a 75 3a    *u:
	mvi	a,003h		;; 0fe0: 3e 03       >.
	ana	m		;; 0fe2: a6          .
	ret			;; 0fe3: c9          .

L0fe4:	lhld	L3a75		;; 0fe4: 2a 75 3a    *u:
	mov	a,m		;; 0fe7: 7e          ~
	ret			;; 0fe8: c9          .

L0fe9:	lxi	b,00007h	;; 0fe9: 01 07 00    ...
	lhld	L3a75		;; 0fec: 2a 75 3a    *u:
	dad	b		;; 0fef: 09          .
	mov	e,m		;; 0ff0: 5e          ^
	inx	h		;; 0ff1: 23          #
	mov	d,m		;; 0ff2: 56          V
	xchg			;; 0ff3: eb          .
	ret			;; 0ff4: c9          .

L0ff5:	lxi	b,5		;; 0ff5: 01 05 00    ...
	lhld	L3a77		;; 0ff8: 2a 77 3a    *w:
	dad	b		;; 0ffb: 09          .
	mov	e,m		;; 0ffc: 5e          ^
	inx	h		;; 0ffd: 23          #
	mov	d,m		;; 0ffe: 56          V
	xchg			;; 0fff: eb          .
	ret			;; 1000: c9          .

L1001:	lxi	h,L3c38		;; 1001: 21 38 3c    .8<
	mov	m,b		;; 1004: 70          p
	dcx	h		;; 1005: 2b          +
	mov	m,c		;; 1006: 71          q
	lhld	L3a75		;; 1007: 2a 75 3a    *u:
	inx	h		;; 100a: 23          #
	push	h		;; 100b: e5          .
	lhld	L3c37		;; 100c: 2a 37 3c    *7<
	xchg			;; 100f: eb          .
	pop	h		;; 1010: e1          .
	mov	m,e		;; 1011: 73          s
	inx	h		;; 1012: 23          #
	mov	m,d		;; 1013: 72          r
	ret			;; 1014: c9          .

L1015:	lxi	h,L3c3a		;; 1015: 21 3a 3c    .:<
	mov	m,b		;; 1018: 70          p
	dcx	h		;; 1019: 2b          +
	mov	m,c		;; 101a: 71          q
	lxi	b,00003h	;; 101b: 01 03 00    ...
	lhld	L3a75		;; 101e: 2a 75 3a    *u:
	dad	b		;; 1021: 09          .
	push	h		;; 1022: e5          .
	lhld	L3c39		;; 1023: 2a 39 3c    *9<
	xchg			;; 1026: eb          .
	pop	h		;; 1027: e1          .
	mov	m,e		;; 1028: 73          s
	inx	h		;; 1029: 23          #
	mov	m,d		;; 102a: 72          r
	ret			;; 102b: c9          .

L102c:	lxi	h,L3c3c		;; 102c: 21 3c 3c    .<<
	mov	m,b		;; 102f: 70          p
	dcx	h		;; 1030: 2b          +
	mov	m,c		;; 1031: 71          q
	lxi	b,5		;; 1032: 01 05 00    ...
	lhld	L3a75		;; 1035: 2a 75 3a    *u:
	dad	b		;; 1038: 09          .
	push	h		;; 1039: e5          .
	lhld	L3c3b		;; 103a: 2a 3b 3c    *;<
	xchg			;; 103d: eb          .
	pop	h		;; 103e: e1          .
	mov	m,e		;; 103f: 73          s
	inx	h		;; 1040: 23          #
	mov	m,d		;; 1041: 72          r
	ret			;; 1042: c9          .

L1043:	lxi	h,L3c3d		;; 1043: 21 3d 3c    .=<
	mov	m,c		;; 1046: 71          q
	lhld	L3a75		;; 1047: 2a 75 3a    *u:
	mvi	a,0fbh		;; 104a: 3e fb       >.
	ana	m		;; 104c: a6          .
	push	psw		;; 104d: f5          .
	lda	L3c3d		;; 104e: 3a 3d 3c    :=<
	ani	001h		;; 1051: e6 01       ..
	add	a		;; 1053: 87          .
	add	a		;; 1054: 87          .
	pop	b		;; 1055: c1          .
	mov	c,b		;; 1056: 48          H
	ora	c		;; 1057: b1          .
	mov	m,a		;; 1058: 77          w
	ret			;; 1059: c9          .

L105a:	lxi	h,L3c3e		;; 105a: 21 3e 3c    .><
	mov	m,c		;; 105d: 71          q
	lhld	L3a75		;; 105e: 2a 75 3a    *u:
	mvi	a,0f7h		;; 1061: 3e f7       >.
	ana	m		;; 1063: a6          .
	push	psw		;; 1064: f5          .
	lda	L3c3e		;; 1065: 3a 3e 3c    :><
	ani	001h		;; 1068: e6 01       ..
	add	a		;; 106a: 87          .
	add	a		;; 106b: 87          .
	add	a		;; 106c: 87          .
	pop	b		;; 106d: c1          .
	mov	c,b		;; 106e: 48          H
	ora	c		;; 106f: b1          .
	mov	m,a		;; 1070: 77          w
	ret			;; 1071: c9          .

L1072:	lxi	h,L3c3f		;; 1072: 21 3f 3c    .?<
	mov	m,c		;; 1075: 71          q
	lhld	L3a75		;; 1076: 2a 75 3a    *u:
	mvi	a,0efh		;; 1079: 3e ef       >.
	ana	m		;; 107b: a6          .
	push	psw		;; 107c: f5          .
	lda	L3c3f		;; 107d: 3a 3f 3c    :?<
	ani	001h		;; 1080: e6 01       ..
	add	a		;; 1082: 87          .
	add	a		;; 1083: 87          .
	add	a		;; 1084: 87          .
	add	a		;; 1085: 87          .
	pop	b		;; 1086: c1          .
	mov	c,b		;; 1087: 48          H
	ora	c		;; 1088: b1          .
	mov	m,a		;; 1089: 77          w
	ret			;; 108a: c9          .

L108b:	lxi	h,L3c40		;; 108b: 21 40 3c    .@<
	mov	m,c		;; 108e: 71          q
	lhld	L3a75		;; 108f: 2a 75 3a    *u:
	mvi	a,0fch		;; 1092: 3e fc       >.
	ana	m		;; 1094: a6          .
	push	psw		;; 1095: f5          .
	lda	L3c40		;; 1096: 3a 40 3c    :@<
	ani	003h		;; 1099: e6 03       ..
	pop	b		;; 109b: c1          .
	mov	c,b		;; 109c: 48          H
	ora	c		;; 109d: b1          .
	mov	m,a		;; 109e: 77          w
	ret			;; 109f: c9          .

L10a0:	lxi	h,L3c42		;; 10a0: 21 42 3c    .B<
	mov	m,b		;; 10a3: 70          p
	dcx	h		;; 10a4: 2b          +
	mov	m,c		;; 10a5: 71          q
	lxi	b,00007h	;; 10a6: 01 07 00    ...
	lhld	L3a75		;; 10a9: 2a 75 3a    *u:
	dad	b		;; 10ac: 09          .
	push	h		;; 10ad: e5          .
	lhld	L3c41		;; 10ae: 2a 41 3c    *A<
	xchg			;; 10b1: eb          .
	pop	h		;; 10b2: e1          .
	mov	m,e		;; 10b3: 73          s
	inx	h		;; 10b4: 23          #
	mov	m,d		;; 10b5: 72          r
	ret			;; 10b6: c9          .

L10b7:	lxi	h,L3c44		;; 10b7: 21 44 3c    .D<
	mov	m,b		;; 10ba: 70          p
	dcx	h		;; 10bb: 2b          +
	mov	m,c		;; 10bc: 71          q
	lxi	b,5		;; 10bd: 01 05 00    ...
	lhld	L3a77		;; 10c0: 2a 77 3a    *w:
	dad	b		;; 10c3: 09          .
	push	h		;; 10c4: e5          .
	lhld	L3c43		;; 10c5: 2a 43 3c    *C<
	xchg			;; 10c8: eb          .
	pop	h		;; 10c9: e1          .
	mov	m,e		;; 10ca: 73          s
	inx	h		;; 10cb: 23          #
	mov	m,d		;; 10cc: 72          r
	ret			;; 10cd: c9          .

L10ce:	lxi	h,L3c49		;; 10ce: 21 49 3c    .I<
	mov	m,e		;; 10d1: 73          s
	dcx	h		;; 10d2: 2b          +
	mov	m,b		;; 10d3: 70          p
	dcx	h		;; 10d4: 2b          +
	mov	m,c		;; 10d5: 71          q
	lxi	h,00000h	;; 10d6: 21 00 00    ...
	shld	L3c45		;; 10d9: 22 45 3c    "E<
	lhld	L3c49		;; 10dc: 2a 49 3c    *I<
	mvi	h,000h		;; 10df: 26 00       &.
	lxi	b,L3a69		;; 10e1: 01 69 3a    .i:
	dad	h		;; 10e4: 29          )
	dad	b		;; 10e5: 09          .
	mov	e,m		;; 10e6: 5e          ^
	inx	h		;; 10e7: 23          #
	mov	d,m		;; 10e8: 56          V
	xchg			;; 10e9: eb          .
	shld	L3a75		;; 10ea: 22 75 3a    "u:
	mvi	a,000h		;; 10ed: 3e 00       >.
	call	subxa		;; 10ef: cd 94 38    ..8
	ora	l		;; 10f2: b5          .
	jnz	L10f9		;; 10f3: c2 f9 10    ...
	mvi	a,000h		;; 10f6: 3e 00       >.
	ret			;; 10f8: c9          .

L10f9:	call	L0fa5		;; 10f9: cd a5 0f    ...
	lxi	d,L3c47		;; 10fc: 11 47 3c    .G<
	call	subxx		;; 10ff: cd ae 38    ..8
	jnc	L1127		;; 1102: d2 27 11    .'.
	lhld	L3a75		;; 1105: 2a 75 3a    *u:
	shld	L3a77		;; 1108: 22 77 3a    "w:
	lhld	L3c45		;; 110b: 2a 45 3c    *E<
	inx	h		;; 110e: 23          #
	shld	L3c45		;; 110f: 22 45 3c    "E<
	call	L0fba		;; 1112: cd ba 0f    ...
	shld	L3a75		;; 1115: 22 75 3a    "u:
	mvi	a,000h		;; 1118: 3e 00       >.
	call	subxa		;; 111a: cd 94 38    ..8
	ora	l		;; 111d: b5          .
	jnz	L1124		;; 111e: c2 24 11    .$.
	mvi	a,000h		;; 1121: 3e 00       >.
	ret			;; 1123: c9          .

L1124:	jmp	L10f9		;; 1124: c3 f9 10    ...

L1127:	call	L0fa5		;; 1127: cd a5 0f    ...
	lxi	d,L3c47		;; 112a: 11 47 3c    .G<
	call	subxx		;; 112d: cd ae 38    ..8
	ora	l		;; 1130: b5          .
	sui	001h		;; 1131: d6 01       ..
	sbb	a		;; 1133: 9f          .
	ret			;; 1134: c9          .

L1135:	lxi	h,L3c54		;; 1135: 21 54 3c    .T<
	mov	m,e		;; 1138: 73          s
	dcx	h		;; 1139: 2b          +
	mov	m,b		;; 113a: 70          p
	dcx	h		;; 113b: 2b          +
	mov	m,c		;; 113c: 71          q
	dcx	h		;; 113d: 2b          +
	pop	d		;; 113e: d1          .
	pop	b		;; 113f: c1          .
	mov	m,c		;; 1140: 71          q
	dcx	h		;; 1141: 2b          +
	pop	b		;; 1142: c1          .
	mov	m,c		;; 1143: 71          q
	dcx	h		;; 1144: 2b          +
	pop	b		;; 1145: c1          .
	mov	m,c		;; 1146: 71          q
	dcx	h		;; 1147: 2b          +
	pop	b		;; 1148: c1          .
	mov	m,c		;; 1149: 71          q
	dcx	h		;; 114a: 2b          +
	pop	b		;; 114b: c1          .
	mov	m,b		;; 114c: 70          p
	dcx	h		;; 114d: 2b          +
	mov	m,c		;; 114e: 71          q
	dcx	h		;; 114f: 2b          +
	pop	b		;; 1150: c1          .
	mov	m,b		;; 1151: 70          p
	dcx	h		;; 1152: 2b          +
	mov	m,c		;; 1153: 71          q
	push	d		;; 1154: d5          .
	mvi	a,000h		;; 1155: 3e 00       >.
	lxi	d,L3c4a		;; 1157: 11 4a 3c    .J<
	call	subxxa		;; 115a: cd ab 38    ..8
	ora	l		;; 115d: b5          .
	sui	001h		;; 115e: d6 01       ..
	sbb	a		;; 1160: 9f          .
	push	psw		;; 1161: f5          .
	lda	L3c50		;; 1162: 3a 50 3c    :P<
	sui	000h		;; 1165: d6 00       ..
	sui	001h		;; 1167: d6 01       ..
	sbb	a		;; 1169: 9f          .
	pop	b		;; 116a: c1          .
	mov	c,b		;; 116b: 48          H
	ana	c		;; 116c: a1          .
	rar			;; 116d: 1f          .
	jnc	L1172		;; 116e: d2 72 11    .r.
	ret			;; 1171: c9          .

L1172:	lda	L3c51		;; 1172: 3a 51 3c    :Q<
	rar			;; 1175: 1f          .
	jnc	L1181		;; 1176: d2 81 11    ...
	lxi	h,L3c55		;; 1179: 21 55 3c    .U<
	mvi	m,009h		;; 117c: 36 09       6.
	jmp	L1186		;; 117e: c3 86 11    ...

L1181:	lxi	h,L3c55		;; 1181: 21 55 3c    .U<
	mvi	m,007h		;; 1184: 36 07       6.
L1186:	lda	L3c55		;; 1186: 3a 55 3c    :U<
	lxi	d,L3a71		;; 1189: 11 71 3a    .q:
	call	subxxa		;; 118c: cd ab 38    ..8
	xchg			;; 118f: eb          .
	dcx	h		;; 1190: 2b          +
	mov	m,e		;; 1191: 73          s
	inx	h		;; 1192: 23          #
	mov	m,d		;; 1193: 72          r
	lxi	h,L3a60		;; 1194: 21 60 3a    .`:
	call	L38b9		;; 1197: cd b9 38    ..8
	jnc	L11a3		;; 119a: d2 a3 11    ...
	lxi	b,L39aa		;; 119d: 01 aa 39    ..9
	call	L36e2		;; 11a0: cd e2 36    ..6
L11a3:	lda	L3c54		;; 11a3: 3a 54 3c    :T<
	rar			;; 11a6: 1f          .
	jnc	L11ba		;; 11a7: d2 ba 11    ...
	lhld	L3c4a		;; 11aa: 2a 4a 3c    *J<
	mov	b,h		;; 11ad: 44          D
	mov	c,l		;; 11ae: 4d          M
	lhld	L3c50		;; 11af: 2a 50 3c    *P<
	xchg			;; 11b2: eb          .
	call	L10ce		;; 11b3: cd ce 10    ...
	rar			;; 11b6: 1f          .
	jnc	L11ba		;; 11b7: d2 ba 11    ...
L11ba:	lhld	L3a71		;; 11ba: 2a 71 3a    *q:
	shld	L3a75		;; 11bd: 22 75 3a    "u:
	mvi	m,000h		;; 11c0: 36 00       6.
	lhld	L3c4a		;; 11c2: 2a 4a 3c    *J<
	mov	b,h		;; 11c5: 44          D
	mov	c,l		;; 11c6: 4d          M
	call	L1001		;; 11c7: cd 01 10    ...
	mvi	a,000h		;; 11ca: 3e 00       >.
	lxi	d,L3c45		;; 11cc: 11 45 3c    .E<
	call	subxxa		;; 11cf: cd ab 38    ..8
	ora	l		;; 11d2: b5          .
	jnz	L11e9		;; 11d3: c2 e9 11    ...
	lhld	L3c50		;; 11d6: 2a 50 3c    *P<
	mvi	h,000h		;; 11d9: 26 00       &.
	lxi	b,L3a69		;; 11db: 01 69 3a    .i:
	dad	h		;; 11de: 29          )
	dad	b		;; 11df: 09          .
	mov	c,m		;; 11e0: 4e          N
	inx	h		;; 11e1: 23          #
	mov	b,m		;; 11e2: 46          F
	call	L102c		;; 11e3: cd 2c 10    .,.
	jmp	L11f1		;; 11e6: c3 f1 11    ...

L11e9:	call	L0ff5		;; 11e9: cd f5 0f    ...
	mov	b,h		;; 11ec: 44          D
	mov	c,l		;; 11ed: 4d          M
	call	L102c		;; 11ee: cd 2c 10    .,.
L11f1:	lhld	L3c4c		;; 11f1: 2a 4c 3c    *L<
	mov	b,h		;; 11f4: 44          D
	mov	c,l		;; 11f5: 4d          M
	call	L1015		;; 11f6: cd 15 10    ...
	lda	L3c51		;; 11f9: 3a 51 3c    :Q<
	rar			;; 11fc: 1f          .
	jnc	L1208		;; 11fd: d2 08 12    ...
	lhld	L3c52		;; 1200: 2a 52 3c    *R<
	mov	b,h		;; 1203: 44          D
	mov	c,l		;; 1204: 4d          M
	call	L10a0		;; 1205: cd a0 10    ...
L1208:	lhld	L3c4f		;; 1208: 2a 4f 3c    *O<
	mov	c,l		;; 120b: 4d          M
	call	L1043		;; 120c: cd 43 10    .C.
	lhld	L3c4e		;; 120f: 2a 4e 3c    *N<
	mov	c,l		;; 1212: 4d          M
	call	L108b		;; 1213: cd 8b 10    ...
	lhld	L3c51		;; 1216: 2a 51 3c    *Q<
	mov	c,l		;; 1219: 4d          M
	call	L105a		;; 121a: cd 5a 10    .Z.
	lhld	L3da8		;; 121d: 2a a8 3d    *.=
	mov	c,l		;; 1220: 4d          M
	call	L1072		;; 1221: cd 72 10    .r.
	mvi	a,000h		;; 1224: 3e 00       >.
	lxi	d,L3c45		;; 1226: 11 45 3c    .E<
	call	subxxa		;; 1229: cd ab 38    ..8
	ora	l		;; 122c: b5          .
	jnz	L1246		;; 122d: c2 46 12    .F.
	lhld	L3c50		;; 1230: 2a 50 3c    *P<
	mvi	h,000h		;; 1233: 26 00       &.
	lxi	b,L3a69		;; 1235: 01 69 3a    .i:
	dad	h		;; 1238: 29          )
	dad	b		;; 1239: 09          .
	push	h		;; 123a: e5          .
	lhld	L3a71		;; 123b: 2a 71 3a    *q:
	xchg			;; 123e: eb          .
	pop	h		;; 123f: e1          .
	mov	m,e		;; 1240: 73          s
	inx	h		;; 1241: 23          #
	mov	m,d		;; 1242: 72          r
	jmp	L124e		;; 1243: c3 4e 12    .N.

L1246:	lhld	L3a71		;; 1246: 2a 71 3a    *q:
	mov	b,h		;; 1249: 44          D
	mov	c,l		;; 124a: 4d          M
	call	L10b7		;; 124b: cd b7 10    ...
L124e:	ret			;; 124e: c9          .

L124f:	lxi	h,L3c56		;; 124f: 21 56 3c    .V<
	mvi	m,000h		;; 1252: 36 00       6.
L1254:	mvi	a,003h		;; 1254: 3e 03       >.
	lxi	h,L3c56		;; 1256: 21 56 3c    .V<
	cmp	m		;; 1259: be          .
	jc	L12b7		;; 125a: da b7 12    ...
	lxi	h,00000h	;; 125d: 21 00 00    ...
	shld	L3c59		;; 1260: 22 59 3c    "Y<
	lhld	L3c56		;; 1263: 2a 56 3c    *V<
	mvi	h,000h		;; 1266: 26 00       &.
	lxi	b,L3a69		;; 1268: 01 69 3a    .i:
	dad	h		;; 126b: 29          )
	dad	b		;; 126c: 09          .
	mov	e,m		;; 126d: 5e          ^
	inx	h		;; 126e: 23          #
	mov	d,m		;; 126f: 56          V
	xchg			;; 1270: eb          .
	shld	L3a75		;; 1271: 22 75 3a    "u:
L1274:	mvi	a,000h		;; 1274: 3e 00       >.
	lxi	d,L3a75		;; 1276: 11 75 3a    .u:
	call	subxxa		;; 1279: cd ab 38    ..8
	ora	l		;; 127c: b5          .
	jz	L129d		;; 127d: ca 9d 12    ...
	call	L0fba		;; 1280: cd ba 0f    ...
	shld	L3c57		;; 1283: 22 57 3c    "W<
	lhld	L3c59		;; 1286: 2a 59 3c    *Y<
	mov	b,h		;; 1289: 44          D
	mov	c,l		;; 128a: 4d          M
	call	L102c		;; 128b: cd 2c 10    .,.
	lhld	L3a75		;; 128e: 2a 75 3a    *u:
	shld	L3c59		;; 1291: 22 59 3c    "Y<
	lhld	L3c57		;; 1294: 2a 57 3c    *W<
	shld	L3a75		;; 1297: 22 75 3a    "u:
	jmp	L1274		;; 129a: c3 74 12    .t.

L129d:	lhld	L3c56		;; 129d: 2a 56 3c    *V<
	mvi	h,000h		;; 12a0: 26 00       &.
	lxi	b,L3a69		;; 12a2: 01 69 3a    .i:
	dad	h		;; 12a5: 29          )
	dad	b		;; 12a6: 09          .
	push	h		;; 12a7: e5          .
	lhld	L3c59		;; 12a8: 2a 59 3c    *Y<
	xchg			;; 12ab: eb          .
	pop	h		;; 12ac: e1          .
	mov	m,e		;; 12ad: 73          s
	inx	h		;; 12ae: 23          #
	mov	m,d		;; 12af: 72          r
	lxi	h,L3c56		;; 12b0: 21 56 3c    .V<
	inr	m		;; 12b3: 34          4
	jnz	L1254		;; 12b4: c2 54 12    .T.
L12b7:	ret			;; 12b7: c9          .

L12b8:	call	L124f		;; 12b8: cd 4f 12    .O.
	lxi	h,L3c5b		;; 12bb: 21 5b 3c    .[<
	mvi	m,000h		;; 12be: 36 00       6.
L12c0:	mvi	a,003h		;; 12c0: 3e 03       >.
	lxi	h,L3c5b		;; 12c2: 21 5b 3c    .[<
	cmp	m		;; 12c5: be          .
	jc	L132c		;; 12c6: da 2c 13    .,.
	lhld	L3c5b		;; 12c9: 2a 5b 3c    *[<
	mvi	h,000h		;; 12cc: 26 00       &.
	lxi	b,L3a69		;; 12ce: 01 69 3a    .i:
	dad	h		;; 12d1: 29          )
	dad	b		;; 12d2: 09          .
	mov	e,m		;; 12d3: 5e          ^
	inx	h		;; 12d4: 23          #
	mov	d,m		;; 12d5: 56          V
	xchg			;; 12d6: eb          .
	shld	L3a75		;; 12d7: 22 75 3a    "u:
	lhld	L3c5b		;; 12da: 2a 5b 3c    *[<
	mvi	h,000h		;; 12dd: 26 00       &.
	lxi	b,L3c0e		;; 12df: 01 0e 3c    ..<
	dad	h		;; 12e2: 29          )
	dad	b		;; 12e3: 09          .
	mov	c,m		;; 12e4: 4e          N
	inx	h		;; 12e5: 23          #
	mov	b,m		;; 12e6: 46          F
	call	L0f2e		;; 12e7: cd 2e 0f    ...
L12ea:	mvi	a,000h		;; 12ea: 3e 00       >.
	lxi	d,L3a75		;; 12ec: 11 75 3a    .u:
	call	subxxa		;; 12ef: cd ab 38    ..8
	ora	l		;; 12f2: b5          .
	jz	L1325		;; 12f3: ca 25 13    .%.
	call	L0fe4		;; 12f6: cd e4 0f    ...
	mov	c,a		;; 12f9: 4f          O
	call	L0e6b		;; 12fa: cd 6b 0e    .k.
	call	L0fa5		;; 12fd: cd a5 0f    ...
	mov	b,h		;; 1300: 44          D
	mov	c,l		;; 1301: 4d          M
	call	L0eaa		;; 1302: cd aa 0e    ...
	call	L0fae		;; 1305: cd ae 0f    ...
	mov	b,h		;; 1308: 44          D
	mov	c,l		;; 1309: 4d          M
	call	L0eaa		;; 130a: cd aa 0e    ...
	call	L0fd1		;; 130d: cd d1 0f    ...
	rar			;; 1310: 1f          .
	jnc	L131c		;; 1311: d2 1c 13    ...
	call	L0fe9		;; 1314: cd e9 0f    ...
	mov	b,h		;; 1317: 44          D
	mov	c,l		;; 1318: 4d          M
	call	L0eaa		;; 1319: cd aa 0e    ...
L131c:	call	L0fba		;; 131c: cd ba 0f    ...
	shld	L3a75		;; 131f: 22 75 3a    "u:
	jmp	L12ea		;; 1322: c3 ea 12    ...

L1325:	lxi	h,L3c5b		;; 1325: 21 5b 3c    .[<
	inr	m		;; 1328: 34          4
	jnz	L12c0		;; 1329: c2 c0 12    ...
L132c:	lxi	h,0		;; 132c: 21 00 00    ...
	shld	L3a69		;; 132f: 22 69 3a    "i:
	shld	L3a6b		;; 1332: 22 6b 3a    "k:
	shld	L3a6d		;; 1335: 22 6d 3a    "m:
	shld	L3a6f		;; 1338: 22 6f 3a    "o:
	ret			;; 133b: c9          .

clrsym:	lhld	cursym		;; 133c: 2a 64 3a    *d:
	inx	h		;; 133f: 23          #
	inx	h		;; 1340: 23          #
	mvi	m,0		;; 1341: 36 00       6.
	lxi	b,5		;; 1343: 01 05 00    ...
	lhld	cursym		;; 1346: 2a 64 3a    *d:
	dad	b		;; 1349: 09          .
	mvi	m,0		;; 134a: 36 00       6.
	ret			;; 134c: c9          .

getnxt:	lhld	cursym		;; 134d: 2a 64 3a    *d:
	mov	e,m		;; 1350: 5e          ^
	inx	h		;; 1351: 23          #
	mov	d,m		;; 1352: 56          V
	xchg			;; 1353: eb          .
	ret			;; 1354: c9          .

setnxt:	lxi	h,L3d60		;; 1355: 21 60 3d    .`=
	mov	m,b		;; 1358: 70          p
	dcx	h		;; 1359: 2b          +
	mov	m,c		;; 135a: 71          q
	lhld	cursym		;; 135b: 2a 64 3a    *d:
	push	h		;; 135e: e5          .
	lhld	L3d5f		;; 135f: 2a 5f 3d    *_=
	xchg			;; 1362: eb          .
	pop	h		;; 1363: e1          .
	mov	m,e		;; 1364: 73          s
	inx	h		;; 1365: 23          #
	mov	m,d		;; 1366: 72          r
	ret			;; 1367: c9          .

getlen:	lxi	b,5		;; 1368: 01 05 00    ...
	lhld	cursym		;; 136b: 2a 64 3a    *d:
	dad	b		;; 136e: 09          .
	mvi	a,01fh		;; 136f: 3e 1f       >.
	ana	m		;; 1371: a6          .
	ret			;; 1372: c9          .

; cursym->len = C - assumes current ->len == 0
setlen:	lxi	h,L3d61		;; 1373: 21 61 3d    .a=
	mov	m,c		;; 1376: 71          q
	lxi	b,5		;; 1377: 01 05 00    ...
	lhld	cursym		;; 137a: 2a 64 3a    *d:
	dad	b		;; 137d: 09          .
	lda	L3d61		;; 137e: 3a 61 3d    :a=
	ora	m		;; 1381: b6          .
	mov	m,a		;; 1382: 77          w
	ret			;; 1383: c9          .

getsln:	lhld	cursym		;; 1384: 2a 64 3a    *d:
	inx	h		;; 1387: 23          #
	inx	h		;; 1388: 23          #
	mvi	a,03fh		;; 1389: 3e 3f       >?
	ana	m		;; 138b: a6          .
	ret			;; 138c: c9          .

setsln:	lxi	h,L3d62		;; 138d: 21 62 3d    .b=
	mov	m,c		;; 1390: 71          q
	lhld	cursym		;; 1391: 2a 64 3a    *d:
	inx	h		;; 1394: 23          #
	inx	h		;; 1395: 23          #
	lda	L3d62		;; 1396: 3a 62 3d    :b=
	ora	m		;; 1399: b6          .
	mov	m,a		;; 139a: 77          w
	ret			;; 139b: c9          .

getf2:	lhld	cursym		;; 139c: 2a 64 3a    *d:
	inx	h		;; 139f: 23          #
	inx	h		;; 13a0: 23          #
	mov	a,m		;; 13a1: 7e          ~
	ani	0e0h		;; 13a2: e6 e0       ..
	ral			;; 13a4: 17          .
	ral			;; 13a5: 17          .
	ral			;; 13a6: 17          .
	ani	001h		;; 13a7: e6 01       ..
	ret			;; 13a9: c9          .

; cursym->f2 |= 1
setf2:	lhld	cursym		;; 13aa: 2a 64 3a    *d:
	inx	h		;; 13ad: 23          #
	inx	h		;; 13ae: 23          #
	mvi	a,001h		;; 13af: 3e 01       >.
	ani	007h		;; 13b1: e6 07       ..
	rar			;; 13b3: 1f          .
	rar			;; 13b4: 1f          .
	rar			;; 13b5: 1f          .
	ora	m		;; 13b6: b6          .
	mov	m,a		;; 13b7: 77          w
	ret			;; 13b8: c9          .

getf1:	lhld	cursym		;; 13b9: 2a 64 3a    *d:
	inx	h		;; 13bc: 23          #
	inx	h		;; 13bd: 23          #
	mov	a,m		;; 13be: 7e          ~
	ani	0c0h		;; 13bf: e6 c0       ..
	ral			;; 13c1: 17          .
	ral			;; 13c2: 17          .
	ani	001h		;; 13c3: e6 01       ..
	ret			;; 13c5: c9          .

setf1:	lhld	cursym		;; 13c6: 2a 64 3a    *d:
	inx	h		;; 13c9: 23          #
	inx	h		;; 13ca: 23          #
	mvi	a,001h		;; 13cb: 3e 01       >.
	ani	003h		;; 13cd: e6 03       ..
	rar			;; 13cf: 1f          .
	rar			;; 13d0: 1f          .
	ora	m		;; 13d1: b6          .
	mov	m,a		;; 13d2: 77          w
	ret			;; 13d3: c9          .

getf3:	lxi	b,5		;; 13d4: 01 05 00    ...
	lhld	cursym		;; 13d7: 2a 64 3a    *d:
	dad	b		;; 13da: 09          .
	mov	a,m		;; 13db: 7e          ~
	rlc			;; 13dc: 07          .
	ani	001h		;; 13dd: e6 01       ..
	ret			;; 13df: c9          .

setf3:	lxi	h,L3d63		;; 13e0: 21 63 3d    .c=
	mov	m,c		;; 13e3: 71          q
	lxi	b,5		;; 13e4: 01 05 00    ...
	lhld	cursym		;; 13e7: 2a 64 3a    *d:
	dad	b		;; 13ea: 09          .
	mvi	a,07fh		;; 13eb: 3e 7f       >.
	ana	m		;; 13ed: a6          .
	push	psw		;; 13ee: f5          .
	lda	L3d63		;; 13ef: 3a 63 3d    :c=
	ani	003h		;; 13f2: e6 03       ..
	rar			;; 13f4: 1f          .
	rar			;; 13f5: 1f          .
	pop	b		;; 13f6: c1          .
	mov	c,b		;; 13f7: 48          H
	ora	c		;; 13f8: b1          .
	mov	m,a		;; 13f9: 77          w
	ret			;; 13fa: c9          .

getopt:	call	getsln		;; 13fb: cd 84 13    ...
	lxi	d,cursym	;; 13fe: 11 64 3a    .d:
	call	addxxa		;; 1401: cd 19 38    ..8
	dcx	h		;; 1404: 2b          +
	dcx	h		;; 1405: 2b          +
	shld	L3c5c		;; 1406: 22 5c 3c    "\<
	lhld	L3c5c		;; 1409: 2a 5c 3c    *\<
	mov	e,m		;; 140c: 5e          ^
	inx	h		;; 140d: 23          #
	mov	d,m		;; 140e: 56          V
	xchg			;; 140f: eb          .
	ret			;; 1410: c9          .

setopt:	lxi	h,L3d64+1	;; 1411: 21 65 3d    .e=
	mov	m,b		;; 1414: 70          p
	dcx	h		;; 1415: 2b          +
	mov	m,c		;; 1416: 71          q
	call	getsln		;; 1417: cd 84 13    ...
	lxi	d,cursym	;; 141a: 11 64 3a    .d:
	call	addxxa		;; 141d: cd 19 38    ..8
	dcx	h		;; 1420: 2b          +
	dcx	h		;; 1421: 2b          +
	shld	L3c5c		;; 1422: 22 5c 3c    "\<
	lhld	L3c5c		;; 1425: 2a 5c 3c    *\<
	push	h		;; 1428: e5          .
	lhld	L3d64		;; 1429: 2a 64 3d    *d=
	xchg			;; 142c: eb          .
	pop	h		;; 142d: e1          .
	mov	m,e		;; 142e: 73          s
	inx	h		;; 142f: 23          #
	mov	m,d		;; 1430: 72          r
	ret			;; 1431: c9          .

getval:	lxi	b,3		;; 1432: 01 03 00    ...
	lhld	cursym		;; 1435: 2a 64 3a    *d:
	dad	b		;; 1438: 09          .
	mov	e,m		;; 1439: 5e          ^
	inx	h		;; 143a: 23          #
	mov	d,m		;; 143b: 56          V
	xchg			;; 143c: eb          .
	ret			;; 143d: c9          .

; cursym->val = BC
setval:	lxi	h,L3d66+1	;; 143e: 21 67 3d    .g=
	mov	m,b		;; 1441: 70          p
	dcx	h		;; 1442: 2b          +
	mov	m,c		;; 1443: 71          q
	lxi	b,3		;; 1444: 01 03 00    ...
	lhld	cursym		;; 1447: 2a 64 3a    *d:
	dad	b		;; 144a: 09          .
	push	h		;; 144b: e5          .
	lhld	L3d66		;; 144c: 2a 66 3d    *f=
	xchg			;; 144f: eb          .
	pop	h		;; 1450: e1          .
	mov	m,e		;; 1451: 73          s
	inx	h		;; 1452: 23          #
	mov	m,d		;; 1453: 72          r
	ret			;; 1454: c9          .

getseg:	lxi	b,5		;; 1455: 01 05 00    ...
	lhld	cursym		;; 1458: 2a 64 3a    *d:
	dad	b		;; 145b: 09          .
	mov	a,m		;; 145c: 7e          ~
	ani	0f0h		;; 145d: e6 f0       ..
	ral			;; 145f: 17          .
	ral			;; 1460: 17          .
	ral			;; 1461: 17          .
	ral			;; 1462: 17          .
	ani	003h		;; 1463: e6 03       ..
	ret			;; 1465: c9          .

setseg:	lxi	h,L3d68		;; 1466: 21 68 3d    .h=
	mov	m,c		;; 1469: 71          q
	lxi	b,5		;; 146a: 01 05 00    ...
	lhld	cursym		;; 146d: 2a 64 3a    *d:
	dad	b		;; 1470: 09          .
	mvi	a,09fh		;; 1471: 3e 9f       >.
	ana	m		;; 1473: a6          .
	push	psw		;; 1474: f5          .
	lda	L3d68		;; 1475: 3a 68 3d    :h=
	ani	003h		;; 1478: e6 03       ..
	add	a		;; 147a: 87          .
	add	a		;; 147b: 87          .
	add	a		;; 147c: 87          .
	add	a		;; 147d: 87          .
	add	a		;; 147e: 87          .
	pop	b		;; 147f: c1          .
	mov	c,b		;; 1480: 48          H
	ora	c		;; 1481: b1          .
	mov	m,a		;; 1482: 77          w
	ret			;; 1483: c9          .

L1484:	lxi	h,L3d6b		;; 1484: 21 6b 3d    .k=
	mov	m,e		;; 1487: 73          s
	dcx	h		;; 1488: 2b          +
	mov	m,b		;; 1489: 70          p
	dcx	h		;; 148a: 2b          +
	mov	m,c		;; 148b: 71          q
	lxi	h,L3d5e		;; 148c: 21 5e 3d    .^=
	mvi	m,0		;; 148f: 36 00       6.
L1491:	lda	L3d6b		;; 1491: 3a 6b 3d    :k=
	dcr	a		;; 1494: 3d          =
	sta	L3d6b		;; 1495: 32 6b 3d    2k=
	cpi	0ffh		;; 1498: fe ff       ..
	jz	L14b1		;; 149a: ca b1 14    ...
	lhld	L3d69		;; 149d: 2a 69 3d    *i=
	lda	L3d5e		;; 14a0: 3a 5e 3d    :^=
	add	m		;; 14a3: 86          .
	sta	L3d5e		;; 14a4: 32 5e 3d    2^=
	lhld	L3d69		;; 14a7: 2a 69 3d    *i=
	inx	h		;; 14aa: 23          #
	shld	L3d69		;; 14ab: 22 69 3d    "i=
	jmp	L1491		;; 14ae: c3 91 14    ...

L14b1:	lda	L3d5e		;; 14b1: 3a 5e 3d    :^=
	ani	07fh		;; 14b4: e6 7f       ..
	sta	L3d5e		;; 14b6: 32 5e 3d    2^=
	ret			;; 14b9: c9          .

L14ba:	lxi	h,L3d6e		;; 14ba: 21 6e 3d    .n=
	mov	m,e		;; 14bd: 73          s
	dcx	h		;; 14be: 2b          +
	mov	m,b		;; 14bf: 70          p
	dcx	h		;; 14c0: 2b          +
	mov	m,c		;; 14c1: 71          q
	call	L04bd		;; 14c2: cd bd 04    ...
	shld	cursym		;; 14c5: 22 64 3a    "d:
L14c8:	lxi	b,L3a60		;; 14c8: 01 60 3a    .`:
	lxi	d,cursym		;; 14cb: 11 64 3a    .d:
	call	subxxx		;; 14ce: cd 9e 38    ..8
	jnc	L1511		;; 14d1: d2 11 15    ...
	call	getf1		;; 14d4: cd b9 13    ...
	rar			;; 14d7: 1f          .
	jnc	L1500		;; 14d8: d2 00 15    ...
	call	getlen		;; 14db: cd 68 13    .h.
	lxi	h,L3d6e		;; 14de: 21 6e 3d    .n=
	cmp	m		;; 14e1: be          .
	jnz	L1500		;; 14e2: c2 00 15    ...
	lhld	L3d6c		;; 14e5: 2a 6c 3d    *l=
	push	h		;; 14e8: e5          .
	lxi	b,6		;; 14e9: 01 06 00    ...
	lhld	cursym		;; 14ec: 2a 64 3a    *d:
	dad	b		;; 14ef: 09          .
	mov	b,h		;; 14f0: 44          D
	mov	c,l		;; 14f1: 4d          M
	lhld	L3d6e		;; 14f2: 2a 6e 3d    *n=
	xchg			;; 14f5: eb          .
	call	strncm		;; 14f6: cd 3e 2a    .>*
	rar			;; 14f9: 1f          .
	jnc	L1500		;; 14fa: d2 00 15    ...
	mvi	a,001h		;; 14fd: 3e 01       >.
	ret			;; 14ff: c9          .

L1500:	call	getsln		;; 1500: cd 84 13    ...
	lxi	d,cursym		;; 1503: 11 64 3a    .d:
	call	addxxa		;; 1506: cd 19 38    ..8
	xchg			;; 1509: eb          .
	dcx	h		;; 150a: 2b          +
	mov	m,e		;; 150b: 73          s
	inx	h		;; 150c: 23          #
	mov	m,d		;; 150d: 72          r
	jmp	L14c8		;; 150e: c3 c8 14    ...

L1511:	ret			;; 1511: c9          .

L1512:	lxi	h,L3d72		;; 1512: 21 72 3d    .r=
	mov	m,e		;; 1515: 73          s
	dcx	h		;; 1516: 2b          +
	mov	m,c		;; 1517: 71          q
	dcx	h		;; 1518: 2b          +
	pop	d		;; 1519: d1          .
	pop	b		;; 151a: c1          .
	mov	m,b		;; 151b: 70          p
	dcx	h		;; 151c: 2b          +
	mov	m,c		;; 151d: 71          q
	push	d		;; 151e: d5          .
	lhld	L3d6f		;; 151f: 2a 6f 3d    *o=
	mov	b,h		;; 1522: 44          D
	mov	c,l		;; 1523: 4d          M
	lhld	L3d71		;; 1524: 2a 71 3d    *q=
	xchg			;; 1527: eb          .
	call	L1484		;; 1528: cd 84 14    ...
	lhld	L3d5e		;; 152b: 2a 5e 3d    *^=
	mvi	h,0		;; 152e: 26 00       &.
	lxi	b,L3c5e		;; 1530: 01 5e 3c    .^<
	dad	h		;; 1533: 29          )
	dad	b		;; 1534: 09          .
	mov	e,m		;; 1535: 5e          ^
	inx	h		;; 1536: 23          #
	mov	d,m		;; 1537: 56          V
	xchg			;; 1538: eb          .
	shld	cursym		;; 1539: 22 64 3a    "d:
L153c:	mvi	a,0		;; 153c: 3e 00       >.
	lxi	d,cursym		;; 153e: 11 64 3a    .d:
	call	subxxa		;; 1541: cd ab 38    ..8
	ora	l		;; 1544: b5          .
	jz	L1586		;; 1545: ca 86 15    ...
	; if (cursym != NULL)...
	call	getlen		;; 1548: cd 68 13    .h.
	lxi	h,L3d71		;; 154b: 21 71 3d    .q=
	cmp	m		;; 154e: be          .
	jnz	L157d		;; 154f: c2 7d 15    .}.
	; len is same...
	lhld	L3d6f		;; 1552: 2a 6f 3d    *o=
	push	h		;; 1555: e5          .
	; TOS=L3d6f
	lxi	b,6		;; 1556: 01 06 00    ...
	lhld	cursym		;; 1559: 2a 64 3a    *d:
	dad	b		;; 155c: 09          .
	mov	b,h		;; 155d: 44          D
	mov	c,l		;; 155e: 4d          M
	; BC=cursym+6
	lhld	L3d71		;; 155f: 2a 71 3d    *q=
	xchg			;; 1562: eb          .
	call	strncm		;; 1563: cd 3e 2a    .>*
	rar			;; 1566: 1f          .
	jnc	L157d		;; 1567: d2 7d 15    .}.
	; names are same...
	call	getseg		;; 156a: cd 55 14    .U.
	sui	003h		;; 156d: d6 03       ..
	sui	001h		;; 156f: d6 01       ..
	sbb	a		;; 1571: 9f          .
	lxi	h,L3d72		;; 1572: 21 72 3d    .r=
	xra	m		;; 1575: ae          .
	rar			;; 1576: 1f          .
	jc	L157d		;; 1577: da 7d 15    .}.
	mvi	a,1		;; 157a: 3e 01       >.
	ret			;; 157c: c9          .

L157d:	call	getnxt		;; 157d: cd 4d 13    .M.
	shld	cursym		;; 1580: 22 64 3a    "d:
	jmp	L153c		;; 1583: c3 3c 15    .<.

L1586:	mvi	a,0		;; 1586: 3e 00       >.
	ret			;; 1588: c9          .

L1589:	lxi	h,L3d7c		;; 1589: 21 7c 3d    .|=
	mov	m,d		;; 158c: 72          r
	dcx	h		;; 158d: 2b          +
	mov	m,e		;; 158e: 73          s
	dcx	h		;; 158f: 2b          +
	mov	m,c		;; 1590: 71          q
	dcx	h		;; 1591: 2b          +
	pop	d		;; 1592: d1          .
	pop	b		;; 1593: c1          .
	mov	m,c		;; 1594: 71          q
	dcx	h		;; 1595: 2b          +
	pop	b		;; 1596: c1          .
	mov	m,c		;; 1597: 71          q
	dcx	h		;; 1598: 2b          +
	pop	b		;; 1599: c1          .
	mov	m,b		;; 159a: 70          p
	dcx	h		;; 159b: 2b          +
	mov	m,c		;; 159c: 71          q
	dcx	h		;; 159d: 2b          +
	pop	b		;; 159e: c1          .
	mov	m,c		;; 159f: 71          q
	dcx	h		;; 15a0: 2b          +
	pop	b		;; 15a1: c1          .
	mov	m,b		;; 15a2: 70          p
	dcx	h		;; 15a3: 2b          +
	mov	m,c		;; 15a4: 71          q
	push	d		;; 15a5: d5          .
	lda	L3d75		;; 15a6: 3a 75 3d    :u=
	adi	006h		;; 15a9: c6 06       ..
	sta	L3d7d		;; 15ab: 32 7d 3d    2}=
	lda	L3d7a		;; 15ae: 3a 7a 3d    :z=
	rar			;; 15b1: 1f          .
	jnc	L15ba		;; 15b2: d2 ba 15    ...
	lxi	h,L3d7d		;; 15b5: 21 7d 3d    .}=
	inr	m		;; 15b8: 34          4
	inr	m		;; 15b9: 34          4
L15ba:	lhld	L3a60		;; 15ba: 2a 60 3a    *`:
	shld	cursym		;; 15bd: 22 64 3a    "d:
	push	h		;; 15c0: e5          .
	lhld	L3d7d		;; 15c1: 2a 7d 3d    *}=
	mvi	h,000h		;; 15c4: 26 00       &.
	pop	b		;; 15c6: c1          .
	dad	b		;; 15c7: 09          .
	shld	L3a60		;; 15c8: 22 60 3a    "`:
	lxi	d,L3a71		;; 15cb: 11 71 3a    .q:
	call	subxx		;; 15ce: cd ae 38    ..8
	jnc	L15da		;; 15d1: d2 da 15    ...
	lxi	b,L39aa		;; 15d4: 01 aa 39    ..9
	call	L36e2		;; 15d7: cd e2 36    ..6
L15da:	call	clrsym		;; 15da: cd 3c 13    .<.
	lhld	L3d73		;; 15dd: 2a 73 3d    *s=
	mov	b,h		;; 15e0: 44          D
	mov	c,l		;; 15e1: 4d          M
	lhld	L3d75		;; 15e2: 2a 75 3d    *u=
	xchg			;; 15e5: eb          .
	call	L1484		;; 15e6: cd 84 14    ...
	lhld	L3d5e		;; 15e9: 2a 5e 3d    *^=
	mvi	h,0		;; 15ec: 26 00       &.
	lxi	b,L3c5e		;; 15ee: 01 5e 3c    .^<
	dad	h		;; 15f1: 29          )
	dad	b		;; 15f2: 09          .
	mov	c,m		;; 15f3: 4e          N
	inx	h		;; 15f4: 23          #
	mov	b,m		;; 15f5: 46          F
	call	setnxt		;; 15f6: cd 55 13    .U.
	lhld	L3d5e		;; 15f9: 2a 5e 3d    *^=
	mvi	h,0		;; 15fc: 26 00       &.
	lxi	b,L3c5e		;; 15fe: 01 5e 3c    .^<
	dad	h		;; 1601: 29          )
	dad	b		;; 1602: 09          .
	push	h		;; 1603: e5          .
	lhld	cursym		;; 1604: 2a 64 3a    *d:
	xchg			;; 1607: eb          .
	pop	h		;; 1608: e1          .
	mov	m,e		;; 1609: 73          s
	inx	h		;; 160a: 23          #
	mov	m,d		;; 160b: 72          r
	lhld	L3d7d		;; 160c: 2a 7d 3d    *}=
	mov	c,l		;; 160f: 4d          M
	call	setsln		;; 1610: cd 8d 13    ...
	lhld	L3d76		;; 1613: 2a 76 3d    *v=
	mov	b,h		;; 1616: 44          D
	mov	c,l		;; 1617: 4d          M
	call	setval		;; 1618: cd 3e 14    .>.
	lhld	L3d79		;; 161b: 2a 79 3d    *y=
	mov	c,l		;; 161e: 4d          M
	call	setf3		;; 161f: cd e0 13    ...
	lhld	L3d75		;; 1622: 2a 75 3d    *u=
	mov	c,l		;; 1625: 4d          M
	call	setlen		;; 1626: cd 73 13    .s.
	lhld	L3d78		;; 1629: 2a 78 3d    *x=
	mov	c,l		;; 162c: 4d          M
	call	setseg		;; 162d: cd 66 14    .f.
	lhld	L3d75		;; 1630: 2a 75 3d    *u=
	lxi	b,6		;; 1633: 01 06 00    ...
	push	h		;; 1636: e5          .
	lhld	cursym		;; 1637: 2a 64 3a    *d:
	dad	b		;; 163a: 09          .
	xchg			;; 163b: eb          .
	lhld	L3d73		;; 163c: 2a 73 3d    *s=
	mov	b,h		;; 163f: 44          D
	mov	c,l		;; 1640: 4d          M
	pop	h		;; 1641: e1          .
L1642:	ldax	b		;; 1642: 0a          .
	stax	d		;; 1643: 12          .
	inx	b		;; 1644: 03          .
	inx	d		;; 1645: 13          .
	dcr	l		;; 1646: 2d          -
	jnz	L1642		;; 1647: c2 42 16    .B.
	lda	L3d7a		;; 164a: 3a 7a 3d    :z=
	rar			;; 164d: 1f          .
	jnc	L1659		;; 164e: d2 59 16    .Y.
	lhld	L3d7b		;; 1651: 2a 7b 3d    *{=
	mov	b,h		;; 1654: 44          D
	mov	c,l		;; 1655: 4d          M
	call	setopt		;; 1656: cd 11 14    ...
L1659:	lxi	b,6		;; 1659: 01 06 00    ...
	lhld	cursym		;; 165c: 2a 64 3a    *d:
	dad	b		;; 165f: 09          .
	mov	a,m		;; 1660: 7e          ~
	cpi	'#'		;; 1661: fe 23       .#
	jnz	L166b		;; 1663: c2 6b 16    .k.
	lxi	h,L397b		;; 1666: 21 7b 39    .{9
	mvi	m,001h		;; 1669: 36 01       6.
L166b:	ret			;; 166b: c9          .

L166c:	db	cr,lf,'MODULE TOP   $'
L167c:	db	'UNDEFINED START SYMBOL: $'
L1695:	db	'YY????  $$$'
L16a0:	db	'XX????  $$$'
L16ab:	db	'RQST$'
L16b0:	db	cr,lf,'UNDEFINED SYMBOLS:',cr,lf,'$'
L16c7:	db	'ABSOLUTE     $'
L16d5:	db	'CODE SIZE    $'
L16e3:	db	'DATA SIZE    $'
L16f1:	db	'COMMON SIZE  $'
L16ff:	db	'USE FACTOR     $'

L170f:	lxi	h,L3d81		;; 170f: 21 81 3d    ..=
	mov	m,c		;; 1712: 71          q
	lhld	L3d81		;; 1713: 2a 81 3d    *.=
	mov	c,l		;; 1716: 4d          M
	call	putchr		;; 1717: cd b2 02    ...
	lxi	h,L3d7e		;; 171a: 21 7e 3d    .~=
	inr	m		;; 171d: 34          4
	ret			;; 171e: c9          .

L171f:	lxi	h,L3d82		;; 171f: 21 82 3d    ..=
	mov	m,c		;; 1722: 71          q
	mvi	a,9		;; 1723: 3e 09       >.
	lxi	h,L3d82		;; 1725: 21 82 3d    ..=
	cmp	m		;; 1728: be          .
	jc	L1738		;; 1729: da 38 17    .8.
	lda	L3d82		;; 172c: 3a 82 3d    :.=
	adi	'0'		;; 172f: c6 30       .0
	mov	c,a		;; 1731: 4f          O
	call	putchr		;; 1732: cd b2 02    ...
	jmp	L1743		;; 1735: c3 43 17    .C.

L1738:	lda	L3d82		;; 1738: 3a 82 3d    :.=
	sui	10		;; 173b: d6 0a       ..
	adi	'A'		;; 173d: c6 41       .A
	mov	c,a		;; 173f: 4f          O
	call	putchr		;; 1740: cd b2 02    ...
L1743:	ret			;; 1743: c9          .

L1744:	lxi	h,L3d83		;; 1744: 21 83 3d    ..=
	mov	m,c		;; 1747: 71          q
	lda	L3d83		;; 1748: 3a 83 3d    :.=
	ani	0f8h	; ***BUG?***	;; 174b: e6 f8       ..
	rar			;; 174d: 1f          .
	rar			;; 174e: 1f          .
	rar			;; 174f: 1f          .
	rar			;; 1750: 1f          .
	mov	c,a		;; 1751: 4f          O
	call	L171f		;; 1752: cd 1f 17    ...
	lda	L3d83		;; 1755: 3a 83 3d    :.=
	ani	00fh		;; 1758: e6 0f       ..
	mov	c,a		;; 175a: 4f          O
	call	L171f		;; 175b: cd 1f 17    ...
	ret			;; 175e: c9          .

L175f:	lxi	h,L3d85		;; 175f: 21 85 3d    ..=
	mov	m,b		;; 1762: 70          p
	dcx	h		;; 1763: 2b          +
	mov	m,c		;; 1764: 71          q
	mvi	c,008h		;; 1765: 0e 08       ..
	lxi	h,L3d84		;; 1767: 21 84 3d    ..=
	call	L3884		;; 176a: cd 84 38    ..8
	mov	c,l		;; 176d: 4d          M
	call	L1744		;; 176e: cd 44 17    .D.
	mvi	a,0ffh		;; 1771: 3e ff       >.
	lxi	d,L3d84		;; 1773: 11 84 3d    ..=
	call	L3830		;; 1776: cd 30 38    .08
	mov	c,l		;; 1779: 4d          M
	call	L1744		;; 177a: cd 44 17    .D.
	ret			;; 177d: c9          .

L177e:	lda	L3b9c		;; 177e: 3a 9c 3b    :.;
	lxi	h,L3b74		;; 1781: 21 74 3b    .t;
	ora	m		;; 1784: b6          .
	lxi	h,L3bc4		;; 1785: 21 c4 3b    ..;
	ora	m		;; 1788: b6          .
	lxi	h,L3bec		;; 1789: 21 ec 3b    ..;
	ora	m		;; 178c: b6          .
	rar			;; 178d: 1f          .
	jnc	L17c1		;; 178e: d2 c1 17    ...
	lda	L3b75		;; 1791: 3a 75 3b    :u;
	sta	deffcb		;; 1794: 32 5c 00    2\.
	mvi	l,00bh		;; 1797: 2e 0b       ..
	lxi	d,deffcb+1	;; 1799: 11 5d 00    .].
	lxi	b,L1695		;; 179c: 01 95 16    ...
L179f:	ldax	b		;; 179f: 0a          .
	stax	d		;; 17a0: 12          .
	inx	b		;; 17a1: 03          .
	inx	d		;; 17a2: 13          .
	dcr	l		;; 17a3: 2d          -
	jnz	L179f		;; 17a4: c2 9f 17    ...
	lxi	b,deffcb	;; 17a7: 01 5c 00    .\.
	call	fdelet		;; 17aa: cd a9 36    ..6
	lxi	h,L3b74		;; 17ad: 21 74 3b    .t;
	mvi	m,000h		;; 17b0: 36 00       6.
	lxi	h,L3b9c		;; 17b2: 21 9c 3b    ..;
	mvi	m,000h		;; 17b5: 36 00       6.
	lxi	h,L3bc4		;; 17b7: 21 c4 3b    ..;
	mvi	m,000h		;; 17ba: 36 00       6.
	lxi	h,L3bec		;; 17bc: 21 ec 3b    ..;
	mvi	m,000h		;; 17bf: 36 00       6.
L17c1:	ret			;; 17c1: c9          .

L17c2:	lxi	h,L3d87		;; 17c2: 21 87 3d    ..=
	mvi	m,000h		;; 17c5: 36 00       6.
	dcx	h		;; 17c7: 2b          +
	mvi	m,000h		;; 17c8: 36 00       6.
L17ca:	mvi	a,003h		;; 17ca: 3e 03       >.
	lxi	h,L3d86		;; 17cc: 21 86 3d    ..=
	cmp	m		;; 17cf: be          .
	jc	L1814		;; 17d0: da 14 18    ...
	lhld	L3d86		;; 17d3: 2a 86 3d    *.=
	mvi	h,000h		;; 17d6: 26 00       &.
	lxi	b,L3b66		;; 17d8: 01 66 3b    .f;
	dad	h		;; 17db: 29          )
	dad	b		;; 17dc: 09          .
	mov	e,m		;; 17dd: 5e          ^
	inx	h		;; 17de: 23          #
	mov	d,m		;; 17df: 56          V
	xchg			;; 17e0: eb          .
	shld	L3d7f		;; 17e1: 22 7f 3d    ".=
	lxi	b,13		;; 17e4: 01 0d 00    ...
	lhld	L3d7f		;; 17e7: 2a 7f 3d    *.=
	dad	b		;; 17ea: 09          .
	mov	a,m		;; 17eb: 7e          ~
	rar			;; 17ec: 1f          .
	jnc	L180a		;; 17ed: d2 0a 18    ...
	lxi	b,0000eh	;; 17f0: 01 0e 00    ...
	lhld	L3d7f		;; 17f3: 2a 7f 3d    *.=
	dad	b		;; 17f6: 09          .
	mov	b,h		;; 17f7: 44          D
	mov	c,l		;; 17f8: 4d          M
	call	endfil		;; 17f9: cd 76 35    .v5
	lxi	b,13		;; 17fc: 01 0d 00    ...
	lhld	L3d7f		;; 17ff: 2a 7f 3d    *.=
	dad	b		;; 1802: 09          .
	mvi	m,000h		;; 1803: 36 00       6.
	lxi	h,L3d87		;; 1805: 21 87 3d    ..=
	mvi	m,001h		;; 1808: 36 01       6.
L180a:	lda	L3d86		;; 180a: 3a 86 3d    :.=
	inr	a		;; 180d: 3c          <
	sta	L3d86		;; 180e: 32 86 3d    2.=
	jnz	L17ca		;; 1811: c2 ca 17    ...
L1814:	lda	L3d87		;; 1814: 3a 87 3d    :.=
	rar			;; 1817: 1f          .
	jnc	L1837		;; 1818: d2 37 18    .7.
	lda	L3ab8		;; 181b: 3a b8 3a    :.:
	sta	deffcb		;; 181e: 32 5c 00    2\.
	mvi	l,11		;; 1821: 2e 0b       ..
	lxi	d,deffcb+1	;; 1823: 11 5d 00    .].
	lxi	b,L16a0		;; 1826: 01 a0 16    ...
L1829:	ldax	b		;; 1829: 0a          .
	stax	d		;; 182a: 12          .
	inx	b		;; 182b: 03          .
	inx	d		;; 182c: 13          .
	dcr	l		;; 182d: 2d          -
	jnz	L1829		;; 182e: c2 29 18    .).
	lxi	b,deffcb	;; 1831: 01 5c 00    .\.
	call	fdelet		;; 1834: cd a9 36    ..6
L1837:	ret			;; 1837: c9          .

L1838:	lhld	L3970		;; 1838: 2a 70 39    *p9
	inx	h		;; 183b: 23          #
	inx	h		;; 183c: 23          #
	inx	h		;; 183d: 23          #
	lxi	d,L3a48		;; 183e: 11 48 3a    .H:
	call	subxx		;; 1841: cd ae 38    ..8
	sbb	a		;; 1844: 9f          .
	lxi	h,L3a44		;; 1845: 21 44 3a    .D:
	ana	m		;; 1848: a6          .
	rar			;; 1849: 1f          .
	jnc	L1855		;; 184a: d2 55 18    .U.
	lxi	h,L3a5c		;; 184d: 21 5c 3a    .\:
	mvi	m,000h		;; 1850: 36 00       6.
	jmp	L18dc		;; 1852: c3 dc 18    ...

L1855:	lhld	L3970		;; 1855: 2a 70 39    *p9
	inx	h		;; 1858: 23          #
	inx	h		;; 1859: 23          #
	inx	h		;; 185a: 23          #
	lxi	d,L3a46		;; 185b: 11 46 3a    .F:
	call	subxx		;; 185e: cd ae 38    ..8
	sbb	a		;; 1861: 9f          .
	lxi	h,L3a43		;; 1862: 21 43 3a    .C:
	ana	m		;; 1865: a6          .
	rar			;; 1866: 1f          .
	jnc	L1872		;; 1867: d2 72 18    .r.
	lxi	h,L3a5c		;; 186a: 21 5c 3a    .\:
	mvi	m,000h		;; 186d: 36 00       6.
	jmp	L18dc		;; 186f: c3 dc 18    ...

L1872:	lhld	L3970		;; 1872: 2a 70 39    *p9
	inx	h		;; 1875: 23          #
	inx	h		;; 1876: 23          #
	inx	h		;; 1877: 23          #
	lxi	d,L3a58		;; 1878: 11 58 3a    .X:
	call	subxx		;; 187b: cd ae 38    ..8
	jnc	L1889		;; 187e: d2 89 18    ...
	lxi	h,L3a5c		;; 1881: 21 5c 3a    .\:
	mvi	m,000h		;; 1884: 36 00       6.
	jmp	L18dc		;; 1886: c3 dc 18    ...

L1889:	lda	L3a52		;; 1889: 3a 52 3a    :R:
	rar			;; 188c: 1f          .
	jnc	L18c4		;; 188d: d2 c4 18    ...
	mvi	a,000h		;; 1890: 3e 00       >.
	lxi	d,L3a53		;; 1892: 11 53 3a    .S:
	call	subxxa		;; 1895: cd ab 38    ..8
	ora	l		;; 1898: b5          .
	sui	001h		;; 1899: d6 01       ..
	sbb	a		;; 189b: 9f          .
	push	psw		;; 189c: f5          .
	lda	L3a55		;; 189d: 3a 55 3a    :U:
	sui	001h		;; 18a0: d6 01       ..
	sui	001h		;; 18a2: d6 01       ..
	sbb	a		;; 18a4: 9f          .
	pop	b		;; 18a5: c1          .
	mov	c,b		;; 18a6: 48          H
	ana	c		;; 18a7: a1          .
	push	psw		;; 18a8: f5          .
	lda	L3a43		;; 18a9: 3a 43 3a    :C:
	cma			;; 18ac: 2f          /
	pop	b		;; 18ad: c1          .
	mov	c,b		;; 18ae: 48          H
	ana	c		;; 18af: a1          .
	rar			;; 18b0: 1f          .
	jnc	L18bc		;; 18b1: d2 bc 18    ...
	lxi	h,L3a5c		;; 18b4: 21 5c 3a    .\:
	mvi	m,000h		;; 18b7: 36 00       6.
	jmp	L18c1		;; 18b9: c3 c1 18    ...

L18bc:	lxi	h,L3a5c		;; 18bc: 21 5c 3a    .\:
	mvi	m,001h		;; 18bf: 36 01       6.
L18c1:	jmp	L18dc		;; 18c1: c3 dc 18    ...

L18c4:	lda	L3a45		;; 18c4: 3a 45 3a    :E:
	lxi	h,L3a43		;; 18c7: 21 43 3a    .C:
	ora	m		;; 18ca: b6          .
	rar			;; 18cb: 1f          .
	jnc	L18d7		;; 18cc: d2 d7 18    ...
	lxi	h,L3a5c		;; 18cf: 21 5c 3a    .\:
	mvi	m,001h		;; 18d2: 36 01       6.
	jmp	L18dc		;; 18d4: c3 dc 18    ...

L18d7:	lxi	h,L3a5c		;; 18d7: 21 5c 3a    .\:
	mvi	m,000h		;; 18da: 36 00       6.
L18dc:	ret			;; 18dc: c9          .

L18dd:	lda	L3a43		;; 18dd: 3a 43 3a    :C:
	rar			;; 18e0: 1f          .
	jnc	L18ed		;; 18e1: d2 ed 18    ...
	lhld	L3a46		;; 18e4: 2a 46 3a    *F:
	shld	L3a93		;; 18e7: 22 93 3a    ".:
	jmp	L1906		;; 18ea: c3 06 19    ...

L18ed:	lda	L3a5c		;; 18ed: 3a 5c 3a    :\:
	rar			;; 18f0: 1f          .
	jnc	L1900		;; 18f1: d2 00 19    ...
	lhld	L3970		;; 18f4: 2a 70 39    *p9
	inx	h		;; 18f7: 23          #
	inx	h		;; 18f8: 23          #
	inx	h		;; 18f9: 23          #
	shld	L3a93		;; 18fa: 22 93 3a    ".:
	jmp	L1906		;; 18fd: c3 06 19    ...

L1900:	lhld	L3970		;; 1900: 2a 70 39    *p9
	shld	L3a93		;; 1903: 22 93 3a    ".:
L1906:	lda	L3a44		;; 1906: 3a 44 3a    :D:
	rar			;; 1909: 1f          .
	jnc	L1916		;; 190a: d2 16 19    ...
	lhld	L3a48		;; 190d: 2a 48 3a    *H:
	shld	L3a97		;; 1910: 22 97 3a    ".:
	jmp	L1938		;; 1913: c3 38 19    .8.

L1916:	lhld	L3a83		;; 1916: 2a 83 3a    *.:
	xchg			;; 1919: eb          .
	lhld	L3a93		;; 191a: 2a 93 3a    *.:
	dad	d		;; 191d: 19          .
	shld	L3a97		;; 191e: 22 97 3a    ".:
	lda	L3972		;; 1921: 3a 72 39    :r9
	rar			;; 1924: 1f          .
	jnc	L1938		;; 1925: d2 38 19    .8.
	lxi	d,000ffh	;; 1928: 11 ff 00    ...
	lhld	L3a97		;; 192b: 2a 97 3a    *.:
	dad	d		;; 192e: 19          .
	lxi	d,0ff00h	;; 192f: 11 00 ff    ...
	call	L3829		;; 1932: cd 29 38    .)8
	shld	L3a97		;; 1935: 22 97 3a    ".:
L1938:	lhld	L3a87		;; 1938: 2a 87 3a    *.:
	xchg			;; 193b: eb          .
	lhld	L3a97		;; 193c: 2a 97 3a    *.:
	dad	d		;; 193f: 19          .
	shld	L3a95		;; 1940: 22 95 3a    ".:
	lxi	b,L3a5a		;; 1943: 01 5a 3a    .Z:
	lxi	d,L3a58		;; 1946: 11 58 3a    .X:
	call	subxxx		;; 1949: cd 9e 38    ..8
	jnc	L195f		;; 194c: d2 5f 19    ._.
	lxi	b,L3a58		;; 194f: 01 58 3a    .X:
	lxi	d,L3a5a		;; 1952: 11 5a 3a    .Z:
	call	subxxx		;; 1955: cd 9e 38    ..8
	inx	h		;; 1958: 23          #
	shld	L3a79		;; 1959: 22 79 3a    "y:
	jmp	L1965		;; 195c: c3 65 19    .e.

L195f:	lxi	h,00000h	;; 195f: 21 00 00    ...
	shld	L3a79		;; 1962: 22 79 3a    "y:
L1965:	ret			;; 1965: c9          .

L1966:	lxi	h,L3a9d		;; 1966: 21 9d 3a    ..:
	mvi	m,000h		;; 1969: 36 00       6.
	lhld	L3a58		;; 196b: 2a 58 3a    *X:
	shld	L3a91		;; 196e: 22 91 3a    ".:
	lxi	h,L3d88		;; 1971: 21 88 3d    ..=
	mvi	m,000h		;; 1974: 36 00       6.
L1976:	mvi	a,003h		;; 1976: 3e 03       >.
	lxi	h,L3d88		;; 1978: 21 88 3d    ..=
	cmp	m		;; 197b: be          .
	jc	L199e		;; 197c: da 9e 19    ...
	lhld	L3d88		;; 197f: 2a 88 3d    *.=
	mvi	h,000h		;; 1982: 26 00       &.
	lxi	b,L3a79		;; 1984: 01 79 3a    .y:
	dad	h		;; 1987: 29          )
	dad	b		;; 1988: 09          .
	mvi	a,000h		;; 1989: 3e 00       >.
	call	L38b6		;; 198b: cd b6 38    ..8
	jnc	L1994		;; 198e: d2 94 19    ...
	call	L19a5		;; 1991: cd a5 19    ...
L1994:	lda	L3d88		;; 1994: 3a 88 3d    :.=
	inr	a		;; 1997: 3c          <
	sta	L3d88		;; 1998: 32 88 3d    2.=
	jnz	L1976		;; 199b: c2 76 19    .v.
L199e:	lxi	h,00000h	;; 199e: 21 00 00    ...
	shld	L3a91		;; 19a1: 22 91 3a    ".:
	ret			;; 19a4: c9          .

L19a5:	lda	L3a9d		;; 19a5: 3a 9d 3a    :.:
	sta	L3d89		;; 19a8: 32 89 3d    2.=
	lxi	h,L3d8a		;; 19ab: 21 8a 3d    ..=
	mvi	m,000h		;; 19ae: 36 00       6.
	lda	L3d88		;; 19b0: 3a 88 3d    :.=
	inx	h		;; 19b3: 23          #
	mov	m,a		;; 19b4: 77          w
L19b5:	lda	L3d89		;; 19b5: 3a 89 3d    :.=
	dcr	a		;; 19b8: 3d          =
	sta	L3d89		;; 19b9: 32 89 3d    2.=
	cpi	0ffh		;; 19bc: fe ff       ..
	jz	L1a0b		;; 19be: ca 0b 1a    ...
	lhld	L3d8b		;; 19c1: 2a 8b 3d    *.=
	mvi	h,000h		;; 19c4: 26 00       &.
	lxi	b,L3a91		;; 19c6: 01 91 3a    ..:
	dad	h		;; 19c9: 29          )
	dad	b		;; 19ca: 09          .
	push	h		;; 19cb: e5          .
	lhld	L3d8a		;; 19cc: 2a 8a 3d    *.=
	mvi	h,000h		;; 19cf: 26 00       &.
	lxi	b,L3a99		;; 19d1: 01 99 3a    ..:
	dad	b		;; 19d4: 09          .
	mov	c,m		;; 19d5: 4e          N
	mvi	b,000h		;; 19d6: 06 00       ..
	lxi	h,L3a91		;; 19d8: 21 91 3a    ..:
	dad	b		;; 19db: 09          .
	dad	b		;; 19dc: 09          .
	pop	d		;; 19dd: d1          .
	call	subxxm		;; 19de: cd a0 38    ..8
	jnc	L1a01		;; 19e1: d2 01 1a    ...
	lhld	L3d8a		;; 19e4: 2a 8a 3d    *.=
	mvi	h,000h		;; 19e7: 26 00       &.
	lxi	b,L3a99		;; 19e9: 01 99 3a    ..:
	dad	b		;; 19ec: 09          .
	mov	a,m		;; 19ed: 7e          ~
	sta	L3d8c		;; 19ee: 32 8c 3d    2.=
	lhld	L3d8a		;; 19f1: 2a 8a 3d    *.=
	mvi	h,000h		;; 19f4: 26 00       &.
	dad	b		;; 19f6: 09          .
	lda	L3d8b		;; 19f7: 3a 8b 3d    :.=
	mov	m,a		;; 19fa: 77          w
	lda	L3d8c		;; 19fb: 3a 8c 3d    :.=
	sta	L3d8b		;; 19fe: 32 8b 3d    2.=
L1a01:	lda	L3d8a		;; 1a01: 3a 8a 3d    :.=
	inr	a		;; 1a04: 3c          <
	sta	L3d8a		;; 1a05: 32 8a 3d    2.=
	jmp	L19b5		;; 1a08: c3 b5 19    ...

L1a0b:	lhld	L3d8a		;; 1a0b: 2a 8a 3d    *.=
	mvi	h,000h		;; 1a0e: 26 00       &.
	lxi	b,L3a99		;; 1a10: 01 99 3a    ..:
	dad	b		;; 1a13: 09          .
	lda	L3d8b		;; 1a14: 3a 8b 3d    :.=
	mov	m,a		;; 1a17: 77          w
	lda	L3a9d		;; 1a18: 3a 9d 3a    :.:
	inr	a		;; 1a1b: 3c          <
	sta	L3a9d		;; 1a1c: 32 9d 3a    2.:
	ret			;; 1a1f: c9          .

L1a20:	lhld	L3a62		;; 1a20: 2a 62 3a    *b:
	shld	cursym		;; 1a23: 22 64 3a    "d:
L1a26:	lxi	b,L3a60		;; 1a26: 01 60 3a    .`:
	lxi	d,cursym		;; 1a29: 11 64 3a    .d:
	call	subxxx		;; 1a2c: cd 9e 38    ..8
	jnc	L1a71		;; 1a2f: d2 71 1a    .q.
	call	getf2		;; 1a32: cd 9c 13    ...
	cma			;; 1a35: 2f          /
	push	psw		;; 1a36: f5          .
	call	getf3		;; 1a37: cd d4 13    ...
	lxi	h,L398d		;; 1a3a: 21 8d 39    ..9
	ora	m		;; 1a3d: b6          .
	pop	b		;; 1a3e: c1          .
	mov	c,b		;; 1a3f: 48          H
	ana	c		;; 1a40: a1          .
	rar			;; 1a41: 1f          .
	jnc	L1a60		;; 1a42: d2 60 1a    .`.
	call	getval		;; 1a45: cd 32 14    .2.
	push	h		;; 1a48: e5          .
	call	getseg		;; 1a49: cd 55 14    .U.
	mov	c,a		;; 1a4c: 4f          O
	mvi	b,000h		;; 1a4d: 06 00       ..
	lxi	h,L3a91		;; 1a4f: 21 91 3a    ..:
	dad	b		;; 1a52: 09          .
	dad	b		;; 1a53: 09          .
	pop	d		;; 1a54: d1          .
	call	addxx		;; 1a55: cd 1d 38    ..8
	mov	b,h		;; 1a58: 44          D
	mov	c,l		;; 1a59: 4d          M
	call	setval		;; 1a5a: cd 3e 14    .>.
	call	setf2		;; 1a5d: cd aa 13    ...
L1a60:	call	getsln		;; 1a60: cd 84 13    ...
	lxi	d,cursym		;; 1a63: 11 64 3a    .d:
	call	addxxa		;; 1a66: cd 19 38    ..8
	xchg			;; 1a69: eb          .
	dcx	h		;; 1a6a: 2b          +
	mov	m,e		;; 1a6b: 73          s
	inx	h		;; 1a6c: 23          #
	mov	m,d		;; 1a6d: 72          r
	jmp	L1a26		;; 1a6e: c3 26 1a    .&.

L1a71:	ret			;; 1a71: c9          .

L1a72:	lxi	h,segmnt	;; 1a72: 21 5d 3a    .]:
	mvi	m,0		;; 1a75: 36 00       6.
	; for segmnt = 0 to 3...
L1a77:	mvi	a,3		;; 1a77: 3e 03       >.
	lxi	h,segmnt	;; 1a79: 21 5d 3a    .]:
	cmp	m		;; 1a7c: be          .
	jc	L1b37		;; 1a7d: da 37 1b    .7.
	lhld	segmnt		;; 1a80: 2a 5d 3a    *]:
	mvi	h,0		;; 1a83: 26 00       &.
	lxi	b,L3b66		;; 1a85: 01 66 3b    .f;
	dad	h		;; 1a88: 29          )
	dad	b		;; 1a89: 09          .
	mov	c,m		;; 1a8a: 4e          N
	inx	h		;; 1a8b: 23          #
	mov	b,m		;; 1a8c: 46          F
	call	L348b		;; 1a8d: cd 8b 34    ..4
	lda	L0188		;; 1a90: 3a 88 01    :..
	rar			;; 1a93: 1f          .
	jnc	L1ae5		;; 1a94: d2 e5 1a    ...
	lhld	segmnt		;; 1a97: 2a 5d 3a    *]:
	mvi	h,000h		;; 1a9a: 26 00       &.
	lxi	b,L3c0e		;; 1a9c: 01 0e 3c    ..<
	dad	h		;; 1a9f: 29          )
	dad	b		;; 1aa0: 09          .
	mov	c,m		;; 1aa1: 4e          N
	inx	h		;; 1aa2: 23          #
	mov	b,m		;; 1aa3: 46          F
	call	L0f2e		;; 1aa4: cd 2e 0f    ...
	call	L0f42		;; 1aa7: cd 42 0f    .B.
	call	L0ee0		;; 1aaa: cd e0 0e    ...
	sta	L3d90		;; 1aad: 32 90 3d    2.=
L1ab0:	lda	L3d90		;; 1ab0: 3a 90 3d    :.=
	cpi	0ffh		;; 1ab3: fe ff       ..
	jz	L1ae2		;; 1ab5: ca e2 1a    ...
	call	L0f18		;; 1ab8: cd 18 0f    ...
	shld	L3d91		;; 1abb: 22 91 3d    ".=
	call	L0f18		;; 1abe: cd 18 0f    ...
	shld	L3d93		;; 1ac1: 22 93 3d    ".=
	lda	L3d90		;; 1ac4: 3a 90 3d    :.=
	ani	008h		;; 1ac7: e6 08       ..
	mov	c,a		;; 1ac9: 4f          O
	mvi	a,000h		;; 1aca: 3e 00       >.
	cmp	c		;; 1acc: b9          .
	jnc	L1ad6		;; 1acd: d2 d6 1a    ...
	call	L0f18		;; 1ad0: cd 18 0f    ...
	shld	L3d95		;; 1ad3: 22 95 3d    ".=
L1ad6:	call	L1b6e		;; 1ad6: cd 6e 1b    .n.
	call	L0ee0		;; 1ad9: cd e0 0e    ...
	sta	L3d90		;; 1adc: 32 90 3d    2.=
	jmp	L1ab0		;; 1adf: c3 b0 1a    ...

L1ae2:	jmp	L1b2d		;; 1ae2: c3 2d 1b    .-.

L1ae5:	lhld	segmnt		;; 1ae5: 2a 5d 3a    *]:
	mvi	h,000h		;; 1ae8: 26 00       &.
	lxi	b,L3a69		;; 1aea: 01 69 3a    .i:
	dad	h		;; 1aed: 29          )
	dad	b		;; 1aee: 09          .
	mov	e,m		;; 1aef: 5e          ^
	inx	h		;; 1af0: 23          #
	mov	d,m		;; 1af1: 56          V
	xchg			;; 1af2: eb          .
	shld	L3a75		;; 1af3: 22 75 3a    "u:
L1af6:	mvi	a,000h		;; 1af6: 3e 00       >.
	lxi	d,L3a75		;; 1af8: 11 75 3a    .u:
	call	subxxa		;; 1afb: cd ab 38    ..8
	ora	l		;; 1afe: b5          .
	jz	L1b2d		;; 1aff: ca 2d 1b    .-.
	call	L0fe4		;; 1b02: cd e4 0f    ...
	sta	L3d90		;; 1b05: 32 90 3d    2.=
	call	L0fa5		;; 1b08: cd a5 0f    ...
	shld	L3d91		;; 1b0b: 22 91 3d    ".=
	call	L0fae		;; 1b0e: cd ae 0f    ...
	shld	L3d93		;; 1b11: 22 93 3d    ".=
	call	L0fd1		;; 1b14: cd d1 0f    ...
	rar			;; 1b17: 1f          .
	jnc	L1b21		;; 1b18: d2 21 1b    ...
	call	L0fe9		;; 1b1b: cd e9 0f    ...
	shld	L3d95		;; 1b1e: 22 95 3d    ".=
L1b21:	call	L1b6e		;; 1b21: cd 6e 1b    .n.
	call	L0fba		;; 1b24: cd ba 0f    ...
	shld	L3a75		;; 1b27: 22 75 3a    "u:
	jmp	L1af6		;; 1b2a: c3 f6 1a    ...

L1b2d:	lda	segmnt		;; 1b2d: 3a 5d 3a    :]:
	inr	a		;; 1b30: 3c          <
	sta	segmnt		;; 1b31: 32 5d 3a    2]:
	jnz	L1a77		;; 1b34: c2 77 1a    .w.
L1b37:	ret			;; 1b37: c9          .

L1b38:	lxi	h,L3d9a		;; 1b38: 21 9a 3d    ..=
	mov	m,d		;; 1b3b: 72          r
	dcx	h		;; 1b3c: 2b          +
	mov	m,e		;; 1b3d: 73          s
	dcx	h		;; 1b3e: 2b          +
	mov	m,b		;; 1b3f: 70          p
	dcx	h		;; 1b40: 2b          +
	mov	m,c		;; 1b41: 71          q
	lhld	L3d99		;; 1b42: 2a 99 3d    *.=
	mov	a,l		;; 1b45: 7d          }
	lhld	L3d97		;; 1b46: 2a 97 3d    *.=
	mov	e,a		;; 1b49: 5f          _
	mov	b,h		;; 1b4a: 44          D
	mov	c,l		;; 1b4b: 4d          M
	call	L3498		;; 1b4c: cd 98 34    ..4
	lhld	L3d97		;; 1b4f: 2a 97 3d    *.=
	inx	h		;; 1b52: 23          #
	push	h		;; 1b53: e5          .
	lhld	L3d99		;; 1b54: 2a 99 3d    *.=
	mov	a,h		;; 1b57: 7c          |
	mov	e,a		;; 1b58: 5f          _
	pop	b		;; 1b59: c1          .
	call	L3498		;; 1b5a: cd 98 34    ..4
	ret			;; 1b5d: c9          .

L1b5e:	lxi	h,L3d9c		;; 1b5e: 21 9c 3d    ..=
	mov	m,b		;; 1b61: 70          p
	dcx	h		;; 1b62: 2b          +
	mov	m,c		;; 1b63: 71          q
	lhld	L3d9b		;; 1b64: 2a 9b 3d    *.=
	shld	cursym		;; 1b67: 22 64 3a    "d:
	call	getval		;; 1b6a: cd 32 14    .2.
	ret			;; 1b6d: c9          .

L1b6e:	lda	L3d90		;; 1b6e: 3a 90 3d    :.=
	ani	003h		;; 1b71: e6 03       ..
	sta	L3d8f		;; 1b73: 32 8f 3d    2.=
	lda	L3d90		;; 1b76: 3a 90 3d    :.=
	ani	004h		;; 1b79: e6 04       ..
	mov	c,a		;; 1b7b: 4f          O
	mvi	a,000h		;; 1b7c: 3e 00       >.
	cmp	c		;; 1b7e: b9          .
	jnc	L1b90		;; 1b7f: d2 90 1b    ...
	lhld	L3d93		;; 1b82: 2a 93 3d    *.=
	mov	b,h		;; 1b85: 44          D
	mov	c,l		;; 1b86: 4d          M
	call	L1b5e		;; 1b87: cd 5e 1b    .^.
	shld	L3d8d		;; 1b8a: 22 8d 3d    ".=
	jmp	L1ba3		;; 1b8d: c3 a3 1b    ...

L1b90:	lhld	L3d8f		;; 1b90: 2a 8f 3d    *.=
	mvi	h,000h		;; 1b93: 26 00       &.
	lxi	b,L3a91		;; 1b95: 01 91 3a    ..:
	dad	h		;; 1b98: 29          )
	dad	b		;; 1b99: 09          .
	lxi	d,L3d93		;; 1b9a: 11 93 3d    ..=
	call	addxxx		;; 1b9d: cd 0e 38    ..8
	shld	L3d8d		;; 1ba0: 22 8d 3d    ".=
L1ba3:	lda	L3d90		;; 1ba3: 3a 90 3d    :.=
	ani	008h		;; 1ba6: e6 08       ..
	mov	c,a		;; 1ba8: 4f          O
	mvi	a,000h		;; 1ba9: 3e 00       >.
	cmp	c		;; 1bab: b9          .
	jnc	L1be5		;; 1bac: d2 e5 1b    ...
	lda	L3d90		;; 1baf: 3a 90 3d    :.=
	ani	010h		;; 1bb2: e6 10       ..
	mov	c,a		;; 1bb4: 4f          O
	mvi	a,000h		;; 1bb5: 3e 00       >.
	cmp	c		;; 1bb7: b9          .
	jnc	L1bda		;; 1bb8: d2 da 1b    ...
	lxi	b,L3d95		;; 1bbb: 01 95 3d    ..=
	lxi	d,L3d8d		;; 1bbe: 11 8d 3d    ..=
	call	subxxx		;; 1bc1: cd 9e 38    ..8
	push	h		;; 1bc4: e5          .
	call	getseg		;; 1bc5: cd 55 14    .U.
	mov	c,a		;; 1bc8: 4f          O
	mvi	b,000h		;; 1bc9: 06 00       ..
	lxi	h,L3a91		;; 1bcb: 21 91 3a    ..:
	dad	b		;; 1bce: 09          .
	dad	b		;; 1bcf: 09          .
	pop	d		;; 1bd0: d1          .
	call	L38b9		;; 1bd1: cd b9 38    ..8
	shld	L3d8d		;; 1bd4: 22 8d 3d    ".=
	jmp	L1be5		;; 1bd7: c3 e5 1b    ...

L1bda:	lhld	L3d95		;; 1bda: 2a 95 3d    *.=
	xchg			;; 1bdd: eb          .
	lhld	L3d8d		;; 1bde: 2a 8d 3d    *.=
	dad	d		;; 1be1: 19          .
	shld	L3d8d		;; 1be2: 22 8d 3d    ".=
L1be5:	lhld	L3d91		;; 1be5: 2a 91 3d    *.=
	mov	b,h		;; 1be8: 44          D
	mov	c,l		;; 1be9: 4d          M
	lhld	L3d8d		;; 1bea: 2a 8d 3d    *.=
	xchg			;; 1bed: eb          .
	call	L1b38		;; 1bee: cd 38 1b    .8.
	ret			;; 1bf1: c9          .

L1bf2:	lxi	b,6		;; 1bf2: 01 06 00    ...
	lhld	cursym		;; 1bf5: 2a 64 3a    *d:
	dad	b		;; 1bf8: 09          .
	mov	a,m		;; 1bf9: 7e          ~
	sui	000h		;; 1bfa: d6 00       ..
	adi	0ffh		;; 1bfc: c6 ff       ..
	sbb	a		;; 1bfe: 9f          .
	lhld	cursym		;; 1bff: 2a 64 3a    *d:
	dad	b		;; 1c02: 09          .
	push	psw		;; 1c03: f5          .
	lda	L0187		;; 1c04: 3a 87 01    :..
	sub	m		;; 1c07: 96          .
	sui	001h		;; 1c08: d6 01       ..
	sbb	a		;; 1c0a: 9f          .
	lxi	h,L397a		;; 1c0b: 21 7a 39    .z9
	ana	m		;; 1c0e: a6          .
	cma			;; 1c0f: 2f          /
	pop	b		;; 1c10: c1          .
	mov	c,b		;; 1c11: 48          H
	ana	c		;; 1c12: a1          .
	ret			;; 1c13: c9          .

L1c14:	lxi	h,00000h	;; 1c14: 21 00 00    ...
	shld	L3d9f		;; 1c17: 22 9f 3d    ".=
	call	L04bd		;; 1c1a: cd bd 04    ...
	shld	cursym		;; 1c1d: 22 64 3a    "d:
L1c20:	lxi	b,L3a60		;; 1c20: 01 60 3a    .`:
	lxi	d,cursym		;; 1c23: 11 64 3a    .d:
	call	subxxx		;; 1c26: cd 9e 38    ..8
	jnc	L1cc5		;; 1c29: d2 c5 1c    ...
	call	getf3		;; 1c2c: cd d4 13    ...
	push	psw		;; 1c2f: f5          .
	call	L1bf2		;; 1c30: cd f2 1b    ...
	pop	b		;; 1c33: c1          .
	mov	c,b		;; 1c34: 48          H
	ana	c		;; 1c35: a1          .
	rar			;; 1c36: 1f          .
	jnc	L1cb4		;; 1c37: d2 b4 1c    ...
	mvi	a,003h		;; 1c3a: 3e 03       >.
	lxi	d,L3d9f		;; 1c3c: 11 9f 3d    ..=
	call	L3830		;; 1c3f: cd 30 38    .08
	mvi	a,000h		;; 1c42: 3e 00       >.
	call	subxa		;; 1c44: cd 94 38    ..8
	ora	l		;; 1c47: b5          .
	jnz	L1c53		;; 1c48: c2 53 1c    .S.
	call	crlf		;; 1c4b: cd d8 36    ..6
	lxi	h,L3d7e		;; 1c4e: 21 7e 3d    .~=
	mvi	m,000h		;; 1c51: 36 00       6.
L1c53:	call	getseg		;; 1c53: cd 55 14    .U.
	cpi	003h		;; 1c56: fe 03       ..
	jnz	L1c60		;; 1c58: c2 60 1c    .`.
	mvi	c,02fh		;; 1c5b: 0e 2f       ./
	call	L170f		;; 1c5d: cd 0f 17    ...
L1c60:	call	L1d77		;; 1c60: cd 77 1d    .w.
	call	getseg		;; 1c63: cd 55 14    .U.
	cpi	003h		;; 1c66: fe 03       ..
	jnz	L1c70		;; 1c68: c2 70 1c    .p.
	mvi	c,'/'		;; 1c6b: 0e 2f       ./
	call	L170f		;; 1c6d: cd 0f 17    ...
L1c70:	mvi	a,3		;; 1c70: 3e 03       >.
	lxi	d,L3d9f		;; 1c72: 11 9f 3d    ..=
	call	L3830		;; 1c75: cd 30 38    .08
	lxi	d,12		;; 1c78: 11 0c 00    ...
	call	mult		;; 1c7b: cd 5c 38    .\8
	lxi	d,9		;; 1c7e: 11 09 00    ...
	dad	d		;; 1c81: 19          .
	mov	c,l		;; 1c82: 4d          M
	call	L1d60		;; 1c83: cd 60 1d    .`.
	call	getf1		;; 1c86: cd b9 13    ...
	rar			;; 1c89: 1f          .
	jnc	L1c96		;; 1c8a: d2 96 1c    ...
	lxi	b,L16ab		;; 1c8d: 01 ab 16    ...
	call	pagmsg		;; 1c90: cd c8 02    ...
	jmp	L1c9e		;; 1c93: c3 9e 1c    ...

L1c96:	call	getval		;; 1c96: cd 32 14    .2.
	mov	b,h		;; 1c99: 44          D
	mov	c,l		;; 1c9a: 4d          M
	call	L175f		;; 1c9b: cd 5f 17    ._.
L1c9e:	mvi	c,020h		;; 1c9e: 0e 20       . 
	call	L170f		;; 1ca0: cd 0f 17    ...
	mvi	c,020h		;; 1ca3: 0e 20       . 
	call	L170f		;; 1ca5: cd 0f 17    ...
	mvi	c,020h		;; 1ca8: 0e 20       . 
	call	L170f		;; 1caa: cd 0f 17    ...
	lhld	L3d9f		;; 1cad: 2a 9f 3d    *.=
	inx	h		;; 1cb0: 23          #
	shld	L3d9f		;; 1cb1: 22 9f 3d    ".=
L1cb4:	call	getsln		;; 1cb4: cd 84 13    ...
	lxi	d,cursym		;; 1cb7: 11 64 3a    .d:
	call	addxxa		;; 1cba: cd 19 38    ..8
	xchg			;; 1cbd: eb          .
	dcx	h		;; 1cbe: 2b          +
	mov	m,e		;; 1cbf: 73          s
	inx	h		;; 1cc0: 23          #
	mov	m,d		;; 1cc1: 72          r
	jmp	L1c20		;; 1cc2: c3 20 1c    . .

L1cc5:	mvi	a,000h		;; 1cc5: 3e 00       >.
	lxi	h,L3d9f		;; 1cc7: 21 9f 3d    ..=
	call	L38b6		;; 1cca: cd b6 38    ..8
	jnc	L1cd3		;; 1ccd: d2 d3 1c    ...
	call	crlf		;; 1cd0: cd d8 36    ..6
L1cd3:	lxi	h,L3d9e		;; 1cd3: 21 9e 3d    ..=
	mvi	m,001h		;; 1cd6: 36 01       6.
	mvi	a,000h		;; 1cd8: 3e 00       >.
	inx	h		;; 1cda: 23          #
	mov	m,a		;; 1cdb: 77          w
	inx	h		;; 1cdc: 23          #
	mvi	m,000h		;; 1cdd: 36 00       6.
	sta	L3d7e		;; 1cdf: 32 7e 3d    2~=
	call	L04bd		;; 1ce2: cd bd 04    ...
	shld	cursym		;; 1ce5: 22 64 3a    "d:
L1ce8:	lxi	b,L3a60		;; 1ce8: 01 60 3a    .`:
	lxi	d,cursym		;; 1ceb: 11 64 3a    .d:
	call	subxxx		;; 1cee: cd 9e 38    ..8
	jnc	L1d4e		;; 1cf1: d2 4e 1d    .N.
	call	getf3		;; 1cf4: cd d4 13    ...
	cma			;; 1cf7: 2f          /
	rar			;; 1cf8: 1f          .
	jnc	L1d3d		;; 1cf9: d2 3d 1d    .=.
	lda	L3d9e		;; 1cfc: 3a 9e 3d    :.=
	rar			;; 1cff: 1f          .
	jnc	L1d0e		;; 1d00: d2 0e 1d    ...
	lxi	h,L3d9e		;; 1d03: 21 9e 3d    ..=
	mvi	m,000h		;; 1d06: 36 00       6.
	lxi	b,L16b0		;; 1d08: 01 b0 16    ...
	call	pagmsg		;; 1d0b: cd c8 02    ...
L1d0e:	mvi	a,007h		;; 1d0e: 3e 07       >.
	lxi	d,L3d9f		;; 1d10: 11 9f 3d    ..=
	call	L3830		;; 1d13: cd 30 38    .08
	mvi	a,000h		;; 1d16: 3e 00       >.
	call	subxa		;; 1d18: cd 94 38    ..8
	ora	l		;; 1d1b: b5          .
	jnz	L1d27		;; 1d1c: c2 27 1d    .'.
	call	crlf		;; 1d1f: cd d8 36    ..6
	lxi	h,L3d7e		;; 1d22: 21 7e 3d    .~=
	mvi	m,000h		;; 1d25: 36 00       6.
L1d27:	call	L1d77		;; 1d27: cd 77 1d    .w.
	lhld	L3d9f		;; 1d2a: 2a 9f 3d    *.=
	inx	h		;; 1d2d: 23          #
	shld	L3d9f		;; 1d2e: 22 9f 3d    ".=
	mvi	a,007h		;; 1d31: 3e 07       >.
	call	L3826		;; 1d33: cd 26 38    .&8
	dad	h		;; 1d36: 29          )
	dad	h		;; 1d37: 29          )
	dad	h		;; 1d38: 29          )
	mov	c,l		;; 1d39: 4d          M
	call	L1d60		;; 1d3a: cd 60 1d    .`.
L1d3d:	call	getsln		;; 1d3d: cd 84 13    ...
	lxi	d,cursym		;; 1d40: 11 64 3a    .d:
	call	addxxa		;; 1d43: cd 19 38    ..8
	xchg			;; 1d46: eb          .
	dcx	h		;; 1d47: 2b          +
	mov	m,e		;; 1d48: 73          s
	inx	h		;; 1d49: 23          #
	mov	m,d		;; 1d4a: 72          r
	jmp	L1ce8		;; 1d4b: c3 e8 1c    ...

L1d4e:	mvi	a,000h		;; 1d4e: 3e 00       >.
	lxi	h,L3d9f		;; 1d50: 21 9f 3d    ..=
	call	L38b6		;; 1d53: cd b6 38    ..8
	jnc	L1d5c		;; 1d56: d2 5c 1d    .\.
	call	crlf		;; 1d59: cd d8 36    ..6
L1d5c:	call	crlf		;; 1d5c: cd d8 36    ..6
	ret			;; 1d5f: c9          .

L1d60:	lxi	h,L3da1		;; 1d60: 21 a1 3d    ..=
	mov	m,c		;; 1d63: 71          q
L1d64:	lxi	h,L3da1		;; 1d64: 21 a1 3d    ..=
	lda	L3d7e		;; 1d67: 3a 7e 3d    :~=
	cmp	m		;; 1d6a: be          .
	jnc	L1d76		;; 1d6b: d2 76 1d    .v.
	mvi	c,020h		;; 1d6e: 0e 20       . 
	call	L170f		;; 1d70: cd 0f 17    ...
	jmp	L1d64		;; 1d73: c3 64 1d    .d.

L1d76:	ret			;; 1d76: c9          .

L1d77:	lxi	h,L3d9d		;; 1d77: 21 9d 3d    ..=
	mvi	m,001h		;; 1d7a: 36 01       6.
L1d7c:	call	getlen		;; 1d7c: cd 68 13    .h.
	lxi	h,L3d9d		;; 1d7f: 21 9d 3d    ..=
	cmp	m		;; 1d82: be          .
	jc	L1da4		;; 1d83: da a4 1d    ...
	lda	L3d9d		;; 1d86: 3a 9d 3d    :.=
	dcr	a		;; 1d89: 3d          =
	mov	c,a		;; 1d8a: 4f          O
	mvi	b,000h		;; 1d8b: 06 00       ..
	lxi	h,6		;; 1d8d: 21 06 00    ...
	dad	b		;; 1d90: 09          .
	xchg			;; 1d91: eb          .
	lhld	cursym		;; 1d92: 2a 64 3a    *d:
	dad	d		;; 1d95: 19          .
	mov	c,m		;; 1d96: 4e          N
	call	L170f		;; 1d97: cd 0f 17    ...
	lda	L3d9d		;; 1d9a: 3a 9d 3d    :.=
	inr	a		;; 1d9d: 3c          <
	sta	L3d9d		;; 1d9e: 32 9d 3d    2.=
	jnz	L1d7c		;; 1da1: c2 7c 1d    .|.
L1da4:	ret			;; 1da4: c9          .

L1da5:	lda	L3a45		;; 1da5: 3a 45 3a    :E:
	rar			;; 1da8: 1f          .
	jnc	L1e00		;; 1da9: d2 00 1e    ...
	lxi	b,L3a4a		;; 1dac: 01 4a 3a    .J:
	push	b		;; 1daf: c5          .
	lhld	L3a51		;; 1db0: 2a 51 3a    *Q:
	mov	c,l		;; 1db3: 4d          M
	mvi	e,000h		;; 1db4: 1e 00       ..
	call	L1512		;; 1db6: cd 12 15    ...
	rar			;; 1db9: 1f          .
	jnc	L1dc6		;; 1dba: d2 c6 1d    ...
	call	getval		;; 1dbd: cd 32 14    .2.
	shld	L3a56		;; 1dc0: 22 56 3a    "V:
	jmp	L1dfd		;; 1dc3: c3 fd 1d    ...

L1dc6:	lxi	h,00000h	;; 1dc6: 21 00 00    ...
	shld	L3a56		;; 1dc9: 22 56 3a    "V:
	lxi	b,L167c		;; 1dcc: 01 7c 16    .|.
	call	pagmsg		;; 1dcf: cd c8 02    ...
	lxi	h,L3da2		;; 1dd2: 21 a2 3d    ..=
	mvi	m,001h		;; 1dd5: 36 01       6.
L1dd7:	lda	L3a51		;; 1dd7: 3a 51 3a    :Q:
	lxi	h,L3da2		;; 1dda: 21 a2 3d    ..=
	cmp	m		;; 1ddd: be          .
	jc	L1dfa		;; 1dde: da fa 1d    ...
	lda	L3da2		;; 1de1: 3a a2 3d    :.=
	dcr	a		;; 1de4: 3d          =
	mov	c,a		;; 1de5: 4f          O
	mvi	b,000h		;; 1de6: 06 00       ..
	lxi	h,L3a4a		;; 1de8: 21 4a 3a    .J:
	dad	b		;; 1deb: 09          .
	mov	c,m		;; 1dec: 4e          N
	call	putchr		;; 1ded: cd b2 02    ...
	lda	L3da2		;; 1df0: 3a a2 3d    :.=
	inr	a		;; 1df3: 3c          <
	sta	L3da2		;; 1df4: 32 a2 3d    2.=
	jnz	L1dd7		;; 1df7: c2 d7 1d    ...
L1dfa:	call	crlf		;; 1dfa: cd d8 36    ..6
L1dfd:	jmp	L1e44		;; 1dfd: c3 44 1e    .D.

L1e00:	lda	L3a52		;; 1e00: 3a 52 3a    :R:
	rar			;; 1e03: 1f          .
	jnc	L1e1d		;; 1e04: d2 1d 1e    ...
	lhld	L3a55		;; 1e07: 2a 55 3a    *U:
	mvi	h,000h		;; 1e0a: 26 00       &.
	lxi	b,L3a91		;; 1e0c: 01 91 3a    ..:
	dad	h		;; 1e0f: 29          )
	dad	b		;; 1e10: 09          .
	lxi	d,L3a53		;; 1e11: 11 53 3a    .S:
	call	addxxx		;; 1e14: cd 0e 38    ..8
	shld	L3a56		;; 1e17: 22 56 3a    "V:
	jmp	L1e44		;; 1e1a: c3 44 1e    .D.

L1e1d:	mvi	a,000h		;; 1e1d: 3e 00       >.
	lxi	h,L3a7b		;; 1e1f: 21 7b 3a    .{:
	call	L38b6		;; 1e22: cd b6 38    ..8
	jnc	L1e31		;; 1e25: d2 31 1e    .1.
	lhld	L3a93		;; 1e28: 2a 93 3a    *.:
	shld	L3a56		;; 1e2b: 22 56 3a    "V:
	jmp	L1e44		;; 1e2e: c3 44 1e    .D.

L1e31:	lxi	b,0ffffh	;; 1e31: 01 ff ff    ...
	lxi	d,L3a58		;; 1e34: 11 58 3a    .X:
	call	subxxb		;; 1e37: cd a3 38    ..8
	ora	l		;; 1e3a: b5          .
	jz	L1e44		;; 1e3b: ca 44 1e    .D.
	lhld	L3a58		;; 1e3e: 2a 58 3a    *X:
	shld	L3a56		;; 1e41: 22 56 3a    "V:
L1e44:	ret			;; 1e44: c9          .

L1e45:	lxi	b,L16c7		;; 1e45: 01 c7 16    ...
	call	pagmsg		;; 1e48: cd c8 02    ...
	lxi	d,L3a5a		;; 1e4b: 11 5a 3a    .Z:
	lxi	b,L3a58		;; 1e4e: 01 58 3a    .X:
	call	subxxx		;; 1e51: cd 9e 38    ..8
	jc	L1e6d		;; 1e54: da 6d 1e    .m.
	lxi	b,L3a58		;; 1e57: 01 58 3a    .X:
	lxi	d,L3a5a		;; 1e5a: 11 5a 3a    .Z:
	call	subxxx		;; 1e5d: cd 9e 38    ..8
	inx	h		;; 1e60: 23          #
	mov	b,h		;; 1e61: 44          D
	mov	c,l		;; 1e62: 4d          M
	lhld	L3a58		;; 1e63: 2a 58 3a    *X:
	xchg			;; 1e66: eb          .
	call	L1ee2		;; 1e67: cd e2 1e    ...
	jmp	L1e76		;; 1e6a: c3 76 1e    .v.

L1e6d:	lxi	d,00000h	;; 1e6d: 11 00 00    ...
	lxi	b,00000h	;; 1e70: 01 00 00    ...
	call	L1ee2		;; 1e73: cd e2 1e    ...
L1e76:	call	crlf		;; 1e76: cd d8 36    ..6
	lxi	b,L16d5		;; 1e79: 01 d5 16    ...
	call	pagmsg		;; 1e7c: cd c8 02    ...
	lhld	L3a83		;; 1e7f: 2a 83 3a    *.:
	mov	b,h		;; 1e82: 44          D
	mov	c,l		;; 1e83: 4d          M
	lhld	L3a93		;; 1e84: 2a 93 3a    *.:
	xchg			;; 1e87: eb          .
	call	L1ee2		;; 1e88: cd e2 1e    ...
	call	crlf		;; 1e8b: cd d8 36    ..6
	lxi	b,L16e3		;; 1e8e: 01 e3 16    ...
	call	pagmsg		;; 1e91: cd c8 02    ...
	lhld	L3a85		;; 1e94: 2a 85 3a    *.:
	mov	b,h		;; 1e97: 44          D
	mov	c,l		;; 1e98: 4d          M
	lhld	L3a95		;; 1e99: 2a 95 3a    *.:
	xchg			;; 1e9c: eb          .
	call	L1ee2		;; 1e9d: cd e2 1e    ...
	call	crlf		;; 1ea0: cd d8 36    ..6
	lxi	b,L16f1		;; 1ea3: 01 f1 16    ...
	call	pagmsg		;; 1ea6: cd c8 02    ...
	lhld	L3a87		;; 1ea9: 2a 87 3a    *.:
	mov	b,h		;; 1eac: 44          D
	mov	c,l		;; 1ead: 4d          M
	lhld	L3a97		;; 1eae: 2a 97 3a    *.:
	xchg			;; 1eb1: eb          .
	call	L1ee2		;; 1eb2: cd e2 1e    ...
	call	crlf		;; 1eb5: cd d8 36    ..6
	lxi	b,L16ff		;; 1eb8: 01 ff 16    ...
	call	pagmsg		;; 1ebb: cd c8 02    ...
	lxi	b,L3a60		;; 1ebe: 01 60 3a    .`:
	lxi	d,L3a73		;; 1ec1: 11 73 3a    .s:
	call	subxxx		;; 1ec4: cd 9e 38    ..8
	lxi	d,L39a8		;; 1ec7: 11 a8 39    ..9
	call	subxx		;; 1eca: cd ae 38    ..8
	push	h		;; 1ecd: e5          .
	lhld	L39a8		;; 1ece: 2a a8 39    *.9
	mov	a,h		;; 1ed1: 7c          |
	inr	a		;; 1ed2: 3c          <
	mov	l,a		;; 1ed3: 6f          o
	mvi	h,000h		;; 1ed4: 26 00       &.
	pop	d		;; 1ed6: d1          .
	call	divide		;; 1ed7: cd 3d 38    .=8
	mov	c,e		;; 1eda: 4b          K
	call	L1744		;; 1edb: cd 44 17    .D.
	call	crlf		;; 1ede: cd d8 36    ..6
	ret			;; 1ee1: c9          .

L1ee2:	lxi	h,L3da6		;; 1ee2: 21 a6 3d    ..=
	mov	m,d		;; 1ee5: 72          r
	dcx	h		;; 1ee6: 2b          +
	mov	m,e		;; 1ee7: 73          s
	dcx	h		;; 1ee8: 2b          +
	mov	m,b		;; 1ee9: 70          p
	dcx	h		;; 1eea: 2b          +
	mov	m,c		;; 1eeb: 71          q
	lhld	L3da3		;; 1eec: 2a a3 3d    *.=
	mov	b,h		;; 1eef: 44          D
	mov	c,l		;; 1ef0: 4d          M
	call	L175f		;; 1ef1: cd 5f 17    ._.
	mvi	a,000h		;; 1ef4: 3e 00       >.
	lxi	d,L3da3		;; 1ef6: 11 a3 3d    ..=
	call	subxxa		;; 1ef9: cd ab 38    ..8
	ora	l		;; 1efc: b5          .
	jnz	L1f01		;; 1efd: c2 01 1f    ...
	ret			;; 1f00: c9          .

L1f01:	mvi	c,020h		;; 1f01: 0e 20       . 
	call	putchr		;; 1f03: cd b2 02    ...
	mvi	c,028h		;; 1f06: 0e 28       .(
	call	putchr		;; 1f08: cd b2 02    ...
	lhld	L3da5		;; 1f0b: 2a a5 3d    *.=
	mov	b,h		;; 1f0e: 44          D
	mov	c,l		;; 1f0f: 4d          M
	call	L175f		;; 1f10: cd 5f 17    ._.
	mvi	c,02dh		;; 1f13: 0e 2d       .-
	call	putchr		;; 1f15: cd b2 02    ...
	lhld	L3da3		;; 1f18: 2a a3 3d    *.=
	xchg			;; 1f1b: eb          .
	lhld	L3da5		;; 1f1c: 2a a5 3d    *.=
	dad	d		;; 1f1f: 19          .
	dcx	h		;; 1f20: 2b          +
	mov	b,h		;; 1f21: 44          D
	mov	c,l		;; 1f22: 4d          M
	call	L175f		;; 1f23: cd 5f 17    ._.
	mvi	c,029h		;; 1f26: 0e 29       .)
	call	putchr		;; 1f28: cd b2 02    ...
	ret			;; 1f2b: c9          .

L1f2c:	lxi	b,L166c		;; 1f2c: 01 6c 16    .l.
	call	pagmsg		;; 1f2f: cd c8 02    ...
	lhld	L397c		;; 1f32: 2a 7c 39    *|9
	mov	b,h		;; 1f35: 44          D
	mov	c,l		;; 1f36: 4d          M
	call	L175f		;; 1f37: cd 5f 17    ._.
	call	crlf		;; 1f3a: cd d8 36    ..6
	ret			;; 1f3d: c9          .

L1f3e:	call	L1838		;; 1f3e: cd 38 18    .8.
	call	L18dd		;; 1f41: cd dd 18    ...
	call	L1966		;; 1f44: cd 66 19    .f.
	call	L1a20		;; 1f47: cd 20 1a    . .
	call	L1da5		;; 1f4a: cd a5 1d    ...
	call	L124f		;; 1f4d: cd 4f 12    .O.
	call	L1a72		;; 1f50: cd 72 1a    .r.
	lda	condst		;; 1f53: 3a 74 39    :t9
	cpi	'Z'		;; 1f56: fe 5a       .Z
	jz	L1f5e		;; 1f58: ca 5e 1f    .^.
	call	L1c14		;; 1f5b: cd 14 1c    ...
L1f5e:	call	L1e45		;; 1f5e: cd 45 1e    .E.
	call	L2ed4		;; 1f61: cd d4 2e    ...
	lda	L0188		;; 1f64: 3a 88 01    :..
	rar			;; 1f67: 1f          .
	jnc	L1f6e		;; 1f68: d2 6e 1f    .n.
	call	L177e		;; 1f6b: cd 7e 17    .~.
L1f6e:	lda	symdst		;; 1f6e: 3a 78 39    :x9
	cpi	'Z'		;; 1f71: fe 5a       .Z
	jz	L1f79		;; 1f73: ca 79 1f    .y.
	call	L2f55		;; 1f76: cd 55 2f    .U/
L1f79:	call	L17c2		;; 1f79: cd c2 17    ...
	ret			;; 1f7c: c9          .

L1f7d:	db	'?OVLAY'
L1f83:	db	'?OVLA0'

relsfx:	db	'REL'
irlsfx:	db	'IRL'
irxsfx:	db	'IRL'
rexsfx:	db	'REL'

; get address (16 bit value) from REL file
getadr:	mvi	c,8		;; 1f95: 0e 08       ..
	call	getbts		;; 1f97: cd f1 29    ..)
	push	psw		;; 1f9a: f5          .
	mvi	c,8		;; 1f9b: 0e 08       ..
	call	getbts		;; 1f9d: cd f1 29    ..)
	mov	c,a		;; 1fa0: 4f          O
	mvi	b,0		;; 1fa1: 06 00       ..
	mov	h,b		;; 1fa3: 60          `
	mov	l,c		;; 1fa4: 69          i
	mvi	c,8		;; 1fa5: 0e 08       ..
	call	shlx		;; 1fa7: cd 7e 38    .~8
	pop	psw		;; 1faa: f1          .
	call	orxa		;; 1fab: cd 70 38    .p8
	ret			;; 1fae: c9          .

L1faf:	mvi	a,000h		;; 1faf: 3e 00       >.
	lxi	h,rellen		;; 1fb1: 21 a1 3a    ..:
	cmp	m		;; 1fb4: be          .
	jnc	L1fdd		;; 1fb5: d2 dd 1f    ...
	lxi	h,L3e17		;; 1fb8: 21 17 3e    ..>
	mvi	m,001h		;; 1fbb: 36 01       6.
L1fbd:	lda	rellen		;; 1fbd: 3a a1 3a    :.:
	lxi	h,L3e17		;; 1fc0: 21 17 3e    ..>
	cmp	m		;; 1fc3: be          .
	jc	L1fdd		;; 1fc4: da dd 1f    ...
	lda	L3e17		;; 1fc7: 3a 17 3e    :.>
	dcr	a		;; 1fca: 3d          =
	mov	c,a		;; 1fcb: 4f          O
	mvi	b,000h		;; 1fcc: 06 00       ..
	lxi	h,rellab		;; 1fce: 21 a2 3a    ..:
	dad	b		;; 1fd1: 09          .
	mov	c,m		;; 1fd2: 4e          N
	call	putchr		;; 1fd3: cd b2 02    ...
	lxi	h,L3e17		;; 1fd6: 21 17 3e    ..>
	inr	m		;; 1fd9: 34          4
	jnz	L1fbd		;; 1fda: c2 bd 1f    ...
L1fdd:	ret			;; 1fdd: c9          .

; get relocatable entry
getrel:	mvi	c,2		;; 1fde: 0e 02       ..
	call	getbts		;; 1fe0: cd f1 29    ..)
	sta	relseg		;; 1fe3: 32 9e 3a    2.:
	call	getadr		;; 1fe6: cd 95 1f    ...
	shld	reladr		;; 1fe9: 22 9f 3a    ".:
	ret			;; 1fec: c9          .

; get identifier (string, label, name)
relnam:	mvi	c,3		;; 1fed: 0e 03       ..
	call	getbts		;; 1fef: cd f1 29    ..)
	sta	rellen		;; 1ff2: 32 a1 3a    2.:
	lda	rellen		;; 1ff5: 3a a1 3a    :.:
	cpi	0		;; 1ff8: fe 00       ..
	jnz	L2002		;; 1ffa: c2 02 20    .. 
	lxi	h,rellen		;; 1ffd: 21 a1 3a    ..:
	mvi	m,8		;; 2000: 36 08       6.
L2002:	lxi	h,L3e18		;; 2002: 21 18 3e    ..>
	mvi	m,1		;; 2005: 36 01       6.
L2007:	lda	rellen		;; 2007: 3a a1 3a    :.:
	lxi	h,L3e18		;; 200a: 21 18 3e    ..>
	cmp	m		;; 200d: be          .
	jc	L202e		;; 200e: da 2e 20    .. 
	mvi	c,8		;; 2011: 0e 08       ..
	call	getbts		;; 2013: cd f1 29    ..)
	ani	07fh		;; 2016: e6 7f       ..
	push	psw		;; 2018: f5          .
	lda	L3e18		;; 2019: 3a 18 3e    :.>
	dcr	a		;; 201c: 3d          =
	mov	c,a		;; 201d: 4f          O
	mvi	b,0		;; 201e: 06 00       ..
	lxi	h,rellab		;; 2020: 21 a2 3a    ..:
	dad	b		;; 2023: 09          .
	pop	b		;; 2024: c1          .
	mov	c,b		;; 2025: 48          H
	mov	m,c		;; 2026: 71          q
	lxi	h,L3e18		;; 2027: 21 18 3e    ..>
	inr	m		;; 202a: 34          4
	jnz	L2007		;; 202b: c2 07 20    .. 
L202e:	ret			;; 202e: c9          .

L202f:	lxi	d,128		;; 202f: 11 80 00    ...
	lhld	deffcb+12	;; 2032: 2a 68 00    *h.
	mvi	h,0		;; 2035: 26 00       &.
	call	mult		;; 2037: cd 5c 38    .\8
	push	h		;; 203a: e5          .
	lhld	deffcb+32	;; 203b: 2a 7c 00    *|.
	mvi	h,0		;; 203e: 26 00       &.
	pop	b		;; 2040: c1          .
	dad	b		;; 2041: 09          .
	; HL = 128 * fcb.ext + fcb.cr
	shld	L39f6		;; 2042: 22 f6 39    ".9
	lxi	b,L3e86		;; 2045: 01 86 3e    ..>
	push	b		;; 2048: c5          .
	lhld	L3a37		;; 2049: 2a 37 3a    *7:
	mov	b,h		;; 204c: 44          D
	mov	c,l		;; 204d: 4d          M
	lxi	d,deffcb	;; 204e: 11 5c 00    .\.
	call	rdfile		;; 2051: cd 8f 35    ..5
	xchg			;; 2054: eb          .
	lhld	L39f6		;; 2055: 2a f6 39    *.9
	dad	d		;; 2058: 19          .
	dcx	h		;; 2059: 2b          +
	shld	L39f8		;; 205a: 22 f8 39    ".9
	ret			;; 205d: c9          .

L205e:	lxi	h,L3e19		;; 205e: 21 19 3e    ..>
	mov	m,c		;; 2061: 71          q
	lda	L3e19		;; 2062: 3a 19 3e    :.>
	sta	segmnt		;; 2065: 32 5d 3a    2]:
	lhld	segmnt		;; 2068: 2a 5d 3a    *]:
	mvi	h,0		;; 206b: 26 00       &.
	lxi	b,L3b66		;; 206d: 01 66 3b    .f;
	dad	h		;; 2070: 29          )
	dad	b		;; 2071: 09          .
	mov	c,m		;; 2072: 4e          N
	inx	h		;; 2073: 23          #
	mov	b,m		;; 2074: 46          F
	call	L348b		;; 2075: cd 8b 34    ..4
	ret			;; 2078: c9          .

L2079:	lxi	h,L3e1a		;; 2079: 21 1a 3e    ..>
	mov	m,c		;; 207c: 71          q
	lda	segmnt		;; 207d: 3a 5d 3a    :]:
	sui	003h		;; 2080: d6 03       ..
	sui	001h		;; 2082: d6 01       ..
	sbb	a		;; 2084: 9f          .
	lxi	h,L3a66		;; 2085: 21 66 3a    .f:
	ana	m		;; 2088: a6          .
	rar			;; 2089: 1f          .
	jnc	L208e		;; 208a: d2 8e 20    .. 
	ret			;; 208d: c9          .

L208e:	lhld	segmnt		;; 208e: 2a 5d 3a    *]:
	mvi	h,0		;; 2091: 26 00       &.
	lxi	b,L3a79		;; 2093: 01 79 3a    .y:
	dad	h		;; 2096: 29          )
	dad	b		;; 2097: 09          .
	mov	c,m		;; 2098: 4e          N
	inx	h		;; 2099: 23          #
	mov	b,m		;; 209a: 46          F
	lhld	L3e1a		;; 209b: 2a 1a 3e    *.>
	xchg			;; 209e: eb          .
	call	L3498		;; 209f: cd 98 34    ..4
	lda	segmnt		;; 20a2: 3a 5d 3a    :]:
	cpi	0		;; 20a5: fe 00       ..
	jnz	L20ce		;; 20a7: c2 ce 20    .. 
	lxi	d,L3a5a		;; 20aa: 11 5a 3a    .Z:
	lxi	b,L3a79		;; 20ad: 01 79 3a    .y:
	call	subxxx		;; 20b0: cd 9e 38    ..8
	jnc	L20bc		;; 20b3: d2 bc 20    .. 
	lhld	L3a79		;; 20b6: 2a 79 3a    *y:
	shld	L3a5a		;; 20b9: 22 5a 3a    "Z:
L20bc:	lxi	b,L3a58		;; 20bc: 01 58 3a    .X:
	lxi	d,L3a79		;; 20bf: 11 79 3a    .y:
	call	subxxx		;; 20c2: cd 9e 38    ..8
	jnc	L20ce		;; 20c5: d2 ce 20    .. 
	lhld	L3a79		;; 20c8: 2a 79 3a    *y:
	shld	L3a58		;; 20cb: 22 58 3a    "X:
L20ce:	lhld	segmnt		;; 20ce: 2a 5d 3a    *]:
	mvi	h,0		;; 20d1: 26 00       &.
	lxi	b,L3a79		;; 20d3: 01 79 3a    .y:
	dad	h		;; 20d6: 29          )
	dad	b		;; 20d7: 09          .
	mov	c,m		;; 20d8: 4e          N
	inx	h		;; 20d9: 23          #
	mov	b,m		;; 20da: 46          F
	inx	b		;; 20db: 03          .
	dcx	h		;; 20dc: 2b          +
	mov	m,c		;; 20dd: 71          q
	inx	h		;; 20de: 23          #
	mov	m,b		;; 20df: 70          p
	ret			;; 20e0: c9          .

L20e1:	lxi	h,L3e1d		;; 20e1: 21 1d 3e    ..>
	mov	m,e		;; 20e4: 73          s
	dcx	h		;; 20e5: 2b          +
	mov	m,b		;; 20e6: 70          p
	dcx	h		;; 20e7: 2b          +
	mov	m,c		;; 20e8: 71          q
	lda	relseg		;; 20e9: 3a 9e 3a    :.:
	sta	L3e1e		;; 20ec: 32 1e 3e    2.>
	mov	c,a		;; 20ef: 4f          O
	mvi	b,000h		;; 20f0: 06 00       ..
	lxi	h,L3a81		;; 20f2: 21 81 3a    ..:
	dad	b		;; 20f5: 09          .
	dad	b		;; 20f6: 09          .
	lxi	d,reladr		;; 20f7: 11 9f 3a    ..:
	call	addxxx		;; 20fa: cd 0e 38    ..8
	shld	L3e1f		;; 20fd: 22 1f 3e    ".>
L2100:	lhld	L3e1f		;; 2100: 2a 1f 3e    *.>
	mov	b,h		;; 2103: 44          D
	mov	c,l		;; 2104: 4d          M
	lhld	L3e1e		;; 2105: 2a 1e 3e    *.>
	xchg			;; 2108: eb          .
	call	L10ce		;; 2109: cd ce 10    ...
	rar			;; 210c: 1f          .
	jnc	L2168		;; 210d: d2 68 21    .h.
	call	L0fae		;; 2110: cd ae 0f    ...
	shld	L3e21		;; 2113: 22 21 3e    ".>
	call	L0fdd		;; 2116: cd dd 0f    ...
	sta	L3e1e		;; 2119: 32 1e 3e    2.>
	lda	L3e1e		;; 211c: 3a 1e 3e    :.>
	sui	000h		;; 211f: d6 00       ..
	sui	001h		;; 2121: d6 01       ..
	sbb	a		;; 2123: 9f          .
	push	psw		;; 2124: f5          .
	mvi	a,000h		;; 2125: 3e 00       >.
	lxi	d,L3e21		;; 2127: 11 21 3e    ..>
	call	subxxa		;; 212a: cd ab 38    ..8
	ora	l		;; 212d: b5          .
	sui	001h		;; 212e: d6 01       ..
	sbb	a		;; 2130: 9f          .
	pop	b		;; 2131: c1          .
	mov	c,b		;; 2132: 48          H
	ana	c		;; 2133: a1          .
	rar			;; 2134: 1f          .
	jnc	L2141		;; 2135: d2 41 21    .A.
	call	L21b1		;; 2138: cd b1 21    ...
	shld	L3e1f		;; 213b: 22 1f 3e    ".>
	jmp	L2147		;; 213e: c3 47 21    .G.

L2141:	lhld	L3e21		;; 2141: 2a 21 3e    *.>
	shld	L3e1f		;; 2144: 22 1f 3e    ".>
L2147:	lhld	L3e1b		;; 2147: 2a 1b 3e    *.>
	mov	b,h		;; 214a: 44          D
	mov	c,l		;; 214b: 4d          M
	call	L1015		;; 214c: cd 15 10    ...
	lhld	L3e1d		;; 214f: 2a 1d 3e    *.>
	mov	c,l		;; 2152: 4d          M
	call	L1043		;; 2153: cd 43 10    .C.
	lda	L3e1d		;; 2156: 3a 1d 3e    :.>
	cpi	000h		;; 2159: fe 00       ..
	jnz	L2165		;; 215b: c2 65 21    .e.
	lhld	segmnt		;; 215e: 2a 5d 3a    *]:
	mov	c,l		;; 2161: 4d          M
	call	L108b		;; 2162: cd 8b 10    ...
L2165:	jmp	L2100		;; 2165: c3 00 21    ...

L2168:	lhld	L3e1f		;; 2168: 2a 1f 3e    *.>
	push	h		;; 216b: e5          .
	lhld	L3e1b		;; 216c: 2a 1b 3e    *.>
	push	h		;; 216f: e5          .
	lhld	segmnt		;; 2170: 2a 5d 3a    *]:
	push	h		;; 2173: e5          .
	lhld	L3e1d		;; 2174: 2a 1d 3e    *.>
	push	h		;; 2177: e5          .
	lhld	L3e1e		;; 2178: 2a 1e 3e    *.>
	push	h		;; 217b: e5          .
	mvi	c,000h		;; 217c: 0e 00       ..
	push	b		;; 217e: c5          .
	mvi	e,000h		;; 217f: 1e 00       ..
	lxi	b,00000h	;; 2181: 01 00 00    ...
	call	L1135		;; 2184: cd 35 11    .5.
	lda	L3da7		;; 2187: 3a a7 3d    :.=
	rar			;; 218a: 1f          .
	jnc	L21ac		;; 218b: d2 ac 21    ...
	call	L21b1		;; 218e: cd b1 21    ...
	shld	L3e21		;; 2191: 22 21 3e    ".>
	mvi	a,000h		;; 2194: 3e 00       >.
	call	subxa		;; 2196: cd 94 38    ..8
	ora	l		;; 2199: b5          .
	jnz	L219e		;; 219a: c2 9e 21    ...
	ret			;; 219d: c9          .

L219e:	lhld	L3e21		;; 219e: 2a 21 3e    *.>
	shld	L3e1f		;; 21a1: 22 1f 3e    ".>
	lxi	h,L3e1e		;; 21a4: 21 1e 3e    ..>
	mvi	m,000h		;; 21a7: 36 00       6.
	jmp	L21ad		;; 21a9: c3 ad 21    ...

L21ac:	ret			;; 21ac: c9          .

L21ad:	jmp	L2100		;; 21ad: c3 00 21    ...

	ret			;; 21b0: c9          .

L21b1:	lda	segmnt		;; 21b1: 3a 5d 3a    :]:
	sta	L3e25		;; 21b4: 32 25 3e    2%>
	lhld	L3e1e		;; 21b7: 2a 1e 3e    *.>
	mov	c,l		;; 21ba: 4d          M
	call	L205e		;; 21bb: cd 5e 20    .^ 
	lhld	L3e1f		;; 21be: 2a 1f 3e    *.>
	mov	b,h		;; 21c1: 44          D
	mov	c,l		;; 21c2: 4d          M
	call	L34dc		;; 21c3: cd dc 34    ..4
	push	psw		;; 21c6: f5          .
	lhld	L3e1f		;; 21c7: 2a 1f 3e    *.>
	inx	h		;; 21ca: 23          #
	mov	b,h		;; 21cb: 44          D
	mov	c,l		;; 21cc: 4d          M
	call	L34dc		;; 21cd: cd dc 34    ..4
	mov	c,a		;; 21d0: 4f          O
	mvi	b,000h		;; 21d1: 06 00       ..
	mov	h,b		;; 21d3: 60          `
	mov	l,c		;; 21d4: 69          i
	mvi	c,008h		;; 21d5: 0e 08       ..
	call	shlx		;; 21d7: cd 7e 38    .~8
	pop	psw		;; 21da: f1          .
	call	orxa		;; 21db: cd 70 38    .p8
	shld	L3e23		;; 21de: 22 23 3e    "#>
	lhld	L3e25		;; 21e1: 2a 25 3e    *%>
	mov	c,l		;; 21e4: 4d          M
	call	L205e		;; 21e5: cd 5e 20    .^ 
	lhld	L3e23		;; 21e8: 2a 23 3e    *#>
	ret			;; 21eb: c9          .

L21ec:	lhld	L3a62		;; 21ec: 2a 62 3a    *b:
	shld	cursym		;; 21ef: 22 64 3a    "d:
L21f2:	lxi	b,L3a60		;; 21f2: 01 60 3a    .`:
	lxi	d,cursym		;; 21f5: 11 64 3a    .d:
	call	subxxx		;; 21f8: cd 9e 38    ..8
	jnc	L2225		;; 21fb: d2 25 22    .%"
	lxi	b,6		;; 21fe: 01 06 00    ...
	lhld	cursym		;; 2201: 2a 64 3a    *d:
	dad	b		;; 2204: 09          .
	mov	a,m		;; 2205: 7e          ~
	cpi	'#'		;; 2206: fe 23       .#
	jnz	L2214		;; 2208: c2 14 22    .."
	lxi	b,6		;; 220b: 01 06 00    ...
	lhld	cursym		;; 220e: 2a 64 3a    *d:
	dad	b		;; 2211: 09          .
	mvi	m,000h		;; 2212: 36 00       6.
L2214:	call	getsln		;; 2214: cd 84 13    ...
	lxi	d,cursym		;; 2217: 11 64 3a    .d:
	call	addxxa		;; 221a: cd 19 38    ..8
	xchg			;; 221d: eb          .
	dcx	h		;; 221e: 2b          +
	mov	m,e		;; 221f: 73          s
	inx	h		;; 2220: 23          #
	mov	m,d		;; 2221: 72          r
	jmp	L21f2		;; 2222: c3 f2 21    ...

L2225:	lxi	h,L397b		;; 2225: 21 7b 39    .{9
	mvi	m,000h		;; 2228: 36 00       6.
	ret			;; 222a: c9          .

L222b:	lxi	b,rellab		;; 222b: 01 a2 3a    ..:
	push	b		;; 222e: c5          .
	lhld	rellen		;; 222f: 2a a1 3a    *.:
	mov	c,l		;; 2232: 4d          M
	mvi	e,0		;; 2233: 1e 00       ..
	call	L1512		;; 2235: cd 12 15    ...
	rar			;; 2238: 1f          .
	jnc	L2248		;; 2239: d2 48 22    .H"
	call	getf3		;; 223c: cd d4 13    ...
	rar			;; 223f: 1f          .
	jc	L2248		;; 2240: da 48 22    .H"
	lxi	h,L3a5e		;; 2243: 21 5e 3a    .^:
	mvi	m,1		;; 2246: 36 01       6.
L2248:	ret			;; 2248: c9          .

L2249:	lxi	b,rellab		;; 2249: 01 a2 3a    ..:
	push	b		;; 224c: c5          .
	lhld	rellen		;; 224d: 2a a1 3a    *.:
	mov	c,l		;; 2250: 4d          M
	mvi	e,001h		;; 2251: 1e 01       ..
	call	L1512		;; 2253: cd 12 15    ...
	rar			;; 2256: 1f          .
	jnc	L2269		;; 2257: d2 69 22    .i"
	call	getval		;; 225a: cd 32 14    .2.
	shld	L3a67		;; 225d: 22 67 3a    "g:
	call	getf2		;; 2260: cd 9c 13    ...
	sta	L3a66		;; 2263: 32 66 3a    2f:
	jmp	L226f		;; 2266: c3 6f 22    .o"

L2269:	lxi	b,L3df6		;; 2269: 01 f6 3d    ..=
	call	L36e2		;; 226c: cd e2 36    ..6
L226f:	ret			;; 226f: c9          .

L2270:	lhld	rellen		;; 2270: 2a a1 3a    *.:
	lxi	d,L3a3a		;; 2273: 11 3a 3a    .::
	lxi	b,rellab		;; 2276: 01 a2 3a    ..:
L2279:	ldax	b		;; 2279: 0a          .
	stax	d		;; 227a: 12          .
	inx	b		;; 227b: 03          .
	inx	d		;; 227c: 13          .
	dcr	l		;; 227d: 2d          -
	jnz	L2279		;; 227e: c2 79 22    .y"
	lda	rellen		;; 2281: 3a a1 3a    :.:
	sta	L3a39		;; 2284: 32 39 3a    29:
	ret			;; 2287: c9          .

L2288:	lhld	rellen		;; 2288: 2a a1 3a    *.:
	xchg			;; 228b: eb          .
	lxi	b,rellab	;; 228c: 01 a2 3a    ..:
	call	L14ba		;; 228f: cd ba 14    ...
	cma			;; 2292: 2f          /
	rar			;; 2293: 1f          .
	jnc	L22b4		;; 2294: d2 b4 22    .."
	lxi	b,rellab	;; 2297: 01 a2 3a    ..:
	push	b		;; 229a: c5          .
	lhld	rellen		;; 229b: 2a a1 3a    *.:
	push	h		;; 229e: e5          .
	lxi	b,0		;; 229f: 01 00 00    ...
	push	b		;; 22a2: c5          .
	mvi	c,0		;; 22a3: 0e 00       ..
	push	b		;; 22a5: c5          .
	mvi	c,1		;; 22a6: 0e 01       ..
	push	b		;; 22a8: c5          .
	lxi	d,0		;; 22a9: 11 00 00    ...
	mvi	c,0		;; 22ac: 0e 00       ..
	call	L1589		;; 22ae: cd 89 15    ...
	call	setf1		;; 22b1: cd c6 13    ...
L22b4:	ret			;; 22b4: c9          .

L22b5:	lxi	b,rellab	;; 22b5: 01 a2 3a    ..:
	push	b		;; 22b8: c5          .
	lhld	rellen		;; 22b9: 2a a1 3a    *.:
	mov	c,l		;; 22bc: 4d          M
	mvi	e,1		;; 22bd: 1e 01       ..
	call	L1512		;; 22bf: cd 12 15    ...
	rar			;; 22c2: 1f          .
	jnc	L22f1		;; 22c3: d2 f1 22    .."
	call	getopt		;; 22c6: cd fb 13    ...
	xchg			;; 22c9: eb          .
	lxi	h,reladr	;; 22ca: 21 9f 3a    ..:
	call	L38b9		;; 22cd: cd b9 38    ..8
	jnc	L22ee		;; 22d0: d2 ee 22    .."
	mvi	c,'/'		;; 22d3: 0e 2f       ./
	call	putchr		;; 22d5: cd b2 02    ...
	call	L1faf		;; 22d8: cd af 1f    ...
	mvi	c,'/'		;; 22db: 0e 2f       ./
	call	putchr		;; 22dd: cd b2 02    ...
	mvi	c,' '		;; 22e0: 0e 20       . 
	call	putchr		;; 22e2: cd b2 02    ...
	lxi	b,L3ddd		;; 22e5: 01 dd 3d    ..=
	call	pagmsg		;; 22e8: cd c8 02    ...
	call	crlf		;; 22eb: cd d8 36    ..6
L22ee:	jmp	L231c		;; 22ee: c3 1c 23    ..#

L22f1:	lxi	b,rellab	;; 22f1: 01 a2 3a    ..:
	push	b		;; 22f4: c5          .
	lhld	rellen		;; 22f5: 2a a1 3a    *.:
	push	h		;; 22f8: e5          .
	lhld	L3a8f		;; 22f9: 2a 8f 3a    *.:
	xchg			;; 22fc: eb          .
	lhld	L3a87		;; 22fd: 2a 87 3a    *.:
	dad	d		;; 2300: 19          .
	push	h		;; 2301: e5          .
	mvi	c,003h		;; 2302: 0e 03       ..
	push	b		;; 2304: c5          .
	mvi	c,001h		;; 2305: 0e 01       ..
	push	b		;; 2307: c5          .
	lhld	reladr		;; 2308: 2a 9f 3a    *.:
	xchg			;; 230b: eb          .
	mvi	c,001h		;; 230c: 0e 01       ..
	call	L1589		;; 230e: cd 89 15    ...
	lhld	reladr		;; 2311: 2a 9f 3a    *.:
	xchg			;; 2314: eb          .
	lhld	L3a8f		;; 2315: 2a 8f 3a    *.:
	dad	d		;; 2318: 19          .
	shld	L3a8f		;; 2319: 22 8f 3a    ".:
L231c:	ret			;; 231c: c9          .

L231d:	lxi	b,rellab		;; 231d: 01 a2 3a    ..:
	push	b		;; 2320: c5          .
	lhld	rellen		;; 2321: 2a a1 3a    *.:
	mov	c,l		;; 2324: 4d          M
	mvi	e,000h		;; 2325: 1e 00       ..
	call	L1512		;; 2327: cd 12 15    ...
	cma			;; 232a: 2f          /
	rar			;; 232b: 1f          .
	jnc	L2349		;; 232c: d2 49 23    .I#
	lxi	b,rellab		;; 232f: 01 a2 3a    ..:
	push	b		;; 2332: c5          .
	lhld	rellen		;; 2333: 2a a1 3a    *.:
	push	h		;; 2336: e5          .
	lxi	b,00000h	;; 2337: 01 00 00    ...
	push	b		;; 233a: c5          .
	mvi	c,000h		;; 233b: 0e 00       ..
	push	b		;; 233d: c5          .
	mvi	c,000h		;; 233e: 0e 00       ..
	push	b		;; 2340: c5          .
	lxi	d,00000h	;; 2341: 11 00 00    ...
	mvi	c,000h		;; 2344: 0e 00       ..
	call	L1589		;; 2346: cd 89 15    ...
L2349:	lhld	cursym		;; 2349: 2a 64 3a    *d:
	mov	b,h		;; 234c: 44          D
	mov	c,l		;; 234d: 4d          M
	mvi	e,001h		;; 234e: 1e 01       ..
	call	L20e1		;; 2350: cd e1 20    .. 
	ret			;; 2353: c9          .

L2354:	lxi	b,rellab		;; 2354: 01 a2 3a    ..:
	push	b		;; 2357: c5          .
	lhld	rellen		;; 2358: 2a a1 3a    *.:
	mov	c,l		;; 235b: 4d          M
	mvi	e,000h		;; 235c: 1e 00       ..
	call	L1512		;; 235e: cd 12 15    ...
	rar			;; 2361: 1f          .
	jnc	L239f		;; 2362: d2 9f 23    ..#
	call	getf3		;; 2365: cd d4 13    ...
	rar			;; 2368: 1f          .
	jnc	L237b		;; 2369: d2 7b 23    .{#
	lxi	b,L3db5		;; 236c: 01 b5 3d    ..=
	call	pagmsg		;; 236f: cd c8 02    ...
	call	L1faf		;; 2372: cd af 1f    ...
	call	crlf		;; 2375: cd d8 36    ..6
	jmp	L239c		;; 2378: c3 9c 23    ..#

L237b:	lhld	relseg		;; 237b: 2a 9e 3a    *.:
	mvi	h,0		;; 237e: 26 00       &.
	lxi	b,L3a81		;; 2380: 01 81 3a    ..:
	dad	h		;; 2383: 29          )
	dad	b		;; 2384: 09          .
	lxi	d,reladr		;; 2385: 11 9f 3a    ..:
	call	addxxx		;; 2388: cd 0e 38    ..8
	mov	b,h		;; 238b: 44          D
	mov	c,l		;; 238c: 4d          M
	call	setval		;; 238d: cd 3e 14    .>.
	mvi	c,1		;; 2390: 0e 01       ..
	call	setf3		;; 2392: cd e0 13    ...
	lhld	relseg		;; 2395: 2a 9e 3a    *.:
	mov	c,l		;; 2398: 4d          M
	call	setseg		;; 2399: cd 66 14    .f.
L239c:	jmp	L23c7		;; 239c: c3 c7 23    ..#

L239f:	lxi	b,rellab		;; 239f: 01 a2 3a    ..:
	push	b		;; 23a2: c5          .
	lhld	rellen		;; 23a3: 2a a1 3a    *.:
	push	h		;; 23a6: e5          .
	lhld	relseg		;; 23a7: 2a 9e 3a    *.:
	mvi	h,0		;; 23aa: 26 00       &.
	lxi	b,L3a81		;; 23ac: 01 81 3a    ..:
	dad	h		;; 23af: 29          )
	dad	b		;; 23b0: 09          .
	lxi	d,reladr		;; 23b1: 11 9f 3a    ..:
	call	addxxx		;; 23b4: cd 0e 38    ..8
	push	h		;; 23b7: e5          .
	lhld	relseg		;; 23b8: 2a 9e 3a    *.:
	push	h		;; 23bb: e5          .
	mvi	c,1		;; 23bc: 0e 01       ..
	push	b		;; 23be: c5          .
	lxi	d,0		;; 23bf: 11 00 00    ...
	mvi	c,0		;; 23c2: 0e 00       ..
	call	L1589		;; 23c4: cd 89 15    ...
L23c7:	ret			;; 23c7: c9          .

L23c8:	lhld	segmnt		;; 23c8: 2a 5d 3a    *]:
	mvi	h,000h		;; 23cb: 26 00       &.
	lxi	b,L3a79		;; 23cd: 01 79 3a    .y:
	dad	h		;; 23d0: 29          )
	dad	b		;; 23d1: 09          .
	mov	c,m		;; 23d2: 4e          N
	inx	h		;; 23d3: 23          #
	mov	b,m		;; 23d4: 46          F
	push	b		;; 23d5: c5          .
	lxi	b,00000h	;; 23d6: 01 00 00    ...
	push	b		;; 23d9: c5          .
	mvi	c,000h		;; 23da: 0e 00       ..
	push	b		;; 23dc: c5          .
	mvi	c,000h		;; 23dd: 0e 00       ..
	push	b		;; 23df: c5          .
	lhld	segmnt		;; 23e0: 2a 5d 3a    *]:
	push	h		;; 23e3: e5          .
	mvi	c,001h		;; 23e4: 0e 01       ..
	push	b		;; 23e6: c5          .
	lhld	reladr		;; 23e7: 2a 9f 3a    *.:
	mov	b,h		;; 23ea: 44          D
	mov	c,l		;; 23eb: 4d          M
	mvi	e,001h		;; 23ec: 1e 01       ..
	call	L1135		;; 23ee: cd 35 11    .5.
	ret			;; 23f1: c9          .

L23f2:	lxi	h,L3da8		;; 23f2: 21 a8 3d    ..=
	mvi	m,001h		;; 23f5: 36 01       6.
	call	L23c8		;; 23f7: cd c8 23    ..#
	lxi	h,L3da8		;; 23fa: 21 a8 3d    ..=
	mvi	m,000h		;; 23fd: 36 00       6.
	ret			;; 23ff: c9          .

L2400:	lhld	reladr		;; 2400: 2a 9f 3a    *.:
	shld	L3a8d		;; 2403: 22 8d 3a    ".:
	ret			;; 2406: c9          .

L2407:	lhld	relseg		;; 2407: 2a 9e 3a    *.:
	mov	c,l		;; 240a: 4d          M
	call	L205e		;; 240b: cd 5e 20    .^ 
	lda	segmnt		;; 240e: 3a 5d 3a    :]:
	cpi	003h		;; 2411: fe 03       ..
	jnz	L2424		;; 2413: c2 24 24    .$$
	lhld	L3a67		;; 2416: 2a 67 3a    *g:
	xchg			;; 2419: eb          .
	lhld	reladr		;; 241a: 2a 9f 3a    *.:
	dad	d		;; 241d: 19          .
	shld	L3a7f		;; 241e: 22 7f 3a    ".:
	jmp	L2443		;; 2421: c3 43 24    .C$

L2424:	lhld	segmnt		;; 2424: 2a 5d 3a    *]:
	mvi	h,000h		;; 2427: 26 00       &.
	lxi	b,L3a81		;; 2429: 01 81 3a    ..:
	dad	h		;; 242c: 29          )
	dad	b		;; 242d: 09          .
	lxi	d,reladr		;; 242e: 11 9f 3a    ..:
	call	addxxx		;; 2431: cd 0e 38    ..8
	push	h		;; 2434: e5          .
	lhld	segmnt		;; 2435: 2a 5d 3a    *]:
	mvi	h,000h		;; 2438: 26 00       &.
	lxi	b,L3a79		;; 243a: 01 79 3a    .y:
	dad	h		;; 243d: 29          )
	dad	b		;; 243e: 09          .
	pop	b		;; 243f: c1          .
	mov	m,c		;; 2440: 71          q
	inx	h		;; 2441: 23          #
	mov	m,b		;; 2442: 70          p
L2443:	lda	segmnt		;; 2443: 3a 5d 3a    :]:
	cpi	000h		;; 2446: fe 00       ..
	jnz	L2450		;; 2448: c2 50 24    .P$
	lxi	h,L3da7		;; 244b: 21 a7 3d    ..=
	mvi	m,001h		;; 244e: 36 01       6.
L2450:	ret			;; 2450: c9          .

L2451:	lhld	segmnt		;; 2451: 2a 5d 3a    *]:
	mvi	h,000h		;; 2454: 26 00       &.
	lxi	b,L3a79		;; 2456: 01 79 3a    .y:
	dad	h		;; 2459: 29          )
	dad	b		;; 245a: 09          .
	mov	c,m		;; 245b: 4e          N
	inx	h		;; 245c: 23          #
	mov	b,m		;; 245d: 46          F
	mvi	e,000h		;; 245e: 1e 00       ..
	call	L20e1		;; 2460: cd e1 20    .. 
	ret			;; 2463: c9          .

L2464:	lhld	reladr		;; 2464: 2a 9f 3a    *.:
	shld	L3a8b		;; 2467: 22 8b 3a    ".:
	ret			;; 246a: c9          .

L246b:	mvi	a,000h		;; 246b: 3e 00       >.
	lxi	h,reladr		;; 246d: 21 9f 3a    ..:
	call	L38b6		;; 2470: cd b6 38    ..8
	sbb	a		;; 2473: 9f          .
	push	psw		;; 2474: f5          .
	lda	relseg		;; 2475: 3a 9e 3a    :.:
	sui	000h		;; 2478: d6 00       ..
	adi	0ffh		;; 247a: c6 ff       ..
	sbb	a		;; 247c: 9f          .
	pop	b		;; 247d: c1          .
	mov	c,b		;; 247e: 48          H
	ora	c		;; 247f: b1          .
	rar			;; 2480: 1f          .
	jnc	L24b2		;; 2481: d2 b2 24    ..$
	lda	L3a52		;; 2484: 3a 52 3a    :R:
	rar			;; 2487: 1f          .
	jnc	L2494		;; 2488: d2 94 24    ..$
	lxi	b,L3dcb		;; 248b: 01 cb 3d    ..=
	call	L36e2		;; 248e: cd e2 36    ..6
	jmp	L24b2		;; 2491: c3 b2 24    ..$

L2494:	lhld	relseg		;; 2494: 2a 9e 3a    *.:
	mvi	h,000h		;; 2497: 26 00       &.
	lxi	b,L3a81		;; 2499: 01 81 3a    ..:
	dad	h		;; 249c: 29          )
	dad	b		;; 249d: 09          .
	lxi	d,reladr		;; 249e: 11 9f 3a    ..:
	call	addxxx		;; 24a1: cd 0e 38    ..8
	shld	L3a53		;; 24a4: 22 53 3a    "S:
	lda	relseg		;; 24a7: 3a 9e 3a    :.:
	sta	L3a55		;; 24aa: 32 55 3a    2U:
	lxi	h,L3a52		;; 24ad: 21 52 3a    .R:
	mvi	m,001h		;; 24b0: 36 01       6.
L24b2:	lda	L3a30		;; 24b2: 3a 30 3a    :0:
	cpi	008h		;; 24b5: fe 08       ..
	jz	L24c6		;; 24b7: ca c6 24    ..$
	mvi	c,001h		;; 24ba: 0e 01       ..
	call	getbts		;; 24bc: cd f1 29    ..)
	rar			;; 24bf: 1f          .
	jnc	L24c3		;; 24c0: d2 c3 24    ..$
L24c3:	jmp	L24b2		;; 24c3: c3 b2 24    ..$

L24c6:	lxi	h,L3e26		;; 24c6: 21 26 3e    .&>
	mvi	m,001h		;; 24c9: 36 01       6.
L24cb:	mvi	a,003h		;; 24cb: 3e 03       >.
	lxi	h,L3e26		;; 24cd: 21 26 3e    .&>
	cmp	m		;; 24d0: be          .
	jc	L2525		;; 24d1: da 25 25    .%%
	lhld	L3e26		;; 24d4: 2a 26 3e    *&>
	mvi	h,000h		;; 24d7: 26 00       &.
	lxi	b,L3a81		;; 24d9: 01 81 3a    ..:
	dad	h		;; 24dc: 29          )
	dad	b		;; 24dd: 09          .
	push	h		;; 24de: e5          .
	lhld	L3e26		;; 24df: 2a 26 3e    *&>
	mvi	h,000h		;; 24e2: 26 00       &.
	lxi	b,L3a89		;; 24e4: 01 89 3a    ..:
	dad	h		;; 24e7: 29          )
	dad	b		;; 24e8: 09          .
	pop	d		;; 24e9: d1          .
	call	addxxx		;; 24ea: cd 0e 38    ..8
	push	h		;; 24ed: e5          .
	lhld	L3e26		;; 24ee: 2a 26 3e    *&>
	mvi	h,000h		;; 24f1: 26 00       &.
	lxi	b,L3a81		;; 24f3: 01 81 3a    ..:
	dad	h		;; 24f6: 29          )
	dad	b		;; 24f7: 09          .
	pop	b		;; 24f8: c1          .
	mov	m,c		;; 24f9: 71          q
	inx	h		;; 24fa: 23          #
	mov	m,b		;; 24fb: 70          p
	lhld	L3e26		;; 24fc: 2a 26 3e    *&>
	mvi	h,000h		;; 24ff: 26 00       &.
	push	b		;; 2501: c5          .
	lxi	b,L3a79		;; 2502: 01 79 3a    .y:
	dad	h		;; 2505: 29          )
	dad	b		;; 2506: 09          .
	pop	b		;; 2507: c1          .
	mov	m,c		;; 2508: 71          q
	inx	h		;; 2509: 23          #
	mov	m,b		;; 250a: 70          p
	lhld	L3e26		;; 250b: 2a 26 3e    *&>
	mvi	h,000h		;; 250e: 26 00       &.
	lxi	b,L3a89		;; 2510: 01 89 3a    ..:
	dad	h		;; 2513: 29          )
	dad	b		;; 2514: 09          .
	mvi	a,000h		;; 2515: 3e 00       >.
	mov	m,a		;; 2517: 77          w
	inx	h		;; 2518: 23          #
	mvi	m,000h		;; 2519: 36 00       6.
	lda	L3e26		;; 251b: 3a 26 3e    :&>
	inr	a		;; 251e: 3c          <
	sta	L3e26		;; 251f: 32 26 3e    2&>
	jnz	L24cb		;; 2522: c2 cb 24    ..$
L2525:	lxi	b,L3a73		;; 2525: 01 73 3a    .s:
	lxi	d,L3a71		;; 2528: 11 71 3a    .q:
	call	subxxx		;; 252b: cd 9e 38    ..8
	jnc	L2537		;; 252e: d2 37 25    .7%
	lhld	L3a71		;; 2531: 2a 71 3a    *q:
	shld	L3a73		;; 2534: 22 73 3a    "s:
L2537:	lda	L0188		;; 2537: 3a 88 01    :..
	rar			;; 253a: 1f          .
	jnc	L2547		;; 253b: d2 47 25    .G%
	call	L12b8		;; 253e: cd b8 12    ...
	lhld	L39a6		;; 2541: 2a a6 39    *.9
	shld	L3a71		;; 2544: 22 71 3a    "q:
L2547:	mvi	c,001h		;; 2547: 0e 01       ..
	call	L205e		;; 2549: cd 5e 20    .^ 
	lda	L3a5f		;; 254c: 3a 5f 3a    :_:
	cma			;; 254f: 2f          /
	sta	L3a5e		;; 2550: 32 5e 3a    2^:
	lda	L397b		;; 2553: 3a 7b 39    :{9
	rar			;; 2556: 1f          .
	jnc	L255d		;; 2557: d2 5d 25    .]%
	call	L21ec		;; 255a: cd ec 21    ...
L255d:	ret			;; 255d: c9          .

L255e:	lxi	h,L3e29		;; 255e: 21 29 3e    .)>
	mov	m,e		;; 2561: 73          s
	dcx	h		;; 2562: 2b          +
	mov	m,b		;; 2563: 70          p
	dcx	h		;; 2564: 2b          +
	mov	m,c		;; 2565: 71          q
	lda	L3e29		;; 2566: 3a 29 3e    :)>
	cpi	003h		;; 2569: fe 03       ..
	jnz	L2588		;; 256b: c2 88 25    ..%
	lhld	L3a67		;; 256e: 2a 67 3a    *g:
	xchg			;; 2571: eb          .
	lhld	L3e27		;; 2572: 2a 27 3e    *'>
	dad	d		;; 2575: 19          .
	shld	L3e27		;; 2576: 22 27 3e    "'>
	lda	L3a66		;; 2579: 3a 66 3a    :f:
	rar			;; 257c: 1f          .
	jnc	L2585		;; 257d: d2 85 25    ..%
	lxi	h,L3e29		;; 2580: 21 29 3e    .)>
	mvi	m,000h		;; 2583: 36 00       6.
L2585:	jmp	L259d		;; 2585: c3 9d 25    ..%

L2588:	lhld	L3e29		;; 2588: 2a 29 3e    *)>
	mvi	h,000h		;; 258b: 26 00       &.
	lxi	b,L3a81		;; 258d: 01 81 3a    ..:
	dad	h		;; 2590: 29          )
	dad	b		;; 2591: 09          .
	lxi	d,L3e27		;; 2592: 11 27 3e    .'>
	call	addxxx		;; 2595: cd 0e 38    ..8
	xchg			;; 2598: eb          .
	dcx	h		;; 2599: 2b          +
	mov	m,e		;; 259a: 73          s
	inx	h		;; 259b: 23          #
	mov	m,d		;; 259c: 72          r
L259d:	lhld	segmnt		;; 259d: 2a 5d 3a    *]:
	mvi	h,000h		;; 25a0: 26 00       &.
	lxi	b,L3a79		;; 25a2: 01 79 3a    .y:
	dad	h		;; 25a5: 29          )
	dad	b		;; 25a6: 09          .
	mov	c,m		;; 25a7: 4e          N
	inx	h		;; 25a8: 23          #
	mov	b,m		;; 25a9: 46          F
	lhld	segmnt		;; 25aa: 2a 5d 3a    *]:
	xchg			;; 25ad: eb          .
	call	L10ce		;; 25ae: cd ce 10    ...
	rar			;; 25b1: 1f          .
	jnc	L25c7		;; 25b2: d2 c7 25    ..%
	lhld	L3e27		;; 25b5: 2a 27 3e    *'>
	mov	b,h		;; 25b8: 44          D
	mov	c,l		;; 25b9: 4d          M
	call	L1015		;; 25ba: cd 15 10    ...
	lhld	L3e29		;; 25bd: 2a 29 3e    *)>
	mov	c,l		;; 25c0: 4d          M
	call	L108b		;; 25c1: cd 8b 10    ...
	jmp	L25ef		;; 25c4: c3 ef 25    ..%

L25c7:	lhld	segmnt		;; 25c7: 2a 5d 3a    *]:
	mvi	h,0		;; 25ca: 26 00       &.
	lxi	b,L3a79		;; 25cc: 01 79 3a    .y:
	dad	h		;; 25cf: 29          )
	dad	b		;; 25d0: 09          .
	mov	c,m		;; 25d1: 4e          N
	inx	h		;; 25d2: 23          #
	mov	b,m		;; 25d3: 46          F
	push	b		;; 25d4: c5          .
	lhld	L3e27		;; 25d5: 2a 27 3e    *'>
	push	h		;; 25d8: e5          .
	lhld	L3e29		;; 25d9: 2a 29 3e    *)>
	push	h		;; 25dc: e5          .
	mvi	c,0		;; 25dd: 0e 00       ..
	push	b		;; 25df: c5          .
	lhld	segmnt		;; 25e0: 2a 5d 3a    *]:
	push	h		;; 25e3: e5          .
	mvi	c,0		;; 25e4: 0e 00       ..
	push	b		;; 25e6: c5          .
	mvi	e,0		;; 25e7: 1e 00       ..
	lxi	b,0		;; 25e9: 01 00 00    ...
	call	L1135		;; 25ec: cd 35 11    .5.
L25ef:	mvi	c,0		;; 25ef: 0e 00       ..
	call	L2079		;; 25f1: cd 79 20    .y 
	mvi	c,0		;; 25f4: 0e 00       ..
	call	L2079		;; 25f6: cd 79 20    .y 
	ret			;; 25f9: c9          .

L25fa:	lxi	h,L3e2a		;; 25fa: 21 2a 3e    .*>
	mov	m,c		;; 25fd: 71          q
	lda	L3e2a		;; 25fe: 3a 2a 3e    :*>
	cpi	005h		;; 2601: fe 05       ..
	jc	L2609		;; 2603: da 09 26    ..&
	call	getrel		;; 2606: cd de 1f    ...
L2609:	mvi	a,007h		;; 2609: 3e 07       >.
	lxi	h,L3e2a		;; 260b: 21 2a 3e    .*>
	cmp	m		;; 260e: be          .
	jc	L2615		;; 260f: da 15 26    ..&
	call	relnam		;; 2612: cd ed 1f    ...
L2615:	lda	L3e2a		;; 2615: 3a 2a 3e    :*>
	cpi	000h		;; 2618: fe 00       ..
	jnz	L2623		;; 261a: c2 23 26    .#&
	call	L222b		;; 261d: cd 2b 22    .+"
	jmp	L26bf		;; 2620: c3 bf 26    ..&

L2623:	lda	L3e2a		;; 2623: 3a 2a 3e    :*>
	cpi	002h		;; 2626: fe 02       ..
	jnz	L2631		;; 2628: c2 31 26    .1&
	call	L2270		;; 262b: cd 70 22    .p"
	jmp	L26bf		;; 262e: c3 bf 26    ..&

L2631:	lda	L3e2a		;; 2631: 3a 2a 3e    :*>
	cpi	00eh		;; 2634: fe 0e       ..
	jnz	L263f		;; 2636: c2 3f 26    .?&
	call	L246b		;; 2639: cd 6b 24    .k$
	jmp	L26bf		;; 263c: c3 bf 26    ..&

L263f:	lda	L3a5e		;; 263f: 3a 5e 3a    :^:
	rar			;; 2642: 1f          .
	jnc	L26bf		;; 2643: d2 bf 26    ..&
	lda	L3e2a		;; 2646: 3a 2a 3e    :*>
	dcr	a		;; 2649: 3d          =
	mov	c,a		;; 264a: 4f          O
	mvi	b,000h		;; 264b: 06 00       ..
	lxi	h,L26a5		;; 264d: 21 a5 26    ..&
	dad	b		;; 2650: 09          .
	dad	b		;; 2651: 09          .
	mov	e,m		;; 2652: 5e          ^
	inx	h		;; 2653: 23          #
	mov	d,m		;; 2654: 56          V
	xchg			;; 2655: eb          .
	pchl			;; 2656: e9          .

L2657:	call	L2249		;; 2657: cd 49 22    .I"
	jmp	L26bf		;; 265a: c3 bf 26    ..&

L265d:	jmp	L26bf		;; 265d: c3 bf 26    ..&

L2660:	call	L2288		;; 2660: cd 88 22    .."
	jmp	L26bf		;; 2663: c3 bf 26    ..&

L2666:	lxi	b,L3e03		;; 2666: 01 03 3e    ..>
	call	pagmsg		;; 2669: cd c8 02    ...
	jmp	L26bf		;; 266c: c3 bf 26    ..&

L266f:	call	L22b5		;; 266f: cd b5 22    .."
	jmp	L26bf		;; 2672: c3 bf 26    ..&

L2675:	call	L231d		;; 2675: cd 1d 23    ..#
	jmp	L26bf		;; 2678: c3 bf 26    ..&

L267b:	call	L2354		;; 267b: cd 54 23    .T#
	jmp	L26bf		;; 267e: c3 bf 26    ..&

L2681:	call	L23f2		;; 2681: cd f2 23    ..#
	jmp	L26bf		;; 2684: c3 bf 26    ..&

L2687:	call	L23c8		;; 2687: cd c8 23    ..#
	jmp	L26bf		;; 268a: c3 bf 26    ..&

L268d:	call	L2400		;; 268d: cd 00 24    ..$
	jmp	L26bf		;; 2690: c3 bf 26    ..&

L2693:	call	L2407		;; 2693: cd 07 24    ..$
	jmp	L26bf		;; 2696: c3 bf 26    ..&

L2699:	call	L2451		;; 2699: cd 51 24    .Q$
	jmp	L26bf		;; 269c: c3 bf 26    ..&

L269f:	call	L2464		;; 269f: cd 64 24    .d$
	jmp	L26bf		;; 26a2: c3 bf 26    ..&

L26a5:	dw	L2657
	dw	L265d
	dw	L2660
	dw	L2666
	dw	L266f
	dw	L2675
	dw	L267b
	dw	L2681
	dw	L2687
	dw	L268d
	dw	L2693
	dw	L2699
	dw	L269f
L26bf:	ret			;; 26bf: c9          .

L26c0:	lxi	h,L3e2b		;; 26c0: 21 2b 3e    .+>
	mvi	m,16		;; 26c3: 36 10       6.
	mvi	c,1		;; 26c5: 0e 01       ..
	call	getbts		;; 26c7: cd f1 29    ..)
	cpi	0		;; 26ca: fe 00       ..
	jnz	L26e8		;; 26cc: c2 e8 26    ..&
	; abs byte, copy direct
	mvi	c,8		;; 26cf: 0e 08       ..
	call	getbts		;; 26d1: cd f1 29    ..)
	sta	L3e2d		;; 26d4: 32 2d 3e    2->
	lda	L3a5e		;; 26d7: 3a 5e 3a    :^:
	rar			;; 26da: 1f          .
	jnc	L26e5		;; 26db: d2 e5 26    ..&
	lhld	L3e2d		;; 26de: 2a 2d 3e    *->
	mov	c,l		;; 26e1: 4d          M
	call	L2079		;; 26e2: cd 79 20    .y 
L26e5:	jmp	L2728		;; 26e5: c3 28 27    .('

L26e8:	mvi	c,002h		;; 26e8: 0e 02       ..
	call	getbts		;; 26ea: cd f1 29    ..)
	sta	L3e2c		;; 26ed: 32 2c 3e    2,>
	cpi	000h		;; 26f0: fe 00       ..
	jnz	L270f		;; 26f2: c2 0f 27    ..'
	mvi	c,004h		;; 26f5: 0e 04       ..
	call	getbts		;; 26f7: cd f1 29    ..)
	sta	L3e2b		;; 26fa: 32 2b 3e    2+>
	lda	L3e2b		;; 26fd: 3a 2b 3e    :+>
	cpi	00fh		;; 2700: fe 0f       ..
	jnc	L270c		;; 2702: d2 0c 27    ..'
	lhld	L3e2b		;; 2705: 2a 2b 3e    *+>
	mov	c,l		;; 2708: 4d          M
	call	L25fa		;; 2709: cd fa 25    ..%
L270c:	jmp	L2728		;; 270c: c3 28 27    .('

L270f:	call	getadr		;; 270f: cd 95 1f    ...
	shld	L3e2e		;; 2712: 22 2e 3e    ".>
	lda	L3a5e		;; 2715: 3a 5e 3a    :^:
	rar			;; 2718: 1f          .
	jnc	L2728		;; 2719: d2 28 27    .('
	lhld	L3e2e		;; 271c: 2a 2e 3e    *.>
	mov	b,h		;; 271f: 44          D
	mov	c,l		;; 2720: 4d          M
	lhld	L3e2c		;; 2721: 2a 2c 3e    *,>
	xchg			;; 2724: eb          .
	call	L255e		;; 2725: cd 5e 25    .^%
L2728:	lda	L3e2b		;; 2728: 3a 2b 3e    :+>
	ret			;; 272b: c9          .

L272c:	call	L26c0		;; 272c: cd c0 26    ..&
	cpi	00fh		;; 272f: fe 0f       ..
	jz	L2737		;; 2731: ca 37 27    .7'
	jmp	L272c		;; 2734: c3 2c 27    .,'

L2737:	ret			;; 2737: c9          .

L2738:	lxi	h,L3a30		;; 2738: 21 30 3a    .0:
	mvi	m,008h		;; 273b: 36 08       6.
L273d:	call	L26c0		;; 273d: cd c0 26    ..&
	cpi	00eh		;; 2740: fe 0e       ..
	jz	L2748		;; 2742: ca 48 27    .H'
	jmp	L273d		;; 2745: c3 3d 27    .='

L2748:	ret			;; 2748: c9          .

L2749:	lxi	h,L3a30		;; 2749: 21 30 3a    .0:
	mvi	m,008h		;; 274c: 36 08       6.
	lxi	h,1024		;; 274e: 21 00 04    ...
	shld	L3a31		;; 2751: 22 31 3a    "1:
	shld	L3a37		;; 2754: 22 37 3a    "7:
	lda	L3a21		;; 2757: 3a 21 3a    :.:
	rar			;; 275a: 1f          .
	jnc	L27c5		;; 275b: d2 c5 27    ..'
	lhld	L3a1f		;; 275e: 2a 1f 3a    *.:
	lxi	d,1024		;; 2761: 11 00 04    ...
	call	subx		;; 2764: cd 97 38    ..8
	shld	L3a31		;; 2767: 22 31 3a    "1:
	shld	L3a37		;; 276a: 22 37 3a    "7:
	mvi	l,020h		;; 276d: 2e 20       . 
	lxi	d,L39fc		;; 276f: 11 fc 39    ..9
	lxi	b,deffcb	;; 2772: 01 5c 00    .\.
L2775:	ldax	b		;; 2775: 0a          .
	stax	d		;; 2776: 12          .
	inx	b		;; 2777: 03          .
	inx	d		;; 2778: 13          .
	dcr	l		;; 2779: 2d          -
	jnz	L2775		;; 277a: c2 75 27    .u'
	mvi	c,008h		;; 277d: 0e 08       ..
	call	getbts		;; 277f: cd f1 29    ..)
	sta	L39fa		;; 2782: 32 fa 39    2.9
	lxi	h,deffcb+12	;; 2785: 21 68 00    .h.
	cmp	m		;; 2788: be          .
	jz	L27a6		;; 2789: ca a6 27    ..'
	lda	L39fa		;; 278c: 3a fa 39    :.9
	sta	deffcb+12	;; 278f: 32 68 00    2h.
	lxi	b,deffcb	;; 2792: 01 5c 00    .\.
	call	fopen		;; 2795: cd 95 36    ..6
	cpi	0ffh		;; 2798: fe ff       ..
	jnz	L27a6		;; 279a: c2 a6 27    ..'
	lxi	d,deffcb	;; 279d: 11 5c 00    .\.
	lxi	b,L3da9		;; 27a0: 01 a9 3d    ..=
	call	L3534		;; 27a3: cd 34 35    .45
L27a6:	mvi	c,008h		;; 27a6: 0e 08       ..
	call	getbts		;; 27a8: cd f1 29    ..)
	sta	deffcb+32	;; 27ab: 32 7c 00    2|.
	sta	L39fb		;; 27ae: 32 fb 39    2.9
	lxi	h,L3a1c		;; 27b1: 21 1c 3a    ..:
	mvi	m,001h		;; 27b4: 36 01       6.
	lhld	L3a37		;; 27b6: 2a 37 3a    *7:
	shld	L3a31		;; 27b9: 22 31 3a    "1:
	lxi	h,00000h	;; 27bc: 21 00 00    ...
	shld	L39f6		;; 27bf: 22 f6 39    ".9
	shld	L39f8		;; 27c2: 22 f8 39    ".9
L27c5:	mvi	c,001h		;; 27c5: 0e 01       ..
	call	L205e		;; 27c7: cd 5e 20    .^ 
	lda	L3a5f		;; 27ca: 3a 5f 3a    :_:
	cma			;; 27cd: 2f          /
	sta	L3a5e		;; 27ce: 32 5e 3a    2^:
	lda	L3a21		;; 27d1: 3a 21 3a    :.:
	lxi	h,L3a5f		;; 27d4: 21 5f 3a    ._:
	ana	m		;; 27d7: a6          .
	rar			;; 27d8: 1f          .
	jnc	L27e2		;; 27d9: d2 e2 27    ..'
	call	L0dfd		;; 27dc: cd fd 0d    ...
	jmp	L27e5		;; 27df: c3 e5 27    ..'

L27e2:	call	L272c		;; 27e2: cd 2c 27    .,'
L27e5:	ret			;; 27e5: c9          .

L27e6:	lda	deffcb+9	;; 27e6: 3a 65 00    :e.
	ani	07fh		;; 27e9: e6 7f       ..
	cpi	' '		;; 27eb: fe 20       . 
	jnz	L2800		;; 27ed: c2 00 28    ..(
	mvi	l,3		;; 27f0: 2e 03       ..
	lxi	d,deffcb+9	;; 27f2: 11 65 00    .e.
	lxi	b,relsfx	;; 27f5: 01 89 1f    ...
L27f8:	ldax	b		;; 27f8: 0a          .
	stax	d		;; 27f9: 12          .
	inx	b		;; 27fa: 03          .
	inx	d		;; 27fb: 13          .
	dcr	l		;; 27fc: 2d          -
	jnz	L27f8		;; 27fd: c2 f8 27    ..'
L2800:	lxi	b,irlsfx	;; 2800: 01 8c 1f    ...
	push	b		;; 2803: c5          .
	mvi	e,3		;; 2804: 1e 03       ..
	lxi	b,deffcb+9	;; 2806: 01 65 00    .e.
	call	strncm		;; 2809: cd 3e 2a    .>*
	sta	L3a21		;; 280c: 32 21 3a    2.:
	lxi	b,deffcb	;; 280f: 01 5c 00    .\.
	call	L3564		;; 2812: cd 64 35    .d5
	call	L2749		;; 2815: cd 49 27    .I'
	ret			;; 2818: c9          .

L2819:	lxi	b,L1f7d		;; 2819: 01 7d 1f    .}.
	push	b		;; 281c: c5          .
	mvi	e,000h		;; 281d: 1e 00       ..
	mvi	c,006h		;; 281f: 0e 06       ..
	call	L1512		;; 2821: cd 12 15    ...
	cma			;; 2824: 2f          /
	rar			;; 2825: 1f          .
	jnc	L2842		;; 2826: d2 42 28    .B(
	lxi	b,L1f7d		;; 2829: 01 7d 1f    .}.
	push	b		;; 282c: c5          .
	mvi	c,006h		;; 282d: 0e 06       ..
	push	b		;; 282f: c5          .
	lxi	b,00000h	;; 2830: 01 00 00    ...
	push	b		;; 2833: c5          .
	mvi	c,001h		;; 2834: 0e 01       ..
	push	b		;; 2836: c5          .
	mvi	c,000h		;; 2837: 0e 00       ..
	push	b		;; 2839: c5          .
	lxi	d,00000h	;; 283a: 11 00 00    ...
	mvi	c,000h		;; 283d: 0e 00       ..
	call	L1589		;; 283f: cd 89 15    ...
L2842:	ret			;; 2842: c9          .

L2843:	call	L04bd		;; 2843: cd bd 04    ...
	shld	cursym		;; 2846: 22 64 3a    "d:
L2849:	lxi	b,L3a60		;; 2849: 01 60 3a    .`:
	lxi	d,cursym		;; 284c: 11 64 3a    .d:
	call	subxxx		;; 284f: cd 9e 38    ..8
	jnc	L290f		;; 2852: d2 0f 29    ..)
	call	getf1		;; 2855: cd b9 13    ...
	rar			;; 2858: 1f          .
	jnc	L28fe		;; 2859: d2 fe 28    ..(
	lda	libdst		;; 285c: 3a 76 39    :v9
	sta	deffcb		;; 285f: 32 5c 00    2\.
	lxi	h,L3e30		;; 2862: 21 30 3e    .0>
	mvi	m,001h		;; 2865: 36 01       6.
L2867:	mvi	a,008h		;; 2867: 3e 08       >.
	lxi	h,L3e30		;; 2869: 21 30 3e    .0>
	cmp	m		;; 286c: be          .
	jc	L28af		;; 286d: da af 28    ..(
	call	getlen		;; 2870: cd 68 13    .h.
	lxi	h,L3e30		;; 2873: 21 30 3e    .0>
	cmp	m		;; 2876: be          .
	jnc	L2888		;; 2877: d2 88 28    ..(
	lhld	L3e30		;; 287a: 2a 30 3e    *0>
	mvi	h,000h		;; 287d: 26 00       &.
	lxi	b,deffcb	;; 287f: 01 5c 00    .\.
	dad	b		;; 2882: 09          .
	mvi	m,020h		;; 2883: 36 20       6 
	jmp	L28a5		;; 2885: c3 a5 28    ..(

L2888:	lda	L3e30		;; 2888: 3a 30 3e    :0>
	dcr	a		;; 288b: 3d          =
	mov	c,a		;; 288c: 4f          O
	mvi	b,000h		;; 288d: 06 00       ..
	lxi	h,6		;; 288f: 21 06 00    ...
	dad	b		;; 2892: 09          .
	xchg			;; 2893: eb          .
	lhld	cursym		;; 2894: 2a 64 3a    *d:
	dad	d		;; 2897: 19          .
	push	h		;; 2898: e5          .
	lhld	L3e30		;; 2899: 2a 30 3e    *0>
	mvi	h,000h		;; 289c: 26 00       &.
	lxi	b,deffcb	;; 289e: 01 5c 00    .\.
	dad	b		;; 28a1: 09          .
	pop	d		;; 28a2: d1          .
	ldax	d		;; 28a3: 1a          .
	mov	m,a		;; 28a4: 77          w
L28a5:	lda	L3e30		;; 28a5: 3a 30 3e    :0>
	inr	a		;; 28a8: 3c          <
	sta	L3e30		;; 28a9: 32 30 3e    20>
	jnz	L2867		;; 28ac: c2 67 28    .g(
L28af:	lxi	h,L3a21		;; 28af: 21 21 3a    ..:
	mvi	m,001h		;; 28b2: 36 01       6.
	mvi	l,003h		;; 28b4: 2e 03       ..
	lxi	d,deffcb+9	;; 28b6: 11 65 00    .e.
	lxi	b,irxsfx	;; 28b9: 01 8f 1f    ...
L28bc:	ldax	b		;; 28bc: 0a          .
	stax	d		;; 28bd: 12          .
	inx	b		;; 28be: 03          .
	inx	d		;; 28bf: 13          .
	dcr	l		;; 28c0: 2d          -
	jnz	L28bc		;; 28c1: c2 bc 28    ..(
	lxi	b,deffcb	;; 28c4: 01 5c 00    .\.
	call	L3557		;; 28c7: cd 57 35    .W5
	cma			;; 28ca: 2f          /
	rar			;; 28cb: 1f          .
	jnc	L28ea		;; 28cc: d2 ea 28    ..(
	lxi	h,L3a21		;; 28cf: 21 21 3a    ..:
	mvi	m,000h		;; 28d2: 36 00       6.
	mvi	l,003h		;; 28d4: 2e 03       ..
	lxi	d,deffcb+9	;; 28d6: 11 65 00    .e.
	lxi	b,rexsfx	;; 28d9: 01 92 1f    ...
L28dc:	ldax	b		;; 28dc: 0a          .
	stax	d		;; 28dd: 12          .
	inx	b		;; 28de: 03          .
	inx	d		;; 28df: 13          .
	dcr	l		;; 28e0: 2d          -
	jnz	L28dc		;; 28e1: c2 dc 28    ..(
	lxi	b,deffcb	;; 28e4: 01 5c 00    .\.
	call	L3564		;; 28e7: cd 64 35    .d5
L28ea:	lhld	cursym		;; 28ea: 2a 64 3a    *d:
	shld	L3e31		;; 28ed: 22 31 3e    "1>
	lxi	h,L3a5f		;; 28f0: 21 5f 3a    ._:
	mvi	m,001h		;; 28f3: 36 01       6.
	call	L2749		;; 28f5: cd 49 27    .I'
	lhld	L3e31		;; 28f8: 2a 31 3e    *1>
	shld	cursym		;; 28fb: 22 64 3a    "d:
L28fe:	call	getsln		;; 28fe: cd 84 13    ...
	lxi	d,cursym		;; 2901: 11 64 3a    .d:
	call	addxxa		;; 2904: cd 19 38    ..8
	xchg			;; 2907: eb          .
	dcx	h		;; 2908: 2b          +
	mov	m,e		;; 2909: 73          s
	inx	h		;; 290a: 23          #
	mov	m,d		;; 290b: 72          r
	jmp	L2849		;; 290c: c3 49 28    .I(

L290f:	ret			;; 290f: c9          .

L2910:	mvi	l,006h		;; 2910: 2e 06       ..
	lxi	d,rellab		;; 2912: 11 a2 3a    ..:
	lxi	b,L1f83		;; 2915: 01 83 1f    ...
L2918:	ldax	b		;; 2918: 0a          .
	stax	d		;; 2919: 12          .
	inx	b		;; 291a: 03          .
	inx	d		;; 291b: 13          .
	dcr	l		;; 291c: 2d          -
	jnz	L2918		;; 291d: c2 18 29    ..)
	lxi	h,rellen		;; 2920: 21 a1 3a    ..:
	mvi	m,006h		;; 2923: 36 06       6.
	lxi	h,relseg		;; 2925: 21 9e 3a    ..:
	mvi	m,001h		;; 2928: 36 01       6.
	mvi	c,001h		;; 292a: 0e 01       ..
	call	L205e		;; 292c: cd 5e 20    .^ 
	call	L04bd		;; 292f: cd bd 04    ...
	shld	cursym		;; 2932: 22 64 3a    "d:
L2935:	lxi	b,L3a60		;; 2935: 01 60 3a    .`:
	lxi	d,cursym		;; 2938: 11 64 3a    .d:
	call	subxxx		;; 293b: cd 9e 38    ..8
	jnc	L29f0		;; 293e: d2 f0 29    ..)
	call	getf3		;; 2941: cd d4 13    ...
	cma			;; 2944: 2f          /
	rar			;; 2945: 1f          .
	jnc	L29df		;; 2946: d2 df 29    ..)
	lhld	L3a7b		;; 2949: 2a 7b 3a    *{:
	mov	b,h		;; 294c: 44          D
	mov	c,l		;; 294d: 4d          M
	call	setval		;; 294e: cd 3e 14    .>.
	mvi	c,1		;; 2951: 0e 01       ..
	call	setseg		;; 2953: cd 66 14    .f.
	mvi	c,1		;; 2956: 0e 01       ..
	call	L2079		;; 2958: cd 79 20    .y 
	mvi	e,1		;; 295b: 1e 01       ..
	lxi	b,6		;; 295d: 01 06 00    ...
	call	L255e		;; 2960: cd 5e 25    .^%
	mvi	c,0c3h		;; 2963: 0e c3       ..
	call	L2079		;; 2965: cd 79 20    .y 
	lxi	h,4		;; 2968: 21 04 00    ...
	shld	reladr		;; 296b: 22 9f 3a    ".:
	mvi	c,0		;; 296e: 0e 00       ..
	call	L2079		;; 2970: cd 79 20    .y 
	mvi	c,0		;; 2973: 0e 00       ..
	call	L2079		;; 2975: cd 79 20    .y 
	lhld	cursym		;; 2978: 2a 64 3a    *d:
	shld	L3e34		;; 297b: 22 34 3e    "4>
	call	L231d		;; 297e: cd 1d 23    ..#
	lhld	L3e34		;; 2981: 2a 34 3e    *4>
	shld	cursym		;; 2984: 22 64 3a    "d:
	lxi	h,L3e33		;; 2987: 21 33 3e    .3>
	mvi	m,001h		;; 298a: 36 01       6.
L298c:	mvi	a,008h		;; 298c: 3e 08       >.
	lxi	h,L3e33		;; 298e: 21 33 3e    .3>
	cmp	m		;; 2991: be          .
	jc	L29c5		;; 2992: da c5 29    ..)
	call	getlen		;; 2995: cd 68 13    .h.
	lxi	h,L3e33		;; 2998: 21 33 3e    .3>
	cmp	m		;; 299b: be          .
	jc	L29b6		;; 299c: da b6 29    ..)
	lda	L3e33		;; 299f: 3a 33 3e    :3>
	dcr	a		;; 29a2: 3d          =
	mov	c,a		;; 29a3: 4f          O
	mvi	b,0		;; 29a4: 06 00       ..
	lxi	h,6		;; 29a6: 21 06 00    ...
	dad	b		;; 29a9: 09          .
	xchg			;; 29aa: eb          .
	lhld	cursym		;; 29ab: 2a 64 3a    *d:
	dad	d		;; 29ae: 19          .
	mov	c,m		;; 29af: 4e          N
	call	L2079		;; 29b0: cd 79 20    .y 
	jmp	L29bb		;; 29b3: c3 bb 29    ..)

L29b6:	mvi	c,020h		;; 29b6: 0e 20       . 
	call	L2079		;; 29b8: cd 79 20    .y 
L29bb:	lda	L3e33		;; 29bb: 3a 33 3e    :3>
	inr	a		;; 29be: 3c          <
	sta	L3e33		;; 29bf: 32 33 3e    23>
	jnz	L298c		;; 29c2: c2 8c 29    ..)
L29c5:	lxi	d,0000eh	;; 29c5: 11 0e 00    ...
	lhld	L3a83		;; 29c8: 2a 83 3a    *.:
	dad	d		;; 29cb: 19          .
	shld	L3a83		;; 29cc: 22 83 3a    ".:
	lda	L0188		;; 29cf: 3a 88 01    :..
	rar			;; 29d2: 1f          .
	jnc	L29df		;; 29d3: d2 df 29    ..)
	call	L12b8		;; 29d6: cd b8 12    ...
	lhld	L39a6		;; 29d9: 2a a6 39    *.9
	shld	L3a71		;; 29dc: 22 71 3a    "q:
; cursym += cursym->slen
L29df:	call	getsln		;; 29df: cd 84 13    ...
	lxi	d,cursym	;; 29e2: 11 64 3a    .d:
	call	addxxa		;; 29e5: cd 19 38    ..8
	xchg			;; 29e8: eb          .
	dcx	h		;; 29e9: 2b          +
	mov	m,e		;; 29ea: 73          s
	inx	h		;; 29eb: 23          #
	mov	m,d		;; 29ec: 72          r
	jmp	L2935		;; 29ed: c3 35 29    .5)

L29f0:	ret			;; 29f0: c9          .

getbts:	mvi	b,0		;; 29f1: 06 00       ..
L29f3:	lxi	h,L3a30		;; 29f3: 21 30 3a    .0:
	inr	m		;; 29f6: 34          4
	mov	a,m		;; 29f7: 7e          ~
	cpi	9		;; 29f8: fe 09       ..
	jc	L2a28		;; 29fa: da 28 2a    .(*
	mvi	m,1		;; 29fd: 36 01       6.
	lhld	L3a31		;; 29ff: 2a 31 3a    *1:
	inx	h		;; 2a02: 23          #
	shld	L3a31		;; 2a03: 22 31 3a    "1:
	xchg			;; 2a06: eb          .
	lhld	L3a37		;; 2a07: 2a 37 3a    *7:
	mov	a,e		;; 2a0a: 7b          {
	sub	l		;; 2a0b: 95          .
	mov	a,d		;; 2a0c: 7a          z
	sbb	h		;; 2a0d: 9c          .
	jc	L2a1c		;; 2a0e: da 1c 2a    ..*
	lxi	h,0		;; 2a11: 21 00 00    ...
	shld	L3a31		;; 2a14: 22 31 3a    "1:
	push	b		;; 2a17: c5          .
	call	L202f		;; 2a18: cd 2f 20    ./ 
	pop	b		;; 2a1b: c1          .
L2a1c:	lhld	L3a31		;; 2a1c: 2a 31 3a    *1:
	xchg			;; 2a1f: eb          .
	lxi	h,L3e86		;; 2a20: 21 86 3e    ..>
	dad	d		;; 2a23: 19          .
	mov	a,m		;; 2a24: 7e          ~
	sta	L3e36		;; 2a25: 32 36 3e    26>
L2a28:	mov	a,b		;; 2a28: 78          x
	rlc			;; 2a29: 07          .
	ani	0feh		;; 2a2a: e6 fe       ..
	mov	b,a		;; 2a2c: 47          G
	lda	L3e36		;; 2a2d: 3a 36 3e    :6>
	rlc			;; 2a30: 07          .
	sta	L3e36		;; 2a31: 32 36 3e    26>
	ani	001h		;; 2a34: e6 01       ..
	ora	b		;; 2a36: b0          .
	mov	b,a		;; 2a37: 47          G
	dcr	c		;; 2a38: 0d          .
	jnz	L29f3		;; 2a39: c2 f3 29    ..)
	mov	a,b		;; 2a3c: 78          x
	ret			;; 2a3d: c9          .

; strncmp(BC,(TOS),E)
; E=len, (TOS)=ptr2, BC=ptr1
strncm:	mov	a,e		;; 2a3e: 7b          {
	pop	h		;; 2a3f: e1          .
	xthl			;; 2a40: e3          .
	mov	e,a		;; 2a41: 5f          _
L2a42:	ldax	b		;; 2a42: 0a          .
	cmp	m		;; 2a43: be          .
	jnz	L2a50		;; 2a44: c2 50 2a    .P*
	inx	b		;; 2a47: 03          .
	inx	h		;; 2a48: 23          #
	dcr	e		;; 2a49: 1d          .
	jnz	L2a42		;; 2a4a: c2 42 2a    .B*
	mvi	a,1		;; 2a4d: 3e 01       >.
	ret			;; 2a4f: c9          .

L2a50:	xra	a		;; 2a50: af          .
	ret			;; 2a51: c9          .

; clear memory at BC, length DE
bzero:	mov	h,b		;; 2a52: 60          `
	mov	l,c		;; 2a53: 69          i
	mvi	c,0		;; 2a54: 0e 00       ..
L2a56:	mov	m,c		;; 2a56: 71          q
	dcx	d		;; 2a57: 1b          .
	inx	h		;; 2a58: 23          #
	mov	a,d		;; 2a59: 7a          z
	ora	e		;; 2a5a: b3          .
	jnz	L2a56		;; 2a5b: c2 56 2a    .V*
	ret			;; 2a5e: c9          .

L2a5f:	db	'COM','PRL','RSP','SPR','OVL'
L2a6e:	db	'SYM'

L2a71:	lxi	h,L3e3b		;; 2a71: 21 3b 3e    .;>
	mov	m,c		;; 2a74: 71          q
	lhld	L3a35		;; 2a75: 2a 35 3a    *5:
	lxi	b,L3e86		;; 2a78: 01 86 3e    ..>
	dad	b		;; 2a7b: 09          .
	lda	L3e3b		;; 2a7c: 3a 3b 3e    :;>
	mov	m,a		;; 2a7f: 77          w
	lhld	L3a35		;; 2a80: 2a 35 3a    *5:
	inx	h		;; 2a83: 23          #
	shld	L3a35		;; 2a84: 22 35 3a    "5:
	xchg			;; 2a87: eb          .
	lxi	h,L3a33		;; 2a88: 21 33 3a    .3:
	call	L38b9		;; 2a8b: cd b9 38    ..8
	jc	L2aa6		;; 2a8e: da a6 2a    ..*
	lxi	b,L3e86		;; 2a91: 01 86 3e    ..>
	push	b		;; 2a94: c5          .
	lhld	L3a33		;; 2a95: 2a 33 3a    *3:
	mov	b,h		;; 2a98: 44          D
	mov	c,l		;; 2a99: 4d          M
	lxi	d,deffcb	;; 2a9a: 11 5c 00    .\.
	call	wrfile		;; 2a9d: cd 94 35    ..5
	lxi	h,0		;; 2aa0: 21 00 00    ...
	shld	L3a35		;; 2aa3: 22 35 3a    "5:
L2aa6:	ret			;; 2aa6: c9          .

L2aa7:	lxi	h,L3e3c		;; 2aa7: 21 3c 3e    .<>
	mov	m,c		;; 2aaa: 71          q
	lda	L3e38		;; 2aab: 3a 38 3e    :8>
	rlc			;; 2aae: 07          .
	lxi	h,L3e3c		;; 2aaf: 21 3c 3e    .<>
	ora	m		;; 2ab2: b6          .
	sta	L3e38		;; 2ab3: 32 38 3e    28>
	lda	L3e37		;; 2ab6: 3a 37 3e    :7>
	inr	a		;; 2ab9: 3c          <
	sta	L3e37		;; 2aba: 32 37 3e    27>
	cpi	008h		;; 2abd: fe 08       ..
	jnz	L2ad3		;; 2abf: c2 d3 2a    ..*
	lxi	h,L3e37		;; 2ac2: 21 37 3e    .7>
	mvi	m,000h		;; 2ac5: 36 00       6.
	lhld	L3e38		;; 2ac7: 2a 38 3e    *8>
	mov	c,l		;; 2aca: 4d          M
	call	L2a71		;; 2acb: cd 71 2a    .q*
	lxi	h,L3e38		;; 2ace: 21 38 3e    .8>
	mvi	m,000h		;; 2ad1: 36 00       6.
L2ad3:	ret			;; 2ad3: c9          .

L2ad4:	lxi	h,L3e3d		;; 2ad4: 21 3d 3e    .=>
	mov	m,c		;; 2ad7: 71          q
	lhld	L3e3d		;; 2ad8: 2a 3d 3e    *=>
	mov	c,l		;; 2adb: 4d          M
	call	L2a71		;; 2adc: cd 71 2a    .q*
	lhld	L3a41		;; 2adf: 2a 41 3a    *A:
	inx	h		;; 2ae2: 23          #
	shld	L3a41		;; 2ae3: 22 41 3a    "A:
	ret			;; 2ae6: c9          .

L2ae7:	lxi	h,L3e3f		;; 2ae7: 21 3f 3e    .?>
	mov	m,b		;; 2aea: 70          p
	dcx	h		;; 2aeb: 2b          +
	mov	m,c		;; 2aec: 71          q
	lhld	L3e3e		;; 2aed: 2a 3e 3e    *>>
	mov	a,l		;; 2af0: 7d          }
	mov	c,a		;; 2af1: 4f          O
	call	L2ad4		;; 2af2: cd d4 2a    ..*
	lhld	L3e3e		;; 2af5: 2a 3e 3e    *>>
	mov	a,h		;; 2af8: 7c          |
	mov	c,a		;; 2af9: 4f          O
	call	L2ad4		;; 2afa: cd d4 2a    ..*
	ret			;; 2afd: c9          .

L2afe:	lda	L3a9d		;; 2afe: 3a 9d 3a    :.:
	cpi	000h		;; 2b01: fe 00       ..
	jnz	L2b07		;; 2b03: c2 07 2b    ..+
	ret			;; 2b06: c9          .

L2b07:	lda	prlflg		;; 2b07: 3a 6f 39    :o9
	cpi	000h		;; 2b0a: fe 00       ..
	jz	L2b12		;; 2b0c: ca 12 2b    ..+
	call	L2c68		;; 2b0f: cd 68 2c    .h,
L2b12:	lhld	L3970		;; 2b12: 2a 70 39    *p9
	shld	L3a41		;; 2b15: 22 41 3a    "A:
	lda	L3a5c		;; 2b18: 3a 5c 3a    :\:
	rar			;; 2b1b: 1f          .
	jnc	L2b2c		;; 2b1c: d2 2c 2b    .,+
	mvi	c,0c3h		;; 2b1f: 0e c3       ..
	call	L2ad4		;; 2b21: cd d4 2a    ..*
	lhld	L3a56		;; 2b24: 2a 56 3a    *V:
	mov	b,h		;; 2b27: 44          D
	mov	c,l		;; 2b28: 4d          M
	call	L2ae7		;; 2b29: cd e7 2a    ..*
L2b2c:	lhld	L3a58		;; 2b2c: 2a 58 3a    *X:
	shld	L3a91		;; 2b2f: 22 91 3a    ".:
	lxi	h,L3e40		;; 2b32: 21 40 3e    .@>
	mvi	m,000h		;; 2b35: 36 00       6.
L2b37:	lda	L3a9d		;; 2b37: 3a 9d 3a    :.:
	dcr	a		;; 2b3a: 3d          =
	lxi	h,L3e40		;; 2b3b: 21 40 3e    .@>
	cmp	m		;; 2b3e: be          .
	jc	L2b71		;; 2b3f: da 71 2b    .q+
	lhld	L3e40		;; 2b42: 2a 40 3e    *@>
	mvi	h,000h		;; 2b45: 26 00       &.
	lxi	b,L3a99		;; 2b47: 01 99 3a    ..:
	dad	b		;; 2b4a: 09          .
	mov	c,m		;; 2b4b: 4e          N
	mvi	b,000h		;; 2b4c: 06 00       ..
	lxi	h,L3a91		;; 2b4e: 21 91 3a    ..:
	dad	b		;; 2b51: 09          .
	dad	b		;; 2b52: 09          .
	xchg			;; 2b53: eb          .
	lxi	b,L3970		;; 2b54: 01 70 39    .p9
	call	subxxx		;; 2b57: cd 9e 38    ..8
	jc	L2b6a		;; 2b5a: da 6a 2b    .j+
	lhld	L3e40		;; 2b5d: 2a 40 3e    *@>
	mvi	h,000h		;; 2b60: 26 00       &.
	lxi	b,L3a99		;; 2b62: 01 99 3a    ..:
	dad	b		;; 2b65: 09          .
	mov	c,m		;; 2b66: 4e          N
	call	L2b8d		;; 2b67: cd 8d 2b    ..+
L2b6a:	lxi	h,L3e40		;; 2b6a: 21 40 3e    .@>
	inr	m		;; 2b6d: 34          4
	jnz	L2b37		;; 2b6e: c2 37 2b    .7+
L2b71:	lda	prlflg		;; 2b71: 3a 6f 39    :o9
	sui	000h		;; 2b74: d6 00       ..
	adi	0ffh		;; 2b76: c6 ff       ..
	sbb	a		;; 2b78: 9f          .
	push	psw		;; 2b79: f5          .
	lda	prlflg		;; 2b7a: 3a 6f 39    :o9
	sui	004h		;; 2b7d: d6 04       ..
	adi	0ffh		;; 2b7f: c6 ff       ..
	sbb	a		;; 2b81: 9f          .
	pop	b		;; 2b82: c1          .
	mov	c,b		;; 2b83: 48          H
	ana	c		;; 2b84: a1          .
	rar			;; 2b85: 1f          .
	jnc	L2b8c		;; 2b86: d2 8c 2b    ..+
	call	L2d0c		;; 2b89: cd 0c 2d    ..-
L2b8c:	ret			;; 2b8c: c9          .

L2b8d:	lxi	h,L3e43		;; 2b8d: 21 43 3e    .C>
	mov	m,c		;; 2b90: 71          q
	lda	L3e43		;; 2b91: 3a 43 3e    :C>
	cpi	000h		;; 2b94: fe 00       ..
	jnz	L2ba2		;; 2b96: c2 a2 2b    ..+
	lhld	L3a58		;; 2b99: 2a 58 3a    *X:
	shld	L3e44		;; 2b9c: 22 44 3e    "D>
	jmp	L2bb3		;; 2b9f: c3 b3 2b    ..+

L2ba2:	lhld	L3e43		;; 2ba2: 2a 43 3e    *C>
	mvi	h,000h		;; 2ba5: 26 00       &.
	lxi	b,L3a91		;; 2ba7: 01 91 3a    ..:
	dad	h		;; 2baa: 29          )
	dad	b		;; 2bab: 09          .
	mov	e,m		;; 2bac: 5e          ^
	inx	h		;; 2bad: 23          #
	mov	d,m		;; 2bae: 56          V
	xchg			;; 2baf: eb          .
	shld	L3e44		;; 2bb0: 22 44 3e    "D>
L2bb3:	lxi	d,L3e44		;; 2bb3: 11 44 3e    .D>
	lxi	b,L3a41		;; 2bb6: 01 41 3a    .A:
	call	subxxx		;; 2bb9: cd 9e 38    ..8
	jnc	L2bc5		;; 2bbc: d2 c5 2b    ..+
	lxi	b,L39de		;; 2bbf: 01 de 39    ..9
	call	L36e2		;; 2bc2: cd e2 36    ..6
L2bc5:	lxi	b,L3e44		;; 2bc5: 01 44 3e    .D>
	lxi	d,L3a41		;; 2bc8: 11 41 3a    .A:
	call	subxxx		;; 2bcb: cd 9e 38    ..8
	jnc	L2bd9		;; 2bce: d2 d9 2b    ..+
	mvi	c,000h		;; 2bd1: 0e 00       ..
	call	L2ad4		;; 2bd3: cd d4 2a    ..*
	jmp	L2bc5		;; 2bd6: c3 c5 2b    ..+

L2bd9:	lhld	L3e43		;; 2bd9: 2a 43 3e    *C>
	mvi	h,000h		;; 2bdc: 26 00       &.
	lxi	b,L3b66		;; 2bde: 01 66 3b    .f;
	dad	h		;; 2be1: 29          )
	dad	b		;; 2be2: 09          .
	mov	c,m		;; 2be3: 4e          N
	inx	h		;; 2be4: 23          #
	mov	b,m		;; 2be5: 46          F
	call	L348b		;; 2be6: cd 8b 34    ..4
	lhld	L3e43		;; 2be9: 2a 43 3e    *C>
	mvi	h,000h		;; 2bec: 26 00       &.
	lxi	b,L3a79		;; 2bee: 01 79 3a    .y:
	dad	h		;; 2bf1: 29          )
	dad	b		;; 2bf2: 09          .
	mvi	a,000h		;; 2bf3: 3e 00       >.
	call	L38b6		;; 2bf5: cd b6 38    ..8
	jnc	L2c14		;; 2bf8: d2 14 2c    ..,
	lda	L3e43		;; 2bfb: 3a 43 3e    :C>
	cpi	000h		;; 2bfe: fe 00       ..
	jnz	L2c0e		;; 2c00: c2 0e 2c    ..,
	lhld	L3a58		;; 2c03: 2a 58 3a    *X:
	mov	b,h		;; 2c06: 44          D
	mov	c,l		;; 2c07: 4d          M
	call	L2c27		;; 2c08: cd 27 2c    .',
	jmp	L2c14		;; 2c0b: c3 14 2c    ..,

L2c0e:	lxi	b,00000h	;; 2c0e: 01 00 00    ...
	call	L2c27		;; 2c11: cd 27 2c    .',
L2c14:	lxi	d,L397c		;; 2c14: 11 7c 39    .|9
	lxi	b,L3a41		;; 2c17: 01 41 3a    .A:
	call	subxxx		;; 2c1a: cd 9e 38    ..8
	jnc	L2c26		;; 2c1d: d2 26 2c    .&,
	lhld	L3a41		;; 2c20: 2a 41 3a    *A:
	shld	L397c		;; 2c23: 22 7c 39    "|9
L2c26:	ret			;; 2c26: c9          .

L2c27:	lxi	h,L3e47		;; 2c27: 21 47 3e    .G>
	mov	m,b		;; 2c2a: 70          p
	dcx	h		;; 2c2b: 2b          +
	mov	m,c		;; 2c2c: 71          q
	lhld	L3e46		;; 2c2d: 2a 46 3e    *F>
	shld	L3e48		;; 2c30: 22 48 3e    "H>
L2c33:	lhld	L3e43		;; 2c33: 2a 43 3e    *C>
	mvi	h,000h		;; 2c36: 26 00       &.
	lxi	b,L3a79		;; 2c38: 01 79 3a    .y:
	dad	h		;; 2c3b: 29          )
	dad	b		;; 2c3c: 09          .
	lxi	d,L3e46		;; 2c3d: 11 46 3e    .F>
	call	addxxx		;; 2c40: cd 0e 38    ..8
	dcx	h		;; 2c43: 2b          +
	xchg			;; 2c44: eb          .
	lxi	h,L3e48		;; 2c45: 21 48 3e    .H>
	call	L38b9		;; 2c48: cd b9 38    ..8
	jc	L2c67		;; 2c4b: da 67 2c    .g,
	lhld	L3e48		;; 2c4e: 2a 48 3e    *H>
	mov	b,h		;; 2c51: 44          D
	mov	c,l		;; 2c52: 4d          M
	call	L34dc		;; 2c53: cd dc 34    ..4
	mov	c,a		;; 2c56: 4f          O
	call	L2ad4		;; 2c57: cd d4 2a    ..*
	lxi	d,00001h	;; 2c5a: 11 01 00    ...
	lhld	L3e48		;; 2c5d: 2a 48 3e    *H>
	dad	d		;; 2c60: 19          .
	shld	L3e48		;; 2c61: 22 48 3e    "H>
	jnc	L2c33		;; 2c64: d2 33 2c    .3,
L2c67:	ret			;; 2c67: c9          .

L2c68:	lda	L3a9d		;; 2c68: 3a 9d 3a    :.:
	dcr	a		;; 2c6b: 3d          =
	mov	c,a		;; 2c6c: 4f          O
	mvi	b,000h		;; 2c6d: 06 00       ..
	lxi	h,L3a99		;; 2c6f: 21 99 3a    ..:
	dad	b		;; 2c72: 09          .
	mov	c,m		;; 2c73: 4e          N
	mvi	b,000h		;; 2c74: 06 00       ..
	push	h		;; 2c76: e5          .
	lxi	h,L3a91		;; 2c77: 21 91 3a    ..:
	dad	b		;; 2c7a: 09          .
	dad	b		;; 2c7b: 09          .
	push	h		;; 2c7c: e5          .
	lxi	h,L3a79		;; 2c7d: 21 79 3a    .y:
	dad	b		;; 2c80: 09          .
	dad	b		;; 2c81: 09          .
	pop	d		;; 2c82: d1          .
	call	addxxx		;; 2c83: cd 0e 38    ..8
	xchg			;; 2c86: eb          .
	lhld	L3970		;; 2c87: 2a 70 39    *p9
	call	subx		;; 2c8a: cd 97 38    ..8
	shld	L3e41		;; 2c8d: 22 41 3e    "A>
	mvi	c,000h		;; 2c90: 0e 00       ..
	call	L2ad4		;; 2c92: cd d4 2a    ..*
	pop	h		;; 2c95: e1          .
	lhld	L3e41		;; 2c96: 2a 41 3e    *A>
	mov	b,h		;; 2c99: 44          D
	mov	c,l		;; 2c9a: 4d          M
	call	L2ae7		;; 2c9b: cd e7 2a    ..*
	mvi	c,000h		;; 2c9e: 0e 00       ..
	call	L2ad4		;; 2ca0: cd d4 2a    ..*
	lda	prlflg		;; 2ca3: 3a 6f 39    :o9
	cpi	004h		;; 2ca6: fe 04       ..
	jnz	L2cc1		;; 2ca8: c2 c1 2c    ..,
	lxi	b,00000h	;; 2cab: 01 00 00    ...
	call	L2ae7		;; 2cae: cd e7 2a    ..*
	mvi	c,000h		;; 2cb1: 0e 00       ..
	call	L2ad4		;; 2cb3: cd d4 2a    ..*
	lhld	L3970		;; 2cb6: 2a 70 39    *p9
	mov	b,h		;; 2cb9: 44          D
	mov	c,l		;; 2cba: 4d          M
	call	L2ae7		;; 2cbb: cd e7 2a    ..*
	jmp	L2cd4		;; 2cbe: c3 d4 2c    ..,

L2cc1:	lhld	L396d		;; 2cc1: 2a 6d 39    *m9
	mov	b,h		;; 2cc4: 44          D
	mov	c,l		;; 2cc5: 4d          M
	call	L2ae7		;; 2cc6: cd e7 2a    ..*
	mvi	c,000h		;; 2cc9: 0e 00       ..
	call	L2ad4		;; 2ccb: cd d4 2a    ..*
	lxi	b,00000h	;; 2cce: 01 00 00    ...
	call	L2ae7		;; 2cd1: cd e7 2a    ..*
L2cd4:	mvi	c,000h		;; 2cd4: 0e 00       ..
	call	L2ad4		;; 2cd6: cd d4 2a    ..*
	lda	L3972		;; 2cd9: 3a 72 39    :r9
	rar			;; 2cdc: 1f          .
	jnc	L2ceb		;; 2cdd: d2 eb 2c    ..,
	lhld	L3a83		;; 2ce0: 2a 83 3a    *.:
	mov	b,h		;; 2ce3: 44          D
	mov	c,l		;; 2ce4: 4d          M
	call	L2ae7		;; 2ce5: cd e7 2a    ..*
	jmp	L2cf1		;; 2ce8: c3 f1 2c    ..,

L2ceb:	lxi	b,00000h	;; 2ceb: 01 00 00    ...
	call	L2ae7		;; 2cee: cd e7 2a    ..*
L2cf1:	lxi	h,L3e4a		;; 2cf1: 21 4a 3e    .J>
	mvi	m,001h		;; 2cf4: 36 01       6.
L2cf6:	mvi	a,0f4h		;; 2cf6: 3e f4       >.
	lxi	h,L3e4a		;; 2cf8: 21 4a 3e    .J>
	cmp	m		;; 2cfb: be          .
	jc	L2d0b		;; 2cfc: da 0b 2d    ..-
	mvi	c,000h		;; 2cff: 0e 00       ..
	call	L2ad4		;; 2d01: cd d4 2a    ..*
	lxi	h,L3e4a		;; 2d04: 21 4a 3e    .J>
	inr	m		;; 2d07: 34          4
	jnz	L2cf6		;; 2d08: c2 f6 2c    ..,
L2d0b:	ret			;; 2d0b: c9          .

L2d0c:	lhld	L3970		;; 2d0c: 2a 70 39    *p9
	shld	L3a41		;; 2d0f: 22 41 3a    "A:
	lda	L3a5c		;; 2d12: 3a 5c 3a    :\:
	rar			;; 2d15: 1f          .
	jnc	L2d28		;; 2d16: d2 28 2d    .(-
	mvi	c,000h		;; 2d19: 0e 00       ..
	call	L2da6		;; 2d1b: cd a6 2d    ..-
	mvi	c,000h		;; 2d1e: 0e 00       ..
	call	L2da6		;; 2d20: cd a6 2d    ..-
	mvi	c,001h		;; 2d23: 0e 01       ..
	call	L2da6		;; 2d25: cd a6 2d    ..-
L2d28:	lxi	h,L3e4c		;; 2d28: 21 4c 3e    .L>
	mvi	m,000h		;; 2d2b: 36 00       6.
L2d2d:	lda	L3a9d		;; 2d2d: 3a 9d 3a    :.:
	dcr	a		;; 2d30: 3d          =
	lxi	h,L3e4c		;; 2d31: 21 4c 3e    .L>
	cmp	m		;; 2d34: be          .
	jc	L2d7c		;; 2d35: da 7c 2d    .|-
	lhld	L3e4c		;; 2d38: 2a 4c 3e    *L>
	mvi	h,000h		;; 2d3b: 26 00       &.
	lxi	b,L3a99		;; 2d3d: 01 99 3a    ..:
	dad	b		;; 2d40: 09          .
	mov	a,m		;; 2d41: 7e          ~
	sta	L3e4b		;; 2d42: 32 4b 3e    2K>
	cpi	000h		;; 2d45: fe 00       ..
	jz	L2d75		;; 2d47: ca 75 2d    .u-
L2d4a:	lhld	L3e4b		;; 2d4a: 2a 4b 3e    *K>
	mvi	h,000h		;; 2d4d: 26 00       &.
	lxi	b,L3a91		;; 2d4f: 01 91 3a    ..:
	dad	h		;; 2d52: 29          )
	dad	b		;; 2d53: 09          .
	lxi	d,L3a41		;; 2d54: 11 41 3a    .A:
	call	subxxm		;; 2d57: cd a0 38    ..8
	jnc	L2d65		;; 2d5a: d2 65 2d    .e-
	mvi	c,000h		;; 2d5d: 0e 00       ..
	call	L2da6		;; 2d5f: cd a6 2d    ..-
	jmp	L2d4a		;; 2d62: c3 4a 2d    .J-

L2d65:	lda	L0188		;; 2d65: 3a 88 01    :..
	rar			;; 2d68: 1f          .
	jnc	L2d72		;; 2d69: d2 72 2d    .r-
	call	L2e12		;; 2d6c: cd 12 2e    ...
	jmp	L2d75		;; 2d6f: c3 75 2d    .u-

L2d72:	call	L2dd3		;; 2d72: cd d3 2d    ..-
L2d75:	lxi	h,L3e4c		;; 2d75: 21 4c 3e    .L>
	inr	m		;; 2d78: 34          4
	jnz	L2d2d		;; 2d79: c2 2d 2d    .--
L2d7c:	lhld	L3970		;; 2d7c: 2a 70 39    *p9
	xchg			;; 2d7f: eb          .
	lhld	L3e41		;; 2d80: 2a 41 3e    *A>
	dad	d		;; 2d83: 19          .
	lxi	d,L3a41		;; 2d84: 11 41 3a    .A:
	call	subxx		;; 2d87: cd ae 38    ..8
	jnc	L2d95		;; 2d8a: d2 95 2d    ..-
	mvi	c,000h		;; 2d8d: 0e 00       ..
	call	L2da6		;; 2d8f: cd a6 2d    ..-
	jmp	L2d7c		;; 2d92: c3 7c 2d    .|-

L2d95:	lda	L3e37		;; 2d95: 3a 37 3e    :7>
	cpi	000h		;; 2d98: fe 00       ..
	jz	L2da5		;; 2d9a: ca a5 2d    ..-
	mvi	c,000h		;; 2d9d: 0e 00       ..
	call	L2da6		;; 2d9f: cd a6 2d    ..-
	jmp	L2d95		;; 2da2: c3 95 2d    ..-

L2da5:	ret			;; 2da5: c9          .

L2da6:	lxi	h,L3e4f		;; 2da6: 21 4f 3e    .O>
	mov	m,c		;; 2da9: 71          q
	lhld	L3e4f		;; 2daa: 2a 4f 3e    *O>
	mov	c,l		;; 2dad: 4d          M
	call	L2aa7		;; 2dae: cd a7 2a    ..*
	lhld	L3a41		;; 2db1: 2a 41 3a    *A:
	inx	h		;; 2db4: 23          #
	shld	L3a41		;; 2db5: 22 41 3a    "A:
	ret			;; 2db8: c9          .

L2db9:	lxi	d,L3e4d		;; 2db9: 11 4d 3e    .M>
	lxi	b,L3a41		;; 2dbc: 01 41 3a    .A:
	call	subxxx		;; 2dbf: cd 9e 38    ..8
	jc	L2dcd		;; 2dc2: da cd 2d    ..-
	mvi	c,000h		;; 2dc5: 0e 00       ..
	call	L2da6		;; 2dc7: cd a6 2d    ..-
	jmp	L2db9		;; 2dca: c3 b9 2d    ..-

L2dcd:	mvi	c,001h		;; 2dcd: 0e 01       ..
	call	L2da6		;; 2dcf: cd a6 2d    ..-
	ret			;; 2dd2: c9          .

L2dd3:	lhld	L3e4b		;; 2dd3: 2a 4b 3e    *K>
	mvi	h,000h		;; 2dd6: 26 00       &.
	lxi	b,L3a69		;; 2dd8: 01 69 3a    .i:
	dad	h		;; 2ddb: 29          )
	dad	b		;; 2ddc: 09          .
	mov	e,m		;; 2ddd: 5e          ^
	inx	h		;; 2dde: 23          #
	mov	d,m		;; 2ddf: 56          V
	xchg			;; 2de0: eb          .
	shld	L3a75		;; 2de1: 22 75 3a    "u:
L2de4:	mvi	a,000h		;; 2de4: 3e 00       >.
	lxi	d,L3a75		;; 2de6: 11 75 3a    .u:
	call	subxxa		;; 2de9: cd ab 38    ..8
	ora	l		;; 2dec: b5          .
	jz	L2e11		;; 2ded: ca 11 2e    ...
	call	L0fa5		;; 2df0: cd a5 0f    ...
	push	h		;; 2df3: e5          .
	lhld	L3e4b		;; 2df4: 2a 4b 3e    *K>
	mvi	h,000h		;; 2df7: 26 00       &.
	lxi	b,L3a91		;; 2df9: 01 91 3a    ..:
	dad	h		;; 2dfc: 29          )
	dad	b		;; 2dfd: 09          .
	pop	d		;; 2dfe: d1          .
	call	addxx		;; 2dff: cd 1d 38    ..8
	shld	L3e4d		;; 2e02: 22 4d 3e    "M>
	call	L2db9		;; 2e05: cd b9 2d    ..-
	call	L0fba		;; 2e08: cd ba 0f    ...
	shld	L3a75		;; 2e0b: 22 75 3a    "u:
	jmp	L2de4		;; 2e0e: c3 e4 2d    ..-

L2e11:	ret			;; 2e11: c9          .

L2e12:	lhld	L3e4b		;; 2e12: 2a 4b 3e    *K>
	mvi	h,000h		;; 2e15: 26 00       &.
	lxi	b,L3c0e		;; 2e17: 01 0e 3c    ..<
	dad	h		;; 2e1a: 29          )
	dad	b		;; 2e1b: 09          .
	mov	c,m		;; 2e1c: 4e          N
	inx	h		;; 2e1d: 23          #
	mov	b,m		;; 2e1e: 46          F
	call	L0f2e		;; 2e1f: cd 2e 0f    ...
	lxi	b,6		;; 2e22: 01 06 00    ...
	lhld	L3c30		;; 2e25: 2a 30 3c    *0<
	dad	b		;; 2e28: 09          .
	mov	a,m		;; 2e29: 7e          ~
	rar			;; 2e2a: 1f          .
	jnc	L2e52		;; 2e2b: d2 52 2e    .R.
	lxi	b,00007h	;; 2e2e: 01 07 00    ...
	lhld	L3c30		;; 2e31: 2a 30 3c    *0<
	dad	b		;; 2e34: 09          .
	mov	b,h		;; 2e35: 44          D
	mov	c,l		;; 2e36: 4d          M
	call	L3564		;; 2e37: cd 64 35    .d5
	lxi	b,00004h	;; 2e3a: 01 04 00    ...
	lhld	L3c30		;; 2e3d: 2a 30 3c    *0<
	dad	b		;; 2e40: 09          .
	push	h		;; 2e41: e5          .
	lhld	L3c30		;; 2e42: 2a 30 3c    *0<
	inx	h		;; 2e45: 23          #
	inx	h		;; 2e46: 23          #
	xthl			;; 2e47: e3          .
	mov	c,m		;; 2e48: 4e          N
	inx	h		;; 2e49: 23          #
	mov	b,m		;; 2e4a: 46          F
	pop	h		;; 2e4b: e1          .
	mov	m,c		;; 2e4c: 71          q
	inx	h		;; 2e4d: 23          #
	mov	m,b		;; 2e4e: 70          p
	jmp	L2e5d		;; 2e4f: c3 5d 2e    .].

L2e52:	lhld	L3c30		;; 2e52: 2a 30 3c    *0<
	inx	h		;; 2e55: 23          #
	inx	h		;; 2e56: 23          #
	lxi	b,0ffffh	;; 2e57: 01 ff ff    ...
	mov	m,c		;; 2e5a: 71          q
	inx	h		;; 2e5b: 23          #
	mov	m,b		;; 2e5c: 70          p
L2e5d:	call	L0ee0		;; 2e5d: cd e0 0e    ...
	sta	L3e50		;; 2e60: 32 50 3e    2P>
L2e63:	lda	L3e50		;; 2e63: 3a 50 3e    :P>
	cpi	0ffh		;; 2e66: fe ff       ..
	jz	L2ea4		;; 2e68: ca a4 2e    ...
	call	L0f18		;; 2e6b: cd 18 0f    ...
	push	h		;; 2e6e: e5          .
	lhld	L3e4b		;; 2e6f: 2a 4b 3e    *K>
	mvi	h,000h		;; 2e72: 26 00       &.
	lxi	b,L3a91		;; 2e74: 01 91 3a    ..:
	dad	h		;; 2e77: 29          )
	dad	b		;; 2e78: 09          .
	pop	d		;; 2e79: d1          .
	call	addxx		;; 2e7a: cd 1d 38    ..8
	shld	L3e4d		;; 2e7d: 22 4d 3e    "M>
	call	L0f18		;; 2e80: cd 18 0f    ...
	shld	L39a4		;; 2e83: 22 a4 39    ".9
	lda	L3e50		;; 2e86: 3a 50 3e    :P>
	ani	008h		;; 2e89: e6 08       ..
	mov	c,a		;; 2e8b: 4f          O
	mvi	a,000h		;; 2e8c: 3e 00       >.
	cmp	c		;; 2e8e: b9          .
	jnc	L2e98		;; 2e8f: d2 98 2e    ...
	call	L0f18		;; 2e92: cd 18 0f    ...
	shld	L39a4		;; 2e95: 22 a4 39    ".9
L2e98:	call	L2db9		;; 2e98: cd b9 2d    ..-
	call	L0ee0		;; 2e9b: cd e0 0e    ...
	sta	L3e50		;; 2e9e: 32 50 3e    2P>
	jmp	L2e63		;; 2ea1: c3 63 2e    .c.

L2ea4:	ret			;; 2ea4: c9          .

L2ea5:	mvi	a,07fh		;; 2ea5: 3e 7f       >.
	lxi	d,L3a35		;; 2ea7: 11 35 3a    .5:
	call	L3830		;; 2eaa: cd 30 38    .08
	mvi	a,0		;; 2ead: 3e 00       >.
	call	subxa		;; 2eaf: cd 94 38    ..8
	ora	l		;; 2eb2: b5          .
	jz	L2ebe		;; 2eb3: ca be 2e    ...
	mvi	c,eof		;; 2eb6: 0e 1a       ..
	call	L2a71		;; 2eb8: cd 71 2a    .q*
	jmp	L2ea5		;; 2ebb: c3 a5 2e    ...

L2ebe:	lxi	b,L3e86		;; 2ebe: 01 86 3e    ..>
	push	b		;; 2ec1: c5          .
	lhld	L3a35		;; 2ec2: 2a 35 3a    *5:
	mov	b,h		;; 2ec5: 44          D
	mov	c,l		;; 2ec6: 4d          M
	lxi	d,deffcb	;; 2ec7: 11 5c 00    .\.
	call	wrfile		;; 2eca: cd 94 35    ..5
	lxi	b,deffcb	;; 2ecd: 01 5c 00    .\.
	call	endfil		;; 2ed0: cd 76 35    .v5
	ret			;; 2ed3: c9          .

L2ed4:	lda	objdst		;; 2ed4: 3a 77 39    :w9
	cpi	'Z'		;; 2ed7: fe 5a       .Z
	jnz	L2edd		;; 2ed9: c2 dd 2e    ...
	ret			;; 2edc: c9          .

L2edd:	mvi	l,12		;; 2edd: 2e 0c       ..
	lxi	d,deffcb	;; 2edf: 11 5c 00    .\.
	lxi	b,L3a22		;; 2ee2: 01 22 3a    .":
L2ee5:	ldax	b		;; 2ee5: 0a          .
	stax	d		;; 2ee6: 12          .
	inx	b		;; 2ee7: 03          .
	inx	d		;; 2ee8: 13          .
	dcr	l		;; 2ee9: 2d          -
	jnz	L2ee5		;; 2eea: c2 e5 2e    ...
	lda	deffcb+9	;; 2eed: 3a 65 00    :e.
	cpi	' '		;; 2ef0: fe 20       . 
	jnz	L2f15		;; 2ef2: c2 15 2f    ../
	mvi	l,003h		;; 2ef5: 2e 03       ..
	push	h		;; 2ef7: e5          .
	lhld	prlflg		;; 2ef8: 2a 6f 39    *o9
	mvi	h,000h		;; 2efb: 26 00       &.
	lxi	d,00003h	;; 2efd: 11 03 00    ...
	call	mult		;; 2f00: cd 5c 38    .\8
	lxi	b,L2a5f		;; 2f03: 01 5f 2a    ._*
	dad	b		;; 2f06: 09          .
	mov	b,h		;; 2f07: 44          D
	mov	c,l		;; 2f08: 4d          M
	lxi	d,deffcb+9	;; 2f09: 11 65 00    .e.
	pop	h		;; 2f0c: e1          .
L2f0d:	ldax	b		;; 2f0d: 0a          .
	stax	d		;; 2f0e: 12          .
	inx	b		;; 2f0f: 03          .
	inx	d		;; 2f10: 13          .
	dcr	l		;; 2f11: 2d          -
	jnz	L2f0d		;; 2f12: c2 0d 2f    ../
L2f15:	lda	objdst		;; 2f15: 3a 77 39    :w9
	cpi	000h		;; 2f18: fe 00       ..
	jz	L2f23		;; 2f1a: ca 23 2f    .#/
	lda	objdst		;; 2f1d: 3a 77 39    :w9
	sta	deffcb		;; 2f20: 32 5c 00    2\.
L2f23:	lxi	b,deffcb	;; 2f23: 01 5c 00    .\.
	call	frcnew		;; 2f26: cd 42 35    .B5
	lda	L397f		;; 2f29: 3a 7f 39    :.9
	cpi	' '		;; 2f2c: fe 20       . 
	jnz	L2f41		;; 2f2e: c2 41 2f    .A/
	mvi	l,12		;; 2f31: 2e 0c       ..
	lxi	d,L397e		;; 2f33: 11 7e 39    .~9
	lxi	b,deffcb	;; 2f36: 01 5c 00    .\.
L2f39:	ldax	b		;; 2f39: 0a          .
	stax	d		;; 2f3a: 12          .
	inx	b		;; 2f3b: 03          .
	inx	d		;; 2f3c: 13          .
	dcr	l		;; 2f3d: 2d          -
	jnz	L2f39		;; 2f3e: c2 39 2f    .9/
L2f41:	lxi	h,00000h	;; 2f41: 21 00 00    ...
	shld	L3a35		;; 2f44: 22 35 3a    "5:
	mov	a,l		;; 2f47: 7d          }
	sta	L3e38		;; 2f48: 32 38 3e    28>
	sta	L3e37		;; 2f4b: 32 37 3e    27>
	call	L2afe		;; 2f4e: cd fe 2a    ..*
	call	L2ea5		;; 2f51: cd a5 2e    ...
	ret			;; 2f54: c9          .

L2f55:	lda	symdst		;; 2f55: 3a 78 39    :x9
	cpi	'Z'		;; 2f58: fe 5a       .Z
	jnz	L2f5e		;; 2f5a: c2 5e 2f    .^/
	ret			;; 2f5d: c9          .

L2f5e:	mvi	l,9		;; 2f5e: 2e 09       ..
	lxi	d,deffcb	;; 2f60: 11 5c 00    .\.
	lxi	b,L3a22		;; 2f63: 01 22 3a    .":
L2f66:	ldax	b		;; 2f66: 0a          .
	stax	d		;; 2f67: 12          .
	inx	b		;; 2f68: 03          .
	inx	d		;; 2f69: 13          .
	dcr	l		;; 2f6a: 2d          -
	jnz	L2f66		;; 2f6b: c2 66 2f    .f/
	mvi	l,3		;; 2f6e: 2e 03       ..
	lxi	d,deffcb+9	;; 2f70: 11 65 00    .e.
	lxi	b,L2a6e		;; 2f73: 01 6e 2a    .n*
L2f76:	ldax	b		;; 2f76: 0a          .
	stax	d		;; 2f77: 12          .
	inx	b		;; 2f78: 03          .
	inx	d		;; 2f79: 13          .
	dcr	l		;; 2f7a: 2d          -
	jnz	L2f76		;; 2f7b: c2 76 2f    .v/
	lda	symdst		;; 2f7e: 3a 78 39    :x9
	cpi	000h		;; 2f81: fe 00       ..
	jz	L2f8c		;; 2f83: ca 8c 2f    ../
	lda	symdst		;; 2f86: 3a 78 39    :x9
	sta	deffcb		;; 2f89: 32 5c 00    2\.
L2f8c:	lxi	b,deffcb	;; 2f8c: 01 5c 00    .\.
	call	frcnew		;; 2f8f: cd 42 35    .B5
	lxi	h,0		;; 2f92: 21 00 00    ...
	shld	L3a35		;; 2f95: 22 35 3a    "5:
	mov	a,l		;; 2f98: 7d          }
	sta	L3e52		;; 2f99: 32 52 3e    2R>
	call	L04bd		;; 2f9c: cd bd 04    ...
	shld	cursym		;; 2f9f: 22 64 3a    "d:
L2fa2:	lxi	b,L3a60		;; 2fa2: 01 60 3a    .`:
	lxi	d,cursym	;; 2fa5: 11 64 3a    .d:
	call	subxxx		;; 2fa8: cd 9e 38    ..8
	jnc	L3028		;; 2fab: d2 28 30    .(0
	call	getf1		;; 2fae: cd b9 13    ...
	cma			;; 2fb1: 2f          /
	push	psw		;; 2fb2: f5          .
	call	L1bf2		;; 2fb3: cd f2 1b    ...
	pop	b		;; 2fb6: c1          .
	mov	c,b		;; 2fb7: 48          H
	ana	c		;; 2fb8: a1          .
	rar			;; 2fb9: 1f          .
	jnc	L3017		;; 2fba: d2 17 30    ..0
	call	getval		;; 2fbd: cd 32 14    .2.
	mov	b,h		;; 2fc0: 44          D
	mov	c,l		;; 2fc1: 4d          M
	call	L3076		;; 2fc2: cd 76 30    .v0
	mvi	c,' '		;; 2fc5: 0e 20       . 
	call	L2a71		;; 2fc7: cd 71 2a    .q*
	lxi	h,L3e51		;; 2fca: 21 51 3e    .Q>
	mvi	m,1		;; 2fcd: 36 01       6.
L2fcf:	call	getlen		;; 2fcf: cd 68 13    .h.
	lxi	h,L3e51		;; 2fd2: 21 51 3e    .Q>
	cmp	m		;; 2fd5: be          .
	jc	L2ff7		;; 2fd6: da f7 2f    ../
	lda	L3e51		;; 2fd9: 3a 51 3e    :Q>
	dcr	a		;; 2fdc: 3d          =
	mov	c,a		;; 2fdd: 4f          O
	mvi	b,0		;; 2fde: 06 00       ..
	lxi	h,6		;; 2fe0: 21 06 00    ...
	dad	b		;; 2fe3: 09          .
	xchg			;; 2fe4: eb          .
	lhld	cursym		;; 2fe5: 2a 64 3a    *d:
	dad	d		;; 2fe8: 19          .
	mov	c,m		;; 2fe9: 4e          N
	call	L2a71		;; 2fea: cd 71 2a    .q*
	lda	L3e51		;; 2fed: 3a 51 3e    :Q>
	inr	a		;; 2ff0: 3c          <
	sta	L3e51		;; 2ff1: 32 51 3e    2Q>
	jnz	L2fcf		;; 2ff4: c2 cf 2f    ../
L2ff7:	lda	L3e52		;; 2ff7: 3a 52 3e    :R>
	inr	a		;; 2ffa: 3c          <
	sta	L3e52		;; 2ffb: 32 52 3e    2R>
	ani	003h		;; 2ffe: e6 03       ..
	cpi	000h		;; 3000: fe 00       ..
	jnz	L3012		;; 3002: c2 12 30    ..0
	mvi	c,cr		;; 3005: 0e 0d       ..
	call	L2a71		;; 3007: cd 71 2a    .q*
	mvi	c,lf		;; 300a: 0e 0a       ..
	call	L2a71		;; 300c: cd 71 2a    .q*
	jmp	L3017		;; 300f: c3 17 30    ..0

L3012:	mvi	c,9		;; 3012: 0e 09       ..
	call	L2a71		;; 3014: cd 71 2a    .q*
; cursym = cursym + cursym->slen
L3017:	call	getsln		;; 3017: cd 84 13    ...
	lxi	d,cursym	;; 301a: 11 64 3a    .d:
	call	addxxa		;; 301d: cd 19 38    ..8
	xchg			;; 3020: eb          .
	dcx	h		;; 3021: 2b          +
	mov	m,e		;; 3022: 73          s
	inx	h		;; 3023: 23          #
	mov	m,d		;; 3024: 72          r
	jmp	L2fa2		;; 3025: c3 a2 2f    ../

L3028:	mvi	c,cr		;; 3028: 0e 0d       ..
	call	L2a71		;; 302a: cd 71 2a    .q*
	mvi	c,lf		;; 302d: 0e 0a       ..
	call	L2a71		;; 302f: cd 71 2a    .q*
	call	L2ea5		;; 3032: cd a5 2e    ...
	ret			;; 3035: c9          .

L3036:	lxi	h,L3e53		;; 3036: 21 53 3e    .S>
	mov	m,c		;; 3039: 71          q
	mvi	a,009h		;; 303a: 3e 09       >.
	lxi	h,L3e53		;; 303c: 21 53 3e    .S>
	cmp	m		;; 303f: be          .
	jc	L304f		;; 3040: da 4f 30    .O0
	lda	L3e53		;; 3043: 3a 53 3e    :S>
	adi	'0'		;; 3046: c6 30       .0
	mov	c,a		;; 3048: 4f          O
	call	L2a71		;; 3049: cd 71 2a    .q*
	jmp	L305a		;; 304c: c3 5a 30    .Z0

L304f:	lda	L3e53		;; 304f: 3a 53 3e    :S>
	sui	10		;; 3052: d6 0a       ..
	adi	'A'		;; 3054: c6 41       .A
	mov	c,a		;; 3056: 4f          O
	call	L2a71		;; 3057: cd 71 2a    .q*
L305a:	ret			;; 305a: c9          .

L305b:	lxi	h,L3e54		;; 305b: 21 54 3e    .T>
	mov	m,c		;; 305e: 71          q
	lda	L3e54		;; 305f: 3a 54 3e    :T>
	ani	0f8h	; ***BUG?***	;; 3062: e6 f8       ..
	rar			;; 3064: 1f          .
	rar			;; 3065: 1f          .
	rar			;; 3066: 1f          .
	rar			;; 3067: 1f          .
	mov	c,a		;; 3068: 4f          O
	call	L3036		;; 3069: cd 36 30    .60
	lda	L3e54		;; 306c: 3a 54 3e    :T>
	ani	00fh		;; 306f: e6 0f       ..
	mov	c,a		;; 3071: 4f          O
	call	L3036		;; 3072: cd 36 30    .60
	ret			;; 3075: c9          .

L3076:	lxi	h,L3e56		;; 3076: 21 56 3e    .V>
	mov	m,b		;; 3079: 70          p
	dcx	h		;; 307a: 2b          +
	mov	m,c		;; 307b: 71          q
	lhld	L3e55		;; 307c: 2a 55 3e    *U>
	mov	a,h		;; 307f: 7c          |
	mov	c,a		;; 3080: 4f          O
	call	L305b		;; 3081: cd 5b 30    .[0
	lhld	L3e55		;; 3084: 2a 55 3e    *U>
	mov	a,l		;; 3087: 7d          }
	mov	c,a		;; 3088: 4f          O
	call	L305b		;; 3089: cd 5b 30    .[0
	ret			;; 308c: c9          .

L308d:	lhld	L3e39		;; 308d: 2a 39 3e    *9>
	xchg			;; 3090: eb          .
	lxi	h,00080h	;; 3091: 21 80 00    ...
	call	divide		;; 3094: cd 3d 38    .=8
	xchg			;; 3097: eb          .
	shld	L3e57		;; 3098: 22 57 3e    "W>
	lhld	L3e57		;; 309b: 2a 57 3e    *W>
	xchg			;; 309e: eb          .
	lxi	h,00080h	;; 309f: 21 80 00    ...
	call	divide		;; 30a2: cd 3d 38    .=8
	lxi	h,L3e59		;; 30a5: 21 59 3e    .Y>
	mov	m,e		;; 30a8: 73          s
	lda	deffcb+12	;; 30a9: 3a 68 00    :h.
	cmp	m		;; 30ac: be          .
	jz	L30ca		;; 30ad: ca ca 30    ..0
	lda	L3e59		;; 30b0: 3a 59 3e    :Y>
	sta	deffcb+12	;; 30b3: 32 68 00    2h.
	lxi	b,deffcb	;; 30b6: 01 5c 00    .\.
	call	fopen		;; 30b9: cd 95 36    ..6
	cpi	0ffh		;; 30bc: fe ff       ..
	jnz	L30ca		;; 30be: c2 ca 30    ..0
	lxi	d,deffcb	;; 30c1: 11 5c 00    .\.
	lxi	b,L363e		;; 30c4: 01 3e 36    .>6
	call	L3534		;; 30c7: cd 34 35    .45
L30ca:	lhld	L3e57		;; 30ca: 2a 57 3e    *W>
	xchg			;; 30cd: eb          .
	lxi	h,00080h	;; 30ce: 21 80 00    ...
	call	divide		;; 30d1: cd 3d 38    .=8
	xchg			;; 30d4: eb          .
	lxi	h,deffcb+32	;; 30d5: 21 7c 00    .|.
	mov	m,e		;; 30d8: 73          s
	ret			;; 30d9: c9          .

L30da:	call	getval		;; 30da: cd 32 14    .2.
	xchg			;; 30dd: eb          .
	lhld	L398b		;; 30de: 2a 8b 39    *.9
	call	subx		;; 30e1: cd 97 38    ..8
	shld	L3e39		;; 30e4: 22 39 3e    "9>
	mvi	l,12		;; 30e7: 2e 0c       ..
	lxi	d,deffcb	;; 30e9: 11 5c 00    .\.
	lxi	b,L397e		;; 30ec: 01 7e 39    .~9
L30ef:	ldax	b		;; 30ef: 0a          .
	stax	d		;; 30f0: 12          .
	inx	b		;; 30f1: 03          .
	inx	d		;; 30f2: 13          .
	dcr	l		;; 30f3: 2d          -
	jnz	L30ef		;; 30f4: c2 ef 30    ..0
	lda	L398a		;; 30f7: 3a 8a 39    :.9
	cpi	000h		;; 30fa: fe 00       ..
	jz	L3109		;; 30fc: ca 09 31    ..1
	lxi	d,256		;; 30ff: 11 00 01    ...
	lhld	L3e39		;; 3102: 2a 39 3e    *9>
	dad	d		;; 3105: 19          .
	shld	L3e39		;; 3106: 22 39 3e    "9>
L3109:	lxi	b,deffcb	;; 3109: 01 5c 00    .\.
	call	L3564		;; 310c: cd 64 35    .d5
	call	L308d		;; 310f: cd 8d 30    ..0
	lxi	b,L4306		;; 3112: 01 06 43    ..C
	push	b		;; 3115: c5          .
	lxi	d,deffcb	;; 3116: 11 5c 00    .\.
	lxi	b,256		;; 3119: 01 00 01    ...
	call	rdfile		;; 311c: cd 8f 35    ..5
	xchg			;; 311f: eb          .
	lxi	h,L3e5a		;; 3120: 21 5a 3e    .Z>
	mov	m,e		;; 3123: 73          s
	lhld	L3e39		;; 3124: 2a 39 3e    *9>
	xchg			;; 3127: eb          .
	lxi	h,128		;; 3128: 21 80 00    ...
	call	divide		;; 312b: cd 3d 38    .=8
	lxi	b,L4306		;; 312e: 01 06 43    ..C
	dad	b		;; 3131: 09          .
	shld	L39a4		;; 3132: 22 a4 39    ".9
	lhld	L39a4		;; 3135: 2a a4 39    *.9
	push	h		;; 3138: e5          .
	lhld	L397c		;; 3139: 2a 7c 39    *|9
	xchg			;; 313c: eb          .
	pop	h		;; 313d: e1          .
	mov	m,e		;; 313e: 73          s
	inx	h		;; 313f: 23          #
	mov	m,d		;; 3140: 72          r
	call	L308d		;; 3141: cd 8d 30    ..0
	lxi	b,L4306		;; 3144: 01 06 43    ..C
	push	b		;; 3147: c5          .
	lxi	d,128		;; 3148: 11 80 00    ...
	lhld	L3e5a		;; 314b: 2a 5a 3e    *Z>
	mvi	h,0		;; 314e: 26 00       &.
	call	mult		;; 3150: cd 5c 38    .\8
	mov	b,h		;; 3153: 44          D
	mov	c,l		;; 3154: 4d          M
	lxi	d,deffcb	;; 3155: 11 5c 00    .\.
	call	wrfile		;; 3158: cd 94 35    ..5
	lda	deffcb+14	;; 315b: 3a 6a 00    :j.
	ani	07fh		;; 315e: e6 7f       ..
	sta	deffcb+14	;; 3160: 32 6a 00    2j.
	lxi	b,deffcb	;; 3163: 01 5c 00    .\.
	call	endfil		;; 3166: cd 76 35    .v5
	ret			;; 3169: c9          .

L316a:	lda	L398d		;; 316a: 3a 8d 39    :.9
	rar			;; 316d: 1f          .
	jnc	L3181		;; 316e: d2 81 31    ..1
	lxi	d,127		;; 3171: 11 7f 00    ...
	lhld	L397c		;; 3174: 2a 7c 39    *|9
	dad	d		;; 3177: 19          .
	lxi	d,-128		;; 3178: 11 80 ff    ...
	call	L3829		;; 317b: cd 29 38    .)8
	shld	L397c		;; 317e: 22 7c 39    "|9
L3181:	lda	L3979		;; 3181: 3a 79 39    :y9
	cpi	'Z'		;; 3184: fe 5a       .Z
	jnz	L318a		;; 3186: c2 8a 31    ..1
	ret			;; 3189: c9          .

L318a:	lxi	b,L3961		;; 318a: 01 61 39    .a9
	push	b		;; 318d: c5          .
	mvi	e,0		;; 318e: 1e 00       ..
	mvi	c,6		;; 3190: 0e 06       ..
	call	L1512		;; 3192: cd 12 15    ...
	rar			;; 3195: 1f          .
	jnc	L319f		;; 3196: d2 9f 31    ..1
	call	L30da		;; 3199: cd da 30    ..0
	jmp	L31b1		;; 319c: c3 b1 31    ..1

L319f:	lxi	b,L3967		;; 319f: 01 67 39    .g9
	push	b		;; 31a2: c5          .
	mvi	e,000h		;; 31a3: 1e 00       ..
	mvi	c,006h		;; 31a5: 0e 06       ..
	call	L1512		;; 31a7: cd 12 15    ...
	rar			;; 31aa: 1f          .
	jnc	L31b1		;; 31ab: d2 b1 31    ..1
	call	L30da		;; 31ae: cd da 30    ..0
L31b1:	ret			;; 31b1: c9          .

; set tmpfil->fcb.cr = C
setfcr:	lxi	h,L3e5f		;; 31b2: 21 5f 3e    ._>
	mov	m,c		;; 31b5: 71          q
	lxi	b,46		;; 31b6: 01 2e 00    ...
	lhld	tmpfil		;; 31b9: 2a 5b 3e    *[>
	dad	b		;; 31bc: 09          .
	lda	L3e5f		;; 31bd: 3a 5f 3e    :_>
	mov	m,a		;; 31c0: 77          w
	ret			;; 31c1: c9          .

; get tmpfil->fcb.ext
getext:	lxi	b,26		;; 31c2: 01 1a 00    ...
	lhld	tmpfil		;; 31c5: 2a 5b 3e    *[>
	dad	b		;; 31c8: 09          .
	mov	a,m		;; 31c9: 7e          ~
	ret			;; 31ca: c9          .

; set tmpfil->fcb.ext = C
setext:	lxi	h,L3e60		;; 31cb: 21 60 3e    .`>
	mov	m,c		;; 31ce: 71          q
	lxi	b,26		;; 31cf: 01 1a 00    ...
	lhld	tmpfil		;; 31d2: 2a 5b 3e    *[>
	dad	b		;; 31d5: 09          .
	lda	L3e60		;; 31d6: 3a 60 3e    :`>
	mov	m,a		;; 31d9: 77          w
	ret			;; 31da: c9          .

; reset/clear tmpfil
rstfil:	lxi	b,6		;; 31db: 01 06 00    ...
	lhld	tmpfil		;; 31de: 2a 5b 3e    *[>
	dad	b		;; 31e1: 09          .
	lxi	b,4		;; 31e2: 01 04 00    ...
	push	h		;; 31e5: e5          .
	lhld	tmpfil		;; 31e6: 2a 5b 3e    *[>
	dad	b		;; 31e9: 09          .
	mov	e,m		;; 31ea: 5e          ^
	inx	h		;; 31eb: 23          #
	mov	d,m		;; 31ec: 56          V
	pop	h		;; 31ed: e1          .
	mov	c,m		;; 31ee: 4e          N
	inx	h		;; 31ef: 23          #
	mov	b,m		;; 31f0: 46          F
	; BC=tmpfil->f4, DE=tmpfil->f3
	call	bzero		;; 31f1: cd 52 2a    .R*
	lxi	b,12		;; 31f4: 01 0c 00    ...
	lhld	tmpfil		;; 31f7: 2a 5b 3e    *[>
	dad	b		;; 31fa: 09          .
	mvi	m,0		;; 31fb: 36 00       6.
	ret			;; 31fd: c9          .

; random-access to tmpfil... i.e. seek
fseek:	lhld	tmpfil		;; 31fe: 2a 5b 3e    *[>
	mov	e,m		;; 3201: 5e          ^
	inx	h		;; 3202: 23          #
	mov	d,m		;; 3203: 56          V
	lxi	h,128		;; 3204: 21 80 00    ...
	call	divide		;; 3207: cd 3d 38    .=8
	xchg			;; 320a: eb          .
	; save quotient: currec = tmpfil->f1 / 128
	shld	currec		;; 320b: 22 62 3e    "b>
	xchg			;; 320e: eb          .
	; BC=128 from previous division
	call	divbc		;; 320f: cd 3f 38    .?8
	lxi	h,curext		;; 3212: 21 61 3e    .a>
	; curext = tmpfil->f1 / 128 / 128
	mov	m,e		;; 3215: 73          s
	call	getext		;; 3216: cd c2 31    ..1
	lxi	h,curext		;; 3219: 21 61 3e    .a>
	cmp	m		;; 321c: be          .
	jz	L3250		;; 321d: ca 50 32    .P2
	; must change extents - seek record...
	lxi	b,14		;; 3220: 01 0e 00    ...
	lhld	tmpfil		;; 3223: 2a 5b 3e    *[>
	dad	b		;; 3226: 09          .
	; &tmpfil->fcb
	mov	b,h		;; 3227: 44          D
	mov	c,l		;; 3228: 4d          M
	call	endfil		;; 3229: cd 76 35    .v5
	lhld	curext		;; 322c: 2a 61 3e    *a>
	mov	c,l		;; 322f: 4d          M
	call	setext		;; 3230: cd cb 31    ..1
	lxi	b,14		;; 3233: 01 0e 00    ...
	lhld	tmpfil		;; 3236: 2a 5b 3e    *[>
	dad	b		;; 3239: 09          .
	; &tmpfil->fcb
	mov	b,h		;; 323a: 44          D
	mov	c,l		;; 323b: 4d          M
	call	fopen		;; 323c: cd 95 36    ..6
	cpi	0ffh		;; 323f: fe ff       ..
	jnz	L3250		;; 3241: c2 50 32    .P2
	; no extent exists...
	lxi	b,14		;; 3244: 01 0e 00    ...
	lhld	tmpfil		;; 3247: 2a 5b 3e    *[>
	dad	b		;; 324a: 09          .
	; &tmpfil->fcb
	mov	b,h		;; 324b: 44          D
	mov	c,l		;; 324c: 4d          M
	call	newfil		;; 324d: cd 4c 35    .L5
L3250:	lhld	currec		;; 3250: 2a 62 3e    *b>
	xchg			;; 3253: eb          .
	lxi	h,128		;; 3254: 21 80 00    ...
	call	divide		;; 3257: cd 3d 38    .=8
	mov	c,l		;; 325a: 4d          M
	; tmpfil->fcb.cr = currec % 128
	call	setfcr		;; 325b: cd b2 31    ..1
	ret			;; 325e: c9          .

wrtemp:	lxi	b,8		;; 325f: 01 08 00    ...
	lhld	tmpfil		;; 3262: 2a 5b 3e    *[>
	dad	b		;; 3265: 09          .
	lxi	b,10		;; 3266: 01 0a 00    ...
	push	h		;; 3269: e5          .
	lhld	tmpfil		;; 326a: 2a 5b 3e    *[>
	dad	b		;; 326d: 09          .
	xchg			;; 326e: eb          .
	pop	b		;; 326f: c1          .
	; tmpfil->f6 - tmpfil->f5
	call	subxxx		;; 3270: cd 9e 38    ..8
	jnc	L328d		;; 3273: d2 8d 32    ..2
	; if (tmpfil->f6 < tmpfil->f5) ...
	lxi	b,8		;; 3276: 01 08 00    ...
	lhld	tmpfil		;; 3279: 2a 5b 3e    *[>
	dad	b		;; 327c: 09          .
	lxi	b,10		;; 327d: 01 0a 00    ...
	push	h		;; 3280: e5          .
	lhld	tmpfil		;; 3281: 2a 5b 3e    *[>
	dad	b		;; 3284: 09          .
	xthl			;; 3285: e3          .
	; BC=tmpfil->f5
	mov	c,m		;; 3286: 4e          N
	inx	h		;; 3287: 23          #
	mov	b,m		;; 3288: 46          F
	pop	h		;; 3289: e1          .
	; tmpfil->f6 = BC
	mov	m,c		;; 328a: 71          q
	inx	h		;; 328b: 23          #
	mov	m,b		;; 328c: 70          p
	; ... tmpfil->f6f7 = tmpfil->f5
L328d:	lxi	b,13		;; 328d: 01 0d 00    ...
	lhld	tmpfil		;; 3290: 2a 5b 3e    *[>
	dad	b		;; 3293: 09          .
	mov	a,m		;; 3294: 7e          ~
	rar			;; 3295: 1f          .
	jc	L32ae		;; 3296: da ae 32    ..2
	; if (not tmpfil->f9) ...
	lxi	b,14		;; 3299: 01 0e 00    ...
	lhld	tmpfil		;; 329c: 2a 5b 3e    *[>
	dad	b		;; 329f: 09          .
	mov	b,h		;; 32a0: 44          D
	mov	c,l		;; 32a1: 4d          M
	call	frcnew		;; 32a2: cd 42 35    .B5
	lxi	b,13		;; 32a5: 01 0d 00    ...
	lhld	tmpfil		;; 32a8: 2a 5b 3e    *[>
	dad	b		;; 32ab: 09          .
	; tmpfil->f9 = 1
	mvi	m,1		;; 32ac: 36 01       6.
	; ...
L32ae:	call	fseek		;; 32ae: cd fe 31    ..1
	lxi	b,6		;; 32b1: 01 06 00    ...
	lhld	tmpfil		;; 32b4: 2a 5b 3e    *[>
	dad	b		;; 32b7: 09          .
	mov	c,m		;; 32b8: 4e          N
	inx	h		;; 32b9: 23          #
	mov	b,m		;; 32ba: 46          F
	push	b		;; 32bb: c5          .
	lxi	b,4		;; 32bc: 01 04 00    ...
	lhld	tmpfil		;; 32bf: 2a 5b 3e    *[>
	dad	b		;; 32c2: 09          .
	lxi	b,14		;; 32c3: 01 0e 00    ...
	push	h		;; 32c6: e5          .
	lhld	tmpfil		;; 32c7: 2a 5b 3e    *[>
	dad	b		;; 32ca: 09          .
	xthl			;; 32cb: e3          .
	mov	c,m		;; 32cc: 4e          N
	inx	h		;; 32cd: 23          #
	mov	b,m		;; 32ce: 46          F
	pop	d		;; 32cf: d1          .
	call	wrfile		;; 32d0: cd 94 35    ..5
	call	rstfil		;; 32d3: cd db 31    ..1
	ret			;; 32d6: c9          .

L32d7:	lxi	h,L3e64+1	;; 32d7: 21 65 3e    .e>
	mov	m,b		;; 32da: 70          p
	dcx	h		;; 32db: 2b          +
	mov	m,c		;; 32dc: 71          q
	lxi	b,4		;; 32dd: 01 04 00    ...
	lhld	tmpfil		;; 32e0: 2a 5b 3e    *[>
	dad	b		;; 32e3: 09          .
	mov	c,m		;; 32e4: 4e          N
	inx	h		;; 32e5: 23          #
	mov	b,m		;; 32e6: 46          F
	; BC=tmpfil->f3
	push	h		;; 32e7: e5          .
	lhld	L3e64		;; 32e8: 2a 64 3e    *d>
	xchg			;; 32eb: eb          .
	call	divbc		;; 32ec: cd 3f 38    .?8
	call	multbc		;; 32ef: cd 5e 38    .^8
	; INT(parm1 / tmpfil->f3) * tmpfil->f3
	push	h		;; 32f2: e5          .
	lhld	tmpfil		;; 32f3: 2a 5b 3e    *[>
	pop	b		;; 32f6: c1          .
	mov	m,c		;; 32f7: 71          q
	inx	h		;; 32f8: 23          #
	mov	m,b		;; 32f9: 70          p
	; tmpfil->f1 = ('')
	lhld	tmpfil		;; 32fa: 2a 5b 3e    *[>
	lxi	b,4		;; 32fd: 01 04 00    ...
	push	h		;; 3300: e5          .
	lhld	tmpfil		;; 3301: 2a 5b 3e    *[>
	dad	b		;; 3304: 09          .
	pop	d		;; 3305: d1          .
	; tmpfil->f1 + tmpfil->f3
	call	addxxx		;; 3306: cd 0e 38    ..8
	dcx	h		;; 3309: 2b          +
	push	h		;; 330a: e5          .
	lhld	tmpfil		;; 330b: 2a 5b 3e    *[>
	inx	h		;; 330e: 23          #
	inx	h		;; 330f: 23          #
	pop	b		;; 3310: c1          .
	mov	m,c		;; 3311: 71          q
	inx	h		;; 3312: 23          #
	mov	m,b		;; 3313: 70          p
	; tmpfil->f2 = (tmpfil->f1 + tmpfil->f3) - 1
	lhld	tmpfil		;; 3314: 2a 5b 3e    *[>
	lxi	b,4		;; 3317: 01 04 00    ...
	push	h		;; 331a: e5          .
	lhld	tmpfil		;; 331b: 2a 5b 3e    *[>
	dad	b		;; 331e: 09          .
	mov	c,m		;; 331f: 4e          N
	inx	h		;; 3320: 23          #
	mov	b,m		;; 3321: 46          F
	pop	h		;; 3322: e1          .
	mov	e,m		;; 3323: 5e          ^
	inx	h		;; 3324: 23          #
	mov	d,m		;; 3325: 56          V
	call	divbc		;; 3326: cd 3f 38    .?8
	inx	d		;; 3329: 13          .
	lxi	b,8		;; 332a: 01 08 00    ...
	lhld	tmpfil		;; 332d: 2a 5b 3e    *[>
	dad	b		;; 3330: 09          .
	mov	m,e		;; 3331: 73          s
	inx	h		;; 3332: 23          #
	mov	m,d		;; 3333: 72          r
	pop	h		;; 3334: e1          .
	ret			;; 3335: c9          .

L3336:	lxi	b,10		;; 3336: 01 0a 00    ...
	lhld	tmpfil		;; 3339: 2a 5b 3e    *[>
	dad	b		;; 333c: 09          .
	mov	c,m		;; 333d: 4e          N
	inx	h		;; 333e: 23          #
	mov	b,m		;; 333f: 46          F
	inx	b		;; 3340: 03          .
	mov	h,b		;; 3341: 60          `
	mov	l,c		;; 3342: 69          i
	shld	L3e68		;; 3343: 22 68 3e    "h>
	; L3e68 = tmpfil->f6 + 1
	lxi	b,8		;; 3346: 01 08 00    ...
	lhld	tmpfil		;; 3349: 2a 5b 3e    *[>
	dad	b		;; 334c: 09          .
	mov	c,m		;; 334d: 4e          N
	inx	h		;; 334e: 23          #
	mov	b,m		;; 334f: 46          F
	dcx	b		;; 3350: 0b          .
	mov	h,b		;; 3351: 60          `
	mov	l,c		;; 3352: 69          i
	shld	L3e6a		;; 3353: 22 6a 3e    "j>
	; L3e6a = tmpfil->f5 - 1
	lhld	L3e68		;; 3356: 2a 68 3e    *h>
	shld	L3e66		;; 3359: 22 66 3e    "f>
	; L3e66 = L3e68
L335c:	lxi	d,L3e6a		;; 335c: 11 6a 3e    .j>
	lxi	b,L3e66		;; 335f: 01 66 3e    .f>
	call	subxxx		;; 3362: cd 9e 38    ..8
	jc	L3390		;; 3365: da 90 33    ..3
	; while (L3e66 <= L3e6a) ...
	lhld	L3e66		;; 3368: 2a 66 3e    *f>
	dcx	h		;; 336b: 2b          +
	lxi	b,4		;; 336c: 01 04 00    ...
	push	h		;; 336f: e5          .
	lhld	tmpfil		;; 3370: 2a 5b 3e    *[>
	dad	b		;; 3373: 09          .
	mov	e,m		;; 3374: 5e          ^
	inx	h		;; 3375: 23          #
	mov	d,m		;; 3376: 56          V
	pop	h		;; 3377: e1          .
	call	mult		;; 3378: cd 5c 38    .\8
	mov	b,h		;; 337b: 44          D
	mov	c,l		;; 337c: 4d          M
	call	L32d7		;; 337d: cd d7 32    ..2
	call	wrtemp		;; 3380: cd 5f 32    ._2
	lxi	d,1		;; 3383: 11 01 00    ...
	lhld	L3e66		;; 3386: 2a 66 3e    *f>
	dad	d		;; 3389: 19          .
	shld	L3e66		;; 338a: 22 66 3e    "f>
	; L3e66 += 1
	jnc	L335c		;; 338d: d2 5c 33    .\3
L3390:	lxi	b,4		;; 3390: 01 04 00    ...
	lhld	tmpfil		;; 3393: 2a 5b 3e    *[>
	dad	b		;; 3396: 09          .
	mov	e,m		;; 3397: 5e          ^
	inx	h		;; 3398: 23          #
	mov	d,m		;; 3399: 56          V
	lhld	L3e6a		;; 339a: 2a 6a 3e    *j>
	call	mult		;; 339d: cd 5c 38    .\8
	mov	b,h		;; 33a0: 44          D
	mov	c,l		;; 33a1: 4d          M
	call	L32d7		;; 33a2: cd d7 32    ..2
	ret			;; 33a5: c9          .

L33a6:	lxi	b,8		;; 33a6: 01 08 00    ...
	lhld	tmpfil		;; 33a9: 2a 5b 3e    *[>
	dad	b		;; 33ac: 09          .
	lxi	b,10		;; 33ad: 01 0a 00    ...
	push	h		;; 33b0: e5          .
	lhld	tmpfil		;; 33b1: 2a 5b 3e    *[>
	dad	b		;; 33b4: 09          .
	xchg			;; 33b5: eb          .
	pop	b		;; 33b6: c1          .
	call	subxxx		;; 33b7: cd 9e 38    ..8
	jnc	rdtemp		;; 33ba: d2 be 33    ..3
	ret			;; 33bd: c9          .

rdtemp:	call	fseek		;; 33be: cd fe 31    ..1
	lxi	b,6		;; 33c1: 01 06 00    ...
	lhld	tmpfil		;; 33c4: 2a 5b 3e    *[>
	dad	b		;; 33c7: 09          .
	mov	c,m		;; 33c8: 4e          N
	inx	h		;; 33c9: 23          #
	mov	b,m		;; 33ca: 46          F
	push	b		;; 33cb: c5          .
	; TOS=tmpfil->f4
	lxi	b,4		;; 33cc: 01 04 00    ...
	lhld	tmpfil		;; 33cf: 2a 5b 3e    *[>
	dad	b		;; 33d2: 09          .
	lxi	b,14		;; 33d3: 01 0e 00    ...
	push	h		;; 33d6: e5          .
	lhld	tmpfil		;; 33d7: 2a 5b 3e    *[>
	dad	b		;; 33da: 09          .
	xthl			;; 33db: e3          .
	mov	c,m		;; 33dc: 4e          N
	inx	h		;; 33dd: 23          #
	mov	b,m		;; 33de: 46          F
	; BC=tmpfil->f3
	pop	d		;; 33df: d1          .
	; DE=&tmpfil->fcb
	call	rdfile		;; 33e0: cd 8f 35    ..5
	ret			;; 33e3: c9          .

L33e4:	lxi	h,L3e6e		;; 33e4: 21 6e 3e    .n>
	mov	m,e		;; 33e7: 73          s
	dcx	h		;; 33e8: 2b          +
	mov	m,b		;; 33e9: 70          p
	dcx	h		;; 33ea: 2b          +
	mov	m,c		;; 33eb: 71          q
	lhld	tmpfil		;; 33ec: 2a 5b 3e    *[>
	lxi	d,L3e6c		;; 33ef: 11 6c 3e    .l>
	call	subxxm		;; 33f2: cd a0 38    ..8
	jnc	L3415		;; 33f5: d2 15 34    ..4
	lxi	b,12		;; 33f8: 01 0c 00    ...
	lhld	tmpfil		;; 33fb: 2a 5b 3e    *[>
	dad	b		;; 33fe: 09          .
	mov	a,m		;; 33ff: 7e          ~
	rar			;; 3400: 1f          .
	jnc	L3407		;; 3401: d2 07 34    ..4
	call	wrtemp		;; 3404: cd 5f 32    ._2
L3407:	lhld	L3e6c		;; 3407: 2a 6c 3e    *l>
	mov	b,h		;; 340a: 44          D
	mov	c,l		;; 340b: 4d          M
	call	L32d7		;; 340c: cd d7 32    ..2
	call	L33a6		;; 340f: cd a6 33    ..3
	jmp	L348a		;; 3412: c3 8a 34    ..4

L3415:	lhld	tmpfil		;; 3415: 2a 5b 3e    *[>
	inx	h		;; 3418: 23          #
	inx	h		;; 3419: 23          #
	xchg			;; 341a: eb          .
	lxi	b,L3e6c		;; 341b: 01 6c 3e    .l>
	call	subxxx		;; 341e: cd 9e 38    ..8
	jnc	L348a		;; 3421: d2 8a 34    ..4
	lxi	b,12		;; 3424: 01 0c 00    ...
	lhld	tmpfil		;; 3427: 2a 5b 3e    *[>
	dad	b		;; 342a: 09          .
	mov	a,m		;; 342b: 7e          ~
	rar			;; 342c: 1f          .
	jnc	L3433		;; 342d: d2 33 34    .34
	call	wrtemp		;; 3430: cd 5f 32    ._2
L3433:	lhld	L3e6c		;; 3433: 2a 6c 3e    *l>
	mov	b,h		;; 3436: 44          D
	mov	c,l		;; 3437: 4d          M
	call	L32d7		;; 3438: cd d7 32    ..2
	lda	L3e6e		;; 343b: 3a 6e 3e    :n>
	rar			;; 343e: 1f          .
	jnc	L346a		;; 343f: d2 6a 34    .j4
	lxi	b,8		;; 3442: 01 08 00    ...
	lhld	tmpfil		;; 3445: 2a 5b 3e    *[>
	dad	b		;; 3448: 09          .
	lxi	b,10		;; 3449: 01 0a 00    ...
	push	h		;; 344c: e5          .
	lhld	tmpfil		;; 344d: 2a 5b 3e    *[>
	dad	b		;; 3450: 09          .
	mov	c,m		;; 3451: 4e          N
	inx	h		;; 3452: 23          #
	mov	b,m		;; 3453: 46          F
	inx	b		;; 3454: 03          .
	mov	d,b		;; 3455: 50          P
	mov	e,c		;; 3456: 59          Y
	pop	h		;; 3457: e1          .
	call	L38b9		;; 3458: cd b9 38    ..8
	jnc	L3464		;; 345b: d2 64 34    .d4
	call	L3336		;; 345e: cd 36 33    .63
	jmp	L3467		;; 3461: c3 67 34    .g4

L3464:	call	L33a6		;; 3464: cd a6 33    ..3
L3467:	jmp	L348a		;; 3467: c3 8a 34    ..4

L346a:	lxi	b,8		;; 346a: 01 08 00    ...
	lhld	tmpfil		;; 346d: 2a 5b 3e    *[>
	dad	b		;; 3470: 09          .
	lxi	b,10		;; 3471: 01 0a 00    ...
	push	h		;; 3474: e5          .
	lhld	tmpfil		;; 3475: 2a 5b 3e    *[>
	dad	b		;; 3478: 09          .
	xchg			;; 3479: eb          .
	pop	b		;; 347a: c1          .
	call	subxxx		;; 347b: cd 9e 38    ..8
	jnc	L3487		;; 347e: d2 87 34    ..4
	call	rstfil		;; 3481: cd db 31    ..1
	jmp	L348a		;; 3484: c3 8a 34    ..4

L3487:	call	L33a6		;; 3487: cd a6 33    ..3
L348a:	ret			;; 348a: c9          .

L348b:	lxi	h,L3e6f+1	;; 348b: 21 70 3e    .p>
	mov	m,b		;; 348e: 70          p
	dcx	h		;; 348f: 2b          +
	mov	m,c		;; 3490: 71          q
	lhld	L3e6f		;; 3491: 2a 6f 3e    *o>
	shld	tmpfil		;; 3494: 22 5b 3e    "[>
	ret			;; 3497: c9          .

L3498:	lxi	h,L3e73		;; 3498: 21 73 3e    .s>
	mov	m,e		;; 349b: 73          s
	dcx	h		;; 349c: 2b          +
	mov	m,b		;; 349d: 70          p
	dcx	h		;; 349e: 2b          +
	mov	m,c		;; 349f: 71          q
	lhld	L3e71		;; 34a0: 2a 71 3e    *q>
	mov	b,h		;; 34a3: 44          D
	mov	c,l		;; 34a4: 4d          M
	mvi	e,001h		;; 34a5: 1e 01       ..
	call	L33e4		;; 34a7: cd e4 33    ..3
	lxi	b,6		;; 34aa: 01 06 00    ...
	lhld	tmpfil		;; 34ad: 2a 5b 3e    *[>
	dad	b		;; 34b0: 09          .
	mov	e,m		;; 34b1: 5e          ^
	inx	h		;; 34b2: 23          #
	mov	d,m		;; 34b3: 56          V
	xchg			;; 34b4: eb          .
	shld	L3e5d		;; 34b5: 22 5d 3e    "]>
	lxi	b,00004h	;; 34b8: 01 04 00    ...
	lhld	tmpfil		;; 34bb: 2a 5b 3e    *[>
	dad	b		;; 34be: 09          .
	mov	c,m		;; 34bf: 4e          N
	inx	h		;; 34c0: 23          #
	mov	b,m		;; 34c1: 46          F
	lhld	L3e71		;; 34c2: 2a 71 3e    *q>
	xchg			;; 34c5: eb          .
	call	divbc		;; 34c6: cd 3f 38    .?8
	xchg			;; 34c9: eb          .
	lhld	L3e5d		;; 34ca: 2a 5d 3e    *]>
	dad	d		;; 34cd: 19          .
	lda	L3e73		;; 34ce: 3a 73 3e    :s>
	mov	m,a		;; 34d1: 77          w
	lxi	b,12		;; 34d2: 01 0c 00    ...
	lhld	tmpfil		;; 34d5: 2a 5b 3e    *[>
	dad	b		;; 34d8: 09          .
	mvi	m,001h		;; 34d9: 36 01       6.
	ret			;; 34db: c9          .

L34dc:	lxi	h,L3e75		;; 34dc: 21 75 3e    .u>
	mov	m,b		;; 34df: 70          p
	dcx	h		;; 34e0: 2b          +
	mov	m,c		;; 34e1: 71          q
	lhld	L3e74		;; 34e2: 2a 74 3e    *t>
	mov	b,h		;; 34e5: 44          D
	mov	c,l		;; 34e6: 4d          M
	mvi	e,000h		;; 34e7: 1e 00       ..
	call	L33e4		;; 34e9: cd e4 33    ..3
	lxi	b,6		;; 34ec: 01 06 00    ...
	lhld	tmpfil		;; 34ef: 2a 5b 3e    *[>
	dad	b		;; 34f2: 09          .
	mov	e,m		;; 34f3: 5e          ^
	inx	h		;; 34f4: 23          #
	mov	d,m		;; 34f5: 56          V
	xchg			;; 34f6: eb          .
	shld	L3e5d		;; 34f7: 22 5d 3e    "]>
	lxi	b,00004h	;; 34fa: 01 04 00    ...
	lhld	tmpfil		;; 34fd: 2a 5b 3e    *[>
	dad	b		;; 3500: 09          .
	mov	c,m		;; 3501: 4e          N
	inx	h		;; 3502: 23          #
	mov	b,m		;; 3503: 46          F
	lhld	L3e74		;; 3504: 2a 74 3e    *t>
	xchg			;; 3507: eb          .
	call	divbc		;; 3508: cd 3f 38    .?8
	xchg			;; 350b: eb          .
	lhld	L3e5d		;; 350c: 2a 5d 3e    *]>
	dad	d		;; 350f: 19          .
	mov	a,m		;; 3510: 7e          ~
	ret			;; 3511: c9          .

L3512:	mvi	e,11		;; 3512: 1e 0b       ..
	inx	b		;; 3514: 03          .
L3515:	ldax	b		;; 3515: 0a          .
	ani	07fh		;; 3516: e6 7f       ..
	cpi	' '		;; 3518: fe 20       . 
	cnz	L352b		;; 351a: c4 2b 35    .+5
	dcr	e		;; 351d: 1d          .
	rz			;; 351e: c8          .
	inx	b		;; 351f: 03          .
	mov	a,e		;; 3520: 7b          {
	cpi	3		;; 3521: fe 03       ..
	mvi	a,'.'		;; 3523: 3e 2e       >.
	cz	L352b		;; 3525: cc 2b 35    .+5
	jmp	L3515		;; 3528: c3 15 35    ..5

L352b:	push	b		;; 352b: c5          .
	push	d		;; 352c: d5          .
	mov	c,a		;; 352d: 4f          O
	call	putchr		;; 352e: cd b2 02    ...
	pop	d		;; 3531: d1          .
	pop	b		;; 3532: c1          .
	ret			;; 3533: c9          .

L3534:	push	d		;; 3534: d5          .
	call	pagmsg		;; 3535: cd c8 02    ...
	pop	b		;; 3538: c1          .
	call	L3512		;; 3539: cd 12 35    ..5
	lxi	b,L3677		;; 353c: 01 77 36    .w6
	call	L36e2		;; 353f: cd e2 36    ..6
frcnew:	push	b		;; 3542: c5          .
	call	fdelet		;; 3543: cd a9 36    ..6
	pop	b		;; 3546: c1          .
	push	b		;; 3547: c5          .
	call	L3581		;; 3548: cd 81 35    ..5
	pop	b		;; 354b: c1          .
; alt entry: only create/open file, don't delete or ...
newfil:	call	fmake		;; 354c: cd be 36    ..6
	inr	a		;; 354f: 3c          <
	rnz			;; 3550: c0          .
	lxi	b,L3635		;; 3551: 01 35 36    .56
	call	L36e2		;; 3554: cd e2 36    ..6
L3557:	push	b		;; 3557: c5          .
	call	L3581		;; 3558: cd 81 35    ..5
	pop	b		;; 355b: c1          .
	call	fopen		;; 355c: cd 95 36    ..6
	inr	a		;; 355f: 3c          <
	rz			;; 3560: c8          .
	mvi	a,001h		;; 3561: 3e 01       >.
	ret			;; 3563: c9          .

L3564:	push	b		;; 3564: c5          .
	call	L3581		;; 3565: cd 81 35    ..5
	pop	b		;; 3568: c1          .
	push	b		;; 3569: c5          .
	call	fopen		;; 356a: cd 95 36    ..6
	inr	a		;; 356d: 3c          <
	pop	d		;; 356e: d1          .
	rnz			;; 356f: c0          .
	lxi	b,L363e		;; 3570: 01 3e 36    .>6
	call	L3534		;; 3573: cd 34 35    .45
endfil:	call	fclose		;; 3576: cd 9c 36    ..6
	inr	a		;; 3579: 3c          <
	rnz			;; 357a: c0          .
	lxi	b,L3648		;; 357b: 01 48 36    .H6
	call	L36e2		;; 357e: cd e2 36    ..6
L3581:	lxi	h,12		;; 3581: 21 0c 00    ...
	dad	b		;; 3584: 09          .
	xra	a		;; 3585: af          .
	mvi	c,33-12		;; 3586: 0e 15       ..
L3588:	mov	m,a		;; 3588: 77          w
	dcr	c		;; 3589: 0d          .
	inx	h		;; 358a: 23          #
	jnz	L3588		;; 358b: c2 88 35    ..5
	ret			;; 358e: c9          .

; (S1)=buffer, DE=fcb, BC=byte count (trunc 128)
rdfile:	mvi	a,0		;; 358f: 3e 00       >.
	jmp	L3596		;; 3591: c3 96 35    ..5

wrfile:	mvi	a,1		;; 3594: 3e 01       >.
L3596:	sta	rwflag		;; 3596: 32 2c 36    2,6
	pop	h		;; 3599: e1          .
	xthl			;; 359a: e3          .
	shld	rwdma		;; 359b: 22 22 36    ""6
	xchg			;; 359e: eb          .
	shld	rwfcb		;; 359f: 22 24 36    "$6
	mov	a,c		;; 35a2: 79          y
	ani	080h		;; 35a3: e6 80       ..
	mov	l,a		;; 35a5: 6f          o
	mov	h,b		;; 35a6: 60          `
	; HL = BC & FF80 - truncate to 128-byte multiple
	shld	rwbyts		;; 35a7: 22 26 36    "&6
	lxi	h,0		;; 35aa: 21 00 00    ...
	shld	rwrecs		;; 35ad: 22 2a 36    "*6
	call	chrst		;; 35b0: cd 8b 36    ..6
	rar			;; 35b3: 1f          .
	lxi	b,L362d		;; 35b4: 01 2d 36    .-6
	cc	L36e2		;; 35b7: dc e2 36    ..6
L35ba:	lhld	rwbyts		;; 35ba: 2a 26 36    *&6
	mov	a,h		;; 35bd: 7c          |
	ora	l		;; 35be: b5          .
	jz	L3618		;; 35bf: ca 18 36    ..6
	lxi	b,-128		;; 35c2: 01 80 ff    ...
	dad	b		;; 35c5: 09          .
	shld	rwbyts		;; 35c6: 22 26 36    "&6
	lhld	rwdma		;; 35c9: 2a 22 36    *"6
	mov	c,l		;; 35cc: 4d          M
	mov	b,h		;; 35cd: 44          D
	call	fstdma		;; 35ce: cd cc 36    ..6
	lhld	rwfcb		;; 35d1: 2a 24 36    *$6
	mov	b,h		;; 35d4: 44          D
	mov	c,l		;; 35d5: 4d          M
	lda	rwflag		;; 35d6: 3a 2c 36    :,6
	cpi	0		;; 35d9: fe 00       ..
	jz	L35eb		;; 35db: ca eb 35    ..5
	call	fwrite		;; 35de: cd b7 36    ..6
	ora	a		;; 35e1: b7          .
	lxi	b,L3667		;; 35e2: 01 67 36    .g6
	cnz	L36e2		;; 35e5: c4 e2 36    ..6
	jmp	L3604		;; 35e8: c3 04 36    ..6

L35eb:	call	fread		;; 35eb: cd b0 36    ..6
	ora	a		;; 35ee: b7          .
	jz	L3604		;; 35ef: ca 04 36    ..6
	lhld	rwrecs		;; 35f2: 2a 2a 36    **6
	mov	a,h		;; 35f5: 7c          |
	ora	l		;; 35f6: b5          .
	jnz	L3618		;; 35f7: c2 18 36    ..6
	lxi	b,L3655		;; 35fa: 01 55 36    .U6
	lhld	rwfcb		;; 35fd: 2a 24 36    *$6
	xchg			;; 3600: eb          .
	call	L3534		;; 3601: cd 34 35    .45
L3604:	lhld	rwdma		;; 3604: 2a 22 36    *"6
	lxi	d,128		;; 3607: 11 80 00    ...
	dad	d		;; 360a: 19          .
	shld	rwdma		;; 360b: 22 22 36    ""6
	lhld	rwrecs		;; 360e: 2a 2a 36    **6
	inx	h		;; 3611: 23          #
	shld	rwrecs		;; 3612: 22 2a 36    "*6
	jmp	L35ba		;; 3615: c3 ba 35    ..5

L3618:	lxi	b,defdma	;; 3618: 01 80 00    ...
	call	fstdma		;; 361b: cd cc 36    ..6
	lhld	rwrecs		;; 361e: 2a 2a 36    **6
	ret			;; 3621: c9          .

rwdma:	db	0,0
rwfcb:	db	0,0
rwbyts:	db	0,0
	db	0,0
rwrecs:	db	0,0
rwflag:	db	0

L362d:	db	'ABORTED$'
L3635:	db	'NO SPACE$'
L363e:	db	'NO FILE: $'
L3648:	db	'CANNOT CLOSE$'
L3655:	db	'DISK READ ERROR: $'
L3667:	db	'DISK WRITE ERROR'
L3677:	db	'$'

chrout:	mov	e,c		;; 3678: 59          Y
	mvi	c,conout	;; 3679: 0e 02       ..
	jmp	bdos		;; 367b: c3 05 00    ...

lstchr:	mov	e,c		;; 367e: 59          Y
	mvi	c,lstout	;; 367f: 0e 05       ..
	jmp	bdos		;; 3681: c3 05 00    ...

getlin:	mov	e,c		;; 3684: 59          Y
	mov	d,b		;; 3685: 50          P
	mvi	c,linin		;; 3686: 0e 0a       ..
	jmp	bdos		;; 3688: c3 05 00    ...

chrst:	mvi	c,const		;; 368b: 0e 0b       ..
	jmp	bdos		;; 368d: c3 05 00    ...

verson:	mvi	c,getver	;; 3690: 0e 0c       ..
	jmp	bdos		;; 3692: c3 05 00    ...

fopen:	mov	e,c		;; 3695: 59          Y
	mov	d,b		;; 3696: 50          P
	mvi	c,open		;; 3697: 0e 0f       ..
	jmp	bdos		;; 3699: c3 05 00    ...

fclose:	push	b		;; 369c: c5          .
	lxi	b,defdma	;; 369d: 01 80 00    ...
	call	fstdma		;; 36a0: cd cc 36    ..6
	pop	d		;; 36a3: d1          .
	mvi	c,close		;; 36a4: 0e 10       ..
	jmp	bdos		;; 36a6: c3 05 00    ...

fdelet:	mov	e,c		;; 36a9: 59          Y
	mov	d,b		;; 36aa: 50          P
	mvi	c,delete	;; 36ab: 0e 13       ..
	jmp	bdos		;; 36ad: c3 05 00    ...

fread:	mov	e,c		;; 36b0: 59          Y
	mov	d,b		;; 36b1: 50          P
	mvi	c,read		;; 36b2: 0e 14       ..
	jmp	bdos		;; 36b4: c3 05 00    ...

fwrite:	mov	e,c		;; 36b7: 59          Y
	mov	d,b		;; 36b8: 50          P
	mvi	c,write		;; 36b9: 0e 15       ..
	jmp	bdos		;; 36bb: c3 05 00    ...

fmake:	mov	e,c		;; 36be: 59          Y
	mov	d,b		;; 36bf: 50          P
	mvi	c,make		;; 36c0: 0e 16       ..
	jmp	bdos		;; 36c2: c3 05 00    ...

	mov	e,c		;; 36c5: 59          Y
	mov	d,b		;; 36c6: 50          P
	mvi	c,017h		;; 36c7: 0e 17       ..
	jmp	bdos		;; 36c9: c3 05 00    ...

fstdma:	mov	e,c		;; 36cc: 59          Y
	mov	d,b		;; 36cd: 50          P
	mvi	c,setdma	;; 36ce: 0e 1a       ..
	jmp	bdos		;; 36d0: c3 05 00    ...

sysdat:	mvi	c,getsda	;; 36d3: 0e 9a       ..
	jmp	bdos		;; 36d5: c3 05 00    ...

crlf:	mvi	c,cr		;; 36d8: 0e 0d       ..
	call	putchr		;; 36da: cd b2 02    ...
	mvi	c,lf		;; 36dd: 0e 0a       ..
	jmp	putchr		;; 36df: c3 b2 02    ...

L36e2:	call	pagmsg		;; 36e2: cd c8 02    ...
	jmp	cpm		;; 36e5: c3 00 00    ...

L36e8:	lxi	h,L3e83		;; 36e8: 21 83 3e    ..>
	mvi	m,0		;; 36eb: 36 00       6.
	inx	h		;; 36ed: 23          #
	mvi	m,0		;; 36ee: 36 00       6.
	call	verson		;; 36f0: cd 90 36    ..6
	shld	L3e81		;; 36f3: 22 81 3e    ".>
	lhld	L3e81		;; 36f6: 2a 81 3e    *.>
	mov	a,h		;; 36f9: 7c          |
	cpi	0		;; 36fa: fe 00       ..
	jnz	L3724		;; 36fc: c2 24 37    .$7
	mvi	a,6		;; 36ff: 3e 06       >.
	lxi	d,L39a6		;; 3701: 11 a6 39    ..9
	call	subxxa		;; 3704: cd ab 38    ..8
	shld	L3e7c		;; 3707: 22 7c 3e    "|>
	inx	h		;; 370a: 23          #
	inx	h		;; 370b: 23          #
	lxi	b,3		;; 370c: 01 03 00    ...
	push	h		;; 370f: e5          .
	lhld	L3e7c		;; 3710: 2a 7c 3e    *|>
	dad	b		;; 3713: 09          .
	mov	a,m		;; 3714: 7e          ~
	pop	h		;; 3715: e1          .
	ora	m		;; 3716: b6          .
	cpi	0		;; 3717: fe 00       ..
	jz	L3721		;; 3719: ca 21 37    ..7
	lxi	h,L3e83		;; 371c: 21 83 3e    ..>
	mvi	m,1		;; 371f: 36 01       6.
L3721:	jmp	L3744		;; 3721: c3 44 37    .D7

L3724:	lhld	L3e81		;; 3724: 2a 81 3e    *.>
	mov	a,h		;; 3727: 7c          |
	cpi	1		;; 3728: fe 01       ..
	jnz	L373f		;; 372a: c2 3f 37    .?7
	lxi	h,L3e84		;; 372d: 21 84 3e    ..>
	mvi	m,1		;; 3730: 36 01       6.
	call	sysdat		;; 3732: cd d3 36    ..6
	lxi	d,000b5h	;; 3735: 11 b5 00    ...
	dad	d		;; 3738: 19          .
	shld	L3e7c		;; 3739: 22 7c 3e    "|>
	jmp	L3744		;; 373c: c3 44 37    .D7

L373f:	lxi	h,L3e83		;; 373f: 21 83 3e    ..>
	mvi	m,1		;; 3742: 36 01       6.
L3744:	lda	L3e83		;; 3744: 3a 83 3e    :.>
	rar			;; 3747: 1f          .
	jnc	L3759		;; 3748: d2 59 37    .Y7
	lxi	h,L3e7e		;; 374b: 21 7e 3e    .~>
	mvi	m,0ffh		;; 374e: 36 ff       6.
	inx	h		;; 3750: 23          #
	mvi	m,0ffh		;; 3751: 36 ff       6.
	inx	h		;; 3753: 23          #
	mvi	m,0ffh		;; 3754: 36 ff       6.
	jmp	L3785		;; 3756: c3 85 37    ..7

L3759:	lhld	L3e7c		;; 3759: 2a 7c 3e    *|>
	mov	a,m		;; 375c: 7e          ~
	sta	L3e7e		;; 375d: 32 7e 3e    2~>
	lxi	b,00004h	;; 3760: 01 04 00    ...
	lhld	L3e7c		;; 3763: 2a 7c 3e    *|>
	dad	b		;; 3766: 09          .
	mov	a,m		;; 3767: 7e          ~
	sta	L3e7f		;; 3768: 32 7f 3e    2.>
	lda	L3e84		;; 376b: 3a 84 3e    :.>
	rar			;; 376e: 1f          .
	jnc	L377a		;; 376f: d2 7a 37    .z7
	lda	L3e7f		;; 3772: 3a 7f 3e    :.>
	ori	080h		;; 3775: f6 80       ..
	sta	L3e7f		;; 3777: 32 7f 3e    2.>
L377a:	lxi	b,5		;; 377a: 01 05 00    ...
	lhld	L3e7c		;; 377d: 2a 7c 3e    *|>
	dad	b		;; 3780: 09          .
	mov	a,m		;; 3781: 7e          ~
	sta	L3e80		;; 3782: 32 80 3e    2.>
L3785:	ret			;; 3785: c9          .

L3786:	lxi	h,L3e85		;; 3786: 21 85 3e    ..>
	mvi	m,000h		;; 3789: 36 00       6.
L378b:	mvi	a,005h		;; 378b: 3e 05       >.
	lxi	h,L3e85		;; 378d: 21 85 3e    ..>
	cmp	m		;; 3790: be          .
	jc	L37b0		;; 3791: da b0 37    ..7
	lhld	L3e85		;; 3794: 2a 85 3e    *.>
	mvi	h,000h		;; 3797: 26 00       &.
	lxi	b,L3e76		;; 3799: 01 76 3e    .v>
	dad	b		;; 379c: 09          .
	mov	a,m		;; 379d: 7e          ~
	cma			;; 379e: 2f          /
	lhld	L3e85		;; 379f: 2a 85 3e    *.>
	mvi	h,000h		;; 37a2: 26 00       &.
	lxi	b,rellab		;; 37a4: 01 a2 3a    ..:
	dad	b		;; 37a7: 09          .
	mov	m,a		;; 37a8: 77          w
	lxi	h,L3e85		;; 37a9: 21 85 3e    ..>
	inr	m		;; 37ac: 34          4
	jnz	L378b		;; 37ad: c2 8b 37    ..7
L37b0:	lxi	b,rellab		;; 37b0: 01 a2 3a    ..:
	push	b		;; 37b3: c5          .
	mvi	e,001h		;; 37b4: 1e 01       ..
	mvi	c,006h		;; 37b6: 0e 06       ..
	call	L1512		;; 37b8: cd 12 15    ...
	rar			;; 37bb: 1f          .
	jc	L37c0		;; 37bc: da c0 37    ..7
	ret			;; 37bf: c9          .

L37c0:	call	getval		;; 37c0: cd 32 14    .2.
	shld	L3a67		;; 37c3: 22 67 3a    "g:
	mvi	c,003h		;; 37c6: 0e 03       ..
	call	L205e		;; 37c8: cd 5e 20    .^ 
	lhld	L3a7f		;; 37cb: 2a 7f 3a    *.:
	shld	L3e7c		;; 37ce: 22 7c 3e    "|>
	lxi	d,00009h	;; 37d1: 11 09 00    ...
	lhld	L3a67		;; 37d4: 2a 67 3a    *g:
	dad	d		;; 37d7: 19          .
	shld	L3a7f		;; 37d8: 22 7f 3a    ".:
	lhld	L39f3		;; 37db: 2a f3 39    *.9
	mov	c,l		;; 37de: 4d          M
	call	L2079		;; 37df: cd 79 20    .y 
	lhld	L39f4		;; 37e2: 2a f4 39    *.9
	mov	c,l		;; 37e5: 4d          M
	call	L2079		;; 37e6: cd 79 20    .y 
	lhld	L39f5		;; 37e9: 2a f5 39    *.9
	mov	c,l		;; 37ec: 4d          M
	call	L2079		;; 37ed: cd 79 20    .y 
	lhld	L3e7e		;; 37f0: 2a 7e 3e    *~>
	mov	c,l		;; 37f3: 4d          M
	call	L2079		;; 37f4: cd 79 20    .y 
	lhld	L3e7f		;; 37f7: 2a 7f 3e    *.>
	mov	c,l		;; 37fa: 4d          M
	call	L2079		;; 37fb: cd 79 20    .y 
	lhld	L3e80		;; 37fe: 2a 80 3e    *.>
	mov	c,l		;; 3801: 4d          M
	call	L2079		;; 3802: cd 79 20    .y 
	lhld	L3e7c		;; 3805: 2a 7c 3e    *|>
	shld	L3a7f		;; 3808: 22 7f 3a    ".:
	ret			;; 380b: c9          .

	mov	l,c		;; 380c: 69          i
	mov	h,b		;; 380d: 60          `
; HL = *(HL) + *(DE)
addxxx:	mov	c,m		;; 380e: 4e          N
	inx	h		;; 380f: 23          #
	mov	b,m		;; 3810: 46          F
	ldax	d		;; 3811: 1a          .
	add	c		;; 3812: 81          .
	mov	l,a		;; 3813: 6f          o
	inx	d		;; 3814: 13          .
	ldax	d		;; 3815: 1a          .
	adc	b		;; 3816: 88          .
	mov	h,a		;; 3817: 67          g
	ret			;; 3818: c9          .

; HL = A + *(DE)
addxxa:	xchg			;; 3819: eb          .
	mov	e,a		;; 381a: 5f          _
	mvi	d,0		;; 381b: 16 00       ..
; HL += *(DE)
addxx:	xchg			;; 381d: eb          .
	ldax	d		;; 381e: 1a          .
	add	l		;; 381f: 85          .
	mov	l,a		;; 3820: 6f          o
	inx	d		;; 3821: 13          .
	ldax	d		;; 3822: 1a          .
	adc	h		;; 3823: 8c          .
	mov	h,a		;; 3824: 67          g
	ret			;; 3825: c9          .

L3826:	mov	e,a		;; 3826: 5f          _
	mvi	d,000h		;; 3827: 16 00       ..
L3829:	mov	a,e		;; 3829: 7b          {
	ana	l		;; 382a: a5          .
	mov	l,a		;; 382b: 6f          o
	mov	a,d		;; 382c: 7a          z
	ana	h		;; 382d: a4          .
	mov	h,a		;; 382e: 67          g
	ret			;; 382f: c9          .

L3830:	xchg			;; 3830: eb          .
	mov	e,a		;; 3831: 5f          _
	mvi	d,000h		;; 3832: 16 00       ..
	xchg			;; 3834: eb          .
	ldax	d		;; 3835: 1a          .
	ana	l		;; 3836: a5          .
	mov	l,a		;; 3837: 6f          o
	inx	d		;; 3838: 13          .
	ldax	d		;; 3839: 1a          .
	ana	h		;; 383a: a4          .
	mov	h,a		;; 383b: 67          g
	ret			;; 383c: c9          .

; divide DE/HL
; returns: DE=quotient, HL=remainder
divide:	mov	b,h		;; 383d: 44          D
	mov	c,l		;; 383e: 4d          M
; divide DE/BC
; returns: DE=quotient, HL=remainder
; preserves BC...
divbc:	lxi	h,0		;; 383f: 21 00 00    ...
	mvi	a,16		;; 3842: 3e 10       >.
L3844:	push	psw		;; 3844: f5          .
	dad	h		;; 3845: 29          )
	xchg			;; 3846: eb          .
	sub	a		;; 3847: 97          .
	dad	h		;; 3848: 29          )
	xchg			;; 3849: eb          .
	adc	l		;; 384a: 8d          .
	sub	c		;; 384b: 91          .
	mov	l,a		;; 384c: 6f          o
	mov	a,h		;; 384d: 7c          |
	sbb	b		;; 384e: 98          .
	mov	h,a		;; 384f: 67          g
	inx	d		;; 3850: 13          .
	jnc	L3856		;; 3851: d2 56 38    .V8
	dad	b		;; 3854: 09          .
	dcx	d		;; 3855: 1b          .
L3856:	pop	psw		;; 3856: f1          .
	dcr	a		;; 3857: 3d          =
	jnz	L3844		;; 3858: c2 44 38    .D8
	ret			;; 385b: c9          .

; multiply DE by HL
mult:	mov	b,h		;; 385c: 44          D
	mov	c,l		;; 385d: 4d          M
; multiply DE by BC
multbc:	lxi	h,0		;; 385e: 21 00 00    ...
	mvi	a,16		;; 3861: 3e 10       >.
L3863:	dad	h		;; 3863: 29          )
	xchg			;; 3864: eb          .
	dad	h		;; 3865: 29          )
	xchg			;; 3866: eb          .
	jnc	L386b		;; 3867: d2 6b 38    .k8
	dad	b		;; 386a: 09          .
L386b:	dcr	a		;; 386b: 3d          =
	jnz	L3863		;; 386c: c2 63 38    .c8
	ret			;; 386f: c9          .

orxa:	mov	e,a		;; 3870: 5f          _
	mvi	d,0		;; 3871: 16 00       ..
	mov	a,e		;; 3873: 7b          {
	ora	l		;; 3874: b5          .
	mov	l,a		;; 3875: 6f          o
	mov	a,d		;; 3876: 7a          z
	ora	h		;; 3877: b4          .
	mov	h,a		;; 3878: 67          g
	ret			;; 3879: c9          .

	mov	e,m		;; 387a: 5e          ^
	inx	h		;; 387b: 23          #
	mov	d,m		;; 387c: 56          V
	xchg			;; 387d: eb          .
shlx:	dad	h		;; 387e: 29          )
	dcr	c		;; 387f: 0d          .
	jnz	shlx		;; 3880: c2 7e 38    .~8
	ret			;; 3883: c9          .

L3884:	mov	e,m		;; 3884: 5e          ^
	inx	h		;; 3885: 23          #
	mov	d,m		;; 3886: 56          V
	xchg			;; 3887: eb          .
L3888:	mov	a,h		;; 3888: 7c          |
	ora	a		;; 3889: b7          .
	rar			;; 388a: 1f          .
	mov	h,a		;; 388b: 67          g
	mov	a,l		;; 388c: 7d          }
	rar			;; 388d: 1f          .
	mov	l,a		;; 388e: 6f          o
	dcr	c		;; 388f: 0d          .
	jnz	L3888		;; 3890: c2 88 38    ..8
	ret			;; 3893: c9          .

; HL = A - HL
subxa:	mov	e,a		;; 3894: 5f          _
	mvi	d,0		;; 3895: 16 00       ..
; HL = DE - HL
subx:	mov	a,e		;; 3897: 7b          {
	sub	l		;; 3898: 95          .
	mov	l,a		;; 3899: 6f          o
	mov	a,d		;; 389a: 7a          z
	sbb	h		;; 389b: 9c          .
	mov	h,a		;; 389c: 67          g
	ret			;; 389d: c9          .

; HL = *(DE) - *(BC)
subxxx:	mov	l,c		;; 389e: 69          i
	mov	h,b		;; 389f: 60          `
; HL = *(DE) - *(HL)
subxxm:	mov	c,m		;; 38a0: 4e          N
	inx	h		;; 38a1: 23          #
	mov	b,m		;; 38a2: 46          F
; HL = *(DE) - BC
subxxb:	ldax	d		;; 38a3: 1a          .
	sub	c		;; 38a4: 91          .
	mov	l,a		;; 38a5: 6f          o
	inx	d		;; 38a6: 13          .
	ldax	d		;; 38a7: 1a          .
	sbb	b		;; 38a8: 98          .
	mov	h,a		;; 38a9: 67          g
	ret			;; 38aa: c9          .

; HL = *(DE) - A
subxxa:	mov	l,a		;; 38ab: 6f          o
	mvi	h,0		;; 38ac: 26 00       &.
; HL = *(DE) - HL
subxx:	ldax	d		;; 38ae: 1a          .
	sub	l		;; 38af: 95          .
	mov	l,a		;; 38b0: 6f          o
	inx	d		;; 38b1: 13          .
	ldax	d		;; 38b2: 1a          .
	sbb	h		;; 38b3: 9c          .
	mov	h,a		;; 38b4: 67          g
	ret			;; 38b5: c9          .

; HL = A - *(HL)
L38b6:	mov	e,a		;; 38b6: 5f          _
	mvi	d,0		;; 38b7: 16 00       ..
; HL = DE - *(HL)
L38b9:	mov	a,e		;; 38b9: 7b          {
	sub	m		;; 38ba: 96          .
	mov	e,a		;; 38bb: 5f          _
	mov	a,d		;; 38bc: 7a          z
	inx	h		;; 38bd: 23          #
	sbb	m		;; 38be: 9e          .
	mov	d,a		;; 38bf: 57          W
	xchg			;; 38c0: eb          .
	ret			;; 38c1: c9          .

	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
stack:	ds	0

L394c:	db	ff	; new page w/header
L394d:	db	'LINK 1.31',lf,cr,'$'
	db	'01/04/83'
L3961:	db	'?MEMRY'
L3967:	db	'$MEMRY'
L396d:	db	0,0
prlflg:	db	0	; 0=COM, 1=PRL, 2=RSP, 3=SPR
L3970:	db	0,1
L3972:	db	0
L3973:	db	1
condst:	db	'X'
intdst:	db	0
libdst:	db	0
objdst:	db	0
symdst:	db	0
L3979:	db	0
L397a:	db	1
L397b:	db	0
L397c:	db	0,0
L397e:	db	0
L397f:	db	'           '
L398a:	db	0
L398b:	db	0,0
L398d:	db	0
L398e:	db	0
L398f:	db	0
L3990:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
L39a4:	db	0,0
L39a6:	db	0,0
L39a8:	db	0,0
L39aa:	db	'MEMORY OVERFLOW, USE [A] SWITCH$'
L39ca:	db	'INSUFFICIENT MEMORY$'
L39de:	db	'OVERLAPPING SEGMENTS$'
L39f3:	db	0
L39f4:	db	0
L39f5:	db	0
L39f6:	db	0,0
L39f8:	db	0,0
L39fa:	db	0
L39fb:	db	0
L39fc:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0
L3a1c:	db	0
L3a1d:	db	0,0
L3a1f:	db	0,2
L3a21:	db	0
L3a22:	db	'         '
L3a2b:	db	'   '
L3a2e:	db	0,0
L3a30:	db	0
L3a31:	db	0,0
L3a33:	db	0,4
L3a35:	db	0,0
L3a37:	db	0,4
L3a39:	db	0
L3a3a:	db	0,0,0,0,0,0,0
L3a41:	db	0,0
L3a43:	db	0
L3a44:	db	0
L3a45:	db	0
L3a46:	db	0,0
L3a48:	db	0,0
L3a4a:	db	0,0,0,0,0,0,0
L3a51:	db	0
L3a52:	db	0
L3a53:	db	0,0
L3a55:	db	0
L3a56:	db	0,0
L3a58:	db	0ffh,0ffh
L3a5a:	db	0,0
L3a5c:	db	0
segmnt:	db	0
L3a5e:	db	0
L3a5f:	db	0
L3a60:	db	0,0
L3a62:	db	0,0
cursym:	db	0,0
L3a66:	db	0
L3a67:	db	0,0
L3a69:	db	0,0
L3a6b:	db	0,0
L3a6d:	db	0,0
L3a6f:	db	0,0
L3a71:	db	0,0
L3a73:	db	0ffh,0ffh
L3a75:	db	0,0
L3a77:	db	0,0

L3a79:	db	0,0	; counters indexed by segment
L3a7b:	db	0,0
L3a7d:	db	0,0
L3a7f:	db	0,0

L3a81:	db	0,0
L3a83:	db	0,0
L3a85:	db	0,0
L3a87:	db	0,0
L3a89:	db	0,0
L3a8b:	db	0,0
L3a8d:	db	0,0
L3a8f:	db	0,0
L3a91:	db	0,0
L3a93:	db	0,0
L3a95:	db	0,0
L3a97:	db	0,0
L3a99:	db	0
L3a9a:	db	1,2,3
L3a9d:	db	0

relseg:	db	0
reladr:	db	0,0
rellen:	db	0	; length of rellab
rellab:	db	0,0,0,0,0,0,0,0

L3aaa:	db	0,0	; +0
L3aac:	db	0,0	; +2
L3aae:	db	0,0	; +4
L3ab0:	db	0,0	; +6
L3ab2:	db	1,0	; +8
L3ab4:	db	0,0,0,0	; +10, +14:
L3ab8:	db	0,'XXABS   $$$',0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0

L3ad9:	db	0,0
L3adb:	db	0,0
L3add:	db	0,0
L3adf:	db	0,0
L3ae1:	db	1,0
L3ae3:	db	0,0,0,0
L3ae7:	db	0,'XXPROG  $$$',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

L3b08:	db	0,0
L3b0a:	db	0,0
L3b0c:	db	0,0
L3b0e:	db	0,0
L3b10:	db	1,0
L3b12:	db	0,0,0,0
L3b16:	db	0,'XXDATA  $$$',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

L3b37:	db	0,0
L3b39:	db	0,0
L3b3b:	db	0,0
L3b3d:	db	0,0
L3b3f:	db	1,0
L3b41:	db	0,0,0,0
L3b45:	db	0,'XXCOMM  $$$',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

L3b66:	dw	L3aaa	; indexed by segment
	dw	L3ad9
	dw	L3b08
	dw	L3b37

L3b6e:	db	0,0
L3b70:	db	0,0
L3b72:	db	0,1
L3b74:	db	0
L3b75:	db	0,'YYABS   $$$',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

L3b96:	db	0,0
L3b98:	db	0,0
L3b9a:	db	0,4
L3b9c:	db	0
L3b9d:	db	0,'YYPROG  $$$',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

L3bbe:	db	0,0
L3bc0:	db	0,0
L3bc2:	db	0,4
L3bc4:	db	0
L3bc5:	db	0,'YYDATA  $$$',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

L3be6:	db	0,0
L3be8:	db	0,0
L3bea:	db	0,1
L3bec:	db	0
L3bed:	db	0,'YYCOMM  $$$',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

L3c0e:	dw	L3b6e	; indexed by segment
	dw	L3b96
	dw	L3bbe
	dw	L3be6

L3c16:	db	0
L3c17:	db	0,0
L3c19:	db	0
L3c1a:	db	0,0
L3c1c:	db	0
L3c1d:	db	0
L3c1e:	db	0
curchr:	db	0
L3c20:	db	0
L3c21:	db	0,0
L3c23:	db	0,0
L3c25:	db	0
L3c26:	db	0,0
L3c28:	db	0
L3c29:	db	0
L3c2a:	db	0
L3c2b:	db	0,0
L3c2d:	db	0
L3c2e:	db	0,0
L3c30:	db	0,0
L3c32:	db	0
L3c33:	db	0
L3c34:	db	0
L3c35:	db	0
L3c36:	db	0
L3c37:	db	0
L3c38:	db	0
L3c39:	db	0
L3c3a:	db	0
L3c3b:	db	0
L3c3c:	db	0
L3c3d:	db	0
L3c3e:	db	0
L3c3f:	db	0
L3c40:	db	0
L3c41:	db	0
L3c42:	db	0
L3c43:	db	0
L3c44:	db	0
L3c45:	db	0,0
L3c47:	db	0,0
L3c49:	db	0
L3c4a:	db	0,0
L3c4c:	db	0,0
L3c4e:	db	0
L3c4f:	db	0
L3c50:	db	0
L3c51:	db	0
L3c52:	db	0,0
L3c54:	db	0
L3c55:	db	0
L3c56:	db	0
L3c57:	db	0,0
L3c59:	db	0,0
L3c5b:	db	0
L3c5c:	db	0,0
L3c5e:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
L3d5e:	db	0
L3d5f:	db	0
L3d60:	db	0
L3d61:	db	0
L3d62:	db	0
L3d63:	db	0
L3d64:	db	0,0
L3d66:	db	0,0
L3d68:	db	0
L3d69:	db	0,0
L3d6b:	db	0
L3d6c:	db	0,0
L3d6e:	db	0
L3d6f:	db	0,0
L3d71:	db	0
L3d72:	db	0
L3d73:	db	0,0
L3d75:	db	0
L3d76:	db	0,0
L3d78:	db	0
L3d79:	db	0
L3d7a:	db	0
L3d7b:	db	0
L3d7c:	db	0
L3d7d:	db	0
L3d7e:	db	0
L3d7f:	db	0,0
L3d81:	db	0
L3d82:	db	0
L3d83:	db	0
L3d84:	db	0
L3d85:	db	0
L3d86:	db	0
L3d87:	db	0
L3d88:	db	0
L3d89:	db	0
L3d8a:	db	0
L3d8b:	db	0
L3d8c:	db	0
L3d8d:	db	0,0
L3d8f:	db	0
L3d90:	db	0
L3d91:	db	0,0
L3d93:	db	0,0
L3d95:	db	0,0
L3d97:	db	0,0
L3d99:	db	0
L3d9a:	db	0
L3d9b:	db	0
L3d9c:	db	0
L3d9d:	db	0
L3d9e:	db	0
L3d9f:	db	0,0
L3da1:	db	0
L3da2:	db	0
L3da3:	db	0,0
L3da5:	db	0
L3da6:	db	0
L3da7:	db	0
L3da8:	db	0
L3da9:	db	'INDEX ERROR$'
L3db5:	db	'MULTIPLE DEFINITION: $'
L3dcb:	db	'MAIN MODULE ERROR$'
L3ddd:	db	'FIRST COMMON NOT LARGEST$'
L3df6:	db	'COMMON ERROR$'
L3e03:	db	'UNRECOGNIZED ITEM',cr,lf,'$'
L3e17:	db	0
L3e18:	db	0
L3e19:	db	0
L3e1a:	db	0
L3e1b:	db	0,0
L3e1d:	db	0
L3e1e:	db	0
L3e1f:	db	0,0
L3e21:	db	0,0
L3e23:	db	0,0
L3e25:	db	0
L3e26:	db	0
L3e27:	db	0,0
L3e29:	db	0
L3e2a:	db	0
L3e2b:	db	0
L3e2c:	db	0
L3e2d:	db	0
L3e2e:	db	0,0
L3e30:	db	0
L3e31:	db	0,0
L3e33:	db	0
L3e34:	db	0,0
L3e36:	db	0
L3e37:	db	0
L3e38:	db	0
L3e39:	db	0,0
L3e3b:	db	0
L3e3c:	db	0
L3e3d:	db	0
L3e3e:	db	0
L3e3f:	db	0
L3e40:	db	0
L3e41:	db	0,0
L3e43:	db	0
L3e44:	db	0,0
L3e46:	db	0
L3e47:	db	0
L3e48:	db	0,0
L3e4a:	db	0
L3e4b:	db	0
L3e4c:	db	0
L3e4d:	db	0,0
L3e4f:	db	0
L3e50:	db	0
L3e51:	db	0
L3e52:	db	0
L3e53:	db	0
L3e54:	db	0
L3e55:	db	0
L3e56:	db	0
L3e57:	db	0,0
L3e59:	db	0
L3e5a:	db	0
tmpfil:	db	0,0	; currently active (temp) FCB?
L3e5d:	db	0,0
L3e5f:	db	0
L3e60:	db	0
curext:	db	0
currec:	db	0,0
L3e64:	db	0
L3e65:	db	0
L3e66:	db	0,0
L3e68:	db	0,0
L3e6a:	db	0,0
L3e6c:	db	0,0
L3e6e:	db	0
L3e6f:	db	0,0
L3e71:	db	0,0
L3e73:	db	0
L3e74:	db	0
L3e75:	db	0
L3e76:	db	0c0h,0b9h,0afh,0bdh,0b1h,0a7h
L3e7c:	db	1ah,1ah
L3e7e:	db	1ah
L3e7f:	db	1ah
L3e80:	ds	0
	ds	1
L3e81:	ds	0
	ds	2
L3e83:	ds	0
	ds	1
L3e84:	ds	0
	ds	1
L3e85:	ds	0
	ds	1
L3e86:	ds	0
	ds	512
L4086:	ds	0
	ds	512
L4286:	ds	0
	ds	1
L4287:	ds	0
	ds	1
L4288:	ds	0
	ds	126
L4306:	ds	0
	end
