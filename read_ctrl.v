`timescale 1ns / 1ps


module read_ctrl(
    input clkout, rstout,
    input oready,
    input [2:0] tail_o,
    output reg ovalid,
    output reg [2:0] head
    );

    //head pointer update
    reg [2:0] next_head;
    always @(posedge clkout or posedge rstout) begin
        if (rstout) head <= 3'b000;
        else head <= next_head;
    end

    //head pointer incrementer
    wire [2:0] inc_head;
    gray_count cnt_head(.gin(head), .gout(inc_head));

    //checking for empty condition
    always@(*) begin
        ovalid = (tail_o != head);
    end

    //empty condition logic
    always @(*) begin
        if (rstout) next_head <= 3'b000;
        else if (ovalid && oready) next_head <= inc_head; //if output line ready and FIFO not empty -> read and increment head
        else next_head <= head;
    end

endmodule
