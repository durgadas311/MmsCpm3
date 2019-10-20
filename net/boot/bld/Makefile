# Assumes PWD = CPMDrive_D

export CPMDrive_D = $(HOME)/CpmDev/netboot	# a.k.a. $(PWD)
export CPMDefault = d:

SYSS = cpnos.sys dump.sys dump3.sys cpnet3.sys # cpnet.sys
BASE3 = nbios3.rel chrio3.rel end.rel lptbl.rel getdp.rel scb.rel
GIDEDRVS = -d b:=70,c:=71,d:=72,e:=73,f:=74,g:=75,h:=76,i:=77
RDDRVS = -d j:=40
DSO = -p def,a:

all: $(SYSS)

%.spr: %.asm
	vcpm rmac $? '$$szla'
	vcpm link $@=$*'[os,nr]'

%.rel: %.asm
	vcpm rmac $? '$$szla'

cpnos.sys: cobdos.spr ndos.spr cobios.spr # snios.spr...
	mknetboot -g -o $@ \
		x:=x: \
		-ndos ndos.spr \
		-snios snios-w.spr \
		-bdos cobdos.spr \
		-bios cobios.spr

dump.sys: dump.spr
	mknetboot -x -o $@ -b 0x2400 \
		dump.spr

dump3.sys: dump3.spr
	mknetboot -x -o $@ -b 0x2400 \
		dump3.spr

netbios3.spr: $(BASE3) gide'3.rel rd512k'3.rel rtc72421.rel mem512k.rel
	vcpm link "netbios3=nbios3,chrio3,gide'3,rd512k'3,end,lptbl,rtc72421,mem512k,getdp,scb[b,os,nr]"
	setup30 $(GIDEDRVS) $(RDDRVS) $(DSO) $@

ndos3.spr: ndos3.rel snioswiz.rel
	vcpm link "ndos3=ndos3,snioswiz[os,nr]"

cpnet3.sys: netbios3.spr ndos3.spr resbdos3.spr bnkbdos3.spr
	mknetboot -g -o $@ \
		a:=b: \
		-ndos ndos3.spr \
		-bdos resbdos3.spr \
		-bnkbdos -k bnkbdos3.spr \
		-bios -e netbios3.spr


cpnet.sys: bdos22.spr ndos.spr bios22.spr # snios.spr...
#	mknetboot ...

# There are run from dev dir, e.g. ~/CpmDev/netboot
# push built files back into repo... new files must be manually copied
syncup:
	rsync -Wurv --existing . ~/git/MmsCpm3/net/boot/bin/.
	rsync -Wurv --existing . ~/git/MmsCpm3/net/boot/prn/.

# pull source files down from repo...
syncdown: scb.rel resbdos3.spr snioswiz.rel
	unix2cpm -s ~/git/MmsCpm3/net/boot/src/*.asm .

scb.rel: ~/git/MmsCpm3/sys/bin/scb.rel
	ln -s ~/git/MmsCpm3/sys/bin/*.rel .

resbdos3.spr: ~/git/MmsCpm3/dist/bin/resbdos3.spr
	ln -s ~/git/MmsCpm3/dist/bin/*.spr .

snioswiz.rel: ~/git/MmsCpm3/net/bin/snioswiz.rel
	ln -s ~/git/MmsCpm3/net/bin/snioswiz.rel .

# The following run from ~/git/MmsCpm3/net/boot/bld...
ship: netboots.tgz

netboots.tgz: # $(SYSS) org0boot.bin
	tar -czf netboots.tgz -C ../bin $(SYSS) -C ../../../rom/bin org0boot.bin
