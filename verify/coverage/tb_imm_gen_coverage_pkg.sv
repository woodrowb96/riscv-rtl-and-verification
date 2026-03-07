package tb_imm_gen_coverage_pkg;
  import rv32i_defs_pkg::*;
  import verify_const_pkg::*;

  class tb_imm_gen_coverage;

    virtual imm_gen_intf.monitor vif;

    covergroup cg;
      /********************* OPCODE COVERAGE **************************/
      //we want to cover each opcode
      opcode: coverpoint vif.inst[6:0] {
        bins op_reg    = {OP_REG};
        bins op_imm    = {OP_IMM};
        bins op_load   = {OP_LOAD};
        bins op_store  = {OP_STORE};
        bins op_branch = {OP_BRANCH};
        bins op_lui    = {OP_LUI};
        bins op_auipc  = {OP_AUIPC};
        bins op_jal    = {OP_JAL};
        bins op_jalr   = {OP_JALR};
      }

      /********************** SIGN COVERAGE ****************************/
      //inst[31] is the sign bit for all immediate formats.
      sign: coverpoint vif.inst[31] {
        bins pos = {1'b0};
        bins neg = {1'b1};
      }

      /**************** ENCODED IMMEDIATE CORNERS *************************/
      //Note: I cover the sign bit separately, so each encoded imm corner is 1 bit
      //      less than the actual length. Later in coverage I cross the
      //      corners with the sign separately.
      //
      //Note: I dont cover R-type corners since it has no encoded immediate.
      //      Covering it once in the opcode coverpoint is sufficient.

      //I-type encoded immediate (inst[30:20]), excluding the sign bit (inst[31])
      i_type_corners: coverpoint vif.imm[10:0]
        iff(vif.inst[6:0] inside {OP_IMM, OP_LOAD, OP_JALR}) {
          bins all_zeros = {IMM_11_ALL_ZEROS};
          bins all_ones  = {IMM_11_ALL_ONES};
          bins other = default;

          //Note: I dont cover the alternating bit patterns (AAA/555) since
          //      the I-type imm is stored across 1 big chunk in the instruction.
          //      Those patterns are more useful for the S/B/J-types where the
          //      encoded bits are split up inside the instruction and need
          //      to be reassembled.
      }

      //S-type encoded immediate {inst[30:25],inst[11:7]} excluding sign bit inst[31]
      s_type_corners: coverpoint vif.imm[10:0]
        iff(vif.inst[6:0] inside {OP_STORE}) {
          bins all_zeros = {IMM_11_ALL_ZEROS};
          bins all_ones  = {IMM_11_ALL_ONES};
          bins alt_55    = {IMM_11_ALT_55};     //the pattern 0101 repeated
          bins alt_aa    = {IMM_11_ALT_AA};     //the pattern 1010 repeated
          bins other = default;
      }

      //B-type encoded immediate {inst[7],inst[30:25],inst[11:8]} excluding the sign bit
      b_type_corners: coverpoint vif.imm[11:1] //bit 0 is not part of the encoded imm
        iff(vif.inst[6:0] inside {OP_BRANCH}) {
          bins all_zeros = {IMM_11_ALL_ZEROS};
          bins all_ones  = {IMM_11_ALL_ONES};
          bins alt_55    = {IMM_11_ALT_55};     //the pattern 0101 repeated
          bins alt_aa    = {IMM_11_ALT_AA};     //the pattern 1010 repeated
          bins other = default;
      }

      //U-type encoded immediate {inst[31:12]}
      //NOTE: U-types dont sign extend so im including the sign bit here and 
      //      wont cross it later.
      u_type_corners: coverpoint vif.imm[31:12]
        iff(vif.inst[6:0] inside {OP_LUI, OP_AUIPC}) {
          bins all_zeros = {IMM_20_ALL_ZEROS};
          bins all_ones  = {IMM_20_ALL_ONES};
          bins other = default;
      }

      //J-type encoded immediate {inst[19:12],inst[20], inst[30:21]}, excluding sign bit
      j_type_corners: coverpoint vif.imm[19:1]
        iff(vif.inst[6:0] inside {OP_JAL}) {
          bins all_zeros = {IMM_19_ALL_ZEROS};
          bins all_ones  = {IMM_19_ALL_ONES};
          bins alt_55    = {IMM_19_ALT_55};
          bins alt_aa    = {IMM_19_ALT_AA};
          bins other = default;
      }

      /************* SIGN EXTENSION X ENCODED IMMEDIATE CORNERS *****************/
      //we want to cover pos and neg sign extension for each corner

      //I-type
      sign_x_i_type_corners: cross sign, i_type_corners;

      //S-type
      sign_x_s_type_corners: cross sign, s_type_corners;

      //B-type
      sign_x_b_type_corners: cross sign, b_type_corners;

      //J-type
      sign_x_j_type_corners: cross sign, j_type_corners;
    endgroup

    function void sample();
      cg.sample();
    endfunction

    function new(virtual imm_gen_intf.monitor vif);
      this.vif = vif;
      this.cg = new();
    endfunction

  endclass

endpackage
