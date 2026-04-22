
;***************************************************************
;***************************************************************
;**                                                           **
;**   B a s i c    D i s k   O p e r a t i n g   S y s t e m  **
;**                                                           **
;**               C o n s o l e    P o r t i o n              **
;**                                                           **
;***************************************************************
;***************************************************************

cnsfunc:
	mov a,c! mov c,e! mov b,d
	lxi h,functab! mov e,a! mvi d,0 ;DE=func, HL=.functab
	dad d! dad d! mov e,m! inx h! mov d,m ;DE=functab(func)
	xchg! pchl ;dispatched
;
;	dispatch table for functions
functab:
	dw	bootf,func1,func2,func3
	dw	func4,func5,func6,func7
	dw	cmnret,func9,func10,func11
diskf	equ	($-functab)/2

nfuncs	equ	41	;must match with banked bdos # fns

;
func1:
	;return console character with echo
	call conech
	mov l,a! ret
;
func2:
	;write console character with tab expansion
	call attcns! jmp tabout
;
func3:
	;return raw unattached console character
	call rawattcns
	jmp dirinp
;
func4:
	;write raw unattached console character
	call rawattcns
	jmp conoutf
;
func5:
	;write list character
	call testlstatt
	;write to list device if already attached
	jz listf
	;else must attach list device first
	push b! push d
		mvi c,attlst! call xdos
	pop d! pop b
	jmp listf
;
func6:
	;direct console i/o - 0ffh = read/status
	;                     0feh = status
	;                     0fdh = read
	call rawattcns
	mov a,c! inr a! jz stsdirinp
	         inr a! jz stsinp
	         inr a! jz dirinp
		;direct output function
		jmp conoutf
	stsdirinp:
		push d! call constf! pop d
		ora a! jnz dirinp
		mvi c,dispatch! call xdos
		xra a! mov l,a! ret
	stsinp:
		;direct console status input
		call constf ;to A
		mov l,a! ret
	dirinp:
		lxi h,kbchar! call ofsthl
		mov a,m! mvi m,0! ora a
		cz coninf ;to A
		mov l,a! ret
;
func7:
	;return io byte
	;*** Not implemented in MP/M ***
	xra a
	mov l,a! ret
;
 ;func8:
	;set i/o byte
	;*** Not implemented in MP/M ***
	;ret
;
func9:
	;write line until $ encountered
	;BC = string address
	call attcns! jmp print ;out to console
;
func10:
	;read a buffered console line
	call attcns! jmp read
;
func11:
	;check console status
	call testcnsatt
	jz doconbrk
		mvi c,dispatch! call xdos
		xra a! mov l,a! ret
	doconbrk:
		call conbrk
		mov l,a
;
cmnret:
		ret
;
tstlivekbd:
	;test for simulated 'live keyboard'
	;pd.name(3)' = off
	call rlr! lxi b,pname+3! dad b! mov a,m! ani 80h
	ret

;
testlstatt:
	;test to determine if list is attached
	;Zero = attached, D = List #
	di
	call rlr! xchg ;DE = Ready List Root
	lxi h,console! dad d! mov a,m! ani 0f0h
		rrc! rrc! rrc! rrc! push psw! push b
		lxi b,lstatt-rlros! jmp attcmn
		;ret

;
testcnsatt:
	;test to determine if console is attached
	;Zero = attached, D = Console #
	di
	call rlr! xchg ;DE = Ready List Root
	lxi h,console! dad d! mov a,m! ani 0fh
		push psw! push b
		lxi b,cnsatt-rlros
	attcmn:
		lhld rlradr! dad b
		add a! mov c,a! mvi b,0! dad b
		mov a,m! cmp e! inx h! jnz notatt
		mov a,m! cmp d! jz testext
	notatt:
		mov a,m! dcx h! ora m! jnz testext
		mov m,e! inx h! mov m,d! xra a ;attach ok
	testext:
	ei! pop b! pop d
	mvi e,0 ;cns req'd flag false
	ret
;
rawattcns:
	push b! mvi b,80h! jmp attcns0
attcns:
	push b! mvi b,0
attcns0:
	call rlr
	inx h! inx h! inx h! inx h! inx h! inx h
	mov a,m! ani 7fh! ora b! mov m,a  ;set/reset direct i/o
	inx h! inx h! inx h
	mov a,m! ani 7fh! ora b! mov m,a  ;set/reset simul. live kbd
	pop b
	;attach console if req'd
	call testcnsatt
	mvi e,0ffh! rz ;cns req'd flag true
	push b! push d!
		mvi c,attach! call xdos
		pop d! push d ;restore DE
		call dsplyatchmsg
	pop d! pop b
	ret
;
ofsthl:
	;offset HL by console # (in D)
	push psw
		mov a,d! add l! mov l,a
		mvi a,0! adc h! mov h,a
	pop psw
	ret

