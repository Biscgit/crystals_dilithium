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

  attribute preserve : boolean;
  attribute preserve of key_gen : label is true;

  component e_key_generation is
    port (
      clock            : in    std_logic;
      matrix_a         : in    t_a_matrix;
      vector_s1        : in    s1;
      vector_s2        : in    s2;
      vector_t         : out   t;
      start_generation : in    std_logic;
      has_finished     : out   std_logic
    );
  end component e_key_generation;

  -- signal a : polynomial := (others => (others => '1'));
  signal slv_state_gen : std_logic;

  signal slv_var   : std_logic;
  signal slv_res   : std_logic;
  signal slv_res_2 : std_logic;

  signal v_1 : t_a_matrix;
  signal v_2 : s1;
  signal v_3 : s2;
  signal v_4 : t;

begin

  slv_state_gen <= not sw(0);
  ledr(2)       <= v_4(0)(1)(1);

  ledr(0) <= slv_res and sw(1);

  process (clock_50) is
  begin

    if rising_edge(clock_50) then
      v_1 <= (others => (others => (others => (others => '0'))));

      if (sw(2) = '1') then
        v_1(0, 0)(0)(0) <= '1';
        v_1(0, 0)(0)(1) <= '0';
      else
        v_1(0, 0)(0)(0) <= '0';
        v_1(0, 0)(0)(1) <= '1';
      end if;

      v_2 <= (others => (others => (others => '0')));

      if (sw(3) = '1') then
        v_2(0)(0)(0) <= '1';
        v_2(0)(0)(1) <= '0';
      else
        v_2(0)(0)(0) <= '0';
        v_2(0)(0)(1) <= '1';
      end if;

      v_3 <= (others => (others => (others => '0')));

      if (sw(4) = '1') then
        v_3(0)(0)(0) <= '1';
        v_3(0)(0)(1) <= '0';
      else
        v_3(0)(0)(0) <= '0';
        v_3(0)(0)(1) <= '1';
      end if;
    end if;

  end process;

  key_gen : component e_key_generation
    port map (
      clock            => clock_50,
      matrix_a         => v_1gb,
      vector_s1        => v_2,
      vector_s2        => v_3,
      vector_t         => v_4,
      start_generation => slv_state_gen,
      has_finished     => slv_res
    );

end architecture a_crystals_dilithium;
