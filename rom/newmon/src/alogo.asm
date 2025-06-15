; A command to display logo on SSD1306 OLED

	maclib	core
	maclib	z80

CR	equ	13
LF	equ	10
TAB	equ	9
BS	equ	8
BEL	equ	7
CTLC	equ	3

	maclib	ram
	maclib	z80

rtc	equ	081h	; bit-bang port address
ss$clk	equ	00000100b
ds$ce	equ	00010000b
ds$wen	equ	00100000b
ds$clk	equ	01000000b
ds$wd	equ	10000000b
ds$wdn	equ	01111111b

oledz	equ	128*64/8

	org	8000h
first:	db	HIGH (last-first)	; +0: num pages
	db	HIGH first		; +1: ORG page
	db	255,0	; ; +2,+3: phy drv base, num

	jmp	init	; +4: init entry
	jmp	exec	; +7: action entry

	db	'@'	; +10: Command letter
	db	-1	; +11: front panel key
	db	0	; +12: port, 0 if variable
	db	11111111b,11111111b,11111111b	; +13: FP display
	db	'Display logo',0	; +16: mnemonic string

init:	xra	a
	ret

exec:
	lda	ds$ctl
	out	rtc	; initialzes ctl port to idle state

	lxi	h,initc
	lxi	b,initz
	mvi	e,00	; command bytes
	call	ssbuf
	rc	; fail

	lxi	h,oledbuf
	lxi	b,oledz
	mvi	e,40h	; (display) data bytes
	call	ssbuf
	rc	; fail

	ret

chrout:	liyd	conout
	pciy

; I2C routines, using NC-89 ports
; "in rtc" reads SDA on D0
; "out rtc" ... bit bang...

std:	db	0	; 00=STOP was done last

dly2:	call	dly1
dly1:	ret

; assert I2C START condition, leave ready for clocking
; returns WEN low (on), SDA and SCL low (ready)
start:
	lda	ds$ctl
	ani	not ds$wen	; /WE active
	ori	ds$wd+ss$clk	; SDA and SCL high
	out	rtc
	call	dly2		; need at least 1.3 uS "idle" time
	ani	ds$wdn		; SDA goes low while SCL high = START
	out	rtc
	ani	not ss$clk
	out	rtc
	sta	ds$ctl
	ori	0ffh
	sta	std
	ret

; assert I2C STOP condition, assuming SDA and SCL currently low
; returns WEN high (off), SDA and SCL high
stop:
	lda	ds$ctl
	ani	not ds$wen	; /WE active - just in case
	ani	ds$wdn		; SDA low - just in case
	ori	ss$clk		; SCL high
	out	rtc
	ori	ds$wd		; SDA goes high while SCL high = STOP
	out	rtc
	ori	ds$wen		; WEN off
	out	rtc
	sta	ds$ctl
	xra	a
	sta	std
	ret

; output byte in E (destructive) over I2C
; returns ACK bit (0=success)
; assumes SDA and SCL low
ssput:
	push	b
	mvi	b,8
	lda	ds$ctl
	ani	not ds$wen	; /WE active - just in case
	out	rtc
ssp1:
	ral		; pop old data bit off...
	ralr	e	; CY = next data bit
	rar		; new data bit in place
	out	rtc
	ori	ss$clk		; clock high
	out	rtc
	ani	not ss$clk	; clock low
	out	rtc
	djnz	ssp1
	; go into ACK mode...
	ori	ds$wen		; stop driving SDA
	out	rtc
	ori	ss$clk		; clock high
	out	rtc
	push	psw
	in	rtc		; get ACK in D0
	mov	e,a
	pop	psw
	ani	not ss$clk	; clock low
	out	rtc
	sta	ds$ctl	; leave clk high, /WE asserted, data = ?
	mov	a,e
	ani	1
	pop	b
	ret

; command byte in E (destroyed)
; assume always write
; caller must STOP when done...
; return CY on error (STOP done)
sscmd:
	push	d	;
	lda	std
	ora	a
	jrnz	ssc0
	call	start
	mvi	e,78h	; SSD1306 address, WR
	call	ssput
	jnz	err
	mvi	e,0	; command(s) follow
	call	ssput
	jnz	err
ssc0:	pop	d
	call	ssput
	jnz	err1
	xra	a
	ret

err:	pop	d
err1:	call	stop

	mvi	a,'*'
	call	chrout
	stc
	ret

; data in (HL), BC=length, E=cmd/data (00/40)
; return CY on error (STOP done)
ssbuf:
	push	d
	lda	std
	ora	a
	cnz	stop	; must STOP before this?
	call	start
	mvi	e,78h	; SSD1306 address, WR
	call	ssput
	jnz	err
	pop	d	; E=cmd/data ctrl byte
	call	ssput
	jnz	err1
ssb0:	mov	e,m
	inx	h
	call	ssput
	jnz	err1
	dcx	b
	mov	a,b
	ora	c
	jnz	ssb0
	call	stop	; always STOP?
	xra	a
	ret

initc:
	db	0aeh, 20h,0, 0c8h, 40h, 81h,7fh, 0a1h
	db	0a6h, 0a8h,3fh, 0d3h,0, 0d5h,80h, 0d9h,22h
	db	0dah,12h, 0dbh,20h, 8dh,14h, 0a4h, 0afh
	; now reset address
	db	21h,0,127, 22h,0,7
