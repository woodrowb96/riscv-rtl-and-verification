package tb_lut_ram_generator_pkg;
  import base_generator_pkg::*;
  import tb_lut_ram_transaction_pkg::*;

  /******************  NOTE ***********************************/
  //These transaction child classes should probably just be inline constraints
  //inside the generator, but I encountered a vivado bug that doesnt let me do
  //that.
  //
  //VIVADO BUG:
  //  Whenever I try and .randomize() a transaction with inline constraints inside a class
  //  (for example the below generator class) elaboration with xelab fails
  //  with a seg fault.
  //
  // So wrapping all the constraints in a transaction child class is the
  // workaround. Ideally they'd be inline constraints so I wouldnt have to pass
  // any info into them (like the prev_written_addr queue).
  /******************************************************/

  class lut_ram_trans_weighted_wr_data #(
    parameter int LUT_WIDTH = 32,
    parameter int LUT_DEPTH = 256
  ) extends lut_ram_trans #(LUT_WIDTH, LUT_DEPTH);

    localparam longint unsigned ALL_ZEROS = {LUT_WIDTH{1'b0}};
    localparam longint unsigned ALL_ONES = {LUT_WIDTH{1'b1}};

    //NOTE:The base lut_ram_trans already constrains 
    //addresses to the legal range i.e {[0:LUT_DEPTH-1]}

    //hit the corners, but also get some full range values too
    constraint lut_ram_data_corners {
      wr_data dist {
        ALL_ZEROS            := 1,
        ALL_ONES             := 1,
        [ALL_ZEROS:ALL_ONES] :/ 5
      };
    };
  endclass

  class lut_ram_trans_corner_addr #(
    parameter int LUT_WIDTH = 32,
    parameter int LUT_DEPTH = 256
  ) extends lut_ram_trans_weighted_wr_data #(LUT_WIDTH, LUT_DEPTH); //use the weighted wr_data constraints

    localparam int     unsigned MIN_ADDR = 0;
    localparam int     unsigned MAX_ADDR = LUT_DEPTH - 1;

    constraint lut_ram_const_corners {
      wr_addr inside { MIN_ADDR, MIN_ADDR + 1, MAX_ADDR - 1, MAX_ADDR };
      rd_addr inside { MIN_ADDR, MIN_ADDR + 1, MAX_ADDR - 1, MAX_ADDR };
    };

  endclass

  class lut_ram_trans_prev_written_addr #(
    parameter int LUT_WIDTH = 32,
    parameter int LUT_DEPTH = 256
  ) extends lut_ram_trans_weighted_wr_data #(LUT_WIDTH, LUT_DEPTH); //use the weighted wr_data constraints

    logic[$clog2(LUT_DEPTH)-1:0] prev_written_addr [$];

    function new(logic[$clog2(LUT_DEPTH)-1:0] prev_written_addr [$]);
      super.new();
      this.prev_written_addr = prev_written_addr;
    endfunction

    //pick a random address weve written to already
    constraint lut_ram_constr_prev_written{
      wr_addr inside {prev_written_addr};
      rd_addr inside {prev_written_addr};
    };
  endclass

  /*==============================================================================*/
  /*------------------------------ GENERATOR -------------------------------------*/
  /*==============================================================================*/
  class lut_ram_default_gen #(
    parameter int LUT_WIDTH = 32,
    parameter int LUT_DEPTH = 256
  ) extends base_generator #(lut_ram_trans #(LUT_WIDTH, LUT_DEPTH));

    typedef logic [$clog2(LUT_DEPTH)-1:0] addr_t;
    typedef lut_ram_trans                   #(LUT_WIDTH, LUT_DEPTH) trans_base_t;
    typedef lut_ram_trans_weighted_wr_data  #(LUT_WIDTH, LUT_DEPTH) trans_full_addr_range_t;
    typedef lut_ram_trans_prev_written_addr #(LUT_WIDTH, LUT_DEPTH) trans_prev_written_addr_t;
    typedef lut_ram_trans_corner_addr       #(LUT_WIDTH, LUT_DEPTH) trans_corner_addr_t;

    //use a dynamic queue to keep track of previously written addresses
    //  - Note: I init with 0, so the solver never tries to solve a 
    //          constraint with an empty queue in it
    addr_t prev_written_addr [$] = {0};

    function new(mailbox_t gen_to_drv_mbx);
      super.new("LUT_RAM_DEFAULT_GEN", gen_to_drv_mbx);
    endfunction

    function void reset_prev_written_addr();
      prev_written_addr = {0};
    endfunction

    function void update_prev_written_addr(trans_base_t trans);
      if(trans.wr_en) begin
        prev_written_addr.push_back(trans.wr_addr);
      end
    endfunction

    /*=================== GEN_TRANS() =================*/

    task gen_trans(output trans_base_t trans);

      //Randomly choose the type of address we want
      //All trans will have the same wr_data weights (see lut_ram_trans_weighted_wr_data above)
      randcase

        //corner addresses
        2: begin
          trans_corner_addr_t trans_corner_addr = new();

          assert(trans_corner_addr.randomize()) else
            $fatal(1, "TB_LUT_RAM_GENERATOR: gen_trans() randomization failed, corner_addr");

          trans = trans_corner_addr;
        end

        //previously written address
        5: begin
          trans_prev_written_addr_t trans_prev_written_addr = new(prev_written_addr);

          assert(trans_prev_written_addr.randomize()) else
            $fatal(1, "TB_LUT_RAM_GENERATOR: gen_trans() randomization failed, prev_written_addr");

          trans = trans_prev_written_addr;
        end

        //full address range
        2: begin
          trans_full_addr_range_t trans_full_addr_range = new();

          assert(trans_full_addr_range.randomize()) else
            $fatal(1, "TB_LUT_RAM_GENERATOR: gen_trans() randomization failed, full_range_addr");

          trans = trans_full_addr_range;
        end
      endcase

      //update the previously writtens
      update_prev_written_addr(trans);
    endtask
  endclass

endpackage
