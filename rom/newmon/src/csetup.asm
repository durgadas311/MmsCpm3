; Command module for SETUP
VERN	equ	02h

false	equ	0
true	equ	not false

z180	equ	false
nofp	equ	false

	maclib	ram
	maclib	setup
 if z180
	maclib	z180
 else
	maclib	z80
 endif

CR	equ	13
LF	equ	10
BS	equ	8
CTLC	equ	3
BEL	equ	7
ESC	equ	27

 if z180
mmu$cbr	equ	38h
mmu$bbr	equ	39h
mmu$cbar equ	3ah
 endif

	org	8000h	; out of reach of ROM overlay...
first:	db	HIGH (last-first)	; +0: num pages
	db	HIGH first		; +1: ORG page
	db	255,0	; +2,+3: phy drv base, num

	jmp	init	; +4: init entry
	jmp	exec	; +7: action entry

	db	'C'	; +10: Command letter
	db	-1	; +11: front panel key
	db	0	; +12: port, 0 if variable
	db	11111111b,11111111b,11111111b	; +13: FP display
	db	'Config Setup',0	; +16: mnemonic string

init:
	xra	a	; NC
	ret

exec:
	lxi	d,signon
	call	msgout
	call	get$su	; get a copy of setup data
	cc	cserr	; offer to clear if checksum error
	; Primary/Default boot options
	lxi	d,gpdev
	lxi	h,last+dpdev
	call	getlet
	lxi	d,gpuni
	lxi	h,last+dpuni
	call	getnum
	lxi	d,gpstr
	lxi	h,last+dpstr
	call	getstr
 if not nofp
	; Secondary boot options
	lxi	d,gsdev
	lxi	h,last+dsdev
	call	getlet
	lxi	d,gsuni
	lxi	h,last+dsuni
	call	getnum
	lxi	d,gsstr
	lxi	h,last+dsstr
	call	getstr
 endif
	; Add-ons Installed
 if not z180
	lxi	d,g512k
	lxi	h,last+m512k
	call	getyn
 endif

	mvi	a,'6'
	sta	dport+1
	lxi	d,dport
	lxi	h,last+h67pt
	call	gethex

	mvi	a,'4'
	sta	dport+1
	lxi	d,dport
	lxi	h,last+h47pt
	call	gethex

	mvi	a,'3'
	sta	dport+1
	lxi	d,dport
	lxi	h,last+h37pt
	call	gethex

 if 0	; H17 is not configurable?
	mvi	a,'1'
	sta	dport+1
	lxi	d,dport
	lxi	h,last+h17pt
	call	gethex
 endif
	lxi	d,vport
	lxi	h,last+vdipt
	call	gethex
 if z180
	lxi	d,gwait
	lxi	h,last+waits
	call	getwt
 endif

	; TODO: more setup?
	lda	dirty
	ora	a
	jnz	mkchg
xxchg:	lxi	d,nochg
	call	msgout
	ret

mkchg:	lxi	d,dochg
	lxi	h,inbuf
	mvi	m,0ffh
	call	getyn
	lda	inbuf
	ora	a
	jrnz	xxchg
	lxi	d,last
	lxi	b,sulen
	call	schksm
	lhld	sum
	shld	ssum
	di
 if z180
	in0	a,mmu$cbar	; preserve monitor CBAR
	push	psw
	lda	ctl$F2
	push	psw
	mvi	b,1000$0000b
	out0	b,mmu$cbar
	mvi	b,0
	out0	b,mmu$cbr
	mvi	b,0f8h
	out0	b,mmu$bbr
	ori	10100000b	; WE, no legacy ROM
	out	0f2h
 else
	lda	ctl$F2
	push	psw
	ani	11011111b	; ORG0 off
	ori	10001000b	; WE, MEM1
	out	0f2h
 endif
	lxi	h,last
	lxi	d,suadr
	lxi	b,susize/64
	call	flash
	;jrc	error	; never returned, actually
	pop	psw
	push	psw
	ani	01111111b	; WE off
	out	0f2h
	lxi	d,suadr
	lxi	b,sulen
	call	vchksm
	lhld	sum
	xchg
	lhld	ssum
	ora	a
	dsbc	d
	jrnz	error
	pop	psw
	out	0f2h
 if z180
	xra	a
	out	mmu$bbr
	pop	psw
	out0	a,mmu$cbar
 endif
	ei
	lxi	d,saved
	call	msgout
	; Update monitor copy
	lxi	h,last
	lxi	d,susave
	lxi	b,sumax
	ldir
	ret

