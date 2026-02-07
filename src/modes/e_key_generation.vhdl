library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity e_key_generation is
  port (
    clock            : in    std_logic;
    matrix_a         : in    a_array; -- a is already in ntt form
    vector_s1        : in    s1;
    vector_s2        : in    s1;
    vector_t         : out   s2;
    start_generation : in    std_logic;
    has_finished     : out   std_logic
  );
end entity e_key_generation;

architecture a_key_generation of e_key_generation is

  component matrix_mul_vector is
    port (
      clock        : in    std_logic;
      input_matrix : in    a_array;
      input_vector : in    s1;
      output       : out   s2;
      start_mul    : in    std_logic;
      finished     : out   std_logic
    );
  end component matrix_mul_vector;

  component vector_add_vector is
    port (
      input_vector1 : in    natural_vector;
      input_vector2 : in    natural_vector;
      output        : out   natural_vector
    );
  end component vector_add_vector;

  type t_gen_state is (
    idle,
    ntt_s1,
    multiply_a_s1,
    intt,
    add_s2,
    done
  );

  signal slv_state : t_gen_state;

  signal slv_matrix_a  : a_array;
  signal slv_vector_s1 : s1;
  signal slv_vector_s2 : s2;

  signal slv_matrix_mul_result   : s2;
  signal slv_start_matrix_mul    : std_logic;
  signal slv_finished_matrix_mul : std_logic;
  signal slv_as1_input           : s2;

  signal slv_vector_t : s2;

begin

  slv_start_matrix_mul <= '1' when slv_state = multiply_a_s1 else
                          '0';
  vector_t             <= slv_vector_t;

  -- A * s multiplier
  a_s_multiplier : component matrix_mul_vector
    port map (
      clock        => clock,
      input_matrix => slv_matrix_a,
      input_vector => slv_vector_s1,
      output       => slv_matrix_mul_result,
      start_mul    => slv_start_matrix_mul,
      finished     => slv_finished_matrix_mul
    );

  as_s2_sum : component vector_add_vector
    port map (
      input_vector1 => slv_as1_input,
      input_vector2 => slv_vector_s2,
      output        => slv_vector_t
    );

  -- main state machine for key generation
  p_fsm_generation : process (clock, slv_state) is
  begin

    if rising_edge(clock) then
      has_finished <= '0';
      --
      if (slv_state = idle) then
        if (start_generation = '1') then
          slv_state <= ntt_s1;

          slv_matrix_a  <= matrix_a;
          slv_vector_s1 <= vector_s1;
          slv_vector_s2 <= vector_s2;

        -- slv_acc_poly <= (others => (others => '0'));
        -- slv_vector_t <= (others => (others => '0'));
        end if;

      --
      elsif (slv_state = ntt_s1) then
      ---
      elsif (slv_state = multiply_a_s1) then
        if (slv_finished_matrix_mul = '1') then
          slv_state <= intt;
        end if;

      --
      elsif (slv_state = intt) then
      --
      elsif (slv_state = add_s2) then
        slv_as1_input <= slv_matrix_mul_result;
        slv_state     <= done;
      --
      elsif (slv_state = done) then
        has_finished <= '1';
        slv_state    <= idle;
      --
      else
        slv_state <= idle;
      end if;
    end if;

  end process p_fsm_generation;

end architecture a_key_generation;

