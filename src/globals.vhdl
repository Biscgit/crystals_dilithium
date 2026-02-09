library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

package globals is

  -- constants for ML-DSA-87

  constant q      : integer := 8380417;
  constant q_len  : integer := 23;
  constant zeta   : integer := 1753;
  constant d      : integer := 13;
  constant tau    : integer := 60;
  constant lambda : integer := 256;
  constant y1     : integer := 524288; -- 2**19
  constant y1_len : integer := 20;
  constant y2     : integer := (q - 1) / 32;
  constant k      : integer := 8;
  constant l      : integer := 7;
  constant eta    : integer := 2;
  constant beta   : integer := tau * eta;
  constant omega  : integer := 75;
  constant n      : integer := 16;
  constant qinv   : integer := 58728449;

  -- generictypes

  subtype modq_t is integer range q - 1 downto 0;

  subtype coefficient is signed(q_len downto 0);

  subtype mul_coefficient is signed(coefficient'length * 2 - 1 downto 0);

  -- subtype small_coefficient is signed(eta downto 0);

  subtype y1_coefficient is signed(y1_len downto 0);

  type natural_polynomial is array (natural range <>) of coefficient;

  subtype polynomial is natural_polynomial(n - 1 downto 0);

  -- type small_polynominal is array (n - 1 downto 0) of small_coefficient;

  type y2_polynomial is array (n - 1 downto 0) of y1_coefficient;

  -- Key Gen

  type natural_vector is array (natural range <>) of polynomial;

  subtype s1 is natural_vector(l - 1 downto 0);

  subtype s2 is natural_vector(k - 1 downto 0);

  subtype vector is natural_vector (l - 1 downto 0);

  subtype t is natural_vector(k - 1 downto 0);

  type natural_matrix is array(natural range <>, natural range <>) of polynomial;

  subtype t_a_matrix is natural_matrix(k - 1 downto 0, l - 1 downto 0);

  -- type natural_array is array (natural range <>) of vector;

  -- subtype a_array is natural_array(k - 1 downto 0);

  -- Signing

  subtype y is natural_vector (l - 1 downto 0);

  subtype w is natural_vector(k - 1 downto 0);

  subtype z is natural_vector (l - 1 downto 0);

  type m is array (natural range <>) of std_logic_vector(63 downto 0);

-- Verification

end package globals;
