			MOV		R0,#0x3F
			LSL		R0,R0,#8
			ADD		R0,R0,#0x45
			LSL		R0,R0,#8
			ADD		R0,R0,#0x67
			LSL		R0,R0,#8
			ADD		R0,R0,#0x89
			MOV		R1,#0x40000000
			BL		IEEE754MULT
			END
			
IEEE754MULT
			
			STMED	R13!,{R0,R1,R3-R12,LR}
			
			MOV		R4,#0xFF ;AND MASK FOR EXPONENT
			MOV		R5,#0xFFFFFF
			LSR		R5,R5,#1 ;AND MASK FOR MANTISSA
			MOV		R8,#1
			
			;STORE	EXPONENTS
			AND		R6,R4,R0, LSR #23
			AND		R7,R4,R1, LSR #23
			
			;STORE	SIGNS
			MOV		R11,R0,LSR #31
			MOV		R12,R1, LSR #31 ;contains sign bit in LSB position
			
			;STORE	MANTISSAS
			LSL		R9,R0,#9
			LSR		R9,R9,#9 ;R9 stores the mantissa of R0
			LSL		R10,R1,#9
			LSR		R10,R10,#9 ;R10 stores the mantissa of R1
			
			;SPECIAL	CHECKS
NANCHECK1		CMP		R7,#0xFF ;Max threshold - we do the second one (R7) first because it takes presedence according to the testbench (not a number case)
			BNE		NANCHECK2
			CMP		R10,#0
			MOVNE	R2,R1
			BNE		DONE
			
NANCHECK2		CMP		R6,#0xFF ;Max threshold
			BNE		CHECK1
			CMP		R9,#0
			MOVNE	R2,R0
			BNE		DONE
			
CHECK1		CMP		R6,#0
			BNE		CHECK2
			CMP		R9,#0
			BNE		CHECK2 ;we now enter zero territory - otherwise this may have been denormal
			CMP		R7,#0xFF
			MOVEQ	R2,#0xFFC00000
			BEQ		DONE
			MOVNE	R2,#0x0
			BNE		SIGNING
CHECK2		CMP		R7,#0
			BNE		CHECK3
			CMP		R10,#0
			BNE		CHECK3 ;we now enter zero territory - otherwise this may have been denormal
			CMP		R6,#0xFF
			MOVEQ	R2,#0xFFC00000
			BEQ		DONE
			MOVNE	R2,#0x0
			BNE		SIGNING
CHECK3		CMP		R7,#0xFF
			BNE		CHECK4
			MOVEQ	R2,#0xFF
			LSLEQ	R2,R2,#23 ;0x7F800000
			BEQ		SIGNING
CHECK4		CMP		R6,#0xFF
			BNE		DENORMALCHECK
			MOVEQ	R2,#0xFF
			LSLEQ	R2,R2,#23 ;0x7F800000
			BEQ		SIGNING
			
DENORMALCHECK
			;From	now on can use R1,R0
			MOV		R0,R9
			MOV		R1,R10
			
			MOV		R9,#22 ;counters
			MOV		R10,#22
			
TESTR6		CMP		R6,#0 ;compare exponent to zero
			BNE		NORMALR6
DENORMR6		TST		R0,R8, LSL R9
			SUBEQ	R9,R9,#1
			BEQ		DENORMR6
			RSB		R9,R9,#23
			LSL		R0,R0,R9
			B		TESTR7
NORMALR6		ADD		R0,R0,R8, LSL #23 ;add in a 1 for pre-multiplication preparation only if the mantissa is not 0
			MOV		R9,#0
TESTR7		CMP		R7,#0
			BNE		NORMALR7
			TST		R0,R8, LSL R10
			SUBEQ	R10,R10,#1
			BEQ		DENORMR6
			RSB		R10,R10,#23
			LSL		R1,R1,R10
			B		ENDDENORMAL
NORMALR7		ADDNE	R1,R1,R8, LSL #23
			MOV		R10,#0
ENDDENORMAL
			
			;MULTIPLICATION
			BL		MUL24X24
			
			;R7		will store the summed exponent
			SUB		R7,R7,#127 ;equivalent to taking away 127 for each and then adding 127
			ADD		R7,R6,R7	;R6 stores the result
			
			SUB		R7,R7,R9
			SUB		R7,R7,R10
			
			CMP		R7,#-1
			BGT		EXPONENTDEBT
			BEQ		SKIPDENLOOP
			MOV		R6,#0
DENORMALRET	ADD		R7,R7,#1
			LSRS		R3,R3,#1
			RRX		R2,R2
			CMP		R7,#-1
			BNE		DENORMALRET
SKIPDENLOOP	LSRS		R3,R3,#1
			RRXS		R2,R2
			ADC		R2,R2,#0
			
			CMP		R2,#0x800000
			BLT		THRESHOLDS ;skip if it is denorm
			
EXPONENTDEBT	BL		ADDITEXPON
			AND		R2,R2,R5 ;take only the first 23 bits (cut off the 1 in the 24th bit (2^23))
			ADD		R7,R7,R6 ;add on any necessary extra to R7
			
THRESHOLDS	;HANDLING THE PRODUCTION OF NEW ZERO/INFINITY
			CMP		R7,#0 ;min threshold
			MOVLT	R7,#0 ;make the mantissa as small as possible
			MOVLT	R2,#0 ;make the significand/mantissa zero (as small as possible)
			CMP		R7,#255 ;Max threshold
			MOVGE	R7,#255
			MOVGE	R2,#0 ;infinity has 0 mantissa
			
			;FINISHING	UP
FINALEXPON	ADD		R2,R2,R7, LSL #23
SIGNING		EOR		R11,R11,R12 ;we form the sign bit lastly
			ADD		R2,R2,R11, LSL #31 ;was in the LSB, now in the MSB
DONE			LDMED	R13!,{R0,R1,R3-R12,PC}
			
			;MULTIPLY	SUBROUTINE
MUL24X24		STMED	R13!,{R0,R1,R4,R5,LR}
			MOV		R2,#0x0
			MOV		R3,#0x0
			SUBS		R4,R3,#1
ADDER		RSB		R5,R4,#32
			ADDSPL	R2,R2,R0,LSL R4
			ADC		R3,R3,R0,LSR R5
LOOP			LSRS		R1,R1,#1
			ADD		R4,R4,#1
			BLCS		ADDER
			BNE		LOOP
			LDMED	R13!,{R0,R1,R4,R5,PC}
			
			;CALCULATE	EXPONENT SUBROUTINE: TODO HANDLE DENORMALISED, OR THOSE THAT BECOME DENORMALISED
ADDITEXPON	STMED	R13!,{R0,R1,R3-R5,R7-R12,LR}
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
			MOV		R6,#0
			LSR		R2,R2,#1
			ADDNE	R2,R2,#1
			TST		R2,R8, LSL #26
			MOVNE	R6,#2
			LSRNE	R2,R2,#2
			TST		R2,R8,LSL #25
			MOVNE	R6,#1
			LSRNE	R2,R2,#1
			LDMED	R13!,{R0,R1,R3-R5,R7-R12,PC}
