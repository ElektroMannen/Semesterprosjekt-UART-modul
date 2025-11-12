library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Entity of testbench (empty)
entity u_baudgen_tb is
end entity;


--Baud rate generator testbench
--examine 8x oversample tick 
architecture SimulationModel of u_baudgen_tb is

constant t_clk : time := 20 ns; --simulate 50MHz clock
constant oversample_8x  : natural := 651; --8x oversample @9600 baudrate


--component u_baudgen
--	--generics
--  generic (oversample_8x  : natural := 651);
--	--ports
--  port (
--    clk	:	in std_logic;
--		rst_n 	:	in std_logic;
--		tick	:	out std_logic
--	);
--end component u_baudgen;

signal clk: std_logic;
signal rst_n : std_logic := '0';
signal tick_8x: std_logic := '0';

begin

  --u_baudgen_test: component u_baudgen
  --port map (
  --  clk => clk,
  --  rst_n => rst_n,
  --  tick => tick_8x
  --);

  u_baudgen_test: entity work.u_baudgen
    generic map (oversample_8x => 651)
    port map (
      clk => clk,
      rst_n => rst_n,
      tick => tick_8x
    );

	
  -- klokkesignalgenerator
  p_clk: process
  begin
    clk <= '0';
    wait for t_clk/2; -- hvert 10. ns
    clk <= '1';
    wait for t_clk/2;
  end process p_clk;

  -- reset
  p_rst: process
  begin
    rst_n <= '0';
    wait for 5*t_clk; -- hold reset i 100ns
    rst_n <= '1';      -- slipp reset
    wait;
  end process p_rst;

  -- stimul main
  p_main: process
    variable tick_count : natural := oversample_8x-1;
    variable tick_check_ok : std_logic := '0';
  begin
    wait until rst_n = '1'; -- test reset
    wait until rising_edge(clk);

    -- for i in 0 to tick_count loop
    --   wait until rising_edge(clk);
    --   if tick_8x = '1' then
    --     tick_check_ok := '1';
    --   end if;
    -- end loop;

    -- assert tick_check_ok = '1'; --ok ok
    --   report "Seems good"
    --   severity error;
    -- report "Counted correct oversample period" severity note;

    wait for 13200 ns; --651*20ns+some extra

    assert false report "Tb finish" severity failure;
  end process p_main;

end architecture SimulationModel;