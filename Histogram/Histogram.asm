;
; The code given to you here implements the histogram calculation that 
; we developed in class.  In programming lab, we will add code that
; prints a number in hexadecimal to the monitor.
;
; Your assignment for this program is to combine these two pieces of 
; code to print the histogram to the monitor.
;
; If you finish your program, 
;    ** commit a working version to your repository  **
;    ** (and make a note of the repository version)! **


	.ORIG	x3000		; starting address is x3000


;
; Count the occurrences of each letter (A to Z) in an ASCII string 
; terminated by a NUL character.  Lower case and upper case should 
; be counted together, and a count also kept of all non-alphabetic 
; characters (not counting the terminal NUL).
;
; The string starts at x4000.
;
; The resulting histogram (which will NOT be initialized in advance) 
; should be stored starting at x3F00, with the non-alphabetic count 
; at x3F00, and the count for each letter in x3F01 (A) through x3F1A (Z).
;
; table of register use in this part of the code
;    R0 holds a pointer to the histogram (x3F00)
;    R1 holds a pointer to the current position in the string
;       and as the loop count during histogram initialization
;    R2 holds the current character being counted
;       and is also used to point to the histogram entry
;    R3 holds the additive inverse of ASCII '@' (xFFC0)
;    R4 holds the difference between ASCII '@' and 'Z' (xFFE6)
;    R5 holds the difference between ASCII '@' and '`' (xFFE0)
;    R6 is used as a temporary register
;

	LD R0,HIST_ADDR      	; point R0 to the start of the histogram
	
	; fill the histogram with zeroes 
	AND R6,R6,#0		; put a zero into R6
	LD R1,NUM_BINS		; initialize loop count to 27
	ADD R2,R0,#0		; copy start of histogram into R2

	; loop to fill histogram starts here
HFLOOP	STR R6,R2,#0		; write a zero into histogram
	ADD R2,R2,#1		; point to next histogram entry
	ADD R1,R1,#-1		; decrement loop count
	BRp HFLOOP		; continue until loop count reaches zero

	; initialize R1, R3, R4, and R5 from memory
	LD R3,NEG_AT		; set R3 to additive inverse of ASCII '@'
	LD R4,AT_MIN_Z		; set R4 to difference between ASCII '@' and 'Z'
	LD R5,AT_MIN_BQ		; set R5 to difference between ASCII '@' and '`'
	LD R1,STR_START		; point R1 to start of string

	; the counting loop starts here
COUNTLOOP
	LDR R2,R1,#0		; read the next character from the string
	BRz PRINT_HIST		; found the end of the string

	ADD R2,R2,R3		; subtract '@' from the character
	BRp AT_LEAST_A		; branch if > '@', i.e., >= 'A'
NON_ALPHA
	LDR R6,R0,#0		; load the non-alpha count
	ADD R6,R6,#1		; add one to it
	STR R6,R0,#0		; store the new non-alpha count
	BRnzp GET_NEXT		; branch to end of conditional structure
AT_LEAST_A
	ADD R6,R2,R4		; compare with 'Z'
	BRp MORE_THAN_Z         ; branch if > 'Z'

; note that we no longer need the current character
; so we can reuse R2 for the pointer to the correct
; histogram entry for incrementing
ALPHA	ADD R2,R2,R0		; point to correct histogram entry
	LDR R6,R2,#0		; load the count
	ADD R6,R6,#1		; add one to it
	STR R6,R2,#0		; store the new count
	BRnzp GET_NEXT		; branch to end of conditional structure

; subtracting as below yields the original character minus '`'
MORE_THAN_Z
	ADD R2,R2,R5		; subtract '`' - '@' from the character
	BRnz NON_ALPHA		; if <= '`', i.e., < 'a', go increment non-alpha
	ADD R6,R2,R4		; compare with 'z'
	BRnz ALPHA		; if <= 'z', go increment alpha count
	BRnzp NON_ALPHA		; otherwise, go increment non-alpha

GET_NEXT
	ADD R1,R1,#1		; point to next character in string
	BRnzp COUNTLOOP		; go to start of counting loop



PRINT_HIST

; you will need to insert your code to print the histogram here

