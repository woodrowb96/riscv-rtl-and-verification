# RISCV RTL and Verification

RTL Design and Verification of a RISC-V RV32I implementation.

Special emphasis has been put on verification.
My goal is to not only design and implement an RV32I Core, but to also fully and professionally verify that implementation.

Each RTL module is being developed alongside a full coverage-driven verification environment consisting of:
- Functional coverage
- Constrained random stimulus
- Behavioral reference models
- SVA assertions

Note: I am actively developing this project.

## Project Structure

```
├── rtl/
│   ├── package/        # Type definitions, config, control enumerations
│   ├── alu.sv          # Arithmetic logic unit
│   ├── reg_file.sv     # 32x32 register file
│   ├── lut_ram.sv      # Generic parameterized LUT-RAM
│   ├── data_mem.sv     # Byte-addressable data memory
│   ├── inst_mem.sv     # Read-only instruction memory (ROM)
│   └── imm_gen.sv      # Immediate generation unit
│
├── lib/
│   ├── base_transaction_pkg.sv  # Virtual base transaction class
│   ├── base_generator_pkg.sv   # Virtual base generator class
│   ├── base_driver_pkg.sv      # Virtual base driver class
│   ├── base_monitor_pkg.sv     # Virtual base monitor class
│   ├── base_scoreboard_pkg.sv  # Virtual base scoreboard class
│   └── base_test_pkg.sv        # Virtual base test class (orchestrates fork/join)
│
├── verify/
│   ├── tb/             # Top-level testbenches
│   ├── tests/          # Test classes (wire up components, configure test scenarios)
│   ├── transaction/    # Transaction classes (randomizable stimulus)
│   ├── generator/      # Constrained random and directed corner-walk generators
│   ├── driver/         # Drive transactions into the DUT through the interface
│   ├── monitor/        # Capture DUT output through the interface
│   ├── scoreboard/     # Score DUT output against reference models
│   ├── ref_model/      # Behavioral reference models (SV and C++ via DPI-C)
│   ├── coverage/       # Functional coverage
│   ├── assert/         # SVA assertion modules (bound into RTL)
│   ├── interface/      # SystemVerilog interfaces with clocking blocks
│   ├── package/        # Verification constants and utility functions
│   └── programs/       # Hex program files loaded into instruction memory
│
├── scripts/
│   ├── xsim/
│   │   ├── filelist/   # Compilation dependencies
│   │   └── *.tcl       # Waveform and simulation TCL scripts
│   └── gen/            # Python scripts for test data generation
│
├── xsim_comp.sh        # Compile script (Xilinx xvlog)
└── xsim_sim.sh         # Simulate script (Xilinx xsim)
```

## RTL Modules
I've currently implemented and verified the following modules:
- ALU
- Register File
- LUT RAM
- Data Memory
- Instruction Memory
- Immediate Generator

## Verification

Each RTL module is paired with an accompanying coverage-driven verification environment,
consisting of:
- a Testbench
- a Functional Coverage Model
- SVA assertions

### Testbench Architecture

Testbenches use a parallel architecture built on `fork/join_any`, mailboxes, and clocking blocks.

Generator, driver, monitor, and scoreboard run as concurrent processes connected by mailboxes,
coordinated through a reusable base class library (`lib/`).

- **Base Class Library** — Parameterized virtual base classes (`base_generator`, `base_driver`, `base_monitor`, `base_scoreboard`, `base_test`) that provide the parallel orchestration. Module-specific verification components extend these base classes.
- **Transactions** — Randomizable stimulus/response pairs extending `base_transaction`
- **Generator** — Generates transactions using constrained random or directed corner-walk strategies. Multiple generator types per DUT target different coverage goals.
- **Driver** — Drives transactions into the DUT through clocking blocks on the interface
- **Monitor** — Captures DUT output through clocking blocks, synchronized to the driver via events
- **Scoreboard** — Scores DUT output against the reference model, tracks pass/fail, and samples functional coverage on pass
- **Tests** — Wire up components and configure test scenarios. A parameterized base test class allows new tests to be created by simply swapping in a different generator.
- **Reference Models** — Behavioral reference models used to score tests. Either written in SystemVerilog or written in C++ and integrated into the testing environment via DPI-C.

### Functional Coverage

Each module is accompanied by a functional coverage model.
Coverage is defined inside SystemVerilog covergroups using coverpoints and crosses.

A large part of the verification process for each module consists of going back and forth
between the coverage model and generator, looking at the coverage model and rewriting constraints,
until the testbench is hitting 100% coverage.

### SVA Assertions

Each RTL module is paired with an assertion module that is bound directly into the RTL.

Once bound, assertions run alongside the RTL during simulation, providing a passive secondary check
of individual functionality within the RTL itself.

Assertions can be used hierarchically just like the RTL — child module assertions can be bound inside parent
assertion modules. For example, my data_mem assertions include the assertions for lut_ram inside them.

### Reference Models

Each module has a behavioral reference model used by the scoreboard to verify the DUT's output.

Reference models are written either in SystemVerilog or C++.

C++ reference models are integrated into the rest of the verification environment through
DPI-C.

Reference model implementations are intentionally kept as independent as possible from the RTL,
either by using a different implementation than the RTL or by writing
the reference model in a completely different language like C++. Maximizing the
difference between RTL and reference model implementations helps ensure that we are not
just duplicating the same bugs in both. Ideally a completely different person would write
the verification for each module than the one who wrote the RTL, but obviously that's not
possible with a personal project.

### Scripts

- `scripts/gen/gen_rand_inst_mem.py`
    - Generates randomized instruction memory contents with weighted corner-case values for use in constrained random testing.
- `xsim_comp.sh`
    - Compiles a SystemVerilog file and its filelist dependencies using Xilinx xvlog.
    - Automatically compiles any C++ DPI-C files found in the filelist using xsc.
- `xsim_sim.sh`
    - Compiles, elaborates, and simulates a testbench using Xilinx xvlog, xelab and xsim.
    - Automatically compiles and links C++ DPI-C files found in the filelist using xsc.
    - By default, the script looks for a TCL script named `<testbench>.tcl` to run the sim, but a custom TCL script can be specified with `-t`.
    - Supports CLI and GUI (`-g`) modes.


## How to Compile and Run Simulations

Prerequisites
    - Xilinx Vivado (xvlog, xelab, xsim, xsc must be on PATH)

```bash
# Compile a testbench and its dependencies
./xsim_comp.sh verify/tb/tb_data_mem.sv

# Run simulation (CLI mode)
./xsim_sim.sh verify/tb/tb_data_mem.sv

# Run simulation with GUI waveform viewer
./xsim_sim.sh -g verify/tb/tb_data_mem.sv

```

## Next Steps

- Short Term:
    - Convert remaining module testbenches to the parallel architecture.
    - Continue implementing and verifying RTL modules towards a single-cycle RV32I Core.

- Long Term:
    - Implement 5-stage pipelining with forwarding, hazard detection and branch prediction.
    - Implement memory hierarchy with an L1 cache.
    - Build UVM versions of each module's verification.
    - Get a version of the core running on an FPGA.

I am actively developing the project.

