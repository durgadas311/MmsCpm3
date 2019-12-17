;MAC.COM - module 4
M2100	equ	1

	public	L2100,L2103,L2106,L2109,L210c
	maclib	m1200
	maclib	m1600
	maclib	m1c00
	maclib	m2580
	maclib	macg

	extrn	L2600	; odd terminator of chain

; Module begin L2100 - parser (assembler)
	;org	2100h
	cseg
L2100:	jmp	L2600		;; 2100: c3 00 26    ..&
L2103:	jmp	L2380		;; 2103: c3 80 23    ..#
L2106:	jmp	L240d		;; 2106: c3 0d 24    ..$
L2109:	jmp	L2462		;; 2109: c3 62 24    .b$
L210c:	jmp	L247b		;; 210c: c3 7b 24    .{$

L210f:	db	0fch

L2110:	dw	L212a	; 1-char tokens
	dw	L213a	; 2-char tokens
	dw	L2158	; 3-char tokens
	dw	L21fd	; 4-char tokens
	dw	L224d	; 5-char tokens
	dw	L2270	; 6-char tokens

	dw	L2282

L211e:	dw	L2288	; 1-char token flags
	dw	L22a8	; 2-char token flags
	dw	L22c6	; 3-char token flags
	dw	L2334	; 4-char token flags
	dw	L235c	; 5-char token flags
	dw	L236a	; 6-char token flags

L212a:	db	0dh,'(',')','*','+',',','-','/','A','B','C','D','E','H','L','M'
num1	equ	$-L212a

L213a:	db	'DB','DI','DS','DW','EI','EQ','GE','GT','IF','IN','LE','LT','NE','OR','SP'
num2	equ	($-L213a)/2

L2158:	db	'ACI','ADC','ADD','ADI','ANA','AND','ANI','CMA','CMC'
	db	'CMP','CPI','DAA','DAD','DCR','DCX','END','EQU','HLT','INR'
	db	'INX','IRP','JMP','LDA','LOW','LXI','MOD','MOV','MVI','NOP'
	db	'NOT','NUL','ORA','ORG','ORI','OUT','POP','PSW','RAL','RAR'
	db	'RET','RLC','RRC','RST','SBB','SBI','SET','SHL','SHR','STA'
	db	'STC','SUB','SUI','XOR','XRA','XRI'
num3	equ	($-L2158)/3

L21fd:	db	'ASEG','CALL','CSEG','DSEG','ELSE','ENDM','HIGH','IRPC','LDAX'
	db	'LHLD','NAME','PAGE','PCHL','PUSH'
	db	'REPT','SHLD','SPHL','STAX','XCHG','XTHL'
num4	equ	($-L21fd)/4

L224d:	db	'ENDIF','EXITM','EXTRN','LOCAL','MACRO','STKLN','TITLE'
num5	equ	($-L224d)/5

L2270:	db	'INPAGE','MACLIB','PUBLIC'
num6	equ	($-L2270)/6

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

L22a8:	db	1ah,1		; 'DB'
	db	1ch,0f3h	; 'DI'
	db	1ah,2		; 'DS'
	db	1ah,3		; 'DW'
	db	1ch,0fbh	; 'EI'
	db	8,41h		; 'EQ'
	db	0ch,41h		; 'GE'
	db	0bh,41h		; 'GT'
	db	1ah,8		; 'IF'
	db	2ah,0dbh	; 'IN'
	db	0ah,41h		; 'LE'
	db	9,41h		; 'LT'
	db	0dh,41h		; 'NE'
	db	10h,28h		; 'OR'
	db	19h,6		; 'SP'

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
	mvi	c,000h		;; 2383: 0e 00       ..
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
	lxi	d,L3009		;; 23a0: 11 09 30    ..0
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
L23c4:	lda	L3009		;; 23c4: 3a 09 30    :.0
	lxi	b,0c220h	;; 23c7: 01 20 c2    . .
	cpi	'J'		;; 23ca: fe 4a       .J
	rz			;; 23cc: c8          .
	mvi	b,0c4h		;; 23cd: 06 c4       ..
	cpi	'C'		;; 23cf: fe 43       .C
	rz			;; 23d1: c8          .
	lxi	b,0c01ch	;; 23d2: 01 1c c0    ...
	cpi	'R'		;; 23d5: fe 52       .R
	ret			;; 23d7: c9          .

L23d8:	lda	L3008		;; 23d8: 3a 08 30    :.0
	cpi	004h		;; 23db: fe 04       ..
	jnc	L240a		;; 23dd: d2 0a 24    ..$
	cpi	003h		;; 23e0: fe 03       ..
	jz	L23ef		;; 23e2: ca ef 23    ..#
	cpi	002h		;; 23e5: fe 02       ..
	jnz	L240a		;; 23e7: c2 0a 24    ..$
	lxi	h,L300b		;; 23ea: 21 0b 30    ..0
	mvi	m,' '		;; 23ed: 36 20       6 
L23ef:	lxi	b,8		;; 23ef: 01 08 00    ...
	lxi	d,L2370		;; 23f2: 11 70 23    .p#
L23f5:	lxi	h,L300a		;; 23f5: 21 0a 30    ..0
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

L240d:	lda	L3008		;; 240d: 3a 08 30    :.0
	mov	c,a		;; 2410: 4f          O
	dcr	a		;; 2411: 3d          =
	mov	e,a		;; 2412: 5f          _
	mvi	d,0		;; 2413: 16 00       ..
	push	d		;; 2415: d5          .
	cpi	006h		;; 2416: fe 06       ..
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

L2462:	lxi	h,L3008		;; 2462: 21 08 30    ..0
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
	mvi	d,000h		;; 2481: 16 00       ..
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
	lxi	h,L213a		;; 2493: 21 3a 21    .:.
	dad	d		;; 2496: 19          .
	mov	a,b		;; 2497: 78          x
	ret			;; 2498: c9          .

L2499:	dw	2000h	; DB
	dw	2002h	; DI
	dw	2004h	; DS
	dw	2006h	; DW
	dw	2008h	; EI
	dw	200ah	; EQ
	dw	200ch	; GE
	dw	200eh	; GT
	dw	2010h	; IF
	dw	2012h	; IN
	dw	2014h	; LE
	dw	2016h	; LT
	dw	2018h	; NE
	dw	201ah	; OR
	dw	201ch	; SP
	dw	301eh	; ACI
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
	dw	30c0h	; XRI
	dw	40c3h	; ASEG
	dw	40c7h	; CALL
	dw	40cbh	; CSEG
	dw	40cfh	; DSEG
	dw	40d3h	; ELSE
	dw	40d7h	; ENDM
	dw	40dbh	; HIGH
	dw	40dfh	; IRPC
	dw	40e3h	; LDAX
	dw	40e7h	; LHLD
	dw	40ebh	; NAME
	dw	40efh	; PAGE
	dw	40f3h	; PCHL
	dw	40f7h	; PUSH
	dw	40fbh	; REPT
	dw	40ffh	; SHLD
	dw	4103h	; SPHL
	dw	4107h	; STAX
	dw	410bh	; XCHG
	dw	410fh	; XTHL
	dw	5113h	; ENDIF
	dw	5118h	; EXITM
	dw	511dh	; EXTRN
	dw	5122h	; LOCAL
	dw	5127h	; MACRO
	dw	512ch	; STKLN
	dw	5131h	; TITLE
	dw	6136h	; INPAGE
	dw	613ch	; MACLIB
	dw	6142h	; PUBLIC

	; junk code? never executed?
	dw	3058h
	db	22h,0bdh,11h
	db	0cdh,6,16h
	db	0c3h,57h,7

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

	db	'SEAR '
	end
