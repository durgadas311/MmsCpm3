# Standalone programs
export CPMDrive_D = $(shell pwd)
export CPMDefault = d:

.PRECIOUS: %.rel %.asm %.lib %.spr

all:

%.lib: ../%.lib
	unix2cpm -s $< $@

%.asm: ../%.asm
	unix2cpm -s $< $@

%.rel: %.asm z80.lib z180.lib
	vcpm rmac "$*.asm" '$$SZ'
	cp $*.prn ../../prn

%.spr: %.rel
	vcpm link $@=$*'[os,nr]'
	cp $@ ../../bin

vflash.spr: vflash.rel vdip1.rel
	vcpm link $@=vflash,vdip1'[os,nr]'
	cp $@ ../../bin

%.sys: %.spr
	mknetboot -x -o $@ $^
	cp $@ ../../bin

