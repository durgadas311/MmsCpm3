; A util to set time/date into the DS1302 RTC.
; Prompts for a time/date string, and parses it and sets RTC

	maclib	core
	maclib	z80

CR	equ	13
LF	equ	10
TAB	equ	9
BS	equ	8
BEL	equ	7
CTLC	equ	3

rtc	equ	080h	; bit-bang port address
ds$clk	equ	00001000b
ds$ce	equ	00000100b
ds$wd	equ	00010000b
ds$wen	equ	00100000b

linbuf	equ	2280h

	cseg

	jmp	start

	dseg
signon:	db	'DS1302 Set Time',CR,LF
	db	'Current time: ',0
newtime: db	'New time: ',0
enter:	db	CR,LF,'Enter MM/DD/YY HH:MM:SS (24-hour)',CR,LF
	db	'> ',0
noset:	db	'Time not set',CR,LF,0
setmsg:	db	' (RETURN to set): ',0
setto:	db	'DS1302 set to ',0

time:	; buffer for burst-mode DS1302 RTC data
sec:	db	0	; bit7 = CH
min:	db	0
hrs:	db	0	; bit7 = 12/24
dom:	db	0
mon:	db	0
dow:	db	0
yrs:	db	0
timez	equ	$-time
;prt:	db	80h	; bit7 = prot

	ds	64
stack:	ds	0

ds$ctl:	db	0

	cseg
start:
	lxi	sp,stack
	call	dsend	; initialzes ctl port to idle state
	lxi	h,signon
	call	msgout
	call	gettime
	call	show
	lxi	h,enter
	call	msgout

	lxi	h,linbuf
	call	linin
	jrc	quit
	lxi	h,linbuf
	call	parse
	jrc	error
	lxi	h,newtime
	call	msgout
	call	show
	lxi	h,setmsg
	call	msgout
	lxi	h,linbuf
	call	linin
	jrc	quit
	call	settime
	lxi	h,setto
	call	msgout
	call	gettime
	call	show
	call	crlf
	jr	exit

error:	; TODO...
quit:	lxi	h,noset
	call	msgout
exit:	lhld	retmon
	pchl

chrout:	liyd	conout
	pciy

hexout:	push	psw
	rlc
	rlc
	rlc
	rlc
	call	hexdig
	pop	psw
hexdig:	ani	0fh
	adi	90h
	daa
	aci	40h
	daa
	jmp	chrout

; MM/DD/YY HH:MM:SS
show:	lda	mon
	call	hexout
	mvi	a,'/'
	call	chrout
	lda	dom
	call	hexout
	mvi	a,'/'
	call	chrout
	lda	yrs
	call	hexout
	mvi	a,' '
	call	chrout
	lda	hrs
	call	hexout
	mvi	a,':'
	call	chrout
	lda	min
	call	hexout
	mvi	a,':'
	call	chrout
	lda	sec
	call	hexout
	ret

linix:	mvi	m,0	; terminate buffer
	jmp	crlf

; input a filename from console, allow backspace
; HL=buffer
; returns C=num chars, buffer NUL terminated
linin:
	mvi	c,0	; count chars
lini0	call	conin
	cpi	CR
	jrz	linix
	cpi	CTLC	; cancel
	stc
	rz
	cpi	BS
	jrz	backup
	cpi	' '
	jrc	chrnak
	cpi	'~'+1
	jrnc	chrnak
chrok:	mov	m,a
	inx	h
	inr	c
	call	chrout	; echo
	; TODO: detect overflow...
	jr	lini0
chrnak:	mvi	a,BEL
	call	chrout
	jr	lini0
backup:
	mov	a,c
	ora	a
	jrz	lini0
	dcr	c
	dcx	h
	mvi	a,BS
	call	chrout
	mvi	a,' '
	call	chrout
	mvi	a,BS
	call	chrout
	jr	lini0

