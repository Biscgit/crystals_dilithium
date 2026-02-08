library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity ntt_butterfly is
  port (
    clock : in    std_logic;
    u_in  : in    coefficient;
    v_in  : in    coefficient;
    zeta  : in    coefficient;
    u_out : out   coefficient;
    v_out : out   coefficient
  );
end entity ntt_butterfly;

architecture a_ntt_butterfly of ntt_butterfly is

  signal product         : signed(63 downto 0);
  signal prod_times_qinv : signed(127 downto 0);
  signal k_factor        : signed(63 downto 0);
  signal montgomery_out  : signed(31 downto 0);

  signal v_zeta  : coefficient;
  signal sum_raw : signed(q_len + 1 downto 0);
  signal sub_raw : signed(q_len + 1 downto 0);

begin

  -- 1. Montgomery Multiplier (v * zeta)
  product         <= resize(v_in * zeta, 64);
  prod_times_qinv <= product * qinv; -- qinv from globals
  k_factor        <= x"0000_0000" & prod_times_qinv(31 downto 0);

  -- This logic matches your ntt_node exactly
  -- montgomery_out is the result of (product - k_factor * q) >> 32
  process (clock) is

    variable correction : signed(127 downto 0); -- Using a temp for the large product

  begin

    if rising_edge(clock) then
      montgomery_out <= resize((product - k_factor * q) / x"1_0000_0000", 32);
    end if;

  end process;

  v_zeta <= resize(montgomery_out, q_len + 1);

  -- 2. Add/Sub logic
  sum_raw <= resize(u_in, q_len + 2) + resize(v_zeta, q_len + 2);
  sub_raw <= resize(u_in, q_len + 2) - resize(v_zeta, q_len + 2);

  process (clock) is
  begin

    if rising_edge(clock) then
      -- Modulo Reduction for Addition
      if (sum_raw >= q) then
        u_out <= resize(sum_raw - q, q_len + 1);
      elsif (sum_raw < 0) then
        u_out <= resize(sum_raw + q, q_len + 1);
      else
        u_out <= resize(sum_raw, q_len + 1);
      end if;

      -- Modulo Reduction for Subtraction
      if (sub_raw >= q) then
        v_out <= resize(sub_raw - q, q_len + 1);
      elsif (sub_raw < 0) then
        v_out <= resize(sub_raw + q, q_len + 1);
      else
        v_out <= resize(sub_raw, q_len + 1);
      end if;
    end if;

  end process;

end architecture a_ntt_butterfly;
