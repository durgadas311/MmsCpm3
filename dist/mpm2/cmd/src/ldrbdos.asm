	title	'MP/M II V2.0  Loader BDOS'

;*****************************************************************
;*****************************************************************
;**                                                             **
;**   B a s i c    D i s k   O p e r a t i n g   S y s t e m    **
;**            I n t e r f a c e   M o d u l e                  **
;**                                                             **
;*****************************************************************
;*****************************************************************
;
;	Copyright (c) 1978, 1979, 1980, 1981
;	Digital Research
;	Box 579, Pacific Grove
;	California
;
;  Revised:
;    14 Sept 81 by Thomas Rolander
;*/

on	equ	0ffffh
off	equ	00000h
test	equ	off
ldr	equ	on
;
	if	test
	org	3c00h
	else
	if	ldr
	org	0d00h
	else
	org	0800h
	endif
	endif
;	bios value defined at end of module
;
ssize	equ	24		;24 level stack
;
;	low memory locations
reboot	equ	0000h		;reboot system
ioloc	equ	0003h		;i/o byte location
bdosa	equ	0006h		;address field of jmp BDOS
;
;	bios access constants
bios	equ	1700H
bootf	equ	bios+3*0	;cold boot function
wbootf	equ	bios+3*1	;warm boot function
constf	equ	bios+3*2	;console status function
coninf	equ	bios+3*3	;console input function
conoutf	equ	bios+3*4	;console output function
listf	equ	bios+3*5	;list output function
punchf	equ	bios+3*6	;punch output function
readerf	equ	bios+3*7	;reader input function
homef	equ	bios+3*8	;disk home function
seldskf	equ	bios+3*9	;select disk function
settrkf	equ	bios+3*10	;set track function
setsecf	equ	bios+3*11	;set sector function
setdmaf	equ	bios+3*12	;set dma function
readf	equ	bios+3*13	;read disk function
writef	equ	bios+3*14	;write disk function
liststf	equ	bios+3*15	;list status function
sectran	equ	bios+3*16	;sector translate
;
;	equates for non graphic characters
ctlc	equ	03h	;control c
ctle	equ	05h	;physical eol
ctlh	equ	08h	;backspace
ctlp	equ	10h	;prnt toggle
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
	db	0,0,0,0,0,0
;
;	enter here from the user's program with function number in c,
;	and information address in d,e
	jmp	bdose	;past parameter block
;
;	************************************************
;	*** relative locations 0009 - 000e           ***
;	************************************************
pererr:	dw	persub	;permanent error subroutine
selerr:	dw	selsub	;select error subroutine
roderr:	dw	rodsub	;ro disk error subroutine
roferr:	dw	rofsub	;ro file error subroutine
;
;
bdose:	;arrive here from user programs
	xchg! shld info! xchg ;info=DE, DE=info
	mov a,e! sta linfo ;linfo = low(info) - don't equ
	lxi h,0! shld aret ;return value defaults to 0000
	;save user's stack pointer, set to local stack
	dad sp! shld entsp ;entsp = stackptr
	lxi sp,lstack ;local stack setup
	xra a! sta fcbdsk! sta resel ;fcbdsk,resel=false
	lxi h,goback ;return here after all functions
	push h ;jmp goback equivalent to ret
	mov a,c! cpi nfuncs! rnc ;skip if invalid #
	mov c,e ;possible output character to C
	lxi h,functab! mov e,a! mvi d,0 ;DE=func, HL=.ciotab
	dad d! dad d! mov e,m! inx h! mov d,m ;DE=functab(func)
	xchg! pchl ;dispatched
;
;	dispatch table for functions
functab:
	dw	bootf, func1, func2, func3
	dw	func4, func5, func6, func7
	dw	func8, func9, func10,func11
diskf	equ	($-functab)/2	;disk funcs
	dw	func12,func13,func14,func15
	dw	func16,func17,func18,func19
	dw	func20,func21,func22,func23
	dw	func24,func25,func26,func27
	dw	func28,func29,func30,func31
	dw	func32,func33,func34,func35
	dw	func36
nfuncs	equ	($-functab)/2
;
return:
	ret

;func1:
func1	equ	return
	;return console character with echo
;
func2:
	;write console character with tab expansion
	jmp tabout
	;ret ;jmp goback
;
;func3:
func3	equ	return
	;return reader character
;
;func4:
func4	equ	return
	;write punch character
;
;func5:
func5	equ	return
	;write list character
	;write to list device
;
;func6:
func6	equ	return
	;direct console i/o - read if 0ffh
;
;func7:
func7	equ	return
	;return io byte
;
;func8:
func8	equ	return
	;set i/o byte
;
func9:
	;write line until $ encountered
	lhld info! mov c,l! mov b,h ;BC=string address
	jmp print ;out to console
	;ret ;jmp goback
;
;func10:
func10	equ	return
	;read a buffered console line
;
;func11:
func11	equ	return
	;check console status
;
;	error subroutines
persub:	;report permanent error
	lxi h,permsg! call errflg ;to report the error
	cpi ctlc! jz reboot ;reboot if response is ctlc
	ret ;and ignore the error
