;
; Format and sector tables
; January 6, 1984 14:57 mjm
;
; Link command: LINK FORMAT=FMTMAIN,FMTZ89 or FMT500,FMTDISP,FMTTBL[NC,NR]
;  Note: This file (FMTTBL) must be last file linked
;
	
	public	table,buffer,std8,z47d,vskstd

;
;	table is the same format as the one in getdp	 
;
;	The config bit in the table (bit 7 byte 3) is used to determine
;	whether the label should be written, not the config in the
;	actual mode byte. Search$table sets CFLG to TRUE if this bit is set
;

table:	db 00000001b,11100101b,10000000b,00000000b   ; STANDARD 8" SD SS ST
	dw STD8      
	db 00000000b,00000001b,10000010b,00010000b   ; MMS 8" DD format
	dw MMS8 	     
	db 00000000b,00000001b,00000010b,00010000b   ; MMS 5" DD format 
	dw MMS5 	     
	db 00000000B,00000100b,10000011b,00010000b   ; MMS M47 8" (1024 sector)
	dw Z47X 	     
	db 00000000b,00001000b,00000001b,10000000b   ; Z37 5" SD (256 sector)
	dw Z37S 	    
	db 00000000b,00001000b,00000001b,10010000b   ; z37 5" dd (256 sector)
	dw Z37D 	     
	db 00000000b,00100000b,10000001b,10011000b   ; z47 8" dd (256 sector)
	dw Z47D 	
	db 00000000b,10000000b,10000001b,10011000b   ; z67 8" dd (256 sector)
	dw Z67D 
	db 00000000b,00010000b,00000011b,10010000b   ; z37x 5" dd (1024 sector)
	dw Z37X 	     
	db 00000000b,01000000b,10000011b,10011100b   ; z47x 8" dd (1024 sector)
	dw Z47X 	     
	db 00000001b,00000000b,00000010b,10010000b   ; z100 5" dd (512 sector)
	dw Z100A	    
	db 00000001b,00000000b,10000001b,10011000b   ; z100 8" dd (256 sector)
	dw Z100B	    
	db 11111111b	     ; end of table flag


;	     Format    DD    Format    Verify
;	      Table  Flag     Skew	Skew
;----------------------------------------------------------------
STD8:	DW	STD,	0,	  0, vskstd
MMS8:	DW	MMS,  255,  FMTSEC8,vskmms8
MMS5:	DW	MMS,  255,  FMTSEC5,vskmms5
M47X:	DW	Z4X,  255,	  0, vsk47x
Z37S:	DW	Z3S,	0,FMTSEC37S,vskz37s	; Tr0, Sd0, Sc1 Spcl data
Z37D:	DW	Z3D,  255,FMTSEC37D,vskz37d	; Tr0, Sd0, Sc1 Spcl data
Z37X:	DW	Z3X,  255,FMTSEC37X,vskz37x	; Tr0, Sd0, Sc1 Spcl data
Z47D:	DW	Z4X,  255,	  0, vskz47	; Track 0 side 0 is STD8
Z47X:	DW	Z4X,  255,	  0, vsk47x	; Track 0 side 0 is STD8
Z67D:	DW	Z6D,  255,	  0, vskz47
Z100A:	DW	Z1005,255,	  0,vskz100
Z100B:	DW	Z1008,255,	  0, vskz47


STD:	DB	40,0FFH
	DB	 6,  0
	DB	 1,0FCH
	DB	26,0FFH
	DB	 0		; flags start of sectors
	DB	 6,  0
	DB	 1,0FEH 	; flags to insert header info.
	DB	11,0FFH
	DB	 6,  0
	DB	 1,0FBH 	; flags to insert data (E5)
	DB	27,0FFH
	DB	 0		; flags end of sector & end of table
	DW     350		; fill size of trailer

MMS:	DB	60,04EH
	DB	12,  0
	DB	 3,0F6H
	DB	 1,0FCH
	DB	44,04EH
	DB	 0
	DB	12,  0
	DB	 3,0F5H
	DB	 1,0FEH
	DB	22,04EH
	DB	12,  0
	DB	 3,0F5H
	DB	 1,0FBH
	DB	45,04EH
	DB	 0
	DW     750

