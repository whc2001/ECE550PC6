module se_death(
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

	localparam NOTES = 18;
	always @(current_note_index) begin
		case ( current_note_index )
			0: begin
				current_note_freq <= 220;
				current_note_duration <= 250000;
			end
			1: begin
				current_note_freq <= 210;
				current_note_duration <= 250000;
			end
			2: begin
				current_note_freq <= 200;
				current_note_duration <= 250000;
			end
			3: begin
				current_note_freq <= 190;
				current_note_duration <= 250000;
			end
			4: begin
				current_note_freq <= 180;
				current_note_duration <= 250000;
			end
			5: begin
				current_note_freq <= 170;
				current_note_duration <= 250000;
			end
			6: begin
				current_note_freq <= 160;
				current_note_duration <= 250000;
			end
			7: begin
				current_note_freq <= 150;
				current_note_duration <= 250000;
			end
			8: begin
				current_note_freq <= 140;
				current_note_duration <= 250000;
			end
			9: begin
				current_note_freq <= 130;
				current_note_duration <= 250000;
			end
			10: begin
				current_note_freq <= 120;
				current_note_duration <= 250000;
			end
			11: begin
				current_note_freq <= 110;
				current_note_duration <= 250000;
			end
			12: begin
				current_note_freq <= 100;
				current_note_duration <= 250000;
			end
			13: begin
				current_note_freq <= 90;
				current_note_duration <= 250000;
			end
			14: begin
				current_note_freq <= 80;
				current_note_duration <= 250000;
			end
			15: begin
				current_note_freq <= 70;
				current_note_duration <= 250000;
			end
			16: begin
				current_note_freq <= 60;
				current_note_duration <= 250000;
			end
			17: begin
				current_note_freq <= 50;
				current_note_duration <= 250000;
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
					current_note_index <= 0;
				end
			end
		end
	end
endmodule