; PSW is on stack...
error:	pop	psw
	lxi	d,failed
	call	msgout
	ret	; what else can we do?

get$su:	di
 if z180
	in0	a,mmu$cbar	; preserve monitor CBAR
	push	psw
	lda	ctl$F2
	push	psw
	mvi	b,1000$0000b
	out0	b,mmu$cbar
	mvi	b,0
	out0	b,mmu$cbr
	mvi	b,0f8h
	out0	b,mmu$bbr
	ori	10100000b	; WE, no legacy ROM
	out	0f2h
	lxi	h,suadr
	lxi	d,last
	lxi	b,susize
	ldir
	pop	psw
	out	0f2h
	xra	a
	out0	a,mmu$bbr
	pop	psw
	out0	a,mmu$cbar
 else
	lda	ctl$F2
	push	psw
	ani	11011111b	; ORG0 off
	ori	00001000b	; MEM1
	out	0f2h
	lxi	h,suadr
	lxi	d,last
	lxi	b,susize
	ldir
	pop	psw
	out	0f2h
 endif
	ei
	lxi	d,last
	lxi	b,sulen
	call	vchksm
	ret	; CY=checksum error

; DE=code start, BC=length
; Returns CY on error
vchksm:	lxi	h,0
	shld	sum
vchk0:	ldax	d
	call	sum1
	inx	d
	dcx	b
	mov	a,b
	ora	c
	jrnz	vchk0
	lxi	h,sum
	mvi	b,2
vchk2:	ldax	d
	cmp	m
	stc
	rnz
	inx	d
	inx	h
	djnz	vchk2
	xra	a	; NC
	ret

; DE=code start, BC=length
; Sets checksum after code
schksm:	lxi	h,0
	shld	sum
schk0:	ldax	d
	call	sum1
	inx	d
	dcx	b
	mov	a,b
	ora	c
	jrnz	schk0
	lxi	h,sum
	mov	a,m
	stax	d
	inx	h
	inx	d
	mov	a,m
	stax	d
	ret

sum1:	lxi	h,sum
	add	m
	mov	m,a
	rnc
	inx	h
	inr	m
	ret

sum:	dw	0
ssum:	dw	0

liniz:	mvi	a,ESC
	sta	inbuf
	mvi	c,1
	jmp	crlf
linix:	mvi	m,0	; terminate buffer
	jmp	crlf

; input a filename from console, allow backspace
; returns C=num chars
linin:
	lxi	h,inbuf
	mvi	c,0	; count chars
lini0	call	conin
	cpi	CR
	jrz	linix
	cpi	ESC
	jrz	liniz
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
	jm	chrovf	; 128 chars max
	call	conout
	; TODO: detect overflow...
	jr	lini0
chrovf:	dcx	h
	dcr	c
chrnak:	mvi	a,BEL
	call	conout
	jr	lini0
backup:
	mov	a,c
	ora	a
	jrz	lini0
	dcr	c
	dcx	h
	mvi	a,BS
	call	conout
	mvi	a,' '
	call	conout
	mvi	a,BS
	call	conout
	jr	lini0

chrout:
conout:	push	psw
cono0:	in	0edh
	ani	00100000b
	jrz	cono0
	pop	psw
	out	0e8h
	ret

conin:	in	0edh
	ani	00000001b
	jrz	conin
	in	0e8h
	ani	01111111b
	ret

