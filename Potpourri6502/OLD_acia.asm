
.segment "SERIAL"

MSGL            = $ED
MSGH            = $EE


ACIA            := $5800
ACIA_CTRL       := ACIA + 3
ACIA_CMD        := ACIA + 2
ACIA_SR         := ACIA + 1
ACIA_DAT        := ACIA
TXDATA          := ACIA
RXDATA          := ACIA

INIT_ACIA:
        CLD                     ; Clear decimal arithmetic mode.
        CLI

        PHA                     ; Push A to stack

        LDA     #$1F            ; ACIA to 19200 Baud.
        STA     ACIA_CTRL
        LDA     #$0B            ; No Parity.
        STA     ACIA_CMD

        LDA     #$0D
        JSR     ECHO            ; New line.

        LDA     #<MSG1          ; Setup and print welcome message
        STA     MSGL
        LDA     #>MSG1
        STA     MSGH
        JSR     SHWMSG          ; Show Welcome.

        LDA     #$0D
        JSR     ECHO            ; New line.

        PLA                     ; Restore A

        RTS

ECHO:
        PHA			; Save A
        AND     #$7F            ; Change to "standard ASCII"
        STA     ACIA_DAT        ; Send it.
        JSR     DELAY1
        PLA                     ; Restore A
        RTS

; Read character from serial port and return in A
GetKey:
        LDA     #$08
RXFULL: BIT     ACIA_SR
        BEQ     RXFULL
        LDA     RXDATA
        AND     #%01111111
        RTS


RDCHR:
        LDA     ACIA_SR         ; Read the ACAI status to
        AND     #$08            ; Check if there is character in the receiver
        BEQ     NOCHAR          ; Exit now if we don't get one.
        LDA     ACIA            ; Load it into the accumulator
        SEC                     ; Set Carry to show we got a character
        RTS                     ; Return
NOCHAR:
        CLC                     ; Clear Carry (no char)
        RTS



SHWMSG:
        LDY #0
@PRINT:
        LDA (MSGL), Y
        BEQ @DONE
        JSR ECHO
        INY 
        BNE @PRINT
@DONE
        RTS


MSG1:
        .byte "Welcome to Potpourri6502...", 0
