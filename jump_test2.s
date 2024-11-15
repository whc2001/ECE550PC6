nop
setx 1
jal FUN
bne $1, $2, ERR
jal FUN
addi $2, $2, 1
setx 2
bex OK
j ERR
OK:
j OK

FUN:
addi $2, $0, 10
LOOP:
addi $1, $1, 1
blt $1, $2, LOOP
jr $31

ERR:
j ERR
