; globals/common variables
	public	L2e83,L2ea3,L2ea4,L2ea5,L2ea6,L2ea7,curhsh,L2eaa,symtab,L2eb4,L2ed4
	public	L2ef4,L2f14,L2f24,L2f44,L2f54,L2f64,L2f65,L2f66,L2f67,prnbuf,curerr
	public	L3004,L3005,L3006,L3008,L3009,L300a,L300b,L3049,L304b,memtop,pass
	public	curadr,linadr,syheap,cursym,L3058,L305a,L305b,L305c,L305d,Sflag,Mflag
	public	L3060,L3062,Qflag,Lflag,L3066,Rflag,stack,buffer

	;org	2e80h
	dseg
; L2e80:
	ds	3
L2e83:	ds	32
L2ea3:	ds	1
L2ea4:	ds	1
L2ea5:	ds	1
L2ea6:	ds	1
L2ea7:	ds	1
curhsh:	ds	2	; current hash pointer (symbol being looked up)
L2eaa:	ds	2
; hash table for symbols?
symtab:	ds	8
L2eb4:	ds	32
L2ed4:	ds	32
L2ef4:	ds	12	; ds 32...
; end of page/record...
	;org	2f00h
	ds	20
L2f14:	ds	16
L2f24:	ds	32
L2f44:	ds	16
L2f54:	ds	16
L2f64:	ds	1
L2f65:	ds	1
L2f66:	ds	1
L2f67:	ds	37

; staging buffer for PRN line
prnbuf:
curerr:	ds	1	; error code
	ds	119

L3004:	ds	1
L3005:	ds	1
L3006:	ds	2
L3008:	ds	1	; current token/opcode (len, chrs...)
L3009:	ds	1
L300a:	ds	1
L300b:	ds	62
L3049:	ds	2
L304b:	ds	2
memtop:	ds	2	; end of TPA
pass:	ds	1	; assembler pass number (0/1)
curadr:	ds	2	; prog addr where current byte is (to go)
linadr:	ds	2	; prog addr where current ASM line started

syheap:	ds	2	; point to free mem for symbols
cursym:	ds	2	; current symbol being examined
L3058:	ds	2
L305a:	ds	1
L305b:	ds	1
L305c:	ds	1
L305d:	ds	1
Sflag:	ds	1	; $[+-]S flag
Mflag:	ds	1	; $[+-*]M flag
L3060:	ds	2
L3062:	ds	2
Qflag:	ds	1	; $[+-]Q flag
Lflag:	ds	1	; $[+-]L flag
L3066:	ds	1
Rflag:	ds	1	; $[+-]R flag = "reloc" ORG 0 instead of 0100h

	ds	152
stack:	ds	0
buffer:	; the rest of memory...
	end
