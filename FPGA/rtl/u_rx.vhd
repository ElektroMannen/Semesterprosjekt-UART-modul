library ieee;
use ieee.std_logic_1164.all;


entity u_rx is
	port (
		clk		: in  std_logic;
		rst		: in  std_logic;
		tick_8x	: in	std_logic;
		rx_i		: in	std_logic;
		rx_o		: out std_logic
	);
end entity;


architecture rtl of u_rx is

begin
end architecture;
