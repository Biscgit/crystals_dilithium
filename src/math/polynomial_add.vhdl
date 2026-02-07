library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity polynomial_add is
  port (
    input_a : in    polynomial;
    input_b : in    polynomial;
    output  : out   polynomial
  );
end entity polynomial_add;

architecture a_polynomial_add of polynomial_add is

begin

  g_vector_sum : for i in polynomial'range generate
    output(i) <= input_a(i) + input_b(i);
  end generate g_vector_sum;

end architecture a_polynomial_add;
