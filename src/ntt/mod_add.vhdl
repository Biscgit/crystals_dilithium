library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity mod_add is
  port (
    a   : in    coefficient;
    b   : in    signed(32 - 1 downto 0);
    sum : out   coefficient
  );
end entity mod_add;

architecture a_mod_add of mod_add is

  signal   tmp        : signed(32 downto 0) := (others => '0');
  signal   adjustment : signed(32 downto 0);
  constant q_signed   : coefficient         := to_signed(q, q_len + 1);

begin

  -- compute sum
  tmp <= resize(a, 33) + resize(b, 33);

  process (tmp) is
  begin

    if (tmp >= q_signed) then
      adjustment <= -resize(q_signed, 33);       -- Need to subtract Q
    elsif (tmp < 0) then
      adjustment <= resize(q_signed, 33);        -- Need to add Q
    else
      adjustment <= (others => '0');             -- No change needed
    end if;

  end process;

  -- Adder 2: Apply the correction (~17 ALMs)
  sum <= resize(tmp + adjustment, sum'length);

end architecture a_mod_add;
