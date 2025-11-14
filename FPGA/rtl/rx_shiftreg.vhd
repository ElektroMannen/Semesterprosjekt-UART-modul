library ieee;
use ieee.std_logic_1164.all;

--u_rx ser RxD gå lav
--setter rx_enable høy
--shiftreg leser en byte selv
--sier i fra til u_rx når den er klar 
--og leverer den tilbake


--Receive Data Register (RDR)
--reference https://www.slideserve.com/ilori/uart
entity rx_shiftreg is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;

        -- en puls '1' når vi skal sample/lagre neste bit
        shift_en  : in  std_logic;

        -- seriell bit fra RX-linja (allerede synkronisert)
        rx_bit    : in  std_logic;

        -- parallell byte ut
        data  : out std_logic_vector(7 downto 0);

        -- hvor mange biter er tatt imot (0–7)
        bit_cnt   : out integer range 0 to 7;

        -- blir '1' én klokke når siste (8.) bit er tatt imot
        byte_done : out std_logic
    );
end entity;

architecture rtl of rx_shiftreg is
    signal data_reg      : std_logic_vector(7 downto 0) := (others => '0');
    signal bit_cnt_reg   : integer range 0 to 7 := 0;
    signal byte_done_reg : std_logic := '0';
begin

    process(clk, rst)
    begin
        if rst = '1' then
            data_reg      <= (others => '0');
            bit_cnt_reg   <= 0;
            byte_done_reg <= '0';

        elsif rising_edge(clk) then
            -- default: ingen ny ferdig byte denne syklusen
            byte_done_reg <= '0';

            if shift_en = '1' then
                -- lagre bit på posisjon bit_cnt_reg
                data_reg(bit_cnt_reg) <= rx_bit;

                if bit_cnt_reg = 7 then
                    -- nå har vi tatt imot 8 biter
                    byte_done_reg <= '1';
                    bit_cnt_reg   <= 0;
                else
                    bit_cnt_reg <= bit_cnt_reg + 1;
                end if;
            end if;
        end if;
    end process;

    data      <= data_reg;
    bit_cnt   <= bit_cnt_reg;
    byte_done <= byte_done_reg;

end architecture;
