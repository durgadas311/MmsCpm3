# Build patched HDOS clibrary.rel, to fix sbrk() issue with RMAC/LINK
# NOTE: clibio.c cannot be built with RMAC, so use M80.

export CPMDrive_C = $(PWD)
export CPMDrive_B = $(PWD)/../bin
export CPMDrive_D = $(PWD)/../src
export CPMDefault = c:


all: clibrary.rel

clibrary.rel: fixmso.rel clibma.rel clibio.rel
	vcpm lib clibrary.rel=fixmso.rel,clibma.rel,clibio.rel

fixmso.rel: ../bin/clibrary.rel
	vcpm lib fixmso=b:clibrary.rel'(fixmso)'

clibma.rel: ../bin/clibrary.rel
	vcpm lib clibma=b:clibrary.rel'(clibma)'

clibio.rel: clibio.asm
	vcpm m80 clibio=clibio.asm

clibio.asm: clibio.c
	vcpm c -m1 clibio.asm=clibio.c

clibio.c: ../src/clibio.c sbrkfix.patch
	patch -i sbrkfix.patch -o clibio.c ../src/clibio.c
