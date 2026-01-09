-- Testbench CONVERTER

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity UART_to_AXI_tb is
end UART_to_AXI_tb;


architecture architecture_uart_axi_tb of UART_to_AXI_tb is

    component UART_to_AXI
        Port ( clk : in STD_LOGIC;
               resetn : in STD_LOGIC;
               packet_in : in STD_LOGIC_VECTOR(15 downto 0);
               packet_valid : in STD_LOGIC;
               m_axis_tvalid : out STD_LOGIC;
               m_axis_tready : in STD_LOGIC;
               m_axis_tdata : out STD_LOGIC_VECTOR(31 downto 0));
    end component;

    signal clk : STD_LOGIC := '0';
    signal resetn : STD_LOGIC := '0';
    signal packet_in : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal packet_valid : STD_LOGIC := '0';
    signal tvalid : STD_LOGIC;
    signal tready : STD_LOGIC := '1';
    signal tdata : STD_LOGIC_VECTOR(31 downto 0);

    constant clk_period : time := 10 ns;

begin
    CONV: UART_to_AXI port map(
        clk => clk,
        resetn => resetn,
        packet_in => packet_in,
        packet_valid => packet_valid,
        m_axis_tvalid => tvalid,
        m_axis_tready => tready,
        m_axis_tdata => tdata);

    clk <= not clk after clk_period/2;

    proc_sim : process
    begin
        resetn <= '0';
        wait for 50 ns;
        resetn <= '1';
        wait for 20 ns;

        packet_in <= X"1234";
        packet_valid <= '1';
        wait for clk_period;
        packet_valid <= '0';
        wait for 40 ns;

        packet_in <= X"00A5";
        packet_valid <= '1';
        wait for clk_period;
        packet_valid <= '0';
        wait for 40 ns;

        packet_in <= X"ABCD";
        packet_valid <= '1';
        wait for clk_period;
        packet_valid <= '0';

        wait;
    end process;

end architecture_uart_axi_tb;
