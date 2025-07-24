`timescale 1ns / 1ps

module write_ctrl(
    input clkin, rstin,
    input [2:0] head_i,
    input ivalid,
    output reg iready,
    output reg [2:0] tail
    );

    //tail pointer update
    reg [2:0] next_tail;
    always@(posedge clkin or posedge rstin) begin
        if (rstin) tail <= 3'b000;
        else tail <= next_tail;
    end

    //tail pointer incrementer
    wire [2:0] inc_tail;
    gray_count cnt_tail(.gin(tail), .gout(inc_tail));


    //logic for checking full condition
    always @(*) begin
        iready = (head_i != inc_tail);
    end

    //tail pointer update logic
    always @(*) begin
        if (rstin) next_tail <= 3'b000;
        else if (iready && ivalid) next_tail <= inc_tail; //if valid data at input and FIFO not full -> write and increment tail
        else next_tail <= tail;
    end

endmodule
