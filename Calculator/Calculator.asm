; This project creates a calculator with the functions: addition, subtraction, multiplication, division, and power.
; The user inputs the equation in postfix format an the output is printe in hexadecimal format.
; Addition adds R3 to R4 and stores the answer in R0
; Subtraction subtracts R3 from R4 and stores the answer in R0
; Multiplication loops addition for R3 number of times and the answer is stored in R0
; Division loops subtraction for R4 times and stores a truncated quotient in R0
; Exponent loops multiplication for R3 number of times and stores the answer in R0

.ORIG x3000
; R0 Stores the solution to the equation
; R1 Stores negative of R0
; R2 Register to test for conditionals 
; R3 Stores first inputted value
; R4 Stores second inputted value
; R5 Temporary register
; R7 Stores return position
	
;your code goes here
MAIN
        GETC                    ; Store inputted character in R0
	JSR EVALUATE		;
	ADD R2,R5,#-1		;
	BRnp MAIN		; Read next input
        ADD R5,R0,#0            ; Store result in R5
	HALT			;





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;R0 - value to print in hexadecimal
PRINT_HEX
                ST    R0,PRINT_SaveR0 ;
		ADD   R3,R0,#0	; Load result into R3
                AND   R1,R1,#0  ; init digit counter

START           ADD   R5,R1,#-4 ;
                BRzp  DONE_PRINT ; printed >= 4 digits

                AND   R2,R2,#0  ; init digit
                AND   R4,R4,#0  ; init bit counter
                ADD   R4,R4,#-4 ; Loop four times
LOOP_FOUR       AND   R4,R4,R4  ;
                BRn   MSB       ; got < 4 bits from R3 (true)   

DIGIT_OUT       ADD   R5,R2,#-9 ;
                BRnz  LE_9      ; digit <= 9?
                ADD   R2,R2,#15 ; Add 'A' - 10 = 65-10 = 55 to R2
                Add   R2,R2,#15 ;   R2 = R2 + 15
                Add   R2,R2,#15 ;   R2 = R2 + 15
                Add   R2,R2,#10 ;   R2 = R2 + 10
                BRnzp OUTPUT    ;

LE_9            ADD   R2,R2,#15 ; Add '0' = 48
                ADD   R2,R2,#15 ;   R2 = R2 + 15
                ADD   R2,R2,#15 ;   R2 = R2 + 15
                ADD   R2,R2,#3  ;   R2 = R2 + 3
OUTPUT          AND   R0,R0,#0  ; Initialize outputted value
                ADD   R0,R2,R0  ; Add ascii value to R0
                OUT             ; Output the ascii digit
                ADD   R1,R1,#1  ; increment digit counter
                BRnzp START     ;

MSB             ADD   R2,R2,R2  ; Shift digit left
                AND   R3,R3,R3  ;
                BRzp  POSITIVE  ; R3 >= 0?
                ADD   R2,R2,#1  ; add 1 because negative
POSITIVE        ADD   R3,R3,R3  ; shift R3 left
                ADD   R4,R4,#1  ; increment bit counter
                BRnzp LOOP_FOUR ;
DONE_PRINT      AND R5,R5,#0	;
		ADD R5,R5,#1	; set status to indicate done
		LD R0,PRINT_SaveR0 ;
		LD R7,MAIN_POS	;
		RET		;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;R0 - character input from keyboard
;R1 - Negative value of R0 / Holds operator
;R2 - Ascii code for comparison
;R6 - current numerical output
;
;
EVALUATE

;your code goes here
        ST R7,MAIN_POS          ; Store current address to MAIN_POS
	OUT			; Echo inputted character
	NOT R1,R0		; -R0 -> R0
	ADD R1,R1,#1		;
	LD R2,EQUALS		; '=' -> R2
	ADD R2,R2,R1		; 
	BRz IS_EQUAL		; Check if inputted character is an '='
	LD R2,SPACE		; ' ' -> R2
	ADD R2,R2,R1		;
	BRz DONE		;
	LD R2,ZERO		; '0' -> R0
	ADD R2,R2,R1		;
	BRp IS_NOT_OPERAND	; Check if inputted character is < '0'
	LD R2,NINE		;
	ADD R2,R2,R1		;
	BRzp IS_OPERAND		;

