`timescale 1 ns / 100 ps
module skeleton_tb();
    reg clock, reset;
	 integer total_cycles;
	 
	 skeleton sk(clock, reset);

    // setting the initial values of all the reg
    initial
    begin
        clock = 1'b0;
		  reset = 1'b1;
		  @(posedge clock);
		  @(posedge clock);
		  @(posedge clock);
		  @(posedge clock);
		  reset = 1'b0;

		  for(total_cycles = 0; total_cycles < 150; total_cycles = total_cycles + 1) begin
			@(posedge clock);
		  end

        $stop;
    end


    // Clock generator
    always
         #10     clock = ~clock;    // toggle

endmodule
