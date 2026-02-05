library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

entity tb_tb_Keccak is
end entity;

architecture rtl of tb_tb_Keccak is
    component tb_Keccak is
    port (
        CLOCK_100:   in	std_logic;
        keccak_cmd_wr_data: in  std_logic_vector(7 downto 0);
        keccak_cmd_wr:  in  std_logic;
        keccak_cmd_co:  in  std_logic;
        keccak_in_wr:  in  std_logic;
        keccak_in_co:  in  std_logic;
		  keccak_out_fifo_rd:  in  std_logic;
		  keccak_out_fifo_co:  in  std_logic;
		  keccak_upper_co:in  std_logic;
		  keccak_upper_rd:in  std_logic;
        keccak_in_wr_data: in   std_logic_vector(63 downto 0);
        cryptocore_reset: in std_logic;
        tb_buffer_full: out std_logic;
        tb_core_ready:  out std_logic;
		  fifo_reset: in std_logic
    );
end component tb_Keccak;

    signal CLOCK_100: std_logic :='0';
    signal keccak_in_co, keccak_cmd_wr, keccak_cmd_co, keccak_in_wr, keccak_out_fifo_co, keccak_out_fifo_rd : std_logic;
    signal keccak_in_wr_data: std_logic_vector(63 downto 0);
    signal keccak_cmd_wr_data: std_logic_vector(7 downto 0);
    signal tb_buffer_full: std_logic;
    signal tb_core_ready: std_logic;
    signal cryptocore_reset: std_logic :='1';
	 signal fifo_reset: std_logic :='1';
	 signal keccak_upper_co:  std_logic;
	 signal keccak_upper_rd:  std_logic;
