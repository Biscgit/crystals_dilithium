onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_tb_keccak/TEST_BENCH/CLOCK_100
add wave -noupdate /tb_tb_keccak/TEST_BENCH/keccak_cmd_wr_data
add wave -noupdate /tb_tb_keccak/TEST_BENCH/keccak_cmd_wr
add wave -noupdate /tb_tb_keccak/TEST_BENCH/keccak_cmd_co
add wave -noupdate /tb_tb_keccak/TEST_BENCH/keccak_in_wr
add wave -noupdate /tb_tb_keccak/TEST_BENCH/keccak_in_co
add wave -noupdate /tb_tb_keccak/TEST_BENCH/keccak_in_wr_data
add wave -noupdate /tb_tb_keccak/TEST_BENCH/cryptocore_reset
add wave -noupdate /tb_tb_keccak/TEST_BENCH/tb_buffer_full
add wave -noupdate /tb_tb_keccak/TEST_BENCH/tb_core_ready
add wave -noupdate /tb_tb_keccak/TEST_BENCH/KECCAK_CORE/rc_sel
add wave -noupdate /tb_tb_keccak/TEST_BENCH/keccak_start
add wave -noupdate /tb_tb_keccak/TEST_BENCH/keccak_din_valid
add wave -noupdate /tb_tb_keccak/TEST_BENCH/keccak_din_last_block
add wave -noupdate /tb_tb_keccak/TEST_BENCH/keccak_out_buffer_rst
add wave -noupdate /tb_tb_keccak/TEST_BENCH/cryptocore_resetn
add wave -noupdate /tb_tb_keccak/TEST_BENCH/keccak_in_reg
add wave -noupdate /tb_tb_keccak/TEST_BENCH/keccak_cmd_reg
add wave -noupdate /tb_tb_keccak/TEST_BENCH/keccak_core_ready
add wave -noupdate /tb_tb_keccak/TEST_BENCH/keccak_buffer_full
add wave -noupdate /tb_tb_keccak/TEST_BENCH/keccak_upper_rd_data
add wave -noupdate -divider Keccak_Core
add wave -noupdate /tb_tb_keccak/TEST_BENCH/KECCAK_CORE/clk
add wave -noupdate /tb_tb_keccak/TEST_BENCH/KECCAK_CORE/rst_n
add wave -noupdate /tb_tb_keccak/TEST_BENCH/KECCAK_CORE/start
add wave -noupdate /tb_tb_keccak/TEST_BENCH/KECCAK_CORE/din
add wave -noupdate /tb_tb_keccak/TEST_BENCH/KECCAK_CORE/din_valid
add wave -noupdate /tb_tb_keccak/TEST_BENCH/KECCAK_CORE/buffer_full
add wave -noupdate /tb_tb_keccak/TEST_BENCH/KECCAK_CORE/last_block
add wave -noupdate /tb_tb_keccak/TEST_BENCH/KECCAK_CORE/ready
add wave -noupdate /tb_tb_keccak/TEST_BENCH/KECCAK_CORE/dout
add wave -noupdate /tb_tb_keccak/TEST_BENCH/KECCAK_CORE/dout_valid
add wave -noupdate /tb_tb_keccak/TEST_BENCH/KECCAK_CORE/reg_data
add wave -noupdate /tb_tb_keccak/TEST_BENCH/KECCAK_CORE/round_in
add wave -noupdate /tb_tb_keccak/TEST_BENCH/KECCAK_CORE/round_out
add wave -noupdate /tb_tb_keccak/TEST_BENCH/KECCAK_CORE/reg_data_vector
add wave -noupdate /tb_tb_keccak/TEST_BENCH/KECCAK_CORE/counter_nr_rounds
add wave -noupdate /tb_tb_keccak/TEST_BENCH/KECCAK_CORE/din_buffer_full
add wave -noupdate /tb_tb_keccak/TEST_BENCH/KECCAK_CORE/round_constant_signal
add wave -noupdate /tb_tb_keccak/TEST_BENCH/KECCAK_CORE/din_buffer_out
add wave -noupdate /tb_tb_keccak/TEST_BENCH/KECCAK_CORE/permutation_computed
add wave -noupdate -divider FSM
add wave -noupdate /tb_tb_keccak/TEST_BENCH/keccak_ready_irq
add wave -noupdate /tb_tb_keccak/TEST_BENCH/keccak_current_state
add wave -noupdate /tb_tb_keccak/TEST_BENCH/keccak_next_state
add wave -noupdate /tb_tb_keccak/TEST_BENCH/keccak_buffer_irq
add wave -noupdate -divider OUT_FIFO
add wave -noupdate /tb_tb_keccak/TEST_BENCH/keccak_out_fifo_rd_data
add wave -noupdate /tb_tb_keccak/TEST_BENCH/keccak_out_fifo_rdreq
add wave -noupdate /tb_tb_keccak/TEST_BENCH/keccak_out_fifo_rd
add wave -noupdate /tb_tb_keccak/TEST_BENCH/keccak_out_fifo_co
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3825 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 318
configure wave -valuecolwidth 337
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {3052 ns} {4571 ns}
