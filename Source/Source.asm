.include "Include/Definitions.inc"
.include "Include/Constants.inc"
.include "Include/Header.inc"

.segment "CODE"
.proc irq_handler
    RTI
.endproc

.proc nmi_handler
    LDA #$00
    STA OAMADDR
    LDA #$02
    STA OAMDMA
    ;#
    CLC
    ;LDX PAUSE_TIMER
    ;CPX #$00
    ;BEQ TTTTTTTTTTTT
    ;DEX
    ;STX PAUSE_TIMER
    ;RTI
    ;TTTTTTTTTTTT:
    JSR SetPlayerYTarget
    LDY BALL_SPEED
    BallMovementLoop:
        LDX #$00
        STX COLLISION_ADDR
        JSR BallController
        DEY
        CPY #$00
        BNE BallMovementLoop
    JSR ReadJoypad1Input
    JSR ReadJoypad2Input
    JSR Player1MovementController
    JSR Player2MovementController
    JSR MusicEngine
    RTI
;>------------------------------------------------------<;
    BallController:
        CLC
        LDA BALL_X
        ADC BALL_X_SPEED_AMP
        STA BALL_X
        ;#
        CLC
        LDA BALL_Y
        ADC BALL_Y_SPEED_AMP
        STA BALL_Y
        JSR CheckBallPlayerCollision
        JSR CheckBallScreenCollisions
        JSR CheckBallOutOfBounds
        RTS
    CheckBallScreenCollisions:
        CLC
        LDX BALL_Y
        CPX #$05
        BEQ InvertBallYSpeed
        CPX #$C5
        BEQ InvertBallYSpeed
        ;$
        LDX COLLISION_ADDR
        CPX #$01
        BNE NoCollisionWithPlayer
        LDX BALL_X 
        CPX #$0C
        BEQ InvertBallXSpeed
        CPX #$F0
        BEQ InvertBallXSpeed
        NoCollisionWithPlayer:
        RTS
    SetPauseTime:
        LDX #$20
        STX PAUSE_TIMER
        JSR ParryBall
        RTS
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    CheckBallPlayerCollision:
        CLC
        ;LDA PLAYER_1_Y
        LDA PLAYING_Y
        SBC #$04
        TAX
        CLC
        
        ;LDX PLAYER_1_Y
        CPX BALL_Y
        LDA COLLISION_ADDR
        ADC COLLISION_ADDR
        STA COLLISION_ADDR
        ;#
        CLC
        ;LDA PLAYER_1_Y
        LDA PLAYING_Y
        ADC #$04
        TAX
        CLC
        LDA #$00
        CPX BALL_Y
        ADC COLLISION_ADDR
        STA COLLISION_ADDR
        RTS
    InvertBallYSpeed:
        SEC
        LDA #$00
        SBC BALL_Y_SPEED_AMP
        STA BALL_Y_SPEED_AMP
        RTS
    InvertBallXSpeed:
        SEC
        LDA #$00
        SBC BALL_X_SPEED_AMP
        STA BALL_X_SPEED_AMP

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;LDX JOYPAD_1_DATA
        ;CPX #$02
        ;BEQ SetPauseTime

        RTS
    CheckBallOutOfBounds:
        LDA BALL_X
        CMP #$00
        BNE BallIsNotOutOfBounds
        BEQ ReallocateBallToCenter
        ReturnFromBallReallocation:
        JSR PlayerAddPoint
        JSR InvertBallXSpeed
        BallIsNotOutOfBounds:
        RTS
    ReallocateBallToCenter:
        LDX #$7D
        STX BALL_X
        STX BALL_Y
        JMP ReturnFromBallReallocation
;>------------------------------------------------------<;
    ReadJoypad1Input:
        LDA #$01
        STA $4016
        STA JOYPAD_1_DATA
        LSR A
        STA $4016
        BufferJoypadData:
            LDA $4016
            LSR A
            ROL JOYPAD_1_DATA
            BCC BufferJoypadData
        RTS
;>------------------------------------------------------<;
    ReadJoypad2Input:
        LDA #$01
        STA $4017
        STA JOYPAD_2_DATA
        LSR A
        STA $4017
        BufferJoypadData2:
            LDA $4017
            LSR A
            ROL JOYPAD_2_DATA
            BCC BufferJoypadData2
        RTS
