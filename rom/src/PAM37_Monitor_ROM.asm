;============================================================================
;  PAM/37 Front Panel Monitor for the Heath H8 Computer
;
;  Credits and basic information are hard to come by for the PAM/37 Monitor.
; As noted below, PAM/37 was issued in 1982; little or no information is
; still available today.  The only available User Manual seems to be
; truncated at 32 pages, and does not contain a listing, as is normal for all
; Heath ROM products.
;
;  The following credit information is is stored at the top end of
; the PAM/37 ROM, at address 0E8BH:
;
; ---------------------------------------------------------------------------
;
; Pam-80 - Front Panel Monitor for the Heath H8 and WH8 Digital Computers.
; Software Issue #01.03.00.
;
;    Copyright	February 1982
;		by Steve Parker
;		Firmware Engineer
;		Zenith Data Systems
;		St. Joseph, MI	49085
;
; Heath Part Number: 444-140
;
; Requires HA8-6 Z80 CPU and either a 444-70 or 444-124 ROM device.
; Use with 390-2333 keypad labels on front panel.
;----------------------------------------------------------------------------
;
; This PAM/37 source code was re-created by:
;
;	Terry Gulczynski	terryg@stack180.com
;	148 Reef Rd.
;	South Daytona, FL  32119
;	3 March 2011
;
;  The checksum for the original PAM37.BIN file (directly from the EPROM
; burner) is 073FF7.  This file matches it exactly.
;============================================================================

tab	equ	09h
lf	equ	0ah
cr	equ	0dh

;============================================================================
; H17 ROM Data Table / Routine Entry Point Addresses
;============================================================================
H17RomStart	equ	1800H		; H17 ROM Base Address
H17RomLen	equ	800h		; Length of H17 ROM Code
ZeroMem		equ	198AH		; Memory Clear Routine
ROMClk		equ	1C19H		; Clock Interrupt Handler
BootA		equ	1F5AH		; H17 Operating parameters
BootALen	equ	88		; Length of H17 data table


; Unknown values
I$1406	EQU	1406H	; ----I
J_1E3B	EQU	1E3BH	; J----

;============================================================================
; RAM Area Definitions, storage cells, and data bytes
;============================================================================
StartRam	equ	2000h		; RAM Start Address
IoWrk		equ	2002h		; I/O Work Area
XinB		equ	2004h		; Transient Routine Area

; The PrsRAM area is inited from ROM bytes at PrsROM
PrsRAM		equ	2004h		; Cells initialized from PrsROM
RegI		equ	2005h		; Index of Register under display
DsProt		equ	2006h		; Period Flag byte
DspMod		equ	2007h		; Display Mode
MFlag		equ	2008h		; User Flag Options
CtlFlg		equ	2009h		; Front Panel Control Bits
Refind		equ	200ah		; Refresh Index (0-7)
PrsLen		equ	Refind-PrsRAM+1	; Length of PrsRAM code block

FpLeds		equ	200bh		; Front Panel LED patterns
ALeds		equ	200bh		; Address LEDs - Addr 0-5
DLeds		equ	2011h		; Data LEDs - Data 0-2

I$200E	EQU	200EH	; ----I
D$2010	EQU	2010H	; --S--


ABUSS		equ	2014h		; Address Bus
RckA		equ	2016h		; RCK Save Area
CRCSUM		equ	2017h		; CRC-16 Checksum
TPERRX		equ	2019h		; Tape Error Exit Address
TicCnt		equ	201Bh		; Interrupt timer counter
RegPtr		equ	201Dh		; Register Contents pointer
UiVec		equ	201Fh		; User Interrupt Vectors



X_2028	EQU	2028H	; J-S--
D$2029	EQU	2029H	; --S--
J$202B	EQU	202BH	; J----
J$202E	EQU	202EH	; J----
J$2031	EQU	2031H	; J----
D$2034	EQU	2034H	; ---L-

CtlFlg2		equ	2036h		; Control Byte for OP2_CTL

D_2037	EQU	2037H	; --SL-


Radix		equ	2039h		; Octal or Hex Radix


J_203C	EQU	203CH	; J---I
D$203E	EQU	203EH	; --S--


D_CON		EQU	2048h			;


C$2061	EQU	2061H	; -C---
C$2067	EQU	2067H	; -C---
C$2076	EQU	2076H	; -C---
C$2085	EQU	2085H	; -C---
D$2086	EQU	2086H	; --S--
C$208B	EQU	208BH	; -C---


D_RAM		equ	20A0h			;


D_20A2	EQU	20A2H	; --SL-
D$20A3	EQU	20A3H	; --S--
D$20B4	EQU	20B4H	; --S--


AIO_UNI	EQU	2131H	; --SL-		; Active I/O unit #


I_2132	EQU	2132H	; ----I
D_2133	EQU	2133H	; --S--
D$2138	EQU	2138H	; --S--
D$213A	EQU	213AH	; --S--


BDA		equ	2150h		; Boot Device Address
BDF		equ	2151h		; Boot Device Flags
TimOut		equ	2152h		; Boot 15 second timeout counter
UsrClk		equ	2154h		; Boot clock interrupt routine


I$2156	EQU	2156H	; ----I
I_26CD	EQU	26CDH	; ----I
I$3221	EQU	3221H	; ----I
I$34CD	EQU	34CDH	; ----I

I$5B01	EQU	5B01H	; ----I
I$A74F	EQU	0A74FH	; ----I
I_C9A7	EQU	0C9A7H	; ----I
I$CD01	EQU	0CD01H	; ----I





Stack	equ	2280h			; Top of Stack
UsrFWA	equ	2280h			; User First Working Address

;============================================================================
; Keyset Monitor Port and Bit Definitions
;
; I/O Port Base Addresses -- Input Ports
;============================================================================
IP_PAD	equ	0f0h			; KeyPad Input Port
IP_TPC	equ	0f9h			; Tape Control In
IP_TPD	equ	0f8h			; Tape Data In
IP_CON	equ	0f2h			; Configure Port In

;============================================================================
; I/O Port Addresses -- Output Ports
;============================================================================
OP_CTL	equ	0f0h			; Control Output port
OP_DIG	equ	0f0h			; Digit Select Output Port
OP_SEG	equ	0f1h			; Segment Select output port
OP_TPC	equ	0f9h			; Tape Control Out
OP_TPD	equ	0f8h			; Tape Data Out
OP_CTL2	equ	0f2h			; Secondary Control port Out

;============================================================================
; Front Panel Hardware Control Bits
;============================================================================
CB_SSI	equ	00010000b		; Single Step interrupt
CB_MTL	equ	00100000b		; Monitor Light
CB_CLI	equ	01000000b		; Clock Interrupt Enable
CB_SPK	equ	10000000b		; Speaker Enable

;============================================================================
; Port 0F2H Secondary Control Port Bits (WRITE)
;============================================================================
CB2_SSI	equ	00000001b		; Single-Step enable
CB2_CLI	equ	00000010b		; Clock Interrupt Enable
CB2_ORG	equ	00100000b		; ORG-0 RAM Enable
CB2_SID	equ	01000000b		; Side 1 select

;============================================================================
; Display Mode Flags (in DspMod)
;============================================================================
DM_MR	equ	0			; Memory Read
DM_MW	equ	1			; Memory Write
DM_RR	equ	2			; Register Read
DM_RW	equ	3			; Register Write

;============================================================================
; User Option Bits (in cell MFlag)
;============================================================================
UO_HLT	equ	10000000b		; Disable HALT procesing
UO_NFR	equ	CB_CLI			; No refresh of Front Panel
UO_DDU	equ	00000010b		; Disable Display Update
UO_CLK	equ	00000001b		; Allow private interrupt processing

;============================================================================
; Configuration Flags
; Secondary Control Port (READ) Switch Content Bits
;============================================================================
CN_174M	equ	00000011b		; Port 174Q device type mask
CN_170M	equ	00001100b		; Port 170Q device type mask
CN_PRI	equ	00010000b		; Primary/Secondary Flag - 1=Primary=170Q
CN_MEM	equ	00100000b		; Auto Memory Test if = 1
CN_BAU	equ	01000000b		; Baud Rate 0=9600, 1=19,200
CN_ABO	equ	10000000b		; 0-No Autoboot, 1=AutoBoot

;============================================================================
; Keypad Key Definitions
;============================================================================
K_Plus		equ	10101111b	; '+' (AFH)
K_Minus		equ	10001111b	; '-' (8FH)
K_Star		equ	01101111b	; '*' (6FH)
K_Divide	equ	01001111b	; '/' (4FH)
K_Number	equ	00101111b	; '#' (2FH)
K_Dot		equ	00001111b	; '.' (0FH)

;============================================================================
; H17 Disk UART Ports and Control Flags
;============================================================================
UP_DP		equ	7ch		; Data Port (Read/Write)
UP_FC		equ	7dh		; Fill character (Write)
UP_ST		equ	7dh		; Status Flags (Read)
UP_SC		equ	7eh		; Sync Character (Write)
UP_SR		equ	7eh		; Sync Reset (Read)
DP_DC		equ	7fh		; Disk Control Port

; Status Flags
UF_RDA		equ	00000001b	; Receive Data Available
UF_ROR		equ	00000010b	; Receiver overrun
UF_RPE		equ	00000100b	; Receiver Parity Error
UF_FCT		equ	01000000b	; Fill Character Transmitted
UF_TBM		equ	10000000b	; Transmitter buffer empty

; Control Port Bits
DF_WG		equ	00000001b	; Write Gate Enable
DF_DS0		equ	00000010b	; Drive Select 0
DF_DS1		equ	00000100b	; Drive Select 1
DF_DS2		equ	00001000b	; Drive Select 3
DF_MO		equ	00010000b	; All Motors On
DF_DI		equ	00100000b	; Direction (0=Out to drive)
DF_ST		equ	01000000b	; Step Command (active high)
DF_WR		equ	10000000b	; Write Enable RAM



;============================================================================
;		P R O G R A M   S T A R T   P O I N T
;============================================================================
	ORG	0

Begin:	ld	de,0
	jp	XInit

	db	0ffh, 0ffh

; Restart 08H address
Int1:	call	SavAll
	ld	d,0
	jp	Clock

; Restart 10h Address
Int2:	call	SavAll
	ld	a,(de)
	jp	StpRtn

	db	0ffh

; Restart 18h Address
Int3:	jp	UiVec + 6		; J$2025
	db	"Pam37"

; Restart 20h Address
Int4:	jp	UiVec + 9		; X_2028
	db	"/SAP/"

; Restart 28h Address
Int5:	jp	UiVec + 12		; J$202B

Dly:	push	af
	xor	a			; Flag for no sound
	jp	Hrn0

; Restart 30h Address
Int6:	jp	UiVec + 15		; J$202E
Go_:	ld	a,0d0h			; Off monitor mode light
	jp	Sst1			; Return to user program

Int7:	jp	UiVec + 18		; J$2031

Init:	ld	a,(de)
	ld	(hl),a
	dec	hl
	inc	e
	jp	nz,Init
	ld	d,4
	ld	hl,StartRam
	jp	XInit1			; Find end of RAM

	db	"HEATH"

