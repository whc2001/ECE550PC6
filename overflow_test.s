nop

lw $1, 8($0)    # $1 has 2147483647
addi $2, $0, 1  # $2 has 1
addi $10, $1, 1 # addi ovf = 2
add $11, $1, $2 # add ovf = 1
lw $3, 9($0)    # $3 has -2147483648
sub $12, $3, $2 # sub ovf = 3
