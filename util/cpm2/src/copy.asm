; z80dasm 1.1.5
; command line: z80dasm -b copy.blk -g 0x100 -t -a -l /home/drmiller/cpm.files/mms/backup-2.23/copy.com
	maclib	z80

cr	equ	13
lf	equ	10
bel	equ	7

cpm	equ	0
bdos	equ	5
cmdbuf	equ	0080h
defdma	equ	0080h

print	equ	9
linein	equ	10

	org	00100h


; BLOCK 'text0' (start 0x0100 end 0x0103)
	jmp l035bh

; BLOCK 'seg1' (start 0x0103 end 0x012e)
	db	'COPYRIGHT (C) 1981 MAGNOLIA MICROSYSTEMS   '

; BLOCK 'seg2' (start 0x012e end 0x0146)
seldsk:	jmp 00000h ; seldsk
settrk:	jmp 00000h ; settrk
setsec:	jmp 00000h ; setsec
setdma:	jmp 00000h ; setdma
read:	jmp 00000h ; read
write:	jmp 00000h ; write
	jmp 00000h ; listst (unused)
sectrn:	jmp 00000h ; sectrn

; BLOCK 'seg3' (start 0x0146 end 0x0314)
srctrk:	dw	0
srcsec:	dw	0
savtrk:	dw	0
savsec:	dw	0
dsttrk:	dw	0
dstsec:	dw	0
enddrv:	db	0
seccnt:	dw	0
countr:	dw	0
dmapt2:	dw	0
dmaptr:	dw	0
hint:	db	0

signon:	db	cr,lf,'+MMS COPY version 4.1$'

srcmsg:	db	cr,lf,lf,'+Insert SOURCE disk in '
srcdrv:	db		'X:'
	db	cr,lf,'+Insert BLANK disk in '
dstdrv:	db		'X:'
	db	cr,lf,'+Push RETURN to copy, ^C to Exit +$'
endmsg:	db	cr,lf,'+Copy completed.$'

srcerr:	db	cr,lf,bel,'+Source Read Error!$'
dsterr:	db	cr,lf,bel,'+Disk Write Error!$'
vererr:	db	cr,lf,bel,'+Verify Error!$'
drverr:	db	cr,lf,bel,'+Invalid drive!$'
samerr:	db	cr,lf,bel,'+Source and Destination cannot be the same drive!$'
fmterr:	db	cr,lf,bel,'+Source and Destination must be same format!$'
synerr:	db	cr,lf,bel,'+Syntax Error. Use "COPY s: TO d:" where'
	db	cr,lf,    '+   "s:" = Source drive name'
	db	cr,lf,    '+   "d:" = Destination drive name$'

inbuf:	db	10,0,'          '
	db	'$$'

; BLOCK 'seg4' (start 0x0314 end 0x0603)
getc:
	ldx a,+0
	inxix
	dcr b
	ret

skipb:
	call getc
	jm ungetc
	cpi ' '
	jz skipb
ungetc:	dcxix
	inr b
	ret

getdrv:
	call skipb
	call getc
	jm l04f5h
	cpi 'A'
	jc l04f5h
	cpi 'P'+1
	jnc l04f5h
	sta dstdrv
	sui 'A'
	mov c,a
	call getc
	jm l04f5h
	cpi ':'
	jnz l04f5h
	push b
	call seldsk
	pop b
	mov a,h
	ora l
	jz drverr
	jmp getfmt

l035bh:
	lxi sp,stack
	lxi d,signon
	mvi c,print
	call bdos
	; init BIOS jump vectors
	lhld cpm+1
	lxi d,8*3 ; start at +8 vectors
	dad d
	lxi d,seldsk
	lxi b,8*3 ; copy 8 vectors
	ldir
	; parse commandline
	lxix cmdbuf+1
	ldx b,-1
	call getdrv
	lda dstdrv
	sta srcdrv
	push h
	push d
	pushiy
	call skipb
	call getc
	jm l04f5h
	cpi 'T'
	jnz l04f5h
	call getc
	jm l04f5h
	cpi 'O'
	jnz l04f5h
	call getdrv
	pushiy
	pop b
	xthl
	ora a
	dsbc b
	jnz l04e9h
	pop b
	pop h
	dsbc d
	jnz l04e9h
	pop h
	dsbc b
	jnz l04e9h
l03bch:
	lxi d,srcmsg
	mvi c,print
	call bdos
	lxi d,inbuf
	mvi c,linein
	call bdos
	lxi h,0
	shld srctrk
	shld srcsec
	xra a
	sta enddrv
l03d9h:
	lxi h,buffer
	shld dmapt2
	lxi h,0
	shld seccnt
	lhld srctrk
	shld savtrk
	lhld srcsec
	shld savsec
	mvi a,0
	sta hint
	lda srcdrv
	sui 'A'
	mov c,a
	call seldsk
	; fill TPA with sectors from source drive...
