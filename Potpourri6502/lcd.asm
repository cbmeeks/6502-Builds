;*******************************************************************************
;                            ||       __   ____
;                            ||     //  \\ ||  \\
;                            ||     ||     ||  ||
;                            ||     ||     ||  ||
;                            ||     ||     ||  ||
;                            \\==== \\__// ||__//
;===============================================================================
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;       At the moment, the LCD is connected as:
;               DB7:0   =       PA7:0
;               RS      =       PB1
;               EN      =       PB0
;       TODO:   Convert to 4 bit mode and free up four pins
;-------------------------------------------------------------------------------
.segment "LCD"

;-------------------------------------------------------------------------------
; 
;-------------------------------------------------------------------------------
LCDpl           =       $DE		; temporary integer low byte
LCDPh           =       LCDpl + 1	; temporary integer high byte

;===============================================================================
;                   |                     Instruction Code                     |
;                   |----+-----+-----+-----+-----+-----+-----+-----+-----+-----|
; Instruction       | RS | R/W | DB7 | DB6 | DB5 | DB4 | DB3 | DB2 | DB1 | DB0 |
;-------------------+----+-----+-----+-----+-----+-----+-----+-----+-----+-----|
; Clear Display     |  0 |  0  |  0  |  0  |  0  |  0  |  0  |  0  |  0  |  1  |
;-------------------+----+-----+-----+-----+-----+-----+-----+-----+-----+-----|
; Return Home       |  0 |  0  |  0  |  0  |  0  |  0  |  0  |  0  |  1  |  x  |
;-------------------+----+-----+-----+-----+-----+-----+-----+-----+-----+-----|
; Entry Mode Set    |  0 |  0  |  0  |  0  |  0  |  0  |  0  |  1  | I/D |  SH |
;-------------------+----+-----+-----+-----+-----+-----+-----+-----+-----+-----|
; Disp ON/OFF Ctrl  |  0 |  0  |  0  |  0  |  0  |  0  |  1  |  D  |  C  |  B  |
;-------------------+----+-----+-----+-----+-----+-----+-----+-----+-----+-----|
; Cursor/Disp Shft  |  0 |  0  |  0  |  0  |  0  |  1  | S/C | R/L |  x  |  x  |
;-------------------+----+-----+-----+-----+-----+-----+-----+-----+-----+-----|
; Function Set      |  0 |  0  |  0  |  0  |  1  |  DL |  N  |  F  |  x  |  x  |
;-------------------+----+-----+-----+-----+-----+-----+-----+-----+-----+-----|
; Set CGRAM Address |  0 |  0  |  0  |  1  | AC5 | AC4 | AC3 | AC2 | AC1 | AC0 |
;-------------------+----+-----+-----+-----+-----+-----+-----+-----+-----+-----|
; Set DDRAM Address |  0 |  0  |  1  | AC6 | AC5 | AC4 | AC3 | AC2 | AC1 | AC0 |
;-------------------+----+-----+-----+-----+-----+-----+-----+-----+-----+-----|
; Rd Busy Flg & Addr|  0 |  1  | BF  | AC6 | AC5 | AC4 | AC3 | AC2 | AC1 | AC0 |
;-------------------+----+-----+-----+-----+-----+-----+-----+-----+-----+-----|
; Write Data to RAM |  1 |  0  |  D7 |  D6 |  D5 |  D4 |  D3 |  D2 |  D1 |  D0 |
;-------------------+----+-----+-----+-----+-----+-----+-----+-----+-----+-----|
; Read Data frm RAM |  1 |  1  |  D7 |  D6 |  D5 |  D4 |  D3 |  D2 |  D1 |  D0 |
;===============================================================================

