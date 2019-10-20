# Assumes PWD = CPMDrive_D

export CPMDrive_D = $(HOME)/CpmDev/util
export CPMDefault = d:

all: tr.com typecr.com spdsbc.com strs512k.com test512k.com tpa.com \
	rsxrm.com nvram.com

%.com: %.asm
	vcpm mac $*.asm '$$SZLA'
	vcpm hexcom $*

# There are run from dev dir, e.g. ~/CpmDev/util
# push built files back into repo... new files must be manually copied
syncup:
	rsync -Wurv --existing . ~/git/MmsCpm3/util/bin/.
	rsync -Wurv --existing . ~/git/MmsCpm3/util/prn/.

# pull source files down from repo...
syncdown:
	unix2cpm -s ~/git/MmsCpm3/util/src/*.asm .
