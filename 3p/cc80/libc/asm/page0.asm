; May 10, 1984	07:57  drm  "PAGE0.ASM"
; page 0 definitions for use in lang routine libraries

	public bdose,wboote,defdsk,deffcb,defbuf
; NOTE: if a .PRL file is generated, these "externals" will have
; their relocation bit set so that they will reference "page 0"
; that is directly before the TPA, where ever that may be.
;
; NOTE: use "wboote" for program termination and access to char I/O
; vectors, use absolute 0 for access to BIOS for configuration info.
;
wboote	equ	0000h
bdose	equ	wboote+5
defdsk	equ	wboote+4
deffcb	equ	wboote+5ch
defbuf	equ	wboote+80h

	end
