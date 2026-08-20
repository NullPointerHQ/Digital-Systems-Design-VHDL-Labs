-- ******************************************************
-- ADDER
-- ******************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
    generic(n: integer := 6);
    port(
        sel  : in  std_logic_vector(1 downto 0);
        a    : in  std_logic_vector(n-1 downto 0);
        b    : in  std_logic_vector(n-1 downto 0);
        r    : out std_logic_vector(n-1 downto 0) 
    );
end adder;

architecture dataflow of adder is

begin

    P1 : process(sel,a,b)
    -- Converting 'a' and 'b' to 7 bit to allow for carry bit
        variable a_long     : unsigned(n downto 0); 
        variable b_long     : unsigned(n downto 0); 
    
        variable op1_long   : unsigned(n downto 0); -- Holds 'NOT' B + 1
        variable op2_long   : unsigned(n downto 0); -- Holds A - B 
    
        variable sum_long   : unsigned(n downto 0); -- Allows for a 7 bit sum 
        variable sum        : unsigned(n - 1 downto 0);
        variable difference : unsigned(n - 1 downto 0);
    begin 
    
    -- Converting a and b to 7-bits to allow us to include the carry bit IF needed
        a_long := '0' & unsigned(a);
        b_long := '0' & unsigned(b);
        
        sum_long := a_long + b_long;     --  A + B
        
        op1_long := (not b_long) + 1;    -- -B + 1
        op2_long := a_long + op1_long;   --  A - B
        
        -- Parsing the 7 bit sum and diff. for the 6 sum and diff.
        for i in 0 to n - 1 loop
           sum(i) := sum_long(i);
           difference(i) :=  op2_long(i);
        end loop; 
        
        if sel = "00" then -- ADDITION
            r <= std_logic_vector(sum);
            
        elsif sel = "01" then -- CARRY
            r <= sum_long(n) & "00000";
        
        elsif sel = "10" then -- SUBTRACTION
            r <= std_logic_vector(difference);
        
        elsif sel = "11" then -- BORROW
            r <= op2_long(n) & "00000";
       end if;

     end process P1;
end dataflow;
-- ******************************************************
-- MULTIPLIER
-- ******************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mult is
    generic(n: integer := 6);
    port(
        sel  : in  std_logic;
        a    : in  std_logic_vector(n-1 downto 0);
        b    : in  std_logic_vector(n-1 downto 0);
        r    : out std_logic_vector(n-1 downto 0) 
    );
end mult;

architecture dataflow of mult is

begin
    P1 : process(sel,a,b)
    
    -- Holds the cross product a x b, r simply holds the first or last 6 bits of this
    variable cross_product : unsigned(((n * 2) -1) downto 0);
 
    variable a_long        : unsigned(n - 1 downto 0); 
    variable b_long        : unsigned(n - 1 downto 0); 
    
    begin
    -- Converting a and b to unsigned
    a_long := unsigned(a);
    b_long := unsigned(b);
        
    -- Gather the 12 bit product and assign it to cross_product
    cross_product := a_long * b_long;  
        
    -- Grabbing the correct 'r'
    
        -- Sel is HIGH
        if sel = '1' then
            for j in 0 to (n - 1) loop 
                r(j) <= cross_product(j + n); 
            end loop; -- Ends J Loop
            
        -- Sel is LOW
        else
            for k in 0 to (n - 1) loop
                r(k) <= cross_product(k);
            end loop; -- Ends K Loop
        end if;
    end process P1;
end dataflow;
-- ******************************************************
-- LOGIC UNIT
-- ******************************************************
library ieee;
use ieee.std_logic_1164.all;

entity logic_unit is
    generic(n: integer := 6);
    port(
        sel  : in  std_logic_vector(1 downto 0);
        a    : in  std_logic_vector(n - 1 downto 0);
        b    : in  std_logic_vector(n - 1 downto 0);
        r    : out std_logic_vector(n - 1 downto 0) 
    );
end logic_unit;

