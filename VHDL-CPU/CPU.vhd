library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity CPU is
	port (
		CLR,T3,C,Z : in std_logic;
		SW : in std_logic_vector(2 downto 0);
		-- CBA => 210
		IR : in std_logic_vector(3 downto 0);
		-- 7654 => 3210
		W : in std_logic_vector(2 downto 0);
		-- 321 => 210
		DRW,PCINC,LPC,LAR,PCADD,ARINC,SELCTL,MEMW,STOP,LIR,LDZ,LDC,CIN,M,ABUS,SBUS,MBUS,SHORT,LONG :out std_logic;
		S : in std_logic_vector(3 downto 0);
		-- 3210 => 3210
		SEL01 : in std_logic_vector(1 downto 0);
		-- 10 => 10
		SEL23 : in std_logic_vector(1 downto 0)
		-- 32 => 10
	);
end CPU;

architecture arc of CPU is
begin	

end arc;