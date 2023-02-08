The file "clibromx.rel" may be used in place of "clibrary.rel"
in Software Toolworks C/80 builds to create standalone programs.
Note that additional steps are required to create the standalone
executable after linking, such as "mknetboot.jar" or "hex2sys".

The following traditional C functions are available
in the standalone environment (using Monitor entry points).

putchar(c)	Output char to console.
putc(c, 0)	Output char to console (only unit "0" allowed).
puts(s)		Output string to console, adding CR/LF.
write(0, buf, len)
		Output len chars from buf to console.

In all cases, outputing a LF causes a CR to be prefixed.

getchar()	Input char from console.
getc(0)		Input char from console (only unit "0" allowed).
gets(buf)	Input a line from console into buf. Returns number
		of chars in (NUL terminated) buf, unless otherwise stated.
		Limited to 128 chars of input.	Edit characters are:

		CR - End input, NUL terminate and return count.
		^C - Abort input, return -1. buf is undefined.
		ESC - Abort input, return 1 with single ESC in buf.
		BS - Erase previous char.

read(0, buf, len)
		Input len chars into buf from console.	BS is NOT
		recognized.

sbrk(len)	Move the heap pointer forward len bytes,
		return previous heap pointer.

Because putchar/putc is implemented, printf will work.

Because sbrk is implemented, alloc/free may be used. The end of memory
is 0xE000. With the typical program ORG of 0x3000 that leaves 44K for
program, data, heap, and stack.

argc, argv[]	Full commandline arguments are supported,
		including a valid argv[0]. Note that the
		commandline is NOT forced to uppercase.

Note that the Monitor uses a 128-byte buffer for line input.
This means the commandline will not exceed 128 characters.

There is no file support. Routines that access files or FCBs
(or the OS) should not be used.

BUILDING STANDALONE PROGRAMS

Aside from special considerations for running in the standalone
environment, programs are compiled/assembled normally - with the
exception that a COM/ABS file is not created.

There are two methods (currently) of producing the ".sys" file
used for standalone programs.

mknetboot.jar:
	The program is linked into a ".spr" file, which requires
	Digital Research's LINK.COM linker and the option "OS".
	After the SPR file is created, that may be converted to
	a ".sys" file using the JAVA program "mknetboot.jar".
	A typical LINK link of a C program might be:

	link myprog=myprog,clibromx[s,os]

	Which is then followed by the "mknetboot" command
	to convert the SPR into a SYS.

hex2sys:
	The program is compiled/assembled into a ".hex" file.
	Since C programs require linking, the only known method
	is to use Microsoft's L80.COM linker with the "/x" option.
	Note that standalone programs must use an "origin" above
	the ROM and associated RAM area, so typically the minimum
	ORG is 3000H. A typical L80 link of a C program might be:

	l80 /p:3000,myprog,clibromx/s,myprog/n/x/e

	Which is then followed by the "hex2sys" command
	to convert the SPR into a SYS.

	It should also be possible to use ld80 (part of zmac) to
	link into HEX files (using Linux). A possible command for that
	might be:

	ld80 -P 0x3000 -o myprog.hex -O hex myprog.rel -l clibromx.rel
