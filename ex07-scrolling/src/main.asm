.include "constants.asm"
.include "header.asm"

.segment "ZEROPAGE"
.exportzp sprite_x, sprite_y, sprite_v, sprite_h
.exportzp paddle_x, paddle_y, controller1, temp_storage
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
.import update_sprite_position
.import draw_sprite
.import process_collisions
.import read_controller
.import update_paddle_position
.import draw_paddle
.import draw_backgrounds

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

	JSR draw_backgrounds

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
.incbin "font.chr"
