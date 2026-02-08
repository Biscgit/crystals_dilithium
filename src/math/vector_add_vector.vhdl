library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity vector_add_vector is
  port (
    input_vector1 : in    natural_vector;
    input_vector2 : in    natural_vector;
    output        : out   natural_vector
  );
end entity vector_add_vector;

architecture a_vector_add_vector of vector_add_vector is

  signal slv_result : natural_vector(output'range);

begin

  -- output <= slv_result;

  gen_row : for i in input_vector1'range generate
  begin

    gen_col : for j in polynomial'range generate

    begin
      -- ToDo: adjust mod!
      output(i)(j) <= (input_vector1(i)(j) + input_vector2(i)(j)) mod q;
    end generate gen_col;

  end generate gen_row;

end architecture a_vector_add_vector;
