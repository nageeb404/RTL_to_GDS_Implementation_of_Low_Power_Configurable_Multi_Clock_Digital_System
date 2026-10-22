module Reg_File 	#(parameter WIDTH = 8, DEPTH = 16, ADDR = 4)	(
input 		[WIDTH-1:0] 	WrData,
input 		[ADDR - 1:0]	Address,
input						RdEn,
input 						WrEn,
input						RST,
input						CLK,
output	reg	[WIDTH-1:0] 	RdData,
output	reg					RdData_VLD,
output		[WIDTH-1:0]		REG0,
output		[WIDTH-1:0]		REG1,
output		[WIDTH-1:0]		REG2,
output		[WIDTH-1:0]		REG3
);

reg [WIDTH-1:0] Reg_File [DEPTH-1:0];

integer i;

always @ (posedge CLK , negedge RST)
begin
	if (!RST)
	
	begin
		RdData 		<= 	16'b0;
		RdData_VLD 	<= 	1'b0;
		for (i = 0 ; i < DEPTH; i = i + 1 )
		begin
			if(i==2)
				Reg_File[i] <= 'b100000_01 ;
			else if (i==3) 
				Reg_File[i] <= 'b0010_0000 ;
			else
				Reg_File[i] <= 'b0 ; 
		end
	end
	
	
	else if (WrEn & !RdEn )
	
	begin
		Reg_File [Address] <= WrData;
	end
	
	
	else if (RdEn & !WrEn )
	
	begin
		RdData 		<= 	Reg_File [Address];
		RdData_VLD 	<= 	1'b1;
	end
	
	
	else
	begin
		RdData_VLD <= 1'b0;
	end
end

assign REG0 = Reg_File[0];
assign REG1 = Reg_File[1];
assign REG2 = Reg_File[2];
assign REG3 = Reg_File[3];

endmodule
