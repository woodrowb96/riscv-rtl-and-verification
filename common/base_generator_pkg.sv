/*
    Virtual base generator class users can use to derive there own generators from.
*/
package base_generator_pkg;
  import base_transaction_pkg::*;

  virtual class base_generator;
    typedef mailbox #(base_transaction) mailbox_t;
    mailbox_t gen_to_drv_mbx;

    int num_transactions = 0;

    pure virtual function base_transaction gen_trans();

    task run();
      base_transaction trans = gen_trans();
      num_transactions++;
      gen_to_drv_mbx.put(trans);
    endtask

    protected function new(mailbox_t gen_to_drv_mbx);
      this.gen_to_drv_mbx = gen_to_drv_mbx;
    endfunction
  endclass

endpackage
