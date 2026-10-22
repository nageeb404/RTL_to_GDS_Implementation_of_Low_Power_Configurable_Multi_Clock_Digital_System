module TX_FSM (
input					DATA_VALID,
input					PAR_EN,
input					SER_DONE,
input					CLK,
input					RST,
output	reg		[1:0]	MUX_SEL,
output	reg				SER_EN,
output	reg				BUSY
);

/*reg			[1:0]	MUX_SEL_COMB;
reg					SER_EN_COMB;
reg					BUSY_COMB;
*/




localparam [4:0]	IDLE	=	5'b00000,
					START	=	5'b00001,
					DATA	=	5'b00011,
					PAR		=	5'b00010,
					STOP	=	5'b00110;


reg [4:0]		    CS,
				    NS;




always @ (posedge CLK, negedge RST)
begin
	if(!RST)
	begin
		CS <= IDLE;
	end
	else
	begin
		CS <= NS;
	end
	
end


always @ (*)
begin
	MUX_SEL = 2'b01;
	SER_EN = 1'b0;
	case (CS)
		
		IDLE	:	begin
						MUX_SEL = 2'b01;
						SER_EN = 1'b0;
						
						if(DATA_VALID)
						begin
							NS = START;
						end
						else
						begin
							NS = IDLE;
						end
						
					end
				
			
		START	:	begin
						MUX_SEL = 2'b00;
						SER_EN = 1'b0;
					
						NS = DATA;
					
					end
				
			
		DATA	:	begin
						MUX_SEL = 2'b10;
						SER_EN = 1'b1;
						if(SER_DONE)
						begin
							if(PAR_EN)
							begin
								NS = PAR;
							end
							else
							begin
								NS = STOP;
							end
						end
						else
						begin
							NS = DATA;
						end
						
					end
	
	
		PAR		:	begin
						MUX_SEL = 2'b11;
						SER_EN = 1'b0;
		
						NS = STOP;
						
					end
	
	
		STOP	:	begin
						MUX_SEL = 2'b01;
						SER_EN = 1'b0;
		
						NS = IDLE;
						
					end
					
					
		default	:	NS = IDLE;			
		
	endcase
	
		
end





always @(posedge CLK or negedge RST)
begin
    if (!RST)
	begin
        BUSY <= 1'b0;
	end
    else
	begin
        BUSY <= (CS != IDLE);
    end
end



/*
	AT MUX
	00 start bit (0)
	01 stop bit  (1)
	10 ser_data
	11 par_bit




*/



endmodule