;
selsub:	;report select error
	lxi h,selmsg! jmp wait$err ;wait console before boot
;
rodsub:	;report write to read/only disk
	lxi h,rodmsg! jmp wait$err ;wait console
;
rofsub:	;report read/only file
	lxi h,rofmsg ;drop through to wait for console
;
wait$err:
	;wait for response before boot
	call errflg! jmp reboot
;
errflg:
	;report error to console, message address in HL
	push h! call crlf ;stack mssg address, new line
	lda curdsk! adi 'A'! sta dskerr ;current disk name
	lxi b,dskmsg! call print ;the error message
	pop b! call print ;error mssage tail
	jmp coninF ;to get the input character
	; NOTE: the conin above has become coninf !
	;ret
;
;	error messages
dskmsg:	db	'Bdos Err On '
dskerr:	db	' : $'	;filled in by errflg
permsg:	db	'Bad Sector$'
selmsg:	db	'Select$'
rofmsg:	db	'File '
rodmsg:	db	'R/O$'
;
;
;	console handlers
;conin:
	;read console character to A
;
;conech:
	;read character with echo
;
;echoc:
	;echo character if graphic
;
conbrk:	;check for character ready
	lda kbchar! ora a! jnz conb1 ;skip if active kbchar
		;no active kbchar, check external break
		call constf! ani 1! rz ;return if no char ready
		;character ready, read it
		call coninf ;to A
		cpi ctls! jnz conb0 ;check stop screen function
		;found ctls, read next character
		call coninf ;to A
		cpi ctlc! jz reboot ;ctlc implies re-boot
		;not a reboot, act as if nothing has happened
		xra a! ret ;with zero in accumulator
	conb0:
		;character in accum, save it
		sta kbchar
	conb1:
		;return with true set in accumulator
		mvi a,1! ret
;
conout:
	;compute character position/write console char from C
	;compcol = true if computing column position
	lda compcol! ora a! jnz compout
		;write the character, then compute the column
		;write console character from C
		push b! call conbrk ;check for screen stop function
		pop b! push b ;recall/save character
		call conoutf ;externally, to console
		pop b! push b ;recall/save character
		;may be copying to the list device
		lda listcp! ora a! cnz listf ;to printer, if so
		pop b ;recall the character
	compout:
		mov a,c ;recall the character
		;and compute column position
		lxi h,column ;A = char, HL = .column
		cpi rubout! rz ;no column change if nulls
		inr m ;column = column + 1
		cpi ' '! rnc ;return if graphic
		;not graphic, reset column position
		dcr m ;column = column - 1
		mov a,m! ora a! rz ;return if at zero
		;not at zero, may be backspace or end line
		mov a,c ;character back to A
		cpi ctlh! jnz notbacksp
			;backspace character
			dcr m ;column = column - 1
			ret
		notbacksp:
			;not a backspace character, eol?
			cpi lf! rnz ;return if not
			;end of line, column = 0
			mvi m,0 ;column = 0
		ret
;
;ctlout:
	;send C character with possible preceding up-arrow
;
tabout:
	;expand tabs to console
	mov a,c! cpi tab! jnz conout ;direct to conout if not
		;tab encountered, move to next tab position
	tab0:
		mvi c,' '! call conout ;another blank
		lda column! ani 111b ;column mod 8 = 0 ?
		jnz tab0 ;back for another if not
	ret
;
;pctlh:
	;send ctlh to console without affecting column count
;
;backup:
	;back-up one screen position
;
;crlfp:
	;print #, cr, lf for ctlx, ctlu, ctlr functions
;
crlf:
	;carriage return line feed sequence
	mvi c,cr! call conout! mvi c,lf! jmp conout
;
print:
	;print message until M(BC) = '$'
	ldax b! cpi '$'! rz ;stop on $
		;more to print
		inx b! push b! mov c,a ;char to C
		call tabout ;another character printed
		pop b! jmp print
;
;read:	;read to info address (max length, current length, buffer)
;
;	data areas
;
compcol:db	0	;true if computing column position
strtcol:db	0	;starting column position after read
column:	db	0	;column position
listcp:	db	0	;listing toggle
kbchar:	db	0	;initial key char = 00
entsp:	ds	2	;entry stack pointer
	ds	ssize*2	;stack size
lstack:
;	end of Basic I/O System
;
;*****************************************************************
;*****************************************************************
;
;	common values shared between bdosi and bdos
usrcode:db	0	;current user number
curdsk:	db	0	;current disk number
info:	ds	2	;information address
aret:	ds	2	;address value to return
lret	equ	aret	;low(aret)
;
;*****************************************************************
;*****************************************************************
;**                                                             **
;**   B a s i c    D i s k   O p e r a t i n g   S y s t e m    **
;**                                                             **
;*****************************************************************
;*****************************************************************
;
dvers	equ	20h	;version 2.0
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
goerr:
	;HL = .errorhandler, call subroutine
	mov e,m! inx h! mov d,m ;address of routine in DE
	xchg! pchl ;to subroutine
