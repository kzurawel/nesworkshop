.segment "HEADER"
.byte "NES", $1a	; Magic string that always begins an iNES header
.byte $08					; how many 16KB PRG-ROM banks (8, 128KB)
.byte $01					; how many 8KB CHR-ROM banks (1, 8KB)
.byte %01000011		; Vertical mirroring, 8KB save RAM, MMC3 mapper
.byte $00					; no other special settings
.byte $00					; no PRG-RAM
