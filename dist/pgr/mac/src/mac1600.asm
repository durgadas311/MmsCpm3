; MAC.COM - module 2

	public	L1600,L1603,L1606,L1609,L160c
	maclib	m1200
	maclib	m1c00
	maclib	m2100
	maclib	m2580
	maclib	macg

	; patch - hooked in to mac1c00 spare memory
	public	L1652

; Module begin L1600
	; org	1600h
	cseg
L1600:	jmp	L1c00		;; 1600: c3 00 1c    ...
L1603:	jmp	L17f1		;; 1603: c3 f1 17    ...
L1606:	jmp	L18b3		;; 1606: c3 b3 18    ...
L1609:	jmp	L1666		;; 1609: c3 66 16    .f.
L160c:	jmp	L1afc		;; 160c: c3 fc 1a    ...

L160f:	db	1ah
L1610:	db	0,0,0
L1613:	db	0,0,0
L1616:	db	0
L1617:	db	1
L1618:	db	1ah

L1619:	lda	L2ea3		;; 1619: 3a a3 2e    :..
	ora	a		;; 161c: b7          .
	jz	L164f		;; 161d: ca 4f 16    .O.
	lhld	L2ef4		;; 1620: 2a f4 2e    *..
	mov	a,m		;; 1623: 7e          ~
	ora	a		;; 1624: b7          .
	jnz	L1648		;; 1625: c2 48 16    .H.
	lda	L2ea4		;; 1628: 3a a4 2e    :..
	cpi	002h		;; 162b: fe 02       ..
	jz	L163d		;; 162d: ca 3d 16    .=.
	lxi	h,L1618		;; 1630: 21 18 16    ...
	inr	m		;; 1633: 34          4
	mvi	a,000h		;; 1634: 3e 00       >.
	rnz			;; 1636: c0          .
	call	L1be7		;; 1637: cd e7 1b    ...
	call	L2595		;; 163a: cd 95 25    ..%
L163d:	call	L1c30		;; 163d: cd 30 1c    .0.
	lda	L2f14		;; 1640: 3a 14 2f    :./
	ora	a		;; 1643: b7          .
	rnz			;; 1644: c0          .
	jmp	L1619		;; 1645: c3 19 16    ...

L1648:	inx	h		;; 1648: 23          #
	shld	L2ef4		;; 1649: 22 f4 2e    "..
	jmp	L20d8	; divert to patch

