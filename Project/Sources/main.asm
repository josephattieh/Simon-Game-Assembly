

;*****************************************************************
;* This stationery serves as the framework for a                 *
;* user application (single file, absolute assembly application) *
;* For a more comprehensive program that                         *
;* demonstrates the more advanced functionality of this          *
;* processor, please see the demonstration applications          *
;* located in the examples subdirectory of the                   *
;* Freescale CodeWarrior for the HC12 Program directory          *
;*****************************************************************
; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point
 
; Include derivative-specific definitions
            INCLUDE 'derivative.inc'
ROMStart    EQU  $4000  ; absolute address to place my code/constant data
; variable/data section
            ORG RAMStart
; Insert here your data definition.
MESSAGE1   DC.B 'SIMON GAME '
LENGTH1    DC.B 11
POSITION1  DC.B 0
OFFSET1    DC.B 0
COUNTER1   DC.B 11
MESSAGE2   DC.B 'Pick the level of difficulty '
LENGTH2    DC.B 29
POSITION2  DC.B 0
OFFSET2    DC.B 0
COUNTER2   DC.B 0
DATA       DC.B 0
LEVEL      DC.B 0
CDOWN      DC.B 3
VOFFSET    DC.B 0
BUZZ       DC.W 150
SEQUENCE   DC.B 0
; code section
            ORG   ROMStart
Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer
            CLI                     ; enable interrupts
mainLoop:
            
 
 
            MOVB #$52,SPI0CR1               ;configuring the SPI control register 1
            MOVB #$10,SPI0CR2               ;configuring the SPI control register 2
            MOVB #$00, SPI0BR               ;configuring SPI baud rate register
            MOVB #$38,DDRM                  ;configuring the port M of Data Direction Register (as output)
            BSET MODRR, #$10                ;setting bit 4 of the Module Routing Register to enable rerouting
            
            MOVB #$F0,DDRB                  ;setting LEDs as output and Push Buttons as input
            MOVB #$00,PORTB                 ;turning off the colored LED lights 
            
            MOVB #$0, SCI0BDH               ;configuring the SCI Baud Rate registers   
            MOVB #$0D, SCI0BDL              ; (these configurations are explained in the report)
            MOVB #0, SCI0CR1                ;configuring the SCI control register 1
            MOVB #$0C,SCI0CR2               ;configuring the SCI control register 2 (with disabled interrupts)
            
            MOVB #$47,MCCTL                 ;configuring the modulus down counter reegister (with disabled interrupts)
            MOVW  #$FFFF, MCCNT             ;loading the modulus down counter count register with its maximum value
                                            ; (in order to generate random value in the RANDOM subroutine)
           
            MOVB #$01,DDRT					;setting the buzzer as output (since the buzzer is connected to port13 which
            								; corresponds to PT0)
            
            JSR DELAY                       ;jumping to delay subroutine
            
            LDAA #%00110011                 ;initializing the LCD with the following instructions
            JSR SENDINSTR
            LDAA #%00110010
            JSR SENDINSTR
            LDAA #%00101000
            JSR SENDINSTR
            LDAA #%00001000
            JSR SENDINSTR
            LDAA #%00000001
            JSR SENDINSTR
            LDAA #%00000110
            JSR SENDINSTR
            
            LDAA #$0C                       ;turning off the cursor and its blinking
            JSR SENDINSTR                   ;sending this instruction to the LCD
           
Task1SG
            MOVB #11,LENGTH1                ;moving the length of the string in memory location MESSAGE1 ('SIMON GAME ')
                                            ; to memory location LENGTH1
            CLR POSITION1                   ;clearing content of POSITION1
            CLR OFFSET1                     ;clearing the content of OFFSET1
            MOVB #11, COUNTER1              ;moving the length of the content of MESSAGE1 to memory location COUNTER1 (in order to scroll right)
             
            MOVB #29, LENGTH2               ;moving the length of the string in memory location MESSAGE2 ('Pick the level of difficulty ')
                                            ; to memory location LENGTH2
            CLR POSITION2                   ;clearing content of POSITION2
            CLR OFFSET2                     ;clearing the content of OFFSET2
            CLR COUNTER2                    ;clearing the content of COUNTER2 (in order to scroll to the left) 
                         
            LDAA #$80                       ;forcing the cursor of the LCD to the beginning of the first line
            JSR SENDINSTR                   ;sending the instruction to the LCD
            LDX #MESSAGE1                   ;loading the address of the first character of MESSAGE1 (pointer) in register X
            
