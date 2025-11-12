library ieee;
use ieee.std_logic_1164.all;


entity u_ctrl is
	port (
		clk			: in  std_logic;
		rst			: in  std_logic;
		rx_data		: in	std_logic_vector(7 downto 0);
		HEX0, HEX1	: out std_logic_vector(7 downto 0)
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
	signal data_h, data_l: std_logic_vector(3 downto 0); --data high/low
	signal rst_n: std_logic;
begin
	rst_n <= not rst;

	p1: process(clk, rst_n)
	begin
		if rising_edge(clk) then
			if rst_n = '0' then
				data_l <= (others => '1');
				data_h <= (others => '1');
			elsif rx_data /= "00000000" then
				data_h <= rx_data(7 downto 4);
				data_l <= rx_data(3 downto 0);
			end if;
		end if;
	end process;
	
HEX0 <= hex_to_7seg(data_h);
HEX1 <= hex_to_7seg(data_l);


end architecture;
