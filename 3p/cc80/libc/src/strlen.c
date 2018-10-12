/*	*	*/

strlen(string)
char *string;
{
#asm
	POP	B	; return address
	POP	D	; the string
	PUSH	D	; restore stack
	PUSH	B
	LXI	H,0	; initialize length
SLLOOP: LDAX	D	; get next char
	ORA	A	; test for zero
	JZ	SLDONE	; end of string
	INX	D	; point at next character
	INX	H	; increment counter
	JMP	SLLOOP	; and around again
SLDONE: DS	0	; fall through for timer
#endasm
}