IS_NOT_OPERAND
	LD R2,OP_ADD		; '+' -> R2
	ADD R2,R2,R1		;
	BRz IS_OPERATOR		; Check if inputted character is a '+'		
	LD R2,OP_SUB		; '-' -> R2
        ADD R2,R2,R1            ; 
        BRz IS_OPERATOR         ; Check if inputted character is a '-'
        LD R2,OP_MULT           ; '*' -> R2
        ADD R2,R2,R1            ; 
        BRz IS_OPERATOR         ; Check if inputted character is a '*'
        LD R2,OP_DIV            ; '/' -> R2
        ADD R2,R2,R1            ; 
        BRz IS_OPERATOR         ; Check if inputted character is a '/'
        LD R2,OP_POW            ; '^' -> R2
        ADD R2,R2,R1            ; 
        BRz IS_OPERATOR         ; Check if inputted character is a '^'

PRINT_INVALID
	LEA R0,STR_INVALID	;
	PUTS			; Output invalid message
	LD R7,MAIN_POS		; Restore restore position to main
	AND R5,R5,#0		;
	ADD R5,R5,#1		; Set status to done
	RET			;

IS_OPERAND			
	LD R2,ZERO		; '0' -> R2
	NOT R2,R2		; -R2 -> R2
	ADD R2,R2,#1		;
	ADD R0,R0,R2		; Convert ascii to hexadecimal
	JSR PUSH		; Push operand to stack
	BRnzp DONE		;

IS_OPERATOR
	JSR POP			; Pop first operand from stack
	AND R5,R5,R5		;
	BRp PRINT_INVALID	; Check if underflow
	ADD R3,R0,#0		; Set first operand
	JSR POP			; Pop second operand from stack
	AND R5,R5,R5            ;
        BRp PRINT_INVALID       ; Check if underflow
        ADD R4,R0,#0            ; Set second operand

        LD R2,OP_ADD            ; '+' -> R2
        ADD R2,R2,R1            ;
        BRnp NOT_PLUS		;
	JSR PLUS 	        ; Jump to add subroutine if inputted character is a '+'          
NOT_PLUS
        LD R2,OP_SUB   	        ; '-' -> R2
        ADD R2,R2,R1            ; 
        BRnp NOT_MIN		;
	JSR MIN		        ; Jump to minus subroutine if inputted character is a '-'
NOT_MIN
        LD R2,OP_MULT           ; '*' -> R2
        ADD R2,R2,R1            ; 
        BRnp NOT_MUL		;
	JSR MUL		        ; Jump to multiply subroutine if inputted character is a '*'
NOT_MUL
        LD R2,OP_DIV            ; '/' -> R2
        ADD R2,R2,R1            ; 
        BRnp NOT_DIV		;
	JSR DIV		        ; Jump to divide subroutine if inputted character is a '/'
NOT_DIV
        LD R2,OP_POW            ; '^' -> R2
        ADD R2,R2,R1            ;
	BRnp NOT_EXP		; 
        JSR EXP		        ; Jump to exponent subroutine if inputted character is a '^'
NOT_EXP				
	JSR PUSH		; PUSH result
	BRnzp DONE		;

IS_EQUAL
        ST R3, POP_SaveR3       ; save R3
        ST R4, POP_SaveR4       ; save R3
        LD R3, STACK_START      ; Load stack start address into R3
        LD R4, STACK_TOP        ; Load stack top address into R4
        ADD R4,R4,#1            ; Add 1 to address to help check if there is one item in stack
        NOT R3,R3               ; -R3 -> R3
        ADD R3,R3,#1            ;
        ADD R4,R4,R3		; R4 - R3 -> R4
	BRnp PRINT_INVALID      ; Check if there is one item in stack
        JSR POP                 ; Pop final result
	JSR PRINT_HEX		; Print result in hexadecimal
        AND R5,R5,#0		;
	ADD R5,R5,#1		; Change status to done
	LD R7,MAIN_POS		; Restore return position to main
	RET			;

