#asm
; CLIBRARY.ASM 3.0 (2/2/84) - (c) 1982, 1983, 1984 Walter Bilofsky
; Multiply and divide routines (c)1981 UltiMeth Corp. Permission is gran-
; ted to reproduce them without charge, provided this notice is included.

	;maclib	core	/* entry points to ROMX */
#include "core.lib"
	extrn	main,c@ugt,c@uge
	public	exit,?END
#endasm
/* CLIBIO.C : includes environment dependent routines (e.g, argument list
  	      preparation, I/O).  This code is not ROMable and must
  	      be replaced if a ROMable object module is to be generated.
   IMPORTANT: CLIBIO must be loaded last in the object module to define ?END.
*/
/* Version for "newmon" a.k.a ROMX EEPROM standalone programs */

/* C/80 3.1 runtime library. (c) 1983 Walter Bilofsky.	All rights
   reserved.  This library in C source and assembler source form may
   not be copied or transmitted to other than the original purchaser
   of C/80.  Executable object modules including code produced by
   C/80 and by this library may be distributed without restriction;
   acknowledgement that C/80 is used would be appreciated. */

/* Get all possible memory and put stack up at the top. */

#define	MEMTOP	0e000h	/* a reasonable end for ROMX */
#define	ARGLIN	02280h	/* where commandline is stored */
#define	CR	13
#define	LF	10

C_lib () {	/* this just to cause generation of code in CODE section, */
		/* although it has to be RAM as we will overlay this area */
		/* with arguments */
#asm

?AS	EQU	$+2		/* CP/M- use this code area for argv arg list */
?AG	EQU	$

?INIT:	DW	0		/* No-op; initializes ?AG */
	lxi	h,MEMTOP
	SPHL			/* Set up stack */
?A81:	LXI	H,ARGLIN	/* Get address of arg line - includes progname */
	MOV	a,M		/* And char count */
	mvi	m,' '
	inx	h
	adi	1
	ani	not 1
	mov	e,a
	MVI	D,0
	DAD	D		/* Get end of string */
	inr	e	/* some more adjustement needed */
	inr	e	/* some more adjustement needed */
	LXI	B,0		/* Push 2 0 bytes to start */
?A8:	PUSH	B
	MOV	B,M		/* Move string onto stack 2 bytes at a time */
	DCX	H		/* (necessary because CP/M 1.4 clobbers 80H) */
	MOV	C,M
	DCX	H
	DCR	E
	DCR	E
	JP	?A8

	LXI	H,?AS		/* Push fwa of arg stack */
	PUSH	H
	LXI	H,2		/* Leave arg line address in HL */
	DAD	SP
?A2:	DS	0		/* Scan next argument. */
?A7:	MOV	A,M		/* Skip over blanks between args. */
	INX	H		
	ORA	A		
	JZ	?A6		/* Terminate on 0 byte */
	CPI	' '
	JZ	?A7
	MOV	C,A		/* Save first character of arg in C */
	CPI	'"'		/* If it's a quote character, leave it */
	JZ	?A3		/*  (so C contains terminator char) */
	CPI	047Q		/* single quote */
	JZ	?A3
	MVI	C,' '		/* Otherwise terminate on blank */
	DCX	H		/*  and include first char in arg */
?A3:	POP	D		/* Store address of arg in arg list */
	MOV	A,L
	STAX	D
	INX	D
	MOV	A,H
	STAX	D
	INX	D
	PUSH	D
	DCX	H
?A9:	INX	H		/* Skip to end of argument */
	MOV	A,M
	ORA	A
	JZ	?A5
	CMP	C
	JNZ	?A9
	MVI	M,0		/* Terminate arg with 0 byte */
	INX	H
?A5:	PUSH	H		/* Save address of arg on stack */
	LXI	H,?AG		/* Bump arg count */
	INR	M
	POP	H		/* Restore command line pointer */
	JMP	?A2		/* Go do next arg */
?A6:	POP	H		/* Done with command line.  Put -1 at end */
	MVI	M,-1		/* of array, push argv and argc. */
	INX	H
	MVI	M,-1
	LHLD	?AG
	PUSH	H
	LXI	H,?AS
	PUSH	H
	CALL	main
exit:	/* no files - nothing to close */
?B4:	LHLD	retmon
	PCHL
#endasm
}