;
per$error:
	;report permanent error to user
	lxi h,pererr! jmp goerr
;
sel$error:
	;report select error
	lxi h,selerr! jmp goerr
;
rod$error:
	;report read/only disk error
	lxi h,roderr! jmp goerr
;
rof$error:
	;report read/only file error
	lxi h,roferr! jmp goerr
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
	lda curdsk! mov c,a ;current disk# to c
	;lsb of e = 0 if not yet logged - in
	call seldskf ;HL filled by call
	;HL = 0000 if error, otherwise disk headers
	mov a,h! ora l! rz ;return with 0000 in HL and z flag
		;disk header block address in hl
		mov e,m! inx h! mov d,m! inx h ;DE=.tran
		shld cdrmaxa! inx h! inx h ;.cdrmax
		shld curtrka! inx h! inx h ;HL=.currec
		shld curreca! inx h! inx h ;HL=.buffa
		;DE still contains .tran
		xchg! shld tranv ;.tran vector
		lxi h,buffa ;DE= source for move, HL=dest
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
	mvi a,true! ora a! ret ;select disk function ok
;
home:
	;move to home position, then offset to start of dir
	call homef ;move to track 00, sector 00 reference
	lxi h,offset! mov c,m! inx h! mov b,m! call settrkf
	;first directory position selected
	xra a ;constant zero to accumulator
	lhld curtrka! mov m,a! inx h! mov m,a ;curtrk=0000
	lhld curreca! mov m,a! inx h! mov m,a ;currec=0000
	;curtrk, currec both set to 0000
	ret
;
rdbuff:
	;read buffer and check condition
	call readf ;current drive, track, sector, dma
	ora a! jnz per$error
	ret
;
wrbuff:
	;write buffer and check condition
	; ...
	ret
;
seek:
	;seek the track given by arecord (actual record)
	;local equates for registers
	arech  equ b! arecl  equ c ;arecord = BC
	crech  equ d! crecl  equ e ;currec  = DE
	ctrkh  equ h! ctrkl  equ l ;curtrk  = HL
	tcrech equ h! tcrecl equ l ;tcurrec = HL
	;load the registers from memory
	lxi h,arecord! mov arecl,m! inx h! mov arech,m
	lhld curreca ! mov crecl,m! inx h! mov crech,m
	lhld curtrka ! mov a,m! inx h! mov ctrkh,m! mov ctrkl,a
	;loop while arecord < currec
	seek0:
		mov a,arecl! sub crecl! mov a,arech! sbb crech
		jnc seek1 ;skip if arecord >= currec
			;currec = currec - sectpt
			push ctrkh! lhld sectpt
			mov a,crecl! sub l! mov crecl,a
			mov a,crech! sbb h! mov crech,a
			pop ctrkh
			;curtrk = curtrk - 1
			dcx ctrkh
		jmp seek0 ;for another try
	seek1:
	;look while arecord >= (t:=currec + sectpt)
		push ctrkh
		lhld sectpt! dad crech ;HL = currec+sectpt
		mov a,arecl! sub tcrecl! mov a,arech! sbb tcrech
		jc seek2 ;skip if t > arecord
			;currec = t
			xchg
			;curtrk = curtrk + 1
			pop ctrkh! inx ctrkh
		jmp seek1 ;for another try
	seek2:	pop ctrkh
	;arrive here with updated values in each register
	push arech! push crech! push ctrkh ;to stack for later
	;stack contains (lowest) BC=arecord, DE=currec, HL=curtrk
	xchg! lhld offset! dad d ;HL = curtrk+offset
	mov b,h! mov c,l! call settrkf ;track set up
	;note that BC - curtrk is difference to move in bios
	pop d ;recall curtrk
	lhld curtrka! mov m,e! inx h! mov m,d ;curtrk updated
	;now compute sector as arecord-currec
	pop crech ;recall currec
	lhld curreca! mov m,crecl! inx h! mov m,crech
	pop arech ;BC=arecord, DE=currec
	mov a,arecl! sub crecl! mov arecl,a
	mov a,arech! sbb crech! mov arech,a
	lhld tranv! xchg ;BC=sector#, DE=.tran
	call sectran ;HL = tran(sector)
	mov c,l! mov b,h ;BC = tran(sector)
	jmp setsecf ;sector selected
	;ret
;
;	file control block (fcb) constants
empty	equ	0e5h	;empty directory entry
lstrec	equ	127	;last record# in extent
recsiz	equ	128	;record size
fcblen	equ	32	;file control block size
dirrec	equ	recsiz/fcblen	;directory elts / record
dskshf	equ	2	;log2(dirrec)
dskmsk	equ	dirrec-1
fcbshf	equ	5	;log2(fcblen)
;
extnum	equ	12	;extent number field
maxext	equ	31	;largest extent number
ubytes	equ	13	;unfilled bytes field
modnum	equ	14	;data module number
maxmod	equ	15	;largest module number
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
;	equ	11	;reserved
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
getdm:
	;return disk map value from position given by BC
	lhld info ;base address of file control block
	lxi d,dskmap! dad d ;HL =.diskmap
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
	lda blkshf ;shift count to reg A
	lhld arecord
	atran0:
		dad h! dcr a! jnz atran0 ;shl(arecord,blkshf)
	lda blkmsk! mov c,a ;mask value to C
	lda vrecord! ana c ;masked value in A
	ora l! mov l,a ;to HL
	shld arecord ;arecord=HL or (vrecord and blkmsk)
	ret
