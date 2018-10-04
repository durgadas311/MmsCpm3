; CPM3LDR BDOS code

	maclib	z80

	extrn	wboot,conout
	extrn	biodma,biores,biotrk,biosec,biodsk,biotrn,d?read

	public	bdos,dlog

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
bdos:
	sspd entsp	;02fb ed 73 30 04 . s 0 .
	xchg 		;02ff eb .
	shld param	;0300 22 2c 04 " , .
	xchg 		;0303 eb .
	mov a,e		;0304 7b {
	sta l08edh	;0305 32 ed 08 2 . .
	lxi h,0		;0308 21 00 00 . . .
	shld aret	;030b 22 2e 04 " . .
	xra a		;030e af .
	sta l08f4h	;030f 32 f4 08 2 . .
	sta l08f2h	;0312 32 f2 08 2 . .
	lxi h,l0884h	;0315 21 84 08 . . .
	push h		;0318 e5 .
	mov a,c		;0319 79 y
	cpi 41		;031a fe 29 . )
	rnc 		;031c d0 .
	mov c,e		;031d 4b K
	lxi h,funcs	;031e 21 2e 03 . . .
	mov e,a		;0321 5f _
	mvi d,0		;0322 16 00 . .
	dad d		;0324 19 .
	dad d		;0325 19 .
	mov e,m		;0326 5e ^
	inx h		;0327 23 #
	mov d,m		;0328 56 V
	lhld param	;0329 2a 2c 04 * , .
	xchg 		;032c eb .
	pchl 		;032d e9 .

funcs:
	dw wboot	; 0
	dw f$null	; 1
	dw f$cono	; 2	CONOUT
	dw f$null	; 3
	dw f$null	; 4
	dw f$null	; 5
	dw f$null	; 6
	dw f$null	; 7
	dw f$null	; 8
	dw f$print	; 9	PRINT
	dw f$null	; 10
	dw f$null	; 11
	dw f$getver	; 12	VERSION
	dw f$reset	; 13	RESET
	dw f$seldrv	; 14	SELECT
	dw f$open	; 15	OPEN
	dw f$null	; 16
	dw f$null	; 17
	dw f$null	; 18
	dw f$null	; 19
	dw f$read	; 20	READ
	dw f$null	; 21
	dw f$null	; 22
	dw f$null	; 23
	dw f$logvec	; 24	LOGIN VEC
	dw f$getdrv	; 25	CUR DSK
	dw f$setdma	; 26	SET DMA
	dw f$null	; 27
	dw f$null	; 28
	dw f$null	; 29
	dw f$null	; 30
	dw f$getdpb	; 31	GET DPB
	dw f$sgusr	; 32	SET/GET USER
	dw f$null	; 33
	dw f$null	; 34
	dw f$null	; 35
	dw f$null	; 36
	dw f$resdrv	; 37	RESET DRIVE
	dw f$null	; 38
	dw f$null	; 39
	dw f$null	; 40

dskmsg:	db	'Bdos Err On '
dskerr:	db	' : $'
permsg:	db	'Bad Sector$'
selmsg:	db	'Select$'

pererr:
	lxi h,permsg	;03a2 21 90 03 . . .
	jmp errflg	;03a5 c3 ab 03 . . .

selerr:
	lxi h,selmsg	;03a8 21 9b 03 . . .
errflg:
	push h	;03ab e5 .
	call crlf		;03ac	cd 07 04 	. . . 
	lda curdsk	;03af 3a 2b 04 : + .
	adi 'A'		;03b2 c6 41 . A
	sta dskerr	;03b4 32 8c 03 2 . .
	lxi b,dskmsg	;03b7 01 80 03 . . .
	call print0		;03ba	cd 14 04 	. . . 
	pop b	;03bd c1 .
	call print0		;03be	cd 14 04 	. . . 
	lxi h,-1	;03c1 21 ff ff . . .
	shld aret	;03c4 22 2e 04 " . .
	jmp retmon	;03c7 c3 a1 08 . . .

conout0:
	lda jamchr	;03ca 3a 28 04 : ( .
	ora a	;03cd b7 .
	jnz nojam	;03ce c2 d6 03 . . .
	push b	;03d1 c5 .
	call conout		;03d2	cd bd 0a 	. . . 
	pop b	;03d5 c1 .
nojam:
	mov a,c	;03d6 79 y
	lxi h,column	;03d7 21 29 04 . ) .
	cpi DEL	;03da fe 7f . 
	rz 	;03dc c8 .
	inr m	;03dd 34 4
	cpi ' '	;03de fe 20 .
	rnc 	;03e0 d0 .
	dcr m	;03e1 35 5
	mov a,m	;03e2 7e ~
	ora a	;03e3 b7 .
	rz 	;03e4 c8 .
	mov a,c
	cpi BS
	jnz notbs
	dcr m	; --col
	ret

notbs:
	cpi LF
	rnz
	mvi m,0	; clear col count
	ret

f$cono:
	mov a,c		;03f3 79 y
	cpi TAB		;03f4 fe 09 . .
	jnz conout0	;03f6 c2 ca 03 . . .
