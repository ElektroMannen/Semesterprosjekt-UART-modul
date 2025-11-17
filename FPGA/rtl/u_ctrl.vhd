library ieee;
use ieee.std_logic_1164.all;

entity u_ctrl is
	port (
		clk          : in std_logic;
		rst          : in std_logic;
		rx_data      : in std_logic_vector(7 downto 0);
		rx_baud_tick : in std_logic;
		data_ready   : in std_logic;
		tx_busy		 : in std_logic;
		tx_send_en   : out std_logic;
		HEX0, HEX1   : out std_logic_vector(7 downto 0);
		rx_ok        : out std_logic
	);
end entity;
architecture rtl of u_ctrl is
	-- functions
	function hex_to_7seg(h : std_logic_vector(3 downto 0)) return std_logic_vector is

		variable seg : std_logic_vector(7 downto 0);
	begin
		case h is
			when "0000" => seg := "11000000"; --0
			when "0001" => seg := "11111001"; --1
			when "0010" => seg := "10100100"; --2
			when "0011" => seg := "10110000"; --3
			when "0100" => seg := "10011001"; --4
			when "0101" => seg := "10010010"; --5
			when "0110" => seg := "10000010"; --6
			when "0111" => seg := "11111000"; --7
			when "1000" => seg := "10000000"; --8
			when "1001" => seg := "10010000"; --9
			when "1010" => seg := "10001000"; --A
			when "1011" => seg := "10000011"; --b
			when "1100" => seg := "11000110"; --C
			when "1101" => seg := "10100001"; --d
			when "1110" => seg := "10000110"; --E
			when others => seg := "10001110"; --F
		end case;
		return seg;
	end function;

	--signals
	signal data_h, data_l : std_logic_vector(3 downto 0); --data high/low
	signal led_on : std_logic;
	signal on_time : integer range 0 to 1000 := 0; --latch for 10 rx ticks
	signal loopback_en : std_logic := '1';
begin

	p1 : process (clk, rst)
	begin
		if rst = '1' then
			data_l <= (others => '1');
			data_h <= (others => '1');
			led_on <= '0';
			on_time <= 0;
			loopback_en <= '1';
		elsif rising_edge(clk) then
			if rx_baud_tick = '1' then
				on_time <= on_time + 1;
				led_on <= '1';
			elsif on_time = 9 then
				on_time <= 0;
				led_on <= '0';
			end if;
			--just latching data until next data
			if data_ready = '1' then
				on_time <= 0;
				--loopback_en <= '1';
				data_h <= rx_data(7 downto 4);
				data_l <= rx_data(3 downto 0);
				--elsif on_time = 999 then
				--	data_h <= (others => '1');
				--	data_l <= (others => '1');
				--else
				--loopback_en <= '0';
			end if;

			--TODO: check if tx_busy=1, if not, make it send
			--		some ASCII symbol on button press

		end if;
	end process;

	--echo loopback ok
	tx_send_en <= data_ready when (loopback_en = '1') else
		'0';
	rx_ok <= led_on;
	HEX0 <= hex_to_7seg(data_h);
	HEX1 <= hex_to_7seg(data_l);

end architecture;
