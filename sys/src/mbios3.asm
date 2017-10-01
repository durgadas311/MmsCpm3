vers equ '2 ' ; Sep 27, 2017  17:35   drm "MBIOS3.ASM"
;****************************************************************
; Main BIOS module for CP/M 3 (CP/M plus),			*
;	 Banked memory and Time split-out.			*
; Copyright (c) 1983 Magnolia Microsystems			*
;****************************************************************
	maclib Z80

true	equ -1
false	equ not true

cr	equ	13
lf	equ	10
bell	equ	7

cpm	equ	0
bdos	equ	5
RST1	equ	8
ccp	equ	0100h	; Console Command Processor gets loaded into the TPA

port	equ	0f2h	;interupt control port

;  SCB registers
	extrn @covec,@civec,@aovec,@aivec,@lovec,@ermde
	extrn @mxtpa,@bnkbf,@sec,@min,@hour,@date
	extrn @lptbl,@nbnk,@compg,@mmerr

;  External routines
	extrn ?getdp,?serdp
	extrn ?bnksl,?bnkck,?xmove,?mvccp,?move
	extrn ?time,?itime

;  Variables for use by other modules
	public @adrv,@pdrv,@rdrv,@side,@trk,@sect,@login
	public @dma,@dbnk,@cnt,@scrbf,@dtacb,@dircb
	public @dstat,@intby,@cmode,@dph,@rcnfg,@tick0
	public @ctbl,@cbnk,bnkdos,resdos,wbtrap

;  Routines for use by other modules
	public ?timot
	public ?dvtbl,?drtbl
	public ?stbnk

;-------- Start of Code-producing source -----------

	cseg		; GENCPM puts CSEG stuff in common memory
BIOS$0	equ	$
bnkdos	equ	bios$0+0fc00h	;dummy values, reloc "Fxxx", GENCPM will
resdos	equ	bios$0+0fd00h	; substitiute real values.
	jmp boot	; initial entry on cold start
	jmp wboot	; reentry on program exit, warm start
 
	jmp const	; return console input status
	jmp conin	; return console input character
	jmp conout	; send console output character
	jmp list	; send list output character
	jmp auxout	; send auxilliary output character
	jmp auxin	; return auxilliary input character

	jmp home	; set disks to logical home
	jmp seldsk	; select disk drive, return disk parameter info
	jmp settrk	; set disk track
	jmp setsec	; set disk sector
	jmp setdma	; set disk I/O memory address
	jmp read	; read physical block(s)
	jmp write	; write physical block(s)

	jmp listst	; return list device status
	jmp sectrn	; translate logical to physical sector

	jmp conost	; return console output status
	jmp auxist	; return aux input status
	jmp auxost	; return aux output status
?dvtbl: jmp devtbl	; return address of device def table
	jmp cinit	; change baud rate of device

?drtbl: jmp getdrv	; return address of disk drive table
	jmp multio	; set multiple record count for disk I/O
	jmp flush	; flush BIOS maintained disk caching

	jmp ?move	; block move memory to memory
	jmp ?time	; Signal Time and Date operation
	jmp ?bnksl	; select bank for code execution and default DMA
?stbnk: jmp setbnk	; select different bank for disk I/O DMA operations.
	jmp ?xmove	; set source and destination banks for one operation

	jmp search	; reserved for OEM: search for module.
	jmp 0		; reserved for future expansion
	jmp 0		; reserved for future expansion

@dstat: ds	1
@intby: ds	1

	dw	@lptbl	;logical/physical drive table
	dw	thread	;module thread
	dw	?serdp	;test mode validity, HL=memory address of ?serdp

@adrv:	ds	1		; currently selected disk drive
@pdrv:	ds	1		; physical drive number (MMS)
@rdrv:	ds	1		; module relative disk drive number
curmdl: ds	2		; currently selected Disk I/O module address
@cmode: ds	2
@dph:	ds	2

icovec: dw	1000000000000000b
icivec: dw	1000000000000000b
iaovec: dw	0010000000000000b
iaivec: dw	0010000000000000b
ilovec: dw	0100000000000000b

