/*
    A base driver class users can use to derive there module specific drivers from.
*/
package base_driver_pkg;

  virtual class base_driver #(parameter type TRANS_T);
    typedef mailbox #(TRANS_T) mailbox_t;
    mailbox_t gen_to_drv_mbx;

    protected function new(mailbox_t gen_to_drv_mbx);
      this.gen_to_drv_mbx = gen_to_drv_mbx;
    endfunction

    pure virtual task drive(input TRANS_T trans);

    task run();
      TRANS_T trans;
      gen_to_drv_mbx.get(trans);
      drive(trans);
    endtask
  endclass

endpackage
