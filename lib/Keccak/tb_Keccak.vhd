library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

entity tb_Keccak is
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
end entity tb_Keccak;

architecture rtl of tb_Keccak is
    component keccak
		port (
				clk     : in  std_logic;
				rst_n   : in  std_logic;
				start : in std_logic;
				din     : in  std_logic_vector(63 downto 0);
				din_valid: in std_logic;
				buffer_full: out std_logic;
				last_block: in std_logic;    
				ready : out std_logic;
				dout    : out std_logic_vector(63 downto 0);
				dout_valid : out std_logic;
				rc_sel:	in std_logic_vector(1 downto 0);
				squeeze: in std_logic
				);
	end component;
	
	component module_fifo_regs_no_flags is
        generic (
          g_WIDTH : natural := 32;
          g_DEPTH : integer := 42
          );
        port (
          i_rst_sync : in std_logic;
          i_clk      : in std_logic;
        
          -- FIFO Write Interface
          i_wr_en   : in  std_logic;
          i_wr_data : in  std_logic_vector((2*g_WIDTH)-1 downto 0);
          o_full    : out std_logic;
        
          -- FIFO Read Interface
          i_rd_en   : in  std_logic;
          o_rd_data : out std_logic_vector(g_WIDTH-1 downto 0);
          o_empty   : out std_logic
          );
    end component;

    signal keccak_start:    std_logic;
    signal keccak_din_valid: std_logic;
    signal keccak_din_last_block: std_logic;
	signal keccak_out_buffer_rst: std_logic := '0';

    signal cryptocore_resetn: std_logic;

    signal keccak_in_reg: std_logic_vector(63 downto 0);
    signal keccak_cmd_reg: std_logic_vector(7 downto 0);

    signal keccak_core_ready:   std_logic;
    signal keccak_buffer_full:   std_logic;
	 
	 signal keccak_buffer_irq: std_logic;
	 signal keccak_ready_irq: std_logic;
	 
	 signal keccak_dout_valid: std_logic;
	 signal keccak_dout_data: std_logic_vector(63 downto 0);
	 
	 signal keccak_out_fifo_full: std_logic;
	 signal keccak_out_fifo_empty: std_logic;
	 signal keccak_out_fifo_rdreq: std_logic;
	 signal keccak_out_fifo_rd_data : std_logic_vector(31 downto 0);
	 
	 signal keccak_upper_rd_data: std_logic_vector(31 downto 0);
	 signal keccak_rc_sel: std_logic_vector(1 downto 0);
	 
	 signal keccak_squeeze: std_logic;
	
	 -- Keccak related State Machine
	type keccak_state_type is (KECCAK_IDLE, S_KECCAK_BUFFER_FULL, KECCAK_CORE_WORKING, KECCAK_STATE_HIGH ,KECCAK_DONE);
	signal keccak_current_state, keccak_next_state : keccak_state_type; --	current and next state declaration.
	-- KECCAK FIFO
	type kfifo_state_type is (KFIFO_IDLE, KFIFO_READ_FIFO, KFIFO_WAIT_STATE, KFIFO_DONE);  --	type of state machine.
	signal kfifo_current_state, kfifo_next_state : kfifo_state_type; --	current and next state declaration.

