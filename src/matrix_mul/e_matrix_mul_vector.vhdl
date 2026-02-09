library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity e_matrix_mul_vector is
  port (
    clock_50    : in    std_logic;
    input_a     : in    t_a_matrix;
    input_b     : in    s1;
    output      : out   s2;
    mm_start    : in    std_logic;
    mm_finished : out   std_logic
  );
end entity e_matrix_mul_vector;

architecture a_matrix_mul_vector of e_matrix_mul_vector is

  component e_mul_polynomial is
    port (
      clock       : in    std_logic;
      input_a     : in    polynomial;
      input_b     : in    polynomial;
      output      : out   polynomial;
      mm_start    : in    std_logic;
      mm_finished : out   std_logic
    );
  end component e_mul_polynomial;

  component e_add_polynomial is
    port (
      clock       : in    std_logic;
      input_a     : in    polynomial;
      input_b     : in    polynomial;
      output      : out   polynomial;
      ad_start    : in    std_logic;
      ad_finished : out   std_logic
    );
  end component e_add_polynomial;

  type t_states is (idle, loading, multiply, add, check_l, check_k, done);

  signal slv_state : t_states;

  -- signal slv_full_cache : s2;
  -- signal slv_mul_cache  : polynomial;

  signal slv_index_l : natural range l - 1 downto 0;
  signal slv_index_k : natural range k - 1 downto 0;
  -- signal slv_index_s : natural(l - 1 downto 0);

  signal slv_result : s2;

  signal clock : std_logic;

  signal slv_polynom_a : polynomial;
  signal slv_polynom_b : polynomial;

  signal slv_mul_output  : polynomial;
  signal slv_mul_storage : s1;

  signal slv_add_input_cache : polynomial;
  signal slv_add_input_a     : polynomial;
  signal slv_add_input_b     : polynomial;
  signal slv_add_output      : polynomial;

  signal slv_mul_start : std_logic;
  signal slv_mul_done  : std_logic;

  signal slv_add_start : std_logic;
  signal slv_add_done  : std_logic;

begin

  clock <= clock_50;

  c_multiplier : component e_mul_polynomial
    port map (
      clock       => clock,
      input_a     => slv_polynom_a,
      input_b     => slv_polynom_b,
      output      => slv_mul_output,
      mm_start    => slv_mul_start,
      mm_finished => slv_mul_done
    );

  c_sum : component e_add_polynomial
    port map (
      clock       => clock,
      input_a     => slv_add_input_a,
      input_b     => slv_add_input_b,
      output      => slv_add_output,
      ad_start    => slv_add_start,
      ad_finished => slv_add_done
    );

  p_multiply_matrix : process (clock) is
  begin

    if rising_edge(clock) then
      slv_mul_start <= '0';
      slv_add_start <= '0';

      mm_finished <= '0';
      --
      if (slv_state = idle) then
        if (mm_start = '1') then
          slv_index_k <= 0;
          slv_index_l <= 0;

          slv_mul_storage <= (others => (others => (others => '0')));
          slv_result      <= (others => (others => (others => '0')));

          -- slv_mul_cache  <= (others => (others => '0'));

          slv_state <= loading;
        end if;
      --
      elsif (slv_state = loading) then
        slv_polynom_a <= input_a(slv_index_k, slv_index_l);
        slv_polynom_b <= input_b(slv_index_l);

        slv_mul_start <= '1';
        slv_state     <= multiply;
      --
      elsif (slv_state = multiply) then
        if (slv_mul_done = '1') then
          if (slv_index_l >= l - 1) then
            slv_state <= add;
          else
            slv_index_l <= slv_index_l + 1;
            slv_state   <= add;
          end if;
        end if;

      --
      elsif (slv_state = add) then
        if (slv_add_done = '0') then
          slv_add_input_a <= slv_mul_output;
          slv_add_input_b <= slv_add_input_cache;
          slv_add_start   <= '1';
        else
          slv_add_input_cache <= slv_add_output;
          slv_state           <= check_l;
        end if;
      --
      elsif (slv_state = check_l) then
        if (slv_index_l >= l - 1) then
          slv_state <= check_k;

          slv_index_l             <= 0;
          slv_result(slv_index_k) <= slv_add_input_cache;
        else
          slv_state <= loading;
        end if;
      --
      elsif (slv_state = check_k) then
        if (slv_index_k = k - 1) then
          slv_state <= done;
        else
          slv_index_k <= slv_index_k + 1;
          slv_state   <= loading;
        end if;
      --
      elsif (slv_state = done) then
        mm_finished <= '1';
        output      <= slv_result;
        slv_state   <= idle;
      --
      else
        slv_state <= idle;
      end if;
    end if;

  end process p_multiply_matrix;

end architecture a_matrix_mul_vector;

