module serializer # ( parameter WIDTH = 8 )
(
    input   wire                 CLK,
    input   wire                 RST,
    input   wire   [WIDTH-1:0]   P_DATA,
    input   wire                 ser_en, 
    input   wire                 BUSY,
    input   wire                 DATA_VALID, 
    output  wire                 ser_data,
    output  wire                 ser_done
);

    reg  [WIDTH-1:0]   data_reg;
    reg  [2:0]         COUNTER;
                
    // isolate input 
    always @ (posedge CLK , negedge RST)
    begin
        if (!RST)
        begin
            data_reg <= 'b0;
        end
        else if (DATA_VALID && !BUSY)
        begin
            data_reg <= P_DATA;
        end 
        else if (ser_en)
        begin
            data_reg <= data_reg >> 1; 
        end
    end
 
    // counter
    always @ (posedge CLK , negedge RST)
    begin
        if (!RST)
        begin
            COUNTER <= 'b0;
        end
        else
        begin
            if (ser_en)
            begin
                COUNTER <= COUNTER + 'b1;      
            end
            else 
            begin
                COUNTER <= 'b0;      
            end 
        end
    end 

    assign ser_done = (COUNTER == 3'b111) ? 1'b1 : 1'b0;

    assign ser_data = data_reg[0];

endmodule