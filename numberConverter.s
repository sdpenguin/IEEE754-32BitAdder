		MOVS		R1,#1   ;PUT NUMBER HERE - note the MSB will be removed
		MOV		R0,#0 ;PUT MANTISSA HERE (MAX 128, min -127) (256 range since the highest representable number is 255 and 0 is also a number)
		ADD		R0,R0,#127
		
		ADD		R2,R2,R0, LSL #23
		
		MOV		R4, #-2 ;COUNTER
		MOV		R5, #0x800000 ;1 in bit number 23
		BEQ		ENDOF
LOOP		LSR		R5,R5,#1
		ADD		R4,R4,#1
		TST		R1,R5
		BEQ		LOOP
		MVN		R5,R5
		AND		R1,R1,R5 ;Essentially remove the MSB
ENDOF	ADD		R2,R2,R1, LSL R4
