H8MODS=	2716_444-19_H17.rom \
	zout/bgide.cim \
	zout/bh17.cim \
	zout/bh37.cim \
	zout/bh47.cim \
	zout/bh67.cim \
	zout/bvdip1.cim \
	zout/bwiznet.cim \
	zout/ccass.cim
#	zout/cx.cim
#	zout/csetup.cim # Z80/Z180 differences

H8MON = zout/h8core.cim $(H8MODS) zout/csetup.cim
H8Z180 = zout/h8z180.cim $(H8MODS) zout/csetup180.cim

VERN = $(shell awk -f getver.awk h8core.asm)
VERNZ = $(shell awk -f getver.awk h8z180.asm)

all: h8mon2.rom h8mon2z180.rom

sys:
	$(MAKE) -C rmac all

zout/%.cim: %.asm core.lib ram.lib z80.lib z180.lib
	zmac --dri -i -8 -c -s -n $<
	cp $@ ../bin
	cp zout/$*.lst ../prn

h8z180.asm: h8core.asm
	sed -e 's/z180	equ	false/z180	equ	true/' $? >$@

csetup180.asm: csetup.asm
	sed -e 's/z180	equ	false/z180	equ	true/' $? >$@

h8mon2z180.rom: $(H8Z180)
	cat $(H8Z180) | ../../../tools/cksum -f -w -x -l 0x8000 >$@
	cp	$@ ../bin

h8mon2.rom: $(H8MON)
	cat $(H8MON) | ../../../tools/cksum -f -w -x -l 0x8000 >$@
	cp	$@ ../bin

# Standalone programs
%.sys:
	$(MAKE) -C rmac $@

ship: rmac/vflash.sys h8mon2.rom h8mon2z180.rom ../doc/H8-Monitor-2.pdf
	rsync -uvW ../bin/*.sys ../doc/H8-Monitor-2.pdf \
		durgadas.com:/http/durgadas.com/sebhc/mms89/h8mon2/
	rsync -uvW h8mon2.rom \
		durgadas.com:/http/durgadas.com/sebhc/mms89/h8mon2/h8mon2-v$(VERN).rom
	rsync -uvW h8mon2z180.rom \
		durgadas.com:/http/durgadas.com/sebhc/mms89/h8mon2/h8mon2z180-v$(VERNZ).rom
	rsync -uvW x.htaccess \
		durgadas.com:/http/durgadas.com/sebhc/mms89/h8mon2/.htaccess
