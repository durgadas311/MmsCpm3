	org 0100h

	mvi a,23
	sta lcount
	lxi d,005ch
	mvi c,0fh
	call 0005h
	inr a
	jz error
	lxi d,0080h
	mvi c,01ah
	call 0005h
rdloop:
	lxi d,005ch
	mvi c,014h
	call 0005h
	ora a
	jnz done
	lxi h,0080h
	mvi d,080h
outloop:
	mov a,m
	inx h
	cpi 01ah
	jz done
	push h
	push d
	cpi 00ah
	jnz notlf
	mvi e,00dh
	mvi c,002h
	call 0005h
	mvi e,00ah
	mvi c,02h
	call 0005h
	lda	lcount
	dcr a
	sta	lcount
	cz more
	jmp waslf
notlf:
	mov e,a
	mvi c,002h
	call 0005h
waslf:
	pop d
	pop h
	dcr d
	jnz outloop
	jmp rdloop

done0:
	pop	h ; discard return addr
done:
	lxi d,005ch
	mvi c,010h
	call 0005h
	ret

error:
	lxi d,errmsg
	mvi c,09h
	call 0005h
	ret

more:
	mvi a,23
	sta lcount
	lxi d,moremsg
	mvi c,09h
	call 0005h
	mvi c,01h
	call 0005h
	cpi 0003h; Ctrl C
	jnz  clearmsg
	pop h ; ret addr
	pop h ; saved DE
	pop h ; saved HL
	lxi d,crlf
	mvi c,09h
	call 0005h
	jmp done

clearmsg:
	lxi d,clrmsg
	mvi c,09h
	call 0005h
	ret

lcount: db	23
errmsg: db 'No File'
crlf:	db 13, 10, '$'
moremsg: db 'MORE:$'
clrmsg: db 13, '     ',13,'$'

	end
