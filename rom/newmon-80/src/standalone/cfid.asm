; Stand-alone program to read two sectors from Z67 and dump in hex/ascii

DUMPZ	equ	256	; 128, 256, 512
TEST	equ	0	; use test data, don't read CF

	maclib	core

CF$BA	equ	80h		; CF base port
CF$DA	equ	CF$BA+8	; CF data port
CF$ER	equ	CF$BA+9	; CF error register (read)
CF$FR	equ	CF$BA+9	; CF feature register (write)
CF$SC	equ	CF$BA+10	; CF sector count
CF$SE	equ	CF$BA+11	; CF sector number
CF$CL	equ	CF$BA+12	; CF cylinder low
CF$CH	equ	CF$BA+13	; CF cylinder high
CF$DH	equ	CF$BA+14	; CF drive/head
CF$CS	equ	CF$BA+15	; CF command/status

CMD$FEA	equ	0efh	; Set Features command
CMD$IDD	equ	0ech	; Identify Device

F$8BIT	equ	001h	; enable 8-bit transfer
F$NOWC	equ	082h	; disable write-cache

CR	equ	13
LF	equ	10

; locations in CF ID buffer
DEFCYL	equ	1 shl 1
DEFHDS	equ	3 shl 1
DEFSPT	equ	6 shl 1
DEFCAP	equ	7 shl 1	; double-word
MODEL	equ	27 shl 1
MODELZ	equ	40 shr 1
SN	equ	10 shl 1
SNZ	equ	20 shr 1
FWREV	equ	23 shl 1
FWREVZ	equ	8 shr 1

	cseg
start:
	lxi	sp,stack
	; must scan past command name...
	lxi	h,2280h
	mov	b,m	; len
	inx	h
skipb:	mov	a,m
	inx	h
	ora	a
	jz	skp1
	cpi	' '
	jnz	skipb

skp0:	mov	a,m
	inx	h
	ora	a
	jz	skp1
	cpi	'1'
	jz	skp2
	ani	01011111b
	cpi	'D'
	jnz	skp0
	sta	dmp
	jmp	skp0
skp2:	sui	'0'
	sta	lun
	jmp	skp0
skp1:
if not TEST
	; TODO: get LUN from command buffer...
	lda	lun
	adi	1	; 01b/10b
	out	CF$BA	; select CF card
	xra	a
	out	CF$FR	; needed after power-on?
	; select 8-bit mode
	mvi	a,F$8BIT
	out	CF$FR
	mvi	a,CMD$FEA
	out	CF$CS
	call	waitcf
	jc	fail
	; disable write-cache
	mvi	a,F$NOWC
	out	CF$FR
	mvi	a,CMD$FEA
	out	CF$CS
	call	waitcf
	jc	fail
	xra	a
	out	CF$DH	; LBA 27:4, drive 0, LBA mode
	mvi	a,CMD$IDD
	out	CF$CS
	lxi	h,buffer
	mvi	c,CF$DA
	mvi	b,0	; should always be 0 after inir
bcf0:
	call	waitcf
	jc	fail
	ani	1000b	; DRQ
	jz	bcf0
	call	inir	; 256 bytes
	call	inir	; 512 bytes
	xra	a
	out	CF$BA	; deselect drive
endif
	call	crlf
; Now dump data...
	; in all cases, dump 512 bytes.
	lda	dmp
	ora	a
	jz	nodump
	lxi	h,buffer
	lxi	d,DUMPZ
	call	dump
	jmp	exit
nodump:
	lxi	h,modmsg
	call	msgout
	lxi	h,buffer+MODEL
	mvi	b,MODELZ
	call	string
	call	crlf
	lxi	h,snmsg
	call	msgout
	lxi	h,buffer+SN
	mvi	b,SNZ
	call	string
	call	crlf
	lxi	h,fwrmsg
	call	msgout
	lxi	h,buffer+FWREV
	mvi	b,FWREVZ
	call	string
	call	crlf
	lxi	h,cylmsg
	call	msgout
	lxi	h,buffer+DEFCYL
	call	decihl
	lxi	h,hdsmsg
	call	msgout
	lxi	h,buffer+DEFHDS
	call	decihl
	lxi	h,sptmsg
	call	msgout
	lxi	h,buffer+DEFSPT
	call	decihl
	call	crlf
	lxi	h,capmsg
	call	msgout
	lxi	h,buffer+DEFCAP
	call	d32ihl
	lxi	h,blkmsg
	call	msgout
	call	crlf