Init2:	DEC	HL			; Point to last RAM address
	LD	SP,HL			;  and set Stack pointer
	CALL	C$07BE
	PUSH	HL
	CALL	C$07C9
	PUSH	HL
	XOR	A
; fall through

;============================================================================
;       Subroutine      SavAll
;
; SavAll is called when an interrupt is accepted, in order to
; save the contents of the registers on the Stack.
;
;	Entry	Called directly from interrupt handler
;	Exit	All registers pushed on Stack.
;
;  If not yet in Monitor Mode, REGPTR = Address of registers on Stack.
;
;  (DE) = Address of CTLFLG.
;============================================================================
SavAll:	EXX
	EX	AF,AF'
	EX	(SP),HL			; Set HL on stack top. RET add to DE
	PUSH	DE
	PUSH	BC
	PUSH	AF
	LD	A,R
	LD	C,A
	jp	SavAllExt		; Skip around the NMI address

NmiAdd:	jp	NmiHandler		; @ 0800H

SavAllRet:				; Return from SavAll extension
	CPL
	AND	30H			; Save register addr if user or single-step
	RET	Z
	LD	HL,2
	ADD	HL,SP			; HL = address of 'StackPtr' on stack
	LD	(RegPtr),HL
	RET

;============================================================================
;	CUI - Check for User Interrupt processing
;
;  CUI is called to see if the user has specified processing for the
; clock interrupt.
;============================================================================
CUI:	LD	A,(BC)
	RRCA
	CALL	C,UiVec

; Return to program from Interrupt.
IntXit:	POP	AF			; Remove fake 'Stack Register'
	POP	AF			; Restore register contents
	POP	BC
	POP	DE
	JP	J$0823

;============================================================================
;	Clock - Process Clock Interrupt
;
;  Clock is entered whenever a 2-Millisecond clock interrupt is
; processed.
;
;  TicCnt is incremented every interrupt, forming a 2mSec counter.
;============================================================================
Clock:	LD	HL,(TicCnt)
	INC	HL
	LD	(TicCnt),HL		; Increment TicCnt

;	Refresh front panel
;
;	  This code displays the appropriate pattern on the
;	front panel LEDs.  The LEDs are painted in reverse order,
;	one per interrupt.  First, # 9 is lit, then # 8, etc.

	LD	HL,MFlag
	LD	A,(HL)
	LD	B,A			; B = current flag
	AND	40H			; Front panel refresh wanted?
	INC	HL
	LD	A,(HL)			; A = CtlFlg
	LD	C,D			; C=0 in case no panel display
	JP	NZ,Clk3			; Go if no front panel refresh

	INC	HL			; Point to Refresh Index
	DEC	(HL)			; -1 for digit index
	JP	NZ,Clk2			; Go if not wrapped around

	LD	(HL),9			; Esle, wrap around to start
Clk2:	LD	E,(HL)
	ADD	HL,DE			; HL -> address of pattern
	LD	C,E
Clk3:	OR	C
	OUT	(OP_DIG),A		; Select digit
	LD	A,(HL)
	OUT	(OP_SEG),A		; Select segment

; See if time to decode display values
	LD	L,low TicCnt
	LD	A,(HL)
	AND	31			; Every 32 interrupts
	CALL	Z,UFD			; Update front panel displays

; Exit clock interrupt
	LD	BC,CtlFlg
	LD	A,(BC)			; A = CtlFlg
	AND	20H
	JP	NZ,IntXit		; Go if in Monitor Mode

	DEC	BC
	LD	A,(BC)			; A = MFlag
	RLA				; Halt processing disabled?
	JP	C,Clk4			; Skip it if yes

; Not in Monitor Mode.  Check for Halt
	LD	A,24			; Locate PC Register
	CALL	LRA_

	LD	E,(HL)
	INC	HL
	LD	D,(HL)			; DE = PC contents
	DEC	DE			; Point to previous instruction
	LD	A,(DE)
	CP	76H			; Previous instruction a HALT?
	jp	z,ErrorEnt		; If HALT, enter monitor mode

Clk4:	IN	A,(IP_PAD)
	CP	2EH			; See if '0' and '#'
	JP	NZ,CUI			; If not, allow user clock processing
; fall through

;============================================================================
;	ErrorEnt - Command Error
;
;  ErrorEnt is called as a 'bail out' routine.  It resets the operational
; mode and restores the stack pointer.
;============================================================================
ErrorEnt:
	LD	HL,MFlag
	LD	A,(HL)			; A = _MFlag
	and	0ffh-UO_DDU-UO_NFR	; Re-enable displays
	LD	(HL),A
	INC	HL
	LD	(HL),0F0H		; Restore CtlFlg
	EI
	LD	HL,(RegPtr)
	LD	SP,HL			; Set Stack Pointer to empty state
	CALL	Alarm			; Alarm for 200mSec
; fall through

;============================================================================
;	MTR - Monitor Loop
;
; This is the main executive loop for the Front Panel Emulator
;============================================================================
MTR:	ei
Mtr1:	ld	hl,Mtr1
	push	hl			; Set Mtr1 as the return address
	ld	bc,DspMod
	ld	a,(bc)
	and	01h			; A = 1 if altered
 	cpl
	ld	(DsProt),a		; Set flag bit if DspMod altered

; Read Keypad
	CALL	RCK			; Read console keyset
	LD	HL,(ABUSS)
	CP	10
	JP	NC,Mtr4			; Go if in 'always valid' group
	LD	E,A			; Save value
	LD	A,(BC)			; Get DspMod value
	RRCA
	JP	C,Mtr5			; Go if in Alter mode
	LD	A,E			; Code to A

; Have a command - not a value
Mtr4:	SUB	4			; A = command table index
	JP	C,ExtCmd	        ; Extended commands
	LD	E,A
	PUSH	HL			; Save ABUSS value
	LD	HL,MtrA			; Point to command table
	LD	D,0			; Put command offset in DE
	ADD	HL,DE			; Add cmd offset to cmd tbl pointer
	LD	E,(HL)			; Get command tble entry
	ADD	HL,DE			; HL gets address of cmd tbl entry
	EX	(SP),HL			; Cmd adress on stack, ABUSS to HL
	LD	DE,RegI			; Point to register index
	LD	A,(BC)			; A = DspMod
	and	2			; Set 'Z' if memory mode
	LD	A,(BC)			; Reload DspMod to A
	ret				;  and 'exit' to command

; Command Jump table
MtrA:	db	Go-$			; 4 - Go
	db	In-$			; 5 - Input
	db	Out-$			; 6 - Output
	db	SStep-$			; 7 - Single Step
	db	RMem-$			; 8 - Cassette Load (read)
	db	WMem-$			; 9 - Cassette Dump (write)
	db	Next-$			; + - Next
	db	Last-$			; - - Last
	db	Abort-$			; * - Abort
	db	R$W-$			; / - Display/Alter
	db	MemM-$			; # - Memory Mode
	db	RegM-$			; . - Register Mode

;============================================================================
;	Mtr5	Process Memory/Register Alterations
;
;	This code is entered if:
;
;	- We are in Alter mode, and
;	- A key from 0-7 was entered.
;============================================================================
Mtr5:	RRCA
	LD	A,E			; A = value
	JP	C,Mtr6			; Go if it's a register
        SCF				; Flag 1st digit in A
	CALL	IOB			; Input octal byte
	INC	HL			; Display next location
; Fall through...

;============================================================================
;	SAE	Store ABUSS and Exit
;============================================================================
SAE:	ld	(ABUSS),hl
	ret

;============================================================================
;	H89Pin	H89-compatible PIN routine
;============================================================================
	  if  $ != 0137h
	.error "* Address Error at H89Pin (0137H) *"
	  endif

H89Pin:	jp	PIN


; Continue with MTR code from Mtr5 above
Mtr6:	PUSH	AF
	CALL	LRA
	AND	A
	JP	J$07D9

	db	0ffh, 0ffh

	  if  $ != 0144h
	.error "* Address Error at RegM (0144H) *"
	  endif
;============================================================================
;	RegM	Enter Register Display Mode
;
;	On entry, A = (DspMod)
;============================================================================
RegM:	ld	a,2			; Set 'Display Register' mode
	ld	(bc),a			; Store mode
	dec	bc			; Point to DsProt
	xor	a
	ld	(bc),a
	call	RCK			; Read key entry
	call	ExtRegTst
	jp	nc,ErrorEnt		; Go if not 1-13
	rlca				; Divide by 2
	ld	(de),a			; Set new register index
	ret

;============================================================================
;	R$W	Toggle Display/Alter mode
;
;	On entry:	A = DspMod
;			BC points to DspMod
;============================================================================
R$W:	XOR	01H			; Set 'other' mode
	LD	(BC),A			;  and save new DspMod
	RET

;============================================================================
;	Next	Increment Display Element
;
;	On entry:	HL points to ABUSS
;			DE has address of RegInd (Register Index)
;============================================================================
Next:	INC	HL
	JP	Z,SAE			; If memory mode, store ABUSS and exit
	LD	A,(DE)			; Get (RegI) value
	ADD	A,2			; Bump to next register
	LD	(DE),A			;  and save new index
	CP	26
	RET	C			; If not too large, exit
	XOR	A			; Else wrap around
	LD	(DE),A			;  and save new index
; Fall through...

;============================================================================
;	Abort	Exit current process
;============================================================================
Abort:	ret

;============================================================================
;	Last	Decrement Display Element
;
;	On entry:	HL points to ABUSS
;			DE points to RegInd (Register Index)
;============================================================================
Last:	DEC	HL
	JP	Z,SAE			; If memory mode, store and exit

; We're in register mode
	LD	A,(DE)			; Get current Register index
	SUB	2			; -2 for register #
	LD	(DE),A			; Save in index pointer
	RET	NC			; Exit if no wrap around
	LD	A,24			; Underflow, so set PC as
	LD	(DE),A			;  current register index
	RET

;============================================================================
;	MemM	Enter Display Memroy Mode
;
;	On Entry, BC has address of DspMod (Display Mode).
;============================================================================
MemM:	XOR	A
	LD	(BC),A			; Set DspMod to 'Display Memory'
	DEC	BC			; Point to DsProt
	LD	(BC),A			; Set all periods on
	LD	HL,ABUSS+1
	JP	IOA			; Input Octal address

;============================================================================
;	In	Input Data Byte
;	Out	Output Data Byte
;
;	On entry, HL points to ABUSS (Address Bus)
;============================================================================
In:	LD	B,0DBH			; 'IN' instruction

; The "DB 11H" below is the precessor to LD DE,NNNN.  As a result, DE will be
; loaded with the code generated by the LD B, 0D3H code, which is meaningless.
; The end result is that the LD B,0D3H code is ignored.
	 db	11h			; Skip next instruction

Out:	ld	b,0D3H			; 'OUT' instruction
	LD	A,H			; Put value in A
	LD	H,L			; Port in H
	LD	L,B			; IN/OUT instruction in L
	LD	(IoWrk),HL		; Store 'IN port' at IoWrk
	CALL	IoWrk			;  and execute the code
	LD	L,H			; Put port in L
	LD	H,A			; Value in H
	JP	SAE			; Store ABUSS and Exit

;============================================================================
;	Go	Return to User Mode
;============================================================================
Go:	JP	Go_			; Routine is in waste space

