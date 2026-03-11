package tb_imm_gen_generator_pkg;
  import base_generator_pkg::*;
  import rv32i_defs_pkg::*;
  import verify_const_pkg::*;
  import tb_imm_gen_transaction_pkg::*;

  //SEE THE NOTE IN: tb_lut_ram_generator_pkg.sv for why im using child trans
  //classes instead of just inlining this stuff in the generator
  class imm_gen_trans_i_type_corners extends imm_gen_trans;

    constraint i_type_opcodes {
      inst[6:0] inside {OP_IMM, OP_LOAD, OP_JALR};
    };

    constraint i_type_corners {
      inst[30:20] dist {
        IMM_11_ALL_ZEROS  := 3,
        IMM_11_ALL_ONES   := 3
      };
    };
  endclass

  class imm_gen_trans_s_type_corners extends imm_gen_trans;

    constraint s_type_opcodes {
      inst[6:0] == OP_STORE;
    };


    //THIS CRASHES VIVADO DURING ELABORATION WITH A SEG FAULT
    // constraint s_type_corners {
    //   {inst[30:25], inst[11:7]} dist {
    //     IMM_11_ALL_ZEROS  := 3,
    //     IMM_11_ALL_ONES   := 3,
    //     IMM_11_ALT_55     := 3,
    //     IMM_11_ALT_AA     := 3
    //   };
    // };

    //using post rand to workaround the vivado bug, see the note below
    function void post_randomize();

      super.post_randomize(); //call parent's post_rand to make sure the MSB gets randomized

      randcase
        1: {inst[30:25], inst[11:7]} = IMM_11_ALL_ZEROS;
        1: {inst[30:25], inst[11:7]} = IMM_11_ALL_ONES;
        1: {inst[30:25], inst[11:7]} = IMM_11_ALT_55;
        1: {inst[30:25], inst[11:7]} = IMM_11_ALT_AA;
      endcase
    endfunction

    /******************  NOTE ***********************************/
    //The s_type_corners constraint above uses concatenated bit slices in its
    //dist to constrain the encoded immediate. This doesnt work and causes the
    //following bug with my version of vivado.
    //
    //VIVADO BUG:
    //  xelab seg faults during elaboration when it encounters
    //  any constraint (dist or inside) on concatenated bit-slices
    //  of a rand variable.
    //
    //I just use the post_rand to do this manually as a workaround
    /******************************************************/
  endclass

  class imm_gen_trans_b_type_corners extends imm_gen_trans;

    constraint b_type_opcodes {
      inst[6:0] == OP_BRANCH;
    };

    //SEE BUG NOTE IN S_TYPE_CORNERS
    // constraint b_type_corners {
    //   {inst[7], inst[30:25], inst[11:8]} dist {
    //     IMM_11_ALL_ZEROS  := 3,
    //     IMM_11_ALL_ONES   := 3,
    //     IMM_11_ALT_55     := 3,
    //     IMM_11_ALT_AA     := 3
    //   };
    // };

    function void post_randomize();
      super.post_randomize();

      randcase
        1: {inst[7], inst[30:25], inst[11:8]} = IMM_11_ALL_ZEROS;
        1: {inst[7], inst[30:25], inst[11:8]} = IMM_11_ALL_ONES;
        1: {inst[7], inst[30:25], inst[11:8]} = IMM_11_ALT_55;
        1: {inst[7], inst[30:25], inst[11:8]} = IMM_11_ALT_AA;
      endcase
    endfunction
  endclass

  class imm_gen_trans_u_type_corners extends imm_gen_trans;

    constraint u_type_opcodes {
      inst[6:0] inside {OP_LUI, OP_AUIPC};
    };

    constraint u_type_corners {
      inst[31:12] dist {
        IMM_20_ALL_ZEROS  := 3,
        IMM_20_ALL_ONES   := 3
      };
    };
  endclass

  class imm_gen_trans_j_type_corners extends imm_gen_trans;

    constraint j_type_opcodes {
      inst[6:0] == OP_JAL;
    };

    //SEE BUG NOTE IN S_TYPE_CORNERS
    // constraint j_type_corners {
    //   {inst[19:12], inst[20], inst[30:21]} dist {
    //     IMM_19_ALL_ZEROS  := 3,
    //     IMM_19_ALL_ONES   := 3,
    //     IMM_19_ALT_55     := 3,
    //     IMM_19_ALT_AA     := 3
    //   };
    // };

    function void post_randomize();
      super.post_randomize();

      randcase
        1: {inst[19:12], inst[20], inst[30:21]} = IMM_19_ALL_ZEROS;
        1: {inst[19:12], inst[20], inst[30:21]} = IMM_19_ALL_ONES;
        1: {inst[19:12], inst[20], inst[30:21]} = IMM_19_ALT_55;
        1: {inst[19:12], inst[20], inst[30:21]} = IMM_19_ALT_AA;
      endcase
    endfunction
  endclass

  /************************* GENERATOR *****************************/
  class imm_gen_default_gen extends base_generator #(imm_gen_trans);

    function new(mailbox_t gen_to_drv_mbx);
      super.new("IMM_GEN_DEFAULT_GEN", gen_to_drv_mbx);
    endfunction

    function imm_gen_trans gen_trans();
      imm_gen_trans trans;

      //We use the randcase to choose which format type to generate.
      //Each format type has its own corner constraints.
      randcase
        //base transaction (no corner constraints, covers non-corners)
        1: begin
          imm_gen_trans trans_base = new();

          assert(trans_base.randomize()) else
            $fatal(1, "[TB_IMM_GEN_GENERATOR]: gen_trans() randomization failed, base trans");

          trans = trans_base;
        end
        //I-type
        1: begin
          imm_gen_trans_i_type_corners trans_i = new();

          assert(trans_i.randomize()) else
            $fatal(1, "[TB_IMM_GEN_GENERATOR]: gen_trans() randomization failed, I-type trans");

          trans = trans_i;
        end
        //S-type
        1: begin
          imm_gen_trans_s_type_corners trans_s = new();

          assert(trans_s.randomize()) else
            $fatal(1, "[TB_IMM_GEN_GENERATOR]: gen_trans() randomization failed, S-type trans");

          trans = trans_s;
        end
        //B-type
        1: begin
          imm_gen_trans_b_type_corners trans_b = new();

          assert(trans_b.randomize()) else
            $fatal(1, "[TB_IMM_GEN_GENERATOR]: gen_trans() randomization failed, B-type trans");

          trans = trans_b;
        end
        //U-type
        1: begin
          imm_gen_trans_u_type_corners trans_u = new();

          assert(trans_u.randomize()) else
            $fatal(1, "[TB_IMM_GEN_GENERATOR]: gen_trans() randomization failed, U-type trans");

          trans = trans_u;
        end
        //J-type
        1: begin
          imm_gen_trans_j_type_corners trans_j = new();

          assert(trans_j.randomize()) else
            $fatal(1, "[TB_IMM_GEN_GENERATOR]: gen_trans() randomization failed, J-type trans");

          trans = trans_j;
        end
      endcase

      return trans;
    endfunction
  endclass
endpackage