exit:
	lhld	retmon
	pchl

fail:
	lxi	h,errmsg
	call	msgout
	jmp	exit

; HL=buf, B=len in words
string:	mvi	e,0	; leading blank suppression
	mov	c,m
	inx	h
	mov	a,m
	inx	h
	call	debchr
	mov	a,c
	call	debchr
	dcr	b
	jnz	string
	ret
; suppress leading blanks...
debchr:	cpi	' '
	jnz	deb0
	dcr	e
	inr	e
	rz
deb0:	mvi	e,1
	jmp	chrout

; HL=buffer, DE=length (multiple of 16)
dump:
	call	dmpline
	call	crlf
	lxi	b,16
	dad	b
	xchg
	ora	a
	call	dsbcb
	xchg
	mov	a,d
	ora	e
	jnz	dump
	ret

; Dump 16 bytes at HL
dmpline:
	push	d
	push	h
	; yuk... need offset, not address...
	lxi	d,buffer
	ora	a
	call	dsbcd
	call	hexwrd
	mvi	a,':'
	call	chrout
	; blank space provided by dmphex
	pop	h
	push	h
	call	dmphex
	lxi	h,spcs
	call	msgout
	pop	h
	push	h
	call	dmpchr
	pop	h
	pop	d
	ret

dmphex:
	mvi	b,16
dh0:	mvi	a,' '
	call	chrout
	mov	a,m
	call	hexout
	inx	h
	dcr b ! jnz	dh0
	ret

dmpchr:
	mvi	b,16
dc0:	mov	a,m
	cpi	' '
	jc	dc1
	cpi	'~'+1
	jc	dc2
dc1:	mvi	a,'.'
dc2:	call	chrout
	inx	h
	dcr b ! jnz	dc0
	ret

; HL=word
hexwrd:	mov	a,h
	call	hexout
	mov	a,l
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
chrout:	push	h
	lhld	conout
	xthl
	ret


; load (HL) into HL and print
decihl:
	mov	a,m
	inx	h
	mov	h,m
	mov	l,a
; Print out HL in decimal
decwrd:
	mvi	c,0	; leading zero suppression
dec16:
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
	call	chrout
	ret

div16:	mvi	b,0
dv0:	ora	a
	call	dsbcd
	inr	b
	jnc	dv0
	dad	d
	dcr	b
	jnz	dv1
	mov	a,c
	ora	a
	jnz	dv1
	ret
dv1:	mvi	c,1
	mvi	a,'0'
	add	b
	call	chrout
	ret

; HL = (int32) - MSW, LSW, little-endian words
d32ihl:
	mov	c,m
	inx	h
	mov	b,m
	inx	h
	mov	e,m
	inx	h
	mov	d,m
; print number in BC:DE
dec32:
	mvi	l,0
	mvi	h,9
	push	h	; control vars on stack
	lxi	h,mlt10
dd1:	xra	a
dd0:	call	sub32
	inr	a
	jnc	dd0
	call	add32
	xthl	; control vars in HL
	dcr	a
	jnz	dd2
	dcr	l
	inr	l
	jz	dd3
dd2:	mvi	l,1
	adi	'0'
	call	chrout
dd3:
	dcr	h
	xthl	; control vars back on stack
	inx	h
	inx	h
	inx	h
	inx	h
	jnz	dd1
	pop	h
	mvi	a,'0'
	add	e
	jmp	chrout

mlt10:
	db	3Bh,9Ah,0CAh,00h	;  1,000,000,000
	db	05h,0F5h,0E1h,00h	;    100,000,000
	db	00h,98h,96h,80h		;     10,000,000
	db	00h,0Fh,42h,40h		;      1,000,000
	db	00h,01h,86h,0A0h	;        100,000
	db	00h,00h,27h,10h		;         10,000
	db	00h,00h,03h,0E8h	;          1,000
	db	00h,00h,00h,64h		;            100
	db	00h,00h,00h,0ah		;             10

