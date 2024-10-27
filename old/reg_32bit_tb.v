// ---------- SAMPLE TEST BENCH ----------
`timescale 1 ns / 100 ps
module reg_32bit_tb();
	reg clock;
	reg en, clr;
	reg [31:0] d;
	wire [31:0] q;
	reg_32bit _reg(q, d, clock, en, clr);
	
    // setting the initial values of all the reg
    initial
    begin
        $display($time, " << Starting the Simulation >>");
        clock = 1'b0;    // at time 0
 
        clr = 1'b1;    // assert reset
        @(negedge clock);    // wait until next negative edge of clock
        @(negedge clock);    // wait until next negative edge of clock

        clr = 1'b0;    // de-assert reset
        @(negedge clock);    // wait until next negative edge of clock
		$display("%h", q);	// should be 0

		@(negedge clock);
		d = 32'hFFFFFFFF;
		@(negedge clock);
		$display("%h", q);	// should be 0
		
		@(negedge clock);
		en = 1'b1;
		@(negedge clock);
		en = 1'b0;
		@(negedge clock);
		$display("%h", q);	// should be FFFFFFFF
	
		@(negedge clock);
		d = 32'h00000000;
		@(negedge clock);
		$display("%h", q);	// should be FFFFFFFF
		
		@(negedge clock);
		en = 1'b1;
		@(negedge clock);
		en = 1'b0;
		@(negedge clock);
		$display("%h", q);	// should be 0

		@(negedge clock);
		d = 32'hA5A5A5A5;
		@(negedge clock);
		$display("%h", q);	// should be 0
		
		@(negedge clock);
		en = 1'b1;
		@(negedge clock);
		en = 1'b0;
		@(negedge clock);
		$display("%h", q);	// should be A5A5A5A5

		@(negedge clock);
		d = 32'h5A5A5A5A;
		@(negedge clock);
		$display("%h", q);	// should be A5A5A5A5

		@(negedge clock);
		en = 1'b1;
		@(negedge clock);
		en = 1'b0;
		@(negedge clock);
		$display("%h", q);	// should be 5A5A5A5A

		@(negedge clock);
		clr = 1'b1;
		@(negedge clock);
		clr = 1'b0;
		@(negedge clock);
		$display("%h", q);	// should be 0

        $stop;
    end



    // Clock generator
    always
         #10     clock = ~clock;    // toggle

endmodule
