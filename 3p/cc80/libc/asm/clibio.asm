; May 9, 1984  16:28  drm  "CLIBIO.C" */
; modified for DRI RMAC and .PRL generation */
; CLIBIO.C : includes environment dependent routines (e.g, argument list
;	     preparation, I/O).  This code is not ROMable and must
;	     be replaced if a ROMable object module is to be generated.
; IMPORTANT: CLIBIO must be loaded last in the object module to define @@END.

; C/80 3.1 runtime library. (c) 1983 Walter Bilofsky.  All rights
;  reserved.  This library in C source and assembler source form may
;  not be copied or transmitted to other than the original purchaser
;  of C/80.  Executable object modules including code produced by
;  C/80 and by this library may be distributed without restriction;
;  acknowledgement that C/80 is used would be appreciated. */

; NFILES = number of files open at one time. */
NFILES	equ 6
NULL	equ 0

abort	equ 0
SCIN	equ 1
SCOUT	equ 2
PRINT	equ 9
READC	equ 10
CONSTAT equ 11
OPENR	equ 15
CLOSE	equ 16
DELETE	equ 19
readf	equ 20
writef	equ 21
MAKE	equ 22
SETDMA	equ 26

EOL	equ 13		; End of line = CR, */
LF	equ 10		; LF. */
EOF	equ 26		; ASCII End of file */
FCBLEN	equ 36		; Length of an FCB */
PUNIT	equ 32		; Lowest physical I/O channel */


; Entry for all C programs.  Initialize I/O channel array.
; Get all possible memory and put stack up at the top. */

; CLIBRARY.ASM 3.0 (4/3/84) - (c) 1982, 1983, 1984 Walter Bilofsky
; Multiply and divide routines (c)1981 UltiMeth Corp. Permission is gran-
; ted to reproduce them without charge, provided this notice is included.

	extrn	wboote,bdose,deffcb,defbuf
	extrn	main,c@ugt,c@uge,c@sxt,s@1,h@,q@

	public	exit,fin,fout,@@END
	public	Cmode,CtlCk,x0fcb,x?fcb,CtlB,NAM@U,??PC2,??CL2
	public	c?lib,iobuf,iofcb,q8qend,fclose,fopen,sbrk,getcha
	public	getc,ioprea,putcha,putc,iopwri,iosect,iorw,iotmp,ioch
	public	ioind,iomode,iobin,ioseek,ionch,iopcha,iopeof,write,read

c?lib:	cseg

@@AS	EQU	$+2	   ; CP/M- use this code area for argv arg list */
@@AG	EQU	$

@@INIT: DW	0		; No-op; initializes $AG */
	LHLD	bdose+1 	; Max mem address */
	DCX	H
	DCR	H		; At this point, HL contains max usable */
	SHLD	IObuf+6 	; memory address.  Allocate 3 buffers; */
	DCR	H		; use likely HDOS overlay area at top memory */
	SHLD	IObuf+4
	DCR	H
	SHLD	IObuf+2
	LXI	B,-FCBLEN	; Allocate 3 FCBs */
	DAD	B
	SHLD	IOfcb+4
	DAD	B
	SHLD	IOfcb+2
	DAD	B
	SHLD	IOfcb
	LXI	B,-135		; and console buffer */
	DAD	B
	MVI	M,0
	SHLD	Cbuf
	DCX	H
	MVI	M,132
	DCX	H
	SPHL			; Set up stack */
	LXI	D,Q8QEND       ; Set sbrk locn to higher of code, data segs */
	PUSH	D
	LXI	H,@@END
	CALL	c@ugt
	POP	H
	JZ	@@A81
	SHLD	@@LM
@@A81:	LXI	H,defbuf	; Get address of arg line */
	MOV	E,M		; And char count */
	MVI	M,' '		; Add on space we might or might not take */
	MVI	D,0
	DAD	D		; Get end of string */
	INR	E		; Fix char count */
	LXI	B,0		; Push 2 0 bytes to start */
@@A8:	PUSH	B
	MOV	B,M		; Move string onto stack 2 bytes at a time */
	DCX	H		; (necessary because CP/M 1.4 clobbers 80H) */
	MOV	C,M
	DCX	H
	DCR	E
	DCR	E
	JP	@@A8
	LXI	H,202AH 	; Push first arg, which is always * */
	PUSH	H
	LXI	H,@@AS		; Push fwa of arg stack */
	PUSH	H
	LXI	H,2		; Leave arg line address in HL */
	DAD	SP
