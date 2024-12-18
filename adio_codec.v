module adio_codec (
	input iCLK_18_4,
	input iRST_N,
	output oAUD_DATA,
	output oAUD_LRCK,
	output reg oAUD_BCK,
	input ch1_en,
	input ch2_en,
	input ch3_en,
	input ch4_en,
	input [15:0] ch1_f,
	input [15:0] ch2_f,
	input [15:0] ch3_f,
	input [15:0] ch4_f
);				

parameter	REF_CLK			=	18432000;	//	18.432	MHz
parameter	SAMPLE_RATE		=	48000;		//	48		KHz
parameter	DATA_WIDTH		=	16;			//	16		Bits
parameter	CHANNEL_NUM		=	2;			//	Dual Channel

parameter	SIN_SAMPLE_DATA	=	48;



////////////	Input Source Number	//////////////
parameter	SIN_SANPLE		=	0;
//////////////////////////////////////////////////
//	Internal Registers and Wires
reg		[3:0]	BCK_DIV;
reg		[8:0]	LRCK_1X_DIV;
reg		[7:0]	LRCK_2X_DIV;
reg		[6:0]	LRCK_4X_DIV;
reg		[3:0]	SEL_Cont;
////////	DATA Counter	////////
reg		[5:0]	SIN_Cont;
////////////////////////////////////
reg							LRCK_1X;
reg							LRCK_2X;
reg							LRCK_4X;

////////////	AUD_BCK Generator	//////////////
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		BCK_DIV		<=	0;
		oAUD_BCK	<=	0;
	end
	else
	begin
		if(BCK_DIV >= REF_CLK/(SAMPLE_RATE*DATA_WIDTH*CHANNEL_NUM*2)-1 )
		begin
			BCK_DIV		<=	0;
			oAUD_BCK	<=	~oAUD_BCK;
		end
		else
		BCK_DIV		<=	BCK_DIV+1;
	end
end
//////////////////////////////////////////////////
////////////	AUD_LRCK Generator	//////////////
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		LRCK_1X_DIV	<=	0;
		LRCK_2X_DIV	<=	0;
		LRCK_4X_DIV	<=	0;
		LRCK_1X		<=	0;
		LRCK_2X		<=	0;
		LRCK_4X		<=	0;
	end
	else
	begin
		//	LRCK 1X
		if(LRCK_1X_DIV >= REF_CLK/(SAMPLE_RATE*2)-1 )
		begin
			LRCK_1X_DIV	<=	0;
			LRCK_1X	<=	~LRCK_1X;
		end
		else
		LRCK_1X_DIV		<=	LRCK_1X_DIV+1;
		//	LRCK 2X
		if(LRCK_2X_DIV >= REF_CLK/(SAMPLE_RATE*4)-1 )
		begin
			LRCK_2X_DIV	<=	0;
			LRCK_2X	<=	~LRCK_2X;
		end
		else
		LRCK_2X_DIV		<=	LRCK_2X_DIV+1;		
		//	LRCK 4X
		if(LRCK_4X_DIV >= REF_CLK/(SAMPLE_RATE*8)-1 )
		begin
			LRCK_4X_DIV	<=	0;
			LRCK_4X	<=	~LRCK_4X;
		end
		else
		LRCK_4X_DIV		<=	LRCK_4X_DIV+1;		
	end
end
assign	oAUD_LRCK	=	LRCK_1X;
//////////////////////////////////////////////////
//////////	Sin LUT ADDR Generator	//////////////
always@(negedge LRCK_1X or negedge iRST_N)
begin
	if(!iRST_N)
	SIN_Cont	<=	0;
	else
	begin
		if(SIN_Cont < SIN_SAMPLE_DATA-1 )
		SIN_Cont	<=	SIN_Cont+1;
		else
		SIN_Cont	<=	0;
	end
end

///////////////////Wave-Source generate////////////////
////////////Timbre selection & SoundOut///////////////
	wire [15:0] wave_out_1;
	wire [15:0] wave_out_2;
	wire [15:0] wave_out_3;
	wire [15:0] wave_out_4;
	wire [15:0] sound_o;
	assign sound_o=wave_out_1 + wave_out_2 + wave_out_3 + wave_out_4;	
	always@(negedge oAUD_BCK or negedge iRST_N)begin
		if(!iRST_N)
			SEL_Cont	<=	0;
		else
			SEL_Cont	<=	SEL_Cont+1;
	end
	assign oAUD_DATA = (ch4_en|ch3_en|ch2_en|ch1_en) ? sound_o[~SEL_Cont] : 0;

//////////Ramp address generater//////////////
	reg [15:0] ramp1;
	reg [15:0] ramp2;
	reg [15:0] ramp3;
	reg [15:0] ramp4;
	wire [15:0] ramp_max = 60000;

	always@(negedge ch1_en or negedge LRCK_1X)begin
		if (!ch1_en)
			ramp1=0;
		else if (ramp1>ramp_max) ramp1=0;
		else ramp1=ramp1+ch1_f;
	end

	always@(negedge ch2_en or negedge LRCK_1X)begin
		if (!ch2_en)
			ramp2=0;
		else if (ramp2>ramp_max) ramp2=0;
		else ramp2=ramp2+ch2_f;
	end

	always@(negedge ch3_en or negedge LRCK_1X)begin
		if (!ch3_en)
			ramp3=0;
		else if (ramp3>ramp_max) ramp3=0;
		else ramp3=ramp3+ch3_f;
	end

	always@(negedge ch4_en or negedge LRCK_1X)begin
		if (!ch4_en)
			ramp4=0;
		else if (ramp4>ramp_max) ramp4=0;
		else ramp4=ramp4+ch4_f;
	end

	wave_gen_square ch1(
			.ramp(ramp1[15:10]),
			.music_o(wave_out_1)
		);
	wave_gen_square ch2(
			.ramp(ramp2[15:10]),
			.music_o(wave_out_2)
		);
	wave_gen_square ch3(
			.ramp(ramp3[15:10]),
			.music_o(wave_out_3)
		);
	wave_gen_square ch4(
			.ramp(ramp4[15:10]),
			.music_o(wave_out_4)
		);

endmodule