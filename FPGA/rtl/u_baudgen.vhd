library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity u_baudgen is
	generic (oversample_8x: natural := 326); --tick every 651 device clock cycle
	port (
		clk			:	in  std_logic;
		rst_n			:	in  std_logic;
		baud_clk		:	out std_logic
	);
end entity;


architecture rtl of u_baudgen is
	signal r1: std_logic := '1';
	signal r2: std_logic := '0';
begin
	--Generate baud-oversample tick
	p_main: process (clk, rst_n)
		variable count: natural range 0 to (oversample_8x-1); --8x oversample (50_000_000/(9600*8))
	begin
		if rst_n = '0' then
			r1 <= '1';
		elsif rising_edge(clk) then
			if count=(oversample_8x-1) then
				count := 0;
				r1 <= not r1; --flip flop
			else
				count := count + 1;
			end if;
		end if;
	end process;
	
	baud_clk <= r1;
	
	p_test: process (baud_clk)
	begin
		if rising_edge(baud_clk) then
			r2 <= '1';
		else
			r2 <= '0';
		end if;
	end process;
	
end architecture;
