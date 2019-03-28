library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity CPU is
	port (
		CLR,		--复位信号，低电平有效
		C,			--进位标准
		Z,			--零标志
		T3,			--T3时钟
		W1,			--W1节拍输出
		W2,			--W2节拍输出
		W3			--W3节拍输出
		: in std_logic;
		IRH			--IR7654
		: in std_logic_vector(3 downto 0);
		SWCBA		--AB模式开关值,C为1时为实验台算数逻辑实验
		: in std_logic_vector(2 downto 0);
		SELCTL,		--为1时为控制台操作
		ABUS,		--为1时运算器结果送数据总线
		M,			--
		SEL1,		--相当于控制台方式的指令操作数IR3210
		SEL0,
		SEL2,
		SEL3,
		DRW,		--为1时允许寄存器加载
		SBUS,		--为1时允许数据开关值送数据总线
		LIR,		--为1时将从从初期读出的指令送至寄存器
		MBUS,		--为1时将从存储器读出的数据送至数据总线
		MEMW,		--为1时在T2写存储器，为0时读存储器
		LAR,		--为1时在T2的上升沿将数据总线上的地址打入地址寄存器
		ARINC,		--为1时在T2的上升沿地址寄存器加一
		LPC,		--为1时在T2的上升沿地址将数据总线上的数据打入PC
		PCINC,		--为1时在T2的上升沿PC+1
		PCADD,
		CIN,
		LONG,
		SHORT,
		STOP,		--观察使用
		LDC,		--为1时T3的上升沿保存进位
		LDZ			--为1时T3的上升沿保存结果为0的标志
		: out std_logic;
		S			--S3210
		: out std_logic_vector(3 downto 0);
		CP1,CP2,CP3 : out std_logic;
		QD : in std_logic
	);
end CPU;

