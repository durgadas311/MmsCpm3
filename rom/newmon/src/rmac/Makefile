# Standalone programs
export CPMDrive_D = $(shell pwd)
export CPMDefault = d:

.PRECIOUS: %.rel %.asm %.lib %.spr

all: vflash.sys test512k.sys vdump3.sys

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

test512k.sys: test512k.spr
	mknetboot -x -b 0x3000 -o $@ $^
	cp $@ ../../bin

%.sys: %.spr
	mknetboot -x -o $@ $^
	cp $@ ../../bin

