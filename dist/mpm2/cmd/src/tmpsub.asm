	title	'MP/M II V2.0 Terminal Message Processor & Submit'
	name	'tmpsub'
	dseg
@@tmpsub:
	public	@@tmpsub
	cseg
;tmp:
@tmpsub:
	public	@tmpsub
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
;$include (xdos.lit)
;$nolist
;$include (fcb.lit)
;$nolist
;$include (xdos.ext)
;$nolist
;$include (bdos.ext)
;$nolist
;$include (datapg.ext)
;$nolist

;  xbdos:
;	extrn	xbdos
;    procedure (func,info) address external;
;      declare func byte;
;      declare info address;
;    end xbdos;

sysdatadr:
	dw	$-$

tmp$entry$point:
	jmp	tmp

bdos:
xdos:
	lhld	bdosadr
	pchl

co:
	mvi	c,2
	jmp	bdos

	dseg
;/*
;  TMP Data Segment
;*/

bdosadr:
	ds	2

;  declare rlradr address;
rlradr:
	ds	2

;  declare rlrpd based rlr process$descriptor;


;  declare subflgadr address;
subflgtbladr:
	ds	2
;  declare subflg based subflgadr (1) byte;

	cseg
;  declare cli$name (8) byte data ('c'+80h,'li     ');
cliname:
	db	'c'+80h,'li     '

;  declare submit$fcb (16) byte data (1,'$$$     SUB',
;    0,0,0,0);
submitfcb:
	db	$-$
	db	'$$$     SUB'
	db	0,0,0,0

dskerr:
	db	'Disk error during submit file read.'
	db	0dh,0ah
	db	'$'

startup:
	db	0dh,0ah
	db	'Start up command: '
	db	'$'

;/*
;  tmp:
;*/

;  tmp:
tmp:
	lhld	sysdatadr
	mvi	l,245
	mov	e,m
	inx	h
	mov	d,m
	xchg
	shld	bdosadr
	LXI	H,0FF49H
	DAD	SP
	SPHL
;    procedure reentrant public;
;      declare buf(129) byte;
;      declare fcb fcb$descriptor;
;      declare submit$user byte;
;      declare console byte;
;      declare tmp$user byte;
;      declare ret byte;
;      declare CLIQ (2) address;
;      declare pname (10) byte;

	lhld	sysdatadr
	push	h
	lxi	d,252
	dad	d
	mov	e,m
	inx	h
	mov	d,m
	lxi	h,5
	dad	d
	shld	rlradr
	mov	e,m
	inx	h
	mov	d,m
;      console = rlrpd.console;
	LXI	h,0EH
	DAD	d
	MOV	A,M
	pop	d
	LXI	H,0A6H  ; CONSOLE
	DAD	SP
	MOV	M,A
;      subflgadr = xdos (system$data$adr,0) + 128;
	lxi	h,123	;offset to system file drive
	dad	d
	mov	a,m
	sta	submitfcb
	LXI	h,80H
	DAD	D
	SHLD	SUBFLGTBLADR
;      subflg(console) = false;
	call	subflgadr
	MVI	M,0H
;      submit$flag = false;
	call	lclsubflgadr
	xra	a
	mov	m,a
	dcx	h
	mov	m,a
;      pname(0) = console;
	LXI	H,0A6H  ; CONSOLE
	DAD	SP
	MOV	A,M
	LXI	H,0ADH  ; PNAME
	DAD	SP
	MOV	M,A
;      call move (8,.cli$name,.pname(1));
	INX	H
	XCHG
	LXI	B,CLINAME
	MVI	L,8H
	LDAX	B
	STAX	D
	INX	B
	INX	D
	DCR	L
	JNZ	$-5H
;      pname(9) = 0;
	XCHG
	MOV	M,E
;      call set$dma (.buf(1));
	LXI	H,1H    ; BUF+1H
	DAD	SP
	xchg

;
;  Temporarily swap stack pointers to avoid TMP process
; descriptor destruction.
;
;	lxi	h,00a2h
;	dad	sp
;	sphl

	mvi	c,26
	call	bdos
