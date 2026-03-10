/*
    Virtual base generator class users can use to derive there own generators from.
*/
package base_generator_pkg;

  virtual class base_generator #(parameter type TRANS_T);
    typedef mailbox #(TRANS_T) mailbox_t;
    mailbox_t gen_to_drv_mbx;

    int num_transactions = 0;

    pure virtual function TRANS_T gen_trans();

    task run();
      TRANS_T trans = gen_trans();
      num_transactions++;
      gen_to_drv_mbx.put(trans);
    endtask

    protected function new(mailbox_t gen_to_drv_mbx);
      this.gen_to_drv_mbx = gen_to_drv_mbx;
    endfunction
  endclass

endpackage
