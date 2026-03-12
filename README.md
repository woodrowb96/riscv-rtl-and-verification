# RISCV RTL and Verification

RTL Design and Verification of a RISC-V RV32I implementation.

A special emphasis has been put on verification.
My goal is to not only design and implement an RV32I Core, but to also fully and professionally verify that implementation.

Each RTL module is being developed alongside a full coverage-driven verification environment consisting of:
- Functional coverage
- Constrained random stimulus
- Behavioral reference models (SystemVerilog and C++ via DPI-C)
- SVA assertions
- Class based parallel testing environments (built using a custom verification library)

To aid in verification I have also developed a custom class-based parallel verification library (located in `lib/`) that provides a reusable base infrastructure for writing generator, driver, monitor, and scoreboards that run as concurrent processes, bundled together in user-written directed/constrained-random tests.


Note: I am actively developing this project.

Note: See [lib/README.md](lib/) for details on the custom verification library.

## Project Structure

```
├── rtl/
│   ├── package/        # Typedefs, config, control enumerations
│   ├── alu.sv          # Arithmetic logic unit
│   ├── reg_file.sv     # 32x32 register file
│   ├── lut_ram.sv      # Generic parameterized LUT-RAM
│   ├── data_mem.sv     # Byte-addressable data memory
│   ├── inst_mem.sv     # Read-only instruction memory (ROM)
│   └── imm_gen.sv      # Immediate generation unit
│
├── lib/                # Class-based parallel verification library
│
├── verify/
│   ├── tb/             # Top-level testbenches
│   ├── tests/          # Directed/Constrained-Random tests
│   ├── transaction/    # Transaction classes (randomizable stimulus)
│   ├── generator/      # Directed/Constrained-Random generators
│   ├── driver/         # Drivers
│   ├── monitor/        # Monitors
│   ├── scoreboard/     # Test scoring
│   ├── ref_model/      # Behavioral reference models (SV and C++ via DPI-C)
│   ├── coverage/       # Functional coverage
│   ├── assert/         # SVA assertion modules (bound into RTL)
│   ├── interface/      # Interfaces with clocking blocks
│   ├── package/        # Verification constants and utility functions
│   └── programs/       # Hex memory files used in testing
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
I've currently implemented and verified the following modules with 100% coverage:
- ALU
- Register File
- LUT RAM
- Data Memory
- Instruction Memory
- Immediate Generator

## Verification

Each RTL module is paired with an accompanying coverage-driven verification environment,
consisting of:
- Functional Coverage Models
- Behavioral Reference Models (SystemVerilog and C++ via DPI-C)
- SVA assertions
- Tests (directed or constrained-random) targeting different coverage elements
- Testbenches to run and coordinate tests

### Testbenches

Testbenches instantiate and connect the DUTs, interfaces, coverages, assertions and tests.

### Tests

Tests are class-based parallel verification environments bundling a generator, driver, monitor, and scoreboard
which together implement a single directed or constrained-random test.

Test components:
- **Generator** — Generates a sequence of transactions which implement a constrained-random or directed test.
- **Driver** — Drives generated transactions into the DUT (typically done through interface clocking blocks)
- **Monitor** — Monitors the DUT I/O ports to sample a single transaction (once again typically through interface clocking blocks)
- **Scoreboard** — Score monitored transactions against a reference model, track total pass/fails, adds passing transactions to functional coverage

Each testbench contains one or more tests, each targeting a different part of coverage.

Tests are implemented using the custom verification library (see [lib/README.md](lib/) for details).

### Functional Coverage

Each module is accompanied by a functional coverage model defining the functions
each module must exercise at some point during testing to be considered verified.

Coverage is written using SystemVerilog coverpoints and crosses which describe corner-values/scenarios
and key operational interactions (transitions, boundary computations, overflows, read-after-writes ...)

A large part of the verification process for each module consists of going back and forth
between the coverage model and generator, looking at the coverage model and rewriting constraints,
until the testbench is hitting 100% coverage. If needed a separate directed test may be required
to hit a certain coverage criterion.

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

Reference model implementations are intentionally kept as independent as possible from the RTL, either
by using a different implementation than the RTL or by writing
the reference model in a completely different language. 

Maximizing the difference between RTL and reference model implementations helps ensure that we are not
just duplicating the same bugs in both. Ideally a completely different person would write
the verification for each module than the one who wrote the RTL, but obviously that's not
possible with a personal project.

## Scripts

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
    - Continue implementing and verifying RTL modules towards a single-cycle RV32I Core.

- Long Term:
    - Implement 5-stage pipelining with forwarding, hazard detection and branch prediction.
    - Implement memory hierarchy with an L1 cache.
    - Build UVM versions of each module's verification.
    - Get a version of the core running on an FPGA.

I am actively developing the project.

## Example Verification Results

Below are example results from the ALU verification environment.

### Test Output

<img width="400" alt="alu_test_output" src="https://github.com/user-attachments/assets/de2a3af2-4959-4123-abd8-41d84298c638" />

### Functional Coverage Report

<img width="400" alt="coverage" src="https://github.com/user-attachments/assets/a8bbe944-8b40-4de4-8706-f27f423fdb4d" />


