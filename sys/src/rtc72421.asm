vers equ '1 ' ; Sep 28, 2017  17:06   drm "RTC72421.ASM"
;****************************************************************
; RTC (Time) BIOS module for CP/M 3 (CP/M plus),		*
; Copyright (c) 2017 Douglas Miller <durgadas311@gmail.com>	*
;****************************************************************
	maclib Z80

true	equ -1
false	equ not true

cr	equ 13
lf	equ 10
bell	equ 7

epoch2k	equ	8035	; CP/M date for Jan 1 2000.
rtc	equ	0a0h	; standard port address

	extrn @cbnk
	extrn ?bnksl
	extrn @sec,@min,@hour,@date

	public ?time,?itime,@rtcstr

	cseg	; common memory, available no matter which bank

@rtcstr: db	'72421 ',0,'RTC Driver ',0,'v3.10'
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
	ret	; No RTC device in this implementation

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
	in	rtc+15
	ori	00000100b ; 24-hour format
	out	rtc+15
	; more to init?
	call	hold
	lxi	h,regs
	mvi	c,rtc-1
	mvi	b,12
gettm0:	inr	c
	inp	a
	ani	0fh
	mov	m,a
	inx	h
	djnz	gettm0
	call	unhold
	lxi	h,regs
	call	gtbcd
	sta	@sec
	call	gtbcd
	sta	@min
	call	gtbcd
	sta	@hour
	call	gtbin	; day of month
	mov	e,a
	call	gtbin	; month (1-12)
	dcr	a	; 0-11
	add	a	; * 2 for table lookup
	mov	d,a
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
	shld	@date
	pop	b
	pop	d
	pop	h
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

; Get (BCD digit) value from regs[] in binary
gtbin:	mov	b,m	; assume no masking required
	inx	h
	mov	a,m	; MSD
	inx	h
	add	a	; X * 2
	mov	c,a
	add	a
	add	a	; X * 8
	add	c	; (X * 8 + X * 2) = X * 10
	add	b	; + LSD
	ret

; Get (BCD digit) value from regs[] in BCD
gtbcd:	mov	b,m	; assume no masking required
	inx	h
	mov	a,m
	inx	h
	add	a
	add	a
	add	a
	add	a
	add	b
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
	mov	m,a
	inx	h
	mov	m,c
	inx	h
	ret

; store BCD value into (BCD) digit registers
stbcd:	mov	b,a
	ani	0fh
	mov	m,a
	inx	h
	mov	a,b
	rrc
	rrc
	rrc
	rrc
	ani	0fh
	mov	m,a
	inx	h
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

	end
