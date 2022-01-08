	title	'MP/M II V2.0 Queue Management'
	name	'queue'
	dseg
@@queue:
	public	@@queue
	cseg
;queue:
@queue:
	public	@queue
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
;$include (queue.lit)
;$nolist
;$include (datapg.ext)
;$nolist
;$include (proces.ext)
;$nolist


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

;  dispat:
	extrn	dispat
;    procedure external;
;    end dispat;

;  declare qlr address external;
	extrn	qlr

;  declare drl address external;
	extrn	drl

;  declare rlr address external;
	extrn	rlr

;  declare dparam address external;
	extrn	dparam

; queue offsets
bufos	equ	24

;/*
;  makeq:  The purpose of the make queue procedure is to setup
;         a queue control block.  A queue is configured as either
;         circular or linked depending upon the message size.
;         Message sizes 0 to 2 use circular queues while > 2 use
;         linked queues.  Note that the make queue does not
;         automatically open the queue, this must be done in
;         another explicit operation.

;  Entry Conditions:
;          BC = address of queue control block

;  Exit Conditions:
;          A  = return code,
;                where   0 = success,
;                      FFH = failure
;*/
;  makeq:
makeq:
	public	makeq
;    procedure (qcbadr) byte reentrant public;
;      declare qcbadr address;
;      declare qcb based qcbadr queuehead;
;      declare cqcb based qcbadr circularqueue;
;      declare lqcb based qcbadr linkedqueue;
;      declare (i,j,nxtmsgadr,bufadr,offset) address;
;      declare buf based bufadr (1) byte;
;      declare nxtmsg based nxtmsgadr address;

;      if qcb.msglen < 3 then
	LXI	H,0000BH
	DAD	B		; HL = .qcb.msglen+1
	MOV	A,M
	ORA	A
	JNZ	@1
	DCX	H
	MOV	A,M
	CPI	3H
	JNC	@1
;      do;  /* setup circular queue */
;        cqcb.msgin,
;        cqcb.msgout,
;        cqcb.msgcnt = 0;
	LXI	H,0012H
	DAD	B
	MVI	E,6
	XRA	A
@1A:
	MOV	M,A
	INX	H
	DCR	E
	JNZ	@1A
;      end;
	JMP	@2
@1:
;      else
;      do;  /* setup linked queue */
;        lqcb.mh = 0;
	LXI	H,0012H
	DAD	B
	XRA	A
	MOV	M,A
	INX	H
	MOV	M,A
;        lqcb.mt = .lqcb.mh;
	MOV	D,H
	MOV	E,L
	DCX	D
	INX	H
	MOV	M,E
	INX	H
	MOV	M,D
;        bufadr,
;        lqcb.bh = .lqcb.buf;
	INX	H
	MOV	D,H
	MOV	E,L
	INX	D
	INX	D
	MOV	M,E
	INX	H
	MOV	M,D
;        offset = lqcb.msglen + 2;
	LXI	H,000AH
	DAD	B
	PUSH	B
	MOV	C,M
	INX	H
	MOV	B,M
	INX	B
	INX	B
;        i = lqcb.nmbmsgs - 1;
	INX	H
	MOV	A,M
	INX	H
	MOV	H,M
	MOV	L,A
	PUSH	H
;        j = 0;
;        do while i <> 0;
@32:
	POP	H
	DCX	H
	MOV	A,H
	ORA	L
	JZ	@33
	PUSH	H
;          i = i - 1;
;          nxtmsgadr = .buf(j);
;          nxtmsg = .lqcb.buf(j+offset);
;          j = j + offset;
;        end;
	MOV	H,D
	MOV	L,E
	DAD	B
	XCHG
	MOV	M,E
	INX	H
	MOV	M,D
	JMP	@32
@33:
;        buf(j),
;        buf(j+1) = 0;
	STAX	D
	INX	D
	STAX	D
	POP	B
;      end;
@2:
;      qcb.dqph,
;      qcb.nqph = 0;
	LXI	H,00EH
	DAD	B
	XRA	A
	MOV	M,A
	INX	H
	MOV	M,A
	INX	H
	MOV	M,A
	INX	H
	MOV	M,A
