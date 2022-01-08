	title	 'MP/M II V2.0 Release Console & List Devices'
	name	'rlsdev'
	dseg
@@rlsdev:
	public	@@rlsdev
	cseg
;release$devices:
@rlsdev:
	public	@rlsdev
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

;  declare console$attached (1) address external;
	extrn	cnsatt

;  declare console$queue (1) address external;
	extrn	cnsque

;  declare list$attached (1) address external;
	extrn	lstatt

;  declare list$queue (1) address external;
	extrn	lstque

;  declare drl address external;
	extrn	drl

;  declare sysdat address external;
	extrn	sysdat

;  declare nmbdev literally '16';
nmbdev	equ	16


;  exitr:
	extrn	exitr
;    procedure external;
;    end exitr;

;  detach:
	extrn	detach
;    procedure (pdadr) external;
;      declare pdadr address;
;    end detach;

;  detlst:
	extrn	detlst
;    procedure (pdadr) external;
;      declare pdadr address;
;    end detlst;

	dseg
;  declare device byte;
device:	ds	1
;  declare rlsdevsub address;
rlsdevsub:
	ds	2

	cseg
;  rlscon:
rlscon:
;    procedure (pdadr) public;
	public	rlscon

;	*** NOTE *** this procedure assumes that a
;			critical region has been entered

	lxi	d,cnsatt
	lxi	h,rlsconsub
	jmp	rlsdev

;  rlslst:
rlslst:
;    procedure (pdadr) public;
	public	rlslst

;	*** NOTE *** this procedure assumes that a
;			critical region has been entered

	lxi	d,lstatt
	lxi	h,rlslstsub
;	jmp	rlsdev

rlsdev:
	;BC = pdadr
	;DE = attach table address
	;HL = rls subroutine address

	shld	rlsdevsub
	xra	a

rlsdevloop:
	sta	device
	cpi	nmbdev
	rz
	ldax	d
	inx	d
	cmp	c
	jnz	rlsdevcont
	ldax	d
	cmp	b
	jnz	rlsdevcont
	lxi	h,rlsdevcont
	push	h
	lhld	rlsdevsub
	push	h
	lxi	h,000eh
	dad	b	;HL = .pd.console
	lda	device
	ret
rlsdevcont:
	inx	d
	lda	device
	inr	a
	jmp	rlsdevloop

rlsconsub:
	push	d
	push	b
	mov	m,a
	call	detach
	pop	b
	pop	d
	ret

rlslstsub:
	push	d
	push	b
	rrc
	rrc
	rrc
	rrc
	mov	m,a
	call	detlst
	pop	b
	pop	d
	ret


;end release$devices;
	END
