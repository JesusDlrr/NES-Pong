.include "Include/Definitions.inc"
.include "Include/Constants.inc"
.include "Include/Variables.inc"

.segment "CODE"
.import main
.export reset_handler
.proc reset_handler
    SEI ; disable interrupts
    CLD ; clear decimal mode

    LDX #$FF
    TXS ;FF to stack
    INX
    STX PPUCTRL
    STX PPUMASK

    :
        BIT PPUSTATUS   ;get bit 7 of ppustatus. If is 0 we are not drawing, otherwise we are drawing
        BPL :- ; <- BRANCH PLUS. Basically bit 7 determines whenever a number is negative or positive (signed)
    
    TXA
    clearmem:
        STA $0000, X    ;00 + X
        STA $0100, X
        STA $0300, X
        STA $0400, X
        STA $0500, X
        STA $0600, X
        STA $0700, X
        LDA #$FF
        STA $0200, X    ; 200 needs to bee initialized with something different to 0 (sprite data mem) 
        LDA #$00
        INX             ;set X to 01
        BNE clearmem    ;branch if zero flag is 1. Zero flag is 1 when you INX from FF to 00

    :
        BIT PPUSTATUS
        BPL :-

    ;FILL VRAM
    LDA #$02    ;most significant byte
    STA OAMDMA
    NOP         ;burn cycle


    ; Init $4000-4013
    LDY #$13
    loop:  
        LDA regs, Y
        STA $4000,Y
        DEY
        bpl loop
    ; We have to skip over $4014 (OAMDMA)
    LDA #$0f
    STA $4015
    LDA #$40  ;Initialize frame counter to 4
    STA $4017 ;
    ;LDA #$00111111 ; enable frame counter irq
    ;STA $4017

    ;https://wiki.nesdev.com/w/index.php/PPU_palettes
    ;to 3F00 (universal palette)
    LDA #$3F    ;most significant byte
    STA PPUADDR
    LDA #$00    ;less significant byte
    STA PPUADDR
    ;0E
    LDA #$14
    STA PPUDATA
    LDA #$14
    STA PPUDATA
    LDA #$14
    STA PPUDATA
    LDA #$14
    STA PPUDATA

    ;to 3F11 (sprite palette 0)
    LDA #$3F    ;most significant byte
    STA PPUADDR
    LDA #$11    ;less significant byte
    STA PPUADDR

    LDA #$FF

    loadSpritePalette:
        INX
        LDA paletteSet0, X
        STA PPUDATA
        CPX #$07
        BNE loadSpritePalette

    LDX #$FF

    loadSprites:
        INX
        LDA spriteDataTest, X
        STA $0200, X
        CPX #$33
        BNE loadSprites

    LDX #$00
    LoadTunes:
        ;INX
        ;LDA Theme, X
        ;STA $5000
        ;CPX #$FF
        ;BNE LoadTunes

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    LDX #$01
    STX BALL_X_SPEED_AMP
    STX BALL_Y_SPEED_AMP
    LDX #$02
    STX PLAYER_1_SPEED
    STX PLAYER_2_SPEED
    LDX #$00
    STX PLAYER_TURN
    STX APU_PULSE_1_COUNTER
    LDX #$02
    STX BALL_SPEED
;;;;;;;;;;;
    LDX #$B7
    STX ROW_COUNTER
    LDX #$83
    STX TIME_COUNTER


;;;;;;;;;;;;;;;;
    LDX #$06
    STX TUNE_BPM
    LDX #$00
    STX TUNE_BEAT
    STX TUNE_NOTE
    STX BAR_REPEAT
    STX BAR_COUNT
    STX NOTE_INDEX
    STX NOTE_PLAYER_TIMER
;;;;;;;;;;;;;;;;;


    JMP main

    regs:
        .byte $30,$08,$00,$00
        .byte $30,$08,$00,$00
        .byte $80,$00,$00,$00
        .byte $30,$00,$00,$00
        .byte $00,$00,$00,$00
    paletteSet0:
        .incbin "../Resources/Graphics/Palettes/Sprite_Palette_Set_0.pld"
    spriteDataTest:
        .incbin "../Resources/Objects/TEST.gmo"
        .incbin "../Resources/Objects/TEST_2.gmo"
        .incbin "../Resources/Objects/TEST_3.gmo"
        .incbin "../Resources/Objects/Player1.gmo"
        .incbin "../Resources/Objects/Player2.gmo"
        .incbin "../Resources/Objects/Player1_Points.gmo"
        .incbin "../Resources/Objects/Player2_Points.gmo"
    Theme:
        .incbin "../Resources/Audio/Music/out.rmd"
.endproc

