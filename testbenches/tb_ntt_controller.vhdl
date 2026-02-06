library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.globals.all;
use work.ntt_results.all;

entity tb_ntt_controller is
end entity;

architecture sim of tb_ntt_controller is

  ------------------------------------------------------------------
  -- DUT signals
  ------------------------------------------------------------------
  signal clock     : std_logic := '0';
  signal start_ntt : std_logic := '0';
  signal finished  : std_logic;

  signal input_poly  : polynomial;
  signal output_poly : polynomial;

  constant clk_period : time := 10 ns;

begin

  ------------------------------------------------------------------
  -- DUT
  ------------------------------------------------------------------
  dut : entity work.ntt_controller
    port map (
      clock     => clock,
      input     => input_poly,
      output    => output_poly,
      start_ntt => start_ntt,
      finished  => finished
    );

  ------------------------------------------------------------------
  -- clock
  ------------------------------------------------------------------
  clock <= not clock after clk_period/2;

  ------------------------------------------------------------------
  -- stimulus
  ------------------------------------------------------------------
  stim : process
  variable temp_poly : polynomial;
  begin
    wait for 50 ns;


    ------------------------------------------------------------
    -- load test vector
    ------------------------------------------------------------
    for i in 0 to n-1 loop
      input_poly(i) <= to_signed(values(i), q_len);
    end loop;

    ------------------------------------------------------------
    -- start
    ------------------------------------------------------------
    wait until rising_edge(clock);
    for i in 0 to n-1 loop
      report "input_poly(" & integer'image(i) & ") = " & integer'image(to_integer(to_signed(values(i), q_len)));
      report "input_poly(" & integer'image(i) & ") = " & integer'image(to_integer(input_poly(i)));
    end loop;
    start_ntt <= '1';

    wait until rising_edge(clock);
    start_ntt <= '0';

    ------------------------------------------------------------
    -- wait for finish
    ------------------------------------------------------------
    wait until finished = '1';
    wait until rising_edge(clock);

    ------------------------------------------------------------
    -- compare results
    ------------------------------------------------------------
    for i in 0 to n-1 loop
      report "output_poly(" & integer'image(i) & ") = "
               & integer'image(to_integer(output_poly(i)));
      assert output_poly(i) = results(i)
        report "Mismatch at index "
               & integer'image(i)
               & "  got="
               & integer'image(to_integer(output_poly(i)))
               & "  exp="
               & integer'image(results(i))
        severity error;
    end loop;

    report "NTT test PASSED";
    wait;
  end process;

end architecture;

