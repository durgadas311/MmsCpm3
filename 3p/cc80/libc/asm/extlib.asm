* Floating point library; C/80 3.0 (7/7/83) - (c) 1983 Walter Bilofsky
* Rev. for DRI ASM's 5-2-85 drm

	public atof,Bf@Bl,Bf@Hc,Bf@Hi,Bf@Hu,Bl@Bf,Bl@Hc,Bl@Hi,Bl@Hu
	public C@1632,C@3216,C@@F,C@@L,cf@eq,cf@fls,cf@ge,cf@gt,cf@le
	public cf@lt,cf@ne,cf@tru,cf@zro,cl@ge,cl@glt,cl@gt,cl@le,cl@lt
	public comp@4,div10@,eq@4,F@@C,F@@I,F@@L,F@@U,f@add,f@div,f@mul
	public f@neg,f@not,f@round,f@sub,fadd@,fadda@,fcomp@,fint@
	public flneg@,float@,flt@0,foutt@,ftoa,Hc@Bf,Hc@Bl,her@32,Hi@Bf
	public Hi@Bl,Hu@Bf,Hu@Bl,I@@F,I@@L,inxhr@,L@@C,L@@F,L@@I,L@@U
	public L@add,L@and,L@asl,L@asr,L@com,L@div,L@mod,L@mul,L@neg
	public L@not,L@or,L@sub,L@xor,llong@,lneq@4,long@0,movfm@,movfr@
	public movmf@,movrf@,movrm@,mul10@,neq@4,pushf@,qint@,sign@
	public slong@,st4@,swap4@,swaps@,U@@F,U@@L,zero@

	extrn c@sxt,h@,g@

facl?:	DB	0
facl?1: DB	0
facl?2: DB	0
fac?:	DB	0
fac?1:	DB	0
save?:	DB	0
fmlt?1: DB	0
fmlt?2: DB	0
dum?:	DB	0
save?1: DB	0
errcod: DB	0
fdiv?a: DB	0
fdiv?b: DB	0
fdiv?c: DB	0
fdiv?g: DB	0
flt?pk: DS	0
F@add:	XRA	A
	JMP	Dual
F@sub:	MVI	A,1
	JMP	Dual
F@mul:	MVI	A,2
	JMP	Dual
F@div:	MVI	A,3
Dual:	CALL	movfr@
	POP	H
	POP	D
	POP	B
	PUSH	H
	LXI	H,movrf@
	PUSH	H
	LXI	H,Ftab
Fexecl: ORA	A
	JZ	Fexec
	DCR	A
	INX	H
	INX	H
	JMP	Fexecl
Fexec:	MOV	A,M
	INX	H
	MOV	H,M
	MOV	L,A
	PCHL
Ftab:	DW	fadd@
	DW	fsub
	DW	fmult
	DW	fdiv
F@neg:	MOV	A,C
	XRI	80H
	MOV	C,A
	RET
cf@le:	CALL	relopf
	JP	ftrue
ffalse: DCR	L
	RET
cf@lt:	CALL	relopf
	DCR	A
	JNZ	ffalse
ftrue:	INR	A
	RET
cf@ge:	CALL	relopf
	DCR	A
	RM
	DCR	L
	RET
cf@gt:	CALL	relopf
	RM
	DCR	L
	RET
relopf:
	CALL	movfr@
	POP	B
	POP	H
	POP	D
	XTHL
	PUSH	B
	MOV	B,H
	MOV	C,L
	CALL	fcomp@
	LXI	H,1
	ORA	A
	RET
cf@eq:	CALL	cf@zro
	JNC	eq@4
	JZ	cf@tru
cf@fls: DCR	E
cf@tru: POP	H
	POP	B
	XTHL
	XCHG
	DCR	L
	RET
cf@ne:	CALL	cf@zro
	JNC	neq@4
	JZ	cf@fls
	JMP	cf@tru
cf@zro: XRA	A
	LXI	H,7
	DAD	SP
	ORA	B
	JZ	zer1
	XRA	A
	ORA	M
	RNZ
	INR	A
zer1:	ORA	M
	STC
	LXI	D,2
	RET
fsub:	CALL	flneg@
fadd@:	MOV	A,B
	ORA	A
	RZ
	LDA	fac?
	ORA	A
	JZ	movfr@
	SUB	B
	JNC	fadd1
	CMA
	INR	A
	XCHG
	CALL	pushf@
	XCHG
	CALL	movfr@
	POP	B
	POP	D
fadd1:	CPI	25
	RNC
	PUSH	PSW
	CALL	unpack
	MOV	H,A
	POP	PSW
	CALL	shiftr
	ORA	H
	LXI	H,facl?
	JP	fadd3
	CALL	fadda@
	JNC	round
	INX	H
	INR	M
	CZ	overr
	MVI	L,1
	CALL	shradd
	JMP	round
fadd3:	XRA	A
	SUB	B
	MOV	B,A
	MOV	A,M
	SBB	E
	MOV	E,A
	INX	H
	MOV	A,M
	SBB	D
	MOV	D,A
	INX	H
	MOV	A,M
	SBB	C
	MOV	C,A
