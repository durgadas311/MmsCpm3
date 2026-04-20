;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This program is intended to be executed from a submit file to de-activate  ;
; xsub and allow input from the console.  It has a side effect of turning off;
; the ^P toggle if it is on.                                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	org	100h		;stay above page 0
bdos	equ	0005h		;bdos location in base page
	mvi	c,9		;print string = function 9
	lxi	d,msg		;
	call	bdos		;
	mvi	c,0		;system reset = function 0
	jmp	bdos		;exit bdos to ccp
msg	db	0dh,0ah,'(xsub deactivated; ^P turned off if on)$'
	end
