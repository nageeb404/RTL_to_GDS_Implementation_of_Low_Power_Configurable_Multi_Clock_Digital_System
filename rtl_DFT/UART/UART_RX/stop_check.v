module stop_check (
input				STOP_CHK_EN,
input				SAMPLED_BIT,
output	reg			STP_ERR
);


always @(*)
begin
	if (STOP_CHK_EN)
	begin
		if (SAMPLED_BIT == 1'b1)
		begin	
			STP_ERR = 'b0;
		end
		
		else
		begin
			STP_ERR = 'b1;
		end
	end
	else
	begin
		STP_ERR = 1'b0;
	end
end





endmodule