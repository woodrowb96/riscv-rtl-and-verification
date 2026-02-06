interface alu_intf;
  logic [3:0] alu_op;
  logic [31:0] in_a;
  logic [31:0] in_b;
  logic [31:0] result;
  logic zero;

  modport coverage(input alu_op, in_a, in_b, result, zero);
  modport assertion(input alu_op, in_a, in_b, result, zero);

  task print(string msg = "");
    $display("-----------------------");
    $display("ALU INTERFACE:%s\n",msg);
    $display("time: %t", $time);
    $display("-----------------------");
    $display("alu_op: %b", alu_op);
    $display("-----------------------");
    $display("in_a: %h", in_a);
    $display("in_b: %h", in_b);
    $display("-----------------------");
    $display("result: %h", result);
    $display("zero: %b", zero);
    $display("-----------------------");
  endtask
endinterface
