.segment "HEADER"
.byte "NES", $1A
.byte $02       ; 16KB PRG-ROM banks
.byte $01       ; 8KB CHR-ROM banks
.byte %00000001 ; vertical mirroring
.byte %00000000 ; maper
.byte $00       ; PRG-RAM
.byte $00       ; NTSC format