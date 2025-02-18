.thumb
.syntax unified

.include "gpio_constants.s"     // Register-adresser og konstanter for GPIO
.include "sys-tick_constants.s"
.text
	.global Start

Start:


	//BUTTON TEST

	Bstart: 							//Creating branch point for Bstart
	LDR R0, =GPIO_BASE					//Filling in data from gpio_constants.s
	LDR R1, =PORT_SIZE
	LDR R2, =BUTTON_PORT
	LDR R3, =BUTTON_PIN
	LDR R4, =GPIO_PORT_DIN

	MUL R1, R1, R2						//Gives offset to Port B, R1 is offset for PORT B
	ADD R0, R0, R1						//Adds the offset to GPIO_BASE, R0 is now the address for PORT B
	ADD R0, R0, R4 						//R0 is now address for DIN at PORT B
										//We want to read the BUTTON_PIN, and ignore the rest (by using AND)
	MOV R5, #1 							//Creating mask material
	LSL R5, R5, R3 						//Left-Shifting to create mask
	LDR R6, [R0]						//Loading the contents of DIN
	AND R6, R6, R5 						//ANDing R5 and R6, if BUTTON_PIN is active, the new R6 == R5
	CMP R5, R6							//Checking for equality
	BEQ Bstart							//If equal (button not pressed), retry at Bstart

	// LED TEST

	Lstart:								//Creating branch point for Lstart
	LDR R7, =GPIO_BASE					//Filling in data from gpio_constants.s
	LDR R8, =PORT_SIZE
	LDR R9, =LED_PORT
	LDR R10, =LED_PIN
	LDR R11, =GPIO_PORT_DOUT
	LDR R12, =GPIO_PORT_DOUTSET
	LDR R13,  =GPIO_PORT_DOUTCLR

	MUL R8, R8, R9 						//Gives offset to Port E, R8 is offset for PORT E
	ADD R7, R7, R8 						//Adds R8 offset to GPIO_BASE, R7 is address for PORT E
	ADD R12, R7, R12					//Creating address for DOUTSET before R7 changes
	ADD R13, R7, R13					//Creating address for DOUTCLR before R7 changes
	ADD R7, R7, R11 					//R7 address is now Port E, DOUT
	MOV R8, #1 							//Creating mask material
	LSL R8, R8, R10 					//Created mask for DOUTSET
	STR R8, [R12]						//DOUTSET now sets our LED active

	// RE-TEST BUTTON

	LDR R6, [R0]						//Loading the contents of DIN
	AND R6, R6, R5 						//ANDing R5 and R6, if BUTTON_PIN is active, the new R6 == R5
	CMP R5, R6							//Checking for equality
	BNE Lstart							//Compare not equal, button is still pressed, goes back to Lstart

	STR R8, [R13]						//DOUTCLR now sets our LED inactive

	BEQ Bstart							//The compare gave equal (button not pressed), goes back to Bstart


NOP // Behold denne p� bunnen av fila
