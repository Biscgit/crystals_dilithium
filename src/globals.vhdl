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
  constant n      : integer := 256;
  constant qinv   : integer := 58728449;

  -- generictypes

  subtype modq_t is integer range 0 to q - 1;

  subtype coefficient is signed(q_len - 1 downto 0);

  subtype small_coefficient is signed(eta downto 0);

  subtype y1_coefficient is signed(y1_len downto 0);

  type natural_polynomial is array (natural range <>) of coefficient;

  subtype polynomial is natural_polynomial (n - 1 downto 0);

  type small_polynominal is array (n - 1 downto 0) of small_coefficient;

  type y2_polynominal is array (n - 1 downto 0) of y1_coefficient;

  -- Key Gen

  type s1 is array (l - 1 downto 0)  of small_polynominal;

  type s2 is array (k - 1 downto 0)  of small_polynominal;

  type vector is array (l - 1 downto 0)  of polynomial;

  type a_array is array (k - 1 downto 0) of vector;

  type t is array (l - 1 downto 0) of polynomial;

  -- Signing

  type y is array (l - 1 downto 0) of y2_polynominal;

  type w is array (k - 1 downto 0) of polynomial;

  type z is array (l - 1 downto 0) of polynomial;

-- Verification

end package globals;