; BC:DE += (mlt10[HL])
add32:	push	psw
	inx	h
	inx	h
	inx	h
	mov	a,e
	add	m
	mov	e,a
	dcx	h
	mov	a,d
	adc	m
	mov	d,a
	dcx	h
	mov	a,c
	adc	m
	mov	c,a
	dcx	h
	mov	a,b
	adc	m
	mov	b,a
	pop	psw
	ret	; CY ignored

; BC:DE += (mlt10[HL])
sub32:	push	psw
	inx	h
	inx	h
	inx	h
	mov	a,e
	sub	m
	mov	e,a
	dcx	h
	mov	a,d
	sbb	m
	mov	d,a
	dcx	h
	mov	a,c
	sbb	m
	mov	c,a
	dcx	h
	mov	a,b
	sbb	m
	mov	b,a
	; CY = borrow... must preserve
	jc	sb0
	pop	psw
	ora	a	; NC
	ret
sb0:	pop	psw
	stc
	ret

; Returns A=CF status register byte, or CY for error
; trashes D, must preserve HL, BC, E
waitcf:
	in	CF$CS
	mov	d,a
	ora	a
	jm	waitcf	; busy
	mvi	a,1	; error
	ana	d
	jnz	cferr
	mvi	a,01000000b	; ready
	ana	d	; NC
	jz	cferr
	mov	a,d
	ret

cferr:
	xra	a
	out	CF$BA	; deselect drive
	stc
	ret

spcs:	db	'    ',0

; HL = HL - DE - CY
dsbcd:	mov	a,l
	sbb	e
	mov	l,a
	mov	a,h
	sbb	d
	mov	h,a
	ret
dsbcb:	mov	a,l
	sbb	c
	mov	l,a
	mov	a,h
	sbb	b
	mov	h,a
	ret

inir:	mov	a,c
	sta	inir0+1
inir0:	in	0
	mov	m,a
	inx	h
	dcr	b
	jnz	inir0
	ret

dmp:	db	0	; 'D' if dump hex vs. print info
lun:	db	0
modmsg:	db	'Model: ',0
snmsg:	db	'S/N: ',0
fwrmsg:	db	'Rev: ',0
cylmsg:	db	'Cylinders: ',0
hdsmsg:	db	', Heads: ',0
sptmsg:	db	', Sectors: ',0
capmsg:	db	'Capacity: ',0
blkmsg:	db	' blocks(sectors)',0
errmsg:	db	'CF command failed',CR,LF,0

	ds	128
stack:	ds	0

buffer:	ds	0	; 512
if TEST
; Data from Norberto's 4G SanDisk:
	db	8Ah,84h,1Ch,1Fh,00h,00h,10h,00h,00h,00h,40h,02h,3Fh,00h,7Ah,00h
	db	40h,7Eh,00h,00h,20h,20h,20h,20h,31h,30h,36h,32h,30h,31h,31h,49h
	db	30h,39h,4Ah,38h,39h,31h,35h,32h,02h,00h,02h,00h,04h,00h,44h,48h
	db	20h,58h,2Eh,34h,32h,33h,61h,53h,44h,6Eh,73h,69h,20h,6Bh,44h,53h
	db	46h,43h,32h,48h,30h,2Dh,34h,30h,20h,47h,20h,20h,20h,20h,20h,20h
	db	20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,04h,00h
	db	00h,00h,00h,03h,00h,00h,00h,02h,00h,00h,03h,00h,1Ch,1Fh,10h,00h
	db	3Fh,00h,40h,7Eh,7Ah,00h,00h,01h,40h,7Eh,7Ah,00h,00h,00h,07h,00h
; 0080:
	db	03h,00h,78h,00h,78h,00h,78h,00h,78h,00h,00h,00h,00h,00h,00h,00h
	db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	db	10h,00h,00h,00h,20h,00h,04h,40h,00h,40h,00h,00h,04h,00h,00h,40h
	db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
; 0100: data not gathered
	db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
; 0180: data not gathered
	db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
endif

	end
