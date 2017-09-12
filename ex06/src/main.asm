.include "constants.asm"
.include "header.asm"

.segment "ZEROPAGE"
sprite_x: .res 1
sprite_y: .res 1
sprite_v: .res 1  ; sprite's vertical movement direction
                  ; 0 for up, 1 for down
sprite_h: .res 1  ; sprite's horizontal movement direction
                  ; 0 for left, 1 for right
paddle_x: .res 1
paddle_y: .res 1
controller1: .res 1
temp_storage: .res 1
scroll_x: .res 1
scroll_table: .res 1

.segment "BSS"

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.proc reset_handler
  SEI           ; turn on interrupts
  CLD           ; turn off non-existent decimal mode
  LDX #$00
  STX PPUCTRL   ; disable NMI
  STX PPUMASK   ; turn off display

vblankwait:     ; wait for PPU to fully boot up
  BIT PPUSTATUS
  BPL vblankwait

  JMP main
.endproc

.proc nmi_handler
  LDA #$00    ; draw SOMETHING first,
  STA OAMADDR ; in case we run out
  LDA #$02    ; of vblank time,
  STA OAMDMA  ; then update positions

  JSR process_collisions
  JSR update_sprite_position
  JSR draw_sprite
  JSR read_controller
  JSR update_paddle_position
  JSR draw_paddle

  LDA scroll_x
  STA PPUSCROLL
  LDA #$00
  STA PPUSCROLL
  LDA scroll_table
  STA PPUCTRL

  LDA scroll_x
  CLC
  ADC #$01
  STA scroll_x
  CMP #$00
  BNE no_wrap
  LDA scroll_table
  CMP #%10010000
  BEQ first_nametable
  LDA #%10010000
  STA scroll_table
  JMP no_wrap
first_nametable:
  LDA #%10010001
  STA scroll_table
no_wrap:
  RTI
.endproc

.proc main
  LDA #$70        ; set up initial sprite values
  STA sprite_x    ; these are stored in zeropage
  LDA #$30
  STA sprite_y
  LDA #$01
  STA sprite_v
  STA sprite_h

  LDA #$70
  STA paddle_x
  LDA #$d8
  STA paddle_y

  LDA #$00
  STA scroll_x
  LDA #%10010000
  STA scroll_table

  LDX PPUSTATUS   ; reset PPUADDR latch
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR     ; set PPU to write to $3f00 (palette ram)

copy_palettes:
  LDA palettes,x  ; use indexed addressing into palette storage
  STA PPUDATA
  INX
  CPX #$20          ; have we copied 32 values?
  BNE copy_palettes ; if no, repeat

vblankwait:       ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankwait

  JSR draw_backgrounds  ; write to nametables and attribute tables

vblankwait2:
  BIT PPUSTATUS
  BPL vblankwait2

  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

forever:
  JMP forever     ; do nothing, forever
.endproc

.proc draw_backgrounds
  LDX PPUSTATUS
  LDX #$21
  STX PPUADDR
  LDX #$c3
  STX PPUADDR
draw_strangeloop:
  LDA strangeloop, x
  STA PPUDATA
  INX
  CPX #$0c
  BNE draw_strangeloop

  LDX PPUSTATUS
  LDX #$20
  STX PPUADDR
  LDX #$4b
  STX PPUADDR
  LDX #$00
draw_goodluck:
  LDA goodluck, x
  STA PPUDATA
  INX
  CPX #$09
  BNE draw_goodluck

  LDX PPUSTATUS
  LDX #$26
  STX PPUADDR
  LDX #$c4
  STX PPUADDR
  LDX #$00
draw_havefun:
  LDA havefun, x
  STA PPUDATA
  INX
  CPX #$08
  BNE draw_havefun

  LDX PPUSTATUS
  LDX #$25
  STX PPUADDR
  LDX #$14
  STX PPUADDR
  LDX #$00
draw_pong:
  LDA pong, x
  STA PPUDATA
  INX
  CPX #$04
  BNE draw_pong

; write both attribute tables
  LDA PPUSTATUS
  LDA #$23
  STA PPUADDR
  LDA #$c0
  STA PPUADDR
  LDA #%01010101
  LDX #$00
write_attribute_table:
  STA PPUDATA
  INX
  CPX #$40
  BNE write_attribute_table

  LDA PPUSTATUS
  LDA #$27
  STA PPUADDR
  LDA #$c0
  STA PPUADDR
  LDA #%01010101
  LDX #$00
write_page_2_attribute_table:
  STA PPUDATA
  INX
  CPX #$40
  BNE write_page_2_attribute_table
  RTS
.endproc

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
  JSR check_paddle_collision  ; yes - see if we hit the paddle
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

.segment "RODATA"
palettes:
.byte $21, $00, $10, $30
.byte $21, $01, $0f, $31
.byte $21, $06, $16, $26
.byte $21, $09, $19, $29

.byte $21, $00, $10, $30
.byte $21, $01, $0f, $31
.byte $21, $06, $16, $26
.byte $21, $09, $19, $29

goodluck:
.byte $0a, $12, $12, $07, $00, $0f, $18, $06, $0e

havefun:
.byte $0b, $04, $19, $08, $00, $09, $18, $11

pong:
.byte $13, $12, $11, $0a, $28

strangeloop:
.byte $16, $17, $15, $04, $11, $0a, $08, $0f, $12, $12, $13, $28

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "CHR"
.incbin "font.chr"
