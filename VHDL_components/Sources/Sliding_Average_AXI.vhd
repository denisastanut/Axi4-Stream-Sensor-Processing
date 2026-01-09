-- AVERAGE - SLIDING WINDOW

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity Sliding_Average_AXI is
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
end Sliding_Average_AXI;


architecture architecture_sliding_window of Sliding_Average_AXI is

    component Adder_32b is
        Port ( a : in STD_LOGIC_VECTOR (31 downto 0);
               b : in STD_LOGIC_VECTOR (31 downto 0);
               cin : in STD_LOGIC;
               s : out STD_LOGIC_VECTOR (31 downto 0);
               cout : out STD_LOGIC );
    end component;

    component Subtractor_32b is
        Port ( a : in STD_LOGIC_VECTOR (31 downto 0);
               b : in STD_LOGIC_VECTOR (31 downto 0);
               d : out STD_LOGIC_VECTOR (31 downto 0);
               cout : out STD_LOGIC );
    end component;

    component Register_32b is
        Port ( clk : in STD_LOGIC;
               aresetn : in STD_LOGIC;
               en : in STD_LOGIC;
               D : in STD_LOGIC_VECTOR (31 downto 0);
               Q : out STD_LOGIC_VECTOR (31 downto 0));
    end component;

    type win_t is array (0 to WINDOW_SIZE-1) of STD_LOGIC_VECTOR(31 downto 0);
    signal window : win_t := (others => (others => '0'));

    signal ptr : INTEGER range 0 to WINDOW_SIZE-1 := 0;

    signal sum : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal diff : STD_LOGIC_VECTOR(31 downto 0);
    signal new_sum : STD_LOGIC_VECTOR(31 downto 0);

    signal avg_out : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal valid : STD_LOGIC := '0';

    signal co1, co2 : STD_LOGIC;

    signal old_val : STD_LOGIC_VECTOR(31 downto 0);

begin

    -- AXI handshake
    s_axis_tready <= '1';
    m_axis_tvalid <= valid;
    m_axis_tdata  <= avg_out;

    old_val <= window(ptr);

    -- SUM - OLD_VAL
    SUB32 : Subtractor_32b port map (
        a => sum,
        b => old_val,
        d => diff,
        cout => co1
    );

    -- (SUM - OLD_VAL) + NEW_VAL
    ADD32 : Adder_32b port map (
        a => diff,
        b => s_axis_tdata,
        cin => '0',
        s => new_sum,
        cout => co2
    );

    REG_SUM : Register_32b port map (
        clk => aclk,
        aresetn => aresetn,
        en => s_axis_tvalid,
        D => new_sum,
        Q => sum
    );

    process(aclk, aresetn)
    begin
        if aresetn = '0' then
            ptr <= 0;
            valid <= '0';
            avg_out <= (others => '0');

        elsif rising_edge(aclk) then
            
            if s_axis_tvalid = '1' then

                -- actualizeaza bufferul circular
                window(ptr) <= s_axis_tdata;

                if ptr = WINDOW_SIZE-1 then
                    ptr <= 0;
                else
                    ptr <= ptr + 1;
                end if;

                -- media prin shiftare la dreapta cu 4
                avg_out <= "0000" & new_sum(31 downto 4);

                valid <= '1';

            elsif m_axis_tready = '1' then
                valid <= '0';
            end if;

        end if;
    end process;

end architecture_sliding_window;
