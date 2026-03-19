# lazyCPU
A **wozmon**-inspired **memory monitor** and **assembly interpreter** with **theoretically infinite memory***, built in haskell.

## About
LazyCPU is a haskell-based program that leverages the language's **lazy evaluation** to create an infinite space of memory which can be written to and read from. LazyCPU leverages this to write and execute theoretically infinite* programs.

## Usage
Compile the source code using ghc:
```
ghc lazyCPU.hs
```
Then just run the binary:
```
./lazyCPU
```

When running, lazyCPU has two distinct stages: A **writing phase** and an **execution phase**. When in the writing phase, line numbers are prompted from the user, each line is a single opcode followed by a command-dependant operand. The program will continue to ask for code until the opcode `HLT` is given. At this point, lazyCPU prints the contents of memory the user has written, and then shifts into the execution phase. The execution phase interprets the code line by line and performs the operation listed.
This means that lazyCPU is a **full simulation of a CPU that has been given infinite memory***.

### Refrence
Below is a full reference of the commands available:
| Opcode | Operand  | Usage | Example |
| ------ | -------- | ----- | ------- |
│ SET | yes | place a value into the CPU register | SET AB |
│ PNT | no | print the value inside the CPU register | PNT |
│ ADD | yes | add the operand to the CPU register | ADD 07 |
│ SUB | yes | subtract the operand from the CPU register | SUB 05 |
│ MUL | yes | multiply the CPU register by the operand | MUL 08 |
│ DIV | yes | divide the CPU register by the operand | DIV 02 |
│ HLT | no | halt the program | HLT |
Please note **not all commands are available in this current release build yet**, only `SET PNT ADD HLT` are available.


*provided the machine running the program also has enough memory.
