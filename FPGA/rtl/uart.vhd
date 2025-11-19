library ieee;
use ieee.std_logic_1164.all;

entity uart is
	port (
		sys_clk    : in std_logic; --50MHz
		rst_n      : in std_logic;
		Rx_D       : in std_logic;
		SW0, SW1   : in std_logic;
		baud_ctrl  : in std_logic_vector(1 downto 0);
		Tx_D       : out std_logic;
		LEDR0      : out std_logic;
		SEG0, SEG1 : out std_logic_vector(7 downto 0)
	);
end entity;

architecture rtl of uart is
	signal rst : std_logic;
	signal rx_oversample_tick : std_logic;
	signal tx_baud_tick : std_logic;
	signal rx_reg : std_logic_vector(7 downto 0);
	signal rx_data_ready : std_logic;
	signal tx_send_en : std_logic;
	signal parity_en : std_logic;
	signal tx_busy : std_logic;
	signal ctrl_baud_sel : std_logic_vector(1 downto 0);
	--signal tx_reg			: std_logic;
begin
	rst <= not rst_n;

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
			clk          	=> sys_clk,
			rst          	=> rst,
			baud_tick_8x 	=> rx_oversample_tick, --8x oversample
			rx_i         	=> Rx_D,
			rx_o         	=> rx_reg,
			LEDR0        	=> LEDR0,
			data_ready   	=> rx_data_ready
		);

	TxD : entity work.u_tx
		port map(
			clk          => sys_clk,
			rst          => rst,
			baud_tick	 => tx_baud_tick,
			tx_i         => rx_reg,
			send_en      => tx_send_en,
			p_en		 => parity_en,
			tx_busy		 => tx_busy,
			tx_o         => TX_D
		);

	CTRL : entity work.u_ctrl
		port map(
			clk          => sys_clk,
			rst          => rst,
			rx_data      => rx_reg,
			rx_baud_tick => rx_oversample_tick,
			data_ready   => rx_data_ready,
			tx_send_en   => tx_send_en,
			tx_busy		 => tx_busy,
			baud_ctrl	 => baud_ctrl,
			baud_sel	 => ctrl_baud_sel,
			HEX0         => SEG0,
			HEX1         => SEG1
		);

end architecture;
