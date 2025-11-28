-- references 
-- https://www.analog.com/en/resources/analog-dialogue/articles/uart-a-hardware-communication-protocol.html

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity u_tx is
	port (
		clk          : in std_logic;
		rst          : in std_logic;
		baud_tick 	 : in std_logic;
		data_in      : in std_logic_vector(7 downto 0); -- from fifo
		send_en      : in std_logic; -- enable send from ctrl
		p_en         : in std_logic; -- parity enable (not tested)
		tx_busy		 : out std_logic;
		tx_o         : out std_logic -- serialized data output
	);
end entity;


architecture rtl of u_tx is
	-- fsm same as rx
	type state_type is (idle, start, data, stop);
	signal state : state_type := idle;

	-- internal register (added 1 bit capacity for parity bit)
	signal in_data : std_logic_vector(8 downto 0);

	signal tick_cnt : integer range 0 to 7 := 0;
	signal bit_cnt : integer range 0 to 8 := 0;

	signal byte_sent : std_logic := '0';

	signal data_out : std_logic := '1'; -- internal tx-sync

	signal busy : std_logic := '0';

	signal bit_cnt_max : integer range 7 to 8;
	signal parity_en : std_logic := '0'; --0: off 1: on (SW0?)
	signal parity_bit : std_logic;
	signal parity_mode : std_logic := '0'; --0: even 1: odd (SW1?)

	signal parity_sum : integer range 0 to 7;
	--signal latch_enable: std_logic := '0';

	--functions
	function xor_parity(x : std_logic_vector) return std_logic is
		variable p : std_logic := '0';
	begin
		for i in x'range loop
			p := p xor x(i);
		end loop;
		return p;
	end function;
begin

	process (clk, rst)
		--variables
	begin
		if rst = '1' then
			state <= idle;
			in_data <= (others => '0');
			bit_cnt <= 0;
			byte_sent <= '0';
			data_out <= '1';
			busy <= '0';
			parity_en <= '0';

		elsif rising_edge(clk) then
			byte_sent <= '0';

			case state is
				when idle =>
					-- wait on go signal from ctrl
					data_out <= '1';
					busy <= '0';

					-- received enable from ctrl module
					if send_en = '1' then
						busy <= '1';
						state <= start;
					end if;

				when start =>
					-- signal start-bit
					data_out <= '0';

					-- put fifo-data in internal send-register
					in_data(7 downto 0) <= data_in;

						--add parity
						if parity_en = '1' then
							if parity_mode = '0' then 
								in_data(8) <= parity_bit; -- even ?
							else
								in_data(8) <= not parity_bit; -- odd ?
							end if;
						end if;

					if baud_tick = '1' then
							state <= data;
					end if;

				when data =>
					--process of sending
					if baud_tick = '1' then

						-- serialize data
						data_out <= in_data(bit_cnt);

							-- count 8 bit if no parity 9 bit with parity
							if bit_cnt = bit_cnt_max then
								bit_cnt <= 0;
								byte_sent <= '1';
								state <= stop;
							else
								bit_cnt <= bit_cnt + 1;
							end if;
					end if;

				when stop =>
					-- output stop-bit
					data_out <= '1';

					-- keep stop-bit on for one baud tick
					if baud_tick = '1' then
						state <= idle; -- reset
					end if;
			end case;
		end if;
	end process;

	parity_bit <= xor_parity(data_in); -- calculate parity bit
	bit_cnt_max <= 7 when parity_en = '0' else 8; -- parity enable
	tx_o <= data_out; -- send data
	tx_busy <= busy; -- indicate sending process to other modules

end architecture;
