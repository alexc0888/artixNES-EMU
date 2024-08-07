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
statusReg_t aluStatusUpdt;
logic  [7:0] SP, acReg, xReg, yReg;
logic  [7:0] SP_next, acReg_next, xReg_next, yReg_next;

opcode_t instr, instr_next; // Latch instruction opcodes  
// ALU
aluop_t  aluOp;
logic [7:0] portA, portB, portOut;

// FSM 
cpustate_t currState, nextState;

// helper signals 
logic loadImm; 
logic loadWaste;




always_ff @(posedge cpuClk, negedge reset) 
begin 
    if(!reset)
    begin 
        // PC        <= 16'hFFFC;
        PC        <= 16'h0000; // for now initialize instruction data to zero page of RAM for testing
        // SP        <= 8'hFD; // should be initialized by software, but after power-on SP is initialized to 0xFD on NES hw
        SP        <= 8'hFF;    // set this explicitly for testing
        acReg     <= 8'h00; 
        xReg      <= 8'h00; 
        yReg      <= 8'h00; 
        statusReg <= 8'h04;

        currState <= INIT;
        instr     <= BRK_IMP;
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
        instr     <= instr_next;

    end
end

// CPU Next state logic 
always_comb 
begin 
    // default values 
    nextState = currState; 

    case(currState)
        INIT:     nextState = DECODE; // do this for now
        DECODE:   nextState = (loadImm   ? IMM_BYTE  : 
                              (loadWaste ? TOSS_BYTE : DECODE));
        IMM_BYTE:  nextState = DECODE;
        TOSS_BYTE: nextState = DECODE;
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
    instr_next     = instr;

    // output signals to RAM
    addr    = PC; // kp fetching instr data by default
    wrEn    = 0; 
    dataWr  = 8'h00; 

    // helper signals 
    loadImm   =  0;
    loadWaste =  0;
    portA     = '0; 
    portB     = '0; 
    aluOp     = ALU_AND;


    case(currState)

        INIT: 
        begin 
        end

        DECODE: 
        begin 
            instr_next = opcode_t'(dataRd);
            // immediate addressing modes 
            if((dataRd == ORA_IMM) || (dataRd == ADC_IMM) || (dataRd == AND_IMM) || (dataRd == CMP_IMM) || 
               (dataRd == CPX_IMM) || (dataRd == CPY_IMM) || (dataRd == EOR_IMM) || (dataRd == LDA_IMM) ||
               (dataRd == LDX_IMM) || (dataRd == LDY_IMM) || (dataRd == SBC_IMM))
            begin 
                loadImm = 1;
            end
            // accumulator addressing modes (1 byte instructions)
            else if((dataRd == ASL_IMP) || (dataRd == LSR_IMP) || (dataRd == ROL_IMP) || (dataRd == ROR_IMP) ||
                    (dataRd == CLC_IMP) || (dataRd == CLD_IMP) || (dataRd == CLI_IMP) || (dataRd == CLV_IMP) ||
                    (dataRd == DEX_IMP) || (dataRd == DEY_IMP) || (dataRd == INX_IMP) || (dataRd == INY_IMP) ||
                    (dataRd == NOP_IMP))
            begin 
                loadWaste = 1;
            end
        end

        IMM_BYTE: 
        begin 
            if(instr == ORA_IMM)
            begin 
                portA          = acReg;
                portB          = dataRd;
                acReg_next     = portOut;
                statusReg_next.negative = aluStatusUpdt.negative;
                statusReg_next.zero     = aluStatusUpdt.zero;
                aluOp          = ALU_ORR;
            end
            else if(instr == ADC_IMM)
            begin 
                portA          = acReg; 
                portB          = dataRd;
                acReg_next     = portOut;
                statusReg_next = aluStatusUpdt; // updates all alu flags (NZCV)
                aluOp          = ALU_ADD; 
            end
            else if(instr == AND_IMM)
            begin 
                portA          = acReg;
                portB          = dataRd; 
                acReg_next     = portOut; 
                statusReg_next.negative = aluStatusUpdt.negative;
                statusReg_next.zero     = aluStatusUpdt.zero;
                aluOp          = ALU_AND;
            end
            else if(instr == CMP_IMM) // simply for updating flags, dont save res
            begin 
                portA = acReg; 
                portB = dataRd; 
                statusReg_next.negative = aluStatusUpdt.negative; 
                statusReg_next.zero     = aluStatusUpdt.zero; 
                statusReg_next.carry    = aluStatusUpdt.carry;
                aluOp                   = ALU_CMP;
            end
            else if(instr == CPX_IMM) 
            begin 
                portA = xReg; 
                portB = dataRd;
                statusReg_next.negative = aluStatusUpdt.negative; 
                statusReg_next.zero     = aluStatusUpdt.zero; 
                statusReg_next.carry    = aluStatusUpdt.carry;
                aluOp                   = ALU_CMP;
            end
            else if(instr == CPY_IMM)
            begin 
                portA = yReg; 
                portB = dataRd;
                statusReg_next.negative = aluStatusUpdt.negative; 
                statusReg_next.zero     = aluStatusUpdt.zero; 
                statusReg_next.carry    = aluStatusUpdt.carry;
                aluOp                   = ALU_CMP;
            end
            else if(instr == EOR_IMM)
            begin 
                portA          = acReg;
                portB          = dataRd;
                acReg_next     = portOut;
                statusReg_next.negative = aluStatusUpdt.negative;
                statusReg_next.zero     = aluStatusUpdt.zero;
                aluOp          = ALU_EOR;
            end
            else if(instr == LDA_IMM)
            begin 
                portB          = dataRd;
                acReg_next     = portOut;
                statusReg_next.negative = aluStatusUpdt.negative;
                statusReg_next.zero     = aluStatusUpdt.zero;
                aluOp          = ALU_PAS;
            end
            else if(instr == LDX_IMM)
            begin 
                portB          = dataRd;
                xReg_next      = portOut;
                statusReg_next.negative = aluStatusUpdt.negative;
                statusReg_next.zero     = aluStatusUpdt.zero;
                aluOp          = ALU_PAS;
            end
            else if(instr == LDY_IMM)
            begin 
                portB          = dataRd;
                yReg_next      = portOut;
                statusReg_next.negative = aluStatusUpdt.negative;
                statusReg_next.zero     = aluStatusUpdt.zero;
                aluOp          = ALU_PAS;
            end
            else if(instr == SBC_IMM)
            begin 
                portA          = acReg; 
                portB          = dataRd;
                acReg_next     = portOut;
                statusReg_next = aluStatusUpdt; // updates all alu flags (NZCV)
                aluOp          = ALU_SUB; 
            end
        end

        TOSS_BYTE: 
        begin 
            PC_next = PC; // jam the PC since these are 1-byte instructions
            if(instr == ASL_IMP)
            begin 
                portA          = acReg;
                acReg_next     = portOut;
                statusReg_next.negative = aluStatusUpdt.negative;
                statusReg_next.zero     = aluStatusUpdt.zero;
                statusReg_next.carry    = aluStatusUpdt.carry;
                aluOp          = ALU_SL;
            end
            else if(instr == LSR_IMP)
            begin 
                portA          = acReg;
                acReg_next     = portOut;
                statusReg_next.negative = 0; // forced to 0 by LSR
                statusReg_next.zero     = aluStatusUpdt.zero;
                statusReg_next.carry    = aluStatusUpdt.carry;
                aluOp          = ALU_SR;
            end
            else if(instr == ROL_IMP)
            begin 
                portA      = acReg;
                acReg_next = portOut; 
                statusReg_next.negative = aluStatusUpdt.negative;
                statusReg_next.zero     = aluStatusUpdt.zero;
                statusReg_next.carry    = aluStatusUpdt.carry;
                aluOp          = ALU_ROL;
            end
            else if(instr == ROR_IMP)
            begin 
                portA      = acReg;
                acReg_next = portOut; 
                statusReg_next.negative = aluStatusUpdt.negative;
                statusReg_next.zero     = aluStatusUpdt.zero;
                statusReg_next.carry    = aluStatusUpdt.carry;
                aluOp          = ALU_ROR;
            end
            // skipping BRK instr for now, do later
            else if(instr == CLC_IMP)
            begin 
                statusReg_next.carry = 0; 
            end
            else if(instr == CLD_IMP)
            begin 
                statusReg_next.decimal = 0; // this is always 0 anyways in RP2A03, so this is just shown for clarity
            end
            else if(instr == CLI_IMP)
            begin 
                statusReg_next.interrupt = 0;
            end
            else if(instr == CLV_IMP)
            begin 
                statusReg_next.overflow = 0;
            end
            else if(instr == DEX_IMP) // just a -1 decrementer
            begin 
                portA         = xReg; 
                portB         = 8'h01;
                xReg_next     = portOut;
                statusReg_next.negative = aluStatusUpdt.negative; 
                statusReg_next.zero     = aluStatusUpdt.zero;
                aluOp          = ALU_CMP; 
            end
            else if(instr == DEY_IMP)
            begin 
                portA         = yReg; 
                portB         = 8'h01;
                yReg_next     = portOut;
                statusReg_next.negative = aluStatusUpdt.negative; 
                statusReg_next.zero     = aluStatusUpdt.zero;
                aluOp          = ALU_CMP; 
            end
            else if(instr == INX_IMP) // just a +1 incrementer
            begin 
                portA         = xReg; 
                portB         = 8'hff;
                xReg_next     = portOut;
                statusReg_next.negative = aluStatusUpdt.negative; 
                statusReg_next.zero     = aluStatusUpdt.zero;
                aluOp          = ALU_CMP; // using xReg - (-1) to reduce logic
            end
            else if(instr == INY_IMP) // just a +1 incrementer
            begin 
                portA         = yReg; 
                portB         = 8'hff;
                yReg_next     = portOut;
                statusReg_next.negative = aluStatusUpdt.negative; 
                statusReg_next.zero     = aluStatusUpdt.zero;
                aluOp          = ALU_CMP; // using xReg - (-1) to reduce logic
            end
            // else if(instr == NOP_IMP) do nothing!
        end

    endcase

end



alu alu (.portA(portA), .portB(portB), .aluOp(aluOp), .portOut(portOut), .statusUpdt(aluStatusUpdt));










endmodule
