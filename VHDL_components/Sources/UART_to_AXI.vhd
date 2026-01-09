-- CONVERTER

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity UART_to_AXI is
    Port ( clk : in STD_LOGIC;
           resetn : in STD_LOGIC;
           packet_in : in STD_LOGIC_VECTOR(15 downto 0);
           packet_valid : in STD_LOGIC;
           m_axis_tvalid : out STD_LOGIC;
           m_axis_tready : in STD_LOGIC;
           m_axis_tdata : out STD_LOGIC_VECTOR(31 downto 0)
    );
end UART_to_AXI;


architecture architecture_uart_axi of UART_to_AXI is

    signal valid_int : STD_LOGIC := '0';
    signal data_reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    
begin
    process(clk, resetn)
    begin
        if resetn = '0' then
            valid_int <= '0';
            
        elsif rising_edge(clk) then
            if packet_valid = '1' then
                data_reg <= (others => '0');
                data_reg(15 downto 0) <= packet_in;
                valid_int <= '1';
            elsif valid_int = '1' and m_axis_tready = '1' then
                valid_int <= '0';
            end if;
        end if;
    end process;

    m_axis_tvalid <= valid_int;
    m_axis_tdata <= data_reg;
    
end architecture_uart_axi;
