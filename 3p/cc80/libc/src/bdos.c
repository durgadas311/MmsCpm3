/* bdos(c,de) - call bdos with given values of c and de.
		return value from register a */
bdos() {
#asm
	extrn bdose
	POP H
	POP D		; Get arguments into d
	POP B		; and b.
	PUSH B		; Restore stack.
	PUSH D
	PUSH H
	CALL bdose	; Call BDOS.
			; Return value from HL.
#endasm
}