architecture dataflow of logic_unit is

begin

     P1 : process(sel,a,b)
     begin 
        if    sel = "00" then r <=   not a;     -- NOT GATE
        elsif sel = "01" then r <= a and b;     -- AND GATE
        elsif sel = "10" then r <= a or b ;     -- OR GATE
        elsif sel = "11" then r <= a xor b;     -- XOR GATE
        end if;
    end process P1;
end dataflow;

-- ******************************************************
-- SHIFTER
-- ******************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shifter is
    generic(
        n: integer := 6;
        m: integer := 3 -- Changes the number of bits in b
    );
    port(
        sel  : in  std_logic_vector(1 downto 0);
        a    : in  std_logic_vector(n - 1 downto 0);
        b    : in  std_logic_vector(m - 1 downto 0);
        r    : out std_logic_vector(n - 1 downto 0) 
    );
end shifter;

architecture dataflow of shifter is

begin
    
    P1 : process(sel,a,b)
    variable arithmetic: std_logic; -- Usually zero, only changes for Arithmetic (Same issue presented with the adder)
    variable shift_by : integer; -- Contains the amount to shift by.
    
    begin 
        shift_by := 0;
        if b(0) = '1' then 
            shift_by := shift_by + 1;
        end if;
        if b(1) = '1' 
            then shift_by := shift_by + 2;
        end if;
        if b(2) = '1' 
            then shift_by := shift_by + 4;
        end if;
        
    -- LEFT SHIFT
    if sel(1) = '0' then
        -- Iterate through the entire input
        for i in 0 to n - 1 loop
            -- Place Zeroes at the indices necessary
            if i <= shift_by - 1 then
                r(i) <= '0';
            -- Grab the remaining bit string
            else 
            -- - shift_by to ensure that it grabs the first part of the string
                r(i) <= a(i - shift_by);  
            end if;
        end loop;
    
    -- RIGHT SHIFT
    elsif sel(1) = '1' then        
      -- IF ARITHMETIC SHIFT REQUIRED THIS WILL PRESERVE THE FIRST BIT
      -- ALSO REDUCES CODE REWRITE
        if sel(0) = '1' then
            -- Preserve the first bit, use it to replace instead of default 0
            arithmetic := a(0);
        else 
            arithmetic := '0';
        end if;
        
        -- RIGHT SHIFT LOGIC, ALSO WORKS FOR ARITHMETIC
        for i in 0 to n - 1 loop 
        -- Shifts the last bits of a over to the first bits of r
            if i < (n - shift_by) then
                -- i + shift_by  WILL GRAB THE VALUES FROM LEFT TO RIGHT
                r(i) <= a(i + shift_by);
                
        -- Place the zeroes/preserved bits
            else 
                r(i) <= arithmetic;
            end if;  
        end loop;
    end if;
        
    end process P1;
end dataflow;

-- ******************************************************
-- MULTIPLEXER
-- ******************************************************
library ieee;
use ieee.std_logic_1164.all;

-- Entity Declaration
entity mux4to1 is
generic (
    n: integer := 6); 
    port(
    sel : in std_logic_vector (1 downto 0); -- 2-Bit Selector Input
    -- 8 'n'-Bit inputs
    din_0 : in std_logic_vector(n - 1 downto 0); -- ADDER INPUT
    din_1 : in std_logic_vector(n - 1 downto 0); -- MULTIPLIER
    din_2 : in std_logic_vector(n - 1 downto 0); -- LOGIC UNIT
    din_3 : in std_logic_vector(n - 1 downto 0); -- SHIFTER
    
    r : out std_logic_vector (n - 1 downto 0) -- 'n' Bit Output
     );
    end mux4to1;
    
-- Architectural Definition
architecture dataflow of mux4to1 is
    begin
        r <=
            din_0 when sel = "00" else -- Multiplexer Port 0
            din_1 when sel = "01" else -- Multiplexer Port 1
            din_2 when sel = "10" else -- Multiplexer Port 2
            din_3 when sel = "11" else -- Multiplexer Port 3
            "000000"; -- Default Case
    end dataflow;