initz	equ	$-initc

ds$ctl:	db	ss$clk+ds$wen
col:	db	0

oledbuf:	; "NC Super89", zilog-inside
	db	000h,0ffh,0ffh,00fh,03ch,0f0h,0c0h,000h
	db	000h,000h,0ffh,0ffh,000h,000h,080h,0e0h
	db	070h,03ch,00eh,007h,003h,003h,003h,003h
	db	003h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,00eh
	db	01fh,03bh,073h,0e3h,0c3h,003h,003h,003h
	db	00fh,00eh,000h,000h,0e0h,0e0h,000h,000h
	db	000h,000h,000h,000h,000h,0e0h,0e0h,000h
	db	000h,0e0h,0e0h,060h,060h,060h,060h,060h
	db	060h,060h,0e0h,0c0h,000h,000h,0e0h,0e0h
	db	060h,060h,060h,060h,060h,060h,060h,060h
	db	000h,000h,0e0h,0e0h,060h,060h,060h,060h
	db	060h,060h,060h,0e0h,0c0h,000h,000h,000h
	db	080h,080h,0feh,0ffh,083h,083h,0ffh,0feh
	db	080h,080h,000h,000h,000h,03eh,07fh,063h
	db	063h,063h,063h,063h,063h,0ffh,0feh,000h
	db	000h,0ffh,0ffh,000h,000h,000h,003h,00fh
	db	03ch,0f0h,0ffh,0ffh,000h,000h,001h,007h
	db	00eh,03ch,070h,0e0h,0c0h,0c0h,0c0h,0c0h
	db	0c0h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,070h
	db	0f0h,0c0h,0c0h,0c1h,0c3h,0c7h,0ceh,0dch
	db	0f8h,070h,000h,000h,03fh,07fh,0e0h,0c0h
	db	0c0h,0c0h,0c0h,0c0h,0e0h,07fh,03fh,000h
	db	000h,0ffh,0ffh,00ch,00ch,00ch,00ch,00ch
	db	00ch,00ch,00fh,007h,000h,000h,0ffh,0ffh
	db	0cch,0cch,0cch,0cch,0c0h,0c0h,0c0h,0c0h
	db	000h,000h,0ffh,0ffh,00ch,00ch,00ch,00ch
	db	01ch,03ch,07ch,0efh,0c7h,000h,000h,07fh
	db	0ffh,0c1h,0c1h,0c1h,0c1h,0c1h,0c1h,0c1h
	db	0c1h,0ffh,07fh,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,0c0h,0ffh,07fh,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,080h,0c0h,0c0h,0e0h,0e0h,0f0h
	db	0f0h,078h,078h,078h,03ch,03ch,03ch,01ch
	db	01eh,01eh,01eh,01eh,01eh,00eh,00fh,00fh
	db	00fh,00fh,09fh,09fh,01eh,01eh,01eh,01eh
	db	03eh,03eh,07eh,060h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,080h,0c0h,0e0h,070h,038h,01ch,00eh
	db	00fh,007h,003h,003h,001h,001h,000h,000h
	db	000h,0f8h,0f8h,000h,000h,000h,080h,080h
	db	080h,000h,000h,080h,0e0h,030h,030h,060h
	db	0f0h,000h,007h,007h,00fh,00fh,00fh,01fh
	db	01eh,01eh,03ch,078h,078h,0f0h,0e0h,0c0h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,0f0h,07ch
	db	01fh,007h,003h,030h,018h,00ch,00ch,0e6h
	db	0feh,01eh,000h,000h,008h,0f9h,0f9h,000h
	db	000h,0ffh,001h,000h,01eh,073h,041h,040h
	db	061h,03fh,000h,003h,08eh,088h,088h,0cch
	db	07fh,000h,000h,000h,040h,0c0h,000h,000h
	db	000h,000h,000h,000h,000h,000h,003h,007h
	db	01fh,0fch,0e0h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,03fh,0ffh,000h
	db	000h,000h,000h,000h,030h,03ch,03fh,01bh
	db	018h,00ch,00ch,000h,000h,087h,080h,000h
	db	080h,081h,000h,000h,000h,000h,000h,000h
	db	0c0h,060h,020h,030h,000h,000h,0f4h,0f4h
	db	000h,0e0h,030h,018h,008h,0ffh,000h,000h
	db	0fch,0b6h,013h,099h,0cfh,000h,000h,000h
	db	0c0h,0ffh,01fh,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,003h,00fh
	db	03ch,070h,0e0h,0c0h,080h,000h,000h,000h
	db	000h,000h,000h,000h,000h,0fch,07ch,000h
	db	000h,0ffh,00eh,003h,003h,03fh,0feh,000h
	db	081h,0c3h,066h,03ch,018h,000h,01fh,001h
	db	000h,007h,00ch,006h,003h,007h,000h,000h
	db	000h,081h,0c1h,0e1h,070h,038h,01ch,00fh
	db	003h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,001h,003h,007h,00eh,00ch
	db	01ch,018h,038h,038h,030h,073h,070h,060h
	db	060h,061h,060h,0e0h,0e0h,0e0h,0e0h,0e0h
	db	0e0h,060h,060h,060h,060h,070h,070h,030h
	db	030h,038h,018h,018h,01ch,00ch,006h,007h
	db	003h,003h,001h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm

last:	end
