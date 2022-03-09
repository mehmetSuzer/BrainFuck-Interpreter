# BrainFuck-Interpreter

This is a simple interpreter for the programming language Brainfuck written in ARM assembly language on Raspberry Pi Zero WH.
Just type your brainfuck code to label 'program' in the file.
You can use the commands below.

To compile the code:
as -o brainfuck.o brainfuck.s
ls -o brainfuck brainfuck.o

To run and get the error code:
./brainfuck; echo $?

If the error code is different than 0, then there is a problem with square braces.
The program in the file simply prints "Hello World!\n"