;      enter$region;
	DI
;        qcb.ql = qlr;
	LHLD	QLR
	XCHG
	MOV	H,B
	MOV	L,C
	MOV	M,E
	INX	H
	MOV	M,D
;        qlr = .qcb.ql;
	DCX	H
	SHLD	QLR
;      exit$region;
	CALL	EXITR
;      return 0;
	XRA	A
	RET
;    end makeq;

;/*
;  openq:  The purpose of the open queue procedure is to place the
;         actual queue control block address into the user queue
;         control block.  The QCB address is obtained by searching
;         the queue list from the QLR to match the user QCB name
;         with the actual QCB name.

;  Entry Conditions:
;         BC = address of user queue control block

;  Exit Conditions:
;         A  = return code,
;               where   0 = success,
;                     FFH = failure
;*/
;  openq:
openq:
	public	openq
;    procedure (uqcbadr) byte reentrant public;
;      declare uqcbadr address;
;      declare uqcb based uqcbadr userqcb;
;      declare qcbadr address;
;      declare qcb based qcbadr queuehead;
;      declare i byte;

;      disable;
	di
;      qcbadr = qlr;
	LHLD	QLR
	XCHG
;      do while qcbadr <> 0;
	PUSH	B
@34:
	POP	B
	MOV	A,D
	ORA	E
	MVI	A,0FFH
	jnz	@35
	ei
	ret
@35:
;        i = 0;
	PUSH	B
	INX	B
	INX	B
	INX	B
	INX	B	; BC = .UQCB.NAME(0)
	LXI	H,0002H
	DAD	D
	PUSH	H	; TOS = .QCB.NAME(0)
	MVI	L,8
;        do while (i <> 8) and (qcb.name(i) = uqcb.name(i));
@36:
	XTHL
	LDAX	B
	CMP	M
	JZ	@36A
	POP	H
	XCHG
	MOV	E,M
	INX	H
	MOV	D,M
	JMP	@34
;          i = i + 1;
@36A:
	INX	B
	INX	H
	XTHL
	DCR	L
;        end;
	JNZ	@36
;        if i = 8 then
;        do;
;          uqcb.pointer = qcbadr;
	POP	B
	POP	H
	MOV	M,E
	INX	H
	MOV	M,D
;          return 0;
	XRA	A
	ei
	RET
;        end;
@3:
;        qcbadr = qcb.ql;
;      end;
;      return 0FFH;
;    end openq;

;/*
;  deletq:
;          The purpose of the delete queue procedure is to remove
;        the specified queue from the queue list.  Before this can
;        be done tests must be made to determine if there are any
;        processes which are on the queues NQ or DQ lists.

;  Entry Conditions:
;          BC = address of queue control block

;  Exit Conditions:
;          A  = return code,
;                where   0 = success,
;                      FFH = failure
;*/
;  deletq:
deletq:
	public	deletq
;    procedure (qcbadr) byte reentrant public;
;      declare qcbadr address;
;      declare qcb based qcbadr queuehead;
;      declare nxtqcbadr address;
;      declare nxtqcb based nxtqcbadr queuehead;

;      enter$region;
	DI
;        nxtqcbadr = qlr;
;	LHLD	QLR
;        if (qcb.dqph = 0) and
	LXI	H,000EH
	DAD	B
	MOV	A,M
	INX	H
	ORA	M
	INX	H
	ORA	M
	INX	H
	ORA	M
	JNZ	@4
;           (qcb.nqph = 0) then
	LXI	H,QLR
;        do while nxtqcbadr <> 0;
@38:
	MOV	A,L
	ORA	H
	JZ	@4
;          if nxtqcb.ql = qcbadr then
	MOV	A,M
	CMP	C
	JNZ	@5
	INX	H
	MOV	A,M
	DCX	H
	CMP	B
	JNZ	@5
;          do;
;            nxtqcb.ql = qcb.ql;
	LDAX	B
	MOV	M,A
	INX	B
	INX	H
	LDAX	B
	MOV	M,A
