.segment "ZEROPAGE"
.importzp sprite_x, sprite_y, sprite_h, sprite_v

.segment "CODE"
.export process_collisions
.proc process_collisions
  LDA sprite_x
  CMP #$ec            ; is sprite_x greater than #$ec?
  BCC check_left_edge
  LDA #$00            ; yes
  STA sprite_h
  JMP horizontal_check_done
check_left_edge:
  CMP #$04            ; no. is it less than #$04?
  BCS horizontal_check_done
  LDA #$01            ; yes
  STA sprite_h
horizontal_check_done: ; all done with x, now y
  LDA sprite_y
  CMP #$d8            ; is sprite_y greater than #$d8?
  BCC check_top_edge
  LDA #$00            ; yes
  STA sprite_v
  JMP vertical_check_done
check_top_edge:
  CMP #$08            ; no. is it less than #$08?
  BCS vertical_check_done
  LDA #$01            ; yes
  STA sprite_v
vertical_check_done:
  RTS
.endproc
