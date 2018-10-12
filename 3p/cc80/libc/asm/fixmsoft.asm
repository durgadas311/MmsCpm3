; May 9, 1984  13:00  drm  "FIXMSOFT.ASM"

; generated from LISTREL1 output of CLIBRARY.REL

;module to fix 6-byte name restiction
	public putchar,getchar,@switch,.switch
	extrn putcha,getcha,.switc

putchar: jmp	putcha
getchar: jmp	getcha
.switch: ds	0
@switch: jmp	.switc

	end
