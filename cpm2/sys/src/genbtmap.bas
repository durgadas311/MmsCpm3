0 REM: *** CREATES RELOCATION-BIT-MAP FROM CP/M 2.2 FILE ***
1 REM: *** ASSUMES FILES "CPSYS0.COM" AND "CPSYS1.COM"**
2 REM: *** ARE IMAGES OF CP/M AT 0000 AND 0100       ***
100 CLEAR 512
110 L=0:L$="":LL$=" DB "
120 PA=0:AD=0:B$=""
130 LINE INPUT "FILE NAME --";A$
140 INPUT "NUMBER OF RECORDS ";RR
150 E=INSTR(A$,"."):IF E<>0 THEN A$=LEFT$(A$,E-1)
160 OPEN "R",1,A$+"0.COM":OPEN "R",3,A$+"1.COM"
170 OPEN "O",2,A$+".REL"
180 FIELD #1,128 AS A$
190 FIELD #3,128 AS C$
200 FOR X=1 TO RR' RR RECORDS IN PROGRAM
210 GET #1,X
220 GET #3,X
230 FOR Y=1 TO 128
240 IF MID$(A$,Y,1)<>MID$(C$,Y,1) THEN L$=L$+"1" ELSE L$=L$+"0"
250 GOSUB 290
260 NEXT Y
270 NEXT X
280 GOTO 350
290 IF LEN(L$)<8 THEN RETURN
300 IF LEN(LL$)>4 THEN LL$=LL$+","
310 LL$=LL$+LEFT$(L$,8)+"B":L=L+1
320 L$=MID$(L$,9)
330 IF L=8 THEN PRINT #2,LL$:L=0:LL$=" DB "
340 GOTO 290
350 IF LEN(L$)=0 THEN 380
360 IF LEN(L$)<8 THEN L$=L$+"0":GOTO 360
370 GOSUB 290
380 IF LL$<>" DB " THEN L$="00000000":GOTO 370
390 CLOSE
400 SYSTEM
