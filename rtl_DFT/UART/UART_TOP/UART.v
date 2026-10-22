module UART (
    input               RST,
    input               TX_CLK,
    input               RX_CLK,
    input				parity_type,
	input				parity_enable,
	
    // RX Interface
    input               RX_IN,
    input       [5:0]   RX_PRESCALE,
//    input               RX_PAR_EN,
//    input               RX_PAR_TYP,
    output      [7:0]   RX_P_DATA,
    output              RX_DATA_VALID,
    output              RX_PAR_ERR,
    output              RX_STP_ERR,
    
    // TX Interface
    input       [7:0]   TX_P_DATA,
    input               TX_DATA_VALID,
//    input               TX_PAR_EN,
//    input               TX_PAR_TYP,
    output              TX_OUT,
    output              TX_BUSY
);

    UART_TX_TOP U_TX (
        .P_DATA     (TX_P_DATA),
        .DATA_VALID (TX_DATA_VALID),
        .PAR_EN     (parity_enable),
        .PAR_TYP    (parity_type),
        .CLK        (TX_CLK),
        .RST        (RST),
        .TX_OUT     (TX_OUT),
        .BUSY       (TX_BUSY)
    );

    UART_RX_TOP U_RX (
        .RX_IN      (RX_IN),
        .PAR_EN     (parity_enable),
        .PAR_TYP    (parity_type),
        .PRESCALE   (RX_PRESCALE),
        .CLK        (RX_CLK),
        .RST        (RST),
        .P_DATA     (RX_P_DATA),
        .PAR_ERR    (RX_PAR_ERR),
        .STP_ERR    (RX_STP_ERR),
        .DATA_VALID (RX_DATA_VALID)
    );

endmodule