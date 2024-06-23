`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: alexc0888
// 
// Create Date: 06/22/2024 03:30:16 PM
// Design Name: 
// Module Name: cpu
// Project Name: artixNES-EMU
// Target Devices: Nexys A7-50T (XC7A50T-1CSG324C FPGA)
// Tool Versions: 
// Description: Module for modified MOS 6502 CPU inside of RP2A03 chip
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "cpu_types.vh"

module cpu
(
    // system
    input  logic        cpuClk, 
    input  logic        reset, 
    // memory 
    input  logic [7:0]  dataRd,
    output logic [7:0]  dataWr, 
    output logic [15:0] addr,
    output logic        wrEn // select between read (0) or write (1) operation
);

import cpu_types::*;


//****************************************
// Internal Signals and Registers                      
//****************************************

// CPU Registers 
logic [15:0] PC; 
logic [15:0] PC_next; 
statusReg_t statusReg; 
statusReg_t statusReg_next;
logic  [7:0] SP, acReg, xReg, yReg;
logic  [7:0] SP_next, acReg_next, xReg_next, yReg_next;

// opcode_t instr; 

// FSM 
cpustate_t currState, nextState;




always_ff @(posedge cpuClk, negedge reset) 
begin 
    if(!reset)
    begin 
        PC        <= 16'hFFFC;
        SP        <= 8'hFD; // should be initialized by software, but after power-on SP is initialized to 0xFD on NES hw
        acReg     <= 8'h00; 
        xReg      <= 8'h00; 
        yReg      <= 8'h00; 
        statusReg <= 8'h04;

        currState <= INIT;
    end
    else 
    begin 
        PC        <= PC_next;
        SP        <= SP_next;
        acReg     <= acReg_next; 
        xReg      <= xReg_next; 
        yReg      <= yReg_next; 
        statusReg <= statusReg_next;

        currState <= nextState;
    end
end

// CPU Next state logic 
always_comb 
begin 
    // default values 
    nextState = currState; 

    case(currState)
        INIT:   nextState = DECODE; // do this for now
        DECODE: nextState = DECODE;
    endcase


end

// CPU Output Logic
always_comb 
begin
    // default values 
    statusReg_next = statusReg; 
    yReg_next      = yReg;
    xReg_next      = xReg;
    acReg_next     = acReg;
    SP_next        = SP;
    PC_next        = PC + 1;  // increment PC by default 

    // output signals to RAM
    addr    = PC; // kp fetching instr data by default
    wrEn    = 0; 
    dataWr  = 8'h00; 

    // case(currState)

    //     INIT: 
    //     begin 
    //     end

    // endcase

end











endmodule