;
getexta:
	;get current extent field address to A
	lhld info! lxi d,extnum! dad d ;HL=.fcb(extnum)
	ret
;
getfcba:
	;compute reccnt and nxtrec addresses for get/setfcb
	lhld info! lxi d,reccnt! dad d! xchg ;DE=.fcb(reccnt)
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
	lda seqio! mov c,a ;=1 if sequential i/o
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
seekdir:
	;seek the record containing the current dir entry
	lhld dcnt ;directory counter to HL
	mvi c,dskshf! call hlrotr ;value to HL
	shld arecord! shld drec ;ready for seek
	jmp seek
	;ret
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
hlrotl:
	;rotate the mask in HL by amount in C
	inr c ;may be zero
	hlrotl0: dcr c! rz ;return if zero
		dad h! jmp hlrotl0
;
set$cdisk:
	;set a "1" value in curdsk position of BC
	push b ;save input parameter
	lda curdsk! mov c,a ;ready parameter for shift
	lxi h,1 ;number to shift
	call hlrotl ;HL = mask to integrate
	pop b ;original mask
	mov a,c! ora l! mov l,a
	mov a,b! ora h! mov h,a ;HL = mask or rol(1,curdsk)
	ret
;
nowrite:
	;return true if dir checksum difference occurred
	lhld rodsk! lda curdsk! mov c,a! call hlrotr
	mov a,l! ani 1b! ret ;non zero if nowrite
;
set$ro:
	;set current disk to read only
	lxi h,rodsk! mov c,m! inx h! mov b,m
	call set$cdisk ;sets bit to 1
	shld rodsk
	;high water mark in directory goes to max
	lhld dirmax! xchg ;DE = directory max
	lhld cdrmaxa ;HL = .cdrmax
	mov m,e! inx h! mov m,d ;cdrmax = dirmax
	ret
;
check$rofile:
	;check current buff(dptr) or fcb(0) for r/o status
	lxi d,rofile! dad d ;offset to ro bit
	mov a,m! ral! rnc ;return if not set
	jmp rof$error ;exit to read only disk message
;
check$rodir:
	;check current directory element for read/only status
	call getdptra ;address of element
	jmp check$rofile ;share code
;
check$write:
	;check for write protected disk
	call nowrite! rz ;ok to write if not rodsk
	jmp rod$error ;read only disk error
;
addh:
	;HL = HL + A
	add l! mov l,a! rnc
	;overflow to H
	inr h! ret
;
getdptra:
	;compute the address of a directory element at
	;positon dptr in the buffer
	lhld buffa! lda dptr! jmp addh
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
setfwf:
	call getmodnum ;HL=.fcb(modnum), A=fcb(modnum)
	;set fwf (file write flag) to "1"
	ori fwfmsk! mov m,a ;fcb(modnum)=fcb(modnum) or 80h
	;also returns non zero in accumulator
	ret
;
setlret1:
	;set lret = 1
	mvi a,1! sta lret! ret
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
	lhld drec! xchg! lhld chksiz! call subdh ;DE-HL
	rnc ;skip checksum if past checksum vector size
		;drec < chksiz, so continue
		push b ;save init flag
		call compute$cs ;check sum value to A
		lhld checka ;address of check sum vector
		xchg
		lhld drec ;value of drec
		dad d ;HL = .check(drec)
		pop b ;recall true=0ffh or false=00 to C
		inr c ;0ffh produces zero flag
		jz initial$cs
			;not initializing, compare
			cmp m ;compute$cs=check(drec)?
			rz ;no message if ok
			;checksum error, are we beyond
			;the end of the disk?
			call compcdr
			rnc ;no message if so
			call set$ro ;read/only disk set
			ret
		initial$cs:
			;initializing the checksum
			mov m,a! ret
;
setdma:
	;HL=.dma address to set (i.e., buffa or dmaad)
	mov c,m! inx h! mov b,m ;parameter ready
	jmp setdmaf
;
setdata:
	;set data dma address
	lxi h,dmaad! jmp setdma ;to complete the call
;
setdir:
	;set directory dma address
	lxi h,buffa! jmp setdma ;to complete the call
;
wrdir:
	;write the current directory entry, set checksum
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
        jmp setdata ;to data dma address
	;ret
;
dir$to$user:
	;copy the directory entry to the user buffer
	;after call to search or searchn by user code
	lhld buffa! xchg ;source is directory buffer
	lhld dmaad ;destination is user dma address
	mvi c,recsiz ;copy entire record
	jmp move
	;ret