PrintSG     LDAB OFFSET1                    ;loading the offset(content of memory location OFFSET1) in register B  
            LDAA B,X                        ;loading register A with 8 bits using the address located in X and the offset located in B
            JSR SENDDATA                    ;sending the data to the LCD
            INCB                            ;incrementing the contents of register B (containing the offset)
            CMPB LENGTH1                    ;comparing the incremented offset (located in register B) with the length of the message to be printed
            BNE  SkipSG                     ;branching to SkipSG if the offset is not equal to the length of the message
            CLRB                            ;clearing register B (offset) if offset is equal to the length of the message 
SkipSG      STAB OFFSET1                    ;storing the content of register B in memory location OFFSET1
            INC POSITION1                   ;incrementing the content of memory location POSITION1
            LDAB POSITION1                  ;loading register B with the content of memory location POSITION1
           
            CMPB #8                         ;comparing the content of register B (POSITION1) with 8 since a line in the LCD holds 8 characters
            BNE PrintSG                     ;branching back to PrintSG if the content of POSITION1 is not yet equal to 8 
            LDAA #$80                       ;forcing the cursor to go to the beginning of the first line if the content of POSITION1 is equal to 8
            JSR SENDINSTR                   ;sending the instruction to the LCD
            CLR POSITION1                   ;clearing the content of memory location POSITION1
            DEC COUNTER1                    ;decrementing the content of memory location COUNTER1 (in order to scroll to the right)
            LDAB COUNTER1                   ;loading register B with the decremented content of memory COUNTER1
            
            LDAA #$A8                       ;forcing the cursor to go the begining of the second line of the LCD 
            JSR SENDINSTR                   ;sending the instruction to the LCD
            LDAA #' '                       ;priting 'Welcome' in the middle of the second line of the LCD
            JSR SENDDATA
            LDAA #'W'
            JSR SENDDATA
            LDAA #'e'
            JSR SENDDATA
            LDAA #'l'
            JSR SENDDATA
            LDAA #'c'
            JSR SENDDATA
            LDAA #'o'
            JSR SENDDATA
            LDAA #'m'
            JSR SENDDATA
            LDAA #'e'
            JSR SENDDATA
            LDAA #$80                       ;forcing the cursor to go back to the beginning of the first line of the LCD
            JSR SENDINSTR                   ;sending the instruction to the LCD
           
            STAB OFFSET1                    ;storing the content of register B (COUNTER1) in memory location OFFSET1 (placing counter in offset)
            CMPB #5                         ;comparing the content of register B (counter) with 5 
            BNE PrintSG                     ;branching back to PrintSG if counter is not equal to 5
                     
                                              
            LDAA #$01                       ;clearing the display  when registerB (counter) is equal to 5 (since the whole message is scrolled)
            JSR SENDINSTR                   ;sending the instruction to the LCD  
            
 
Task1PL     
            
            LDAA #$80                       ;forcing the cursor to go the beginning of the first line of the LCD
            JSR SENDINSTR                   ;sending the instruction to the LCD
            LDX #MESSAGE2                   ;loading the address of the first character of MESSAGE2 (pointer) in register X 
           
PrintPL     LDAB OFFSET2                    ;loading the offset(content of memory location OFFSET2) in register B   
            LDAA B,X                        ;loading register A with 8bits using the address located in X and the offset located in B
            JSR SENDDATA                    ;sending the data to the LCD
           
            INCB                            ;incrementing the content of register B (containing the offset)
            CMPB LENGTH2                    ;comparing the incremented offset (register B) with the length of the message to be printed
            BNE  SKIPPL1                    ;branching to SKIPPL if the offset is not equal to the length of the message
            CLRB                            ;clearing register B (offset) if offset is equal to the length of the message
