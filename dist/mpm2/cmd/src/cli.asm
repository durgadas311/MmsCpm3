	title	'MP/M II V2.0 Command Line Interpreter'
	name	'cli'
	dseg
@@cli:
	public	@@cli
	cseg
;cli:
@cli:
	public	@cli
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
;$include (proces.lit)
;$nolist
;$include (queue.lit)
;$nolist
;$include (fcb.lit)
;$nolist
;$include (xdos.lit)
;$nolist
;$include (memmgr.lit)
;$nolist
;$include (memmgr.ext)
;$nolist
;$include (xdos.ext)
;$nolist
;$include (bdos.ext)
;$nolist
;$include (bdosi.ext)
;$nolist
;$include (datapg.ext)
;$nolist

;  declare sysdat address external;
	extrn	sysdat

;  declare msegtbl address(8) external;
	extrn	msegtbl

;  declare stktbl (1) structure (loc (10) address) external;
	extrn	stktbl

;  declare pdtbl (1) structure (process$descriptor) external;
	extrn	pdtbl

;  declare console$attached (1) address external;
	extrn	cnsatt

;  declare list$attached (1) address external;
	extrn	lstatt

;  declare rlr address external;
	extrn	rlr

;  declare rlrpd based rlr process$descriptor;

;  assign:
	extrn	assign
;    procedure (nameadr) byte external;
;      declare nameadr address;
;    end assign;

;  dispatch:
	extrn	dispatch
;    procedure external;
;    end dispatch;

;  parsefilename:
	extrn	parsefilename
;    procedure (pcb$address) address external;
;      declare pcb$address address;
;    end paresefilename;

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

;  readq:
	extrn	readq
;    procedure (uqcbadr) byte external;
;      declare uqcbadr address;
;    end readq;

;  cwriteq:
	extrn	cwriteq
;    procedure (uqcbadr) byte external;
;      declare uqcbadr address;
;    end cwriteq;

;  detach:
	extrn	detach
;    procedure external;
;    end detach;

;  detlst:
	extrn	detlst
;    procedure (pdadr) external;
;      declare pdadr address;
;    end detlst;

;  xbdos:
	extrn	xbdos
;    procedure (func,info) address external;
;      declare func byte;
;      declare info address;
;    end xbdos;

;  xdos:
	extrn	xdos
;    procedure (func,info) address external;
;      declare func byte;
;      declare info address;
;    end xdos;

;  endp:
	extrn	endp
;    procedure external;
;    end endp;

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

;  co:
	extrn	co
;    procedure (char);
;      declare char byte;
;    end co;

;  printb:
	extrn	printb
;    procedure (msgadr);
;      declare msgadr address;
;    end printb;

;  crlf:
	extrn	crlf
;    procedure;
;    end crlf;

;  crlfprintb:
crlfprintb:
;    procedure (msgadr);
;      declare msgadr address;
	push	b
	lhld	sysdat
	lda	pname	;console #
	adi	128
	mov	l,a
	mvi	m,0
	call	crlf
	pop	b
	jmp	printb
;    end crlfprintb;

;  open:
	extrn	open
;    procedure (fcbadr) byte;
;      declare fcbadr address;
;    end open;

;  close:
	extrn	close
;    procedure (fcbadr) byte;
;      declare fcbadr address;
;    end close;

;  readbf:
	extrn	readbf
;    procedure (fcbadr) byte;
;      declare fcbadr address;
;    end readbf;

;  setdma:
	extrn	setdma
;    procedure (dmaadr) external;
;      declare dmaadr address;
;    end setdma;

;  remfl:
	extrn	remfl
;    procedure external;
;    end remfl;

	dseg
;  declare reserved$for$disk (3) byte;
	ds	3
;  declare buffer (128) byte;
buffer:	ds	128

;  declare pname (10) byte initial (
;    0,'        ',0);
pname:
	db	0
	db	'        '
	db	0

;/*
;  CLI Process Data Segment
;*/
;  declare cli$pd process$descriptor public
;    initial (0,rtr$status,200,.cli$entrypt,
;             'c'+80h,'l','i'+80h,'  ',' '+80h,'  ',0,0ffh,0,0,.buffer,0);
clipd: 
	public	clipd
	extrn	attchpd
	dw	attchpd	; pl
	db	0	; status
	db	200	; priority
	dw	clientrypt	; stkptr
	db	'c'+80h,'l','i'+80h,'  ',' '+80h,' ',' '+80h ; name
cliabort equ	$-2	; pd.name(6)- high order bit
cli$console:
	db	$-$	; console
cli$memseg:
	db	0ffh	; memseg (system)
	dw	$-$	; b
	dw	$-$	; thread
	dw	buffer	; disk set DMA
cli$slct$user:
	db	$-$	; disk select / user code
	dw	$-$	; dcnt
	db	$-$	; searchl
	dw	$-$	; searcha
cli$pdcnt:
	ds	2	; drvact
	ds	20	; registers
	ds	2	; scratch

;  declare cli$stk (25) address
;    initial (restarts,.cli);
clistk:
	dw	0c7c7h,0c7c7h,0c7c7h
	dw	0c7c7h,0c7c7h,0c7c7h
	dw	0c7c7h,0c7c7h,0c7c7h
	dw	0c7c7h,0c7c7h,0c7c7h
	dw	0c7c7h,0c7c7h,0c7c7h
	dw	0c7c7h,0c7c7h,0c7c7h
	dw	0c7c7h,0c7c7h,0c7c7h
	dw	0c7c7h,0c7c7h,0c7c7h
