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
    a          : in    natural_polynomial(size - 1 downto 0);
    ntt_a      : out   natural_polynomial(size - 1 downto 0);
    slv_active : in    std_logic;
    slv_done   : out   std_logic
  );
end entity ntt_node;

architecture a_ntt_node of ntt_node is

  constant zeta_pow : modq_t := zetas(zeta_expo);

  signal proc_a : natural_polynomial(size - 1 downto 0) := (others => (others => '0'));
  signal temp_a : signed(2 * q_len - 1 downto 0);

  component ntt_node is
    generic (
      zeta_expo : natural;
      size      : natural
    );
    port (
      clock      : in    std_logic;
      a          : in    natural_polynomial(size - 1 downto 0);
      ntt_a      : out   natural_polynomial(size - 1 downto 0);
      slv_active : in    std_logic;
      slv_done   : out   std_logic
    );
  end component ntt_node;

  component mod_add is
    port (
      a   : in    coefficient;
      b   : in    signed(32 - 1 downto 0);
      sum : out   coefficient
    );
  end component mod_add;

  component mod_sub is
    port (
      a    : in    coefficient;
      b    : in    signed(32 - 1 downto 0);
      diff : out   coefficient
    );
  end component mod_sub;

  signal right_done : std_logic;
  signal left_done  : std_logic;

begin

  normal_node : if (size > 1) generate
    signal sub_a1 : natural_polynomial(size / 2 - 1 downto 0) := (others => (others => '0'));
    signal sub_a0 : natural_polynomial(size / 2 - 1 downto 0) := (others => (others => '0'));

    signal right_result : natural_polynomial(size / 2 - 1 downto 0);
    signal left_result  : natural_polynomial(size / 2 - 1 downto 0);

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

    calc_a1 : for i in 0 to size / 2 - 1 generate
      signal product         : signed(q_len * 2 downto 0) := (others => '0');
      signal prod_times_qinv : signed(product'length * 2 - 1 downto 0) := (others => '0');
      signal k_factor        : signed(64 - 1 downto 0) := (others => '0');
      signal correction_term : signed(k_factor'length * 2 - 1 downto 0) := (others => '0');
      signal montgomery_out  : signed(32 - 1 downto 0) := (others => '0');
    begin
      product         <= resize(proc_a(size / 2 + i) * to_signed(zeta_pow, q_len + 1), product'length);
      prod_times_qinv <= product * qinv;
      k_factor        <= x"0000_0000" & prod_times_qinv(31 downto 0);
      correction_term <= (product - k_factor * q);
      montgomery_out  <= correction_term(64 - 1 downto 32);

      compute_a0 : component mod_add
        port map (
          a   => proc_a(i),
          b   => montgomery_out,
          sum => sub_a0(i)
        );

      compute_a1 : component mod_sub
        port map (
          a    => proc_a(i),
          b    => montgomery_out,
          diff => sub_a1(i)
        );

    end generate calc_a1;

    left_node : component ntt_node
      generic map (
        zeta_expo => zeta_expo / 2, size => size / 2
      )
      port map (
        clock      => clock,
        a          => sub_a0,
        ntt_a      => left_result,
        slv_active => left_active,
        slv_done   => left_done
      );

    right_node : component ntt_node
      generic map (
        zeta_expo => zeta_expo / 2 + n / 2, size => size / 2
      )
      port map (
        clock      => clock,
        a          => sub_a1,
        ntt_a      => right_result,
        slv_active => right_active,
        slv_done   => right_done
      );

    ntt_a    <= left_result & right_result;
    slv_done <= right_done and left_done;

  end generate normal_node;

  leaf_node : if (size = 1) generate

    p_ntt_step : process (clock) is
    begin

      if rising_edge(clock) then
        if (slv_active = '1') then
          proc_a <= a;
        end if;
      end if;

    end process p_ntt_step;

    -- temp_a <= (proc_a(0) * zeta_pow) mod q;
    -- ntt_a(0) <= resize(temp_a, q_len);
    ntt_a(0) <= proc_a(0);
    slv_done <= slv_active;
  end generate leaf_node;

end architecture a_ntt_node;
