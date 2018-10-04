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
dmabuf	equ	0080h

	cseg

; Main entry into BDOS: execute function in C, using param DE
bdos:
	sspd entsp
	xchg 
	shld param
	xchg 
	mov a,e
	sta linfo
	lxi h,0
	shld aret
	xra a
	sta fcbdsk
	sta resel
	lxi h,goback2
	push h
	mov a,c
	cpi 41
	rnc 
	mov c,e
	lxi h,functab
	mov e,a
	mvi d,0
	dad d
	dad d
	mov e,m
	inx h
	mov d,m
	lhld param
	xchg 
	pchl 

functab:
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
	lxi h,permsg
	jmp errflg

selerr:
	lxi h,selmsg
errflg:
	push h
	call crlf
	lda curdsk
	adi 'A'
	sta dskerr
	lxi b,dskmsg
	call print0
	pop b
	call print0
	lxi h,-1
	shld aret
	jmp retmon

conout0:
	lda jamchr
	ora a
	jnz nojam
	push b
	call conout
	pop b
nojam:
	mov a,c
	lxi h,column
	cpi DEL
	rz 
	inr m
	cpi ' '
	rnc 
	dcr m
	mov a,m
	ora a
	rz 
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
	mov a,c
	cpi TAB
	jnz conout0
tab0:
	mvi c,' '
	call conout0
	lda column
	ani 007h
	jnz tab0
	ret

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
	db 000h
param:	dw	0
aret:	dw	0	; return value from BDOS
entsp:	dw	0

memmov:
	inr c
move0:
	dcr c
	rz 
	ldax d
	mov m,a
	inx d
	inx h
	jmp move0

selectdisk:
	lda curdsk
	mov c,a
	call biodsk
	mov a,h
	ora l
	rz 
	mov e,m
	inx h
	mov d,m
	inx h
	shld cdrmaxa
	inx h
	inx h
	shld curtrka
	inx h
	inx h
	shld curreca
	inx h
	inx h
	xchg 
	shld tranv
	lxi h,buffa
	mvi c,8
	call memmov
	lhld dpbaddr
	xchg 
	lxi h,sectpt
	mvi c,15
	call memmov
	lhld maxall
	mov a,h
	lxi h,single
	mvi m,0ffh
	ora a
	jz retselect
	mvi m,000h
retselect:
	mvi a,0ffh
	ora a
	ret

home:
	call biores
	xra a
	lhld curtrka
	mov m,a
	inx h
	mov m,a
	lhld curreca
	mov m,a
	inx h
	mov m,a
	ret

rdbuff:
	call d?read
	ora a
	rz 
	jmp pererr

seek$dir:
	lhld dcnt
	mvi c,002h
	call hlrotr
	shld arecord
	shld drec
seek:
	lxi h,arecord
	mov c,m
	inx h
	mov b,m
	lhld curreca
	mov e,m
	inx h
	mov d,m
	lhld curtrka
	mov a,m
	inx h
	mov h,m
	mov l,a
seek0:
	mov a,c
	sub e
	mov a,b
	sbb d
	jnc seek1
	push h
	lhld sectpt
	mov a,e
	sub l
	mov e,a
	mov a,d
	sbb h
	mov d,a
	pop h
	dcx h
	jmp seek0
seek1:
	push h
	lhld sectpt
	dad d
	jc seek2
	mov a,c
	sub l
	mov a,b
	sbb h
	jc seek2
	xchg 
	pop h
	inx h
	jmp seek1

seek2:
	pop h
	push b
	push d
	push h
	xchg 
	lhld offset
	dad d
	mov b,h
	mov c,l
	call biotrk
	pop d
	lhld curtrka
	mov m,e
	inx h
	mov m,d
	pop d
	lhld curreca
	mov m,e
	inx h
	mov m,d
	pop b
	mov a,c
	sub e
	mov c,a
	mov a,b
	sbb d
	mov b,a
	lhld tranv
	xchg 
	call biotrn
	mov c,l
	mov b,h
	jmp biosec

dm$position:
	lxi h,blkshf
	mov c,m
	lda vrecord
dmpos0:
	ora a
	rar
	dcr c
	jnz dmpos0
	mov b,a
	mvi a,8
	sub m
	mov c,a
	lda extval
dmpos1:
	dcr c
	jz dmpos2
	ora a
	ral
	jmp dmpos1
dmpos2:
	add b
	ret

getdm:
	lhld param
	lxi d,16
	dad d
	dad b
	lda single
	ora a
	jz getdmd
	mov l,m
	mvi h,0
	ret

getdmd:
	dad b
	mov e,m
	inx h
	mov d,m
	xchg 
	ret
index:
	call dm$position
	mov c,a
	mvi b,0
	call getdm
	shld arecord
	ret

allocated:
	lhld arecord
	mov a,l
	ora h
	ret
atran:
	lda blkshf
	lhld arecord