;            exit$region;
	CALL	EXITR
;            return 0;
	XRA	A
	RET
;          end;
@5:
;          nxtqcbadr = nxtqcb.ql;
	MOV	E,M
	INX	H
	MOV	D,M
	XCHG
;        end;
	JMP	@38
@4:
;      exit$region;
	CALL	EXITR
;      return 0FFH;
	MVI	A,0FFH
	RET
;    end deletq;

;/*
;  rdynqph:
;          The ready NQ process head procedure is called when a
;        buffer is freed by the action of readq. Rdynqph determines
;        if a process has been placed in the NQ state waiting for
;        an available buffer at that queue.  If such a process
;        exists the process is placed on the dispatcher ready list
;        and the NQ process head list is updated.

;  Entry Conditions:
;        BC = address of queue descriptor

;  Exit Conditions:
;        None
;*/

;  rdynqph:
rdynqph:
;    procedure (qcbadr) reentrant;
;      declare qcbadr address;
;      declare qcb based qcbadr queuehead;
;      declare pdadr address;
;      declare pd based pdadr process$descriptor;

;      if qcb.nqph <> 0 then
	LXI	H,0010H
RNQDQPH:
	DAD	B
	MOV	E,M
	INX	H
	MOV	D,M
	MOV	A,D
	ORA	E
	JZ	EXITR
;      do;
;        pdadr = qcb.nqph;
	; DE = PDADR, BC = QCBADR
;        qcb.nqph = pd.pl;
	DCX	H
	LDAX	D
	MOV	M,A
	INX	D
	INX	H
	LDAX	D
	MOV	M,A
;        pd.status = rtr$status;
	INX	D
	XRA	A
	STAX	D
;        call insert$process (.drl,pdadr);
	DCX	D
	DCX	D
	LXI	B,DRL
	CALL	INSPR
;      end;
;      exit$region;
	JMP	EXITR
;    end rdynqph;

;/*
;  readq:
;          The purpose of the read queue procedure is to read
;        a message from the specified queue.  If no message is
;        available the calling process is placed into the DQ
;        status, relinquishing the processor, until a message
;        is posted at the queue.

;  Entry Conditions:
;        BC = address of user queue control block

;  Exit Conditions:
;        None
;*/

;  readq:
readq:
	public	readq
;    procedure (uqcbadr) byte reentrant public;
;      declare uqcbadr address;
;      declare uqcb based uqcbadr userqcb;
;      declare qcbadr address;
;      declare qcb based qcbadr queuehead;
;      declare cqcb based qcbadr circularqueue;
;      declare lqcb based qcbadr linkedqueue;
;      declare msglnkadr address;
;      declare msglnk based msglnkadr address;
;      declare i address;
;      declare i$cont based i address;

;      qcbadr = uqcb.pointer;
	LDAX	B
	MOV	E,A
	INX	B
	LDAX	B
	MOV	D,A
	INX	B
	LDAX	B
	MOV	H,A
	INX	B
	LDAX	B
	MOV	B,A
	MOV	C,H
;      do forever;
@40:
	; BC = UQCB.MSGADR, DE = QCBADR
;        if qcb.msglen < 3 then
	LXI	H,000BH
	DAD	D
	MOV	A,M
	ORA	A
	JNZ	@7
	DCX	H
	MOV	A,M
	CPI	3H
	JNC	@7
;        do;  /* reading message from a circular queue */
;          enter$region;
	DI
;          if cqcb.msgcnt <> 0 then
	LXI	H,0016H
	DAD	D
	MOV	A,M
	INX	H
	ORA	M
	JZ	@14
;          do;
;            if cqcb.msglen <> 0 then
	LXI	H,000AH
	DAD	D
	MOV	A,M
	ORA	M
	JZ	@9
;            do;
	; A = MSGLEN, BC = UQCB.MSGADR, DE = QCBADR
	PUSH	B
	LXI	H,0014H
	DAD	D
	MOV	C,M
	INX	H
	MOV	B,M	; BC = CQCB.MSGOUT
	LXI	H,0018H
	DAD	D
	DAD	B
