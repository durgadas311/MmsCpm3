; From H8 bring-up manual, initial "test" program
; that displays "your H8 is up and running |---| |---| |---|"
; on the front panel (marqui paging style).

	maclib	ram
	maclib	core
	maclib	z80

CR	equ	13
LF	equ	10
CTLC	equ	3

FPDSPW	equ	9	; LED display has 9 "characters"

	org	1000h
first:	db	HIGH (last-first)	; +0: num pages
	db	HIGH first		; +1: ORG page
	db	255,0	; +2,+3: phy drv base, num

	jmp	init	; +4: init entry
	jmp	exec	; +7: action entry

	db	'f'	; +10: Command letter
	db	-1	; +11: front panel key
	db	0	; +12: port, 0 if variable
	db	11111111b,11111111b,11111111b	; +13: FP display
	db	'Test',0	; +16: mnemonic string

init:
	xra	a	; NC
	ret

exec:
	lda	MFlag
	mvi	a,00000010b	; auto disp update OFF
	sta	MFlag
	lxi	h,signon
	call	msgout
	;
show:	mvi	b,nmsg
	lxi	h,message
	; copy a "line" to FP display, from HL
nxtlin:	lxi	d,fpLeds
	mvi	c,FPDSPW
msgcpy:	mov	a,m
	stax	d
	inx	h
	inx	d
	dcr	c
	jrnz	msgcpy
	; We can't abort delay with Ctrl-C, so must check after
	mvi	c,3	; 3*512mS = 1.536 secs
pause:	mvi	a,255	; 512mS
	call	delay
	call	check	; jumps directly to abort...
	dcr	c
	jrnz	pause
	dcr	b
	jrnz	nxtlin
	; double "beep" the horn
	mvi	a,50	; 100mS
	call	hhorn
	mvi	a,50	; 100mS
	call	delay
	mvi	a,50	; 100mS
	call	hhorn
	call	check	; jumps directly to abort...
	jmp	show

check:	in	0edh
	rrc
	rnc
	in	0e8h
	cpi	CTLC
	rnz
	pop	h	; discard local return adr
abort:	call	crlf
	lda	MFlag
	ani	11111101b	; re-enable disp update
	sta	MFlag
	ret

signon:	db	' FP display test',CR,LF
	db	'Ctl-C to quit ',0

message:	; each "entry" is 9 bytes (display width)
	; " your H8 "
	db	11111111b,10110010b,10111000b,10111010b,10111101b,11111111b
	db	10010010b,10000000b,11111111b
	; "is up and"
	db	10011111b,10100100b,11111111b,10111010b,10011000b,11111111b
	db	10010000b,11010110b,11000010b
	; " running "
	db	11111111b,10111101b,10111010b,10111001b,10111001b,11111011b
	db	10111001b,10100000b,11111111b
	; "|---||---||---|"
	db	10011110b,11111110b,11110010b,10011110b,11111110b,11110010b
	db	10011110b,11111110b,11110010b
nmsg	equ	($-message)/FPDSPW

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm
if ($ > 1800h)
	.error	'Module overflow'
endif

last:	end
