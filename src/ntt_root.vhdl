library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity ntt_root is
  port (
    clock : in    std_logic;
    a     : in    polynomial;
    ntt_a : out   polynomial
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

  signal proc_a : polynomial;

begin

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
