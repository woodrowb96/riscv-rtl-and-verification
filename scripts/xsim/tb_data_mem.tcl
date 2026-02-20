add_wave tb_data_mem/clk
add_wave_divider
add_wave -radix bin tb_data_mem/intf/wr_sel
add_wave_divider
add_wave -radix hex tb_data_mem/intf/addr
add_wave -radix hex tb_data_mem/intf/wr_data
add_wave -radix hex tb_data_mem/intf/rd_data
add_wave_divider
add_wave -radix hex tb_data_mem/dut/byte_0_addr
add_wave -radix hex tb_data_mem/dut/byte_1_addr
add_wave -radix hex tb_data_mem/dut/byte_2_addr
add_wave -radix hex tb_data_mem/dut/byte_3_addr
add_wave_divider
add_wave -radix bin tb_data_mem/dut/lut_ram_wr_en
add_wave_divider
add_wave -radix hex tb_data_mem/dut/byte_0_rd
add_wave -radix hex tb_data_mem/dut/byte_1_rd
add_wave -radix hex tb_data_mem/dut/byte_2_rd
add_wave -radix hex tb_data_mem/dut/byte_3_rd
add_wave_divider
add_wave -radix hex tb_data_mem/dut/byte_0_wr
add_wave -radix hex tb_data_mem/dut/byte_1_wr
add_wave -radix hex tb_data_mem/dut/byte_2_wr
add_wave -radix hex tb_data_mem/dut/byte_3_wr
add_wave_divider
add_wave -radix hex tb_data_mem/dut/byte_0/mem
add_wave -radix hex tb_data_mem/dut/byte_1/mem
add_wave -radix hex tb_data_mem/dut/byte_2/mem
add_wave -radix hex tb_data_mem/dut/byte_3/mem
add_wave_divider

run all

# write_xsim_coverage
# export_xsim_coverage -output_dir ./coverage_reports/tb_data_mem
