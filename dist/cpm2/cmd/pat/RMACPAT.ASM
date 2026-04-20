;****************************************************************
;
;		    Patches for MAC and RMAC
;		    ------------------------
;
;			 by George Blat
;	       Blat, Research + Development Corp.
;			  8016 188th SW
;			Edmonds, WA 98020
;
;
;****************************************************************
;
;
;The following changes are (c)1983 Blat R+D Corp. Permission is
;granted to use these patches only in non-commercial applications.
;MAC and RMAC are trademarks of Digital Research, Inc. which holds
;ownership and all rights to the original programs.
;
;****************************************************************
;
;
;Mac and Rmac are two reliable assemblers developed by Digital
;Research which have a good number of useful features. It seems
;natural to get the most out of them.
;
;Among the features that can be added to Mac and Rmac, are the
;ability to use the period '.' and the underscore '_' as part of
;symbol names such as labels, even as first character of the
;symbol. The underscore, for instance, makes a much better word
;separator than the dollar '$' sign when used in a multi-word
;label. In a dense program listing, it's certainly easier to find
;STAT_PORT than STAT$PORT, and @hl_to_de than @hl$to$de.
;
;By the same token, I don't agree with the decision of Digital
;Research of making the dollar sign a don't care character. It
;introduces confusion as it allows symbols that don't look the
;same to be equivalent.
;
;In addition, RMAC can be easily patched to create .REL files
;where the global (external) names have up to 7 active characters.
;This helps by allowing you to create more meaningful symbol names
;and therefore improve program legibility. This change is still
;entirely compatible with the industry standard Microsoft format.
;
;The following patches should be assembled with MAC (not RMAC)
;and the resulting hex file should be applied over the original
;programs with DDT, SID or ZSID. KEEP AN ARCHIVE COPY OF THE
;ORIGINAL MAC OR RMAC BEFORE PATCHING.


FALSE	EQU	0
TRUE	EQU	NOT FALSE

RMAC	EQU	TRUE		;select one and only one of these
MAC	EQU	FALSE		;true

	IF	RMAC
GLOBAL7		EQU	TRUE	;set to false if you don't want
				;7 char globals
PATCHAREA	EQU	13BH
DOLLARCOUNTS	EQU	1D7AH	;set this to false if you like to 
				;keep the dollar as a don't care char
CHECKALFA	EQU	1D9CH
TOUP		EQU	2844H
	ENDIF

	IF	MAC
COPYRITE	EQU	103H	;shorten but keep the copyright notice
DOLLARCOUNTS	EQU	1834H
CHECKALFA	EQU	1853H
	ENDIF

	IF	MAC

	ORG	COPYRITE
	DB	'(c)1977 DRI'
PATCHAREA:
	ENDIF

	IF	RMAC
	ORG	PATCHAREA
	ENDIF

	CPI	'.'
	RZ
	CPI	'_'
	RZ
	CPI	'?'
	RZ
	CPI	'@'
	RZ
	IF	RMAC
	CALL	TOUP
	ENDIF
	SUI	'A'
	CPI	'Z'-'A'+1
	CMC
	RET

	IF	RMAC AND GLOBAL7

COMPARE	EQU	12D6H
SETIT7	EQU	12DBH

	ORG	COMPARE
	CPI	8		;replaces cpi 7
	ORG	SETIT7
	MVI	A,7		;replaces mvi a,6

	ENDIF

	IF	DOLLARCOUNTS
	ORG	DOLLARCOUNTS
	NOP			;replaces mov m,a
	ENDIF

	ORG	CHECKALFA
	CALL	PATCHAREA	;replaces cpi 3f
	CMC			;jz	1db1
	SBB	A		;cpi	40
	RET			;jz	1db1,	etc.


	END
