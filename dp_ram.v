`timescale 1ns / 1ps

module dp_ram(
    input clk,
    input [2:0] waddr,raddr,
    input write,
    input [7:0] wdata,
    output [7:0] rdata
    );
    reg [7:0] memory [7:0];
    
    assign rdata = memory[raddr];
    
    always@(posedge clk) begin
        if (write) begin
            memory[waddr] <= wdata;
        end 
    end
    
endmodule