; do not forget to write a brief description of the approach/algorithm
; for your implementation, list registers used in this part of the code,
; and provide sufficient comments
;    R0 Ascii value to be outputted
;    R1 Counter to print from '@' - 'Z' / Digit Counter in PRINT_4HEX
;    R2 Holds the ascii equivalent to a hexadecimal number
;    R3 Holds the input four digit hexadecimal number to print
;    R4 Pointer to the frequency counter / Bit counter in PRINT_4HEX 
;    R5 Temporary

                LD    R6,NUM_BINS 	; initialize loop count to 27
                LD    R4,HIST_ADDR 	; Loads the pointer to the frequency of a character
LOOP_27         LD    R3,AT    		; Set R3 to the ascii value of the @ character or A-Z
		ADD   R0,R3,#0		; Move R3 into R0
		OUT			; Output ascii character @ or A-Z
		LD    R0,SPACE  	; Set R0 to the ascii value of space
                OUT             	; Output space
		ADD   R1,R3,#1  	; Increment to next ascii value
		ST    R1,AT		; Save R1 in memory so it can be reused in PRINT_4HEX
		AND   R1,R1,#0  	; init digit counter
		LDR   R3,R4,#0		; Load frequency of the letter
		ADD   R4,R4,#1  	; Increment pointer to the frequency
                ST    R4,HIST_INCREMENT ; Save R4 in memory so it can be reused in PRINT_4HEX

PRINT_4HEX      ADD   R5,R1,#-4 	; Loop 4 hex digits
                BRzp  NEXT      	; printed >= 4 digits

                AND   R2,R2,#0  	; init digit
                AND   R4,R4,#0  	; init bit counter
                ADD   R4,R4,#-4 	; Loop four bits in a hex digit
LOOP_FOUR       AND   R4,R4,R4  	; Set condition code
                BRn   MSB       	; got < 4 bits from R3 (true)   

DIGIT_OUT       ADD   R5,R2,#-9 	;
                BRnz  LE_9      	; digit <= 9?
                ADD   R2,R2,#15	 	; Add 'A' - 10 = 65-10 = 55 to R2
                Add   R2,R2,#15 	;   R2 = R2 + 15
                ADD   R2,R2,#15 	;   R2 = R2 + 15
                ADD   R2,R2,#10 	;   R2 = R2 + 10
                BRnzp OUTPUT    	;

LE_9            ADD   R2,R2,#15 	; Add '0' = 48
                ADD   R2,R2,#15 	;   R2 = R2 + 15
                ADD   R2,R2,#15 	;   R2 = R2 + 15
                ADD   R2,R2,#3  	;   R2 = R2 + 3
OUTPUT         	AND   R0,R0,#0  	; Initialize outputted value
                ADD   R0,R2,R0  	; Add ascii value to R0
                OUT             	; Output the ascii digit
                ADD   R1,R1,#1  	; increment digit counter
                BRnzp PRINT_4HEX 	; 

MSB             ADD   R2,R2,R2  	; Shift digit left
                AND   R3,R3,R3  	; Set condition code
                BRzp  POSITIVE  	; R3 >= 0?
                ADD   R2,R2,#1  	; add 1 because negative
POSITIVE        ADD   R3,R3,R3  	; shift R3 left
                ADD   R4,R4,#1  	; increment bit counter
                BRnzp LOOP_FOUR 	;

NEXT		LD    R0,NEWLINE 	; Output new line
		OUT			;
		LD    R4,HIST_INCREMENT ; Restore R4
		ADD   R6,R6,#-1  	; Decrement LOOP_27 counter 
		BRp   LOOP_27		;
DONE	HALT				; done


; the data needed by the program
NUM_BINS	.FILL #27	; 27 loop iterations
NEG_AT		.FILL xFFC0	; the additive inverse of ASCII '@'
AT_MIN_Z	.FILL xFFE6	; the difference between ASCII '@' and 'Z'
AT_MIN_BQ	.FILL xFFE0	; the difference between ASCII '@' and '`'
HIST_ADDR	.FILL x3F00     ; histogram starting address
STR_START	.FILL x4000	; string starting address
AT		.FILL x0040	; @ symbol ascii code
SPACE		.FILL x0020	; ascii for space
NEWLINE		.FILL x000A	; ascii for newline
HIST_INCREMENT	.FILL #0	;
; for testing, you can use the lines below to include the string in this
; program...
;STR_START	.FILL STRING	; string starting address
;STRING		.STRINGZ "This is a test of the counting frequency code.  AbCd...WxYz."
	; the directive below tells the assembler that the program is done
	; (so do not write any code below it!)

	.END
