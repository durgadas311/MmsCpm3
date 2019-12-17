; MAC.COM module 1

	public	L1200,L1203,L1206,divide
	maclib	m1600
	maclib	m1c00
	maclib	m2100
	maclib	m2580
	maclib	macg

; Module begin L1200
	;org	1200h
	cseg
L1200:	jmp	L1600		;; 0c3h,0,16h
L1203:	jmp	L142d		;; 1203: c3 2d 14    .-.
L1206:	jmp	L131e		;; 1206: c3 1e 13    ...
divide:	jmp	div16		;; 1209: c3 e8 12    ...

L120c:	db	0

; some sort of dual stack/fifo - 10 bytes/entries
L120d:	db	0,0,0,0,0,0,0,0,0,0
L1217:	db	0,0,0,0,0,0,0,0,0,0

; some sort of stack/fifo - 16 bytes/8 words
L1221:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

L1231:	db	0	; L120d "sp"
L1232:	db	0	; L1221 "sp"

; "push" HL into L1221 "fifo stack"
; "stack" wraps after 8 entries...
L1233:	xchg			;; 1233: eb          .
	lxi	h,L1232		;; 1234: 21 32 12    .2.
	mov	a,m		;; 1237: 7e          ~
	cpi	16		;; 1238: fe 10       ..
	jc	L1242		;; 123a: da 42 12    .B.
	call	Eerror		;; 123d: cd e4 15    ...
	mvi	m,0		;; 1240: 36 00       6.
L1242:	mov	a,m		;; 1242: 7e          ~
	inr	m		;; 1243: 34          4
	inr	m		;; 1244: 34          4
	mov	c,a		;; 1245: 4f          O
	mvi	b,0		;; 1246: 06 00       ..
	lxi	h,L1221		;; 1248: 21 21 12    ...
	dad	b		;; 124b: 09          .
	mov	m,e		;; 124c: 73          s
	inx	h		;; 124d: 23          #
	mov	m,d		;; 124e: 72          r
	ret			;; 124f: c9          .

; push bytes onto parallel stacks L120d, L1217
; A => L120d, B => L1217
L1250:	push	psw		;; 1250: f5          .
	lxi	h,L1231		;; 1251: 21 31 12    .1.
	mov	a,m		;; 1254: 7e          ~
	cpi	10		;; 1255: fe 0a       ..
	jc	L125f		;; 1257: da 5f 12    ._.
	mvi	m,0		;; 125a: 36 00       6.
	call	Eerror		;; 125c: cd e4 15    ...
L125f:	mov	e,m		;; 125f: 5e          ^
	mvi	d,0		;; 1260: 16 00       ..
	inr	m		;; 1262: 34          4
	pop	psw		;; 1263: f1          .
	lxi	h,L120d		;; 1264: 21 0d 12    ...
	dad	d		;; 1267: 19          .
	mov	m,a		;; 1268: 77          w
	lxi	h,L1217		;; 1269: 21 17 12    ...
	dad	d		;; 126c: 19          .
	mov	m,b		;; 126d: 70          p
	ret			;; 126e: c9          .

; "pop" HL off L1221 "fifo stack"
L126f:	lxi	h,L1232		;; 126f: 21 32 12    .2.
	mov	a,m		;; 1272: 7e          ~
	ora	a		;; 1273: b7          .
	jnz	L127e		;; 1274: c2 7e 12    .~.
	call	Eerror		;; 1277: cd e4 15    ...
	lxi	h,0		;; 127a: 21 00 00    ...
	ret			;; 127d: c9          .

L127e:	dcr	m		;; 127e: 35          5
	dcr	m		;; 127f: 35          5
	mov	c,m		;; 1280: 4e          N
	mvi	b,0		;; 1281: 06 00       ..
	lxi	h,L1221		;; 1283: 21 21 12    ...
	dad	b		;; 1286: 09          .
	mov	c,m		;; 1287: 4e          N
	inx	h		;; 1288: 23          #
	mov	h,m		;; 1289: 66          f
	mov	l,c		;; 128a: 69          i
	ret			;; 128b: c9          .

