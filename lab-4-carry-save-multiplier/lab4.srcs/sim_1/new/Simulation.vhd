library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
library std;
use std.textio.all;

entity mult_tb is
end mult_tb;

architecture behavioral of mult_tb is
    file MULT_FILE : text OPEN READ_MODE is "mult8x8.dat";

    constant PERIOD : time := 10 ns;
    
    component mult is
        port(
           clk : in std_logic;
           a   : in std_logic_vector (7 downto 0);
           b   : in std_logic_vector (7 downto 0);
           
           p   : out std_logic_vector(15 downto 0)
        );
    end component;

    signal clk : std_logic;
    signal a   : std_logic_vector (7 downto 0);
    signal b   : std_logic_vector (7 downto 0);      
    signal p   : std_logic_vector(15 downto 0);

begin
    mult_inst : mult
    port map(
        clk => clk,
        a => a,
        b => b,
        p => p );

    clk_gen: process
    begin
        clk <= '0';
        wait for PERIOD/2;
        clk <= '1';
        wait for PERIOD/2;
    end process;
     
    -- variables for reading for MULT_FILE
    tb: process
        variable cur_line   : integer := 1;
        variable v_line     : line; -- Line Var, usable by 'readline'
        variable v_space    : character;
        variable v_a        : std_logic_vector(7 downto 0);
        variable v_b        : std_logic_vector(7 downto 0);
        variable v_p_exp    : std_logic_vector(15 downto 0);

    begin     
        while not endfile(MULT_FILE) loop
        
            readline(MULT_FILE, v_line);-- Reads 1 line at a time from file and stores it in variable.
            hread(v_line, v_a);-- Reads from the 1st variable into the 2nd variable.
            hread(v_line, v_b);-- Reads from the 1st variable into the 2nd variable.
            hread(v_line, v_p_exp); -- Reads from the 1st variable into the 2nd variable.
            a <= v_a;
            b <= v_b; 
            wait for (2 * PERIOD);
            
            assert p = v_p_exp report "Multiplication Error!" severity error;
 
        end loop; 
        report "Simulation Complete";
    end process;
    

end behavioral;
