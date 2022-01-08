	title	 'MP/M II V2.0 Extended Disk Operating System'
	name	'xdos'
	dseg
@@xdos:
	public	@@xdos
	cseg
;xdos:
@xdos:
	public	@xdos
;do;

;/*
;  Copyright (C) 1979,1980,1981
;  Digital Research
;  P.O. Box 579
;  Pacific Grove, CA 93950
;
;  Revised:
;    14 Sept 81 by Thomas Rolander
;*/

;$include (common.lit)
;$nolist
;$include (queue.lit)
;$nolist
;$include (proces.lit)
;$nolist
;$include (memmgr.lit)
;$nolist
;$include (datapg.ext)
;$nolist
;$include (proces.ext)
;$nolist
;$include (queue.ext)
;$nolist
;$include (flag.ext)
;$nolist
;$include (memmgr.ext)
;$nolist
;$include (th.ext)
;$nolist
;  flshbf:
	extrn	flshbf
;    procedure;
;    end flshbf;

;  parse$filename:
	extrn	parsefilename
;    procedure (pcb$address) address external;
;      declare pcb$address address;
;    end parse$filename;

;  exitr:
	extrn	exitr
;    procedure external;
;    end exitr;

;  flgwt:
	extrn	flgwt
;    procedure (flgnmb) byte external;
;      declare flgnmb byte;
;    end flgwt;

;  flgset:
	extrn	flgset
;    procedure (flgnmb) byte external;
;      declare flgnmb byte;
;    end flgset;

;  absrq:
	extrn	absrq
;    procedure (mdadr) byte external;
;      declare mdadr address;
;    end absrq;

;  relrq:
	extrn	relrq
;    procedure (mdadr) byte external;
;      declare mdadr address;
;    end relrq;

;  memfr:
	extrn	memfr
;    procedure (mdadr) byte external;
;      declare mdadr address;
;    end memfr;

;  dispat:
	extrn	dispat
;    procedure external;
;    end dispat;

;  makeq:
	extrn	makeq
;    procedure (qcbadr) byte external;
;      declare qcbadr address;
;    end makeq;

;  openq:
	extrn	openq
;    procedure (uqcbadr) byte external;
;      declare uqcbadr address;
;    end openq;

;  deletq:
	extrn	deletq
;    procedure (uqcbadr) byte external;
;      declare uqcbadr address;
;    end deletq;

;  readq:
	extrn	readq
;    procedure (uqcbadr) byte external;
;      declare uqcbadr address;
;    end readq;

;  creadq:
	extrn	creadq
;    procedure (uqcbadr) byte external;
;      declare uqcbadr address;
;    end creadq;

;  writeq:
	extrn	writeq
;    procedure (uqcbadr) byte external;
;      declare uqcbadr address;
;    end writeq;

;  cwriteq:
	extrn	cwriteq
;    procedure (uqcbadr) byte external;
;      declare uqcbadr address;
;    end cwriteq;

;  assign:
	extrn	assign
;    procedure (pname) byte external;
;      declare pname address;
;    end assign;

;  declare dparam address external;
	extrn	dparam

;  declare rlr address external;
	extrn	rlr

;  declare drl address external;
	extrn	drl

;  declare dlr address external;
	extrn	dlr

;  declare plr address external;
	extrn	plr

;  declare slr address external;
	extrn	slr

;  declare qlr address external;
	extrn	qlr

;  declare thrdrt address external
	extrn	thrdrt

;  declare nmbcns literally '16';
nmbcns	equ	16

;  declare cnsatt (1) address external;
	extrn	cnsatt

;  declare lstatt (1) address external;
	extrn	lstatt

;  declare mpmver address external;
	extrn	mpmver

;  declare cnsque (1) address external;
	extrn	cnsque

;  declare tod structure (
	extrn	tod
;    day address,
;    hr byte,
;    min byte,
;    sec byte ) external;

;  declare nmbflags byte external;
	extrn	nmbflags

