
.PRECIOUS: %.asm %.h %.rel

CSRC = $(HOME)/swtw-c80-cpm

VCPM_A = $(shell CPMShow=A vcpm)

export CPMDrive_C = $(PWD)
export CPMDrive_D = $(CSRC)
export CPMDefault = c:

TARGETS = oledldr.com
DEPS = i2clib.rel oledlib.rel

all: $(TARGETS)

%.h: $(VCPM_A)/%.h
	ln -s $? $@

oledlib.rel: oledlib.c
i2clib.rel: i2clib.c

%.asm: %.c
	vcpm c -m2 c:$*.c
	@test -s $@

%.asm: $(CPMDrive_D)/%.c
	vcpm c -m2 c:$*=d:$*.c
	@test -s $@

%.rel: %.asm
	vcpm rmac c:$*.asm '$$szpz'
	@test -s $@

oledldr.com: printf.h printf.rel oledldr.rel $(DEPS)
	vcpm link oledldr=oledldr,oledlib,i2clib,printf,a:stdlib'[s]',a:clibrary'[s,oc,nr]'
	@test -s $@
