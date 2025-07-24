`timescale 1ns / 1ps

module asyncfifo(
    input clkin, clkout,
    input rstin, rstout,
    input ivalid, oready,
    input [7:0] din,
    output iready, ovalid,
    output [7:0] dout
    );

    wire [2:0] tail, next_tail, head, next_head;
    wire [2:0] inc_head, inc_tail;
    wire [2:0] head_i, tail_o;

    dp_ram ram(
        .clk(clkin), 
        .wdata(din), 
        .waddr(tail),
        .raddr(head),
        .write(iready && ivalid),
        .rdata(dout)
    );

    BFsync head2in(
        .d(head), 
        .clk(clkin), 
        .rst(rstin),
        .q(head_i)
        );

    BFsync tail2out(
        .d(tail), 
        .clk(clkout), 
        .rst(rstout),
        .q(tail_o)
        );


    write_ctrl wr_ctrl(
        .clkin(clkin),
        .rstin(rstin),
        .head_i(head_i),
        .ivalid(ivalid),
        .iready(iready),
        .tail(tail)
    );

    read_ctrl re_ctrl(
        .clkout(clkout),
        .rstout(rstout),
        .tail_o(tail_o),
        .oready(oready),
        .ovalid(ovalid),
        .head(head)
    );

endmodule
