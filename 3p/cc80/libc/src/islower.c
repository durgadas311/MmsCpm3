/* islower  -  is the input in [a..z] ?
*/
islower(c) {
/*  return ('a' <= c && c <= 'z'); */
#asm
	LXI H,2
	DAD SP
	MOV A,M
	LXI H,0
	CPI 'a'
	RC
	CPI 'z'+1
	RNC
	INR L
#endasm
}

