;-----------------------------------------------------------------------------------------------------------------------------
;Control en Biosistemas con Lógica Contínua
;
;Programa de encendido de un  led controlado por pulsador.  Un s?lo pulsador enciende y apaga el led
;-----------------------------------------------------------------------------------------------------------------------------
	list p=18F4550
	include <p18F4550.inc>
        include <configurationbit.txt>; PIC18F4550 Configuration Bit Settings
;-----------------------------------------------------------------------------------------------------------------------------
;Defining Special Bits
;-----------------------------------------------------------------------------------------------------------------------------
CARRY		EQU	0	;   Para la multiplicación y división
ENCENDER	EQU	0	;   Pulsador de encendido
APAGA1		EQU	0
APAGA2		EQU	1
APAGA3		EQU	2		
APAGA4		EQU	3		
APAGA5		EQU	4		
APAGA6		EQU	5		
APAGA7		EQU	6		
SALIDA_U	EQU	1	;   
SALIDA_H	EQU	2 	;   
SALIDA_L	EQU	3	;   
ZERO		EQU	2	;   
NEGATIVE	EQU	4	;   
STATUSLED       EQU	4	;   Para corroborar que el proceso está montad en el procesador
TRIGGER		EQU	6	;   Señal de salida  del ULTRASONIDO
ECHO		EQU	7	;   Señal de entrada del ULTRASONIDO
OKLED		EQU	7	;   Led que corrobora la realización del proceso
;-----------------------------------------------------------------------------------------------------------------------------
;Defining General  Registers   (GPR)
;-----------------------------------------------------------------------------------------------------------------------------
    CBLOCK  0x00
        CONT_L,CONT_H
	DataH,DataL,Tempo
	DataA4,DataA3,DataA2,DataA1
	DataB4,DataB3,DataB2,DataB1
	Result4,Result3,Result2,Result1
	Reminder4,Reminder3,Reminder2,Reminder1
	TempoA4,TempoA3,TempoA2,TempoA1
	TempoB4,TempoB3,TempoB2,TempoB1
	Constant4,Constant3,Constant2,Constant1
	Counter4,Counter3,Counter2,Counter1
    ENDC
;-----------------------------------------------------------------------------------------------------------------------------

	ORG         00
	GOTO        Start
;-----------------------------------------------------------------------------------------------------------------------------
;Main Program
;-----------------------------------------------------------------------------------------------------------------------------
Start

	CALL        CONFIGURATION                               ;Configuration routine
	CLRF	    CONT_L
	CLRF	    CONT_H
	BSF	    PORTA,STATUSLED
	
MAIN	;starts main program				;Turn on Status led
IN	BTFSS		PORTD,ENCENDER
	GOTO		IN
OUT	BTFSC		PORTD,ENCENDER
	GOTO		OUT
	BCF		PORTA,STATUSLED
	CALL		PULSO
B1	BTFSS		PORTC,ECHO
	GOTO		B1
B2	MOVLW		B'11111111'
	CPFSEQ		CONT_L
	GOTO		B3
	INCF		CONT_H
B3	INCF		CONT_L
	BTFSC		PORTC,ECHO
	GOTO		B2
;-----------------------------------------------------------------------------------------------------------------------------
;						    Cálculo del valor real
;-----------------------------------------------------------------------------------------------------------------------------
    MOVF	CONT_L,W
    MOVWF       DataA1                  ;DataA
    MOVF	CONT_H,W
    MOVWF       DataA2                  ;
    CLRF        DataA3                  ;
    CLRF        DataA4

    MOVLW       .232
    MOVWF       DataB1                  ;Data B
    MOVLW       .3
    MOVWF       DataB2
    CLRF        DataB3                  ;
    CLRF        DataB4

    CALL    MULTIPLY				;   ---------------------    Se multiplica por 1000	-----------------------
    
    MOVF        Result1,W
    MOVWF       DataA1                  ;DataA
    MOVF        Result2,W
    MOVWF       DataA2                  ;
    MOVF        Result3,W
    MOVWF       DataA3                  ;
    MOVF        Result4,W
    MOVWF       DataA4
    
    CLRF	Result1
    CLRF	Result2
    CLRF	Result3
    CLRF	Result4
    
    MOVLW       .185
    MOVWF       DataB1                  ;Data B
    MOVLW       .28
    MOVWF       DataB2
    MOVLW       .0
    MOVWF       DataB3                  ;
    MOVLW       .0
    MOVWF       DataB4

    CALL        DIVISION		;   ---------------------	 Se Divide por 1000		----------------------
