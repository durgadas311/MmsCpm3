H8MODS=	2716_444-19_H17.rom \
	zout/bgide.cim \
	zout/bh17.cim \
	zout/bh37.cim \
	zout/bh47.cim \
	zout/bh67.cim \
	zout/bvdip1.cim \
	zout/bwiznet.cim \
	zout/chelp.cim \
	zout/cinput.cim \
	zout/coutput.cim \
	zout/cterm.cim \
	zout/ccass.cim \
	zout/cspeed.cim \
	zout/cvtalk.cim \
	zout/ch8dcopy.cim \
	zout/cclock.cim \
	zout/ch8test1.cim
#	zout/cx.cim
#	zout/csetup.cim # Z80/Z180 differences

H8NMODS= 2716_444-19_H17.rom \
	zout/bgide.cim \
	zout/bh17.cim \
	zout/bh37.cim \
	zout/bh47.cim \
	zout/bh67.cim \
	zout/bvdip1.cim \
	zout/bwiznet.cim \
	zout/chelp.cim \
	zout/cinput.cim \
	zout/coutput.cim \
	zout/cterm.cim \
	zout/cvtalk.cim \
	zout/ch8dcopy.cim \
	zout/cspeed.cim

# TODO: what will this include?
H89MODS= 2716_444-19_H17.rom \
	zout/bgide.cim \
	zout/bh17.cim \
	zout/bh37.cim \
	zout/bh47.cim \
	zout/bh67.cim \
	zout/bvdip1.cim \
	zout/bwiznet.cim \
	zout/chelp.cim \
	zout/cinput.cim \
	zout/coutput.cim \
	zout/cterm.cim \
	zout/cvtalk.cim \
	zout/ch8dcopy.cim \
	zout/cspeed.cim

H8MON = zout/h8core.cim $(H8MODS) zout/csetup.cim
H8NMON = zout/h8ncore.cim $(H8NMODS) zout/csetupn.cim
H89MON = zout/h89core.cim $(H89MODS) zout/csetupn.cim
H8Z180 = zout/h8z180.cim $(H8MODS) zout/csetup180.cim
H8NZ180 = zout/h8nz180.cim $(H8NMODS) zout/csetup180n.cim
ROMS = h8mon2.rom h8nmon2.rom h8mon2z180.rom h8nmon2z180.rom

VERN = $(shell awk -f getver.awk h8core.asm)

all: $(ROMS)

sys:
	$(MAKE) -C rmac all

zout/%.cim: %.asm core.lib ram.lib z80.lib z180.lib
	zmac --dri -i -8 -c -s -n $<
	cp $@ ../bin
	cp zout/$*.lst ../prn

# customized core monitor
# TODO: H89 versions
h8ncore.asm: h8core.asm
	sed -e 's/h8nofp	equ	false/h8nofp	equ	true/' $? >$@

h89core.asm: h8core.asm
	sed -e 's/h89	equ	false/h89	equ	true/' $? >$@

h8nz180.asm: h8core.asm
	sed -e 's/z180	equ	false/z180	equ	true/' \
	    -e 's/h8nofp	equ	false/h8nofp	equ	true/' $? >$@

h8z180.asm: h8core.asm
	sed -e 's/z180	equ	false/z180	equ	true/' $? >$@

# customized SETUP command
csetupn.asm: csetup.asm
	sed -e 's/nofp	equ	false/nofp	equ	true/' $? >$@

csetup180.asm: csetup.asm
	sed -e 's/z180	equ	false/z180	equ	true/' $? >$@

csetup180n.asm: csetup.asm
	sed -e 's/z180	equ	false/z180	equ	true/' \
	    -e 's/nofp	equ	false/nofp	equ	true/' $? >$@

# customized ROM images
# TODO: H89 versions
h8nmon2z180.rom: $(H8NZ180)
	cat $(H8NZ180) | ../../../tools/cksum -f -w -x -l 0x8000 >$@
	cp	$@ ../bin

h8mon2z180.rom: $(H8Z180)
	cat $(H8Z180) | ../../../tools/cksum -f -w -x -l 0x8000 >$@
	cp	$@ ../bin

h8nmon2.rom: $(H8NMON)
	cat $(H8NMON) | ../../../tools/cksum -f -w -x -l 0x8000 >$@
	cp	$@ ../bin

h8mon2.rom: $(H8MON)
	cat $(H8MON) | ../../../tools/cksum -f -w -x -l 0x8000 >$@
	cp	$@ ../bin

# Standalone programs
%.sys:
	$(MAKE) -C rmac $@

# TODO: H89 versions
ship: rmac/vflash.sys $(ROMS) ../doc/H8-Monitor-2.pdf
	rsync -uvW ../bin/*.sys ../doc/H8-Monitor-2.pdf \
		durgadas.com:/var/www/html/sebhc/mms89/h8mon2/
	rsync -uvW h8mon2.rom \
		durgadas.com:/var/www/html/sebhc/mms89/h8mon2/h8mon2-v$(VERN).rom
	rsync -uvW h8nmon2.rom \
		durgadas.com:/var/www/html/sebhc/mms89/h8mon2/h8nmon2-v$(VERN).rom
	rsync -uvW h8mon2z180.rom \
		durgadas.com:/var/www/html/sebhc/mms89/h8mon2/h8mon2z180-v$(VERN).rom
	rsync -uvW h8nmon2z180.rom \
		durgadas.com:/var/www/html/sebhc/mms89/h8mon2/h8nmon2z180-v$(VERN).rom
	rsync -uvW x.htaccess \
		durgadas.com:/var/www/html/sebhc/mms89/h8mon2/.htaccess
