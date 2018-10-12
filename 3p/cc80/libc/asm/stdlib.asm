;C/80 Compiler 3@1 (4/11/84) - (c) 1984 The Software Toolworks


	PUBLIC	rename
	CSEG

rename:	LXI	H,-54
	DAD	SP
	SPHL
	LXI	H,56
	DAD	SP
	CALL	h@
	EXTRN	h@
	PUSH	H
	LXI	H,2
	DAD	SP
	LXI	D,16
	DAD	D
	PUSH	H
	CALL	makfcb
	POP	B
	POP	B
	LXI	H,58
	DAD	SP
	CALL	h@
	EXTRN	h@
	PUSH	H
	LXI	H,2
	DAD	SP
	PUSH	H
	CALL	makfcb
	POP	B
	POP	B
	LXI	H,26
	PUSH	H
	LXI	H,128
	PUSH	H
	CALL	bdos
	POP	B
	POP	B
	LXI	H,23
	PUSH	H
	LXI	H,2
	DAD	SP
	PUSH	H
	CALL	bdos
	POP	B
	POP	B
@d:	XCHG
	LXI	H,54
	DAD	SP
	SPHL
	XCHG
	RET

	PUBLIC	unlink

unlink:	LXI	H,-36
	DAD	SP
	SPHL
	LXI	H,38
	DAD	SP
	CALL	h@
	EXTRN	h@
	PUSH	H
	LXI	H,2
	DAD	SP
	PUSH	H
	CALL	makfcb
	POP	B
	POP	B
	LXI	H,26
	PUSH	H
	LXI	H,128
	PUSH	H
	CALL	bdos
	POP	B
	POP	B
	LXI	H,19
	PUSH	H
	LXI	H,2
	DAD	SP
	PUSH	H
	CALL	bdos
	POP	B
	POP	B
@e:	LXI	H,36
	DAD	SP
	SPHL
	RET

	PUBLIC	abs

abs:	LXI	H,2
	DAD	SP
	CALL	h@
	EXTRN	h@
	LXI	D,0
	CALL	c@gt
	EXTRN	c@gt
	JZ	@f
	LXI	H,2
	DAD	SP
	CALL	h@
	EXTRN	h@
	CALL	c@neg
	EXTRN	c@neg
	JMP	@g
@f:	LXI	H,2
	DAD	SP
	CALL	h@
	EXTRN	h@
@g:	RET
@h:	DW	0,-1

	PUBLIC	alloc
	DSEG
@i:	DW	0
@j:	DW	0
@k:	DW	0
	CSEG

alloc:	LXI	H,2
	DAD	SP
	PUSH	H
	CALL	h@
	EXTRN	h@
	INX	H
	INX	H
	CALL	q@
	EXTRN	q@
	LXI	D,4
	CALL	c@ugt
	EXTRN	c@ugt
	JZ	@l
	LXI	H,2
	DAD	SP
	MVI	M,4
	INX	H
	MVI	M,0
@l:	DS	0
@o:	LXI	H,@h
	SHLD	@i
@r:	LHLD	@i
	INX	H
	INX	H
	CALL	h@
	EXTRN	h@
	SHLD	@j
	INX	H
	CALL	e@0
	EXTRN	e@0
	JZ	@q
	JMP	@s
@p:	LHLD	@j
	SHLD	@i
	JMP	@r
