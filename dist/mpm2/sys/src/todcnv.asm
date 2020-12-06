
	title 'MP/M-80 V2.0  Time of Day Conversion Procedure'
	name	'todcnv'
	cseg
;  todcnv:
;  do;
;  /*****************************************************
;            Time & Date ASCII Conversion Code
;   *****************************************************/
	dseg
;  declare lit literally 'literally',
;    forever lit 'while 1',
;    word lit 'address',
;    true lit '0ffh',
;    false lit '0';
;  declare tod$adr address;
tod$adr:
	ds	2
;  declare tod based tod$adr structure (
;    opcode byte,
;    date address,
;    hrs byte,
;    min byte,
;    sec byte,
;    ASCII (21) byte );
;  declare string$adr address;
string$adr:
	ds	2
;  declare string based string$adr (1) byte;
;  declare index byte;
index:
	ds	1
;  declare chr byte;
chr:
	ds	1
;  declare
;      base$year lit '78',   /* base year for computations */
;      base$day  lit '0',    /* starting day for base$year 0..6 */
;      month$size (*) byte data
;      /* jan feb mar apr may jun jul aug sep oct nov dec */
;      (   31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31),
	cseg
month$size:
	db	31,28,31,30,31,30,31,31,30,31,30,31
;      month$days (*) word data
;      /* jan feb mar apr may jun jul aug sep oct nov dec */
;      (  000,031,059,090,120,151,181,212,243,273,304,334);
month$days:
	dw	000,031,059,090,120,151,181,212,243,273,304,334
	dseg
;  declare word$value word;
word$value:
	ds	2
;  declare (month, day, year, hrs, min, sec) byte;
month:
	ds	1
day:
	ds	1
year:
	ds	1
hrs:
	ds	1
min:
	ds	1
sec:
	ds	1
;  declare
;      week$day  byte, /* day of week 0 ... 6 */
weekday:
	ds	1
;      day$list (*) byte data
;      ('Sun$Mon$Tue$Wed$Thu$Fri$Sat$'),
	cseg
day$list:
	db	'Sun$Mon$Tue$Wed$Thu$Fri$Sat$'
	dseg
;      leap$bias byte; /* bias for feb 29 */
leapbias:
	ds	1

	cseg

;  error$exit: procedure;
ERROREXIT:
;      declare rtn byte;
;      /* pop off two returns */
;      stack$ptr = stack$ptr + 6;
;      /* set A reg = 0 */
	LXI	D,6H
	LXI	H,0	;	0
	DAD	SP
	DAD	D
	SPHL
;      rtn = false;
	xra	a
;      end error$exit;
	RET

;  emitchar: procedure(c$1);
EMITCHAR:
;      declare c$1 byte;
;      string(index := index + 1) = c$1;
	lxi	h,index
	inr	m
	mov	e,m
	mvi	d,0
	LHLD	STRINGADR
	dad	d
	mov	m,c
;      end emitchar;
	RET

;  emitn: procedure(a$1);
EMITN:
;      declare a$1 address;
;      declare c based a$1 byte;
;      do while c <> '$';
@25:			;BC = .source
	ldax	b
	CPI	24H
	rz
;        string(index := index + 1) = c;
	lxi	h,index
	inr	m
	mov	e,m
	mvi	d,0
	lhld	stringadr
	dad	d
	mov	m,a
	inx	h
;        a$1 = a$1 + 1;
	inx	b
;      end;
	JMP	@25
;      end emitn;
;	RET

;  emit$bcd$pair: procedure(b$1);
EMITBCDPAIR:
;      declare b$1 byte;
;      call emit$char('0'+shr(b$1,4));
	push	b
	mov	a,c
	ani	0f0h
	RAR
	RAR
	RAR
	RAR
	ADI	'0'
	MOV	C,A
	CALL	EMITCHAR
;      call emit$char('0'+(b$1 and 0fh));
	pop	b
	mov	a,c
	ANI	0FH
	ADI	'0'
	MOV	C,A
	jmp	EMITCHAR
;      end emit$bcd$pair;
;	RET

;  emit$colon: procedure(b$2);
EMITCOLON:
;      declare b$2 byte;
;      call emit$bcd$pair(b$2);
	CALL	EMITBCDPAIR