clientrypt:
	dw	cli

;  declare cli$lqcb
;    structure (lqueue,
;               buf (131) byte) public
;    initial (0,'CliQ    ',129,1);
clilqcb:
	public	clilqcb
	dw	$-$	; ql
	db	'CliQ    '	; name
	dw	129	; msglen
	dw	1	; nmbmsgs
	dw	$-$	; dqph
	dw	$-$	; nqph
	dw	$-$	; mh
	dw	$-$	; mt
	dw	$-$	; bh
	ds	131	; buf (131) byte

;  declare CLIQ userqcbhead
;    initial (.cli$lqcb,.field);
cliq:
	dw	clilqcb	; pointer
	dw	field	; msgadr

;  declare pcb structure (
;    field$adr address,
;    fcb$adr address );
pcb:
	ds	2	; fieldadr
	ds	2	; fcbadr

;  declare field (129) byte;
field:	ds	129
;  declare disk$select byte at (.field);
diskselect	equ	field
;  declare console byte at (.field(1));
console	equ	field+1
;  declare command$tail (1) byte at (.field(2));
commandtail	equ	field+2

;  declare fcb fcb$descriptor;
fcb:
	db	$-$	; et
	db	'        '	; fn
	db	'   '	; ft
	db	$-$	; ex
	dw	$-$	; nu
	db	$-$	; rc
	ds	16	; dm
	db	$-$	; nr

;  declare cusp$uqcb userqcb initial (
;    0,.field,'$$$$$$$$');
cuspuqcb:
	dw	$-$	; pointer
	dw	field	; msgadr
	db	'$$$$$$$$'	; name

;  declare nxt$chr$adr address;
nxtchradr:
	ds	2

;  declare ret byte;

;  declare md memory$descriptor;
md:
	db	$-$	; base
	db	$-$	; size
	db	$-$	; attrib
	db	$-$	; bank

;  declare pdadr address;
pdadr:	ds	2
;  declare pd based pdadr process$descriptor;

;  declare (base,top) address;
base:	ds	2
top:	ds	2

;  declare (i,j) address;
;i:	ds	2
;j:	ds	2

;  declare (mask,prl,ok,notdone) byte;
;mask:	ds	1
prl:	ds	1
;ok:	ds	1
;notdone:	ds	1

;  declare sysdriveadr address;
;  declare sysuser based sysdriveadr byte;
sysdriveadr: ds	2

;  declare dayfileadr address;
;  declare dayfile based dayfileadr byte;
dayfileadr:  ds	2

;  declare todadr address;
;  declare tod based todadr byte;
todadr:  ds	2

;  declare drive byte;
drive:	ds	1

;  declare dfltdrive byte;
dfltdrive:	ds	1

;  declare notsyspass boolean;
notsyspass:  ds	1

;  declare chain$seg byte;
chainseg: ds	1

;  declare sector$size literally '0080H';

;  declare user$priority literally '200';

;  declare segment$bottom address;
segmentbottom:
	ds	2

;  declare offset address;
;offset:	ds	2

;  declare data$size address;
;datasize:
;	ds	2

;  declare mem$pointer address;
;mempointer:
;	ds	2
;  declare instr based mem$pointer byte;
;  declare location based mem$pointer address;
;  declare array based mem$pointer (1) byte;

;  declare bitmap$adr address;
;bitmapadr:
;	ds	2
;  declare bitmap based bitmap$adr (1) byte;

;  declare prl$code$adr address;
prlcodeadr:
	ds	2
;  declare prl$code based prl$code$adr (1) byte;

;  declare prlen address;
prlen:
	ds	2

	cseg
