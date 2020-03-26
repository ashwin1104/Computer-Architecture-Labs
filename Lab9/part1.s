# syscall constants
PRINT_STRING            = 4
PRINT_CHAR              = 11
PRINT_INT               = 1

# memory-mapped I/O
VELOCITY                = 0xffff0010
ANGLE                   = 0xffff0014
ANGLE_CONTROL           = 0xffff0018

BOT_X                   = 0xffff0020
BOT_Y                   = 0xffff0024
GET_OPPONENT_HINT       = 0xffff00ec

TIMER                   = 0xffff001c
ARENA_MAP               = 0xffff00dc

SHOOT_UDP_PACKET        = 0xffff00e0
GET_BYTECOINS           = 0xffff00e4
USE_SCANNER             = 0xffff00e8

REQUEST_PUZZLE          = 0xffff00d0  ## Puzzle
SUBMIT_SOLUTION         = 0xffff00d4  ## Puzzle

BONK_INT_MASK           = 0x1000
BONK_ACK                = 0xffff0060

TIMER_INT_MASK          = 0x8000
TIMER_ACK               = 0xffff006c

REQUEST_PUZZLE_INT_MASK = 0x800       ## Puzzle
REQUEST_PUZZLE_ACK      = 0xffff00d8  ## Puzzle

RESPAWN_INT_MASK        = 0x2000      ## Respawn
RESPAWN_ACK             = 0xffff00f0  ## Respawn

.data
### Puzzle
puzzle:     .byte 0:268
solution:   .byte 0:256
#### Puzzle

has_puzzle: .word 0
has_timer: .word 0

flashlight_space: .word 0

scanner_wb: .byte 0 0 0 0

.text
main:
    # Construct interrupt mask
    li      $t4, 0
    or      $t4, $t4, BONK_INT_MASK # request bonk
    or      $t4, $t4, REQUEST_PUZZLE_INT_MASK           # puzzle interrupt bit
    or      $t4, $t4, TIMER_INT_MASK
    or      $t4, $t4, 1 # global enable
    mtc0    $t4, $12

    #Fill in your code here
    li $t0, 10          # t0 = velocity = 10
    sw $t0, VELOCITY

    li $t0, 50     # t0 = angle = right
    li $t1, 1       # t1 = angle_control = 1
    sw $t0, ANGLE
    sw $t1, ANGLE_CONTROL

    lw $t2, TIMER     # t2 = time
    addi $t2, $t2, 30000 # t2 += 8000
    sw $t2, TIMER

check_timer:
    la $t3, has_timer   # t3 = &has_timer
    lw $t4, 0($t3)      # t4 = has_timer
    beq $t4, $0, check_timer
    sw $0, 0($t3)

transition_to_down:
  sw $0, VELOCITY
  li $t0, 10          # t0 = velocity = 10
  sw $t0, VELOCITY
  li $t0, 90     # t0 = angle = right
  li $t1, 1        # t1 = angle_control = 1
  sw $t0, ANGLE
  sw $t1, ANGLE_CONTROL

  lw $t2, TIMER     # t2 = time
  addi $t2, $t2, 30000 # t2 += 8000
  sw $t2, TIMER

move_down:
  la $t3, has_timer   # t3 = &has_timer
  lw $t4, 0($t3)      # t4 = has_timer
  beq $t4, $0, move_down
  sw $0, 0($t3)

transition_to_right:
  sw $0, VELOCITY
  li $t0, 10          # t0 = velocity = 10
  sw $t0, VELOCITY
  li $t0, 0     # t0 = angle = right
  li $t1, 1        # t1 = angle_control = 1
  sw $t0, ANGLE
  sw $t1, ANGLE_CONTROL

  lw $t2, TIMER     # t2 = time
  addi $t2, $t2, 30000 # t2 += 8000
  sw $t2, TIMER

move_right:

    la $t3, has_timer   # t3 = &has_timer
    lw $t4, 0($t3)      # t4 = has_timer
    # la $t5, scanner_wb
    # sw $t5, USE_SCANNER
    # lw $t5, USE_SCANNER
    # li $t6, 2
    # beq $t5, $t6, fire
    beq $t4, $0, move_right
    sw $0, 0($t3)
    j fire;

end:
  jr      $ra

fire:
  sw $0, SHOOT_UDP_PACKET
  j move_right_2_prep

move_right_2_prep:
      lw $t2, TIMER     # t2 = time
      addi $t2, $t2, 30000 # t2 += 8000
      sw $t2, TIMER

move_right_2:
      la $t3, has_timer   # t3 = &has_timer
      lw $t4, 0($t3)      # t4 = has_timer
      beq $t4, $0, move_right_2
      sw $0, 0($t3)

fire_2:
sw $0, SHOOT_UDP_PACKET

move_right_3_prep:
      lw $t2, TIMER     # t2 = time
      addi $t2, $t2, 30000 # t2 += 8000
      sw $t2, TIMER

move_right_3:
      la $t3, has_timer   # t3 = &has_timer
      lw $t4, 0($t3)      # t4 = has_timer
      beq $t4, $0, move_right_3
      sw $0, 0($t3)