;===============================================================================
; Instruction       | Description                                    |Exe Time |
;-------------------+------------------------------------------------+---------|
;                   |                                                |         |
; Clear Display     | Write “20H” to DDRAM and set DDRAM address     | 1.53 ms |
;                   | to “00H” from AC.                              |         |
;-------------------+------------------------------------------------+---------|
;                   |                                                |         |
; Return Home       | Set DDRAM address to “00H” from AC and return  | 1.53 ms |
;                   | cursor to its original position if shifted.    |         |
;-------------------+------------------------------------------------+---------|
;                   |                                                |         |
; Entry Mode Set    | Assign cursor moving direction and enable the  |  39 µs  |
;                   | shift of entire display .                      |         |
;-------------------+------------------------------------------------+---------|
;                   |                                                |         |
; Disp ON/OFF Ctrl  | Set display (D), cursor (C), and blinking of   |  39 µs  |
;                   | cursor (B) on/off control bit.                 |         |
;-------------------+------------------------------------------------+---------|
;                   | Set cursor moving and display shift control    |         |
; Cursor/Disp Shft  | bit, and the direction, without changing of    |  39 µs  |
;                   | DDRAM data.                                    |         |
;-------------------+------------------------------------------------+---------|
;                   | Set interface data length (DL : 4-bit/8-bit),  |         |
; Function Set      | numbers of display line (N : 1-line/ 2-line,   |  39 µs  |
;                   | Display font type (F:0 ...)                    |         |
;-------------------+------------------------------------------------+---------|
;                   |                                                |         |
; Set CGRAM Address | Set CGRAM address in address counter.          |  39 µs  |
;                   |                                                |         |
;-------------------+------------------------------------------------+---------|
;                   |                                                |         |
; Set DDRAM Address | Set DDRAM address in address counter.          |  39 µs  |
;                   |                                                |         |
;-------------------+------------------------------------------------+---------|
;                   | Whether during internal operation or not can   |         |
; Rd Busy Flg & Addr| be known by reading BF.  The contents of       |  0 µs   |
;                   | address counter can also be read.              |         |
;-------------------+------------------------------------------------+---------|
;                   |                                                |         |
; Write Data to RAM | Write data into internal RAM (DDRAM/CGRAM).    |  43 µs  |
;                   |                                                |         |
;-------------------+------------------------------------------------+---------|
;                   |                                                |         |
; Read Data frm RAM | Read data from internal RAM (DDRAM/CGRAM).     |  43 µs  |
;                   |                                                |         |
;===============================================================================



;-------------------------------------------------------------------------------
;       Initialize the LCD module
;-------------------------------------------------------------------------------
LCD_INIT:
        JSR DELAY1          ; Allow some time for the LCD module to warm up
        JSR DELAY1
        JSR LCD_SET_TWO_LINE_MODE
        JSR DELAY1
        JSR DELAY1
        JSR LCD_SET_DISPLAY_ON
        JSR DELAY1
        JSR DELAY1
        JSR LCD_CLEAR
        JSR DELAY1
        JSR DELAY1

        RTS


;-------------------------------------------------------------------------------
;       Clear Display
;       RS  R/W DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0
;       === === === === === === === === === ===
;        0   0   0   0   0   0   0   0   0   1 
;-------------------------------------------------------------------------------
;
;       Clear all the display data by writing "20H" (space code) to all DDRAM 
;       addresses, and set the DDRAM addresses to "00H" in the AC 
;       (address counter). Return cursor to original status, namely, bring the
;       cursor to the left edge on first line of the display. Make entry mode 
;       increment (I/D = "1")
;
;       Destroys:       Nothing
;-------------------------------------------------------------------------------
LCD_CLEAR:
        PHA                             ; Push A to stack
        LDA     #%00000001
        STA     PA
        JSR     LCD_CLR_RS
        JSR     LCD_TOGGLE_EN
        PLA                             ; Restore A
        RTS

;-------------------------------------------------------------------------------
;       Display ON/OFF
;       RS  R/W DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0
;       === === === === === === === === === ===
;        0   0   0   0   0   0   1   D   C   B 
;-------------------------------------------------------------------------------
;       Control display/cursor/blink ON/OFF 1-bit register.
;       D : Display ON/OFF control bit
;               When D = “1”, entire display is turned on.
;               When D = “0”, display is turned off, but display data remains in
;               DDRAM.
;       C : Cursor ON/OFF control bit
;               When C = “1”, cursor is turned on.
;               When C = “0”, cursor disappears in current display, but I/D 
;               register retains its data.
;       B : Cursor Blink ON/OFF control bit
;               When B = “1”, cursor blink is on, which performs alternately 
;               between all the “1” data and display characters at the cursor 
;               position.
;               When B = “0”, blink is off.
;-------------------------------------------------------------------------------
LCD_SET_DISPLAY_ON:
        LDA     #%00001111
        STA     PA
        JSR     LCD_CLR_RS
        JSR     LCD_TOGGLE_EN
        RTS


;-------------------------------------------------------------------------------
;       Entry Mode Set
;       RS  R/W DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0
;       === === === === === === === === === ===
;        0   0   0   0   0   0   0   1  I/D  SH 
;-------------------------------------------------------------------------------
;
;       Set the moving direction of cursor and display.
;       I/D : Increment / decrement of DDRAM address (cursor or blink)
;               When I/D = “1”, cursor/blink moves to right and DDRAM address is
;               increased by 1.
;               When I/D = “0”, cursor/blink moves to left and DDRAM address is
;               decreased by 1. * CGRAM operates the same as DDRAM, when reading
;               from or writing to CGRAM.
;       SH: Shift of entire display
;               When DDRAM is in read (CGRAM read/write) operation or SH = “0”,
;               shift of entire display is not performed.
;               If SH = “1”and in DDRAM write operation, shift of entire display
;               is performed according to I/D value
;               (I/D = “1”: shift left, I/D = “0”: shift right).
;-------------------------------------------------------------------------------
LCD_ENTRY_MODE_SET:
        PHA                             ; Push A to stack
        LDA     #%00000101
        STA     PA
        JSR     LCD_CLR_RS
        JSR     LCD_TOGGLE_EN
        PLA                             ; Restore A
        RTS



;-------------------------------------------------------------------------------
;       Return Home
;       RS  R/W DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0
;       === === === === === === === === === ===
;        0   0   0   0   0   0   0   0   1   X 
;-------------------------------------------------------------------------------
;
;       Return Home is the cursor return home instruction.  Set DDRAM address 
;       to "00H" in the address counter.  Return cursor to its original site 
;       and return display to its original status, if shifted. 
;       Contents of DDRAM does not change.
;-------------------------------------------------------------------------------
LCD_RETURN_HOME:
        LDA     #%00000010
        STA     PA
        JSR     LCD_CLR_RS
        JSR     LCD_TOGGLE_EN
        RTS


;-------------------------------------------------------------------------------
;       Name:           LCD_TOGGLE_EN
;       Desc:           Toggles PB0 (the LCD EN pin) with a delay in between
;       Destroys:       A
;-------------------------------------------------------------------------------
LCD_TOGGLE_EN:
        PHA                             ; Push A to stack
        JSR     DELAY1

        LDA     PB
        AND     #%11111110
        STA     PB
        JSR     DELAY1

        LDA     PB
        ORA     #%00000001
        STA     PB
        JSR     DELAY1

        LDA     PB
        AND     #%11111110
        STA     PB
        JSR     DELAY1

        PLA                             ; Resore A
        RTS


;-------------------------------------------------------------------------------
;       Write data to RAM
;       RS  R/W DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0
;       === === === === === === === === === ===
;        1   0   D7  D6  D5  D4  D3  D2  D1  D0
;-------------------------------------------------------------------------------
;
;       Write binary 8-bit data to DDRAM/CGRAM.
;       The selection of RAM from DDRAM, and CGRAM, is set by the previous 
;       address set instruction: DDRAM address set, and CGRAM address set. 
;       RAM set instruction can also determine the AC direction to RAM.
;       After write operation, the address is automatically increased/decreased
;       by 1, according to the entry mode.
;-------------------------------------------------------------------------------
LCD_WRITE:
;       Prepare for write...set RS to 1
        PHA                     ; Push A to stack
        JSR     LCD_SET_RS
        JSR     LCD_TOGGLE_EN
        PLA                     ; Restore A
        RTS




;-------------------------------------------------------------------------------
;       Name:           LCD_CLR_RS 
;       Desc:           Clear the RS bit of the LCD module
;       Destroys:       Nothing
;-------------------------------------------------------------------------------
LCD_CLR_RS:
        PHA                             ; Push A to stack
        LDA     PB
        AND     #%11111101
        STA     PB
        PLA                             ; Restore A
        RTS

;-------------------------------------------------------------------------------
;       Name:           LCD_SET_RS
;       Desc:           Set the RS bit of the LCD module
;       Destroys:       Nothing
;-------------------------------------------------------------------------------
LCD_SET_RS:
        PHA                             ; Push A to stack
        LDA     PB
        ORA     #%00000010
        STA     PB
        PLA                             ; Restore A
        RTS


;-------------------------------------------------------------------------------
;       Name:           LCD_SET_TWO_LINE_MODE
;       Desc:           Enable two line mode
;       Destroys:       A
;
;       RS  R/W DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0
;       === === === === === === === === === ===
;        0   0   0   0   1   DL  N   F   x   x
;-------------------------------------------------------------------------------
;
;       DL : Interface data length control bit
;           When DL = “1”, it means 8-bit bus mode with MPU.
;           When DL = “0”, it means 4-bit bus mode with MPU. 
;           So to speak, DL is a signal to select 8-bit or 4-bit bus mode.
;           When 4-bit bus mode, it needs to transfer 4-bit data in two parts.
;       N : Display line number control bit
;           When N = “0”, it means 1-line display mode.
;           When N = “1”, 2-line display mode is set.
;       F : Display font type control bit
;           When F = “0”, 5 ´ 7 dots format display mode
;           When F = “1”, 5 ´ 10 dots format display mode
;-------------------------------------------------------------------------------
LCD_SET_TWO_LINE_MODE:
        PHA                             ; Push A to stack
        LDA     #%00111000
        STA     PA

        JSR     LCD_CLR_RS
        JSR     LCD_TOGGLE_EN

        PLA                             ; Restore A
        RTS


;-------------------------------------------------------------------------------
;       Name:           LCD_SET_DRAM_ADDRESS
;       Desc:           Sets the address of the DRAM for writing.
;                       Set A to the address you want.
;       Destroys:       
;
;       RS  R/W DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0
;       === === === === === === === === === ===
;        0   0   1  AC6 AC5 AC4 AC3 AC2 AC1 AC0
;-------------------------------------------------------------------------------
;
;       Set DDRAM address to AC.
;       This instruction makes DDRAM data available from MPU.
;       When in 1-line display mode (N = 0), DDRAM address is from $00 to $4F.
;       In 2-line display mode (N = 1), DDRAM address in the 1st line is from 
;       $00 to $27, and DDRAM address in the 2nd line is from $40 to $67.
;-------------------------------------------------------------------------------
LCD_SET_DRAM_ADDRESS:
        ORA     #%10000000
        STA     PA
        JSR     LCD_CLR_RS
        JSR     LCD_TOGGLE_EN

        RTS
