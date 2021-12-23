; RomWBW Boot Info Sector
; This resides in the third (512B) sector, which overlays
; part of the MMS magic sector, but there is no conflict
; since no boot code is required/possible there.
; This replaces the first two boot stages, so we lose
; the ability to boot from other partitions.

	extrn cboot,btend,loader

	aseg
	org	2000H	; a convenient place in the file
; Cloned from RomWBW/Source/HBIOS/romldr.asm:
; (this is only the last 128 bytes of the block)
	db	05ah,0a5h	; signature (0xA55A if set)
	ds	1		; formatting platform
	ds	1		; formatting device
	ds	8		; formatting program
	ds	1		; physical disk drive # (OBS)
	ds	1		; logical unit (lu) (OBS)
	ds	1		; msb of lu, now deprecated (OBS)
	ds	81
	ds	1		; write protect boolean
	ds	2		; update counter
	ds	1		; rmj major version number
	ds	1		; rmn minor version number
	ds	1		; rup update number
	ds	1		; rtp patch level
	db	'MP/M-CP/NET     '	; 16 character drive label
	db	'$'		; label terminator ('$')
	ds	2		; loc to patch boot drive info
	dw	loader		; final ram dest for cpm/cbios
	dw	btend		; end address for load
	dw	cboot		; CP/M entry point (cbios boot)

	end
