library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity u_baudgen is
	generic (oversample_8x: natural := 651); --tick every 651 device clock cycle
	port (
		clk		:	in  std_logic;
		rst_n		:	in  std_logic;
		tick		:	out std_logic
	);
end entity;


architecture rtl of u_baudgen is
--signals
signal tick_8x: std_logic;

begin
	--Generate baud-oversample tick
	p_main: process (clk, rst_n)
		variable count: natural range 0 to oversample_8x-1; --8x oversample (50_000_000/(9600*8))
	begin
		if rising_edge(clk) then
			if rst_n = '0' then
				tick_8x <= '0';
			elsif count=(oversample_8x-1) then
				count := 0;
				tick_8x <= '1';
			else
				count := count + 1;
				tick_8x <= '0';
			end if;
		end if;
	end process;
	
	tick <= tick_8x;
	
end architecture;
