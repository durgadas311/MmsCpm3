/***************************************************************************
*
*	  C P / M   C	R U N	T I M E   L I B   H E A D E R	F I L E
*	  -------------------------------------------------------------
*	Copyright 1982 by Digital Research Inc.  All rights reserved.
*
*	This is an include file for assisting the user to write portable
*	programs for C.  All processor dependencies should be located here.
*
****************************************************************************/

/*
 *	Standard type definitions
 */

#define byte	char
#define BYTE	char				/* signed byte */
#define UBYTE	char				/* unsigned byte */
#define bool	int				/* 2 valued (true/false)   */
#define BOOLEAN int
#define word	unsigned int
#define WORD	int				/* signed word */
#define UWORD	unsigned int			/* unsigned word */
#define short	int
#define void	/**/				/* Void function return    */
#define VOID	/**/
#define ushort	unsigned int
#define bits	unsigned int
#define metachar int

#define LONG	long				/* signed long (32 bits)   */
#define ULONG	long				/* Unsigned long	   */
#define FLOAT	float				/* Floating Point	   */
#define DOUBLE	float				/* Double precision	   */
#define DEFAULT int				/* Default size 	   */

#define REG	register			/* register variable	   */
#define LOCAL	auto				/* Local var on 68000	   */
#define EXTERN	extern				/* External variable	   */
#define MLOCAL	static				/* Local to module	   */
#define GLOBAL	/**/				/* Global variable	   */

#define FILE	char				/* FILE * type */

/****************************************************************************/
/*	Miscellaneous Definitions:					    */
/****************************************************************************/
#define FAILURE (-1)			/*	Function failure return val */
#define SUCCESS (0)			/*	Function success return val */
#define YES	1			/*	"TRUE"			    */
#define NO	0			/*	"FALSE" 		    */
#define FOREVER for(;;) 		/*	Infinite loop declaration   */
#define NULL	0			/*	Null character value	    */
#define NULLPTR (char *) 0		/*	Null pointer value	    */
#define EOF	(-1)			/*	EOF Value		    */
#define TRUE	(1)			/*	Function TRUE  value	    */
#define FALSE	(0)			/*	Function FALSE value	    */


/* printf.h: definitions for printf and fprintf to allow multiple args.
 */

#undef printf
#undef fprintf
#undef sprintf
#define printf prnt_1(),prnt_2
#define fprintf prnt_1(),prnt_3
#define sprintf prnt_1(),prnt_4

/* Header file for scanf */

#undef scanf
#undef fscanf
#undef sscanf
#define scanf STK_pos(),scan_f
#define fscanf STK_pos(),f_scan
#define sscanf STK_pos(),s_scan

/* DOS defination */

#define dos bdos

_pos(),scan_f
#define fscanf STK_pos(),f_scan
#define sscanf STK_pos(),s_scan

/* DOS defination */

#define dos