/* Allocate memory; return -1 if none available (with 500 byte threshold) */

/* WARNING : upon program execution, ?LM MUST point to the very end
	     of the program.  Because LINK and L80 load the data segment
	     differently, only LINK is supported.
*/
sbrk (n) int n; {
#asm
	POP	D
	POP	B
	PUSH	B
	PUSH	D
	LHLD	?LM
	PUSH	H
	PUSH	H
	POP	D
	DAD	B
	PUSH	H
	PUSH	H
	CALL	c@ugt
	POP	D
	JNZ	sbrk1
	LXI	H,-500
	DAD	SP
	CALL	c@uge
sbrk1:	POP	D
	POP	B
	LXI	H,-1
	RNZ
	XCHG
	SHLD	?LM
	PUSH	B
	POP	H
	RET
?LM:	DW	Q8QENDD
#endasm
}

/* Get a line from the console */
gets(s) char *s; {
#asm
	pop	b
	pop	h	/* buffer to HL */
	push	h
	push	b
	push	h
	call	linin
	pop	h	/* return 's' */
#endasm
}

/* Get a character from the console */
getchar() {
/*	return getc(fin);	*/
#asm
chrin:	call	conin	/* call ROMX conin */
	mov	l,a
	mvi	h,0
#endasm
}

/* put a line to the console, with LF */
puts(s) char *s; {
#asm
	pop	b
	pop	h	/* buffer to HL */
	push	h
	push	b
PS0:	mov	a,m
	ora	a
	jz	PS1
	call	chrout
	inx	h
	jmp	PS0
PS1:	mvi	a,LF
	call	chrout
#endasm
}

/* Write a character to the console */
putchar(c) char c; {
  /*	return putc(c,fout);  */
#asm
	POP	B
	POP	D	/* get char */
	PUSH	D
	PUSH	B
PC1:	mov	a,e
	cpi	LF
	jnz	PC0
	mvi	a,CR
	call	chrout
PC0:	mov	a,e
	/*jmp	chrout*/
chrout:	lhld	conout
	pchl	/* call ROMX conout and return */
#endasm
}

getc(unit)
int unit;
{
#asm
	POP	B
	POP	D
	PUSH	D
	PUSH	B
	mov	a,e
	ORA	A	/* If unit 0 */
	JZ	chrin	/* Read from console */
reterr:	lxi	h,-1	/* EOF */
#endasm
}	

putc(c,unit)
char c; int unit;
{
  /*	if ((IOind[unit] & 255) == 0) IOind[unit] = IOind[unit] - 256;	*/
#asm
	POP	B
	POP	D	/* unit in E */
	PUSH	H	/* char in L */
	POP	H
	PUSH	D
	PUSH	B
	mov	a,e
	xchg		/* char to E */
	ORA	A	/* If to console */
	jz	PC1
#endasm
}

/* Routines to write, read one block */
write(unit,buf,count)
int unit;
char *buf;
int count;
{				/* Set up channel and addresses */
#asm
	lxi	h,2
	dad	sp	/* unit */
	mov	a,m
	ora	a
	jnz	reterr
	inx	h
	inx	h	/* buf */
	mov	e,m
	inx	h
	mov	d,m
	inx	h	/* count */
	mov	c,m
	inx	h
	mov	b,m
	xchg		/* buf to HL */
	push	b	/* save count for return */
WR0:	mov	a,m
	call	chrout
	inx	h
	dcx	b
	mov	a,b
	ora	c
	jnz	WR0
	pop	h	/* return count */
#endasm
}

read(unit,buf,count)
int unit;
char *buf;
int count;
{				/* Set up channel and addresses */
#asm
	lxi	h,2
	dad	sp	/* unit */
	mov	a,m
	ora	a
	jnz	reterr
	inx	h
	inx	h	/* buf */
	mov	e,m
	inx	h
	mov	d,m
	inx	h	/* count */
	mov	c,m
	inx	h
	mov	b,m
	xchg		/* buf to HL */
	push	b	/* save count for return */
RD0:	call	conin
	mov	m,a
	inx	h
	dcx	b
	mov	a,b
	ora	c
	jnz	RD0
	pop	h	/* return count */

?END:	DS	0	/* End of library (code segment) */
#endasm
}
char Q8QENDD;		/* End of library (data segment) */
#asm
	END	?INIT
#endasm
