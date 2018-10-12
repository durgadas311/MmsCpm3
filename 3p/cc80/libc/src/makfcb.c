/* makfcb(file,fcb) - unpack filename into char fcb[36]. */
makfcb(file,fcb) {
#asm
	POP B
	POP H
	POP D
	PUSH D
	PUSH H
	PUSH B
#endasm
	x0fcb();
}

