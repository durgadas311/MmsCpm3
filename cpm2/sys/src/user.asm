; August 1, 1982  09:25  drm  "USER.ASM" version 2.241
************************************************************************
*
*	       USER-ADAPTABLE PERIPHERAL I/O CODE
*   with link to external Console-module via BAT: logical device.
*
*  Copyright (c) 1982 Magnolia Microsystems
************************************************************************
*
* INSTRUCTIONS AND SOURCE CODE FOR PATCHING THE USER AREA (NON-DISK I/O)
* OF BIOS FOR MMS-CP/M 2.24.
*
* GENERATE A FILE IMAGE OF THE SYSTEM FOR THE DESIRED MEMORY SIZE USING
* "MOVCPM" AND THE "SAVE xx CPMyy.COM" OPTION. FOR EXAMPLE,
*
*  A0>MOVCPM 64 *
*  A0>SAVE 41 CPM64.COM
*
* USE 'DDT' TO FIND THE STARTING ADDRESS OF USER AREA:
*
*  A0>DDT CPMyy.COM
*  DDT VERS 2.2
*  NEXT  PC
*  zzzz 0100
*  -L2000
*  2000 JMP  F2D9
*  2003 JMP  F364
*  2006 JMP  F500 ; here is the JMP to the start of the USER code.
*  2009 JMP  F503
*  200C ...  ...
*  -^C		  ; CONTROL-C RETURNS TO CP/M
*
* CHANGE "USER EQU 1900H" BELOW TO THE ADDRESS FOUND AT LOCATION 2006.
* MAKE ANY OTHER DESIRED CHANGES TO THE CODE AND RE-ASSEMBLE IT. THE
* NEW USER CODE MUST NOT EXCEED 512 BYTES. GET THE VALUE OF "BIAS" FROM THE
* NEW LISTING AND USE "DDT" TO MERGE THE NEW OBJECT FILE "USER.HEX" INTO
* "CPMyy.COM":
*
*  A0>DDT CPMyy.COM
*  DDT VERS 2.2
*  NEXT  PC
*  zzzz 0100
*  -IUSER.HEX
*  -RWWWW		; substitute "BIAS" value for WWWW
*  NEXT  PC
*  zzzz 0000
*  -^C
*  A0>SAVE xx CPMyy.COM
*
* NOW SYSGEN YOUR DISK WITH FILE CPMyy.COM ("SYSGEN CPMyy.COM").
* EACH DISK THAT YOU SYSGEN USING CPMyy.COM WILL CONTAIN THE PATCH.
*
***********************************************************************
*
USER	EQU	1900H		; SET TO ADDRESS FOUND USING DDT CPMyy.COM
*
************************************************************************
SYSGEN	EQU	0900H	;ADDRESS OF SYSTEM START IN MOVCPM.COM
BOOTL	EQU	0100H	;LENGTH OF BOOT ROUTINE
BIOS	EQU	USER-0300H
DBASE	EQU	BIOS+4CH	; Drive-base table address
************************************************************************

;------------------------------------------------------------------
BIAS	EQU	2000H-BIOS	; OFFSET FOR DDT
;------------------------------------------------------------------

CONSOLE EQU	0E8H	;Z89 CRT SYSTEM CONSOLE
CONSTAT EQU	0EDH	;STATUS
TTYDAT	EQU	0D0H	;Z89 AUXILIARY DCE DATA PORT
TTYSTAT EQU	0D5H	;STATUS
MODEM	EQU	0D8H	;Z89 DTE DATA PORT
MODSTAT EQU	0DDH	;STATUS
PRINTER EQU	0E0H	;Z89 DCE DATA PORT
PRTSTAT EQU	0E5H	;STATUS

SEND	EQU	00100000B	;MASK FOR TX BUFFR EMPTY
RECEIVE EQU	00000001B	;MASK FOR RX DATA READY
DSRCTS	EQU	00110000B	;MASK FOR DATA SET READY, CLEAR TO SEND

ESC	EQU	27	;ASCII ESCAPE KEY

DEV$STAT	EQU	3	;CP/M IOBYTE address

	ORG	USER
