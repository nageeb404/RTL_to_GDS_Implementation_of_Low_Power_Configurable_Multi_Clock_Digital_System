module ClkDiv (
input			I_ref_clk,
input			I_rst_n,
input			I_clk_en,
input	[7:0]	I_div_ratio,
output			o_div_clk
);


wire			odd;
wire	[7:0]	half;
wire	[7:0]	halfp1;
wire			ClK_DIV_EN;


reg		[7:0]	counter;
reg				flag;
reg				div_clk_reg;


assign ClK_DIV_EN = I_clk_en && ( I_div_ratio != 'd0) && ( I_div_ratio != 'd1);
assign half = I_div_ratio >> 1;
assign halfp1 = half + 'd1;
assign odd = I_div_ratio[0];
assign o_div_clk = ClK_DIV_EN ? div_clk_reg : I_ref_clk;


always @ (posedge I_ref_clk, negedge I_rst_n )
begin

	if (!I_rst_n)
	begin
		div_clk_reg <= 'd0;
		counter <= 'd0;
		flag <= 'b0;
	end

	else if (ClK_DIV_EN)
	begin
		if(!odd && counter == (half - 'd1))
		begin
			div_clk_reg <= ! div_clk_reg;
			counter <= 'd0;
		end
		
		else if (odd && counter == (half - 'd1) && !flag )  		// small period 
		begin
			div_clk_reg <= ! div_clk_reg;
			flag <= ! flag;
			counter <= 'd0;
		end
		
		else if (odd && counter == (halfp1 - 'd1) && flag )		// large period
		begin
			div_clk_reg <= ! div_clk_reg;
			flag <= ! flag;
			counter <= 'd0;
		end
		
		else
		begin
			counter <= counter + 'd1;
		end
	end
	
	else
	begin
        div_clk_reg <= 'b0;
        counter     <= 'd0;
        flag        <= 'b0;
    end
	
end







endmodule
