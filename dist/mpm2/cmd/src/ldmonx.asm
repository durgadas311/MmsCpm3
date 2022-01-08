$title	('MP/M II V2.0  Loader BDOS Interface')
	name	ldmonx

;/*
;  Copyright (C) 1979,1980,1981
;  Digital Research
;  P.O. Box 579
;  Pacific Grove, CA 93950
;
;  Revised:
;    14 Sept 81 by Thomas Rolander
;*/

	cseg
	public	ldmon1,ldmon2

ldmon1	equ	0d06h
ldmon2	equ	0d06h

offset	equ	0000h

fcb	equ	005ch+offset
fcb16	equ	006ch+offset
tbuff	equ	0080h+offset
	public	fcb,fcb16,tbuff

	END
