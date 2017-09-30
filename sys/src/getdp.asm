; July 27, 1983  11:53	mjm  "GETDP.ASM"
	maclib Z80
	$-MACRO
@	equ	-1
; CP/M 3.0 system routine to select a DPB and sector translation table
;  given the mode bytes (4)

****************************************************
* label:  calcdpb   spt,spb,bpd,dpd,nst,pss[,flg]
*
*  spt = Sectors per Track
*  spb = Sectors per allocation Block
*  bpd = allocation Blocks per Disk (max (DS))
*  dpd = Directory entries per Disk
*  nst = Number of System Tracks
*  pss = Physical Sector Size (bytes)
* [flg]= optional flag to intentionally produce incorrect EXM
*	 (used to maintain compatability with previous formats)
*
calcdpb macro ?spt0,?spb0,?dsm0,?drm0,?off0,?pss0,?flg

?bsm	set	?spb0-1
?exm	set	?bsm shr 3
	if ?dsm0 gt 256
?exm	set	?exm shr 1
	endif

	if not NUL ?flg
?exm	set	?exm shr 1
	endif

?cks	set	?drm0/4

?bsh	set	0
?@	set	?spb0
	rept 8
?@	set	?@ shr 1
	if ?@ eq 0
	exitm
	endif
?bsh	set	?bsh+1
	endm

?al0	set	0
	rept (?cks+?bsm)/?spb0
?al0	set	(?al0 shr 1) or 10000000$00000000b
	endm
?al1	set	low ?al0
?al0	set	high ?al0

?psh	set	0
?psm	set	0
?@	set	high ?pss0
	rept 8
	if ?@ eq 0
	exitm
	endif
?psh	set	?psh+1
?psm	set	(?psm shl 1) or 1
?@	set	?@ shr 1
	endm

	dw	?spt0
	db	?bsh,?bsm,?exm
	dw	?dsm0-1,?drm0-1
	db	?al0,?al1
	dw	?cks,?off0
	db	?psh,?psm

	endm
; Entry:  HL = points to Mode bytes
; Exit:    A = error code (0 if DPs found)
;	  DE = points to DPB
;	  BC = points to sector translation table (or BC=0)
;	  HL = offset from ?serdp to beginning of format string table
; Uses 2 levels of stack.
;
	public ?getdp,?serdp
	cseg	;for now we'll put it all in common memory.
?serdp: 		;user has to tell us where we are.
	lxi	b,PTRTBL-?serdp  ;HL=memory address of "?serdp"
	dad	b		 ;DE=mode bytes
	xchg
	jr	gd1

?GETDP:
	lxi	d,ptrtbl
gd1:	PUSH	H		; save mode byte pointer
	push	d	;save parameter table address
	mov	c,m	;no need to mask format origin code.
	inx	h
	mov	b,m
	inx	h
	MOV	A,M		; get first mode byte
	ani	srm0		; mask FIRST BYTE
	MOV	E,A    
	INX	H		; and point to the second
	MOV	A,M
	ani	srm1		; mask SECOND BYTE
	MOV	D,A
	pop	h		; table lookup...
NXDPB:
	MOV	A,M		; format origin code.
	inx	h
	ana	c	;compare it: if the format requested matches
	jrnz	got1	    ;(if the bit is set in both DPB and requested
	mov	a,m	    ; mode ([NZ] condition) then we have a match.)
	ana	b		;check for possible extend format origin
	jrz	nxd1	;...
got1:	inx	h
	MOV	A,M		; get first byte
	INX	H
	ani	srm0		;mask it also
	CMP	E		;compare to target mode
	jrnz	NXD3
	MOV	A,M		; and the second
	ani	srm1		;mask it
	CMP	D		;compare it
	jrnz	NXD3
	inx	h
	mov	e,m	;pick up DPB
	inx	h
	mov	d,m
	inx	h
	mov	c,m	;pick up XLAT also
	inx	h
	mov	b,m
	xchg		;DE=table pointer, HL=DPB
	xthl		;put DPB on stack, get HL=requested mode
	inx	h
	inx	h	;point past "format origin"
	push	b	;put XLAT on stack.
	xchg
	lxi	b,-5
	dad	b	;point back to table's modes
	xchg		;
	ldax	d		;get "excess" mode bits.
	ani	xsm0		;mask in bits to give caller.
	mov	c,a
	mvi	a,(not xsm0) and 0ffh
	ana	m		;clear callers bits prior to setting again
	ora	c		;complete callers mode bytes
	mov	m,a
	inx	h
	inx	d
	ldax	d		;get "excess" mode bits.
	ani	xsm1		;mask in bits to give caller.
	mov	c,a
	mvi	a,(not xsm1) and 0ffh
	ana	m		;clear callers bits prior to setting again
	ora	c		;complete callers mode bytes
	mov	m,a
	pop	b	;restore XLAT
	pop	d	;restore DPB
	lxi	h,strtbl-?serdp ; load address of string table
	XRA	A		; and clear the accumulator
	RET			; as this is the successful return

