#Zatacka
#By Jeremy Sant
#UTORid: santjere
#Station 94
.global main
main:


.equ ADDR_PUSHBUTTONS, 0xFF200050
.equ IRQ_PUSHBUTTONS,0b10
.equ IRQ_TIMER,0b1
.equ LEDS, 0xFF200000
.equ ADDR_7SEG1, 0xFF200020
.equ ADDR_7SEG2, 0xFF200030
.equ TIMERPERIOD, 3500000 
.equ TIMER, 0xFF202000
.equ TRURNRATE, 6


.equ VGA_ADDR, 0xFF203020
.equ ADDR_REDLEDS, 0xFF200000


movia r10,TIMER #set base address
movi r11,%hi(TIMERPERIOD) #set timer period
stwio r11,12(r10)
movi r11,%lo(TIMERPERIOD)
stwio r11,8(r10)
stwio r0,0(r10) #clear “timeout” bit, just in case
movi r11,0b111 #start timer, continuous, interrupt enabled
stwio r11,4(r10) #note: Other initialization, any order, but this should be last
movia r2,IRQ_TIMER
wrctl ctl3,r2  

movi r20, TRURNRATE #Turn rate

clear_score:
  movia r2,ADDR_7SEG1
  movia r3,0b0000000 
  stwio r3,0(r2)        # Write to 7-seg display
 

setup_screen:
 movia r8, 0x08000000
 movia r7, 0x0803BE7E
 
 black:
  movia r5, 0x0000
  sthio r5, 0(r8)
  addi r8, r8, 0x2
  bleu r8,r7,black

 movia r8, 0x08000000
 movia r7, 0x08000302
 
 white_top:
  movia r5, 0xFFFF
  sthio r5, 0(r8)
  addi r8, r8, 0x2
  bleu r8,r7,white_top

 movia r8, 0x0803BC00
 movia r7, 0x0803BE7E
 
 white_bottom:
  movia r5, 0xFFFF
  sthio r5, 0(r8)
  addi r8, r8, 0x2
  bleu r8,r7,white_bottom


 movia r8, 0x0803BC00
 movia r7, 0x0800007E
 
 white_left:
  movia r5, 0xFFFF
  sthio r5, 0(r8)
  subi r8, r8, 0x400
  bgeu r8,r7,white_left

  movia r8, 0x0803BE7E
 movia r7, 0x0800067E
 
 white_right:
  movia r5, 0xFFFF
  sthio r5, 0(r8)
  subi r8, r8, 0x400
  bgeu r8,r7,white_right
 
 

 addi sp,sp,-16
  stw r7,0(sp)
  stw r8,4(sp)
  stw r11,8(sp)
  stw r12,12(sp) 
  call random_start
  ldw r7,0(sp)
  ldw r8,4(sp)
  ldw r11,8(sp)
  ldw r12,12(sp)
  addi sp,sp,16
mov r7, r2 # Player 1 location

 addi sp,sp,-16
  stw r7,0(sp)
  stw r8,4(sp)
  stw r11,8(sp)
  stw r12,12(sp) 
  call random_start
  ldw r7,0(sp)
  ldw r8,4(sp)
  ldw r11,8(sp)
  ldw r12,12(sp)
  addi sp,sp,16
mov r11, r2 # Player 2 location

  addi sp,sp,-16
  stw r7,0(sp)
  stw r8,4(sp)
  stw r11,8(sp)
  stw r12,12(sp) 
  call random_start_d
  ldw r7,0(sp)
  ldw r8,4(sp)
  ldw r11,8(sp)
  ldw r12,12(sp)
  addi sp,sp,16

mov r8, r2   # Player 1 direction


  addi sp,sp,-16
  stw r7,0(sp)
  stw r8,4(sp)
  stw r11,8(sp)
  stw r12,12(sp) 
  call random_start_d
  ldw r7,0(sp)
  ldw r8,4(sp)
  ldw r11,8(sp)
  ldw r12,12(sp)
  addi sp,sp,16
  