Z3S:	DB	16,0FFH
	DB	 0
	DB	 6,  0
	DB	 1,0FEH
	DB	11,0FFH
	DB	 6,  0
	DB	 1,0FBH
	DB	16,0FFH
	DB	 0
	DW     150

Z3D:	DB	32, 4EH
	DB	 0
	DB	12,  0
	DB	 3,0F5H
	DB	 1,0FEH
	DB	22, 4EH
	DB	12,  0
	DB	 3,0F5H
	DB	 1,0FBH
	DB	54, 4EH
	DB	 0
	DW     350

Z3X:	DB	32, 4EH
	DB	 0
	DB	12,  0
	DB	 3,0F5H
	DB	 1,0FEH
	DB	22, 4EH
	DB	12,  0
	DB	 3,0F5H
	DB	 1,0FBH
	DB	96, 4EH
	DB	 0
	DW     450

Z1005:	DB	80,04EH
	DB	12,  0
	DB	 3,0F6H
	DB	 1,0FCH
	DB	50,04EH
	DB	 0
	DB	12,  0
	DB	 3,0F5H
	DB	 1,0FEH
	DB	22,04EH
	DB	12,  0
	DB	 3,0F5H
	DB	 1,0FBH
	DB	80,04EH
	DB	 0
	DW     1059

Z4X:	DB     144, 4EH
	DB	 0
	DB	12,  0
	DB	 3,0F5H
	DB	 1,0FEH
	DB	22, 4EH
	DB	12,  0
	DB	 3,0F5H
	DB	 1,0FBH
	DB	54, 4EH
	DB	 0
	DW    1300

Z6D:				; actually, standard IBM
	DB	56,4EH
	DB	12,0
	DB	3,0F6H
	DB	1,0FCH
	DB	50,4EH
	DB	0
	DB	12,0
	DB	3,0F5H
	DB	1,0FEH
	DB	22,4EH
	DB	12,0
	DB	3,0F5H
	DB	1,0FBH
	DB	54,4EH
	DB	0
	DW	750

Z1008:				
	DB	80,4EH
	DB	12,0
	DB	3,0F6H
	DB	1,0FCH
	DB	50,4EH
	DB	0
	DB	12,0
	DB	3,0F5H
	DB	1,0FEH
	DB	22,4EH
	DB	12,0
	DB	3,0F5H
	DB	1,0FBH
	DB	54,4EH
	DB	0
	DW	910


;
;	Format skew tables for formats that have build in sector skewing
;

FMTSEC5:   DB  1, 8, 6, 4, 2, 9, 7, 5, 3			; MMS 5" format

FMTSEC8:   DB  1,14,11, 8, 5, 2,15,12, 9, 6, 3,16,13,10, 7, 4	; MMS 8" fmt

FMTSEC37S: DB  1, 8, 5, 2, 9, 6, 3,10, 7, 4			; Z37 SD format

FMTSEC37D: DB  1,12, 7, 2,13, 8, 3,14, 9, 4,15,10, 5,16,11, 6	; Z37 DD

FMTSEC37X: DB  1, 3, 5, 2, 4					; Z37 XD

;
;	Verify skew tables added to speed up verify
;

vskstd:
	db	1,4,7,10,13,16,19,22,25,2,5,8,11
	db	14,17,20,23,26,3,6,9,12,15,18,21,24

vskz47: db	1,3,5,7,9,11,13,15,17,19,21,23,25
	db	2,4,6,8,10,12,14,16,18,20,22,24,26

vskz100:
vsk47x: db	1,3,5,7,2,4,6,8

vskmms5:
	db	1,6,2,7,3,8,4,9,5
vskmms8:
	db	1,11,5,15,9,3,13,7,14,8,2,12,6,16,10,4
vskz37s:
	db	1,5,9,3,7,8,2,6,10,4
vskz37d:
	db	1,7,13,3,9,15,5,11,12,2,8,14,4,10,16,6
vskz37x:
	db	1,5,4,3,2

buffer: ds	0		; start of free memory
	
	end
