	title	 'MP/M II V2.0 Terminal Handler'
	name	'th'
	dseg
@@th:
	public	@@th
	cseg
;terminal$handler:
@th:
	public	@th
;do;

;$include (copyrt.lit)
;/*
;  Copyright (C) 1979,1980,1981
;  Digital Research
;  P.O. Box 579
;  Pacific Grove, CA 93950
;
;  Revised:
;    14 Sept 81  by Thomas Rolander
;*/
;$include (common.lit)
;$nolist
;$include (proces.lit)
;$nolist
;$include (datapg.ext)
;$nolist
;$include (proces.ext)
;$nolist

;  declare list$attached (1) address external;
	extrn	lstatt

;  declare console$attached (1) address external;
	extrn	cnsatt

;  declare console$queue (1) address external;
	extrn	cnsque

;  declare rlr address external;
	extrn	rlr

;  declare drl address external;
	extrn	drl

;  declare thread$root address external;
	extrn	thrdrt

;  declare nmb$cns byte external;
;	extrn	nmbcns

;  declare insert$process literally 'inspr';
;  insert$process:
	extrn	inspr
;    procedure (pdladr,pdadr) external;
;      declare (pdladr,pdadr) address;
;    end insert$process;

;  exitr:
	extrn	exitr
;    procedure external;
;    end exitr;

; process descriptor offsets
nameos	equ	6

CMNCODE:
;      if (console$attached(pd.console) = pdadr)
	LXI	H,0EH
	DAD	B
	MOV	a,M
	ani	0fh
	mov	e,a
	INX	H
	MVI	D,0
	LXI	H,CNSATT
	DAD	D
	DAD	D
	MOV	A,M
	CMP	C
	RNZ
	INX	H
	MOV	A,M
	CMP	B
	DCX	H
	RET

;/*
;  attach:
;          The purpose of the attach procedure is to attach a
;        console to the calling process.  The console to attach
;        is obtained from the process descriptor.  If the console
;        is already attached to the process or if no one has the
;        console attached the process is given the console and
;        is then placed on the DRL list.  If the console is
;        attached to some other process the current process is
;        placed on the console queue.

;  Entry Conditions:
;        BC = process descriptor address

;  Exit Conditions:
;        None

;  ****  Note: this procedure must be called from within a
;              critical region.

;*/
;  attach:
attach:
	public	attach
;    procedure (pdadr) reentrant public;
;      declare pdadr address;
;      declare pd based pdadr process$descriptor;

;      if (console$attached(pd.console) = pdadr) or
	CALL	CMNCODE
	JZ	@1A
	MOV	A,M
	INX	H
	ORA	M
	JNZ	@1
;         (console$attached(pd.console) = 0) then
;      do;
;        console$attached(pd.console) = pdadr;
	MOV	M,B
	DCX	H
	MOV	M,C
;        pd.pl = drl;
@1A:
	LHLD	DRL
	XCHG
	MOV	H,B
	MOV	L,C
	MOV	M,E
	INX	H
	MOV	M,D
;        drl = pdadr;
	DCX	H
	SHLD	DRL
;      end;
	RET
@1:
;      else
;      do;
;        call insert$process (.console$queue(pd.console),pdadr);
	LXI	H,CNSQUE
	DAD	D
	DAD	D
	MOV	D,B
	MOV	E,C
	MOV	B,H
	MOV	C,L
	JMP	INSPR
;      end;
;    end attach;

;/*
;  detach:
;          The purpose of the detach procedure is to detach the
;        console from the calling process.  After checking to
;        determine that the console is attached to the process
;        invoking the detach, the console is detached, attaching
;        the next waiting process to the console and then placing
;        it on the DRL.

;  Entry Conditions:
;        BC = process descriptor address

;  Exit Conditions:
;        None

;  ****  Note: this procedure must be called from within a
;              critical region.

;*/
;  detach:
detach:
	public	detach
;    procedure (pdadr) reentrant public;
;      declare pdadr address;
;      declare pd based pdadr process$descriptor;

;      if pdadr = console$attached(pd.console) then
	CALL	CMNCODE
	RNZ
;      do;
	push	h
;        console$attached(pd.console) = console$queue(pd.console);
	LXI	H,CNSQUE
	DAD	D
	DAD	D
	POP	D
	MOV	A,M
	STAX	D
	MOV	C,A
	INX	H
	INX	D
	MOV	A,M
	STAX	D
	MOV	B,A
;        pdadr = console$attached(pd.console);
;        if pdadr <> 0 then
	ORA	C
	RZ
;        do;
;          console$queue(pd.console) = pd.pl;
	LDAX	B
	DCX	H
	MOV	M,A
	INX	B
	LDAX	B
	INX	H
	MOV	M,A
;          pd.pl = drl;
	LHLD	DRL
	MOV	A,H
	STAX	B
	DCX	B
	MOV	A,L
	STAX	B
;          drl = pdadr;
	MOV	H,B
	MOV	L,C
	SHLD	DRL
