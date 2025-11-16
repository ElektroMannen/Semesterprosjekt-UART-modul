library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity u_baudgen is
	generic (oversample_8x : natural := 651); --tick every 651 device clock cycle
	port (
		clk          : in std_logic;
		rst          : in std_logic;
		rx_baud_tick : out std_logic;
		tx_baud_tick : out std_logic
	);
end entity;
architecture rtl of u_baudgen is
	--sigmals
	signal r1 : std_logic := '0';
begin

	--Generate baud-oversample tick
	p_main : process (clk, rst)
		variable count : natural range 0 to (oversample_8x - 1); --8x oversample (50_000_000/(9600*8))
	begin
		if rst = '1' then
			r1 <= '1';
			count := 0;
		elsif rising_edge(clk) then
			if count = (oversample_8x - 1) then
				r1 <= '1';
				count := 0;
			else
				count := count + 1;
				r1 <= '0';
			end if;
		end if;
	end process;

	rx_baud_tick <= r1;
	tx_baud_tick <= r1;

end architecture;