DONE    AND R5,R5,#0            ; Change status to continue
        LD R7,MAIN_POS          ; Restore return position to main
        RET                     ; Return to main

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
PLUS	
;your code goes here
	ADD R0,R3,R4		; R3 + R4 -> R0	
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
MIN	
;your code goes here
	NOT R3,R3		; -R4 -> R4
	ADD R3,R3,#1		;
	ADD R0,R4,R3		; R4 - R3 -> R0
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
MUL	
;your code goes here
        ST R2,MUL_SaveR2	; Determine if positive or negative multiplication
	ST R7,MUL_POS		; Save return pointer 
	ST R5,MUL_SaveR5        ; Save R5
	AND R3,R3,R3		;
	BRnp NOT_ZERO		;
	AND R0,R0,#0		;
	BRnzp MUL_DONE		;
NOT_ZERO
	ADD R5,R3,#0		; Store number of additions to R5
	BRp MUL_POSITIVE	; 
	ADD R2,R2,#1		; Multiplier is negative
	NOT R5,R5		; -R5 -> R5
	ADD R5,R5,#1		;
MUL_POSITIVE
	ADD R3,R4,#0		; Store R3 in R4
	ADD R5,R5,#-1		;
        BRz MUL_DONE            ; Finish loop if R5 is zero

MUL_LOOP  
	JSR PLUS		; Add to R3 for R4 times
	ADD R3,R0,#0		; Move solution of R3 + R4 to R3
	ADD R5,R5,#-1		; Decrement multiplication counter
	BRp MUL_LOOP		; Continue looping until R5 is positive
        ADD R0,R3,#0            ; Store output in R0
	AND R2,R2,R2		;
	BRz MUL_DONE		; Check if R2 is negative multiply 
	NOT R0,R0		; -R0 -> R0
	ADD R0,R0,#1		;
MUL_DONE
	LD R2,MUL_SaveR2	; Restore R2
	LD R5,MUL_SaveR5	; Restore R5
	LD R7,MUL_POS		; Restore return pointer
	RET			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
DIV	
;your code goes here
;your code goes here
        ST R7,DIV_POS           ; Save return pointer 
        ST R1,DIV_SaveR1	; Save R1
	ST R6,DIV_SaveR6	; Save R6
        AND R0,R0,#0            ; Initialize subtraction counter
        AND R1,R1,#0            ; Initialize remainder
        NOT R3,R3               ; Make R4 negative
        ADD R3,R3,#1            ;
NEXT_DIV
        ADD R6,R4,#0            ; Save fraction
        ADD R4,R4,R3            ; R3 - R4 -> R3
        BRn REMAINDER           ;
        ADD R0,R0,#1            ; Increment quotient
        BRnzp NEXT_DIV          ; Return to next subtraction
REMAINDER
        ADD R3,R6,#0            ; Restore fraction
        ADD R1,R4,#0            ; Set remainder

	LD R1,DIV_SaveR1	; Restore R1
	LD R6,DIV_SaveR6	; Restore R6
	LD R7,DIV_POS		; Restore return address
	RET


	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
EXP
;your code goes here
        
	ST R7,EXP_POS           ; Save return pointer 
        ST R5,EXP_SaveR5        ; Save R5
        ADD R5,R3,#0            ; Store number of additions to R5
	BRp EXP_NZERO		; Check if exponent is 0
	AND R0,R0,#0		;
	ADD R0,R0,#1		; EXP = 1 if to the 0 power
	BRnzp EXP_DONE		;
