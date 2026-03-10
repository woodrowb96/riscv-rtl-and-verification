/*
    A base driver class users can use to derive there module specific drivers from.
*/
package base_driver_pkg;
  import base_transaction_pkg::*;

  virtual class base_driver;
    typedef mailbox #(base_transaction) mailbox_t;
    mailbox_t gen_to_drv_mbx;

    protected function new(mailbox_t gen_to_drv_mbx);
      this.gen_to_drv_mbx = gen_to_drv_mbx;
    endfunction

    pure virtual task drive(input base_transaction trans);

    task run();
      base_transaction trans;
      gen_to_drv_mbx.get(trans);
      drive(trans);
    endtask
  endclass

endpackage