ORGADR: DS	0
************************************************************
** U S E R   A R E A :
**
************************************************************
*
*	SYSTEM JUMP TABLE
*
XCONS	CALL	CONINIT ;these CALL's cause initialization the
XCNIN	CALL	CONINIT ;first time the console is accessed. They
XCOUT	CALL	CONINIT ;are replaced during initialization.
XLIST	JMP	LIST	;Standard Entry to MMS USER area...
XPUN	JMP	PUNCH
XRDR	JMP	READER
XPRTS	JMP	PRTST
*
********************************************************************
**	START OF THE LOGICAL DEVICE ROUTINES
************************************************************************
*
CONINIT:		;Initialize the console device.
	POP	H	;Get address of vector following CALLed vector.
	DCX	H
	DCX	H
	DCX	H	;make it into the address of the CALLed vector
	PUSH	H	;so we can perform the requested function after
	PUSH	B	;initialization.
	LXI	H,CONVEC	;replace "CALL CONINIT" with appropriate
	LXI	D,XCONS 	;JMP's to console routines.
	LXI	B,9
	DW 0B0EDH ; LDIR ;Z80 block move instruction
	POP	B
	LXI	H,DBASE ;search for custom console module in system
	MVI	B,8	;DEVICE BASE table.
CSER:	MOV	A,M
	INX	H
	CPI	200	;console is device 200
	JNZ	NOTIT
	INR	A	;and module only supports one device.
	CMP	M	;so the device number cannot be >= 201
	JZ	YESIT
NOTIT:	INX	H	;search all 8 possible entries in table.
	INX	H
	INX	H
	DB 10H		; DJNZ CSER ;Z80 controlled loop instruction
	DB CSER-$-1 AND 0FFH
	RET	;if no module exists, leave BAT: as standard function.

YESIT:	INX	H	;Yes, we found the console module in the table.
	MOV	E,M	;get starting address of module.
	INX	H
	MOV	D,M
	XCHG
	LXI	D,3	;
	SHLD	INTST+1 ;replace BAT: STATUS vector with module's STATUS vec.
	DAD	D	;  next vector is +3 bytes...
	SHLD	INTIN+1 ;replace INPUT vector.
	DAD	D
	SHLD	INTOUT+1 ;replace OUTPUT vector.
	RET	;do requested function now...

CONVEC: JMP	CONST	;console vectors for replacement in entry table.
	JMP	CONIN
	JMP	CONOUT

CONST:			;console input status routine.
	LDA	DEV$STAT
	ANI	00000011B
	JZ	TTYST	;TTY: device handling.
	DCR	A
	JZ	CRTST	;CRT: device.
	DCR	A
	JZ	INTST	;BAT: or Interupt driven keyboard module.
	JMP	MODST	;UC1: device.

CONIN:			;console input routine.
	LDA	DEV$STAT
	ANI	00000011B
	JZ	TTYIN	;TTY: input.
	DCR	A
	JZ	CRTIN	;CRT: input.
	DCR	A
	JZ	INTIN	;BAT: or Interupt driven keyboard module.
	JMP	MODIN	;UC1: input.

CONOUT: 		;console output routine.
	LDA	DEV$STAT
	ANI	00000011B
	JZ	TTYOUT	;TTY: output.
	DCR	A
	JZ	CRTOUT	;CRT: output.
	DCR	A
	JZ	INTOUT	;BAT: or Interupt driven keyboard module.
	JMP	MODOUT	;UC1: output.

LIST:			;logical printer routine
	LDA	DEV$STAT
	RLC
	RLC
	ANI	00000011B
	JZ	TTYOUT	;TTY:
	DCR	A
	JZ	CRTOUT	;CRT:
	DCR	A
	JZ	LPTOUT	;LPT:
	JMP	MODOUT	;UL1:

PRTST:			;logical printer status routine
	LDA	DEV$STAT
	RLC
	RLC
	ANI	00000011B
	JZ	TTYSTO	;TTY:
	DCR	A
	JZ	CRTSTO	;CRT:
	DCR	A
	JZ	LPTSTO	;LPT:
	JMP	MODSTO	;UL1:

PUNCH:			;logical punch device
	LDA	DEV$STAT
	RRC
	RRC
	RRC
	RRC
	ANI	00000011B
	JZ	TTYOUT
	DCR	A
	JZ	MODOUT	;PTP:
	DCR	A
	JZ	CRTOUT	;UP1:
	JMP	LPTOUT	;UP2:

READER: 		;logical reader device
	LDA	DEV$STAT
	RRC
	RRC
	ANI	00000011B
	JZ	TTYIN	;TTY:
	DCR	A
	JZ	MODIN	;PTR:
	DCR	A
	JZ	CRTIN	;UR1:
	JMP	LPTIN	;UR2:

