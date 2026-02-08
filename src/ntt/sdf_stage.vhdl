library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity ntt_sdf_stage is
  generic (
    delay    : natural;
    stage_id : natural
  );
  port (
    clock : in    std_logic;
    en    : in    std_logic;
    cnt   : in    unsigned(7 downto 0);
    zeta  : in    coefficient;
    din   : in    coefficient;
    dout  : out   coefficient
  );
end entity ntt_sdf_stage;

architecture a_ntt_sdf_stage of ntt_sdf_stage is

  -- The Delay FIFO. Important: Quartus will infer M10K RAM if DELAY is large.

  type t_fifo is array (0 to DELAY - 1) of coefficient;

  signal fifo : t_fifo := (others => (others => '0'));

  signal bf_u_in,  bf_v_in  : coefficient;
  signal bf_u_out, bf_v_out : coefficient;

  -- Mode bit: when '0' we fill FIFO, when '1' we calculate
  signal s_mode : std_logic;

begin

  s_mode <= cnt(7 - stage_id);

  u_butterfly : entity work.ntt_butterfly
    port map (
      clock => clock,
      u_in  => bf_u_in,
      v_in  => bf_v_in,
      zeta  => zeta,
      u_out => bf_u_out,
      v_out => bf_v_out
    );

  -- Connections
  bf_u_in <= fifo(delay - 1);
  bf_v_in <= din;

  process (clock) is
  begin

    if rising_edge(clock) then
      if (en = '1') then
        if (s_mode = '0') then
          -- Fill Phase
          fifo(0) <= din;
          dout    <= fifo(delay - 1);
        else
          -- Butterfly Phase
          fifo(0) <= bf_v_out;
          dout    <= bf_u_out;
        end if;

        -- Shift FIFO (The delay line)
        for i in 1 to delay - 1 loop

          fifo(i) <= fifo(i - 1);

        end loop;

      end if;
    end if;

  end process;

end architecture a_ntt_sdf_stage;
