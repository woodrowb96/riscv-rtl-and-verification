#include <cstdint>
#include <cstdio>

enum AluControl : uint8_t {
  AluAnd = 0b0000,
  AluOr  = 0b0001,
  AluAdd = 0b0010,
  AluSub = 0b0110,
};

extern "C" {

  void dpi_alu_compute(
      //input
      uint8_t  alu_op,
      uint32_t in_a,
      uint32_t in_b,
      //output
      uint32_t* result_out,
      uint8_t*  zero_out)
  {
    uint32_t result {0xBADBAD00};
    uint8_t  zero   {0};

    //make sure we didnt get passed nullptrs
    if(!result_out || !zero_out) {
      fprintf(stderr, "[ALU_REF_MODEL] passed nullptrs");
      return;
    }

    switch(alu_op)
    {
      case AluAnd: {
        result = in_a & in_b;
        break;
      }
      case AluOr: {
        result = in_a | in_b;
        break;
      }
      case AluAdd: {
        result = in_a + in_b;
        break;
      }
      case AluSub: {
        result = in_a - in_b;
        break;
      }
      default: {
        result = 0;
        break;
      }
    }//end switch

    zero = (result == 0);

    *zero_out = zero;
    *result_out = result;
  }//end function

}//end extern
