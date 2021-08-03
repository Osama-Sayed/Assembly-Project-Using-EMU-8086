CODE	SEGMENT
ASSUME	CS:CODE,DS:CODE,ES:CODE,SS:CODE	
command	equ	00h
stat	equ     02h
data	equ	04h
key		equ	01h
org 1000h

;--------Your code here------- 
 call Lcd_init  ; initiate LCD 
  mov si,offset str 
 l1:
 mov al,[si]
 cmp al,00
 je start 
 out data,al
 call busy   
 inc si
 jmp l1   ; display first line
 
 start:
 call line_two  ;move to second line 
    call scan   ;take number
    cmp al,16h  ;compere number if (
    jz bracket1 ;if true go to bracket1 
    
    jmp start   ;if not back to start
    
 number: 
 call scan      ;take number
 cmp al,15h     ;check if , 
 jz comma       ;go to comma lable
 cmp al,17h     ;else if )
 jz bracket2    ;go to bracket2 lable
 cmp al,16h     ;else if (
 jz number      ;back to scan new number 
 add al,30h     
 out data,al  
 mov bl,al      ;take last value and save it in bl
 
     jmp number  
     
     
 bracket1:
     mov al,'('    
     mov bl,'('    ;save last value in bl
     out data,al 
     jmp number 
     
 bracket2:
     cmp bl,'('
     jz number       ;compare if close bracket after open bracket 
     cmp bl,','      ;compare if close bracket after comma
     jz number       ;else print 
     cmp bh,','      ;compare if bh flag is one
     jnz number
     mov al,')'
     out data,al
 
 comma: 
     cmp bl,'('
     jz number
     cmp bh,','
     jz number
     mov bh,','
     mov bl,','
     mov al,','
     out data,al 
     jmp number
hlt
;-----------------------------

;-----------------------------------------------------  
;Scan PROC
;Scans a kit button from the user into al
;Inputs:   None
;Outputs:  Al - scanned char code
;-----------------------------------------------------	
scan:   IN AL,key					;read from keypad register
        TEST AL,10000000b			;test status flag of keypad register
        JNZ Scan
        AND al,00011111b			;mask the valid bits for code
        OUT key,AL					;get the keypad ready to read another key
        ret
        
;-----------------------------------------------------  
;Busy PROC
;Makes the CPU wait till the kit is ready to take a command
;Inputs:   None
;Outputs:  None
;-----------------------------------------------------		
busy:   IN AL,Stat
        test AL,10000000b
        jnz busy
        ret
        
;-----------------------------------------------------  
;Lcd_init PROC
;LCD screen initialization which makes the screen ready as a one line input with a ;cursor. You can call this method again if you want to clear the LCD screen
;Inputs:   None
;Outputs:  None
;-----------------------------------------------------	
Lcd_init:	
        push ax
        call busy      	    ;Check if KIT is busy
		mov al,38h          ;8-bits mode, one line & 5x7 dots
		out command,al      ;Execute the command above.
		call busy           ;Check if KIT is busy
		mov al,0fh          ;Turn the display and cursor ON, and set cursor to blink
		out command,al      ;Execute the command above.
		call busy           ;Check if KIT is busy
		mov al,06h          ;cursor is to be moved to right
		out command,al      ;Execute the command above.
		call busy           ;Check if KIT is busy
		mov al,02           ;Return cursor to home
		out command,al      ;Execute the command above.
		call busy           ;Check if KIT is busy
		mov al,01           ;Clear the display
		out command,al      ;Execute the command above.
		call busy           ;Check if KIT is busy
		pop ax
		ret
Line_two:
push ax
call busy
mov al,11000000b
out command,al
call busy
pop ax
ret		




;-----------Vars--------------
str db "Enter The Points: ",0
;-----------------------------


CODE	ENDS
END