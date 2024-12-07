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
#define BIRD_TIMER_DIVIDER 8000
#define BIRD_JUMP_ACC 10
#define BIRD_FALL_ACC_MAX 9
#define BIRD_HEIGHT 24
#define BIRD_WIDTH 34
#define BIRD_X 303
#define FLOOR_Y 395
#define PIPE_WIDTH 52
#define PIPE_GAP 100
#define DIF 2

#define $GAME_STATE $1
#define $BIRD_Y $2
#define $SCORE $3
#define $PIPE_X1 $4
#define $PIPE_Y1 $5
#define $PIPE_X2 $6
#define $PIPE_Y2 $7
#define $PIPE_X3 $8
#define $PIPE_Y3 $9
# Dir: 0=falling, 1=jumping
#define $BIRD_DIR $10
#define $BIRD_ACC $11
#define $PIPE1_SCORE $12
#define $PIPE2_SCORE $13
#define $PIPE3_SCORE $14
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
bne $KEY_STATUS, $TEMP, GAME_LOGIC
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
# Set pipe scoring mark
addi $PIPE1_SCORE, $0, 0
addi $PIPE2_SCORE, $0, 0
addi $PIPE3_SCORE, $0, 0
# }
j GAME_LOGIC

KEY_ELSE1:
addi $TEMP, $0, STATE_PLAYING
bne $GAME_STATE, $TEMP, KEY_ELSE2
# playing {
# Set bird to jump
addi $BIRD_DIR, $0, 1
addi $BIRD_ACC, $0, BIRD_JUMP_ACC
# }
j GAME_LOGIC

KEY_ELSE2:
addi $TEMP, $0, STATE_GAME_OVER
bne $GAME_STATE, $TEMP, GAME_LOGIC
# game over {
# Set game state to title
addi $GAME_STATE, $0, STATE_TITLE
ssta $GAME_STATE
# }
j GAME_LOGIC

GAME_LOGIC:
# Logic during game, if not playing, skip
addi $TEMP, $0, STATE_PLAYING
bne $GAME_STATE, $TEMP, MAIN_LOOP
# playing {
# Check floor collision
addi $TEMP, $BIRD_Y, BIRD_HEIGHT
addi $TEMP2, $0, FLOOR_Y
blt $TEMP, $TEMP2, CHECK_PIPE
j COLLIDED

CHECK_PIPE:
# Check pipe collision
pobx1 $PIPE_X1
pobx2 $PIPE_X2
pobx3 $PIPE_X3
poby1 $PIPE_Y1
poby2 $PIPE_Y2
poby3 $PIPE_Y3
# PIPE_X <= BIRD_X + BIRD_WIDTH
addi $TEMP, $0, BIRD_WIDTH
addi $TEMP, $TEMP, BIRD_X
addi $TEMP2, $PIPE_X1, DIF
blt $TEMP, $TEMP2, CHECK_COLLISION2
# BIRD_X <= PIPE_X + PIPE_WIDTH
addi $TEMP, $PIPE_X1, PIPE_WIDTH
addi $TEMP, $TEMP, -DIF
addi $TEMP2, $0, BIRD_X
blt $TEMP, $TEMP2, CHECK_COLLISION2
# y_bird < pipe_y
blt $BIRD_Y, $PIPE_Y1, COLLIDED
# y_bird + BIRD_HEIGHT > (pipe_y + PIPE_GAP)
addi $TEMP, $BIRD_Y, BIRD_HEIGHT
addi $TEMP2, $PIPE_Y1, PIPE_GAP
blt $TEMP2, $TEMP, COLLIDED
CHECK_COLLISION2:
# PIPE_X <= BIRD_X + BIRD_WIDTH
addi $TEMP, $0, BIRD_WIDTH
addi $TEMP, $TEMP, BIRD_X
addi $TEMP2, $PIPE_X2, DIF
blt $TEMP, $TEMP2, CHECK_COLLISION3
# BIRD_X <= PIPE_X + PIPE_WIDTH
addi $TEMP, $PIPE_X2, PIPE_WIDTH
addi $TEMP, $TEMP, -DIF
addi $TEMP2, $0, BIRD_X
blt $TEMP, $TEMP2, CHECK_COLLISION3
# y_bird < pipe_y
blt $BIRD_Y, $PIPE_Y2, COLLIDED
# y_bird + BIRD_HEIGHT > (pipe_y + PIPE_GAP)
addi $TEMP, $BIRD_Y, BIRD_HEIGHT
addi $TEMP2, $PIPE_Y2, PIPE_GAP
blt $TEMP2, $TEMP, COLLIDED
CHECK_COLLISION3:
# PIPE_X <= BIRD_X + BIRD_WIDTH
addi $TEMP, $0, BIRD_WIDTH
addi $TEMP, $TEMP, BIRD_X
addi $TEMP2, $PIPE_X3, DIF
blt $TEMP, $TEMP2, BIRD_MOVE
# BIRD_X <= PIPE_X + PIPE_WIDTH
addi $TEMP, $PIPE_X3, PIPE_WIDTH
addi $TEMP, $TEMP, -DIF
addi $TEMP2, $0, BIRD_X
blt $TEMP, $TEMP2, BIRD_MOVE
# y_bird < pipe_y
blt $BIRD_Y, $PIPE_Y3, COLLIDED
# y_bird + BIRD_HEIGHT > (pipe_y + PIPE_GAP)
addi $TEMP, $BIRD_Y, BIRD_HEIGHT
addi $TEMP2, $PIPE_Y3, PIPE_GAP
blt $TEMP2, $TEMP, COLLIDED

