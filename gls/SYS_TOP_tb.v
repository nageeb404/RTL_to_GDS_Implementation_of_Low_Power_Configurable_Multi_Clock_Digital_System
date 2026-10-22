`timescale 1ns/1ps

module SYS_TOP_tb ();

localparam real				REF_CLK_PERIOD  = 10.0;
localparam real				UART_CLK_PERIOD = 271.267;
localparam real				BIT_PERIOD      = 32.0 * UART_CLK_PERIOD;

// -----------------------------------------------------------
// Functional Signals
// -----------------------------------------------------------
reg							RST_N;
reg							UART_CLK;
reg							REF_CLK;
reg							UART_RX_IN;

wire						UART_TX_O;
wire						parity_error;
wire						framing_error;

// -----------------------------------------------------------
// DFT / Scan Chain Signals (Tied off for Functional Mode)
// -----------------------------------------------------------
reg                         test_mode;
reg                         SE;
reg                         scan_clk;
reg                         scan_rst;
reg  [3:0]                  SI;
wire [3:0]                  SO;

// -----------------------------------------------------------
// DUT Instantiation
// -----------------------------------------------------------
SYS_TOP UUT (
	.RST_N(RST_N),
	.UART_CLK(UART_CLK),
	.REF_CLK(REF_CLK),
	.UART_RX_IN(UART_RX_IN),
	.UART_TX_O(UART_TX_O),
	.parity_error(parity_error),
	.framing_error(framing_error),
    
    // DFT Scan Ports
	.test_mode(test_mode),
	.SE(SE),
	.scan_clk(scan_clk),
	.scan_rst(scan_rst),
	.SI(SI),
	.SO(SO)
);

// -----------------------------------------------------------
// Initialization & Waveform Dumping
// -----------------------------------------------------------
initial begin
    // Dump waveforms to VCD file
    $dumpfile("SYS_TOP_GLS.vcd");
    $dumpvars(0, SYS_TOP_tb);
    
    // Initialize DFT signals to 0 to prevent X-propagation on internal clocks
    test_mode = 1'b0;
    SE        = 1'b0;
    scan_clk  = 1'b0;
    scan_rst  = 1'b0; 
    SI        = 4'b0000;
end

// -----------------------------------------------------------
// Simple Verification Arrays (Reduced to 6 tests, index 0 to 5)
// -----------------------------------------------------------
reg			[7:0]			expected_results [0:5];
reg			[159:0]			test_phases      [0:5];

integer						check_idx = 0;
integer						passed    = 0;
integer						failed    = 0;

initial
begin
	expected_results[0] = 8'h11; test_phases[0] = "REG_RD_0x05";
	expected_results[1] = 8'hA5; test_phases[1] = "REG_RD_0x06";
	expected_results[2] = 8'h0C; test_phases[2] = "ALU_ADD_8+4";
	expected_results[3] = 8'h04; test_phases[3] = "ALU_SUB_8-4";
	expected_results[4] = 8'h00; test_phases[4] = "ALU_MULT_LOWER";
	expected_results[5] = 8'h01; test_phases[5] = "ALU_MULT_UPPER";
end

// -----------------------------------------------------------
// Clocks
// -----------------------------------------------------------
initial
begin
	REF_CLK = 0;
	forever #(REF_CLK_PERIOD / 2.0) REF_CLK = ~REF_CLK;
end

initial
begin
	UART_CLK = 0;
	forever #(UART_CLK_PERIOD / 2.0) UART_CLK = ~UART_CLK;
end

// -----------------------------------------------------------
// Transmit Tasks
// -----------------------------------------------------------
task send_byte(input [7:0] data);
	integer i;
	reg parity_bit;
begin
	parity_bit = ^data; 
	
    // Trigger slightly after clock edge to prevent setup/hold violations on async rx pin
    @(negedge UART_CLK);
	UART_RX_IN = 1'b0;  
	#(BIT_PERIOD);
	
	for (i = 0; i < 8; i = i + 1)
	begin
		UART_RX_IN = data[i]; 
		#(BIT_PERIOD);
	end
	
	UART_RX_IN = parity_bit; 
	#(BIT_PERIOD);
	
	UART_RX_IN = 1'b1;  
	#(BIT_PERIOD * 5); // Gap between bytes
end
endtask

task write_reg(input [7:0] addr, input [7:0] data);
begin 
	send_byte(8'hAA); 
	send_byte(addr); 
	send_byte(data); 
end
endtask

task read_reg(input [7:0] addr);
begin 
	send_byte(8'hBB); 
	send_byte(addr); 
end
endtask

task alu_with_op(input [7:0] opA, input [7:0] opB, input [7:0] fun);
begin 
	send_byte(8'hCC); 
	send_byte(opA); 
	send_byte(opB); 
	send_byte(fun); 
end
endtask

task alu_no_op(input [7:0] fun);
begin 
	send_byte(8'hDD); 
	send_byte(fun); 
end
endtask

// -----------------------------------------------------------
// Main Stimulus
// -----------------------------------------------------------
initial
begin
	$display("\n===================================================");
	$display("   STARTING FINAL SYSTEM TEST (GLS)");
	$display("===================================================\n");
	
	UART_RX_IN = 1'b1; 
	RST_N      = 1'b1;
	#(REF_CLK_PERIOD * 5);
	
	RST_N = 1'b0;
	// Hold reset active for at least 3 slow clock cycles to initialize the UART domain
	#(UART_CLK_PERIOD * 3);
    
    // De-assert reset strictly on the negative clock edge to prevent removal violations
    @(negedge REF_CLK);
	RST_N = 1'b1;
	
	#(UART_CLK_PERIOD * 10);
	#(BIT_PERIOD * 2);

	// 1. Write Data
	write_reg(8'h05, 8'h11);
	#(BIT_PERIOD * 5); 
	write_reg(8'h06, 8'hA5);
	#(BIT_PERIOD * 5);

	// 2. Read Data
	read_reg(8'h05);
	#(BIT_PERIOD * 5);
	read_reg(8'h06);
	#(BIT_PERIOD * 5);

	// 3. ALU Tests
	alu_with_op(8'h08, 8'h04, 8'h00);
	#(BIT_PERIOD * 5);
	alu_no_op(8'h01);
	#(BIT_PERIOD * 5);
	alu_with_op(8'h10, 8'h10, 8'h02); 
	#(BIT_PERIOD * 5);

	#(BIT_PERIOD * 40);

	// End Report
	$display("\n===================================================");
	$display("   TESTBENCH COMPLETE");
	$display("   Total Passed: %0d / 6", passed);
	
	if (failed == 0 && passed == 6) 
		$display("   STATUS: SUCCESS");
	else                   
		$display("   STATUS: FAILED (%0d errors)", failed);
		
	$display("===================================================\n");
	$stop;
end

// -----------------------------------------------------------
// Background Monitor
// -----------------------------------------------------------
reg			[7:0]			captured_data;
integer						bit_idx;

always
begin
	wait (RST_N == 1'b1);
	
	@(negedge UART_TX_O);
	#(BIT_PERIOD / 2.0); 
	
	if (UART_TX_O == 1'b0)
	begin
		#(BIT_PERIOD); 
		
		for (bit_idx = 0; bit_idx < 8; bit_idx = bit_idx + 1)
		begin
			captured_data[bit_idx] = UART_TX_O;
			#(BIT_PERIOD);
		end
		
		if (check_idx <= 5)
		begin
			if (captured_data === expected_results[check_idx])
			begin
				$display("[%0t ns] [PASS] %0s | Exp: 0x%h | Got: 0x%h", 
						 $time, test_phases[check_idx], expected_results[check_idx], captured_data);
				passed = passed + 1;
			end
			else
			begin
				$display("[%0t ns] [FAIL] %0s | Exp: 0x%h | Got: 0x%h", 
						 $time, test_phases[check_idx], expected_results[check_idx], captured_data);
				failed = failed + 1;
			end
			check_idx = check_idx + 1;
		end
		
		#(BIT_PERIOD * 2); 
	end
end

endmodule