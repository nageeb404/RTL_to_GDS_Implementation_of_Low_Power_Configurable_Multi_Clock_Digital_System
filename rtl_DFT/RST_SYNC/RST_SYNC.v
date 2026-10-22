module RST_SYNC # ( parameter NUM_STAGES = 2) (	

input    	     		RST,
input    	    		CLK,
output   	     		SYNC_RST

);

reg   [NUM_STAGES-1:0]    shift_reg;

always @(posedge CLK, negedge RST)
 begin
	if(!RST)      
	begin
		shift_reg <= 'b0 ;
	end
	else
	begin
		shift_reg <= {shift_reg[NUM_STAGES-2:0],1'b1} ;
	end  
 end
 
 
assign  SYNC_RST = shift_reg[NUM_STAGES-1] ;



endmodule