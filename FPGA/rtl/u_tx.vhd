library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity u_tx is
	port (
		clk          : in std_logic;
		rst          : in std_logic;
		tx_baud_tick : in std_logic;
		tx_i         : in std_logic_vector(7 downto 0);
		send_en      : in std_logic;
		p_en		 : in std_logic;
		tx_o         : out std_logic
	);
end entity;

-- implement FSM
architecture rtl of u_tx is

	type state_type is (idle, start, data, stop);
	signal state : state_type := idle;

	signal in_data : std_logic_vector(8 downto 0);

	signal tick_cnt : integer range 0 to 7 := 0;
	signal bit_cnt : integer range 0 to 8 := 0;

	signal byte_sent : std_logic := '0';

	signal tx_data_out : std_logic := '1';

	signal tx_busy : std_logic := '0';

	signal bit_cnt_max : integer range 7 to 8;
	signal parity_en : std_logic := '1';

	signal parity_sum : integer range 0 to 7;
	--signal latch_enable: std_logic := '0';

begin

	process (clk, rst)
		--variables
	begin
		if rst = '1' then
			state <= idle;
			in_data <= (others => '0');
			tick_cnt <= 0;
			bit_cnt <= 0;
			byte_sent <= '0';
			tx_data_out <= '1';
			tx_busy <= '0';
			parity_en <= '1';
			--latch_enable <= '0';

		elsif rising_edge(clk) then
			byte_sent <= '0';

			--if send_en = '1' then
			--	latch_enable <= '1';
			--	in_data <= tx_i;
			--end if;

			case state is
				when idle =>
					--wait on go signal from ctrl
					tx_data_out <= '1';

					if send_en = '1' then
						in_data(7 downto 0) <= tx_i;

						--tick_cnt <= 0;
						tx_busy <= '1';
						state <= start;
						--latch_enable <= '0';
					end if;

				when start =>
					--signal start-bit
					--latch_enable <= '0';
					tx_data_out <= '0';

					if tx_baud_tick = '1' then
						if tick_cnt = 7 then
							state <= data;
							tick_cnt <= 0;
						else
							tick_cnt <= tick_cnt + 1;
						end if;
					end if;

				when data =>
					--process of sending
					if tx_baud_tick = '1' then

						tx_data_out <= in_data(bit_cnt);

						if tick_cnt = 7 then

							if parity_en = '1' then
								if in_data(bit_cnt) = '1' then
									parity_sum <= parity_sum + 1;
								end if;
							end if;

							
							if parity_en = '1' and bit_cnt = 7 then
								in_data(8) <= '1' when (parity_sum mod 2) = 1 else '0';
							end if;

							if bit_cnt = bit_cnt_max then		
								tick_cnt <= 0;
								bit_cnt <= 0;
								byte_sent <= '1';
								state <= stop;
							else
								bit_cnt <= bit_cnt + 1;
							end if;

							tick_cnt <= 0;

						else
							tick_cnt <= tick_cnt + 1;
						end if;
					end if;

				when stop =>
					if tx_baud_tick = '1' then

						--signal stop-bit
						tx_data_out <= '1';

						if tick_cnt = 7 then
							state <= idle;
							tick_cnt <= 0;
						else
							tick_cnt <= tick_cnt + 1;
						end if;
					end if;
			end case;
		end if;
	end process;


	bit_cnt_max <= 7 when (parity_en = '0') else 8; 

	tx_o <= tx_data_out;

end architecture;
