library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity countdown_clock is
  generic (
    -- count limit of the timer
    counter_limit : natural := 8
  );
  port (
    -- clock, counter enabled and reset
    slv_clock           : in    std_logic;
    slv_counter_enabled : in    std_logic;
    slv_reset           : in    std_logic;
    slv_write           : in    std_logic;
    -- output 1 for one cycle when timer is complete
    slv_output : out   std_logic;
    -- internal counter interfaces
    slv_counter_in  : in    natural;
    slv_counter_out : out   natural
  );
end entity countdown_clock;

architecture a_countdown_clock of countdown_clock is

  constant limit        : natural := counter_limit;
  signal   slv_internal : natural;

begin

  slv_counter_out <= slv_internal;

  p_counter : process (slv_clock, slv_reset, slv_write, slv_counter_enabled, slv_counter_in) is
  begin

    if rising_edge(slv_clock) then
      -- set output to 0 by default
      slv_output <= '0';

      -- check reset first
      if (slv_reset = '1') then
        slv_internal <= limit;

      -- write to counter if slv_write is enabled
      elsif (slv_write = '1') then
        slv_internal <= slv_counter_in;

      -- otherwise, forward counter if enabled
      elsif (slv_counter_enabled = '1') then
        if (slv_internal = 0) then
          slv_internal <= 0;
          slv_output   <= '1';
        else
          slv_internal <= slv_internal - 1;
        end if;
      end if;
    end if;

  end process p_counter;

end architecture a_countdown_clock;
