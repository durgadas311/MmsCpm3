/*	*	*/

strcmp(str1, str2)
char *str1, *str2;
{
#asm
	POP	B	; return address
	POP	H	; get first string (str2)
	POP	D	; get second string (str1)
	PUSH	D	; restore stack for caller
	PUSH	H
	PUSH	B
SCLOOP: LDAX	D	; get next byte from second string
	CMP	M	; compare that with first string
	JNZ	SCDIFF	; they didn't compare
	INX	D	; increment both pointers
	INX	H
	ORA	A	; both the same.  see if both zero
	JNZ	SCLOOP	; nope.  get the next ones
	LXI	H,0	; yup.	they matched all the way to the null
	JMP	SCRET	; unified return for timing
SCDIFF: LXI	H,-1	;
	JC	SCRET	; first string < second string
	LXI	H,1	; first string > second string
SCRET:	DS	0	; unified return
#endasm
}

