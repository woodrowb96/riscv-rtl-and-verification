interface alu_intf;
  logic [3:0] alu_op;
  logic [31:0] in_a;
  logic [31:0] in_b;
  logic [31:0] result;
  logic zero;

  modport COV(input alu_op, in_a, in_b, result, zero);
  modport ASSERT(input alu_op, in_a, in_b, result, zero);
endinterface