; TODO: support reorder/partials?
; HL="MM/DD/YY HH:MM:SS"
parse:
	; TODO: skip blanks
	call	parsnm	; month
	mov	a,m
	cpi	'/'
	stc
	rnz
	inx	h
	mov	a,c
	sta	mon
	call	parsnm	; day of month
	mov	a,m
	cpi	'/'
	stc
	rnz
	inx	h
	mov	a,c
	sta	dom
	call	parsnm	; year of century
	mov	a,m
	cpi	' '	; or NUL?
	stc
	rnz
	inx	h
	mov	a,c
	sta	yrs
	call	parsnm	; hour (24-hour)
	mov	a,m
	cpi	':'
	stc
	rnz
	inx	h
	mov	a,c
	sta	hrs
	call	parsnm	; minutes
	mov	a,m
	cpi	':'	; seconds optional?
	stc
	rnz
	inx	h
	mov	a,c
	sta	min
	call	parsnm	; seconds
	mov	a,m
	cpi	0	; blanks? others?
	stc
	rnz
	inx	h
	mov	a,c
	sta	sec
	xra	a
	ret

; parse (up to) two digits, return C = BCD number
; HL=input string
; returns HL at next char
parsnm:	call	pnm
	mov	a,b
	rlc
	rlc
	rlc
	rlc
	ora	c
	mov	c,a
	ret

; parse (up to) two digits, return B=10's, C=1's
; HL=input string
; returns HL at next char
pnm:
	lxi	b,0
	mov	a,m
	sui	'0'
	rc
	cpi	10
	cmc
	rc
	inx	h
	mov	c,a
	mov	a,m
	sui	'0'
	rc
	cpi	10
	cmc
	rc
	inx	h
	mov	b,c
	mov	c,a
	ret

; DS1302 routines, using NC-89 ports
; "in rtc" reads SDA on D0
; "out rtc" ... bit bang...

; get a byte from DS1302. Assumes read command already sent.
; return byte in E, rtc ctrl port same state as entry (ds$clk high)
dsget:
	mvi	e,0
	mvi	b,8
	lda	ds$ctl
	ori	ds$wen	; disable write
dsg1:
	ani	not ds$clk	; clock low
	out	rtc
	nop		; delay >= 250nS
	push	psw
	in	rtc		; read data line
	rar
	rarr	e
	pop	psw
	ori	ds$clk
	out	rtc
	nop		; delay >= 250nS
	djnz	dsg1
	sta	ds$ctl
	ret

; output byte in E (destructive)
dsput:
	mvi	b,8
	lda	ds$ctl
	ani	not ds$wen	; /WE active
dsp1:
	ani	not ds$clk	; clock low
	out	rtc
	nop		; delay >= 250nS
	rarr	e
	jrnc	dsp2
	ori	ds$wd
	jr	dsp3
dsp2:	ani	not ds$wd
dsp3:	out	rtc
	ori	ds$clk		; clock high
	out	rtc
	nop		; delay >= 250nS
	djnz	dsp1
	sta	ds$ctl	; leave clk high, /WE asserted, data = ?
	ret

dsend:
	mvi	a,ds$wen
	out	rtc
	sta	ds$ctl
	ret

; command byte in E (destroyed)
dscmd:
	call	dsend	; force idle
	nop	; delay >= 1uS
	nop
	nop
	nop
	ori	ds$ce
	out	rtc
	sta	ds$ctl
	nop	; delay >= 1uS
	nop
	nop
	nop
	call	dsput
	ret

settime:
	mvi	e,10001110b	; write ctrl reg (disable prot)
	call	dscmd
	mvi	e,0		; unprotect
	call	dsput
	call	dsend
	mvi	e,10111110b	; burst write clock
	call	dscmd
	lxi	h,time
	mvi	b,timez
st1:	push	b
	mov	e,m
	call	dsput
	inx	h
	pop	b
	djnz	st1
	mvi	e,80h		; protect
	call	dsput
	jmp	dsend
	ret

gettime:
	mvi	e,10111111b	; burst read clock
	call	dscmd
	lxi	h,time
	mvi	b,timez
gt1:	push	b
	call	dsget
	mov	m,e
	inx	h
	pop	b
	djnz	gt1
	jmp	dsend

	end
