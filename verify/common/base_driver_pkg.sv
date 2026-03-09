/*
    A base driver class users can use to derive there module specific drivers from.
*/
package base_drive_pkg;
  import base_transaction_pkg::*;

  virtual class base_drive;
    typedef mailbox #(base_transaction) mailbox_t;
    mailbox_t drv_mbx_in;

    pure virtual function void drive(base_transaction trans);

    function void run();
      base_transaction trans;
      drv_mbx_in.get(trans);
      drive(trans);
    endfunction;

    function new(mailbox_t drv_mbx_in);
      this.drv_mbx_in = drv_mbx_in;
    endfunction;
  endclass

endpackage