;  declare tfcb$default (50) byte data (
tfcbdefault:
	db	0
	db	0,0,0,0,0,0,0,0,0,0,0
	db	0,'        ','   '
	db	0,0,0,0
	db	0,'        ','   '
	db	0,0,0,0
	db	0,0,0,0,0,0
;      /* setup
;               tdrv:    0050H - 0050H = 0
;		tptpw:   0051H - 0052H = 0
;		tnpw:    0053H - 0053H = 0
;		tptpw+16:0054H - 0055H = 0
;		tnpw+16: 0056H - 0056H = 0
;              (unused)  0057H - 005BH = 0
;               tfcb:    005CH - 005CH = 0
;                        005DH - 0067H = ' '
;                        0068H - 006BH = 0
;               tfcb+16: 006CH - 006CH = 0
;                        006DH - 0077H = ' '
;                        0078H - 007BH = 0
;                        007CH - 007FH = 0
;               tbuff:   0080H - 0081H = 0  */

plderr:
	db	'Prg ld err'
	db	'$'

cliabt:
	db	'Cli abort'
	db	'$'

abstpana:
	db	'Abs TPA not free'
	db	'$'

insufrm:
	db	'Reloc seg not free'
	db	'$'

badprlhr:
	db	'Bad PRL hdr rec'
	db	'$'

fltypblnk:
	db	'Blnk file type rqd'
	db	'$'

quefull:
	db	'Queue full'
	db	'$'

illegal:
	db	'Bad entry'
	db	'$'

chainComtoPrl:
	db	'Chain COM to PRL'
	db	'$'

msgqued:
	db	'Msg Qued'
	db	0dh,0ah
	db	'$'

user0:
	db	'  (User 0)'
	db	'$'

;  pmove:
pmove:
	; BC = COUNT, DE = SOURCE ADR, HL = DEST ADR
;    procedure (n,s$adr,d$adr);
;      declare (n,s$adr,d$adr) address;
;      declare s based s$adr byte;
;      declare d based d$adr byte;

;      n = n + 1;
;      do while (n := n - 1) <> 0;
@38:
	MOV	A,B
	ORA	C
	RZ
;        d = (s and 7fh);
	ldax	d
	ani	7fh
	mov	m,a
;        if s >= 'a' and s <= 'z'
	CPI	'a'
	JC	@2
	CPI	'z'+1
	JNC	@2
;          then d = s and 101$1111b;  /* force upper case */
	ANI	5FH
	MOV	M,A
;          else d = s;
@2:
;        s$adr = s$adr + 1;
	INX	D
;        d$adr = d$adr + 1;
	INX	H
;      end;
	DCX	B
	JMP	@38
;    end pmove;

;;;  bmove:
;;bmove:
;;	; BC = COUNT, DE = SOURCE ADR, HL = DEST ADR
;;;    procedure (n,s$adr,d$adr);
;;;      declare (n,s$adr,d$adr) address;
;;;      declare s based s$adr byte;
;;;      declare d based d$adr byte;
;;
;;;      n = n + 1;
;;;      do while (n := n - 1) <> 0;
;;@39:
;;	MOV	A,B
;;	ORA	C
;;	RZ
;;	LDAX	D
;;	MOV	M,A
;;;        d = s;
;;;        s$adr = s$adr + 1;
;;	INX	D
;;;        d$adr = d$adr + 1;
;;	INX	H
;;;      end;
;;	DCX	B
;;	JMP	@39
;;;    end bmove;

;  setup$base$page:
setupbasepage:
;    procedure;

;      /* place a jump to xdos in the top three bytes
;         of the memory segment                       */
;      base,
;      mem$pointer = top - 3;
	LHLD	TOP
	DCX	H
	DCX	H
	DCX	H
	SHLD	BASE
;      instr = 0C3H;
	MVI	M,0C3H
;      mem$pointer = mem$pointer + 1;
	INX	H
;      location = .xbdos;

;      /* place a jump to the termination procedure (ENDP)
;         at the first three bytes of the memory segment  */
	LXI	B,XBDOS
	MOV	M,C
	INX	H
	MOV	M,B
;      if (mem$pointer := segment$bottom) <> 0000H then
	LHLD	SEGMENTBOTTOM
	MOV	A,H
	ORA	L
	JZ	@3
;      do;
;        instr = 0C3H;
	MVI	M,0C3H
;        mem$pointer = mem$pointer + 1;
	INX	H
;        location = .endp;
	LXI	B,ENDP
	MOV	M,C
	INX	H
	MOV	M,B
;        mem$pointer = mem$pointer + 3;
	inx	h
	inx	h
;        array(0) = shr(disk$select,4);
	lda	diskselect
	ani	0f0h
	rrc
	rrc
	rrc
	rrc
	mov	m,a
;      end;

;      /* place a jump to the mem segment top - 3 into
@3:
;         the normal bdos jump at mem segment 0005H    */
;      mem$pointer = segment$bottom + 5;
	LXI	D,5H
	LHLD	SEGMENTBOTTOM
	DAD	D
;      instr = 0C3H;
	MVI	M,0C3H
;      mem$pointer = mem$pointer + 1;
	INX	H
;      location = base;
	XCHG
	LHLD	BASE
	XCHG
	MOV	M,E
	INX	H
	MOV	M,D
;    end setup$base$page;
	RET

;  parse$command$tail:
parsecommandtail:
;    procedure;

;      call pmove (128-(nxt$chr$adr-.command$tail),nxt$chr$adr,
	LHLD	NXTCHRADR
	XCHG
	MOV	A,E
	lxi	h,commandtail
	sub	l		;only need 8-bit arith.
	MOV	B,A
	MVI	A,80H
	SUB	B
	LXI	B,0014H
	LHLD	PDADR
	DAD	B
	MOV	C,M
	INX	H
	MOV	H,M
	MOV	L,C
	PUSH	H
	INX	H
	MOV	C,A
	MVI	B,0
	CALL	PMOVE
	POP	H
	PUSH	H
;                 (mem$pointer := pd.disk$set$dma+1));
;      j = 0;
	MVI	B,0FFH
;      do while instr <> 0;
@40:
	INX	H
	INR	B
	MOV	A,M
	ORA	A
	JNZ	@40
;        mem$pointer = mem$pointer + 1;
;        j = j + 1;
;      end;
;      mem$pointer = pd.disk$set$dma;
	POP	H
;      instr = j;
	MOV	M,B
;      pcb.field$adr = mem$pointer;
	inx	h
	SHLD	PCB
;      pcb.fcb$adr = segment$bottom + 5CH;
	LXI	D,5CH
	LHLD	SEGMENTBOTTOM
	DAD	D
	SHLD	PCB+2H
;      if (nxt$chr$adr := xdos (parse$fname,.pcb)) <> 0FFFFH then
	LXI	B,PCB
	CALL	PARSEFILENAME
	SHLD	NXTCHRADR
	INX	H
	MOV	A,H
	ORA	L
	RZ
;      /* valid first file name in command tail */
;      do;
;        call b3move (pcb.fcb$adr+24,segment$bottom+51h)
	lhld	pcb+2h
	lxi	b,24
	dad	b
	xchg
	lhld	segmentbottom
	lxi	b,51h
	dad	b
	call	b3move
;        if nxt$chr$adr <> 0 then
	lhld	nxtchradr
	MOV	A,H
	ORA	L
	xchg
	jnz	@41
	lhld	pcb+2h
	lxi	d,16
	dad	d
	mvi	m,0
	inx	h
	mvi	m,' '
	ret
@41:
;        /* parse second file name in command tail */
;        do;
;          pcb.field$adr = nxt$chr$adr + 1;
	xchg
	INX	H
	SHLD	PCB
;          pcb.fcb$adr = buffer;
	lxi	h,buffer
	SHLD	PCB+2H
;          nxt$chr$adr = xdos (parse$fname,.pcb);
	LXI	B,PCB
	CALL	PARSEFILENAME
;          if nxt$chr$adr <> 0ffffh then
	inx	h
	mov	a,h
	ora	l
	rz
;          do;
;            call pmove (16,.buffer,segment$bottom+6ch);
	lxi	b,16
	lxi	d,6ch
	lhld	segmentbottom
	dad	d
	lxi	d,buffer
	call	pmove
;            call pmove (3,.buffer+24,segment$bottom+54h);
	lxi	b,54h
	lhld	segmentbottom
	dad	b
	lxi	d,buffer+24
;	jmp	pmove
;        end;
;      end;
;    end parse$command$tail;
;	RET

;	Note: fall thru from parse$command$tail
b3move:
	ldax	d
	mov	m,a
	inx	d
	inx	h
	ldax	d
	mov	m,a
	inx	d
	inx	h
	ldax	d
	mov	m,a
	ret


;  relocate:
relocate:
;    procedure;

;      /* offset by base of reloc memseg */
;      offset = md.base;
;      /* bitmap directly follows last byte of code */
	LDA	MD
	MOV	B,A
;      bitmap$adr = .prl$code + prlen;
	LHLD	PRLEN
	XCHG
	LHLD	PRLCODEADR
	PUSH	H
	DAD	D
;      prlen = prlen - 1;
;      j = 0;
;      mask = 80H;
;      /* loop through entire bit map */
	MVI	C,80H
;      do i = 0 to prlen;
	; B = OFFSET, C = MASK, DE = PRLEN, HL = BITMAPADR
	; TOS = PRLCODEADR
@42:
;        if (bitmap(j) and mask) <> 0 then
	MOV	A,M
	ANA	C
	XTHL
	JZ	@6
;        /* offset the byte where a bitmap bit is on */
;        do;
;          prl$code(i) = prl$code(i) + offset;
	MOV	A,M
	ADD	B
	MOV	M,A
;        end;
@6:
	INX	H
	XTHL
;        /* move mask bit one position to the right */
;        if (mask := shr(mask,1)) = 0 then
	MOV	A,C
	RAR
	MOV	C,A
	JNC	@7
;        /* re-initialize mask and get next bitmap byte */
;        do;
;          mask = 80H;
	MVI	C,80H
;          j = j + 1;
	INX	H
;        end;
@7:
;      end;
	DCX	D
	MOV	A,D
	ORA	E
	JNZ	@42
;    end relocate;
	POP	H
	RET

;  pd$init:
pdinit:
;    procedure;

;      pd.pl = 0;
	LHLD	PDADR
	XRA	A
	MOV	M,A
	INX	H
	MOV	M,A
;      pd.status = rtr$status;
	INX	H
	MOV	M,A
;      pd.priority = user$priority;
	INX	H
	MVI	M,0C8H
	XCHG
;      pd.stkptr = .stktbl(rlrpd.memseg).loc(18);
	lda	cli$memseg
	LXI	B,0014H
	LXI	H,STKTBL-4
	INR	A
@MPM0:
	DAD	B
	DCR	A
	JNZ	@MPM0
	XCHG
	INX	H
	MOV	M,E
	INX	H
	MOV	M,D
;      call pmove (8,.fcb.fn,.pd.name);
	LXI	B,8H
	INX	H
	LXI	D,FCB+1H
	CALL	PMOVE
;      pd.console = rlrpd.console;
	XCHG
	lxi	h,cli$console
	MOV	A,M
	STAX	D
;      pd.memseg = rlrpd.memseg;
	INX	D
	INX	H
	MOV	A,M
	STAX	D
;      segment$bottom = shl(double(md.base),8);
	LDA	MD
	MOV	H,A
	MVI	L,0
	SHLD	SEGMENTBOTTOM
;      pd.disk$set$dma = segment$bottom + 0080H;
	LXI	D,0080H
	DAD	D
	XCHG
	LXI	B,0014H
	LHLD	PDADR
	DAD	B
	MOV	M,E
	INX	H
	MOV	M,D
;      pd.disk$slct = rlrpd.disk$slct;
	INX	H
	lda	diskselect
	mov	m,a
;    end pd$init;
	RET

;  load:
load:
;    procedure;

	lhld	dayfileadr
	mov	a,m
	ora	a
	jz	@69
	lda	fcb
	ora	a
	jnz	@60
	lda	dfltdrive
	inr	a
@60:
	adi	'A'-1
	mov	c,a
	call	co
	mvi	c,':'
	call	co
	mvi	b,11
	lxi	h,fcb+1
@61:
	mov	a,b
	cpi	3
	jnz	@62
	push	b
	push	h
	mvi	c,'.'
	call	co
	pop	h
	pop	b
@62:
	mov	a,m
	ani	7fh
	mov	c,a
	inx	h
	push	b
	push	h
	call	co
	pop	h
	pop	b
	dcr	b
	jnz	@61
	lda	fcb+8
	ani	80h
	jnz	@62a
	lda	diskselect
	lxi	h,cli$slctuser
	cmp	m
	jz	@63
@62a:
	lxi	b,user0
	call	printb
@63:
	call	crlf
@69:

;      /* obtain proc dscrptr adr from memsegtbl index */
;      pdadr = .pdtbl(rlrpd.memseg);

;      /* make dispatch call to force memory selection */
	lda	cli$memseg
	LXI	H,PDTBL-34H
	LXI	B,0034H
	INR	A
@MPM1:
	DAD	B
	DCR	A
	JNZ	@MPM1
	SHLD	PDADR
;      ret = xdos (dispatch,0);
	CALL	DISPATCH

;      /* initialize process descriptor */
;      call pd$init;

	CALL	PDINIT
;      base = segment$bottom + 0100H;
	LXI	D,100H
	LHLD	SEGMENTBOTTOM
	DAD	D
	SHLD	BASE
;      prl$code$adr = base;

;      /* setup stack */
	SHLD	PRLCODEADR
;      stktbl(pd.memseg).loc(19) = .endp;
	LXI	B,0FH
	LHLD	PDADR
	DAD	B
	MOV	A,M
	LXI	B,0014H
	LXI	H,STKTBL-2
	INR	A
@MPM2:
	DAD	B
	DCR	A
	JNZ	@MPM2
	LXI	B,ENDP
	MOV	M,C
	INX	H
	MOV	M,B
;      stktbl(pd.memseg).loc(18) = base;
	DCX	H
	DCX	H
	XCHG
	LHLD	BASE
	XCHG
	MOV	M,D
	DCX	H
	MOV	M,E
;      do i = 0 to 8;
	MVI	B,16
@44:
;        stktbl(pd.memseg).loc(i) = 0C7C7H;
	DCX	H
	MVI	M,0C7H
;      end;
	DCR	B
	JNZ	@44

;      top = segment$bottom + shl(double(md.size),8);
	LDA	MD+1H
	MOV	D,A
	MVI	E,0
	LHLD	SEGMENTBOTTOM
	DAD	D
	SHLD	TOP
;      ok = false;
;      notdone = true;

;      /* read COM or PRL+bitmap file into memory */
;      do while notdone;
@46:
;        if base = top then
	LHLD	BASE
	XCHG
	LHLD	TOP
	MOV	A,E
	CMP	L
	JNZ	@8
	MOV	A,D
	CMP	H
	JNZ	@8
;        do;
;          notdone = false;
;          if prl then ok = true;
; the next three lines removed to support
;   chaining PRL's, tests for segment
;   too small on a PRL as well as COM
;	LDA	PRL
;	RAR
;	JC	@47
;          else
;          do;
;            call set$dma (.buffer);
	LXI	B,BUFFER
	CALL	SETDMA
;            if readbf (.fcb) = 1 then ok = true;
	LXI	B,FCB
	CALL	READBF
	DCR	A
	JZ	@47
	JMP	@15
;          end;
;        end;
@8:
;        else
;        do;
;          call set$dma (base);
	LHLD	BASE
	MOV	B,H
	MOV	C,L
	LXI	D,80H
	DAD	D
	SHLD	BASE
	CALL	SETDMA
;          base = base + sector$size;
;          if (ret := readbf (.fcb)) <> 0 then
	LXI	B,FCB
	CALL	READBF
	ORA	A
	JZ	@46
	mov	b,a
;          call tstcliabort;
	CALL	TSTCLIABORT
;          do;
;            notdone = false;
;            if ret = 1 then ok = true;
	DCR	b
	JNZ	@15
;          end;
;        end;
;      end;
@47:

;      /* free file & drives */
	call	rlsfile

;      if ok then
;      /* file read with no errors */
;      do;
;        if prl then
	LDA	PRL
	RAR
;        /* page relocatable, do the relocation */
;        do;
;          call relocate;
	CC	RELOCATE
;        end;

;        call pmove (50,.tfcb$default,segment$bottom+50H);
	LXI	B,50
	LXI	D,50H
	LHLD	SEGMENTBOTTOM
	DAD	D
	LXI	D,TFCBDEFAULT
	CALL	PMOVE
;        segment$bottom+50h = drive;
	lhld	segmentbottom
	lxi	d,50h
	dad	d
	lda	drive
	mov	m,a
;        if nxt$chr$adr <> 0 then
	LHLD	NXTCHRADR
	MOV	A,H
	ORA	L
;        /* parse the command tail */
;        do;
;           call parse$command$tail;
	CNZ	PARSECOMMANDTAIL
;        end;

;        /* setup base page of memory segment */
;        call setup$base$page;

	CALL	SETUPBASEPAGE
;        /* attach the console to the process to be created */
;        console$attached(pd.console) = pdadr;

;        call tstcliabort;
	DI
	CALL	TSTCLIABORT

;        /* create - start the process */
	LHLD	PDADR
	XCHG
	LXI	H,000EH
	DAD	D
	MOV	a,M
	push	psw	;save for list attaching
	ani	0fh
	mov	c,a
	MVI	B,0
	LXI	H,cnsatt	; CONSOLEATTACHED
	DAD	B
	DAD	B
	MOV	M,E
	INX	H
	MOV	M,D
;        /* attach list if required */
	pop	psw
	ani	0f0h
	rrc
	rrc
	rrc
	rrc
	mov	c,a
	lxi	h,lstatt
	dad	b
	dad	b
	lxi	b,clipd
	mov	a,m
	cmp	c
	jnz	@14
	inx	h
	mov	a,m
	cmp	b
	jnz	@14
	mov	m,d
	dcx	h
	mov	m,e
@14:
;        rlrpd.memseg = 0ffh; /* set clipd.memseg back to system */
	MVI	a,0FFH
	sta	cli$memseg
;        ret = xdos (create,pdadr);
	MVI	C,90H
	JMP	XDOS
;      end; /* of successful file read */
@15:
	LXI	B,plderr
@15A:
	PUSH	B
;      else
;      /* file read errors */
;      do;
;        /* free the allocated memory segment */
;        call mem$fr (.md);
	LXI	B,MD
	CALL	MEMFR
;        rlrpd.memseg = 0ffh; /* set clipd.memseg back to system */
	MVI	a,0FFH
	sta	cli$memseg
;        call print$b (.(
	POP	B
	JMP	PRINTB$rlsfile
;          'Program load error.','$'));
;   -or-   'Cli abort.','$'));       
;      end;
;    end load;