@@A2:	DS	0		; Scan next argument. */
@@A7:	MOV	A,M		; Skip over blanks between args. */
	INX	H		
	ORA	A		
	JZ	@@A6		; Terminate on 0 byte */
	CPI	' '
	JZ	@@A7
	MOV	C,A		; Save first character of arg in C */
	CPI	'"'		; If it's a quote character, leave it */
	JZ	@@A3		;  (so C contains terminator char) */
	CPI	047Q
	JZ	@@A3
	MVI	C,' '		; Otherwise terminate on blank */
	DCX	H		;  and include first char in arg */
@@A3:	POP	D		; Store address of arg in arg list */
	MOV	A,L
	STAX	D
	INX	D
	MOV	A,H
	STAX	D
	INX	D
	PUSH	D
	PUSH	H		; Save address of arg on stack */
	DCX	H
@@A9:	INX	H		; Skip to end of argument */
	MOV	A,M
	ORA	A
	JZ	@@A5
	CMP	C
	JNZ	@@A9
	MVI	M,0		; Terminate arg with 0 byte */
	INX	H
@@A5:	XTHL		; Check for > or < arg for I/O redirection */
	MOV	A,M
	INX	H
	CPI	'<'
	JZ	@@B1
	CPI	'>'
	JZ	@@B2
	LXI	H,@@AG		; Bump arg count */
	INR	M
	POP	H		; Restore command line pointer */
	JMP	@@A2		; Go do next arg */
@@A6:	POP	H		; Done with command line.  Put -1 at end */
	MVI	M,-1		; of array, push argv and argc. */
	INX	H
	MVI	M,-1
	LHLD	@@AG
	PUSH	H
	LXI	H,@@AS
	PUSH	H
	CALL	main
exit:	LHLD	fout
	MOV	A,H
	ORA	L
	JZ	@@B4
	PUSH	H
	CALL	fclose
@@B4:	JMP	wboote
exic	EQU	exit

; I/O redirection: open a file */
@@B1:	PUSH	H
	LXI	H,@@BR
	PUSH	H
	CALL	fopen
	SHLD	fin
	JMP	@@B3
@@BR:	DB	'r',0
fin:	DW	0
@@B2:	PUSH	H
	LXI	H,@@BW
	PUSH	H
	CALL	fopen
	SHLD	fout
@@B3:	POP	B
	POP	B
	JC	@@B0

; Restore command line pointer; discard the > or < arg */

	POP	H
	POP	D
	DCX	D
	DCX	D
	PUSH	D
	JMP	@@A2
@@B0:	LXI	D,@@BMS
	MVI	C,PRINT
	CALL	bdose
	MVI	C,abort
	CALL	bdose

@@BMS:	DB	'Can''t open > or < file.$'

CtlB	EQU	$+1	; Patch here for ctl-c action */
	JMP	exic	; Patch here for ctl-c action */

@@BW:	DB	'w',0
fout:	DW	0

; Allocate memory; return -1 if none available (with 500 byte threshold) */

; WARNING : upon program execution, @@LM MUST point to the very end
;	     of the program.  Because LINK and L80 load the data segment
;	     differently, @@LM is computed at initialization time.

sbrk:	POP	D
	POP	B
	PUSH	B
	PUSH	D
	LHLD	@@LM
	PUSH	H
	PUSH	H
	POP	D
	DAD	B
	PUSH	H
	PUSH	H
	CALL	c@ugt
	POP	D
	JNZ	al@1
	LXI	H,-500
	DAD	SP
	CALL	c@uge
al@1:	POP	D
	POP	B
	LXI	H,-1
	RNZ
	XCHG
	SHLD	@@LM
	PUSH	B
	POP	H
	RET
@@LM:	DW	@@END

; Get a character from the console */
;      return getc(fin);       */
getcha:
	LHLD	fin
	PUSH	H
	CALL	getc
	POP	B
	RET
