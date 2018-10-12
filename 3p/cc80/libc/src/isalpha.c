/* isalpha  -  is the input in [A..Z, a..z] ?
*/
isalpha(c) {
/*  return (('A' <= c && c <= 'Z') || ('a' <= c && c <= 'z')); */
#asm
	LXI H,2
	DAD SP
	MOV A,M
	LXI H,0
	CPI 'A'
	RC
	CPI 'z'+1
	RNC
	INR L
	CPI 'a'
	RNC
	CPI 'Z'+1
	RC
	DCR L
#endasm
}

