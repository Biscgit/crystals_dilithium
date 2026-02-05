library work;
	use work.keccak_globals.all;
	
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;	



entity keccak_rc_wrapper is
  
  port (
    reg_data: in k_state;
	 din_buffer_out: in std_logic_vector(1343 downto 0);
	 din_buffer_full: in std_logic;
	 permutation_computed: in std_logic;
	 rc_sel:	in std_logic_vector(1 downto 0);
	 round_in_out: out k_state
	 );

end keccak_rc_wrapper;


architecture rtl of keccak_rc_wrapper is 

signal sha3_256_round_in, sha3_512_round_in, shake_128_round_in: k_state;

begin

	-- output
	round_in_out <= sha3_256_round_in when (rc_sel="01") else
       sha3_512_round_in when (rc_sel="10") else
       shake_128_round_in when (rc_sel="11") else
       sha3_512_round_in;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- SHAKE256, SHA3-256 [FIPS 202], cSHAKE256, KMAC256, KMACXOF256, TupleHash256, TupleHashXOF256, ParallelHash256, ParallelHashXOF256 [SP 800-185]
--capacity part

	i01_sha3_256: for col in 2 to 4 generate
		i02_sha3_256: for i in 0 to 63 generate
			sha3_256_round_in(3)(col)(i)<= reg_data(3)(col)(i);

		
		end generate;	
	end generate;

	i03_sha3_256: for col in 0 to 4 generate
		i04_sha3_256: for i in 0 to 63 generate
			sha3_256_round_in(4)(col)(i)<= reg_data(4)(col)(i);
	end generate;	
	end generate;
	
--rate part
i10_sha3_256: for row in 0 to 2 generate
	i11_sha3_256: for col in 0 to 4 generate
		i12_sha3_256: for i in 0 to 63 generate
			sha3_256_round_in(row)(col)(i)<= reg_data(row)(col)(i) xor (din_buffer_out((row*64*5)+(col*64)+i) and (din_buffer_full and permutation_computed));
		end generate;	
	end generate;
end generate;

i13_sha3_256: for col in 0 to 1 generate
	i14_sha3_256: for i in 0 to 63 generate
			sha3_256_round_in(3)(col)(i)<= reg_data(3)(col)(i) xor (din_buffer_out((3*64*5)+(col*64)+i) and (din_buffer_full and permutation_computed));
	end generate;	
end generate;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- SHA3-512 [FIPS 202]
--capacity part
i01_sha3_512: for row in 2 to 4 generate
	i02_sha3_512: for col in 0 to 4 generate
		i03_sha3_512: for i in 0 to 63 generate
			sha3_512_round_in(row)(col)(i)<= reg_data(row)(col)(i);
		end generate;	
	end generate;
	end generate;

		i04_sha3_512: for i in 0 to 63 generate
			sha3_512_round_in(1)(4)(i)<= reg_data(1)(4)(i);
	end generate;	
	
--rate part

	i10_sha3_512: for col in 0 to 4 generate
		i11_sha3_512: for i in 0 to 63 generate
			sha3_512_round_in(0)(col)(i)<= reg_data(0)(col)(i) xor (din_buffer_out((0*64*5)+(col*64)+i) and (din_buffer_full and permutation_computed));
	end generate;
end generate;

i12_sha3_512: for col in 0 to 3 generate
	i13_sha3_512: for i in 0 to 63 generate
			sha3_512_round_in(1)(col)(i)<= reg_data(1)(col)(i) xor (din_buffer_out((1*64*5)+(col*64)+i) and (din_buffer_full and permutation_computed));
	end generate;	
end generate;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- SHAKE128 [FIPS 202], cSHAKE128, KMAC128, KMACXOF128, TupleHash128, TupleHashXOF128, ParallelHash128, ParallelHashXOF128 [SP 800-185]
--capacity part

	i01_shake_128: for col in 1 to 4 generate
		i02_shake_128: for i in 0 to 63 generate
			shake_128_round_in(4)(col)(i)<= reg_data(4)(col)(i);

		end generate;	
	end generate;
	
--rate part
i10_shake_128: for row in 0 to 3 generate
	i11_shake_128: for col in 0 to 4 generate
		i12_shake_128: for i in 0 to 63 generate
			shake_128_round_in(row)(col)(i)<= reg_data(row)(col)(i) xor (din_buffer_out((row*64*5)+(col*64)+i) and (din_buffer_full and permutation_computed));
		end generate;	
	end generate;
end generate;

i13_shake_128: for i in 0 to 63 generate
			shake_128_round_in(4)(0)(i)<= reg_data(4)(0)(i) xor (din_buffer_out((4*64*5)+(0*64)+i) and (din_buffer_full and permutation_computed));
end generate;	


end architecture rtl;