NXD1:	INX	H
NXD2:	INX	H
nxd3:	inx	h
	inx	h
	inx	h
	inx	h
	inx	h
	MOV	A,M
	CPI	11111111B
	jrnz	NXDPB		; loop if more entries in table
	POP	H		; restore mode byte pointer
	lxi	h,strtbl-?serdp ; load address of string table
	xra a ! dcr a		; return [NZ] if DPs not found.
	RET			; as this is the error return

;						     ; (10-256 byte)
; Format string name table - all formats must have a entry here
;
strtbl	db	'MMS     '	;bit 0 - must be 8 characters wide
	db	'Z17     '	;bit 1
	db	'M47     '	;    2
	db	'Z37     '	;    3
	db	'Z37X    '	;    4
	db	'Z47     '	;    5
	db	'Z47X    '	;    6
	db	'Z67     '	;    7
	db	'Z100    '	;    8
	db	'FMT1    '	;    9
	db	'FMT2    '	;   10
	db	'FMT3    '	;   11
	db	'FMT4    '	;   12
	db	'FMT5    '	;   13
	db	'FMT6    '	;   14

;
;----------------------------------------------------------------------
;
;
;----------------------------------------------------------------------
;
; 
SRM0:	equ	10000000B	      ;
SRM1:	equ		  01110000B   ;SEARCH MODES MASKS

XSM0:	equ	00000011B	      ;
XSM1:	equ		  10001111B   ;EXCESS MODES MASKS

PTRTBL:
	DB	00000001b,11100101B,10000000B,00000000B ; 8" SD SS
	dw	std8,stdx
	DB	00000000b,00000100B,10000011B,00010000B ; m47,dd,ss
	dw	m471,z47xx
	DB	00000000b,00000100B,10000011B,01010000B ; m47,dd,ds
	dw	m472,z47xx
	DB	00000000b,00000001B,10000010B,00010000B ; mms,dd,ss
	dw	mms5,0
	DB	00000000b,00000001B,10000010B,01010000B ; mms,dd,ds
	dw	mms6,0
	DB	00000001b,10100000B,10000000B,01000001B ; z47,z67,z100,sd,ds
	dw	z471,stdx
	DB	00000001b,10100000B,10000001B,00011000B ; z47,z67,z100,dd,ss
	dw	z472,z47x
	DB	00000001b,10100000B,10000001B,01011001B ; z47,z67,z100,dd,ds
	dw	z473,z47x
	DB	00000000b,01000000B,10000011B,00011100B ; z47x,dd,ss
	dw	z474,z47xx
	DB	00000000b,01000000B,10000011B,01011101B ; z47x,dd,ds
	dw	z475,z47xx
	DB	00000000b,00000010B,00000001B,00000000B ; z17,sd,ss,st
	dw	z170,z17x
	DB	00000000b,00000010B,00000001B,01000000B ; z17,sd,ds,st
	dw	z171,z17x
	DB	00000000b,00000010B,00000001B,00100000B ; z17,sd,ss,dt
	dw	z172,z17x
	DB	00000000b,00000010B,00000001B,01100000B ; z17,sd,ds,dt
	dw	z173,z17x
	DB	00000000b,00000001B,00000010B,00010000B ; 5" mms,dd,ss,st
	dw	mms0,0
	DB	00000000b,00000001B,00000010B,01010000B ; 5" mms,dd,ds,st
	dw	mms1,0
	DB	00000000b,00000001B,00000010B,00110000B ; 5" mms,dd,ss,dt
	dw	mms2,0
	DB	00000000b,00000001B,00000010B,01110000B ; 5" mms,dd,ds,dt
	dw	mms3,0
	DB	00000000b,00001000B,00000001B,10000000B ;  z37,sd,ss,st
	dw	z370,0
	DB	00000000b,00001000B,00000001B,10010000B ;  z37,dd,ss,st
	dw	z371,0
	DB	00000000b,00010000B,00000011B,10010000B ;  z37x,dd,ss,st
	dw	z372,0
	DB	00000000b,00001000B,00000001B,11000001B ;  z37,sd,ds,st
	dw	z373,0
	DB	00000000b,00001000B,00000001B,11010001B ;  z37,dd,ds,st
	dw	z374,0
	DB	00000000b,00010000B,00000011B,11010001B ;  z37x,dd,ds,st
	dw	z375,0
	DB	00000000b,00001000B,00000001B,10100000B ;  z37,sd,ss,dt
	dw	z376,0
	DB	00000000b,00001000B,00000001B,10110000B ;  z37,dd,ss,dt
	dw	z377,0
	DB	00000000b,00010000B,00000011B,10110000B ;  z37x,dd,ss,dt
	dw	z378,0
	DB	00000000b,00001000B,00000001B,11100001B ;  z37,sd,ds,dt
	dw	z379,0
	DB	00000000b,00001000B,00000001B,11110001B ;  z37,dd,ds,dt
	dw	z37a,0
	DB	00000000b,00010000B,00000011B,11110001B ;  z37x,dd,ds,dt
	dw	z37b,0
	DB	00000001b,00000000B,00000010B,10010000B ;  z100,dd,ss,st
	dw	z100a,0
	DB	00000001b,00000000B,00000010B,11010001B ;  z100,dd,ds,st
	dw	z100b,0
	DB	00000001b,00000000B,00000010B,10110000B ;  z100,dd,ss,dt
	dw	z100c,0
	DB	00000001b,00000000B,00000010B,11110001B ;  z100,dd,ds,dt
	dw	z100d,0
	DB	11111111B	;FLAG FOR END OF TABLE

	$*MACRO 

