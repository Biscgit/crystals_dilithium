library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity matrix_mul_vector is
  port (
    clock        : in    std_logic;
    input_matrix : in    a_array;
    input_vector : in    s1;
    output       : out   s2;
    start_mul    : in    std_logic;
    finished     : out   std_logic
  );
end entity matrix_mul_vector;

architecture a_matrix_mul_vector of matrix_mul_vector is

  component polynomial_element_mul is
    port (
      input_a : in    natural_polynomial;
      input_b : in    natural_polynomial;
      output  : out   natural_polynomial
    );
  end component polynomial_element_mul;

  component polynomial_add is
    port (
      input_a : in    natural_polynomial;
      input_b : in    natural_polynomial;
      output  : out   natural_polynomial
    );
  end component polynomial_add;

  type t_state is (idle, run, done);

  signal slv_state        : t_state;
  signal slv_input_matrix : a_array;

  signal slv_index_col : integer range 0 to k - 1;
  signal slv_index_row : integer range 0 to l;

  signal slv_mul_result : polynomial;

  signal slv_current_mul : polynomial;
  signal slv_next_mul    : polynomial;

  signal slv_result : s2;

begin

  output <= slv_result;

  -- store multiplication result
  p_multiply_elements : component polynomial_element_mul
    port map (
      input_a => slv_input_matrix(slv_index_col)(slv_index_row),
      input_b => input_vector(slv_index_row),
      output  => slv_mul_result
    );

  -- calculate sum and store into temporary variable
  p_add_elements : component polynomial_add
    port map (
      input_a => slv_mul_result,
      input_b => slv_current_mul,
      output  => slv_next_mul
    );

  -- iter through matrix
  p_matrix_mul : process (clock, slv_state) is
  begin

    if rising_edge(clock) then
      if (slv_state = idle) then
        if (start_mul = '1') then
          slv_state <= run;

          slv_result       <= (others => (others => (others => '0')));
          slv_input_matrix <= input_matrix;

          slv_index_col <= 0;
          slv_index_row <= 0;
        end if;
      --
      elsif (slv_state = run) then
        -- reset counter and sum up array in last additional step
        if (slv_index_row = l) then
          slv_index_row <= 0;
          slv_index_col <= slv_index_col + 1;

          -- write into temporary storage
          slv_result(slv_index_col) <= slv_next_mul;
          slv_current_mul           <= (others => (others => '0'));

        -- multiply and add other to other
        else
          slv_current_mul <= slv_next_mul;
        -- slv_next_mul    <= (others => (others => '0'));  -- TODO: ERROR WITH RESETTING!!
        end if;

        -- calculate
        if ((slv_index_col = (k - 1)) and (slv_index_row = l)) then
          slv_state <= done;
        end if;

      --
      elsif (slv_state = done) then
        finished  <= '1';
        slv_state <= idle;
      --
      else
        slv_state <= idle;
      end if;
    end if;

  end process p_matrix_mul;

end architecture a_matrix_mul_vector;
