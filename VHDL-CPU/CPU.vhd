library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
   
entity CPU is
	port (
		CLR,		--��λ�źţ��͵�ƽ��Ч
		C,			--��λ��׼
		Z,			--���־ 
		T3,			--T3ʱ��
		W1,			--W1�������
		W2,			--W2�������
		W3			--W3�������
		: in std_logic;
		IRH			--IR7654
		: in std_logic_vector(3 downto 0);
		SWCBA		--ABģʽ����ֵ,CΪ1ʱΪʵ��̨�����߼�ʵ��
		: in std_logic_vector(2 downto 0);
		SELCTL,		--Ϊ1ʱΪ����̨����
		ABUS,		--Ϊ1ʱ�������������������
		M,			--
		SEL1,		--�൱�ڿ���̨��ʽ��ָ�������IR3210
		SEL0,
		SEL2,
		SEL3,
		DRW,		--Ϊ1ʱ����Ĵ�������
		SBUS,		--Ϊ1ʱ�������ݿ���ֵ����������
		LIR,		--Ϊ1ʱ���Ӵӳ��ڶ�����ָ�������Ĵ���
		MBUS,		--Ϊ1ʱ���Ӵ洢������������������������
		MEMW,		--Ϊ1ʱ��T2д�洢����Ϊ0ʱ���洢��
		LAR,		--Ϊ1ʱ��T2�������ؽ����������ϵĵ�ַ�����ַ�Ĵ���
		ARINC,		--Ϊ1ʱ��T2�������ص�ַ�Ĵ�����һ
		LPC,		--Ϊ1ʱ��T2�������ص�ַ�����������ϵ����ݴ���PC
		PCINC,		--Ϊ1ʱ��T2��������PC+1
		PCADD,
		CIN,
		LONG,
		SHORT,
		STOP,		--�۲�ʹ��
		LDC,		--Ϊ1ʱT3�������ر����λ
		LDZ			--Ϊ1ʱT3�������ر�����Ϊ0�ı�־
		: out std_logic;
		S			--S3210
		: out std_logic_vector(3 downto 0);
		CP1,CP2,CP3 : out std_logic;
		QD : in std_logic
		
		
		
		
	--	;SB : out std_logic
	);
end CPU;

