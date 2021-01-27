;*******************************************************************************
;                              __  __ ======  ____
;                              ||  ||   ||   //  \\
;                              \\  //   ||   ||  ||
;                               \\//    ||   ||  ||
;                                \/     ||   ||==||
;                                 `   ====== ||  ||
;===============================================================================
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; Name:                 via.asm
; Description:          Helper methods for interfacing with WDC65C22 (VIA).

.segment "VIA"

VIA             :=      $6000
VIA_PORTB       :=      VIA
VIA_PORTA       :=      VIA + $01
VIA_DDRB        :=      VIA + $02
VIA_DDRA        :=      VIA + $03
VIA_T1CL        :=      VIA + $04
VIA_T1CH        :=      VIA + $05
VIA_T1LL        :=      VIA + $06
VIA_T1LH        :=      VIA + $07
VIA_T2LL        :=      VIA + $08
VIA_T2CL        :=      VIA + $08
VIA_T2CH        :=      VIA + $09
VIA_SR          :=      VIA + $0A
VIA_ACR         :=      VIA + $0B
VIA_PCR         :=      VIA + $0C
VIA_IFR         :=      VIA + $0D
VIA_IER         :=      VIA + $0E
VIA_ORAX        :=      VIA + $0F


.byte "VIA "            ; Tag this segment.  Remove to save four bytes
;-------------------------------------------------------------------------------
;       Name:           VIA_INIT
;       Desc:           Configures on-board VIA
;       Destroys:       Nothing
;-------------------------------------------------------------------------------
VIA_INIT:
        PHA                     ; Push A to stack
        LDA #$FF
        STA VIA_DDRA            ; PORT A is all output
        STA VIA_DDRB            ; PORT B is all output
        LDA #$00                ; Reset both ports to zero
        STA VIA_PORTA
        STA VIA_PORTB
        PLA                     ; Restore A
        RTS

