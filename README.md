# 16-Bit-CPU

A VHDL implementation of a simple 16-bit single-cycle CPU, built from modular components including an ALU, register file, control unit, program counter, and memory. The design is intended for simulation and educational purposes (e.g., FPGA or ModelSim/QuestaSim).

# Overview
CPU_3380 is a single-cycle 16-bit CPU written in VHDL. It supports a small RISC-style instruction set with:
1. Register-to-register arithmetic/logic (ADD, SUB, AND, OR, SLT)
2. Immediate arithmetic (ADDi, SUBi)
3. Memory access (LW, SW)
4. Control flow (BNE, JUMP)

The CPU is composed of reusable subcomponents, most of which are also provided as standalone files.

# Key modules:

1. CPU_3380	CPU_33802.vhd	Top-level CPU
2. ALU_16Bit	ALU_16Bit3.vhd	16-bit ALU (ripple-carry)
3. ALU	ALU4.vhd	1-bit ALU slice
4. full_adder	full_adder2.vhd	1-bit full adder
5. and_gate	and_gate2.vhd	2-input AND
6. or_gate	or_gate2.vhd	2-input OR
7. MUX31	MUX312.vhd	1-bit 3-to-1 MUX
8. Control	Control1.vhd	Instruction decoder / control unit
9. Registers	Registers2.vhd	16 x 16-bit register file
10. Signextend	Signextend1.vhd	4-bit -> 16-bit sign extension
11. Memory	Memory.vhd	Generic single-port memory
12. mux2_1	mux2_11.vhd	Generic 2-to-1 MUX
13. mux3_1	mux3_11.vhd	Generic 3-to-1 MUX
14. PC_REG	PC_REG.vhd	Program counter register

# File Structure

├── CPU_33802.vhd        # Top-level CPU
├── ALU_16Bit3.vhd       # 16-bit ALU
├── ALU4.vhd             # 1-bit ALU slice
├── full_adder2.vhd      # 1-bit full adder
├── and_gate2.vhd        # AND gate
├── or_gate2.vhd         # OR gate
├── MUX312.vhd           # 1-bit 3-to-1 MUX
├── mux2_11.vhd          # Generic 2-to-1 MUX
├── mux3_11.vhd          # Generic 3-to-1 MUX
├── Control1.vhd         # Control unit
├── Registers2.vhd       # Register file
├── Signextend1.vhd      # Sign extender
├── Memory.vhd           # Memory model
├── PC_REG.vhd           # Program counter
├── Instr.txt            # Instruction memory image
├── Instr2.txt           # Alternate instruction memory image
└── in.txt               # Data memory image
Instruction Set
Instructions are 16 bits wide:

 15 14 13 12 | 11 10  9  8 | 7  6  5  4 | 3  2  1  0
 +-----------+------------+------------+------------+
 |    op     |     rd     |     rs     |     rt     |
 +-----------+------------+------------+------------+
 
Opcode (hex)	Mnemonic	Operation	Description
0x0	ADD	rd = rs + rt	- Add registers
0x1	SUB	rd = rs - rt	- Subtract registers
0x2	AND	rd = rs & rt	- Bitwise AND
0x3	OR	rd = rs | rt	- Bitwise OR
0x4	ADDi	rd = rs + imm	- Add immediate (rt sign-extended)
0x5	SUBi	rd = rs - imm	- Subtract immediate
0x7	SLT	rd = (rs < rt) ? 1 : 0	- Set on less than
0x8	LW	rd = mem[rs + imm]	- Load word
0x9	BNE	if (rs != 0) PC += imm	- Branch if not equal (not zero)
0xB	JUMP	PC = {PC[15:12], instr[11:0]}	- Jump
0xC	SW	mem[rs + imm] = rd	- Store word
Note: The BNE implementation uses Zero from the ALU (which is based on rs - rt). The branch condition is ctrl_branch AND NOT zero.

# Control Signals
The Control unit outputs the following signals based on the opcode:

alu_op - Selects ALU operation (00=ADD, 01=SUB, 10=AND, 11=OR)
alu_src	-	0 = register, 1 = immediate
reg_dest	-	0 = rd, 1 = rt (register write address)
reg_load	-	Register file write enable
reg_src	-	Write-back source: 00=memory, 01=ALU, 10=SLT
mem_read	-	Data memory read enable
mem_write	-	Data memory write enable
branch	-	Branch enable
jump	-	Jump enable
