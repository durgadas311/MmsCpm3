; MMS CPM3LDR BIOS core code

	maclib	z80

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

; locations in page-0
rst1	equ	0008h	; 2mS clock interrupt vector
ticker	equ	000bh	; 2mS counter
gpbyte	equ	000dh	; image of curr GPP bits
xxbyte	equ	000eh	; what device is this for?

msgout	equ	9

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
	db	CR,LF,BEL,'Z89/Z90 Loader v2.241  (c) 1982,1983 Magnolia Microsystems'
	db	CR,LF,'$'

cboot:
	lxi sp,stack
	mvi a,080h
	sta xxbyte
	out 07fh
	lxi d,signon
	mvi c,msgout
	call bdos
	di
	mvi a,0c3h
	sta rst1
	lxi h,tick
	shld rst1+1
	lxi h,0
	shld ticker
	mvi a,022h	; Org-0 and 2mS enable
	sta gpbyte
	out 0f2h
	ei
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

tick:
	sspd savstk
	lxi sp,intstk
	push psw
	push h
	lda gpbyte
	out 0f2h
	lhld ticker
	inx h
	shld ticker
	mov a,l
	ora a
	cz timeot
	pop h
	pop psw
	lspd savstk
	ei
	ret

	ds	64
stack:	ds	0


	ds	20
intstk:	ds	0
savstk:	dw	0

dirbuf:	ds	128

; conout for standard INS8250 at 0E8H
; TODO: make into module, for alternate console options
conout:
	in 0edh		; console 8250 line status
	ani 020h	; TxE
	jz conout
	mov a,c
	out 0e8h	; send char to console
	ret

driver:	equ	$+0	; init entry for disk driver module
d?sel:	equ	$+3
d?read:	equ	$+6

	end