tab0:
	mvi c,' '	;03f9 0e 20 .
	call conout0		;03fb	cd ca 03 	. . . 
	lda column	;03fe 3a 29 04 : ) .
	ani 007h	;0401 e6 07 . .
	jnz tab0	;0403 c2 f9 03 . . .
	ret			;0406	c9 	. 

crlf:
	mvi c,CR
	call conout0
	mvi c,LF
	jmp conout0

f$print:
	xchg
	mov c,l
	mov b,h
print0:
	ldax b
	cpi '$'
	rz
	inx b
	push b
	mov c,a
	call f$cono
	pop b
	jmp print0

setlret1:
	mvi a,1	; error
sta$ret:
	sta aret
f$null:	ret

jamchr:	db	0
column:	db	0
usrcod:	db	0
curdsk:
	db 000h	;042b 00 .
param:	dw	0
aret:	dw	0	; return value from BDOS
entsp:	dw	0

memmov:
	inr c	;0432 0c .
l0433h:
	dcr c	;0433 0d .
	rz 	;0434 c8 .
	ldax d	;0435 1a .
	mov m,a	;0436 77 w
	inx d	;0437 13 .
	inx h	;0438 23 #
	jmp l0433h	;0439 c3 33 04 . 3 .

sub$043ch:
	lda curdsk	;043c 3a 2b 04 : + .
	mov c,a	;043f 4f O
	call biodsk		;0440	cd 88 09 	. . . 
	mov a,h	;0443 7c |
	ora l	;0444 b5 .
	rz 	;0445 c8 .
	mov e,m	;0446 5e ^
	inx h	;0447 23 #
	mov d,m	;0448 56 V
	inx h	;0449 23 #
	shld l08cbh	;044a 22 cb 08 " . .
	inx h	;044d 23 #
	inx h	;044e 23 #
	shld l08cdh	;044f 22 cd 08 " . .
	inx h	;0452 23 #
	inx h	;0453 23 #
	shld l08cfh	;0454 22 cf 08 " . .
	inx h	;0457 23 #
	inx h	;0458 23 #
	xchg 	;0459 eb .
	shld l08e8h	;045a 22 e8 08 " . .
	lxi h,l08d1h	;045d 21 d1 08 . . .
	mvi c,008h	;0460 0e 08 . .
	call memmov		;0462	cd 32 04 	. 2 . 
	lhld l08d3h	;0465 2a d3 08 * . .
	xchg 	;0468 eb .
	lxi h,l08d9h	;0469 21 d9 08 . . .
	mvi c,00fh	;046c 0e 0f . .
	call memmov		;046e	cd 32 04 	. 2 . 
	lhld l08deh	;0471 2a de 08 * . .
	mov a,h	;0474 7c |
	lxi h,l08f1h	;0475 21 f1 08 . . .
	mvi m,0ffh	;0478 36 ff 6 .
	ora a	;047a b7 .
	jz l0480h	;047b ca 80 04 . . .
	mvi m,000h	;047e 36 00 6 .
l0480h:
	mvi a,0ffh	;0480 3e ff > .
	ora a	;0482 b7 .
	ret			;0483	c9 	. 

sub$0484h:
	call biores		;0484	cd 82 09 	. . . 
	xra a	;0487 af .
	lhld l08cdh	;0488 2a cd 08 * . .
	mov m,a	;048b 77 w
	inx h	;048c 23 #
	mov m,a	;048d 77 w
	lhld l08cfh	;048e 2a cf 08 * . .
	mov m,a	;0491 77 w
	inx h	;0492 23 #
	mov m,a	;0493 77 w
	ret			;0494	c9 	. 

sub$0495h:
	call d?read		;0495	cd ce 0a 	. . . 
	ora a	;0498 b7 .
	rz 	;0499 c8 .
	jmp pererr	;049a c3 a2 03 . . .

sub$049dh:
	lhld l08feh	;049d 2a fe 08 * . .
	mvi c,002h	;04a0 0e 02 . .
	call sub$05bch		;04a2	cd bc 05 	. . . 
	shld l08f9h	;04a5 22 f9 08 " . .
	shld l0900h	;04a8 22 00 09 " . .
sub$04abh:
	lxi h,l08f9h	;04ab 21 f9 08 . . .
	mov c,m	;04ae 4e N
	inx h	;04af 23 #
	mov b,m	;04b0 46 F
	lhld l08cfh	;04b1 2a cf 08 * . .
	mov e,m	;04b4 5e ^
	inx h	;04b5 23 #
	mov d,m	;04b6 56 V
	lhld l08cdh	;04b7 2a cd 08 * . .
	mov a,m	;04ba 7e ~
	inx h	;04bb 23 #
	mov h,m	;04bc 66 f
	mov l,a	;04bd 6f o
