# Assumes PWD = CPMDrive_D

export CPMDrive_D = $(HOME)/CpmDev/sys	# a.k.a. $(PWD)
export CPMDrive_O = $(HOME)/CpmDev/sysprn
export CPMDefault = d:

SRCS = $(wildcard *.asm)
RELS = $(subst .asm,.rel,$(SRCS))

BASE = mbios3.rel chrio3.rel end.rel lptbl.rel getdp.rel scb.rel
BASEZ = mbios3z.rel chrio3.rel end.rel lptbl.rel getdp.rel scb.rel

CFDRVS = -d a:=70,b:=71,c:=72,d:=73,e:=74,f:=75,g:=76,h:=77
SDCDRVS = -d a:=80,b:=81,c:=82,d:=83,e:=84,f:=85,g:=86,h:=87
Z67DRVS = -d a:=50,b:=51,c:=52,d:=53,e:=54,f:=55,g:=56,h:=57
Z17DRVS = -d i:=0,j:=1,k:=2
Z17MODS = -m "0=dds,mds;1=dds,mds;2=dds,mds"
Z37DRVS = -d i:=46,j:=47,k:=48
Z37MODS = -m "46=dds,mdd,mds;47=dds,mdd,mds;48=dds,mdd,mds;49=dds,mdd,mds"
M316DRVS = -d i:=33,j:=34,k:=35
M316MODS = -m "33=dds,mdd,mds;34=dds,mdd,mds;35=dds,mdd,mds;36=dds,mdd,mds"
RDDRVS = -d l:=40
DSO = -p def,a:

SDCSYS = c3s37krr.sys c3s37zrr.sys
CFSYS = c3f37krr.sys c3f37zrr.sys
Z67SYS = c3z17krr.sys c3z37krr.sys c3z67mr.sys c3z37zrr.sys
ALLSYS = $(Z67SYS) $(CFSYS) $(SDCSYS)

all: $(ALLSYS)

%.rel: %.asm
	vcpm rmac "$?" '$$SZLA'

ldr%.com: ldr%.rel ldrb%.rel ldrprog.rel ldrbdos.rel ldrbios.rel
	vcpm link "ldr$*=ldrprog,ldrbdos,ldrbios,ldr$*,ldrb$*[oc,nr]"

b3z17krr.spr: $(BASE) m320'3.rel z17'3.rel rd512k'3.rel rtc72421.rel mem512k.rel
	vcpm link "b3z17krr=mbios3,chrio3,m320'3,z17'3,rd512k'3,end,lptbl,rtc72421,mem512k,getdp,scb[b,os,nr]"
	setup30 $(Z67DRVS) $(Z17DRVS) $(Z17MODS) $(RDDRVS) $(DSO) $@
	

b3z37krr.spr: $(BASE) m320'3.rel z37'3.rel rd512k'3.rel rtc72421.rel mem512k.rel
	vcpm link "b3z37krr=mbios3,chrio3,m320'3,z37'3,rd512k'3,end,lptbl,rtc72421,mem512k,getdp,scb[b,os,nr]"
	setup30 $(Z67DRVS) $(Z37DRVS) $(Z37MODS) $(RDDRVS) $(DSO) $@

b3f37krr.spr: $(BASE) h8cf'3.rel z37'3.rel rd512k'3.rel rtc72421.rel mem512k.rel ldrcf.com
	vcpm link "b3f37krr=mbios3,chrio3,h8cf'3,z37'3,rd512k'3,end,lptbl,rtc72421,mem512k,getdp,scb[b,os,nr]"
	setup30 $(CFDRVS) $(Z37DRVS) $(Z37MODS) $(RDDRVS) $(DSO) $@

b3s37krr.spr: $(BASE) sdc'3.rel z37'3.rel rd512k'3.rel rtc72421.rel mem512k.rel ldrsdc.com
	vcpm link "b3s37krr=mbios3,chrio3,sdc'3,z37'3,rd512k'3,end,lptbl,rtc72421,mem512k,getdp,scb[b,os,nr]"
	setup30 $(SDCDRVS) $(Z37DRVS) $(Z37MODS) $(RDDRVS) $(DSO) $@

