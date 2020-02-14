H8MODS=	2716_444-19_H17.rom \
	zout/bgide.cim \
	zout/bh17.cim \
	zout/bh37.cim \
	zout/bh47.cim \
	zout/bh67.cim \
	zout/bvdip1.cim \
	zout/bwiznet.cim \
	zout/ccass.cim
#	zout/cx.cim

H8MON = zout/h8core.cim $(H8MODS)
H8Z180 = zout/h8z180.cim $(H8MODS)

VERN = $(shell awk -f getver.awk h8core.asm)

all: h8mon2.rom vflash.sys

zout/%.cim: %.asm core.lib ram.lib vdip1.lib z80.lib
	zmac --dri -i -8 -c -s -n $<
	cp $@ ../bin
	cp zout/$*.lst ../prn

h8mon2z180.rom: $(H8Z180)
	cat $(H8Z180) | ../../../tools/cksum -f -w -l 0x8000 >$@
	cp	$@ ../bin

h8mon2.rom: $(H8MON)
	cat $(H8MON) | ../../../tools/cksum -f -w -l 0x8000 >$@
	cp	$@ ../bin

# Standalone programs
export CPMDrive_D = $(PWD)
export CPMDefault = d:

%.spr: %.asm
	zmac --dri -i -8 -c -s -n --rel $<
	cp zout/$*.rel .
	vcpm link $@=$*'[os,nr]'
	cp $@ ../bin
	cp zout/$*.lst ../prn

vflash.sys: vflash.spr
	mknetboot -x -o $@ $^
	cp $@ ../bin

ship: vflash.sys h8mon2.rom ../doc/H8-Monitor-2.pdf
	rsync -uvW vflash.sys ../doc/H8-Monitor-2.pdf \
		durgadas.com:/http/durgadas.com/sebhc/mms89/h8mon2/
	rsync -uvW h8mon2.rom \
		durgadas.com:/http/durgadas.com/sebhc/mms89/h8mon2/h8mon2-v$(VERN).rom
