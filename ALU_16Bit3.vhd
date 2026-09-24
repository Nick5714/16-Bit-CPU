Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

Entity ALU_16Bit is
port(	
		A		:	in		std_logic_vector(15 downto 0);
		B		:	in		std_logic_vector(15 downto 0);
		S		:	in		std_logic_vector(1 downto 0);
		Sout	:	out 	std_logic_vector(15 downto 0);
		Cout	:	out	std_logic;
		Zero : out std_logic
);
End;

Architecture behavior of ALU_16Bit is
	COMPONENT ALU
	port(	
		A		:	in		std_logic;
		B		:	in		std_logic;
		Cin	:	in		std_logic;
		S		:	in		std_logic_vector(1 downto 0);
		Sout	:	out 	std_logic;
		Cout	:	out	std_logic
	);
	END COMPONENT;

	signal Carry		:	std_logic_vector(14 downto 0);
	signal SoutBuffer :    std_logic_vector(15 downto 0);

Begin
	alu00	:	ALU	port map(A(0),		B(0),		S(0),			S,	SoutBuffer(0),		Carry(0));
	alu01	:	ALU	port map(A(1),		B(1),		Carry(0),	S,	SoutBuffer(1),		Carry(1));
	alu02	:	ALU	port map(A(2),		B(2),		Carry(1),	S,	SoutBuffer(2),		Carry(2));
	alu03	:	ALU	port map(A(3),		B(3),		Carry(2),	S,	SoutBuffer(3),		Carry(3));
	
	alu04	:	ALU	port map(A(4),		B(4),		Carry(3),	S,	SoutBuffer(4),		Carry(4));
	alu05	:	ALU	port map(A(5),		B(5),		Carry(4),	S,	SoutBuffer(5),		Carry(5));
	alu06	:	ALU	port map(A(6),		B(6),		Carry(5),	S,	SoutBuffer(6),		Carry(6));
	alu07	:	ALU	port map(A(7),		B(7),		Carry(6),	S,	SoutBuffer(7),		Carry(7));

	alu08	:	ALU	port map(A(8),		B(8),		Carry(7),	S,	SoutBuffer(8),		Carry(8));
	alu09	:	ALU	port map(A(9),		B(9),		Carry(8),	S,	SoutBuffer(9),		Carry(9));
	alu10	:	ALU	port map(A(10),	B(10),	Carry(9),	S,	SoutBuffer(10),	Carry(10));
	alu11	:	ALU	port map(A(11),	B(11),	Carry(10),	S,	SoutBuffer(11),	Carry(11));

	alu12	:	ALU	port map(A(12),	B(12),	Carry(11),	S,	SoutBuffer(12),	Carry(12));
	alu13	:	ALU	port map(A(13),	B(13),	Carry(12),	S,	SoutBuffer(13),	Carry(13));
	alu14	:	ALU	port map(A(14),	B(14),	Carry(13),	S,	SoutBuffer(14),	Carry(14));
	alu15	:	ALU	port map(A(15),	B(15),	Carry(14),	S,	SoutBuffer(15),	Cout);
	
	Sout <= SoutBuffer;
	Zero <= '1' when unsigned(SoutBuffer) = 0 else '0';
	
End;
	