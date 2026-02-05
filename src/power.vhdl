library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity power is
  port (
    number   : in    signed(18 downto 0);
    exponent : in    signed(4 downto 0);
    result   : out   signed(21 downto 0)
  );
end entity power;

architecture a_power of power is

  signal r0_temp   : signed(18 downto 0);
  signal d_powerd : signed(18 downto 0);

begin

    power: process()

end architecture a_power;
