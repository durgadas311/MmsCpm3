; Unix(Linux) "sum" algorithm on CP/M
; Accepts only one, unambiguous, filename.
; Does not handle text EOF ^Z or byte-count.

	maclib	z80

sysv$sum equ	0	; TODO: commandline option

WBOOT	equ	0000h
BDOS	equ	0005h
FCB	equ	005ch
CMDLINE	equ	0080h

CR	equ	13
LF	equ	10
EOF	equ	26

CONOUT	equ	2
PRINT	equ	9
OPEN	equ	15
CLOSE	equ	16
READ	equ	20
SETDMA	equ	26

BUFLEN	equ	128

	org	0100h
	jmp	start

parms:	db	13,10,'Requires filename$'
opnerr:	db	13,10,'File not found$'

 if sysv$sum
s:	db	0,0,0,0	; 32-bit integer, LE
chksum:	db	0,0,0,0	; final result, LE
 else	; BSD sum
chksum	dw	0
 endif
totbyt:	db	0,0,0,0	; total bytes, LE

; add A to 32-bit sum in HL
add32a:
	add	m
	mov	m,a
	rnc
	inx	h
	mvi	a,0
	adc	m
	mov	m,a
	rnc
	inx	h
	mvi	a,0
	adc	m
	mov	m,a
	rnc
	inx	h
	mvi	a,0
	adc	m
	mov	m,a
	ret	; CY indicates overflow

; add DE to 32-bit sum in HL
add32de:
	mov	a,e
	add	m
	mov	m,a
	inx	h
	mov	a,d
	adc	m
	mov	m,a
	rnc
	inx	h
	mvi	a,0
	adc	m
	mov	m,a
	rnc
	inx	h
	mvi	a,0
	adc	m
	mov	m,a
	ret	; CY indicates overflow

; TODO: support things like A:=B:*.asm[u]
start:
	lxi	sp,stack
	lda	FCB+1
	cpi	' '
	jz	nofile	; no file specified
	lxi	d,FCB
	mvi	c,OPEN
	call	BDOS
	inr	a
	jz	notfnd	; No such file
loop:
	lxi	d,buf
	mvi	c,SETDMA
	call	BDOS
	lxi	d,FCB
	mvi	c,READ
	call	BDOS
	ora	a
	jnz	done	; TODO: differentiate?
	lxi	h,buf
	mvi	b,128
 if sysv$sum
sumloop:
	mov	a,m
	inx	h
	push	h
	push	b
	lxi	h,s
	call	add32a	; s += buf[i];
	pop	b
	pop	h
	djnz	sumloop
 else	; BSD sum
sumloop:
	lded	chksum
	; checksum = (checksum >> 1) + ((checksum & 1) << 15);
	srlr	d
	rarr	e
	jrnc	sl0
	setb	7,d
sl0:
	mov	a,e
	add	m
	mov	e,a
	mvi	a,0
	adc	d
	mov	d,a
	sded	chksum	; checksum += ch; (mod 16-bit)
	inx	h
	djnz	sumloop
 endif
	lxi	h,totbyt
	mvi	a,128
	call	add32a	; total_bytes += bytes_read;
	jmp	loop
done:
	lxi	d,FCB
	mvi	c,CLOSE
	call	BDOS
 if sysv$sum
	lhld	s+2	; HL = ((s & 0xffffffff) >> 16)
	lded	s	; DE = (s & 0xffff)
	dad	d	; (s & 0xffff) + ((s & 0xffffffff) >> 16) [CY]
	shld	r	; r = (s & 0xffff) + ((s & 0xffffffff) >> 16);
	mvi	a,0
	adc	a
	sta	r+2	; with CY
	lhld	r
	lded	r+2
	dad	d	; checksum = (r & 0xffff) + (r >> 16);
 else	; BSD sum
	lhld	chksum
 endif
	mvi	c,1	; zero-fill
	call	dec16
	call	space
	; ... print size, w/o "human_readable" junk.
	; round up to next 1K-byte block...
	lxi	h,totbyt
	lxi	d,1023	; TODO: SYSV sum uses 512...
	call	add32de
	; TODO: handle more than 16M?
	lhld	totbyt+1	; divide by 1024... >> (2+8)
	srlr	h
	rarr	l
	srlr	h
	rarr	l
	mvi	c,0	; blank-fill
	call	dec16
	call	crlf
	jmp	WBOOT

nofile:	lxi	d,parms
err:	mvi	c,PRINT
	call	BDOS
	jmp	WBOOT
notfnd:	lxi	d,opnerr
	jr	err

; print HL in decimal, c=zero suppression/print
dec16:
	; remainder in HL
	lxi	d,10000
	call	div16
	lxi	d,1000
	call	div16
	lxi	d,100
	call	div16
	lxi	d,10
	call	div16
	mov	a,l
	adi	'0'
	mov	e,a
	jmp	chrout

; divide HL/DE, remainder in HL
; assert(HL/DE < 10) (one digit)
div16:	mvi	b,0
dv0:	ora	a
	dsbc	d
	inr	b
	jrnc	dv0
	dad	d
	dcr	b
	jrnz	dv1
	bit	0,c
	jrnz	dv1
	mvi	a,' '
	jr	dv2
dv1:	setb	0,c
	mvi	a,'0'
	add	b
dv2:	push	h	; save remainder
	push	b
	mov	e,a
	call	chrout
	pop	b
	pop	h
	ret

space:	mvi	e,' '
chrout:	mvi	c,CONOUT
	jmp	BDOS

crlf:	mvi	e,13
	call	chrout
	mvi	e,10
	jmp	chrout

; end of program code
stack	equ	$+64

buf	equ	stack

	end
========================================
