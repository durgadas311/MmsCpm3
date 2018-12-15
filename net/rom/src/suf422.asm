VERS1 set 86 ; February 9, 1983  15:24	drm  "SUF422.ASM"
 if VERS1 gt VERS
VERS set VERS1
 endif

; All nodes have equal responsibility. no Server/Requestor determination.

*********************************************************
**  Debug mode
*********************************************************

debug:
	mvi	a,1
	out	cmdB
	lxi	h,chBwr1
	mov	a,m
	ani	00000100b	;all interupts,etc off
	mov	m,a
	out	cmdB
	lxi	h,signon	;display revision message
	call	msgout
cilp	lxi	sp,stack
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
	jrz	gotocmd 	;command was found, execute it
	inx	h		;step past routine address
	inx	h
	djnz	cci0		;loop untill all valid commands are checked
error	mvi	c,bell		;if command unknown, beep and re-prompt
	jmp	conout

gotocmd:
	push	d		;save command line buffer pointer
	mov	e,m		;get command routine address
	inx	h
	mov	d,m		;DE = routine address
	xchg			;HL = routine address
	pop	d		;restore buffer pointer
	pchl			;jump to command routine

** Macros to build the command code and routine address tables
ncmnds	set	0
comnds:
	irpc	XX,?DSGLMFR	  ;commands
	db	'&XX&'
	dw	XX&comnd
ncmnds	set	ncmnds+1
	endm

*********************************************************
**  Command subroutines
*********************************************************

menu:	DB	cr,lf,'D <start> <end> - display memory in HEX'
	DB	cr,lf,'S <start> - set/view memory'
	DB	cr,lf,'G <start> - go to address'
	DB	cr,lf,'L <start> <end> - list instructions'
	DB	cr,lf,'F <start> <end> <data> - fill memory'
	DB	cr,lf,'M - 64K memory test'
	db	cr,lf,'MB - test (4) 56K banks'
	DB	0

?comnd: LXI	H,menu
	JMP	msgout

