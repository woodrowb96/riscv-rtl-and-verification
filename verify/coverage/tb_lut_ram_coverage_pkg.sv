package tb_lut_ram_coverage_pkg;

  class tb_lut_ram_coverage #(parameter int LUT_WIDTH = 32, parameter int LUT_DEPTH = 256);
    virtual lut_ram_intf #(.LUT_WIDTH(LUT_WIDTH), .LUT_DEPTH(LUT_DEPTH)).monitor vif;

    covergroup cg @(posedge vif.clk);

      /************************ WRITTING *********************/
      wr_en: coverpoint vif.wr_en{
        bins write = {1'b1};
        bins no_write = {1'b0};
      }

      //mem[0] and mem[MAX_ADDR] are the interesting corner cases we want to hit
      wr_addr: coverpoint vif.wr_addr {
        bins addr_min =   {0};
        bins addr_max =   {LUT_DEPTH - 1};
        bins non_corner = {[1 : LUT_DEPTH - 2]};
      }

      //we want to write and not write to our corner addresses
      wr_addr_x_wr_en: cross wr_addr, wr_en;

      //ALL_ONES and ALL_ZERO are the interesting corner cases we want to read
      //and write through the _data ports
      wr_data: coverpoint vif.wr_data
        iff(vif.wr_en) {
          bins zeros      = {'0};
          bins all_ones   = {'1};
          bins non_corner = {['0 + 1 : '1 - 1]};
        }


      //write to the same wr_addr in back to back clk cycles
      back_to_back_writes: coverpoint vif.wr_addr
        iff(vif.wr_en) {
          bins hit = ([0:LUT_DEPTH-1][*2]);
        }

      /************************ READING *********************/
      rd_addr: coverpoint vif.rd_addr {
        bins addr_min =   {0};
        bins addr_max =   {LUT_DEPTH - 1};
        bins non_corner = {[1:LUT_DEPTH - 2]};
      }

      rd_data: coverpoint vif.rd_data{
        bins zeros      = {'0};
        bins all_ones   = {'1};
        bins non_corner = {['0 + 1 : '1 - 1]};
      }

      /**************************************************************************/
      //@(posedge clk) rd_addr == wr_addr, and write is enabled.
      //
      //Becasue our reads are combinatorial, and writes are syncronous
      //the rd_data = mem[wr_addr] should read out the old data @mem[wr_addr]
      //not the new wr_data that is in the process of being clked into memory.
      //
      //The functionality that this coverpoint is trying to capture is the
      //fact the combinatorial read path is "independent" of the synchronous
      //write path, in the sense that reads should be asyncronous.
      //
      //rd_addr and rd_data are not effected by changes on wr_addr, wr_data and wr_en
      //(even if wr_en == 1, wr_addr == rd_addr). Those changes wont take
      //effect until AFTER the clock edge.
      /**************************************************************************/
      read_before_write: coverpoint (vif.wr_en && (vif.rd_addr == vif.wr_addr)) {
        bins hit = {1};
      }

      //The data we read out has to have been written in, so this covers
      //reading stuff after it was written
      read_after_write: cross rd_addr, rd_data;
    endgroup

    function new(virtual lut_ram_intf #(.LUT_WIDTH(LUT_WIDTH), .LUT_DEPTH(LUT_DEPTH)).monitor vif);
      this.vif = vif;
      this.cg = new();
    endfunction

    function void start();
      cg.start();
    endfunction

    function void stop();
      cg.stop();
    endfunction
  endclass
endpackage