L128c:	call	L126f		;; 128c: cd 6f 12    .o.
	xchg			;; 128f: eb          .
	call	L126f		;; 1290: cd 6f 12    .o.
	ret			;; 1293: c9          .

L1294:	mov	l,a		;; 1294: 6f          o
	mvi	h,000h		;; 1295: 26 00       &.
	dad	h		;; 1297: 29          )
	lxi	d,L12a1		;; 1298: 11 a1 12    ...
	dad	d		;; 129b: 19          .
	mov	e,m		;; 129c: 5e          ^
	inx	h		;; 129d: 23          #
	mov	h,m		;; 129e: 66          f
	mov	l,e		;; 129f: 6b          k
	pchl			;; 12a0: e9          .

L12a1:	dw	L1339
	dw	L1342
	dw	L1349
	dw	L134f
	dw	L135b
	dw	L136f
	dw	L1376
	dw	L1380
	dw	L138f
	dw	L139b
	dw	L13a8
	dw	L13b4
	dw	L13bb
	dw	L13c2
	dw	L13da
	dw	L13e1
	dw	L13ed
	dw	L13f9
	dw	L1405
	dw	L140c
	dw	Eerror
L12cb:	call	L128c		;; 12cb: cd 8c 12    ...
	mov	a,d		;; 12ce: 7a          z
	ora	a		;; 12cf: b7          .
	jnz	L12d7		;; 12d0: c2 d7 12    ...
	mov	a,e		;; 12d3: 7b          {
	cpi	011h		;; 12d4: fe 11       ..
	rc			;; 12d6: d8          .
L12d7:	call	Eerror		;; 12d7: cd e4 15    ...
	mvi	a,010h		;; 12da: 3e 10       >.
	ret			;; 12dc: c9          .

L12dd:	xra	a		;; 12dd: af          .
	sub	l		;; 12de: 95          .
	mov	l,a		;; 12df: 6f          o
	mvi	a,000h		;; 12e0: 3e 00       >.
	sbb	h		;; 12e2: 9c          .
	mov	h,a		;; 12e3: 67          g
	ret			;; 12e4: c9          .

L12e5:	call	L128c		;; 12e5: cd 8c 12    ...
; some sort of division operation
div16:	xchg			;; 12e8: eb          .
	shld	L131b		;; 12e9: 22 1b 13    "..
	lxi	h,L131d		;; 12ec: 21 1d 13    ...
	mvi	m,011h		;; 12ef: 36 11       6.
	lxi	b,0		;; 12f1: 01 00 00    ...
	push	b		;; 12f4: c5          .
	xra	a		;; 12f5: af          .
L12f6:	mov	a,e		;; 12f6: 7b          {
	ral			;; 12f7: 17          .
	mov	e,a		;; 12f8: 5f          _
	mov	a,d		;; 12f9: 7a          z
	ral			;; 12fa: 17          .
	mov	d,a		;; 12fb: 57          W
	dcr	m		;; 12fc: 35          5
	pop	h		;; 12fd: e1          .
	rz			;; 12fe: c8          .
	mvi	a,0		;; 12ff: 3e 00       >.
	aci	0		;; 1301: ce 00       ..
	dad	h		;; 1303: 29          )
	mov	b,h		;; 1304: 44          D
	add	l		;; 1305: 85          .
	lhld	L131b		;; 1306: 2a 1b 13    *..
	sub	l		;; 1309: 95          .
	mov	c,a		;; 130a: 4f          O
	mov	a,b		;; 130b: 78          x
	sbb	h		;; 130c: 9c          .
	mov	b,a		;; 130d: 47          G
	push	b		;; 130e: c5          .
	jnc	L1314		;; 130f: d2 14 13    ...
	dad	b		;; 1312: 09          .
	xthl			;; 1313: e3          .
L1314:	lxi	h,L131d		;; 1314: 21 1d 13    ...
	cmc			;; 1317: 3f          ?
	jmp	L12f6		;; 1318: c3 f6 12    ...

L131b:	db	0,0
L131d:	db	0
L131e:	mov	b,h		;; 131e: 44          D
	mov	c,l		;; 131f: 4d          M
	lxi	h,0		;; 1320: 21 00 00    ...
L1323:	xra	a		;; 1323: af          .
	mov	a,b		;; 1324: 78          x
	rar			;; 1325: 1f          .
	mov	b,a		;; 1326: 47          G
	mov	a,c		;; 1327: 79          y
	rar			;; 1328: 1f          .
	mov	c,a		;; 1329: 4f          O
	jc	L1332		;; 132a: da 32 13    .2.
	ora	b		;; 132d: b0          .
	rz			;; 132e: c8          .
	jmp	L1333		;; 132f: c3 33 13    .3.

L1332:	dad	d		;; 1332: 19          .
L1333:	xchg			;; 1333: eb          .
	dad	h		;; 1334: 29          )
	xchg			;; 1335: eb          .
	jmp	L1323		;; 1336: c3 23 13    .#.