;============================================================================
;	SStep	Single Step Instruction
;============================================================================
SStep:	DI
	LD	A,(CtlFlg)		; Get control Flag
	XOR	10h			; Disable sngl step inhibit
	OUT	(0F0H),A		; Prime single step interrupt
Sst1:	LD	(CtlFlg),A		; Set new CtlFlg value
	POP	HL			; Clear rtn address from stack
	JP	IntXit			; Rtn to user routine for step

;============================================================================
;	StpRtn	Signle Step Return
;
;	On entry:	DE points to CtlFlg
;============================================================================
StpRtn:	OR	10H			; Disable single step interrupt
	OUT	(OP_CTL),A		; Turn off signle step enable
	LD	(DE),A			; Set new CtlFlg
	AND	20H			; See if in Monitor Mode
	jp	nz,MTR			;  and go to MTR loop if so
	JP	SStepRtnExt		; Enter Extended SS return processor

;============================================================================
;	RMem	Load Memory from Tape
;============================================================================
RMem:
	LD	HL,TPABT
	LD	(TPERRX),HL		; Setup error exit address

; Fall through...

;============================================================================
;	Load	Load memory from Tape
;
;	  Read the next record from cassette tape, using the load address
;	in the tape record.
;
;	Entry:	HL = Error Exit address
;	Exit	User P-Reg (on stack) set to entry address
;		To caller if OK
;		To Error Exit (HL) is tape errors detected
;============================================================================
Load:	LD	BC,0FE00H		; Required type and #
Load0:	CALL	SRS			; Scan for record start

	LD	L,A			; (HL) = count
	EX	DE,HL			; DE = count, HL = type and #
	DEC	C			; - next #
	ADD	HL,BC
	LD	A,H
	PUSH	BC			; Save type and #
	PUSH	AF			; Save type code
	AND	7FH			; Clear end flag bit
	OR	L
	LD	A,2			; Assume sequence error
	JP	NZ,TpErr		;  and go if wrong type or sequence
	CALL	RNP			; Read address
	LD	B,H
	LD	C,A			; BC = P-Reg address
	LD	A,24			; Offset to PC register
	PUSH	DE
	CALL	LRA_			; Locate Register address
	POP	DE
	LD	(HL),C			; Set P-Reg in mem
	INC	HL
	LD	(HL),B
	CALL	RNP			; Read address
	LD	L,A			; HL = Address, DE = count
 	LD	(StartRam),HL

Load1:	CALL	RNB			; Read next byte
	LD	(HL),A
	LD	(ABUSS),HL		; Set ABUSS for display
	INC	HL
	DEC	DE
	LD	A,D
	OR	E
	JP	NZ,Load1		; Go if more remaining

	CALL	CTC			; Check tape checksum
	POP	AF			; File type byte
	POP	BC			; Last type, Last #
	RLCA
	JP	C,TFT			; If done, turn off tape
	JP	Load0			;  else read next record

;============================================================================
;	Dump	Dump Memory to Mag Tape
;
; Dump specified memory to mag tape.
;
;	Entry	(Start) = Start address
;		(ABUSS) = End Address
;		User PC = Entry Point address
;============================================================================
	  if  $ != 01fch
	.error "* Address Error @ WMem *"
	  endif
WMem:	LD	HL,TPABT
	LD	(TPERRX),HL		; Set up error exit

	LD	A,1
	OUT	(OP_TPC),A		; Set up tape control
	LD	A,16H			; Sync character
	LD	H,32			; # of sync characters

WMem1:	CALL	WNB			; Write next byte
	DEC	H
	JP	NZ,WMem1		; Loop for 32 sync chars
	LD	A,2			; STX char
	CALL	WNB			; Write STX
	LD	L,H			; HL = 0
	LD	(CRCSUM),HL		; Init checksum counter
	LD	HL,8101h		; Write header
	CALL	WNP
	LD	HL,(StartRam)
	EX	DE,HL			; DE gets Start address
	LD	HL,(ABUSS)		; HL has end address

; Calculate byte count
	INC	HL
	LD	A,L
	SUB	E
	LD	L,A
	LD	A,H
	SBC	A,D
	LD	H,A			; HL has byte count
	CALL	WNP			; Write byte count

	PUSH	HL
	LD	A,24
	PUSH	DE
	CALL	LRA_			; Locate PC Reg address
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A			; HL = contents of PC
	CALL	WNP			; Write header
	POP	HL			; HL = Address
	POP	DE			; DE = Count
	CALL	WNP

WMem2:	LD	A,(HL)
	CALL	WNB			; Write byte
	LD	(ABUSS),HL		; Set address for display
	INC	HL
	DEC	DE
	LD	A,D
	OR	E
	JP	NZ,WMem2		; Loop if more to go

; Write Checksum
	LD	HL,(CRCSUM)
	CALL	WNP			; Write it
	CALL	WNP			; Flush it
; fall through

;============================================================================
;	Subroutine	TFT - Turn Off Tape
;
;  Stop the tape transport.
;============================================================================
TFT:	xor	a
	out	(OP_TPC),a		; Turn off tape
; Fall through...

;============================================================================
;	Subroutine	Alarm
;
;	Entry:	A = Millisecond count / 2
;============================================================================
Alarm:	ld	a,200/2			; 100mSec beep
; Fall through

	  if  ($ != 0260h)
	error	"* Address Error @ 0260H *"
	  endif

;============================================================================
;	Subroutine	Horn
;
; Sound horm for mSec length in A.
;============================================================================
Horn:	push	af			; Save count
	ld	a,80h			; Turn on speaker
Hrn0:	ex	(sp),hl			; Save HL, H = count
	push	de
	ex	de,hl			; D = loop count
	ld	hl,CtlFlg
	xor	(hl)
	ld	e,(hl)			; E = old CtlFlg value
	ld	(hl),a			; Turn on horn
	ld	L,1BH
	ld	a,d			; A = cycle count
	add	a,(hl)
Hrn2:	cp	(hl)			; Wait required TicCnt times
	jp	nz,Hrn2			;  loop if not done
	ld	L,9
	ld	(hl),e			; Turn horn off
	pop	de
	pop	hl
	ret

;============================================================================
;         Subroutine	CTC - Verify Checksum
;
;	Entry	Tape positioned just before CRC
;	Exit	To caller if OK
;		To TpErr if bad
;============================================================================
CTC:	CALL	RNP			; Read next Pair
	LD	HL,(CRCSUM)
	LD	A,H
	OR	L
	RET	Z			; Exit if OK
	LD	A,01h			; Tape Checksum Error
; fall through

;============================================================================
;	Subroutine	TpErr - Process Tape Error
;
;  Display error number in low byte of ABUSS
;
; If error # even, don't allow #
; If error # odd, allow #
;============================================================================
TpErr:	LD	(ABUSS),A		; Save the error code
	LD	B,A
	CALL	TFT			; Turn off tape

	db	0e6h			; MI.ANI - Fall through w/carry clr
Ter3:	LD	A,B
	RRCA
	RET	C			; Return if OK

; Beep and flash error #

Ter1:	CALL	C,Alarm			; Alarm if proper time
	CALL	TpXit			; See if * entered
	IN	A,(IP_PAD)
	CP	K_Number		; Check for '#'
	JP	Z,Ter3
	LD	A,(TicCnt+1)		; Get TicCnt high byte
	RRA     			; C set if 1/2 second
	JP	Ter1

;============================================================================
;	Subroutine	TPABT - Abort Tape Load or Dump
;
; Entered when Loading or Dumping, and the '*' key is struck.
;============================================================================
TPABT:	xor	a
	out	(0F9H),a
	jp	ErrorEnt

	  if  ($ !=02aah)
	error	"* Address Error @ 02AAH *"
	  endif

;============================================================================
;	Subroutine	TpXit - Check for User Forced Exit
;
; TpXit checks for a '*' keypad entry.  If so, take the tape driver
; abnormal exit.
;
;	Exit:	Via RET if not '*'
;		  A = port status
;		To (TpErrx) if '*' pressed
;============================================================================
TpXit:	IN	A,(IP_PAD)		; Read keypad
	CP	K_Star			; '*' character?
	IN	A,(0F9H)		; Read tape status
	RET	NZ			; Not '*', so return with status
	LD	HL,(TPERRX)		; Get address of error handler
	JP	(HL)			;  and do it

;============================================================================
;	Subroutine	SRS - Scan Record Start
;
; SRS scans bytes until it recognizes the start of a record.
; This requires at least 10 sync characters and 1 STX character.
; The CRC-16 is then initialized.
;============================================================================
SRS:	LD	D,00H
	LD	H,D
	LD	L,D
Srs2:	CALL	RNB			; Read next byte
	INC	D
	CP	16H			; Sync byte?
	JP	Z,Srs2
	CP	02H			; STX byte?
	JP	NZ,SRS			;  No - start over
	LD	A,10
	CP	D			; Enough SYNC characters received?
	JP	NC,SRS			;  go if no
	LD	(CRCSUM),HL		; Y - Clear CRC-16
	CALL	RNP			; Read Next Pair - leader

	LD	D,H
	LD	E,A
; Fall through...

;============================================================================
;	Subroutine	RNP - Read Next Pair
;
; Read next two bytes from input device
;============================================================================

RNP:	call	RNB
	ld	h,a
; Fall through...

;============================================================================
;	Subroutine	RNB - Read Next Byte
;
;  RND reads the next single byte from the input device.  The CRC checksum
; is updated.
;============================================================================
RNB:	LD	A,34H			; Turn on reader for next byte
	OUT	(0F9H),A
Rnb1:	call	TpXit			; Check for '*', read status
	and	2
	jp	z,Rnb1			; Loop if not ready

	IN	A,(0F8H)		; Else read data
; Fall through...

;============================================================================
;	Subroutine	CRC - Computer CRC-16
;
; CRC computes a CRC-16 checksum from the polynomial:
;
;  (X + 1) * (X^15 + X + 1)
;
;  Since the checksum generated is a division remainder,
; a checksummed data sequence can be verified by running
; the data through CRC, and running the previously obtained
; checksum through CRC.  The resulting checksum should be 0.
;============================================================================
CRC:	PUSH	BC
	LD	B,8			; B = bit count
	PUSH	HL
	LD	HL,(CRCSUM)		; Get current checksum value
Crc1:	RLCA
	LD	C,A			; C = bit
	LD	A,L
	ADD	A,A
	LD	L,A
	LD	A,H
	RLA
	LD	H,A
	RLA
	XOR	C
	RRCA
	JP	NC,Crc2			; If not to XOR
	LD	A,H
	XOR	80H
	LD	H,A
	LD	A,L
	XOR	05H
	LD	L,A

Crc2:	LD	A,C
	DEC	B
	JP	NZ,Crc1			; Go if more to do

	LD	(CRCSUM),HL		; Store updated checksum/CRC
	POP	HL			; Restore
	POP	BC
	RET

	  if  ($ != 030fh)
	error	"* Address Error @ 030FH *"
	  endif

;============================================================================
;	Subroutine	WNP - Write Next Pair
;
; Writes two bytes to the tape drive.
;============================================================================
WNP:	LD	A,H
	CALL	WNB			; Write 1st byte
	LD	A,L			; 2nd byte in A
; Fall through...

