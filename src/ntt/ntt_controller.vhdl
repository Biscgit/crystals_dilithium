library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity ntt_controller is
  port (
    clock     : in    std_logic;
    input     : in    natural_vector;
    output    : out   natural_vector;
    start_ntt : in    std_logic;
    finished  : out   std_logic
  );
end entity ntt_controller;

architecture a_ntt_controller of ntt_controller is

    component ntt_top_pipelined is
  port (
    clock : in    std_logic;
    start : in    std_logic;
    din   : in    coefficient;
    dout  : out   coefficient;
    done  : out   std_logic
  );
end component ntt_top_pipelined;

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

  -- constant clock_cycles: n + 2

  type t_ntt_state is (s_idle, s_stream_in, s_collect, s_checking, s_done);

  signal slv_ntt_state : t_ntt_state;

  signal slv_computing_done  : std_logic;
  signal slv_vector_input    : natural_vector(input'range);
  signal slv_vector_output   : natural_vector(output'range);
  signal slv_computing_start : std_logic;

  signal slv_ntt_input  : polynomial;
  signal slv_ntt_output : polynomial;

  signal slv_vector_index : natural;
  -- Counters for streaming
  signal coeff_counter   : integer range 0 to 255 := 0;
  signal collect_counter : integer range 0 to 255 := 0;

  signal ntt_din       : coefficient;
  signal ntt_dout      : coefficient;
  signal ntt_start     : std_logic;
  signal ntt_valid_out : std_logic;

begin

  output   <= slv_vector_output;
  finished <= '1' when slv_ntt_state = s_done else
              '0';

  p_ntt_fsm : process (clock, start_ntt) is
  begin

    if rising_edge(clock) then
      slv_computing_start <= '0';

      case slv_ntt_state is

        when s_idle =>

          if (start_ntt = '1') then
            slv_ntt_state     <= s_stream_in;
            slv_vector_input  <= input; -- Store input vector
            slv_vector_index  <= 0;
            coeff_counter     <= 0;
            collect_counter   <= 0;
            slv_vector_output <= (others => (others => (others => '0')));
          end if;

        -- Step 1: Feed 256 coefficients into the NTT pipeline
        when s_stream_in =>

          if (coeff_counter = 0) then
            ntt_start <= '1';
          else
            ntt_start <= '0';
          end if;

          -- Feed the specific coefficient from the current polynomial
          ntt_din <= slv_vector_input(slv_vector_index)(coeff_counter);

          if (coeff_counter < 255) then
            coeff_counter <= coeff_counter + 1;
          else
            -- All 256 sent. Now we wait for the pipeline to finish.
            coeff_counter <= 0;
            slv_ntt_state <= s_collect;
          end if;

        -- Step 2: Catch 256 coefficients as they come out of the pipeline
        when s_collect =>

          if (ntt_valid_out = '1') then
            -- Store arriving coefficient into the current polynomial index
            slv_vector_output(slv_vector_index)(collect_counter) <= ntt_dout;

            if (collect_counter < 255) then
              collect_counter <= collect_counter + 1;
            else
              -- Current Polynomial is completely finished
              collect_counter  <= 0;
              slv_vector_index <= slv_vector_index + 1;
              slv_ntt_state    <= s_checking;
            end if;
          end if;

        when s_checking =>

          -- Note: input'length is 'l' or 'k' (e.g., 7 or 8)
          if (slv_vector_index >= input'length) then
            slv_ntt_state <= s_done;
          else
            -- Reset for next polynomial in the vector
            slv_ntt_state <= s_stream_in;
          end if;

        when s_done =>

          slv_ntt_state <= s_idle;

        when others =>

          slv_ntt_state <= s_idle;

      end case;

    end if;

  end process p_ntt_fsm;

  -- ntt : component ntt_node
  --   generic map (
  --     zeta_expo => n / 2,
  --     size      => n
  --   )
  --   port map (
  --     clock      => clock,
  --     a          => slv_ntt_input,
  --     ntt_a      => slv_ntt_output,
  --     slv_active => slv_computing_start,
  --     slv_done   => slv_computing_done
  --   );

  new_ntt : component ntt_top_pipelined
    port map (
      clock     => clock,
      start     => ntt_start,
      din       => ntt_din,
      dout      => ntt_dout,
      done => ntt_valid_out 
    );

end architecture a_ntt_controller;
