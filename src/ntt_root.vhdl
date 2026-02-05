library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity ntt_root is
  port (
    clock    : in    std_logic;
    a        : in    polynomial;
    ntt_a    : out   polynomial;
    finished : out   std_logic
  );
end entity ntt_root;

architecture a_ntt_root of ntt_root is

  component ntt_node is
    generic (
      zeta_expo : natural;
      depth     : natural;
      size      : natural
    );
    port (
      clock   : in    std_logic;
      counter : in    natural;
      a       : in    natural_polynomial(size - 1 downto 0);
      ntt_a   : out   natural_polynomial(size - 1 downto 0)
    );
  end component ntt_node;

  component countdown_clock is
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
  end component countdown_clock;

  signal proc_a  : polynomial;
  signal counter : natural;

begin

  count : component countdown_clock
    generic map (
      counter_limit => ntt_tree_depth
    )
    port map (
      slv_clock           => clock,
      slv_counter_enabled => '1',
      slv_reset           => '0',
      slv_write           => '0',
      slv_output          => finished,
      slv_counter_in      => 0,
      slv_counter_out     => counter
    );

  p_ntt : process (clock) is
  begin

    if rising_edge(clock) then
      proc_a <= a;
    end if;

  end process p_ntt;

  ntt : component ntt_node
    generic map (
      zeta_expo => n,
      depth     => ntt_tree_depth,
      size      => n
    )
    port map (
      clock   => clock,
      counter => 8,
      a       => proc_a,
      ntt_a   => ntt_a
    );

end architecture a_ntt_root;
