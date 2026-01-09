-- TOP

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Top_Basys3 is
    Port ( clk : in STD_LOGIC;
           reset_btn : in STD_LOGIC;
           btn_reset_maxmin : in STD_LOGIC;
           rx : in STD_LOGIC;
           sw : in STD_LOGIC_VECTOR(2 downto 0);
           led : out STD_LOGIC_VECTOR(15 downto 0);  
           cat : out STD_LOGIC_VECTOR(6 downto 0);
           an : out STD_LOGIC_VECTOR(3 downto 0);
           dp : out STD_LOGIC);
end Top_Basys3;


architecture architecture_top of Top_Basys3 is

    signal aresetn : STD_LOGIC;
    signal en_reset : STD_LOGIC;
    signal rx_data : STD_LOGIC_VECTOR(7 downto 0);
    signal rx_valid : STD_LOGIC;
    signal packet_data : STD_LOGIC_VECTOR(15 downto 0);
    signal packet_valid : STD_LOGIC;
    signal packet_error : STD_LOGIC;
    signal packet_error_hold : STD_LOGIC := '0';

    signal tvalid1, tvalid2, tvalid3 : STD_LOGIC;
    signal tready1, tready2, tready3 : STD_LOGIC;
    signal tdata1, tdata2, tdata3 : STD_LOGIC_VECTOR(31 downto 0);
    signal fifo_full, fifo_empty : STD_LOGIC;

    signal buffer_index : integer range 0 to 15 := 0;
    signal digits : STD_LOGIC_VECTOR(15 downto 0);
    signal temp_value : STD_LOGIC_VECTOR(15 downto 0);
    signal current_packet : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal display_value : STD_LOGIC_VECTOR(15 downto 0);

    signal led_pattern : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal led_output : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal blink_counter : unsigned(23 downto 0) := (others => '0');
    signal blink_state : STD_LOGIC := '0';
    
    signal max_val, min_val : STD_LOGIC_VECTOR(31 downto 0);
    signal max_valid, min_valid : STD_LOGIC;
    signal en_rst_mm : STD_LOGIC;
    signal aresetn_maxmin : STD_LOGIC;
    signal tvalid_mm : STD_LOGIC;
    signal tdata_mm  : STD_LOGIC_VECTOR(31 downto 0);
    
    signal ssd_digits : STD_LOGIC_VECTOR(15 downto 0);
    constant SSD_E : STD_LOGIC_VECTOR(3 downto 0) := "1110";
    constant SSD_r : STD_LOGIC_VECTOR(3 downto 0) := "1010";
    constant SSD_F : STD_LOGIC_VECTOR(3 downto 0) := "1111";
    constant SSD_U : STD_LOGIC_VECTOR(3 downto 0) := "1101";
    constant SSD_L : STD_LOGIC_VECTOR(3 downto 0) := "1100";

    component debouncer
        Port ( clk : in STD_LOGIC;
               btn : in STD_LOGIC;
               en : out STD_LOGIC );
    end component;

    component UART_receiver
        Port ( clk : in STD_LOGIC;
               resetn : in STD_LOGIC;
               rx : in STD_LOGIC;
               data_out : out STD_LOGIC_VECTOR(7 downto 0);
               data_valid : out STD_LOGIC );
    end component;

    component Packet_Decoder
        Port ( clk : in STD_LOGIC;
               resetn : in STD_LOGIC;
               data_in : in STD_LOGIC_VECTOR(7 downto 0);
               data_valid : in STD_LOGIC;
               packet_out : out STD_LOGIC_VECTOR(15 downto 0);
               packet_valid : out STD_LOGIC;
               packet_error : out STD_LOGIC );
    end component;

    component UART_to_AXI
        Port ( clk : in STD_LOGIC;
               resetn : in STD_LOGIC;
               packet_in : in STD_LOGIC_VECTOR(15 downto 0);
               packet_valid : in STD_LOGIC;
               m_axis_tvalid : out STD_LOGIC;
               m_axis_tready : in STD_LOGIC;
               m_axis_tdata : out STD_LOGIC_VECTOR(31 downto 0));
    end component;

    component AXI_FIFO
        Port ( clk : in STD_LOGIC;
               resetn : in STD_LOGIC;
               s_axis_tvalid : in STD_LOGIC;
               s_axis_tready : out STD_LOGIC;
               s_axis_tdata : in STD_LOGIC_VECTOR(31 downto 0);
               m_axis_tvalid : out STD_LOGIC;
               m_axis_tready : in STD_LOGIC;
               m_axis_tdata : out STD_LOGIC_VECTOR(31 downto 0);
               fifo_full : out STD_LOGIC;
               fifo_empty : out STD_LOGIC);
    end component;

    component Sliding_Average_AXI
        generic ( WINDOW_SIZE : integer := 16 );
        Port ( aclk : in STD_LOGIC;
               aresetn : in STD_LOGIC;
               s_axis_tvalid : in STD_LOGIC;
               s_axis_tready : out STD_LOGIC;
               s_axis_tdata : in STD_LOGIC_VECTOR(31 downto 0);
               m_axis_tvalid : out STD_LOGIC;
               m_axis_tready : in STD_LOGIC;
               m_axis_tdata : out STD_LOGIC_VECTOR(31 downto 0));
    end component;
    
    component Max_AXI is
        Port ( aclk : in STD_LOGIC;
               aresetn : in STD_LOGIC;
               s_axis_tvalid : in STD_LOGIC;
               s_axis_tready : out STD_LOGIC;
               s_axis_tdata : in STD_LOGIC_VECTOR(31 downto 0);
               m_axis_tvalid : out STD_LOGIC;
               m_axis_tready : in STD_LOGIC;
               m_axis_tdata : out STD_LOGIC_VECTOR(31 downto 0));
    end component;
    
    component Min_AXI is
        Port ( aclk : in STD_LOGIC;
               aresetn : in STD_LOGIC;
               s_axis_tvalid : in STD_LOGIC;
               s_axis_tready : out STD_LOGIC;
               s_axis_tdata : in STD_LOGIC_VECTOR(31 downto 0);
               m_axis_tvalid : out STD_LOGIC;
               m_axis_tready : in STD_LOGIC;
               m_axis_tdata : out STD_LOGIC_VECTOR(31 downto 0));
    end component;

    component display_7seg
        Port ( digit0 : in STD_LOGIC_VECTOR(3 downto 0);
               digit1 : in STD_LOGIC_VECTOR(3 downto 0);
               digit2 : in STD_LOGIC_VECTOR(3 downto 0);
               digit3 : in STD_LOGIC_VECTOR(3 downto 0);
               clk : in STD_LOGIC;
               cat : out STD_LOGIC_VECTOR(6 downto 0);
               an : out STD_LOGIC_VECTOR(3 downto 0);
               dp : out STD_LOGIC);
    end component;