L1339:	call	L128c		;; 1339: cd 8c 12    ...
	call	L131e		;; 133c: cd 1e 13    ...
	jmp	L1411		;; 133f: c3 11 14    ...

L1342:	call	L12e5		;; 1342: cd e5 12    ...
	xchg			;; 1345: eb          .
	jmp	L1411		;; 1346: c3 11 14    ...

L1349:	call	L12e5		;; 1349: cd e5 12    ...
	jmp	L1411		;; 134c: c3 11 14    ...

L134f:	call	L12cb		;; 134f: cd cb 12    ...
L1352:	ora	a		;; 1352: b7          .
	jz	L1411		;; 1353: ca 11 14    ...
	dad	h		;; 1356: 29          )
	dcr	a		;; 1357: 3d          =
	jmp	L1352		;; 1358: c3 52 13    .R.

L135b:	call	L12cb		;; 135b: cd cb 12    ...
L135e:	ora	a		;; 135e: b7          .
	jz	L1411		;; 135f: ca 11 14    ...
	push	psw		;; 1362: f5          .
	xra	a		;; 1363: af          .
	mov	a,h		;; 1364: 7c          |
	rar			;; 1365: 1f          .
	mov	h,a		;; 1366: 67          g
	mov	a,l		;; 1367: 7d          }
	rar			;; 1368: 1f          .
	mov	l,a		;; 1369: 6f          o
	pop	psw		;; 136a: f1          .
	dcr	a		;; 136b: 3d          =
	jmp	L135e		;; 136c: c3 5e 13    .^.

L136f:	call	L128c		;; 136f: cd 8c 12    ...
L1372:	dad	d		;; 1372: 19          .
	jmp	L1411		;; 1373: c3 11 14    ...

L1376:	call	L128c		;; 1376: cd 8c 12    ...
	xchg			;; 1379: eb          .
	call	L12dd		;; 137a: cd dd 12    ...
	jmp	L1372		;; 137d: c3 72 13    .r.

L1380:	call	L126f		;; 1380: cd 6f 12    .o.
L1383:	call	L12dd		;; 1383: cd dd 12    ...
	jmp	L1411		;; 1386: c3 11 14    ...

L1389:	mov	a,d		;; 1389: 7a          z
	cmp	h		;; 138a: bc          .
	rnz			;; 138b: c0          .
	mov	a,e		;; 138c: 7b          {
	cmp	l		;; 138d: bd          .
	ret			;; 138e: c9          .

L138f:	call	L128c		;; 138f: cd 8c 12    ...
	call	L1389		;; 1392: cd 89 13    ...
	jnz	L13d4		;; 1395: c2 d4 13    ...
	jmp	L13ce		;; 1398: c3 ce 13    ...

L139b:	call	L128c		;; 139b: cd 8c 12    ...
L139e:	mov	a,l		;; 139e: 7d          }
	sub	e		;; 139f: 93          .
	mov	a,h		;; 13a0: 7c          |
	sbb	d		;; 13a1: 9a          .
	jc	L13ce		;; 13a2: da ce 13    ...
	jmp	L13d4		;; 13a5: c3 d4 13    ...

