# Standalone programs
export CPMDrive_D = $(shell pwd)
export CPMDefault = d:

.PRECIOUS: %.rel %.asm %.lib %.spr

all: vflash.sys test512k.sys mtest512.sys vdump3.sys wizcfg.sys setrtc.sys

%.lib: ../%.lib
	unix2dos -n $< $@

%.asm: ../%.asm
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

vdump3.sys: vdump3.spr
	mknetboot -x -b 0x3000 -o $@ $^
	cp $@ ../../bin

diag512k.rel: core.lib diag512k.asm

diag512k.sys: diag512k.spr
	mknetboot -x -b 0xc000 -o $@ $^
	cp $@ ../../bin

mtest512.sys: mtest512.spr
	mknetboot -x -b 0x3000 -o $@ $^
	cp $@ ../../bin

test512k.sys: test512k.spr
	mknetboot -x -b 0x3000 -o $@ $^
	cp $@ ../../bin

vh8dutil.rel: ram.lib core.lib vh8dutil.asm

vdump3.rel: ram.lib core.lib vdump3.asm
setrtc.rel: core.lib setrtc.asm

setrtc.sys: setrtc.spr
	mknetboot -x -b 0x3000 -o $@ $^
	cp $@ ../../bin

libwiznt.asm: config.lib
	unix2dos -n ~/git/cpnet-z80/src/w5500/libwiznt.asm $@

libnvram.asm: config.lib
	unix2dos -n ~/git/cpnet-z80/src/h8xspi/libnvram.asm $@

config.lib: ~/git/cpnet-z80/src/config.lib \
	~/git/cpnet-z80/src/w5500/config.lib ~/git/cpnet-z80/src/h8xspi/config.lib
	cat $^ | unix2dos >$@

wizcfg.spr: wizcfg.rel libwiznt.rel libnvram.rel
	vcpm link $@=wizcfg,libwiznt,libnvram'[os,nr]'
	cp $@ ../../bin

sdtest.sys: sdtest.spr
	mknetboot -x -b 0x3000 -o $@ $^
	cp $@ ../../bin

wizcfg.sys: wizcfg.spr
	mknetboot -x -b 0x3000 -o $@ $^
	cp $@ ../../bin

%.sys: %.spr
	mknetboot -x -o $@ $^
	cp $@ ../../bin