;      ret = xdos (attach,0);
	MVI	C,92H
	CALL	XDOS
;      call print$b (.ver);
	lhld	sysdatadr
	mvi	l,11	;offset to xdos base
	mov	d,m
	mvi     e,063h	;offset from base of ver module
	mvi	c,9
	call	bdos

;            call move (16,.submit$fcb,.fcb.et);
	LXI	H,81H   ; FCB
	DAD	SP
	XCHG
	LXI	B,SUBMITFCB
	MVI	L,10H
	LDAX	B
	STAX	D
	INX	B
	INX	D
	DCR	L
	JNZ	$-5H
;            fcb.fn(1) = console + '0';
	MVI	A,30H
	LXI	H,0A6H  ; CONSOLE
	DAD	SP
	ADD 	M
	LXI	H,83H   ; FCB+2H
	DAD	SP
	MOV	M,A
	lxi	d,11-2
	dad	d
	mvi	m,'P'
;            if open (.fcb) <> 0ffh then
	LXI	H,81H   ; FCB
	DAD	SP
	xchg
	mvi	c,15
	call	bdos
	INR	A
	jz	@2
	lxi	h,81h
	dad	sp
	xchg
	lxi	h,32
	dad	d
	mvi	m,0	;fcb.cr = 0;
	mvi	c,20
	call	bdos
	inr	a
	push	psw
	lxi	h,81h+2
	dad	sp
	xchg
	mvi	c,16
	call	bdos
	pop	psw
	jz	@2
	lxi	h,1h
	dad	sp
	mvi	b,-1
@2a:
	inr	b
	mov	a,m
	cpi	0dh
	inx	h
	jnz	@2a
	mvi	m,0
	mov	c,b
	inr	c
@2b:
	dcr	c
	jz	@2c
	dcx	h
	dcx	h
	mov	a,m
	inx	h
	mov	m,a
	jmp	@2b
@2c:
	dcx	h
	mov	m,b
	mvi	c,9
	lxi	d,startup
	call	bdos
	jmp	@7c
@2:
;      ret = xdos (detach,0);
	MVI	C,93H
	CALL	XDOS

;	lxi	h,-00a2h
;	dad	sp
;	sphl

;      do forever;
@17:
;        ret = xdos (attach,0);
	MVI	C,92H
	CALL	XDOS
;        call crlf;
	mvi	e,0dh
	call	co
	mvi	e,0ah
	call	co
;        i = rlrpd.disk$slct and 0fh;
	LHLD	rlradr
        mov	c,m
	inx	h
	mov	b,m
	lxi	h,16h
	DAD	B
	MOV	A,M
	PUSH	PSW
	ANI	0FH
;        if (i:=i-10) < 15 then
	SUI	10
	JC	@TMP0
;          call co ('1');
	PUSH	PSW
	MVI	e,'1'
	call	co
	POP	PSW
	SUI	10
;        call co (i + 10 + '0');
@TMP0:
	ADI	10+'0'
	mov	e,a
	call	co
;        call co (shr(rlrpd.disk$slct,4) + 'A');
	POP	PSW
	ANI	0f8h
	RAR
	RAR
	RAR
	RAR
	ADI	41H
	mov	e,a
	call	co
;        call co ('>');
	MVI	e,3EH
	call	co
;        buf(0) = 100;
	LXI	H,0H    ; BUF
	DAD	SP
	MVI	M,100
;        if not submit$flag then
	call	lclsubflgadr
	jnz	@1
;        do;
;          if subflg(console) then
	call	subflgadr
	jz	@6
;          do;
;            call move (16,.submit$fcb,.fcb.et);
	lhld	sysdatadr
	lxi	d,196	;offset to temp file drive
	dad	d
	mov	a,m
	LXI	H,81H   ; FCB
	DAD	SP
	XCHG
	LXI	B,SUBMITFCB
	stax	b	;set drive to current temp file drive
	MVI	L,10H
	LDAX	B
	STAX	D
	INX	B
	INX	D
	DCR	L
	JNZ	$-5H
