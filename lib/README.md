# Verification Library

A custom class-based parallel verification library for SystemVerilog testbenches.

The library provides a set of parameterized virtual base classes that handle the infrastructure for running generator, driver, monitor, and scoreboard as concurrent processes connected by mailboxes. Users extend the base classes with module-specific logic and wire them together in a test class.

## Architecture

```
                  gen_to_drv_mbx              mon_to_scb_mbx
  ┌───────────┐  ──────────────►  ┌────────┐  ┌─────────┐  ──────────────►  ┌────────────┐
  │ Generator │    (mailbox)      │ Driver │  │ Monitor │    (mailbox)      │ Scoreboard │
  └───────────┘                   └────┬───┘  └────┬────┘                   └────────────┘
                                       │           │
                                       ▼           ▼
                                  ┌─────────────────────┐
                                  │     DUT (via intf)   │
                                  └─────────────────────┘

  All processes are launched concurrently by base_test::run() using fork/join_any.
```

## Base Classes

- **base_transaction** - Virtual base class for all transactions.
    - Requires a `print()` function.

- **base_generator #(TRANS_T)** - Generates transactions and sends them to the driver via mailbox.
    - The Generator Class provides:
        - A pure virtual `gen_trans()` function users override to define their stimulus generation logic.
        - A `finished` flag users can set to signal test completion (for tests without a fixed count).
        - A `num_transactions` counter that tracks how many transactions have been generated.
    - Note: `gen_trans()` is currently a function. If a future use case requires
      time-consuming operations it can be converted to a task.

- **base_driver #(TRANS_T)** - Receives transactions from the generator and drives them into the DUT.
    - The Driver Class provides:
        - A pure virtual `drive(input TRANS_T trans)` task users override to define their DUT driving logic.
        - A `drv_started` flag that is automatically set after the first drive. Used by `base_test` to gate the monitor.

- **base_monitor #(TRANS_T)** - Samples the DUT and sends observed transactions to the scoreboard via mailbox.
    - The Monitor Class provides:
        - A pure virtual `monitor(output TRANS_T trans)` task users override to define their DUT sampling logic.
    - Note: `base_monitor::run()` is automatically gated by `base_test` — monitoring
      does not begin until after the first drive has been applied to the DUT.

- **base_scoreboard #(TRANS_T)** - Receives monitored transactions and scores them against expected results.
    - The Scoreboard Class provides:
        - A pure virtual `score(input TRANS_T actual)` function users override to score each test. Return `1` for pass, `0` for fail.
        - `num_tests` and `num_fails` counters.
        - A `print_fail()` utility to print actual vs expected on failure.
        - A `print_results()` utility to print the pass/fail summary.
    - Note: `score()` is currently a function. If a future use case requires
      time-consuming operations it can be converted to a task.

- **base_test #(TRANS_T, GEN_T, DRV_T, MON_T, SCB_T)** - Orchestrates the entire test.
    - The Test Class provides:
        - A `run(int num_tests = -1)` task that launches all processes concurrently and manages test termination.
            - Tests run until:
                - `num_tests` transactions have been generated, OR
                - `gen.finished` is set (for directed/finite tests), OR
                - a configurable timeout is reached
            - After the generator finishes, `run()` waits for the scoreboard to process all remaining transactions before calling `disable fork` to clean up.
        - A `print_results()` function to print the pass/fail summary.
    - Note: In the child test's `new()`:
        1. Call `super.new()` first (this creates the mailboxes).
        2. Construct and assign `gen`, `drv`, `mon`, `scb` (pass mailboxes from super).

A typical user test has the following structure:
```
user_base_test #(GEN_T) : base_test (abstract)
 ├── run()              # launches gen, drv, mon, scb concurrently via fork/join_any
 ├── print_results()    # prints pass/fail summary
 ├── gen : GEN_T        # user's generator (extends base_generator)
 ├── drv : DRV_T        # user's driver (extends base_driver)
 ├── mon : MON_T        # user's monitor (extends base_monitor)
 ├── scb : SCB_T        # user's scoreboard (extends base_scoreboard)
 ├── gen_to_drv_mbx     # mailbox connecting generator → driver
 └── mon_to_scb_mbx     # mailbox connecting monitor → scoreboard

user_default_test : user_base_test #(user_default_gen)
 └── new()              # just calls super.new() with tag
```

## Writing a Test

1. **Extend the base classes** with module-specific logic:
   - Transaction: define your DUT's stimulus fields, constraints, `compare()`, and `print()`
   - Generator: implement `gen_trans()` with your randomization strategy
   - Driver: implement `drive()` using clocking blocks on your interface
   - Monitor: implement `monitor()` using clocking blocks on your interface
   - Scoreboard: implement `score()` using a reference model

2. **Create a base test class** for your module that extends `base_test`, parameterized with your component types. In the constructor, call `super.new()` first (creates mailboxes), then construct and assign `gen`, `drv`, `mon`, `scb`:

```systemverilog
virtual class my_base_test #(type GEN_T) extends base_test #(
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

3. **Create child test classes** by parameterizing the base test with different generators:

```systemverilog
class my_default_test extends my_base_test #(my_default_gen);
  function new(virtual my_intf vif, my_coverage coverage);
    super.new(vif, coverage, "MY_DEFAULT_TEST");
  endfunction
endclass
```

4. **Instantiate and run** in the testbench:

```systemverilog
my_default_test test_default;
test_default = new(intf, coverage);
test_default.run(1000);
test_default.print_results();
```

## Design Decisions

- **Function vs Task**: `gen_trans()` and `score()` are functions, not tasks. This simplifies the interface at the cost of not supporting time-consuming operations. If a future use case requires it, they can be converted to tasks.
- **Monitor gating**: The monitor is automatically held until the driver's first transaction has been applied to the DUT. This prevents the monitor from sampling uninitialized signals without requiring any user-side wiring.
- **Timeout**: A configurable timeout (default 1,000,000 time units) guards against hangs in both the main test loop and the post-test scoreboard drain.
- **Test termination**: The generator controls when the test ends. `base_test::run()` waits for the scoreboard to finish processing all generated transactions before calling `disable fork` to clean up.
