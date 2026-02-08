library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity polynomial_element_mul is
  port (
    input_a : in    natural_polynomial;
    input_b : in    natural_polynomial;
    output  : out   natural_polynomial
  );
end entity polynomial_element_mul;

architecture a_polynomial_element_mul of polynomial_element_mul is

  type poly_cache is array (output'range) of mul_coefficient;

  signal slv_cache : poly_cache;

begin

  g_vector_sum : for i in input_a'range generate
    -- ToDo: adjust mod!
    slv_cache(i) <= (input_a(i) * input_b(i)) mod q;
    output(i)    <= resize(slv_cache(i), coefficient'length);

  end generate g_vector_sum;

end architecture a_polynomial_element_mul;
