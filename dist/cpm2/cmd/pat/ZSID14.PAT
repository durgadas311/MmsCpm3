                        A PATCH FOR ZSID

From DDJ, Dec. 1981, p. 4

There is a small hidden bug in ZSID version 1.4. It is easily
demonstrated when trying the following: in the direct assembly
mode, try to assemble three 16-bit loads with the values of (hex):

        FF7F, FF80, FFFF

Afterwards list the product.

The false values are not only used in the assembler, but in the
F(ill), M(ove) and D(ump) command as well. The cure is very simple:
change the byte at 02AE (hex) in ZSID from "C2" to "C3".

SID version 1.4 does not have this "feature", so it may be that
the routine starting at 02A1H is, at some place, necessary in the
Z-80 specific parts, e.g. for error checking in relative jumps.

There are no apparent problems after this patch is installed but,
even so, care should be taken if it is used.

The following demonstrates the bug and fix:


A>ZSID
ZSID VERS 1.4
#A100
0100  LD HL,0FF7F
0103  LD HL,0FF80
0106  LD HL,0FFFF
0109  .
#L100,108
  0100  LD   HL,FF7F
  0103  LD   HL,0080
  0106  LD   HL,00FF
  0109
#IZSID.COM
#R
NEXT  PC  END
2900 0100 B9FF
#L2A1,2BC
  02A1  PUSH DE
  02A2  CP   41
  02A4  JP   NC,0BCF
  02A7  CALL 0EAA
  02AA  LD   B,D
  02AB  LD   A,B
  02AC  CP   FF
  02AE  JP   NZ,00B8
  02B1  LD   A,E
  02B2  OR   A
  02B3  JP   P,00B8
  02B6  LD   B,00
  02B8  LD   A,E
  02B9  POP  DE
  02BA  DEC  B
  02BB  INC  B
  02BC  RET
  02BD
#S2AE
02AE C2 C3
02AF B8 .
#L2AE,2B0
  02AE  JP   00B8
  02B1
#G0

A>SAVE 40 ZSIDP.COM
A>ZSIDP
ZSID VERS 1.4
#A100
0100  LD HL,0FF7F
0103  LD HL,0FF80
0106  LD HL,0FFFF
0109  .
#L100,108
  0100  LD  HL,FF7F
  0103  LD  HL,FF80
  0106  LD  HL,FFFF
  0109
#G0
