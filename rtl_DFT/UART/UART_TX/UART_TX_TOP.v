module UART_TX_TOP (
    input  [7:0] P_DATA,
    input        DATA_VALID,
    input        PAR_EN,
    input        PAR_TYP,
    input        CLK,
    input        RST,
    output       TX_OUT,
    output       BUSY
);

    wire        ser_done_w;
    wire        ser_en_w;
    wire        ser_data_w;
    wire        par_bit_w;
    wire [1:0]  mux_sel_w;

	serializer #( .WIDTH(8) ) ser (
        .CLK        (CLK),
        .RST        (RST),
        .P_DATA     (P_DATA),
        .ser_en     (ser_en_w),
        .BUSY       (BUSY),
        .DATA_VALID (DATA_VALID),
        .ser_data   (ser_data_w),
        .ser_done   (ser_done_w)
    );

    parity_calc par (
        .P_DATA     (P_DATA),
        .DATA_VALID (DATA_VALID),
        .BUSY       (BUSY),
        .PAR_TYP    (PAR_TYP),
        .CLK        (CLK),
        .RST        (RST),
        .PAR_BIT    (par_bit_w)
    );
	
	
    TX_FSM fsm (
        .DATA_VALID(DATA_VALID),
        .PAR_EN    (PAR_EN),
        .SER_DONE  (ser_done_w),
        .CLK       (CLK),
        .RST       (RST),
        .MUX_SEL   (mux_sel_w),
        .SER_EN    (ser_en_w),
        .BUSY      (BUSY)
    );

    MUX4x1 mux (
        .i00    (1'b0),
        .i01    (1'b1),
        .i10    (ser_data_w),
        .i11    (par_bit_w),
        .MUX_SEL(mux_sel_w),
		.CLK(CLK),
		.RST(RST),
        .TX_OUT (TX_OUT)
    );

endmodule