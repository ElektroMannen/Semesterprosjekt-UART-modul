library ieee; 
use ieee.std_logic_1164.all;

entity uart is
	port (
		d_clk			: in std_logic; --device clk
		rst_n			: in std_logic;
		Rx_D			: in std_logic;
		SW0, SW1		: in std_logic;
		Tx_D			: out std_logic;
		LEDR0			: out std_logic;
		SEG0, SEG1	: out std_logic_vector(7 downto 0)
	);
end entity;

architecture rtl of uart is
	signal rst			: std_logic;
	signal baud_tick	: std_logic;
	signal rx_reg		: std_logic_vector(7 downto 0);
	signal tx_reg		: std_logic;
begin
	
	BAUD: entity work.u_baudgen
	port map (
		clk  => d_clk,
		rst_n  => rst_n,
		tick => baud_tick
	);
	
	RxD: entity work.u_rx
	port map (
		clk => d_clk,
		rst => rst,
		tick_8x => baud_tick,
		rx_i => Rx_D,
		rx_o => rx_reg,
		LEDR0 => LEDR0
	);

	TxD: entity work.u_tx
	port map (
		clk => d_clk,
		rst => rst,
		tick_8x => baud_tick,
		tx_i => tx_reg,
		tx_o => TX_D
	);
		
	CTRL: entity work.u_ctrl
	port map (
		clk => d_clk,
		rst => rst,
		rx_data => rx_reg,
		HEX0 => SEG0,
		HEX1 => SEG1
	);
	 
end architecture;
