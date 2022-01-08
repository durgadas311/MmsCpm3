	title	'MP/M II V2.0 Flag Management'
	name	'flag'
	dseg
@@flag:
	public	@@flag
	cseg
;flag:
@flag:
	public	@flag
;do;

;/*
;  Copyright (C) 1979,1980,1981
;  Digital Research
;  P.O. Box 579
;  Pacific Grove, CA 93950
;
;  Revised:
;    14 Sept 81  by Thomas Rolander
;*/

;/*
;    Common Literals
;*/

;  declare enter$region literally
;    'disable';

;  exitr:
;    procedure external;
	extrn	exitr
;    end exitr;

;  declare exit$region literally
;    'call exitr';

;/*
;    Proces Literals
;*/

;  declare process$header literally
;    'structure (pl address,
;                status byte,
;                priority byte,
;                stkptr address';
;  declare bdos$save literally
;               'disk$set$dma address,
;                disk$slct$byte,
;                dcnt address,
;                searchl byte,
;                searcha address,
;                scratch (13) byte)';
;  declare process$descriptor literally
;               'process$header,
;                name (8) byte,
;                console byte,
;                memseg byte,
;                b address,
;                threadraddress,
;                bdos$save';

;  declare rtr$status       literally '0',
;          FlgWt$status     literally '4';

;/*
;  Data Page Externals
;*/

;  declare rlr address external;
	extrn	rlr

;  declare drl address external;
	extrn	drl

;  declare nmbflags byte external;
	extrn	nmbflags

;  declare sys$flag literally 'sysfla';
;  declare sys$flag (1) address external;
	extrn	sysfla

;/*
;    Proces Externals
;*/

;  declare rlrpdrbased rlr process$descriptor;

;  declare dsptch$param literally 'dparam';
;  declare dsptch$paramraddress external;
	extrn	dparam

;  declare dispatch literally 'dispat';
;  dispatch:
;    procedure external;
	extrn	dispat
;    end dispatch;

;  declare insert$process literally 'inspr';
;  insert$process:
;    procedure (pdladr,pdadr) external;
	extrn	inspr
;      declare (pdladr,pdadr) address;
;    end insert$process;

;  declare pdadr address;

;  declare pd based pdadr process$descriptor;


sharedflagcode:
	; shared flag code, wait & set
	LDA	NMBFLAGS
	MOV	B,A
	MOV	A,C
	CMP	B
	JC	@1
	MVI	A,0FFH
	POP	H	; DISCARD RETURN ADR FROM SHARED
	RET
@1:
;      enter$region;
	DI
;        if sys$flag(flagnmb) <> 0FFFEH then
	MOV	E,C
	MVI	D,0
	LXI	H,SYSFLA
	DAD	D
	DAD	D	; HL = .sys$flag(flagnmb)
	MOV	E,M
	INX	H
	MOV	D,M	; DE = sys$flag(flagnmb)
	MVI	A,0FFH
	CMP	D
	RET

;/*
;  flagwait:
;          The purpose of the flag wait procedure is to wait
;        until a specified flag has been set before continuing
;        execution.  If the flag is already set no waiting
;        occurs.  If a process is already waiting for the same
;        flag, no waiting occurs and the boolean flag under run
;        is set true.

;  Entry Conditions:
;        C  = flag


;  Exit Conditions:
;        A  = return code,
;              where   0 = success,
;                    FFH = failure

;        *** Note *** if waiting is to occur the process remains
;                     in a critical region until dispatch

;*/

;  flag$wait:
flgwt:
	public	flgwt
;    procedure (flagnmb) byte reentrant public;
;      declare flagnmb byte;	; Register C
;      declare ret byte;	; Register B

;      if flagnmb >= nmbflags then return 0FFH;
	CALL	SHAREDFLAGCODE
;      ret = 0;
;      enter$region;
;        if sys$flag(flagnmb) <> 0FFFEH then
	JNZ	@5A
	DCR	A	; A = 0FEH
	CMP	E
	JZ	@2
;        do;
;          if sys$flag(flagnmb) <> 0FFFFH then
	INR	A	; A = 0FFH
	CMP	E
	JNZ	@5A
;          do;
;            /* flag$under$run */
;            ret = 0FFH;
;	   end;
;          else
;          do;
;            rlrpd.status = flgwt$status;
	LHLD	RLR
	INX	H
	INX	H
	MVI	M,4H
;            dsptch$param = flagnmb;
	MOV	L,C
	MVI	H,0
	SHLD	DPARAM
;            call dispatch;
	CALL	DISPAT
;          end;
;        end;
	JMP	@5
@2:
;        else sys$flag(flagnmb) = 0FFFFH;
	DCX	H
	MVI	M,0FFH
@5:
	XRA	A
;      exit$region;
@5A:
	PUSH	PSW
	CALL	EXITR
;      return ret;
	POP	PSW	; A = ret
	RET
;    end flag$wait;

;/*
;  flagset:
;          The purpose of the flag set procedure is to set the
;        specified flag.  If a process is waiting for the flag
;        to be set it is placed on the dispatcher ready list.
;        If the flag is already set the booleanrflag over run
;        is set true.

;  Entry Conditions:
;        C  = flag

;  Exit Conditions:
;        A  = return code,
;              where   0 = success,
;                    FFH = failure
;*/

;  flag$set:
flgset:
	public	flgset
;     procedure (flagnmb) byte reentrant public;
;      declare flagnmb byte;	; Register C
;      derlare ret byte;	; Register B

;      if flagnmb >= nmbflags then return 0FFH;
	CALL	SHAREDFLAGCODE
;      ret = 0;
;      enter$region;
;        pdadr = sys$flag(flagnmb);
;        if pdadr = 0FFFFH then
	JNZ	@9
	CMP	E
	JNZ	@7
;        do;
;          sys$flag(flagnmb) = 0FFFEH;
	DCX	H
	MVI	M,0FEH
;        end;
	JMP	@5
@7:
;        else
;        do;
;          if pdadr = 0FFFEH then
	DCR	A
	CMP	E
	MVI	A,0FFH
	JZ	@5A
;          do;
;            /* flag$over$run */
;            ret = 0FFH;
;          end;
@9:
;          else
;          do;
;            sys$flag(flagnmb) = 0FFFFH;
	MOV	M,A
	DCX	H
	MOV	M,A
;            pd.pl = drl;
	LHLD	DRL
	XCHG
	MOV	M,E
	INX	H
	MOV	M,D
;            drl = pdadr;
	DCX	H
	SHLD	DRL
;            pd.status = rtr$status;
	INX	H
	INX	H
	MVI	M,0H
;          end;
;        end;
	JMP	@5
;      exit$region;
;      return ret;
;    end flag$set;

;end flag;
	END
