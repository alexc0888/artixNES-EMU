`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: alexc0888
// 
// Create Date: 06/22/2024 11:34:48 PM
// Design Name: 
// Module Name: memory_select
// Project Name: artixNES-EMU
// Target Devices: Nexys A7-50T (XC7A50T-1CSG324C FPGA)
// Tool Versions: 
// Description: Enables memory enable signal for either internal
//              CPU RAM, PPU, or ROM cartridge
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module memory_select
(
    input [15:0] addr, 
    output ramSel
);

assign ramSel = ~(addr[13] | addr[14] | addr[15]);


endmodule
