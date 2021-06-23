    .data

test_sub:   .string 27, "[20;1H",0
sub_board:  .string "XXXXXXXX"
            .string "X       "   ; this board will fill via a subroutine
            .string "X       "   ; O's will be placed as 1-7 for color
            .string "X       "   ; links will be placed as 0x31-0x35
            .string "X       "   ;
            .string "X       "   ;
            .string "X       "   ;
            .string "X       "   ;
            .string "XXXXXXXX",0
placeholder:.string 0,0,0
sub_pos:    .int 0,0    ; stores the current pos in the sub board
start_pos:  .int 0,0    ; stores the link start pos

    .text
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
    .global check_win
    .global last_link

    .global output_string
    .global output_character
    .global int2str


ptr_to_test_sub:    .word test_sub
ptr_to_sub_board:   .word sub_board
ptr_to_sub_pos:     .word sub_pos
ptr_to_start_pos:   .word start_pos
ptr_to_placeholder: .word placeholder

WIDTH: 	    .equ 0x7
HEIGHT: 	.equ 0x7
X:          .equ 0x58
O:          .equ 0x4F
SPACE:      .equ 0x20
CHARS:      .equ 0xB  ; characters per char
TOPROW:     .equ 28
FOREGROUND: .equ 0x3  ; offset for foreground
CHAR_OFFSET:.equ 0xA  ; offset for the char
Cursor_off  .equ 0x24   ; offset for cursor
Cursor_vert .equ 0x7    ; vertical cursor offset
VERT:       .equ 0x7C
HORIZ:      .equ 0x2D
PLUS:       .equ 0x2B

;* places color numbers on subboard (1-7) inplace of O's
;* input  - r0, board
;* output - builds the subboard from fresh board
make_sub_board:
	STMFD SP!,{lr, r4-r5}
    ldr r1, ptr_to_sub_board
    add r1, r1, #9                ; incrmement past top
    mov r4, #0                    ; y
    mov r5, #0                    ; x
    add r0, r0, #TOPROW              ; increment past first row

    b _next_row
_end_chars
    add r0, r0, #2                ; increment past end chars
_next_row
    add r0, r0, #7                ; increment past fluff
    add r0, r0, #CHARS            ; increment past boarder

    add r4, r4, #1                ; increment y
    mov r5, #0                    ; x  ; x = 0
    cmp r4, #HEIGHT               ; check done
    bgt _exit_make_sub_board
