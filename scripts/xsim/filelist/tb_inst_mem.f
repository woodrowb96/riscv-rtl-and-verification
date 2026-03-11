#LIB
lib/base_transaction_pkg.sv
lib/base_generator_pkg.sv
lib/base_driver_pkg.sv
lib/base_monitor_pkg.sv
lib/base_scoreboard_pkg.sv
lib/base_test_pkg.sv

# RTL
rtl/package/rv32i_defs_pkg.sv
rtl/package/rv32i_config_pkg.sv
rtl/inst_mem.sv

#VERIFICATION
verify/package/verify_const_pkg.sv
verify/package/verify_config_pkg.sv
verify/interface/inst_mem_intf.sv
verify/assert/inst_mem_assert.sv
verify/transaction/tb_inst_mem_transaction_pkg.sv
verify/ref_model/inst_mem_ref_model_pkg.sv
verify/coverage/tb_inst_mem_coverage_pkg.sv
verify/generator/tb_inst_mem_generator_pkg.sv
verify/driver/tb_inst_mem_driver_pkg.sv
verify/monitor/tb_inst_mem_monitor_pkg.sv
verify/scoreboard/tb_inst_mem_scoreboard_pkg.sv
verify/tests/tb_inst_mem_tests_pkg.sv