msgout:	ldax	d
	ora	a
	rz
	call	conout
	inx	d
	jr	msgout

; A=number to print
; leading zeroes blanked - must preserve B
decout:
	push	b
	mvi	c,0
	mvi	d,100
	call	divide
	mvi	d,10
	call	divide
	adi	'0'
	call	chrout
	pop	b
	ret

hexout:
	push	psw
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
	jmp	chrout

divide:	mvi	e,0
div0:	sub	d
	inr	e
	jrnc	div0
	add	d
	dcr	e
	jrnz	div1
	bit	0,c
	jrnz	div1
	ret
div1:	setb	0,c
	push	psw	; remainder
	mvi	a,'0'
	add	e
	call	chrout
	pop	psw	; remainder
	ret

parshx:
	mvi	d,0
px0:	mov	a,m
	ora	a
	rz
	sui	'0'
	rc
	cpi	'9'-'0'+1
	jrc	px3
	sui	'A'-'0'
	ani	11011111b	; toupper
	cpi	'F'-'A'+1
	cmc
	rc
	adi	10
px3:	mov	e,a
	mov	a,d
	add	a
	rc
	add	a
	rc
	add	a
	rc
	add	a
	rc
	add	e	; no CY possible
	mov	d,a
	inx	h
	djnz	px0
	ora	a
	ret

; Parse a 8-bit (max) decimal number
; HL=string, B=count
; Returns D=number, CY=error
parsnm:
	lxi	d,0
pd0:	mov	a,m
	ora	a
	rz
	cpi	'0'
	rc
	cpi	'9'+1
	cmc
	rc
	ani	0fh
	mov	e,a
	mov	a,d
	add	a	; *2
	rc
	add	a	; *4
	rc
	add	d	; *5
	rc
	add	a	; *10
	rc
	add	e	;
	rc
	mov	d,a
	inx	h
	djnz	pd0
	ora	a	; NC
	ret

; flash ROM from HL to DE, 64 bytes at a time.
; DE must be on a 64-byte boundary.
; BC=num pages to flash
; returns CY on error, else HL,DE at next 64 bytes
; caller must set WE... and MEM1 as needed.
flash:
	push	b
	lxi	b,64
	ldir
	; -----
	dcx	h
	dcx	d	; last addr written...
	; wait for write cycle to begin...
	; TODO: timeout this loop?
flash2:	ldax	d
	xra	m
	ani	10000000b	; bit7 is inverted when busy...
	jrz	flash2
	; wait for write cycle to end...
	; TODO: timeout this loop?
flash0:	ldax	d
	xra	m
	ani	10000000b	; bit7 is inverted when busy...
	jrnz	flash0
	inx	h
	inx	d
	; done with page...
	;call	progress	; TODO: progress needed?
	pop	b
	dcx	b
	mov	a,b
	ora	c
	jrnz	flash
	;xra	a	; NC already
	ret

crlf:	mvi	a,CR
	call	conout
	mvi	a,LF
	jmp	conout

cserr:	lxi	d,csbad
	call	msgout
	lxi	h,inbuf
	mvi	m,0ffh
	call	getyn
	lda	inbuf
	ora	a	; NZ=no
	jrnz	cserr9
	lxi	h,last
	mov	d,h
	mov	e,l
	mvi	m,0ffh
	inx	d
	lxi	b,susize-1
	ldir
	lxi	h,0
	shld	last+subase
	mvi	a,1
	sta	dirty
	ret

; CY preserved if set...
nmerr9:	pop	h	; discard saved HL
	pop	d	; discard saved DE
cserr9:	pop	h	; discard our ret adr
	jmp	xxchg	; return to monitor

; DE=prompt prefix, HL=value location
; get a Y/N, Wait for CR, allow BS.
; Stores 0ffh for "no", 000h for "yes"
getyn:
	call	msgout
	mov	a,m
	ora	a
	mvi	a,'N'
	jrnz	getyn1
	mvi	a,'Y'