;  declare sysfla (1) address external;
	extrn	sysfla

;  declare nmblst byte external;
	extrn	nmblst

;  declare lstque (1) address external;
	extrn	lstque

;  declare sysdat address external;
	extrn	sysdat

;  declare cli$lqcb address external;
	extrn	clilqcb

	dseg
;  declare cli$uqcb userqcbhead
;    initial (.cli$lqcb,0);
;cliuqcb:    /* This data structure has been moved to the stack */
;	dw	clilqcb	; pointer
;	dw	$-$	; msgadr

;  declare rsp$adr address;
rspadr:	ds	2

;  declare rsp$uqcb userqcb
;    initial (0,.rsp$adr,'$$$$$$$$');
rspuqcb:
	dw	$-$	; pointer
	dw	rspadr	; msgadr
	db	'$$$$$$$$'	; name

;  declare cpb$adr address;
cpbadr:	ds	2
;  declare cpb based cpb$adr structure (
;    rsp$name$adr address,
;    rsp$param address);

;  declare flag$wait$function literally '4';
;  declare flag$set$function literally '5';

;  declare (svstk,old$drl,old$thread$root) address;
svstk:	ds	2
olddrl:	ds	2
oldthreadroot:
	ds	2
	cseg

;  xdos:
xdos:
	public	xdos
;    procedure (function,parameter) address reentrant public;
;      declare function byte;
;      declare parameter address;
;      declare ret address;
;      declare pd based parameter process$descriptor;

;      ret = 0000H;
	MOV	A,C
;      function = function - 128;
	SUI	80H
;      if function > max$xdos$function then
	CPI	maxfunc
	LXI	H,0FFFFH
	RNC
;      do;
;        ret = 0FFFFH;
;      end;
;      else
;      do case function;
	CPI	4H
	JZ	@1	; SETUP RETURN TO DISPATCH
	CPI	5H	;  FOR ALL BUT FLAG OP'S
	JZ	@1
	LXI	H,DISPAT
	PUSH	H
@1:
	LXI	H,EXDOS
	PUSH	H
	MOV	B,D
	MOV	C,E
	MOV	E,A
	MVI	D,0
	LXI	H,@37
	DAD	D
	DAD	D
	MOV	E,M
	INX	H
	MOV	D,M
	LHLD	RLR
	INX	H
	INX	H	; HL = .RLR.STATUS
	XCHG
	PCHL

;        /* function = 128, Absolute Memory Request */
;        ret = abs$rq (parameter);
;	CALL	ABSRQ

;        /* function = 129, Relocatable Memory Request */
;        ret = rel$rq (parameter);
;	CALL	RELRQ

;        /* function = 130, Memory Free */
;        call mem$fr (parameter);
;	CALL	MEMFR

;        /* function = 131, Poll Device */
;        do;
@7:
;          enter$region;
	DI
;          dsptch$param = parameter;
	MOV	L,C
	MOV	H,B
	SHLD	DPARAM
;          rlrpd.status = poll$status;
	XCHG
	MVI	M,3H
;        end;
	RET

;        /* function = 132, Flag Wait */
;        ret = flag$wait (parameter);
;	CALL	FLGWT

;        /* function = 133, Flag Set */
;        ret = flag$set (parameter);
;	CALL	FLGSET

;        /* function = 134, Make Queue */
;        ret = makeq (parameter);
;	CALL	MAKEQ

;        /* function = 135, Open Queue */
;        ret = openq (parameter);
;	CALL	OPENQ

;        /* function = 136, Delete Queue */
;        ret = deletq (parameter);
;	CALL	DELETQ

;        /* function = 137, Read Queue */
;        ret = readq (parameter);
;	CALL	READQ

;        /* function = 138, Conditional Read Queue */
;        ret = creadq (parameter);
;	CALL	CREADQ

;        /* function = 139, Write Queue */
;        ret = writeq (parameter);
;	CALL	WRITEQ

;        /* function = 140, Conditional Write Queue */
;        ret = cwriteq (parameter);
;	CALL	CWRITEQ

