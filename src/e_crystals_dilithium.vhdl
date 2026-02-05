library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity e_crystals_dilithium is
  port (
    sw   : in    std_logic_vector(9 downto 0);
    ledr : out   std_logic_vector(9 downto 0)
  );
end entity e_crystals_dilithium;

architecture a_crystals_dilithium of e_crystals_dilithium is

  signal test : integer;

begin

  test <= 10 mod 3;

end architecture a_crystals_dilithium;