defsrc: db	0,0ffh,0ffh,0ffh
tmpdrv: db	0
srctyp: db	000$00$000b	;only bits 3,4 are used (others ignored)

bdose:	lhld	@mxtpa
	pchl

@dma:	dw	0
wbtrap: dw	0

;  Note Page-0 handling in banked system: At cold start, all vectors are
;initialized in bank 0, then copied to banks 1,2...  Then at warm starts,
;the vectors are re-initialized from bank 0.
;
boot$1:
	; bank 0 selected at this point...
	call	?itime	; Initial setting of time/date in SCB
	lxi	d,signon
	mvi	c,9
	call	bdose
	; BDOS selects bank 1...
	lda	bnkflg
	ora	a	;is banked memory installed?
	jz	ramerr
	lda	@compg
	dcr	a	; minus 0100h
	rrc
	rrc
	rrc
	rrc
	mov	h,a
	ani	0f0h
	mov	l,a
	mov	a,h
	ani	00fh
	mov	h,a	; HL=space in a bank / 16
	shld	hsize	; not used until seldsk... currently.
	mvi	c,0
	call	set$jumps  ;setup system jumps and put in all banks
	; interrupts now enabled
	; bank 1 selected
; fetch CCP for first time, system will put it in bank 1.
	lxi	d,ccp$com
	mvi	c,15	;open file
	call	bdose
	inr	a
	jz	noccp
	xra	a
	sta	fcb$nr
	lxi	d,ccp
	mvi	c,26	;set DMA address
	call	bdose
	mvi	e,128	;read upto 128 records (16K)
	mvi	c,44	;set multi-sector count
	call	bdose
	lxi	d,ccp$com
	mvi	c,20	;read record(s)
	call	bdose
	mov	a,h	;H=number of records actually read
	sta	ccprecs
	mvi	c,1	; save CCP in bank 0 for warm boots.
	mvi	b,0	;NOTE: this restricts banked OS size to 39K.
	jmp	goccp	; (allowing 16K for "CCP" and reserving page 0)

; Don't know which bank is selected...
wboot:	lxi	sp,stack
	call	reset$pg0	; initialize page zero
				; leaves bank 1 selected...
	lda	ccprecs 	; reload CCP
	mvi	c,0
	mvi	b,1
goccp:	lxi	h,ccp
	call	?mvccp
	mvi	a,0	; allow I/O modules to partake in the warm$boot.
	call	?bnksl	;
	lhld	wbtrap	;
	mov	a,h	;
	ora	l	;
	cnz	icall	;
	mvi	a,1	;
	call	?bnksl	;
	jmp	ccp 	; exit to ccp

set$jumps:
reset$pg0:
	di
	lda	@intby
	ori	00000010b	; enable 2mS clock intr
	sta	@intby
	out	port ; a side-effect of bnksel used to be output @intby...
	xra	a	;
	call	?bnksl	;select bank 0
	mvi a,(JMP)
	sta cpm ! sta bdos	; set up jumps in page zero
	sta RST1
	lxi h,BIOS$0+3 ! shld cpm+1	; BIOS warm start entry
	lhld @mxtpa ! shld bdos+1	; BDOS system call entry
	lxi h,clock ! shld RST1+1	;bank 0 is all set...
	lxi	h,0	;
	lded	@bnkbf	;
	lxi	b,64	;
	ldir		;
	lda	@nbnk
rpg1:	dcr	a
	jz	rpg0
	push	psw
	call	?bnksl
	lhld	@bnkbf	;
	lxi	d,0	;
	lxi	b,64	;
	ldir		;
	pop	psw
	jr	rpg1
rpg0:	ei	; bank 1 is selected
	ret

	ds 64
stack	equ $
	ds 32
iostk	equ $
iostkp: dw	$-$

clock:	sspd	istk
	lxi	sp,intstk
	push	psw
	push	h
	lda	@intby
	out	port
	lxi	h,@tick0
	dcr	m
	jrnz	xit
	mvi	m,t0cnt
	inx	h
	dcr	m
	jrnz	xit		;ONE SECOND:
	mvi	m,t1cnt
	push	b
	lxi	h,tictbl	; see if anything needs to be timed out
	mvi	b,numtic
