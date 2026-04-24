    .data

input_addr:     .word 0x80
output_addr:    .word 0x84
stack_pointer:  .word 0x500



    .text

_start:
    lui     t0,     %hi(input_addr)         ; Load intput address
    addi    t0,     t0,     %lo(input_addr)
    lw      t0,     0(t0)

    lui     t6,     %hi(output_addr)        ; Load output address
    addi    t6,     t6,     %lo(output_addr)
    lw      t6,     0(t6)

    lui     sp,     %hi(stack_pointer)      ; Load stack pointer
    addi    sp,     sp,     %lo(stack_pointer)
    lw      sp,     0(sp)
    
    lw      t0,     0(t0)
    ble     t0,     zero,   invalid_data

    addi    sp,     sp,     4
    jal     ra,     calc
    addi    sp,     sp,    -4
    bnez    t1,     overflow
    lw      t1,     0(sp)

    sw      t1,     0(t6)                   
    j       stw

invalid_data:
    addi    t0,     zero,   -1
    sw      t0,     0(t6)
    j       stw

overflow:
    lui     t0,     0xCCCCC
    addi    t0,     t0,     0xCCC
    sw      t0,     0(t6)

stw:
    halt                                    ; STW




    .text
.org        0x88
; t0 - n. t1 - output status. also use t2, t3
calc:
    sw      ra,     0(sp)
    addi    sp,     sp,     4

    mv      t3,     zero
    addi    t3,     t3,     2
    rem     t1,     t0,     t3

    beqz    t1,     even    
odd:
    addi    t1,     t0,     1
    div     t1,     t1,     t3
    j       mul_stage

even:
    addi    t0,     t0,     1
    div     t1,     t0,     t3

mul_stage:
    mul     t3,     t0,     t1

    mulh    t2,     t0,     t1

    mv      t1,     zero
    bnez    t2,     calc_overflow
    ble     t3,     zero,   calc_overflow
    
    sw      t3,     -8(sp)
    j       calc_return

calc_overflow:
    addi    t1,     t1,     1

calc_return:
    addi    sp,     sp,     -4
    lw      ra,     0(sp)    
    jr      ra