READST: 		;logical reader status routine (used by standard
	LDA	DEV$STAT	; BAT: process).
	RRC
	RRC
	ANI	00000011B
	JZ	TTYST	;TTY:
	DCR	A
	JZ	MODST	;PTR:
	DCR	A
	JZ	CRTST	;UR1:
	JMP	LPTST	;UR2:

***********************************************************
** END OF LOGICAL DEVICE ROUTINES
***********************************************************
** START OF PHYSICAL DEVICE ROUTINES
**	The following code is dependent on physical serial
**	ports and specific port-addresses.
***********************************************************

CRTST:		;Z89 CONSOLE INPUT STATUS
	IN	CONSTAT
	ANI	RECEIVE ;check Receiver Data Available bit.
	JZ	NOTRDY	;(A) is zero if no character ready.
	XRA	A	;if a character is ready, set (A) to 0FFH
	CMA		;as per CP/M status conventions.
NOTRDY	ORA	A	;set Zero status bit accordingly.
	RET

CRTIN:		;Z89 CONSOLE INPUT DATA
	CALL	CRTST	;check CRT: input status.
	JZ	CRTIN	;wait for a character to be received.
	IN	CONSOLE ;get the character.
	ANI	7FH	;discard parity bit.
PATCHE: RET	;this point is also called from the Interupt Driven
	CPI	ESC	;Keyboard module.  Check for an "ESC" code.
	RNZ
	LXI	B,361	;WAIT MAX OF 1 CHAR TIME @ MIN BAUD (1200)