;>------------------------------------------------------<;
    Player1MovementController:
        LDA PLAYER_1_Y
        LDX JOYPAD_1_DATA
        CPX #$08
        BEQ MovePlayer1Down
        CPX #$04
        BEQ MovePlayer1Up
        RTS
        MovePlayer1Up:
            CLC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;PHA
        ;LDA $82AE
        ;LDA #%01011111
        ;STA APU_PULSE_1_DDLCVVVV
        ;LDA #%11111101
        ;STA APU_PULSE_1_TTTTTTTT
        ;LDA #%00000000
        ;STA APU_PULSE_1_LLLLLTTT
        ;PLA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ADC PLAYER_1_SPEED
            STA PLAYER_1_Y
        RTS
        MovePlayer1Down:
            SEC
            SBC PLAYER_1_SPEED
            STA PLAYER_1_Y
        RTS
    Player2MovementController:
        LDA PLAYER_2_Y
        LDX JOYPAD_2_DATA
        CPX #$08
        BEQ MovePlayer2Down
        CPX #$04
        BEQ MovePlayer2Up
        RTS
        MovePlayer2Up:
            CLC
            ADC PLAYER_2_SPEED
            STA PLAYER_2_Y
        RTS
        MovePlayer2Down:
            SEC
            SBC PLAYER_2_SPEED
            STA PLAYER_2_Y
        RTS
;>------------------------------------------------------<;
    SetPlayerYTarget:
        BIT BALL_X_SPEED_AMP
        BMI TargetPlayer1Y
        JMP TargetPlayer2Y
        TargetPlayer1Y:
            LDX PLAYER_1_Y
            STX PLAYING_Y
        RTS
        TargetPlayer2Y:
            LDX PLAYER_2_Y
            STX PLAYING_Y
        RTS
;>------------------------------------------------------<;
    PlayerAddPoint:
        CLC
        BIT BALL_X_SPEED_AMP
        BPL AddPointToPlayer1
        JMP AddPointToPlayer2
        AddPointToPlayer1:
            CLC
            LDA PLAYER_1_POINTS
            ADC #$1
            STA PLAYER_1_POINTS
            LDA #$1F
            ADC PLAYER_1_POINTS
            STA PLAYER_1_POINTS_DISPLAY
        RTS
        AddPointToPlayer2:
            CLC
            LDA PLAYER_2_POINTS
            ADC #$1
            STA PLAYER_2_POINTS
            LDA #$1F
            ADC PLAYER_2_POINTS
            STA PLAYER_2_POINTS_DISPLAY
        RTS

;>------------------------------------------------------<;
    ParryBall:
        CLC
        LDA BALL_SPEED
        ADC #$01
        STA BALL_SPEED
        RTS
