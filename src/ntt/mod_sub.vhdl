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

  signal   tmp      : signed(32 - 1 downto 0) := (others => '0');
  constant q_signed : coefficient := to_signed(q, q_len+1);

begin

  -- compute difference
  tmp <= a - b;

  -- add q if negative
  diff <= resize(tmp + q_signed, q_len+1) when tmp < 0 else
          resize(tmp, q_len+1);

end architecture a_mod_sub;