atran0:
	dad h
	dcr a
	jnz atran0
	shld arecord1
	lda blkmsk
	mov c,a
	lda vrecord
	ana c
	ora l
	mov l,a
	shld arecord
	ret

getexta:
	lhld param
	lxi d,12
	dad d
	ret

getfcba:
	lhld param
	lxi d,15
	dad d
	xchg 
	lxi h,17
	dad d
	ret

getfcb:
	call getfcba
	mov a,m
	sta vrecord
	xchg 
	mov a,m
	sta rcount
	call getexta
	lda extmsk
	ana m
	sta extval
	ret
setfcb:
	call getfcba
	mvi c,001h
	lda vrecord
	add c
	mov m,a
	xchg 
	lda rcount
	mov m,a
	ret

hlrotr:
	inr c
hlrotr0:
	dcr c
	rz 
	mov a,h
	ora a
	rar
	mov h,a
	mov a,l
	rar
	mov l,a
	jmp hlrotr0

hlrotl:
	inr c
hlrotl0:
	dcr c
	rz 
	dad h
	jmp hlrotl0

set$cdisk:
	push b
	lda curdsk
	mov c,a
	lxi h,00001h
	call hlrotl
	pop b
	mov a,c
	ora l
	mov l,a
	mov a,b
	ora h
	mov h,a
	ret
getdptra:
	lhld buffa
	lda dptr
	add l
	mov l,a
	rnc 
	inr h
	ret

getmodnum:
	lhld param
	lxi d,14
	dad d
	mov a,m
	ret

clrmodnum:
	call getmodnum
	mvi m,0
	ret

setfwf:
	call getmodnum
	ori 080h
	mov m,a
	ret

subdh:
	mov a,e
	sub l
	mov l,a
	mov a,d
	sbb h
	mov h,a
	ret

rd$dir:
	call setdir
	call rdbuff
setdata:
	lxi h,dmaad
	jmp setdma

setdir:
	lxi h,buffa
setdma:
	mov c,m
	inx h
	mov b,m
	jmp biodma

end$of$dir:
	lxi h,dcnt
	mov a,m
	inx h
	cmp m
	rnz 
	inr a
	ret

set$end$dir:
	lxi h,0ffffh
	shld dcnt
	ret

read$dir:
	lhld dirmax
	xchg 
	lhld dcnt
	inx h
	shld dcnt
	call subdh
	jc set$end$dir
	lda dcnt
	ani 003h
	mvi b,005h
read$dir1:
	add a
	dcr b
	jnz read$dir1
	sta dptr
	ora a
	rnz 
	push b
	call seek$dir
	call rd$dir
	pop b
	ret

initialize:
	call home
	lhld cdrmaxa
	mvi m,003h
	inx h
	mvi m,000h
	call set$end$dir
initial2:
	mvi c,0ffh
	call read$dir
	call end$of$dir
	rz 
	jmp initial2

compext:
	push b
	push psw
	lda extmsk
	cma
	mov b,a
	mov a,c
	ana b
	mov c,a
	pop psw
	ana b
	sub c
	ani 01fh
	pop b
	ret

search:
	mvi a,0ffh
	sta dirloc
	lxi h,searchl
	mov m,c
	lhld param
	shld searcha
	call set$end$dir
	call home
searchn:
	mvi c,000h
	call read$dir
	call end$of$dir
	jz search$fin
	lhld searcha
	xchg 
	call getdptra
	lda searchl
	mov c,a
	mvi b,0
searchloop:
	mov a,c
	ora a
	jz endsearch
	ldax d
	cpi '?'
	jz searchok
	mov a,b
	cpi 13
	jz searchok
	cpi 12
	ldax d
	jz searchext
	sub m
	ani 07fh
	jnz searchn
	jmp searchok

searchext:
	push b
	mov c,m
	call compext
	pop b
	jnz searchn
searchok:
	inx d
	inx h
	inr b
	dcr c
	jmp searchloop

endsearch:
	lda dcnt
	ani 003h
	sta aret
	lxi h,dirloc
	mov a,m
	ral
	rnc 
	xra a
	mov m,a
	ret

search$fin:
	call set$end$dir
	mvi a,0ffh
	jmp sta$ret

open:
	call find
	rz	; no file
open$copy:
	call getexta
	mov a,m
	push psw
	push h
	call getdptra
	xchg 
	lhld param
	mvi c,32
	push d
	call memmov
	call setfwf
	pop d
	lxi h,12
	dad d
	mov c,m
	lxi h,15
	dad d
	mov b,m
	pop h
	pop psw
	mov m,a
	mov a,c
	cmp m
	mov a,b
	jz open$rcnt
	mvi a,000h
	jc open$rcnt
	mvi a,080h
open$rcnt:
	lhld param
	lxi d,15
	dad d
	mov m,a
	ret

