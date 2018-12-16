vers equ '0a' ; January 19, 1983  08:17  drm  "SETEXEC.ASM"
***************************************************************
** Sets ".COM" file attribute bit f1 to "1" or "0"	     **
** to cause execution by 77422 CPU or Z89.		     **
***************************************************************
	maclib	Z80

cpm	equ	0
defdsk	equ	4
bdos	equ	5
fcb	equ	5ch
dma	equ	80h
tpa	equ	100h

msgout	equ	9
setatt	equ	30

bell	equ	7
lf	equ	10
cr	equ	13

chr422	equ	'`'	;character associated with 77422 execution
chrz89	equ	'~'	;character to cause Z89 execution

	org	tpa
	jmp	start
	db	'100182DRM'

signon: db	cr,lf,'SETEXEC version 2.29'
	dw	vers
	db	cr,lf,'(c) 1983 Magnolia Microsystems$'

help:
 db cr,lf,'This program sets the default execution mode for ".COM" files.'
 db cr,lf,'Type:  SETEXEC filename param'
 db cr,lf,'filename = name of a ".COM" file'
 db cr,lf,'param    = "77422" or "Z89"'
 db '$'

nammsg: db	cr,lf,'"d:filename.typ"$'
setmsg: db	' set for '
param:	db	'..... execution.$'
nofmsg: db	' not found.$'

parerr: db	cr,lf,'Missing or invalid Parameter.$'
filerr: db	cr,lf,'Filename must not have "?".$' 

l7422:	db	'77422'
z89:	db	'Z89',0,0

start:	lxi	d,signon
	mvi	c,msgout
	call	bdos
	lxi	d,help
	lda	fcb+1
	cpi	' '
	jz	msgret
	cpi	'?'
	jz	msgret
	lxix	fcb
	mvix	'C',+9
	mvix	'O',+10
	mvix	'M',+11
	lxi	h,fcb
	lxi	b,8
	mvi	a,'?'	;check for any "?" in name (not allowed)
	ccir
	lxi	d,filerr
	jz	msgret
	lxi	h,fcb
	lxi	d,nammsg+3
	mov	a,m
	inx	h
	ora	a
	jnz	st0
	lda	defdsk
	ani	00001111b
	inr	a
st0:	adi	'A'-1
	stax	d
	inx	d
	inx	d
	lxi	b,8
	ldir
	inx	d
	mvi	c,3
	ldir		;"COM" forced
	mvi	c,10000000b
	lxi	d,l7422
	lda	fcb+17
	cpi	' '
	jz	invpar
	cpi	chr422
	jz	gotsc
	call	cmpstr
	jz	got
	mvi	c,00000000b
	lxi	d,z89
	lda	fcb+17
	cpi	chrz89
	jz	gotsc
	call	cmpstr
	jz	got
invpar: lxi	d,parerr
	jmp	msgret

gotsc:	lda	fcb+17+1
	cpi	' '
	jnz	invpar
got:	push	b
	lxi	h,param
	lxi	b,5
	xchg
	ldir
	pop	b
	lxix	fcb
	ldx	a,+1
	ani	01111111b
	ora	c	;set/reset F1'
	stx	a,+1
	lxi	d,fcb
	mvi	c,setatt
	call	bdos
	push	psw
	lxi	d,nammsg
	mvi	c,msgout
	call	bdos
	pop	psw
	cpi	255
	lxi	d,nofmsg
	jz	msgret
	lxi	d,setmsg
msgret: mvi	c,msgout
	jmp	bdos

cmpstr: lxi	h,fcb+17 ;DE points to reference string, 5 characters max
	push	d
	mvi	b,5
cs0:	ldax	d
	ora	a
	jz	endref
	cmp	m
	jnz	xit	;[NZ]
	inx	h
	inx	d
	dcr	b
	jnz	cs0
endref: mov	a,m
	cpi	' '	;users string must end here also
xit:	pop	d
	ret	;[ZR] if alls well...

	end