b3z67mr.spr: $(BASE) m320'3.rel m316'3.rel nortc.rel mem318.rel
	vcpm link "b3z67mr=mbios3,chrio3,m320'3,m316'3,end,lptbl,nortc,mem318,getdp,scb[b,os,nr]"
	setup30 $(Z67DRVS) $(M316DRVS) $(M316MODS) $(DSO) $@

# Z180 versions
mbios3z.asm: mbios3.asm
	sed -e 's/^z180	equ	false/z180	equ	true/' $^ >$@

# Z67+Z37+Z180MMU+RTC+RAMDISK
b3z37zrr.spr: $(BASEZ) m320'3.rel z37'3.rel rdz180'3.rel rtc72421.rel memz180.rel
	vcpm link "b3z37zrr=mbios3z,chrio3,m320'3,z37'3,rdz180'3,end,lptbl,rtc72421,memz180,getdp,scb[b,os,nr]"
	setup30 $(Z67DRVS) $(Z37DRVS) $(Z37MODS) $(RDDRVS) $(DSO) $@
# CF+Z37+Z180MMU+RTC+RAMDISK
b3f37zrr.spr: $(BASEZ) h8cf'3.rel z37'3.rel rdz180'3.rel rtc72421.rel memz180.rel
	vcpm link "b3f37zrr=mbios3z,chrio3,h8cf'3,z37'3,rdz180'3,end,lptbl,rtc72421,memz180,getdp,scb[b,os,nr]"
	setup30 $(CFDRVS) $(Z37DRVS) $(Z37MODS) $(RDDRVS) $(DSO) $@
# SDC+Z37+Z180MMU+RTC+RAMDISK
b3s37zrr.spr: $(BASEZ) sdc'3.rel z37'3.rel rdz180'3.rel rtc72421.rel memz180.rel
	vcpm link "b3s37zrr=mbios3z,chrio3,sdc'3,z37'3,rdz180'3,end,lptbl,rtc72421,memz180,getdp,scb[b,os,nr]"
	setup30 $(SDCDRVS) $(Z37DRVS) $(Z37MODS) $(RDDRVS) $(DSO) $@

c3%.sys: b3%.spr
	cp $? bnkbios3.spr
	cp gc.$*.dat gencpm.dat
	vcpm gencpm a d
	mv cpm3.sys $@

.PRECIOUS: %.rel

syncdown:
	unix2cpm -s ~/git/MmsCpm3/sys/src/*.asm .

syncup:
	rsync -Wurv --existing . ~/git/MmsCpm3/sys/bin/.
	rsync -Wurv --existing . ~/git/MmsCpm3/sys/prn/.
	rsync -Wuv gc.*.dat ~/git/MmsCpm3/sys/bld/

# Run from sys/bld dir
VPATH = ../../dist/bin ../../dist/cmd/bin ../../util/bin ../../help/bin

z80.lib: ../../sys/src/z80.lib
	unix2dos -n $? $@

DRIS =	ccp.com \
	date.com \
	device.com \
	dir.com \
	dump.com \
	ed.com \
	erase.com \
	gencom.com \
	gencpm.com \
	get.com \
	help.com \
	hexcom.com \
	initdir.com \
	lib.com \
	link.com \
	patch.com \
	pip.com \
	put.com \
	rename.com \
	save.com \
	set.com \
	setdef.com \
	show.com \
	sid.com \
	submit.com \
	type.com \
	xref.com \
	zsid.com \
	resbdos3.spr \
	bnkbdos3.spr

PATS =	mac.com \
	rmac.com

LOCS =	modules.com \
	copysys.com \
	drives.com \
	format.com \
	mode.com \
	rsxrm.com \
	setup.com \
	spdsbc.com \
	tpa.com \
	tr.com
# TODO:
#	edit.com
#	print.com
#	fixmsoft.com

cpm3dist.tgz: __FRC__
	tar -czf $@ z80.lib \
		-C ../../dist/bin $(DRIS) \
		-C ../cmd/bin $(PATS) \
		-C ../../../help/bin help.hlp \
		-C ../../util/bin $(LOCS)

BLDS = $(patsubst ../bin/%,"%",$(wildcard ../bin/*.rel))

cpm3bld.tgz: __FRC__
	tar -czf $@ *.sub \
		-C ../bin $(BLDS)

publish:
	rsync -Wuv cpm3dist.tgz cpm3bld.tgz durgadas.com:/http/durgadas.com/sebhc/mms89

__FRC__:
