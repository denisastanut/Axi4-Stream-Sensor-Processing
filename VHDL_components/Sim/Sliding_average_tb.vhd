-- Testbench AVERAGE

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity Sliding_Average_AXI_tb is
end Sliding_Average_AXI_tb;


architecture architecture_sliding_average_tb of Sliding_Average_AXI_tb is

    component Sliding_Average_AXI is
        Generic ( WINDOW_SIZE : integer := 16 );
        Port ( aclk : in STD_LOGIC;
               aresetn : in STD_LOGIC;
               s_axis_tvalid : in STD_LOGIC;
               s_axis_tready : out STD_LOGIC;
               s_axis_tdata  : in STD_LOGIC_VECTOR(31 downto 0);
               m_axis_tvalid : out STD_LOGIC;
               m_axis_tready : in STD_LOGIC;
               m_axis_tdata  : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    signal clk : STD_LOGIC := '0';
    signal resetn : STD_LOGIC := '0';

    signal tvalid_in : STD_LOGIC := '0';
    signal tready_in : STD_LOGIC;
    signal tdata_in : STD_LOGIC_VECTOR(31 downto 0) := (others=>'0');

    signal tvalid_out : STD_LOGIC;
    signal tready_out : STD_LOGIC := '1';
    signal tdata_out : STD_LOGIC_VECTOR(31 downto 0);

    constant clk_period : time := 10 ns;

begin

    AVG: Sliding_Average_AXI
        generic map ( WINDOW_SIZE => 16 )
        port map (
            aclk => clk,
            aresetn => resetn,
            s_axis_tvalid => tvalid_in,
            s_axis_tready => tready_in,
            s_axis_tdata => tdata_in,
            m_axis_tvalid => tvalid_out,
            m_axis_tready => tready_out,
            m_axis_tdata => tdata_out
        );

    clk <= not clk after clk_period/2;

    process
    begin
        resetn <= '0';
        wait for 50 ns;
        resetn <= '1';
        wait for 20 ns;

        tvalid_in <= '1';

        tdata_in <= conv_std_logic_vector(10,32);
        wait for clk_period;

        tdata_in <= conv_std_logic_vector(20,32);
        wait for clk_period;

        tdata_in <= conv_std_logic_vector(30,32);
        wait for clk_period;

        tdata_in <= conv_std_logic_vector(40,32);
        wait for clk_period;

        tdata_in <= conv_std_logic_vector(50,32);
        wait for clk_period;

        tdata_in <= conv_std_logic_vector(60,32);
        wait for clk_period;

        tdata_in <= conv_std_logic_vector(70,32);
        wait for clk_period;

        tdata_in <= conv_std_logic_vector(80,32);
        wait for clk_period;

        tdata_in <= conv_std_logic_vector(90,32);
        wait for clk_period;

        tvalid_in <= '0';

        wait;
    end process;

end architecture_sliding_average_tb;
