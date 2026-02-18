package tb_lut_ram_transaction_pkg;

  class lut_ram_trans #(parameter int LUT_WIDTH = 32, parameter int LUT_DEPTH = 256);
    rand logic wr_en;
    rand logic [$clog2(LUT_DEPTH)-1:0] wr_addr;
    rand logic [$clog2(LUT_DEPTH)-1:0] rd_addr;
    rand logic [LUT_WIDTH-1:0] wr_data;

    logic [LUT_WIDTH-1:0] rd_data;

    //We want to keep the addresses within the legal range
    constraint legal_address_range{
      wr_addr inside {[0:LUT_DEPTH-1]};
      rd_addr inside {[0:LUT_DEPTH-1]};
    }

    function bit compare(lut_ram_trans #(LUT_WIDTH, LUT_DEPTH) other);
      return (this.wr_en   === other.wr_en   &&
              this.wr_addr === other.wr_addr &&
              this.rd_addr === other.rd_addr &&
              this.wr_data === other.wr_data &&
              this.rd_data === other.rd_data);
    endfunction

    function void print(string msg = "");
      $display("[%s] t=%0t wr_en:%b wr_addr:%0d rd_addr:%0d wr_data:%h rd_data:%h",
               msg, $time, wr_en, wr_addr, rd_addr, wr_data, rd_data);
    endfunction

    //I manually post_randomize the msb of data.
    //(SEE THE NOTE BELLOW FOR AN EXPLINATION OF WHY)
    localparam longint unsigned ALL_ZEROS = {LUT_WIDTH{1'b0}};
    localparam longint unsigned ALL_ONES = {LUT_WIDTH{1'b1}};
    function void post_randomize();
      if(!(wr_data inside {ALL_ZEROS, ALL_ONES})) begin
        randcase
          1: wr_data[LUT_WIDTH-1] = 1'b0;
          1: wr_data[LUT_WIDTH-1] = 1'b1;
        endcase
      end
    endfunction

    /************ NOTE *********************/
    //I use the post_rand function to manually randomize the MSB of wr_data as
    //a workaround for a potential bug in the free version of Vivado xsim Im using
    //
    //POTENTIAL XSIM BUG:
    //  When wr_data is 32 bits wide the MSB (so bit 31) is never randomized.
    //  This happens even when wr_data is completely unconstrained.
    //  So Im pretty confident its an issue with the xsim constraint solver.
    //
    //  This only happens when wr_data is exactly 32 bits wide,
    //  so I think the cause is that xsims constraint solver code must be
    //  using signed ints internally to generate random values.
    //  So when I want the whole 32 bit unsigned range, the solver caps out
    //  at 0x7FFFFFFF because thats the max positive signed 32 bit value.
    //
    //  I tried several things to try and get the solver to give me the whole
    //  32 bit unsigned range
    //
    //    - making the boundary localparams int unsigned and longint unsigned
    //
    //    - changing the rand variable from logic to bit
    //
    //    - making the rand variable a longint unsigned (I thought this might
    //      work because everything I give the solver would be 64 bits, so
    //      maybe the solver would use 64 bit signed ints, but even the the 32nd bit
    //      never get set)
    //
    //  None of that worked so Im pretty sure its an xsim bug, unless im missing something.
    //
    //  I think using the post_rand function is probably the cleanest way to
    //  get the MSB to randomize
    /**************************************/
  endclass
endpackage
