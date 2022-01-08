	title	'MP/M II V2.0 Version & Revision Date'
	name	'ver'
	cseg
@ver:
	public	@ver
;
;  MP/M II V2.0   Version
;

;/*
;  Copyright (C) 1979,1980,1981
;  Digital Research
;  P.O. Box 579
;  Pacific Grove, CA 93950
;
;  Revised:
;    14 Sept 81 by Thomas Rolander
;*/

;
	extrn	mpm
startmpm:
	jmp	mpm

	extrn	pdisp
	jmp	pdisp

	extrn	xbdos
	jmp	xbdos

remfl:
	public	remfl
	jmp	$-$

	public	sysdat
sysdat:
	dw	$-$

;  declare Proc$Address$Table (20) address initial (
;    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
	public	ProcAddressTable
ProcAddressTable:
	dw	0,0,0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0,0,0

copyright:
	db	'COPYRIGHT (C) 1981,'
	db	' DIGITAL RESEARCH '

serial:
	db	'654321'

	public	mpmver
mpmver:
	dw	0120h

	public	ver
ver:
	db	0dh,0ah,0ah
	db	'MP/M II '
	db	'V2.0'
	db	0dh,0ah
	db	'Copyright (C) 1981, Digital Research'
	db	0dh,0ah
	db	'$'
	db	'09/14/81'

	end	startmpm
