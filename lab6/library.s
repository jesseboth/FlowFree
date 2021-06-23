	.data

	.text
	.global read_character
	.global output_character
	.global output_string
	.global read_string
	.global uart_init
	.global gpio_init
	.global interrupt_init
	.global timer_init
	.global read_from_push_btn
	.global illuminate_RGB_LED
	.global num_digits
	.global int2str
	.global str2int
	.global negate_int 
	.global Timer_Handler
	.global Switch_Handler
	.global UART0_Handler
	.global correct_num

.text
U0FR:  	.equ 0x18			; UART0 Flag Register
ENTER: 	.equ 0x0D
MINUS: 	.equ 0x2D
YES		.equ 0x79

;* waits for a character to be pressed in terminal
;* input  - 
;* output - r0 (char)
read_character:
	STMFD SP!,{lr, r4-r11}      

	MOV r1, #0xC000     ; set lower 16 bits
	MOVT r1, #0x4000    ; set upper 16 bits

	;* read from r0
	LDRB r0, [r1]

	LDMFD sp!, {lr, r4-r11}
	mov pc, lr

;* outputs character to the screen
;* input  - r0 (char)
;* output -
output_character:
	STMFD SP!,{lr, r4-r11} 

	mov r1,#0xC000   ; set lower 16 bits
	movt r1,#0x4000  ; set upper 16 bits
_output_char_LOOP:
	add r2,r1,#0x18  ; move to flag
	LDRB r2, [r2]    ; load flag
	and r2,r2, #0x20 ; isolate flag
	cmp r2,#0        ; compare flag
	BNE _output_char_LOOP

	;* store data
	STRB r0, [r1]

	LDMFD sp!, {lr, r4-r11}
	mov pc, lr

;* outputs string to terminal
;* input  - r0 (ptr to string)
;* output - 
output_string:
	STMFD SP!,{lr, r4-r11}

	mov r3,r0                ; move pointer to r3

_print_string:
	LDRB r0, [r3]            ; get character at pointer
	CMP r0, #0x0             ; check if r0 is null
	BEQ _STOP_output_string   ; if char is null stop,else ouptput character
	bl output_character      ; output char
	add r3, r3, #1           ; increment pointer
	b _print_string

_STOP_output_string:
	LDMFD sp!, {lr, r4-r11}
	mov pc, lr

;* get string
;* input  - 
;* output - 
read_string:
	STMFD SP!,{lr, r4-r11}
	mov r3, r0
_cont_read_string:
	bl read_character
	bl output_character
	CMP r0, #ENTER
	BEQ _exit_read

	STRB r0, [r3]   ; store character from read in ptr
	ADD r3, r3, #1  ; increment to next space
	b _cont_read_string   ; get next character

_exit_read:
	MOV r0, #0x0      ; null character @ end
	STRB r0, [r3]   ; store character from read in ptr

	; no return -> use assigned ptr to get string
	LDMFD sp!, {lr, r4-r11}
	mov pc, lr