l04beh:
	mov a,c	;04be 79 y
	sub e	;04bf 93 .
	mov a,b	;04c0 78 x
	sbb d	;04c1 9a .
	jnc l04d4h	;04c2 d2 d4 04 . . .
	push h	;04c5 e5 .
	lhld l08d9h	;04c6 2a d9 08 * . .
	mov a,e	;04c9 7b {
	sub l	;04ca 95 .
	mov e,a	;04cb 5f _
	mov a,d	;04cc 7a z
	sbb h	;04cd 9c .
	mov d,a	;04ce 57 W
	pop h	;04cf e1 .
	dcx h	;04d0 2b +
	jmp l04beh	;04d1 c3 be 04 . . .
l04d4h:
	push h	;04d4 e5 .
	lhld l08d9h	;04d5 2a d9 08 * . .
	dad d	;04d8 19 .
	jc l04e9h	;04d9 da e9 04 . . .
	mov a,c	;04dc 79 y
	sub l	;04dd 95 .
	mov a,b	;04de 78 x
	sbb h	;04df 9c .
	jc l04e9h	;04e0 da e9 04 . . .
	xchg 	;04e3 eb .
	pop h	;04e4 e1 .
	inx h	;04e5 23 #
	jmp l04d4h	;04e6 c3 d4 04 . . .

l04e9h:
	pop h	;04e9 e1 .
	push b	;04ea c5 .
	push d	;04eb d5 .
	push h	;04ec e5 .
	xchg 	;04ed eb .
	lhld l08e6h	;04ee 2a e6 08 * . .
	dad d	;04f1 19 .
	mov b,h	;04f2 44 D
	mov c,l	;04f3 4d M
	call biotrk		;04f4	cd a5 09 	. . . 
	pop d	;04f7 d1 .
	lhld l08cdh	;04f8 2a cd 08 * . .
	mov m,e	;04fb 73 s
	inx h	;04fc 23 #
	mov m,d	;04fd 72 r
	pop d	;04fe d1 .
	lhld l08cfh	;04ff 2a cf 08 * . .
	mov m,e	;0502 73 s
	inx h	;0503 23 #
	mov m,d	;0504 72 r
	pop b	;0505 c1 .
	mov a,c	;0506 79 y
	sub e	;0507 93 .
	mov c,a	;0508 4f O
	mov a,b	;0509 78 x
	sbb d	;050a 9a .
	mov b,a	;050b 47 G
	lhld l08e8h	;050c 2a e8 08 * . .
	xchg 	;050f eb .
	call biotrn		;0510	cd ae 09 	. . . 
	mov c,l	;0513 4d M
	mov b,h	;0514 44 D
	jmp biosec	;0515 c3 ba 09 . . .

sub$0518h:
	lxi h,l08dbh	;0518 21 db 08 . . .
	mov c,m	;051b 4e N
	lda l08f7h	;051c 3a f7 08 : . .
l051fh:
	ora a	;051f b7 .
	rar	;0520 1f .
	dcr c	;0521 0d .
	jnz l051fh	;0522 c2 1f 05 . . .
	mov b,a	;0525 47 G
	mvi a,008h	;0526 3e 08 > .
	sub m	;0528 96 .
	mov c,a	;0529 4f O
	lda l08f6h	;052a 3a f6 08 : . .
l052dh:
	dcr c	;052d 0d .
	jz l0536h	;052e ca 36 05 . 6 .
	ora a	;0531 b7 .
	ral	;0532 17 .
	jmp l052dh	;0533 c3 2d 05 . - .
l0536h:
	add b	;0536 80 .
	ret			;0537	c9 	. 
sub$0538h:
	lhld param	;0538 2a 2c 04 * , .
	lxi d,00010h	;053b 11 10 00 . . .
	dad d	;053e 19 .
	dad b	;053f 09 .
	lda l08f1h	;0540 3a f1 08 : . .
	ora a	;0543 b7 .
	jz l054bh	;0544 ca 4b 05 . K .
	mov l,m	;0547 6e n
	mvi h,000h	;0548 26 00 & .
	ret			;054a	c9 	. 
l054bh:
	dad b	;054b 09 .
	mov e,m	;054c 5e ^
	inx h	;054d 23 #
	mov d,m	;054e 56 V
	xchg 	;054f eb .
	ret			;0550	c9 	. 
sub$0551h:
	call sub$0518h		;0551	cd 18 05 	. . . 
	mov c,a	;0554 4f O
	mvi b,000h	;0555 06 00 . .
	call sub$0538h		;0557	cd 38 05 	. 8 . 
	shld l08f9h	;055a 22 f9 08 " . .
	ret			;055d	c9 	. 
sub$055eh:
	lhld l08f9h	;055e 2a f9 08 * . .
	mov a,l	;0561 7d }
	ora h	;0562 b4 .
	ret			;0563	c9 	. 
sub$0564h:
	lda l08dbh	;0564 3a db 08 : . .
	lhld l08f9h	;0567 2a f9 08 * . .
