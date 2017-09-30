vers equ '1 ' ; Sep 25, 2017  17:06   drm "NORTC.ASM"
;****************************************************************
; RTC (Time) BIOS module for CP/M 3 (CP/M plus),		*
; Copyright (c) 2017 Douglas Miller <durgadas311@gmail.com>	*
;****************************************************************
	maclib Z80

true	equ -1
false	equ not true

cr	equ 13
lf	equ 10
bell	equ 7

	extrn @cbnk
	extrn ?bnksl

	public ?time,?itime

	cseg	; common memory, available no matter which bank

; C=0 GET TIME (BDOS is about to read SCB), else SET TIME (BDOS just updated SCB)
; Typically, only C1=0 (SET) is used, to update the RTC chip.
; Cold Boot will call ?itime to force read of RTC chip.
; Must preserve HL, DE. Must be called with intrs enabled.
; Cannot depend on Bank 0 on entry...
?time:
;	mov	a,c
;	ora	a
;	rz
;	lda	@cbnk
;	sta	????
;	di
;	xra	a
;	call	?bnksl
;	sspd	savsp
;	lxi	sp,stack
;	ei
;	call	settim
;	di
;	lda	????
;	call	?bnksl
;	lspd	savsp
;	ei
	ret	; No RTC device in this implementation

	dseg	; this part can be banked

;stack:	ds	0
;savsp:	dw	0

; Same semantics as ?time, except Bank 0 must be active.
?itime:
	ret	; No RTC device in this implementation

	end
