library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity vector_mul_number is
  generic (
    size : natural
  );
  port (
    input_vector : in    natural_vector;
    input_number : in    std_logic_vector(size - 1 downto 0);
    output       : out   natural_vector;
    start_mul    : in    std_logic;
    finished     : out   std_logic
  );
end entity vector_mul_number;

architecture a_vector_mul_number of vector_mul_number is

  subtype big_coefficient is signed(q_len * 2 downto 0);

  type big_natural_polynomial is array (natural range <>) of big_coefficient;

  type big_vector is array (natural range <>) of big_natural_polynomial;

  signal slv_result : big_vector;

begin

  output <= slv_result;

  add_number : for i in input_vector'range generate
  begin
    slv_result(i) <= (input_vector(i) * signed(input_number)) mod q;
  end generate add_number;

end architecture a_vector_mul_number;
