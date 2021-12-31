#include <xc.inc>

global	Print_OM,Print_ST,Write_delay,two_digit_number_display,Initialise_numbers,Print_EM,Set_EM_counter,Clear_EM, Alphabet_display
    
extrn	LCD_Setup, LCD_Write_Message,Set_Second_line,Display_clear,timer_counter,LCD_Send_Byte_D,timer_counter,counter,index,Delay_one_second,LCD_Send_Byte_I,LCD_delay_x4us,EM_counter,LCD_delay_ms
	
psect	udata_acs   ; reserve data space in access ram
counter_1:	ds 1    ; reserve one byte for a counter variable
counter_2:	ds 1
counter_stl:	ds  1
space_counter:	ds  1

    
psect	udata_bank7 ; reserve data anywhere in RAM (here at 0x400)
OM_array:    ds 17 ; reserve 128 bytes for message data

OM_array2: ds 13
    
psect	data    
	; ******* myTable, data in programme memory, and its length *****
OM_Table:
	db	'B','r','a','i','l','l','e',' ','T','e','a','c','h','i','n','g',0x0a
					; message, plus carriage return
	OM_Table_1   EQU    17		; length of data
	align	2

OM_Table2:
	db	' ',' ',' ',' ',' ',' ','D','e','v','i','c','e',0x0a
	
	OM_Table_2  EQU	 13
	align	2
	
psect	udata_bank3
    
ST_array:   ds	14
    
psect	data

ST_Table:
	db	'D','e','l','a','y',' ','S','e','t',':','(','s',')',0x0a
	
	ST_Table_1 EQU	    14
	align	2
	
psect	udata_bank7 ; reserve data anywhere in RAM (here at 0x400)

myArray_number:   ds	11

psect	data

number_array:    ;need to load these in at the start of the programme in the intialisation stage
    
    db '0','1','2','3','4','5','6','7','8','9',' ',0x0a	
    number_array_1 EQU 11
    align 2
    
psect	udata_bank7 ; reserve data anywhere in RAM (here at 0x400)

EM_array:   ds	12

psect	data

EM_Table:    ;need to load these in at the start of the programme in the intialisation stage
    
    db 'E','n','t','e','r',' ','W','o','r','d',':',0x0a	
    EM_Table_1 EQU 12
    align 2
    
psect	LCD_mesages_code, class=CODE

Print_OM:
	;call	Display_clear
	call	Display_1
	call	Set_Second_line
	call	Display_2
	
	
	return
	
Print_ST:
	call	Display_ST1
	;call	Set_Second_line
	;call	Display_ST2
	return
	
Print_EM:
	call	Display_EM
	movlw	200
	call	LCD_delay_ms
	return
Display_1: 	
	lfsr	0, OM_array	; Load FSR0 with address in RAM	
	movlw	low highword(OM_Table)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(OM_Table)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(OM_Table)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	OM_Table_1	; bytes to read
	movwf 	counter_1, A		; our counter register
loop_1: 	
	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter_1, A		; count down to zero
	bra	loop_1		; keep going until finished
	
	movlw	OM_Table_1	; output message to LCD
	addlw	0xff		; don't send the final carriage return to LCD
	lfsr	2, OM_array
	call	LCD_Write_Message
	return
		
Display_2: 	
	lfsr	0, OM_array2	; Load FSR0 with address in RAM	
	movlw	low highword(OM_Table2)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(OM_Table2)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(OM_Table2)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	OM_Table_2	; bytes to read
	movwf 	counter_2, A		; our counter register
loop_2: 	
	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter_2, A		; count down to zero
	bra	loop_2		; keep going until finished
	
	movlw	OM_Table_2	; output message to LCD
	addlw	0xff		; don't send the final carriage return to LCD
	lfsr	2, OM_array2
	call	LCD_Write_Message
	return

Display_ST1: 	
	lfsr	0, ST_array	; Load FSR0 with address in RAM	
	movlw	low highword(ST_Table)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(ST_Table)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(ST_Table)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	ST_Table_1	; bytes to read
	movwf 	counter_stl, A		; our counter register
loop_ST1: 	
	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter_stl, A		; count down to zero
	bra	loop_ST1		; keep going until finished
	
	movlw	ST_Table_1	; output message to LCD
	addlw	0xff		; don't send the final carriage return to LCD
	lfsr	2, ST_array
	call	LCD_Write_Message
	
	return
	
Write_delay:
	;clear whatever was in line 2
	movf	timer_counter
	call	LCD_Send_Byte_D
	return
	
Initialise_numbers:
	
	lfsr	1,myArray_number
	movlw	low highword(number_array)
	movwf	TBLPTRU, A
	movlw	high(number_array)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(number_array)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	number_array_1	; bytes to read
	;addlw	1
	movwf	counter,A
	bra	loop_numbers
	
loop_numbers: 	
	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC1; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	loop_numbers		; keep going until finished
    
	return
	
two_digit_number_display:
	
	call	Clear_Second_Line
    
	movlw	30
	cpfslt	index
	bra	Case_30
	
	movlw	20
	cpfslt	index
	bra	Case_20
	
	movlw	10
	cpfslt	index
	bra	Case_10
	
	bra	Case_0
	return 
	
Case_30:
    movlw   3
    call    number_display
    
    movlw   30		    ;move 30 to W
    subwf   index,0	    ;subtract sub_carry from index (i.e. index - 30), stores value in W
    call    number_display
    return
Case_20:
    movlw   2
    call    number_display
    
    movlw   20		    ;move 30 to W
    subwf   index,0	    ;subtract sub_carry from index (i.e. index - 30), stores value in W
    call    number_display
    return
Case_10:
    movlw   1
    call    number_display
    
    movlw   10		    ;move 30 to W
    subwf   index,0	    ;subtract sub_carry from index (i.e. index - 30), stores value in W
    call    number_display
    return
Case_0:
    movf    index,W
    call    number_display
    return

number_display:	
    lfsr    2, myArray_number
    ;put it in W repositry before calling
    movf    PLUSW2,W
    call    LCD_Send_Byte_D
    return
    
Clear_Second_Line:
    movlw   3
    movwf   space_counter
    call    Set_Second_line
    
Clear_loop:	;prints 3 spaces
    lfsr    2,myArray_number
    movlw   10
    movf    PLUSW2,W
    call    LCD_Send_Byte_D
    decfsz  space_counter		
    bra	    Clear_loop
    
    call    Set_Second_line
    movlw   20		
    call    LCD_delay_x4us			;needs a delay so it doesn't read and write too quickly
    return
    
Display_EM: 	
	lfsr	2, EM_array	; Load FSR0 with address in RAM	
	movlw	low highword(EM_Table)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(EM_Table)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(EM_Table)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	EM_Table_1	; bytes to read
	movwf 	counter_1, A		; our counter register
loop_EM: 	
	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC2; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter_1, A		; count down to zero
	bra	loop_EM		; keep going until finished
	
	movlw	EM_Table_1	; output message to LCD
	addlw	0xff		; don't send the final carriage return to LCD
	lfsr	2, EM_array
	call	LCD_Write_Message
	return
	
Set_EM_counter:
	movlw	1
	movwf	EM_counter
	return
	
Clear_EM:
	movlw	1
	cpfslt	EM_counter
	call	LCD_Setup
	movlw	0
	movwf	EM_counter
	return

Alphabet_display:	;takes the index and converts it into a letter, places in final_alphabet

    lfsr    2, myArray_alphabet
    movf    index,W		    ;POSTINC2
    movff   PLUSW2,final_alphabet
    movf    final_alphabet,W
    call    LCD_Send_Byte_D
    return