SKIPPL1     STAB OFFSET2                    ;storing the content of register B in memory location OFFSET2
            INC POSITION2                   ;incrementing the content of memory location POSITION2
            LDAB POSITION2                  ;loading register B with the content of memory location POSITION2
            
            CMPB #8                         ;comparing the content of register B (position) with 8 since a line in the LCD holds 8 characters
            BNE PrintPL                     ;branching to PrintPL if the content of POSITION2 is not yet equal to 8
            CLR POSITION2                   ;clearing the content of memory location POSITION2
            INC COUNTER2                    ;incrementing the content of memory location COUNTER2 (in order to scroll to the left)
            LDAB COUNTER2                   ;loading content of register B with the incremented content of memory location COUNTER2
            CMPB LENGTH2                    ;comparing content of register B(counter) with the length of the message to be printed 
            BNE SKIPPL2                     ;branching to SKIPPL2 if the counter is not equal to the length of the message yet
            CLR COUNTER2                    ;clearing the counter if the counter is equal to the length of the message
SKIPPL2     MOVB COUNTER2, OFFSET2          ;moving content of memory location COUNTER2 to  memory location OFFSET2
                                            ; (placing counter in offset)     
            LDAA PORTB                      ;loading the content of register A with the bits in PORTB
            BITA #1                         ;testing the first bit of registerA (PORTB) by performing an AND operation of the content of registerA
                                            ; and %00000001 
            BEQ EASY                        ;branching to EASY if the first bit is equal to 0 (which means that PB1 is pushed) 
            BITA #2                         ;testing the second bit of registerA (PORTB) by performing an AND operation of the content of registerA
                                            ; and %00000010 
            BEQ MEDIUM                      ;branching to MEDIUM if the second bit is equal to 0 (which means that PB2 is pushed) 
            BITA #4                         ;testing the third bit of registerA (PORTB) by performing an AND operation of the content of registerA
                                            ; and %00000100 
            BEQ HARD                        ;branching to HARD if the third bit is equal to 0 (which means that PB3 is pushed) 
            JMP Task1PL                     ;otherwise jumping to Task1PL (--> printing again pick the level of the difficulty)
            
EASY       
            LDAB #5                         ;loading the content of register B with the value 5
            STAB LEVEL                      ;storing the value of register B in memory location LEVEL (-->content of LEVEL is 5)
            LDAA #$01                       ;clearing the display of the LCD
            JSR SENDINSTR                   ;sending the instruction to the LCD
            LDAA #' '                       ;printing 'EASY' in the middle of the first line of the display of the LCD
            JSR SENDDATA
            LDAA #' '
            JSR SENDDATA
            LDAA #'E'
            JSR SENDDATA
            LDAA #'A'
            JSR SENDDATA
            LDAA #'S'
            JSR SENDDATA
            LDAA #'Y'
            JSR SENDDATA  
            JMP COUNTDOWN                   ;jumping to COUNTDOWN in order to display a countdown from 3 to 1 on the LCD
         
MEDIUM     
            LDAB #10                        ;loading the content of register B with the value 10
            STAB LEVEL                      ;storing the value of register B in memory location LEVEL (-->content of LEVEL is 10)
            LDAA #$01                       ;clearing the display of the LCD
            JSR SENDINSTR                   ;sending the instruction to the LCD
            LDAA #' '                       ;printing 'MEDIUM' in the middle of the first line of the display of the LCD
            JSR SENDDATA
            LDAA #'M'
            JSR SENDDATA
            LDAA #'E'
            JSR SENDDATA
            LDAA #'D'
            JSR SENDDATA
            LDAA #'I'
            JSR SENDDATA
            LDAA #'U'
            JSR SENDDATA
            LDAA #'M'
            JSR SENDDATA
            JMP COUNTDOWN                   ;jumping to COUNTDOWN in order to display a countdown from 3 to 1 on the LCD
