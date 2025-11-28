library ieee;
use ieee.std_logic_1164.all;

entity uart_tb is
end entity;

architecture sim of uart_tb is
    constant t_baud_9600 : time := 104 us; --us
    constant t_baud_115200 : time := 8680 ns;

    signal sys_clk : std_logic := '0';
    signal rst_n : std_logic := '0'; --rst low active
    signal test_n : std_logic := '1';
    signal Rx_D : std_logic := '1'; --idle
    signal SW0 : std_logic := '0';
    signal SW1 : std_logic := '0';

    signal Tx_D : std_logic;
    signal LEDR0 : std_logic;
    signal SEG0 : std_logic_vector(7 downto 0);
    signal SEG1 : std_logic_vector(7 downto 0);
    signal baud_selector : std_logic_vector(1 downto 0);

begin
    sys_clk <= not sys_clk after 10 ns; --50MHz clk

    DUT : entity work.uart
        port map(
            sys_clk => sys_clk,
            rst_n   => rst_n,
            test_n  => test_n,
            Rx_D    => Rx_D,
            SW0     => SW0,
            SW1     => SW1,
            baud_ctrl => baud_selector,
            Tx_D    => Tx_D,
            LEDR0   => LEDR0,
            SEG0    => SEG0,
            SEG1    => SEG1
        );

    stim : process
    begin

        rst_n <= '0';
        baud_selector <= "00";
        wait for 50 us;
        rst_n <= '1';

        wait for 150 us;

        --baudrate 9600 simple test
        --start byte
        Rx_D <= '0';
        wait for t_baud_9600;

        --0x51 (0b01010001)
        Rx_D <= '1';
        wait for t_baud_9600;
        Rx_D <= '0';
        wait for t_baud_9600;
        Rx_D <= '0';
        wait for t_baud_9600;
        Rx_D <= '0';
        wait for t_baud_9600;
        Rx_D <= '1';
        wait for t_baud_9600;
        Rx_D <= '0';
        wait for t_baud_9600;
        Rx_D <= '1';
        wait for t_baud_9600;
        Rx_D <= '0';
        wait for t_baud_9600;

        Rx_D <= '1';
        wait for t_baud_9600;

        --byte 2 startbit
        Rx_D <= '0';
        wait for t_baud_9600;

        --0x55 (0b01010101)
        Rx_D <= '1';
        wait for t_baud_9600;
        Rx_D <= '0';
        wait for t_baud_9600;
        Rx_D <= '1';
        wait for t_baud_9600;
        Rx_D <= '0';
        wait for t_baud_9600;
        Rx_D <= '1';
        test_n <= '0';
        wait for t_baud_9600;
        Rx_D <= '0';
        test_n <= '1';
        wait for t_baud_9600;
        Rx_D <= '1';
        wait for t_baud_9600;
        Rx_D <= '0';
        wait for t_baud_9600;

        --stopp
        Rx_D <= '1';
        wait for t_baud_9600;

        wait for 8*t_baud_9600;



        baud_selector <= "01";


        --baudrate 9600 simple test
        --start byte
        Rx_D <= '0';
        wait for t_baud_115200;

        --0x51 (0b01010001)
        Rx_D <= '1';
        wait for t_baud_115200;
        Rx_D <= '0';
        wait for t_baud_115200;
        Rx_D <= '0';
        wait for t_baud_115200;
        Rx_D <= '0';
        wait for t_baud_115200;
        Rx_D <= '1';
        wait for t_baud_115200;
        Rx_D <= '0';
        wait for t_baud_115200;
        Rx_D <= '1';
        wait for t_baud_115200;
        Rx_D <= '0';
        wait for t_baud_115200;

        Rx_D <= '1';
        wait for t_baud_115200;



        wait for 1 ms;
        std.env.stop;
        wait;
    end process;

end architecture;
