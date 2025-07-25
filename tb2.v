`timescale 1ns / 1ps

module tb();

    reg clkin, rstin, clkout, rstout;
    reg ivalid, oready;
    wire iready, ovalid;
    reg [7:0] input_data;
    wire [7:0] output_data;
    
    //test metrics
    integer write_count = 0;
    integer read_count = 0;
    integer error_count = 0;
    reg [7:0] expected_data = 8'h01;
    
    //instantiate FIFO
    asyncfifo dut (
        .clkin(clkin),
        .rstin(rstin),
        .clkout(clkout),
        .rstout(rstout),
        .ivalid(ivalid),
        .oready(oready),
        .iready(iready),
        .ovalid(ovalid),
        .din(input_data),
        .dout(output_data)
    );
    
    
    //clock generation 
    initial begin
        clkin = 0;
        forever #5 clkin = ~clkin;  // 100MHz (10ns period)
    end
    
    initial begin
        clkout = 0;
        forever #7 clkout = ~clkout;  // ~71MHz (14ns period)
    end
    
    initial begin
        $display("=== Testbench Starting ===");
        $display("Input Clock: 100MHz, Output Clock: 71MHz");
        $display("");
        
        //initialization
        rstin = 1;
        rstout = 1;
        ivalid = 0;
        oready = 0;
        input_data = 0;
        
        repeat(5) @(posedge clkin);
        repeat(5) @(posedge clkout);
        
        $display("Time=%0t: releasing resets", $time);
        rstin = 0;
        rstout = 0;
        
        //reset propogation interval
        repeat(10) @(posedge clkin);

        write_operation();
        read_operation();
        reset_inputdata();
        write_full();
        read_till_empty();
        reset_inputdata();
        concurrent_readnwrite();
    end
    
    task write_operation;
        repeat(3) begin
            @(posedge clkin);
            wait (iready);
            input_data = input_data + 1;
            ivalid = 1'b1;
            write_count = write_count + 1;
            $display("time=%0t: writing data=0x%02h, write_count=%0d",$time, input_data, write_count);
            @(posedge clkin);
            ivalid = 1'b0;
            @(posedge clkin);
        end
    endtask
    
    task read_operation;
        repeat(3) begin
            @(posedge clkout);
            wait (ovalid);
            oready = 1'b1;
            @(posedge clkout);
            read_count = read_count + 1;
            $display("time=%0t: reading data=0x%02h, read_count=%0d",$time, output_data, read_count);
            oready = 1'b0;
            @(posedge clkout);
        end
    endtask
    
   task reset_inputdata;
        input_data = 0;
   endtask
   
   
    task write_full;
        repeat(8) begin
            @(posedge clkin);
            if (iready) begin
                input_data = input_data + 1;
                ivalid = 1'b1;
                write_count = write_count + 1;
                $display("time=%0t: writing data=0x%02h, write_count=%0d",$time, input_data, write_count);
                @(posedge clkin);
                ivalid = 1'b0;
            end
            repeat(2) @(posedge clkin);
        end
    endtask
    
    task read_till_empty;
        repeat(8) begin
            @(posedge clkout);
            if (ovalid) begin
                oready = 1'b1;
                @(posedge clkout);
                read_count = read_count + 1;
                $display("time=%0t: reading data=0x%02h, read_count=%0d",$time, output_data, read_count);
                oready = 1'b0;
            end
            repeat(2)@(posedge clkout);
        end
    endtask
    
    task concurrent_readnwrite;
        begin
            fork
                //write
                begin
                    repeat(5) begin
                        @(posedge clkin);
                        wait(iready);
                        input_data = input_data + 1;
                        ivalid = 1;
                        write_count = write_count + 1;
                        $display("Time=%0t: Concurrent write data=0x%02h", $time, input_data);
                        @(posedge clkin);
                        ivalid = 0;
                        repeat(2) @(posedge clkin); //random delay
                    end
                end
                
                //read
                begin
                    repeat(5) begin
                        @(posedge clkout);
                        wait(ovalid);
                        oready = 1;
                        @(posedge clkout);
                        read_count = read_count + 1;
                        $display("Time=%0t: Concurrent read data=0x%02h, expected=0x%02h",
                            $time, output_data, expected_data);
                        if (output_data !== expected_data) begin
                            $display("ERROR: Data mismatch in concurrent test!");
                            error_count = error_count + 1;
                        end
                        expected_data = expected_data + 1;
                        oready = 0;
                        repeat(2) @(posedge clkout);
                    end
                end
            join
        end
    endtask

endmodule
