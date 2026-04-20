El Paso TX  10-29-83

How often have you inadvertently struck a key while Digital Research's
LINK was linking a file? If you've ever done it (especially where you
had to type a long command line or the linking took a while) you know
how frustrating it is when LINK aborts. It is a mystery to me why DRI
would allow LINK to abort on ANY keyboard entry. Fortunately, the
changes to prevent that are trivial. Simply use your favorite debugger,
load LINK.COM and change location 368B from 0E to AF and 368C from 0B to C9.
This causes the console status routine to always return "console not ready."

NOTE: platch is valid for LINK ver 1.31 only. The code to be changed is
from 0E 0B C3 05 00  (MVI C,0B ! JMP BDOS)
to   AF C9 .. .. ..  (XRA A ! RET)
and can be found using DDTF or DU.
