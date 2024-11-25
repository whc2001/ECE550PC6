module PS2_Interface(inclock, resetn, ps2_clock, ps2_data, space_state, reset_space_state);

	input 			inclock, resetn;
	inout 			ps2_clock, ps2_data;
	output reg [1:0] space_state;
	input reset_space_state;

	wire [7:0] received_data;
	wire received_data_en;
	reg release_armed;

	localparam RELEASE_PREFIX = 8'hF0;
	localparam SPACE_SCANCODE = 8'h29;

	localparam IDLE = 2'd0;
	localparam PRESSED = 2'd1;
	localparam RELEASED = 2'd2;

	always @(posedge inclock)
	begin
		if (reset_space_state == 1'b1) begin
			space_state <= IDLE;
		end
		if (resetn == 1'b0) begin
			release_armed <= 1'b0;
			space_state <= IDLE;
		end
		else if (received_data_en == 1'b1) begin
			if (release_armed == 1'b1) begin
				if (received_data == SPACE_SCANCODE) begin
					space_state <= RELEASED;
				end
				release_armed <= 1'b0;
			end
			else begin
				if (received_data == SPACE_SCANCODE) begin
					space_state <= PRESSED;
				end
				else if (received_data == RELEASE_PREFIX) begin
					release_armed <= 1'b1;
				end
			end
		end
	end
	
	PS2_Controller PS2 (.CLOCK_50 			(inclock),
						.reset 				(~resetn),
						.PS2_CLK			(ps2_clock),
						.PS2_DAT			(ps2_data),		
						.received_data		(received_data),
						.received_data_en	(received_data_en)
						);

endmodule