begin
    
    cryptocore_resetn <= not cryptocore_reset;

    keccak_start    <= keccak_cmd_reg(0);   --start bit
    keccak_din_valid    <= keccak_cmd_reg(1);   -- data in valid bit
    keccak_din_last_block    <= keccak_cmd_reg(2);   -- keccak data in is last block
	 keccak_out_buffer_rst		<= keccak_cmd_reg(3);
	 keccak_rc_sel			<= keccak_cmd_reg(5 downto 4) when (keccak_cmd_reg(5 downto 4) /= "00");
	 keccak_squeeze <= keccak_cmd_reg(6);
	 tb_buffer_full <= keccak_buffer_full;
    tb_core_ready <= keccak_core_ready;

    KECCAK_CORE : keccak
		port map (
				clk     		=>		CLOCK_100,
				rst_n   		=> 	    cryptocore_resetn,
				start   		=>		keccak_start, 
				din     		=>		keccak_in_reg,
				din_valid	    =>		keccak_din_valid,
				buffer_full	    =>		keccak_buffer_full,
				last_block	    =>		keccak_din_last_block,    
				ready 		    =>		keccak_core_ready,
				dout    					=>		keccak_dout_data,
				dout_valid 	    =>		keccak_dout_valid,
				rc_sel			 =>	keccak_rc_sel,
				squeeze			=>		keccak_squeeze
				);
				
	FSM_STATES: process (CLOCK_100)
	begin
		if (rising_edge(CLOCK_100)) then
			if(cryptocore_resetn = '0') then 				-- reset condition
				keccak_current_state		<=			KECCAK_IDLE;
				kfifo_current_state		<=			KFIFO_IDLE;
			else											-- normal condition
				keccak_current_state 	<= 		keccak_next_state;
				kfifo_current_state 		<= 		kfifo_next_state;
			end if;
		end if;
	end process FSM_STATES;	
	
	KECCAK_FSM_TRANSITIONS: process (keccak_next_state, keccak_current_state, keccak_core_ready, keccak_buffer_full)
	begin
		keccak_next_state <= keccak_current_state;
		case keccak_current_state is
			when KECCAK_IDLE			=>			if(keccak_buffer_full = '1') then
															keccak_next_state <= S_KECCAK_BUFFER_FULL;
														end if;
			when S_KECCAK_BUFFER_FULL	=>			if(keccak_core_ready = '0') then
															keccak_next_state <= KECCAK_CORE_WORKING;
														end if;
			when KECCAK_CORE_WORKING =>		if(keccak_core_ready = '1' and keccak_buffer_full = '0') then
															keccak_next_state <= KECCAK_STATE_HIGH;
														end if;
			when KECCAK_STATE_HIGH	=>			keccak_next_state <= KECCAK_DONE;
			when KECCAK_DONE		=>		keccak_next_state <= KECCAK_IDLE;
			when others					=>			keccak_next_state <= KECCAK_IDLE;
		end case;
	end process KECCAK_FSM_TRANSITIONS;

	KECCAK_FSM: process (CLOCK_100)
	begin
		if (rising_edge(CLOCK_100)) then
			if(cryptocore_resetn = '0') then
				keccak_ready_irq	<=	'0';
				keccak_buffer_irq <= '0';
			else
				case keccak_current_state is
					when KECCAK_IDLE			=>			keccak_ready_irq	<=	'0';
																keccak_buffer_irq <=	'0';
					when S_KECCAK_BUFFER_FULL	=>			keccak_buffer_irq <=	'1';											
					when KECCAK_CORE_WORKING	=>		keccak_buffer_irq <=	'1';
																keccak_ready_irq <=	'1';
					when KECCAK_STATE_HIGH	=>			keccak_buffer_irq <=	'1';
																keccak_ready_irq <=	'1';
					when KECCAK_DONE	=>			keccak_buffer_irq <=	'0';
																keccak_ready_irq <=	'0';
					when others					=>			null;
				end case;
			end if;
		end if;
	end process KECCAK_FSM;

	
	P_KECCAK_CMD_REG: process(CLOCK_100, cryptocore_resetn, keccak_cmd_co, keccak_cmd_wr)
	begin  
		if (rising_edge(CLOCK_100)) then
			if (cryptocore_resetn = '0') then
				keccak_cmd_reg <= (others => '0');
			else
                if (keccak_cmd_reg(0) = '1') then       -- reset start bit
							keccak_cmd_reg(0) <= '0';
				end if;
                if (keccak_cmd_reg(1) = '1') then       -- reset valid bit
							keccak_cmd_reg(1) <= '0';
				end if;
                if (keccak_cmd_reg(2) = '1') then       -- reset last block bit
							keccak_cmd_reg(2) <= '0';
				end if;
					if (keccak_cmd_reg(3) = '1') then       -- reset rst bit
							keccak_cmd_reg(3) <= '0';
				end if;
				if (keccak_cmd_reg(6) = '1') then       -- reset rst bit
							keccak_cmd_reg(6) <= '0';
				end if;
				if (keccak_cmd_co = '1' and keccak_cmd_wr = '1') then
					keccak_cmd_reg <= keccak_cmd_wr_data;
				end if;
			end if;
		end if;
	end process P_KECCAK_CMD_REG;
    
    P_KECCAK_IN_REG: process(CLOCK_100, cryptocore_resetn, keccak_in_co, keccak_in_wr)
	begin  
		if (rising_edge(CLOCK_100)) then
			if (cryptocore_resetn = '0') then
				keccak_in_reg <= (others => '0');
			else
				if (keccak_in_co = '1' and keccak_in_wr = '1') then
					keccak_in_reg <= keccak_in_wr_data;
				end if;
			end if;
		end if;
	end process P_KECCAK_IN_REG;
	
	KECCAK_OUT_FIFO: module_fifo_regs_no_flags
  generic map (
    g_WIDTH  => 32,
    g_DEPTH =>  42
    )
  port map(
    i_rst_sync => fifo_reset,
    i_clk      => CLOCK_100,
 
    -- FIFO Write Interface
    i_wr_en   => keccak_dout_valid,
    i_wr_data => keccak_dout_data,
    o_full    => keccak_out_fifo_full,
 
    -- FIFO Read Interface
    i_rd_en   => keccak_out_fifo_rdreq,
    o_rd_data => keccak_out_fifo_rd_data,
    o_empty   => keccak_out_fifo_empty
    );
    
		KFIFO_FSM_TRANSITIONS: process(kfifo_next_state, kfifo_current_state, keccak_out_fifo_co, keccak_out_fifo_empty, keccak_out_fifo_rd)
	begin
		kfifo_next_state <= kfifo_current_state;
		case kfifo_current_state is
			when KFIFO_IDLE				=>			if(keccak_out_fifo_co = '1' and keccak_out_fifo_rd = '1' and keccak_out_fifo_empty = '0') then
															kfifo_next_state <= KFIFO_READ_FIFO;
														end if;
			when KFIFO_READ_FIFO	   =>			kfifo_next_state <= KFIFO_WAIT_STATE;	
			when KFIFO_WAIT_STATE		=>		kfifo_next_state <= KFIFO_DONE;
			when KFIFO_DONE				=>		kfifo_next_state <= KFIFO_IDLE;
			when others					=>			kfifo_next_state <= KFIFO_IDLE;
		end case;
	end process KFIFO_FSM_TRANSITIONS;

	KFIFO_FSM: process (CLOCK_100)
	begin
		if (rising_edge(CLOCK_100)) then
			if(cryptocore_resetn = '0') then
				keccak_out_fifo_rdreq			<=		'0';
			else
				case kfifo_current_state is
					when KFIFO_IDLE			=>			keccak_out_fifo_rdreq				<=		'0';
					when KFIFO_READ_FIFO  =>			keccak_out_fifo_rdreq				<=		'1';
					when KFIFO_WAIT_STATE =>			keccak_out_fifo_rdreq				<=		'0';
					when KFIFO_DONE   		=>			keccak_out_fifo_rdreq				<=		'0';
					when others				=>			null;
				end case;
			end if;
		end if;
	end process KFIFO_FSM;
	
	P_KECCAK_UPPER_REG: process(CLOCK_100, cryptocore_resetn, keccak_upper_co, keccak_upper_rd)
	begin  
		if (rising_edge(CLOCK_100)) then
			if (cryptocore_resetn = '0') then
				keccak_upper_rd_data <= (others => '0');
			else
				if (keccak_upper_co = '1' and keccak_upper_rd = '1') then
					--keccak_in_rd_data <= (others => '0');
					keccak_upper_rd_data <= keccak_in_reg(63 downto 32);
				end if;
			end if;
		end if;
	end process P_KECCAK_UPPER_REG;
    
end architecture rtl;

