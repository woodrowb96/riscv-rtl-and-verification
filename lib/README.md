# Class Based Parallel Verification Library

A custom verification library for writing class-based parallel SystemVerilog testbenches.

This library provides users a set of reusable base classes they can use to implement
their transactions, generators, drivers, monitors, scoreboards and tests.

## Architecture

<img width="1768" height="772" alt="diagram" src="https://github.com/user-attachments/assets/3e51f2a6-ee10-47ff-819a-a61489cbdc1b" />

## Base Classes

| Class | Role |
|-------|------|
| `base_transaction` | Virtual base class for all transactions |
| `base_generator #(TRANS_T)` | Generates transactions and sends them to the driver via mailbox |
| `base_driver #(TRANS_T)` | Receives transactions from the generator and drives them into the DUT |
| `base_monitor #(TRANS_T)` | Samples the DUT and sends observed transactions to the scoreboard via mailbox |
| `base_scoreboard #(TRANS_T)` | Receives monitored transactions and scores them against expected results |
| `base_test #(TRANS_T, GEN_T, DRV_T, MON_T, SCB_T)` | Orchestrates the entire test |

### base_transaction

Virtual base class for all transactions.

- Requires a `print()` function.

### base_generator #(TRANS_T)

Generates transactions and sends them to the driver via mailbox.

- **Override**: `gen_trans()` — pure virtual function where users define their stimulus generation logic.
- **Provides**: `finished` flag to signal test completion (for tests without a fixed count).
- **Provides**: `num_transactions` counter tracking how many transactions have been generated.

### base_driver #(TRANS_T)

Receives transactions from the generator and drives them into the DUT.

- **Override**: `drive(input TRANS_T trans)` — pure virtual task where users define their DUT driving logic.
- **Provides**: `drv_started` flag, automatically set after the first drive. Used by `base_test` to gate the monitor.

### base_monitor #(TRANS_T)

Samples the DUT and sends observed transactions to the scoreboard via mailbox.

- **Override**: `monitor(output TRANS_T trans)` — pure virtual task where users define their DUT sampling logic.
- Monitoring is automatically gated by `base_test` — it does not begin until after the first drive has been applied to the DUT.

### base_scoreboard #(TRANS_T)

Receives monitored transactions and scores them against expected results.

- **Override**: `score(input TRANS_T actual)` — pure virtual function where users score each transaction. Return `1` for pass, `0` for fail.
- **Provides**: `num_tests` and `num_fails` counters.
- **Provides**: `print_fail()` utility to print actual vs expected on failure.
- **Provides**: `print_results()` utility to print the pass/fail summary.

### base_test #(TRANS_T, GEN_T, DRV_T, MON_T, SCB_T)

Orchestrates the entire test by launching all components concurrently and managing test termination.

- **Provides**: `run(int num_tests = -1)` — launches all processes via `fork/join_any`.
    - Tests run until `num_tests` transactions have been generated, `gen.finished` is set, or a configurable timeout is reached.
    - After the generator finishes, `run()` waits for the scoreboard to process all remaining transactions before calling `disable fork`.
- **Provides**: `print_results()` to print the pass/fail summary.
- **Contract**: In the child test's `new()`, call `super.new()` first (creates the mailboxes), then construct and assign `gen`, `drv`, `mon`, `scb`.

### Typical Test Structure

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

## Usage

### 1. Extend the base classes with module-specific logic

- **Transaction**: define stimulus fields, constraints, `compare()`, and `print()`
- **Generator**: implement `gen_trans()` with your randomization strategy
- **Driver**: implement `drive()` using clocking blocks on your interface
- **Monitor**: implement `monitor()` using clocking blocks on your interface
- **Scoreboard**: implement `score()` using a reference model

### 2. Create a base test class for your module

Extend `base_test` parameterized with your component types. Call `super.new()` first (creates mailboxes), then construct and assign `gen`, `drv`, `mon`, `scb`:

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

### 3. Create child test classes

Parameterize the base test with different generators to target different coverage:

```systemverilog
class my_default_test extends my_base_test #(my_default_gen);
  function new(virtual my_intf vif, my_coverage coverage);
    super.new(vif, coverage, "MY_DEFAULT_TEST");
  endfunction
endclass
```

### 4. Instantiate and run in the testbench

```systemverilog
my_default_test test_default;
test_default = new(intf, coverage);
test_default.run(1000);
test_default.print_results();
```

## Design Decisions

- **Function vs Task**: `gen_trans()` and `score()` are functions, not tasks. This keeps the interface simple. If a future use case requires time-consuming operations, they can be converted to tasks.
- **Monitor gating**: The monitor is automatically held until the driver's first transaction has been applied. This prevents sampling uninitialized signals without requiring any user-side wiring.
- **Timeout**: A configurable timeout (default 1,000,000 time units) guards against hangs in both the main test loop and the post-test scoreboard drain.
- **Test termination**: The generator controls when the test ends. `base_test::run()` waits for the scoreboard to finish processing before calling `disable fork` to clean up.
