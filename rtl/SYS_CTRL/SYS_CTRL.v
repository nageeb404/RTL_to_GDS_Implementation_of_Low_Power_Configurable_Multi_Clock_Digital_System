module SYS_CTRL # ( parameter DATA_WIDTH = 8 ,  RF_ADDR = 4 ) (

input								CLK,
input								RST,
output	reg							CLKG_EN, 
output	reg							CLKDIV_EN, 

// RegFile

input		[DATA_WIDTH-1 : 0]		RF_RdData,
input								RF_RdData_VLD,
output	reg							RF_WrEn,
output	reg							RF_RdEn,
output	reg	[RF_ADDR-1 : 0]			RF_Address,
output	reg	[DATA_WIDTH-1 : 0]		RF_WrData,

// ALU

input								ALU_OUT_VLD,  
input		[DATA_WIDTH*2-1:0]		ALU_OUT,
output	reg							ALU_EN,
output	reg	[3:0]					ALU_FUN, 

// RX

input		[DATA_WIDTH-1 : 0]		UART_RX_DATA, 
input								UART_RX_VLD,

// FIFO

input								FIFO_FULL,
output	reg	[DATA_WIDTH-1 : 0]		UART_TX_DATA, 
output	reg							UART_TX_VLD
);





// Registers

reg			[DATA_WIDTH-1 : 0]		register;


// States

localparam							IDLE 		= 4'b0000,
									WR_ADD		= 4'b0001,
									WR_DATA		= 4'b0011,
									RD_ADD		= 4'b0010,
									RD_DATA		= 4'b0110,
									WR_FIFO		= 4'b0111,
									WR_OP_A		= 4'b0101,
									WR_OP_B		= 4'b0100,
									ALU_FUNC	= 4'b1100,
									ALU_WR1		= 4'b1101,
									ALU_WR2		= 4'b1111;


reg			[3:0]					CS,
									NS;

// State Transition

always @(posedge CLK, negedge RST)
begin
	if(!RST)
	begin
		CS 		<= IDLE;
		register <= 'b0;
	end
	else
	begin
		CS <= NS;
		if (UART_RX_VLD)
			begin
				if (CS == WR_ADD || CS == RD_ADD || CS == ALU_FUNC)
					begin
						register <= UART_RX_DATA;
					end
			end
	end
end

// Next State Logic

