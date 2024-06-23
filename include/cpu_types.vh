//////////////////////////////////////////////////////////////////////////////////
// Custom types for opcodes and state machine for cpu.sv
// 
//////////////////////////////////////////////////////////////////////////////////

`ifndef CPU_TYPES_VH
`define CPU_TYPES_VH
package cpu_types;

    // opcodes
    typedef enum logic [7:0] {
      //
      BRK_IMP   = 8'h00, 
      ORA_X_IND = 8'h01, 
      ORA_ZPG   = 8'h05, 
      ASL_ZPG   = 8'h06, 
      PHP_IMP   = 8'h08,
      ORA_IMM   = 8'h09, 
      ASL_IMP   = 8'h0A, 
      ORA_ABS   = 8'h0D, 
      ASL_ABS   = 8'h0E,

      BPL_REL   = 8'h10, 
      ORA_Y_IND = 8'h11, 
      ORA_X_ZPG = 8'h15, 
      ASL_X_ZPG = 8'h16, 
      CLC_IMP   = 8'h18, 
      ORA_Y_ABS = 8'h19, 
      ORA_X_ABS = 8'h1D, 
      ASL_X_ABS = 8'h1E, 

      JSR_ABS   = 8'h20, 
      AND_X_IND = 8'h21, 
      BIT_ZPG   = 8'h24, 
      AND_ZPG   = 8'h25, 
      ROL_ZPG   = 8'h26, 
      PLP_IMP   = 8'h28, 
      AND_IMM   = 8'h29, 
      ROL_IMP   = 8'h2A, 
      BIT_ABS   = 8'h2C, 
      AND_ABS   = 8'h2D, 
      ROL_ABS   = 8'h2E




    } opcode_t;

    // alu op type
    typedef enum logic [2:0] {
      ALU_AND     = 4'h0,
      ALU_EOR     = 4'h1, 
      ALU_ORR     = 4'h2, 
      ALU_PAS     = 4'h3, 
      ALU_ADD     = 4'h4, 
      ALU_SUB     = 4'h5, 
      ALU_SR      = 4'h6, 
      ALU_SL      = 4'h7
    } aluop_t;

    typedef struct packed {
    logic negative; 
    logic overflow; 
    logic spacer;
    logic b_reak;
    logic decimal; // ignored in RP2A03 chip
    logic interrupt; 
    logic zero; 
    logic carry;
    } statusReg_t;

    // CPU state type
    typedef enum logic [2:0] {
      INIT,
      DECODE,
      BYTE2, 
      BYTE3, 
      LD_DATA
    } cpustate_t;

endpackage
`endif //CPU_TYPES_VH