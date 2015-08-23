----------------------------------------------------------------------------------
-- Author: 	Krzysztof Kepa
-- 
-- Create Date:    17:28:39 09/30/2014 
-- Design Name: 
-- Module Name:    greasy_mod - Behavioral 
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


entity greasy_mod is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           i_valid : in  STD_LOGIC;
           i_last : in  STD_LOGIC;
           i_data : in  STD_LOGIC_VECTOR(63 downto 0);
           i_ready : out  STD_LOGIC;
           o_valid : out  STD_LOGIC;
           o_last : out  STD_LOGIC;
           o_data : out  STD_LOGIC_VECTOR(63 downto 0);
           o_ready : in  STD_LOGIC;
           enable_out : out  STD_LOGIC);
end greasy_mod;

architecture Behavioral of greasy_mod is

signal full, writable, en, rd, wr : std_logic;

begin

en_i:
	en <= wr or rd;

rd_i:
	rd <= full and o_ready;

writable_i:
	writable <= not full or rd;

wr_i:
	wr <= i_valid and writable;

o_valid <= full;

i_ready <= writable;
enable_out <= wr;

process(clk)
begin
	if rising_edge(clk) then
		if rst='1' then
			full <= '0';
		elsif en='1' then
			full <= wr;
		end if;
	end if;
end process;

process(clk)
begin
	if rising_edge(clk) then
		if rst='1' then
			o_last <= '0';
			o_data <= (others => '0');
		elsif wr='1' then
			o_last <= i_last;
			o_data <= i_data;
		end if;
	end if;
end process;

end Behavioral;