fadflt: CC	negr
normal: MOV	L,B
	MOV	H,E
	XRA	A
norm1:	MOV	B,A
	MOV	A,C
	ORA	A
	JNZ	norm3
	MOV	C,D
	MOV	D,H
	MOV	H,L
	MOV	L,A
	MOV	A,B
	SUI	8
	CPI	0E0H
	JNZ	norm1
zero@:	XRA	A
zero0:	STA	fac?
	RET
norm2:	DCR	B
	DAD	H
	MOV	A,D
	RAL
	MOV	D,A
	MOV	A,C
	ADC	A
	MOV	C,A
norm3:	JP	norm2
	MOV	A,B
	MOV	E,H
	MOV	B,L
	ORA	A
	JZ	round
	LXI	H,fac?
	ADD	M
	MOV	M,A
	JNC	zero@
	RZ
round:	MOV	A,B
roundb: LXI	H,fac?
	ORA	A
	CM	rounda
	MOV	B,M
	INX	H
	MOV	A,M
	ANI	80H
	XRA	C
	MOV	C,A
	JMP	movfr@
rounda: INR	E
	RNZ
	INR	D
	RNZ
	INR	C
	RNZ
	MVI	C,80H
	INR	M
	RNZ
overr1: JMP	overr
fadda@: MOV	A,M
	ADD	E
	MOV	E,A
	INX	H
	MOV	A,M
	ADC	D
	MOV	D,A
	INX	H
	MOV	A,M
	ADC	C
	MOV	C,A
	RET
negr:	LXI	H,fac?1
	MOV	A,M
	CMA
	MOV	M,A
	XRA	A
	MOV	L,A
	SUB	B
	MOV	B,A
	MOV	A,L
	SBB	E
	MOV	E,A
	MOV	A,L
	SBB	D
	MOV	D,A
	MOV	A,L
	SBB	C
	MOV	C,A
	RET
shiftr: MVI	B,0
shftr1: SUI	8
	JC	shftr2
	MOV	B,E
	MOV	E,D
	MOV	D,C
	MVI	C,0
	JMP	shftr1
shftr2: ADI	9
	MOV	L,A
shftr3: XRA	A
	DCR	L
	RZ
	MOV	A,C
shradd: RAR
	MOV	C,A
	MOV	A,D
	RAR
	MOV	D,A
	MOV	A,E
	RAR
	MOV	E,A
	MOV	A,B
	RAR
	MOV	B,A
	JMP	shftr3
fmult3: MOV	B,E
	MOV	E,D
	MOV	D,C
	MOV	C,A
	RET
fmult:	CALL	sign@
	RZ
	MVI	L,0
	CALL	muldiv
	MOV	A,C
	STA	fmlt?1
	XCHG
	SHLD	fmlt?2
	LXI	B,0
	MOV	D,B
	MOV	E,B
	LXI	H,normal
	PUSH	H
	LXI	H,fmult2
	PUSH	H
	PUSH	H
	LXI	H,facl?
fmult2: MOV	A,M
	INX	H
	ORA	A
	JZ	fmult3
	PUSH	H
	MVI	L,8
fmult4: RAR
	MOV	H,A
	MOV	A,C
	JNC	fmult5
	PUSH	H
	LHLD	fmlt?2
	DAD	D
	XCHG
	POP	H
	LDA	fmlt?1
	ADC	C
fmult5: RAR
	MOV	C,A
	MOV	A,D
	RAR
	MOV	D,A
	MOV	A,E
	RAR
	MOV	E,A
	MOV	A,B
	RAR
	MOV	B,A
	DCR	L
	MOV	A,H
	JNZ	fmult4
pophrt: POP	H
	RET
div10@: CALL	pushf@
	LXI	B,8420H
	LXI	D,0000H
	CALL	movfr@
fdivt:	POP	B
	POP	D
fdiv:	CALL	sign@
	CZ	dv0err
	MVI	L,0FFH
	CALL	muldiv
	INR	M
	INR	M
	DCX	H
	MOV	A,M
	STA	fdiv?a
	DCX	H
	MOV	A,M
	STA	fdiv?b
	DCX	H
	MOV	A,M
	STA	fdiv?c
	MOV	B,C
	XCHG
	XRA	A
	MOV	C,A
	MOV	D,A
	MOV	E,A
	STA	fdiv?g
fdiv1:	PUSH	H
	PUSH	B
	MOV	A,L
fdivc:
	PUSH	H
	LXI	H,fdiv?c
	SUB	M
	POP	H
	MOV	L,A
	MOV	A,H
fdivb:
	PUSH	H
	LXI	H,fdiv?b
	SBB	M
	POP	H
	MOV	H,A
	MOV	A,B
fdiva:
	PUSH	H
	LXI	H,fdiv?a
	SBB	M
	POP	H
	MOV	B,A