@s:	LHLD	@j
	CALL	h@
	EXTRN	h@
	PUSH	H
	LXI	H,4
	DAD	SP
	CALL	h@
	EXTRN	h@
	POP	D
	CALL	c@uge
	EXTRN	c@uge
	JZ	@t
	LXI	H,2
	DAD	SP
	CALL	h@
	EXTRN	h@
	LXI	D,4
	DAD	D
	PUSH	H
	LHLD	@j
	CALL	h@
	EXTRN	h@
	POP	D
	CALL	c@ule
	EXTRN	c@ule
	JZ	@u
	LHLD	@i
	INX	H
	INX	H
	PUSH	H
	LHLD	@j
	XCHG
	LXI	H,4
	DAD	SP
	CALL	h@
	EXTRN	h@
	DAD	D
	CALL	q@
	EXTRN	q@
	SHLD	@i
	LHLD	@i
	PUSH	H
	LHLD	@j
	CALL	h@
	EXTRN	h@
	PUSH	H
	LXI	H,6
	DAD	SP
	CALL	h@
	EXTRN	h@
	CALL	s@
	EXTRN	s@
	CALL	q@
	EXTRN	q@
	LHLD	@j
	PUSH	H
	LXI	H,4
	DAD	SP
	CALL	h@
	EXTRN	h@
	CALL	q@
	EXTRN	q@
@u:	LHLD	@i
	INX	H
	INX	H
	PUSH	H
	LHLD	@j
	INX	H
	INX	H
	CALL	h@
	EXTRN	h@
	CALL	q@
	EXTRN	q@
	LHLD	@j
	INX	H
	INX	H
	RET
@t:	JMP	@p
@q:	LXI	H,2
	DAD	SP
	CALL	h@
	EXTRN	h@
	LXI	D,1024
	CALL	c@ugt
	EXTRN	c@ugt
	JZ	@w
	LXI	H,1024
	JMP	@x
@w:	LXI	H,2
	DAD	SP
	CALL	h@
	EXTRN	h@
@x:	SHLD	@k
	PUSH	H
	CALL	sbrk
	POP	B
	SHLD	@i
	INX	H
	CALL	c@not
	EXTRN	c@not
	JZ	@v
	LXI	H,-1
	RET
@v:	LHLD	@i
	PUSH	H
	LHLD	@k
	CALL	q@
	EXTRN	q@
	LHLD	@i
	INX	H
	INX	H
	PUSH	H
	CALL	free
	POP	B
	JMP	@o
@n:	RET

	PUBLIC	free
	DSEG
@y:	DW	0
@z:	DW	0
	CSEG

free:	LXI	H,2
	DAD	SP
	PUSH	H
	CALL	h@
	EXTRN	h@
	DCX	H
	DCX	H
	CALL	q@
	EXTRN	q@
	LXI	H,@h
	SHLD	@y
@cb:	LHLD	@y
	INX	H
	MOV	A,H
	ORA	L
	JZ	@bb
	JMP	@db
@ab:	LHLD	@z
	SHLD	@y
	JMP	@cb
@db:	LHLD	@y
	INX	H
	INX	H
	CALL	h@
	EXTRN	h@
	SHLD	@z
	PUSH	H
	LXI	H,4
	DAD	SP
	CALL	h@
	EXTRN	h@
	POP	D
	CALL	c@ugt
	EXTRN	c@ugt
	JZ	@eb
	LXI	H,2
	DAD	SP
	CALL	h@
	EXTRN	h@
	CALL	h@
	EXTRN	h@
	XCHG
	LXI	H,2
	DAD	SP
	CALL	h@
	EXTRN	h@
	DAD	D
	PUSH	H
	LHLD	@z
	CALL	e@
	EXTRN	e@
	JZ	@fb
	LXI	H,2
	DAD	SP
	CALL	h@
	EXTRN	h@
	PUSH	H
	CALL	h@
	EXTRN	h@
	PUSH	H
	LHLD	@z
	CALL	h@
	EXTRN	h@
	POP	D
	DAD	D
	CALL	q@
	EXTRN	q@
	LHLD	@z
	INX	H
	INX	H
	CALL	h@
	EXTRN	h@
	SHLD	@z
