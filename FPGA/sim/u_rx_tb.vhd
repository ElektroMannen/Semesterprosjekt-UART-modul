library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_uart_rx is
end entity;

architecture sim of tb_uart_rx is

    -- DUT components
    component u_baudgen is
        generic (
            oversample_8x : natural := 651
        );
        port (
            clk          : in std_logic;
            rst          : in std_logic;
            rx_baud_tick : out std_logic;
            tx_baud_tick : out std_logic
        );
    end component;

    component u_rx is
        port (
            clk          : in std_logic;
            rst          : in std_logic;
            rx_baud_tick : in std_logic;
            rx_i         : in std_logic;
            rx_o         : out std_logic_vector(7 downto 0);
            LEDR0        : out std_logic;
            data_ready   : out std_logic
        );
    end component;

    -- Testbench signals
    signal clk          : std_logic := '0';
    signal rst          : std_logic := '0';
    signal rx_baud_tick : std_logic;
    signal rx_i         : std_logic := '1';
    signal rx_o         : std_logic_vector(7 downto 0);
    signal data_ready   : std_logic;
    signal LEDR0        : std_logic;

    -- Constants
    constant clk_period : time := 20 ns;  -- 50 MHz
    constant oversample_factor : integer := 8;
    constant bit_time_ticks : integer := 8; -- 8 oversample ticks per bit

begin

    --------------------------------------------------------------------
    -- Clock generation
    --------------------------------------------------------------------
    clk <= not clk after clk_period/2;

    --------------------------------------------------------------------
    -- Instantiate baud generator
    --------------------------------------------------------------------
    U_BAUD : u_baudgen
        generic map(
            oversample_8x => 651  -- 9600 baud, 8x oversampling
        )
        port map(
            clk          => clk,
            rst          => rst,
            rx_baud_tick => rx_baud_tick,
            tx_baud_tick => open
        );

    --------------------------------------------------------------------
    -- Instantiate RX module
    --------------------------------------------------------------------
    U_RX : u_rx
        port map(
            clk          => clk,
            rst          => rst,
            rx_baud_tick => rx_baud_tick,
            rx_i         => rx_i,
            rx_o         => rx_o,
            LEDR0        => LEDR0,
            data_ready   => data_ready
        );

    --------------------------------------------------------------------
    -- UART transmit procedure (bit-banging)
    --------------------------------------------------------------------
    procedure uart_send_byte(signal tx : out std_logic; data_byte : std_logic_vector) is
    begin
        -- Start bit
        tx <= '0';
        wait until rx_baud_tick = '1' for 1 ns;

        for i in 1 to bit_time_ticks-1 loop
            wait until rx_baud_tick = '1' for 1 ns;
        end loop;

        -- Data bits LSB first
        for i in 0 to 7 loop
            tx <= data_byte(i);
            for j in 1 to bit_time_ticks loop
                wait until rx_baud_tick = '1' for 1 ns;
            end loop;
        end loop;

        -- Stop bit
        tx <= '1';
        for j in 1 to bit_time_ticks loop
            wait until rx_baud_tick = '1' for 1 ns;
        end loop;
    end procedure;

    --------------------------------------------------------------------
    -- Test sequence
    --------------------------------------------------------------------
    stimulus : process
        constant test_byte : std_logic_vector(7 downto 0) := x"A5";
    begin

        ----------------------------------------------------------------
        -- Reset
        ----------------------------------------------------------------
        rst <= '1';
        wait for 200 ns;
        rst <= '0';
        wait for 200 ns;

        ----------------------------------------------------------------
        -- Send UART frame
        ----------------------------------------------------------------
        uart_send_byte(rx_i, test_byte);

        ----------------------------------------------------------------
        -- Wait for receiver to finish
        ----------------------------------------------------------------
        wait until data_ready = '1';

        ----------------------------------------------------------------
        -- Check result
        ----------------------------------------------------------------
        assert rx_o = test_byte
            report "ERROR: Received byte does not match!"
            severity failure;

        report "SUCCESS: Received byte = " & to_hstring(rx_o);

        wait;
    end process;

end architecture;
