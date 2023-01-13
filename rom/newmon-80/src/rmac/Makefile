# Standalone programs
# Requires that ~/git/cpnet-z80 exist and be current
# (https://github.com/durgadas311/cpnet-z80.git).
# Requires unix2dos utility (e.g. 'dos2unix' package).
#
export CPMDrive_D = $(shell pwd)
export CPMDefault = d:

.PRECIOUS: %.rel %.asm %.lib %.spr

all: vaflash.sys test512k.sys mtest512.sys \
	vdump3.sys wizcfg.sys setrtc.sys vh8dutil.sys

# not auto-built: diag512k, sdtest, vcpu

%.lib: ../%.lib
	unix2dos -n $< $@

vdip1.asm: ../vdip1.lib vdip1.pre vdip1.post
	cat vdip1.pre ../vdip1.lib vdip1.post | unix2dos >$@

%.asm:: ../standalone/%.asm
	unix2dos -n $< $@

%.rel: %.asm
	vcpm rmac "$*.asm" '$$SZ'
	cp $*.prn ../../prn

%.spr: %.rel
	vcpm link $@=$*'[os,nr]'
	cp $@ ../../bin

vaflash.spr: vaflash.rel vdip1.rel
	vcpm link $@=vaflash,vdip1'[os,nr]'
	cp $@ ../../bin

vdump.spr: vdump.rel vdip1.rel
	vcpm link $@=vdump,vdip1'[os,nr]'
	cp $@ ../../bin

vh8dutil.spr: vh8dutil.rel vdip1.rel
	vcpm link $@=vh8dutil,vdip1'[os,nr]'
	cp $@ ../../bin

wizcfg.spr: wizcfg.rel libwiznt.rel libnvram.rel
	vcpm link $@=wizcfg,libwiznt,libnvram'[os,nr]'
	cp $@ ../../bin

# these require custom placement in RAM...
vaflash.sys: vaflash.spr
	mknetboot -x -o $@ $^
	cp $@ ../../bin

# standard placement in RAM (0x3000) by default

vh8dutil.rel: ram.lib core.lib vh8dutil.asm
vdump.rel: ram.lib core.lib vdump.asm
setrtc.rel: core.lib setrtc.asm

%.sys: %.spr
	mknetboot -x -b 0x3000 -o $@ $^
	cp $@ ../../bin

