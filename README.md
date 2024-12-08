# ECE 550 PC6: Flappy Bird

## Verilog 模块

- [x] PS/2 键盘输入
- [x] 游戏画面渲染
- [X] 随机数生成
- [X] 游戏进程控制（柱子位置）
- [X] 胶水逻辑（skeleton）
- [X] 音响发生器
- [X] CPU 接入

## Specs

- 显示元素的尺寸参考 [`game_render_controller.v`](game_render_controller.v) 中的 `localparam` 定义
- 鸟的位置指鸟的左上角
  - 横向 `BIRD_WIDTH = 34` * 纵向 `BIRD_HEIGHT = 24`
  - 鸟的 X 永远是屏幕中心减去鸟的宽度的一半（`BIRD_X = (SCREEN_WIDTH / 2) - (BIRD_WIDTH / 2)`），Y 是可以任意移动
  - 鸟的碰撞箱比实际图形缩一圈（2 像素），是水平 `[BIRD_X + 2, BIRD_X + BIRD_WIDTH - 2]`，垂直 `[BIRD_Y + 2, BIRD_Y + BIRD_HEIGHT - 2]`
- 柱子的位置指空档的左上角
  - 横向 `PIPE_WIDTH = 52` * 纵向 `PIPEPIPE_GAP_HEIGHT = 100`
  - 柱子的 X Y 均可整个画面内任意移动
  - 当鸟整个碰撞箱的 X 在柱子空挡范围内 `BIRD_X + BIRD_WIDTH >= PIPE_X && BIRD_X < PIPE_X + PIPE_WIDTH` 的时候持续检测碰撞，能通过的区域水平 `[PIPE_X + 2, PIPE_X + PIPE_WIDTH - 2]`，垂直 `[PIPE_Y, PIPE_Y + PIPEPIPE_GAP_HEIGHT]`，不在这个范围内一概算撞上（包括鸟高出屏幕上边缘也撞）
  - 鸟飞过柱子中间时进行加分
  - 柱子移出屏幕左边（PIPE_X < -PIPE_WIDTH）后立即回到屏幕右边外侧进行循环使用
  - 寄存器标记三个柱子哪个没飞过（飞过之后循环了）哪个已经飞过了，防止重复加分
- 地板的 Y 是 `FLOOR_Y = 390`
  - 鸟的碰撞下边缘撞到地板 `BIRD_Y + BIRD_HEIGHT - 2 > FLOOR_Y` 也结束

## CPU 自定指令

- `pkey $rd`（11111）读按键状态寄存器到 $rd 并重设为 0（0=没有新动作 1=按下 2=弹起）
- `pobx1~3 $rd`（01000 01001 01010）读某个柱子的 x 坐标到 $rd
- `poby1~3 $rd`（01100 01101 01110）读某个柱子的 y 坐标到 $rd
- `ssta $rd`（11100）写游戏状态显示寄存器，控制画面场景显示（0=点击开始 1=游戏进行中 2=游戏结束）
- `spos $rd`（11101）写 $rd 到鸟的位置显示寄存器（鸟只在 y 轴上移动）
- `sscr $rd`（11110）写 $rd 到分数显示寄存器
- `ssnd $rd`（01111）写 $rd 到音响发生器（0=跳跃 1=得分 2=死亡）