;
;	console handlers

constx:
	push d! call constf! pop d! ret

coninx:
	;returns char & cond code = NZ if raw input
	push d! call rlr! lxi d,pname! dad d
	pop d! push d! ;restore console #
	mov a,m! ani 80h! push psw
	call coninf
	mov b,a! pop psw! mov a,b
	pop d! ret

conoutx:
	mov a,c! ani 7fh! mov c,a
	push d! call conoutf! pop d! ret

conin:
	;read console character to A
	;attach console first
	call attcns
	lxi h,kbchar! call ofsthl
	mov a,m! mvi m,0! ora a! rnz
	;no previous keyboard character ready
	call getchr ;get character externally and test it
	jmp conin ;only exit is with kbchar <> 0
	;ret
;
conech:
	;read character with echo
	call conin! call echoc! rc ;echo character?
        ;character must be echoed before return
	push psw! mov c,a! call tabout! pop psw
 	ret ;with character in A
;
echoc:
	;echo character if graphic
	;cr, lf, tab, or backspace
	cpi cr! rz ;carriage return?
	cpi lf! rz ;line feed?
	cpi tab! rz ;tab?
	cpi ctlh! rz ;backspace?
	cpi ' '! ret ;carry set if not graphic
;
conbrk:	;check for character ready
	call constx! ani 1
	lxi h,kbchar! call ofsthl
	jnz pgetchr ;jump if char to be read in
	mov a,m! ora a! rz ;return if no char in kbchar either
	jmp conb1 ;active kbchar
	pgetchr:
		mvi m,0 ;clear kbchar to prepare for new char
		;character ready, read it
	getchr: ;entry point used by conin
		call coninx ;to A
		jnz conb0; skip char testing if pd.pname.f0 is "on"
		cpi ctls! jnz notcts ;check stop screen function
		;found ctls, read next character
	    getctlq:
		call coninx ;to A
		cpi ctlc! jz controlc ;ctlc implies re-boot
		cpi ctlq! jz gotctlq
		mvi c,7! call conoutx ;send bell character
		jmp getctlq
	    gotctlq:
		;resume after ^Q
		xra a! ret ;with zero in accumulator
	notcts:
		;not a control s, control q?
		cpi ctlq! jz gotctlq
		;ignore control Q's
	notctq:
		;not a control s, control d?
		cpi ctld! jnz notctd
		;found ctld, detach console
		;^D is ignored if submit in progress
		lhld sysdat! mvi l,128! call ofsthl
		mov a,m! ora a! mvi a,0! rnz
		push d! lxi h,listcp! call ofsthl
		;if ^D and ^P then detach list
		mov a,m! ora a! jz notctlp
		mvi c,detlst! call XDOS
	    notctlp:
		mvi c,detach! call XDOS
		;then attach console back
		; unless cns not req'd
		pop d! mov a,e! ora a
		rz! push d ;return if cns not req'd
		mvi c,attach! call XDOS! pop d
	dsplyatchmsg:
		;print console attach message
		lxi b,atchmsg! call xprint
		call rlr
	dsplynm:
		call pdsplynm
	xcrlf:
		;output crlf without CONBRK calls
		mvi c,cr! call conoutx
		mvi c,lf! call conoutx
		xra a! ret ;with zero in A

	pdsplynm:
		lxi b,pname! dad b! mvi e,8
		dsploop:
			mov c,m! push h! push d! call conoutx
			pop d! pop h! inx h! dcr e
			jnz dsploop
		inr e ;cns req'd set true
		ret

	notctd:
 		;not a control d, control c?
		cpi ctlc! jnz conb0
	    controlc: ;entry point
		lhld sysdat! mvi l,128! call ofsthl
		mov a,m! ora a! jz ctlcnt
		push h! lxi b,submsg! call query
		pop h! jnz ctlcnt
		mvi m,0
	    ctlcnt:
		;test for suppress abort flag
		call rlr! lxi b,(pname+7)! dad b
		mov a,m! ani 80h! jz notctlcsupr
		dcx h! mov a,m! ori 80h! mov m,a
		xra a! ret
	    notctlcsupr:
		;test to see if this is a user process
		inx h! inx h
		mov a,m! ora a! rz
		inr a! rz ;ignore ^C if system process running
		;print Abort (Y/N) ?
		lxi b,abtmsg1! call xprint
		call rlr! call pdsplynm
		lxi b,abtmsg2! call query! jz xreboot
		xra a! ret ;with zero in A
	conb0:
		;character in accum, save it
		lxi h,kbchar! call ofsthl! mov m,a
	conb1:
		;return with true set in accumulator
		mvi a,1! ret
