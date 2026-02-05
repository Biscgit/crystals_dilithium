vcom -reportprogress 300 -work work ../../tb_Keccak.vhd
vcom -reportprogress 300 -work work tb_tb_Keccak.vht
vsim -voptargs=+acc work.tb_tb_keccak
do wave.do
run -all