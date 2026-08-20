library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tb is
end alu_tb;

architecture behavioral of alu_tb is
    component alu is 
        port(
            sel  : in  std_logic_vector(3 downto 0);
            a    : in  std_logic_vector(5 downto 0);
            b    : in  std_logic_vector(5 downto 0);
            r    : out std_logic_vector(5 downto 0) 
        );
    end component;    
    
    signal sel  : std_logic_vector(3 downto 0);
    signal a    : std_logic_vector(5 downto 0);
    signal b    : std_logic_vector(5 downto 0);
    signal r    : std_logic_vector(5 downto 0);
  
begin
    alu_inst : alu
    port map(
        sel => sel,
        a => a,
        b => b,
        r => r
        );

    tb : process
    begin
        -- Initialization
        sel <= "0000";
        
    -- Case 1 (4 & 2)

        a <= "000100"; -- 4
        b <= "000010"; -- 2
        
        sel <= "0000"; wait for 10 ns; -- Addition
        sel <= "0001"; wait for 10 ns;  -- Addition w/ Carry
        
        sel <= "0010"; wait for 10 ns;  -- Subtraction
        sel <= "0011"; wait for 10 ns;  -- Subtraction w/ Carry
        
        sel <= "0100"; wait for 10 ns;  -- Multiplication LOW
        sel <= "0101"; wait for 10 ns;  -- Multiplication HIGH
        
        sel <= "1000"; wait for 10 ns;  -- NOT Gate
        sel <= "1001"; wait for 10 ns;  -- AND Gate
        sel <= "1010"; wait for 10 ns;  -- OR Gate
        sel <= "1011"; wait for 10 ns;  -- XOR Gate
        
        sel <= "1100"; wait for 10 ns;  -- Shift Left
        sel <= "1110"; wait for 10 ns;  -- Shift Right
        sel <= "1111"; wait for 10 ns;  -- Shift Arithmetic
        
       --Case 2 (49 & 50)
        a <= "110001"; -- 49
        b <= "110010"; -- 50
        
        sel <= "0000"; wait for 10 ns; -- Addition
        sel <= "0001"; wait for 10 ns;  -- Addition w/ Carry
        sel <= "0010"; wait for 10 ns;  -- Subtraction
        sel <= "0011"; wait for 10 ns;  -- Subtraction w/ Carry
        
        sel <= "0100"; wait for 10 ns;  -- Multiplication LOW
        sel <= "0101"; wait for 10 ns;  -- Multiplication HIGH
        
        sel <= "1000"; wait for 10 ns;  -- NOT Gate
        sel <= "1001"; wait for 10 ns;  -- AND Gate
        sel <= "1010"; wait for 10 ns;  -- OR Gate
        sel <= "1011"; wait for 10 ns;  -- XOR Gate
        
        sel <= "1100"; wait for 10 ns;  -- Shift Left
        sel <= "1110"; wait for 10 ns;  -- Shift Right
        sel <= "1111"; wait for 10 ns;  -- Shift Arithmetic
        
    -- Case 3 (63 & 63)
        a <= "111111"; -- 63
        b <= "111111"; -- 63
        
        sel <= "0000"; wait for 10 ns; -- Addition
        sel <= "0001"; wait for 10 ns;  -- Addition w/ Carry
        sel <= "0010"; wait for 10 ns;  -- Subtraction
        sel <= "0011"; wait for 10 ns;  -- Subtraction w/ Carry
        
        sel <= "0100"; wait for 10 ns;  -- Multiplication LOW
        sel <= "0101"; wait for 10 ns;  -- Multiplication HIGH
        
        sel <= "1000"; wait for 10 ns;  -- NOT Gate
        sel <= "1001"; wait for 10 ns;  -- AND Gate
        sel <= "1010"; wait for 10 ns;  -- OR Gate
        sel <= "1011"; wait for 10 ns;  -- XOR Gate
        
        sel <= "1100"; wait for 10 ns;  -- Shift Left
        sel <= "1110"; wait for 10 ns;  -- Shift Right
        sel <= "1111"; wait for 10 ns;  -- Shift Arithmetic

        wait;
    end process;
end behavioral;