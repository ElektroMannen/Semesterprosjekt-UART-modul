library ieee;
use ieee.std_logic_1164.all;

entity uart_tb is
end entity;

architecture sim of uart_tb is

    signal sys_clk : std_logic := '0';
    signal rst_n : std_logic := '0'; --rst low active
    signal Rx_D : std_logic := '1'; --idle
    signal SW0 : std_logic := '0';
    signal SW1 : std_logic := '0';

    signal Tx_D : std_logic;
    signal LEDR0 : std_logic;
    signal SEG0 : std_logic_vector(7 downto 0);
    signal SEG1 : std_logic_vector(7 downto 0);

begin
    sys_clk <= not sys_clk after 10 ns; --50MHz clk

    DUT : entity work.uart
        port map(
            sys_clk => sys_clk,
            rst_n   => rst_n,
            Rx_D    => Rx_D,
            SW0     => SW0,
            SW1     => SW1,
            Tx_D    => Tx_D,
            LEDR0   => LEDR0,
            SEG0    => SEG0,
            SEG1    => SEG1
        );

    stim : process
    begin

        rst_n <= '0';
        wait for 50 us;
        rst_n <= '1';

        wait for 150 us;

        --baudrate 9600 simple test
        --start byte
        Rx_D <= '0';
        wait for 104 us;

        --0x51 (0b01010001)
        Rx_D <= '1';
        wait for 104 us;
        Rx_D <= '0';
        wait for 104 us;
        Rx_D <= '0';
        wait for 104 us;
        Rx_D <= '0';
        wait for 104 us;
        Rx_D <= '1';
        wait for 104 us;
        Rx_D <= '0';
        wait for 104 us;
        Rx_D <= '1';
        wait for 104 us;
        Rx_D <= '0';
        wait for 104 us;

        Rx_D <= '1';
        wait for 104 us;

        --byte 2 startbit
        Rx_D <= '0';
        wait for 104 us;

        --0x55 (0b01010101)
        Rx_D <= '1';
        wait for 104 us;
        Rx_D <= '0';
        wait for 104 us;
        Rx_D <= '1';
        wait for 104 us;
        Rx_D <= '0';
        wait for 104 us;
        Rx_D <= '1';
        wait for 104 us;
        Rx_D <= '0';
        wait for 104 us;
        Rx_D <= '1';
        wait for 104 us;
        Rx_D <= '0';
        wait for 104 us;

        --stopp
        Rx_D <= '1';
        wait for 104 us;

        wait for 1 ms;
        std.env.stop;
        wait;
    end process;

end architecture;
