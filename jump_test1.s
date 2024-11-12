bne $1, $0, 2
nop
nop
addi $1, $0, 1
bne $1, $0, 2
nop
nop
blt $1, $0, 2
nop
nop
blt $0, $1, 2
nop
nop
bex TEST1
nop
nop
TEST1: nop
setx 1
bex TEST2
nop
nop
TEST2: nop
jal TEST3
j TEST4
TEST3: nop
jr $31
TEST4: nop