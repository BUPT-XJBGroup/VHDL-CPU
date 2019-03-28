

architecture ARCH_CPU of ARC is
	
begin
	process (CLR, T3)
	begin
		if (CLR == '0') then
			ST0_REG <= '0';
			STOP_REG_REG <= '1';
		elsif (SST0 == '1') then
			ST0_REG <= '1'
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
		S <= '0';
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
			when "000"=>  --执行程序
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
								PCINC <= W;
						end case;
					when others =>
						-- 不可能到这吧?
				end case;
		end case;
	end process;
end ARCH_CPU;