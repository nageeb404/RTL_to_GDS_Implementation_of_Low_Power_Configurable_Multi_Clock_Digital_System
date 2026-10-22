module DATA_SYNC #(parameter NUM_STAGES = 2, BUS_WIDTH = 8) (

input		[BUS_WIDTH-1:0]		unsync_bus,
input							bus_enable,
input							CLK,
input							RST,
output	reg	[BUS_WIDTH-1:0]		sync_bus,
output	reg						enable_pulse

);


/// INTERNAL SIGNALS 

reg		[BUS_WIDTH-1:0]		mux_out;
reg							pulse_gen;
reg							pulse_ff;


/// REGISTERS

reg		[NUM_STAGES-1:0]		SYNC;





/// MUX

always @(*)
begin
	if(pulse_gen)
	begin
		mux_out = unsync_bus;
	end
	
	else
	begin
		mux_out = sync_bus;
	end
end




always @(posedge CLK, negedge RST)
begin
	if(!RST)
	begin
		sync_bus <= 'd0;
	end

	else
	begin
		sync_bus <= mux_out;
	end
	
end




/// SYNC

always @(posedge CLK, negedge RST)
begin
	if(!RST)
	begin
		SYNC <= 'd0;
	end
	
	else
	begin
		SYNC <= {bus_enable, SYNC[NUM_STAGES-1:1]};
	end

end



/// PULSE GEN

always @(posedge CLK, negedge RST)
begin
	if(!RST)
	begin
		pulse_ff <= 'd0;
	end
	else
	
	begin
		pulse_ff <= SYNC[0];
	end
	
end



always @(*)
begin
	pulse_gen = !pulse_ff & SYNC[0];
end



/// PULSE GEN FLOP

always @(posedge CLK, negedge RST)
begin
	if(!RST)
	begin
		enable_pulse <= 'd0;
	end
	else
	
	begin
		enable_pulse <= pulse_gen;
	end
	
end




endmodule