;  tstcliabort:
tstcliabort:
;    procedure;
	LXI	H,CLIABORT
	MOV	A,M
	ANI	7FH
	CMP	M
	RZ
	MOV	M,A	;clear the abort flag bit
	EI
	POP	H	;pop the return address
	LXI	B,CLIABT
	JMP	@15A
;    end tstcliabort

;  tstchain:
tstchain:
;    procedure;
	lda	chainseg
	inr	a
	rz		;if chainseg = 0ffh then return
	pop	h	;discard return address
	dcr	a
	add	a
	add	a
	lxi	h,msegtbl+2
	add	l
	mov	l,a
	mvi	a,0
	adc	h
	mov	h,a
	mov	a,m	;set on hi bit of attrib
	ori	80h
	mov	m,a
	dcx	h
	dcx	h
	mvi	e,4
tstch0:
	mov	a,m
	stax	b
	inx	h
	inx	b
	dcr	e
	jnz	tstch0
	lda	chainseg
	di
	sta	clipd+0fh
	call	dispatch
	jmp	load
;	ret
;    end tstchain;


;  load$COM:
loadcom:
;    procedure;

;      prl = false;
	xra	a
	sta	prl
;      md.base = 00H;
;      /* make absolute memory request */
	LXI	B,MD
;	XRA	A
	STAX	B
