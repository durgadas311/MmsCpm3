export CPMDrive_C = $(PWD)

all: xd.com

%.rel: %.asm
	vcpm rmac c:$*.asm '$$szpz'

%.asm: %.c
	vcpm c -m2 c:$*.c

%.com: %.rel
	vcpm link c:$*=c:$*,'c:libc.irl[s,oc,nr]'

#	vcpm link c:$*=c:$*,'a:stdlib[s],a:clibrary[s,oc,nr]'

.PRECIOUS: %.asm %.rel