;      call emitchar(':');
	MVI	C,3AH
	jmp	EMITCHAR
;      end emit$colon;
;	RET

;  emit$bin$pair: procedure(b$3);
EMITBINPAIR:
;      declare b$3 byte;
;      call emit$char('0'+b$3/10);
	mov	e,c
	mvi	d,0
	LXI	H,0AH
	CALL	@P0029
	push	h
	mvi	a,'0'
	add	e
	mov	c,a
	CALL	EMITCHAR
;      call emit$char('0'+b$3 mod 10);
	pop	b
	mov	a,c
	adi	'0'
	mov	c,a
	jmp	EMITCHAR
;      end emit$bin$pair;
;	RET

;  emit$slant: procedure(b$4);
EMITSLANT:
;      declare b$4 byte;
;      call emit$bin$pair(b$4);
	CALL	EMITBINPAIR
;      call emitchar('/');
	MVI	C,2FH
	jmp	EMITCHAR
;      end emit$slant;
;	RET

;  gnc: procedure;
GNC:
;      /* get next command byte */
;      if chr = 0 then return;
	LDA	CHR
	ora	a
	rz
;      if index = 20 then
	LDA	INDEX
	sui	14H
	jz	@2
;      do;
;        chr = 0;
;        return;
;      end;
;      chr = string(index := index + 1);
	lxi	h,index
	inr	m
	mov	e,m
	mvi	d,0
	LHLD	STRINGADR
	DAD	d
	MOV	A,M
@2:
	STA	CHR
;      end gnc;
	RET

;  deblank: procedure;
DEBLANK:
;          do while chr = ' ';
@27:
	LDA	CHR
	CPI	20H
	rnz
;          call gnc;
	CALL	GNC
;          end;
	JMP	@27
;      end deblank;
;	RET

;  numeric: procedure byte;
NUMERIC:
;      /* test for numeric */
;      return (chr - '0') < 10;
	LDA	CHR
	SUI	30H
	SUI	0AH
	SBB	A
	RET
;      end numeric;

;  scan$numeric: procedure(lb$1,ub$1) byte;
SCANNUMERIC:
	LXI	H,UB1
	MOV	M,E
	DCX	H
	MOV	M,C
;      declare (lb$1,ub$1) byte;
	dseg
lb1:
	ds	1
ub1:
	ds	1
;      declare b$5 byte;
b$5:
	ds	1
	cseg
;      b$5 = 0;
	LXI	H,B5
	MVI	M,0H
;      call deblank;
	CALL	DEBLANK
;      if not numeric then call error$exit;
	CALL	NUMERIC
	RAR
	cnc	ERROREXIT
;          do while numeric;
@29:
	CALL	NUMERIC
	RAR
	JNC	@30
;          if (b$5 and 1110$0000b) <> 0 then call error$exit;
	LDA	B5
	ANI	0E0H
	CPI	0H
	cnz	ERROREXIT
;          b$5 = shl(b$5,3) + shl(b$5,1); /* b$5 = b$5 * 10 */
	LDA	B5
	ADD	A
	mov	c,a
	ADD	A
	ADD	A
	ADD	C
	STA	B5
;          if carry then call error$exit;
	SBB	A
	RAR
	cc	ERROREXIT
;          b$5 = b$5 + (chr - '0');
	LDA	CHR
	SUI	30H
	LXI	H,B5
	ADD	M
	MOV	M,A
;          if carry then call error$exit;
	SBB	A
	RAR
	cc	ERROREXIT
;          call gnc;
	CALL	GNC
;          end;
	JMP	@29
@30:
;      if (b$5 < lb$1) or (b$5 > ub$1) then call error$exit;
	LXI	H,LB1
	LDA	B5
	SUB	M
	SBB	A
	INX	H
	PUSH	PSW	;	1
	MOV	A,M
	LXI	H,B5
	SUB	M
	SBB	A
	POP	B	;	1
	MOV	C,B
	ORA	C
	RAR
	cc	ERROREXIT
;      return b$5;
	LDA	B5
	RET
;      end scan$numeric;