move_right_4_prep:
            lw $t2, TIMER     # t2 = time
            addi $t2, $t2, 30000 # t2 += 8000
            sw $t2, TIMER

move_right_4:
            la $t3, has_timer   # t3 = &has_timer
            lw $t4, 0($t3)      # t4 = has_timer
            beq $t4, $0, move_right_4
            sw $0, 0($t3)

            fire_3:
            la $t5, scanner_wb
            sw $t5, USE_SCANNER
                  sw $0, SHOOT_UDP_PACKET
move_right_5_prep:
                        lw $t2, TIMER     # t2 = time
                        addi $t2, $t2, 30000 # t2 += 8000
                        sw $t2, TIMER

            move_right_5:
                        la $t3, has_timer   # t3 = &has_timer
                        lw $t4, 0($t3)      # t4 = has_timer
                        beq $t4, $0, move_right_5
                        sw $0, 0($t3)
                        move_right_6_prep:
                                    lw $t2, TIMER     # t2 = time
                                    addi $t2, $t2, 30000 # t2 += 8000
                                    sw $t2, TIMER

                        move_right_6:
                                    la $t3, has_timer   # t3 = &has_timer
                                    lw $t4, 0($t3)      # t4 = has_timer
                                    beq $t4, $0, move_right_6
                                    sw $0, 0($t3)
                                    j $ra


.kdata
chunkIH:    .space 40
non_intrpt_str:    .asciiz "Non-interrupt exception\n"
unhandled_str:    .asciiz "Unhandled interrupt type\n"
.ktext 0x80000180
interrupt_handler:
.set noat
    move    $k1, $at        # Save $at
                            # NOTE: Don't touch $k1 or else you destroy $at!
.set at
    la      $k0, chunkIH
    sw      $a0, 0($k0)        # Get some free registers
    sw      $v0, 4($k0)        # by storing them to a global variable
    sw      $t0, 8($k0)
    sw      $t1, 12($k0)
    sw      $t2, 16($k0)
    sw      $t3, 20($k0)
    sw      $t4, 24($k0)
    sw      $t5, 28($k0)

    # Save coprocessor1 registers!
    # If you don't do this and you decide to use division or multiplication
    #   in your main code, and interrupt handler code, you get WEIRD bugs.
    mfhi    $t0
    sw      $t0, 32($k0)
    mflo    $t0
    sw      $t0, 36($k0)

    mfc0    $k0, $13                # Get Cause register
    srl     $a0, $k0, 2
    and     $a0, $a0, 0xf           # ExcCode field
    bne     $a0, 0, non_intrpt



interrupt_dispatch:                 # Interrupt:
    mfc0    $k0, $13                # Get Cause register, again
    beq     $k0, 0, done            # handled all outstanding interrupts

    and     $a0, $k0, BONK_INT_MASK     # is there a bonk interrupt?
    bne     $a0, 0, bonk_interrupt

    and     $a0, $k0, TIMER_INT_MASK    # is there a timer interrupt?
    bne     $a0, 0, timer_interrupt

    and     $a0, $k0, REQUEST_PUZZLE_INT_MASK
    bne     $a0, 0, request_puzzle_interrupt

    and     $a0, $k0, RESPAWN_INT_MASK
    bne     $a0, 0, respawn_interrupt

    li      $v0, PRINT_STRING       # Unhandled interrupt types
    la      $a0, unhandled_str
    syscall
    j       done

bonk_interrupt:
    sw      $0, BONK_ACK
    li $t2, 10
    sw $t2, VELOCITY
    lw $t0, ANGLE
    add $t0, $t0, 20
    sw $t0, ANGLE
    li $t1, 1
    sw $t1, ANGLE_CONTROL
    j      interrupt_dispatch      # see if other interrupts are waiting

timer_interrupt:
    sw      $0, TIMER_ACK
    la $t0, has_timer
    li $t1, 1
    sw $t1, 0($t0)
    j        interrupt_dispatch     # see if other interrupts are waiting

request_puzzle_interrupt:
    sw      $0, REQUEST_PUZZLE_ACK
    #Fill in your puzzle interrupt code here
    j       interrupt_dispatch

respawn_interrupt:
    sw      $0, RESPAWN_ACK
    #Fill in your respawn handler code here
    j       interrupt_dispatch

non_intrpt:                         # was some non-interrupt
    li      $v0, PRINT_STRING
    la      $a0, non_intrpt_str
    syscall                         # print out an error message
    # fall through to done

done:
    la      $k0, chunkIH

    # Restore coprocessor1 registers!
    # If you don't do this and you decide to use division or multiplication
    #   in your main code, and interrupt handler code, you get WEIRD bugs.
    lw      $t0, 32($k0)
    mthi    $t0
    lw      $t0, 36($k0)
    mtlo    $t0

    lw      $a0, 0($k0)             # Restore saved registers
    lw      $v0, 4($k0)
    lw      $t0, 8($k0)
    lw      $t1, 12($k0)
    lw      $t2, 16($k0)
    lw      $t3, 20($k0)
    lw      $t4, 24($k0)
    lw      $t5, 28($k0)

.set noat
    move    $at, $k1        # Restore $at
.set at
    eret
