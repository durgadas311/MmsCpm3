# For use with vcpm, SWTW C/80, and DRI RMAC/LINK.
#

.PRECIOUS: %.asm %.h %.rel %.spr

BLD = ./build

# need to get from vcpm...
VCPM_A = $(shell CPMShow=A vcpm)
# these are for vcpm...
export CPMDrive_C = $(PWD)
export CPMDrive_B = $(BLD)
export CPMDefault = c:

TARGETS = clibromx.rel

all: $(TARGETS)

clean:
	rm -f *.asm *.rel

clobber: clean
	rm -rf $(BLD)

install: $(TARGETS)
	rsync -Wuv $(TARGETS) $(VCPM_A)

$(CPMDrive_B):
	mkdir -p $@

%.lib: ../newmon/src/%.lib
	ln -s $< $@

%.rel: %.asm
	vcpm rmac $*.asm '$$szpz'
	@test -s $@

end.rel: end.mac
	vcpm m80 end=end.mac
	@test -s $@

%.asm: %.c
	vcpm c -m2 $*.c
	@test -s $@

clibma.rel: $(VCPM_A)/clibrary.rel
	vcpm lib clibma=a:clibrary.rel'(clibma)'
	@test -s $@

fixmso.rel: $(VCPM_A)/clibrary.rel
	vcpm lib fixmso=a:clibrary.rel'(fixmso)'
	@test -s $@

clibromx.rel: core.lib clibio.rel clibma.rel fixmso.rel end.rel
	vcpm lib clibromx.rel=fixmso.rel,clibma.rel,clibio.rel,end.rel
	@test -s $@

# test programs

tests: hello.sys argv.sys

%.spr: %.rel clibromx.rel printf.rel
	vcpm link $@=$*,'printf[s],clibromx[s,os,nr]'
	@test -s $@

%.sys: %.spr
	mknetboot -x -b 0x3000 -o $@ $^

__FRC__:
