/* isdigit  -  is the input in [0..9] ?
*/
isdigit(c) {
/*  return ('0' <= c && c <= '9'); */
#asm
	LXI H,2
	DAD SP
	MOV A,M
	LXI H,0
	CPI '0'
	RC
	CPI '9'+1
	RNC
	INR L
#endasm
}