;            fcb.fn(1) = console + '0';
	MVI	A,30H
	LXI	H,0A6H  ; CONSOLE
	DAD	SP
	ADD 	M
	LXI	H,83H   ; FCB+2H
	DAD	SP
	MOV	M,A
;            if open (.fcb) <> 0ffh then
	LXI	H,81H   ; FCB
	DAD	SP
	xchg
	mvi	c,15
	call	bdos
	INR	A
	jnz	@3
;            subflg(console) = false;
	call	subflgadr
	mvi	m,0
	jmp	@6
;            do;
;              submit$flag = true;
@3:
	lxi	h,0081h
	dad	sp
	xchg
	mvi	c,35
	call	bdos	;compute file size
	mvi	c,32
	mvi	e,0ffh
	call	bdos	;get user number 
	lxi	h,00a5h
	dad	sp
	mov	m,a
;            end;
;          end;
;        end;
@1:
;        if submit$flag and subflg(console) then
	call	subflgadr
	jz	@10a
;        do;
; use buffer area as temporary stack
;	lxi	h,0081h
;	dad	sp
;	sphl
;          if bdos (11,0) then
	MVI	C,0BH
	call	bdos
	RAR
	JNC	@5
;          do;
;            ret = ci;
	mvi	c,1
	call	bdos
;            call bdos (19,.fcb);
;            submit$flag = false;
;          end;
;	lxi	h,-0081h
;	dad	sp
;	sphl
	JMP	@10A
@5:
;	lxi	h,-0081h
;	dad	sp
;	sphl
;          else
;          do;
;            fcb.nr = fcb.rc - 1;
	call	lclsubflgadr
	mov	d,m
	dcx	h
	mov	e,m
	dcx	d
	mov	m,e
	inx	h
	mov	m,d
;            if readbf (.fcb) = 0ffh then
	call	submituser
	LXI	H,81H   ; FCB
	DAD	SP
	xchg
	mvi	c,33
	call	bdos
	INR	A
	JNZ	@7
	call	tmpuser
;            do;
;              call bdos (19,.fcb); /* delete file */
;              submit$flag = false;
;              call print$b (.(
	LXI	d,dskerr
	mvi	c,9
	call	bdos
;                'Disk error during submit file read.','$'));
;              call crlf;
;            end;
	JMP	@10a
@7:
	call	tmpuser
	call	lclsubflgadr
	mov	d,m
	dcx	h
	mov	e,m
	inx	d
	mov	m,e
	inx	h
	mov	m,d
;            else
;            do;
;              i = 2;
@7c:
	LXI	H,2H    ; BUF+2H
	DAD	SP
;              do while buf(i) <> 0;
@7A:
	mov	a,m
	ora	a
	jz	@7B
	mov	e,a
;                call co (.buf(i));
	push	h
	call	co
	pop	h
;                i = i + 1;
	inx	h
;              end;
	jmp	@7A
;              call co (0dh);
@7B:
	mvi	e,0dh
	call	co
	JMP	@9
;            end;
;          end;
;        end;
;        if not submit$flag then
;        do;
@6:
;          call read$bu (.buf);
	LXI	H,0H    ; BUF
	DAD	SP
	mvi	m,80h
	xchg
;
;  The following stack swap is done to prevent destruction
; of the TMP process descriptor by the stack.  The stack used
; during read$bu overlays the TMP fcb and the end of the
; line buffer.  Note that the line buffer length is reduced
; from 128 to 100 bytes.
;
;	lxi	h,00a2h
;	dad	sp
;	sphl
	mvi	c,10
	call	bdos
;	lxi	h,-00a2h
;	dad	sp
;	sphl

;        end;
@9:
;        if (buf(1) <> 0) and
	LXI	H,1H    ; BUF+1H
	DAD	SP
	MOV	A,M
	ORA	A
	JZ	@10
	MOV	B,A
	INX	H
	MOV	A,M
	CPI	';'
	JZ	@10
	MOV	C,A
