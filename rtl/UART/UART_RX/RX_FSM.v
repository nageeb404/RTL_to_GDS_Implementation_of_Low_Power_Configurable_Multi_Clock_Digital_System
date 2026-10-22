module RX_FSM (
input				RX_IN,
input				PAR_EN,
input		[5:0]	PRESCALE,
input		[4:0]	EDGE_CNT,
input		[3:0]	BIT_CNT,
input				PAR_ERR,
input				STRT_GLITCH,
input				STP_ERR,
input				CLK,
input				RST,
output	reg			DATA_SAMP_EN,
output	reg			CNT_EN,
output	reg			PAR_CHK_EN,
output	reg			STRT_CHK_EN,
output	reg			STOP_CHK_EN,
output	reg			DESER_EN,
output	reg			DATA_VALID,
output	reg			DESER_STORE // delaying data valid because for some reason it ticks before the data arrives
);

wire		[4:0]	edge_smp    = PRESCALE >> 1;
wire				edge_done   = ({1'b0, EDGE_CNT} == (PRESCALE - 6'd1));
wire				sample_tick = (EDGE_CNT == (edge_smp + 5'd3));


localparam [2:0]	IDLE         = 3'b000,
					START_CHECK  = 3'b001,
					SHIFT        = 3'b010,
					PARITY_CHECK = 3'b011,
					STOP_CHECK   = 3'b100,
					DATA_V       = 3'b101;

reg [2:0]			CS, NS;

always @ (posedge CLK, negedge RST)
begin
	if(!RST)
	begin
		DESER_STORE		<=1'b0;
		DATA_VALID	   	<=1'b0;
		CS <= IDLE;
	end
	else
	begin
		CS <= NS;
		DESER_STORE <= (CS == DATA_V);
		DATA_VALID <= DESER_STORE;
	end
end

always @ (*)
begin
	DATA_SAMP_EN = 'b0;
	CNT_EN       = 'b0;
	PAR_CHK_EN   = 'b0;
	STRT_CHK_EN  = 'b0;
	STOP_CHK_EN  = 'b0;
	DESER_EN     = 'b0;
//	DATA_VALID   = 'b0;
	NS           = CS;
	
	case (CS)
		IDLE : begin
			if(!RX_IN)
			begin
				CNT_EN       = 1'b1;
				DATA_SAMP_EN = 1'b1;
				NS           = START_CHECK;
			end
			else
			begin
				NS = IDLE;
			end
		end

		START_CHECK : begin
			DATA_SAMP_EN = 1'b1;
			CNT_EN       = 1'b1;
			STRT_CHK_EN  = sample_tick;
			
			if(STRT_GLITCH)
				NS = IDLE;
			else if (edge_done)
				NS = SHIFT;
			else
				NS = START_CHECK;
		end

		SHIFT : begin
			DATA_SAMP_EN = 1'b1;
			CNT_EN       = 1'b1;
			DESER_EN     = sample_tick;

			if (edge_done && (BIT_CNT == 4'd8))
			begin
				if (PAR_EN)
					NS = PARITY_CHECK;
				else
					NS = STOP_CHECK;
			end
			else
				NS = SHIFT;
		end

		PARITY_CHECK : begin
			DATA_SAMP_EN = 1'b1;
			CNT_EN       = 1'b1;
			PAR_CHK_EN   = (EDGE_CNT >= (edge_smp + 5'd3));

			if (edge_done)
			begin
				if (PAR_ERR)
					NS = IDLE;
				else
					NS = STOP_CHECK;
			end
			else
				NS = PARITY_CHECK;
		end

		STOP_CHECK : begin
			DATA_SAMP_EN = 1'b1;
			CNT_EN       = 1'b1;
			STOP_CHK_EN  = (EDGE_CNT >= (edge_smp + 5'd3));
			if (edge_done)
			begin
				if (STP_ERR)
					NS = IDLE;
				else
					NS = DATA_V;
			end
			else
				NS = STOP_CHECK;
		end

		DATA_V : begin
//			DATA_VALID = 1'b1;
			
			if (!RX_IN)
			begin
				CNT_EN       = 1'b1;
				DATA_SAMP_EN = 1'b1;
				NS           = START_CHECK;
			end
			else
			begin
				NS = IDLE;
			end
		end

		default : NS = IDLE;
	endcase
end





endmodule
