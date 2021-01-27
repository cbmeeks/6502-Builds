;*******************************************************************************
;        ___   ====== ======  __            ____    __   ======  ____
;       // \\  ||     ||     //||          //  \\ //  \\   ||   //  \\
;       || __  \\__   \\__     ||          ||  || ||       ||   ||  ||
;       ||/  \     \\     \\   ||          ||  || ||       ||   ||  ||
;       || ()| \\__// \\__//   ||          ||==|| ||       ||   ||==||
;        \\__/                ====         ||  || \\__// ====== ||  ||
;===============================================================================
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; Name:                 acia.asm
; Description:          Helper methods for interfacing with WDC65C51 (ACIA).
;                       Should focus on the core methods of the ACIA.  
;                       Things like displaying welcome messages should be 
;                       limited to parent objects and not the core.
;
;     NOTE: 65C51 has a transmit bug.  See details here:
;     http://forum.6502.org/viewtopic.php?f=4&t=2543&start=30#p29795
;
;     =====================================================
;     CONTROL REGISTER
;     =====================================================
;     _____________________________________________________
;     |  7  |   6 - 5   |  4  |           3 - 0           |
;     |     |     WL    |     |            SBR            |
;     |-----+-----------+-----+---------------------------|
;     | SBN | WL1 | WL0 | RCS | SBR3 | SBR2 | SBR1 | SBR0 |
;     |-----+-----------+-----+---------------------------|
;     _____________________________________________________
;     | Bit 7                             Bit Stop Number |
;     |---------------------------------------------------|
;     | 0 | 1 Stop bit                                    |
;     | 1 | 2 Stop bits                                   |
;     | 1 | 1 1/2 Stop bits for WL = 5 and no parity      |
;     | 1 | 1 Stop bit for WL = 8 and parity              |
;     |---------------------------------------------------|
;     _____________________________________________________
;     | Bits 6-5                         Word Length (WL) |
;     |---------------------------------------------------|
;     | 6 | 5 |                                           |
;     |---+---+-------------------------------------------|
;     | 0 | 0 | 8 bits                                    |
;     | 0 | 1 | 7 bits                                    |
;     | 1 | 0 | 6 bits                                    |
;     | 1 | 1 | 5 bits                                    |
;     |---------------------------------------------------|
;     _____________________________________________________
;     | Bit 4                 Receiver Clock Source (RCS) |
;     |---------------------------------------------------|
;     | 0 | External receiver clock                       |
;     | 1 | Baud rate                                     |
;     |---------------------------------------------------|
;     _____________________________________________________
;     | Bits 3-0                 Selected Baud Rate (SBR) |
;     |---------------------------------------------------|
;     | 3 | 2 | 1 | 0 |                                   |
;     |---+---+---+---+-----------------------------------|
;     | 0 | 0 | 0 | 0 | 16x                               |
;     | 0 | 0 | 0 | 1 | 50                                |
;     | 0 | 0 | 1 | 0 | 75                                |
;     | 0 | 0 | 1 | 1 | 109.92                            |
;     | 0 | 1 | 0 | 0 | 134.58                            |
;     | 0 | 1 | 0 | 1 | 150                               |
;     | 0 | 1 | 1 | 0 | 300                               |
;     | 0 | 1 | 1 | 1 | 600                               |
;     | 1 | 0 | 0 | 0 | 1200                              |
;     | 1 | 0 | 0 | 1 | 1800                              |
;     | 1 | 0 | 1 | 0 | 2400                              |
;     | 1 | 0 | 1 | 1 | 3600                              |
;     | 1 | 1 | 0 | 0 | 4800                              |
;     | 1 | 1 | 0 | 1 | 7200                              |
;     | 1 | 1 | 1 | 0 | 9600                              |
;     | 1 | 1 | 1 | 1 | 19,200                            |
;     |---------------------------------------------------|
;
;
;
;     =====================================================
;     COMMAND REGISTER
;     =====================================================
;     _____________________________________________________
;     |    7 - 6    |  5  |  4  |    3 - 2    |  1  |  0  |
;     |     PMC     |     |     |     TIC     |     |     |
;     |-------------+-----+-----+-------------+-----------|
;     | PMC1 | PMC0 | PME | REM | TIC1 | TIC0 | IRD | DTR |
;     |-------------+-----+-----+-------------+-----------|
;     _____________________________________________________
;     | Bits 7-6                Parity Mode Control (PMC) |
;     |---------------------------------------------------|
;     | 7 | 6 |                                           |
;     |---+---+-------------------------------------------|
;     | 0 | 0 | Receiver odd parity check                 |
;     | 0 | 1 | Receiver even parity check                |
;     | 1 | 0 | Receiver parity check disabled            |
;     | 1 | 1 | Receiver parity check disabled   **       | ** Is this right?
;     |---------------------------------------------------|
;     _____________________________________________________
;     | Bit 5                   Parity Mode Enabled (PME) |
;     |---------------------------------------------------|
;     | 0 | Parity mode disabled. Parity check and        |
;     |   | transmission disabled.                        |
;     | 1 | Parity mode enabled and mark parity bit always|
;     |   | transmitted.                                  |
;     |---------------------------------------------------|
;     _____________________________________________________
;     | Bit 4                    Receiver Echo Mode (REM) |
;     |---------------------------------------------------|
;     | 0 | Receiver normal mode                          |
;     | 1 | Receiver echo mode bits 2 and 3.  Must be zero|
;     |   | for receiver echo mode, RTS will be low.      |
;     |---------------------------------------------------|
;     _____________________________________________________
;     | Bits 3-2      Transmitter Interrupt Control (TIC) |
;     |---------------------------------------------------|
;     | 3 | 2 |                                           |
;     |---+---+-------------------------------------------|
;     | 0 | 0 | RTSB = High, transmit interrupt disabled  |
;     | 0 | 1 | RTSB = Low, transmit interrupt enabled    |
;     | 1 | 0 | RTSB = Low, transmit interrupt disabled   |
;     | 1 | 1 | RTSB = Low, transmit interrupt disabled   |
;     |   |   | Transmit break on TxD                     |
;     |---------------------------------------------------|
;     _____________________________________________________
;     | Bit 1   Receiver Interrupt Request Disabled (IRD) |
;     |---------------------------------------------------|
;     | 0 | IRQB enabled                                  |
;     | 1 | IRQB disabled                                 |
;     |---------------------------------------------------|
;     _____________________________________________________
;     | Bit 0                   Data Terminal Ready (DTR) |
;     |---------------------------------------------------|
;     | 0 | Data terminal not ready (DTRB high)           |
;     | 1 | Data terminal ready (DTRB low)                |
;     |---------------------------------------------------|

