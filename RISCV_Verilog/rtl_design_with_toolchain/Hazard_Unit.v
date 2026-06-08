//==============================================================
// Hazard Unit
//==============================================================
// This module handles pipeline hazards in a pipelined RISC-V CPU.
//
// It mainly performs 3 tasks:
//
// 1. Forwarding (Data Hazard Resolution)
//    - Sends data directly from later pipeline stages
//      to the Execute stage without waiting for
//      register writeback.
//
// 2. Stalling (Load-Use Hazard Handling)
//    - Stops pipeline temporarily when forwarding
//      cannot solve the dependency.
//
// 3. Flushing (Branch Hazard Handling)
//    - Removes wrong instructions after a branch/jump.
//
//==============================================================

module Hazard_Unit(

    //==========================================================
    // Source register addresses
    //==========================================================
    
    // Source registers of instruction in Decode stage
    input  [4:0] Rs1D,
    input  [4:0] Rs2D,

    // Source registers of instruction in Execute stage
    input  [4:0] Rs1E,
    input  [4:0] Rs2E,

    //==========================================================
    // Destination register addresses
    //==========================================================

    // Destination register of instruction in Execute stage
    input  [4:0] RdE,

    // Destination register of instruction in Memory stage
    input  [4:0] RdM,

    // Destination register of instruction in Writeback stage
    input  [4:0] RdW,

    //==========================================================
    // Control signals
    //==========================================================

    // Indicates instruction in MEM stage writes to register file
    input  RegWriteM,

    // Indicates instruction in WB stage writes to register file
    input  RegWriteW,

    // ResultSrcE0 = 1 means current EX-stage instruction is a LOAD instruction (lw)
    input  ResultSrcE0,

    // PCSrcE becomes 1 when branch/jump is taken
    input  PCSrcE,

    // Reset signal: rst_n=1: Hazard detection works, rst_n=0: Hazard unit disabled
    input  rst_n,

    //==========================================================
    // Outputs
    //==========================================================

    // Forwarding control signals
    //
    // 00 -> No forwarding (use register file data)
    // 10 -> Forward from EX/MEM stage
    // 01 -> Forward from MEM/WB stage
    //
    output reg [1:0] ForwardAE,
    output reg [1:0] ForwardBE,

    // Stall signals
    output StallD,
    output StallF,

    // Flush signals
    output FlushD,
    output FlushE
);

wire lwStall; // Internal wire for detecting load-use hazard

//==============================================================
// FORWARDING LOGIC
//==============================================================
//
// Purpose:
// --------
// Solve data hazards without stalling the pipeline.
//
// Example:
//
// add x5, x1, x2
// sub x6, x5, x3
//
// 'sub' needs x5 before it is written back.
//
// So we FORWARD the result directly from later stages.
//
//==============================================================
always @(*) begin
    //----------------------------------------------------------
    // Default condition:
    // No forwarding
    //----------------------------------------------------------
    //
    // 00 means ALU operands come directly
    // from register file outputs.
    //
    ForwardAE = 2'b00;
    ForwardBE = 2'b00;

    //==========================================================
    // Forwarding for ALU Operand A
    //==========================================================
    //
    // Rs1E = source register needed in Execute stage
    //
    // We check whether a later instruction already
    // has the updated value.
    //
    //==========================================================
    //----------------------------------------------------------
    // Case 1:
    // Forward from Memory Stage (EX/MEM)
    //----------------------------------------------------------
    //
    // Condition:
    //
    // 1. Current instruction needs Rs1E
    // 2. Previous instruction writes to RdM
    // 3. Both registers are same
    // 4. Register is not x0
    //
    // This has HIGHER PRIORITY because MEM stage
    // contains the newest value.
    if ((Rs1E == RdM) && RegWriteM && (Rs1E != 0))
        // 10 selects forwarded data from MEM stage
        ForwardAE = 2'b10;
    //----------------------------------------------------------
    // Case 2:
    // Forward from Writeback Stage (MEM/WB)
    //----------------------------------------------------------
    //
    // Used when matching data is not found in MEM stage.
    else if ((Rs1E == RdW) && RegWriteW && (Rs1E != 0))
        // 01 selects forwarded data from WB stage
        ForwardAE = 2'b01;


    //==========================================================
    // Forwarding for ALU Operand B
    //==========================================================
    //
    // Same logic as Operand A
    // but for Rs2E.
    //
    //==========================================================
    //----------------------------------------------------------
    // Case 1:
    // Forward from Memory Stage
    //----------------------------------------------------------
    if ((Rs2E == RdM) && RegWriteM && (Rs2E != 0))
        // Forward latest ALU result
        ForwardBE = 2'b10;
    //----------------------------------------------------------
    // Case 2:
    // Forward from Writeback Stage
    //----------------------------------------------------------
    else if ((Rs2E == RdW) && RegWriteW && (Rs2E != 0))
        // Forward WB result
        ForwardBE = 2'b01;

end

//==============================================================
// LOAD-USE HAZARD DETECTION
//==============================================================
//
// Forwarding cannot solve this hazard.
//
// Example:
//
// lw  x5, 0(x1)
// add x6, x5, x2
//
// Problem:
// --------
// 'lw' gets data from memory only in MEM stage,
// but 'add' needs it earlier in EX stage.
//
// So pipeline must STALL for one cycle.
//
//==============================================================
assign lwStall =

    // Current instruction in EX stage is LOAD
    (ResultSrcE0 == 1)

    &&

    (
        // Decode-stage instruction needs same register
        (RdE == Rs1D)

        ||

        (RdE == Rs2D)
    );

//==============================================================
// STALL LOGIC
//==============================================================
//
// Stall Fetch and Decode stages.
//
// This freezes:
//
// 1. Program Counter
// 2. IF/ID Pipeline Register
//
// Thus pipeline waits until load data becomes available.
//
//==============================================================
assign StallF = lwStall & (rst_n);
assign StallD = lwStall & rst_n;

//==============================================================
// FLUSH LOGIC
//==============================================================
//
// Flush means inserting a NOP (bubble).
//
//==============================================================


//--------------------------------------------------------------
// Flush Execute Stage
//--------------------------------------------------------------
//
// Flush when:
//
// 1. Load-use hazard occurs
//    -> insert bubble
//
// OR
//
// 2. Branch/jump changes PC
//    -> wrong instruction entered pipeline
//
//--------------------------------------------------------------
assign FlushE = (lwStall | PCSrcE) & rst_n;

//--------------------------------------------------------------
// Flush Decode Stage
//--------------------------------------------------------------
//
// If branch is taken:
//
// Instruction already fetched in Decode stage
// is wrong and must be discarded.
//
//--------------------------------------------------------------
assign FlushD = PCSrcE & rst_n;

endmodule