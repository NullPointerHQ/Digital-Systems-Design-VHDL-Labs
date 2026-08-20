-- *************************************************
--          FULL_ADDER COMPONENT
-- *************************************************
library ieee;
use ieee.std_logic_1164.all;

entity full_adder is
    port(
        a    : in std_logic;    -- Holds operand 1
        b    : in std_logic;    -- Holds operand 2
        cin  : in std_logic ;   -- Holds carry bit 
        
        sum  : out std_logic;   -- Holds the sum
        cout : out std_logic    -- Holds the carry bit from the sum 
    );
end full_adder;

architecture dataflow of full_adder is
    signal ab_operand : std_logic; -- Will hold the result of a XOR b
begin

    ab_operand <= a xor b;      
    sum <= ab_operand xor cin;  
    cout <= b when ab_operand = '0' else cin; 
end dataflow;

-- *************************************************
--          CARRY_SAVE_MULT COMPONENT
-- *************************************************
library ieee;
use ieee.std_logic_1164.all;

entity carry_save_mult is
    generic(n: integer := 8);
    port(
        a : in std_logic_vector (n - 1 downto 0);
        b : in std_logic_vector (n - 1 downto 0);
        
        p : out std_logic_vector ((n * 2) - 1 downto 0)
    );
end carry_save_mult;

architecture structural of carry_save_mult is
    component full_adder is 
        port(
        a    : in std_logic;    -- Holds operand 1
        b    : in std_logic;    -- Holds operand 2
        cin  : in std_logic ;   -- Holds carry bit 
        
        sum  : out std_logic;   -- Holds the sum
        cout : out std_logic    -- Holds the carry bit from the sum     
        );
   end component;
   
    type arr2d is array (integer range <>) of std_logic_vector(n - 1 downto 0);

    signal ab : arr2d(0 to (n - 1));


    signal FA_a    : arr2d(0 to (n - 2));
    signal FA_b    : arr2d(0 to (n - 2));
    signal FA_cin  : arr2d(0 to (n - 2));
    
    signal FA_sum  : arr2d(0 to (n - 2));
    signal FA_cout : arr2d(0 to (n - 2));
    
begin
    gen_ab_rows: for i in 0 to n - 1 generate -- A
        gen_ab_cols: for j in 0 to n - 1 generate -- B 
            ab(i)(j) <= a(i) and b(j); 
        end generate;
    end generate;
    
    Rows : for i in 0 to (n - 2) generate 
        Columns : for j in 0 to n - 1 generate 
            full_adder_inst : full_adder
                port map(
                    a => FA_a(i)(j),
                    b => FA_b(i)(j),
                    cin => FA_cin(i)(j),
                    sum => FA_sum(i)(j),
                    cout => FA_cout(i)(j));
            end generate;
        end generate;
     
    -- First row:
        FA_a(0) <= '0' & ab(0)((n - 1) downto 1);
        FA_b(0) <= ab(1)((n - 1) downto 0);
        FA_cin(0) <= ab(2)((n - 2) downto 0) & '0';
    
    -- Intermediate rows:
        Intermediate_Rows: for i in 1 to (n - 3) generate
            FA_a(i) <= ab(i + 1)(n - 1) & FA_sum(i - 1)((n - 1) downto 1);
            FA_b(i) <= FA_cout(i - 1)((n - 1) downto 0);
            FA_cin(i) <= ab(i + 2)((n - 2) downto 0) & '0'; 
        end generate;
        
    -- Last row:
        FA_a(n - 2) <= ab(n - 1)(n - 1) & FA_sum(n - 3)((n - 1) downto 1);
        FA_b(n - 2) <= FA_cout(n - 3)((n - 1) downto 0);
        FA_cin(n - 2) <= FA_cout(n - 2)(n - 2 downto 0) & '0'; 
        

    -- Product:

    p(0) <= ab(0)(0); 
    

    Product : for i in 1 to (n - 2) generate
        p(i) <= FA_sum(i - 1)(0);
    end generate;
    

    Product_2 : for i in (n - 1) to ((2 * n) - 2) generate
        p(i) <= FA_sum(n - 2)(i - (n - 1)); 
    end generate;
    
    
    p((2 * n) - 1) <= FA_cout(n - 2)(n - 1);
end structural;




-- MULT WRAPPER
library ieee;
use ieee.std_logic_1164.all;

entity mult is
    port(
         clk : in std_logic;
         a   : in std_logic_vector (7 downto 0);
         b   : in std_logic_vector (7 downto 0);
         
         p   : out std_logic_vector(15 downto 0)
    );
end mult;

architecture structural of mult is
    component carry_save_mult is 
        generic(n: integer := 8);
        port (
            a : in std_logic_vector (n - 1 downto 0);
            b : in std_logic_vector (n - 1 downto 0);
        
            p : out std_logic_vector ((n * 2) - 1 downto 0)
            );
     end component;
     
    -- signals
    signal a_reg  : std_logic_vector(7 downto 0); 
    signal b_reg  : std_logic_vector(7 downto 0); 
    signal p_s    : std_logic_vector(15 downto 0); 
    
begin

    carry_save_mult_inst : carry_save_mult 
        port map(
            a => a_reg, 
            b => b_reg, 
            p => p_s             
            );

    reg_mult : process(clk) 
    begin
        if rising_edge(clk) then 
            a_reg <= a; 
            b_reg <= b; 
            p <= p_s; 
        end if;
    end process;

end structural;

-- after completing the design, write the simulation testbench.
-- make sure to add "create clock -period 10 -name clk [get ports clk]"
-- to your constraints file.