l056ah:
	dad h	;056a 29 )
	dcr a	;056b 3d =
	jnz l056ah	;056c c2 6a 05 . j .
	shld l08fbh	;056f 22 fb 08 " . .
	lda l08dch	;0572 3a dc 08 : . .
	mov c,a	;0575 4f O
	lda l08f7h	;0576 3a f7 08 : . .
	ana c	;0579 a1 .
	ora l	;057a b5 .
	mov l,a	;057b 6f o
	shld l08f9h	;057c 22 f9 08 " . .
	ret			;057f	c9 	. 
sub$0580h:
	lhld param	;0580 2a 2c 04 * , .
	lxi d,0000ch	;0583 11 0c 00 . . .
	dad d	;0586 19 .
	ret			;0587	c9 	. 
sub$0588h:
	lhld param	;0588 2a 2c 04 * , .
	lxi d,0000fh	;058b 11 0f 00 . . .
	dad d	;058e 19 .
	xchg 	;058f eb .
	lxi h,00011h	;0590 21 11 00 . . .
	dad d	;0593 19 .
	ret			;0594	c9 	. 
sub$0595h:
	call sub$0588h		;0595	cd 88 05 	. . . 
	mov a,m	;0598 7e ~
	sta l08f7h	;0599 32 f7 08 2 . .
	xchg 	;059c eb .
	mov a,m	;059d 7e ~
	sta l08f5h	;059e 32 f5 08 2 . .
	call sub$0580h		;05a1	cd 80 05 	. . . 
	lda l08ddh	;05a4 3a dd 08 : . .
	ana m	;05a7 a6 .
	sta l08f6h	;05a8 32 f6 08 2 . .
	ret			;05ab	c9 	. 
l05ach:
	call sub$0588h		;05ac	cd 88 05 	. . . 
	mvi c,001h	;05af 0e 01 . .
	lda l08f7h	;05b1 3a f7 08 : . .
	add c	;05b4 81 .
	mov m,a	;05b5 77 w
	xchg 	;05b6 eb .
	lda l08f5h	;05b7 3a f5 08 : . .
	mov m,a	;05ba 77 w
	ret			;05bb	c9 	. 
sub$05bch:
	inr c	;05bc 0c .
l05bdh:
	dcr c	;05bd 0d .
	rz 	;05be c8 .
	mov a,h	;05bf 7c |
	ora a	;05c0 b7 .
	rar	;05c1 1f .
	mov h,a	;05c2 67 g
	mov a,l	;05c3 7d }
	rar	;05c4 1f .
	mov l,a	;05c5 6f o
	jmp l05bdh	;05c6 c3 bd 05 . . .
sub$05c9h:
	inr c	;05c9 0c .
l05cah:
	dcr c	;05ca 0d .
	rz 	;05cb c8 .
	dad h	;05cc 29 )
	jmp l05cah	;05cd c3 ca 05 . . .
sub$05d0h:
	push b	;05d0 c5 .
	lda curdsk	;05d1 3a 2b 04 : + .
	mov c,a	;05d4 4f O
	lxi h,00001h	;05d5 21 01 00 . . .
	call sub$05c9h		;05d8	cd c9 05 	. . . 
	pop b	;05db c1 .
	mov a,c	;05dc 79 y
	ora l	;05dd b5 .
	mov l,a	;05de 6f o
	mov a,b	;05df 78 x
	ora h	;05e0 b4 .
	mov h,a	;05e1 67 g
	ret			;05e2	c9 	. 
sub$05e3h:
	lhld l08d1h	;05e3 2a d1 08 * . .
	lda l08fdh	;05e6 3a fd 08 : . .
	add l	;05e9 85 .
	mov l,a	;05ea 6f o
	rnc 	;05eb d0 .
	inr h	;05ec 24 $
	ret			;05ed	c9 	. 
sub$05eeh:
	lhld param	;05ee 2a 2c 04 * , .
	lxi d,0000eh	;05f1 11 0e 00 . . .
	dad d	;05f4 19 .
	mov a,m	;05f5 7e ~
	ret			;05f6	c9 	. 
sub$05f7h:
	call sub$05eeh		;05f7	cd ee 05 	. . . 
	mvi m,000h	;05fa 36 00 6 .
	ret			;05fc	c9 	. 
sub$05fdh:
	call sub$05eeh		;05fd	cd ee 05 	. . . 
	ori 080h	;0600 f6 80 . .
	mov m,a	;0602 77 w
	ret			;0603	c9 	. 
