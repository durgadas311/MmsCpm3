	title	'MP/M II V2.0  Resident Portion of Banked BDOS'
	cseg
;***************************************************************
;***************************************************************
;**                                                           **
;**   B a s i c    D i s k   O p e r a t i n g   S y s t e m  **
;**                                                           **
;**  R e s i d e n t  P o r t i o n  -  B a n k e d  B D O S  **
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
;
	org	0000h
base	equ	$
;
;	XDOS jump table below BDOS origin
pdisp	equ	$-3
xdos	equ	pdisp-3

;	equates for non graphic characters
ctlc	equ	03h	;control c, abort
ctld	equ	04h	;control d, detach
ctle	equ	05h	;physical eol
ctlh	equ	08h	;backspace
ctlp	equ	10h	;prnt toggle
ctlq	equ	11h	;prnt owner toggle
ctlr	equ	12h	;repeat line
ctls	equ	13h	;stop/start screen
ctlu	equ	15h	;line delete
ctlx	equ	18h	;=ctl-u
ctlz	equ	1ah	;end of file
rubout	equ	7fh	;char delete
tab	equ	09h	;tab char
cr	equ	0dh	;carriage return
lf	equ	0ah	;line feed
ctl	equ	5eh	;up arrow
;
;	XDOS call equates
makeque		equ	134
readque		equ	137
writeque	equ	139
dispatch	equ	142
terminate	equ	143
setprior	equ	145
attach		equ	146
detach		equ	147
asgncns		equ	149
sendcli		equ	150
ATTLST		EQU	158
DETLST		EQU	159
;
;	Process Descriptor Offsets
pname		equ	6
console		equ	14
memseg		equ	15
disksetDMA	equ	20
diskselect	equ	22
searcha		equ	26
MULT$CNT	EQU	50
;
;	System Data Page Offsets
userstackflag	equ	3
brkvctr		equ	48
usrstkregion	equ	80
LISTCPADR	EQU	126
;
;	MP/M Data Page Offsets
rlros		equ	5
cnsatt		equ	20
msegtbl		equ	150
LSTATT		EQU	599
;
;*****
;
;	enter here from the user's program with function number
;	in c, and information address in d,e
	jmp	xbdos	;to xbdos handler
	jmp	bios	;to bios jump table base address
	JMP	SYINIT
	JMP	REMOVE$FILES
	JMP	SWITCH$USER
	JMP	SWITCH$ZERO
XREMOVE$FILES:
	JMP	$-$
;
;	bdos/xdos initialization code
syinit:
	;HL = sysdat page address
	shld sysdat
	mvi l,14! lxi b,bnkbdos+1
	mov a,m! mov d,a! stax b
 	xchg! mvi l,3
	shld bnkbdosinit
	MVI L,6! SHLD XREMOVE$FILES+1
	MVI L,9! LXI D,COMMON$DMA
	MOV M,E! INX H! MOV M,D! INX H
	XCHG! LHLD SYSDAT! XCHG
	MOV M,E! INX H! MOV M,D
	INX H! PUSH H
bnkbdosinit equ $+1
	call $-$	 ;initialize the banked bdos
	jmp syinitcontd

extjmptbl:
	jmp	extreboot
	jmp	rlr
	jmp	getrlradr
	jmp	dsplynm
	jmp	xprint
	jmp	xcrlf
	jmp	conoutx
	jmp	xgetmemseg
;
syinitcontd:
	lhld sysdat! mov c,h
	MVI L,LISTCPADR! LXI D,LISTCP ;PUT .LISTCP IN SYS DTA PG
	MOV M,E! INX H! MOV M,D
	mvi l,252! mov a,m! inx h! mov h,m
	mov l,a! lxi d,0005! dad d! shld rlradr
	lxi d,0091h! dad d! shld msegtadr
	mov h,c! mvi l,userstackflag
	mov a,m! sta usrstkflg
	dcr l! mov l,m! mvi h,0 ;HL = RST #
	mov c,l ;put RST # into C for use by SYSINITF
	dad h! dad h! dad h ;HL = breakpoint address
	mvi m,0C3h! inx h ;store jump to brkpt hndlr
	lxi d,brkpt ;DE = brkpt entry address
	mov m,e! inx h! mov m,d
	;initialize jmp at 0000H to fake BIOS jump table
	mvi a,0C3H! sta 0000H
	lxi h,drctjmptbl! shld 0001H
	;execute the XIOS SYSINIT function
	call syinitf
	ei ;in case it was not done in sysinit
	;create disk mutual exclusion queue
	mvi c,makeque! lxi d,diskcqcb! call xdos
	mvi c,writeque! lxi d,MXDisk! call xdos
	;create printer mutual exclusion queue
	mvi c,makeque! lxi d,listcqcb! call xdos
	;INHIBIT MXList EXCLUSION
	LXI H,0FFFFH! SHLD LISTNMSGS! SHLD LISTMSGCNT
	;get the directory buffer address
	mvi c,0! call seldskf
	lxi d,8! dad d! mov e,m! inx h! mov d,m
	JMP SYINITEXTRA
