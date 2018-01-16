.include "constants.inc"

.segment "ZEROPAGE"
.importzp paddle_y, paddle_x, controller1

.segment "CODE"
.export draw_paddle
.proc draw_paddle
  PHA
  TXA
  PHA
  PHP

  LDA paddle_y
  STA $0210
  STA $0214
  STA $0218
  STA $021c

  LDA #$02
  STA $0211
  STA $0215
  STA $0219
  STA $021d

  LDA #$00
  STA $0212
  STA $0216
  STA $021a
  STA $021e

  LDA paddle_x
  LDX #$00
write_paddle_x_values:
  STA $0213,x
  CLC
  ADC #$08
  INX
  INX
  INX
  INX
  CPX #$10
  BCC write_paddle_x_values

  PLP
  PLA
  TAX
  PLA
  RTS
.endproc

.export update_paddle_position
.proc update_paddle_position
  PHA
  PHP

  LDA controller1
  AND #BTN_LEFT
  BEQ not_left_pressed

  LDA paddle_x
  SEC
  SBC #$02
  STA paddle_x
  JMP done_with_controller

not_left_pressed:
  LDA controller1
  AND #BTN_RIGHT
  BEQ done_with_controller

  LDA paddle_x
  CLC
  ADC #$02
  STA paddle_x

done_with_controller:
  PLP
  PLA
  RTS
.endproc
