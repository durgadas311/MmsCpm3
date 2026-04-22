	title	'Non-Resident Portion of Banked BDOS'
	cseg

;***************************************************************
;***************************************************************
;**                                                           **
;**   B a s i c    D i s k   O p e r a t i n g   S y s t e m  **
;**                                                           **
;**         N o n - R e s i d e n t   P o r t i o n           **
;**                B a n k e d   B D O S                      **
;**                                                           **
;***************************************************************
;***************************************************************

;/*
;  Copyright (C) 1978,1979,1980,1981
;  Digital Research
;  P.O. Box 579
;  Pacific Grove, CA 93950
;
;  Revised:
;    14 Sept 81 by David K. Brown
;*/

on	equ	0ffffh
off	equ	00000h

MPM	EQU	ON
MPMENV	EQU	ON
BNKBDOS	EQU	ON

ctlc	equ	03h	;control-c
cr	equ	0dh	;carriage return
lf	equ	0ah	;line feed
;
;	BDOS call equates
dskinit		equ	13
dskslct		equ	14
dsksetDMA	equ	26
setusercode	equ	32
;
;	Process Descriptor Offsets
pname		equ	6
console		equ	14
memseg		equ	15
thread		equ	18
disksetDMA	equ	20
diskselect	equ	22
diskparams	equ	23
MULT$CNT$OFF	EQU	50
PD$CNT$OFF	EQU	51
;
;	System Data Page Offsets
userstackflag	equ	3
brkvctr		equ	48
usrstkregion	equ	80
;
;
;	MP/M Data Page Offsets
rlros		equ	5
thrdrt		equ	17
msegtbl		equ	150
;
;**************************************************
;*                                                *
;**************************************************
;
	org	0000h
base	equ	$

	jmp	bnkbdose
	JMP	BNKBDOSINIT
	JMP	REMOVE$FILES
XDMAAD:	DW	$-$
SYSDAT:	DW	$-$
BUFFA:	DW	$-$

bnkbdosinit:
	pop h! push h! inx h! inx h! inx h
	lxi d,extjmptbl! mvi c,24! xchg
	CALL MOVE

	;INITIALIZE OPEN FILE AND LOCKED RECORD LIST
	
	LHLD SYSDAT! MVI L,187
	MOV A,M! STA LOCK$MAX! INX H
	MOV A,M! STA OPEN$MAX
	INX H! MOV E,M! INX H! MOV D,M! INX H
	PUSH D
	MOV E,M! INX H! MOV D,M! XCHG! SHLD FREE$ROOT
	POP D! DCX D! LXI B,10
ILIST:
	PUSH D
	MOV D,H! MOV E,L! DAD B! XCHG
	MOV M,E! INX H! MOV M,D! XCHG
	POP D! DCX D! MOV A,D! ORA E! JNZ ILIST
	MOV M,A! DCX H! MOV M,A! RET

extjmptbl:

reboot:	jmp	$-$
rlr:	jmp	$-$
rlradr:	jmp	$-$
dsplynm: jmp	$-$
xprint:	jmp	$-$
xcrlf:	jmp	$-$
conoutx: jmp	$-$
getmemseg: jmp	$-$
;
;************************************************
;*                                              *
;************************************************
;

bnkbdose:

	push d! push b

	LXI H,DELETED$FILES
	DI
	MOV A,M! ORA A! MVI M,0
	EI
	CNZ DELETE$FILES

	;perform the necessary BDOS parameter initialization
	;disk set DMA
	call rlr! SHLD PDADDR
	lxi b,disksetDMA! dad b
	mov e,m! inx h! mov d,m! push h! xchg! shld dmaad
	mov b,h! mov c,l! call setdmaf

	;disk select
	pop h! inx h
	mov a,m! rrc! rrc! rrc! rrc! ani 0fh! STA SELDSK

	;set user code
	mov a,m! ani 0fh! STA USRCODE

	;copy local disk params
	inx h! push h! lxi d,dcnt
	XCHG! MVI C,2! CALL MOVE
	LXI H,SEARCHL! LDAX D! MOV M,A
	LXI H,MULT$CNT$OFF-DISKPARAMS-2! DAD D
	MOV A,M! STA MULT$CNT
	INX H! MOV A,M! ANI 0F0H! CMP M! JZ BNKBDOS1
	ADI 10H! MOV M,A
BNKBDOS1:
	STA PDCNT

	;perform requested BDOS function
	pop h! pop b! pop d! push h
	call bdose

	;save results
	pop d! push h ; save results in HL

	;copy disk params
	lxi h,dcnt
	XCHG! MVI C,2! CALL MOVE
	LXI D,SEARCHL! LDAX D! MOV M,A

	;return to non-banked bdos, will restore calling bank
	; and release disk mutual exclusion message
	pop h! ret


