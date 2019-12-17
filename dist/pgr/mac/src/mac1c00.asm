; MAC.COM - module 3
M1C00	equ	1

	public	L1c00,L1c03,L1c06,L1c09,L1c0c,L1c0f,L1c12,L1c15,L1c18,L1c1b,L1c1e,L1c21
	public	L1c24,L1c27,L1c2a,L1c2d,L1c30,L1c33,L1c36,L1c39,L1c3c,L1c3f,L1c42,L1c45
	public	L1c48,L1c4b
	maclib	m1200
	maclib	m1600
	maclib	m2100
	maclib	m2580
	maclib	macg

	; patch - hooked in here in unused memory...
	public	L20d8
	extrn	L1652,L11e2

; Module begin L1c00
	;org	1c00h
	cseg
L1c00:	jmp	L2100		;; 1c00: c3 00 21    ...
L1c03:	jmp	L1d51		;; 1c03: c3 51 1d    .Q.
L1c06:	jmp	L1ea9		;; 1c06: c3 a9 1e    ...
L1c09:	jmp	L1e89		;; 1c09: c3 89 1e    ...
L1c0c:	jmp	L1f02		;; 1c0c: c3 02 1f    ...
L1c0f:	jmp	L2012		;; 1c0f: c3 12 20    .. 
L1c12:	jmp	L2024		;; 1c12: c3 24 20    .$ 
L1c15:	jmp	L203f		;; 1c15: c3 3f 20    .? 
L1c18:	jmp	L2048		;; 1c18: c3 48 20    .H 
L1c1b:	jmp	L2059		;; 1c1b: c3 59 20    .Y 
L1c1e:	jmp	L2060		;; 1c1e: c3 60 20    .` 
L1c21:	jmp	L2065		;; 1c21: c3 65 20    .e 
L1c24:	jmp	L2092		;; 1c24: c3 92 20    .. 
L1c27:	jmp	L20bc		;; 1c27: c3 bc 20    .. 
L1c2a:	jmp	L20b2		;; 1c2a: c3 b2 20    .. 
L1c2d:	jmp	L1d7e		;; 1c2d: c3 7e 1d    .~.
L1c30:	jmp	L1dc5		;; 1c30: c3 c5 1d    ...
L1c33:	jmp	L1e8f		;; 1c33: c3 8f 1e    ...
L1c36:	jmp	L1e47		;; 1c36: c3 47 1e    .G.
L1c39:	jmp	L1f87		;; 1c39: c3 87 1f    ...
L1c3c:	jmp	L1fa5		;; 1c3c: c3 a5 1f    ...
L1c3f:	jmp	L1fbb		;; 1c3f: c3 bb 1f    ...
L1c42:	jmp	L1ff0		;; 1c42: c3 f0 1f    ...
L1c45:	jmp	L1ef8		;; 1c45: c3 f8 1e    ...
L1c48:	jmp	L1e1a		;; 1c48: c3 1a 1e    ...
L1c4b:	jmp	L1d66		;; 1c4b: c3 66 1d    .f.

L1c4e:	db	44h,3fh,0b2h,3ch,1eh,3dh,0c7h,3dh,0a1h,3ah,0,0,65h,3eh,0,0,3fh,3bh,20h,3eh
	db	0,0,3ch,3eh,89h,3bh,20h,3ch,59h,3dh,32h,3dh,3,3eh,0e8h,3bh,0fah,3ch,0,0,0,0,0b7h
	db	3dh,0,0,52h,3eh,0dch,3eh,0e5h,3eh,0,0,0,0,46h,3eh,0dch,3bh,0,0,9ch
	db	3eh,47h,3dh,0,0,0,0,0,0,0,0,93h,3dh,0c6h,3ch,15h,3dh,0,0,0aeh,3dh
	db	91h,3eh,0beh,3dh,0,0,0,0,0,0,0,0,73h,3bh,0a5h,3dh,50h,3dh,0,0,0,0,0,0
	db	2ah,3eh,4,3dh,24h,3fh,50h,3ah,2dh,3fh,5dh,3eh,2ah,3ch,15h,3ch,0,0,81h,3dh,8ah,3dh,0,0,0e5h,3ch
	db	0ffh,3bh,0,0,9ch,3dh,81h,3eh,89h,3eh,79h,3eh,0ah,3ch,55h,3ch,0feh,3ah,3fh,3ch,6bh,3ch
	db	0ddh,3ah,0f4h,3bh,0,0,0,0,0,0,0c6h,3eh,0,0,0,0,0,0,9,3bh
	db	0e8h,3ah,0dh,3dh,93h,3bh,0fbh,3eh,5,3fh,0,0,0,0,0eeh,3eh,50h,3fh,0
	db	0,0aah,3ch,0f9h,3dh,1ah,3fh,0b2h,3eh,0bch,3eh,0efh,3dh,0,0
	db	0dbh,3ch,0d1h,3ch,0,0,69h,3bh,0,0,0,0,0,0,0,0,0,0,0,0,6dh,3dh,16h
	db	3eh,0,0,0,0,63h,3dh,0e5h,3dh,0a8h,3eh,6fh,3eh,76h,3ch,0dbh,3dh,0bch,3ch
	db	0a8h,3bh,38h,3fh
L1d4e:	db	1
L1d4f:	dw	L1c4e
L1d51:	lxi	h,L1c4e		;; 1d51: 21 4e 1c    .N.
	mvi	b,080h		;; 1d54: 06 80       ..
	xra	a		;; 1d56: af          .
L1d57:	mov	m,a		;; 1d57: 77          w
	inx	h		;; 1d58: 23          #
	mov	m,a		;; 1d59: 77          w
	inx	h		;; 1d5a: 23          #
	dcr	b		;; 1d5b: 05          .
	jnz	L1d57		;; 1d5c: c2 57 1d    .W.
	lxi	h,0		;; 1d5f: 21 00 00    ...
	shld	cursym		;; 1d62: 22 56 30    "V0
	ret			;; 1d65: c9          .

L1d66:	lxi	h,L2e83		;; 1d66: 21 83 2e    ...
	mvi	b,010h		;; 1d69: 06 10       ..
	xra	a		;; 1d6b: af          .
L1d6c:	mov	m,a		;; 1d6c: 77          w
	inx	h		;; 1d6d: 23          #
	mov	m,a		;; 1d6e: 77          w
	inx	h		;; 1d6f: 23          #
	dcr	b		;; 1d70: 05          .
	jnz	L1d6c		;; 1d71: c2 6c 1d    .l.
	ret			;; 1d74: c9          .

	call	L1e1a		;; 1d75: cd 1a 1e    ...
	ani	00fh		;; 1d78: e6 0f       ..
	sta	L1d4e		;; 1d7a: 32 4e 1d    2N.
	ret			;; 1d7d: c9          .

L1d7e:	lxi	h,L2ea3		;; 1d7e: 21 a3 2e    ...
	mov	a,m		;; 1d81: 7e          ~
	cpi	00fh		;; 1d82: fe 0f       ..
	jnc	L1e15		;; 1d84: d2 15 1e    ...
	inr	m		;; 1d87: 34          4
	mov	e,m		;; 1d88: 5e          ^
	mvi	d,000h		;; 1d89: 16 00       ..
	lxi	h,L2ea4		;; 1d8b: 21 a4 2e    ...
	mov	a,m		;; 1d8e: 7e          ~
	dad	d		;; 1d8f: 19          .
	mov	m,a		;; 1d90: 77          w
	lxi	h,L2ed4		;; 1d91: 21 d4 2e    ...
	call	L1dbc		;; 1d94: cd bc 1d    ...
	lxi	h,L2eb4		;; 1d97: 21 b4 2e    ...
	call	L1dbc		;; 1d9a: cd bc 1d    ...
	lxi	h,L2ef4		;; 1d9d: 21 f4 2e    ...
	call	L1dbc		;; 1da0: cd bc 1d    ...
	lxi	h,L2f14		;; 1da3: 21 14 2f    ../
	mov	a,m		;; 1da6: 7e          ~
	dad	d		;; 1da7: 19          .
	mov	m,a		;; 1da8: 77          w
	lxi	h,L2f24		;; 1da9: 21 24 2f    .$/
	call	L1dbc		;; 1dac: cd bc 1d    ...
	lxi	h,L2f44		;; 1daf: 21 44 2f    .D/
	mov	a,m		;; 1db2: 7e          ~
	dad	d		;; 1db3: 19          .
	mov	m,a		;; 1db4: 77          w
	lxi	h,L2f54		;; 1db5: 21 54 2f    .T/
	mov	a,m		;; 1db8: 7e          ~
	dad	d		;; 1db9: 19          .
	mov	m,a		;; 1dba: 77          w
	ret			;; 1dbb: c9          .

L1dbc:	mov	c,m		;; 1dbc: 4e          N
	inx	h		;; 1dbd: 23          #
	mov	b,m		;; 1dbe: 46          F
	dad	d		;; 1dbf: 19          .
	dad	d		;; 1dc0: 19          .
	mov	m,b		;; 1dc1: 70          p
	dcx	h		;; 1dc2: 2b          +
	mov	m,c		;; 1dc3: 71          q
	ret			;; 1dc4: c9          .

L1dc5:	lxi	h,L2ea3		;; 1dc5: 21 a3 2e    ...
	mov	a,m		;; 1dc8: 7e          ~
	ora	a		;; 1dc9: b7          .
	jz	L1e15		;; 1dca: ca 15 1e    ...
	push	h		;; 1dcd: e5          .
	mov	e,m		;; 1dce: 5e          ^
	mvi	d,000h		;; 1dcf: 16 00       ..
	lxi	h,L2ea4		;; 1dd1: 21 a4 2e    ...
	call	L1e04		;; 1dd4: cd 04 1e    ...
	lxi	h,L2ed4		;; 1dd7: 21 d4 2e    ...
	call	L1e0a		;; 1dda: cd 0a 1e    ...
	lxi	h,L2eb4		;; 1ddd: 21 b4 2e    ...
	call	L1e0a		;; 1de0: cd 0a 1e    ...
	lxi	h,L2ef4		;; 1de3: 21 f4 2e    ...
	call	L1e0a		;; 1de6: cd 0a 1e    ...
	lxi	h,L2f14		;; 1de9: 21 14 2f    ../
	call	L1e04		;; 1dec: cd 04 1e    ...
	lxi	h,L2f24		;; 1def: 21 24 2f    .$/
	call	L1e0a		;; 1df2: cd 0a 1e    ...
	lxi	h,L2f44		;; 1df5: 21 44 2f    .D/
	call	L1e04		;; 1df8: cd 04 1e    ...
	lxi	h,L2f54		;; 1dfb: 21 54 2f    .T/
	call	L1e04		;; 1dfe: cd 04 1e    ...
	pop	h		;; 1e01: e1          .
	dcr	m		;; 1e02: 35          5
	ret			;; 1e03: c9          .

L1e04:	push	h		;; 1e04: e5          .
	dad	d		;; 1e05: 19          .
	mov	a,m		;; 1e06: 7e          ~
	pop	h		;; 1e07: e1          .
	mov	m,a		;; 1e08: 77          w
	ret			;; 1e09: c9          .

L1e0a:	push	h		;; 1e0a: e5          .
	dad	d		;; 1e0b: 19          .
	dad	d		;; 1e0c: 19          .
	mov	c,m		;; 1e0d: 4e          N
	inx	h		;; 1e0e: 23          #
	mov	b,m		;; 1e0f: 46          F
	pop	h		;; 1e10: e1          .
	mov	m,c		;; 1e11: 71          q
	inx	h		;; 1e12: 23          #
	mov	m,b		;; 1e13: 70          p
	ret			;; 1e14: c9          .

L1e15:	mvi	a,'B'		;; 1e15: 3e 42       >B
	jmp	setere		;; 1e17: c3 98 25    ..%

L1e1a:	lxi	h,L3008		;; 1e1a: 21 08 30    ..0
	shld	L20d6		;; 1e1d: 22 d6 20    ". 
L1e20:	lhld	L20d6		;; 1e20: 2a d6 20    *. 
	mov	b,m		;; 1e23: 46          F
	xra	a		;; 1e24: af          .
L1e25:	inx	h		;; 1e25: 23          #
	add	m		;; 1e26: 86          .
	dcr	b		;; 1e27: 05          .
	jnz	L1e25		;; 1e28: c2 25 1e    .%.
	ani	07fh		;; 1e2b: e6 7f       ..
	sta	L1d4e		;; 1e2d: 32 4e 1d    2N.
	ret			;; 1e30: c9          .

	mov	b,a		;; 1e31: 47          G
	lhld	cursym		;; 1e32: 2a 56 30    *V0
	inx	h		;; 1e35: 23          #
	inx	h		;; 1e36: 23          #
	mov	a,m		;; 1e37: 7e          ~
	ani	0f0h		;; 1e38: e6 f0       ..
	ora	b		;; 1e3a: b0          .
	mov	m,a		;; 1e3b: 77          w
	ret			;; 1e3c: c9          .

L1e3d:	lhld	cursym		;; 1e3d: 2a 56 30    *V0
	inx	h		;; 1e40: 23          #
	inx	h		;; 1e41: 23          #
	mov	a,m		;; 1e42: 7e          ~
	ani	00fh		;; 1e43: e6 0f       ..
	inr	a		;; 1e45: 3c          <
	ret			;; 1e46: c9          .

L1e47:	call	L1e89		;; 1e47: cd 89 1e    ...
	rz			;; 1e4a: c8          .
	xchg			;; 1e4b: eb          .
	lxi	b,0		;; 1e4c: 01 00 00    ...
	lda	L2ea4		;; 1e4f: 3a a4 2e    :..
	cpi	001h		;; 1e52: fe 01       ..
	jz	L1e74		;; 1e54: ca 74 1e    .t.
	lxi	h,L2ea3		;; 1e57: 21 a3 2e    ...
	mov	c,m		;; 1e5a: 4e          N
	mvi	b,000h		;; 1e5b: 06 00       ..
	lxi	h,L2ea4		;; 1e5d: 21 a4 2e    ...
	dad	b		;; 1e60: 09          .
L1e61:	mov	a,c		;; 1e61: 79          y
	ora	a		;; 1e62: b7          .
	jz	L1e71		;; 1e63: ca 71 1e    .q.
	mov	a,m		;; 1e66: 7e          ~
	cpi	001h		;; 1e67: fe 01       ..
	jz	L1e74		;; 1e69: ca 74 1e    .t.
	dcx	b		;; 1e6c: 0b          .
	dcx	h		;; 1e6d: 2b          +
	jmp	L1e61		;; 1e6e: c3 61 1e    .a.

L1e71:	inr	a		;; 1e71: 3c          <
	xchg			;; 1e72: eb          .
	ret			;; 1e73: c9          .

L1e74:	lxi	h,L2f24		;; 1e74: 21 24 2f    .$/
	dad	b		;; 1e77: 09          .
	dad	b		;; 1e78: 09          .
	mov	a,e		;; 1e79: 7b          {
	sub	m		;; 1e7a: 96          .
	mov	a,d		;; 1e7b: 7a          z
	inx	h		;; 1e7c: 23          #
	sbb	m		;; 1e7d: 9e          .
	jc	L1e89		;; 1e7e: da 89 1e    ...
	lxi	h,0		;; 1e81: 21 00 00    ...
	shld	cursym		;; 1e84: 22 56 30    "V0
	xra	a		;; 1e87: af          .
	ret			;; 1e88: c9          .

L1e89:	lhld	cursym		;; 1e89: 2a 56 30    *V0
	mov	a,l		;; 1e8c: 7d          }
	ora	h		;; 1e8d: b4          .
	ret			;; 1e8e: c9          .

L1e8f:	lxi	h,L2f66		;; 1e8f: 21 66 2f    .f/
	shld	L20d6		;; 1e92: 22 d6 20    ". 
	call	L1e20		;; 1e95: cd 20 1e    . .
	lda	L1d4e		;; 1e98: 3a 4e 1d    :N.
	ani	00fh		;; 1e9b: e6 0f       ..
	sta	L1d4e		;; 1e9d: 32 4e 1d    2N.
	lxi	h,L2e83		;; 1ea0: 21 83 2e    ...
	shld	L1d4f		;; 1ea3: 22 4f 1d    "O.
	jmp	L1eb8		;; 1ea6: c3 b8 1e    ...

L1ea9:	call	L1e1a		;; 1ea9: cd 1a 1e    ...
	lxi	h,L1c4e		;; 1eac: 21 4e 1c    .N.
	shld	L1d4f		;; 1eaf: 22 4f 1d    "O.
	lxi	h,L3008		;; 1eb2: 21 08 30    ..0
	shld	L20d6		;; 1eb5: 22 d6 20    ". 
L1eb8:	lhld	L20d6		;; 1eb8: 2a d6 20    *. 
	mov	a,m		;; 1ebb: 7e          ~
	cpi	011h		;; 1ebc: fe 11       ..
	jc	L1ec3		;; 1ebe: da c3 1e    ...
	mvi	m,010h		;; 1ec1: 36 10       6.
L1ec3:	lxi	h,L1d4e		;; 1ec3: 21 4e 1d    .N.
	mov	e,m		;; 1ec6: 5e          ^
	mvi	d,000h		;; 1ec7: 16 00       ..
	lhld	L1d4f		;; 1ec9: 2a 4f 1d    *O.
	dad	d		;; 1ecc: 19          .
	dad	d		;; 1ecd: 19          .
	mov	e,m		;; 1ece: 5e          ^
	inx	h		;; 1ecf: 23          #
	mov	h,m		;; 1ed0: 66          f
	mov	l,e		;; 1ed1: 6b          k
L1ed2:	shld	cursym		;; 1ed2: 22 56 30    "V0
	call	L1e89		;; 1ed5: cd 89 1e    ...
	rz			;; 1ed8: c8          .
	call	L1e3d		;; 1ed9: cd 3d 1e    .=.
	lhld	L20d6		;; 1edc: 2a d6 20    *. 
	cmp	m		;; 1edf: be          .
	jnz	L1ef8		;; 1ee0: c2 f8 1e    ...
	mov	b,a		;; 1ee3: 47          G
	inx	h		;; 1ee4: 23          #
	xchg			;; 1ee5: eb          .
	lhld	cursym		;; 1ee6: 2a 56 30    *V0
	inx	h		;; 1ee9: 23          #
	inx	h		;; 1eea: 23          #
	inx	h		;; 1eeb: 23          #
L1eec:	ldax	d		;; 1eec: 1a          .
	cmp	m		;; 1eed: be          .
	jnz	L1ef8		;; 1eee: c2 f8 1e    ...
	inx	d		;; 1ef1: 13          .
	inx	h		;; 1ef2: 23          #
	dcr	b		;; 1ef3: 05          .
	jnz	L1eec		;; 1ef4: c2 ec 1e    ...
	ret			;; 1ef7: c9          .

L1ef8:	lhld	cursym		;; 1ef8: 2a 56 30    *V0
	mov	e,m		;; 1efb: 5e          ^
	inx	h		;; 1efc: 23          #
	mov	d,m		;; 1efd: 56          V
	xchg			;; 1efe: eb          .
	jmp	L1ed2		;; 1eff: c3 d2 1e    ...

L1f02:	lxi	h,L3008		;; 1f02: 21 08 30    ..0
	mov	e,m		;; 1f05: 5e          ^
	mvi	d,000h		;; 1f06: 16 00       ..
	lhld	L304b		;; 1f08: 2a 4b 30    *K0
	shld	cursym		;; 1f0b: 22 56 30    "V0
	dad	d		;; 1f0e: 19          .
	lxi	d,5		;; 1f0f: 11 05 00    ...
	dad	d		;; 1f12: 19          .
	xchg			;; 1f13: eb          .
	lhld	memtop		;; 1f14: 2a 4d 30    *M0
	mov	a,e		;; 1f17: 7b          {
	sub	l		;; 1f18: 95          .
	mov	a,d		;; 1f19: 7a          z
	sbb	h		;; 1f1a: 9c          .
	xchg			;; 1f1b: eb          .
	jnc	L1ff3		;; 1f1c: d2 f3 1f    ...
	shld	L304b		;; 1f1f: 22 4b 30    "K0
	lxi	h,L1c4e		;; 1f22: 21 4e 1c    .N.
	shld	L1d4f		;; 1f25: 22 4f 1d    "O.
	call	L1f31		;; 1f28: cd 31 1f    .1.
	xra	a		;; 1f2b: af          .
	inx	h		;; 1f2c: 23          #
	mov	m,a		;; 1f2d: 77          w
	inx	h		;; 1f2e: 23          #
	mov	m,a		;; 1f2f: 77          w
	ret			;; 1f30: c9          .

L1f31:	lhld	cursym		;; 1f31: 2a 56 30    *V0
	xchg			;; 1f34: eb          .
	lxi	h,L1d4e		;; 1f35: 21 4e 1d    .N.
	mov	c,m		;; 1f38: 4e          N
	mvi	b,000h		;; 1f39: 06 00       ..
	lhld	L1d4f		;; 1f3b: 2a 4f 1d    *O.
	dad	b		;; 1f3e: 09          .
	dad	b		;; 1f3f: 09          .
	mov	c,m		;; 1f40: 4e          N
	inx	h		;; 1f41: 23          #
	mov	b,m		;; 1f42: 46          F
	mov	m,d		;; 1f43: 72          r
	dcx	h		;; 1f44: 2b          +
	mov	m,e		;; 1f45: 73          s
	xchg			;; 1f46: eb          .
	mov	m,c		;; 1f47: 71          q
	inx	h		;; 1f48: 23          #
	mov	m,b		;; 1f49: 70          p
	lxi	d,L3008		;; 1f4a: 11 08 30    ..0
	ldax	d		;; 1f4d: 1a          .
	cpi	011h		;; 1f4e: fe 11       ..
	jc	L1f55		;; 1f50: da 55 1f    .U.
	mvi	a,010h		;; 1f53: 3e 10       >.
L1f55:	mov	b,a		;; 1f55: 47          G
	dcr	a		;; 1f56: 3d          =
	inx	h		;; 1f57: 23          #
	mov	m,a		;; 1f58: 77          w
L1f59:	inx	h		;; 1f59: 23          #
	inx	d		;; 1f5a: 13          .
	ldax	d		;; 1f5b: 1a          .
	mov	m,a		;; 1f5c: 77          w
	dcr	b		;; 1f5d: 05          .
	jnz	L1f59		;; 1f5e: c2 59 1f    .Y.
	ret			;; 1f61: c9          .

L1f62:	lhld	memtop		;; 1f62: 2a 4d 30    *M0
	xchg			;; 1f65: eb          .
	lxi	h,L3008		;; 1f66: 21 08 30    ..0
	mov	l,m		;; 1f69: 6e          n
	mvi	h,000h		;; 1f6a: 26 00       &.
	dad	b		;; 1f6c: 09          .
	mov	a,e		;; 1f6d: 7b          {
	sub	l		;; 1f6e: 95          .
	mov	l,a		;; 1f6f: 6f          o
	mov	a,d		;; 1f70: 7a          z
	sbb	h		;; 1f71: 9c          .
	mov	h,a		;; 1f72: 67          g
	shld	cursym		;; 1f73: 22 56 30    "V0
	xchg			;; 1f76: eb          .
	lxi	h,L304b		;; 1f77: 21 4b 30    .K0
	mov	a,e		;; 1f7a: 7b          {
	sub	m		;; 1f7b: 96          .
	inx	h		;; 1f7c: 23          #
	mov	a,d		;; 1f7d: 7a          z
	sbb	m		;; 1f7e: 9e          .
	jc	L1ff3		;; 1f7f: da f3 1f    ...
	xchg			;; 1f82: eb          .
	shld	memtop		;; 1f83: 22 4d 30    "M0
	ret			;; 1f86: c9          .

L1f87:	lxi	b,1		;; 1f87: 01 01 00    ...
	call	L1f62		;; 1f8a: cd 62 1f    .b.
	lhld	memtop		;; 1f8d: 2a 4d 30    *M0
	xchg			;; 1f90: eb          .
	lxi	h,L3008		;; 1f91: 21 08 30    ..0
	mov	c,m		;; 1f94: 4e          N
L1f95:	inx	h		;; 1f95: 23          #
	mov	a,c		;; 1f96: 79          y
	ora	a		;; 1f97: b7          .
	jz	L1fa2		;; 1f98: ca a2 1f    ...
	dcr	c		;; 1f9b: 0d          .
	mov	a,m		;; 1f9c: 7e          ~
	stax	d		;; 1f9d: 12          .
	inx	d		;; 1f9e: 13          .
	jmp	L1f95		;; 1f9f: c3 95 1f    ...

L1fa2:	xra	a		;; 1fa2: af          .
	stax	d		;; 1fa3: 12          .
	ret			;; 1fa4: c9          .

L1fa5:	lxi	b,3		;; 1fa5: 01 03 00    ...
	call	L1f62		;; 1fa8: cd 62 1f    .b.
	lxi	h,L2e83		;; 1fab: 21 83 2e    ...
	shld	L1d4f		;; 1fae: 22 4f 1d    "O.
	call	L1f31		;; 1fb1: cd 31 1f    .1.
	lda	L1d4e		;; 1fb4: 3a 4e 1d    :N.
	call	L2012		;; 1fb7: cd 12 20    .. 
	ret			;; 1fba: c9          .

L1fbb:	lhld	memtop		;; 1fbb: 2a 4d 30    *M0
	xchg			;; 1fbe: eb          .
	lxi	h,L2f24		;; 1fbf: 21 24 2f    .$/
	mov	a,e		;; 1fc2: 7b          {
	sub	m		;; 1fc3: 96          .
	inx	h		;; 1fc4: 23          #
	mov	a,d		;; 1fc5: 7a          z
	sbb	m		;; 1fc6: 9e          .
	rnc			;; 1fc7: d0          .
	xchg			;; 1fc8: eb          .
	shld	cursym		;; 1fc9: 22 56 30    "V0
	call	L2024		;; 1fcc: cd 24 20    .$ 
	mov	e,a		;; 1fcf: 5f          _
	mvi	d,000h		;; 1fd0: 16 00       ..
	lxi	h,L2e83		;; 1fd2: 21 83 2e    ...
	dad	d		;; 1fd5: 19          .
	dad	d		;; 1fd6: 19          .
	xchg			;; 1fd7: eb          .
	lhld	cursym		;; 1fd8: 2a 56 30    *V0
	mov	a,m		;; 1fdb: 7e          ~
	stax	d		;; 1fdc: 12          .
	inx	h		;; 1fdd: 23          #
	mov	a,m		;; 1fde: 7e          ~
	inx	d		;; 1fdf: 13          .
	stax	d		;; 1fe0: 12          .
	call	L2031		;; 1fe1: cd 31 20    .1 
L1fe4:	mov	a,m		;; 1fe4: 7e          ~
	ora	a		;; 1fe5: b7          .
	inx	h		;; 1fe6: 23          #
	jnz	L1fe4		;; 1fe7: c2 e4 1f    ...
	shld	memtop		;; 1fea: 22 4d 30    "M0
	jmp	L1fbb		;; 1fed: c3 bb 1f    ...

L1ff0:	jmp	L2031		;; 1ff0: c3 31 20    .1 

L1ff3:	lxi	h,L1ffc		;; 1ff3: 21 fc 1f    ...
	call	msgcre		;; 1ff6: cd 92 25    ..%
	jmp	hexfne		;; 1ff9: c3 9e 25    ..%

L1ffc:	db	'SYMBOL TABLE OVERFLOW',0dh
L2012:	ral			;; 2012: 17          .
	ral			;; 2013: 17          .
	ral			;; 2014: 17          .
	ral			;; 2015: 17          .
	ani	0f0h		;; 2016: e6 f0       ..
	mov	b,a		;; 2018: 47          G
	lhld	cursym		;; 2019: 2a 56 30    *V0
	inx	h		;; 201c: 23          #
	inx	h		;; 201d: 23          #
	mov	a,m		;; 201e: 7e          ~
	ani	00fh		;; 201f: e6 0f       ..
	ora	b		;; 2021: b0          .
	mov	m,a		;; 2022: 77          w
	ret			;; 2023: c9          .

L2024:	lhld	cursym		;; 2024: 2a 56 30    *V0
	inx	h		;; 2027: 23          #
	inx	h		;; 2028: 23          #
	mov	a,m		;; 2029: 7e          ~
	rar			;; 202a: 1f          .
	rar			;; 202b: 1f          .
	rar			;; 202c: 1f          .
	rar			;; 202d: 1f          .
	ani	00fh		;; 202e: e6 0f       ..
	ret			;; 2030: c9          .

L2031:	call	L1e3d		;; 2031: cd 3d 1e    .=.
	lhld	cursym		;; 2034: 2a 56 30    *V0
	mov	e,a		;; 2037: 5f          _
	mvi	d,000h		;; 2038: 16 00       ..
	dad	d		;; 203a: 19          .
	inx	h		;; 203b: 23          #
	inx	h		;; 203c: 23          #
	inx	h		;; 203d: 23          #
	ret			;; 203e: c9          .

L203f:	push	h		;; 203f: e5          .
	call	L2031		;; 2040: cd 31 20    .1 
	pop	d		;; 2043: d1          .
	mov	m,e		;; 2044: 73          s
	inx	h		;; 2045: 23          #
	mov	m,d		;; 2046: 72          r
	ret			;; 2047: c9          .

L2048:	call	L2031		;; 2048: cd 31 20    .1 
	mov	e,m		;; 204b: 5e          ^
	inx	h		;; 204c: 23          #
	mov	d,m		;; 204d: 56          V
	xchg			;; 204e: eb          .
	ret			;; 204f: c9          .

L2050:	call	L2031		;; 2050: cd 31 20    .1 
	inx	h		;; 2053: 23          #
	inx	h		;; 2054: 23          #
	shld	L3058		;; 2055: 22 58 30    "X0
	ret			;; 2058: c9          .

L2059:	push	psw		;; 2059: f5          .
	call	L2050		;; 205a: cd 50 20    .P 
	pop	psw		;; 205d: f1          .
	mov	m,a		;; 205e: 77          w
	ret			;; 205f: c9          .

L2060:	call	L2050		;; 2060: cd 50 20    .P 
	mov	a,m		;; 2063: 7e          ~
	ret			;; 2064: c9          .

L2065:	call	L1e1a		;; 2065: cd 1a 1e    ...
	ani	00fh		;; 2068: e6 0f       ..
	add	a		;; 206a: 87          .
	add	a		;; 206b: 87          .
	add	a		;; 206c: 87          .
	add	a		;; 206d: 87          .
	mov	c,a		;; 206e: 4f          O
	lxi	h,L3008		;; 206f: 21 08 30    ..0
	mov	a,m		;; 2072: 7e          ~
	cpi	011h		;; 2073: fe 11       ..
	jc	L207a		;; 2075: da 7a 20    .z 
	mvi	m,010h		;; 2078: 36 10       6.
L207a:	mov	a,m		;; 207a: 7e          ~
	dcr	a		;; 207b: 3d          =
	ora	c		;; 207c: b1          .
	call	L20bc		;; 207d: cd bc 20    .. 
	lxi	h,L3008		;; 2080: 21 08 30    ..0
	mov	c,m		;; 2083: 4e          N
L2084:	inx	h		;; 2084: 23          #
	mov	a,m		;; 2085: 7e          ~
	push	b		;; 2086: c5          .
	push	h		;; 2087: e5          .
	call	L20bc		;; 2088: cd bc 20    .. 
	pop	h		;; 208b: e1          .
	pop	b		;; 208c: c1          .
	dcr	c		;; 208d: 0d          .
	jnz	L2084		;; 208e: c2 84 20    .. 
	ret			;; 2091: c9          .

L2092:	call	L20b2		;; 2092: cd b2 20    .. 
	mov	c,a		;; 2095: 4f          O
	rlc			;; 2096: 07          .
	rlc			;; 2097: 07          .
	rlc			;; 2098: 07          .
	rlc			;; 2099: 07          .
	ani	00fh		;; 209a: e6 0f       ..
	sta	L1d4e		;; 209c: 32 4e 1d    2N.
	mov	a,c		;; 209f: 79          y
	ani	00fh		;; 20a0: e6 0f       ..
	inr	a		;; 20a2: 3c          <
	mov	c,a		;; 20a3: 4f          O
	lxi	d,L3008		;; 20a4: 11 08 30    ..0
	stax	d		;; 20a7: 12          .
L20a8:	call	L20b2		;; 20a8: cd b2 20    .. 
	inx	d		;; 20ab: 13          .
	stax	d		;; 20ac: 12          .
	dcr	c		;; 20ad: 0d          .
	jnz	L20a8		;; 20ae: c2 a8 20    .. 
	ret			;; 20b1: c9          .

L20b2:	lhld	L3058		;; 20b2: 2a 58 30    *X0
	inx	h		;; 20b5: 23          #
	shld	L3058		;; 20b6: 22 58 30    "X0
	mov	a,m		;; 20b9: 7e          ~
	ret			;; 20ba: c9          .

	ret			;; 20bb: c9          .

L20bc:	mov	c,a		;; 20bc: 4f          O
	lhld	L3058		;; 20bd: 2a 58 30    *X0
	inx	h		;; 20c0: 23          #
	xchg			;; 20c1: eb          .
	lhld	memtop		;; 20c2: 2a 4d 30    *M0
	mov	a,e		;; 20c5: 7b          {
	sub	l		;; 20c6: 95          .
	mov	a,d		;; 20c7: 7a          z
	sbb	h		;; 20c8: 9c          .
	jnc	L1ff3		;; 20c9: d2 f3 1f    ...
	xchg			;; 20cc: eb          .
	shld	L3058		;; 20cd: 22 58 30    "X0
	mov	m,c		;; 20d0: 71          q
	inx	h		;; 20d1: 23          #
	shld	L304b		;; 20d2: 22 4b 30    "K0
	ret			;; 20d5: c9          .

L20d6:	dw	022ebh

; patch - fix ???
L20d8:	cpi	','		;; 20d8: fe 2c       .,
	jnz	L1652		;; 20da: c2 52 16    .R.
	shld	L11e2		;; 20dd: 22 e2 11    "..
	jmp	L1652		;; 20e0: c3 52 16    .R.

	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0dah,96h,7,0dh,0cah,96h,7,0c3h,80h
	db	7,0,0,0,0,0,0
	end
