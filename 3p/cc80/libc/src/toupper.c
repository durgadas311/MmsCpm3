/* toupper - Convert character to upper case if in [a..z].  */
toupper(c) {
/*	if ('a' <= c && c <= 'z')
		return (c - 0x20);
	return (c);			*/
#asm
	LXI H,2
	DAD SP
	MOV L,M
	MVI H,0
	MOV A,L
	CPI 'a'
	RC
	CPI 'z'+1
	RNC
	XRI 20H
	MOV L,A
#endasm
}