;
end$of$dir:
	;return zero flag if at end of directory, non zero
	;if not at end (end of dir if dcnt = 0ffffh)
	lxi h,dcnt! mov a,m ;may be 0ffh
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
		call set$end$dir
		ret
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
rotr:
	;byte value from ALLOC is in register A, with shift count
	;in register C (to place bit back into position), and
	;target ALLOC position in registers HL, rotate and replace
	rrc! dcr d! jnz rotr ;back into position
	mov m,a ;back to ALLOC
	ret
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
	mov a,c! rrc! rrc! rrc! ani 11111b! mov c,a ;C shr 3 to C
	mov a,b! add a! add a! add a! add a! add a ;B shl 5
	ora c! mov c,a ;bbbccccc to C
	mov a,b! rrc! rrc! rrc! ani 11111b! mov b,a ;BC shr 3 to BC
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
	jmp rotr ;to rotate back into proper position
	;ret
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
			cnz set$alloc$bit
			;bit set to 0/1
			pop h! inx h ;to next bit position
			pop b ;recall counter
			jmp scandm0 ;for another item
;
initialize:
	;initialize the current disk
	;lret = false ;set to true if $ file exists
	;compute the length of the allocation vector - 2
	lhld maxall! mvi c,3 ;perform maxall/8
	;number of bytes in alloc vector is (maxall/8)+1
	call hlrotr! inx h ;HL = maxall/8+1
	mov b,h! mov c,l ;count down BC til zero
	lhld alloca ;base of allocation vector
	;fill the allocation vector with zeros
	initial0:
		mvi m,0! inx h ;alloc(i)=0
		dcx b ;count length down
		mov a,b! ora c! jnz initial0
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
		;not empty, user code the same?
		lda usrcode
		cmp m! jnz pdollar
		;same user code, check for '$' submit
		inx h! mov a,m ;first character
		sui '$' ;dollar file?
		jnz pdollar
		;dollar file found, mark in lret
		dcr a! sta lret ;lret = 255
	pdollar:
		;now scan the disk map for allocated blocks
		mvi c,1 ;set to allocated
		call scandm
		call setcdr ;set cdrmax to dcnt
		jmp initial2 ;for another entry
;
copy$dirloc:
	;copy directory location to lret following
	;delete, rename, ... ops
	lda dirloc! sta lret
	ret
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
searchn:
	;search for the next directory element, assuming
	;a previous call on search which sets searcha and
	;searchl
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
		searchloop:
			mov a,c! ora a! jz endsearch
			ldax d! cpi '?'! jz searchok ;? matches all
			;scan next character if not ubytes
			mov a,b! cpi ubytes! jz searchok
			;not the ubytes field, extent field?
			cpi extnum ;may be extent field
			ldax d ;fcb character
			jz searchext ;skip to search extent
			sub m! ani 7fh ;mask-out flags/extent modulus
			jnz searchn ;skip if not matched
			jmp searchok ;matched character
		searchext:
			;A has fcb character
			;attempt an extent # match
			push b ;save counters
			mov c,m ;directory character to c
			call compext ;compare user/dir char
			pop b ;recall counters
			jnz searchn ;skip if no match
		searchok:
			;current character matches
			inx d! inx h! inr b! dcr c
			jmp searchloop
		endsearch:
			;entire name matches, return dir position
			lda dcnt! ani dskmsk! sta lret
			;lret = low(dcnt) and 11b
			lxi h,dirloc! mov a,m! ral! rnc ;dirloc=0ffh?
			;yes, change it to 0 to mark as found
			xra a! mov m,a ;dirloc=0
			ret
		search$fin:
			;end of directory, or empty name
			call set$end$dir ;may be artifical end
			mvi a,255! sta lret! ret
;
search:
	;search for directory element of length C at info
	mvi a,0ffh! sta dirloc ;changed if actually found
	lxi h,searchl! mov m,c ;searchl = C
	lhld info! shld searcha ;searcha = info
	call set$end$dir ;dcnt = enddir
	call home ;to start at the beginning
	jmp searchn ;start the search operation
;
delete:
	;delete the currently addressed file
	call check$write ;write protected?
	mvi c,extnum! call search ;search through file type
	delete0:
		;loop while directory matches
		call end$of$dir! rz ;stop if end
		;set each non zero disk map entry to 0
		;in the allocation vector
		;may be r/o file
		call check$rodir ;ro disk error if found
		call getdptra ;HL=.buff(dptr)
		mvi m,empty
		mvi c,0! call scandm ;alloc elts set to 0
		call wrdir ;write the directory
		call searchn ;to next element
		jmp delete0 ;for another record
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
		lxi h,0000h! ret
;
copy$dir:
	;copy fcb information starting at C for E bytes
	;into the currently addressed directory entry
	push d ;save length for later
	mvi b,0 ;double index to BC
	lhld info ;HL = source for data
	dad b! xchg ;DE=.fcb(C), source for copy
	call getdptra ;HL=.buff(dptr), destination
	pop b ;DE=source, HL=dest, C=length
	call move ;data moved
