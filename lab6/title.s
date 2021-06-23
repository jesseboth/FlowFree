    .data

    ;; 80 by 22 -- 1 tab (9) - 9 spaces
            ;* .string 0xA, 0xA, 0xA, 0xA, 0xA, 0xA, 0xA,0xA, 0xA, 0xA, 0xA, 0xA, 0xA, 0xA, 0xA, 0xA, 0xA, 0xA, 0xA, 0xA
        ;* 27, "[41m                                                                                " 
title:  .string 27, "[40m", 27, "[1;1H",0xA, 0xA, 0xA, 0xA, 0xA, 0xA
        .string 27, "[40m  ",27, "[41m       ", 27, "[40m  ", 27, "[41m  ", 27, "[40m         ", 27, "[41m      ", 27, "[40m    ",                         27, "[41m  ", 27, "[40m      ", 27, "[41m  ", 27, "[40m  ", 27, "[44m       ", 27, "[40m  ", 27, "[44m      ", 27, "[40m   ", 27, "[44m       ", 27, "[40m  ", 27, "[44m       ", 27, "[40m  ", 0xA, 0xD
        .string 27, "[40m  ",27, "[41m  ", 27, "[40m       ", 27, "[41m  ", 27, "[40m        ", 27, "[41m  ", 27, "[40m    ", 27, "[41m  ", 27, "[40m   ", 27, "[41m  ", 27, "[40m      ", 27, "[41m  ",  27, "[40m  ", 27, "[44m  ", 27, "[40m       ", 27, "[44m  ", 27, "[40m    ", 27, "[44m ", 27, "[40m  ", 27, "[44m  ", 27, "[40m       ", 27, "[44m  ", 27, "[40m       ", 0xA, 0xD
        .string 27, "[40m  ",27, "[41m     ", 27, "[40m    ", 27, "[41m  ", 27, "[40m       ", 27, "[41m  ", 27, "[40m      ", 27, "[41m  ", 27, "[40m  ", 27, "[41m  ", 27, "[40m      ", 27, "[41m  ", 27, "[40m  ", 27, "[44m     ", 27, "[40m    ", 27, "[44m      ",                         27, "[40m   ", 27, "[44m     ", 27, "[40m    ", 27, "[44m     ", 27, "[40m    ", 0xA, 0xD
        .string 27, "[40m  ",27, "[41m  ", 27, "[40m       ", 27, "[41m  ", 27, "[40m        ", 27, "[41m  ", 27, "[40m    ", 27, "[41m  ", 27, "[40m   ", 27, "[41m  ", 27, "[40m  ", 27, "[41m  ", 27, "[40m  ", 27, "[41m  ", 27, "[40m  ", 27, "[44m  ", 27, "[40m       ", 27, "[44m  ", 27, "[40m  ", 27, "[44m  ", 27, "[40m   ", 27, "[44m  ", 27, "[40m       ", 27, "[44m  ", 27, "[40m       ",0xA, 0xD
        .string 27, "[40m  ",27, "[41m  ", 27, "[40m       ", 27, "[41m       ", 27, "[40m    ", 27, "[41m      ", 27, "[40m      ",                       27, "[41m  ", 27, "[40m  ", 27, "[41m  ", 27, "[40m  ", 27, "[40m  ", 27, "[44m  ", 27, "[40m       ", 27, "[44m  ", 27, "[40m   ", 27, "[44m  ", 27, "[40m  ", 27, "[44m       ", 27, "[40m  ", 27, "[44m       ", 27, "[40;0mR ", 0xA, 0xD
        .string 27, "[14;31H",27, "[37;1mPress: ", 27, "[31;5mEnter", 27, "[37;0;1m to Start"
os:     .string 27, "[2;4H",27, "[31mO"
        .string 27, "[20;7H",27, "[31mO"
        .string 27, "[6;60H",27, "[31mO"
        .string 27, "[20;40H",27, "[31mO"

        .string 27, "[8;37H",27, "[32mO"
        .string 27, "[3;70H",27, "[32mO"
        .string 27, "[17;65H",27, "[32mO"

        .string 27, "[9;18H",27, "[33mO"
        .string 27, "[17;40H",27, "[33mO"
        .string 27, "[3;48H",27, "[33mO"

        .string 27, "[21;52H",27, "[34mO"
        .string 27, "[4;32H",27, "[34mO"
        .string 27, "[13;10H",27, "[34mO"

        .string 27, "[16;25H",27, "[35mO"
        .string 27, "[21;72H",27, "[35mO"
        .string 27, "[11;50H",27, "[35mO"

        .string 27, "[4;16H",27, "[36mO"
        .string 27, "[20;25H",27, "[36mO"
        .string 27, "[16;52H",27, "[36mO"

        .string 27, "[23;23H",27, "[37mO"
        .string 27, "[15;74H",27, "[37mO"
        .string 27, "[5;42H",27, "[37mO"

        .string 27, "[40m", 27, "[1;1H",0


end:    .string 27, "[7;32H", 27, "[47m                    "
        .string 27, "[8;32H", 27, "[47m                    "
        .string 27, "[9;32H", 27, "[47m                    "
        .string 27, "[10;32H", 27, "[47m                    "
        .string 27, "[11;32H", 27, "[47m                    " 
        .string 27, "[12;32H", 27, "[47m                    "

