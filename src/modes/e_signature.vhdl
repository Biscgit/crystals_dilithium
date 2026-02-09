library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.globals.all;

entity e_signature is
  port (
    clock         : in    std_logic;
    matrix_a      : in    a_array;
    vector_s1     : in    s1;
    vector_s2     : in    s1;
    message       : in    m;
    start_signing : in    std_logic;
    has_finished  : out   std_logic;
    hash          : out   std_logic_vector(63 downto 0);
    signature     : out   z
  );
end entity e_signature;

architecture a_signature of e_signature is

  component matrix_mul_vector is
    port (
      clock        : in    std_logic;
      input_matrix : in    a_array;
      input_vector : in    s1;
      output       : out   s2;
      start_mul    : in    std_logic;
      finished     : out   std_logic
    );
  end component matrix_mul_vector;

  component vector_add_vector is
    port (
      input_vector1 : in    natural_vector;
      input_vector2 : in    natural_vector;
      output        : out   natural_vector
    );
  end component vector_add_vector;

  component vector_mul_number is
    generic (
      size : natural
    );
    port (
      input_vector : in    natural_vector;
      input_number : in    std_logic_vector(size - 1 downto 0);
      output       : out   natural_vector;
      start_mul    : in    std_logic;
      finished     : out   std_logic
    );
  end component vector_mul_number;

  component keccak is
    port (
      clk         : in    std_logic;
      rst_n       : in    std_logic;
      start       : in    std_logic;
      din         : in    std_logic_vector(63 downto 0);
      din_valid   : in    std_logic;
      buffer_full : out   std_logic;
      last_block  : in    std_logic;
      ready       : out   std_logic;
      dout        : out   std_logic_vector(63 downto 0);
      dout_valid  : out   std_logic
    );
  end component keccak;

  component decompose is
    port (
      r  : in    natural_polynomial;
      a  : in    natural;
      r0 : out   natural_polynomial;
      r1 : out   natural_polynomial
    );
  end component decompose;

  type t_sign_state is (
    s_idle,
    s_compute_y,
    s_computing_w,
    s_start_hashing,
    s_wait_for_hashing,
    s_write_hash_buffer,
    s_compute_c,
    s_read_c,
    s_compute_c_s1,
    s_compute_c_s2,
    s_compute_check,
    s_verify,
    s_compute_z,
    s_done
  );

  signal slv_state : t_sign_state;

  signal slv_matrix_a      : a_array;
  signal slv_vector_s1     : s1;
  signal slv_vector_s2     : s2;
  signal slv_vector_result : t;
  signal slv_message       : m;

  signal message_index : integer := 0;

  signal slv_vector_y    : y;
  signal slv_vector_w    : w;
  signal slv_vector_w1   : w;
  signal slv_c           : std_logic_vector(63 downto 0);
  signal slv_vector_c_s1 : w;
  signal slv_vector_c_s2 : w;

  signal slv_vector_z : z;

  signal slv_matrix_mul_result   : vector;
  signal slv_start_matrix_mul    : std_logic;
  signal slv_finished_matrix_mul : std_logic;

  signal slv_matrix   : natural_array;
  signal slv_vector_a : natural_vector;
  signal slv_vector_b : natural_vector;
  signal slv_vector_c : natural_vector;

  signal slv_start_vector_number_mul    : std_logic;
  signal slv_finished_vector_number_mul : std_logic;
  signal slv_number_a                   : std_logic_vector(63 downto 0);

  -- Hashing
  signal slv_start_keccak      : std_logic;
  signal slv_hash_input        : std_logic_vector(63 downto 0);
  signal slv_hash_output       : std_logic_vector(63 downto 0);
  signal slv_hash_input_valid  : std_logic;
  signal slv_hash_output_valid : std_logic;
  signal slv_hash_buffer_full  : std_logic;
  signal slv_hash_last_block   : std_logic;
  signal slv_hash_finished     : std_logic;