;>------------------------------------------------------<;
    MusicEngine:
        CLC
        LDX NOTE_PLAYER_TIMER
        CPX #$00
        BNE DecreaseNotePlayerTimer
        LDX TUNE_BPM
        STX NOTE_PLAYER_TIMER
        ;#
        LDX NOTE_INDEX
        CPX #$00
        BNE PlayNextRow
        JSR ReadBarHeader
        RTS
        PlayNextRow:
            JSR LoadPulse1
            JSR LoadPulse2
            JSR LoadTriangle
        RTS
        DecreaseNotePlayerTimer:
            LDX NOTE_PLAYER_TIMER
            DEX
            STX NOTE_PLAYER_TIMER
        RTS
        LoadPulse1:
            ;LDX NOTE_INDEX
            ;INX
            ;INX
            ;INX
            ;INX
            ;STX NOTE_INDEX
            ;RTS
            
            LDX APU_PULSE_1_COUNTER
            CPX #$00
            BEQ Load1
            DEX
            STX APU_PULSE_1_COUNTER
            RTS
            Load1:
                JSR GetNoteLength1
                ;LDX NOTE_INDEX
                
                ;LDA TUNE_ADDR, X
                LDX #$00
                LDA (ROW_COUNTER, X)
                STA APU_PULSE_1_DDLCVVVV
                LDX ROW_COUNTER
                INX
                STX ROW_COUNTER
                ;INX
                ;LDA TUNE_ADDR, X
                LDX #$00
                LDA (ROW_COUNTER, X)
                STA APU_PULSE_1_EPPPNSSS
                LDX ROW_COUNTER
                INX
                STX ROW_COUNTER
                ;INX
                ;LDA TUNE_ADDR, X
                LDX #$00
                LDA (ROW_COUNTER, X)
                STA APU_PULSE_1_TTTTTTTT
                LDX ROW_COUNTER
                INX
                STX ROW_COUNTER
                ;INX
                ;LDA TUNE_ADDR, X
                LDX #$00
                LDA (ROW_COUNTER, X)
                AND #%00000111
                ADC #%00001000
                STA APU_PULSE_1_LLLLLTTT
                LDX ROW_COUNTER
                INX
                STX ROW_COUNTER
                ;INX
                ;STX NOTE_INDEX
            RTS
        LoadPulse2:
            LDX NOTE_INDEX
            INX
            INX
            INX
            INX
            STX NOTE_INDEX
        RTS


            LDX APU_PULSE_2_COUNTER
            CPX #$00
            BEQ Load2
            DEX
            STX APU_PULSE_2_COUNTER
            RTS
            Load2:
                JSR GetNoteLength2
                LDX NOTE_INDEX
                
                LDA TUNE_ADDR, X
                STA APU_PULSE_2_DDLCVVVV
                INX
                LDA TUNE_ADDR, X
                STA APU_PULSE_2_EPPPNSSS
                INX
                LDA TUNE_ADDR, X
                STA APU_PULSE_2_TTTTTTTT
                INX
                LDA TUNE_ADDR, X
                AND #%00000111
                ADC #%00001000
                STA APU_PULSE_2_LLLLLTTT
                INX
                STX NOTE_INDEX
            RTS
        LoadTriangle:
            LDX NOTE_INDEX
            INX
            INX
            INX
            STX NOTE_INDEX
        RTS

            LDX NOTE_INDEX

            LDA TUNE_ADDR, X
            STA APU_TRIANGLE_CRRRRRRR
            INX
            LDA TUNE_ADDR, X
            STA APU_TRIANGLE_TTTTTTTT
            INX
            LDA TUNE_ADDR, X
            STA APU_TRIANGLE_LLLLLTTT
            INX
            STX NOTE_INDEX
        RTS
        GetNoteLength1:
            CLC
            LDA NOTE_INDEX
            ADC #$03
            TAX
            LDA TUNE_ADDR, X
            AND #%11111000
            LSR A
            LSR A
            LSR A
            ;CMP #$00
            ;BEQ NoteLengthZero
            STA APU_PULSE_1_COUNTER
            ;CLC
            ;LDA TUNE_ADDR, X
            ;AND #%00000111
            ;ADC #%00001000

            ;STA TUNE_ADDR, X
            ;GetLengthBitsLoops:
            ;    CMP TUNE_ADDR
            ;CLC
            ;LSR A
            ;LSR A
            ;LSR A
            ;STA APU_PULSE_1_COUNTER
            ;LDA #$0A
            ;ADC APU_PULSE_1_COUNTER
            ;STA APU_PULSE_1_COUNTER
            ;LDA TUNE_ADDR, X
            ;NoteLengthZero:
            CLC
            ;AND #%00000111
            ;ADC #%00001000
            ;STA TUNE_ADDR, X
        RTS
        GetNoteLength2:
            CLC
            LDA NOTE_INDEX
            ADC #$03
            TAX
            LDA TUNE_ADDR, X
            AND #%11111000
            LSR A
            LSR A
            LSR A
            ;CMP #$00
            ;BEQ NoteLengthZero
            STA APU_PULSE_2_COUNTER
            ;CLC
            ;LDA TUNE_ADDR, X
            ;AND #%00000111
            ;ADC #%00001000

            ;STA TUNE_ADDR, X
            ;GetLengthBitsLoops:
            ;    CMP TUNE_ADDR
            ;CLC
            ;LSR A
            ;LSR A
            ;LSR A
            ;STA APU_PULSE_1_COUNTER
            ;LDA #$0A
            ;ADC APU_PULSE_1_COUNTER
            ;STA APU_PULSE_1_COUNTER
            ;LDA TUNE_ADDR, X
            ;NoteLengthZero:
            CLC
            ;AND #%00000111
            ;ADC #%00001000
            ;STA TUNE_ADDR, X
        RTS
        ReadBarHeader:
            CLC
            LDX NOTE_INDEX
            INX
            STX NOTE_INDEX
            CLC
        RTS
;>------------------------------------------------------<;
    SynchronizeAPU:
        
;>------------------------------------------------------<;
.endproc

.import reset_handler

.export main
.proc main

vblankwait:       ; wait for another vblank before continuing
    BIT PPUSTATUS
    BPL vblankwait

    LDA #%10010000  ; turn on NMIs, sprites use first pattern table
    STA PPUCTRL
    LDA #%00011110  ; turn on screen
    STA PPUMASK

forever:
    JMP forever
.endproc

.segment "VECTORS"
    .addr nmi_handler, reset_handler, irq_handler

.segment "CHR"
    .incbin "../Resources/Graphics/Graphics.chr"