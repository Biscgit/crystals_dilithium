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

  component ntt_controller is
    port (
      clock     : in    std_logic;
      input     : in    polynomial;
      output    : out   polynomial;
      start_ntt : in    std_logic;
      finished  : out   std_logic
    );
  end component ntt_controller;

  signal a : polynomial := (others => (others => '1'));

begin

  test : component ntt_controller
    port map (
      clock     => clock_50,
      input     => a,
      output    => open,
      start_ntt => '1',
      finished  => open
    );

end architecture a_crystals_dilithium;
