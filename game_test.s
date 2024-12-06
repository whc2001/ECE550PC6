#
#          Flappy Bird
# MIPS-like instruction set
# Instructions: add, addi, sub, and, or, not, sll, sra, bne, blt, j, nop, jal, jr
# Custom instructions:
#  pkey $rd - poll key status (0=no new event, 1=pressed)
#  ssta $rd - set game state (0=title, 1=playing, 2=game over)
#  spos $rd - set bird y position
#  sscr $rd - set score
#  pobx1~3/poby1~3 $rd - poll pipe 1~3 x/y position
#  rsed - random reseed
#define STATE_TITLE 0
#define STATE_PLAYING 1
#define STATE_GAME_OVER 2
#define BIRD_TIMER_DIVIDER 25000
#define BIRD_JUMP_ACC 10
#define BIRD_FALL_ACC_MAX 9
#define BIRD_HEIGHT 24
#define FLOOR_Y 395

#define $GAME_STATE $1
#define $BIRD_Y $2
#define $SCORE $3
#define $PIPE_X $4
#define $PIPE_Y $5
# Dir: 0=falling, 1=jumping
#define $BIRD_DIR $10
#define $BIRD_ACC $11
#define $BIRD_TIMER $20
#define $TEMP $28
#define $TEMP2 $27
#define $KEY_STATUS $29

# Entry point
addi $GAME_STATE, $0, 0
MAIN_LOOP:

# Detect key press
addi $TEMP, $0, 1
pkey $KEY_STATUS
bne $KEY_STATUS, $TEMP, LOOP_LOGIC

addi $TEMP, $0, STATE_TITLE
bne $GAME_STATE, $TEMP, KEY_ELSE1
# title {
addi $BIRD_TIMER, $0, 0
# Set bird to center of screen, start falling
addi $BIRD_Y, $0, 216
addi $BIRD_DIR, $0, 0
addi $BIRD_ACC, $0, 5
spos $BIRD_Y
# Set score to 0
addi $SCORE, $0, 0
sscr $SCORE
# Reseed RNG
rsed
# Set game state to playing
addi $GAME_STATE, $0, STATE_PLAYING
ssta $GAME_STATE
# }
j LOOP_LOGIC
KEY_ELSE1:
addi $TEMP, $0, STATE_PLAYING
bne $GAME_STATE, $TEMP, KEY_ELSE2
# playing {
# Set bird to jump
addi $BIRD_DIR, $0, 1
addi $BIRD_ACC, $0, BIRD_JUMP_ACC
# }
j LOOP_LOGIC
KEY_ELSE2:
addi $TEMP, $0, STATE_GAME_OVER
bne $GAME_STATE, $TEMP, LOOP_LOGIC
# game over {
# Set game state to title
addi $GAME_STATE, $0, STATE_TITLE
ssta $GAME_STATE
# }
j LOOP_LOGIC

LOOP_LOGIC:
# Logic during game, if not playing, skip
addi $TEMP, $0, STATE_PLAYING
bne $GAME_STATE, $TEMP, MAIN_LOOP
# playing {
addi $BIRD_TIMER, $BIRD_TIMER, 1
addi $TEMP, $0, BIRD_TIMER_DIVIDER
bne $BIRD_TIMER, $TEMP, MAIN_LOOP
addi $BIRD_TIMER, $0, 0
# time to update bird position {
bne $BIRD_DIR, $0, BIRD_JUMP
# bird falling {
addi $TEMP, $0, 1
addi $BIRD_ACC, $BIRD_ACC, 1
# cap acceleration to BIRD_FALL_ACC_MAX
addi $TEMP, $0, BIRD_FALL_ACC_MAX
blt $BIRD_ACC, $TEMP, BIRD_FALL
addi $BIRD_ACC, $0, BIRD_FALL_ACC_MAX
j BIRD_FALL

BIRD_JUMP:
# bird jumping {
# accel decrease till 0
addi $TEMP, $0, 1
sub $BIRD_ACC, $BIRD_ACC, $TEMP
# if accel is 0, start falling
bne $BIRD_ACC, $0, BIRD_RISE
addi $BIRD_DIR, $0, 0
addi $BIRD_ACC, $0, 1
j BIRD_FALL

BIRD_RISE:
sub $BIRD_Y, $BIRD_Y, $BIRD_ACC
# If less than 0, set to 0
addi $TEMP, $0, 0
blt $BIRD_Y, $TEMP, BIRD_CAP
spos $BIRD_Y
j DETECTION
BIRD_CAP:
addi $BIRD_Y, $0, 0
spos $BIRD_Y
j DETECTION

BIRD_FALL:
add $BIRD_Y, $BIRD_Y, $BIRD_ACC
# If more than 480, set to 480
addi $TEMP, $0, 480
blt $TEMP, $BIRD_Y, BIRD_CAP2
spos $BIRD_Y
j DETECTION
BIRD_CAP2:
addi $BIRD_Y, $0, 480
spos $BIRD_Y
j DETECTION

DETECTION:
# If bird hit floor, game over
addi $TEMP, $BIRD_Y, 0
addi $TEMP, $TEMP, BIRD_HEIGHT
addi $TEMP2, $0, FLOOR_Y
blt $TEMP, $TEMP2, MAIN_LOOP
addi $GAME_STATE, $0, STATE_GAME_OVER
ssta $GAME_STATE
j MAIN_LOOP