;        /* function = 141, Delay */
;        do;
@17:
;          enter$region;
	DI
;          dsptch$param = parameter;
	MOV	L,C
	MOV	H,B
	SHLD	DPARAM
;          rlrpd.status = delay$status;
	XCHG
	MVI	M,5H
;        end;
	RET

;        /* function = 142, Dispatch */
;        do;
@18:
;          enter$region;
	DI
;          rlrpd.status = dispatch$status;
	XCHG
	MVI	M,9H
;        end;
	RET

;        /* function = 143, Terminate */
;        do;
@19:
;          call flush$buffers;
	push	b
	push	d
	call	flshbf
	pop	d
	pop	b
;          enter$region;
	DI
;          dsptch$param = parameter;
	MOV	L,C
	MOV	H,B
	SHLD	DPARAM
;          rlrpd.status = terminate$status;
	XCHG
	MVI	M,7H
;        end;
	RET

;        /* function = 144, Create */
;        do;
@20:
;          enter$region;
	DI
;          old$drl = drl;
	LHLD	DRL
	SHLD	OLDDRL
;          old$thread$root = thread$root;
	LHLD	THRDRT
	SHLD	OLDTHREADROOT
;          drl,
;          thread$root = parameter;
	MOV	L,C
	MOV	H,B
	SHLD	DRL
	SHLD	THRDRT
;          do while pd.pl <> 0;
@38:
	MOV	E,M
	INX	H
	MOV	D,M
	MOV	A,E
	ORA	D
	JZ	@39
;            pd.thread = pd.pl;
	LXI	H,12H
	DAD	B
	MOV	M,E
	INX	H
	MOV	M,D
	CALL @39A
;            parameter = pd.pl;
	MOV	B,D
	MOV	C,E
	XCHG
;          end;
	JMP	@38
@39:
;          pd.pl = old$drl;
	XCHG
	LHLD	OLDDRL
	XCHG
	MOV	M,D
	DCX	H
	MOV	M,E
;          pd.thread = old$thread$root;
	LHLD	OLDTHREADROOT
	XCHG
	LXI	H,12H
	DAD	B
	MOV	M,E
	INX	H
	MOV	M,D
@39A:
;            pd.drvacc = 0;
	lxi	h,1ch
	dad	b
	xra	a
	mov	m,a
	inx	h
	mov	m,a
;            pd.multcnt = 1;
	lxi	h,32h
	dad	b
	mvi	m,1
;            pd.pdcnt = 0;
	inx	h
	mov	m,a
;        end;
	RET

;        /* function = 145, Set Priority */
;        do;
@21:
;          enter$region;
	DI
;          dsptch$param = parameter;
	MOV	L,C
	MOV	H,B
	SHLD	DPARAM
;          rlrpd.status = set$prior$status;
	XCHG
	MVI	M,8H
;        end;
	RET

;        /* function = 146, Attach */
;        do;
@22:
;          enter$region;
	DI
;          rlrpd.status = attach$status;
	XCHG
	MVI	M,0AH
;        end;
	RET

;        /* function = 147, Detach */
;        do;
@23:
;          enter$region;
	DI
;          rlrpd.status = detach$status;
	XCHG
	MVI	M,0BH
;        end;
	RET

;        /* function = 148, Set Console */
;        do;
@24:
;          rlrpd.console = parameter;
	lxi	h,0eh-02h
	dad	d	;HL = .rlrpd.console
	mov	a,m
	ani	0f0h
	ora	c
	mov	m,a
	pop	h	;discard EXDOS return
;        end;
	RET

;        /* function = 149, Assign Console */
;        ret = assign (parameter);
;	CALL	ASSIGN

;        /* function = 150, Send CLI Command */
;        do;
@26:
;			+------+
;			|msgadr|
;			+------+
;	Stk Ptr	------->| qptr |
;			+------+

;          cli$uqcb.msgadr = parameter;
	push	b