ESCLP:	IN	CONSTAT ;wait for possible 2nd character (if the terminal
	ANI	RECEIVE ;is generating an ESC sequence, the next character
	JNZ	ESCRDY	;will follow directly...it will be here in approx 1
	DCX	B	;character time.
	MOV	A,B
	ORA	C
	JNZ	ESCLP	;loop untill a character time has elapsed.
	MVI	A,ESC	;GET READY TO RETURN "ESC" IF NO 2ND CHAR
	RET
ESCRDY: IN	CONSOLE ;get the next character of sequence.
	ORI	10000000B	;SIGNAL ESCAPE SEQUENCE by setting Hi bit.
	RET

CRTOUT: 	;Z89 CONSOLE OUTPUT DATA
	CALL	CRTSTO	;see if transmitter is ready to for another character.
	JZ	CRTOUT	;wait untill it is...
	MOV	A,C
	OUT	CONSOLE ;send character to transmitter.
	RET

CRTSTO: 	;Z89 CONSOLE OUTPUT STATUS
	IN	CONSTAT+1	;check hardware handshake lines to see if
	ANI	DSRCTS		;its OK to send a character.
	CPI	DSRCTS		;check DSR and CTS, both must be "1"
	MVI	A,0
	JNZ	NRDY		;if not, signal NOT READY
	IN	CONSTAT 	;else check transmitter shift register.
	ANI	SEND		;see if its empty.
	JZ	NRDY		;if not, signal NOT READY
	XRA	A
	CMA			;otherwise, set (A) = 0FFH for READY
NRDY:	ORA	A	;set flags.
	RET

LPTST:		;Z89 LP PORT INPUT STATUS
	IN	PRTSTAT 	;see if character received by LPT: port.
	ANI	RECEIVE
	JZ	NREDY		;signal NOT READY if no character.
	XRA	A
	CMA			;else signal READY
NREDY:	ORA	A	; and set flags.
	RET

LPTIN:		;Z89 LP PORT INPUT
	CALL	LPTST	;
	JZ	LPTIN	;wait for a character to be received.
	IN	PRINTER ;get the character.
	ANI	7FH	;discard parity bit.
	RET

LPTOUT: 	;Z89 LP PORT OUTPUT
	CALL	LPTSTO	;wait for LPT: to be ready to send a character.
	JZ	LPTOUT
	MOV	A,C
	OUT	PRINTER ;send character to LPT:
	RET

LPTSTO: 	;Z89 LP PORT OUTPUT STATUS
	IN	PRTSTAT+1	;check hardware handshake lines.
	ANI	DSRCTS	;CTS,DSR
	CPI	DSRCTS	;MUST HAVE BOTH
	MVI	A,0
	JNZ	NTRDY	;signal NOT READY if printer not ready.
	IN	PRTSTAT
	ANI	SEND	;also check transmitter shift register empty.
	JZ	NTRDY
	XRA	A
	CMA
NTRDY:	ORA	A	;set flags.
	RET

MODST:		;Z89 DTE PORT INPUT STATUS
	IN	MODSTAT 	;check modem port for character received.
	ANI	RECEIVE
	JZ	NORDY	;signal READY or NOT READY accordingly.
	XRA	A
	CMA
NORDY:	ORA	A
	RET

MODOUT: 	;Z89 DTE PORT OUTPUT DATA
	CALL	MODSTO
	JZ	MODOUT	;wait for modem port to be ready to transmit.
	MOV	A,C
	OUT	MODEM	;send character to modem.
	RET

MODIN:		;Z89 DTE PORT INPUT DATA
	CALL	MODST
	JZ	MODIN	;wait for modem port to receive a character.
	IN	MODEM	;get the character.
	RET		;NOTE: the parity bit is not stripped.

MODSTO: 	;Z89 DTE PORT OUTPUT STATUS
	IN	MODSTAT+1	;see if modem is ready to take a character.
	ANI	DSRCTS
	CPI	DSRCTS		;check for both DSR and CTS
	MVI	A,0
	JNZ	NTREDY
	IN	MODSTAT
	ANI	SEND
	JZ	NTREDY
	XRA	A
	CMA
NTREDY: ORA	A	;set flags
	RET

TTYST:		;Z89 AUXILIARY DCE PORT INPUT STATUS
	IN	TTYSTAT 	;GET THE STATUS
	ANI	RECEIVE 	;GET BIT OF INTEREST AND SET Z-FLAG
	RZ			;IF ZERO, THEN NO KEY STRUCK
	MVI	A,0FFH		;ELSE, FLAG KEY STRUCK
	RET			;AND RETURN STATUS


TTYSTO: ;Z89 AUXILIARY DCE PORT OUTPUT STATUS
	IN	TTYSTAT+1	;GET THE CLEAR TO SEND STATUS
	ANI	DSRCTS		;EXTRACT THE BITS OF INTEREST
	CPI	DSRCTS		;MATCH?
	MVI	A,00H		;PRE-CLEAR THE STATUS FLAG
	JNZ	SETIT		;IF NZ, THEN MISMATCH, RETURN NOT READY
	IN	TTYSTAT 	;ELSE, GET THE REST OF THE OUTPUT STATUS
	ANI	SEND		;GET THE BIT OF INTEREST
	RZ			;IF Z, THEN RETURN NOT READY
RDY:	MVI	A,0FFH		;ELSE, SET THE STATUS FLAG
SETIT:	ORA	A		;FORCE THE Z-FLAG
	RET
  
  
TTYIN:		;Z89 AUXILIARY DCE PORT INPUT	
	CALL	TTYST		;RETRIEVE KEY-INPUT STATUS
	JZ	TTYIN		;KEEP TRYING UNTIL KEY AVAILABLE
	IN	TTYDAT		;GET CHARACTER
	ANI	7FH		;STRIP PARITY BIT
	RET			;AND RETURN CHARACTER
  
  
TTYOUT: ;Z89 AUXILIARY DCE PORT OUTPUT
	CALL	TTYSTO		;RETRIEVE CHARACTER-OUTPUT STATUS
	JZ	TTYOUT		;KEEP TRYING UNTIL IT'S READY
	MOV	A,C		;WHAT WAS THE CHARACTER AGAIN?
	OUT	TTYDAT		;SEND TO DEVICE
	RET
  
; These JMP's are used to channel console I/O to the BAT: devices, or the
;external console-module if it is installed.
INTST:	JMP	READST	;standard BAT: handling if no console module is
INTIN:	JMP	READER	;installed.
INTOUT: JMP	LIST

**********************************************************************
**	END OF THE PHYSICAL DEVICE ROUTINES
**********************************************************************

; For use with MAC:
; Check if the USER area is longer than it should be.  If it isn't, fill
; it out to its full size (200H bytes).
; IF ($-ORGADR+4) GT 200H
; DS 'OVERRUN - LARGER THAN 200H'
; ELSE
; REPT (200H-($-ORGADR))-4
; DB 0
; ENDM
; ENDIF
 DS (200H-($-ORGADR))-4 ;FOR USE WITH STANDARD CP/M "ASM" 2.0

SCRATCH DB	0	;dummy patch location if PATCHE is removed.
	RET	;this RET must be here if PATCHE is removed and
		;the external console-module is used.
	DW	PATCHE	;must be here but can address "SCRATCH"
			;instead of "PATCHE"
*********************************************************
	END
