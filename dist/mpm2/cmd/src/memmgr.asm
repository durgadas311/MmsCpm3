	title	 'MP/M II V2.0 Memory Management'
	name	'memmgr'
	dseg
@@memmgr:
	public	@@memmgr
	cseg
;memory$manager:
@memmgr:
	public	@memmgr
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
;$include (memmgr.lit)
;$nolist
;$include (proces.lit)
;$nolist
;$include (datapg.ext)
;$nolist
;$include (proces.ext)
;$nolist

;  declare rlr address external;
	extrn	rlr

;  declare nmbsegs byte external;
	extrn	nmbsegs

;  declare msegtbl (1) structure (memory$descriptor);
	extrn	msegtbl

;  declare maxseg literally 'nmbsegs - 1';

;  exitr:
	extrn	exitr
;    procedure external;
;    end exitr;

; memory descriptor offsets
size	equ	1
attrib	equ	2

;  declare user$process literally 'userpr';
;  user$process:
userpr:Š	public	userpr
;    procedure (pdadr) byte public;
;      declare pdadr address;
;      declare pd based pdadr process$descriptor;

;      return not (pd.memseg = 0ffh);
	LXI	H,0FH
	DAD	B
	MOV	A,M
	INR	A
	RZ
	MVI	A,0FFH
	RET
;    end user$process;

;  declare i byte;

;  abs$rq:
absrq:
	public	absrq
;    procedure (mdadr) byte public reentrant;
;      declare mdadr address;
;      declare md based mdadr memory$descriptor;

;      enter$region;
	DI
;        do i = 0 to maxseg;
	LDA	NMBSEGS
	MOV	E,A
	LXI	H,MSEGTBL-2
@8:
	INX	H
	INX	H
	INX	H
	INX	H
;          if (memsegtbl(i).attrib and allocated) = 0 then
	MVI	A,80H
	ANA	M
	JNZ	@1
;          do;
;            if memsegtbl(i).base = md.base then
	DCX	H
	DCX	H
	LDAX	B
	CMP	M
	INX	H
	INX	H
	JNZ	@2
;            do;
;              memsegtbl(i).attrib = memsegtbl(i).attrib
;                                      or allocated;
	MVI	A,80H
	ORA	M
	MOV	M,A
;              md.size = memsegtbl(i).size;Š	INX	B
	DCX	H
	MOV	A,M
	STAX	B
;              md.attrib = memsegtbl(i).attrib;
	INX	B
	INX	H
	MOV	A,M
	STAX	B
;              md.bank = memsegtbl(i).bank;
	inx	b
	inx	h
	mov	a,m
	stax	b
;              rlrpd.memseg = i;
	LXI	B,0FH
	LHLD	RLR
	DAD	B
	LDA	NMBSEGS
	SUB	E
	MOV	M,A
;              exit$region;
	CALL	EXITR
;              return 0;
	XRA	A
	RET
;            end;
@2:
;          end;
@1:
;        end;
	DCR	E
	JNZ	@8
;      exit$region;
	CALL	EXITR
;      return 0FFH;
	MVI	A,0FFH
	RET
;    end abs$rq;

	dseg
;  declare j byte;
;  declare fit$size byte;
;  declare fit$index byte;
fitindex:
	ds	1
	cseg

;  /*
;    rel$rq:
;          The purpose of the relocatable memory request procedure
;        is to find the unallocated memory segment which best fits
;        the size request.
;  */
;  rel$rq:Šrelrq:
	public	relrq
;    procedure (mdadr) byte public reentrant;
;      declare mdadr address;
;      declare md based mdadr memory$descriptor;

;      enter$region;
	DI
;        fit$size = 0ffh;
	MVI	D,0FFH	; D = fitsize
;        do j = 0 to maxseg;
	LDA	NMBSEGS
	MOV	E,A
	LXI	H,MSEGTBL-2
	INX	B	; BC = .MD.SIZE
@10:
	INX	H
	INX	H
	INX	H
	INX	H
;          if (memsegtbl(j).attrib and allocated) = 0 then
	MVI	A,80H
	ANA	M
	JNZ	@3
;          do;
;            if memsegtbl(j).size >= md.size then
	DCX	H
	LDAX	B
	DCR	A
	CMP	M
	JNC	@4
;            do;
;              if memsegtbl(j).size <= fit$size then
	MOV	A,D
	CMP	M
	JC	@5
;              do;
;                fit$index = j;
	LDA	NMBSEGS
	SUB	E
	STA	FITINDEX
;                fit$size = memsegtbl(j).size;
	MOV	A,M
	MOV	D,A
;              end;
@5:
;            end;
@4:
;          end;
	INX	H
@3:
;        end;
	DCR	E
	JNZ	@10
@11:Š;        if fit$size <> 0ffh then
	INR	D
	JZ	@6
	DCR	D
	LHLD	FITINDEX
	MVI	H,0
	DAD	H
	DAD	H
	LXI	D,msegtbl	; MEMSEGTBL
	DAD	D
;        do;
;          md.base = memsegtbl(fit$index).base;
	DCX	B
	MOV	A,M
	STAX	B
;          md.size = memsegtbl(fit$index).size;
	INX	H
	INX	B
	MOV	A,M
	STAX	B
;          memsegtbl(fit$index).attrib =
;            memsegtbl(fit$index).attrib or allocated;
	INX	H
	MVI	A,80H
	ORA	M
	MOV	M,A
;          md.attrib = memsegtbl(fit$index).attrib;
	INX	B
	STAX	B
;          md.bank = memsegtbl(fit$index).bank;
	inx	h
	inx	b
	mov	a,m
	stax	b
;          rlrpd.memseg = fit$index;
	LXI	B,0FH
	LHLD	RLR
	DAD	B
	LDA	FITINDEX
	MOV	M,A
;          exit$region;
	CALL	EXITR
;          return 0;
	XRA	A
	RET
;        end;
@6:
;      exit$region;
	CALL	EXITR
;      return 0FFH;
	MVI	A,0FFH
	RET
;    end rel$rq;

;  mem$fr:Šmemfr:
	public	memfr
;    procedure (mdadr) public reentrant;
;      declare mdadr address;
;      declare md based mdadr memory$descriptor;
;      declare i byte;

;      do i = 0 to maxseg;
	LDA	NMBSEGS
	MOV	E,A
	LXI	H,MSEGTBL-4
@12:
	INX	H
	INX	H
	INX	H
	INX	H
;        if memsegtbl(i).base = md.base then
	LDAX	B
	CMP	M
	JNZ	@7
;        do;
;          if memsegtbl(i).bank = md.bank then
	PUSH	H
	PUSH	B
	INX	H
	INX	H
	INX	H
	INX	B
	INX	B
	INX	B
	LDAX	B
	CMP	M
	POP	B
	POP	H
	JNZ	@7
;          do;
;            memsegtbl(i).attrib = memsegtbl(i).attrib
;                                   and (not allocated);
	INX	H
	INX	H
	MVI	A,7FH
	ANA	M
	MOV	M,A
;            return;
	RET
;          end;
;        end;
@7:
;      end;
	DCR	E
	JNZ	@12
;    end mem$fr;
	RET

;end memory$manager;Š	END