sub$0604h:
	mov a,e	;0604 7b {
	sub l	;0605 95 .
	mov l,a	;0606 6f o
	mov a,d	;0607 7a z
	sbb h	;0608 9c .
	mov h,a	;0609 67 g
	ret			;060a	c9 	. 
sub$060bh:
	call sub$0617h		;060b	cd 17 06 	. . . 
	call sub$0495h		;060e	cd 95 04 	. . . 
sub$0611h:
	lxi h,l08c9h	;0611 21 c9 08 . . .
	jmp l061ah	;0614 c3 1a 06 . . .
sub$0617h:
	lxi h,l08d1h	;0617 21 d1 08 . . .
l061ah:
	mov c,m	;061a 4e N
	inx h	;061b 23 #
	mov b,m	;061c 46 F
	jmp biodma	;061d c3 c0 09 . . .
sub$0620h:
	lxi h,l08feh	;0620 21 fe 08 . . .
	mov a,m	;0623 7e ~
	inx h	;0624 23 #
	cmp m	;0625 be .
	rnz 	;0626 c0 .
	inr a	;0627 3c <
	ret			;0628	c9 	. 
l0629h:
	lxi h,0ffffh	;0629 21 ff ff . . .
	shld l08feh	;062c 22 fe 08 " . .
	ret			;062f	c9 	. 
sub$0630h:
	lhld l08e0h	;0630 2a e0 08 * . .
	xchg 	;0633 eb .
	lhld l08feh	;0634 2a fe 08 * . .
	inx h	;0637 23 #
	shld l08feh	;0638 22 fe 08 " . .
	call sub$0604h		;063b	cd 04 06 	. . . 
	jc l0629h	;063e da 29 06 . ) .
	lda l08feh	;0641 3a fe 08 : . .
	ani 003h	;0644 e6 03 . .
	mvi b,005h	;0646 06 05 . .
l0648h:
	add a	;0648 87 .
	dcr b	;0649 05 .
	jnz l0648h	;064a c2 48 06 . H .
	sta l08fdh	;064d 32 fd 08 2 . .
	ora a	;0650 b7 .
	rnz 	;0651 c0 .
	push b	;0652 c5 .
	call sub$049dh		;0653	cd 9d 04 	. . . 
	call sub$060bh		;0656	cd 0b 06 	. . . 
	pop b	;0659 c1 .
	ret			;065a	c9 	. 
l065bh:
	call sub$0484h		;065b	cd 84 04 	. . . 
	lhld l08cbh	;065e 2a cb 08 * . .
	mvi m,003h	;0661 36 03 6 .
	inx h	;0663 23 #
	mvi m,000h	;0664 36 00 6 .
	call l0629h		;0666	cd 29 06 	. ) . 
l0669h:
	mvi c,0ffh	;0669 0e ff . .
	call sub$0630h		;066b	cd 30 06 	. 0 . 
	call sub$0620h		;066e	cd 20 06 	.   . 
	rz 	;0671 c8 .
	jmp l0669h	;0672 c3 69 06 . i .
sub$0675h:
	push b	;0675 c5 .
	push psw	;0676 f5 .
	lda l08ddh	;0677 3a dd 08 : . .
	cma	;067a 2f /
	mov b,a	;067b 47 G
	mov a,c	;067c 79 y
	ana b	;067d a0 .
	mov c,a	;067e 4f O
	pop psw	;067f f1 .
	ana b	;0680 a0 .
	sub c	;0681 91 .
	ani 01fh	;0682 e6 1f . .
	pop b	;0684 c1 .
	ret			;0685	c9 	. 
sub$0686h:
	mvi a,0ffh	;0686 3e ff > .
	sta l08ech	;0688 32 ec 08 2 . .
	lxi h,l08eeh	;068b 21 ee 08 . . .
	mov m,c	;068e 71 q
	lhld param	;068f 2a 2c 04 * , .
	shld l08efh	;0692 22 ef 08 " . .
	call l0629h		;0695	cd 29 06 	. ) . 
	call sub$0484h		;0698	cd 84 04 	. . . 
l069bh:
	mvi c,000h	;069b 0e 00 . .
	call sub$0630h		;069d	cd 30 06 	. 0 . 
	call sub$0620h		;06a0	cd 20 06 	.   . 
	jz l06f4h	;06a3 ca f4 06 . . .
	lhld l08efh	;06a6 2a ef 08 * . .
	xchg 	;06a9 eb .
	call sub$05e3h		;06aa	cd e3 05 	. . . 
	lda l08eeh	;06ad 3a ee 08 : . .
	mov c,a	;06b0 4f O
	mvi b,000h	;06b1 06 00 . .
l06b3h:
	mov a,c	;06b3 79 y
	ora a	;06b4 b7 .
	jz l06e3h	;06b5 ca e3 06 . . .
	ldax d	;06b8 1a .
	cpi 03fh	;06b9 fe 3f . ?
	jz l06dch	;06bb ca dc 06 . . .
	mov a,b	;06be 78 x
	cpi 00dh	;06bf fe 0d . .
	jz l06dch	;06c1 ca dc 06 . . .
	cpi 00ch	;06c4 fe 0c . .
	ldax d	;06c6 1a .
	jz l06d3h	;06c7 ca d3 06 . . .
	sub m	;06ca 96 .
	ani 07fh	;06cb e6 7f . 
	jnz l069bh	;06cd c2 9b 06 . . .
	jmp l06dch	;06d0 c3 dc 06 . . .
l06d3h:
	push b	;06d3 c5 .
	mov c,m	;06d4 4e N
	call sub$0675h		;06d5	cd 75 06 	. u . 
	pop b	;06d8 c1 .
	jnz l069bh	;06d9 c2 9b 06 . . .
