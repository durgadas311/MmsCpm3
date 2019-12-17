#
MODS = mac0.rel mac1200.rel mac1600.rel mac1c00.rel mac2100.rel mac2580.rel mac9.rel
ZMODS = $(addprefix zout/,$(MODS))
LMODS = $(shell echo "$(basename $(MODS))"|tr ' ' ',')

all:

mac.cim: $(ZMODS)
	ld80 -O cmd -o $@ $(ZMODS)

zout/mac%.rel: mac%.asm macg.lib
	zmac --dri --rel -i -8 -c -s -n $<

# For use from vcpm directory...
export CPMDrive_L = $(PWD)
export CPMDefault = l:

%.rel: %.asm macg.lib
	vcpm rmac $<

mac.com: $(MODS)
	vcpm link $@=$(LMODS)'[oc]'

syncdown:
	unix2cpm -s ~/git/MmsCpm3/dist/pgr/mac/src/*.asm \
		~/git/MmsCpm3/dist/pgr/mac/src/*.lib .

syncup:
	rsync -Wurv --existing . ~/git/MmsCpm3/dist/pgr/mac/bin/.
	rsync -Wurv --existing . ~/git/MmsCpm3/dist/pgr/mac/prn/.
