;
;*****************************************************************
;*****************************************************************
;
;	error messages
IF MPM
dskmsg:	db	'Bdos Err On '
dskerr:	db	' : ',0	
permsg:	db	'Bad Sector',0
selmsg:	db	'Select',0
rofmsg:	db	'File '
rodmsg:	db	'R/O',0
ELSE
dskmsg:	db	'Bdos Err On '
dskerr:	db	' : $'	;filled in by errflg
permsg:	db	'Bad Sector$'
selmsg:	db	'Select$'
rofmsg:	db	'File '
rodmsg:	db	'R/O$'
XERROR:	DB	'X/Err '
XERR$ID:DB	' $'
ENDIF
;
IF BNKBDOS
setlret1:
	mvi a,1
sta$ret:
	sta	aret
func$ret:
	ret
entsp:	ds	2
ENDIF
;
;*****************************************************************
;*****************************************************************
;
;	common values shared between bdosi and bdos
usrcode:db	0	;current user number
info:	ds	2	;information address
aret:	ds	2	;address value to return
lret	equ	aret	;low(aret)
;
;*****************************************************************
;*****************************************************************
;**                                                             **
;**   B a s i c    D i s k   O p e r a t i n g   S y s t e m    **
;**                                                             **
*****************************************************************
;*****************************************************************
;
dvers	equ	30h	;version 3.0
;	module addresses
;
;	literal constants
true	equ	0ffh	;constant true
false	equ	000h	;constant false
enddir	equ	0ffffh	;end of directory
byte	equ	1	;number of bytes for "byte" type
word	equ	2	;number of bytes for "word" type
;
;	fixed addresses in low memory
tfcb	equ	005ch	;default fcb location
tbuff	equ	0080h	;default buffer location
;
;	fixed addresses referenced in bios module are
;	pererr (0009), selerr (000c), roderr (000f)
;
;	error message handlers
;
;
rod$error:						;
	;report read/only disk error
	MVI B,2
 	JMP GOERR				;
;
rof$error:						;
	;report read/only file error			;
	MVI B,3
 	JMP GOERR	
;
sel$error:
	;report select error
	MVI B,4
;
goerr:
	;HL = .errorhandler, call subroutine
	MOV H,B! MVI L,0FFH! SHLD ARET
IF MPM
	call test$error$mode! jnz rtn$phy$errs
ELSE
	LDA ERROR$MODE! ORA A! JNZ RTN$PHY$ERRS
ENDIF
	MOV A,B! LXI H,PERERR-2! JMP BDOS$JMP
;
RTN$PHY$ERRS:
;
IF MPM
	lda lock$shell! ora a! jnz lock$perr
ENDIF
	LDA RETURN$FFFF! ORA A! JNZ GOBACK0
	JMP GOBACK
;
IF MPM
test$error$mode:
	lxi d,pname+4
test$error$mode1:
	call rlr! dad d
	mov a,m! ani 80h! ret
ENDIF
;
BDE$E$BDE$M$HL:
	MOV A,E! SUB L! MOV E,A ;
	MOV A,D! SBB H! MOV D,A ;
	RNC! DCR B! RET
;
BDE$E$BDE$P$HL:
	MOV A,E! ADD L! MOV E,A ;
	MOV A,D! ADC H! MOV D,A ;
	RNC! INR B! RET
;
SHL3BV:
	INR C
SHL3BV1:
	DCR C! RZ
	DAD H! ADC A! JMP SHL3BV1
;
;*********************************************
;	routines used by shell and lock/unlock
;*********************************************
incr$rr:
	call get$rra
	inr m! rnz
	inx h! inr m! rnz
	inx h! inr m! ret
;
save$rr:
	call save$rr2! xchg
save$rr1:
	mvi c,3! jmp move ;ret
save$rr2:
	call get$rra! lxi d,save$ranr! ret
;
reset$rr:
	call save$rr2! jmp save$rr1 ;ret
;
compare:
	ldax d! cmp m! rnz
	inx h! inx d! dcr c! rz
	jmp compare
;****************************************************
;
;
;	local subroutines for bios interface
;
move:
	;move data length of length C from source DE to
	;destination given by HL
	inr c ;in case it is zero
	move0:
		dcr c! rz ;more to move
		ldax d! mov m,a ;one byte moved
		inx d! inx h ;to next byte
		jmp move0
;
selectdisk:
	;select the disk drive given by curdsk, and fill
	;the base addresses curtrka - alloca, then fill
	;the values of the disk parameter block
	MVI A,0FFH! STA CURDSK ; IN CASE SELECT FAILS
	LDA SELDSK! mov c,a ;current disk# to c
	;lsb of e = 0 if not yet logged - in
	call seldskf ;HL filled by call
	;HL = 0000 if error, otherwise disk headers
	mov a,h! ora l! rz ;return with 0000 in HL and z flag
		;disk header block address in hl
		mov e,m! inx h! mov d,m! inx h ;DE=.tran
		shld cdrmaxa! inx h! inx h ;.cdrmax
		shld curtrka! inx h! inx h ;HL=.currec
		shld curreca! inx h! inx h ;HL=.buffa
		INX H! SHLD DRVLBLA! INX H
		;DE still contains .tran
		xchg! shld tranv ;.tran vector
		LXI H,DPBADDR ;DE= source for move, HL=dest
		mvi c,addlist! call move ;addlist filled
		;now fill the disk parameter block
		lhld dpbaddr! xchg ;DE is source
		lxi h,sectpt ;HL is destination
		mvi c,dpblist! call move ;data filled
		;now set single/double map mode
		lhld maxall ;largest allocation number
		mov a,h ;00 indicates < 255
		lxi h,single! mvi m,true ;assume a=00
		ora a! jz retselect
		;high order of maxall not zero, use double dm
		mvi m,false
	retselect:
	LDA SELDSK! STA CURDSK
IF NOT MPM
	LHLD BUFFA! MOV A,H! ORA L! RNZ
	LHLD DRVLBLA! MOV D,M! DCX H! MOV E,M
	XCHG! SHLD BUFFA
ENDIF
	INR A! RET ;select disk function ok
;
home:
	;move to home position, then offset to start of dir
	call homef ;move to track 00, sector 00 reference
	;lxi h,offset ;mov c,m ;inx h ;mov b,m ;call settrkf	;
	;first directory position selected
	xra a ;constant zero to accumulator
	lhld curtrka! mov m,a! inx h! mov m,a ;curtrk=0000
	lhld curreca! mov m,a! inx h! mov m,a ;currec=0000
	INX H! MOV M,A ;CURREC HIGH BYTE=00
	LXI H,0! SHLD DBLK ; DBLK = 0000
	;curtrk, currec both set to 0000
	ret
;
PASS$ARECORD:
	LXI H,ARECORD
	MOV E,M! INX H! MOV D,M! INX H! MOV B,M
	RET
;
rdbuff:
	;read buffer and check condition
	CALL PASS$ARECORD
	call readf ;current drive, track, sector, dma
	jmp diocomp	;check for i/o errors
;
wrbuff:
	;write buffer and check condition
	;write type (wrtype) is in register C
	;wrtype = 0 => normal write operation
	;wrtype = 1 => directory write operation
	;wrtype = 2 => start of new block
	CALL PASS$ARECORD
IF MPM
	lda rem$drv! ora c! mov c,a
ENDIF
	call writef ;current drive, track, sector, dma
diocomp:	;check for disk errors
	ora a! rz			;
	MOV B,A
	CPI 3! JC GOERR
	MVI B,1! JMP GOERR
;
seekdir:
	;seek the record containing the current dir entry
;
	LXI D,0FFFFH ; MASK = FFFF
	LHLD DBLK! MOV A,H! ORA L! JZ SEEKDIR1
	LDA BLKMSK! MOV E,A! XRA A! MOV D,A ; MASK = BLKMSK
	LDA BLKSHF! MOV C,A! XRA A ;
	CALL SHL3BV ; AHL = SHL(DBLK,BLKSHF)
SEEKDIR1:
	PUSH H! PUSH A ; SAVE AHL
;
	lhld dcnt ;directory counter to HL
	mvi c,dskshf! call hlrotr ;value to HL
;
;	ARECORD = SHL(DBLK,BLKSHF) + SHR(DCNT,DSKSHF) & MASK
;
	MOV A,L! ANA E! MOV L,A ; DCNT = DCNT & MASK
	MOV A,H! ANA D! MOV H,A
	POP B! POP D! CALL BDE$E$BDE$P$HL ;
	LXI H,ARECORD! MOV M,E! INX H! MOV M,D! INX H! MOV M,B
;
	;  jmp seek				;
	;ret
;
;
seek:
	;seek the track given by arecord (actual record)
;
	LHLD CURTRKA! MOV C,M! INX H! MOV B,M ; BC = CURTRK
	PUSH B ; S0 = CURTRK 
	LHLD CURRECA! MOV E,M! INX H! MOV D,M
	INX H! MOV B,M ; BDE = CURREC
	LHLD ARECORD! LDA ARECORD+2! MOV C,A ; CHL = ARECORD
SEEK0:
	MOV A,L! SUB E! MOV A,H! SBB D! MOV A,C! SBB B
	PUSH H ; SAVE LOW(ARECORD)
	JNC SEEK1 ; IF ARECORD >= CURREC THEN GO TO SEEK1
	LHLD SECTPT! CALL BDE$E$BDE$M$HL ; CURREC = CURREC - SECTPT
	POP H! XTHL! DCX H! XTHL ; CURTRK = CURTRK - 1
	JMP SEEK0
SEEK1:
	LHLD SECTPT! CALL BDE$E$BDE$P$HL ; CURREC = CURREC + SECTPT
	POP H ; RESTORE LOW(ARECORD)
	MOV A,L! SUB E! MOV A,H! SBB D! MOV A,C! SBB B
	JC SEEK2 ; IF ARECORD < CURREC THEN GO TO SEEK2
	XTHL! INX H! XTHL ; CURTRK = CURTRK + 1
	PUSH H ; SAVE LOW (ARECORD)
	JMP SEEK1
SEEK2:
	XTHL! PUSH H ; HL,S0 = CURTRK, S1 = LOW(ARECORD)
	LHLD SECTPT! CALL BDE$E$BDE$M$HL ; CURREC = CURREC - SECTPT
	POP H! PUSH D! PUSH B! PUSH H ; HL,S0 = CURTRK, 
	; S1 = HIGH(ARECORD,CURREC), S2 = LOW(CURREC), 
	; S3 = LOW(ARECORD)
	XCHG! LHLD OFFSET! DAD D! MOV B,H! MOV C,L
	CALL SETTRKF ; CALL BIOS SETTRK ROUTINE
	; STORE CURTRK
	POP D! LHLD CURTRKA! MOV M,E! INX H! MOV M,D
	; STORE CURREC
	POP B! POP D!
	LHLD CURRECA! MOV M,E! INX H! MOV M,D
	INX H! MOV M,B ; CURREC = BDE
	POP B ; BC = LOW(ARECORD), DE = LOW(CURREC)
	MOV A,C! SUB E! MOV C,A ; BC = BC - DE
	MOV A,B! SBB D! MOV B,A ;
;
	lhld tranv! xchg ;BC=sector#, DE=.tran
	call sectran ;HL = tran(sector)
	mov c,l! mov b,h ;BC = tran(sector)
	jmp setsecf ;sector selected
	;ret
;
;	file control block (fcb) constants
empty	equ	0e5h	;empty directory entry
lstrec	equ	127	;last record# on extent
recsiz	equ	128	;record size
fcblen	equ	32	;file control block size
dirrec	equ	recsiz/fcblen	;directory FCBS / record
dskshf	equ	2	;log2(dirrec)
dskmsk	equ	dirrec-1
fcbshf	equ	5	;log2(fcblen)
;
extnum	equ	12	;extent number field
maxext	equ	31	;largest extent number
ubytes	equ	13	;unfilled bytes field
modnum	equ	14	;data module number
;
MAXMOD	equ	64	;LARGEST MODULE NUMBER
;
fwfmsk	equ	80h	;file write flag is high order modnum
namlen	equ	15	;name length
reccnt	equ	15	;record count field
dskmap	equ	16	;disk map field
lstfcb	equ	fcblen-1
nxtrec	equ	fcblen
ranrec	equ	nxtrec+1;random record field (2 bytes)
;
;	reserved file indicators
rofile	equ	9	;high order of first type char
invis	equ	10	;invisible file in dir command
;
;	utility functions for file access
;
dm$position:
	;compute disk map position for vrecord to HL
	lxi h,blkshf! mov c,m ;shift count to C
	lda vrecord ;current virtual record to A
	dmpos0:
		ora a! rar! dcr c! jnz dmpos0
	;A = shr(vrecord,blkshf) = vrecord/2**(sect/block)
	mov b,a ;save it for later addition
	mvi a,8! sub m ;8-blkshf to accumulator
	mov c,a ;extent shift count in register c
	lda extval ;extent value ani extmsk
	dmpos1:
		;blkshf = 3,4,5,6,7, C=5,4,3,2,1
		;shift is 4,3,2,1,0
		dcr c! jz dmpos2
		ora a! ral! jmp dmpos1
	dmpos2:
	;arrive here with A = shl(ext and extmsk,7-blkshf)
	add b ;add the previous shr(vrecord,blkshf) value
	;A is one of the following values, depending upon alloc
	;bks blkshf
	;1k   3     v/8 + extval * 16
	;2k   4     v/16+ extval * 8
	;4k   5     v/32+ extval * 4
	;8k   6     v/64+ extval * 2
	;16k  7     v/128+extval * 1
	ret ;with dm$position in A
;
GETDMA:
	LHLD INFO! LXI D,DSKMAP! DAD D! RET
;
getdm:
	;return disk map value from position given by BC
	CALL GETDMA
	dad b ;index by a single byte value
	lda single ;single byte/map entry?
	ora a! jz getdmd ;get disk map single byte
		mov l,m! mvi h,0! ret ;with HL=00bb
	getdmd:
		dad b ;HL=.fcb(dm+i*2)
		;double precision value returned
		mov e,m! inx h! mov d,m! xchg! ret
;
index:
	;compute disk block number from current fcb
	call dm$position ;0...15 in register A
	mov c,a! mvi b,0! call getdm ;value to HL
	shld arecord! ret
;
allocated:
	;called following index to see if block allocated
	lhld arecord! mov a,l! ora h! ret
;
atran:
	;compute actual record address, assuming index called
;
;	ARECORD = SHL(ARECORD,BLKSHF)
;
	LDA BLKSHF! MOV C,A
	LHLD ARECORD! XRA A! CALL SHL3BV
	SHLD ARECORD! STA ARECORD+2 ; 
;
	SHLD ARECORD1 ; SAVE LOW(ARECORD)
;
;	ARECORD = ARECORD OR (VRECORD AND BLKMSK)
;
	LDA BLKMSK! MOV C,A! LDA VRECORD! ANA C
	LXI H,ARECORD! ORA M! MOV M,A! RET
