/*
 * Low level I2C/OLED bit-banging
 */
#define PORT	80h

#define I2C_CLK	04h
#define DS_CE	10h
#define SS_WEN	20h
#define SS_WD	80h
#define SS_WDN	7fh

#asm
@ctl	db	0
@dly2:	call	@dly1
@dly1:	ret
#endasm
static char std = 0;

int i2cinit()
{
#asm
	mvi	a,SS_WEN+I2C_CLK;
	sta	@ctl
	out	PORT
#endasm
}

int i2cstart()
{
	if (std) return 0;
#asm
	lda	@ctl
	ani	not SS_WEN
	ori	SS_WD
	out	PORT
	call	@dly2
	ani	SS_WDN
	out	PORT
	ani	not I2C_CLK
	out	PORT
	sta	@ctl
#endasm
	std = 0xff;
}

int i2cstop()
{
	if (!std) return;
#asm
	lda	@ctl
	ani	not SS_WEN
	ani	SS_WDN
	ori	I2C_CLK
	out	PORT
	ori	SS_WD
	out	PORT
	ori	SS_WEN
	out	PORT
	sta	@ctl
#endasm
	std = 0;
}

/*
 * caller has already done START and issued I2C adr and ctl.
 * caller is responsible for STOP.
 */
int i2cput(dat)
char dat;
{
#asm
	lxi	h,2
	dad	sp
	mov	d,m
	lda	@ctl
	ani	not SS_WEN
	out	PORT
	mov	c,a
	mvi	b,8
i2cp1:
	ral
	mov	c,a
	mov	a,d
	ral
	mov	d,a
	mov	a,c
	rar
	out	PORT
	ori	I2C_CLK
	out	PORT
	ani	not I2C_CLK
	out	PORT
	dcr	b
	jnz	i2cp1
	ori	SS_WEN
	out	PORT
	ori	I2C_CLK
	out	PORT
	push	psw
	in	PORT
	ani	1
	mov	l,a
	pop	psw
	ani	not I2C_CLK
	out	PORT
	sta	@ctl
	mvi	h,0
#endasm
}

/* UNTESTED! SSD1306 does not allow reading */
/*
 * caller has already done START and issued I2C adr and ctl.
 * caller is responsible for STOP.
 */
int i2cget()
{
#asm
	lxi	h,0
	lda	@ctl
	ori	SS_WEN
	out	PORT
	mvi	b,8
i2cp1:
	ori	I2C_CLK
	out	PORT
	push	psw
	in	PORT
	rar
	mov	a,l
	ral
	mov	l,a
	pop	psw
	ani	not I2C_CLK
	out	PORT
	dcr	b
	jnz	i2cp1
	ani	not SS_WEN
	ani	SS_WDN
	out	PORT
	ori	I2C_CLK
	out	PORT
	ani	not I2C_CLK
	out	PORT
	sta	@ctl
#endasm
}