;  scan$delimiter: procedure(d$1,lb$2,ub$2) byte;
SCANDELIMITER:
	LXI	H,UB2
	MOV	M,E
	DCX	H
	MOV	M,C
	DCX	H
	POP	D
	POP	B
	MOV	M,C
	PUSH	D
;      declare (d$1,lb$2,ub$2) byte;
	dseg
d$1:
	ds	1
lb2:
	ds	1
ub2:
	ds	1
	cseg
;      call deblank;
	CALL	DEBLANK
;      if chr <> d$1 then call error$exit;
	LXI	H,D1
	LDA	CHR
	CMP	M
	JZ	@8
	CALL	ERROREXIT
@8:
;      call gnc;
	CALL	GNC
;      return scan$numeric(lb$2,ub$2);
	LHLD	LB2
	MOV	C,L
	LHLD	UB2
	XCHG
	jmp	SCANNUMERIC
;	RET
;      end scan$delimiter;

;  leap$days: procedure(y,m$1) byte;
LEAPDAYS:
	LXI	H,M1
	MOV	M,E
	DCX	H
	MOV	M,C
;      declare (y,m$1) byte;
	dseg
y:
	ds	1
m1:
	ds	1
	cseg
;      /* compute days accumulated by leap years */
;      declare yp byte;
	dseg
yp:
	ds	1
	cseg
;      yp = shr(y,2); /* yp = y/4 */
	LDA	Y
	ANI	254
	RAR
	RAR
	STA	YP
;      if (y and 11b) = 0 and month$days(m$1) < 59 then
	LDA	Y
	ANI	3H
	SUI	0H
	SUI	1
	SBB	A
	LHLD	M1
	MVI	H,0
	LXI	B,MONTHDAYS
	DAD	H
	DAD	B
	XCHG
	PUSH	PSW	;	1
	MVI	A,3BH
	CALL	@P0101
	SBB	A
	POP	B	;	1
	MOV	C,B
	ANA	C
	RAR
	JNC	@9
;          /* y not 00, y mod 4 = 0, before march, so not leap yr */
;          return yp - 1;
	LDA	YP
	DCR	A
	RET
@9:
;      /* otherwise, yp is the number of accumulated leap days */
;      return yp;
	LDA	YP
	RET
;      end leap$days;

;  bcd:
BCD:
	LXI	H,VAL
	MOV	M,C
;    procedure (val) byte;
;      declare val byte;
	dseg
val:
	ds	1
	cseg
;      return shl((val/10),4) + val mod 10;
	LHLD	VAL
	MVI	H,0
	XCHG
	LXI	H,0AH
	CALL	@P0029
	XCHG
	DAD	H
	DAD	H
	DAD	H
	DAD	H
	PUSH	H	;	1
	LHLD	VAL
	MVI	H,0
	XCHG
	CALL	@P0030
	POP	B	;	1
	DAD	B
	MOV	A,L
	RET
;    end bcd;

;  set$date$time: procedure;
SETDATETIME:
;      declare
;          (i, leap$flag) byte; /* temporaries */
	dseg
i:
	ds	1
leap$flag:
	ds	1
	cseg
;      month = scan$numeric(1,12) - 1;
;      /* may be feb 29 */
	MVI	E,0CH
	MVI	C,1H
	CALL	SCANNUMERIC
	DCR	A
	STA	MONTH
;      if (leap$flag := month = 1) then i = 29;
	LDA	MONTH
	SUI	1H
	SUI	1
	SBB	A
	STA	LEAPFLAG
	RAR
	JNC	@10
	LXI	H,I
	MVI	M,1DH
	JMP	@11
@10:
;          else i = month$size(month);
	LHLD	MONTH
	MVI	H,0
	LXI	B,MONTHSIZE
	DAD	B
	MOV	A,M
	STA	I
@11:
;      day   = scan$delimiter('/',1,i);
	MVI	C,2FH
	PUSH	B	;	1
	LHLD	I
	XCHG
	MVI	C,1H
	CALL	SCANDELIMITER
	STA	DAY
;      year  = scan$delimiter('/',base$year,99);
;      /* ensure that feb 29 is in a leap year */
	MVI	C,2FH
	PUSH	B	;	1
	MVI	E,63H
	MVI	C,4EH
	CALL	SCANDELIMITER
	STA	YEAR
