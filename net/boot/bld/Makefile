# Assumes PWD = CPMDrive_D

export CPMDrive_D = $(HOME)/CpmDev/netboot	# a.k.a. $(PWD)
export CPMDefault = d:

all:

%.spr: %.asm
	vcpm rmac $? '$$szla'
	vcpm link $@=$*'[os,nr]'

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

cpnet.sys: bdos22.spr ndos.spr bios22.spr # snios.spr...
#	mknetboot ...

# There are run from dev dir, e.g. ~/CpmDev/netboot
# push built files back into repo... new files must be manually copied
syncup:
	rsync -Wurv --existing . ~/git/MmsCpm3/net/boot/bin/.
	rsync -Wurv --existing . ~/git/MmsCpm3/net/boot/prn/.

# pull source files down from repo...
syncdown:
	unix2cpm -s ~/git/MmsCpm3/net/boot/src/*.asm .
