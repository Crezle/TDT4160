.thumb
.syntax unified

.include "gpio_constants.s"     // Register-adresser og konstanter for GPIO
.include "sys-tick_constants.s" // Register-adresser og konstanter for SysTick

.text
	.global Start

.global SysTick_Handler
.thumb_func
SysTick_Handler:						//IMPORTANT: The handler must be defined before anything else
	PUSH {R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12}
	LDR R0, =tenths						//Tenths address
	LDR R1, =seconds					//Seconds address
	LDR R2, =minutes					//Minutes address
	MOV R3, #10							//Loading 10 to R3, to be used for checking if tenths = 10
	MOV R7, #60							//Loading 60 to R7, to be used for checking if seconds = 10

	LDR R4, [R0]						//Tenths value
	LDR R5, [R1]						//Seconds value
	LDR R6, [R2]						//Minutes value

	ADD R4, R4, #1						//Adding one tenth
	CMP R4, R3							//Checking if tenth = 10

	BNE Update

	LDR R8, =GPIO_BASE					//Filling in data from gpio_constants.s
	LDR R9, =PORT_SIZE
	LDR R10, =LED_PORT

	MUL R9, R9, R10						//R9 is now the total offset to port
	ADD R8, R8, R9						//R8 is now the at the LED PORT
	ADD R8, R8, #GPIO_PORT_DOUTTGL						//R8 is now the address for LED DOUTTGL
	MOV R9, #1							//Creating empty mask for LED check
	LSL R9, R9, #LED_PIN						//R9 IS A READY MASK
	STR R9, [R8]						//TURNS ON LED

	MOV R4, #0							//Resetting tenths
	ADD R5, R5, #1						//Adding a second
	CMP R5, R7							//Checking if seconds = 60

	BNE Update
	MOV R5, #0							//Resetting seconds
	ADD R6, R6, #1						//Adding a minute
	Update:
	STR R4, [R0]
	STR R5, [R1]						//Updating current values
	STR R6, [R2]
	POP {R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12}
	BX LR								//Return from SysTick interrupt

//==============================================================

.global GPIO_ODD_IRQHandler
.thumb_func
GPIO_ODD_IRQHandler:
	LDR R0, =SYSTICK_BASE
	LDR R1, [R0]
	LDR R2, =0b111
	AND R1, R1, R2
	EOR R1, R1, R2
	STR R1, [R0]

	LDR R5, =GPIO_BASE
	ADD R5, R5, #GPIO_IFC			//Flag clear address
	MOV R6, #1						//Loading from IF register
	LSL R6, R6, BUTTON_PIN
	STR R6, [R5]

	BX LR

//==============================================================

Start:									//We start by defining our SYSTICK settings

	LDR R0, =SYSTICK_BASE 				//Base address and CTRL address
	LDR R1,	=SYSTICK_LOAD				//LOAD Offset
	LDR R2, =SYSTICK_VAL				//VAL Offset

    ADD R1, R0, R1						//LOAD Address
    ADD R2, R0, R2						//VAL Address

	LDR R3, =0b000
	STR R3, [R0]

	LDR R4, =1400000					//A tenth of clock frequency
	STR R4, [R1]						//Setting required clock triggers before next interrupt

	STR R4, [R2]						//Setting initial amount of clock triggers before interrupt

	LDR R0, =GPIO_BASE
	LDR R1, =GPIO_EXTIPSELH
	LDR R2, =GPIO_EXTIFALL
	LDR R3, =GPIO_IEN

	ADD R1, R0, R1						//External Port Select High address
	ADD R2, R0, R2						//Falling Edge Register address
	ADD R3, R0, R3						//Interrupt enable address

	MOV R4, #0b1111						//Mask for pin9 in EXTIPSELH
	LSL R4, R4, #4						//Shifting mask 4 to left
	MVN R5, R4							//Inverting bits, complete mask
	LDR R6, [R1]						//EXTIPHSELH content
	AND R6, R6, R5						//Removing pin9 settings
	LDR R4, =PORT_B
	LSL R4, R4, #4						//Shifting port B identity to pin9
	ORR R6, R6, R4						//Adding new pin9 settings
	STR R6, [R1]						//Storing new EXTIPHSELH values

	MOV R1, #1
	LSL R1, #BUTTON_PIN
	LDR R4, [R2]
	LDR R5, [R3]
	ORR R4, R4, R1
	ORR R5, R5, R1
	STR R4, [R2]						//Storing new EXTIFALL
	STR R5, [R3]						//Storing new IEN


	InfLoop:
		B InfLoop





NOP // Behold denne på bunnen av fila
