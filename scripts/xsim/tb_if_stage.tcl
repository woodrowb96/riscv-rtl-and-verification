add_wave tb_if_stage/dut/clk
add_wave tb_if_stage/dut/reset_n
add_wave_divider
add_wave tb_if_stage/dut/branch
add_wave tb_if_stage/dut/branch_target
add_wave_divider
add_wave tb_if_stage/dut/pc
add_wave tb_if_stage/dut/inst

run all

write_xsim_coverage
export_xsim_coverage -output_dir ./coverage_reports/tb_if_stage
