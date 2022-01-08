	title	 'MP/M II V2.0 List Handler'
	name	'lst'
	dseg
@@lst:
	public	@@lst
	cseg
;List$handler:
@lst:
	public	@lst
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

;  declare list$attlsted (1) address external;
	extrn	lstatt

;  declare list$queue (1) address external;
	extrn	lstque

;  declare drl address external;
	extrn	drl

;  declare thread$root address external;
	extrn	thrdrt

;  declare nmb$lst byte external;
;	extrn	nmblst

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
;      if (list$attlsted(pd.console) = pdadr)
	LXI	H,0EH
	DAD	B
	MOV	a,M
	ani	0f0h
	rrc
	rrc
	rrc
	rrc
	mov	e,a
	INX	H
	MVI	D,0
	LXI	H,lstatt
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
;  attlst:
;          The purpose of the attlst procedure is to attlst a
;        list to the calling process.  The list to attlst
;        is obtained from the process descriptor.  If the list
;        is already attlsted to the process or if no one has the
;        list attlsted the process is given the list and
;        is then placed on the DRL list.  If the list is
;        attlsted to some other process the current process is
;        placed on the list queue.

;  Entry Conditions:
;        BC = process descriptor address

;  Exit Conditions:
;        None

;  ****  Note: this procedure must be called from within a
;              critical region.

;*/
;  attlst:
attlst:
	public	attlst
;    procedure (pdadr) reentrant public;
;      declare pdadr address;
;      declare pd based pdadr process$descriptor;

;      if (list$attlsted(pd.console) = pdadr) or
	CALL	CMNCODE
	JZ	@1A
	MOV	A,M
	INX	H
	ORA	M
	JNZ	@1
;         (list$attlsted(pd.console) = 0) then
;      do;
;        list$attlsted(pd.console) = pdadr;
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
;        call insert$process (.list$queue(pd.console),pdadr);
	LXI	H,lstQUE
	DAD	D
	DAD	D
	MOV	D,B
	MOV	E,C
	MOV	B,H
	MOV	C,L
	JMP	INSPR
;      end;
;    end attlst;

;/*
;  detlst:
;          The purpose of the detlst procedure is to detlst the
;        list from the calling process.  After checking to
;        determine that the list is attlsted to the process
;        invoking the detlst, the list is detlsted, attlsting
;        the next waiting process to the list and then placing
;        it on the DRL.

;  Entry Conditions:
;        BC = process descriptor address

;  Exit Conditions:
;        None

;  ****  Note: this procedure must be called from within a
;              critical region.

;*/
;  detlst:
detlst:
	public	detlst
;    procedure (pdadr) reentrant public;
;      declare pdadr address;
;      declare pd based pdadr process$descriptor;

;      if pdadr = list$attlsted(pd.console) then
	CALL	CMNCODE
	RNZ
;      do;
;        list$attlsted(pd.console) = list$queue(pd.console);
	PUSH	H
	LXI	H,lstQUE
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
;        pdadr = list$attlsted(pd.console);
;        if pdadr <> 0 then
	ORA	C
	RZ
;        do;
;          list$queue(pd.console) = pd.pl;
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
;    end detlst;
	RET

;end List$handler;
	END