begin

    RST_BTN : debouncer port map(
        clk => clk,
        btn => reset_btn,
        en  => en_reset
    );
    
    BTN_RST_MM : debouncer port map(
        clk => clk,
        btn => btn_reset_maxmin,
        en  => en_rst_mm
    );

    aresetn <= not en_reset;
    aresetn_maxmin <= not en_rst_mm;

    REC : UART_receiver port map(
        clk => clk,
        resetn => aresetn,
        rx => rx,
        data_out => rx_data,
        data_valid => rx_valid
    );

    PDEC : Packet_Decoder port map(
        clk => clk,
        resetn => aresetn,
        data_in => rx_data,
        data_valid => rx_valid,
        packet_out => packet_data,
        packet_valid => packet_valid,
        packet_error => packet_error
    );

    UART_AXI : UART_to_AXI port map(
        clk => clk,
        resetn => aresetn,
        packet_in => packet_data,
        packet_valid => packet_valid,
        m_axis_tvalid => tvalid1,
        m_axis_tready => tready1,
        m_axis_tdata => tdata1);

    FIFO : AXI_FIFO port map(
        clk => clk,
        resetn => aresetn,
        s_axis_tvalid => tvalid1,
        s_axis_tready => tready1,
        s_axis_tdata  => tdata1,
        m_axis_tvalid => tvalid2,
        m_axis_tready => tready2,
        m_axis_tdata => tdata2,
        fifo_full => fifo_full,
        fifo_empty => fifo_empty);
    
    tvalid_mm <= tvalid2;
    tdata_mm <= tdata2;
        
    MAX : Max_AXI port map(
        aclk => clk,
        aresetn => aresetn_maxmin,
        s_axis_tvalid => tvalid_mm,
        s_axis_tready => open,
        s_axis_tdata => tdata_mm,
        m_axis_tvalid => max_valid,
        m_axis_tready => '1',
        m_axis_tdata => max_val
    );
    
    MIN : Min_AXI port map(
        aclk => clk,
        aresetn => aresetn_maxmin,
        s_axis_tvalid => tvalid_mm,
        s_axis_tready => open,
        s_axis_tdata => tdata_mm,
        m_axis_tvalid => min_valid,
        m_axis_tready => '1',
        m_axis_tdata => min_val
    );

    AVG : Sliding_Average_AXI
        generic map ( WINDOW_SIZE => 16 )
        port map(
            aclk => clk,
            aresetn => aresetn,
            s_axis_tvalid => tvalid2,
            s_axis_tready => tready2,
            s_axis_tdata => tdata2,
            m_axis_tvalid => tvalid3,
            m_axis_tready => tready3,
            m_axis_tdata => tdata3);

    tready3 <= '1';
    temp_value <= tdata3(15 downto 0);

    -- proces pentru memorarea erorilor de pachet
    -- daca apare o eroare, o tinem minte pana cand vine un pachet valid
    process(clk, aresetn)
    begin
        if aresetn = '0' then
            packet_error_hold <= '0';
        elsif rising_edge(clk) then
            if packet_error = '1' then
                packet_error_hold <= '1';
            elsif packet_valid = '1' then
                packet_error_hold <= '0';
            end if;
        end if;
    end process;


    -- proces pentru salvarea valorii pachetului curent
    -- cand semnalul packet_valid este activ, actualizam variabila interna
    process(clk, aresetn)
    begin
        if aresetn = '0' then
            current_packet <= (others => '0');
        elsif rising_edge(clk) then
            if packet_valid = '1' then
                current_packet <= packet_data;
            end if;
        end if;
    end process;


    -- MUX pentru alegerea valorii afisate pe SSD in functie de switch-uri
    process(sw, current_packet, temp_value, max_val, min_val)
    begin
        if sw(2) = '1' then
            display_value <= min_val(15 downto 0);
        elsif sw(1) = '1' then
            display_value <= max_val(15 downto 0);
        elsif sw(0) = '1' then
            display_value <= temp_value;
        else
            display_value <= current_packet;
        end if;
    end process;


    -- logica pentru aprinderea LED-urilor
    -- la fiecare pachet valid se aprinde un LED nou pana se umple buffer-ul (16 pozitii)
    process(clk, aresetn)
    begin
        if aresetn = '0' then
            buffer_index <= 0;
            led_pattern <= (others => '0');
        elsif rising_edge(clk) then
            if packet_valid = '1' then
                led_pattern(buffer_index) <= '1';
                if buffer_index = 15 then
                    buffer_index <= 0;
                    led_pattern <= (others => '0');
                else
                    buffer_index <= buffer_index + 1;
                end if;
            end if;
        end if;
    end process;


    -- generator de semnal pentru blink
    process(clk, aresetn)
    begin
        if aresetn = '0' then
            blink_counter <= (others => '0');
            blink_state <= '0';
        elsif rising_edge(clk) then
            blink_counter <= blink_counter + 1;
            if blink_counter(23 downto 22) = "00" then
                blink_state <= '1';
            else
                blink_state <= '0';
            end if;
        end if;
    end process;
    
    
    led <= led_output;


    -- conversia valorii binare in cifre zecimale (BCD) pentru SSD
    -- gestioneaza afisarea mesajelor de eroare "Err" sau "FULL"
    process(clk)
        variable temp_val : integer range 0 to 65535;
        variable digit_0, digit_1, digit_2, digit_3 : integer range 0 to 9;
    begin
        if rising_edge(clk) then
            if packet_error_hold = '1' then
                digits <= SSD_E & SSD_r & SSD_r & "1111";
            elsif fifo_full = '1' then
                digits <= SSD_F & SSD_U & SSD_L & SSD_L;
            else
                temp_val := to_integer(unsigned(display_value));
                digit_0 := temp_val mod 10;
                digit_1 := (temp_val / 10) mod 10;
                digit_2 := (temp_val / 100) mod 10;
                digit_3 := (temp_val / 1000) mod 10;
                digits(3 downto 0) <= std_logic_vector(to_unsigned(digit_0, 4));
                digits(7 downto 4) <= std_logic_vector(to_unsigned(digit_1, 4));
                digits(11 downto 8) <= std_logic_vector(to_unsigned(digit_2, 4));
                digits(15 downto 12) <= std_logic_vector(to_unsigned(digit_3, 4));
            end if;
        end if;
    end process;
    
    
    ssd_digits <= digits;


    SSD : display_7seg port map(
        digit0 => ssd_digits(3 downto 0),
        digit1 => ssd_digits(7 downto 4),
        digit2 => ssd_digits(11 downto 8),
        digit3 => ssd_digits(15 downto 12),
        clk => clk,
        cat => cat,
        an => an,
        dp => dp
    );

end architecture_top;