@fb:	LHLD	@y
	CALL	h@
	EXTRN	h@
	XCHG
	LHLD	@y
	DAD	D
	PUSH	H
	LXI	H,4
	DAD	SP
	CALL	h@
	EXTRN	h@
	CALL	e@
	EXTRN	e@
	JZ	@gb
	LHLD	@y
	PUSH	H
	CALL	h@
	EXTRN	h@
	PUSH	H
	LXI	H,6
	DAD	SP
	CALL	h@
	EXTRN	h@
	CALL	h@
	EXTRN	h@
	POP	D
	DAD	D
	CALL	q@
	EXTRN	q@
	LXI	H,2
	DAD	SP
	PUSH	H
	LHLD	@y
	CALL	q@
	EXTRN	q@
@gb:	LHLD	@y
	INX	H
	INX	H
	PUSH	H
	LXI	H,4
	DAD	SP
	CALL	h@
	EXTRN	h@
	CALL	q@
	EXTRN	q@
	LXI	H,2
	DAD	SP
	CALL	h@
	EXTRN	h@
	INX	H
	INX	H
	PUSH	H
	LHLD	@z
	CALL	q@
	EXTRN	q@
	RET
@eb:	JMP	@ab
@bb:	RET

	PUBLIC	atoi
	DSEG
@hb:	DW	0
@ib:	DW	0
	CSEG

atoi:	LXI	H,1
	SHLD	@ib
	LXI	H,0
	SHLD	@hb
	LXI	H,2
	DAD	SP
	CALL	h@
	EXTRN	h@
	MOV	L,M
	MVI	H,0
	JMP	@kb
@lb:	LXI	H,-1
	SHLD	@ib
@mb:	LXI	H,2
	DAD	SP
	PUSH	H
	CALL	h@
	EXTRN	h@
	INX	H
	CALL	q@
	EXTRN	q@
	JMP	@jb
@kb:	CALL	@switch
	EXTRN	@switch
	DW	@lb,45
	DW	@mb,43
	DW	0
@jb:	DS	0
@nb:	LXI	H,2
	DAD	SP
	CALL	h@
	EXTRN	h@
	MOV	L,M
	MVI	H,0
	LXI	D,48
	CALL	c@le
	EXTRN	c@le
	JZ	@pb
	LXI	H,2
	DAD	SP
	CALL	h@
	EXTRN	h@
	MOV	L,M
	MVI	H,0
	LXI	D,57
	CALL	c@ge
	EXTRN	c@ge
@pb:	CALL	e@0
	EXTRN	e@0
	JZ	@ob
	LHLD	@hb
	LXI	D,10
	CALL	c@mult
	EXTRN	c@mult
	PUSH	H
	LXI	H,4
	DAD	SP
	PUSH	H
	CALL	h@
	EXTRN	h@
	INX	H
	CALL	q@
	EXTRN	q@
	DCX	H
	MOV	L,M
	MVI	H,0
	POP	D
	DAD	D
	LXI	D,-48
	DAD	D
	SHLD	@hb
	JMP	@nb
@ob:	LHLD	@ib
	XCHG
	LHLD	@hb
	CALL	c@mult
	EXTRN	c@mult
	RET

	PUBLIC	bdos

bdos:	DS	0
;#asm
	extrn bdose
	POP H
	POP D		; Get arguments into d
	POP B		; and b.
	PUSH B		; Restore stack.
	PUSH D
	PUSH H
	CALL bdose	; Call BDOS.
			; Return value from HL.
;#endasm
	RET

	PUBLIC	getline
	DSEG
@qb:	DW	0
	CSEG

getline:	LXI	H,4
	DAD	SP
	CALL	h@
	EXTRN	h@
	SHLD	@qb
@tb:	LXI	H,2
	DAD	SP
	PUSH	H
	CALL	h@
	EXTRN	h@
	DCX	H
	CALL	q@
	EXTRN	q@
	LXI	D,0
	CALL	c@lt
	EXTRN	c@lt
	JZ	@ub
	LHLD	@qb
	PUSH	H
	CALL	getchar
	POP	D
	MOV	A,L
	STAX	D
	LXI	D,-10
	DAD	D
	CALL	e@0
	EXTRN	e@0
