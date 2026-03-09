/*
  Coverage for this module is collected manually through the sample() function.

  Coverage was written with the following sampling assumptions concerning sampling.

  COVERAGE SAMPLING ASSUMPTIONS:
        - sample() is being called AFTER the DUT signals have been driven onto the DUT's input ports
          and AFTER the combinatorial rd_reg's have had time to propagate to the rd_data outputs
          but BEFORE the new wr_data has been clocked into the wr_reg.

        - So something like this:
                                  drive
                                  #PROPAGATION_DELAY  //let rd_reg propagate to rd_data
                                  monitor
                                  coverage.sample();
                                  @(posedge clk)      //clk the new wr_data into the reg_file
        -NOTE:
            - The covergroup uses written, prev_wr_en and prev_register to collect coverage.
            - These variables are all updated when you call sample().
            - If you drive/clock the DUT without calling sample(), manually update
              written, prev_wr_en, and prev_wr_reg or else the coverage state will
              get out of sync with the test state.
       - NOTE:
            - If you reset the DUT in between tests you can call reset_state() to
              reset written, prev_wr_en and prev_wr_reg to a clean state.
              (this will NOT reset the coverage percentages, just the state variables)
*/
package tb_reg_file_coverage_pkg;
  import rv32i_defs_pkg::*;
  import verify_const_pkg::*;

  class tb_reg_file_coverage;

    virtual reg_file_intf.monitor vif;

    /*==============================  COVERGROUP  =================================*/

    //We want to keep track of some stuff to help us collect coverage
    bit [RF_DEPTH-1:0] written; //track which registers have been written to
    logic prev_wr_en;
    rf_addr_t prev_wr_reg;

    covergroup cg;
      /********************** WRITE COVERAGE *********************/

      wr_en: coverpoint vif.wr_en{
        bins write = {1'b1};
        bins no_write = {1'b0};
      }

      //cover the lower 31 writable registers
      wr_reg: coverpoint vif.wr_reg {
        ignore_bins x0 = {X0};  //we'll cover x0 behavior separately
      }

      //we want to write and not write to each writable register
      wr_en_x_wr_reg: cross wr_en, wr_reg;

      back_to_back_wr: coverpoint ((vif.wr_reg == prev_wr_reg) && (vif.wr_en && prev_wr_en)) {
          bins hit = {1};
      }

      //Note: iff(vif.wr_en && vif.wr_reg)
      //  - Coverage on wr_data functionality is only relevant when we are
      //    actually writing (wr_en asserted) into writable (non-x0) registers.
      wr_data: coverpoint vif.wr_data
        iff(vif.wr_en && vif.wr_reg != X0) {
          bins zeros      = {WORD_ALL_ZEROS};
          bins all_ones   = {WORD_ALL_ONES};
          bins non_corner = default;
        }

      //we want to write corner values into all the writable registers
      wr_data_x_wr_reg: cross wr_data, wr_reg;


      /******************* READ COVERAGE **********************/

      //Cover the read registers ONLY AFTER they have been written into.
      //  - NOTE: iff(written[rd_reg])
      //     - We are not really interested in covering the reading of
      //       uninitialized x's from unwritten registers.
      //       The functionality we are really interested in is reading
      //       data out that has already been written in.
      //     - Reading x's out from uninitialized registers also doesn't
      //       really give us much to verify rd_reg functionality.
      //       We want to collect coverage on functionality ONLY when its
      //       in a verifiable state.
      rd_reg_1: coverpoint vif.rd_reg_1
        iff(written[vif.rd_reg_1]) {
          ignore_bins x0 = {X0};    //we'll cover x0 separately
      }
      rd_reg_2: coverpoint vif.rd_reg_2 
        iff(written[vif.rd_reg_2]) {
          ignore_bins x0 = {X0};
      }

      rd_data_1: coverpoint vif.rd_data_1
        iff(vif.rd_reg_1 != X0) {
          bins zeros      = {WORD_ALL_ZEROS};
          bins all_ones   = {WORD_ALL_ONES};
          bins non_corner = default;
      }
      rd_data_2: coverpoint vif.rd_data_2
        iff(vif.rd_reg_2 != X0) {
          bins zeros      = {WORD_ALL_ZEROS};
          bins all_ones   = {WORD_ALL_ONES};
          bins non_corner = default;
      }

      //read out corners from all 31 non-x0 registers
      rd_data_1_x_rd_reg_1: cross rd_data_1, rd_reg_1;
      rd_data_2_x_rd_reg_2: cross rd_data_2, rd_reg_2;

      //NOTE: iff(written[rd_reg])
      //   - We only care about this scenario when the register holds valid written data.
      //     Simultaneous reads to uninitialized registers isn't really an interesting functionality.
      simultaneous_reads_from_the_same_reg: coverpoint (vif.rd_reg_1 == vif.rd_reg_2)
        iff(written[vif.rd_reg_1]) {
          bins hit = {1};
      }

      //Cover reading and writing to the same register during the same clk cycle.
      //  - rd_data will read out the OLD data in the register, NOT the NEW
      //    wr_data about to be written in.
      //  - NOTE: iff(rd_data != wr_data)
      //     - We can only verify this functionality (that rd_data isn't
      //       reading wr_data yet) when rd_data and wr_data are different.
      //  - NOTE:
      //     - I don't guard with iff(written[rd_reg_1]) here. The
      //       interesting functionality here is that the new writes aren't
      //       appearing in the register yet. So we dont really care if
      //       the current rd_data is uninitialized, we just care that it
      //       is not what's on the wr_data port yet.
      read_during_write_reg_1: coverpoint ((vif.wr_reg == vif.rd_reg_1) && vif.wr_en)
        iff(vif.rd_data_1 != vif.wr_data) {
          bins hit = {1};
      }
      read_during_write_reg_2: coverpoint ((vif.wr_reg == vif.rd_reg_2) && vif.wr_en)
        iff(vif.rd_data_2 != vif.wr_data) {
          bins hit = {1};
      }

      //After writing to a reg, we want to cover reading from it in the clk
      //cycle IMMEDIATELY after the write.
      //  - Note:
      //      - There is a small verifiability gap here.
      //      - Consider the following corner scenario:
      //              @clk rd_reg has 5 in it                     //first cycle
      //              @clk wr_reg writes 5 into rd_reg            //second cycle
      //              @clk we rd_reg again (triggering coverage)  //third cycle
      //        On the third cycle we can't really verify much about the
      //        functionality (Is new write data available for reading in the
      //        next clk cycle? We don't know since rd_reg already held 5.)
      //      - To fill this gap I would need to track values in the reg_file
      //        across multiples of clk cycles. In a professional environment
      //        the added infrastructure complexity would be worth it, but for a
      //        personal project I am choosing to keep the coverage class relatively
      //        simple in this regard.
      next_cycle_read_after_write_reg_1: coverpoint ((vif.rd_reg_1 == prev_wr_reg) && prev_wr_en) {
        bins hit = {1};
      }
      next_cycle_read_after_write_reg_2: coverpoint ((vif.rd_reg_2 == prev_wr_reg) && prev_wr_en) {
        bins hit = {1};
      }


      /**************** X0 COVERAGE *********************/

      //We want to cover exercising x0s write immunity behavior
      // - Note: iff(wr_data != 0)
      //    - x0 is hardwired to zero. We can only verify x0_write_immunity
      //      functionality when we are trying to write non-zero into it.
      x0_write_immunity: coverpoint (vif.wr_reg == X0 && vif.wr_en)
        iff (vif.wr_data != '0) {
          bins hit = {1};
      }

      x0_rd_reg_1: coverpoint (vif.rd_reg_1 == X0);
      x0_rd_reg_2: coverpoint (vif.rd_reg_2 == X0);
    endgroup

    /*========================= MEMBER FUNCTIONS ==============================*/

    function void update_state();
      if(vif.wr_en) begin
        written[vif.wr_reg] = 1'b1;
      end
      prev_wr_en = vif.wr_en;
      prev_wr_reg = vif.wr_reg;
    endfunction

    //if DUT ever gets reset in a test, we can call this to keep coverage in sync
    function void reset_state();
      written = '0;     //none of the registers have been written yet
      prev_wr_en = '0;  //we didnt write previously
      prev_wr_reg = 'x; //we have no past wr_reg
    endfunction

    function void sample();
      cg.sample();
      update_state(); //update state after we sample
    endfunction

    function new(virtual reg_file_intf.monitor vif);
      this.vif = vif;
      this.cg = new();
      this.reset_state();
    endfunction
  endclass

endpackage
