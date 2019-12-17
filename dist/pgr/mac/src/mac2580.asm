; MAC.COM - module 5
M2580	equ	1

	public	L2580,L2583,L2586,L2589,L258c,L258f,msgcre,L2595,setere
	public	hexpte,hexfne,L25a1,libfie,L25a7,L25aa,L25ad
	public	L2600	; termination? patch???
	maclib	m1200
	maclib	m1600
	maclib	m1c00
	maclib	m2100

	maclib	macg

; Module start L2580 - I/O, OS?
	;org	2580h
	cseg
L2580:	jmp	osinit		;; 2580: c3 f6 26    ..&
L2583:	jmp	L2905		;; 2583: c3 05 29    ..)
L2586:	jmp	L294c		;; 2586: c3 4c 29    .L)
L2589:	jmp	prnput		;; 2589: c3 0e 2a    ..*
L258c:	jmp	hexput		;; 258c: c3 95 2a    ..*
L258f:	jmp	chrout		;; 258f: c3 c9 2a    ..*
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
L25d3:	db	'_',0eh,0eh,0cdh,5,0,0c9h
	db	':JASM'
L25df:	db	0,'PE',0,0c3h,0cdh,'%:L%',0c3h,0cdh,'%:M%',0c3h,0cdh,'%'
	db	':'
L25f3:	db	0
L25f4:	db	0,4
L25f6:	db	0,0

; FCB for output files (PRN, SYM)
prnfcb:	db	4,0cdh,'I*~#',0feh,0dh
L2600:	db	0ffh	;something is wrong here - module termination?
	db	'PRN',0,'FTYPE',0,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	db	0ffh,0ffh,0ffh,0ffh,'s'
	db	0

prnidx:	db	0,0
L261b:	db	0ffh,0ffh

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
	mvi	b,009h		;; 268c: 06 09       ..
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
	lxi	d,L3008		;; 26a6: 11 08 30    ..0
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
	jmp	L2775		;; 26de: c3 75 27    .u'

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
	shld	L304b		;; 272d: 22 4b 30    "K0
	shld	syheap		;; 2730: 22 54 30    "T0
	jmp	parcmd		;; 2733: c3 ea 27    ..'

; print char if not blank
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

L2744:	inx	h		;; 2744: 23          #
	mov	a,m		;; 2745: 7e          ~
	call	L2736		;; 2746: cd 36 27    .6'
	dcr	c		;; 2749: 0d          .
	jnz	L2744		;; 274a: c2 44 27    .D'
	ret			;; 274d: c9          .

L274e:	push	h		;; 274e: e5          .
	xchg			;; 274f: eb          .
	lda	curdrv		;; 2750: 3a c9 25    :.%
	adi	'A'		;; 2753: c6 41       .A
	call	L2736		;; 2755: cd 36 27    .6'
	mvi	a,':'		;; 2758: 3e 3a       >:
	call	L2736		;; 275a: cd 36 27    .6'
	mvi	c,008h		;; 275d: 0e 08       ..
	call	L2744		;; 275f: cd 44 27    .D'
	mvi	a,'.'		;; 2762: 3e 2e       >.
	call	L2736		;; 2764: cd 36 27    .6'
	mvi	c,003h		;; 2767: 0e 03       ..
	call	L2744		;; 2769: cd 44 27    .D'
	mvi	a,'-'		;; 276c: 3e 2d       >-
	call	L2736		;; 276e: cd 36 27    .6'
	pop	h		;; 2771: e1          .
	jmp	msgcr		;; 2772: c3 78 26    .x&

L2775:	mvi	c,open		;; 2775: 0e 0f       ..
	push	d		;; 2777: d5          .
	call	bdos		;; 2778: cd 05 00    ...
	cpi	0ffh		;; 277b: fe ff       ..
	pop	d		;; 277d: d1          .
	rnz			;; 277e: c0          .
	lxi	h,L2ce8		;; 277f: 21 e8 2c    ..,
	call	L274e		;; 2782: cd 4e 27    .N'
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
	call	L274e		;; 27ad: cd 4e 27    .N'
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
	mvi	m,000h		;; 27e2: 36 00       6.
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

L28c8:	lxi	h,L25d3		;; 28c8: 21 d3 25    ..%
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
	sta	L25df		;; 292a: 32 df 25    2.%
	sta	L25f3		;; 292d: 32 f3 25    2.%
	sta	hexlen		;; 2930: 32 b8 25    2.%
	call	setasm		;; 2933: cd 5a 26    .Z&
	lxi	d,L25d3		;; 2936: 11 d3 25    ..%
	call	L2775		;; 2939: cd 75 27    .u'
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
	call	L274e		;; 299c: cd 4e 27    .N'
	jmp	cpm		;; 299f: c3 00 00    ...

L29a2:	lhld	L25f4		;; 29a2: 2a f4 25    *.%
	lxi	d,1024		;; 29a5: 11 00 04    ...
	call	compar		;; 29a8: cd 46 29    .F)
	jnz	L29f0		;; 29ab: c2 f0 29    ..)
	call	setasm		;; 29ae: cd 5a 26    .Z&
	lxi	h,0		;; 29b1: 21 00 00    ...
	shld	L25f4		;; 29b4: 22 f4 25    ".%
	mvi	b,008h		;; 29b7: 06 08       ..
	lhld	L25f6		;; 29b9: 2a f6 25    *.%
L29bc:	push	b		;; 29bc: c5          .
	push	h		;; 29bd: e5          .
	xchg			;; 29be: eb          .
	call	L2642		;; 29bf: cd 42 26    .B&
	mvi	c,read		;; 29c2: 0e 14       ..
	lxi	d,L25d3		;; 29c4: 11 d3 25    ..%
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
	mvi	b,006h		;; 2a5e: 06 06       ..
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
	mvi	b,006h		;; 2ac4: 06 06       ..
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
	mvi	a,vt		;; 2afe: 3e 0c       >.
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
	db	0ffh,0ffh,0ffh,0ffh
; L2e80:
	end