BIRD_MOVE:
# Bird Move
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
# If less than -24, set to -24
addi $TEMP, $0, -24
blt $BIRD_Y, $TEMP, BIRD_CAP
spos $BIRD_Y
j MAIN_LOOP
BIRD_CAP:
addi $BIRD_Y, $0, -24
spos $BIRD_Y
j MAIN_LOOP

BIRD_FALL:
add $BIRD_Y, $BIRD_Y, $BIRD_ACC
# If more than 480, set to 480
addi $TEMP, $0, 480
blt $TEMP, $BIRD_Y, BIRD_CAP2
spos $BIRD_Y
j MAIN_LOOP
BIRD_CAP2:
addi $BIRD_Y, $0, 480
spos $BIRD_Y
j MAIN_LOOP

COLLIDED:
addi $GAME_STATE, $0, STATE_GAME_OVER
ssta $GAME_STATE
j MAIN_LOOP


# ####################################################
# CHECK_SCORE:
# blt $PIPE_X1, $0, PIPE1_MARK
# # pipe1_x + PIPE_WIDTH < BIRD_X
# addi $TEMP, $PIPE_X1, PIPE_WIDTH
# addi $TEMP2, $0, BIRD_X
# blt $TEMP, $TEMP2, PIPE1_CHECK
# 
# CHECK_SCORE2:
# blt $PIPE_X2, $0, PIPE2_MARK
# addi $TEMP, $PIPE_X2, PIPE_WIDTH
# blt $TEMP, $TEMP2, PIPE2_CHECK
# 
# CHECK_SCORE3:
# blt $PIPE_X3, $0, PIPE3_MARK
# addi $TEMP, $PIPE_X3, PIPE_WIDTH
# blt $TEMP, $TEMP2, PIPE3_CHECK
# j MAIN_LOOP
# 
# PIPE1_MARK:
# addi $PIPE1_SCORE, $0, 0
# j CHECK_SCORE2
# 
# PIPE1_CHECK:
# # check if pipe1 score has already been counted
# blt $0, $PIPE1_SCORE, CHECK_SCORE2
# addi $PIPE1_SCORE, $0, 1
# j ADD_SCORE
# 
# PIPE2_MARK:
# addi $PIPE2_SCORE, $0, 0
# j CHECK_SCORE3
# 
# PIPE2_CHECK:
# blt $0, $PIPE2_SCORE, CHECK_SCORE3
# addi $PIPE2_SCORE, $0, 1
# j ADD_SCORE
# 
# PIPE3_MARK:
# addi $PIPE2_SCORE, $0, 0
# j MAIN_LOOP
# 
# PIPE3_CHECK:
# blt $0, $PIPE3_SCORE, MAIN_LOOP
# addi $PIPE3_SCORE, $0, 1
# j ADD_SCORE
# 
# ADD_SCORE:
# addi $SCORE, $SCORE, 1
# sscr $SCORE
# j MAIN_LOOP