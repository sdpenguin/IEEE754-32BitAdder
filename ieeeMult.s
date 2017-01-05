			MOV		R0, #0xFFFFFFFF
			
IEEE754MULT
			STMED	R13!,{R0,R1,R3-R12}
			MOV		R3,#0xFF ;AND MASK FOR EXPONENENT
			MOV		R4,#0xFFFFFF
			LSR		R4,R4,#1 ;AND MASK FOR MANTISSA
			AND		R5,R3,R0, LSR #23
			AND		R6,R3,R1, LSR #23
			SUB		R6,R6,#127 ;equivalent to taking away 127 for each and then adding 127
			ADD		R6,R5,R6	;R6 stores the result
			CMP		R6,#0 ;min threshold
			MOVLT	R6,#0
			CMP		R6,#255 ;Max threshold
			MOVGT	R6,#255
			MOV		R9,R0,LSR #31
			AND		R9,R9,R1, LSR #31 ;contains sign bit
			LSL		R0,#9
			LSR		R0,#9
			LSL		R1,#9
			LSR		R1,#9
			;NEED TO STORE OVERFLOW IN MULTLOOP
MULTLOOP		
			
			;TODO	RSR #31 both numbers and check whether the reult
			;is		negative or positive using EOR (1 and 0 gives negative)
