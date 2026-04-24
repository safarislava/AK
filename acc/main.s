    .data

input_addr:      .word  0x80
output_addr:     .word  0x84
first_byte:      .word  0xFF000000
second_byte:     .word  0x00FF0000
third_byte:      .word  0x0000FF00
fourth_byte:     .word  0x000000FF
long_offset:     .word  24
short_offset:    .word  8
n:               .word  0
result:          .word  0

    .text

_start:
    load         input_addr
    load_acc
    store        n

    and          first_byte
    shiftr       long_offset
    and          fourth_byte
    store        result

    load         n
    and          second_byte
    shiftr       short_offset
    or           result
    store        result

    load         n
    and          third_byte
    shiftl       short_offset
    or           result
    store        result

    load         n
    and          fourth_byte
    shiftl       long_offset
    or           result

    store_ind    output_addr
    halt