;* initializes terminal input/output
;* input  - 
;* output - 
uart_init:
	STMFD SP!,{lr, r4-r11}

	mov r0,#0xE618
	movt r0,#0x400F
	ldr r1,[r0]
	ORR r1,r1,#1
	str r1,[r0]			; Provide clock to UART0

	mov r0,#0xE608
	movt r0,#0x400F
	ldr r1,[r0]
	ORR r1,r1,#1		;Disable UART0 Control
	str r1,[r0]

	mov r0,#0xC030
	movt r0,#0x4000
	ldr r1,[r0]
	ORR r1,r1,#0		;Disable UART0 Control
	str r1,[r0]

	mov r0,#0xC024
	movt r0,#0x4000
	ldr r1,[r0]
	ORR r1,r1,#8 ;Set UART0_IBRD_R for 115,200 baud
	str r1,[r0]

	mov r0,#0xC028
	movt r0,#0x4000
	ldr r1,[r0]
	ORR r1,r1,#44  ;Set UART0_FBRD_R for 115,200 baud
	str r1,[r0]


	mov r0,#0xCFC8
	movt r0,#0x4000
	ldr r1,[r0]
	ORR r1,r1,#0 ;/* Use System Clock */
	str r1,[r0]

	mov r0,#0xC02C
	movt r0,#0x4000
	ldr r1,[r0]
	ORR r1,r1,#0x60 ;/* Use 8-bit word length, 1 stop bit, no parity */
	str r1,[r0]


	mov r0,#0xC030
	movt r0,#0x4000
	ldr r1,[r0]
	mov r2,#0x301
	ORR r1,r1,r2
	str r1,[r0]


	mov r0,#0x451C
	movt r0,#0x4000
	ldr r1,[r0]
	ORR r1,r1,#0x03
	str r1,[r0]	 ;/* Enable UART0 Control  */

	mov r0,#0x4420
	movt r0,#0x4000
	ldr r1,[r0]
	ORR r1,r1,#0x03
	str r1,[r0]	 ; /* Make PA0 and PA1 as Digital Ports  */

	mov r0,#0x452C
	movt r0,#0x4000
	ldr r1,[r0]
	ORR r1,r1,#0x11
	str r1,[r0]	 ;(*((volatile uint32_t *)(0x4000452C))) |= 0x11

	LDMFD sp!, {lr, r4-r11}
	mov pc, lr

