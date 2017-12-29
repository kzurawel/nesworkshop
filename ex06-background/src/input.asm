.include "constants.asm"

.segment "ZEROPAGE"
.importzp controller1

.segment "CODE"
.export read_controller
.proc read_controller
  PHA
  TXA
  PHA
  PHP

  ; write a 1, then a 0, to CONT_PORT_1
  ; to latch button states
  LDA #$01
  STA CONT_PORT_1
  LDA #$00
  STA CONT_PORT_1

  LDA #$01
  STA controller1 ; move the '1' until done
                  ; (ring counter)
get_buttons:
  LDA CONT_PORT_1   ; read from controller port
  LSR A             ; shift accumulator bit 0 into carry flag
  ROL controller1   ; move carry flag into controller1
  BCC get_buttons   ; repeat until original '1' is moved to carry

  PLP
  PLA
  TAX
  PLA
  RTS
.endproc
