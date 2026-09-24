# 16-Bit CPU (CPU_3380)

A VHDL implementation of a simple 16-bit single-cycle CPU, built from modular components including an ALU, register file, control unit, program counter, and memory. The design is intended for simulation and educational purposes (e.g., FPGA or ModelSim/QuestaSim).

---

## Overview

`CPU_3380` is a single-cycle 16-bit CPU written in VHDL. It supports a small RISC-style instruction set with:

1. Register-to-register arithmetic/logic (ADD, SUB, AND, OR, SLT)
2. Immediate arithmetic (ADDi, SUBi)
3. Memory access (LW, SW)
4. Control flow (BNE, JUMP)

The CPU is composed of reusable subcomponents, most of which are also provided as standalone files.

---

## Key Modules

| Module | File | Purpose |
|---|---|---|
| `CPU_3380` | `CPU_33802.vhd` | Top-level CPU |
| `ALU_16Bit` | `ALU_16Bit3.vhd` | 16-bit ALU (ripple-carry) |
| `ALU` | `ALU4.vhd` | 1-bit ALU slice |
| `full_adder` | `full_adder2.vhd` | 1-bit full adder |
| `and_gate` | `and_gate2.vhd` | 2-input AND |
| `or_gate` | `or_gate2.vhd` | 2-input OR |
| `MUX31` | `MUX312.vhd` | 1-bit 3-to-1 MUX |
| `Control` | `Control1.vhd` | Instruction decoder / control unit |
| `Registers` | `Registers2.vhd` | 16 x 16-bit register file |
| `Signextend` | `Signextend1.vhd` | 4-bit -> 16-bit sign extension |
| `Memory` | `Memory.vhd` | Generic single-port memory |
| `mux2_1` | `mux2_11.vhd` | Generic 2-to-1 MUX |
| `mux3_1` | `mux3_11.vhd` | Generic 3-to-1 MUX |
| `PC_REG` | `PC_REG.vhd` | Program counter register |

---

## File Structure

```
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
```

---

## Instruction Set

Instructions are 16 bits wide:

```
 15 14 13 12 | 11 10  9  8 | 7  6  5  4 | 3  2  1  0
 +-----------+------------+------------+------------+
 |    op     |     rd     |     rs     |     rt     |
 +-----------+------------+------------+------------+
```

| Opcode (hex) | Mnemonic | Operation | Description |
|---|---|---|---|
| `0x0` | ADD  | rd = rs + rt | Add registers |
| `0x1` | SUB  | rd = rs - rt | Subtract registers |
| `0x2` | AND  | rd = rs & rt | Bitwise AND |
| `0x3` | OR   | rd = rs \| rt | Bitwise OR |
| `0x4` | ADDi | rd = rs + imm | Add immediate (rt sign-extended) |
| `0x5` | SUBi | rd = rs - imm | Subtract immediate |
| `0x7` | SLT  | rd = (rs < rt) ? 1 : 0 | Set on less than |
| `0x8` | LW   | rd = mem[rs + imm] | Load word |
| `0x9` | BNE  | if (rs != 0) PC += imm | Branch if not equal (not zero) |
| `0xB` | JUMP | PC = {PC[15:12], instr[11:0]} | Jump |
| `0xC` | SW   | mem[rs + imm] = rd | Store word |

> **Note:** The BNE implementation uses `Zero` from the ALU (which is based on `rs - rt`). The branch condition is `ctrl_branch AND NOT zero`.

---

## Control Signals

The `Control` unit outputs the following signals based on the opcode:

| Signal | Purpose |
|---|---|
| `alu_op` | Selects ALU operation (`00`=ADD, `01`=SUB, `10`=AND, `11`=OR) |
| `alu_src` | `0` = register, `1` = immediate |
| `reg_dest` | `0` = rd, `1` = rt (register write address) |
| `reg_load` | Register file write enable |
| `reg_src` | Write-back source: `00`=memory, `01`=ALU, `10`=SLT |
| `mem_read` | Data memory read enable |
| `mem_write` | Data memory write enable |
| `branch` | Branch enable |
| `jump` | Jump enable |

---

## How It Works

1. **Fetch** - `PC_REG` outputs the current PC. Instruction memory is addressed by `pc_reg_output` and returns a 16-bit `instruction`.
2. **Decode** - `op`, `rd`, `rs`, `rt` are extracted from the instruction. `Control` generates all control signals. `Signextend` expands the 4-bit `rt` field to 16 bits.
3. **Execute** - The ALU performs the operation selected by `ctrl_alu_op` on `rs_data` and either `rt_data` or the sign-extended immediate.
4. **Memory** - For LW/SW, data memory is accessed at `alu_result`.
5. **Write-Back** - The `reg_src` 3-to-1 MUX selects between memory data, ALU result, or SLT result, and writes to the register file.
6. **PC Update** - `pc_plus_2` is computed. If branching, the branch target is `pc_plus_2 + sign_ex_out`. If jumping, the target is `{pc_plus_2[15:12], instruction[11:0]}`. The final PC comes from the jump MUX.

---

## Simulation

1. Ensure all `.vhd` files are added to your project (e.g., Vivado, Quartus, ModelSim).
2. Set `CPU_33802.vhd` as the top-level entity.
3. Provide `Instr.txt` (or `Instr2.txt`) and `in.txt` in the simulation working directory.
4. Drive the inputs:
   - `clk` - clock
   - `clear` - active-low reset (`'0'` resets PC and registers)
   - `mem_dump` - optional memory dump trigger
5. Observe `cpu_out` (16-bit) for the write-back value each cycle.

Example testbench stimulus:

```vhdl
clk <= '0'; clear <= '0'; wait for 10 ns;
clear <= '1';
for i in 0 to 50 loop
    clk <= '1'; wait for 10 ns;
    clk <= '0'; wait for 10 ns;
end loop;
```

---


## License

Educational project - no explicit license provided. Use at your own discretion.
