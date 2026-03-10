/*
    Virtual base transaction class providing users can derive there own transaction from.
*/
package base_transaction_pkg;

  virtual class base_transaction;
    static local int next_id = 0;
    int id;

    pure virtual function bit compare(base_transaction other);
    pure virtual function void print(string msg = "");

    protected function new();
      this.id = next_id;
      next_id++;
    endfunction
  endclass



endpackage
