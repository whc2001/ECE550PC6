# Verilog 模块

- [x] PS/2 键盘输入
- [x] 根据多种寄存器渲染游戏画面
- [ ] 随机数生成
- [ ] 胶水逻辑
- [ ] 计算柱子的x坐标和y坐标

## Specs
- 显示元素的尺寸参考 [`game_render_controller.v`](game_render_controller.v) 中的 `localparam` 定义
- 鸟的位置指鸟的左上角
  - 横向 `BIRD_WIDTH = 34` * 纵向 `BIRD_HEIGHT = 24`
  - 鸟的 X 永远是屏幕中心减去鸟的宽度的一半（`BIRD_X = (SCREEN_WIDTH / 2) - (BIRD_WIDTH / 2)`），Y 是可以任意移动
  - 鸟的碰撞箱是水平 `[BIRD_X, BIRD_X + BIRD_WIDTH]`，垂直 `[BIRD_Y, BIRD_Y + BIRD_HEIGHT]`
- 柱子的位置指空档的左上角
  - 横向 `PIPE_WIDTH = 52` * 纵向 `PIPEPIPE_GAP_HEIGHT = 100`
  - 柱子的 X Y 均可整个画面内任意移动
  - 当鸟整个碰撞箱的 X 在柱子空挡范围内 `BIRD_X + BIRD_WIDTH >= PIPE_X && BIRD_X < PIPE_X + PIPE_WIDTH` 的时候持续检测碰撞，能通过的区域水平 `[PIPE_X, PIPE_X + PIPE_WIDTH]`，垂直 `[PIPE_Y, PIPE_Y + PIPEPIPE_GAP_HEIGHT]`，不在这个范围内一概算撞上（包括鸟高出屏幕上边缘也撞）
  - 鸟移出柱子空挡的瞬间（或者飞过中间时）进行加分
  - 柱子移出屏幕左边（PIPE_X < -PIPE_WIDTH）后立即回到屏幕右边外侧进行循环使用
  - 可能需要寄存器标记三个柱子哪个没飞过（飞过之后循环了）哪个已经飞过了，防止重复加分
- 地板的 Y 是 `FLOOR_Y = 395`
  - 鸟的下边缘撞到地板 `BIRD_Y + BIRD_HEIGHT > FLOOR_Y` 也结束

# MIPS 新指令

- `pkey $rd` 读按键状态寄存器到 $rd 并重设为 0（0=没有新动作 1=按下 2=弹起）
- `pobx1~3 $rd` 读某个柱子的 x 坐标到 $rd
- `poby1~3 $rd` 读某个柱子的 y 坐标到 $rd
- `ssta $rd` 写游戏状态显示寄存器，控制画面场景显示（0=点击开始 1=游戏进行中 2=游戏结束）
- `spos $rd` 写 $rd 到鸟的位置显示寄存器（鸟只在 y 轴上移动）
- `sscr $rd` 写 $rd 到分数显示寄存器
- ~~(optional) `shis $rd` 写 $rd 到最高分显示寄存器？，值被 Verilog 钳制在（0-99）~~ 有空就做没空就算

# MIPS 逻辑
```
状态 == 0:
    初始化
    等待按键 == 1
    状态 = 1
状态 == 1:
    if 碰撞检测:
        状态 = 2
    if 按键 == 1:
        更新速度&加速度
    else
        更新速度
    重新计算鸟的坐标
    计算柱子位置
    更新分数
状态 == 2:
    从 dmem 读取最高分
    更新分数和最高分显示
    if 分数 > 最高分:
        写入最高分到 dmem
    等待按键 == 1
    状态 = 0
```

# C语言版 MIPS指令
```c
#define GROUND_LEVEL 450
#define SCREEN_HEIGHT 480
#define GRAVITY 10
#define JUMP_ACCEL -5
#define PIPE_WIDTH 50
#define PIPE_GAP 100
#define PIPE_RESET_X 640
#define BIRD_X 100
#define BIRD_HEIGHT 24
#define BIRD_WIDTH 34

int state = 0; // 0 = Init, 1 = Running, 2 = Game Over
int y_bird; // Bird's initial y-coordinate
int vel;      // Bird's velocity
int accel;
int score;
int pipe1_x, pipe2_x, pipe3_x; 
int pipe1_y, pipe2_y, pipe3_y;
bool collision = false; // 碰撞检测
bool key_pressed;

while (true) {
    switch (state) {
        case 0: // 初始化
            y_bird = 240;
            vel = 0;
            accel = GRAVITY;
            score = 0;
            pipe1_x = PIPE_RESET_X;
            pipe2_x = PIPE_RESET_X;
            pipe3_x = PIPE_RESET_X;
            collision = false;
            //传入key_pressed
            if (key_pressed) {
                state = 1; // Start the game
            }
            break;

        case 1: 
            //传入key_pressed，三根柱子x&y坐标
            // 碰撞检测
            collision = check_collision(y_bird, pipe1_x, pipe1_y) || check_collision(y_bird, pipe2_x, pipe2_y) || check_collision(y_bird, pipe3_x, pipe3_y) || (y_bird >= GROUND_LEVEL);
            if (collision) {
                state = 2; // Game over
                break;
            }

            if (key_pressed) {
                accel = JUMP_ACCEL;
                vel = 0;
            } else if (accel != GRAVITY) {
                accel += 1;
                vel += accel;
            } else {
                accel = GRAVITY;
                vel += accel;
            }
 
            y_bird += vel;

            if (y_bird < 0) {
                y_bird = 0;
            }

            if (pipe1_x + PIPE_WIDTH < BIRD_X || pipe2_x + PIPE_WIDTH < BIRD_X || pipe3_x + PIPE_WIDTH < BIRD_X) {
                score++;
            }
            //传出y_bird, score, state

            break;

        case 2: // Game Over
            
            //传入key_pressed
            if (key_pressed) {
                state = 0; // Restart the game
            }
            break;
    }
}

bool check_collision(int y_bird, int pipe_x, int pipe_y) {
    // 柱子是否到了鸟的位置
    if (pipe_x < BIRD_X + BIRD_WIDTH && pipe_x > BIRD_X-PIPE_WIDTH) {
        // 检查鸟是否与柱子上下边界发生碰撞
        if (y_bird < pipe_y || y_bird + BIRD_HEIGHT > (pipe_y + PIPE_GAP)) {
            return true;
        }
    }
    return false; // 无碰撞
}

```
