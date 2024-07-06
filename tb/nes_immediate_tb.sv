`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/06/2024 12:25:09 AM
// Design Name: 
// Module Name: nes_immediate_tb
// Project Name: artixNES-EMU
// Target Devices: Nexys A7-50T (XC7A50T-1CSG324C FPGA)
// Tool Versions: 
// Description: Testbench for verifying instructions with immediate addressing modes
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module nes_immediate_tb();
localparam CLK_PERIOD = 1000; // 1MHZ
logic tb_clk; 
logic tb_reset;

// Clock generation block
always
begin
    // Start with clock low to avoid false rising edge events at t=0
    tb_clk = 1'b0;
    // Wait half of the clock period before toggling clock value (maintain 50% duty cycle)
    #(CLK_PERIOD/2.0);
    tb_clk = 1'b1;
    // Wait half of the clock period before toggling clock value via rerunning the block (maintain 50% duty cycle)
    #(CLK_PERIOD/2.0);
end

nes DUT (.sys_clock(tb_clk), .reset(tb_reset));

initial 
begin 
    #(0.1);
    tb_reset = 0; 
    @(negedge tb_clk);
    @(negedge tb_clk);
    tb_reset = 1;
    
    @(negedge tb_clk);
    @(negedge tb_clk);

    for(int i = 0; i < 32; i++)
    begin 
        @(negedge tb_clk);
        @(negedge tb_clk);
    end

end
endmodule
