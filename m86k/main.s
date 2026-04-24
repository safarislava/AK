    .data
.org            0x100

input_addr:     .word 0x80
output_addr:    .word 0x84
buffer_pointer: .word 0x0
buffer_size:    .word 0x40



    .text

_start:
    movea.l 1000,   A7 
    movea.l input_addr,     A0
    movea.l (A0),   A0
    movea.l buffer_pointer, A1
    movea.l (A1),   A1
    movea.l output_addr,    A2
    movea.l (A2),   A2
    movea.l buffer_size,    A3
    move.l  0,      D5          ; Count of read symbols from input
    move.l  16,     D2          ; Count of bits that needs to shift left for entire second byte

read_symbol:
    move.l  (A0),   D0          ; Read symbol 
    add.l   1,      D5     

    cmp.l   D5,   (A3)          ; If count of read symbol >= buffer
    beq     buffer_overflow

    cmp.l   0xA,    D0          ; If it is \n
    beq     line_end

    cmp.l   0x3D,    D0         ; If it is =
    beq     read_symbol_end

    jsr     symbol_to_index     ; Translate symbol
    cmp.l   -1,     D0
    beq     error

    asl.l   6,      D1          ; Merge with D1 and count lenght of D1
    or.l    D0,     D1
    sub.l   6,      D2

    cmp.l   8,      D2          ; If less than byte
    bgt     read_symbol

    lsl.l   D2,     D1          ; Shift for entire second byte

    move.b  D1,     D3          ; Write remainder
    lsr.l   D2,     D3

    lsr.l   8,      D1          ; Write entire byte into buffer where D4 offset from buffer pointer
    move.b  D1,     (A1, D4)
    add.l   1,      D4

    move.l  D3,     D1          ; Restore remainder
    add.l   8,      D2          ; Restore count of bits that needs to shift left for entire second byte
    jmp     read_symbol         ; Loop

read_symbol_end:
    jsr     clear_input
line_end:
    move.l  D4,     (A3)
    move.l  0,       D4

write:
    cmp.l   D4,     (A3)
    beq     write_end
    move.b  (A1, D4),   (A2) 
    add.l   1,      D4
    jmp     write

write_end:
    halt

buffer_overflow:
    move.l  0xCCCCCCCC, (A2)
    halt

error:
    jsr     clear_input
    move.l  -1, (A2)
    halt



; Input - D0, Output - D0
; Doesn't change another data registers
; -1 if wrong symbol
symbol_to_index:
    cmp.l   0x41,   D0          ; A-Z
    blt     check_low
    cmp.l   0x5A,   D0
    bgt     check_low
    sub.l   0x41,   D0
    rts

check_low:
    cmp.l   0x61,   D0          ; a-z
    blt     check_digit
    cmp.l   0x7A,   D0
    bgt     check_digit
    sub.l   0x61,   D0
    add.l   26,     D0
    rts

check_digit:
    cmp.l   0x30,   D0          ; 0-9
    blt     check_plus
    cmp.l   0x39,   D0
    bgt     check_plus
    sub.l   0x30,   D0
    add.l   52,     D0
    rts

check_plus:
    cmp.l   0x2B,   D0          ; +
    bne     check_slash
    move.l  62,     D0
    rts

check_slash:
    cmp.l   0x2F,   D0          ; /
    bne     sym_error
    move.l  63,     D0
    rts

sym_error:
    move.l  -1,     D0
    rts



; Change D0
clear_input:
    move.l  (A0),   D0
    cmp.l   0xA,    D0
    beq     clear_input_end
    jmp     clear_input
clear_input_end:
    rts
