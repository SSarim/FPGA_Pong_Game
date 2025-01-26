----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Sarim Shahwar
-- 
-- Create Date:    11:52:34 11/01/2024 
-- Design Name: 	pingpong stle game
-- Module Name:    Game_Funct - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Entity definition: Defines the inputs and outputs of the module
entity Game_Funct is
port (
    clk : in STD_LOGIC;                         -- Input clock signal
    Hsync : OUT STD_LOGIC;                      -- Horizontal sync for VGA
    Vsync : OUT STD_LOGIC;                      -- Vertical sync for VGA
    DAC_clk : OUT STD_LOGIC;                    -- DAC clock for VGA
    Bout : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);   -- Blue color intensity
    Gout : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);   -- Green color intensity
    Rout : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);   -- Red color intensity
    SWH0 : IN STD_LOGIC;                        -- Switch for blue paddle enable
    SWH1 : IN STD_LOGIC;                        -- Switch for blue paddle move
    SWH2 : IN STD_LOGIC;                        -- Switch for red paddle enable
    SWH3 : IN STD_LOGIC                         -- Switch for red paddle move
);
end Game_Funct;

-- Behavioral architecture for the game
architecture Behavioral of Game_Funct is
-- VGA parameters: hsync/vsync counters for tracking the current pixel
signal hcounter : integer range 0 to 799; -- Horizontal pixel counter (max 800)
signal vcounter : integer range 0 to 524; -- Vertical pixel counter (max 525)

    -- Clock signals
signal fresh_clk : std_logic;              -- Custom clock for slower updates
signal fresh_controller : integer := 0;   -- Counter for custom clock
signal pixel_clk : std_logic;             -- Pixel clock derived from system clock

-- RGB signals for VGA colors
signal R: std_logic_vector(7 DOWNTO 0);
signal G: std_logic_vector(7 DOWNTO 0);
signal B: std_logic_vector(7 DOWNTO 0);

 -- Top border parameters
signal tborder_x1 : integer := 10;         -- Left boundary of the top vertical bar
signal tborder_x2 : integer := 20;         -- Right boundary of the top vertical bar
signal tborder_y1 : integer := 10;         -- Top boundary of the top vertical bar
signal tborder_y2 : integer := 160;        -- Bottom boundary of the top vertical bar
--horz bar #1 (top)
signal tborder_x3: integer := 10;
signal tborder_x4: integer := 630;
signal tborder_y3: integer := 10;
signal tborder_y4: integer := 20;

--vert bar #2 (top)
signal tborder_x5: integer := 620;
signal tborder_x6: integer := 630;
signal tborder_y5: integer := 10;
signal tborder_y6: integer := 160;

--horz bar #2 (bottom)
signal bborder_x3 : integer := 10;
signal bborder_x4 : integer := 630;
signal bborder_y3 : integer := 460;
signal bborder_y4 : integer := 470;

--vert bar #3 (bottom)
signal bborder_x1 : integer := 10;
signal bborder_x2 : integer := 20;
signal bborder_y1 : integer := 300;
signal bborder_y2 : integer := 470;

--vert bar #4 (bottom)
signal bborder_x5 : integer := 620;
signal bborder_x6 : integer := 630;
signal bborder_y5 : integer := 300;
signal bborder_y6 : integer := 470;

--Mid line
signal midline_x1 : integer := 318;
signal midline_x2 : integer := 322;
signal midline_y1 : integer := 30;
signal midline_y2 : integer := 450;

--Cntr white line
signal cntrborder_x1: integer := 300;
signal cntrborder_x2: integer := 340;
signal cntrborder_y1: integer := 220;
signal cntrborder_y2: integer := 260;

--Cntr green background
signal gcntrborder_x1: integer := 305;
signal gcntrborder_x2: integer := 335;
signal gcntrborder_y1: integer := 225;
signal gcntrborder_y2: integer := 255;

