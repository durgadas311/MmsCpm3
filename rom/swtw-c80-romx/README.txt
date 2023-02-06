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
gets(buf)	Input a line from console into buf. The LF/CR is not
		placed in buf. BS is recognized and works. DEL will
		abort and return to monitor, however that behavior may
		not be safe. Other control chars are rejected.
read(0, buf, len)
		Input len chars into buf from console.	BS is NOT
		recognized.

sbrk(len)	Move the heap point forward len bytes,
		return previous heap pointer.

Because putchar/putc is implemented, printf will work.

Because sbrk is implemented, alloc/free may be used. The end of memory
is 0xE000. With the typical program ORG of 0x3000 that leaves 44K for
program, data, heap, and stack.

argc, argv[]	Full commandline arguments are supported,
		including a valid argv[0]. Note that the
		commandline is NOT forced to uppercase.

Note that the Monitor uses a 128-byte buffer for line input.
This means the commandline will not exceed 128 characters, nor
will the results of gets().

There is no file support. Routines that access files or FCBs
(or the OS) should not be used.