l06dch:
	inx d	;06dc 13 .
	inx h	;06dd 23 #
	inr b	;06de 04 .
	dcr c	;06df 0d .
	jmp l06b3h	;06e0 c3 b3 06 . . .
l06e3h:
	lda l08feh	;06e3 3a fe 08 : . .
	ani 003h	;06e6 e6 03 . .
	sta aret	;06e8 32 2e 04 2 . .
	lxi h,l08ech	;06eb 21 ec 08 . . .
	mov a,m	;06ee 7e ~
	ral	;06ef 17 .
	rnc 	;06f0 d0 .
	xra a	;06f1 af .
	mov m,a	;06f2 77 w
	ret			;06f3	c9 	. 
l06f4h:
	call l0629h		;06f4	cd 29 06 	. ) . 
	mvi a,0ffh	;06f7 3e ff > .
	jmp sta$ret	;06f9 c3 24 04 . $ .
l06fch:
	call sub$08abh		;06fc	cd ab 08 	. . . 
	rz 	;06ff c8 .
sub$0700h:
	call sub$0580h		;0700	cd 80 05 	. . . 
	mov a,m	;0703 7e ~
	push psw	;0704 f5 .
	push h	;0705 e5 .
	call sub$05e3h		;0706	cd e3 05 	. . . 
	xchg 	;0709 eb .
	lhld param	;070a 2a 2c 04 * , .
	mvi c,020h	;070d 0e 20 .
	push d	;070f d5 .
	call memmov		;0710	cd 32 04 	. 2 . 
	call sub$05fdh		;0713	cd fd 05 	. . . 
	pop d	;0716 d1 .
	lxi h,0000ch	;0717 21 0c 00 . . .
	dad d	;071a 19 .
	mov c,m	;071b 4e N
	lxi h,0000fh	;071c 21 0f 00 . . .
	dad d	;071f 19 .
	mov b,m	;0720 46 F
	pop h	;0721 e1 .
	pop psw	;0722 f1 .
	mov m,a	;0723 77 w
	mov a,c	;0724 79 y
	cmp m	;0725 be .
	mov a,b	;0726 78 x
	jz l0731h	;0727 ca 31 07 . 1 .
	mvi a,000h	;072a 3e 00 > .
	jc l0731h	;072c da 31 07 . 1 .
	mvi a,080h	;072f 3e 80 > .
l0731h:
	lhld param	;0731 2a 2c 04 * , .
	lxi d,0000fh	;0734 11 0f 00 . . .
	dad d	;0737 19 .
	mov m,a	;0738 77 w
	ret			;0739	c9 	. 
sub$073ah:
	xra a	;073a af .
	sta l08eah	;073b 32 ea 08 2 . .
	lhld param	;073e 2a 2c 04 * , .
	lxi b,0000ch	;0741 01 0c 00 . . .
	dad b	;0744 09 .
	mov a,m	;0745 7e ~
	inr a	;0746 3c <
	ani 01fh	;0747 e6 1f . .
	mov m,a	;0749 77 w
	jz l075ch	;074a ca 5c 07 . \ .
	mov b,a	;074d 47 G
	lda l08ddh	;074e 3a dd 08 : . .
	ana b	;0751 a0 .
	lxi h,l08eah	;0752 21 ea 08 . . .
	ana m	;0755 a6 .
	jz l0767h	;0756 ca 67 07 . g .
	jmp l076dh	;0759 c3 6d 07 . m .

l075ch:
	lxi b,00002h	;075c 01 02 00 . . .
	dad b	;075f 09 .
	inr m	;0760 34 4
	mov a,m	;0761 7e ~
	ani 00fh	;0762 e6 0f . .
	jz l0777h	;0764 ca 77 07 . w .
l0767h:
	call sub$08abh		;0767	cd ab 08 	. . . 
	jz l0777h	;076a ca 77 07 . w .
l076dh:
	call sub$0700h		;076d	cd 00 07 	. . . 
	call sub$0595h		;0770	cd 95 05 	. . . 
	xra a	;0773 af .
	jmp sta$ret	;0774 c3 24 04 . $ .

l0777h:
	call setlret1		;0777	cd 22 04 	. " . 
	jmp sub$05fdh	;077a c3 fd 05 . . .

l077dh:
	mvi a,0ffh	;077d 3e ff > .
	sta l08ebh	;077f 32 eb 08 2 . .
	call sub$0595h		;0782	cd 95 05 	. . . 
	lda l08f7h	;0785 3a f7 08 : . .
	lxi h,l08f5h	;0788 21 f5 08 . . .
	cmp m	;078b be .
	jc l07a2h	;078c da a2 07 . . .
	cpi 080h	;078f fe 80 . .
	jnz l07b7h	;0791 c2 b7 07 . . .
	call sub$073ah		;0794	cd 3a 07 	. : . 
	xra a	;0797 af .
	sta l08f7h	;0798 32 f7 08 2 . .
	lda aret	;079b 3a 2e 04 : . .
	ora a	;079e b7 .
	jnz l07b7h	;079f c2 b7 07 . . .
