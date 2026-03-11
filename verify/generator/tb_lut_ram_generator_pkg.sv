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
  //  (for example the bellow generator class) elaboration with xelab fails
  //  with a seg fault.
  //
  // So wrapping all the constraints in a transaction child class is the
  // workaround. Idealy theyde be inline constraints so I wouldnt have to pass
  // any info into them (like the prev_written_addr queue).
  /******************************************************/
  class lut_ram_trans_corners #(parameter int LUT_WIDTH = 32, parameter int LUT_DEPTH = 256) 
    extends lut_ram_trans #(LUT_WIDTH, LUT_DEPTH);

    localparam longint unsigned ALL_ZEROS = {LUT_WIDTH{1'b0}};
    localparam longint unsigned ALL_ONES = {LUT_WIDTH{1'b1}};
    localparam int     unsigned MIN_ADDR = 0;
    localparam int     unsigned MAX_ADDR = LUT_DEPTH - 1;

    //We want to hit each corner with equal probability
    constraint lut_ram_const_corners {
      wr_addr dist {
        MIN_ADDR := 1,
        MAX_ADDR := 1
      };
      rd_addr dist {
        MIN_ADDR := 1,
        MAX_ADDR := 1
      };
    };

    //write some corners, but mostly the full range
    constraint lut_ram_data_corners {
      wr_data dist {
        ALL_ZEROS            := 1,
        ALL_ONES             := 1,
        [ALL_ZEROS:ALL_ONES] :/ 5
      };
    };
  endclass

  class lut_ram_trans_prev_written #(parameter int LUT_WIDTH = 32, parameter int LUT_DEPTH = 256)
    extends lut_ram_trans #(LUT_WIDTH, LUT_DEPTH);

    localparam longint unsigned ALL_ZEROS = {LUT_WIDTH{1'b0}};
    localparam longint unsigned ALL_ONES = {LUT_WIDTH{1'b1}};

    //I initialize the prev_written queue so that the solver wont fail when it
    //tries and solve the inside {empty_queue}
    logic[$clog2(LUT_DEPTH)-1:0] prev_written_addr [$] = {0};

    //we want a random address that we have already written too
    constraint lut_ram_constr_prev_written{
      wr_addr inside {prev_written_addr};
      rd_addr inside {prev_written_addr};
    };

    constraint lut_ram_data_corners {
      wr_data dist {
        ALL_ZEROS            := 1,
        ALL_ONES             := 1,
        [ALL_ZEROS:ALL_ONES] :/ 5
      };
    };
  endclass

  class lut_ram_trans_full_addr_range #(parameter int LUT_WIDTH = 32, parameter int LUT_DEPTH = 256)
    extends lut_ram_trans #(LUT_WIDTH, LUT_DEPTH);

    localparam longint unsigned ALL_ZEROS = {LUT_WIDTH{1'b0}};
    localparam longint unsigned ALL_ONES = {LUT_WIDTH{1'b1}};
    localparam int     unsigned MIN_ADDR = 0;
    localparam int     unsigned MAX_ADDR = LUT_DEPTH - 1;

    //we want a random address from the full range, with no restrictions
    constraint lut_ram_full_addr_range {
      wr_addr inside { [MIN_ADDR:MAX_ADDR] };
      rd_addr inside { [MIN_ADDR:MAX_ADDR] };
    };

    constraint lut_ram_data_corners {
      wr_data dist {
        ALL_ZEROS            := 1,
        ALL_ONES             := 1,
        [ALL_ZEROS:ALL_ONES] :/ 5
      };
    };
  endclass

  /************************** GENERATOR ************************************/
  class lut_ram_default_gen #(parameter int LUT_WIDTH = 32, parameter int LUT_DEPTH = 256)
    extends base_generator #(lut_ram_trans #(LUT_WIDTH, LUT_DEPTH));

    typedef lut_ram_trans_prev_written #(LUT_WIDTH, LUT_DEPTH)    trans_prev_written_t;
    typedef lut_ram_trans_corners #(LUT_WIDTH, LUT_DEPTH)         trans_corners_t;
    typedef lut_ram_trans_full_addr_range #(LUT_WIDTH, LUT_DEPTH) trans_full_addr_range_t;
    typedef lut_ram_trans #(LUT_WIDTH, LUT_DEPTH)                 base_trans_t;
    typedef logic [$clog2(LUT_DEPTH)-1:0] addr_t;

    //generator needs to keep track of generated transactions
    addr_t prev_written_addr [$] = {0};

    function new(mailbox_t gen_to_drv_mbx);
      super.new("LUT_RAM_DEFAULT_GEN", gen_to_drv_mbx);
    endfunction

    //the tb can call this to clear the generated wr_addr history if it needs to
    function void reset_prev_written_addr();
      prev_written_addr = {0};
    endfunction

    function base_trans_t gen_trans();
      base_trans_t trans;

      //use a randcase to decide whether we want to generate addressses from
      //our corners, previously written queue, or the full address range.
      randcase
        1: begin
          trans_corners_t trans_corners = new();

          assert(trans_corners.randomize()) else
            $fatal(1, "TB_LUT_RAM_GENERATOR: gen_trans() randomization failed, corners");

          trans = trans_corners;
        end
        5: begin
          trans_prev_written_t trans_prev_written = new();

          //give the trans the current set of prev written addresses
          trans_prev_written.prev_written_addr = prev_written_addr;

          assert(trans_prev_written.randomize()) else
            $fatal(1, "TB_LUT_RAM_GENERATOR: gen_trans() randomization failed, prev_written");

          trans = trans_prev_written;
        end
        2: begin
          trans_full_addr_range_t trans_full_addr_range = new();

          assert(trans_full_addr_range.randomize()) else
            $fatal(1, "TB_LUT_RAM_GENERATOR: gen_trans() randomization failed, full_range");

          trans = trans_full_addr_range;
        end
      endcase

      //update the set of previously written addresses
      if(trans.wr_en) begin
        prev_written_addr.push_back(trans.wr_addr);
      end

      return trans;
    endfunction
  endclass
endpackage
