		;------INITIALISATION---------
		MOV		R10,#0  ;NEGATIVE?
		
		MOV		R1,#0x10 ;1st and 2nd
		MOV		R0,#0x01 ;3rd and 4th
		ADD		R1,R0,R1,LSL #8
		MOV		R0,#0x00 ;5th and 6h
		ADD		R1,R0,R1,LSL #8
		;PUT		MANTISSA HERE - note: do not put in the 1 in the msb position
		;range	- 0x0 (1) to 0xFFFFFE (1.1111...111)
		
		MOV		R0,#0 ;PUT EXP HERE (MAX 128, min -127) (256 range since the highest representable number is 255 and 0 is also a number)
		;-----------------------------
		
		ADD		R0,R0,#127
		
		ADD		R2,R2,R0, LSL #23
		
		MOV		R4, #-1 ;COUNTER
		MOV		R5, #0x1000000 ;1 in bit number 23
		CMP		R1,#0
		BEQ		ENDOF
		
LOOP		LSR		R5,R5,#1
		ADD		R4,R4,#1
		TST		R1,R5
		BEQ		LOOP
		MVN		R5,R5
		AND		R1,R1,R5 ;remove msb
ENDOF	ADD		R2,R2,R1 , LSL R4 ;exponent
		ADD		R2,R2,R10, ROR #1 ;(OR LSL #31)
