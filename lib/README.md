# Class Based Parallel Verification Library

A custom verification library for writing class-based parallel SystemVerilog testbenches.

This library provides a set of reusable base classes users can use to implement
transactions, generators, drivers, monitors, scoreboards and tests.

Each test component runs as a parallel process, forked concurrently during the test.
Each component executes its own loop, which users can interface into and customize through a set of
pure virtual functions provided in each component's base class.


## Architecture

<img width="1768" height="772" alt="diagram" src="https://github.com/user-attachments/assets/3e51f2a6-ee10-47ff-819a-a61489cbdc1b" />

## Classes

Users are provided the following virtual base classes to implement their tests:

- **base_test:**
    - Orchestrates parallel testing.
    - Provides users the `base_test::run(int num_tests)` function which is used to start testing.
    - Users can interface into the `run()` function through a set of pure virtual functions
        they can use to implement their tests.
- **base_transaction:** 
    - Collection of DUT signals sent between components.
- **base_generator:**
    - Generates a sequence of transactions and sends them to the driver.
    - Users are provided the pure virtual `base_generator::gen_trans()` function which
        they can use to write sequence generation logic for their tests.
- **base_driver:**
    - Drives transactions into the DUT.
    - Users are provided the pure virtual `base_driver::drive()` function which
        they can use to implement DUT specific driving logic.
- **base_monitor:**
    - Samples DUT inputs and outputs to construct a single transaction snapshot sent to the scoreboard.
    - Users are provided the pure virtual `base_monitor::monitor()` function which
        they can use to implement DUT specific monitoring logic.
- **base_scoreboard:**
    - Scores each transaction for correctness.
    - Users are provided the pure virtual `base_scoreboard::score()` function which
        they can use to implement test specific scoring.

See the source files for full API implementation details.

## Typical User Test Implementation

A typical user test will have the following structure.

### Defining Test Components

**Transaction**

```systemverilog
class my_trans extends base_transaction;
  rand logic [31:0] in_a;
  rand logic [31:0] in_b;
  logic [31:0] result;

  // constraints ...

  function bit compare(my_trans other);
    return (this.result === other.result);
  endfunction

  function void print(string msg = "");
    $display("[%s] in_a:%0h in_b:%0h result:%0h", msg, in_a, in_b, result);
  endfunction
endclass
```

**Generators** — Users will typically write multiple generators, each generating a separate sequence.

```systemverilog
class my_gen_1 extends base_generator #(my_trans);
  // ...
  function my_trans gen_trans();
    my_trans trans = new();
    assert(trans.randomize()) else
      $fatal(1, "[%s]: randomization failed", tag);
    return trans;
  endfunction
endclass

class my_gen_2 extends base_generator #(my_trans);
  // ...
  function my_trans gen_trans();
    my_trans trans = new();
    assert(trans.randomize() with {
        in_a inside {32'h0000_0000, 32'hFFFF_FFFF};
        in_b inside {32'h0000_0000, 32'hFFFF_FFFF};
    }) else
      $fatal(1, "[%s]: randomization failed", tag);
    return trans;
  endfunction
endclass
```

**Driver**

```systemverilog
class my_driver extends base_driver #(my_trans);
  // ...
  task drive(input my_trans trans);
    @(vif.cb_drv);
    vif.cb_drv.in_a <= trans.in_a;
    vif.cb_drv.in_b <= trans.in_b;
  endtask
endclass
```

**Monitor**

```systemverilog
class my_monitor extends base_monitor #(my_trans);
  // ...
  task monitor(output my_trans trans);
    @(vif.cb_mon);
    trans = new();
    trans.in_a   = vif.cb_mon.in_a;
    trans.in_b   = vif.cb_mon.in_b;
    trans.result = vif.cb_mon.result;
  endtask
endclass
```

**Scoreboard**

```systemverilog
class my_scoreboard extends base_scoreboard #(my_trans);
  // ...
  function bit score(input my_trans actual);
    my_trans expected = new();
    expected.result = ref_model(actual.in_a, actual.in_b);

    if (!actual.compare(expected)) begin
      print_fail(actual, expected);
      return 0;
    end
    return 1;
  endfunction
endclass
```

### Defining Tests

**parent_test** Users will typically define a parent_test that connects everything except the test specific generator:

```systemverilog
virtual class my_parent_test #(type GEN_T) extends base_test #(
    my_trans, GEN_T, my_driver, my_monitor, my_scoreboard);

  protected function new(virtual my_intf vif, my_coverage coverage, string tag);
    super.new(tag);
    gen = new(gen_to_drv_mbx);
    drv = new(vif, "MY_DRV", gen_to_drv_mbx);
    mon = new(vif, "MY_MON", mon_to_scb_mbx);
    scb = new(coverage, "MY_SCB", mon_to_scb_mbx);
  endfunction
endclass
```


**tests** Users can then implement individual tests by extending the parent_test and hooking up a generator.

```systemverilog
class my_test_1 extends my_parent_test #(my_gen_1);
  function new(virtual my_intf vif, my_coverage coverage);
    super.new(vif, coverage, "MY_TEST_1");
  endfunction
endclass

class my_test_2 extends my_parent_test #(my_gen_2);
  function new(virtual my_intf vif, my_coverage coverage);
    super.new(vif, coverage, "MY_TEST_2");
  endfunction
endclass
```

### Running Tests

Tests are instantiated and run from the testbench:

```systemverilog
my_test_1 test_1;
my_test_2 test_2;

test_1 = new(intf, coverage);
test_1.run(1000);
test_1.print_results();

test_2 = new(intf, coverage);
test_2.run(1000);
test_2.print_results();
```