l03ffh:
	call getsec
	jnz l04d3h
	lhld seccnt
	inx h
	shld seccnt
	call nxtsrc
	jc l041ah
	xra a
	cma
	sta enddrv
	jmp l042ah
l041ah:
	lhld dmapt2
	lxi d,128
	dad d
	shld dmapt2
	call chkmem
	jc l03ffh
	; TPA full, now write...
l042ah:
	lhld savtrk
	shld dsttrk
	lhld savsec
	shld dstsec
	lxi h,buffer
	shld dmapt2
	lhld seccnt
	shld countr
	lda dstdrv
	sui 'A'
	mov c,a
	call seldsk
	; write TPA to destination drive
l044bh:
	lhld countr
	mov a,l
	ora h
	jz l0469h
	call putsec
	jnz l04fbh
	lhld dmapt2
	lxi d,128
	dad d
	shld dmapt2
	call nxtdst
	jc l044bh
	; now verify what was written...
l0469h:
	lxi h,buffer
	shld dmaptr
	lhld savtrk
	shld srctrk
	lhld savsec
	shld srcsec
	lhld seccnt
	shld countr
	lxi h,defdma
	shld dmapt2
l0487h:
	lhld countr
	mov a,h
	ora l
	jz l04b2h
	call getsec
	jnz l0501h
	lhld dmaptr
	lxi d,defdma
	lxi b,128
l049eh:
	ldax d
	cmp m
	jnz l0501h
	inx h
	inx d
	dcr c
	jnz l049eh
	shld dmaptr
	call nxtsrc
	jmp l0487h

l04b2h:
	lda enddrv
	ora a
	jz l03d9h
	lxi d,endmsg
	mvi c,print
	call bdos
	jmp l03bch

chkmem:
	push d
	push h
	lded bdos+1
	mvi e,0
	dcr d
	ora a
	dsbc d
	pop h
	pop d
	ret

l04d3h:
	lxi d,srcerr
l04d6h:
	mvi c,print
	call bdos
	jmp l03bch

	lxi d,drverr
l04e1h:
	mvi c,print
	call bdos
	jmp cpm

l04e9h:
	lxi d,fmterr
	jmp l04e1h

	lxi d,samerr
	jmp l04e1h

l04f5h:
	lxi d,synerr
	jmp l04e1h

l04fbh:
	lxi d,dsterr
	jmp l04d6h
l0501h:
	lxi d,vererr
	jmp l04d6h

; get parrams from DPH/DPB
getfmt:	; HL -> DPH
	mov e,m
	inx h
	mov d,m
	sded sectbl
	lxi d,9
	dad d
	mov e,m
	inx h
	mov h,m
	mov l,e
	; HL -> DPB
	mov e,m
	inx h
	mov d,m
	sded numsec
	inx h
	mov c,m	; BSH
	inx h
	inx h
	inx h
	mov e,m	; DSM
	inx h
	mov d,m
	inx d
	push d
	lxi d,7
	dad d
	mov e,m	; OFF
	inx h
	mov d,m
	pop h
	push b
	push d
	mov a,c
	ora a
	jz l053bh
l0536h:	; multiply DSM by BSH - total num secs per disk
	dad h
	dcr c
	jnz l0536h
l053bh:	; compute number of tracks...
	lded numsec
	lxi b,0
	ora a
l0543h:
	inx b
	dsbc d
	jz l054ch
	jnc l0543h
l054ch:
	pop h
	dad b	; add OFF
	pop b
	shld numtrk
	lded numsec
	liyd sectbl
	ret

numsec:	dw	0
numtrk:	dw	0
sectbl:	dw	0

getsec:
	lbcd srctrk
	call settrk
	lbcd srcsec
	lded sectbl
	call sectrn
	mov c,l
	mov b,h
	call setsec
	lbcd dmapt2
	call setdma
	call read
	lhld countr
	dcx h
	shld countr
	ora a
	ret

putsec:
	lbcd dsttrk
	call settrk
	lbcd dstsec
	lded sectbl
	call sectrn
	mov c,l
	mov b,h
	call setsec
	lbcd dmapt2
	call setdma
	lda hint
	mov c,a
	lxi d,0
	mvi a,002h
	sta hint
	call write
	lhld countr
	dcx h
	shld countr
	ora a
	ret

nxtsrc:
	lhld srcsec
	inx h
	shld srcsec
	lded numsec
	ora a
	dsbc d
	rc
	shld srcsec
	lhld srctrk
	inx h
	shld srctrk
	lded numtrk
	ora a
	dsbc d
	ret

nxtdst:
	lhld dstsec
	inx h
	shld dstsec
	lded numsec
	ora a
	dsbc d
	rc
	shld dstsec
	lhld dsttrk
	inx h
	shld dsttrk
	lded numtrk
	ora a
	dsbc d
	ret

; BLOCK 'seg5' (start 0x0603 end 0x0680)
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
stack:	ds	0

	rept	((stack+07fh) and 0ff80h)-stack
	db	0
	endm

buffer:	ds	0
