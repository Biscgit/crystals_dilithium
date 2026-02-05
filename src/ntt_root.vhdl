library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity ntt_root is
  port (
    a     : in    polynominal;
    ntt_a : out   polynominal
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
      a     : in    natural_polynom(size - 1 downto 0);
      ntt_a : out   natural_polynom(size - 1 downto 0)
    );
  end component ntt_node;

begin

  ntt : component ntt_node
    generic map (
      zeta_expo => 256,
      depth     => 8,
      size      => 256
    )
    port map (
      a     => a,
      ntt_a => ntt_a
    );

end architecture a_ntt_root;
