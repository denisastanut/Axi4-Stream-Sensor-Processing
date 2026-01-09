-- Testbench FIFO MEMORY

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity FIFO_tb is
end FIFO_tb;


architecture architecture_fifo_tb of FIFO_tb is

    component AXI_FIFO is
        Port ( clk : in STD_LOGIC;
               resetn : in STD_LOGIC;
               s_axis_tvalid : in STD_LOGIC;
               s_axis_tready : out STD_LOGIC;
               s_axis_tdata : in STD_LOGIC_VECTOR(31 downto 0);
               m_axis_tvalid : out STD_LOGIC;
               m_axis_tready : in STD_LOGIC;
               m_axis_tdata : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    signal clk : STD_LOGIC := '0';
    signal resetn : STD_LOGIC := '0';

    signal tvalid_in : STD_LOGIC := '0';
    signal tready_in : STD_LOGIC;
    signal tdata_in : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

    signal tvalid_out : STD_LOGIC;
    signal tready_out : STD_LOGIC := '0';
    signal tdata_out : STD_LOGIC_VECTOR(31 downto 0);

    constant clk_period : time := 10 ns;

begin

    DUT : AXI_FIFO port map (
        clk => clk,
        resetn => resetn,
        s_axis_tvalid => tvalid_in,
        s_axis_tready => tready_in,
        s_axis_tdata => tdata_in,
        m_axis_tvalid => tvalid_out,
        m_axis_tready => tready_out,
        m_axis_tdata => tdata_out
    );

    clk <= not clk after clk_period/2;

    proc_reset : process
    begin
        resetn <= '0';
        wait for 40 ns;
        resetn <= '1';
        wait;
    end process;

    proc_sim : process
    begin
        wait until resetn = '1';
        wait for 20 ns;

        tvalid_in <= '1';

        -- write 4 values
        tdata_in <= x"0000000A"; 
        wait for clk_period;
        tdata_in <= x"00000014"; 
        wait for clk_period;
        tdata_in <= x"0000001E"; 
        wait for clk_period;
        tdata_in <= x"00000028"; 
        wait for clk_period;

        tvalid_in <= '0';
        wait for 40 ns;

        --read from FIFO
        tready_out <= '1';
        wait for 8 * clk_period;

        tready_out <= '0';
        wait for 50 ns;

        tvalid_in <= '1';
        tdata_in <= x"00000032"; 
        wait for clk_period;
        tdata_in <= x"0000003C"; 
        wait for clk_period;
        tvalid_in <= '0';

        wait for 20 ns;

        tready_out <= '1';
        wait for 50 ns;

        tready_out <= '0';

        wait;
    end process;

end architecture_fifo_tb;