bdose:
	xchg! shld info! xchg ;save parameter
	mov a,e! sta linfo ;linfo = low(info) - don't equ
	lxi h,0! shld aret ;return value defaults to 0000
	SHLD RESEL ; RESEL,FCBDSK = 0
	SHLD COMP$FCB$CKS ; COMP$FCB$CKS,SEARCH$USER0 = 0
	SHLD MAKE$XFCB ; MAKE$XFCB,FIND$XFCB = 0
	DAD SP! SHLD ENTSP ; SAVE STACK POSITION
	lxi h,goback! push h ;fake return address

	;compute disk function code address
	mov a,c! STA FX! mov c,e! mov b,d
	CPI NFUNCS+12! JNC HIGH$FXS
	LXI H,DISKF-24! JMP BDOS$JMP
HIGH$FXS:
	LXI H,XDISKF-200
BDOS$JMP:
	mov e,a! mvi d,0 ;DE=func, HL=.diskf-24
	dad d! dad d! mov e,m! inx h! mov d,m ;DE=functab(func)
	LHLD INFO	;INFO IN DE FOR LATER EXCHANGE
	xchg! pchl ;dispatched
;
;	dispatch table for disk functions
diskf:
	dw	func12,func13,func14,func15
	dw	func16,func17,func18,func19
	dw	func20,func21,func22,func23
	dw	func24,func25,func26,func27
	dw	func28,func29,func30,func31
	dw	func32,func33,func34,func35
	dw	func36,func37,func38,func39
	DW	FUNC40,FUNC41,FUNC42,FUNC43
	DW	FUNC44,FUNC45,FUNC46,FUNC47
	DW	FUNC48,FUNC49,FUNC50
nfuncs	equ	($-diskf)/2
XDISKF:
	DW	FUNC100,FUNC101,FUNC102,FUNC103
	DW	FUNC104,FUNC105,FUNC106,FUNC107

PERERR:	DW	PERSUB		;PERMANENT ERROR SUBROUTINE
RODERR:	DW	RODSUB		;RO DISK ERROR SUBROUTINE
ROFERR:	DW	ROFSUB		;RO FILE ERROR SUBROUTINE
SELERR:	DW	SELSUB		;SELECT ERROR SUBROUTINE

;
;	error subroutines
PERSUB:
	;report permanent error
	lxi h,permsg! jmp report$err ;to report the error
;
SELSUB:
	;report select error
	lxi h,selmsg! jmp report$err ;wait console before boot
;
RODSUB:
	;report write to read/only disk
	lxi h,rodmsg! jmp report$err ;wait console
;
ROFSUB:
	;report read/only file
	lxi h,rofmsg ;drop through to wait for console
;
report$err:
	;report error to console, message address in HL
	push h ;stack msg address
	;set D=console #
	call rlr! lxi d,console! dad d! mov d,m
	call xcrlf ;new line
	LDA SELDSK! adi 'A'! sta dskerr ;current disk name
	lxi b,dskmsg! call xprint ;the error message
	pop b! call xprint ;error mssage tail

	lda fx! mvi b,30h
	lxi h,pr$fx1
	cpi 100! jc rpt$err1
	mvi m,31h! inx h! sui 100
rpt$err1:
	sui 10! jc rpt$err2
	inr b! jmp rpt$err1
rpt$err2:
	mov m,b! inx h! adi 3ah! mov m,a
	inx h! mvi m,20h
	lxi h,pr$fcb! mvi m,0
	lda resel! ora a! jz rpt$err3
	mvi m,20h! push d
	lhld info! inx h! xchg! lxi h,pr$fcb1
	mvi c,8! call move! mvi m,'.'! inx h
	mvi c,3! call move! pop d
rpt$err3:
	call xcrlf
	lxi b,pr$fx! call xprint

	CALL GET$MEM$SEG
	ORA A! JZ RTN$PHY$ERRS
	INR A! JZ RTN$PHY$ERRS
	LXI D,PNAME+5! CALL TEST$ERROR$MODE1! JNZ RTN$PHY$ERRS
	jmp reboot ;terminate process
	;ret

xerr$list:
	dw	xe3,xe4,xe5,xe6,xe7,xe8,xe9,xe10,xe11

xe3:	db	'File Opened in Read/Only Mode',0
xe4:	db	0
xe5:	db	'File Currently Open',0
xe6:	db	'Close Checksum Error',0
xe7:	db	'Password Error',0
xe8:	db	'File Already Exists',0
xe9:	db	'Illegal ? in FCB',0
xe10:	db	'Open File Limit Exceeded',0
xe11:	db	'No Room in System Lock List',0

pr$fx: 	db	'Bdos Function: '
pr$fx1:	db	'   '
pr$fcb:	db	'  File: '
pr$fcb1:ds	12
	db	0
 
fx:	ds	1


