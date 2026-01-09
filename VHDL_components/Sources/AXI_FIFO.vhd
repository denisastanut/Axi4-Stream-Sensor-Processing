-- FIFO MEMORY

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity AXI_FIFO is
    Port ( clk : in STD_LOGIC;
           resetn : in STD_LOGIC;
           s_axis_tvalid : in STD_LOGIC;
           s_axis_tready : out STD_LOGIC;
           s_axis_tdata : in STD_LOGIC_VECTOR(31 downto 0);
           m_axis_tvalid : out STD_LOGIC;
           m_axis_tready : in STD_LOGIC;
           m_axis_tdata : out STD_LOGIC_VECTOR(31 downto 0);
           fifo_full : out STD_LOGIC;
           fifo_empty : out STD_LOGIC
    );
end AXI_FIFO;


architecture architecture_fifo of AXI_FIFO is

    type fifo_array is array(0 to 15) of STD_LOGIC_VECTOR(31 downto 0);
    signal fifo : fifo_array := (others => (others => '0'));

    signal wr_ptr, rd_ptr : integer range 0 to 15 := 0;
    signal count : integer range 0 to 16 := 0;

    signal s_tready_int : STD_LOGIC;
    signal m_tvalid_int : STD_LOGIC;

begin

    s_axis_tready <= s_tready_int;
    m_axis_tvalid <= m_tvalid_int;
    m_axis_tdata  <= fifo(rd_ptr);

    s_tready_int <= '1' when count < 16 else '0';
    m_tvalid_int <= '1' when count > 0 else '0';

    fifo_full <= '1' when count = 16 else '0';
    fifo_empty <= '1' when count = 0 else '0';

    process(clk, resetn)
    begin
        if resetn = '0' then
            wr_ptr <= 0;
            rd_ptr <= 0;
            count <= 0;
        elsif rising_edge(clk) then

            -- scriere in FIFO (doar daca exista loc)
            if (s_axis_tvalid = '1' and s_tready_int = '1') then
                fifo(wr_ptr) <= s_axis_tdata;
                if wr_ptr = 15 then
                    wr_ptr <= 0;
                else
                    wr_ptr <= wr_ptr + 1;
                end if;
                if count < 16 then
                    count <= count + 1;
                end if;
            end if;

            -- citire din FIFO (doar daca valid si ready)
            if (m_tvalid_int = '1' and m_axis_tready = '1') then
                if rd_ptr = 15 then
                    rd_ptr <= 0;
                else
                    rd_ptr <= rd_ptr + 1;
                end if;
                if count > 0 then
                    count <= count - 1;
                end if;
            end if;

        end if;
    end process;

end architecture_fifo;