;============================================================================
;	Subroutine	WNB - Write Next Byte
;
; Writes next byte to cassette tape.
;============================================================================
WNB:	PUSH	AF			; Save byte to send
Wnb1:	CALL	TpXit			; Check for '*', read status
	AND	01H			; #1, not L
	JP	Z,Wnb1			; Loop if more
	LD	A,11H			; Enable transmitter
	OUT	(0F9H),A		; Turn on tape drive
	POP	AF			; Restore byte
	OUT	(0F8H),A		; Output it
	JP	CRC			; Exit via CRC calc

;============================================================================
;	Subroutine	LRA - Locate Register Address
;============================================================================
LRA:	LD	A,(RegI)		; Load register index
LRA_:	LD	E,A
	LD	D,0
	LD	HL,(RegPtr)		; Get address
	ADD	HL,DE			; Add index offset
	RET				; Exit w/HL = address

;============================================================================
;	Subroutine	IOA - Input Octal Address
;
;	HL has address of double byte entry
;============================================================================
IOA:	JP	IoaExt

	db	0ffh			; Space waster for address

;============================================================================
;	Subroutine	IOB - Input Octal Byte
;
; Read one Octal Byte from the keypad
;
;	Entry:	HL = address to put octal byte
;;===========================================================================
IOB:	JP	IobExt

; The rest ot the IOB code area below is unused.  It it maintained here to
; ensure the compiler generates a code file that is identical to the original
; PAM/37 code.

	  if	($ != 0339h)
	error	"* Address error @ 0339H *"
	  endif

	RST	38H
	RST	38H
	CP	08H
	JP	NC,ErrorEnt
	LD	E,A
	LD	A,(HL)
	RLCA
	RLCA
	RLCA
	AND	0F8H
	OR	E
	LD	(HL),A
	DEC	D
	JP	NZ,0338h
	LD	A,0Fh
	JP	Horn

; End of unused code block

;============================================================================
;	Subroutine	DOD - Decode Octal Display
;
;	Entry:	HL = Address of LED refresh area
;		B = OR pattern to force on bars or periods
;		A = Octal value
;		HL = HEX digit address
;============================================================================
DOD:	JP	DodExt

DodRet:	LD	C,3
DodR5:	RLA
	RLA
	RLA
	PUSH	AF			; Save for next digit
	AND	07H			; Mask

	add	a,low DodOct		; Add offset into table
	LD	E,A
	LD	A,(DE)
	XOR	B
	AND	7FH
	XOR	B
	LD	(HL),A
	INC	HL
	LD	A,B
	RLCA
	LD	B,A
	POP	AF
	DEC	C
	JP	NZ,DodR5
	POP	DE
	RET

;============================================================================
;	Subroutine	UFD - Update Front Panel Displays
;
; UFD is called by the clock interrupt processor when it is
; time to update the display contents.  Currently, this is done
; every 32 interrupts, or about 32 times a second.
;============================================================================
UFD:	LD	A,2
	AND	B
	RET	NZ			; Exit if not handling update

	LD	L,low DsProt
	LD	A,(HL)
	RLCA
	LD	(HL),A			; Rotate pattern
	LD	B,A
	INC	HL
	LD	A,(HL)			; A= Display Mode (DspMod)
	AND	2
	LD	HL,(ABUSS)
	JP	Z,Ufd1			; Go if displaying memory

; Displaying registers
	CALL	LRA			; Locate register address offset in DE
	PUSH	HL			; Save pointer to (ABUSS)
	ld	hl,LedRegTbl		; Pointer to Register table
	ADD	HL,DE			; Offset HL to register name pattern
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	EX	(SP),HL
	OR	H
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A			; HL = address of reg pair contents

Ufd1:	PUSH	AF
	EX	DE,HL			; Register table to DE
	LD	HL,ALeds
	LD	A,D
	CALL	DOD			; Format ABANK high half
	LD	A,E
	CALL	DOD			; Format ABANK low half
	POP	AF
	LD	A,(DE)
	JP	Z,DOD			; Go if displaying memory

; Is register display, set register name
	pop	bc			; Point BC to (ABUSS)
	ld	de,DLeds		; Data LEDs
	JP	Mov3Bytes		; Move 3 from (BC) to (DE)

;============================================================================
;	Subroutine	RCK - Read Console Keyset
;
;  Called to read a keystroke from the console.  It performs
; de-bounce and auto-repeat.  A 'bip' is sounded when a value
; is accepted.
;
;	KeyPad	  Code	     Returned
;	 Key	  Value	       in A
;	  0	1111 1110	0
;	  1	1111 1100	1
;	  2	1111 1010	2
;	  3	1111 1000	3
;	  4	1111 0110	4
;	  5	1111 0100	5
;	  6	1111 0010	6
;	  7	1111 0000	7
;
;	  8	1110 1111	8
;	  9	1100 1111	9
;	  +	1010 1111	10
;	  -	1000 1111	11
;	  *	0110 1111	12
;	  /	0100 1111	13
;	  #	0010 1111	14
;	  .	0000 1111	15
;
;	Inputs		None
;	Outputs		A has keypad code 0-15 for key in above table
;============================================================================
	  if  $ != 03b0h
	.error "* Address Error at RCK (03B0H) *"
	  endif

RCK:	PUSH	HL
	PUSH	BC
	LD	C,400/20		; Wait 400 mSec
	LD	HL,RckA			; Storage in RAM
Rck1:	IN	A,(0F0H)		; Input keypad value
	LD	B,A
	LD	A,20/2			; Wait 20 mSec
	CALL	Dly
	LD	A,B
	CP	(HL)
	JP	NZ,Rck2			; Go if different key from last
	DEC	C
	JP	NZ,Rck1			; Wait N cycles

Rck2:	LD	(HL),A			; Update last key received byte
	XOR	0FEH			; Invert all but group 0 flag
	RRCA
	JP	NC,Rck3			; Hit Bank 0
	RRCA
	RRCA
	RRCA
	RRCA
	JP	NC,Rck1			; No hit at all

Rck3:	LD	B,A			; B gets key code
	LD	A,4/2			; Bip sound timer
	CALL	Horn			; Make bip
	LD	A,B			; Restore key code
	AND	0FH			; Mask
	POP	BC
	POP	HL
	RET

; This is the original DSPA data table for displaying the register names.  It
; is replaced in high ROM so the additional Z80 registers can be added.

	dw	1001100010100100b	; SP
	dw	1001110010010000b	; AF
	dw	1000110110000110b	; BC
	dw	1000110011000010b	; DE
	dw	1000111110010010b	; HL
	dw	1100111010011000b	; PC

DodOct:			; Octal to 7-Segment pattern
	db	00000001b		; 0
	db	01110011b		; 1
	db	01001000b		; 2
	db	01100000b		; 3
	db	00110010b		; 4
	db	00100100b		; 5
	db	00000100b		; 6
	db	01110001b		; 7
	db	00000000b		; 8
	db	00100000b		; 9

	db	0ffh			; Space waster to put PRSROM at right location

	  if  ($ !=03f9h)
	error "* Address Error @ 03F9H (PRSROM) *"
	  endif

; I/O Routines copied to and used in RAM.
;
; Must Continue to 3777A for proper copy.  The table must also
; be backwards to the final RAM.
PRSROM:
	db	1			; Refresh Index
	db	0			; CtlFlg
	db	0			; .MFlag
	db	0			; DSPMOD Display Register
	db	0			; DsProt
	db	0			; RegI - Show SP Register
	db	0c9h			; Return instruction

;============================================================================
;	XInit1 - Size Memory
;
;  XInit1 is jumped to during PAM-8's memory sizing.
; This routine differes from the standard PAM-8 function
; in that it is non-destructive to what may be in RAM below
; 040000A, and it will not wrap-around in a 64K RAM system.
;
;	Entry:	Jumped to from old Init1
;		(DE) = Search increment
;		(HL) = First RAM search location
;
;	Exit:	(HL) = First location where no RAM found
;			(or zero if RAM through 64K present.)
;		(E) = 0 as required
;============================================================================
XInit1:	ld	a,(hl)			; Get RAM contents at current address
	dec	(hl)			; Change it
	cp	(hl)			; Compare to old value
	ld	(hl),a			; Restore original value
	jp	z,Init2			; Go if contents did not change - no RAM here

	add	hl,de			; Add the search increment
	jp	nc,XInit1		;  and loop back for next block, if no wrap-around
	jp	Init2			; Search complete

;============================================================================
;	XInit	- Extended Initialization
;
; Decide if there is RAM at 0.  If there is, then copy
; RAM Front Panel and H17 ROM to appropriate locations.
; Then jump back to inline init.
;
;  Modified to only do one move directly to RAM.
;
;	Entry:	(DE) = RAM8GO
;
;	Exit:	(DE) = PRSROM
;		(HL) = PrsRAM + PRSL - 1
;		RAM at 0000 set up if present
;============================================================================
XInit:	xor	a
	ld	(CtlFlg2),a		; Initialize the flag

; Copy RAM test routine to RAM
	ld	c,XinAL			; Length byte
	ld	de,XinA			; Source address
	ld	hl,XinB			; Destination
XIn1:	ld	a,(de)			; MOve a byte
	ld	(hl),a
	inc	de
	inc	hl
	dec	c			; -1 for count
	jp	nz,XIn1			;  and loop if more to go

; Test for RAM at location 0
	ld	hl,0
	ld	a,(CtlFlg2)		; Get original contents
	ld	b,a			; Save

; The OR  F2H below is NOT the code needed to enable ORG-0 RAM, although it WILL work.
; Instead, OR  CB2.ORG or OR  00100000B would be used.  0F2H is the PORT used to enable
; or disable ORG-0 RAM.

	OR	0F2H			; Turn on RAM at 0000
	LD	DE,XIn2			; DE = return address
	JP	XinB			; Execute test routine

XIn2:	JP	Z,XInit5		; Go if no change (no RAM at 0000)

	ld	bc,EndOfCode		; # of bytes to move
	ld	de,0			; Start address of move

; This part makes no sense, moving data from (DE) to (DE).  As far as the XinA routine
; is concerned, the memory map is set to ROM + RAM.  In other words, ORG-0 is NOT in
; effect, so there is no way to copy from ROM to RAM, unless there's one of those odd
; 'Read ROM, Write RAM' sort of mapping schemes in effect.

XIn3:	LD	A,(DE)
	LD	(DE),A
	INC	DE
	DEC	BC
	LD	A,B
	OR	C
	JP	NZ,XIn3			; Loop until all bytes copied

	LD	BC,H17RomLen
	LD	DE,H17RomStart

; Same as before - copying from (DE) to (DE).  This part makes no sense, moving data
; from (DE) to (DE).  As far as the XinA routine is concerned, the memory map is set
; to ROM + RAM.  In other words, ORG-0 is NOT in effect, so there is no way to copy
; from ROM to RAM, unless there's one of those odd 'Read ROM, Write RAM' sort of
; mapping schemes in effect.

XIn4:	LD	A,(DE)
	LD	(DE),A
	INC	DE
	DEC	BC
	LD	A,B
	OR	C
	JP	NZ,XIn4

; Now, put the RAM-only memory map in effect
	LD	A,(CtlFlg2)		; Get current Control Port 2 Flags
	OR	CB2_ORG			; ORG-0 RAM enable
	LD	(CtlFlg2),A		; Save current bits
	OUT	(OP_CTL2),A		; Set ORG0 in place

