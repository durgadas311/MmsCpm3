	title	 'MP/M II V2.0 Main Program'
	name	'mpm'

	dseg
@@mpm:
	public	@@mpm
	cseg
;mpm:
@mpm:
	public	@mpm
;do;

;$include (copyrt.lit)

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
;$include (proces.lit)
;$nolist
;$include (queue.lit)
;$nolist
;$include (xdos.lit)
;$nolist
;$include (xdos.ext)
;$nolist
;$include (bdosi.ext)
;$nolist
;$include (datapg.ext)
;$nolist

;  xdos:
	extrn	xdos
;    procedure (func,info) address external;
;      declare func byte;
;      declare info address;
;    end xdos;

;  syinit:
	extrn	syinit
;    procedure external;
;    end syinit;

;  xidle:
	extrn	xidle
;    procedure external;
;    end xidle;

;  xbdos:
	extrn	xbdos
;    procedure (func,info) address external;
;      declare func byte;
;      declare info address;
;    end xbdos;

;  maxcns:
	extrn	maxcns
;    procedure byte external;
;    end maxcons;

;  declare datapg (1) byte external;
	extrn	datapg

;  declare sysdat address external;
	extrn	sysdat

;  declare rlr address external;
	extrn	rlr

;  declare qlr address external;
	extrn	qlr

;  declare nmb$segs byte external;
	extrn	nmbsegs

;  declare nmb$cns byte external;
	extrn	nmbcns

;  declare nmb$lst byte external;
	extrn	nmblst

;  declare m$seg$tbl (1) structure (
	extrn	msegtbl
;    base byte,
;    size byte,
;    attrib byte,
;    bank byte  );


;/*
;  Init Process Data Segment
;
; *** Note:
;	Portions of the following 'data' have been moved into csegs
;  for the purposes of combining all the initialization code and data
;  together in one place so that it can be overlayed by the user
;  process stack table.
;
;
;  declare stktbl (max$usr$pr)
;    structure (loc (10) address) public;
stktbl:
	public	stktbl
;
;
;*/
;  declare init$pd process$descriptor
;    initial (idlepd,rtr$status,254,0,'Init    ',0,0ffh,0,0,0080h,0);
	public	initpd
initpd:
	dw	idlepd	; pl
	db	0	; status
	db	254	; priority
	dw	0	; stkptr
	db	'Init    '	; name
	db	$-$	; console
	db	0ffh	; memseg (system)
	dw	$-$	; b
	dw	$-$	; thread
	dw	0080h	; disk set DMA
	db	$-$	; disk select / user code
	dw	$-$	; dcnt
	db	$-$	; searchl
	dw	$-$	; searcha
	ds	2	; drvact
	ds	20	; registers
	ds	2	; scratch

;  declare init$stk (24) address
;    initial (restarts,0C7C7H);
;  /* this stack area is in the system data page */

	dseg
;/*
;  Idle Process Data Segment
;*/
;  declare idle$pd process$descriptor
;    initial (0,rtr$status,255,.idlentrypt,'Idle    ',0,0ffh,0,0,0080h,0);
	public	idlepd
idlepd:
	dw	$-$	; pl
	db	0	; status
	db	255	; priority
	dw	idlentrypt	; stkptr
	db	'Idle    '	; name
	db	$-$	; console
	db	0ffh	; memseg (system)
	dw	$-$	; b
	dw	$-$	; thread
	dw	0080h	; disk set DMA
	db	$-$	; disk select / user code
	dw	$-$	; dcnt
	db	$-$	; searchl
	dw	$-$	; searcha
	ds	2	; drvact
	ds	20	; registers
	ds	2	; scratch

;  declare idle$stk (10) address
;    initial (restarts,0C7C7H);
	public	idlestk
idlestk:
	dw	0c7c7h,0c7c7h,0c7c7h
	dw	0c7c7h,0c7c7h,0c7c7h
	dw	0c7c7h,0c7c7h,0c7c7h
idlentrypt:
	dw	idle

	cseg

;  declare tmp$pd$adr address;
tmppdadr:
	ds	2
;  declare tmp$pd based tmp$pd$adr process$descriptor;
;  declare tmp$stk$adr address;
tmpstkadr:
	ds	2
;  declare tmp$stk based tmp$stk$adr (114) address;
;  declare sys$dat based tmp$pd$adr (1) byte;

