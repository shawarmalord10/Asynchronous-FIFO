`timescale 1ns / 1ps

module BFsync(
    input [2:0] d,
    input clk, rst,
    output reg [2:0] q
    );
    
    reg [2:0] qi;
    always@(posedge clk or posedge rst) begin
        if (rst) begin 
            q <= 3'b000;
            qi<= 3'b000;
        end
        else {q,qi} <= {qi,d}; 
    end
    
endmodule
