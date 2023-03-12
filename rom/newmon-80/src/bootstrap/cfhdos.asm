; Bootstrap for Rick's HDOS CF.
; NOTE: this only works for segment A.

	maclib	ram

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

F$8BIT	equ	001h	; enable 8-bit transfer
F$NOWC	equ	082h	; disable write-cache

drv0	equ	70
ndrv	equ	2

boot2	equ	3000h

	org	2280h
boot:
	lxi	h,boot1
	lxi	d,boot2
	lxi	b,boot2len
copy:	mov	a,m
	stax	d
	inx	h
	inx	d
	dcx	b
	mov	a,b
	ora	c
	jnz	copy
	jmp	boot2

boot1:
	phase	boot2
	lxi	h,0	; def seg/lun
	shld	l2156h+2
	shld	l2156h+4
	shld	l2156h	; l2156h[0]=DRV|27:24, l2156h[1]=23:16
	lda	AIO$UNI	; 0000000d - 0/1
	adi	1	; 01b/10b
	out	CF$BA	; select CF card
	; assume CF already initialized
	mov	a,l
	ori	11100000b	; LBA mode + std "1" bits
	out	CF$DH	; LBA 27:4, drive 0, LBA mode
	mov	a,h
	out	CF$CH	; LBA 23:16
	xra	a
	out	CF$CL	; LBA 15:8
	mvi	a,0f1h
	out	CF$SE	; LBA 7:0
	mvi	a,10
	out	CF$SC	; 10 sectors (standard boot length)
	mvi	a,20h	; READ SECTORS
	out	CF$CS
	lxi	h,bootbf
	mvi	c,CF$DA
	mvi	e,10	; num sectors
	mvi	b,0	; should always be 0 after inir
bcf0:
	call	waitcf
	rc
	ani	1000b	; DRQ
	jz	bcf0
	call	inir	; 256 bytes
	call	inirN	; last 256 ignored
	dcr	e
	jnz	bcf0
	xra	a
	out	CF$BA	; deselect drive
	; final status check?
	ei
	jmp	bootbf

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

inirN:	mov	a,c
	sta	inirN0+1
inirN0:	in	0
	dcr	b
	jnz	inirN0
	ret

inir:	mov	a,c
	sta	inir0+1
inir0:	in	0
	mov	m,a
	inx	h
	dcr	b
	jnz	inir0
	ret

boot2len equ	$-boot2

	end