XInit5:	LD	DE,PRSROM		; Restore normal values
	ld	hl,PrsRAM + PrsLen - 1
	JP	Init			; Return to in-line code

; This routine is block moved to RAM @ 4002H for execution
XinA:	OUT	(OP_CTL2),A		; Swap in Page0 RAM
	LD	A,(HL)			; Get value and save it
	DEC	(HL)			; Attept to change
	CP	(HL)			; Set NZ if RAM changed
	LD	A,B			; Get original value for 0F2H port
	OUT	(OP_CTL2),A		; Select ROM map
	EX	DE,HL
	JP	(HL)
XinAL	equ	$-XinA

;============================================================================
;	ExtCmd - Extended Command Processor
;
; Handler for commands 0-3
;============================================================================
ExtCmd:	ADD	A,4			; Convert keypad to numeric
	ADD	A,A			; A = 2 * A
	LD	DE,ExtTbl		; Point to command table
	LD	L,A			; HL gets offset to command entry
	LD	H,0
	ADD	HL,DE			;  added to table base address
	LD	A,(HL)			; Get command address LSB
	INC	HL
	LD	H,(HL)			; Put command MSB address in H
	LD	L,A			;  and LSB address in L
	JP	(HL)			; Execute command

ExtTbl:	dw	UnivBoot		; '0' - Universal boot???
	dw	PriBoot			; '1' - Primary Boot
	dw	SecBoot			; '2' - Secondary Boot
	dw	AutoBoot		; '3' - Auto Boot????

;============================================================================
;	AutoB - Auto Boot
;
; Performs an auto boot of the primary device.
;============================================================================
AutoB:	LD	HL,MFlag
	LD	A,(HL)
	and	0ffh-UO_DDU-UO_NFR	; Enable display update, and refresh
	LD	(HL),A
	INC	HL
	LD	(HL),0F0H
	LD	A,0FFH
	LD	(DsProt),A		; All periods OFF
	EI
	LD	HL,(RegPtr)
	LD	SP,HL
	jp	PriBoot			; Boot primary device

;============================================================================
;	SecBoot - Secondary Boot
;	PriBoot - Primary Boot
;
;  PriBoot is called to boot from the primary boot device as defined in the
; configuration port IP.COM.  The alternate entry, SecBoot, is called to boot
; from the secondary boot device.  If the CN.PRI switch is one, the address
; 170 is the primary device; otherwise, address 174 is the boot device.  From
; there, the configuration switch further determines the device type with the
; appropriate masks.
;============================================================================
SecBoot:
	xor	a
SecBt1:	ld	(AIO_UNI),a		; Zero boot unit
	ld	bc,MsgSec
	in	a,(IP_CON)
	cpl				; Invert Primary flag
	jr	Boot			; Boot Secondary device

PriBoot:
	xor	a
PriBt1:	ld	(AIO_UNI),a		; Zero boot unit
	ld	bc,MsgPri
	in	a,(IP_CON)
; fall through

Boot:	ld	sp,Stack		; Init the stack pointer
	and	CN_PRI			; Booting primary?
	IN	A,(IP_CON)		; Read config switches
	PUSH	AF			;  and save
	JR	Z,Boot2			; 174 is the device to boot (secondary)

; Booting 170q device
	LD	A,78H			; Set Boot Dev Address to 170q
	LD	(BDA),A
	POP	AF			; Restore config switch data
	AND	CN_170M			; Mask with 0000 1100
	jr	z,SetH37
	CP	CN_170M			; Is it 0000 1100?
	JP	Z,ErrDevice		; Go if device 3
	RRCA				; Shift bits to 0000 00xx
	RRCA
	jr	Boot3			;  and handle devices 0, 1, or 2

; Soecial case.  Port 170 device 0 (H37) is treated as Device 3 in the lookup table
SetH37:	ld	a,3
	jr	Boot3			; Handle device 3

; Booting 174q device
Boot2:	LD	A,7CH			; Set Boot Dev Address to 174q
	LD	(BDA),A
	POP	AF			; Restore config switch data
	AND	CN_174M			; Mask with 0000 0011
	CP	CN_174M			; Is it 0000 0011?
	JP	Z,ErrDevice		;  Go if device 3

Boot3:	ld	(BDF),a			; Save Boot Dev Flag
	push	bc			; Save message display pointer
	ld	a,CB_SSI + CB_CLI + CB_SPK	; Turn off monitor mode
	ld	(CtlFlg),A

; Set all interrupt handlers to EI, RET
	LD	A,7
	LD	HL,UiVec
SetInt:	LD	(HL),0C3H		; Stuff interrupt vectors
	INC	HL
	LD	(HL),low EiRet		;  with JP EiRet instruction
	INC	HL
	LD	(HL),high EiRet
	INC	HL
	DEC	A
	JR	NZ,SetInt

	xor	a
	ld	(TimOut),a		; Zero timeout counter
	ld	hl,ROMClk		; H17 ROM clock routine
	ld	(UsrClk),hl
	ld	hl,ClkInt
	ld	(UiVec+1),hl		; Init Clock Interrupt vector
	ld	bc,BootA		; Point to H17 variables
	ld	de,D_CON
	call	BlkMovStk		; Block move H17 tables into RAM
	 db	BootALen

	LD	HL,D_RAM
	LD	B,31
	CALL	ZeroMem

	LD	A,(MFlag)
	or	UO_DDU + UO_CLK		; Enable clock interrupt, turn off display update
	LD	(MFlag),A
	POP	BC			; Restore message pointer
	LD	DE,ALeds		;  and move to address LEDs
	call	BlkMovStk
	 db	MsgLen

	ld	L,9-MsgLen
	ld	a,0ffh
Boot5:	ld	(de),a			; Blank LED RAM after "PRI" or "SEC"
	inc	de
	dec	L
	jr	nz,Boot5		; Loop 'til done

	ld	de,Boot6		; Return address
	push	de
	ld	a,(BDF)			; Get Boot Device Flags
	add	a,a			; Device flags x 2
	ld	L,a			;  into HL
	ld	h,0
	ld	de,BootTbl		; Point to start of boot table
	add	hl,de			; Add offset in HL
	ld	a,(hl)			; Get address from table, into HL
	inc	hl
	ld	h,(hl)
	ld	L,a
	jp	(hl)			;  and execute boot routine

Boot6:	LD	A,(MFlag)
	and	0ffh-UO_DDU		; Turn on Display Update
	LD	(MFlag),A		; Restore original front panel mode
	LD	HL,(UsrClk)
	LD	(UiVec+1),HL		; Clear timeout vector to just user vector
	LD	HL,I$2156
	LD	B,5
	CALL	ZeroMem			; Zero 5-byte block

	JP	UsrFWA			;  and enter boot code

BootTbl:
	dw	H17Boot			; H-17 Boot
	dw	H47Boot			; H-47 Boot
	dw	H67Boot			; H-67 Boot
	dw	H37Boot			; H-37 Boot

MsgPri: db      10011000b,11011110b,11011111b   ; 'Pri'
MsgLen  equ     $-MsgPri

MsgSec: db      10100100b,10001100b,10001101b   ; 'SEC'

;============================================================================
;	Device Error Display Entry Point
;
; Displays the 'DEU' message (for 'DEV') on the front panel
;============================================================================
ErrDevice:
	di
	ld	bc,DevMsg		; Display 'DEU' (for 'DEV')
	ld	de,DLeds
	call	BlkMovStk
	 db	3
; fall through

;============================================================================
;	Boot Error Display Entry Point
;
; Displays the 'Error ' message on the front panel
;============================================================================
ErrorDisplay:
	ld	a,(MFlag)
	or	UO_DDU			; Disable display update
	and	0ffh-UO_CLK		; Disable private clock processing
	ld	(MFlag),a
	ei
	LD	BC,ErrMsg		; Display 'Error '
	LD	DE,ALeds
	CALL	BlkMovStk
	 db	6
; fall through

;============================================================================
;	Error Acknowledge
;
; Waits for the operator to acknoledge the error condition by:
;
; - Sound the error BEEP
; - Strobe the keypad for 1/2 second, waiting for '*' keypress
; - Repeat
;============================================================================
ErrorAck:
	ld	a,50/2			; 50mSec error beep
	CALL	Horn

	ld	A,(TicCnt)		; Get current count LSB
	dec	a			; -1 for 255*2mSec Tics (1/2 second)
	ld	b,a			; Load delay counter
EAck5:	in	a,(IP_PAD)		; Read keypad
	cp	K_Star			; '*' pressed?
	jp	z,ErrorEnt		; Go if cancel pressed

	ld	a,(TicCnt)		; Get current count LSB
	cp	b
	jr	nz,EAck5		;  and go if not 1/2 second
	jr	ErrorAck

; "Error ' message string
ErrMsg:	db	10001100b, 11011110b, 11011110b	; 'Err'
	db	11000110b, 11011110b, 11111111b	; 'or '

;============================================================================
;	ClkInt - Clock Interrupt
;
; ClkInt is added to the normal Clock interrupt process during disk boot. It
; performs the following:
;
; - Check for keypad abort key ('*')
; - Every 1/2 second, bump the timeout counter
;
;  If the abort key (*) is pressed, exit the boot process by shutting down
; the selected disk drive, returning the clock processing to normal, and
; exiting via the ErrorEnt routine.
;
;  If the 15 second timeout expires, shut down the drives, restore normal
; clock processing, and exit via the ErrorDisplay routine.
;============================================================================
ClkInt:	PUSH	AF
	IN	A,(IP_PAD)
	CP	K_Star
	JR	Z,BootAbort

	LD	A,(TicCnt)
	AND	A			; 1/2 second elapsed?
	JR	NZ,BtClkExit		;  go if no

	LD	A,(TimOut)
	INC	A
	LD	(TimOut),A
	CP	30			; 30/2 = 15 second timeout
	JR	NC,BootTimeout		; Go if timed out

BtClkExit:
	POP	AF
	PUSH	HL
	LD	HL,(UsrClk)
	EX	(SP),HL
	RET				; Exit to the H17ROM clock processor

;============================================================================
;	DrvShutdown
;
;  DrvShutdown polls the Boot Device Flag (BDF) to determine the boot device,
; and then performs a command abort on that device.
;============================================================================
DrvShutdown:
	DI
	LD	A,(BDF)
; Was it Dev 0 (H17)?
	CP	0
	JR	NZ,TestDev1

	XOR	A
	LD	(D$20A3),A
	LD	A,(D_20A2)
	AND	80H
	LD	(D_20A2),A
	OUT	(DP_DC),A
	JR	RestoreBtClk

; Was it Dev 1 (H47)?
TestDev1:
	CP	1
	JR	NZ,TestDev2
	CALL	ByteToPortOff
; Two data bytes, value, then port offset
	db	2,0			; Send 2 to port (BDA+0)
;	LD	(BC),A
;	NOP
	JR	RestoreBtClk

; Was it Dev 2 (H67)?
TestDev2:
	CP	2
	JR	NZ,TestDev3
	CALL	ByteToPortOff
; Two data bytes: value, then port offset
	db	10h, 1			; Send 10h to port (BDA+1)
