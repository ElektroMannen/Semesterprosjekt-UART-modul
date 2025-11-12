LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY u_rx IS
	PORT (
		clk : IN STD_LOGIC;
		rst : IN STD_LOGIC;
		tick_8x : IN STD_LOGIC;
		rx_i : IN STD_LOGIC;
		rx_o : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		LEDR0 : OUT STD_LOGIC
	);
END ENTITY;

ARCHITECTURE rtl OF u_rx IS
	-- Signals
	TYPE state_type IS (idle, start, data, stop);
	SIGNAL state : state_type := idle;
	SIGNAL bit_cnt : INTEGER RANGE 0 TO 7 := 0;
	SIGNAL tick_cnt : INTEGER RANGE 0 TO 7 := 0;
	SIGNAL data_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL rx_sync : STD_LOGIC := '1';
	SIGNAL data_ready_i : STD_LOGIC := '0';
	SIGNAL LEDR0 <= data_recieved
	SIGNAL prev_signal : STD_LOGIC_VECTOR(7 DOWNTO 0);

-- Uart rx funksjon
FUNCTION f_standard_uart_protocol(
		current_state : state_type;
		rx_sample : STD_LOGIC
	) RETURN state_type IS
	BEGIN
		CASE current_state IS
			WHEN idle =>
				IF rx_sample = '0' THEN
					RETURN start; 
				ELSE
					RETURN idle;
				END IF;

			WHEN start =>
				RETURN data; 

			WHEN data =>
				RETURN stop;

			WHEN stop =>
				RETURN idle;
		END CASE;
	END FUNCTION;



	--Byte lagring
	FUNCTION f_store_byte(
		data_in : STD_LOGIC;
		bit_idx : INTEGER;
		data_reg : STD_LOGIC_VECTOR
	) RETURN STD_LOGIC_VECTOR IS
		VARIABLE tmp : STD_LOGIC_VECTOR(data_reg'RANGE) := data_reg;
	BEGIN
		tmp(bit_idx) := data_in;
		RETURN tmp;
	END FUNCTION;

	-- sjekker stop bit for å skru av og på LEDR0 
	FUNCTION f_data_ready(state : state_type; rx_sample : STD_LOGIC) RETURN STD_LOGIC IS
	BEGIN
		IF (state = stop) AND (rx_sample = '1') THEN
			RETURN '1';
		ELSE
			RETURN '0';
		END IF;
	END FUNCTION;

-- Main prosess
BEGIN
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			state <= idle;
			bit_cnt <= 0;
			tick_cnt <= 0;
			data_reg <= (OTHERS => '0');
			data_ready_i <= '0';
			rx_sync <= '1';

		ELSIF rising_edge(clk) THEN
			rx_sync <= rx_i;

			IF f_check_baudrate(tick_8x) THEN
				tick_cnt <= tick_cnt + 1;

				IF f_oversampling(tick_cnt) THEN
					CASE state IS
						WHEN idle =>
							IF rx_sync = '0' THEN
								state <= f_standard_uart_protocol(idle, rx_sync);
								tick_cnt <= 0;
							END IF;

						WHEN start =>
							state <= f_standard_uart_protocol(start, rx_sync);
							bit_cnt <= 0;

						WHEN data =>
							data_reg <= f_store_byte(rx_sync, bit_cnt, data_reg);
							IF bit_cnt = 7 THEN
								state <= f_standard_uart_protocol(data, rx_sync);
							ELSE
								bit_cnt <= bit_cnt + 1;
							END IF;

						WHEN stop =>
							data_ready_i <= f_data_ready(state, rx_sync);
							state <= f_standard_uart_protocol(stop, rx_sync);
					END CASE;
				END IF;
			END IF;
		END IF;
	END PROCESS;

	data_out <= data_reg;
	data_ready <= data_ready_i;

END ARCHITECTURE;