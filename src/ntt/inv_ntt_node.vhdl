library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;
  use work.zeta_lut.all;

entity inv_ntt_node is
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
end entity inv_ntt_node;

architecture a_inv_ntt_node of ntt_node is

  constant zeta_pow : modq_t := zetas(zeta_expo);

  signal proc_a : natural_polynomial(size - 1 downto 0);

  component inv_ntt_node is
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
  end component inv_ntt_node;

  function mod_add (
    a,
    b : signed
  ) return signed is
  begin

    return resize((a + b) mod q, q_len);

  end function mod_add;

  function mod_sub (
    a,
    b : signed
  ) return signed is
  begin

    return resize((a - b) mod q, q_len);

  end function mod_sub;

begin

  p_ntt_step : process (clock) is
  begin

    if rising_edge(clock) then
      if (counter = depth) then
        proc_a <= a;
      end if;
    end if;

  end process p_ntt_step;

  normal_node : if (size > 1) generate
    signal rigth_result : natural_polynomial((size / 2) - 1 downto 0);
    signal left_result  : natural_polynomial((size / 2) - 1 downto 0);

    signal rigth_a : natural_polynomial((size / 2) - 1 downto 0);
    signal left_a  : natural_polynomial((size / 2) - 1 downto 0);
  begin

    left_node : component inv_ntt_node
      generic map (
        zeta_expo => zeta_expo / 2, depth => depth - 1, size => size / 2
      )
      port map (
        clock   => clock,
        counter => counter,
        a       => proc_a(size / 2 - 1 downto 0),
        ntt_a   => left_result
      );

    right_node : component inv_ntt_node
      generic map (
        zeta_expo => zeta_expo / 2 + n / 2, depth => depth - 1, size => size / 2
      )
      port map (
        clock   => clock,
        counter => counter,
        a       => proc_a(size - 1 downto size / 2),
        ntt_a   => rigth_result
      );

    calc_a1 : for i in 0 to size - 1 generate
      left_a(i)  <= mod_add(left_result(i), rigth_result(i));
      rigth_a(i) <= (mod_sub(left_result(i), rigth_result(i)) * zeta_pow) mod q;
    end generate calc_a1;

    ntt_a <= left_a & rigth_a;

  end generate normal_node;

  leaf_node : if (size = 1) generate
    ntt_a <= proc_a;
  end generate leaf_node;

end architecture a_inv_ntt_node;
