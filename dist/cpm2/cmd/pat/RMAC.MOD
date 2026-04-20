El Paso, TX, 10/18/83

When I wrote LDIR a few hours ago, I realized that RMAC was unable to
handle the job, since it would wipe out DOLLAR-SIGNS in labels.  Some
SYSLIB routines, however, use them in external references...

	EXTRN	F$OPEN		in RMAC is synonymous to
	EXTRN	FOPEN

and LINK would complain about the missing symbol FOPEN!

Now, there just HADT TO BE a better way than M80, and after a lot of
DU'ing and DDT'ing, I found it! In RMAC ver 1.1 you find the following
code starting at address 1D76:

L1D76:	CPI	'$'
	RNZ
	XRA	A
	MOV	M,A
	RET

Now, to be able to use RMAC instead of M80 for *ALL* your SYSLIB work,
make a NOP out of the MOV M,A instruction! Remember, the address is only
good for my version of RMAC, as supplied with an early version of CP/M plus.
Your RMAC may be a bit different, but the code should be in the general
area.

With the availability of CP/M plus, more people will probably use RMAC
than M80, and this easy patch (which seems to have NO ILL EFFECTS) allows
use of SYSLIB with RMAC.

My recommendation: reformat SYSLIB into an IRL file for faster searching.
