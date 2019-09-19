; Standalone utility to dump core for 64K standard (ORG0)
	maclib	z80
	aseg

; ROM constants
ctl$F2	equ	2036h

; WIZNET constants
sock0	equ	000$01$000b	; base pattern for Sn_ regs

	org	2280h
server:	ds	1	; SID, dest of send
nodeid:	ds	1	; our node id
cursok:	ds	1	; current socket select patn
curptr:	ds	2	; into chip mem
msgptr:	ds	2
msglen:	ds	2
totlen:	ds	2
dma:	ds	2
; extensions:
phase:	ds	1

	org	2300h
msgbuf:	ds	0
msg$fmt: ds	1
msg$did: ds	1
msg$sid: ds	1
msg$fnc: ds	1
msg$siz: ds	1
msg$dat: ds	128

; ROM hooks
wizopen	equ	0033h
sndrcv	equ	0023h

; e.g. org 2400h...
	cseg
	org	0
begin:	di
	; all should be setup from boot, except socket is closed.
	lda	cursok
	ori	sock0
	mov	d,a
	call	wizopen
	rc	; still OK to return on error?
	xra	a
	sta	phase
	; phase 0: dump from our end to top of memory...
	lxi	h,endadr	; must be 128 boundary
loop0:	shld	dma
	call	setdma
	rc
	lhld	dma
loop1:
	lxi	d,msg$dat
	lxi	b,128
	ldir
	mvi	a,128-1
	sta	msg$siz
	mvi	a,03h	; put data to dmadr...
	sta	msg$fnc
	call	sendit
	rc
	lhld	dma
	lxi	b,128
	dad	b
	mov	a,h
	ora	l
	jz	got64k
	shld	dma
	jmp	loop1
got64k:
	lda	phase
	inr	a
	sta	phase
	cpi	2
	jnc	ph2
	; phase 1: dump low 8K into higher memory...
	lda	ctl$F2
	ori	20h	; ORG0 on
	out	0f2h
	lxi	h,0
	lxi	d,-8192
	lxi	b,8192
	ldir
	lda	ctl$F2
	out	0f2h	; ORG0 off
	lxi	h,0
	call	setdma
	rc
	lxi	h,-8192
	jmp	loop0
ph2:
	cpi	3
	jnc	done
	; phase 2: dump bogus data for trashed memory
	lxi	h,endadr
	lxi	d,2000h
	ora	a
	dsbc	d	; length of chunk
	mov	b,h
	mov	c,l
	lxi	h,0
	ora	a
	dsbc	b	; high memory start
	push	h
	mvi	m,0ffh
	mov	d,h
	mov	e,l
	inx	d
	dcx	b
	ldir	; fill with 0ffh
	pop	h	; address to dump from
	jmp	loop0

done:
	mvi	a,04h	; end dump
	sta	msg$fnc
	xra	a
	sta	msg$siz
	call	sendit
	rc
	; TODO: how to close...
	jmp	0	; or...?

setdma:	; HL=remote dma adr
	shld	msg$dat
	mvi	a,1-1
	sta	msg$siz
	mvi	a,02h	; set dma
	sta	msg$fnc
	;jmp	sendit

sendit:
	mvi	a,0d0h
	sta	msg$fmt
	call	sndrcv
	rc
	lda	msg$fmt
	cpi	0d1h
	stc
	rnz	; protocol error
	xra	a
	ret

endpre:	ds	0
	rept	128-((endpre-begin) and 07fh)
	db	0
	endm
endadr:	ds	0

	end
