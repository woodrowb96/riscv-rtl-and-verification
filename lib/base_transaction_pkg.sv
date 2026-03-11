/*
    Base transaction class for the verification library.

    Pure Virtual Functions:
      function void print(string msg = "")
*/
package base_transaction_pkg;

  virtual class base_transaction;
    pure virtual function void print(string msg = "");
  endclass

endpackage
