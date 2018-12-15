all: ../bin/rom422.bin

../bin/rom422.bin: rom422.asm
	zmac --dri -i -8 -c -s -n rom422.asm
	cp zout/rom422.cim $@
	cp zout/rom422.hex ../bin

rom422.asm: pre422.asm net422.asm suf422.asm
	cat pre422.asm net422.asm suf422.asm >$@
