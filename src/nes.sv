`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: alexc0888
// 
// Create Date: 06/22/2024 11:22:40 PM
// Design Name: 
// Module Name: nes
// Project Name: artixNES-EMU
// Target Devices: Nexys A7-50T (XC7A50T-1CSG324C FPGA)
// Tool Versions: 
// Description: Top level module for NES design
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module nes
(
    input logic sys_clock, reset, 
    output logic led0
);

//****************************************
// Internal Signals and Registers                      
//****************************************

// System signals 
logic masterClk;
logic cpuClk, ramClk;
logic [3:0] counter;

// Memory bus 
logic [7:0] dataRd, dataWr; 
logic [15:0] addr; 
logic wrEn;

// enable for 2KB CPU Ram (mirrored over next 6KB. 8KB worth of address space mapped to 2KB RAM)
logic ramSel;

artixNES_wrapper artixNES_BD
   (addr,
    dataRd,
    dataWr,
    masterClk,
    ramClk,
    ramSel,
    reset,
    sys_clock,
    wrEn);
    
cpu RP2A03 (.cpuClk(cpuClk), .reset(reset), 
            .dataRd(dataRd), .dataWr(dataWr), .addr(addr), .wrEn(wrEn));

memory_select memSel (.addr(addr), .ramSel(ramSel));
assign led0 = ramSel;


always_ff @(posedge masterClk, negedge reset)
begin 
    if(!reset)
    begin 
        counter <= '0;
        cpuClk  <=  0;
        ramClk  <=  0;
    end
    else 
    begin 
        counter <= counter + 1;
        if(counter == 5) // divide by 12
        begin 
            counter <= '0;
            cpuClk <= ~cpuClk; 
            ramClk <= ~ramClk;
        end
        else 
        begin 
            cpuClk <= cpuClk; 
            ramClk <= ramClk;
        end
    end
end

endmodule
