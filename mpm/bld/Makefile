# Assumes PWD = CPMDrive_D

export CPMDrive_D = $(PWD)
export CPMDefault = d:

SRCS = $(wildcard *.asm)
RELS = $(subst .asm,.rel,$(SRCS))

BASE = mxios.rel cio8250.rel end.rel lptbl.rel

SDCDRVS = -d a:=80,b:=81,c:=82,d:=83,e:=84,f:=85,g:=86,h:=87
DSO = -p def,a:

all: m3sdczrr.sys

%.rel: %.asm
	vcpm rmac "$?" '$$SZLA'

m3sdczrr.spr: $(BASE) sdc.rel rtc72421.rel memz180.rel
	vcpm link "m3sdczrr=mxios,cio8250,sdc,end,lptbl,memz180,rtc72421[os,nr]"
	setup30 $(SDCDRVS) $(DSO) $@

m3%.sys: m3%.spr
	cp $? bnkxios.spr
	vcpm gensys '$$ar'
	mv mpm.sys $@

.PRECIOUS: %.rel

syncdown:
	unix2cpm -s ~/git/MmsCpm3/mpm/src/*.asm .

syncup:
	rsync -Wurv --existing . ~/git/MmsCpm3/mpm/bin/.
	rsync -Wurv --existing . ~/git/MmsCpm3/mpm/prn/.

__FRC__:
