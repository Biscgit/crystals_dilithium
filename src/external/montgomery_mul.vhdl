-- Entity name: montgomery_multiplier
-- Author: Stephen Carter
-- Contact: stephen.carter@mail.mcgill.ca
-- Date: March 10th, 2016
-- Description: Performs modular multiplication. See paper for more information. Designed for use with RSA Encryption.

-- Modified by:
-- Author: David Horvát
-- Contact: horvatda@proton.me

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity montgomery_multiplier is
  generic (
    width_in : integer := 8
  );
  port (
    a          : in    unsigned(width_in - 1 downto 0);
    b          : in    unsigned(width_in - 1 downto 0);
    n          : in    unsigned(width_in - 1 downto 0);
    latch      : in    std_logic;
    clk        : in    std_logic;
    data_ready : out   std_logic;
    m          : out   unsigned(width_in - 1 downto 0)
  );
end entity montgomery_multiplier;

architecture behavioral of montgomery_multiplier is

  -- Signals
  signal m_temp  : unsigned(width_in + 1 downto 0) := (others => '0');
  signal state   : integer                         := 0;
  signal count   : integer                         := 0;
  signal b_reg   : unsigned(width_in - 1 downto 0) := (others => '0');
  signal a_reg   : unsigned(width_in - 1 downto 0) := (others => '0');
  signal b_zeros : unsigned(width_in - 1 downto 0) := (others => '0');
  signal n_temp  : unsigned(width_in - 1 downto 0);

begin

  -- Process to perform mod mult operation
  compute_m : process (clk, latch) is
  begin

    if rising_edge(clk) then

      case state is

        when 0 =>

          -- latch data when latch high
          if (latch = '1') then
            data_ready <= '0';
            m_temp     <= (others => '0');
            count      <= 0;
            b_reg      <= b;
            a_reg      <= a;
            n_temp     <= n;
            state      <= 1;
          end if;

        when 1 =>

          -- perform appropriate add and shift
          -- check to see if we add B or not
          if (a_reg(0) = '1') then
            -- check to see if we add N and B
            if ((m_temp(0) xor b_reg(0)) = '1') then
              m_temp <= unsigned(shift_right(unsigned(m_temp + b_reg + n), integer(1)));
            else
              m_temp <= unsigned(shift_right(unsigned(m_temp + b_reg), integer(1)));
            end if;
          else
            -- check to see if we need to add modulus
            if (m_temp(0) = '1') then
              m_temp <= unsigned(shift_right(unsigned(m_temp + n), integer(1)));
            else
              m_temp <= unsigned(shift_right(unsigned(m_temp), integer(1)));
            end if;
          end if;
          -- check to see if multiply is complete
          if (n_temp = to_unsigned(integer(1), width_in)) then
            state <= 2;
          else
            state <= 1;
          end if;
          -- Update the A and N value used to update values
          n_temp <= unsigned(shift_right(unsigned(n_temp), integer(1)));
          a_reg  <= unsigned(shift_right(unsigned(a_reg), integer(1)));

        when 2 =>

          -- update output values and return to default state
          if (m_temp > n) then
            m <= m_temp(width_in - 1 downto 0) - n;
          else
            m <= m_temp(width_in - 1 downto 0);
          end if;
          data_ready <= '1';
          state      <= 0;

        when others =>

          state <= 0;

      end case;

    end if;

  end process compute_m;

end architecture behavioral;