;  declare console$dat$adr address;
consoledatadr:
	ds	2

	dseg

;  declare disk$mx userqcb public
;    initial (0,0,'MXDisk  ');
diskmx:
	public	diskmx
	dw	$-$	; pointer
	dw	$-$	; msgadr
	db	'MXDisk  '	; name

;  declare list$mx userqcb public
;    initial (0,0,'MXList  ');
listmx:
	public	listmx
	dw	$-$	; pointer
	dw	$-$	; msgadr
	db	'MXList  '	; name

	cseg

;  memory descriptor offsets:
size	equ	0001h
attrib	equ	0002h
bank	equ	0003h


;/*
;  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;         Idle Program

;  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;*/

;  declare ret byte;
;  declare (i,j) byte;
i:	ds	1
j:	ds	1

;  declare tick$pd process$descriptor external;
	extrn	tickpd

;  declare rspladr address;
rspladr:
	ds	2
;  declare rspl based rspladr address;
;  declare temp address;
temp:	ds	2

;  declare mem$segs$adr address;
memsegsadr:
	ds	2
;  declare mem$segs based mem$segs$adr (1) byte;
;  declare mem$banks$adr address;
membanksadr:
	ds	2
;  declare mem$banks based mem$banks$adr (1) byte;

;  declare template (16) byte initial (
;    0,0,0,198,0,0,'Tmpx   ',' '+80h,0,0ffh);
template:
	dw	$-$	; pl
	db	0	; status
	db	198	; priority
	dw	$-$	; stkptr
	db	'Tmpx   ',' '+80h ; name
	db	$-$	; console
	db	0	; banked OS

;  mpm:
mpm:
	public	mpm
;    procedure public;

;      stackptr = .init$stk+48;
;      rlr = .init$pd;
	lhld	sysdat
	mvi	l,245
	lxi	d,xbdos
	mov	m,e
	inx	h
	mov	m,d

	mvi	l,0f0h
	sphl		; stackptr = sysdat + f0h
;      call syinit;

	CALL	SYINIT
;      ret = xdos (open$queue,.disk$mx);
	LXI	D,DISKMX
	MVI	C,87H
	CALL	XDOS
;      ret = xdos (open$queue,.list$mx);
	LXI	D,LISTMX
	MVI	C,87H
	CALL	XDOS

;      ret = xdos (create,.tick$pd);
	LXI	D,TICKPD
	MVI	C,90H
	CALL	XDOS
;      ret = xdos (create,.clock$pd);
;      ret = xdos (create,.cli$pd);
;      ret = xdos (create,.attch$pd);

;      rspladr = (tmp$pd$adr:=xdos (system$data$adr,0)) + 252;

;      /* system$data(252-253) = address of data page */
	lhld	sysdat
	mov	a,h
	mvi	l,243
	mov	h,m
	mvi	l,0
	SHLD	TMPPDADR
	mov	h,a
	mvi	l,244
	mov	h,m
	mvi	l,0
	shld	consoledatadr
	mov	h,a

;      rspl = .datapg;

;      /* system$data(15) = max memory segment followed by table */
	mvi	l,0fch
	LXI	B,DATAPG
	MOV	M,C
	INX	H
	MOV	M,B
;      mem$segs$adr = tmp$pd$adr + 15;

;      /* system$data(32) = memory bank table */
	mvi	l,0fh
	SHLD	MEMSEGSADR
;      mem$banks$adr = tmp$pd$adr + 32;

;      /* system$data(254-255) = resident system process list head */
	mvi	l,20h
	SHLD	MEMBANKSADR
;      rspladr = rspladr + 2;
	mvi	l,0feh
	SHLD	RSPLADR

;      /* setup the memory segment table */
;      nmb$segs = mem$segs(0);
	LHLD	MEMSEGSADR
	MOV	A,M
	STA	NMBSEGS
	INX	H
	XCHG		; DE = .MEM$SEGS(1)
	LXI	H,MSEGTBL ; HL = .MEM$SEG$TBL(0).BASE
;      do i = 1 to nmb$segs;
	RLC
	RLC
	MOV	C,A
@4:
;        mem$seg$tbl(i-1).base = mem$segs(i);
;        mem$seg$tbl(i-1).size = mem$size(i-1);
;        mem$seg$tbl(i-1).attrib = mem$attribs(i-1);;
;        mem$seg$tbl(i-1).bank = mem$banks(i-1);
	LDAX	D
	MOV	M,A
	INX	H
	INX	D
