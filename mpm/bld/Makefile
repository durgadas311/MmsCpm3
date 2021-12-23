# MP/M for H89

# Where to find CP/NET Server build
HBA = h8xspi
CPNET = ~/cpnet-bld-test/w5500/$(HBA)/bin/mpmnet

SHELL = /bin/bash
ZMAC = zmac

export CPMDrive_D = $(PWD)
export CPMDefault = d:

SRCS = $(wildcard *.asm)
RELS = $(subst .asm,.rel,$(SRCS))

BASE = mxios.rel cio8250.rel end.rel lptbl.rel
RCBASE = mxios.rel cioz180.rel end.rel lptbl.rel

Z67DRVS = -d a:=50,b:=51,c:=52,d:=53,e:=54,f:=55,g:=56,h:=57
SDCDRVS = -d a:=80,b:=81,c:=82,d:=83,e:=84,f:=85,g:=86,h:=87
DSO = -p def,a:

all: m3sdczrr.sys mldrsdc.img

%.rel: %.asm cfgsys.lib
	vcpm rmac "$<" '$$SZ'

# Targets that setup configuration file.
# One of these must be done before each mpm.sys build.
# h8v4 h8z180
%:	cfg%.lib
	cp $< cfgsys.lib

# MPMLDR bootstrap image (1st stage at 2280H)
# (bootstrap at 2280H is written to first sector(s) on boot track,
#  then 0100H-... is written to following sectors of boot tracks)
mldr%.img: ldr%.rel ldrb%.rel mldrprog.rel ldrbdos.rel ldrbios.rel
	vcpm link "$@=mldrprog,ldrbdos,ldrbios,ldr$*,ldrb$*[oc,nr]"

# RomWBW/RC2014 boot images - must recompile SDC module for MT011!
mldrwbw.img: ldrsdc.rel bl_info.rel mldrprog.rel ldrbdos.rel ldrrc14.rel
	vcpm link "$@=mldrprog,ldrbdos,ldrrc14,ldrsdc,bl_info[oc,nr]"

bwbwbot.cim: bwbwbot.asm
	$(ZMAC) --dri -i -8 -c -s -n --od . --oo cim,lst $<

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

m3rcz180.spr: $(RCBASE) sdc.rel nortc.rel memz180.rel
	vcpm link "m3rcz180=mxios,cioz180,sdc,end,lptbl,memz180,nortc[b,os,nr]"
	setup30 $(SDCDRVS) $(DSO) $@

# SDCard MP/M+CP/NET - assumes CP/NET RSP(s) present
m3sdcnet.sys: m3sdczrr.spr netservr.rsp netservr.brs
	cp $< bnkxios.spr
	cp gm.cpnet.dat system.dat
	vcpm gensys '$$ar' | tee m3sdcnet.out
	mv mpm.sys $@
	mv system.dat m3sdcnet.dat

# Z67-IDE MP/M+CP/NET - assumes CP/NET RSP(s) present
m3z67net.sys: m3z67zrr.spr netservr.rsp netservr.brs
	cp $< bnkxios.spr
	cp gm.cpnet.dat system.dat
	vcpm gensys '$$ar' | tee m3z67net.out
	mv mpm.sys $@
	mv system.dat m3z67net.dat

# RC2014/MT011 MP/M+CP/NET - assumes CP/NET RSP(s) present
m3rcznet.sys: m3rcz180.spr netservr.rsp netservr.brs
	cp $< bnkxios.spr
	cp gm.cpnet.dat system.dat
	vcpm gensys '$$ar' | tee m3rcznet.out
	mv mpm.sys $@
	mv system.dat m3rcznet.dat

netservr.rsp netservr.brs:
	cp $(CPNET)/$@ .

unnet:
	rm -f netservr.rsp netservr.brs

# removes CP/NET RSP(s)
m3%.sys: m3%.spr gm.mpmii.dat
	rm -f netservr.*
	cp $< bnkxios.spr
	cp gm.mpmii.dat system.dat
	vcpm gensys '$$ar' | tee m3$*.out
	mv mpm.sys $@
	mv system.dat m3$*.dat

.PRECIOUS: %.rel

syncdown:
	unix2cpm -q -s ~/git/MmsCpm3/mpm/src/*.asm .
	unix2cpm -q -s ~/git/MmsCpm3/sys/src/{ldr*.asm,z*80.lib} .
	unix2cpm -q -s ~/git/MmsCpm3/mpm/src/cfg*.lib .

syncup:
	rsync -Wurv --existing . ~/git/MmsCpm3/mpm/bin/.
	rsync -Wurv --existing . ~/git/MmsCpm3/mpm/prn/.

__FRC__:
