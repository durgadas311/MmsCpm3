/*	*	*/

strcpy(to, from)
char *to, *from;
{
#asm
	POP	B	; return address
	POP	H	; get from arg
	POP	D	; get to arg
	PUSH	D	; restore stack for caller
	PUSH	H
	PUSH	B
	DCX	H	; back off for a running start
STLOOP: INX	H	; point at next FROM char
	MOV	A,M	; put it into accumulator
	STAX	D	; store it in TO string
	INX	D	; increment TO string
	ORA	A	; check for last char
	JNZ	STLOOP	; copied the 0 byte.  Go away.
#endasm
}

