# Assumes PWD = CPMDrive_D

export CPMDrive_D = /home/drmiller/CpmDev/net
export CPMDefault = d:

all:

%.rel: %.asm
	vcpm rmac "$*.asm" '$$SZLA'

%.spr: %.rel
	vcpm link "$*=$*[os,nr]"

# An example, really. For ROM at F000.
cpnos.com: cpnos.rel cpndos.rel cpbdos.rel cpbios.rel cpnios.rel
	vcpm link "cpnos,cpndos,cpnios,cpbdos,cpbios[LF000,DEC00]"