;
CoNm:
	db ' COPYRIGHT (C) 1981,'
	db ' DIGITAL RESEARCH '
Serial:
	db '654321'

lstack	equ	Serial+4

entsp	equ	lstack	;BDOS entry stack pointer

dtbl	equ	$
	org	((dtbl-base)+0ffh) and 0ff00h
; *** this table is page aligned
;	BIOS jump table for *.COM file support
	jmp bootf
drctjmptbl:
	jmp wbootf
	jmp bconst
	jmp bconin
	jmp bconout
	jmp blist
;
;  Support for direct BIOS console & list device I/O
;
SYINITEXTRA:
	xchg! shld dirbufa
	XCHG! POP H! MOV M,E! INX H! MOV M,D
	ret

bconst:	mvi e,0feh! mvi c,6! jmp xbdos

bconin:	mvi c,3! jmp xbdos

bconout:mov e,c! mvi c,4! jmp xbdos

blist:	mov e,c! mvi c,5! jmp xbdos

;	Disk and List data structures
diskcqcb:
	;disk mutual exclusion circular que ctl blk
	dw	$-$	;link
	db	'MXDisk  ' ;name
	dw	0	;message length
	dw	1	;number of messages
	dw	$-$	;dq process head
	dw	$-$	;nq process head
	dw	$-$	;msgin
	dw	$-$	;msgout
	dw	$-$	;msgcnt
	dw	$-$	;owner Process descriptor adr
MXDisk:
	;disk user queue control block
	dw	diskcqcb

listcqcb:
	;list mutual exclusion circular queue control block
	dw	$-$	;link
	db	'MXList  ' ;name
	dw	0	;message length
LISTNMSGS:
 	dw	0FFFFH	;number of messages
	dw	$-$	;dq process head
	dw	$-$	;nq process head
	dw	$-$	;msgin
	dw	$-$	;msgout
LISTMSGCNT:
	dw	0FFFFH	;msgcnt
	dw	listcqcb-4	;owner Process Descriptor adr

xbdos:	;arrive here from user programs
	mov a,c! ora c ; test function code
	jz reboot ;zero terminates calling process
	jp notXDOS ;jump if a BDOS call

	call XDOS ;func >= 128 is a XDOS call
	mov a,l ;XDOS returns address put low byte into A
	ret

badfunc:
	;invalid function code
	lxi h,0ffffh! mov a,l! ret

brkpt:	;debugger breakpoint entry
	di! shld svdhl! pop h! shld svdrt! push psw
	;set HL = RLR
	lhld rlradr! mov a,m! inx h! mov h,m! mov l,a
	mvi a,memseg! add l! mov l,a
	mvi a,0! adc h! mov h,a ;HL = .pd.memseg
	mov a,m! add a! adi brkvctr
	lhld sysdat! mov l,a ;HL = brkpt hndlr address
	mov a,m! inx h! mov h,m! mov l,a
	shld jmptobrk+1
	pop psw! lhld svdrt! push h! lhld svdhl
jmptobrk:
	jmp	$-$

restore:
	;restore user stack
	xchg! pop h! sphl! xchg ;get user stack pointer
	ret

tst$stk$swap:
	lda usrstkflg! ora a
	rz ; if flag set then change stack
	; get memory segment index
	lhld rlradr! mov a,m! inx h
	mov h,m! mov l,a
	mvi a,pname+2! add l! mov l,a
	mvi a,0! adc h! mov h,a
	mov a,m ; A = pd.name(2)
	ani 80h! jz tst$stk$swap1 ;no stk chg if name(2) "on"
	xra a! ret
