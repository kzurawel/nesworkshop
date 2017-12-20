.segment "ZEROPAGE"
.importzp sprite_x, sprite_y, sprite_v, sprite_h

.segment "CODE"
.export draw_sprite
.proc draw_sprite
  PHA ; store all registers in stack
  TXA ; this subroutine does not use
  PHA ; X or Y registers, so we don't
  TYA ; actually need to store/replace
  PHA ; them, just here as an example.
  PHP

  ; sprite data at $0200, $0204, $0208, $020c
  ; store y values first
  LDA sprite_y
  STA $0200
  STA $0204
  CLC
  ADC #$08
  STA $0208
  STA $020c

  ; store sprite tile numbers
  LDA #$04
  STA $0201
  STA $0205
  STA $0209
  STA $020d

  ; store attributes
  LDA #%00000000
  STA $0202
  LDA #%01000000
  STA $0206
  LDA #%10000000
  STA $020a
  LDA #%11000000
  STA $020e

  ; store x values
  LDA sprite_x
  STA $0203
  STA $020b
  CLC
  ADC #$08
  STA $0207
  STA $020f

  PLP ; restore all registers from stack
  PLA ; again, X and Y registers never
  TAY ; changed, so some of this could
  PLA ; be removed.
  TAX
  PLA
  RTS
.endproc

.export update_sprite_position
.proc update_sprite_position
  PHA
  PHP

  LDA sprite_v
  BEQ move_sprite_up  ; if sprite_v is 0, skip ahead
  LDA sprite_y  ; if we got here, sprite is moving down
  CLC
  ADC #$01
  STA sprite_y
  JMP vertical_movement_done  ; don't move sprite up!
move_sprite_up:
  LDA sprite_y
  SEC
  SBC #$01
  STA sprite_y  ; no need to jump here
vertical_movement_done:
  LDA sprite_h
  BEQ move_sprite_left  ; if sprite_h is 0, skip ahead
  LDA sprite_x  ; if we got here, sprite is moving right
  CLC
  ADC #$01
  STA sprite_x
  JMP horizontal_movement_done
move_sprite_left:
  LDA sprite_x
  SEC
  SBC #$01
  STA sprite_x
horizontal_movement_done: ; all done, restore registers and return

  PLP
  PLA
  RTS
.endproc
