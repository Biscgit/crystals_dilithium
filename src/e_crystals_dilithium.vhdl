library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity e_crystals_dilithium is
  port (
    clock_50 : in    std_logic;
    sw       : in    std_logic_vector(9 downto 0);
    ledr     : out   std_logic_vector(9 downto 0)
  );
end entity e_crystals_dilithium;

architecture a_crystals_dilithium of e_crystals_dilithium is

  component ntt_root is
    port (
      clock    : in    std_logic;
      a        : in    polynomial;
      ntt_a    : out   polynomial;
      finished : out   std_logic
    );
  end component ntt_root;

  signal a : polynomial := (others => (others => '1'));

begin

  test : component ntt_root
    port map (
      clock    => clock_50,
      a        => a,
      ntt_a    => open,
      finished => open
    );

end architecture a_crystals_dilithium;