fdivg:
	LDA	fdiv?g
	SBI	0
	CMC
	JNC	fdiv2
	STA	fdiv?g
	POP	PSW
	POP	PSW
	STC
	DB	0D2H
fdiv2:	POP	B
	POP	H
	MOV	A,C
	INR	A
	DCR	A
	RAR
	JM	roundb
	RAL
	MOV	A,E
	RAL
	MOV	E,A
	MOV	A,D
	RAL
	MOV	D,A
	MOV	A,C
	RAL
	MOV	C,A
	DAD	H
	MOV	A,B
	RAL
	MOV	B,A
	LDA	fdiv?g
	RAL
	STA	fdiv?g
	MOV	A,C
	ORA	D
	ORA	E
	JNZ	fdiv1
	PUSH	H
	LXI	H,fac?
	DCR	M
	POP	H
	CZ	overr
	JNZ	fdiv1
muldiv: MOV	A,B
	ORA	A
	JZ	muldv2
	MOV	A,L
	LXI	H,fac?
	XRA	M
	ADD	B
	MOV	B,A
	RAR
	XRA	B
	MOV	A,B
	JP	muldv1
	ADI	80H
	MOV	M,A
	JZ	pophrt
	CALL	unpack
	MOV	M,A
dcxhrt: DCX	H
	RET
mldvex: CALL	sign@
	CMA
	POP	H
muldv1: ORA	A
muldv2: POP	H
	CM	overr
	JMP	zero@
mul10@: CALL	movrf@
	MOV	A,B
	ORA	A
	RZ
	ADI	2
	CC	overr
	MOV	B,A
	CALL	fadd@
	LXI	H,fac?
	INR	M
	RNZ
	JMP	overr
sign@:	LDA	fac?
	ORA	A
	RZ
signc:	LDA	facl?2
	DB	(CPI)
fcomps: CMA
	RAL
	SBB	A
	RNZ
inrart: INR	A
	RET
fflo:	MVI	B,98H
	MOV	A,C
	JMP	floatr
float@: MVI	B,88H
	LXI	D,0000H
floatr: LXI	H,fac?
	MOV	C,A
	MOV	M,B
	MVI	B,0
	INX	H
	MVI	M,80H
	RAL
	JMP	fadflt
flneg@: LXI	H,facl?2
	MOV	A,M
	XRI	80H
	MOV	M,A
	RET
pushf@: XCHG
	LHLD	facl?
	XTHL
	PUSH	H
	LHLD	facl?2
	XTHL
	PUSH	H
	XCHG
	RET
movfm@: CALL	movrm@
movfr@: XCHG
	SHLD	facl?
	MOV	H,B
	MOV	L,C
	SHLD	facl?2
	XCHG
	RET
movrf@: LXI	H,facl?
	JMP	movrm@
inxhr@: INX	H
	RET
movmf@: LXI	D,facl?
move:	MVI	B,4
move1:	LDAX	D
	MOV	M,A
	INX	D
	INX	H
	DCR	B
	JNZ	move1
	RET
unpack: LXI	H,facl?2
	MOV	A,M
	RLC
	STC
	RAR
	MOV	M,A
	CMC
	RAR
	INX	H
	INX	H
	MOV	M,A
	MOV	A,C
	RLC
	STC
	RAR
	MOV	C,A
	RAR
	XRA	M
	RET
fcomp@: MOV	A,B
	ORA	A
	JZ	sign@
	LXI	H,fcomps
	PUSH	H
	CALL	sign@
	MOV	A,C
	RZ
	LXI	H,facl?2
	XRA	M
	MOV	A,C
	RM
	CALL	fcomp2
fcompd: RAR
	XRA	C
	RET
fcomp2: INX	H
	MOV	A,B
	CMP	M
	RNZ
	DCX	H
	MOV	A,C
	CMP	M
	RNZ
	DCX	H
	MOV	A,D
	CMP	M
	RNZ
	DCX	H
	MOV	A,E
	SUB	M
	RNZ
	POP	H
	POP	H
	RET
fint@:	LXI	B,6900H
	MOV	D,C
	MOV	E,C
	CALL	fadd@
	LXI	H,fac?
	MOV	A,M
qint@:	MOV	B,A
	MOV	C,A
	MOV	D,A
	MOV	E,A
	ORA	A
	RZ
	PUSH	H
	CALL	movrf@
	CALL	unpack
	XRA	M
	MOV	H,A
	CM	qinta
	MVI	A,98H
	SUB	B
	CALL	shiftr
	MOV	A,H
	RAL
	CC	rounda
	MVI	B,0
	CC	negr
	POP	H
	RET
qinta:	DCX	D
	MOV	A,D
	ANA	E
	INR	A
	RNZ
dcxbrt: DCX	B
	RET
int:	LXI	H,fac?
	MOV	A,M
	CPI	98H
	LDA	facl?
	RNC
	MOV	A,M
	CALL	qint@
	MVI	M,98H
	MOV	A,E
	PUSH	PSW
	MOV	A,C
	RAL
	CALL	fadflt
	POP	PSW
	RET
