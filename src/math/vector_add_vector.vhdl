library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity vector_add_vector is
  port (
    input_vector1 : in    vector;
    input_vector2 : in    vector;
    output        : out   vector
  );
end entity vector_add_vector;

architecture a_vector_add_vector of vector_add_vector is

  signal slv_result : vector;

begin

  output <= slv_result;

  gen_row : for i in vector'range generate
  begin

    gen_col : for j in polynomial'range generate

    begin
      -- ToDo: adjust mod!
      output(i, j) <= (input_vector1(i, j) + input_vector2(i, j)) mod n;
    end generate gen_col;

  end generate gen_row;

end architecture a_vector_add_vector;