Ccnt:	DB	0
Cbuf:	DS	2
Cmode:	DB	1		; Set to 0 for raw console input */
@@RLIN: LDA	Ccnt	; Check if console buffer needs more chars */
	INR	A		; Returns with chars in buffer, */
	LHLD	Cbuf	; new count in A and Cbuf in HL */
	CMP	M		; Past last char? */
	RC		; No - return */
	RZ
	XCHG			; Yes - read another line */
	MVI	C,READC
	DCX	D
	CALL	bdose
	XRA	A
	STA	Ccnt
	MVI	E,LF
	CALL	@@RADD		 ; Add Line Feed */
	JMP	@@RLIN
CtlCk:	MVI	C,CONSTAT	; Check for console input (maybe ctrl-c) */
	CALL	bdose
	ORA	A
	RZ
	MVI	C,SCIN
	CALL	bdose		; Char waiting - read it */
	CPI	3		; Check ctrl-C */
	JZ	0		; and reboot if there */
	CPI	2		; Check ctrl-B */
	JZ	CtlB-1
	CPI	EOL
	JNZ	@@CC
	MVI	A,LF
@@CC:	MOV	E,A
@@RADD: LHLD	Cbuf	; Add character fm E to console line buffer */
	MOV	A,M
	DCX	H
	CMP	M
	RNC			; Return if no room */
	INX	H
	INR	M		; Inc count */
	MOV	C,M
	MVI	B,0
	DAD	B
	MOV	M,E		; Store char */
	MVI	A,LF
	CMP	E
	MVI	C,SCOUT
	CZ	bdose		; If CR, echo line feed */
	RET		; CHARACTER INPUT ROUTINE */
@@B8Z:	CALL	CtlB-1		; Enter here to process ^B and reread */
@@B8:	MVI	A,PUNIT 	; Enter here to read from console */
@@GCH:	LXI	H,IOprea	; Enter here for CHAR IN; A = unit */
	CALL	@@PU
	RC			; Return if error */
	PUSH	B		; Save sys fn */
	LDA	Cmode		; Check if line mode & console input(both 1)*/
	CMP	C
	JNZ	@@GC1		 ; If so, */
	CALL	@@RLIN		 ; read a char from console in line mode */
	STA	Ccnt
	MOV	E,A
	MVI	D,0
	DAD	D
	MOV	A,M
	JMP	@@GC2