overr:	CALL	erreur
	DB	1
	RET
dv0err: CALL	erreur
	DB	3
	RET
erreur:
	XTHL
	PUSH	PSW
	LDA	errcod
	ORA	A
	JNZ	exiterr
	MOV	A,M
	STA	errcod
exiterr:
	INX	H
	POP	PSW
	XTHL
	RET
Hc@Bf:	CALL	Hc@Bl
	JMP	HiBf0
Hi@Bf:	CALL	Hi@Bl
HiBf0:	CALL	fflo
	JMP	movrf@
Hu@Bf:	CALL	Hu@Bl
Bl@Bf:
	MOV	A,B
	ORA	A
	JP	BlBf0
	CALL	L@neg
	MVI	A,-1
BlBf0:	PUSH	PSW
	PUSH	B
	MVI	C,0
	CALL	fflo
	POP	B
	CALL	pushf@
	MOV	E,C
	MOV	D,B
	MVI	C,0
	CALL	fflo
	LDA	fac?
	ORA	A
	JZ	R?b
	ADI	16
	STA	fac?
R?b:	POP	B
	POP	D
	CALL	fadd@
	POP	PSW
	ORA	A
	CM	flneg@
	JMP	movrf@
Bf@Hc:	CALL	Bf@Bl
	XCHG
	JMP	c@sxt
Bf@Hu:	DS	0
Bf@Hi:	CALL	Bf@Bl
	XCHG
	RET
Bf@Bl:	MOV	A,B
	ORA	A
	JNZ	BfBl0
	MOV	C,A
	MOV	D,A
	MOV	E,A
	RET
BfBl0:
	LXI	H,0
	MOV	A,C
	XRI	80H
	JM	BfBl1
	MOV	C,A
	INR	H
BfBl1:	MOV	A,B
	CPI	128+32
	JNC	BfBlov
	CPI	128+24
	JC	BfBl2
	SUI	8
	MOV	B,A
	INR	L
BfBl2:	PUSH	H
	CALL	movfr@
	CALL	fint@
	MVI	B,0
	POP	H
	DCR	L
	JNZ	BfBl3
	MOV	B,C
	MOV	C,D
	MOV	D,E
	MVI	E,0
BfBl3:	DCR	H
	RNZ
	JMP	L@neg
BfBlov: LXI	B,7FFFH
	LXI	D,-1
	JMP	BfBl3
F@not:	LXI	H,1
	MOV	A,B
	ORA	A
	RNZ
	DCR	L
	RET
flt@0:	MOV	A,B
	ORA	A
	RET
f?stak: DS	0
I@@F:	XTHL
	PUSH	H
	LXI	H,Hi@Bf
	JMP	C@1632
C@@F:	XTHL
	PUSH	H
	LXI	H,Hc@Bf
	JMP	C@1632
U@@F:	XTHL
	PUSH	H
	LXI	H,Hu@Bf
	JMP	C@1632
F@@C:	PUSH	H
	LXI	H,Bf@Hc
	JMP	C@3216
F@@U:	PUSH	H
	LXI	H,Bf@Hu
	JMP	C@3216
F@@I:	PUSH	H
	LXI	H,Bf@Hi
	JMP	C@3216
L@@F:	XRA	A
	JMP	C3232
F@@L:	MVI	A,1
C3232:	PUSH	B
	PUSH	D
	PUSH	H
	LXI	H,her@32
	PUSH	H
	LXI	H,10
	DAD	SP
	CALL	movrm@
	ORA	A
	JZ	Bl@Bf
	JMP	Bf@Bl
	RET
@tmvb:	DW	-27009,-26600
@umvb:	DW	9216,-27532
digc??: DB	0
fmtc??: DB	0
@vmvb:	DW	16960,15,-31072,1,10000,0,1000,0
	DW	100,0,10,0,1,0
@wmvb:	DW	9216,-27788,20480,-28605,16384,-29412,0,-30342
	DW	0,-31160,0,-31968,0,32768,-13107,31820
	DW	-10486,31011,4718,30211,-18666,29265,-14933,28455
	DW	-16493,27478,-13194,26667
ftoa:	LXI	H,8
	DAD	SP
	CALL	h@
	MOV	A,L
	STA	digc??
	LXI	H,10
	DAD	SP
	CALL	g@
	MOV	A,L
	STA	fmtc??
	LXI	H,4
	DAD	SP
	CALL	movrm@
	CALL	movfr@
	POP	D
	POP	H
	PUSH	H
	PUSH	D
	CALL	sign@
	JP	fout1
	MVI	M,'-'
	INX	H
fout1:	MVI	M,'0'
	JZ	fout19a
	PUSH	H
	CM	flneg@
	LDA	fmtc??
	ANI	0137Q
	CPI	'E'
	JZ	fout41
	LDA	digc??
	ADI	6
	CALL	f@round
fout41: XRA	A
	PUSH	PSW
	CALL	foutcb