getyn1:	call	conout
	lxi	d,gpunn
	call	msgout
getyn2:	call	conin
	cpi	CR
	jz	getlt1	; same processing
	ani	01011111b	; toupper
	cpi	'Y'
	jrz	getyn0
	cpi	'N'
	jrz	getyn0
	mvi	a,BEL
	call	conout
	jr	getyn2
getyn0:	call	conout
	sui	'N'	;  0='N',  X='Y'
	sui	1	; CY='N', NC='Y'
	sbb	a	; FF='N', 00='Y'
	mov	c,a
getyn5:	call	conin
	cpi	CR
	jrz	getlt3	; same processing
	cpi	BS
	jrz	getyn4
	mvi	a,BEL
	call	conout
	jr	getyn5
getyn4:	call	conout
	mvi	a,' '
	call	conout
	mvi	a,BS
	call	conout
	jr	getyn2

; DE=prompt prefix, HL=value location
; get a single letter, toupper. Wait for CR, allow BS
; TODO: allow value meaning "not defined"?
getlete:
	mvi	a,BEL
	call	conout
	call	crlf
getlet:
	sded	curmsg
	call	msgout
	mov	a,m
	cpi	0ffh
	jrz	getlt6
	call	conout
getlt6:	lxi	d,gpunn
	call	msgout
getlt2:	call	conin
	cpi	CR
	jrz	getlt1
	cpi	ESC
	jrz	getltx
	ani	01011111b	; toupper
	cpi	'B'	; 'A' means default, makes no sense here
	jrc	getlt0
	cpi	'Z'+1
	jrnc	getlt0
	; wait for CR, honor BS
	mov	c,a
	call	conout
getlt5:	call	conin
	cpi	CR
	jrz	getlt3
	cpi	BS
	jrz	getlt4
	cpi	ESC
	jrz	getltx
	mvi	a,BEL
	call	conout
	jr	getlt5
getlt4:	call	conout
	mvi	a,' '
	call	conout
	mvi	a,BS
	call	conout
	jr	getlt2
getlt3:	mov	m,c
	mvi	a,1
	sta	dirty
getlt1:	call	crlf
	ret
getlt0:	mvi	a,BEL
	call	conout
	jr	getlt2

; delete setting, re-prompt
getltx:	mvi	m,0ffh
	mvi	a,1
	sta	dirty
	lded	curmsg
	jr	getlete

; DE=prompt prefix, HL=value location
gethexe:
	mvi	a,BEL
	call	conout
gethex:
	push	d
	push	h
	call	msgout
	mov	a,m
	call	hexout
	lxi	d,gpunn
	call	msgout
	call	linin
	jc	nmerr9
	mov	a,c
	ora	a
	jrz	getxit
	lda	inbuf
	cpi	ESC	; delete setting
	jrz	gethxx
	mov	b,c
	lxi	h,inbuf
	call	parshx
	mov	a,d
	pop	h
	pop	d
	jrc	gethexe
	mov	m,a
	mvi	a,1
	sta	dirty
	ret

; delete setting, re-prompt
gethxx:	pop	h
	mvi	m,0ffh
	mvi	a,1
	sta	dirty
	pop	d
	jr	gethexe

; DE=prompt prefix, HL=value location
getnume:
	mvi	a,BEL
	call	conout
getnum:
	push	d
	push	h
	call	msgout
	mov	a,m
	cpi	0ffh
	jrz	getnm0
	call	decout
getnm0:	lxi	d,gpunn
	call	msgout
	call	linin
	jc	nmerr9
	mov	a,c
	ora	a
	jrz	getxit
	lda	inbuf
	cpi	ESC	; delete setting
	jrz	getnmx
	mov	b,c
	lxi	h,inbuf
	call	parsnm
	mov	a,d
	pop	h
	pop	d
	jrc	getnume
	mov	m,a
	mvi	a,1
	sta	dirty
	ret