;          cli$uqcb.pointer = .cli$lqcb;
	lxi	h,clilqcb
	push	h
;          ret = writeq (.cli$uqcb);
	lxi	h,0
	dad	sp
	mov	b,h
	mov	c,l
	call	WRITEQ
	pop	h
	pop	h
	ret
;        end;

;        /* function = 151, Call Resident System Process */
;        do;
@27:
	POP	H	; DISCARD EXDOS RETURN

	mov	h,b
	mov	l,c		;HL = .cpb
;            cpb$adr = parameter;
	mov	c,m
	inx	h
	mov	b,m		;BC = cpb.name
	inx	h
	mov	e,m
	inx	h
	mov	d,m		;DE = cpb.param
	lxi	h,-14
	dad	sp
	sphl			;make room for uqcb+2 on stk
	push	d
;
;	Stack Structure:
;
;	+-----------------------+
;	|   Return Address      |
;	+-----------------------+
;	|                       |
;	  uqcb.name(0) - name(7)
;	|                       |
;	+-----------------------+
;	|   uqcb.msgadr         | ---+
;	+-----------------------+    |
;	|   uqcb.pointer        |    |
;	+-----------------------+    |
;	|  (space for .proc)    | <--+
;	+-----------------------+
;  S--->|   .cpb.param          |
;	+-----------------------+
;
	mov	d,h
	mov	e,l
	inx	h
	inx	h
	inx	h
	inx	h
	mov	m,e
	inx	h
	mov	m,d		;uqcb.msgadr <-
	inx	h
;            call move (8,cpb.rsp$name$adr,.rsp$uqcb.name);
	mvi	e,8
clresploop:
	ldax	b
	mov	m,a
	inx	b
	inx	h
	dcr	e
	jnz	clresploop
;            /* open queue having passed procedure name */
;            if openq(.rsp$uqcb) <> 0ffh then
	lxi	b,-12
	dad	b		;HL = .uqcb
	mov	b,h
	mov	c,l
	call	openq
	inr	a
;            else
;            do;
;              /* procedure not resident */
;              ret = 1;
;            end;
	lxi	h,0001h
	pop	d		;DE = cpb.param
	jz	clrespdone	;queue not found
;            do;
;              /* read queue to get procedure entry point address */
;              call readq (.rsp$uqcb);
	lxi	h,2
	dad	sp
	mov	b,h
	mov	c,l
	push	d
	call	readq		;read proc adr from queue
;              /* execute the procedure (function) */
;              ret = xfunc (cpb.rsp$param,rsp$adr);

	pop	b		;BC = cpb.param
	pop	h		;HL = procadr
	push	h
	lxi	d,clresprtn
	push	d		;setup return addr
	pchl			;call proc (param)
clresprtn:			;return here from proc call
	push	h		;save returned result
;              /* write queue to put message back on queue, this
;                 mechanism makes the procedure a serially
;                 resuseable resource                            */
;              call writeq (.rsp$uqcb);
;            end;
	lxi	h,4
	dad	sp
	mov	b,h
	mov	c,l		;BC = .uqcb
	call	writeq		;write proc adr to queue
	pop	h		;DE = result returned from proc
clrespdone:
	xchg
	lxi	h,14
	dad	sp
	sphl			;discard uqcb on stack
	xchg
;        end;
	ret			;return with HL = proc()

;        /* function = 152, Parse Filename */
;        ret = parse$filename (parameter);
@31:
	POP	H	; DISCARD EXDOS RETURN
	JMP	PARSEFILENAME

;        /* function = 153, Get Console Number */
;        ret = rlrpd.console;
@32:
	LXI	B,0CH
	XCHG
	DAD	B
	MOV	A,M
	ani	0fh
	RET

;        /* function = 154, System Data Address */
;        ret = sysdat;
@33:
	POP	H	; DISCARD EXDOS RETURN
	LHLD	SYSDAT
	RET

