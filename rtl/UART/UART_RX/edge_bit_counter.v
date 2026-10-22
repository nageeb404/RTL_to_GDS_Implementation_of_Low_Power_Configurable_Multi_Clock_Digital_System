module edge_bit_counter (
input				CNT_EN,
input		[5:0]	PRESCALE,
input				PAR_EN,
input				CLK,
input				RST,
output	reg	[4:0]	EDGE_CNT,
output	reg	[3:0]	BIT_CNT
);

wire				DONE_EDG;
wire				DONE_BIT;

assign DONE_EDG = CNT_EN && ({1'b0, EDGE_CNT} == (PRESCALE - 6'd1));
assign DONE_BIT = PAR_EN ? (BIT_CNT == 4'd11) : (BIT_CNT == 4'd10);

always @ (posedge CLK, negedge RST)
begin
	if(!RST)
	begin
		EDGE_CNT <= 'b0;
	end
	else if (!CNT_EN || DONE_EDG)
	begin
		EDGE_CNT <= 'b0;
	end
	else if (CNT_EN)
	begin
		EDGE_CNT <= EDGE_CNT + 5'd1;
	end
end

always @ (posedge CLK, negedge RST)
begin
	if(!RST)
	begin
		BIT_CNT <= 'b0;
	end
	else if (!CNT_EN || DONE_BIT)
	begin
		BIT_CNT <= 'b0;
	end
	else if (CNT_EN && DONE_EDG)
	begin
		BIT_CNT <= BIT_CNT + 4'd1;
	end
end

endmodule