open$reel:
	xra a
	sta fcb$copied
	lhld param
	lxi b,0000ch
	dad b
	mov a,m
	inr a
	ani 01fh
	mov m,a
	jz open$mod
	mov b,a
	lda extmsk
	ana b
	lxi h,fcb$copied
	ana m
	jz open$reel0
	jmp open$reel1

open$mod:
	lxi b,00002h
	dad b
	inr m
	mov a,m
	ani 00fh
	jz open$r$err
open$reel0:
	call find
	jz open$r$err
open$reel1:
	call open$copy
	call getfcb
	xra a
	jmp sta$ret

open$r$err:
	call setlret1
	jmp setfwf

seqdiskread:
	mvi a,0ffh
	sta rmf
	call getfcb
	lda vrecord
	lxi h,rcount
	cmp m
	jc recordok
	cpi 128
	jnz diskeof
	call open$reel
	xra a
	sta vrecord
	lda aret
	ora a
	jnz diskeof
recordok:
	call index
	call allocated
	jz diskeof
	call atran
	call seek
	call rdbuff
	jmp setfcb

diskeof:
	jmp setlret1

select:
	lhld dlog
	lda curdsk
	mov c,a
	call hlrotr
	push h
	xchg 
	call selectdisk
	pop h
	jz selerr
	mov a,l
	rar
	rc 
	lhld dlog
	mov c,l
	mov b,h
	call set$cdisk
	shld dlog
	jmp initialize

f$seldrv:
	lda linfo
	lxi h,curdsk
	cmp m
	nop
	mov m,a
	jmp select

reselect:
	mvi a,0ffh
	sta resel
	lhld param
	mov a,m
	ani 00011111b
	dcr a
	sta linfo
	cpi 30
	jnc noselect
	lda curdsk
	sta olddsk
	mov a,m
	sta fcbdsk
	ani 11100000b
	mov m,a
	call f$seldrv
noselect:
	lda usrcod
	lhld param
	ora m
	mov m,a
	ret

f$getver:
	mvi a,022h	; CP/M 2.2
	jmp sta$ret

f$reset:
	lxi h,00000h
	shld dlog
	xra a
	sta curdsk
	lxi h,dmabuf
	shld dmaad
	call setdata
	jmp select

f$open:
	call clrmodnum
	call reselect
	jmp open

f$read:
	call reselect
	jmp seqdiskread

f$logvec:
	lhld dlog
	jmp goback

f$getdrv:
	lda curdsk
	jmp sta$ret

f$setdma:
	xchg 
	shld dmaad
	jmp setdata

f$getdpb:
	lhld dpbaddr
goback:
	shld aret
	ret

f$sgusr:
	lda linfo
	cpi 0ffh
	jnz setusrcode
	lda usrcod
	jmp sta$ret

setusrcode:
	ani 01fh
	sta usrcod
	ret

f$resdrv:
	lhld param
	mov a,l
	cma
	mov e,a
	mov a,h
	cma
	lhld dlog
	ana h
	mov d,a
	mov a,l
	ana e
	mov e,a
	xchg 
	shld dlog
	ret

goback2:
	lda resel
	ora a
	jz retmon
	lhld param
	mvi m,0
	lda fcbdsk
	ora a
	jz retmon
	mov m,a
	lda olddsk
	sta linfo
	call f$seldrv
retmon:
	lspd entsp
	lhld aret
	mov a,l
	mov b,h
	ret

find:
	mvi c,00fh
	call search
	call end$of$dir
	rnz		; return if found
	lhld param	; try user 0 also...
	mov a,m
	mov c,a
	ani 11100000b
	mov m,a
	mov a,c
	ani 00011111b
	jnz find
	call noselect
	xra a
	ret

dlog:	dw	0
dmaad:
	db 080h
	db 000h
cdrmaxa:
	db 000h
	db 000h
curtrka:
	db 000h
	db 000h
curreca:
	db 000h
	db 000h
buffa:
	db 000h
	db 000h
dpbaddr:
	db 000h
	db 000h
	db 000h
	db 000h
	db 000h
	db 000h
sectpt:
	db 000h
	db 000h
blkshf:
	db 000h
blkmsk:
	db 000h
extmsk:
	db 000h
maxall:
	db 000h
	db 000h
dirmax:
	db 000h
	db 000h
	db 000h
	db 000h
	db 000h
	db 000h
offset:
	db 000h
	db 000h
tranv:
	db 000h
	db 000h
fcb$copied:
	db 000h
rmf:
	db 000h
dirloc:
	db 000h
linfo:
	db 000h
searchl:
	db 000h
searcha:
	db 000h
	db 000h
single:
	db 000h
resel:
	db 000h
olddsk:
	db 000h
fcbdsk:
	db 000h
rcount:
	db 000h
extval:
	db 000h
vrecord:
	db 000h
	db 000h
arecord:
	db 000h
	db 000h
arecord1:
	db 000h
	db 000h
dptr:
	db 000h
dcnt:
	db 000h
	db 000h
drec:
	db 000h
	db 000h

	end