;        /* function = 155, Get Time & Date */
;        do;
@34:
;          call move (5,.tod,parameter);
	LXI	D,TOD
	MVI	L,5H
	LDAX	D
	STAX	B
	INX	B
	INX	D
	DCR	L
	JNZ	$-5H
;        end;
	RET

;        /* function = 156, Return Process Descriptor Address */
;	 do;
rtnpdadr:
;          return rlr;
	pop	h	; discard EXDOS return
	lhld	rlr
;        end;
	ret

;        /* function = 157, Abort Specified Process */
;        do;
abort:
;
; BC -> Abort$parameter$control$block
; declare apcb structure (
;   pdadr address,
;   param address,
;   pname (8) byte );
	ldax	b
	inx	b
	mov	e,a
	ldax	b
	inx	b
	mov	d,a
	ora	e	;test for PD address present
	ldax	b
	inx	b
	mov	l,a
	ldax	b
	inx	b
	mov	h,a	;DE = apcb.pdadr, HL = apcb.param
	di
	shld	dparam
	shld	tparam
	jnz	@15	;jump if already have pdadr
;      pdadr = thread$root;
	LHLD	THRDRT
	XCHG
;      do while pdadr <> 0;
@9:
;        i = 1;
	PUSH	B
	LXI	H,6
	DAD	D
	PUSH	H
	MVI	L,8	;** this no longer includes the pd.console byte !
;        do while (i <> 9) and (pd.name(i-1) = pname(i));
@11:
	XTHL
	LDAX	B
	sub	M
	INX	B
	INX	H
	JZ	@11A
	ani	7fh
	jz	@11a	;also don't care on high order bit
	POP	H
	POP	B
	JMP	@6
@11A:
	XTHL
	DCR	L
	JNZ	@11
	xthl		;now test console byte
	ldax	b
	mov	b,a
	mov	a,m
	ani	0fh
	cmp	b
;          i = i + 1;
;        end;
	pop	h
	pop	b
	jz	@15
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
exitabort:
;      return 0FFFFH;
	ei
	mvi	a,0ffh
	RET
@15:
	lxi	h,13
	dad	d
	mov	a,m
	ani	80h
	jnz	@15b	;jump if no abort flag bit set
	push	h
	lxi	h,7
	dad	d
	mov	a,m
	ani	80h
	pop	h
	jz	@15a	;jump if in bdos flag bit not set
	dcx	h
	ora	m
	mov	m,a
	dcx	h
	dcx	h
	dcx	h
	dcx	h
	mov	a,m
	ori	80h
	mov	m,a	;set no sys stk swp flag bit
	dcx	h
	dcx	h
	dcx	h
	dcx	h
	dcx	h
	xra	a
	mov	m,a	;set priority to zero
	ei
	ret
@15b:
	dcx	h
	ora	m
	mov	m,a		;set process abort flag
	jmp	exitabort	;cannot abort
@15a:
	lhld	rlr
	mov	a,e
	cmp	l
	jnz	@16
	mov	a,d
	cmp	h
	jnz	@16
;
; aborting the running process
	inx	h
	inx	h
	mvi	m,7	;set pd.status to terminate
	ret
@16:
	lxi	b,setupabort
	push	b		;setup return address
	lxi	h,2
	dad	d
	mov	c,m
	mvi	b,0
	lxi	h,abtbl
	dad	b
	dad	b
	mov	a,m
	inx	h
	mov	h,m
	mov	l,a
	pchl

abtbl:
	dw	abtrun	; 0 = Ready to run
	dw	abtque	; 1 = DQ
	dw	abtque	; 2 = NQ
	dw	abtpol	; 3 = Poll
	dw	abtflg	; 4 = Flag Wait
	dw	abtdly	; 5 = Delay
	dw	abtswp	; 6 = Swap
	dw	abtrun	; 7 = Terminate
	dw	abtrun	; 8 = Set Priority
	dw	abtrun	; 9 = Dispatch
	dw	abtcns	;10 = Attach
	dw	abtrun	;11 = Detach
	dw	abtcns	;12 = Set Console
	dw	abtlst	;13 = Attach List
	dw	abtrun	;14 = Detach List

