library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity e_add_polynomial is
  port (
    clock       : in    std_logic;
    input_a     : in    polynomial;
    input_b     : in    polynomial;
    output      : out   polynomial;
    ad_start    : in    std_logic;
    ad_finished : out   std_logic
  );
end entity e_add_polynomial;

architecture a_add_polynomial of e_add_polynomial is

  type t_states is (idle, add, done);

  signal slv_state  : t_states;
  signal slv_result : polynomial;
  signal slv_index  : natural range output'range;

begin

  p_add_polynomial : process (clock) is
  begin

    if rising_edge(clock) then
      ad_finished <= '0';
      --
      if (slv_state = idle) then
        if (ad_start = '1') then
          slv_state <= add;
          slv_index <= 0;
        end if;
      --
      elsif (slv_state = add) then
        if (slv_index >= output'length - 1) then
          slv_state <= done;
        else
          slv_result(slv_index) <= (input_a(slv_index) + input_b(slv_index)) mod q;
          slv_index             <= slv_index + 1;
        end if;

      --
      elsif (slv_state = done) then
        output      <= slv_result;
        ad_finished <= '1';
        slv_state   <= idle;
      --
      else
        slv_state <= idle;
      end if;
    end if;

  end process p_add_polynomial;

end architecture a_add_polynomial;