;           (buf(2) <> ';') then
;        do;
;          if (buf(1) = 2) and (buf(3) = ':') then
	MOV	A,B
	CPI	2
	JNZ	@11
	INX	H
	MOV	A,M
	CPI	':'
	JNZ	@11
;          do;
;            i = (buf(2) and 101$1111b) - 'A';
	MVI	A,5FH
	ANA	C
	SUI	'A'
;            if i < 16
	CPI	10H
	JNC	@13
;              then call bdos (14,i);
	MOV	E,A
	MVI	C,0EH
	call	bdos
;          end;
	JMP	@13
@11:
;          else
;          do;
;            buf(buf(1)+2) = 0;
	LXI	H,1H    ; BUF+1H
	DAD	SP
	MOV	C,M
	MVI	B,0
	LXI	H,2H    ; BUF+2H
	DAD	SP
	DAD	B
	MVI	M,0H
;            call co (0ah);
	MVI	e,0AH
	call	co
;            buf(0) = rlrpd.disk$slct;
	LHLD	rlradr
	mov	c,m
	inx	h
	mov	b,m
	lxi	h,16h
	DAD	B
	MOV	A,M
	LXI	H,0H    ; BUF
	DAD	SP
	MOV	M,A
;            buf(1) = rlrpd.console;
	XCHG
	lhld	rlradr
	mov	c,m
	inx	h
	mov	b,m
	lxi	h,0eh
	dad	b
	mov	a,m
	INX	D
	STAX	D
;            ret = assign (.pname);
	LXI	H,0ADH  ; PNAME
	DAD	SP
	MOV	d,H
	MOV	e,L
	mvi	c,149
	call	xdos
;            ret = xdos (send$cli$command,.CLIQ);
	LXI	H,0     ; buf
	DAD	SP
	XCHG
	MVI	C,150
	CALL	XDOS
;          end;
@13:
;        end;
@10:
;        if submit$flag then
	call	lclsubflgadr
	jz	@17
;        do;
;          if fcb.nr = 1 then
	mov	d,m
	dcx	h
	mov	e,m
	dcx	d
	mov	m,e
	inx	h
	mov	m,d
	mov	a,d
	ora	e
	jnz	@17
@10A:
;          do;
;            call mon1 (19,.fcb); /* delete file */
;            submit$flag = false;
;            call close (.fcb);
	call	submituser
	LXI	H,81H   ; FCB
	DAD	SP
	xchg
	mvi	c,16
	call	bdos
;              call mon1 (19,.fcb); /* delete file */
	LXI	H,81H   ; FCB
	DAD	SP
	XCHG
	MVI	C,13H
	call	bdos
	call	tmpuser
;              submit$flag = false;
	call	lclsubflgadr
	xra	a
	mov	m,a
	dcx	h
	mov	m,a
	call	subflgadr
	mvi	m,0
;              /* free drive */
;              call bdos (39,0ffffh);
	mvi	c,39
	lxi	d,0ffffh
	call	bdos
;          end;
	JMP	@17
;          else
;          do;
;            fcb.rc = fcb.rc - 1;
;            call close (.fcb);
;          end;
;        end;
;      end;
;    end tmp;
;end tmp;

subflgadr:
;		ret = .subflg(console);
	lxi	h,0a6h+2	; console
	dad	sp
	mov	c,m
	mvi	b,0
	lhld	subflgtbladr
	dad	b
	mov	a,m
	ora	a
	ret		;HL = .subflg(console), B = 0

lclsubflgadr:
;		ret = submit$flag;
	lxi	h,081h+33+2	; submitflag
	dad	sp
	mov	a,m
	inx	h
	ora	m
	ret		;HL = submitflag

submituser:
;
	mvi	c,32
	mvi	e,0ffh
	call	bdos
	lxi	h,00a5h+2
	dad	sp
	mov	e,m
	inx	h
	inx	h
	mov	m,a
	mvi	c,32
	jmp	bdos

tmpuser:
;
	lxi	h,00a7h+2
	dad	sp
	mov	e,m
	mvi	c,32
	jmp	bdos

patch:
	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	END
