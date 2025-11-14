library ieee;
use ieee.std_logic_1164.all;
entity u_rx is
	port (
		clk     	: in std_logic;
		rst     	: in std_logic;
		baud_clk : in std_logic;
		rx_i    	: in std_logic;
		rx_o    	: out std_logic_vector(7 downto 0);
		LEDR0   	: out std_logic
	);
end entity;

architecture rtl of u_rx is

    component rx_shiftreg is
        port (
            clk       : in  std_logic;
            rst       : in  std_logic;
            shift_en  : in  std_logic;
            rx_bit    : in  std_logic;
            data      : out std_logic_vector(7 downto 0);
            bit_cnt   : out integer range 0 to 7;
            byte_done : out std_logic
        );
    end component;
	 
    signal sh_data      : std_logic_vector(7 downto 0);
    signal sh_bit_cnt   : integer range 0 to 7;
    signal sh_byte_done : std_logic;

    signal shift_en     : std_logic;
	 

	-- Signals
	type state_type is (idle, start, data, stop);
	signal state : state_type := idle;
	signal bit_cnt : integer range 0 to 7 := 0;
	signal tick_cnt : integer range 0 to 7 := 0;
	signal data_reg : std_logic_vector(7 downto 0) := (others => '0');
	signal rx_sync : std_logic := '1';
	signal data_ready_i : std_logic := '0';
	signal data_recieved : std_logic := '0';
	signal prev_signal : std_logic_vector(7 downto 0);

	-- Uart rx funksjon
	function f_standard_uart_protocol(
		current_state : state_type;
		rx_sample : std_logic
	) return state_type is
	begin
		case current_state is
			when idle =>
				if rx_sample = '0' then
					return start;
				else
					return idle;
				end if;

			when start =>
				return data;

			when data =>
				return stop;

			when stop =>
				return idle;
		end case;
	end function;

	--Byte lagring
	function f_store_byte(
		data_in : std_logic;
		bit_idx : integer;
		data_reg : std_logic_vector
	) return std_logic_vector is
		variable tmp : std_logic_vector(data_reg'range) := data_reg;
	begin
		tmp(bit_idx) := data_in;
		return tmp;
	end function;
	
	--return true when middle of oversample frequency
	function f_oversampling(cnt : integer) return boolean is
	begin
		return (cnt = 3);
	end function;

	-- sjekker stop bit for å skru av og på LEDR0 
	function f_data_ready(state : state_type; rx_sample : std_logic) return std_logic is
	begin
		if (state = stop) and (rx_sample = '1') then
			return '1';
		else
			return '0';
		end if;
	end function;

	-- Main prosess
begin
    -- instans av shiftregisteret
		u_shift : rx_shiftreg
        port map (
            clk       => clk,
            rst       => rst,
            shift_en  => shift_en,
            rx_bit    => rx_sync,
            data      => sh_data,
            bit_cnt   => sh_bit_cnt,
            byte_done => sh_byte_done
        );



	process (clk, rst)
	begin
		if rst = '1' then
			state <= idle;
			bit_cnt <= 0;
			tick_cnt <= 0;
			data_reg <= (others => '0');
			data_ready_i <= '0';
			rx_sync <= '1';

		elsif rising_edge(clk) then
			rx_sync <= rx_i;

			if rising_edge(baud_clk) then
				tick_cnt <= tick_cnt + 1;

				if f_oversampling(tick_cnt) then
					case state is
						when idle =>
							if rx_sync = '0' then
								state <= f_standard_uart_protocol(idle, rx_sync);
								tick_cnt <= 0;
							end if;

						when start =>
							state <= f_standard_uart_protocol(start, rx_sync);
							bit_cnt <= 0;

						when data =>
							data_reg <= f_store_byte(rx_sync, bit_cnt, data_reg);
							if bit_cnt = 7 then
								state <= f_standard_uart_protocol(data, rx_sync);
							else
								bit_cnt <= bit_cnt + 1;
							end if;

						when stop =>
							data_ready_i <= f_data_ready(state, rx_sync);
							state <= f_standard_uart_protocol(stop, rx_sync);
					end case;
				end if;
			end if;
		end if;
	end process;

	LEDR0 <= data_ready_i;
	rx_o <= data_reg;
	
end architecture;