always @ (*)
begin
NS = CS;
case (CS)
	IDLE :  begin
				if (UART_RX_VLD)
				begin
					case (UART_RX_DATA)
						8'hAA : NS = WR_ADD;
						
						8'hBB : NS = RD_ADD;
						
						8'hCC : NS = WR_OP_A;
						
						8'hDD : NS = ALU_FUNC;
					endcase
					
				end
			end
			
			
	WR_ADD : begin
				if (UART_RX_VLD)
				begin
					NS = WR_DATA;
				end
			 end
			 
			 
	WR_DATA : begin
					if (UART_RX_VLD)
					begin
						NS = IDLE;
					end
			  end
			  
			  
	RD_ADD : begin
				if (UART_RX_VLD)
				begin
					NS = RD_DATA;
				end
			 end
			 
	RD_DATA : begin
					if (RF_RdData_VLD)
					begin
						NS = WR_FIFO;
					end
			  end		


	WR_FIFO : begin	
				if(!FIFO_FULL)
				begin
					NS = IDLE;
				end
			  end
			  
			  
	WR_OP_A : begin
					if (UART_RX_VLD)
					begin
						NS = WR_OP_B;
					end
			  end

			 
	WR_OP_B : begin
					if (UART_RX_VLD)
					begin
						NS = ALU_FUNC;
					end
			  end


	ALU_FUNC: begin
					if (UART_RX_VLD)
					begin
						NS = ALU_WR1;
					end
			  end


	ALU_WR1:begin
				if (ALU_OUT_VLD)
				begin
					if(!FIFO_FULL)
					begin
						if (register == 8'b00000010)
						begin	
							NS = ALU_WR2;
						end
						else
						begin
							NS = IDLE;
						end
					end
					else
					begin
						NS = ALU_WR1;
					end
				end
			end


	ALU_WR2:begin
				if(!FIFO_FULL)
				begin
					NS = IDLE;
				end
			  end


			  
endcase


end


// Output Logic

always @ (*)
begin

	CLKG_EN			= 'b0;
	CLKDIV_EN		= 'b1;
	RF_WrEn			= 'b0;
	RF_RdEn			= 'b0;
	RF_Address		= 'b0;
	RF_WrData		= 'b0;
	ALU_EN			= 'b0;
	ALU_FUN			= 'b0;
	UART_TX_DATA	= 'b0;
	UART_TX_VLD		= 'b0;
	
case (CS)
	IDLE :  begin
			
			CLKG_EN			= 'b0;
			CLKDIV_EN		= 'b1;
			RF_WrEn			= 'b0;
			RF_RdEn			= 'b0;
			RF_Address		= 'b0;
			RF_WrData		= 'b0;
			ALU_EN			= 'b0;
			ALU_FUN			= 'b0;
			UART_TX_DATA	= 'b0;
			UART_TX_VLD		= 'b0;
			end
			
			
	WR_ADD : begin
/*				if (UART_RX_VLD)
				begin
					register = UART_RX_DATA ;
				end */
			 end
			 
			 
	WR_DATA : begin
					if (UART_RX_VLD)
					begin
						RF_WrEn 	= 1'b1 ;
						RF_Address	= register ;
						RF_WrData 	= UART_RX_DATA ;
					end
			  end
			  
			  
	RD_ADD : begin
				if (UART_RX_VLD)
				begin
					RF_RdEn 	= 1'b1 ;
					RF_Address	= UART_RX_DATA ;
				end
			 end
			 
	RD_DATA : begin
				RF_RdEn 	= 1'b1 ;
				RF_Address	= register ;
			  end		


	WR_FIFO : begin	
				RF_RdEn 	= 1'b1 ;
				RF_Address	= register ;
				if (!FIFO_FULL)
				begin
					UART_TX_DATA 	= RF_RdData;
					UART_TX_VLD 	= 1'b1;
				end
				
			  end
			  
			  
	WR_OP_A : begin
					if (UART_RX_VLD)
					begin
						RF_WrEn 	= 1'b1 ;
						RF_Address	= 'd0 ;
						RF_WrData 	= UART_RX_DATA ;
					end
			  end

			 
	WR_OP_B : begin
					if (UART_RX_VLD)
					begin
						RF_WrEn 	= 1'b1 ;
						RF_Address	= 'd1 ;
						RF_WrData 	= UART_RX_DATA ;
					end
			  end


	ALU_FUNC: begin
				CLKG_EN = 1'b1;
				if (UART_RX_VLD)
				begin
					ALU_EN 		= 1'b1;
					ALU_FUN 	= UART_RX_DATA;
				end
			  end


	ALU_WR1:begin
				ALU_FUN		= register;
				ALU_EN 		= 1'b1;
				CLKG_EN 	= 1'b1;
				if (ALU_OUT_VLD & !FIFO_FULL)
				begin
					UART_TX_DATA 	= ALU_OUT[DATA_WIDTH-1 : 0];
					UART_TX_VLD 	= 1'b1;
				end
			  end


	ALU_WR2:begin
				ALU_FUN		= register;
				ALU_EN 		= 1'b1;
				CLKG_EN 	= 1'b1;
				if (!FIFO_FULL)
				begin
					UART_TX_DATA 	= ALU_OUT[DATA_WIDTH*2-1 : DATA_WIDTH];
					UART_TX_VLD 	= 1'b1;
				end
			end


			  
endcase


end




endmodule
