; This program de-activates XSUB without cold boot.
; disassembled from HEX of unknown origin.
; Rumored to have been supplied by DRI
;
; This works because the standard 2.2 BDOS function 0 SYSTEM RESET
; directly jumps to the BIOS+3 warm boot entry, bypassing the jump at
; location 0000h which was modified by XSUB.

CR	equ	13
LF	equ	10

bdos	equ	5

reset	equ	0
fprint	equ	9

	org	0100h

	mvi	c,fprint
	lxi	d,deact
	call	bdos
	mvi	c,reset
	jmp	bdos

deact:	db	CR,LF,'(XSUB DEACTIVATED; ^P TURNED OFF IF ON)$'

	end