tst$stk$swap1:
	mvi a,memseg-(pname+2)! add l! mov l,a
 	mvi a,0! adc h! mov h,a
	mov a,m ; A = memory segment index
	ora a! rz
	inr a! ret ;no stack change if system process call

notXDOS:
	call tst$stk$swap! jz BDOS
	dcr a! dcr a! add a! adi usrstkregion
	lhld sysdat! mov l,a
	mov a,d! mov b,e ;save DE in AB
	mov e,m! inx h! mov d,m
	lxi h,0! dad sp
	xchg! sphl! push d ;set & save user SP
	lxi h,restore! push h ; setup return address to restore stack
	mov d,a! mov e,b ;restore DE

BDOS:
	mov a,c! cpi diskf! jc cnsfunc ;jump if not disk i/o
	cpi 26! jnz BDOS2
	call rlr! mvi a,disksetDMA! add l! mov l,a
	mvi a,0! adc h! mov h,a
	inx d! mov a,e! ora d
	jz BDOS1
	dcx d
BDOS1:
	mov m,e! inx h! mov m,d
	ret
BDOS2:
	cpi ndf+1! jc OKdf ;func <= ndf
	cpi 100! jc badfunc ;ndf < func < 100
	cpi nxdf+1! jnc badfunc ;func > nxdf
    OKdf:
	cpi chainf! jz chain

	push d! push b ;save info & func

	CALL TSTLIVEKBD ;TST FOR PD.NAME(3)' OFF
	cz func11 ;simulate 'live console' with kbd status chk

	;if not suppressing abort then set ctlc flg off, in BDOS on
	call rlr! lxi d,(pname+7)! dad d
	mov a,m! ani 80h! jnz noinbdosflg
	dcx h! mov a,m! ani 7fh! mov m,a
	dcx h! dcx h! dcx h! dcx h! dcx h
	;DO NOT ALLOW ABORT WHEN IN BDOS
	MOV A,M! ORI 80H! MOV M,A
    noinbdosflg:
	;obtain entry by getting disk mutual exclusion message
	mvi c,readque! lxi d,MXDisk! call XDOS

	;setup & jump to banked bdos
	pop b! pop d ;restore info & func
	lxi h,0! dad sp! shld entsp
	lxi sp,lstack
	;perform the required buffer transfers from
	; the user in common memory
	mov a,c! cpi 17 ;search ?
	jnz skipsrch
	call rlr! push d! lxi d,searcha! dad d! pop d
	mov m,e! inx h! mov m,d
	jmp skipsrchnxt
    skipsrch:
	cpi 18 ;search next ?
	jnz skipsrchnxt
	call rlr! lxi d,searcha! dad d
	mov e,m! inx h! mov d,m
    skipsrchnxt:
	lxi h,dfctbl-12
	mov a,c! cpi 100! jc normalCPM
	lxi h,xdfctbl-100
    normalCPM:
	mvi b,0! dad b! mov a,m

