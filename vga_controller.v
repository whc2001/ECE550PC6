module vga_controller(iRST_n, iVGA_CLK, oBLANK_n, oHS, oVS, b_data, g_data, r_data,
						ADDR, rgb_data_raw);

	
input iRST_n;
input iVGA_CLK;
output reg oBLANK_n;
output reg oHS;
output reg oVS;
output [7:0] b_data;
output [7:0] g_data;  
output [7:0] r_data;	
output reg [18:0] ADDR;
input [23:0] rgb_data_raw;

reg [23:0] rgb_data;
wire VGA_CLK_n;
wire [7:0] index;
wire [23:0] test_data, square_data;
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

//////latch valid data at falling edge;
always@(posedge VGA_CLK_n) rgb_data <= rgb_data_raw;
assign r_data = rgb_data[23:16];
assign g_data = rgb_data[15:8];
assign b_data = rgb_data[7:0]; 
///////////////////
//////Delay the iHD, iVD,iDEN for one clock cycle;
always@(negedge iVGA_CLK)
begin
  oHS<=cHS;
  oVS<=cVS;
  oBLANK_n<=cBLANK_n;
end

endmodule
 	