;              if cqcb.msglen = 2 then i = i + i;
	DCR	A
	JZ	@10A
	DAD	B
@10A:
	POP	B
;              call move (cqcb.msglen,.cqcb.buf(i),uqcb.msgadr);
	MOV	A,M
	STAX	B
	JZ	@10B
	INX	B
	INX	H
	MOV	A,M
	STAX	B
@10B:
;              cqcb.msgout = (cqcb.msgout+1) mod cqcb.nmbmsgs;
	LXI	H,000CH
	DAD	D
	MOV	C,M
	INX	H
	MOV	B,M
	PUSH	B	; TOS,BC = CQCB.NMBMSGS
	LXI	H,0014H
	DAD	D
	MOV	C,M
	INX	H
	MOV	B,M
	INX	B
	XTHL
	MOV	A,C
	CMP	L
	JNZ	@10C
	MOV	A,B
	CMP	H
	JNZ	@10C
	LXI	B,0000H
@10C:
	POP	H
	MOV	M,B
	DCX	H
	MOV	M,C
;            end;
	JMP	@11
@9:
;            else
;            do;
;              if cqcb.name(0) = 'M' then
	LXI	H,0002H
	DAD	D
	MOV	A,M
	CPI	'M'
	JNZ	@12
;              do;
;                if cqcb.name(1) = 'X' then
	INX	H
	MOV	A,M
	CPI	'X'
	JNZ	@13
;                do;
;                  i = qcbadr + 24;
;                  /* put pdadr into MX queue */
;                  icont = rlr;
	LHLD	RLR
	MOV	B,H
	MOV	C,L
	LXI	H,0018H
	DAD	D
	MOV	M,C
	INX	H
	MOV	M,B
;                end;
@13:
;              end;
@12:
;            end;
@11:
;            cqcb.msgcnt = cqcb.msgcnt - 1;
	LXI	H,0016H
	DAD	D
	MOV	C,M
	INX	H
	MOV	B,M
	DCX	B
	MOV	M,B
	DCX	H
	MOV	M,C
;            call rdynqph (qcbadr);
	MOV	B,D
	MOV	C,E
	CALL	RDYNQPH
;            return 0;
	XRA	A
	RET
;          end;
;        end;
@7:	; BC = uqcb.msgadr, DE = qcbadr
;        else
;        do;  /* reading message from a linked queue */
;          enter$region;
	DI
;          if lqcb.mh <> 0 then
	LXI	H,0012H
	DAD	D
	PUSH	D	; TOS = QCBADR
	MOV	E,M
	INX	H
	MOV	D,M
	MOV	A,E
	ORA	D
	JZ	@15
;          do;
;            msglnkadr = lqcb.mh;
	PUSH	D
;            lqcb.mh = msglnk;
	LDAX	D
	DCX	H
	MOV	M,A
	INX	D
	INX	H
	LDAX	D
	MOV	M,A
;            if msglnk = 0 then lqcb.mt = .lqcb.mh;
	DCX	H
	ORA	M
	JNZ	@16
	MOV	D,H
	MOV	E,L
	INX	H
	INX	H
	MOV	M,E
	INX	H
	MOV	M,D
@16:
;            exit$region;
	PUSH	B
	CALL	EXITR
	POP	D
;            call move (lqcb.msglen,msglnkadr+2,uqcb.msgadr);
	POP	B
	POP	H
	PUSH	H
	PUSH	B
	INX	B
	INX	B
	; BC = MSGLNKADR+2, DE = UQCB.MSGADR, HL = QCBADR
	MOV	A,L
	ADI	0AH
	MOV	L,A
	MOV	A,H
	ACI	00H
	MOV	H,A
	MOV	A,M
	INX	H
	MOV	H,M
	MOV	L,A	; HL = LQCB.MSGLEN
	LDAX	B
	STAX	D
	INX	B
	INX	D
	DCX	H
	MOV	A,H
	ORA	L
	JNZ	$-7H
;            enter$region;
	POP	D	; DE = MSGLNKADR
	POP	B	; BC = QCBADR
	DI
