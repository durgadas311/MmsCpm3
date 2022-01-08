	title	'MP/M II V2.0 Attach Process'
	name	'attch'
	dseg
@@attch:
	public	@@attch
	cseg
;attch:
@attch:
	public	@attch
;do;

;/*
;  Copyright (C) 1979, 1980,1981
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
;$include (datapg.ext)
;$nolist
;$include (xdos.ext)
;$nolist
;$include (bdos.ext)
;$nolist

;  declare rlr address external;
	extrn	rlr

;  nfxdos:
;    procedure (func,info) external;
	extrn	nfxdos
;      declare func byte;
;      declare info address;
;    end nfxdos;

;  xdos:
;    procedure (func,info) byte external;
	extrn	xdos
;      declare func byte;
;      declare info address;
;    end xdos;

;  printb:
;    procedure (bufferadr) external;
	extrn	printb
;      declare bufferadr address;
;    end printb;

;  declare rlrpd based rlr process$descriptor;

;/*
	dseg
;  Attach Process Data Segment
;*/
;  declare attch$pd process$descriptor public
;    initial (0,rtr$status,20,.attch$entrypt,
;             'ATTACH ',' '+80h,0,0ffh,0);
attchpd:
	public	attchpd
	dw	0	; pl
	db	0	; status
	db	20	; priority
	dw	attchentrypt	; stkptr
	db	'ATTACH ',' '+80h	; name
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
	ds	2	; sratch

;  declare attch$stk (14) address
;    initial (restarts,.attch);
attchstk:
	dw	0c7c7h,0c7c7h,0c7c7h
	dw	0c7c7h,0c7c7h,0c7c7h
	dw	0c7c7h,0c7c7h,0c7c7h
	dw	0c7c7h,0c7c7h,0c7c7h
	dw	0c7c7h
attchentrypt:
	dw	attch

;  declare attch$lqcb structure (
;    lqueue,
;    buf (12) byte )
;    initial (0,'ATTACH  ',10,1);
attchlqcb:
	dw	$-$	; ql
	db	'ATTACH  '	; name
	dw	10	; msglen
	dw	1	; nmbmsgs
	dw	$-$	; dqph
	dw	$-$	; nqph
	dw	$-$	; mh
	dw	$-$	; mt
	dw	$-$	; bh
	ds	12	; buf (12) byte
;  declare attch$uqcb userqcbhead public
;    initial (.attch$lqcb,.field);
attchuqcb:
	dw	attchlqcb	; pointer
	dw	field		; msgadr
;  declare field (11) byte;
field:
	ds	11
;  declare console byte at (.field(1));
console	equ	field+1
	cseg

atfail:
	db	0dh,0ah
	db	'Attach failed.'
	db	'$'


;/*
;  attch:
;          The purpose of the attach process is to attach
;        the console to the specified process.

;  Entry Conditions:
;        None

;  Exit Conditions:
;        None

;*/

;  attch:
attch:
;    procedure public;
	public	attch
;      declare i byte;

;      call nfxdos (make$queue,.attch$lqcb);
	LXI	D,ATTCHLQCB
	MVI	C,86H
;      do forever;
@4:
	CALL	NFXDOS
;        call nfxdos (read$queue,.attch$uqcb);
	LXI	D,ATTCHUQCB
	MVI	C,89H
	CALL	NFXDOS
;        rlrpd.console = console;
	LXI	B,0EH
	LHLD	RLR
	DAD	B
	LDA	CONSOLE
	MOV	M,A
;        i = 2;
	MVI	C,8
	LXI	H,FIELD+2
;        do while i <> 10;
@6:
;          if field(i) = 0 then
	MOV	A,M
	ORA	A
	JNZ	@1
;          do while i <> 10;
@8:
;            field(i) = ' ';
	MVI	M,20H
;            i = i + 1;
	INX	H
	DCR	C
	JNZ	@8
	JMP	@7
;          end;
@1:
;          else i = i + 1;
	INX	H
	DCR	C
	JNZ	@6
;        end;
@7:
;        /* specify that console of attached process must
;           match that currently of the attach process    */
;        field(10) = 0ffh;
	MVI	M,0FFH
;        if xdos (assign$console,.field(1)) = 255 then
	LXI	D,FIELD+1H
	MVI	C,95H
	CALL	XDOS
	INR	L
;        do;
;          call printb (.('Attach failed.','$'));
	LXI	B,atfail
	CZ	PRINTB
;        end;
;        call nfxdos (detlst,0);
	mvi	c,9fh
	call	xdos
;        call nfxdos (detach,0);
	MVI	C,93H
;      end; /* forever */
	JMP	@4
;    end attch;

;end attch;
	END
