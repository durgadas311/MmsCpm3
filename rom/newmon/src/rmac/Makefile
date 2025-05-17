# Standalone programs
# Requires that ~/git/cpnet-z80 exist and be current
# (https://github.com/durgadas311/cpnet-z80.git).
# Requires unix2dos utility (e.g. 'dos2unix' package).
#
export CPMDrive_D = $(shell pwd)
export CPMDefault = d:

.PRECIOUS: %.rel %.asm %.lib %.spr

all: vflash.sys test512k.sys mtest512.sys mtest180.sys \
	vdump3.sys wizcfg.sys setrtc.sys vh8dutil.sys setdsrtc.sys

# not auto-built: diag512k, sdtest, vcpu

%.lib: ../%.lib
	unix2dos -n $< $@

vdip1.asm: ../vdip1.lib vdip1.pre vdip1.post
	cat vdip1.pre ../vdip1.lib vdip1.post | unix2dos >$@

%.asm:: ../standalone/%.asm
	unix2dos -n $< $@

%.rel: %.asm z80.lib z180.lib
	vcpm rmac "$*.asm" '$$SZ'
	cp $*.prn ../../prn

%.spr: %.rel
	vcpm link $@=$*'[os,nr]'
	cp $@ ../../bin

vflash.spr: vflash.rel vdip1.rel
	vcpm link $@=vflash,vdip1'[os,nr]'
	cp $@ ../../bin

vdump3.spr: vdump3.rel vdip1.rel
	vcpm link $@=vdump3,vdip1'[os,nr]'
	cp $@ ../../bin

vh8dutil.spr: vh8dutil.rel vdip1.rel
	vcpm link $@=vh8dutil,vdip1'[os,nr]'
	cp $@ ../../bin

wizcfg.spr: wizcfg.rel libwiznt.rel libnvram.rel
	vcpm link $@=wizcfg,libwiznt,libnvram'[os,nr]'
	cp $@ ../../bin

# these require custom placement in RAM...
vflash.sys: vflash.spr
	mknetboot -x -o $@ $^
	cp $@ ../../bin

# standard placement in RAM (0x3000) by default

diag512k.rel: core.lib diag512k.asm
vh8dutil.rel: ram.lib core.lib vh8dutil.asm
sasidump.rel: core.lib setup.lib ram.lib z80.lib
vdump3.rel: ram.lib core.lib vdump3.asm
setrtc.rel: core.lib setrtc.asm

libwiznt.asm: config.lib
	unix2dos -n ~/git/cpnet-z80/src/w5500/libwiznt.asm $@

libnvram.asm: config.lib
	unix2dos -n ~/git/cpnet-z80/src/libnvram.asm $@

config.lib: ~/git/cpnet-z80/src/config.lib \
	~/git/cpnet-z80/src/w5500/config.lib ~/git/cpnet-z80/src/h8xspi/config.lib
	cat $^ | unix2dos >$@

%.sys: %.spr
	mknetboot -x -b 0x3000 -o $@ $^
	cp $@ ../../bin