;-----------------------------------------------------------------------------------------------------------------------------
;						    Limpieza Vúmetro
;-----------------------------------------------------------------------------------------------------------------------------
    	BSF		PORTB,OKLED
	BCF		PORTB,APAGA1
	BCF		PORTB,APAGA2
	BCF		PORTB,APAGA3
	BCF		PORTB,APAGA4
	BCF		PORTB,APAGA5
	BCF		PORTB,APAGA6
	BCF		PORTB,APAGA7
;-----------------------------------------------------------------------------------------------------------------------------
;						    Presentaci+on de los resultados
;-----------------------------------------------------------------------------------------------------------------------------
B4	BTFSS		PORTD,SALIDA_U			
	GOTO  		B4							
B5	BTFSC		PORTD,SALIDA_U			
	GOTO		B5
	MOVFF		Result3,PORTB
B6	BTFSS		PORTD,SALIDA_H			
	GOTO  		B6							
B7	BTFSC		PORTD,SALIDA_H			
	GOTO		B7
	MOVFF		Result2,PORTB
B8	BTFSS		PORTD,SALIDA_L			
	GOTO  		B8							
B9	BTFSC		PORTD,SALIDA_L
	GOTO		B9
	MOVFF		Result1,PORTB
;-----------------------------------------------------------------------------------------------------------------------------
;							    Reseteo
;-----------------------------------------------------------------------------------------------------------------------------
	CLRF	Result1
	CLRF	Result2
	CLRF	Result3
	CLRF	Result4
	CLRF	    CONT_L
	CLRF	    CONT_H
	
    GOTO	MAIN					;Continue
	
	
	
CONFIGURATION
;-----------------------------------------------------------------------------------------------------------------------------
;Configuring Special Registers (SFR)
;-----------------------------------------------------------------------------------------------------------------------------


    CLRF        PORTA
    CLRF        PORTB
    CLRF        PORTC
    CLRF	PORTD
    CLRF	CONT_L
    CLRF	CONT_H
    MOVLW       B'00000010'					;RA1 inputs,  others ouput
    MOVWF       TRISA
    MOVLW       B'00000000'					;PORTB all outputs
    MOVWF       TRISB
    MOVLW       B'10000000'
    MOVWF       TRISC
    MOVLW	B'00001111'
    MOVWF	TRISD
    MOVLW       B'00001111'
    MOVWF       ADCON1						;All digital
    MOVLW       B'10000000'
    MOVWF       OSCTUNE
    MOVLW       B'01101111'				        ;Internal clock,  4 MHz
    MOVWF       OSCCON
    MOVLW	B'10100100'
    MOVWF	T1CON
    MOVLW	.60
    MOVWF	TMR1H
    MOVLW	.176
    MOVWF	TMR1L
    MOVLW	B'00000001'
    MOVWF	PIE1
    MOVLW	B'00000001'
    MOVWF	PIR1
    MOVLW	B'11000000'
    MOVWF	INTCON
    
    
    CLRF        UCON
    CLRF        UCFG
	

    RETURN
   
;-----------------------------------------------------------------------------------------------------------------------------
;Pulso
;-----------------------------------------------------------------------------------------------------------------------------
PULSO
    
    
    BSF	    PORTC,TRIGGER
    
    
    NOP	    ;	1
    NOP	    ;	2
    NOP	    ;	3
    NOP	    ;	4
    NOP	    ;	5
    NOP	    ;	6
    NOP	    ;	7
    NOP	    ;	8
    NOP	    ;	9
    NOP	    ;	10
    NOP	    ;	11
    NOP	    ;	12
    NOP	    ;	13
    NOP	    ;	14
    NOP	    ;	15
    NOP	    ;	16
    NOP	    ;	17
    NOP	    ;	18
    NOP	    ;	19
    NOP	    ;	20
    NOP	    ;	21
    NOP	    ;	22
    NOP	    ;	23
    NOP	    ;	24
    NOP	    ;	25
    NOP	    ;	26
    NOP	    ;	27
    NOP	    ;	28
    NOP	    ;	29
    NOP	    ;	30
    NOP	    ;	31
    NOP	    ;	32
    NOP	    ;	33
    NOP	    ;	34
    NOP	    ;	35
    NOP	    ;	36
    NOP	    ;	37
    NOP	    ;	38
    NOP	    ;	39
    NOP	    ;	40
    NOP	    ;	1
    NOP	    ;	2
    NOP	    ;	3
    NOP	    ;	4
    NOP	    ;	5
    NOP	    ;	6
    NOP	    ;	7
    NOP	    ;	8
    NOP	    ;	9
    NOP	    ;	10
    
    
    BCF	    PORTC,TRIGGER
    
    
    
    RETURN
    
;-----------------------------------------------------------------------------------------------------------------------------
;Contador LOW
;-----------------------------------------------------------------------------------------------------------------------------
    
;-----------------------------------------------------------------------------------------------------------------------------
;Contador HIGH
;-----------------------------------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------
;Double Precision Multiply
;
;   Multiplication  : DataA(16 bits)  x  DataB(16 bits) -> Result(32 bits)
;                          DataA : 4 Bytes     DataB : 4 Bytes
;--------------------------------------------------------------------------------------------
MULTIPLY
	MOVFF		DataA4,Constant4				;Store the constant value to add
	MOVFF		DataA3,Constant3
	MOVFF		DataA2,Constant2				;Store the constant value to add
	MOVFF		DataA1,Constant1
	MOVFF		DataB4,Counter4
	MOVFF		DataB3,Counter3
	MOVFF		DataB2,Counter2
	MOVFF		DataB1,Counter1
	MOVFF		DataA4,Result4
	MOVFF		DataA3,Result3
	MOVFF		DataA2,Result2
	MOVFF		DataA1,Result1
A7	MOVFF		Counter4,DataA4					;Move Counter to DataA
	MOVFF		Counter3,DataA3
	MOVFF		Counter2,DataA2					;Move Counter to DataA
	MOVFF		Counter1,DataA1
	CLRF		DataB4							;-----------------------------
	CLRF		DataB3
	CLRF		DataB2
	MOVLW   	.1								;Decrement by 1 the counter
	MOVWF   	DataB1							;-----------------------------
	CALL		SUBTRACTION
	MOVFF		DataA4,Counter4				;
	MOVFF		DataA3,Counter3					;Store data in Counter
	MOVFF		DataA2,Counter2				;
	MOVFF		DataA1,Counter1					;Store data in Counter
	MOVLW       .0								;-------------------------------
	CPFSEQ      Counter4
	GOTO       	A8
	CPFSEQ  	Counter3
	GOTO		A8
	CPFSEQ  	Counter2						;
	GOTO		A8								;Check if Counter is Zero
	CPFSEQ      Counter1						;
	GOTO		A8								;-------------------------------
	RETURN
A8	MOVFF		Result4,DataA4					;Result is the progressive sum
	MOVFF		Result3,DataA3
	MOVFF		Result2,DataA2					;Result is the progressive sum
	MOVFF		Result1,DataA1
	MOVFF		Constant4,DataB4
	MOVFF		Constant3,DataB3
	MOVFF		Constant2,DataB2
	MOVFF		Constant1,DataB1
	CALL		ADD
	GOTO		A7
	RETURN