seek$copy:
	;enter from close to seek and copy current element
	call seek$dir ;to the directory element
	jmp wrdir ;write the directory element
	;ret
;
copy$fcb:
	;copy the entire file control block
	mvi c,0! mvi e,fcblen ;start at 0, to fcblen-1
	jmp copy$dir
;
rename:
	;rename the file described by the first half of
	;the currently addressed file control block. the
	;new name is contained in the last half of the
	;currently addressed file conrol block.  the file
	;name and type are changed, but the reel number
	;is ignored.  the user number is identical
	call check$write ;may be write protected
	;search up to the extent field
	mvi c,extnum! call search
	;copy position 0
	lhld info! mov a,m ;HL=.fcb(0), A=fcb(0)
	lxi d,dskmap! dad d;HL=.fcb(dskmap)
	mov m,a ;fcb(dskmap)=fcb(0)
	;assume the same disk drive for new named file
	rename0:
		call end$of$dir! rz ;stop at end of dir
		;not end of directory, rename next element
		call check$rodir ;may be read-only file
		mvi c,dskmap! mvi e,extnum! call copy$dir
		;element renamed, move to next
		call searchn
		jmp rename0
;
indicators:
	;set file indicators for current fcb
	mvi c,extnum! call search ;through file type
	indic0:
		call end$of$dir! rz ;stop at end of dir
		;not end of directory, continue to change
		mvi c,0! mvi e,extnum ;copy name
		call copy$dir
		call searchn
		jmp indic0
;
open:
	;search for the directory entry, copy to fcb
	mvi c,namlen! call search
	call end$of$dir! rz ;return with lret=255 if end
	;not end of directory, copy fcb information
open$copy:
	;(referenced below to copy fcb info)
	call getexta! mov a,m! push psw! push h ;save extent#
	call getdptra! xchg ;DE = .buff(dptr)
	lhld info ;HL=.fcb(0)
	mvi c,nxtrec ;length of move operation
	push d ;save .buff(dptr)
	call move ;from .buff(dptr) to .fcb(0)
	;note that entire fcb is copied, including indicators
	call setfwf ;sets file write flag
	pop d! lxi h,extnum! dad d ;HL=.buff(dptr+extnum)
	mov c,m ;C = directory extent number
	lxi h,reccnt! dad d ;HL=.buff(dptr+reccnt)
	mov b,m ;B holds directory record count
	pop h! pop psw! mov m,a ;restore extent number
	;HL = .user extent#, B = dir rec cnt, C = dir extent#
	;if user ext < dir ext then user := 128 records
	;if user ext = dir ext then user := dir records
	;if user ext > dir ext then user := 0 records
		mov a,c! cmp m! mov a,b ;ready dir reccnt
		jz open$rcnt ;if same, user gets dir reccnt
		mvi a,0! jc open$rcnt ;user is larger
		mvi a,128 ;directory is larger
	open$rcnt: ;A has record count to fill
	lhld info! lxi d,reccnt! dad d! mov m,a
	ret
;
mergezero:
	;HL = .fcb1(i), DE = .fcb2(i),
	;if fcb1(i) = 0 then fcb1(i) := fcb2(i)
	mov a,m! inx h! ora m! dcx h! rnz ;return if = 0000
	ldax d! mov m,a! inx d! inx h ;low byte copied
	ldax d! mov m,a! dcx d! dcx h ;back to input form
	ret
;
close:
	;locate the directory element and re-write it
	xra a! sta lret
	call nowrite! rnz ;skip close if r/o disk
	;check file write flag - 0 indicates written
	call getmodnum ;fcb(modnum) in A
	ani fwfmsk! rnz ;return if bit remains set
	mvi c,namlen! call search ;locate file
	call end$of$dir! rz ;return if not found
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
		cmp m! jc endmerge
		;fcb extent number >= dir extent number
		mov m,a ;buff(ext) = fcb(ext)
		;update directory record count field
		lxi b,(reccnt-extnum)! dad b! xchg! dad b
		;DE=.buff(reccnt), HL=.fcb(reccnt)
		mov a,m! stax d ;buff(reccnt)=fcb(reccnt)
	endmerge:
		mvi a,true! sta fcb$copied ;mark as copied
		call seek$copy ;ok to "wrdir" here - 1.4 compat
		ret
	mergerr:
		;elements did not merge correctly
		lxi h,lret! dcr m ;=255 non zero flag set
	ret
;
make:
	;create a new file by creating a directory entry
	;then opening the file
	call check$write ;may be write protected
	lhld info! push h ;save fcb address, look for e5
	lxi h,efcb! shld info ;info = .empty
	mvi c,1! call search ;length 1 match on empty entry
	call end$of$dir ;zero flag set if no space
	pop h ;recall info address
	shld info ;in case we return here
	rz ;return with error condition 255 if not found
	xchg ;DE = info address
	;clear the remainder of the fcb
	lxi h,namlen! dad d ;HL=.fcb(namlen)
	mvi c,fcblen-namlen ;number of bytes to fill
	xra a ;clear accumulator to 00 for fill
	make0:
		mov m,a! inx h! dcr c! jnz make0
	lxi h,ubytes! dad d ;HL = .fcb(ubytes)
	mov m,a ;fcb(ubytes) = 0
	call setcdr ;may have extended the directory
	;now copy entry to the directory
	call copy$fcb
	;and set the file write flag to "1"
	jmp setfwf
	;ret
