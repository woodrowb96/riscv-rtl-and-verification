add_wave tb_lut_ram/clk
add_wave_divider
add_wave tb_lut_ram/wr_en
add_wave_divider
add_wave -radix unsigned tb_lut_ram/wr_addr
add_wave -radix hex tb_lut_ram/wr_data
add_wave_divider
add_wave -radix unsigned tb_lut_ram/rd_addr
add_wave -radix hex tb_lut_ram/rd_data
add_wave_divider
add_wave -radix hex tb_lut_ram/dut/ram

run all

# write_xsim_coverage
# export_xsim_coverage -output_dir ./coverage_reports/tb_lut_ram
