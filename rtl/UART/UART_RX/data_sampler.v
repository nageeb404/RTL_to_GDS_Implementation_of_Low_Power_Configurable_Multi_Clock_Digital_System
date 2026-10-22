module data_sampler  (
input				RX_IN,
input				DATA_SAMP_EN,
input		[5:0]	PRESCALE,
input		[4:0]	EDGE_CNT,
input				CLK,
input				RST,
output	reg			SAMPLED_BIT
);

wire		[4:0]	EDGE_SMP = PRESCALE >> 1 ;

reg			[2:0]	SAMPLES;


always @ (posedge CLK, negedge RST)
begin
	if(!RST)
	begin
		SAMPLED_BIT <= 'b0;
		SAMPLES <= 3'b000;
	end
	
	else if(DATA_SAMP_EN)
	begin
		case (EDGE_CNT)
		EDGE_SMP	-	1	: SAMPLES[0] <= RX_IN;
		EDGE_SMP			: SAMPLES[1] <= RX_IN;
		EDGE_SMP	+	1	: SAMPLES[2] <= RX_IN;
		EDGE_SMP 	+	2	: begin
								SAMPLED_BIT <= (SAMPLES[0] &  SAMPLES[1] | SAMPLES[0] & SAMPLES[2] | SAMPLES[1] & SAMPLES[2]);
							  end
		default : ;
		endcase
	end

end

endmodule