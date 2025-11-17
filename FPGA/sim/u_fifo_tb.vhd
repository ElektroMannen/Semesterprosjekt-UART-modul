library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity u_fifo_tb is
end entity;

architecture sim of u_fifo_tb is
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    --signal addr     : std_logic_vector(4 downto 0) := (others => '0');
    signal data_in : std_logic_vector(7 downto 0) := (others => '0');
    signal data_out : std_logic_vector(7 downto 0);
    signal we : std_logic := '0';
    signal re : std_logic := '0';

begin

    DUT : entity work.u_fifo
        port map(
            clk      => clk,
            rst      => rst,
            --addr     => addr,
            data_in  => data_in,
            data_out => data_out,
            we       => we,
            re       => re
        );
    clk_p : process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    stim : process
    begin

        rst <= '1';
        wait for 50 ns;
        rst <= '0';
        wait for 150 ns;

        data_in <= x"AA";
        we <= '1';
        wait for 20 ns;
        we <= '0';
        wait for 20 ns;

        data_in <= x"BB";
        we <= '1';
        wait for 20 ns;
        we <= '0';
        wait for 20 ns;

        re <= '1';
        wait for 20 ns;
        re <= '0';
        wait for 20 ns;


        data_in <= x"FF";
        we <= '1';
        wait for 20 ns;
        we <= '0';
        wait for 20 ns;


        data_in <= x"FF";
        we <= '1';
        wait for 20 ns;
        we <= '0';
        wait for 20 ns;

        data_in <= x"FF";
        we <= '1';
        wait for 20 ns;
        we <= '0';
        wait for 20 ns;

        data_in <= x"FF";
        we <= '1';
        wait for 20 ns;
        we <= '0';
        wait for 20 ns;

        data_in <= x"FF";
        we <= '1';
        wait for 20 ns;
        we <= '0';
        wait for 20 ns;

        data_in <= x"FF";
        we <= '1';
        wait for 20 ns;
        we <= '0';
        wait for 20 ns;

        data_in <= x"FF";
        we <= '1';
        wait for 20 ns;
        we <= '0';
        wait for 20 ns;
        
        data_in <= x"FF";
        we <= '1';
        wait for 20 ns;
        we <= '0';
        wait for 20 ns;


        data_in <= x"FF";
        we <= '1';
        wait for 20 ns;
        we <= '0';
        wait for 20 ns;

        data_in <= x"FF";
        we <= '1';
        wait for 20 ns;
        we <= '0';
        wait for 20 ns;

        data_in <= x"FF";
        we <= '1';
        wait for 20 ns;
        we <= '0';
        wait for 20 ns;

        data_in <= x"FF";
        we <= '1';
        wait for 20 ns;
        we <= '0';
        wait for 20 ns;

        data_in <= x"FF";
        we <= '1';
        wait for 20 ns;
        we <= '0';
        wait for 20 ns;

        data_in <= x"FF";
        we <= '1';
        wait for 20 ns;
        we <= '0';
        wait for 20 ns;
        
        wait for 100 ns;

        re <= '1';
        wait for 20 ns;
        re <= '0';
        wait for 20 ns;        

        re <= '1';
        wait for 20 ns;
        re <= '0';
        wait for 20 ns;

        re <= '1';
        wait for 20 ns;
        re <= '0';
        wait for 20 ns;

        wait for 1 ms;
        std.env.stop;
        wait;
    end process;

end architecture;
