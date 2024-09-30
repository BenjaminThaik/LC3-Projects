; This program reads in some ASCII characters, and use these characters to print
;   a pixel map of a character according to VGA text mode standard.

; Register functions
; R0 - temporary storage
; R1 - font pointer
; R2 - row counter
; R3 - font data
; R4 - column counter
; R5 - bit mask pointer
; R6 - character counter
; R7 - character pointer

            .ORIG x3000
            GETC 		      ; Get CHAR0
	    ST    R0,CHAR0	      ; Store R0 in CHAR0
            GETC                      ; Get CHAR1
            ST    R0,CHAR1            ; Store R0 in CHAR1
	    AND   R6,R6,#0	      ; Intialize character counter
	    LEA   R2,STRNG            ; R7 <- STRNG location
GETSTRNG    GETC                      ; Get CHARACTER
	    STR   R0,R2,#0	      ; Store R0 at the location of the character pointer
            ADD   R6,R6,#1            ; Increment character counter
            ADD   R2,R2,#1	      ; Increment character pointer
	    ADD   R0,R0,#-10	      ; Determine if read character is an enter
	    BRnp  GETSTRNG
	    ADD   R6,R6,#-1
	    ST    R6,STRLEN	      ; Store String length
        
	    AND   R2,R2,#0            ; Initialize R2
ROWLOOP     LD    R6,STRLEN	      ; R6 <- M[STRLEN]
	    LEA   R7,STRNG	      ; R7 <- STRNG location
CHARLOOP    LD    R0,OFFSET           ; Load OFFSET to R0 (Font Data)
	    LDR	  R1,R7,#0	      ; Load character into R1
	    ADD   R1,R1,R1	      ; Add R1 to itself (4 times)
            ADD   R1,R1,R1 
            ADD   R1,R1,R1 
            ADD   R1,R1,R1 	      ; Added 4 times to multiply by 16
	    ADD   R1,R0,R1	      ; Add offset and to character pointer in table
	    ADD   R1,R1,R2	      ; Add row counter to character pointer
	    LDR   R3,R1,#0	      ; R3 <- M[R1] Font Pixel Data
	    AND   R4,R4,#0	      ; Initialize R4
	    ADD   R4,R4,#8	      ; R4 <- 8
	    LEA   R5,MASK	      ; R5 <- MASK
COLUMNLOOP  LDR   R0,R5,#0            ; R0 <- M[R5] (Bit mask)
	    AND   R0,R0,R3	      ; R0 <- R0 AND R3
	    BRz   OUTPUTCHAR0	      
	    LD    R0,CHAR1	      ; R0 <- M[CHAR1]
	    BRnzp OUTPUT
OUTPUTCHAR0 LD    R0,CHAR0 	      ; R0 <- M[CHAR0]
OUTPUT	    ST    R7,SAVER7	      ; Save R7
	    OUT   		      ; Output Pixel
	    LD    R7,SAVER7	      ; Reload R7	
	    ADD   R5,R5,#1	      ; Increment Mask Pointer
	    ADD	  R4,R4,#-1	      ; Decrement Column Counter
            BRp   COLUMNLOOP
	    ADD   R7,R7,#1	      ; Increment Character Pointer
	    ADD   R6,R6,#-1	      ; Decrement character counter
	    BRnp  CHARLOOP    
            AND   R0,R0,#0	      ; Initialize R0
	    ADD   R0,R0,#10           ; R0 <- Ascii new line
            ST    R7,SAVER7           ; Save R7
 	    OUT                       ; Output New Line
            LD    R7,SAVER7           ; Reload R7       
	    ADD   R1,R1,#1	      ; Increment font row pointer
	    ADD   R2,R2,#1	      ; Increment row counter
            ADD   R0,R2,#-16  	      ; Stop after 16 loops
	    BRn   ROWLOOP             ; Branch to row loop
            HALT

CHAR0      .FILL  x0000               ; The character to print if bit is  0
CHAR1      .FILL  x0000               ; The character to print if bit is 1
CHARACTER  .FILL  x0000	              ; The character whose pixel map to print
OFFSET     .FILL  x4000	              ; Start of font data
MASK	   .FILL  x8000               ; Set first MASK bit
	   .FILL  x4000		      ; Set second MASK bit
           .FILL  x2000               ; Set third MASK bit
           .FILL  x1000               ; Set fourth MASK bit
           .FILL  x0800               ; Set fifth MASK bit
           .FILL  x0400               ; Set six MASK bit
           .FILL  x0200               ; Set seventh MASK bit
           .FILL  x0100               ; Set eight MASK bit
STRNG      .BLKW  x0010		      ; Allocate space for up to 16 characters
STRLEN	   .FILL  x0000		      ; The length of the string
SAVER7	   .FILL  x0000		      ; Temporary place to hold R7
.END
