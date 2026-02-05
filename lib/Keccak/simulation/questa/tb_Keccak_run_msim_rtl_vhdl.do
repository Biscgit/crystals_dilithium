transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:/intelFPGA_lite/Abgabe/Keccak/e_keccak/keccak_globals.vhd}
vcom -93 -work work {C:/intelFPGA_lite/Abgabe/Keccak/e_keccak/keccak_round_constants_gen.vhd}
vcom -93 -work work {C:/intelFPGA_lite/Abgabe/Keccak/e_keccak/keccak_round.vhd}
vcom -93 -work work {C:/intelFPGA_lite/Abgabe/Keccak/e_keccak/keccak_buffer.vhd}
vcom -93 -work work {C:/intelFPGA_lite/Abgabe/Keccak/e_keccak/keccak.vhd}
vcom -93 -work work {C:/intelFPGA_lite/Abgabe/Keccak/e_keccak/keccak_rc_wrapper.vhd}

