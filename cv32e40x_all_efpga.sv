package cv32e40x_pkg;

////////////////////////////////////////////////
//    ___         ____          _             //
//   / _ \ _ __  / ___|___   __| | ___  ___   //
//  | | | | '_ \| |   / _ \ / _` |/ _ \/ __|  //
//  | |_| | |_) | |__| (_) | (_| |  __/\__ \  //
//   \___/| .__/ \____\___/ \__,_|\___||___/  //
//        |_|                                 //
////////////////////////////////////////////////

  typedef enum logic [6:0] {
                            OPCODE_SYSTEM    = 7'h73,
                            OPCODE_FENCE     = 7'h0f,
                            OPCODE_OP        = 7'h33,
                            OPCODE_OPIMM     = 7'h13,
                            OPCODE_STORE     = 7'h23,
                            OPCODE_LOAD      = 7'h03,
                            OPCODE_BRANCH    = 7'h63,
                            OPCODE_JALR      = 7'h67,
                            OPCODE_JAL       = 7'h6f,
                            OPCODE_AUIPC     = 7'h17,
                            OPCODE_LUI       = 7'h37,
                            OPCODE_AMO       = 7'h2F
                            } opcode_e;

//////////////////////////////////////////////////////////////////////////////
//      _    _    _   _    ___                       _   _                  //
//     / \  | |  | | | |  / _ \ _ __   ___ _ __ __ _| |_(_) ___  _ __  ___  //
//    / _ \ | |  | | | | | | | | '_ \ / _ \ '__/ _` | __| |/ _ \| '_ \/ __| //
//   / ___ \| |__| |_| | | |_| | |_) |  __/ | | (_| | |_| | (_) | | | \__ \ //
//  /_/   \_\_____\___/   \___/| .__/ \___|_|  \__,_|\__|_|\___/|_| |_|___/ //
//                             |_|                                          //
//////////////////////////////////////////////////////////////////////////////

parameter ALU_OP_WIDTH = 6;

// Note: Certain bits in alu_opcode_e are referred to directly in the ALU:
//
// - Bit 2: Right shift?
//          Used for ALU_SLL, ALU_B_ROL,  ALU_B_ROR, ALU_B_BCLR,
//          ALU_B_BSET, ALU_B_BINV, ALU_SRL, ALU_SRA, ALU_B_BEXT.
// - Bit 3: Should B operand of adder be negated?
//          Used for ALU_ADD, ALU_SUB.
// - Bit 3: Are operands signed?
//          Used for ALU_SLT, ALU_SLTU, ALU_LT, ALU_GE, ALU_LTU, ALU_GEU,
//          ALU_B_MIN, ALU_B_MINU, ALU_B_MAX, ALU_B_MAXU
// - Bit 5: Is the operator a B extension operation?

typedef enum logic [ALU_OP_WIDTH-1:0]
{
 ALU_ADD      = 6'b000000, // funct3 = 000, negate_b(3)
 ALU_SUB      = 6'b001000, // funct3 = 000, negate_b(3)

 ALU_XOR      = 6'b000100, // funct3 = 100
 ALU_OR       = 6'b000110, // funct3 = 110
 ALU_AND      = 6'b000111, // funct3 = 111

 ALU_B_XNOR   = 6'b101100, // funct3 = 100, zbb
 ALU_B_ORN    = 6'b101110, // funct3 = 110, zbb
 ALU_B_ANDN   = 6'b101111, // funct3 = 111, zbb

 ALU_EQ       = 6'b010000, // funct3 = 000
 ALU_NE       = 6'b010001, // funct3 = 001
 ALU_SLT      = 6'b011010, // funct3 = 010, signed(3)
 ALU_SLTU     = 6'b010011, // funct3 = 011, unsigned(3)
 ALU_LT       = 6'b011100, // funct3 = 100, signed(3)
 ALU_GE       = 6'b011101, // funct3 = 101, signed(3)
 ALU_LTU      = 6'b010110, // funct3 = 110, unsigned(3)
 ALU_GEU      = 6'b010111, // funct3 = 111, unsigned(3)

 ALU_B_MIN    = 6'b111100, // funct3 = 100, signed(3), minimum(1)
 ALU_B_MINU   = 6'b110101, // funct3 = 101, unsigned(3), minimum(1)
 ALU_B_MAX    = 6'b111110, // funct3 = 110, signed(3), maximum(1)
 ALU_B_MAXU   = 6'b110111, // funct3 = 111, unsigned(3), maximum(1)

 ALU_SLL      = 6'b000001, // funct3 = 001, left(2)
 ALU_B_ROL    = 6'b100001, // funct3 = 001, left(2)
 ALU_B_ROR    = 6'b100101, // funct3 = 101, right(2)
 ALU_B_BCLR   = 6'b101001, // funct3 = 001, Zbs, left(2)
 ALU_B_BSET   = 6'b110001, // funct3 = 001, Zbs, left(2)
 ALU_B_BINV   = 6'b111001, // funct3 = 001, Zbs, left(2)
 ALU_SRL      = 6'b000101, // funct3 = 101, right(2)
 ALU_SRA      = 6'b001101, // funct3 = 101, right(2)
 ALU_B_BEXT   = 6'b111101, // funct3 = 101, Zbs, right(2)

 // B, Zba
 ALU_B_SH1ADD = 6'b100010, // funct3 = 010
 ALU_B_SH2ADD = 6'b100100, // funct3 = 100
 ALU_B_SH3ADD = 6'b100110, // funct3 = 110

 // B, Zbb
 ALU_B_CLZ    = 6'b100000, // (funct3 = 001)
 ALU_B_CTZ    = 6'b101000, // (funct3 = 001)
 ALU_B_CPOP   = 6'b100011, // (funct3 = 001)

 // The following three alu opcodes are shared between B and ZC.
 // Setting bit5==0 allows synth to optimize away most B logic
 // in the ALU in case only ZC_EXT is enabled.
 ALU_B_SEXT_B = 6'b010010,
 ALU_B_SEXT_H = 6'b010100,
 ALU_B_ZEXT_H = 6'b010101,

 ALU_B_REV8   = 6'b110100, // (funct3 = 101)
 ALU_B_ORC_B  = 6'b110010, // (funct3 = 101)

 // B, Zbc
 ALU_B_CLMUL  = 6'b100111, // (funct3 = 001)
 ALU_B_CLMULH = 6'b101011, // funct3 = 011
 ALU_B_CLMULR = 6'b101010  // funct3 = 010

 // Free encodings with bit 5 set (for B_EXT):
 // 6'b101101
 // 6'b110110
 // 6'b111010
 // 6'b111011
 // 6'b111111

} alu_opcode_e;

parameter MUL_OP_WIDTH = 1;

typedef enum logic [MUL_OP_WIDTH-1:0]
{
 MUL_M32 = 1'b0,
 MUL_H   = 1'b1
 } mul_opcode_e;

parameter DIV_OP_WIDTH = 2;

typedef enum logic [DIV_OP_WIDTH-1:0]
{

 DIV_DIVU= 2'b00,
 DIV_DIV = 2'b01,
 DIV_REMU= 2'b10,
 DIV_REM = 2'b11

 } div_opcode_e;

// FSM state encoding
typedef enum logic [1:0] { RESET, FUNCTIONAL, SLEEP, DEBUG_TAKEN} ctrl_state_e;

// Debug FSM state encoding
// State encoding done one-hot to ensure that debug_havereset_o, debug_running_o, debug_halted_o
// will come directly from flip-flops. *_INDEX and debug_state_e encoding must match

parameter HAVERESET_INDEX = 0;
parameter RUNNING_INDEX = 1;
parameter HALTED_INDEX = 2;

typedef enum logic [2:0] { HAVERESET = 3'b001, RUNNING = 3'b010, HALTED = 3'b100 } debug_state_e;

typedef enum logic {IDLE, BRANCH_WAIT} prefetch_state_e;

typedef enum logic [1:0] {MUL_ALBL, MUL_ALBH, MUL_AHBL, MUL_AHBH} mul_state_e;

// ALU divider FSM state encoding
typedef enum logic [1:0] {DIV_IDLE, DIV_DIVIDE, DIV_DUMMY, DIV_FINISH} div_state_e;


/////////////////////////////////////////////////////////
//    ____ ____    ____            _     _             //
//   / ___/ ___|  |  _ \ ___  __ _(_)___| |_ ___ _ __  //
//  | |   \___ \  | |_) / _ \/ _` | / __| __/ _ \ '__| //
//  | |___ ___) | |  _ <  __/ (_| | \__ \ ||  __/ |    //
//   \____|____/  |_| \_\___|\__, |_|___/\__\___|_|    //
//                           |___/                     //
/////////////////////////////////////////////////////////

// CSRs mnemonics
typedef enum logic[11:0] {

  ///////////////////////////////////////////////////////
  // User CSRs
  ///////////////////////////////////////////////////////

  CSR_JVT            = 12'h017,

  ///////////////////////////////////////////////////////
  // User Custom CSRs
  ///////////////////////////////////////////////////////

  // None


  ///////////////////////////////////////////////////////
  // Machine CSRs
  ///////////////////////////////////////////////////////

  // Machine trap setup
  CSR_MSTATUS        = 12'h300,
  CSR_MISA           = 12'h301,
  CSR_MIE            = 12'h304,
  CSR_MTVEC          = 12'h305,
  CSR_MTVT           = 12'h307,
  CSR_MSTATUSH       = 12'h310,

  // Performance counters
  CSR_MCOUNTINHIBIT  = 12'h320,
  CSR_MHPMEVENT3     = 12'h323,
  CSR_MHPMEVENT4     = 12'h324,
  CSR_MHPMEVENT5     = 12'h325,
  CSR_MHPMEVENT6     = 12'h326,
  CSR_MHPMEVENT7     = 12'h327,
  CSR_MHPMEVENT8     = 12'h328,
  CSR_MHPMEVENT9     = 12'h329,
  CSR_MHPMEVENT10    = 12'h32A,
  CSR_MHPMEVENT11    = 12'h32B,
  CSR_MHPMEVENT12    = 12'h32C,
  CSR_MHPMEVENT13    = 12'h32D,
  CSR_MHPMEVENT14    = 12'h32E,
  CSR_MHPMEVENT15    = 12'h32F,
  CSR_MHPMEVENT16    = 12'h330,
  CSR_MHPMEVENT17    = 12'h331,
  CSR_MHPMEVENT18    = 12'h332,
  CSR_MHPMEVENT19    = 12'h333,
  CSR_MHPMEVENT20    = 12'h334,
  CSR_MHPMEVENT21    = 12'h335,
  CSR_MHPMEVENT22    = 12'h336,
  CSR_MHPMEVENT23    = 12'h337,
  CSR_MHPMEVENT24    = 12'h338,
  CSR_MHPMEVENT25    = 12'h339,
  CSR_MHPMEVENT26    = 12'h33A,
  CSR_MHPMEVENT27    = 12'h33B,
  CSR_MHPMEVENT28    = 12'h33C,
  CSR_MHPMEVENT29    = 12'h33D,
  CSR_MHPMEVENT30    = 12'h33E,
  CSR_MHPMEVENT31    = 12'h33F,

  // Machine trap handling
  CSR_MSCRATCH       = 12'h340,
  CSR_MEPC           = 12'h341,
  CSR_MCAUSE         = 12'h342,
  CSR_MTVAL          = 12'h343,
  CSR_MIP            = 12'h344,
  CSR_MNXTI          = 12'h345,
  CSR_MINTTHRESH     = 12'h347,
  CSR_MSCRATCHCSWL   = 12'h349,
  CSR_MCLICBASE      = 12'h34A,

  // Trigger
  CSR_TSELECT        = 12'h7A0,
  CSR_TDATA1         = 12'h7A1,
  CSR_TDATA2         = 12'h7A2,
  CSR_TINFO          = 12'h7A4,

  // Debug/trace
  CSR_DCSR           = 12'h7B0,
  CSR_DPC            = 12'h7B1,

  // Debug
  CSR_DSCRATCH0      = 12'h7B2,
  CSR_DSCRATCH1      = 12'h7B3,

  // Hardware Performance Monitor
  CSR_MCYCLE         = 12'hB00,
  CSR_MINSTRET       = 12'hB02,
  CSR_MHPMCOUNTER3   = 12'hB03,
  CSR_MHPMCOUNTER4   = 12'hB04,
  CSR_MHPMCOUNTER5   = 12'hB05,
  CSR_MHPMCOUNTER6   = 12'hB06,
  CSR_MHPMCOUNTER7   = 12'hB07,
  CSR_MHPMCOUNTER8   = 12'hB08,
  CSR_MHPMCOUNTER9   = 12'hB09,
  CSR_MHPMCOUNTER10  = 12'hB0A,
  CSR_MHPMCOUNTER11  = 12'hB0B,
  CSR_MHPMCOUNTER12  = 12'hB0C,
  CSR_MHPMCOUNTER13  = 12'hB0D,
  CSR_MHPMCOUNTER14  = 12'hB0E,
  CSR_MHPMCOUNTER15  = 12'hB0F,
  CSR_MHPMCOUNTER16  = 12'hB10,
  CSR_MHPMCOUNTER17  = 12'hB11,
  CSR_MHPMCOUNTER18  = 12'hB12,
  CSR_MHPMCOUNTER19  = 12'hB13,
  CSR_MHPMCOUNTER20  = 12'hB14,
  CSR_MHPMCOUNTER21  = 12'hB15,
  CSR_MHPMCOUNTER22  = 12'hB16,
  CSR_MHPMCOUNTER23  = 12'hB17,
  CSR_MHPMCOUNTER24  = 12'hB18,
  CSR_MHPMCOUNTER25  = 12'hB19,
  CSR_MHPMCOUNTER26  = 12'hB1A,
  CSR_MHPMCOUNTER27  = 12'hB1B,
  CSR_MHPMCOUNTER28  = 12'hB1C,
  CSR_MHPMCOUNTER29  = 12'hB1D,
  CSR_MHPMCOUNTER30  = 12'hB1E,
  CSR_MHPMCOUNTER31  = 12'hB1F,

  CSR_MCYCLEH        = 12'hB80,
  CSR_MINSTRETH      = 12'hB82,
  CSR_MHPMCOUNTER3H  = 12'hB83,
  CSR_MHPMCOUNTER4H  = 12'hB84,
  CSR_MHPMCOUNTER5H  = 12'hB85,
  CSR_MHPMCOUNTER6H  = 12'hB86,
  CSR_MHPMCOUNTER7H  = 12'hB87,
  CSR_MHPMCOUNTER8H  = 12'hB88,
  CSR_MHPMCOUNTER9H  = 12'hB89,
  CSR_MHPMCOUNTER10H = 12'hB8A,
  CSR_MHPMCOUNTER11H = 12'hB8B,
  CSR_MHPMCOUNTER12H = 12'hB8C,
  CSR_MHPMCOUNTER13H = 12'hB8D,
  CSR_MHPMCOUNTER14H = 12'hB8E,
  CSR_MHPMCOUNTER15H = 12'hB8F,
  CSR_MHPMCOUNTER16H = 12'hB90,
  CSR_MHPMCOUNTER17H = 12'hB91,
  CSR_MHPMCOUNTER18H = 12'hB92,
  CSR_MHPMCOUNTER19H = 12'hB93,
  CSR_MHPMCOUNTER20H = 12'hB94,
  CSR_MHPMCOUNTER21H = 12'hB95,
  CSR_MHPMCOUNTER22H = 12'hB96,
  CSR_MHPMCOUNTER23H = 12'hB97,
  CSR_MHPMCOUNTER24H = 12'hB98,
  CSR_MHPMCOUNTER25H = 12'hB99,
  CSR_MHPMCOUNTER26H = 12'hB9A,
  CSR_MHPMCOUNTER27H = 12'hB9B,
  CSR_MHPMCOUNTER28H = 12'hB9C,
  CSR_MHPMCOUNTER29H = 12'hB9D,
  CSR_MHPMCOUNTER30H = 12'hB9E,
  CSR_MHPMCOUNTER31H = 12'hB9F,

  CSR_CYCLE          = 12'hC00,
  CSR_TIME           = 12'hC01,
  CSR_INSTRET        = 12'hC02,
  CSR_HPMCOUNTER3    = 12'hC03,
  CSR_HPMCOUNTER4    = 12'hC04,
  CSR_HPMCOUNTER5    = 12'hC05,
  CSR_HPMCOUNTER6    = 12'hC06,
  CSR_HPMCOUNTER7    = 12'hC07,
  CSR_HPMCOUNTER8    = 12'hC08,
  CSR_HPMCOUNTER9    = 12'hC09,
  CSR_HPMCOUNTER10   = 12'hC0A,
  CSR_HPMCOUNTER11   = 12'hC0B,
  CSR_HPMCOUNTER12   = 12'hC0C,
  CSR_HPMCOUNTER13   = 12'hC0D,
  CSR_HPMCOUNTER14   = 12'hC0E,
  CSR_HPMCOUNTER15   = 12'hC0F,
  CSR_HPMCOUNTER16   = 12'hC10,
  CSR_HPMCOUNTER17   = 12'hC11,
  CSR_HPMCOUNTER18   = 12'hC12,
  CSR_HPMCOUNTER19   = 12'hC13,
  CSR_HPMCOUNTER20   = 12'hC14,
  CSR_HPMCOUNTER21   = 12'hC15,
  CSR_HPMCOUNTER22   = 12'hC16,
  CSR_HPMCOUNTER23   = 12'hC17,
  CSR_HPMCOUNTER24   = 12'hC18,
  CSR_HPMCOUNTER25   = 12'hC19,
  CSR_HPMCOUNTER26   = 12'hC1A,
  CSR_HPMCOUNTER27   = 12'hC1B,
  CSR_HPMCOUNTER28   = 12'hC1C,
  CSR_HPMCOUNTER29   = 12'hC1D,
  CSR_HPMCOUNTER30   = 12'hC1E,
  CSR_HPMCOUNTER31   = 12'hC1F,

  CSR_CYCLEH         = 12'hC80,
  CSR_TIMEH          = 12'hC81,
  CSR_INSTRETH       = 12'hC82,
  CSR_HPMCOUNTER3H   = 12'hC83,
  CSR_HPMCOUNTER4H   = 12'hC84,
  CSR_HPMCOUNTER5H   = 12'hC85,
  CSR_HPMCOUNTER6H   = 12'hC86,
  CSR_HPMCOUNTER7H   = 12'hC87,
  CSR_HPMCOUNTER8H   = 12'hC88,
  CSR_HPMCOUNTER9H   = 12'hC89,
  CSR_HPMCOUNTER10H  = 12'hC8A,
  CSR_HPMCOUNTER11H  = 12'hC8B,
  CSR_HPMCOUNTER12H  = 12'hC8C,
  CSR_HPMCOUNTER13H  = 12'hC8D,
  CSR_HPMCOUNTER14H  = 12'hC8E,
  CSR_HPMCOUNTER15H  = 12'hC8F,
  CSR_HPMCOUNTER16H  = 12'hC90,
  CSR_HPMCOUNTER17H  = 12'hC91,
  CSR_HPMCOUNTER18H  = 12'hC92,
  CSR_HPMCOUNTER19H  = 12'hC93,
  CSR_HPMCOUNTER20H  = 12'hC94,
  CSR_HPMCOUNTER21H  = 12'hC95,
  CSR_HPMCOUNTER22H  = 12'hC96,
  CSR_HPMCOUNTER23H  = 12'hC97,
  CSR_HPMCOUNTER24H  = 12'hC98,
  CSR_HPMCOUNTER25H  = 12'hC99,
  CSR_HPMCOUNTER26H  = 12'hC9A,
  CSR_HPMCOUNTER27H  = 12'hC9B,
  CSR_HPMCOUNTER28H  = 12'hC9C,
  CSR_HPMCOUNTER29H  = 12'hC9D,
  CSR_HPMCOUNTER30H  = 12'hC9E,
  CSR_HPMCOUNTER31H  = 12'hC9F,

  // Machine information
  CSR_MVENDORID      = 12'hF11,
  CSR_MARCHID        = 12'hF12,
  CSR_MIMPID         = 12'hF13,
  CSR_MHARTID        = 12'hF14,
  CSR_MCONFIGPTR     = 12'hF15,
  CSR_MINTSTATUS     = 12'hFB1

} csr_num_e;

// CSR Bit Implementation Masks
// A mask bit of '1' means a flipflop is implemented.
parameter CSR_JVT_MASK          = 32'hFFFFFFC0;
parameter CSR_MEPC_MASK         = 32'hFFFFFFFE;
parameter CSR_DPC_MASK          = 32'hFFFFFFFE;
parameter CSR_MSCRATCH_MASK     = 32'hFFFFFFFF;
parameter CSR_DCSR_MASK         = 32'b0000_0000_0000_0000_1000_1101_1100_0100; // NMI bit taken from ctrl_fsm
parameter CSR_DSCRATCH0_MASK    = 32'hFFFFFFFF;
parameter CSR_DSCRATCH1_MASK    = 32'hFFFFFFFF;
parameter CSR_MSTATUS_MASK      = 32'b0000_0000_0000_0000_0000_0000_1000_1000;
parameter CSR_MINTSTATUS_MASK   = 32'hFF000000;
parameter CSR_MINTTHRESH_MASK   = 32'h000000FF;
parameter CSR_CLIC_MCAUSE_MASK  = 32'b1100_1000_1111_1111_0000_0111_1111_1111;
parameter CSR_BASIC_MCAUSE_MASK = 32'b1000_0000_0000_0000_0000_0111_1111_1111;
parameter CSR_CLIC_MTVEC_MASK   = 32'hFFFFFF80;
parameter CSR_BASIC_MTVEC_MASK  = 32'hFFFFFF81;


// CSR operations

parameter CSR_OP_WIDTH = 2;

typedef enum logic [CSR_OP_WIDTH-1:0]
{
 CSR_OP_READ  = 2'b00,
 CSR_OP_WRITE = 2'b01,
 CSR_OP_SET   = 2'b10,
 CSR_OP_CLEAR = 2'b11
} csr_opcode_e;

// CSR interrupt pending/enable bits
parameter int unsigned CSR_MSIX_BIT      = 3;
parameter int unsigned CSR_MTIX_BIT      = 7;
parameter int unsigned CSR_MEIX_BIT      = 11;
parameter int unsigned CSR_MFIX_BIT_LOW  = 16;
parameter int unsigned CSR_MFIX_BIT_HIGH = 31;

// Privileged mode
typedef enum logic[1:0] {
  PRIV_LVL_M = 2'b11,
  PRIV_LVL_H = 2'b10,
  PRIV_LVL_S = 2'b01,
  PRIV_LVL_U = 2'b00
} privlvl_t;

parameter privlvl_t PRIV_LVL_LOWEST = PRIV_LVL_M;

// Struct used for setting privilege level
typedef struct packed {
  logic        priv_lvl_set;
  privlvl_t    priv_lvl;
} privlvlctrl_t;

// Machine Vendor ID - OpenHW JEDEC ID is '2 decimal (bank 13)'
parameter MVENDORID_OFFSET = 7'h2;      // Final byte without parity bit
parameter MVENDORID_BANK = 25'hC;       // Number of continuation codes

// Machine Architecture ID (https://github.com/riscv/riscv-isa-manual/blob/master/marchid.md)
parameter MARCHID = 32'h14;

// MachineImplementation ID
parameter MIMPID_MAJOR = 4'h0;  // Major ID
parameter MIMPID_MINOR = 4'h0;  // Minor ID

parameter MTVEC_MODE_BASIC  = 2'b01;
parameter MTVEC_MODE_CLIC   = 2'b11;
parameter NUM_HPM_EVENTS    =   16;

parameter MSTATUS_MIE_BIT      = 3;
parameter MSTATUS_MPIE_BIT     = 7;
parameter MSTATUS_MPP_BIT_LOW  = 11;
parameter MSTATUS_MPP_BIT_HIGH = 12;
parameter MSTATUS_MPRV_BIT     = 17;

parameter MCAUSE_MPIE_BIT      = 27;
parameter MCAUSE_MPP_BIT_LOW   = 28;
parameter MCAUSE_MPP_BIT_HIGH  = 29;

parameter MTVEC_MODE_BIT_HIGH  = 1;
parameter MTVEC_MODE_BIT_LOW   = 0;

parameter DCSR_EBREAKU_BIT     = 12;
parameter DCSR_PRV_BIT_HIGH    = 1;
parameter DCSR_PRV_BIT_LOW     = 0;


// misa
parameter logic [1:0] MXL = 2'd1; // M-XLEN: XLEN in M-Mode for RV32

// Types for packed struct CSRs

typedef struct packed {
  logic [31:6] base;
  logic [5: 0] mode;
} jvt_t;

parameter JVT_ADDR_WIDTH = 26;

typedef struct packed {
  logic         sd;     // State dirty
  logic [30:23] zero3;  // Hardwired zero
  logic         tsr;    // Hardwired zero
  logic         tw;     // Hardwired zero
  logic         tvm;    // Hardwired zero
  logic         mxr;    // Hardwired zero
  logic         sum;    // Hardwired zero
  logic         mprv;   // Hardwired zero
  logic [16:15] xs;     // Other extension context
  logic [14:13] fs;     // FPU extension context status
  logic [12:11] mpp;    // Hardwired to 2'b11
  logic [10:9]  vs;     // Vector extension context status
  logic         spp;    // Hardwired zero
  logic         mpie;
  logic         ube;    // Hardwired zero
  logic         spie;   // Hardwired zero
  logic         zero2;  // Reserved, hardwired to zero.
  logic         mie;
  logic         zero1;  // Reserved, hardwired to zero.
  logic         sie;    // Hardwired to zero
  logic         zero0;  // Reserved, hardwired zero
} mstatus_t;

typedef struct packed {
  logic [31:6] zero1;
  logic mbe;
  logic sbe;
  logic [3:0] zero0;
} mstatush_t;

// Debug Cause
parameter DBG_CAUSE_NONE       = 3'h0;
parameter DBG_CAUSE_EBREAK     = 3'h1;
parameter DBG_CAUSE_TRIGGER    = 3'h2;
parameter DBG_CAUSE_HALTREQ    = 3'h3;
parameter DBG_CAUSE_STEP       = 3'h4;
parameter DBG_CAUSE_RSTHALTREQ = 3'h5;

// Constants for the dcsr.xdebugver fields
typedef enum logic[3:0] {
   XDEBUGVER_NO     = 4'd0, // no external debug support
   XDEBUGVER_STD    = 4'd4, // external debug according to RISC-V debug spec
   XDEBUGVER_NONSTD = 4'd15 // debug not conforming to RISC-V debug spec
} x_debug_ver_e;

// Trigger types
typedef enum logic [3:0] {
  TTYPE_MCONTROL  = 4'h2,
  TTYPE_ETRIGGER  = 4'h5,
  TTYPE_MCONTROL6 = 4'h6,
  TTYPE_DISABLED  = 4'hF
} trigger_type_e;

typedef struct packed {
    logic [31:28] xdebugver;
    logic [27:18] zero2;
    logic         ebreakvs; // Hardwired to zero
    logic         ebreakvu; // Hardwired to zero
    logic         ebreakm;
    logic         zero1;
    logic         ebreaks;
    logic         ebreaku;
    logic         stepie;
    logic         stopcount;
    logic         stoptime;
    logic [8:6]   cause;
    logic         v;        // Hardwired to zero
    logic         mprven;
    logic         nmip;
    logic         step;
    privlvl_t     prv;
} dcsr_t;

typedef struct packed {
  logic           irq;
  logic           minhv;           // CLIC only
  logic [29:28]   mpp;             // CLIC only, same as mstatus.mpp
  logic           mpie;            // CLIC only, same as mstatus.mpie
  logic [26:24]   zero1;           // Reserved, hardwired to zero.
  logic [23:16]   mpil;            // CLIC only. Previous interrupt level
  logic [15:11]   zero0;           // Reserved, hardwired to zero.
  logic [10: 0]   exception_code;  // Exception cause
} mcause_t;

typedef struct packed {
  logic [31:7] addr;
  logic        zero0;
  logic [ 5:2] submode;
  logic [ 1:0] mode;
} mtvec_t;

typedef struct packed {
  logic [31:6] addr;
  logic [ 5:0] zero0;
} mtvt_t;

typedef struct packed {
  logic [31:24] mil;
  logic [23:16] zero0;
  logic [15: 8] sil;
  logic [ 7: 0] uil;
} mintstatus_t;


parameter dcsr_t DCSR_RESET_VAL = '{
  xdebugver:  XDEBUGVER_STD,
  stopcount:  1'b1,
  cause:      DBG_CAUSE_NONE,
  mprven:     1'b1,
  prv:        PRIV_LVL_M,
  default:    '0};

parameter mtvec_t MTVEC_BASIC_RESET_VAL = '{
  addr: 'd0,
  zero0: 'd0,
  submode: 'd0,
  mode:  MTVEC_MODE_BASIC};

parameter mtvec_t MTVEC_CLIC_RESET_VAL = '{
  addr: 'd0,
  zero0: 'd0,
  submode: 'd0,
  mode:  MTVEC_MODE_CLIC};

parameter mtvt_t MTVT_RESET_VAL = '{
  addr:  '0,
  zero0: '0};

parameter mintstatus_t MINTSTATUS_RESET_VAL = '{
  mil:   '0,
  zero0: '0,
  sil:   '0,
  uil:   '0};

parameter mstatus_t MSTATUS_RESET_VAL = '{
  tw      : 1'b0,
  mprv    : 1'b0,
  zero3   : 'b0,
  mpp     : PRIV_LVL_M,
  zero2   : 'b0,
  mpie    : 1'b0,
  zero1   : 'b0,
  mie     : 1'b0,
  zero0   : 'b0,
  default : 'b0};

parameter mcause_t MCAUSE_CLIC_RESET_VAL = '{
  mpp     : PRIV_LVL_M,
  default: 'b0};

parameter mcause_t MCAUSE_BASIC_RESET_VAL = '{
    default: 'b0};

parameter JVT_RESET_VAL                = 32'd0;
parameter MSCRATCH_RESET_VAL           = 32'd0;
parameter MEPC_RESET_VAL               = 32'd0;
parameter DPC_RESET_VAL                = 32'd0;
parameter DSCRATCH0_RESET_VAL          = 32'd0;
parameter DSCRATCH1_RESET_VAL          = 32'd0;
parameter MINTTHRESH_RESET_VAL         = 32'd0;
parameter MIE_BASIC_RESET_VAL          = 32'd0;

parameter logic [31:0] TDATA1_RST_VAL = {
  TTYPE_MCONTROL,        // type    : address/data match
  1'b1,                  // dmode   : access from D mode only
  6'b000000,             // maskmax  : hardwired to zero
  1'b0,                  // hit     : hardwired to zero
  1'b0,                  // select  : hardwired to zero, only address matching
  1'b0,                  // timing  : hardwired to zero, only 'before' timing
  2'b00,                 // sizelo  : hardwired to zero, match any size
  4'b0001,               // action  : enter debug on match
  1'b0,                  // chain   : hardwired to zero
  4'b0000,               // match, WARL(0,2,3) 10:7
  1'b0,                  // m       : match in machine mode
  1'b0,                  //         : hardwired to zero
  1'b0,                  // s       : hardwired to zer0
  1'b0,                  // zero, U 3
  1'b0,                  // EXECUTE 2
  1'b0,                  // STORE 1
  1'b0};                 // LOAD 0

  // Bit position parameters for MCONTROL and MCONTROL6
  parameter MCONTROL_6_UNCERTAIN   = 26;
  parameter MCONTROL_6_HIT1        = 25;
  parameter MCONTROL_6_HIT0        = 22;
  parameter MCONTROL2_6_MATCH_HIGH = 10;
  parameter MCONTROL2_6_MATCH_LOW  = 7;
  parameter MCONTROL2_6_M          = 6;
  parameter MCONTROL_6_UNCERTAINEN = 5;
  parameter MCONTROL2_6_U          = 3;
  parameter MCONTROL2_6_EXECUTE    = 2;
  parameter MCONTROL2_6_STORE      = 1;
  parameter MCONTROL2_6_LOAD       = 0;


  parameter ETRIGGER_M = 9;
  parameter ETRIGGER_U = 6;

  // Bit position parameters for trigger type within tdata1
  parameter TDATA1_TTYPE_HIGH = 31;
  parameter TDATA1_TTYPE_LOW  = 28;

  // Struct for carrying read/write hazard signals
  typedef struct packed {
    logic impl_re_ex; // Implicit CSR read in EX
    logic impl_wr_ex; // Implicit CSR write in EX (will perform write in WB)
    logic expl_re_ex; // Conservative, using flopped instr_valid
    logic expl_we_wb; // Conservative, using flopped instr_valid
    csr_num_e expl_raddr_ex;
    csr_num_e expl_waddr_wb;
  } csr_hz_t;


///////////////////////////////////////////////
//   ___ ____    ____  _                     //
//  |_ _|  _ \  / ___|| |_ __ _  __ _  ___   //
//   | || | | | \___ \| __/ _` |/ _` |/ _ \  //
//   | || |_| |  ___) | || (_| | (_| |  __/  //
//  |___|____/  |____/ \__\__,_|\__, |\___|  //
//                              |___/        //
///////////////////////////////////////////////

// Register file read/write ports
parameter REGFILE_NUM_WRITE_PORTS = 1;

// Address width of register file
parameter REGFILE_ADDR_WIDTH = 5;

// Data width of register file
parameter REGFILE_DATA_WIDTH = 32;

// Word width of register file memory
parameter REGFILE_WORD_WIDTH = REGFILE_DATA_WIDTH;

// Register file address type
typedef logic [REGFILE_ADDR_WIDTH-1:0] rf_addr_t;

// Register file data type
typedef logic [REGFILE_DATA_WIDTH-1:0] rf_data_t;

// forwarding operand mux
typedef enum logic[1:0] {
                         SEL_REGFILE = 2'b00,
                         SEL_FW_EX   = 2'b01,
                         SEL_FW_WB   = 2'b10
                         } op_fw_mux_e;

typedef enum logic {
                         SELJ_REGFILE = 1'b0,
                         SELJ_FW_WB   = 1'b1
                         } jalr_fw_mux_e;

// Operand a selection
typedef enum logic[1:0] {
                         OP_A_REGA_OR_FWD = 2'b00,
                         OP_A_CURRPC      = 2'b01,
                         OP_A_IMM         = 2'b10,
                         OP_A_NONE        = 2'b11
                         } alu_op_a_mux_e;


// Immediate a selection
typedef enum logic {
                    IMMA_Z      = 1'b0,
                    IMMA_ZERO   = 1'b1
                    } imm_a_mux_e;


// Operand b selection
typedef enum logic[1:0] {
                    OP_B_REGB_OR_FWD = 2'b00,
                    OP_B_IMM         = 2'b01,
                    OP_B_NONE        = 2'b10
                    } alu_op_b_mux_e;

// Immediate b selection
typedef enum logic[1:0] {
                         IMMB_I      = 2'b00,
                         IMMB_S      = 2'b01,
                         IMMB_U      = 2'b10,
                         IMMB_PCINCR = 2'b11
                         } imm_b_mux_e;

// Operand c selection
typedef enum logic[1:0] {
                         OP_C_REGB_OR_FWD = 2'b00,
                         OP_C_BCH         = 2'b01,
                         OP_C_NONE        = 2'b10
                         } op_c_mux_e;

// Control transfer (branch/jump) target mux
typedef enum logic[1:0] {
                         CT_TBLJMP = 2'b00,
                         CT_JAL    = 2'b01,
                         CT_JALR   = 2'b10,
                         CT_BCH    = 2'b11
                         } bch_jmp_mux_e;

// Atomic operations
parameter AMO_LR   = 5'b00010;
parameter AMO_SC   = 5'b00011;
parameter AMO_SWAP = 5'b00001;
parameter AMO_ADD  = 5'b00000;
parameter AMO_XOR  = 5'b00100;
parameter AMO_AND  = 5'b01100;
parameter AMO_OR   = 5'b01000;
parameter AMO_MIN  = 5'b10000;
parameter AMO_MAX  = 5'b10100;
parameter AMO_MINU = 5'b11000;
parameter AMO_MAXU = 5'b11100;

// Decoder control signals
typedef struct packed {
  logic                              alu_en;
  logic                              alu_bch;
  logic                              alu_jmp;
  logic                              alu_jmpr;
  alu_opcode_e                       alu_operator;
  alu_op_a_mux_e                     alu_op_a_mux_sel;
  alu_op_b_mux_e                     alu_op_b_mux_sel;
  op_c_mux_e                         op_c_mux_sel;
  imm_a_mux_e                        imm_a_mux_sel;
  imm_b_mux_e                        imm_b_mux_sel;
  bch_jmp_mux_e                      bch_jmp_mux_sel;
  logic                              mul_en;
  mul_opcode_e                       mul_operator;
  logic [1:0]                        mul_signed_mode;
  logic                              div_en;
  div_opcode_e                       div_operator;
  logic [1:0]                        rf_re; // Core internals will never use more than two read ports.
  logic                              rf_we;
  logic                              csr_en;
  csr_opcode_e                       csr_op;
  logic                              lsu_en;
  logic                              lsu_we;
  logic [1:0]                        lsu_size;
  logic                              lsu_sext;
  logic [5:0]                        lsu_atop;
  logic                              sys_en;
  logic                              illegal_insn;
  logic                              sys_dret_insn;
  logic                              sys_ebrk_insn;
  logic                              sys_ecall_insn;
  logic                              sys_fence_insn;
  logic                              sys_fencei_insn;
  logic                              sys_mret_insn;
  logic                              sys_wfi_insn;
  logic                              sys_wfe_insn;
} decoder_ctrl_t;

  parameter decoder_ctrl_t DECODER_CTRL_ILLEGAL_INSN =  '{
                                                          alu_en                       : 1'b0,
                                                          alu_bch                      : 1'b0,
                                                          alu_jmp                      : 1'b0,
                                                          alu_jmpr                     : 1'b0,
                                                          alu_operator                 : ALU_SLTU,
                                                          alu_op_a_mux_sel             : OP_A_NONE,
                                                          alu_op_b_mux_sel             : OP_B_NONE,
                                                          op_c_mux_sel                 : OP_C_NONE,
                                                          imm_a_mux_sel                : IMMA_ZERO,
                                                          imm_b_mux_sel                : IMMB_I,
                                                          bch_jmp_mux_sel              : CT_JAL,
                                                          mul_en                       : 1'b0,
                                                          mul_operator                 : MUL_M32,
                                                          mul_signed_mode              : 2'b00,
                                                          div_en                       : 1'b0,
                                                          div_operator                 : DIV_DIVU,
                                                          rf_re                        : 2'b00,
                                                          rf_we                        : 1'b0,
                                                          csr_en                       : 1'b0,
                                                          csr_op                       : CSR_OP_READ,
                                                          lsu_en                       : 1'b0,
                                                          lsu_we                       : 1'b0,
                                                          lsu_size                     : 2'b00,
                                                          lsu_sext                     : 1'b0,
                                                          lsu_atop                     : 6'b000000,
                                                          sys_en                       : 1'b0,
                                                          illegal_insn                 : 1'b1,
                                                          sys_dret_insn                : 1'b0,
                                                          sys_ebrk_insn                : 1'b0,
                                                          sys_ecall_insn               : 1'b0,
                                                          sys_fence_insn               : 1'b0,
                                                          sys_fencei_insn              : 1'b0,
                                                          sys_mret_insn                : 1'b0,
                                                          sys_wfi_insn                 : 1'b0,
                                                          sys_wfe_insn                 : 1'b0
                                                          };

///////////////////////////////////////////////
//   ___ _____   ____  _                     //
//  |_ _|  ___| / ___|| |_ __ _  __ _  ___   //
//   | || |_    \___ \| __/ _` |/ _` |/ _ \  //
//   | ||  _|    ___) | || (_| | (_| |  __/  //
//  |___|_|     |____/ \__\__,_|\__, |\___|  //
//                              |___/        //
///////////////////////////////////////////////

// PC mux selector defines
typedef enum logic[3:0] {
  PC_BOOT       = 4'b0000,
  PC_MRET       = 4'b0001,
  PC_DRET       = 4'b0010,
  PC_JUMP       = 4'b0100,
  PC_BRANCH     = 4'b0101,
  PC_WB_PLUS4   = 4'b0110,
  PC_TRAP_EXC   = 4'b1000,
  PC_TRAP_IRQ   = 4'b1001,
  PC_TRAP_DBD   = 4'b1010,
  PC_TRAP_DBE   = 4'b1011,
  PC_TRAP_NMI   = 4'b1100,
  PC_TRAP_CLICV = 4'b1101,
  PC_POINTER    = 4'b1110,
  PC_TBLJUMP    = 4'b1111
} pc_mux_e;

// Exception Cause
parameter EXC_CAUSE_INSTR_FAULT      = 11'h01;
parameter EXC_CAUSE_ILLEGAL_INSN     = 11'h02;
parameter EXC_CAUSE_BREAKPOINT       = 11'h03;
parameter EXC_CAUSE_LOAD_FAULT       = 11'h05;
parameter EXC_CAUSE_STORE_FAULT      = 11'h07;
parameter EXC_CAUSE_ECALL_MMODE      = 11'h0B;
parameter EXC_CAUSE_INSTR_BUS_FAULT  = 11'h18;

parameter INT_CAUSE_LSU_LOAD_FAULT  = 11'h400;
parameter INT_CAUSE_LSU_STORE_FAULT = 11'h401;

// Interrupt mask
parameter IRQ_MASK = 32'hFFFF0888;

// NMI offset
parameter NMI_MTVEC_INDEX = 5'd15;

////////////////////////////
//                        //
//    /\/\    / _ \/\ /\  //
//   /    \  / /_)/ / \ \ //
//  / /\/\ \/ ___/\ \_/ / //
//  \/    \/\/     \___/  //
//                        //
////////////////////////////

// PMA region config
// word_addr_low/high: Address boundaries, containing word aligned 34-bit address (address[33:2])
// main:               Region is defined as main memory (as opposed to I/O memory)
// bufferable:         Transfers in this region are bufferable
// cacheable:          Transfers in this region are cacheable
// atomic:             This region supports atomic transfers
typedef struct packed {
  logic [31:0] word_addr_low;
  logic [31:0] word_addr_high;
  logic        main;
  logic        bufferable;
  logic        cacheable;
  logic        atomic;
} pma_cfg_t;

// Default attribution when PMA is not configured (PMA_NUM_REGIONS=0) (Address is don't care)
parameter pma_cfg_t NO_PMA_R_DEFAULT = '{word_addr_low   : 0,
                                         word_addr_high  : 0,
                                         main            : 1'b1,
                                         bufferable      : 1'b0,
                                         cacheable       : 1'b0,
                                         atomic          : 1'b1};

// Default attribution when PMA is configured (Address is don't care)
parameter pma_cfg_t PMA_R_DEFAULT = '{word_addr_low   : 0,
                                      word_addr_high  : 0,
                                      main            : 1'b0,
                                      bufferable      : 1'b0,
                                      cacheable       : 1'b0,
                                      atomic          : 1'b0};

// MPU status. Used for PMA
typedef enum logic [1:0] {
                          MPU_OK            = 2'h0,
                          MPU_RE_FAULT      = 2'h1,
                          MPU_WR_FAULT      = 2'h2
                          } mpu_status_e;


typedef enum logic [2:0] {MPU_IDLE, MPU_RE_ERR_RESP, MPU_RE_ERR_WAIT, MPU_WR_ERR_RESP, MPU_WR_ERR_WAIT} mpu_state_e;

// ALIGN status. Used when checking alignment for atomics
typedef enum logic [1:0] {
                          ALIGN_OK         = 2'h0,
                          ALIGN_RE_ERR     = 2'h1,
                          ALIGN_WR_ERR     = 2'h2
                          } align_status_e;

typedef enum logic [2:0] {ALIGN_IDLE, ALIGN_WR_ERR_RESP, ALIGN_WR_ERR_WAIT, ALIGN_RE_ERR_RESP, ALIGN_RE_ERR_WAIT} align_state_e;

// WPT state machine
typedef enum logic [1:0] {WPT_IDLE, WPT_MATCH_WAIT, WPT_MATCH_RESP} wpt_state_e;

// OBI bus and internal data types

parameter INSTR_ADDR_WIDTH = 32;
parameter INSTR_DATA_WIDTH = 32;
parameter DATA_ADDR_WIDTH = 32;
parameter DATA_DATA_WIDTH = 32;

typedef struct packed {
  logic        req;
} obi_req_t;

typedef struct packed {
  logic        gnt;
} obi_gnt_t;

typedef struct packed {
  logic        rvalid;
} obi_rvalid_t;

typedef struct packed {
  logic [INSTR_ADDR_WIDTH-1:0] addr;
  logic [1:0]                  memtype;
  logic [2:0]                  prot;
  logic                        dbg;
} obi_inst_req_t;

typedef struct packed {
  logic [INSTR_DATA_WIDTH-1:0] rdata;
  logic                        err;
} obi_inst_resp_t;

typedef struct packed {
  logic [DATA_ADDR_WIDTH-1:0]     addr;
  logic [5:0]                     atop;
  logic                           we;
  logic [(DATA_DATA_WIDTH/8)-1:0] be;
  logic [DATA_DATA_WIDTH-1:0]     wdata;
  logic [1:0]                     memtype;
  logic [2:0]                     prot;
  logic                           dbg;
} obi_data_req_t;

typedef struct packed {
  logic [DATA_DATA_WIDTH-1:0] rdata;
  logic [1:0]                 err; // bit0: Error from bus, bit1: 0 for load, 1 for store
  logic                       exokay;
} obi_data_resp_t;

// Data/instruction transfer bundeled with MPU status
typedef struct packed {
 obi_inst_resp_t             bus_resp;
 mpu_status_e                mpu_status;
} inst_resp_t;

// Reset value for the inst_resp_t type
parameter inst_resp_t INST_RESP_RESET_VAL = '{
  // Setting rdata[1:0] to 2'b11 to easily assert that all
  // instructions in ID are uncompressed
  bus_resp     : '{rdata: 32'h3, err: 1'b0},
  mpu_status   : MPU_OK
};

// Reset value for the obi_inst_req_t type
parameter obi_inst_req_t OBI_INST_REQ_RESET_VAL = '{
  addr    : 'h0,
  memtype : 'h0,
  prot    : {PRIV_LVL_M, 1'b0},
  dbg     : 1'b0
};

// Data transfer bundeled with MPU status and watchpoint trigger match
typedef struct packed {
  obi_data_resp_t             bus_resp;
  mpu_status_e                mpu_status;
  logic [31:0]                wpt_match;
  align_status_e              align_status;
} data_resp_t;

// LSU transaction
typedef struct packed {
  logic [DATA_ADDR_WIDTH-1:0]     addr;
  logic [1:0]                     size;
  logic [5:0]                     atop;
  logic                           we;
  logic                           sext;
  logic [DATA_DATA_WIDTH-1:0]     wdata;
  logic [1:0]                     mode;
  logic                           dbg;
} trans_req_t;

// Response type for tracking bufferable and load/store in lsu response filter
typedef struct packed {
  logic bufferable;
  logic store;
} outstanding_t;

// Instruction meta data
typedef struct packed
{
  logic        compressed;
  logic        clic_ptr;   // "True" CLIC pointer due to taking a CLIC SHV interrupt
  logic        mret_ptr;   // CLIC pointer due to an mret restarting pointer fetch
  logic        tbljmp;
  logic        pushpop;    // Operation is part of a push/pop sequence.
} instr_meta_t;

typedef struct packed
{
  logic        bus_err;
  logic        store;
} lsu_err_wb_t;

// Struct for carrying eXtension interface information
typedef struct packed
{
  logic        exception;       // Can offloaded ins cause an exception?
  logic        loadstore; // Is offloaded ins a load or store?
  logic        dualwrite; // Will oflfoaded ins cause a dual writeback?
  logic [31:0] id;        // ID of offloaded ins
  logic        accepted;  // Was the offloaded instruction accepted or not?
} xif_meta_t;

// Struct for signaling if there is an atomic LSU instruction, and of which type
typedef enum logic [1:0]
{
  AT_NONE   = 2'b00,  // There is no atomic instruction
  AT_LR     = 2'b01,  // Atomic of LR.W type
  AT_SC     = 2'b10,  // Atomic of SC.W type
  AT_AMO    = 2'b11   // Atomic of AMO type
} lsu_atomic_e;

// IF/ID pipeline
typedef struct packed {
  logic        instr_valid;
  inst_resp_t  instr;
  instr_meta_t instr_meta;
  logic [31:0] pc;
  logic [15:0] compressed_instr;
  logic        illegal_c_insn;
  privlvl_t    priv_lvl;
  logic [31:0] trigger_match;    // only DBG_NUM_TRIGGERS are implemented, free bits will be tied off
  logic [31:0] xif_id;           // ID of offloaded instruction
  logic [31:0] ptr;              // Flops to hold 32-bit pointer
  logic        first_op;         // First part of multi operation instruction
  logic        last_op;          // Last part of multi operation instruction
  logic        abort_op;         // Instruction will be aborted due to known exceptions or trigger matches
} if_id_pipe_t;

// ID/EX pipeline
typedef struct packed {

  // ALU
  logic         alu_en;
  logic         alu_bch;
  logic         alu_jmp;
  alu_opcode_e  alu_operator;
  logic [31:0]  alu_operand_a;
  logic [31:0]  alu_operand_b;
  logic [31:0]  operand_c;

  // Multiplier
  logic         mul_en;
  mul_opcode_e  mul_operator;
  logic [ 1:0]  mul_signed_mode;

  // Divider
  logic         div_en;
  div_opcode_e  div_operator;

  // Operands for multiplier and divider
  logic [31:0]  muldiv_operand_a;
  logic [31:0]  muldiv_operand_b;

  // CSR
  logic         csr_en;
  csr_opcode_e  csr_op;

  // LSU
  logic         lsu_en;
  logic         lsu_we;
  logic [1:0]   lsu_size;
  logic         lsu_sext;
  logic [5:0]   lsu_atop;

  // SYS
  logic         sys_en;
  logic         sys_dret_insn;
  logic         sys_ebrk_insn;
  logic         sys_ecall_insn;
  logic         sys_fence_insn;
  logic         sys_fencei_insn;
  logic         sys_mret_insn;
  logic         sys_wfi_insn;
  logic         sys_wfe_insn;

  logic         illegal_insn;

  // Trigger match on insn
  logic [31:0]  trigger_match;    // only DBG_NUM_TRIGGERS are implemented, free bits will be tied off

  // Register write control
  logic         rf_we;
  rf_addr_t     rf_waddr;

  // Signals for exception handling etc passed on for evaluation in WB stage
  logic [31:0]  pc;
  inst_resp_t   instr;            // Contains instruction word (may be compressed),bus error status and MPU status
  instr_meta_t  instr_meta;
  logic         instr_valid;      // instruction in EX is valid

  privlvl_t     priv_lvl;

  // eXtension interface
  logic         xif_en;           // Instruction has been offloaded via eXtension interface
  xif_meta_t    xif_meta;         // xif meta struct

  logic         first_op;         // First part of multi operation instruction
  logic         last_op;          // Last part of multi operation instruction
  logic         abort_op;         // Instruction will be aborted due to known exceptions or trigger matches

} id_ex_pipe_t;

// EX/WB pipeline
typedef struct packed {
  logic         rf_we;
  rf_addr_t     rf_waddr;
  logic [31:0]  rf_wdata;

  // ALU
  logic         alu_jmp_qual;           // Qualified with alu_en
  logic         alu_bch_qual;           // Qualified with alu_en
  logic         alu_bch_taken_qual;     // Qualified with alu_en

  // CSR
  logic         csr_en;
  csr_opcode_e  csr_op;
  logic [11:0]  csr_addr;
  logic [31:0]  csr_wdata;
  logic         csr_mnxti_access;

  // LSU
  logic         lsu_en;

  // Trigger match on insn
  logic [31:0]  trigger_match;    // only DBG_NUM_TRIGGERS are implemented, free bits will be tied off

  // Signals for exception handling etc
  logic [31:0]  pc;
  inst_resp_t   instr;            // Contains instruction word (may be compressed), bus error status and MPU status
  instr_meta_t  instr_meta;
  logic         instr_valid;      // instruction in WB is valid
  logic         illegal_insn;

  privlvl_t     priv_lvl;

  logic         sys_en;
  logic         sys_dret_insn;
  logic         sys_ebrk_insn;
  logic         sys_ecall_insn;
  logic         sys_fence_insn;
  logic         sys_fencei_insn;
  logic         sys_mret_insn;
  logic         sys_wfi_insn;
  logic         sys_wfe_insn;

  // eXtension interface
  logic         xif_en;           // Instruction has been offloaded via eXtension interface
  xif_meta_t    xif_meta;         // xif meta struct

  logic         first_op;         // First part of multi operation instruction
  logic         last_op;          // Last part of multi operation instruction
  logic         abort_op;         // Instruction will be aborted due to known exceptions or trigger matches

  logic         csr_impl_wr;      // A CSR instruction is doing an implicit write
} ex_wb_pipe_t;

// Performance counter events
typedef struct packed {
  logic                              minstret;
  logic                              compressed;
  logic                              jump;
  logic                              branch;
  logic                              branch_taken;
  logic                              intr_taken;
  logic                              data_read;
  logic                              data_write;
  logic                              if_invalid;
  logic                              id_invalid;
  logic                              ex_invalid;
  logic                              wb_invalid;
  logic                              id_ld_stall;
  logic                              id_jalr_stall;
  logic                              wb_data_stall;
} mhpmevent_t;


// Controller Bypass outputs
typedef struct packed {
  op_fw_mux_e   operand_a_fw_mux_sel;   // Operand A forward mux sel
  op_fw_mux_e   operand_b_fw_mux_sel;   // Operand B forward mux sel
  jalr_fw_mux_e jalr_fw_mux_sel;        // Jump target forward mux sel
  logic         jalr_stall;             // Stall due to JALR hazard (JALR used result from EX or LSU result in WB)
  logic         load_stall;             // Stall due to load operation
  logic         csr_stall_id;
  logic         csr_stall_ex;
  logic         sleep_stall;            // Stall ID due to sleep (e.g. WFI, WFE) instruction in EX
  logic         mnxti_id_stall;         // Stall ID due to mnxti CSR access in EX
  logic         mnxti_ex_stall;         // Stall EX due to LSU instruction in WB
  logic         minstret_stall;         // Stall due to minstret/h read in EX
  logic         deassert_we;            // Deassert write enable and special insn bits
  logic         id_stage_abort;         // Same signal as deassert_we, with better name for use in the controller.
  logic         xif_exception_stall;    // Stall (EX) if xif insn in WB can cause an exception
  logic         irq_enable_stall;       // Stall (EX) if an interrupt may be enabled by the instruction in WB.
  logic         atomic_stall;           // Stall (EX) if an Atomic/non-atomic LSU is in EX while an non-atomic/Atomic is in WB
} ctrl_byp_t;

// Controller FSM outputs
typedef struct packed {
  logic        ctrl_busy;             // Core is busy processing instructions

  // to IF stage
  logic        instr_req;             // Start fetching instructions
  logic        pc_set;                // Jump to address set by pc_mux
  logic        pc_set_clicv;          // Signal pc_set it for CLIC vectoring pointer load
  logic        pc_set_tbljmp;         // Signal pc_set is for Zc* cm.jt / cm.jalt pointer load
  pc_mux_e     pc_mux;                // Selector in the Fetch stage to select the rigth PC (normal, jump ...)
  logic [4:0]  mtvec_pc_mux;          // Id of taken basic mode irq (to IF, EXC_PC_MUX, zeroed if mtvec_mode==0)
  logic [9:0]  mtvt_pc_mux;           // Id of taken CLIC irq (to IF, EXC_PC_MUX, zeroed if not shv)
                                      // Setting to 11 bits (max), unused bits will be tied off
  logic [4:0]  nmi_mtvec_index;       // Offset into mtvec when taking an NMI

  logic        irq_ack;               // Irq has been taken
  logic [9:0]  irq_id;                // Id of taken irq. Max width (1024 interrupts), unused bits will be tied off
  logic [7:0]  irq_level;             // Level of taken irq (CLIC only)
  logic [1:0]  irq_priv;              // Associated privilege mode for taken irq (CLIC only)
  logic        irq_shv;               // Selective hardware vectoring for taken irq (CLIC only)
  logic        dbg_ack;               // Debug has been taken

  // Debug outputs
  logic        debug_mode_if;          // Flag signalling we are in debug mode, valid for IF
  logic        debug_mode;             // Flag signalling we are in debug mode, valid for ID, EX and WB
  logic [2:0]  debug_cause;            // cause of debug entry
  logic        debug_csr_save;         // Update debug CSRs
  logic [31:0] debug_trigger_hit;      // Mask for hit bits for mcontrol6 triggers
  logic        debug_trigger_hit_update; // Signal that hit bits should be updated
  logic        debug_no_sleep;         // Debug prevents core from sleeping after WFI, etc.
  logic        debug_havereset;        // Signal to external debugger that we have reset
  logic        debug_running;          // Signal to external debugger that we are running (not in debug)
  logic        debug_halted;           // Signal to external debugger that we are halted (in debug mode)


  // Wakeup Signal to sleep unit
  logic        wake_from_sleep;       // Wakeup (due to irq or debug)

  // CSR signals
  logic [31:0] pipe_pc;             // PC from pipeline
  mcause_t     csr_cause;           // CSR cause (saves to mcause CSR)
  logic        csr_restore_mret;    // Restore CSR due to mret
  logic        csr_restore_dret;    // Restore CSR due to dret
  logic        csr_save_cause;      // Update CSRs
  logic        pending_nmi;         // An NMI is pending (for dcsr.nmip)

  // Performance counter events
  mhpmevent_t  mhpmevent;

  // Halt signals
  logic        halt_if; // Halt IF stage
  logic        halt_id; // Halt ID stage
  logic        halt_ex; // Halt EX stage
  logic        halt_wb; // Halt WB stage
  logic        halt_limited_wb; // Halt WB stage during SLEEP, but not cs_registers

  // Kill signals
  logic        kill_if; // Kill IF stage
  logic        kill_id; // Kill ID stage
  logic        kill_ex; // Kill EX stage
  logic        kill_wb; // Kill WB stage

  // Kill signal for xif_commit_if
  logic        kill_xif; // Kill (attempted) offloaded instruction

  // Signal that an exception is in WB
  logic        exception_in_wb;
  logic [10:0] exception_cause_wb;
} ctrl_fsm_t;

  ////////////////////////////////////////
  // Resolution functions


  function automatic privlvl_t dcsr_prv_resolve
  (
    privlvl_t   current_value,
    logic [1:0] next_value
  );
    // dcsr.prv is WARL(0x3)
    return PRIV_LVL_M;
  endfunction

  function automatic logic dcsr_ebreaku_resolve
  (
    logic       current_value,
    logic       next_value
  );
    // dcsr.ebreaku is WARL(0x0)
    return 1'b0;
  endfunction

  function automatic logic [1:0] mstatus_mpp_resolve
  (
    logic [1:0] current_value,
    logic [1:0] next_value
  );
    // mstatus.mpp is WARL(0x3)
    return PRIV_LVL_M;
  endfunction

  function automatic logic [1:0] mcause_mpp_resolve
  (
    logic [1:0] current_value,
    logic [1:0] next_value
  );
    // mcause.mpp is WARL(0x3)
    return PRIV_LVL_M;
  endfunction

  function automatic logic mstatus_mprv_resolve
  (
    logic current_value,
    logic next_value
  );
    // mstatus.mprv is WARL(0x0)
    return 1'b0;
  endfunction

  function automatic logic [3:0] mcontrol2_6_match_resolve
  (
    logic [3:0] next_value
  );
    return ((next_value != 4'h0) && (next_value != 4'h2) && (next_value != 4'h3)) ? 4'h0 : next_value;
  endfunction

  function automatic logic mcontrol2_6_u_resolve
  (
    logic next_value
  );
    // mcontrol2/6.u is WARL(0x0)
    return 1'b0;
  endfunction

  function automatic logic mcontrol6_uncertain_resolve
  (
    logic next_value
  );
    // mcontrol6.uncertain is WARL(0x0)
    return 1'b0;
  endfunction

  function automatic logic mcontrol6_uncertainen_resolve
  (
    logic next_value
  );
    // mcontrol6.uncertainen is WARL(0x0)
    return 1'b0;
  endfunction

  function automatic logic [1:0] mcontrol6_hit_resolve
  (
    logic [1:0] current_value,
    logic [1:0] next_value
  );
    // mcontrol6.hit is WARL(0x0, 0x1)
    return ((next_value != 2'b00) && (next_value != 2'b01)) ? current_value : next_value;
  endfunction

  function automatic logic etrigger_u_resolve
  (
    logic next_value
  );
    // etrigger.u is WARL(0x0)
    return 1'b0;
  endfunction

  function automatic logic[1:0] mtvec_mode_clint_resolve
  (
    logic [1:0] current_value,
    logic [1:0] next_value
  );
    // mtvec.mode is WARL(0,1) in CLINT mode
    return ((next_value != 2'b00) && (next_value != 2'b01)) ? current_value : next_value;
  endfunction

  function automatic logic[1:0] mtvec_mode_clic_resolve
  (
    logic [1:0] current_value,
    logic [1:0] next_value
  );
    // mtvec.mode is WARL(0x3) in CLIC mode
    return 2'b11;
  endfunction

  // Function for setting next-value for CSRs
  // Uses a mask and reset value to allow nom-implemented (no flipflop) bits to be either 0 or 1.
  function automatic logic [31:0] csr_next_value
  (
      logic [31:0] wdata,
      logic [31:0] mask,
      logic [31:0] reset_value
  );
      return (wdata & mask) | (reset_value & ~mask);
  endfunction
  ///////////////////////////
  //                       //
  //    /\/\ (_)___  ___   //
  //   /    \| / __|/ __|  //
  //  / /\/\ \ \__ \ (__   //
  //  \/    \/_|___/\___|  //
  //                       //
  ///////////////////////////

  // RV32 base integer instruction set
  typedef enum logic {RV32I, RV32E} rv32_e;

  // Write buffer FSM state encoding
  typedef enum logic {WBUF_EMPTY, WBUF_FULL} write_buffer_state_e;

  // OBI interface FSM state encoding
  typedef enum logic {TRANSPARENT, REGISTERED} obi_if_state_e;

  // Enum used for configuration of A extension
  typedef enum logic [1:0] {A_NONE, ZALRSC, A} a_ext_e;

  // Enum used for configuration of B extension
  typedef enum logic [1:0] {B_NONE, ZBA_ZBB, ZBA_ZBB_ZBS, ZBA_ZBB_ZBC_ZBS} b_ext_e;

  // Enum used for configuration of M extension
  typedef enum logic [1:0] {M_NONE, M, ZMMUL} m_ext_e;

  // Pipe PC mux selector defines. Used to control PC mux in control FSM
  typedef enum logic[1:0] {
    PC_IF,
    PC_ID,
    PC_EX,
    PC_WB
  } pipe_pc_mux_e;


  //////////////////
  // Zc Sequencer //
  //////////////////

  typedef logic [4:0] regnum_t;
  typedef logic [3:0] seq_t;    // Max length is 16 for POPRETZ, counter limit is then 15.

  localparam REG_ZERO = 5'd0;
  localparam REG_RA = 5'd1;
  localparam REG_SP = 5'd2;

  typedef enum logic [3:0] {
    INVALID_INST,
    PUSH,
    POP,
    POPRET,
    POPRETZ,
    MVA01S,
    MVSA01,
    TBLJMP
  } seq_instr_e;

  typedef enum logic [3:0] {
    R_NONE    = 4'd0,
    RA_S0     = 4'd1,
    RA_S0_S1  = 4'd2,
    RA_S0_S2  = 4'd3,
    RA_S0_S3  = 4'd4,
    RA_S0_S4  = 4'd5,
    RA_S0_S5  = 4'd6,
    RA_S0_S6  = 4'd7,
    RA_S0_S7  = 4'd8,
    RA_S0_S8  = 4'd9,
    RA_S0_S9  = 4'd10,
    RA_S0_S11 = 4'd12
  } pushpop_rlist_e;


  typedef struct packed {
    logic [11:0]    stack_adj_base;        // Stack adjustment based on space needed by register list
    pushpop_rlist_e registers_saved;       // Number of s-registers saved (excluding ra)
    logic [11:0]    total_stack_adj;       // Total stack adjustment (register space + extra blocks)
    logic [11:0]    current_stack_adj;     // Current stack adjustment for use in sequence
    regnum_t        sreg;                  // Current s-register being pushed/popped
  } pushpop_decode_s;


  // Map any of S0-S11 to X-registers
  function automatic regnum_t sn_to_regnum(regnum_t snum);
    case (snum)
      0, 1:    sn_to_regnum = regnum_t'({(snum[3:1] != 3'd0), 1'b1, snum[2:0]});
      default: sn_to_regnum = regnum_t'({(snum[3:1] != 3'd0), snum[3], snum[2:0]});
    endcase
  endfunction

  // Set stack adjustment base based on rlist as suggested in Zc spec 0.70.4
  function automatic logic [11:0] get_stack_adj_base(logic [3:0] rlist);
    case (rlist)
      4,5,6,7: begin
        get_stack_adj_base = 12'd16;
      end
      8,9,10,11: begin
        get_stack_adj_base = 12'd32;
      end
      12,13,14: begin
        get_stack_adj_base = 12'd48;
      end
      15: begin
        get_stack_adj_base = 12'd64;
      end
      default: begin
        get_stack_adj_base = 12'd0;
      end
    endcase

  endfunction

  function automatic pushpop_rlist_e pushpop_reg_length(logic [3:0] rlist4);
    case (rlist4)
      'd0:     pushpop_reg_length = R_NONE;
      'd1:     pushpop_reg_length = R_NONE;
      'd2:     pushpop_reg_length = R_NONE;
      'd3:     pushpop_reg_length = R_NONE;
      'd4:     pushpop_reg_length = R_NONE;
      'd5:     pushpop_reg_length = RA_S0;
      'd6:     pushpop_reg_length = RA_S0_S1;
      'd7:     pushpop_reg_length = RA_S0_S2;
      'd8:     pushpop_reg_length = RA_S0_S3;
      'd9:     pushpop_reg_length = RA_S0_S4;
      'd10:    pushpop_reg_length = RA_S0_S5;
      'd11:    pushpop_reg_length = RA_S0_S6;
      'd12:    pushpop_reg_length = RA_S0_S7;
      'd13:    pushpop_reg_length = RA_S0_S8;
      'd14:    pushpop_reg_length = RA_S0_S9;
      'd15:    pushpop_reg_length = RA_S0_S11;
      default: pushpop_reg_length = R_NONE;
    endcase
  endfunction

  // State machine definition
  typedef enum logic [3:0] { S_IDLE, S_PUSH, S_POP, S_DMOVE, S_RA, S_SP, S_A0, S_RET} seq_state_e;

endpackage



















// OBI interface definition for instruction and data
// The two parameters set the types for payload 
// as these are different for instruction and data
// 
// The 'c' in the interface names means 'Compressed'
// since this interface is a subset of the full OBI spec.
interface cv32e40x_if_c_obi import cv32e40x_pkg::*;
#(
    parameter type REQ_TYPE  = obi_inst_req_t,
    parameter type RESP_TYPE = obi_inst_resp_t
);
    // A channel signals
    obi_req_t                  s_req;
    obi_gnt_t                  s_gnt;
    REQ_TYPE                   req_payload;
    // R channel signals
    obi_rvalid_t               s_rvalid;
    RESP_TYPE                  resp_payload;
  
    modport master
       (
       output s_req, req_payload,
       input  s_gnt, s_rvalid, resp_payload
       );
  
    modport monitor
       (
       input  s_req, req_payload,
              s_gnt, s_rvalid, resp_payload
       );

endinterface : cv32e40x_if_c_obi











// Description:    Definition of the CORE-V XIF eXtension Interface.          //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

interface cv32e40x_if_xif
#(
  parameter int unsigned X_NUM_RS        =  2,  // Number of register file read ports that can be used by the eXtension interface
  parameter int unsigned X_ID_WIDTH      =  4,  // Width of ID field.
  parameter int unsigned X_MEM_WIDTH     =  32, // Memory access width for loads/stores via the eXtension interface
  parameter int unsigned X_RFR_WIDTH     =  32, // Register file read access width for the eXtension interface
  parameter int unsigned X_RFW_WIDTH     =  32, // Register file write access width for the eXtension interface
  parameter logic [31:0] X_MISA          =  '0, // MISA extensions implemented on the eXtension interface
  parameter logic [ 1:0] X_ECS_XS        =  '0  // Default value for mstatus.XS
);

  localparam int XLEN = 32;
  localparam int FLEN = 32;

  typedef struct packed {
    logic [          15:0] instr; // Offloaded compressed instruction
    logic [           1:0] mode;  // Privilege level
    logic [X_ID_WIDTH-1:0] id;    // Identification number of the offloaded compressed instruction
  } x_compressed_req_t;

  typedef struct packed {
    logic [31:0] instr;   // Uncompressed instruction
    logic        accept;  // Is the offloaded compressed instruction (id) accepted by the coprocessor?
  } x_compressed_resp_t;

  typedef struct packed {
    logic [          31:0]                  instr;     // Offloaded instruction
    logic [           1:0]                  mode;      // Privilege level
    logic [X_ID_WIDTH-1:0]                  id;        // Identification of the offloaded instruction
    logic [X_NUM_RS  -1:0][X_RFR_WIDTH-1:0] rs;        // Register file source operands for the offloaded instruction
    logic [X_NUM_RS  -1:0]                  rs_valid;  // Validity of the register file source operand(s)
    logic [           5:0]                  ecs;       // Extension Context Status ({mstatus.xs, mstatus.fs, mstatus.vs})
    logic                                   ecs_valid; // Validity of the Extension Context Status
  } x_issue_req_t;

  typedef struct packed {
    logic       accept;     // Is the offloaded instruction (id) accepted by the coprocessor?
    logic       writeback;  // Will the coprocessor perform a writeback in the core to rd?
    logic       dualwrite;  // Will the coprocessor perform a dual writeback in the core to rd and rd+1?
    logic [2:0] dualread;   // Will the coprocessor require dual reads from rs1\rs2\rs3 and rs1+1\rs2+1\rs3+1?
    logic       loadstore;  // Is the offloaded instruction a load/store instruction?
    logic       ecswrite ;  // Will the coprocessor write the Extension Context Status in mstatus?
    logic       exc;        // Can the offloaded instruction possibly cause a synchronous exception in the coprocessor itself?
  } x_issue_resp_t;

  typedef struct packed {
    logic [X_ID_WIDTH-1:0] id;          // Identification of the offloaded instruction
    logic                  commit_kill; // Shall an offloaded instruction be killed?
  } x_commit_t;

  typedef struct packed {
    logic [X_ID_WIDTH   -1:0] id;    // Identification of the offloaded instruction
    logic [             31:0] addr;  // Virtual address of the memory transaction
    logic [              1:0] mode;  // Privilege level
    logic                     we;    // Write enable of the memory transaction
    logic [              2:0] size;  // Size of the memory transaction
    logic [X_MEM_WIDTH/8-1:0] be;    // Byte enables for memory transaction
    logic [              1:0] attr;  // Memory transaction attributes
    logic [X_MEM_WIDTH  -1:0] wdata; // Write data of a store memory transaction
    logic                     last;  // Is this the last memory transaction for the offloaded instruction?
    logic                     spec;  // Is the memory transaction speculative?
  } x_mem_req_t;

  typedef struct packed {
    logic       exc;      // Did the memory request cause a synchronous exception?
    logic [5:0] exccode;  // Exception code
    logic       dbg;      // Did the memory request cause a debug trigger match with ``mcontrol.timing`` = 0?
  } x_mem_resp_t;

  typedef struct packed {
    logic [X_ID_WIDTH -1:0] id;     // Identification of the offloaded instruction
    logic [X_MEM_WIDTH-1:0] rdata;  // Read data of a read memory transaction
    logic                   err;    // Did the instruction cause a bus error?
    logic                   dbg;    // Did the read data cause a debug trigger match with ``mcontrol.timing`` = 0?
  } x_mem_result_t;

  typedef struct packed {
    logic [X_ID_WIDTH      -1:0] id;      // Identification of the offloaded instruction
    logic [X_RFW_WIDTH     -1:0] data;    // Register file write data value(s)
    logic [                 4:0] rd;      // Register file destination address(es)
    logic [X_RFW_WIDTH/XLEN-1:0] we;      // Register file write enable(s)
    logic [                 5:0] ecsdata; // Write data value for {mstatus.xs, mstatus.fs, mstatus.vs}
    logic [                 2:0] ecswe;   // Write enables for {mstatus.xs, mstatus.fs, mstatus.vs}
    logic                        exc;     // Did the instruction cause a synchronous exception?
    logic [                 5:0] exccode; // Exception code
    logic                        err;     // Did the instruction cause a bus error?
    logic                        dbg;     // Did the instruction cause a debug trigger match with ``mcontrol.timing`` = 0?
  } x_result_t;

  // Compressed interface
  logic               compressed_valid;
  logic               compressed_ready;
  x_compressed_req_t  compressed_req;
  x_compressed_resp_t compressed_resp;

  // Issue interface
  logic               issue_valid;
  logic               issue_ready;
  x_issue_req_t       issue_req;
  x_issue_resp_t      issue_resp;

  // Commit interface
  logic               commit_valid;
  x_commit_t          commit;

  // Memory (request/response) interface
  logic               mem_valid;
  logic               mem_ready;
  x_mem_req_t         mem_req;
  x_mem_resp_t        mem_resp;

  // Memory result interface
  logic               mem_result_valid;
  x_mem_result_t      mem_result;

  // Result interface
  logic               result_valid;
  logic               result_ready;
  x_result_t          result;

  // Port directions for host CPU
  modport cpu_compressed (
    output compressed_valid,
    input  compressed_ready,
    output compressed_req,
    input  compressed_resp
  );
  modport cpu_issue (
    output issue_valid,
    input  issue_ready,
    output issue_req,
    input  issue_resp
  );
  modport cpu_commit (
    output commit_valid,
    output commit
  );
  modport cpu_mem (
    input  mem_valid,
    output mem_ready,
    input  mem_req,
    output mem_resp
  );
  modport cpu_mem_result (
    output mem_result_valid,
    output mem_result
  );
  modport cpu_result (
    input  result_valid,
    output result_ready,
    input  result
  );

  // Port directions for extension
  modport coproc_compressed (
    input  compressed_valid,
    output compressed_ready,
    input  compressed_req,
    output compressed_resp
  );
  modport coproc_issue (
    input  issue_valid,
    output issue_ready,
    input  issue_req,
    output issue_resp
  );
  modport coproc_commit (
    input  commit_valid,
    input  commit
  );
  modport coproc_mem (
    output mem_valid,
    input  mem_ready,
    output mem_req,
    input  mem_resp
  );
  modport coproc_mem_result (
    input  mem_result_valid,
    input  mem_result
  );
  modport coproc_result (
    output result_valid,
    input  result_ready,
    output result
  );

  // Monitor port directions
  modport monitor_compressed (
    input  compressed_valid,
    input  compressed_ready,
    input  compressed_req,
    input  compressed_resp
  );
  modport monitor_issue (
    input  issue_valid,
    input  issue_ready,
    input  issue_req,
    input  issue_resp
  );
  modport monitor_commit (
    input  commit_valid,
    input  commit
  );
  modport monitor_mem (
    input  mem_valid,
    input  mem_ready,
    input  mem_req,
    input  mem_resp
  );
  modport monitor_mem_result (
    input  mem_result_valid,
    input  mem_result
  );
  modport monitor_result (
    input  result_valid,
    input  result_ready,
    input  result
  );

endinterface : cv32e40x_if_xif







module cv32e40x_clock_gate
#(
  parameter LIB = 0
  )
(
    input  logic clk_i,
    input  logic en_i,
    input  logic scan_cg_en_i,
    output logic clk_o
  );

  logic clk_en;

  always_latch
  begin
     if (clk_i == 1'b0)
       clk_en <= en_i | scan_cg_en_i;
  end

  assign clk_o = clk_i & clk_en;

endmodule // cv32e40x_clock_gate


// Description:    Sleep unit containing the instantiated clock gate which    //
//                 provides the gated clock (clk_gated_o) for the rest        //
//                 of the design.                                             //
//                                                                            //
//                 The clock is gated for the following scenarios:            //
//                                                                            //
//                 - While waiting for fetch to become enabled                //
//                 - While blocked on a WFI                                   //
//                                                                            //
//                 Sleep is signaled via core_sleep_o:                        //
//                                                                            //
//                 - During a WFI (except in debug)                           //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_sleep_unit import cv32e40x_pkg::*;
#(
  parameter LIB = 0
)
(
  // Clock, reset interface
  input  logic        clk_ungated_i,            // Free running clock
  input  logic        rst_n,
  output logic        clk_gated_o,              // Gated clock
  input  logic        scan_cg_en_i,             // Enable all clock gates for testing

  // Core sleep
  output logic        core_sleep_o,

  // Fetch enable
  input  logic        fetch_enable_i,
  output logic        fetch_enable_o,

  // Core status
  input  logic        if_busy_i,
  input  logic        lsu_busy_i,

  input  ctrl_fsm_t   ctrl_fsm_i
);

  logic              fetch_enable_q;            // Sticky version of fetch_enable_i
  logic              fetch_enable_d;
  logic              core_busy_q;               // Is core still busy (and requires a clock) with what needs to finish before entering sleep?
  logic              core_busy_d;
  logic              clock_en;                  // Final clock enable

  //////////////////////////////////////////////////////////////////////////////
  // Sleep FSM
  //////////////////////////////////////////////////////////////////////////////

  // Make sticky version of fetch_enable_i
  assign fetch_enable_d = fetch_enable_i ? 1'b1 : fetch_enable_q;

  // Busy when any of the sub units is busy (typically wait for the instruction buffer to fill up)
  assign core_busy_d = if_busy_i || ctrl_fsm_i.ctrl_busy || lsu_busy_i;

  // Enable the clock only after the initial fetch enable while busy or waking up to become busy
  assign clock_en = fetch_enable_q && (ctrl_fsm_i.wake_from_sleep || core_busy_q);

  // Sleep only in response to WFI which leads to clock disable. The controller determines the
  // scenarios for which WFI can(not) cause sleep. WFI suppression is performed in the i_decoder
  // based on the debug_no_sleep signal from the controller.
  assign core_sleep_o = fetch_enable_q && !clock_en;

  always_ff @(posedge clk_ungated_i, negedge rst_n)
  begin
    if (rst_n == 1'b0) begin
      core_busy_q    <= 1'b0;
      fetch_enable_q <= 1'b0;
    end else begin
      core_busy_q    <= core_busy_d;
      fetch_enable_q <= fetch_enable_d;
    end
  end

  // Fetch enable for Controller
  assign fetch_enable_o = fetch_enable_q;

  // Main clock gate of CV32E40P
  cv32e40x_clock_gate
    #(.LIB (LIB))
  core_clock_gate_i
  (
    .clk_i        ( clk_ungated_i   ),
    .en_i         ( clock_en        ),
    .scan_cg_en_i ( scan_cg_en_i    ),
    .clk_o        ( clk_gated_o     )
  );

endmodule





// Description:    Prefetch Controller which receives control flow            //
//                 information (req_i, branch_*) from the Fetch stage         //
//                 and based on that performs transactions requests to the    //
//                 bus interface adapter instructions. Prefetching based on   //
//                 incrementing addressed is performed when no new control    //
//                 flow change is requested. New transaction requests are     //
//                 only performed if it can be guaranteed that the fetch FIFO //
//                 will not overflow (resulting in a maximum of DEPTH         //
//                 outstanding transactions.                                  //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_prefetcher import cv32e40x_pkg::*;
#(
    parameter bit CLIC = 1'b0
)
(
  input  logic                     clk,
  input  logic                     rst_n,

  // Interface to alignment_buffer
  input  logic                     fetch_branch_i,                // Taken branch
  input  logic [31:0]              fetch_branch_addr_i,           // Taken branch address (only valid when fetch_branch_i = 1), word aligned
  input  logic                     fetch_valid_i,
  output logic                     fetch_ready_o,
  input  logic                     fetch_ptr_access_i,            // Access is for a pointer (CLIC, mret or tablejump)
  output logic                     fetch_ptr_access_o,            // Handshake is for a pointer access (CLIC, mret or tablejump)
  input  privlvl_t                 fetch_priv_lvl_access_i,       // Priv level of access
  output privlvl_t                 fetch_priv_lvl_access_o,       // Priv level for the (fetch_valid_i && fetch_ready_o) handshake, indicating privilege level of the requested instruction.

  // Transaction request interface
  output logic                     trans_valid_o,           // Transaction request valid (to bus interface adapter)
  input  logic                     trans_ready_i,           // Transaction request ready (transaction gets accepted when trans_valid_o and trans_ready_i are both 1)
  output logic [31:0]              trans_addr_o             // Transaction address (only valid when trans_valid_o = 1). No stability requirements.
);


  prefetch_state_e state_q, next_state;

  // Transaction address
  logic [31:0]                   trans_addr_q, trans_addr_incr;
  logic                          trans_ptr_access_q;
  privlvl_t                      trans_priv_lvl_q;

  // Increment address (address will be made word aligned at core level)
  assign trans_addr_incr = {trans_addr_q[31:1], 1'b0} + 32'd4;

  // Transaction request generation
  // alignment_buffer will request a transaction when it needs it.
  // Alignment buffer controls number of outstanding transactions
  // and will always be ready to accept responses.
  assign trans_valid_o = fetch_valid_i;

  assign fetch_ready_o = trans_valid_o && trans_ready_i;

  // FSM (state_q, next_state) to control trans_addr_o
  always_comb
  begin
    next_state = state_q;
    trans_addr_o = trans_addr_q;
    fetch_ptr_access_o = trans_ptr_access_q;
    fetch_priv_lvl_access_o = trans_priv_lvl_q;

    case(state_q)
      // Default state (pass on branch target address or transaction with incremented address)
      IDLE:
      begin
        begin
          // Select branch address on branch, otherwise incremented address
          if (fetch_branch_i) begin
            trans_addr_o = fetch_branch_addr_i;
            fetch_ptr_access_o = fetch_ptr_access_i;
            fetch_priv_lvl_access_o = fetch_priv_lvl_access_i;
          end else begin
            trans_addr_o = trans_addr_incr;
            fetch_ptr_access_o = 1'b0; // No incremental pointer fetches
            fetch_priv_lvl_access_o = fetch_priv_lvl_access_i;
          end
        end
        if ((fetch_branch_i) && !(trans_valid_o && trans_ready_i)) begin
          // Taken branch, but transaction not yet accepted by bus interface adapter.
          next_state = BRANCH_WAIT;
        end
      end // case: IDLE

      BRANCH_WAIT:
      begin
        // Replay previous branch target address (trans_addr_q) or new branch address (this can
        // occur if for example an interrupt is taken right after a taken jump which did not
        // yet have its target address accepted by the bus interface adapter.
        trans_addr_o = fetch_branch_i ? fetch_branch_addr_i : trans_addr_q;
        fetch_ptr_access_o = fetch_branch_i ? fetch_ptr_access_i : trans_ptr_access_q;
        fetch_priv_lvl_access_o = fetch_branch_i ? fetch_priv_lvl_access_i : trans_priv_lvl_q;
        if (trans_valid_o && trans_ready_i) begin
          // Transaction with branch target address has been accepted. Start regular prefetch again.
          next_state = IDLE;
        end
      end // case: BRANCH_WAIT

      default:;
    endcase
  end


  //////////////////////////////////////////////////////////////////////////////
  // Registers
  //////////////////////////////////////////////////////////////////////////////

  always_ff @(posedge clk, negedge rst_n)
  begin
    if(rst_n == 1'b0)
    begin
      state_q            <= IDLE;
      trans_addr_q       <= '0;
      trans_ptr_access_q <= 1'b0;
      trans_priv_lvl_q   <= PRIV_LVL_M;
    end
    else
    begin
      state_q        <= next_state;
      if (fetch_branch_i || (trans_valid_o && trans_ready_i)) begin
        trans_addr_q <= trans_addr_o;
        trans_ptr_access_q <= fetch_ptr_access_o;
        trans_priv_lvl_q <= fetch_priv_lvl_access_o;
      end
    end
  end

endmodule





module cv32e40x_alignment_buffer import cv32e40x_pkg::*;
#(
  parameter int unsigned ALBUF_DEPTH     = 3,
  parameter int unsigned ALBUF_CNT_WIDTH = $clog2(ALBUF_DEPTH)
)
(
  input  logic           clk,
  input  logic           rst_n,

  // Controller fsm inputs
  input  ctrl_fsm_t      ctrl_fsm_i,

  // Privilige level control
  input privlvlctrl_t    priv_lvl_ctrl_i,

  // Branch control
  input  logic [31:0]    branch_addr_i,
  output logic           prefetch_busy_o,
  output logic           one_txn_pend_n,

  // Interface to prefetcher
  output logic           fetch_valid_o,
  input  logic           fetch_ready_i,
  output logic           fetch_branch_o,
  output logic [31:0]    fetch_branch_addr_o,
  output logic           fetch_ptr_access_o,
  input  logic           fetch_ptr_access_i,
  output privlvl_t       fetch_priv_lvl_o,
  input  privlvl_t       fetch_priv_lvl_i,

  // Resp interface
  input  logic           resp_valid_i,
  input  inst_resp_t     resp_i,


  // Interface to if_stage
  output logic                       instr_valid_o,
  input  logic                       instr_ready_i,
  output inst_resp_t                 instr_instr_o,
  output logic [31:0]                instr_addr_o,
  output privlvl_t                   instr_priv_lvl_o,
  output logic                       instr_is_clic_ptr_o, // True CLIC pointer after taking a CLIC SHV interrupt
  output logic                       instr_is_mret_ptr_o, // CLIC pointer due to restarting pointer fetch during mret
  output logic                       instr_is_tbljmp_ptr_o,
  output logic [ALBUF_CNT_WIDTH-1:0] outstnd_cnt_q_o
);

  // Counter for number of instructions in the FIFO
  // ALBUF_CNT_WIDTH defines number of words
  // We must count number of instructions, thus
  // using the value without subtracting
  logic [ALBUF_CNT_WIDTH:0] instr_cnt_n, instr_cnt_q;

  // Counter for number of outstanding transactions
  logic [ALBUF_CNT_WIDTH-1:0] outstanding_cnt_n, outstanding_cnt_q;
  logic outstanding_count_up;
  logic outstanding_count_down;

  // number of complete instructions in resp_data
  logic [1:0] n_incoming_ins;

  // Indicates that we consumed one instruction last cycle
  logic pop_q;

  // Number of instructions pushed to fifo
  // special encoding 2'b11 means pop (-1 instruction)
  // Other values are unsigned
  logic [1:0] n_pushed_ins;

  // Flags to indicate aligned address and complete instructions
  // in the write side of the buffer. This is used in the tracking
  // of number of complete instructions (compressed and uncompressed)
  // in the buffer. Updated on branches and whenever we get a valid response.
  logic aligned_n, aligned_q;
  logic complete_n, complete_q;

  // Store number of responses to flush when get get a branch
  logic [1:0] n_flush_n, n_flush_q, n_flush_branch;

  // Error propagation signals for bus, mpu and alignment checker (pointers)
  logic bus_err_unaligned, bus_err;
  mpu_status_e mpu_status_unaligned, mpu_status;

  // resp_valid gated while flushing
  logic resp_valid_gated;

  // Privilege level for the IF stage
  privlvl_t instr_priv_lvl_q;

  // CLIC vectoring
  // Flag for signalling that results is a CLIC function pointer
  logic is_clic_ptr_q;
  logic is_mret_ptr_q;

  // Flag for table jump pointer
  logic is_tbljmp_ptr_q;
  logic ptr_fetch_accepted_q;

  assign resp_valid_gated = (n_flush_q > 0) ? 1'b0 : resp_valid_i;

  // Assume we always push all instructions to FIFO
  // We may directly consume it, but accounting for that gives
  // bad timing paths to instr_cnt_q
  assign n_pushed_ins = n_incoming_ins;

  // Request a transfer when needed, or we do a branch, iff outstanding_cnt_q is less than 2
  // Adjust instruction count with 'pop_q', which tells if we consumed an instruction
  // during the last cycle
  // For CLIC vector loads we want to stop prefetching between an accepted pointer load and
  // the next pc_set (to the target address).
  assign fetch_valid_o = (ctrl_fsm_i.instr_req )                                     &&
                         (outstanding_cnt_q < 2)                                     &&
                         !(ptr_fetch_accepted_q && !ctrl_fsm_i.pc_set)               && // No fetch until next pc_set after accepted pointer fetches
                         (((instr_cnt_q - pop_q) == 'd0)                             ||
                         ((instr_cnt_q - pop_q) == 'd1 && outstanding_cnt_q == ALBUF_CNT_WIDTH'(0)) ||
                         ctrl_fsm_i.pc_set);


  // Busy if we expect any responses, or we have an active fetch_valid_o
  assign prefetch_busy_o = (outstanding_cnt_q != ALBUF_CNT_WIDTH'(0))|| fetch_valid_o;

  // Indicate that there will be one pending transaction in the next cycle
  assign one_txn_pend_n = outstanding_cnt_n == ALBUF_CNT_WIDTH'(1);

  // Signal aligned branch to the prefetcher
  assign fetch_branch_o = ctrl_fsm_i.pc_set;
  assign fetch_branch_addr_o = {branch_addr_i[31:1], 1'b0};

  //////////////////
  // FIFO signals //
  //////////////////
  inst_resp_t [ALBUF_DEPTH-1:0]  resp_q;
  logic [ALBUF_DEPTH-1:0]        valid_n,   valid_int,   valid_q;
  inst_resp_t resp_n;

  // Read/write pointer for FIFO
  logic [ALBUF_CNT_WIDTH-1:0] rptr, rptr_n;
  logic [ALBUF_CNT_WIDTH-1:0] rptr2;
  logic [ALBUF_CNT_WIDTH-1:0] wptr, wptr_n;

  logic             [31:0]  addr_n, addr_q, addr_incr;
  logic             [31:0]  instr, instr_unaligned;
  logic                     valid, valid_unaligned_uncompressed;

  logic                     aligned_is_compressed, unaligned_is_compressed;

  // Aligned instructions will either be fully in index 0 or incoming data
  // This also applies for the bus_error and mpu_status
  assign instr        = (valid_q[rptr]) ? resp_q[rptr].bus_resp.rdata : resp_i.bus_resp.rdata;
  assign bus_err      = (valid_q[rptr]) ? resp_q[rptr].bus_resp.err   : resp_i.bus_resp.err;
  assign mpu_status   = (valid_q[rptr]) ? resp_q[rptr].mpu_status     : resp_i.mpu_status;


  // Unaligned instructions will either be split across index 0 and 1, or index 0 and incoming data
  assign instr_unaligned = (valid_q[rptr2]) ? {resp_q[rptr2].bus_resp.rdata[15:0], instr[31:16]} : {resp_i.bus_resp.rdata[15:0], instr[31:16]};


  // Unaligned uncompressed instructions are valid if index 1 is valid (index 0 will always be valid if 1 is)
  // or if we have data in index 0 AND we get a new incoming instruction
  // All other cases are valid if we have data in q0 or we get a response
  assign valid_unaligned_uncompressed = (valid_q[rptr2] || (valid_q[rptr] && resp_valid_gated));
  assign valid = valid_q[rptr] || resp_valid_gated;

  // unaligned_is_compressed and aligned_is_compressed are only defined when valid = 1 (which implies that instr_valid_o will be 1)
  // Never flag a compressed instruction (aligned or misaligned) for pointers. Otherwise one could signal instr_valid_o twice for one pointer
  // if the pointer itself looks like two compressed instructions.
  assign unaligned_is_compressed = (instr[17:16] != 2'b11) &&
                                   !(instr_is_clic_ptr_o || instr_is_mret_ptr_o || instr_is_tbljmp_ptr_o);

  assign aligned_is_compressed   = (instr[1:0] != 2'b11) &&
                                   !(instr_is_clic_ptr_o || instr_is_mret_ptr_o || instr_is_tbljmp_ptr_o);


  // Set mpu_status and bus error for unaligned instructions
  always_comb begin
    mpu_status_unaligned = MPU_OK;
    bus_err_unaligned = 1'b0;
    // There is valid data in q1 (valid q0 is implied)
    if(valid_q[rptr2]) begin
      // Not compressed, need two sources
      if(!unaligned_is_compressed) begin
        // If any entry is not ok, we have an instr_fault
        if((resp_q[rptr2].mpu_status != MPU_OK) || (resp_q[rptr].mpu_status != MPU_OK)) begin
          mpu_status_unaligned = MPU_RE_FAULT;
        end

        // Bus error from either entry
        bus_err_unaligned = (resp_q[rptr2].bus_resp.err || resp_q[rptr].bus_resp.err);
      end else begin
        // Compressed, use only mpu_status from q0
        mpu_status_unaligned = resp_q[rptr].mpu_status;

        // bus error from q0
        bus_err_unaligned    = resp_q[rptr].bus_resp.err;
      end
    end else begin
      // There is no data in q1, check q0
      if(valid_q[rptr]) begin
        if(!unaligned_is_compressed) begin
          // There is unaligned data in q0 and is it not compressed
          // use q0 and incoming data
          if((resp_q[rptr].mpu_status != MPU_OK) || (resp_i.mpu_status != MPU_OK)) begin
            mpu_status_unaligned = MPU_RE_FAULT;
          end

          // Bus error from q0 and resp_i
          bus_err_unaligned = (resp_q[rptr].bus_resp.err || resp_i.bus_resp.err);
        end else begin
          // There is unaligned data in q0 and it is compressed
          mpu_status_unaligned = resp_q[rptr].mpu_status;

          // Bus error from q0
          bus_err_unaligned = resp_q[rptr].bus_resp.err;
        end
      end else begin
        // There is no data in the buffer, use input
        mpu_status_unaligned   = resp_i.mpu_status;
        bus_err_unaligned      = resp_i.bus_resp.err;
      end
    end
  end


  // Output instructions to the if stage
  always_comb
  begin
    instr_instr_o.bus_resp.rdata = instr;
    instr_instr_o.bus_resp.err   = bus_err;
    instr_instr_o.mpu_status     = mpu_status;
    instr_valid_o = 1'b0;

    // Invalidate output if we get killed
    if (ctrl_fsm_i.kill_if) begin
      instr_valid_o = 1'b0;
    end else if (instr_addr_o[1]) begin
      // unaligned instruction
      instr_instr_o.bus_resp.rdata = instr_unaligned;
      instr_instr_o.bus_resp.err   = bus_err_unaligned;
      instr_instr_o.mpu_status     = mpu_status_unaligned;

      if (!valid) begin
        // No instruction valid
        instr_valid_o = 1'b0;
      end else if (instr_is_clic_ptr_o || instr_is_mret_ptr_o || instr_is_tbljmp_ptr_o) begin
        // currently outputting a pointer, valid whenever the response arrives or we have
        // the pointer within index 0 of the buffer.
        instr_valid_o = valid;
      end else if (unaligned_is_compressed) begin
        // Unaligned instruction is compressed, we only need 16 upper bits from index 0
        instr_valid_o = valid;
      end else begin
        // Unaligned is not compressed, we need data from either index 0 and 1, or 0 and input
        instr_valid_o = valid_unaligned_uncompressed;
      end
    end else begin
      // aligned case, contained in index 0
      instr_valid_o = valid;
    end
  end


  //////////////////////////////////////////////////////////////////////////////
  // FIFO management
  //////////////////////////////////////////////////////////////////////////////

  always_comb
  begin
    resp_n     = resp_q[wptr];
    valid_int  = valid_q;
    wptr_n     = wptr;
    // Write response and update valid bit and write pointer
    if (resp_valid_gated) begin
      // Increase write pointer, wrap to zero if at last entry
      if (wptr < (ALBUF_DEPTH-1)) begin
        wptr_n =  wptr + ALBUF_CNT_WIDTH'(1);
      end
      else begin
        wptr_n = ALBUF_CNT_WIDTH'(0);
      end

      // Set fifo and valid write data
      resp_n   = resp_i;
      valid_int[wptr] = 1'b1;
    end // resp_valid_gated
  end // always_comb

  // Calculate address increment
  assign addr_incr = {addr_q[31:2], 2'b00} + 32'h4;

  // Update address, read pointer and valid bits
  always_comb
  begin
    addr_n     = addr_q;
    valid_n    = valid_int;
    rptr_n     = rptr;
    // Next values for address, valid bits and read pointer
    if (addr_q[1]) begin
      // unaligned case
      // Set next address based on instr being compressed or not
      if (unaligned_is_compressed) begin
        addr_n = {addr_incr[31:2], 2'b00};
      end else begin
        addr_n = {addr_incr[31:2], 2'b10};
      end

      // Advance FIFO one step, wrap if at last entry
      if (rptr < (ALBUF_DEPTH-1)) begin
        rptr_n = rptr + ALBUF_CNT_WIDTH'(1);
      end
      else begin
        rptr_n = ALBUF_CNT_WIDTH'(0);
      end
    end else begin
      // aligned case
      if (aligned_is_compressed) begin
        // just increase address, do not move to next entry in FIFO
        addr_n = {addr_q[31:2], 2'b10};
      end else begin
        // move to next entry in FIFO
        // Uncompressed instruction, use addr_incr without offset
        addr_n = {addr_incr[31:2], 2'b00};

        // Advance FIFO one step, wrap if at last entry
        if (rptr < (ALBUF_DEPTH-1)) begin
          rptr_n = rptr + ALBUF_CNT_WIDTH'(1);
        end
        else begin
          rptr_n = ALBUF_CNT_WIDTH'(0);
        end
      end
    end

    // Only clear valid[rptr] if we actually emit an instruction
    if (instr_valid_o && instr_ready_i) begin
      if (addr_q[1] || (!addr_q[1] && (!aligned_is_compressed))) begin
        valid_n[rptr] = 1'b0;
      end
    end
  end

  // rptr2 will always be one higher than rptr
  always_comb begin
    if (rptr < (ALBUF_DEPTH-1)) begin
      rptr2 = rptr + ALBUF_CNT_WIDTH'(1);
    end
    else begin
      rptr2 = ALBUF_CNT_WIDTH'(0);
    end
  end

  // Counting instructions in FIFO
  always_comb begin
    instr_cnt_n = instr_cnt_q;
    n_flush_branch = outstanding_cnt_q;

    if(ctrl_fsm_i.kill_if) begin
      // FIFO content is invalidated when IF is killed
      instr_cnt_n = 'd0;

      if(resp_valid_i) begin
        n_flush_branch = outstanding_cnt_q - 2'd1;
      end
    end else begin
      // Update number of instructions
      // Subracting emitted instructions lags behind by 1 cycle
      // to break timing paths from instr_ready_i to instr_cnt_q;
      instr_cnt_n = instr_cnt_q + n_pushed_ins - (pop_q ? ALBUF_CNT_WIDTH'(1) : ALBUF_CNT_WIDTH'(0));
    end
  end

  // Counting number of outstanding transactions
  assign outstanding_count_up   = fetch_valid_o && fetch_ready_i;    // Increment upon accepted transfer request
  assign outstanding_count_down = resp_valid_i;                   // Decrement upon accepted transfer response

  always_comb begin
    outstanding_cnt_n = outstanding_cnt_q;
    case ({outstanding_count_up, outstanding_count_down})
      2'b00 : begin
        outstanding_cnt_n = outstanding_cnt_q;
      end
      2'b01 : begin
        outstanding_cnt_n = outstanding_cnt_q - 1'b1;
      end
      2'b10 : begin
        outstanding_cnt_n = outstanding_cnt_q + 1'b1;
      end
      2'b11 : begin
        outstanding_cnt_n = outstanding_cnt_q;
      end
      default;
    endcase
  end


  // Count number of incoming instructions in resp_data
  // This can also be done by inspecting the fifo content
  always_comb begin
    // Set default values
    aligned_n = aligned_q;
    complete_n = complete_q;
    n_incoming_ins = 2'd0;

    // On a branch we need to know if it is aligned or not
    // the complete flag will be special cased for unaligned branches
    // as aligned=0 and complete=1 can only happen in that case
    if(ctrl_fsm_i.pc_set) begin
      aligned_n = !branch_addr_i[1];
      complete_n = branch_addr_i[1];
    end else begin
      // Valid response
      if(resp_valid_gated) begin
        // We are on an aligned address
        if(aligned_q) begin
          // uncompressed in rdata
          if(resp_i.bus_resp.rdata[1:0] == 2'b11) begin
            n_incoming_ins = 2'd1;
            // Still aligned and complete, no need to update
          end else begin
            // compressed in lower part, check next halfword
            if(resp_i.bus_resp.rdata[17:16] == 2'b11) begin
              // Upper half is uncompressed, not complete
              // 1 complete insn
              n_incoming_ins = 2'd1;
              // Not aligned nor complete, as upper 16 bits are uncompressed
              aligned_n = 1'b0;
              complete_n = 1'b0;
            end else begin
              // Another compressed in upper half
              // two complete insn in word, still aligned and complete
              n_incoming_ins = 2'd2;
              aligned_n = 1'b1;
              complete_n = 1'b1;
            end
          end
        // We are on ann unaligned address
        end else begin
          // Unaligned and complete_q==1 can only happen
          // for unaligned branches, signalling that lower
          // 16 bits can be discarded
          if(complete_q) begin
            // Uncompressed unaligned
            if(resp_i.bus_resp.rdata[17:16] == 2'b11) begin
              // No complete ins in data
              n_incoming_ins = 2'd0;
              // Still unaligned
              aligned_n = 1'b0;
              // Not a complete instruction
              complete_n = 1'b0;
            end else begin
              // Compressed unaligned
              // We have one insn in upper 16 bits
              n_incoming_ins = 2'd1;
              // We become aligned
              aligned_n = 1'b1;
              // Complete instruction
              complete_n = 1'b1;
            end
          end else begin
            // Incomplete. Check upper 16 bits for content
            // Implied that lower 16 bits contain the MSBs
            // of an uncompressed instruction
            if(resp_i.bus_resp.rdata[17:16] == 2'b11) begin
              // Upper 16 is uncompressed
              // 1 complete insn in word
              n_incoming_ins = 2'd1;
              // Unaligned and not complete
              aligned_n = 1'b0;
              complete_n = 1'b0;
            end else begin
              // Compressed unaligned
              // Two complete insn in word
              // Aligned and complete
              n_incoming_ins = 2'd2;
              aligned_n = 1'b1;
              complete_n = 1'b1;
            end // rdata[17:16]
          end // complete_q
        end // aligned_q
      end // resp_valid_gated
    end // branch
  end // comb


  // number of resps to flush
  always_comb
  begin
    // Default value
    n_flush_n = n_flush_q;

    // On a branch, the counter logic will calculate
    // the number of words to flush
    if(ctrl_fsm_i.pc_set) begin
      n_flush_n = n_flush_branch;
    end else begin
      // Decrement flush counter on valid inputs
      if(resp_valid_i && (n_flush_q > 0)) begin
        n_flush_n = n_flush_q - 2'b01;
      end
    end
  end
  //////////////////////////////////////////////////////////////////////////////
  // registers
  //////////////////////////////////////////////////////////////////////////////

  always_ff @(posedge clk, negedge rst_n)
  begin
    if(rst_n == 1'b0)
    begin
      addr_q            <= '0;
      resp_q            <= INST_RESP_RESET_VAL;
      valid_q           <= '0;
      aligned_q         <= 1'b0;
      complete_q        <= 1'b0;
      n_flush_q         <= 'd0;
      instr_cnt_q       <= 'd0;
      outstanding_cnt_q <= 'd0;
      rptr              <= 'd0;
      wptr              <= 'd0;
      pop_q             <= 1'b0;
      is_clic_ptr_q     <= 1'b0;
      is_mret_ptr_q     <= 1'b0;
      is_tbljmp_ptr_q   <= 1'b0;
      ptr_fetch_accepted_q  <= 1'b0;
    end
    else
    begin
      // on a kill signal from outside we invalidate the content of the FIFO
      // completely and start from an empty state
      if (ctrl_fsm_i.kill_if) begin
        valid_q <= '0;
      end else begin
        // Update FIFO content on a valid response
        if (resp_valid_gated) begin
          resp_q[wptr] <= resp_n;
        end

        // Update valid bits on both bus resp and instruction output
        if((instr_valid_o && instr_ready_i) || resp_valid_gated) begin
          valid_q <= valid_n;
        end
      end

      // Update address and read/write pointers on a requested branch
      // Incoming pointers for CLIC and Zc may cause the pointers to get wrong values
      // We do however prevent further fetches after a pointer fetch, and the pointers
      // will be reset on the next pc_set (jump to target)
      if (ctrl_fsm_i.pc_set) begin
        addr_q  <= branch_addr_i;       // Branch target address will correspond to first instruction received after this.
        // Reset pointers on branch
        wptr <= 'd0;
        rptr <= 'd0;
        is_clic_ptr_q <= ctrl_fsm_i.pc_set_clicv && (ctrl_fsm_i.pc_mux == PC_TRAP_CLICV);
        is_mret_ptr_q <= ctrl_fsm_i.pc_set_clicv && (ctrl_fsm_i.pc_mux == PC_MRET); // Only set when an mret restarts pointer fetch. Used to manipulate first_op/last_op
        is_tbljmp_ptr_q <= ctrl_fsm_i.pc_set_tbljmp;
      end else begin
        // Update write pointer on a valid response
        if (resp_valid_gated) begin
          wptr <= wptr_n;
        end

        // Update address and read pointer when we emit an instruction
        if(instr_valid_o && instr_ready_i) begin
          addr_q <= addr_n;
          rptr   <= rptr_n;

          // Clear pointer flags when pointers are consumed.
          is_clic_ptr_q     <= 1'b0;
          is_mret_ptr_q     <= 1'b0;
          is_tbljmp_ptr_q   <= 1'b0;
        end
      end

      if(fetch_valid_o && fetch_ready_i && fetch_ptr_access_i) begin
        ptr_fetch_accepted_q <= 1'b1;
      end else begin
        if(ctrl_fsm_i.pc_set) begin
          ptr_fetch_accepted_q <= 1'b0;
        end
      end
      // Set pop-bit when instruction is emitted.
      pop_q <= (instr_valid_o && instr_ready_i);

      aligned_q <= aligned_n;
      complete_q <= complete_n;
      n_flush_q <= n_flush_n;
      instr_cnt_q <= instr_cnt_n;
      outstanding_cnt_q <= outstanding_cnt_n;
    end
  end

  // Output outstanding transaction counter to if_stage
  assign outstnd_cnt_q_o = outstanding_cnt_q;

  // Output instruction address to if_stage
  assign instr_addr_o = addr_q;

  // Signal that result is a CLIC pointer
  assign instr_is_clic_ptr_o   = is_clic_ptr_q;

  // Signal that result is an mret pointer
  assign instr_is_mret_ptr_o   = is_mret_ptr_q;

  // Signal that result is a table jump pointer
  assign instr_is_tbljmp_ptr_o = is_tbljmp_ptr_q;

  // Signal that a pointer is about to be fetched
  assign fetch_ptr_access_o = (ctrl_fsm_i.pc_set && (ctrl_fsm_i.pc_set_clicv || ctrl_fsm_i.pc_set_tbljmp));

  // Set privilege level to prefetcher
  // Privilege level must be updated immediatly to allow the
  // IF stage to do access permission checks with the correct privilege level
  //
  // When an mret is in the ID stage, a jump is performed and the privilege level may be changed.
  // When the privilege level changes, priv_lvl_ctrl_i.priv_lvl_set is 1, and the new privilege level
  // is visible on priv_lvl_ctrl_i.priv_lvl. When priv_lvl_set is 0, the privilege level
  // as seen from the WB stage (flop output) is visible on priv_lvl_ctrl_i.priv_lvl.
  //
  // This means that in the time between the mret jump and privilege level change in ID and the time when
  // the mret retires in WB, the old privilege level is visible on pvi_lvl_ctrl_i.priv_lvl.
  // To ensure the correct privilege level for prefetches, the alignment_buffer remembers the last commanded
  // privilege level in the instr_priv_lvl_q flops.
  assign fetch_priv_lvl_o = priv_lvl_ctrl_i.priv_lvl_set ? priv_lvl_ctrl_i.priv_lvl:
                            instr_priv_lvl_q;

  // Privilege level for the IF stage
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      instr_priv_lvl_q <= PRIV_LVL_M;
    end
    else begin
      if (priv_lvl_ctrl_i.priv_lvl_set) begin
        instr_priv_lvl_q <= priv_lvl_ctrl_i.priv_lvl;
      end
    end
  end

  // Set privilege level to IF stage
  assign instr_priv_lvl_o = fetch_priv_lvl_i;
endmodule






// Description:    Prefetch unit that prefetches instructions and store them  //
//                 in a buffer that extracts compressed and uncompressed      //
//                 instructions.                                              //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

// input port: send address one cycle before the data
// clear_i clears the FIFO for the following cycle. in_addr_i can be sent in
// this cycle already

module cv32e40x_prefetch_unit import cv32e40x_pkg::*;
#(
    parameter bit CLIC                     = 1'b0,
    parameter int unsigned ALBUF_DEPTH     = 3,
    parameter int unsigned ALBUF_CNT_WIDTH = $clog2(ALBUF_DEPTH)
)
(
  input  logic        clk,
  input  logic        rst_n,

  input  ctrl_fsm_t   ctrl_fsm_i,
  input  privlvlctrl_t priv_lvl_ctrl_i,

  input  logic [31:0] branch_addr_i,

  input  logic        prefetch_ready_i,
  output logic        prefetch_valid_o,
  output inst_resp_t  prefetch_instr_o,
  output logic [31:0] prefetch_addr_o,
  output privlvl_t    prefetch_priv_lvl_o,
  output logic        prefetch_is_clic_ptr_o,
  output logic        prefetch_is_mret_ptr_o,
  output logic        prefetch_is_tbljmp_ptr_o,

  // Transaction interface to obi interface
  output logic        trans_valid_o,
  input  logic        trans_ready_i,
  output logic [31:0] trans_addr_o,

  input  logic        resp_valid_i,
  input  inst_resp_t  resp_i,

  output logic                       one_txn_pend_n,
  output logic [ALBUF_CNT_WIDTH-1:0] outstnd_cnt_q_o,

  // Prefetch Buffer Status
  output logic        prefetch_busy_o
);

  logic fetch_valid;
  logic fetch_ready;

  logic        fetch_branch;
  logic [31:0] fetch_branch_addr;
  logic        fetch_ptr_access;
  logic        fetch_ptr_resp;
  privlvl_t    fetch_priv_lvl_access;
  privlvl_t    fetch_priv_lvl_resp;



  //////////////////////////////////////////////////////////////////////////////
  // Prefetcher
  //////////////////////////////////////////////////////////////////////////////

  cv32e40x_prefetcher
  #(
      .CLIC  (CLIC)
  )
  prefetcher_i
  (
    .clk                      ( clk                  ),
    .rst_n                    ( rst_n                ),

    .fetch_branch_i           ( fetch_branch         ),
    .fetch_branch_addr_i      ( fetch_branch_addr    ),
    .fetch_valid_i            ( fetch_valid          ),
    .fetch_ready_o            ( fetch_ready          ),
    .fetch_ptr_access_i       ( fetch_ptr_access     ),
    .fetch_ptr_access_o       ( fetch_ptr_resp       ),
    .fetch_priv_lvl_access_i  ( fetch_priv_lvl_access),
    .fetch_priv_lvl_access_o  ( fetch_priv_lvl_resp  ),
    .trans_valid_o            ( trans_valid_o        ),
    .trans_ready_i            ( trans_ready_i        ),
    .trans_addr_o             ( trans_addr_o         )
  );


  cv32e40x_alignment_buffer
  #(
    .ALBUF_DEPTH(ALBUF_DEPTH),
    .ALBUF_CNT_WIDTH(ALBUF_CNT_WIDTH)
  )
  alignment_buffer_i
  (
    .clk                   ( clk                     ),
    .rst_n                 ( rst_n                   ),

    .ctrl_fsm_i            ( ctrl_fsm_i              ),
    .priv_lvl_ctrl_i       ( priv_lvl_ctrl_i         ),

    .branch_addr_i         ( branch_addr_i           ),
    .prefetch_busy_o       ( prefetch_busy_o         ),

    // prefetch unit
    .fetch_valid_o         ( fetch_valid             ),
    .fetch_ready_i         ( fetch_ready             ),
    .fetch_branch_o        ( fetch_branch            ),
    .fetch_branch_addr_o   ( fetch_branch_addr       ),
    .fetch_ptr_access_o    ( fetch_ptr_access        ),
    .fetch_ptr_access_i    ( fetch_ptr_resp          ),
    .fetch_priv_lvl_o      ( fetch_priv_lvl_access   ),
    .fetch_priv_lvl_i      ( fetch_priv_lvl_resp     ),

    .resp_valid_i          ( resp_valid_i            ),
    .resp_i                ( resp_i                  ),
    .one_txn_pend_n        ( one_txn_pend_n          ),
    .outstnd_cnt_q_o       ( outstnd_cnt_q_o         ),

    // Instruction interface
    .instr_valid_o         ( prefetch_valid_o        ),
    .instr_ready_i         ( prefetch_ready_i        ),
    .instr_instr_o         ( prefetch_instr_o        ),
    .instr_addr_o          ( prefetch_addr_o         ),
    .instr_priv_lvl_o      ( prefetch_priv_lvl_o     ),
    .instr_is_clic_ptr_o   ( prefetch_is_clic_ptr_o  ),
    .instr_is_mret_ptr_o   ( prefetch_is_mret_ptr_o  ),
    .instr_is_tbljmp_ptr_o ( prefetch_is_tbljmp_ptr_o)

  );

endmodule






// Description:    PMA (Physical Memory Attribution)                          //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_pma import cv32e40x_pkg::*;
#(
  parameter a_ext_e      A_EXT = A_NONE,
  parameter int          PMA_NUM_REGIONS = 0,
  parameter pma_cfg_t    PMA_CFG[PMA_NUM_REGIONS-1:0] = '{default:PMA_R_DEFAULT}
)
(
  input  logic [31:0] trans_addr_i,
  input  logic        trans_debug_region_i, // Transaction address is inside the debug region
  input  logic        trans_pushpop_i,      // Transaction is part of a PUSH or POP sequence
  input  logic        instr_fetch_access_i, // Indicate that ongoing access is an instruction fetch
  input  logic        atomic_access_i,      // Indicate that ongoing access is atomic
  input  logic        misaligned_access_i,  // Indicate that ongoing access is part of a misaligned access
  input  logic        modified_access_i,    // Indicate that ongoing access is part of a modified access
  input  logic        load_access_i,        // Indicate that ongoing access is a load
  output logic        pma_err_o,
  output logic        pma_bufferable_o,
  output logic        pma_cacheable_o
);

  // Attributes for accessing the DM (DM_REGION_START:DM_REGION_END) in debug mode
  localparam pma_cfg_t PMA_DBG = '{word_addr_low   : '0, // not used
                                   word_addr_high  : '0, // not used
                                   main            : 1'b1,
                                   bufferable      : 1'b0,
                                   cacheable       : 1'b0,
                                   atomic          : 1'b0};


  pma_cfg_t pma_cfg;
  logic [31:0] word_addr;
  logic pma_cfg_atomic;

  // PMA addresses are word addresses
  assign word_addr = {2'b00, trans_addr_i[31:2]};

  generate
    if(PMA_NUM_REGIONS == 0) begin: no_pma

      always_comb begin
        // PMA is deconfigured, use NO_PMA_R_DEFAULT as default.
        pma_cfg = NO_PMA_R_DEFAULT;

        // Debug mode transactions within the Debug Module region use PMA_DBG as attributes for the DM range
        if (trans_debug_region_i) begin
          pma_cfg = PMA_DBG;
        end
      end

    end
    else begin: pma

      // Identify PMA region
      always_comb begin

        // If no match, use default PMA config as default.
        pma_cfg = PMA_R_DEFAULT;

        for(int i = PMA_NUM_REGIONS-1; i >= 0; i--)  begin
          if((word_addr >= PMA_CFG[i].word_addr_low) &&
             (word_addr <  PMA_CFG[i].word_addr_high)) begin
            pma_cfg = PMA_CFG[i];
          end
        end

        // Debug mode transactions within the Debug Module region use PMA_DBG as attributes for the DM range
        if (trans_debug_region_i) begin
          pma_cfg = PMA_DBG;
        end
      end
    end

  endgenerate

  // Tie of atomic attribute if A_EXT=0
  generate
    if (A_EXT) begin: pma_atomic
      assign pma_cfg_atomic = pma_cfg.atomic;
    end
    else begin: pma_no_atomic
      assign pma_cfg_atomic = 1'b0;
    end
  endgenerate

  // Check transaction based on PMA region config
  always_comb begin

    pma_err_o = 1'b0;

    // Check for atomic access
    if (atomic_access_i && !pma_cfg_atomic) begin
      pma_err_o = 1'b1;
    end

    // Instruction fetches only allowed in main memory
    if (instr_fetch_access_i && !pma_cfg.main) begin
      pma_err_o   = 1'b1;
    end

    // Misaligned or modified access to I/O memory
    if ((misaligned_access_i || modified_access_i) && !pma_cfg.main) begin
      pma_err_o   = 1'b1;
    end

    // PUSH/POP outside of main is not allowed
    if (trans_pushpop_i && !pma_cfg.main) begin
      pma_err_o   = 1'b1;
    end
  end

  // Set cacheable and bufferable based on PMA region attributes
  // Instruction fetches, atomic operations and loads are never classified as bufferable
  assign pma_bufferable_o = pma_cfg.bufferable && !instr_fetch_access_i && !atomic_access_i && !load_access_i;
  assign pma_cacheable_o  = pma_cfg.cacheable;

endmodule




// Description:    MPU (Memory Protection Unit)                               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_mpu import cv32e40x_pkg::*;
  #(  parameter bit          IF_STAGE                     = 1,
      parameter a_ext_e      A_EXT                        = A_NONE,
      parameter type         CORE_REQ_TYPE                = obi_inst_req_t,
      parameter type         CORE_RESP_TYPE               = inst_resp_t,
      parameter type         BUS_RESP_TYPE                = data_resp_t,
      parameter int          PMA_NUM_REGIONS              = 0,
      parameter pma_cfg_t    PMA_CFG[PMA_NUM_REGIONS-1:0] = '{default:PMA_R_DEFAULT},
      parameter bit          DEBUG                        = 1,
      parameter logic [31:0] DM_REGION_START              = 32'hF0000000,
      parameter logic [31:0] DM_REGION_END                = 32'hF0003FFF)
  (
   input logic  clk,
   input logic  rst_n,

   input logic  atomic_access_i,     // Indicate that ongoing access is atomic
   input logic  misaligned_access_i, // Indicate that ongoing access is part of a misaligned access
   input logic  modified_access_i,   // Indicate that ongoing access is part of a modified access

   // Interface towards bus interface
   input logic  bus_trans_ready_i,
   output logic bus_trans_valid_o,
   output       CORE_REQ_TYPE bus_trans_o,

   input logic  bus_resp_valid_i,
   input        BUS_RESP_TYPE bus_resp_i,

   // Interface towards core
   input logic  core_trans_valid_i,
   input logic  core_trans_pushpop_i,
   output logic core_trans_ready_o,
   input        CORE_REQ_TYPE core_trans_i,

   output logic core_resp_valid_o,
   output       CORE_RESP_TYPE core_resp_o,

   // Indication from the core that there will be one pending transaction in the next cycle
   input logic  core_one_txn_pend_n,

   // Indication from the core that MPU errors should be reported after all in flight transactions
   // are complete (default behavior for main core requests, but not used for XIF requests)
   input logic  core_mpu_err_wait_i,

   // Report MPU errors to the core immediatly (used in case core_mpu_err_wait_i is not asserted)
   output logic core_mpu_err_o
   );

  logic        pma_err;
  logic        mpu_err;
  logic        mpu_block_core;
  logic        mpu_block_bus;
  logic        mpu_err_trans_valid;
  logic        mpu_err_trans_ready;
  mpu_status_e mpu_status;
  mpu_state_e  state_q, state_n;
  logic        bus_trans_cacheable;
  logic        bus_trans_bufferable;
  logic        core_trans_we;
  logic        instr_fetch_access;
  logic        load_access;
  logic        core_trans_debug_region;

  // Detect a debug mode transaction to the Debug Module region
  assign core_trans_debug_region = (core_trans_i.addr >= DM_REGION_START) && (core_trans_i.addr <= DM_REGION_END) && core_trans_i.dbg;

  // FSM that will "consume" transfers failing PMA checks.
  // Upon failing checks, this FSM will prevent the transfer from going out on the bus
  // and wait for all in flight bus transactions to complete while blocking new transfers.
  // When all in flight transactions are complete, it will respond with the correct status before
  // allowing new transfers to go through.
  // The input signal core_one_txn_pend_n indicates that there, from the core's point of view,
  // will be one pending transaction in the next cycle. Upon MPU error, this transaction
  // will be completed by this FSM
  always_comb begin

    state_n             = state_q;
    mpu_status          = MPU_OK;
    mpu_block_core      = 1'b0;
    mpu_block_bus       = 1'b0;
    mpu_err_trans_valid = 1'b0;
    mpu_err_trans_ready = 1'b0;

    case(state_q)
      MPU_IDLE: begin
        if (mpu_err && core_trans_valid_i) begin

          // Block transfer from going out on the bus.
          mpu_block_bus  = 1'b1;

          // Signal to the core that the transfer was accepted (but will be consumed by the MPU)
          mpu_err_trans_ready = 1'b1;

          if (core_mpu_err_wait_i) begin
            if(core_trans_we) begin
              // MPU error on write
              state_n = core_one_txn_pend_n ? MPU_WR_ERR_RESP : MPU_WR_ERR_WAIT;
            end
            else begin
              // MPU error on read
              state_n = core_one_txn_pend_n ? MPU_RE_ERR_RESP : MPU_RE_ERR_WAIT;
            end
          end

        end
      end
      MPU_RE_ERR_WAIT, MPU_WR_ERR_WAIT: begin

        // Block new transfers while waiting for in flight transfers to complete
        mpu_block_bus  = 1'b1;
        mpu_block_core = 1'b1;

        if (core_one_txn_pend_n) begin
          state_n = (state_q == MPU_RE_ERR_WAIT) ? MPU_RE_ERR_RESP : MPU_WR_ERR_RESP;
        end
      end
      MPU_RE_ERR_RESP, MPU_WR_ERR_RESP: begin

        // Keep blocking new transfers
        mpu_block_bus  = 1'b1;
        mpu_block_core = 1'b1;

        // Set up MPU error response towards the core
        mpu_err_trans_valid = 1'b1;
        mpu_status = (state_q == MPU_RE_ERR_RESP) ? MPU_RE_FAULT : MPU_WR_FAULT;
        // Go back to IDLE uncoditionally.
        // The core is expected to always be ready for the response
        state_n = MPU_IDLE;

      end
      default: ;
    endcase
  end

  always_ff @(posedge clk, negedge rst_n) begin
    if (rst_n == 1'b0) begin
      state_q     <= MPU_IDLE;
    end
    else begin
      state_q <= state_n;
    end
  end

  // Forward transaction request towards bus interface
  assign bus_trans_valid_o = core_trans_valid_i && !mpu_block_bus;

  always_comb begin
    bus_trans_o            = core_trans_i;
    bus_trans_o.memtype[0] = bus_trans_bufferable;
    bus_trans_o.memtype[1] = bus_trans_cacheable;
  end

  // Forward transaction response towards core
  assign core_resp_valid_o      = bus_resp_valid_i || mpu_err_trans_valid;
  assign core_resp_o.mpu_status = mpu_status;


  // Report MPU errors to the core immediately
  assign core_mpu_err_o = mpu_err;

  // Signal ready towards core
  assign core_trans_ready_o     = (bus_trans_ready_i && !mpu_block_core) || mpu_err_trans_ready;

  // PMA - Physical Memory Attribution
  cv32e40x_pma
  #(
    .A_EXT                      ( A_EXT                   ),
    .PMA_NUM_REGIONS            ( PMA_NUM_REGIONS         ),
    .PMA_CFG                    ( PMA_CFG                 )
  )
  pma_i
    (
    .trans_addr_i               ( core_trans_i.addr       ),
    .trans_debug_region_i       ( core_trans_debug_region ),
    .trans_pushpop_i            ( core_trans_pushpop_i    ),
    .instr_fetch_access_i       ( instr_fetch_access      ),
    .atomic_access_i            ( atomic_access_i         ),
    .misaligned_access_i        ( misaligned_access_i     ),
    .modified_access_i          ( modified_access_i       ),
    .load_access_i              ( load_access             ),
    .pma_err_o                  ( pma_err                 ),
    .pma_bufferable_o           ( bus_trans_bufferable    ),
    .pma_cacheable_o            ( bus_trans_cacheable     )
  );

  assign mpu_err = pma_err;

  // Writes are only supported on the data interface
  // Tie to 1'b0 if this MPU is instantiatied in the IF stage
  generate
    if (IF_STAGE) begin: mpu_if
      assign instr_fetch_access     = 1'b1;
      assign load_access            = 1'b0;
      assign core_trans_we          = 1'b0;
      assign core_resp_o.bus_resp   = bus_resp_i;
    end
    else begin: mpu_lsu
      assign instr_fetch_access       = 1'b0;
      assign load_access              = !core_trans_i.we;
      assign core_trans_we            = core_trans_i.we;
      assign core_resp_o.wpt_match    = '0; // Will be set by upstream wpt-module within load_store_unit
      assign core_resp_o.align_status = bus_resp_i.align_status;
      assign core_resp_o.bus_resp     = bus_resp_i.bus_resp;
    end
  endgenerate

endmodule


// Description:    Open Bus Interface adapter. Translates transaction request //
//                 on the trans_* interface into an OBI A channel transfer.   //
//                 The OBI R channel transfer translated (i.e. passed on) as  //
//                 a transaction response on the resp_* interface.            //
//                                                                            //
//                 This adapter does not limit the number of outstanding      //
//                 OBI transactions in any way.                               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_instr_obi_interface import cv32e40x_pkg::*;
(
  input  logic           clk,
  input  logic           rst_n,

  // Transaction request interface
  input  logic           trans_valid_i,
  output logic           trans_ready_o,
  input  obi_inst_req_t  trans_i,

  // Transaction response interface
  output logic           resp_valid_o,             // Note: Consumer is assumed to be 'ready' whenever resp_valid_o = 1
  output obi_inst_resp_t resp_o,

  // OBI interface
  cv32e40x_if_c_obi.master m_c_obi_instr_if

);

  obi_if_state_e state_q, next_state;

  //////////////////////////////////////////////////////////////////////////////
  // OBI R Channel
  //////////////////////////////////////////////////////////////////////////////

  // The OBI R channel signals are passed on directly on the transaction response
  // interface (resp_*). It is assumed that the consumer of the transaction response
  // is always receptive when resp_valid_o = 1 (otherwise a response would get dropped)

  assign resp_valid_o = m_c_obi_instr_if.s_rvalid.rvalid;
  assign resp_o       = m_c_obi_instr_if.resp_payload;
  


  //////////////////////////////////////////////////////////////////////////////
  // OBI A Channel
  //////////////////////////////////////////////////////////////////////////////

  
  // OBI A channel registers (to keep A channel stable)
  obi_inst_req_t        obi_a_req_q;

  // If the incoming transaction itself is not stable; use an FSM to make sure that
  // the OBI address phase signals are kept stable during non-granted requests.

  //////////////////////////////////////////////////////////////////////////////
  // OBI FSM
  //////////////////////////////////////////////////////////////////////////////

  // FSM (state_q, next_state) to control OBI A channel signals.

  always_comb
  begin
    next_state = state_q;

    case(state_q)

      // Default (transparent) state. Transaction requests are passed directly onto the OBI A channel.
      TRANSPARENT:
      begin
        if (m_c_obi_instr_if.s_req.req && !m_c_obi_instr_if.s_gnt.gnt) begin
          // OBI request not immediately granted. Move to REGISTERED state such that OBI address phase
          // signals can be kept stable while the transaction request (trans_*) can possibly change.
          next_state = REGISTERED;
        end
      end // case: TRANSPARENT

      // Registered state. OBI address phase signals are kept stable (driven from registers).
      REGISTERED:
      begin
        if (m_c_obi_instr_if.s_gnt.gnt) begin
          // Received grant. Move back to TRANSPARENT state such that next transaction request can be passed on.
          next_state = TRANSPARENT;
        end
      end // case: REGISTERED
      default: ;
    endcase
  end

  always_comb
  begin
    if (state_q == TRANSPARENT) begin
      m_c_obi_instr_if.s_req.req   = trans_valid_i;              // Do not limit number of outstanding transactions
      m_c_obi_instr_if.req_payload = trans_i;
    end else begin
      // state_q == REGISTERED
      m_c_obi_instr_if.s_req.req   = 1'b1;                       // Never retract request
      m_c_obi_instr_if.req_payload = obi_a_req_q;
    end
  end

  //////////////////////////////////////////////////////////////////////////////
  // Registers
  //////////////////////////////////////////////////////////////////////////////

  always_ff @(posedge clk, negedge rst_n)
  begin
    if(rst_n == 1'b0)
    begin
      state_q       <= TRANSPARENT;
      obi_a_req_q   <= OBI_INST_REQ_RESET_VAL;
    end
    else
    begin
      state_q       <= next_state;
      if ((state_q == TRANSPARENT) && (next_state == REGISTERED)) begin
        // Keep OBI A channel signals stable throughout REGISTERED state
        obi_a_req_q <= m_c_obi_instr_if.req_payload;
      end
    end
  end

  // Always ready to accept a new transfer requests when previous A channel
  // transfer has been granted. Note that cv32e40x_obi_interface does not limit
  // the number of outstanding transactions in any way.
  assign trans_ready_o = (state_q == TRANSPARENT);

endmodule





// Description:    Decodes RISC-V compressed instructions into their RV32     //
//                 equivalent. This module is fully combinatorial.            //
//                 Float extensions added                                     //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_compressed_decoder import cv32e40x_pkg::*;
#(
    parameter bit          ZC_EXT    = 0,
    parameter b_ext_e      B_EXT     = B_NONE,
    parameter m_ext_e      M_EXT     = M_NONE
 )
(
  input  inst_resp_t  instr_i,
  input  logic        instr_is_ptr_i,
  output inst_resp_t  instr_o,
  output logic        is_compressed_o,
  output logic        illegal_instr_o
);

  logic [31:0] instr;

  assign instr = instr_i.bus_resp.rdata;
  //////////////////////////////////////////////////////////////////////////////////////////////////////
  //   ____                                                 _   ____                     _            //
  //  / ___|___  _ __ ___  _ __  _ __ ___  ___ ___  ___  __| | |  _ \  ___  ___ ___   __| | ___ _ __  //
  // | |   / _ \| '_ ` _ \| '_ \| '__/ _ \/ __/ __|/ _ \/ _` | | | | |/ _ \/ __/ _ \ / _` |/ _ \ '__| //
  // | |__| (_) | | | | | | |_) | | |  __/\__ \__ \  __/ (_| | | |_| |  __/ (_| (_) | (_| |  __/ |    //
  //  \____\___/|_| |_| |_| .__/|_|  \___||___/___/\___|\__,_| |____/ \___|\___\___/ \__,_|\___|_|    //
  //                      |_|                                                                         //
  //////////////////////////////////////////////////////////////////////////////////////////////////////

  always_comb
  begin
    illegal_instr_o  = 1'b0;
    instr_o          = instr_i;

    if (instr_is_ptr_i) begin
      is_compressed_o = 1'b0;
    end else begin
      is_compressed_o = (instr[1:0] != 2'b11);
      unique case (instr[1:0])
        // C0
        2'b00: begin
          unique case (instr[15:13])
            3'b000: begin
              // c.addi4spn -> addi rd', x2, imm
              instr_o.bus_resp.rdata = {2'b0, instr[10:7], instr[12:11], instr[5], instr[6], 2'b00, 5'h02, 3'b000, 2'b01, instr[4:2], OPCODE_OPIMM};
              if (instr[12:5] == 8'b0) begin
                illegal_instr_o = 1'b1;
              end
            end

            3'b010: begin
              // c.lw -> lw rd', imm(rs1')
              instr_o.bus_resp.rdata = {5'b0, instr[5], instr[12:10], instr[6], 2'b00, 2'b01, instr[9:7], 3'b010, 2'b01, instr[4:2], OPCODE_LOAD};
            end

            3'b110: begin
              // c.sw -> sw rs2', imm(rs1')
              instr_o.bus_resp.rdata = {5'b0, instr[5], instr[12], 2'b01, instr[4:2], 2'b01, instr[9:7], 3'b010, instr[11:10], instr[6], 2'b00, OPCODE_STORE};
            end


            3'b100: begin
              if (ZC_EXT) begin
                unique case (instr[12:10])
                  3'b000: begin
                    // c.lbu -> lbu rd', imm(rs1')
                    instr_o.bus_resp.rdata = {10'b0, instr[5], instr[6], 2'b01, instr[9:7], 3'b100, 2'b01, instr[4:2], OPCODE_LOAD};
                  end
                  3'b001: begin
                    // c.lh  -> lh rd', imm(rs1')
                    // c.lhu -> lhu rd', imm(rs1')
                    // instr[6] determines sign extension for lh vs lhu
                    instr_o.bus_resp.rdata = {10'b0, instr[5], 1'b0, 2'b01, instr[9:7], !instr[6], 2'b01, 2'b01, instr[4:2], OPCODE_LOAD};
                  end
                  3'b010: begin
                    // c.sb -> sb rs2', imm(rs1')
                    instr_o.bus_resp.rdata = {7'b0, 2'b01, instr[4:2], 2'b01, instr[9:7], 3'b000, 3'b000, instr[5], instr[6], OPCODE_STORE};
                  end
                  3'b011: begin
                    // c.sh -> sh rs2', imm(rs1')
                    instr_o.bus_resp.rdata = {7'b0, 2'b01, instr[4:2], 2'b01, instr[9:7], 3'b001, 3'b000, instr[5], 1'b0, OPCODE_STORE};

                    if (instr[6]) begin
                      illegal_instr_o = 1'b1;
                    end
                  end
                  default: begin
                    illegal_instr_o = 1'b1;
                    instr_o.bus_resp.rdata = {7'b0, 2'b01, instr[4:2], 2'b01, instr[9:7], 3'b001, 3'b000, instr[5], 1'b0, OPCODE_STORE};
                  end
                endcase
              end else begin
                illegal_instr_o = 1'b1;
                instr_o.bus_resp.rdata = {5'b0, instr[5], instr[12:10], instr[6], 2'b00, 2'b01, instr[9:7], 3'b010, 2'b01, instr[4:2], OPCODE_LOAD};
              end
            end

            3'b001,
            3'b011,       // c.flw -> flw rd', imm(rs1')
            3'b101,
            3'b111: begin // c.fsw -> fsw rs2', imm(rs1')
              illegal_instr_o = 1'b1;
              instr_o.bus_resp.rdata = {5'b0, instr[5], instr[12:10], instr[6], 2'b00, 2'b01, instr[9:7], 3'b010, 2'b01, instr[4:2], OPCODE_LOAD};
            end
            default: begin
              instr_o.bus_resp.rdata = {5'b0, instr[5], instr[12:10], instr[6], 2'b00, 2'b01, instr[9:7], 3'b010, 2'b01, instr[4:2], OPCODE_LOAD};
              illegal_instr_o = 1'b1;
            end
          endcase
        end


        // C1
        2'b01: begin
          unique case (instr[15:13])
            3'b000: begin
              // c.addi -> addi rd, rd, nzimm
              // c.nop
              instr_o.bus_resp.rdata = {{6 {instr[12]}}, instr[12], instr[6:2], instr[11:7], 3'b0, instr[11:7], OPCODE_OPIMM};
            end

            3'b001, 3'b101: begin
              // 001: c.jal -> jal x1, imm
              // 101: c.j   -> jal x0, imm
              instr_o.bus_resp.rdata = {instr[12], instr[8], instr[10:9], instr[6], instr[7], instr[2], instr[11], instr[5:3], {9 {instr[12]}}, 4'b0, !instr[15], OPCODE_JAL};
            end

            3'b010: begin
              if (instr[11:7] == 5'b0) begin
                // Hint -> addi x0, x0, nzimm
                instr_o.bus_resp.rdata = {{6 {instr[12]}}, instr[12], instr[6:2], 5'b0, 3'b0, instr[11:7], OPCODE_OPIMM};
              end else begin
                // c.li -> addi rd, x0, nzimm
                instr_o.bus_resp.rdata = {{6 {instr[12]}}, instr[12], instr[6:2], 5'b0, 3'b0, instr[11:7], OPCODE_OPIMM};
              end
            end

            3'b011: begin
              if ({instr[12], instr[6:2]} == 6'b0) begin
                instr_o.bus_resp.rdata = {{15 {instr[12]}}, instr[6:2], instr[11:7], OPCODE_LUI};
                illegal_instr_o = 1'b1;
              end else begin
                if (instr[11:7] == 5'h02) begin
                  // c.addi16sp -> addi x2, x2, nzimm
                  instr_o.bus_resp.rdata = {{3 {instr[12]}}, instr[4:3], instr[5], instr[2], instr[6], 4'b0, 5'h02, 3'b000, 5'h02, OPCODE_OPIMM};
                end else if (instr[11:7] == 5'b0) begin
                  // Hint -> lui x0, imm
                  instr_o.bus_resp.rdata = {{15 {instr[12]}}, instr[6:2], instr[11:7], OPCODE_LUI};
                end else begin
                  // c.lui -> lui rd, imm
                  instr_o.bus_resp.rdata = {{15 {instr[12]}}, instr[6:2], instr[11:7], OPCODE_LUI};
                end
              end
            end

            3'b100: begin
              unique case (instr[11:10])
                2'b00,
                2'b01: begin
                  // 00: c.srli -> srli rd, rd, shamt
                  // 01: c.srai -> srai rd, rd, shamt
                  if (instr[12] == 1'b1) begin
                    // Reserved for future custom extensions (instr_o don't care)
                    instr_o.bus_resp.rdata = {1'b0, instr[10], 5'b0, instr[6:2], 2'b01, instr[9:7], 3'b101, 2'b01, instr[9:7], OPCODE_OPIMM};
                    illegal_instr_o = 1'b1;
                  end else begin
                    if (instr[6:2] == 5'b0) begin
                      // Hint
                      instr_o.bus_resp.rdata = {1'b0, instr[10], 5'b0, instr[6:2], 2'b01, instr[9:7], 3'b101, 2'b01, instr[9:7], OPCODE_OPIMM};
                    end else begin
                      instr_o.bus_resp.rdata = {1'b0, instr[10], 5'b0, instr[6:2], 2'b01, instr[9:7], 3'b101, 2'b01, instr[9:7], OPCODE_OPIMM};
                    end
                  end
                end

                2'b10: begin
                  // c.andi -> andi rd, rd, imm
                  instr_o.bus_resp.rdata = {{6 {instr[12]}}, instr[12], instr[6:2], 2'b01, instr[9:7], 3'b111, 2'b01, instr[9:7], OPCODE_OPIMM};
                end

                2'b11: begin
                  unique case ({instr[12], instr[6:5]})
                    3'b000: begin
                      // c.sub -> sub rd', rd', rs2'
                      instr_o.bus_resp.rdata = {2'b01, 5'b0, 2'b01, instr[4:2], 2'b01, instr[9:7], 3'b000, 2'b01, instr[9:7], OPCODE_OP};
                    end

                    3'b001: begin
                      // c.xor -> xor rd', rd', rs2'
                      instr_o.bus_resp.rdata = {7'b0, 2'b01, instr[4:2], 2'b01, instr[9:7], 3'b100, 2'b01, instr[9:7], OPCODE_OP};
                    end

                    3'b010: begin
                      // c.or  -> or  rd', rd', rs2'
                      instr_o.bus_resp.rdata = {7'b0, 2'b01, instr[4:2], 2'b01, instr[9:7], 3'b110, 2'b01, instr[9:7], OPCODE_OP};
                    end

                    3'b011: begin
                      // c.and -> and rd', rd', rs2'
                      instr_o.bus_resp.rdata = {7'b0, 2'b01, instr[4:2], 2'b01, instr[9:7], 3'b111, 2'b01, instr[9:7], OPCODE_OP};
                    end

                    3'b110: begin
                      if (ZC_EXT && (M_EXT != M_NONE)) begin
                        // c.mul -> mul rsd', rsd', rs2'
                        instr_o.bus_resp.rdata = {7'b0000001, 2'b01, instr[4:2], 2'b01, instr[9:7], 3'b000, 2'b01, instr[9:7], OPCODE_OP};
                      end else begin
                        instr_o.bus_resp.rdata = {7'b0, 2'b01, instr[4:2], 2'b01, instr[9:7], 3'b111, 2'b01, instr[9:7], OPCODE_OP};
                        illegal_instr_o = 1'b1;
                      end
                    end

                    3'b111: begin
                      if (ZC_EXT) begin
                        unique case (instr[4:2])
                          3'b000: begin
                            // c.zext.b -> andi rsd', rsd', 0xff
                            instr_o.bus_resp.rdata = {4'h0, 8'hff, 2'b01, instr[9:7], 3'b111, 2'b01, instr[9:7],  OPCODE_OPIMM};
                          end
                          3'b001: begin
                            if (B_EXT != B_NONE) begin
                              // c.sext.b -> sext.b rsd', rsd'
                              instr_o.bus_resp.rdata = {7'b0110000, 5'b00100, 2'b01, instr[9:7], 3'b001, 2'b01, instr[9:7],  OPCODE_OPIMM};
                            end else begin
                              instr_o.bus_resp.rdata = {7'b0, 2'b01, instr[4:2], 2'b01, instr[9:7], 3'b111, 2'b01, instr[9:7], OPCODE_OP};
                              illegal_instr_o = 1'b1;
                            end
                          end
                          3'b010: begin
                            if (B_EXT != B_NONE) begin
                              // c.zext.h -> zext.h rsd', rsd'
                              instr_o.bus_resp.rdata = {7'b0000100, 5'b00000, 2'b01, instr[9:7], 3'b100, 2'b01, instr[9:7],  OPCODE_OP};
                            end else begin
                              instr_o.bus_resp.rdata = {7'b0, 2'b01, instr[4:2], 2'b01, instr[9:7], 3'b111, 2'b01, instr[9:7], OPCODE_OP};
                              illegal_instr_o = 1'b1;
                            end
                          end
                          3'b011: begin
                            if (B_EXT != B_NONE) begin
                              // c.sext.h -> sext.h rsd', rsd'
                              instr_o.bus_resp.rdata = {7'b0110000, 5'b00101, 2'b01, instr[9:7], 3'b001, 2'b01, instr[9:7],  OPCODE_OPIMM};
                            end else begin
                              instr_o.bus_resp.rdata = {7'b0, 2'b01, instr[4:2], 2'b01, instr[9:7], 3'b111, 2'b01, instr[9:7], OPCODE_OP};
                              illegal_instr_o = 1'b1;
                            end
                          end
                          3'b101: begin
                            // c.not -> xori rsd', rsd', -1
                            instr_o.bus_resp.rdata = {12'hfff, 2'b01, instr[9:7], 3'b100, 2'b01, instr[9:7],  OPCODE_OPIMM};
                          end
                          default: begin
                            instr_o.bus_resp.rdata = {7'b0, 2'b01, instr[4:2], 2'b01, instr[9:7], 3'b111, 2'b01, instr[9:7], OPCODE_OP};
                            illegal_instr_o = 1'b1;
                          end
                        endcase
                      end else begin
                        instr_o.bus_resp.rdata = {7'b0, 2'b01, instr[4:2], 2'b01, instr[9:7], 3'b111, 2'b01, instr[9:7], OPCODE_OP};
                        illegal_instr_o = 1'b1;
                      end
                    end
                    3'b100,
                    3'b101: begin
                      // 100: c.subw
                      // 101: c.addw
                      instr_o.bus_resp.rdata = {7'b0, 2'b01, instr[4:2], 2'b01, instr[9:7], 3'b111, 2'b01, instr[9:7], OPCODE_OP};
                      illegal_instr_o = 1'b1;
                    end
                    default:;
                  endcase
                end
                default:;
              endcase
            end

            3'b110, 3'b111: begin
              // 0: c.beqz -> beq rs1', x0, imm
              // 1: c.bnez -> bne rs1', x0, imm
              instr_o.bus_resp.rdata = {{4 {instr[12]}}, instr[6:5], instr[2], 5'b0, 2'b01, instr[9:7], 2'b00, instr[13], instr[11:10], instr[4:3], instr[12], OPCODE_BRANCH};
            end
            default:;
          endcase
        end

        // C2
        2'b10: begin
          unique case (instr[15:13])
            3'b000: begin
              if (instr[12] == 1'b1) begin
                // Reserved for future extensions (instr_o don't care)
                instr_o.bus_resp.rdata = {7'b0, instr[6:2], instr[11:7], 3'b001, instr[11:7], OPCODE_OPIMM};
                illegal_instr_o = 1'b1;
              end else begin
                if ((instr[6:2] == 5'b0) || (instr[11:7] == 5'b0)) begin
                  // Hint -> slli rd, rd, shamt
                  instr_o.bus_resp.rdata = {7'b0, instr[6:2], instr[11:7], 3'b001, instr[11:7], OPCODE_OPIMM};
                end else begin
                  // c.slli -> slli rd, rd, shamt
                  instr_o.bus_resp.rdata = {7'b0, instr[6:2], instr[11:7], 3'b001, instr[11:7], OPCODE_OPIMM};
                end
              end
            end


            3'b010: begin
              // c.lwsp -> lw rd, imm(x2)
              instr_o.bus_resp.rdata = {4'b0, instr[3:2], instr[12], instr[6:4], 2'b00, 5'h02, 3'b010, instr[11:7], OPCODE_LOAD};
              if (instr[11:7] == 5'b0) begin
                illegal_instr_o = 1'b1;
              end
            end

            3'b100: begin
              if (instr[12] == 1'b0) begin
                if (instr[6:2] == 5'b0) begin
                  if (instr[11:7] == 5'b0) begin
                    // c.jr with rs1 = 0 is reserved
                    instr_o.bus_resp.rdata = {7'b0, instr[6:2], 5'b0, 3'b0, instr[11:7], OPCODE_OP}; // Not using OPCODE_JALR on purpose (to allow direct decoder_i_ctrl branch/jump usage)
                    illegal_instr_o = 1'b1;
                  end else begin
                    // c.jr -> jalr x0, rd/rs1, 0
                    instr_o.bus_resp.rdata = {12'b0, instr[11:7], 3'b0, 5'b0, OPCODE_JALR};
                  end
                end else begin
                  if (instr[11:7] == 5'b0) begin
                    // Hint -> add x0, x0, rs2
                    instr_o.bus_resp.rdata = {7'b0, instr[6:2], 5'b0, 3'b0, instr[11:7], OPCODE_OP};
                  end else begin
                    // c.mv -> add rd, x0, rs2
                    instr_o.bus_resp.rdata = {7'b0, instr[6:2], 5'b0, 3'b0, instr[11:7], OPCODE_OP};
                  end
                end
              end else begin
                if (instr[6:2] == 5'b0) begin
                  if (instr[11:7] == 5'b0) begin
                    // c.ebreak -> ebreak
                    instr_o.bus_resp.rdata = {32'h00_10_00_73};
                  end else begin
                    // c.jalr -> jalr x1, rs1, 0
                    instr_o.bus_resp.rdata = {12'b0, instr[11:7], 3'b000, 5'b00001, OPCODE_JALR};
                  end
                end else begin
                  if (instr[11:7] == 5'b0) begin
                    // Hint -> add x0, x0, rs2
                    instr_o.bus_resp.rdata = {7'b0, instr[6:2], instr[11:7], 3'b0, instr[11:7], OPCODE_OP};
                  end else begin
                    // c.add -> add rd, rd, rs2
                    instr_o.bus_resp.rdata = {7'b0, instr[6:2], instr[11:7], 3'b0, instr[11:7], OPCODE_OP};
                  end
                end
              end
            end

            3'b110: begin
              // c.swsp -> sw rs2, imm(x2)
              instr_o.bus_resp.rdata = {4'b0, instr[8:7], instr[12], instr[6:2], 5'h02, 3'b010, instr[11:9], 2'b00, OPCODE_STORE};
            end

            3'b001,
            3'b011,
            3'b101,
            3'b111: begin  // c.fswsp -> fsw rs2, imm(x2)
              instr_o.bus_resp.rdata = {4'b0, instr[3:2], instr[12], instr[6:4], 2'b00, 5'h02, 3'b010, instr[11:7], OPCODE_LOAD};
              illegal_instr_o = 1'b1;
            end
            default:;
          endcase
        end

        default: begin
          // 32 bit (or more) instruction
          instr_o.bus_resp.rdata = instr_i.bus_resp.rdata;
        end
      endcase
    end // instr_is_pointer_i
  end // always_comb

endmodule



// Description:    Sequencer for Zc push/pop and double move instructions     //
//                 Inherited from CV32E41P PR#24 and updated to support       //
//                 Zc spec 0.70.4.
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_sequencer import cv32e40x_pkg::*;
 #(
   parameter rv32_e    RV32 = RV32I
 )
 (
    input  logic       clk,
    input  logic       rst_n,

    input  logic [5:0] jvt_mode_i,
    input  inst_resp_t instr_i,               // Instruction from prefetch unit
    input  logic       instr_is_clic_ptr_i,   // CLIC pointer flag, instr_i does not contain an instruction
    input  logic       instr_is_mret_ptr_i,   // mret pointer flag, instr_i does not contain an instruction
    input  logic       instr_is_tbljmp_ptr_i, // Tablejump pointer flag, instr_i does not contain an instruction

    input  logic       valid_i,               // valid input from if stage
    input  logic       ready_i,               // Downstream is ready (ID stage)
    input  logic       halt_i,                // Halt, not ready for new input, no output valid. Keep state
    input  logic       kill_i,                // Kill. Ready for inputs, no output valid. Reset state

    output inst_resp_t instr_o,               // Output sequenced (32-bit) instruction
    output logic       valid_o,               // Output is valid - input is valid AND we decode a valid seq instruction
    output logic       ready_o,               // Sequencer is ready for new inputs
    output logic       seq_first_o,           // First operation is being output
    output logic       seq_last_o,            // Last operation is being output,
    output logic       seq_tbljmp_o,          // Instruction is a table jump (jt/jalt)
    output logic       seq_pushpop_o          // Instruction is a PUSH or POP
  );

  seq_t                instr_cnt_q;        // Count number of emitted uncompressed instructions
  pushpop_decode_s     decode;             // Struct holding metatdata for current decoded instruction
  seq_instr_e          seq_instr;          // Type of current decoded instruction

  logic [31:0]         instr;              // Instruction word from prefetcher
  logic [3:0]          rlist;              // rlist for push/pop*

  // Helper signals to indicate type of instruction
  logic                seq_load;
  logic                seq_store;
  logic                seq_move_a2s;
  logic                seq_move_s2a;

  // FSM state
  seq_state_e          seq_state_n;
  seq_state_e          seq_state_q;

  logic                seq_first_fsm;
  logic                seq_last_fsm;

  logic                instr_is_pointer;

  logic                ready_fsm;

  logic                dmove_legal_dest_s2a;
  logic                dmove_legal_dest_a2s;
  logic                pushpop_legal_rlist;

  assign instr = instr_i.bus_resp.rdata;
  assign rlist = instr[7:4];

  assign instr_is_pointer = instr_is_clic_ptr_i || instr_is_mret_ptr_i || instr_is_tbljmp_ptr_i;

  // Count number of instructions emitted and set next state for FSM.
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      instr_cnt_q <= '0;
      seq_state_q <= S_IDLE;
    end else begin
      if (valid_o && ready_i) begin // Implies !halt_i && !kill_i
        // Exclude tablejumps and tablejump pointers from increasing the counter.
        // To remain SEC clean, the prefetcher is ack'ed on a tablejump. If the tablejump
        // has a bus error or mpu error, the instruction after the tablejump may reach EX before the pipeline is killed.
        // If this next instruction is a load or store, the starting value for the stack adjustment will be wrong and the LSU
        // outputs may get affected. If one changes to not ack the prefetcher on table jumps, this exclusion can likely be removed.
        if (!seq_last_o) begin
          if (!seq_tbljmp_o && !instr_is_tbljmp_ptr_i) begin
            instr_cnt_q <= instr_cnt_q + 1'd1;
          end
        end else begin
          instr_cnt_q <= '0;
        end

        seq_state_q <= seq_state_n;
      end else begin
        // Reset state and counter when killed
        if (kill_i) begin
          instr_cnt_q <= '0;
          seq_state_q <= S_IDLE;
        end

        // When halt_i == 1, no state change should occur. Checked with a_seq_halt_stable within cv32e40x_sequencer_sva.sv
        // When a sequence is done, instr_cnt_q should be zero and seq_state_q should be S_IDLE. Checked with a_done_state within cv32e40x_sequencer_sva.sv
        // When (!valid_o && !halt_i) instr_cnt_q should be zero and seq_state_q should be S_IDLE (no instruction was emitted and state should be the initial state)
        //   Checked by a_idle_state within cv32e40x_sequencer_sva.sv
      end
    end
  end // always_ff

  ///////////////////////////////////
  // Decode sequenced instructions //
  ///////////////////////////////////

  // rlist values 0 to 3 are reserved for a future EABI variant called cm.popret.e
  // For RV32E, S2-S11 are not present (i.e. rlist must be < 7)
  assign pushpop_legal_rlist = (RV32 == RV32I) ? (rlist > 4'h3) :
                               (rlist < 4'h7) && (rlist > 4'h3);

  // cm.mva01s: allows r1s' and r2s' to be the same register
  // For RV32E, S2-S11 are not present
  assign dmove_legal_dest_s2a = (RV32 == RV32I) ? 1'b1 : (instr[9:7] < 3'h2) && (instr[4:2] < 3'h2);

  // cm.mvsa01: r1s' must be different from r2s'
  // For RV32E, S2-S11 are not present
  assign dmove_legal_dest_a2s = (RV32 == RV32I) ? (instr[9:7] != instr[4:2]) :
                                (instr[9:7] != instr[4:2]) && (instr[9:7] < 3'h2) && (instr[4:2] < 3'h2);
  always_comb
  begin
    seq_instr     = INVALID_INST;
    seq_load      = 1'b0;
    seq_store     = 1'b0;
    seq_move_a2s  = 1'b0;
    seq_move_s2a  = 1'b0;
    seq_tbljmp_o  = 1'b0;
    seq_pushpop_o = 1'b0;
    // Disregard all pointers, they do not contain instructions.
    if (!instr_is_pointer) begin
      // All sequenced instructions are within C2
      if (instr[1:0] == 2'b10) begin
        if (instr[15:13] == 3'b101) begin
          unique case (instr[12:10])
            3'b000: begin
              if (!(|jvt_mode_i)) begin
                seq_tbljmp_o = 1'b1;
                seq_instr = TBLJMP;
              end
            end

            3'b011: begin
              if (instr[6:5] == 2'b11) begin
                // cm.mva01s
                if (dmove_legal_dest_s2a) begin
                  seq_instr = MVA01S;
                  seq_move_s2a = 1'b1;
                end
              end else if (instr[6:5] == 2'b01) begin
                // cm.mvsa01
                if (dmove_legal_dest_a2s) begin
                  seq_instr = MVSA01;
                  seq_move_a2s = 1'b1;
                end
              end
            end
            3'b110: begin
              if (instr[9:8] == 2'b00) begin
                // cm.push
                if (pushpop_legal_rlist) begin
                  seq_instr = PUSH;
                  seq_store = 1'b1;
                  seq_pushpop_o = 1'b1;
                end
              end else if (instr[9:8] == 2'b10) begin
                // cm.pop
                if (pushpop_legal_rlist) begin
                  seq_instr = POP;
                  seq_load = 1'b1;
                  seq_pushpop_o = 1'b1;
                end
              end
            end
            3'b111: begin
              if (instr[9:8] == 2'b00) begin
                // cm.popretz
                if (pushpop_legal_rlist) begin
                  seq_instr = POPRETZ;
                  seq_load = 1'b1;
                  seq_pushpop_o = 1'b1;
                end
              end else if (instr[9:8] == 2'b10) begin
                // cm.popret
                if (pushpop_legal_rlist) begin
                  seq_instr = POPRET;
                  seq_load = 1'b1;
                  seq_pushpop_o = 1'b1;
                end
              end
            end
            default: begin
              seq_instr = INVALID_INST;
            end
          endcase
        end // instr[15:13]
      end // C2
    end // instr_is_pointer
  end // always_comb

  // Local valid
  // In principle this is the same as "seq_en && valid_i"
  //   as the output of the above decode logic is equivalent to seq_en
  // We have valid outputs for any correctly decoded instruction, or when we are handling a tablejump pointer.
  assign valid_o = ((seq_instr != INVALID_INST) || instr_is_tbljmp_ptr_i) && valid_i && !halt_i && !kill_i;


  // Calculate number of S* registers needed in sequence (push/pop* only)
  assign decode.registers_saved = pushpop_reg_length(rlist);

  // Calculate stack space needed for the push/pop* registers (including ra)
  // 16-bit aligned
  assign decode.stack_adj_base = get_stack_adj_base(rlist);

  // Compute total stack adjustment based on saved registers and additional 16 byte blocks from immediate
  assign decode.total_stack_adj = decode.stack_adj_base + (instr[3:2] << 4);

  // Calculate the current stack address used for push/pop*
  always_comb begin : current_stack_adj
    case (seq_instr)
      PUSH: begin
        // Start pushing to -4(SP)
        decode.current_stack_adj = -{{instr_cnt_q+12'b1}<<2};
      end
      POP,POPRET, POPRETZ: begin
        // Need to account for any extra allocated stack space during cm.push
        // Rewind with decode.total_stack_adj and then start by popping from -4
        decode.current_stack_adj = decode.total_stack_adj-12'({instr_cnt_q+5'b1}<<2);
      end
      default:
        decode.current_stack_adj = '0;
    endcase
  end

  // Set current sreg number based on sequence counter
  assign decode.sreg = decode.registers_saved - instr_cnt_q - 4'd1;

  // Generate 32-bit instructions for all sequenced operations
  always_comb begin : sequencer_state_machine
    instr_o = instr_i;
    seq_state_n = seq_state_q;
    seq_last_fsm = 1'b0;
    // default to 1, set to zero in non-first states.
    seq_first_fsm = 1'b1;
    ready_fsm = 1'b0;

    unique case (seq_state_q)
      S_IDLE: begin
        // First instruction is output here
        if (seq_load) begin
          if (decode.registers_saved == 'd1) begin
            // Exactly one S register popped
            // lw rd, decode.current_stack_adj(SP)
            instr_o.bus_resp.rdata = {decode.current_stack_adj,REG_SP,3'b010,sn_to_regnum(decode.sreg),OPCODE_LOAD};
            // Finished loading the single Sreg, ra next
            seq_state_n = S_RA;
          end else if (decode.registers_saved > 'd1) begin
            // More than one S register popped
            // lw rd, decode.current_stack_adj(SP)
            instr_o.bus_resp.rdata = {decode.current_stack_adj,REG_SP,3'b010,sn_to_regnum(decode.sreg),OPCODE_LOAD};
            // Continue popping Sregs
            seq_state_n = S_POP;
          end else begin
            // No S register popped, pop ra
            // lw ra, decode.current_stack_adj(SP)
            instr_o.bus_resp.rdata = {decode.current_stack_adj,REG_SP,3'b010,REG_RA,OPCODE_LOAD};
            // Finished popping, stack pointer next
            seq_state_n = S_SP;
          end
        end else if (seq_store) begin
          // Current stack adjustment for the first stores are always -4
          if (decode.registers_saved == 'd1) begin
            // Exactly one S register pushed
            // sw, rs2, -4(sp)
            instr_o.bus_resp.rdata = {7'b1111111,sn_to_regnum(decode.sreg),5'd2,3'b010,5'b11100,OPCODE_STORE};
            // Finished pushing, ra next
            seq_state_n = S_RA;
          end else if (decode.registers_saved > 'd1) begin
            // More than one S register pushed
            // sw, rs2, -4(sp)
            instr_o.bus_resp.rdata = {7'b1111111,sn_to_regnum(decode.sreg),5'd2,3'b010,5'b11100,OPCODE_STORE};
            // Continue pushing
            seq_state_n = S_PUSH;
          end else begin
            // No S register pushed
            // sw, ra, -4(sp)
            instr_o.bus_resp.rdata = {7'b1111111,REG_RA,5'd2,3'b010,5'b11100,OPCODE_STORE};
            // Finished pushing, stack pointer next
            seq_state_n = S_SP;
          end
        end else if (seq_move_a2s) begin
          // addi s*, a0, 0
          instr_o.bus_resp.rdata = {12'h000, 5'd10, 3'b000, sn_to_regnum({2'h0,instr[9:7]}), OPCODE_OPIMM};
          seq_state_n = S_DMOVE;
        end else if (seq_tbljmp_o) begin
          if (instr[9:7] == 3'b000) begin
            // cm.jt -> JAL x0, index
            instr_o.bus_resp.rdata = {15'b000000000000000, instr[6:2], 5'b00000, OPCODE_JAL};
          end else begin
            // cm.jalt -> JAL, x1, index
            instr_o.bus_resp.rdata = {12'b000000000000, instr[9:2], 5'b00001, OPCODE_JAL};
          end
          // The second half of tablejumps (pointer) will not use the FSM (the jump will kill the sequencer anyway).
          // Signalling ready here will acknowledge the prefetcher.
          ready_fsm = ready_i && !halt_i;
        end else if (seq_move_s2a) begin
          // move s to a
          // addi a0, s*, 0
          instr_o.bus_resp.rdata = {12'h000, sn_to_regnum({2'h0,instr[9:7]}), 3'b000, 5'd10, OPCODE_OPIMM};
          seq_state_n = S_DMOVE;
        end

      end
      S_PUSH: begin
        seq_first_fsm = 1'b0;
        // sw rs2, current_stack_adj(sp)
        instr_o.bus_resp.rdata = {decode.current_stack_adj[11:5],sn_to_regnum(decode.sreg),REG_SP,3'b010,decode.current_stack_adj[4:0],OPCODE_STORE};
        // Advance FSM when we have saved all s* registers
        if (instr_cnt_q == decode.registers_saved - 1) begin
          seq_state_n = S_RA;
        end
      end
      S_POP: begin
        seq_first_fsm = 1'b0;
        // lw rd, current_stack_adj(sp)
        instr_o.bus_resp.rdata = {decode.current_stack_adj,REG_SP,3'b010,sn_to_regnum(decode.sreg),OPCODE_LOAD};
        // Advance FSM when we have loaded all s* registers
        if (instr_cnt_q == decode.registers_saved - 1) begin
          seq_state_n = S_RA;
        end
      end
      S_DMOVE: begin
        seq_first_fsm = 1'b0;
        // Second half of double moves
        if (seq_move_a2s) begin
          // addi s*, a1, 0
          instr_o.bus_resp.rdata = {12'h000, 5'd11, 3'b000, sn_to_regnum({2'h0,instr[4:2]}), OPCODE_OPIMM};
        end else begin
          // addi a1, s*, 0
          instr_o.bus_resp.rdata = {12'h000, sn_to_regnum({2'h0,instr[4:2]}), 3'b000, 5'd11, OPCODE_OPIMM};
        end

        seq_state_n = S_IDLE;
        ready_fsm = ready_i && !halt_i;
        seq_last_fsm = 1'b1;
      end
      S_RA: begin
        seq_first_fsm = 1'b0;
        // push pop ra register
        if (seq_load) begin
          // lw ra, current_stack_adj(sp)
          instr_o.bus_resp.rdata = {decode.current_stack_adj,REG_SP,3'b010,REG_RA,OPCODE_LOAD};
        end else begin
          // sw ra, current_stack_adj(sp)
          instr_o.bus_resp.rdata = {decode.current_stack_adj[11:5],REG_RA,REG_SP,3'b010,decode.current_stack_adj[4:0],OPCODE_STORE};
        end

        seq_state_n = S_SP;
      end
      S_SP: begin
        seq_first_fsm = 1'b0;
        // Adjust stack pointer
        if (seq_load) begin
          // addi sp, sp, total_stack_adj
          instr_o.bus_resp.rdata = {decode.total_stack_adj,REG_SP,3'b0,REG_SP,OPCODE_OPIMM};
        end else begin
          // addi sp, sp, -total_stack_adj
          instr_o.bus_resp.rdata = {-decode.total_stack_adj,REG_SP,3'b0,REG_SP,OPCODE_OPIMM};
        end


        if (seq_instr == POPRETZ) begin
          seq_state_n = S_A0;
        end else if (seq_instr == POPRET) begin
          seq_state_n = S_RET;
        end else begin
          seq_state_n = S_IDLE;
          ready_fsm = ready_i && !halt_i;
          seq_last_fsm = 1'b1;
        end
      end
      S_A0: begin
        seq_first_fsm = 1'b0;
        // Clear a0 for popretz
        // addi ra, x0, 0
        instr_o.bus_resp.rdata = {12'h000,5'd0,3'b0,5'd10,OPCODE_OPIMM};

        seq_state_n = S_RET;
      end
      S_RET: begin
        seq_first_fsm = 1'b0;
        // return for popret/popretz
        // jalr x0, 0(ra)
        instr_o.bus_resp.rdata = {12'b0,REG_RA,3'b0,5'b0,OPCODE_JALR};

        seq_state_n = S_IDLE;
        ready_fsm = ready_i && !halt_i;
        seq_last_fsm = 1'b1;
      end

      default: begin
        // Should not happen
        ready_fsm = 1'b1;
        seq_state_n = S_IDLE;
      end
    endcase

    // If there is no valid output or we are killed: default to ready_fsm==1 (fans into if_ready).
    // No ready_fsm if !valid while halted, as we cannot accept a new instruction while halted.
    if ((!valid_o && !halt_i) || kill_i) begin
      ready_fsm = 1'b1;
    end
  end

  // Bypass the sequencer FSM when there is an incoming tablejump pointer.
  // Tablejump pointers are the last/non-first of a sequence.
  // While waiting for a tablejump pointer, we still need to obey halt/kill inputs for the ready_o.
  assign seq_last_o  = instr_is_tbljmp_ptr_i ? 1'b1 : seq_last_fsm;
  assign seq_first_o = instr_is_tbljmp_ptr_i ? 1'b0 : seq_first_fsm;
  assign ready_o     = instr_is_tbljmp_ptr_i ? (ready_i && !halt_i) || kill_i : ready_fsm;


endmodule





// Description:    Instruction fetch unit: Selection of the next PC, and      //
//                 buffering (sampling) of the read instruction               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_if_stage import cv32e40x_pkg::*;
#(
  parameter rv32_e       RV32            = RV32I,
  parameter a_ext_e      A_EXT           = A_NONE,
  parameter b_ext_e      B_EXT           = B_NONE,
  parameter bit          X_EXT           = 0,
  parameter int unsigned X_ID_WIDTH      = 4,
  parameter int          PMA_NUM_REGIONS = 0,
  parameter pma_cfg_t    PMA_CFG[PMA_NUM_REGIONS-1:0] = '{default:PMA_R_DEFAULT},
  parameter int unsigned MTVT_ADDR_WIDTH = 26,
  parameter bit          CLIC            = 1'b0,
  parameter int unsigned CLIC_ID_WIDTH   = 5,
  parameter bit          ZC_EXT          = 0,
  parameter m_ext_e      M_EXT           = M_NONE,
  parameter bit          DEBUG           = 1,
  parameter logic [31:0] DM_REGION_START = 32'hF0000000,
  parameter logic [31:0] DM_REGION_END   = 32'hF0003FFF
)
(
  input  logic          clk,
  input  logic          rst_n,

  // Target addresses
  input  logic [31:0]   boot_addr_i,            // Boot address
  input  logic [31:0]   branch_target_ex_i,     // Branch target address
  input  logic [31:0]   dm_exception_addr_i,    // Debug mode exception address
  input  logic [31:0]   dm_halt_addr_i,         // Debug mode halt address
  input  logic [31:0]   dpc_i,                  // Debug PC (restore upon return from debug)
  input  logic [31:0]   jump_target_id_i,       // Jump target address
  input  logic [31:0]   mepc_i,                 // Exception PC (restore upon return from exception/interrupt)
  input  logic [24:0]   mtvec_addr_i,           // Exception/interrupt address (MSBs)
  input  logic [5:0]    jvt_mode_i,

  input  logic [MTVT_ADDR_WIDTH-1:0]   mtvt_addr_i,            // Base address for CLIC vectoring

  input ctrl_fsm_t      ctrl_fsm_i,
  input  logic [31:0]   trigger_match_i,

  // Instruction bus interface
  cv32e40x_if_c_obi.master m_c_obi_instr_if,

  output if_id_pipe_t   if_id_pipe_o,           // IF/ID pipeline stage
  output logic [31:0]   pc_if_o,                // Program counter
  output logic          csr_mtvec_init_o,       // Tell CS regfile to init mtvec
  output logic          if_busy_o,              // Is the IF stage busy fetching instructions?
  output logic          ptr_in_if_o,            // The IF stage currently holds a pointer
  output privlvl_t      priv_lvl_if_o,          // Privilege level of the instruction currently in IF

  output logic          last_op_o,
  output logic          abort_op_o,

  // Stage ready/valid
  output logic          if_valid_o,
  input  logic          id_ready_i,

  // Privilege mode
  input privlvlctrl_t   priv_lvl_ctrl_i,

  // eXtension interface
  cv32e40x_if_xif.cpu_compressed xif_compressed_if,      // XIF compressed interface
  input  logic                   xif_offloading_id_i     // ID stage attempts to offload an instruction
);

  // ALBUF_DEPTH set to 3 as the alignment_buffer will need 3 entries to function correctly
  localparam int unsigned ALBUF_DEPTH     = 3;
  localparam int unsigned ALBUF_CNT_WIDTH = $clog2(ALBUF_DEPTH);

  // Calculate number of bits of mtvt_pc_mux to use in branch_addr_n for CLIC SHV interrupts.
  // Minimum number of bits to use from ctrl_fsm.mtvt_pc_mux is four to keep 32-bit address 64B aligned.
  // Otherwise the resulting concatenated address will be less than 32 bits.
  localparam int unsigned CLIC_MUX_WIDTH = (CLIC_ID_WIDTH < 4) ? 4 : CLIC_ID_WIDTH;

  logic              if_ready;

  // prefetch buffer related signals
  logic              prefetch_busy;

  logic       [31:0] branch_addr_n;

  logic              prefetch_valid;
  logic              prefetch_ready;
  inst_resp_t        prefetch_instr;
  privlvl_t          prefetch_priv_lvl;

  logic              prefetch_is_clic_ptr;
  logic              prefetch_is_mret_ptr;
  logic              prefetch_is_tbljmp_ptr;

  logic              illegal_c_insn;

  inst_resp_t        instr_decompressed;
  logic              instr_compressed;

  // Transaction signals to/from obi interface
  logic                       prefetch_resp_valid;
  logic                       prefetch_trans_valid;
  logic                       prefetch_trans_ready;
  logic [31:0]                prefetch_trans_addr;
  inst_resp_t                 prefetch_inst_resp;
  logic                       prefetch_one_txn_pend_n;
  logic [ALBUF_CNT_WIDTH-1:0] prefetch_outstnd_cnt_q;

  logic              bus_resp_valid;
  obi_inst_resp_t    bus_resp;
  logic              bus_trans_valid;
  logic              bus_trans_ready;
  obi_inst_req_t     bus_trans;
  obi_inst_req_t     core_trans;

  // Local instr_valid
  logic              instr_valid;

  // eXtension interface signals
  logic [X_ID_WIDTH-1:0] xif_id;

  // ready signal for predecoder, tied to id_ready_i
  logic              predec_ready;

  // Zc* sequencer signals
  logic              seq_valid;       // sequencer has valid output
  logic              seq_ready;       // sequencer is ready for new inputs
  logic              seq_instr_valid; // Sequencer has valid inputs
  logic              seq_first;       // sequencer is outputting the first operation
  logic              seq_last;        // sequencer is outputting the last operation
  inst_resp_t        seq_instr;       // Instruction for sequenced operation
  logic              seq_tbljmp;      // Sequenced instruction is a table jump
  logic              seq_pushpop;     // Sequenced instruction is a push or pop
  logic              first_op;

  logic              unused_signals;

  // Fetch address selection
  always_comb
  begin
    // Default assign PC_BOOT (should be overwritten in below case)
    branch_addr_n = {boot_addr_i[31:2], 2'b0};

    unique case (ctrl_fsm_i.pc_mux)
      PC_BOOT:       branch_addr_n = {boot_addr_i[31:2], 2'b0};
      PC_JUMP:       branch_addr_n = jump_target_id_i;
      PC_BRANCH:     branch_addr_n = branch_target_ex_i;
      // An mret that restarts a CLIC pointer fetch must make sure the address is aligned to XLEN/8.
      // Clearing branch_addr_n[1] when an mepc is used as part of CLIC pointer fetch.
      PC_MRET:       branch_addr_n = {mepc_i[31:2], (mepc_i[1] & !ctrl_fsm_i.pc_set_clicv), mepc_i[0]}; // PC is restored when returning from IRQ/exception
      PC_DRET:       branch_addr_n = dpc_i;
      PC_WB_PLUS4:   branch_addr_n = ctrl_fsm_i.pipe_pc;                                          // Jump to next instruction forces prefetch buffer reload
      PC_TRAP_EXC:   branch_addr_n = {mtvec_addr_i, 7'h0};                                        // All the exceptions go to base address
      PC_TRAP_IRQ:   branch_addr_n = {mtvec_addr_i, ctrl_fsm_i.mtvec_pc_mux, 2'b00};     // interrupts are vectored
      PC_TRAP_DBD:   branch_addr_n = {dm_halt_addr_i[31:2], 2'b0};
      PC_TRAP_DBE:   branch_addr_n = {dm_exception_addr_i[31:2], 2'b0};
      PC_TRAP_NMI:   branch_addr_n = {mtvec_addr_i, ctrl_fsm_i.nmi_mtvec_index, 2'b00};
      PC_TRAP_CLICV: branch_addr_n = {mtvt_addr_i, ctrl_fsm_i.mtvt_pc_mux[CLIC_MUX_WIDTH-1:0], 2'b00};
      // CLIC and Zc* spec requires to clear bit 0. This clearing is done in the alignment buffer.
      PC_POINTER :   branch_addr_n = if_id_pipe_o.ptr;
      // JVT + (index << 2)
      PC_TBLJUMP :   branch_addr_n = jump_target_id_i; // Tablejumps reuse jump target adder in the ID stage.

      default:;
    endcase
  end

  // tell CS register file to initialize mtvec on boot
  assign csr_mtvec_init_o = (ctrl_fsm_i.pc_mux == PC_BOOT) & ctrl_fsm_i.pc_set;

  // prefetch buffer, caches a fixed number of instructions
  cv32e40x_prefetch_unit
  #(
      .CLIC            (CLIC),
      .ALBUF_DEPTH     (ALBUF_DEPTH),
      .ALBUF_CNT_WIDTH (ALBUF_CNT_WIDTH)
  )
  prefetch_unit_i
  (
    .clk                      ( clk                         ),
    .rst_n                    ( rst_n                       ),

    .ctrl_fsm_i               ( ctrl_fsm_i                  ),
    .priv_lvl_ctrl_i          ( priv_lvl_ctrl_i             ),

    .branch_addr_i            ( {branch_addr_n[31:1], 1'b0} ),

    .prefetch_ready_i         ( prefetch_ready              ),
    .prefetch_valid_o         ( prefetch_valid              ),
    .prefetch_instr_o         ( prefetch_instr              ),
    .prefetch_addr_o          ( pc_if_o                     ),
    .prefetch_priv_lvl_o      ( prefetch_priv_lvl           ),
    .prefetch_is_clic_ptr_o   ( prefetch_is_clic_ptr        ),
    .prefetch_is_mret_ptr_o   ( prefetch_is_mret_ptr        ),
    .prefetch_is_tbljmp_ptr_o ( prefetch_is_tbljmp_ptr      ),

    .trans_valid_o            ( prefetch_trans_valid        ),
    .trans_ready_i            ( prefetch_trans_ready        ),
    .trans_addr_o             ( prefetch_trans_addr         ),

    .resp_valid_i             ( prefetch_resp_valid         ),
    .resp_i                   ( prefetch_inst_resp          ),

    // Prefetch Buffer Status
    .prefetch_busy_o          ( prefetch_busy               ),
    .one_txn_pend_n           ( prefetch_one_txn_pend_n     ),
    .outstnd_cnt_q_o          ( prefetch_outstnd_cnt_q      )
  );

  //////////////////////////////////////////////////////////////////////////////
  // MPU
  //////////////////////////////////////////////////////////////////////////////

  assign core_trans.addr      = prefetch_trans_addr;
  assign core_trans.dbg       = ctrl_fsm_i.debug_mode_if;
  assign core_trans.prot[0]   = 1'b0;                     // Transfers from IF stage all instruction fetches
  assign core_trans.prot[2:1] = prefetch_priv_lvl;        // Machine mode
  assign core_trans.memtype   = 2'b00;                    // memtype is assigned in the MPU, tie off.

  cv32e40x_mpu
  #(
    .IF_STAGE             ( 1                           ),
    .A_EXT                ( A_EXT                       ),
    .CORE_REQ_TYPE        ( obi_inst_req_t              ),
    .CORE_RESP_TYPE       ( inst_resp_t                 ),
    .BUS_RESP_TYPE        ( obi_inst_resp_t             ),
    .PMA_NUM_REGIONS      ( PMA_NUM_REGIONS             ),
    .PMA_CFG              ( PMA_CFG                     ),
    .DEBUG                ( DEBUG                       ),
    .DM_REGION_START      ( DM_REGION_START             ),
    .DM_REGION_END        ( DM_REGION_END               )
  )
  mpu_i
  (
    .clk                  ( clk                         ),
    .rst_n                ( rst_n                       ),
    .atomic_access_i      ( 1'b0                        ), // No atomic transfers on instruction side
    .misaligned_access_i  ( 1'b0                        ), // MPU on instruction side will not issue misaligned access fault
                                                           // Misaligned access to main is allowed, and accesses outside main will
                                                           // result in instruction access fault (which will have priority over
                                                           //  misaligned from I/O fault)
    .modified_access_i    ( 1'b0                        ), // Prefetcher will never issue a modified request
    .core_one_txn_pend_n  ( prefetch_one_txn_pend_n     ),
    .core_mpu_err_wait_i  ( 1'b1                        ),
    .core_mpu_err_o       (                             ), // Unconnected on purpose
    .core_trans_valid_i   ( prefetch_trans_valid        ),
    .core_trans_pushpop_i ( 1'b0                        ), // Prefetches are never part of a PUSH/POP sequence
    .core_trans_ready_o   ( prefetch_trans_ready        ),
    .core_trans_i         ( core_trans                  ),
    .core_resp_valid_o    ( prefetch_resp_valid         ),
    .core_resp_o          ( prefetch_inst_resp          ),

    .bus_trans_valid_o    ( bus_trans_valid             ),
    .bus_trans_ready_i    ( bus_trans_ready             ),
    .bus_trans_o          ( bus_trans                   ),
    .bus_resp_valid_i     ( bus_resp_valid              ),
    .bus_resp_i           ( bus_resp                    )
  );


  //////////////////////////////////////////////////////////////////////////////
  // OBI interface
  //////////////////////////////////////////////////////////////////////////////

  cv32e40x_instr_obi_interface
  instruction_obi_i
  (
    .clk                  ( clk              ),
    .rst_n                ( rst_n            ),

    .trans_valid_i        ( bus_trans_valid  ),
    .trans_ready_o        ( bus_trans_ready  ),
    .trans_i              ( bus_trans        ),

    .resp_valid_o         ( bus_resp_valid   ),
    .resp_o               ( bus_resp         ),
    .m_c_obi_instr_if     ( m_c_obi_instr_if )
  );

  // Local instr_valid when we have valid output from prefetcher
  // and IF stage is not halted or killed
  assign instr_valid = prefetch_valid && !ctrl_fsm_i.kill_if && !ctrl_fsm_i.halt_if;

  // if_stage ready when killed, otherwise when not halted and the sequencer and predecoder are both ready
  assign if_ready = ctrl_fsm_i.kill_if || (seq_ready && predec_ready && !ctrl_fsm_i.halt_if);


  // if stage valid when local instr_valid=1
  // Ideally this should be the following:
  //
  // assign if_valid_o = (seq_en    && seq_valid    ) ||
  //                     (predec_en && predec_valid ) && instr_valid;
  //
  // The predecoder is purely combinatorial module, and will produce a valid output for any valid input (instr_valid)
  // The Sequencer will output valid=1 for any instruction it can decode while not halted or killed
  //   when its valid_i (prefetch_valid) is high.

  assign if_valid_o = instr_valid;

  assign if_busy_o = prefetch_busy;

  assign ptr_in_if_o = prefetch_is_clic_ptr || prefetch_is_mret_ptr || prefetch_is_tbljmp_ptr;

  // Acknowledge prefetcher when IF stage is ready. This factors in seq_ready to avoid ack'ing the
  // prefetcher in the middle of a Zc sequence.
  assign prefetch_ready = if_ready;

  // Sequenced instructions set last_op from the sequencer.
  // Any other instruction will be single operation, and gets last_op=1.
  // Regular CLIC pointers are single operation with first_op == last_op == 1
  // CLIC pointers that are a side effect of mret instructions will have first_op == 0 and last_op == 1
  assign last_op_o = seq_valid               ? seq_last :  // Sequencer controls last_op for sequenced instructions
                     prefetch_is_mret_ptr    ? 1'b1     :  // clic pointer caused by mret, must be !first && last
                                               1'b1;       // Any other regular instructions are single operation.

  // Flag first operation of a sequence.
  // Any sequenced instructions use the seq_first from the sequencer.
  // Any other instruction will be single operation, and gets first_op=1.
  // Regular CLIC pointers are single operation with first_op == last_op == 1
  // CLIC pointers that are a side effect of mret instructions will have first_op == 0 and last_op == 1
  assign first_op = seq_valid                ? seq_first :  // Sequencer controls first_op for sequenced instructions
                    prefetch_is_mret_ptr     ? 1'b0      :  // clic pointer caused by mret, must be !first && last
                                               1'b1;        // Any other regular instructions are single operation.


  // Set flag to indicate that instruction/sequence will be aborted due to known exceptions or trigger match
  assign abort_op_o = instr_decompressed.bus_resp.err || (instr_decompressed.mpu_status != MPU_OK) || |trigger_match_i;

  // Signal current privilege level of IF
  assign priv_lvl_if_o = prefetch_priv_lvl;

  // Populate instruction meta data
  // Fields 'compressed' and 'tbljmp' keep their old value by default.
  //   - In case of a table jump we need the fields to stay as 'compressed=1' and 'tbljmp=1'
  //     even when the pointer is sent to ID (operation 2/2)
  //   - For all cases except table jump pointer we update the values to the current values from predecoding.
  instr_meta_t instr_meta_n;
  always_comb begin
    instr_meta_n = '0;
    instr_meta_n.compressed    = if_id_pipe_o.instr_meta.compressed;
    instr_meta_n.clic_ptr      = prefetch_is_clic_ptr;
    instr_meta_n.mret_ptr      = prefetch_is_mret_ptr;
    instr_meta_n.tbljmp        = if_id_pipe_o.instr_meta.tbljmp;
    instr_meta_n.pushpop       = if_id_pipe_o.instr_meta.pushpop;
  end

  // IF-ID pipeline registers, frozen when the ID stage is stalled
  always_ff @(posedge clk, negedge rst_n)
  begin : IF_ID_PIPE_REGISTERS
    if (rst_n == 1'b0) begin
      if_id_pipe_o.instr_valid      <= 1'b0;
      if_id_pipe_o.instr            <= INST_RESP_RESET_VAL;
      if_id_pipe_o.instr_meta       <= '0;
      if_id_pipe_o.pc               <= '0;
      if_id_pipe_o.illegal_c_insn   <= 1'b0;
      if_id_pipe_o.compressed_instr <= '0;
      if_id_pipe_o.priv_lvl         <= PRIV_LVL_M;
      if_id_pipe_o.trigger_match    <= '0;
      if_id_pipe_o.xif_id           <= '0;
      if_id_pipe_o.ptr              <= '0;
      if_id_pipe_o.last_op          <= 1'b0;
      if_id_pipe_o.first_op         <= 1'b0;
      if_id_pipe_o.abort_op         <= 1'b0;
    end else begin
      // Valid pipeline output if we are valid AND the
      // alignment buffer has a valid instruction
      if (if_valid_o && id_ready_i) begin
        if_id_pipe_o.instr_valid      <= 1'b1;
        if_id_pipe_o.instr_meta       <= instr_meta_n;

        // seq_valid implies no illegal instruction, sequencer successfully decoded an instruction.
        // compressed decoder will still raise illegal_c_insn as it doesn't (currently) recognize Zc push/pop/dmove
        if_id_pipe_o.illegal_c_insn   <= seq_valid ? 1'b0 : illegal_c_insn;

        if_id_pipe_o.priv_lvl         <= prefetch_priv_lvl;
        if_id_pipe_o.trigger_match    <= trigger_match_i;
        if_id_pipe_o.xif_id           <= 32'(xif_id);
        if_id_pipe_o.last_op          <= last_op_o;
        if_id_pipe_o.first_op         <= first_op;
        if_id_pipe_o.abort_op         <= abort_op_o;

        // No PC update for tablejump pointer, PC of instruction itself is needed later.
        // No update to the meta compressed, as this is used in calculating the link address.
        //   Any pointer could change instr_compressed and cause a wrong link address.
        // No update to tbljmp flag, we want flag to be high for both operations.
        if (!prefetch_is_tbljmp_ptr) begin

          // For mret pointers, the pointer address is only needed downstream if the pointer fetch fails.
          // If the pointer fetch is successful, the address of the mret (i.e. the previous PC) is needed.
          if(prefetch_is_mret_ptr ?
             (instr_decompressed.bus_resp.err || (instr_decompressed.mpu_status != MPU_OK)) :
             1'b1) begin
            if_id_pipe_o.pc                    <= pc_if_o;
          end
          // Sequenced instructions are marked as illegal by the compressed decoder, however, the instr_compressed
          // flag is still set and can be used when propagating to ID.
          if_id_pipe_o.instr_meta.compressed <= instr_compressed;
          if_id_pipe_o.instr_meta.tbljmp     <= seq_tbljmp;
          if_id_pipe_o.instr_meta.pushpop    <= seq_pushpop;

          // Only update compressed_instr for compressed instructions
          if (instr_compressed) begin
            if_id_pipe_o.compressed_instr      <= prefetch_instr.bus_resp.rdata[15:0];
          end
        end

        // For pointers, we want to update the if_id_pipe.ptr field, but also any associated error conditions from bus or MPU.
        if (ptr_in_if_o) begin
          // Update pointer value
          if_id_pipe_o.ptr                <= instr_decompressed.bus_resp.rdata;

          // Need to update bus error status and mpu status, but may omit the 32-bit instruction word
          if_id_pipe_o.instr.bus_resp.err <= instr_decompressed.bus_resp.err;
          if_id_pipe_o.instr.mpu_status   <= instr_decompressed.mpu_status;
        end else begin
          // Regular instruction, update the whole instr field
          if_id_pipe_o.instr          <= seq_valid ? seq_instr : instr_decompressed;
        end
      end else if (id_ready_i) begin
        if_id_pipe_o.instr_valid      <= 1'b0;
      end
    end
  end

  cv32e40x_compressed_decoder
  #(
      .ZC_EXT ( ZC_EXT ),
      .B_EXT  ( B_EXT  ),
      .M_EXT  ( M_EXT  )
  )
  compressed_decoder_i
  (
    .instr_i            ( prefetch_instr          ),
    .instr_is_ptr_i     ( ptr_in_if_o             ),
    .instr_o            ( instr_decompressed      ),
    .is_compressed_o    ( instr_compressed        ),
    .illegal_instr_o    ( illegal_c_insn          )
  );

  // Setting predec_ready to id_ready_i here instead of passing it through the predecoder.
  // Predecoder is purely combinatorial and is always ready for new inputs
  assign predec_ready = id_ready_i;

  // Sequencer gets valid inputs regardless of known error conditions
  // Error conditions will cause a 'deassert_we' in the ID stage and exceptions
  // will be taken from WB with no side effects performed.
  assign seq_instr_valid = prefetch_valid;

  generate
    if (ZC_EXT) begin : gen_seq
      cv32e40x_sequencer
        #(.RV32(RV32))
      sequencer_i
      (
        .clk                  ( clk                     ),
        .rst_n                ( rst_n                   ),

        .jvt_mode_i           ( jvt_mode_i              ),

        .instr_i              ( prefetch_instr          ),
        .instr_is_clic_ptr_i  ( prefetch_is_clic_ptr    ),
        .instr_is_mret_ptr_i  ( prefetch_is_mret_ptr    ),
        .instr_is_tbljmp_ptr_i( prefetch_is_tbljmp_ptr  ),

        .valid_i              ( seq_instr_valid         ),
        .ready_i              ( id_ready_i              ),
        .halt_i               ( ctrl_fsm_i.halt_if      ),
        .kill_i               ( ctrl_fsm_i.kill_if      ),


        .instr_o              ( seq_instr               ),
        .valid_o              ( seq_valid               ),
        .ready_o              ( seq_ready               ),
        .seq_first_o          ( seq_first               ),
        .seq_last_o           ( seq_last                ),
        .seq_tbljmp_o         ( seq_tbljmp              ),
        .seq_pushpop_o        ( seq_pushpop             )
      );
    end else begin : gen_no_seq
      assign seq_valid   = 1'b0;
      assign seq_last    = 1'b0;
      assign seq_instr   = '0;
      assign seq_ready   = 1'b1;
      assign seq_first   = 1'b0;
      assign seq_tbljmp  = 1'b0;
      assign seq_pushpop = 1'b0;
    end
  endgenerate



  //---------------------------------------------------------------------------
  // eXtension interface
  //---------------------------------------------------------------------------

  generate
    if (X_EXT) begin : x_ext

      // TODO:XIF implement offloading of compressed instruction
      assign xif_compressed_if.compressed_valid = '0;
      assign xif_compressed_if.compressed_req   = '0;

      // TODO:XIF assert that the oustanding IDs are unique
      assign xif_id = xif_offloading_id_i ? if_id_pipe_o.xif_id + 1 : if_id_pipe_o.xif_id;

    end else begin : no_x_ext

      assign xif_compressed_if.compressed_valid = '0;
      assign xif_compressed_if.compressed_req   = '0;

      assign xif_id                             = '0;

    end
  endgenerate


  // Some signals are unused on purpose. Use them here for easier LINT waiving.
  assign unused_signals = |prefetch_outstnd_cnt_q;

endmodule







































// Description:    Computes pc target for jumps and branches                  //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_pc_target import cv32e40x_pkg::*;
  (
   input  bch_jmp_mux_e               bch_jmp_mux_sel_i,
   input  logic [31:0]                pc_id_i,
   input  logic [31:0]                imm_uj_type_i,
   input  logic [31:0]                imm_sb_type_i,
   input  logic [31:0]                imm_i_type_i,
   input  logic [31:0]                jalr_fw_i,
   input  logic [JVT_ADDR_WIDTH-1:0]  jvt_addr_i,
   input  logic [7:0]                 jvt_index_i,
   output logic [31:0]                bch_target_o,
   output logic [31:0]                jmp_target_o
  );

  logic [31:0] pc_target;

  assign bch_target_o = pc_target;
  assign jmp_target_o = pc_target; // Used for both regular jumps and tablejumps

  always_comb begin : pc_target_mux
    unique case (bch_jmp_mux_sel_i)
      CT_TBLJMP: pc_target = {jvt_addr_i, {(32-JVT_ADDR_WIDTH){1'b0}}} + {22'd0, jvt_index_i, 2'b00};
      CT_JAL:    pc_target = pc_id_i   + imm_uj_type_i;
      CT_BCH:    pc_target = pc_id_i   + imm_sb_type_i;
      CT_JALR:   pc_target = jalr_fw_i + imm_i_type_i;    // Forward from WB, but only of ALU result
      default:   pc_target = jalr_fw_i + imm_i_type_i;
    endcase
  end
endmodule



// Description:    Decoder for the RV32I Base Instruction set                 //
//                 Custom instruction WFE is also decoded in the I decoder    //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_i_decoder import cv32e40x_pkg::*;
#(
    parameter bit CLIC              = 1
)
(
   // from IF/ID pipeline
   input logic [31:0] instr_rdata_i,
   input logic        tbljmp_i,      // instruction is a tablejump, mapped to JAL
   input  ctrl_fsm_t     ctrl_fsm_i,
   output decoder_ctrl_t decoder_ctrl_o
);

  localparam CUSTOM_EXT = 1;

  always_comb
  begin

    // Default assignments
    decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
    decoder_ctrl_o.illegal_insn = 1'b0;

    unique case (instr_rdata_i[6:0])

      //////////////////////////////////////
      //      _ _   _ __  __ ____  ____   //
      //     | | | | |  \/  |  _ \/ ___|  //
      //  _  | | | | | |\/| | |_) \___ \  //
      // | |_| | |_| | |  | |  __/ ___) | //
      //  \___/ \___/|_|  |_|_|   |____/  //
      //                                  //
      //////////////////////////////////////

      OPCODE_JAL: begin // Jump and Link
        decoder_ctrl_o.alu_en                       = 1'b1;             // ALU computes link address (PC+2/4)
        decoder_ctrl_o.alu_jmp                      = 1'b1;
        decoder_ctrl_o.alu_jmpr                     = 1'b0;             // No register used (rf_re[0] = 0) (used for hazard detection)
        decoder_ctrl_o.alu_op_a_mux_sel             = OP_A_CURRPC;
        decoder_ctrl_o.alu_op_b_mux_sel             = OP_B_IMM;         // PC increment (2 or 4) for link address
        decoder_ctrl_o.imm_b_mux_sel                = IMMB_PCINCR;
        decoder_ctrl_o.alu_operator                 = ALU_ADD;
        decoder_ctrl_o.rf_we                        = 1'b1;             // Write LR
        decoder_ctrl_o.rf_re[0]                     = 1'b0;             // Calculate jump target (= PC + UJ imm)
        decoder_ctrl_o.rf_re[1]                     = 1'b0;             // Calculate jump target (= PC + UJ imm)
        decoder_ctrl_o.bch_jmp_mux_sel              = tbljmp_i ? CT_TBLJMP : CT_JAL; // Zc tablejumps are mapped to JAL, but require their own mux selector for target computation.
      end

      OPCODE_JALR: begin // Jump and Link Register
        if (instr_rdata_i[14:12] != 3'b0) begin
          decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
        end else begin
          decoder_ctrl_o.alu_en                     = 1'b1;             // ALU computes link address (PC+2/4)
          decoder_ctrl_o.alu_jmp                    = 1'b1;
          decoder_ctrl_o.alu_jmpr                   = 1'b1;             // Register used (rf_re[0] = 1) (used for hazard detection)
          decoder_ctrl_o.alu_op_a_mux_sel           = OP_A_CURRPC;
          decoder_ctrl_o.alu_op_b_mux_sel           = OP_B_IMM;         // PC increment (2 or 4) for link address
          decoder_ctrl_o.imm_b_mux_sel              = IMMB_PCINCR;
          decoder_ctrl_o.alu_operator               = ALU_ADD;
          decoder_ctrl_o.rf_we                      = 1'b1;             // Write LR
          decoder_ctrl_o.rf_re[0]                   = 1'b1;             // Calculate jump target (= RS1 + I imm)
          decoder_ctrl_o.rf_re[1]                   = 1'b0;             // Calculate jump target (= RS1 + I imm)
          decoder_ctrl_o.bch_jmp_mux_sel            = CT_JALR;
        end
      end

      OPCODE_BRANCH: begin // Branch
        decoder_ctrl_o.alu_en                       = 1'b1;
        decoder_ctrl_o.alu_bch                      = 1'b1;
        decoder_ctrl_o.alu_op_a_mux_sel             = OP_A_REGA_OR_FWD;
        decoder_ctrl_o.alu_op_b_mux_sel             = OP_B_REGB_OR_FWD;
        decoder_ctrl_o.op_c_mux_sel                 = OP_C_BCH;
        decoder_ctrl_o.rf_we                        = 1'b0;             // No result write
        decoder_ctrl_o.rf_re[0]                     = 1'b1;
        decoder_ctrl_o.rf_re[1]                     = 1'b1;
        decoder_ctrl_o.bch_jmp_mux_sel              = CT_BCH;

        unique case (instr_rdata_i[14:12])
          3'b000: decoder_ctrl_o.alu_operator = ALU_EQ;
          3'b001: decoder_ctrl_o.alu_operator = ALU_NE;
          3'b100: decoder_ctrl_o.alu_operator = ALU_LT;
          3'b101: decoder_ctrl_o.alu_operator = ALU_GE;
          3'b110: decoder_ctrl_o.alu_operator = ALU_LTU;
          3'b111: decoder_ctrl_o.alu_operator = ALU_GEU;
          default: begin
            decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
          end
        endcase
      end

      //////////////////////////////////
      //  _     ____    ______ _____  //
      // | |   |  _ \  / / ___|_   _| //
      // | |   | | | |/ /\___ \ | |   //
      // | |___| |_| / /  ___) || |   //
      // |_____|____/_/  |____/ |_|   //
      //                              //
      //////////////////////////////////

      OPCODE_STORE: begin
        decoder_ctrl_o.lsu_en           = 1'b1;
        decoder_ctrl_o.lsu_we           = 1'b1;
        decoder_ctrl_o.rf_re[0]         = 1'b1;
        decoder_ctrl_o.rf_re[1]         = 1'b1;
        decoder_ctrl_o.alu_op_a_mux_sel = OP_A_REGA_OR_FWD;
        decoder_ctrl_o.alu_op_b_mux_sel = OP_B_IMM;             // Offset from immediate
        decoder_ctrl_o.op_c_mux_sel     = OP_C_REGB_OR_FWD;     // Used for write data
        decoder_ctrl_o.imm_b_mux_sel    = IMMB_S;

        // Data size encoded in instr_rdata_i[13:12]:
        // 2'b00: SB, 2'b01: SH, 2'10: SW
        decoder_ctrl_o.lsu_size = instr_rdata_i[13:12];

        if ((instr_rdata_i[14] == 1'b1) || (instr_rdata_i[13:12] == 2'b11)) begin
          decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
        end
      end

      OPCODE_LOAD: begin
        decoder_ctrl_o.lsu_en           = 1'b1;
        decoder_ctrl_o.rf_we            = 1'b1;
        decoder_ctrl_o.rf_re[0]         = 1'b1;
        decoder_ctrl_o.alu_op_a_mux_sel = OP_A_REGA_OR_FWD;
        decoder_ctrl_o.alu_op_b_mux_sel = OP_B_IMM;             // Offset from immediate
        decoder_ctrl_o.op_c_mux_sel     = OP_C_NONE;
        decoder_ctrl_o.imm_b_mux_sel    = IMMB_I;

        // Sign/zero extension
        decoder_ctrl_o.lsu_sext = !instr_rdata_i[14];

        // Data size encoded in instr_rdata_i[13:12]:
        // 2'b00: LB, 2'b01: LH, 2'10: LW
        decoder_ctrl_o.lsu_size = instr_rdata_i[13:12];

        // Reserved or RV64
        if ((instr_rdata_i[14:12] == 3'b111) || (instr_rdata_i[14:12] == 3'b110) || (instr_rdata_i[14:12] == 3'b011)) begin
          decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
        end
      end

      //////////////////////////
      //     _    _    _   _  //
      //    / \  | |  | | | | //
      //   / _ \ | |  | | | | //
      //  / ___ \| |__| |_| | //
      // /_/   \_\_____\___/  //
      //                      //
      //////////////////////////

      OPCODE_LUI: begin // Load Upper Immediate
        decoder_ctrl_o.alu_en           = 1'b1;
        decoder_ctrl_o.alu_op_a_mux_sel = OP_A_IMM;
        decoder_ctrl_o.alu_op_b_mux_sel = OP_B_IMM;
        decoder_ctrl_o.imm_a_mux_sel    = IMMA_ZERO;
        decoder_ctrl_o.imm_b_mux_sel    = IMMB_U;
        decoder_ctrl_o.alu_operator     = ALU_ADD;
        decoder_ctrl_o.rf_we            = 1'b1;
      end

      OPCODE_AUIPC: begin // Add Upper Immediate to PC
        decoder_ctrl_o.alu_en           = 1'b1;
        decoder_ctrl_o.alu_op_a_mux_sel = OP_A_CURRPC;
        decoder_ctrl_o.alu_op_b_mux_sel = OP_B_IMM;
        decoder_ctrl_o.imm_b_mux_sel    = IMMB_U;
        decoder_ctrl_o.alu_operator     = ALU_ADD;
        decoder_ctrl_o.rf_we            = 1'b1;
      end

      OPCODE_OPIMM: begin // Register-Immediate ALU Operations
        decoder_ctrl_o.alu_en           = 1'b1;
        decoder_ctrl_o.alu_op_a_mux_sel = OP_A_REGA_OR_FWD;
        decoder_ctrl_o.alu_op_b_mux_sel = OP_B_IMM;
        decoder_ctrl_o.imm_b_mux_sel    = IMMB_I;
        decoder_ctrl_o.rf_we            = 1'b1;
        decoder_ctrl_o.rf_re[0]         = 1'b1;

        unique case (instr_rdata_i[14:12])
          3'b000: decoder_ctrl_o.alu_operator = ALU_ADD;  // Add Immediate
          3'b010: decoder_ctrl_o.alu_operator = ALU_SLT;  // Set to one if Lower Than Immediate
          3'b011: decoder_ctrl_o.alu_operator = ALU_SLTU; // Set to one if Lower Than Immediate Unsigned
          3'b100: decoder_ctrl_o.alu_operator = ALU_XOR;  // Exclusive Or with Immediate
          3'b110: decoder_ctrl_o.alu_operator = ALU_OR;   // Or with Immediate
          3'b111: decoder_ctrl_o.alu_operator = ALU_AND;  // And with Immediate

          3'b001: begin
            decoder_ctrl_o.alu_operator = ALU_SLL;        // Shift Left Logical by Immediate
            if (instr_rdata_i[31:25] != 7'b0) begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end

          3'b101: begin
            if (instr_rdata_i[31:25] == 7'b0) begin
              decoder_ctrl_o.alu_operator = ALU_SRL;      // Shift Right Logical by Immediate
            end else if (instr_rdata_i[31:25] == 7'b010_0000) begin
              decoder_ctrl_o.alu_operator = ALU_SRA;      // Shift Right Arithmetically by Immediate
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end
          default:;
        endcase
      end

      OPCODE_OP: begin  // Register-Register ALU operation
        if ((instr_rdata_i[31:30] == 2'b11) || (instr_rdata_i[31:30] == 2'b10)) begin
          decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
        end else begin
          decoder_ctrl_o.alu_en           = 1'b1;
          decoder_ctrl_o.alu_op_a_mux_sel = OP_A_REGA_OR_FWD;
          decoder_ctrl_o.alu_op_b_mux_sel = OP_B_REGB_OR_FWD;
          decoder_ctrl_o.rf_we            = 1'b1;
          decoder_ctrl_o.rf_re[0]         = 1'b1;

          if (!instr_rdata_i[28]) begin
            decoder_ctrl_o.rf_re[1] = 1'b1;
          end

          unique case ({instr_rdata_i[30:25], instr_rdata_i[14:12]})
            // RV32I ALU operations
            {6'b00_0000, 3'b000}: decoder_ctrl_o.alu_operator = ALU_ADD;  // Add
            {6'b10_0000, 3'b000}: decoder_ctrl_o.alu_operator = ALU_SUB;  // Sub
            {6'b00_0000, 3'b010}: decoder_ctrl_o.alu_operator = ALU_SLT;  // Set Lower Than
            {6'b00_0000, 3'b011}: decoder_ctrl_o.alu_operator = ALU_SLTU; // Set Lower Than Unsigned
            {6'b00_0000, 3'b100}: decoder_ctrl_o.alu_operator = ALU_XOR;  // Xor
            {6'b00_0000, 3'b110}: decoder_ctrl_o.alu_operator = ALU_OR;   // Or
            {6'b00_0000, 3'b111}: decoder_ctrl_o.alu_operator = ALU_AND;  // And
            {6'b00_0000, 3'b001}: decoder_ctrl_o.alu_operator = ALU_SLL;  // Shift Left Logical
            {6'b00_0000, 3'b101}: decoder_ctrl_o.alu_operator = ALU_SRL;  // Shift Right Logical
            {6'b10_0000, 3'b101}: decoder_ctrl_o.alu_operator = ALU_SRA;  // Shift Right Arithmetic
            default: begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          endcase
        end
      end

      ////////////////////////////////////////////////
      //  ____  ____  _____ ____ ___    _    _      //
      // / ___||  _ \| ____/ ___|_ _|  / \  | |     //
      // \___ \| |_) |  _|| |    | |  / _ \ | |     //
      //  ___) |  __/| |__| |___ | | / ___ \| |___  //
      // |____/|_|   |_____\____|___/_/   \_\_____| //
      //                                            //
      ////////////////////////////////////////////////

      OPCODE_FENCE: begin
        decoder_ctrl_o.sys_en = 1'b1;
        unique case (instr_rdata_i[14:12])
          3'b000: begin // FENCE
            // Flush pipeline
            decoder_ctrl_o.sys_fence_insn = 1'b1;
          end

          3'b001: begin // FENCE.I
            // Flush prefetch buffer, flush pipeline
            decoder_ctrl_o.sys_fencei_insn = 1'b1;
          end

          default: begin
            decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
          end
        endcase
      end

      OPCODE_SYSTEM: begin
        if (instr_rdata_i[14:12] == 3'b000) begin // Non CSR related SYSTEM instructions
          if ({instr_rdata_i[19:15], instr_rdata_i[11:7]} == '0) begin
            decoder_ctrl_o.sys_en = 1'b1;

            unique case (instr_rdata_i[31:20])
              12'h000: begin // ecall
                // Environment (system) call
                decoder_ctrl_o.sys_ecall_insn  = 1'b1;
              end

              12'h001: begin // ebreak
                // Debugger trap
                decoder_ctrl_o.sys_ebrk_insn = 1'b1;
              end

              12'h302: begin // mret
                // Safe to use ctrl_fsm_i.debug_mode. It is either set to 1 on a debug entry after killing the pipeline or
                // 0 after a dret which also kills the pipeline.
                if (ctrl_fsm_i.debug_mode) begin
                  decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
                end else begin
                  decoder_ctrl_o.sys_mret_insn = 1'b1;
                end
              end

              12'h7b2: begin // dret
                // Safe to use ctrl_fsm_i.debug_mode. It is either set to 1 on a debug entry after killing the pipeline or
                // 0 after a dret which also kills the pipeline.
                if (ctrl_fsm_i.debug_mode) begin
                  decoder_ctrl_o.sys_dret_insn    =  1'b1;
                end else begin
                  decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
                end
              end

              12'h105: begin // wfi
                // Suppressing WFI in case of ctrl_fsm_i.debug_no_sleep to prevent sleeping when not allowed.
                // Using ctrl_fsm_i.debug_no sleep is safe because the fan-ins can only change when the pipeline is killed:
                //  ctrl_fsm_o.debug_no_sleep = debug_mode_q || dcsr_i.step; from the controller_fsm
                //  debug_mode can only change after debug entry or dret, both kills the pipeline
                //  dcsr_i.step can only change during debug mode, and will only take effect once outside of debug mode
                //  which again requires a dret that kills the pipeline.
                decoder_ctrl_o.sys_wfi_insn = ctrl_fsm_i.debug_no_sleep ? 1'b0 : 1'b1;
              end

              12'h8C0: begin // wfe
                if (CUSTOM_EXT == 1) begin
                  // Suppressing WFE in case of ctrl_fsm_i.debug_no_sleep to prevent sleeping when not allowed.
                  // See comment about usage of ctrl_fsm_i.debug_no_sleep for the WFI instruction.
                  decoder_ctrl_o.sys_wfe_insn = ctrl_fsm_i.debug_no_sleep ? 1'b0 : 1'b1;
                end else begin
                  decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
                end
              end

              default: begin
                decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
              end
            endcase
          end else begin // if ({instr_rdata_i[19:15], instr_rdata_i[11:7]} == '0)
            decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
          end
        end else begin // CSR instructions
          decoder_ctrl_o.csr_en = 1'b1;
          decoder_ctrl_o.rf_we  = 1'b1;

          if (instr_rdata_i[14] == 1'b1) begin
            // rs1 field is used as immediate
            decoder_ctrl_o.alu_op_a_mux_sel = OP_A_IMM;
          end else begin
            decoder_ctrl_o.rf_re[0]         = 1'b1;
            decoder_ctrl_o.alu_op_a_mux_sel = OP_A_REGA_OR_FWD;
          end

          decoder_ctrl_o.alu_op_b_mux_sel = OP_B_IMM;
          decoder_ctrl_o.imm_a_mux_sel    = IMMA_Z;
          decoder_ctrl_o.imm_b_mux_sel    = IMMB_I; // CSR address is encoded in I imm

          // instr_rdata_i[19:14] = rs or immediate value
          // If set or clear with rs==x0 or imm==0, then do not perform a write action
          unique case (instr_rdata_i[13:12])
            2'b01:   decoder_ctrl_o.csr_op = CSR_OP_WRITE;
            2'b10:   decoder_ctrl_o.csr_op = (instr_rdata_i[19:15] == 5'b0) ? CSR_OP_READ : CSR_OP_SET;
            2'b11:   decoder_ctrl_o.csr_op = (instr_rdata_i[19:15] == 5'b0) ? CSR_OP_READ : CSR_OP_CLEAR;
            default: decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
          endcase

          if (CLIC) begin
            // The mscratchcswl CSR is only accessible using CSRRW with neither rd nor rs1 set to x0
            if (instr_rdata_i[31:20] == CSR_MSCRATCHCSWL) begin
              if (instr_rdata_i[14:12] == 3'b001) begin // CSRRW
                if ((instr_rdata_i[11:7] == 5'b0) || (instr_rdata_i[19:15] == 5'b0)) begin
                  // rd or rs1 is zero, flag instruction as illegal
                  decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
                end
              end else begin
                // Not a CSRRW instruction, flag illegal
                decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
              end
            end

            // Mnxti is only accessible using CSRR (CSRRS rd, csr, x0), CSRRSI or CSRRCI
            // In addition, when using CSRRSI, if immediate bits 0, 2 or 4 is set the instruction is reserved (illegal in cv32e40x case)
            if ((instr_rdata_i[31:20] == CSR_MNXTI)) begin
              if (instr_rdata_i[14:12] == 3'b010) begin // CSRRS
                // Only legal if rs1 == x0
                if (instr_rdata_i[19:15] != 5'b0) begin
                  decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
                end
              end else if (instr_rdata_i[14:12] == 3'b110) begin // CSRRSI
                // Only legal if immediate 0,2 and 4 is zero
                if (instr_rdata_i[19] || instr_rdata_i[17] || instr_rdata_i[15]) begin
                  decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
                end
              end else begin
                // Not CSRR or CSRRSI
                // Illegal unless instruction is CSRRCI
                if (instr_rdata_i[14:12] != 3'b111) begin
                  decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
                end
              end
            end
          end // CLIC
        end
      end

      default: begin
        decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
      end
    endcase

  end // always_comb

endmodule





// Description:    Decoder for the RV32A extension                            //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_a_decoder import cv32e40x_pkg::*;
  #(
      parameter a_ext_e A_EXT = A
  )
  (
   // from IF/ID pipeline
   input logic [31:0] instr_rdata_i,

   output             decoder_ctrl_t decoder_ctrl_o
   );

  localparam A_LRSC = (A_EXT == A) || (A_EXT == ZALRSC);
  localparam A_AMO  = (A_EXT == A);

  always_comb
  begin

    // Default assignments
    decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
    decoder_ctrl_o.illegal_insn = 1'b0;

    unique case (instr_rdata_i[6:0])

      OPCODE_AMO: begin
        if (instr_rdata_i[14:12] == 3'b010) begin // RV32A Extension (word)
          decoder_ctrl_o.lsu_en           = 1'b1;
          decoder_ctrl_o.rf_re[0]         = 1'b1;
          decoder_ctrl_o.rf_we            = 1'b1;
          decoder_ctrl_o.alu_op_a_mux_sel = OP_A_REGA_OR_FWD;
          decoder_ctrl_o.alu_op_b_mux_sel = OP_B_NONE;
          decoder_ctrl_o.lsu_size         = 2'b10; // All atomics are 32-bit word accesses
          decoder_ctrl_o.lsu_sext         = 1'b1;
          decoder_ctrl_o.lsu_atop         = {1'b1, instr_rdata_i[31:27]};

          unique case (instr_rdata_i[31:27])
            AMO_LR: begin
              if (A_LRSC) begin
                decoder_ctrl_o.rf_re[1]     = 1'b0;
                decoder_ctrl_o.op_c_mux_sel = OP_C_NONE;
                decoder_ctrl_o.lsu_we       = 1'b0;
                if (instr_rdata_i[24:20] != 5'b00000) begin
                  decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
                end
              end else begin
                decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
              end
            end
            AMO_SC: begin
              if (A_LRSC) begin
                decoder_ctrl_o.rf_re[1]     = 1'b1;             // Used for operand C
                decoder_ctrl_o.op_c_mux_sel = OP_C_REGB_OR_FWD; // Used for write data
                decoder_ctrl_o.lsu_we       = 1'b1;
              end else begin
                decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
              end
            end
            AMO_SWAP,
            AMO_ADD,
            AMO_XOR,
            AMO_AND,
            AMO_OR,
            AMO_MIN,
            AMO_MAX,
            AMO_MINU,
            AMO_MAXU: begin
              if (A_AMO) begin
                decoder_ctrl_o.rf_re[1]     = 1'b1;             // Used for operand C
                decoder_ctrl_o.op_c_mux_sel = OP_C_REGB_OR_FWD; // Used for write data
                decoder_ctrl_o.lsu_we       = 1'b1;
              end else begin
                decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
              end
            end
            default : begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          endcase
        end
        else begin
          // No match
          decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
        end
      end

      default: begin
        // No match
        decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
      end
    endcase

  end

endmodule




// Description:    Decoder for the RV32B extension                            //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_b_decoder import cv32e40x_pkg::*;
#(
  parameter b_ext_e B_EXT  = B_NONE
)
(
  // from IF/ID pipeline
  input logic [31:0] instr_rdata_i,
  output             decoder_ctrl_t decoder_ctrl_o
);

  localparam RV32B_ZBA = (B_EXT == ZBA_ZBB) || (B_EXT == ZBA_ZBB_ZBS) || (B_EXT == ZBA_ZBB_ZBC_ZBS);
  localparam RV32B_ZBB = (B_EXT == ZBA_ZBB) || (B_EXT == ZBA_ZBB_ZBS) || (B_EXT == ZBA_ZBB_ZBC_ZBS);
  localparam RV32B_ZBS = (B_EXT == ZBA_ZBB_ZBS) || (B_EXT == ZBA_ZBB_ZBC_ZBS);
  localparam RV32B_ZBC = (B_EXT == ZBA_ZBB_ZBC_ZBS);

  always_comb
  begin

    // Default assignments
    decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
    decoder_ctrl_o.illegal_insn = 1'b0;

    unique case (instr_rdata_i[6:0])

      OPCODE_OP: begin
        decoder_ctrl_o.alu_en           = 1'b1;
        decoder_ctrl_o.alu_op_a_mux_sel = OP_A_REGA_OR_FWD;
        decoder_ctrl_o.alu_op_b_mux_sel = OP_B_REGB_OR_FWD;
        decoder_ctrl_o.rf_re[0]         = 1'b1;
        decoder_ctrl_o.rf_re[1]         = 1'b1;
        decoder_ctrl_o.rf_we            = 1'b1;

        unique case ({instr_rdata_i[31:25], instr_rdata_i[14:12]})

          // Supported RV32B Zca instructions
          {7'b001_0000, 3'b010}: begin // Shift left by 1 and add (sh1add)
            if (RV32B_ZBA) begin
              decoder_ctrl_o.alu_operator = ALU_B_SH1ADD;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end
          {7'b001_0000, 3'b100}: begin // Shift left by 2 and add (sh2add)
            if (RV32B_ZBA) begin
              decoder_ctrl_o.alu_operator = ALU_B_SH2ADD;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end
          {7'b001_0000, 3'b110}: begin // Shift left by 3 and add (sh3add)
            if (RV32B_ZBA) begin
              decoder_ctrl_o.alu_operator = ALU_B_SH3ADD;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end

          // RVB Zbb
          {7'b0000101, 3'b100}: begin // Return minimum number, signed (min)
            if (RV32B_ZBB) begin
              decoder_ctrl_o.alu_operator = ALU_B_MIN;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end
          {7'b0000101, 3'b101}: begin // Return minimum number, unsigned (minu)
            if (RV32B_ZBB) begin
              decoder_ctrl_o.alu_operator = ALU_B_MINU;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end
          {7'b0000101, 3'b110}: begin // Return maximum number, signed (max)
            if (RV32B_ZBB) begin
              decoder_ctrl_o.alu_operator = ALU_B_MAX;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end
          {7'b0000101, 3'b111}: begin // Return maximum number, signed (maxu)
            if (RV32B_ZBB) begin
              decoder_ctrl_o.alu_operator = ALU_B_MAXU;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end

          {7'b0100000, 3'b111}: begin // Return minimum number, signed (andn)
            if (RV32B_ZBB) begin
              decoder_ctrl_o.alu_operator = ALU_B_ANDN;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end
          {7'b0100000, 3'b110}: begin // Return minimum number, signed (orn)
            if (RV32B_ZBB) begin
              decoder_ctrl_o.alu_operator = ALU_B_ORN;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end
          {7'b0100000, 3'b100}: begin // Return minimum number, signed (xnor)
            if (RV32B_ZBB) begin
              decoder_ctrl_o.alu_operator = ALU_B_XNOR;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end
          {7'b0110000, 3'b001}: begin // Rotate Left (rol)
            if (RV32B_ZBB) begin
              decoder_ctrl_o.alu_operator = ALU_B_ROL;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end
          {7'b0110000, 3'b101}: begin // Rotate Right (ror)
            if (RV32B_ZBB) begin
              decoder_ctrl_o.alu_operator = ALU_B_ROR;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end
          {7'b0000100, 3'b100}: begin // Zero extend halfword (zext.h)
            // zext.h is a subset of the proposed pack instruction in Zbkb
            if (RV32B_ZBB) begin
              decoder_ctrl_o.alu_operator     = ALU_B_ZEXT_H;
              decoder_ctrl_o.alu_op_b_mux_sel = OP_B_NONE;
              decoder_ctrl_o.rf_re[1]         = 1'b0; // rs2 is not read, but field is hardcoded to x0

              if (instr_rdata_i[24:20] != 5'b00000) begin
                decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
              end
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end

          // RVB Zbc
          {7'b0000101, 3'b001}: begin // Carry-less Multiply (clmul)
            if (RV32B_ZBC) begin
              decoder_ctrl_o.alu_operator = ALU_B_CLMUL;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end
          {7'b0000101, 3'b011}: begin // Carry-less Multiply upper bits (clmulh)
            if (RV32B_ZBC) begin
              decoder_ctrl_o.alu_operator = ALU_B_CLMULH;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end
          {7'b0000101, 3'b010}: begin // Carry-less Multiply reversed (clmulr)
            if (RV32B_ZBC) begin
              decoder_ctrl_o.alu_operator = ALU_B_CLMULR;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end

          // RVB Zbs
          {7'b0010100, 3'b001}: begin // Set bit in rs1 at index specified by rs2 (bset)
            if (RV32B_ZBS) begin
              decoder_ctrl_o.alu_operator = ALU_B_BSET;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end
          {7'b0100100, 3'b001}: begin // Clear bit in rs1 at index specified by rs2 (bclr)
            if (RV32B_ZBS) begin
              decoder_ctrl_o.alu_operator = ALU_B_BCLR;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end
          {7'b0110100, 3'b001}: begin // Invert bit in rs1 at index specified by rs2 (binv)
            if (RV32B_ZBS) begin
              decoder_ctrl_o.alu_operator = ALU_B_BINV;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end
          {7'b0100100, 3'b101}: begin // Extract bit from rs1 at index specified by rs2 (bext)
            if (RV32B_ZBS) begin
              decoder_ctrl_o.alu_operator = ALU_B_BEXT;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end

          default: begin
            // No match
            decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
          end
        endcase

      end // case: OPCODE_OP

      OPCODE_OPIMM: begin
        decoder_ctrl_o.alu_en           = 1'b1;
        decoder_ctrl_o.alu_op_a_mux_sel = OP_A_REGA_OR_FWD;
        decoder_ctrl_o.rf_re[0]         = 1'b1;
        decoder_ctrl_o.rf_re[1]         = 1'b0;
        decoder_ctrl_o.rf_we            = 1'b1;

        unique casez ({instr_rdata_i[31:25], instr_rdata_i[24:20], instr_rdata_i[14:12]})
          // RVB Zbb
          {7'b011_0000, 5'b0_0000, 3'b001} : begin
            if (RV32B_ZBB) begin
              decoder_ctrl_o.alu_operator     = ALU_B_CLZ;
              decoder_ctrl_o.alu_op_b_mux_sel = OP_B_NONE;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end
          {7'b011_0000, 5'b0_0001, 3'b001} : begin
            if (RV32B_ZBB) begin
              decoder_ctrl_o.alu_operator     = ALU_B_CTZ;
              decoder_ctrl_o.alu_op_b_mux_sel = OP_B_NONE;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end
          {7'b011_0000, 5'b0_0010, 3'b001} : begin
            if (RV32B_ZBB) begin
              decoder_ctrl_o.alu_operator     = ALU_B_CPOP;
              decoder_ctrl_o.alu_op_b_mux_sel = OP_B_NONE;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end

          {7'b001_0100, 5'b0_0111, 3'b101}: begin
            if (RV32B_ZBB) begin
              decoder_ctrl_o.alu_operator     = ALU_B_ORC_B;
              decoder_ctrl_o.alu_op_b_mux_sel = OP_B_NONE;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end
          {7'b011_0100, 5'b1_1000, 3'b101}: begin
            if (RV32B_ZBB) begin
              decoder_ctrl_o.alu_operator     = ALU_B_REV8;
              decoder_ctrl_o.alu_op_b_mux_sel = OP_B_NONE;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end

          {7'b011_0000, 5'b0_0100, 3'b001}: begin
            if (RV32B_ZBB) begin
              decoder_ctrl_o.alu_operator     = ALU_B_SEXT_B;
              decoder_ctrl_o.alu_op_b_mux_sel = OP_B_NONE;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end
          {7'b011_0000, 5'b0_0101, 3'b001}: begin
            if (RV32B_ZBB) begin
              decoder_ctrl_o.alu_operator     = ALU_B_SEXT_H;
              decoder_ctrl_o.alu_op_b_mux_sel = OP_B_NONE;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end
          {7'b0110000, 5'b?_????, 3'b101}: begin // Rotate Right immediate (rori)
            if (RV32B_ZBB) begin
              decoder_ctrl_o.alu_operator     = ALU_B_ROR;
              decoder_ctrl_o.alu_op_b_mux_sel = OP_B_IMM;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end

          // RVB Zbs immediate
          {7'b0010100, 5'b?_????, 3'b001}: begin // Set bit in rs1 at index specified by immediate (bseti)
            if (RV32B_ZBS) begin
              decoder_ctrl_o.alu_operator     = ALU_B_BSET;
              decoder_ctrl_o.alu_op_b_mux_sel = OP_B_IMM;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end
          {7'b0100100, 5'b?_????, 3'b001}: begin // Clear bit in rs1 at index specified by immediate (bclri)
            if (RV32B_ZBS) begin
              decoder_ctrl_o.alu_operator     = ALU_B_BCLR;
              decoder_ctrl_o.alu_op_b_mux_sel = OP_B_IMM;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end
          {7'b0110100, 5'b?_????, 3'b001}: begin // Invert bit in rs1 at index specified by immediate (binvi)
            if (RV32B_ZBS) begin
              decoder_ctrl_o.alu_operator     = ALU_B_BINV;
              decoder_ctrl_o.alu_op_b_mux_sel = OP_B_IMM;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end
          {7'b0100100, 5'b?_????, 3'b101}: begin // Extract bit from rs1 at index specified by immediate (bexti)
            if (RV32B_ZBS) begin
              decoder_ctrl_o.alu_operator     = ALU_B_BEXT;
              decoder_ctrl_o.alu_op_b_mux_sel = OP_B_IMM;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end

          default: begin
            // No match
            decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
          end
        endcase
      end // case: OPCODE_OPIMM

      default: begin
        // No match
        decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
      end

    endcase // unique case (instr_rdata_i[6:0])

  end // always_comb

endmodule





// Description:    Decoder for the RV32M extension                            //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_m_decoder import cv32e40x_pkg::*;
  #(
    parameter m_ext_e M_EXT = M
    )
  (
   // from IF/ID pipeline
   input logic [31:0] instr_rdata_i,
   output             decoder_ctrl_t decoder_ctrl_o
   );
  
  always_comb
  begin

    // Default assignments
    decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
    decoder_ctrl_o.illegal_insn = 1'b0;

    unique case (instr_rdata_i[6:0])
     
      OPCODE_OP: begin

        // Common signals for all MUL/DIV 
        decoder_ctrl_o.rf_we    = 1'b1;
        decoder_ctrl_o.rf_re[0] = 1'b1;
        decoder_ctrl_o.rf_re[1] = 1'b1;

        // Multiplier and divider has its own operand registers.
        // Settings will be overruled for div(u) and rem(u) which rely on ALU.
        decoder_ctrl_o.alu_op_a_mux_sel = OP_A_NONE;
        decoder_ctrl_o.alu_op_b_mux_sel = OP_B_NONE;
        decoder_ctrl_o.op_c_mux_sel     = OP_C_NONE;

        unique case ({instr_rdata_i[31:25], instr_rdata_i[14:12]})
          // supported RV32M instructions
          {7'b000_0001, 3'b000}: begin // mul
            decoder_ctrl_o.mul_en        = 1'b1;
            decoder_ctrl_o.mul_operator  = MUL_M32;
          end
          {7'b000_0001, 3'b001}: begin // mulh
            decoder_ctrl_o.mul_en           = 1'b1;
            decoder_ctrl_o.mul_signed_mode  = 2'b11;
            decoder_ctrl_o.mul_operator     = MUL_H;
          end
          {7'b000_0001, 3'b010}: begin // mulhsu
            decoder_ctrl_o.mul_en           = 1'b1;
            decoder_ctrl_o.mul_signed_mode  = 2'b01;
            decoder_ctrl_o.mul_operator     = MUL_H;
          end
          {7'b000_0001, 3'b011}: begin // mulhu
            decoder_ctrl_o.mul_en           = 1'b1;
            decoder_ctrl_o.mul_signed_mode  = 2'b00;
            decoder_ctrl_o.mul_operator     = MUL_H;
          end
          {7'b000_0001, 3'b100}: begin // div
            if (M_EXT == M) begin
              decoder_ctrl_o.div_en       = 1'b1;
              decoder_ctrl_o.div_operator = DIV_DIV;
              decoder_ctrl_o.alu_operator = ALU_SLL;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end
          {7'b000_0001, 3'b101}: begin // divu
            if (M_EXT == M) begin
              decoder_ctrl_o.div_en       = 1'b1;
              decoder_ctrl_o.div_operator = DIV_DIVU;
              decoder_ctrl_o.alu_operator = ALU_SLL;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end
          {7'b000_0001, 3'b110}: begin // rem
            if (M_EXT == M) begin
              decoder_ctrl_o.div_en       = 1'b1;
              decoder_ctrl_o.div_operator = DIV_REM;
              decoder_ctrl_o.alu_operator = ALU_SLL;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end
          {7'b000_0001, 3'b111}: begin // remu
            if (M_EXT == M) begin
              decoder_ctrl_o.div_en       = 1'b1;
              decoder_ctrl_o.div_operator = DIV_REMU;
              decoder_ctrl_o.alu_operator = ALU_SLL;
            end else begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          end

          default: begin
            // No match
            decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
          end
        endcase

      end // case: OPCODE_OP
      
      default: begin
        // No match
        decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
      end
      
    endcase // unique case (instr_rdata_i[6:0])
    
  end // always_comb

endmodule





// Description:    Decoder                                                    //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_decoder import cv32e40x_pkg::*;
#(
  parameter rv32_e       RV32                   = RV32I,
  parameter int unsigned REGFILE_NUM_READ_PORTS = 2,
  parameter a_ext_e      A_EXT                  = A_NONE,
  parameter b_ext_e      B_EXT                  = B_NONE,
  parameter m_ext_e      M_EXT                  = M,
  parameter bit          CLIC                   = 1
)
(
  // singals running to/from controller
  input  logic          deassert_we_i,          // deassert we and special insn (exception in IF)

  output logic          sys_en_o,               // System enable
  output logic          illegal_insn_o,         // Illegal instruction encountered
  output logic          sys_ebrk_insn_o,        // Trap instruction encountered
  output logic          sys_mret_insn_o,        // Return from exception instruction encountered (M)
  output logic          sys_dret_insn_o,        // Return from debug (M)
  output logic          sys_ecall_insn_o,       // Environment call (syscall) instruction encountered
  output logic          sys_wfi_insn_o,
  output logic          sys_wfe_insn_o,
  output logic          sys_fence_insn_o,       // fence instruction
  output logic          sys_fencei_insn_o,      // fence.i instruction

  // from IF/ID pipeline
  input  if_id_pipe_t   if_id_pipe_i,

  // ALU signals
  output logic          alu_en_o,               // ALU enable
  output logic          alu_bch_o,              // ALU branch (ALU used for comparison)
  output logic          alu_jmp_o,              // ALU jump (JALR, JALR) (ALU used to compute LR)
  output logic          alu_jmpr_o,             // ALU jump register (JALR) (ALU used to compute LR)
  output alu_opcode_e   alu_operator_o,         // ALU operation selection
  output alu_op_a_mux_e alu_op_a_mux_sel_o,     // Operand a selection: reg value, PC, immediate or zero
  output alu_op_b_mux_e alu_op_b_mux_sel_o,     // Operand b selection: reg value or immediate

  // MUL related control signals
  output mul_opcode_e   mul_operator_o,         // Multiplication operation selection
  output logic          mul_en_o,               // Perform integer multiplication
  output logic [1:0]    mul_signed_mode_o,      // Multiplication in signed mode

  // DIV related control signals
  output div_opcode_e   div_operator_o,         // Division operation selection
  output logic          div_en_o,               // Perform division

  // CSR
  output logic          csr_en_o,               // CSR enable
  output logic          csr_en_raw_o,           // CSR enable without deassert
  output csr_opcode_e   csr_op_o,               // Operation to perform on CSR

  // LSU
  output logic          lsu_en_o,               // Start transaction to data memory
  output logic          lsu_we_o,               // Data memory write enable
  output logic [1:0]    lsu_size_o,             // Data size (byte, half word or word)
  output logic          lsu_sext_o,             // Sign extension on read data from data memory
  output logic [5:0]    lsu_atop_o,             // Atomic memory access

  // Register file related signals
  output logic          rf_we_o,                // Write enable for register file
  output logic [1:0]    rf_re_o,

  input rf_addr_t                           rf_raddr_i[REGFILE_NUM_READ_PORTS],
  input rf_addr_t                           rf_waddr_i,
  output logic [REGFILE_NUM_READ_PORTS-1:0] rf_illegal_raddr_o,

  // Mux selects
  output op_c_mux_e     op_c_mux_sel_o,         // Operand c selection: reg value or jump target
  output imm_a_mux_e    imm_a_mux_sel_o,        // Immediate selection for operand a
  output imm_b_mux_e    imm_b_mux_sel_o,        // Immediate selection for operand b
  output bch_jmp_mux_e  bch_jmp_mux_sel_o,      // Branch / jump target selection

  input  ctrl_fsm_t     ctrl_fsm_i,             // Control signal from controller_fsm

  // Table jump related signals
  input  logic          tbljmp_first_i          // Currently decoding first operation of a table jump
);

  // write enable/request control
  logic       rf_we;
  logic       lsu_en;

  logic       csr_en;
  logic       alu_en;
  logic       mul_en;
  logic       div_en;
  logic       sys_en;

  logic [31:0] instr_rdata;

  logic dec_i_rf_illegal_addr;
  logic dec_a_rf_illegal_addr;
  logic dec_b_rf_illegal_addr;
  logic dec_m_rf_illegal_addr;
  logic rf_illegal_waddr;

  decoder_ctrl_t decoder_i_ctrl, decoder_i_ctrl_int;
  decoder_ctrl_t decoder_m_ctrl, decoder_m_ctrl_int;
  decoder_ctrl_t decoder_a_ctrl, decoder_a_ctrl_int;
  decoder_ctrl_t decoder_b_ctrl, decoder_b_ctrl_int;
  decoder_ctrl_t decoder_ctrl_mux;

  assign instr_rdata = if_id_pipe_i.instr.bus_resp.rdata;

  // Check for illegal GPR address if using RV32E
  genvar rf_rport_idx;
  generate
    for (rf_rport_idx = 0; rf_rport_idx < REGFILE_NUM_READ_PORTS; rf_rport_idx++) begin: gen_rf_raddr_illegal
      assign rf_illegal_raddr_o[rf_rport_idx] = (RV32 == RV32I) ? 1'b0 : rf_raddr_i[rf_rport_idx][4];
    end
  endgenerate

  assign rf_illegal_waddr = (RV32 == RV32I) ? 1'b0 : rf_waddr_i[4];

  // RV32I Base instruction set decoder
  cv32e40x_i_decoder
  #(
    .CLIC             (CLIC            )
  )
  i_decoder_i
  (
    .instr_rdata_i  ( instr_rdata                    ),
    .tbljmp_i       ( if_id_pipe_i.instr_meta.tbljmp ),
    .ctrl_fsm_i     ( ctrl_fsm_i                     ),
    .decoder_ctrl_o ( decoder_i_ctrl_int             )
  );

  assign dec_i_rf_illegal_addr = (decoder_i_ctrl_int.rf_re[0] && rf_illegal_raddr_o[0]) ||
                                 (decoder_i_ctrl_int.rf_re[1] && rf_illegal_raddr_o[1]) ||
                                 (decoder_i_ctrl_int.rf_we    && rf_illegal_waddr);

  // Take illegal compressed instruction and illegal RV32E GPR address into account
  assign decoder_i_ctrl = (dec_i_rf_illegal_addr || if_id_pipe_i.illegal_c_insn) ?
                          DECODER_CTRL_ILLEGAL_INSN :
                          decoder_i_ctrl_int;

  generate
    if (A_EXT != A_NONE) begin: a_decoder
      // RV32A extension decoder
      cv32e40x_a_decoder
      #(
          .A_EXT (A_EXT)
      )
      a_decoder_i
      (
        .instr_rdata_i  ( instr_rdata        ),
        .decoder_ctrl_o ( decoder_a_ctrl_int )
      );

      assign dec_a_rf_illegal_addr = (decoder_a_ctrl_int.rf_re[0] && rf_illegal_raddr_o[0]) ||
                                     (decoder_a_ctrl_int.rf_re[1] && rf_illegal_raddr_o[1]) ||
                                     (decoder_a_ctrl_int.rf_we    && rf_illegal_waddr);

      // Take illegal compressed instruction and illegal RV32E GPR address into account
      assign decoder_a_ctrl = (dec_a_rf_illegal_addr || if_id_pipe_i.illegal_c_insn) ?
                              DECODER_CTRL_ILLEGAL_INSN :
                              decoder_a_ctrl_int;

    end else begin: no_a_decoder
      assign dec_a_rf_illegal_addr = 1'b0;
      assign decoder_a_ctrl = DECODER_CTRL_ILLEGAL_INSN;
    end

    if (B_EXT != B_NONE) begin: b_decoder
      // RV32B extension decoder
      cv32e40x_b_decoder
      #(
        .B_EXT  (B_EXT )
      )
      b_decoder_i
      (
        .instr_rdata_i      ( instr_rdata                        ),
        .decoder_ctrl_o     ( decoder_b_ctrl_int                 )
      );

      assign dec_b_rf_illegal_addr = (decoder_b_ctrl_int.rf_re[0] && rf_illegal_raddr_o[0]) ||
                                     (decoder_b_ctrl_int.rf_re[1] && rf_illegal_raddr_o[1]) ||
                                     (decoder_b_ctrl_int.rf_we    && rf_illegal_waddr);

      // Take illegal compressed instruction and illegal RV32E GPR address into account
      assign decoder_b_ctrl = (dec_b_rf_illegal_addr || if_id_pipe_i.illegal_c_insn) ?
                              DECODER_CTRL_ILLEGAL_INSN :
                              decoder_b_ctrl_int;

    end else begin: no_b_decoder
      assign dec_b_rf_illegal_addr = 1'b0;
      assign decoder_b_ctrl = DECODER_CTRL_ILLEGAL_INSN;
    end

    if (M_EXT != M_NONE) begin: m_decoder
      // RV32M extension decoder
      cv32e40x_m_decoder
        #(
          .M_EXT (M_EXT)
          )
      m_decoder_i
      (
       .instr_rdata_i  ( instr_rdata        ),
       .decoder_ctrl_o ( decoder_m_ctrl_int )
      );

      assign dec_m_rf_illegal_addr = (decoder_m_ctrl_int.rf_re[0] && rf_illegal_raddr_o[0]) ||
                                     (decoder_m_ctrl_int.rf_re[1] && rf_illegal_raddr_o[1]) ||
                                     (decoder_m_ctrl_int.rf_we    && rf_illegal_waddr);

      // Take illegal compressed instruction and illegal RV32E GPR address into account
      assign decoder_m_ctrl = (dec_m_rf_illegal_addr || if_id_pipe_i.illegal_c_insn) ?
                              DECODER_CTRL_ILLEGAL_INSN :
                              decoder_m_ctrl_int;

    end else begin: no_m_decoder
      assign dec_m_rf_illegal_addr = 1'b0;
      assign decoder_m_ctrl = DECODER_CTRL_ILLEGAL_INSN;
    end

  endgenerate

  // Mux control outputs from decoders
  always_comb
  begin
    unique case (1'b1)
      !decoder_m_ctrl.illegal_insn : decoder_ctrl_mux = decoder_m_ctrl; // M decoder got a match
      !decoder_a_ctrl.illegal_insn : decoder_ctrl_mux = decoder_a_ctrl; // A decoder got a match
      !decoder_i_ctrl.illegal_insn : decoder_ctrl_mux = decoder_i_ctrl; // I decoder got a match
      !decoder_b_ctrl.illegal_insn : decoder_ctrl_mux = decoder_b_ctrl; // B decoder got a match
      default                      : decoder_ctrl_mux = DECODER_CTRL_ILLEGAL_INSN; // No match from decoders, illegal instruction
    endcase
  end

  assign alu_en             = decoder_ctrl_mux.alu_en;
  assign alu_bch_o          = decoder_i_ctrl.alu_bch;                           // Only I decoder handles branches/jumps
  assign alu_jmp_o          = decoder_i_ctrl.alu_jmp;                           // Only I decoder handles branches/jumps
  assign alu_jmpr_o         = decoder_i_ctrl.alu_jmpr;                          // Only I decoder handles branches/jumps
  assign alu_operator_o     = decoder_ctrl_mux.alu_operator;
  assign alu_op_a_mux_sel_o = decoder_ctrl_mux.alu_op_a_mux_sel;
  assign alu_op_b_mux_sel_o = decoder_ctrl_mux.alu_op_b_mux_sel;
  assign op_c_mux_sel_o     = decoder_ctrl_mux.op_c_mux_sel;
  assign imm_a_mux_sel_o    = decoder_ctrl_mux.imm_a_mux_sel;
  assign imm_b_mux_sel_o    = decoder_ctrl_mux.imm_b_mux_sel;
  assign bch_jmp_mux_sel_o  = decoder_i_ctrl.bch_jmp_mux_sel;                   // Only I decoder handles branches/jumps
  assign mul_en             = decoder_m_ctrl.mul_en;                            // Only M decoder handles mul/div
  assign mul_operator_o     = decoder_m_ctrl.mul_operator;                      // Only M decoder handles mul/div
  assign mul_signed_mode_o  = decoder_m_ctrl.mul_signed_mode;                   // Only M decoder handles mul/div
  assign div_en             = decoder_m_ctrl.div_en;                            // Only M decoder handles mul/div
  assign div_operator_o     = decoder_m_ctrl.div_operator;                      // Only M decoder handles mul/div
  assign rf_re_o            = decoder_ctrl_mux.rf_re;
  assign rf_we              = decoder_ctrl_mux.rf_we;
  assign csr_en             = decoder_i_ctrl.csr_en;                            // Only I decoder handles CSR
  assign csr_op_o           = decoder_i_ctrl.csr_op;                            // Only I decoder handles CSR
  assign lsu_en             = decoder_ctrl_mux.lsu_en;
  assign lsu_we_o           = decoder_ctrl_mux.lsu_we;
  assign lsu_size_o         = decoder_ctrl_mux.lsu_size;
  assign lsu_sext_o         = decoder_ctrl_mux.lsu_sext;
  assign lsu_atop_o         = decoder_a_ctrl.lsu_atop;                          // Only A decoder handles atomics
  assign sys_en             = decoder_i_ctrl.sys_en;                            // Only I decoder handles SYS
  assign sys_mret_insn_o    = decoder_i_ctrl.sys_mret_insn;                     // Only I decoder handles MRET
  assign sys_dret_insn_o    = decoder_i_ctrl.sys_dret_insn;                     // Only I decoder handles DRET
  assign sys_ebrk_insn_o    = decoder_i_ctrl.sys_ebrk_insn;                     // Only I decoder handles EBREAK
  assign sys_ecall_insn_o   = decoder_i_ctrl.sys_ecall_insn;                    // Only I decoder handles ECALL
  assign sys_wfi_insn_o     = decoder_i_ctrl.sys_wfi_insn;                      // Only I decoder handles WFI
  assign sys_wfe_insn_o     = decoder_i_ctrl.sys_wfe_insn;                      // Only I decoder handles WFE
  assign sys_fence_insn_o   = decoder_i_ctrl.sys_fence_insn;                    // Only I decoder handles FENCE
  assign sys_fencei_insn_o  = decoder_i_ctrl.sys_fencei_insn;                   // Only I decoder handles FENCE.I

  // Suppress control signals
  assign alu_en_o = deassert_we_i ? 1'b0 : alu_en;
  assign sys_en_o = deassert_we_i ? 1'b0 : sys_en;
  assign mul_en_o = deassert_we_i ? 1'b0 : mul_en;
  assign div_en_o = deassert_we_i ? 1'b0 : div_en;
  assign lsu_en_o = deassert_we_i ? 1'b0 : lsu_en;

  assign csr_en_o = deassert_we_i ? 1'b0 : csr_en;

  // rf_we is deasserted with deassert_we as all other enables
  // but also for the first part of a table jump (only the last part write to the link register)
  assign rf_we_o  = (deassert_we_i || tbljmp_first_i) ? 1'b0 : rf_we;

  // Suppress special instruction/illegal instruction bits
  assign illegal_insn_o = deassert_we_i ? 1'b0 : decoder_ctrl_mux.illegal_insn;

  assign csr_en_raw_o = csr_en;

endmodule





// Description:    Decode stage of the core. It decodes the instructions      //
//                 and hosts the register file.                               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_id_stage import cv32e40x_pkg::*;
#(
  parameter rv32_e       RV32                   = RV32I,
  parameter a_ext_e      A_EXT                  = A_NONE,
  parameter b_ext_e      B_EXT                  = B_NONE,
  parameter m_ext_e      M_EXT                  = M,
  parameter bit          X_EXT                  = 0,
  parameter int unsigned REGFILE_NUM_READ_PORTS = 2,
  parameter bit          CLIC                   = 1
)
(
  input  logic        clk,                    // Gated clock
  input  logic        rst_n,

  // Jumps and branches
  output logic [31:0] jmp_target_o,

  // IF/ID pipeline
  input  if_id_pipe_t if_id_pipe_i,

  // ID/EX pipeline
  output id_ex_pipe_t id_ex_pipe_o,

  // EX/WB pipeline
  input  ex_wb_pipe_t ex_wb_pipe_i,

  // Controller
  input  ctrl_byp_t   ctrl_byp_i,
  input  ctrl_fsm_t   ctrl_fsm_i,

  input  mcause_t     mcause_i,
  input  logic [JVT_ADDR_WIDTH-1:0] jvt_addr_i,

  // Register file write data from WB stage
  input  logic [31:0] rf_wdata_wb_i,

  // Register file write data from EX stage
  input  logic [31:0] rf_wdata_ex_i,

  output logic        alu_jmp_o,        // Jump (JAL, JALR)
  output logic        alu_jmpr_o,       // Jump register (JALR)

  output logic        sys_mret_insn_o,

  output logic        csr_en_raw_o,

  output logic        alu_en_o,
  output logic        sys_en_o,

  output logic        first_op_o,
  output logic        last_op_o,
  output logic        abort_op_o,

  // RF interface -> controller
  output logic [REGFILE_NUM_READ_PORTS-1:0] rf_re_o,
  output rf_addr_t    rf_raddr_o[REGFILE_NUM_READ_PORTS],

  // Register file
  input  rf_data_t    rf_rdata_i[REGFILE_NUM_READ_PORTS],

  // Stage ready/valid
  output logic        id_ready_o,     // ID stage is ready for new data
  output logic        id_valid_o,     // ID stage has valid (non-bubble) data for next stage
  input  logic        ex_ready_i,     // EX stage is ready for new data

  // eXtension interface
  cv32e40x_if_xif.cpu_issue xif_issue_if,
  output logic              xif_offloading_o
);

  // Source/Destination register instruction index
  localparam REG_S1_MSB = 19;
  localparam REG_S1_LSB = 15;

  localparam REG_S2_MSB = 24;
  localparam REG_S2_LSB = 20;

  localparam REG_S3_MSB = 31;
  localparam REG_S3_LSB = 27;

  localparam REG_D_MSB  = 11;
  localparam REG_D_LSB  = 7;

  logic [31:0] instr;

  // Register Read/Write Control
  logic [1:0]           rf_re;                  // Decoder only supports rs1, rs2
  logic                 rf_we;
  logic                 rf_we_dec;
  rf_addr_t             rf_waddr;
  logic [REGFILE_NUM_READ_PORTS-1:0] rf_illegal_raddr;

  // ALU Control
  logic                 alu_en;
  logic                 alu_bch;
  logic                 alu_jmp;
  logic                 alu_jmpr;
  alu_opcode_e          alu_operator;

  // Multiplier Control
  logic                 mul_en;                 // Multiplication is used instead of ALU
  mul_opcode_e          mul_operator;           // Multiplication operation selection
  logic [1:0]           mul_signed_mode;        // Signed mode multiplication at the output of the controller, and before the pipe registers

  // Divider control
  logic                 div_en;
  div_opcode_e          div_operator;

  // LSU
  logic                 lsu_en;
  logic                 lsu_we;
  logic [1:0]           lsu_size;
  logic                 lsu_sext;
  logic [5:0]           lsu_atop;               // Atomic memory instruction

  // CSR
  logic                 csr_en;
  logic                 csr_en_raw;
  csr_opcode_e          csr_op;

  // SYS
  logic                 sys_en;
  logic                 sys_fence_insn;
  logic                 sys_fencei_insn;
  logic                 sys_ecall_insn;
  logic                 sys_ebrk_insn;
  logic                 sys_mret_insn;
  logic                 sys_dret_insn;
  logic                 sys_wfi_insn;
  logic                 sys_wfe_insn;

  // Operands and forwarding
  logic [31:0]          operand_a;
  logic [31:0]          operand_b;
  logic [31:0]          operand_c;
  logic [31:0]          operand_a_fw;
  logic [31:0]          operand_b_fw;
  logic [31:0]          jalr_fw;
  alu_op_a_mux_e        alu_op_a_mux_sel;
  alu_op_b_mux_e        alu_op_b_mux_sel;
  op_c_mux_e            op_c_mux_sel;
  imm_a_mux_e           imm_a_mux_sel;
  imm_b_mux_e           imm_b_mux_sel;
  bch_jmp_mux_e         bch_jmp_mux_sel;

  // Immediates
  logic [31:0]          imm_a;                  // Immediate for operand A
  logic [31:0]          imm_b;                  // Immediate for operand B
  logic [31:0]          imm_i_type;
  logic [31:0]          imm_s_type;
  logic [31:0]          imm_sb_type;
  logic [31:0]          imm_u_type;
  logic [31:0]          imm_uj_type;
  logic [31:0]          imm_z_type;

  // Branch target address
  logic [31:0]          bch_target;

  logic                 illegal_insn;

  // Local instruction valid qualifier
  logic                 instr_valid;

  // eXtension interface signals
  logic                 xif_en;
  logic                 xif_waiting;
  logic                 xif_insn_accept;
  logic                 xif_insn_reject;
  logic                 xif_we;
  logic                 xif_exception;
  logic                 xif_dualwrite;
  logic                 xif_loadstore;

  // Signal for detection of first operation (of two) of table jumps.
  logic                 tbljmp_first;

  // Current index for JVT instructions
  logic [7:0]           jvt_index;

  assign instr_valid = if_id_pipe_i.instr_valid && !ctrl_fsm_i.kill_id && !ctrl_fsm_i.halt_id;

  assign sys_mret_insn_o = sys_mret_insn;

  assign instr = if_id_pipe_i.instr.bus_resp.rdata;

  // Immediate extraction and sign extension
  assign imm_i_type   = { {20 {instr[31]}}, instr[31:20] };
  assign imm_s_type   = { {20 {instr[31]}}, instr[31:25], instr[11:7] };
  assign imm_sb_type  = { {19 {instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };
  assign imm_u_type   = { instr[31:12], 12'b0 };
  assign imm_uj_type  = { {12 {instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };

  // Immediate for CSR manipulation (zero extended)
  assign imm_z_type  = { 27'b0, instr[REG_S1_MSB:REG_S1_LSB] };

  //---------------------------------------------------------------------------
  // Source register selection
  //---------------------------------------------------------------------------
  assign rf_raddr_o[0] = instr[REG_S1_MSB:REG_S1_LSB];
  assign rf_raddr_o[1] = instr[REG_S2_MSB:REG_S2_LSB];

  // Assign rs3 address if Xif mandates three read ports
  generate
    if(REGFILE_NUM_READ_PORTS == 3) begin : gen_rs3_raddr
      assign rf_raddr_o[2] = instr[REG_S3_MSB:REG_S3_LSB];
    end
  endgenerate

  //---------------------------------------------------------------------------
  // Destination register seclection
  //---------------------------------------------------------------------------
  assign rf_waddr = instr[REG_D_MSB:REG_D_LSB];

  // Detect first half of table jumps
  assign tbljmp_first = if_id_pipe_i.instr_meta.tbljmp ? !if_id_pipe_i.last_op : 1'b0;

  //////////////////////////////////////////////////////////////////
  //      _                         _____                    _    //
  //     | |_   _ _ __ ___  _ __   |_   _|_ _ _ __ __ _  ___| |_  //
  //  _  | | | | | '_ ` _ \| '_ \    | |/ _` | '__/ _` |/ _ \ __| //
  // | |_| | |_| | | | | | | |_) |   | | (_| | | | (_| |  __/ |_  //
  //  \___/ \__,_|_| |_| |_| .__/    |_|\__,_|_|  \__, |\___|\__| //
  //                       |_|                    |___/           //
  //////////////////////////////////////////////////////////////////

  assign jvt_index = if_id_pipe_i.instr.bus_resp.rdata[19:12];

  cv32e40x_pc_target cv32e40x_pc_target_i
  (
    .bch_jmp_mux_sel_i ( bch_jmp_mux_sel ),
    .pc_id_i           ( if_id_pipe_i.pc ),
    .imm_uj_type_i     ( imm_uj_type     ),
    .imm_sb_type_i     ( imm_sb_type     ),
    .imm_i_type_i      ( imm_i_type      ),
    .jalr_fw_i         ( jalr_fw         ),
    .jvt_addr_i        ( jvt_addr_i      ),
    .jvt_index_i       ( jvt_index       ),
    .bch_target_o      ( bch_target      ),
    .jmp_target_o      ( jmp_target_o    )
  );

  ////////////////////////////////////////////////////////
  //   ___                                 _      _     //
  //  / _ \ _ __   ___ _ __ __ _ _ __   __| |    / \    //
  // | | | | '_ \ / _ \ '__/ _` | '_ \ / _` |   / _ \   //
  // | |_| | |_) |  __/ | | (_| | | | | (_| |  / ___ \  //
  //  \___/| .__/ \___|_|  \__,_|_| |_|\__,_| /_/   \_\ //
  //       |_|                                          //
  ////////////////////////////////////////////////////////

  // Operand A Mux
  always_comb begin : operand_a_mux
    case (alu_op_a_mux_sel)
      OP_A_REGA_OR_FWD:  operand_a = operand_a_fw;
      OP_A_CURRPC:       operand_a = if_id_pipe_i.pc;
      OP_A_IMM:          operand_a = imm_a;
      default:           operand_a = operand_a_fw;
    endcase; // case (alu_op_a_mux_sel)
  end

  always_comb begin : immediate_a_mux
    unique case (imm_a_mux_sel)
      IMMA_Z:      imm_a = imm_z_type;
      IMMA_ZERO:   imm_a = '0;
      default:     imm_a = '0;
    endcase
  end

  // Operand A forwarding mux
  always_comb begin : operand_a_fw_mux
    case (ctrl_byp_i.operand_a_fw_mux_sel)
      SEL_FW_EX:    operand_a_fw = rf_wdata_ex_i;
      SEL_FW_WB:    operand_a_fw = rf_wdata_wb_i;
      SEL_REGFILE:  operand_a_fw = rf_rdata_i[0];
      default:      operand_a_fw = rf_rdata_i[0];
    endcase;
  end

  always_comb begin: jalr_fw_mux
    case (ctrl_byp_i.jalr_fw_mux_sel)
      SELJ_FW_WB:   jalr_fw = ex_wb_pipe_i.rf_wdata;  // todo:XIF This won't allow forwarding from the XIF.
      SELJ_REGFILE: jalr_fw = rf_rdata_i[0];
      default:      jalr_fw = rf_rdata_i[0];
    endcase
  end

  //////////////////////////////////////////////////////
  //   ___                                 _   ____   //
  //  / _ \ _ __   ___ _ __ __ _ _ __   __| | | __ )  //
  // | | | | '_ \ / _ \ '__/ _` | '_ \ / _` | |  _ \  //
  // | |_| | |_) |  __/ | | (_| | | | | (_| | | |_) | //
  //  \___/| .__/ \___|_|  \__,_|_| |_|\__,_| |____/  //
  //       |_|                                        //
  //////////////////////////////////////////////////////

  // Immediate Mux for operand B
  always_comb begin : immediate_b_mux
    unique case (imm_b_mux_sel)
      IMMB_I:      imm_b = imm_i_type;
      IMMB_S:      imm_b = imm_s_type;
      IMMB_U:      imm_b = imm_u_type;
      IMMB_PCINCR: imm_b = if_id_pipe_i.instr_meta.compressed ? 32'h2 : 32'h4;
      default:     imm_b = imm_i_type;
    endcase
  end

  // Operand B Mux
  always_comb begin : operand_b_mux
    case (alu_op_b_mux_sel)
      OP_B_REGB_OR_FWD:  operand_b = operand_b_fw;
      OP_B_IMM:          operand_b = imm_b;
      default:           operand_b = operand_b_fw;
    endcase // case (alu_op_b_mux_sel)
  end

  // Operand B forwarding mux
  always_comb begin : operand_b_fw_mux
    case (ctrl_byp_i.operand_b_fw_mux_sel)
      SEL_FW_EX:    operand_b_fw = rf_wdata_ex_i;
      SEL_FW_WB:    operand_b_fw = rf_wdata_wb_i;
      SEL_REGFILE:  operand_b_fw = rf_rdata_i[1];
      default:      operand_b_fw = rf_rdata_i[1];
    endcase;
  end

  //////////////////////////////////////////////////////
  //   ___                                 _    ____  //
  //  / _ \ _ __   ___ _ __ __ _ _ __   __| |  / ___| //
  // | | | | '_ \ / _ \ '__/ _` | '_ \ / _` | | |     //
  // | |_| | |_) |  __/ | | (_| | | | | (_| | | |___  //
  //  \___/| .__/ \___|_|  \__,_|_| |_|\__,_|  \____| //
  //       |_|                                        //
  //////////////////////////////////////////////////////

  // ALU OP C Mux
  always_comb begin : operand_c_mux
    case (op_c_mux_sel)
      OP_C_REGB_OR_FWD:  operand_c = operand_b_fw;
      OP_C_BCH:          operand_c = bch_target;
      default:           operand_c = operand_b_fw;
    endcase // case (op_c_mux_sel)
  end


  ///////////////////////////////////////////////
  //  ____  _____ ____ ___  ____  _____ ____   //
  // |  _ \| ____/ ___/ _ \|  _ \| ____|  _ \  //
  // | | | |  _|| |  | | | | | | |  _| | |_) | //
  // | |_| | |__| |__| |_| | |_| | |___|  _ <  //
  // |____/|_____\____\___/|____/|_____|_| \_\ //
  //                                           //
  ///////////////////////////////////////////////

  cv32e40x_decoder
  #(
    .RV32                            ( RV32                      ),
    .REGFILE_NUM_READ_PORTS          ( REGFILE_NUM_READ_PORTS    ),
    .A_EXT                           ( A_EXT                     ),
    .B_EXT                           ( B_EXT                     ),
    .M_EXT                           ( M_EXT                     ),
    .CLIC                            ( CLIC                      )
  )
  decoder_i
  (
    // controller related signals
    .deassert_we_i                   ( ctrl_byp_i.deassert_we    ),

    // SYS signals
    .sys_en_o                        ( sys_en                    ),
    .illegal_insn_o                  ( illegal_insn              ),
    .sys_ebrk_insn_o                 ( sys_ebrk_insn             ),
    .sys_mret_insn_o                 ( sys_mret_insn             ),
    .sys_dret_insn_o                 ( sys_dret_insn             ),
    .sys_ecall_insn_o                ( sys_ecall_insn            ),
    .sys_wfi_insn_o                  ( sys_wfi_insn              ),
    .sys_wfe_insn_o                  ( sys_wfe_insn              ),
    .sys_fence_insn_o                ( sys_fence_insn            ),
    .sys_fencei_insn_o               ( sys_fencei_insn           ),

    // from IF/ID pipeline
    .if_id_pipe_i                    ( if_id_pipe_i              ),

    // ALU
    .alu_en_o                        ( alu_en                    ),
    .alu_bch_o                       ( alu_bch                   ),
    .alu_jmp_o                       ( alu_jmp                   ),
    .alu_jmpr_o                      ( alu_jmpr                  ),
    .alu_operator_o                  ( alu_operator              ),
    .alu_op_a_mux_sel_o              ( alu_op_a_mux_sel          ),
    .alu_op_b_mux_sel_o              ( alu_op_b_mux_sel          ),

    // MUL
    .mul_en_o                        ( mul_en                    ),
    .mul_operator_o                  ( mul_operator              ),
    .mul_signed_mode_o               ( mul_signed_mode           ),

    // DIV
    .div_en_o                        ( div_en                    ),
    .div_operator_o                  ( div_operator              ),

    // CSR
    .csr_en_o                        ( csr_en                    ),
    .csr_en_raw_o                    ( csr_en_raw                ),
    .csr_op_o                        ( csr_op                    ),

    // LSU
    .lsu_en_o                        ( lsu_en                    ),
    .lsu_we_o                        ( lsu_we                    ),
    .lsu_size_o                      ( lsu_size                  ),
    .lsu_sext_o                      ( lsu_sext                  ),
    .lsu_atop_o                      ( lsu_atop                  ),

    // Register file control signals
    .rf_re_o                         ( rf_re                     ),
    .rf_we_o                         ( rf_we_dec                 ),
    .rf_raddr_i                      ( rf_raddr_o                ),
    .rf_waddr_i                      ( rf_waddr                  ),
    .rf_illegal_raddr_o              ( rf_illegal_raddr          ),

    // Mux selects
    .imm_a_mux_sel_o                 ( imm_a_mux_sel             ),
    .imm_b_mux_sel_o                 ( imm_b_mux_sel             ),
    .op_c_mux_sel_o                  ( op_c_mux_sel              ),
    .bch_jmp_mux_sel_o               ( bch_jmp_mux_sel           ),

    // From controller fsm
    .ctrl_fsm_i                      ( ctrl_fsm_i                ),

    // Table jump related signals
    .tbljmp_first_i                  ( tbljmp_first              )
  );

  generate
    if (X_EXT) begin : x_ext_rf_re
      // Speculatively read all source registers for illegal instr, might be required by coprocessor
      // Non-offloaded instructions will use maximum two read ports (rf_re from decoder is two bits, rf_re_o may be two or three bits wide)
      // Todo:XIF Too conservative, causes load_use stalls on offloaded instruction when the operands may not be needed at all.
      //       issue_valid depends on halt_id (and data_rvalid) via the local instr_valid.
      //       Can issue_valid be made fast by using the registered instr_valid and only factor in kill_id and not halt_id?
      //       Maybe it is ok to have a late issue_valid, as accept signal will depend on late rs_valid anyway?
      assign rf_re_o = illegal_insn ? '1 : REGFILE_NUM_READ_PORTS'(rf_re);
    end else begin : no_x_ext_rf_re
      assign rf_re_o = rf_re;
    end
  endgenerate

  // Register writeback is enabled either by the decoder or by the XIF
  assign rf_we          = rf_we_dec || xif_we;


  /////////////////////////////////////////////////////////////////////////////////
  //   ___ ____        _______  __  ____ ___ ____  _____ _     ___ _   _ _____   //
  //  |_ _|  _ \      | ____\ \/ / |  _ \_ _|  _ \| ____| |   |_ _| \ | | ____|  //
  //   | || | | |_____|  _|  \  /  | |_) | || |_) |  _| | |    | ||  \| |  _|    //
  //   | || |_| |_____| |___ /  \  |  __/| ||  __/| |___| |___ | || |\  | |___   //
  //  |___|____/      |_____/_/\_\ |_|  |___|_|   |_____|_____|___|_| \_|_____|  //
  //                                                                             //
  /////////////////////////////////////////////////////////////////////////////////

  always_ff @(posedge clk, negedge rst_n)
  begin : ID_EX_PIPE_REGISTERS
    if (rst_n == 1'b0)
    begin
      id_ex_pipe_o.instr_valid            <= 1'b0;
      id_ex_pipe_o.alu_en                 <= 1'b0;
      id_ex_pipe_o.alu_bch                <= 1'b0;
      id_ex_pipe_o.alu_jmp                <= 1'b0;
      id_ex_pipe_o.alu_operator           <= ALU_SLTU;
      id_ex_pipe_o.alu_operand_a          <= 32'b0;
      id_ex_pipe_o.alu_operand_b          <= 32'b0;

      id_ex_pipe_o.operand_c              <= 32'b0;

      id_ex_pipe_o.mul_en                 <= 1'b0;
      id_ex_pipe_o.mul_operator           <= MUL_M32;
      id_ex_pipe_o.mul_signed_mode        <= 2'b0;

      id_ex_pipe_o.div_en                 <= 1'b0;
      id_ex_pipe_o.div_operator           <= DIV_DIVU;

      id_ex_pipe_o.muldiv_operand_a       <= 32'b0;
      id_ex_pipe_o.muldiv_operand_b       <= 32'b0;

      id_ex_pipe_o.csr_en                 <= 1'b0;
      id_ex_pipe_o.csr_op                 <= CSR_OP_READ;

      id_ex_pipe_o.lsu_en                 <= 1'b0;
      id_ex_pipe_o.lsu_we                 <= 1'b0;
      id_ex_pipe_o.lsu_size               <= 2'b0;
      id_ex_pipe_o.lsu_sext               <= 1'b0;
      id_ex_pipe_o.lsu_atop               <= 6'b0;

      id_ex_pipe_o.sys_en                <= 1'b0;
      id_ex_pipe_o.sys_dret_insn         <= 1'b0;
      id_ex_pipe_o.sys_ebrk_insn         <= 1'b0;
      id_ex_pipe_o.sys_ecall_insn        <= 1'b0;
      id_ex_pipe_o.sys_fence_insn        <= 1'b0;
      id_ex_pipe_o.sys_fencei_insn       <= 1'b0;
      id_ex_pipe_o.sys_mret_insn         <= 1'b0;
      id_ex_pipe_o.sys_wfi_insn          <= 1'b0;
      id_ex_pipe_o.sys_wfe_insn          <= 1'b0;

      id_ex_pipe_o.xif_en                 <= 1'b0;
      id_ex_pipe_o.xif_meta               <= '0;

      id_ex_pipe_o.priv_lvl               <= PRIV_LVL_M;
      id_ex_pipe_o.illegal_insn           <= 1'b0;

      id_ex_pipe_o.rf_we                  <= 1'b0;
      id_ex_pipe_o.rf_waddr               <= '0;

        // Exceptions and debug
      id_ex_pipe_o.pc                     <= 32'b0;
      id_ex_pipe_o.instr                  <= INST_RESP_RESET_VAL;
      id_ex_pipe_o.instr_meta             <= '0;
      id_ex_pipe_o.trigger_match          <= '0;

      id_ex_pipe_o.first_op               <= 1'b0;
      id_ex_pipe_o.last_op                <= 1'b0;
      id_ex_pipe_o.abort_op               <= 1'b0;
    end else begin
      // normal pipeline unstall case
      if (id_valid_o && ex_ready_i) begin
        id_ex_pipe_o.priv_lvl     <= if_id_pipe_i.priv_lvl;
        id_ex_pipe_o.instr_valid  <= 1'b1;
        id_ex_pipe_o.last_op      <= last_op_o;
        id_ex_pipe_o.first_op     <= first_op_o;
        id_ex_pipe_o.abort_op     <= abort_op_o;

        // Operands
        if (alu_op_a_mux_sel != OP_A_NONE) begin
          id_ex_pipe_o.alu_operand_a        <= operand_a;               // Used by most ALU, CSR and LSU instructions
        end
        if (alu_op_b_mux_sel != OP_B_NONE) begin
          id_ex_pipe_o.alu_operand_b        <= operand_b;               // Used by most ALU, CSR and LSU instructions
        end

        if (op_c_mux_sel != OP_C_NONE)
        begin
          id_ex_pipe_o.operand_c            <= operand_c;               // Used by LSU stores and some ALU instructions
        end

        id_ex_pipe_o.alu_en                 <= alu_en;
        if (alu_en) begin                                               // Branch comparison and jump link computation are done in ALU
          id_ex_pipe_o.alu_bch              <= alu_bch;
          id_ex_pipe_o.alu_jmp              <= alu_jmp;
        end
        if (alu_en || div_en) begin                                     // ALU and DIV use alu_operator (DIV uses the shifter in the ALU)
          id_ex_pipe_o.alu_operator         <= alu_operator;
        end

        id_ex_pipe_o.div_en                 <= div_en;
        if (div_en) begin
          id_ex_pipe_o.div_operator         <= div_operator;
        end

        id_ex_pipe_o.mul_en                 <= mul_en;
        if (mul_en) begin
          id_ex_pipe_o.mul_operator         <= mul_operator;
          id_ex_pipe_o.mul_signed_mode      <= mul_signed_mode;
        end

        if (mul_en || div_en) begin
          id_ex_pipe_o.muldiv_operand_a     <= operand_a_fw;            // Only register file operand (or forward) is required
          id_ex_pipe_o.muldiv_operand_b     <= operand_b_fw;            // Only register file operand (or forward) is required
        end

        id_ex_pipe_o.csr_en                 <= csr_en;
        if (csr_en) begin
          id_ex_pipe_o.csr_op               <= csr_op;
        end

        id_ex_pipe_o.lsu_en                 <= lsu_en;
        if (lsu_en) begin
          id_ex_pipe_o.lsu_we               <= lsu_we;
          id_ex_pipe_o.lsu_size             <= lsu_size;
          id_ex_pipe_o.lsu_sext             <= lsu_sext;
          id_ex_pipe_o.lsu_atop             <= lsu_atop;
        end

        // Special instructions
        id_ex_pipe_o.sys_en                 <= sys_en;
        if (sys_en) begin
          id_ex_pipe_o.sys_dret_insn        <= sys_dret_insn;
          id_ex_pipe_o.sys_ebrk_insn        <= sys_ebrk_insn;
          id_ex_pipe_o.sys_ecall_insn       <= sys_ecall_insn;
          id_ex_pipe_o.sys_fence_insn       <= sys_fence_insn;
          id_ex_pipe_o.sys_fencei_insn      <= sys_fencei_insn;
          id_ex_pipe_o.sys_mret_insn        <= sys_mret_insn;
          id_ex_pipe_o.sys_wfi_insn         <= sys_wfi_insn;
          id_ex_pipe_o.sys_wfe_insn         <= sys_wfe_insn;
        end

        id_ex_pipe_o.illegal_insn           <= illegal_insn && !xif_insn_accept;

        id_ex_pipe_o.rf_we                  <= rf_we;
        if (rf_we) begin
          id_ex_pipe_o.rf_waddr             <= rf_waddr;
        end

        // Exceptions and debug
        id_ex_pipe_o.pc                     <= if_id_pipe_i.pc;
        id_ex_pipe_o.instr_meta             <= if_id_pipe_i.instr_meta;

        if (if_id_pipe_i.instr_meta.compressed) begin
          // Overwrite instruction word in case of compressed instruction
          id_ex_pipe_o.instr.bus_resp.rdata <= {16'h0, if_id_pipe_i.compressed_instr};
          id_ex_pipe_o.instr.bus_resp.err   <= if_id_pipe_i.instr.bus_resp.err;
          id_ex_pipe_o.instr.mpu_status     <= if_id_pipe_i.instr.mpu_status;
        end else begin
          id_ex_pipe_o.instr                <= if_id_pipe_i.instr;
        end

        id_ex_pipe_o.trigger_match          <= if_id_pipe_i.trigger_match;

        // eXtension interface
        id_ex_pipe_o.xif_en                 <= xif_en;
        id_ex_pipe_o.xif_meta.id            <= if_id_pipe_i.xif_id;
        id_ex_pipe_o.xif_meta.exception     <= xif_exception;
        id_ex_pipe_o.xif_meta.loadstore     <= xif_loadstore;
        id_ex_pipe_o.xif_meta.dualwrite     <= xif_dualwrite;
        id_ex_pipe_o.xif_meta.accepted      <= xif_insn_accept;

      end else if (ex_ready_i) begin
        id_ex_pipe_o.instr_valid            <= 1'b0;
      end
    end
  end

  assign alu_jmp_o    = alu_jmp;
  assign alu_jmpr_o   = alu_jmpr;

  assign csr_en_raw_o = csr_en_raw;

  assign alu_en_o     = alu_en;
  assign sys_en_o     = sys_en;

  // Stage ready/valid
  //
  // Most stall conditions are factored into halt_id (and will force both ready and valid to 0).

  assign id_ready_o = ctrl_fsm_i.kill_id || (ex_ready_i && !ctrl_fsm_i.halt_id && !xif_waiting);

  assign id_valid_o = (instr_valid && !xif_waiting);

  assign first_op_o  = if_id_pipe_i.first_op;
  // An mret with mcause.minhv set  will cause a pointer fetch, and that pointer fetch is the last operation of the mret.
  // Mrets with the mcause conditions not true will be normal single operation instructions.
  // Using CSR signals below is safe, as any implicit CSR read in ID stage is halted if there is an implicit or explicit CSR write
  // in either EX or WB at the same time.
  assign last_op_o   = (sys_en && sys_mret_insn && mcause_i.minhv) ? 1'b0 : if_id_pipe_i.last_op;
  assign abort_op_o  = if_id_pipe_i.abort_op || ctrl_byp_i.id_stage_abort;
  //---------------------------------------------------------------------------
  // eXtension interface
  //---------------------------------------------------------------------------

  generate
    if (X_EXT) begin : x_ext

      // remember whether an instruction was accepted or rejected (required if EX stage is not ready)
      // TODO:XIF check whether this state machine should be put back in its initial state when the instruction in ID gets killed
      logic xif_accepted_q, xif_rejected_q;

      assign xif_en = xif_insn_accept || xif_insn_reject;

      always_ff @(posedge clk, negedge rst_n) begin : ID_XIF_STATE_REGISTERS
        if (rst_n == 1'b0) begin
          xif_accepted_q <= 1'b0;
          xif_rejected_q <= 1'b0;
        end else begin
          if ( (id_valid_o && ex_ready_i) || ctrl_fsm_i.kill_id ) begin
            xif_accepted_q <= 1'b0;
            xif_rejected_q <= 1'b0;
          end else begin
            xif_accepted_q <= xif_insn_accept;
            xif_rejected_q <= xif_insn_reject;
          end
        end
      end

      // attempt to offload every valid instruction that is considered illegal by the decoder
      // Also attempt to offload any CSR instruction. The validity of such instructions are only
      // checked in the EX stage.
      // Instructions with deassert_we set to 1 from the controller bypass logic will not be attempted offloaded.
      assign xif_issue_if.issue_valid     = instr_valid && (illegal_insn || csr_en) &&
                                            !(xif_accepted_q || xif_rejected_q || ctrl_byp_i.deassert_we);

      // Keep xif_offloading_o high after an offloaded instruction was accepted or rejected to get
      // a new instruction ID from the IF stage
      assign xif_offloading_o             = xif_issue_if.issue_valid || xif_accepted_q || xif_rejected_q;

      assign xif_issue_if.issue_req.instr = instr;
      assign xif_issue_if.issue_req.mode  = PRIV_LVL_M;
      assign xif_issue_if.issue_req.id    = if_id_pipe_i.xif_id;

      always_comb begin
        xif_issue_if.issue_req.rs       = '0;
        xif_issue_if.issue_req.rs_valid = '0;
        if (xif_issue_if.X_NUM_RS > 0) begin
          xif_issue_if.issue_req.rs      [0] = operand_a_fw;
          xif_issue_if.issue_req.rs_valid[0] = !rf_illegal_raddr[0];
        end
        if (xif_issue_if.X_NUM_RS > 1) begin
          xif_issue_if.issue_req.rs      [1] = operand_b_fw;
          xif_issue_if.issue_req.rs_valid[1] = !rf_illegal_raddr[1];
        end
        // TODO:XIF implement forwarding for other operands than rs1 and rs2
        for (integer i = 2; i < xif_issue_if.X_NUM_RS && i < REGFILE_NUM_READ_PORTS; i++) begin
          xif_issue_if.issue_req.rs      [i] = rf_rdata_i[i];
          xif_issue_if.issue_req.rs_valid[i] = !rf_illegal_raddr[i];
        end
      end

      assign xif_issue_if.issue_req.ecs       = 6'b111111; // todo:XIF hookup to related mstatus bits (for now just reporting all state as dirty)
                                                           // and make sure that instruction after ecs update sees correct bits
      assign xif_issue_if.issue_req.ecs_valid = 1'b1; // todo:XIF needs to take into account if mstatus extension context writes are in flight
                                                      // todo:XIF use xif_issue_if.issue_resp.ecswrite

      // need to wait if the coprocessor is not ready and has not already accepted or rejected the instruction
      assign xif_waiting = xif_issue_if.issue_valid && !xif_issue_if.issue_ready && !xif_accepted_q && !xif_rejected_q;

      // an instruction was offloaded successfully if the coprocessor accepts it (or has accepted it)
      assign xif_insn_accept = (xif_issue_if.issue_valid && xif_issue_if.issue_ready &&  xif_issue_if.issue_resp.accept) || xif_accepted_q;
      assign xif_insn_reject = (xif_issue_if.issue_valid && xif_issue_if.issue_ready && !xif_issue_if.issue_resp.accept) || xif_rejected_q;

      // TODO:XIF These may be missed if issue_valid retracts before ID goes to EX. Need to check for sticky accept as well
      assign xif_we        = xif_issue_if.issue_valid && xif_issue_if.issue_resp.writeback;
      assign xif_exception = xif_issue_if.issue_valid && xif_issue_if.issue_resp.exc;
      assign xif_dualwrite = xif_issue_if.issue_valid && xif_issue_if.issue_resp.dualwrite;
      assign xif_loadstore = xif_issue_if.issue_valid && xif_issue_if.issue_resp.loadstore;

    end else begin : no_x_ext

      // Drive all eXtension interface signals and outputs low if X_EXT == 0
      assign xif_en                           = 1'b0;
      assign xif_waiting                      = 1'b0;
      assign xif_insn_accept                  = 1'b0;
      assign xif_insn_reject                  = 1'b0;
      assign xif_we                           = 1'b0;
      assign xif_exception                    = 1'b0;
      assign xif_dualwrite                    = 1'b0;
      assign xif_loadstore                    = 1'b0;

      assign xif_issue_if.issue_valid         = 1'b0;
      assign xif_issue_if.issue_req.instr     = '0;
      assign xif_issue_if.issue_req.mode      = '0;
      assign xif_issue_if.issue_req.id        = '0;
      assign xif_issue_if.issue_req.rs        = '0;
      assign xif_issue_if.issue_req.rs_valid  = '0;
      assign xif_issue_if.issue_req.ecs       = '0;
      assign xif_issue_if.issue_req.ecs_valid = '0;

      assign xif_offloading_o                 = 1'b0;

      logic unused_xif_signals;
      assign unused_xif_signals = xif_insn_reject | (|rf_illegal_raddr);
    end
  endgenerate

endmodule





































// Description:    Find First One                                             //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_ff_one
#(
  parameter int unsigned LEN = 32
)
(
  input  logic [LEN-1:0]         in_i,

  output logic [$clog2(LEN)-1:0] first_one_o,
  output logic                   no_ones_o
);

  localparam NUM_LEVELS = $clog2(LEN);

  logic [LEN-1:0] [NUM_LEVELS-1:0]           index_lut;
  logic [2**NUM_LEVELS-1:0]                  sel_nodes;
  logic [2**NUM_LEVELS-1:0] [NUM_LEVELS-1:0] index_nodes;


  //////////////////////////////////////////////////////////////////////////////
  // generate tree structure
  //////////////////////////////////////////////////////////////////////////////

  generate
    genvar j;
    for (j = 0; j < LEN; j++) begin : gen_index_lut
      assign index_lut[j] = $unsigned(j);
    end
  endgenerate

  generate
    genvar k;
    genvar l;
    genvar level;

    assign sel_nodes[2**NUM_LEVELS-1] = 1'b0;

    for (level = 0; level < NUM_LEVELS; level++) begin : gen_tree
    //------------------------------------------------------------
    if (level < NUM_LEVELS-1) begin : gen_non_root_level
      for (l = 0; l < 2**level; l++) begin : gen_node_non_root
        assign sel_nodes[2**level-1+l]   = sel_nodes[2**(level+1)-1+l*2] | sel_nodes[2**(level+1)-1+l*2+1];
        assign index_nodes[2**level-1+l] = (sel_nodes[2**(level+1)-1+l*2] == 1'b1) ?
                                           index_nodes[2**(level+1)-1+l*2] : index_nodes[2**(level+1)-1+l*2+1];
      end
    end
    //------------------------------------------------------------
    if (level == NUM_LEVELS-1) begin : gen_root_level
      for (k = 0; k < 2**level; k++) begin : gen_node_root
        // if two successive indices are still in the vector...
        if (k * 2 < LEN-1) begin : gen_two
          assign sel_nodes[2**level-1+k]   = in_i[k*2] | in_i[k*2+1];
          assign index_nodes[2**level-1+k] = (in_i[k*2] == 1'b1) ? index_lut[k*2] : index_lut[k*2+1];
        end
        // if only the first index is still in the vector...
        if (k * 2 == LEN-1) begin: gen_one
          assign sel_nodes[2**level-1+k]   = in_i[k*2];
          assign index_nodes[2**level-1+k] = index_lut[k*2];
        end
        // if index is out of range
        if (k * 2 > LEN-1) begin : gen_out_of_range
          assign sel_nodes[2**level-1+k]   = 1'b0;
          assign index_nodes[2**level-1+k] = '0;
        end
      end
    end
    //------------------------------------------------------------
    end
  endgenerate

  //////////////////////////////////////////////////////////////////////////////
  // connect output
  //////////////////////////////////////////////////////////////////////////////

  assign first_one_o = index_nodes[0];
  assign no_ones_o   = ~sel_nodes[0];

endmodule





// Description:    CPOP for Zbb extension                                     //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////


module cv32e40x_alu_b_cpop
  (input  logic [31:0] operand_i,
   output logic [ 5:0] result_o);

  logic [31:0][5:0] sum;

  assign result_o = sum[31];

  generate
    assign sum[0] = {5'h0, operand_i[0]};
    for (genvar i=1; i < 32; i++) begin
      assign sum[i] = sum[i-1] + {5'h0, operand_i[i]};
    end
  endgenerate

endmodule





module cv32e40x_alu import cv32e40x_pkg::*;
#(
  parameter b_ext_e B_EXT  = B_NONE
)
(
  input  alu_opcode_e       operator_i,
  input  logic [31:0]       operand_a_i,
  input  logic [31:0]       operand_b_i,
  input  logic [31:0]       muldiv_operand_b_i,

  output logic [31:0]       result_o,
  output logic              cmp_result_o,

  // Divider interface towards CLZ
  input logic               div_clz_en_i,
  input logic [31:0]        div_clz_data_rev_i,
  output logic [5:0]        div_clz_result_o,

  // Divider interface towards shifter
  input logic               div_shift_en_i,
  input logic [5:0]         div_shift_amt_i,
  output logic [31:0]       div_op_b_shifted_o
);

  localparam RV32B_ZBS = (B_EXT == ZBA_ZBB_ZBS) || (B_EXT == ZBA_ZBB_ZBC_ZBS);

  logic [31:0] operand_a_rev;
  logic [31:0] operand_b_rev;

  // Reverse operands
  assign operand_a_rev = {<<{operand_a_i}};
  assign operand_b_rev = {<<{operand_b_i}};

  ////////////////////////////////////
  //     _       _     _            //
  //    / \   __| | __| | ___ _ __  //
  //   / _ \ / _` |/ _` |/ _ \ '__| //
  //  / ___ \ (_| | (_| |  __/ |    //
  // /_/   \_\__,_|\__,_|\___|_|    //
  //                                //
  ////////////////////////////////////

  // Adder is used for:
  //
  // - ALU_ADD, ALU_SUB
  //
  // Currently not used for ALU_B_SH1ADD, ALU_B_SH2ADD, ALU_B_SH3ADD

  logic [32:0] adder_in_a, adder_in_b;
  logic [31:0] adder_result;
  logic [33:0] adder_result_expanded;
  logic        adder_subtract;

  assign adder_subtract = operator_i[3];

  // Prepare carry
  assign adder_in_a = {operand_a_i,                                 1'b1          };
  assign adder_in_b = {adder_subtract ? ~operand_b_i : operand_b_i, adder_subtract};

  // Actual adder
  assign adder_result_expanded = $unsigned(adder_in_a) + $unsigned(adder_in_b);
  assign adder_result = adder_result_expanded[32:1];

  ////////////////////////////////////////
  //  ____  _   _ ___ _____ _____       //
  // / ___|| | | |_ _|  ___|_   _|      //
  // \___ \| |_| || || |_    | |        //
  //  ___) |  _  || ||  _|   | |        //
  // |____/|_| |_|___|_|     |_|        //
  //                                    //
  ////////////////////////////////////////

  // Shifter is used for:
  //
  // - ALU_SLL, ALU_SRA, ALU_SRL
  // - ALU_B_ROL, ALU_B_ROR
  // - ALU_B_BEXT, ALU_B_BSET, ALU_B_BCLR, ALU_B_BINV
  //
  // - DIV_DIVU, DIV_DIVU, DIV_REM, DIV_REMU

  logic [5:0]  shifter_shamt;           // Shift amount
  logic        shifter_rshift;          // Shift right
  logic [31:0] shifter_aa, shifter_bb;
  logic [63:0] shifter_tmp;
  logic [31:0] shifter_result;

  assign shifter_rshift = operator_i[2];

  always_comb begin
    if (div_shift_en_i) begin
      shifter_shamt =  {1'b0, div_shift_amt_i[4:0]};    // DIV(U), REM(U) always use shift left
    end else if (shifter_rshift) begin
      shifter_shamt = -{1'b0, operand_b_i[4:0]};
    end else begin
      shifter_shamt =  {1'b0, operand_b_i[4:0]};
    end
  end

  always_comb begin
    // Defaults (ALU_SLL, ALU_SRL, ALU_B_BEXT, DIV_DIVU, DIV_DIVU, DIV_REM, DIV_REMU)
    shifter_aa = div_shift_en_i ? muldiv_operand_b_i : operand_a_i;
    shifter_bb = 32'h0;

    unique case (operator_i)
      ALU_SRA : begin
        shifter_bb = {32{operand_a_i[31]}};
      end
      ALU_B_ROL,
      ALU_B_ROR : begin
        shifter_bb = operand_a_i;
      end
      ALU_B_BSET,
      ALU_B_BCLR,
      ALU_B_BINV : begin
        if (RV32B_ZBS) begin
          shifter_aa = 32'h1;
        end
      end
      default: ;
    endcase
  end

  always_comb begin
    shifter_tmp = {shifter_bb, shifter_aa};
    shifter_tmp = shifter_shamt[5] ? {shifter_tmp[31:0], shifter_tmp[63:32]} : shifter_tmp;
    shifter_tmp = shifter_shamt[4] ? {shifter_tmp[47:0], shifter_tmp[63:48]} : shifter_tmp;
    shifter_tmp = shifter_shamt[3] ? {shifter_tmp[55:0], shifter_tmp[63:56]} : shifter_tmp;
    shifter_tmp = shifter_shamt[2] ? {shifter_tmp[59:0], shifter_tmp[63:60]} : shifter_tmp;
    shifter_tmp = shifter_shamt[1] ? {shifter_tmp[61:0], shifter_tmp[63:62]} : shifter_tmp;
    shifter_tmp = shifter_shamt[0] ? {shifter_tmp[62:0], shifter_tmp[63:63]} : shifter_tmp;
  end

  generate
    if (RV32B_ZBS) begin : gen_shift_zbs
      always_comb begin
        shifter_result = shifter_tmp[31:0];

        unique case (operator_i)
          ALU_B_BEXT : shifter_result =       32'h1 &  shifter_tmp[31:0];
          ALU_B_BSET : shifter_result = operand_a_i |  shifter_tmp[31:0];
          ALU_B_BCLR : shifter_result = operand_a_i & ~shifter_tmp[31:0];
          ALU_B_BINV : shifter_result = operand_a_i ^  shifter_tmp[31:0];
          default: ;
        endcase
      end
    end else begin : gen_shift_nozbs
      assign shifter_result = shifter_tmp[31:0];
    end
  endgenerate

  assign div_op_b_shifted_o = shifter_tmp[31:0];

  //////////////////////////////////////////////////////////////////
  // Shift and add

  logic [31:0] result_shnadd;

  assign result_shnadd = (operand_a_i << ((operator_i == ALU_B_SH1ADD) ? 1 : (operator_i == ALU_B_SH2ADD) ? 2 : 3)) + operand_b_i;

  //////////////////////////////////////////////////////////////////
  //   ____ ___  __  __ ____   _    ____  ___ ____   ___  _   _   //
  //  / ___/ _ \|  \/  |  _ \ / \  |  _ \|_ _/ ___| / _ \| \ | |  //
  // | |  | | | | |\/| | |_) / _ \ | |_) || |\___ \| | | |  \| |  //
  // | |__| |_| | |  | |  __/ ___ \|  _ < | | ___) | |_| | |\  |  //
  //  \____\___/|_|  |_|_| /_/   \_\_| \_\___|____/ \___/|_| \_|  //
  //                                                              //
  //////////////////////////////////////////////////////////////////

  // Comparator used for:
  //
  // - ALU_EQ, ALU_NE, ALU_GE, ALU_GEU, ALU_LT, ALU_LTU
  // - ALU_SLT, ALU_SLTU
  // - ALU_B_MIN, ALU_B_MINU, ALU_B_MAX, ALU_B_MAXU

  logic is_equal;
  logic is_greater;     // Handles both signed and unsigned forms
  logic is_signed;

  assign is_signed = operator_i[3];
  assign is_equal = (operand_a_i == operand_b_i);
  assign is_greater = $signed({operand_a_i[31] & is_signed, operand_a_i}) > $signed({operand_b_i[31] & is_signed, operand_b_i});

  // Generate comparison result
  always_comb
  begin
    cmp_result_o = is_equal;
    unique case (operator_i)
      ALU_EQ          : cmp_result_o = is_equal;
      ALU_NE          : cmp_result_o = !is_equal;
      ALU_GE, ALU_GEU : cmp_result_o = is_greater || is_equal;
      ALU_LT, ALU_LTU : cmp_result_o = !(is_greater || is_equal);

      default: ;
    endcase
  end

  //////////////////////////////////////////////////////////////////
  // Min/max

  logic [31:0] min_minu_result;
  logic [31:0] max_maxu_result;

  assign min_minu_result = (!is_greater) ? operand_a_i : operand_b_i;
  assign max_maxu_result = ( is_greater) ? operand_a_i : operand_b_i;

  /////////////////////////////////////////////////////////////////////
  //   ____  _ _      ____                  _      ___               //
  //  | __ )(_) |_   / ___|___  _   _ _ __ | |_   / _ \ _ __  ___    //
  //  |  _ \| | __| | |   / _ \| | | | '_ \| __| | | | | '_ \/ __|   //
  //  | |_) | | |_  | |__| (_) | |_| | | | | |_  | |_| | |_) \__ \_  //
  //  |____/|_|\__|  \____\___/ \__,_|_| |_|\__|  \___/| .__/|___(_) //
  //                                                   |_|           //
  /////////////////////////////////////////////////////////////////////

  logic [31:0] clz_data_in;
  logic [4:0]  ff1_result; // holds the index of the first '1'
  logic        ff_no_one;  // if no ones are found
  logic [ 5:0] cpop_result_o;

  assign clz_data_in = div_clz_en_i ? div_clz_data_rev_i :
                       (operator_i == ALU_B_CTZ) ? operand_a_i : operand_a_rev;

  cv32e40x_ff_one ff_one_i
  (
    .in_i        ( clz_data_in ),
    .first_one_o ( ff1_result ),
    .no_ones_o   ( ff_no_one  )
  );

  // Divider assumes CLZ returning 32 when there are no zeros (as per CLZ spec)
  assign div_clz_result_o = ff_no_one ? 6'd32 : ff1_result;

  // CPOP
  cv32e40x_alu_b_cpop alu_b_cpop_i
    (.operand_i (operand_a_i),
     .result_o  (cpop_result_o));


  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //   ____                      _                 __  __       _ _   _       _ _           _   _              //
  //  / ___|__ _ _ __ _ __ _   _| | ___  ___ ___  |  \/  |_   _| | |_(_)_ __ | (_) ___ __ _| |_(_) ___  _ __   //
  // | |   / _` | '__| '__| | | | |/ _ \/ __/ __| | |\/| | | | | | __| | '_ \| | |/ __/ _` | __| |/ _ \| '_ \  //
  // | |__| (_| | |  | |  | |_| | |  __/\__ \__ \ | |  | | |_| | | |_| | |_) | | | (_| (_| | |_| | (_) | | | | //
  //  \____\__,_|_|  |_|   \__, |_|\___||___/___/ |_|  |_|\__,_|_|\__|_| .__/|_|_|\___\__,_|\__|_|\___/|_| |_| //
  //                       |___/                                       |_|                                     //
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

  logic [31:0] clmul_result;
  logic [31:0] clmulr_result;
  logic [31:0] clmulh_result;

  generate
    if (B_EXT == ZBA_ZBB_ZBC_ZBS) begin: clmul

      logic [31:0] clmul_op_a;
      logic [31:0] clmul_op_b;

      assign clmul_op_a = (operator_i != ALU_B_CLMUL) ? operand_a_rev : operand_a_i;
      assign clmul_op_b = (operator_i != ALU_B_CLMUL) ? operand_b_rev : operand_b_i;

      always_comb begin
        clmul_result ='0;
        for (integer i = 0; i < 32; i++) begin
          for (integer j = 0; j < i+1; j++) begin
            clmul_result[i] = clmul_result[i] ^ (clmul_op_a[i-j] & clmul_op_b[j]);
          end
        end
      end

      assign clmulr_result = {<<{clmul_result}}; // Reverse for clmulr
      assign clmulh_result = {1'b0, clmulr_result[31:1]};

    end else begin: no_clmul

      assign clmul_result  = 32'h0;
      assign clmulr_result = 32'h0;
      assign clmulh_result = 32'h0;

    end
  endgenerate

  ////////////////////////////////////////////////////////
  //   ____                 _ _     __  __              //
  //  |  _ \ ___  ___ _   _| | |_  |  \/  |_   ___  __  //
  //  | |_) / _ \/ __| | | | | __| | |\/| | | | \ \/ /  //
  //  |  _ <  __/\__ \ |_| | | |_  | |  | | |_| |>  <   //
  //  |_| \_\___||___/\__,_|_|\__| |_|  |_|\__,_/_/\_\  //
  //                                                    //
  ////////////////////////////////////////////////////////

  always_comb
  begin
    result_o = 32'h0;

    // RV32I
    unique case (operator_i)
      // Bitwise operators
      ALU_AND    : result_o = operand_a_i &  operand_b_i;
      ALU_OR     : result_o = operand_a_i |  operand_b_i;
      ALU_XOR    : result_o = operand_a_i ^  operand_b_i;
      ALU_B_ANDN : result_o = operand_a_i & ~operand_b_i;
      ALU_B_ORN  : result_o = operand_a_i | ~operand_b_i;
      ALU_B_XNOR : result_o = operand_a_i ^ ~operand_b_i;

      // Adder Operations
      ALU_ADD,
      ALU_SUB : result_o = adder_result;

      // Shift Operations
      ALU_SLL,
      ALU_SRL,
      ALU_SRA,
      ALU_B_ROL,
      ALU_B_ROR,
      ALU_B_BSET,
      ALU_B_BCLR,
      ALU_B_BINV,
      ALU_B_BEXT   : result_o = shifter_result;

      // Comparisons
      ALU_SLT, ALU_SLTU: result_o = {31'b0, !(is_greater || is_equal)};

      // Shift and add
      ALU_B_SH1ADD,
      ALU_B_SH2ADD,
      ALU_B_SH3ADD : result_o = result_shnadd;

      ALU_B_CLZ,
      ALU_B_CTZ    : result_o = {26'h0, div_clz_result_o};
      ALU_B_CPOP   : result_o = {26'h0, cpop_result_o};


      ALU_B_MIN,
      ALU_B_MINU   : result_o = min_minu_result;
      ALU_B_MAX,
      ALU_B_MAXU   : result_o = max_maxu_result;

      ALU_B_ORC_B  : result_o = {{(8){|operand_a_i[31:24]}}, {(8){|operand_a_i[23:16]}}, {(8){|operand_a_i[15:8]}}, {(8){|operand_a_i[7:0]}}};

      ALU_B_REV8   : result_o = {operand_a_i[7:0], operand_a_i[15:8], operand_a_i[23:16], operand_a_i[31:24]};

      ALU_B_SEXT_B : result_o = {{(24){operand_a_i[ 7]}}, operand_a_i[ 7:0]};
      ALU_B_SEXT_H : result_o = {{(16){operand_a_i[15]}}, operand_a_i[15:0]};

      ALU_B_ZEXT_H : result_o = {16'h0000, operand_a_i[15:0]};

      ALU_B_CLMUL  : result_o = clmul_result;
      ALU_B_CLMULH : result_o = clmulh_result;
      ALU_B_CLMULR : result_o = clmulr_result;

      default: ;
    endcase

  end

endmodule







module cv32e40x_div import cv32e40x_pkg::*;
(
    // Clock and reset
    input logic                clk,
    input logic                rst_n,

    // Control signals
    input                      div_opcode_e operator_i,
    input logic                data_ind_timing_i,

    // Input operands
    input logic [31:0]         op_a_i,
    input logic [31:0]         op_b_i,


    // CLZ interface towards ALU
    output logic               alu_clz_en_o,
    output logic [31:0]        alu_clz_data_rev_o,
    input logic [5:0]          alu_clz_result_i,

    // Shifter interface towards ALU
    output logic               alu_shift_en_o,
    output logic [5:0]         alu_shift_amt_o,
    input logic [31:0]         alu_op_b_shifted_i,

    // Controller inputs
    input logic                halt_i,
    input logic                kill_i,

    // Input handshake
    input logic                valid_i,
    output logic               ready_o,

    // Output handshake and result
    input logic                ready_i,
    output logic               valid_o,
    output logic [31:0]        result_o
  );

  ///////////////////////////////////////////////////////////////////////////////
  // Signal declarations
  ///////////////////////////////////////////////////////////////////////////////

  logic [31:0] alu_clz_data;

  logic [31:0] quotient_q, quotient_d;
  logic [31:0] remainder_q, remainder_d;
  logic [31:0] divisor_q, divisor_d;

  logic div_rem_d, div_rem_q;
  logic comp_inv_d, comp_inv_q;
  logic res_inv_d, res_inv_q;

  logic [31:0] add_a_mux;
  logic [31:0] add_out;
  logic [31:0] add_b_mux;
  logic [31:0] divisor_mux;
  logic [31:0] res_mux;
  logic [32:0] op_b_alt;

  logic [5:0] cnt_q, cnt_d, cnt_d_dummy;
  logic cnt_q_is_zero;
  logic init_dummy_cnt;

  logic remainder_en, divisor_en, quotient_en, comp_out, init_remainder_pos, init_en;

  div_state_e next_state, state;

  logic div_signed;
  logic div_rem;
  logic op_b_is_neg;
  logic op_b_is_zero;

  ///////////////////////////////////////////////////////////////////////////////
  // Operator decoding
  ///////////////////////////////////////////////////////////////////////////////

  assign div_signed = (operator_i == DIV_DIV) || (operator_i == DIV_REM);
  assign div_rem    = (operator_i == DIV_REM) || (operator_i == DIV_REMU);

  ///////////////////////////////////////////////////////////////////////////////
  // Interaction with CLZ and shift circuitry in the ALU
  ///////////////////////////////////////////////////////////////////////////////

  // In case of negative op_b, invert op_b_i to count leading ones
  // and shift one less to preserve sign bit
  assign op_b_alt = {~op_b_i, 1'b0};

  always_comb
  begin
    alu_clz_data = op_b_i;

    case (operator_i)
      DIV_DIVU,
      DIV_REMU: alu_clz_data = op_b_i;

      DIV_DIV,
      DIV_REM: begin
        if (op_b_is_neg) begin
          alu_clz_data = {op_b_alt[31:1], 1'b1};
        end else begin
          alu_clz_data = op_b_i;
        end
      end
      default:;
    endcase
  end

  // CLZ circuit needs reversed input
  generate
    genvar l;
    for (l = 0; l < 32; l++)
    begin : gen_div_clz_data_rev
      assign alu_clz_data_rev_o[l] = alu_clz_data[31-l];
    end
  endgenerate

  assign alu_clz_en_o = valid_i;

  // Deternmine initial shift of divisor
  assign op_b_is_neg = op_b_i[31] & div_signed;
  assign alu_shift_amt_o = alu_clz_result_i;
  assign alu_shift_en_o  = valid_i;

  // Check for op_b_i == 0
  assign op_b_is_zero = !(|op_b_i);

  ///////////////////////////////////////////////////////////////////////////////
  // Datapath
  ///////////////////////////////////////////////////////////////////////////////

  // Initialize remainder with negated op_a_i upon signed division with different signs on op_a and op_b
  assign init_remainder_pos = init_en && !(div_signed && (op_a_i[$high(op_a_i)] ^ op_b_is_neg));

  // Divisor mux and shifter. Shift with sign extension in case of negative op_b
  assign divisor_mux = init_en ? alu_op_b_shifted_i : {comp_inv_q, (divisor_q[$high(divisor_q):1])};

  // Main comparator
  assign comp_out = ((remainder_q == divisor_q) || ((remainder_q > divisor_q) ^ comp_inv_q)) &&
                    ((|remainder_q) || op_b_is_zero);

  // Adder input muxes
  assign add_b_mux = init_en ? 0 : remainder_q;
  assign add_a_mux = init_en ? op_a_i : divisor_q;

  // Main adder
  always_comb begin
    if (init_remainder_pos) begin
      add_out = add_b_mux + add_a_mux;
    end
    else begin
      add_out = add_b_mux - $signed(add_a_mux);
    end
  end

  // Result mux, negate if necessary
  assign res_mux  = div_rem_q ? remainder_q : quotient_q;
  assign result_o = res_inv_q ? -$signed(res_mux) : res_mux;

  ///////////////////////////////////////////////////////////////////////////////
  // Counter
  ///////////////////////////////////////////////////////////////////////////////

  assign cnt_d_dummy = 6'd32 - alu_shift_amt_o;

  always_comb begin
    cnt_d = cnt_q;

    if (init_en) begin
      cnt_d = alu_shift_amt_o;
    end
    else if (init_dummy_cnt) begin
      cnt_d = cnt_d_dummy - 6'd1; /*-1 because one cycle is used to update the counter*/
    end
    else if (!cnt_q_is_zero) begin
      cnt_d = cnt_q - 6'd1;
    end
  end

  assign cnt_q_is_zero = !(|cnt_q);

  ///////////////////////////////////////////////////////////////////////////////
  // FSM
  ///////////////////////////////////////////////////////////////////////////////

  always_comb
  begin : p_fsm
    // default
    next_state     = state;

    valid_o        = 1'b0;
    ready_o        = 1'b0;

    init_en        = 1'b0;
    init_dummy_cnt = 1'b0;

    remainder_en   = 1'b0;
    divisor_en     = 1'b0;
    quotient_en    = 1'b0;

    // Case statement assumes valid_i = 1, halt_i = 0 and kill_i = 0.
    // the valid_i = 0 / halt_i = 1 / kill_i = 1 scenarios
    // are handled after the case statement.
    case (state)
      DIV_IDLE: begin
        remainder_en = 1'b1;
        divisor_en   = 1'b1;
        init_en      = 1'b1;
        next_state   = DIV_DIVIDE;
      end

      DIV_DIVIDE: begin
        remainder_en = comp_out;
        divisor_en   = 1'b1;
        quotient_en  = 1'b1;

        // calculation finished
        // one more divide cycle (32nd divide cycle)
        if (cnt_q_is_zero) begin
          if (data_ind_timing_i && |(cnt_d_dummy)) begin
            init_dummy_cnt = 1'b1;
            next_state = DIV_DUMMY;
          end else begin
            next_state = DIV_FINISH;
          end
        end
      end

      DIV_DUMMY: begin
        if (cnt_q_is_zero) begin
          next_state = DIV_FINISH;
        end
      end

      DIV_FINISH: begin
        valid_o = 1'b1;

        if (ready_i) begin
          ready_o    = 1'b1;
          next_state = DIV_IDLE;
        end
      end

      default : /* default */ ;

    endcase

    // Allow kill at any time
    if (!valid_i || kill_i) begin
      ready_o    = 1'b1;
      valid_o    = 1'b0;
    end else begin
      // Neither ready nor valid when halted
      if (halt_i) begin
        ready_o = 1'b0;
        valid_o = 1'b0;
      end
    end

    if (kill_i) begin
      next_state = DIV_IDLE;

      init_en        = 1'b0;
      init_dummy_cnt = 1'b0;

      remainder_en   = 1'b0;
      divisor_en     = 1'b0;
      quotient_en    = 1'b0;
    end
  end

  ///////////////////////////////////////////////////////////////////////////////
  // Registers
  ///////////////////////////////////////////////////////////////////////////////

  assign div_rem_d  = init_en ? div_rem : div_rem_q;
  assign comp_inv_d = init_en ? op_b_is_neg : comp_inv_q;
  assign res_inv_d  = init_en ? (!op_b_is_zero || div_rem) && div_signed && (op_a_i[$high(op_a_i)] ^ op_b_is_neg) :
                      res_inv_q;

  assign remainder_d = remainder_en ? add_out     : remainder_q;
  assign divisor_d   = divisor_en   ? divisor_mux : divisor_q;
  assign quotient_d  = init_en      ? '0                                            :
                       quotient_en  ? {quotient_q[$high(quotient_q)-1:0], comp_out} :
                       quotient_q;

  always_ff @(posedge clk, negedge rst_n) begin : p_regs
    if (rst_n == 1'b0) begin
       state       <= DIV_IDLE;
       remainder_q <= '0;
       divisor_q   <= '0;
       quotient_q  <= '0;
       cnt_q       <= '0;
       div_rem_q   <= 1'b0;
       comp_inv_q  <= 1'b0;
       res_inv_q   <= 1'b0;
    end else begin
      // Update flops on valid input or when killed. No updates while halted.
      // When a divide instruction is killed, the cnt_q will decrement unless
      // the divider is finished in the same cycle as the kill.
      // All flops below will keep their values until initialized for the next
      // divide (init_en, remainder_en, divisor_en, quotient_en) and no flops
      // are used between kill and init.
      if ((valid_i && !halt_i) || kill_i) begin
       state       <= next_state;
       remainder_q <= remainder_d;
       divisor_q   <= divisor_d;
       quotient_q  <= quotient_d;
       cnt_q       <= cnt_d;
       div_rem_q   <= div_rem_d;
       comp_inv_q  <= comp_inv_d;
       res_inv_q   <= res_inv_d;
      end
    end
  end

endmodule







module cv32e40x_mult import cv32e40x_pkg::*;
(
  input  logic        clk,
  input  logic        rst_n,

  input  logic        valid_i,
  input  mul_opcode_e operator_i,

  // integer and short multiplier
  input  logic [ 1:0] signed_mode_i,

  input  logic [31:0] op_a_i,
  input  logic [31:0] op_b_i,

  output logic [31:0] result_o,

  input  logic        halt_i,
  input  logic        kill_i,

  output logic        ready_o,
  output logic        valid_o,
  input  logic        ready_i
);

  ///////////////////////////////////////////////////////////////
  //  ___ _  _ _____ ___ ___ ___ ___   __  __ _   _ _  _____   //
  // |_ _| \| |_   _| __/ __| __| _ \ |  \/  | | | | ||_   _|  //
  //  | || .  | | | | _| (_ | _||   / | |\/| | |_| | |__| |    //
  // |___|_|\_| |_| |___\___|___|_|_\ |_|  |_|\___/|____|_|    //
  //                                                           //
  ///////////////////////////////////////////////////////////////

  // Multiplier Operands
  logic [31:0] op_a;
  logic [31:0] op_b;
  logic [33:0] int_result;

  // MULH control signals
  logic        mulh_shift;

  // MULH State variables
  mul_state_e  mulh_state;
  mul_state_e  mulh_state_next;

  // MULH Part select operands
  logic [16:0] mulh_al;
  logic [16:0] mulh_bl;
  logic [16:0] mulh_ah;
  logic [16:0] mulh_bh;

  // MULH Operands
  logic [16:0] mulh_a;
  logic [16:0] mulh_b;

  // MULH Intermediate Results
  logic [32:0] mulh_acc;
  logic [32:0] mulh_acc_next;
  logic [32:0] mulh_acc_res;

  // Result
  logic [33:0] result;
  logic [33:0] result_shifted;

  assign mulh_al[15:0] = op_a_i[15:0];
  assign mulh_bl[15:0] = op_b_i[15:0];
  assign mulh_ah[15:0] = op_a_i[31:16];
  assign mulh_bh[15:0] = op_b_i[31:16];

  // Lower halfwords are always multiplied as unsigned
  assign mulh_al[16] = 1'b0;
  assign mulh_bl[16] = 1'b0;

  // Sign extention for the upper halfword is decided by the instuction used.
  // MULH   :   signed x signed    : signed_mode_i == 'b00
  // MULHSU :   signed x unsigned  : signed_mode_i == 'b01
  // MULHU  : unsigned x unsigned  : signed_mode_i == 'b11
  assign mulh_ah[16] = signed_mode_i[0] && op_a_i[31];
  assign mulh_bh[16] = signed_mode_i[1] && op_b_i[31];

  ////////////////
  //  MULH FSM  //
  ////////////////

  always_comb
  begin
    mulh_shift       = 1'b0;
    mulh_a           = mulh_al;
    mulh_b           = mulh_bl;
    mulh_state_next  = mulh_state;
    ready_o          = 1'b0;
    valid_o          = 1'b0;
    mulh_acc_next    = mulh_acc;

    // Case statement assumes valid_i = 1, halt_i = 0 and kill_i = 0.
    // the valid_i = 0 / halt_i = 1 / kill_i = 1 scenarios
    // are handled after the case statement.
    case (mulh_state)
      MUL_ALBL: begin
        if (operator_i == MUL_H) begin
          // Multicycle multiplication
          mulh_shift      = 1'b1;
          mulh_state_next = MUL_ALBH;
          mulh_acc_next   = mulh_acc_res;
        end
        else begin
          // Single cycle multiplication
          valid_o         = 1'b1;

          if (ready_i) begin
            ready_o = 1'b1;
          end
        end
      end

      MUL_ALBH: begin
        mulh_state_next  = MUL_AHBL;
        mulh_acc_next    = mulh_acc_res;
        mulh_a           = mulh_al;
        mulh_b           = mulh_bh;
      end

      MUL_AHBL: begin
        mulh_state_next  = MUL_AHBH;
        mulh_acc_next    = mulh_acc_res;
        mulh_shift       = 1'b1;
        mulh_a           = mulh_ah;
        mulh_b           = mulh_bl;
      end

      MUL_AHBH: begin
        valid_o           = 1'b1;
        mulh_a            = mulh_ah;
        mulh_b            = mulh_bh;

        if (ready_i) begin
          ready_o         = 1'b1;
          mulh_state_next = MUL_ALBL;
          mulh_acc_next   = '0;
        end
      end
      default: ;
    endcase

    // Allow kill at any time
    if (!valid_i || kill_i) begin
      valid_o         = 1'b0;
      ready_o         = 1'b1;
      mulh_shift      = 1'b0;
      mulh_a          = mulh_al;
      mulh_b          = mulh_bl;
    end else begin
      if (halt_i) begin
        valid_o         = 1'b0;
        ready_o         = 1'b0;
        mulh_shift      = 1'b0;
        mulh_a          = mulh_al;
        mulh_b          = mulh_bl;
      end
    end

    if (kill_i) begin
      mulh_state_next = MUL_ALBL;
      mulh_acc_next   = '0;
    end
  end // always_comb

  always_ff @(posedge clk, negedge rst_n) begin
    if (rst_n == 1'b0) begin
      mulh_acc   <=  '0;
      mulh_state <= MUL_ALBL;
    end else begin
      // Update flops on valid input or when killed. No updates while halted.
      if ((valid_i && !halt_i) || kill_i) begin
        mulh_acc   <= mulh_acc_next;
        mulh_state <= mulh_state_next;
      end
    end
  end

  // MULH Shift Mux
  assign result_shifted = $signed(result) >>> 16;
  assign mulh_acc_res   = mulh_shift ? result_shifted[32:0] : result[32:0];

  ///////////////////////////
  //   32-bit multiplier   //
  ///////////////////////////

  assign op_a = (operator_i == MUL_M32) ? op_a_i : {{16{mulh_a[16]}}, mulh_a[15:0]};
  assign op_b = (operator_i == MUL_M32) ? op_b_i : {{16{mulh_b[16]}}, mulh_b[15:0]};

  assign int_result = $signed(op_a) * $signed(op_b);

  ////////////////////////////////////
  //   ____                 _ _     //
  //  |  _ \ ___  ___ _   _| | |_   //
  //  | |_) / _ \/ __| | | | | __|  //
  //  |  _ <  __/\__ \ |_| | | |_   //
  //  |_| \_\___||___/\__,_|_|\__|  //
  //                                //
  ////////////////////////////////////

  // 34bit Adder - mulh_acc is always 0 for the MUL instruction
  assign result   = $signed(int_result) + $signed(mulh_acc);

  assign result_o = result[31:0];

endmodule






// Description:    Execution stage: Hosts ALU and MAC unit                    //
//                 ALU: computes additions/subtractions/comparisons           //
//                 MULT: computes normal multiplications                      //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_ex_stage import cv32e40x_pkg::*;
#(
  parameter bit     X_EXT            = 1'b0,
  parameter b_ext_e B_EXT            = B_NONE,
  parameter m_ext_e M_EXT            = M
)
(
  input  logic        clk,
  input  logic        rst_n,

  // ID/EX pipeline
  input id_ex_pipe_t  id_ex_pipe_i,

  // CSR interface
  input  logic [31:0] csr_rdata_i,
  input  logic        csr_illegal_i,
  input  logic        csr_mnxti_read_i,
  input  csr_hz_t     csr_hz_i,

  // EX/WB pipeline
  output ex_wb_pipe_t ex_wb_pipe_o,

  // From controller FSM
  input  ctrl_fsm_t   ctrl_fsm_i,

  // Register file forwarding signals (to ID)
  output logic [31:0] rf_wdata_o,

  // To IF: Jump and branch target and decision
  output logic        branch_decision_o,
  output logic [31:0] branch_target_o,

  // Output to controller
  output logic        xif_csr_error_o,

  // LSU handshake interface
  input  logic        lsu_valid_i,
  output logic        lsu_ready_o,
  output logic        lsu_valid_o,
  input  logic        lsu_ready_i,
  input  logic        lsu_split_i,      // LSU is performing first part of a misaligned/split instruction
  input  logic        lsu_last_op_i,
  input  logic        lsu_first_op_i,

  // Stage ready/valid
  output logic        ex_ready_o,       // EX stage is ready for new data
  output logic        ex_valid_o,       // EX stage has valid (non-bubble) data for next stage
  input  logic        wb_ready_i,       // WB stage is ready for new data

  output logic        last_op_o
);

  // Ready and valid signals
  logic           instr_valid;
  logic           alu_ready;
  logic           alu_valid;
  logic           csr_ready;
  logic           csr_valid;
  logic           sys_ready;
  logic           sys_valid;
  logic           mul_ready;
  logic           mul_valid;
  logic           div_ready;
  logic           div_valid;
  logic           xif_ready;
  logic           xif_valid;

  // Result signals
  logic [31:0]    alu_result;
  logic           alu_cmp_result;
  logic [31:0]    mul_result;
  logic [31:0]    div_result;

  // Gated enable signals factoring in instr_valid)
  logic           lsu_en_gated;

  // Divider signals
  logic           div_en;               // Not affected by instr_valid (kill/halt)
  logic           div_clz_en;
  logic [31:0]    div_clz_data_rev;
  logic [5:0]     div_clz_result;
  logic           div_shift_en;
  logic [5:0]     div_shift_amt;
  logic [31:0]    div_op_b_shifted;

  // Multiplier signals
  logic           mul_en;

  // Misc signals
  logic           forced_nop; // Exception or trigger forces this instruction to be a nop with no enables active
  logic           forced_nop_valid;
  logic           first_op;

  // Detect if we get an illegal CSR instruction
  logic           csr_is_illegal;


  assign instr_valid = id_ex_pipe_i.instr_valid && !ctrl_fsm_i.kill_ex && !ctrl_fsm_i.halt_ex;

  // The multiplier and divider both factor in halt_ex and kill_ex.
  // MUL/DIV instructions in flight will keep state while halted, and reset state on kill.
  assign mul_en = id_ex_pipe_i.mul_en && id_ex_pipe_i.instr_valid; // Valid MUL in EX, not affected by kill/halt
  assign div_en = id_ex_pipe_i.div_en && id_ex_pipe_i.instr_valid; // Valid DIV in EX, not affected by kill/halt

  // The lsu_en_gated factors in halt_ex and kill_ex via instr_valid.
  // A halted or killed LSU instruction must not generate a data_req to ensure no OBI protocol is violated.
  assign lsu_en_gated = id_ex_pipe_i.lsu_en && instr_valid; // Factoring in instr_valid to suppress bus transactions on kill/halt


  // If pipeline is handling a valid CSR AND the same instruction is accepted by the eXtension interface
  // we need to convert the instruction to an illegal instruction and signal commit_kill to the eXtension interface.
  // Using registered instr_valid, as gated instr_valid would not allow killing of offloaded instruction
  // in case of halt_ex==1. We need to kill this duplicate regardless of halt state.
  //  Currently, halt_ex is asserted in the cycle before debug entry, and if any performance counter is being read.
  assign xif_csr_error_o = instr_valid && (id_ex_pipe_i.xif_en && id_ex_pipe_i.xif_meta.accepted) && (id_ex_pipe_i.csr_en && !csr_illegal_i);

  // CSR instruction is illegal if core signals illegal and NOT offloaded, or if both core and xif accepted it.
  assign csr_is_illegal = ((csr_illegal_i && !(id_ex_pipe_i.xif_en && id_ex_pipe_i.xif_meta.accepted)) ||
                           xif_csr_error_o) &&
                           instr_valid;

  // Exception happened during IF or ID, or trigger match in ID (converted to NOP).
  // signal needed for ex_valid to go high in such cases
  assign forced_nop = (id_ex_pipe_i.illegal_insn                     ||
                       id_ex_pipe_i.instr.bus_resp.err               ||
                       (id_ex_pipe_i.instr.mpu_status != MPU_OK)     ||
                       |id_ex_pipe_i.trigger_match)                  &&
                      id_ex_pipe_i.instr_valid;

  // ALU write port mux
  always_comb
  begin
    // There is no need to use gated versions of alu_en, mul_en, etc. as rf_wdata_o will be ignored
    // for invalid instructions (as the register file write enable will be suppressed).
    unique case (1'b1)
      id_ex_pipe_i.alu_en : rf_wdata_o = alu_result;
      id_ex_pipe_i.mul_en : rf_wdata_o = mul_result;
      id_ex_pipe_i.div_en : rf_wdata_o = div_result;
      id_ex_pipe_i.csr_en : rf_wdata_o = csr_rdata_i;
      default             : rf_wdata_o = alu_result;
    endcase
  end

  // Branch handling
  assign branch_decision_o = alu_cmp_result;
  assign branch_target_o   = id_ex_pipe_i.operand_c;

  // Detect last operation
  // Both parts of a split misaligned load/store will reach WB, but only the second half will be marked with "last_op"
  assign last_op_o = id_ex_pipe_i.lsu_en ? (lsu_last_op_i && id_ex_pipe_i.last_op) : id_ex_pipe_i.last_op;

  assign first_op  = id_ex_pipe_i.lsu_en ? (lsu_first_op_i && id_ex_pipe_i.first_op) : id_ex_pipe_i.first_op;

  ////////////////////////////
  //     _    _    _   _    //
  //    / \  | |  | | | |   //
  //   / _ \ | |  | | | |   //
  //  / ___ \| |__| |_| |   //
  // /_/   \_\_____\___/    //
  //                        //
  ////////////////////////////

  cv32e40x_alu
    #(.B_EXT(B_EXT))
  alu_i
  (
    .operator_i          ( id_ex_pipe_i.alu_operator     ),
    .operand_a_i         ( id_ex_pipe_i.alu_operand_a    ),
    .operand_b_i         ( id_ex_pipe_i.alu_operand_b    ),
    .muldiv_operand_b_i  ( id_ex_pipe_i.muldiv_operand_b ),

    // ALU CLZ interface
    .div_clz_en_i        ( div_clz_en                    ),
    .div_clz_data_rev_i  ( div_clz_data_rev              ),
    .div_clz_result_o    ( div_clz_result                ),

    // ALU shifter interface
    .div_shift_en_i      ( div_shift_en                  ),
    .div_shift_amt_i     ( div_shift_amt                 ),
    .div_op_b_shifted_o  ( div_op_b_shifted              ),

    // Result(s)
    .result_o            ( alu_result                    ),
    .cmp_result_o        ( alu_cmp_result                )
  );

  ////////////////////////////////////////////////////
  //  ____ _____     __     __  ____  _____ __  __  //
  // |  _ \_ _\ \   / /    / / |  _ \| ____|  \/  | //
  // | | | | | \ \ / /    / /  | |_) |  _| | |\/| | //
  // | |_| | |  \ V /    / /   |  _ <| |___| |  | | //
  // |____/___|  \_/    /_/    |_| \_\_____|_|  |_| //
  //                                                //
  ////////////////////////////////////////////////////

  generate
    if (M_EXT == M) begin: div

      cv32e40x_div div_i
        (
         .clk                ( clk                                  ),
         .rst_n              ( rst_n                                ),

         // Input IF
         .data_ind_timing_i  ( 1'b0                                 ), // CV32E40X does not support data independent timing
         .operator_i         ( id_ex_pipe_i.div_operator            ),
         .op_a_i             ( id_ex_pipe_i.muldiv_operand_a        ),
         .op_b_i             ( id_ex_pipe_i.muldiv_operand_b        ),

         // ALU CLZ interface
         .alu_clz_result_i   ( div_clz_result                       ),
         .alu_clz_en_o       ( div_clz_en                           ),
         .alu_clz_data_rev_o ( div_clz_data_rev                     ),

         // ALU shifter interface
         .alu_op_b_shifted_i ( div_op_b_shifted                     ),
         .alu_shift_en_o     ( div_shift_en                         ),
         .alu_shift_amt_o    ( div_shift_amt                        ),

         // Result
         .result_o           ( div_result                           ),

         // Handshakes
         .halt_i             ( ctrl_fsm_i.halt_ex                   ),
         .kill_i             ( ctrl_fsm_i.kill_ex                   ),
         .valid_i            ( div_en                               ),
         .ready_o            ( div_ready                            ),
         .valid_o            ( div_valid                            ),
         .ready_i            ( wb_ready_i                           )
         );

    end
    else begin: no_div

      // No divider, tie off outputs
      assign div_clz_en       = 1'b0;
      assign div_clz_data_rev = 32'h0;
      assign div_shift_en     = 1'b0;
      assign div_shift_amt    = 6'h0;
      assign div_ready        = 1'b1;
      assign div_valid        = 1'b0;
      assign div_result       = 32'h0;

    end
  endgenerate

  ////////////////////////////////////////////////////////////////
  //  __  __ _   _ _   _____ ___ ____  _     ___ _____ ____     //
  // |  \/  | | | | | |_   _|_ _|  _ \| |   |_ _| ____|  _ \    //
  // | |\/| | | | | |   | |  | || |_) | |    | ||  _| | |_) |   //
  // | |  | | |_| | |___| |  | ||  __/| |___ | || |___|  _ <    //
  // |_|  |_|\___/|_____|_| |___|_|   |_____|___|_____|_| \_\   //
  //                                                            //
  ////////////////////////////////////////////////////////////////

  generate
    if (M_EXT != M_NONE) begin: mul

      cv32e40x_mult mult_i
        (
         .clk             ( clk                           ),
         .rst_n           ( rst_n                         ),

         .operator_i      ( id_ex_pipe_i.mul_operator     ),
         .signed_mode_i   ( id_ex_pipe_i.mul_signed_mode  ),
         .op_a_i          ( id_ex_pipe_i.muldiv_operand_a ),
         .op_b_i          ( id_ex_pipe_i.muldiv_operand_b ),

         // Result
         .result_o        ( mul_result                    ),

         .halt_i          ( ctrl_fsm_i.halt_ex            ),
         .kill_i          ( ctrl_fsm_i.kill_ex            ),

         // Handshakes
         .valid_i         ( mul_en                        ),
         .ready_o         ( mul_ready                     ),
         .valid_o         ( mul_valid                     ),
         .ready_i         ( wb_ready_i                    )
         );

    end
    else begin: no_mul

      // No multiplier, tie off outputs
      assign mul_result = 32'h0;
      assign mul_ready  = 1'b1;
      assign mul_valid  = 1'b0;

    end
  endgenerate

  ///////////////////////////////////////
  // EX/WB Pipeline Register           //
  ///////////////////////////////////////
  always_ff @(posedge clk, negedge rst_n)
  begin : EX_WB_PIPE_REGISTERS
    if (rst_n == 1'b0)
    begin
      ex_wb_pipe_o.instr_valid        <= 1'b0;
      ex_wb_pipe_o.rf_we              <= 1'b0;
      ex_wb_pipe_o.rf_waddr           <= '0;
      ex_wb_pipe_o.rf_wdata           <= 32'b0;
      ex_wb_pipe_o.pc                 <= 32'h0;
      ex_wb_pipe_o.instr              <= INST_RESP_RESET_VAL;
      ex_wb_pipe_o.instr_meta         <= '0;

      ex_wb_pipe_o.illegal_insn       <= 1'b0;

      ex_wb_pipe_o.alu_jmp_qual       <= 1'b0;
      ex_wb_pipe_o.alu_bch_qual       <= 1'b0;
      ex_wb_pipe_o.alu_bch_taken_qual <= 1'b0;

      ex_wb_pipe_o.sys_en             <= 1'b0;
      ex_wb_pipe_o.sys_dret_insn      <= 1'b0;
      ex_wb_pipe_o.sys_ebrk_insn      <= 1'b0;
      ex_wb_pipe_o.sys_ecall_insn     <= 1'b0;
      ex_wb_pipe_o.sys_fence_insn     <= 1'b0;
      ex_wb_pipe_o.sys_fencei_insn    <= 1'b0;
      ex_wb_pipe_o.sys_mret_insn      <= 1'b0;
      ex_wb_pipe_o.sys_wfi_insn       <= 1'b0;
      ex_wb_pipe_o.sys_wfe_insn       <= 1'b0;

      ex_wb_pipe_o.trigger_match      <= '0;

      ex_wb_pipe_o.lsu_en             <= 1'b0;
      ex_wb_pipe_o.csr_en             <= 1'b0;
      ex_wb_pipe_o.csr_op             <= CSR_OP_READ;
      ex_wb_pipe_o.csr_addr           <= 12'h000;
      ex_wb_pipe_o.csr_wdata          <= 32'h00000000;
      ex_wb_pipe_o.csr_mnxti_access   <= 1'b0;
      ex_wb_pipe_o.xif_en             <= 1'b0;
      ex_wb_pipe_o.xif_meta           <= '0;
      ex_wb_pipe_o.first_op           <= 1'b0;
      ex_wb_pipe_o.last_op            <= 1'b0;
      ex_wb_pipe_o.abort_op           <= 1'b0;
      ex_wb_pipe_o.csr_impl_wr        <= 1'b0;

      ex_wb_pipe_o.priv_lvl           <= PRIV_LVL_M;
    end
    else
    begin
      if (ex_valid_o && wb_ready_i) begin
        ex_wb_pipe_o.instr_valid <= 1'b1;
        ex_wb_pipe_o.priv_lvl    <= id_ex_pipe_i.priv_lvl;
        ex_wb_pipe_o.last_op     <= last_op_o;
        ex_wb_pipe_o.first_op    <= first_op;
        ex_wb_pipe_o.abort_op    <= id_ex_pipe_i.abort_op; // MPU exceptions and watchpoint triggers have WB timing and will not impact ex_wb_pipe.abort_op
        // Deassert rf_we in case of illegal csr instruction or when the first half of a misaligned/split LSU goes to WB.
        // Also deassert if CSR was accepted both by eXtension if and pipeline
        ex_wb_pipe_o.rf_we       <= (csr_is_illegal || lsu_split_i) ? 1'b0 : id_ex_pipe_i.rf_we;
        ex_wb_pipe_o.lsu_en      <= id_ex_pipe_i.lsu_en;

        if (id_ex_pipe_i.rf_we) begin
          ex_wb_pipe_o.rf_waddr <= id_ex_pipe_i.rf_waddr;
          if (!id_ex_pipe_i.lsu_en) begin
            ex_wb_pipe_o.rf_wdata <= rf_wdata_o;
          end
        end

        ex_wb_pipe_o.alu_jmp_qual       <= id_ex_pipe_i.alu_jmp && id_ex_pipe_i.alu_en;
        ex_wb_pipe_o.alu_bch_qual       <= id_ex_pipe_i.alu_bch && id_ex_pipe_i.alu_en;
        ex_wb_pipe_o.alu_bch_taken_qual <= id_ex_pipe_i.alu_bch && id_ex_pipe_i.alu_en && branch_decision_o;

        // Update signals for CSR access in WB
        // deassert csr_en in case of an internal illegal csr instruction
        // to avoid writing to CSRs inside the core.
        ex_wb_pipe_o.csr_en     <= (csr_illegal_i || xif_csr_error_o) ? 1'b0 : id_ex_pipe_i.csr_en;
        if (id_ex_pipe_i.csr_en) begin
          // The ex_wb_pipe_o.csr_addr is used (for RVFI) even for CSR instructions that do not write to the CSR
          // Any future clock gating improvements to ex_wb_pipe.csr_addr must take this into account.
          ex_wb_pipe_o.csr_addr         <= id_ex_pipe_i.alu_operand_b[11:0];
          ex_wb_pipe_o.csr_wdata        <= id_ex_pipe_i.alu_operand_a;
          ex_wb_pipe_o.csr_op           <= id_ex_pipe_i.csr_op;
          ex_wb_pipe_o.csr_mnxti_access <= csr_mnxti_read_i;
          ex_wb_pipe_o.csr_impl_wr      <= csr_hz_i.impl_wr_ex;
        end

        // Propagate signals needed for exception handling in WB
        ex_wb_pipe_o.pc             <= id_ex_pipe_i.pc;
        ex_wb_pipe_o.instr          <= id_ex_pipe_i.instr;
        ex_wb_pipe_o.instr_meta     <= id_ex_pipe_i.instr_meta;

        ex_wb_pipe_o.sys_en            <= id_ex_pipe_i.sys_en;
        if (id_ex_pipe_i.sys_en) begin
          ex_wb_pipe_o.sys_dret_insn   <= id_ex_pipe_i.sys_dret_insn;
          ex_wb_pipe_o.sys_ebrk_insn   <= id_ex_pipe_i.sys_ebrk_insn;
          ex_wb_pipe_o.sys_ecall_insn  <= id_ex_pipe_i.sys_ecall_insn;
          ex_wb_pipe_o.sys_fence_insn  <= id_ex_pipe_i.sys_fence_insn;
          ex_wb_pipe_o.sys_fencei_insn <= id_ex_pipe_i.sys_fencei_insn;
          ex_wb_pipe_o.sys_mret_insn   <= id_ex_pipe_i.sys_mret_insn;
          ex_wb_pipe_o.sys_wfi_insn    <= id_ex_pipe_i.sys_wfi_insn;
          ex_wb_pipe_o.sys_wfe_insn    <= id_ex_pipe_i.sys_wfe_insn;
        end

        // CSR illegal instruction detected in this stage, OR'ing in the status
        ex_wb_pipe_o.illegal_insn   <= id_ex_pipe_i.illegal_insn || csr_is_illegal;
        ex_wb_pipe_o.trigger_match  <= id_ex_pipe_i.trigger_match;

        // eXtension interface
        ex_wb_pipe_o.xif_en         <= ctrl_fsm_i.kill_xif ? 1'b0 : id_ex_pipe_i.xif_en;
        ex_wb_pipe_o.xif_meta       <= id_ex_pipe_i.xif_meta;
      end else if (wb_ready_i) begin
        // we are ready for a new instruction, but there is none available,
        // so we introduce a bubble
        ex_wb_pipe_o.instr_valid <= 1'b0;
      end
    end
  end

  // LSU inputs are valid when LSU is enabled; LSU outputs need to remain valid until downstream stage is ready
  // If a trigger matches LSU address, this valid will be gated off inside the load_store_unit to prevent the instruction
  // from accessing the bus.
  assign lsu_valid_o = lsu_en_gated;
  assign lsu_ready_o = wb_ready_i;

  // ALU is single-cycle and output is therefore immediately valid (no handshake to optimize timing)
  assign alu_valid = 1'b1;
  assign alu_ready = wb_ready_i;

  // CSR is single-cycle and output is therefore immediately valid (no handshake to optimize timing)
  assign csr_valid = 1'b1;
  assign csr_ready = wb_ready_i;

  // SYS instructions (ebreak, wfi, etc.) are single-cycle (and have no result output) (no handshake to optimize timing)
  assign sys_valid = 1'b1;
  assign sys_ready = wb_ready_i;

  // Forced nop (exceptions or trigger matches) will pass through the EX stage in a single cycle.
  assign forced_nop_valid = 1'b1;

  // CLIC and mret pointers pass through the EX stage in a single cycle
  assign clic_ptr_valid = 1'b1;
  assign mret_ptr_valid = 1'b1;

  // EX stage is ready immediately when killed and otherwise when its functional units are ready,
  // unless the stage is being halted. The late (data_rvalid_i based) downstream wb_ready_i signal
  // fans into the ready signals of all functional units.

  assign ex_ready_o = ctrl_fsm_i.kill_ex || (alu_ready && csr_ready && sys_ready && mul_ready && div_ready && lsu_ready_i && xif_ready && !ctrl_fsm_i.halt_ex);

  assign ex_valid_o = ((id_ex_pipe_i.alu_en && alu_valid)                   ||
                       (id_ex_pipe_i.csr_en && csr_valid)                   ||
                       (id_ex_pipe_i.sys_en && sys_valid)                   ||
                       (id_ex_pipe_i.mul_en && mul_valid)                   ||
                       (id_ex_pipe_i.div_en && div_valid)                   ||
                       (id_ex_pipe_i.lsu_en && lsu_valid_i)                 ||
                       (id_ex_pipe_i.xif_en && xif_valid)                   ||
                       (id_ex_pipe_i.instr_meta.clic_ptr && clic_ptr_valid) ||
                       (id_ex_pipe_i.instr_meta.mret_ptr && mret_ptr_valid) ||
                       (forced_nop && forced_nop_valid)
                      ) && instr_valid;

  //---------------------------------------------------------------------------
  // eXtension interface
  //---------------------------------------------------------------------------

  // XIF is modeled as a functional unit that occupies EX for a single cycle no matter whether the
  // result handshake is received in a single cycle or not.
  assign xif_valid = 1'b1;
  assign xif_ready = wb_ready_i;

  // TODO:XIF The EX stage needs to be ready to receive a result from a single cycle offloaded
  // instruction. In such case the result can be written into ex_wb_pipe_i.rf_wdata (as if the XIF
  // is a functional unit living in EX) and then typically a cycle later the result would get
  // written from ex_wb_pipe_i.rf_wdata into the registerfile.

endmodule






































// Description:    WPT                                                        //
//                 Module blocks any trans to the MPU if a watchpoint trigger //
//                 fires for the current address. Trigger match is reported   //
//                 with WB timing similar to how the MPU reports status.      //
//                 cv32e40x_wpt is inherited from cv32e40x_mpu and adataped   //
//                 for watchpoint triggers.                                   //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_wpt import cv32e40x_pkg::*;
  (
   input logic  clk,
   input logic  rst_n,

   // Input from debug_triggers module
   input  logic [31:0]    trigger_match_i,

   // Interface towards mpu interface
   input  logic           mpu_trans_ready_i,
   output logic           mpu_trans_valid_o,
   output logic           mpu_trans_pushpop_o,
   output obi_data_req_t  mpu_trans_o,

   input  logic           mpu_resp_valid_i,
   input  data_resp_t     mpu_resp_i,

   // Interface towards core
   input  logic           core_trans_valid_i,
   output logic           core_trans_ready_o,
   input  logic           core_trans_pushpop_i,
   input  obi_data_req_t  core_trans_i,

   output logic           core_resp_valid_o,
   output data_resp_t     core_resp_o,

   // Indication from the core that there will be one pending transaction in the next cycle
   input logic            core_one_txn_pend_n,

   // Indication from the core that watchpoint triggers should be reported after all in flight transactions
   // are complete (default behavior for main core requests, but not used for XIF requests)
   input logic            core_wpt_wait_i,

   // Report watchpoint triggers to the core immediatly (used in case core_wpt_wait_i is not asserted)
   output logic [31:0]    core_wpt_match_o
   );

  logic        wpt_block_core;
  logic        wpt_block_bus;
  logic        wpt_trans_valid;
  logic        wpt_trans_ready;
  logic [31:0] wpt_match;   // 1 bit per trigger, unused bits are tied to 0 in debug_triggers
  wpt_state_e  state_q, state_n;

  logic [31:0] wpt_match_n, wpt_match_q;

  // FSM that will "consume" transfers with firing watchpoint triggers.
  // Upon trigger match, this FSM will prevent the transfer from going out on the bus
  // and wait for all in flight bus transactions to complete while blocking new transfers.
  // When all in flight transactions are complete, it will respond with the correct status before
  // allowing new transfers to go through.
  // The input signal core_one_txn_pend_n indicates that there, from the core's point of view,
  // will be one pending transaction in the next cycle. Upon watchpoint match, this transaction
  // will be completed by this FSM
  always_comb begin

    state_n         = state_q;
    wpt_block_core  = 1'b0;
    wpt_block_bus   = 1'b0;
    wpt_trans_valid = 1'b0;
    wpt_trans_ready = 1'b0;
    wpt_match       = '0;
    wpt_match_n     = wpt_match_q;

    case(state_q)
      WPT_IDLE: begin
        if (|trigger_match_i && core_trans_valid_i) begin
          // Remember which trigger(s) hit
          wpt_match_n = trigger_match_i;

          // Block transfer from going out on the bus.
          wpt_block_bus  = 1'b1;

          // Signal to the core that the transfer was accepted (but will be consumed by the WPT)
          wpt_trans_ready = 1'b1;

          if (core_wpt_wait_i) begin
            state_n = core_one_txn_pend_n ? WPT_MATCH_RESP : WPT_MATCH_WAIT;
          end

        end
      end
      WPT_MATCH_WAIT: begin

        // Block new transfers while waiting for in flight transfers to complete
        wpt_block_bus  = 1'b1;
        wpt_block_core = 1'b1;

        if (core_one_txn_pend_n) begin
          state_n = WPT_MATCH_RESP;
        end
      end
      WPT_MATCH_RESP: begin

        // Keep blocking new transfers
        wpt_block_bus  = 1'b1;
        wpt_block_core = 1'b1;

        // Set up WPT response towards the core
        wpt_trans_valid = 1'b1;
        wpt_match       = wpt_match_q;

        // Clear wpt_match_q
        wpt_match_n     = '0;

        // Go back to IDLE uncoditionally.
        // The core is expected to always be ready for the response
        state_n = WPT_IDLE;

      end
      default: ;
    endcase
  end

  always_ff @(posedge clk, negedge rst_n) begin
    if (rst_n == 1'b0) begin
      state_q     <= WPT_IDLE;
      wpt_match_q <= '0;
    end
    else begin
      state_q <= state_n;
      wpt_match_q <= wpt_match_n;
    end
  end

  // Forward transaction request towards MPU
  assign mpu_trans_valid_o   = core_trans_valid_i && !wpt_block_bus;
  assign mpu_trans_o         = core_trans_i;
  assign mpu_trans_pushpop_o = core_trans_pushpop_i;


  // Forward transaction response towards core
  assign core_resp_valid_o        = mpu_resp_valid_i || wpt_trans_valid;
  assign core_resp_o.bus_resp     = mpu_resp_i.bus_resp;
  assign core_resp_o.mpu_status   = mpu_resp_i.mpu_status;
  assign core_resp_o.align_status = mpu_resp_i.align_status;
  assign core_resp_o.wpt_match    = wpt_match;


  // Report WPT matches to the core immediately
  assign core_wpt_match_o = trigger_match_i;

  // Signal ready towards core
  assign core_trans_ready_o = (mpu_trans_ready_i && !wpt_block_core) || wpt_trans_ready;



endmodule




// Description:    Alignment checker for mret pointers and atomics            //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_align_check import cv32e40x_pkg::*;
  #(  parameter bit          IF_STAGE          = 1,
      parameter type         CORE_REQ_TYPE     = obi_inst_req_t,
      parameter type         CORE_RESP_TYPE    = inst_resp_t,
      parameter type         BUS_RESP_TYPE     = inst_resp_t

  )
  (
   input logic  clk,
   input logic  rst_n,

   // Enable signal, active for atomics and pointers
   input  logic           align_check_en_i,
   input  logic           misaligned_access_i,

   // Interface towards bus interface
   input  logic           bus_trans_ready_i,
   output logic           bus_trans_valid_o,
   output CORE_REQ_TYPE   bus_trans_o,

   input  logic           bus_resp_valid_i,
   input  BUS_RESP_TYPE   bus_resp_i,

   // Interface towards core (MPU)
   input  logic           core_trans_valid_i,
   output logic           core_trans_ready_o,
   input  CORE_REQ_TYPE   core_trans_i,

   output logic           core_resp_valid_o,
   output CORE_RESP_TYPE  core_resp_o,

   // Indication from the core that there will be one pending transaction in the next cycle
   input logic            core_one_txn_pend_n,

   // Indication from the core that an alignment error should be reported after all in flight transactions
   // are complete (default behavior for main core requests, but not used for XIF requests)
   input logic            core_align_err_wait_i,

   // Report alignment errors to the core immediatly (used in case core_align_wait_i is not asserted)
   output logic           core_align_err_o
   );

  logic          align_block_core;
  logic          align_block_bus;
  logic          align_trans_valid;
  logic          align_trans_ready;
  logic          align_err;
  logic          core_trans_we;
  align_status_e align_status;
  align_state_e  state_q, state_n;

  // FSM that will "consume" transfers which violates alignment requirement for atomics or pointers.
  // Upon an error, this FSM will prevent the transfer from going out on the bus
  // and wait for all in flight bus transactions to complete while blocking new transfers.
  // When all in flight transactions are complete, it will respond with the correct status before
  // allowing new transfers to go through.
  // The input signal core_one_txn_pend_n indicates that there, from the core's point of view,
  // will be one pending transaction in the next cycle. Upon an error, this transaction
  // will be completed by this FSM
  always_comb begin

    state_n           = state_q;
    align_block_core  = 1'b0;
    align_block_bus   = 1'b0;
    align_trans_valid = 1'b0;
    align_trans_ready = 1'b0;
    align_status      = ALIGN_OK;

    case(state_q)
      ALIGN_IDLE: begin
        if (align_err && core_trans_valid_i) begin

          // Block transfer from going out on the bus.
          align_block_bus  = 1'b1;

          // Signal to the core that the transfer was accepted (but will be consumed by the align)
          align_trans_ready = 1'b1;

          if (core_align_err_wait_i) begin
            if (core_trans_we) begin
              state_n = core_one_txn_pend_n ? ALIGN_WR_ERR_RESP : ALIGN_WR_ERR_WAIT;
            end else begin
              state_n = core_one_txn_pend_n ? ALIGN_RE_ERR_RESP : ALIGN_RE_ERR_WAIT;
            end
          end

        end
      end
      ALIGN_WR_ERR_WAIT,
      ALIGN_RE_ERR_WAIT: begin

        // Block new transfers while waiting for in flight transfers to complete
        align_block_bus  = 1'b1;
        align_block_core = 1'b1;

        if (core_one_txn_pend_n) begin
          state_n = (state_q == ALIGN_WR_ERR_WAIT) ? ALIGN_WR_ERR_RESP : ALIGN_RE_ERR_RESP;
        end
      end
      ALIGN_WR_ERR_RESP,
      ALIGN_RE_ERR_RESP: begin

        // Keep blocking new transfers
        align_block_bus  = 1'b1;
        align_block_core = 1'b1;

        // Set up align response towards the core
        align_trans_valid = 1'b1;
        align_status      = (state_q == ALIGN_WR_ERR_RESP) ? ALIGN_WR_ERR : ALIGN_RE_ERR;

        // Go back to IDLE uncoditionally.
        // The core is expected to always be ready for the response
        state_n = ALIGN_IDLE;

      end
      default: ;
    endcase
  end

  always_ff @(posedge clk, negedge rst_n) begin
    if (rst_n == 1'b0) begin
      state_q     <= ALIGN_IDLE;
    end
    else begin
      state_q <= state_n;
    end
  end

  // Forward transaction request towards MPU
  assign bus_trans_valid_o   = core_trans_valid_i && !align_block_bus;
  assign bus_trans_o         = core_trans_i;


  // Forward transaction response towards core
  assign core_resp_valid_o        = bus_resp_valid_i || align_trans_valid;
  assign core_resp_o.bus_resp     = bus_resp_i;
  assign core_resp_o.align_status = align_status;
  assign core_resp_o.mpu_status   = MPU_OK;  // Assigned in the MPU (upstream), tied off to MPU_OK here.
  assign core_resp_o.wpt_match    = '0;      // Assigned in the watchpoint unit (upstream), tied off to zero here.

  // Detect alignment error
  assign align_err = align_check_en_i && misaligned_access_i;

  // Report align matches to the core immediately
  assign core_align_err_o = align_err;

  // Signal ready towards core
  assign core_trans_ready_o     = (bus_trans_ready_i && !align_block_core) || align_trans_ready;

  generate
    if (IF_STAGE) begin: alcheck_if
      assign core_trans_we = 1'b0;
    end
    else begin: alcheck_lsu
      assign core_trans_we = core_trans_i.we;
    end
  endgenerate

endmodule






// Description:    Response filter for the LSU. Used to return rvalid early   //
//                 for bufferable transfers.                                  //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_lsu_response_filter
  import cv32e40x_pkg::*;
  #(parameter int unsigned DEPTH = 2)
  (
   // clock and reset
   input logic            clk,
   input logic            rst_n,

   // inputs
   input  logic           valid_i,
   input  obi_data_req_t  trans_i,
   input  logic           ready_i,

   input  logic           resp_valid_i,
   input  obi_data_resp_t resp_i,

   // outputs
   output logic           valid_o,
   output obi_data_req_t  trans_o,
   output logic           ready_o,

   output logic           busy_o,
   output logic           bus_busy_o,      // There are outstanding transactions on the bus side.
   output logic           resp_valid_o,
   output obi_data_resp_t resp_o
);

  localparam CNT_WIDTH = $clog2(DEPTH+1);

  // Core side transfer counter
  logic [CNT_WIDTH-1:0]  bus_cnt_q;
  logic [CNT_WIDTH-1:0]  bus_next_cnt;
  logic                  bus_count_up;
  logic                  bus_count_down;

  // Bus side transfer counter
  logic [CNT_WIDTH-1:0]  core_cnt_q;
  logic [CNT_WIDTH-1:0]  core_next_cnt;
  logic                  core_count_up;
  logic                  core_count_down;

  logic                  core_trans_accepted;
  logic                  bus_trans_accepted;

  logic                  bus_resp_is_bufferable;
  logic                  core_resp_is_bufferable;

  // Shift register containing bufferable cofiguration of outstanding transfers
  outstanding_t [DEPTH:0]        outstanding_q; // Using 1-DEPTH entries for outstanding xfers, index 0 is tied low
  outstanding_t [DEPTH:0]        outstanding_next;

  assign busy_o              = ( bus_cnt_q != '0) || valid_i;
  assign bus_busy_o          = ( bus_cnt_q != '0);

  // The two trans valid signals will always have the same value as they are gated with the same condition
  assign core_trans_accepted = ready_o && valid_i; // Transfer accepted on the core side of the response filter
  assign bus_trans_accepted  = ready_i && valid_o; // Transfer accepted on the bus side of the response filter

  // Bufferable configuration of the oldest outstanding transfer
  assign bus_resp_is_bufferable = outstanding_q[bus_cnt_q].bufferable;

  // Bufferable configuration of the oldest outstanding transfer seen from the LSU control logic
  assign core_resp_is_bufferable = outstanding_q[core_cnt_q].bufferable;

  always_comb begin
    outstanding_next = outstanding_q;

    if (bus_trans_accepted) begin
      // Shift in bufferable bit and type of accepted transfer
      outstanding_next[DEPTH:1]    = outstanding_q[DEPTH-1:0];
      outstanding_next[1]          = outstanding_t'{bufferable: trans_i.memtype[0], store: trans_i.we};
      outstanding_next[0]          = '0; // Tie off unused index
    end

  end

  ///////////////////////////////////////////
  // Counter
  ///////////////////////////////////////////

  assign core_count_up   = core_trans_accepted;
  assign core_count_down = resp_valid_o;

  assign bus_count_up    = bus_trans_accepted;
  assign bus_count_down  = resp_valid_i;

  always_comb begin
    core_next_cnt = core_cnt_q;
    if (core_count_up) begin
      core_next_cnt++;
    end
    if (core_count_down) begin
      core_next_cnt--;
    end

    bus_next_cnt = bus_cnt_q;
    if (bus_count_up) begin
      bus_next_cnt++;
    end
    if (bus_count_down) begin
      bus_next_cnt--;
    end
  end

  ///////////////////////////////////////////
  // Registers
  ///////////////////////////////////////////

  always_ff @(posedge clk, negedge rst_n) begin
    if(rst_n == 1'b0)  begin
      bus_cnt_q                <= '0;
      core_cnt_q               <= '0;
      outstanding_q <= '0;
    end else begin
      bus_cnt_q                <= bus_next_cnt;
      core_cnt_q               <= core_next_cnt;
      outstanding_q <= outstanding_next;
    end
  end

  ///////////////////////////////////////////
  // Filtering
  ///////////////////////////////////////////

  // Blocking transfers when outstanding queue is full to avoid bus_cnt_q overflow
  assign ready_o      = ready_i && (bus_cnt_q < DEPTH);
  assign valid_o      = valid_i && (bus_cnt_q < DEPTH);

  // Response Mux
  // If the oldest outstanding transaction on the bus side is bufferable,
  // response valid will be signalled if the oldest outstanding transaction on the core side is bufferable.
  // If the oldest outstanding transfer is non-bufferable the valid response from the bus will be passed through.
  assign resp_valid_o = (bus_resp_is_bufferable) ? core_resp_is_bufferable : resp_valid_i;
  assign trans_o      = trans_i;

  // bus_resp goes straight through
  assign resp_o.rdata  = resp_i.rdata;
  assign resp_o.err    = {outstanding_q[bus_cnt_q].store, (resp_valid_i && resp_i.err[0])};
  assign resp_o.exokay = resp_i.exokay;

endmodule







// Description:    Single word write buffer                                   //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_write_buffer import cv32e40x_pkg::*;
#(
  parameter int          PMA_NUM_REGIONS = 0,
  parameter pma_cfg_t    PMA_CFG[PMA_NUM_REGIONS-1:0] = '{default:PMA_R_DEFAULT}
)
  (
   // clock and reset
   input logic           clk,
   input logic           rst_n,

   // inputs
   input  logic          valid_i,
   input  obi_data_req_t trans_i,
   input  logic          ready_i,

   // outputs
   output logic          valid_o,
   output obi_data_req_t trans_o,
   output logic          ready_o
  );

  // local signals
  write_buffer_state_e        state, next_state;
  obi_data_req_t              trans_q;
  logic                       push;
  logic                       bufferable;

  assign bufferable = trans_i.memtype[0];

  ///////////////////////////////////////////
  // FSM
  ///////////////////////////////////////////
  always_ff @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
      state <= WBUF_EMPTY;
    end else begin
      state <= next_state;
    end
  end

  always_comb begin
    next_state = state;
    push       = 1'b0;

    case(state)
      WBUF_EMPTY: begin // buffer is empty
        if(bufferable && valid_i && !ready_i) begin
          next_state = WBUF_FULL;
          push       = 1'b1; // push incoming data into the buffer
        end
      end
      WBUF_FULL: begin // buffer is full
        if(ready_i) begin
          if (bufferable && valid_i) begin
            next_state = WBUF_FULL;
            push       = 1'b1; // push incoming data into the buffer
          end else begin
            next_state = WBUF_EMPTY;
          end
        end
      end

      default:;
    endcase // case (state)
  end

  ///////////////////////////////////////////
  // Buffer
  ///////////////////////////////////////////
  always_ff @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
      trans_q <= obi_data_req_t'{we: 1'b1, default: '0};
    end else if (push) begin
      trans_q <= trans_i;
    end
  end

  ///////////////////////////////////////////
  // Outputs
  ///////////////////////////////////////////
  assign ready_o = (state == WBUF_FULL) ?
                   (bufferable && ready_i) : // A downstream ready will free up the buffer for a new bufferable transfer
                   (bufferable || ready_i);  // Ready for bufferable transfer, accept any transfer if downstream is ready
  assign valid_o = (state == WBUF_FULL) || valid_i;
  assign trans_o = (state == WBUF_FULL) ? trans_q : trans_i;

endmodule






// Description:    Open Bus Interface adapter. Translates transaction request //
//                 on the trans_* interface into an OBI A channel transfer.   //
//                 The OBI R channel transfer translated (i.e. passed on) as  //
//                 a transaction response on the resp_* interface.            //
//                                                                            //
//                 This adapter does not limit the number of outstanding      //
//                 OBI transactions in any way.                               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_data_obi_interface import cv32e40x_pkg::*;
(
  input  logic        clk,
  input  logic        rst_n,

  // Transaction request interface
  input  logic         trans_valid_i,
  output logic         trans_ready_o,
  input obi_data_req_t trans_i,

  // Transaction response interface
  output logic           resp_valid_o,          // Note: Consumer is assumed to be 'ready' whenever resp_valid_o = 1
  output obi_data_resp_t resp_o,

  // OBI interface
  cv32e40x_if_c_obi.master m_c_obi_data_if
);

  //////////////////////////////////////////////////////////////////////////////
  // OBI R Channel
  //////////////////////////////////////////////////////////////////////////////

  // The OBI R channel signals are passed on directly on the transaction response
  // interface (resp_*). It is assumed that the consumer of the transaction response
  // is always receptive when resp_valid_o = 1 (otherwise a response would get dropped)

  assign resp_valid_o = m_c_obi_data_if.s_rvalid.rvalid;
  assign resp_o       = m_c_obi_data_if.resp_payload;

  //////////////////////////////////////////////////////////////////////////////
  // OBI A Channel
  //////////////////////////////////////////////////////////////////////////////

  // If the incoming transaction itself is stable, then it satisfies the OBI protocol
  // and signals can be passed to/from OBI directly.
  assign m_c_obi_data_if.s_req.req   = trans_valid_i;
  assign m_c_obi_data_if.req_payload = trans_i;

  assign trans_ready_o = m_c_obi_data_if.s_gnt.gnt;

endmodule






// Description:    Load Store Unit, used to eliminate multiple access during  //
//                 processor stalls, and to align bytes and halfwords         //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_load_store_unit import cv32e40x_pkg::*;
#(
  parameter a_ext_e      A_EXT = A_NONE,
  parameter bit          X_EXT = 0,
  parameter int unsigned X_ID_WIDTH = 4,
  parameter int          PMA_NUM_REGIONS = 0,
  parameter pma_cfg_t    PMA_CFG[PMA_NUM_REGIONS-1:0] = '{default:PMA_R_DEFAULT},
  parameter int          DBG_NUM_TRIGGERS = 1,
  parameter bit          DEBUG = 1,
  parameter logic [31:0] DM_REGION_START = 32'hF0000000,
  parameter logic [31:0] DM_REGION_END   = 32'hF0003FFF
)
(
  input  logic        clk,
  input  logic        rst_n,

  // From controller FSM
  input  ctrl_fsm_t   ctrl_fsm_i,

  // output to data memory
  cv32e40x_if_c_obi.master m_c_obi_data_if,

  // ID/EX pipeline
  input id_ex_pipe_t  id_ex_pipe_i,

  // Control outputs
  output logic        busy_o,
  output logic        bus_busy_o,        // There are outstanding OBI transactions
  output logic        interruptible_o,

  // Trigger match input
  input logic [31:0]  trigger_match_0_i,

  // Stage 0 outputs (EX)
  output logic        lsu_split_0_o,            // Misaligned access is split in two transactions (to controller)
  output logic        lsu_first_op_0_o,         // First operation is active in EX
  output logic        lsu_last_op_0_o,          // Last operation is active in EX
  output lsu_atomic_e lsu_atomic_0_o,           // Is there an atomic in EX, and of which type

  // outputs to trigger module
  output logic [31:0] lsu_addr_o,
  output logic        lsu_we_o,
  output logic [3:0]  lsu_be_o,

  // Stage 1 outputs (WB)
  output lsu_err_wb_t lsu_err_1_o,
  output logic [31:0] lsu_rdata_1_o,            // LSU read data
  output mpu_status_e lsu_mpu_status_1_o,       // MPU (PMA) status, response/WB timing. To controller and wb_stage
  output logic [31:0] lsu_wpt_match_1_o,        // Address match trigger, WB timing.
  output align_status_e lsu_align_status_1_o,   // Alignment status (for atomics), WB timing
  output lsu_atomic_e lsu_atomic_1_o,           // Is there an atomic in WB, and of which type.

  // Privilege mode
  input              privlvl_t priv_lvl_lsu_i,

  // Handshakes
  input  logic        valid_0_i,                // Handshakes for first LSU stage (EX)
  output logic        ready_0_o,                // LSU ready for new data in EX stage
  output logic        valid_0_o,
  input  logic        ready_0_i,

  input  logic        valid_1_i,                // Handshakes for second LSU stage (WB)
  output logic        ready_1_o,                // LSU ready for new data in WB stage
  output logic        valid_1_o,
  input  logic        ready_1_i,

  // eXtension interface
  cv32e40x_if_xif.cpu_mem        xif_mem_if,
  cv32e40x_if_xif.cpu_mem_result xif_mem_result_if
);

  localparam DEPTH = 2;                         // Maximum number of outstanding transactions

  // Transaction request (before aligner)
  trans_req_t     trans;
  logic           trans_valid;
  logic           trans_ready;

  // Aligned transaction request (to cv32e40x_wpt)
  logic           wpt_trans_valid;
  logic           wpt_trans_ready;
  logic           wpt_trans_pushpop;
  obi_data_req_t  wpt_trans;

  // Align_check transaction request (to cv32e40x_align_check)
  logic           alcheck_trans_valid;
  logic           alcheck_trans_ready;
  obi_data_req_t  alcheck_trans;

  // Transaction request to cv32e40x_mpu
  logic           mpu_trans_valid;
  logic           mpu_trans_ready;
  logic           mpu_trans_pushpop;
  logic           mpu_trans_atomic;
  obi_data_req_t  mpu_trans;

  // Transaction response
  logic           resp_valid;
  logic [31:0]    resp_rdata;
  data_resp_t     resp;

  // Transaction response interface (from cv32e40x_wpt)
  logic           wpt_resp_valid;
  logic [31:0]    wpt_resp_rdata;
  data_resp_t     wpt_resp;

  // Transaction response interface (from cv32e40x_align_check)
  logic           alcheck_resp_valid;
  data_resp_t     alcheck_resp;

  // Transaction response interface (from cv32e40x_mpu)
  logic           mpu_resp_valid;
  data_resp_t     mpu_resp;

  // Transaction request (from cv32e40x_mpu to cv32e40x_write_buffer)
  logic           buffer_trans_valid;
  logic           buffer_trans_ready;
  obi_data_req_t  buffer_trans;

  logic           filter_trans_valid;
  logic           filter_trans_ready;
  obi_data_req_t  filter_trans;
  logic           filter_resp_valid;
  obi_data_resp_t filter_resp;

  // Transaction request (from cv32e40x_write_buffer to cv32e40x_data_obi_interface)
  logic           bus_trans_valid;
  logic           bus_trans_ready;
  obi_data_req_t  bus_trans;

  // Transaction response (from cv32e40x_data_obi_interface to cv32e40x_mpu)
  logic           bus_resp_valid;
  obi_data_resp_t bus_resp;

  // Counter to count maximum number of outstanding transactions
  logic [1:0]     cnt_q;                // Transaction counter
  logic [1:0]     next_cnt;             // Next value for cnt_q
  logic           count_up;             // Increment outstanding transaction count by 1 (can happen at same time as count_down)
  logic           count_down;           // Decrement outstanding transaction count by 1 (can happen at same time as count_up)
  logic           cnt_is_one_next;

  logic           ctrl_update;          // Update load/store control info in WB stage

  // registers for data_rdata alignment and sign extension
  logic [1:0]     lsu_size_q;
  logic           lsu_sext_q;
  logic           lsu_we_q;
  logic [1:0]     rdata_offset_q;
  logic           last_q;               // Last transfer of load/store (only 0 for first part of split transfer)

  logic [3:0]     be;                   // Byte enables
  logic [31:0]    wdata;

  logic           split_q;              // Currently performing the second address phase of a split misaligned load/store
                                        // Note that in the presence of a write buffer, split_q will align with acceptance of the second
                                        // transfer by the write buffer. This may not align with the OBI address phase.
  logic           nonsplit_misaligned_halfword;  // Halfword is not naturally aligned, but no split is needed
  logic           misaligned_access;    // Access is not naturally aligned
  logic           modified_access;      // Access is modified, e.g. non-naturally aligned access needs two bus transactions

  logic           filter_resp_busy;     // Response filter busy

  logic [31:0]    rdata_q;

  logic           done_0;               // First stage (EX) is done

  logic           trans_valid_q;        // trans_valid got clocked without trans_ready

  logic                  xif_req;       // The ongoing memory request comes from the XIF interface
  logic                  xif_mpu_err;   // The ongoing memory request caused an MPU error
  logic [31:0]           xif_wpt_match; // The ongoing memory request caused a watchpoint trigger match
  logic                  xif_ready_1;   // The LSU second stage is ready for an XIF transaction
  logic                  xif_res_q;     // The next memory result is for the XIF interface
  logic [X_ID_WIDTH-1:0] xif_id_q;      // Instruction ID of an XIF memory transaction

  logic           align_check_en;        // Perform alignment checks for atomics

  logic           consumer_resp_wait;    // Signal to WPT, MPU and alignment checker if they must wait with
                                         // the response until there is one transaction left;

  assign xif_req = X_EXT && xif_mem_if.mem_valid;

  // Transaction (before aligner)
  // Generate address from operands (atomic memory transactions do not use an address offset computation)
  always_comb begin
    trans.addr  = id_ex_pipe_i.lsu_atop[5] ? id_ex_pipe_i.alu_operand_a : (id_ex_pipe_i.alu_operand_a + id_ex_pipe_i.alu_operand_b);
    trans.we    = id_ex_pipe_i.lsu_we;
    trans.size  = id_ex_pipe_i.lsu_size;
    trans.wdata = id_ex_pipe_i.operand_c;
    trans.mode  = priv_lvl_lsu_i;
    trans.dbg   = ctrl_fsm_i.debug_mode;

    trans.atop  = id_ex_pipe_i.lsu_atop;
    trans.sext  = id_ex_pipe_i.lsu_sext;
  end

  // Set outputs for trigger module
  assign lsu_addr_o = wpt_trans.addr;
  assign lsu_we_o   = wpt_trans.we;
  assign lsu_be_o = be;

  ///////////////////////////////// BE generation ////////////////////////////////
  always_comb
  begin
    case (trans.size) // Data type 00 byte, 01 halfword, 10 word
      2'b00: begin // Writing a byte
        case (trans.addr[1:0])
          2'b00: be = 4'b0001;
          2'b01: be = 4'b0010;
          2'b10: be = 4'b0100;
          2'b11: be = 4'b1000;
          default:;
        endcase; // case (trans.addr[1:0])
      end
      2'b01:
      begin // Writing a half word
        if (split_q == 1'b0)
        begin // non-misaligned case
          case (trans.addr[1:0])
            2'b00: be = 4'b0011;
            2'b01: be = 4'b0110;
            2'b10: be = 4'b1100;
            2'b11: be = 4'b1000;
            default:;
          endcase; // case (trans.addr[1:0])
        end
        else
        begin // misaligned case
          be = 4'b0001;
        end
      end
      default:
      begin // Writing a word (note: XIF memory requests always write a word)
        if (split_q == 1'b0)
        begin // non-misaligned case
          case (trans.addr[1:0])
            2'b00: be = 4'b1111;
            2'b01: be = 4'b1110;
            2'b10: be = 4'b1100;
            2'b11: be = 4'b1000;
            default:;
          endcase; // case (trans.addr[1:0])
        end
        else
        begin // misaligned case
          case (trans.addr[1:0])
            2'b00: be = 4'b0000; // this is not used, but included for completeness
            2'b01: be = 4'b0001;
            2'b10: be = 4'b0011;
            2'b11: be = 4'b0111;
            default:;
          endcase; // case (trans.addr[1:0])
        end
      end
    endcase; // case (trans.size)
  end

  // Prepare data to be written to the memory. We handle misaligned (split) accesses,
  // half word and byte accesses and register offsets here.

  always_comb
  begin
    case (trans.addr[1:0])
      2'b00: wdata = trans.wdata[31:0];
      2'b01: wdata = {trans.wdata[23:0], trans.wdata[31:24]};
      2'b10: wdata = {trans.wdata[15:0], trans.wdata[31:16]};
      2'b11: wdata = {trans.wdata[ 7:0], trans.wdata[31: 8]};
      default:;
    endcase; // case (trans.addr[1:0])
  end

  // FF for rdata alignment and sign-extension
  // Signals used in WB stage
  always_ff @(posedge clk, negedge rst_n)
  begin
    if (rst_n == 1'b0) begin
      lsu_size_q       <= 2'b0;
      lsu_sext_q       <= 1'b0;
      lsu_we_q         <= 1'b0;
      rdata_offset_q   <= 2'b0;
      last_q           <= 1'b0;
    end else if (ctrl_update) begin     // request was granted, we wait for rvalid and can continue to WB
      if (xif_req) begin
        // Note: lsu_size_q is set to max size to prevent the zero/sign extension logic from
        // overwriting data
        lsu_size_q     <= 2'b10;
        lsu_sext_q     <= 1'b0;
        lsu_we_q       <= xif_mem_if.mem_req.we;
        rdata_offset_q <= '0;
      end else begin
        lsu_size_q     <= trans.size;
        lsu_sext_q     <= trans.sext;
        lsu_we_q       <= trans.we;
        rdata_offset_q <= trans.addr[1:0];
      end
      // If we currently signal split from first stage (EX), WB stage will not see the last transfer for this update.
      // Otherwise we are on the last. For non-split accesses we always mark as last.
      last_q           <= lsu_split_0_o ? 1'b0 : 1'b1;
    end
  end

  // Tracking split (misaligned) state
  // This signals has EX timing, and indicates that the second
  // address phase of a split transfer is taking place
  // Reset/killed on !valid_0_i to ensure it is zero for the
  // first phase of the next instruction. Otherwise it could stick at 1 after a killed
  // split, causing next LSU instruction to calculate wrong _be.
  always_ff @(posedge clk, negedge rst_n) begin
    if (rst_n == 1'b0) begin
      split_q    <= 1'b0;
    end else begin
      if(!valid_0_i && !xif_req) begin
        split_q <= 1'b0; // Reset split_st when no valid instructions
      end else if (ctrl_update) begin // EX done, update split_q for next address phase
        split_q <= lsu_split_0_o;
      end
    end
  end

  generate
    if (X_EXT) begin : x_ext_regs
      always_ff @(posedge clk, negedge rst_n) begin
        if (rst_n == 1'b0) begin
          xif_res_q <= '0;
          xif_id_q  <= '0;
        end else if (ctrl_update) begin       // request was granted
          xif_res_q <= xif_req;               // expect an XIF result if we did an XIF request
          xif_id_q  <= xif_mem_if.mem_req.id; // save XIF instruction ID for result
        end
      end
    end else begin : no_x_ext_regs
      assign xif_res_q = 1'b0;
      assign xif_id_q  = '0;
    end
  endgenerate

  ////////////////////////////////////////////////////////////////////////
  //  ____  _               _____      _                 _              //
  // / ___|(_) __ _ _ __   | ____|_  _| |_ ___ _ __  ___(_) ___  _ __   //
  // \___ \| |/ _` | '_ \  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \  //
  //  ___) | | (_| | | | | | |___ >  <| ||  __/ | | \__ \ | (_) | | | | //
  // |____/|_|\__, |_| |_| |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_| //
  //          |___/                                                     //
  ////////////////////////////////////////////////////////////////////////

  logic [31:0] rdata_ext;
  logic [63:0] rdata_full;
  logic [63:0] rdata_aligned; // [63:32] unsused
  logic        rdata_is_split;

  // Check if rdata is split over two accesses
  assign rdata_is_split = ((lsu_size_q == 2'b10) && (rdata_offset_q != 2'b00)) || // Split word
                          ((lsu_size_q == 2'b01) && (rdata_offset_q == 2'b11));   // Split halfword

  // Assemble full rdata
  assign rdata_full  = rdata_is_split ? {resp_rdata, rdata_q} :   // Use lsb data from previous access if split
                                        {resp_rdata, resp_rdata}; // Set up data for shifting resp_data LSBs into MSBs of rdata_aligned

  // Realign rdata
  assign rdata_aligned = rdata_full >> (8*rdata_offset_q);

  // Sign-extend aligned rdata
  always_comb begin
    case (lsu_size_q)
      2'b00:   rdata_ext = {{24{lsu_sext_q && rdata_aligned[ 7]}},  rdata_aligned[ 7:0]}; // Byte
      2'b01:   rdata_ext = {{16{lsu_sext_q && rdata_aligned[ 15]}}, rdata_aligned[15:0]}; // Halfword
      default: rdata_ext =                                          rdata_aligned[31:0];  // Word
    endcase
  end



  always_ff @(posedge clk, negedge rst_n)
  begin
    if (rst_n == 1'b0) begin
      rdata_q <= '0;
    end else if (resp_valid && !lsu_we_q) begin
      // if we have detected a split access, and we are
      // currently doing the first part of this access, then
      // store the data coming from memory in rdata_q.
      // In all other cases, rdata_q gets the value that we are
      // writing to the register file
      if (split_q || lsu_split_0_o) begin
        rdata_q <= resp_rdata;
      end else begin
        rdata_q <= rdata_ext;
      end
    end
  end

  // Set rdata output and atomic type output depending on A_EXT
  generate
    if (A_EXT != A_NONE) begin : a_ext
      lsu_atomic_e lsu_atomic_q;

      always_ff @(posedge clk, negedge rst_n)
      begin
        if (rst_n == 1'b0) begin
          lsu_atomic_q     <= AT_NONE;
        end else if (ctrl_update) begin     // request was granted, we wait for rvalid and can continue to WB
          if (xif_req) begin
            lsu_atomic_q   <= AT_NONE;
          end else begin
            // Set type of atomic instruction in WB, if any.
            lsu_atomic_q   <= lsu_atomic_0_o;
            end
        end
      end

      assign lsu_atomic_0_o  = !trans.atop[5]            ? AT_NONE :
                               (trans.atop[4:0] == 5'h2) ? AT_LR   :
                               (trans.atop[4:0] == 5'h3) ? AT_SC   :
                                                           AT_AMO;
      assign lsu_atomic_1_o = lsu_atomic_q;

      // SC.W must write 0 to rd on success, and 1 on failure. All other instructions including AMO write the response data.
      assign lsu_rdata_1_o = (lsu_atomic_q == AT_SC) ? {{31{1'b0}}, !resp.bus_resp.exokay} : rdata_ext;

    end else begin : no_a_ext
      // A_EXT not enabled, tie off outputs.
      assign lsu_atomic_0_o = AT_NONE;
      assign lsu_atomic_1_o = AT_NONE;

      // output to register file
      // Always rdata_ext regardless of split accesses
      // Output will be valid (valid_1_o) only for the last phase of split access.
      assign lsu_rdata_1_o = rdata_ext;
    end
  endgenerate

  // Misaligned accesses occur for:
  //
  // - Both phases of a split misaligned access
  // - For a misaligned halfword that does not require a split
  // - When the XIF does a misaligned access
  assign misaligned_access = split_q || lsu_split_0_o || nonsplit_misaligned_halfword || (xif_req && xif_mem_if.mem_req.attr[1]);

  // Modified acccesses occur for:
  //
  // - Both phases of a split misaligned access
  // - When the XIF does a modified access
  assign modified_access = split_q || lsu_split_0_o || (xif_req && (xif_mem_if.mem_req.attr[0]));

  // Check for misaligned accesses that need a second memory access
  // If one is detected, this is signaled with lsu_split_0_o.
  // This is used to gate off ready_0_o to avoid instructions into
  // the EX stage while the LSU is handling the second phase of the split access.
  // Also detecting misaligned halfwords that don't need a second transfer.
  // Note: XIF memory requests are already aligned and do not need a second memory access.
  always_comb
  begin
    lsu_split_0_o = 1'b0;
    nonsplit_misaligned_halfword = 1'b0;
    if (valid_0_i && !xif_req && !split_q)
    begin
      case (trans.size)
        2'b10: // word
        begin
          if (trans.addr[1:0] != 2'b00)
            lsu_split_0_o = 1'b1;
        end
        2'b01: // half word
        begin
          if (trans.addr[1:0] == 2'b11)
            lsu_split_0_o = 1'b1;
          if (trans.addr[0] != 1'b0)
            nonsplit_misaligned_halfword = 1'b1;
        end
        default:;
      endcase // case (trans.size)
    end
  end

  // Set flags for first and last op
  // Only valid when id_ex_pipe.lsu_en == 1
  assign lsu_last_op_0_o  = !lsu_split_0_o;
  assign lsu_first_op_0_o = !split_q;

  // Busy if there are ongoing (or potentially outstanding) transfers
  // In the case of mpu errors, the LSU control logic can have outstanding transfers not seen by the response filter.
  assign busy_o = filter_resp_busy || (cnt_q > 0) || trans_valid;

  //////////////////////////////////////////////////////////////////////////////
  // Transaction request generation
  //
  // Assumes that corresponding response is at least 1 cycle after request
  //
  // - Only request transaction when EX stage requires data transfer and
  // - maximum number of outstanding transactions will not be exceeded (cnt_q < DEPTH)
  //////////////////////////////////////////////////////////////////////////////

  always_comb begin
    if (xif_req) begin
      wpt_trans.addr    = xif_mem_if.mem_req.addr;
      wpt_trans.we      = xif_mem_if.mem_req.we;
      wpt_trans.be      = xif_mem_if.mem_req.be;
      wpt_trans.wdata   = xif_mem_if.mem_req.wdata;
      wpt_trans.atop    = '0;
      wpt_trans.prot    = {xif_mem_if.mem_req.mode, 1'b1}; // XIF transfers are data transfers
      wpt_trans.dbg     = '0;                              // TODO:XIF setup debug triggers
      wpt_trans.memtype = 2'b00;                           // Memory type is assigned in MPU
    end else begin
      // For last phase of misaligned/split transfer the address needs to be word aligned (as LSB of be will be set)
      wpt_trans.addr    = trans.atop[5] ? trans.addr : (split_q ? {trans.addr[31:2], 2'b00} + 'h4 : trans.addr);
      wpt_trans.we      = trans.we;
      wpt_trans.be      = be;
      wpt_trans.wdata   = wdata;
      wpt_trans.atop    = trans.atop;
      wpt_trans.prot    = {trans.mode, 1'b1};      // Transfers from LSU are data transfers
      wpt_trans.dbg     = trans.dbg;
      wpt_trans.memtype = 2'b00;                   // Memory type is assigned in MPU
    end
  end

  // Set handshake signals for wpt_trans (same as for trans, but kept separate for clean naming)
  assign wpt_trans_valid = trans_valid;
  assign trans_ready     = wpt_trans_ready;

  // Indicate if transaction is part of a PUSH/POP sequence
  assign wpt_trans_pushpop = id_ex_pipe_i.instr_meta.pushpop;

  // Transaction request generation
  // OBI compatible (avoids combinatorial path from data_rvalid_i to data_req_o). Multiple trans_* transactions can be
  // issued (and accepted) before a response (resp_*) is received.
  assign trans_valid = (valid_0_i || xif_req) && (cnt_q < DEPTH);

  // LSU second stage is ready if it is not being used (i.e. no outstanding transfers, cnt_q = 0),
  // or if it is being used and the awaited response arrives (resp_rvalid).
  // XIF transactions bypass the pipeline, hence ready_1_i is not required for the second stage to
  // be ready for XIF transactions.
  assign ready_1_o   = ((cnt_q == 2'b00) ? 1'b1 : resp_valid) && ready_1_i;
  assign xif_ready_1 = ((cnt_q == 2'b00) ? 1'b1 : resp_valid);

  // LSU second stage is valid when resp_valid (typically data_rvalid_i) is received. Both parts of a misaligned transfer will signal valid_1_o.
  assign valid_1_o                          = resp_valid && valid_1_i && !xif_res_q;
  assign xif_mem_result_if.mem_result_valid = last_q && resp_valid && xif_res_q; // todo:XIF last_q or not?

  // LSU EX stage readyness requires two criteria to be met:
  //
  // - A data request has been forwarded/accepted (trans_valid && trans_ready)
  // - The LSU WB stage is available such that EX and WB can be updated in lock step
  //
  // Default (if there is not even a data request) LSU EX is signaled to be ready, else
  // if there are no outstanding transactions the EX stage is ready again once the transaction
  // request is accepted (at which time this load/store will move to the WB stage), else
  // in case there is already at least one outstanding transaction (so WB is full) the EX
  // and WB stage can only signal readiness in lock step.

  // Internal signal used in ctrl_update.
  // Indicates that address phase in EX is complete.
  // XIF request bypasses pipeline, ignores ready_0_i but requires xif_ready_1 instead.
  assign done_0    = (
                      !(valid_0_i || xif_req) ? 1'b1 :
                      (cnt_q == 2'b00)        ? (trans_valid && trans_ready) :
                      (cnt_q == 2'b01)        ? (trans_valid && trans_ready) :
                      1'b1
                     ) && (ready_0_i || (xif_req && xif_ready_1));

  // XIF request bypasses pipeline (does not assert valid_0_o) and takes precedence over regular
  // requests, hence inhibits a concurrent request from EX stage
  assign valid_0_o =  (
                       (cnt_q == 2'b00) ? (trans_valid && trans_ready) :
                       (cnt_q == 2'b01) ? (trans_valid && trans_ready) :
                       1'b1
                      ) && valid_0_i && !xif_req;


  // External (EX) ready only when not handling multi cycle split accesses
  // otherwise we may let a new instruction into EX, overwriting second phase of split access..
  // XIF transactions take precedence, thus the LSU is not ready for EX in case of an XIF request.
  assign ready_0_o = done_0 && !lsu_split_0_o && !xif_req;

  generate
    if (X_EXT) begin : x_ext_mem_ready
      assign xif_mem_if.mem_ready = done_0 && !lsu_split_0_o;
    end else begin : no_x_ext_mem_ready
      assign xif_mem_if.mem_ready = 1'b0;
    end
  endgenerate

  // Export mpu status and align check status to WB stage/controller
  assign lsu_mpu_status_1_o   = resp.mpu_status;
  assign lsu_align_status_1_o = resp.align_status;

  // Update signals for EX/WB registers (when EX has valid data itself and is ready for next)
  assign ctrl_update = done_0 && (valid_0_i || xif_req);


  //////////////////////////////////////////////////////////////////////////////
  // Counter (cnt_q, next_cnt) to count number of outstanding OBI transactions
  // (maximum = DEPTH)
  //
  // Counter overflow is prevented by limiting the number of outstanding transactions
  // to DEPTH. Counter underflow is prevented by the assumption that resp_valid = 1
  // will only occur in response to accepted transfer request (as per the OBI protocol).
  //////////////////////////////////////////////////////////////////////////////

  assign count_up = trans_valid && trans_ready;         // Increment upon accepted transfer request
  assign count_down = resp_valid;                       // Decrement upon accepted transfer response

  always_comb begin
    case ({count_up, count_down})
      2'b00 : begin
        next_cnt = cnt_q;
      end
      2'b01 : begin
        next_cnt = cnt_q - 1'b1;
      end
      2'b10 : begin
        next_cnt = cnt_q + 1'b1;
      end
      2'b11 : begin
        next_cnt = cnt_q;
      end
      default:;
    endcase
  end

  // Indicate that counter will be one in the next cycle
  assign cnt_is_one_next = next_cnt == 2'h1;

  //////////////////////////////////////////////////////////////////////////////
  // Counter (cnt_q) to count number of outstanding OBI transactions
  //////////////////////////////////////////////////////////////////////////////

  always_ff @(posedge clk, negedge rst_n)
  begin
    if (rst_n == 1'b0) begin
      cnt_q <= '0;
    end else begin
      cnt_q <= next_cnt;
    end
  end

  //////////////////////////////////////////////////////////////////////////////
  // Check if LSU is interruptible
  //////////////////////////////////////////////////////////////////////////////
  // OBI protocol should not be violated. For non-buffered writes, the trans_
  // signals are fed directly through to the OBI interface. Buffered writes that have
  // been accepted by the write buffer will complete regardless of interrupts,
  // debug and killing of stages.
  //
  // A trans_valid that has been high for at least one clock cycle is not
  // allowed to retract.
  //
  // LSU instructions shall not be interrupted/killed if the address phase is
  // already done, the instruction must finish with resp_valid=1 in WB
  // stage (cnt_q > 0 until resp_valid becomes 1)
  //
  // For misaligned split instructions, we may interrupt during the first
  // cycle of the first half. If the first half stays in EX for more than one
  // cycle, we cannot interrupt it (trans_valid_q == 1). When the first half
  // goes to WB, cnt_q != 0 will block interrupts. If the first half finishes
  // in WB before the second half gets grant, trans_valid_q will again be
  // 1 and block interrupts, and cnt_q will block the last half while it is in
  // WB.

  always_ff @(posedge clk, negedge rst_n)
  begin
    if (rst_n == 1'b0) begin
      trans_valid_q <= 1'b0;
    end else begin
      if (trans_valid && !ctrl_update) begin
        trans_valid_q <= 1'b1;
      end else if (ctrl_update) begin
        trans_valid_q <= 1'b0;
      end
    end
  end

  assign interruptible_o = !trans_valid_q && (cnt_q == '0);


  //////////////////////////////////////////////////////////////////////////////
  // Handle bus errors
  //////////////////////////////////////////////////////////////////////////////

  // Validate bus_error on rvalid from the bus (WB stage)
  // For bufferable transfers, this can happen many cycles after the pipeline control logic has seen the filtered resp_valid
  assign lsu_err_1_o.bus_err = xif_res_q ? 1'b0 : resp.bus_resp.err[0];
  assign lsu_err_1_o.store   = xif_res_q ? 1'b0 : resp.bus_resp.err[1];

  //////////////////////////////////////////////////////////////////////////////
  // WPT
  //////////////////////////////////////////////////////////////////////////////
  assign consumer_resp_wait = !xif_req;

  // Watchpint trigger "gate". If a watchpoint trigger is detected, this module will
  // consume the transaction, not letting it through to the MPU. The triger match will
  // be returned with the response with WB timing.
  generate
    if (DBG_NUM_TRIGGERS > 0) begin : gen_wpt
      cv32e40x_wpt wpt_i
        (
        .clk                 ( clk               ),
        .rst_n               ( rst_n             ),

        // Input from debug_triggers module
        .trigger_match_i     ( trigger_match_0_i ),

        // Interface towards MPU
        .mpu_trans_ready_i   ( mpu_trans_ready   ),
        .mpu_trans_valid_o   ( mpu_trans_valid   ),
        .mpu_trans_pushpop_o ( mpu_trans_pushpop ),
        .mpu_trans_o         ( mpu_trans         ),

        .mpu_resp_valid_i    ( mpu_resp_valid    ),
        .mpu_resp_i          ( mpu_resp          ),

        // Interface towards core
        .core_trans_valid_i  ( wpt_trans_valid   ),
        .core_trans_ready_o  ( wpt_trans_ready   ),
        .core_trans_pushpop_i( wpt_trans_pushpop ),
        .core_trans_i        ( wpt_trans         ),

        .core_resp_valid_o   ( wpt_resp_valid    ),
        .core_resp_o         ( wpt_resp          ),

        // Indication from the core that there will be one pending transaction in the next cycle
        .core_one_txn_pend_n ( cnt_is_one_next   ),

        // Indication from the core that watchpoint triggers should be reported after all in flight transactions
        // are complete (default behavior for main core requests, but not used for XIF requests)
        .core_wpt_wait_i     ( consumer_resp_wait),

        // Report watchpoint triggers to the core immediatly (used in case core_wpt_wait_i is not asserted)
        .core_wpt_match_o    ( xif_wpt_match     )
        );

      // Extract rdata from response struct
      assign wpt_resp_rdata = wpt_resp.bus_resp.rdata;

      assign resp_valid = wpt_resp_valid;
      assign resp_rdata = wpt_resp_rdata;
      assign resp       = wpt_resp;

      assign lsu_wpt_match_1_o = resp.wpt_match;

    end else begin : gen_no_wpt
      // Bypass WPT in case DBG_NUM_TRIGGERS is zero
      assign lsu_wpt_match_1_o = resp.wpt_match;
      assign mpu_trans_valid   = wpt_trans_valid;
      assign mpu_trans         = wpt_trans;
      assign mpu_trans_pushpop = wpt_trans_pushpop;
      assign wpt_trans_ready   = mpu_trans_ready;
      assign wpt_resp_valid    = mpu_resp_valid;
      assign wpt_resp          = mpu_resp;
      assign xif_wpt_match     = 1'b0;

      assign wpt_resp_rdata = wpt_resp.bus_resp.rdata;

      assign resp_valid = wpt_resp_valid;
      assign resp_rdata = wpt_resp_rdata;
      assign resp       = wpt_resp;
    end
  endgenerate


  //////////////////////////////////////////////////////////////////////////////
  // MPU
  //////////////////////////////////////////////////////////////////////////////
  assign mpu_trans_atomic = mpu_trans.atop[5];

  cv32e40x_mpu
  #(
    .IF_STAGE           ( 0                    ),
    .A_EXT              ( A_EXT                ),
    .CORE_RESP_TYPE     ( data_resp_t          ),
    .BUS_RESP_TYPE      ( data_resp_t          ),
    .CORE_REQ_TYPE      ( obi_data_req_t       ),
    .PMA_NUM_REGIONS    ( PMA_NUM_REGIONS      ),
    .PMA_CFG            ( PMA_CFG              ),
    .DEBUG              ( DEBUG                ),
    .DM_REGION_START    ( DM_REGION_START      ),
    .DM_REGION_END      ( DM_REGION_END        )
  )
  mpu_i
  (
    .clk                  ( clk                ),
    .rst_n                ( rst_n              ),
    .atomic_access_i      ( mpu_trans_atomic   ),
    .misaligned_access_i  ( misaligned_access  ),
    .modified_access_i    ( modified_access    ),

    .core_one_txn_pend_n  ( cnt_is_one_next    ),
    .core_mpu_err_wait_i  ( consumer_resp_wait ),
    .core_mpu_err_o       ( xif_mpu_err        ),
    .core_trans_valid_i   ( mpu_trans_valid    ),
    .core_trans_pushpop_i ( mpu_trans_pushpop  ),
    .core_trans_ready_o   ( mpu_trans_ready    ),
    .core_trans_i         ( mpu_trans          ),
    .core_resp_valid_o    ( mpu_resp_valid     ),
    .core_resp_o          ( mpu_resp           ),

    .bus_trans_valid_o    ( alcheck_trans_valid ),
    .bus_trans_ready_i    ( alcheck_trans_ready ),
    .bus_trans_o          ( alcheck_trans       ),
    .bus_resp_valid_i     ( alcheck_resp_valid  ),
    .bus_resp_i           ( alcheck_resp        )

  );

  //////////////////////////////////////////////////////////////////////////////
  // Alignment checker for atomics
  //////////////////////////////////////////////////////////////////////////////
  assign align_check_en = alcheck_trans.atop[5];

  cv32e40x_align_check
  #(
    .IF_STAGE             ( 0                    ),
    .CORE_RESP_TYPE       ( data_resp_t          ),
    .BUS_RESP_TYPE        ( obi_data_resp_t      ),
    .CORE_REQ_TYPE        ( obi_data_req_t       )

  )
  align_check_i
  (
    .clk                  ( clk                   ),
    .rst_n                ( rst_n                 ),
    .align_check_en_i     ( align_check_en        ),
    .misaligned_access_i  ( misaligned_access     ),

    .core_one_txn_pend_n  ( cnt_is_one_next       ),
    .core_align_err_wait_i( consumer_resp_wait    ),
    .core_align_err_o     (                       ), // todo:XIF Unconnected on purpose, is this needed for xif?

    .core_trans_valid_i   ( alcheck_trans_valid   ),
    .core_trans_ready_o   ( alcheck_trans_ready   ),
    .core_trans_i         ( alcheck_trans         ),
    .core_resp_valid_o    ( alcheck_resp_valid    ),
    .core_resp_o          ( alcheck_resp          ),

    .bus_trans_valid_o    ( filter_trans_valid    ),
    .bus_trans_ready_i    ( filter_trans_ready    ),
    .bus_trans_o          ( filter_trans          ),
    .bus_resp_valid_i     ( filter_resp_valid     ),
    .bus_resp_i           ( filter_resp           )

  );


  //////////////////////////////////////////////////////////////////////////////
  // Response Filter
  //////////////////////////////////////////////////////////////////////////////

  cv32e40x_lsu_response_filter
    response_filter_i
      (.clk          ( clk                ),
       .rst_n        ( rst_n              ),
       .busy_o       ( filter_resp_busy   ),
       .bus_busy_o   ( bus_busy_o         ),

       .valid_i      ( filter_trans_valid ),
       .ready_o      ( filter_trans_ready ),
       .trans_i      ( filter_trans       ),
       .resp_valid_o ( filter_resp_valid  ),
       .resp_o       ( filter_resp        ),

       .valid_o      ( buffer_trans_valid ),
       .ready_i      ( buffer_trans_ready ),
       .trans_o      ( buffer_trans       ),
       .resp_valid_i ( bus_resp_valid     ),
       .resp_i       ( bus_resp           )

     );


  //////////////////////////////////////////////////////////////////////////////
  // Write Buffer
  //////////////////////////////////////////////////////////////////////////////

  cv32e40x_write_buffer
  #(
    .PMA_NUM_REGIONS    ( PMA_NUM_REGIONS    ),
    .PMA_CFG            ( PMA_CFG            )
  )
  write_buffer_i
  (
    .clk                ( clk                ),
    .rst_n              ( rst_n              ),

    .valid_i            ( buffer_trans_valid ),
    .ready_o            ( buffer_trans_ready ),
    .trans_i            ( buffer_trans       ),

    .valid_o            ( bus_trans_valid    ),
    .ready_i            ( bus_trans_ready    ),
    .trans_o            ( bus_trans          )
  );

  //////////////////////////////////////////////////////////////////////////////
  // OBI interface
  //////////////////////////////////////////////////////////////////////////////

  cv32e40x_data_obi_interface
  data_obi_i
  (
    .clk                ( clk             ),
    .rst_n              ( rst_n           ),

    .trans_valid_i      ( bus_trans_valid ),
    .trans_ready_o      ( bus_trans_ready ),
    .trans_i            ( bus_trans       ),

    .resp_valid_o       ( bus_resp_valid  ),
    .resp_o             ( bus_resp        ),

    .m_c_obi_data_if    ( m_c_obi_data_if )
  );

  //////////////////////////////////////////////////////////////////////////////
  // XIF interface response and result data
  //////////////////////////////////////////////////////////////////////////////

  generate
    if (X_EXT) begin : x_ext
      // XIF memory response: convert MPU errors to exception codes
      assign xif_mem_if.mem_resp.exc     = xif_mpu_err;
      assign xif_mem_if.mem_resp.exccode = xif_mpu_err ? (
                                            trans.we ? EXC_CAUSE_STORE_FAULT : EXC_CAUSE_LOAD_FAULT
                                           ) : '0;
      assign xif_mem_if.mem_resp.dbg     = |xif_wpt_match;

      // XIF memory result
      assign xif_mem_result_if.mem_result.id    = xif_id_q;
      assign xif_mem_result_if.mem_result.rdata = rdata_ext;
      assign xif_mem_result_if.mem_result.err   = resp.bus_resp.err[0]; // forward bus errors to coprocessor
      assign xif_mem_result_if.mem_result.dbg   = '0;            // TODO:XIF forward debug triggers
    end else begin : no_x_ext
      assign xif_mem_if.mem_resp.exc            = '0;
      assign xif_mem_if.mem_resp.exccode        = '0;
      assign xif_mem_if.mem_resp.dbg            = '0;
      assign xif_mem_result_if.mem_result.id    = '0;
      assign xif_mem_result_if.mem_result.rdata = '0;
      assign xif_mem_result_if.mem_result.err   = '0;
      assign xif_mem_result_if.mem_result.dbg   = '0;

      logic unused_xif_signals;
      assign unused_xif_signals = (|xif_id_q) | (|xif_wpt_match) | xif_mpu_err;
    end
  endgenerate

endmodule






// Description:    Write back stage: Hosts write back from load/store unit    //
//                 and combined write back from ALU/MULT/DIV/CSR.             //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_wb_stage import cv32e40x_pkg::*;
#(
    parameter bit DEBUG = 1
)
(
  input  logic          clk,            // Not used in RTL; only used by assertions
  input  logic          rst_n,          // Not used in RTL; only used by assertions

  // EX/WB pipeline
  input  ex_wb_pipe_t   ex_wb_pipe_i,

  // Controller
  input  ctrl_fsm_t     ctrl_fsm_i,

  // LSU
  input  logic [31:0]   lsu_rdata_i,
  input  mpu_status_e   lsu_mpu_status_i,
  input  logic [31:0]   lsu_wpt_match_i,
  input  align_status_e lsu_align_status_i,

  // Register file interface
  output logic          rf_we_wb_o,     // Register file write enable
  output rf_addr_t      rf_waddr_wb_o,  // Register file write address
  output logic [31:0]   rf_wdata_wb_o,  // Register file write data

  // LSU handshake interface
  input  logic          lsu_valid_i,
  output logic          lsu_ready_o,
  output logic          lsu_valid_o,
  input  logic          lsu_ready_i,

  // WB stalled by LSU
  output logic          data_stall_o,

  // Stage ready/valid
  output logic          wb_ready_o,
  output logic          wb_valid_o,

  // eXtension interface
  cv32e40x_if_xif.cpu_result xif_result_if,

  // Sticky WB outputs
  output logic [31:0]   wpt_match_wb_o,
  output mpu_status_e   mpu_status_wb_o,
  output align_status_e align_status_wb_o,

  // From cs_registers
  input logic [31:0]    clic_pa_i,
  input logic           clic_pa_valid_i,

  output logic          last_op_o,
  output logic          abort_op_o
);

  logic                 instr_valid;
  logic                 wb_valid;
  logic                 lsu_exception;

  // eXtension interface signals
  logic                 xif_waiting;
  logic                 xif_exception;

  // Flops for making volatile LSU outputs sticky until wb_valid
  mpu_status_e          lsu_mpu_status_q;
  logic [31:0]          lsu_wpt_match_q;
  align_status_e        lsu_align_status_q;
  logic                 lsu_valid_q;

  mpu_status_e          lsu_mpu_status;
  logic [31:0]          lsu_wpt_match;
  align_status_e        lsu_align_status;
  logic                 lsu_valid;
  // WB stage has two halt sources, ctrl_fsm_i.halt_wb and ctrl_fsm_i.halt_limited_wb. The limited halt is only set during
  // the SLEEP state, and is used to prevent timing paths from interrupt inputs to obi outputs when waking up from SLEEP.
  assign instr_valid = ex_wb_pipe_i.instr_valid && !ctrl_fsm_i.kill_wb && !ctrl_fsm_i.halt_wb && !ctrl_fsm_i.halt_limited_wb;

  assign lsu_exception = (lsu_mpu_status != MPU_OK) || (lsu_align_status != ALIGN_OK);


  //////////////////////////////////////////////////////////////////////////////
  // Register file interface
  //
  // Note that write back is not suppressed during bus errors (in order to prevent
  // a timing path from the late arriving data_err_i into the register file).
  //
  // Note that the register file is only written for the last part of a split misaligned load.
  // (rf_we suppressed in ex_stage for the first part, lsu aggregates data for second part)
  //
  // Note that the register file is written multiple times in case waited loads (in
  // order to prevent a timing path from the late arriving data_rvalid_i into the
  // register file.
  //
  // In case of MPU/PMA error, the register file should not be written.
  // rf_we_wb_o is deasserted if lsu_mpu_status is not equal to MPU_OK

  // TODO:XIF Could use result interface.we into account if out of order completion is allowed.
  assign rf_we_wb_o     = ex_wb_pipe_i.rf_we && !lsu_exception && !xif_waiting && !xif_exception && !(|lsu_wpt_match) && instr_valid;
  // TODO:XIF Could use result interface.rd into account if out of order completion is allowed.
  assign rf_waddr_wb_o  = ex_wb_pipe_i.rf_waddr;
  // TODO:XIF Could use result interface.rd into account if out of order completion is allowed.
  // Not using any flopped/sticky version of lsu_rdata_i. The sticky bits are only needed for MPU errors and watchpoint triggers.
  // Any true load that succeeds will write the RF and will never be halted or killed by the controller. (wb_valid during the same cycle as lsu_valid_i).
  assign rf_wdata_wb_o  = ex_wb_pipe_i.lsu_en ? lsu_rdata_i               :
                         (ex_wb_pipe_i.xif_en ? xif_result_if.result.data :
                         clic_pa_valid_i      ? clic_pa_i                 :
                         ex_wb_pipe_i.rf_wdata);

  //////////////////////////////////////////////////////////////////////////////
  // LSU inputs are valid when LSU is enabled; LSU outputs need to remain valid until downstream stage is ready

  // Does not depend on local instr_valid (i.e. kept high for stalls and kills)
  // Ok, as controller will never kill ongoing LSU instructions, and thus
  // the lsu valid_1_o which lsu_valid_o factors into should not be affected.
  assign lsu_valid_o = ex_wb_pipe_i.lsu_en && ex_wb_pipe_i.instr_valid;
  assign lsu_ready_o = 1'b1; // Always ready (there is no downstream stage)

  //////////////////////////////////////////////////////////////////////////////
  // Stage ready/valid

  // Using both ctrl_fsm_i.halt_wb and ctrl_fsm_i.halt_limited_wb to halt.
  assign wb_ready_o = ctrl_fsm_i.kill_wb || (lsu_ready_i && !xif_waiting && !ctrl_fsm_i.halt_wb && !ctrl_fsm_i.halt_limited_wb);

  // wb_valid
  //
  // - Will be 0 for interrupted instruction and debug entry
  // - Will be 1 for synchronous exceptions (which is easier to deal with for RVFI); this implies that wb_valid
  //   cannot be used to increment the minstret CSR (as that should not increment for e.g. ecall, ebreak, etc.)
  // - Will be 1 for both phases of a split misaligned load/store that completes without MPU errors.
  //   If an MPU error occurs, wb_valid will be 1 due to lsu_exception (for any phase where the error occurs)
  // - Will be 1 for CLIC pointer fetches. RVFI will only set rvfi_valid for CLIC pointers that caused an exception.
  assign wb_valid = ((!ex_wb_pipe_i.lsu_en && !xif_waiting) ||    // Non-LSU instructions have valid result in WB, also for exceptions, unless we are waiting for a coprocessor
                     ( ex_wb_pipe_i.lsu_en && lsu_valid   )       // LSU instructions have valid result based on data_rvalid_i or the flopped version in case of watchpoint triggers.
                                                                  // WFI/WFE are halted in WB until the core wakes up, this pulls instr_valid low and ensures wb_valid==0 until we
                                                                  // actually retire the WFI/WFE.
                    ) && instr_valid;

  // Letting all suboperations signal wb_valid
  assign wb_valid_o = wb_valid;

  // Signal that WB stage contains the last operation of an instruction
  assign last_op_o = ex_wb_pipe_i.last_op;

  // Append any MPU exception to abort_op
  // An abort_op_o = 1 will terminate a sequence, either to take an exception or debug due to trigger match.
  assign abort_op_o = ex_wb_pipe_i.abort_op || ( ex_wb_pipe_i.lsu_en && lsu_exception) || (ex_wb_pipe_i.lsu_en && |lsu_wpt_match);

  // Export signal indicating WB stage stalled by load/store
  assign data_stall_o = ex_wb_pipe_i.lsu_en && !lsu_valid && instr_valid;

  // Flops for sticky LSU signals
  always_ff @(posedge clk, negedge rst_n) begin
    if (rst_n == 1'b0) begin
      lsu_valid_q <= 1'b0;
      lsu_wpt_match_q <= '0;
      lsu_mpu_status_q <= MPU_OK;
      lsu_align_status_q <= ALIGN_OK;
    end else begin
      if (wb_valid || ctrl_fsm_i.kill_wb) begin
        // Clear sticky LSU bits when WB is done
        lsu_valid_q <= 1'b0;
        lsu_wpt_match_q <= '0;
        lsu_mpu_status_q <= MPU_OK;
        lsu_align_status_q <= ALIGN_OK;
      end else begin
        if (lsu_valid_i) begin
          lsu_valid_q <= 1'b1;
          lsu_wpt_match_q <= lsu_wpt_match;
          lsu_mpu_status_q <= lsu_mpu_status;
          lsu_align_status_q <= lsu_align_status;
        end
      end
    end
  end

  assign lsu_valid        = lsu_valid_q ? lsu_valid_q        : lsu_valid_i;
  assign lsu_wpt_match    = lsu_valid_q ? lsu_wpt_match_q    : lsu_wpt_match_i;
  assign lsu_mpu_status   = lsu_valid_q ? lsu_mpu_status_q   : lsu_mpu_status_i;
  assign lsu_align_status = lsu_valid_q ? lsu_align_status_q : lsu_align_status_i;

  assign wpt_match_wb_o = lsu_wpt_match;
  assign mpu_status_wb_o = lsu_mpu_status;
  assign align_status_wb_o = lsu_align_status;
  //---------------------------------------------------------------------------
  // eXtension interface
  //---------------------------------------------------------------------------

  // TODO:XIF How to handle conflicting values of ex_wb_pipe_i.rf_waddr and xif_result_if.result.rd?
  // TODO:XIF How to handle conflicting values of ex_wb_pipe_i.rf_we (based on xif_issue_if.issue_resp.writeback in ID) and xif_result_if.result.we?
  // TODO:XIF Check whether result IDs match the instruction IDs propagated along the pipeline
  // TODO:XIF Implement writeback to extension context status into mstatus (ecswe, ecsdata)

  // Need to wait for the result
  assign xif_waiting = ex_wb_pipe_i.instr_valid && ex_wb_pipe_i.xif_en && !xif_result_if.result_valid;

  // Coprocessor signals a synchronous exception
  // TODO:XIF Maybe do something when an exception occurs (other than just inhibiting writeback)
  assign xif_exception = ex_wb_pipe_i.instr_valid && ex_wb_pipe_i.xif_en && xif_result_if.result_valid && xif_result_if.result.exc;

  // todo:XIF Handle xif_result_if.result.err as NMI (do not factor into xif_exception as that signal is for synchronous exceptions)

  assign xif_result_if.result_ready = ex_wb_pipe_i.instr_valid && ex_wb_pipe_i.xif_en;

endmodule






































/**
 * Control / status register primitive
 */


module cv32e40x_csr #(
    parameter int unsigned    WIDTH      = 32,
    parameter bit [WIDTH-1:0] RESETVALUE = '0,
    parameter bit [WIDTH-1:0] MASK       = '1
 ) (
    input  logic             clk,
    input  logic             rst_n,

    input  logic [WIDTH-1:0] wr_data_i,
    input  logic             wr_en_i,
    output logic [WIDTH-1:0] rd_data_o
);

  logic [WIDTH-1:0] rdata_q;

  generate
    for (genvar i = 0; i < WIDTH; i++) begin : gen_csr
      if (MASK[i]) begin : gen_unmasked
        // Bits with mask set are actual flipflops
        always_ff @(posedge clk or negedge rst_n) begin
          if (!rst_n) begin
            rdata_q[i] <= RESETVALUE[i];
          end else if (wr_en_i) begin
            rdata_q[i] <= wr_data_i[i];
          end
        end
      end else begin : gen_masked
        // Bits with mask cleared are tied off to the reset value
        assign rdata_q[i] = RESETVALUE[i];
      end
    end // for
  endgenerate

  assign rd_data_o = rdata_q;



endmodule







// Description:    Module containing 0-4 triggers for debug                   //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_debug_triggers
import cv32e40x_pkg::*;
#(
  parameter int     DBG_NUM_TRIGGERS = 1,
  parameter a_ext_e A_EXT = A_NONE
)
(
  input  logic       clk,
  input  logic       rst_n,

  // CSR inputs write inputs
  input  logic [31:0] csr_wdata_i,
  input  logic        tselect_we_i,
  input  logic        tdata1_we_i,
  input  logic        tdata2_we_i,
  input  logic        tinfo_we_i,

  // CSR read data outputs
  output logic [31:0] tselect_rdata_o,
  output logic [31:0] tdata1_rdata_o,
  output logic [31:0] tdata2_rdata_o,
  output logic [31:0] tinfo_rdata_o,

  // IF stage inputs
  input  logic [31:0] pc_if_i,
  input  logic        ptr_in_if_i,
  input  privlvl_t    priv_lvl_if_i,

  // EX stage / LSU inputs
  input  logic        lsu_valid_ex_i,
  input  logic [31:0] lsu_addr_ex_i,
  input  logic        lsu_we_ex_i,
  input  logic [3:0]  lsu_be_ex_i,
  input  privlvl_t    priv_lvl_ex_i,
  input  lsu_atomic_e lsu_atomic_ex_i,

  // WB stage inputs
  input  privlvl_t    priv_lvl_wb_i,

  // Controller inputs
  input ctrl_fsm_t    ctrl_fsm_i,

  // Trigger match outputs
  output logic [31:0] trigger_match_if_o,  // Instruction address match
  output logic [31:0] trigger_match_ex_o,  // Load/Store address match
  output logic        etrigger_wb_o        // Exception trigger match
);

  // Set mask for supported exception codes for exception triggers
  localparam logic [31:0] ETRIGGER_TDATA2_MASK = (1 << EXC_CAUSE_INSTR_BUS_FAULT) | (1 << EXC_CAUSE_ECALL_MMODE) | (1 << EXC_CAUSE_STORE_FAULT) |
                                                   (1 << EXC_CAUSE_LOAD_FAULT) | (1 << EXC_CAUSE_BREAKPOINT) | (1 << EXC_CAUSE_ILLEGAL_INSN) | (1 << EXC_CAUSE_INSTR_FAULT);


  // CSR write data
  logic [31:0] tselect_n;
  logic [31:0] tdata2_n;
  logic [31:0] tinfo_n;

  // RVFI only signals
  logic [31:0] tdata1_n_r;
  logic [31:0] tdata2_n_r;
  logic        tdata1_we_r;
  logic        tdata2_we_r;


  // Signal for or'ing unused signals for easier lint
  logic unused_signals;



  generate
    if (DBG_NUM_TRIGGERS > 0) begin : gen_triggers
      // Internal CSR write enables
      logic [DBG_NUM_TRIGGERS-1 : 0] tdata1_we_int;
      logic [DBG_NUM_TRIGGERS-1 : 0] tdata1_we_hit;
      logic [DBG_NUM_TRIGGERS-1 : 0] tdata2_we_int;

      // Next-values for tdata1
      logic [31:0] tdata1_n[DBG_NUM_TRIGGERS];

      // CSR instance outputs
      logic [31:0] tdata1_q[DBG_NUM_TRIGGERS];
      logic [31:0] tdata2_q[DBG_NUM_TRIGGERS];
      logic [31:0] tselect_q;

      // CSR read data, possibly WARL resolved
      logic [31:0] tdata1_rdata[DBG_NUM_TRIGGERS];
      logic [31:0] tdata2_rdata[DBG_NUM_TRIGGERS];

      // IF, EX and WB stages trigger match
      logic [DBG_NUM_TRIGGERS-1 : 0] trigger_match_if;
      logic [DBG_NUM_TRIGGERS-1 : 0] trigger_match_ex;
      logic [DBG_NUM_TRIGGERS-1 : 0] etrigger_wb;

      // Instruction address match
      logic [DBG_NUM_TRIGGERS-1 : 0] if_addr_match;

      // LSU address match signals
      logic [DBG_NUM_TRIGGERS-1 : 0] lsu_addr_match_en;
      logic [DBG_NUM_TRIGGERS-1 : 0] lsu_addr_match;
      logic [3:0]                    lsu_byte_addr_match[DBG_NUM_TRIGGERS];

      // Enable matching based on privilege level per trigger
      logic [DBG_NUM_TRIGGERS-1 : 0] priv_lvl_match_en_if;
      logic [DBG_NUM_TRIGGERS-1 : 0] priv_lvl_match_en_ex;
      logic [DBG_NUM_TRIGGERS-1 : 0] priv_lvl_match_en_wb;

      logic [1:0]  lsu_addr_low_lsb;  // Lower two bits of the lowest accessed address
      logic [1:0]  lsu_addr_high_lsb; // Lower two bits of the highest accessed address
      logic [31:0] lsu_addr_low;      // The lowest accessed address of an LSU transaction
      logic [31:0] lsu_addr_high;     // The highest accessed address of an LSU transaction

      // Exception trigger code match
      logic [31:0] exception_match[DBG_NUM_TRIGGERS];

      // Resolve hit1+hit0 of mcontrol6
      logic [1:0] mcontrol6_hit_resolved[DBG_NUM_TRIGGERS];


      // Write data
      // tdata1 has one _n value per implemented trigger to enable updating all hit-fields of
      // mcontrol6 at the same time.
      for (genvar idx=0; idx<DBG_NUM_TRIGGERS; idx++) begin : tdata1_wdata
        always_comb begin
          tdata1_n[idx]  = tdata1_rdata[idx];
          tdata1_we_hit[idx] = 1'b0;

          mcontrol6_hit_resolved[idx] = mcontrol6_hit_resolve({tdata1_rdata[idx][MCONTROL_6_HIT1], tdata1_rdata[idx][MCONTROL_6_HIT0]},
                                                              {csr_wdata_i[MCONTROL_6_HIT1], csr_wdata_i[MCONTROL_6_HIT0]});
          if (tdata1_we_i && (tselect_rdata_o == idx)) begin
            if (csr_wdata_i[TDATA1_TTYPE_HIGH:TDATA1_TTYPE_LOW] == TTYPE_MCONTROL) begin
              // Mcontrol supports any value in tdata2, no need to check tdata2 before writing tdata1
              tdata1_n[idx] = {
                                TTYPE_MCONTROL,        // type    : address/data match
                                1'b1,                  // dmode   : access from D mode only
                                6'b000000,             // maskmax  : hardwired to zero
                                1'b0,                  // hit     : hardwired to zero
                                1'b0,                  // select  : hardwired to zero, only address matching
                                1'b0,                  // timing  : hardwired to zero, only 'before' timing
                                2'b00,                 // sizelo  : hardwired to zero, match any size
                                4'b0001,               // action  : enter debug on match
                                1'b0,                  // chain   : hardwired to zero
                                mcontrol2_6_match_resolve(csr_wdata_i[MCONTROL2_6_MATCH_HIGH:MCONTROL2_6_MATCH_LOW]), // match, WARL(0,2,3) 10:7
                                csr_wdata_i[6],        // m       : match in machine mode
                                1'b0,                  //         : hardwired to zero
                                1'b0,                  // s       : hardwired to zer0
                                mcontrol2_6_u_resolve(csr_wdata_i[MCONTROL2_6_U]),     // zero, U 3
                                csr_wdata_i[2],        // EXECUTE 2
                                csr_wdata_i[1],        // STORE 1
                                csr_wdata_i[0]         // LOAD 0
                            };
            end else if (csr_wdata_i[TDATA1_TTYPE_HIGH:TDATA1_TTYPE_LOW] == TTYPE_MCONTROL6) begin
              // Mcontrol6 supports any value in tdata2, no need to check tdata2 before writing tdata1
              tdata1_n[idx] = {
                                TTYPE_MCONTROL6,       // type    : address/data match
                                1'b1,                  // dmode   : access from D mode only
                                mcontrol6_uncertain_resolve(csr_wdata_i[MCONTROL_6_UNCERTAIN]), // uncertain  26
                                mcontrol6_hit_resolved[idx][1], // hit1: 25
                                2'b00,                // zero, vs, vu
                                mcontrol6_hit_resolved[idx][0], // hit0: 22
                                1'b0,                  // zero, select 21
                                2'b00,                 // zero, 20:19
                                3'b000,                // zero, size (match any size) 18:16
                                4'b0001,               // action, WARL(1), enter debug 15:12
                                1'b0,                  // zero, chain 11
                                mcontrol2_6_match_resolve(csr_wdata_i[MCONTROL2_6_MATCH_HIGH:MCONTROL2_6_MATCH_LOW]), // match, WARL(0,2,3) 10:7
                                csr_wdata_i[6],        // M  6
                                mcontrol6_uncertainen_resolve(csr_wdata_i[MCONTROL_6_UNCERTAINEN]), // uncertainen 5
                                1'b0,                  // zero, S 4
                                mcontrol2_6_u_resolve(csr_wdata_i[MCONTROL2_6_U]),     // zero, U 3
                                csr_wdata_i[2],        // EXECUTE 2
                                csr_wdata_i[1],        // STORE 1
                                csr_wdata_i[0]         // LOAD 0
                              };
            end else if (csr_wdata_i[TDATA1_TTYPE_HIGH:TDATA1_TTYPE_LOW] == TTYPE_ETRIGGER) begin
              // Etrigger can only support a subset of possible values in tdata2, only update tdata1 if
              // tdata2 contains a legal value for etrigger.

              // Detect if any cleared bits in ETRIGGER_TDATA2_MASK are set in tdata2
              if (|(tdata2_rdata_o & (~ETRIGGER_TDATA2_MASK))) begin
                // Unsupported exception codes enabled, default to disabled trigger.
                tdata1_n[idx] = {TTYPE_DISABLED, 1'b1, {27{1'b0}}};
              end else begin
                tdata1_n[idx] = {
                                  TTYPE_ETRIGGER,        // type  : exception trigger
                                  1'b1,                  // dmode : access from D mode only 27
                                  1'b0,                  // hit   : WARL(0) 26
                                  13'h0,                 // zero  : tied to zero 25:13
                                  1'b0,                  // vs    : WARL(0) 12
                                  1'b0,                  // vu    : WARL(0) 11
                                  1'b0,                  // zero  : tied to zero 10
                                  csr_wdata_i[9],        // m     : Match in machine mode 9
                                  1'b0,                  // zero  : tied to zero 8
                                  1'b0,                  // s     : WARL(0) 7
                                  etrigger_u_resolve(csr_wdata_i[ETRIGGER_U]), // u     : Match in user mode 6
                                  6'b000001              // action : WARL(1), enter debug on match
                                };
              end
            end else if (csr_wdata_i[TDATA1_TTYPE_HIGH:TDATA1_TTYPE_LOW] == TTYPE_DISABLED) begin
              // All tdata2 values are legal for a disabled trigger, no WARL on tdata1.
              tdata1_n[idx] = {TTYPE_DISABLED, 1'b1, {27{1'b0}}};
            end else begin
              // No legal trigger type, set disabled trigger type 0xF
              tdata1_n[idx] = {TTYPE_DISABLED, 1'b1, {27{1'b0}}};
            end
          end // tdata1_we_i

          // SW writes and writes from controller cannot happen at the same time.
          // Update bits {hit1, hit0} (WARL 0x0, 0x1)
          if (ctrl_fsm_i.debug_trigger_hit_update) begin
            if (tdata1_rdata[idx][TDATA1_TTYPE_HIGH:TDATA1_TTYPE_LOW] == TTYPE_MCONTROL6) begin
              if (ctrl_fsm_i.debug_trigger_hit[idx]) begin
                tdata1_n[idx][MCONTROL_6_HIT1]  = 1'b0;
                tdata1_n[idx][MCONTROL_6_HIT0]  = 1'b1;
                tdata1_we_hit[idx]              = 1'b1;
              end
            end
          end
        end
      end //for

      // Write data for tdata2 and tselect
      always_comb begin
        // Tselect is WARL (0 -> DBG_NUM_TRIGGERS-1)
        tselect_n = (csr_wdata_i < DBG_NUM_TRIGGERS) ? csr_wdata_i : tselect_rdata_o;
        tdata2_n  = tdata2_rdata_o;

        // tdata2
        if (tdata2_we_i) begin
          if ((tdata1_rdata_o[TDATA1_TTYPE_HIGH:TDATA1_TTYPE_LOW] == TTYPE_DISABLED) ||
              (tdata1_rdata_o[TDATA1_TTYPE_HIGH:TDATA1_TTYPE_LOW] == TTYPE_MCONTROL) ||
              (tdata1_rdata_o[TDATA1_TTYPE_HIGH:TDATA1_TTYPE_LOW] == TTYPE_MCONTROL6)) begin
            // Disabled trigger, mcontrol and mcontrol6 can have any value in tdata2
            tdata2_n = csr_wdata_i;
          end else begin
            // Exception trigger, only allow implemented exception codes to be used
            tdata2_n = csr_wdata_i & ETRIGGER_TDATA2_MASK;
          end
        end // tdata2_we_i

        tinfo_n       = tinfo_rdata_o;    // Read only
      end

      // Calculate highest and lowest value of address[1:0] based on lsu_be_ex_i
      always_comb begin
        lsu_addr_high_lsb = 2'b00;
        lsu_addr_low_lsb  = 2'b00;
        // Find highest accessed byte
        for (int b=0; b<4; b++) begin : gen_high_byte_checks
          if (lsu_be_ex_i[b]) begin
            lsu_addr_high_lsb = 2'(b);
          end // if
        end // for

        // Find lowest accessed byte
        for (int b=3; b>=0; b--) begin : gen_low_byte_checks
          if (lsu_be_ex_i[b]) begin
            lsu_addr_low_lsb = 2'(b);
          end // if
        end // for
      end // always

      assign lsu_addr_high = {lsu_addr_ex_i[31:2], lsu_addr_high_lsb};
      assign lsu_addr_low =  {lsu_addr_ex_i[31:2], lsu_addr_low_lsb};

      // Generate DBG_NUM_TRIGGERS instances of tdata1, tdata2 and match checks
      for (genvar idx=0; idx<DBG_NUM_TRIGGERS; idx++) begin : tmatch_csr

        ////////////////////////////////////
        // Instruction address match (IF)
        ////////////////////////////////////

        // With timing=0 we enter debug before executing the instruction at the match address. We use the IF stage PC
        // for comparison, and any trigger match will cause the instruction to act as a NOP with no side effects until it
        // reaches WB where debug mode is entered.
        //
        // Trigger match is disabled while in debug mode.
        //
        // Trigger CSRs can only be written from debug mode, writes from any other privilege level are ignored.
        //   Thus we do not have an issue where a write to the tdata2 CSR immediately before the matched instruction
        //   could be missed since we must write in debug mode, then dret to machine mode (kills pipeline) before
        //   returning to dpc.
        //   No instruction address match on any pointer type (CLIC and Zc tablejumps).

        // Check for address match using tdata2.match for checking rule
        assign if_addr_match[idx] = (tdata1_rdata[idx][MCONTROL2_6_MATCH_HIGH:MCONTROL2_6_MATCH_LOW] == 4'h0) ? (pc_if_i == tdata2_rdata[idx]) :
                                    (tdata1_rdata[idx][MCONTROL2_6_MATCH_HIGH:MCONTROL2_6_MATCH_LOW] == 4'h2) ? (pc_if_i >= tdata2_rdata[idx]) : (pc_if_i < tdata2_rdata[idx]);

        // Check if matching is enabled for the current privilege level from IF
        assign priv_lvl_match_en_if[idx] = (tdata1_rdata[idx][MCONTROL2_6_M] && (priv_lvl_if_i == PRIV_LVL_M)) ||
                                           (tdata1_rdata[idx][MCONTROL2_6_U] && (priv_lvl_if_i == PRIV_LVL_U));

        // Check for trigger match from IF
        assign trigger_match_if[idx] = ((tdata1_rdata[idx][TDATA1_TTYPE_HIGH:TDATA1_TTYPE_LOW] == TTYPE_MCONTROL)   ||
                                        (tdata1_rdata[idx][TDATA1_TTYPE_HIGH:TDATA1_TTYPE_LOW] == TTYPE_MCONTROL6)) &&
                                       tdata1_rdata[idx][MCONTROL2_6_EXECUTE] && priv_lvl_match_en_if[idx] && !ctrl_fsm_i.debug_mode && !ptr_in_if_i &&
                                       if_addr_match[idx];

        ///////////////////////////////////////
        // Load/Store address match (EX)
        ///////////////////////////////////////

        // As for instruction address match, the load/store address match happens before the a bus transaction is visible on the OBI bus.
        // For split misaligned transfers, each transfer is checked separately. This means that half a store may be visible externally even if
        // the second part matches tdata2 and debug is entered. For loads the RF write will not happen until the last part finished anyway, so no state update
        // will happen regardless of which transaction matches.
        // The BE of the transaction is used to determine which bytes of a word is being accessed.

        // Check if any accessed byte matches the lower two bits of tdata2
        always_comb begin
          for (int b=0; b<4; b++) begin
            if (lsu_be_ex_i[b] && (2'(b) == tdata2_rdata[idx][1:0])) begin
              lsu_byte_addr_match[idx][b] = 1'b1;
            end else begin
              lsu_byte_addr_match[idx][b] = 1'b0;
            end
          end
        end

        // Check address matches for (==), (>=) and (<)
        // For ==, check that we match the 32-bit aligned word and that any of the accessed bytes matches tdata2[1:0]
        // For >=, check that the highest accessed address is greater than or equal to tdata2. If this fails, no bytes within the access are >= tdata2
        // For <, check that the lowest accessed address is less than tdata2. If this fails, no bytes within the access are < tdata2.
        assign lsu_addr_match[idx] = (tdata1_rdata[idx][MCONTROL2_6_MATCH_HIGH:MCONTROL2_6_MATCH_LOW] == 4'h0) ? ((lsu_addr_ex_i[31:2] == tdata2_rdata[idx][31:2]) && (|lsu_byte_addr_match[idx])) :
                                     (tdata1_rdata[idx][MCONTROL2_6_MATCH_HIGH:MCONTROL2_6_MATCH_LOW] == 4'h2) ? (lsu_addr_high >= tdata2_rdata[idx]) :
                                                                                                             (lsu_addr_low  <  tdata2_rdata[idx]) ;

        // Check if matching is enabled for the current privilege level from EX
        assign priv_lvl_match_en_ex[idx] = (tdata1_rdata[idx][MCONTROL2_6_M] && (priv_lvl_ex_i == PRIV_LVL_M)) ||
                                           (tdata1_rdata[idx][MCONTROL2_6_U] && (priv_lvl_ex_i == PRIV_LVL_U));

        // Enable LSU address matching
        // AMO transactions have lsu_we_ex_i == 1'b1, but also perform a read. Thus AMOs will also match loads regardless of the lsu_we_we bit.
        assign lsu_addr_match_en[idx] = lsu_valid_ex_i && ((tdata1_rdata[idx][MCONTROL2_6_LOAD] && (!lsu_we_ex_i || (lsu_atomic_ex_i == AT_AMO))) || (tdata1_rdata[idx][MCONTROL2_6_STORE] && lsu_we_ex_i));

        // Signal trigger match for LSU address
        assign trigger_match_ex[idx] = ((tdata1_rdata[idx][TDATA1_TTYPE_HIGH:TDATA1_TTYPE_LOW] == TTYPE_MCONTROL)   ||
                                        (tdata1_rdata[idx][TDATA1_TTYPE_HIGH:TDATA1_TTYPE_LOW] == TTYPE_MCONTROL6)) &&
                                        priv_lvl_match_en_ex[idx] &&  lsu_addr_match_en[idx] && lsu_addr_match[idx] && !ctrl_fsm_i.debug_mode;

        /////////////////////////////
        // Exception trigger
        /////////////////////////////

        always_comb begin
          exception_match[idx] = 32'd0;
          for (int i=0; i<32; i++) begin
            exception_match[idx][i] = tdata2_rdata[idx][i] && ctrl_fsm_i.exception_in_wb && (ctrl_fsm_i.exception_cause_wb == 11'(i));
          end
        end

        assign priv_lvl_match_en_wb[idx] = (tdata1_rdata[idx][ETRIGGER_M] && (priv_lvl_wb_i == PRIV_LVL_M)) ||
                                           (tdata1_rdata[idx][ETRIGGER_U] && (priv_lvl_wb_i == PRIV_LVL_U));

        assign etrigger_wb[idx] = (tdata1_rdata[idx][TDATA1_TTYPE_HIGH:TDATA1_TTYPE_LOW] == TTYPE_ETRIGGER) && priv_lvl_match_en_wb[idx] &&
                                  (|exception_match[idx]) && !ctrl_fsm_i.debug_mode;



        cv32e40x_csr
        #(
          .WIDTH      (32),
          .RESETVALUE (TDATA1_RST_VAL)
        )
        tdata1_csr_i
        (
          .clk                ( clk                   ),
          .rst_n              ( rst_n                 ),
          .wr_data_i          ( tdata1_n[idx]         ),
          .wr_en_i            ( tdata1_we_int[idx]    ),
          .rd_data_o          ( tdata1_q[idx]         )
        );

        cv32e40x_csr
        #(
          .WIDTH      (32),
          .RESETVALUE (32'd0)
        )
        tdata2_csr_i
        (
          .clk                ( clk                   ),
          .rst_n              ( rst_n                 ),
          .wr_data_i          ( tdata2_n              ),
          .wr_en_i            ( tdata2_we_int[idx]    ),
          .rd_data_o          ( tdata2_q[idx]         )
        );

        // Set write enables
        assign tdata1_we_int[idx] = (tdata1_we_i && (tselect_rdata_o == idx)) || tdata1_we_hit[idx];
        assign tdata2_we_int[idx] = tdata2_we_i && (tselect_rdata_o == idx);

        // Assign read data
        assign tdata1_rdata[idx] = tdata1_q[idx];
        assign tdata2_rdata[idx] = tdata2_q[idx];
      end // for

      // CSR instance for tselect
      cv32e40x_csr
      #(
        .WIDTH      (32),
        .RESETVALUE (32'd0)
      )
      tselect_csr_i
      (
        .clk                ( clk                   ),
        .rst_n              ( rst_n                 ),
        .wr_data_i          ( tselect_n             ),
        .wr_en_i            ( tselect_we_i          ),
        .rd_data_o          ( tselect_q             )
      );

      // Assign CSR read data outputs
      always_comb begin
        tdata1_rdata_o = tdata1_rdata[0];
        tdata2_rdata_o = tdata2_rdata[0];

        // Iterate through triggers and set tdata1/tdata2 rdata for the currently selected trigger
        for (int unsigned i=0; i<DBG_NUM_TRIGGERS; i++) begin
          if(tselect_rdata_o == i) begin
            tdata1_rdata_o = tdata1_rdata[i];
            tdata2_rdata_o = tdata2_rdata[i];
          end
        end
      end

      // RVFI only
      // assign _we_r and wdata_n_r values
      always_comb begin
        tdata1_we_r = tdata1_we_i || tselect_we_i;
        tdata2_we_r = tdata2_we_i || tselect_we_i;

        tdata1_n_r = tdata1_n[0];
        tdata2_n_r = tdata2_n;

        // Iterate over all triggers and pick tdata1_n_r and tdata1_we_r for the
        // currently selected trigger.
        for (int unsigned i=0; i<DBG_NUM_TRIGGERS; i++) begin
          if(tselect_rdata_o == i) begin
            tdata1_n_r = tdata1_n[i];
            // Using tdata1_we_int to include HW writes to mcontrol6
            tdata1_we_r = tdata1_we_int[i] || tselect_we_i;
          end
        end

        // Make sure to update SW visible trigger CSRs on RVFI
        // when tselect is written
        if (tselect_we_i) begin
          for (int unsigned i=0; i<DBG_NUM_TRIGGERS; i++) begin
            if(tselect_n == i) begin
              tdata1_n_r = tdata1_rdata[i];
              tdata2_n_r = tdata2_rdata[i];
            end
          end
        end
      end


      assign tselect_rdata_o  = tselect_q;
      assign tinfo_rdata_o    = 32'h01008064; // Supported types 0x2, 0x5, 0x6 and 0xF, tinfo.version=1

      // Set trigger match for IF
      assign trigger_match_if_o = {{(32-DBG_NUM_TRIGGERS){1'b0}}, trigger_match_if};

      // Set trigger match for EX
      assign trigger_match_ex_o = {{(32-DBG_NUM_TRIGGERS){1'b0}}, trigger_match_ex};

      // Set trigger match for WB
      assign etrigger_wb_o = |etrigger_wb;

      assign unused_signals = tinfo_we_i | (|tinfo_n) | (|tdata1_n_r) | (|tdata2_n_r) | tdata1_we_r | tdata2_we_r;

    end else begin : gen_no_triggers
      // Tie off outputs
      assign tdata1_rdata_o = '0;
      assign tdata2_rdata_o = '0;
      assign tselect_rdata_o = '0;
      assign tinfo_rdata_o = '0;
      assign trigger_match_if_o = '0;
      assign trigger_match_ex_o = '0;
      assign etrigger_wb_o = '0;
      assign tdata1_n = '0;
      assign tdata2_n = '0;
      assign tselect_n = '0;
      assign tinfo_n = '0;
      assign tdata1_n_r = '0;
      assign tdata2_n_r = '0;
      assign tdata1_we_r = 1'b0;
      assign tdata2_we_r = 1'b0;

      assign unused_signals = (|tdata1_n) | (|tdata2_n) | (|tselect_n) | (|tinfo_n) |
                              (|csr_wdata_i) | tdata1_we_i | tdata2_we_i | tselect_we_i | tinfo_we_i |
                              (|tdata1_n_r) | (|tdata2_n_r) | tdata1_we_r | tdata2_we_r;
    end
  endgenerate
endmodule






// Description:    Control and Status Registers (CSRs)                        //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_cs_registers import cv32e40x_pkg::*;
#(
  parameter rv32_e       RV32                 = RV32I,
  parameter a_ext_e      A_EXT                = A_NONE,
  parameter m_ext_e      M_EXT                = M,
  parameter bit          X_EXT                = 0,
  parameter logic [31:0] X_MISA               =  32'h00000000,
  parameter logic [1:0]  X_ECS_XS             =  2'b00, // todo:XIF implement related mstatus bitfields (but only if X_EXT = 1)
  parameter bit          ZC_EXT               = 0,
  parameter bit          CLIC                 = 0,
  parameter int unsigned CLIC_ID_WIDTH        = 5,
  parameter int unsigned NUM_MHPMCOUNTERS     = 1,
  parameter bit          DEBUG                = 1,
  parameter int          DBG_NUM_TRIGGERS     = 1,
  parameter int unsigned MTVT_ADDR_WIDTH      = 26
)
(
  // Clock and Reset
  input  logic                          clk,
  input  logic                          rst_n,

  // Configuration
  input  logic [31:0]                   mhartid_i,
  input  logic  [3:0]                   mimpid_patch_i,
  input  logic [31:0]                   mtvec_addr_i,
  input  logic                          csr_mtvec_init_i,

  // CSRs
  output dcsr_t                         dcsr_o,
  output logic [31:0]                   dpc_o,
  output logic [JVT_ADDR_WIDTH-1:0]     jvt_addr_o,
  output logic [5:0]                    jvt_mode_o,
  output mcause_t                       mcause_o,
  output logic [63:0]                   mcycle_o,
  output logic [31:0]                   mepc_o,
  output logic [31:0]                   mie_o,
  output mintstatus_t                   mintstatus_o,
  output logic [7:0]                    mintthresh_th_o,
  output mstatus_t                      mstatus_o,
  output logic [24:0]                   mtvec_addr_o,
  output logic  [1:0]                   mtvec_mode_o,
  output logic [MTVT_ADDR_WIDTH-1:0]    mtvt_addr_o,

  output privlvl_t                      priv_lvl_o,
  output privlvlctrl_t                  priv_lvl_if_ctrl_o,
  output privlvl_t                      priv_lvl_lsu_o,

  // ID/EX pipeline
  input id_ex_pipe_t                    id_ex_pipe_i,
  output logic                          csr_illegal_o,

  // EX/WB pipeline
  input  ex_wb_pipe_t                   ex_wb_pipe_i,

  // From controller_fsm
  input  ctrl_fsm_t                     ctrl_fsm_i,

  // To controller_bypass
  output logic                          csr_counter_read_o,
  output logic                          csr_mnxti_read_o,
  output csr_hz_t                       csr_hz_o,

  // Interface to CSRs (SRAM like)
  output logic [31:0]                   csr_rdata_o,

  // Interrupts
  input  logic [31:0]                   mip_i,
  input  logic                          mnxti_irq_pending_i,
  input  logic [CLIC_ID_WIDTH-1:0]    mnxti_irq_id_i,
  input  logic [7:0]                    mnxti_irq_level_i,
  output logic                          clic_pa_valid_o,        // CSR read data is an address to a function pointer
  output logic [31:0]                   clic_pa_o,              // Address to CLIC function pointer
  output logic                          csr_irq_enable_write_o, // An irq enable write is being performed in WB

  // Time input
  input  logic [63:0]                   time_i,

  // CSR write strobes
  output logic                          csr_wr_in_wb_flush_o,

  // Debug
  input  logic [31:0]                   pc_if_i,
  input  logic                          ptr_in_if_i,
  input  privlvl_t                      priv_lvl_if_i,
  output logic [31:0]                   trigger_match_if_o,
  output logic [31:0]                   trigger_match_ex_o,
  output logic                          etrigger_wb_o,
  input  logic                          lsu_valid_ex_i,
  input  logic [31:0]                   lsu_addr_ex_i,
  input  logic                          lsu_we_ex_i,
  input  logic [3:0]                    lsu_be_ex_i,
  input  lsu_atomic_e                   lsu_atomic_ex_i
);

  localparam logic [31:0] CORE_MISA =
    (32'(A_EXT == A)      <<  0) | // A - Atomic Instructions extension
    (32'(1)               <<  2) | // C - Compressed extension
    (32'(RV32 == RV32E)   <<  4) | // E - RV32E/64E base ISA
    (32'(RV32 == RV32I)   <<  8) | // I - RV32I/64I/128I base ISA
    (32'(M_EXT == M)      << 12) | // M - Integer Multiply/Divide extension
    (32'(0)               << 20) | // U - User mode implemented
    (32'(1)               << 23) | // X - Non-standard extensions present
    (32'(MXL)             << 30);  // M-XLEN

  localparam bit          ZIHPM  = 1'b1;
  localparam bit          ZICNTR = 1'b1;

  localparam logic [31:0] MISA_VALUE = CORE_MISA | (X_EXT ? X_MISA : 32'h0000_0000);

  localparam logic [31:0] CSR_MTVT_MASK = {{MTVT_ADDR_WIDTH{1'b1}}, {(32-MTVT_ADDR_WIDTH){1'b0}}};

  // CSR update logic
  logic [31:0]                  csr_wdata_int;
  logic [31:0]                  csr_rdata_int;
  logic                         csr_we_int;

  csr_opcode_e                  csr_op;
  csr_num_e                     csr_waddr;
  csr_num_e                     csr_raddr;
  logic [31:0]                  csr_wdata;
  logic                         csr_en_gated;

  logic                         illegal_csr_read;                               // Current CSR cannot be read
  logic                         illegal_csr_write;                              // Current CSR cannot be written

  logic                         instr_valid;                                    // Local instr_valid

  logic                         unused_signals;

  // Interrupt control signals
  logic [31:0]                  mepc_q, mepc_n, mepc_rdata;
  logic                         mepc_we;

  // Trigger
  // Trigger CSR write enables are decoded in cs_registers, all other (WARL behavior, write data and trigger matches)
  // are handled within cv32e40x_debug_triggers
  logic [31:0]                  tselect_rdata;
  logic                         tselect_we;

  logic [31:0]                  tdata1_rdata;
  logic                         tdata1_we;

  logic [31:0]                  tdata2_rdata;
  logic                         tdata2_we;

  logic [31:0]                  tinfo_rdata;
  logic                         tinfo_we;

  // Debug
  dcsr_t                        dcsr_q, dcsr_n, dcsr_rdata;
  logic                         dcsr_we;

  logic [31:0]                  dpc_q, dpc_n, dpc_rdata;
  logic                         dpc_we;

  logic [31:0]                  dscratch0_q, dscratch0_n, dscratch0_rdata;
  logic                         dscratch0_we;

  logic [31:0]                  dscratch1_q, dscratch1_n, dscratch1_rdata;
  logic                         dscratch1_we;

  logic [31:0]                  mscratch_q, mscratch_n, mscratch_rdata;
  logic                         mscratch_we;

  jvt_t                         jvt_q, jvt_n, jvt_rdata;
  logic                         jvt_we;

  mstatus_t                     mstatus_q, mstatus_n, mstatus_rdata;
  logic                         mstatus_we;

  logic [31:0]                  mstatush_n, mstatush_rdata;                     // No CSR module instance
  logic                         mstatush_we;                                    // Not used in RTL (used by RVFI)

  logic [31:0]                  misa_n, misa_rdata;                             // No CSR module instance
  logic                         misa_we;                                        // Not used in RTL (used by RVFI)

  mcause_t                      mcause_q, mcause_n, mcause_rdata;
  logic                         mcause_we;

  mtvec_t                       mtvec_q, mtvec_n, mtvec_rdata;
  logic                         mtvec_we;

  mtvt_t                        mtvt_q, mtvt_n, mtvt_rdata;
  logic                         mtvt_we;

  logic [31:0]                  mnxti_n, mnxti_rdata;                           // No CSR module instance
  logic                         mnxti_we;

  mintstatus_t                  mintstatus_q, mintstatus_n, mintstatus_rdata;
  logic                         mintstatus_we;

  logic [31:0]                  mintthresh_q, mintthresh_n, mintthresh_rdata;
  logic                         mintthresh_we;

  logic [31:0]                  mscratchcswl_n, mscratchcswl_rdata;
  logic                         mscratchcswl_we;

  logic [31:0]                  mip_n, mip_rdata;                               // No CSR module instance
  logic                         mip_we;                                         // Not used in RTL (used by RVFI)

  logic [31:0]                  mie_q, mie_n, mie_rdata;                        // Bits are masked according to IRQ_MASK
  logic                         mie_we;

  logic [31:0]                  mvendorid_n, mvendorid_rdata;                   // No CSR module instance
  logic                         mvendorid_we;                                   // Always 0 (MRO), not used in RTL (used by RVFI)

  logic [31:0]                  marchid_n, marchid_rdata;                       // No CSR module instance
  logic                         marchid_we;                                     // Always 0 (MRO), not used in RTL (used by RVFI)

  logic [31:0]                  mimpid_n, mimpid_rdata;                         // No CSR module instance
  logic                         mimpid_we;                                      // Always 0 (MRO), not used in RTL (used by RVFI)

  logic [31:0]                  mhartid_n, mhartid_rdata;                       // No CSR module instance
  logic                         mhartid_we;                                     // Always 0 (MRO), not used in RTL (used by RVFI)

  logic [31:0]                  mconfigptr_n, mconfigptr_rdata;                 // No CSR module instance
  logic                         mconfigptr_we;                                  // Always 0 (MRO), not used in RTL (used by RVFI)

  logic [31:0]                  mtval_n, mtval_rdata;                           // No CSR module instance
  logic                         mtval_we;                                       // Not used in RTL (used by RVFI)

  privlvl_t                     priv_lvl_n, priv_lvl_q, priv_lvl_rdata;
  logic                         priv_lvl_we;

  // Detect JVT writes (requires pipeline flush)
  logic                         csr_wr_in_wb;
  logic                         jvt_wr_in_wb;

  // Special we signal for aliased writes between mstatus and mcause.
  // Only used for explicit writes to either mcause or mstatus, to signal that
  // mpp and mpie of the aliased CSR should be written.
  // All implicit writes (upon taking exceptions etc) handle the aliasing by also
  // writing mcause.mpp/mpie to mstatus and vice versa.
  logic                         mcause_alias_we;
  logic                         mstatus_alias_we;


  // Performance Counter Signals
  logic [31:0] [63:0]           mhpmcounter_q;                                  // Performance counters
  logic [31:0] [63:0]           mhpmcounter_n;                                  // Performance counters next value
  logic [31:0] [63:0]           mhpmcounter_rdata;                              // Performance counters next value
  logic [31:0] [1:0]            mhpmcounter_we;                                 // Performance counters write enable
  logic [31:0] [31:0]           mhpmevent_q, mhpmevent_n, mhpmevent_rdata;      // Event enable
  logic [31:0]                  mcountinhibit_q, mcountinhibit_n, mcountinhibit_rdata; // Performance counter inhibit
  logic [NUM_HPM_EVENTS-1:0]    hpm_events;                                     // Events for performance counters
  logic [31:0] [63:0]           mhpmcounter_increment;                          // Increment of mhpmcounter_q
  logic [31:0]                  mhpmcounter_write_lower;                        // Write 32 lower bits of mhpmcounter_q
  logic [31:0]                  mhpmcounter_write_upper;                        // Write 32 upper bits mhpmcounter_q
  logic [31:0]                  mhpmcounter_write_increment;                    // Write increment of mhpmcounter_q

  // Signal used for RVFI to set rmask, not used internally
  logic                         mscratchcswl_in_wb;
  logic                         mnxti_in_wb;

  // Local padded version of mnxti_irq_id_i
  logic [32-MTVT_ADDR_WIDTH-2-1:0] mnxti_irq_id;

  // Pad mnxti_irq_i with zeroes if CLIC_ID_WIDTH is not 4 or more.
  generate
    if (CLIC_ID_WIDTH < 4) begin : mnxti_irq_id_lt4
      assign mnxti_irq_id = {{(4-CLIC_ID_WIDTH){1'b0}}, mnxti_irq_id_i};
    end
    else begin: mnxti_irq_id_ge4
      assign mnxti_irq_id = mnxti_irq_id_i;
    end
  endgenerate

  // Local instr_valid for write portion (WB)
  // Not factoring in ctrl_fsm_i.halt_limited_wb. This signal is only set during SLEEP mode, and while in SLEEP
  // there cannot be any CSR instruction in WB.
  assign instr_valid = ex_wb_pipe_i.instr_valid && !ctrl_fsm_i.kill_wb && !ctrl_fsm_i.halt_wb;

  // CSR access. Read in EX, write in WB
  // Setting csr_raddr to zero in case of unused csr to save power (alu_operand_b toggles a lot)
  assign csr_raddr = csr_num_e'((id_ex_pipe_i.csr_en && id_ex_pipe_i.instr_valid) ? id_ex_pipe_i.alu_operand_b[11:0] : 12'b0);

  // Not suppressing csr_waddr to zero when unused since its source are dedicated flipflops and would not save power as for raddr
  assign csr_waddr = csr_num_e'(ex_wb_pipe_i.csr_addr);
  assign csr_wdata = ex_wb_pipe_i.csr_wdata;

  assign csr_op    =  ex_wb_pipe_i.csr_op;

  // CSR write operations in WB, actual csr_we_int may still become 1'b0 in case of CSR_OP_READ
  assign csr_en_gated    = ex_wb_pipe_i.csr_en && instr_valid;

  ////////////////////////////////////////
  // Determine if CSR access is illegal //
  // Both read and write validity is    //
  // checked in the first (EX) stage    //
  // Invalid writes will suppress ex_wb //
  // signals and avoid writing in WB    //
  ////////////////////////////////////////
  assign illegal_csr_write = (id_ex_pipe_i.csr_op != CSR_OP_READ) &&
                             (id_ex_pipe_i.csr_en) &&
                             (csr_raddr[11:10] == 2'b11); // Priv spec section 2.1

  assign csr_illegal_o = (id_ex_pipe_i.instr_valid && id_ex_pipe_i.csr_en) ? illegal_csr_write || illegal_csr_read : 1'b0;


  ////////////////////////////////////////////
  //   ____ ____  ____    ____              //
  //  / ___/ ___||  _ \  |  _ \ ___  __ _   //
  // | |   \___ \| |_) | | |_) / _ \/ _` |  //
  // | |___ ___) |  _ <  |  _ <  __/ (_| |  //
  //  \____|____/|_| \_\ |_| \_\___|\__, |  //
  //                                |___/   //
  ////////////////////////////////////////////


  ////////////////////////////////////////////
  // CSR read logic

  always_comb
  begin
    illegal_csr_read    = 1'b0;
    csr_counter_read_o  = 1'b0;
    csr_mnxti_read_o    = 1'b0;
    csr_hz_o.impl_re_ex = 1'b0;
    csr_hz_o.impl_wr_ex = 1'b0;

    case (csr_raddr)
      // jvt: Jump vector table
      CSR_JVT:  begin
        if (ZC_EXT) begin
          csr_rdata_int = jvt_rdata;
        end else begin
          csr_rdata_int    = '0;
          illegal_csr_read = 1'b1;
        end
      end

      // mstatus
      CSR_MSTATUS: begin
        csr_rdata_int = mstatus_rdata;
        if (CLIC) begin
          csr_hz_o.impl_wr_ex = 1'b1; // Writes to mcause as well
        end
      end

      // misa
      CSR_MISA: csr_rdata_int = misa_rdata;

      // mie: machine interrupt enable
      CSR_MIE: begin
        csr_rdata_int = mie_rdata;
      end

      // mtvec: machine trap-handler base address
      CSR_MTVEC: csr_rdata_int = mtvec_rdata;

      // mtvt: machine trap-handler vector table base address
      CSR_MTVT: begin
        if (CLIC) begin
          csr_rdata_int = mtvt_rdata;
        end else begin
          csr_rdata_int    = '0;
          illegal_csr_read = 1'b1;
        end
      end

      // mstatush
      CSR_MSTATUSH: csr_rdata_int = mstatush_rdata;

      CSR_MCOUNTINHIBIT: csr_rdata_int = mcountinhibit_rdata;

      CSR_MHPMEVENT3,
      CSR_MHPMEVENT4,  CSR_MHPMEVENT5,  CSR_MHPMEVENT6,  CSR_MHPMEVENT7,
      CSR_MHPMEVENT8,  CSR_MHPMEVENT9,  CSR_MHPMEVENT10, CSR_MHPMEVENT11,
      CSR_MHPMEVENT12, CSR_MHPMEVENT13, CSR_MHPMEVENT14, CSR_MHPMEVENT15,
      CSR_MHPMEVENT16, CSR_MHPMEVENT17, CSR_MHPMEVENT18, CSR_MHPMEVENT19,
      CSR_MHPMEVENT20, CSR_MHPMEVENT21, CSR_MHPMEVENT22, CSR_MHPMEVENT23,
      CSR_MHPMEVENT24, CSR_MHPMEVENT25, CSR_MHPMEVENT26, CSR_MHPMEVENT27,
      CSR_MHPMEVENT28, CSR_MHPMEVENT29, CSR_MHPMEVENT30, CSR_MHPMEVENT31:
        csr_rdata_int = mhpmevent_rdata[csr_raddr[4:0]];

      // mscratch: machine scratch
      CSR_MSCRATCH: csr_rdata_int = mscratch_rdata;

      // mepc: exception program counter
      CSR_MEPC: csr_rdata_int = mepc_rdata;

      // mcause: exception cause
      CSR_MCAUSE: begin
        csr_rdata_int = mcause_rdata;
        if (CLIC) begin
          csr_hz_o.impl_wr_ex = 1'b1; // Writes to mstatus as well
        end
      end

      // mtval
      CSR_MTVAL: csr_rdata_int = mtval_rdata;

      // mip: interrupt pending
      CSR_MIP: csr_rdata_int = mip_rdata;

      // mnxti: Next Interrupt Handler Address and Interrupt Enable
      CSR_MNXTI: begin
        if (CLIC) begin
          // The data read here is what will be used in the read-modify-write portion of the CSR access.
          // For mnxti, this is actually mstatus. The value written back to the GPR will be the address of
          // the function pointer to the interrupt handler. This is muxed in the WB stage.
          csr_rdata_int = mstatus_rdata;
          csr_hz_o.impl_re_ex = 1'b1; // Reads mstatus
          csr_hz_o.impl_wr_ex = 1'b1; // Writes mstatus, mcause and mintstatus
          csr_mnxti_read_o = 1'b1;
        end else begin
          csr_rdata_int    = '0;
          illegal_csr_read = 1'b1;
        end
      end

      // mintstatus: Interrupt Status
      CSR_MINTSTATUS: begin
        if (CLIC) begin
          csr_rdata_int = mintstatus_rdata;
        end else begin
          csr_rdata_int    = '0;
          illegal_csr_read = 1'b1;
        end
      end

      // mintthresh: Interrupt-Level Threshold
      CSR_MINTTHRESH: begin
        if (CLIC) begin
          csr_rdata_int = mintthresh_rdata;
        end else begin
          csr_rdata_int    = '0;
          illegal_csr_read = 1'b1;
        end
      end

      // mscratchcswl: Scratch Swap for Interrupt Levels
      CSR_MSCRATCHCSWL: begin
        if (CLIC) begin
          // CLIC spec 14.1
          // Depending on mcause.pil and mintstatus.mil, either mscratch or rs1 is returned to rd.
          // Safe to use mcause_rdata and mintstatus_rdata here (EX timing), as there is a generic stall of the ID stage
          // whenever a CSR instruction follows another CSR instruction. Alternative implementation using
          // a local forward of mcause_rdata and mintstatus_rdata is identical (SEC).
          csr_hz_o.impl_re_ex = 1'b1; // Reads mscratch, mcause and mintstatus
          csr_hz_o.impl_wr_ex = 1'b1; // Writes mscratch
          if ((mcause_rdata.mpil == '0) != (mintstatus_rdata.mil == 0)) begin
            // Return mscratch for writing to GPR
            csr_rdata_int = mscratch_rdata;
          end else begin
            // return rs1 for writing to GPR
            csr_rdata_int = id_ex_pipe_i.alu_operand_a;
          end
        end else begin
          csr_rdata_int    = '0;
          illegal_csr_read = 1'b1;
        end
      end

      CSR_TSELECT: begin
        if (DBG_NUM_TRIGGERS > 0) begin
          csr_rdata_int = tselect_rdata;
          csr_hz_o.impl_wr_ex = 1'b1; // Changing tselect may change tdata1 and tdata2 as well
        end else begin
          csr_rdata_int = '0;
          illegal_csr_read = 1'b1;
        end
      end

      CSR_TDATA1: begin
        if (DBG_NUM_TRIGGERS > 0) begin
          csr_rdata_int = tdata1_rdata;
        end else begin
          csr_rdata_int = '0;
          illegal_csr_read = 1'b1;
        end
      end

      CSR_TDATA2: begin
        if (DBG_NUM_TRIGGERS > 0) begin
          csr_rdata_int = tdata2_rdata;
        end else begin
          csr_rdata_int = '0;
          illegal_csr_read = 1'b1;
        end
      end

      CSR_TINFO: begin
        if (DBG_NUM_TRIGGERS > 0) begin
          csr_rdata_int = tinfo_rdata;
        end else begin
          csr_rdata_int = '0;
          illegal_csr_read = 1'b1;
        end
      end

      CSR_DCSR: begin
        if (DEBUG) begin
          csr_rdata_int = dcsr_rdata;
          illegal_csr_read = !ctrl_fsm_i.debug_mode;
        end else begin
          csr_rdata_int    = '0;
          illegal_csr_read = 1'b1;
        end
      end

      CSR_DPC: begin
        if (DEBUG) begin
          csr_rdata_int = dpc_rdata;
          illegal_csr_read = !ctrl_fsm_i.debug_mode;
        end else begin
          csr_rdata_int    = '0;
          illegal_csr_read = 1'b1;
        end
      end

      CSR_DSCRATCH0: begin
        if (DEBUG) begin
          csr_rdata_int = dscratch0_rdata;
          illegal_csr_read = !ctrl_fsm_i.debug_mode;
        end else begin
          csr_rdata_int    = '0;
          illegal_csr_read = 1'b1;
        end
      end

      CSR_DSCRATCH1: begin
        if (DEBUG) begin
          csr_rdata_int = dscratch1_rdata;
          illegal_csr_read = !ctrl_fsm_i.debug_mode;
        end else begin
          csr_rdata_int    = '0;
          illegal_csr_read = 1'b1;
        end
      end

      CSR_TIME: begin
        if (ZICNTR) begin : zicntr_time
          csr_rdata_int = time_i[31:0];
        end else begin : no_zicntr_time
          csr_rdata_int    = '0;
          illegal_csr_read = 1'b1;
        end
      end

      CSR_TIMEH: begin
        if (ZICNTR) begin : zicntr_timeh
          csr_rdata_int = time_i[63:32];
        end else begin : no_zicntr_timeh
          csr_rdata_int    = '0;
          illegal_csr_read = 1'b1;
        end
      end

      // Hardware Performance Monitor
      CSR_MCYCLE,
      CSR_MINSTRET,
      CSR_MHPMCOUNTER3,
      CSR_MHPMCOUNTER4,  CSR_MHPMCOUNTER5,  CSR_MHPMCOUNTER6,  CSR_MHPMCOUNTER7,
      CSR_MHPMCOUNTER8,  CSR_MHPMCOUNTER9,  CSR_MHPMCOUNTER10, CSR_MHPMCOUNTER11,
      CSR_MHPMCOUNTER12, CSR_MHPMCOUNTER13, CSR_MHPMCOUNTER14, CSR_MHPMCOUNTER15,
      CSR_MHPMCOUNTER16, CSR_MHPMCOUNTER17, CSR_MHPMCOUNTER18, CSR_MHPMCOUNTER19,
      CSR_MHPMCOUNTER20, CSR_MHPMCOUNTER21, CSR_MHPMCOUNTER22, CSR_MHPMCOUNTER23,
      CSR_MHPMCOUNTER24, CSR_MHPMCOUNTER25, CSR_MHPMCOUNTER26, CSR_MHPMCOUNTER27,
      CSR_MHPMCOUNTER28, CSR_MHPMCOUNTER29, CSR_MHPMCOUNTER30, CSR_MHPMCOUNTER31 : begin
        csr_rdata_int = mhpmcounter_rdata[csr_raddr[4:0]][31:0];
        csr_counter_read_o = 1'b1;
      end


      CSR_CYCLE, CSR_INSTRET : begin
        if (ZICNTR) begin : zicntr_counters
          csr_rdata_int = mhpmcounter_rdata[csr_raddr[4:0]][31:0];
          csr_counter_read_o = 1'b1;
        end else begin : no_zicntr_counters
          csr_rdata_int    = '0;
          illegal_csr_read = 1'b1;
        end
      end

      CSR_CYCLEH, CSR_INSTRETH : begin
        if (ZICNTR) begin : zicntr_hcounters
        csr_rdata_int = mhpmcounter_rdata[csr_raddr[4:0]][63:32];
          csr_counter_read_o = 1'b1;
        end else begin : no_zicntr_hcounters
          csr_rdata_int    = '0;
          illegal_csr_read = 1'b1;
        end
      end

      CSR_HPMCOUNTER3,
      CSR_HPMCOUNTER4,  CSR_HPMCOUNTER5,  CSR_HPMCOUNTER6,  CSR_HPMCOUNTER7,
      CSR_HPMCOUNTER8,  CSR_HPMCOUNTER9,  CSR_HPMCOUNTER10, CSR_HPMCOUNTER11,
      CSR_HPMCOUNTER12, CSR_HPMCOUNTER13, CSR_HPMCOUNTER14, CSR_HPMCOUNTER15,
      CSR_HPMCOUNTER16, CSR_HPMCOUNTER17, CSR_HPMCOUNTER18, CSR_HPMCOUNTER19,
      CSR_HPMCOUNTER20, CSR_HPMCOUNTER21, CSR_HPMCOUNTER22, CSR_HPMCOUNTER23,
      CSR_HPMCOUNTER24, CSR_HPMCOUNTER25, CSR_HPMCOUNTER26, CSR_HPMCOUNTER27,
      CSR_HPMCOUNTER28, CSR_HPMCOUNTER29, CSR_HPMCOUNTER30, CSR_HPMCOUNTER31 : begin
        if (ZIHPM) begin : zihpm_counters
          csr_rdata_int = mhpmcounter_rdata[csr_raddr[4:0]][31:0];
          csr_counter_read_o = 1'b1;
        end else begin : no_zihpm_counters
          csr_rdata_int    = '0;
          illegal_csr_read = 1'b1;
        end
      end

      CSR_MCYCLEH,
      CSR_MINSTRETH,
      CSR_MHPMCOUNTER3H,
      CSR_MHPMCOUNTER4H,  CSR_MHPMCOUNTER5H,  CSR_MHPMCOUNTER6H,  CSR_MHPMCOUNTER7H,
      CSR_MHPMCOUNTER8H,  CSR_MHPMCOUNTER9H,  CSR_MHPMCOUNTER10H, CSR_MHPMCOUNTER11H,
      CSR_MHPMCOUNTER12H, CSR_MHPMCOUNTER13H, CSR_MHPMCOUNTER14H, CSR_MHPMCOUNTER15H,
      CSR_MHPMCOUNTER16H, CSR_MHPMCOUNTER17H, CSR_MHPMCOUNTER18H, CSR_MHPMCOUNTER19H,
      CSR_MHPMCOUNTER20H, CSR_MHPMCOUNTER21H, CSR_MHPMCOUNTER22H, CSR_MHPMCOUNTER23H,
      CSR_MHPMCOUNTER24H, CSR_MHPMCOUNTER25H, CSR_MHPMCOUNTER26H, CSR_MHPMCOUNTER27H,
      CSR_MHPMCOUNTER28H, CSR_MHPMCOUNTER29H, CSR_MHPMCOUNTER30H, CSR_MHPMCOUNTER31H: begin
        csr_rdata_int = mhpmcounter_rdata[csr_raddr[4:0]][63:32];
        csr_counter_read_o = 1'b1;
      end

      CSR_HPMCOUNTER3H,
      CSR_HPMCOUNTER4H,  CSR_HPMCOUNTER5H,  CSR_HPMCOUNTER6H,  CSR_HPMCOUNTER7H,
      CSR_HPMCOUNTER8H,  CSR_HPMCOUNTER9H,  CSR_HPMCOUNTER10H, CSR_HPMCOUNTER11H,
      CSR_HPMCOUNTER12H, CSR_HPMCOUNTER13H, CSR_HPMCOUNTER14H, CSR_HPMCOUNTER15H,
      CSR_HPMCOUNTER16H, CSR_HPMCOUNTER17H, CSR_HPMCOUNTER18H, CSR_HPMCOUNTER19H,
      CSR_HPMCOUNTER20H, CSR_HPMCOUNTER21H, CSR_HPMCOUNTER22H, CSR_HPMCOUNTER23H,
      CSR_HPMCOUNTER24H, CSR_HPMCOUNTER25H, CSR_HPMCOUNTER26H, CSR_HPMCOUNTER27H,
      CSR_HPMCOUNTER28H, CSR_HPMCOUNTER29H, CSR_HPMCOUNTER30H, CSR_HPMCOUNTER31H  : begin
        if (ZIHPM) begin : zihpm_hcounters
          csr_rdata_int      = mhpmcounter_rdata[csr_raddr[4:0]][63:32];
          csr_counter_read_o = 1'b1;
        end else begin : no_zihpm_hcounters
          csr_rdata_int    = '0;
          illegal_csr_read = 1'b1;
        end
      end

      // mvendorid: Machine Vendor ID
      CSR_MVENDORID: csr_rdata_int = mvendorid_rdata;

      // marchid: Machine Architecture ID
      CSR_MARCHID: csr_rdata_int = marchid_rdata;

      // mimpid: implementation id
      CSR_MIMPID: csr_rdata_int = mimpid_rdata;

      // mhartid: unique hardware thread id
      CSR_MHARTID: csr_rdata_int = mhartid_rdata;

      // mconfigptr: Pointer to configuration data structure
      CSR_MCONFIGPTR: csr_rdata_int = mconfigptr_rdata;

      default: begin
        csr_rdata_int    = '0;
        illegal_csr_read = 1'b1;
      end
    endcase
  end

  ////////////////////////////////////////////
  // CSR write logic

  always_comb
  begin

    jvt_n         = csr_next_value(csr_wdata_int, CSR_JVT_MASK, JVT_RESET_VAL);
    jvt_we        = 1'b0;

    mscratch_n    = csr_next_value(csr_wdata_int, CSR_MSCRATCH_MASK, MSCRATCH_RESET_VAL);
    mscratch_we   = 1'b0;

    mepc_n        = csr_next_value(csr_wdata_int, CSR_MEPC_MASK, MEPC_RESET_VAL);
    mepc_we       = 1'b0;

    dpc_n         = csr_next_value(csr_wdata_int, CSR_DPC_MASK, DPC_RESET_VAL);
    dpc_we        = 1'b0;

    dcsr_n        = csr_next_value(dcsr_t'{
                                            xdebugver : dcsr_rdata.xdebugver,
                                            ebreakm   : csr_wdata_int[15],
                                            ebreaku   : dcsr_ebreaku_resolve(dcsr_rdata.ebreaku, csr_wdata_int[DCSR_EBREAKU_BIT]),
                                            stepie    : csr_wdata_int[11],
                                            stopcount : csr_wdata_int[10],
                                            mprven    : dcsr_rdata.mprven,
                                            step      : csr_wdata_int[2],
                                            prv       : dcsr_prv_resolve(dcsr_rdata.prv, csr_wdata_int[DCSR_PRV_BIT_HIGH:DCSR_PRV_BIT_LOW]),
                                            cause     : dcsr_rdata.cause,
                                            default   : 'd0
                                          },
                                    CSR_DCSR_MASK, DCSR_RESET_VAL);
    dcsr_we       = 1'b0;

    dscratch0_n   = csr_next_value(csr_wdata_int, CSR_DSCRATCH0_MASK, DSCRATCH0_RESET_VAL);
    dscratch0_we  = 1'b0;

    dscratch1_n   = csr_next_value(csr_wdata_int, CSR_DSCRATCH1_MASK, DSCRATCH1_RESET_VAL);
    dscratch1_we  = 1'b0;

    tselect_we    = 1'b0;

    tdata1_we     = 1'b0;

    tdata2_we     = 1'b0;

    tinfo_we      = 1'b0;

    // TODO:XIF add support for SD/XS/FS/VS
    mstatus_n     = csr_next_value(mstatus_t'{
                                              tw:   1'b0,
                                              mprv: mstatus_mprv_resolve(mstatus_rdata.mprv, csr_wdata_int[MSTATUS_MPRV_BIT]),
                                              mpp:  mstatus_mpp_resolve(mstatus_rdata.mpp, csr_wdata_int[MSTATUS_MPP_BIT_HIGH:MSTATUS_MPP_BIT_LOW]),
                                              mpie: csr_wdata_int[MSTATUS_MPIE_BIT],
                                              mie:  csr_wdata_int[MSTATUS_MIE_BIT],
                                              default: 'b0
                                            },
                                  CSR_MSTATUS_MASK, MSTATUS_RESET_VAL);
    mstatus_we    = 1'b0;

    mstatush_n    = mstatush_rdata; // Read only
    mstatush_we   = 1'b0;
    mstatus_alias_we = 1'b0;

    misa_n        = misa_rdata; // Read only
    misa_we       = 1'b0;

    priv_lvl_n    = priv_lvl_rdata;
    priv_lvl_we   = 1'b0;

    if (CLIC) begin
      mtvec_n       = csr_next_value(mtvec_t'{
                                              addr:    csr_mtvec_init_i ? mtvec_addr_i[31:7] : csr_wdata_int[31:7],
                                              zero0:   mtvec_rdata.zero0,
                                              submode: mtvec_rdata.submode,
                                              mode:    csr_mtvec_init_i ? mtvec_rdata.mode : mtvec_mode_clic_resolve(mtvec_rdata.mode, csr_wdata_int[MTVEC_MODE_BIT_HIGH:MTVEC_MODE_BIT_LOW])
                                            },
                                      CSR_CLIC_MTVEC_MASK, MTVEC_CLIC_RESET_VAL);
      mtvec_we        = csr_mtvec_init_i;

      mtvt_n                   = csr_next_value({csr_wdata_int[31:(32-MTVT_ADDR_WIDTH)], {(32-MTVT_ADDR_WIDTH){1'b0}}}, CSR_MTVT_MASK, MTVT_RESET_VAL);
      mtvt_we                  = 1'b0;

      mnxti_we                 = 1'b0;

      mintstatus_n             = mintstatus_rdata; // Read only
      mintstatus_we            = 1'b0;

      mintthresh_n             = csr_next_value(csr_wdata_int, CSR_MINTTHRESH_MASK, MINTTHRESH_RESET_VAL);
      mintthresh_we            = 1'b0;

      mscratchcswl_n           = mscratch_n; // mscratchcswl operates conditionally on mscratch
      mscratchcswl_we          = 1'b0;

      mie_n                    = '0;
      mie_we                   = 1'b0;

      mip_n                    = mip_rdata; // Read only;
      mip_we                   = 1'b0;

      mcause_n                 = csr_next_value(mcause_t'{
                                                          irq:            csr_wdata_int[31],
                                                          minhv:          csr_wdata_int[30],
                                                          mpp:            mcause_mpp_resolve(mcause_rdata.mpp, csr_wdata_int[MCAUSE_MPP_BIT_HIGH:MCAUSE_MPP_BIT_LOW]),
                                                          mpie:           csr_wdata_int[MCAUSE_MPIE_BIT],
                                                          mpil:           csr_wdata_int[23:16],
                                                          exception_code: csr_wdata_int[10:0],
                                                          default:        'b0
                                                        },
                                                CSR_CLIC_MCAUSE_MASK, MCAUSE_CLIC_RESET_VAL);
      mcause_we                = 1'b0;
      mcause_alias_we          = 1'b0;
    end else begin // !CLIC
      mtvec_n                  = csr_next_value(mtvec_t'{
                                                        addr:    csr_mtvec_init_i ? mtvec_addr_i[31:7] : csr_wdata_int[31:7],
                                                        zero0:   mtvec_rdata.zero0,
                                                        submode: mtvec_rdata.submode,
                                                        mode:    csr_mtvec_init_i ? mtvec_rdata.mode : mtvec_mode_clint_resolve(mtvec_rdata.mode, csr_wdata_int[MTVEC_MODE_BIT_HIGH:MTVEC_MODE_BIT_LOW])
                                                      },
                                                CSR_BASIC_MTVEC_MASK, MTVEC_BASIC_RESET_VAL);
      mtvec_we                 = csr_mtvec_init_i;

      mtvt_n                   = '0;
      mtvt_we                  = 1'b0;

      mnxti_we                 = 1'b0;

      mintstatus_n             = '0;
      mintstatus_we            = 1'b0;

      mintthresh_n             = '0;
      mintthresh_we            = 1'b0;

      mscratchcswl_n           = '0;
      mscratchcswl_we          = 1'b0;

      mie_n                    = csr_next_value(csr_wdata_int, IRQ_MASK, MIE_BASIC_RESET_VAL);
      mie_we                   = 1'b0;

      mip_n                    = mip_rdata; // Read only;
      mip_we                   = 1'b0;

      mcause_n                 = csr_next_value(mcause_t'{
                                                          irq:            csr_wdata_int[31],
                                                          exception_code: csr_wdata_int[10:0],
                                                          default:        'b0
                                                        },
                                                        CSR_BASIC_MCAUSE_MASK, MCAUSE_BASIC_RESET_VAL);
      mcause_we                = 1'b0;
      mcause_alias_we          = 1'b0;
    end

    mtval_n         = mtval_rdata;                // Read-only
    mtval_we        = 1'b0;

    // Read-only CSRS
    mhartid_n       = mhartid_rdata;              // Read-only
    mhartid_we      = 1'b0;                       // Always 0

    mimpid_n        = mimpid_rdata;               // Read-only
    mimpid_we       = 1'b0;                       // Always 0

    mconfigptr_n    = mconfigptr_rdata;           // Read-only
    mconfigptr_we   = 1'b0;                       // Always 0

    mvendorid_n     = mvendorid_rdata;            // Read-only
    mvendorid_we    = 1'b0;                       // Always 0

    marchid_n       = marchid_rdata;              // Read-only
    marchid_we      = 1'b0;                       // Always 0

    if (csr_we_int) begin
      case (csr_waddr)

        // jvt: Jump vector table
        CSR_JVT: begin
          if (ZC_EXT) begin
            jvt_we = 1'b1;
          end
        end

        // mstatus
        CSR_MSTATUS: begin
          mstatus_we = 1'b1;
          // CLIC mode is assumed when CLIC = 1
          // For CLIC, a write to mstatus.mpp or mstatus.mpie will write to the
          // corresponding bits in mstatus as well.
          if (CLIC) begin
            mcause_alias_we = 1'b1;
          end
        end

        CSR_MISA: begin
          misa_we = 1'b1;
        end

        // mie: machine interrupt enable
        CSR_MIE: begin
          mie_we = 1'b1;
        end

        // mtvec: machine trap-handler base address
        CSR_MTVEC: begin
          mtvec_we = 1'b1;
        end

        // mtvt: machine trap-handler vector table base address
        CSR_MTVT: begin
          if (CLIC) begin
            mtvt_we = 1'b1;
          end
        end

        CSR_MSTATUSH: begin
          mstatush_we = 1'b1;
        end

        // mscratch: machine scratch
        CSR_MSCRATCH: begin
          mscratch_we = 1'b1;
        end

        // mepc: exception program counter
        CSR_MEPC: begin
          mepc_we = 1'b1;
        end

        // mcause
        CSR_MCAUSE: begin
          mcause_we = 1'b1;
          // CLIC mode is assumed when CLIC = 1
          // For CLIC, a write to mcause.mpp or mcause.mpie will write to the
          // corresponding bits in mstatus as well.
          if (CLIC) begin
            mstatus_alias_we = 1'b1;
          end
        end

        CSR_MTVAL: begin
          mtval_we = 1'b1;
        end

        // mip: machine interrupt pending
        CSR_MIP: begin
          mip_we = 1'b1;
        end

        CSR_MNXTI: begin
          if (CLIC) begin
            mnxti_we = 1'b1;

            // Writes to mnxti also writes to mstatus (uses mstatus in the RMW operation)
            // Also writing to mcause to ensure we can assert mstatus_we == mcause_we and similar for mpp/mpie.
            mstatus_we = 1'b1;
            mcause_we  = 1'b1;

            // Writes to mintstatus.mil and mcause depend on the current state of
            // clic interrupts AND the type of CSR instruction used.
            // Mcause is written unconditionally for aliasing purposes, but the mcause_n
            // is modified to reflect the side effects in case mnxti_irq_pending_i i set.
            // Side effects occur when there is an actual write to the mstatus CSR
            // This is already coded into the csr_we_int/mnxti_we
            if (mnxti_irq_pending_i) begin
              mintstatus_we = 1'b1;
            end
          end
        end

        CSR_MINTTHRESH: begin
          if (CLIC) begin
            mintthresh_we = 1'b1;
          end
        end

        CSR_MSCRATCHCSWL: begin
          if (CLIC) begin
            // mscratchcswl operates on mscratch
            if ((mcause_rdata.mpil == '0) != (mintstatus_rdata.mil == '0)) begin
              mscratchcswl_we = 1'b1;
              mscratch_we     = 1'b1;
            end
          end
        end

        CSR_TSELECT: begin
          tselect_we = 1'b1;
        end

        CSR_TDATA1: begin
          if (ctrl_fsm_i.debug_mode) begin
            tdata1_we = 1'b1;
          end
        end

        CSR_TDATA2: begin
          if (ctrl_fsm_i.debug_mode) begin
            tdata2_we = 1'b1;
          end
        end

        CSR_TINFO: begin
          tinfo_we = 1'b1;
        end

        CSR_DCSR: begin
          dcsr_we = 1'b1;
        end

        CSR_DPC: begin
          dpc_we = 1'b1;
        end

        CSR_DSCRATCH0: begin
          dscratch0_we = 1'b1;
        end

        CSR_DSCRATCH1: begin
           dscratch1_we = 1'b1;
        end
        default:;
      endcase
    end

    // CSR side effects from other CSRs

    // CLIC mode is assumed when CLIC = 1
    if (CLIC) begin
      if (mnxti_we) begin
        // Mstatus is written as part of an mnxti access
        // Make sure we alias the mpp/mpie to mcause
        mcause_n = mcause_rdata;
        mcause_n.mpie = mstatus_n.mpie;
        mcause_n.mpp = mstatus_n.mpp;

        // mintstatus and mcause are updated if an actual mstatus write happens and
        // a higher level non-shv interrupt is pending.
        // This is already decoded into the respective _we signals below.
        if (mintstatus_we) begin
          mintstatus_n.mil = mnxti_irq_level_i;
        end
        if (mnxti_irq_pending_i) begin
          mcause_n.irq = 1'b1;
          mcause_n.exception_code = {1'b0, 10'(mnxti_irq_id_i)};
        end
      end else if (mstatus_alias_we) begin
        // In CLIC mode, writes to mcause.mpp/mpie is aliased to mstatus.mpp/mpie
        // All other mstatus bits are preserved
        mstatus_n      = mstatus_rdata; // Preserve all fields

        // Write mpie and mpp as aliased through mcause
        mstatus_n.mpie = mcause_n.mpie;
        mstatus_n.mpp  = mcause_n.mpp;

        mstatus_we = 1'b1;
      end else if (mcause_alias_we) begin
        // In CLIC mode, writes to mstatus.mpp/mpie is aliased to mcause.mpp/mpie
        // All other mcause bits are preserved
        mcause_n = mcause_rdata;
        mcause_n.mpie = mstatus_n.mpie;
        mcause_n.mpp = mstatus_n.mpp;

        mcause_we = 1'b1;
      end
      // The CLIC pointer address should always be output for an access to MNXTI,
      // but will only contain a nonzero value if a CLIC interrupt is actually pending
      // with a higher level. The valid below will be high also for the cases where
      // no side effects occur.
      clic_pa_valid_o = csr_en_gated && (csr_waddr == CSR_MNXTI);
      clic_pa_o       = mnxti_rdata;
    end else begin
      clic_pa_valid_o = 1'b0;
      clic_pa_o       = '0;
    end

    // Exception controller gets priority over other writes
    unique case (1'b1)
      ctrl_fsm_i.csr_save_cause: begin
        if (ctrl_fsm_i.debug_csr_save) begin
          // All interrupts are masked, don't update mcause, mepc, mtval, dpc and mstatus
          // dcsr.nmip is not a flop, but comes directly from the controller
          dcsr_n         = dcsr_t'{
                                    xdebugver : dcsr_rdata.xdebugver,
                                    ebreakm   : dcsr_rdata.ebreakm,
                                    ebreaku   : dcsr_rdata.ebreaku,
                                    stepie    : dcsr_rdata.stepie,
                                    stopcount : dcsr_rdata.stopcount,
                                    mprven    : dcsr_rdata.mprven,
                                    step      : dcsr_rdata.step,
                                    prv       : priv_lvl_rdata,                 // Privilege level at time of debug entry
                                    cause     : ctrl_fsm_i.debug_cause,
                                    default   : 'd0
                                  };
          dcsr_we        = 1'b1;

          dpc_n          = ctrl_fsm_i.pipe_pc;
          dpc_we         = 1'b1;

          priv_lvl_n     = PRIV_LVL_M;  // Execute with machine mode privilege in debug mode
          priv_lvl_we    = 1'b1;
        end else begin
          priv_lvl_n     = PRIV_LVL_M;  // Trap into machine mode
          priv_lvl_we    = 1'b1;

          mstatus_n      = mstatus_rdata;
          mstatus_n.mie  = 1'b0;
          mstatus_n.mpie = mstatus_rdata.mie;
          mstatus_n.mpp  = priv_lvl_rdata;
          mstatus_we     = 1'b1;

          mepc_n         = ctrl_fsm_i.pipe_pc;
          mepc_we        = 1'b1;

          // Save relevant fields from controller to mcause
          mcause_n.irq            = ctrl_fsm_i.csr_cause.irq;
          mcause_n.exception_code = ctrl_fsm_i.csr_cause.exception_code;


          mcause_we = 1'b1;


          if (CLIC) begin
            // mpil is saved from mintstatus
            mcause_n.mpil = mintstatus_rdata.mil;

            // Save minhv from controller
            mcause_n.minhv          = ctrl_fsm_i.csr_cause.minhv;
            // Save aliased values for mpp and mpie
            mcause_n.mpp            = mstatus_n.mpp;
            mcause_n.mpie           = mstatus_n.mpie;

            // Save new interrupt level to mintstatus
            // Horizontal synchronous exception traps do not change the interrupt level.
            // Vertical synchronous exception traps to higher privilege level use interrupt level 0.
            // All exceptions are taken in PRIV_LVL_M, so checking that we get a different privilege level is sufficient for clearing
            // mintstatus.mil.
            if (ctrl_fsm_i.csr_cause.irq) begin
              mintstatus_n.mil = ctrl_fsm_i.irq_level;
              mintstatus_we = 1'b1;
            end else if ((priv_lvl_rdata != priv_lvl_n)) begin
              mintstatus_n.mil = '0;
              mintstatus_we = 1'b1;
            end
          end else begin
            mcause_n.mpil = '0;
          end
        end
      end //ctrl_fsm_i.csr_save_cause

      ctrl_fsm_i.csr_restore_mret: begin // MRET
        priv_lvl_n     = privlvl_t'(mstatus_rdata.mpp);
        priv_lvl_we    = 1'b1;

        mstatus_n      = mstatus_rdata;
        mstatus_n.mie  = mstatus_rdata.mpie;
        mstatus_n.mpie = 1'b1;
        mstatus_n.mpp  = PRIV_LVL_LOWEST;
        mstatus_we     = 1'b1;

        if (CLIC) begin
          mintstatus_n.mil = mcause_rdata.mpil;
          mintstatus_we = 1'b1;

          // Save aliased values for mpp and mpie
          mcause_n = mcause_rdata;
          mcause_n.mpp = mstatus_n.mpp;
          mcause_n.mpie = mstatus_n.mpie;
          mcause_we = 1'b1;

          // Mret to lower privilege mode clear mintthresh
          if (priv_lvl_n < PRIV_LVL_M) begin
            mintthresh_n  = 32'h00000000;
            mintthresh_we = 1'b1;
          end
        end
      end //ctrl_fsm_i.csr_restore_mret

      ctrl_fsm_i.csr_restore_dret: begin // DRET
        // Restore to the recorded privilege level
        priv_lvl_n = dcsr_rdata.prv;
        priv_lvl_we = 1'b1;

        // Section 4.6 of debug spec: If the new privilege mode is less privileged than M-mode, MPRV in mstatus is cleared.
        mstatus_n      = mstatus_rdata;
        mstatus_n.mprv = (privlvl_t'(dcsr_rdata.prv) == PRIV_LVL_M) ? mstatus_rdata.mprv : 1'b0;
        mstatus_we     = 1'b1;

        if (CLIC) begin
          // Not really needed, but allows for asserting mstatus_we == mcause_we to check aliasing formally
          mcause_n       = mcause_rdata;
          mcause_we      = 1'b1;

          // Dret to lower privilege mode does not clear mintthresh
        end

      end //ctrl_fsm_i.csr_restore_dret

      default:;
    endcase

  end

  // Mirroring mstatus_n to mnxti_n for RVFI
  assign mnxti_n = mstatus_n;

  // CSR operation logic
  // Using ex_wb_pipe_i.rf_wdata for read-modify-write since CSR was read in EX, written in WB
  always_comb
  begin
    if(!csr_en_gated) begin
      csr_wdata_int = csr_wdata;
      csr_we_int    = 1'b0;
    end else begin
      csr_we_int    = 1'b1;
      csr_wdata_int = csr_wdata;
      case (csr_op)
        CSR_OP_WRITE: csr_wdata_int = csr_wdata;
        CSR_OP_SET:   csr_wdata_int = csr_wdata | ex_wb_pipe_i.rf_wdata;
        CSR_OP_CLEAR: csr_wdata_int = (~csr_wdata) & ex_wb_pipe_i.rf_wdata;

        CSR_OP_READ: begin
          csr_wdata_int = csr_wdata;
          csr_we_int    = 1'b0;
        end
        default:;
      endcase
    end
  end

  ////////////////////////////////////////////////////////////////////////
  //
  // CSR instances

  cv32e40x_csr
  #(
    .WIDTH      (32            ),
    .MASK       (CSR_JVT_MASK  ),
    .RESETVALUE (JVT_RESET_VAL )
  )
  jvt_csr_i
  (
    .clk                ( clk                   ),
    .rst_n              ( rst_n                 ),
    .wr_data_i          ( jvt_n                 ),
    .wr_en_i            ( jvt_we                ),
    .rd_data_o          ( jvt_q                 )
  );

  generate
    if (DEBUG) begin : gen_debug_csr
      cv32e40x_csr
      #(
        .WIDTH      (32                 ),
        .MASK       (CSR_DSCRATCH0_MASK ),
        .RESETVALUE (DSCRATCH0_RESET_VAL)
      )
      dscratch0_csr_i
      (
        .clk                ( clk                   ),
        .rst_n              ( rst_n                 ),
        .wr_data_i          ( dscratch0_n           ),
        .wr_en_i            ( dscratch0_we          ),
        .rd_data_o          ( dscratch0_q           )
      );

      cv32e40x_csr
      #(
        .WIDTH      (32                 ),
        .MASK       (CSR_DSCRATCH1_MASK ),
        .RESETVALUE (DSCRATCH1_RESET_VAL)
      )
      dscratch1_csr_i
      (
        .clk                ( clk                   ),
        .rst_n              ( rst_n                 ),
        .wr_data_i          ( dscratch1_n           ),
        .wr_en_i            ( dscratch1_we          ),
        .rd_data_o          ( dscratch1_q           )
      );

      cv32e40x_csr
      #(
        .WIDTH      (32            ),
        .MASK       (CSR_DCSR_MASK ),
        .RESETVALUE (DCSR_RESET_VAL)
      )
      dcsr_csr_i
      (
        .clk                ( clk                   ),
        .rst_n              ( rst_n                 ),
        .wr_data_i          ( dcsr_n                ),
        .wr_en_i            ( dcsr_we               ),
        .rd_data_o          ( dcsr_q                )
      );

      cv32e40x_csr
      #(
        .WIDTH      (32           ),
        .MASK       (CSR_DPC_MASK ),
        .RESETVALUE (DPC_RESET_VAL)
      )
      dpc_csr_i
      (
        .clk                ( clk                   ),
        .rst_n              ( rst_n                 ),
        .wr_data_i          ( dpc_n                 ),
        .wr_en_i            ( dpc_we                ),
        .rd_data_o          ( dpc_q                 )
      );
    end else begin : debug_csr_tieoff
        assign dscratch0_q = 32'h0;
        assign dscratch1_q = 32'h0;
        assign dpc_q       = 32'h0;
        assign dcsr_q      = 32'h0;
    end
  endgenerate

  cv32e40x_csr
  #(
    .WIDTH      (32            ),
    .MASK       (CSR_MEPC_MASK ),
    .RESETVALUE (MEPC_RESET_VAL)
  )
  mepc_csr_i
  (
    .clk                ( clk                   ),
    .rst_n              ( rst_n                 ),
    .wr_data_i          ( mepc_n                ),
    .wr_en_i            ( mepc_we               ),
    .rd_data_o          ( mepc_q                )
  );

  cv32e40x_csr
  #(
    .WIDTH      (32                ),
    .MASK       (CSR_MSCRATCH_MASK ),
    .RESETVALUE (MSCRATCH_RESET_VAL)
  )
  mscratch_csr_i
  (
    .clk                ( clk                   ),
    .rst_n              ( rst_n                 ),
    .wr_data_i          ( mscratch_n            ),
    .wr_en_i            ( mscratch_we           ),
    .rd_data_o          ( mscratch_q            )
  );

  cv32e40x_csr
  #(
    .WIDTH      (32               ),
    .MASK       (CSR_MSTATUS_MASK ),
    .RESETVALUE (MSTATUS_RESET_VAL)
  )
  mstatus_csr_i
  (
    .clk                ( clk                   ),
    .rst_n              ( rst_n                 ),
    .wr_data_i          ( mstatus_n             ),
    .wr_en_i            ( mstatus_we            ),
    .rd_data_o          ( mstatus_q             )
  );



  generate
    if (CLIC) begin : clic_csrs

      assign mie_q = 32'h0;                                                     // CLIC mode is assumed when CLIC = 1

      cv32e40x_csr
      #(
        .WIDTH      (32                   ),
        .MASK       (CSR_CLIC_MCAUSE_MASK ),
        .RESETVALUE (MCAUSE_CLIC_RESET_VAL)
      )
      mcause_csr_i (
        .clk                ( clk                   ),
        .rst_n              ( rst_n                 ),
        .wr_data_i          ( mcause_n              ),
        .wr_en_i            ( mcause_we             ),
        .rd_data_o          ( mcause_q              )
      );

      cv32e40x_csr
      #(
        .WIDTH      (32),
        .MASK       (CSR_CLIC_MTVEC_MASK ),
        .RESETVALUE (MTVEC_CLIC_RESET_VAL)
      )
      mtvec_csr_i
      (
        .clk            ( clk                   ),
        .rst_n          ( rst_n                 ),
        .wr_data_i      ( mtvec_n               ),
        .wr_en_i        ( mtvec_we              ),
        .rd_data_o      ( mtvec_q               )
      );

      cv32e40x_csr
      #(
        .WIDTH      (32            ),
        .MASK       (CSR_MTVT_MASK ),
        .RESETVALUE (MTVT_RESET_VAL)
      )
      mtvt_csr_i
      (
        .clk            ( clk                   ),
        .rst_n          ( rst_n                 ),
        .wr_data_i      ( mtvt_n                ),
        .wr_en_i        ( mtvt_we               ),
        .rd_data_o      ( mtvt_q                )
      );

      cv32e40x_csr
      #(
        .WIDTH      (32                  ),
        .MASK       (CSR_MINTSTATUS_MASK ),
        .RESETVALUE (MINTSTATUS_RESET_VAL)
      )
      mintstatus_csr_i
      (
        .clk            ( clk                   ),
        .rst_n          ( rst_n                 ),
        .wr_data_i      ( mintstatus_n          ),
        .wr_en_i        ( mintstatus_we         ),
        .rd_data_o      ( mintstatus_q          )
      );

      cv32e40x_csr
      #(
        .WIDTH      (32                  ),
        .MASK       (CSR_MINTTHRESH_MASK ),
        .RESETVALUE (MINTTHRESH_RESET_VAL)
      )
      mintthresh_csr_i
      (
        .clk            ( clk                   ),
        .rst_n          ( rst_n                 ),
        .wr_data_i      ( mintthresh_n          ),
        .wr_en_i        ( mintthresh_we         ),
        .rd_data_o      ( mintthresh_q          )
      );

      logic unused_clic_signals;
      assign unused_clic_signals = mie_we | (|mie_n);

    end else begin : basic_mode_csrs

      cv32e40x_csr
      #(
        .WIDTH      (32),
        .MASK       (CSR_BASIC_MCAUSE_MASK ),
        .RESETVALUE (MCAUSE_BASIC_RESET_VAL)
      )
      mcause_csr_i (
        .clk                ( clk                   ),
        .rst_n              ( rst_n                 ),
        .wr_data_i          ( mcause_n              ),
        .wr_en_i            ( mcause_we             ),
        .rd_data_o          ( mcause_q              )
      );

      cv32e40x_csr
      #(
        .WIDTH      (32                   ),
        .MASK       (CSR_BASIC_MTVEC_MASK ),
        .RESETVALUE (MTVEC_BASIC_RESET_VAL)
      )
      mtvec_csr_i
      (
        .clk            ( clk                   ),
        .rst_n          ( rst_n                 ),
        .wr_data_i      ( mtvec_n               ),
        .wr_en_i        ( mtvec_we              ),
        .rd_data_o      ( mtvec_q               )
      );

      cv32e40x_csr
      #(
        .WIDTH      (32                 ),
        .MASK       (IRQ_MASK           ),
        .RESETVALUE (MIE_BASIC_RESET_VAL)
      )
      mie_csr_i
      (
        .clk            ( clk                   ),
        .rst_n          ( rst_n                 ),
        .wr_data_i      ( mie_n                 ),
        .wr_en_i        ( mie_we                ),
        .rd_data_o      ( mie_q                 )
      );

      assign mtvt_q              = 32'h0;

      assign mintstatus_q        = 32'h0;

      assign mintthresh_q        = 32'h0;

    end
  endgenerate

  ////////////////////////////////////////////////////////////////////////
  //
  // CSR rdata

  assign jvt_rdata          = jvt_q;
  assign dscratch0_rdata    = dscratch0_q;
  assign dscratch1_rdata    = dscratch1_q;
  assign dpc_rdata          = dpc_q;
  assign mepc_rdata         = mepc_q;
  assign mscratch_rdata     = mscratch_q;
  assign mstatus_rdata      = mstatus_q;
  assign mtvec_rdata        = mtvec_q;
  assign mtvt_rdata         = mtvt_q;
  assign mintstatus_rdata   = mintstatus_q;
  assign mie_rdata          = mie_q;

  assign mintthresh_rdata   = mintthresh_q;

  // mnxti_rdata breaks the regular convension for CSRs. The read data used for read-modify-write is the mstatus_rdata,
  // while the value read and written back to the GPR is a pointer address if an interrupt is pending, or zero
  // if no interrupt is pending.
  assign mnxti_rdata        = mnxti_irq_pending_i ? {mtvt_addr_o, mnxti_irq_id, 2'b00} : 32'h00000000;

  // mscratchcswl_rdata breaks the regular convension for CSrs. Read data depend on mcause.pil and mintstatus.mil.
  // This signal is only used by RVFI, and has WB timing (rs1 comes from ex_wb_pipe_i.csr_wdata, flopped version of id_ex_pipe.alu_operand_a)
  assign mscratchcswl_rdata = ((mcause_rdata.mpil == '0) != (mintstatus_rdata.mil == 0)) ? mscratch_rdata : ex_wb_pipe_i.csr_wdata;

  assign mip_rdata          = mip_i;
  assign misa_rdata         = MISA_VALUE;
  assign mstatush_rdata     = 32'h0;
  assign mtval_rdata        = 32'h0;
  assign mvendorid_rdata    = {MVENDORID_BANK, MVENDORID_OFFSET};
  assign marchid_rdata      = MARCHID;
  assign mimpid_rdata       = {12'b0, MIMPID_MAJOR, 4'b0, MIMPID_MINOR, 4'b0, mimpid_patch_i};
  assign mhartid_rdata      = mhartid_i;
  assign mconfigptr_rdata   = 32'h0;

  // Only machine mode is supported
  assign priv_lvl_rdata     = priv_lvl_q;
  assign priv_lvl_q         = PRIV_LVL_M;
  assign priv_lvl_lsu_o     = PRIV_LVL_M;
  assign priv_lvl_if_ctrl_o.priv_lvl     = PRIV_LVL_M;
  assign priv_lvl_if_ctrl_o.priv_lvl_set = 1'b0;

  // dcsr_rdata factors in the flop outputs and the nmip bit from the controller
  assign dcsr_rdata = DEBUG ? {dcsr_q[31:4], ctrl_fsm_i.pending_nmi, dcsr_q[2:0]} : 32'h0;


  assign mcause_rdata = mcause_q;


  assign csr_rdata_o = csr_rdata_int;

  // Any CSR write in WB
  assign csr_wr_in_wb = ex_wb_pipe_i.csr_en &&
                        ex_wb_pipe_i.instr_valid &&
                        ((csr_op == CSR_OP_WRITE) ||
                         (csr_op == CSR_OP_SET)   ||
                         (csr_op == CSR_OP_CLEAR));

  // Detect when a JVT write is in WB
  assign jvt_wr_in_wb = csr_wr_in_wb && (csr_waddr == CSR_JVT);

  // Output to controller to request pipeline flush
  assign csr_wr_in_wb_flush_o = jvt_wr_in_wb;

  // Signal when an interrupt may become enabled due to a CSR write
  generate
    if (CLIC) begin : clic_irq_en
      assign csr_irq_enable_write_o = mstatus_we || priv_lvl_we || mintthresh_we || mintstatus_we;
    end else begin : basic_irq_en
      assign csr_irq_enable_write_o = mie_we || mstatus_we || priv_lvl_we;
    end
  endgenerate

  // Set signals for explicit CSR hazard detection
  // Conservative expl_re_ex, based on flopped instr_valid and not the local version factoring in halt/kill.
  // May cause a false positive while EX stage is either halted or killed. When halted the instruction in EX would
  // not propagate at all, regardless of any hazard raised. When killed the stage is flushed and there is no penalty
  // added from the conservative stall.
  // Avoiding halt/kill also avoids combinatorial lopps via the controller_fsm as a CSR hazard may lead to halt_ex being asserted.
  assign csr_hz_o.expl_re_ex = id_ex_pipe_i.csr_en && id_ex_pipe_i.instr_valid;
  assign csr_hz_o.expl_raddr_ex = csr_raddr;

  // Conservative expl_we_wb, based on flopped instr_valid and not the local version factoring in halt/kill.
  // May cause false positives when a CSR instruction in WB is halted or killed. When WB is halted, the backpressure of the pipeline
  // causes no instructions to propagate down the pipeline. Thus a false positive will not give any cycle penalties.
  // When WB is killed, the full pipeline is also killed and any stalls due to a false positive will not have any effect.
  // Same remark about combinatorial loops as for the expl_re_ex above.
  assign csr_hz_o.expl_we_wb = ex_wb_pipe_i.csr_en && ex_wb_pipe_i.instr_valid && (csr_op != CSR_OP_READ);
  assign csr_hz_o.expl_waddr_wb = csr_waddr;
  ////////////////////////////////////////////////////////////////////////
  //
  // CSR outputs

  assign dcsr_o        = dcsr_rdata;
  assign dpc_o         = dpc_rdata;
  assign jvt_addr_o    = jvt_rdata.base[31:32-JVT_ADDR_WIDTH];
  assign jvt_mode_o    = jvt_rdata.mode;
  assign mcause_o      = mcause_rdata;
  assign mcycle_o      = mhpmcounter_rdata[0];
  assign mepc_o        = mepc_rdata;
  assign mie_o         = mie_rdata;
  assign mintstatus_o  = mintstatus_rdata;
  assign mintthresh_th_o  = mintthresh_rdata[7:0];
  assign mstatus_o     = mstatus_rdata;
  assign mtvec_addr_o  = mtvec_rdata.addr;
  assign mtvec_mode_o  = mtvec_rdata.mode;
  assign mtvt_addr_o   = mtvt_rdata.addr[31:(32-MTVT_ADDR_WIDTH)];

  assign priv_lvl_o    = priv_lvl_rdata;

  ////////////////////////////////////////////////////////////////////////
  //  ____       _                   _____     _                        //
  // |  _ \  ___| |__  _   _  __ _  |_   _| __(_) __ _  __ _  ___ _ __  //
  // | | | |/ _ \ '_ \| | | |/ _` |   | || '__| |/ _` |/ _` |/ _ \ '__| //
  // | |_| |  __/ |_) | |_| | (_| |   | || |  | | (_| | (_| |  __/ |    //
  // |____/ \___|_.__/ \__,_|\__, |   |_||_|  |_|\__, |\__, |\___|_|    //
  //                         |___/               |___/ |___/            //
  ////////////////////////////////////////////////////////////////////////

  // When DEBUG==0, DBG_NUM_TRIGGERS is assumed to be 0 as well.
  cv32e40x_debug_triggers
    #(
        .DBG_NUM_TRIGGERS (DBG_NUM_TRIGGERS),
        .A_EXT            (A_EXT)
    )
    debug_triggers_i
    (
      .clk                 ( clk                   ),
      .rst_n               ( rst_n                 ),

      // CSR inputs write inputs
      .csr_wdata_i         ( csr_wdata_int         ),
      .tselect_we_i        ( tselect_we            ),
      .tdata1_we_i         ( tdata1_we             ),
      .tdata2_we_i         ( tdata2_we             ),
      .tinfo_we_i          ( tinfo_we              ),

      // CSR read data outputs
      .tselect_rdata_o     ( tselect_rdata         ),
      .tdata1_rdata_o      ( tdata1_rdata          ),
      .tdata2_rdata_o      ( tdata2_rdata          ),
      .tinfo_rdata_o       ( tinfo_rdata           ),

      // IF stage inputs
      .pc_if_i             ( pc_if_i               ),
      .ptr_in_if_i         ( ptr_in_if_i           ),
      .priv_lvl_if_i       ( priv_lvl_if_i         ),

      // LSU inputs
      .lsu_valid_ex_i      ( lsu_valid_ex_i        ),
      .lsu_addr_ex_i       ( lsu_addr_ex_i         ),
      .lsu_we_ex_i         ( lsu_we_ex_i           ),
      .lsu_be_ex_i         ( lsu_be_ex_i           ),
      .priv_lvl_ex_i       ( id_ex_pipe_i.priv_lvl ),
      .lsu_atomic_ex_i     ( lsu_atomic_ex_i       ),

      // WB inputs
      .priv_lvl_wb_i       ( ex_wb_pipe_i.priv_lvl ),

      // Controller inputs
      .ctrl_fsm_i          ( ctrl_fsm_i            ),

      // Trigger match outputs
      .trigger_match_if_o  ( trigger_match_if_o    ),
      .trigger_match_ex_o  ( trigger_match_ex_o    ),
      .etrigger_wb_o       ( etrigger_wb_o         )
    );



  /////////////////////////////////////////////////////////////////
  //   ____            __     ____                  _            //
  // |  _ \ ___ _ __ / _|   / ___|___  _   _ _ __ | |_ ___ _ __  //
  // | |_) / _ \ '__| |_   | |   / _ \| | | | '_ \| __/ _ \ '__| //
  // |  __/  __/ |  |  _|  | |__| (_) | |_| | | | | ||  __/ |    //
  // |_|   \___|_|  |_|(_)  \____\___/ \__,_|_| |_|\__\___|_|    //
  //                                                             //
  /////////////////////////////////////////////////////////////////

  // Flop certain events to ease timing
  localparam bit [15:0] HPM_EVENT_FLOP     = 16'b1111_1111_1100_0000;

  // Calculate mask for MHPMCOUNTERS depending on how many that are implemented.
  localparam bit [28:0] MHPMCOUNTERS_MASK = (2 ** NUM_MHPMCOUNTERS) -1;
  // Set mask for mcountinhibit, include always included counters for mcycle and minstret.
  localparam bit [31:0] MCOUNTINHIBIT_MASK = (MHPMCOUNTERS_MASK << 3) | 3'b101;


  logic [15:0]          hpm_events_raw;
  logic                 all_counters_disabled;
  logic                 debug_stopcount;

  assign all_counters_disabled = &(mcountinhibit_n | ~MCOUNTINHIBIT_MASK);

  // dcsr.stopcount == 1: Don’t increment any counters while in Debug Mode.
  // The debug spec states that we should also not increment counters "on ebreak instructions that cause entry into debug mode",
  // but this implementation does not take ebreak instructions into account.
  // This is considered OK since most counter events (except wb_invalid and cycle) will be suppressed (in ctrl_fsm_i.mhpmevent) when we
  // have an ebreak causing debug mode entry in WB.
  assign debug_stopcount = dcsr_rdata.stopcount && ctrl_fsm_i.debug_mode;

  genvar                hpm_idx;
  generate
    for(hpm_idx=0; hpm_idx<16; hpm_idx++) begin
      if(HPM_EVENT_FLOP[hpm_idx]) begin: hpm_event_flop

        always_ff @(posedge clk, negedge rst_n) begin
          if (rst_n == 1'b0) begin
            hpm_events[hpm_idx] <= 1'b0;
          end else begin
            if(!all_counters_disabled) begin
              hpm_events[hpm_idx] <= hpm_events_raw[hpm_idx];
            end
          end
        end

      end
      else begin: hpm_even_no_flop
        assign hpm_events[hpm_idx] = hpm_events_raw[hpm_idx];
      end
    end
  endgenerate

  // ------------------------
  // Events to count
  assign hpm_events_raw[0]  = 1'b1;                               // Cycle counter
  assign hpm_events_raw[1]  = ctrl_fsm_i.mhpmevent.minstret;      // Instruction counter
  assign hpm_events_raw[2]  = ctrl_fsm_i.mhpmevent.compressed;    // Compressed instruction counter
  assign hpm_events_raw[3]  = ctrl_fsm_i.mhpmevent.jump;          // Nr of jumps (unconditional)
  assign hpm_events_raw[4]  = ctrl_fsm_i.mhpmevent.branch;        // Nr of branches (conditional)
  assign hpm_events_raw[5]  = ctrl_fsm_i.mhpmevent.branch_taken;  // Nr of taken branches (conditional)
  assign hpm_events_raw[6]  = ctrl_fsm_i.mhpmevent.intr_taken;    // Nr of interrupts taken (excluding NMI)
  assign hpm_events_raw[7]  = ctrl_fsm_i.mhpmevent.data_read;     // Data read. Nr of read transactions on the OBI data interface
  assign hpm_events_raw[8]  = ctrl_fsm_i.mhpmevent.data_write;    // Data write. Nr of write transactions on the OBI data interface
  assign hpm_events_raw[9]  = ctrl_fsm_i.mhpmevent.if_invalid;    // IF invalid (No valid output from IF when ID stage is ready)
  assign hpm_events_raw[10] = ctrl_fsm_i.mhpmevent.id_invalid;    // ID invalid (No valid output from ID when EX stage is ready)
  assign hpm_events_raw[11] = ctrl_fsm_i.mhpmevent.ex_invalid;    // EX invalid (No valid output from EX when WB stage is ready)
  assign hpm_events_raw[12] = ctrl_fsm_i.mhpmevent.wb_invalid;    // WB invalid (No valid output from WB)
  assign hpm_events_raw[13] = ctrl_fsm_i.mhpmevent.id_ld_stall;   // Nr of load use hazards
  assign hpm_events_raw[14] = ctrl_fsm_i.mhpmevent.id_jalr_stall; // Nr of jump (and link) register hazards
  assign hpm_events_raw[15] = ctrl_fsm_i.mhpmevent.wb_data_stall; // Nr of stall cycles caused in the WB stage by loads/stores

  // ------------------------
  // address decoder for performance counter registers
  logic mcountinhibit_we;
  logic mhpmevent_we;

  assign mcountinhibit_we = csr_we_int & (  csr_waddr == CSR_MCOUNTINHIBIT);
  assign mhpmevent_we     = csr_we_int & ( (csr_waddr == CSR_MHPMEVENT3  )||
                                           (csr_waddr == CSR_MHPMEVENT4  ) ||
                                           (csr_waddr == CSR_MHPMEVENT5  ) ||
                                           (csr_waddr == CSR_MHPMEVENT6  ) ||
                                           (csr_waddr == CSR_MHPMEVENT7  ) ||
                                           (csr_waddr == CSR_MHPMEVENT8  ) ||
                                           (csr_waddr == CSR_MHPMEVENT9  ) ||
                                           (csr_waddr == CSR_MHPMEVENT10 ) ||
                                           (csr_waddr == CSR_MHPMEVENT11 ) ||
                                           (csr_waddr == CSR_MHPMEVENT12 ) ||
                                           (csr_waddr == CSR_MHPMEVENT13 ) ||
                                           (csr_waddr == CSR_MHPMEVENT14 ) ||
                                           (csr_waddr == CSR_MHPMEVENT15 ) ||
                                           (csr_waddr == CSR_MHPMEVENT16 ) ||
                                           (csr_waddr == CSR_MHPMEVENT17 ) ||
                                           (csr_waddr == CSR_MHPMEVENT18 ) ||
                                           (csr_waddr == CSR_MHPMEVENT19 ) ||
                                           (csr_waddr == CSR_MHPMEVENT20 ) ||
                                           (csr_waddr == CSR_MHPMEVENT21 ) ||
                                           (csr_waddr == CSR_MHPMEVENT22 ) ||
                                           (csr_waddr == CSR_MHPMEVENT23 ) ||
                                           (csr_waddr == CSR_MHPMEVENT24 ) ||
                                           (csr_waddr == CSR_MHPMEVENT25 ) ||
                                           (csr_waddr == CSR_MHPMEVENT26 ) ||
                                           (csr_waddr == CSR_MHPMEVENT27 ) ||
                                           (csr_waddr == CSR_MHPMEVENT28 ) ||
                                           (csr_waddr == CSR_MHPMEVENT29 ) ||
                                           (csr_waddr == CSR_MHPMEVENT30 ) ||
                                           (csr_waddr == CSR_MHPMEVENT31 ) );

  // ------------------------
  // Increment value for performance counters
  genvar incr_gidx;
  generate
    for (incr_gidx=0; incr_gidx<32; incr_gidx++) begin : gen_mhpmcounter_increment
      assign mhpmcounter_increment[incr_gidx] = mhpmcounter_rdata[incr_gidx] + 1;
    end
  endgenerate

  // ------------------------
  // next value for performance counters and control registers
  always_comb
    begin
      mcountinhibit_n = mcountinhibit_rdata;
      mhpmevent_n     = mhpmevent_rdata;


      // Inhibit Control
      if(mcountinhibit_we)
        mcountinhibit_n = csr_wdata_int & MCOUNTINHIBIT_MASK;

      // Event Control
      if(mhpmevent_we)
        mhpmevent_n[csr_waddr[4:0]] = csr_wdata_int;
    end

  genvar wcnt_gidx;
  generate
    for (wcnt_gidx=0; wcnt_gidx<32; wcnt_gidx++) begin : gen_mhpmcounter_write

      // Write lower counter bits
      assign mhpmcounter_write_lower[wcnt_gidx] = csr_we_int && (csr_waddr == (CSR_MCYCLE + wcnt_gidx));

      // Write upper counter bits
      assign mhpmcounter_write_upper[wcnt_gidx] = !mhpmcounter_write_lower[wcnt_gidx] &&
                                                  csr_we_int && (csr_waddr == (CSR_MCYCLEH + wcnt_gidx));

      // Increment counter

      if (wcnt_gidx == 0) begin : gen_mhpmcounter_mcycle
        // mcycle = mhpmcounter[0] : count every cycle (if not inhibited)
        assign mhpmcounter_write_increment[wcnt_gidx] = !mhpmcounter_write_lower[wcnt_gidx] &&
                                                        !mhpmcounter_write_upper[wcnt_gidx] &&
                                                        !mcountinhibit_rdata[wcnt_gidx] &&
                                                        !debug_stopcount;
      end else if (wcnt_gidx == 2) begin : gen_mhpmcounter_minstret
        // minstret = mhpmcounter[2]  : count every retired instruction (if not inhibited)
        assign mhpmcounter_write_increment[wcnt_gidx] = !mhpmcounter_write_lower[wcnt_gidx] &&
                                                        !mhpmcounter_write_upper[wcnt_gidx] &&
                                                        !mcountinhibit_rdata[wcnt_gidx] &&
                                                        !debug_stopcount &&
                                                        hpm_events[1];
      end else if( (wcnt_gidx>2) && (wcnt_gidx<(NUM_MHPMCOUNTERS+3))) begin : gen_mhpmcounter_write_increment
        // add +1 if any event is enabled and active
        assign mhpmcounter_write_increment[wcnt_gidx] = !mhpmcounter_write_lower[wcnt_gidx] &&
                                                        !mhpmcounter_write_upper[wcnt_gidx] &&
                                                        !mcountinhibit_rdata[wcnt_gidx] &&
                                                        !debug_stopcount &&
                                                        |(hpm_events & mhpmevent_rdata[wcnt_gidx][NUM_HPM_EVENTS-1:0]);
      end else begin : gen_mhpmcounter_not_implemented
        assign mhpmcounter_write_increment[wcnt_gidx] = 1'b0;
      end

    end
  endgenerate

  // ------------------------
  // HPM Registers
  // next value
  genvar nxt_gidx;
  generate
    for (nxt_gidx = 0; nxt_gidx < 32; nxt_gidx++) begin : gen_mhpmcounter_nextvalue
      // mcyclce  is located at index 0
      // there is no counter at index 1
      // minstret is located at index 2
      // Programable HPM counters start at index 3
      if( (nxt_gidx == 1) ||
          (nxt_gidx >= (NUM_MHPMCOUNTERS+3) ) )
        begin : gen_non_implemented_nextvalue
          assign mhpmcounter_n[nxt_gidx]  = 'b0;
          assign mhpmcounter_we[nxt_gidx] = 2'b0;
      end
      else begin : gen_implemented_nextvalue
        always_comb begin
          mhpmcounter_we[nxt_gidx] = 2'b0;
          mhpmcounter_n[nxt_gidx]  = mhpmcounter_rdata[nxt_gidx];
          if (mhpmcounter_write_lower[nxt_gidx]) begin
            mhpmcounter_n[nxt_gidx][31:0] = csr_wdata_int;
            mhpmcounter_we[nxt_gidx][0] = 1'b1;
          end else if (mhpmcounter_write_upper[nxt_gidx]) begin
            mhpmcounter_n[nxt_gidx][63:32] = csr_wdata_int;
            mhpmcounter_we[nxt_gidx][1] = 1'b1;
          end else if (mhpmcounter_write_increment[nxt_gidx]) begin
            mhpmcounter_we[nxt_gidx] = 2'b11;
            mhpmcounter_n[nxt_gidx] = mhpmcounter_increment[nxt_gidx];
          end
        end // always_comb
      end
    end
  endgenerate
  //  Counter Registers: mhpcounter_q[]
  genvar cnt_gidx;
  generate
    for (cnt_gidx = 0; cnt_gidx < 32; cnt_gidx++) begin : gen_mhpmcounter
      // mcyclce  is located at index 0
      // there is no counter at index 1
      // minstret is located at index 2
      // Programable HPM counters start at index 3
      if( (cnt_gidx == 1) ||
          (cnt_gidx >= (NUM_MHPMCOUNTERS+3) ) )
        begin : gen_non_implemented_mhpmcounter
        assign mhpmcounter_q[cnt_gidx] = 'b0;
      end
      else begin : gen_implemented_mhpmcounter
        always_ff @(posedge clk, negedge rst_n)
          if (!rst_n) begin
            mhpmcounter_q[cnt_gidx] <= 'b0;
          end else begin
            if (mhpmcounter_we[cnt_gidx][0]) begin
              mhpmcounter_q[cnt_gidx][31:0] <= mhpmcounter_n[cnt_gidx][31:0];
            end
            if (mhpmcounter_we[cnt_gidx][1]) begin
              mhpmcounter_q[cnt_gidx][63:32] <= mhpmcounter_n[cnt_gidx][63:32];
            end
          end
      end
      assign mhpmcounter_rdata[cnt_gidx] = mhpmcounter_q[cnt_gidx];
    end
  endgenerate

  //  Event Register: mhpevent_q[]
  genvar evt_gidx;
  generate
    for (evt_gidx = 0; evt_gidx < 32; evt_gidx++) begin : gen_mhpmevent
      // programable HPM events start at index3
      if( (evt_gidx < 3) ||
          (evt_gidx >= (NUM_MHPMCOUNTERS+3) ) )
        begin : gen_non_implemented_mhpmevent
          assign mhpmevent_q[evt_gidx] = 'b0;

          logic unused_mhpmevent_signals;
          assign unused_mhpmevent_signals = (|mhpmevent_n[evt_gidx]) | (|mhpmevent_q[evt_gidx]) | (|mhpmevent_rdata[evt_gidx]);
      end
      else begin : gen_implemented_mhpmevent
        if (NUM_HPM_EVENTS < 32) begin : gen_tie_off
             assign mhpmevent_q[evt_gidx][31:NUM_HPM_EVENTS] = 'b0;
        end
        always_ff @(posedge clk, negedge rst_n)
            if (!rst_n)
                mhpmevent_q[evt_gidx][NUM_HPM_EVENTS-1:0]  <= 'b0;
            else
                mhpmevent_q[evt_gidx][NUM_HPM_EVENTS-1:0]  <= mhpmevent_n[evt_gidx][NUM_HPM_EVENTS-1:0] ;
      end
      assign mhpmevent_rdata[evt_gidx] = mhpmevent_q[evt_gidx];
    end
  endgenerate

  //  Inhibit Register: mcountinhibit_q
  //  Note: implemented counters are disabled out of reset to save power
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      mcountinhibit_q <= MCOUNTINHIBIT_MASK; // default disable
    end else begin
      mcountinhibit_q <= mcountinhibit_n;
    end
  end

  assign mcountinhibit_rdata = mcountinhibit_q;

  // Assign values used for setting rmask in RVFI
  assign mscratchcswl_in_wb = ex_wb_pipe_i.csr_en && (csr_waddr == CSR_MSCRATCHCSWL);
  assign mnxti_in_wb        = ex_wb_pipe_i.csr_en && (csr_waddr == CSR_MNXTI);

  // Some signals are unused on purpose (typically they are used by RVFI code). Use them here for easier LINT waiving.

  assign unused_signals = mstatush_we | misa_we | mip_we | mvendorid_we |
    marchid_we | mimpid_we | mhartid_we | mconfigptr_we | mtval_we | (|mnxti_n) | mscratchcswl_we |
    (|mscratchcswl_rdata) | (|mscratchcswl_n) |mscratchcswl_in_wb | mnxti_in_wb |
    (|mtval_n) | (|mconfigptr_n) | (|mhartid_n) | (|mimpid_n) | (|marchid_n) | (|mvendorid_n) | (|mip_n) | (|misa_n) | (|mstatush_n);

endmodule







// Description:    FSM of the pipeline controller                             //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_controller_fsm import cv32e40x_pkg::*;
#(
  parameter bit          X_EXT         = 0,
  parameter bit          DEBUG         = 1,
  parameter bit          CLIC          = 0,
  parameter int unsigned CLIC_ID_WIDTH = 5,
  parameter rv32_e       RV32          = RV32I
)
(
  // Clocks and reset
  input  logic        clk,                        // Gated clock
  input  logic        rst_n,

  input  logic        fetch_enable_i,             // Start executing

  // From bypass logic
  input  ctrl_byp_t   ctrl_byp_i,

  // From IF stage
  input  logic [31:0] pc_if_i,
  input  logic        last_op_if_i,               // IF stage is handling the last operation of a sequence.
  input  logic        abort_op_if_i,              // IF stage contains an operation that will be aborted (bus error or MPU exception)

  // From ID stage
  input  if_id_pipe_t if_id_pipe_i,
  input  logic        alu_jmp_id_i,               // Jump in ID
  input  logic        sys_mret_id_i,              // mret in ID
  input  logic        alu_en_id_i,                // alu_en qualifier for jumps
  input  logic        sys_en_id_i,                // sys_en qualifier for mret
  input  logic        first_op_id_i,              // ID stage is handling the first operation of a sequence
  input  logic        last_op_id_i,               // ID stage is handling the last operation of a sequence
  input  logic        abort_op_id_i,              // ID stage contains an (to be) aborted instruction or sequence

  // From EX stage
  input  id_ex_pipe_t id_ex_pipe_i,
  input  logic        branch_decision_ex_i,       // branch decision signal from EX ALU
  input  logic        last_op_ex_i,               // EX stage contains the last operation of an instruction

  // From WB stage
  input  ex_wb_pipe_t   ex_wb_pipe_i,
  input  lsu_err_wb_t   lsu_err_wb_i,               // LSU caused bus_error in WB stage, gated with data_rvalid_i inside load_store_unit
  input  logic          last_op_wb_i,               // WB stage contains the last operation of an instruction
  input  logic          abort_op_wb_i,              // WB stage contains an (to be) aborted instruction or sequence
  input  mpu_status_e   mpu_status_wb_i,            // MPU status (WB timing)
  input  align_status_e align_status_wb_i,          // Aligned status (atomics) in WB
  input  logic [31:0]   wpt_match_wb_i,             // LSU watchpoint trigger (WB)

  // From LSU (WB)
  input  logic        data_stall_wb_i,            // WB stalled by LSU
  input  logic        lsu_valid_wb_i,             // LSU instruction in WB is valid

  input  logic        lsu_busy_i,                 // LSU is busy with outstanding transfers
  input  logic        lsu_interruptible_i,        // LSU can be interrupted

  // Interrupt Controller Signals
  input  logic        irq_wu_ctrl_i,              // Irq wakeup control
  input  logic        irq_req_ctrl_i,             // Irq request
  input  logic [9:0]  irq_id_ctrl_i,              // Irq id
  input  logic        irq_clic_shv_i,             // CLIC mode selective hardware vectoring
  input  logic [7:0]  irq_clic_level_i,           // CLIC mode current interrupt level
  input  logic [1:0]  irq_clic_priv_i,            // CLIC mode current interrupt privilege

  // Wakeup signal for WFE (from toplevel input)
  input  logic        wu_wfe_i,

  // From cs_registers
  input  logic  [1:0] mtvec_mode_i,
  input  dcsr_t       dcsr_i,
  input  mcause_t     mcause_i,
  input  mintstatus_t mintstatus_i,

  // Trigger module
  input  logic        etrigger_wb_i,              // Trigger module detected match in WB (etrigger)

  // Toplevel input
  input  logic        debug_req_i,                // External debug request

  // All controller FSM outputs
  output ctrl_fsm_t   ctrl_fsm_o,

  // CSR write strobes
  input  logic        csr_wr_in_wb_flush_i,

  // Stage valid/ready signals
  input  logic        if_valid_i,       // IF stage has valid (non-bubble) data for next stage
  input  logic        id_ready_i,       // ID stage is ready for new data
  input  logic        id_valid_i,       // ID stage has valid (non-bubble) data for next stage
  input  logic        ex_ready_i,       // EX stage is ready for new data
  input  logic        ex_valid_i,       // EX stage has valid (non-bubble) data for next stage
  input  logic        wb_ready_i,       // WB stage is ready for new data,
  input  logic        wb_valid_i,       // WB stage ha valid (non-bubble) data

  // Fencei flush handshake
  output logic        fencei_flush_req_o,
  input logic         fencei_flush_ack_i,

  // Data OBI interface monitor
  cv32e40x_if_c_obi.monitor m_c_obi_data_if,

  // eXtension interface
  cv32e40x_if_xif.cpu_commit xif_commit_if,
  input                      xif_csr_error_i
);

   // FSM state encoding
  ctrl_state_e ctrl_fsm_cs, ctrl_fsm_ns;

  // Debug state
  debug_state_e debug_fsm_cs, debug_fsm_ns;

  // Sticky version of lsu_err_wb_i
  logic nmi_pending_q;
  logic nmi_is_store_q; // 1 for store, 0 for load

  // Debug mode
  logic debug_mode_n;
  logic debug_mode_q;

  // Signals used for halting IF after first instruction
  // during single step
  logic single_step_halt_if_n;
  logic single_step_halt_if_q; // Halting IF after issuing one insn in single step mode

  // ID signals
  logic sys_mret_id;             // MRET in ID
  logic jmp_id;                  // JAL, JALR in ID
  logic jump_in_id;
  logic jump_taken_id;
  logic clic_ptr_in_id; // CLIC pointer in ID
  logic mret_ptr_in_id; // mret pointer in ID

  // EX signals
  logic branch_in_ex;
  logic branch_taken_ex;

  logic branch_taken_n;
  logic branch_taken_q;
  logic clic_ptr_in_ex;

  // WB signals
  logic exception_in_wb;
  logic [10:0] exception_cause_wb;
  logic wfi_in_wb;
  logic wfe_in_wb;
  logic fencei_in_wb;
  logic fence_in_wb;
  logic mret_in_wb;
  logic mret_ptr_in_wb; // CLIC pointer caused by mret is in WB
  logic dret_in_wb;
  logic ebreak_in_wb;
  logic trigger_match_in_wb;   // mcontrol2/6 trigger in WB
  logic etrigger_in_wb;        // exception trigger in WB
  logic xif_in_wb;
  logic clic_ptr_in_wb;   // CLIC pointer caused by directly acking an SHV is in WB (no mret)

  logic pending_nmi;
  logic pending_nmi_early;
  logic pending_async_debug;
  logic pending_sync_debug;
  logic pending_single_step;
  logic pending_interrupt;


  // Flags for allowing interrupt and debug
  logic exception_allowed;
  logic interrupt_allowed;
  logic nmi_allowed;
  logic async_debug_allowed;
  logic sync_debug_allowed;
  logic single_step_allowed;

  // Flag for blocking interrupts due to debug conditions
  logic debug_interruptible;

  // Flag indicating there is a 'live' CLIC pointer in the pipeline
  // Used to block debug and interrupts until pointer fetch is done and the final ISR instruction PC is available.
  logic clic_ptr_in_pipeline;

  // Internal irq_ack for use when a (clic) pointer reaches ID stage and
  // we have single stepping enabled.
  logic non_shv_irq_ack;

  // Flops for debug cause
  logic [2:0] debug_cause_n;
  logic [2:0] debug_cause_q;

  // Cause of synchronous debug entry
  logic [2:0] sync_debug_cause;

  // Flop for remembering causes of wakeup
  logic       woke_to_debug_q;
  logic       woke_to_interrupt_q;

  logic [10:0] exc_cause; // id of taken interrupt. Max width, unused bits are tied off.

  logic       fence_req_set;
  logic       fence_req_clr;
  logic       fence_req_q;
  logic       fencei_req_and_ack_q;
  logic       fencei_ongoing;

  // Pipeline PC mux control
  pipe_pc_mux_e pipe_pc_mux_ctrl;

  // Flag for signalling that a new instruction arrived in WB.
  // Used for performance counters. High for one cycle, unless WB is halted
  // (for fence.i for example), then it will remain high until un-halted.
  logic       wb_counter_event;

  // Gated version of wb_counter_event
  // Do not count if halted or killed
  logic       wb_counter_event_gated;

  // Flop for acking flush requests due to CSR writes
  logic       csr_flush_ack_n;
  logic       csr_flush_ack_q;

  // Flag for checking if multi op instructions are in an interruptible state
  logic       sequence_in_progress_wb;
  logic       sequence_interruptible;

  // Flag for checking if ID stage can be halted
  // Used to not halt sequences in the middle, potentially causing deadlocks
  logic       sequence_in_progress_id;
  logic       id_stage_haltable;

  // Flag that is high during the cycle after an LSU instruction finishes in WB
  logic       interrupt_blanking_q;

  // Flop for tracking when a pointer fetch is in progress
  logic       clic_ptr_in_progress_id;
  logic       clic_ptr_in_progress_id_set;
  logic       clic_ptr_in_progress_id_clear;

  assign sequence_interruptible = !sequence_in_progress_wb;

  assign id_stage_haltable = !(sequence_in_progress_id || clic_ptr_in_progress_id);

  // Once the fencei handshake is initiated, it must complete and the instruction must retire.
  // The instruction retires when fencei_req_and_ack_q = 1
  assign fencei_ongoing = fencei_flush_req_o || fencei_req_and_ack_q;

  // Mux selector for vectored IRQ PC
  // Used for both basic mode and CLIC when shv == 0.
  assign ctrl_fsm_o.mtvec_pc_mux = ((mtvec_mode_i == 2'b0) || ((mtvec_mode_i == 2'b11) && !irq_clic_shv_i)) ? 5'h0 : exc_cause[4:0];

  // CLIC mode vectored PC mux is always the same as exc_cause.
  assign ctrl_fsm_o.mtvt_pc_mux = exc_cause[9:0];

  // Set which mtvec index to jump to when an NMI is taken
  // index 0 for non-vectored CLINT mode and CLIC mode, 0xF for vectored CLINT mode
  assign ctrl_fsm_o.nmi_mtvec_index = (mtvec_mode_i == 2'b01) ? 5'hF : 5'h0;

  ////////////////////////////////////////////////////////////////////
  // ID stage

  // A jump is taken in ID for jump instructions, and also for mret instructions
  // Checking validity of jump/mret instruction with if_id_pipe_i.instr_valid and the respective alu_en/sys_en.
  // Using the ID stage local instr_valid would bring halt_id and kill_id into the equation
  // causing a path from data_rvalid to instr_addr_o/instr_req_o/instr_memtype_o via pc_set.

  assign sys_mret_id = sys_en_id_i && sys_mret_id_i && if_id_pipe_i.instr_valid;
  assign jmp_id      = alu_en_id_i && alu_jmp_id_i  && if_id_pipe_i.instr_valid;

  // Detect that a jump is in the ID stage.
  // This will also be true for table jumps, as they are encoded as JAL instructions.
  //   An extra table jump flag is used in the logic for taken jumps to disinguish between
  //   regular jumps and table jumps.
  // Table jumps do an implicit read of the JVT CSR, so csr_stall must be accounted for.
  assign jump_in_id = (jmp_id && !if_id_pipe_i.instr_meta.tbljmp && !ctrl_byp_i.jalr_stall)    ||
                      (jmp_id &&  if_id_pipe_i.instr_meta.tbljmp && !ctrl_byp_i.csr_stall_id ) ||
                      (sys_mret_id && !ctrl_byp_i.csr_stall_id);

  // Blocking on branch_taken_q, as a jump has already been taken
  assign jump_taken_id = jump_in_id && !branch_taken_q;

  // Detect clic pointers in ID
  assign clic_ptr_in_id = if_id_pipe_i.instr_valid && if_id_pipe_i.instr_meta.clic_ptr;

  // Detect mret pointers in ID
  assign mret_ptr_in_id = if_id_pipe_i.instr_valid && if_id_pipe_i.instr_meta.mret_ptr;

  // Note: RVFI does not use jump_taken_id (which is not in itself an issue). An assertion in id_stage_sva checks that the jump target remains stable.

  // EX stage
  // Branch taken for valid branch instructions in EX with valid decision

  assign branch_in_ex = id_ex_pipe_i.alu_bch && id_ex_pipe_i.alu_en && id_ex_pipe_i.instr_valid;

  // Blocking on branch_taken_q, as a branch ha already been taken
  assign branch_taken_ex = branch_in_ex && !branch_taken_q && branch_decision_ex_i;

  // Exception in WB if the following evaluates to 1
  // Not checking for ex_wb_pipe_i.last_op to enable exceptions to be taken as soon as possible for
  // split load/stores or Zc sequences.
  //
  // For ebreak instructions, the following scenarios are possible. Only one scenario could cause an exception:
  // priv_lvl | ebreakm | debug_mode | action
  //----------|---------|------------|-----------------------------------------
  //   M      |   0     |      0     | Exception
  //   M      |   0     |      1     | Debug entry (restart from dm_halt_addr_i)
  //   M      |   1     |      0     | Debug entry
  //   M      |   1     |      1     | Debug entry (restart from dm_halt_addr_i)
  //
  assign exception_in_wb = ((ex_wb_pipe_i.instr.mpu_status != MPU_OK)                                                      ||
                             ex_wb_pipe_i.instr.bus_resp.err                                                               ||
                             ex_wb_pipe_i.illegal_insn                                                                     ||
                            (ex_wb_pipe_i.sys_en && ex_wb_pipe_i.sys_ecall_insn)                                           ||
                            (ex_wb_pipe_i.sys_en && ex_wb_pipe_i.sys_ebrk_insn && (ex_wb_pipe_i.priv_lvl == PRIV_LVL_M) &&
                              !dcsr_i.ebreakm && !debug_mode_q) ||
                            (mpu_status_wb_i != MPU_OK) ||
                            (align_status_wb_i != ALIGN_OK)) && ex_wb_pipe_i.instr_valid;

  assign ctrl_fsm_o.exception_in_wb = exception_in_wb;

  // Set exception cause
  assign exception_cause_wb = (ex_wb_pipe_i.instr.mpu_status != MPU_OK)                                                      ? EXC_CAUSE_INSTR_FAULT      :
                              ex_wb_pipe_i.instr.bus_resp.err                                                                ? EXC_CAUSE_INSTR_BUS_FAULT  :
                              ex_wb_pipe_i.illegal_insn                                                                      ? EXC_CAUSE_ILLEGAL_INSN     :
                              (ex_wb_pipe_i.sys_en && ex_wb_pipe_i.sys_ecall_insn)                                           ? EXC_CAUSE_ECALL_MMODE      :
                              (ex_wb_pipe_i.sys_en && ex_wb_pipe_i.sys_ebrk_insn && (ex_wb_pipe_i.priv_lvl == PRIV_LVL_M) &&
                                !dcsr_i.ebreakm && !debug_mode_q)                                                            ? EXC_CAUSE_BREAKPOINT       :
                              (mpu_status_wb_i == MPU_WR_FAULT)                                                              ? EXC_CAUSE_STORE_FAULT      :
                              (mpu_status_wb_i == MPU_RE_FAULT)                                                              ? EXC_CAUSE_LOAD_FAULT       :
                              (align_status_wb_i == ALIGN_WR_ERR)                                                            ? EXC_CAUSE_STORE_FAULT      :
                                                                                                                               EXC_CAUSE_LOAD_FAULT;

  assign ctrl_fsm_o.exception_cause_wb = exception_cause_wb;

  // For now we are always allowed to take exceptions once they arrive in WB.
  // For a misaligned load/store with MPU error on the first half, the second half
  // will arrive in EX when the first half (with error) arrives in WB. The exception will
  // be taken and the bus transaction of the second half will be suppressed by the ctrl_fsm_o.kill_ex signal.
  // The only higher priority events are  NMI, debug and interrupts, and none of them are allowed if there is
  // a load/store in WB.
  assign exception_allowed = 1'b1;

  // wfi in wb
  assign wfi_in_wb = ex_wb_pipe_i.sys_en && ex_wb_pipe_i.sys_wfi_insn && ex_wb_pipe_i.instr_valid;

  // wfe in wb
  assign wfe_in_wb = ex_wb_pipe_i.sys_en && ex_wb_pipe_i.sys_wfe_insn && ex_wb_pipe_i.instr_valid;

  // fencei in wb
  assign fencei_in_wb = ex_wb_pipe_i.sys_en && ex_wb_pipe_i.sys_fencei_insn && ex_wb_pipe_i.instr_valid;

  // fence in wb
  assign fence_in_wb  = ex_wb_pipe_i.sys_en && ex_wb_pipe_i.sys_fence_insn && ex_wb_pipe_i.instr_valid;

  // mret in wb - only valid when ex_wb_pipe_i.first_op == 1.
  // Regular mret instruction will have first_op == last_op == 1.
  // Mret with mcause.minhv==1 will restart a CLIC pointer fetch. The mret instruction will have first_op==1 && last_op==0
  // while the pointer will finish the sequence with first_op==0 and last_op==1. The mret related CSR updates will happen
  // once the mret instruction reaches WB. The pointer fetch may generate an exception, causing further CSR updates
  // once the attempted pointer fetch reaches WB.
  assign mret_in_wb = ex_wb_pipe_i.sys_en && ex_wb_pipe_i.sys_mret_insn && ex_wb_pipe_i.instr_valid && ex_wb_pipe_i.first_op;

  // CLIC pointer (caused by mret) in WB.
  assign mret_ptr_in_wb = ex_wb_pipe_i.instr_meta.mret_ptr && ex_wb_pipe_i.instr_valid;

  // dret in wb
  assign dret_in_wb = ex_wb_pipe_i.sys_en && ex_wb_pipe_i.sys_dret_insn && ex_wb_pipe_i.instr_valid;

  // ebreak in wb
  assign ebreak_in_wb = ex_wb_pipe_i.sys_en && ex_wb_pipe_i.sys_ebrk_insn && ex_wb_pipe_i.instr_valid;

  // Trigger match in wb
  // Trigger_match during debug mode is masked in the trigger logic inside cs_registers.sv
  assign trigger_match_in_wb = ((|ex_wb_pipe_i.trigger_match) || (|wpt_match_wb_i)) && ex_wb_pipe_i.instr_valid;

  // Only set the etrigger_in_wb flag when wb_valid is true (WB is not halted or killed).
  // If a higher priority event than taking an exception (NMI, external debug or interrupts) are present, wb_valid_i will be
  // suppressed by either halt_wb followed by kill_wb (debug), or kill_wb (NMI/interrupt).
  assign etrigger_in_wb = etrigger_wb_i && wb_valid_i;

  // An offloaded instruction is in WB
  assign xif_in_wb = (ex_wb_pipe_i.xif_en && ex_wb_pipe_i.instr_valid);

  // Regular CLIC pointer in EX (not caused by mret)
  assign clic_ptr_in_ex = id_ex_pipe_i.instr_meta.clic_ptr && id_ex_pipe_i.instr_valid;

  // Regular CLIC pointer in WB (not caused by mret)
  assign clic_ptr_in_wb = ex_wb_pipe_i.instr_meta.clic_ptr && ex_wb_pipe_i.instr_valid;

  // Pending NMI
  // Using flopped version to avoid paths from data_err_i/data_rvalid_i to instr_* outputs
  assign pending_nmi = nmi_pending_q;

  // Early version of the pending_nmi signal, using the unflopped lsu_err_wb_i.bus_err
  // This signal is used for halting the ID stage in the same cycle as the bus error arrives.
  // This ensures that any instruction in the ID stage that may depend on the result of the faulted load
  // will not propagate to the EX stage. For cycles after lsu_err_wb_i[0] is
  // high, ID stage will be halted due to pending_nmi and !nmi_allowed.
  assign pending_nmi_early =  lsu_err_wb_i.bus_err;

  // dcsr.nmip will always see a pending nmi if nmi_pending_q is set.
  // This CSR bit shall not be gated by debug mode or step without stepie
  assign ctrl_fsm_o.pending_nmi = nmi_pending_q;

  // Debug

  // Single step will need to finish insn in WB, including LSU
  // LSU will now set valid_1_o only for second part of misaligned instructions.
  // We can always allow single step when checking for wb_valid_i in 'pending_single_step'
  // - no other instructions should be in the pipeline.
  assign single_step_allowed = 1'b1;

  /*
  "If control is transferred to a trap handler while executing the instruction, then Debug Mode is
  re-entered immediately after the PC is changed to the trap handler, and the appropriate tval and
  cause registers are updated. In this case none of the trap handler is executed, and if the cause was
  a pending interrupt no instructions might be executed at all."

  Hence, a pending_single_step is asserted if we take an interrupt when we should be stepping.
  For any interruptible instructions (non-LSU), at any stage, we would kill the instruction and jump
  to debug mode without executing any instructions. Interrupt handler's first instruction will be in dpc.

  For LSU instructions that may not be killed (if they reach WB or stay in EX for >1 cycles),
  we are not allowed to take interrupts, and we will re-enter debug mode after finishing the LSU.
  Interrupt will then be taken when we enter the next step.
  */

  assign non_shv_irq_ack = ctrl_fsm_o.irq_ack && !irq_clic_shv_i;

  // single step becomes pending when the last operation of an instruction is done in WB (including CLIC pointers), or we ack a non-shv interrupt (including NMI).
  // If a CLIC SHV interrupt is taken during single step, a pointer that reaches WB will trigger the debug entry.
  //   - For un-faulted pointer fetches, the second fetch of the CLIC vectoring took place in ID, and the final SHV handler target address will be available from IF.
  //   - A faulted pointer fetch does not perform the second fetch. Instead the exception handler fetch will occur before entering debug due to stepping.
  //
  // Unlike [a]synchrounous debug entries, single step does not halt the pipeline.
  // This causes the reason for debug entry to 'disappear' as seen from the DEBUG_TAKEN state one cycle later.
  // The signal pending_single_step should never be used outside of the FUNCTIONAL state.
  assign pending_single_step = (!debug_mode_q && dcsr_i.step && ((wb_valid_i && (last_op_wb_i || abort_op_wb_i)) || non_shv_irq_ack || (pending_nmi && nmi_allowed)));

  // Detect if there is a live CLIC pointer in the pipeline
  // This should block debug and interrupts
  generate
    if (CLIC) begin : gen_clic_pointer_flag
      // A CLIC pointer may be in the pipeline from the moment we start fetching (clic_ptr_in_progress_id == 1)
      // or while a pointer is in the EX or WB stages.
      assign clic_ptr_in_pipeline = clic_ptr_in_ex || clic_ptr_in_wb || clic_ptr_in_progress_id;
    end else begin : gen_basic_pointer_flag
      assign clic_ptr_in_pipeline = 1'b0;
    end
  endgenerate
  // External debug will kill insn in WB, do not allow if LSU is not interruptible, a fence.i handshake is taking place
  // or if an offloaded instruction is in WB.
  // LSU will not be interruptible if the outstanding counter != 0, or
  // a trans_valid has been clocked without ex_valid && wb_ready handshake.
  // When a fencei is present in WB and the LSU has completed all tranfers, the fencei handshake will be initiated. This must complete and the fencei instruction must retire before allowing external debug.
  // Any multi operation instruction (table jumps, push/pop and double moves) may not be interrupted once the first operation has completed its operation in WB.
  //   - This is guarded with using the sequence_interruptible, which tracks sequence progress through the WB stage.
  // When a CLIC pointer is in the pipeline stages EX or WB, we must block debug.
  //   - Debug would otherwise kill the pointer and use the address of the pointer for dpc. A following dret would then return to the mtvt table, losing program progress.
  //
  // Debug entry because of haltreq is disallowed when the LSU is busy and therefore
  // haltreq can only cause debug entry on the instruction following a load or store that
  // keep the LSU busy. If such load or store however is being single stepped or has an
  // associated breakpoint or watchpoint, then debug will be entered because of that
  // lower priority reason even though haltreq is asserted. This is okay because if instruction
  // timing is considered haltreq should be considered only asserted on the following
  // instruction (i.e. the asynchronous haltreq signal is considered asserted too late to
  // impact the current instruction in the pipeline).
  // If the core woke up from sleep due to interrupts, the wakeup reason will be honored
  // by not allowing async debug the cycle after wakeup.
  assign async_debug_allowed = lsu_interruptible_i && !fencei_ongoing && !xif_in_wb && !clic_ptr_in_pipeline && sequence_interruptible &&
                               !woke_to_interrupt_q && !csr_flush_ack_q && !(ctrl_fsm_cs == SLEEP);

  // synchronous debug entry have far fewer restrictions than asynchronous entries. In principle synchronous debug entry should have the same
  // 'allowed' signal as exceptions - that is it should always be possible.
  // todo:XIF When XIF is being finished, debug entry vs xif must be reevaluated.
  assign sync_debug_allowed = !xif_in_wb && !(ctrl_fsm_cs == SLEEP);

  // Debug pending for any other synchronous reason than single step
  // Note that the WB stage may be killed for interrupts and NMIs, thus invalidating the instruction causing the sync debug entry.
  // Exception triggers do not set pending_sync_debug, as they need to take the single step path through the FSM.
  assign pending_sync_debug = (trigger_match_in_wb) ||
                              (ebreak_in_wb && dcsr_i.ebreakm && (ex_wb_pipe_i.priv_lvl == PRIV_LVL_M) && !debug_mode_q) || // Ebreak with dcsr.ebreakm==1  during machine mode
                              (ebreak_in_wb && debug_mode_q); // Ebreak during debug_mode restarts execution from dm_halt_addr, as a regular debug entry without CSR updates.

  // Debug pending for external debug request, only if not already in debug mode
  // Ideally the !debug_mode_q below should be factored into async_debug_allowed, but
  // that can currently cause a deadlock if debug_req_i gets asserted while in debug mode, as
  // a pending but not allowed async debug will cause the ID stage to halt forever while trying
  // to get to an interruptible state.
  // When the core wakes up from sleep due to debug_req_i, woke_to_debug_q will be set for exactly one cycle
  // to allow the core to enter debug one cycle after waking up, even though debug_req_i may have been deasserted.
  assign pending_async_debug = (debug_req_i || woke_to_debug_q) && !debug_mode_q;

  // Determine cause of debug. Set for all causes of debug entry.
  // In case of ebreak during debug mode, the entry code in DEBUG_TAKEN will
  // make sure not to update any CSRs.
  // The flopped version of this is checked during DEBUG_TAKEN state (one cycle delay)
  // For this core, the three top priorities are covered by pending_async_debug.
  // 1: resethaltreq (0x5)
  // 2: halt group (0x6)
  // 3: haltreq (0x3)
  // 4: trigger match (0x2)
  // 5: ebreak (0x1)
  // 6: single step (0x4)

  // The synchronous causes are determined here, while the priority between haltreq, sync_debug_cause and single step is determined within the FSM.
  assign sync_debug_cause = (trigger_match_in_wb)                                                                      ? DBG_CAUSE_TRIGGER :    // Etrigger will enter DEBUG_TAKEN as a single step (no halting), but kill pipeline as non-stepping entries.
                            (ebreak_in_wb && dcsr_i.ebreakm && (ex_wb_pipe_i.priv_lvl == PRIV_LVL_M) && !debug_mode_q) ? DBG_CAUSE_EBREAK  :    // Ebreak during machine mode
                            (ebreak_in_wb && debug_mode_q)                                                             ? DBG_CAUSE_EBREAK  :    // Ebreak during debug mode
                                                                                                                         DBG_CAUSE_NONE;

  // Debug cause to CSR from flopped version (valid during DEBUG_TAKEN)
  assign ctrl_fsm_o.debug_cause = debug_cause_q;

  // interrupt pending comes directly from the interrupt controller
  assign pending_interrupt = irq_req_ctrl_i;

  // Allow interrupts to be taken only if there is no data request in WB,
  // and no trans_valid has been clocked from EX to environment.
  // Not allowing interrupts when the core cannot take interrupts due to debug conditions.
  // Offloaded instructions in WB also block, as they cannot be killed after commit_kill=0 (EX stage)
  // LSU instructions which were suppressed due to previous exceptions or trigger match
  // will be interruptable as they were converted to NOP in ID stage.
  // When a fencei is present in WB and the LSU has completed all tranfers, the fencei handshake will be initiated. This must complete and the fencei instruction must retire before allowing interrupts.
  // Any multi operation instruction (table jumps, push/pop and double moves) may not be interrupted once the first operation has completed its operation in WB.
  //   - This is guarded with using the sequence_interruptible, which tracks sequence progress through the WB stage.
  // When a CLIC pointer is in the pipeline stages EX or WB, we must block interrupts.
  //   - Interrupt would otherwise kill the pointer and use the address of the pointer for mepc. A following mret would then return to the mtvt table, losing program progress.
  assign interrupt_allowed = lsu_interruptible_i && debug_interruptible && !fencei_ongoing && !xif_in_wb && !clic_ptr_in_pipeline &&
                             sequence_interruptible && !interrupt_blanking_q && !csr_flush_ack_q && !(ctrl_fsm_cs == SLEEP);

  // Allowing NMI's follow the same rule as regular interrupts, except we don't need to regard blanking of NMIs after a load/store.
  // If the core woke up from sleep due to either debug or regular interrupts, the wakeup reason is honored by not allowing NMIs in the cycle after
  // waking up to such an event.
  assign nmi_allowed = lsu_interruptible_i && debug_interruptible && !fencei_ongoing && !xif_in_wb && !clic_ptr_in_pipeline &&
                       sequence_interruptible && !(woke_to_debug_q || woke_to_interrupt_q) && !csr_flush_ack_q && !(ctrl_fsm_cs == SLEEP);

  // Do not allow interrupts if in debug mode, or single stepping without dcsr.stepie set.
  assign debug_interruptible = !(debug_mode_q || (dcsr_i.step && !dcsr_i.stepie));

  // Do not count if we have an exception in WB, ebreak in WB, trigger match in WB (we do not execute the instruction at trigger address),
  // or WB stage is killed or halted.
  // When WB is halted, we do not know (yet) if the instruction will retire or get killed.
  // Halted WB due to debug will result in WB getting killed
  // Halted WB due to fence.i will result in fence.i retire after handshake is done and we count when WB is un-halted
  // ctrl_fsm_o.halt_limited_wb will only be set during SLEEP, and only affect the WB stage (not cs_registers)
  //  In terms of counter events, no event should be counted while either of the WB related halts are asserted.
  assign wb_counter_event_gated = wb_counter_event && !exception_in_wb && !ebreak_in_wb && !trigger_match_in_wb &&
                                  !ctrl_fsm_o.kill_wb && !ctrl_fsm_o.halt_wb && !ctrl_fsm_o.halt_limited_wb;

  // Performance counter events
  assign ctrl_fsm_o.mhpmevent.minstret      = wb_counter_event_gated;
  assign ctrl_fsm_o.mhpmevent.compressed    = wb_counter_event_gated && ex_wb_pipe_i.instr_meta.compressed;
  assign ctrl_fsm_o.mhpmevent.jump          = wb_counter_event_gated && ex_wb_pipe_i.alu_jmp_qual;
  assign ctrl_fsm_o.mhpmevent.branch        = wb_counter_event_gated && ex_wb_pipe_i.alu_bch_qual;
  assign ctrl_fsm_o.mhpmevent.branch_taken  = wb_counter_event_gated && ex_wb_pipe_i.alu_bch_taken_qual;
  assign ctrl_fsm_o.mhpmevent.intr_taken    = ctrl_fsm_o.irq_ack;
  assign ctrl_fsm_o.mhpmevent.data_read     = m_c_obi_data_if.s_req.req && m_c_obi_data_if.s_gnt.gnt && !m_c_obi_data_if.req_payload.we;
  assign ctrl_fsm_o.mhpmevent.data_write    = m_c_obi_data_if.s_req.req && m_c_obi_data_if.s_gnt.gnt && m_c_obi_data_if.req_payload.we;
  assign ctrl_fsm_o.mhpmevent.if_invalid    = !if_valid_i && id_ready_i;
  assign ctrl_fsm_o.mhpmevent.id_invalid    = !id_valid_i && ex_ready_i;
  assign ctrl_fsm_o.mhpmevent.ex_invalid    = !ex_valid_i && wb_ready_i;
  assign ctrl_fsm_o.mhpmevent.wb_invalid    = !wb_valid_i;
  assign ctrl_fsm_o.mhpmevent.id_jalr_stall = ctrl_byp_i.jalr_stall && !id_valid_i && ex_ready_i;
  assign ctrl_fsm_o.mhpmevent.id_ld_stall   = ctrl_byp_i.load_stall && !id_valid_i && ex_ready_i;
  assign ctrl_fsm_o.mhpmevent.wb_data_stall = data_stall_wb_i;



  // Mux used to select PC from the different pipeline stages
  always_comb begin

    ctrl_fsm_o.pipe_pc = ex_wb_pipe_i.pc;

    unique case (pipe_pc_mux_ctrl)
      PC_WB: ctrl_fsm_o.pipe_pc = ex_wb_pipe_i.pc;
      PC_EX: ctrl_fsm_o.pipe_pc = id_ex_pipe_i.pc;
      PC_ID: ctrl_fsm_o.pipe_pc = if_id_pipe_i.pc;
      PC_IF: ctrl_fsm_o.pipe_pc = pc_if_i;
      default:;
    endcase
  end

  //////////////
  // FSM comb //
  //////////////
  always_comb begin
    // Default values
    ctrl_fsm_ns                 = ctrl_fsm_cs;
    ctrl_fsm_o.ctrl_busy        = 1'b1;
    ctrl_fsm_o.instr_req        = 1'b1;

    ctrl_fsm_o.pc_mux           = PC_BOOT;
    ctrl_fsm_o.pc_set           = 1'b0;

    ctrl_fsm_o.irq_ack          = 1'b0;
    ctrl_fsm_o.irq_id           = '0;
    ctrl_fsm_o.irq_priv         = '0;
    ctrl_fsm_o.irq_shv          = '0;
    ctrl_fsm_o.irq_level        = 8'h00;

    ctrl_fsm_o.dbg_ack          = 1'b0;

    // IF stage is halted if an instruction has been issued during single step
    // to avoid more than one instructions passing down the pipe.
    ctrl_fsm_o.halt_if          = single_step_halt_if_q;

    // ID stage is halted when hazards are present (i.e. stalls for which the instruction currently in ID is not ready to be issued yet).
    //
    // In addition the ID stage may be halted to enable interrupts or debug to be taken.
    //   - If an interrupt (including NMI) is present it is not guaranteed that the pipeline
    //     can take the interrupt immediately. A LSU instruction could for instance be outstanding, causing the interrupt not to be taken.
    //     The controller uses (pending_interrupt && interrupt_allowed) to check for these conditions.
    //     When an interrupt (or NMI) is pending, the ID stage is halted to guarantee that an interruptible bubble eventually will
    //     occur in the WB stage.
    //   -- The ID stage is only halted iff debug_interruptible==1, indicating that we are not in debug mode or single step mode with interrupts disabled.
    //   --- If halting for interrupts while in debug mode (debug_interruptible == 0), the core would deadlock waiting for interrupt_allowed, but the core
    //       would never exit debug mode because the dret instruction could be blocked by the halted ID stage.
    //   -- The ID stage is only halted iff also the ID stage is haltable (meaning ID stage is not currently in the middle of a sequence or waiting for a CLIC pointer)
    //
    //   - The ID stage is halted when any async or sync debug is pending for the same reasons as for interrupts.
    //
    //   - If not checking for id_stage_haltable for interrupts and debug, the core could end up in a situation where it tries to create a bubble
    //     by halting ID, but the condition disallowing interrupt or debug will not disappear until the sequence currently handled by the ID stage
    //     is done. This would create an unrecoverable deadlock.
    ctrl_fsm_o.halt_id          = (ctrl_byp_i.jalr_stall || ctrl_byp_i.load_stall || ctrl_byp_i.csr_stall_id || ctrl_byp_i.sleep_stall || ctrl_byp_i.mnxti_id_stall) ||
                                  ((pending_interrupt || pending_nmi || pending_nmi_early) && debug_interruptible && id_stage_haltable)                             ||
                                  ((pending_async_debug || pending_sync_debug) && id_stage_haltable);


    // Halting EX if minstret_stall occurs. Otherwise we would read the wrong minstret value
    // Also halting EX if an offloaded instruction in WB may cause an exception, such that a following offloaded
    // instruction can correctly receive commit_kill.
    // Halting EX when an instruction in WB may cause an interrupt to become pending.
    // Halting while handling atomics for the following two scenarios to avoid mix of atomics and non-atomics outstanding at the same time:
    //   - An atomic is in EX while there is an LSU instruction in WB (including atomics)
    //   - Any LSU instruction is in EX while there is an outstanding atomic in WB
    ctrl_fsm_o.halt_ex          = ctrl_byp_i.minstret_stall || ctrl_byp_i.xif_exception_stall || ctrl_byp_i.irq_enable_stall ||
                                  ctrl_byp_i.mnxti_ex_stall || ctrl_byp_i.atomic_stall || ctrl_byp_i.csr_stall_ex;
    ctrl_fsm_o.halt_wb          = 1'b0;
    ctrl_fsm_o.halt_limited_wb  = 1'b0;

    // By default no stages are killed
    ctrl_fsm_o.kill_if          = 1'b0;
    ctrl_fsm_o.kill_id          = 1'b0;
    ctrl_fsm_o.kill_ex          = 1'b0;
    ctrl_fsm_o.kill_wb          = 1'b0;

    ctrl_fsm_o.csr_restore_mret = 1'b0;
    ctrl_fsm_o.csr_restore_dret = 1'b0;

    ctrl_fsm_o.csr_save_cause   = 1'b0;
    ctrl_fsm_o.csr_cause        = 32'h0;

    pipe_pc_mux_ctrl            = PC_WB;

    exc_cause                   = 11'b0;

    debug_cause_n               = DBG_CAUSE_NONE;
    debug_mode_n                = debug_mode_q;
    ctrl_fsm_o.debug_csr_save   = 1'b0;
    ctrl_fsm_o.debug_trigger_hit = '0;          // Mask of which triggers did hit.
    ctrl_fsm_o.debug_trigger_hit_update = 1'b0; // Signal that hit bits of mcontrol6 shall be written.

    // Single step halting of IF
    single_step_halt_if_n       = single_step_halt_if_q;

    // Ensure jumps and branches are taken only once
    branch_taken_n              = branch_taken_q;

    fence_req_set               = 1'b0;
    fence_req_clr               = 1'b1;

    ctrl_fsm_o.pc_set_clicv     = 1'b0;
    ctrl_fsm_o.pc_set_tbljmp    = 1'b0;

    csr_flush_ack_n             = 1'b0;

    clic_ptr_in_progress_id_set   = 1'b0;
    clic_ptr_in_progress_id_clear = 1'b0;

    unique case (ctrl_fsm_cs)
      RESET: begin
        ctrl_fsm_o.instr_req = 1'b0;
        if (fetch_enable_i) begin
          if (debug_req_i) begin
            // Not raising instr_req to prevent fetching until we are in debug mode
            ctrl_fsm_o.instr_req = 1'b0;
            ctrl_fsm_o.pc_mux    = PC_BOOT;
            ctrl_fsm_o.pc_set    = 1'b1; // pc_set is required for propagating boot address to dpc (from IF stage)
            ctrl_fsm_ns          = DEBUG_TAKEN;
            debug_cause_n        = DBG_CAUSE_HALTREQ;
          end else begin
            ctrl_fsm_o.instr_req = 1'b1;
            ctrl_fsm_o.pc_mux    = PC_BOOT;
            ctrl_fsm_o.pc_set    = 1'b1;
            ctrl_fsm_ns          = FUNCTIONAL;
          end
        end
      end
      FUNCTIONAL: begin
        // NMI
        if (pending_nmi && nmi_allowed) begin
          ctrl_fsm_o.kill_if = 1'b1;
          ctrl_fsm_o.kill_id = 1'b1;
          ctrl_fsm_o.kill_ex = 1'b1;
          ctrl_fsm_o.kill_wb = 1'b1;

          ctrl_fsm_o.pc_set = 1'b1;
          ctrl_fsm_o.pc_mux = PC_TRAP_NMI;

          ctrl_fsm_o.csr_save_cause  = 1'b1;
          ctrl_fsm_o.csr_cause.irq = 1'b1;
          ctrl_fsm_o.csr_cause.exception_code = nmi_is_store_q ? INT_CAUSE_LSU_STORE_FAULT : INT_CAUSE_LSU_LOAD_FAULT;

          // Clear mcause.minhv when taking an NMI (only set when taking exceptions on CLIC/mret pointers)
          ctrl_fsm_o.csr_cause.minhv  = 1'b0;

          if (CLIC) begin
            // Keep current interrupt level when taking NMIs
            ctrl_fsm_o.irq_level = mintstatus_i.mil;
          end

          // Save pc from oldest valid instruction
          if (ex_wb_pipe_i.instr_valid) begin
            pipe_pc_mux_ctrl = PC_WB;
          end else if (id_ex_pipe_i.instr_valid) begin
            pipe_pc_mux_ctrl = PC_EX;
          end else if (if_id_pipe_i.instr_valid) begin
            pipe_pc_mux_ctrl = PC_ID;
          end else begin
            // IF PC will always be valid as it points to the next
            // instruction to be issued from IF to ID.
            pipe_pc_mux_ctrl = PC_IF;
          end

        // External debug entry (async)
        end else if (pending_async_debug && async_debug_allowed) begin
          // Halt the whole pipeline
          // Halting makes sure instructions stay in the pipeline stage without propagating to the next.
          //  This is needed by the debug entry code in the DEBUG_STAKEN state to pick the correct PC for storing in dpc.
          ctrl_fsm_o.halt_if = 1'b1;
          ctrl_fsm_o.halt_id = 1'b1;
          ctrl_fsm_o.halt_ex = 1'b1;
          ctrl_fsm_o.halt_wb = 1'b1;

          ctrl_fsm_ns = DEBUG_TAKEN;
          debug_cause_n = DBG_CAUSE_HALTREQ;
        // IRQ
        end else if (pending_interrupt && interrupt_allowed) begin
          ctrl_fsm_o.kill_if = 1'b1;
          ctrl_fsm_o.kill_id = 1'b1;
          ctrl_fsm_o.kill_ex = 1'b1;
          ctrl_fsm_o.kill_wb = 1'b1;

          ctrl_fsm_o.pc_set = 1'b1;

          exc_cause = {1'b0, irq_id_ctrl_i};

          ctrl_fsm_o.irq_ack = 1'b1;
          ctrl_fsm_o.irq_id  = irq_id_ctrl_i;

          ctrl_fsm_o.csr_save_cause  = 1'b1;
          ctrl_fsm_o.csr_cause.irq = 1'b1;

          // Clear mcause.minhv when taking an interrupt (only set when taking exceptions on CLIC/mret pointers)
          ctrl_fsm_o.csr_cause.minhv  = 1'b0;

          if (CLIC) begin
            ctrl_fsm_o.csr_cause.exception_code = {1'b0, irq_id_ctrl_i};
            ctrl_fsm_o.irq_level = irq_clic_level_i;
            ctrl_fsm_o.irq_priv = irq_clic_priv_i;
            ctrl_fsm_o.irq_shv = irq_clic_shv_i;
            if (irq_clic_shv_i) begin
              ctrl_fsm_o.pc_mux = PC_TRAP_CLICV;
              clic_ptr_in_progress_id_set = 1'b1;
              ctrl_fsm_o.pc_set_clicv = 1'b1;
            end else begin
              ctrl_fsm_o.pc_mux = PC_TRAP_IRQ;
            end
          end else begin
            ctrl_fsm_o.pc_mux = PC_TRAP_IRQ;
            ctrl_fsm_o.csr_cause.exception_code = {1'b0, irq_id_ctrl_i};
          end

          // Save pc from oldest valid instruction
          if (ex_wb_pipe_i.instr_valid) begin
            pipe_pc_mux_ctrl = PC_WB;
          end else if (id_ex_pipe_i.instr_valid) begin
            pipe_pc_mux_ctrl = PC_EX;
          end else if (if_id_pipe_i.instr_valid) begin
            pipe_pc_mux_ctrl = PC_ID;
          end else begin
            // IF PC will always be valid as it points to the next
            // instruction to be issued from IF to ID.
            pipe_pc_mux_ctrl = PC_IF;
          end
        // Synchronous debug entry (ebreak, trigger match)
        end else if (pending_sync_debug && sync_debug_allowed) begin
          // Halt the whole pipeline
          // Halting makes sure instructions stay in the pipeline stage without propagating to the next.
          //  This is needed by the debug entry code in the DEBUG_STAKEN state to pick the correct PC for storing in dpc.
          ctrl_fsm_o.halt_if = 1'b1;
          ctrl_fsm_o.halt_id = 1'b1;
          ctrl_fsm_o.halt_ex = 1'b1;
          ctrl_fsm_o.halt_wb = 1'b1;

          ctrl_fsm_ns = DEBUG_TAKEN;
          debug_cause_n = sync_debug_cause;
        end else begin
          if (exception_in_wb && exception_allowed) begin
            // Kill all stages
            ctrl_fsm_o.kill_if = 1'b1;
            ctrl_fsm_o.kill_id = 1'b1;
            ctrl_fsm_o.kill_ex = 1'b1;
            // All write enables are suppressed, no need to kill WB.
            // RVFI also needs wb_valid to be able to signal an exception on rvfi_valid/rvfi_trap.
            ctrl_fsm_o.kill_wb = 1'b0;

            // Set pc to exception handler
            ctrl_fsm_o.pc_set = 1'b1;
            ctrl_fsm_o.pc_mux = debug_mode_q ? PC_TRAP_DBE : PC_TRAP_EXC;

            // Save CSR from WB
            pipe_pc_mux_ctrl = PC_WB;
            ctrl_fsm_o.csr_save_cause = !debug_mode_q; // Do not update CSRs if in debug mode
            ctrl_fsm_o.csr_cause.exception_code = exception_cause_wb;

            // Set mcause.minhv if exception is for a CLIC or mret pointer. Otherwise clear it
            ctrl_fsm_o.csr_cause.minhv = clic_ptr_in_wb || mret_ptr_in_wb;

          // Special insn
          end else if (wfi_in_wb || wfe_in_wb) begin
            // Halt the entire pipeline
            // WFI/WFE will stay in WB until we exit sleep mode
            ctrl_fsm_o.halt_wb = 1'b1;
            ctrl_fsm_o.instr_req = 1'b0;
            ctrl_fsm_ns = SLEEP;

          end else if (fencei_in_wb || fence_in_wb) begin

            // fence.i behavior:
            //
            // - Can be killed due to interrupts and debug at any time before fencei_flush_req_o is asserted (so even after initial cycle in WB).
            // - Initially halt entire pipeline, making sure that possibly following loads/stores do not initiate transactions.
            // - Wait until the LSU is ready (i.e. write buffer must also be empty and possible NMIs will have been raised).
            // - Once the LSU is ready take the NMI if present or otherwise continue fence.i handling by initiating the fencei_flush_req_o handshake.
            // - Once the fencei_flush_req_o handshake is complete flush the entire pipeline (branch to next instruction) and retire the fence.i.

            // fence behavior:
            //
            // - Can be killed due to interrupts and debug at any time (so even after initial cycle in WB).
            // - Initially halt entire pipeline, making sure that possibly following loads/stores do not initiate transactions.
            // - Wait until the LSU is ready (i.e. write buffer must also be empty and possible NMIs will have been raised).
            // - Once the LSU is ready take the NMI if present or otherwise continue fence handling.
            // - Flush the entire pipeline (branch to next instruction) and retire the fence.

            // Halt the pipeline
            ctrl_fsm_o.halt_if = 1'b1;
            ctrl_fsm_o.halt_id = 1'b1;
            ctrl_fsm_o.halt_ex = 1'b1;
            ctrl_fsm_o.halt_wb = 1'b1;

            // Set fence_req_q when the LSU is no longer busy
            fence_req_set = !lsu_busy_i;
            fence_req_clr = 1'b0;

            if (fencei_in_wb ? fencei_req_and_ack_q : fence_req_q) begin

              // Unhalt wb, kill if,id,ex
              ctrl_fsm_o.kill_if   = 1'b1;
              ctrl_fsm_o.kill_id   = 1'b1;
              ctrl_fsm_o.kill_ex   = 1'b1;
              ctrl_fsm_o.halt_wb   = 1'b0;

              // Jump to PC from oldest valid instruction, excluding WB stage
              if (id_ex_pipe_i.instr_valid) begin
                pipe_pc_mux_ctrl = PC_EX;
              end else if (if_id_pipe_i.instr_valid) begin
                pipe_pc_mux_ctrl = PC_ID;
              end else begin
                pipe_pc_mux_ctrl = PC_IF;
              end

              ctrl_fsm_o.pc_set    = 1'b1;
              ctrl_fsm_o.pc_mux    = PC_WB_PLUS4;

              // Clear fence_req_q
              fence_req_set = 1'b0;
              fence_req_clr = 1'b1;
            end
          end else if (dret_in_wb) begin
            // dret takes jump from WB stage
            // Kill previous stages and jump to pc in dpc
            ctrl_fsm_o.kill_if = 1'b1;
            ctrl_fsm_o.kill_id = 1'b1;
            ctrl_fsm_o.kill_ex = 1'b1;

            ctrl_fsm_o.pc_mux  = PC_DRET;
            ctrl_fsm_o.pc_set  = 1'b1;

            ctrl_fsm_o.csr_restore_dret  = 1'b1;

            single_step_halt_if_n = 1'b0;
            debug_mode_n  = 1'b0;
          end else if (csr_wr_in_wb_flush_i) begin
            // CSR write in WB requires pipeline flush, halt all stages except WB
            // EX could contain a load/store, need to avoid its address phase going onto the bus
            ctrl_fsm_o.halt_if = 1'b1;
            ctrl_fsm_o.halt_id = 1'b1;
            ctrl_fsm_o.halt_ex = 1'b1;

            // Set flop input to get ack in the next cycle when the write is done.
            csr_flush_ack_n    = 1'b1;
          end else if (csr_flush_ack_q) begin
            // Flush pipeline because of CSR update in the previous cycle
            ctrl_fsm_o.kill_if   = 1'b1;
            ctrl_fsm_o.kill_id   = 1'b1;
            ctrl_fsm_o.kill_ex   = 1'b1;

            // Jump to PC from oldest valid instruction, excluding WB stage
            if (id_ex_pipe_i.instr_valid) begin
              pipe_pc_mux_ctrl = PC_EX;
            end else if (if_id_pipe_i.instr_valid) begin
              pipe_pc_mux_ctrl = PC_ID;
            end else begin
              pipe_pc_mux_ctrl = PC_IF;
            end

            ctrl_fsm_o.pc_set    = 1'b1;
            ctrl_fsm_o.pc_mux    = PC_WB_PLUS4;


          end else if (branch_taken_ex) begin
            ctrl_fsm_o.kill_if = 1'b1;
            ctrl_fsm_o.kill_id = 1'b1;

            ctrl_fsm_o.pc_mux  = PC_BRANCH;
            ctrl_fsm_o.pc_set  = 1'b1;

            // Set flag to avoid further branches to the same target
            // if we are stalled
            branch_taken_n     = 1'b1;

          end else if (jump_taken_id) begin
            // Jumps in ID (JAL, JALR, mret)

            // kill_if
            ctrl_fsm_o.kill_if = 1'b1;

            if (sys_mret_id) begin
              // If the mcause.minhv bit is set when an mret is in ID, the mret should restart the CLIC pointer fetch using mepc as
              // a pointer to the pointer instead of jumping to the address in mepc.
              // This is done below by signalling pc_set_clicv along with pc_mux=PC_MRET. This will
              // treat the mepc as an address to a CLIC pointer. The minhv flag will only be set when an exception is taken on a
              // CLIC or mret pointer, and cleared when a trap for any other cause except debug is taken. It is also writeable by SW.
              // ID stage is halted while it contains an mret and at the same time there are CSR writes (including CLIC pointers) in EX or WB, hence it is safe to use mcause here.
              if (mcause_i.minhv) begin
                // mcause.minhv set, exception occured during last pointer fetch (or SW wrote it)
                // Do another pointer fetch from the address stored in mepc.
                ctrl_fsm_o.pc_set = 1'b1;
                ctrl_fsm_o.pc_set_clicv = 1'b1; // Treat mepc as a pointer fetch
                ctrl_fsm_o.pc_mux = PC_MRET;

                // Set flag to avoid further jumps to the same target
                // if we are stalled
                branch_taken_n = 1'b1;

                // Clear flag for halting IF in case of single stepping
                // For the single step to complete, both the mret and the pointer must reach WB.
                // If no unhalt is done here, the pointer will never reach WB.
                single_step_halt_if_n = 1'b0;
              end else begin
                // xcause.xinhv not set for the previous privilege level, do regular mret
                ctrl_fsm_o.pc_mux = PC_MRET;
                ctrl_fsm_o.pc_set = 1'b1;

                // Set flag to avoid further jumps to the same target
                // if we are stalled
                branch_taken_n = 1'b1;
              end

            end else begin
              // For table jumps we have two different jumps
              // - First part does a pointer fetch from (jvt + (index<<2))
              // - Second part jumps to the fetched pointer
              // Regular jumps use the regular jump to the target calculated in the ID stage.
              ctrl_fsm_o.pc_mux        = if_id_pipe_i.instr_meta.tbljmp && !if_id_pipe_i.last_op ? PC_TBLJUMP :
                                         if_id_pipe_i.instr_meta.tbljmp && if_id_pipe_i.last_op  ? PC_POINTER : PC_JUMP;
              ctrl_fsm_o.pc_set        = 1'b1;
              ctrl_fsm_o.pc_set_tbljmp = if_id_pipe_i.instr_meta.tbljmp && !if_id_pipe_i.last_op;

              // Set flag to avoid further jumps to the same target
              // if we are stalled
              branch_taken_n = 1'b1;
            end
          end else if (clic_ptr_in_id || mret_ptr_in_id) begin
            if (!(if_id_pipe_i.instr.bus_resp.err || (if_id_pipe_i.instr.mpu_status != MPU_OK))) begin
              if (!branch_taken_q) begin
                ctrl_fsm_o.pc_set = 1'b1;
                ctrl_fsm_o.pc_mux = PC_POINTER;
                ctrl_fsm_o.kill_if = 1'b1;
                branch_taken_n = 1'b1;
              end
            end
          end

          // The following if statements are in parallel with the main decision tree.
          // If any of these would be part of the decision tree, they could mask jumps and branches
          // from being taken.
          // CLIC pointer in ID clears pointer fetch flag
          if (clic_ptr_in_id && id_valid_i && ex_ready_i) begin
            clic_ptr_in_progress_id_clear = 1'b1;
          end

          // Regular mret in WB restores CSR regs
          if (mret_in_wb && !ctrl_fsm_o.kill_wb && !ctrl_fsm_o.halt_wb) begin
            ctrl_fsm_o.csr_restore_mret  = !debug_mode_q;
          end

        end // !debug or interrupts

        // Single step debug entry or etrigger debug entry
        // Need to be after (in parallell with) exception/interrupt handling
        // to ensure mepc and if_pc are set correctly for use in dpc,
        // and to ensure only one instruction can retire during single step
        // Triggers other than exception trigger do not cause any state change before debug entry.
        // Exception triggers do all the side effects off taking an exception (mcause, mepc etc) but without
        // executing the first handler instruction before debug entry. If an exception trigger factored into
        // 'pending_sync_debug' instead og the single step logic, then these side effects of taking the exception would not occur, since exceptions
        // are prioritized below all debug entries in the FSM.
        if (pending_single_step || etrigger_in_wb) begin
          if (single_step_allowed) begin
            ctrl_fsm_ns = DEBUG_TAKEN;
            // etrigger has higher priority than step.
            // Any other higher priority cause of debug would not be pending is this context
            //   Async and sync debug entries will halt WB, causing !wb_valid which in turn pulls pending_single_step and etrigger_in_wb low.
            //   Any taken interrupt or NMI kills WB, also pulling wb_valid low. Pending_single_step will still be high, but any other debug entry
            //   reason as seen from WB will be deasserted.
            if (etrigger_in_wb) begin
              debug_cause_n = DBG_CAUSE_TRIGGER;
            end else begin
              debug_cause_n = DBG_CAUSE_STEP;
            end
          end
        end
      end
      SLEEP: begin
        // There should be a bubble in EX in this state (checked by assertion)
        // We are avoiding that a load/store starts its bus transaction
        ctrl_fsm_o.ctrl_busy         = 1'b0;
        ctrl_fsm_o.instr_req         = 1'b0;
        // Put backpressure on pipeline to avoid retiring WFI until we wake up.
        // Using limited version of halt_wb to avoid timing paths through cs_registers and bypass onto the data OBI bus.
        // Assertions exist to check that no CSR instruction can be in WB at this time.
        ctrl_fsm_o.halt_limited_wb   = 1'b1;

        // Wake up from SLEEP
        if (ctrl_fsm_o.wake_from_sleep) begin
          ctrl_fsm_ns = FUNCTIONAL;
          ctrl_fsm_o.ctrl_busy = 1'b1;
          // Keep IF/ID halted while waking up (EX contains a bubble)
          // Any jump/table jump/mret which is in ID in this cycle must also remain in ID
          // the next cycle for their side effects to be taken during the FUNCTIONAL state in case the interrupt is not actually taken.
          ctrl_fsm_o.halt_id = 1'b1;

          // Unhalt WB to allow WFI to retire when we exit SLEEP mode
          // Using limited version of halt_wb to avoid timing paths through cs_registers and bypass onto the data OBI bus.
          ctrl_fsm_o.halt_limited_wb = 1'b0;
        end
      end
      DEBUG_TAKEN: begin

        // Indicate that debug is taken
        ctrl_fsm_o.dbg_ack = 1'b1;

        // Clear flags for halting IF during single step
        single_step_halt_if_n = 1'b0;

        // Set pc
        ctrl_fsm_o.pc_set = 1'b1;
        ctrl_fsm_o.pc_mux = PC_TRAP_DBD;

        // Save CSRs
        ctrl_fsm_o.csr_save_cause = !(ebreak_in_wb && debug_mode_q);  // No CSR update for ebreak in debug mode
        ctrl_fsm_o.debug_csr_save = 1'b1;

        // If a trigger was hit, signal that mcontrol6 hit1 and hit0 bits should be written.
        // Only triggers configured as mcontrol6 will perform the actual write within debug_triggers.
        if (debug_cause_q == DBG_CAUSE_TRIGGER) begin
          ctrl_fsm_o.debug_trigger_hit_update = 1'b1;
          ctrl_fsm_o.debug_trigger_hit = ex_wb_pipe_i.trigger_match | wpt_match_wb_i;
        end

        // debug_cause_q set when decision was made to enter debug
        if (debug_cause_q != DBG_CAUSE_STEP) begin
          // Kill pipeline
          ctrl_fsm_o.kill_if = 1'b1;
          ctrl_fsm_o.kill_id = 1'b1;
          ctrl_fsm_o.kill_ex = 1'b1;
          // Ebreak that causes debug entry should not be killed, otherwise RVFI will skip it
          // Trigger match should also be signalled as not killed (all write enables are suppressed in ID), otherwise RVFI will not properly signal a trigger match.
          // Exception trigger match should have nothing in WB, excepted instruction finished the previous cycle and set mepc and mcause due to the exception.
          // Ebreak during debug_mode restarts from dm_halt_addr, without CSR updates. Not killing ebreak due to the same RVFI/ISS reasons.
          // Neither ebreak nor trigger match have any state updates in WB. For trigger match, all write enables are suppressed in the ID stage.
          //   Thus this change is not visible to core state, only for RVFI use.
          ctrl_fsm_o.kill_wb = !((debug_cause_q == DBG_CAUSE_EBREAK) || (debug_cause_q == DBG_CAUSE_TRIGGER));


          // Save pc from oldest valid instruction
          if (ex_wb_pipe_i.instr_valid) begin
            pipe_pc_mux_ctrl = PC_WB;
          end else if (id_ex_pipe_i.instr_valid) begin
            pipe_pc_mux_ctrl = PC_EX;
          end else if (if_id_pipe_i.instr_valid) begin
            pipe_pc_mux_ctrl = PC_ID;
          end else begin
            pipe_pc_mux_ctrl = PC_IF;
          end
        end else begin
          // Single step
          // Only kill IF. WB should be allowed to complete
          // ID and EX are empty as IF is blocked after one issue in single step mode
          ctrl_fsm_o.kill_if = 1'b1;
          ctrl_fsm_o.kill_id = 1'b0;
          ctrl_fsm_o.kill_ex = 1'b0;
          ctrl_fsm_o.kill_wb = 1'b0;

          // Should use pc from IF (next insn, as IF is halted after first issue)
          pipe_pc_mux_ctrl = PC_IF;
        end

        // Enter debug mode next cycle
        debug_mode_n = 1'b1;
        ctrl_fsm_ns = FUNCTIONAL;
      end

      default: begin
        // should never happen
        ctrl_fsm_o.instr_req = 1'b0;
        ctrl_fsm_ns = RESET;
      end
    endcase

    // Detect first insn issue in single step after dret
    // Any Zc sequence must fully complete (last_op_if_i) before halting the IF stage.
    // Used to block further issuing
    if (!ctrl_fsm_o.debug_mode && dcsr_i.step && !single_step_halt_if_q && (if_valid_i && id_ready_i && (last_op_if_i || abort_op_if_i))) begin
      single_step_halt_if_n = 1'b1;
    end

    // Clear jump/branch flag when new insn is emitted from IF
    if (branch_taken_q && if_valid_i && id_ready_i) begin
      branch_taken_n = 1'b0;
    end
  end

  // Wakeup from sleep
  assign ctrl_fsm_o.wake_from_sleep = pending_nmi || irq_wu_ctrl_i || pending_async_debug || (wfe_in_wb && wu_wfe_i); // Only WFE wakes up for wfe_wu_i
  assign ctrl_fsm_o.debug_no_sleep = debug_mode_q || dcsr_i.step;

  ////////////////////
  // Flops          //
  ////////////////////

  // FSM state and debug_mode
  always_ff @(posedge clk , negedge rst_n) begin
    if (rst_n == 1'b0) begin
      ctrl_fsm_cs <= RESET;
      debug_mode_q <= 1'b0;
      debug_cause_q <= DBG_CAUSE_NONE;
    end else begin
      ctrl_fsm_cs   <= ctrl_fsm_ns;
      debug_mode_q  <= debug_mode_n;
      debug_cause_q <= debug_cause_n;
    end
  end

  // debug_mode_if is a control input for the if stage.
  // For both debug mode entry end exit, the IF, ID and EX stages are killed. While the IF stage is killed it starts
  // fetching the next instruction (sets the obi request high), requiring a valid debug mode signal for this fetch.
  // The debug_mode_if signal is valid for all IF fetches.
  assign ctrl_fsm_o.debug_mode_if = debug_mode_n;
  assign ctrl_fsm_o.debug_mode    = debug_mode_q;


  // Sticky version of lsu_err_wb_i
  always_ff @(posedge clk, negedge rst_n) begin
    if (rst_n == 1'b0) begin
      nmi_pending_q <= 1'b0;
      nmi_is_store_q <= 1'b0;
    end else begin
      if (lsu_err_wb_i.bus_err && !nmi_pending_q) begin
        // Set whenever an error occurs in WB for the LSU, unless we already have an NMI pending.
        // Later errors could overwrite the bit for load/store type, and with mtval the address would be overwritten.
        nmi_pending_q <= 1'b1;
        nmi_is_store_q <= lsu_err_wb_i.store;
      // Clear when the controller takes the NMI
      end else if (ctrl_fsm_o.pc_set && (ctrl_fsm_o.pc_mux == PC_TRAP_NMI)) begin
        nmi_pending_q <= 1'b0;
      end
    end
  end

  // Flop used to gate if_valid after one instruction issued
  // in single step mode
  always_ff @(posedge clk, negedge rst_n) begin
    if (rst_n == 1'b0) begin
      single_step_halt_if_q <= 1'b0;
      branch_taken_q        <= 1'b0;
      csr_flush_ack_q       <= 1'b0;
    end else begin
      single_step_halt_if_q <= single_step_halt_if_n;
      branch_taken_q        <= branch_taken_n;
      csr_flush_ack_q       <= csr_flush_ack_n;
    end
  end

  // Flop used to track LSU instructions in WB. High in the cycle after an LSU instruction
  // leaves WB.
  // Used for disregarding interrupts one cycle after a load/store to make sure the
  // interrupt controller propagates the inputs through its flops.
  always_ff @(posedge clk, negedge rst_n) begin
    if (rst_n == 1'b0) begin
      interrupt_blanking_q <= 1'b0;
    end else begin
      interrupt_blanking_q <= ex_wb_pipe_i.instr_valid && ex_wb_pipe_i.lsu_en;
    end
  end

  // Flops for fencei handshake request
  always_ff @(posedge clk, negedge rst_n) begin
    if (rst_n == 1'b0) begin
      fence_req_q          <= 1'b0;
      fencei_req_and_ack_q <= 1'b0;
    end else begin

      // Flop fencei_flush_ack_i to break timing paths
      // fencei_flush_ack_i must be qualified with fencei_flush_req_o
      fencei_req_and_ack_q <= fencei_flush_req_o && fencei_flush_ack_i;

      // Set and clear fence_req_q based on FSM output. Also clear when fence.i handshake is completed
      if (fence_req_clr || (fencei_flush_req_o && fencei_flush_ack_i)) begin
        fence_req_q <= 1'b0;
      end
      else if (fence_req_set) begin
        fence_req_q <= 1'b1;
      end
    end
  end

  // Set flush request if we have a fence.i
  assign fencei_flush_req_o = fencei_in_wb ? fence_req_q : 1'b0;

  // minstret event
  always_ff @(posedge clk, negedge rst_n) begin
    if (rst_n == 1'b0) begin
      wb_counter_event <= 1'b0;
    end else begin
      // When the last part of an instruction reaches WB we may increment counters,
      // unless WB stage is halted. WB stage is halted due to either halt_wb or halt_limited wb (SLEEP with WFI/WFE in WB only).
      // A halted instruction in WB may or may not be killed later,
      // thus we cannot count it until we know for sure if it will retire.
      // i.e halt_wb due to debug will result in killed WB, while for fence.i it will retire.
      // Note that this event bit is further gated before sent to the actual counters in case
      // other conditions prevent counting.
      // CLIC: Exluding pointer fetches as they are not instructions.
      //       mret pointers will finish the mret->ptr sequence and will update wb_counter_event (instr_meta.mret_ptr is 1)
      if (ex_valid_i && wb_ready_i && last_op_ex_i && !id_ex_pipe_i.instr_meta.clic_ptr)  begin
        wb_counter_event <= 1'b1;
      end else begin
        // Keep event flag high while WB is halted, as we don't know if it will retire yet
        if (!ctrl_fsm_o.halt_wb && !ctrl_fsm_o.halt_limited_wb) begin
          wb_counter_event <= 1'b0;
        end
      end
    end
  end

  // Instruction sequences may not be interrupted/killed if the first operation has already been retired.
  // Flop set when first_op without either last_op or abort_op is done in WB, and cleared when last_op is done.
  always_ff @(posedge clk, negedge rst_n) begin
    if (rst_n == 1'b0) begin
      sequence_in_progress_wb <= 1'b0;
    end else begin
      if (!sequence_in_progress_wb) begin
        if (wb_valid_i && ex_wb_pipe_i.first_op && !(last_op_wb_i || abort_op_wb_i)) begin // wb_valid implies ex_wb_pipe.instr_valid
          sequence_in_progress_wb <= 1'b1;
        end
      end else begin
        // sequence_in_progress_wb is set, clear when last_op retires or sequence is aborted due to exceptions.
        if (wb_valid_i && (last_op_wb_i || abort_op_wb_i)) begin
          sequence_in_progress_wb <= 1'b0;
        end

        // No need to reset this flag on kill_wb.
        // When flag is high, there should be no reason to kill WB as they are blocked by the flag itself.
        // This is checked by an assertion, no killing while !sequence_interruptible

        // If debug entry is caused by a watchpoint address trigger, then abort_op_wb_i will be 1 and a debug entry is initiated.
        // This must also cause the sequence_in_progress_wb to be reset as the sequence is effectively terminated, although the instruction itself is not killed or completed
        // in a normal manner. As the WB stage is halted for debug entry on a watchcpoint trigger, wb_valid_i is zero.
        if (ex_wb_pipe_i.instr_valid && (|wpt_match_wb_i) && abort_op_wb_i) begin
          sequence_in_progress_wb <= 1'b0;
        end
      end
    end
  end

  // Logic to track first_op and last_op through the ID stage to detect unhaltable sequences
  // Flop set when first_op is done in ID, and cleared when last_op is done, or ID is killed
  // If the ID stage first_op has a known exception or trigger match the flop will not be set
  // as the controller will either take an exception or enter debug mode without finishing the sequence.
  always_ff @(posedge clk, negedge rst_n) begin
    if (rst_n == 1'b0) begin
      sequence_in_progress_id <= 1'b0;
    end else begin
      if (!sequence_in_progress_id) begin
        if (id_valid_i && ex_ready_i && first_op_id_i && !(last_op_id_i || abort_op_id_i)) begin // id_valid implies if_id_pipe.instr.valid
          sequence_in_progress_id <= 1'b1;
        end
      end else begin
        // sequence_in_progress_id is set, clear when last_op retires or ID stage is killed
        if (id_valid_i && ex_ready_i && (last_op_id_i || abort_op_id_i)) begin
          sequence_in_progress_id <= 1'b0;
        end
      end

      // Reset flag on a kill_id. May happen before sequence_in_progress_id gets set, or if a sequence gets an exception in the middle
      if (ctrl_fsm_o.kill_id) begin
        sequence_in_progress_id <= 1'b0;
      end
    end
  end

  // Flag for tracking CLIC pointer fetches. Only done when acking an SHV interrupt, not when an mret restarts a pointer fetch.
  always_ff @(posedge clk, negedge rst_n) begin
    if (rst_n == 1'b0) begin
      clic_ptr_in_progress_id <= 1'b0;
    end else begin
      if (!clic_ptr_in_progress_id) begin
        if (clic_ptr_in_progress_id_set) begin
          clic_ptr_in_progress_id <= 1'b1;
        end
      end else begin
        // clic_ptr_in_progress_id is set, clear when controller assert the clear-bit or ID stage is killed
        if (clic_ptr_in_progress_id_clear) begin
          clic_ptr_in_progress_id <= 1'b0;
        end
      end

      // When clic_ptr_in_progress_id is high, the ID stage can never be killed and thus no reset on kill_id is needed.
      // This is checked by an assertion. Taking an SHV interrupt kills the pipeline ensuring no exceptions may happen, and
      // the flag itself keeps debug or interrupts from killing the pipeline.
    end
  end

  // Flags for remembering if the core woke up due to a debug request or interrupt.
  always_ff @(posedge clk, negedge rst_n) begin
    if (rst_n == 1'b0) begin
      woke_to_debug_q <= 1'b0;
      woke_to_interrupt_q <= 1'b0;
    end else begin
      // Woke up to debug if no nmi was pending
      woke_to_debug_q     <= (ctrl_fsm_cs == SLEEP) && debug_req_i && !(pending_nmi);
      // Woke up to interrupts if no NMI or debug was pending
      woke_to_interrupt_q <= (ctrl_fsm_cs == SLEEP) && irq_wu_ctrl_i && !(pending_nmi || debug_req_i);
    end
  end

  /////////////////////
  // Debug state FSM //
  /////////////////////
  always_ff @(posedge clk , negedge rst_n) begin
    if (rst_n == 1'b0) begin
      debug_fsm_cs <= HAVERESET;
    end else begin
      debug_fsm_cs <= debug_fsm_ns;
    end
  end

  always_comb begin
    debug_fsm_ns = debug_fsm_cs;

    case (debug_fsm_cs)
      HAVERESET: begin
        if (debug_mode_n || (ctrl_fsm_ns == FUNCTIONAL)) begin
          if (debug_mode_n) begin
            debug_fsm_ns = HALTED;
          end else begin
            debug_fsm_ns = RUNNING;
          end
        end
      end

      RUNNING: begin
        if (debug_mode_n) begin
          debug_fsm_ns = HALTED;
        end
      end

      HALTED: begin
        if (!debug_mode_n) begin
          debug_fsm_ns = RUNNING;
        end
      end

      default: begin
        debug_fsm_ns = HAVERESET;
      end
    endcase
  end

  assign ctrl_fsm_o.debug_havereset = debug_fsm_cs[HAVERESET_INDEX];
  assign ctrl_fsm_o.debug_running   = debug_fsm_cs[RUNNING_INDEX];
  assign ctrl_fsm_o.debug_halted    = debug_fsm_cs[HALTED_INDEX];



  //---------------------------------------------------------------------------
  // eXtension interface
  //---------------------------------------------------------------------------

  generate
    if (X_EXT) begin : x_ext
      logic commit_valid_q; // Sticky bit for commit_valid
      logic commit_kill_q;  // Sticky bit for commit_kill
      logic kill_rejected;  // Signal used to kill rejected xif instructions

      // TODO:XIF Add assertion to check the following:
      // Every issue interface transaction (whether accepted or not) has an associated commit interface
      // transaction and both interfaces use a matching transaction ordering.

      // Commit an offloaded instruction in the first cycle where EX is not halted, or EX is killed.
      //       Only commit when there is an offloaded instruction in EX (accepted or not), and we have not
      //       previously signalled commit for the same instruction. Rejected xif instructions gets killed
      //       with commit_kill=1 (pipeline is not killed as we need to handle the illegal instruction in WB)
      // Can only allow commit when older instructions are guaranteed to complete without exceptions
      //       - EX is halted if offloaded in WB can cause an exception, causing below to evaluate to 0.
      assign xif_commit_if.commit_valid       = (!ctrl_fsm_o.halt_ex || ctrl_fsm_o.kill_ex) &&
                                                 (id_ex_pipe_i.xif_en && id_ex_pipe_i.instr_valid) &&
                                                 !commit_valid_q; // Make sure we signal only once per instruction

      assign xif_commit_if.commit.id          = id_ex_pipe_i.xif_meta.id;
      assign xif_commit_if.commit.commit_kill = xif_csr_error_i || ctrl_fsm_o.kill_ex || kill_rejected;

      // Signal commit_kill=1 to all instructions rejected by the eXtension interface
      assign kill_rejected = (id_ex_pipe_i.xif_en && !id_ex_pipe_i.xif_meta.accepted) && id_ex_pipe_i.instr_valid;

      // Signal (to EX stage), that an (attempted) offloaded instructions is killed (clears ex_wb_pipe.xif_en)
      assign ctrl_fsm_o.kill_xif = xif_commit_if.commit.commit_kill || commit_kill_q;

      // Flag used to make sure we only signal commit_valid once for each instruction
      always_ff @(posedge clk, negedge rst_n) begin : commit_valid_ctrl
        if (rst_n == 1'b0) begin
          commit_valid_q <= 1'b0;
          commit_kill_q  <= 1'b0;
        end else begin
          if ((ex_valid_i && wb_ready_i) || ctrl_fsm_o.kill_ex) begin
            commit_valid_q <= 1'b0;
            commit_kill_q  <= 1'b0;
          end else begin
            commit_valid_q <= (xif_commit_if.commit_valid || commit_valid_q);
            commit_kill_q  <= (xif_commit_if.commit.commit_kill || commit_kill_q);
          end
        end
      end

    end else begin : no_x_ext

      assign xif_commit_if.commit_valid       = '0;
      assign xif_commit_if.commit.id          = '0;
      assign xif_commit_if.commit.commit_kill = '0;
      assign ctrl_fsm_o.kill_xif              = 1'b0;

    end
  endgenerate

endmodule










// Description:    Bypass logic, hazard detection and stall control           //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_controller_bypass import cv32e40x_pkg::*;
#(
  parameter int unsigned REGFILE_NUM_READ_PORTS = 2,
  parameter a_ext_e      A_EXT                  = A_NONE
)
(
  // From decoder
  input  logic [REGFILE_NUM_READ_PORTS-1:0]     rf_re_id_i, // Read enables from decoder
  input rf_addr_t     rf_raddr_id_i[REGFILE_NUM_READ_PORTS],// Read addresses from decoder

  // Pipeline registers
  input if_id_pipe_t  if_id_pipe_i,
  input id_ex_pipe_t  id_ex_pipe_i,
  input ex_wb_pipe_t  ex_wb_pipe_i,

  // From ID
  input  logic        alu_jmpr_id_i,              // ALU jump register (JALR)
  input  logic        sys_mret_id_i,              // mret in ID
  input  logic        csr_en_raw_id_i,            // CSR in ID (not gated with deassert)

  // From EX
  input  logic        csr_counter_read_i,         // CSR is reading a counter (EX).
  input  logic        csr_mnxti_read_i,           // CSR is reading mnxti (EX)

  // From WB
  input  logic        wb_ready_i,                 // WB stage is ready
  input  logic        csr_irq_enable_write_i,     // WB is writing to a CSR that may enable an interrupt.

  // From LSU
  input  lsu_atomic_e lsu_atomic_ex_i,
  input  lsu_atomic_e lsu_atomic_wb_i,
  input  logic        lsu_bus_busy_i,

  // From CS registers
  input  csr_hz_t     csr_hz_i,

  // Controller Bypass outputs
  output ctrl_byp_t   ctrl_byp_o
);

  logic [REGFILE_NUM_READ_PORTS-1:0] rf_rd_ex_match;            // Register file address match (ID vs. EX). Not qualified with rf_we_ex yet.
  logic                              rf_rd_ex_jalr_match;
  logic [REGFILE_NUM_READ_PORTS-1:0] rf_rd_wb_match;            // Register file address match (ID vs. WB). Not qualified with rf_we_wb yet.
  logic                              rf_rd_wb_jalr_match;
  logic [REGFILE_NUM_READ_PORTS-1:0] rf_rd_ex_hz;
  logic [REGFILE_NUM_READ_PORTS-1:0] rf_rd_wb_hz;

  logic                              csr_write_in_ex_wb;        // Detect CSR write in EX or WB (implicit and explicit)
  logic                              csr_write_in_ex;           // Detect CSR write in EX (implicit and explicit)
  logic                              csr_write_in_wb;           // Detect CSR write in WB (implicit and explicit)
  logic                              csr_impl_write_in_ex;      // Detect implicit CSR write in EX
  logic                              csr_impl_write_in_wb;      // Detect implicit CSR write in WB
  logic                              csr_expl_hz_ex;            // Explicit CSR hazard in EX

  logic                              rf_we_ex;                  // EX register file write enable
  logic                              rf_we_wb;                  // WB register file write enable
  logic                              lsu_en_wb;                 // WB lsu_en

  rf_addr_t                          rf_waddr_ex;               // EX rf_waddr
  rf_addr_t                          rf_waddr_wb;               // WB rf_waddr

  logic                              sys_mret_unqual_id;        // MRET in ID (not qualified with sys_en)
  logic                              csr_impl_rd_unqual_id;     // Implicit CSR read in ID (not qualified)
  logic                              jmpr_unqual_id;            // JALR in ID (not qualified with alu_en)
  logic                              tbljmp_unqual_id;          // Table jump in ID (not qualified with alu_en)

  assign rf_we_ex = id_ex_pipe_i.rf_we && id_ex_pipe_i.instr_valid;
  assign rf_we_wb = ex_wb_pipe_i.rf_we && ex_wb_pipe_i.instr_valid;
  assign lsu_en_wb = ex_wb_pipe_i.lsu_en && ex_wb_pipe_i.instr_valid;

  assign rf_waddr_ex = id_ex_pipe_i.rf_waddr;
  assign rf_waddr_wb = ex_wb_pipe_i.rf_waddr; // TODO:XIF If XIF OoO is allowed, we need to look at WB stage outputs instead

  // The following unqualified signals are such that they can have a false positive (but no false negative).
  //
  // There are two reasons why these signals are considered unqualified:
  // - The corresponding _en signal is not used
  // - A raw _en signal is used (i.e. deassert_we is ignored)
  //
  // This can lead to stall cycles (via jalr_stall or csr_stall) when they should not actually be needed.
  // Such cases are however rare as the difference between qualified and unqualified signals will only
  // occur in case that deassert_we = 1. Permanent stalls are avoided because the EX, WB stages will
  // eventually empty out removing that reasons for stall conditions.

  assign sys_mret_unqual_id = sys_mret_id_i && if_id_pipe_i.instr_valid;
  assign jmpr_unqual_id = alu_jmpr_id_i && if_id_pipe_i.instr_valid;
  assign tbljmp_unqual_id = if_id_pipe_i.instr_meta.tbljmp && if_id_pipe_i.instr_valid;

  // Any implicit CSR reads from the ID stage
  // mret reads mepc and mcause
  // tablejumps read jvt
  assign csr_impl_rd_unqual_id = sys_mret_unqual_id || tbljmp_unqual_id;

  // Detect any implicit CSR write currently in in EX (actual write will happen in WB)
  // mret, dret and CLIC/mret pointers implicitly writes to CSRs. (dret is killing IF/ID/EX once it is in WB and can be disregarded here.
  // Some CSR instructions perform writes to other CSRs, encoded by 'ex_wb_pipe_i.csr_impl_wr'
  assign csr_impl_write_in_ex = (id_ex_pipe_i.instr_valid &&
                                 (((id_ex_pipe_i.sys_en && id_ex_pipe_i.sys_mret_insn) || id_ex_pipe_i.instr_meta.clic_ptr || id_ex_pipe_i.instr_meta.mret_ptr) ||
                                  (id_ex_pipe_i.csr_en && csr_hz_i.impl_wr_ex)));

  // Detect any implicit CSR write in WB
  // mret, dret and CLIC/mret pointers implicitly writes to CSRs. (dret is killing IF/ID/EX once it is in WB and can be disregarded here.
  // Some CSR instructions perform writes to other CSRs, encoded by 'ex_wb_pipe_i.csr_impl_wr'
  assign csr_impl_write_in_wb = (ex_wb_pipe_i.instr_valid &&
                                 (((ex_wb_pipe_i.sys_en && ex_wb_pipe_i.sys_mret_insn) || ex_wb_pipe_i.instr_meta.clic_ptr || ex_wb_pipe_i.instr_meta.mret_ptr) ||
                                  (ex_wb_pipe_i.csr_en && ex_wb_pipe_i.csr_impl_wr)));

  // Detect implicit and explicit CSR writes in EX
  assign csr_write_in_ex = id_ex_pipe_i.instr_valid && (id_ex_pipe_i.csr_en || csr_impl_write_in_ex);

  // Detect implicit and explicit CSR writes in WB
  assign csr_write_in_wb = ex_wb_pipe_i.instr_valid && (ex_wb_pipe_i.csr_en || csr_impl_write_in_wb);

  // Any CSR access (implicit or explicit) in any of EX and WB stages
  assign csr_write_in_ex_wb = csr_write_in_ex || csr_write_in_wb;

  // Detect RAW hazard for explicit CSR accesses in EX vs WB
  assign csr_expl_hz_ex = (csr_hz_i.expl_re_ex && csr_hz_i.expl_we_wb) &&
                          (csr_hz_i.expl_raddr_ex == csr_hz_i.expl_waddr_wb);

  /////////////////////////////////////////////////////////////
  //  ____  _        _ _    ____            _             _  //
  // / ___|| |_ __ _| | |  / ___|___  _ __ | |_ _ __ ___ | | //
  // \___ \| __/ _` | | | | |   / _ \| '_ \| __| '__/ _ \| | //
  //  ___) | || (_| | | | | |__| (_) | | | | |_| | | (_) | | //
  // |____/ \__\__,_|_|_|  \____\___/|_| |_|\__|_|  \___/|_| //
  //                                                         //
  /////////////////////////////////////////////////////////////

  // Stall ID when instruction that can trigger sleep (e.g. WFI or WFE) is active in EX.
  // Prevent load/store following a sleep instruction in the pipeline
  assign ctrl_byp_o.sleep_stall = (id_ex_pipe_i.sys_en && (id_ex_pipe_i.sys_wfi_insn || id_ex_pipe_i.sys_wfe_insn) && id_ex_pipe_i.instr_valid);

  // Stall ID when mnxti CSR is accessed in EX
  // This is needed because the data bypass from EX uses csr_rdata, and for mnxti this is actually mstatus and not the result
  // that will be written to the register file. Could be optimized to only stall when the result from the CSR instruction is used in ID,
  // but the common usecase is a CSR access followed by a branch using the mnxti result in the RF, so it would likely stall in most cases anyway.
  assign ctrl_byp_o.mnxti_id_stall = csr_mnxti_read_i;

  // Stall EX stage when an mnxti is in EX and an LSU instruction is in WB.
  // This is needed to make sure that any external interrupt clearing (due to a LSU instruction) gets picked
  // up correctly by the mnxti access.
  assign ctrl_byp_o.mnxti_ex_stall = csr_mnxti_read_i && (ex_wb_pipe_i.lsu_en && ex_wb_pipe_i.instr_valid);

  genvar i;
  generate
    for(i=0; i<REGFILE_NUM_READ_PORTS; i++) begin : gen_forward_signals
      // Does register file read address match write address in EX (excluding R0)?
      assign rf_rd_ex_match[i] = (rf_waddr_ex == rf_raddr_id_i[i]) && |rf_raddr_id_i[i] && rf_re_id_i[i];

      // Does register file read address match write address in WB (excluding R0)?
      assign rf_rd_wb_match[i] = (rf_waddr_wb == rf_raddr_id_i[i]) && |rf_raddr_id_i[i] && rf_re_id_i[i];

      // Load-read hazard (for any instruction following a load)
      assign rf_rd_ex_hz[i] = rf_rd_ex_match[i];
      assign rf_rd_wb_hz[i] = rf_rd_wb_match[i];
    end
  endgenerate

  // JALR rs1 match (rf_re_id_i[0] implied by JALR).
  // Not qualified yet with JALR instruction nor with read enable (implied by JALR)
  assign rf_rd_ex_jalr_match = (rf_waddr_ex == rf_raddr_id_i[0]) && |rf_raddr_id_i[0];
  assign rf_rd_wb_jalr_match = (rf_waddr_wb == rf_raddr_id_i[0]) && |rf_raddr_id_i[0];

  always_comb
  begin
    ctrl_byp_o.load_stall          = 1'b0;
    ctrl_byp_o.deassert_we         = 1'b0;
    ctrl_byp_o.csr_stall_id        = 1'b0;
    ctrl_byp_o.csr_stall_ex        = 1'b0;
    ctrl_byp_o.minstret_stall      = 1'b0;
    ctrl_byp_o.irq_enable_stall    = 1'b0;

    // deassert WE when the core has an exception in ID (ins converted to nop and propagated to WB)
    // Also deassert for trigger match, as with dcsr.timing==0 we do not execute before entering debug mode
    // CLIC pointer fetches go through the pipeline, but no write enables should be active.
    if (if_id_pipe_i.instr.bus_resp.err || !(if_id_pipe_i.instr.mpu_status == MPU_OK) || (|if_id_pipe_i.trigger_match) ||
        if_id_pipe_i.instr_meta.clic_ptr || if_id_pipe_i.instr_meta.mret_ptr) begin
      ctrl_byp_o.deassert_we = 1'b1;
    end

    // Stall because of load or XIF operation
    if (
        ((id_ex_pipe_i.lsu_en || id_ex_pipe_i.xif_en) && rf_we_ex && |rf_rd_ex_hz) || // load-use hazard (EX)
        (!wb_ready_i                                  && rf_we_wb && |rf_rd_wb_hz)    // load-use hazard (WB during wait-state)
       )
    begin
      ctrl_byp_o.load_stall  = 1'b1;
    end

    // Stall because of jalr path. Stall if a result is to be forwarded to the PC except if result from WB is an ALU result.
    // No need to deassert anything in ID as ID stage is stalled anyway. JALR implies rf_re_id_i[0].
    // Also stalling when a CSR access to MNXTI is in WB. This is because the jalr forward uses the ex_wb_pipe.rf_wdata as data,
    // and forwarding the CSR result (pointer address for mnxti) would need the forward mux to also include the pointer address from cs_registers.
    // Cannot use wb_stage.rf_wdata_o due to the timing path from the data OBI.
    if (jmpr_unqual_id &&
         ((rf_we_wb && rf_rd_wb_jalr_match && lsu_en_wb) ||
          (rf_we_wb && rf_rd_wb_jalr_match && (ex_wb_pipe_i.csr_mnxti_access && ex_wb_pipe_i.csr_en)) ||
          (rf_we_ex && rf_rd_ex_jalr_match))) begin
      ctrl_byp_o.jalr_stall = 1'b1;
    end else begin
      ctrl_byp_o.jalr_stall = 1'b0;
    end

    ////////////////
    // CSR stalls //
    ////////////////

    // Implicit CSR read in ID: Conservatively stall on any implicit CSR write in EX or WB
    // Implicit CSR read in ID: Conservatively stall on any explicit CSR write in EX or WB
    // Implicit CSR read in EX: Conservatively stall on any implicit CSR write in WB
    // Implicit CSR read in EX: Conservatively stall on any explicit CSR write in WB
    // Explicit CSR read in EX: Conservatively stall on any implicit CSR write in WB
    // Explicit CSR read in EX: Precise stall on any explicit CSR write in WB

    // Stall ID because of an implicit CSR read is in ID while CSR (implicit or explicit) is written in EX/WB
    // This stall is very conservative as it stalls on any CSR access in EX or WB.
    // mret reads mcause and mepc (via controller_fsm) in the ID stage
    // tablejumps read jvt in the ID stage
    if (csr_impl_rd_unqual_id && csr_write_in_ex_wb) begin
      ctrl_byp_o.csr_stall_id = 1'b1;
    end

    // Stall EX because of
    // 1: an implicit CSR read is being performed while an implicit or explicit CSR write is in WB,
    // 2: or an explicit CSR read is in EX while any implicit write is in WB (conservative stall)
    // 3: or an explicit CSR read is in EX while an explicit CSR write to the same CSR is in WB. (exact stall)
    //
    // Cases like accesses to mscratchcswl and mnxti which reads multiple CSRs are handled by 1 above.
    if ((csr_hz_i.impl_re_ex && csr_write_in_wb) ||
        (id_ex_pipe_i.csr_en && id_ex_pipe_i.instr_valid && csr_impl_write_in_wb) ||
        csr_expl_hz_ex) begin

      ctrl_byp_o.csr_stall_ex = 1'b1;
    end

    // Stall (EX) due to performance counter read
    // csr_counter_read_i is derived from csr_raddr, which is gated with id_ex_pipe.csr_en and id_ex_pipe.instr_valid
    if (csr_counter_read_i && ex_wb_pipe_i.instr_valid) begin
      ctrl_byp_o.minstret_stall = 1'b1;
    end

    // Stall EX when an interrupt may be enabled from WB while there is a LSU instruction in EX.
    if (csr_irq_enable_write_i && (id_ex_pipe_i.instr_valid && id_ex_pipe_i.lsu_en)) begin
      ctrl_byp_o.irq_enable_stall = 1'b1;
    end
  end

  generate
    if (A_EXT != A_NONE) begin : atomic_stall
      always_comb begin
        ctrl_byp_o.atomic_stall = 1'b0;

        // Stall EX for the following two scenarios
        // 1: There is an atomic instruction in EX while we have outstanding transactions on the bus
        // 2: There is any LSU instruction in EX while there is an outstanding atomic transfer in progress
        if ((id_ex_pipe_i.lsu_en && (lsu_atomic_ex_i != AT_NONE) && id_ex_pipe_i.instr_valid) ||
            (id_ex_pipe_i.lsu_en && id_ex_pipe_i.instr_valid && ex_wb_pipe_i.lsu_en && (lsu_atomic_wb_i != AT_NONE) && ex_wb_pipe_i.instr_valid)) begin
            ctrl_byp_o.atomic_stall = lsu_bus_busy_i;
        end
      end
    end else begin : no_atomic_stall
      assign ctrl_byp_o.atomic_stall = 1'b0;
    end
  endgenerate

  assign ctrl_byp_o.id_stage_abort = ctrl_byp_o.deassert_we;

  // Forwarding control unit
  always_comb
  begin
    // default assignements
    ctrl_byp_o.operand_a_fw_mux_sel = SEL_REGFILE;
    ctrl_byp_o.operand_b_fw_mux_sel = SEL_REGFILE;
    ctrl_byp_o.jalr_fw_mux_sel      = SELJ_REGFILE;

    // Forwarding WB -> ID
    if (rf_we_wb) begin
      if (rf_rd_wb_match[0]) begin
        ctrl_byp_o.operand_a_fw_mux_sel = SEL_FW_WB;
      end
      if (rf_rd_wb_match[1]) begin
        ctrl_byp_o.operand_b_fw_mux_sel = SEL_FW_WB;
      end
    end

    // Forwarding EX -> ID (not actually used when there is a load in EX)
    if (rf_we_ex) begin
      if (rf_rd_ex_match[0]) begin
        ctrl_byp_o.operand_a_fw_mux_sel = SEL_FW_EX;
      end
      if (rf_rd_ex_match[1]) begin
        ctrl_byp_o.operand_b_fw_mux_sel = SEL_FW_EX;
      end
    end

    // Forwarding WB->ID for the jump register path
    // Only used if WB is writing back an ALU result. No forwarding for load result because of timing reasons.
    // Non qualified rf_rd_wb_jalr_match is used as it is a don't care if jmpr_unqual_id = 0 or jalr_stall = 1.
    if (rf_we_wb) begin
      if (rf_rd_wb_jalr_match) begin
        ctrl_byp_o.jalr_fw_mux_sel = SELJ_FW_WB;
      end
    end
  end

  // Stall EX if offloaded instruction in WB may trigger an exception
  assign ctrl_byp_o.xif_exception_stall = ex_wb_pipe_i.xif_en && ex_wb_pipe_i.xif_meta.exception && ex_wb_pipe_i.instr_valid;

endmodule









// Description:    Main CPU controller of the processor                       //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_controller import cv32e40x_pkg::*;
#(
  parameter bit          X_EXT                  = 0,
  parameter a_ext_e      A_EXT                  = A_NONE,
  parameter int unsigned REGFILE_NUM_READ_PORTS = 2,
  parameter bit          CLIC                   = 0,
  parameter int unsigned CLIC_ID_WIDTH          = 5,
  parameter rv32_e       RV32                   = RV32I,
  parameter bit          DEBUG                  = 1
)
(
  input  logic        clk,                        // Gated clock
  input  logic        rst_n,

  input  logic        fetch_enable_i,             // Start the decoding

  input  logic        if_valid_i,

  // From IF stage
  input  logic [31:0] pc_if_i,
  input  logic        last_op_if_i,
  input  logic        abort_op_if_i,

  // from IF/ID pipeline
  input  if_id_pipe_t if_id_pipe_i,
  input  logic        alu_jmp_id_i,               // Jump (JAL, JALR)
  input  logic        alu_jmpr_id_i,              // Jump register (JALR)
  input  logic        alu_en_id_i,
  input  logic        sys_en_id_i,
  input  logic        sys_mret_id_i,
  input  logic        csr_en_raw_id_i,
  input  logic        first_op_id_i,
  input  logic        last_op_id_i,
  input  logic        abort_op_id_i,

  input  id_ex_pipe_t id_ex_pipe_i,

  input  ex_wb_pipe_t ex_wb_pipe_i,
  input  mpu_status_e mpu_status_wb_i,            // MPU status (WB stage)
  input  logic [31:0] wpt_match_wb_i,             // LSU watchpoint trigger in WB
  input  align_status_e align_status_wb_i,        // Aligned status (atomics and mret pointers) in WB

  // Last operation bits
  input  logic        last_op_ex_i,               // EX contains the last operation of an instruction
  input  logic        last_op_wb_i,               // WB contains the last operation of an instruction

  input  logic        abort_op_wb_i,

  // LSU
  input  logic        data_stall_wb_i,            // WB stalled by LSU
  input  lsu_err_wb_t lsu_err_wb_i,               // LSU bus error in WB stage
  input  logic        lsu_busy_i,                 // LSU is busy with outstanding transfers or is initiating a new transfer
  input  logic        lsu_bus_busy_i,             // LSU is busy with outstanding transfers
  input  logic        lsu_interruptible_i,        // LSU may be interrupted
  input  logic        lsu_valid_wb_i,             // LSU is valid in WB (factors in rvalid from either OBI bus or write buffer)
  input  lsu_atomic_e lsu_atomic_ex_i,
  input  lsu_atomic_e lsu_atomic_wb_i,

  // jump/branch signals
  input  logic        branch_decision_ex_i,       // branch decision signal from EX ALU

  // Interrupt Controller Signals
  input  logic        irq_req_ctrl_i,
  input  logic [9:0]  irq_id_ctrl_i,
  input  logic        irq_wu_ctrl_i,
  input  logic        irq_clic_shv_i,
  input  logic [7:0]  irq_clic_level_i,
  input  logic [1:0]  irq_clic_priv_i,

  input  logic        wu_wfe_i,

  input logic  [1:0]  mtvec_mode_i,
  input  mcause_t     mcause_i,
  input  mintstatus_t mintstatus_i,

  input  logic        etrigger_wb_i,

  input  logic        csr_wr_in_wb_flush_i,

  // Debug Signal
  input  logic        debug_req_i,
  input  dcsr_t       dcsr_i,


  // CSR raddr in ex
  input  logic        csr_counter_read_i,         // A performance counter is read in CSR (EX)
  input  logic        csr_mnxti_read_i,           // MNXTI is read in CSR (EX)

  input  logic        csr_irq_enable_write_i,     // An interrupt may be enabled by a write (WB)
  input  csr_hz_t     csr_hz_i,

  input logic [REGFILE_NUM_READ_PORTS-1:0] rf_re_id_i,
  input rf_addr_t     rf_raddr_id_i[REGFILE_NUM_READ_PORTS],

  input  logic        id_ready_i,               // ID stage is ready
  input  logic        id_valid_i,               // ID stage is done
  input  logic        ex_ready_i,               // EX stage is ready
  input  logic        ex_valid_i,               // EX stage is done
  input  logic        wb_ready_i,               // WB stage is ready
  input  logic        wb_valid_i,               // WB stage is done

  // Data OBI interface monitor
  cv32e40x_if_c_obi.monitor m_c_obi_data_if,

  // Outputs
  output ctrl_byp_t   ctrl_byp_o,
  output ctrl_fsm_t   ctrl_fsm_o,               // FSM outputs

  // Fencei flush handshake
  output logic        fencei_flush_req_o,
  input logic         fencei_flush_ack_i,

  // eXtension interface
  cv32e40x_if_xif.cpu_commit xif_commit_if,
  input                      xif_csr_error_i
);

  // Main FSM and debug FSM
  cv32e40x_controller_fsm
  #(
    .X_EXT                       ( X_EXT                    ),
    .CLIC                        ( CLIC                     ),
    .CLIC_ID_WIDTH               ( CLIC_ID_WIDTH            ),
    .RV32                        ( RV32                     ),
    .DEBUG                       ( DEBUG                    )
  )
  controller_fsm_i
  (
    // Clocks and reset
    .clk                         ( clk                      ),
    .rst_n                       ( rst_n                    ),

    .fetch_enable_i              ( fetch_enable_i           ),

    .ctrl_byp_i                  ( ctrl_byp_o               ),

    .if_valid_i                  ( if_valid_i               ),
    .pc_if_i                     ( pc_if_i                  ),
    .last_op_if_i                ( last_op_if_i             ),
    .abort_op_if_i               ( abort_op_if_i            ),

    // From ID stage
    .if_id_pipe_i                ( if_id_pipe_i             ),
    .id_ready_i                  ( id_ready_i               ),
    .id_valid_i                  ( id_valid_i               ),
    .alu_jmp_id_i                ( alu_jmp_id_i             ),
    .sys_mret_id_i               ( sys_mret_id_i            ),
    .alu_en_id_i                 ( alu_en_id_i              ),
    .sys_en_id_i                 ( sys_en_id_i              ),
    .first_op_id_i               ( first_op_id_i            ),
    .last_op_id_i                ( last_op_id_i             ),
    .abort_op_id_i               ( abort_op_id_i            ),

    // From EX stage
    .id_ex_pipe_i                ( id_ex_pipe_i             ),
    .branch_decision_ex_i        ( branch_decision_ex_i     ),
    .ex_ready_i                  ( ex_ready_i               ),
    .ex_valid_i                  ( ex_valid_i               ),
    .last_op_ex_i                ( last_op_ex_i             ),

    // From WB stage
    .ex_wb_pipe_i                ( ex_wb_pipe_i             ),
    .lsu_err_wb_i                ( lsu_err_wb_i             ),
    .mpu_status_wb_i             ( mpu_status_wb_i          ),
    .align_status_wb_i           ( align_status_wb_i        ),
    .data_stall_wb_i             ( data_stall_wb_i          ),
    .wb_ready_i                  ( wb_ready_i               ),
    .wb_valid_i                  ( wb_valid_i               ),
    .last_op_wb_i                ( last_op_wb_i             ),
    .abort_op_wb_i               ( abort_op_wb_i            ),
    .lsu_valid_wb_i              ( lsu_valid_wb_i           ),
    .wpt_match_wb_i              ( wpt_match_wb_i           ),

    .lsu_interruptible_i         ( lsu_interruptible_i      ),

    // CSR write strobes
    .csr_wr_in_wb_flush_i        ( csr_wr_in_wb_flush_i     ),

    // Interrupt Controller Signals
    .irq_req_ctrl_i              ( irq_req_ctrl_i           ),
    .irq_id_ctrl_i               ( irq_id_ctrl_i            ),
    .irq_wu_ctrl_i               ( irq_wu_ctrl_i            ),
    .irq_clic_shv_i              ( irq_clic_shv_i           ),
    .irq_clic_level_i            ( irq_clic_level_i         ),
    .irq_clic_priv_i             ( irq_clic_priv_i          ),

    .wu_wfe_i                    ( wu_wfe_i                 ),

    .mtvec_mode_i                ( mtvec_mode_i             ),

    .etrigger_wb_i               ( etrigger_wb_i            ),

    // Debug Signal
    .debug_req_i                 ( debug_req_i              ),
    .dcsr_i                      ( dcsr_i                   ),
    .mcause_i                    ( mcause_i                 ),
    .mintstatus_i                ( mintstatus_i             ),

    // Fencei flush handshake
    .fencei_flush_ack_i          ( fencei_flush_ack_i       ),
    .fencei_flush_req_o          ( fencei_flush_req_o       ),

    .lsu_busy_i                  ( lsu_busy_i               ),

   // Data OBI interface monitor
    .m_c_obi_data_if             ( m_c_obi_data_if          ),

    // Outputs
    .ctrl_fsm_o                  ( ctrl_fsm_o               ),

    // eXtension interface
    .xif_commit_if               ( xif_commit_if            ),
    .xif_csr_error_i             ( xif_csr_error_i          )
  );


  // Hazard/bypass/stall control instance
  cv32e40x_controller_bypass
  #(
    .REGFILE_NUM_READ_PORTS     ( REGFILE_NUM_READ_PORTS   ),
    .A_EXT                      ( A_EXT                    )
  )
  bypass_i
  (
    // From controller_fsm
    .if_id_pipe_i               ( if_id_pipe_i             ),
    .id_ex_pipe_i               ( id_ex_pipe_i             ),
    .ex_wb_pipe_i               ( ex_wb_pipe_i             ),

    // From ID
    .rf_re_id_i                 ( rf_re_id_i               ),
    .rf_raddr_id_i              ( rf_raddr_id_i            ),
    .alu_jmpr_id_i              ( alu_jmpr_id_i            ),
    .sys_mret_id_i              ( sys_mret_id_i            ),
    .csr_en_raw_id_i            ( csr_en_raw_id_i          ),

    // From EX
    .csr_counter_read_i         ( csr_counter_read_i       ),
    .csr_mnxti_read_i           ( csr_mnxti_read_i         ),

    // From WB
    .wb_ready_i                 ( wb_ready_i               ),
    .csr_irq_enable_write_i     ( csr_irq_enable_write_i   ),

    // From LSU
    .lsu_atomic_ex_i            ( lsu_atomic_ex_i          ),
    .lsu_atomic_wb_i            ( lsu_atomic_wb_i          ),
    .lsu_bus_busy_i             ( lsu_bus_busy_i           ),

    .csr_hz_i                   ( csr_hz_i                 ),

    // Outputs
    .ctrl_byp_o                 ( ctrl_byp_o               )
  );

endmodule









// Description:    Controller for handling CLIC interrupts                    //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_clic_int_controller import cv32e40x_pkg::*;
#(
  parameter int unsigned CLIC_ID_WIDTH = 5
)
(
  input  logic                       clk,
  input  logic                       rst_n,

  // CLIC interface
  input  logic                       clic_irq_i,                // CLIC interrupt pending
  input  logic [CLIC_ID_WIDTH-1:0] clic_irq_id_i,               // ID of pending interrupt
  input  logic [7:0]                 clic_irq_level_i,          // Level of pending interrupt
  input  logic [1:0]                 clic_irq_priv_i,           // Privilege level of pending interrupt (always machine mode) (not used)
  input  logic                       clic_irq_shv_i,            // Is pending interrupt vectored?

  // To controller
  output logic                       irq_req_ctrl_o,
  output logic [9:0]                 irq_id_ctrl_o,             // Max width - unused bits are tied off
  output logic                       irq_wu_ctrl_o,
  output logic                       irq_clic_shv_o,
  output logic [7:0]                 irq_clic_level_o,
  output logic [1:0]                 irq_clic_priv_o,

  // From cs_registers
  input  mstatus_t                   mstatus_i,                 // Current mstatus from CSR
  input  logic [7:0]                 mintthresh_th_i,           // Current interrupt threshold from CSR
  input  mintstatus_t                mintstatus_i,              // Current mintstatus from CSR
  input  mcause_t                    mcause_i,                  // Current mcause from CSR
  input  privlvl_t                   priv_lvl_i,                // Current privilege level of core

  // To cs_registers
  output logic                       mnxti_irq_pending_o,       // An interrupt is available to the mnxti CSR read
  output logic [CLIC_ID_WIDTH-1:0]   mnxti_irq_id_o,            // The id of the availble mnxti interrupt
  output logic [7:0]                 mnxti_irq_level_o          // Level of the available interrupt
);

  logic                       global_irq_enable;
  logic  [7:0]                effective_irq_level;              // Effective interrupt level

  // Flops for breaking timing path to instruction interface
  logic                       clic_irq_q;
  logic [CLIC_ID_WIDTH-1:0]   clic_irq_id_q;
  logic [7:0]                 clic_irq_level_q;
  logic                       clic_irq_shv_q;

  logic                       unused_signals;

  // Register interrupt input (on gated clock). The wake-up logic will
  // observe clic_irq_i as well, but in all other places clic_irq_q will be used to
  // avoid timing paths from clic_irq_i to instr_*_o

  always_ff @(posedge clk, negedge rst_n)
  begin
    if (rst_n == 1'b0) begin
      clic_irq_q  <= 1'b0;
    end else begin
      clic_irq_q  <= clic_irq_i;
    end
  end

  // Flop all irq inputs to break timing paths through the controller.
  always_ff @(posedge clk, negedge rst_n)
  begin
    if (rst_n == 1'b0) begin
      clic_irq_id_q     <= '0;
      clic_irq_level_q  <= '0;
      clic_irq_shv_q    <= 1'b0;
    end else begin
      if (clic_irq_i) begin
        clic_irq_id_q    <= clic_irq_id_i;
        clic_irq_level_q <= clic_irq_level_i;
        clic_irq_shv_q   <= clic_irq_shv_i;
      end
    end
  end

  // Global interrupt enable
  //
  // Machine mode interrupts are always enabled when in a lower privilege mode.

  assign global_irq_enable = mstatus_i.mie || (priv_lvl_i < PRIV_LVL_M);

  // Effective interrupt level
  //
  // The interrupt-level threshold is only valid when running in the associated privilege mode.

  assign effective_irq_level = (mintthresh_th_i > mintstatus_i.mil) ? mintthresh_th_i : mintstatus_i.mil;

  ///////////////////////////
  // Outputs to controller //
  ///////////////////////////

  // Request to take interrupt if there is a pending-and-enabled interrupt, interrupts are enabled globally,
  // and the incoming irq level is above the core's current effective interrupt level. Machine mode interrupts
  // during user mode shall always be taken if their level is > 0

  // Cannot use flopped comparator results from the irq_wu_ctrl_o logic, as the effective_irq_level
  // may change from one cycle to the next due to CSR updates. However, as the irq_wu_ctrl_o is only used
  // when the core is in the SLEEP state (where no CSR updates can happen), an assertion exists to check that the cycle after a core wakes up
  // due to an interupt the irq_req_ctrl_o must be asserted if global_irq_enable == 1;
  assign irq_req_ctrl_o = clic_irq_q && global_irq_enable &&
    ((priv_lvl_i == PRIV_LVL_M) ? (clic_irq_level_q > effective_irq_level) : (clic_irq_level_q > '0));

  // Pass on interrupt ID
  assign irq_id_ctrl_o = 10'(clic_irq_id_q);  // Casting into max with of 10 bits.

  // Wake-up signal based on unregistered IRQ such that wake-up can be caused if no clock is present
  //
  // Wakeup scenarios:
  //
  // - priv mode == current, irq i is max (done in external CLIC), level > max(mintstatus.mil, mintthresh.th)
  // - priv mode  > current, irq i is max (done in external CLIC), level != 0

  assign irq_wu_ctrl_o = clic_irq_i &&
    ((priv_lvl_i == PRIV_LVL_M) ? (clic_irq_level_i > effective_irq_level) : (clic_irq_level_i > '0));

  assign irq_clic_shv_o = clic_irq_shv_q;

  assign irq_clic_level_o = clic_irq_level_q;

  // Take all interrupts into machine mode. clic_irq_priv_i not used on purpose.
  assign irq_clic_priv_o = PRIV_LVL_M;

  ///////////////////////////
  // Outputs for mnxti CSR //
  ///////////////////////////

  // The outputs for mnxti will only be used within cs_registers when a CSR instruction is accessing mnxti
  // The mxnti path to interrupts does not take mstatus.mie or dcsr.stepie into account.
  assign mnxti_irq_pending_o = clic_irq_q &&
    (clic_irq_level_q > mcause_i.mpil) &&
    (clic_irq_level_q > mintthresh_th_i)  &&
    !clic_irq_shv_q;

  // If mnxti_irq_pending is true, the currently flopped ID and level will be sent to cs_registers
  // for use in the function pointer and CSR side effects.
  // Using native CLIC_ID_WIDTH for cleaner pointer concatenation in cs_registers.

  assign mnxti_irq_id_o    = clic_irq_id_q;
  assign mnxti_irq_level_o = clic_irq_level_q;

  // Unused signals
  //
  // clic_irq_priv_i is not used on purpose. It is required to be tied to machine mode.
  // All interrupts are taken into machine mode.

  assign unused_signals = |clic_irq_priv_i;

endmodule







// Description:    Basic Interrupt Controller                                 //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_int_controller import cv32e40x_pkg::*;
(
  input  logic        clk,
  input  logic        rst_n,

  // External interrupt lines
  input  logic [31:0] irq_i,                    // Level-triggered interrupt inputs

  // To controller
  output logic        irq_req_ctrl_o,
  output logic  [4:0] irq_id_ctrl_o,
  output logic        irq_wu_ctrl_o,

  // From cs_registers
  input  logic [31:0] mie_i,                    // MIE CSR
  input  mstatus_t    mstatus_i,                // MSTATUS CSR
  input  privlvl_t    priv_lvl_i,               // Current privilege level of core

  // To cs_registers
  output logic [31:0] mip_o                     // MIP CSR
);

  logic        global_irq_enable;
  logic [31:0] irq_local_qual;
  logic [31:0] irq_q;

  // Register all interrupt inputs (on gated clock). The wake-up logic will
  // observe irq_i as well, but in all other places irq_q will be used to
  // avoid timing paths from irq_i to instr_*_o

  always_ff @(posedge clk, negedge rst_n)
  begin
    if (rst_n == 1'b0) begin
      irq_q <= '0;
    end else begin
      irq_q <= irq_i & IRQ_MASK;
    end
  end

  // MIP CSR
  assign mip_o = irq_q;

  // Qualify registered IRQ with MIE CSR to compute locally enabled IRQs
  assign irq_local_qual = irq_q & mie_i;

  // Wake-up signal based on unregistered IRQ such that wake-up can be caused if no clock is present
  assign irq_wu_ctrl_o = |(irq_i & mie_i);

  // Global interrupt enable
  assign global_irq_enable = mstatus_i.mie || (priv_lvl_i < PRIV_LVL_M);

  // Request to take interrupt if there is a locally enabled interrupt while interrupts are also enabled globally
  assign irq_req_ctrl_o = (|irq_local_qual) && global_irq_enable;

  // Interrupt Encoder
  //
  // - sets correct id to request to ID
  // - encodes priority order

  always_comb
  begin
    if      (irq_local_qual[31]) irq_id_ctrl_o = 5'd31;                         // Custom irq_i[31]
    else if (irq_local_qual[30]) irq_id_ctrl_o = 5'd30;                         // Custom irq_i[30]
    else if (irq_local_qual[29]) irq_id_ctrl_o = 5'd29;                         // Custom irq_i[29]
    else if (irq_local_qual[28]) irq_id_ctrl_o = 5'd28;                         // Custom irq_i[28]
    else if (irq_local_qual[27]) irq_id_ctrl_o = 5'd27;                         // Custom irq_i[27]
    else if (irq_local_qual[26]) irq_id_ctrl_o = 5'd26;                         // Custom irq_i[26]
    else if (irq_local_qual[25]) irq_id_ctrl_o = 5'd25;                         // Custom irq_i[25]
    else if (irq_local_qual[24]) irq_id_ctrl_o = 5'd24;                         // Custom irq_i[24]
    else if (irq_local_qual[23]) irq_id_ctrl_o = 5'd23;                         // Custom irq_i[23]
    else if (irq_local_qual[22]) irq_id_ctrl_o = 5'd22;                         // Custom irq_i[22]
    else if (irq_local_qual[21]) irq_id_ctrl_o = 5'd21;                         // Custom irq_i[21]
    else if (irq_local_qual[20]) irq_id_ctrl_o = 5'd20;                         // Custom irq_i[20]
    else if (irq_local_qual[19]) irq_id_ctrl_o = 5'd19;                         // Custom irq_i[19]
    else if (irq_local_qual[18]) irq_id_ctrl_o = 5'd18;                         // Custom irq_i[18]
    else if (irq_local_qual[17]) irq_id_ctrl_o = 5'd17;                         // Custom irq_i[17]
    else if (irq_local_qual[16]) irq_id_ctrl_o = 5'd16;                         // Custom irq_i[16]

    // Reserved: irq_local_qual[15], irq_id_ctrl_o = 5'd15
    // Reserved: irq_local_qual[14], irq_id_ctrl_o = 5'd14
    // Reserved: irq_local_qual[13], irq_id_ctrl_o = 5'd13
    // Reserved: irq_local_qual[12], irq_id_ctrl_o = 5'd12

    else if (irq_local_qual[CSR_MEIX_BIT]) irq_id_ctrl_o = CSR_MEIX_BIT;        // MEI, irq_i[11]
    else if (irq_local_qual[CSR_MSIX_BIT]) irq_id_ctrl_o = CSR_MSIX_BIT;        // MSI, irq_i[3]
    else                                   irq_id_ctrl_o = CSR_MTIX_BIT;        // MTI, irq_i[7]

    // Reserved: irq_local_qual[10], irq_id_ctrl_o = 5'd10
    // Reserved: irq_local_qual[ 2], irq_id_ctrl_o = 5'd2
    // Reserved: irq_local_qual[ 6], irq_id_ctrl_o = 5'd6

    // Reserved: irq_local_qual[ 9], irq_id_ctrl_o = 5'd9, SEI
    // Reserved: irq_local_qual[ 1], irq_id_ctrl_o = 5'd1, SSI
    // Reserved: irq_local_qual[ 5], irq_id_ctrl_o = 5'd5, STI

    // Reserved: irq_local_qual[ 8], irq_id_ctrl_o = 5'd8, UEI
    // Reserved: irq_local_qual[ 0], irq_id_ctrl_o = 5'd0, USI
    // Reserved: irq_local_qual[ 4], irq_id_ctrl_o = 5'd4, UTI

  end

endmodule








// Description:    Register file with 31x registers. Register 0 is fixed to 0. //
//                 This register file is based on flip-flops. The register     //
//                 width is configurable to allow adding a parity bit or ECC.  //
//                                                                             //
/////////////////////////////////////////////////////////////////////////////////

module cv32e40x_register_file import cv32e40x_pkg::*;
  #(
      parameter int unsigned REGFILE_NUM_READ_PORTS = 2,
      parameter rv32_e       RV32                   = RV32I
  )
  (
    // Clock and Reset
    input logic                           clk,
    input logic                           rst_n,

    // Read ports
    input  rf_addr_t                      raddr_i [REGFILE_NUM_READ_PORTS],
    output logic [REGFILE_WORD_WIDTH-1:0] rdata_o [REGFILE_NUM_READ_PORTS],

    // Write ports
    input rf_addr_t                       waddr_i [REGFILE_NUM_WRITE_PORTS],
    input logic [REGFILE_WORD_WIDTH-1:0]  wdata_i [REGFILE_NUM_WRITE_PORTS],
    input logic                           we_i    [REGFILE_NUM_WRITE_PORTS]
   );

  // Number of regfile integer registers
  localparam REGFILE_NUM_WORDS = (RV32 == RV32I) ? 32 : 16;
  localparam REGFILE_IMPL_ADDR_WIDTH = $clog2(REGFILE_NUM_WORDS);

  // integer register file
  logic [REGFILE_WORD_WIDTH-1:0]          mem [REGFILE_NUM_WORDS];

  // write enable signals for all registers
  logic [REGFILE_NUM_WORDS-1:0]           we_dec[REGFILE_NUM_WRITE_PORTS];

  //-----------------------------------------------------------------------------
  //-- READ : Read address decoder RAD
  //-----------------------------------------------------------------------------
  genvar ridx;
  generate
    for (ridx=0; ridx<REGFILE_NUM_READ_PORTS; ridx++) begin : gen_regfile_rdata
      assign rdata_o[ridx] = mem[raddr_i[ridx][REGFILE_IMPL_ADDR_WIDTH-1:0]];
    end
  endgenerate

  //-----------------------------------------------------------------------------
  //-- WRITE : Write Address Decoder (WAD), combinatorial process
  //-----------------------------------------------------------------------------


  genvar reg_index, port_index;
  generate
    for (reg_index=0; reg_index<REGFILE_NUM_WORDS; reg_index++) begin : gen_we_decoder
      for (port_index=0; port_index<REGFILE_NUM_WRITE_PORTS; port_index++) begin : gen_we_ports
        assign we_dec[port_index][reg_index] = (waddr_i[port_index] == reg_index) ? we_i[port_index] : 1'b0;
      end // gen_we_ports
    end // gen_we_decoder
  endgenerate

  genvar i;
  generate

    //-----------------------------------------------------------------------------
    //-- WRITE : Write operation
    //-----------------------------------------------------------------------------
    // R0 is nil
    always_ff @(posedge clk or negedge rst_n) begin
      if(~rst_n) begin
        // R0 is nil
        mem[0] <= '0;
      end else begin
        // R0 is nil
        mem[0] <= '0;
      end
    end

    // loop from 1 to NUM_WORDS-1 as R0 is nil
    for (i = 1; i < REGFILE_NUM_WORDS; i++)
    begin : gen_rf

      always_ff @(posedge clk, negedge rst_n)
      begin : register_write_behavioral
        if (rst_n==1'b0) begin
          mem[i] <= '0;
        end else begin
          // Highest indexed write port will have priority
          for(int j=0; j<REGFILE_NUM_WRITE_PORTS; j++) begin : rf_write_ports
            if(we_dec[j][i] == 1'b1) begin
              mem[i] <= wdata_i[j];
            end
          end
        end
      end

    end

  endgenerate

endmodule







// Description:    Wrapper for the register file                              //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_register_file_wrapper import cv32e40x_pkg::*;
#(
      parameter int unsigned REGFILE_NUM_READ_PORTS = 2,
      parameter rv32_e       RV32                   = RV32I
)
(
        // Clock and Reset
        input  logic         clk,
        input  logic         rst_n,
    
        // Read ports
        input  rf_addr_t     raddr_i [REGFILE_NUM_READ_PORTS],
        output rf_data_t     rdata_o [REGFILE_NUM_READ_PORTS],
    
        // Write ports
        input rf_addr_t     waddr_i [REGFILE_NUM_WRITE_PORTS],
        input rf_data_t     wdata_i [REGFILE_NUM_WRITE_PORTS],
        input logic         we_i [REGFILE_NUM_WRITE_PORTS]
);
    
    cv32e40x_register_file
    #(
      .REGFILE_NUM_READ_PORTS       ( REGFILE_NUM_READ_PORTS ),
      .RV32                         ( RV32                   )
    )
    register_file_i
    (
      .clk                ( clk                ),
      .rst_n              ( rst_n              ),
    
      // Read ports
      .raddr_i            ( raddr_i            ),
      .rdata_o            ( rdata_o            ),
    
      // Write ports
      .waddr_i            ( waddr_i            ),
      .wdata_i            ( wdata_i            ),
      .we_i               ( we_i               )
                 
    ); 
    
    endmodule





// Description:    Top level module of the RISC-V core.                       //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_core import cv32e40x_pkg::*;
#(
  parameter                             LIB                                     = 0,
  parameter rv32_e                      RV32                                    = RV32I,
  parameter a_ext_e                     A_EXT                                   = A_NONE,
  parameter b_ext_e                     B_EXT                                   = B_NONE,
  parameter m_ext_e                     M_EXT                                   = M,
  parameter bit                         DEBUG                                   = 1,
  parameter logic [31:0]                DM_REGION_START                         = 32'hF0000000,
  parameter logic [31:0]                DM_REGION_END                           = 32'hF0003FFF,
  parameter int                         DBG_NUM_TRIGGERS                        = 1,
  parameter int                         PMA_NUM_REGIONS                         = 0,
  parameter pma_cfg_t                   PMA_CFG[PMA_NUM_REGIONS-1:0]            = '{default:PMA_R_DEFAULT},
  parameter bit                         CLIC                                    = 0,
  parameter int unsigned                CLIC_ID_WIDTH                           = 5,
  parameter bit                         X_EXT                                   = 0,
  parameter int unsigned                X_NUM_RS                                = 2,
  parameter int unsigned                X_ID_WIDTH                              = 4,
  parameter int unsigned                X_MEM_WIDTH                             = 32,
  parameter int unsigned                X_RFR_WIDTH                             = 32,
  parameter int unsigned                X_RFW_WIDTH                             = 32,
  parameter logic [31:0]                X_MISA                                  = 32'h00000000,
  parameter logic [1:0]                 X_ECS_XS                                = 2'b00,
  parameter int unsigned                NUM_MHPMCOUNTERS                        = 1
)
(
  // Clock and reset
  input  logic                          clk_i,
  input  logic                          rst_ni,
  input  logic                          scan_cg_en_i,   // Enable all clock gates for testing

  // Static configuration
  input  logic [31:0]                   boot_addr_i,
  input  logic [31:0]                   dm_exception_addr_i,
  input  logic [31:0]                   dm_halt_addr_i,
  input  logic [31:0]                   mhartid_i,
  input  logic  [3:0]                   mimpid_patch_i,
  input  logic [31:0]                   mtvec_addr_i,

  // Instruction memory interface
  output logic                          instr_req_o,
  input  logic                          instr_gnt_i,
  input  logic                          instr_rvalid_i,
  output logic [31:0]                   instr_addr_o,
  output logic [1:0]                    instr_memtype_o,
  output logic [2:0]                    instr_prot_o,
  output logic                          instr_dbg_o,
  input  logic [31:0]                   instr_rdata_i,
  input  logic                          instr_err_i,

  // Data memory interface
  output logic                          data_req_o,
  input  logic                          data_gnt_i,
  input  logic                          data_rvalid_i,
  output logic [31:0]                   data_addr_o,
  output logic [3:0]                    data_be_o,
  output logic                          data_we_o,
  output logic [31:0]                   data_wdata_o,
  output logic [1:0]                    data_memtype_o,
  output logic [2:0]                    data_prot_o,
  output logic                          data_dbg_o,
  output logic [5:0]                    data_atop_o,
  input  logic [31:0]                   data_rdata_i,
  input  logic                          data_err_i,
  input  logic                          data_exokay_i,

  // Cycle count
  output logic [63:0]                   mcycle_o,

  // Time input
  input  logic [63:0]                   time_i,

  // eXtension interface
  cv32e40x_if_xif.cpu_compressed        xif_compressed_if,
  cv32e40x_if_xif.cpu_issue             xif_issue_if,
  cv32e40x_if_xif.cpu_commit            xif_commit_if,
  cv32e40x_if_xif.cpu_mem               xif_mem_if,
  cv32e40x_if_xif.cpu_mem_result        xif_mem_result_if,
  cv32e40x_if_xif.cpu_result            xif_result_if,

  // Basic interrupt architecture
  input  logic [31:0]                   irq_i,

  // Event wakeup signals
  input  logic                          wu_wfe_i,   // Wait-for-event wakeup

  // CLIC interrupt architecture
  input  logic                          clic_irq_i,
  input  logic [CLIC_ID_WIDTH-1:0]      clic_irq_id_i,
  input  logic [ 7:0]                   clic_irq_level_i,
  input  logic [ 1:0]                   clic_irq_priv_i,
  input  logic                          clic_irq_shv_i,

  // Fence.i flush handshake
  output logic                          fencei_flush_req_o,
  input  logic                          fencei_flush_ack_i,

  // Debug interface
  input  logic                          debug_req_i,
  output logic                          debug_havereset_o,
  output logic                          debug_running_o,
  output logic                          debug_halted_o,
  output logic                          debug_pc_valid_o,
  output logic [31:0]                   debug_pc_o,

  // CPU control signals
  input  logic                          fetch_enable_i,
  output logic                          core_sleep_o
);

  // Number of register file read ports
  // Core will only use two, but X_EXT may mandate 2 or 3
  localparam int unsigned REGFILE_NUM_READ_PORTS = X_EXT ? X_NUM_RS : 2;

  // Zc is always present
  localparam bit ZC_EXT = 1;

  // Determine alignedness of mtvt
  // mtvt[31:N] holds mtvt table entry
  // mtvt[N-1:0] is tied to zero.
  localparam int unsigned MTVT_LSB = ((CLIC_ID_WIDTH + 2) < 6) ? 6 : (CLIC_ID_WIDTH + 2);
  localparam int unsigned MTVT_ADDR_WIDTH = 32 - MTVT_LSB;

  logic         clk;                    // Gated clock
  logic         fetch_enable;

  logic [31:0]  pc_if;                  // Program counter in IF stage
  logic         ptr_in_if;              // IF stage contains a pointer
  privlvl_t     priv_lvl_if;            // IF stage privilege level

  // Jump and branch target and decision (EX->IF)
  logic [31:0] jump_target_id;
  logic [31:0] branch_target_ex;
  logic        branch_decision_ex;

  // Busy signals
  logic        if_busy;
  logic        lsu_busy;       // LSU is busy, outstanding OBI or new transaction being initiated
  logic        lsu_bus_busy;   // LSU has outstanding transactions on the OBI bus
  logic        lsu_interruptible;

  // ID/EX pipeline
  id_ex_pipe_t id_ex_pipe;

  // EX/WB pipeline
  ex_wb_pipe_t ex_wb_pipe;

  // IF/ID pipeline
  if_id_pipe_t if_id_pipe;

  // Controller
  ctrl_byp_t   ctrl_byp;
  ctrl_fsm_t   ctrl_fsm;

  // Gated debug_req_i signal depending on DEBUG parameter
  logic        debug_req_gated;

  // Register File Write Back
  logic        rf_we_wb;
  rf_addr_t    rf_waddr_wb;
  logic [31:0] rf_wdata_wb;

  // Forwarding RF from EX
  logic [31:0] rf_wdata_ex;

  // Detect last_op
  logic        last_op_if;
  logic        last_op_id;
  logic        last_op_ex;
  logic        last_op_wb;

  // Abort_op bits
  logic        abort_op_if;
  logic        abort_op_id;
  logic        abort_op_wb;

  // First op bits
  logic        first_op_id;

  // Register file signals from ID/decoder to controller
  logic [REGFILE_NUM_READ_PORTS-1:0] rf_re_id;
  rf_addr_t    rf_raddr_id[REGFILE_NUM_READ_PORTS];

  // Register file read data
  rf_data_t    rf_rdata_id[REGFILE_NUM_READ_PORTS];

  // Register file write interface
  rf_addr_t    rf_waddr[REGFILE_NUM_WRITE_PORTS];
  rf_data_t    rf_wdata[REGFILE_NUM_WRITE_PORTS];
  logic        rf_we   [REGFILE_NUM_WRITE_PORTS];

  // CSR control
  logic [24:0] mtvec_addr;
  logic [1:0]  mtvec_mode;

  // JVT
  logic [JVT_ADDR_WIDTH-1:0]  jvt_addr;
  logic [5:0]                 jvt_mode;

  logic [MTVT_ADDR_WIDTH-1:0] mtvt_addr;

  logic [7:0]  mintthresh_th;
  mintstatus_t mintstatus;

  mcause_t     mcause;

  logic [31:0] csr_rdata;
  logic csr_counter_read;
  logic csr_wr_in_wb_flush;
  logic csr_irq_enable_write;

  privlvl_t     priv_lvl_lsu;
  privlvlctrl_t priv_lvl_if_ctrl;

  privlvl_t     priv_lvl;

  logic         csr_mnxti_read;
  csr_hz_t      csr_hz;

  // CLIC signals for returning pointer addresses
  // when mnxti is accessed
  logic        csr_clic_pa_valid;   // A CSR access to mnxti has a valid ponter address
  logic [31:0] csr_clic_pa;         // Pointer address returned by accessing mnxti

  // LSU
  logic        lsu_split_ex;
  logic        lsu_first_op_ex;
  logic        lsu_last_op_ex;
  lsu_atomic_e lsu_atomic_ex;
  mpu_status_e lsu_mpu_status_wb;
  logic [31:0] lsu_wpt_match_wb;
  align_status_e lsu_align_status_wb;
  logic [31:0] lsu_rdata_wb;
  lsu_err_wb_t lsu_err_wb;
  lsu_atomic_e lsu_atomic_wb;

  logic        lsu_valid_0;             // Handshake with EX
  logic        lsu_ready_ex;
  logic        lsu_valid_ex;
  logic        lsu_ready_0;

  logic        lsu_valid_1;             // Handshake with WB
  logic        lsu_ready_wb;
  logic        lsu_valid_wb;
  logic        lsu_ready_1;

  // LSU signals to trigger module
  logic [31:0] lsu_addr_ex;
  logic        lsu_we_ex;
  logic [3:0]  lsu_be_ex;

  logic        data_stall_wb;

  logic [31:0] wpt_match_wb;       // Sticky wpt_match from WB stage
  mpu_status_e mpu_status_wb;      // Sticky mpu_status from WB stage
  align_status_e align_status_wb;  // Sticky align_status from WB stage

  // Stage ready signals
  logic        id_ready;
  logic        ex_ready;
  logic        wb_ready;

  // Stage valid signals
  logic        if_valid;
  logic        id_valid;
  logic        ex_valid;
  logic        wb_valid;

  // Interrupts
  mstatus_t    mstatus;
  logic [31:0] mepc, dpc;
  logic [31:0] mie;
  logic [31:0] mip;

  // Signal from IF to init mtvec at boot time
  logic        csr_mtvec_init_if;

  // debug mode and dcsr configuration
  // From cs_registers
  dcsr_t       dcsr;

  // trigger match detected in trigger module (using IF timing)
  // One bit per trigger (max 32 triggers)
  logic [31:0] trigger_match_if;
  // trigger match detected in trigger module (using EX/LSU timing)
  // One bit per trigger (max 32 triggers)
  logic [31:0] trigger_match_ex;
  // trigger match detected in trigger module (using WB timing, etrigger)
  logic        etrigger_wb;

  // Controller <-> decoder
  logic        alu_jmp_id;
  logic        alu_jmpr_id;
  logic        alu_en_id;
  logic        sys_en_id;
  logic        sys_mret_insn_id;
  logic        csr_en_raw_id;
  logic        csr_illegal;

  // CSR illegal in EX due to offloading and pipeline accept
  logic        xif_csr_error_ex;

  // irq signals
  logic        irq_req_ctrl;
  logic [9:0]  irq_id_ctrl;
  logic        irq_wu_ctrl;

  // CLIC specific irq signals
  logic                       irq_clic_shv;
  logic [7:0]                 irq_clic_level;
  logic [1:0]                 irq_clic_priv;
  logic                       mnxti_irq_pending;
  logic [CLIC_ID_WIDTH-1:0]   mnxti_irq_id;
  logic [7:0]                 mnxti_irq_level;

  // Used (only) by verification environment
  logic        irq_ack;
  logic [9:0]  irq_id;
  logic [7:0]  irq_level;       // Only applicable if CLIC = 1
  logic [1:0]  irq_priv;        // Only applicable if CLIC = 1
  logic        irq_shv;         // Only applicable if CLIC = 1
  logic        dbg_ack;

  // eXtension interface signals
  logic        xif_offloading_id;

  logic        unused_signals;

  // Internal OBI interfaces
  cv32e40x_if_c_obi #(.REQ_TYPE(obi_inst_req_t), .RESP_TYPE(obi_inst_resp_t))  m_c_obi_instr_if();
  cv32e40x_if_c_obi #(.REQ_TYPE(obi_data_req_t), .RESP_TYPE(obi_data_resp_t))  m_c_obi_data_if();

  // Connect toplevel OBI signals to internal interfaces
  assign instr_req_o                         = m_c_obi_instr_if.s_req.req;
  // Address is made word aligned late so that full address can be used in RVFI
  assign instr_addr_o                        = {m_c_obi_instr_if.req_payload.addr[31:2], 2'b0};
  assign instr_memtype_o                     = m_c_obi_instr_if.req_payload.memtype;
  assign instr_prot_o                        = m_c_obi_instr_if.req_payload.prot;
  assign instr_dbg_o                         = m_c_obi_instr_if.req_payload.dbg;
  assign m_c_obi_instr_if.s_gnt.gnt          = instr_gnt_i;
  assign m_c_obi_instr_if.s_rvalid.rvalid    = instr_rvalid_i;
  assign m_c_obi_instr_if.resp_payload.rdata = instr_rdata_i;
  assign m_c_obi_instr_if.resp_payload.err   = instr_err_i;

  assign data_req_o                          = m_c_obi_data_if.s_req.req;
  assign data_we_o                           = m_c_obi_data_if.req_payload.we;
  assign data_be_o                           = m_c_obi_data_if.req_payload.be;
  assign data_addr_o                         = m_c_obi_data_if.req_payload.addr;
  assign data_memtype_o                      = m_c_obi_data_if.req_payload.memtype;
  assign data_prot_o                         = m_c_obi_data_if.req_payload.prot;
  assign data_dbg_o                          = m_c_obi_data_if.req_payload.dbg;
  assign data_wdata_o                        = m_c_obi_data_if.req_payload.wdata;
  assign data_atop_o                         = m_c_obi_data_if.req_payload.atop;
  assign m_c_obi_data_if.s_gnt.gnt           = data_gnt_i;
  assign m_c_obi_data_if.s_rvalid.rvalid     = data_rvalid_i;
  assign m_c_obi_data_if.resp_payload.rdata  = data_rdata_i;
  assign m_c_obi_data_if.resp_payload.err[0] = data_err_i;
  assign m_c_obi_data_if.resp_payload.err[1] = 1'b0; // Will be assigned in the response filter
  assign m_c_obi_data_if.resp_payload.exokay = data_exokay_i;

  assign debug_havereset_o = ctrl_fsm.debug_havereset;
  assign debug_halted_o    = ctrl_fsm.debug_halted;
  assign debug_running_o   = ctrl_fsm.debug_running;
  assign debug_pc_valid_o  = ctrl_fsm.mhpmevent.minstret;
  assign debug_pc_o        = ex_wb_pipe.pc;

  // Used (only) by verification environment
  assign irq_ack   = ctrl_fsm.irq_ack;
  assign irq_id    = ctrl_fsm.irq_id;
  assign irq_level = ctrl_fsm.irq_level;
  assign irq_priv  = ctrl_fsm.irq_priv;
  assign irq_shv   = ctrl_fsm.irq_shv;
  assign dbg_ack   = ctrl_fsm.dbg_ack;

  // Gate off the internal debug_request signal if debug support is not configured.
  assign debug_req_gated = DEBUG ? debug_req_i : 1'b0;

  //////////////////////////////////////////////////////////////////////////////////////////////
  //   ____ _            _      __  __                                                   _    //
  //  / ___| | ___   ___| | __ |  \/  | __ _ _ __   __ _  __ _  ___ _ __ ___   ___ _ __ | |_  //
  // | |   | |/ _ \ / __| |/ / | |\/| |/ _` | '_ \ / _` |/ _` |/ _ \ '_ ` _ \ / _ \ '_ \| __| //
  // | |___| | (_) | (__|   <  | |  | | (_| | | | | (_| | (_| |  __/ | | | | |  __/ | | | |_  //
  //  \____|_|\___/ \___|_|\_\ |_|  |_|\__,_|_| |_|\__,_|\__, |\___|_| |_| |_|\___|_| |_|\__| //
  //                                                     |___/                                //
  //////////////////////////////////////////////////////////////////////////////////////////////

  cv32e40x_sleep_unit
  #(
    .LIB                        ( LIB                  )
  )
  sleep_unit_i
  (
    // Clock, reset interface
    .clk_ungated_i              ( clk_i                ),       // Ungated clock
    .rst_n                      ( rst_ni               ),
    .clk_gated_o                ( clk                  ),       // Gated clock
    .scan_cg_en_i               ( scan_cg_en_i         ),

    // Core sleep
    .core_sleep_o               ( core_sleep_o         ),

    // Fetch enable
    .fetch_enable_i             ( fetch_enable_i       ),
    .fetch_enable_o             ( fetch_enable         ),

    // Core status
    .if_busy_i                  ( if_busy              ),
    .lsu_busy_i                 ( lsu_busy             ),

    // Inputs from controller (including busy)
    .ctrl_fsm_i                 ( ctrl_fsm             )
  );

  //////////////////////////////////////////////////
  //   ___ _____   ____ _____  _    ____ _____    //
  //  |_ _|  ___| / ___|_   _|/ \  / ___| ____|   //
  //   | || |_    \___ \ | | / _ \| |  _|  _|     //
  //   | ||  _|    ___) || |/ ___ \ |_| | |___    //
  //  |___|_|     |____/ |_/_/   \_\____|_____|   //
  //                                              //
  //////////////////////////////////////////////////

  cv32e40x_if_stage
  #(
    .RV32                ( RV32                     ),
    .A_EXT               ( A_EXT                    ),
    .B_EXT               ( B_EXT                    ),
    .X_EXT               ( X_EXT                    ),
    .X_ID_WIDTH          ( X_ID_WIDTH               ),
    .PMA_NUM_REGIONS     ( PMA_NUM_REGIONS          ),
    .PMA_CFG             ( PMA_CFG                  ),
    .MTVT_ADDR_WIDTH     ( MTVT_ADDR_WIDTH          ),
    .CLIC                ( CLIC                     ),
    .CLIC_ID_WIDTH       ( CLIC_ID_WIDTH            ),
    .ZC_EXT              ( ZC_EXT                   ),
    .M_EXT               ( M_EXT                    ),
    .DEBUG               ( DEBUG                    ),
    .DM_REGION_START     ( DM_REGION_START          ),
    .DM_REGION_END       ( DM_REGION_END            )
  )
  if_stage_i
  (
    .clk                 ( clk                      ),
    .rst_n               ( rst_ni                   ),

    .boot_addr_i         ( boot_addr_i              ), // Boot address
    .branch_target_ex_i  ( branch_target_ex         ), // Branch target address
    .dm_exception_addr_i ( dm_exception_addr_i      ), // Debug mode exception address
    .dm_halt_addr_i      ( dm_halt_addr_i           ), // Debug mode halt address
    .dpc_i               ( dpc                      ), // Debug PC (restore upon return from debug)
    .jump_target_id_i    ( jump_target_id           ), // Jump target address
    .mepc_i              ( mepc                     ), // Exception PC (restore upon return from exception/interrupt)
    .mtvec_addr_i        ( mtvec_addr               ), // Exception/interrupt address (MSBs only)
    .mtvt_addr_i         ( mtvt_addr                ), // CLIC vector base
    .jvt_mode_i          ( jvt_mode                 ),

    .m_c_obi_instr_if    ( m_c_obi_instr_if.master  ), // Instruction bus interface

    .if_id_pipe_o        ( if_id_pipe               ),

    .ctrl_fsm_i          ( ctrl_fsm                 ),
    .trigger_match_i     ( trigger_match_if         ),

    .pc_if_o             ( pc_if                    ),
    .csr_mtvec_init_o    ( csr_mtvec_init_if        ),
    .if_busy_o           ( if_busy                  ),
    .ptr_in_if_o         ( ptr_in_if                ),
    .priv_lvl_if_o       ( priv_lvl_if              ),

    .last_op_o           ( last_op_if               ),
    .abort_op_o          ( abort_op_if              ),

    // Pipeline handshakes
    .if_valid_o          ( if_valid                 ),
    .id_ready_i          ( id_ready                 ),

    // Privilege level
    .priv_lvl_ctrl_i     ( priv_lvl_if_ctrl         ),

    // eXtension interface
    .xif_compressed_if   ( xif_compressed_if        ),
    .xif_offloading_id_i ( xif_offloading_id        )
  );

  /////////////////////////////////////////////////
  //   ___ ____    ____ _____  _    ____ _____   //
  //  |_ _|  _ \  / ___|_   _|/ \  / ___| ____|  //
  //   | || | | | \___ \ | | / _ \| |  _|  _|    //
  //   | || |_| |  ___) || |/ ___ \ |_| | |___   //
  //  |___|____/  |____/ |_/_/   \_\____|_____|  //
  //                                             //
  /////////////////////////////////////////////////

  cv32e40x_id_stage
  #(
    .RV32                         ( RV32                      ),
    .A_EXT                        ( A_EXT                     ),
    .B_EXT                        ( B_EXT                     ),
    .M_EXT                        ( M_EXT                     ),
    .X_EXT                        ( X_EXT                     ),
    .REGFILE_NUM_READ_PORTS       ( REGFILE_NUM_READ_PORTS    ),
    .CLIC                         ( CLIC                      )
  )
  id_stage_i
  (
    .clk                          ( clk                       ),     // Gated clock
    .rst_n                        ( rst_ni                    ),

    // Jumps and branches
    .jmp_target_o                 ( jump_target_id            ),

    // IF/ID pipeline
    .if_id_pipe_i                 ( if_id_pipe                ),

    // ID/EX pipeline
    .id_ex_pipe_o                 ( id_ex_pipe                ),

    // EX/WB pipeline
    .ex_wb_pipe_i                 ( ex_wb_pipe                ),

    // Controller
    .ctrl_byp_i                   ( ctrl_byp                  ),
    .ctrl_fsm_i                   ( ctrl_fsm                  ),

    .mcause_i                     ( mcause                    ),
    .jvt_addr_i                   ( jvt_addr                  ),

    // Register file write back and forwards
    .rf_wdata_ex_i                ( rf_wdata_ex               ),
    .rf_wdata_wb_i                ( rf_wdata_wb               ),

    .alu_jmp_o                    ( alu_jmp_id                ),
    .alu_jmpr_o                   ( alu_jmpr_id               ),
    .sys_mret_insn_o              ( sys_mret_insn_id          ),
    .csr_en_raw_o                 ( csr_en_raw_id             ),
    .alu_en_o                     ( alu_en_id                 ),
    .sys_en_o                     ( sys_en_id                 ),

    .first_op_o                   ( first_op_id               ),
    .last_op_o                    ( last_op_id                ),
    .abort_op_o                   ( abort_op_id               ),

    .rf_re_o                      ( rf_re_id                  ),
    .rf_raddr_o                   ( rf_raddr_id               ),
    .rf_rdata_i                   ( rf_rdata_id               ),

    // Pipeline handshakes
    .id_ready_o                   ( id_ready                  ),
    .id_valid_o                   ( id_valid                  ),
    .ex_ready_i                   ( ex_ready                  ),

    // eXtension interface
    .xif_issue_if                 ( xif_issue_if              ),
    .xif_offloading_o             ( xif_offloading_id         )
  );

  /////////////////////////////////////////////////////
  //   _______  __  ____ _____  _    ____ _____      //
  //  | ____\ \/ / / ___|_   _|/ \  / ___| ____|     //
  //  |  _|  \  /  \___ \ | | / _ \| |  _|  _|       //
  //  | |___ /  \   ___) || |/ ___ \ |_| | |___      //
  //  |_____/_/\_\ |____/ |_/_/   \_\____|_____|     //
  //                                                 //
  /////////////////////////////////////////////////////

  cv32e40x_ex_stage
  #(
    .X_EXT                      ( X_EXT                        ),
    .B_EXT                      ( B_EXT                        ),
    .M_EXT                      ( M_EXT                        )
  )
  ex_stage_i
  (
    .clk                        ( clk                          ),
    .rst_n                      ( rst_ni                       ),

    // ID/EX pipeline
    .id_ex_pipe_i               ( id_ex_pipe                   ),

    // EX/WB pipeline
    .ex_wb_pipe_o               ( ex_wb_pipe                   ),

    // From controller FSM
    .ctrl_fsm_i                 ( ctrl_fsm                     ),

    // CSR interface
    .csr_rdata_i                ( csr_rdata                    ),
    .csr_illegal_i              ( csr_illegal                  ),
    .csr_mnxti_read_i           ( csr_mnxti_read               ),
    .csr_hz_i                   ( csr_hz                       ),

    // Branch decision
    .branch_decision_o          ( branch_decision_ex           ),
    .branch_target_o            ( branch_target_ex             ),

    .xif_csr_error_o            ( xif_csr_error_ex             ),

    // Register file forwarding
    .rf_wdata_o                 ( rf_wdata_ex                  ),

    // LSU interface
    .lsu_valid_i                ( lsu_valid_0                  ),
    .lsu_ready_o                ( lsu_ready_ex                 ),
    .lsu_valid_o                ( lsu_valid_ex                 ),
    .lsu_ready_i                ( lsu_ready_0                  ),
    .lsu_split_i                ( lsu_split_ex                 ),
    .lsu_last_op_i              ( lsu_last_op_ex               ),
    .lsu_first_op_i             ( lsu_first_op_ex              ),

    // Pipeline handshakes
    .ex_ready_o                 ( ex_ready                     ),
    .ex_valid_o                 ( ex_valid                     ),
    .wb_ready_i                 ( wb_ready                     ),
    .last_op_o                  ( last_op_ex                   )
  );

  ////////////////////////////////////////////////////////////////////////////////////////
  //    _     ___    _    ____    ____ _____ ___  ____  _____   _   _ _   _ ___ _____   //
  //   | |   / _ \  / \  |  _ \  / ___|_   _/ _ \|  _ \| ____| | | | | \ | |_ _|_   _|  //
  //   | |  | | | |/ _ \ | | | | \___ \ | || | | | |_) |  _|   | | | |  \| || |  | |    //
  //   | |__| |_| / ___ \| |_| |  ___) || || |_| |  _ <| |___  | |_| | |\  || |  | |    //
  //   |_____\___/_/   \_\____/  |____/ |_| \___/|_| \_\_____|  \___/|_| \_|___| |_|    //
  //                                                                                    //
  ////////////////////////////////////////////////////////////////////////////////////////

  cv32e40x_load_store_unit
  #(
    .A_EXT                 (A_EXT               ),
    .X_EXT                 (X_EXT               ),
    .X_ID_WIDTH            (X_ID_WIDTH          ),
    .PMA_NUM_REGIONS       (PMA_NUM_REGIONS     ),
    .PMA_CFG               (PMA_CFG             ),
    .DBG_NUM_TRIGGERS      (DBG_NUM_TRIGGERS    ),
    .DEBUG                 (DEBUG               ),
    .DM_REGION_START       (DM_REGION_START     ),
    .DM_REGION_END         (DM_REGION_END       )
  )
  load_store_unit_i
  (
    .clk                   ( clk                ),
    .rst_n                 ( rst_ni             ),

    // ID/EX pipeline
    .id_ex_pipe_i          ( id_ex_pipe         ),

    // Controller
    .ctrl_fsm_i            ( ctrl_fsm           ),

    // Data OBI interface
    .m_c_obi_data_if       ( m_c_obi_data_if.master ),

    // Control signals
    .busy_o                ( lsu_busy           ),
    .bus_busy_o            ( lsu_bus_busy       ),
    .interruptible_o       ( lsu_interruptible  ),

    // Trigger match
    .trigger_match_0_i     ( trigger_match_ex   ),

    // Stage 0 outputs (EX)
    .lsu_split_0_o         ( lsu_split_ex       ),
    .lsu_first_op_0_o      ( lsu_first_op_ex    ),
    .lsu_last_op_0_o       ( lsu_last_op_ex     ),
    .lsu_atomic_0_o        ( lsu_atomic_ex      ),

    // Outputs to trigger module
    .lsu_addr_o            ( lsu_addr_ex        ),
    .lsu_we_o              ( lsu_we_ex          ),
    .lsu_be_o              ( lsu_be_ex          ),

    // Stage 1 outputs (WB)
    // lsu_err_1_o has WB timing and is used by the controller. Does not go through the wb_stage, and does not have
    // any sticky bits associated with it. The sticky bits for LSU related signals within the WB stage are only needed
    // for MPU errors and watchpoint triggers. All LSU instructions that gets through the WPT and MPU will retire immediately
    // when data_rvalid arrives. data_err_i will always come from the bus.
    .lsu_err_1_o           ( lsu_err_wb         ),
    .lsu_rdata_1_o         ( lsu_rdata_wb       ),
    .lsu_mpu_status_1_o    ( lsu_mpu_status_wb  ),
    .lsu_wpt_match_1_o     ( lsu_wpt_match_wb   ),
    .lsu_align_status_1_o  ( lsu_align_status_wb),
    .lsu_atomic_1_o        ( lsu_atomic_wb      ),

    // Privilege level
    .priv_lvl_lsu_i        ( priv_lvl_lsu       ),

    // Valid/ready
    .valid_0_i             ( lsu_valid_ex       ), // First LSU stage (EX)
    .ready_0_o             ( lsu_ready_0        ),
    .valid_0_o             ( lsu_valid_0        ),
    .ready_0_i             ( lsu_ready_ex       ),

    .valid_1_i             ( lsu_valid_wb       ), // Second LSU stage (WB)
    .ready_1_o             ( lsu_ready_1        ),
    .valid_1_o             ( lsu_valid_1        ),
    .ready_1_i             ( lsu_ready_wb       ),

    // eXtension interface
    .xif_mem_if            ( xif_mem_if         ),
    .xif_mem_result_if     ( xif_mem_result_if  )
  );

  ////////////////////////////////////////////////////////////////////////////////////////
  // Write back stage                                                                   //
  ////////////////////////////////////////////////////////////////////////////////////////

  cv32e40x_wb_stage
  #(
      .DEBUG                    ( DEBUG                        )
  )
  wb_stage_i
  (
    .clk                        ( clk                          ), // Not used in RTL; only used by assertions
    .rst_n                      ( rst_ni                       ), // Not used in RTL; only used by assertions

    // EX/WB pipeline
    .ex_wb_pipe_i               ( ex_wb_pipe                   ),

    // Controller
    .ctrl_fsm_i                 ( ctrl_fsm                     ),

    // LSU
    .lsu_rdata_i                ( lsu_rdata_wb                 ),
    .lsu_mpu_status_i           ( lsu_mpu_status_wb            ),
    .lsu_wpt_match_i            ( lsu_wpt_match_wb             ),
    .lsu_align_status_i         ( lsu_align_status_wb          ),

    // Write back to register file
    .rf_we_wb_o                 ( rf_we_wb                     ),
    .rf_waddr_wb_o              ( rf_waddr_wb                  ),
    .rf_wdata_wb_o              ( rf_wdata_wb                  ),

    // LSU handshakes
    .lsu_valid_i                ( lsu_valid_1                  ),
    .lsu_ready_o                ( lsu_ready_wb                 ),
    .lsu_valid_o                ( lsu_valid_wb                 ),
    .lsu_ready_i                ( lsu_ready_1                  ),

    .data_stall_o               ( data_stall_wb                ),

    // Valid/ready
    .wb_ready_o                 ( wb_ready                     ),
    .wb_valid_o                 ( wb_valid                     ),

    // eXtension interface
    .xif_result_if              ( xif_result_if                ),

    .wpt_match_wb_o             ( wpt_match_wb                 ),
    .mpu_status_wb_o            ( mpu_status_wb                ),
    .align_status_wb_o          ( align_status_wb              ),

    // CSR/CLIC pointer inputs
    .clic_pa_valid_i            ( csr_clic_pa_valid            ),
    .clic_pa_i                  ( csr_clic_pa                  ),

    .last_op_o                  ( last_op_wb                   ),
    .abort_op_o                 ( abort_op_wb                  )
  );

  //////////////////////////////////////
  //        ____ ____  ____           //
  //       / ___/ ___||  _ \ ___      //
  //      | |   \___ \| |_) / __|     //
  //      | |___ ___) |  _ <\__ \     //
  //       \____|____/|_| \_\___/     //
  //                                  //
  //   Control and Status Registers   //
  //////////////////////////////////////

  cv32e40x_cs_registers
  #(
    .RV32                       ( RV32                   ),
    .A_EXT                      ( A_EXT                  ),
    .M_EXT                      ( M_EXT                  ),
    .X_EXT                      ( X_EXT                  ),
    .X_MISA                     ( X_MISA                 ),
    .X_ECS_XS                   ( X_ECS_XS               ),
    .ZC_EXT                     ( ZC_EXT                 ),
    .CLIC                       ( CLIC                   ),
    .CLIC_ID_WIDTH              ( CLIC_ID_WIDTH          ),
    .DEBUG                      ( DEBUG                  ),
    .DBG_NUM_TRIGGERS           ( DBG_NUM_TRIGGERS       ),
    .NUM_MHPMCOUNTERS           ( NUM_MHPMCOUNTERS       ),
    .MTVT_ADDR_WIDTH            ( MTVT_ADDR_WIDTH        )
  )
  cs_registers_i
  (
    .clk                        ( clk                    ),
    .rst_n                      ( rst_ni                 ),

    // Configuration
    .mhartid_i                  ( mhartid_i              ),
    .mimpid_patch_i             ( mimpid_patch_i         ),
    .mtvec_addr_i               ( mtvec_addr_i[31:0]     ),
    .csr_mtvec_init_i           ( csr_mtvec_init_if      ),

    // CSRs
    .dcsr_o                     ( dcsr                   ),
    .dpc_o                      ( dpc                    ),
    .jvt_addr_o                 ( jvt_addr               ),
    .jvt_mode_o                 ( jvt_mode               ),
    .mcause_o                   ( mcause                 ),
    .mcycle_o                   ( mcycle_o               ),
    .mepc_o                     ( mepc                   ),
    .mie_o                      ( mie                    ),
    .mintstatus_o               ( mintstatus             ),
    .mintthresh_th_o            ( mintthresh_th          ),
    .mstatus_o                  ( mstatus                ),
    .mtvec_addr_o               ( mtvec_addr             ),
    .mtvec_mode_o               ( mtvec_mode             ),
    .mtvt_addr_o                ( mtvt_addr              ),

    .priv_lvl_if_ctrl_o         ( priv_lvl_if_ctrl       ),
    .priv_lvl_lsu_o             ( priv_lvl_lsu           ),
    .priv_lvl_o                 ( priv_lvl               ),

    // ID/EX pipeline
    .id_ex_pipe_i               ( id_ex_pipe             ),
    .csr_illegal_o              ( csr_illegal            ),

    // EX/WB pipeline
    .ex_wb_pipe_i               ( ex_wb_pipe             ),

    // From controller_fsm
    .ctrl_fsm_i                 ( ctrl_fsm               ),

    // To controller_bypass
    .csr_counter_read_o         ( csr_counter_read       ),
    .csr_mnxti_read_o           ( csr_mnxti_read         ),
    .csr_irq_enable_write_o     ( csr_irq_enable_write   ),
    .csr_hz_o                   ( csr_hz                 ),

    // Interface to CSRs (SRAM like)
    .csr_rdata_o                ( csr_rdata              ),

    // Interrupts
    .mip_i                      ( mip                    ),
    .mnxti_irq_pending_i        ( mnxti_irq_pending      ),
    .mnxti_irq_id_i             ( mnxti_irq_id           ),
    .mnxti_irq_level_i          ( mnxti_irq_level        ),
    .clic_pa_valid_o            ( csr_clic_pa_valid      ),
    .clic_pa_o                  ( csr_clic_pa            ),

    // Time input
    .time_i                     ( time_i                 ),

    // CSR write strobes
    .csr_wr_in_wb_flush_o       ( csr_wr_in_wb_flush     ),

    // Debug
    .trigger_match_if_o         ( trigger_match_if       ),
    .trigger_match_ex_o         ( trigger_match_ex       ),
    .etrigger_wb_o              ( etrigger_wb            ),
    .pc_if_i                    ( pc_if                  ),
    .ptr_in_if_i                ( ptr_in_if              ),
    .priv_lvl_if_i              ( priv_lvl_if            ),
    .lsu_valid_ex_i             ( lsu_valid_ex           ),
    .lsu_addr_ex_i              ( lsu_addr_ex            ),
    .lsu_we_ex_i                ( lsu_we_ex              ),
    .lsu_be_ex_i                ( lsu_be_ex              ),
    .lsu_atomic_ex_i            ( lsu_atomic_ex          )
  );

  ////////////////////////////////////////////////////////////////////
  //    ____ ___  _   _ _____ ____   ___  _     _     _____ ____    //
  //   / ___/ _ \| \ | |_   _|  _ \ / _ \| |   | |   | ____|  _ \   //
  //  | |  | | | |  \| | | | | |_) | | | | |   | |   |  _| | |_) |  //
  //  | |__| |_| | |\  | | | |  _ <| |_| | |___| |___| |___|  _ <   //
  //   \____\___/|_| \_| |_| |_| \_\\___/|_____|_____|_____|_| \_\  //
  //                                                                //
  ////////////////////////////////////////////////////////////////////

  cv32e40x_controller
  #(
    .X_EXT                          ( X_EXT                  ),
    .A_EXT                          ( A_EXT                  ),
    .REGFILE_NUM_READ_PORTS         ( REGFILE_NUM_READ_PORTS ),
    .CLIC                           ( CLIC                   ),
    .CLIC_ID_WIDTH                  ( CLIC_ID_WIDTH          ),
    .RV32                           ( RV32                   ),
    .DEBUG                          ( DEBUG                  )
  )
  controller_i
  (
    .clk                            ( clk                    ),         // Gated clock
    .rst_n                          ( rst_ni                 ),

    .fetch_enable_i                 ( fetch_enable           ),

    // From ID/EX pipeline
    .id_ex_pipe_i                   ( id_ex_pipe             ),

    .csr_counter_read_i             ( csr_counter_read       ),
    .csr_mnxti_read_i               ( csr_mnxti_read         ),
    .csr_irq_enable_write_i         ( csr_irq_enable_write   ),

    // From EX/WB pipeline
    .ex_wb_pipe_i                   ( ex_wb_pipe             ),
    .mpu_status_wb_i                ( mpu_status_wb          ),
    .wpt_match_wb_i                 ( wpt_match_wb           ),
    .align_status_wb_i              ( align_status_wb        ),

    // last_op bits
    .last_op_id_i                   ( last_op_id             ),
    .last_op_ex_i                   ( last_op_ex             ),
    .last_op_wb_i                   ( last_op_wb             ),

    .abort_op_id_i                  ( abort_op_id            ),
    .abort_op_wb_i                  ( abort_op_wb            ),

    .if_valid_i                     ( if_valid               ),
    .pc_if_i                        ( pc_if                  ),
    .last_op_if_i                   ( last_op_if             ),
    .abort_op_if_i                  ( abort_op_if            ),

    // from IF/ID pipeline
    .if_id_pipe_i                   ( if_id_pipe             ),

    .alu_jmp_id_i                   ( alu_jmp_id             ),
    .alu_jmpr_id_i                  ( alu_jmpr_id            ),
    .alu_en_id_i                    ( alu_en_id              ),
    .sys_en_id_i                    ( sys_en_id              ),
    .sys_mret_id_i                  ( sys_mret_insn_id       ),
    .csr_en_raw_id_i                ( csr_en_raw_id          ),
    .first_op_id_i                  ( first_op_id            ),

    // LSU
    .data_stall_wb_i                ( data_stall_wb          ),
    .lsu_err_wb_i                   ( lsu_err_wb             ),
    .lsu_busy_i                     ( lsu_busy               ),
    .lsu_bus_busy_i                 ( lsu_bus_busy           ),
    .lsu_interruptible_i            ( lsu_interruptible      ),
    .lsu_valid_wb_i                 ( lsu_valid_wb           ),
    .lsu_atomic_ex_i                ( lsu_atomic_ex          ),
    .lsu_atomic_wb_i                ( lsu_atomic_wb          ),

    // jump/branch control
    .branch_decision_ex_i           ( branch_decision_ex     ),

    // Interrupt signals
    .irq_wu_ctrl_i                  ( irq_wu_ctrl            ),
    .irq_req_ctrl_i                 ( irq_req_ctrl           ),
    .irq_id_ctrl_i                  ( irq_id_ctrl            ),
    .irq_clic_shv_i                 ( irq_clic_shv           ),
    .irq_clic_level_i               ( irq_clic_level         ),
    .irq_clic_priv_i                ( irq_clic_priv          ),

    .wu_wfe_i                       ( wu_wfe_i               ),

    // From CSR registers
    .mtvec_mode_i                   ( mtvec_mode             ),
    .mcause_i                       ( mcause                 ),
    .mintstatus_i                   ( mintstatus             ),
    .csr_hz_i                       ( csr_hz                 ),

    // Trigger module
    .etrigger_wb_i                  ( etrigger_wb            ),

    // CSR write strobes
    .csr_wr_in_wb_flush_i           ( csr_wr_in_wb_flush     ),

    // Debug signals
    .debug_req_i                    ( debug_req_gated        ),
    .dcsr_i                         ( dcsr                   ),

    // Register File read, write back and forwards
    .rf_re_id_i                     ( rf_re_id               ),
    .rf_raddr_id_i                  ( rf_raddr_id            ),

    // Fencei flush handshake
    .fencei_flush_ack_i             ( fencei_flush_ack_i     ),
    .fencei_flush_req_o             ( fencei_flush_req_o     ),

    // Data OBI interface
    .m_c_obi_data_if                ( m_c_obi_data_if.monitor),

    .id_ready_i                     ( id_ready               ),
    .id_valid_i                     ( id_valid               ),
    .ex_ready_i                     ( ex_ready               ),
    .ex_valid_i                     ( ex_valid               ),
    .wb_ready_i                     ( wb_ready               ),
    .wb_valid_i                     ( wb_valid               ),

    .ctrl_byp_o                     ( ctrl_byp               ),
    .ctrl_fsm_o                     ( ctrl_fsm               ),

    // eXtension interface
    .xif_commit_if                  ( xif_commit_if          ),
    .xif_csr_error_i                ( xif_csr_error_ex       )
  );

  ////////////////////////////////////////////////////////////////////////
  //  _____      _       _____             _             _ _            //
  // |_   _|    | |     /  __ \           | |           | | |           //
  //   | | _ __ | |_    | /  \/ ___  _ __ | |_ _ __ ___ | | | ___ _ __  //
  //   | || '_ \| __|   | |    / _ \| '_ \| __| '__/ _ \| | |/ _ \ '__| //
  //  _| || | | | |_ _  | \__/\ (_) | | | | |_| | | (_) | | |  __/ |    //
  //  \___/_| |_|\__(_)  \____/\___/|_| |_|\__|_|  \___/|_|_|\___|_|    //
  //                                                                    //
  ////////////////////////////////////////////////////////////////////////

  generate
    if (CLIC) begin : gen_clic_interrupt
      assign mip          = '0;

      cv32e40x_clic_int_controller
      #(
          .CLIC_ID_WIDTH (CLIC_ID_WIDTH)
      )
      clic_int_controller_i
      (
        .clk                  ( clk                ),
        .rst_n                ( rst_ni             ),

        // CLIC interface
        .clic_irq_i           ( clic_irq_i         ),
        .clic_irq_id_i        ( clic_irq_id_i      ),
        .clic_irq_level_i     ( clic_irq_level_i   ),
        .clic_irq_priv_i      ( clic_irq_priv_i    ),
        .clic_irq_shv_i       ( clic_irq_shv_i     ),

        // To controller
        .irq_req_ctrl_o       ( irq_req_ctrl       ),
        .irq_id_ctrl_o        ( irq_id_ctrl        ),
        .irq_wu_ctrl_o        ( irq_wu_ctrl        ),
        .irq_clic_shv_o       ( irq_clic_shv       ),
        .irq_clic_level_o     ( irq_clic_level     ),
        .irq_clic_priv_o      ( irq_clic_priv      ),

        // From cs_registers
        .mstatus_i            ( mstatus            ),
        .mintthresh_th_i      ( mintthresh_th      ),
        .mintstatus_i         ( mintstatus         ),
        .mcause_i             ( mcause             ),
        .priv_lvl_i           ( priv_lvl           ),

        // To cs_registers
        .mnxti_irq_pending_o  ( mnxti_irq_pending  ),
        .mnxti_irq_id_o       ( mnxti_irq_id       ),
        .mnxti_irq_level_o    ( mnxti_irq_level    )
      );

      logic unused_clic_signals;
      assign unused_clic_signals = |mie;

    end else begin : gen_basic_interrupt
      cv32e40x_int_controller
      int_controller_i
      (
        .clk                  ( clk                ),
        .rst_n                ( rst_ni             ),

        // External interrupt lines
        .irq_i                ( irq_i              ),

        // To controller
        .irq_req_ctrl_o       ( irq_req_ctrl       ),
        .irq_id_ctrl_o        ( irq_id_ctrl[4:0]   ),
        .irq_wu_ctrl_o        ( irq_wu_ctrl        ),

        // To with cs_registers
        .mie_i                ( mie                ),
        .mstatus_i            ( mstatus            ),
        .priv_lvl_i           ( priv_lvl           ),

        // To/from with cs_registers
        .mip_o                ( mip                )
      );

      // Tie off unused irq_id_ctrl bits
      assign irq_id_ctrl[9:5] = 5'b00000;

      // CLIC shv not used in basic mode
      assign irq_clic_shv = 1'b0;
      assign irq_clic_level = 8'h00;
      assign irq_clic_priv = 2'b0;

      // CLIC mnxti not used in basic mode
      assign mnxti_irq_pending = 1'b0;
      assign mnxti_irq_id      = '0;
      assign mnxti_irq_level   = '0;
    end
  endgenerate

  /////////////////////////////////////////////////////////
  //  ____  _____ ____ ___ ____ _____ _____ ____  ____   //
  // |  _ \| ____/ ___|_ _/ ___|_   _| ____|  _ \/ ___|  //
  // | |_) |  _|| |  _ | |\___ \ | | |  _| | |_) \___ \  //
  // |  _ <| |__| |_| || | ___) || | | |___|  _ < ___) | //
  // |_| \_\_____\____|___|____/ |_| |_____|_| \_\____/  //
  //                                                     //
  /////////////////////////////////////////////////////////

  // Connect register file write port(s) to regfile inputs
  assign rf_we[0]    = rf_we_wb;
  assign rf_waddr[0] = rf_waddr_wb;
  assign rf_wdata[0] = rf_wdata_wb;

  cv32e40x_register_file_wrapper
  #(
    .REGFILE_NUM_READ_PORTS       ( REGFILE_NUM_READ_PORTS ),
    .RV32                         ( RV32                   )
  )
  register_file_wrapper_i
  (
    .clk                ( clk         ),
    .rst_n              ( rst_ni      ),

    // Read ports
    .raddr_i            ( rf_raddr_id ),
    .rdata_o            ( rf_rdata_id ),

    // Write ports
    .waddr_i            ( rf_waddr    ),
    .wdata_i            ( rf_wdata    ),
    .we_i               ( rf_we       )
  );


  // Some signals are unused on purpose (typically they are used by RVFI code). Use them here for easier LINT waiving.
  assign unused_signals = dbg_ack | irq_ack | (|irq_id) | (|irq_level) | (|irq_priv) | irq_shv;

endmodule
