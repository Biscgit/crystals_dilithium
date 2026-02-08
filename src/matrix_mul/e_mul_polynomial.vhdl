library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity e_mul_polynomial is
  port (
    clock       : in    std_logic;
    input_a     : in    polynomial;
    input_b     : in    polynomial;
    output      : out   polynomial;
    mm_start    : in    std_logic;
    mm_finished : out   std_logic
  );
end entity e_mul_polynomial;

architecture a_mul_polynomial of e_mul_polynomial is

  component e_mul_coefficient is
    port (
      clock       : in    std_logic;
      input_a     : in    coefficient;
      input_b     : in    coefficient;
      output      : out   coefficient;
      mm_start    : in    std_logic;
      mm_finished : out   std_logic
    );
  end component e_mul_coefficient;

  type t_states is (idle, load, multiply, check, done);

  signal slv_state  : t_states;
  signal slv_index  : natural range n - 1 downto 0;
  signal slv_result : polynomial;

  signal slv_mul_input_a : coefficient;
  signal slv_mul_input_b : coefficient;
  signal slv_mul_output  : coefficient;
  signal slv_mul_start   : std_logic;
  signal slv_mul_done    : std_logic;

begin

  c_mul_circuit : component e_mul_coefficient
    port map (
      clock       => clock,
      input_a     => slv_mul_input_a,
      input_b     => slv_mul_input_b,
      output      => slv_mul_output,
      mm_start    => slv_mul_start,
      mm_finished => slv_mul_done
    );

  p_mul_polynomial : process (clock) is
  begin

    if rising_edge(clock) then
      mm_finished   <= '0';
      slv_mul_start <= '0';
      --
      if (slv_state = idle) then
        if (mm_start = '1') then
          slv_index <= 0;

          slv_mul_start   <= '1';
          slv_mul_input_a <= input_a(slv_index);
          slv_mul_input_b <= input_b(slv_index);

          slv_state <= multiply;
        end if;
      --
      elsif (slv_state = multiply) then
        if (slv_mul_done = '1') then
          slv_result(slv_index) <= slv_mul_output;
          slv_state             <= check;
        end if;
      --
      elsif (slv_state = check) then
        if (slv_index = n - 1) then
          slv_state <= done;
        else
          slv_index <= slv_index + 1;
          slv_state <= load;
        end if;
      --
      elsif (slv_state = done) then
        output      <= slv_result;
        mm_finished <= '1';
        slv_state   <= idle;
      --
      else
        slv_state <= idle;
      end if;
    end if;

  end process p_mul_polynomial;

end architecture a_mul_polynomial;
