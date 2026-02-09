library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;
  use work.zeta_lut.all;

entity ntt_sdf_stage is
  generic (
    delay    : natural;
    stage_id : natural
  );
  port (
    clock : in    std_logic;
    en    : in    std_logic;
    cnt   : in    unsigned(7 downto 0);
    din   : in    coefficient;
    dout  : out   coefficient
  );
end entity ntt_sdf_stage;

architecture a_ntt_sdf_stage of ntt_sdf_stage is

  constant start_reading   : natural              := (256 - 2 ** (8 - stage_id));
  constant start_computing : natural              := (256 - 2 ** (8 - (stage_id + 1)));
  signal   counter         : unsigned(7 downto 0) := (others => '0');

  -- The Delay FIFO. Important: Quartus will infer M10K RAM if DELAY is large.

  type t_ntt_stage_state is (s_idle, s_wait_to_collect, s_stream_in, s_stram_and_computing);

  signal slv_ntt_stage_state : t_ntt_stage_state;

  type t_fifo is array (0 to DELAY - 1) of coefficient;

  signal fifo : t_fifo := (others => (others => '0'));

  signal bf_u_in,  bf_v_in  : coefficient;
  signal bf_u_out, bf_v_out : coefficient;

  -- Logic for Zeta Indexing
  signal zeta_idx     : unsigned(7 downto 0);
  signal current_zeta : coefficient;

  -- Mode bit: when '0' we fill FIFO, when '1' we calculate
  signal s_mode : std_logic;

  function rev_bits (
    vec: unsigned
  ) return unsigned is

    variable res : unsigned(vec'range);

  begin

    for i in vec'low to vec'high loop

      res(vec'high - (i - vec'low)) := vec(i);

    end loop;

    return res;

  end function rev_bits;

begin

  process (clock) is
  begin

    if rising_edge(clock) then

      case slv_ntt_stage_state is

        when s_idle =>

          if (en = '1') then
            counter             <= (others => '0');
            slv_ntt_stage_state <= s_wait_to_collect;
          end if;

        when s_wait_to_collect =>

          counter <= counter + 1;
          if ((start_reading) = counter) then
            counter             <= (others => '0');
            slv_ntt_stage_state <= s_stream_in;
          end if;

        when s_stream_in =>

          counter <= counter + 1;
          if ((start_computing) = counter) then
            slv_ntt_stage_state <= s_stram_and_computing;
          end if;

        when s_stram_and_computing =>
          counter <= counter + 1;

          if ((start_computing) = cnt) then
          end if;

      end case;

    end if;

  end process;

  s_mode <= cnt(7 - stage_id);

  -- 2. Zeta Index Construction
  process (cnt) is

    variable high_bits : unsigned(stage_id downto 0);

  begin

    zeta_idx               <= (others => '0');
    zeta_idx(7 - stage_id) <= '1'; -- The "Marker" bit

    if (stage_id > 0) then
      -- Take high bits of counter, reverse them, and place them at the top
      high_bits                       := cnt(7 downto 7 - stage_id);
      zeta_idx(7 downto 7 - stage_id) <= rev_bits(high_bits);
    end if;

  end process;

  -- Indexing the global zetas array
  current_zeta <= to_signed(zetas(to_integer(zeta_idx)), q_len + 1);

  u_butterfly : entity work.ntt_butterfly
    port map (
      clock => clock,
      u_in  => bf_u_in,
      v_in  => bf_v_in,
      zeta  => current_zeta,
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
