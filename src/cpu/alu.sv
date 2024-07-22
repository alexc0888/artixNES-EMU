`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: alexc0888
// 
// Create Date: 07/05/2024 03:59:53 PM
// Design Name: 
// Module Name: alu
// Project Name: artixNES-EMU
// Target Devices: Nexys A7-50T (XC7A50T-1CSG324C FPGA)
// Tool Versions: 
// Description: Module for ALU
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "cpu_types.vh"
import cpu_types::*;

module alu
(
    input  logic [7:0]  portA, 
    input  logic [7:0]  portB, 
    input  aluop_t      aluOp,
    input  statusReg_t  status,
    output logic [7:0]  portOut, 
    output statusReg_t  statusUpdt
);
// unused status flags in ALU
assign statusUpdt.spacer    = status.spacer;
assign statusUpdt.b_reak    = status.b_reak;
assign statusUpdt.decimal   = status.decimal; 
assign statusUpdt.interrupt = status.interrupt;

// status update block 
always_comb
begin 
    statusUpdt.negative = portOut[7];
    statusUpdt.zero     = (portOut == 8'h00); 
    // maintain unless ALU calls for a change
    statusUpdt.carry    = status.carry; 
    statusUpdt.overflow = status.overflow;
    casez(aluOp)
    ALU_ADD : 
    begin 
        statusUpdt.carry    = ((portA[7] | portB[7]) & ~portOut[7]); // res >= 255 means cout
        statusUpdt.overflow = ((portA[7] == portB[7]) && (portOut[7] != portA[7]));
    end
    ALU_SUB, ALU_CMP : 
    begin 
        statusUpdt.carry    = ~portOut[7];
        // technically this flag is unused by ALU_CMP, but we just won't listen to this status bit.
        statusUpdt.overflow = (portA[7] != portB[7]) && (portOut[7] == portB[7]); 
    end
    // special carry set!
    ALU_SR, ALU_ROR : statusUpdt.carry = portA[0];
    ALU_SL, ALU_ROL : statusUpdt.carry = portA[7];
    endcase
end

// Operations 
always_comb 
begin
    // defaults 
    portOut = '0;
    casez(aluOp)
        ALU_AND  : portOut = portA & portB;
        ALU_EOR  : portOut = portA ^ portB;
        ALU_ORR  : portOut = portA | portB;
        ALU_PAS  : portOut = portB;
        ALU_ADD  : portOut = portA + portB + status.carry; 
        ALU_SUB  : portOut = portA - portB - ~status.carry;
        ALU_SR   : portOut = portA >> 1; // for LSR instruction
        ALU_SL   : portOut = portA << 1;           // for ASL instruction
        ALU_CMP  : portOut = portA - portB;
        ALU_ROR  : portOut = (portA >> 1) | ({status.carry, 7'h00});
        ALU_ROL  : portOut = (portA << 1) | ({7'h00, status.carry});
    endcase
end

endmodule 