VERS EQU '2 ' ; 11/2/83 14:06 mjm "M320'3.ASM"
*************************************************************************

	TITLE	'SASI- DRIVER FOR MMS CP/M 3 SASI BUS INTERFACE'
	; Configurable portion - DEFSASI3 also generates equivalent
	$*MACRO

	extrn	@dph,@rdrv,@side,@trk,@sect,@dma,@dbnk,@dstat,@intby
	extrn	@dtacb,@dircb,@scrbf,@rcnfg,@cmode,@lptbl,@login
	extrn	?bnksl

	public	SDRV0,SCNUM,SMODTB,SDPB,SDPHTB
	extrn	STHRD,SINIT,SLOGIN,SREAD,SWRIT,SSTRNG

**************************************************************************
; Configure the number of partitions (numparX) on each LUN in your system
;  and if the LUN is removable (true) or not (false).
**************************************************************************

false	equ	0
true	equ	not false
 
; Logical Unit 0 characteristics

numpar0 equ	8		; number of partitions on LUN
remov0	equ	false		; LUN removable if TRUE

; Logical Unit 1 characteristics

numpar1 equ	0		; number of partitions on LUN
remov1	equ	false		; LUN removable if TRUE

; Logical Unit 2 characteristics

numpar2 equ	0		; number of partitions on LUN
remov2	equ	false		; LUN removable if TRUE

; Logical Unit 3 characteristics

numpar3 equ	0		; number of partitions on LUN
remov3	equ	false		; LUN removable if TRUE

ndev	equ	numpar0+numpar1+numpar2+numpar3
dev0	equ	50

dpbl	equ	17	; length of CP/M 3.0 dpb
alvl	equ	512	; size of allocation vector
csvl	equ	256	; size of check sum vector

*************************************************** 
	cseg

	dw	STHRD
SDRV0	db	dev0,ndev
	jmp	SINIT
	jmp	SLOGIN
	JMP	SREAD
	JMP	SWRIT
	dw	SSTRNG
	dw	SDPHTB,SMODTB

;SSTRNG: db	'77320 ',0,'SASI Interface '
;	db	0
;	db	'v3.10'
;	dw	VERS
;	db	'$'

; Mode byte table for SASI driver

SMODTB:
drv	set	0
	rept	numpar0
	if	remov0
	db	1001$0000b+drv,000$00000b,00000000b,00000000b
	else
	db	1000$0000b+drv,000$00000b,00000000b,00000000b
	endif
	db	11111111b,11111111b,11111111b,11111111b
drv	set	drv+1
	endm

drv	set	0
	rept	numpar1
	if	remov1
	db	1001$0000b+drv,001$00000b,00000000b,00000000b
	else
	db	1000$0000b+drv,001$00000b,00000000b,00000000b
	endif
	db	11111111b,11111111b,11111111b,11111111b
drv	set	drv+1
	endm

drv	set	0
	rept	numpar2
	if	remov2
	db	1001$0000b+drv,010$00000b,00000000b,00000000b
	else
	db	1000$0000b+drv,010$00000b,00000000b,00000000b
	endif
	db	11111111b,11111111b,11111111b,11111111b
drv	set	drv+1
	endm

drv	set	0
	rept	numpar3
	if	remov3
	db	1001$0000b+drv,011$00000b,00000000b,00000000b
	else
	db	1000$0000b+drv,011$00000b,00000000b,00000000b
	endif
	db	11111111b,11111111b,11111111b,11111111b
drv	set	drv+1
	endm

; Disk parameter tables

SDPB:
	rept	ndev
	ds	dpbl
	endm

	$-MACRO

	dseg
	$*MACRO

SCNUM:	DB	0

; Disk parameter headers for the SASI driver

ncsv	set	0
drv	set	0

SDPHTB:
	rept	numpar0
	dw	0,0,0,0,0,0,SDPB+(drv*dpbl)
	if	remov0
	dw	csv+(ncsv*csvl)
ncsv	set	ncsv+1
	else
	dw	0
	endif
	dw	alv+(drv*alvl),@dircb,@dtacb,0
	db	0
drv	set	drv+1
	endm

	rept	numpar1
	dw	0,0,0,0,0,0,SDPB+(drv*dpbl)
	if	remov1
	dw	csv+(ncsv*csvl)
ncsv	set	ncsv+1
	else
	dw	0
	endif
	dw	alv+(drv*alvl),@dircb,@dtacb,0
	db	0
drv	set	drv+1
	endm

	rept	numpar2
	dw	0,0,0,0,0,0,SDPB+(drv*dpbl)
	if	remov2
	dw	csv+(ncsv*csvl)
ncsv	set	ncsv+1
	else
	dw	0
	endif
	dw	alv+(drv*alvl),@dircb,@dtacb,0
	db	0
drv	set	drv+1
	endm

	rept	numpar3
	dw	0,0,0,0,0,0,SDPB+(drv*dpbl)
	if	remov3
	dw	csv+(ncsv*csvl)
ncsv	set	ncsv+1
	else
	dw	0
	endif
	dw	alv+(drv*alvl),@dircb,@dtacb,0
	db	0
drv	set	drv+1
	endm

; Allocation vectors

alv:
	rept	ndev
	ds	alvl
	endm

; Check sum vectors for removable media

csv:
	rept	ncsv
	ds	csvl
	endm

	$-MACRO

	END
