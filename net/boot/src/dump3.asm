; Standalone utility to dump core for CP/M 3 on H8x512K
	maclib	z80
	aseg

; H8x512K MMU constants
mmu	equ	0	; base port
rd	equ	0
wr	equ	4
pg0k	equ	0
pg16k	equ	1
pg32k	equ	2
pg48k	equ	3
ena	equ	80h
rd00k	equ	mmu+rd+pg0k
rd16k	equ	mmu+rd+pg16k
rd32k	equ	mmu+rd+pg32k
rd48k	equ	mmu+rd+pg48k
wr00k	equ	mmu+wr+pg0k
wr16k	equ	mmu+wr+pg16k
wr32k	equ	mmu+wr+pg32k
wr48k	equ	mmu+wr+pg48k

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
pagex:	ds	1	; dma extension for 512K

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
wizclsp	equ	0036h	; pointer, not vector
sndrcv	equ	0023h
conop	equ	0026h	; pointer, not vector

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

	; setup/activate MMU
	call	mmu$init
	; from here on, must exit via mmu$deinit

	; just map each page into pg48k and dump from there
	lxi	h,0
	shld	dma
	xra	a
	sta	pagex
	call	setdma
	jc	mmu$deinit
	; no need to setdma again, everything is sent in order

loop0:
	call	map$page
	lxi	h,0c000h	; page 48K
	shld	dma
loop1:
	lxi	d,msg$dat
	lxi	b,128
	ldir
	shld	dma
	mvi	a,128-1
	sta	msg$siz
	mvi	a,03h	; put data to dmadr...
	sta	msg$fnc
	call	sendit
	jc	mmu$deinit
	lhld	dma
	mov	a,h
	ora	l
	jz	gotpg
	mov	a,h
	ani	0fh	; at 4K boundary?
	ora	l
	jnz	loop1
	push	h
	mvi	a,'.'
	call	conout
	pop	h
	jmp	loop1
gotpg:
	lda	pagex
	inr	a
	sta	pagex
	cpi	13	; done after pages 0-12
	jnc	done
	jmp	loop0
done:
	call	mmu$deinit	; now safe to return directly
	mvi	a,04h	; end dump
	sta	msg$fnc
	xra	a
	sta	msg$siz
	call	sendit
	rc
	call	wizclose
	jmp	0	; restart ROM, or...?

setdma:	; HL=remote dma adr
	shld	msg$dat
	mvi	a,2-1
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
	lda	msg$fnc
	cpi	01h	; ACK
	rz
	stc	; NAK - no more dumping
	ret

wizclose:
	lhld	wizclsp
	pchl

conout:
	lhld	conop
	pchl

; Create "unity" page mapping, enable MMU
mmu$init:
	mvi	a,0	; page 0
	out	rd00k
	out	wr00k
	inr	a
	out	rd16k
	out	wr16k
	inr	a
	out	rd32k
	out	wr32k
	inr	a
	ori	ena
	out	rd48k
	out	wr48k
	ret

mmu$deinit:
	mvi	a,0
	out	rd00k	; disables MMU, forces 64K
	ret

map$page:
	lda	pagex	; page we're on
	ori	ena
	out	rd48k
	ret

endpre:	ds	0
	rept	128-((endpre-begin) and 07fh)
	db	0
	endm
endadr:	ds	0

	end
