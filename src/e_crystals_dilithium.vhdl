library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity e_crystals_dilithium is
  port (
    sw   : in    std_logic_vector(9 downto 0);
    ledr : out   std_logic_vector(9 downto 0)
  );
end entity e_crystals_dilithium;

architecture a_crystals_dilithium of e_crystals_dilithium is

  component ntt_root is
    port (
    a     : in    polynominal;
    ntt_a : out   polynominal
    );
  end component ntt_root;
    signal a : polynominal := (others => (others => '0'));

begin

    test: ntt_root
     port map(
        a => a,
        ntt_a => open
    );

end architecture a_crystals_dilithium;