;	DJNZ	J$05FB
	JR	RestoreBtClk
;J$05FB	EQU	$-1


; Was it Dev 3 (H37)?
TestDev3:
	CP	3
	JR	NZ,RestoreBtClk
	CALL	ByteToPortOff
	 DB	0,0			; Send 0 to port (BDA+0)

RestoreBtClk:
	LD	HL,(UsrClk)		; Get default H17ROM Clock interrupt address
	LD	(UiVec+1),HL		;  and re-vector the clock int
	RET

;	-----------------
;?.060C:
	RST	38H
	RST	38H
	RST	38H
	RST	38H
	RST	38H
	RST	38H
	RST	38H
	JP	C_0713
;
;	-----------------
;?.0616:
	RST	38H
	JP	J$06F9
;
;	-----------------
BootAbort:
	CALL	DrvShutdown
	jp	ErrorEnt
;
;	-----------------
BootTimeout:
	CALL	DrvShutdown
	JP	ErrorDisplay

;============================================================================
;	Boot Processor - H-17
;============================================================================
H17Boot:
	LD	BC,H17BtMsg
	LD	DE,DLeds
	CALL	BlkMovStk
	 db	3

	XOR	A
	OUT	(DP_DC),A
	LD	HL,I$075B
	LD	(D$2086),HL
J$0639:	LD	E,0AH	; 10
J_063B:	CALL	C_0670
;
	AND	01H	; 1
	JP	Z,J_063B
;
J$0643:	CALL	C_0670
;
	AND	01H	; 1
	JP	NZ,J$0643
;
	DEC	E
	JP	NZ,J_063B
;
	 CALL	C$2085
;
	 CALL	C$208B
;
	LD	A,0AH	; 10
	LD	(D_RAM),A
	 CALL	C$2076
;
	 CALL	C$2061
;
	LD	DE,UsrFWA
	LD	BC,I$0900
	LD	HL,0
	 CALL	C$2067
;
	JP	C,J$0639
;
	RET
;
;	-----------------
;
;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________
;
C_0670:	LD	A,(AIO_UNI)
	LD	B,A
	INC	B
	XOR	A
	 CALL	C_07E1
;
	OR	10H	; 16
	OUT	(DP_DC),A
	IN	A,(DP_DC)
	RET

H17BtMsg:	db	10010010b, 11110011b, 11110001b	; Message 'H17'


;============================================================================
;	Boot Processor - H-47
;============================================================================
H47Boot:
	LD	BC,H47BtMsg
	LD	DE,DLeds
	CALL	BlkMovStk
	 db	3

J$068D:	CALL	C$0699
	RET	NC
	LD	A,500/2			; 500 mSec delay
	CALL	Dly
	JP	J$068D
;
;	-----------------
;
;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________
;
C$0699:	CALL	ByteToPortOff
	 db	2, 0			; Output data, then port offset

	LD	A,20			; Short delay loop
J$06A0:	DEC	A
	JR	NZ,J$06A0
	CALL	C_0789
	RET	C

J$06A7:	CALL	C_076E
	RET	C

	CALL	C_076E
	RET	C

	LD	A,(AIO_UNI)
	LD	B,A
	XOR	A
	CALL	C_07E1
	AND	L
	JP	NZ,J$06A7

	CALL	C_06F5

	INC	BC
	RET	C

	CALL	C_070F
	NOP
	RET	C

	CALL	C_070F
	LD	(BC),A
	RET	C
;
	CALL	C_0789
;
	RET	C
;
	 CALL	C_06F5
;
	RLCA
	RET	C
;
	 CALL	C_070F
;
	NOP
	RET	C
;
	LD	A,(AIO_UNI)
	RRCA
	RRCA
	RRCA
	OR	01H	; 1
	 CALL	C_0713
;
	RET	C
;
	LD	DE,UsrFWA
J$06E7:	 CALL	PIN
;
	JP	C,C_0789
;
	LD	(DE),A
	INC	DE
	JP	J$06E7

H47BtMsg:	db	10010010b, 10110010b, 11110001b	; Message 'H47'


;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________
;
; Pop data into A from top of stack
C_06F5:	EX	(SP),HL
	LD	A,(HL)
	INC	HL
	EX	(SP),HL
J$06F9:	PUSH	AF
	CALL	C_0789
	JP	C,J$070C
	POP	AF
	CALL	AtoPortOff		; **************************************
	LD	BC,I$1406

J$0707:	DEC	B
	JR	NZ,J$0707
	AND	A
	RET
;
;	-----------------
J$070C:	INC	SP
	INC	SP
	RET
;
;	-----------------
;
;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________
;
; Pop byte off top of stack

C_070F:	EX	(SP),HL
	LD	A,(HL)
	INC	HL
	EX	(SP),HL
;
;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________
;

C_0713:	PUSH	AF
	CALL	C$07A4
	JP	C,J$0721

	POP	AF
	CALL	AtoPortOff
; One byte at top of stack

	LD	BC,I_C9A7

J$0721:	INC	SP
	INC	SP
	RET
;
;	-----------------


EiRet:	EI
	RET

;============================================================================
;	ByteFromPortOff
;
; Inputs a byte from the port at (BDA) + offset on top of Stack
;============================================================================
ByteFromPortOff:
	ex	(sp),hl
	push	bc
	ld	c,(hl)			; Get port offset from Stack
	inc	hl			; Bump past the byte
	ld	a,(BDA)			; Get Boot Device Address
	add	a,c			; Add offset from Stack
	ld	c,a
	in	a,(c)			; Input from the port
	pop	bc			; Restore Stack
	ex	(sp),hl
	ret

;============================================================================
;	ByteToPortOff
;
; Sends the byte on the top of the Stack to the port at Top of Stack + 1.
;============================================================================
ByteToPortOff:
	ex	(sp),hl
	ld	a,(hl)			; Get the byte to send
	inc	hl			; Bump stack to next byte
	ex	(sp),hl			;  and set new Stack pointer
; fall through

;============================================================================
;	AtoPortOff
;
; Send byte in A to (BDA) + offset on top of stack
;============================================================================
AtoPortOff:
	ex	(sp),hl
	push	bc
	push	af			; Save output byte
	ld	c,(hl)			; Get port offset from Stack
	inc	hl			; Bump Stack to new address
	ld	a,(BDA)			; Get Boot Device Address
J$0740:	add	a,c			; Add to offset value
	ld	c,a
	pop	af			; Restore byte to output
	out	(c),a			; Send it
	pop	bc			; Restore Stack
	ex	(sp),hl			;  and set new Stack pointer
	ret

;============================================================================
;	PIN - Port In
;
;  Input a byte of data from H47 with DTR handshake.
;
;	Outputs		'C' set if Error, else NC
;			A has data byte
;============================================================================
PIN:	CALL	ByteFromPortOff
	 db	0
	AND	0A0H
	JP	Z,PIN			; Not done, not ready to xfer

	AND	20H
	SCF
	RET	NZ			; Error - done before DTR

	CALL	ByteFromPortOff
	 db	1
	AND	A
	RET


I$075B:	LD	A,0AH	; 10
	LD	(D$20B4),A
	LD	A,(AIO_UNI)
	PUSH	AF
	CP	02H	; 2
	JP	C,J_1E3B
;
	LD	A,03H	; 3
	JP	J_1E3B
;
;	-----------------
;
;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________
;
C_076E:	CALL	C_06F5
	DJNZ	J$0740
	LD	C,B
	RLCA
	RET	C
	LD	L,A
	CALL	C_0789
	RET

;============================================================================
;	Subroutine	BlkMovStk - Block Move, Count on Stack
;
;  Move bytes from (BC) to (DE), with the byte count on the top of the stack.
;============================================================================
BlkMovStk:
	ex	(sp),hl			; Put SP in HL
	ld	a,(hl)			; Get next byte
	inc	hl			; Bump HL
	EX	(sp),hl			;  and put back in SP
	ld	L,a			; Counter to L

BLM55:	ld	a,(bc)			; Move from BC
	ld	(de),A			;  to DE
	inc	bc
	inc	de
	dec	L			;  for L # of bytes
	jp	nz,BLM55
	ret

;
;	-----------------
;
;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________
;
C_0789:	LD	BC,32000
J$078C:	DEC	BC
	LD	A,B
	OR	C
	SCF
	RET	Z
;
	CALL	ByteFromPortOff
	 db	0

	AND	20H	; " "
	JP	Z,J$078C
;
	CALL	ByteFromPortOff
	 db	0

	AND	01H	; 1
	SCF
	RET	NZ
;
	AND	A
	RET
;
;	-----------------
;
;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________
;
C$07A4:	LD	BC,32000
J$07A7:	CALL	ByteFromPortOff
	 db	0

	AND	20H	; " "
	SCF
	RET	NZ
;
	DEC	BC
	LD	A,B
	OR	C
	SCF
	RET	Z

	CALL	ByteFromPortOff
	 db	0

	AND	80H
	JP	Z,J$07A7

	RET
;
;	-----------------
;
;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________
;
C$07BE:	LD	(ABUSS),HL
	XOR	A
	LD	(Radix),A
	LD	HL,DefPC
	RET
;
;	-----------------
;
;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________
;
C$07C9:	LD	A,4EH	; "N"
	OUT	(0F9H),A
	ld	hl,ErrorEnt
	IN	A,(0F2H)
	AND	80H
	RET	Z
;
	LD	HL,AutoB
	RET
;
;	-----------------
J$07D9:	jp	z,ErrorEnt
;
	INC	HL
	POP	AF
	JP	IOA
;
;	-----------------
;
;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________
;
C_07E1:	PUSH	BC
	PUSH	AF
	LD	A,80H
	INC	B
J$07E6:	RLCA
	DEC	B
	JP	NZ,J$07E6

	ld	c,a
	pop	af
	or	c
	pop	bc
	ret

	db	0ffh, 0ffh, 0ffh, 0ffh

	  if  ($ != 07F4H)
	error "* Address Error @ 07F4H *"
	  endif

DefPC:	jp	PriBt1
	jp	SecBt1
	jp	$			; H89 compatibility
	jp	$			; H89 compatibility


NmiHandler:
J_0800:	PUSH	HL
	LD	HL,(D$2034)
	EX	(SP),HL
	RET
;
;	-----------------

SavAllExt:
	LD	A,I
	LD	B,A
	PUSH	BC
	PUSH	IY
	PUSH	IX
	PUSH	HL
	EXX
	EX	AF,AF'
	EX	(SP),HL
	PUSH	DE
	PUSH	BC
	PUSH	AF
	EX	DE,HL			; DE gets return address
	LD	HL,24
	ADD	HL,SP			; HL = address of users SP
	PUSH	HL			; Set on stack as register
	PUSH	DE			; Stack the return address
	LD	DE,CtlFlg
	LD	A,(DE)			; A gets CtlFlg contents
	JP	SavAllRet
;
;	-----------------
J$0823:	POP	HL
	POP	IX
	POP	IY
	EXX
	EX	AF,AF'
	POP	BC
	LD	A,B
	LD	I,A
	POP	AF
	POP	BC
	POP	DE
	POP	HL
	EXX
	EX	AF,AF'
	EI
	RET


