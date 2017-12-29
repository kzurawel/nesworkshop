.segment "ZEROPAGE"
.importzp sprite_x, sprite_y, sprite_h, sprite_v
.importzp paddle_x, temp_storage

.segment "CODE"
.export process_collisions
.proc process_collisions
	PHA
	PHP

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
  CMP #$c8            ; is sprite_y greater than #$c8 (the paddle)?
  BCC check_top_edge
	JSR check_paddle_collision ; yes - see if we hit the paddle
  JMP vertical_check_done
check_top_edge:
  CMP #$08            ; no. is it less than #$08?
  BCS vertical_check_done
  LDA #$01            ; yes
  STA sprite_v
vertical_check_done:
	PLP
	PLA
  RTS
.endproc

.proc check_paddle_collision
  PHA
  PHP

  LDA sprite_x
  CMP paddle_x  ; is sprite_x greater than paddle_x?
  BCC no_collision
  ; yes
  CLC
  ADC #$10
  STA temp_storage
  LDA paddle_x
  CLC
  ADC #$20
  CMP temp_storage  ; is right end of paddle greater than right end of sprite?
  BCC no_collision
  ; yes - we have a collision!
  LDA #$00
  STA sprite_v
no_collision:

  PLP
  PLA
  RTS
.endproc
