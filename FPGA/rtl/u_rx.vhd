library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity u_rx is
    port (
        clk            : in  std_logic;
        rst            : in  std_logic;
        baud_tick_8x   : in  std_logic;
        rx_i           : in  std_logic;
        parity_enable  : in  std_logic;
        parity_even    : in  std_logic;
        data_bus       : out std_logic_vector(7 downto 0);
        LEDR0          : out std_logic;
        data_ready     : out std_logic
    );
end entity;

architecture rtl of u_rx is

    component rx_shiftreg is
        port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            shift_en : in  std_logic;
            rx_bit   : in  std_logic;
            clear    : in  std_logic;
            data     : out std_logic_vector(7 downto 0)
        );
    end component;

    -- RX shiftregister
    signal sh_data       : std_logic_vector(7 downto 0);
    signal shift_en      : std_logic := '0';
    signal sh_clear      : std_logic := '0';

    -- UART state machine
    type state_type is (idle, start, data, parity, stop);
    signal state         : state_type := idle;
    signal tick_cnt      : unsigned(2 downto 0) := (others => '0');
    signal bit_cnt       : integer range 0 to 7 := 0;

    -- RX line sync
    signal rx_sync       : std_logic := '1';

    -- Majority buffer
    signal sample_buf    : std_logic_vector(4 downto 0) := (others => '0');
    signal sample_idx    : integer range 0 to 4 := 0;
    signal majority_bit  : std_logic := '1';

    -- Parity
    signal parity_bit_rx : std_logic := '0';

    -- Start ok
    signal start_signal : std_logic := '0';

    -- Data ready
    signal data_ready_i  : std_logic := '0';

    -- Helper function for parity calculation
    function calc_parity(x : std_logic_vector) return std_logic is
        variable p : std_logic := '0';
    begin
        for i in x'range loop
            p := p xor x(i);
        end loop;
        return p;
    end function;

begin

    -- Shift register instance
    u_shift : rx_shiftreg
        port map(
            clk      => clk,
            rst      => rst,
            shift_en => shift_en,
            rx_bit   => majority_bit,
            clear    => sh_clear,
            data     => sh_data
        );

    -- Main RX process
    process(clk, rst)
        variable ones : integer;
    begin
        if rst = '1' then
            state        <= idle;
            tick_cnt     <= (others => '0');
            bit_cnt      <= 0;
            data_ready_i <= '0';
            rx_sync      <= '1';
            shift_en     <= '0';
            sh_clear     <= '0';
            sample_buf   <= (others => '0');
            sample_idx   <= 0;
            LEDR0        <= '0';
            start_signal <= '0';
        elsif rising_edge(clk) then
            rx_sync <= rx_i;
            shift_en <= '0';
            data_ready_i <= '0';
            LEDR0 <= '0';

            if baud_tick_8x = '1' then
                -- 8x oversampling
                if tick_cnt = 7 then
                    tick_cnt <= (others => '0');
                else
                    tick_cnt <= tick_cnt + 1;
                end if;




                -- UART state machine
                case state is
                    when idle =>
                        sh_clear <= '0';
                        tick_cnt <= (others => '0');
                        if rx_sync = '0' then
                            state <= start;
                        end if;

                    when start =>
                        if tick_cnt = 3 and rx_sync = '0' then
                            start_signal <= '1';
                        elsif tick_cnt = 7 then
                            if start_signal = '1' then
                                tick_cnt <= (others => '0');
                                sample_idx <= 0;
                                state <= data;
                                start_signal <= '0';
                            else
                                state <= idle;
                            end if;
                        end if;
                    

                    when data =>
                        -- 5-point majority sampling (midbit)
                        -- changed from 2 and 6 to 1 and 5 due to timing issues
                        -- we are lagging 1 baud tick already
                        -- so 1 will be earlier
                        if tick_cnt >= 1 and tick_cnt <= 5 then
                            sample_buf(sample_idx) <= rx_sync;
                            if sample_idx < 4 then
                                sample_idx <= sample_idx + 1;
                            end if;
                        end if;


                        if tick_cnt = 5 then
                            -- Majority decision
                            ones := 0;
                            for i in 0 to 4 loop
                                if sample_buf(i) = '1' then
                                    ones := ones + 1;
                                end if;
                            end loop;
                            if ones >= 3 then
                                majority_bit <= '1';
                            else
                                majority_bit <= '0';
                            end if;
                            shift_en <= '1';
                            sample_idx <= 0;

                            -- Move to next bit
                            if bit_cnt = 7 then
                                bit_cnt <= 0;
                                if parity_enable = '1' then
                                    state <= parity;
                                else
                                    state <= stop;
                                end if;
                            else
                                bit_cnt <= bit_cnt + 1;
                            end if;
                        end if;

                    when parity =>
                        if tick_cnt = 3 then
                            parity_bit_rx <= rx_sync;
                            state <= stop;
                        end if;

                    when stop =>
                        if tick_cnt = 3 then
                            -- STOP bit must be high
                            if rx_sync = '1' then
                                -- Parity check
                                if parity_enable = '1' then
                                    if parity_even = '1' then
                                        if calc_parity(sh_data) = parity_bit_rx then
                                            data_ready_i <= '1';
                                        else
                                            LEDR0 <= '1'; -- parity error
                                        end if;
                                    else
                                        if calc_parity(sh_data) /= parity_bit_rx then
                                            data_ready_i <= '1';
                                        else
                                            LEDR0 <= '1';
                                        end if;
                                    end if;
                                else
                                    data_ready_i <= '1';
                                end if;
                                sh_clear <= '1';
                            end if;
                            state <= idle;
                        end if;

                    when others =>
                        state <= idle;
                end case;

            end if;
        end if;
    end process;

    -- Data output
    process(clk)
    begin
        if rising_edge(clk) then
            if data_ready_i = '1' then
                data_bus <= sh_data;
            
            -- keep data on data bus longer
            elsif baud_tick_8x = '1' then 
                data_bus <= (others => '0');
            end if;
        end if;
    end process;

    -- had multiple drivers so commented out
    -- LEDR0 <= '0'; -- Could use to flag parity error 
    data_ready <= data_ready_i;

end architecture;
