# Build CP/M-Plus BDOS SPRs

export CPMDrive_D = $(PWD)
export CPMDrive_O = $(HOME)/CpmDev/sysprn
export CPMDefault = d:

all: resbdos3.spr bnkbdos3.spr

%.rel: %.asm
	vcpm rmac "$?" '$$SZPO'

cpmbdos.asm: cpmbdos2.asm conbdos.asm bdos30.asm
	vcpm pip $@=cpmbdos2.asm,conbdos.asm,bdos30.asm

resbdos3.spr: resbdos.rel
	vcpm link resbdos3=resbdos'[os,nr]'

bnkbdos3.spr: cpmbdos.rel
	vcpm link bnkbdos3=cpmbdos'[os,nr]'

clobber:
	rm -f *.spr *.rel
