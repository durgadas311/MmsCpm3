;***************************************************
;*                                                 *
;* sample random access program for cp/m 3         *
;*                                                 *
;***************************************************
        org     100h    ;base of tpa
;
reboot  equ     0000h   ;system reboot
bdos    equ     0005h   ;bdos entry point
;
coninp  equ     1       ;console input function
conout  equ     2       ;console output function
pstring equ     9       ;print string until '$'
rstring equ     10      ;read console buffer
version equ     12      ;return version number
openf   equ     15      ;file open function
closef  equ     16      ;close function
makef   equ     22      ;make file function
readr   equ     33      ;read random
writer  equ     34      ;write random
wrtrzf	equ	40	;write random zero fill
parsef  equ     152	;parse function
;
fcb     equ     005ch   ;default file control block
ranrec  equ     fcb+33  ;random record position
ranovf  equ     fcb+35  ;high order (overflow) byte
buff    equ     0080h   ;buffer address
;
cr      equ     0dh     ;carriage return
lf      equ     0ah     ;line feed
;
;***************************************************
;*                                                 *
;* load SP, set-up file for random access          *
;*                                                 *
;***************************************************
        lxi     sp,stack
;
;       version 3.1?
        mvi     c,version
        call    bdos
        cpi     31h     ;version 3.1 or better?
        jnc     versok
;       bad version, message and go back
        lxi     d,badver
        call    print
        jmp     reboot
;
versok:
;       correct version for random access
        mvi     c,openf ;open default fcb
rdname: lda     fcb+1
	cpi	' '
	jnz	opfile
	lxi	d,entmsg
	call 	print
	call 	parse
	jmp	versok
opfile:	lxi	d,fcb
	call    bdos
        inr     a       ;err 255 becomes zero
        jnz     ready
;
;       cannot open file, so create it
        mvi     c,makef
        lxi     d,fcb
        call    bdos
        inr     a       ;err 255 becomes zero
        jnz     ready
;
;       cannot create file, directory full
        lxi     d,nospace
        call    print
        jmp     reboot  ;back to ccp
;
;***************************************************
;*                                                 *
;*  loop back to "ready" after each command        *
;*                                                 *
;***************************************************
;
ready:
;       file is ready for processing
;
        call    readcom ;read next command
        shld    ranrec  ;store input record#
        lxi     h,ranovf
        mov     m,c     ;set ranrec high byte
        cpi     'Q'     ;quit?
        jnz     notq
;
;       quit processing, close file
        mvi     c,closef
        lxi     d,fcb
        call    bdos
        inr     a       ;err 255 becomes 0
        jz      error   ;error message, retry
        jmp     reboot  ;back to ccp
;
;***************************************************
;*                                                 *
;* end of quit command, process write              *
;*                                                 *
;***************************************************
notq:
;       not the quit command, random write?
        cpi     'W'
        jnz     notw
;
;       this is a random write, fill buffer until cr
        lxi     d,datmsg
        call    print   ;data prompt
        mvi     c,127   ;up to 127 characters
        lxi     h,buff  ;destination
rloop:  ;read next character to buff
        push    b       ;save counter
        push    h       ;next destination
        call    getchr  ;character to a
        pop     h       ;restore counter
        pop     b       ;restore next to fill
        cpi     cr      ;end of line?
        jz      erloop
;       not end, store character
        mov     m,a
        inx     h       ;next to fill
        dcr     c       ;counter goes down
        jnz     rloop   ;end of buffer?
erloop:
;       end of read loop, store 00
        mvi     m,0
;
;       write the record to selected record number
        mvi     c,writer
        lxi     d,fcb
        call    bdos
        ora     a       ;error code zero?
        jnz     error   ;message if not
        jmp     ready   ;for another record
;
;
;********************************************************
;*                                                      *
;* end of write command, process write random zero fill *
;*                                                      *
;********************************************************
notw:
;       not the quit command, random write zero fill?
        cpi     'F'
        jnz     notf
;
;       this is a random write, fill buffer until cr
        lxi     d,datmsg
        call    print   ;data prompt
        mvi     c,127   ;up to 127 characters
        lxi     h,buff  ;destination
rloop1: ;read next character to buff
        push    b       ;save counter
        push    h       ;next destination
        call    getchr  ;character to a
        pop     h       ;restore counter
        pop     b       ;restore next to fill
        cpi     cr      ;end of line?
        jz      erloop1
