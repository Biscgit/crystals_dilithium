library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity decompose is
  port (
    r  : in    natural_polynomial;
    a  : in    natural;
    r0 : out   natural_polynomial;
    r1 : out   natural_polynomial
  );
end entity decompose;

architecture a_decompose of decompose is

  signal r0_temp : natural_polynomial;

begin

  high_low_bits : for i in 0 to r'length generate
    r0_temp(i) <= r(i) mod a when r(i) mod a <= a / 2 else -- r mods a
                  r(i) - a;

    r1(i) <= (r(i) - r0_temp(i)) / a;
    r0    <= r0_temp;
  end generate high_low_bits;

end architecture a_decompose;
