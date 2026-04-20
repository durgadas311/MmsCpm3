
Conflict with XSUB and MBASIC or PIP
-----

        Question:  Why do I have problems using XSUB with some programs, in
particular MBASIC and PIP?

        Answer:  Any program, like MBASIC, that uses single character input
or direct console i/o cannot work with XSUB which only supplies console
buffer input.

        PIP commands can be given by XSUB but CON: input cannot.  Another
problem with PIP is that you cannot exit with just a RETURN since SUBMIT
does not allow blank lines.  The following patch will allow PIP to be exited
with either a RETURN or any single character (usually a period) followed by
a RETURN.

A>ddt pip.com
DDT VERS 2.2
NEXT  PC
1E00 0100
-a54f
054f  cpi 2
0551  jnc 55e
0554
-g0
A>save 29 pip.com

