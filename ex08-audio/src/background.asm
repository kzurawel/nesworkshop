.include "constants.inc"

.segment "CODE"
.export draw_backgrounds
.proc draw_backgrounds
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
  LDX #$22
  STX PPUADDR
  LDX #$02
  STX PPUADDR
  LDX #$00
draw_havefun:
  LDA havefun, x
  STA PPUDATA
  INX
  CPX #$08
  BNE draw_havefun

  LDX PPUSTATUS
  LDX #$21
  STX PPUADDR
  LDX #$97
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

.segment "RODATA"
goodluck:
.byte $0a, $12, $12, $07, $00, $0f, $18, $06, $0e

havefun:
.byte $0b, $04, $19, $08, $00, $09, $18, $11

pong:
.byte $13, $12, $11, $0a, $28
