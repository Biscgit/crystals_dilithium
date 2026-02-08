library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity e_crystals_dilithium is
  port (
    clock_50 : in    std_logic;
    sw       : in    std_logic_vector(9 downto 0);
    ledr     : out   std_logic_vector(9 downto 0)
  );
end entity e_crystals_dilithium;

architecture a_crystals_dilithium of e_crystals_dilithium is

  component e_key_generation is
    port (
      clock            : in    std_logic;
      matrix_a         : in    a_array; -- a is already in ntt form
      vector_s1        : in    s1;
      vector_s2        : in    s2;
      vector_t         : out   t;
      start_generation : in    std_logic;
      has_finished     : out   std_logic
    );
  end component e_key_generation;

  -- signal a : polynomial := (others => (others => '1'));
  signal slv_state_gen: std_logic;
begin
    slv_state_gen <= not SW(0);

  key_gen:  component e_key_generation
  port map(
    clock            => clock_50,
    matrix_a         => (others => (others => (others => (others => '0')))),
    vector_s1        => (others => (others => (others => '0'))),
    vector_s2        => (others => (others => (others => '0'))),
    vector_t         => open,
    start_generation => slv_state_gen,
    has_finished     => ledr(0)
  );

end architecture a_crystals_dilithium;