;      if leap$flag and day = 29 and (year and 11b) <> 0 then
	LDA	DAY
	SUI	1DH
	SUI	1
	SBB	A
	LXI	H,LEAPFLAG
	ANA	M
	PUSH	PSW	;	1
	LDA	YEAR
	ANI	3H
	SUI	0H
	ADI	255
	SBB	A
	POP	B	;	1
	MOV	C,B
	ANA	C
	RAR
	JNC	@12
;          /* feb 29 of non-leap year */ call error$exit;
	CALL	ERROREXIT
@12:
;      /* compute total days */
;       tod.date = month$days(month)
;                  + 365 * (year - base$year)
;                  + day
;                  - leap$days(base$year,0)
;                  + leap$days(year,month);
	LHLD	MONTH
	MVI	H,0
	LXI	B,MONTHDAYS
	DAD	H
	DAD	B
	LDA	YEAR
	SUI	4EH
	MOV	E,A
	MVI	D,0
	PUSH	H	;	1
	LXI	H,16DH
	CALL	@P0034
	POP	D	;	1
	CALL	@P0017
	PUSH	H	;	1
	LHLD	DAY
	MVI	H,0
	POP	B	;	1
	DAD	B
	PUSH	H	;	1
	MVI	E,0H
	MVI	C,4EH
	CALL	LEAPDAYS
	POP	D	;	1
	CALL	@P0096
	PUSH	H	;	1
	LHLD	YEAR
	MOV	C,L
	LHLD	MONTH
	XCHG
	CALL	LEAPDAYS
	MOV	E,A
	MVI	D,0
	POP	H	;	1
	DAD	D
	PUSH	H	;	1
	LHLD	TODADR
	INX	H
	POP	B	;	1
	MOV	M,C
	INX	H
	MOV	M,B
;      tod.hrs   = bcd (scan$numeric(0,23));
	MVI	E,17H
	MVI	C,0H
	CALL	SCANNUMERIC
	MOV	C,A
	CALL	BCD
	LXI	B,3H
	LHLD	TODADR
	DAD	B
	MOV	M,A
;      tod.min   = bcd (scan$delimiter(':',0,59));
	MVI	C,3AH
	PUSH	B	;	1
	MVI	E,3BH
	MVI	C,0H
	CALL	SCANDELIMITER
	MOV	C,A
	CALL	BCD
	LXI	B,4H
	LHLD	TODADR
	DAD	B
	MOV	M,A
;      if tod.opcode = 2 then
	LHLD	TODADR
	MOV	A,M
	CPI	2H
	JNZ	@13
;      /* date, hours and minutes only */
;      do;
;        if chr = ':'
	LDA	CHR
	CPI	3AH
	JNZ	@14
;          then i = scan$delimiter (':',0,59);
	MVI	C,3AH
	PUSH	B	;	1
	MVI	E,3BH
	MVI	C,0H
	CALL	SCANDELIMITER
	STA	I
@14:
;        tod.sec = 0;
	LXI	B,5H
	LHLD	TODADR
	DAD	B
	MVI	M,0H
;      end;
	ret
@13:
;      /* include seconds */
;      else tod.sec   = bcd (scan$delimiter(':',0,59));
	MVI	C,3AH
	PUSH	B	;	1
	MVI	E,3BH
	MVI	C,0H
	CALL	SCANDELIMITER
	MOV	C,A
	CALL	BCD
	LXI	B,5H
	LHLD	TODADR
	DAD	B
	MOV	M,A
;      end set$date$time;
	RET

;  compute$year: procedure;
COMPUTEYEAR:
;      /* compute year from number of days in word$value */
;      declare year$length word;
	dseg
year$length:
	ds	2
	cseg
;      year = base$year;
	LXI	H,YEAR
	MVI	M,4EH
;          do forever;
@31:
;          year$length = 365;
	LXI	H,16DH
	SHLD	YEARLENGTH
;          if (year and 11b) = 0 then /* leap year */
	LDA	YEAR
	ANI	3H
	JNZ	@16
;              year$length = 366;
	LXI	H,16EH
	SHLD	YEARLENGTH
