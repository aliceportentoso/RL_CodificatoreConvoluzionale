library IEEE; --
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity project_reti_logiche is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        o_done : out std_logic;
        o_en : out std_logic;
        o_we : out std_logic;
        o_data : out std_logic_vector (7 downto 0)
    );
end project_reti_logiche;

architecture b of project_reti_logiche is

    type S is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11);
    signal curr_state, next_state : S;
    signal num_words : std_logic_vector (7 downto 0);
    signal o_r1 : std_logic_vector (7 downto 0);
    signal o_r2 : std_logic_vector (7 downto 0);
    signal address_in : std_logic_vector (15 downto 0);
    signal address_o : std_logic_vector (15 downto 0);
    signal conv: std_logic_vector (15 downto 0);
    signal pre_bit: std_logic_vector (1 downto 0);
    
begin
    -- lettura numero di parole (num_words)
    process(i_clk, i_rst) 
    begin
        if (i_rst = '1' or next_state = S0) then
           num_words <= "11111111";
        elsif (i_clk'event and i_clk = '1') then
            if (curr_state = S2) then
                num_words <= i_data;
            elsif (curr_state = S4) then
                num_words <= num_words - '1';
            end if;
        end if;
    end process;
    
    -- o_r1 (lettura, in S2)
    process (i_clk, i_rst)
    begin
        if (i_rst = '1' or next_state = S0) then
            o_r1 <= "00000000";
        elsif (i_clk'event and i_clk = '1' and curr_state = S5) then
            o_r1 <= i_data;         
        end if;
    end process;
    
    -- address_in
    process (i_clk, i_rst)
    begin
        if (i_rst = '1' or next_state = S0) then
            address_in <= "0000000000000000";
        elsif (i_clk'event and i_clk = '1') then
            if (curr_state = S1) then
                address_in <= "0000000000000000";
            elsif (curr_state = S2 or curr_state = S4) then
                address_in <= address_in + '1';
            end if;
        end if;
    end process;
    
    -- address_o
    process (i_clk, i_rst)
    begin
        if (i_rst = '1' or next_state = S0) then
            address_o <= "0000000000000000";
        elsif (i_clk'event and i_clk = '1') then
            if (curr_state = S1) then
                address_o <= "0000001111101000"; --1000
            elsif (curr_state = S7 or curr_state = S10) then
                address_o <= address_o + '1';
            end if;
        end if;
    end process;
    
    -- o_address
    process (i_clk, i_rst)
    begin
        if (i_rst = '1' or next_state = S0) then
            o_address <= "0000000000000000";
        elsif (i_clk'event and i_clk = '1') then
            if (curr_state = S1) then
                o_address <= "0000000000000000";
            elsif (curr_state = S3) then
                o_address <= address_in;
            elsif (curr_state = S6 or curr_state = S8) then
                o_address <= address_o;
            end if;
        end if;
    end process;
    
    -- pre_bit
    process (i_clk, i_rst)
    begin
        if (i_rst = '1' or next_state = S0) then
            pre_bit <= "00";
        elsif (i_clk'event and i_clk = '1' and curr_state = S4) then
            pre_bit(0) <= o_r1(0);
            pre_bit(1) <= o_r1(1); 
        end if;
    end process;
       
    -- conv
    process (i_clk, i_rst)
    begin
        if (i_rst = '1' or next_state = S0) then
            conv <= "0000000000000000";
        elsif (i_clk'event and i_clk = '1' and curr_state = S6) then
            conv(15) <= o_r1(7) xor pre_bit(1);
            conv(14) <= o_r1(7) xor pre_bit(0) xor pre_bit(1);
            conv(13) <= o_r1(6) xor pre_bit(0);
            conv(12) <= o_r1(6) xor o_r1(7) xor pre_bit(0);
            conv(11) <= o_r1(5) xor o_r1(7);
            conv(10) <= o_r1(5) xor o_r1(6) xor o_r1(7);
            conv(9) <= o_r1(4) xor o_r1(6);
            conv(8) <= o_r1(4) xor o_r1(5) xor o_r1(6);
            conv(7) <= o_r1(3) xor o_r1(5);
            conv(6) <= o_r1(3) xor o_r1(4) xor o_r1(5);
            conv(5) <= o_r1(2) xor o_r1(4);
            conv(4) <= o_r1(2) xor o_r1(3) xor o_r1(4);
            conv(3) <= o_r1(1) xor o_r1(3);
            conv(2) <= o_r1(1) xor o_r1(2) xor o_r1(3);
            conv(1) <= o_r1(0) xor o_r1(2);
            conv(0) <= o_r1(0) xor o_r1(1) xor o_r1(2);
        end if;
    end process;

    -- o_r2
    process (i_clk, i_rst)
        begin
            if (i_rst = '1' or next_state = S0) then
                o_r2 <= "00000000";
            elsif (i_clk'event and i_clk = '1') then
                if (curr_state = S7) then
                    o_r2 <= conv(15 downto 8);
                elsif (curr_state = S9) then
                    o_r2 <= conv (7 downto 0);
                end if;
            end if;
        end process;
   
    
    ---- macchina a stati
    process (i_clk, i_rst)
        begin
        if (i_rst = '1') then
            curr_state <= S0;
        elsif (i_clk'event and i_clk = '1') then
            curr_state <= next_state;
        end if;
    end process;
    
    process (curr_state, i_start)
    begin 
        next_state <= curr_state;
        case curr_state is
            when S0 =>
                if (i_start = '1') then
                    next_state <= S1;
                else
                    next_state <= S0;
                end if;
            when S1 => 
                next_state <= S2;
            when S2 =>
                next_state <= S3;
            when S3 =>
                if (num_words > "00000000") then
                    next_state <= S4;
                else 
                    next_state <= S11;
                end if;
            when S4 =>
                next_state <= S5;
            when S5 =>
                next_state <= S6; 
            when S6 =>
                next_state <= S7; 
            when S7 =>
                next_state <= S8; 
            when S8 =>
                next_state <= S9;
            when S9 =>
                next_state <= S10; 
            when S10 =>
                next_state <= S3;      
            when S11 =>
                if (i_start = '1') then
                    next_state <= S0;
                end if;
            when others =>    
        end case;
    end process;
    
    process (curr_state)
    begin
        o_done <= '0';
        o_en <= '0';
        o_we <= '0';
        o_data <= "00000000";
        
        case curr_state is 
        when S0 => o_en <= '1';
        when S1 => 
        when S2 => o_en <= '1';
        when S3 =>
        when S4 => o_en <= '1';
        when S5 =>
        when S6 =>
        when S7 => 
        when S8 => o_en <= '1';
            o_we <= '1';
            o_data <= o_r2;
        when S9 => 
        when S10 => o_en <= '1';
            o_we <= '1';
            o_data <= o_r2;
        when S11 => 
            o_done <= '1';
            
        when others =>
     
        end case;
    end process;
end b;