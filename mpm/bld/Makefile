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
CFDRVS = -d a:=70,b:=71,c:=72,d:=73,e:=74,f:=75,g:=76,h:=77

# Override on make command (e.g. make ... DEF_H8=h8)
DEF_H8 = h8v4

all: m3sdczrr.sys mldrsdc.img

nc89: m3z67kd m3cfkd m3sdckd

%.rel: %.asm cfgsys.lib
	vcpm rmac "$<" '$$SZ'

# Targets that setup configuration file.
# One of these must be done before each mpm.sys build.
# h8 h8v4 h8z180 rcz180
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

# Rules to configure/make XIOS and loader
# H8/H8-512K/H67 MP/M XIOS
m3z67kr: $(DEF_H8) m3z67kr.sys mldr320.com
# NC89, new DS1302 RTC chip
m3z67kd: $(DEF_H8) m3z67kd.sys mldr320.img
m3cfkd: $(DEF_H8) m3cfkd.sys mldrcf.img
m3sdckd: $(DEF_H8) m3sdckd.sys mldrsdc.img

# H8/H8-512K/CF MP/M XIOS
m3cfkr: $(DEF_H8) m3cfkr.sys mldrcf.com

# H8/Z180/H8xSPI+SDC MP/M XIOS
m3sdczr: h8z180 m3sdczr.sys mldrsdc.com

# RC2014/MT011+SDC MP/M XIOS
m3rcz1sd: rcz180 m3rcz1sd.sys mldrwbw.com

# RC2014/CF MP/M XIOS
m3rcz1cf: rcz180 m3rcz1cf.sys mldrwbw.com

m3z67kr.spr: $(BASE) z67.rel rtc72421.rel mem512k.rel
	vcpm link "m3z67kr=mxios,cio8250,z67,end,lptbl,mem512k,rtc72421[b,os,nr]"
	setup30 $(Z67DRVS) $@

m3cfkr.spr: $(BASE) h8cf.rel rtc72421.rel mem512k.rel
	vcpm link "m3cfkr=mxios,cio8250,h8cf,end,lptbl,mem512k,rtc72421[b,os,nr]"
	setup30 $(CFDRVS) $@

m3sdczr.spr: $(BASE) sdc.rel rtc72421.rel memz180.rel
	vcpm link "m3sdczrr=mxios,cio8250,sdc,end,lptbl,memz180,rtc72421[b,os,nr]"
	setup30 $(SDCDRVS) $@

m3rcz1sd.spr: $(RCBASE) sdc.rel nortc.rel memz180.rel
	vcpm link "m3rcz180=mxios,cioz180,sdc,end,lptbl,memz180,nortc[b,os,nr]"
	setup30 $(SDCDRVS) $@

m3rcz1cf.spr: $(RCBASE) cf2014.rel nortc.rel memz180.rel
	vcpm link "m3rcz180=mxios,cioz180,cf2014,end,lptbl,memz180,nortc[b,os,nr]"
	setup30 $(CFDRVS) $@

# NC-89
m3z67kd.spr: $(BASE) z67.rel rtc1302.rel mem512k.rel
	vcpm link "m3z67kd=mxios,cio8250,z67,end,lptbl,mem512k,rtc1302[b,os,nr]"
	setup30 $(Z67DRVS) $@

m3cfkd.spr: $(BASE) h8cf.rel rtc1302.rel mem512k.rel
	vcpm link "m3cfkd=mxios,cio8250,h8cf,end,lptbl,mem512k,rtc1302[b,os,nr]"
	setup30 $(CFDRVS) $@

m3sdckd.spr: $(BASE) sdc.rel rtc1302.rel mem512k.rel
	vcpm link "m3sdckd=mxios,cio8250,sdc,end,lptbl,mem512k,rtc1302[b,os,nr]"
	setup30 $(SDCDRVS) $@

# SDCard MP/M+CP/NET - assumes CP/NET RSP(s) present
m3sdcnet.sys: m3sdczr.spr netservr.rsp netservr.brs
	cp $< bnkxios.spr
	cp gm.cpnet.dat system.dat
	vcpm gensys '$$ar' | tee m3sdcnet.out
	mv mpm.sys $@
	mv system.dat m3sdcnet.dat

# Z67-IDE MP/M+CP/NET - assumes CP/NET RSP(s) present
m3z67net.sys: m3z67kr.spr netservr.rsp netservr.brs
	cp $< bnkxios.spr
	cp gm.cpnet.dat system.dat
	vcpm gensys '$$ar' | tee m3z67net.out
	mv mpm.sys $@
	mv system.dat m3z67net.dat

# RC2014/MT011 MP/M+CP/NET - assumes CP/NET RSP(s) present
m3rcznsd.sys: m3rcz1sd.spr netservr.rsp netservr.brs
	cp $< bnkxios.spr
	cp gm.cpnet.dat system.dat
	vcpm gensys '$$ar' | tee m3rcznsd.out
	mv mpm.sys $@
	mv system.dat m3rcznsd.dat

# RC2014/MT011/CF MP/M+CP/NET - assumes CP/NET RSP(s) present
m3rczncf.sys: m3rcz1cf.spr netservr.rsp netservr.brs
	cp $< bnkxios.spr
	cp gm.cpnet.dat system.dat
	vcpm gensys '$$ar' | tee m3rczncf.out
	mv mpm.sys $@
	mv system.dat m3rczncf.dat

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