@@GC1:	MVI	E,-1		; Otherwise, get char the regular way. */
	CALL	bdose		; (put FF in E in case it's fn 6) */
@@GC2:	POP	B
	CPI	EOL		; If char is CR */
	JNZ	@@B8P
	DCR	C		; If fn is SCIN = 1 */
	JNZ	@@B8M
	MVI	E,10		; echo LF */
	MVI	C,SCOUT
	CALL	bdose
@@B8M:	LXI	H,10		; Return LF. */
	RET
@@B8P:	DCR	C		; If fn is SCIN = 1, */
	JNZ	@@B8G
	CPI	2		; Check for ctl-b */
	JZ	@@B8Z
@@B8G:	CPI	EOF		; Ctl-z? */
	JZ	@@B9
	MOV	L,A		; Return the char (12/83) */
	MVI	H,0
	RET

@@B9:	DS 0
@@RM:	LXI	H,-1
	ret

; Write a character to the console */
;    return putc(c,fout);  */
putcha:
	POP	B
	POP	D
	PUSH	D
	PUSH	B
	LHLD	fout
	PUSH	D
	PUSH	H
	CALL	putc
	POP	B
	POP	B
	RET
@@B7:	XCHG
	MVI	A,PUNIT
@@PCH:	PUSH	H		; Char out; A = unit, HL = char */
	LXI	H,IOpwri
	CALL	@@PU
	POP	D		; Restore char */
	RC		; Return if error */
	PUSH	D
	XCHG
	MOV	A,L
	CPI	LF		; If outputting LF */
	JNZ	@@B7A
	MVI	E,EOL		; First put CR */
	PUSH	B		; Save scall number */
	CALL	bdose
	POP	B
	MVI	A,LF		; Get LF into A */
@@B7A:	MOV	E,A
	CALL	bdose
	POP	H
	RET

	; Check for physical unit - return carry if no good */
	; Call with IOprea or IOpwri in HL, log unit in A */
	; Return sys call in C, HL points to it in table. */
IOdev:	DB	'con:rdr:pun:lst:'
	DB	0

@@PU:	SUI	PUNIT		; Check channel in bounds */
	JC	@@PU1
	CPI	4
	JP	@@PU1
	MOV	E,A
	MVI	D,0
	DAD	D
	MOV	A,M
	MOV	C,A		; Get call number */
	ORA	A
	RNZ		; Check can do operation */
@@PU1:	STC			; error ret */
	JMP	@@RM

; io storage
IObuf:	dw	0,0,0,0,0,0,0	; Start of buffer for file */
IOsect: dw	0,0,0,0,0,0,0	; Current sector, for seek */
IOrw:	db	0,0,0,0,0,0,0	; # sectors read on last op on chan */
IOtmp:	dw	0		; Holds buffer start within routines */
IOch:	db -1,-1,-1,-1,-1,-1,-1 ; Channel for open files */
IOind:	dw	0,0,0,0,0,0,0	; Index of next character in current rec */
IOmode: db	0,0,0,0,0,0,0	; Mode in which opened */
IObin:	db	0,0,0,0,0,0,0	; Binary? */
IOseek: db	0,0,0,0,0,0,0	; If seek performed on file */

IOfcb:	dw	0,0,0,0,0,0,0	; FCB addresses for files.  In CP/M, */
				;  channel is index into this array. */
IOnch:	db	0,0,0,0,0,0,0	; Nr chars in buffer: 0 or 128 */
IOpcha: db	32,33,34,35	; Logical channels */
IOprea: db	1, 3, 0, 0	; System call for read */
IOpwri: db	2, 0, 4, 5	; System call for write */
IOpeof: db	0,EOF,EOF,12	; EOF char: FF for LST */


; Open file sname with indicated mode - "w", "r" or "u". */
   ; For CP/M, check if device is any of the logical hardware devices */
fopen:	POP	B
	POP	H
	POP	D		; Get name in D, table in H */
	PUSH	D
	PUSH	H
	PUSH	B
	LXI	H,IOdev
	MVI	C,32	; Loop count */
Z1@@:	PUSH	D
	PUSH	H
	MVI	B,4
Z2@@:	LDAX	D
	ORI	' '	; lower case */
	CMP	M
	JNZ	Z3@@
	INX	D
	INX	H
	DCR	B
	JNZ	Z2@@
	POP	D	; Match succeeds */
	POP	H
	MOV	L,C	; Return channel */
	MVI	H,0
	RET
Z3@@:	LXI	D,4	; Match fails - inc IOdev ptr */
	POP	H
	DAD	D
	POP	D
	INR	C
	MOV	A,M
	ORA	A
	JNZ	Z1@@	 ; Check next channel if not done */
   ;   i = 1;		       ; Find an available channel */
   ;   while (i <= NFILES)     */
   ;	  if (IOch[i] == -1) break;
   ;		else i++;	*/

	MVI	B,NFILES
	LXI	H,IOch+1
O1@@:	MOV	A,M
	CPI	-1
	JZ	O2@@
	INX	H
	DCR	B
	JNZ	O1@@

   ;   if (i>NFILES) return NULL;      */
	JMP	RN@@

   ;   scall = 34;	       ; Compute system call - .OPENR, W or U. */
   ;   if (*mode == 'w') scall = 35;
   ;	if (*mode == 'u') scall = 36;	*/

O2@@:	POP	B
	POP	D
	PUSH	D
	PUSH	B
	XCHG

   ;   IOmode[i] = *mode++;
   ;	IObin[i] = *mode;
   ;	IOseek[i] = IOrw[i] = 0;	   */

	MOV	A,M
	INX	H
	MOV	B,M
	XCHG
	LXI	D,IOrw-IOch
	DAD	D
	MVI	M,0
	LXI	D,IOseek-IOrw
	DAD	D
	MVI	M,0
	LXI	D,IObin-IOseek
	DAD	D
	MOV	M,B
	LXI	D,IOmode-IObin
	DAD	D
	MOV	M,A
IOguy	equ IOnch
	LXI	D,IOnch-IOmode	; CP/M - set chars in buffer to 0 (= 256) */
	DAD	D
	MVI	M,0
	STA	O6@@+1
	LXI	D,IOguy 	; Macro-80 can't relocate neg. addr. */
	XCHG
	CALL	s@1
	PUSH	H
	LXI	H,6
	DAD	SP
	CALL	h@
	POP	B
	PUSH	B
	MOV	A,C
	DCR	A
	PUSH	H			; Save file name */
	CALL	@CPC		; Get FCB from "channel" */
	POP	H
	JZ	RN@@			 ; Return if can't alloc */
	PUSH	D			; Save FCB */
	XCHG
	CALL	x?fcb		; Put name in it */
O6@@:	MVI	A,0		; Gets plugged with mode */
	MVI	C,OPENR
	CPI	'w'		; If not open for write, */
	JNZ	O6@@B		 ; just do OPEN. */
	POP	D
	PUSH	D
	MVI	C,DELETE	; Open for write - delete file */
	CALL	bdose
	MVI	C,MAKE		; Then make new one. */
O6@@B:	POP	D			; Restore FCB */
	CALL	bdose
	POP	D
	INR	A			; Check for error */
	JZ	RN@@

  ;    IOch[i] = i;	       ; Initialize index into buffer */

	LXI	H,IOch
	DAD	D
	MOV	M,E

  ;    IOind[i] = 256;	       ; to point to LWA + 1 */

	LXI	B,IOind-IOch
	DAD	B
	DAD	D
	XRA	A
	MOV	M,A
	INX	H
	MVI	M,1

  ;    IOsect[i] = 256;        ; Clear sector count */

	LXI	B,IOsect-IOind
	DAD	B
	MOV	M,A
	DCX	H
	MOV	M,A

  ; See if buffer already allocated */

	LXI	B,IObuf-IOsect
	DAD	B
	MOV	A,M
	INX	H
	ORA	M
	JNZ	O8@@

  ; No - allocate 256 bytes for it. */

	PUSH	D
	PUSH	H
	LXI	B,256
	PUSH	B
	CALL	sbrk
	POP	B
	XCHG
	POP	H
	MOV	M,D
	DCX	H
	MOV	M,E

  ; Return NULL if sbrk returned -1 */

	INX	D
	MOV	A,E
	ORA	D
	POP	D
	JZ	RN@@

  ;    return i;	       (Clear carry for internal call) */

O8@@:	XCHG
	XRA	A
	ret

unit:	dw	0

fclose: POP	B	
	POP	D
	PUSH	D
	PUSH	B
	MOV	A,E				; Check if physical unit */
	CPI	PUNIT
	JC	F@@1
	LXI	H,IOpwri			; Yes - check if can write */
	CALL	@@PU
	INX	H				; If not, just return */
	RC
	LXI	D,IOpeof-IOpwri-1		; Else write EOF */
	DAD	D
	MOV	E,M
	MOV	A,E
	ORA	A
	CNZ	bdose
	LXI	H,0
	RET			; and return */
F@@1:	LXI	H,IOch
	DAD	D
	MOV	A,M
	INR	A
	JZ	RN@@	 
	MVI	M,-1	;	 IOch[unit] = -1;	 ; Release channel. */
	CALL	TM@@			 ; Put buffer address in IOtmp */
	LXI	H,IOmode
;    if (IOmode[unit] <=> 'r') { ; If file being written, */
	DAD	D
	MOV	A,M
	CPI	'r'
	JZ	F2@@
	LXI	H,IObin 	;  and binary char*/
	DAD	D
	MOV	C,M
	LXI	H,IOind   ;   i = IOind[unit];	   */
	DAD	D
	DAD	D
	PUSH	D
	CALL	h@
	MOV	A,L	 ;	  if (i & 255) {	  */
	ORA	A
	JZ	F3@@
	XCHG
	PUSH	PSW	; CP/M - save whether >= 128 bytes */
	LHLD	IOtmp
	MOV	A,C	 ;	      if (IObin[unit] <=> 'b')		  */
	CPI	'b'
	JZ	F5@@
	DAD	D	 ;	      while (i & 255) IObuf[i++] = 0;	 */
	MVI	A,EOF		; Fill last record with ctrl-Z for CP/M */
F4@@:	MOV	M,A
	INX	H
	INR	E
	JNZ	F4@@
	DCR	H  ;	 write(unit,&IObuf[i-256],256); ; dump buffer */
F5@@:	POP	PSW		; CP/M - might want to write 128 */
	PUSH	H
	LXI	H,128
	DCR	A		; or 256 if index > 128 */
	JP	F5A@@
	DAD	H
F5A@@:	PUSH	H
??CL2	EQU	$+1
	CALL	write		; This location may be modified by seek */
	POP	B
	POP	B
F3@@:	POP	D

F2@@:	MOV	A,E
	DCR	A
	PUSH	D
	CALL	@CPC
	MVI	C,CLOSE
	CALL	bdose
	INR	A
	POP	H
	RNZ

  ;    return NULL;	       */

RN@@:	LXI	H,NULL
	STC
	RET

  ; Subroutine to put buffer address in IOtmp */
TM@@:	LXI	H,IObuf
	DAD	D
	DAD	D
	MOV	C,M
	INX	H
	MOV	B,M
	PUSH	B
	POP	H
	SHLD	IOtmp
	ret

getc:
@G3:	CALL	@GPC	
	ORA	A	; If unit 0 */
	JZ	@@B8	 ; Read from console */
	CPI	PUNIT	; Check if phys device */
	JNC	@@GCH
	XRA	A
	CMP	C
	DCX	H
	JNZ	@G1
	PUSH	H	 ;  IOind[unit] = IOind[unit] - 256; */
	PUSH	D	 ;  if (read(unit,&IObuf[IOind[unit]],256) == 0)  */
	LHLD	IOtmp
	PUSH	H
	LXI	H,256
	PUSH	H
	CALL	read
	POP	B
	POP	B
	POP	D
	PUSH	D
	XCHG	; Store amount read in IOnch[unit] */
	LXI	B,IOnch
	DAD	B
	MOV	M,E
	MOV	A,E
	ORA	D
	POP	D
	POP	H
	JZ	@@RM	    ;	     return -1; }    */

   ;	       c = 255 & IObuf[IOind[unit]++]; */
   ; (IOind+unit is still in (SP)). */

@G1:	PUSH	D
	PUSH	H
	CALL	h@
	INX	H
	CALL	q@
	DCX	H
	XCHG
	LHLD	IOtmp
	DAD	D
	MOV	B,M

   ;	       if (IObin[unit] == 'b') return c;       */

	LXI	H,IObin
	POP	D
	DAD	D
	MVI	A,'b'
	CMP	M
	JZ	@G2
	MOV	A,B
	CPI	EOL	; In CP/M, ignore CRs */
	JZ	@G3
	CPI	EOF	; and return EOF for ctrl-Z */
	JZ	@@RM

   ;	       if (c) return (c); }    ; Ignore nulls in ascii file */

	ORA	A
	JZ	@G3
@G2:	MOV	L,B
	MVI	H,0
	RET

; Subroutine for putc and getc to increment buffer pointers */
; Does: if ((IOind[unit]&255)==0) IOind[unit]=IOind[unit]-256; 
;  returns IOind[unit] in BC, address+1 in HL, and unit in DE and A.
;  Also sets up IOtmp to point to buffer. */

@GPC:	POP	H
	POP	B
	POP	D
	PUSH	D
	PUSH	B
	PUSH	H
	MOV	A,E	; Return if unit 0 */
	ORA	A
	RZ
	CPI	PUNIT	; Check if phys channel */
	RNC
	CALL	TM@@
	LXI	H,IOnch ; Get nr chars in buffer */
	DAD	D
	MOV	A,M
	LXI	H,IOind
	DAD	D
	DAD	D
	MOV	C,M
	INX	H
	MOV	B,M
	CMP	C
	MOV	A,E	; Leave unit in A */
	RNZ
	MVI	B,0
	MOV	M,B
	DCX	H	; On CP/M, C might be 00 or 80.  HDOS: only 00 */
	MOV	M,B
	MOV	C,B
	INX	H
	ret


  ;    if ((IOind[unit] & 255) == 0) IOind[unit] = IOind[unit] - 256;  */

putc:	CALL	@GPC
	ORA	A	; If to console */
	JNZ	PC@8
	POP	B
	POP	H
	POP	D	; Get character in D */
	PUSH	D
	PUSH	H
	PUSH	B
	JMP	@@B7	 ; Go output it */
PC@8:	DS	0
	CPI	PUNIT	; Check if phys device */
	JC	PC@9
	POP	B		; Get char in HL */
	POP	D
	POP	H
	PUSH	H
	PUSH	D
	PUSH	B
	JMP	@@PCH	 ; Go do it */
PC@9:	DCX	H
	PUSH	H

   ;   IObuf[IOind[unit]++] = c;       */

	LXI	H,6
	DAD	SP
	MOV	A,M
	CPI	LF		; LF on non-bin file? */
	JNZ	PC@1
	PUSH	H
	LXI	H,IObin
	DAD	D
	MOV	A,M
	CPI	'b'
	JZ	PC@3
	LXI	H,C@LFD  ; Yes - check flag to see if CR output already */
	DCR	M
	JNZ	PC@2
	MVI	A,EOL
	POP	H
	JMP	PC@1
C@LFD:	DB 1
PC@2:	MVI	M,1
PC@3:	POP	H
	MVI	A,LF
PC@1:	LHLD	IOtmp
	DAD	B
	MOV	M,A
	XTHL
	PUSH	H
	PUSH	H
	MOV	H,B
	MOV	L,C
	INX	H
	CALL	q@
	POP	H

   ;   if ((IOind[unit] & 255) == 0)   */

	XRA	A
	CMP	M
	POP	H
	JNZ	@PC1

   ;	       if (write(unit,&IObuf[IOind[unit]-256],256) <= 0) return -1; */

	POP	B
	POP	D
	PUSH	D
	PUSH	B
	PUSH	D
	DCR	H
	INR	L
	PUSH	H
	LXI	H,256
	PUSH	H
??PC2	EQU	$+1
	CALL	write		; This location may be modified by seek */
	POP	B
	POP	B
	POP	B
	MOV	A,H
	ORA	L
	LXI	H,-1
	RZ
	RM

   ;   return (c & 255);       */

@PC1:	LXI	H,4
	DAD	SP
	MOV	L,M
	MVI	H,0
	LDA	C@LFD
	ORA	A
	JZ	putc	; If output CR, follow with LF */
	ret

; Routines to write, read one block */

write:	XRA	A		; Remember whether write */
	STA	RD@RW
	MVI	A,writef
	JMP	RD@0
RD@T:	DS	1
@@RW@2: PUSH	H		; Increment sector count */
	LXI	H,8
	DAD	SP
	CALL	h@
	XCHG
	POP	H
	PUSH	H		; Retrieve sectors read/written */
	DAD	H		; (CP/M - Multiple of 128 bytes) */
	LDA	RD@RW
	ANA	H		; R/W flag is number of sectors read */
	PUSH	PSW		; Save it on stack */
	MOV	A,H
	LXI	H,IOsect
	DAD	D
	DAD	D
	ADD	M		; Add to sector count */
	MOV	M,A
	JNC	@PC5
	INX	H		; And carry if necessary */
	INR	M
@PC5:	LXI	H,IOrw		; Store R/W flag */
	DAD	D
	POP	PSW		; Get nr sectors read back */
	MOV	M,A
	POP	H
	ret


read:	MVI	A,-1
	STA	RD@RW
	MVI	A,readf
RD@0:	STA	RD@T
	LDA	Cmode	; If not in raw mode, give ^c a shot */
	ORA	A
	CNZ	CtlCk
	CALL	@@RW@
	PUSH	B		; Save original count */
RD@1:	MOV	A,B		; Done reading? */
	ORA	C
	JZ	RD@4		; Yes - quit */
	PUSH	D		; Save FCB */
	PUSH	H		; Save address */
	PUSH	B		; Save remaining count */
	PUSH	D		; Save FCB */
	XCHG
	MVI	C,SETDMA
	CALL	bdose
	POP	D		; Get FCB */
	LDA	RD@T	; Get read/write code */
	MOV	C,A
	CALL	bdose
	POP	B		; Get count */
	ORA	A		; If EOF */
	JNZ	RD@2		; Quit */
	LXI	H,-128
	DAD	B
	MOV	B,H
	MOV	C,L
	POP	H		; Bump address */
	LXI	D,128
	DAD	D
	POP	D		; Get FCB back */
	JMP	RD@1
RD@2:	POP	H		; Error - Pop adr, FCB off stack */
	POP	D		; saving adr in H */
	LDA	RD@T	; Check read or write */
	CPI	writef
	JNZ	RD@4		; If read, EOF. Just return count */
	POP	H
	LXI	D,RD@M		; Write - it's an error. */
	MVI	C,PRINT 	; Print message */
	CALL	bdose
	LXI	H,-1		; Return -1 */
	JMP	RD@3
RD@M:	DB	'Write error - Disk full'
	DB	0AH,0DH,'$'
RD@4:	POP	D		; Restore orig. count */
	MOV	H,B
	MOV	L,C
	CALL	s@1		; Return amount read */
RD@3:	PUSH	H
	MVI	C,SETDMA	; Restore DMA address */
	LXI	D,defbuf	; (because CDOS uses it) */
	CALL	bdose
	POP	H
	JMP	@@RW@2		 ; Return */
RD@RW:	DS	1

; Subroutine to set up channel and transfer addresses.
;	CALL	with stack = [ret.ad; ret.ad; xfer count; buffer adr; channel].
;	RETurns with addresses set up for read/write call.
;  CP/M: BC=count, DE=FCB, HL=address. */

@@RW@:	LXI	H,8
	DAD	SP
	MOV	A,M
	DCR	A
	DCX	H
	PUSH	H		; Save address */
	CALL	@CPC		; Get FCB in DE */
	POP	H
	PUSH	D		; Save it */
	MOV	D,M
	DCX	H
	MOV	E,M
	DCX	H
	MOV	B,M
	DCX	H
	MOV	C,M
	POP	H		; Restore FCB */
	XCHG
	RET

; CP/M name->FCB routine.  Call with file name address in DE, FCB IN HL. */

x0fcb:	;another name, callable from "C" programs
x?fcb:	LXI	B,11	; Erase the name area with blanks. */
	DAD	B
	SHLD	@XTMP	; Save FCB+11 */
	MVI	A,' '
nam@1:	MOV	M,A
	DCX	H
	DCR	C
	JNZ	nam@1
	XRA	A		
	MOV	M,A	; Erase drive number */
	LXI	B,12
	DAD	B
	MOV	M,A	; Erase EX, S2 and CR */
	INX	H
	INX	H
	MOV	M,A
	LXI	B,18
	DAD	B
	MOV	M,A
	LXI	B,-32	; Get start of FCB */
	DAD	B
	XCHG
	INX	H
	MOV	A,M	; IS : IN NAME */
	DCX	H
	CPI	':'
	JNZ	nam@2
	MOV	A,M	; YES - GET DRIVE. */
	INX	H
	INX	H		; STEP PAST DRIVE: */
	CALL	NAM@U
	SUI	'A'-1
	STAX	D
nam@2:	INX	D		; GET NAME*/
	MOV	A,M
	INX	H
	ORA	A		; DONE? */
	RZ	; YES - RETURN. */
	CPI	'.'	 ; START TYPE? */
	JZ	nam@3
	CALL	NAM@U	; NO. STORE CHAR. */
	STAX	D
	JMP	nam@2
nam@3:	XCHG		; START TYPE */
	LHLD	@XTMP
	DCX	H		; Restore FCB+11 */
	DCX	H
nam@4:	LDAX	D
	ORA	A		; DONE? */
	RZ	; RETURN. */
	CALL	NAM@U
	MOV	M,A
	INX	D
	INX	H
	JMP	nam@4
@XTMP:	DS 2
NAM@U:	ANI	177Q	; CAPITALIZE (A). */
	CPI	'a'
	RM
	SUI	'a'-'A'
	RET
@CPC:	MOV	C,A	; Get FCB location in DE from channel number in A. */
	MVI	B,0	; Return zero flag if error. */
	LXI	H,IOfcb
	DAD	B
	DAD	B
	MOV	A,M	; Allocated yet? */
	MOV	E,A
	INX	H
	MOV	D,M
	ORA	D
	RNZ		; Yes - return */
	PUSH	H		; No - allocate it */
	LXI	H,FCBLEN
	PUSH	H
	CALL	sbrk
	XCHG
	POP	H
	POP	H
	MOV	M,D	; Store block address */
	DCX	H
	MOV	M,E
	MOV	H,D
	MOV	L,E	; Get value to return */
	INX	H	; Set Z flag if can't alloc */
	MOV	A,H
	ORA	L
	RET

@@END:	DS	0	; End of library (code segment) */

	dseg
Q8QEND: db	0	; End of library (data segment) */

	END	@@INIT
