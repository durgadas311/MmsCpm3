; Command module for Cassette tape load/store
	maclib	ram
	maclib	core
	maclib	z80

; ASCII control characters
STXc	equ	02h
SYNc	equ	16h

tpd	equ	0f8h	; data port
tpc	equ	0f9h	; ctrl/status port

	org	1000h
first:	db	HIGH (last-first)	; +0: num pages
	db	HIGH first		; +1: ORG page
	db	255,0	; +2,+3: phy drv base, num

	jmp	init	; +4: init entry
	jmp	cass	; +7: action entry

	db	-1	; +10: Command letter
	db	88h	; +11: front panel key
	db	0	; +12: port, 0 if variable
	db	11111111b,11111111b,11111111b	; +13: FP display
	db	'Cassette',0	; +16: mnemonic string

crcsum:	dw	0
savstk:	dw	0

init:
	mvi	a,01001110b	; 1 stop, no par, 8 data, 16x
	out	tpc
	xra	a
	out	tpc	; in case it was not "mode" state...
	xra	a	; NC
	ret

cass:
	sspd	savstk
	lda	lstcmd
	cpi	88h	; load key
	jrz	rmem
	jr	wmem

; "read memory" a.k.a. load from cassette
; load start => tpadr
; end adr => ABUSS
; exec adr => Reg[PC]
rmem:
	; setup error exit? tpabt -> (tperrx)...
load:	lxi	b,0fe00h
load0:	call	srs	; scan for record start...
	; DE=leader (8101h)
	; HA=byte count
	mov	l,a	; HL=byte count
	xchg		; DE=byte count, HL=leader
	dcr	c
	dad	b
	mov	a,h
	push	b
	push	psw	; A=leader(HI)
	ani	7fh
	ora	l
	mvi	a,2	; tape header error
	jrnz	tperr	; wrong type/seq
	call	rnp	; get PC
	mov	b,h
	mov	c,a	; BC=PC
	push	d
	lxi	d,24	; get PC
	lhld	RegPtr
	dad	d
	pop	d
	mov	m,c
	inx	h
	mov	m,b	; save PC in Reg[PC]
	call	rnp	; memory load address
	mov	l,a	; HL=load addr
	shld	tpadr
load1:	call	rnb	; data byte
	mov	m,a
	shld	ABUSS
	inx	h
	dcx	d
	mov	a,d
	ora	e
	jrnz	load1
	call	ctc	; verify checksum
	pop	psw	; A=leader(HI)
	pop	b	; BC=0fe00h...
	rlc
	jrc	tft
	jr	load0

ctc:	call	rnp
	lhld	crcsum
	mov	a,h
	ora	l
	rz
	mvi	a,1	; checksum error code
	;jr	tperr
tperr:	mov	m,a	; error code
	mov	b,a
	call	tft
	lspd	savstk
	ret

; "write memory" a.k.a. save to cassette
; tpadr=start of save
; ABUSS=end of save
; Reg[PC]=entry/start execution address
wmem:
	; setup error exit? tpabt -> (tperrx)...
	mvi	a,00000001b	; TxEn
	out	tpc
	mvi	a,SYNc
	mvi	b,32
wmem1:	call	wnb
	djnz	wmem1
	mvi	a,STXc
	call	wnb
	lxi	h,0
	shld	crcsum
	lxi	h,8101h
	call	wnp
	lhld	tpadr
	xchg
	lhld	ABUSS
	ora	a
	dsbc	d	; HL=length of data
	call	wnp
	push	h
	push	d
	lxi	d,24	; get PC
	lhld	RegPtr
	dad	d
	mov	a,m
	inx	h
	mov	h,m
	mov	l,a
	call	wnp
	pop	h	; former DE content
	pop	d	; former HL content
	call	wnp
wmem2:	mov	a,m
	call	wnb
	shld	ABUSS
	inx	h
	dcx	d
	mov	a,d
	ora	e
	jrnz	wmem2
	lhld	crcsum
	call	wnp
	call	wnp
; turn off tape and beep
tft:	xra	a
	out	tpc
	lxi	h,ctl$F0
	mov	a,m
	ani	01111111b	; beep on
	mov	m,a
	mvi	a,255
	call	delay
	mov	a,m
	ori	10000000b	; beep off
	mov	m,a
	ret

; scan for header...
; Returns DE=leader, HA=byte count
srs:	lxi	h,0
	mov	d,h
srs2:	call	rnb
	inr	d
	cpi	SYNc
	jrz	srs2
	cpi	STXc
	jrnz	srs
	mvi	a,10
	cmp	d
	jrnc	srs
	shld	crcsum	; zero checksum
	call	rnp	; leader code
	mov	d,h
	mov	e,a
	;jr	rnp	; byte count
; returns H=first byte, A=second byte
rnp:	call	rnb
	mov	h,a
	;jr	rnb
rnb:	mvi	a,00110100b	; Err reset, RTS, RxEn, no DTR
	out	tpc
rnb1:	call	tpxit
	ani	00000010b	; RxR
	jrz	rnb1
	in	tpd
	jr	crc

tpxit:	lda	kpchar
	cpi	01101111b	; cancel?
	in	tpc
	rnz
	xra	a
	sta	kpchar
	lspd	savstk
	ret

; HL=two bytes to save, big endian
wnp:	mov	a,h
	call	wnb
	mov	a,l
	; jr	wnb
wnb:	push	psw
wnb1:	call	tpxit	; check for cancel...
	ani	00000001b	; TxRdy
	jrz	wnb1
	mvi	a,00010001b	; TxEn, Err reset
	out	tpc
	pop	psw
	out	tpd
	;jr	crc
; A=data byte
crc:	push	b
	push	h
	mvi	b,8
	lhld	crcsum
crc1:	rlc
	mov	c,a
	slar	l
	ralr	h
	mov	a,h
	ral
	xra	c
	rrc
	jrnc	crc2
	mov	a,h
	xri	80h
	mov	h,a
	mov	a,l
	xri	05h
	mov	l,a
crc2:	mov	a,c
	djnz	crc1
	; A was RLCed 8 times, back to original value
	shld	crcsum
	pop	h
	pop	b
	ret

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm
if ($ > 1800h)
	.error	'Module overflow'
endif

last:	end