@ub:	CALL	e@0
	EXTRN	e@0
	JZ	@vb
	LHLD	@qb
	MOV	L,M
	MVI	H,0
	INX	H
	CALL	e@0
	EXTRN	e@0
@vb:	CALL	e@0
	EXTRN	e@0
	JZ	@sb
	JMP	@wb
@rb:	LHLD	@qb
	INX	H
	SHLD	@qb
	JMP	@tb
@wb:	JMP	@rb
@sb:	LHLD	@qb
	MVI	M,0
	LHLD	@qb
	PUSH	H
	LXI	H,6
	DAD	SP
	CALL	h@
	EXTRN	h@
	CALL	s@
	EXTRN	s@
	RET

	PUBLIC	index
	DSEG
@xb:	DW	0
@yb:	DW	0
@zb:	DW	0
	CSEG

index:	LXI	H,0
	SHLD	@xb
@cc:	LXI	H,4
	DAD	SP
	CALL	h@
	EXTRN	h@
	XCHG
	LHLD	@xb
	DAD	D
	MOV	L,M
	MVI	H,0
	MOV	A,H
	ORA	L
	JZ	@bc
	JMP	@dc
@ac:	LHLD	@xb
	INX	H
	SHLD	@xb
	DCX	H
	JMP	@cc
@dc:	LHLD	@xb
	SHLD	@yb
	LXI	H,0
	SHLD	@zb
@gc:	LXI	H,2
	DAD	SP
	CALL	h@
	EXTRN	h@
	XCHG
	LHLD	@zb
	DAD	D
	MOV	L,M
	MVI	H,0
	CALL	e@0
	EXTRN	e@0
	JZ	@hc
	LXI	H,4
	DAD	SP
	CALL	h@
	EXTRN	h@
	XCHG
	LHLD	@yb
	DAD	D
	MOV	L,M
	MVI	H,0
	PUSH	H
	LXI	H,4
	DAD	SP
	CALL	h@
	EXTRN	h@
	XCHG
	LHLD	@zb
	DAD	D
	MOV	L,M
	MVI	H,0
	CALL	e@
	EXTRN	e@
@hc:	CALL	e@0
	EXTRN	e@0
	JZ	@fc
	JMP	@ic
@ec:	LHLD	@yb
	INX	H
	SHLD	@yb
	LHLD	@zb
	INX	H
	SHLD	@zb
	JMP	@gc
@ic:	JMP	@ec
@fc:	LXI	H,2
	DAD	SP
	CALL	h@
	EXTRN	h@
	XCHG
	LHLD	@zb
	DAD	D
	MOV	L,M
	MVI	H,0
	MOV	A,H
	ORA	L
	JNZ	@jc
	LHLD	@xb
	RET
@jc:	JMP	@ac
@bc:	LXI	H,-1
	RET

	PUBLIC	isalpha

isalpha:	DS	0
;#asm
	LXI H,2
	DAD SP
	MOV A,M
	LXI H,0
	CPI 'A'
	RC
	CPI 'z'+1
	RNC
	INR L
	CPI 'a'
	RNC
	CPI 'Z'+1
	RC
	DCR L
;#endasm
	RET

	PUBLIC	isdigit

isdigit:	DS	0
;#asm
	LXI H,2
	DAD SP
	MOV A,M
	LXI H,0
	CPI '0'
	RC
	CPI '9'+1
	RNC
	INR L
;#endasm
	RET

	PUBLIC	islower

islower:	DS	0
;#asm
	LXI H,2
	DAD SP
	MOV A,M
	LXI H,0
	CPI 'a'
	RC
	CPI 'z'+1
	RNC
	INR L
;#endasm
	RET

	PUBLIC	isspace

isspace:	LXI	H,2
	DAD	SP
	CALL	h@
	EXTRN	h@
	JMP	@lc
@mc:	DS	0
@nc:	DS	0
@oc:	LXI	H,1
	RET
	JMP	@kc