;
; 0 Ready to run
; 7 Terminate
; 8 Set Priority
; 9 Dispatch
;11 Detach
;
abtrun:
	pop	h	;discard return addr
	jmp	procrdy	;no action simply setup abort

;
; 1 DQ
; 2 NQ
;
abtque:
	;find queue link & remove
	lxi	b,qlr
abtq0:
	ldax	b
	mov	l,a
	inx	b
	ldax	b
	mov	h,a
	ora	l
	rz		;not DQing or NQing ?
	push	h
	lxi	b,14
	dad	b
	mov	b,h
	mov	c,l
	push	b
	call	delpr
	pop	b
	pop	h
	rc		;return if DQing & removed
	push	h
	inx	b
	inx	b
	call	delpr
	pop	b
	rc		;return if NQing & removed
	jmp	abtq0

;
; 3 Poll
;
abtpol:
	;remove PD from poll list
	lxi	b,plr
	jmp	delpr
	;ret

;
; 4 Flag Wait
;
abtflg:
	;remove PD from flag
	lda	nmbflags
	mov	c,a
	inr	c
	lxi	h,sysfla-1
abtfl0:
	inx	h
	dcr	c
	rz		;not waiting for a flag ?!
	mov	a,e
	cmp	m
	inx	h
	jnz	abtfl0
	mov	a,d
	cmp	m
	jnz	abtfl0
	mvi	m,0ffh
	dcx	h
	mvi	m,0ffh
	ret

;
; 5 Delay
;
abtdly:
	;remove PD from delay list
	lxi	b,dlr
	jmp	delpr
	;ret

;
; 6 Swap
;
abtswp:
	;remove PD from swap list
	lxi	b,slr
	jmp	delpr
	;ret

;
;10 Attach
;12 Set Console
;
abtcns:
	;remove PD from console queue
	mvi	l,nmbcns
	inr	l
	lxi	b,cnsque
abct0:
	dcr	l
	rz		;not queued for any console ?
	push	b
	push	h
	call	delpr
	pop	h
	pop	b
	inx	b
	inx	b
	jnc	abct0
	ret

;
;13 Attach List
;
abtlst:
	;remove PD from list queue
	mvi	l,nmbcns
	inr	l
	lxi	b,lstque
ablt0:
	dcr	l
	rz		;not queued for any list ?
	push	b
	push	h
	call	delpr
	pop	h
	pop	b
	inx	b
	inx	b
	jnc	ablt0
	ret

setupabort:
	;put PD on dispatcher ready list
	lhld	drl
	xchg
	mov	m,e
	inx	h
	mov	m,d
	dcx	h
	shld	drl
	xchg
procrdy:
	;compute process return address location in stack
	;and fill in with address of abort code.
	xchg
	inx	h
	inx	h
	inx	h
	mvi	m,0	;pd.priority = 0
	inx	h	;HL = .pd.stkptr
	mov	e,m
	inx	h
	mov	d,m	;DE = pd.stkptr
	dcx	d
	dcx	d	;DE = pd.stkptr-2 (PUSHed)
	mov	m,d
	dcx	h
	mov	m,e
	inx	h
	inx	h
	inx	h
	inx	h
	mov	a,m
	ori	80h
	mov	m,a
	lhld	tparam
	xchg
	lxi	b,abortcode
	mov	m,c
	inx	h
	mov	m,b
	inx	h
	mov	m,e
	inx	h
	mov	m,d
	ei
	xra	a
	ret

abortcode:
	di
	mvi	c,143
	pop	d
	jmp	xdos

	dseg
tparam:	ds	2
	cseg

;        end;


;        /* function = 158, Attach List */
;        do;
@40:
;          enter$region;
	DI
;          rlrpd.status = attach$list$status;
	XCHG
	MVI	M,0DH
;        end;
	RET

;        /* function = 159, Detach List */
;        do;
@41:
;          enter$region;
	DI
