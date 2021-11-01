; May 24, 1983	13:36  drm  "LPTBL.ASM"
;
; Logical Physical drive table for MP/M
;

	public @lptbl

	dseg	; common memory
@lptbl:
	db	255	;Drive A:
	db	255	;Drive B:
	db	255	;Drive C:
	db	255	;Drive D:
	db	255	;Drive E:
	db	255	;Drive F:
	db	255	;Drive G:
	db	255	;Drive H:
	db	255	;Drive I:
	db	255	;Drive J:
	db	255	;Drive K:
	db	255	;Drive L:
	db	255	;Drive M:
	db	255	;Drive N:
	db	255	;Drive O:
	db	255	;Drive P:

	end