EXP_NZERO
        ADD R3,R4,#0            ; Store R3 in R4
        ADD R5,R5,#-1           ;
	BRp EXP_LOOP		; Check if exponent = 1 then Exp = R3
	ADD R0,R3,#0		; R3 -> R0
	BRnzp EXP_DONE		; Branch to done
EXP_LOOP
        JSR MUL                 ; Add to R3 for R4 times
        ADD R3,R0,#0            ; Move solution of R3 + R4 to R3
        ADD R5,R5,#-1           ; Decrement multiplication counter
        BRp EXP_LOOP            ; Continue loop if R4 isn't zero
        ADD R0,R3,#0            ; Store output in R0
EXP_DONE        
	LD R5, EXP_SaveR5       ; Restore R5
        LD R7,EXP_POS           ; Restore return pointer
        RET

;IN:R0, OUT:R5 (0-success, 1-fail/overflow)
;R3: STACK_END R4: STACK_TOP
;
PUSH	
	ST R3, PUSH_SaveR3	;save R3
	ST R4, PUSH_SaveR4	;save R4
	AND R5, R5, #0		;
	LD R3, STACK_END	;
	LD R4, STACk_TOP	;
	ADD R3, R3, #-1		;
	NOT R3, R3		;
	ADD R3, R3, #1		;
	ADD R3, R3, R4		;
	BRz OVERFLOW		;stack is full
	STR R0, R4, #0		;no overflow, store value in the stack
	ADD R4, R4, #-1		;move top of the stack
	ST R4, STACK_TOP	;store top of stack pointer
	BRnzp DONE_PUSH		;
OVERFLOW
	ADD R5, R5, #1		;
DONE_PUSH
	LD R3, PUSH_SaveR3	;
	LD R4, PUSH_SaveR4	;
	RET			;


PUSH_SaveR3	.BLKW #1	;
PUSH_SaveR4	.BLKW #1	;


;OUT: R0, OUT R5 (0-success, 1-fail/underflow)
;R3 STACK_START R4 STACK_TOP
;
POP	
	ST R3, POP_SaveR3	;save R3
	ST R4, POP_SaveR4	;save R3
	AND R5, R5, #0		;clear R5
	LD R3, STACK_START	;
	LD R4, STACK_TOP	;
	NOT R3, R3		;
	ADD R3, R3, #1		;
	ADD R3, R3, R4		;
	BRz UNDERFLOW		;
	ADD R4, R4, #1		;
	LDR R0, R4, #0		;
	ST R4, STACK_TOP	;
	BRnzp DONE_POP		;
UNDERFLOW
	ADD R5, R5, #1		;
DONE_POP
	LD R3, POP_SaveR3	;
	LD R4, POP_SaveR4	;
	RET


POP_SaveR3	.BLKW #1	;
POP_SaveR4	.BLKW #1	;
MUL_SaveR2	.BLKW #1	;
MUL_SaveR5	.BLKW #1	;
DIV_SaveR1      .BLKW #1        ;
DIV_SaveR6      .BLKW #1        ;
EXP_SaveR5	.BLKW #1	;
PRINT_SaveR0	.BLKW #1	;
MAIN_POS	.BLKW #1	;
EVALUATE_POS	.BLKW #1	;
MUL_POS		.BLKW #1	;
DIV_POS		.BLKW #1	;
EXP_POS		.BLKW #1	;
SAVE_POW	.BLKW #1	;
STACK_END	.FILL x3FF0	;
STACK_START	.FILL x4000	;
STACK_TOP	.FILL x4000	;
EQUALS		.FILL x003D	;
SPACE		.FILL x0020	;
ZERO		.FILL x0030	;
NINE		.FILL x0039	;
OP_ADD		.FILL x002B	;
OP_SUB		.FILL x002D	;
OP_MULT		.FILL x002A	;
OP_DIV		.FILL x002F	;
OP_POW		.FILL x005E	;
STR_INVALID	.STRINGZ "Invalid Expression"
.END
