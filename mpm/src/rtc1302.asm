vers equ '1 ' ; May 19, 2025  17:06   drm "RTC1302.ASM"
;****************************************************************
; DS1302 RTC (Time) BIOS module for CP/M 3 (CP/M plus),		*
; Copyright (c) 2017 Douglas Miller <durgadas311@gmail.com>	*
;****************************************************************
	maclib	z80

epoch2k	equ	8035	; CP/M date for Jan 1 2000.

rtc	equ	080h	; bit-bang port address
ds$ce	equ	00010000b
ds$wen	equ	00100000b
ds$clk	equ	01000000b
ds$wd	equ	10000000b

	extrn @cbnk
	extrn ?bnksl
	extrn sysdat

	public ?time,?itime,@rtcstr

	dseg

@rtcstr: db	'DS1302 ',0,'RTC Driver ',0,'v3.00'
	dw	vers
	db	'$'

; C=0 GET TIME (BDOS is about to read SCB), else SET TIME (BDOS just updated SCB)
; Typically, only C1=0 (SET) is used, to update the RTC chip.
; Cold Boot will call ?itime to force read of RTC chip.
; Must preserve HL, DE. Must be called with intrs enabled.
; Cannot depend on Bank 0 on entry...
?time:
	mov	a,c
	ora	a
	rz	; we keep time ourselves, not in RTC
	lda	@cbnk
	sta	savbnk
	di
	xra	a
	call	?bnksl
	sspd	savsp
	lxi	sp,stack
	ei	; TODO: bother with this?
	call	settm
	di
	lda	savbnk
	call	?bnksl
	lspd	savsp
	ei
	ret

	cseg

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

ds$ctl:	db	0

	ds	32
stack:	ds	0
savsp:	dw	0
savbnk:	db	0
todptr:	dw	0

; This also must initialize the entire chip
settm:	push	h
	push	d
	push	b
	pushiy
	liyd	todptr
	lxi	h,time
	ldy	a,+4	; @sec
	mov	m,a
	inx	h
	ldy	a,+3	; @min
	mov	m,a
	inx	h
	ldy	a,+2	; @hour
	mov	m,a
	inx	h
	push	h
	ldy	e,+0	; @date
	ldy	d,+1
	call	dt2mdy
	; A=dom, E=month, D=year(BCD)
	pop	h
	call	stbin	; dom
	mov	a,e	; mon
	call	stbin
	push	h	; save dow ptr
	inx	h
	mov	m,d	; already in BCD
	ldy	l,+0	; @date
	ldy	h,+1
	call	weekdy
	pop	h
	mov	m,a	; dow
	call	settime
	popiy
	pop	b
	pop	d
	pop	h
	ret

?itime:	; initialize RTC and get time
	lhld	sysdat	; system data area
	mvi	l,0fch	;XDOS int.dat.page, TOD
	mov	e,m
	inx	h
	mov	d,m
	xchg
	shld	todptr
	push	h
	popiy
	; TODO: force 24-hour?
	call	gettime
	lxi	h,time
	mov	a,m
	inx	h
	sty	a,+4	; @sec
	mov	a,m
	inx	h
	sty	a,+3	; @min
	mov	a,m
	inx	h
	sty	a,+2	; @hour
	call	gtbin	; day of month
	mov	e,a
	call	gtbin	; month (1-12)
	dcr	a	; 0-11
	add	a	; * 2 for table lookup
	mov	d,a
	inx	h	; skip DOW (unused)
	; assume RTC is never set for 20th cetnury...
	; i.e. year is always 20xx.
	call	gtbin	; year (century)
	mov	b,a
	mov	c,a
	dcr	c	; could be -1
	srar	c	;
	srar	c	;
	inr	c	; C=number of leap years before
	ani	00000011b	; check leap year
	lxi	h,month0
	jrnz	gettm2
	lxi	h,month1
