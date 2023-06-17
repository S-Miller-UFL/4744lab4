;*******************************************
;Lab 4, Section 2
;Name: Steven Miller
;Class #: 11318
;PI Name: Anthony Stross
;Description: Writes switch values from the external switches to the external LED's
;*******************************************
;***************INCLUDES*************************************
.include "ATxmega128a1udef.inc"
;***************END OF INCLUDES******************************

;*********************************EQUATES********************************
.EQU INPUT = 0B00000000
.EQU OUTPUT = 0B11111111
.EQU IO_START_ADDRESS = 0X224000
.EQU SRAM_START_ADDRESS = 0X128000
;*******************************END OF EQUATES*******************************

;*********************************DEFS********************************
;*******************************END OF DEFS*******************************

;***********MEMORY CONFIGURATION*************************

;***********END OF MEMORY CONFIGURATION***************
;***********MAIN PROGRAM*******************************
.CSEG
.ORG 0X0000
	RJMP MAIN
.ORG 0X0200
MAIN:
	RCALL EBI_INIT
	;LOAD IO ADDRESS
	LDI XL, BYTE1(IO_START_ADDRESS)
	LDI XH, BYTE2(IO_START_ADDRESS)
	LDI R16, BYTE3(IO_START)
	OUT CPU_RAMPX, R16
	MOV R16, XL
	STS PORTK_OUT, R16
	;SET RE AND WE TO TRUE
	LDI R16, 0B00000011
	STS PORTH_OUTCLR, R16
	;LOAD TOGGLE BIT
	LDI R16, 0B00000001
	LOOP:
	;TOGGLE WE ON AND OFF
		STS PORTH_OUTTGL, R16
	RJMP LOOP
END:
RJMP END
;*****************SUBROUTINES*************************

;******************************************
;NAME:EBI_INIT
;PURPOSE: INITIALIZES EBI SYSTEM
;REGISTERS AFFECTED: EBI_CNTRL
;INPUTS AFFECTED:PORTJ
;OUTPUTS AFFECTED:PORTK,RE, CS0, CS2
;******************************************
EBI_INIT:
	;SAVE RELATIVE REGISTERS
	PUSH R16
	;INIITIALIZE EBI CONTROL SIGNALS
	LDI R16,0B01010011
	STS PORTH_OUTSET, R16
	LDI R16,0B00000100
	STS PORTH_OUTCLR, R16
	;SET EBI CONTROL SIGNALS TO OUTPUT
	LDI R16, 0B01010111
	STS PORTH_DIRSET, R16
	;SET ADDRESS SIGNALS TO OUTPUT
	LDI R16,0XFF
	STS PORTK_DIRSET, R16
	;SET EBI TYPE TO 3 PORT SRAM ALE1
	LDI R16, 0B00000001
	STS EBI_CTRL, R16
	;CONFIGURE CS0
	LDI R16, 0B00011101
	STS EBI_CS0_CTRLA, R16
	LDI R16, BYTE2(SRAM_START_ADDRESS )
	STS EBI_CS0_BASEADDR, R16
	LDI R16, BYTE3(SRAM_START_ADDRESS )
	STS EBI_CS0_BASEADDR+1, R16
	;CONFIGURE CS2
	LDI R16, 0B00000001
	STS EBI_CS2_CTRLA, R16
	LDI R16, BYTE2(IO_START_ADDRESS)
	STS EBI_CS2_BASEADDR,R16
	LDI R16, BYTE3(IO_START_ADDRESS)
	STS EBI_CS2_BASEADDR+1,R16
	;RESTORE REGISTERS
	POP R16
RET
