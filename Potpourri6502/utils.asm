;*******************************************************************************
;                     ||  || ====== ====== ||      -----
;                     ||  ||   ||     ||   ||     //
;                     ||  ||   ||     ||   ||     \\___
;                     ||  ||   ||     ||   ||         \\
;                     ||__||   ||     ||   ||         //
;                     \\__//   ||   ====== \\==== -----
;===============================================================================
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

.segment "UTILS"
.byte "UTILS"

;------------------------------------------------------------------------------
;       Name:           DELAY1
;       Desc:           Slight delay (TODO, calculate and re-name)
;       Destroys:       Nothing
;------------------------------------------------------------------------------

DELAY1:
        PHP                     ; Push status register
        PHX                     ; Push X to stack
        PHY                     ; Push Y to stack

        LDX     #$00
        LDY     #$04
_DELAY1:
        DEX
        BNE     _DELAY1
        DEY
        BNE     _DELAY1

        PLY                     ; Restore Y
        PLX                     ; Restore X
        PLP                     ; Restore status register

        RTS


;------------------------------------------------------------------------------
;       Name:           DELAY
;       Desc:           9 * (256 * A + Y) + 8 cycles
;                       Assumes that the BCS does not cross a page boundary
;                       Credit to dclxvi for the mechanics
;                       Thanks to barrym95838 for the reference
;------------------------------------------------------------------------------
DELAY:
      PHA
      PHY
@DLOOP:
      CPY   #1
      DEY
      SBC   #0
      BCS   @DLOOP
      PLY
      PLA

      RTS