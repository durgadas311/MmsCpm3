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

zout/%.cim: %.asm
	zmac --dri -i -8 -c -s -n $?

h8mon2.rom: $(ALL)
	dd if=/dev/zero bs=1k count=32 | tr '\0' '\377' >$@
	cat $(ALL) | dd of=$@ conv=notrunc
