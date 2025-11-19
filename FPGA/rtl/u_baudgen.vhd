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
	function baud_rate(f_clk : integer) return integer is
	begin
		return 50_000_000 / f_clk;
	end function;

	--sigmals
	signal r1 : std_logic := '0';
	signal clk_i : std_logic := '0';
	signal clk_j : std_logic := '0';
	signal speed : integer range 0 to 6000 := 0;
begin

	--Generate baud-oversample tick
	p_clk : process (clk)
		variable counter_i : natural range 0 to baud_rate(9600);
		--variable clk_j : natural range 0 to baud_rate(9600); --8x oversample (50_000_000/(9600*8))
	begin
		if rising_edge(clk) then
			if counter_i = (baud_rate(9600) - 1) then
				--r1 <= '1';
				clk_i <= not clk_i;
				clk_j <= not clk_j;
				counter_i := 0;
				speed <= baud_rate(9600);
			else
				counter_i := counter_i + 1;
				--r1 <= '0';
			end if;
		end if;
	end process;


	rx_baud_tick <= clk_i;
	tx_baud_tick <= clk_j;

end architecture;
