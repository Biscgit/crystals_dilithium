library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity polynomial_element_mul is
  port (
    clock                : in    std_logic;
    start_multiplication : in    std_logic;
    input_a              : in    natural_polynomial;
    input_b              : in    natural_polynomial;
    output               : out   natural_polynomial;
    finished             : out   std_logic
  );
end entity polynomial_element_mul;

architecture a_polynomial_element_mul of polynomial_element_mul is

  component montgomery_multiplier is
    generic (
      width_in : integer := q_len
    );
    port (
      a          : in    unsigned(width_in - 1 downto 0);
      b          : in    unsigned(width_in - 1 downto 0);
      n          : in    unsigned(width_in - 1 downto 0);
      latch      : in    std_logic;
      clk        : in    std_logic;
      data_ready : out   std_logic;
      m          : out   unsigned(width_in - 1 downto 0)
    );
  end component montgomery_multiplier;

  type t_state is (idle, computing, check, done);

  signal slv_state : t_state;
  signal slv_index : natural;

  signal slv_cache               : natural_polynomial(output'range);
  signal slv_start_montgomery    : std_logic;
  signal slv_finished_montgomery : std_logic;

  signal slv_mongomery_result   : unsigned(q_len - 1 downto 0);
  signal slv_montomgery_input_a : unsigned(q_len - 1 downto 0);
  signal slv_montomgery_input_b : unsigned(q_len - 1 downto 0);

begin

  output <= slv_cache;

  slv_montomgery_input_a <= resize(unsigned(input_a(slv_index)), q_len);
  slv_montomgery_input_b <= resize(unsigned(input_b(slv_index)), q_len);

  c_montgomery_mul : component montgomery_multiplier
    port map (
      a          => slv_montomgery_input_a,
      b          => slv_montomgery_input_b,
      n          => to_unsigned(q, q_len),
      latch      => slv_start_montgomery,
      clk        => clock,
      data_ready => slv_finished_montgomery,
      m          => slv_mongomery_result
    );

  p_compute_mul : process (clock, slv_state, start_multiplication) is
  begin

    if rising_edge(clock) then
      finished <= '0';
      --
      if (slv_state = idle) then
        -- activate circuit when in s_idle
        if (start_multiplication = '1') then
          slv_state <= computing;
          slv_index <= 0;

          slv_start_montgomery <= '1';
        end if;
      --
      elsif (slv_state = computing) then
        if (slv_finished_montgomery = '1') then
          slv_state <= check;
        end if;
      --
      elsif (slv_state = check) then
        slv_cache(slv_index) <= signed(slv_mongomery_result);
        if (slv_index >= output'length - 1) then
          slv_state <= done;
        else
          slv_state <= computing;
          slv_index <= slv_index + 1;
        end if;
      --
      elsif (slv_state = done) then
        finished  <= '1';
        slv_state <= idle;
      --
      else
        slv_state <= idle;
      end if;
    end if;

  end process p_compute_mul;

end architecture a_polynomial_element_mul;
