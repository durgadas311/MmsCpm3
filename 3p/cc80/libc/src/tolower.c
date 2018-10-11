/* tolower  -  if the input is in [A..Z], convert to lower case
*/
tolower(c) {
/*  if ('A' <= c && c <= 'Z')
	return (c + 0x20);
    return c;		*/
#asm
	LXI H,2
	DAD SP
	MOV L,M
	MVI H,0
	MOV A,L
	CPI 'A'
	RC
	CPI 'Z'+1
	RNC
	XRI 20H
	MOV L,A
#endasm
}

