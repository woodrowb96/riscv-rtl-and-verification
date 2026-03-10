/*
    Virtual base transaction class providing users can derive there own transaction from.
*/
package base_transaction_pkg;

  virtual class base_transaction;

    pure virtual function bit compare(base_transaction other);
    pure virtual function void print(string msg = "");

  endclass

endpackage
