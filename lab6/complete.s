    .data
comp            .char 0,0
comp_space:     .space 7 
comp_text:      .string 27,"[s",27,"[04;44;H","0",27,"[u",0 ; 12 offset
    
    .text
    .global modify_completed
    .global clear_completed
    .global reprint_completed
    .global check_completed
    .global output_string
    .global check_win
ptr_to_comp:        .word comp
ptr_to_comp_space:  .word comp_space
ptr_to_comp_text:   .word comp_text


COMP_offset:    .equ 0xC

;* increment completed int
;* input  - r0 - increment by, r1 - color
;* output - r0 - 0 for gameover, 1 for continue
modify_completed:
	STMFD SP!,{lr, r4}
    sub r1, r1, #1      ; deccrement to start at 0
    ldr r4, ptr_to_comp_space
    add r4, r4, r1      ; increment to correct space

    cmp r0, #0
    blt _remove_completed
_add_completed:
    ldrb r2, [r4]   ; get current char in space
    cmp r2, #0
    bne _exit_modify_completed

    mov r3, #1
    strb r3, [r4]   ; store 1 to indicate complete link

    ldr r4, ptr_to_comp
    ldrb r2, [r4]
    add r0, r2, #1  ; increment completed
    strb r0, [r4]
    bl output_completed

    b _exit_modify_completed
_remove_completed:
    ldrb r2, [r4]   ; get current char in space
    cmp r2, #0
    beq _exit_modify_completed

    mov r3, #0
    strb r3, [r4]   ; store 0 to show broken link

    ldr r4, ptr_to_comp
    ldrb r2, [r4]
    sub r0, r2, #1  ; decrement
    strb r0, [r4]
    bl output_completed

_exit_modify_completed:
	LDMFD sp!, {lr, r4}
	mov pc, lr

;* outputs the completed value to screen
;* input - r0 - int
;* output - r0 - 0 for gameover, 1 for continue
output_completed:
	STMFD SP!,{lr, r4-r5}
    mov r5, r0               ; preserve
    add r0, r0, #0x30        ; convert to a char

    ldr r4, ptr_to_comp_text
    strb r0, [r4, #COMP_offset]

    mov r0, r4
    bl output_string

    cmp r5, #7
    bne _exit_output_completed
    bl check_win

_exit_output_completed:
	LDMFD sp!, {lr, r4-r5}
	mov pc, lr

;* clears the completed space to 0
;* input - 
;* output -
clear_completed:
	STMFD SP!,{lr, r4-r5}

    ldr r4, ptr_to_comp_space
    ldr r5, ptr_to_comp
    mov r0, #0
    strb r0, [r5]
    strb r0, [r4]
    strb r0, [r4, #1]
    strb r0, [r4, #2]
    strb r0, [r4, #3]
    strb r0, [r4, #4]
    strb r0, [r4, #5]
    strb r0, [r4, #6]

	LDMFD sp!,{lr, r4-r5}
	mov pc, lr

;* check link completion
;* input - r0-color
;* output - r0 (1 for yes, 0 no)
check_completed:
	STMFD SP!,{lr, r4}

    sub r0, r0, #1      ; start at 0
    ldr r4, ptr_to_comp_space
    add r4, r4, r0
    ldrb r0, [r4]

_exit_check_completed
	LDMFD sp!,{lr, r4}
	mov pc, lr

;* reprints completed
;* input - 
;* output -
reprint_completed:
	STMFD SP!,{lr}
    ldr r0, ptr_to_comp
    ldrb r0, [r0]
    bl output_completed
	LDMFD sp!,{lr}
	mov pc, lr

    .end