L13a8:	call	L128c		;; 13a8: cd 8c 12    ...
L13ab:	call	L1389		;; 13ab: cd 89 13    ...
	jz	L13ce		;; 13ae: ca ce 13    ...
	jmp	L139e		;; 13b1: c3 9e 13    ...

L13b4:	call	L128c		;; 13b4: cd 8c 12    ...
	xchg			;; 13b7: eb          .
	jmp	L139e		;; 13b8: c3 9e 13    ...

L13bb:	call	L128c		;; 13bb: cd 8c 12    ...
	xchg			;; 13be: eb          .
	jmp	L13ab		;; 13bf: c3 ab 13    ...

L13c2:	call	L128c		;; 13c2: cd 8c 12    ...
	call	L1389		;; 13c5: cd 89 13    ...
	jnz	L13ce		;; 13c8: c2 ce 13    ...
	jmp	L13d4		;; 13cb: c3 d4 13    ...

L13ce:	lxi	h,0ffffh	;; 13ce: 21 ff ff    ...
	jmp	L1411		;; 13d1: c3 11 14    ...

L13d4:	lxi	h,0		;; 13d4: 21 00 00    ...
	jmp	L1411		;; 13d7: c3 11 14    ...

L13da:	call	L126f		;; 13da: cd 6f 12    .o.
	inx	h		;; 13dd: 23          #
	jmp	L1383		;; 13de: c3 83 13    ...