;      if abs$rq (.md) = 0 then
	call	tstchain
	CALL	ABSRQ
	ORA	A
	jnz	@20
	lda	md	;test for COM chaining to PRL
	ora	a
;      /* successful memory request */
;      do;
;        /* load and create process */
;        call load;
	JZ	LOAD
	lxi	b,chainComtoPRL  ;attempt to chain from PRL to COM
	jmp	@15a
;      end;
;      else
;      /* unsuccessful memory request */
;      do;
;        call print$b (.('Absolute ',
@20:
	LXI	B,abstpana
	JMP	PRINTB$rlsfile
;          'TPA is not currently available.','$'));
;      end;
;    end load$COM;

;  load$PRL:
loadprl:
;    procedure;

;      prl = true;
	mvi	a,0ffh
	sta	prl
;      ok = false;
;      /* read in first record, contains code size
;         and data size information                */
;      if readbf (.fcb) = 0 then
	LXI	B,FCB
	CALL	READBF
	ORA	A
	JNZ	@21
;      do;
;        /* obtain code length */
	lhld	buffer+1h
	shld	prlen

;        /* compute size of memory segment needed */
;        md.size = high(prlen+shr(prlen,3)+0FFH)
;                 + high(data$size+0FFH)
;                 + 1;

	mov	a,h
	rrc
	rrc
	rrc
	mov	b,a
	ani	0001$1111b
	mov	d,a
	mov	a,b
	ani	1110$0000b
	mov	e,a
	mov	a,l
	rrc
	rrc
	rrc
	ani	0001$1111b
	ora	e
	mov	e,a	;DE = shr (prlen,3)
	lxi	b,00ffh
	dad	d
	dad	b
	mov	a,h
	lhld	buffer+4h
	dad	b	;HL = datasize + 00ffh
	add	h
	inr	a
	STA	MD+1H
