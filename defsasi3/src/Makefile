# These binaries are typically inserted into associated arrays in
# H89SASIFormatter.java where they are set into the partition sectors
# of new disk images. Alternatively, DEFSASI is modified to do that.
#
# "od -tx1 -w8 zout/bsdcbot.cim" is used to get initial array data,
# then apply fixup to meet JAVA syntax.

all: cf m320 sdc

m320: ../bin/b320bot.bin

cf: ../bin/bcfbot.bin

sdc: ../bin/bsdcbot.bin

../bin/%.bin: %.asm
	zmac --dri -i -8 -c -s -n $?
	cp zout/$*.cim $@
