



/*

An interpreter for the programming language Brainfuck written in Raspberry Pi Zero WH
Type your brainfuck program to the string 'program'

Commands to compile the program:
as -o brainfuck.o brainfuck.s
ld -o brainfuck brainfuck.o

Commands to run the program and get the error code:
./brainfuck; echo $?

If the return code is different than 0, then there is problem with square braces
The program below is taken from wikipedia and prints "Hello World!\n"

*/


.equ NULL,              0
.equ STDIN,             0
.equ STDOUT,         	1
.equ EXIT,              1
.equ READ,              3
.equ WRITE,             4
.equ ARRAY_SIZE,        10000


.data
.align 4
program: .asciz "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."  


.bss
.align 4
array:  .skip ARRAY_SIZE


.text
.global _start


.align 4
input:
  push {r7,lr}
  mov r1, r0                            @ move the address to r1
  mov r7, #READ                         @ system call READ
  mov r0, #STDIN                        @ standard input
  mov r2, #1                            @ get only one byte
  swi #0                                @ call

  pop {r7,lr}
  bx lr                                 @ return


output:
  push {r7,lr}
  mov r1, r0                            @ move the address to r1
  mov r7, #WRITE                        @ system call WRITE
  mov r0, #STDOUT                       @ standard output
  mov r2, #1                            @ print only one character
  swi #0                                @ call

  pop {r7,lr}
  bx lr                                 @ return


_start:
  ldr r5, addr_of_array                 @ ptr: data pointer
  ldr r4, addr_of_program               @ program pointer
  mov fp, sp                            @ store sp in fp

1:
  ldrb r3, [r4]                         @ load command to r3
  cmp r3, #NULL                         @ if we reach the end of the program,
  beq 100f                              @ then exit

  cmp r3, #'>'
  addeq r5, r5, #1                      @ ++ptr
  beq 4f

  cmp r3, #'<'
  subeq r5, r5, #1                      @ --ptr
  beq 4f

  cmp r3, #'+'
  bne 2f
  ldrb r6, [r5]                         @ load *ptr
  add r6, r6, #1                        @ ++*ptr
  strb r6, [r5]                         @ store *ptr
  b 4f

2:
  cmp r3, #'-'
  bne 3f
  ldrb r6, [r5]                         @ load *ptr
  sub r6, r6, #1                        @ --*ptr
  strb r6, [r5]                         @ store *ptr
  b 4f

3:
  cmp r3, #'.'
  moveq r0, r5                          @ parameter: data pointer
  bleq output                           @ call output

  cmp r3, #','
  moveq r0, r5                          @ parameter: data pointer
  bleq input                            @ call input

  cmp r3, #'['                          @ beginning of while loop
  beq 5f

  cmp r3, #']'                          @ end of while loop
  beq 7f

4:
  add r4, r4, #1                        @ increment the program pointer
  b 1b

5:
  ldrb r0, [r5]                         @ load *ptr
  cmp r0, #0                            @ compute r0-0 and update cpsr
  strne r4, [sp, #-4]!          	@ if *ptr != 0, push the address of '[' in the program
  bne 4b                                @ then go to next command

6:
  add r4, r4, #1                        @ increment program pointer
  ldrb r3, [r4]                         @ load the command
  cmp r3, #']'                          @ if the command is ']',
  addeq sp, sp, #4                      @ then remove the address of the previous '[' from the stack
  beq 4b                                @ and return back to 4
  b 6b                                  @ if not, go back to 6 to check the next command

7:
  ldrb r0, [r5]                         @ load *ptr
  cmp r0, #0                            @ compute r0-0 and update cpsr
  addeq sp, sp, #4                      @ if *ptr == 0, remove the address of the previous '['
  beq 4b                                @ then go to next command

  ldr r4, [sp]                          @ if not, load the address of the previous '['
  b 4b                                  @ and go to the command after the previous '['

100:
  sub r0, fp, sp                        @ if the return code is different than 0, then there is a problem with square braces
  mov r7, #EXIT                         @ system call EXIT
  swi #0



addr_of_program:        .word program
addr_of_array:          .word array