@16:
;          if word$value <= year$length then
	LXI	D,YEARLENGTH
	LXI	B,WORDVALUE
	CALL	@P0098
	rnc
;              return;
;          word$value = word$value - year$length;
	LXI	B,YEARLENGTH
	LXI	D,WORDVALUE
	CALL	@P0098
	XCHG
	DCX	H
	MOV	M,E
	INX	H
	MOV	M,D
;          year = year + 1;
	LXI	H,YEAR
	INR	M
;          end;
	JMP	@31
;      end compute$year;
;	RET

;  compute$month: procedure;
COMPUTEMONTH:
;      month = 12;
	LXI	H,MONTH
	MVI	M,0CH
;          do while month > 0;
@33:
	LXI	H,MONTH
	mov	a,m
	ora	a
	rz
;          if (month := month - 1) < 2 then /* jan or feb */
	DCR	A
	mov	m,a
	CPI	2H
	JNC	@18
;              leapbias = 0;
	LXI	H,LEAPBIAS
	MVI	M,0H
@18:
;          if month$days(month) + leap$bias < word$value then return;
	LHLD	MONTH
	MVI	H,0
	LXI	B,MONTHDAYS
	DAD	H
	DAD	B
	LDA	LEAPBIAS
	CALL	@P0015
	XCHG
	LXI	H,WORDVALUE
	CALL	@P0104
	rc
;          end;
	JMP	@33
;      end compute$month;
;	RET

;  get$date$time: procedure;
GETDATETIME:
;      /* get date and time */
;      hrs = tod.hrs;
	LXI	B,3H
	LHLD	TODADR
	DAD	B
	MOV	A,M
	STA	HRS
;      min = tod.min;
	LHLD	TODADR
	INX	B
	DAD	B
	MOV	A,M
	STA	MIN
;      sec = tod.sec;
	LHLD	TODADR
	INX	B
	DAD	B
	MOV	A,M
	STA	SEC
;      word$value = tod.date;
;      /* word$value contains total number of days */
	LHLD	TODADR
	INX	H
	MOV	E,M
	INX	H
	MOV	D,M
	XCHG
	SHLD	WORDVALUE
;      week$day = (word$value + base$day - 1) mod 7;
	DCX	H
	XCHG
	LXI	H,7H
	CALL	@P0029
	XCHG
	LXI	H,WEEKDAY
	MOV	M,E
;      call compute$year;
;      /* year has been set, word$value is remainder */
	CALL	COMPUTEYEAR
;      leap$bias = 0;
	LXI	H,LEAPBIAS
	MVI	M,0H
;      if (year and 11b) = 0 and word$value > 59 then
	LDA	YEAR
	ANI	3H
	SUI	0H
	SUI	1
	SBB	A
	PUSH	PSW	;	1
	MVI	A,3BH
	LXI	H,WORDVALUE
	CALL	@P0103
	SBB	A
	POP	B	;	1
	MOV	C,B
	ANA	C
	RAR
	JNC	@20
;          /* after feb 29 on leap year */ leap$bias = 1;
	LXI	H,LEAPBIAS
	MVI	M,1H
@20:
;      call compute$month;
	CALL	COMPUTEMONTH
;      day = word$value - (month$days(month) + leap$bias);
	LHLD	MONTH
	MVI	H,0
	LXI	B,MONTHDAYS
	DAD	H
	DAD	B
	LDA	LEAPBIAS
	CALL	@P0015
	LXI	D,WORDVALUE
	CALL	@P0102
	XCHG
	LXI	H,DAY
	MOV	M,E
;      month = month + 1;
	DCX	H
	INR	M
;      end get$date$time;
	RET

;  emit$date$time: procedure;
EMITDATETIME:
;      call emitn(.day$list(shl(week$day,2)));
	LDA	WEEKDAY
	ADD	A
	ADD	A
	MOV	C,A
	MVI	B,0
	LXI	H,DAYLIST
	DAD	B
	MOV	B,H
	MOV	C,L
	CALL	EMITN
;      call emitchar(' ');
	MVI	C,20H
	CALL	EMITCHAR
;      call emit$slant(month);
	LHLD	MONTH
	MOV	C,L
	CALL	EMITSLANT
;      call emit$slant(day);
	LHLD	DAY
	MOV	C,L
	CALL	EMITSLANT
