library ieee;
use ieee.std_logic_1164.all;

entity uart is
	port (
		sys_clk    : in std_logic; --50MHz
		rst_n      : in std_logic;
		test_n     : in std_logic;
		Rx_D       : in std_logic;
		SW0, SW1   : in std_logic;
		baud_ctrl  : in std_logic_vector(1 downto 0);
		Tx_D       : out std_logic;
		LEDR0      : out std_logic;
		SEG0, SEG1 : out std_logic_vector(7 downto 0)
	);
end entity;

architecture rtl of uart is
	signal rst : std_logic; -- inverse rst button (key1)
	signal test : std_logic; -- inverse test button (key2)
	
	-- Baudrate
	signal rx_oversample_tick : std_logic;
	signal tx_baud_tick : std_logic;
	
	-- RX/TX interface
	signal data_bus : std_logic_vector(7 downto 0);
	signal rx_data_ready : std_logic;
	signal tx_en : std_logic; -- enable send from tx
	signal parity_en : std_logic;
	signal tx_busy : std_logic;
	signal ctrl_baud_sel : std_logic_vector(1 downto 0);

	--FIFO controlls
	signal write_en : std_logic;
	signal read_en : std_logic;
	signal fifo_data : std_logic_vector(7 downto 0);
	signal fifo_empty : std_logic;
	signal t_signal : std_logic;
	--signal tx_reg			: std_logic;
	
	-- Patiry toggle signals
    signal parity_enable : std_logic;
    signal parity_even_odd   : std_logic;
	


begin
	rst <= not rst_n;
	test <= not test_n;

	--Patity controlls
	parity_enable <= SW0; -- SW0 turns parity ON/OFF  
	parity_even   <= SW1; -- SW1 selects EVEN (1) or ODD (0)

	BAUD : entity work.u_baudgen
		port map(
			clk          	=> sys_clk,
			rst          	=> rst,
			baud_sel	 	=> ctrl_baud_sel,
			tx_baud_tick 	=> tx_baud_tick,
			rx_baud_tick_8x => rx_oversample_tick
		);

	RxD : entity work.u_rx
		port map(
			clk           => clk,
			rst           => rst,
			baud_tick_8x  => rx_baud_tick_8x,
			rx_i          => rx_i,
			parity_enable => parity_enable,
			parity_even   => parity_even,
			data_bus      => data_bus_rx,
			LEDR0         => LEDR0,
			data_ready    => data_ready,
		);

	TxD : entity work.u_tx
		port map(
            clk          => sys_clk,
            rst          => rst,
            baud_tick    => tx_baud_tick,
            data_in      => fifo_data,
            send_en      => tx_en,
            p_en         => parity_enable,   -- parity enable signal
            even_parity  => parity_even,     -- even/odd select
            tx_busy      => tx_busy,
            tx_o         => Tx_D
        );

	CTRL : entity work.u_ctrl
		port map(
			clk          => sys_clk,
			rst          => rst,
			data_bus     => data_bus,
			rx_baud_tick => rx_oversample_tick,
			data_ready   => rx_data_ready,
			tx_en   	 => tx_en,
			tx_busy		 => tx_busy,
			test_btn     => test,
			baud_ctrl	 => baud_ctrl,
			baud_sel	 => ctrl_baud_sel,
			w_data 		 => write_en,	 	 
			r_data 		 => read_en,
			t_data		 => t_signal,
			fifo_empty   => fifo_empty,
			HEX0         => SEG0,
			HEX1         => SEG1
		);

	FIFO : entity work.u_fifo
		port map(
			clk          => sys_clk,
			rst          => rst,
			we	 		 => write_en,
			re   		 => read_en,
			ASCIItest    => t_signal,
			data_bus     => data_bus,
			data_out     => fifo_data,
			empty		 => fifo_empty
		);

end architecture;