HARD       
            LDAB #15                        ;loading the content of register B with the value 15
            STAB LEVEL                      ;storing the value of register B in memory location LEVEL (-->content of LEVEL is 15)
            LDAA #$01                       ;clearing the display of the LCD
            JSR SENDINSTR                   ;sending the instruction to the LCD
            LDAA #' '                       ;printing 'HARD' in the middle of the first line of the display of the LCD
            JSR SENDDATA
            LDAA #' '
            JSR SENDDATA
            LDAA #'H'
            JSR SENDDATA
            LDAA #'A'
            JSR SENDDATA
            LDAA #'R'
            JSR SENDDATA
            LDAA #'D'
            JSR SENDDATA
            
COUNTDOWN  
            
                                            
RepeatCNT   LDAA #$A8                       ;forcing the cursor to go to the beginning of the second line of the LCD
            JSR SENDINSTR                   ;sending the instructionn to the LCD
            JSR DELAYCNT                    ;jumping to the subroutine DELAYCNT 
            LDAA #' '                       ;printing empty charcters in order for the numbers of the countdown to appear in the middle of LCD
            JSR SENDDATA    
            LDAA #' '         
            JSR SENDDATA     
            LDAA #' '        
            JSR SENDDATA     
            JSR DELAYCNT                    ;jumping to the subroutine DELAYCNT 
            LDAA CDOWN                      ;loading the content of register A with the content of memory location CDOWN that is initially 3
            ADDA #48                        ;adding 48 to register A in order to send the ASCII representation of the number to the LCD
            JSR SENDDATA                    ;sending data to the LCD
            
            DEC CDOWN                       ;decrementing the content of memory location CDOWN
            LDAA CDOWN                      ;loading the content of register A with the decremented content of memory location CDOWN 
            BNE RepeatCNT                   ;branching back to RepeatCNT if the value in CDOWN is not 0 yet
            MOVB #3, CDOWN                  ;moving back #3 to the content of memory location CDOWN in case we want to re-use the memory location 
                                            ; CDOWN again 
            
GAME       
            
REPEAT     
            
            JSR RANDOM                      ;jumping to subroutine RANDOM in order to generate a random value between 1 and 4 inclusive
            LDX #SEQUENCE                   ;loading the address of the first character of SEQUENCE (pointer) in register X
            LDAA VOFFSET                    ;loading register A with the value of memory location VOFFSET
            STAB A,X                        ;storing the content of register B (random value generated by the subroutine RANDOM) to the memory address  
            								;that is equal to the address in X with an offset located in A
            INC VOFFSET                     ;incrementing the content of memory location VOFFSET
            LDAA  VOFFSET                   ;loading the content of regsiter A with the value of the memory location VOFFSET
            CMPA LEVEL                      ;comparing value in register A (offset) with the value in LEVEL 
            BNE REPEAT                      ;branching back to REPEAT if the offset is not equal to the content of LEVEL yet
            CLR VOFFSET                     ;clearing the content of VOFFSET when the offset is equal to the content of LEVEL 
                                            ; in order to reuse VOFFSET later on
           
            JSR LEDS                        ;jumping to subroutine LEDS in order to light the LEDs based on the random sequence of numbers generated