; delete setting, re-prompt
getnmx:	pop	h
	mvi	m,0ffh
	mvi	a,1
	sta	dirty
	pop	d
	jr	getnume

getxit:	pop	h
	pop	d
	ret

; DE=prompt prefix, HL=value location
getstre:
	mvi	a,BEL
	call	conout
getstr:
	push	d
	push	h
	call	msgout
	mov	a,m
	cpi	0ffh
	jrz	getst0
	xchg
	call	msgout
getst0:	lxi	d,gpunn
	call	msgout
	call	linin
	jc	nmerr9
	mov	a,c
	ora	a
	jrz	getxit
	; no error checking left?
	pop	h
	pop	d
	; TODO: are we guaranteed 'inbuf' is terminated?
	lxi	d,inbuf
	ldax	d
	cpi	ESC	; delete setting
	jrz	getstx
getst2:	ldax	d
	ora	a
	jrz	getst1
	mov	m,a
	inx	h
	inx	d
	jr	getst2
getstx:	mvi	m,0ffh
	mvi	a,1
	sta	dirty
	jr	getstre
getst1:	mvi	m,0
	mvi	a,1
	sta	dirty
	ret

 if z180
getwte:	mvi	a,BEL
	call	conout
getwt:
	push	d
	push	h
	call	msgout
	mov	a,m
	call	wtout
	lxi	d,gpunn
	call	msgout
	call	linin
	jc	nmerr9
	mov	a,c
	ora	a
	jrz	getxit
	lda	inbuf
	cpi	ESC	; delete setting
	jrz	getwtx
	mov	b,c
	lxi	h,inbuf
	call	parwt
	pop	h
	pop	d
	jrc	getwte
	mov	m,a
	mvi	a,1
	sta	dirty
	ret

getwtx:	pop	h
	mvi	m,0ffh
	mvi	a,1
	sta	dirty
	pop	d
	jr	getwte

wtout:	cpi	0ffh
	rz
	push	psw
	rlc
	rlc
	call	wtout1
	mvi	a,','
	call	conout
	pop	psw
	rrc
	rrc
	rrc
	rrc
wtout1:	ani	3
	adi	'0'
	jmp	conout

parwt:	call	parwt1
	rc
	rrc
	rrc
	mov	d,a
	inx	h
	mov	a,m
	cpi	','
	stc
	rnz
	inx	h
	call	parwt1
	rc
	rlc
	rlc
	rlc
	rlc
	ora	d
	mov	d,a
	inx	h
	mov	a,m
	sui	1	; CY only if was 00
	cmc
	mov	a,d
	ret

parwt1:
	mov	a,m
	sui	'0'
	rc
	cpi	'3'-'0'+1
	cmc
	ret
 endif

signon:	db	'onfig setup v'
	db	(VERN SHR 4)+'0','.',(VERN AND 0fh)+'0'
	db	CR,LF,0

csbad:	db	'Setup bank checksum error. Clear setup data (',0
nochg:	db	'Setup not changed',CR,LF,0
dochg:	db	'Save changes (',0
saved:	db	'Setup data saved',CR,LF,0
failed:	db	'Setup flash failed, checksum error',CR,LF,0

gpunn:	db	'): ',0
gpdev:	db	'Primary/Default boot device (',0
gpuni:	db	'Primary/Default boot unit (',0
gpstr:	db	'Primary/Default boot string (',0
 if not nofp
gsdev:	db	'Secondary boot device (',0
gsuni:	db	'Secondary boot unit (',0
gsstr:	db	'Secondary boot string (',0
 endif
 if not z180
g512k:	db	'H8-512K RAM installed (',0
 endif
dport:	db	'H_7 Port (FF=use SW1) (',0
vport:	db	'VDIP1 Port (FF=(D8)) (',0
 if z180
gwait:	db	'WAIT states (MEM,I/O) (',0
 endif

dirty:	db	0
curmsg:	dw	0

inbuf:	ds	128	; input entry buffer

	ds	128
stack:	ds	0

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm

last:	end