;-------------------------------------------------------------------------------
.segment "SERIAL"

;-------------------------------------------------------------------------------
;       Register Locations
;       TODO    Move $5800 to config file?  Is it worth it?
;-------------------------------------------------------------------------------
ACIA            := $5800
ACIA_CTRL       := ACIA + 3
ACIA_CMD        := ACIA + 2
ACIA_SR         := ACIA + 1
ACIA_RX         := ACIA
ACIA_TX         := ACIA


;-------------------------------------------------------------------------------
;       Name:           ACIA_INIT
;       Desc:           Configures base setup
;                       19200,N,8,1
;       Destroys:       Nothing
;-------------------------------------------------------------------------------
.byte "ACIA"                ; Tag this segment.  Remove to save four bytes.
ACIA_INIT:
        PHA                 ; Push A to stack
        LDA #$1F            ; %0001 1111 = 19200 Baud
                            ;              External receiver
                            ;              8 bit words
                            ;              1 stop bit
        STA ACIA_CTRL
        LDA #$0B            ; %0000 1011 = Receiver odd parity check
                            ;              Parity mode disabled
                            ;              Receiver normal mode
                            ;              RTSB Low, trans int disabled
                            ;              IRQB disabled
                            ;              Data terminal ready (DTRB low)
        STA ACIA_CMD
        PLA                 ; Restore A
        RTS


;-------------------------------------------------------------------------------
;       Name:           ACIA_ECHO
;       Desc:           Sends data to serial port
;       Destroys:       A
;       Note:           TODO - Add fix for 65C51 transmit bug
;                       It was recommended to use ~521 microseconds 
;                       (or a little more) delay.
;-------------------------------------------------------------------------------
ACIA_ECHO:
        PHA             ; Push A to stack
@LOOP:
        LDA ACIA_SR     ; Read ACIA Status Register
        AND #$10        ; Isolate transmit data register status bit
        BEQ @LOOP
        PLA             ; Pull A from stack
        STA ACIA_TX     ; Send A
;        JSR DELAY_6551
        RTS

;-------------------------------------------------------------------------------
;       Name:           ACIA_READ
;       Desc:           Reads data from serial port and return in A
;       Destroys:       A
;       Note:           Probably not compatible with EhBASIC because it is 
;                       blocking
;-------------------------------------------------------------------------------
ACIA_READ:
        LDA #$08
ACIA_RX_FULL:
        BIT ACIA_SR             ; Check to see if the buffer is full
        BEQ ACIA_RX_FULL
        LDA ACIA_RX
        RTS





; Latest WDC 65C51 has a bug - Xmit bit in status register is stuck on
; IRQ driven transmit is not possible as a result - interrupts are endlessly triggered
; Polled I/O mode also doesn't work as the Xmit bit is polled - delay routine is the only option
; The following delay routine kills time to allow W65C51 to complete a character transmit
; 0.523 milliseconds required loop time for 19,200 baud rate
; MINIDLY routine takes 524 clock cycles to complete - X Reg is used for the count loop
; Y Reg is loaded with the CPU clock rate in MHz (whole increments only) and used as a multiplier
;
DELAY_6551:
		PHY             ;Save Y Reg
		PHX             ;Save X Reg
DELAY_LOOP:
;		LDY   #2        ;Get delay value (clock rate in MHz 2 clock cycles)
		LDY   #1        ;Get delay value (clock rate in MHz 1 clock cycles)

MINIDLY:
		LDX   #$68      ;Seed X reg
DELAY_1:
		DEX             ;Decrement low index
		BNE   DELAY_1   ;Loop back until done
		DEY             ;Decrease by one
		BNE   MINIDLY   ;Loop until done
		PLX             ;Restore X Reg
		PLY             ;Restore Y Reg
DELAY_DONE:
		RTS             ;Delay done, return

