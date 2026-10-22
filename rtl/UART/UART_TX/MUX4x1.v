module MUX4x1 (
input				i00,
input				i01,
input				i10,
input				i11,
input		[1:0]	MUX_SEL,
input				CLK,
input				RST,
output	reg			TX_OUT
);

always @ (negedge RST, posedge CLK )
begin
	if (!RST)
	begin
		TX_OUT <= 1'b1;
	end
	
	else
	begin
	case (MUX_SEL)
		2'b00	: TX_OUT <= i00;
		2'b01	: TX_OUT <= i01;
		2'b10	: TX_OUT <= i10;
		2'b11	: TX_OUT <= i11;
		default	: TX_OUT <= 1'b1;
	endcase
	end
	
end
endmodule