# MP/M for H89 with Z180 CPU
# Assumes PWD = CPMDrive_D

export CPMDrive_D = $(PWD)
export CPMDefault = d:

SRCS = $(wildcard *.asm)
RELS = $(subst .asm,.rel,$(SRCS))

BASE = mxios.rel cio8250.rel end.rel lptbl.rel

SDCDRVS = -d a:=80,b:=81,c:=82,d:=83,e:=84,f:=85,g:=86,h:=87
DSO = -p def,a:

all: m3sdczrr.sys mldrsdc.img

%.rel: %.asm
	vcpm rmac "$?" '$$SZLA'

# MPMLDR bootstrap image (1st stage at 2280H)
# (bootstrap at 2280H is written to first sector(s) on boot track,
#  then 0100H-... is written to following sectors of boot tracks)
mldr%.img: ldr%.rel ldrb%.rel mldrprog.rel ldrbdos.rel ldrbios.rel
	vcpm link "$@=mldrprog,ldrbdos,ldrbios,ldr$*,ldrb$*[oc,nr]"

# MPMLDR.COM, runnable from CP/M
# This still doesn't work... use of "org 0100h" in mldrprog ruins it.
#mldr%.com: ldrentry.rel ldr%.rel mldrprog.rel ldrbdos.rel ldrbios.rel
#	vcpm link "$@=ldrentry,mldrprog,ldrbdos,ldrbios,ldr$*[oc,nr,l0100,p0]"

m3sdczrr.spr: $(BASE) sdc.rel rtc72421.rel memz180.rel
	vcpm link "m3sdczrr=mxios,cio8250,sdc,end,lptbl,memz180,rtc72421[os,nr]"
	setup30 $(SDCDRVS) $(DSO) $@

m3%.sys: m3%.spr
	cp $? bnkxios.spr
	cp gm.cpnet.dat system.dat
	vcpm gensys '$$ar'
	mv mpm.sys $@

.PRECIOUS: %.rel

syncdown:
	unix2cpm -s ~/git/MmsCpm3/mpm/src/*.asm .
	unix2cpm -s ~/git/MmsCpm3/sys/src/ldr*.asm .

syncup:
	rsync -Wurv --existing . ~/git/MmsCpm3/mpm/bin/.
	rsync -Wurv --existing . ~/git/MmsCpm3/mpm/prn/.

__FRC__:
