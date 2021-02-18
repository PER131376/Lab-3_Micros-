; Archivo: main.s
; Dispositivo: PIC16F887
; Autor: Selvin Peralta 
; Compilador: pic-as (v2.30), MPLABX v5.40
;
; Programa: Contador Hexadecimal y Contador con Timer0
; Hardware: LEDS en el puerto B
;
; Creado: 16 feb, 2021
; Última modificación:
    
PROCESSOR 16F887
#include <xc.inc>

; configuración word1
 CONFIG FOSC=INTRC_NOCLKOUT //Oscilador interno sin salidas
 CONFIG WDTE=OFF	    //WDT disabled (reinicio repetitivo del pic)
 CONFIG PWRTE=ON            // PWRT enabled (espera de 72ms al iniciar)
 CONFIG MCLRE=OFF           // el pin de MCLR se utiliza como I/O
 CONFIG CP=OFF              // Sin protección de código
 CONFIG CPD=OFF             // Sin protección de datos
 
 CONFIG BOREN=OFF  // Sin reinicio cuándo el voltaje de alimentación baja de 4v 
 CONFIG IESO=OFF   // Reinicio sin cambio de reloj de interno a externo 
 CONFIG FCMEN=OFF  // Cambio de reloj externo a interno en caso de fallo 
 CONFIG LVP=ON     // Programación en bajo voltaje permitida
 
;configuración word2
  CONFIG WRT=OFF	//Protección de autoescritura 
  CONFIG BOR4V=BOR40V	//Reinicio abajo de 4V 

;------------------------------
    ;PSECT udata_bank0 ;common memory
    ;cont:	DS  2 ;1 byte apartado
    ;cont_big:	DS  1;1 byte apartado
  
  PSECT resVect, class=CODE, abs, delta=2
  ;----------------------vector reset------------------------
  ORG 00h	;posición 000h para el reset
  resetVec:
    PAGESEL main
    goto main
  
  PSECT code, delta=2, abs
  ORG 100h	;Posición para el código
  ;---------------configuración------------------------------
  main: 
    bsf	    STATUS, 5   ;banco  11
    bsf	    STATUS, 6	;Banksel ANSEL
    clrf    ANSEL	;pines digitales
    clrf    ANSELH
    
    bsf	    STATUS, 5	;banco 01
    bcf	    STATUS, 6	;Banksel TRISA
    movlw   11100000B 
    movwf   TRISB	;PORTA A salida
    ;bsf	    TRISB, 0	;Pin 0 puerto B como entrada
    ;bsf	    TRISB, 1	;Pin 1 puerto B como entrada

    bcf	    STATUS, 5	;banco 00
    bcf	    STATUS, 6	;Banksel PORTA
    clrf    PORTB	;Valor incial 0 en puerto A
  
    call    config_reloj
    call    config_timr0
    banksel PORTB
;----------loop principal---------------------
 loop: 
    ;btfsc   PORTB, 0	;Cuando no este presionado 
    ;call    inc_porta
    ;btfsc   PORTB, 1	;Revisar si no esta presionado 
    ;call    dec_porta
    
    btfss   T0IF
    goto    $-1
    call    _timr0
    incf    PORTB
    goto    loop    ;loop forever 
;------------sub rutinas---------------------
    ;inc_porta:
    ;call    delay_small
    ;btfsc   PORTB, 0	;Revisa de nuevo si no esta presionado
    ;goto    $-1		;ejecuta una linea atrás	        
    ;incf    PORTA
    ;return
    ;dec_porta:
    ;call    delay_small
    ;btfsc   PORTB, 1	;Revisa de nuevo si no esta presionado
    ;goto    $-1		;ejecuta una linea atrás	        
    ;decf    PORTA
    ;return
 config_timr0:
    banksel OPTION_REG   ;Banco de registros asociadas al puerto A
    bcf	    T0CS    ; reloj interno clock selection
    bcf	    PSA	    ;Prescaler 
    bsf	    PS2
    bsf	    PS1
    bsf	    PS0	    ;PS = 111 Tiempo en ejecutar , 256
    
    banksel TMR0
    call    _timr0
    return
 _timr0: 
    movlw   134
    movwf   TMR0
    bcf	    T0IF
    return
    
 config_reloj:
    banksel OSCCON	;Banco OSCCON 
    bcf	    IRCF2	;OSCCON configuración bit2 IRCF
    bsf	    IRCF1	;OSCCON configuracuón bit1 IRCF
    bcf	    IRCF0	;OSCCON configuración bit0 IRCF
    bsf	    SCS		;reloj interno , 250KHz
    return
    
 ;delay_big:
    ;movlw	50		;valor inical del contador 
    ;movwf	cont+1
    ;call	delay_small	;rutina de delay
    ;decfsz	cont+1, 1	;decrementar el contador 
    ;goto	$-2		;ejecutar dos líneas atrás
    ;return
    
 ;delay_small:
    ;movlw	150		;valor incial
    ;movwf	cont
    ;decfsz	cont, 1		;decrementar
    ;goto	$-1		;ejecutar línea anterior
    ;return
    
   
end


