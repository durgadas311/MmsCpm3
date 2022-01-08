	title	'MP/M II V2.0 Abort Resident System Process'
	name	'abort'
	cseg
;abort:
;do;

;$include (copyrt.lit)
;/*
;  Copyright (C) 1979, 1980, 1981
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
;$include (mon2.lit)
;$nolist
;$include (datapg.ext)
;$nolist
;$include (mon2.ext)
;$nolist
;$include (bdos.ext)
;$nolist

;  declare rlrpd based rlr process$descriptor;

;/*
;  Abort Process Data Segment
;*/
;  declare os address;
os:	dw	$-$

;  declare abort$pd process$descriptor
;    initial (0,rtr$status,20,.abort$entrypt,
;             'ABORT  ',' '+80h,0,0ffh,0);
abortpd:
	dw	0	; pl
	db	0	; status
	db	20	; priority
	dw	abortentrypt	; stkptr
	db	'ABORT  ',' '+80h ; name
	db	$-$	; console
	db	0ffh	; memseg (system)
	dw	$-$	; b
	dw	$-$	; thread
	dw	$-$	; disk set DMA
	db	$-$	; disk select / user code
	dw	$-$	; dcnt
	db	$-$	; searchl
	dw	$-$	; searcha
	dw	$-$	; drvact
	ds	20	; registers
	ds	2	; scratch

apcb:
abtpd:	dw	0
abortmsg:
param:
dskslct: ds	1
console: ds	1
pname:	ds	8
abtcns:	ds	1
	ds	1	;filler for 12 byte message


;  declare abort$stk (15) address
;    initial (restarts,.abort);
abortstk:
	dw	0c7c7h,0c7c7h,0c7c7h
	dw	0c7c7h,0c7c7h,0c7c7h
	dw	0c7c7h,0c7c7h,0c7c7h
	dw	0c7c7h,0c7c7h,0c7c7h
	dw	0c7c7h,0c7c7h
abortentrypt:
	dw	abort

;  declare abort$lqcb structure (
;    lqueue,
;    buf (14) byte )
;    initial (0,'ABORT   ',12,1);
abortlqcb:
	dw	$-$	; ql
	db	'ABORT   '	; name
	dw	12	; msglen
	dw	1	; nmbmsgs
	dw	$-$	; dqph
	dw	$-$	; nqph
	dw	$-$	; mh
	dw	$-$	; mt
	dw	$-$	; bh
	ds	2	; link
	ds	12	; buf (12) byte
;  declare abort$uqcb userqcbhead
;    initial (.abort$lqcb,.dskslct);
abortuqcb:
	dw	abortlqcb	; pointer
	dw	abortmsg	; msgadr

abortfail:
	db	'Abort failed.'
	db	'$'


;/*
;  abort:
;          The purpose of the abort process is to abort
;        the specified process.

;  Entry Conditions:
;        None

;  Exit Conditions:
;        None

;*/

;  abort:
abort:
;    procedure;
;      declare i byte;

;      call mon1 (make$queue,.abort$lqcb);
	LXI	D,ABORTLQCB
	MVI	C,86H
;      do forever;
@4:
	CALL	MON1
;        call mon1 (read$queue,.abort$uqcb);
	LXI	D,ABORTUQCB
	MVI	C,89H
	CALL	MON1
;        abortpd.console = console;
	LDA	CONSOLE
	sta	abortpd+0eh
	push	psw		;save abtcns

	lxi	h,pname
	mvi	c,10
namefill:
	mov	a,m
	ora	a
	jz	spacefill
	cpi	' '
	jz	cnspcfd
	inx	h
	dcr	c
	jnz	namefill
	jmp	@7
cnspcfd:
	inx	h
	mov	a,m
	pop	d
	push	psw
	dcx	h
spacefill:
	mvi	m,' '
	inx	h
	dcr	c
	jnz	spacefill
         
@7:
	pop	psw
	ani	0fh
	sta	abtcns
;        /* parameters to MON2 abort process are terminate
;           system or non-sytem process & release memory segment */
;	apcb.param = 00ffh;
	lxi	h,00ffh
	shld	param
;        if mon2 (abort$process,.apcb) = 255 then
	LXI	D,apcb
	MVI	C,9dH
	CALL	MON2
	INR	L

;        do;
;          call mon1 (9,.('Abort failed.','$'));
	mvi	c,9
	LXI	d,abortfail
	cz	mon1
;        end;
@9:
;        call mon1 (detlst,0);
	mvi	c,9fh
	call	mon1
;        call mon1 (detach,0);
	MVI	C,93H
;      end; /* forever */
	JMP	@4
;    end abort;

;  mon1:
mon1:
;    procedure (func,info) external;
;      declare func byte;
;      declare info address;
;    end mon1;

;  mon2:
mon2:
;    procedure (func,info) byte external;
;      declare func byte;
;      declare info address;
;    end mon2;

	lhld	os
	pchl

;end abort;
	END
