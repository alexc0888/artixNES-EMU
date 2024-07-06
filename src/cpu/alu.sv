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


assign statusUpdt.negative = portOut[7];
assign statusUpdt.zero     = (portOut == 8'h00);

assign statusUpdt.carry    = (((portA[7] | portB[7]) & ~portOut[7]) && (aluOp == ALU_ADD)) || ((~portOut[7]) && ((aluOp == ALU_SUB) || (aluOp == ALU_CMP)));
assign statusUpdt.overflow = (((portA[7] == portB[7]) && (portOut[7] != portA[7]) && (aluOp == ALU_ADD)) || 
                              ((portA[7] != portB[7]) && (portOut[7] == portB[7]) && (aluOp == ALU_SUB)));
// unused status flags in ALU
assign statusUpdt.spacer    = status.spacer;
assign statusUpdt.b_reak    = status.b_reak;
assign statusUpdt.decimal   = status.decimal; 
assign statusUpdt.interrupt = status.interrupt;

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
        ALU_SR   : portOut = portA >> portB; 
        ALU_SL   : portOut = portA << portB;
        ALU_CMP  : portOut = portA - portB;
    endcase
end




endmodule 