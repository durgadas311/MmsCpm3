; MMS CPM3LDR/MPMLDR BIOS core code for RC2014/Z180
; Z180 I/O base used by RomWBW
iobase	equ	000h

	maclib	z180

	extrn	bdos
	extrn	loader

	public	biodma,biores,biotrk,biosec,biodsk,biotrn,d?read
	public	conout

	public	wboot,cboot,dsksta,timeot,mixer,dirbuf
	public	newdsk,newtrk,phytrk,newsec,dmaa

CR	equ	13
LF	equ	10
TAB	equ	9
BS	equ	8
BEL	equ	7
DEL	equ	127

msgout	equ	9

; Z180 ASC0 registers
ctlb	equ	iobase+03h
stat	equ	iobase+05h
tdr	equ	iobase+07h

	cseg
dsksta:	db	0
mixer:	db	-1

; patch space to hook into tick interrupt
timeot:
	ret
	nop
	nop

newdsk:	db	0
newtrk:	db	0
newsec:	db	0
phytrk:	dw	0
dmaa:	dw	0

signon:
	db	CR,LF,BEL,'RC-Z180 Loader v2.299'
	db	CR,LF,'$'

cboot:
	lxi sp,stack
	lxi d,signon
	mvi c,msgout
	call bdos
	call driver
	jmp loader

wboot:	; never called normally
	di
	hlt

biores:
	lxi b,0
	jmp biotrk

biodsk:
	mov a,c
	cpi 16
	jrnc nosel
	lda mixer
	mov c,a
	cpi 0ffh
	jrnz selok
nosel:
	lxi h,0
	ret

selok:
	mov a,c
	sta newdsk
	call d?sel
	lda newdsk
	mov c,a
	ret

biotrk:
	mov a,c
	sta newtrk
	sbcd phytrk
	ret

biotrn:
	mov l,c
	mov h,b
	inx h
	mov a,d
	ora e
	rz 
	xchg 
	dad b
	mov l,m
	mvi h,0
	ret

biosec:
	mov a,c
	dcr a
	sta newsec
	ret

biodma:
	sbcd dmaa
	ret

	ds	64
stack:	ds	0

dirbuf:	ds	128

; conout for standard Z180 ASCx
; TODO: make into module, for alternate console options
conout:
	in0	a,ctlb
	ani	00100000b	; /CTS
	jrnz	conout
	in0	a,stat
	ani	00000010b	; TDRE
	jrz	conout
	out0	c,tdr
	ret

driver:	equ	$+0	; init entry for disk driver module
d?sel:	equ	$+3
d?read:	equ	$+6

	end
