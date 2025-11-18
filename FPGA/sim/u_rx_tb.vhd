library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity u_rx_tb is
end entity;

architecture sim of u_rx_tb is

    -- Component declarations
    component u_baudgen is
        generic (
            oversample_8x : natural := 8   -- lav verdi for simulering
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
            data_ready   : out std_logic;
            bit_mid      : out std_logic
        );
    end component;

    -- Signals
    signal clk          : std_logic := '0';
    signal rst          : std_logic := '1';
    signal rx_baud_tick : std_logic := '0';
    signal rx_i         : std_logic := '1';
    signal rx_o         : std_logic_vector(7 downto 0);
    signal data_ready   : std_logic;
    signal LEDR0        : std_logic;
    signal bit_mid      : std_logic;

    constant clk_period : time := 20 ns;  -- 50 MHz

begin

    -- Clock generation
    clk <= not clk after clk_period/2;

    -- Baud generator
    BAUD_INST : u_baudgen
        generic map(oversample_8x => 8) -- rask for simulering
        port map(
            clk => clk,
            rst => rst,
            rx_baud_tick => rx_baud_tick,
            tx_baud_tick => open
        );

    -- RX module
    RX_INST : u_rx
        port map(
            clk => clk,
            rst => rst,
            rx_baud_tick => rx_baud_tick,
            rx_i => rx_i,
            rx_o => rx_o,
            LEDR0 => LEDR0,
            data_ready => data_ready,
            bit_mid => bit_mid
        );

    ----------------------------------------------------------------
    -- Continuous stimulus: send bytes 0xA5, 0x3C, 0xFF repeatedly
    ----------------------------------------------------------------
    stimulus: process
        type byte_array is array (natural range <>) of std_logic_vector(7 downto 0);
        constant test_data : byte_array := (x"A5", x"3C", x"FF");
        variable byte_idx : integer := 0;
        variable bit_idx  : integer;
        variable os_tick  : integer;
        constant num_os   : integer := 8; -- 8x oversampling
    begin
        -- Reset
        rst <= '1';
        wait for 200 ns;
        rst <= '0';
        wait for 200 ns;

        loop
            -- Send one byte
            for bit_idx in -1 to 7 loop
                if bit_idx = -1 then
                    rx_i <= '0'; -- start bit
                else
                    rx_i <= test_data(byte_idx)(bit_idx); -- data bits LSB first
                end if;

                -- Hold bit for 8 rx_baud_ticks
                for os_tick in 0 to num_os-1 loop
                    wait until rising_edge(rx_baud_tick);
                end loop;
            end loop;

            -- Stop bit
            rx_i <= '1';
            for os_tick in 0 to num_os-1 loop
                wait until rising_edge(rx_baud_tick);
            end loop;

            -- Move to next byte
            byte_idx := (byte_idx + 1) mod test_data'length;
        end loop;
    end process;

end architecture;
