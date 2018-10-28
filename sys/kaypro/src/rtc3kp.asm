vers equ '1 ' ; Dec 23, 2017  07:06   drm "RTC3KP.ASM"
;****************************************************************
; RTC (Time) BIOS module for CP/M 3 (CP/M plus),		*
; For MM58167 RTC chip connected to PIO (as on Kaypro) 		*
; Copyright (c) 2017 Douglas Miller <durgadas311@gmail.com>	*
;****************************************************************
	maclib Z80

true	equ -1
false	equ not true

cr	equ 13
lf	equ 10
bell	equ 7

pio	equ	020h	;modem and rtc functions
rtc	equ	024h	;real-time clock

*********************************************************
**  PIO
*********************************************************
pioAdat equ	pio+0
pioActl equ	pioAdat+2
pioBdat equ	pio+1
pioBctl equ	pioBdat+2

*********************************************************
**  RTC (MM58167 Real-Time Clock)
*********************************************************
RTCDTA	equ	RTC
RTCADR	equ	pioAdat

RTCSEC	equ	2
RTCMIN	equ	3
RTCHRS	equ	4
RTCDAY	equ	5
RTCDAT	equ	6
RTCMON	equ	7
lastmon equ	10	;month last accessed (used to detect year change)
rtcyrs	equ	8	;years (decade)
rtcent	equ	9	;century

clrcnt	equ	18
rtcsts	equ	20
rtcis	equ	16	;interupt status
rtcic	equ	17	;interupt control

epoch2k	equ	8035	; CP/M date for Jan 1 2000.

	extrn @cbnk
	extrn ?bnksl
	extrn @sec,@min,@hour,@date

	public ?time,?itime

	cseg	; common memory, available no matter which bank

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

	dseg	; this part can be banked

regs:	db	0,0,0,0,0,0,0,0,0,0,0,0,0

	ds	32
stack:	ds	0
savsp:	dw	0
savbnk:	db	0

; This also must initialize the entire chip
settm:	push	h
	push	d
	push	b
	lxi	h,regs
	lda	@sec
	call	stbcd
	lda	@min
	call	stbcd
	lda	@hour
	call	stbcd
	push	h
	lded	@date
	call	dt2mdy
	; A=dom, E=month, D=year(BCD)
	pop	h
	call	stbin
	mov	a,e
	call	stbin
	mov	a,d
	call	stbcd
	push	h
	lhld	@date
	call	weekdy
	pop	h
	mov	m,a
	xra	a
	out	rtc+13
	out	rtc+14
	mvi	a,0100b	; 24-hour format
	out	rtc+15
	call	hold
	lxi	h,regs
	mvi	c,rtc-1
	mvi	b,13
settm0:	inr	c
	outi
	jrnz	settm0
	call	unhold
	pop	b
	pop	d
	pop	h
	ret

?itime:	; initialize RTC and get time
	push	h
	push	d
	push	b

ti0:	lxi	d,rtcsts+(numrtc shl 8)
	lxi	h,time
	lxi	b,rtcadr+(rtcsec shl 8)
ti1:	outp	b	;select reg
	inr	b
	in	rtcdta
	mov	m,a
	inx	h
	outp	e	;select status reg
	in	rtcdta
	ora	a
	jrnz	ti0
	dcr	d
	jrnz	ti1
	lda	timemon 	;if last accessed month is greater
	lxi	h,lstmnth	;than current month, the year must be
	cmp	m		;changed.
	cc	setyear$1	;assumes 1 year elapsed
	lda	timesec
	sta	@sec
	lda	timemin
	sta	@min
	lda	timehrs
	sta	@hour
	mvi	a,28
	sta	mondays+1	;set February=28
	lda	timeyrs
	call	bcdbin
	mov	b,a
	lda	timecnt
	sui	19h
	mov	a,b
	jrz	ti1@0
	adi	100	;adjust for century
ti1@0:	sui	78	;years since 1978 (base year)
	mov	b,a	;
	inr	a	;adjustment for leap year calc.
	mov	c,a	;
	srlr	c	;
	srlr	c	;divide by 4 = number of leap years (exclusive)
	ani	11b
	cpi	11b	;is this year a leap year?
	jrnz	ti2
	mvi	a,29
	sta	mondays+1	;set february=29
ti2:	lxi	h,0
	lxi	d,365
ti3:	dad	d	;find number of days since 1978
	djnz	ti3
	dad	b	;(B=0) add in 1 day for each leap year
	lda	timedat
	call	bcdbin
	mov	c,a
	mvi	b,0
	dad	b	;add in days of this month
	lda	timemon
	call	bcdbin
	dcr	a	;if January, nothing left to add.
	jrz	ti4
	mov	b,a
	lxi	d,mondays	;add in days of each month upto this.
ti5:	ldax	d
	inx	d
	add	l
	mov	l,a
	mvi	a,0
	adc	h
	mov	h,a
	djnz	ti5
ti4:	shld	@date

	pop	b
	pop	d
	pop	h
	ret

