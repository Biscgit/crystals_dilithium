library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity e_mul_coefficient is
  port (
    clock       : in    std_logic;
    input_a     : in    coefficient;
    input_b     : in    coefficient;
    output      : out   coefficient;
    mm_start    : in    std_logic;
    mm_finished : out   std_logic
  );
end entity e_mul_coefficient;

architecture a_mul_coefficient of e_mul_coefficient is

  type t_states is (idle, done);

  signal slv_state  : t_states;
  signal slv_result : mul_coefficient;

begin

  p_mul_coefficient : process (clock) is
  begin

    if rising_edge(clock) then
      mm_finished <= '0';
      --
      if (slv_state = idle) then
        if (mm_start = '1') then
          slv_result <= (input_a * input_b) mod q;
          slv_state  <= done;
        end if;
      --
      elsif (slv_state = done) then
        output      <= resize(slv_result, q_len + 1);
        mm_finished <= '1';
        slv_state   <= idle;
      --
      else
        slv_state <= idle;
      end if;
    end if;

  end process p_mul_coefficient;

end architecture a_mul_coefficient;