fout3:	DS	0
	LXI	H,@umvb
	CALL	llong@
	CALL	fcomp@
	ORA	A
	JP	fout5
	CALL	mul10@
	POP	PSW
	DCR	A
	PUSH	PSW
	JMP	fout3
foutcb: DS	0
	LXI	H,@tmvb
	CALL	llong@
	CALL	fcomp@
	ORA	A
	POP	H
	JPO	fout9
	PCHL
fout9:	CALL	div10@
	POP	PSW
	INR	A
	PUSH	PSW
	CALL	foutcb
fout5:	LDA	fmtc??
	ANI	0137Q
	CPI	'E'
	JNZ	fout5a
	LDA	digc??
	CALL	f@round
	CALL	foutcb
fout5a: MVI	A,1
	CALL	qint@
	CALL	movfr@
	POP	PSW
	POP	H
	ADI	7-1
	MOV	C,A
	LDA	fmtc??
	ANI	0137Q
	CPI	'E'
	MVI	B,2
	MOV	A,C
	JZ	fout6
	ADI	2
	MOV	B,A
	MVI	A,0
	JZ	fout6a
	JP	fout6
fout6a: MVI	M,'.'
	INX	H
	LDA	digc??
	DCR	B
fout32: MVI	M,'0'
	INX	H
	DCR	A
	JZ	fout17
	INR	B
	JM	fout32
	MVI	B,0
	STA	digc??
	XRA	A
fout6:	PUSH	PSW
	LDA	digc??
	PUSH	PSW
	MVI	C,7
	XCHG
	LXI	H,@vmvb
	XCHG
fout8:	DCR	C
	JM	fout8b
	DCR	B
	JM	fout8g
	JNZ	fout8f
	MVI	M,'.'
	INX	H
fout8g: POP	PSW
	DCR	A
	JM	fout11
	PUSH	PSW
fout8f: PUSH	B
	PUSH	H
	PUSH	D
	CALL	movrf@
	POP	H
	MVI	B,2FH
fout10: INR	B
	MOV	A,E
	SUB	M
	MOV	E,A
	INX	H
	MOV	A,D
	SBB	M
	MOV	D,A
	INX	H
	MOV	A,C
	SBB	M
	MOV	C,A
	DCX	H
	DCX	H
	JNC	fout10
	CALL	fadda@
	INX	H
	INX	H
	CALL	movfr@
	XCHG
	POP	H
	MOV	M,B
	INX	H
	POP	B
	JMP	fout8
fout8b: MOV	A,B
	DCR	A
	CALL	foutt@
	DCR	B
	MVI	M,'.'
	CP	inxhr@
	POP	PSW
	CALL	foutt@
fout11: LDA	fmtc??
	ANI	040Q
	JNZ	fout12
fout11a: DCX	 H
	MOV	A,M
	CPI	'0'
	JZ	fout11a
	CPI	'.'
	CNZ	inxhr@
fout12: POP	PSW
	ORA	A
	JZ	fout17
fout20: MVI	M,'e'
	INX	H
	MVI	M,'+'
	JP	fout14
	MVI	M,'-'
	CMA
	INR	A
fout14: MVI	B,'0'-1
fout15: INR	B
	SUI	10
	JNC	fout15
	INX	H
	MOV	M,B
fout19: INX	H
	ADI	'0'+10
	MOV	M,A
fout19a: INX	H
fout17: MVI	M,0
	RET
foutt@: DCR	A
	RM
	MVI	M,'0'
	INX	H
	JMP	foutt@
f@round: ADD	A
	RM
	CPI	28
	RNC
	ADD	A
	MOV	E,A
	MVI	D,0
	LXI	H,@wmvb
	DAD	D
	CALL	movrm@
	JMP	fadd@
	RET
atof:	DS	0
	LXI	H,2
	DAD	SP
	MOV	E,M
	INX	H
	MOV	D,M
	XCHG
	MOV	A,M
	CALL	ffin
	JMP	movrf@
ffin:	CPI	'-'
	PUSH	PSW
	JZ	fin1
	CPI	'+'
	JZ	fin1
	DCX	H
fin1:	CALL	zero@
	MOV	B,A
	MOV	D,A
	MOV	E,A
	CMA
	MOV	C,A
finc:	CALL	chrgtr
	JC	findig
	CPI	'.'
	JZ	findp
	CPI	'e'
	JZ	founde
	CPI	'E'
	JNZ	fine
founde:
	CALL	chrgtr
	CALL	minpls
finec:	CALL	chrgtr
	JC	finedg
	INR	D
	JNZ	fine
	XRA	A
	SUB	E
	MOV	E,A
	INR	C
findp:	INR	C
	JZ	finc
fine:	PUSH	H
	MOV	A,E
	SUB	B
fine2:	CP	finmul
	JP	fine3
	PUSH	PSW
	CALL	div10@
	POP	PSW
	INR	A
fine3:	JNZ	fine2
	POP	D
	POP	PSW
	CZ	flneg@
	XCHG
	RET
finmul: RZ
finmlt: PUSH	PSW
	CALL	mul10@
	POP	PSW