PUTTY       
 
            BRCLR SCI0SR1, $20, PUTTY       ;keep checking bit 5 (Receive Data Register Full Flag) of SCI status register 1; while this bit is 0
                                            ; we keep branching to PUTTY, when it becomes 1, the value entered by the user is now available in 
                                            ; SCI data registers then we continue with the sequence of code  
            LDX #SEQUENCE                   ;loading the address of the first character of SEQUENCE (pointer) in register X
            LDAB VOFFSET                    ;loading register B with the value of memory location VOFFSET
            LDAA B,X                        ;loading register A with 8 bits using the address located in X and the offset located in B
            ADDA #48                        ;adding 48 to the contents of register A in order to compare it with the ASCII representation of the numbers 
            								;entered by the user
            INC VOFFSET                     ;incrementing the value of the VOFFSET
            CMPA SCI0DRL                    ;comparing the value of register A (value of a number of the random sequence that light the LEDs) with the 
                                            ;value in the SCI data register SCI0DRL (value entered by the user) 
            LBNE FALSE                      ;branching to FALSE if the values do not match
            LDAB SCI0SR1                    ;reading the SCI status register 1 
            LDAB SCI0DRL                    ;reading the SCI data register low 
            								;reading those registers was done to clear the flags of the SCI status register 1
            LDAB LEVEL                      ;loading  register B with the content of memory location LEVEL 
            CMPB VOFFSET                    ;comparing the content of register B(level) with the content of memory location VOFFSET
            BEQ TRUE                        ;branching if equal (if the user enterred all the sequence correctly) to TRUE
               
           
            JMP PUTTY                        ;otherwise jumping to PUTTY

TRUE
            JSR BUZZWIN                     ;jumping to subroutine BUZZWIN which will produce a buzzer sound for winner
            LDAA #$01                       ;clearing the display
            JSR SENDINSTR                   ;sending the instruction to the LCD
            LDAA #'C'                       ;sending to the LCD 'Correct'
            JSR SENDDATA
            LDAA #'o'
            JSR SENDDATA
            LDAA #'r'
            JSR SENDDATA
            LDAA #'r'
            JSR SENDDATA
            LDAA #'e'
            JSR SENDDATA
            LDAA #'c'
            JSR SENDDATA
            LDAA #'t'
            JSR SENDDATA
            JSR DELAYOTHER                  ;jumping to subroutine DELAYANOTHER
            INC LEVEL                       ;incrementing the content of memory location LEVEL (since when the user wins, we should increment
                                            ; the length of the sequence)
            LDAA #$01                       ;clearing the display again 
            JSR SENDINSTR                   ;sending the instruction to the LCD
            LDAA #'B'                       ;sending to the LCD 'BE READY'
            JSR SENDDATA
            LDAA #'E'
            JSR SENDDATA
            LDAA #' '
            JSR SENDDATA
            LDAA #'R'
            JSR SENDDATA
            LDAA #'E'
            JSR SENDDATA
            LDAA #'A'
            JSR SENDDATA
            LDAA #'D'
            JSR SENDDATA
            LDAA #'Y'
            JSR SENDDATA
            JSR DELAYOTHER                  ;jumping to subroutine DELAYANOTHER
            CLR VOFFSET                     ;clearing the content of memory location VOFFSET
            LDAB SCI0SR1                    ;reading the SCI status register 
            LDAB SCI0DRL                    ;reading the SCI data register low                       
            JMP GAME                        ;jumping to GAME 
           
            
            
                                         
FALSE 
            JSR BUZZLOSE                   ;jumping to subroutine BUZZLOSE which will produce a buzzer sound for loser
            LDAA #$01                       ;clearing the display again 
            JSR SENDINSTR                   ;sending the instruction to the LCD
            LDAA #'Y'                       ;sending 'You lost' to the LCD
            JSR SENDDATA
            LDAA #'o'
            JSR SENDDATA
            LDAA #'u'
            JSR SENDDATA
            LDAA #' '
            JSR SENDDATA
            LDAA #'L'
            JSR SENDDATA
            LDAA #'o'
            JSR SENDDATA
            LDAA #'s'
            JSR SENDDATA
            LDAA #'t'
            JSR SENDDATA
            JSR DELAYOTHER                  ;jumping to subroutine DELAYANOTHER
            JSR DELAYOTHER                  ;jumping to subroutine DELAYANOTHER
            LDAB SCI0SR1                    ;reading the SCI status register 1 
            JSR DELAY                       ;jumping to subroutine DELAY
            LDAB SCI0DRL                    ;reading the SCI data register low 
            JSR DELAY                       ;jumping to subroutine DELAY
            JMP Task1SG                     ;jumping back to Task1SG (game reapeat from the beginning when you loose)
 
