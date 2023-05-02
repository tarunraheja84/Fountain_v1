`timescale 1ns/1ns
`include "fountain_v1_serial.v"

module fountain_v1_tb();

    reg clk;
    reg rst;
    reg start;
    reg [63:0] data_in;
    wire [63:0] data_out;

    fountain_v1_serial uut (
        .clk(clk),
        .start(start),
        .data_in(data_in),
        .data_out(data_out)
    );

    initial begin
        $dumpfile("fountain_v1_tb.vcd");
        $dumpvars(0, fountain_v1_tb);

        // Initialize inputs
        clk = 0;
        rst = 0;
        start = 0;
        data_in = 8'b00000000;
        #10 rst = 1;
        #10 rst = 0;

        // Start the module
        #10 start = 1;
        #100 start = 0;

        // Send data
        #50 data_in = 8'b01010101;
        #50 data_in = 8'b10101010;

        // Wait for the module to finish
        #100000 $finish;
    end

    always #5 clk = ~clk;

endmodule