begin

  -- A * s multiplier
  matrix_multiplier : component matrix_mul_vector
    port map (
      clock        => clock,
      input_matrix => slv_matrix,
      input_vector => slv_vector_a,
      output       => slv_matrix_mul_result,
      start_mul    => slv_start_matrix_mul,
      finished     => slv_finished_matrix_mul
    );

  vector_sum : component vector_add_vector
    port map (
      input_vector1 => slv_vector_a,
      input_vector2 => slv_vector_b,
      output        => slv_vector_result
    );

  vector_mul : component vector_mul_number
    generic map (
      size => 64
    )
    port map (
      input_vector => slv_vector_a,
      input_number => slv_number_a,
      output       => slv_vector_result,

      start_mul => slv_start_vector_number_mul,
      finished  => slv_finished_vector_number_mul
    );

  hashing : component keccak
    port map (
      clk         => clock,
      rst_n       => '1',
      start       => slv_start_keccak,
      din         => slv_hash_input,
      din_valid   => slv_hash_input_valid,
      buffer_full => slv_hash_buffer_full,
      last_block  => slv_hash_last_block,
      ready       => slv_hash_finished,
      dout        => slv_hash_output,
      dout_valid  => slv_hash_output_valid
    );

  high_low_bits : component decompose
    port map (
      r  => slv_vector_a,
      a  => 2 * y2,
      r0 => ,
r1 => 
    );

  p_fsm_signing : process (clock, slv_state) is
  begin

    if rising_edge(clock) then
      has_finished <= '0';

      case slv_state is

        when s_idle =>

          if (start_signing = '1') then
            slv_state <= s_compute_y;

            slv_matrix_a  <= matrix_a;
            slv_vector_s1 <= vector_s1;
            slv_vector_s2 <= vector_s2;
            slv_message   <= message;
          end if;

        when s_compute_y =>

        when s_computing_w =>

          if (slv_start_matrix_mul = '1') then
            slv_start_matrix_mul <= '0';
          elsif (slv_finished_matrix_mul = '1') then
            slv_vector_w <= slv_vector_result;
            slv_state    <= s_start_hashing;
          end if;
          slv_start_matrix_mul <= '1';
          slv_matrix           <= slv_matrix_a;
          slv_vector_a         <= slv_vector_y;

        when s_start_hashing =>

          slv_start_keccak <= '1';
          slv_state        <= s_wait_for_hashing;

        when s_wait_for_hashing =>

          slv_start_keccak <= '0';
          if (slv_hash_buffer_full = '0') then
            slv_hash_input_valid <= '1';
            slv_state            <= s_write_hash_buffer;
          end if;

        when s_write_hash_buffer =>

          if (message_index >= slv_message'length) then
            slv_state <= s_compute_c;
          end if;
          slv_hash_input <= slv_message(message_index);

          message_index <= message_index + 1;

        when s_compute_c =>

          slv_hash_input_valid <= '0';
          slv_hash_last_block  <= '0';

          if (slv_hash_finished = '1') then
            slv_state <= s_read_c;
          end if;

        when s_read_c =>

          if (slv_hash_output_valid = '1') then
            slv_c     <= slv_hash_output;
            slv_state <= s_compute_c_s1;
          end if;

        when s_compute_c_s1 =>

          slv_start_vector_number_mul <= '1';
          if (slv_start_vector_number_mul = '1') then
            slv_start_matrix_mul <= '0';
          elsif (slv_finished_vector_number_mul = '1') then
            slv_vector_c_s1 <= slv_vector_result;
            slv_state       <= s_compute_check;
          end if;
          slv_vector_a <= slv_vector_s1;
          slv_number_a <= slv_c;

        when s_compute_check =>

          slv_vector_a <= slv_vector_y;
          slv_vector_b <= slv_vector_c_s1;
          slv_vector_z <= slv_vector_result;
          slv_state    <= s_verify;

        when s_verify =>

          slv_state <= s_compute_c_s2;

        when s_compute_c_s2 =>

          slv_start_vector_number_mul <= '1';
          if (slv_start_vector_number_mul = '1') then
            slv_start_matrix_mul <= '0';
          elsif (slv_finished_vector_number_mul = '1') then
            slv_vector_c_s2 <= slv_vector_result;
            slv_state       <= s_compute_z;
          end if;
          slv_vector_a <= slv_vector_s2;
          slv_number_a <= slv_c;

        when s_compute_z =>

          slv_vector_a <= slv_vector_y;
          slv_vector_b <= slv_vector_c_s1;
          slv_vector_z <= slv_vector_result;
          slv_state    <= s_done;

        when s_done =>

          hash      <= slv_c;
          signature <= slv_vector_z;
          slv_state <= s_idle;

      end case;

    end if;

  end process p_fsm_signing;

  has_finished <= '1' when slv_state = s_done else
                  '0';

end architecture a_signature;