@lc:	CALL	@switch
	EXTRN	@switch
	DW	@mc,32
	DW	@nc,9
	DW	@oc,10
	DW	0
@kc:	LXI	H,0
	RET

	PUBLIC	isupper

isupper:	DS	0
;#asm
	LXI H,2
	DAD SP
	MOV A,M
	LXI H,0
	CPI 'A'
	RC
	CPI 'Z'+1
	RNC
	INR L
;#endasm
	RET

	PUBLIC	itoa
	DSEG
@pc:	DW	0
@qc:	DW	0
@rc:	DW	0
@sc:	DW	0
	CSEG

itoa:	LXI	H,4
	DAD	SP
	CALL	h@
	EXTRN	h@
	SHLD	@qc
	LXI	D,0
	CALL	c@gt
	EXTRN	c@gt
	JZ	@tc
	LHLD	@qc
	CALL	c@neg
	EXTRN	c@neg
	SHLD	@qc
@tc:	LXI	H,2
	DAD	SP
	CALL	h@
	EXTRN	h@
	SHLD	@rc
	SHLD	@sc
@wc:	LHLD	@rc
	INX	H
	SHLD	@rc
	DCX	H
	PUSH	H
	LHLD	@qc
	XCHG
	LXI	H,10
	CALL	c@div
	EXTRN	c@div
	XCHG
	LXI	D,48
	DAD	D
	POP	D
	MOV	A,L
	STAX	D
@uc:	LHLD	@qc
	XCHG
	LXI	H,10
	CALL	c@div
	EXTRN	c@div
	SHLD	@qc
	MOV	A,H
	ORA	L
	JNZ	@wc
@vc:	LXI	H,4
	DAD	SP
	CALL	h@
	EXTRN	h@
	LXI	D,32768
	CALL	c@tst
	EXTRN	c@tst
	JC	@xc
	LHLD	@rc
	INX	H
	SHLD	@rc
	DCX	H
	MVI	M,45
@xc:	LHLD	@rc
	MVI	M,0
@yc:	LHLD	@rc
	DCX	H
	SHLD	@rc
	XCHG
	LHLD	@sc
	CALL	c@ugt
	EXTRN	c@ugt
	JZ	@zc
	LHLD	@sc
	MOV	L,M
	MVI	H,0
	SHLD	@pc
	LHLD	@sc
	INX	H
	SHLD	@sc
	DCX	H
	PUSH	H
	LHLD	@rc
	MOV	L,M
	MVI	H,0
	POP	D
	MOV	A,L
	STAX	D
	LHLD	@rc
	PUSH	H
	LHLD	@pc
	POP	D
	MOV	A,L
	STAX	D
	JMP	@yc
@zc:	LXI	H,2
	DAD	SP
	CALL	h@
	EXTRN	h@
	RET

	PUBLIC	makfcb

makfcb:	DS	0
;#asm
	POP B
	POP H
	POP D
	PUSH D
	PUSH H
	PUSH B
;#endasm
	CALL	x0fcb
	RET

	PUBLIC	max

max:	LXI	H,4
	DAD	SP
	CALL	h@
	EXTRN	h@
	PUSH	H
	LXI	H,4
	DAD	SP
	CALL	h@
	EXTRN	h@
	POP	D
	CALL	c@gt
	EXTRN	c@gt
	JZ	@ad
	LXI	H,4
	DAD	SP
	CALL	h@
	EXTRN	h@
	JMP	@bd
@ad:	LXI	H,2
	DAD	SP
	CALL	h@
	EXTRN	h@
@bd:	RET

	PUBLIC	min

min:	LXI	H,4
	DAD	SP
	CALL	h@
	EXTRN	h@
	PUSH	H
	LXI	H,4
	DAD	SP
	CALL	h@
	EXTRN	h@
	POP	D
	CALL	c@lt
	EXTRN	c@lt
	JZ	@cd
	LXI	H,4
	DAD	SP
	CALL	h@
	EXTRN	h@
	JMP	@dd