;
GET$ATTS:
	;GET VOLATILE ATTRIBUTES STARTING AT F'5
	;INFO LOCATES FCB
	LHLD INFO
	LXI D,5! DAD D ; HL = .FCB(F'5)
	MVI E,0111$1111B! MVI C,4
GET$ATTS$LOOP:
	MOV A,M! PUSH A
	RAL! MOV A,D! ADC A! MOV D,A
	POP A! ANA E! MOV M,A
	INX H! DCR C! JNZ GET$ATTS$LOOP
	MOV A,D! ADD A! ADD A! ADD A! ADD A! RET
;
GET$S1:
	;GET CURRENT S1 FIELD TO A
	CALL GETEXTA! INX H! MOV A,M! RET ;
;
GET$RRA:
	;GET CURRENT RAN REC FIELD ADDRESS TO HL
	LHLD INFO! LXI D,RANREC! DAD D ;HL=.FCB(RANREC)
	RET
;
getexta:
	;get current extent field address to HL
	lhld info! lxi d,extnum! dad d ;HL=.fcb(extnum)
	ret
;
GETRCNTA:
	;GET RECCNT ADDRESS TO HL
	LHLD INFO! LXI D,RECCNT! DAD D! RET
;
getfcba:
	;compute reccnt and nxtrec addresses for get/setfcb
	CALL GETRCNTA! xchg ;DE=.fcb(reccnt)
	lxi h,(nxtrec-reccnt)! dad d ;HL=.fcb(nxtrec) 
	ret
;
getfcb:
	;set variables from currently addressed fcb
	call getfcba ;addresses in DE, HL
	mov a,m! sta vrecord ;vrecord=fcb(nxtrec)
	xchg! mov a,m! sta rcount ;rcount=fcb(reccnt)
	call getexta ;HL=.fcb(extnum)
	lda extmsk ;extent mask to a
	ana m ;fcb(extnum) and extmsk
	sta extval
	ret
;
setfcb:
	;place values back into current fcb
	call getfcba ;addresses to DE, HL
	lda seqio
	cpi 02! jnz setfcb1! xra a	;check ranfill	
setfcb1:
 	mov c,a ;=1 if sequential i/o
	lda vrecord! add c! mov m,a ;fcb(nxtrec)=vrecord+seqio
	xchg! lda rcount! mov m,a ;fcb(reccnt)=rcount
	ret
;
hlrotr:
	;hl rotate right by amount C
	inr c ;in case zero
	hlrotr0: dcr c! rz ;return when zero
		mov a,h! ora a! rar! mov h,a ;high byte
		mov a,l! rar! mov l,a ;low byte
		jmp hlrotr0
;
;
compute$cs:
	;compute checksum for current directory buffer
	mvi c,recsiz ;size of directory buffer
	lhld buffa ;current directory buffer
	xra a ;clear checksum value
	computecs0:
		add m! inx h! dcr c ;cs=cs+buff(recsiz-C)
		jnz computecs0
	ret ;with checksum in A
;
CHKSUM$FCB: ; COMPUTE CHECKSUM FOR FCB
	; ADD 1ST 12 BYTES OF FCB + CURDSK + 
	;     HIGH$EXT + XFCB$READ$ONLY + BBH
IF MPM
	lxi h,pdcnt! mov a,m
	inx h! add m ; Add high$ext
ELSE
	LXI H,HIGH$EXT! MOV A,M
ENDIF
	INX H! ADD M ; ADD XFCB$READ$ONLY
	INX H! ADD M ; ADD CURDSK
	ADI 0BBH ; ADD 0BBH TO BIAS CHECKSUM
	LHLD INFO! MVI C,12! CALL COMPUTECS0
	; SKIP EXTNUM
	INX H
	; ADD FCB(S1)
	ADD M! INX H
	; SKIP MODNUM
	INX H
	; SKIP FCB(RECCNT)
	; ADD DISK MAP
	INX H! MVI C,16! CALL COMPUTECS0
	ORA A! RET ; Z FLAG SET IF CHECKSUM VALID
;
SET$CHKSUM$FCB:
	CALL CHKSUM$FCB! RZ
	MOV B,A! CALL GETS1
	CMA! ADD B! CMA
	MOV M,A! RET
;
RESET$CHKSUM$FCB:
	XRA A! STA COMP$FCB$CKS
	CALL CHKSUM$FCB! RNZ
	CALL GET$S1! INR M! RET
;
CHEK$FCB:
	LDA HIGH$EXT
	; IF EXT & 0110$0000B = 0110$0000B THEN
	; SET FCB(0) TO 0 (USER 0)
	CPI 0110$0000B! JNZ CHEK$FCB1
	LHLD INFO! XRA A! MOV M,A ; FCB(0) = 0
CHEK$FCB1:
	JMP CHKSUM$FCB ;RET
;
CHECK$FCB:
IF MPM
	xra a! sta check$fcb4
check$fcb1:
ENDIF
	CALL CHEK$FCB! RZ
CHECK$FCB2:
;
IF MPM
	ani 0fh! jnz check$fcb3
	lda pdcnt! ora a! jz check$fcb3
	call set$sdcnt! sta dont$close
	call close1
	lxi h,lret! inr m! jz check$fcb3
	mvi m,0! call pack$sdcnt! mvi b,5
	call search$olist! rz
check$fcb3:
;
ENDIF
	POP H ; DISCARD RETURN ADDRESS
IF MPM
check$fcb4:
	nop
ENDIF
	MVI A,10! JMP STA$RET
;
SET$FCB$CKS$FLAG:
	MVI A,0FFH! STA COMP$FCB$CKS! RET
;
hlrotl:
 	;rotate the mask in HL by amount in C
 	inr c ;may be zero
 	hlrotl0: dcr c! rz ;return if zero
 		dad h! jmp hlrotl0
;
;
set$cdisk:
	;set a "1" value in curdsk position of BC
	LDA SELDSK
SET$CDISK1:
	push b ;save input parameter
	mov c,a ;ready parameter for shift
	lxi h,1 ;number to shift
	call hlrotl ;HL = mask to integrate
	pop b ;original mask
	mov a,c! ora l! mov l,a
	mov a,b! ora h! mov h,a ;HL = mask or rol(1,curdsk)
	ret
;
nowrite:
	;return true if dir checksum difference occurred
	lhld rodsk! 
;
TEST$VECTOR:
	LDA SELDSK
TEST$VECTOR1:
	mov c,a! call hlrotr
	mov a,l! ani 1b! ret ;non zero if curdsk bit on
;
set$ro:
	;set current disk to read only
	lxi h,rodsk! mov c,m! inx h! mov b,m
	call set$cdisk ;sets bit to 1
	shld rodsk
	;high water mark in directory goes to max
	lhld dirmax! inx h! xchg ;DE = directory max	
	lhld cdrmaxa ;HL = .cdrmax
	mov m,e! inx h! mov m,d ;cdrmax = dirmax
	ret
;
check$rodir:
	;check current directory element for read/only status
	call getdptra ;address of element
;
check$rofile:
	;check current buff(dptr) or fcb(0) for r/o status
	CALL RO$TEST
	rnc ;return if not set
	jmp rof$error ;exit to read only disk message
;
RO$TEST:
	LXI D,ROFILE! DAD D
	MOV A,M! RAL! RET ;CARRY SET IF R/O
;
;
check$write:
	;check for write protected disk
	call nowrite! rz ;ok to write if not rodsk
	jmp rod$error ;read only disk error
;
getdptra:
	;compute the address of a directory element at
	;positon dptr in the buffer
	lhld buffa! lda dptr			;
addh:
	;HL = HL + A
	add l! mov l,a! rnc
	;overflow to H
	inr h! ret
;
;
getmodnum:
	;compute the address of the module number 
	;bring module number to accumulator
	;(high order bit is fwf (file write flag)
	lhld info! lxi d,modnum! dad d ;HL=.fcb(modnum)
	mov a,m! ret ;A=fcb(modnum)
;
clrmodnum:
	;clear the module number field for user open/make
	call getmodnum! mvi m,0 ;fcb(modnum)=0
	ret
;
CLR$EXT:
	;FCB EXT = FCB EXT & 1FH
	CALL GETEXTA! MOV A,M! ANI 0001$1111B! MOV M,A!
	RET
;
setfwf:
	call getmodnum ;HL=.fcb(modnum), A=fcb(modnum)
	;set fwf (file write flag) to "1"
	ori fwfmsk! mov m,a ;fcb(modnum)=fcb(modnum) or 80h
	;also returns non zero in accumulator
	ret
;
;
compcdr:
	;return cy if cdrmax > dcnt
	lhld dcnt! xchg ;DE = directory counter
	lhld cdrmaxa ;HL=.cdrmax
	mov a,e! sub m ;low(dcnt) - low(cdrmax)
	inx h ;HL = .cdrmax+1
	mov a,d! sbb m ;hig(dcnt) - hig(cdrmax)
	;condition dcnt - cdrmax  produces cy if cdrmax>dcnt
	ret
;
setcdr:
	;if not (cdrmax > dcnt) then cdrmax = dcnt+1
	call compcdr
	rc ;return if cdrmax > dcnt
	;otherwise, HL = .cdrmax+1, DE = dcnt
	inx d! mov m,d! dcx h! mov m,e
	ret
;
subdh:
	;compute HL = DE - HL
	mov a,e! sub l! mov l,a! mov a,d! sbb h! mov h,a
	ret
;
newchecksum:
	mvi c,true ;drop through to compute new checksum
checksum:
	;compute current checksum record and update the
	;directory element if C=true, or check for = if not
	;drec < chksiz?
	LHLD ARECORD! xchg! lhld chksiz
	MOV A,H! ANI 7FH! MOV H,A ; MASK OFF PERMANENT DRIVE BIT
	call subdh ;DE-HL
	rnc ;skip checksum if past checksum vector size
		;drec < chksiz, so continue
		push b ;save init flag
		call compute$cs ;check sum value to A
		lhld checka ;address of check sum vector
		xchg
		LHLD ARECORD
		dad d ;HL = .check(drec)
		pop b ;recall true=0ffh or false=00 to C
		inr c ;0ffh produces zero flag
		jz initial$cs
IF MPM
		inr c! jz test$dir$cs
ENDIF
			;not initializing, compare
			cmp m ;compute$cs=check(drec)?
			rz ;no message if ok
			;checksum error, are we beyond
			;the end of the disk?
			call compcdr
			rnc ;no message if so
IF MPM
			call nowrite! cz flush$file0
ENDIF
			jmp set$ro ;read/only disk set
IF MPM
		test$dir$cs:
			cmp m! jnz flush$files
			ret
ENDIF
		initial$cs:
			;initializing the checksum
			mov m,a! ret
;
;
wrdir:
	;write the current directory entry, set checksum
	CALL CHECK$WRITE
	call newchecksum ;initialize entry
	call setdir ;directory dma
	mvi c,1 ;indicates a write directory operation
	call wrbuff ;write the buffer
        jmp setdata ;to data dma address
	;ret
;
rd$dir:
	;read a directory entry into the directory buffer
	call setdir ;directory dma
	call rdbuff ;directory record loaded
        ; jmp setdata to data dma address    
	;ret
;
setdata:
	;set data dma address
	lxi h,dmaad! jmp setdma ;to complete the call
;
setdir:
	;set directory dma address
	lxi h,buffa  ;jmp setdma to complete call     
;
setdma:
	;HL=.dma address to set (i.e., buffa or dmaad)
	mov c,m! inx h! mov b,m ;parameter ready
	jmp setdmaf
;
;
IF NOT MPM
dir$to$user:
	;copy the directory entry to the user buffer
	;after call to search or searchn by user code
	lhld buffa! xchg ;source is directory buffer
	lhld dmaad ;destination is user dma address
	mvi c,recsiz ;copy entire record
	jmp move
	;ret
ENDIF
;
MAKE$FCB$INV: ; FLAG FCB AS INVALID
	; RESET FCB WRITE FLAG
	CALL SETFWF
	; SET 1ST TWO BYTES OF DISKMAP TO FFH
	INX H! INX H! MVI A,0FFH! MOV M,A! INX H! MOV M,A
	RET
;
CHK$INV$FCB: ; CHECK FOR INVALID FCB
	CALL GETDMA! JMP TEST$FFFF
;
TST$INV$FCB: ; TEST FOR INVALID FCB
	CALL CHK$INV$FCB! RNZ
	POP H! MVI A,9! JMP STA$RET! ; LRET = 9
;
end$of$dir:
	;return zero flag if at end of directory, non zero
	;if not at end (end of dir if dcnt = 0ffffh)
	lxi h,dcnt
TEST$FFFF:
	mov a,m ;may be 0ffh
	inx h! cmp m ;low(dcnt) = high(dcnt)?
	rnz ;non zero returned if different
	;high and low the same, = 0ffh?
	inr a ;0ffh becomes 00 if so
	ret
;
set$end$dir:
	;set dcnt to the end of the directory
	lxi h,enddir! shld dcnt! ret
;
read$dir:
	;read next directory entry, with C=true if initializing
	lhld dirmax! xchg ;in preparation for subtract
	lhld dcnt! inx h! shld dcnt ;dcnt=dcnt+1
	;continue while dirmax >= dcnt (dirmax-dcnt no cy)
	call subdh ;DE-HL
	jnc read$dir0
		;yes, set dcnt to end of directory
		jmp set$end$dir			;
;		ret				;
	read$dir0:
		;not at end of directory, seek next element
		;initialization flag is in C
		lda dcnt! ani dskmsk ;low(dcnt) and dskmsk
		mvi b,fcbshf ;to multiply by fcb size
		read$dir1:
			add a! dcr b! jnz read$dir1
		;A = (low(dcnt) and dskmsk) shl fcbshf
		sta dptr ;ready for next dir operation
		ora a! rnz ;return if not a new record
		push b ;save initialization flag C
		call seek$dir ;seek proper record
		call rd$dir ;read the directory record
		pop b ;recall initialization flag
		jmp checksum ;checksum the directory elt
		;ret
;
;
getallocbit:
	;given allocation vector position BC, return with byte
	;containing BC shifted so that the least significant
	;bit is in the low order accumulator position.  HL is
	;the address of the byte for possible replacement in
	;memory upon return, and D contains the number of shifts
	;required to place the returned value back into position
	mov a,c! ani 111b! inr a! mov e,a! mov d,a
	;d and e both contain the number of bit positions to shift
;
	MOV H,B! MOV L,C! MVI C,3 ; BC = BC SHR 3
	CALL HLROTR ; HLROTR DOES NOT TOUCH D AND E
	MOV B,H! MOV C,L
;
	lhld alloca ;base address of allocation vector
	dad b! mov a,m ;byte to A, hl = .alloc(BC shr 3)
	;now move the bit to the low order position of A
	rotl: rlc! dcr e! jnz rotl! ret
;
;
setallocbit:
	;BC is the bit position of ALLOC to set or reset.  The
	;value of the bit is in register E.
	push d! call getallocbit ;shifted val A, count in D
	ani 1111$1110b ;mask low bit to zero (may be set)
	pop b! ora c ;low bit of C is masked into A
;	jmp rotr ;to rotate back into proper position	
	;ret
rotr:
	;byte value from ALLOC is in register A, with shift count
	;in register C (to place bit back into position), and
	;target ALLOC position in registers HL, rotate and replace
	rrc! dcr d! jnz rotr ;back into position
	mov m,a ;back to ALLOC
	ret
;
scandm:
	;scan the disk map addressed by dptr for non-zero
	;entries, the allocation vector entry corresponding
	;to a non-zero entry is set to the value of C (0,1)
	call getdptra ;HL = buffa + dptr
	;HL addresses the beginning of the directory entry
	lxi d,dskmap! dad d ;hl now addresses the disk map
	push b ;save the 0/1 bit to set
	mvi c,fcblen-dskmap+1 ;size of single byte disk map + 1
	scandm0:
		;loop once for each disk map entry
		pop d ;recall bit parity
		dcr c! rz ;all done scanning?
		;no, get next entry for scan
		push d ;replace bit parity
		lda single! ora a! jz scandm1
			;single byte scan operation
			push b ;save counter
			push h ;save map address
			mov c,m! mvi b,0 ;BC=block#
			jmp scandm2
		scandm1:
			;double byte scan operation
			dcr c ;count for double byte
			push b ;save counter
			mov c,m! inx h! mov b,m ;BC=block#
			push h ;save map address
		scandm2:
			;arrive here with BC=block#, E=0/1
			mov a,c! ora b ;skip if = 0000
			jz scanm3
				lhld maxall	;check invalid index
			mov a,l! sub c! mov a,h! sbb b	;maxall - block#
			cnc set$alloc$bit			;
			;bit set to 0/1
		scanm3:						;
			pop h! inx h ;to next bit position
			pop b ;recall counter
			jmp scandm0 ;for another item
;
GET$NALBS: ; GET # OF ALLOCATION VECTOR BYTES
	LHLD MAXALL! MVI C,3
	;number of bytes in alloc vector is (maxall/8)+1
	CALL HLROTR! INX H! RET
;
IF MPM
test$dir:
	call home
	call set$end$dir
test$dir1:
	mvi c,0feh! call read$dir
	lda flushed! ora a! rnz
	call end$of$dir! rz
	jmp test$dir1
;
ENDIF
initialize:
	;initialize the current disk
	;lret = false ;set to true if $ file exists
	;compute the length of the allocation vector - 2
IF MPM
	lhld tlog! call test$vector! jz initialize1
	lhld tlog! call remove$drive! shld tlog
	xra a! sta flushed
	call test$dir! rz
initialize1:
ENDIF
	CALL GET$NALBS ; get # of allocation vector bytes
	mov b,h! mov c,l ;count down BC til zero
	lhld alloca ;base of allocation vector
	;fill the allocation vector with zeros
	initial0:
		mvi m,0! inx h ;alloc(i)=0
		dcx b ;count length down
		mov a,b! ora c! jnz initial0
	;
	LHLD DRVLBLA! MOV M,A ; ZERO OUT DRIVE DESC BYTE
	;
	;set the reserved space for the directory
	lhld dirblk! xchg
	lhld alloca ;HL=.alloc()
	mov m,e! inx h! mov m,d ;sets reserved directory blks
	;allocation vector initialized, home disk
	call home
        ;cdrmax = 3 (scans at least one directory record)
	lhld cdrmaxa! mvi m,3! inx h! mvi m,0
	;cdrmax = 0000
	call set$end$dir ;dcnt = enddir
	;read directory entries and check for allocated storage
	initial2:
		mvi c,true! call read$dir
		call end$of$dir! rz ;return if end of directory
		;not end of directory, valid entry?
		call getdptra ;HL = buffa + dptr
		mvi a,empty! cmp m
		jz initial2 ;go get another item
		;
		MVI A,20H! CMP M! JZ DRV$LBL
		MVI A,70H! ANA M! JNZ INITIAL3
		;
		;now scan the disk map for allocated blocks
		mvi c,1 ;set to allocated
		call scandm
	INITIAL3:
		call setcdr ;set cdrmax to dcnt
		jmp initial2 ;for another entry
;
DRV$LBL:
		LXI D,EXTNUM! DAD D! MOV A,M
		LHLD DRVLBLA! MOV M,A! JMP INITIAL3
;
;
copy$dirloc:
	;copy directory location to lret following
	;delete, rename, ... ops
	lda dirloc! jmp sta$ret				;
;	ret						;
;
compext:
	;compare extent# in A with that in C, return nonzero
	;if they do not match
	push b ;save C's original value
	push psw! lda extmsk! cma! mov b,a
	;B has negated form of extent mask
	mov a,c! ana b! mov c,a ;low bits removed from C
	pop psw! ana b ;low bits removed from A
	sub c! ani maxext ;set flags
	pop b ;restore original values
	ret
;
GET$DIR$EXT:
	;COMPUTE DIRECTORY EXTENT FROM FCB
	;SCAN FCB DISK MAP BACKWARDS
	CALL GETFCBA ; HL = .FCB(VRECORD)
	MVI C,16! MOV B,C! INR C! PUSH B
	; B=DSKMAP POS (REL TO 0)
GET$DE0:
	POP B ;
	DCR C ;
	XRA A ; COMPARE TO ZERO
GET$DE1:
	DCX H! DCR B; DECR DSKMAP POSITION
	CMP M! JNZ GET$DE2 ; FCB(DSKMAP(B)) ~= 0
	DCR C! JNZ GET$DE1
	;ALL BLOCKS = 0 IN FCB DISK MAP
GET$DE2:
	LDA SINGLE! ORA A! MOV A,B ;
	JNZ GET$DE3
	RAR ; NOT SINGLE, DIVIDE BLK IDX BY 2
GET$DE3:
	PUSH B! PUSH H ; SAVE DSKMAP POSITION & COUNT
	MOV L,A! MVI H,0 ; HL = NON-ZERO BLK IDX
	; COMPUTE EXT OFFSET FROM LAST NON-ZERO
	; BLOCK INDEX BY SHIFTING BLK IDX RIGHT
	; 7 - BLKSHF
	LDA BLKSHF! MOV D,A! MVI A,7! SUB D ;
	MOV C,A! CALL HLROTR! MOV B,L ;
	; B = EXT OFFSET
	LDA EXTMSK! CMP B! POP H! JC GET$DE0
	; VERIFY COMPUTED EXTENT OFFSET <= EXTMSK
	CALL GETEXTA! MOV C,M
	CMA! ANI MAXEXT! ANA C! ORA B
	;DIR EXT = (FCB EXT & (~ EXTMSK) & MAXEXT) | EXT OFFSET
	POP B ; RESTORE STACK
	RET ; A = DIRECTORY EXTENT
;
SEARCHI:
	;SEARCH INITIALIZATION
	lhld info! shld searcha ;searcha = info
SEARCHI1:
	mvi a,0ffh! sta dirloc ;changed if actually found
	lxi h,searchl! mov m,c ;searchl = C
	RET
;
search:
	;search for directory element of length C at info
	CALL SEARCHI;
SEARCH1: ; ENTRY POINT USED BY RENAME
	call set$end$dir ;dcnt = enddir
	call home ;to start at the beginning
	;(drop through to searchn)			;
;
searchn:
	;search for the next directory element, assuming
	;a previous call on search which sets searcha and
	;searchl
;
IF MPM
	lxi h,user0$pass! xra a! cmp m! mov m,a! cnz swap
ELSE
	XRA A! STA USER0$PASS ;
ENDIF
;
	mvi c,false! call read$dir ;read next dir element
	call end$of$dir! jz search$fin ;skip to end if so
		;not end of directory, scan for match
		lhld searcha! xchg ;DE=beginning of user fcb
		ldax d ;first character
		cpi empty ;keep scanning if empty
		jz searchnext
		;not empty, may be end of logical directory
		push d ;save search address
		call compcdr ;past logical end?
		pop d ;recall address
		jnc search$fin ;artificial stop
searchnext:
		call getdptra ;HL = buffa+dptr
		lda searchl! mov c,a ;length of search to c
		mvi b,0 ;b counts up, c counts down
		;
		MOV A,M! CPI EMPTY! CZ SAVE$DCNT$POS1 
		XRA A! STA SAVE$XFCB
		MOV A,M! ANI 1110$1111B! CMP M! JZ SEARCH$LOOP
		XCHG! CMP M! XCHG! JNZ SEARCH$LOOP
		LDA FIND$XFCB! ORA A! JZ SEARCH$N
		STA SAVE$XFCB! JMP SEARCHOK
		;
		searchloop:
			mov a,c! ora a! jz endsearch
			ldax d! cpi '?'! jz searchok ;? IN USER FCB
			;scan next character if not ubytes
			mov a,b! cpi ubytes! jz searchok
			;not the ubytes field, extent field?
			cpi extnum ;may be extent field
			jz searchext ;skip to search extent
			CPI MODNUM! LDAX D! CZ SEARCHMOD
			sub m! ani 7fh ;mask-out flags/extent modulus
			JNZ SEARCHNM ;skip if not matched
			jmp searchok ;matched character
		searchext:
			LDAX D
			;attempt an extent # match
			push b ;save counters
			;
IF MPM
			push h
 			lhld sdcnt
 			inr h! jnz dont$save
 			lhld dcnt! shld sdcnt
 			lhld dblk! shld sdblk
 		dont$save:
			pop h
ENDIF
			mov c,m ;directory character to c
			call compext ;compare user/dir char
			;
			MOV B,A
			LDA USER0PASS! INR A! JZ SAVE$DCNT$POS2
			; DISABLE SEARCH OF USER 0 IF ANY FCB
			; IS FOUND UNDER THE CURRENT USER #
			XRA A! STA SEARCH$USER0
			DCR A! STA FCB$EXISTS
			MOV A,B
			;
			pop b ;recall counters
			ORA A ; SET FLAG
			jnz searchn ;skip if no match
		searchok:
			;current character matches
			inx d! inx h! inr b! dcr c
			jmp searchloop
		endsearch:
			;entire name matches, return dir position
			LDA SAVE$XFCB! ORA A! JZ ENDSEARCH1
			LDA XDCNT+1! CPI 0FEH! CZ SAVE$DCNT$POS0
			JMP SEARCHN
		ENDSEARCH1:
			STA DIRLOC ; DIRLOC = 0
			lda dcnt! ani dskmsk! sta lret
			;lret = low(dcnt) and 11b
			;SUCCESSFUL SEARCH -
			;RETURN WITH ZERO FLAG RESET
			MOV B,A! INR B! RET
		SEARCHMOD:
			ANI 3FH! RET ; MASK OFF HIGH 2 BITS
		search$fin:
			;end of directory, or empty name
			;
			CALL SAVE$DCNT$POS1 ;
			;
			;SET DCNT = 0FFFFH
			call set$end$dir ;may be artifical end
		LRET$EQ$FF:
			;UNSUCCESSFUL SEARCH -
			;RETURN WITH ZERO FLAG SET
			;LRET,LOW(ARET) = 0FFH
			mvi a,255! MOV B,A! INR B! jmp sta$ret		;
			;
		SEARCHNM: ; SEARCH NO MATCH ROUTINE
			MOV A,B! ORA A! JNZ SEARCHN ; FCB(0)?
			MOV A,M! ORA A! JNZ SEARCHN ; DIR FCB(0)=0?
			LDA SEARCH$USER0! ORA A! JZ SEARCHN
			STA USER0$PASS
			;
IF MPM
			call swap
ENDIF
			;
			JMP SEARCHOK
;
IF MPM
swap: ; swap dcnt,sdblk with sdcnt0,sdblk0
	push h! push d! push b
	lxi d,sdcnt! lxi h,sdcnt0
	mvi b,4
swap1:
	ldax d! mov c,a! mov a,m
	stax d! mov m,c
	inx h! inx d! dcr b! jnz swap1
	pop b! pop d! pop h! 
	ret
ENDIF
;
SAVE$DCNT$POS2:
	; SAVE DIRECTORY POSITION OF MATCHING FCB
	; UNDER USER 0 WITH MATCHING EXTENT # & MODNUM = 0
	; A = 0 ON ENTRY
	ORA B! POP B! LXI B,SEARCHN! PUSH B! RNZ
	; CALL IF USER0PASS = 0FFH &
	;         DIR FCB(EXTNUM) = FCB(EXTNUM)
	;         DIR FCB(MODNUM) = 0
SAVE$DCNT$POS0:
	CALL SAVE$DCNT$POS ; RETURN TO SEARCHN
SAVE$DCNT$POS1:
	; SAVE DIRECTORY POSITION OF FIRST EMPTY FCB
	; OR THE END OF THE DIRECTORY
	PUSH H! 
	LHLD XDCNT! INR H! JNZ SAVE$DCNT$POS$RET ; RETURN IF H ~= 0FFH
SAVE$DCNT$POS:
	LHLD DCNT! SHLD XDCNT ;
	LHLD DBLK! SHLD XDBLK ;
SAVE$DCNT$POS$RET:
	POP H! RET
;
INIT$XFCB$SEARCH:
	MVI A,0FFH
INIT$XFCB$SEARCH1:
	STA FIND$XFCB! MVI A,0FEH! STA XDCNT+1! RET

;
DOES$XFCB$EXIST:
	LDA XDCNT+1! CPI 0FEH! RZ
	CALL SET$DCNT$DBLK
	XRA A! CALL INIT$XFCB$SEARCH1
	LHLD SEARCHA! MOV A,M! ORI 10H! MOV M,A
	MVI C,EXTNUM! CALL SEARCHI1! JMP SEARCHN 
;
delete:
	;delete the currently addressed file
	call check$write ;write protected?
	CALL GET$ATTS! STA ATTRIBUTES
	CALL CHK$PWS! PUSH A
	CALL INIT$XFCB$SEARCH
	MVI C,EXTNUM! CALL SEARCH ;SEARCH THROUGH FILE TYPE
	POP B! JZ DELETE2
	MOV A,B! ORA A! JNZ CHK$PW1
	LDA ATTRIBUTES! RAL! JC DELETE015
	LHLD INFO! CALL CHK$WILD! JZ DELETE015
IF MPM
	call tst$olist
ENDIF
	CALL CHECK$RODIR! JMP DELETE0
;
	DELETE01:
		;LOOP WHILE DIRECTORY MATCHES
		JZ DELETE02
	DELETE015:
IF MPM
		call tst$olist
ENDIF
		CALL CHECK$RODIR
		CALL SEARCHN! JMP DELETE01
	DELETE02:
;
	LDA ATTRIBUTES! RAL! JC DELETE2

	mvi c,extnum! call search ;search through file type
	delete0:
		;loop while directory matches
		JZ DELETE2
	DELETE1:
		;set each non zero disk map entry to 0
		;in the allocation vector
IF MPM
		call chk$olist
ENDIF
		call getdptra ;HL=.buff(dptr)
		MOV A,M! ANI 10H
		mvi m,empty
		mvi c,0! CZ SCANDM ;alloc elts set to 0
		call wrdir ;write the directory
		call searchn ;to next element
		jmp delete0 ;for another record
	DELETE2:
		CALL DOES$XFCB$EXIST! JNZ DELETE1! JMP COPY$DIR$LOC
;
get$block:
	;given allocation vector position BC, find the zero bit
	;closest to this position by searching left and right.
	;if found, set the bit to one and return the bit position
	;in hl.  if not found (i.e., we pass 0 on the left, or
	;maxall on the right), return 0000 in hl
	mov d,b! mov e,c ;copy of starting position to de
	lefttst:
		mov a,c! ora b! jz righttst ;skip if left=0000
		;left not at position zero, bit zero?
		dcx b! push d! push b ;left,right pushed
		call getallocbit
		rar! jnc retblock ;return block number if zero
		;bit is one, so try the right
		pop b! pop d ;left, right restored
	righttst:
		lhld maxall ;value of maximum allocation#
		mov a,e! sub l! mov a,d! sbb h ;right=maxall?
		jnc retblock0 ;return block 0000 if so
		inx d! push b! push d ;left, right pushed
		mov b,d! mov c,e ;ready right for call
		call getallocbit
		rar! jnc retblock ;return block number if zero
		pop d! pop b ;restore left and right pointers
		jmp lefttst ;for another attempt
	retblock:
		ral! inr a ;bit back into position and set to 1
		;d contains the number of shifts required to reposition
		call rotr ;move bit back to position and store
		pop h! pop d ;HL returned value, DE discarded
		ret
	retblock0:
		;cannot find an available bit, return 0000
		mov a,c				;
		ora b! jnz lefttst	;also at beginning    
		lxi h,0000h! ret
;
copy$dir:
	;copy fcb information starting at C for E bytes
	;into the currently addressed directory entry
	MVI D,80H
COPY$DIR0:
	CALL COPY$DIR2
	INR C
COPY$DIR1:
	DCR C! JZ SEEK$COPY
	MOV A,M! ANA B! PUSH B
	MOV B,A! LDAX D! ANI 7FH! ORA B! MOV M,A
	POP B! INX H! INX D! JMP COPY$DIR1
COPY$DIR2:
	push d ;save length for later
	mvi b,0 ;double index to BC
	lhld info ;HL = source for data
	dad b! xchg ;DE=.fcb(C), source for copy
	call getdptra ;HL=.buff(dptr), destination
	pop b ;DE=source, HL=dest, C=length
	RET
seek$copy:
	;enter from close to seek and copy current element
	call seek$dir ;to the directory element
	jmp wrdir ;write the directory element
	;ret
;
CHECK$WILD:
	;CHECK FOR ? IN FILE NAME OR TYPE
	LHLD INFO
CHECK$WILD0:	; ENTRY POINT USED BY RENAME
	CALL CHK$WILD! RNZ
	MVI A,9! POP H ; DISCARD RETURN ADDRESS
	JMP SET$ARET
;
CHK$WILD:
	MVI B,03FH! MVI C,11
CHK$WILD1:
	INX H! MOV A,B! SUB M! ANA B! RZ
	DCR C! JNZ CHK$WILD1! ORA A! RET
;
COPY$USER$NO:
	LHLD INFO! MOV A,M! LXI B,DSKMAP
	DAD B! MOV M,A! RET
;
rename:
	;rename the file described by the first half of
	;the currently addressed file control block. the
	;new name is contained in the last half of the
	;currently addressed file conrol block.  the file
	;name and type are changed, but the reel number
	;is ignored.  the user number is identical
	;
	;VERIFIES NEW FILE NAME DOES NOT EXIST
	;ALSO VERIFIES THAT NO WILD CHARS EXIST
	;IN EITHER FILENAME
;
	call check$write ;may be write protected
	;VERIFY NO WILD CHARS EXIST IN 1ST FILENAME
	CALL CHECK$WILD
	CALL CHK$PASSWORD
;
	CALL INIT$XFCB$SEARCH
;
	;COPY USER NUMBER TO 2ND FILENAME
	CALL COPY$USER$NO
	;VERIFY NEW FILENAME DOES NOT ALREADY EXIST
	SHLD SEARCHA
;
	;VERIFY NO WILD CHARS EXIST IN 2ND FILENAME
	CALL CHECK$WILD0
;
	MVI C,EXTNUM! CALL SEARCHI1! CALL SEARCH1
	JNZ FILE$EXISTS ; NEW FILENAME EXISTS
	CALL DOES$XFCB$EXIST! CNZ DELETE1
;
	CALL COPY$USER$NO
	CALL INIT$XFCB$SEARCH
	;search up to the extent field
	mvi c,extnum! call search
	rz
	CALL CHECK$RODIR ;MAY BE READ-ONLY FILE
IF MPM
	call chk$olist
ENDIF
	;copy position 0
	rename0:
		;not end of directory, rename next element
		mvi c,dskmap! mvi e,extnum! call copy$dir
		;element renamed, move to next
		call searchn
		JNZ RENAME0
	RENAME1:
		CALL DOES$XFCB$EXIST! JZ COPY$DIR$LOC
		CALL COPY$USER$NO! JMP RENAME0
;
indicators:
	;set file indicators for current fcb
	CALL GET$ATTS ; CLEAR F5' THROUGH F8'
	mvi c,extnum! call search ;through file type
	RZ
IF MPM
	call chk$olist
ENDIF
	indic0:
		;not end of directory, continue to change
		mvi c,0! mvi e,extnum ;copy name
		CALL COPY$DIR2! CALL MOVE! CALL SEEK$COPY
		call searchn
		JZ COPY$DIR$LOC
		jmp indic0
;
open:
	;search for the directory entry, copy to fcb
	mvi c,namlen! call search
OPEN1:
	rz ;return with lret=255 if end
	;not end of directory, copy fcb information
open$copy:
	;(referenced below to copy fcb info)
	CALL SETFWF! MOV E,A! PUSH H! DCX H! DCX H
	MOV D,M! PUSH D ; SAVE EXTENT# & MODULE# WITH FCB WRITE FLAG SET
	call getdptra! xchg ;HL = .buff(dptr)
	lhld info ;HL=.fcb(0)
	mvi c,nxtrec ;length of move operation
	push d ; save .buff(dptr)
	call move ;from .buff(dptr) to .fcb(0)
	;note that entire fcb is copied, including indicators
	pop d! lxi h,extnum! dad d ;HL=.buff(dptr+extnum)
	mov c,m ;C = directory extent number
	; RESTORE MODULE # AND EXTENT #
	POP D! POP H! MOV M,E! DCX H! DCX H! MOV M,D
	;HL = .user extent#, C = dir extent#
	;above move set fcb(reccnt) to dir(reccnt)
	;if fcb ext < dir ext then fcb(reccnt) = fcb(reccnt) | 128
	;if fcb ext = dir ext then fcb(reccnt) = fcb(reccnt)
	;if fcb ext > dir ext then fcb(reccnt) = 0
	;
SET$RC: ; HL=.FCB(EXT), C=DIREXT
		MVI B,0
		XCHG! LXI H,(RECCNT-EXTNUM)! DAD D
		LDAX D! CMP C! JZ SET$RC2
		MVI A,0! JNC SET$RC1
		MVI A,128! MOV B,M
	SET$RC1:
		MOV M,A
	SET$RC2:
		MOV A,B! STA ACTUAL$RC
		RET 
;
mergezero:
	;HL = .fcb1(i), DE = .fcb2(i),
	;if fcb1(i) = 0 then fcb1(i) := fcb2(i)
	mov a,m! inx h! ora m! dcx h! rnz ;return if = 0000
	ldax d! mov m,a! inx d! inx h ;low byte copied
	ldax d! mov m,a! dcx d! dcx h ;back to input form
	ret
;
RESTORE$RC:
;	HL = .FCB(EXTNUM)
;	IF ACTUAL$RC ~= 0 THEN RCOUNT = ACTUAL$RC
	PUSH H
	LDA ACTUAL$RC! ORA A! JZ RESTORE$RC1
	LXI D,(RECCNT-EXTNUM)! DAD D
	MOV M,A
RESTORE$RC1:
	POP H! RET
;
close:
	;locate the directory element and re-write it
	xra a! sta lret ;
IF MPM
	sta dont$close
ENDIF
	call nowrite! rnz ;skip close if r/o disk
	;check file write flag - 0 indicates written
	call getmodnum ;fcb(modnum) in A
	ani fwfmsk! rnz ;return if bit remains set
CLOSE1:
	CALL SET$FCB$CKS$FLAG
	CALL GETEXTA! MOV A,M! STA SAVE$EXT
	CALL CLOSE$FCB
	CALL GETDPTRA! LXI D,EXTNUM! DAD D! MOV C,M
	CALL GETEXTA! LDA SAVE$EXT! MOV M,A
	JMP SET$RC

CLOSE$FCB:
	CALL GET$DIR$EXT! ; HL = .FCB(EXT)
	MOV B,M! MOV M,A! INR A! SUB B! JNZ CLOSE3
	ORA C! JZ CLOSE3
	PUSH H! LXI D,(RECCNT-EXTNUM)! DAD D
	MOV A,M! ORA A! JNZ CLOSE2
	MVI M,80H
CLOSE2:
	POP H
CLOSE3:
	CALL RESTORE$RC ; RESTORE FCB(RECCNT)
	mvi c,namlen! call search ;locate file
	rz ;return if not found
	;merge the disk map at info with that at buff(dptr)
	lxi b,dskmap! call getdptra
	dad b! xchg ;DE is .buff(dptr+16)
	lhld info! dad b ;DE=.buff(dptr+16), HL=.fcb(16)
	mvi c,(fcblen-dskmap) ;length of single byte dm
	merge0:
		lda single! ora a! jz merged ;skip to double
		;this is a single byte map
		;if fcb(i) = 0 then fcb(i) = buff(i)
		;if buff(i) = 0 then buff(i) = fcb(i)
		;if fcb(i) <> buff(i) then error
		mov a,m! ora a! ldax d! jnz fcbnzero
			;fcb(i) = 0
			mov m,a ;fcb(i) = buff(i)
		fcbnzero:
		ora a! jnz buffnzero
			;buff(i) = 0
			mov a,m! stax d ;buff(i)=fcb(i)
		buffnzero:
		cmp m! jnz mergerr ;fcb(i) = buff(i)?
		jmp dmset ;if merge ok
	merged:
		;this is a double byte merge operation
		call mergezero ;buff = fcb if buff 0000
		xchg! call mergezero! xchg ;fcb = buff if fcb 0000
		;they should be identical at this point
		ldax d! cmp m! jnz mergerr ;low same?
		inx d! inx h ;to high byte
		ldax d! cmp m! jnz mergerr ;high same?
		;merge operation ok for this pair
		dcr c ;extra count for double byte
	dmset:
		inx d! inx h ;to next byte position
		dcr c! jnz merge0 ;for more
		;end of disk map merge, check record count
		;DE = .buff(dptr)+32, HL = .fcb(32)
		lxi b,-(fcblen-extnum)! dad b! xchg! dad b
		;DE = .fcb(extnum), HL = .buff(dptr+extnum)
		ldax d ;current user extent number
		;if fcb(ext) >= buff(fcb) then
		;buff(ext) := fcb(ext), buff(rec) := fcb(rec)
		cmp m! JNC DMSET0
		XCHG ; UPDATE FCB IN MEMORY FROM DIR FCB
DMSET0:

IF MPM
		push a
ENDIF

		;fcb extent number >= dir extent number
		mov m,a ;buff(ext) = fcb(ext)
		;update directory record count field
		lxi b,(reccnt-extnum)! dad b! xchg! dad b
		;DE=.buff(reccnt), HL=.fcb(reccnt)
IF MPM
		;under mp/m reccnt may have been extended
		;by another process - if extents match, set
		;both reccnt fields to the higher value
		pop a! jnz dmset1
		ldax d! cmp m! jc dmset1
		mov m,a ; fcb(reccnt)=buff(reccnt)
dmset1:
ENDIF
		mov a,m! stax d ;buff(reccnt)=fcb(reccnt)
endmerge:
IF MPM
		lda dont$close! ora a! rnz
ENDIF
		;SET T3' OFF INDICATING FILE UPDATE
		CALL GETDPTRA! LXI D,11! DAD D
		MOV A,M! ANI 7FH! MOV M,A
		CALL SETFWF
		jmp seek$copy ;ok to "wrdir" here - 1.4 compat
	;		ret				;
	mergerr:
		;elements did not merge correctly
		CALL MAKE$FCB$INV
		lxi h,lret! dcr m ;=255 non zero flag set
	ret
;
SET$XDCNT:
	LXI H,0FFFFH! SHLD XDCNT! RET
;
SET$DCNT$DBLK:
	LHLD XDCNT! MVI A,1111$1100B! ANA L
	MOV L,A! DCX H! SHLD DCNT ;
	LHLD XDBLK! SHLD DBLK ;
	RET
;
IF MPM
sdcnt$eq$xdcnt:
	lxi h,sdcnt! lxi d,xdcnt! mvi c,4
	jmp move
ENDIF
;
make:
	;create a new file by creating a directory entry
	;then opening the file
;
	LXI H,XDCNT! CALL TEST$FFFF! JZ LRET$EQ$FF
	CALL SET$DCNT$DBLK
;
	call check$write ;may be write protected
	lhld info! push h ; save fcb address, look for e5
	lxi h,efcb! shld info ; info = .empty
	mvi c,1! 
;
	CALL SEARCHI! CALL SEARCHN
;
	;zero flag set if no space
	pop h ; recall info address
	shld info ;in case we return here
	rz ;return with error condition 255 if not found
;
	; RETURN EARLY IF MAKING AN XFCB
	LDA MAKE$XFCB! ORA A! RNZ
	;clear the remainder of the fcb
	;CLEAR S1 BYTE
	LXI D,13! DAD D! MOV M,D! INX H
	;CLEAR AND SAVE FILE WRITE FLAG OF MODNUM
	MOV A,M! PUSH A! PUSH H! ANI 3FH! MOV M,A! INX H
	mvi c,fcblen-namlen ;number of bytes to fill
	make0:
		MOV M,D! inx h! dcr c! jnz make0
	call setcdr ;may have extended the directory
	;now copy entry to the directory
	MVI C,0! LXI D,FCBLEN! CALL COPY$DIR0
	;AND RESTORE THE FILE WRITE FLAG
	POP H! POP A! MOV M,A
	;and set the FCB write flag to "1"
	XRA A! STA ACTUAL$RC
	jmp setfwf
;
open$reel:
	;close the current extent, and open the next one
	;if possible.  RMF is true if in read mode
	CALL GETMODNUM! STA SAVE$MOD
	CALL GETEXTA
	MOV A,M! MOV C,A ;
	INR C! CALL COMPEXT ;
	JZ OPEN$REEL3
	PUSH H! PUSH B
	CALL CLOSE
	POP B! POP H
	LDA LRET! INR A! RZ
	MVI A,MAXEXT! ANA C! MOV M,A; INCR EXTENT FIELD
	JNZ OPEN$REEL0 ; JMP IF IN SAME MODULE
;
	open$mod:
		;extent number overflow, go to next module
		INX H! INX H ;HL=.fcb(modnum)
		inr m ;fcb(modnum)=++1
		;module number incremented, check for overflow
;
		mov a,m! ANI 3FH! ;mask high order bits
;
		JZ OPEN$R$ERR ;cannot overflow to zero
		;otherwise, ok to continue with new module
	open$reel0:
		CALL SET$XDCNT ; RESET XDCNT FOR MAKE
IF MPM
		call set$sdcnt
ENDIF
		mvi c,namlen! call search ;next extent found?
		jnz open$reel1
			;end of file encountered
			lda rmf! inr a ;0ffh becomes 00 if read
			jz open$r$err ;sets lret = 1
			;try to extend the current file
			call make
			;cannot be end of directory
			;call end$of$dir
			jz open$r$err ;with lret = 1
IF MPM
			call fix$olist$item
ENDIF
			CALL SET$FCB$CKS$FLAG
			jmp open$reel2
		open$reel1:
			;not end of file, open
			CALL SET$FCB$CKS$FLAG
			call open$copy
		open$reel2:
			call getfcb ;set parameters
			xra a! STA VRECORD! jmp sta$ret ;lret = 0	;
;			ret ;with lret = 0
	open$r$err:
		CALL GETMODNUM! LDA SAVE$MOD! MOV M,A
		CALL GETEXTA! LDA SAVE$EXT! MOV M,A
		CALL SET$FCB$CKS$FLAG
		;cannot move to next extent of this file
		call setlret1 ;lret = 1
		jmp setfwf ;ensure that it will not be closed
		;ret
	OPEN$REEL3:
		MOV M,C ; INCREMENT EXTENT FIELD
		CALL GET$DIR$EXT! MOV C,A
		CALL RESTORE$RC
		CALL SET$RC! JMP OPEN$REEL2
;
seqdiskread:
	;sequential disk read operation
	mvi a,1! sta seqio
	;drop through to diskread
;
diskread:	;(may enter from seqdiskread)
	CALL TST$INV$FCB ; CHECK FOR VALID FCB
	mvi a,true! sta rmf ;read mode flag = true (open$reel)
IF MPM
	sta dont$close
ENDIF
	;read the next record from the current fcb
	call getfcb ;sets parameters for the read
DISKREAD0:
	lda vrecord! lxi h,rcount! cmp m ;vrecord-rcount
	;skip if rcount > vrecord
	jc recordok
IF MPM
		call test$disk$fcb! jnz diskread0
		lda vrecord
ENDIF
		;not enough records in the extent
		;record count must be 128 to continue
		cpi 128 ;vrecord = 128?
		JNZ SETLRET1 ;skip if vrecord<>128
		call open$reel ;go to next extent if so
		; xra a  sta vrecord ;vrecord=00 (DONE BY OPEN$REEL)
		;now check for open ok
		lda lret! ora a! JNZ SETLRET1 ;stop at eof
	recordok:
		;arrive with fcb addressing a record to read
		call index
		;error 2 if reading unwritten data
		;(returns 1 to be compatible with 1.4)
		call allocated ;arecord=0000?
IF MPM
		jnz recordok1
		call test$disk$fcb! jnz diskread0
ENDIF
		JZ SETLRET1
	RECORDOK1:
		;record has been allocated, read it
		call atran ;arecord now a disk address
		call seek ;to proper track,sector
		call rdbuff ;to dma address
		jmp setfcb ;replace parameter	

IF MPM
;
test$unlocked:
	lda high$ext! ani 80h! ret
;
test$disk$fcb:
	call test$unlocked! rz 
	lda dont$close! ora a! rz
	call close1
test$disk$fcb1:
	pop d
	lxi h,lret! inr m! mvi a,11! jz sta$ret
	mvi m,0
	push d
	call getrcnta! mov a,m! sta rcount ; reset rcount
	xra a! sta dont$close
	inr a! ret
ENDIF
;
RESET$FWF:
	call getmodnum ;HL=.fcb(modnum), A=fcb(modnum)
	;reset the file write flag to mark as written fcb
	ani (not fwfmsk) and 0ffh ;bit reset
	mov m,a ;fcb(modnum) = fcb(modnum) and 7fh
	RET
;
seqdiskwrite:
	;sequential disk write
	mvi a,1! sta seqio
	;drop through to diskwrite
;
diskwrite:	;(may enter here from seqdiskwrite above)
	mvi a,false! sta rmf ;read mode flag
	;write record to currently selected file
	call check$write ;in case write protected
;
	LDA XFCB$READ$ONLY! ORA A
	MVI A,3! JNZ SET$ARET
;
	LDA HIGH$EXT! ANI 0100$0000B
	; Z FLAG RESET IF R/O MODE
	MVI A,3! JNZ SET$ARET
;
	lhld info ;HL = .fcb(0)
	call check$rofile ;may be a read-only file
;
	CALL TST$INV$FCB ; TEST FOR INVALID FCB
	call getfcb ;to set local parameters
	lda vrecord! cpi lstrec+1 ;vrecord-128
	JC DISKWRITE0
	CALL OPEN$REEL ;VRECORD = 128, TRY TO OPEN NEXT EXTENT
	LDA LRET! ORA A! RNZ ; NO AVAILABLE FCB
DISK$WRITE0:
;
IF MPM
	mvi a,0ffh! sta dont$close
disk$write1:
ENDIF
	;can write the next record, so continue
	call index
	call allocated
IF MPM
	jz diskwrite2
	;if file is unlocked, verify record is not locked
	;record has to be allocated to be locked
	call test$unlocked! jz not$unlocked
	call atran! mov c,a
	lda mult$cnt! mov b,a! push b
	call test$lock! pop b
	mov a,c! mvi c,0! push b
	jmp diskwr10
not$unlocked:
	inr a
ENDIF
	mvi c,0 ;marked as normal write operation for wrbuff
	jnz diskwr1
IF MPM
	diskwrite2:
		call test$disk$fcb! jnz diskwrite1
ENDIF
		;not allocated
		;the argument to getblock is the starting
		;position for the disk search, and should be
		;the last allocated block for this file, or
		;the value 0 if no space has been allocated
		call dm$position
		sta dminx ;save for later
		lxi b,0000h ;may use block zero
		ora a! jz nopblock ;skip if no previous block
			;previous block exists at A
			mov c,a! dcx b ;previous block # in BC
			call getdm ;previous block # to HL
			mov b,h! mov c,l ;BC=prev block#
		nopblock:
			;BC = 0000, or previous block #
			call get$block ;block # to HL
		;arrive here with block# or zero
		mov a,l! ora h! jnz blockok
			;cannot find a block to allocate
			mvi a,2! jmp sta$ret 	;lret=2	
		blockok:
		CALL SET$FCB$CKS$FLAG
		;allocated block number is in HL
		shld arecord
		xchg ;block number to DE
		lhld info! lxi b,dskmap! dad b ;HL=.fcb(dskmap)
		lda single! ora a ;set flags for single byte dm
		lda dminx ;recall dm index
		jz allocwd ;skip if allocating word
			;allocating a byte value
			call addh! mov m,e ;single byte alloc
			jmp diskwru ;to continue
		allocwd:
		;allocate a word value
			mov c,a! mvi b,0 ;double(dminx)
			dad b! dad b ;HL=.fcb(dminx*2)
			mov m,e! inx h! mov m,d ;double wd
		diskwru:
		;disk write to previously unallocated block
		mvi c,2 ;marked as unallocated write
	diskwr1:
	;continue the write operation of no allocation error
	;C = 0 if normal write, 2 if to prev unalloc block
	;lda lret  ora a  rnz ;stop if non zero returned value
	;ABOVE LINE REMOVED - LRET CANNOT BE NON-ZERO
	push b ;save write flag
	call atran ;arecord set
	diskwr10:
;
		MOV D,A ; SAVE LOW BYTE OF ARECORD RETURNED
			; IN REGISTER A FROM ATRAN
;
		lda seqio! dcr a! dcr a! jnz diskwr11   ;
		pop b! push b! mov a,c! dcr a! dcr a	;
		jnz diskwr11		;old allocation  
;
		PUSH D ; SAVE LOW BYTE OF ARECORD ON STACK
;
		lhld buffa! mov d,a	;zero buffa & fill 
	fill0:  mov m,a! inx h! inr d! jp fill0		;
		call setdir! lhld arecord1		;
		mvi c,2					;
	fill1:  shld arecord! push b! call seek! pop b  ;
		call wrbuff	;write fill record	;
		lhld arecord!	;restore last record     
		mvi c,0		;change  allocate flag   
		lda blkmsk! mov b,a! ana l! cmp b!inx h	;
		jnz fill1	;cont until cluster is zeroed
;
		POP A! STA ARECORD ; RESTORE ARECORD LOW BYTE
;
		call setdata ; restore dma
	diskwr11:					;
	call seek ;to proper file position
	pop b ;
;
	LDA VRECORD! MOV B,A ; LOAD AND SAVE VRECORD
;
	push b ;restore/save write flag (C=2 if new block)
;
	LXI H,BLKMSK! ANA M! JZ WRITE ;
	MVI C,0 ; SET C TO ZERO IF VRECORD DOES NOT LOCATE
;		  FIRST RECORD OF NEW BLOCK
WRITE:
;
	call wrbuff ;written to disk
	pop b ;C = 2 if a new block was allocated, 0 if not
	;increment record count if rcount<=vrecord
	MOV A,B! lxi h,rcount! cmp m ;vrecord-rcount
	jc diskwr2
		;rcount <= vrecord
		mov m,a! inr m ;rcount = vrecord+1
IF	MPM
		call test$unlocked! jz write1
	
		;for unlocked files 
		;  rcount = rcount & (~ blkmsk) + blkmsk + 1

		lda blkmsk! mov b,a! inr b! cma! mov c,a
		mov a,m! dcr a! ana c! add b! mov m,a
	write1:
ENDIF
		mvi c,2 ;mark as record count incremented
	diskwr2:
	;A has vrecord, C=2 if new block or new record#
	dcr c! dcr c! jnz noupdate
		CALL RESET$FWF
IF MPM
		call test$unlocked! jz noupdate
		lda rcount! call getrcnta! mov m,a
		call close
		call test$disk$fcb1
ENDIF

noupdate:
;
	;SET FILE WRITE FLAG IF RESET
	CALL GETMODNUM! ANI 0100$0000B! JNZ DISK$WRITE3
	MOV A,M! ORI 0100$0000B! MOV M,A
	;RESET FCB FILE WRITE FLAG TO ENSURE T3' GETS
	;RESET BY THE CLOSE FUNCTION
	CALL RESET$FWF
DISK$WRITE3:
	jmp setfcb ;replace parameters
	;ret
;
rseek:   
	;random access seek operation, C=0ffh if read mode
	;fcb is assumed to address an active file control block
	;(modnum has been set to 1100$0000b if previous bad seek)
	xra a! sta seqio ;marked as random access operation
rseek1:
	push b ;save r/w flag
	lhld info! xchg ;DE will hold base of fcb
		lxi h,ranrec! dad d ;HL=.fcb(ranrec)
		mov a,m! ani 7fh! push psw ;record number
		mov a,m! ral ;cy=lsb of extent#
		inx h! mov a,m! ral! ani 11111b ;A=ext#
		mov c,a ;C holds extent number, record stacked
;
		MOV A,M! ANI 1111$0000B! INX H! ORA M ;
		RRC! RRC! RRC! RRC! MOV B,A ; 
		; B HOLDS MODULE #
;
		; CHECK HIGH BYTE OF RAN REC <= 3
		MOV A,M
		ANI 1111$1100B! POP H! MVI L,6! MOV A,H ;
;
		;produce error 6, seek past physical eod
		jnz seekerr
		;otherwise, high byte = 0, A = sought record
		lxi h,nxtrec! dad d ;HL = .fcb(nxtrec)
		mov m,a ;sought rec# stored away
	;arrive here with B=mod#, C=ext#, DE=.fcb, rec stored
	;the r/w flag is still stacked.  compare fcb values
	;
		;CHECK MODULE # FIRST
		PUSH D! CALL CHK$INV$FCB! POP D! JZ RANCLOSE
		lxi h,modnum! dad d! mov a,b ;B=seek mod#
		;could be overflow at eof, producing module#
		;of 90H or 10H, so compare all but fwf
		sub m! ani 3fh! JNZ RANCLOSE ;same?
		;MODULE MATCHES, CHECK EXTENT
		lxi h,extnum! dad d
		MOV A,M! CMP C! JZ SEEKOK1 ;EXTENTS EQUAL
		CALL COMPEXT! JNZ RANCLOSE
		;EXTENT IS IN SAME DIRECTORY FCB
		MOV M,C ; FCB(EXT) = C
		CALL GET$DIR$EXT! MOV C,A
		; HL=.FCB(EXT),C=DIR EXT
		CALL RESTORE$RC
		CALL SET$RC
		JMP SEEKOK1
	ranclose:
		push b! push d ;save seek mod#,ext#, .fcb
		call close ;current extent closed
		pop d! pop b ;recall parameters and fill
		mvi l,3 ;cannot close error #3
		lda lret! inr a! jz badseek
		CALL SET$XDCNT ; RESET XDCNT FOR MAKE
IF MPM
		call set$sdcnt
ENDIF
		lxi h,extnum! dad d! mov m,c ;fcb(extnum)=ext#
		INX H! INX H! MOV A,M! ANI 040H! ORA B! MOV M,A
		;fcb(modnum)=mod#
		call open ;is the file present?
		lda lret! inr a! jnz seekok ;open successful?
		;cannot open the file, read mode?
		pop b ;r/w flag to c (=0ffh if read)
		push b ;everyone expects this item stacked
		mvi l,4 ;seek to unwritten extent #4
		inr c ;becomes 00 if read operation
		jz badseek ;skip to error if read operation
		;write operation, make new extent
		call make
		mvi l,5 ;cannot create new extent #5
		jz badseek ;no dir space
IF MPM
		call fix$olist$item
ENDIF
		;file make operation successful
	seekok:
		CALL SET$FCB$CKS$FLAG
	SEEKOK1:
		pop b ;discard r/w flag
		xra a! jmp sta$ret 	;with zero set	
	badseek:
		;fcb no longer contains a valid fcb, mark
		;with 1100$000b in modnum field so that it
		;appears as overflow with file write flag set
		push h ;save error flag
		CALL SET$FCB$CKS$FLAG
		CALL MAKE$FCB$INV ; FLAG FCB AS INVALID
		pop h ;and drop through
	seekerr:
		pop b ;discard r/w flag
		mov a,l! sta lret ;lret=#, nonzero
		;setfwf returns non-zero accumulator for err
		RET ; FOLLOWING LINE REMOVED
;		jmp setfwf ;flag set, so subsequent close ok
		;ret
;
randiskread:
	;random disk read operation
	mvi c,true ;marked as read operation
	call rseek
	cz diskread ;if seek successful
	ret
;
randiskwrite:
	;random disk write operation
	mvi c,false ;marked as write operation
	call rseek
	cz diskwrite ;if seek successful
	ret
;
compute$rr:
	;compute random record position for getfilesize/setrandom
	xchg! dad d
	;DE=.buf(dptr) or .fcb(0), HL = .f(nxtrec/reccnt)
	mov c,m! mvi b,0 ;BC = 0000 0000 ?rrr rrrr
	lxi h,extnum! dad d! mov a,m! rrc! ani 80h ;A=e000 0000
	add c! mov c,a! mvi a,0! adc b! mov b,a
	;BC = 0000 000? errrr rrrr
	mov a,m! rrc! ani 0fh! add b! mov b,a
	;BC = 000? eeee errrr rrrr
	lxi h,modnum! dad d! mov a,m ;A=XXmm mmmm
	add a! add a! add a! add a ;cy=m A=mmmm 0000
;
	ORA A! ADD B! MOV B,A! PUSH PSW ; SAVE CARRY
	MOV A,M! RAR! RAR! RAR! RAR! ANI 0000$0011B ; A=0000 00mm
	MOV L,A! POP PSW! MVI A,0! ADC L ; ADD CARRY
	RET ;
;
getfilesize:
	;compute logical file size for current fcb
	;zero the receiving ranrec field
	CALL GET$RRA! push h ;save position
	mov m,d! inx h! mov m,d! inx h! mov m,d;=00 00 00
	MVI C,EXTNUM! CALL SEARCH
	getsize:
		jz setsize
		;current fcb addressed by dptr
		call getdptra! lxi d,reccnt ;ready for compute size
		call compute$rr
		;A=0000 00mm BC = mmmm eeee errr rrrr
		;compare with memory, larger?
		pop h! push h ;recall, replace .fcb(ranrec)
		mov e,a ;save cy
		mov a,c! sub m! inx h ;ls byte
		mov a,b! sbb m! inx h ;middle byte
		mov a,e! sbb m ;carry if .fcb(ranrec) > directory
		jc getnextsize ;for another try
		;fcb is less or equal, fill from directory
		mov m,e! dcx h! mov m,b! dcx h! mov m,c
	getnextsize:
		call searchn
		MVI A,0! STA ARET
		jmp getsize
	setsize:
	pop h ;discard .fcb(ranrec)
	ret
;
setrandom:
	;set random record from the current file control block
	XCHG! lxi d,nxtrec ;ready params for computesize
	call compute$rr ;DE=info, A=0000 00mm, BC=mmmm eeee errr rrrr
	lxi h,ranrec! dad d ;HL = .fcb(ranrec)
	mov m,c! inx h! mov m,b! inx h! mov m,a ;to ranrec
	ret
;
TMPSELECT:
	LXI H,SELDSK! MOV A,M! PUSH A! MOV M,E
	CALL CURSELECT! POP A! STA SELDSK! RET
;
XCURSELECT:
	MVI A,0FFH! STA RETURN$FFFF 
	CALL CURSELECT
	XRA A! STA RETURN$FFFF! RET
;
CURSELECT:
	LDA SELDSK! 
	LXI H,CURDSK! CMP M! JZ TEST$FF$DSK
	;SKIP IF SELDSK = CURDSK, FALL INTO SELECT
;
select:
	;select disk info for subsequent input or output ops
	lhld dlog! CALL TEST$VECTOR
	MOV E,A! PUSH D ;SEND TO SELDSK, SAVE FOR TEST BELOW
	call selectdisk! pop h ;recall dlog vector
	cz sel$error ;returns true if select ok
	;is the disk logged in?
	mov a,l! ORA A
IF MPM
	jz select1
	lhld rlog! call test$vector
	sta rem$drv! ret ; set rem$drv & return
select1:
ELSE
	rnz ;return if bit is set
ENDIF
	;disk not logged in, set bit and initialize
	lhld dlog! mov c,l! mov b,h ;call ready
	call set$cdisk! shld dlog ;dlog=set$cdisk(dlog)
IF MPM
	lxi h,chksiz+1! mov a,m! ral! mvi a,0! jc select2
	lhld rlog! mov c,l! mov b,h
	call set$cdisk! shld rlog ;rlog=set$cdisk(rlog)
	mvi a,1
select2:
	sta rem$drv
ENDIF
	jmp initialize
	;ret
;
TEST$FF$DSK:
	INR A! JZ SEL$ERROR
	RET
;
SET$SELDSK:
	LDA LINFO! STA SELDSK! RET
;
RESELECTX:
	XRA A! STA HIGH$EXT! JMP RESELECT1
reselect:
	;check current fcb to see if reselection necessary
	MVI A,80H! MOV B,A! DCR A! MOV C,A
	LHLD INFO! LXI D,7! XCHG! DAD D
	MOV A,M! ANA B! STA XFCB$READ$ONLY
	MOV A,M! ANA C! MOV M,A
	INX H! LXI D,4
	MOV A,M! ANA C! CMP M! MOV M,A! MVI A,60H! JNZ RESELECT0
	DAD D! MVI A,0E0H! ANA M
RESELECT0:
	STA HIGH$EXT! CALL CLR$EXT
	CALL GETRCNTA! MOV A,M! ANA B! JZ RESELECT1
	MOV A,M! ANA C! MOV M,B
RESELECT1:
	STA ACTUAL$RC
	mvi a,true! sta resel ;mark possible reselect
	lhld info! mov a,m ;drive select code
	ani 1$1111b ;non zero is auto drive select
	dcr a ;drive code normalized to 0..30, or 255
	sta linfo ;save drive code
	CPI 0FFH! JZ NOSELECT
		;auto select function, save SELDSK
		LDA SELDSK! sta olddsk ;olddsk=SELDSK
		mov a,m! sta fcbdsk ;save drive code
		ani 1110$0000b! mov m,a ;preserve hi bits
		CALL SET$SELDSK
	noselect:
		CALL CURSELECT
		;set user code
		lda usrcode ;0...31
		lhld info! ora m! mov m,a
		ret
;
CHK$PASSWORD:
	CALL GET$DIR$MODE! ANI 80H! JNZ CHK$PW! RET
;
GET$DIR$MODE:
	LHLD DRVLBLA! MOV A,M! RET
;
CHK$PW:		; CHECK PASSWORD
	CALL GET$XFCB! RZ ; A = XFCB OPTIONS
	DCR A! CNZ CMP$PW! RZ
CHK$PW1:	; PASSWORD ERROR
	POP H! MVI A,7! JMP SET$ARET
;
CMP$PW:		; COMPARE PASSWORDS
	INX H! MOV B,M
	MOV A,B! ORA A! JNZ CMP$PW2
	MOV D,H! MOV E,L! INX H! INX H
	MVI C,9
CMP$PW1:
	INX H! MOV A,M! DCR C! RZ
	ORA A! JZ CMP$PW1
	CPI 20H! JZ CMP$PW1
	XCHG
CMP$PW2:
	LXI D,(23-UBYTES)! DAD D! XCHG
	LHLD XDMAAD! MVI C,8
CMP$PW3:
	LDAX D! XRA B! CMP M! JNZ CMP$PW4
	DCX D! INX H! DCR C! JNZ CMP$PW3
	RET
CMP$PW4:
	DCX D! DCR C! JNZ CMP$PW4
	INX D
IF MPM
	call get$df$pwa! inr a! jnz cmp$pw5
	inr a! ret
cmp$pw5:
ELSE
	LXI H,DF$PASSWORD
ENDIF
	MVI C,8! JMP COMPARE
;
IF MPM
get$df$pwa:		;A = FF => no df pwa
	call rlr! lxi b,console! dad b
	mov a,m! cpi 16! mvi a,0ffh! rnc
	mov a,m! add a! add a! add a
	mvi h,0! mov l,a! lxi b,dfpassword! dad b
	ret
ENDIF
;
SET$PW:		; SET PASSWORD IN XFCB
	PUSH H ; SAVE .XFCB(EX) 
	LXI B,8 ; B = 0, C = 8
	LXI D,(23-EXTNUM)! DAD D
	XCHG! LHLD XDMAAD
SET$PW0:
	XRA A! PUSH A
SET$PW1:
	MOV A,M! STAX D! ORA A! JZ SET$PW2
	CPI 20H! JZ SET$PW2
	INX SP! INX SP! PUSH A
SET$PW2:
	ADD B! MOV B,A
	DCX D! INX H! DCR C! JNZ SET$PW1
	POP A! ORA B! POP H! JNZ SET$PW3
	MOV M,A ; ZERO XFCB(EX) - NO PASSWORD
SET$PW3:
	INX D! MVI C,8
SET$PW4:
	LDAX D! XRA B! STAX D! INX D! DCR C! JNZ SET$PW4
	INX H! RET
;
GET$XFCB:
	MVI B,0
GET$XFCB0:
	LHLD INFO! MOV A,M! PUSH A
	ORI 010H! MOV M,A! MVI C,EXTNUM
	XRA A! CMP B! JNZ GET$XFCB00
	CALL SEARCH! JMP GET$XFCB01
GET$XFCB00:
	CALL SEARCHN
GET$XFCB01:
	MVI A,0! STA LRET
	LHLD INFO! POP B! MOV M,B! RZ
GET$XFCB1:
	CALL GETDPTRA! XCHG
	LXI H,EXTNUM! DAD D! MOV A,M! ANI 0E0H! ORI 1
	RET
;
ADJUST$DMAAD:
	PUSH H! LHLD XDMAAD! DAD D
	SHLD XDMAAD! POP H! RET
;
INIT$XFCB:
	CALL SETCDR ;MAY HAVE EXTENDED THE DIRECTORY
	LXI B,1014H ; B=10H, C=20
INIT$XFCB0:
	;B = FCB(0) LOGICAL OR MASK
	;C = ZERO COUNT
	PUSH B
	CALL GETDPTRA! XCHG! LHLD INFO! XCHG
	;ZERO EXTNUM AND MODNUM
	LDAX D! ORA B! MOV M,A! INX D! INX H
	MVI C,11! CALL MOVE! POP B! INR C
INIT$XFCB1:
	DCR C! RZ
	MVI M,0! INX H! JMP INIT$XFCB1
;
CHK$XFCB$PASSWORD:
	CALL GET$XFCB1! DCR A
CHK$XFCB$PASSWORD1:
	PUSH H! CNZ CMP$PW! POP H! RZ
	JMP CHK$PW1
;
CHK$PWS:
	CALL GET$DIR$MODE! ANI 80H! RZ
	CALL GET$XFCB
CHK$PWS1:
	RZ! DCR A
	CNZ CMP$PW! RNZ
	MVI B,1! CALL GET$XFCB0! JMP CHK$PWS1
;
STAMP1:
	LXI B,24! JMP STAMP3
STAMP2:
	LXI B,28!
STAMP3:
;
IF MPM
	push b!
	call get$stamp$add! xchg
	pop b
ELSE
	LXI D,STAMP
ENDIF
	CALL GETDPTRA! DAD B
	MVI C,4! JMP MOVE ;RET
;
IF MPM
;
pack$sdcnt:
;
;packed$dcnt = dblk(low 15 bits) || dcnt(low 9 bits)
;
;	if sdblk = 0 then dblk = shr(sdcnt,blkshf+2)
;		     else dblk = sdblk
;	dcnt = sdcnt & (blkmsk || '11'b)
;
;	packed$dcnt format (24 bits)
;
;	12345678 12345678 12345678
;	23456789 .......1 ........ sdcnt (low 9 bits)
;	........ 9abcdef. 12345678 sdblk (low 15 bits)
;
	lhld sdblk! mov a,h! ora l! jnz pack$sdcnt1
	lda blkshf! adi 2! mov c,a! lhld sdcnt
	call hlrotr
pack$sdcnt1:
	dad h! xchg! lxi h,sdcnt! mvi b,1
	lda blkmsk! ral! ora b! ral! ora b
	ana m! sta packed$dcnt
	lda blkshf! cpi 7! jnz pack$sdcnt2
	inx h! mov a,m! ana b! jz pack$sdcnt2
	mov a,e! ora b! mov e,a
pack$sdcnt2:
	xchg! shld packed$dcnt+1
	ret
;
;
;olist element = link(2) || atts(1) || dcnt(3) || 
;		 pdaddr(2) || opncnt(2)
;
;	link = 0 -> end of list
;
;	atts - 80 - open in locked mode
;	       40 - open in unlocked mode
;	       20 - open in read/only mode
;	       10 - deleted item
;	       0n - drive code (0-f)
;
;	dcnt = packed sdcnt+sdblk
;	pdaddr = process descriptor addr
;	opncnt = # of open calls - # of close calls
;		 olist item freed by close when opncnt = 0
;
;llist element = link(2) || drive(1) || arecord(3) || 
;	         pdaddr(2) || .olist$item(2)
;
;	link = 0 -> end of list
;
;	drive - 0n - drive code (0-f)
;
;	arecord = record number of locked record
;	pdaddr = process descriptor addr
;	.olist$item = address of file's olist item
;
search$olist:
	lxi h,open$root! jmp srch$list0
search$llist:
	lxi h,lock$root! jmp srch$list0
searchn$list:
	lhld cur$pos
srch$list0:
	shld prv$pos
;
;search$olist, search$llist, searchn$list conventions
;
;	B = 0 -> return next item
;	B = 1 -> search for matching drive
; 	B = 3 -> search for matching dcnt
;	B = 5 -> search for matching dcnt + pdaddr
;	if found then z flag is set
;	              prv$pos -> previous list element
;		      cur$pos -> found list element
;		      HL -> found list element
;	else prv$pos -> list element to insert after
;
;	olist and llist are maintained in drive order
;
srch$list1:
	mov e,m! inx h! mov d,m! xchg
	mov a,l! ora h! jz srch$list3
	xra a! cmp b! jz srch$list6
	inx h! inx h!
	lxi d,curdsk! mov a,m! ani 0fh! mov c,a
	ldax d! sub c! jnz srch$list4
	mov a,b! dcr a! jz srch$list5
	mov c,b! push h
	inx d! inx h! call compare
	pop h! jz srch$list5
srch$list2:
	dcx h! dcx h
	shld prv$pos! jmp srch$list1
srch$list3:
	inr a! ret
srch$list4:
	jnc srch$list2
srch$list5:
	dcx h! dcx h
srch$list6:
	shld cur$pos! ret
;
delete$item: ; HL -> item to be deleted
	di
	push d! push h
	mov e,m! inx h! mov d,m
	lhld prv$pos! shld cur$pos
	;prv$pos.link = delete$item.link
	mov m,e! inx h! mov m,d
	;
	lhld free$root! xchg
	;free$root = .delete$item
	pop h! shld free$root
	;delete$item.link = previous free$root
	mov m,e! inx h! mov m,d
	pop d! ei! ret
;
create$item: ; HL -> new item if successful
	     ; Z flag set if no free items
	lhld free$root! mov a,l! ora h! rz
	push d! push h! shld cur$pos
	mov e,m! inx h! mov d,m
	;free$root = free$root.link
	xchg! shld free$root
	;
	lhld prv$pos
	mov e,m! inx h! mov d,m
	pop h
	;create$item.link = prv$pos.link
	mov m,e! inx h! mov m,d! dcx h
	xchg! lhld prv$pos
	;prv$pos.link = .create$item
	mov m,e! inx h! mov m,d! xchg
	pop d! ret
;
set$olist$item:
	; A = attributes
	; HL = olist entry address
	inx h! inx h
	mov b,a! lxi d,curdsk! ldax d! ora b
	mov m,a! inx h! inx d
	mvi c,5! call move
	xra a! mov m,a! inx h! mov m,a! ret
;
set$sdcnt:
 	mvi a,0ffh! sta sdcnt+1! ret
;
tst$olist:
	mvi a,0c9h! sta chk$olist05! jmp chk$olist0
chk$olist:
	xra a! sta chk$olist05
chk$olist0:
	lxi d,dcnt! lxi h,sdcnt! mvi c,4! call move
	call pack$sdcnt! mvi b,3! call search$olist! rnz
	pop d ; pop return address
	inx h! inx h
	mov a,m! ani 80h! jz openx06 
	dcx h! dcx h
	push d! push h
	call compare$pds! pop h! pop d! jnz openx06
	push d ;restore return address
chk$olist05:
	nop ; tst$olist changes this instr to ret
	call delete$item! lda pdcnt
chk$olist1:
	adi 16! jz chk$olist1
	sta pdcnt

	push a! call rlr
	lxi b,pdcnt$off! dad b! pop a
	mov m,a

	ret
;
remove$files:	;BC = pdaddr
	lhld cur$pos! push h
	lhld prv$pos! push h
	mov d,b! mov e,c! lxi h,open$root! shld cur$pos
remove$file1:
	mvi b,0! push d! call searchn$list! pop d! jnz remove$file2
	lxi b,6! call tst$tbl$lmt! jnz remove$file1
	inx h! inx h! mov a,m! ori 10h! mov m,a
	sta deleted$files
	jmp remove$file1
remove$file2:
	pop h! shld prv$pos
	pop h! shld cur$pos
	ret
;
delete$files:
	lxi h,open$root! shld cur$pos
delete$file1:
	mvi b,0! call search$nlist! rnz
	inx h! inx h! mov a,m! ani 10h! jz delete$file1
	dcx h! dcx h! call remove$locks! call delete$item
	jmp delete$file1
;
flush$files:
	lxi h,flushed! mov a,m! ora a! rnz
	inr m
flush$file0:
	lxi h,open$root! shld cur$pos
flush$file1:
	mvi b,1! call searchn$list! rnz
	push h! call remove$locks! call delete$item! pop h
	lxi d,6! dad d! mov e,m! inx h! mov d,m
	lxi h,pdcnt$off! dad d! mov a,m! ani 1! jnz flush$file1
	mov a,m! ori 1! mov m,a
	lhld pdaddr! mvi c,2! call compare! jnz flush$file1
	lda pdcnt! adi 10h! sta pdcnt! jmp flush$file1
;
free$files:
	; free$mode = 1 - remove curdsk files for process
	;	      0 - remove all files for process
	lhld pdaddr! xchg! lxi h,open$root! shld curpos
free$files1:
	lda free$mode! mov b,a
	push d! call searchn$list! pop d! rnz
	lxi b,6! call tst$tbl$lmt! jnz free$files1
	push h! inx h! inx h! inx h
	call test$ffff! jnz free$files2
	call test$ffff! jz free$files3
free$files2:
	mvi a,0ffh! sta incr$pdcnt
free$files3:
	pop h! call remove$locks! call delete$item
	jmp free$files1
;
remove$locks:
	shld file$id
	inx h! inx h! mov a,m! ani 40h! jz remove$lock3
	push d! lhld prv$pos! push h
	lhld file$id! xchg! lxi h,lock$root! shld cur$pos
remove$lock1:
	mvi b,0! push d! call searchn$list! pop d
	jnz remove$lock2
	lxi b,8! call tst$tbl$lmt! jnz remove$lock1
	call delete$item
	jmp remove$lock1
remove$lock2:
	pop h! shld prv$pos! pop d
remove$lock3:
	lhld file$id! ret
;
tst$tbl$lmt:
	push h! dad b
	mov a,m! inx h! mov h,m
	sub e! jnz tst$tbl$lmt1
	mov a,h! sub d
tst$tbl$lmt1:
	pop h! ret
;
create$olist$item:
	mvi b,1! call search$olist
	di
	call create$item! lda attributes! call set$olist$item
	ei
	ret
;
count$opens:
	xra a! sta open$cnt
	lhld pdaddr! xchg! lxi h,open$root! shld curpos
count$open1:
	mvi b,0! push d! call searchn$list! pop d! jnz count$open2
	lxi b,6! call tst$tbl$lmt! jnz count$open1
	lda open$cnt! inr a! sta open$cnt
	jmp count$open1
count$open2:
	lxi h,open$max! lda open$cnt! ret
;
count$locks:
	xra a! sta lock$cnt
	xchg! lxi h,lock$root! shld cur$pos
count$lock1:
	mvi b,0! push d! call searchn$list! pop d! rnz
	lxi b,8! call tst$tbl$lmt! jnz count$lock1
	lda lock$cnt! inr a! sta lock$cnt
	jmp count$lock1
;
check$free:
	lda mult$cnt! mov e,a
	mvi d,0! lxi h,free$root! shld cur$pos
check$free1:
	mvi b,0! push d! call searchn$list! pop d! jnz check$free2
	inr d! mov a,d! sub e! jc check$free1
	ret
check$free2:
	pop h! mvi a,14! jmp sta$ret
;
lock:				;record lock and unlock 
	call reselect! call check$fcb
	call test$unlocked
	rz ; file not opened in unlocked mode
	lhld xdmaad! mov e,m! inx h! mov d,m
	xchg! inx h! inx h
	mov a,m! mov b,a! lda curdsk! sub b
	ani 0fh! jnz lock8 ; invalid file id
	mov a,b! ani 40h! jz lock8 ; invalid file id
	dcx h! dcx h! shld file$id
	lda lock$unlock! inr a! jnz lock1 ; jmp if unlock
	call count$locks
	lda lock$cnt! mov b,a
	lda mult$cnt! add b! mov b,a
	lda lock$max! cmp b
	mvi a,12! jc sta$ret ; too many locks by this process
	call check$free
lock1:
	call save$rr! lxi h,lock9! push h! lda mult$cnt
lock2:
	push a! call get$lock$add
	lda lock$unlock! inr a! jnz lock3
	call test$lock
lock3:
	pop a! dcr a! jz lock4
	call incr$rr! jmp lock2
lock4:
	call reset$rr! lda mult$cnt
lock5:
	push a! call get$lock$add
	lda lock$unlock! inr a! jnz lock6
	call set$lock! jmp lock7
lock6:
	call free$lock
lock7:
	pop a! dcr a! rz
	call incr$rr! jmp lock5
lock8:
	mvi a,13! jmp sta$ret ; invalid file id
lock9:
	call reset$rr! ret
;
get$lock$add:
	lxi h,0! dad sp! shld lock$sp
	mvi a,0ffh! sta lock$shell
	call rseek
	xra a! sta lock$shell
	call getfcb
	lhld aret! mov a,l! ora a! jnz lock$err
	call index! call allocated
	lxi h,1! jz lock$err
	call atran! ret
;
lock$perr:
	xra a! sta lock$shell
	xchg! lhld lock$sp! sphl! xchg
lock$err:
	pop d ; discard return address
	pop b ; B = mult$cnt-# recs processed
	lda mult$cnt! sub b
	add a! add a! add a! add a
	ora h! mov h,a! mov b,a
	shld aret! ret
;
test$lock:
	call move$arecord
	mvi b,3! call search$llist! rnz
	call compare$pds! rz
	lxi h,8! jmp lock$err
;
set$lock:
	call move$arecord
	mvi b,1! call search$llist
	di
	call create$item
	xra a! call set$olist$item
	xchg! lhld file$id! xchg
	mov m,d! dcx h! mov m,e
	ei! ret
;
free$lock:
	call move$arecord
	mvi b,5! call search$llist! rnz
free$lock0:
	call delete$item
	mvi b,5! call searchn$list! rnz
	jmp free$lock0
;
compare$pds:
	lxi d,6! dad d! xchg
	lxi h,pdaddr! mvi c,2! jmp compare
	;ret
;
move$arecord:
	lxi d,arecord! lxi h,packed$dcnt
	mvi c,3! jmp move ;ret
;
fix$olist$item:
	lxi d,xdcnt! lxi h,sdcnt
	;is xdblk,xdcnt < sdblk,sdcnt
	mvi c,4! ora a!
fix$ol1:
	ldax d! sbb m! inx h! inx d! dcr c! jnz fix$ol1
	rnc
	;yes - update olist entry
	call swap! call sdcnt$eq$xdcnt
	lxi h,open$root! shld cur$pos
	;find file's olist entry
fix$ol2:
	call swap! call pack$sdcnt! call swap
	mvi b,3! call searchn$list! rnz
	;update olist entry with new dcnt value
	push h! call pack$sdcnt! pop h
	inx h! inx h! inx h! lxi d,packed$dcnt
	mvi c,3! call move! jmp fix$ol2
;
hl$eq$hl$and$de:
	mov a,l! ana e! mov l,a
	mov a,h! ana d! mov h,a
	ret
;
remove$drive:
	xchg! lda curdsk! mov c,a! lxi h,1
	call hlrotl
	mov a,l! cma! ana e! mov e,a
	mov a,h! cma! ana d! mov d,a
	xchg! ret
;
diskreset:
	lxi h,0! shld ntlog
	xra a! sta set$ro$flag
	lhld info
intrnldiskreset:
	xchg! lhld open$root! mov a,h! ora l! rz
	xchg! lda curdsk! push a! mvi b,0
dskrst1:
	mov a,l! rar! jc dskrst3
dskrst2:
	mvi c,1! call hlrotr! inr b
	mov a,h! ora l! jnz dskrst1
	pop a! sta curdsk
	lhld ntlog! xchg! lhld tlog
	mov a,l! ora e! mov l,a
	mov a,h! ora d! mov h,a! shld tlog
	inr a! ret
dskrst3:
	push b! push h! mov a,b! sta curdsk
	lhld rlog! call test$vector1! push a
	lhld rodsk! lda curdsk! call test$vector1! mov b,a
	pop h! lda set$ro$flag! ora b! ora h! sta check$disk
	lxi h,open$root! shld cur$pos
dskrst4:
	mvi b,1! call searchn$list! jnz dskrst6
	lda check$disk! ora a! jz dskrst5
	push h! call compare$pds! jz dskrst45
	pop h! xra a! xchg! jmp dskrst6
dskrst45:
	lhld ntlog! mov b,h! mov c,l
	lda curdsk! call set$cdisk1! shld ntlog
	pop h! jmp dskrst4
dskrst5:
	lhld info! call remove$drive! shld info
	ori 1
dskrst6:
	pop h! pop b! jnz dskrst2

	;error - olist item exists for another process
	;for removable drive to be reset
	pop a! sta curdsk! mov a,b! adi 41h ; A = ASCII drive
	lxi h,6! dad d! mov c,m! inx h! mov b,m ; BC = pdaddr
	push psw! call test$error$mode! pop d! jnz dskrst7
	mov a,d

	push b! push psw
	call rlr! lxi d,console! dad d! mov d,m ;D = console #
	lxi b,deniedmsg! call xprint
	pop psw! mov c,a! call conoutx
	mvi c,':'! call conoutx
	lxi b,cnsmsg! call xprint
	pop h! push h! lxi b,console! dad b
	mov a,m! adi '0'! mov c,a! call conoutx
	lxi b,progmsg! call xprint
	pop h! call dsplynm

dskrst7:
	pop h ;remove return addr from diskreset
	lxi h,0ffffh! shld aret ;flag the error
	ret
;
deniedmsg:
	db cr,lf,'Disk reset denied, Drive ',0
cnsmsg:
	db ' Console ',0
progmsg:
	db ' Program ',0
;
;
ENDIF
;
;	individual function handlers
func12:
	;return version number
IF MPM
	lxi h,0100h+dvers! jmp sthl$ret
ELSE
	mvi a,dvers! jmp sta$ret ;lret = dvers (high = 00)
ENDIF
;	ret ;jmp goback
;
func13:
IF MPM
	lhld dlog! shld info
	call diskreset! jz reset$all
	call reset$37
	jmp func13$cont
reset$all:
ENDIF
	;reset disk system - initialize to disk 0
	lxi h,0! shld rodsk! shld dlog
IF MPM
	shld rlog! shld tlog
func13$cont:
ENDIF
	xra a! STA SELDSK ;note that usrcode remains unchanged
	DCR A! STA CURDSK 
IF MPM
	xra a! call getmemseg ;A = mem seg tbl index
	ora a! rz
	inr a! rz
	call rlradr! lxi b,msegtbl-rlros! dad b
	add a! add a! mov e,a! mvi d,0! dad d
	mov h,m! mvi l,80h
	jmp intrnlsetDMA
ELSE
	lxi h,tbuff! shld dmaad ;dmaad = tbuff
        JMP SETDATA ;to data dma address
ENDIF
	;ret ;jmp goback
;
func14:	
	;select disk info
	CALL SET$SELDSK ; SELDSK = LINFO
IF MPM
	call curselect
	call rlr! lxi b,diskselect! dad b
	mov a,m! ani 0fh! rrc! rrc! rrc! rrc
	mov b,a! lda seldsk! ora b! rrc! rrc! rrc! rrc
	mov m,a! ret
ELSE
	JMP CURSELECT
ENDIF
	;ret ;jmp goback
;
func15:
	;open file
	call clrmodnum ;clear the module number
	call reselect
IF MPM
	xra a! sta make$flag
	call set$sdcnt
	lxi h,open$file! push h
	mvi a,0c9h! sta check$fcb4
	call check$fcb1
	pop h! lda high$ext! cpi 060h! jnz open$file
	call home! call set$end$dir
	jmp open$user$zero
open$file:
	lhld info! lda usrcode! mov m,a
	call set$sdcnt
ENDIF
	CALL RESET$CHKSUM$FCB ; SET INVALID CHECK SUM
	CALL CHECK$WILD ; CHECK FOR WILD CHARS IN FCB
	CALL GET$ATTS! ANI 1100$0000B ; A = ATTRIBUTES
IF MPM
 	cpi 1100$0000b! jnz att$ok
ENDIF
	ANI 0100$0000B ; MASK OFF UNLOCK MODE 
ATT$OK:
	STA HIGH$EXT
IF MPM
	mov b,a! ora a! rar! jnz att$set
	mvi a,80h
att$set:
	sta attributes! mov a,b
ENDIF
	ANI 80H! JNZ CALL$OPEN
	LDA USRCODE! ORA A! JZ CALL$OPEN 
	MVI A,0FEH! STA XDCNT+1! INR A! STA SEARCH$USER0
IF MPM
	sta sdcnt0+1
ENDIF
;
CALL$OPEN:
	CALL OPEN! CALL OPENX ; RETURNS IF UNSUCCESSFUL, A = 0
	LXI H,SEARCH$USER0! CMP M! RZ
	MOV M,A! LDA XDCNT+1! CPI 0FEH! RZ 
;
;	FILE EXISTS UNDER USER 0
;
IF MPM
	call swap
ENDIF
	CALL SET$DCNT$DBLK
	MVI A,0110$0000B! STA HIGH$EXT
OPEN$USER$ZERO:
	; SET FCB USER # TO ZERO
	LHLD INFO! MVI M,0
	MVI C,NAMLEN! CALL SEARCHI! CALL SEARCHN
	CALL OPEN1 ; ATTEMPT REOPEN UNDER USER ZERO
	CALL OPENX ; OPENX RETURNS ONLY IF UNSUCCESSFUL
	RET
OPENX:
	CALL END$OF$DIR! RZ
	; OPEN SUCCESSFUL
	POP H ; DISCARD RETURN ADDRESS
	; WAS FILE OPENED UNDER USER 0 AFTER UNSUCCESSFUL
	; ATTEMPT TO OPEN UNDER USER N
IF MPM
	LDA HIGH$EXT! CPI 060H! JZ OPENX00 ;YES
	; WAS FILE OPENED IN LOCKED MODE?
	ORA A! JNZ OPENX0 ; NO
	; DOES USER = ZERO?
	LHLD INFO! ORA M! JNZ OPENX0 ; NO
	; DOES FILE HAVE READ/ONLY ATTRIBUTE SET?
	CALL ROTEST! JNC OPENX0 ; NO
	; DOES FILE HAVE SYSTEM ATTRIBUTE SET?
	INX H! MOV A,M! RAL! JNC OPENX0 ; NO

	; FORCE OPEN MODE TO READ/ONLY MODE AND SET USER 0 FLAG
	; IF FILE OPENED IN LOCKED MODE, USER = 0, AND
	; FILE HAS READ/ONLY AND SYSTEM ATTRIBUTES SET

OPENX00:
ELSE
	LDA HIGH_EXT! CPI 060H! JNZ OPENX0 ; NO
ENDIF
	; IS FILE UNDER USER 0 A SYSTEM FILE ?
	MVI A,20H! STA ATTRIBUTES
	LHLD INFO! LXI D,10! DAD D
	MOV A,M! ANI 80H! JNZ OPENX0 ; YES - OPEN SUCCESSFUL
	; OPEN FAILS
	STA HIGH$EXT! JMP LRET$EQ$FF
OPENX0:
	CALL RESET$CHKSUM$FCB
	;
	;DOES DIR LBL EXIST?
IF MPM
	call get$dir$mode! ora a! jz openx1
ELSE
	CALL GET$DIR$MODE! ORA A! JZ SET$FCB$CKS$FLAG
ENDIF
	;YES - IS FILE PASSWORD PROTECTED FOR OPEN?
	PUSH A! CALL GET$XFCB! POP B
	ANI 0C0H! JZ OPENX1
	;YES - HAVE PASSWORDS BEEN ENABLES BY DIR LBL?
	MOV C,A! MOV A,B! ANI 80H! JZ OPENX1
	;YES - CHECK PASSWORD
	PUSH B! CALL CMP$PW! POP B! JZ OPENX1
	MOV A,C! ANI 40H! CZ CHK$PW1
	MVI A,080H! STA XFCB$READ$ONLY
OPENX1:
;
IF MPM
	call pack$sdcnt
	;is this file currently open?
	mvi b,3! call search$olist! jz openx04
openx01:
	;no - is olist full?
	lhld free$root! mov a,l! ora h! jnz openx03
	;yes - error
openx02:
	mvi a,11! jmp set$aret
openx03:
	;has process exceeded open file maximum?
	call count$opens! sub m! jc openx035
	;yes - error
openx034:
	mvi a,10! jmp set$aret
openx035:
	;create new olist element
	call create$olist$item
	jmp openx08
openx04:
	;do file attributes match?
	inx h! inx h
	lda attributes! ora m! cmp m! jnz openx06
	;yes - is open mode locked?
	ani 80h! jnz openx07
	;no - has this file been opened by this process?
	lhld prv$pos! shld cur$pos
	mvi b,5! call searchn$list! jnz openx01
openx05:
	;yes - increment open file count
	lxi d,8! dad d! inr m! jnz openx08
	;count overflow
	inx h! inr m! jmp openx08
openx06:
	;error - file opened by another process in imcompatible mode
	mvi a,5! jmp set$aret
openx07:
	;does this olist item belong to this process?
	dcx h! dcx h! push h
	call compare$pds
	pop h! jnz openx06 ; no - error
	jmp openx05 ; yes
openx08:; open ok
	;was file opened in unlocked mode?
	lda attributes! ani 40h! jz openx09 ; no
	;yes - return .olist$item in ranrec field of fcb
	call get$rra
	lxi d,cur$pos! mvi c,2! call move
openx09:
;
	call set$fcb$cks$flag
	lda make$flag! ora a! rnz
	call get$dir$mode
ELSE
	CALL SET$FCB$CKS$FLAG! MOV A,B
ENDIF
	;IS FILE ACCESS STAMPING ENABLED BY DIR LBL?
	ANI 40H! RZ
	CALL ENDOFDIR! RZ
	;YES - IS FILE READ/WRITE?
	CALL NOWRITE! RNZ ; CANNOT STAMP IF DISK READ ONLY
	;YES - UPDATE FCB ACCESS STAMP
OPENX2:
	CALL STAMP1
	JMP SEEK$COPY
;
func16:
	;close file
	call reselect
	CALL GET$ATTS! STA ATTRIBUTES
IF MPM
	lxi h,close00! push h
	mvi a,0c9h! sta check$fcb4
	call check$fcb1! pop h
	call set$sdcnt
	call getmodnum! ani 80h! jnz close01
	call close! jmp close02
close00:
	mvi a,6! jmp set$aret
close01:
	mvi a,0ffh! sta dont$close! call close1
close02:
ELSE
	CALL CHEK$FCB! MVI A,6! JNZ SET$ARET
	CALL CLOSE
ENDIF
	LDA LRET! INR A! RZ
	CALL FUNC48 ; FLUSH BUFFERS
	LDA ATTRIBUTES! ANI 1000$0000B! RNZ
IF MPM
	call pack$sdcnt
	;find olist item for this process & file
	mvi b,5! call search$olist! jnz close03
	;decrement open count
	push h! lxi d,8! dad d
	mov a,m! sui 1! mov m,a! inx h
	mov a,m! sbi 0! mov m,a! dcx h
	;is open count = 0ffffh
	call test$ffff! pop h! jnz close03
	;yes - remove file's olist entry
	shld file$id! call delete$item
	call reset$chksum$fcb
	;if unlocked file, remove file's locktbl entries
	call test$unlocked! jz close03
	lhld file$id! call remove$locks
close03:
ENDIF
	;
	;HAS FILE BEEN WRITTEN TO SINCE IT WAS OPENED?
	CALL GETMODNUM! ANI 40H! RZ
	;YES - IS FILE UPDATE STAMPING ENABLED BY DIR LBL?
	CALL GET$DIR$MODE! ANI 20H! RZ
	;YES - DOES XFCB EXIST FOR FILE?
	CALL GET$XFCB! RZ
	;YES - UPDATE XFCB UPDATE STAMP
	CALL STAMP2
	JMP SEEK$COPY
	;ret ;jmp goback
;
func17:
	;search for first occurrence of a file
	xchg! XRA A
CSEARCH:
	PUSH A
	mov a,m! cpi '?'! JNZ CSEARCH1 ; NO RESELECT IF ?
	CALL CURSELECT! MVI C,0! JMP CSEARCH3
CSEARCH1:
	CALL GETEXTA! MOV A,M! CPI '?'! JZ CSEARCH2
	CALL CLR$EXT! CALL CLRMODNUM
CSEARCH2:
	CALL RESELECTX
	MVI C,NAMLEN
CSEARCH3:
	POP A
IF NOT MPM
	LXI H,DIR$TO$USER
	PUSH H
ENDIF
	JNZ SEARCHN
	JMP SEARCH
	;ret ;jmp goback
;
func18:
	;search for next occurrence of a file name
IF MPM
	xchg! shld searcha
ELSE
	lhld searcha! shld info
ENDIF
;
	ORI 1! JMP CSEARCH
	;ret ;jmp goback
;
func19:
	;delete a file
	call reselectx
	jmp delete
	;ret ;jmp goback
;
func20:
	;read a file
	call reselect
	CALL CHECK$FCB
	jmp seqdiskread				;
	 ;jmp goback
;
func21:
	;write a file
	call reselect
	CALL CHECK$FCB
	jmp seqdiskwrite			;
	 ;jmp goback
;
func22:
	;make a file
	CALL GET$ATTS! STA ATTRIBUTES
	XRA A! STA FCB$EXISTS
	CALL CLR$EXT
	call clrmodnum ; FCB MOD = 0
	call reselect
	CALL RESET$CHKSUM$FCB
	CALL CHECK$WILD
	CALL SET$XDCNT ; RESET XDCNT FOR MAKE
IF MPM
	call set$sdcnt
ENDIF
	CALL OPEN ; VERIFY FILE DOES NOT ALREADY EXIST
	CALL RESET$CHKSUM$FCB
	CALL END$OF$DIR! JNZ FILE$EXISTS ; 
IF MPM
	lda attributes! ani 80h! rrc! jnz makex00
	mvi a,80h
makex00:
	sta make$flag
	lda sdcnt+1! inr a! jz makex01
	call pack$sdcnt
	mvi b,3! call search$olist! jz make$x02
makex01:
	lhld free$root! mov a,l! ora h! jz openx02
	jmp makex03
makex02:
	inx h! inx h
	lda makeflag! ana m! jz openx06
	dcx h! dcx h! call compare$pds! jz makex03
	lda makeflag! ral! jc openx06
makex03:
ENDIF
	;DO ANY FCBS FOR FILE EXIST IN THE DIRECTORY?
	LDA FCB$EXISTS! ORA A! JZ MAKEX04
	;YES - DOES DIR LBL REQUIRE PASSWORDS?
	CALL GET$DIR$MODE! ANI 80H! JZ MAKEX04
	;YES - DOES XFCB EXIST WITH MODE 1 OR 2 PASSWORD?
	CALL GET$XFCB! ANI 0C0H! JZ MAKEX04
	;YES - CHECK PASSWORD
	CALL CHK$XFCB$PASSWORD1
MAKEX04:
;
	CALL MAKE
	CALL RESET$CHKSUM$FCB
	CALL END$OF$DIR! RZ ; RETURN IF MAKE UNSUCCESSFUL
	;
	;DOES DIR LBL EXIST?
	CALL GET$DIR$MODE! ORA A! JZ MAKE4
	;YES - DOES XFCB ALREADY EXIST FOR FILE
	CALL GET$XFCB! JNZ MAKE000
	;NO - DOES DIR LBL INVOKE AUTO XFCB CREATE
	CALL GET$DIR$MODE! ANI 10H! JZ MAKE4
	MVI A,0FFH! STA MAKE$XFCB! CALL MAKE! JNZ MAKE00
	MVI C,NAMLEN! CALL SEARCH	
	CALL DELETE0! JMP LRET$EQ$FF
MAKE000:
	;YES - IS THIS FIRST FCB FOR FILE?
	LDA FCB$EXISTS! ORA A! JNZ MAKE4
MAKE00:
	CALL INIT$XFCB 
MAKE1:
	CALL SET$FCB$CKS$FLAG
	;DID USER SET PASSWORD ATTRIBUTE
	LDA ATTRIBUTES! ANI 40H! JZ MAKE3
	XCHG! LHLD XDMAAD! LXI B,8! DAD B! XCHG
	LDAX D! ANI 0E0H! JNZ MAKE2
	MVI A,80H
MAKE2:
	PUSH A! CALL GETXFCB1! POP A! MOV M,A
	CALL SET$PW! MOV M,B
MAKE3:
	CALL OPENX2
MAKE4:
IF MPM
	lda make$flag! sta attributes
	ani 40h! ral! sta high$ext
	lda sdcnt+1! inr a! jnz makexx02
	call sdcnt$eq$xdcnt! call pack$sdcnt
	jmp openx03
makexx02:
	call fix$olist$item! jmp openx1
ENDIF
	JMP SET$FCB$CKS$FLAG
	;ret ;jmp goback
FILE$EXISTS:
	MVI A,8! 
SET$ARET:
	MOV C,A! STA ARET+1! CALL LRET$EQ$FF
IF MPM
	call test$error$mode! jnz goback
ELSE
	LDA ERROR$MODE! INR A! RZ
	MVI A,40H! ADD C! STA XERR$ID
ENDIF
IF MPM
	mov a,c! sui 3
	mov l,a! mvi h,0! dad h
	lxi d,xerr$list! dad d
	mov e,m! inx h! mov d,m
	xchg! jmp report$err
ELSE
	LXI H,XERROR! JMP REPORT$ERR
ENDIF
;
func23:
	;rename a file
	call reselectx
	jmp rename
	;ret ;jmp goback
;
func24:
	;return the login vector
	lhld dlog! jmp sthl$ret			;
;	ret ;jmp goback
;
func25:
	;return selected disk number
	LDA SELDSK! jmp sta$ret			;
;	ret ;jmp goback
;
func26:
IF MPM
	;save DMA address in process descriptor
	lhld info
intrnlsetDMA:
	xchg
	call rlr! lxi b,disksetDMA! dad b
	mov m,e! inx h! mov m,d
ENDIF
	;set the subsequent dma address to info
	xchg! shld dmaad ;dmaad = info
        jmp setdata ;to data dma address
;
func27:
	;return the login vector address
	CALL XCURSELECT
	lhld alloca! jmp sthl$ret
;	ret ;jmp goback
;
IF MPM
func28:
	;write protect current disk
	;first check for open files on disk
	mvi a,0ffh! sta set$ro$flag
	lda seldsk! mov c,a! lxi h,0001h
	call hlrotl! call intrnldiskreset
	jmp set$ro
ELSE
func28:	equ	set$ro				;
	;write protect current disk
	;ret ;jmp goback
ENDIF
;
func29:
	;return r/o bit vector
	lhld rodsk! jmp sthl$ret		;
;	ret ;jmp goback
;
func30:
	;set file indicators
	CALL CHECK$WRITE
	CALL CHECK$WILD
	call reselectx
	CALL CHK$PASSWORD
	call indicators
	jmp copy$dirloc ;lret=dirloc
	;ret ;jmp goback
;
func31:
	;return address of disk parameter block
	CALL XCURSELECT
	lhld dpbaddr
sthl$ret:
 	shld aret
	ret ;jmp goback
;
func32:
	;set user code
        lda linfo! cpi 0ffh! jnz setusrcode
		;interrogate user code instead
		lda usrcode! jmp sta$ret ;lret=usrcode	
;		ret ;jmp goback
	setusrcode:
		ANI 0FH! sta usrcode
IF MPM
		push a
		call rlr! lxi b,diskselect! dad b
		pop b
		mov a,m! ani 0f0h! ora b! mov m,a
ENDIF
		ret ;jmp goback
;
func33:
	;random disk read operation
	call reselect
	CALL CHECK$FCB
	jmp randiskread ;to perform the disk read
	;ret ;jmp goback
;
func34:
	;random disk write operation
	call reselect
	CALL CHECK$FCB
	jmp randiskwrite ;to perform the disk write
	;ret ;jmp goback
;
func35:
	;return file size (0-65536)
	call reselect
	CALL CHECK$WILD
	jmp getfilesize
	;ret ;jmp goback
;
func36:	equ setrandom
	;set random record
	;ret ;jmp goback
func37:
;
IF MPM
	call diskreset
reset$37:
	lhld info
ELSE
	XCHG
ENDIF
	mov a,l! cma! mov e,a! mov a,h! cma
	lhld dlog! ana h! mov d,a! mov a,l! ana e
	mov e,a! lhld rodsk! xchg! shld dlog
IF MPM
	push h! call hl$eq$hl$and$de
ELSE
	mov a,l! ana e! mov l,a
	mov a,h! ana d! mov h,a
ENDIF
	shld rodsk! 
;
IF MPM
	pop h! xchg! lhld rlog! call hl$eq$hl$and$de! shld rlog
ENDIF
	LHLD DLOG! LDA CURDSK! CALL TEST$VECTOR1
	RNZ ; RETURN IF CURDSK NOT RESET
	MVI A,0FFH! STA CURDSK
	; FORCE SELECT CALL IN NEXT CURSELECT
	RET
IF MPM
;
func38:				; access drive
	lxi h,packed$dcnt! mvi a,0ffh
	mov m,a! inx h! mov m,a! inx h! mov m,a
	xra a! xchg! lxi b,16
acc$drv0:
	dad h! adc b! dcr c! jnz acc$drv0
	ora a! rz
	sta mult$cnt! dcr a! push a
	call acc$drv02
	pop a! jmp openx02 ; insufficient free lock list items
acc$drv02:
	call check$free! pop h ; discard return addr, free space exists
	call count$opens! pop b! add b! jc openx034
	sub m! jnc openx034 ; openmax exceeded
	lhld info! lda curdsk! push a! mvi a,16
acc$drv1:
	dcr a! dad h! jc acc$drv2
acc$drv15:
	ora a! jnz acc$drv1
	pop a! sta curdsk! ret
acc$drv2:
	push a! push h! sta curdsk
	call create$olist$item
	pop h! pop a! jmp acc$drv15
;
func39:				; free drive
	lhld open$root! mov a,h! ora l! rz
	xra a! sta incr$pdcnt! inr a! sta free$mode
	lhld info! mov a,h! cmp l! jnz free$drv1
	inr a! jnz free$drv1
	sta free$mode! call free$files! jmp free$drv3
free$drv1:
	lda curdsk! push a! mvi a,16
free$drv2:
	dcr a! dad h! jc free$drv4
free$drv25:
	ora a! jnz free$drv2
	pop a! sta curdsk
free$drv3:
	lda incr$pdcnt! ora a! rz
	lda pdcnt! jmp chk$olist1
free$drv4:
	push a! push h! sta curdsk
	call free$files
	pop h! pop a! jmp free$drv25
ELSE
func38 	equ	func$ret
func39	equ	func$ret
ENDIF
;
func40:
	;random disk write with zero fill of unallocated block
	call reselect
	CALL CHECK$FCB
	mvi a,2! sta seqio
	mvi	c,false
	call	rseek1
	cz	diskwrite	;if seek successful
	ret
;
func41	equ	func$ret	;test & write
IF MPM
func42:				;record lock
	mvi a,0ffh! sta lock$unlock! jmp lock
func43:				;record unlock
	xra a! sta lock$unlock! jmp lock
ELSE
func42	equ	func$ret	;record lock
func43	equ	func$ret	;record unlock
ENDIF
;
func44:				;set multi-sector count
	mov a,e! ora a! jz lret$eq$ff
	cpi 17! jnc lret$eq$ff
	sta mult$cnt
IF MPM
	mov d,a
	call rlr! lxi b,mult$cnt$off! dad b
	mov m,d
ENDIF
	ret
;
func45:				;set BDOS error mode
IF MPM
	call rlr! lxi b,pname+4! dad b
	call set$pflag
	mov m,a! inx h
	call set$pflag
	mov m,a! ret
;
set$pflag:
	mov a,m! ani 7fh! inr e! rnz
	ori 80h! ret
ELSE
	mov a,e! sta error$mode
ENDIF
	ret
;
func46:				;get free space
	;perform temporary select of specified drive
	call tmpselect
	lhld alloca! xchg ; DE = alloc vector addr
	call get$nalbs ; get # alloc blocks
	; HL = # of allocation vector bytes
	; count # of true bits in allocation vector
	lxi b,0 ; BC = true bit accumulator
gsp1:	ldax d
gsp2:	ora a! jz gsp4
gsp3:	rar! jnc gsp3
	inx b! jmp gsp2
gsp4:	inx d! dcx h
	mov a,l! ora h! jnz gsp1
	;HL = 0 when allocation vector processed
	;compute maxall + 1 - BC
	lhld maxall! inx h
	mov a,l! sub c! mov l,a
	mov a,h! sbb b! mov h,a
	;HL = # of available blocks on drive
	lda blkshf! mov c,a! xra a
	call shl3bv
	;AHL = # of available sectors on drive
	;store AHL in beginning of current DMA
	xchg! lhld xdmaad! mov m,e! inx h
	mov m,d! inx h! mov m,a
	ret
;
IF MPM
func47	equ	func$ret
ELSE
func47: 			;chain to program
	;save user# and seldsk in location 0004h
	lda usrcode
	add a! add a! add a! add a! mov b,a
	lda seldsk! ora b! sta base+0004h
	mvi a,0ffh! sta chain$flg! jmp REBOOTX
ENDIF
;
func48:				;flush buffers
	lxi h,diocomp! push h
	lxi b,0ffffh! call setdmaf
	pop h! jmp setdata
;
IF MPM
func49	equ	func$ret
ELSE
func49:				;ccp chain query
	lxi h,chain$flg! mov a,m! ora a! rz
	mvi m,0! jmp lret$eq$ff
ENDIF
;
IF MPM
func50	equ	func$ret
ELSE
func50:				;direct bios call
	;DE -> function (1 byte)
	;      BC value (2 bytes)
	;      DE value (2 bytes)
	xchg
	mov a,m! inx h
	mov c,m! inx h! mov b,m! inx h
	mov e,m! inx h! mov d,m
	mov l,a! add a! add l

	lxi h,bios

	add l! mov l,a!
	mvi a,0! adc h! mov h,a! pchl
ENDIF
;
func100:			;set directory label
	;DE -> .fcb
	;      drive location
	;      name & type fields user's discretion
	;      extent field definition
	;      bit 1 (80h): enable passwords on drive
	;      bit 2 (40h): enable file access 	
	;      bit 3 (20h): enable file update stamping
	;      bit 8 (01h): assign new password to dir lbl
	call reselectx
	call check$write
	;does dir lbl exist on drive?
	lhld info! mvi m,20h! mvi c,1
	call set$xdcnt! call search! jnz sdl1
	;no - make one
	mvi a,0ffh! sta make$xfcb
	call make! rz ;no dir space
	call init$xfcb! call stamp1 ; create date & time stamp
sdl1:
	;update date & time stamp
	call stamp2
	;verify password - new dir lbl falls through
	call getxfcb1! call chk$xfcb$password1
	lxi b,0! call init$xfcb0
	;set dir lbl dta in extent field
	ldax d! ori 1h! mov m,a
	;low bit of dir lbl data set to indicate dir lbl exists
	;update drive's dir lbl vector element
	push h! lhld drvlbla! mov m,a! pop h
sdl2:
	;assign new password to dir lbl or xfcb?
	ldax d! ani 1! jz seek$copy
	;yes - new password field is in 2nd 8 bytes of dma
	lxi d,8! call adjust$dmaad
	call set$pw! mov m,b
	lxi d,-8! call adjust$dmaad
	jmp seek$copy
;
func101:			;return directory label data
	;perform temporary select of specified drive
	call tmpselect
	call get$dir$mode! jmp sta$ret
;
func102:			;read file xfcb
	call reselectx
	call check$wild
	;does xfcb exist for file?
	call getxfcb! mvi a,0ffh! jz sta$ret
	;yes - copy xfcb to user's fcb
	lhld info! mvi c,nxtrec! jmp move ;ret
;
func103:			;write or update file xfcb
	call reselectx
	call check$wild
	;does xfcb exist for file?
	call set$xdcnt
	call getxfcb! jnz wxfcb1
	;no - does dir lbl exist in directory?
	call get$dir$mode
	ora a! mvi a,0ffh! jz sta$ret
	;yes - does file exist in directory?
	sta make$xfcb
	mvi c,extnum! call search! rz
	;yes - attempt to make xfcb for file
	call make! rz ; no dir space
	;initialize xfcb
	call init$xfcb 
wxfcb1:
	;verify password - new xfcb falls through
	call chk$xfcb$password
	;set xfcb options data
	push h! call getexta! pop d! xchg
	mov a,m! ora a! jnz wxfcb2
	ldax d! ani 1! jz seek$copy
wxfcb2:
	ldax d! ani 0e0h! jnz wxfcb3
	mvi a,80h
wxfcb3:
	mov m,a! jmp sdl2
;
func104:			;set current date and time
IF MPM
	call get$stamp$add
	call copy$stamp
	mvi m,0! ret
ELSE
	lxi h,stamp
	jmp copy$stamp
ENDIF
;
func105:			;get current date and time
IF MPM
	call get$stamp$add
ELSE
	lxi h,stamp
ENDIF
	xchg
copy$stamp:
	mvi c,4! jmp move ;ret
;
IF MPM
get$stamp$add:
	call rlradr! lxi b,-5! dad b
	ret
ENDIF
;
func106:			;set default password
IF MPM
	call get$df$pwa! inr a! rz
	lxi b,7! dad b
ELSE
	LXI H,DF$PASSWORD+7
ENDIF
	xchg! lxi b,8! push h
	jmp set$pw0
;
func107:			;return serial number
IF MPM
	lhld sysdat! mvi l,181
ELSE
	lxi h,serial
ENDIF
	xchg! mvi c,6! jmp move
;
GOBACK0:
	XRA A! STA RETURN$FFFF
	LXI H,0FFFFH! SHLD ARET
goback:
	;arrive here at end of processing to return to user
	lda resel! ora a! jz retmon
		;reselection may have taken place
		LDA COMP$FCB$CKS! ORA A! CNZ SET$CHKSUM$FCB
		LDA XFCB$READ$ONLY! ORA A! JZ GOBACK05
		LHLD INFO! LXI D,7! DAD D
		ORA M! MOV M,A
	GOBACK05:
		CALL GETEXTA! LDA HIGH$EXT! CPI 60H! JNZ GOBACK1
		LXI D,-4! DAD D! MVI A,80H
	GOBACK1:
		ORA M! MOV M,A
		LDA ACTUAL$RC! ORA A! JZ GOBACK2
		CALL GETRCNTA! ORA M! MOV M,A
	GOBACK2:
		lhld info! mvi m,0 ;fcb(0)=0
		lda fcbdsk! ora a! jz retmon
		;restore disk number
		mov m,a ;fcb(0)=fcbdsk
		lda olddsk! STA SELDSK
;
;	return from the disk monitor
retmon:
	lhld entsp! sphl
	lhld aret! mov a,l! mov b,h! ret
;
;
;	data areas
;
;	initialized data
efcb:	db	empty	;0e5=available dir entry
rodsk:	dw	0	;read only disk vector
dlog:	dw	0	;logged-in disks
IF MPM
rlog:	dw	0	;removeable logged-in disks
tlog:	dw	0	;removeable disk test login vector
ntlog:	dw	0	;new tlog vector
rem$drv: db	0	;curdsk removable drive switch
			;0 = permanent drive, 1 = removable drive
ENDIF
IF NOT BNKBDOS
xdmaad	equ	$
ENDIF
dmaad:	dw	tbuff	;initial dma address
IF NOT MPM
buffa:	ds	word	;pointer to directory dma address
ENDIF
;
;	curtrka - alloca are set upon disk select
;	(data must be adjacent, do not insert variables)
;	(address of translate vector, not used)
cdrmaxa:ds	word	;pointer to cur dir max value
curtrka:ds	word	;current track address
curreca:ds	word	;current record address
DRVLBLA:DS	WORD	;CURRENT DRIVE LABEL BYTE ADDRESS
dpbaddr:ds	word	;current disk parameter block address
checka:	ds	word	;current checksum vector address
alloca:	ds	word	;current allocation vector address
addlist	equ	$-DPBADDR	;address list size
;
;	sectpt - offset obtained from disk parm block at dpbaddr
;	(data must be adjacent, do not insert variables)
sectpt:	ds	word	;sectors per track
blkshf:	ds	byte	;block shift factor
blkmsk:	ds	byte	;block mask
extmsk:	ds	byte	;extent mask
maxall:	ds	word	;maximum allocation number
dirmax:	ds	word	;largest directory number
dirblk:	ds	word	;reserved allocation bits for directory
chksiz:	ds	word	;size of checksum vector
offset:	ds	word	;offset tracks at beginning
dpblist	equ	$-sectpt	;size of area
;
;	local variables
RETURN$FFFF:	DS	BYTE	;SEL ERR FLAG FOR FXS 27 & 31
tranv:	ds	word	;address of translate vector
lock$unlock:
make$flag:
rmf:	ds	byte	;read mode flag for open$reel
incr$pdcnt:
dirloc:	ds	byte	;directory flag in rename, etc.
fcb$exists:
	ds	byte	;Make FCB exists flag
free$mode:
seqio:	ds	byte	;1 if sequential i/o
linfo:	ds	byte	;low(info)
dminx:	ds	byte	;local for diskwrite
searchl:ds	byte	;search length
searcha:ds	word	;search address
ACTUAL$RC:
	DS	BYTE	;DIRECTORY EXT RECORD COUNT
SAVE$XFCB:
	DS	BYTE	;SEARCH XFCB SAVE FLAG
single:	ds	byte	;set true if single byte allocation map
SELDSK: DS	BYTE	;CURRENTLY SELECTED DISK 
olddsk:	ds	byte	;disk on entry to bdos
rcount:	ds	byte	;record count in current fcb
extval:	ds	byte	;extent number and extmsk
SAVE$MOD:
	DS	BYTE	;OPEN$REEL MODULE SAVE FIELD
SAVE$EXT:
	DS	BYTE	;OPEN$REEL EXTENT SAVE FIELD
vrecord:ds	BYTE	;current virtual record
arecord:ds	word	;current actual record
	DS	BYTE
;			SHELL FCB SAVE AREA
SAVE$RANR:	DB	0,0,0	;RANDOM RECORD SAVE AREA
arecord1:	ds	word	;current actual block# * blkmsk
IF NOT MPM
MULT$CNT:	DB	1	;MULTI-SECTOR COUNT
ERROR$MODE 	DB	0	;BDOS ERROR MODE
ENDIF
ATTRIBUTES:	DB	0	;MAKE ATTRIBUTE HOLD AREA
IF NOT MPM
CHAIN$FLG:	DB	0	;CHAIN FLAG
STAMP:		DB	0FFH,0FFH,0FFH,0FFH
ENDIF
;
;******** Following variable order critical *****************
IF MPM
mult$cnt:	db	1	;multi-sector count
pdcnt:		db	0	;process descriptor count
ENDIF
HIGH$EXT:	DB	0	;FCB HIGH EXT BITS
XFCB$READ$ONLY:	DB	0	;XFCB READ ONLY FLAG
CURDSK:		DB	0	;CURRENT DISK
IF MPM
;				MP/M VARIABLES	*
packed$dcnt:	db	0,0,0			;
pdaddr:		dw	0			;
;************************************************************
cur$pos:	dw	0			;
prv$pos:	dw	0			;
sdcnt:		dw	0   	 		;
sdblk:		dw	0   			;
sdcnt0:		dw	0			;
sdblk0:		dw	0			;
dont$close:	db	0			;
open$cnt:			;MP/M temp variaable for open
lock$cnt:	dw	0	;MP/M temp variable for lock
file$id:	dw	0	;MP/M temp variable for lock
deleted$files:	db	0
lock$shell:	db	0
lock$sp:	dw	0
set$ro$flag:	db	0
check$disk:	db	0
flushed:	db	0
fcb$cks$valid:  db	0
;				MP/M VARIABLES  *
ENDIF
;
;	local variables for directory access
dptr:	ds	byte	;directory pointer 0,1,2,3
XDCNT:  DS	WORD	;EMPTY DIRECTORY DCNT
XDBLK:  DS	WORD	;EMPTY DIRECTORY BLOCK
dcnt:	ds	word	;directory counter 0,1,...,dirmax
DBLK:	DS	WORD	;DIRECTORY BLOCK INDEX
USER0$PASS:
	DS	BYTE	;SEARCH USER 0 PASS FLAG
;
;	local variables initialized by bdos at entry
;
resel:		ds	byte	;reselection flag
fcbdsk:		ds	byte	;disk named in fcb
COMP$FCB$CKS:	DS	BYTE	;COMPUTE FCB CHECKSUM FLAG
SEARCH$USER0:	DS	BYTE	;SEARCH USER 0 FOR FILE (OPEN)
MAKE$XFCB:	DB	BYTE	;MAKE & SEARCH XFCB FLAG
FIND$XFCB:	DB	BYTE	;SEARCH FIND XFCB FLAG
;
DF$PASSWORD:	DW	0,0,0,0
IF MPM
		dw	0,0,0,0
		dw	0,0,0,0
		dw	0,0,0,0
		dw	0,0,0,0
		dw	0,0,0,0
		dw	0,0,0,0
		dw	0,0,0,0
		dw	0,0,0,0
		dw	0,0,0,0
		dw	0,0,0,0
		dw	0,0,0,0
		dw	0,0,0,0
		dw	0,0,0,0
		dw	0,0,0,0
		dw	0,0,0,0
ENDIF
;
IF MPM
	ds	192
last:
	org	(((last-base)+255) AND 0ff00h) - 192

	;	BNKBDOS patch area

	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0,0,0,0,0

free$root:	dw	$-$			;
open$root:	dw	0			;
lock$root:	dw	0			;
lock$max:	db	0			;
open$max:	db	0			;
;
;	bios access table
bios	equ	$		;base of the bios jump table
bootf	equ	bios		;cold boot function
wbootf	equ	bootf+3		;warm boot function
constf	equ	wbootf+3	;console status function
coninf	equ	constf+3	;console input function
conoutf	equ	coninf+3	;console output function
listf	equ	conoutf+3	;list output function
punchf	equ	listf+3		;punch output function
readerf	equ	punchf+3	;reader input function
homef	equ	readerf+3	;disk home function
seldskf	equ	homef+3		;select disk function
settrkf	equ	seldskf+3	;set track function
setsecf	equ	settrkf+3	;set sector function
setdmaf	equ	setsecf+3	;set dma function
readf	equ	setdmaf+3	;read disk function
writef	equ	readf+3		;write disk function
liststf	equ	writef+3	;list status function
sectran	equ	liststf+3	;sector translate
;
ENDIF
	end