;*****  SAVE DFTBL ITEM, INFO, & FUNCTION *****
 
	MOV B,A! PUSH B! PUSH D

	rar! jc cpydmain
	RAR! JC CPYCDMAIN
	rar! jc cpyfcbin
	jmp nocpyin
    CPYCDMAIN:
	LXI H,COMMON$DMA! PUSH H! MVI B,16! PUSH B
	JMP CPYDMAIN1
    cpydmain:
	LHLD DIRBUFA! PUSH H! MVI B,128! PUSH B
    CPYDMAIN1:
	CALL SET$DMABUFA
	XCHG! POP B! POP H
	call move
	pop d! push d
    cpyfcbin:
	lxi h,commonfcb! mvi b,36
	call move
	lxi d,commonfcb

    nocpyin:
	MOV A,C! MVI B,0! CPI 41! JZ SHELL
	PUSH D! CALL GET$MULT$CNT$ADD! POP D
	MOV A,M! DCR A! JZ BDOSE2
	LXI H,MULT$FXS! INR B
     BDOSE1:
	MOV A,M! ORA A! JZ BDOSE2
	CMP C! JZ SHELL
	INX H! JMP BDOSE1
     BDOSE2:

	CALL BANK$BDOS

     BDOSE3:
	POP D ;RESTORE FCB ADDRESS
	POP B! MOV A,B ;RESTORE DFCTBL BYTE & FUNCTION #
	ral! jc dmacpyout
	RAL! JC CDMACPYOUT
    COPYOUT:
	lxi h,commonfcb! xchg! mvi b,33
	ral! jc cpyoutcmn
	ral! jnc nocpyout
	MOV A,C! CPI 105! MVI B,4! JZ CPYOUTCMN
	CPI 107! MVI B,6! JZ CPYOUTCMN
	mvi b,36! CPI 15! JZ CPYOUT1
	CPI 22! JNZ CPYOUTCMN
    CPYOUT1:
	DCR B! PUSH H! LXI H,12! DAD D! MOV A,M! POP H
	ANI 80H! JNZ CPYOUTCMN
	MVI B,33! jmp cpyoutcmn

    CDMACPYOUT:
	PUSH D ;SAVE FCB ADDRESS FOR COPYOUT
	CALL SET$DMA$BUFA
        MVI B,3! CALL COPY$CDMA$OUT
 	POP D! JMP NOCPYOUT
    dmacpyout:
	lhld dirbufa! xchg! lhld dmabufa! mvi b,128
    cpyoutcmn:
	call move

    nocpyout:
	lhld entsp! sphl ;user stack restored
    RELEASE:
	lhld aret
	push h
	;release disk mutual exclusion message
	mvi c,writeque! lxi d,MXDisk! call XDOS

	;if in BDOS flag on, check for abt spc proc flg
	call rlr! lxi d,(pname+1)! dad d
	mov a,m! ani 7fh! cmp m! mov m,a
	jz funcdone
	inx h! inx h! inx h! inx h! inx h
	mov a,m! ani 7fh! cmp m! mov m,a
	CNZ REBOOT

    funcdone:
	;function done
	pop h! mov a,l! mov b,h ;BA = HL = aret
	ret

