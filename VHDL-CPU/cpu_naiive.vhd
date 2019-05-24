library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
entity CPU is
	port (
		CLR,C,Z,T3,W1,W2,W3: in std_logic;
		IRH:in std_logic_vector(3 downto 0);
		SWCBA:in std_logic_vector(2 downto 0);
		SELCTL,ABUS,M,SEL1,SEL0,SEL2,SEL3,DRW,SBUS,LIR,MBUS,MEMW,LAR,ARINC,LPC,PCINC,PCADD,CIN,LONG,SHORT,STOP,LDC,LDZ: out std_logic;
		S:out std_logic_vector(3 downto 0);
		CP1,CP2,CP3:out std_logic;	
		QD:in std_logic	
	);
end CPU;

architecture arc of CPU is
signal ST0,ST0_1,ST0_2,STOP_1,STOP_2: std_logic;
begin	
	with SWCBA select
		STOP <= '0'						when "000",
				STOP_1 or STOP_2 		when others;
	ST0 <= ST0_1;

	process (CLR, T3)
	begin
		-- 任何时候按下CLR, 都会返回
		if (CLR = '0') then
			ST0_1	<= '0';
			STOP_1	<= '1';
		-- 如果到节拍电位T3下降沿，ST0_1 |= ST0_2
		elsif (T3'event and T3 = '0') then
			if (ST0_2 = '1') then
				ST0_1 <= '1';
			end if;
		end if;
	end process;
	
	process (SWCBA, IRH, W1, W2, W3, ST0, C, Z)
	begin	
		-- 初始化 和 状态参数
		SHORT <= '0';
		LONG <= '0';
		-- 设置STOP
		STOP_2 <= '1';
		-- 设置ST0标志
		ST0_2 <= '0';
		-- ALU
		ABUS <= '0';
		M <= '0';
		CIN <= '0';
		S <= "0000";
		ARINC <= '0';
		-- 保存Z标志
		LDZ <= '0';
		-- 保存C标志
		LDC <= '0';		
		SBUS <= '0';
		MBUS <= '0';
		-- 控制台操作标志
		SELCTL <= '0';
		-- RD1~RD0
		SEL3 <= '0';
		SEL2 <= '0';
		-- RS1~RS0
		SEL1 <= '0';
		SEL0 <= '0';
		-- 送指令寄存器标志
		LIR <= '0';
		-- 送地址寄存器标志
		LAR <= '0';
		-- 送程序计数器标志
		LPC <= '0';
		-- (~R)/W
		MEMW <= '0';
		DRW <= '0';
		-- 程序计数器自增标志
		PCINC <= '0';		
		-- 程序计数器增量标志
		PCADD <= '0';
		case SWCBA is
			when "000" =>  --执行程序
				case ST0 is
					when '0' =>
						-- load pc
						LPC <= W1;
						SBUS <= W1;
						ST0_2 <= W1;
						SHORT <= W1;
						STOP_2 <= '0';
                    when '1' =>
						if(W1='1')then
							LIR<=W1;
							PCINC<=W1;
						else                        
							case IRH is 
								when "0001" =>  --ADD 														
									-- ABUS = W2
									ABUS <= W2;
									CIN <= W2;
									-- 选择加法
									-- 选择算术运算, M已经被初始化为0
									S <= "1001";
									-- 加法操作
									DRW <= W2;
									LDZ <= W2;
									LDC <= W2;
								when "0010" =>  -- SUB													
									-- 选择算术运算, 选择减法
									-- M已经被初始化为0
									S <= "0110";
									-- 减法操作
									ABUS <= W2;
									DRW <= W2;
									LDZ <= W2;
									LDC <= W2;
								when "0011" =>  -- AND								
									-- 选择逻辑运算, 与运算
									M <= W2;
									S <= "1011";
									ABUS <= W2;
									DRW <= W2;
									LDZ <= W2;
								when "0100" => -- INC								
									-- 选择算术运算, 与运算
									-- M已经被初始化为0
									S <= "0000";
									ABUS <= W2;
									DRW <= W2;
									LDZ <= W2;
									LDC <= W2;
								when "0101" =>  -- LD
									-- 选择算术运算，传送B（保留原值）
									M <= W2;
									S <= "1010";
									ABUS <= W2;
									LONG<=W2;
									LAR <= W2;
									MBUS <= W3;
									DRW <= W3;
								when "0110" =>  -- ST
									LONG<=W2;
									-- 设定...
									M <= W2 or W3;
									if(W2='1')then
										S<="1111";
									else
										S<="1010";
									end if;
									ABUS <= W2 or W3;
									LAR <= W2;
									MEMW <= W3;							
								when "0111" =>  -- JC
									PCADD <= C and W2;
								when "1000" =>  -- JZ
									PCADD <= Z and W2;
								when "1001" =>  -- JMP
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
								when "1011" =>  -- SSP  
									SEL3<='1';
									LONG<=W2;
									M <= W2 or W3;
									if (W2 = '1') then
										S <= "1000";
									elsif (W3 = '1') then
										S <= "1010";
									end if;
									ABUS <= W2 or W3;
									LAR <= W2;
									MEMW <= W3;
								when "1100" =>  -- PUSH
									--PUSH无法自减
									M <= W2 or W3;
									if (W2 = '1') then
										S <= "1111";
									elsif (W3 = '1') then
										S <= "1010";
									end if;
									ABUS <=W2 or W3;
									LAR <= W2;
									MEMW <= W3;
									LONG <= W2;
								when "1101" =>  -- MOV B->A								
									-- 选择逻辑运算, MOV 运算
									M <= W2;
									S <= "1010";
									ABUS <= W2;
									DRW <= W2;
									LDZ <= W2;
								when "1110" =>  -- STP
									STOP_2 <= W2;								
								when "1111" =>  -- LSP
									LONG<=W2;
									M <= W2;
									S <= "1000";
									ABUS <= W2;
									LAR <= W2;
									MBUS <= W3;
									DRW <= W3;		
								when others =>  -- 公操作
							end case;
						end if;
					when others =>
							-- 不可能到这吧?
				end case;
			when "001" =>
			--	SEL0<=ST0;
				-- SBUS = (ST0=0 or ST0=1) and W1 
				SBUS <= W1;
				-- STOP = (ST0=0 or ST0=1) and W1
				STOP_2 <= W1;
				-- SHORT = (ST0=0 or ST0=1) and W1
				SHORT <= W1;
				-- SELCTL = (ST0=0 or ST0=1) and W1
				SELCTL <= W1;
				-- LAR = (ST0=0) and W1
				LAR <= W1 and (not ST0);
				-- LAR = (ST0=1) and W1
				ARINC <= W1 and ST0;
				-- MEMW = (ST0=1) and W1
				MEMW <= W1 and ST0;
				ST0_2 <= W1;
			when "010" =>
				-- SHORT = (ST0=0 or ST0=1) and W1
				SHORT<=W1;
				-- SELCTL = (ST0=0 or ST0=1) and W1
				SELCTL <= W1;
				-- STOP = (ST0=0 or ST0=1) and W1
				STOP_2<=W1;
				-- SBUS = (ST0=0) and W1
				SBUS<=W1 and (not ST0);
				-- LAR = (ST0=0) and W1
				LAR<=W1 and (not ST0);
				-- MBUS = (ST0=1) and W1
				MBUS<=W1 and ST0;
				-- ARINC = (ST0=1) and W1
				ARINC<=W1 and ST0;
				ST0_2<=W1;
			when "011" =>
				-- SELCTL = W1 or W2
				SELCTL <= '1';
				-- STOP = W1 or W2
				STOP_2 <= W1 or W2;
				-- SEL0 = W1 or W2
				SEL0<=W1 or W2;
				-- SEL1 = W2
				SEL1<=W2;
				-- SEL2 = 0
				-- SEL3 = W2
				SEL3<=W2;
			when "100" =>
				-- SELCTL = (ST0=0 or ST0=1) and (W1 or W2)
				SELCTL <= '1';
				-- SBUS = (ST0=0 or ST0=1) and (W1 or W2)
				SBUS <= W1 or W2;
				-- STOP = (ST0=0 or ST0=1) and (W1 or W2)
				STOP_2 <= W1 or W2;
				-- DRW = (ST0=0 or ST0=1) and (W1 or W2)
				DRW <= W1 or W2;
				-- SEL0 = (ST0=0 or ST0=1) and W1
				SEL0 <= W1;
				-- SEL1 = ((ST0=0) and W1) or ((ST0=1) and W2)
				SEL1 <= ((not ST0) and W1) or (ST0 and W2);
				-- SEL2 = (ST0=0 or ST0=1) and W2
				SEL2 <= W2;
				-- SEL3 = (ST0=1) and (W1 or W2) 
				SEL3 <= ST0 and (W1 or W2);
				ST0_2 <= W2;
			when others=>
		end case;
	end process;
end arc;