architecture arc of CPU is
signal ST0,ST0_REG,SST0,STOP_REG,STOP_REG_REG: std_logic;
begin
	CP1<='1';
	CP2<='1';
	with SWCBA select
	STOP<= '0'							when "000",
			STOP_REG or STOP_REG_REG 	when others;
	CP3<=QD;
	ST0<=ST0_REG;

	process (CLR, T3)
	begin
		if (CLR'event and CLR = '0') then
			ST0_REG <= '0';
			STOP_REG_REG <= '1';
		else if (T3'event and T3 = '0') then
			if (SST0 = '1') then
				ST0_REG <= '1';
			end if;
		end if;
	end process;
	
	process (SWCBA, IRH, W1, W2, W3, ST0, C, Z)
	begin
		SHORT <= '0';
		LONG <= '0';
		CIN <= '0';
		SELCTL <= '0';
		ABUS <= '0';
		SBUS <= '0';
		MBUS <= '0';
		M <= '0';
		S <= "0000";
		SEL3 <= '0';
		SEL2 <= '0';
		SEL1 <= '0';
		SEL0 <= '0';
		LIR <= '0';
		MEMW <= '0';
		LAR <= '0';
		ARINC <= '0';
		LPC <= '0';
		LDZ <= '0';
		LDC <= '0';
		STOP_REG <= '0';
		PCINC <= '0';
		SST0 <= '0';
		PCADD <= '0';
		case SWCBA is
			when "000" =>  --执行程序
				case ST0 is
					when '0' =>
						-- load pc
						LPC <= W1;
						SBUS <= W1;
						SST0 <= W1;
						SHORT <= W1;
						STOP_REG <= '0';
					when '1' =>
						case IRH is
							when "0001" =>  --ADD ()
								
								-- 设定PC
								LIR <= W1;
								PCINC <= W1;
								
								-- 选择加法
								-- 选择算术运算, M已经被初始化为0
								S <= "1001";
								
								-- 加法操作
								ABUS <= W2;
								DRW <= W2;
								LDZ <= W2;
								LDC <= W2;
							
							when "0010" =>  -- SUB ()
								
								-- 设定PC
								LIR <= W1;
								PCINC <= W1;
								
								-- 选择算术运算, 选择减法
								-- M已经被初始化为0
								S <= "0110";
								
								-- 减法操作
								ABUS <= W2;
								DRW <= W2;
								LDZ <= W2;
								LDC <= W2;
							when "0011" =>  -- AND ()
								
								-- 设定PC
								LIR <= W1;
								PCINC <= W1;
								
								-- 选择逻辑运算, 与运算
								M <= W2;
								S <= "1011";
								
								ABUS <= W2;
								DRW <= W2;
								LDZ <= W2;
							when "0100" =>  -- INC ()
								
								-- 设定PC
								LIR <= W1;
								PCINC <= W1;
								
								-- 选择算术运算, 与运算
								-- M已经被初始化为0
								S <= "0000";
								
								ABUS <= W2;
								DRW <= W2;
								LDZ <= W2;
								LDC <= W2;
								
							when "0101" =>  -- LD
								
								-- 设定PC
								LIR <= W1;
								PCINC <= W1;
								
								-- 选择算术运算，传送B（保留原值）
								M <= W2;
								S <= "1010";
								
								ABUS <= W2;
								LAR <= W2;
								
								-- 延长周期
								LONG <= W2;
								
								MBUS <= W3;
								DRW <= W3;
							when "0110" =>  -- ST
								
								-- 设定PC
								LIR <= W1;
								PCINC <= W1;
								
								-- 设定...
								M <= W2 or W3;
								S <= '1' & W2 & '1' & W2;
								
								ABUS <= W2 or W3;
								LAR <= W2;
								
								-- 延长周期
								LONG <= W2;
								
								MEMW <= W3;
							
							when "0111" =>  -- JC
								
								-- 设定PC
								LIR <= W1;
								PCINC <= W1;
								
								PCADD <= C and W2;
							
							when "1000" =>  -- JZ
								
								-- 设定PC
								LIR <= W1;
								PCINC <= W1;
								
								PCADD <= Z and W2;
								
							when "1001" =>  -- JMP
								
								-- 设定PC
								LIR <= W1;
								PCINC <= W1;
								
								-- 设定算术运算
								M <= W2;
								S <= "1111";
								
								ABUS <= W2;
								LPC <= W2;
								
							when "1010" =>  -- OUT
								
								-- 设定算术运算
								M <= W2;
								S <= "1010";
								ABUS <= W2;
							when others =>  -- 空指令
								
								-- 设定PC
								LIR <= W1;
								PCINC <= W1;
						end case;
					when others =>
						-- 不可能到这吧?
				end case;
			when "001" =>
				
				SELCTL<=W1;
				SHORT<=W1;
				SBUS<=W1;
				STOP_REG<=W1;
				SST0<=W1;
				LAR<=W1 and (not ST0);
				ARINC<=W1 and ST0;
				MEMW<=W1 and ST0;
			when "010" =>
				SELCTL<=W1;
				SHORT<=W1;
				SBUS<=W1 and (not ST0);
				MBUS<=W1 and ST0;
				STOP_REG<=W1;
				SST0<=W1;
				LAR<=W1 and (not ST0);
				ARINC<=W1 and ST0;
			when "011" =>
				SELCTL<='1';
				SEL0<=W1 or W2;
				STOP_REG<=W1 or W2;
				SEL3<=W2;
				SEL1<=W2;
			when "100" =>
				SELCTL<='1';
				SST0<=W2;
				SBUS<=W1 or W2;
				STOP_REG<=W1 or W2;
				DRW<=W1 or W2;
				SEL3<=(ST0 and W1) or (ST0 and W2);
				SEL2<=W2;
				SEL1<=((not ST0) and W1) or (ST0 and W2);
				SEL0<=W1;
			when others=>
		end case;
	end process;
end arc;






