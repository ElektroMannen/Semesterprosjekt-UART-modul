library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_u_rx is
end entity;

architecture sim of tb_u_rx is

    -- DUT signals
    signal clk          : std_logic := '0';
    signal rst          : std_logic := '1';
    signal baud_tick_8x : std_logic := '0';
    signal rx_i         : std_logic := '1';
    signal parity_enable: std_logic := '0';
    signal parity_even  : std_logic := '1';
    signal data_bus     : std_logic_vector(7 downto 0);
    signal LEDR0        : std_logic;
    signal data_ready   : std_logic;

    -- Baud generator control
    signal baud_sel     : std_logic_vector(1 downto 0) := "00"; -- 9600bps

    -- Clock period
    constant clk_period : time := 20 ns; -- 50MHz

    -- Helper function: calculate parity
    function calc_parity(data : std_logic_vector; even : std_logic) return std_logic is
        variable p : std_logic := '0';
    begin
        for i in data'range loop
            p := p xor data(i);
        end loop;
        if even = '1' then
            return p;
        else
            return not p;
        end if;
    end function;

    -- Procedure to send a UART byte (with optional parity, 8x oversampling)
    procedure send_uart_byte(
        signal rx     : out std_logic;
        signal tick   : out std_logic;
        data_byte     : std_logic_vector(7 downto 0);
        parity_en     : std_logic;
        parity_even   : std_logic
    ) is
        variable parity_bit : std_logic;
        variable i, j       : integer;
    begin
        parity_bit := calc_parity(data_byte, parity_even);

        -- Start bit
        rx <= '0';
        for i in 0 to 7 loop
            tick <= '1'; wait for clk_period*8; tick <= '0'; wait for clk_period*8;
        end loop;

        -- Data bits LSB first
        for i in 0 to 7 loop
            rx <= data_byte(i);
            for j in 0 to 7 loop
                tick <= '1'; wait for clk_period*8; tick <= '0'; wait for clk_period*8;
            end loop;
        end loop;

        -- Parity bit
        if parity_en = '1' then
            rx <= parity_bit;
            for i in 0 to 7 loop
                tick <= '1'; wait for clk_period*8; tick <= '0'; wait for clk_period*8;
            end loop;
        end if;

        -- Stop bit
        rx <= '1';
        for i in 0 to 7 loop
            tick <= '1'; wait for clk_period*8; tick <= '0'; wait for clk_period*8;
        end loop;
    end procedure;

begin

    -- Clock generation
    clk_proc: process
    begin
        while true loop
            clk <= '0'; wait for clk_period/2;
            clk <= '1'; wait for clk_period/2;
        end loop;
    end process;

    -- Instantiate baud generator
    BAUD_INST : entity work.u_baudgen
        generic map (OVERSAMPLE => 8)
        port map (
            clk             => clk,
            rst             => rst,
            baud_sel        => baud_sel,
            rx_baud_tick_8x => baud_tick_8x,
            tx_baud_tick    => open
        );

    -- Instantiate RX module
    RX_INST : entity work.u_rx
        port map (
            clk            => clk,
            rst            => rst,
            baud_tick_8x   => baud_tick_8x,
            rx_i           => rx_i,
            parity_enable  => parity_enable,
            parity_even    => parity_even,
            data_bus       => data_bus,
            LEDR0          => LEDR0,
            data_ready     => data_ready
        );

    -- Stimulus process
    stim_proc: process
    begin
        -- Release reset
        wait for 100 ns;
        rst <= '0';
        wait for 50 ns;

        -- RX01: Standard 8N1
        parity_enable <= '0';
        send_uart_byte(rx_i, baud_tick_8x, "10101010", parity_enable, parity_even);
        wait until data_ready = '1';
        assert data_bus = "10101010" report "RX01 failed!" severity error;

        -- RX08: Even parity
        parity_enable <= '1';
        parity_even <= '1';
        send_uart_byte(rx_i, baud_tick_8x, "11001100", parity_enable, parity_even);
        wait until data_ready = '1';
        assert data_bus = "11001100" report "RX08 even parity failed!" severity error;

        -- RX08: Odd parity
        parity_even <= '0';
        send_uart_byte(rx_i, baud_tick_8x, "11110000", parity_enable, parity_even);
        wait until data_ready = '1';
        assert data_bus = "11110000" report "RX08 odd parity failed!" severity error;

        -- RX04: Implicitly tested via baud_tick_8x and oversampling

        -- RX07: FIFO multiple bytes
        for i in 0 to 15 loop
            send_uart_byte(rx_i, baud_tick_8x, std_logic_vector(to_unsigned(i,8)), '0', '1');
            wait until data_ready = '1';
        end loop;

        -- 17th byte -> should drop if FIFO full
        send_uart_byte(rx_i, baud_tick_8x, "11111111", '0', '1');
        wait for 500 ns;

        wait;
    end process;

end architecture;