begin
    
    TEST_BENCH: tb_Keccak
    port map (
        CLOCK_100            =>   CLOCK_100,
        keccak_cmd_wr_data  =>   keccak_cmd_wr_data,
        keccak_cmd_wr       =>   keccak_cmd_wr,
        keccak_cmd_co       =>   keccak_cmd_co,
        keccak_in_wr        =>   keccak_in_wr,
        keccak_in_co        =>   keccak_in_co,
		  keccak_upper_co		=> keccak_upper_co,
		  keccak_upper_rd    =>keccak_upper_rd,
        keccak_in_wr_data   =>   keccak_in_wr_data,
        cryptocore_reset    =>   cryptocore_reset,
        tb_buffer_full      =>   tb_buffer_full,
        tb_core_ready       =>   tb_core_ready,
		  keccak_out_fifo_rd 	=>   keccak_out_fifo_rd,
		  keccak_out_fifo_co 	=>   keccak_out_fifo_co,
		  fifo_reset				=> fifo_reset
    );
    
    CLOCK_100 <= not CLOCK_100 after 5 ns;
    
    p_stimulus: process
	
		procedure P_sync_app(constant c_loop: integer) is
			variable v_count: integer := 0;
		begin
			loop_cnt: while v_count <= c_loop loop
			wait until rising_edge(CLOCK_100);
				v_count := v_count + 1;
			end loop loop_cnt;
		end procedure P_sync_app;	
	
		procedure P_stable is
		begin
			fifo_reset <= '1';
			cryptocore_reset <= '1';
			wait for 15 ns;
			cryptocore_reset <= '0';
			fifo_reset <= '0';
		end procedure P_stable;

        procedure P_Fill_Keccak_Buffer(constant c_keccak_in_wr_data: std_logic_vector(63 downto 0)) is
        begin
            keccak_in_wr_data <= c_keccak_in_wr_data;
            keccak_in_co <= '1';
            keccak_in_wr <= '1';
				keccak_upper_rd <= '1';
				keccak_upper_co <= '1';
            wait for 10 ns;
            keccak_in_co <= '0';
            keccak_in_wr <= '0';
				keccak_upper_rd <= '0';
				keccak_upper_co <= '0';
            keccak_in_wr_data <= (others => '0');
        end procedure P_Fill_Keccak_Buffer;
    

        procedure P_Set_Keccak_CMD(constant c_keccak_cmd_wr_data: std_logic_vector(7 downto 0)) is
        begin
            keccak_cmd_wr_data <= c_keccak_cmd_wr_data;
            keccak_cmd_co <= '1';
            keccak_cmd_wr <= '1';
            wait for 10 ns;
            keccak_cmd_co <= '0';
            keccak_cmd_wr <= '0';
            keccak_cmd_wr_data <= (others => '0');
        end procedure P_Set_Keccak_CMD;
		  
		  procedure P_READ_OUT(constant test: std_logic) is
        begin
            keccak_out_fifo_rd <= '1';
            keccak_out_fifo_co <= '1';
            wait for 10 ns;
            keccak_out_fifo_rd <= '0';
            keccak_out_fifo_co <= '0';
        end procedure P_READ_OUT;
		  procedure P_RST_FIFO is
        begin
            fifo_reset <= '1';
            wait for 10 ns;
            fifo_reset <= '0';
        end procedure P_RST_FIFO;
		
	begin

		P_stable;
		P_sync_app(1);
		P_Set_Keccak_CMD("00111001");
        P_sync_app(1);
        P_Fill_Keccak_Buffer(x"00000000001f4b4f");
        P_Set_Keccak_CMD("00000010");
        P_sync_app(1);
		P_Fill_Keccak_Buffer(x"0000000000000000");
        P_Set_Keccak_CMD("00000010");
        P_sync_app(1);
		P_Fill_Keccak_Buffer(x"0000000000000000");
        P_Set_Keccak_CMD("00000010");
        P_sync_app(1);
		P_Fill_Keccak_Buffer(x"0000000000000000");
        P_Set_Keccak_CMD("00000010");
        P_sync_app(1);
		P_Fill_Keccak_Buffer(x"0000000000000000");
        P_Set_Keccak_CMD("00000010");
        P_sync_app(1);
		P_Fill_Keccak_Buffer(x"0000000000000000");
        P_Set_Keccak_CMD("00000010");
        P_sync_app(1);
		P_Fill_Keccak_Buffer(x"0000000000000000");
        P_Set_Keccak_CMD("00000010");
        P_sync_app(1);
		P_Fill_Keccak_Buffer(x"0000000000000000");
        P_Set_Keccak_CMD("00000010");
        P_sync_app(1);
		P_Fill_Keccak_Buffer(x"0000000000000000");
        P_Set_Keccak_CMD("00000010");
        P_sync_app(1);
		P_Fill_Keccak_Buffer(x"0000000000000000");
        P_Set_Keccak_CMD("00000010");
        P_sync_app(1);
		P_Fill_Keccak_Buffer(x"0000000000000000");
        P_Set_Keccak_CMD("00000010");
        P_sync_app(1);
		P_Fill_Keccak_Buffer(x"0000000000000000");
        P_Set_Keccak_CMD("00000010");
        P_sync_app(1);
		P_Fill_Keccak_Buffer(x"0000000000000000");
        P_Set_Keccak_CMD("00000010");
        P_sync_app(1);
		P_Fill_Keccak_Buffer(x"0000000000000000");
        P_Set_Keccak_CMD("00000010");
        P_sync_app(1);
		P_Fill_Keccak_Buffer(x"0000000000000000");
        P_Set_Keccak_CMD("00000010");
        P_sync_app(1);
		P_Fill_Keccak_Buffer(x"0000000000000000");
        P_Set_Keccak_CMD("00000010");
		  P_sync_app(1);
		P_Fill_Keccak_Buffer(x"0000000000000000");
        P_Set_Keccak_CMD("00000010");
		P_sync_app(1);
		P_Fill_Keccak_Buffer(x"0000000000000000");
        P_Set_Keccak_CMD("00000010");
		P_sync_app(1);
		P_Fill_Keccak_Buffer(x"0000000000000000");
        P_Set_Keccak_CMD("00000010");
		P_sync_app(1);
		P_Fill_Keccak_Buffer(x"0000000000000000");
        P_Set_Keccak_CMD("00000010");
		P_sync_app(1);
		P_Fill_Keccak_Buffer(x"8000000000000000");
        P_Set_Keccak_CMD("00000010");
		P_sync_app(1);
        wait until tb_core_ready = '1';
			P_sync_app(2);
			P_Set_Keccak_CMD("00000100");
        P_sync_app(100);
		  P_RST_FIFO;
		  P_sync_app(1);
		P_Set_Keccak_CMD("01000000");
		wait until tb_core_ready = '1';
			P_sync_app(100);
			P_Set_Keccak_CMD("00000100");
		P_sync_app(100);
		assert false report "--- END OF SIMULATION ---" severity failure;
		
	end process p_stimulus;

    
end architecture rtl;