    .data
complete:   .string 27, "[04;35;H",27,"[37;1mComplete:0/7", 0
time:       .string 27, "[05;36;H",27,"[37mTime:0000", 0xA,0xA, 0xD, 0
string_time:.string 27, "[37;1m0000", 0, 0, 0, 0
time_place: .string "0000",0
time_pos:   .string 27, "[05;41;H", 0       ; middle point on board y;x
cursor:     .string 27, "[11;40;H", 0       ; middle point on board y;x
cursor_two: .string 27, "[11;40;H", 0       ; middle point on board y;x
text:       .string 27,"[30;40;1mX", 0      ; placeholder for any ansi insertion
save:       .string 27, "[s", 0             ; this saves the cursor position
restore:    .string 27, "[u",0              ; this restores the cursor position
placeholder:.string 0,0,0,0                 ; place holder for int2str
clear:          .string  27, "[2J", 0
timer:          .int 0,0   ; value for timer
final_timer:    .int 0, 0  ; this value will display time at end incase of timer overflow
cur_x:          .int 4,0   ; column of cursor on board (+2)
cur_y:          .int 4,0   ; row of cursor on board    (+1)
board:          .char 0,0
pause:          .char 1, 0  ; 1 for paused
screen:         .int 0, 0  ; 0 - title or end, 1 - game, 2 - pause
links:          .space 211 ; this space is used for the link coordinates
link_color:     .char 0, 0 ; char 1-7
ignore:         .char 0,0

    .text
    ;*Lab 6
    .global UART0_Handler
    .global Switch_Handler
    .global Timer_Handler
    .global lab6

    ;* Libary
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

    ;* Boards
    .global test_boards
    .global board_out
    .global reprint_board
    .global reset_subboard

    ;*title
    .global make_title
    .global make_end
    .global make_pause

    ;*subboard
    .global make_sub_board
    .global clear_sub_board
    .global check_move
    .global check_spot
    .global test_sub_board
    .global get_color
    .global get_cursor_pos
    .global clear_pos_sub_board
    .global coord_to_byte
    .global byte_to_coord
    .global place_link
    .global last_link

    ;*complete
    .global modify_completed
    .global clear_completed
    .global reprint_completed
    .global check_completed

ptr_to_time:        .word time
ptr_to_string_time: .word string_time
ptr_to_time_pos:    .word time_pos
ptr_to_timer:       .word timer
ptr_to_time_place:  .word time_place
ptr_to_final_timer: .word final_timer
ptr_to_complete:    .word complete
ptr_to_clear:       .word clear
ptr_to_cur_x:       .word cur_x
ptr_to_cur_y:       .word cur_y
ptr_to_cursor:      .word cursor
ptr_to_cursor_two:  .word cursor_two
ptr_to_text:        .word text
ptr_to_save:        .word save
ptr_to_restore:     .word restore
ptr_to_board:       .word board
ptr_to_pause:       .word pause
ptr_to_screen:      .word screen
ptr_to_links:       .word links
ptr_to_link_color:  .word link_color
ptr_to_placeholder: .word placeholder
ptr_to_ignore:      .word ignore

WIDTH: 	    .equ 0x7
HEIGHT: 	.equ 0x7
CHARS:      .equ 0xB  ; characters per char
ROW:        .equ 0x6C ; characters per row
FOREGROUND: .equ 0x3  ; offset for foreground
BACKGROUND: .equ 0x6  ; offset for background
CHAR_OFFSET:.equ 0xA  ; offset for the char
ATTR:       .equ 0x8  ; offset for attribute
SPACE:      .equ 0x20
W_key:      .equ 0x77
A_key:      .equ 0x61
S_key:      .equ 0x73
D_key:      .equ 0x64
ENTER:      .equ 0xD
Cursor_off  .equ 0x24   ; offset for cursor
Cursor_vert .equ 0x7    ; vertical cursor offset
HORIZ:      .equ 0x2D
VERT:       .equ 0x7C
PLUS:       .equ 0x2B

lab6:
    STMFD SP!,{r0-r12,lr}
    bl uart_init
    bl gpio_init
    bl interrupt_init
    bl timer_init
	bl make_title
    
_again:
    wfi
    b _again
    LDMFD sp!, {r0-r12,lr}
    MOV pc, lr

