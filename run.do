# =========================================================
# clean
# =========================================================
quit -sim
vdel -all -lib work
vlib work
vmap work work

# =========================================================
# compile (order matters!)
# =========================================================
vcom src/globals.vhdl
vcom src/countdown_clock.vhd
vcom src/decompose.vhdl
vcom src/power2round.vhdl
vcom src/zeta_lut.vhdl

vcom src/ntt/ntt_butterfly.vhdl
vcom src/ntt/sdf_stage.vhdl
vcom src/ntt/ntt_pipe.vhdl
vcom src/ntt/ntt_controller.vhdl
#vcom src/ntt/ntt_mux.vhdl
vcom src/ntt/ntt_node.vhdl
#vcom src/ntt/ntt_root.vhdl
#vcom src/ntt/inv_ntt_node.vhdl
#vcom src/ntt/inv_ntt_root.vhdl

vcom src/e_crystals_dilithium.vhdl

vcom testbenches/ntt_results.vhdl
vcom testbenches/tb_ntt_controller.vhdl

# =========================================================
# simulate
# =========================================================
vsim work.tb_ntt_controller

# optional waves
add wave -r *
radix decimal

# run until finish
run -all
