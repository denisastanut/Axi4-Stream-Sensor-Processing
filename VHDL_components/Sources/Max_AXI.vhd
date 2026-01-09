-- MAX

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Max_AXI is
    Port ( aclk : in STD_LOGIC;
           aresetn : in STD_LOGIC;
           s_axis_tvalid : in STD_LOGIC;
           s_axis_tready : out STD_LOGIC;
           s_axis_tdata : in STD_LOGIC_VECTOR(31 downto 0);
           m_axis_tvalid : out STD_LOGIC;
           m_axis_tready : in STD_LOGIC;
           m_axis_tdata : out STD_LOGIC_VECTOR(31 downto 0));
end Max_AXI;


architecture arch_max of Max_AXI is

    signal max_value : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal valid_out : STD_LOGIC := '0';
    signal first_value : STD_LOGIC := '0';
    
begin
    
    s_axis_tready <= '1';
    m_axis_tvalid <= valid_out;
    m_axis_tdata <= max_value;
    
    process(aclk, aresetn)
    begin
        if aresetn = '0' then
            max_value <= (others => '0');
            valid_out <= '0';
            first_value <= '0';
            
        elsif rising_edge(aclk) then
            if s_axis_tvalid = '1' then
                -- init cu prima valoare primita
                if first_value = '0' then
                    max_value <= s_axis_tdata;
                    first_value <= '1';
                -- comparam si actualizam
                elsif unsigned(s_axis_tdata) > unsigned(max_value) then
                    max_value <= s_axis_tdata;
                end if;
                valid_out <= '1';
                
            elsif m_axis_tready = '1' then
                valid_out <= '0';
            end if;
        end if;
    end process;
    
end arch_max;