BANK$BDOS:
	push d! push b ;save info & func
	call getmemseg! sta usermemseg
	xra a ;set memseg to 0 (memseg #0 must be bank zero)
	call extbnkswt
	pop b! pop d

bnkbdos equ $+1
	call $-$

	shld aret
	call getmemseg! lda usermemseg
	jmp extbnkswt ;ret

COPY$CDMA$OUT: ;B = 2 | 3
	LHLD DMABUFA! LXI D,COMMON$DMA
	;FALLS THROUGH TO MOVE

move:
	;move data length of B from source DE to
	;destination HL
	inr b ;in case of length=0
	move0:
		dcr b! rz
		ldax d! mov m,a
		inx d! inx h
		jmp move0

MULT$FXS:	DB	20,21,33,34,40,0

;
getrlradr:
	lhld rlradr! ret

rlr:
	;set HL = contents of Ready List Root
	lhld rlradr! mov a,m! inx h! mov h,m! mov l,a
	ret
;
GET$MULT$CNT$ADD:
	CALL RLR! LXI D,MULT$CNT! DAD D! RET
;
xgetmemseg:
	lda usermemseg
	ret
;
getmemseg:
	;set A = memory segment #
	call rlr ;HL = Ready List Root
	mvi a,memseg! add l! mov l,a
	mvi a,0! adc h! mov h,a ;HL = .pd.memseg
	mov a,m! ret
;
REMOVE$FILES:
	CALL GETMEMSEG! PUSH A! XRA A
	PUSH B! CALL EXTBNKSWT! POP B
	CALL XREMOVE$FILES
	CALL GETMEMSEG! POP A! JMP EXTBNKSWT

;
;
;	intercept bios boot to switch banks

extreboot:
	call getmemseg! lda usermemseg
	call extbnkswt
	lxi h,0ffffh! shld aret
	LHLD ENTSP! SPHL ;RESTORE USER'S STACK
	CALL RELEASE ;RELEASE MXDisk
	LDA USERMEMSEG
	ORA A! RZ! INR A! RZ ;DON'T TERMINATE IF SYS PROCESS
xreboot:
	call tst$stk$swap! jz reboot
	lxi h,0! dad sp! lxi d,3fh! dad d
	mov a,l! ani 0c0h! mov l,a! dcx h
	mov d,m! dcx h! mov e,m! xchg! sphl
reboot:
	call rlr! lxi d,memseg! dad d
	mov a,m! ora a! rz
	inr a! rz
	dcx h! dcx h
	mov a,m! ani 80h! rnz
	;terminate the calling process
	mvi c,terminate! lxi d,0
	jmp xdos

SWITCH$USER:
	call getmemseg! lda usermemseg
	jmp extbnkswt

SWITCH$ZERO:
	call getmemseg! xra a
	;call extbnkswt
	;ret

extbnkswt:
	di
	mov m,a! inr a! jz extbnkswt1 ;return if system process
	dcr a! add a! add a! lhld msegtadr
	add l! mov c,a
	mvi a,0! adc h! mov b,a
	  call xiosms
extbnkswt1:
	ei
	ret

;
;	Local Data Segment
msegtadr: ds	2	;address of memory segment table
rlradr:	ds	2	;address of Ready List Root
sysdat:	ds	2	;address of system data page
usrstkflg: ds	1	;user stack flag, 0ffh=users stack
svdhl:	ds	2	;saved HL at breakpoint entry
svdrt:	ds	2	;saved return address at breakpoint entry
;
dirbufa: ds	2	;directory buffer address
dmabufa: ds	2	;dma buffer address
usermemseg: ds	1	;saved user mem seg index
aret:	ds	2	;address value to return

commonfcb:
	ds	36	;fcb copy in common memory
;
COMMON$DMA:
	DS	16	;LOCAL DMA FOR PASSWORDS, ETC.
;
;	Disk Function Copy Table
;
dmain	equ	00000001b	;dma copy on entry
CDMAIN	EQU	00000010B	;COPY 1ST 16 BYTES OF DMA TO
fcbin	equ	00000100b	;fcb copy on entry
				;COMMON$DMA ON ENTRY
dmaout	equ	10000000b	;dma copy on exit
CDMAOUT	EQU	01000000B	;COPY 1ST 2 | 3 BYTES OF COMMON$DMA
				;TO DMA ON EXIT
				;2 IF UNLOCKED OPEN
				;3 IF GET DISK FREE SPACE
fcbout	equ	00100000b	;fcb copy on exit
pfcbout	equ	00010000b	;random fcb copy on exit
dfctbl:
	db 0			; 12=return version #
	db 0			; 13=reset disk system
	db 0			; 14=select disk
	db fcbin+PFCBOUT+CDMAIN ; 15=open file
	db fcbin+fcbout		; 16=close file
	db fcbin+dmain+dmaout	; 17=search first
	db fcbin+dmain+dmaout	; 18=search next
	db fcbin+CDMAIN		; 19=delete file
	db fcbin+fcbout		; 20=read sequential
	db fcbin+fcbout		; 21=write sequential
	db fcbin+PFCBOUT+CDMAIN	; 22=make file
	db fcbin+CDMAIN		; 23=rename file
	db 0			; 24=return login vector
	db 0			; 25=return current disk
	db 0			; 26=set DMA address
	db 0			; 27=get alloc address
	db 0			; 28=write protect disk
	db 0			; 29=get R/O vector
	db fcbin+CDMAIN		; 30=set file attributes
	db 0			; 31=get disk param addr
	db 0			; 32=get/set user code
	db fcbin+fcbout		; 33=read random
	db fcbin+fcbout		; 34=write random
	db fcbin+pfcbout	; 35=compute file size
	db fcbin+pfcbout	; 36=set random record
	db 0			; 37=drive reset
	db 0			; 38=access drive
 	db 0			; 39=free drive
	db fcbin+fcbout		; 40=write random w/ zero fill

	db fcbin+fcbout		; 41=test & write record
	db fcbin+fcbout+CDMAIN	; 42=record lock
	db fcbin+fcbout+CDMAIN	; 43=record unlock
	db 0			; 44=set multi-sector count
	db 0			; 45=set BDOS error mode
	db CDMAOUT		; 46=get disk free space
	db fcbin		; 47=chain to program
	db 0			; 48=flush buffers
	db 0			; 49=CCP chain query (CP/M)
	db 0			; 50=direct BIOS call (CP/M)
ndf equ ($-dfctbl)+12

xdfctbl:
	db fcbin+CDMAIN		; 100=set directory label
	db 0     		; 101=return directory label data
	db fcbin+fcbout+CDMAIN	; 102=read file xfcb
	db fcbin+CDMAIN		; 103=write or update file xfcb
	db fcbin		; 104=set current date and time
	db fcbin+pfcbout	; 105=get current date and time
	db fcbin		; 106=set default password
	db fcbin+pfcbout	; 107=return serial number
nxdf equ ($-xdfctbl)+100

get$dma$add:
	call rlr! lxi d,disksetdma! dad d! ret

set$dmabufa:
	call get$dma$add
	mov e,m! inx h! mov d,m
	xchg! shld dmabufa! ret

shell:
	sta fx! call set$dmabufa
	shld shell$dma
	call get$mult$cnt$add
	mov a,m! sta shell$cnt
	lxi h,shell$rtn! push h! push b
	call save$rr! call save$dma
	pop psw! ora a! jz tst$wrt
	jmp mult$io ; HL = .DMA 
;
shell$cnt:	db	0
fx:		db	0
shell$rr:	db	0,0,0
;
hold$dma:	dw	0
shell$dma:	dw	0
;
cbdos:
	lda fx! mov c,a
cbdos1:
	lxi d,common$fcb! call bank$bdos! lda aret! ret
;
adv$dma:
	lhld shell$dma
	lxi d,80h! dad d! shld shell$dma
;
set$process$dma:
	push h
	call get$dma$add! pop d! mov m,e! inx h! mov m,d
	ret
 ;
save$dma:
	lhld shell$dma! shld hold$dma! ret
;
reset$dma:
	lhld hold$dma! jmp set$process$dma
;
shell$err:
	lhld aret
	lda shell$cnt! pop b! sub b
	add a! add a! add a! add a
	ora h! mov h,a! ret
;
shell$rtn:
	shld aret! lda fx! cpi 33! cnc reset$rr
	call reset$dma! jmp bdose3
;
incr$rr:
	call get$rra
	inr m! rnz
	inx h! inr m! rnz
	inx h! inr m! ret
;
save$rr:
	call save$rr2! xchg
save$rr1:
	mvi b,3! jmp move ;ret
save$rr2:
	call get$rra! lxi d,shell$rr! ret
;
reset$rr:
	call save$rr2! jmp save$rr1
;
tst$wrt:
	lhld dirbufa! xchg
	mvi c,26! call bank$bdos
	lda shell$cnt
tst$wrt1:
	push a! mvi c,33! call cbdos1
	ora a! jnz shell$err
	call compare$recs
	call incr$rr
	lxi d,80h! lhld shell$dma! dad d! shld shell$dma
	pop a! dcr a! jnz tst$wrt1
	call set$process$dma
	call reset$rr
	mvi a,34! sta fx ; jmp mult$io
;
mult$io:
	lda shell$cnt
mult$io1:
	push a! call cbdos
	ora a! jnz shell$err
	lda fx! cpi 33! cnc incr$rr
	call adv$dma
	pop a! dcr a! jnz mult$io1
	lxi h,0
	ret
;
compare$recs:
	lhld shell$dma! xchg! lhld dirbufa
	mvi c,128
	call compare! rz
	pop h! lxi h,0007! jmp shell$err
;
compare:
	ldax d! cmp m! rnz
	inx h! inx d! dcr c! rz
	jmp compare
;
get$rra:
	lxi h,common$fcb! lxi d,33! dad d! ret

;******************************************************
;**                                                  **
;**             C h a i n                            **
;**                                                  **
;******************************************************
;
chainf	equ	47

chain:
	call getmemseg! lhld rlradr
	lxi b,msegtbl-rlros! dad b
	add a! add a! mov e,a! mvi d,0! dad d
	mov h,m! mvi l,5ch
	push h! inx h! mvi c,8! lxi d,clipdname
	moveclipdname:
		ldax d! mov m,a! inx d! inx h
		dcr c! jnz moveclipdname
		mvi m,0
	;set no user sys stacks
	call rlr! lxi b,pname+2! dad b
	mov a,m! ori 80h! mov m,a
	lxi b,console-(pname+2)! dad b! mov a,m
	pop d! push d! stax d! mvi e,7dh! stax d
	lxi b,diskselect-console! dad b
	dcx d! mov a,m! stax d
	inx d! inx d! xra a! stax d! inx d
	call getmemseg! stax d;
	;assign the console to the cli
	mvi c,asgncns! pop d! push d! call xdos
	;raise process priority
	mvi c,setprior! mvi e,0! call xdos
	;send special form of send cli command
	mvi c,sendcli! pop d! mvi e,7ch! call xdos
	;terminate the calling process
	mvi c,terminate! lxi d,0ff00h! jmp xdos

clipdname:
	db 'cli     '

