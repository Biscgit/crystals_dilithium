library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;
  use work.zeta_lut.all;

entity ntt_top_pipelined is
  port (
    clock : in    std_logic;
    start : in    std_logic;
    din   : in    coefficient;
    dout  : out   coefficient;
    done  : out   std_logic
  );
end entity ntt_top_pipelined;

architecture a_ntt_top_pipelined of ntt_top_pipelined is

  signal counter : unsigned(7 downto 0) := (others => '0');
  signal active  : std_logic            := '0';

  -- Wires between stages

  type t_pipe_wire is array (0 to 8) of coefficient;

  signal pipe : t_pipe_wire;

  -- Zeta ROM lookup (This uses your inv_mont_reduce(zeta**i) logic)

  function get_zeta_idx (
    s : integer;
    c : unsigned
  ) return integer is

    variable base   : integer;
    variable offset : integer;

  begin

    base := 2 ** s;

    if (s = 0) then
      return 1;
    else
      -- Extract the bits from the counter to find the current zeta in the stage
      return base + to_integer(c(7 downto 8 - s));
    end if;

  end function get_zeta_idx;

begin

  process (clock) is
  begin

    if rising_edge(clock) then
      if (start = '1') then
        active  <= '1';
        counter <= (others => '0');
      elsif (active = '1') then
        counter <= counter + 1;
      end if;
    end if;

  end process;

  pipe(0) <= din;

  -- Generate 8 stages for N=256 (2^8)

  gen_stages : for i in 0 to 7 generate
    signal stage_zeta : coefficient;
  begin
    -- Get the zeta for this specific stage and current counter position
    -- stage_zeta <= zetas(get_zeta_idx(i, counter));

    u_stage : entity work.ntt_sdf_stage
      generic map (
        delay    => 2 ** (7 - i),
        stage_id => i
      )
      port map (
        clock => clock,
        en    => active,
        cnt   => counter,
        zeta  => to_signed(zetas(get_zeta_idx(i, counter)), q_len + 1),
        din   => pipe(i),
        dout  => pipe(i + 1)
      );

  end generate gen_stages;

  dout <= pipe(8);
  done <= '1' when counter = 255 else
          '0';

end architecture a_ntt_top_pipelined;