LEDS     
           
            PSHD                            ;pushing register D on the stack
            PSHX                            ;pushing register X on the stack
            LDX #SEQUENCE                   ;loading the address of the first character of SEQUENCE (pointer) in register X
            CLR VOFFSET                     ;clearing the content of VOFFSET
RepeatThis  LDAB VOFFSET                    ;loading the content of memory loction VOFFSET in regsiter B
            CMPB LEVEL                      ;comparing the content of regsiter B (offset) with the value in memory LEVEL (which contains
                                            ; the length of the random sequence) 
            BEQ OUT                         ;branching to OUT if the offset is equal to the content of LEVEL 
           
            JSR DELAYOTHER                  ;jumping to subroutine DELAYOTHER
            JSR DELAYOTHER                  ;jumping to subroutine DELAYOTHER
             
             
            LDAA B,X                        ;loading register A with 8 bits using the address located in X and the offset located in B
            CMPA #1                         ;comparing the value of register A with 1
            BEQ L1                          ;branching to L1 if value of register A is equal to 1 (in order to light LED1)
            CMPA #2                         ;comparing the value of register A with 2
            BEQ L2                          ;branching to L2 if value of register A is equal to 2 (in order to light LED2)
            CMPA #3                         ;comparing the value of register A with 3
            BEQ L3                          ;branching to L3 if value of register A is equal to 3 (in order to light LED3)
            CMPA #4                         ;comparing the value of register A with 4
            BEQ L4                          ;branching to L4 if value of register A is equal to 4 (in order to light LED4)
            JMP OUT                         ;otherwise jumping to OUT
           
L1          MOVB #%00011111,PORTB           ;lighting the first colored lED only by sending a 1 to bit4 of PORTB     (colored LEDs of bonus)
            INC VOFFSET                     ;incrementing the value in memory location VOFFSET
            JSR DELAYOTHER                  ;jumping to subroutine DELAYOTHER
            MOVB #$00, PORTB                ;turning the coloured LEDs off 
            JMP RepeatThis                  ;jumping back to RepeatThis
                       
L2          MOVB #%00101111,PORTB           ;lighting the second colored lED only by sending a 1 to bit5 of PORTB    (colored LEDs of bonus)
            INC VOFFSET                     ;incrementing the value in memory location VOFFSET
            JSR DELAYOTHER                  ;jumping to subroutine DELAYOTHER
            MOVB #$00, PORTB                ;turning the coloured LEDs off 
            JMP RepeatThis                  ;jumping back to RepeatThis
        
L3          MOVB #%01001111,PORTB           ;lighting the third colored lED only by sending a 1 to bit6 of PORTB    (colored LEDs of bonus)
            INC VOFFSET                     ;incrementing the value in memory location VOFFSET
            JSR DELAYOTHER                  ;jumping to subroutine DELAYOTHER
            MOVB #$00, PORTB                ;turning the coloured LEDs off 
            JMP RepeatThis                  ;jumping back to RepeatThis
           
L4          MOVB #%10001111,PORTB           ;lighting the fourth colored lED only by sending a 1 to bit7 of PORTB    (colored LEDs of bonus)
            INC VOFFSET                     ;incrementing the value in memory location VOFFSET
            JSR DELAYOTHER                  ;jumping to subroutine DELAYOTHER
            MOVB #$00, PORTB                ;turning the coloured LEDs off 
            JMP RepeatThis                  ;jumping back to RepeatThis
OUT
            MOVB #$00, PORTB                ;turning the colored LEDs off 
            CLR VOFFSET                     ;clearing the value of memory VOFFSET
            PULX                            ;pulling the register X out of the stack
            PULD                            ;pulling the register D out of the stack
            RTS
            
            
            