to4:	mov	a,m
	inx	h
	cpi	true
	jz	to3
	mov	a,m
	ora	a
	jrz	to5		; nothing is timing out
	dcr	m
	jrnz	to3		; not timed out yet
	push	b
	push	h
	inx	h
	mov	a,m  
	inx	h
	mov	h,m
	mov	l,a
	call	icall		; call module time out routine
	pop	h
	pop	b
	mov	a,m
	ora	a
	jrnz	to3
to5:	dcx	h
	mvi	m,true
	inx	h
to3:	inx	h
	inx	h
	inx	h
	dcr	b
	jrnz	to4
	pop	b
	lxi	h,@sec
	mov	a,m
	adi	1
	daa
	mov	m,a
	cpi	60h
	jrc	xit
	mvi	m,00h
	lxi	h,@min
	mov	a,m
	adi	1
	daa
	mov	m,a
	cpi	60h
	jrc	xit
	mvi	m,00h
	lxi	h,@hour
	mov	a,m
	adi	1
	daa
	mov	m,a
	cpi	24h
	jrc	xit
	mvi	m,00h
	lhld	@date
	inx	h
	shld	@date
xit:	pop	h
	pop	psw
	lspd	istk
	ei
	ret

?timot: ei			; (B)=I.D. (C)=count, (DE)=routine address
	push	d
to1:	mvi	e,numtic
	lxi	h,tictbl
to0:	mov	a,m
	cpi	true
	jrz	to2
	cmp	b
	jrz	to2
	inx	h
	inx	h
	inx	h
	inx	h
	dcr	e
	jrnz	to0
	mov	a,c	;don't wait if all it wants is to clear a possible
	ora	a	;existing entry, since none exists for that module.
	jrnz	to1	;
	pop	d
	ret
to2:	di
	pop	d
	mov	m,b
	inx	h
	mov	m,c
	inx	h
	mov	m,e
	inx	h
	mov	m,d
	ei
	ret

tictbl: db	true,0
	dw	$-$
	db	true,0
	dw	$-$
numtic equ ($-tictbl)/4

@tick0: db	t0cnt,t1cnt	;
t0cnt	equ	10	;counts 2 milliseconds into 20 milliseconds.
t1cnt	equ	50	;counts 20 milliseconds into 1 second.

signon: db	13,10,7,'CP/M 3.10'
	dw	vers
	db	' (c) 1982,1983 DRI and MMS'
	db	13,10,'$'

ramerr: lxi	d,@mmerr
	jr	errx
noccp:	lxi	d,ccp$msg
errx:	mvi	c,9
	call	bdose
	di ! hlt

ccp$msg db	13,10,7,'No CCP$'

ccp$com db	1,'CCP     COM',0,0,0,0
	ds	16
fcb$nr	db	0,0,0,0

	ds	16	;8 levels of stack
intstk: ds	0
istk:	dw	0

ccprecs db	0