;       not end, store character
        mov     m,a
        inx     h       ;next to fill
        dcr     c       ;counter goes down
        jnz     rloop1  ;end of buffer?
erloop1:
;       end of read loop, store 00
        mvi     m,0
;
;       write the record to selected record number
        mvi     c,wrtrzf
        lxi     d,fcb
        call    bdos
        ora     a       ;error code zero?
        jnz     error   ;message if not
        jmp     ready   ;for another record
;
;***************************************************
;*                                                 *
;* end of write commands, process read             *
;*                                                 *
;***************************************************
notf:
;       not a write command, read record?
        cpi     'R'
        jnz     error   ;skip if not
;
;       read random record
        mvi     c,readr
        lxi     d,fcb
        call    bdos
        ora     a       ;return code 00?
        jnz     error
;
;       read was successful, write to console
        call    crlf    ;new line
        mvi     c,128   ;max 128 characters
        lxi     h,buff  ;next to get
wloop:
        mov     a,m     ;next character
        inx     h       ;next to get
        ani     7fh     ;mask parity
        jz      ready   ;for another command if 00
        push    b       ;save counter
        push    h       ;save next to get
        cpi     ' '     ;graphic?
        cnc     putchr  ;skip output if not
        pop     h
        pop     b
        dcr     c       ;count=count-1
        jnz     wloop
        jmp     ready
;
;***************************************************
;*                                                 *
;* end of read command, all errors end-up here     *
;*                                                 *
;***************************************************
;
error:
        lxi     d,errmsg
        call    print
        jmp     ready
;
;***************************************************
;*                                                 *
;* utility subroutines for console i/o             *
;*                                                 *
;***************************************************
getchr:
        ;read next console character to a
        mvi     c,coninp
        call    bdos
        ret
;
putchr:
        ;write character from a to console
        mvi     c,conout
        mov     e,a     ;character to send
        call    bdos    ;send character
        ret
;
crlf:
        ;send carriage return line feed
        mvi     a,cr    ;carriage return
        call    putchr
        mvi     a,lf    ;line feed
        call    putchr
        ret
;
parse:
	;read and parse filespec
	lxi	d,conbuf
	mvi	c,rstring
	call 	bdos
	lxi	d,pfncb
	mvi	c,parsef
	call 	bdos
	ret
;
print:
        ;print the buffer addressed by de until $
        push    d
        call    crlf
        pop     d       ;new line
        mvi     c,pstring
        call    bdos    ;print the string
        ret
;
readcom:
        ;read the next command line to the conbuf
        lxi     d,prompt
        call    print   ;command?
        mvi     c,rstring
        lxi     d,conbuf
        call    bdos    ;read command line
;       command line is present, scan it
	mvi	c,0	;start with 00
        lxi     h,0     ;           0000
        lxi     d,conlin;command line
readc:  ldax    d       ;next command character
        inx     d       ;to next command position
        ora     a       ;cannot be end of command
        rz
;       not zero, numeric?
        sui     '0'
        cpi     10      ;carry if numeric
        jnc     endrd
;       add-in next digit
	push 	psw
	mov	a,c	;value = ahl
	dad	h
	adc	a	;*2
	push	a	;save value * 2
	push	h
        dad     h       ;*4
	adc	a
	dad	h	;*8
	adc	a
	pop	b	;*2 + *8 = *10
	dad	b
	pop	b
	adc	b
	pop	b  	;+digit
	mov	c,b
	mvi	b,0
	dad	b
	aci	0
	mov	c,a
	jnc	readc
        jmp     readcom
endrd:
;       end of read, restore value in a
        adi     '0'     ;command
        cpi     'a'     ;translate case?
        rc
;       lower case, mask lower case bits
        ani     101$1111b
        ret		;return with value in chl
;
;***************************************************
;*                                                 *
;* string data area for console messages           *
;*                                                 *
;***************************************************
badver:
        db      'sorry, you need cp/m version 3$'
nospace:
        db      'no directory space$'
datmsg:
        db      'type data: $'
errmsg:
        db      'error, try again.$'
prompt:
        db      'next command? $'
entmsg:
	db	'enter filename: $' 
;
;***************************************************
;*                                                 *
;* fixed and variable data area                    *
;*                                                 *
;***************************************************
conbuf: db      conlen  ;length of console buffer
consiz: ds      1       ;resulting size after read
conlin: ds      32      ;length 32 buffer
conlen  equ     $-consiz
;
pfncb:
	dw	conlin
	dw	fcb
;
        ds      32      ;16 level stack
stack:
        end
