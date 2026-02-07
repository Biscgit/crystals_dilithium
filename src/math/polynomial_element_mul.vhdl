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

  signal slv_cache : natural_polynomial(input_a'length + input_b'length - 1 downto 0);

begin

  g_vector_sum : for i in polynomial'range generate
    -- ToDo: adjust mod!
    slv_cache(i) <= (input_a(i) * input_b(i)) mod q;
    output(i)    <= slv_cache(i)(output'range);
  end generate g_vector_sum;

end architecture a_polynomial_element_mul;