;============================================================================
;         Subroutine	SStepRtnExt - Single Step Return Extended
;
;  This is an extension of the PAM/8 Single Step Return routine.  There are
; many more registers that need to be restored in PAM/37 with the Z80 CPU.
;
; Exit is to the User Interrupt Vector
;============================================================================
SStepRtnExt:
	POP	HL
	POP	AF
	POP	BC
	POP	DE
	POP	HL
	EX	AF,AF'
	EXX
	POP	HL
	POP	HL
	POP	HL
	POP	AF
	POP	BC
	POP	DE
	POP	HL
	EX	AF,AF'
	EXX
	PUSH	HL
	PUSH	DE
	PUSH	BC
	PUSH	AF
	LD	HL,10
	ADD	HL,SP
	PUSH	HL
	jp	UiVec+3

;============================================================================
;         Subroutine	ExtRegTest - Extended Register Test
;
;  Test for valid register #.  This is an extension of the PAM/8 register
; check.  PAM/8 only checks 6 registers; PAM/37 must check 13.
;
;	Entry	'A' has register #
;
;	Exit	'C' set & return to caller of OK
;		To ErrorEnt if bad register #
;============================================================================
ExtRegTst:
	cp	12			; Is register less than PC reg?
	ret	c			;  exit if yes - valid register
	sub	3			; Offset to PC register
	cp	12			; Is it PC register?
	scf				; Assume yes - valid register
	ret	z			;  and exit if PC reg
	jp	ErrorEnt

;============================================================================
;	Boot Processor - H-37
;============================================================================
H37Boot:
	LD	BC,H37BtMsg
	LD	DE,DLeds
	call	BlkMovStk
	 db	3

	CALL	ByteToPortOff
	 db	0, 1

	call	ByteToPortOff
	 db	0d0h, 2		; FORCE INTR command

	LD	A,2/2		; 2mSec delay
	CALL	Dly
;
	CALL	ByteFromPortOff
	 db	2

	LD	HL,I$096B
	LD	(D$2029),HL
	LD	A,0C3H
	LD	(X_2028),A
	LD	A,(AIO_UNI)
	ADD	A,04H	; 4 bits left (hi nibble)
	LD	B,A
	XOR	A
	 CALL	C_07E1
;
	OR	0DH	; INTEN, DDEN, MOTOR
	CALL	AtoPortOff
	 db	0

	LD	B,A
	PUSH	BC
	EI
	LD	A,96H
	 CALL	Dly
;
	LD	HL,I$08BE
	LD	(D_2037),HL
	CALL	ByteToPortOff
	 db	3, 2			; RESTORE command

	LD	BC,0FFFFh
	LD	D,06H	; 6
J_08AE:	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,J_08AE
;
	DEC	D
	JR	NZ,J_08AE
;
	CALL	ByteToPortOff
	 db	0d0h,2		; FORCE INTR command

	JP	J_091F
;
;	-----------------
I$08BE:	LD	E,10		; step in 10 tracks
	LD	HL,I$08CE
	LD	(D_2037),HL
J$08C6:	CALL	ByteToPortOff
	 db	43h, 2		; STEP IN command

	JP	J_08AE
;
;	-----------------
I$08CE:	LD	HL,I_08E3
	DEC	E
	JP	NZ,J$08C6
;
	LD	HL,I_08E3
	LD	(D_2037),HL
	CALL	ByteToPortOff
	 db	3, 2		; RESTORE command

	JP	J_08AE
;
;	-----------------

; Some sort of data table
I_08E3:	AND	04H	; TR00 flag
	JR	Z,J_091F
I_08E6	EQU	$-1
;
	LD	BC,3200
J$08EA:	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,J$08EA
;
	POP	BC
	LD	A,B
	OR	02H	; DDEN
	LD	B,A
	PUSH	BC
	CALL	AtoPortOff
	 db	0

	 CALL	C_0927

	POP	BC
	PUSH	AF
	LD	A,B
	AND	0FBH	; ~DDEN
I$0900	EQU	$-1
	LD	B,A
	POP	AF
	JR	NZ,J$090D
;
	LD	HL,-UsrFWA
	ADD	HL,DE
	LD	A,H
	CP	09H	; Should have >= 10 pages
	RET	NC
;
J$090D:	LD	A,B
	CALL	AtoPortOff
	 db	0

	 CALL	C_0927
;
	JR	NZ,J_091F
;
	LD	HL,-UsrFWA
	ADD	HL,DE
	LD	A,H
	CP	09H	; Should have >= 10 pages
	RET	NC
;
J_091F:	 CALL	ByteToPortOff
	DB	0,0			; control port all-off

	JP	ErrorDisplay
;
;	-----------------
;
;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________
;
C_0927:	CALL	ByteToPortOff
	 db	01, 01		; Mux port 1 (trk/sec regs)

	call	0738h		; SECTOR = 1
	LD	(BC),A
	CALL	ByteToPortOff
	 db	0, 1		; Mux port 0 (cmd-sts/dat regs)

	ld	bc,I$095B	; copy template into RAM
	LD	DE,J_203C
	call	BlkMovStk
	 db	6

	ld	a,(BDA)
	add	a,3		; compute FDC data register
	LD	(D$203E),A	; put port adr into routine
	LD	HL,I$0961
	LD	(D_2037),HL
	LD	HL,J_203C
	LD	DE,UsrFWA
	CALL	ByteToPortOff
	 db	9ch, 2		; READ SECTOR, MULTI, command

	JP	J_203C
;
;	-----------------
;	Template for H37 read data routine
I$095B:	HALT
	IN	A,(03H)	; real port adr substituted later
	LD	(DE),A
	INC	DE
	JP	(HL)
;
;	-----------------
I$0961:	PUSH	AF
	CALL	ByteToPortOff
	 db	8,0	; only MOTOR on

	POP	AF	; restore FDC status
	AND	0ACH	; check NOTRDY, DELDAT, CRCERR, DATLOST
	RET
;
;	-----------------
I$096B:	CALL	ByteFromPortOff
	 db	2	; FDC status register, also turns off INTRQ

	POP	HL
	LD	HL,(D_2037)
	EI
	JP	(HL)
;
;	-----------------
H37BtMsg:	db	10010010b, 11100000b, 11110001b	; Message 'H37'

;============================================================================
;	Boot Processor - H-67
;============================================================================
H67Boot:
	LD	BC,H67BtMsg
	LD	DE,DLeds
	call	BlkMovStk
	 db	3

	LD	A,500/2			; 1/2 second delay (500 mSec)
	 CALL	Dly
;
	LD	A,(MFlag)
	and	0ffh-UO_CLK		; Disable clock processing
	LD	(MFlag),A
	CALL	ByteToPortOff
	 db	10h, 1			; Output data, then port offset

	LD	A,8/2			; 8mSec delay
	CALL	Dly
;
	LD	HL,I_2132
	LD	(HL),00H
	LD	C,05H	; 5
J$09A0:	INC	HL
	LD	(HL),00H
	DEC	C
	JR	NZ,J$09A0
;
	 CALL	C_0A06
;
	LD	(D_2133),A
J$09AC:	 CALL	C_0A0F
;
	JR	NC,J$09BB
;
	JP	Z,ErrorDisplay
;
	LD	A,0FFH
	 CALL	Dly
;
	JR	J$09AC
;
;	-----------------
J$09BB:	LD	HL,I_2132
	LD	(HL),01H	; 1
	 CALL	C_0A0F
;
	JP	C,ErrorDisplay
;
	LD	A,(AIO_UNI)
	AND	A
	JP	NZ,J$09EB
;
	LD	HL,I_2132
	LD	(HL),0BH	; 11
	INC	HL
	INC	HL
	LD	(HL),07H	; 7
	 CALL	C_0A0F
;
	JP	C,ErrorDisplay
;
	LD	HL,I_2132
	LD	(HL),01H	; 1
	INC	HL
	INC	HL
	LD	(HL),00H
	 CALL	C_0A0F
;
	JP	C,ErrorDisplay
;
J$09EB:	LD	HL,I_2132
	LD	(HL),08H	; 8
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	LD	(HL),0AH	; 10
	INC	HL
	LD	(HL),80H
	 CALL	C_0A06
;
	LD	(D_2133),A
	 CALL	C_0A0F
;
	JP	C,ErrorDisplay
;
	RET
;
;	-----------------
;
;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________
;
C_0A06:	LD	A,(AIO_UNI)
	RRCA
	RRCA
	RRCA
	AND	60H	; "`"
	RET
;
;	-----------------
;
;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________
;
C_0A0F:	DI
	LD	BC,0FFFFh
	LD	D,02H	; 2
J_0A15:	 CALL	ByteFromPortOff			; ************************************
;
	LD	BC,I_08E6
	JR	Z,J$0A27
;
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,J_0A15
;
	DEC	D
	JR	NZ,J_0A15
;
	SCF
	RET
;
;	-----------------
J$0A27:	CALL	ByteToPortOff
	 db	40h, 1			; Output data, then port offset

J$0A2C:	call	0726h

	LD	BC,I_08E6
	JR	NZ,J$0A3B
;
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,J$0A2C
;
	SCF
	RET
;
;	-----------------
J$0A3B:	CALL	ByteToPortOff
	 db	02, 01			; Output data, then port offset

 	ld	hl,2132h

J_0A43:	call	0726h
	LD	BC,I$A74F
	JP	P,J_0A43
;
	AND	10H	; 16
	JR	Z,J$0A94
;
	LD	A,C
	AND	40H	; "@"
	JR	Z,J_0A5D
;
	LD	A,(HL)
	CALL	AtoPortOff
	 db	0

 	INC	HL
	JR	J_0A43
;
;	-----------------
J_0A5D:	 CALL	ByteFromPortOff			; ****************************************

	LD	BC,0D0E6H
	CP	90H
	JR	NZ,J_0A5D
;
	 CALL	ByteFromPortOff
;
	NOP
	LD	C,A
	LD	(D$2138),A
J$0A6F:	CALL	ByteFromPortOff			; ****************************************

	LD	BC,03247H
	ADD	HL,SP
	LD	HL,0E0E6H
	CP	0A0H
	JR	NZ,J$0A6F
;
	LD	(D$213A),A
	EI
	CALL	ByteFromPortOff
	 db	0

	OR	A
	SCF
	RET	NZ
;
	LD	A,C
	AND	03H	; 3
	SCF
	RET	NZ
;
	LD	A,B
	AND	02H	; 2
	SCF
	RET	NZ
;
	XOR	A
	RET
;
;	-----------------
J$0A94:	LD	HL,UsrFWA
J_0A97:	 CALL	ByteFromPortOff			; ******************************************

	LD	BC,0E64FH
	ADD	A,B
	JR	Z,J_0A97
;
	LD	A,C
	AND	10H	; 16
	JR	NZ,J_0A5D
;
	CALL	ByteFromPortOff
	 db	0

	LD	(HL),A
	INC	HL
	JR	J_0A97
;
;	-----------------
H67BtMsg:	db	10010010b, 10000100b, 11110001b	; Message 'H67'


; Universal Boot.  This is a 'possible' name - not certain about it yet.

UnivBoot:
	LD	A,(MFlag)
	or	UO_DDU			; Disable display update
	LD	(MFlag),A
	LD	BC,DevMsg		; Display the DEV msg
	LD	DE,ALeds
	call	BlkMovStk
	 db	3

	LD	L,6			; Set 6 bytes
	LD	A,0FFH			;  to 0FFh