; SEARCH for a module by device #.
;   entry:	C = device # (0-249)
;   exit:	[CY] = not found
;	   else HL=module address ("init" entry)
;		A=device number (relative to module's #0)
;

search: lxi	d,thread	;C=device number
snext:	xchg
	mov	e,m
	inx	h
	mov	d,m
	inx	h
	mov	a,d
	ora	e
	sui	1	;produce [CY] if DE=0000
	rc		;return if device not found, DE=0000
	mov	a,c
	sub	m
	jrc	snext
	inx	h
	cmp	m
	jrnc	snext
	inx	h	;point to "init" vector
	ora	a	;set [NC] condition
	ret

devtbl: lxi	h,@ctbl
	ret

@ctbl:	db	'nodev ',0,0	;character table, filled at cold-start.
	db	'nodev ',0,0
	db	'nodev ',0,0
	db	'nodev ',0,0
	db	'nodev ',0,0
	db	'nodev ',0,0
	db	'nodev ',0,0
	db	'nodev ',0,0
	db	'nodev ',0,0
	db	'nodev ',0,0
	db	'nodev ',0,0
	db	'nodev ',0,0
	db	0	;table terminator

cdtbl:	rept 12 	;character device table, filled at cold-start.
	dw cnull
	endm

cnull:	jmp	null	;init
	jmp	nulli	;input status
	jmp	nulli	;input
	jmp	nulli	;output status
	jmp	null	;output


nulli:	mvi	a,1ah	;E.O.F. character, also [NZ] to be always ready.
	ora	a	;sets [NZ] condition.
null:	ret


cinit:	mvi	b,0	;C=device number (0-11)
	lxi	h,cdtbl
	dad	b   
	dad	b  
	mov	e,m
	inx	h
	mov	d,m
	mov	b,c
	xchg
	pchl		;jump to modules "init" with B=device #

conout: 
	lhld	@covec	; fetch console output bit vector
	jr	out$scan0

auxout:
	lhld	@aovec	; fetch aux output bit vector
	jr	out$scan0

list:
	lhld	@lovec	; fetch list output bit vector
out$scan0:
	call	swtosys
out$scan:
	lxi	d,cdtbl
	mvi	b,0
co$next:
	slar	h	; shift out next bit
	mvi	a,12
	cc	indjmp1
	inx	d
	inx	d
	inr	b
	mov a,h ! ora a ; see if any devices left
	jrnz	co$next ; and go find them...
	jmp	xitusr
  
conost:
	lhld	@covec	; get console output bit vector
	jr	ost$scan0

auxost:
	lhld	@aovec	; get aux output bit vector
	jr	ost$scan0

listst:
	lhld	@lovec	; get list output bit vector
ost$scan0:
	call	swtosys
ost$scan:
	lxi	d,cdtbl
	mvi	b,0	;B = device number
cos$next:
	slar	h	; check next bit
	mvi a,9 	; [NZ] will assume device ready (in case no call made)
	cc	indjmp1 ; check status for this device
	ora a		; see if device ready
	jrz	xitusr	; if any not ready, return false
	inx	d
	inx	d
	inr	b
	mov a,h ! ora a ; see if any more selected devices
	jrnz cos$next
	ori 0FFh	; if all selected were ready, return true
	jr	xitusr



const:
	lhld	@civec	; get console input bit vector
	jr	ist$scan0

auxist:
	lhld @aivec	; get aux input bit vector
ist$scan0:
	call	swtosys
	lxi	d,xitusr
	push	d
ist$scan:
	lxi	d,cdtbl
	mvi	b,0
cis$next:
	slar	h	; check next bit
	jnc is0
	mvi a,3 	; assume device not ready
	call indjmp1	; check status for this device
	ora a ! rnz	; if any ready, return true
is0:	inx	d
	inx	d
	inr	b
	mov a,h ! ora a ; see if any more selected devices
	jrnz cis$next
	xra a		; all selected were not ready, return false
	ret


conin:
	lhld	@civec
	jr	in$scan0

auxin:
	lhld	@aivec
in$scan0:
	call	swtosys
in$scan:
	push	h
	call	ist$scan	;see if there is a character ready
	pop	h
	ora	a
	jrz	in$scan ;wait untill one is ready.
	mvi	a,6
	call	indjmp	;get character
	jr	xitusr

swtosys:
	pop	d	;routine return address
	lda	@cbnk
	ora	a
	jrz	sw0
	sspd	iostkp
	lxi	sp,iostk
	push	psw
	mvi	a,0
	call	?bnksl
	pop	psw
sw0:	push	psw
	push	d
	ret 

xitusr: mov	b,a
	pop	psw
	ora	a
	jrz	xu0
	call	?bnksl	;preserves BC.
	lspd	iostkp
xu0:	mov	a,b
	ora	a
	ret

indjmp1:
	push	h
	push	d
	push	b
	call	indjmp
	pop	b
	pop	d
	pop	h
	ret

indjmp: xchg
	add	m	;a=0,3,6,9,12,...
	mov	e,a
	mvi	a,0
	inx	h
	adc	m
	mov	d,a
	xchg
	pchl		;indirect call

addjmp: add	l	;a=0,3,6,9,...
	mov	l,a
	mvi	a,0
	adc	h
	mov	h,a
icall:	pchl		;indirect call

@cbnk:	db	0		; bank for processor operations
bnkflg: ds	1	;flag for banked RAM installed.

hbnk	equ	2	;bank to use for Hash tables.
hstart	equ	100h	;reserve page 0 for interupt vectors, etc.
hsize	dw	0	;1/16 of amount of space in a bank

dtabf1: ds	1024
dtabf2: ds	1024-1
	db	0	;to force LINK to fill with "00"

;must be at end of all "cseg" code.
thread	equ	$

	dseg	; this part can be banked
@login: ds	2	;position is assumed by special BNKBDOS3.SPR...
			; must be first item in DSEG.
boot:	lxi	sp,stack
	lda	13
	ani	11111101b	;we must be in bank 0 now or all is lost...
	sta	@intby
	out	port
; Verify that we have banked RAM...
	call	?bnkck
	sta	bnkflg	;assume X/2-H8 Bank Switch not installed (error)
; Initialize all modules and build tables.
	lxi	h,thread	;thread our way through the modules,
in0:	mov	e,m		;initializing as we go.
	inx	h
	mov	d,m	;next module, or "0000" if we're past the end.
	inx	h
	mov	a,d
	ora	e
	jz	init$done
	mov	a,m	;device base number
	inx	h
	inx	h	;thread+4 = init entry (JMP)
	sui	200	;if Char I/O module, build entry(s) in tables.
	jc	notchr
	push	d	;save NEXT module address
	mov	c,a
	mvi	b,0
	dcx	h
	mov	a,m	;number of devices
	inx	h
	xchg		;DE=init entry point
	lxi	h,cdtbl
	dad	b
	dad	b
	mov	b,a
	mov	a,c
in1:	cpi	12
	jnc	in4	;if device # overflows, adjust next step.
	mov	m,e		;
	inx	h		;
	mov	m,d		;
	inx	h		;
	inr	a
	djnz	in1
	dcx	d
	ldax	d	;number of devices
in3:	mov	b,a
	mov	a,c	;DE=module address, C=device base
	add	a	; *2
	add	a	; *4
	add	a	; *8
	mov	c,a
	mov	a,b	;number of devices
	mvi	b,0
	lxi	h,@ctbl
	dad	b
	xchg		;DE=@ctbl indexed by device base
	mvi	c,17+1	;B=0 still, point to CHRTBL vector
	dad	b	;point to chrtbl location
	mov	c,m
	inx	h
	mov	h,m
	mov	l,c	;HL=chrtbl
	add	a
	add	a
	add	a	;num.dev * 8 = number of bytes in module's table.
	mov	c,a	;B=0 still
	ldir		;copy modules chrtbl into system table.
in2:	pop	h
	jmp	in0

in4:	sub	c	;compute number of devices that will fit.
	jnz	in3	;continue with initialization of tables
	jmp	in2

notchr: 		;HL point to init entry
	push	d
	call	icall	;"call" (HL)
	pop	h
	jmp	in0

init$done:		;all Disk I/O modules are initialized.
	mvi	c,11
in5:	push	b
	call	cinit
	pop	b
	dcr	c
	jp	in5

	lhld	icovec
	shld	@covec	;set console I/O
	lhld	icivec
	shld	@civec	;
	lhld	ilovec
	shld	@lovec	;set list output device
	lhld	iaovec
	shld	@aovec	;set auxiliary I/O device
	lhld	iaivec
	shld	@aivec	;
	lxi	h,defsrc
	lxi	d,@ermde+1	;location of default search chain in SCB
	lxi	b,5
	ldir
	lda	srctyp
	ani	000$11$000b
	mov	c,a
	lda	@civec-10	;location of search type flags in CCP section
	ani	111$00$111b
	ora	c
	sta	@civec-10
	jmp	boot$1

getdrv:
	lxi h,@dtbl ! ret

@dtbl:	dw	dnull,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

dnull:	dw 0,0,0,0,0,0,0,0,0,@dircb,@dtacb,0
	db 0

seldsk:
	mov a,c ! sta @adrv			; save drive select code
	lxi	h,@lptbl
	mvi b,0 ! dad b 	      ; create index from drive code
	mov	a,m
	cpi	255
	jrz	selerr
	sta	@pdrv
	mov	c,a
	mov	b,e	;save login flag thru "search" routine
	call	search
	jrc	selerr
	sta	@rdrv
	shld	curmdl
	push	b	;save login bit
	lxi	d,14
	dad	d	;point to dphtbl
	mov	e,m	;DE=dphtbl
	inx	h
	mov	d,m
	inx	h
	mov	c,m	;BC=modtbl
	inx	h
	mov	b,m
	lda	@rdrv
	add	a
	add	a
	add	a	;*8
	mov	l,a
	mvi	h,0
	dad	b	;select mode bytes
	shld	@cmode	;set current mode pointer
	pop	b	;get login bit back.
	bit	0,b	;test for initial select.
	jrnz	notlgi
	xchg		;DE=modes
	mov	c,a
	mvi	b,0
	dad	b	;+*8
	dad	b	;+*16
	dad	b	;+*24
	lda	@rdrv
	mov	c,a
	dad	b	;+*1 = +*25
	shld	@dph
	call	setup$dph
	jrc	selerr
	xra	a
	sta	@rcnfg
	mvi	a,3
	call	calmod	;call module's "login" routine.
	ora	a	;see if an error occured.
	jrnz	selerr
	lda	@rcnfg
	ora	a
	cnz	setup$dph
	jrc	selerr
	lda	@adrv
	add	a
	mov	c,a
	mvi	b,0
	lxi	h,@dtbl
	dad	b
	lded	@dph
	mov	m,e	;set current DPH in @dtbl
	inx	h
	mov	m,d
	jr	selcom	;DE=dph

selerr: lxi	h,0
	ret

notlgi: lda	@adrv
	add	a
	mov	c,a
	mvi	b,0
	lxi	h,@dtbl
	dad	b
	mov	e,m	;get current DPH from @dtbl
	inx	h
	mov	d,m	;DE=dph
	sded	@dph
selcom: lhld	@cmode
	lxi	b,0	;
	bit	7,m	;Tracks-per-side not valid for Hard disks.
	jrnz	selxit
	inx	h
	bit	1,m	;unless its Z17...
	jrz	sc0
	mvi	b,4	;then side 1 has 4 less tracks (8 on DT)
sc0:	mvi	a,40	;assume 5" ST
	inx	h
	bit	7,m	;check 5" drive
	jrz	sc1
	mvi	a,77	;8" drives have 77 tracks
sc1:	mov	c,a	;set side 0 tracks
	sub	b
	mov	b,a
	inx	h	;fix for HT bug
	bit	5,m	;check for DT
	jrz	selxit
	slar	b	;multiply # of tracks by 2 if DT
	slar	c	;
selxit: sbcd	@tps
	lded	@dph
	lxi	h,+12
	dad	d	;point to DPB entry
	mov	c,m
	inx	h
	mov	b,m
	ldax	b	;logical sectors-per-track, byte value
	lxi	h,+15
	dad	b
	mov	b,m	;psh
	inr	b
gh2:	dcr	b
	jz	gh3
	srlr	a
	jr	gh2
gh3:	sta	@pspt	;physical sectors per track
	lda	@adrv	;allocate hash buffer by logical drive number
	lxi	h,hstart
	lbcd	hsize
	inr	a
gh0:	dcr	a
	jrz	gh1
	dad	b
	jr	gh0
gh1:	mov	c,l
	mov	b,h
	lxi	h,+22
	dad	d	;point to hash address
	mov	m,c	;set hash buffer address for this drive.
	inx	h
	mov	m,b
	inx	h
	mvi	m,hbnk	;set hash bank also.
	xchg	;put DPH in (HL) for BDOS
	ret

setup$dph:
	ora	a	;reset [CY]
	lhld	@cmode	;HL=modes
	bit	7,m	;check for hard-disk drive (modes not standard)
	rnz
	call	?getdp
	stc
	rnz
	lhld	@dph	;restore dph
	mov	m,c	;set XLAT table
	inx	h
	mov	m,b
	lxi	b,12-1
	dad	b	;point to dpb
	mov	m,e	;set DPB
	inx	h
	mov	m,d	;(DE=dpb)
	ora	a	;reset [CY]
	ret

home:	lxi b,0 	; same as set track zero
settrk: sbcd trk
	ret

setsec: sbcd sect
	ret

setdma: sbcd @dma
	lda @cbnk	; default DMA bank is current bank
setbnk: sta @dbnk
	ret

sectrn: mov l,c ! mov h,b
	mov a,d ! ora e ! rz
	xchg ! dad b ! mov l,m ! mvi h,0
	dcx	h	;sectors numbered 0 - (n-1)
	ret

read:	mvi	e,6	;read entry is +6
	jmp rw$common			; use common code

write:	mvi	e,9	;write entry is +9

rw$common:	;do any track/sector/side conversion...
	xra	a
	sta	@side
	lhld	trk
	shld	@trk
	lhld	sect
	shld	@sect
	lhld	@cmode
	bit	7,m	;floppy or hard-disk?
	jrnz	rw0
	inx	h
	inx	h
	inx	h
	bit	6,m
	jrz	rw0
	mov	a,m
	ani	0011b	;DSALG
	jrz	wrap	;as done by MMS
	dcr	a
	jrz	alt	;as done by Zenith
	dcr	a
	jrz	cont1	;as done by EXO and Televideo.

cont2:	lda	@pspt	;as done by Gnat
	srlr	a	;SPT must be EVEN
	mov	c,a
	lda	@sect
	cmp	c	;don't change the sector number on side 1
	jrc	rw0
	jr	side1

cont1:	lda	@pspt
	srlr	a	;SPT must be EVEN
	mov	c,a
	lda	@sect
	sub	c
	jrc	rw0
	sta	@sect
	jr	side1

alt:	lda	@trk
	rar
	sta	@trk
	mvi	a,0
	ral
	sta	@side
	jr	rw0

wrap:	lbcd	@tps	;B=tracks on side 1, C=tracks on side 0
	lda	@trk	;(for all except Z17, B=C)
	cmp	c
	jrc	rw0
	neg
	add	c
	add	b
	dcr	a
	sta	@trk
side1:	mvi	a,1
	sta	@side
rw0:	mov	a,e
calmod: lhld	curmdl
	jmp	addjmp			; leap to driver

multio: sta @cnt ! ret

flush:	xra a ! ret		; return with no error


@side:	ds	1		; current side of media (floppy only)
@trk:	ds	2		; current track number
@sect:	ds	2		; current sector number
@cnt:	db	0		; record count for multisector transfer
@dbnk:	db	0		; bank for disk DMA operations
@pspt:	ds	1		; physical sectors per track
@tps:	ds	2
@rcnfg: ds	1
trk:	ds	2		 
sect:	ds	2

@scrbf: ds	1024

@dtacb: dw	dtacb1
@dircb: dw	dircb1

dtacb1: db 0ffh ;drive
	db 0,0,0,0,0
	dw 0,0,dtabf1
	db 0
	dw dtacb2

dtacb2: db 0ffh ;drive
	db 0,0,0,0,0
	dw 0,0,dtabf2
	db 0
	dw 0000 ;end of data buffers

dircb1: db 0ffh ;drive
	db 0,0,0,0,0
	dw 0,0,dirbf1
	db 0
	dw dircb2

dircb2: db 0ffh ;drive
	db 0,0,0,0,0
	dw 0,0,dirbf2
	db 0
	dw 0000 ;end of DIR buffers

dirbf1: ds	1024
dirbf2: ds	1024-1
	db	0	;to force LINK to fill space with "00"

	end