dcrart: DCR	A
	RET
findig: PUSH	D
	MOV	D,A
	MOV	A,B
	ADC	C
	MOV	B,A
	PUSH	B
	PUSH	H
	PUSH	D
	CALL	mul10@
	POP	PSW
	SUI	30H
	CALL	finlog
	POP	H
	POP	B
	POP	D
	JMP	finc
finlog: CALL	pushf@
	CALL	float@
faddt:	POP	B
	POP	D
	JMP	fadd@
finedg: MOV	A,E
	RLC
	RLC
	ADD	E
	RLC
	ADD	M
	SUI	'0'
	MOV	E,A
	JMP	finec
chrgtr: INX	H
chrgt2: MOV	A,M
	CPI	':'
	RNC
chrcon: CPI	' '
	JZ	chrgtr
notlf:	CPI	'0'
	CMC
	INR	A
	DCR	A
	RET
minpls: DCR	D
	CPI	0A8H
	RZ
	CPI	'-'
	RZ
	INR	D
	CPI	'+'
	RZ
	CPI	0A7H
	RZ
	DCX	H
	RET

* Long runtime library; C/80 3.0 (5/28/83) - (c) 1983 Walter Bilofsky
* Rev. for DRI ASM's 5-2-85 drm

L?shif: DS	0
L@and:	LXI	H,2
	DAD	SP
	MOV	A,M
	ANA	E
	MOV	E,A
	INX	H
	MOV	A,M
	ANA	D
	MOV	D,A
	INX	H
	MOV	A,M
	ANA	C
	MOV	C,A
	INX	H
	MOV	A,M
	ANA	B
	MOV	B,A
	POP	H
	INX	SP
	INX	SP
	XTHL
	RET
L@asr:	XRA	A
	ORA	B
	ORA	C
	ORA	D
	JNZ	Lasr9
	ORA	E
	JZ	Lasr3
	MOV	A,E
	CPI	32
	JNC	Lasr9
Lasr2:	MVI	B,4
	LXI	H,5
	DAD	SP
	XRA	A
	MOV	A,M
	ORA	A
	JP	Lasr1
	STC
Lasr1:	MOV	A,M
	RAR
	MOV	M,A
	DCX	H
	DCR	B
	JNZ	Lasr1
	DCR	E
	JNZ	Lasr2
Lasr3:	POP	H
	POP	D
	POP	B
	PCHL
Lasr9:
	LXI	H,5
	DAD	SP
	MOV	A,M
	ORA	A
	MVI	A,0
	JP	Lasr8
	DCR	A
Lasr8:	MVI	B,4
Lasr7:	MOV	M,A
	DCX	H
	DCR	B
	JNZ	Lasr7
	JMP	Lasr3
L@asl:	XRA	A
	ORA	B
	ORA	C
	ORA	D
	JNZ	Lasl9
	ORA	E
	JZ	Lasr3
	MOV	A,E
	CPI	32
	JNC	Lasl9
Lasl2:	MVI	B,4
	LXI	H,2
	DAD	SP
	XRA	A
Lasl4:	MOV	A,M
	RAL
	MOV	M,A
	INX	H
	DCR	B
	JNZ	Lasl4
	DCR	E
	JNZ	Lasl2
	JMP	Lasr3
Lasl9:	LXI	H,5
	DAD	SP
	XRA	A
	JMP	Lasr8
	RET
L?comp: DS	0
cl@lt:	LXI	H,4
	CALL	swaps@
cl@gt:	LXI	H,1
cl@glt: PUSH	H
	CALL	sstak
	POP	H
	PUSH	PSW
	CALL	long@0
	JNZ	clgt1
	POP	PSW
	JMP	clgt2
clgt1:	POP	PSW
	LXI	H,2
	JNC	clgt2
	DCR	L
clgt2:	POP	D
	POP	B
	POP	B
	PUSH	D
	DCR	L
	RET
cl@le:	LXI	H,4
	CALL	swaps@
cl@ge:	LXI	H,2
	JMP	cl@glt
sstak:	LXI	H,6
	DAD	SP
	MOV	A,M
	SUB	E
	MOV	E,A
	INX	H
	MOV	A,M
	SBB	D
	MOV	D,A
	INX	H
	MOV	A,M
	SBB	C
	MOV	C,A
	INX	H
	MOV	A,M
	MOV	L,B
	MOV	H,A
	SBB	B
	MOV	B,A
	PUSH	PSW
	MOV	A,H
	XRA	L
	JP	snorml
	POP	PSW
	CMC
	RET
snorml: POP	PSW
	RET
	RET
L?mdiv: DS	0
L@mul:	PUSH	B
	PUSH	D
	LXI	D,0
	PUSH	D
	PUSH	D
Lmshtx: MVI	B,4
	LXI	H,7
	DAD	SP
	XRA	A
Lmrtx:	MOV	A,M
	RAR
	MOV	M,A
	DCX	H
	DCR	B
	JNZ	Lmrtx
	JNC	Lmul0
	MVI	B,4
	LXI	H,10
	DAD	SP
	XCHG
	LXI	H,0
	DAD	SP
	XRA	A
