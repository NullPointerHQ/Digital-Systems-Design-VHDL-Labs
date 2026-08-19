-- 3 to 8 Decoder --
-- Preprocessing Instructions
library ieee;
use ieee.std_logic_1164.all;

-- Entity Declaration
entity decoder_3to8 is
    port(
        we : in std_logic; -- Write Enable Bit 
        din : in std_logic_vector(2 downto 0); -- 3 Bit Input
        dout : out std_logic_vector (7 downto 0) -- 8 Bit Output
        );
    end decoder_3to8;

-- Architectural Definition
architecture dataflow of decoder_3to8 is 
    signal enw : std_logic_vector (3 downto 0); -- Declares 4-Bit Signal 'ENW'
    begin
        enw <= we & din; -- Combines the Input and 'We' ports.
        dout <= 
                "00000001" when enw = "1000" else -- Port 0
                "00000010" when enw = "1001" else -- Port 1
                "00000100" when enw = "1010" else -- Port 2
                "00001000" when enw = "1011" else -- Port 3
                "00010000" when enw = "1100" else -- Port 4
                "00100000" when enw = "1101" else -- Port 5
                "01000000" when enw = "1110" else -- Port 6
                "10000000" when enw = "1111" else -- Port 7
                "00000000"; --Default Case, Write Disabled OR No Port Was Selected.
    end dataflow;
----------------------------------------------------------------------------------------------
-- Register Module
-- Preprocessing Instructions
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

-- Entity Declaration
entity reg_module is
generic (
    n: integer := 4); -- Generic Variable
    port(
        we : in std_logic; -- Write Enable Bit
        clk : in std_logic; -- Clock Bit
        rst : in std_logic; -- Reset Bit
        din : in std_logic_vector(n - 1 downto 0); -- 'n' Bit Input 
        dout : out std_logic_vector (n - 1 downto 0) -- 'n' Bit Output
        );
    end reg_module;

-- Architectural Definition
architecture behavioral of reg_module is
    begin
        P1: process(rst, clk)
            begin
            -- Reset Register
            if rst = '0' then 
                dout <= "0000";
        
            -- Register Reset Not Required.
            elsif rst = '1' then
                -- Check for 'Rising Edge'
                if rising_edge(clk) then
                    --Check if Write is enabled
                    if we = '1' then
                        dout <= din; -- Update the output
                    end if;
                end if;
            end if;
        end process P1;
    end behavioral;
----------------------------------------------------------------------------------------------
-- 8 to 1 Multiplexer 
-- Preprocessing Instructions
library ieee;
use ieee.std_logic_1164.all;

-- Entity Declaration
entity mux8to1 is
generic (
    n: integer := 4); 
    port(
    addr : in std_logic_vector (2 downto 0); -- 3-Bit Address Input
    -- 8 'n'-Bit inputs
    din_0 : in std_logic_vector(n - 1 downto 0);
    din_1 : in std_logic_vector(n - 1 downto 0);
    din_2 : in std_logic_vector(n - 1 downto 0);
    din_3 : in std_logic_vector(n - 1 downto 0);
    din_4 : in std_logic_vector(n - 1 downto 0);
    din_5 : in std_logic_vector(n - 1 downto 0);
    din_6 : in std_logic_vector(n - 1 downto 0);
    din_7 : in std_logic_vector(n - 1 downto 0);
    
    dout : out std_logic_vector (n - 1 downto 0) -- 'n' Bit Output
            );
    end mux8to1;
    
-- Architectural Definition
architecture dataflow of mux8to1 is
    begin
        dout <=
            din_0 when addr = "000" else -- Multiplexer Port 0
            din_1 when addr = "001" else -- Multiplexer Port 1
            din_2 when addr = "010" else -- Multiplexer Port 2
            din_3 when addr = "011" else -- Multiplexer Port 3
            din_4 when addr = "100" else -- Multiplexer Port 4
            din_5 when addr = "101" else -- Multiplexer Port 5
            din_6 when addr = "110" else -- Multiplexer Port 6
            din_7 when addr = "111" else -- Multiplexer Port 7
            "0000"; -- Default Case
    end dataflow;
----------------------------------------------------------------------------------------------
-- Register File
library ieee;
use ieee.std_logic_1164.all;

-- Entity Declaration
entity reg_file is
--generic (n: integer := 4); 
    port(
    clk : in std_logic; -- Clock Bit
    rst : in std_logic; -- Reset Bit
    we : in std_logic; -- Write Enable Bit
    addr : in std_logic_vector (2 downto 0); -- 3-Bit Address Input
    din : in std_logic_vector(3 downto 0); -- 4 Bit Input
   
    dout : out std_logic_vector (3 downto 0) -- 4 Bit Output
    );
end reg_file;
    
architecture structural of reg_file is
-- Component Declarations
    component decoder_3to8 is 
    port (
        we : in std_logic; -- Write Enable Bit
        din : in std_logic_vector(2 downto 0); -- 3 Bit Input
        dout : out std_logic_vector (7 downto 0)); -- 8 Bit Output
    end component;
    
    component reg_module
    generic (n: integer := 4); 
    port(
        we : in std_logic; -- Write Enable Bit
        clk : in std_logic; -- Clock Bit
        rst : in std_logic; -- Reset Bit
        din : in std_logic_vector(n - 1 downto 0); -- 'n' Bit Input 
        dout : out std_logic_vector (n - 1 downto 0)); -- 'n' Bit Output
    end component; 
    
    component mux8to1
    generic (n: integer := 4); 
    port(
        addr : in std_logic_vector (2 downto 0); -- 3-Bit Address Input
        -- 8 'n' -Bit inputs
        din_0 : in std_logic_vector (n - 1 downto 0);
        din_1 : in std_logic_vector (n - 1 downto 0);
        din_2 : in std_logic_vector (n - 1 downto 0);
        din_3 : in std_logic_vector (n - 1 downto 0);
        din_4 : in std_logic_vector (n - 1 downto 0); 
        din_5 : in std_logic_vector (n - 1 downto 0); 
        din_6 : in std_logic_vector (n - 1 downto 0); 
        din_7 : in std_logic_vector (n - 1 downto 0); 
        
        dout : out std_logic_vector (n - 1 downto 0)); -- 'n' Bit Output
    end component;
    
     
    
    -- Register Outputs Array
    type reg_dout is array (0 to 7) of std_logic_vector (3 downto 0);
    signal decoder_dout : std_logic_vector (7 downto 0); -- Used as the 'WE' for the Registers
    -- Multiplexer Input
    signal mux_din : reg_dout;
    
    

begin
    -- Component Port Maps
    Decoder3to8 : decoder_3to8 port map(
        we => we,
        din => addr,
        dout => decoder_dout); 
    -- Instantiating the 8 Registers Using FOR Loop
    reg_module_gen: for i in 0 to 7 generate   
        reg_module_inst: reg_module
            generic map (n => 4)
            port map(
                we => decoder_dout(i),
                clk => clk,
                rst => rst,
                din => din, 
                dout => mux_din(i));
    end generate;
    --multiplexer_gen: for i in 0 to 7 generate
        --multiplexer_inst: mux8to1
   Multiplexer : mux8to1 
    generic map (n => 4)
    port map (  
         addr => addr,
         din_0 => mux_din(0),
         din_1 => mux_din(1),
         din_2 => mux_din(2),
         din_3 => mux_din(3),
         din_4 => mux_din(4),
         din_5 => mux_din(5),
         din_6 => mux_din(6),
         din_7 => mux_din(7),
         dout => dout);
       --end generate;
end structural;