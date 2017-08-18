.include "constants.asm"
.include "header.asm"

.segment "ZEROPAGE"
sprite_x: .res 1
sprite_y: .res 1
sprite_v: .res 1  ; sprite's vertical movement direction
                  ; 0 for up, 1 for down
sprite_h: .res 1  ; sprite's horizontal movement direction
                  ; 0 for left, 1 for right

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

  JSR update_sprite_position
  JSR draw_sprite

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

  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

forever:
  JMP forever     ; do nothing, forever
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

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "CHR"
.incbin "sprites.chr"