Lmnxt:	LDAX	D
	ADC	M
	MOV	M,A
	INX	D
	INX	H
	DCR	B
	JNZ	Lmnxt
Lmul0:	LXI	H,4
	MOV	B,L
	MOV	A,H
	DAD	SP
Lmzchk: ORA	M
	JNZ	Lmshty
	INX	H
	DCR	B
	JNZ	Lmzchk
	JMP	Lmexi
Lmshty: MVI	B,4
	LXI	H,10
	DAD	SP
	XRA	A
Lmlfty: MOV	A,M
	RAL
	MOV	M,A
	INX	H
	DCR	B
	JNZ	Lmlfty
	JMP	Lmshtx
Lmexi:	LXI	H,8
	DAD	SP
	MOV	E,M
	INX	H
	MOV	D,M
	INX	H
	INX	H
	INX	H
	MOV	M,E
	INX	H
	MOV	M,D
	POP	D
	POP	B
	LXI	H,8
	DAD	SP
	SPHL
	RET
L@mod:	MVI	L,0
	JMP	Ldiv0
L@div:	MVI	L,1
Ldiv0:	PUSH	H
	PUSH	B
	PUSH	D
	MOV	A,B
	ORA	A
	JP	Ldiv1
	CALL	negst4
	MVI	A,-1
Ldiv1:	PUSH	PSW
	LXI	H,0
	PUSH	H
	PUSH	H
	MVI	L,17
	DAD	SP
	MOV	B,M
	DCX	H
	MOV	C,M
	DCX	H
	MOV	D,M
	DCX	H
	MOV	E,M
	PUSH	B
	PUSH	D
	MOV	A,B
	ORA	A
	JP	Ldiv2
	CALL	negst4
	MVI	A,-1
Ldiv2:	LXI	H,9
	DAD	SP
	XRA	M
	MOV	M,A
	LXI	H,0
	PUSH	H
	PUSH	H
	MVI	A,32
Ldiv10: PUSH	PSW
	LXI	H,6
	DAD	SP
	XRA	A
	MVI	B,8
Ldiv3:	MOV	A,M
	RAL
	MOV	M,A
	INX	H
	DCR	B
	JNZ	Ldiv3
	LXI	H,13
	DAD	SP
	XCHG
	LXI	H,19
	DAD	SP
	LXI	B,4*256
Ldiv5:	LDAX	D
	CMP	M
	JC	Ldiv4
	JNZ	Ldiv44
	DCX	H
	DCX	D
	DCR	B
	JNZ	Ldiv5
Ldiv44:
	INR	C
Ldiv4:
	CMC
	PUSH	PSW
	LXI	H,4
	DAD	SP
	POP	PSW
	MVI	B,4
Ldiv7:	MOV	A,M
	RAL
	MOV	M,A
	INX	H
	DCR	B
	JNZ	Ldiv7
	MOV	A,C
	ORA	A
	JZ	Ldiv8
	LXI	H,16
	DAD	SP
	XCHG
	LXI	H,10
	DAD	SP
	XRA	A
	XCHG
	MVI	B,4
Ldiv9:	LDAX	D
	SBB	M
	STAX	D
	INX	H
	INX	D
	DCR	B
	JNZ	Ldiv9
Ldiv8:
	POP	PSW
	DCR	A
	JNZ	Ldiv10
	LXI	H,18
	DAD	SP
	MOV	A,M
	ORA	A
	JNZ	Ldiv20
	LXI	H,8
	DAD	SP
	XCHG
	LXI	H,0
	DAD	SP
	XCHG
	MVI	B,4
Ldiv21: MOV	A,M
	STAX	D
	INX	H
	INX	D
	DCR	B
	JNZ	Ldiv21
Ldiv20:
	LXI	H,13
	DAD	SP
	MOV	A,M
	ORA	A
	CM	negst4
	POP	D
	POP	B
	LXI	H,16
	DAD	SP
	SPHL
outLL:	POP	H
	INX	SP
	INX	SP
	XTHL
	RET
negst4:
	PUSH	H
	PUSH	B
	LXI	B,4*256
	LXI	H,6
	DAD	SP
	XRA	A
ngst4l: MOV	A,C
	SBB	M
	MOV	M,A
	INX	H
	DCR	B
	JNZ	ngst4l
	POP	B
	POP	H
	RET
L@or:	LXI	H,2
	DAD	SP
	MOV	A,M
	ORA	E
	MOV	E,A
	INX	H
	MOV	A,M
	ORA	D
	MOV	D,A
	INX	H
	MOV	A,M
	ORA	C
	MOV	C,A
	INX	H
	MOV	A,M
	ORA	B
	MOV	B,A
	JMP	outLL
L@xor:	LXI	H,2
	DAD	SP
	MOV	A,M
	XRA	E
	MOV	E,A
	INX	H
	MOV	A,M
	XRA	D
	MOV	D,A
	INX	H
	MOV	A,M
	XRA	C
	MOV	C,A
	INX	H
	MOV	A,M
	XRA	B
	MOV	B,A
	JMP	outLL
	RET