J$0AC6:	LD	(DE),A
	INC	DE
	DEC	L
	JP	NZ,J$0AC6
;
	 CALL	C_0B1D			; Get boot device selection
;
	LD	(BDF),A			; Save boot device flag
	ADD	A,A
	LD	L,A
	LD	H,0
	LD	DE,I$0B37
	ADD	HL,DE
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	LD	DE,ALeds
	call	BlkMovStk
	 db	3

	LD	BC,I$0B31
	call	BlkMovStk
	 db	3

	CALL	C_0B1D			; Get boot device selection
;
	PUSH	AF
	LD	L,A
	LD	H,00H
	LD	DE,I$0B3F
	ADD	HL,DE
	LD	A,(HL)
	LD	(BDA),A
	LD	B,0FFH
	LD	HL,I$200E
	CALL	DOD			; Decode Octal Display
;
	LD	D,H
	LD	E,L
	LD	BC,I_0B34
	call	BlkMovStk
	 db	3

	CALL	C_0B1D
;
	LD	(AIO_UNI),A
	ld	sp,Stack
	LD	A,(BDF)
	LD	BC,I_0B34
	JP	Boot3
;
;	-----------------
;
;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________
;
C_0B1D:	CALL	RCK			; Read keypad
	CP	04H			;  and rtn if 0-3 pressed
	RET	C
	CP	0CH			; See if '*' pressed
	jp	z,ErrorEnt		;  and exit via error if so
	CALL	Alarm			; Non valid key, sound error
	JP	C_0B1D

DevMsg:	db	0c2h, 08ch, 083h	; 'DEV' display (Device)


; ASCII data table

I$0B31:	SBC	A,B
	ADD	A,0DEH
I_0B34:	ADD	A,E
	SUB	0F7H
I$0B37:	ADD	A,B
J$0B38:	LD	B,0F2H
	LD	B,0ADH
	LD	A,(BC)
	LD	(HL),L
	ADD	HL,BC
I$0B3F:	LD	A,B
	LD	A,H
	CP	B
	CP	H



; This is the AutoBoot entry from the jump table, but it seems to only perform
; the RADIX function, then exits via HORN.
;
; Auto Boot? 0b43h
AutoBoot:
	LD	A,(MFlag)
	OR	UO_DDU			; Disable display update
	LD	(MFlag),A
	LD	BC,I$0B89		; Display "rAd" (Radix) message
	LD	DE,ALeds
	call	BlkMovStk
	 db	3

	LD	L,6
	LD	A,0FFH			; Turn off next 6 LEDs
AB010:	LD	(DE),A
	INC	DE
	DEC	L
	JP	NZ,AB010		; Loop until 6 blank LEDs


	LD	A,(Radix)		; Get current Radix flag
	AND	A			; Clear flags
	CPL				; Complement (Z to NZ or NZ to Z)
	JP	Z,AB015			; Go if Radix now Z
	XOR	A			; Else set to Z

AB015:	LD	(Radix),A
	AND	13H	; 19
	XOR	81H
	LD	(D$2010),A

	LD	A,250			; Wait 2*250 mSec (500 mSec)
	CALL	Dly
	LD	A,250
	CALL	Dly			; Wait 2*250 mSec (500mSec)

	LD	A,(MFlag)
	and	0ffh-UO_DDU		; Enable display update
	LD	(MFlag),A
	LD	A,17			; 34 mSec (17*2) horn sound
	JP	Horn

I$0B89:
	db	0deh, 90h, 0c2h		; "rAd" message (Radix)


IoaExt:
	push	af
	ld	a,(Radix)		; Test the radix
	and	A
	JP	NZ,J$0B9C		; Go if radix is HEX

	POP	AF
	CALL	ExtOct
	DEC	HL
	JP	ExtOct
;
;	-----------------
J$0B9C:	POP	AF
	CALL	IobExtHEX		; Get first byte of HEX address
	DEC	HL
	XOR	A
	SCF				; Flag cannot be a zero byte
;  and fall through for second byte

;============================================================================
;         Subroutine	IobExtHEX - HEX Byte Input
;
;  This is the HEX byte input, vectored from the IobExt routine below.
;============================================================================
IobExtHEX:
	call	nc,RCK			; Get zero character???
	and	a
	jp	nz,ErrorEnt		; Go if non-zero entered???
	ld	d,2			; 2 digit input
ExtHex5:
	call	RCK			; Get character
	ld	e,a			;  and save
	ld	a,(hl)			; Get previous character
	rlca				; Shift 4 bits left
	rlca
	rlca
	rlca
	and	0f0h			;  and mask
	or	e			; OR in new character
	ld	(hl),a			;  and save
	dec	d			; -1 for loop count
	jp	nz,ExtHex5		; Loop for 2nd hex char

	ld	a,30/2			; 30mSec beep to acknowledge entry
	jp	Horn

;============================================================================
;         Subroutine	IobExt - Input Octal Byte Extension
;
;  The XCON/8 IOB routine is replaced by IobExt to allow for HEX or OCTAL
; character entry, depending on the (Radix) value.
;
;  Check the Radix, and dispatch to the HEX or Octal routines, as required.
;============================================================================
IobExt:	PUSH	AF
	LD	A,(Radix)
	AND	A
	JP	Z,IobExtOct		; Go if Octal radix?
	POP	AF
	JP	IobExtHEX

;============================================================================
;         Subroutine	IobExtOct - Octal Byte Input
;
;  This is the Octal byte input, vectored from the IobExt routine above.
;============================================================================
IobExtOct:
	pop	af
ExtOct:	ld	d,3			; Digit counter
ExtOct5:
	CALL	NC,RCK			; Read keypad
	CP	8
	jp	nc,ErrorEnt		; Error if input above 7
	LD	E,A			; Keypad value to E
	LD	A,(HL)			; Get current byte contents
	RLCA				; Rotate left 3
	RLCA
	RLCA
	AND	11111000b		; Mask
	OR	E			; OR in new keypad value
	LD	(HL),A			; Replace old value
	DEC	D			; -1 for digit counter
	JP	NZ,ExtOct5		; Loop for all 3 digits
	LD	A,30/2			; 30mSec beep to acknowledge entry
	JP	Horn

;============================================================================
;         Subroutine	DodExt - Decode Octal Display Extension
;
;  This is the Decode Octal Display extension.  The original DOD routine is
; vectored here to test the Radix flag prior to execution.  If the current
; Radix is Octal, the routine returns to the standard Octal DOD routine.  If
; the Radix is HEX, it is handled here, then returned to the routine that
; called DOD in the first place.
;============================================================================
DodExt:	ld	c,a			; Save value being displayed
	ld	a,(Radix)
	and	a			; Set 'Z' if Octal
	ld	a,c			; Restore display value
	jp	nz,DodExtHex

	push	de
	ld	d,DodOct/256		; DODA/256
	jp	DodRet

DodExtHex:
	push	de			; Save DE
	ld	c,2			; 2 characters

DEH55:	RLCA				; Put high nibble in low
	RLCA
	RLCA
	RLCA
	PUSH	AF			; Save
	AND	0Fh			; Mask to low nibble only
	ADD	A,6EH
	LD	E,A
	LD	A,0CH	; 12
	ADC	A,0
	LD	D,A
	LD	A,(DE)
	XOR	B
	AND	7FH
	XOR	B
	LD	(HL),A
	INC	HL
	LD	A,B
	RLCA
	LD	B,A
	POP	AF
	DEC	C			; -1 for character
	JP	NZ,DEH55		; Loop for 2nd char

	POP	DE			; Restore
	LD	A,6FH	; "o"
	XOR	B
	AND	7FH
	XOR	B
	LD	(HL),A
	INC	HL
	LD	A,B
	RLCA
	LD	B,A
	ret

;============================================================================
;	Subroutine	Move3Bytes
;
; Continuation of
;============================================================================
Mov3Bytes:
	call	BlkMovStk
	 db	3			; Move 3 bytes
	ret				;  and exit

;============================================================================
;	Display Segment Coding
;
;	Byte = 76 543  210
;
;	 1		----
;      6   2	       |    |
;        0		----
;      5   3	       |    |
;        4		----
;	      7		     DP
;============================================================================

DispSP:		db	0ffh, 0a4h, 098h
DispAF:		db	0ffh, 090h, 09ch
DispBC:		db	0ffh, 086h, 08dh
DispDE:		db	0ffh, 0c2h, 08ch
DispHL:		db	0ffh, 092h, 08fh
DispIX:		db	0ffh, 0f3h, 0b6h
DispIY:		db	0ffh, 0f3h, 0a2h
DispIR:		db	0ffh, 0f3h, 0deh
DispAFp:	db	090h, 09ch, 0bfh
DispBCp:	db	086h, 08dh, 0bfh
DispDEp:	db	0c2h, 08ch, 0bfh
DispHLp:	db	092h, 08fh, 0bfh
DispPC:		db	0ffh, 098h, 0ceh

LedRegTbl:
	dw	DispSP			; SP
	dw	DispAF			; AF
	dw	DispBC			; BC
	dw	DispDE			; DE
	dw	DispHL			; HL
	dw	DispIX			; IX
	dw	DispIY			; IY
	dw	DispIR			; IR
	dw	DispAFp			; AF'
	dw	DispBCp			; BC'
	dw	DispDEp			; DE'
	dw	DispHLp			; HL'
	dw	DispPC			; Program Counter


; Hex to 7-Segment patterns
DodHex:
	db	00000001b		; 0
	db	01110011b		; 1
	db	01001000b		; 2
	db	01100000b		; 3
	db	00110010b		; 4
	db	00100100b		; 5
	db	00000100b		; 6
	db	01110001b		; 7
	db	00000000b		; 8
	db	00100000b		; 9
	db	10h			; A
	db	06h			; B
	db	0dh			; C
	db	42h			; D
	db	0ch			; E
	db	1ch			; F

	  if  ($ != 0c7eh)
	error	"* End of Code Address Error *"
	  endif

EndOfCode	equ	$


	mlist -1
	rept	0e8bh-$
	db	0ffh
	endm
	mlist 1

Credits:
	db	cr,lf,cr,lf
	db	"Pam-80 - Front Panel Monitor for the Heath H8 and WH8 Digital Computers."
	db	cr,lf
	db	"Software Issue #01.03.00."
	db	cr,lf,cr,lf
	db	"    Copyright",tab,"February 1982"
	db	cr,lf
	db	tab,tab,"by Steve Parker"
	db	cr,lf
	db	tab,tab,"Firmware Engineer"
	db	cr,lf
	db	tab,tab,"Zenith Data Systems"
	db	cr,lf
	db	tab,tab,"St. Joseph, MI	49085"
	db	cr,lf,cr,lf
	db	"Heath Part Number: 444-140"
	db	cr,lf,cr,lf
	db	"Requires HA8-6 Z80 CPU and either a 444-70 or 444-124 ROM device."
	db	cr,lf,"Use with 390-2333 keypad labels on front panel."
	db	cr,lf,cr,lf

LenCredit	equ	$-Credits

	  if  ($ != 1000h)
	error	"* Code overflows i2732 EPROM size *"
	  endif

	end