STD8:	calcdpb 26, 8,243, 64,2,128

M471:	calcdpb 64,16,300,192,2,1024

M472:	calcdpb 64,16,608,192,2,1024

MMS5:	calcdpb 64,16,300,192,2,512

MMS6:	calcdpb 64,16,608,192,2,512

Z471:	calcdpb 26,16,247,128,2,128

Z472:	calcdpb 52,16,243,128,2,256,@

Z473:	calcdpb 52,16,494,256,2,256

Z474:	calcdpb 64,16,300,128,2,1024

Z475:	calcdpb 64,16,608,256,2,1024

Z170:	calcdpb 20, 8, 92, 64,3,256

Z171:	calcdpb 20, 8,182, 64,3,256

Z172:	calcdpb 20,16, 96, 64,3,256

Z173:	calcdpb 20,16,186, 64,3,256

MMS0:	calcdpb 36,16, 83, 96,3,512

MMS1:	calcdpb 36,16,173, 96,3,512

MMS2:	calcdpb 36,32, 86,128,3,512

MMS3:	calcdpb 36,32,176,128,3,512

Z370:	calcdpb 20, 8, 92, 64,3,256

Z371:	calcdpb 32, 8,152,128,2,256

Z372:	calcdpb 40, 8,186,128,2,1024

Z373:	calcdpb 20, 8,188,128,3,256

Z374:	calcdpb 32,16,156,256,2,256,@

Z375:	calcdpb 40,16,195,256,2,1024,@

Z376:	calcdpb 20, 8,192, 64,3,256

Z377:	calcdpb 32,16,156,128,2,256

Z378:	calcdpb 40,16,195,128,2,1024

Z379:	calcdpb 20,16,196,128,3,256

Z37A:	calcdpb 32,16,316,256,2,256

Z37B:	calcdpb 40,16,395,256,2,1024

Z100a:	calcdpb 32, 8,152,128,2,512	;; 5" disks

Z100b:	calcdpb 32,16,156,256,2,512,@

Z100c:	calcdpb 32,16,156,128,2,512

Z100d:	calcdpb 32,16,316,256,2,512

;
; NOTE: skew tables are for physical sector numbers.
;

STDX:	DB	1,7,13,19,25,5,11,17,23,3,9,15,21    ;3740 format
	DB	2,8,14,20,26,6,12,18,24,4,10,16,22   ; (26-128 byte)

Z47X:	DB	1,10,19,2,11,20,3,12,21,4,13,22,5    ;Z47/Z67 format
	DB	14,23,6,15,24,7,16,25,8,17,26,9,18   ; (26-256 byte)

Z47XX:	DB	1,5,2,6,3,7,4,8 		     ;Z47X/M47 format
						     ; (8-1024 byte)

Z17X:	db	1,5,9,3,7,2,6,10,4,8		     ;Z17 format

	end
,5,2,6,3,7,4,8 		     ;Z4