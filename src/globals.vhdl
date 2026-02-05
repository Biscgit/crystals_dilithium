library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

package globals is

  -- constants for ML-DSA-87

  constant q     : integer := 8380417;
  constant q_len : integer := 23;
  constant zeta  : integer := 1753;
  constant n     : integer := 256;
  constant k     : integer := 8;
  constant l     : integer := 7;
  constant d     : integer := 13;
  constant ni    : integer := 2;
  constant y1    : integer := 524288;
  constant t     : integer := 60;
  constant b     : integer := t * ni;

  -- types

  subtype coefficient is signed(q_len - 1 downto 0);

  type polynominal is array (n - 1 downto 0) of coefficient;

  type s1 is array (k - 1 downto 0)  of polynominal;

  type s2 is array (l - 1 downto 0)  of polynominal;

  type a_array is array (k - 1 downto 0) of s2;

end package globals;