-- Initial position and dimensions for the red paddle
signal red_paddle_x1: integer := 608;  -- Left boundary (close to the right edge of the screen)
signal red_paddle_x2: integer := 618;  -- Right boundary (15 pixels wide)(MAX 635)
signal red_paddle_y1: integer := 40;  -- Top boundary (can be adjusted for initial position)
signal red_paddle_y2: integer := 115;  -- Bottom boundary (75 pixels tall)

-- movement initially set to 0
signal red_paddle_x: integer := 0;  -- Horizontal movement
signal red_paddle_y: integer := 0;  -- Vertical movement

-- Initial position and dimensions for the blue paddle
signal blue_paddle_x1: integer := 20;   -- Left boundary (close to the left edge of the screen)
signal blue_paddle_x2: integer := 30;  -- Right boundary (15 pixels wide)
signal blue_paddle_y1: integer := 40; -- Top boundary (can be adjusted for initial position)
signal blue_paddle_y2: integer := 115;--Bottom boundary (75 pixels tall)

-- movement initially set to 0
signal blue_paddle_x: integer := 0;    -- Horizontal movement 
signal blue_paddle_y: integer := 0;    -- Vertical movement

--Ball
signal ball_x: std_logic;		-- Horizontal movement direction
signal ball_y: std_logic;		-- Vertical movement direction
signal ball_x1: integer := 313;  -- Left boundary (midpoint - half the ball's width)
signal ball_x2: integer := 327;  -- Right boundary (midpoint + half the ball's width)
signal ball_y1: integer := 233;  -- Top boundary (midpoint - half the ball's height)
signal ball_y2: integer := 247;  -- Bottom boundary (midpoint + half the ball's height)

--End goal line
signal red_goal: integer := 625;
signal blue_goal: integer := 15; 
signal score : std_logic;
signal reset : std_logic;
begin
--25Mhz clock using the 50 MHz system clock. Every other rising edge.
process (clk)
	begin
	if clk'event and clk='1' then
		pixel_clk <= NOT(pixel_clk);		
	end if;
end process;
DAC_CLK <= pixel_clk;

-- Horizontal and vertical sync counters: Track the current position in the VGA frame
process (pixel_clk, hcounter, vcounter)
begin
    if pixel_clk'event and pixel_clk = '1' then
        hcounter <= hcounter + 1;             -- Increment the horizontal counter
        if (hcounter = 799) then              -- End of a horizontal line
            vcounter <= vcounter + 1;         -- Move to the next vertical line
            hcounter <= 0;                    -- Reset horizontal counter
        end if;
        if (vcounter = 524) then              -- End of the screen frame
            vcounter <= 0;                    -- Reset vertical counter
        end if;
    end if;
end process;
    
-- Hsync and Vsync signal generation: Generate pulses based on counters
Hsync <= '0' when hcounter <= 96 else '1';    -- Hsync low for the first 96 counts
Vsync <= '0' when vcounter <= 2 else '1';     -- Vsync low for the first 2 counts


-- RGB output only in the active region (valid pixels for display)
process
begin
    if (hcounter >= 143 and hcounter <= 783 and vcounter >= 34 and vcounter <= 514) then
        Rout <= R;                           -- Assign red intensity
        Gout <= G;                           -- Assign green intensity
        Bout <= B;                           -- Assign blue intensity
    else
        Rout <= (others => '0');             -- No red outside active region
        Gout <= (others => '0');             -- No green outside active region
        Bout <= (others => '0');             -- No blue outside active region
    end if;
end process;

process(pixel_clk)
    begin
        if pixel_clk'event and pixel_clk='1' then
            if (fresh_controller >= 416667) then
                fresh_clk <= not(fresh_clk);
                fresh_controller <= 0;
            else
                fresh_controller <= fresh_controller + 1;
            end if;
        end if;
    end process;

--Ball movement/impact
process(fresh_clk)
begin
    if fresh_clk'event and fresh_clk = '1' then

        --Ball-->left, send ball +x direction
        if (ball_x1 <= tborder_x2 +7 and (ball_y1 >= tborder_y4 and ball_y2<= tborder_y6+2)) then
            --Ball-->top-left boundary
            ball_x <= '1';

        elsif(ball_x1 <= bborder_x2 +7 and (ball_y1 >= bborder_y5-2 and ball_y2<= bborder_y6)) then
            --Ball -->bottom-left boundary
            ball_x <= '1';

        --Ball -->right, send ball -x direction
        elsif (ball_x2 >= tborder_x5 -7 and (ball_y2 >= tborder_y4 and ball_y1<= tborder_y6)) then
            --Ball -->top-right boundary
            ball_x <= '0';

        elsif (ball_x2 >= bborder_x5 -7 and (ball_y2 >= bborder_y1 and ball_y1<= bborder_y6)) then
            --Ball --> bottom-right boundary
            ball_x <= '0';

        end if;

        --Paddle and ball impacts
        if (ball_x1 <= blue_paddle_x2 and (ball_y1 >= blue_paddle_y1 and ball_y2 <= blue_paddle_y2)) then
            --Ball -->blue paddle (left); send +x direction
            ball_x <= '1';


        end if;
-- 1 is right, 0 is left
        --Ball/paddle impacts
			if (ball_x2 >= blue_paddle_x1 and ball_x1 <= blue_paddle_x2 and ball_y2 >= blue_paddle_y1 and ball_y1 <= blue_paddle_y2) then
				ball_x <= '1';
			
			elsif (ball_x2 >= red_paddle_x1 and ball_x1 <= red_paddle_x2 and ball_y2 >= red_paddle_y1 and ball_y1 <= red_paddle_y2) then
			ball_x <= '0';
        end if;

        if (ball_y1 <= tborder_y4+7) then
            --Ball -->top boundary; send -y direction
            ball_y <= '0';
        elsif (ball_y2 >= bborder_y3-7) then
            --Ball -->bottom boundary; send +y direction
            ball_y <= '1';
        end if;

        --Goal detection
        if (ball_x1 < blue_goal) then
            --Ball -->left goal line; red paddle scores
            score <= '1';
        elsif (ball_x2 > red_goal) then
            --Ball -->right goal line; blue paddle scores
            score <= '1';
        else
            --no scoring if the set parameters are not met. Game continues.
            score <= '0';
        end if;

        if (ball_x1 <= 5) then
            --Ball -->end of screen (left); reset to center
            ball_x1 <= 310;
            ball_x2 <= 325;
            ball_y1 <= 230;
            ball_y2 <= 245;
            ball_x <= '1';
            ball_y <= '1';
        elsif (ball_x2 >= 635) then
            --Ball -->end of screen (right); reset to center
            ball_x1 <= 310;
            ball_x2 <= 325;
            ball_y1 <= 230;
            ball_y2 <= 245;
            ball_x <= '0';
            ball_y <= '1';
        else
            --Ball movement continue
            if (ball_x = '1') then
                --ball --> +x direction
                ball_x1 <= ball_x1 + 6;
                ball_x2 <= ball_x2 + 6;
            else
                --ball --> -x direction
                ball_x1 <= ball_x1 - 6;
                ball_x2 <= ball_x2 - 6;
            end if;

            if ( ball_y = '1') then
                --ball --> +y direction
                ball_y1 <= ball_y1 - 6;
                ball_y2 <= ball_y2 - 6;
            else
                --ball --> -y direction
                ball_y1 <= ball_y1 + 6;
                ball_y2 <= ball_y2 + 6;
            end if;
        end if;
    end if;
end process;

--Paddle movement via switches
process(fresh_clk)
    begin
        if fresh_clk'event and fresh_clk = '1' then

            if (SWH2 = '1') then
                --red paddle up
                if (red_paddle_y1 > tborder_y4) then
                    red_paddle_y1 <= red_paddle_y1 - 10;
                    red_paddle_y2 <= red_paddle_y2 - 10;
                end if;
            end if;
            
            if(SWH2 = '0') then
                --red paddle down
                if (red_paddle_y2 < bborder_y3) then
                    red_paddle_y1 <= red_paddle_y1 + 10;
                    red_paddle_y2 <= red_paddle_y2 + 10;
                end if;
            end if;

            if (SWH0 = '1') then
                --blue paddle up
                if (blue_paddle_y1 > tborder_y4) then
                    blue_paddle_y1 <= blue_paddle_y1 - 10;
                    blue_paddle_y2 <= blue_paddle_y2 - 10;
                end if;
            end if;

            if(SWH0 = '0') then
                --blue paddle down
                if (blue_paddle_y2 < bborder_y3) then
                    blue_paddle_y1 <= blue_paddle_y1 + 10;
                    blue_paddle_y2 <= blue_paddle_y2 + 10;
                end if;
            end if;

        end if;
end process;



-- VGA display generation: Maps objects (borders, paddles, ball) to RGB colors
process(hcounter, vcounter)
variable x, y: integer range 0 to 639; -- Active region of the screen
begin
x := hcounter - 143;                -- Adjust for active display
y := vcounter - 34;                 -- Adjust for active display
--background dark green 
R <= "00000001";
G <= "01100100";
B <= "00100000";

if (x > ball_x1 and x < ball_x2 and y > ball_y1 and y < ball_y2) then -- ball parameters

--ball colour == red when scored
if (score = '1') then
R <= "11111111";
G <= "00000000";
B <= "00000000";
else
R <= "11111111";
G <= "11111111";
B <= "00000000";
end if;


-- Top border
elsif (x > tborder_x1 and x < tborder_x2 and y > tborder_y1 and y <
tborder_y2) then

R <= "11111111";
G <= "01101001";
B <= "10110100";
elsif (x > tborder_x3 and x < tborder_x4 and y > tborder_y3 and y <
tborder_y4) then

R <= "11111111";
G <= "01101001";
B <= "10110100";
elsif (x > tborder_x5 and x < tborder_x6 and y > tborder_y5 and y <
tborder_y6) then

R <= "11111111";
G <= "01101001";
B <= "10110100";

--Bottom border

elsif (x > bborder_x1 and x < bborder_x2 and y > bborder_y1 and y < bborder_y2) then
R <= "11111111";
G <= "01101001";
B <= "10110100";
elsif (x > bborder_x3 and x < bborder_x4 and y > bborder_y3 and y < bborder_y4) then
R <= "11111111";
G <= "01101001";
B <= "10110100";
elsif (x > bborder_x5 and x < bborder_x6 and y > bborder_y5 and y < bborder_y6) then
R <= "11111111";
G <= "01101001";
B <= "10110100";
--Mid field
elsif (x > gcntrborder_x1 and x < gcntrborder_x2 and y > gcntrborder_y1 and y < gcntrborder_y2)
then

R <= "11111111";
G <= "00000000";
B <= "00000000";
elsif (x > midline_x1 and x < midline_x2 and y > midline_y1 and y < midline_y2) then
R <= "11111111";
G <= "01100110";
B <= "00000000";
elsif (x > cntrborder_x1 and x < cntrborder_x2 and y > cntrborder_y1 and y < cntrborder_y2) then
R <= "11111111";
G <= "11111111";
B <= "11111111";

--Paddle (R)
elsif (x > red_paddle_x1 and x < red_paddle_x2 and y > red_paddle_y1 and y < red_paddle_y2) then
R <= "11111111";
G <= "11000000";
B <= "11001011";

--Paddle (B)
elsif (x > blue_paddle_x1 and x <blue_paddle_x2 and y > blue_paddle_y1 and y < blue_paddle_y2) then
R <= "00000000";
G <= "00000000";
B <= "11111111";
end if;
end process;
end Behavioral;