;            msglnk = lqcb.bh;
	LXI	H,16H
	DAD	B
	MOV	A,M
	STAX	D
	INX	D
	INX	H
	MOV	A,M
	STAX	D
;            lqcb.bh = msglnkadr;
	DCX	D
	MOV	M,D
	DCX	H
	MOV	M,E
;            call rdynqph (qcbadr);
	CALL	RDYNQPH
;            return 0;
	XRA	A
	RET
;          end;
@15:
	POP	D
;        end;
@14:
;        rlrpd.status = dq$status;
	LHLD	RLR
	INX	H
	INX	H
	MVI	M,1H
;        dsptch$param = .qcb.dqph;
	LXI	H,000EH
	DAD	D
	SHLD	DPARAM
;        call dispatch;
	CALL	DISPAT
;      end; /* forever */
	JMP	@40
;    end readq;

;/*
;  creadq:
;          The purpose of the conditional read queue procedure
;        is to read a message from the specified queue.  If
;        no message is available a status of FFH is returned.

;  Entry Conditions:
;        BC = address of user queue control block

;  Exit Conditions:
;        A  = return code,
;              where   0 = success,
;                    FFH = failure
;*/

;  creadq:
creadq:
	public	creadq
;    procedure (uqcbadr) byte reentrant public;
;      declare uqcbadr address;
;      declare uqcb based uqcbadr userqcb;
;      declare qcbadr address;
;      declare qcb based qcbadr queuehead;
;      declare cqcb based qcbadr circularqueue;
;      declare lqcb based qcbadr linkedqueue;

;      qcbadr = uqcb.pointer;
	LDAX	B
	MOV	E,A
	INX	B
	LDAX	B
	DCX	B
	MOV	D,A	; BC = UQCBADR, DE = QCBADR
;      if qcb.msglen < 3 then
	LXI	H,000BH
	DAD	D
	MOV	A,M
	ORA	A
	JNZ	@17
	DCX	H
	MOV	A,M
	CPI	3H
	JNC	@17
;      do;  /* reading message from a circular queue */
;        enter$region;
	DI
;        if cqcb.msgcnt <> 0 then return readq (uqcbadr);
	LXI	H,0016H
	JMP	@20
;      end;
@17:
;      else
;      do;  /* reading message from a linked queue */
;        enter$region;
	DI
;        if lqcb.mh <> 0 then return readq (uqcbadr);
	LXI	H,0012H
@20:
	DAD	D
	MOV	A,M
	INX	H
	ORA	M
	JNZ	READQ
;      end;
;      exit$region;
	CALL	EXITR
;      return 0FFH;
	MVI	A,0FFH
	RET
;    end creadq;

;/*
;  rdydqph:
;          The ready DQ process head procedure is called when a
;        message is posted by the action of writeq. Rdydqph
;        determines if a process has been placed in the DQ state
;        waiting for a message at that queue.  If such a process
;        exists the process is placed on the dispatcher ready list
;        and the DQ process head list is updated.

;  Entry Conditions:
;        BC = address of queue descriptor

;  Exit Conditions:
;        None
;*/

;  rdydqph:
rdydqph:
;    procedure (qcbadr) reentrant;
;      declare qcbadr address;
;      declare qcb based qcbadr queuehead;
;      declare pdadr address;
;      declare pd based pdadr process$descriptor;

;      if qcb.dqph <> 0 then
	LXI	H,0000EH
	JMP	RNQDQPH
;      do;
;        pdadr = qcb.dqph;
;        qcb.dqph = pd.pl;
;        pd.status = rtr$status;
;        call insert$process (.drl,pdadr);
;      end;
;      exit$region;
;    end rdydqph;

;/*
;  writeq:
;          The purpose of the write queue procedure is to write
;        a message to the specified queue.  If no buffer is
;        available the calling process is placed into the NQ
;        status, relinquishing the processor, until a buffer
;        is returned to the queue.

;  Entry Conditions:
;        BC = address of user queue control block

;  Exit Conditions:
;        None
;*/

