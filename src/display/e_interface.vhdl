library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity e_interface is
  port (
    sw       : in    std_logic_vector(9 downto 0);
    ledr     : out   std_logic_vector(9 downto 0);
    hex0     : out   std_logic_vector(6 downto 0);
    hex1     : out   std_logic_vector(6 downto 0);
    hex2     : out   std_logic_vector(6 downto 0);
    key      : in    std_logic_vector(3 downto 0);
    clock_50 : in    std_logic
  );
end entity e_interface;

architecture a_interface of e_interface is

  signal slv_selection : natural range 3 downto 0;
  signal slv_start     : std_logic;
  signal slv_cache     : std_logic_vector(1 downto 0);

begin

  ledr <= sw;

  slv_cache(0)  <= not sw(0);
  slv_cache(1)  <= not sw(1);

  slv_selection <= to_integer(unsigned(slv_cache));
  slv_start     <= key(0);

  with slv_selection select hex0 <=
    "0010010" when 1, -- S
    "1000010" when 2, -- G
    "1000110" when 3, -- C
    "0111111" when others;

  with slv_selection select hex1 <=
    "1001111" when 1, -- I
    "0000110" when 2, -- E
    "0001001" when 3, -- H
    "0111111" when others;

  with slv_selection select hex2 <=
    "1000010" when 1, -- G
    "0100100" when 2, -- n
    "0101011" when 3, -- E
    "0111111" when others;

end architecture a_interface;