;* starts the game
;* input  -
;* output -
init_game:
	STMFD SP!,{lr}

    bl reset_game

    ;*print the header*;
    ldr r0, ptr_to_clear
    bl output_string
    ldr r0, ptr_to_complete
    bl output_string
    ldr r0, ptr_to_time
    bl output_string
    ;*print the header*;

    ;*print the board*;
    bl board_out
    ldr r2, ptr_to_board
    strb r1, [r2]
    bl make_sub_board
    ;*print the board*;

    ;*place cursor*;
    ldr r0, ptr_to_cursor
    bl output_string
    ;*place cursor*;

    ldr r0, ptr_to_pause
    mov r1, #0
    strb r1, [r0]           ; unpause game

	LDMFD sp!, {lr}
	mov pc, lr

;* resets all values to default
;* input  -
;* output -
reset_game:
	STMFD SP!,{lr}

    bl clear_sub_board
    bl clear_links
    bl clear_completed

    mov r1, #0
    ldr r0, ptr_to_link_color
    str r1, [r0]
    mov r0, #0
    bl illuminate_RGB_LED
    ;* set timers to 0
    mov r1, #0
    ldr r0, ptr_to_timer
    str r1, [r0]
    ldr r0, ptr_to_final_timer
    str r1, [r0]
    ldr r0, ptr_to_string_time
    mov r1, #0x30
    strb r1, [r0, #7]
    strb r1, [r0, #8]
    strb r1, [r0, #9]
    strb r1, [r0, #10]


    ;center x and y
    mov r1, #4
    ldr r0, ptr_to_cur_x
    strb r1, [r0]

    ldr r0, ptr_to_cur_y
    strb r1, [r0]

    ;center cursor
    ldr r0, ptr_to_cursor
    mov r1, #0x31
    strb r1, [r0, #2]
    strb r1, [r0, #3]
    mov r1, #0x34
    strb r1, [r0, #5]
    mov r1, #0x30
    strb r1, [r0, #6]

	LDMFD sp!, {lr}
	mov pc, lr

;* starts game
;* input  -
;* output -
restart_game:
	STMFD SP!,{lr}
    ;*print the header*;
    ldr r0, ptr_to_clear
    bl output_string
    ldr r0, ptr_to_complete
    bl output_string
    ldr r0, ptr_to_time
    bl output_string
    ;*print the header*;

    bl reprint_board
    ;*print the board*;

    ldr r0, ptr_to_string_time
    bl put_time
    bl reprint_completed

    ;*place cursor*;
    ldr r0, ptr_to_cursor
    bl output_string
    ;*place cursor*;
    ldr r0, ptr_to_link_color
    ldrb r0, [r0]
    bl correct_num
    bl illuminate_RGB_LED

    LDMFD sp!, {lr}
	mov pc, lr

;* moves the cursor on the board
;* input  - r0 (x), r1 (y)
;* output -
move_cursor:
	STMFD SP!,{lr, r4-r6}

    ldr r6, ptr_to_cursor

    cmp r0, #0
    beq _no_move_x

    ldr r4, ptr_to_cur_x
    ldr r2, [r4]

    add r2, r2, r0
    str r2, [r4]

    mov r5, r1
    add r0, r2, #Cursor_off  ; increment row to fit board
    ldr r1, ptr_to_placeholder
    bl int2str

    ldrb r2, [r1]
    strb r2, [r6, #5] ; store char in tens position
    ldrb r2, [r1, #1]
    strb r2, [r6, #6] ; store char in tens position

    mov r1, r5
    b _move_y
_no_move_x:

_move_y:
    cmp r1, #0
    beq _no_move_y

    ldr r5, ptr_to_cur_y
    ldr r3, [r5]
    add r3, r3, r1
    str r3, [r5]

    add r0, r3, #Cursor_vert  ; increment row to fit board
    cmp r0, #0xA    ;
    blt _move_under_ten
    ldr r1, ptr_to_placeholder
    bl int2str

    ldrb r2, [r1]
    strb r2, [r6, #2] ; store char in tens position
    ldrb r2, [r1, #1]
    strb r2, [r6, #3] ; store char in tens position
    b _exit_move
_move_under_ten
    ldr r1, ptr_to_placeholder
    bl int2str
    mov r0, #30
    strb r0, [r6, #2] ; store char in tens position
    ldrb r2, [r1]
    strb r2, [r6, #3] ; store char in tens position


_no_move_y:

_exit_move
	LDMFD sp!, {lr, r4-r6}
	mov pc, lr

;* puts string of numbers in timer
;* input  - ptr_to_string_time
;* output -
put_time:
	STMFD SP!,{lr}

    ldr r0, ptr_to_time_pos
    bl output_string
    ldr r0, ptr_to_string_time
    bl output_string
    ldr r0, ptr_to_cursor
    bl output_string

	LDMFD sp!, {lr}
	mov pc, lr

;* places text at current a cursor position
;* input  - r0 (char), r1 (cursor ptr)
;* output -
place_text:
	STMFD SP!,{lr, r4-r5}
    mov r4, r0
    mov r5, r1
    ldr r0, ptr_to_save
    bl output_string

    mov r0, r5          ; new cursor pos
    bl output_string

    ldr r0, ptr_to_text
    strb r4, [r0, #CHAR_OFFSET]
    bl output_string
    ldr r0, ptr_to_restore
    bl output_string

	LDMFD sp!, {lr, r4-r5}
	mov pc, lr

;* changes the color of text
;* input  - r0 (ptr to char 1-7),
;* output -
color_text:
	STMFD SP!,{lr, r4}
    add r0, r0, #0x30   ; change to char
    ldr r4, ptr_to_text
    strb r0, [r4, #FOREGROUND]

	LDMFD sp!, {lr, r4}
	mov pc, lr

;* changes cursor
;* input  - y (tens r0, ones r1), x (tens r2, ones r3)
;* output -
modify_cursor_two:
	STMFD SP!,{lr, r4}
    ldr r4, ptr_to_cursor_two
    strb r0, [r4, #2]
    strb r1, [r4, #3]
    strb r2, [r4, #5]
    strb r3, [r4, #6]
	LDMFD sp!, {lr, r4}
	mov pc, lr

;* converts the time to string and places in string_time
;* input  - r0 (int)
;* output -
timer_to_string:
	STMFD SP!,{lr, r4-r5}

    mov r4, r0            ; store
    bl num_digits
    mov r5, r0            ; save num digits
    mov r0, r4
    ldr r1, ptr_to_time_place
    bl int2str            ; covert to string

    cmp r5, #4
    bgt _timer_overflow   ; check for timer overflow > 9999
    ldr r1, ptr_to_string_time
    add r1, r1, #11        ; increment to ones position
    sub r1, r1, r5        ; go back num_digits
_place_timer:
    ldrb r2, [r0], #1     ; load char
    strb r2, [r1], #1     ; store char
    sub r5, r5, #1        ; decrement ptr
    cmp r5, #0
    bne _place_timer
    b _exit_timer_to_string
_timer_overflow:
    ldr r4, ptr_to_timer
    mov r0, #0
    str r0, [r4]          ; set timer to 0
    ldr r1, ptr_to_string_time
    add r1, r1, #57       ; move to start position
    mov r5, #4            ; num_digits
    mov r2, #0x30         ; char 0
_timer_reset
    strb r2, [r1], #1     ; store 0
    sub r5, r5, #1        ; decrement
    cmp r5, #0            ; check for 0
    bne _timer_reset

_exit_timer_to_string
	LDMFD sp!, {lr, r4-r5}
	mov pc, lr

;* converts the time to string and places in string_time
;* input  - r0 - x, r1 - y, r2 - color 1-7
;* output -
store_pos:
	STMFD SP!,{lr, r4-r5}
    mov r3, #30         ; number to multiply by
    sub r2, r2, #1      ; increment down to start at 0

    mul r2, r2, r3      ; r2 = 30 * color
    ldr r4, ptr_to_links

    add r4, r4, r2      ; increment down to colors pos
    sub r4, r4, #1      ; just to add in loop
_find_zero:
    add r4, r4, #1
    ldrb r5, [r4]
    cmp r5, #0
    bne _find_zero

    bl coord_to_byte
    strb r0, [r4]

	LDMFD sp!, {lr, r4-r5}

	mov pc, lr

;* put link on display
;* input  - r0 - color
;* output -
show_link:
	STMFD SP!,{lr, r4-r6}
    mov r6, r0
    mov r4, r1
    mov r5, r2

    bl color_text
    ldr r0, ptr_to_cur_x
    ldrb r0, [r0]
    ldr r1, ptr_to_cur_y
    ldrb r1, [r1]

    bl check_spot  ;check if its safe for a link

    cmp r0, #1
    beq _exit_show_link

    ldr r0, ptr_to_links
    mov r1, #30
    sub r6, r6, #1  ; decrement to start at 0
    mul r1, r1, r6
    add r0, r0, r1  ; location in mem for color

_find_end:
    ldrb r1, [r0], #1
    cmp r1, #0
    bne _find_end

    sub r1, r0, #3  ; index len - 2
    ldrb r0, [r1]   ; second to last
    ldrb r1, [r1, #1]; last

    mov r2, r4
    mov r3, r5
    bl link_char

_place_char:
    ldr r1, ptr_to_cursor
    bl place_text

_exit_show_link
	LDMFD sp!, {lr, r4-r6}
	mov pc, lr

;* determines the char for the link
;* input  - r0 - byte 1, r1 - byte 2, r2 - x inc, r3 - y inc
;* output -
link_char:
	STMFD SP!,{lr}

    sub r0, r1, r0  ; sub the coords
    bl byte_to_coord

    cmp r0, #0
    beq _insert_pipe
    cmp r1, #0
    beq _insert_dash

_insert_pipe:
    cmp r2, #0
    bne _insert_plus
    mov r0, #VERT
    b  _exit_link_char
_insert_dash:
    cmp r3, #0
    bne _insert_plus
    mov r0, #HORIZ
    b _exit_link_char
_insert_plus:
    mov r0, #PLUS

_exit_link_char:
	LDMFD sp!, {lr}
	mov pc, lr

;*prints a plus to position
;* input  - r0 - color,
;* output -
show_plus:
	STMFD SP!,{lr, r4}
    mov r4, r0
    bl check_start
    cmp r0, #0
    bne _exit_show_plus

    mov r0, r4
    bl color_text
    mov r0, #PLUS
    ldr r1, ptr_to_cursor
    bl place_text
_exit_show_plus:
	LDMFD sp!, {lr, r4}
	mov pc, lr

;* clears ALL links in .space
;* input  -
;* output -
clear_links:
	STMFD SP!,{lr, r4}

    ldr r4, ptr_to_links
    mov r0, #210
    mov r1, #0
_clear_link_loop:
    strb r1, [r4], #1
    sub r0, r0, #1
    cmp r0, #0
    bgt _clear_link_loop

_exit_clear_links:
	LDMFD sp!, {lr, r4}
	mov pc, lr

;* clears links of a specific color
;* input  - r0 - color
;* output -
clear_color_links:
	STMFD SP!,{lr, r4-r6}
    sub r0, r0, #1
    mov r6, #30     ; multiply by

    ldr r4, ptr_to_links
    mul r0, r0, r6
    add r4, r4, r0      ; increment to correct color
    mov r5, #0          ; store value

    strb r5, [r4], #1   ; skip first val
_clear_color_links_loop:
    ldrb r0, [r4]   ; load the value
    cmp r0, #0
    beq _exit_clear_color_links
    bl byte_to_coord            ; get x,y coordinate
    bl clear_pos_sub_board      ; clear sub board position
    bl get_cursor_pos           ; get cursor
    bl modify_cursor_two        ; get cursor ready

    mov r0, #0
    bl color_text
    mov r0, #SPACE
    ldr r1, ptr_to_cursor_two
    bl place_text
    strb r5, [r4], #1
    b _clear_color_links_loop

_exit_clear_color_links:
	LDMFD sp!, {lr, r4-r6}
	mov pc, lr

;*clear links at x and y pos
;* input - r0 - color
;* ouput -
clear_pos_links:
	STMFD SP!,{lr, r4-r5}
    sub r4, r0, #1

    ldr r0, ptr_to_cur_x
    ldr r0, [r0]
    ldr r1, ptr_to_cur_y
    ldr r1, [r1]
    bl coord_to_byte    ; get byte

    ldr r1, ptr_to_links
    mov r2, #30             ; increment value
    mul r2, r2, r4          ; 30*color
    add r1, r1, r2
    b _clear_pos_links_loop

_clear_pos_links_loop:
    ldrb r3, [r1]
    cmp r0, r3
    beq _byte_found
    add r1, r1, #1
    b _clear_pos_links_loop

_byte_found:
    mov r4, r1      ; ptr_to_links

_set_links_to_zero:
    ldrb r0, [r4]               ; load the value
    cmp r0, #0
    beq _exit_clear_pos_links
    bl byte_to_coord            ; get x,y coordinate
    bl clear_pos_sub_board      ; clear sub board position
    bl get_cursor_pos           ; get cursor
    bl modify_cursor_two        ; get cursor ready

    mov r0, #0
    bl color_text
    mov r0, #SPACE
    ldr r1, ptr_to_cursor_two
    bl place_text
    mov r5, #0
    strb r5, [r4], #1
    b _set_links_to_zero

_exit_clear_pos_links:
	LDMFD sp!, {lr, r4-r5}
	mov pc, lr

;* replaces links after pause
;* input -
;* ouput -
replace_links:
	STMFD SP!,{lr, r4-r9}

    ldr r4, ptr_to_links
    mov r6, #0

_next_color:
    mov r5, #30     ; space per color
    add r6, r6, #1  ; color incrementor
    ldrb r7, [r4]   ; first pos
    cmp r7, #0
    beq _end_color_link_loop
_color_link_loop:
    add r4, r4, #1  ; increment ptr
    sub r5, r5, #1  ; decrement space per color
    ldrb r9, [r4, #1]   ; load next
    cmp r9, #0
    beq _last_link

    ldrb r1, [r4]
    mov r8, r1
    sub r0, r9, r8
    bl byte_to_coord
    mov r2, r0
    mov r3, r1

    mov r0, r7
    mov r1, r8
    bl link_char
    mov r9, r0      ; store char

    mov r0, r8      ; pos of second coord
    bl byte_to_coord
    bl get_cursor_pos
    bl modify_cursor_two

    mov r0, r6
    bl color_text
    mov r0, r9
    ldr r1, ptr_to_cursor_two
    bl place_text

    mov r7, r8      ; mov 2nd xy to first xy
    b _color_link_loop
_last_link:
    mov r0, r6
    bl check_completed
    cmp r0, #1
    beq _complete_link

    mov r9, #PLUS
    ldrb r8, [r4]   ; last
    b _output_last_link
_complete_link:
    mov r0, r7      ; second to last
    ldrb r1, [r4]   ; last
    mov r8, r1
    mov r2, r6      ; color 
    bl last_link
    cmp r0, #0
    beq _end_color_link_loop
    mov r9, r0

_output_last_link:
    cmp r8, #0
    beq _end_color_link_loop
    mov r0, r8      ; pos of second coord
    bl byte_to_coord
    bl get_cursor_pos
    bl modify_cursor_two

    mov r0, r6
    bl color_text
    mov r0, r9
    ldr r1, ptr_to_cursor_two
    bl place_text

_end_color_link_loop:
    add r4, r4, r5  ; increment to next color
    cmp r6, #7
    bne _next_color



	LDMFD sp!, {lr, r4-r9}
	mov pc, lr

;*checks start pt
;* input - r0 - color
;* ouput - r0 - 1 not done, 0 done
check_start:
	STMFD SP!,{lr, r4-r5}

    ldr r4, ptr_to_links
    mov r1, #30
    sub r0, r0, #1  ; decrement to start at 0
    mul r1, r1, r0
    add r4, r4, r1  ; location in mem for color

    ldrb r0, [r4]
    bl byte_to_coord

    ldr r4, ptr_to_cur_x
    ldrb r4, [r4]
    ldr r5, ptr_to_cur_y
    ldrb r5, [r5]
    cmp r0, r4
    bne _pos_not_equal_start
    cmp r1, r5
    bne _pos_not_equal_start
    mov r0, #1
    b _exit_check_start
_pos_not_equal_start:
    mov r0, #0
_exit_check_start:
	LDMFD sp!, {lr, r4-r5}
	mov pc, lr

;************************Handlers************************
;* clear timer interupt and does "stuff"
;* input  -
;* output -
Timer_Handler:
    STMFD SP!,{r0-r12,lr}

    ;0x40030024
    mov r0, #0x0000
    movt r0, #0x4003
    ldrb r1, [r0,#0x024]
    orr r2,r1 ,#1
    strb r2, [r0,#0x024]

    ldr r0, ptr_to_pause
    ldrb r0, [r0]
    cmp r0, #1
    beq _exit_timer_handler ; currently paused

	ldr r0, ptr_to_timer
    ldr r1, [r0]
    add r1, r1, #1  ; increment timer
    str r1, [r0]

    ; this timer is displayed at end of game
    ldr r0, ptr_to_final_timer
    ldr r1, [r0]
    add r1, r1, #1  ; increment timer
    str r1, [r0]

    mov r0, r1
    bl timer_to_string
    bl put_time

_exit_timer_handler:
    mov r0, #0
    ldr r1, ptr_to_ignore
    ldrb r0, [r1]
    cmp r0, #0
    beq _done_timer_handler
    sub r0, r0, #1
    strb r0, [r1]
_done_timer_handler
    LDMFD sp!, {r0-r12,lr}
    BX lr

;* clear switch interupt and does "stuff"
;* input  -
;* output -
Switch_Handler:
    STMFD SP!,{r0-r12,lr}

    mov r1, #0x5000
    movt r1, #0x4002
    ldrb r2, [r1,#0x41C]
    orr r3, r2, #0x10
    strb r3, [r1,#0x41C]

    ldr r4, ptr_to_screen
    ldrb r1, [r4]
    cmp r1, #0
    beq _exit_switch_handler

    ;* keep handler from triggering 2x
    ldr r4, ptr_to_ignore
    ldrb r1, [r4]
    cmp r1, #0
    bne _exit_switch_handler
    mov r1, #2
    strb r1, [r4]
    ;* keep handler from triggering 2x

	ldr r4, ptr_to_pause
    ldrb r1, [r4]
    cmp r1, #1
    beq _unpause

    mov r0, #0
    bl illuminate_RGB_LED
    
    ldr r0, ptr_to_board
    ldrb r0, [r0]
    bl make_pause
    mov r1, #1
    strb r1, [r4]

    b _exit_switch_handler
_unpause:
    bl restart_game
    bl replace_links
    ldr r0, ptr_to_cursor
    bl output_string
    mov r1, #0
    strb r1, [r4]

_exit_switch_handler:

    LDMFD sp!, {r0-r12,lr}
    BX lr

;* clear UART interupt and does "stuff"
;* input  -
;* output -
UART0_Handler:
	STMFD SP!,{r0-r12,lr}

    mov r0, #0xC000
    movt r0, #0x4000
    ldrb r1, [r0,#0x044]
    mov r2, #1
    bfi r1, r2, #4, #1  ; place 1 to clear interrupt
    strb r1, [r0,#0x044]

    bl read_character

    ldr r1, ptr_to_pause
    ldrb r1, [r1]
    cmp r1, #1
    beq check_screen ; currently paused
    ;* bgt _title_screen      ; will be used to check for enter

    cmp r0, #W_key
    beq _w_pressed
    cmp r0, #A_key
    beq _a_pressed
    cmp r0, #S_key
    beq _s_pressed
    cmp r0, #D_key
    beq _d_pressed
    cmp r0, #SPACE
    beq _space_pressed
    b _exit_uart_handler ; exit if no relevant key pressed

;* r4, r5 are used to preserve values
_w_pressed:
    mov r4, #0
    mov r5, #-1
    b _uart_do_stuff

_a_pressed:
    mov r4, #-1
    mov r5, #0
    b _uart_do_stuff

_s_pressed:
    mov r4, #0
    mov r5, #1
    b _uart_do_stuff

_d_pressed:
    mov r4, #1
    mov r5, #0
    b _uart_do_stuff

_space_pressed:
    ldr r1, ptr_to_link_color
    ldrb r0, [r1]
    cmp r0, #0
    beq _activate_color
_deactivate_color:
    bl show_plus
    mov r0, #0
    ldr r1, ptr_to_link_color
    strb r0, [r1]
    bl illuminate_RGB_LED
    b _exit_uart_handler
_activate_color:
    bl get_color
    mov r4, r0  ; preserve
    cmp r0, #0
    beq _exit_uart_handler
    cmp r1, #1
    bne _start_on_link
_start_on_O:
    bl clear_color_links
    mov r0, #-1     ; decrement
    mov r1, r4      ; color
    bl modify_completed

    ldr r0, ptr_to_cur_x
    ldrb r0, [r0]
    ldr r1, ptr_to_cur_y
    ldrb r1, [r1]
    mov r2, r4
    bl store_pos

    mov r0, r4
    b _set_color
_start_on_link:
    bl clear_pos_links

    mov r0, #-1     ; decrement
    mov r1, r4      ; color
    bl modify_completed

    ldr r0, ptr_to_cur_x
    ldrb r0, [r0]
    ldr r1, ptr_to_cur_y
    ldrb r1, [r1]
    mov r2, r4
    bl store_pos
    mov r0, r4
    bl place_link
    mov r0, r4
_set_color:
    ldr r4, ptr_to_link_color
    strb r0, [r4]
    bl correct_num
    bl  illuminate_RGB_LED

    ;* b _exit_uart_handler
    b _print_cursor

_uart_do_stuff:
    mov r0, r4
    mov r1, r5            
    ldr r2, ptr_to_link_color
    ldrb r2, [r2]
    bl check_move
    cmp r0, #0
    beq _move
    cmp r0, #1  ; not safe
    beq _exit_uart_handler
    cmp r0, #2  ; break links
    beq _break_links
    cmp r0, #3  ; link done
    beq _link_done

_break_links:
    mov r7, r1  ; color to break

    ldr r6, ptr_to_link_color
    ldrb r6, [r6]
    cmp r6, r7      ; same color
    beq _dont_show_link
    mov r0, r6
    mov r1, r4
    mov r2, r5
    bl show_link

    mov r0, #-1     ; decrement
    mov r1, r7      ; color
    bl modify_completed

_dont_show_link:
    mov r0, r4
    mov r1, r5
    bl move_cursor

    mov r0, r7
    bl clear_pos_links
    b _link_operations

_link_done:

    ldr r6, ptr_to_link_color
    ldrb r6, [r6]
    mov r0, r6

    mov r1, r4
    mov r2, r5
    bl show_link
    

    mov r0, #1     ; increment
    mov r1, r6     ; color
    bl modify_completed
    mov r8, r0      ; store return val

    b _done_link
_link_at_start:
    ldrb r0, [r6]
    bl clear_color_links
    b _activate_color

_done_link:
    mov r0, r4
    mov r1, r5
    bl move_cursor

    ldr r6, ptr_to_link_color
    ldrb r0, [r6]
    bl check_start
    cmp r0, #1
    beq _link_at_start

    mov r0, #0              ; change link color to 0
    strb r0, [r6]           ; inactive
    bl illuminate_RGB_LED   ; turn off led
    b _print_cursor

_move:
    ldr r6, ptr_to_link_color
    ldrb r6, [r6]
    cmp r6, #0
    bne _link

    mov r0, r4
    mov r1, r5
    bl move_cursor
    b _print_cursor

_link:
    mov r0, r6  ; color
    mov r1, r4
    mov r2, r5
    bl show_link
    mov r0, r4
    mov r1, r5
    bl move_cursor

_link_operations:
    ldr r0, ptr_to_cur_x
    ldrb r0, [r0]
    ldr r1, ptr_to_cur_y
    ldrb r1, [r1]
    mov r2, r6
    bl store_pos
    mov r0, r6
    bl place_link

_print_cursor:
    ldr r0, ptr_to_cursor
    bl output_string
    cmp r8, #1
    bne _exit_uart_handler

_trigger_end:
    ldr r0, ptr_to_pause
    mov r1, #1
    strb r1, [r0] ;pause game

    ldr r0, ptr_to_screen
    mov r1, #0
    strb r1, [r0] ;change screen

    ldr r0, ptr_to_final_timer
    ldr r0, [r0]

    ldr r1, ptr_to_board
    ldrb r1, [r1]
    bl make_end

_exit_uart_handler:
    LDMFD sp!, {r0-r12,lr}
    BX lr

;* an extension of uart_handler
check_screen:
    ldr r4, ptr_to_screen
    ldrb r3, [r4]

    cmp r3, #1
    beq game_paused
    blt _check_char

_set_up_game:
    bl init_game
    mov r3, #1
    strb r3, [r4]
    b _exit_check_screen

_check_char:
    cmp r0, #ENTER
    beq _set_up_game


game_paused:
    cmp r0, #0x1B ;escape key, new level if escape is pressed while paused.
    beq new_level
    cmp r0, #ENTER
    beq pause_restart
    b _exit_check_screen
pause_restart:
	bl reset_game
	bl restart_game
    bl reset_subboard
	ldr r0, ptr_to_pause
    mov r1, #0
    strb r1, [r0]
	b _exit_check_screen


new_level:
    mov r0, #0
    ldr r1, ptr_to_link_color
    strb r0, [r1]
    bl illuminate_RGB_LED
    bl init_game
    mov r3, #1
    strb r3, [r4]

    b _exit_check_screen

_exit_check_screen:
    LDMFD sp!, {r0-r12,lr}
    BX lr

.end