;  writeq:
writeq:
	public	writeq
;    procedure (uqcbadr) byte reentrant public;
;      declare uqcbadr address;
;      declare uqcb based uqcbadr userqcb;
;      declare qcbadr address;
;      declare qcb based qcbadr queuehead;
;      declare cqcb based qcbadr circularqueue;
;      declare lqcb based qcbadr linkedqueue;
;      declare i address;
;      declare msglnkadr address;
;      declare msglnk based msglnkadr address;
;      declare mtadr address;
;      declare mtcont based mtadr address;

;      qcbadr = uqcb.pointer;
	LDAX	B
	MOV	E,A
	INX	B
	LDAX	B
	MOV	D,A
	INX	B
	LDAX	B
	MOV	H,A
	INX	B
	LDAX	B
	MOV	B,A
	MOV	C,H
;      do forever;
@42:	; BC = uqcb.nsgadr, DE = qcbadr
;        if qcb.msglen < 3 then
	LXI	H,000BH
	DAD	D
	MOV	A,M
	ORA	A
	JNZ	@22
	DCX	H
	MOV	A,M
	CPI	3H
	JNC	@22
;        do;  /* writing message to a circular queue */
;          enter$region;
	DI
;          if cqcb.msgcnt <> cqcb.nmbmsgs then
	LXI	H,0017H
	DAD	D
	MOV	A,M
	DCX	H
	PUSH	H
	LXI	H,000DH
	DAD	D
	CMP	M
	DCX	H
	MOV	A,M
	XTHL
	JNZ	@42A
	CMP	M
@42A:
	POP	H
	JZ	@26
;          do;
;            if cqcb.msglen <> 0 then
	DCX	H
	DCX	H
	MOV	A,M
	ORA	A
	JZ	@24
;            do;
;              i = cqcb.msgin;
	PUSH	B
	LXI	H,0012H
	DAD	D
	MOV	C,M
	INX	H
	MOV	B,M
	LXI	H,0018H
	DAD	D
	DAD	B
;              if cqcb.msglen = 2 then i = i + i;
	DCR	A
	JZ	@25A
	DAD	B
@25A:
	POP	B
;              call move (cqcb.msglen,uqcb.msgadr,.cqcb.buf(i));
	LDAX	B
	MOV	M,A
	JZ	@25B
	INX	B
	INX	H
	LDAX	B
	MOV	M,A
@25B:
;              cqcb.msgin = (cqcb.msgin+1) mod cqcb.nmbmsgs;
	LXI	H,000CH
	DAD	D
	MOV	C,M
	INX	H
	MOV	B,M
	PUSH	B
	LXI	H,0012H
	DAD	D
	MOV	C,M
	INX	H
	MOV	B,M
	INX	B
	XTHL
	MOV	A,C
	CMP	L
	JNZ	@25C
	MOV	A,B
	CMP	H
	JNZ	@25C
	LXI	B,0000H
@25C:
	POP	H
	MOV	M,B
	DCX	H
	MOV	M,C
;            end;
@24:
;            cqcb.msgcnt = cqcb.msgcnt + 1;
	LXI	H,0016H
	DAD	D
	MOV	C,M
	INX	H
	MOV	B,M
	INX	B
	MOV	M,B
	DCX	H
	MOV	M,C
;            call rdydqph (qcbadr);
	MOV	B,D
	MOV	C,E
	CALL	RDYDQPH
;            return 0;
	XRA	A
	RET
;          end;
;        end;
@22:
;        else
;        do;  /* writing message to a linked queue */
;          enter$region;
	DI
;          if lqcb.bh <> 0 then
	LXI	H,0016H
	DAD	D
	PUSH	D
	MOV	E,M
	INX	H
	MOV	D,M
	MOV	A,E
	ORA	D
	JZ	@27
;          do;
;            msglnkadr = lqcb.bh;
	PUSH	D
;            lqcb.bh = msglnk;
	LDAX	D
	DCX	H
	MOV	M,A
	INX	D
	INX	H
	LDAX	D
	MOV	M,A
