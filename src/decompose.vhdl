library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity decompose is
  port (
    r  : in    coefficient;
    a  : in    coefficient;
    r0 : out   coefficient;
    r1 : out   coefficient
  );
end entity decompose;

architecture a_decompose of decompose is

  signal r0_temp : signed(18 downto 0);

begin

  r0_temp <= r when r < '0' & a(18 downto 1) else -- r mods a
             r - a;

  r1 <= (r - r0_temp) / a;
  r0 <= r0_temp;

end architecture a_decompose;
