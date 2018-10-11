/* isupper  -  is the input in [A..Z] ?
*/
isupper(c) {
/*  return ('A' <= c && c <= 'Z'); */
#asm
	LXI H,2
	DAD SP
	MOV A,M
	LXI H,0
	CPI 'A'
	RC
	CPI 'Z'+1
	RNC
	INR L
#endasm
}