;        /* ignore next sector */
;        if readbf (.fcb) = 0 then
	LXI	B,FCB
	CALL	READBF
	ORA	A
	JNZ	@22
;        do;
;          /* make relocatable memory request */
;          if rel$rq(.md) = 0 then
	LXI	B,MD
	call	tstchain
	CALL	RELRQ
	ORA	A
;          /* successful memory request */
;          do;
;            /* load and create process */
;            call load;
	JZ	LOAD
;            return;
;          end;
;          else
;          /* unsuccessful memory request */
;          do;
;            call print$b (.(
;              'Insufficient relocatable memory to',
	LXI	B,insufrm
	JMP	PRINTB$rlsfile
;              ' load program.','$'));
;            return;
;          end;
;        end; /* of successful ignore record read */
@22:
;      end; /* of successful header record read */
@21:
;      call print$b (.(
	LXI	B,badprlhr
;	JMP	PRINTB$rlsfile
;        'Bad PRL header record.','$'));
;    end load$PRL;

PRINTB$rlsfile:
	CALL	crlfprintb
rlsfile:
	lxi	b,clipd
	call	remfl
;        /* free drives, if still accessed */
;        ret = xdos (39,0ffffh);
	mvi	c,39
	lxi	d,0ffffh
	call	xbdos
	lxi	h,0
	shld	cli$pdcnt	;ZERO THE CLI pdcnt
	ret

