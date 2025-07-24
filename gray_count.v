`timescale 1ns / 1ps

module gray_count(
    input [2:0] gin,
    output [2:0] gout
    );

    wire [2:0] bin, bin_inc;

    // gray to bin
    assign  bin[2] = gin[2],
            bin[1] = gin[1] ^ bin[2],
            bin[0] = gin[0] ^ bin[1];
    
    assign bin_inc = bin + 1;

    //bin to gray
    assign gout = bin_inc ^ (bin_inc>>1);

endmodule

