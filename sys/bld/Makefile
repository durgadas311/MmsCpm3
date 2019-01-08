# Assumes PWD = CPMDrive_D

export CPMDrive_D = $(HOME)/CpmDev/sys	# a.k.a. $(PWD)
export CPMDrive_O = $(HOME)/CpmDev/sysprn
export CPMDefault = d:

SRCS = $(wildcard *.asm)
RELS = $(subst .asm,.rel,$(SRCS))

BASE = mbios3.rel chrio3.rel end.rel lptbl.rel getdp.rel scb.rel

Z67DRVS = -d a:=50,b:=51,c:=52,d:=53,e:=54,f:=55,g:=56,h:=57
Z17DRVS = -d i:=0,j:=1,k:=2
Z17MODS = -m "0=dds,mds;1=dds,mds;2=dds,mds"
Z37DRVS = -d i:=46,j:=47,k:=48
Z37MODS = -m "46=dds,mdd,mds;47=dds,mdd,mds;48=dds,mdd,mds;49=dds,mdd,mds"
M316DRVS = -d i:=33,j:=34,k:=35
M316MODS = -m "33=dds,mdd,mds;34=dds,mdd,mds;35=dds,mdd,mds;36=dds,mdd,mds"
RDDRVS = -d l:=40
DSO = -p def,a:

all: c3z17krr.sys c3z37krr.sys c3z67mr.sys

%.rel: %.asm
	vcpm rmac "$?" '$$SZLAPO'

b3z17krr.spr: $(BASE) m320'3.rel z17'3.rel rd512k'3.rel rtc72421.rel mem512k.rel
	vcpm link "b3z17krr=mbios3,chrio3,m320'3,z17'3,rd512k'3,end,lptbl,rtc72421,mem512k,getdp,scb[b,os,nr]"
	setup30 $(Z67DRVS) $(Z17DRVS) $(Z17MODS) $(RDDRVS) $(DSO) $@
	

b3z37krr.spr: $(BASE) m320'3.rel z37'3.rel rd512k'3.rel rtc72421.rel mem512k.rel
	vcpm link "b3z37krr=mbios3,chrio3,m320'3,z37'3,rd512k'3,end,lptbl,rtc72421,mem512k,getdp,scb[b,os,nr]"
	setup30 $(Z67DRVS) $(Z37DRVS) $(Z37MODS) $(RDDRVS) $(DSO) $@

b3z67mr.spr: $(BASE) m320'3.rel m316'3.rel nortc.rel mem318.rel
	vcpm link "b3z67mr=mbios3,chrio3,m320'3,m316'3,end,lptbl,nortc,mem318,getdp,scb[b,os,nr]"
	setup30 $(Z67DRVS) $(M316DRVS) $(M316MODS) $(DSO) $@

c3%.sys: b3%.spr
	cp $? bnkbios3.spr
	cp gc.$*.dat gencpm.dat
	vcpm gencpm a d
	mv cpm3.sys $@