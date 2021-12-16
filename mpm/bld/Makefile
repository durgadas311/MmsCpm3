# MP/M for H89 with Z180 CPU
# Assumes PWD = CPMDrive_D
SHELL = /bin/bash

export CPMDrive_D = $(PWD)
export CPMDefault = d:

SRCS = $(wildcard *.asm)
RELS = $(subst .asm,.rel,$(SRCS))

BASE = mxios.rel cio8250.rel end.rel lptbl.rel

Z67DRVS = -d a:=50,b:=51,c:=52,d:=53,e:=54,f:=55,g:=56,h:=57
SDCDRVS = -d a:=80,b:=81,c:=82,d:=83,e:=84,f:=85,g:=86,h:=87
DSO = -p def,a:

all: m3sdczrr.sys mldrsdc.img

%.rel: %.asm
	vcpm rmac "$?" '$$SZ'

cio8250.rel: cio8250.asm cfgmpm.lib
	vcpm rmac "$<" '$$SZ'

mxios.rel: mxios.asm cfgmpm.lib
	vcpm rmac "$<" '$$SZ'

# Targets that setup configuration file.
# One of these must be done before each mpm.sys build.
# h8v4 h8z180
%:	cfg%.lib
	cp $< cfgmpm.lib

# MPMLDR bootstrap image (1st stage at 2280H)
# (bootstrap at 2280H is written to first sector(s) on boot track,
#  then 0100H-... is written to following sectors of boot tracks)
mldr%.img: ldr%.rel ldrb%.rel mldrprog.rel ldrbdos.rel ldrbios.rel
	vcpm link "$@=mldrprog,ldrbdos,ldrbios,ldr$*,ldrb$*[oc,nr]"

# MPMLDR.COM, runnable from CP/M
# This still doesn't work... use of "org 0100h" in mldrprog ruins it.
#mldr%.com: ldrentry.rel ldr%.rel mldrprog.rel ldrbdos.rel ldrbios.rel
#	vcpm link "$@=ldrentry,mldrprog,ldrbdos,ldrbios,ldr$*[oc,nr,l0100,p0]"

m3z67zrr.spr: $(BASE) z67.rel rtc72421.rel mem512k.rel
	vcpm link "m3z67zrr=mxios,cio8250,z67,end,lptbl,mem512k,rtc72421[b,os,nr]"
	setup30 $(Z67DRVS) $(DSO) $@

m3sdczrr.spr: $(BASE) sdc.rel rtc72421.rel memz180.rel
	vcpm link "m3sdczrr=mxios,cio8250,sdc,end,lptbl,memz180,rtc72421[b,os,nr]"
	setup30 $(SDCDRVS) $(DSO) $@

# assumes CP/NET RSP(s) present
m3sdcnet.sys: m3sdczrr.spr netservr.rsp netservr.brs
	cp $< bnkxios.spr
	cp gm.cpnet.dat system.dat
	vcpm gensys '$$ar'
	mv mpm.sys $@
	mv system.dat m3sdcnet.dat

# assumes CP/NET RSP(s) removed (no check)
m3%.sys: m3%.spr gm.mpmii.dat
	cp $< bnkxios.spr
	cp gm.mpmii.dat system.dat
	vcpm gensys '$$ar'
	mv mpm.sys $@
	mv system.dat $*.dat

.PRECIOUS: %.rel

syncdown:
	unix2cpm -q -s ~/git/MmsCpm3/mpm/src/*.asm .
	unix2cpm -q -s ~/git/MmsCpm3/sys/src/{ldr*.asm,z*80.lib} .
	unix2cpm -q -s ~/git/MmsCpm3/mpm/src/cfg*.lib .

syncup:
	rsync -Wurv --existing . ~/git/MmsCpm3/mpm/bin/.
	rsync -Wurv --existing . ~/git/MmsCpm3/mpm/prn/.

__FRC__:
