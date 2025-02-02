;*******************************************
;Lab 4, Section 3b
;Name: Steven Miller
;Class #: 11318
;PI Name: Anthony Stross
;Description: Writes switch values from the external switches to the external LED's
;*******************************************
;***************INCLUDES*************************************
.include "ATxmega128a1udef.inc"
;***************END OF INCLUDES******************************

;*********************************EQUATES********************************
.EQU STACKEND = 0x3fff ;top of stack
.EQU STACKBEGIN = 0x2000 ;bottom of stack
.EQU INPUT = 0B00000000
.EQU OUTPUT = 0B11111111
.EQU IO_START_ADDRESS = 0X224000
.EQU SRAM_START_ADDRESS = 0X128000
.EQU READ_LOCATION = 0X128000
.EQU WRITE_LOCATION = 0X128100
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
	;INITIALIZE STACK POINTER
	LDI R16, LOW(STACKBEGIN)
	out CPU_SPL, R16
	LDI R16, HIGH(STACKEND)
	OUT CPU_SPH, R16
	RCALL EBI_INIT
	;LOAD SRAM ADDRESS INTO Y
	LDI YL, BYTE1(SRAM_START_ADDRESS)
	LDI YH, BYTE2(SRAM_START_ADDRESS)
	LDI R16, BYTE3(SRAM_START_ADDRESS)
	OUT CPU_RAMPY, R16
	;LOAD WRITE ADDRESS INTO Z
	LDI ZL, BYTE1(WRITE_LOCATION )
	LDI ZH, BYTE2(WRITE_LOCATION )
	LDI R16, BYTE3(WRITE_LOCATION )
	OUT CPU_RAMPZ, R16
	;INITIALIZE SRAM ADDRESSES
	LDI R16, 0XE
	ST Y,R16
	LDI R16, 0XF
	ST Z,R16
	LOOP:
	;READ FROM SRAM READ ADDRESS
	LD R16,Y
	;LOAD R16 WITH 0XF
	LDI R16, 0XF
	;WRITE TO SRAM WRITE ADDRESS
	ST Z, r16
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
