	title	'MP/M II V2.0 Clock Process'
	name	'clock'
	dseg
@@clock:
	public	@@clock
	cseg
;clock:
@clock:
	public	@clock
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
;$include (datapg.ext)
;$nolist

;  xdos:
	extrn	xdos
;    procedure (func,info) address external;
;      declare func byte;
;      declare info address;
;    end xdos;

;  declare tod structure (
	extrn	tod
;    day address,
;    hr byte,
;    min byte,
;    sec byte ) external;

	dseg
;/*
;  Clock Process Data Segment
;*/
;  declare clock$pd process$descriptor public
;    initial (0,rtr$status,20,.tick$entrypt,
;             'Clock   ',0,0ffh,0);
clockpd:
	public	clockpd
	extrn	clipd
	dw	clipd	; pl
	db	0	; status
	db	20	; priority
	dw	clockentrypt	; stkptr
	db	'Clock   '	; name
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

;  declare clock$stk (10) address
;    initial (restarts,.clock);
clockstk:
	dw	0c7c7h,0c7c7h,0c7c7h
	dw	0c7c7h,0c7c7h,0c7c7h
	dw	0c7c7h,0c7c7h,0c7c7h
clockentrypt:
	dw	clock
	cseg


;/*
;  clock:
;          The purpose of the clock process is to maintain a time
;        of day clock.  It utilizes the XDOS delay function to
;        increment the PUBLIC clock every one second.
;*/

;  clock:
clock:
;    procedure;
;      declare ret byte;

;      do forever;
@4:
;        ret = xdos (flag$wait,2);
	MVI	E,2H
	MVI	C,84H
	CALL	XDOS
;        if (tod.sec := dec (tod.sec + 1)) = 60h then
	LXI	H,TOD+4H
	MOV	A,M
	INR	A
	DAA
	MOV	M,A
	SUI	60H
	JNZ	@4
;        do;
;          tod.sec = 0;
	MOV	M,A
;          ret = xdos (flag$set,3);
	MVI	E,3H
	MVI	C,85H
	CALL	XDOS
;          if (tod.min := dec (tod.min + 1)) = 60h then
	LXI	H,TOD+3H
	MOV	A,M
	INR	A
	DAA
	MOV	M,A
	SUI	60H
	JNZ	@4
;          do;
;            tod.min = 0;
	MOV	M,A
;            if (tod.hr := dec (tod.hr + 1)) = 24h then
	DCX	H
	MOV	A,M
	INR	A
	DAA
	MOV	M,A
	SUI	24H
	JNZ	@4
;            do;
;              tod.hr = 0;
	MOV	M,A
;              tod.day = tod.day + 1;
	LHLD	TOD
	INX	H
	SHLD	TOD
;            end;
;          end;
;        end;
;      end;
	JMP	@4
;    end clock;
;end clock;
	END
