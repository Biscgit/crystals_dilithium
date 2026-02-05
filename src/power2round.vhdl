library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity power2round is
  port (
    r  : in    polynominal;
    d  : in    signed(18 downto 0);
    r0 : out   polynominal;
    r1 : out   polynominal
  );
end entity power2round;

architecture a_power2round of power2round is

  signal d_squared : signed(18 downto 0);

  component decompose is
    port (
      r  : in    signed(18 downto 0);
      a  : in    signed(18 downto 0);
      r0 : out   signed(18 downto 0);
      r1 : out   signed(18 downto 0)
    );
  end component decompose;

begin

  d_squared <= "10" srl to_integer(d);

  test : for i in 0 to polynominal'length generate

    decompose_inst : component decompose
      port map (
        r  => r(i),
        a  => d_squared,
        r0 => r0(i),
        r1 => r1(i)
      );

  end generate test;

end architecture a_power2round;
