* Author: Dustin Fay
* Convert a 32-bit 2's cmpliment number to a Decimal string, 
* output to the terminal, and store the NULL-terminated 
* Decimal string to memory

	AREA	Hw5A, CODE
	ENTRY 

NULL		EQU	0
CR		EQU	0x0D		;Ascii of Carriage Return
LF		EQU	0x0A		;Ascii of Line Feeder

Main
		MOV R0, #0		;clear result registers
		MOV R2, #0
		MOV R5, #0
		LDR R3, =TwosComp	;load location of TwosComp to R3
		LDR R4, =DecStr 	;load location of DecStr to R4
		LDR R6, =RevStr		;load location of RevStr to R6
		LDR R7, =MinusSign	;load location of negative sign ('-')
		LDR R9, =RevStr		;reference to address of RevStr
		

TestStr
		SWI 4			;read the first ascii from keyboard to [R0]
		CMP R0, #'0'		;is it lower then '0'
		BLT DoneReading		;not a valid digit
		CMP R0, #'9'		;is it higher then '9'
		BLS AcceptNum		;valid digit
		CMP R0, #'A'		;is it lower then 'A'
		BLT DoneReading		;not a valid digit
		CMP R0, #'F'		;is it higher then 'F'
		BLS AcceptLet		;valid digit
		B DoneReading

		
AcceptNum	
		SUB R2, R0, #'0'	;convert ASCII number input to HEX
		B Store2Register
		
AcceptLet
		SUB R2, R0, #'A'	;convert ASCII letter input to HEX
		ADD R2, R2, #0xA	;convert ASCII letter input to HEX (continued)
		B Store2Register


Store2Register
		MOV R5, R5, LSL#4	;make room for new value
		ADD R5, R5, R2		;append inputs to R5
		B TestStr		


DoneReading
		STR R5, [R3]	 	;store in TwosComp[R3]
		TST R5, #2, 2		;check for 1 in MSB (is negative?)
		BEQ Positive		;if positive branch to Positive
		STRB R7, [R4], #1	;if negative store '-' in DecStr[R4]
		MVN R5, R5		;convert to positive	
		ADD R5, R5, #1		;add 1 to LSB to finish conversion	
	
Positive
		CMP R5, #0		;check value for zero
		BEQ DoneConverting	;if zero then done
		BL DivBy10		;if not zero begin division (to convert to decimal)
		ADD R5, R5, #'0'
		STRB R5, [R6], #1	;store remainder in RevStr[R6] 
		MOV R5, R7		;store value of counter in R5 (new quotient)
		MOV R7, #0		;clear counter
		B Positive

		


DoneConverting
		SUB R6, R6, #1
ConvertLoop
		LDRB R8, [R6], #-1	;Load Byte from RevStr[R6] and shift right
		STRB R8, [R4], #1	;Store Byte from DecStr[R4] and shift left
		CMP R6, R9		;More characters?
		BHS ConvertLoop
		MOV R1, #0
		STRB R1, [R4]
		LDR R0, =DecStr
		
		SWI 2			;display string in R0
		


	SWI 0x11	;terminate program



DivBy10
		MOV R7, #0		;clear counter
		CMP R5, #10
		BHS DivLoop

		MOV pc,lr

DivLoop		
		SUB R5, R5, #10		;subtract 10 (for division routine)
		ADD R7, R7, #1		;add 1 to counter (Quotient)
		CMP R5, #10		;is quotient less than 10?
		BHS DivLoop			 

		MOV pc, lr



		AREA	Data, DATA

MinusSign	DCB	0		;ascii code of '-' if negative
RevStr		% 12
TwosComp	DCD	0		;2's compliment number.
DecStr		% 12			;12 bytes for Decimal string
		ALIGN

		END


