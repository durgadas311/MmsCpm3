; A util to test OLED display based on SSD1306

	maclib	core
	maclib	z80

CR	equ	13
LF	equ	10
TAB	equ	9
BS	equ	8
BEL	equ	7
CTLC	equ	3

rtc	equ	080h	; bit-bang port address
ss$clk	equ	00000100b
ds$ce	equ	00010000b
ds$wen	equ	00100000b
ds$clk	equ	01000000b
ds$wd	equ	10000000b
ds$wdn	equ	01111111b

linbuf	equ	2280h

oledz	equ	128*64/8

	cseg

	jmp	begin

	dseg

init:
	db	0aeh, 20h,0, 0c8h, 40h, 81h,7fh, 0a1h
	db	0a6h, 0a8h,3fh, 0d3h,0, 0d5h,80h, 0d9h,22h
	db	0dah,12h, 0dbh,20h, 8dh,14h, 0a4h, 0afh
	; now reset address
	db	21h,0,127, 22h,0,7
initz	equ	$-init

	ds	64
stack:	ds	0

ds$ctl:	db	ss$clk+ds$wen
col:	db	0

font:
	db	000h,000h,000h,000h,000h	; sp
	db	000h,000h,05Fh,000h,000h	; |
	db	000h,003h,000h,003h,000h	; "
	db	014h,03Eh,014h,03Eh,014h	; #
	db	024h,02Ah,07Fh,02Ah,012h	; $
	db	043h,033h,008h,066h,061h	; %
	db	036h,049h,055h,022h,050h	; &
	db	000h,005h,003h,000h,000h	; '
	db	000h,01Ch,022h,041h,000h	; (
	db	000h,041h,022h,01Ch,000h	; )
	db	014h,008h,03Eh,008h,014h	; *
	db	008h,008h,03Eh,008h,008h	; +
	db	000h,050h,030h,000h,000h	; ,
	db	008h,008h,008h,008h,008h	; -
	db	000h,060h,060h,000h,000h	; .
	db	020h,010h,008h,004h,002h	; /
	db	03Eh,051h,049h,045h,03Eh	; 0
	db	000h,004h,002h,07Fh,000h	; 1
	db	042h,061h,051h,049h,046h	; 2
	db	022h,041h,049h,049h,036h	; 3
	db	018h,014h,012h,07Fh,010h	; 4
	db	027h,045h,045h,045h,039h	; 5
	db	03Eh,049h,049h,049h,032h	; 6
	db	001h,001h,071h,009h,007h	; 7
	db	036h,049h,049h,049h,036h	; 8
	db	026h,049h,049h,049h,03Eh	; 9
	db	000h,036h,036h,000h,000h	; :
	db	000h,056h,036h,000h,000h	; ;
	db	008h,014h,022h,041h,000h	; <
	db	014h,014h,014h,014h,014h	; =
	db	000h,041h,022h,014h,008h	; >
	db	002h,001h,051h,009h,006h	; ?
	db	03Eh,041h,059h,055h,05Eh	; @
	db	07Eh,009h,009h,009h,07Eh	; A
	db	07Fh,049h,049h,049h,036h	; B
	db	03Eh,041h,041h,041h,022h	; C
	db	07Fh,041h,041h,041h,03Eh	; D
	db	07Fh,049h,049h,049h,041h	; E
	db	07Fh,009h,009h,009h,001h	; F
	db	03Eh,041h,041h,049h,03Ah	; G
	db	07Fh,008h,008h,008h,07Fh	; H
	db	000h,041h,07Fh,041h,000h	; I
	db	030h,040h,040h,040h,03Fh	; J
	db	07Fh,008h,014h,022h,041h	; K
	db	07Fh,040h,040h,040h,040h	; L
	db	07Fh,002h,00Ch,002h,07Fh	; M
	db	07Fh,002h,004h,008h,07Fh	; N
	db	03Eh,041h,041h,041h,03Eh	; O
	db	07Fh,009h,009h,009h,006h	; P
	db	01Eh,021h,021h,021h,05Eh	; Q
	db	07Fh,009h,009h,009h,076h	; R
	db	026h,049h,049h,049h,032h	; S
	db	001h,001h,07Fh,001h,001h	; T
	db	03Fh,040h,040h,040h,03Fh	; U
	db	01Fh,020h,040h,020h,01Fh	; V
	db	07Fh,020h,010h,020h,07Fh	; W
	db	041h,022h,01Ch,022h,041h	; X
	db	007h,008h,070h,008h,007h	; Y
	db	061h,051h,049h,045h,043h	; Z
	db	000h,07Fh,041h,000h,000h	; [
	db	002h,004h,008h,010h,020h	; 55
	db	000h,000h,041h,07Fh,000h	; ]
	db	004h,002h,001h,002h,004h	; ^
	db	040h,040h,040h,040h,040h	; _
	db	000h,001h,002h,004h,000h	; `
	db	020h,054h,054h,054h,078h	; a
	db	07Fh,044h,044h,044h,038h	; b
	db	038h,044h,044h,044h,044h	; c
	db	038h,044h,044h,044h,07Fh	; d
	db	038h,054h,054h,054h,018h	; e
	db	004h,004h,07Eh,005h,005h	; f
	db	008h,054h,054h,054h,03Ch	; g
	db	07Fh,008h,004h,004h,078h	; h
	db	000h,044h,07Dh,040h,000h	; i
	db	020h,040h,044h,03Dh,000h	; j
	db	07Fh,010h,028h,044h,000h	; k
	db	000h,041h,07Fh,040h,000h	; l
	db	07Ch,004h,078h,004h,078h	; m
	db	07Ch,008h,004h,004h,078h	; n
	db	038h,044h,044h,044h,038h	; o
	db	07Ch,014h,014h,014h,008h	; p
	db	008h,014h,014h,014h,07Ch	; q
	db	000h,07Ch,008h,004h,004h	; r
	db	048h,054h,054h,054h,020h	; s
	db	004h,004h,03Fh,044h,044h	; t
	db	03Ch,040h,040h,020h,07Ch	; u
	db	01Ch,020h,040h,020h,01Ch	; v
	db	03Ch,040h,030h,040h,03Ch	; w
	db	044h,028h,010h,028h,044h	; x
	db	00Ch,050h,050h,050h,03Ch	; y
	db	044h,064h,054h,04Ch,044h	; z
	db	000h,008h,036h,041h,041h	; {
	db	000h,000h,07Fh,000h,000h	; |
	db	041h,041h,036h,008h,000h	; }
	db	002h,001h,002h,004h,002h	; ~
	db	014h,014h,014h,014h,014h	; horiz lines // DEL

oledbuf:
	ds	0	; 1024 bytes

	cseg
begin:
	lxi	sp,stack
	lda	ds$ctl
	out	rtc	; initialzes ctl port to idle state

	lxi	h,prmpt
	call	msgout
	lxi	h,linbuf
	call	linin

	lxi	h,init
	lxi	b,initz
	mvi	e,00	; command bytes
	call	ssbuf
	jc	fail

	call	putmsg

	lxi	h,oledbuf
	lxi	b,oledz
	mvi	e,40h	; (display) data bytes
	call	ssbuf
	jc	fail

	call	crlf
	jr	exit

fail:
	lxi	h,failm
	call	msgout
	;jr	exit
exit:	lhld	retmon
	pchl

chrout:	liyd	conout
	pciy

failm:	db	13,10,'Failed to talk to SSD1306/OLED',13,10,0
prmpt:	db	13,10,'Enter message:',13,10,0

linix:	mvi	m,0	; terminate buffer
	jmp	crlf

; input a string from console, allow backspace
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

zerbuf:	lxi	h,oledbuf
	lxi	d,oledbuf
	lxi	b,oledz
	xra	a
	stax	d
	inx	d
	dcx	b
	ldir
	ret

putmsg:
	call	zerbuf
	lxi	d,oledbuf
	lxi	h,linbuf
pm0:	mov	a,m
	cpi	' '
	rc
	sui	' '
	inx	h
	push	h
	mov	l,a
	mvi	h,0
	dad	h
	dad	h
	mov	c,a
	mvi	b,0
	dad	b	; * 5
	lxi	b,font
	dad	b
	lda	col
	mov	c,a
	mvi	b,5
pm1:	mov	a,m
	stax	d
	inx	h
	inx	d
	inr	c
	djnz	pm1
	inx	d
	inr	c
	mov	a,c
	cpi	126
	jc	pm2
	inx	d
	inx	d
	xra	a
pm2:	sta	col
	pop	h
	jmp	pm0

; I2C routines, using NC-89 ports
; "in rtc" reads SDA on D0
; "out rtc" ... bit bang...

std:	db	0	; 00=STOP was done last

delay:	call	dly1
dly1:	ret

; assert I2C START condition, leave ready for clocking
; returns WEN low (on), SDA and SCL low (ready)
start:
	lda	ds$ctl
	ani	not ds$wen	; /WE active
	ori	ds$wd+ss$clk	; SDA and SCL high
	out	rtc
	call	delay		; need at least 1.3 uS "idle" time
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

	end