-- ******************************************************
-- ALU WRAPPER
-- ******************************************************
library ieee;
use ieee.std_logic_1164.all;

entity alu is
    port(
        sel  : in  std_logic_vector(3 downto 0);
        a    : in  std_logic_vector(5 downto 0);
        b    : in  std_logic_vector(5 downto 0);
        r    : out std_logic_vector(5 downto 0) 
    );
end alu;

architecture structural of alu is
    constant n : integer := 6;
    constant m : integer := 3;

    component adder is
        generic(n: integer := 6);
        port(
            sel  : in  std_logic_vector(1 downto 0);
            a    : in  std_logic_vector(n-1 downto 0);
            b    : in  std_logic_vector(n-1 downto 0);
            r    : out std_logic_vector(n-1 downto 0) 
        );
    end component;

    component mult is
        generic(n: integer := 6);
        port(
            sel  : in  std_logic;
            a    : in  std_logic_vector(n - 1 downto 0);
            b    : in  std_logic_vector(n - 1 downto 0);
            r    : out std_logic_vector(n - 1 downto 0) 
        );
    end component;

    component logic_unit is
        generic(n: integer := 6);
        port(
            sel  : in  std_logic_vector(1 downto 0);
            a    : in  std_logic_vector(n - 1 downto 0);
            b    : in  std_logic_vector(n - 1 downto 0);
            r    : out std_logic_vector(n - 1 downto 0) 
        );
    end component;

    component shifter is
        generic(
            n: integer := 6;
            m: integer := 3
        );
        port(
            sel  : in  std_logic_vector(1 downto 0);
            a    : in  std_logic_vector(n - 1 downto 0);
            b    : in  std_logic_vector(m - 1 downto 0);
            r    : out std_logic_vector(n - 1 downto 0) 
        );
    end component;
    
    -- ALU MULTIPLEXER
    component mux4to1 is
        generic(n: integer := 6);
        port(
            sel   : in  std_logic_vector(1 downto 0);
            din_0 : in  std_logic_vector(n - 1 downto 0);
            din_1 : in  std_logic_vector(n - 1 downto 0);
            din_2 : in  std_logic_vector(n - 1 downto 0);
            din_3 : in  std_logic_vector(n - 1 downto 0); 
            r     : out std_logic_vector(n - 1 downto 0)
        );    
    end component;
    
    
    -- Array of Arrays for the output from each unit in the ALU
    type r_dout is array (0 to 3) of std_logic_vector (n - 1 downto 0);
    -- r_dout Array Signal, decides which array in r_dout is accessed 
    signal mux_din : r_dout;
    
    -- Selector Signal, decides which input becomes the output
    signal sel_mux : std_logic_vector (1 downto 0);
begin

    -- Assigning Sel's 3:2 ports 
     sel_mux(1) <= sel(3);
     sel_mux(0) <= sel(2);
    
    -- COMPONENT PORT MAPS
    Adder_inst : adder port map(
        sel(1) => sel(1),
        sel(0) => sel(0),
        a => a,
        b => b,
        r => mux_din(0)
        );

    Multiplier_inst : mult port map(
        sel => sel(0),
        a => a,
        b => b,
        r => mux_din(1)
        );
        
    Logic_Unit_inst : logic_unit port map(
        sel(1) => sel(1),
        sel(0) => sel(0),
        a => a,
        b => b,
        r => mux_din(2)
        );
        
    Shifter_inst : shifter port map(
        sel(1) => sel(1),
        sel(0) => sel(0),
        a => a,
        b(0) => b(0),
        b(1) => b(1),
        b(2) => b(2),
        r => mux_din(3)
        );
        
    Multiplexer : mux4to1 port map(
        sel => sel_mux,
        din_0 => mux_din(0),
        din_1 => mux_din(1),
        din_2 => mux_din(2),
        din_3 => mux_din(3),
        r => r
        );
end structural;
