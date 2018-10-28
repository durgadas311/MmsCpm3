; December 21, 1985  10:46  drm  "GETDP3KP.ASM"
	maclib Z80
;	$-MACRO
@	equ	-1
; CP/M 3.0 system routine to select a DPB and sector translation table
;  given the mode bytes (4)

****************************************************
* label:  calcdpb   spt,spb,bpd,dpd,nst,pss,exd[,flg]
*
*  spt = Sectors per Track
*  spb = Sectors per allocation Block
*  bpd = allocation Blocks per Disk (max (DS))
*  dpd = Directory entries per Disk
*  nst = Number of System Tracks
*  pss = Physical Sector Size (bytes)
*  exd = Extra Directory entries reserved
* [flg]= optional flag to intentionally produce incorrect EXM
*	 (used to maintain compatability with previous formats)
*
calcdpb macro ?spt0,?spb0,?dsm0,?drm0,?off0,?pss0,?exd0,?flg

?bsm	set	?spb0-1
?exm	set	?bsm shr 3
	if ?dsm0 gt 256
?exm	set	?exm shr 1
	endif

	if not NUL ?flg
?exm	set	?exm shr 1
	endif

?cks	set	?drm0/4
?exs	set	?exd0/4

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
	rept (?cks+?exs+?bsm)/?spb0
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
strtbl	db	'KAYPRO  '	;bit 0 - must be 8 characters wide
	db	'UNUSED  '	;bit 1
	db	'MMS     '	;    2
	db	'Z37     '	;    3
	db	'Z37X    '	;    4
	db	'Z100    '	;    5
	db	'EPSON   '	;    6
	db	'ASSOC   '	;    7
	db	'FMT8    '	;    8
	db	'FMT9    '	;    9
	db	'FMT10   '	;   10
	db	'FMT11   '	;   11
	db	'FMT12   '	;   12
	db	'FMT13   '	;   13
	db	'FMT14   '	;   14

;
;----------------------------------------------------------------------
;
;
;----------------------------------------------------------------------
;
; 
SRM0:	equ	10000001B	      ;
SRM1:	equ		  01110000B   ;SEARCH MODES MASKS

XSM0:	equ	00000000B	      ;
XSM1:	equ		  10001111B   ;EXCESS MODES MASKS

PTRTBL:
	DB	00000000b,00000100B,00000000B,00010001B ; 5" mms,dd,ss,st
	dw	mms0,0
	DB	00000000b,00000100B,00000000B,01010001B ; 5" mms,dd,ds,st
	dw	mms1,0
	DB	00000000b,00000100B,00000000B,00110001B ; 5" mms,dd,ss,dt
	dw	mms2,0
	DB	00000000b,00000100B,00000000B,01110001B ; 5" mms,dd,ds,dt
	dw	mms3,0
	DB	00000000b,00001000B,00000000B,10000001B ;  z37,sd,ss,st
	dw	z370,0
	DB	00000000b,00001000B,00000000B,10010001B ;  z37,dd,ss,st
	dw	z371,0
	DB	00000000b,00010000B,00000000B,10010001B ;  z37x,dd,ss,st
	dw	z372,0
	DB	00000000b,00001000B,00000000B,11000011B ;  z37,sd,ds,st
	dw	z373,0
	DB	00000000b,00001000B,00000000B,11010011B ;  z37,dd,ds,st
	dw	z374,0
	DB	00000000b,00010000B,00000000B,11010011B ;  z37x,dd,ds,st
	dw	z375,0
	DB	00000000b,00001000B,00000000B,10100001B ;  z37,sd,ss,dt
	dw	z376,0
	DB	00000000b,00001000B,00000000B,10110001B ;  z37,dd,ss,dt
	dw	z377,0
	DB	00000000b,00010000B,00000000B,10110001B ;  z37x,dd,ss,dt
	dw	z378,0
	DB	00000000b,00001000B,00000000B,11100011B ;  z37,sd,ds,dt
	dw	z379,0
	DB	00000000b,00001000B,00000000B,11110011B ;  z37,dd,ds,dt
	dw	z37a,0
	DB	00000000b,00010000B,00000000B,11110011B ;  z37x,dd,ds,dt
	dw	z37b,0
	DB	00000000b,00100000B,00000000B,10010001B ;  z100,dd,ss,st
	dw	z100a,0
	DB	00000000b,00100000B,00000000B,11010011B ;  z100,dd,ds,st
	dw	z100b,0
	DB	00000000b,00100000B,00000000B,10110001B ;  z100,dd,ss,dt
	dw	z100c,0
	DB	00000000b,00100000B,00000000B,11110011B ;  z100,dd,ds,dt
	dw	z100d,0
	DB	00000000b,01000000B,00000000B,01010101B ; 5" EPSON,dd,ds,st
	dw	epson,0
	DB	00000000b,10000000B,00000000B,01010111B ; 5" GNAT,dd,ds,st
	dw	gnat,0
	DB	00000000b,00000001B,00000000B,00011000B ; 5" KAYPRO  dd,ss,st
	dw	kaypro0,0
	DB	00000000b,00000001B,00000000B,01011000B ; 5" KAYPRO  dd,ds,st
	dw	kaypro1,0
	DB	00000000b,00000001b,00000001b,01110011b ; 5" KAYPRO qd,ds,qt
	dw	kaypro3,kpqtx
	DB	11111111B	;FLAG FOR END OF TABLE

	$*MACRO 

	dseg	;DPBs and SECTRN tables in banked mem

MMS0:	calcdpb 36,16, 83, 96,3,512,0

MMS1:	calcdpb 36,16,173, 96,3,512,0

MMS2:	calcdpb 36,32, 86,128,3,512,0

MMS3:	calcdpb 36,32,176,128,3,512,0

Z370:	calcdpb 20, 8, 92, 64,3,256,0

Z371:	calcdpb 32, 8,152,128,2,256,0

Z372:	calcdpb 40, 8,186,128,2,1024,0

Z373:	calcdpb 20, 8,188,128,3,256,0

Z374:	calcdpb 32,16,156,256,2,256,0,@

Z375:	calcdpb 40,16,195,256,2,1024,0,@

Z376:	calcdpb 20, 8,192, 64,3,256,0

Z377:	calcdpb 32,16,156,128,2,256,0

Z378:	calcdpb 40,16,195,128,2,1024,0

Z379:	calcdpb 20,16,196,128,3,256,0

Z37A:	calcdpb 32,16,316,256,2,256,0

Z37B:	calcdpb 40,16,395,256,2,1024,0

Z100a:	calcdpb 32, 8,152,128,2,512,0	;; 5" disks

Z100b:	calcdpb 32,16,156,256,2,512,0,@

Z100c:	calcdpb 32,16,156,128,2,512,0

Z100d:	calcdpb 32,16,316,256,2,512,0

epson:	calcdpb 80,16,190,128,2,512,0

gnat:	calcdpb 80,16,169,128,1,512,0,@

kaypro0: calcdpb 40,8,195,64,1,512,64

kaypro1: calcdpb 40,16,197,64,1,512,64

;drop support for expanded-directory format - risky anyway.
;kaypro2: calcdpb 40,16,197,128,1,512,0

kaypro3: calcdpb 68,16,1351,1024,2,512,0
;
; NOTE: skew tables are for physical sector numbers.
;
kpqtx:	db	1,6,11,16,4,9,14,2,7,12,17,5,10,15,3,8,13

	end
