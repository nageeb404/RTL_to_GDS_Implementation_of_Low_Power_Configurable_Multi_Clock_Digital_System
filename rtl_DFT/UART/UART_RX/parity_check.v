module parity_check (
input				PAR_TYP,
input				PAR_CHK_EN,
input				SAMPLED_BIT,
input		[7:0]	P_DATA,
output	reg			PAR_ERR
);


always @(*)
begin
	
	if (PAR_CHK_EN)
	begin
        PAR_ERR = (SAMPLED_BIT != (PAR_TYP ? ~(^P_DATA) : (^P_DATA)));
	end
	else
	begin
		PAR_ERR = 1'b0;
	end

end

endmodule