;
open$reel:
	;close the current extent, and open the next one
	;if possible.  RMF is true if in read mode
		xra a! sta fcb$copied ;set true if actually copied
		call close ;close current extent
		;lret remains at enddir if we cannot open the next ext
		call end$of$dir! rz ;return if end
	;increment extent number
	lhld info! lxi b,extnum! dad b ;HL=.fcb(extnum)
	mov a,m! inr a! ani maxext! mov m,a ;fcb(extnum)=++1
	jz open$mod ;move to next module if zero
	;may be in the same extent group
	mov b,a! lda extmsk! ana b
	;if result is zero, then not in the same group
	lxi h,fcb$copied ;true if the fcb was copied to directory
	ana m ;produces a 00 in accumulator if not written
	jz open$reel0 ;go to next physical extent
	;result is non zero, so we must be in same logical ext
	jmp open$reel1 ;to copy fcb information
	open$mod:
		;extent number overflow, go to next module
		lxi b,(modnum-extnum)! dad b ;HL=.fcb(modnum)
		inr m ;fcb(modnum)=++1
		;module number incremented, check for overflow
		mov a,m! ani maxmod ;mask high order bits
		jz open$r$err ;cannot overflow to zero
		;otherwise, ok to continue with new module
	open$reel0:
		mvi c,namlen! call search ;next extent found?
		call end$of$dir! jnz open$reel1
			;end of file encountered
			lda rmf! inr a ;0ffh becomes 00 if read
			jz open$r$err ;sets lret = 1
			;try to extend the current file
			call make
			;cannot be end of directory
			call end$of$dir
			jz open$r$err ;with lret = 1
			jmp open$reel2
		open$reel1:
			;not end of file, open
			call open$copy
		open$reel2:
			call getfcb ;set parameters
			xra a! sta lret ;lret = 0
			ret ;with lret = 0
	open$r$err:
		;cannot move to next extent of this file
		call setlret1 ;lret = 1
		jmp setfwf ;ensure that it will not be closed
		;ret
;
seqdiskread:
	;sequential disk read operation
	mvi a,1! sta seqio
	;drop through to diskread
;
diskread:	;(may enter from seqdiskread)
	mvi a,true! sta rmf ;read mode flag = true (open$reel)
	;read the next record from the current fcb
	call getfcb ;sets parameters for the read
	lda vrecord! lxi h,rcount! cmp m ;vrecord-rcount
	;skip if rcount > vrecord
	jc recordok
		;not enough records in the extent
		;record count must be 128 to continue
		cpi 128 ;vrecord = 128?
		jnz diskeof ;skip if vrecord<>128
		call open$reel ;go to next extent if so
		xra a! sta vrecord ;vrecord=00
		;now check for open ok
		lda lret! ora a! jnz diskeof ;stop at eof
	recordok:
		;arrive with fcb addressing a record to read
		call index
		;error 2 if reading unwritten data
		;(returns 1 to be compatible with 1.4)
		call allocated ;arecord=0000?
		jz diskeof
		;record has been allocated, read it
		call atran ;arecord now a disk address
		call seek ;to proper track,sector
		call rdbuff ;to dma address
		call setfcb ;replace parameters
		ret
	diskeof:
		jmp setlret1 ;lret = 1
		;ret
;
;seqdiskwrite:
	;sequential disk write
;
;diskwrite:	;(may enter here from seqdiskwrite above)
;
;rseek:
	;random access seek operation, C=0ffh if read mode
;
;randiskread:
	;random disk read operation
;
;randiskwrite:
	;random disk write operation
;
;compute$rr:
	;compute random record position for getfilesize/setrandom
;
;getfilesize:
	;compute logical file size for current fcb
;
;setrandom:
	;set random record from the current file control block
;
select:
	;select disk info for subsequent input or output ops
	lhld dlog! lda curdsk! mov c,a! call hlrotr
	push h! xchg ;save it for test below, send to seldsk
	call selectdisk! pop h ;recall dlog vector
	cz sel$error ;returns true if select ok
	;is the disk logged in?
	mov a,l! rar! rc ;return if bit is set
	;disk not logged in, set bit and initialize
	lhld dlog! mov c,l! mov b,h ;call ready
	call set$cdisk! shld dlog ;dlog=set$cdisk(dlog)
	jmp initialize
	;ret
;
curselect:
	lda linfo! lxi h,curdsk! cmp m! rz ;skip if linfo=curdsk
	mov m,a ;curdsk=info
	jmp select
	;ret