gettm2:	
	push	d	; save day of month
	mov	e,d
	mvi	d,0
	dad	d
	mov	a,m
	inx	h
	mov	h,m
	mov	l,a	; number of days before this month
	push	h	; save current month offset
	lxi	h,epoch2k
	lxi	d,365
gettm1:	dad	d
	djnz	gettm1
	dad	b	; add leap years (B=0 now)
	pop	b	; current month offset
	dad	b
	pop	b	; day of month
	mvi	b,0	;
	dad	b
	sty	l,+0	; @date
	sty	h,+1
	ret

; HL=CP/M date value (days since epoch)
; From DATE.PLM: week$day = (word$value + base$day - 1) mod 7;
;                base$day  lit '0',
weekdy:	dcx	h	; 1/1/78 is "0" (Sun), -1 for offset
	lxi	d,7000
	ora	a
wd0:	dsbc	d
	jrnc	wd0
	dad	d
	lxi	d,700
	ora	a
wd1:	dsbc	d
	jrnc	wd1
	dad	d
	lxi	d,70
	ora	a
wd2:	dsbc	d
	jrnc	wd2
	dad	d
	lxi	d,7
	ora	a
wd3:	dsbc	d
	jrnc	wd3
	dad	d
	mov	a,l
	ret

; DE=CP/M date value (days since epoch)
dt2mdy:	mvi	c,78	; Epoch year, binary
	mvi	b,078h	; Epoch year, BCD
	mov	a,e
	ora	d
	jrnz	d2mdy0
	inx	d
d2mdy0:	lxi	h,365
	mov	a,c
	ani	03h	; Not strictly true, but works until year 2100...
	jrnz	d2mdy1
	inx	h
d2mdy1:	push	h
	ora	a
	dsbc	d
	pop	h
	jrnc	d2mdy2	; done computing year...
	xchg
	ora	a
	dsbc	d
	xchg
	inr	c	; does not wrap at 100
	mov	a,b
	adi	1
	daa
	mov	b,a
	jr	d2mdy0
d2mdy2:	push	b	; DE = days within year 'C'
	lxi	h,month0+24
	mov	a,c
	ani	03h
	jrnz	d2mdy3
	lxi	h,month1+24
d2mdy3:	mvi	b,12
d2mdy4:	dcx	h
	dcx	h
	dcr	b
	jm	d2mdy5
	push	h
	push	d
	mov	a,m
	inx	h
	mov	h,m
	mov	l,a
	; DE = days in year, HL = ytd[month]
	ora	a
	dsbc	d
	mov	a,l	; potential remainder (neg)
	pop	d
	pop	h
	jrnc	d2mdy4
d2mdy5:	neg	; B = month, 0-11; A = -dom
	pop	d	; D=year (BCD)
	inr	b	; month (1-12)
	mov	e,b	; E=month
	ret		; A=dom

;               J   F   M   A   M   J   J   A   S   O   N   D
month0: dw       0, 31, 59, 90,120,151,181,212,243,273,304,334
month1: dw       0, 31, 60, 91,121,152,182,213,244,274,305,335

; Get (BCD digit) value from regs[] in binary
gtbin:	mov	a,m
	ani	00fh	; LSD
	mov	b,a
	mov	a,m
	ani	0f0h	; MSD as X * 16
	rrc		; X * 8
	mov	c,a
	rrc		; X * 4
	rrc		; X * 2
	add	c	; (X * 8 + X * 2) = X * 10
	add	b	; + LSD
	inx	h
	ret

; store binary value into (BCD) digit registers
stbin:	sui	100
	jrnc	stbin
	adi	100
	mvi	c,0
stbin0:	sui	10
	inr	c
	jrnc	stbin0
	adi	10
	dcr	c
	rlcr	c
	rlcr	c
	rlcr	c
	rlcr	c
	ora	c
	mov	m,a
	inx	h
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
	ral		; pop off data bit
	rarr	e	; next data bit to CY
	rar		; new data bit in place
	out	rtc
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