mov r12, r2     # Player 2 direction


movia r2,1
wrctl ctl0,r2   # Enable global Interrupts on Processor

run: br run

 
 

P1_win:
  movia r2,ADDR_7SEG1
  movia r3,0b0000110 # Display 1
  stwio r3,0(r2)     # Write to 7-seg display
  br done
P2_win:
  movia r2,ADDR_7SEG1
  movia r3,0b1011011 # Display 1
  stwio r3,0(r2)     # Write to 7-seg display
  br done
 
 
done: 
  movia r10, 0xFF200040 #turn on any switch to restart
  ldwio r10,0(r10) 
  beq r0, r10, done
  br main



# Interrupts come here.
.section .exceptions, "ax"
.align 2

addi sp,sp,-8 #we need to use a second and third register, so we save r10 and r9
stw r10,0(sp)
stw r9,4(sp)

movia et,TIMER
stwio r0,0(et) #acknowledge
# set LEDS to values


movia r10, ADDR_PUSHBUTTONS
movia r14, LEDS
ldwio r10,0(r10) #get button values
stwio r10,0(r14)

subi r20, r20, 1

bne r20, r0, draw_line

movi r20, TRURNRATE

check_1:
  andi r9, r10, 0b0001
  movi r13, 0b0001
  beq r13,r9,P1_Clock
check_2:
  andi r9, r10, 0b0010
  movi r13, 0b0010
  beq r13,r9,P1_C_Clock
check_3:
  andi r9, r10, 0b0100
  movi r13, 0b0100
  beq r13,r9,P2_Clock
check_4:
  andi r9, r10, 0b1000
  movi r13, 0b1000
  beq r13,r9,P2_C_Clock
  br draw_line
P1_Clock:
  #If r8 is 4 then we must reset to 1 to go from left to up
  movi r13, 0x4
  beq r13, r8, P1_Reset_C
  addi r8, r8, 1
  br check_2
  P1_Reset_C:
    movi r8, 0x1
    br check_2
P1_C_Clock:
  #If r8 is 4 then we must reset to 1 to go from left to up
  movi r13, 0x1
  beq r13, r8, P1_Reset_C_C
  subi r8, r8, 1
  br check_3
  P1_Reset_C_C:
    movi r8, 0x4
    br check_3
P2_Clock:
  #If r12 is 4 then we must reset to 1 to go from left to up
  movi r13, 0x4
  beq r13, r12, P2_Reset_C
  addi r12, r12, 1
  br check_4
  P2_Reset_C:
    movi r12, 0x1
    br check_4
P2_C_Clock:
  #If r7 is 4 then we must reset to 1 to go from left to up
  movi r13, 0x1
  beq r13, r12, P2_Reset_C_C
  subi r12, r12, 1
  br draw_line
P2_Reset_C_C:
    movi r12, 0x4
    br draw_line


draw_line:


move_1:
  movi r10, 0x1
  beq r8,r10, move_1_up
  movi r10, 0x2
  beq r8,r10, move_1_right
  movi r10, 0x3
  beq r8,r10, move_1_down
  movi r10, 0x4
  beq r8,r10, move_1_left
move_2:
  movi r10, 0x1
  beq r12,r10, move_2_up
  movi r10, 0x2
  beq r12,r10, move_2_right
  movi r10, 0x3
  beq r12,r10, move_2_down
  movi r10, 0x4
  beq r12,r10, move_2_left


move_1_up:
  subi r7, r7, 0x400
  #check for collision
  ldhio r9, 0(r7)
  bne r9, r0, P2_win
  
  addi sp,sp,-16
  stw r7,0(sp)
  stw r8,4(sp)
  stw r11,8(sp)
  stw r12,12(sp) 
  call random_P1
  ldw r7,0(sp)
  ldw r8,4(sp)
  ldw r11,8(sp)
  ldw r12,12(sp)
  addi sp,sp,16
  mov r9, r2

  sthio r9, 0(r7)
  br move_2
 