;      end;
	DCR	C
	JNZ	@4

;      call bdos (disk$reset);
	mvi	c,0dh
	call	xbdos

	lhld	rspladr
;      temp = rspl;

;      /* create the processes on the resident system process
;         list and set the first two bytes of the PRL to xbdos adr */
	MOV	E,M
	INX	H
	MOV	D,M
	XCHG
	SHLD	TEMP
;      do while temp <> 0;
@2:
	LHLD	TEMP
	MOV	A,H
	ORA	L
	JZ	@3
;        rspladr = temp;
	SHLD	RSPLADR
;        temp = rspl;
	MOV	E,M
	INX	H
	MOV	D,M
	XCHG
	SHLD	TEMP
;        rspl = .xbdos;
	LXI	B,XBDOS
	XCHG
	MOV	M,B
	DCX	H
	MOV	M,C
;        ret = xdos (create,rspladr + 2);
	INX	H
	INX	H
	XCHG
	MVI	C,90H
	CALL	XDOS
;      end;
	JMP	@2
@3:
;      nmb$lst = sysdat(197);
	LHLD	sysdat
	mvi	l,197
	mov	a,m
	sta	nmb$lst

;      /* see if consoles configured > max physical consoles */
;      if (nmb$cns:=sys$dat(1)) > maxcns then
	CALL	MAXCNS
	LHLD	sysdat
	inx	h
	CMP	M
	JC	@1
	MOV	A,M
;      do;
;        nmb$cns = maxcns;
@1:
	STA	NMBCNS
;      end;

;      /* create TMP process descriptors, one per console */
;      i = nmb$cns;
	STA	I
;      do while i <> 0;
@6:
	LDA	I
	ORA	A
	JZ	@7
;        tmp$stk$adr = .tmp$pd.scratch(0);
	lhld	consoledatadr
	mvi	l,34h
	shld	tmpstkadr
;        call move (16,.template,.tmp$pd);
	lhld	tmppdadr
	xchg
	LXI	B,TEMPLATE
	MVI	L,10H
	LDAX	B
	STAX	D
	INX	B
	INX	D
	DCR	L
	JNZ	$-5H
;        tmp$pd.stkptr = .tmp$stk(101);
	LXI	B,0CAH
	LHLD	TMPSTKADR
	DAD	B
	MOV	B,H
	MOV	C,L
	LHLD	TMPPDADR
	XCHG
	LXI	H,4H
	DAD	D
	MOV	M,C
	INX	H
	MOV	M,B
;        i = i - 1;
	LXI	H,I
	DCR	M
;        tmp$pd.name(3) = i + '0';
	MOV	A,M
	MOV	B,A
	ADI	30H
	LXI	H,9H
	DAD	D
	MOV	M,A
;        tmp$pd.console = i;
	LXI	H,0EH
	DAD	D
	MOV	M,B
;        tmp$pd.disk$slct = i;
	LXI	H,16H
	DAD	D
	MOV	M,B
;        do j = 0 to 100;
	MVI	C,202
	LHLD	TMPSTKADR
@8:
;          tmp$stk(j) = 0C7C7H;
	MVI	M,0C7H
	INX	H
;        end;
	DCR	C
	JNZ	@8
;        tmp$stk(101) = .tmp;
	lxi	b,sysdat+1
	ldax	b
	mov	b,a
	mvi	c,247
	ldax	b
	mov	b,a
	mvi	c,2
	MOV	M,C
	INX	H
	MOV	M,B

	lhld	consoledatadr
	inr	h
	shld	consoledatadr

;        ret = xdos (create,.tmp$pd);
	LHLD	TMPPDADR
	XCHG
	lxi	h,64
	dad	d
	shld	tmppdadr

	MVI	C,90H
	CALL	XDOS
;      end;
	JMP	@6
@7:

;      /* Terminate the initialization process */
;      ret = xdos (terminate,0ffh);
	MVI	C,8FH
	MVI	E,0FFH
	JMP	XDOS

;      /*  Idle Process */
idle:
;      do forever;
;        call xidle;
	CALL	XIDLE
;      end;
	JMP	idle

;    end mpm;
;end mpm;
	END
