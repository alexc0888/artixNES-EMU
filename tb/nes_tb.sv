`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/23/2024 01:47:52 AM
// Design Name: 
// Module Name: nes_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module nes_tb();
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
    @(negedge tb_clk);
    @(negedge tb_clk);
    @(negedge tb_clk);
end
endmodule
