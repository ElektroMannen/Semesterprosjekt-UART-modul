library ieee; 
use ieee.std_logic_1164.all;


entity u_tx is
	port (
		clk		: in	std_logic;
		rst		: in	std_logic;
		baud_clk	: in	std_logic;
		tx_i		: in	std_logic;
		tx_o		: out	std_logic
	);
end entity;

-- implement FSM
architecture rtl of u_tx is

begin
end architecture;
