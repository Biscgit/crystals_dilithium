library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity power2round is
  port (
    r  : in    polynomial;
    d  : in    coefficient;
    r0 : out   polynomial;
    r1 : out   polynomial
  );
end entity power2round;

architecture a_power2round of power2round is

  signal two_pow_d : coefficient;

  component decompose is
    port (
      r  : in    coefficient;
      a  : in    coefficient;
      r0 : out   coefficient;
      r1 : out   coefficient
    );
  end component decompose;

begin

  two_pow_d <= shift_left(to_signed(1, q_len), to_integer(d));

  test : for i in 0 to polynomial'length generate

    decompose_inst : component decompose
      port map (
        r  => r(i),
        a  => two_pow_d,
        r0 => r0(i),
        r1 => r1(i)
      );

  end generate test;

end architecture a_power2round;
