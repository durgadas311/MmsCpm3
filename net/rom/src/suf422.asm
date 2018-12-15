VERS1 set 35 ; (Dec 14, 2018 21:34) drm  "SUF422.ASM"
 if VERS1 gt VERS
VERS set VERS1
 endif

; All nodes have equal responsibility. no Server/Requestor determination.

*********************************************************
**  Debug mode
*********************************************************

debug:
	lda	ntype
	push	psw
	sspd	savstk
	mvi	a,1
	out	cmdB
	lxi	h,chBwr1
	mov	a,m
	ani	00000100b	;all interupts,etc off
	mov	m,a
	out	cmdB
	mvi	a,TDBG
	sta	ntype
	mvi	a,false
	sta	dbgflg
	lxi	h,signon	;display revision message
	call	msgout
cilp:	lspd	savstk
	lxi	h,cilp		;setup return address
	push	h
	lxi	h,prompt	;prompt for a command
	call	msgout
	call	linein		;wait for command line to be entered
	lxi	d,line
	call	char		;get first character
	rz			;ignore line if it is empty
	lxi	h,comnds	;search table for command character
	mvi	b,ncmnds	;(number of commands)
cci0:	cmp	m		;search command table
	inx	h
	jrz	gotocmd		;command was found, execute it
	inx	h		;step past routine address
	inx	h
	djnz	cci0		;loop untill all valid commands are checked
error	lxi	h,errm		;if command unknown, beep and re-prompt
	jmp	msgout

gotocmd:
	push	d		;save command line buffer pointer
	mov	e,m		;get command routine address
	inx	h
	mov	d,m		;DE = routine address
	xchg			;HL = routine address
	pop	d		;restore buffer pointer
	pchl			;jump to command routine

** Macros to build the command code and routine address tables
comnds:
	db	'?'
	dw	Qcomnd
	db	'D'
	dw	Dcomnd
	db	'S'
	dw	Scomnd
	db	'G'
	dw	Gcomnd
	db	'L'
	dw	Lcomnd
	db	'M'
	dw	Mcomnd
	db	'F'
	dw	Fcomnd
	db	'R'
	dw	Rcomnd
	db	'T'
	dw	Tcomnd
ncmnds	equ	($-comnds)/3

*********************************************************
**  Command subroutines
*********************************************************

menu:	db	cr,lf,'D <start> <end> - display memory in HEX'
	db	cr,lf,'S <start> - set/view memory'
	db	cr,lf,'G <start> - go to address'
	db	cr,lf,'L <start> <end> - list instructions'
	db	cr,lf,'F <start> <end> <data> - fill memory'
	db	cr,lf,'M <start> <end> <dest> - Move data'
	db	cr,lf,'T - Test 64K memory'
	db	cr,lf,'T <#> - test 56K bank(s) #=1,2,3,4'
	db	cr,lf,'R - return to network'
	db	0

Qcomnd:	lxi	h,menu
	jmp	msgout

Rcomnd:
	mvi	a,001h
	out	cmdB
	lxi	h,chBwr1
	mov	a,m
	ori	01ah
	mov	m,a
	out	cmdB
	lspd	savstk
	pop	psw
	sta	ntype
	ret

Mcomnd:	call	getaddr
	jc	error
	bit	7,b
	jnz	error
	shld	addr0
	call	getaddr
	jc	error
	bit	7,b
	jnz	error
	shld	addr1
	call	getaddr
	jc	error
	bit	7,b
	jnz	error
	xchg
	lbcd	addr0
	lhld	addr1
	ora	a
	dsbc	b
	jc	error
	inx	h
	mov	c,l
	mov	b,h
	push	d
	xchg
	dad	b
	pop	d
	jc	error
	lhld	addr1
	call	check
	jc	mc0
	lhld	addr0
	call	check
	jnc	mc0
	lhld	addr1
	xchg
	dad	b
	dcx	h
	xchg
	lddr
	ret
mc0:	lhld	addr0
	ldir
	ret
