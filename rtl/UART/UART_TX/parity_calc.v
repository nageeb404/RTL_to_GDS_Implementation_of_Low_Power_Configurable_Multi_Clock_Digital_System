module parity_calc (
input		[7:0]	P_DATA,
input				DATA_VALID,
input				BUSY,
input				PAR_TYP,
input				CLK,
input				RST,
output	reg			PAR_BIT
);


always @(posedge CLK or negedge RST)
begin
    if (!RST)
	begin
        PAR_BIT <= 1'b0;
    end
    else if (DATA_VALID && !BUSY)
	begin
        PAR_BIT <= PAR_TYP ? ~(^P_DATA) : (^P_DATA);
    end
end

endmodule
