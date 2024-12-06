addi $10, $0, 0
addi $11, $0, 3
addi $2, $0, 1
LOOP:
pkey $1
#addi $20, $0, 0
#addi $21, $0, 100000
#INNER:
#addi $20, $20, 1
#bne $20, $0, INNER
bne $1, $2, LOOP
addi $10, $10, 1
bne $10, $11, SKIP
addi $10, $0, 0
SKIP:
ssta $10
j LOOP
