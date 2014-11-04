* Correct and decode an even-parity 
* Hamming Code into the source word.
*

MAX_LEN		EQU	100
NULL		EQU	0


	AREA	Assignment6_Fay, CODE
	ENTRY

Main
		LDR	R0, =SRC_WORD		    ;[R0] <- addr of source word		
		LDR	R1, =H_CODE		      ;[R1] <- addr of Hamming code
		LDR	R9, =PARITY_COUNTS	;[R9] <- addr of Parity Count
		MOV	R2, #1			        ;counter src_word (bit #1 in source word)
		MOV	R3, #1			        ;counter h_code (bit #1 in Hamming code)
		MOV	R4, #1			        ;counter h_code check bit (bit#1)
		SUB	R0, R0, #1	      	;adjust to current bit
		SUB	R1, R1, #1		      ;adjust to current bit
		EOR	R5, R5, R5		      ;[R5] <- 0
			
Loop		
		LDRB	R5, [R1, R3]		  ;[R5] <- data bit from H_Code
		 
		CMP	R5, #NULL		        ;is NULL?
		BEQ	DoneChecking		    ;done with H_code
		CMP	R5, #'0'		        ;is it a '0'
		BEQ	BitZero			        ;yes
		CMP	R5, #'1'		        ;is it a '1'
	 	BEQ	BitOne			        ;yes
		B	DoneError		          ;not 1, not 0, not NULL, -> ERROR

BitZero
		ADD	R3, R3, #1				
		B	Loop

BitOne		
		MOV	R6, R3			        ;[R6] <- [R3]
		EOR	R7, R7, R7
		EOR	R8, R8, R8		

LoopParity
		CMP	R7, #32		        	;less than '32'?
		BGE	BitZero
		MOVS	R6, R6, LSR #1		;[C-bit] <- [R3]'s bit #[R7]
		BCC 	NoParity
		LDRB	R8, [R9, R7]		  ;increment parity counter for check bit
		ADD	R8, R8, #1		      ;+1
		STRB	R8, [R9, R7]		
NoParity
		ADD	R7, R7, #1
		B	LoopParity

DoneError		
		MOV	R5, #'E'
		STRB	R5, [R1], #1
		MOV	R5, #'R'
		STRB	R5, [R1], #1
		MOV	R5, #'R'
		STRB	R5, [R1], #1
		MOV	R5, #'O'
		STRB	R5, [R1], #1
		MOV	R5, #'R'
		STRB	R5, [R1], #1
		MOV	R5, #NULL
		STRB	R5, [R1], #1
		B	Done

DoneChecking
		SUB	R3, R3, #1		
		EOR	R7, R7, R7
		MOV	R4, #1
		EOR	R10, R10, R10

LoopCheckBit
		CMP	R4, R3
		BHS	DoneEDetection		;done loading all checkbits
		LDRB	R5, [R9, R7]		;load parity of check bit
		TST	R5, #1		      	;is parity even?
		BEQ	LoadCheckBit		  ;yes -> go to LoadCheckBit
		ADD	R10, R10, R4		
	
LoadCheckBit
		ADD	R7, R7, #1		    ;[R7]++, next check bit
		ADD	R4, R4, R4		    ;[R4] <- [R4]*2, next check bit
		B	LoopCheckBit
		
DoneEDetection
		CMP	R10, #NULL		    ;is NULL?
		BEQ	DoneCorrection	
		LDRB	R5, [R1, R10]		
		CMP	R5, #'0'		      ;is it a '0' ?
		BEQ	TrueBit		      	;yes -> go to TrueBit
		CMP	R5, #'1'	      	;is it a '1' ?
		BEQ	ZeroBit		      	;no -> go to ZeroBit
		B	DoneError		        ;not 1, not 0, not NULL -> Error

ZeroBit
		MOV	R5, #'0'
		B	Store

TrueBit		
		MOV	R5, #'1'

Store		
		STRB	R5, [R1, R10]		

DoneCorrection
		MOV	R2, #1
		MOV	R3, #1
		MOV	R4, #1
LoopCorrect	LDRB	R5, [R1, R3]
		CMP	R5, #NULL
		BEQ	Done
		CMP	R3, R4
		BEQ	SkipBit
		STRB	R5, [R0, R2]
		ADD	R3, R3, #1
		ADD	R2, R2, #1
		B	LoopCorrect
SkipBit		ADD	R3, R3, #1
		ADD	R4, R4, R4
		B	LoopCorrect

Done
		SWI 0x11		      ;terminate program						

*
* Data Area
*

	AREA	Data1, DATA	

SRC_WORD	
		% MAX_LEN		      ;reserve zeroed memory for source word
		ALIGN

PARITY_COUNTS	
		% MAX_LEN		      ;reserve zeroed memory for Hamming Code
		ALIGN

H_CODE		DCB	"010011100101"
		DCB	NULL
		ALIGN

		END
