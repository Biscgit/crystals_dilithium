library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity mod_sub is
  port (
    a    : in    coefficient;
    b    : in    signed(32 - 1 downto 0);
    diff : out   coefficient
  );
end entity mod_sub;

architecture a_mod_sub of mod_sub is

  signal   tmp        : signed(32 - 1 downto 0) := (others => '0');
  signal   adjustment : signed(32 downto 0);
  constant q_signed   : coefficient             := to_signed(q, q_len + 1);

begin

  -- compute difference
  tmp <= a - b;

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

  diff <= resize(tmp + adjustment, diff'length);

end architecture a_mod_sub;