sett:	lda	@hour
	sta	timehrs
	lda	@min
	sta	timemin
	lda	@sec
	sta	timesec
	lhld	@date
	lxi	d,365
	mvi	a,28
	sta	mondays+1	;set february=28
	mvi	b,0	;start counting years since 1978
ti6:	mov	a,b	; check for leap year
	ani	11b	;every 4 years,
	xri	10b	;starting with 1980
	jrnz	ti7
	stc		;one extra day for leap years
ti7:	dsbc	d	;does this year fit in @date?
	inr	b	;count a year.
	jrnc	ti6	;yes, keep taking out more days (by years)
	mov	a,b	;is this year a leap year?
	ani	11b
	xri	10b
	jrnz	ti8
	mvi	a,29
	sta	mondays+1	;February=29
	stc
ti8:	dadc	d	;normalize @date (we subtracted one too many)
	dcr	b
	mov	a,b
	adi	78	;adjust year to 1900
	mvi	b,19	;century
	cpi	100
	jrc	ti8@0
	inr	b
	sui	100
ti8@0:	call	binbcd
	sta	timeyrs
	mov	a,b
	call	binbcd
	sta	timecnt
	xchg		;remainder into DE
	mvi	b,1	;start taking out months.
	lxi	h,mondays
ti9:	mov	a,e
	sub	m
	mov	c,a
	mov	a,d
	sbi	0
	jrc	ti10
	mov	e,c
	mov	d,a
	inx	h
	inr	b
	mov	a,b
	cpi	13
	jrc	ti9
ti10:	mov	a,b
	call	binbcd
	sta	timemon
	sta	lstmnth 	;also set last accessed month
	mov	a,e	;left-over must be date of month
	call	binbcd
	sta	timedat

; set day-of-week using Zeller's congruence:
	lda	timeyrs 	;E=([2.6m-.2]+K+D+[D/4]+[C/4]-2C) mod 7
	call	bcdbin		;0=sunday
	mov	d,a
	lda	timemon
	call	bcdbin
	mov	b,d
	sui	2
	jrz	ti11
	jrnc	ti12
ti11:	adi	12
	dcr	b
ti12:	mov	c,a
	add	a
	add	c	;*3
	add	a
	add	a	;*12
	add	c	;*13
	dcr	a
	mvi	c,0
ti13:	inr	c
	sui	5
	jrnc	ti13
	dcr	c
	lda	timedat
	push	b
	call	bcdbin
	pop	b
	add	c	;[2.6m-.2]+K
	add	b	;+D
	srlr	b
	srlr	b	; [D/4]
	add	b	;+[D/4]
	mov	c,a
	lda	timecnt ;century
	call	bcdbin
	mov	b,a
	slar	b	; 2*C
	srlr	a	;;
	srlr	a	; [C/4]
	add	c	;+[C/4]
	sub	b	;-2*C
	mov	c,a
	jp	ti14
	neg
ti14:	mvi	b,0
ti15:	inr	b
	sui	7
	jrz	ti16
	jrnc	ti15
	bit	7,c
	jrnz	ti16
	dcr	b
ti16:	mov	a,b
	add	a
	add	b	;*3
	add	a
	add	b	;*7
	bit	7,c
	jrz	ti17
	neg
ti17:	mov	b,a
	mov	a,c
	sub	b
	inr	a
	sta	timeday
	mvi	a,clrcnt	;
	out	rtcadr		;
	mvi	a,00000011b	;reset fractional seconds
	out	rtcdta	;we now have one second to set time
	mvi	d,numrtc
	lxi	h,time
	lxi	b,rtcadr+(rtcsec shl 8)
ti18:	outp	b	;select reg
	inr	b
	mov	a,m
	out	rtcdta
	inx	h
	dcr	d
	jrnz	ti18
	ret

setyear$1:
	mov	m,a	;set last-month
	dcx	h
	dcx	h
	mov	a,m
	adi	1
	daa
	mov	m,a
	jrnc	sy0
	inx	h
	mov	a,m
	adi	1
	daa
	mov	m,a
	dcx	h
sy0:	mvi	d,3	;3 registers to update
	lxi	b,rtcadr+(rtcyrs shl 8)
	jr	ti18

bcdbin: mov	b,a
	ani	00001111b
	mov	c,a
	mov	a,b
	ani	11110000b
	rrc
	mov	b,a
	rrc
	rrc
	add	b
	add	c
	ret

binbcd: sui	100
	jrnc	binbcd
	adi	100
	mvi	c,0
bb0:	sui	10
	inr	c
	jrnc	bb0
	adi	10
	dcr	c
	slar	c
	slar	c
	slar	c
	slar	c
	ora	c
	ret

mondays: db 31,28,31,30,31,30,31,31,30,31,30,31

time:
timesec: db	0
timemin: db	0
timehrs: db	0
timeday: db	0
timedat: db	0
timemon: db	0
	 db	0	;thousandths of seconds, 4 bits only
timeyrs: db	0
timecnt: db	0
lstmnth: db	0
numrtc equ $-time

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

	end
