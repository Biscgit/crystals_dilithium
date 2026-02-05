library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity ntt_node is
  generic (
    zeta_expo : natural;
    depth : natural;
    size: natural
  );
  port(
    a : in natural_polynom(size - 1 downto 0);
    ntt_a : out natural_polynom(size - 1 downto 0)
  );
end entity ntt_node;

architecture a_ntt_node of ntt_node is

    type te is array (size-1 downto 0) of signed(3*q_len-1 downto 0);
  constant zeta_pow : modq_t := (zeta ** zeta_expo) mod q;
  signal sub_a1_temp: te;
  signal sub_a0_temp: te;
  signal sub_a1: natural_polynom((size/2)-1 downto 0);
  signal sub_a0: natural_polynom((size/2)-1 downto 0);

  signal test1: natural_polynom((size/2)-1 downto 0);
  signal test2: natural_polynom((size/2)-1 downto 0);


  component ntt_node is
  generic (
    zeta_expo : natural;
    depth : natural;
    size: natural
  );
  port(
    a : in natural_polynom(size -1 downto 0);
    ntt_a : out natural_polynom(size - 1 downto 0)
  );
  end component ntt_node;

begin

    test: if (depth > 0) generate
        calc_a1: for i in 0 to size/2-1 generate
            sub_a1_temp(i) <= ("000" & x"00000" & a(i) - ("000" & x"00000" & a((size/2) + i) * zeta_pow))mod q;
            sub_a0_temp(i) <= ("000" & x"00000" & a(i) + ("000" & x"00000" & a((size/2) + i) * zeta_pow))mod q;
            sub_a0(i) <= sub_a0_temp(i)(q_len-1 downto 0);
            sub_a1(i) <= sub_a1_temp(i)(q_len-1 downto 0);
        end generate;

        right_node: ntt_node generic map (zeta_expo/2, depth -1, size/2) port map(a((size/2)-1 downto 0), test1);
        left_node: ntt_node generic map (zeta_expo/2 + n/2, depth -1, size/2) port map(a(size-1 downto (size/2)), test2);

        ntt_a <= test1 & test2;

    end generate;
    test3: if (depth = 0) generate
            ntt_a <= a;
    end generate;


end architecture a_ntt_node;
