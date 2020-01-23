H8BINS = ../bin/PAM37_Monitor_ROM.bin
MMSBINS = ../bin/mms_rom_84b.bin ../bin/org0boot.bin

all: $(MMSBINS) $(H8BINS)

mms: $(MMSBINS)

h8: $(H8BINS)

../bin/org0boot.bin: org0boot.asm
	zmac --dri -i -8 -c -s -n org0boot.asm
	cp zout/org0boot.cim $@
	cp zout/org0boot.lst ../prn

../bin/mms_rom_84b.bin: mms_rom_84b.asm
	zmac --dri -i -8 -c -s -n mms_rom_84b.asm
	cp zout/mms_rom_84b.cim $@
	cp zout/mms_rom_84b.lst ../prn
# Checksum no longer used...
#	dd if=zout/mms_rom_84b.cim bs=1 count=4092 2>/dev/null |../../tools/cksum 
#	dd if=zout/mms_rom_84b.cim bs=1 skip=4094 2>/dev/null |od -tx2

../bin/PAM37_Monitor_ROM.bin: PAM37_Monitor_ROM.asm
	zmac -i -z -c -s -n PAM37_Monitor_ROM.asm
	cp zout/PAM37_Monitor_ROM.cim $@
	cp zout/PAM37_Monitor_ROM.lst ../prn
