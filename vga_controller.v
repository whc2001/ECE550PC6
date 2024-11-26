module vga_controller(iRST_n, iVGA_CLK, oBLANK_n, oHS, oVS, b_data, g_data, r_data,
						iBirdY, iScore);

	
input iRST_n;
input iVGA_CLK;
output reg oBLANK_n;
output reg oHS;
output reg oVS;
output [7:0] b_data;
output [7:0] g_data;  
output [7:0] r_data;	

input [9:0] iBirdY;
input [15:0] iScore;
			
reg [18:0] ADDR;
reg [23:0] bgr_data;
wire VGA_CLK_n;
wire [7:0] index;
wire [23:0] test_data, square_data;
wire [23:0] bgr_data_raw;
wire cBLANK_n,cHS,cVS,rst;

assign rst = ~iRST_n;
assign VGA_CLK_n = ~iVGA_CLK;
video_sync_generator LTM_ins (.vga_clk(iVGA_CLK),
							  .reset(rst),
							  .blank_n(cBLANK_n),
							  .HS(cHS),
							  .VS(cVS));


////Addresss generator
always@(posedge iVGA_CLK,negedge iRST_n)
begin
  if (!iRST_n)
	 ADDR<=19'd0;
  else if (cHS==1'b0 && cVS==1'b0)
	 ADDR<=19'd0;
  else if (cBLANK_n==1'b1)
	 ADDR<=ADDR+1;
end

/*
//////////////////////////
//////INDEX addr.

img_data	img_data_inst (
	.address ( ADDR ),
	.clock ( VGA_CLK_n ),
	.q ( index )
	);
	
/////////////////////////
//////Add switch-input logic here
	
//////Color table output
img_index	img_index_inst (
	.address ( index ),
	.clock ( iVGA_CLK ),
	.q ( bgr_data_raw)
	);	
//////

*/

/** Game Render Controller **/
game_render_controller grc (
	.oPixel(bgr_data_raw),
	.iClock(iVGA_CLK),
	.iAddress(ADDR),
	.iBirdY(iBirdY),
	.iScore(iScore)
);

//////latch valid data at falling edge;
always@(posedge VGA_CLK_n) bgr_data <= bgr_data_raw;
assign r_data = bgr_data[23:16];
assign g_data = bgr_data[15:8];
assign b_data = bgr_data[7:0]; 
///////////////////
//////Delay the iHD, iVD,iDEN for one clock cycle;
always@(negedge iVGA_CLK)
begin
  oHS<=cHS;
  oVS<=cVS;
  oBLANK_n<=cBLANK_n;
end

endmodule
 	