L164f:	call	L2586		;; 164f: cd 86 25    ..%
L1652:	sta	L1618		;; 1652: 32 18 16    2..
	mov	b,a		;; 1655: 47          G
	lda	L3005		;; 1656: 3a 05 30    :.0
	cpi	003h		;; 1659: fe 03       ..
	mov	a,b		;; 165b: 78          x
	rz			;; 165c: c8          .
	cpi	'a'		;; 165d: fe 61       .a
	rc			;; 165f: d8          .
	cpi	'z'+1		;; 1660: fe 7b       .{
	rnc			;; 1662: d0          .
	ani	05fh		;; 1663: e6 5f       ._
	ret			;; 1665: c9          .

L1666:	push	psw		;; 1666: f5          .
	cpi	cr		;; 1667: fe 0d       ..
	jz	L1687		;; 1669: ca 87 16    ...
	cpi	lf		;; 166c: fe 0a       ..
	jz	L1687		;; 166e: ca 87 16    ...
	lda	L3004		;; 1671: 3a 04 30    :.0
	cpi	120		;; 1674: fe 78       .x
	jnc	L1687		;; 1676: d2 87 16    ...
	mov	e,a		;; 1679: 5f          _
	mvi	d,000h		;; 167a: 16 00       ..
	inr	a		;; 167c: 3c          <
	sta	L3004		;; 167d: 32 04 30    2.0
	lxi	h,prnbuf	;; 1680: 21 8c 2f    ../
	dad	d		;; 1683: 19          .
	pop	psw		;; 1684: f1          .
	mov	m,a		;; 1685: 77          w
	ret			;; 1686: c9          .

L1687:	pop	psw		;; 1687: f1          .
	ret			;; 1688: c9          .

L1689:	lda	L2f65		;; 1689: 3a 65 2f    :e/
	call	L1853		;; 168c: cd 53 18    .S.
	rnz			;; 168f: c0          .
	lda	L2f65		;; 1690: 3a 65 2f    :e/
	call	L1839		;; 1693: cd 39 18    .9.
	ret			;; 1696: c9          .

L1697:	xra	a		;; 1697: af          .
	sta	L2f66		;; 1698: 32 66 2f    2f/
	sta	L2f64		;; 169b: 32 64 2f    2d/
	call	L1619		;; 169e: cd 19 16    ...
	sta	L2f65		;; 16a1: 32 65 2f    2e/
	lda	L3005		;; 16a4: 3a 05 30    :.0
	cpi	006h		;; 16a7: fe 06       ..
	rz			;; 16a9: c8          .
	lda	L2f65		;; 16aa: 3a 65 2f    :e/
	cpi	128		;; 16ad: fe 80       ..
	jc	L16c6		;; 16af: da c6 16    ...
	call	L210c		;; 16b2: cd 0c 21    ...
	sta	L2f66		;; 16b5: 32 66 2f    2f/
	lxi	d,L2f67		;; 16b8: 11 67 2f    .g/
L16bb:	mov	a,m		;; 16bb: 7e          ~
	stax	d		;; 16bc: 12          .
	inx	h		;; 16bd: 23          #
	inx	d		;; 16be: 13          .
	dcr	b		;; 16bf: 05          .
	jnz	L16bb		;; 16c0: c2 bb 16    ...
	jmp	L16e5		;; 16c3: c3 e5 16    ...

L16c6:	call	L1853		;; 16c6: cd 53 18    .S.
	rz			;; 16c9: c8          .
L16ca:	call	L1689		;; 16ca: cd 89 16    ...
	jz	L16f0		;; 16cd: ca f0 16    ...
	lxi	h,L2f66		;; 16d0: 21 66 2f    .f/
	mov	a,m		;; 16d3: 7e          ~
	cpi	00fh		;; 16d4: fe 0f       ..
	jnc	L16ee		;; 16d6: d2 ee 16    ...
	inr	m		;; 16d9: 34          4
	lxi	h,L2f67		;; 16da: 21 67 2f    .g/
	mov	e,a		;; 16dd: 5f          _
	mvi	d,000h		;; 16de: 16 00       ..
	dad	d		;; 16e0: 19          .
	lda	L2f65		;; 16e1: 3a 65 2f    :e/
	mov	m,a		;; 16e4: 77          w
L16e5:	call	L1619		;; 16e5: cd 19 16    ...
	sta	L2f65		;; 16e8: 32 65 2f    2e/
	jmp	L16ca		;; 16eb: c3 ca 16    ...

L16ee:	xra	a		;; 16ee: af          .
	ret			;; 16ef: c9          .

L16f0:	xra	a		;; 16f0: af          .
	inr	a		;; 16f1: 3c          <
	ret			;; 16f2: c9          .

L16f3:	lhld	cursym		;; 16f3: 2a 56 30    *V0
	shld	L1613		;; 16f6: 22 13 16    "..
	call	L1c33		;; 16f9: cd 33 1c    .3.
	call	L1c36		;; 16fc: cd 36 1c    .6.
	rnz			;; 16ff: c0          .
	lhld	L1613		;; 1700: 2a 13 16    *..
	shld	cursym		;; 1703: 22 56 30    "V0
	ret			;; 1706: c9          .

L1707:	xra	a		;; 1707: af          .
	sta	L1617		;; 1708: 32 17 16    2..
L170b:	lxi	h,L1617		;; 170b: 21 17 16    ...
	inr	m		;; 170e: 34          4
	jnz	L171d		;; 170f: c2 1d 17    ...
	call	L1bdb		;; 1712: cd db 1b    ...
	lxi	h,L2f66		;; 1715: 21 66 2f    .f/
	mvi	m,000h		;; 1718: 36 00       6.
	shld	L2ef4		;; 171a: 22 f4 2e    "..
L171d:	lxi	h,L2f66		;; 171d: 21 66 2f    .f/
	mov	a,m		;; 1720: 7e          ~
	ora	a		;; 1721: b7          .
	jz	L1735		;; 1722: ca 35 17    .5.
	dcr	m		;; 1725: 35          5
	lxi	h,L2f64		;; 1726: 21 64 2f    .d/
	mov	e,m		;; 1729: 5e          ^
	inr	m		;; 172a: 34          4
	mvi	d,000h		;; 172b: 16 00       ..
	lxi	h,L2f67		;; 172d: 21 67 2f    .g/
	dad	d		;; 1730: 19          .
	mov	a,m		;; 1731: 7e          ~
	jmp	L1666		;; 1732: c3 66 16    .f.

L1735:	lda	L2ea3		;; 1735: 3a a3 2e    :..
	ora	a		;; 1738: b7          .
	lda	L2f65		;; 1739: 3a 65 2f    :e/
	jnz	L174a		;; 173c: c2 4a 17    .J.
	mov	b,a		;; 173f: 47          G
	ora	a		;; 1740: b7          .
	jnz	L1777		;; 1741: c2 77 17    .w.
	call	L1619		;; 1744: cd 19 16    ...
	jmp	L1666		;; 1747: c3 66 16    .f.

L174a:	ora	a		;; 174a: b7          .
	jz	L177f		;; 174b: ca 7f 17    ...
	cpi	'^'		;; 174e: fe 5e       .^
	jnz	L176c		;; 1750: c2 6c 17    .l.
	call	L1697		;; 1753: cd 97 16    ...
	mvi	b,'^'		;; 1756: 06 5e       .^
	jnz	L177b		;; 1758: c2 7b 17    .{.
	lda	L2f65		;; 175b: 3a 65 2f    :e/
	cpi	'&'		;; 175e: fe 26       .&
	jnz	L177b		;; 1760: c2 7b 17    .{.
	lxi	h,L2f66		;; 1763: 21 66 2f    .f/
	inr	m		;; 1766: 34          4
	inx	h		;; 1767: 23          #
	mov	m,a		;; 1768: 77          w
	jmp	L1777		;; 1769: c3 77 17    .w.

L176c:	cpi	'&'		;; 176c: fe 26       .&
	jz	L179e		;; 176e: ca 9e 17    ...
	mov	b,a		;; 1771: 47          G
	cpi	del		;; 1772: fe 7f       ..
	jz	L17b1		;; 1774: ca b1 17    ...
L1777:	xra	a		;; 1777: af          .
	sta	L2f65		;; 1778: 32 65 2f    2e/
L177b:	mov	a,b		;; 177b: 78          x
	jmp	L1666		;; 177c: c3 66 16    .f.

L177f:	call	L1697		;; 177f: cd 97 16    ...
	jz	L170b		;; 1782: ca 0b 17    ...
	lda	L2f65		;; 1785: 3a 65 2f    :e/
	cpi	'&'		;; 1788: fe 26       .&
	jz	L1795		;; 178a: ca 95 17    ...
	lda	L3005		;; 178d: 3a 05 30    :.0
	cpi	003h		;; 1790: fe 03       ..
	jz	L170b		;; 1792: ca 0b 17    ...
L1795:	call	L16f3		;; 1795: cd f3 16    ...
	jz	L170b		;; 1798: ca 0b 17    ...
	jmp	L17bd		;; 179b: c3 bd 17    ...

L179e:	call	L1697		;; 179e: cd 97 16    ...
	mvi	b,'&'		;; 17a1: 06 26       .&
	jz	L177b		;; 17a3: ca 7b 17    .{.
	call	L16f3		;; 17a6: cd f3 16    ...
	mvi	b,'&'		;; 17a9: 06 26       .&
	jz	L177b		;; 17ab: ca 7b 17    .{.
	jmp	L17bd		;; 17ae: c3 bd 17    ...

L17b1:	call	L1697		;; 17b1: cd 97 16    ...
	jz	L170b		;; 17b4: ca 0b 17    ...
	call	L16f3		;; 17b7: cd f3 16    ...
	jz	L170b		;; 17ba: ca 0b 17    ...
L17bd:	lxi	h,L2f65		;; 17bd: 21 65 2f    .e/
	mov	a,m		;; 17c0: 7e          ~
	cpi	'&'		;; 17c1: fe 26       .&
	jnz	L17c8		;; 17c3: c2 c8 17    ...
	mvi	a,del		;; 17c6: 3e 7f       >.
L17c8:	mvi	m,0		;; 17c8: 36 00       6.
	sta	L2f14		;; 17ca: 32 14 2f    2./
	call	L1c2d		;; 17cd: cd 2d 1c    .-.
	lxi	h,L2ea4		;; 17d0: 21 a4 2e    ...
	mvi	m,002h		;; 17d3: 36 02       6.
	lhld	memtop		;; 17d5: 2a 4d 30    *M0
	shld	L2f24		;; 17d8: 22 24 2f    "$/
	call	L1c42		;; 17db: cd 42 1c    .B.
	shld	L2ef4		;; 17de: 22 f4 2e    "..
	xra	a		;; 17e1: af          .
	sta	L2f66		;; 17e2: 32 66 2f    2f/
	lhld	L1613		;; 17e5: 2a 13 16    *..
	shld	cursym		;; 17e8: 22 56 30    "V0
	call	L1697		;; 17eb: cd 97 16    ...
	jmp	L170b		;; 17ee: c3 0b 17    ...

L17f1:	call	L180e		;; 17f1: cd 0e 18    ...
	sta	L2f66		;; 17f4: 32 66 2f    2f/
	sta	L2f65		;; 17f7: 32 65 2f    2e/
	sta	L305b		;; 17fa: 32 5b 30    2[0
	sta	L3004		;; 17fd: 32 04 30    2.0
	mvi	a,lf		;; 1800: 3e 0a       >.
	sta	L160f		;; 1802: 32 0f 16    2..
	call	L2595		;; 1805: cd 95 25    ..%
	mvi	a,010h		;; 1808: 3e 10       >.
	sta	L3004		;; 180a: 32 04 30    2.0
	ret			;; 180d: c9          .

L180e:	xra	a		;; 180e: af          .
	sta	L3008		;; 180f: 32 08 30    2.0
	sta	L1610		;; 1812: 32 10 16    2..
	ret			;; 1815: c9          .

L1816:	lxi	h,L3008		;; 1816: 21 08 30    ..0
	mov	a,m		;; 1819: 7e          ~
	cpi	64		;; 181a: fe 40       .@
	jc	L1824		;; 181c: da 24 18    .$.
	mvi	m,0		;; 181f: 36 00       6.
	call	L1bdb		;; 1821: cd db 1b    ...
L1824:	mov	e,m		;; 1824: 5e          ^
	mvi	d,0		;; 1825: 16 00       ..
	inr	m		;; 1827: 34          4
	inx	h		;; 1828: 23          #
	dad	d		;; 1829: 19          .
	lda	L305b		;; 182a: 3a 5b 30    :[0
	mov	m,a		;; 182d: 77          w
	ret			;; 182e: c9          .

L182f:	mov	a,m		;; 182f: 7e          ~
	cpi	'$'		;; 1830: fe 24       .$
	rnz			;; 1832: c0          .
	xra	a		;; 1833: af          .
	mov	m,a		;; 1834: 77          w
	ret			;; 1835: c9          .

; is char '0'-'9'?
L1836:	lda	L305b		;; 1836: 3a 5b 30    :[0
L1839:	sui	'0'		;; 1839: d6 30       .0
	cpi	10		;; 183b: fe 0a       ..
	ral			;; 183d: 17          .
	ani	001h		;; 183e: e6 01       ..
	ret			;; 1840: c9          .

; is char 'A'-'F'?
L1841:	call	L1836		;; 1841: cd 36 18    .6.
	rnz			;; 1844: c0          .
	lda	L305b		;; 1845: 3a 5b 30    :[0
	sui	'A'		;; 1848: d6 41       .A
	cpi	6		;; 184a: fe 06       ..
	ral			;; 184c: 17          .
	ani	001h		;; 184d: e6 01       ..
	ret			;; 184f: c9          .

; is first char of symbol valid?
L1850:	lda	L305b		;; 1850: 3a 5b 30    :[0
L1853:	cpi	'?'		;; 1853: fe 3f       .?
	jz	L1865		;; 1855: ca 65 18    .e.
	cpi	'@'		;; 1858: fe 40       .@
	jz	L1865		;; 185a: ca 65 18    .e.
	sui	'A'		;; 185d: d6 41       .A
	cpi	'Z'-'A'+1		;; 185f: fe 1a       ..
	ral			;; 1861: 17          .
	ani	001h		;; 1862: e6 01       ..
	ret			;; 1864: c9          .

L1865:	ora	a		;; 1865: b7          .
	ret			;; 1866: c9          .

L1867:	call	L1850		;; 1867: cd 50 18    .P.
	rnz			;; 186a: c0          .
	call	L1836		;; 186b: cd 36 18    .6.
	ret			;; 186e: c9          .

; is char end-of-field?
L186f:	cpi	' '		;; 186f: fe 20       . 
	rnc			;; 1871: d0          .
	cpi	tab		;; 1872: fe 09       ..
	rz			;; 1874: c8          .
	cpi	cr		;; 1875: fe 0d       ..
	rz			;; 1877: c8          .
	cpi	lf		;; 1878: fe 0a       ..
	rz			;; 187a: c8          .
	cpi	eof		;; 187b: fe 1a       ..
	rz			;; 187d: c8          .
	jmp	L1be1		;; 187e: c3 e1 1b    ...

L1881:	call	L1707		;; 1881: cd 07 17    ...
	call	L186f		;; 1884: cd 6f 18    .o.
	sta	L305b		;; 1887: 32 5b 30    2[0
	lda	L305a		;; 188a: 3a 5a 30    :Z0
	ora	a		;; 188d: b7          .
	jz	L18a6		;; 188e: ca a6 18    ...
	lda	L305c		;; 1891: 3a 5c 30    :\0
	cpi	001h		;; 1894: fe 01       ..
	jnz	L18a0		;; 1896: c2 a0 18    ...
	lda	pass		;; 1899: 3a 4f 30    :O0
	ora	a		;; 189c: b7          .
	jnz	L18a6		;; 189d: c2 a6 18    ...
L18a0:	lda	L305b		;; 18a0: 3a 5b 30    :[0
	call	L1c27		;; 18a3: cd 27 1c    .'.
L18a6:	lda	L305b		;; 18a6: 3a 5b 30    :[0
	ret			;; 18a9: c9          .

; is char end-of-statement?
L18aa:	cpi	cr		;; 18aa: fe 0d       ..
	rz			;; 18ac: c8          .
	cpi	eof		;; 18ad: fe 1a       ..
	rz			;; 18af: c8          .
	cpi	'!'		;; 18b0: fe 21       ..
	ret			;; 18b2: c9          .

L18b3:	call	L180e		;; 18b3: cd 0e 18    ...
L18b6:	xra	a		;; 18b6: af          .
	sta	L3005		;; 18b7: 32 05 30    2.0
	lda	L305b		;; 18ba: 3a 5b 30    :[0
	cpi	tab		;; 18bd: fe 09       ..
	jz	L1952		;; 18bf: ca 52 19    .R.
	cpi	';'		;; 18c2: fe 3b       .;
	jnz	L192f		;; 18c4: c2 2f 19    ./.
	mvi	a,006h		;; 18c7: 3e 06       >.
	sta	L3005		;; 18c9: 32 05 30    2.0
	lda	L305a		;; 18cc: 3a 5a 30    :Z0
	ora	a		;; 18cf: b7          .
	jz	L193f		;; 18d0: ca 3f 19    .?.
	lda	L305c		;; 18d3: 3a 5c 30    :\0
	cpi	001h		;; 18d6: fe 01       ..
	jnz	L18e2		;; 18d8: c2 e2 18    ...
	lda	pass		;; 18db: 3a 4f 30    :O0
	ora	a		;; 18de: b7          .
	jnz	L193f		;; 18df: c2 3f 19    .?.
L18e2:	call	L1881		;; 18e2: cd 81 18    ...
	cpi	';'		;; 18e5: fe 3b       .;
	jnz	L1942		;; 18e7: c2 42 19    .B.
	lhld	L3060		;; 18ea: 2a 60 30    *`0
	xchg			;; 18ed: eb          .
	lhld	L3058		;; 18ee: 2a 58 30    *X0
	dcx	h		;; 18f1: 2b          +
	dcx	h		;; 18f2: 2b          +
L18f3:	mov	a,e		;; 18f3: 7b          {
	cmp	l		;; 18f4: bd          .
	jnz	L18fd		;; 18f5: c2 fd 18    ...
	mov	a,d		;; 18f8: 7a          z
	cmp	h		;; 18f9: bc          .
	jz	L1911		;; 18fa: ca 11 19    ...
L18fd:	mov	a,m		;; 18fd: 7e          ~
	cpi	lf		;; 18fe: fe 0a       ..
	jnz	L1908		;; 1900: c2 08 19    ...
	dcx	h		;; 1903: 2b          +
	dcx	h		;; 1904: 2b          +
	jmp	L1911		;; 1905: c3 11 19    ...

L1908:	cpi	' '+1		;; 1908: fe 21       ..
	jnc	L1911		;; 190a: d2 11 19    ...
	dcx	h		;; 190d: 2b          +
	jmp	L18f3		;; 190e: c3 f3 18    ...

L1911:	shld	L3058		;; 1911: 22 58 30    "X0
	lda	L305a		;; 1914: 3a 5a 30    :Z0
	push	psw		;; 1917: f5          .
	xra	a		;; 1918: af          .
	sta	L305a		;; 1919: 32 5a 30    2Z0
L191c:	call	L1881		;; 191c: cd 81 18    ...
	call	L18aa		;; 191f: cd aa 18    ...
	jnz	L191c		;; 1922: c2 1c 19    ...
	call	L1c27		;; 1925: cd 27 1c    .'.
	pop	psw		;; 1928: f1          .
	sta	L305a		;; 1929: 32 5a 30    2Z0
	jmp	L1958		;; 192c: c3 58 19    .X.

L192f:	lda	L305b		;; 192f: 3a 5b 30    :[0
	cpi	'*'		;; 1932: fe 2a       .*
	jnz	L194b		;; 1934: c2 4b 19    .K.
	lda	L160f		;; 1937: 3a 0f 16    :..
	cpi	lf		;; 193a: fe 0a       ..
	jnz	L194b		;; 193c: c2 4b 19    .K.
L193f:	call	L1881		;; 193f: cd 81 18    ...
L1942:	call	L18aa		;; 1942: cd aa 18    ...
	jz	L1958		;; 1945: ca 58 19    .X.
	jmp	L193f		;; 1948: c3 3f 19    .?.

L194b:	ori	020h		;; 194b: f6 20       . 
	cpi	020h		;; 194d: fe 20       . 
	jnz	L1958		;; 194f: c2 58 19    .X.
L1952:	call	L1881		;; 1952: cd 81 18    ...
	jmp	L18b6		;; 1955: c3 b6 18    ...

L1958:	xra	a		;; 1958: af          .
	sta	L3005		;; 1959: 32 05 30    2.0
	call	L1850		;; 195c: cd 50 18    .P.
	jz	L1967		;; 195f: ca 67 19    .g.
	mvi	a,001h		;; 1962: 3e 01       >.
	jmp	L19a3		;; 1964: c3 a3 19    ...

L1967:	call	L1836		;; 1967: cd 36 18    .6.
	jz	L1972		;; 196a: ca 72 19    .r.
	mvi	a,002h		;; 196d: 3e 02       >.
	jmp	L19a3		;; 196f: c3 a3 19    ...

L1972:	lda	L305b		;; 1972: 3a 5b 30    :[0
	cpi	''''		;; 1975: fe 27       .'
	jnz	L1983		;; 1977: c2 83 19    ...
	xra	a		;; 197a: af          .
	sta	L305b		;; 197b: 32 5b 30    2[0
	mvi	a,003h		;; 197e: 3e 03       >.
	jmp	L19a3		;; 1980: c3 a3 19    ...

L1983:	cpi	lf		;; 1983: fe 0a       ..
	jnz	L19a1		;; 1985: c2 a1 19    ...
	lda	L2ea3		;; 1988: 3a a3 2e    :..
	ora	a		;; 198b: b7          .
	jz	L1994		;; 198c: ca 94 19    ...
	mvi	a,'+'		;; 198f: 3e 2b       >+
	sta	prnbuf+5	;; 1991: 32 91 2f    2./
L1994:	call	L2595		;; 1994: cd 95 25    ..%
	lxi	h,curerr	;; 1997: 21 8c 2f    ../
	mvi	m,' '		;; 199a: 36 20       6 
	mvi	a,010h		;; 199c: 3e 10       >.
	sta	L3004		;; 199e: 32 04 30    2.0
L19a1:	mvi	a,004h		;; 19a1: 3e 04       >.
L19a3:	sta	L3005		;; 19a3: 32 05 30    2.0
L19a6:	lda	L305b		;; 19a6: 3a 5b 30    :[0
	sta	L160f		;; 19a9: 32 0f 16    2..
	ora	a		;; 19ac: b7          .
	cnz	L1816		;; 19ad: c4 16 18    ...
	call	L1881		;; 19b0: cd 81 18    ...
	lda	L3005		;; 19b3: 3a 05 30    :.0
	cpi	004h		;; 19b6: fe 04       ..
	jnz	L1a06		;; 19b8: c2 06 1a    ...
	lda	L305a		;; 19bb: 3a 5a 30    :Z0
	ora	a		;; 19be: b7          .
	rnz			;; 19bf: c0          .
	lda	L3009		;; 19c0: 3a 09 30    :.0
	cpi	'='		;; 19c3: fe 3d       .=
	jnz	L19ce		;; 19c5: c2 ce 19    ...
	lxi	h,'EQ'		;; 19c8: 21 45 51    .EQ
	jmp	L19f9		;; 19cb: c3 f9 19    ...

L19ce:	cpi	'<'		;; 19ce: fe 3c       .<
	jnz	L19e4		;; 19d0: c2 e4 19    ...
	lxi	h,'LT'		;; 19d3: 21 4c 54    .LT
	lda	L305b		;; 19d6: 3a 5b 30    :[0
	cpi	'='		;; 19d9: fe 3d       .=
	jnz	L19f9		;; 19db: c2 f9 19    ...
	lxi	h,'LE'		;; 19de: 21 4c 45    .LE
	jmp	L19f5		;; 19e1: c3 f5 19    ...

L19e4:	cpi	'>'		;; 19e4: fe 3e       .>
	rnz			;; 19e6: c0          .
	lxi	h,'GT'		;; 19e7: 21 47 54    .GT
	lda	L305b		;; 19ea: 3a 5b 30    :[0
	cpi	'='		;; 19ed: fe 3d       .=
	jnz	L19f9		;; 19ef: c2 f9 19    ...
	lxi	h,'GE'		;; 19f2: 21 47 45    .GE
L19f5:	xra	a		;; 19f5: af          .
	sta	L305b		;; 19f6: 32 5b 30    2[0
L19f9:	shld	L3009		;; 19f9: 22 09 30    ".0
	lxi	h,L3008		;; 19fc: 21 08 30    ..0
	inr	m		;; 19ff: 34          4
	mvi	a,001h		;; 1a00: 3e 01       >.
	sta	L3005		;; 1a02: 32 05 30    2.0
	ret			;; 1a05: c9          .

L1a06:	lxi	h,L305b		;; 1a06: 21 5b 30    .[0
	lda	L3005		;; 1a09: 3a 05 30    :.0
	cpi	001h		;; 1a0c: fe 01       ..
	jnz	L1a1e		;; 1a0e: c2 1e 1a    ...
	call	L182f		;; 1a11: cd 2f 18    ./.
	jz	L19a6		;; 1a14: ca a6 19    ...
	call	L1867		;; 1a17: cd 67 18    .g.
	jnz	L19a6		;; 1a1a: c2 a6 19    ...
	ret			;; 1a1d: c9          .

L1a1e:	cpi	002h		;; 1a1e: fe 02       ..
	jnz	L1ab4		;; 1a20: c2 b4 1a    ...
	call	L182f		;; 1a23: cd 2f 18    ./.
	jz	L19a6		;; 1a26: ca a6 19    ...
	call	L1841		;; 1a29: cd 41 18    .A.
	jnz	L19a6		;; 1a2c: c2 a6 19    ...
	lda	L305b		;; 1a2f: 3a 5b 30    :[0
	cpi	'O'		;; 1a32: fe 4f       .O
	jz	L1a3c		;; 1a34: ca 3c 1a    .<.
	cpi	'Q'		;; 1a37: fe 51       .Q
	jnz	L1a41		;; 1a39: c2 41 1a    .A.
L1a3c:	mvi	a,008h		;; 1a3c: 3e 08       >.
	jmp	L1a48		;; 1a3e: c3 48 1a    .H.

L1a41:	cpi	'H'		;; 1a41: fe 48       .H
	jnz	L1a52		;; 1a43: c2 52 1a    .R.
	mvi	a,010h		;; 1a46: 3e 10       >.
L1a48:	sta	L1610		;; 1a48: 32 10 16    2..
	xra	a		;; 1a4b: af          .
	sta	L305b		;; 1a4c: 32 5b 30    2[0
	jmp	L1a6d		;; 1a4f: c3 6d 1a    .m.

L1a52:	lda	L160f		;; 1a52: 3a 0f 16    :..
	cpi	'B'		;; 1a55: fe 42       .B
	jnz	L1a5f		;; 1a57: c2 5f 1a    ._.
	mvi	a,002h		;; 1a5a: 3e 02       >.
	jmp	L1a66		;; 1a5c: c3 66 1a    .f.

L1a5f:	cpi	'D'		;; 1a5f: fe 44       .D
	mvi	a,lf		;; 1a61: 3e 0a       >.
	jnz	L1a6a		;; 1a63: c2 6a 1a    .j.
L1a66:	lxi	h,L3008		;; 1a66: 21 08 30    ..0
	dcr	m		;; 1a69: 35          5
L1a6a:	sta	L1610		;; 1a6a: 32 10 16    2..
L1a6d:	lxi	h,0		;; 1a6d: 21 00 00    ...
	shld	L3006		;; 1a70: 22 06 30    ".0
	lxi	h,L3008		;; 1a73: 21 08 30    ..0
	mov	c,m		;; 1a76: 4e          N
	inx	h		;; 1a77: 23          #
L1a78:	mov	a,m		;; 1a78: 7e          ~
	inx	h		;; 1a79: 23          #
	cpi	'A'		;; 1a7a: fe 41       .A
	jnc	L1a84		;; 1a7c: d2 84 1a    ...
	sui	'0'		;; 1a7f: d6 30       .0
	jmp	L1a86		;; 1a81: c3 86 1a    ...

L1a84:	sui	'A'-10		;; 1a84: d6 37       .7
L1a86:	push	h		;; 1a86: e5          .
	push	b		;; 1a87: c5          .
	mov	c,a		;; 1a88: 4f          O
	lxi	h,L1610		;; 1a89: 21 10 16    ...
	cmp	m		;; 1a8c: be          .
	cnc	L1bd5		;; 1a8d: d4 d5 1b    ...
	mvi	b,000h		;; 1a90: 06 00       ..
	mov	a,m		;; 1a92: 7e          ~
	lhld	L3006		;; 1a93: 2a 06 30    *.0
	xchg			;; 1a96: eb          .
	lxi	h,0		;; 1a97: 21 00 00    ...
L1a9a:	ora	a		;; 1a9a: b7          .
	jz	L1aa9		;; 1a9b: ca a9 1a    ...
	rar			;; 1a9e: 1f          .
	jnc	L1aa3		;; 1a9f: d2 a3 1a    ...
	dad	d		;; 1aa2: 19          .
L1aa3:	xchg			;; 1aa3: eb          .
	dad	h		;; 1aa4: 29          )
	xchg			;; 1aa5: eb          .
	jmp	L1a9a		;; 1aa6: c3 9a 1a    ...

L1aa9:	dad	b		;; 1aa9: 09          .
	shld	L3006		;; 1aaa: 22 06 30    ".0
	pop	b		;; 1aad: c1          .
	pop	h		;; 1aae: e1          .
	dcr	c		;; 1aaf: 0d          .
	jnz	L1a78		;; 1ab0: c2 78 1a    .x.
	ret			;; 1ab3: c9          .

L1ab4:	lda	L305b		;; 1ab4: 3a 5b 30    :[0
	cpi	cr		;; 1ab7: fe 0d       ..
	jz	L1bdb		;; 1ab9: ca db 1b    ...
	cpi	''''		;; 1abc: fe 27       .'
	jnz	L19a6		;; 1abe: c2 a6 19    ...
	call	L1881		;; 1ac1: cd 81 18    ...
	cpi	''''		;; 1ac4: fe 27       .'
	rnz			;; 1ac6: c0          .
	jmp	L19a6		;; 1ac7: c3 a6 19    ...

L1aca:	lda	L305b		;; 1aca: 3a 5b 30    :[0
	ora	a		;; 1acd: b7          .
	rz			;; 1ace: c8          .
	cpi	' '		;; 1acf: fe 20       . 
	rz			;; 1ad1: c8          .
	cpi	tab		;; 1ad2: fe 09       ..
	ret			;; 1ad4: c9          .

L1ad5:	lda	L305b		;; 1ad5: 3a 5b 30    :[0
	cpi	','		;; 1ad8: fe 2c       .,
	rz			;; 1ada: c8          .
	cpi	';'		;; 1adb: fe 3b       .;
	rz			;; 1add: c8          .
	cpi	'%'		;; 1ade: fe 25       .%
	rz			;; 1ae0: c8          .
L1ae1:	lda	L305b		;; 1ae1: 3a 5b 30    :[0
	cpi	cr		;; 1ae4: fe 0d       ..
	rz			;; 1ae6: c8          .
	cpi	eof		;; 1ae7: fe 1a       ..
	rz			;; 1ae9: c8          .
	cpi	'!'		;; 1aea: fe 21       ..
	ret			;; 1aec: c9          .

L1aed:	lda	L305b		;; 1aed: 3a 5b 30    :[0
	cpi	';'		;; 1af0: fe 3b       .;
	rz			;; 1af2: c8          .
	cpi	' '		;; 1af3: fe 20       . 
	rz			;; 1af5: c8          .
	cpi	tab		;; 1af6: fe 09       ..
	rz			;; 1af8: c8          .
	cpi	','		;; 1af9: fe 2c       .,
	ret			;; 1afb: c9          .

L1afc:	call	L180e		;; 1afc: cd 0e 18    ...
	xra	a		;; 1aff: af          .
	sta	L3005		;; 1b00: 32 05 30    2.0
	sta	L1616		;; 1b03: 32 16 16    2..
L1b06:	call	L1aca		;; 1b06: cd ca 1a    ...
	jnz	L1b12		;; 1b09: c2 12 1b    ...
	call	L1881		;; 1b0c: cd 81 18    ...
	jmp	L1b06		;; 1b0f: c3 06 1b    ...

L1b12:	call	L1ad5		;; 1b12: cd d5 1a    ...
	jnz	L1b2f		;; 1b15: c2 2f 1b    ./.
	mvi	a,004h		;; 1b18: 3e 04       >.
	sta	L3005		;; 1b1a: 32 05 30    2.0
	jmp	L1bc9		;; 1b1d: c3 c9 1b    ...

L1b20:	lda	L305b		;; 1b20: 3a 5b 30    :[0
	sta	L160f		;; 1b23: 32 0f 16    2..
	call	L1881		;; 1b26: cd 81 18    ...
	lda	L3005		;; 1b29: 3a 05 30    :.0
	cpi	004h		;; 1b2c: fe 04       ..
	rz			;; 1b2e: c8          .
L1b2f:	call	L1ae1		;; 1b2f: cd e1 1a    ...
	jnz	L1b47		;; 1b32: c2 47 1b    .G.
	lda	L3005		;; 1b35: 3a 05 30    :.0
	cpi	003h		;; 1b38: fe 03       ..
	cz	L1bd5		;; 1b3a: cc d5 1b    ...
	lda	L1616		;; 1b3d: 3a 16 16    :..
	ora	a		;; 1b40: b7          .
	cnz	L1bd5		;; 1b41: c4 d5 1b    ...
	jmp	L1bcf		;; 1b44: c3 cf 1b    ...

L1b47:	lda	L3005		;; 1b47: 3a 05 30    :.0
	cpi	003h		;; 1b4a: fe 03       ..
	jnz	L1b6c		;; 1b4c: c2 6c 1b    .l.
	lda	L305b		;; 1b4f: 3a 5b 30    :[0
	cpi	''''		;; 1b52: fe 27       .'
	jnz	L1bc9		;; 1b54: c2 c9 1b    ...
	call	L1816		;; 1b57: cd 16 18    ...
	call	L1881		;; 1b5a: cd 81 18    ...
	lda	L305b		;; 1b5d: 3a 5b 30    :[0
	cpi	''''		;; 1b60: fe 27       .'
	jz	L1b20		;; 1b62: ca 20 1b    . .
	xra	a		;; 1b65: af          .
	sta	L3005		;; 1b66: 32 05 30    2.0
	jmp	L1b2f		;; 1b69: c3 2f 1b    ./.

L1b6c:	lda	L305b		;; 1b6c: 3a 5b 30    :[0
	cpi	''''		;; 1b6f: fe 27       .'
	jnz	L1b7c		;; 1b71: c2 7c 1b    .|.
	mvi	a,003h		;; 1b74: 3e 03       >.
	sta	L3005		;; 1b76: 32 05 30    2.0
	jmp	L1bc9		;; 1b79: c3 c9 1b    ...

L1b7c:	cpi	'^'		;; 1b7c: fe 5e       .^
	jnz	L1b97		;; 1b7e: c2 97 1b    ...
	call	L1881		;; 1b81: cd 81 18    ...
	lda	L305b		;; 1b84: 3a 5b 30    :[0
	cpi	tab		;; 1b87: fe 09       ..
	jz	L1bc9		;; 1b89: ca c9 1b    ...
	cpi	' '		;; 1b8c: fe 20       . 
	jnc	L1bc9		;; 1b8e: d2 c9 1b    ...
	call	L1be1		;; 1b91: cd e1 1b    ...
	jmp	L1bcf		;; 1b94: c3 cf 1b    ...

L1b97:	cpi	'<'		;; 1b97: fe 3c       .<
	jnz	L1ba8		;; 1b99: c2 a8 1b    ...
	lxi	h,L1616		;; 1b9c: 21 16 16    ...
	mov	a,m		;; 1b9f: 7e          ~
	inr	m		;; 1ba0: 34          4
	ora	a		;; 1ba1: b7          .
	jz	L1b20		;; 1ba2: ca 20 1b    . .
	jmp	L1bc9		;; 1ba5: c3 c9 1b    ...

L1ba8:	cpi	'>'		;; 1ba8: fe 3e       .>
	jnz	L1bbc		;; 1baa: c2 bc 1b    ...
	lxi	h,L1616		;; 1bad: 21 16 16    ...
	mov	a,m		;; 1bb0: 7e          ~
	ora	a		;; 1bb1: b7          .
	jz	L1bc9		;; 1bb2: ca c9 1b    ...
	dcr	m		;; 1bb5: 35          5
	jz	L1b20		;; 1bb6: ca 20 1b    . .
	jmp	L1bc9		;; 1bb9: c3 c9 1b    ...

L1bbc:	lda	L1616		;; 1bbc: 3a 16 16    :..
	ora	a		;; 1bbf: b7          .
	jnz	L1bc9		;; 1bc0: c2 c9 1b    ...
	call	L1aed		;; 1bc3: cd ed 1a    ...
	jz	L1bcf		;; 1bc6: ca cf 1b    ...
L1bc9:	call	L1816		;; 1bc9: cd 16 18    ...
	jmp	L1b20		;; 1bcc: c3 20 1b    . .

L1bcf:	mvi	a,005h		;; 1bcf: 3e 05       >.
	sta	L3005		;; 1bd1: 32 05 30    2.0
	ret			;; 1bd4: c9          .

L1bd5:	push	psw		;; 1bd5: f5          .
	mvi	a,'V'		;; 1bd6: 3e 56       >V
	jmp	L1bed		;; 1bd8: c3 ed 1b    ...

L1bdb:	push	psw		;; 1bdb: f5          .
	mvi	a,'O'		;; 1bdc: 3e 4f       >O
	jmp	L1bed		;; 1bde: c3 ed 1b    ...

L1be1:	push	psw		;; 1be1: f5          .
	mvi	a,'I'		;; 1be2: 3e 49       >I
	jmp	L1bed		;; 1be4: c3 ed 1b    ...

L1be7:	push	psw		;; 1be7: f5          .
	mvi	a,'B'		;; 1be8: 3e 42       >B
	jmp	L1bed		;; 1bea: c3 ed 1b    ...

L1bed:	push	b		;; 1bed: c5          .
	push	h		;; 1bee: e5          .
	call	setere		;; 1bef: cd 98 25    ..%
	pop	h		;; 1bf2: e1          .
	pop	b		;; 1bf3: c1          .
	pop	psw		;; 1bf4: f1          .
	ret			;; 1bf5: c9          .

	pop	psw		;; 1bf6: f1          .
	ret			;; 1bf7: c9          .

	db	0,0,0,0,0,0,0,0
	end