RANDOM                                       
            PSHX                            ;pushing register X on stack
            PSHA                            ;pushing register A on stack
                                            ;(we don't push regsiter B because we want to use its content outside the subroutine)
            JSR DELAYCUST                   ;jumping to subroutine DELAYCUST that uses a variable length delay
            LDD MCCNT                       ;loading register D with the value of the modulus down counter count register configured in the 
                                            ; beginning of the code
            LDX #4                          ;loading register X with the value 4
            IDIV                            ;performing division of the value in D by the value in X and it will save the remainder in 
                                            ; register D (thus register B since the remainder is small)
            ADDB #1                         ;adding 1 to register B since the remainder of the previous operation is between 0 and 3, then 
                                            ; 1 is added in order for the value to be between 1 and 4 inclusive
          
            PULA                            ;pulling register A out of the stack
            PULX                            ;pulling register X out of the stack
            RTS                             ;returning from the subroutine                         

BUZZWIN 
            PSHX                            ;pushing register X on the stack
            PSHY                            ;pushing regsiter Y on the stack
REPW
            MOVB #$01,PTT                   ;setting PT0 to 1
            JSR DELAYW                      ;jumping to subroutine DELAYW
            MOVB #$00,PTT                   ;clearing PT0
            JSR DELAYW                      ;jumping to subroutine DELAYW
            DEC BUZZ                        ;decrementing the content of memory location BUZZ 
            BNE REPW                        ;branching back to REPW as long as the content of BUZZ is not 0
            MOVW #150,BUZZ                  ;storing back 150 into memory location BUZZ so we can use BUZZ later
            JSR DELAYW                      ;jumping to subroutine DELAYW
            PULY                            ;pulling register Y out of the stack 
            PULX                            ;pulling register X out of the stack
            RTS                             ;returning from subroutine
 

BUZZLOSE 
            PSHX                            ;pushing register X on the stack
            PSHY                            ;pushing regsiter Y on the stack     
REPL
            MOVB #$01,PTT                   ;setting PT0 to 1
            JSR DELAYW                      ;jumping to subroutine DELAYW
            JSR DELAYW                      ;jumping to subroutine DELAYW
            MOVB #$00,PTT                   ;clearing PT0
            JSR DELAYW                      ;jumping to subroutine DELAYW
            JSR DELAYW                      ;jumping to subroutine DELAYW
            DEC BUZZ                        ;decrementing the content of memory location BUZZ 
            BNE REPL                        ;branching back to REPL as long as the content of BUZZ not 0
            MOVW #150,BUZZ                  ;storing back 150 into memory location BUZZ so we can use BUZZ later
            JSR DELAYW                      ;jumping to subroutine DELAYW
            PULY                            ;pulling register Y out of the stack 
            PULX                            ;pulling register X out of the stack
            RTS                             ;returning from subroutine                



DELAYW
            PSHX                            ;pushing register X on the stack
            LDX #$1E0                       ; we chose this value since the sound that the buzzer generates using
            								; this value is nice
            DBNE X, *					    ;keep decrementing the value in register X  until it become 0
            PULX                            ;pulling register X out of the stack                         
            RTS             
DELAY
            PSHX                            ;pushing register X on the stack
            LDX #8032						; we chose this value since it permits us to show 'SIMON GAME ' for 3seconds
            DBNE X, *					    ;keep decrementing the value in register X  until it become 0
            PULX                            ;pulling register X out of the stack
            RTS
            
            
DELAYCUST
            PSHX                            ;pushing register X on the stack
            LDX MCCNT						;loading the value of the MCCNT in register X ( to create a delay that give
            								; us a different value each time we enter it)
            DBNE X, *					    ;keep decrementing the value in register X  until it become 0						;
            PULX                            ;pulling register X out of the stack
            RTS

DELAYCNT    PSHX                            ;pushing register X on the stack
            LDX #$FFFF					    ;creating a big delay
            DBNE X, *					    ;keep decrementing the value in register X  until it become 0
            PULX                            ;pulling register X out of the stack
            RTS
 
DELAYOTHER  
            PSHX                            ;pushing register X on the stack
            PSHY                            ;pushing register Y on the stack
            							    ;creating a big delay
            LDX #$FFFF
DEL1        LDY #$01  
            DBNE Y, *
            DBNE X, DEL1
            
            PULY                            ;pulling register Y out of the stack
            PULX                            ;pulling register X out of the stack
            RTS  



SENDINSTR
			PSHD
            TAB                ;transfer the content of register A to register B to keep a copy of the data
            RORA               ;shift the content of register A 4 times to the right in order to replace  
            RORA               ;the highest 4 bits with the lower ones
            RORA
            RORA
            ANDA #%00001111    ;clearing the first 4 bits (data bits who are shifted) in order to send 
                               ;only the highest 4 bits of the original value of register A
                               ;(LCD is a 4 bit interface)   
                               
            ORAA #%10000000    ;setting the enable (bit7) to 1 without affecting the R/S (bit 6) that is already 0 
                               ;since it is an instruction
                               
            JSR SPI            ;jumping to SPI subroutine in order to send the content of register A to LCD
            
            ANDA #%01111111    ;clearing the enable bit (bit 7)
                               ;  we are changing the enable in order to simulate a virtual clock 
                               
            JSR SPI            ;jumping to SPI subroutine in order to send the content of register A to LCD
            
            JSR DELAY          ;jumping to subroutine DELAY 
            
            
            TBA                ;copying back the original content of A which was transfered earlier to register B
            
            ANDA #%00001111    ;clearing the highest 4 bits in order to send the lower 4 bits
            
            ORAA #%10000000    ;setting the enable (bits 7) to 1
            
            JSR SPI            ;jumping to SPI subroutine in order to send the content of register A to LCD
            
            ANDA #%00001111    ;clearing the enable (bit 7) in order to create a virtual clock
            
            JSR SPI            ;jumping to SPI subroutine in order to send the content of register A to LCD
            
            JSR DELAY          ;jumping to subroutine DELAY
            PULD
            RTS                ;returning from subroutine
            
            
SENDDATA	
			PSHD
            TAB                ;transfer the content of register A to register B to keep a copy of data
            RORA               ;shift the content of register A 4 times to the right in order to replace  
            RORA               ;the highest 4 bits with the lower ones
            RORA
            RORA
            ANDA #%00001111    ;clearing the first 4 bits (data bits who are shifted) in order to send 
                               ;fisrt only the highest 4 bits of the original value of register A
                               ;(LCD is a 4 bit interface) 
                               
            ORAA #%11000000    ;setting the enable (bit7) to 1 and R/S (bit 6) to 1 since it is data 
                                
            JSR SPI            ;jumping to SPI subroutine in order to send the content of register A to LCD 
            
            ANDA #%01111111    ;clearing the enable (bit7) in order to simulate a virtual clock
            
            JSR SPI            ;jumping to SPI subroutine in order to send the content of register A to LCD 

            JSR DELAY          ;jumping to subroutine DELAY
            
            
            TBA                ;copying back the original content of A which was transfered in register B
            
            ANDA #%00001111    ;clearing the highest 4 bits in order to send the lower 4 data bits

            ORAA #%11000000    ;setting the enable (bit7) to 1 and R/S (bit 6) to 1 since it is data 

            JSR SPI            ;jumping to SPI subroutine in order to send the content of register A to LCD 
           
            ANDA #%01111111    ;clearing the enable (bit7) in order to simulate a virtual clock
          
            JSR SPI            ;jumping to SPI subroutine in order to send the content of register A to LCD 
            
            JSR DELAY          ;jumping to subroutine DELAY
            PULD
            RTS                ;returning from subroutine
          
             
            
           
            
SPI         PSHA 
            STAA SPI0DR              ;storing the content of register A (assuming data is in register A)
                                     ;to the SPI data register
            
            BRCLR SPI0SR,#%00100000,*;checking for bit 5(SPTEF responsible to check if the transfer
                                     ;of data was successful) and waiting for him to be set to 1 to move 
                                     ;to the following instruction
                                     
            MOVB SPI0DR,DATA         ;reading the content of SPI data register and moving it to memory 
                                     ;location DATA in order to clear the data register
                                     
            MOVB SPI0SR,DATA         ;reading the content of SPI state register and moving it to memory 
                                     ;location labeled DATA in order to clear the state register
            PULA
            RTS  


                      
Ending         
 
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
           
