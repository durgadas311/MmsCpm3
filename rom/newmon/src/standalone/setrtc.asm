; A util to set time/date into the RTC.
; Prompts for a time/date string, and parses it and sets RTC

	maclib	core
	maclib	z80

CR	equ	13
LF	equ	10
TAB	equ	9
BS	equ	8
BEL	equ	7
CTLC	equ	3

rtc	equ	0a0h	; standard port address
linbuf	equ	2280h

	cseg

	jmp	start

	dseg
signon:	db	'RTC Set Time',CR,LF
	db	'Current time: ',0
newtime: db	'New time: ',0
enter:	db	CR,LF,'Enter MM/DD/YY HH:MM:SS (24-hour)',CR,LF
	db	'> ',0
noset:	db	'Time not set',CR,LF,0
setmsg:	db	' (RETURN to set): ',0
setto:	db	'RTC set to ',0

time:	db	0,0,0,0,0,0,0,0,0,0,0,0
sec1	equ	time+0
sec10	equ	time+1
min1	equ	time+2
min10	equ	time+3
hrs1	equ	time+4
hrs10	equ	time+5
dom1	equ	time+6
dom10	equ	time+7
mon1	equ	time+8
mon10	equ	time+9
yrs1	equ	time+10
yrs10	equ	time+11
dow:	db	0

	ds	64
stack:	ds	0

	cseg
start:
	lxi	sp,stack
	in	rtc+15
	ori	00000100b ; 24-hour format
	out	rtc+15
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

; MM/DD/YY HH:MM:SS
show:	lda	mon10
	ori	'0'
	call	chrout
	lda	mon1
	ori	'0'
	call	chrout
	mvi	a,'/'
	call	chrout
	lda	dom10
	ori	'0'
	call	chrout
	lda	dom1
	ori	'0'
	call	chrout
	mvi	a,'/'
	call	chrout
	lda	yrs10
	ori	'0'
	call	chrout
	lda	yrs1
	ori	'0'
	call	chrout
	mvi	a,' '
	call	chrout
	lda	hrs10
	ori	'0'
	call	chrout
	lda	hrs1
	ori	'0'
	call	chrout
	mvi	a,':'
	call	chrout
	lda	min10
	ori	'0'
	call	chrout
	lda	min1
	ori	'0'
	call	chrout
	mvi	a,':'
	call	chrout
	lda	sec10
	ori	'0'
	call	chrout
	lda	sec1
	ori	'0'
	call	chrout
	ret

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
	sbcd	mon1
	call	parsnm	; day of month
	mov	a,m
	cpi	'/'
	stc
	rnz
	inx	h
	sbcd	dom1
	call	parsnm	; year of century
	mov	a,m
	cpi	' '	; or NUL?
	stc
	rnz
	inx	h
	sbcd	yrs1
	call	parsnm	; hour (24-hour)
	mov	a,m
	cpi	':'
	stc
	rnz
	inx	h
	sbcd	hrs1
	call	parsnm	; minutes
	mov	a,m
	cpi	':'	; seconds optional?
	stc
	rnz
	inx	h
	sbcd	min1
	call	parsnm	; seconds
	mov	a,m
	cpi	0	; blanks? others?
	stc
	rnz
	inx	h
	sbcd	sec1
	xra	a
	ret

; parse (up to) two digits, return B=10's, C=1's
; HL=input string
; returns HL at next char
parsnm:
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

settime:
	xra	a
	out	rtc+13
	out	rtc+14
	mvi	a,0100b	; 24-hour format
	out	rtc+15
	call	hold
	lxi	h,time
	mvi	c,rtc-1
	mvi	b,13	; TODO: day-of-week?
settm0:	inr	c
	outi
	jrnz	settm0
	call	unhold
	ret

gettime:
	call	hold
	lxi	h,time
	mvi	c,rtc-1
	mvi	b,12
gettm0:	inr	c
	inp	a
	ani	0fh
	mov	m,a
	inx	h
	djnz	gettm0
	call	unhold
	ret

hold:	in	rtc+13
	ori	0001b	; HOLD
	out	rtc+13
	in	rtc+13
	ani	0010b	; BUSY
	rz
	ani	00001110b
	out	rtc+13
	; TODO: pause?
	jr	hold

unhold:	in	rtc+13
	ani	11111110b
	out	rtc+13
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

	end
