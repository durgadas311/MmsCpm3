/*
 * Low-level I2C routines for I2C bus on NC-89.
 */

/* what to add to I2C adr for reading */
#define I2C_RD		0x01

extern int i2cinit();	/* (void) */
extern int i2cstart();	/* (void) */
extern int i2cstop();	/* (void) */
extern int i2cput();	/* (char dat) */
extern int i2cget();	/* returns byte recvd */
