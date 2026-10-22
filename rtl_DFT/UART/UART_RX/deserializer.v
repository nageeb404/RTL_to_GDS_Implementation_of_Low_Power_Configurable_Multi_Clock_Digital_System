module deserializer (
    input               DESER_EN,
    input               SAMPLED_BIT,
    input               CLK,
    input               RST,
    input               DATA_VALID,
    output  reg [7:0]   P_DATA,     
    output      [7:0]   P_DATA_PAR
);

    reg [7:0] SHFT_REG;


    assign P_DATA_PAR = SHFT_REG;


    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            SHFT_REG <= 8'b0;
        end else if (DESER_EN) begin
            SHFT_REG <= {SAMPLED_BIT, SHFT_REG[7:1]};
        end
    end


    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            P_DATA <= 8'b0;
        end else if (DATA_VALID) begin
            P_DATA <= SHFT_REG;
        end
    end

endmodule
