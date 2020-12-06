;	MDS-800 Cold Start Loader for MP/M 2.0
;
;	VERSION 2.0    09/1481   
;
mpmldrb	equ	0100h	;base of MP/M loader
;
	org	3000h	;loaded here by hardware
;
ntrks	equ	2	;tracks to read
mpmldr0	equ	25	;# on track 0
mpmldr1	equ	26	;# on track 1
;
rmon80	equ	0ff0fh	;restart location for mon80
base	equ	078h	;'base' used by controller
rtype	equ	base+1	;result type
rbyte	equ	base+3	;result byte
reset	equ	base+7	;reset controller
;
dstat	equ	base	;disk status port
ilow	equ	base+1	;low iopb address
ihigh	equ	base+2	;high iopb address
bsw	equ	0ffh	;boot switch
readf	equ	4h	;disk read function
stack	equ	100h	;use end of boot for stack
;
rstart:
	lxi	sp,stack;in case of call to mon80
;	clear disk status
	in	rtype
	in	rbyte
;	check if boot switch is off
coldstart:
	in	bsw
	ani	02h	;switch on?
	jnz	coldstart
;	clear the controller
	out	reset	;logic cleared
;
;
	mvi	b,ntrks	;number of tracks to read
	lxi	h,iopb0
;
start:
;
;	read first/next track into cpmb
	mov	a,l
	out	ilow
	mov	a,h
	out	ihigh
wait0:	in	dstat
	ani	4
	jz	wait0
;
;	check disk status
	in	rtype
	ani	11b
	cpi	2
;
	jnc	rstart	;retry the load
;
	in	rbyte	;i/o complete, check status
;	if not ready, then go to mon80
	ral
	cc	rmon80	;not ready bit set
	rar		;restore
	ani	11110b	;overrun/addr err/seek/crc/xxxx
;
	jnz	rstart	;retry the load
;
;
	lxi	d,iopbl	;length of iopb
	dad	d	;addressing next iopb
	dcr	b	;count down tracks
	jnz	start
;
;
;	jmp to the MP/M loader
	jmp	mpmldrb
;
;	parameter blocks
iopb0:	db	80h	;iocw, no update
	db	readf	;read function
	db	mpmldr0	;# sectors to read trk 0
	db	0	;track 0
	db	2	;start with sector 2, trk 0
	dw	mpmldrb	;start at base of bdos
iopbl	equ	$-iopb0
;
iopb1:	db	80h
	db	readf
	db	mpmldr1	;sectors to read on track 1
	db	1	;track 1
	db	1	;sector 1
	dw	mpmldrb+mpmldr0*128 ;base of second read
	end
