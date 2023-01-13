H8MODS=	../../newmon/src/2716_444-19_H17.rom \
	zout/bcf.cim \
	zout/bh17.cim \
	zout/bh37.cim \
	zout/bh47.cim \
	zout/bh67.cim \
	zout/bsdcard.cim \
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
	zout/ch8test1.cim \
	zout/csetup.cim
#	zout/cx.cim
# for bringup:
H8MODS=	../../newmon/src/2716_444-19_H17.rom \
	zout/chelp.cim \
	zout/cdump.cim	\
	zout/csubst.cim

H8MON = zout/h8core.cim $(H8MODS)
ROMS = h8amon2.rom # h8anmon2.rom

VERN = $(shell awk -f ../../newmon/src/getver.awk h8core.asm)

all: $(ROMS)

ram.lib core.lib setup.lib:
	ln -s ../../newmon/src/$@ $@

sys:
	$(MAKE) -C rmac all

zout/%.cim: %.asm core80.lib core.lib ram.lib setup.lib
	zmac --dri -i -8 -c -s -n $<
	cp $@ ../bin
	cp zout/$*.lst ../prn

h8amon2.rom: $(H8MON)
	cat $(H8MON) | ../../../tools/cksum -f -w -x -l 0x8000 >$@
	cp $@ ../bin

# Standalone programs
%.sys:
	$(MAKE) -C rmac $@

ship: $(ROMS) rmac/vaflash.sys # ../doc/H8-Monitor-2.pdf
	rsync -uvW ../bin/*.sys ../doc/H8-Monitor-2.pdf \
		durgadas.com:/var/www/html/sebhc/mms89/h8mon2/8080/
	rsync -uvW h8mon2.rom \
		durgadas.com:/var/www/html/sebhc/mms89/h8mon2/8080/h8amon2-v$(VERN).rom
	rsync -uvW x.htaccess \
		durgadas.com:/var/www/html/sebhc/mms89/h8mon2/8080/.htaccess
