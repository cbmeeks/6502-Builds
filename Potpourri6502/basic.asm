;*******************************************************************************
;                       ||=\\   ____   ----- ======   __
;                       ||  || //  \\ //       ||   //  \\
;                       ||__// ||  || \\___    ||   ||
;                       ||  \\ ||  ||     \\   ||   ||
;                       ||  || ||==||     //   ||   ||
;                       ||=//  ||  || -----  ====== \\__//
;===============================================================================
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;       Setup EhBASIC
;       Desc:   Note, this isn't really my code.  Cannot remember where I found
;               this setup code.  From what I understand, it is performing:
;
;               1) Grab the first word of LAB_vec which is the LOCATION of
;                  ACIAin.
;
;               2) Store the location of ACIAin into the EhBASIC vector of
;                  VEC_IN.  So when EhBASIC needs to read a char, it
;                  JMP (VEC_IN) = JMP ACIAin. This is labeled V_INPT in EhBASIC
;
;               3) Y has a count of labels in the vectors for EhBASIC.
;                  Those labels are ACIAin, ACIAout, LOAD, SAVE.
;                  So Y = 3 (4-1).
;                  Each iteration of Y stores the word location of the vectors.
;                  Which in EhBASIC is V_INPT, V_OUTP, V_LOAD, V_SAVE.
;                  So long story short, after LAB_stlp is finished, all four
;                  of the vectors EhBASIC uses is pointing to our local methods.
;                  Note, as of 2019-02-06, LOAD and SAVE have not been 
;                  implemented.
;
;               4) LAB_signon - Display the initial message and memory question.
;                  Remember, at this point, EhBASIC knows how to communicate
;                  serially.  So now, we just iterate through the strings.
;
;               5) LAB_nokey - Here we are waiting for input (via ACIA).
;                  Here we sit in a loop waiting for V_INPT (which pionts
;                  to our ACIAin) to register a key press (ACIA send char).
;                  Once that is done, we then compare to 'W' or 'C'.
;                  Then we have a simple branch within EhBASIC based on the
;                  answer.  W = Warm Start and C = Cold Start.
;                  TODO - Explain the difference between warm/cold starts.
;
;               6) At this point, EhBASIC is running and working directly
;                  with the I/O system.  Which, again, is an ACIA here.
;
;       TODO    Move to basic.asm - EhBASIC might not be the only BASIC I use
;-------------------------------------------------------------------------------
	LDY	#END_CODE - LAB_vec		; set index/count
LAB_stlp:
	LDA	LAB_vec - 1, Y			; get byte from interrupt code
	STA	VEC_IN - 1, Y			; save to RAM
	DEY							; decrement index/count
	BNE	LAB_stlp				; loop if more to do

LAB_signon:
	LDA	LAB_mess, Y				; get byte from sign on message
	BEQ	LAB_nokey				; exit loop if done

	JSR	V_OUTP		    		; output character
	INY							; increment index
	BNE	LAB_signon				; loop, branch always

LAB_nokey:
	JSR	V_INPT		    		; call scan input device
	BCC	LAB_nokey				; loop if no key
	AND	#$DF					; mask xx0x xxxx, ensure upper case

	CMP	#'W'					; compare with [W]arm start
	BEQ	LAB_dowarm				; branch if [W]arm start

	CMP	#'C'					; compare with [C]old start
	BEQ	LAB_docold	    		; branch if [C]old start

	CMP #'E'					; compare with [E]xit
	BEQ GO_MAIN					; branch to main loop (return to DOS)

	CMP #'R'					; compare with [R]eset
	BEQ LAB_vec					; branch to reset vector

	JMP LAB_nokey				; invalid key.  TODO: play beep?

LAB_docold:
	JMP	LAB_COLD				; do EhBASIC cold start

LAB_dowarm:
	JMP	LAB_WARM				; do EhBASIC warm start

GO_MAIN:
	JMP MAIN					; jump to main loop - TODO: display message...


;-------------------------------------------------------------------------------
;       ACIA Input/Output Routines
;       These two methods have their locations copied in the EhBASIC vectors.
;       Assumes data to work with is already in A.
;
;       Note:  While these methods work directly with the ACIA, they are really
;              functions of EhBASIC and should not be moved to acia.asm.
;              Instead, they should call the ACIA I/O routines.  In fact, a 
;              better way would be to call a "IO Vector" so that instead of 
;              "hard coding" an ACIA, it could be rerouted to LCD, video, etc.
;       TODO - utilize jump vectors for I/O
;-------------------------------------------------------------------------------
ACIAout:
        CMP #LF                     ; Ignore line feed character
        BEQ IgnoreLF
WaitForReady:      
		BIT	ACIA_DATA
		BMI WaitForReady
        JSR ACIA_ECHO
IgnoreLF:
		RTS

ACIAin:
        JSR ACIA_READ
        BEQ LAB_nobyw
        AND	#$7F					; clear high bit
        SEC							; flag byte received
		RTS

LAB_nobyw
		CLC							; flag no byte received
        RTS

;-------------------------------------------------------------------------------
;       EhBASIC Load/Save Routines
;       These are not implemented at this point.
;       These would be used to load/save EhBASIC code to disk, serial, whatever.
;-------------------------------------------------------------------------------
LOAD:
SAVE:
        RTS




;-------------------------------------------------------------------------------
;       EhBASIC Vectors
;-------------------------------------------------------------------------------
LAB_vec:
	.word	ACIAin		; byte in from ACIA
	.word	ACIAout		; byte out to ACIA
	.word	LOAD		; load vector for EhBASIC
	.word	SAVE		; save vector for EhBASIC
END_CODE:




;-------------------------------------------------------------------------------
;       MESSAGES
;-------------------------------------------------------------------------------
LAB_mess:
	.byte CR, LF, "Welcome to 6502 EhBASIC."
	.byte CR, LF, "Please select startup option, [R] to reset or [E] to exit."
	.byte CR, LF, " [C]old Start"
	.byte CR, LF, " [W]arm Start"
	.byte CR, LF, " [R]eset"
	.byte CR, LF, " [E]xit", $00