* 32 bit common library routines; C/80 3.0 (7/1/83) - (c) 1983 Walter Bilofsky
* Rev. for DRI ASM's 5-2-85 drm

Four?b: DS	0
movrm@:
llong@: MOV	E,M
	INX	H
	MOV	D,M
	INX	H
	MOV	C,M
	INX	H
	MOV	B,M
	INX	H
	RET
st4@:	XTHL
	CALL	llong@
	XTHL
slong@: MOV	M,E
	INX	H
	MOV	M,D
	INX	H
	MOV	M,C
	INX	H
	MOV	M,B
	RET
eq@4:	POP	H
	PUSH	B
	MVI	C,1
	JMP	comp@4
neq@4:	POP	H
	PUSH	B
	MVI	C,0
comp@4:
	PUSH	D
	PUSH	H
	LXI	H,2
	DAD	SP
	XCHG
	LXI	H,6
	DAD	SP
	MVI	B,4
lneq@4: LDAX	D
	CMP	M
	INX	H
	INX	D
	JNZ	diff
	DCR	B
	JNZ	lneq@4
	XRA	A
	JMP	exneq
diff:	MVI	A,1
exneq:	POP	H
	POP	D
	POP	D
	POP	D
	XTHL
	MVI	H,0
	XRA	C
	MOV	L,A
	RET
swap4@: LXI	H,2
swaps@: DAD	SP
	MOV	A,M
	MOV	M,E
	MOV	E,A
	INX	H
	MOV	A,M
	MOV	M,D
	MOV	D,A
	INX	H
	MOV	A,M
	MOV	M,C
	MOV	C,A
	INX	H
	MOV	A,M
	MOV	M,B
	MOV	B,A
	RET
long@0: MOV	A,B
	ORA	C
	ORA	D
	ORA	E
	RET
L@not:	LXI	H,1
	CALL	long@0
	RNZ
	DCR	L
	RET
l?stak: DS	0
C@@L:	XTHL
	PUSH	H
	LXI	H,Hc@Bl
	JMP	C@1632
U@@L:	XTHL
	PUSH	H
	LXI	H,Hu@Bl
	JMP	C@1632
I@@L:	XTHL
	PUSH	H
	LXI	H,Hi@Bl
C@1632: PUSH	B
	PUSH	D
	PUSH	H
	LXI	H,8
	DAD	SP
	CALL	movrm@
	POP	H
	PUSH	D
	LXI	D,her@32
	PUSH	D
	PUSH	H
	MOV	H,B
	MOV	L,C
	RET
her@32: LXI	H,8
	DAD	SP
	CALL	slong@
	POP	H
	POP	D
	POP	B
	RET
L@@C:	PUSH	H
	LXI	H,Bl@Hc
	JMP	C@3216
L@@U:	PUSH	H
	LXI	H,Bl@Hu
	JMP	C@3216
L@@I:	PUSH	H
	LXI	H,Bl@Hi
C@3216: PUSH	B
	PUSH	D
	PUSH	H
	LXI	H,10
	DAD	SP
	CALL	movrm@
	POP	H
	CALL	callhl
	MOV	B,H
	MOV	C,L
	LXI	H,6
	DAD	SP
	MOV	E,M
	INX	H
	MOV	D,M
	INX	H
	CALL	slong@
	POP	D
	POP	B
	POP	H
	POP	PSW
	RET
callhl: PCHL
	RET
I?long: DS	0
Hu@Bl:	XCHG
	LXI	B,0
	RET
Hc@Bl:	MOV	A,L
	CALL	sgnbyt
	MOV	E,L
	MOV	D,A
	MOV	C,A
	MOV	B,A
	RET
Hi@Bl:	MOV	A,H
	CALL	sgnbyt
	XCHG
	MOV	C,A
	MOV	B,A
	RET
sgnbyt: ORA	A
	MVI	A,-1
	RM
	INR	A
	RET
Bl@Hu:
Bl@Hi:	XCHG
	RET
Bl@Hc:	XCHG
	JMP	c@sxt
	RET
L?adsb: DS	0
L@sub:	CALL	L@neg
L@add:	POP	H
	XTHL
	DAD	D
	XCHG
	POP	H
	XTHL
	MOV	A,L
	ADC	C
	MOV	C,A
	MOV	A,H
	ADC	B
	MOV	B,A
	RET
L@neg:	MVI	A,0
	SUB	E
	MOV	E,A
	MVI	A,0
	SBB	D
	MOV	D,A
	MVI	A,0
	SBB	C
	MOV	C,A
	MVI	A,0
	SBB	B
	MOV	B,A
	RET
L@com:	MOV	A,E
	CMA
	MOV	E,A
	MOV	A,D
	CMA
	MOV	D,A
	MOV	A,C
	CMA
	MOV	C,A
	MOV	A,B
	CMA
	MOV	B,A
	RET