board_num:.string 27, "[8;33H", 27,"[30mBoard 00 Completed"
        .string 27, "[10;34H", 27,"[30mCompletion Time:"
        .string 27, "[14;29H",27, "[37;40;1mPress: ", 27, "[31;5mEnter", 27, "[37;0;1m to Play Again"
        .string 27, "[11;61H",27, "[35mO"
        .string 27, "[8;76H",27, "[32mO"
sec:    .string 27, "[11;43H",27, "[30;47ms"
done:   .string 27, "[40m", 27, "[1;1H",0


pause_screen:    .string 27, "[7;32H", 27, "[47m                    "
        .string 27, "[8;32H", 27, "[47m                    "
        .string 27, "[9;32H", 27, "[47m                    "
        .string 27, "[10;32H", 27, "[47m                    "
        .string 27, "[11;32H", 27, "[47m                    "
        .string 27, "[12;32H", 27, "[47m                    "

pause_mess:.string 27, "[11;38H", 27,"[30mBoard 00"
        .string 27, "[8;36H", 27,"[30mYour Game is"
		.string 27, "[9;34H", 27,"[30mCurrently Paused"
        .string 27, "[14;32H",27, "[37;40;1mPress: ", 27, "[34;1mSW2", 27, "[37;0;1m to Resume"
        .string 27, "[16;28H",27, "[37;40;1mPress: ", 27, "[31;1mEnter", 27, "[37;0;1m to Restart Level"
        .string 27, "[17;27H",27, "[37;40;1mPress: ", 27, "[31;1mEscape", 27, "[37;0;1m to Play New Level"
        .string 27, "[11;61H",27, "[35mO"
        .string 27, "[8;76H",27, "[32mO"

pause_done:   .string 27, "[40m", 27, "[1;1H",0


clear: .string 27, "[2J", 0

nums_out:.string 27, "[11;42H",27,"[30;47m"
nums:   .string "00000000", 0

time_int

    .text
    .global make_title
    .global make_end
    .global output_string
    .global output_character
    .global num_digits
    .global int2str
    .global make_pause

ptr_to_title:   .word title
ptr_to_end:     .word end
ptr_to_pause_screen:     .word pause_screen

ptr_to_clear:   .word clear
ptr_to_board_num:.word board_num
ptr_to_os:      .word os
ptr_to_sec:     .word sec
ptr_to_nums:    .word nums
ptr_to_nums_out:.word nums_out
ptr_to_done:    .word done
ptr_to_pause_done:    .word pause_done
ptr_to_pause_mess .word pause_mess

;* prints title to the screen
;* input  - 
;* output - 
make_title:
	STMFD SP!,{lr, r0}
	ldr r0, ptr_to_clear
    bl output_string
    ldr r0, ptr_to_title
    bl output_string

	LDMFD SP!,{lr, r0}
	MOV pc, lr

;* prints end screen
;* input  - r0 - final timer, r1, board_number
;* output - 
make_end:
	STMFD SP!,{lr, r4-r6}
    mov r4, r0
    mov r5, r1

    mov r6, #2      ; s starting pt
    bl num_digits
    mov r2, #2      ; div by
    udiv r3, r0, r2 ; split
    add r2, r3, r6  ; increment
    ldr r1, ptr_to_sec
    add r2, r2, #0x30   ; to char
    strb r2, [r1,#6]    ; store

    mov r6, #41    ; starting pt
    sub r2, r6, r3  ; decrement
    mov r0, r2
    ldr r1, ptr_to_nums
    bl int2str

    ldr r2, ptr_to_nums_out
    ldrb r0, [r1]
    strb r0, [r2, #5]
    ldrb r0, [r1, #1]
    strb r0, [r2, #6]

    mov r0, r4
    ldr r1, ptr_to_nums
    bl int2str

    ldr r4, ptr_to_board_num
    cmp r5, #0xA
    bge _board_over_ten

    mov r6, #0x30
    add r5, r5, #0x30
    strb r6, [r4, #18]
    strb r5, [r4, #19]

    b _print_the_stuff


_board_over_ten:
    mov r6, #0x31
    add r5, r5, #0x26 ; 0x30 - 0xA = 0x26
    strb r6, [r4, #18]
    strb r5, [r4, #19]


_print_the_stuff:
    ldr r0, ptr_to_clear
    bl output_string
    ldr r0, ptr_to_os
    bl output_string
    ldr r0, ptr_to_end
    bl output_string
    ldr r0, ptr_to_nums_out
    bl output_string
    ldr r0, ptr_to_done
    bl output_string

	LDMFD SP!,{lr, r4-r6}
	MOV pc, lr

;* pause screen
;* input  - r0 - board_number
;* output - 
make_pause:
	STMFD SP!,{lr, r4-r6}
    mov r5, r0
    ldr r4, ptr_to_pause_mess

    cmp r5, #0xA
    bge _pause_board_over_ten

    mov r6, #0x30
    add r5, r5, #0x30
    strb r6, [r4, #19]
    strb r5, [r4, #20]

    b _print_pause


_pause_board_over_ten:
    mov r6, #0x31
    add r5, r5, #0x26 ; 0x30 - 0xA = 0x26
    strb r6, [r4, #19]
    strb r5, [r4, #20]

_print_pause:
    ldr r0, ptr_to_clear
    bl output_string
    ldr r0, ptr_to_os
    bl output_string
    ldr r0, ptr_to_pause_screen
    bl output_string


	LDMFD SP!,{lr, r4-r6}
	MOV pc, lr
    .end
