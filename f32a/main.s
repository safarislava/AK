    .data
.org                0x100

input_addr:         .word 0x80
output_addr:        .word 0x84
buffer_pointer:     .word 0x0
buffer_size:        .word 0x20
    


    .text

_start:
    @p      buffer_pointer 
    a!                          \ Load buffer pointer into A
    lit     0x1F 
    >r                          \ Set 0x20 iteration

init_loop:                      \ Init buffer with _
    lit     0x5F              
    !+
    next    init_loop

    lit     0x0                 \ Index of current byte in buffer
    @p      input_addr   
    a!                          \ Load input address to A

loop:
    @                           \ Read data from input

    dup                         \ If read symbol is \n than stop
    lit     0xa
    negate
    +
    if      end_loop

    capitalize

    over                        \ Pull index with saving current A
    a
    over

    a!                          \ Read index to A

    over                        \ Pull capitalized symbol
    !+                          \ Write symbol by index

    a                           \ Push index to stack

    dup                         \ Chech that index not greater than buffer size
    @p      buffer_size
    negate
    +
    if      overflow

    over                        \ Restore input address
    a!                          

    loop ;                      

end_loop:
    drop                        \ Drop \n
    a!                          \ Read index to A

    lit     0x5f5f5f00          \ Add suffix
    !

    @p      buffer_pointer
    a!              

    @p      output_addr
    b!

output_loop:
    @+                          \ Read byte from buffer
    lit 0xFF
    and

    dup                         \ If 0 than end of line
    if halt

    !b                          \ Write to output

    output_loop ;

halt:
    halt

overflow:
    @p      output_addr
    b!
    lit     0xCCCCCCCC
    !b
    halt



capitalize:
    is_small_case
    if      not_change_case
    lit     0x20
    negate
    +
not_change_case:
    ;



is_small_case:
    dup
    lit     0x61
    over
    negate
    +
    -if     non_small_case
    dup
    lit     0x7a
    negate
    +
    -if     non_small_case
    lit     1
    ;
non_small_case:
    lit     0
    ;



negate:
    inv
    lit     1
    +
    ;