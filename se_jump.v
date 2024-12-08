module se_jump(
	input iClock,
	input iReset,
	input iTrig,
	output oEnable,
	output [15:0] oFreq
);

	reg playing;
	reg [7:0] current_note_index;
	reg [15:0] current_note_freq;
	reg [31:0] current_note_duration;
	reg [31:0] timer;
	assign oEnable = playing;
	assign oFreq = playing ? current_note_freq : 0;

	localparam NOTES = 1;
	always @(current_note_index) begin
		case ( current_note_index )
			0: begin
				current_note_freq <= 150;
				current_note_duration <= 500000;
			end
		endcase
	end

	always @(posedge iClock) begin
		if (iReset) begin
			playing <= 0;
			current_note_index <= 0;
			timer <= 0;
		end
		else if (iTrig) begin
			playing <= 1;
			current_note_index <= 0;
			timer <= 0;
		end
		
		if (playing) begin
			if (timer < current_note_duration) begin
				timer <= timer + 1;
			end
			else begin
				timer <= 0;
				current_note_index <= current_note_index + 1;
				if (current_note_index == NOTES) begin
					playing <= 0;
				end
			end
		end
	end
endmodule
