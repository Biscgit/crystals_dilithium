library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;
  use work.zeta_lut.all;

entity ntt_node is
  generic (
    zeta_expo : natural;
    size      : natural
  );
  port (
    clock      : in    std_logic;
    a          : in    natural_polynomial(2 * size - 1 downto 0);
    ntt_a      : out   natural_polynomial(2 * size - 1 downto 0);
    slv_active : in    std_logic;
    slv_done   : out   std_logic
  );
end entity ntt_node;

architecture a_ntt_node of ntt_node is

  constant zeta_pow : modq_t := zetas(zeta_expo);

  signal proc_a : natural_polynomial(2 * size - 1 downto 0);

  component ntt_node is
    generic (
      zeta_expo : natural;
      size      : natural
    );
    port (
      clock      : in    std_logic;
      a          : in    natural_polynomial(2 * size - 1 downto 0);
      ntt_a      : out   natural_polynomial(2 * size - 1 downto 0);
      slv_active : in    std_logic;
      slv_done   : out   std_logic
    );
  end component ntt_node;

  function mod_add (
    a,
    b: signed
  ) return signed is
  begin

    return resize((a + b) mod q, q_len);

  end function mod_add;

  function mod_sub (
    a,
    b: signed
  ) return signed is
  begin

    return resize((a - b) mod q, q_len);

  end function mod_sub;

  signal right_done : std_logic;
  signal left_done  : std_logic;

begin

  normal_node : if (size > 1) generate
    signal sub_a1 : natural_polynomial((size) - 1 downto 0);
    signal sub_a0 : natural_polynomial((size) - 1 downto 0);

    signal rigth_result : natural_polynomial(size - 1 downto 0);
    signal left_result  : natural_polynomial(size - 1 downto 0);

    signal right_active : std_logic;
    signal left_active  : std_logic;
  begin

    p_ntt_step : process (clock) is
    begin

      if rising_edge(clock) then
        right_active <= '0';
        left_active  <= '0';

        if (slv_active = '1') then
          proc_a       <= a;
          right_active <= '1';
          left_active  <= '1';
        end if;
      end if;

    end process p_ntt_step;

    calc_a1 : for i in 0 to size - 1 generate
      signal prod : signed(q_len * 2 - 1 downto 0);
    begin
      prod <= resize(proc_a(size + i) * zeta_pow, prod'length);

      sub_a0(i) <= mod_add(proc_a(i), prod);
      sub_a1(i) <= mod_sub(proc_a(i), prod);
    end generate calc_a1;

    right_node : component ntt_node
      generic map (
        zeta_expo => zeta_expo / 2, size => size / 2
      )
      port map (
        clock      => clock,
        a          => sub_a0,
        ntt_a      => rigth_result,
        slv_active => right_active,
        slv_done   => right_done
      );

    left_node : component ntt_node
      generic map (
        zeta_expo => zeta_expo / 2 + n / 2, size => size / 2
      )
      port map (
        clock      => clock,
        a          => sub_a1,
        ntt_a      => left_result,
        slv_active => left_active,
        slv_done   => left_done
      );

    ntt_a    <= rigth_result & left_result;
    slv_done <= right_done and left_done;

  end generate normal_node;

  leaf_node : if (size = 1) generate
    ntt_a    <= proc_a;
    slv_done <= slv_active;
  end generate leaf_node;

end architecture a_ntt_node;
