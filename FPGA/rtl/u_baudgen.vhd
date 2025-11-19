library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity u_baudgen is
	generic (
		OVERSAMPLE : integer := 8
	);
	port (
		clk             : in std_logic;
		rst             : in std_logic;
		baud_sel        : in std_logic_vector(1 downto 0);
		rx_baud_tick_8x : out std_logic;
		tx_baud_tick    : out std_logic
	);
end entity;
architecture rtl of u_baudgen is
	--functions
	--function baud_rate(
	--	clk_freq : integer;
	--	baud : integer;
	--	os : integer
	--	) return integer is
	--	begin
	--		if os > 0 then
	--			return clk_freq / (baud * os);
	--		else
	--			return clk_freq / baud;
	--		end if;
	--	end function;

	--constants
	constant F_CLK : integer := 50e6;

	-- 9600bps
	constant RX_9600_DIV : integer := F_CLK/(9600 * OVERSAMPLE);
	constant TX_9600_DIV : integer := F_CLK/9600;

	-- 115200bps
	constant RX_115200_DIV : integer := F_CLK/(115200 * OVERSAMPLE);
	constant TX_115200_DIV : integer := F_CLK/115200;

	-- 100kbps
	constant RX_100K_DIV : integer := F_CLK/(1e5 * OVERSAMPLE);
	constant TX_100K_DIV : integer := F_CLK/(1e5);

	-- 1Mbps
	constant RX_1M_DIV : integer := F_CLK/(1e6 * OVERSAMPLE);
	constant TX_1M_DIV : integer := F_CLK/(1e6);

	--sigmals
	signal baud_tick : std_logic := '0';
	signal oversample_tick : std_logic := '0';
	signal rx_div : integer := RX_9600_DIV;
	signal tx_div : integer := TX_9600_DIV;
begin

	p_sel_baud : process (baud_sel)
	begin
		case baud_sel is
			when "01" =>
				rx_div <= RX_115200_DIV;
				tx_div <= TX_115200_DIV;

			when "10" =>
				rx_div <= RX_100K_DIV;
				tx_div <= TX_100K_DIV;

			when "11" =>
				rx_div <= RX_1M_DIV;
				tx_div <= TX_1M_DIV;

			when others =>
				rx_div <= RX_9600_DIV;
				tx_div <= TX_9600_DIV;
		end case;
	end process;
	p_baud_tx : process (clk)
		variable baud_cnt : natural range 0 to TX_9600_DIV - 1;
	begin
		if rst = '1' then
			baud_cnt := 0;
		elsif rising_edge(clk) then
			if baud_cnt >= tx_div - 1 then
				baud_cnt := 0;
				baud_tick <= '1';
			else
				baud_tick <= '0';
				baud_cnt := baud_cnt + 1;
			end if;
		end if;
	end process;

	--Generate baud-oversample tick
	p_oversample_rx : process (clk, rst)
		variable oversample_cnt : natural range 0 to RX_9600_DIV - 1;
	begin
		if rst = '1' then
			oversample_cnt := 0;
		elsif rising_edge(clk) then
			if oversample_cnt >= rx_div - 1 then
				oversample_tick <= '1';
				oversample_cnt := 0;
			else
				oversample_tick <= '0';
				oversample_cnt := oversample_cnt + 1;
			end if;
		end if;
	end process;
	rx_baud_tick_8x <= oversample_tick;
	tx_baud_tick <= baud_tick;

end architecture;