;
query:
	call xprint
	eatctlc:
		call coninx! ani 7fh
		cpi ctlc! jz eatctlc! push psw
		mov c,a! call conoutx
		mvi c,cr! call conoutx
		mvi c,lf! call conoutx
	pop psw
	ani 5fh! cpi 'Y'
	ret
;
conout:
	;compute character position/write console char from C
	;compcol = true if computing column position
	lxi h,compcol! call ofsthl
	mov a,m! ora a! jnz compout
		;write the character, then compute the column
		;write console character from C
		push b!	call conoutx ;externally, to console
		call tstlivekbd ;conbrk only if simulated 'live kbd'
		cz conbrk ;check for screen stop function
		pop b! push b! push d ;recall/save character & con #
		;may be copying to the list device
		lxi h,listcp! call ofsthl
		mov a,m! ani 01h! cnz func5 ;to printer, if so
		pop d! pop b ;recall the character & con #
	compout:
		mov a,c ;recall the character
		;and compute column position
		lxi h,column! call ofsthl ;A = char, HL = .column
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
ctlout:
	;send C character with possible preceding up-arrow
	mov a,c! call echoc ;cy if not graphic (or special case)
	jnc tabout ;skip if graphic, tab, cr, lf, or ctlh
		;send preceding up arrow
		push psw! mvi c,ctl! call conout ;up arrow
		pop psw! ori 40h ;becomes graphic letter
		mov c,a ;ready to print
		;(drop through to tabout)
;
tabout:
	;expand tabs to console
	mov a,c! cpi tab! jnz conout ;direct to conout if not
		;tab encountered, move to next tab position
	tab0:
		mvi c,' '! call conout ;another blank
		call ldacolumn! ani 111b ;column mod 8 = 0 ?
		jnz tab0 ;back for another if not
	ret
;
backup:
	;back-up one screen position
	call pctlh! mvi c,' '! call conoutx ;jmp pctlh
;
pctlh:
	;send ctlh to console without affecting column count
	mvi c,ctlh! jmp conoutx
	;ret
;
crlfp:
	;print #, cr, lf for ctlx, ctlu, ctlr functions
	;then move to strtcol (starting column)
	mvi c,'#'! call conout
	call crlf
	;column = 0, move to position strtcol
	crlfp0:
		call ldacolumn! lxi h,strtcol! call ofsthl
		cmp m! rnc ;stop when column reaches strtcol
		mvi c,' '! call conout ;print blank
		jmp crlfp0
;;
;
crlf:
	;carriage return line feed sequence
	mvi c,cr! call conout! mvi c,lf! jmp conout
	;ret
;
xprint:
	;print routine which does not CONBRK
	;BC = string address, string terminated with a '$'
	ldax b! ORA A! rz
	push b! mov c,a! call conoutx! pop b
	inx b! jmp xprint
;
print:
	;print message until M(BC) = '$'
	ldax b! cpi '$'! rz ;stop on $
		;more to print
		inx b! push b! mov c,a ;char to C
		call tabout ;another character printed
		pop b! jmp print
;
pread:	;entry to read, restores buffer address
	pop b
read:	;BC = address (max length, current length, buffer)
	push b ;save buffer address for possible ^X or ^U
	call ldacolumn
	lxi h,strtcol! call ofsthl
	mov m,a ;save start for ctl-x, ctl-h
	mov h,b! mov l,c! mov c,m! inx h! push h! mvi b,0
	;B = current buffer length,
	;C = maximum buffer length,
	;HL= next to fill - 1
	readnx:
		;read next character, BC, HL active
		push b! push h ;blen, cmax, HL saved
		readn0:
			call conin ;next char in A
			ani 7fh ;mask parity bit
			pop h! pop b ;reactivate counters
			cpi cr! jz readen ;end of line?
			cpi lf! jz readen ;also end of line
			cpi ctlh! jnz noth ;backspace?
			;do we have any characters to back over?
			mov a,b! ora a! jz readnx
			;characters remain in buffer, backup one
			dcr b ;remove one character
			call ldacolumn
			lxi h,compcol! call ofsthl
			mov m,a ;col > 0
			;compcol > 0 marks repeat as length compute
			jmp linelen ;uses same code as repeat
		noth:
			;not a backspace
			cpi rubout! jnz notrub ;rubout char?
			;rubout encountered, rubout if possible
			mov a,b! ora a! jz readnx ;skip if len=0
			;buffer has characters, resend last char
			mov a,m! dcr b! dcx h ;A = last char
			;blen=blen-1, next to fill - 1 decremented
 			jmp rdech1 ;act like this is an echo
