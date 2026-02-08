library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;
  use work.ntt_results.all;

entity tb_ntt_controller is
end entity tb_ntt_controller;

architecture sim of tb_ntt_controller is

  ------------------------------------------------------------------
  -- DUT signals
  ------------------------------------------------------------------
  signal clock     : std_logic := '0';
  signal start_ntt : std_logic := '0';
  signal finished  : std_logic;

  signal input_poly  : natural_vector(0 downto 0) := (others => (others => (others => '0')));
  signal output_poly : natural_vector(0 downto 0);

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
  clock <= not clock after clk_period / 2;

  ------------------------------------------------------------------
  -- stimulus
  ------------------------------------------------------------------
  stim : process is

    variable temp_poly   : polynomial;
    variable all_correct : boolean := true;

  begin

    wait for 50 ns;

    ------------------------------------------------------------
    -- load test vector
    ------------------------------------------------------------
    for i in 0 to n - 1 loop

      input_poly(0)(i) <= to_signed(values(i), q_len + 1);

    end loop;

    ------------------------------------------------------------
    -- start
    ------------------------------------------------------------
    wait until rising_edge(clock);
    start_ntt <= '1';

    wait until rising_edge(clock);
    start_ntt <= '0';

    ------------------------------------------------------------
    -- wait for finish
    ------------------------------------------------------------
    wait until finished = '1';
    wait until rising_edge(clock);
    wait until rising_edge(clock);

    ------------------------------------------------------------
    -- compare results
    ------------------------------------------------------------
    all_correct := true;

    for i in 0 to n - 1 loop

      -- Check for mismatch (Notice the logic is inverted from '=' to '/=')
      -- Preserving your index logic: output_poly(n-i-1) vs results(i)
      if (output_poly(0)(n - i - 1) /= results(i)) then
        -- Mark test as failed
        all_correct := false;

        -- Report only the specific failure
        report "Mismatch at index " & integer'image(i) &
               " (Output Index " & integer'image(n - i - 1) & ")" &
               "  got=" & integer'image(to_integer(output_poly(0)(n - i - 1))) &
               "  exp=" & integer'image(results(i))
          severity error;
      end if;

    end loop;

    -- Only print PASSED if the flag is still true
    if (all_correct) then
      report "NTT test PASSED"
        severity note;
    else
      report "NTT test FAILED: Mismatches detected."
        severity failure;
    end if;

    wait;

  end process stim;

end architecture sim;

