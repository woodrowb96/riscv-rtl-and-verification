#LIB
lib/base_transaction_pkg.sv
lib/base_generator_pkg.sv
lib/base_driver_pkg.sv
lib/base_monitor_pkg.sv
lib/base_scoreboard_pkg.sv
lib/base_test_pkg.sv

#RTL
rtl/package/rv32i_defs_pkg.sv
rtl/lut_ram.sv

#Verification
verify/interface/lut_ram_intf.sv
verify/assert/lut_ram_assert.sv
verify/transaction/tb_lut_ram_transaction_pkg.sv
verify/coverage/tb_lut_ram_coverage_pkg.sv
verify/generator/tb_lut_ram_generator_pkg.sv
verify/ref_model/lut_ram_ref_model_pkg.sv
verify/driver/tb_lut_ram_driver_pkg.sv
verify/monitor/tb_lut_ram_monitor_pkg.sv
verify/scoreboard/tb_lut_ram_scoreboard_pkg.sv
verify/tests/tb_lut_ram_tests_pkg.sv