architecture arc of CPU is
signal ST0,ST0_REG,SST0,STOP_REG1,STOP_REG2: std_logic;
begin
--	SB <= ST0;
	CP1 <= '1';
	CP2 <= '1';
	CP3 <= QD;
	
	with SWCBA select
		STOP <= '0'						when "000",
				STOP_REG1 or STOP_REG2 	when others;
	ST0 <= ST0_REG;

	process (CLR, T3)
	begin
		-- �κ�ʱ����CLR, ���᷵��
		if (CLR = '0') then
			ST0_REG <= '0';
			STOP_REG1 <= '1';
		-- ��������ĵ�λT3�½��أ�ST0_REG |= SST0
		elsif (T3'event and T3 = '0') then
			if (SST0 = '1') then
				ST0_REG <= '1';
			end if;
		end if;
	end process;
	
	process (SWCBA, IRH, W1, W2, W3, ST0, C, Z)
	begin
	
		-- ��ʼ�� �� ״̬����
		SHORT <= '0';
		LONG <= '0';
		-- ����STOP
		STOP_REG2 <= '1';
		-- ����ST0��־
		SST0 <= '0';
		
		-- ALU
		ABUS <= '0';
		M <= '0';
		CIN <= '0';
		S <= "0000";
		ARINC <= '0';
		-- ����Z��־
		LDZ <= '0';
		-- ����C��־
		LDC <= '0';		
	
		SBUS <= '0';
		MBUS <= '0';
		
		-- ����̨������־
		SELCTL <= '0';
		
		-- RD1~RD0
		SEL3 <= '0';
		SEL2 <= '0';
		
		-- RS1~RS0
		SEL1 <= '0';
		SEL0 <= '0';
		
		-- ��ָ��Ĵ�����־
		LIR <= '0';
		-- �͵�ַ�Ĵ�����־
		LAR <= '0';
		-- �ͳ����������־
		LPC <= '0';

		
		-- (~R)/W
		MEMW <= '0';
		DRW <= '0';
		
		-- ���������������־
		PCINC <= '0';		
		-- ���������������־
		PCADD <= '0';
		
		
		
		case SWCBA is
			when "000" =>  --ִ�г���
				case ST0 is
					when '0' =>
						-- load pc
						LPC <= W1;
						SBUS <= W1;
						SST0 <= W1;
						
						SHORT <= W1;
						-- STOP_REG2 <= '0';
					when '1' =>
						case IRH is
							when "0000" =>  -- NOP
								
								-- �趨PC
								LIR <= W1;
								PCINC <= W1;
								
								-- ������
								SHORT <= W1;
							when "0001" =>  --ADD ()
								
								-- �趨PC
								LIR <= W1;
								PCINC <= W1;
								
								-- ������
								SHORT <= W1;
								
								-- ABUS = W1
								ABUS <= W1;
								CIN <= W1;
								
								-- ѡ��ӷ�
								-- ѡ����������, M�Ѿ�����ʼ��Ϊ0
								S <= "1001";
								
								-- �ӷ�����
								DRW <= W1;
								LDZ <= W1;
								LDC <= W1;
							
							when "0010" =>  -- SUB ()
								
								-- �趨PC
								LIR <= W1;
								PCINC <= W1;
								
								-- ������
								SHORT <= W1;
								
								-- ѡ����������, ѡ�����
								-- M�Ѿ�����ʼ��Ϊ0
								S <= "0110";
								-- TODO: CIN��?
								
								-- ��������
								ABUS <= W1;
								DRW <= W1;
								LDZ <= W1;
								LDC <= W1;
							when "0011" =>  -- AND ()
								
								-- �趨PC
								LIR <= W1;
								PCINC <= W1;
								
								-- ������
								SHORT <= W1;
								
								-- ѡ���߼�����, ������
								M <= W1;
								S <= "1011";
								
								ABUS <= W1;
								DRW <= W1;
								LDZ <= W1;
							when "0100" =>
								
								--case SEL1 & SEL0 is
								--	when "00" =>  -- INC ()
										-- �趨PC
										LIR <= W1;
										PCINC <= W1;
										
										-- ������
										SHORT <= W1;
										
										-- ѡ����������, ������
										-- M�Ѿ�����ʼ��Ϊ0
										S <= "0000";
										
										ABUS <= W1;
										DRW <= W1;
										LDZ <= W1;
										LDC <= W1;
								--	when "01" =>  -- DEC ()
								--		-- �趨PC
								--		LIR <= W1;
								--		PCINC <= W1;
								--		
								--		-- ������
								--		SHORT <= W1;
								--		
								--		-- ѡ����������, ������
								--		-- M�Ѿ�����ʼ��Ϊ0
								--		CIN <= W1;
								--		S <= "1111";
								--		
								--		ABUS <= W1;
								--		DRW <= W1;
								--		LDZ <= W1;
								--		LDC <= W1;
								--	when "10" => -- NOT
								--		-- �趨PC
								--		LIR <= W1;
								--		PCINC <= W1;
								--		
								--		-- ������
								--		SHORT <= W1;
								--		
								--		-- ѡ���߼�����, ������
								--		M <= W1;
								--		S <= "0000";
								--		
								--		ABUS <= W1;
								--		DRW <= W1;
								--		LDZ <= W1;
								--		LDC <= W1;
								--	when "10" => -- CLR
								--		-- �趨PC
								--		LIR <= W1;
								--		PCINC <= W1;
								--		
								--		-- ������
								--		SHORT <= W1;
								--		
								--		-- ѡ���߼�����, A <= 0000
								--		M <= W1;
								--		S <= "0011";
								--		
								--		ABUS <= W1;
								--		DRW <= W1;
								--		LDZ <= W1;
								--		LDC <= W1;
								--	when others =>
								--end case;
								
							when "0101" =>  -- LD
								
								
								-- ѡ���������㣬����B������ԭֵ��
								M <= W1;
								S <= "1010";
								
								ABUS <= W1;
								LAR <= W1;
								
								-- �趨PC
								LIR <= W2;
								PCINC <= W2;
								
								MBUS <= W2;
								DRW <= W2;
							when "0110" =>  -- ST
								
								
								-- �趨...
								M <= W1 or W2;
								
								if(W1='1')then
									S<="1111";
								else
									S<="1010";
								end if;
								
								
								ABUS <= W1 or W2;
								LAR <= W1;
								
								MEMW <= W2;
								-- �趨PC
								LIR <= W2;
								PCINC <= W2;
								
							
							when "0111" =>  -- JC
								
								-- �趨PC
								LIR <= (W1 and (not C)) or (W2 and C);
								PCINC <= (W1 and (not C)) or (W2 and C);
								PCADD <= C and W1;
								SHORT <= W1 and (not C);
							
							when "1000" =>  -- JZ
								
								-- �趨PC
								LIR <= (W1 and (not Z)) or (W2 and Z);
								PCINC <= (W1 and (not Z)) or (W2 and Z);
								PCADD <= Z and W1;
								SHORT <= W1 and (not Z);
								
							when "1001" =>  -- JMP
								
								-- �趨��������
								M <= W1;
								S <= "1111";
								
								ABUS <= W1;
								LPC <= W1;
								
								-- �趨PC
								LIR <= W2;
								PCINC <= W2;
								
							when "1010" =>  -- OUT
								
								-- �趨PC
								LIR <= W1;
								PCINC <= W1;
								
								-- ������
								SHORT <= W1;
								
								-- �趨��������
								M <= W1;
								S <= "1010";
								ABUS <= W1;

							when "1011" =>  -- SSP  -- ori XOR ()
								M <= W1 or W2;
								if (W1 = '1') then
									S <= "1000";
								else
									-- or S <= "1111"
									S <= "1010";
								end if;
								
								ABUS <= W1;
								LAR <= W1;
								
								-- 
								MBUS <= W2;
								MEMW <= W2;
								
								-- �趨PC
								LIR <= W2;
								PCINC <= W2;
							--	-- �趨PC
							--	LIR <= W1;
							--	PCINC <= W1;
							--	
							--	-- ������
							--	SHORT <= W1;
							--	
							--	-- ѡ���߼�����, xor����
							--	M <= W1;
							--	S <= "0110";
							--	
							--	ABUS <= W1;
							--	DRW <= W1;
							--	LDZ <= W1;
								
								
							when "1100" =>  -- PUSHS -- ori OR ()
								M <= W1 or W2;
								CIN <= W3;
								if (W1 = '1') then
									S <= "1111";
								elsif (W2 = '1') then
									S <= "1010";
								elsif (W3 = '1') then
									S <= "1111";
								end if;
								
								ABUS <= W1 or W2 or W3;
								LAR <= W1;
								
								MBUS <= W2;
								MEMW <= W2;
								LONG <= W2;
								
								DRW <= W3;
								LIR <= W3;
								PCINC <= W3;
							--	-- �趨PC
							--	LIR <= W1;
							--	PCINC <= W1;
							--	
							--	-- ������
							--	SHORT <= W1;
							--	
							--	-- ѡ���߼�����, or����
							--	M <= W1;
							--	S <= "1110";
							--	
							--	ABUS <= W1;
							--	DRW <= W1;
							--	LDZ <= W1;
							when "1101" =>  -- MOV B->A
								-- �趨PC
								LIR <= W1;
								PCINC <= W1;
								
								-- ������
								SHORT <= W1;
								
								-- ѡ���߼�����, MOV ����
								M <= W1;
								S <= "1010";
								
								ABUS <= W1;
								DRW <= W1;
								LDZ <= W1;
							
							when "1110" =>  -- STP
							
								--if (SEL3 = '1' and SEL2 = '1') then
								--	if (SEL1 = '1' and SEL0 = '1') then -- SSP
								--		-- ѡ���߼�����, A <- 0000
								--		M <= W1 or W2;
								--		if (W1 = '1') then
								--			S <= "1000";
								--		else
								--			-- or S <= "1111"
								--			S <= "1010";
								--		end if;
								--		
								--		ABUS <= W1;
								--		LAR <= W1;
								--		
								--		-- 
								--		MBUS <= W2;
								--		MEMW <= W2;
								--		
								--		-- �趨PC
								--		LIR <= W2;
								--		PCINC <= W2;
								--		
								--	else -- PUSHS
								--		-- assuming SP is R3 (the forth register)
								--		-- LAR <- SP
								--		M <= W1 or W2;
								--		CIN <= W3;
								--		if (W1 = '1') then
								--			S <= "1111";
								--		elsif (W2 = '1') then
								--			S <= "1010";
								--		elsif (W3 = '1') then
								--			S <= "1111";
								--		end if;
								--		
								--		ABUS <= W1 or W2 or W3;
								--		LAR <= W1;
								--		
								--		MBUS <= W2;
								--		MEMW <= W2;
								--		LONG <= W2;
								--		
								--		DRW <= W3;
								--		LIR <= W3;
								--		PCINC <= W3;
								--		-- MBUS <- DBUS <- B
								--		-- SP --
								--	end if;
								--else -- POP STACK
									STOP_REG2 <= W1;
								--end if;
								
								
							when "1111" =>  -- STACK Function
								--case SEL3&SEL2 is
								--	when "00" =>
								--	when "01" =>
								--	when "10" =>
								--	when "11" =>
										--case SEL1 & SEL0 is
										--	when "11" => -- LSP
												-- ѡ���߼�����, A <- 0000
												M <= W1;
												S <= "1000";
												
												ABUS <= W1;
												LAR <= W1;
												
												-- 
												MBUS <= W2;
												DRW <= W2;
												
												-- �趨PC
												LIR <= W2;
												PCINC <= W2;
										--	when others => -- POPS
										--		-- �趨PC
										--		LIR <= W1;
										--		PCINC <= W1;
										--		
										--		-- ������
										--		SHORT <= W1;
										--		
										--		-- ѡ����������, ������
										--		-- M�Ѿ�����ʼ��Ϊ0
										--		S <= "0000";
										--		
										--		ABUS <= W1;
										--		DRW <= W1;
										--		LDZ <= W1;
										--		LDC <= W1;
										--end case;
								--	when others=>
								-- end case;				
												
												
												
												
							when others =>  -- ������
								
								-- �趨PC
								LIR <= W1;
								PCINC <= W1;
								
								-- TODO: SHORT��?
						end case;
					when others =>
						-- �����ܵ����?
				end case;
			when "001" =>
			--	SEL0<=ST0;
				-- SBUS = (ST0=0 or ST0=1) and W1 
				SBUS <= W1;
				-- STOP = (ST0=0 or ST0=1) and W1
				STOP_REG2 <= W1;
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
				
				-- TODO: ����
				SST0 <= W1;
				
			when "010" =>
				-- SHORT = (ST0=0 or ST0=1) and W1
				SHORT<=W1;
				-- SELCTL = (ST0=0 or ST0=1) and W1
				SELCTL <= W1;
				-- STOP = (ST0=0 or ST0=1) and W1
				STOP_REG2<=W1;
				
				-- SBUS = (ST0=0) and W1
				SBUS<=W1 and (not ST0);
				-- LAR = (ST0=0) and W1
				LAR<=W1 and (not ST0);
				-- MBUS = (ST0=1) and W1
				MBUS<=W1 and ST0;
				-- ARINC = (ST0=1) and W1
				ARINC<=W1 and ST0;


				-- TODO: ����
				SST0<=W1;
			when "011" =>
				
				-- SELCTL = W1 or W2
				SELCTL <= '1';
				-- STOP = W1 or W2
				STOP_REG2 <= W1 or W2;
				
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
				STOP_REG2 <= W1 or W2;
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
				
				-- TODO: ����
				SST0 <= W2;
				
			when others=>
		end case;
	end process;
end arc;