;* initializes LEDs and sw2
;* input  - 
;* output - 
gpio_init:
	STMFD SP!,{lr, r4-r11}


	;* enable clock
	mov r1, #0xE000
	movt r1, #0x400F
	ldrb r2, [r1, #0x608]   ; with offset 0x608
	orr r0, r2, #0x20         ; enable clock
	strb r0, [r1, #0x608]   ; with offset 0x608

	;* enable led input and switch output
	mov r1, #0x5000        ; 0x40025000
	movt r1, #0x4002
	ldrb r2, [r1, #0x400]   ; with offset 0x400
	orr r0, r2, #0x0F      ; Enable LED pins as inputs
	strb r0, [r1, #0x400]   ; with offset 0x400

	;* enable digital led
	mov r1, #0x5000
	movt r1, #0x4002
	ldrb r2, [r1, #0x51C]   ; with offset 0x51C
	orr r0, r2, #0x1F       ; Enable LED for digital use
	strb r0, [r1, #0x51C]   ; with offset 0x400

	;* enable pull up resistor
	mov r1, #0x5000
	movt r1, #0x4002
	ldrb r2, [r1, #0x510]   ; with offset 0x510
	orr r0, r2, #0x10       	;enable 
	strb r0, [r1, #0x510]   ; with offset 0x510


	LDMFD sp!, {lr, r4-r11}
	MOV pc, lr

;* initializes interrupts
;* input  - 
;* output - 
interrupt_init:       
    STMFD SP!,{r0-r12,lr}   ; Preserve registers on the stack           
    
    ; 0x4000C000 off set 0x038
    ; UART Interrupt Mask Register
    mov r0, #0xC000
    movt r0, #0x4000
    ldrb r1, [r0,#0x038]
    orr r2, r1, #0x10   ; place 1 at pin 4
    strb r2, [r0,#0x038]

    ;* UART stuff
    mov r0, #0xE000
    movt r0, #0xE000
    ldr r1, [r0,#0x100]     
    orr r2, r1, #0x20   ; place 1 at pin 5
    str r2, [r0,#0x100]

    ;* gpio port F interrupt
    mov r2, #1
    bfi r1, r2, #30, #1 ; place 1 at pin 30
    str r1, [r0,#0x100]

    ;* 0x40025000
    mov r0, #0x5000
    movt r0, #0x4002

    ;* edge sensitive
    ldrb r1, [r0,#0x404]
    mov r2, #0          ; to insert 0
    bfi r1, r2, #4, #1  ; place 0 at pin 4
    strb r1, [r0,#0x404]

    ;* not both rising and falling (0)
    ldrb r1, [r0,#0x408]
    mov r2, #0          ; to insert 0
    bfi r1, r2, #4, #1  ; place 0 at pin 4
    strb r1, [r0,#0x408]
    
    ;* rising (1) or falling (0)
    ldrb r1, [r0,#0x40C]
    mov r2, #0  
    bfi r1, r2, #4, #1  ; place 0 at pin 4
    strb r1, [r0,#0x40C]

    ;* enable interrupt
    ldrb r1, [r0,#0x410]
    orr r2, r1, #0x10   ; place 1 at pin 4
    strb r2, [r0,#0x410]


    LDMFD sp!, {r0-r12,lr}       
    MOV pc, lr

;* initializes timer for interrupts
;* input  - 
;* output - 
timer_init:
    STMFD SP!,{r0-r12,lr}   ; Preserve registers on the stack 

    ;0x400FE604
    mov r0, #0xE000
    movt r0, #0x400F
    ldrb r1, [r0,#0x604]
	orr r2, r1, #1
    strb r2, [r0,#0x604]

    ;0x4003000C
    mov r0, #0x0000
    movt r0, #0x4003
    ldrb r1, [r0,#0x00C]
    AND r2, r1, #0x1
    strb r2, [r0,#0x00C]

    ;0x40030000
    mov r0, #0x0000
    movt r0, #0x4003
    ldrb r1, [r0]
	AND r2,r1,#0x1
    strb r2, [r0]


	;0x40030004
	mov r0, #0x0000
    movt r0, #0x4003
    ldrb r1, [r0,#0x004]
    mov r2, #2
    bfi r1, r2, #0, #1
    strb r2, [r0,#0x004]

	;0x2400
	;0x00F4
	mov r10, #0x2400
	movt r10, #0x00F4

	;0x40030028
	mov r0, #0x0000
    movt r0, #0x4003
    ldr r1, [r0,#0x028]
	AND r2, r1, r10
    str r2, [r0,#0x028]

	;0x40030018
	mov r0, #0x0000
    movt r0, #0x4003
    ldrb r1, [r0,#0x018]
	orr r2, r1, #1
    strb r2, [r0,#0x018]


    mov r0, #0xE000
    movt r0, #0xE000
    ldr r1, [r0,#0x100]
    mov r2, #1
    bfi r1, r2, #19, #1 ; place 1 at pin 19
    str r1, [r0,#0x100]



	mov r0, #0x0000
    movt r0, #0x4003
    ldrb r1, [r0,#0x00C]
	orr r2, r1, #1
    strb r2, [r0,#0x00C]

    LDMFD sp!, {r0-r12,lr}       
    MOV pc, lr

;* checks if sw2 is being pressed
;* input  - r0 (1 -> pressed, 0 -> not)
;* output - 
read_from_push_btn:
	STMFD SP!,{lr, r4-r11}	

_read_button_again:
	;*0x40025000
	mov r1, #0x5000        ; move to port F
	movt r1, #0x4002
	ldrb r1, [r1, #0x3fc]   ; load pins
	and r0, r1, #0x10       ; check if 4th (-x---) bit is 1 or 0
	cmp r0, #0x0
	bne _off_btn
	mov r0, #1
	b _exit_btn
_off_btn:
	mov r0, #0
_exit_btn:	
	LDMFD sp!, {lr, r4-r11}
	MOV pc, lr

;* Changes color of LED
;* input  - r0 (int)
;* 		off = 0 Red = 1 Blue = 2 Purple = 3 Green = 4 Yellow = 5 Cyan = 6 White = 7
;* output - 
illuminate_RGB_LED:
	STMFD SP!,{lr, r4-r11}	

	mov r1, #0x5000
	movt r1, #0x4002
	ldrb r2, [r1, #0x038]
	bfi r2, r0, #1, #3		; bit field insert to correct pins
	strb r2, [r1, #0x038]

	LDMFD sp!, {lr, r4-r11}
	MOV pc, lr
	
;* returns number of digits in an int
;* input  - r0 (int)
;* output - r0 (num_digits)
num_digits:
	STMFD SP!,{lr}

	MOV r1, r0          ; Move int passed to R1
	MOV r0, #0          ; initialize number of digits to 0
	MOV r2, #10
	cmp r1,#0
	BGE _DIV_NUM_DIGITS
	EOR r1,r1,#0xFFFFFFFF
	ADD r1,r1,#1

_DIV_NUM_DIGITS: UDIV r1,r1,r2   ; Divide int by 10
	ADD r0,r0,#1        ; Increase number of digits by 1
	CMP r1, #0          ; Compare quotient to 0
	BNE _DIV_NUM_DIGITS	 ; If not equal to 0 repeat processes.

	LDMFD sp!, {lr}
	MOV pc, lr

;* converts an integer to a string
;* input  - r0 (int), r1 (ptr to string)
;* output - r0 (ptr to string)
int2str:
	;* int in r0
	;* ptr in r1
	STMFD SP!,{lr, r4-r11}
	mov r4, r0          ; store int
	mov r5, r1          ; store ptr
	bl num_digits
	mov r2, r0          ; mov num to posistion
	mov r0, r4          ; restore int
	mov r1, r5          ; restore ptr



	cmp r0,#0
	BGE _SKIP_int2str
	mov r5, #0
	EOR r0,r0,#0xFFFFFFFF
	ADD r0, r0, #1
	mov r3,#0x2D
	STRB r3, [r1]
	ADD r1,r1,#1

_SKIP_int2str:
	ADD r1,r1,r2        ; Add number of digits to to pointer
	MOV r3, #0          ; 0 to store as null
	STRB r3, [r1]       ; NULL stored
	MOV r3,#10          ; register used to mult and divide by 10

_LOOP_int2str:
	SUB r1, r1, #1      ; decrement ptr
	UDIV r4, r0, r3     ; divide integer by 10
                     ; R4 holds quotient

	MUL r5,r4,r3        ; Mult integer by 10

	SUB r5, r0,r5       ; Subtract product from integer

	ADD r5, r5, #0x30   ; add 0x30 to get ASCII value

	STRB r5, [r1]       ; store ASCII value @ r1

	MOV r0, r4          ; initilize quotent to new integer

	CMP r0,#0           ; check if integer is = 0

	BNE _LOOP_int2str
	mov r0, r1
	LDMFD SP!,{lr, r4-r11}
	MOV pc, lr

;* negates the integer
;* input  - r0 (int)
;* output - r0 (int)
negate_int:
	STMFD SP!,{lr, r4-r11}
	
	EOR r0,r0,#0xFFFFFFFF
	ADD r0,r0,#1

	LDMFD SP!,{lr, r4-r11}
	MOV pc, lr




correct_num:
	STMFD SP!,{lr, r4-r11}

	cmp r0,#2
	beq green

	cmp r0,#4
	beq blue


	cmp r0,#5
	beq yellow

	cmp r0,#3
	beq magenta

	bl exit_correct_num


green:
	mov r0,#4
	bl exit_correct_num

blue:
	mov r0,#2
	bl exit_correct_num

yellow:
	mov r0,#3
	bl exit_correct_num

magenta:
	mov r0,#5
	bl exit_correct_num



exit_correct_num:
	LDMFD SP!,{lr, r4-r11}
	MOV pc, lr
;* converts a string to and int
;* input  - r0 (ptr to string)
;* output - r0 int
str2int:
	;* string in r0
	STMFD SP!,{lr, r4-r11}
	MOV r1, r0          ; save ptr
	MOV r0, #0          ; initialize int (i)
	MOV r4, #10         ; initialize MUL int

_LOOP_str2int:
	LDRB r2, [r1]       ; get contents from ptr (c)
	CMP r2, #0x0        ; compare to break loop -> null
	BEQ _STOP_str2int    ; r1 == 0

	MUL r0, r0, r4      ; i = i*10
	SUB r3, r2, #0x30   ; dig = c - 0x30
	ADD r0, r0, r3      ; i = i + dig

	ADD r1, r1, #1      ; increment ptr
	B _LOOP_str2int      ; branch LOOP

_STOP_str2int:
	LDMFD SP!,{lr, r4-r11}
	MOV pc, lr

;*
	.end