@cd:	LXI	H,2
	DAD	SP
	CALL	h@
	EXTRN	h@
@dd:	RET

	PUBLIC	strcat

strcat:	DS	0
@ed:	LXI	H,4
	DAD	SP
	CALL	h@
	EXTRN	h@
	MOV	A,M
	ORA	A
	JZ	@fd
	LXI	H,4
	DAD	SP
	PUSH	H
	CALL	h@
	EXTRN	h@
	INX	H
	CALL	q@
	EXTRN	q@
	JMP	@ed
@fd:	DS	0
@gd:	LXI	H,4
	DAD	SP
	PUSH	H
	CALL	h@
	EXTRN	h@
	INX	H
	CALL	q@
	EXTRN	q@
	DCX	H
	PUSH	H
	LXI	H,4
	DAD	SP
	PUSH	H
	CALL	h@
	EXTRN	h@
	INX	H
	CALL	q@
	EXTRN	q@
	DCX	H
	MOV	L,M
	MVI	H,0
	POP	D
	MOV	A,L
	STAX	D
	MOV	A,H
	ORA	L
	JZ	@hd
	JMP	@gd
@hd:	RET

	PUBLIC	strcmp

strcmp:	DS	0
;#asm
	POP	B	; return address
	POP	H	; get first string (str2)
	POP	D	; get second string (str1)
	PUSH	D	; restore stack for caller
	PUSH	H
	PUSH	B
SCLOOP: LDAX	D	; get next byte from second string
	CMP	M	; compare that with first string
	JNZ	SCDIFF	; they didn't compare
	INX	D	; increment both pointers
	INX	H
	ORA	A	; both the same.  see if both zero
	JNZ	SCLOOP	; nope.  get the next ones
	LXI	H,0	; yup.	they matched all the way to the null
	JMP	SCRET	; unified return for timing
SCDIFF: LXI	H,-1	;
	JC	SCRET	; first string < second string
	LXI	H,1	; first string > second string
SCRET:	DS	0	; unified return
;#endasm
	RET

	PUBLIC	strcpy

strcpy:	DS	0
;#asm
	POP	B	; return address
	POP	H	; get from arg
	POP	D	; get to arg
	PUSH	D	; restore stack for caller
	PUSH	H
	PUSH	B
	DCX	H	; back off for a running start
STLOOP: INX	H	; point at next FROM char
	MOV	A,M	; put it into accumulator
	STAX	D	; store it in TO string
	INX	D	; increment TO string
	ORA	A	; check for last char
	JNZ	STLOOP	; copied the 0 byte.  Go away.
;#endasm
	RET

	PUBLIC	strlen

strlen:	DS	0
;#asm
	POP	B	; return address
	POP	D	; the string
	PUSH	D	; restore stack
	PUSH	B
	LXI	H,0	; initialize length
SLLOOP: LDAX	D	; get next char
	ORA	A	; test for zero
	JZ	SLDONE	; end of string
	INX	D	; point at next character
	INX	H	; increment counter
	JMP	SLLOOP	; and around again
SLDONE: DS	0	; fall through for timer
;#endasm
	RET

	PUBLIC	tolower

tolower:	DS	0
;#asm
	LXI H,2
	DAD SP
	MOV L,M
	MVI H,0
	MOV A,L
	CPI 'A'
	RC
	CPI 'Z'+1
	RNC
	XRI 20H
	MOV L,A
;#endasm
	RET

	PUBLIC	toupper

toupper:	DS	0
;#asm
	LXI H,2
	DAD SP
	MOV L,M
	MVI H,0
	MOV A,L
	CPI 'a'
	RC
	CPI 'z'+1
	RNC
	XRI 20H
	MOV L,A
;#endasm
	RET
	EXTRN	sbrk
	EXTRN	getchar
	EXTRN	x0fcb
	EXTRN	g@
	END