; open$test:
opentest:
;    procedure byte;
;      if open (.fcb) = ffh
	lxi	b,fcb
	call	open
	inr	a
	jnz	tstsyspass
	mov	a,h
	ora	a
;        then return 0;
	rz
	pop	h
	ret
tstsyspass:
;      if notsyspass
	lda	notsyspass
	ora	a
;        then return 0ffh;
	rnz
;      return 80h and fcb.ft(1);
	lxi	h,fcb+0ah
	mov	a,m
	ani	80h
	ret
;    end open$test;

;  file$load$execute:
fileloadexecute:
;    procedure;

;      notsyspass = true;
	mvi	a,0ffh
	sta	notsyspass
;      call set$dma (.buffer);
	LXI	B,BUFFER
	CALL	SETDMA
;      call pmove (8,.FCB+10h,.buffer);
	lxi	b,8
	lxi	d,fcb+10h
	lxi	h,buffer
	call	pmove
;      if fcb.ft(0) = ' ' then
	LXI	H,FCB+9H
	MOV	A,M
	CPI	20H
	JNZ	@25
;      /* type must be left blank */
;      do;
;        fcb.fn(5) = fcb.fn(5) or 80h;
;        /* open file R/O */
@18:
	lxi	h,fcb+6h
	mov	a,m
	ori	80h
	mov	m,a
;        call pmove (3,.('PRL'),.fcb.ft);
	lxi	h,fcb+9h
	MVI	M,'P'
	INX	H
	MVI	M,'R'
	INX	H
	MVI	M,'L'

;        /* first try for PRL file */
;        if open$test (.fcb) = 0FFH then
	call	open$test
	JNZ	LOADPRL
;        /* PRL file not found, try COM file */
;        do;
;        fcb.fn(5) = fcb.fn(5) or 80h;
;        /* open file R/O */
	lxi	h,fcb+6h
	mov	a,m
	ori	80h
	mov	m,a
;          call pmove (3,.('COM'),.fcb.ft);
	LXI	H,FCB+9H
	MVI	M,'C'
	INX	H
	MVI	M,'O'
	INX	H
	MVI	M,'M'
;          if open$test (.fcb) = 0FFH then
	call	open$test
	JNZ	LOADCOM

	lda	notsyspass
	ora	a
	jnz	@18a
	lda	cli$slct$user
	ani	0fh
	jz	@19
	mvi	c,32
	mvi	e,0
	call	xbdos		;set user = 0
	jmp	@18
@18a:
	lda	drive
	ora	a
	jnz	@19	;explicit drive specified
	lhld	sysdriveadr
	mov	a,m
	ora	a
	jz	@19	;no system drive specified
	mov	b,a
	lda	dfltdrive
	inr	a
	cmp	m
	mov	a,b
        jz	@19	;default drive same as system drive
	lxi	h,fcb
	cmp	m
	mov	m,a
	jz	@19
	xra	a
	sta	notsyspass
	jmp	@18	;go try with system disk
@19:
;          /* unsuccessful file open */
;          do;
;            call print$b (.(
	LXI	H,FCB+9H
@23:
	DCX	H
	MOV	A,M
	CPI	' '
	JZ	@23
	INX	H
	MVI	M,'?'
	INX	H
	MVI	M,'$'
	LXI	B,FCB+1H
	JMP	PRINTB$rlsfile
;              'No such file.','$'));
;            return;
;          end;
;        end;

;        /* successful file open */
;        if prl then
;        /* relocatable load */
;        do;
;          call load$PRL;
;        end;
;        else
;        /* COM file load */
;        do;
;          call load$COM;
;        end;
;      end; /* of blank file type */
@25:
;      else
;      do;
;      /* non-blank file type */
;        call print$b (.(
	LXI	B,fltypblnk
	JMP	PRINTB$rlsfile
;          'File type must not be specified.','$'));
;      end;
;    end file$load$execute;

;  queue$message:
queuemessage:
;    procedure boolean;

;      call pmove (8,.fcb.fn,.cusp$uqcb.name);
	LXI	B,8H
	LXI	H,CUSPUQCB+4H
	LXI	D,FCB+1H
	CALL	PMOVE
;      if xdos (open$queue,.cusp$uqcb) = 0 then
	LXI	B,CUSPUQCB
	CALL	openq
	ORA	A
	MVI	A,0
	RNZ
;      /* queue exists */
;      do;
;        /* if dayfile then log message queued */
	lhld	dayfileadr
	mov	a,m
	ora	a
	jz	@26
	lxi	b,msgqued
	call	printb
@26:

;        call pmove (8,.fcb.fn,.pname(1));
	LXI	B,8H
	LXI	H,PNAME+1H
	LXI	D,FCB+1H
	CALL	PMOVE
;        /* assign the console to the process, if any,
;           associated with the queue. a console is
;           associated with a process if there is a
;           process with the same name as the queue.   */
;        ret = assign (.pname);

	LXI	B,PNAME
	CALL	ASSIGN
;        if nxt$chr$adr <> 0 then
	LHLD	NXTCHRADR
	MOV	A,H
	ORA	L
	JZ	@32
;        /* copy the command tail */
;        do;
;          call pmove (128-(nxt$chr$adr-.command$tail),
	LHLD	NXTCHRADR
	XCHG
	MOV	A,E
	INX	D
	lxi	h,commandtail
	sub	l		;only need 8-bit arith.
	MOV	B,A
	MVI	A,80H
	SUB	B
	MOV	C,A
	MVI	B,0
;	LXI	H,FIELD+2H	;already loaded above
	CALL	PMOVE
;            nxt$chr$adr+1,.field(2));
;        end;
	JMP	@33