;            exit$region;
	PUSH	B
	CALL	EXITR
	POP	B
;            call move (lqcb.msglen,uqcb.msgadr,msglnkadr+2);
	POP	D
	POP	H
	PUSH	H
	PUSH	D
	INX	D
	INX	D
	; BC = UQCB.MSGADR, DE = MSGLNKADR+2, HL = QCBADR
	MOV	A,L
	ADI	0AH
	MOV	L,A
	MOV	A,H
	ACI	0
	MOV	H,A
	MOV	A,M
	INX	H
	MOV	H,M
	MOV	L,A
	; BC = UQCB.MSGADR, DE = MSGLNKADR+2, HL = LQCB.MSGLEN
	LDAX	B
	STAX	D
	INX	B
	INX	D
	DCX	H
	MOV	A,H
	ORA	L
	JNZ	$-7H
;            msglnk = 0;
	POP	D
	STAX	D
	INX	D
	STAX	D
	DCX	D
;            mtadr = lqcb.mt;
	LXI	H,0014H
	POP	B
	DAD	B
	PUSH	B
	MOV	C,M
	INX	H
	MOV	B,M
;            enter$region;
	DI
;            mtcont,
;            lqcb.mt = msglnkadr;
	MOV	A,E
	STAX	B
	INX	B
	MOV	A,D
	STAX	B
	MOV	M,D
	DCX	H
	MOV	M,E
;            call rdydqph (qcbadr);
	POP	B
	CALL	RDYDQPH
;            return 0;
	XRA	A
	RET
;          end;
@27:
	POP	D
;        end;
@26:
;        rlrpd.status = nq$status;
	LHLD	RLR
	INX	H
	INX	H
	MVI	M,2H
;        dsptch$param = .qcb.nqph;
	LXI	H,0010H
	DAD	D
	SHLD	DPARAM
;        call dispatch;
	CALL	DISPAT
;      end; /* forever */
	JMP	@42
;    end writeq;

;/*
;  cwriteq:
;          The purpose of the conditional write queue procedure
;        is to write a message to the specified queue.  If no
;        buffer is available the value FFH is returned.

;  Entry Conditions:
;        BC = address of user queue control block

;  Exit Conditions:
;        A  = return code,
;              where   0 = success,
;                    FFH = failure
;*/

;  cwriteq:
cwriteq:
	public	cwriteq
;    procedure (uqcbadr) byte reentrant public;
;      declare uqcbadr address;
;      declare uqcb based uqcbadr userqcb;
;      declare qcbadr address;
;      declare qcb based qcbadr queuehead;
;      declare cqcb based qcbadr circularqueue;
;      declare lqcb based qcbadr linkedqueue;

;      qcbadr = uqcb.pointer;
	LDAX	B
	MOV	E,A
	INX	B
	LDAX	B
	DCX	B
	MOV	D,A
;      if qcb.msglen < 3 then
	LXI	H,000BH
	DAD	D
	MOV	A,M
	ORA	A
	JNZ	@28
	DCX	H
	MOV	A,M
	CPI	3H
	JNC	@28
;      do;  /* writing message to a circular queue */
;        enter$region;
	DI
;        if cqcb.nmbmsgs <> cqcb.msgcnt
	LXI	H,000CH
	DAD	D
	MOV	A,M
	INX	H
	MOV	H,M
	MOV	L,A
	JMP	@29
;          then return writeq(uqcbadr);
;      end;
@28:
;      else
;      do;  /* writing message to a linked queue */
;        enter$region;
	DI
;        if lqcb.bh <> 0 then return writeq(uqcbadr);
	LXI	H,0000H
@29:
	PUSH	H
	LXI	H,0016H
	DAD	D
	MOV	E,M
	INX	H
	MOV	D,M
	POP	H
	MOV	A,E
	CMP	L
	JNZ	WRITEQ
	MOV	A,D
	CMP	H
	JNZ	WRITEQ
;      end;
;      exit$region;
	CALL	EXITR
;      return 0FFH;
	MVI	A,0FFH
	RET
;    end cwriteq;

;end queue;
	END
