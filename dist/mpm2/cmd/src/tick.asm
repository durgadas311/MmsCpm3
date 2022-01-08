	title	'MP/M II V2.0 Tick Process'
	name	'tick'
	dseg
@@tick:
	public	@@tick
	cseg
;tick:
@tick:
	public	@tick
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

;  stpclk:
	extrn	stpclk
;    procedure external;
;    end stpclk;

;  declare dlr address external;
	extrn	dlr

;  declare drl address exteranl;
	extrn	drl

	dseg
;/*
;  Tick Process Data Segment
;*/
;  declare tick$pd process$descriptor public
;    initial (0,rtr$status,10,tick$entrypt,
;             'Tick   ',0,0ffh,0,0,0);
tickpd:
	public	tickpd
	extrn	clockpd
	dw	clockpd	; pl
	db	0	; status
	db	10	; priority
	dw	tickentrypt	; stkptr
	db	'Tick    '	; name
	db	$-$	; console
	db	0ffh	; memseg (system)
	dw	$-$	; b
	dw	$-$	; thread
	dw	$-$	; disk set DMA
	db	$-$	; disk select / user code
	dw	$-$	; dcnt
	db	$-$	; searchl
	dw	$-$	; searcha
	ds	2	; drvact
	ds	20	; registers
	ds	2	; scratch

;  declare tick$stk (10) address
;    initial (restarts,.tick);
tickstk:
	dw	0c7c7h,0c7c7h,0c7c7h
	dw	0c7c7h,0c7c7h,0c7c7h
	dw	0c7c7h,0c7c7h,0c7c7h
tickentrypt:
	dw	tick

;  declare ret byte;

;  declare pdadr address;
;  declare pd based pdadr process$descriptor;
	cseg


;/*
;  tick:
;*/

;  tick:
tick:
;    procedure;

;      do forever;
@4:
	ei
;        ret = xdos (flag$wait,1);
	MVI	E,1
	MVI	C,84H
	CALL	XDOS
	di
;        if dlr <> 0 then
	LHLD	DLR
	MOV	A,H
	ORA	L
	JZ	@4
;        do;
;          pdadr = dlr;
	XCHG
;          if (pd.b := pd.b - 1) = 0 then
	LXI	H,10H
	DAD	D
	mov	c,m
	inx	h
	mov	b,m
	dcx	b
	mov	m,b
	dcx	h
	mov	m,c
	mov	a,b
	ora	c
	jnz	@2
;          do while (pdadr <> 0) and (pd.b = 0);
@6:			; DE = pdadr, HL = pd.b
	MOV	A,D
	ORA	E
	JZ	@2
	LXI	H,10H
	DAD	D
	MOV	A,M
	INX	H
	ORA	M
	JNZ	@2
;            dlr = pd.pl;
	XCHG
	MOV	E,M
	INX	H
	MOV	D,M
	XCHG
	SHLD	DLR
;            pd.pl = drl;
	LHLD	DRL
	XCHG
	MOV	M,D
	DCX	H
	MOV	M,E
;            drl = pdadr;
	SHLD	DRL
;            pdadr = dlr;
	LHLD	DLR
	XCHG
;          end;
	JMP	@6
@7:
@2:
;          if dlr = 0 then call stp$clk;
	LHLD	DLR
	MOV	A,H
	ORA	L
	CZ	STPCLK
;        end;
;      end;
	JMP	@4
;    end tick;
;end tick;
	END
