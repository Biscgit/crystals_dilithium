library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity ntt_controller is
  port (
    clock     : in    std_logic;
    input     : in    polynomial;
    output    : out   polynomial;
    start_ntt : in    std_logic;
    finished  : out   std_logic
  );
end entity ntt_controller;

architecture a_ntt_controller of ntt_controller is

  component ntt_node is
    generic (
      zeta_expo : natural;
      size      : natural
    );
    port (
      clock      : in    std_logic;
      a          : in    natural_polynomial(size - 1 downto 0);
      ntt_a      : out   natural_polynomial(size - 1 downto 0);
      slv_active : in    std_logic;
      slv_done   : out   std_logic
    );
  end component ntt_node;

  type t_ntt_state is (s_idle, s_computing, s_propagation, s_done);

  signal slv_ntt_state : t_ntt_state;

  signal slv_computing_done  : std_logic;
  signal slv_polynomial      : polynomial;
  signal slv_computing_start : std_logic;

begin
    finished <= '1' when slv_ntt_state = s_done else '0';

  p_ntt_fsm : process (clock, start_ntt) is
  begin

    if rising_edge(clock) then
      if (slv_ntt_state = s_idle) then
        -- activate circuit when in s_idle
        if (start_ntt = '1') then
          slv_ntt_state       <= s_computing;
          slv_polynomial      <= input;             -- store input
          slv_computing_start <= '1';
        end if;
      -- s_computing ntt
      elsif (slv_ntt_state = s_computing) then
        slv_computing_start <= '0';
        if (slv_computing_done = '1') then
          slv_ntt_state <= s_propagation;
        end if;
      -- propagating result back up
      elsif (slv_ntt_state = s_propagation) then
        slv_ntt_state <= s_done;
      -- signaling that result can now be read
      elsif (slv_ntt_state = s_done) then
        slv_ntt_state <= s_idle;
      -- set to s_idle on default
      else
        slv_ntt_state <= s_idle;
      end if;
    end if;

  end process p_ntt_fsm;

  ntt : component ntt_node
    generic map (
      zeta_expo => n / 2,
      size      => n
    )
    port map (
      clock      => clock,
      a          => slv_polynomial,
      ntt_a      => output,
      slv_active => slv_computing_start,
      slv_done   => slv_computing_done
    );

end architecture a_ntt_controller;
