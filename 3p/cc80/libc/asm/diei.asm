; May 10, 1984	09:28  drm  "DIEI.ASM"

; routines to disable/enable interupts from "C"

	public DISINT,ENAINT

disint: di
	ret

enaint: ei
	ret

	end