move_1_down:
  addi r7, r7, 0x400
  #check for collision
  ldhio r9, 0(r7)
  bne r9, r0, P2_win
  addi sp,sp,-16
  stw r7,0(sp)
  stw r8,4(sp)
  stw r11,8(sp)
  stw r12,12(sp) 
  call random_P1
  ldw r7,0(sp)
  ldw r8,4(sp)
  ldw r11,8(sp)
  ldw r12,12(sp)
  addi sp,sp,16
  mov r9, r2
  sthio r9, 0(r7)
  br move_2
 
move_1_right:
  addi r7, r7, 0x2
  #check for collision
  ldhio r9, 0(r7)
  bne r9, r0, P2_win
  addi sp,sp,-16
  stw r7,0(sp)
  stw r8,4(sp)
  stw r11,8(sp)
  stw r12,12(sp) 
  call random_P1
  ldw r7,0(sp)
  ldw r8,4(sp)
  ldw r11,8(sp)
  ldw r12,12(sp)
  addi sp,sp,16
  mov r9, r2
  sthio r9, 0(r7)
  br move_2
 
move_1_left:
  subi r7, r7, 0x2
  #check for collision
  ldhio r9, 0(r7)
  bne r9, r0, P2_win
  addi sp,sp,-16
  stw r7,0(sp)
  stw r8,4(sp)
  stw r11,8(sp)
  stw r12,12(sp) 
  call random_P1
  ldw r7,0(sp)
  ldw r8,4(sp)
  ldw r11,8(sp)
  ldw r12,12(sp)
  addi sp,sp,16
  mov r9, r2
  sthio r9, 0(r7)
  br move_2


move_2_up:
  subi r11, r11, 0x400
  #check for collision
  ldhio r9, 0(r11)
  bne r9, r0, P1_win

  addi sp,sp,-16
  stw r7,0(sp)
  stw r8,4(sp)
  stw r11,8(sp)
  stw r12,12(sp) 
  call random_P2
  ldw r7,0(sp)
  ldw r8,4(sp)
  ldw r11,8(sp)
  ldw r12,12(sp)
  addi sp,sp,16
  mov r9, r2

  sthio r9, 0(r11)
  br Iexit
 
move_2_down:
  addi r11, r11, 0x400
  #check for collision
  ldhio r9, 0(r11)
  bne r9, r0, P1_win
  addi sp,sp,-16
  stw r7,0(sp)
  stw r8,4(sp)
  stw r11,8(sp)
  stw r12,12(sp) 
  call random_P2
  ldw r7,0(sp)
  ldw r8,4(sp)
  ldw r11,8(sp)
  ldw r12,12(sp)
  addi sp,sp,16
  mov r9, r2
  sthio r9, 0(r11)
  br Iexit
 
move_2_right:
  addi r11, r11, 0x2
  #check for collision
  ldhio r9, 0(r11)
  bne r9, r0, P1_win
  addi sp,sp,-16
  stw r7,0(sp)
  stw r8,4(sp)
  stw r11,8(sp)
  stw r12,12(sp) 
  call random_P2
  ldw r7,0(sp)
  ldw r8,4(sp)
  ldw r11,8(sp)
  ldw r12,12(sp)
  addi sp,sp,16
  mov r9, r2
  sthio r9, 0(r11)
  br Iexit
 
move_2_left:
  subi r11, r11, 0x2
  #check for collision
  ldhio r9, 0(r11)
  bne r9, r0, P1_win
  addi sp,sp,-16
  stw r7,0(sp)
  stw r8,4(sp)
  stw r11,8(sp)
  stw r12,12(sp) 
  call random_P2
  ldw r7,0(sp)
  ldw r8,4(sp)
  ldw r11,8(sp)
  ldw r12,12(sp)
  addi sp,sp,16
  mov r9, r2
  sthio r9, 0(r11)
  br Iexit


Iexit:

  ldw r10,0(sp)
  ldw r9,4(sp)
  addi sp,sp,8 #stack back to where it was
  subi ea,ea,4 #adjust return address
  eret #go back to interrupted routine