;          rlrpd.status = detach$list$status;
	XCHG
	MVI	M,0EH
;        end;
	RET

;        /* function = 160, Set List */
;        do;
@42:
;          rlrpd.console = parameter;
	mov	a,c
	ral
	ral
	ral
	ral
	mov	c,a
	lxi	h,0eh-02h
	dad	d	;HL = .rlrpd.console
	mov	a,m
	ani	0fh
	ora	c
	mov	m,a
	pop	h	;discard EXDOS return
;        end;
	RET

;        /* function = 161, Conditional Attach List */
;        do;
@43:
;          enter$region;
	DI
	lhld	rlr
	xchg		;DE = Ready List Root
	lxi	h,0eh	;rlrpd.console offset
	dad	d
	mov	a,m
	ani	0f0h
	rrc
	rrc
	rrc
	rrc
	lxi	h,lstatt
	jmp	attcmn
;        end;
	RET

;        /* function = 162, Conditional Attach Console */
;        do;
@44:
;          enter$region;
	DI
	lhld	rlr
	xchg		;DE = Ready List Root
	lxi	h,0eh	;rlrpd.console offset
	dad	d
	mov	a,m
	ani	0fh
	lxi	h,cnsatt
attcmn:
	add	a
	mov	c,a
	mvi	b,0
	dad	b
	mov	a,m
	cmp	e
	inx	h
	jnz	@44a
	mov	a,m
	cmp	d
	jz	@44b
@44a:
	mov	a,m
	dcx	h
	ora	m	;testing for non-attached
	jnz	@44b
	mov	m,e
	inx	h
	mov	m,d
	xra	a
@44b:
	mvi	a,0
	rz
	dcr	a
;        end;
	RET

;        /* function = 163, Return MP/M Version Number */
;        do;
@45:
	pop	h	;discard EXDOS return
	lhld	mpmver
;        end;
	RET

;        /* function = 164, Get List Number */
;        ret = rlrpd.console$list;
@46:
	LXI	B,0CH
	XCHG
	DAD	B
	MOV	A,M
	rlc
	rlc
	rlc
	rlc
	ani	0fh
	RET

;      end; /* case */
@37:
	DW	ABSRQ
	DW	RELRQ
	DW	MEMFR
	DW      @7
	DW	FLGWT
	DW	FLGSET
	DW	MAKEQ
	DW	OPENQ
	DW	DELETQ
	DW	READQ
	DW	CREADQ
	DW	WRITEQ
	DW	CWRITEQ
	DW      @17
	DW      @18
	DW      @19
	DW      @20
	DW      @21
	DW      @22
	DW      @23
	DW      @24
	DW	ASSIGN
	DW      @26
	DW      @27
	DW	@31
	DW      @32
	DW      @33
	DW      @34
	dw	rtnpdadr
	dw	abort
	dw	@40
	dw	@41
	dw	@42
	dw	@43
	dw	@44
	dw	@45
	dw	@46
maxfunc	equ	($-@37)/2

;      if function <> flag$set$function then
;      do;
;        if function <> flag$wait$function then
;        do;
;          call dispatch;
;        end;
;      end;
;      return ret;
EXDOS:
	MVI	H,0
	MOV	L,A
	RET
;    end xdos;

delpr0:
	mov	b,h
	mov	c,l
;  delete$process:
;    procedure (nxtpdladr,pdadr) public;
delpr:
	public	delpr
;      declare (nxtpdladr,pdadr) address;
;      declare pdladr based nxtpdladr address;
	ldax	b
	mov	l,a
	inx	b
	ldax	b
	dcx	b
	mov	h,a
	ora	l
	rz		;end of list with no match
	mov	a,l
	cmp	e
	jnz	delpr0
	mov	a,h
	cmp	d
	jnz	delpr0
	mov	a,m	;found match, update pointers
	stax	b
	inx	h
	inx	b
	mov	a,m
	stax	b
	stc		;indicate success
	ret
;end xdos;
	END
