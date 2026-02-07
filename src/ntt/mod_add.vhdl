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

  signal   tmp      : signed(32 downto 0) := (others => '0');
  constant q_signed : coefficient := to_signed(q, q_len+1);

begin

  -- compute sum
  tmp <= resize(a, 33) + resize(b, 33);

  -- subtract q if overflow
  sum <= resize(tmp - q_signed, q_len+1) when tmp >= q_signed else
         resize(tmp, q_len+1);

end architecture a_mod_add;
