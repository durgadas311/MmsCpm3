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
rst1	equ	0008h
ticker	equ	000bh
gpbyte	equ	000dh
l000eh	equ	000eh
dmabuf	equ	0080h

msgout	equ	9
reset	equ	13
open	equ	15
read	equ	20
setdma	equ	26

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
phytrk:
	db 000h	;090a 00 .
	db 000h	;090b 00 .
dmaa:	dw	0

signon:
	db	CR,LF,BEL,'Z89/Z90 Loader v2.241  (c) 1982,1983 Magnolia Microsystems'
	db	CR,LF,'$'

cboot:
	lxi sp,stack	;094e 31 27 0a 1 ' .
	mvi a,080h	;0951 3e 80 > .
	sta l000eh	;0953 32 0e 00 2 . .
	out 07fh	;0956 d3 7f . 
	lxi d,signon	;0958 11 0e 09 . . .
	mvi c,msgout	;095b 0e 09 . .
	call bdos		;095d	cd fb 02 	. . . 
	di			;0960	f3 	. 
	mvi a,0c3h	;0961 3e c3 > .
	sta rst1	;0963 32 08 00 2 . .
	lxi h,tick	;0966 21 c5 09 . . .
	shld rst1+1	;0969 22 09 00 " . .
	lxi h,0
	shld ticker	;096f 22 0b 00 " . .
	mvi a,022h	;0972 3e 22 > "
	sta gpbyte	;0974 32 0d 00 2 . .
	out 0f2h	;0977 d3 f2 . .
	ei		;0979	fb 	. 
	call driver	;097a	cd c8 0a 	. . . 
	jmp loader	;097d c3 00 02 . . .

wboot:	; never called normally
	di		;0980	f3 	. 
	hlt		;0981 76 v

biores:
	lxi b,0		;0982 01 00 00 . . .
	jmp biotrk	;0985 c3 a5 09 . . .

biodsk:
	mov a,c		;0988 79 y
	cpi 16		;0989 fe 10 . .
	jrnc l0995h	;098b 30 08 0 .
	lda mixer	;098d 3a 03 09 : . .
	mov c,a		;0990 4f O
	cpi 0ffh	;0991 fe ff . .
	jrnz l0999h	;0993 20 04 .
l0995h:
	lxi h,0		;0995 21 00 00 . . .
	ret		;0998	c9 	. 

l0999h:
	mov a,c
	sta newdsk
	call d?sel
	lda newdsk
	mov c,a
	ret

biotrk:
	mov a,c	;09a5 79 y
	sta newtrk	;09a6 32 08 09 2 . .
	sbcd phytrk	;09a9 ed 43 0a 09 . C . .
	ret			;09ad	c9 	. 

biotrn:
	mov l,c	;09ae 69 i
	mov h,b	;09af 60 `
	inx h	;09b0 23 #
	mov a,d	;09b1 7a z
	ora e	;09b2 b3 .
	rz 	;09b3 c8 .
	xchg 	;09b4 eb .
	dad b	;09b5 09 .
	mov l,m	;09b6 6e n
	mvi h,0	;09b7 26 00 & .
	ret			;09b9	c9 	. 

biosec:
	mov a,c	;09ba 79 y
	dcr a	;09bb 3d =
	sta newsec	;09bc 32 09 09 2 . .
	ret			;09bf	c9 	. 

biodma:
	sbcd dmaa	;09c0 ed 43 0c 09 . C . .
	ret			;09c4	c9 	. 

tick:
	sspd savstk	;09c5 ed 73 3b 0a . s ; .
	lxi sp,intstk	;09c9 31 3b 0a 1 ; .
	push psw	;09cc f5 .
	push h	;09cd e5 .
	lda gpbyte	;09ce 3a 0d 00 : . .
	out 0f2h	;09d1 d3 f2 . .
	lhld ticker	;09d3 2a 0b 00 * . .
	inx h	;09d6 23 #
	shld ticker	;09d7 22 0b 00 " . .
	mov a,l	;09da 7d }
	ora a	;09db b7 .
	cz timeot	;09dc cc 04 09 . . .
	pop h	;09df e1 .
	pop psw	;09e0 f1 .
	lspd savstk	;09e1 ed 7b 3b 0a . { ; .
	ei			;09e5	fb 	. 
	ret			;09e6	c9 	. 

	ds	64
stack:	ds	0


	ds	20
intstk:	ds	0
savstk:	dw	0

dirbuf:	ds	128

conout:
	in 0edh		;0abd db ed . .
	ani 020h	;0abf e6 20 .
	jz conout	;0ac1 ca bd 0a . . .
	mov a,c		;0ac4 79 y
	out 0e8h	;0ac5 d3 e8 . .
	ret		;0ac7	c9 	. 

driver:	equ	$+0	; init entry for disk driver module
d?sel:	equ	$+3
d?read:	equ	$+6

	end