L13e1:	call	L128c		;; 13e1: cd 8c 12    ...
	mov	a,d		;; 13e4: 7a          z
	ana	h		;; 13e5: a4          .
	mov	h,a		;; 13e6: 67          g
	mov	a,e		;; 13e7: 7b          {
	ana	l		;; 13e8: a5          .
	mov	l,a		;; 13e9: 6f          o
	jmp	L1411		;; 13ea: c3 11 14    ...

L13ed:	call	L128c		;; 13ed: cd 8c 12    ...
	mov	a,d		;; 13f0: 7a          z
	ora	h		;; 13f1: b4          .
	mov	h,a		;; 13f2: 67          g
	mov	a,e		;; 13f3: 7b          {
	ora	l		;; 13f4: b5          .
	mov	l,a		;; 13f5: 6f          o
	jmp	L1411		;; 13f6: c3 11 14    ...

L13f9:	call	L128c		;; 13f9: cd 8c 12    ...
	mov	a,d		;; 13fc: 7a          z
	xra	h		;; 13fd: ac          .
	mov	h,a		;; 13fe: 67          g
	mov	a,e		;; 13ff: 7b          {
	xra	l		;; 1400: ad          .
	mov	l,a		;; 1401: 6f          o
	jmp	L1411		;; 1402: c3 11 14    ...

L1405:	call	L126f		;; 1405: cd 6f 12    .o.
	mov	l,h		;; 1408: 6c          l
	jmp	L140f		;; 1409: c3 0f 14    ...

L140c:	call	L126f		;; 140c: cd 6f 12    .o.
L140f:	mvi	h,000h		;; 140f: 26 00       &.
L1411:	jmp	L1233		;; 1411: c3 33 12    .3.

endstm:	lda	L3005		;; 1414: 3a 05 30    :.0
	cpi	004h		;; 1417: fe 04       ..
	rnz			;; 1419: c0          .
	lda	L3009		;; 141a: 3a 09 30    :.0
	cpi	cr		;; 141d: fe 0d       ..
	rz			;; 141f: c8          .
	cpi	';'		;; 1420: fe 3b       .;
	rz			;; 1422: c8          .
	cpi	'!'		;; 1423: fe 21       ..
	ret			;; 1425: c9          .

endtok:	call	endstm		;; 1426: cd 14 14    ...
	rz			;; 1429: c8          .
	cpi	','		;; 142a: fe 2c       .,
	ret			;; 142c: c9          .

L142d:	xra	a		;; 142d: af          .
	sta	L1231		;; 142e: 32 31 12    21.
	sta	L1232		;; 1431: 32 32 12    22.
	dcr	a		;; 1434: 3d          =
	sta	L120c		;; 1435: 32 0c 12    2..
	lxi	h,0		;; 1438: 21 00 00    ...
	shld	L3049		;; 143b: 22 49 30    "I0
L143e:	call	endtok		;; 143e: cd 26 14    .&.
	jnz	L1471		;; 1441: c2 71 14    .q.
; "pop" something and process it... until empty
L1444:	lxi	h,L1231		;; 1444: 21 31 12    .1.
	mov	a,m		;; 1447: 7e          ~
	ora	a		;; 1448: b7          .
	jz	L145c		;; 1449: ca 5c 14    .\.
	dcr	m		;; 144c: 35          5
	mov	e,a		;; 144d: 5f          _
	dcr	e		;; 144e: 1d          .
	mvi	d,0		;; 144f: 16 00       ..
	lxi	h,L120d		;; 1451: 21 0d 12    ...
	dad	d		;; 1454: 19          .
	mov	a,m		;; 1455: 7e          ~
	call	L1294		;; 1456: cd 94 12    ...
	jmp	L1444		;; 1459: c3 44 14    .D.

L145c:	lda	L1232		;; 145c: 3a 32 12    :2.
	cpi	002h		;; 145f: fe 02       ..
	cnz	Eerror		;; 1461: c4 e4 15    ...
	lda	curerr		;; 1464: 3a 8c 2f    :./
	cpi	' '		;; 1467: fe 20       . 
	rnz			;; 1469: c0          .
	lhld	L1221		;; 146a: 2a 21 12    *..
	shld	L3049		;; 146d: 22 49 30    "I0
	ret			;; 1470: c9          .

; get 1 or 2 chars from L3008 buffer (error if 0 or >2)
L1471:	lda	curerr		;; 1471: 3a 8c 2f    :./
	cpi	' '		;; 1474: fe 20       . 
	jnz	L15d0		;; 1476: c2 d0 15    ...
	lda	L3005		;; 1479: 3a 05 30    :.0
	cpi	003h		;; 147c: fe 03       ..
	jnz	L149d		;; 147e: c2 9d 14    ...
	lda	L3008		;; 1481: 3a 08 30    :.0
	ora	a		;; 1484: b7          .
	cz	Eerror		;; 1485: cc e4 15    ...
	cpi	003h		;; 1488: fe 03       ..
	cnc	Eerror		;; 148a: d4 e4 15    ...
	mvi	d,0		;; 148d: 16 00       ..
	lxi	h,L3009		;; 148f: 21 09 30    ..0
	mov	e,m		;; 1492: 5e          ^
	inx	h		;; 1493: 23          #
	dcr	a		;; 1494: 3d          =
	jz	L1499		;; 1495: ca 99 14    ...
	mov	d,m		;; 1498: 56          V
L1499:	xchg			;; 1499: eb          .
	jmp	L15cd		;; 149a: c3 cd 15    ...

L149d:	cpi	002h		;; 149d: fe 02       ..
	jnz	L14a8		;; 149f: c2 a8 14    ...
	lhld	L3006		;; 14a2: 2a 06 30    *.0
	jmp	L15cd		;; 14a5: c3 cd 15    ...

L14a8:	call	L2106		;; 14a8: cd 06 21    ...
	jnz	L158d		;; 14ab: c2 8d 15    ...
	cpi	019h		;; 14ae: fe 19       ..
	jnc	L1582		;; 14b0: d2 82 15    ...
	cpi	018h		;; 14b3: fe 18       ..
	jnz	L14f1		;; 14b5: c2 f1 14    ...
	call	L160c		;; 14b8: cd 0c 16    ...
	call	endstm		;; 14bb: cd 14 14    ...
	jz	L14e8		;; 14be: ca e8 14    ...
	lda	L3005		;; 14c1: 3a 05 30    :.0
	cpi	003h		;; 14c4: fe 03       ..
	jnz	L14d9		;; 14c6: c2 d9 14    ...
	lda	L3008		;; 14c9: 3a 08 30    :.0
	ora	a		;; 14cc: b7          .
	jnz	L14d9		;; 14cd: c2 d9 14    ...
	call	L1606		;; 14d0: cd 06 16    ...
	call	endtok		;; 14d3: cd 26 14    .&.
	jz	L14e8		;; 14d6: ca e8 14    ...
L14d9:	call	L160c		;; 14d9: cd 0c 16    ...
	call	endstm		;; 14dc: cd 14 14    ...
	jnz	L14d9		;; 14df: c2 d9 14    ...
	lxi	h,0		;; 14e2: 21 00 00    ...
	jmp	L14eb		;; 14e5: c3 eb 14    ...

L14e8:	lxi	h,0ffffh	;; 14e8: 21 ff ff    ...
L14eb:	call	L15d6		;; 14eb: cd d6 15    ...
	jmp	L143e		;; 14ee: c3 3e 14    .>.

L14f1:	cpi	014h		;; 14f1: fe 14       ..
	mov	c,a		;; 14f3: 4f          O
	lda	L120c		;; 14f4: 3a 0c 12    :..
	jnz	L1507		;; 14f7: c2 07 15    ...
	ora	a		;; 14fa: b7          .
	cz	Eerror		;; 14fb: cc e4 15    ...
	mvi	a,0ffh		;; 14fe: 3e ff       >.
	sta	L120c		;; 1500: 32 0c 12    2..
	mov	a,c		;; 1503: 79          y
	jmp	L1555		;; 1504: c3 55 15    .U.

L1507:	ora	a		;; 1507: b7          .
	jnz	L1560		;; 1508: c2 60 15    .`.
L150b:	push	b		;; 150b: c5          .
	lda	L1231		;; 150c: 3a 31 12    :1.
	ora	a		;; 150f: b7          .
	jz	L1530		;; 1510: ca 30 15    .0.
	mov	e,a		;; 1513: 5f          _
	dcr	e		;; 1514: 1d          .
	mvi	d,000h		;; 1515: 16 00       ..
	lxi	h,L1217		;; 1517: 21 17 12    ...
	dad	d		;; 151a: 19          .
	mov	a,m		;; 151b: 7e          ~
	cmp	b		;; 151c: b8          .
	jc	L1530		;; 151d: da 30 15    .0.
	lxi	h,L1231		;; 1520: 21 31 12    .1.
	mov	m,e		;; 1523: 73          s
	lxi	h,L120d		;; 1524: 21 0d 12    ...
	dad	d		;; 1527: 19          .
	mov	a,m		;; 1528: 7e          ~
	call	L1294		;; 1529: cd 94 12    ...
	pop	b		;; 152c: c1          .
	jmp	L150b		;; 152d: c3 0b 15    ...

L1530:	pop	b		;; 1530: c1          .
	mov	a,c		;; 1531: 79          y
	cpi	015h		;; 1532: fe 15       ..
	jnz	L1555		;; 1534: c2 55 15    .U.
	lxi	h,L1231		;; 1537: 21 31 12    .1.
	mov	a,m		;; 153a: 7e          ~
	ora	a		;; 153b: b7          .
	jz	L154e		;; 153c: ca 4e 15    .N.
	dcr	a		;; 153f: 3d          =
	mov	m,a		;; 1540: 77          w
	mov	e,a		;; 1541: 5f          _
	mvi	d,000h		;; 1542: 16 00       ..
	lxi	h,L120d		;; 1544: 21 0d 12    ...
	dad	d		;; 1547: 19          .
	mov	a,m		;; 1548: 7e          ~
	cpi	014h		;; 1549: fe 14       ..
	jz	L1551		;; 154b: ca 51 15    .Q.
L154e:	call	Eerror		;; 154e: cd e4 15    ...
L1551:	xra	a		;; 1551: af          .
	jmp	L155a		;; 1552: c3 5a 15    .Z.

L1555:	call	L1250		;; 1555: cd 50 12    .P.
	mvi	a,0ffh		;; 1558: 3e ff       >.
L155a:	sta	L120c		;; 155a: 32 0c 12    2..
	jmp	L15d0		;; 155d: c3 d0 15    ...

L1560:	mov	a,c		;; 1560: 79          y
	cpi	005h		;; 1561: fe 05       ..
	jz	L15d0		;; 1563: ca d0 15    ...
	cpi	006h		;; 1566: fe 06       ..
	jnz	L1570		;; 1568: c2 70 15    .p.
	inr	a		;; 156b: 3c          <
	mov	c,a		;; 156c: 4f          O
	jmp	L150b		;; 156d: c3 0b 15    ...

L1570:	cpi	00eh		;; 1570: fe 0e       ..
	jz	L150b		;; 1572: ca 0b 15    ...
	cpi	012h		;; 1575: fe 12       ..
	jz	L150b		;; 1577: ca 0b 15    ...
	cpi	013h		;; 157a: fe 13       ..
	cnz	Eerror		;; 157c: c4 e4 15    ...
	jmp	L150b		;; 157f: c3 0b 15    ...

L1582:	cpi	eof		;; 1582: fe 1a       ..
	cz	Eerror		;; 1584: cc e4 15    ...
	mov	l,b		;; 1587: 68          h
	mvi	h,000h		;; 1588: 26 00       &.
	jmp	L15cd		;; 158a: c3 cd 15    ...

L158d:	lda	L3005		;; 158d: 3a 05 30    :.0
	cpi	004h		;; 1590: fe 04       ..
	jnz	L15ac		;; 1592: c2 ac 15    ...
	lda	L3009		;; 1595: 3a 09 30    :.0
	cpi	'$'		;; 1598: fe 24       .$
	jz	L15a6		;; 159a: ca a6 15    ...
	call	Eerror		;; 159d: cd e4 15    ...
	lxi	h,0		;; 15a0: 21 00 00    ...
	jmp	L15cd		;; 15a3: c3 cd 15    ...

L15a6:	lhld	linadr		;; 15a6: 2a 52 30    *R0
	jmp	L15cd		;; 15a9: c3 cd 15    ...

L15ac:	call	L1c06		;; 15ac: cd 06 1c    ...
	call	L1c09		;; 15af: cd 09 1c    ...
	jnz	L15c0		;; 15b2: c2 c0 15    ...
	mvi	a,'P'		;; 15b5: 3e 50       >P
	call	setere		;; 15b7: cd 98 25    ..%
	call	L1c0c		;; 15ba: cd 0c 1c    ...
	jmp	L15ca		;; 15bd: c3 ca 15    ...

L15c0:	call	L1c12		;; 15c0: cd 12 1c    ...
	ani	007h		;; 15c3: e6 07       ..
	mvi	a,'U'		;; 15c5: 3e 55       >U
	cz	setere		;; 15c7: cc 98 25    ..%
L15ca:	call	L1c18		;; 15ca: cd 18 1c    ...
L15cd:	call	L15d6		;; 15cd: cd d6 15    ...
L15d0:	call	L1606		;; 15d0: cd 06 16    ...
	jmp	L143e		;; 15d3: c3 3e 14    .>.

L15d6:	lda	L120c		;; 15d6: 3a 0c 12    :..
	ora	a		;; 15d9: b7          .
	cz	Eerror		;; 15da: cc e4 15    ...
	xra	a		;; 15dd: af          .
	sta	L120c		;; 15de: 32 0c 12    2..
	jmp	L1233		;; 15e1: c3 33 12    .3.

Eerror:	push	h		;; 15e4: e5          .
	mvi	a,'E'		;; 15e5: 3e 45       >E
	call	setere		;; 15e7: cd 98 25    ..%
	pop	h		;; 15ea: e1          .
	ret			;; 15eb: c9          .

	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	end
