--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:26:50 11/14/2024
-- Design Name:   
-- Module Name:   /home/student1/sshahwar/Desktop/Pong_Game_Coe758/Pong_Game/testbench.vhd
-- Project Name:  Pong_Game
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Game_Funct
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY testbench IS
END testbench;
 
ARCHITECTURE behavior OF testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Game_Funct
    PORT(
         clk : IN  std_logic;
         Hsync : OUT  std_logic;
         Vsync : OUT  std_logic;
         DAC_clk : OUT  std_logic;
         Bout : OUT  std_logic_vector(7 downto 0);
         Gout : OUT  std_logic_vector(7 downto 0);
         Rout : OUT  std_logic_vector(7 downto 0);
         SWH0 : IN  std_logic;
         SWH1 : IN  std_logic;
         SWH2 : IN  std_logic;
         SWH3 : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal SWH0 : std_logic := '0';
   signal SWH1 : std_logic := '0';
   signal SWH2 : std_logic := '0';
   signal SWH3 : std_logic := '0';

 	--Outputs
   signal Hsync : std_logic;
   signal Vsync : std_logic;
   signal DAC_clk : std_logic;
   signal Bout : std_logic_vector(7 downto 0);
   signal Gout : std_logic_vector(7 downto 0);
   signal Rout : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant DAC_clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Game_Funct PORT MAP (
          clk => clk,
          Hsync => Hsync,
          Vsync => Vsync,
          DAC_clk => DAC_clk,
          Bout => Bout,
          Gout => Gout,
          Rout => Rout,
          SWH0 => SWH0,
          SWH1 => SWH1,
          SWH2 => SWH2,
          SWH3 => SWH3
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   DAC_clk_process :process
   begin
		DAC_clk <= '0';
		wait for DAC_clk_period/2;
		DAC_clk <= '1';
		wait for DAC_clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
