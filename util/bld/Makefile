# Assumes PWD = CPMDrive_D

export CPMDrive_D = $(HOME)/CpmDev/util
export CPMDefault = d:

all: tr.com typecr.com spdsbc.com strs512k.com test512k.com tpa.com \
	rsxrm.com nvram.com

%.com: %.asm
	vcpm mac $*.asm '$$SZLA'
	vcpm hexcom $*
