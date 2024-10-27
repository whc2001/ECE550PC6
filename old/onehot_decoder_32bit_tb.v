// ---------- SAMPLE TEST BENCH ----------
`timescale 1 ns / 100 ps
module onehot_decoder_32bit_tb();
	reg clock;
    integer i;
	reg [5:0] in;
	wire [31:0] out;
	onehot_decoder_32bit _decoder(out, in);
	
    // setting the initial values of all the reg
    initial
    begin
        $display($time, " << Starting the Simulation >>");
        clock = 1'b0;    // at time 0

        @(negedge clock);    // wait until next negative edge of clock
        for(i = 0; i < 32; i = i + 1) begin
            @(negedge clock);
            in = i;
            @(negedge clock);
            $display("in = %d, out = %b", in, out);
        end

        $stop;
    end



    // Clock generator
    always
         #10     clock = ~clock;    // toggle

endmodule