@32:
;        else
;        /* put a <cr> in first field position */
;        do;
;          field(2) = 0dh;
	LXI	H,FIELD+2H
	MVI	M,0DH
;        end;
@33:

;        /* conditionally write the message to the queue */
;        if xdos (cond$write$queue,.cusp$uqcb) <> 0 then
	LXI	B,CUSPUQCB
	CALL	cwriteq
	ORA	A
;        /* write failed, buffer not available */
;        do;
;          call print$b (.(
	LXI	B,quefull
	CNZ	crlfprintb
;            'Queue full.','$'));
;        end;
;        return true;
	MVI	A,0FFH
	RET
;      end; /* of successful queue open */
;      /* queue open failed */
;      return false;
;    end queue$message;


;/*
;  cli:
;*/

;  cli:
cli:
;    procedure;

;      ret = xdos (make$queue,.cli$lqcb);

	lhld	sysdat
	xchg
	lxi	h,123
	dad	d
	shld	sysdriveadr
	lxi	h,195
	dad	d
	shld	dayfileadr
	lxi	h,252
	dad	d
	mov	e,m
	inx	h
	mov	d,m
	xchg
	inx	h
	inx	h
	shld	todadr
	LXI	B,CLILQCB
	CALL	makeq
;      do forever;
@48:
;        ret = xdos (read$queue,.CLIQ);
	LXI	B,CLIQ
	CALL	readq

;        clipd.name(6) = (clipd.name(6) and 7fh);
	lxi	h,cliabort
	mov	a,m
	ani	7fh
	mov	m,a
;        pname(0),
;        clipd.console = console;
	LDA	CONSOLE
	sta	cli$console
	ani	0fh	;mask off printer
	STA	PNAME
;        /* test for console attached to cli */
	mvi	c,162
	call	xbdos	;conditional attach console
	ora	a
	jnz	@37	;ignore request if console not attached to CLI
;        /* test for chain function */
	mvi	a,0ffh
	sta	chainseg	;chain flagged false
	lxi	h,commandtail
	mov	a,m
	ora	a		;chaining flagged by
	jnz	@49		; commandtail(0) = 0 
	inx	h
	mov	a,m
	sta	chainseg	;chainseg = commandtail(1);
	inx	h
	mov	d,h
	mov	e,l
	dcx	d
	dcx	d
@49a:			;move command tail down 2 bytes
	mov	a,m
	stax	d
	inx	d
	inx	h
	ora	a
	jz	@49
	cpi	0dh	;line terminated by nul or <cr>
	jnz	@49a
@49:

;        /* test for dayfile and print crlf & time */
	lhld	dayfileadr
	mov	a,m
	ora	a
	jz	@51
	lhld	todadr
	mvi	b,3
@52:
	mov	a,m
	inx	h
	push	h
	push	b
	push	psw
	ani	0f0h
	rrc
	rrc
	rrc
	rrc
	adi	'0'
	mov	c,a
	call	co
	pop	psw
	ani	0fh
	adi	'0'
	mov	c,a
	call	co
	pop	b
	dcr	b
	mvi	c,':'
	jnz	@50
	mvi	c,' '
@50:
	push	b
	push	psw
	call	co
	pop	psw
	pop	b
	pop	h
	jnz	@52
@51:

;        rlrpd.disk$slct = disk$select;
	LDA	DISKSELECT
	sta	cli$slctuser
	ani	1111$0000b
	rar
	rar
	rar
	rar
	sta	dfltdrive

;        pcb.field$adr = .command$tail;
	LXI	H,COMMANDTAIL
	SHLD	PCB
;        pcb.fcb$adr = .fcb;
	LXI	H,FCB
	SHLD	PCB+2H
;        if (nxt$chr$adr := xdos (parse$fname,.pcb)) <> 0FFFFH then
	LXI	B,PCB
	CALL	parsefilename
	SHLD	NXTCHRADR
	INX	H
	MOV	A,H
	ORA	L
	JZ	@35
;        /* legitimate queue or file name entered */
;        do;
;          fcb.nr = 0;
	LXI	H,FCB+20H
	MVI	M,0H
;          /* test for message to be queued */
	lda	fcb+26	;size of password
	ora	a
	jnz	@34

	lda	fcb
	sta	drive	;save explicit/default drive spec.
	ora	a
	mvi	a,0
;          if not queue$message
	cz	QUEUEMESSAGE  ;queue only if drive not explicit
	RAR
;	JC	@37
;          then
;          /* file is to be loaded and executed */
;          do;
;            call file$load$execute;
@34:
	cnc	FILELOADEXECUTE
;          end;
;        end;
	JMP	@37
@35:
;        else
;        /* illegitimate queue or file name */
;        do;
;          call print$b (.(
	LXI	B,illegal
	CALL	crlfprintb
;            'Illegal entry.','$'));
;        end;
@37:

;        /* detach the console from CLI, if still attached */
;        ret = xdos (detach,0);
	LXI	B,CLIPD
	CALL	DETACH
;        /* detach the list from CLI, if still attached */
;        call detlst (.clipd);
	LXI	B,CLIPD
	call	detlst
;      end; /* of forever */
	JMP	@48

;    end cli; /* procedure */

;end cli;
	END