;          pd.status = rtr$status;
	INX	H
	INX	H
	MVI	M,0H
;        end;
;      end;
;    end detach;
	RET

;/*
;  assign:
;          The purpose of the assign procedure is to attach a
;        specified console to a specified process.  The process
;        threads are traversed from the thread root to find a
;        match between the name passed as a parameter and the
;        process name.

;  Entry Conditions:
;        BC = name address, points to console # followed by
;               8 byte ASCII name

;  Exit Conditions:
;        A  = return code,
;              where   0 = success,
;                    FFH = failure
;*/

;  assign:
assign:
	public	assign
;    procedure (name$adr) byte reentrant public;
;      declare name$adr address;
;      declare pname based name$adr (1) byte;
;      declare assign$cns literally 'pname(0)';
;      declare match$reqd literally 'pname(9)';
;      declare i byte;
;      declare pdadr address;
;      declare pd based pdadr process$descriptor;
;      declare next$console$ptr address;
;      declare next$console based next$console$ptr address;
;      declare pdladr address;
;      declare pdl based pdladr process$descriptor;

;      disable;
	di
;      pdadr = thread$root;
	LHLD	THRDRT
	XCHG
;      if assign$cns < nmb$cns then
;	LXI	H,NMBCNS
;	LDAX	B
;	CMP	M
;	MVI	A,0FFH
;	RNC
	INX	B
;      do while pdadr <> 0;
@9:
;        i = 1;
	PUSH	B
	LXI	H,6
	DAD	D
	PUSH	H
	MVI	L,8
;        do while (i <> 9) and (pd.name(i-1) = pname(i));
@11:
	XTHL
	LDAX	B
	sub	M
	INX	B
	INX	H
	JZ	@11A
	ani	7fh
	jz	@11a	;don't care on high order bit
	POP	H
	POP	B
	JMP	@6
@11A:
	XTHL
	DCR	L
	JNZ	@11
;          i = i + 1;
;        end;
;        if (i = 9) and
;           (not match$reqd or
	LDAX	B
	RAR
	POP	H
	POP	B
	DCX	B
	LDAX	B
	MOV	C,A
	MVI	B,0
	JNC	@12
	mov	a,m
	ani	0fh
	cmp	c
	JNZ	@6

@12:	;if calling proc owns list, past it as well
	push	b
	lhld	rlr
	mov	b,h
	mov	c,l
	lxi	h,000eh
	dad	b
	mov	a,m
	ani	0f0h
	rrc
	rrc
	rrc
	rrc
	add	a
	lxi	h,lstatt
	add	l
	mov	l,a
	mov	a,h
	aci	0
	mov	h,a
	mov	a,m
	cmp	c
	jnz	@12a
	inx	h
	mov	a,m
	cmp	b
	jnz	@12a
	mov	m,d
	dcx	h
	mov	m,e
@12a:
	pop	b
;           (match$reqd and (assign$cns = pd.console))) then
;        do;
;          enter$region;
	; DE = pdadr, BC = assign$cns
;	DI	;now done at entry
;          console$attached(assign$cns) = pdadr;

;          /* if process is currently queued for the console
;             then put the process on the dispatcher ready list */
	LXI	H,CNSATT
	DAD	B
	DAD	B
	MOV	M,E
	INX	H
	MOV	M,D
;          next$console$ptr = .console$queue(assign$cns);
	LXI	H,CNSQUE
	DAD	B
	DAD	B
;          do forever;
@13:	; HL = next$console$ptr, DE = pdadr
;            if (pdladr := next$console) = 0 then
	MOV	C,M
	INX	H
	MOV	B,M
	DCX	H
	MOV	A,B
	ORA	C
	JZ	@7
;            do;
;              exit$region;
;              return 0;
;            end;
;            if pdladr = pdadr then
	; HL = NEXT$CONSOLE$PTR, DE = PDADR, BC = PDLADR
	MOV	A,E
	CMP	C
	JNZ	@8
	MOV	A,D
	CMP	B
	JNZ	@8
;            do;
;              next$console = pdl.pl;
	LDAX	B
	MOV	M,A
	INX	B
	INX	H
	LDAX	B
	MOV	M,A
;              pd.pl = drl;
	LHLD	DRL
	XCHG
	MOV	M,E
	INX	H
	MOV	M,D
;              drl = pdadr;
	DCX	H
	SHLD	DRL
;              exit$region;
@7:
	ei
;              return 0;
	XRA	A
	RET
;            end;
@8:
;            next$console$ptr = next$console;
	MOV	A,M
	INX	H
	MOV	H,M
	MOV	L,A
;          end; /* of forever */
	JMP	@13
;        end;
@6:
;        pdadr = pd.thread;
	LXI	H,12H
	DAD	D
	MOV	E,M
	INX	H
	MOV	D,M
	MOV	A,D
	ORA	E
	JNZ	@9
;      end;
;      enable;
	ei
;      return 0FFH;
	CMA
	RET
;    end assign;

;end terminal$handler;
	END