;      call emit$bin$pair(year);
	LHLD	YEAR
	MOV	C,L
	CALL	EMITBINPAIR
;      call emitchar(' ');
	MVI	C,20H
	CALL	EMITCHAR
;      call emit$colon(hrs);
	LHLD	HRS
	MOV	C,L
	CALL	EMITCOLON
;      call emit$colon(min);
	LHLD	MIN
	MOV	C,L
	CALL	EMITCOLON
;      call emit$bcd$pair(sec);
	LHLD	SEC
	MOV	C,L
	jmp	EMITBCDPAIR
;      end emit$date$time;
;	RET

;  tod$cnv:
TODCNV:
	public	todcnv

	mov	h,b
	mov	l,c
;    procedure (parameter) byte;
;      declare parameter address;
;      tod$adr = parameter;
	SHLD	TODADR
;      string$adr = .tod.ASCII;
	xchg
	LXI	h,6H
	DAD	d
	SHLD	STRINGADR
;      if tod.opcode = 0 then
	ldax	d
	ora	a
	JNZ	@21
;      do;
;        call get$date$time;
	CALL	GETDATETIME
;        index = -1;
	LXI	H,INDEX
	MVI	M,0FFH
;        call emit$date$time;
	CALL	EMITDATETIME
;      end;
	JMP	@22
@21:
;      else
;      do;
;        if (tod.opcode = 1) or
	LHLD	TODADR
	MOV	A,M
	SUI	1H
	SUI	1
	SBB	A
	PUSH	PSW	;	1
	MOV	A,M
	SUI	2H
	SUI	1
	SBB	A
	POP	B	;	1
	MOV	C,B
	ORA	C
	RAR
	JNC	@23
;           (tod.opcode = 2) then
;        do;
;          chr = string(index:=0);
	LXI	H,INDEX
	MVI	M,0H
	LHLD	STRINGADR
	MOV	A,M
	STA	CHR
;          call set$date$time;
	CALL	SETDATETIME
;        end;
	JMP	@24
@23:
;        else
;        do;
;          return false;
	xra	a
	RET
;        end;
@24:
;      end;
@22:
;      return true;
	MVI	A,0FFH
	RET
;    end tod$ASCII;
;  end todcnv;

@P0015:
	mov	e,a
	mvi	d,0
	xchg
@P0017:
	LDAX	D
	ADD	L
	MOV	L,A
	INX	D
	LDAX	D
	ADC	H
	MOV	H,A
	RET
@P0029:
	MOV	B,H
	MOV	C,L
@P0030:
	LXI	H,0
	MVI	A,16
	PUSH	PSW
	DAD	H
	XCHG
	SUB	A
	DAD	H
	XCHG
	ADC	L
	SUB	C
	MOV	L,A
	MOV	A,H
	SBB	B
	MOV	H,A
	INX	D
	JNC	$+5H
	DAD	B
	DCX	D
	POP	PSW
	DCR	A
	JNZ	$-14H
	RET
@P0034:
	MOV	B,H
	MOV	C,L

	LXI	H,0
	MVI	A,16
	DAD	H
	XCHG
	DAD	H
	XCHG
	JNC	$+4H
	DAD	B
	DCR	A
	JNZ	$-9H
	RET
@P0096:
	MOV	C,A
	MVI	B,0

	MOV	A,E
	SUB	C
	MOV	L,A
	MOV	A,D
	SBB	B
	MOV	H,A
	RET
@P0098:
	MOV	L,C
	MOV	H,B

	MOV	C,M
	INX	H
	MOV	B,M

	LDAX	D
	SUB	C
	MOV	L,A
	INX	D
	LDAX	D
	SBB	B
	MOV	H,A
	RET
@P0101:
	MOV	L,A
	MVI	H,0
@P0102:
	LDAX	D
	SUB	L
	MOV	L,A
	INX	D
	LDAX	D
	SBB	H
	MOV	H,A
	RET
@P0103:
	MOV	E,A
	MVI	D,0
@P0104:
	MOV	A,E
	SUB	M
	MOV	E,A
	MOV	A,D
	INX	H
	SBB	M
	MOV	D,A
	XCHG
	RET

	END 
