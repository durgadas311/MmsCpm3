all: ../bin/mms_rom_84b.bin

../bin/mms_rom_84b.bin: mms_rom_84b.asm
	zmac --dri -i -8 -c -s -n mms_rom_84b.asm
	dd if=zout/mms_rom_84b.cim bs=1 count=4092 2>/dev/null |../../tools/cksum 
	cp zout/mms_rom_84b.cim $@
	cp zout/mms_rom_84b.lst ../prn