_next_char

    ldrb r2, [r0, #CHAR_OFFSET]   ; load relevant char
    cmp r2, #O                    ; check for O
    beq _place_in_sub
_return_place:
    add r0, r0, #CHARS            ; increment to next char
    add r1, r1, #1                ; increment sub board
    add r5, r5, #1                ; increment x
    cmp r5, #WIDTH                ; check for width
    bgt _end_chars                ; loop
    b _next_char
_place_in_sub:
    ldrb r2, [r0, #FOREGROUND]    ; get color #
    sub r2, r2, #0x30             ; char to int ; convert to int
    strb r2, [r1]                 ; store on sub (must use strb)

    b _return_place

_exit_make_sub_board:

    bl find_center
	LDMFD sp!, {lr, r4-r5}
	mov pc, lr

;* tests the subboard output at bottom of terminal
;* input - 
;* output - 
test_sub_board:
	STMFD SP!,{lr, r4}
    ldr r0, ptr_to_test_sub
    bl output_string
    ldr r4, ptr_to_sub_board

_test_sub_loop:
    ldrb r0, [r4]
    cmp r0, #0
    beq _exit_test
    cmp r0, #0xA
    blt _convert_char
_test_convert_return:
    bl output_character
    add r4, r4, #1
    b _test_sub_loop
_convert_char:
    add r0, r0, #0x30
    b _test_convert_return

_exit_test:
    LDMFD sp!, {lr, r4}
	mov pc, lr

;* find the center of the subboard
;* input -
;* output -
find_center:
	STMFD SP!,{lr, r4-r5}

    ldr r4, ptr_to_sub_board
    add r4, r4, #36          ; center of board
    ldr r5, ptr_to_sub_pos   ; ptr for ptr
    str r4, [r5]             ; store sub board pos

	LDMFD sp!, {lr, r4-r5}
	mov pc, lr

;* clears subboard to empty state
;* input  - 
;* output - 
clear_sub_board:
	STMFD SP!,{lr, r4-r6}

    ldr r0, ptr_to_sub_board
    add r0, r0, #8          ; increment past boarder
    mov r4, #0              ; y
    mov r6, #SPACE          ; char to place
_clear_sub_loop_y:
    add r4, r4, #1          ; increment y
    mov r5, #0              ; set x = 0
    add r0, r0, #1          ; increment ptr
    cmp r4, #HEIGHT
    bgt _exit_clear_sub
_clear_sub_loop_x:
    strb r6, [r0]
    add r0, r0, #1          ; increment ptr
    add r5, r5, #1          ; increment x
    cmp r5, #WIDTH      
    beq _clear_sub_loop_y   ; next row
    b _clear_sub_loop_x

_exit_clear_sub:
	LDMFD sp!, {lr, r4-r6}
	mov pc, lr

;* determines if the next move is safe
;* input  - r0-x shift, r1-y shift, 
;*          r2- current color (0 for link inactive)
;* output - r0 - 0 safe, 1 not safe, 2 break links, 3 link done
;*          r1 - [r0 = 1 - r1 = int to break] [r0 = 3, r1 = 0 for +1 complete 1 for -1 complete]
check_move:
	STMFD SP!,{lr, r4-r7}
 
    ldr r4, ptr_to_sub_pos
    ldr r5, [r4]

    cmp r0, #0
    beq _check_y

    add r5, r5, r0  ; increment to new pos
    ldrb r6, [r5]   ; get char at new pos
    b _check
_check_y: 
    cmp r1, #0
    beq _exit_check_move

    mov r7, #8
    mul r7, r7, r1          ; multiple r1 by 8 (up or down)

    add r5, r5, r7  ; increment to new pos
    ldrb r6, [r5]   ; get char at new pos

_check:
    cmp r6, #X      ; don't move past boarder
    beq _not_safe

    cmp r2, #0      ; no active links
    beq _safe

    cmp r2, r6
    beq _complete_link

    cmp r6, #0xA             ; char < 10
    blt _not_safe

    cmp r6, #SPACE          ; link active space
    beq _safe

    b _break_links

_safe:
    str r5, [r4]            ; store new value                   
    mov r0, #0              ; return value
    b _exit_check_move

_complete_link:
    mov r0, #3  ; indicate links are complete
    mov r1, #0
    str r5, [r4]    ; store new value
    b _exit_check_move

_undo_link:
    mov r0, #3  ; indicate links are complete
    mov r1, #1  ; indicate to decrement complete
    str r5, [r4]    ; store new value
    b _exit_check_move

_break_links:
    mov r0, #2
    ldrb r1, [r5]
    sub r1, r1, #0x30   ; convert color to int
    str r5, [r4]    ; store new value
    b _exit_check_move
_not_safe:
    mov r0, #1
   
_exit_check_move:
	LDMFD sp!, {lr, r4-r7}
	mov pc, lr

;* checks the space to see if it is safe for a link
;* input - r0 - x, r1 - y
;* output - r0 (0 safe, 1 not)
check_spot:
	STMFD SP!,{lr, r4-r5}
    ldr r4, ptr_to_sub_board
    mov r2, #8
    mul r5, r1, r2  ; get y incrementation

    add r4, r4, r0
    add r4, r4, r5

    ldrb r5, [r4]   ; load the value
    cmp r5, #0xA     ; check if int or char
    bgt _safe_spot  ; char = safe
    mov r0, #1
    b _exit_check_spot
_safe_spot:
    mov r0, #0
_exit_check_spot:
	LDMFD sp!, {lr, r4-r5}
	mov pc, lr

;* returns ptr to spot on sub board
;* input - r0 - x, r1 - y
;* output - r0 ptr
get_subboard_ptr:
	STMFD SP!,{lr, r4-r5}
    ldr r4, ptr_to_sub_board
    mov r2, #8
    mul r5, r1, r2  ; get y incrementation

    add r4, r4, r0
    add r4, r4, r5
    mov r0, r4
_exit_get_subboard_ptr:
	LDMFD sp!, {lr, r4-r5}
	mov pc, lr

;* place link on current pos
;* input  - r0 - (char color 1-7) 
;* output - 
place_link:
	STMFD SP!,{lr, r4}
    add r0, r0, #0x30       ; convert to char
    ldr r4, ptr_to_sub_pos
    ldr r4, [r4]
    strb r0, [r4]    ; store char in pos

	LDMFD sp!, {lr, r4}
	mov pc, lr

;* get color on current pos
;* input  - 
;* output - r0 - color 1-7 (char), 0 for fail - no color, 
;*          r1 - (1 if start on link) 0
get_color:
	STMFD SP!,{lr, r4-r5}

    ldr r4, ptr_to_sub_pos
    ldr r4, [r4]

    ldrb r0, [r4]        ; load char
    cmp r0, #SPACE      ; check for space
    beq _color_space
    cmp r0, #0xA        ; check for int
    bgt _color_on_link

    ldr r5, ptr_to_start_pos
    str r4, [r5]

    mov r1, #1          ; on O
    b _exit_get_color
_color_on_link:
    sub r0, r0, #0x30   ; convert to int
    mov r1, #0
    b _exit_get_color
_color_space:
    mov r0, #0

_exit_get_color:
	LDMFD sp!, {lr, r4-r5}
	mov pc, lr

;* place link on current pos
;* input  - r0 - x, r1 - y
;* output - y (tens r0, ones r1), x (tens r2, ones r3)
get_cursor_pos:
	STMFD SP!,{lr, r4-r7}
    mov r6, r1
;* x pos
    add r0, r0, #Cursor_off  ; increment column to fit board
    ldr r1, ptr_to_placeholder
    bl int2str

    ldrb r4, [r1]       ; x tens
    ldrb r5, [r1, #1]   ; x ones

;* y pos
    mov r0, r6
    add r0, r0, #Cursor_vert  ; increment row to fit board
    cmp r0, #0xA    ; 
    blt _under_ten
    ldr r1, ptr_to_placeholder
    bl int2str

    ldrb r6, [r1]
    ldrb r7, [r1, #1]
    b _exit_get_cursor
_under_ten
    ldr r1, ptr_to_placeholder
    bl int2str
    mov r6, #30
    ldrb r7, [r1]

_exit_get_cursor:
    mov r0, r6
    mov r1, r7
    mov r2, r4
    mov r3, r5
 
	LDMFD sp!, {lr, r4-r7}
	mov pc, lr

;* place link on current pos
;* input  - r0 - x, r1 - y
;* output - 
clear_pos_sub_board:
	STMFD SP!,{lr, r4-r5}

    ldr r4, ptr_to_sub_board
    mov r2, #8
    mul r5, r1, r2  ; get y incrementation

    add r4, r4, r0
    add r4, r4, r5

    mov r3, #SPACE
    strb r3, [r4]

	LDMFD sp!, {lr, r4-r5}
	mov pc, lr

;* converts x and y to a single byte
;* input  - r0 - x, r1 - y
;* output - r0 - xy in a single byte
coord_to_byte:
	STMFD SP!,{lr}
    lsl r0, r0, #4 ; bit shift 4 bits left
    orr r0, r0, r1 ; or r0 and r1
	LDMFD sp!, {lr}
	mov pc, lr

;* converts a byte to x and y
;* input  - r0 - byte
;* output - r0 - x, r1 - y
byte_to_coord:
	STMFD SP!,{lr}
    mov r1, r0          ; store to get y
    asr r0, r0, #4      ; shift x down to <8
    and r1, r1, #0x0F   ; get y down to <8
    cmp r1, #0xF
    bne _exit_byte_to_coord
    mov r0, #0
    mov r1, #-1
_exit_byte_to_coord:
	LDMFD sp!, {lr}
	mov pc, lr


;* loops subboard to check if game is finished
;* input  - 
;* output - r0 - 1 win, 0 fail
check_win:
	STMFD SP!,{lr}
    ldr r4, ptr_to_sub_board

_check_win_loop:
    ldrb r1, [r4], #1
    cmp r1, #SPACE
    beq _check_win_fail
    cmp r1, #0
    bne _check_win_loop

    mov r0, #1
    b _exit_check_win
_check_win_fail:
    mov r0, #0
_exit_check_win:
	LDMFD sp!, {lr}
	mov pc, lr

;* finds the last link after pause
;* input  - r0 (byte 1), r1 (last byte). r2 - color
;* output - r0 - char
last_link:
	STMFD SP!,{lr, r4-r6}
    cmp r1, #0
    beq _do_nothing
    mov r4, r1
    mov r6, r2      ; save color

    bl byte_to_coord
    bl get_subboard_ptr
    mov r5, r0          ; ptr 1

    mov r0, r4
    bl byte_to_coord
    bl get_subboard_ptr
    mov r4, r0          ; ptr 2

_look_left:
    sub r0, r4, #1
    ldrb r1, [r0]
    cmp r0, r5      ; newptr != ptr 2
    beq _look_right
    cmp r1, r6      ; pos == O
    bne _look_right

    add r3, r4, #1  ; determine char
    cmp r3, r5      ; prev not right
    bne _char_plus  ; must be plus
    mov r0, #HORIZ
    b _exit_last_link
_look_right:
    add r0, r4, #1
    ldrb r1, [r0]
    cmp r0, r5      ; newptr != ptr 2
    beq _look_up
    cmp r1, r6      ; pos == O
    bne _look_up

    sub r3, r4, #1  ; determine char
    cmp r3, r5      ; prev not left
    bne _char_plus  ; must be plus
    mov r0, #HORIZ
    b _exit_last_link
_look_up:
    sub r0, r4, #8
    ldrb r1, [r0]
    cmp r0, r5      ; newptr != ptr 2
    beq _look_down
    cmp r1, r6      ; pos == O
    bne _look_down

    add r3, r4, #8  ; determine char
    cmp r3, r5      ; prev not down
    bne _char_plus  ; must be plus
    mov r0, #VERT
    b _exit_last_link
_look_down:
    add r0, r4, #8
    ldrb r1, [r0]
    cmp r0, r5      ; newptr != ptr 2
    beq _char_plus
    cmp r1, r6      ; pos == O
    bne _char_plus

    sub r3, r4, #8  ; determine char
    cmp r3, r5      ; prev not up
    bne _char_plus  ; must be plus
    mov r0, #VERT
    b _exit_last_link

_char_plus:
    mov r0, #PLUS
    b _exit_last_link
_do_nothing:
    mov r0, #0
_exit_last_link:
	LDMFD sp!, {lr, r4-r6}
	mov pc, lr
;*******************************************;
    .end