Rcomnd: di
	jmp	0	;"RESET" command, restart system.

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
f0:	mov	a,c	;
	stax	d	;put byte in memory
	inx	d	;step to next byte
	mov	a,d	;
	ora	e	;if we reach 0000, stop. (don't wrap around)
	rz		;
	call	check	;test for past stop address
	rc	;quit if past stop address
	jr	f0

***************************************************
** Full Memeory Test
***************************************************
CSTAT	MACRO
	mvi	a,10h
	out	constat
	in	constat
	ani	00000100b
	jrz	$-9
	ENDM
***************************************************
LOPAGE	equ	0E0h	;RAM is tested is sections, 0000-DFFF/E000-FFFF

Mcomnd: MVI	C,lf
	CALL	conout
	mvi	l,0
mc0:	call	char
	jrz	mc1
	cpi	' '
	jz	mc0
	sui	'B'
	sui	1
	sbb	a	;0ffh if was "B"
	mov	l,a
mc1:	MVI	E,100H-LOPAGE
	MVI	D,0
	MVI	C,LOPAGE
	MVI	B,0
	EXX
	LXI	H,MEMTEST-FIXJ
	LXI	D,LOPAGE*256-FIXJ
	LXI	B,PGMLEN+FIXJ
	LDIR
	LXI	D,LOPAGE*256
	LXI	H,MEMTEST
	LXI	B,PGMLEN+100H
	XRA	A
	EXAF
	XRA	A
CS1:	ADD	M
	EXAF
	XCHG
	ADD	M
	EXAF
	XCHG
	INX	H
	INX	D
	DCR	C
	JNZ	CS1
	DJNZ	CS1
	MOV	C,A
	EXAF
	CMP	C
	JNZ	XCSERR
	DI
	exx
	mov	a,l	;flag for "banked" test
	exx
	stai
	lxix	(GREEN+B156)*256+(RED+ROMOFF)
	lxiy	(GREEN+B356)*256+(RED+B256)
	JMP	LOPAGE*256-FIXJ

XCSERR: LXI	H,CSEMSG
	JMP	MSGOUT

CSEMSG: DB	cr,lf,bell,'Checksum error!',0

;*** The following block of code must be contiguous but is otherwise
;*** relocatable.
FIXJMP: db 0DDH
	mov	a,l ;; MOV A,XL
	out	ctrl
FIXJ EQU $-FIXJMP
;*** The following block of code is check-summed to prevent bad memory from
;*** causing program crash.
MEMTEST: EXX
	MOV	H,D
	MVI	L,0
	MOV	A,B
	EXX
	MOV	C,A
	MVI	B,2
	cstat
DSP0:	MOV	A,C
	RLC
	RLC
	RLC
	RLC
	MOV	C,A
	ANI	00001111b
	ADI	90H
	DAA
	ACI	40H
	DAA
	OUT	console
	cstat
	DCR	B
	JRNZ	DSP0
	MVI	A,cr
	OUT	console
	EXX
	MOV	A,B
DMEM0:	MOV	M,A
	ADI	1
	DAA
	INR	L
	JRNZ	DMEM0
	INR	H
	DCR	C
	JRNZ	DMEM0
	MOV	A,H
	SUB	D
	MOV	C,A
	MOV	H,D
	MVI	L,0	;HL = starting address
	MOV	A,B
DMEM1:	CMP	M
	JRNZ	DYERR
	ADI	1
	DAA
	INR	L
	JRNZ	DMEM1
	INR	H
	DCR	C
	JRNZ	DMEM1
	ldai
	ora	a
	jrz	dm0
	db 0ddh
	mov	c,l	;; MOV C,XL
	db 0ddh
	mov	a,h	;; MOV A,XH
	db 0ddh
	mov	l,a	;; MOV XL,A
	db 0fdh
	mov	a,l	;; MOV A,YL
	db 0ddh
	mov	h,a	;; MOV XH,A
	db 0fdh
	mov	a,h	;; MOV A,YH
	db 0fdh
	mov	l,a	;; MOV YL,A
	db 0fdh
	mov	h,c	;; MOV YH,C
	db 0ddh
	mov	a,l	;; MOV A,XL
	out	ctrl
	mov	a,h	;re-compute number of pages to test
	sub	d
	mov	c,a
	MVI	A,1
	ADD	B
	DAA
	MOV	B,A
	EXX
	mvi	d,LOPAGE	;this only allows proper checksum verfication
	jr	dm1		;and execution address generation.
dm0:	db 0ddh
	mov	a,l
	xri	BOTH
	db 0ddh
	mov	l,a
	out	ctrl
	EXX
	LXI	H,LOPAGE*256
	LXI	D,0
	LXI	B,PGMLEN
	EXX
	MOV	A,D
	XRI	LOPAGE
	MOV	D,A
	JRZ	NEXT0
	MOV	C,E
	JR	NEXT20
NEXT0:	MVI	C,LOPAGE
	MVI	A,1
	ADD	B
	DAA
	MOV	B,A
	EXX
	XCHG
	EXX
NEXT20: EXX
	LDIR
dm1:	MOV	A,D
	ANI	11110000b
	MOV	H,A
	MVI	L,0
	LXI	B,PGMLEN+100H
	XRA	A
CS0:	ADD	M
	INX	H
	DCR	C
	JRNZ	CS0
	DJNZ	CS0
	MOV	C,A
	EXAF
	CMP	C
	JRNZ	CSERR
	EXAF
	MOV	A,D
	ANI	11110000b
	MOV	H,A
	MVI	L,0
	PCHL

DYERR:	XRA	M
	MOV	D,A
	cstat
	MVI	A,lf
	OUT	console
	cstat
	db 0ddh
	mov	a,l
	ani	111b
	ori	'0'
	OUT	console
	cstat
	MVI	A,'*'
	OUT	console
	MVI	B,2
DE1:	cstat
	MOV	A,D
	RLC
	RLC
	RLC
	RLC
	MOV	D,A
	ANI	00001111b
	ADI	90H
	DAA
	ACI	40H
	DAA
	OUT	console
	DJNZ	DE1
	JR	DEAD

CSERR:	cstat
	MVI	A,lf
	OUT	console
	cstat
	MVI	A,'!'
	OUT	console
DEAD:	XRA	A
	MVI	B,0
DEAD0:	DCR	A
	JRNZ	DEAD0
DEAD1:	DCR	A
	JRNZ	DEAD1
	DJNZ	DEAD0
	MVI	A,bell
	OUT	console
	JR	DEAD
PGMLEN EQU $-MEMTEST
;***************************************************************************
;*** End of block of code.


Lcomnd: CALL	getaddr
	JC	error
	BIT	7,B
	JZ	L5
	LHLD	ADDR0
L5:	SHLD	ADDR0
	MVI	A,255
	STA	COUNT
	CALL	GETADDR
	JC	ERROR
	BIT	7,B
	JZ	L3
	MVI	A,16
	STA	COUNT
	LHLD	ADDR0
	LXI	D,16*4
	DAD	D
L3:	SHLD	ADDR1
	LDED	ADDR0
L0:	SDED	ADDR0
	CALL	CRLF
	CALL	TADDR
	CALL	SPACE
	LDAX	D
	ANI	11000000B
	LXI	H,type$0
	JRZ	XTRA
	CPI	01000000b
	JRZ	ONEBYTE
	CPI	10000000b
	JRZ	ONEBYTE
	LXI	H,type$3
XTRA:	LDAX	D
	ANI	00111111B
	ADD	L
	MOV	L,A
	MVI	A,0
	ADC	H
	MOV	H,A
	MOV	A,M
	ORA	A
	JRZ	Z80I
	JR	L1
ONEBYTE:
	MVI	A,1
L1:	MOV	B,A
L2:	LDAX	D
	CALL	HEXOUT
	CALL	SPACE
	INX	D
	DJNZ	L2
	LDA	ADDR0+1
	ANI	10000000B
	JRZ	L4
	XRA	D
	ANI	10000000B
	RNZ
L4:	LHLD	ADDR1
	CALL	CHECK
	RC
	LDA	COUNT
	CPI	255
	JRZ	L0
	DCR	A
	STA	COUNT
	RZ
	JR	L0

Z80I:	LDAX	D
	CPI	0FDH
	JRZ	LX
	CPI	0DDH
	JRZ	LX
	CPI	0EDH
	JRZ	LZ
TWOBYTE:
	MVI	A,2
	JR	L1

LZ:	INX	D
	LDAX	D
	DCX	D
	ANI	11000111B
	CPI	01000011b
	JRNZ	TWOBYTE
FOURBY: MVI	A,4
	JR	L1

LX:	INX	D
	LDAX	D
	DCX	D
	CPI	34H
	JRZ	THREEBY
	CPI	35H
	JRZ	THREEBY
	CPI	21H
	JRZ	FOURBY
	CPI	22H
	JRZ	FOURBY
	CPI	2AH
	JRZ	FOURBY
	CPI	36H
	JRZ	FOURBY
	CPI	0CBH
	JRZ	FOURBY
	MOV	C,A
	ANI	11000111B
	CPI	46H
	JRZ	THREEBY
	CPI	86H
	JRZ	THREEBY
	MOV	A,C
	ANI	11111000B
	CPI	70H
	JRNZ	TWOBYTE
THREEBY:
	MVI	A,3
	JR	L1

type$0:
	DB	1,3,1,1,1,1,2,1,1,1,1,1,1,1,2,1
	DB	2,3,1,1,1,1,2,1,2,1,1,1,1,1,2,1
	DB	2,3,3,1,1,1,2,1,2,1,3,1,1,1,2,1
	DB	2,3,3,1,1,1,2,1,2,1,3,1,1,1,2,1

type$3:
	DB	1,1,3,3,3,1,2,1,1,1,3,0,3,3,2,1
	DB	1,1,3,2,3,1,2,1,1,1,3,2,3,0,2,1
	DB	1,1,3,1,3,1,2,1,1,1,3,1,3,0,2,1
	DB	1,1,3,1,3,1,2,1,1,1,3,1,3,0,2,1


Dcomnd: 	;display memory
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
dis0	call	crlf	;start on new line
	call	taddr	;print current address
	call	space	;delimit it from data
	mvi	b,16	;display 16 bytes on each line
dis1	ldax	d	;get byte to display
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
dis3	ldax	d	;get byte to display
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
sb1	call	crlf	;start on new line
	call	taddr	;print address
	call	space	;and delimit it
	ldax	d	;get current value of byte
	call	hexout	;and display it
	call	space	;delimit it from user's (posible) entry
	mvi	b,0	;zero accumilator for user's entry
sb2	call	conin	;get user's first character
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
sb0	call	hexcon	;test for HEX digit
	jrc	error1	;error if not HEX
sb3	slar	b	;roll accumilator to receive new digit
	slar	b
	slar	b
	slar	b
	ora	b	;merge in new digit
	mov	b,a
sb4	call	conin	;get next character
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

error0	mvi	c,bell	;user's entry was not valid, beep and continue
	call	conout
	jr	sb2
error1	mvi	c,bell	;same as above but for different section of routine
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
hexout	push	psw	;output (A) to console in HEX
	rlc		;get HI digit in usable (LO) position
	rlc
	rlc
	rlc
	call	nible	;and display it
	pop	psw	;get LO digit back and display it
nible	ani	00001111b	;display LO 4 bits of (A) in HEX
	adi	90h	;algorithm to convert 4-bits to ASCII
	daa
	aci	40h
	daa
	mov	c,a	;display ASCII digit
	jmp	conout

space	mvi	c,' '	;send an ASCII blank to console
	jmp	conout

crlf	mvi	c,cr	;send Carriage-Return/Line-Feed to console
	call	conout
	mvi	c,lf
	jmp	conout

msgout	mov	a,m	;send string to console, terminated by 00
	ora	a
	rz
	mov	c,a
	call	conout
	inx	h
	jr	msgout

check	push	h	;non-destuctive compare HL:DE
	ora	a
	dsbc	d
	pop	h
	ret

linein	lxi	h,line	;get string of characters from console, ending in CR
li0	call	conin	;get a character
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

backup	mov	a,l	;(destructive) BackSpacing
	cpi	line mod 256	;test if at beginning of line
	jrz	li0	;can't backspace past start of line
	mvi	c,bs	;output BS," ",BS to erase character on screen
	call	conout	;and put cursor back one position
	call	space
	mvi	c,bs
	call	conout
	dcx	h	;step buffer pointer back one
	jr	li0	;and continue to get characters

li1	mvi	c,cr	;display CR so user knows we got it
	jmp	conout	;then return to calling routine

char	mov	a,e	;remove a character from line buffer,
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
ga2	call	char
	rz		;end of buffer/line before a character was found
	cpi	' '	;skip all leading spaces
	jrnz	ga1	;if not space, then start getting HEX digits
	jr	ga2	;else if space, loop untill not space

ga0	call	char
	rz
ga1	call	hexcon	;start assembling digits into 16 bit accumilator
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
ok0	sui	'0'	;convert (numeral) to 0-15 in (A)
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

signon: db	cr,lf,'MMS Z80 monitor v-6.'
	dw	AVERS
	db	' (for 77422)',0
prompt: db	cr,lf,':',0

 if $ gt EPROM+EPROML
 ds 'EPROM overflow'
 endif

**********************************************************
** Varibles (RAM area)
**********************************************************

	org	RAM	;use area at start of RAM for general buffers
	ds	128	
stack:	ds	0

sftvec:
VRST1:	ds	3
VRST2:	ds	3
VRST3:	ds	3
VRST4:	ds	3
VRST5:	ds	3
VRST6:	ds	3
VRST7:	ds	3
VNMI:	ds	3
numsft	equ	$-sftvec

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

addr0:	ds	2	;temporary 16 bit storage
addr1:	ds	2	; ''
count:	ds	1
line:	ds	64	;input line buffer

destin: ds	1	;default destination of any messages
;--- Outgoing (to network) message frames --------------------------
RESmsg:    ds	3
ACKmsg:    ds	3	;DEST,CODE,SORC  (DEST is the only variable)
NAKmsg:    ds	3
BSYmsg:    ds	4
POLLmsg:   ds	3
PAKmsg:    ds	9	;printer acknowledge, CP/NET form
RETmsg:    ds	10	;

TOKEN0msg: ds	3	;DEST,CODE,SORC
net$table:
nxt$sp:    ds	1	;next server to poll
srvtbl:    ds	64	;status of all server nodes.
tk0ml	equ	$-TOKEN0msg
;-------------------------------------------------------------------
nxsrva: ds	2
nxsrvn: ds	1

nstat:	ds	1

ctime:	ds	2
ltime:	ds	1

deadct0: ds	2
deadctr: ds	2

eops:	ds	1	;End Of Process flags from DMA

hdrsiz	equ	7

ch2hdr: ds	hdrsiz
stshdr: ds	hdrsiz
rsphdr: ds	hdrsiz
cpnhdr: ds	hdrsiz

z89flg: ds	1
ch2flg: ds	1
outflg: ds	1
cpnflg: ds	1
cp89:	ds	1
STSflg: ds	1
RSPflg: ds	1
ch3flg: ds	1

ch3hda: ds	2
ch3adr: ds	2
ch3siz: ds	2

pflag:	ds	1

retry:	ds	1
prtflg: ds	1
endlst: ds	1
retflg: ds	1

ch2alt: ds	2
ch2pri: ds	2
ch2siz: ds	2

altaddr: ds	2	;alternate address for receive from network
ch0addr: ds	2	;primary address for receive from network
ch0size: ds	2	;size of message in primary buffer

bufsiz	equ	2	;I/O buffer sizes, in pages

hstbf:	ds	bufsiz*256	;
ch2bf:	ds	bufsiz*256	;output (Z89 to network) buffer
ch3bf:	ds	bufsiz*256	;input (from network to Z89) buffer
netbf:	ds	bufsiz*256	;general network message buffer

prtpt0: ds	2
prtpt1: ds	2
bufmsk	equ	01111111b	;32K circular buffer
buffer: ds	0
;--------- end of SUF422.ASM ---------
	end
