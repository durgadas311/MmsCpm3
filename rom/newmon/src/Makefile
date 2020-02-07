ALL = zout/h8core.cim \
	2716_444-19_H17.rom \
	zout/bgide.cim \
	zout/bh17.cim \
	zout/bh37.cim \
	zout/bh47.cim \
	zout/bh67.cim \
	zout/bvdip1.cim \
	zout/bwiznet.cim \
	zout/ccass.cim
#	zout/cx.cim

all: h8mon2.rom

zout/%.cim: %.asm core.lib ram.lib vdip1.lib z80.lib
	zmac --dri -i -8 -c -s -n $<
	cp $@ ../bin
	cp zout/$*.lst ../prn

h8mon2.rom: $(ALL)
	cat $(ALL) | ../../../tools/cksum -f -w -l 0x8000 >$@
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
