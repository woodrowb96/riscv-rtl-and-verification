package inst_mem_ref_model_pkg;
  import rv32i_defs_pkg::*;
  import rv32i_config_pkg::*;

  class inst_mem_ref_model;

    //Use an associative array to model the inst_memories rom.
    //We will read the instructions in from the mem file during new()
    word_t ref_inst_rom [int unsigned];

    function new(string program_file = "NO_INST_MEM_PROGRAM_SPECIFIED");
      //we need to read the mem, from the file and fill the reference memory manualy
      string line;
      int index = 0;
      word_t data;

      //open the program_file
      int fd = $fopen(program_file, "r");
      if(!fd) begin
        $fatal(1, "[INST_MEM_REF_MODEL]: Failed to open %s", program_file);
      end

      //loop and fill the reference inst rom
      while($fgets(line, fd) != 0) begin
        if($sscanf(line, "%h", data) == 1) begin
          ref_inst_rom[index] = data;
          index++;
        end
      end

      //close the file
      $fclose(fd);
    endfunction

    function automatic word_t read(word_t inst_addr);
      //get rid of the byte offset
      int unsigned ref_inst_addr = inst_addr >> 2;

      //manually wrap out of bounds addresses
      if(ref_inst_addr >= INST_MEM_DEPTH) begin
        $warning("[INST_MEM_REF_MODEL]: out of bound read: depth:%0d, inst_addr:%0d",
                    INST_MEM_DEPTH, inst_addr);
        ref_inst_addr = ref_inst_addr % INST_MEM_DEPTH;
      end

      //read out the ref_instruction
      return ref_inst_rom[ref_inst_addr];
    endfunction

  endclass

endpackage
