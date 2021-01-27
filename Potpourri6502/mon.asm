;*******************************************************************************
;      ||===\\   __   ====== ||===\\   __   ||  || ||===\\ ||===\\ ======
;      ||   ||  /  \    ||   ||   ||  /  \  ||  || ||   || ||   ||   ||  
;      ||===// / -- \   ||   ||===// / -- \ ||  || ||===// ||===//   ||  
;      ||      | || |   ||   ||      | || | ||  || ||  \\  ||  \\    ||  
;      ||      \ -- /   ||   ||      \ -- / ||__|| ||   \\ ||   \\   ||  
;      ||       \__/    ||   ||       \__/  \\__// ||   || ||   || ======
;                                              ___   ======  ____   ___
;                                             // \\  ||     /    \ // \\
;                                             || __  \\__   | /\ |    ||
;                                             ||/  \     \\ | || |   //
;                                             || ()| \\__// | \/ |  ||
;                                              \\__/        \____/  =====
;===============================================================================
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;                               Potpourri6502 SBC 
;                                  by Cecil Meeks
;
;                            http://potpourri6502.com
;
;               Design based off 6502 "Primer" computer by Garth Wilson
;               http://wilsonminesco.com/6502primer/potpourri.html
;               
;               Assembler / Linker of choice:
;
;               Assembler
;               https://cc65.github.io/doc/ca65.html
;
;               Linker
;               https://cc65.github.io/doc/ld65.html
;
;
;-------------------------------------------------------------------------------
;
;               RAM:    0000-3FFF (using half of a 62256 32Kx8 SRAM = 16K)
;               I/O:    4000-7FFF (on-board 6522 VIA is at $6000-$600F)
;               ROM:    8000-FFFF (using all 32KB of EPROM or EEPROM)
;
;-------------------------------------------------------------------------------
;===============================================================================
;*******************************************************************************

        .debuginfo  +
        .setcpu     "65C02"

.include "acia.asm"
;.include "EhBASIC.asm"
;.include "keyboard.asm"
;.include "lcd.asm"
;.include "pckybd.asm"
.include "via.asm"
;.include "utils.asm"


; Remove these segments when implementing the actual code
;.segment "SERIAL"
.segment "BASIC"
.segment "LCD"
.segment "KEYBDRVER"
.segment "KEYBOARD"
.segment "UTILS"

ESC     =   $1B		; Escape character
CR      =   $0D     ; Return character
LF      =   $0A     ; Line feed character

MSGL	=	$2C		; Message pointers
MSGH    = 	$2D

;-------------------------------------------------------------------------------
;		Zero Page Locations
;-------------------------------------------------------------------------------
CHAR_IN_vec	=	$40




;-------------------------------------------------------------------------------
;       Main RESET Vector (ROM Startup)
;-------------------------------------------------------------------------------
.segment "CODE"
.org $8000

NMI_vec:
IRQ_vec:
RES_vec:
        JSR INITS
		JSR WELCOME


;-------------------------------------------------------------------------------
;       MAIN Loop
;-------------------------------------------------------------------------------
MAIN:
		JSR ACIA_READ
		JSR PARSE_CMD

        JMP MAIN


;-------------------------------------------------------------------------------
;       System Initialization
;-------------------------------------------------------------------------------
INITS:
        CLD                 		; Clear decimal arithmetic mode.
        CLI                 		; Clear interrupts
		JSR	VIA_INIT				; Initialize onboard VIA
		JSR ACIA_INIT				; Initialize ACIA

        RTS



PARSE_CMD:
		CMP #'H'
		BEQ @H_CMD

		CMP #'R'
		BEQ @R_CMD

		JSR ACIA_ECHO

@EXIT:
		JMP MAIN

@H_CMD:
		JSR PRINT_HELP
		JMP MAIN
@R_CMD:
		JSR INITS
		JSR MSG_Welcome
		JMP MAIN


;-------------------------------------------------------------------------------
;       System Messages
;-------------------------------------------------------------------------------
WELCOME:
		LDA #<MSG_Welcome
		STA MSGL
		LDA #>MSG_Welcome
		STA MSGH
		JSR SHWMSG
		RTS

PRINT_HELP:
		LDA #<MSG_Help
		STA MSGL
		LDA #>MSG_Help
		STA MSGH
		JSR SHWMSG
		RTS


SHWMSG:
		LDY #$00
@PRINT:
		LDA (MSGL), Y
		BEQ @DONE
		JSR ACIA_ECHO
		INY
		BNE @PRINT
@DONE:
		RTS





MSG_Welcome:
	.byte CR, LF, "Welcome to Potpourri6502"
	.byte CR, LF, "[L]oad update"
	.byte CR, LF, "[H]elp"
	.byte CR, LF
	.byte $00

MSG_Help:
	.byte CR, LF, "** Help **"
	.byte CR, LF, "This is currently a test to see if things work."
	.byte CR, LF
	.byte $00



MSG_Load_Update:
	.byte CR, LF
	.byte CR, LF, "Waiting for update..."
	.byte $00




;-------------------------------------------------------------------------------
;       Startup Vectors
;-------------------------------------------------------------------------------
.segment "VECTORS"
	.word NMI_vec           ; NMI Vector
	.word RES_vec           ; RESET Vector
	.word IRQ_vec           ; IRQ Vector


;-------------------------------------------------------------------------------
;       EOF
;-------------------------------------------------------------------------------