;--------------------------------------------------------------------------------------------
;Double Precision Division
;
;   Division : DataA(32 bits) / DataB(32 bits) -> Result(32 bits) with
;                                               Remainder in Reminder(32 bits)
;--------------------------------------------------------------------------------------------
DIVISION
	CLRF		Result4						;Result 16 bits
	CLRF		Result3
	CLRF		Result2						;Result 16 bits
	CLRF		Result1
	CLRF		Reminder4					;Reminder 16 bits
	CLRF		Reminder3
	CLRF		Reminder2					;Reminder 16 bits
	CLRF		Reminder1
A5	CALL		SUBTRACTION
	BTFSS		STATUS,NEGATIVE				;Check if result is negative
	GOTO		A6							;No,  then continue
	BTFSS		STATUS,CARRY
	RETURN									;Yes,  then finish division
A6	CALL		TEMPO_STORE					;Store data
	MOVLW       .1							;-----------------------------
	MOVWF       DataA1						;
	CLRF		DataA2						;Increment quotient by 1
	CLRF		DataA3
	CLRF		DataA4
	MOVFF		Result1,DataB1				;
	MOVFF		Result2,DataB2				;
	MOVFF		Result3,DataB3				;
	MOVFF		Result4,DataB4
	CALL		ADD							;-----------------------------
	CALL		TEMPO_RECOVERY				;Recover data
	GOTO		A5	
	
;--------------------------------------------------------------------------------------------
;Double Precision Addition
;
;   Addition :  DataA(32 bits) + DataB(32 bits) -> Result(32 bits)
;--------------------------------------------------------------------------------------------
ADD
	MOVF    	DataA1,W
	ADDWF     	DataB1,0           		;ADDWF LSB
	MOVWF       Result1

	MOVF    	DataA2,W
	ADDWFC      DataB2,0           		;ADDWF MSB WITH CARRY
	MOVWF       Result2

	MOVF    	DataA3,W
	ADDWFC      DataB3,0           		;ADDWF MSB WITH CARRY
	MOVWF       Result3

	MOVF    	DataA4,W
	ADDWFC      DataB4,0           		;ADDWF MSB WITH CARRY
	MOVWF       Result4

	RETURN
;--------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------
;Double Precision Subtraction
;
;   Subtraction : DataA(32 bits) - DataB(32 bits) -> DataA(32 bits)
;--------------------------------------------------------------------------------------------
SUBTRACTION
	MOVF    	DataB1,W
	SUBWF		DataA1
	MOVF		DataB2,W
	BTFSS		STATUS,CARRY
	INCFSZ		DataB2,W
	SUBWF		DataA2

	MOVF		DataB3,W
	BTFSS		STATUS,CARRY
	INCFSZ		DataB3,W
	SUBWF		DataA3

	MOVF		DataB4,W
	BTFSS		STATUS,CARRY
	INCFSZ		DataB4,W
	SUBWF		DataA4

	RETURN
	
;--------------------------------------------------------------------------------------------
;Store and Recovery Data Routine (Temporary store)
;--------------------------------------------------------------------------------------------
TEMPO_STORE
	MOVFF		DataA4,TempoA4
	MOVFF		DataA3,TempoA3
	MOVFF		DataA2,TempoA2
	MOVFF		DataA1,TempoA1

	MOVFF		DataB4,TempoB4
	MOVFF		DataB3,TempoB3
	MOVFF		DataB2,TempoB2
	MOVFF		DataB1,TempoB1
	RETURN
	
TEMPO_RECOVERY
	MOVFF		TempoA4,DataA4
	MOVFF		TempoA3,DataA3
	MOVFF		TempoA2,DataA2
	MOVFF		TempoA1,DataA1

	MOVFF		TempoB4,DataB4
	MOVFF		TempoB3,DataB3
	MOVFF		TempoB2,DataB2
	MOVFF		TempoB1,DataB1
	RETURN
	
	
	END
	