l07a2h:
	call sub$0551h		;07a2	cd 51 05 	. Q . 
	call sub$055eh		;07a5	cd 5e 05 	. ^ . 
	jz l07b7h	;07a8 ca b7 07 . . .
	call sub$0564h		;07ab	cd 64 05 	. d . 
	call sub$04abh		;07ae	cd ab 04 	. . . 
	call sub$0495h		;07b1	cd 95 04 	. . . 
	jmp l05ach	;07b4 c3 ac 05 . . .

l07b7h:
	jmp setlret1	;07b7 c3 22 04 . " .

l07bah:
	lhld dlog	;07ba 2a c7 08 * . .
	lda curdsk	;07bd 3a 2b 04 : + .
	mov c,a	;07c0 4f O
	call sub$05bch		;07c1	cd bc 05 	. . . 
	push h	;07c4 e5 .
	xchg 	;07c5 eb .
	call sub$043ch		;07c6	cd 3c 04 	. < . 
	pop h	;07c9 e1 .
	jz selerr	;07ca ca a8 03 . . .
	mov a,l	;07cd 7d }
	rar	;07ce 1f .
	rc 	;07cf d8 .
	lhld dlog	;07d0 2a c7 08 * . .
	mov c,l	;07d3 4d M
	mov b,h	;07d4 44 D
	call sub$05d0h		;07d5	cd d0 05 	. . . 
	shld dlog	;07d8 22 c7 08 " . .
	jmp l065bh	;07db c3 5b 06 . [ .

f$seldrv:
	lda l08edh	;07de 3a ed 08 : . .
	lxi h,curdsk	;07e1 21 2b 04 . + .
	cmp m	;07e4 be .
	nop			;07e5	00 	. 
	mov m,a	;07e6 77 w
	jmp l07bah	;07e7 c3 ba 07 . . .

sub$07eah:
	mvi a,0ffh	;07ea 3e ff > .
	sta l08f2h	;07ec 32 f2 08 2 . .
	lhld param	;07ef 2a 2c 04 * , .
	mov a,m	;07f2 7e ~
	ani 01fh	;07f3 e6 1f . .
	dcr a	;07f5 3d =
	sta l08edh	;07f6 32 ed 08 2 . .
	cpi 01eh	;07f9 fe 1e . .
	jnc l080eh	;07fb d2 0e 08 . . .
	lda curdsk	;07fe 3a 2b 04 : + .
	sta l08f3h	;0801 32 f3 08 2 . .
	mov a,m	;0804 7e ~
	sta l08f4h	;0805 32 f4 08 2 . .
	ani 0e0h	;0808 e6 e0 . .
	mov m,a	;080a 77 w
	call f$seldrv		;080b	cd de 07 	. . . 
l080eh:
	lda usrcod	;080e 3a 2a 04 : * .
	lhld param	;0811 2a 2c 04 * , .
	ora m	;0814 b6 .
	mov m,a	;0815 77 w
	ret			;0816	c9 	. 

f$getver:
	mvi a,022h	;0817 3e 22 > "
	jmp sta$ret	;0819 c3 24 04 . $ .

f$reset:
	lxi h,00000h	;081c 21 00 00 . . .
	shld dlog	;081f 22 c7 08 " . .
	xra a	;0822 af .
	sta curdsk	;0823 32 2b 04 2 + .
	lxi h,dmabuf	;0826 21 80 00 . . .
	shld l08c9h	;0829 22 c9 08 " . .
	call sub$0611h		;082c	cd 11 06 	. . . 
	jmp l07bah	;082f c3 ba 07 . . .

f$open:
	call sub$05f7h		;0832	cd f7 05 	. . . 
	call sub$07eah		;0835	cd ea 07 	. . . 
	jmp l06fch	;0838 c3 fc 06 . . .

f$read:
	call sub$07eah		;083b	cd ea 07 	. . . 
	jmp l077dh	;083e c3 7d 07 . } .

f$logvec:
	lhld dlog	;0841 2a c7 08 * . .
	jmp l0857h	;0844 c3 57 08 . W .

f$getdrv:
	lda curdsk	;0847 3a 2b 04 : + .
	jmp sta$ret	;084a c3 24 04 . $ .

f$setdma:
	xchg 	;084d eb .
	shld l08c9h	;084e 22 c9 08 " . .
	jmp sub$0611h	;0851 c3 11 06 . . .

f$getdpb:
	lhld l08d3h	;0854 2a d3 08 * . .
l0857h:
	shld aret	;0857 22 2e 04 " . .
	ret			;085a	c9 	. 

f$sgusr:
	lda l08edh	;085b 3a ed 08 : . .
	cpi 0ffh	;085e fe ff . .
	jnz l0869h	;0860 c2 69 08 . i .
	lda usrcod	;0863 3a 2a 04 : * .
	jmp sta$ret	;0866 c3 24 04 . $ .

l0869h:
	ani 01fh	;0869 e6 1f . .
	sta usrcod	;086b 32 2a 04 2 * .
	ret			;086e	c9 	. 

