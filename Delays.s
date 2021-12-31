#include <xc.inc>
    
global        Delay_in_seconds, Delay_one_second, Delay_between_keypresses, Delay_between_braille_display ;also letters 1-17    
extrn    LCD_delay_ms, timer_counter_temp
       
    
    
Delay_in_seconds:
    movwf timer_counter_temp,A
dlp2:    
    call Delay_one_second
    decfsz timer_counter_temp, A
    bra dlp2
    return
   
Delay_one_second:
; literal stored in w for no. seconds
    movlw	250
    call	LCD_delay_ms
    call	LCD_delay_ms
    call	LCD_delay_ms
    call	LCD_delay_ms
    return

Delay_between_keypresses:
    movlw	250
    call	LCD_delay_ms
    ;call	LCD_delay_ms
    return

Delay_between_braille_display:
    movlw 250     ; LCD delay ms has a limit!!!!!!!!!!!!!
    call LCD_delay_ms; external subroutines
    call LCD_delay_ms; external subroutines dont uncomment this- too many delays
    return
    