;
reselect:
	;check current fcb to see if reselection necessary
	mvi a,true! sta resel ;mark possible reselect
	lhld info! mov a,m ;drive select code
	ani 1$1111b ;non zero is auto drive select
	dcr a ;drive code normalized to 0..30, or 255
	sta linfo ;save drive code
	cpi 30! jnc noselect
		;auto select function, save curdsk
		lda curdsk! sta olddsk ;olddsk=curdsk
		mov a,m! sta fcbdsk ;save drive code
		ani 1110$0000b! mov m,a ;preserve hi bits
		call curselect
	noselect:
		;set user code
		lda usrcode ;0...31
		lhld info! ora m! mov m,a
		ret
;
;	individual function handlers
;func12:
func12	equ	return
	;return version number
;
func13:
	;reset disk system - initialize to disk 0
	lxi h,0! shld rodsk! shld dlog
	xra a! sta curdsk ;note that usrcode remains unchanged
	lxi h,tbuff! shld dmaad ;dmaad = tbuff
        call setdata ;to data dma address
	jmp select
	;ret ;jmp goback
;
;func14:
func14	equ	return
	;select disk info
	jmp curselect
	;ret ;jmp goback
;
func15:
	;open file
	call clrmodnum ;clear the module number
	call reselect
	jmp open
	;ret ;jmp goback
;
;func16:
func16	equ	return
	;close file
;
;func17:
func17	equ	return
	;search for first occurrence of a file
;
;func18:
func18	equ	return
	;search for next occurrence of a file name
;
;func19:
func19	equ	return
	;delete a file
;
func20:
	;read a file
	call reselect
	call seqdiskread
	ret ;jmp goback
;
;func21:
func21	equ	return
	;write a file
;
;func22:
func22	equ	return
	;make a file
;
;func23:
func23	equ	return
	;rename a file
;
;func24:
func24	equ	return
	;return the login vector
;
;func25:
func25	equ	return
	;return selected disk number
;
func26:
	;set the subsequent dma address to info
	lhld info! shld dmaad ;dmaad = info
        jmp setdata ;to data dma address
	;ret ;jmp goback
;
;func27:
func27	equ	return
	;return the login vector address
;
;func28:
func28	equ	return
	;write protect current disk
;
;func29:
func29	equ	return
	;return r/o bit vector
;
;func30:
func30	equ	return
	;set file indicators
;
;func31:
func31	equ	return
	;return address of disk parameter block
;
;func32:
func32	equ	return
	;set user code
;
;func33:
func33	equ	return
	;random disk read operation
;
;func34:
func34	equ	return
	;random disk write operation
;
;func35:
func35	equ	return
	;return file size (0-65536)
;
;func36:
func36	equ	return
	;set random record
;
goback:
	;arrive here at end of processing to return to user
	lda resel! ora a! jz retmon
		;reselection may have taken place
		lhld info! mvi m,0 ;fcb(0)=0
		lda fcbdsk! ora a! jz retmon
		;restore disk number
		mov m,a ;fcb(0)=fcbdsk
		lda olddsk! sta linfo! call curselect
;
;	return from the disk monitor
retmon:
	lhld entsp! sphl ;user stack restored
	lhld aret! mov a,l! mov b,h ;BA = HL = aret
	ret
;
;	data areas
;
;	initialized data
efcb:	db	empty	;0e5=available dir entry
rodsk:	dw	0	;read only disk vector
dlog:	dw	0	;logged-in disks
dmaad:	dw	tbuff	;initial dma address
;
;	curtrka - alloca are set upon disk select
;	(data must be adjacent, do not insert variables)
;	(address of translate vector, not used)
cdrmaxa:ds	word	;pointer to cur dir max value
curtrka:ds	word	;current track address
curreca:ds	word	;current record address
buffa:	ds	word	;pointer to directory dma address
dpbaddr:ds	word	;current disk parameter block address
checka:	ds	word	;current checksum vector address
alloca:	ds	word	;current allocation vector address
addlist	equ	$-buffa	;address list size
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
tranv:	ds	word	;address of translate vector
fcb$copied:
	ds	byte	;set true if copy$fcb called
rmf:	ds	byte	;read mode flag for open$reel
dirloc:	ds	byte	;directory flag in rename, etc.
seqio:	ds	byte	;1 if sequential i/o
linfo:	ds	byte	;low(info)
dminx:	ds	byte	;local for diskwrite
searchl:ds	byte	;search length
searcha:ds	word	;search address
tinfo:	ds	word	;temp for info in "make"
single:	ds	byte	;set true if single byte allocation map
resel:	ds	byte	;reselection flag
olddsk:	ds	byte	;disk on entry to bdos
fcbdsk:	ds	byte	;disk named in fcb
rcount:	ds	byte	;record count in current fcb
extval:	ds	byte	;extent number and extmsk
vrecord:ds	word	;current virtual record
arecord:ds	word	;current actual record
;
;	local variables for directory access
dptr:	ds	byte	;directory pointer 0,1,2,3
dcnt:	ds	word	;directory counter 0,1,...,dirmax
drec:	ds	word	;directory record 0,1,...,dirmax/4
;
	end