f$resdrv:
	lhld param	;086f 2a 2c 04 * , .
	mov a,l	;0872 7d }
	cma	;0873 2f /
	mov e,a	;0874 5f _
	mov a,h	;0875 7c |
	cma	;0876 2f /
	lhld dlog	;0877 2a c7 08 * . .
	ana h	;087a a4 .
	mov d,a	;087b 57 W
	mov a,l	;087c 7d }
	ana e	;087d a3 .
	mov e,a	;087e 5f _
	xchg 	;087f eb .
	shld dlog	;0880 22 c7 08 " . .
	ret			;0883	c9 	. 

l0884h:
	lda l08f2h	;0884 3a f2 08 : . .
	ora a	;0887 b7 .
	jz retmon	;0888 ca a1 08 . . .
	lhld param	;088b 2a 2c 04 * , .
	mvi m,000h	;088e 36 00 6 .
	lda l08f4h	;0890 3a f4 08 : . .
	ora a	;0893 b7 .
	jz retmon	;0894 ca a1 08 . . .
	mov m,a	;0897 77 w
	lda l08f3h	;0898 3a f3 08 : . .
	sta l08edh	;089b 32 ed 08 2 . .
	call f$seldrv		;089e	cd de 07 	. . . 
retmon:
	lspd entsp	;08a1 ed 7b 30 04 . { 0 .
	lhld aret	;08a5 2a 2e 04 * . .
	mov a,l		;08a8 7d }
	mov b,h		;08a9 44 D
	ret			;08aa	c9 	. 

sub$08abh:
	mvi c,00fh	;08ab 0e 0f . .
	call sub$0686h		;08ad	cd 86 06 	. . . 
	call sub$0620h		;08b0	cd 20 06 	.   . 
	rnz 	;08b3 c0 .
	lhld param	;08b4 2a 2c 04 * , .
	mov a,m	;08b7 7e ~
	mov c,a	;08b8 4f O
	ani 0e0h	;08b9 e6 e0 . .
	mov m,a	;08bb 77 w
	mov a,c	;08bc 79 y
	ani 01fh	;08bd e6 1f . .
	jnz sub$08abh	;08bf c2 ab 08 . . .
	call l080eh		;08c2	cd 0e 08 	. . . 
	xra a	;08c5 af .
	ret			;08c6	c9 	. 

dlog:	dw	0
l08c9h:
	db 080h	;08c9 80 .
	db 000h	;08ca 00 .
l08cbh:
	db 000h	;08cb 00 .
	db 000h	;08cc 00 .
l08cdh:
	db 000h	;08cd 00 .
	db 000h	;08ce 00 .
l08cfh:
	db 000h	;08cf 00 .
	db 000h	;08d0 00 .
l08d1h:
	db 000h	;08d1 00 .
	db 000h	;08d2 00 .
l08d3h:
	db 000h	;08d3 00 .
	db 000h	;08d4 00 .
	db 000h	;08d5 00 .
	db 000h	;08d6 00 .
	db 000h	;08d7 00 .
	db 000h	;08d8 00 .
l08d9h:
	db 000h	;08d9 00 .
	db 000h	;08da 00 .
l08dbh:
	db 000h	;08db 00 .
l08dch:
	db 000h	;08dc 00 .
l08ddh:
	db 000h	;08dd 00 .
l08deh:
	db 000h	;08de 00 .
	db 000h	;08df 00 .
l08e0h:
	db 000h	;08e0 00 .
	db 000h	;08e1 00 .
	db 000h	;08e2 00 .
	db 000h	;08e3 00 .
	db 000h	;08e4 00 .
	db 000h	;08e5 00 .
l08e6h:
	db 000h	;08e6 00 .
	db 000h	;08e7 00 .
l08e8h:
	db 000h	;08e8 00 .
	db 000h	;08e9 00 .
l08eah:
	db 000h	;08ea 00 .
l08ebh:
	db 000h	;08eb 00 .
l08ech:
	db 000h	;08ec 00 .
l08edh:
	db 000h	;08ed 00 .
l08eeh:
	db 000h	;08ee 00 .
l08efh:
	db 000h	;08ef 00 .
	db 000h	;08f0 00 .
l08f1h:
	db 000h	;08f1 00 .
l08f2h:
	db 000h	;08f2 00 .
l08f3h:
	db 000h	;08f3 00 .
l08f4h:
	db 000h	;08f4 00 .
l08f5h:
	db 000h	;08f5 00 .
l08f6h:
	db 000h	;08f6 00 .
l08f7h:
	db 000h	;08f7 00 .
	db 000h	;08f8 00 .
l08f9h:
	db 000h	;08f9 00 .
	db 000h	;08fa 00 .
l08fbh:
	db 000h	;08fb 00 .
	db 000h	;08fc 00 .
l08fdh:
	db 000h	;08fd 00 .
l08feh:
	db 000h	;08fe 00 .
	db 000h	;08ff 00 .
l0900h:
	db 000h	;0900 00 .
	db 000h	;0901 00 .

	end