;
		notrub:
			;not a rubout character, check end line
			cpi ctle! jnz note ;physical end line?
			;yes, save active counters and force eol
			push b! push h! call crlf
			lxi h,strtcol! call ofsthl
			xra a! mov m,a ;start position = 00
			jmp readn0 ;for another character
		note:
			;not end of line, list toggle?
			cpi ctlp! jnz notp ;skip if not ctlp
			lda kbproc! ora a! jnz notp
			;list toggle - change parity
			push h ;save next to fill - 1
			push b! push d
			lxi h,listcp! call ofsthl ;HL=.listcp flag
			mvi a,01h! xra m! mov m,a ;listcp=-listcp
			push h ;save address of listcp
			jnz prntron ; jump if printer to be turned on
			prntroff:
				;return list mutex queue message
				mvi m,0! ;zero listcp(console)
				mvi c,detlst! call XDOS
				pop h! jmp ctlpxit
			prntron:
				call testlstatt
				pop h! jz ctlpxit
				;printer busy, could not ^p
				mvi m,0! lxi b,pbsymsg
				;D = console #
				pop d! push d
				call xprint
			ctlpxit:
				pop d! pop b
				pop h! jmp readnx ;for another char
		notp:
			;not a ctlp, line delete?
			cpi ctlx! jnz notx
			pop h ;discard start position
			;loop while column > strtcol
			backx:
				lxi h,strtcol! call ofsthl
				mov a,m! lxi h,column! call ofsthl
				cmp m! jnc pread ;start again
 				dcr m ;column = column - 1
				call backup ;one position
				jmp backx
		notx:
			;not a control x, control u?
			cpi ctlu! jnz notu ;skip if not
			;delete line (ctlu)
			call crlfp ;physical eol
			pop h ;discard starting position
			jmp pread ;to start all over
		notu:
			;not line delete, repeat line?
			cpi ctlr! jnz notr
		linelen:
			;repeat line, or compute line len (ctlh)
			;if compcol > 0
			push b! call crlfp ;save line length
			pop b! pop h! push h! push b
			;bcur, cmax active, beginning buff at HL
		rep0:
			mov a,b! ora a! jz rep1 ;count len to 00
			inx h! mov c,m ;next to print
			dcr b! push b! push h ;count length down
			call ctlout ;character echoed
			pop h! pop b ;recall remaining count
			jmp rep0 ;for the next character
		rep1:
			;end of repeat, recall lengths
			;original BC still remains pushed
			push h ;save next to fill
			lxi h,compcol! call ofsthl
			mov a,m! ora a ;>0 if computing length
			jz readn0 ;for another char if so
			;column position computed for ctlh
			lxi h,column! call ofsthl! sub m ;diff > 0
			lxi h,compcol! call ofsthl
			mov m,a ;count down below
			;move back compcol-column spaces
		backsp:
			;move back one more space
			call backup ;one space
			lxi h,compcol! call ofsthl! dcr m
			jnz backsp
			jmp readn0 ;for next character
		notr:
			;not a ctlr, place into buffer
		rdecho:
			inx h! mov m,a ;character filled to mem
			inr b ;blen = blen + 1
		rdech1:
			;look for a random control character
			push b! push h ;active values saved
			mov c,a ;ready to print
			call ctlout ;may be up-arrow C
			pop h! pop b! mov a,b ;len to A
			;are we at end of buffer?
 			cmp c! jc readnx ;go for another if not
		readen:
			;end of read operation, store blen
			pop h! mov m,b ;M(current len) = B
			pop h ;discard buffer address
			mvi c,cr! jmp conout ;return carriage
			;ret
;
ldacolumn:
	lxi h,column! call ofsthl! mov a,m! ret

pbsymsg:
	db	cr,lf,'Printer Busy.',cr,lf,0

abtmsg1:
	db	cr,lf,'Abort ',0
abtmsg2:
	db	' (Y/N) ?',0

atchmsg:
	db	cr,lf,'Attach:',0

submsg:
	db	cr,lf,'Terminate Submit ?',0

;
;	data areas
;
nmbcns	equ	16

compcol:db	0	;true if computing column position
	rept	nmbcns-1
	db	0
	endm
strtcol:db	0	;starting column position after read
	rept	nmbcns-1
	db	0
	endm
column:	db	0	;column position
	rept	nmbcns-1
	db	0
	endm
kbchar:	db	0	;initial key char = 00
	rept	nmbcns-1
	db	0
	endm
listcp:	db	0	;listing toggle
	rept	nmbcns-1
	db	0
	endm

kbproc:	db	0	;kb proc resident flag

;
patch$size equ	80
	ds	patch$size
patch:
	org	(((patch-base)+255) AND 0ff00h)-patch$size
	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0

;
;	bios external jump table
;
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
;	xios access table
xiosms	equ	sectran+3	;memory select / protect
xiospl	equ	xiosms+3	;device poll
strclk	equ	xiospl+3	;start clock
stpclk	equ	strclk+3	;stop clock
exitr	equ	stpclk+3	;exit critical region
maxcns	equ	exitr+3		;max console #
syinitf	equ	maxcns+3	;MP/M system initialization
;
	end
