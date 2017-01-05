			MOV		R0,#0x40000000
			MOV		R1,#0x00000001
			BL		IEEE754MULT
			END
			
IEEE754MULT
			;SETUP
			STMED	R13!,{R0,R1,R3-R12,LR}
			MOV		R4,#0xFF ;AND MASK FOR EXPONENENT
			MOV		R5,#0xFFFFFF
			LSR		R5,R5,#1 ;AND MASK FOR MANTISSA
			MOV		R8,#1
			
			;R10		will store the sign
			MOV		R10,R0,LSR #31
			EOR		R10,R10,R1, LSR #31 ;contains sign bit inLSB position
			
			;MULTIPLICATION	into R2-R3
			STMED	R13!,{R0,R1}
			LSL		R0,R0,#9
			LSR		R0,R0,#9
			ADD		R0,R0,R8, LSL #23 ;add in a 1 for pre-multiplication preparation
			LSL		R1,R1,#9
			LSR		R1,R1,#9
			ADD		R1,R1,R8, LSL #23
			BL		MUL24X24 ;multiply R0 and R1, store in R2-3
			LDMED	R13!,{R0,R1} ;Keep R0 and R1
			
			;ADD		ON ADDITIONAL EXPONENT FOR THRESHOLD stored in R9 by subroutine and also produces the mantissa in R2
			BL		ADDITEXPON
			AND		R2,R2,R5 ;take only the first 23 bits (cut off the 1 in the 24th bit (2^23))
			ADD		R7,R7,R9 ;add on any necessary extra to R7
			
			;R7		will store the summed exponent
			AND		R7,R4,R1, LSR #23
			CMP		R6,#255 ;Max threshold - we do the second one first because it takes presedence according to the testbench
			MOVGT	R2,R1
			BGT		NOTANUMBER
			AND		R6,R4,R0, LSR #23
			CMP		R6,#255 ;Max threshold
			MOVGT	R2,R0
			BGT		NOTANUMBER
			SUB		R7,R7,#127 ;equivalent to taking away 127 for each and then adding 127
			ADD		R7,R6,R7	;R6 stores the result
			
			;THRESHOLDS
			CMP		R7,#0 ;min threshold
			MOVLT	R7,#0 ;make the mantissa as small as possible
			MOVLT	R2,#0 ;make the significand/mantissa zero (as small as possible)
			CMP		R7,#255 ;Max threshold
			MOVGT	R7,#255
			
			;BRING	IT ALL TOGETHER
			ADD		R2,R2,R7, LSL #23 ;23 -> smallest one is in the 24th bit
			ADD		R2,R2,R10, LSL #31 ;was in the LSB, now in the MSB
			
NOTANUMBER	LDMED	R13!,{R0,R1,R3-R12,PC}
			
MUL24X24		STMED	R13!,{R0,R1,R4,R5,LR}
			MOVS		R4,#-1
			MOV		R2,#0x0
			MOV		R3,#0x0
ADDER		RSB		R5,R4,#32
			ADDSPL	R2,R2,R0,LSL R4
			ADC		R3,R3,R0,LSR R5
LOOP			LSRS		R1,R1,#1
			ADD		R4,R4,#1
			BLCS		ADDER
			BNE		LOOP
			LDMED	R13!,{R0,R1,R4,R5,PC}
			
			
ADDITEXPON	STMED	R13!,{R0,R1,R3-R8,R10,LR}
			MOV		R0,#0xFF
			ADD		R0,R0,#0x100
			LSL		R0,R0, #23 ;This mask checks whether all the bits are zero yet during the loop
			MOV		R12,#0
LOOP2		LSRS		R3,R3,#1
			RRX		R2,R2
			ADD		R12,R12,#1
			CMP		R12,#22
			BNE		LOOP2 ;shifts 22 times to the right
			;now		must check whether there are extra bits (i.e. check whether there is a bit in place no. 26)
			;set		overflow to 1 if there is
			;then	check the 1st bit to see if it is greater or equal to 8 (round up)
			;then	shift and add 1 to the overflow if so, otherwise just shift
			TST		R2,R8
			MOV		R9,#0
			LSR		R2,R2,#1
			ADDNE	R2,R2,#1
			TST		R2,R8, LSL #26
			MOVNE	R9,#2
			LSRNE	R2,R2,#2
			TST		R2,R8,LSL #25
			MOVNE	R9,#1
			LSRNE	R2,R2,#1
			LDMED	R13!,{R0,R1,R3-R8,R10,PC}
			;TODO	RSR #31 both numbers and check whether the reult
			;is		negative or positive using EOR (1 and 0 gives negative)
