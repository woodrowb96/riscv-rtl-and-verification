#include <cstdint>
#include <cstdio>

enum Opcodes : uint8_t {
  OpReg    = 0b0110011,
  OpImm    = 0b0010011,
  OpLoad   = 0b0000011,
  OpStore  = 0b0100011,
  OpBranch = 0b1100011,
  OpLui    = 0b0110111,
  OpAuipc  = 0b0010111,
  OpJal    = 0b1101111,
  OpJalr   = 0b1100111
};

extern "C" {

  uint32_t dpi_imm_gen_compute(uint32_t inst)
  {
    uint32_t imm {0xBADBAD00};
    uint8_t opcode = inst & 0x7F;

    switch(opcode)
    {
      //R-type
      case OpReg: {
        imm = 0;    //R types dont have an immediate, my riscv implementation outputs 0 for them
        break;
      }

      //I-type
      case OpImm:
      case OpLoad:
      case OpJalr: {
        imm = (inst >> 20);       //shift the imm into place
        if(inst & 0x80000000) {   //sign extend
          imm |= 0xFFFFF000;
        }
        break;
      }

      //S-type
      case OpStore: {
        //pick out the immediate
        uint32_t imm_11_5 = (inst >> 25) & 0x7F;   //inst[31:25]
        uint32_t imm_4_0  = (inst >> 7)  & 0x1F;   //inst[11:7]

        //combine
        imm = (imm_11_5 << 5) | imm_4_0;

        //sign extend
        if(inst & 0x80000000) {
          imm |= 0xFFFFF000;
        }
        break;
      }

      //B-type
      case OpBranch: {
        //pick out the immediate from inst
        uint32_t imm_12   = (inst >> 31) & 0x01;  //inst[31]
        uint32_t imm_11   = (inst >> 7)  & 0x01;  //inst[7]
        uint32_t imm_10_5 = (inst >> 25) & 0x3F;  //inst[30:25]
        uint32_t imm_4_1  = (inst >> 8)  & 0x0F;  //inst[11:8]
        uint32_t imm_0    = 0;                    //imm[0] == 0 for B-types

        //combine
        imm = (imm_12   << 12)
            | (imm_11   << 11)
            | (imm_10_5 << 5)
            | (imm_4_1  << 1)
            | (imm_0);

        //sign extend
        if(inst & 0x80000000) {
          imm |= 0xFFFFE000;
        }
        break;
      }

      //U-type
      case OpLui:
      case OpAuipc: {
        imm = inst;           //imm[31:12] is already in place
        imm &= 0xFFFFF000;    //lower 12 bits should be 0
        break;
      }

      //J-type
      case OpJal: {
        //pick out the immediate from inst
        uint32_t imm_20    = (inst >> 31) & 0x01;   //inst[31]
        uint32_t imm_19_12 = (inst >> 12) & 0xFF;   //inst[19:12]
        uint32_t imm_11    = (inst >> 20) & 0x01;   //inst[20]
        uint32_t imm_10_1  = (inst >> 21) & 0x3FF;  //inst[30:21]
        uint32_t imm_0     = 0;                     //imm[0] == 0 for J-types

        //combine
        imm = (imm_20    << 20)
            | (imm_19_12 << 12)
            | (imm_11   << 11)
            | (imm_10_1 << 1)
            | (imm_0);

        //sign extend
        if(inst & 0x80000000) {
          imm |= 0xFFE00000;
        }
        break;
      }

      //Invalid opcode
      default: {
        fprintf(stderr, "[IMM_GEN_REF_MODEL] invalid opcode: 0x%02X\n", opcode);
        imm = 0xBADBAD00;
        break;
      }
    } //end switch

    return imm;
  } //endfunction
}