Fcomnd:
	call	getaddr ;get address to start at
	jc	error	;error if non-hex character
	bit	7,b	;test for no address (different from 0000)
	jnz	error	;error if no address was entered
	shld	addr0	;save starting address
	call	getaddr ;get stop address
	jc	error	;error if non-hex character
	bit	7,b	;test for no entry
	jnz	error	;error if no stop address
	shld	addr1	;save stop address
	call	getaddr ;get fill data
	jc	error	;error if non-hex character
	bit	7,b	;test for no entry
	jnz	error	;error if no fill data
	mov	a,h
	ora	a
	jnz	error
	mov	c,l	;(C)=fill data
	lhld	addr1	;get stop address
	lded	addr0	;get start address
fc0:	mov	a,c	;
	stax	d	;put byte in memory
	inx	d	;step to next byte
	mov	a,d	;
	ora	e	;if we reach 0000, stop. (don't wrap around)
	rz		;
	call	check	;test for past stop address
	rc	;quit if past stop address
	jr	fc0

***************************************************
** Full Memeory Test
***************************************************
cstat	macro
	mvi	a,10h
	out	constat
	in	constat
	ani	00000100b
	jrz	$-9
	endm
***************************************************
LOPAGE	equ	0E0h

Tcomnd:
	mvi	c,lf
	call	conout
	mvi	l,000h
tc0:	call	char
	jrz	tc1
	cpi	' '
	jz	tc0
	sui	'0'
	cpi	5
	jnc	tc1
	mov	l,a
tc1:	mvi	e,100H-LOPAGE
	mvi	d,0
	mvi	c,LOPAGE
	mvi	b,0
	exx
	lxi	h,FIXJMP
	lxi	d,LOPAGE*256-FIXJ
	lxi	b,PGMLEN+FIXJ
	ldir
	lxi	d,LOPAGE*256
	lxi	h,MEMTEST
	lxi	b,PGMLEN+100H
	xra	a
	exaf
	xra	a
CS1:	add	m
	exaf
	xchg
	add	m
	exaf
	xchg
	inx	h
	inx	d
	dcr	c
	jnz	CS1
	djnz	CS1
	mov	c,a
	exaf
	cmp	c
	jnz	XCSERR
	di
	exx
	mov	a,l
	exx
	stai
	lxix	08001h
	jmp	LOPAGE*256-FIXJ

XCSERR:	lxi	h,CSEMSG
tc4:	jmp	msgout

CSEMSG:	db	cr,lf,bell,'Checksum error!',0

;*** The following block of code must be contiguous but is otherwise
;*** relocatable.
FIXJMP:	db 0DDH
	mov	a,l ;;MOV A,XL
	db 0ddh
	ora	h ;;ORA XH
	out	ctrl
FIXJ EQU $-FIXJMP
;*** The following block of code is check-summed to prevent bad memory from
;*** causing program crash.
MEMTEST: exx
	mov	h,d
	mvi	l,0
	mov	a,b
	exx
	mov	c,a
	mvi	b,2
	cstat
DSP0:	mov	a,c
	rlc
	rlc
	rlc
	rlc
	mov	c,a
	ani	00001111b
	adi	90h
	daa
	aci	40h
	daa
	out	console
	cstat
	dcr	b
	jrnz	DSP0
	mvi	a,cr
	out	console
	exx
	mov	a,b
DMEM0:	mov	m,a
	adi	1
	daa
	inr	l
	jrnz	DMEM0
	inr	h
	dcr	c
	jrnz	DMEM0
	mov	a,h
	sub	d
	mov	c,a
	mov	h,d
	mvi	l,0	;HL = starting address
	mov	a,b
DMEM1:	cmp	m
	jrnz	DYERR
	adi	1
	daa
	inr	l
	jrnz	DMEM1
	inr	h
	dcr	c
	jrnz	DMEM1
	ldai
	ora	a
	jrz	dm0
	mov	c,a
	db 0ddh
	mov	a,l	;;MOV A,XL
	ani	006h
	rrc
	inr	a
	cmp	c
	jrnz	tc10
	xra	a
tc10:	add	a
	jrnz	tc11
	inr	a
tc11:	db 0ddh
	mov	l,a	;; MOV XL,A
	mov	a,h
	sub	d
	mov	c,a
	mvi	a,1
	add	b
	daa
	mov	b,a
	exx
	mvi	d,LOPAGE
	jr	dm1
dm0:	exx
	lxi	h,LOPAGE*256
	lxi	d,0
	lxi	b,PGMLEN
	exx
	mov	a,d
	xri	LOPAGE
	mov	d,a
	jrz	NEXT0
	mov	c,e
	jr	NEXT20
NEXT0:	mvi	c,LOPAGE
	mvi	a,1
	add	b
	daa
	mov	b,a
	exx
	xchg
	exx
NEXT20:	exx
	ldir
dm1:	db	0ddh
	mov	a,h	;MOV A,XH
	xri	BOTH
	db	0ddh
	mov	h,a	;MOV XH,A
	db	0ddh
	ora	l	;ORA XL
	out	ctrl
	mov	a,d
	ani	11110000b
	mov	h,a
	mvi	l,0
	lxi	b,PGMLEN+100H
	xra	a
CS0:	add	m
	inx	h
	dcr	c
	jrnz	CS0
	djnz	CS0
	mov	c,a
	exaf
	cmp	c
	jrnz	CSERR
	exaf
	mov	a,d
	ani	11110000b
	mov	h,a
	mvi	l,0
	pchl

DYERR:	xra	m
	mov	d,a
	cstat
	mvi	a,lf
	out	console
	cstat
	db 0ddh
	mov	a,l	;; MOV A,XL
	ani	110b
	rrc
	adi	'0'
	out	console
	cstat
	mvi	a,'*'
	out	console
	mvi	b,2
DE1:	cstat
	mov	a,d
	rlc
	rlc
	rlc
	rlc
	mov	d,a
	ani	00001111b
	adi	90h
	daa
	aci	40h
	daa
	out	console
	djnz	DE1
	jr	DEAD

CSERR:	cstat
	mvi	a,lf
	out	console
	cstat
	mvi	a,'!'
	out	console
DEAD:	xra	a
	mvi	b,0
DEAD0:	dcr	a
	jrnz	DEAD0
tc22:	dcr	a
	jrnz	tc22
	djnz	DEAD0
	mvi	a,bell
	out	console
	jr	DEAD
PGMLEN	EQU	$-MEMTEST
;***************************************************************************
;*** End of block of code.


Lcomnd:	call	getaddr
	jc	error
	bit	7,b
	jz	L5
	lhld	addr0
L5:	shld	addr0
	mvi	a,255
	sta	count
	call	getaddr
	jc	error
	bit	7,b
	jz	L3
	mvi	a,16
	sta	count
	lhld	addr0
	lxi	d,16*4
	dad	d
L3:	shld	addr1
	lded	addr0
L0:	call	crlf
	call	taddr
	call	space
	ldax	d
	ani	11000000b
	lxi	h,type$0
	jrz	XTRA
	cpi	01000000b
	jrz	ONEBYTE
	cpi	10000000b
	jrz	ONEBYTE
	lxi	h,type$3
XTRA:	ldax	d
	ani	00111111b
	add	l
	mov	l,a
	mvi	a,0
	adc	h
	mov	h,a
	mov	a,m
	ora	a
	jrz	Z80I
	jr	L1
ONEBYTE:
	mvi	a,1
L1:	mov	b,a
L2:	ldax	d
	call	hexout
	call	space
	inx	d
	djnz	L2
	lda	addr0+1
	sded	addr0
	ani	10000000b
	jrz	L4
	xra	d
	ani	10000000b
	rnz
L4:	lhld	addr1
	call	check
	rc
	lda	count
	cpi	255
	jrz	L0
	dcr	a
	sta	count
	rz
	jr	L0

Z80I:	ldax	d
	cpi	0fdh
	jrz	LX
	cpi	0ddh
	jrz	LX
	cpi	0edh
	jrz	LZ
TWOBYTE:
	mvi	a,2
	jr	L1

LZ:	inx	d
	ldax	d
	dcx	d
	ani	11000111b
	cpi	01000011b
	jrnz	TWOBYTE
FOURBY:	mvi	a,4
	jr	L1

LX:	inx	d
	ldax	d
	dcx	d
	cpi	34h
	jrz	THREEBY
	cpi	35h
	jrz	THREEBY
	cpi	21h
	jrz	FOURBY
	cpi	22h
	jrz	FOURBY
	cpi	2ah
	jrz	FOURBY
	cpi	36h
	jrz	FOURBY
	cpi	0cbh
	jrz	FOURBY
	mov	c,a
	ani	11000111b
	cpi	46h
	jrz	THREEBY
	cpi	86h
	jrz	THREEBY
	mov	a,c
	ani	11111000b
	cpi	70h
	jrnz	TWOBYTE
THREEBY:
	mvi	a,3
	jmp	L1

type$0:
	db	1,3,1,1,1,1,2,1,1,1,1,1,1,1,2,1
	db	2,3,1,1,1,1,2,1,2,1,1,1,1,1,2,1
	db	2,3,3,1,1,1,2,1,2,1,3,1,1,1,2,1
	db	2,3,3,1,1,1,2,1,2,1,3,1,1,1,2,1

type$3:
	db	1,1,3,3,3,1,2,1,1,1,3,0,3,3,2,1
	db	1,1,3,2,3,1,2,1,1,1,3,2,3,0,2,1
	db	1,1,3,1,3,1,2,1,1,1,3,1,3,0,2,1
	db	1,1,3,1,3,1,2,1,1,1,3,1,3,0,2,1

Dcomnd:		;display memory
	call	getaddr ;get address to start at
	jc	error	;error if non-hex character
	bit	7,b	;test for no address (different from 0000)
	jnz	error	;error if no address was entered
	shld	addr0	;save starting address
	call	getaddr ;get stop address
	jc	error	;error if non-hex character
	bit	7,b	;test for no entry
	jnz	error	;error if no stop address
	lded	addr0	;get start address into (DE)
dis0:	call	crlf	;start on new line
	call	taddr	;print current address
	call	space	;delimit it from data
	mvi	b,16	;display 16 bytes on each line
dis1:	ldax	d	;get byte to display
	inx	d	;step to next byte
	call	hexout	;display this byte in HEX
	call	space	;delimit it from others
	mov	a,d
	ora	e	;if we reach 0000, stop. (don't wrap around)
	jrz	dis2
	call	check	;test for past stop address
	jrc	dis2	;quit if past stop address
	djnz	dis1	;else do next byte on this line
dis2:	call	space	;delimit it from data
	call	space
	lded	addr0
	mvi	b,16	;display 16 bytes on each line
dis3:	ldax	d	;get byte to display
	inx	d	;step to next byte
	mvi	c,'.'
	cpi	' '
	jrc	dis4
	cpi	'~'+1
	jrnc	dis4
	mov	c,a
dis4:	call	conout
	mov	a,d
	ora	e	;if we reach 0000, stop. (don't wrap around)
	rz
	call	check	;test for past stop address
	rc	;quit if past stop address
	djnz	dis3	;else do next byte on this line
	sded	addr0
	jr	dis0	;when line is finished, start another

Scomnd: 		;substitute (set) memory
	call	getaddr ;get address to start substitution at
	jc	error	;error if non-hex character
	bit	7,b	;test for no entry
	jnz	error	;error if no address
	xchg		;put address in (DE)
sb1:	call	crlf	;start on new line
	call	taddr	;print address
	call	space	;and delimit it
	ldax	d	;get current value of byte
	call	hexout	;and display it
	call	space	;delimit it from user's (posible) entry
	mvi	b,0	;zero accumilator for user's entry
sb2:	call	conin	;get user's first character
	cpi	cr	;if CR then skip to next byte
	jrz	foward
	cpi	' '	;or if Space then skip to next
	jrz	foward
	cpi	'-'	;if Minus then step back to previous address
	jrz	bakwrd
	cpi	'.'	;if Period then stop substitution
	rz
	call	hexcon	;if none of the above, should be HEX digit
	jrc	error0	;error if not
	jr	sb3	;start accumilating HEX digits
sb0:	call	hexcon	;test for HEX digit
	jrc	error1	;error if not HEX
sb3:	slar	b	;roll accumilator to receive new digit
	slar	b
	slar	b
	slar	b
	ora	b	;merge in new digit
	mov	b,a
sb4:	call	conin	;get next character
	cpi	cr	;if CR then put existing byte into memory
	jrz	putbyte ;  and step to next.
	cpi	'.'
	rz
	cpi	del	;if DEL then restart at same address
	jrz	sb1
	jr	sb0	;else continue entering hex digits
putbyte:
	mov	a,b	;store accumilated byte in memory
	stax	d
foward:
	inx	d	;step to next location
	jr	sb1	;and allow substitution there

bakwrd:
	dcx	d	;move address backward one location
	jr	sb1

error0:	mvi	c,bell	;user's entry was not valid, beep and continue
	call	conout
	jr	sb2
error1:	mvi	c,bell	;same as above but for different section of routine
	call	conout
	jr	sb4

Gcomnd: 		;jump to address given by user
	call	getaddr ;get address to jump to
	jc	error	;error if non-hex character
	bit	7,b	;test for no entry
	jnz	error	;error if no address entered
	call	crlf	;on new line,
	mvi	c,'G'	;display "GO aaaa?" to ask
	call	conout	;user to verify that we should
	mvi	c,'O'	;jump to this address (in case user
	call	conout	;made a mistake we should not blindly
	call	space	;commit suicide)
	xchg
	call	taddr
	call	space
	mvi	c,'?'
	call	conout
	call	conin	;wait for user to type "Y" to
	cpi	'Y'	;indicate that we should jump.
	rnz		;abort if response was not "Y"
	xchg
	pchl		;else jump to address


*********************************************************
**  Utility subroutines
*********************************************************

taddr:	mov	a,d	;display (DE) at console in HEX
	call	hexout	;print HI byte in HEX
	mov	a,e	;now do LO byte
hexout:	push	psw	;output (A) to console in HEX
	rlc		;get HI digit in usable (LO) position
	rlc
	rlc
	rlc
	call	nible	;and display it
	pop	psw	;get LO digit back and display it
nible:	ani	00001111b	;display LO 4 bits of (A) in HEX
	adi	90h	;algorithm to convert 4-bits to ASCII
	daa
	aci	40h
	daa
	mov	c,a	;display ASCII digit
	jmp	conout

space:	mvi	c,' '	;send an ASCII blank to console
	jmp	conout

crlf:	mvi	c,cr	;send Carriage-Return/Line-Feed to console
	call	conout
	mvi	c,lf
	jmp	conout

msgout:	mov	a,m	;send string to console, terminated by 00
	ora	a
	rz
	rm
	mov	c,a
	call	conout
	inx	h
	jr	msgout

check:	push	h	;non-destuctive compare HL:DE
	ora	a
	dsbc	d
	pop	h
	ret

linein:	lxi	h,line	;get string of characters from console, ending in CR
li0:	call	conin	;get a character
	cpi	bs	;allow BackSpacing
	jrz	backup
	cpi	tab	;ignore tabs (they foul BackSpace routine)
	jrz	li0
	mov	m,a	;put character in line nuffer
	inx	h
	cpi	cr	;check for end of line
	jrz	li1	;finish up if at end of input
	mov	a,l	;else check for pending buffer overflow
	sui	line mod 256
	cpi	64
	rz		;stop if buffer full
	jr	li0	;if not full, keep getting characters

backup:	mov	a,l	;(destructive) BackSpacing
	cpi	line mod 256	;test if at beginning of line
	jrz	li0	;can't backspace past start of line
	mvi	c,bs	;output BS," ",BS to erase character on screen
	call	conout	;and put cursor back one position
	call	space
	mvi	c,bs
	call	conout
	dcx	h	;step buffer pointer back one
	jr	li0	;and continue to get characters

li1:	mvi	c,cr	;display CR so user knows we got it
	jmp	conout	;then return to calling routine

char:	mov	a,e	;remove a character from line buffer,
	sui	line mod 256	;testing for no more characters
	sui	64
	rz		;return [ZR] condition if at end of buffer
	ldax	d
	cpi	cr
	rz		;also return [ZR] if at end of line
	inx	d	;else step to next character
	ret		;and return [NZ]

getaddr:		;extract address from line buffer (dilimitted by " ")
	setb	7,b	;flag to detect no address entered
	lxi	h,0
ga2:	call	char
	rz		;end of buffer/line before a character was found
	cpi	' '	;skip all leading spaces
	jrnz	ga1	;if not space, then start getting HEX digits
	jr	ga2	;else if space, loop untill not space

ga0:	call	char
	rz
ga1:	call	hexcon	;start assembling digits into 16 bit accumilator
	jrc	chkdlm	;check if valid delimiter before returning error.
	res	7,b	;reset flag
	push	d	;save buffer pointer
	mov	e,a
	mvi	d,0
	dad	h	;shift "accumilator" left 1 digit
	dad	h
	dad	h
	dad	h
	dad	d	;add in new digit
	pop	d	;restore buffer pointer
	jr	ga0	;loop for next digit

chkdlm: cpi	' '	;blank is currently the only valid delimiter
	rz
	stc
	ret

hexcon: 		;convert ASCII character to HEX digit
	cpi	'0'	;must be .GE. "0"
	rc
	cpi	'9'+1	;and be .LE. "9"
	jrc	ok0	;valid numeral.
	cpi	'A'	;or .GE. "A"
	rc
	cpi	'F'+1	;and .LE. "F"
	cmc
	rc		;return [CY] if not valid HEX digit
	sui	'A'-'9'-1	;convert letter
ok0:	sui	'0'	;convert (numeral) to 0-15 in (A)
	ret


**********************************************************
** Physical I/O subroutines
**********************************************************

conin:	xra	a	;wait for a character from console
	out	constat ;command SIO to give status
	in	constat ;get status
	ani	00000001b	;test for character received
	jrz	conin	;loop until a byte is ready
	in	console ;get character
	ani	01111111b	;discard parity bit
	cpi	esc	;check for abort (ESC) key
	jz	cilp	;if ESC then re-start monitor
	cpi	' '	;test for Control Characters
	rc		;if Control character, don't echo
	cpi	'a'	;do Lower case to Upper case conversion
	jrc	ci0
	cpi	'z'+1
	jrnc	ci0
	sui	'a'-'A'
ci0:	push	psw	;echo character to console
	mov	c,a
	call	conout
	pop	psw
	ret

conout: xra	a	;output register (C) to console
	out	constat ;command SIO to give status
	in	constat ;get status
	bit	0,a	;check input status
	jrnz	break
	ani	00000100b	;check for Tx Buffer Empty
	jrz	conout	;loop until Empty
	mov	a,c
	out	console ;send character to SIO
	ret

break:	in	console
	ani	01111111b
	cpi	13h	;ctrl-S
	jnz	cilp
br0:	xra	a
	out	constat
	in	constat
	ani	00000001b
	jrz	br0
	in	console
	ani	01111111b
	cpi	03h	;ctrl-C
	jz	cilp
	jr	conout

AVERS	equ	(((VERS/10) and 0fh)+'0')+((VERS mod 10)+'0')*256

signon:	db	cr,lf,'MMS 77422 monitor M2001-'
	dw	AVERS
	db	0
prompt:	db	cr,lf,':',0

	rept	RAM-$
	db	0ffh
	endm
 if $ gt EPROM+EPROML
 ds 'EPROM overflow'
 endif

**********************************************************
** Varibles (RAM area)
**********************************************************

	org	RAM
	ds	128
stack:	ds	0
sioA:	ds	3	;channel reset and wr4 select.
chAwr4: ds	2	;wr4 must be programmed before 3,5,6,7
chAwr1: ds	2	;
maddr:
chAwr6: ds	2	;then 6,7 before 3,5
chAwr7: ds	2	;
chAwr5: ds	2	;
chAwr3: ds	1	;
lenA	equ	$-sioA

sioB:	ds	1
chBwr2: ds	2
chBwr4: ds	2
chBwr1: ds	2
chBwr5: ds	2
chBwr3: ds	1
lenB	equ	$-sioB

 if $ gt RAM+0E1H
ds 'error: overrun interupt vectors'
 endif
	org	RAM+0E1H	;
vector: 		;must start at 16 byte boundary and end at "FF"
TxEB:	ds	2	;transmitter B empty
ExtB:	ds	2	;external status B
RxAB:	ds	2	;receiver B character available 
SpcB:	ds	2	;special recieve condition B
TxEA:	ds	2	;transmitter A empty
ExtA:	ds	2	;external status A
RxAA:	ds	2	;receiver A character available 
SpcA:	ds	2	;special recieve condition A
	ds	2
	ds	2
	ds	2
	ds	2
	ds	2
	ds	2
	ds	2
ticker: ds	2	;tic-counter for MP/M, must be at address xxFF
numvec	equ	$-vector

ctl$image: ds	1	;image of general control output port

savstk:	ds	2

addr0:	ds	2	;temporary 16 bit storage
addr1:	ds	2	; ''
count:	ds	1
line:	ds	64	;input line buffer

spcstk:	ds	2	; saved in special recv condition intr
destin:	ds	1	;default destination of any messages
;--- Outgoing (to network) message frames --------------------------
RESmsg:	ds	3
ACKmsg:    ds	3	;DEST,CODE,SORC  (DEST is the only variable)
NAKmsg:	ds	3
BSYmsg:	ds	4
POLLmsg:	ds	3
PAKmsg:	ds	9	;printer acknowledge, CP/NET form
	ds	1
RETmsg:	ds	10	;
	ds	1

TOKEN0msg: ds	3	;DEST,CODE,SORC
net$table:
nxt$sp:    ds	1	;next server to poll
srvtbl:    ds	64	;status of all server nodes.
tk0ml	equ	$-TOKEN0msg
SEQtbl:	ds	64
;-------------------------------------------------------------------
nxsrva:	ds	2
nxsrvn:	ds	1
ntype:	ds	1	; current node type/role

nstat:	ds	1

ctime:	ds	2
ltime:	ds	1

deadct0:	ds	2
deadctr:	ds	2

eops:	ds	1	;End Of Process flags from DMA

hdrsiz	equ	7

ch2hdr:	ds	hdrsiz
stshdr:	ds	hdrsiz
rsphdr:	ds	hdrsiz
cpnhdr:	ds	hdrsiz

from89:	ds	1
outflg:	ds	1
cpnflg:	ds	1
didalt:	ds	1
stsflg:	ds	1
didsts:	ds	1
rspflg:	ds	1
didrsp:	ds	1
to89:	ds	1
dbgflg:	ds	1

ch3hda:	ds	2
ch3adr:	ds	2
ch3siz:	ds	2

pflag:	ds	1

retry:	ds	1
prtflg:	ds	1
endlst:	ds	1
retflg:	ds	1

ch2alt:	ds	2
ch2pri:	ds	2
ch2siz:	ds	2

altaddr: ds	2	;alternate address for receive from network
ch0addr: ds	2	;primary address for receive from network
ch0size: ds	2	;size of message in primary buffer

bufsiz	equ	2	;I/O buffer sizes, in pages

hstbf:	ds	bufsiz*256	;
ch2bf:	ds	bufsiz*256	;output (Z89 to network) buffer
ch3bf:	ds	bufsiz*256	;input (from network to Z89) buffer
netbf:	ds	bufsiz*256	;general network message buffer

prtpt0:	ds	2
prtpt1:	ds	2
bufmsk	equ	01111111b	;32K circular buffer
buffer: ds	0
;--------- end of SUF422.ASM ---------
	end
