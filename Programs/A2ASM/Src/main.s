;******************** (C) COPYRIGHT HAW-Hamburg ********************************
;* File Name          : main.s
;* Author             : Martin Becke    
;* Version            : V1.0
;* Date               : 01.06.2021
;* Description        : This is a simple main to demonstrate data transfer
;                     : and manipulation.
;                     :
;
;*******************************************************************************
    EXTERN initITSboard ; Helper to organize the setup of the board
 
    EXPORT main         ; we need this for the linker - In this context it set the entry point,too
 
ConstByteA  EQU 0xaffe ; hier wird ConstByteA als Variable mit dem Wert 0xaffe definiert. (10*16**3 + 15*16**2 + 15*16**1 + 14*16**0 = 45054 || 1010 1111 1111 1110)
   
;* We need some data to work on
    AREA DATA, DATA, align=2    
VariableA   DCW 0xbeef ; diese Variablen werden auch im Speicher abgelegt, da sie mit DCW definiert wurden. (11*16**3 + 14*16**2 + 14*16**1 + 15*16**0 = 48879 || 1011 1110 1110 1111)
VariableB   DCW 0x1234 ; (1*16**3 + 2*16**2 + 3*16**1 + 4*16**0 = 4660 || 0001 0010 0011 0100)
 
;* We need minimal memory setup of InRootSection placed in Code Section
    AREA  |.text|, CODE, READONLY, ALIGN = 3    ; Ka. was das heißt
    ALIGN  
main
    BL initITSboard             ; needed by the board to setup
;* swap memory - Is there another, at least optimized approach?
    ldr     R0,=VariableA   ; Anw01 lädt die ADRESSE von VariableA into R0
    ldrb    R2,[R0]         ; Anw02 load byte at address in R0 into R2 (0xef) - da ldrb nur 1 Byte lädt, wird nur das niederwertigste Byte von VariableA geladen (ef nicht be)
    ldrb    R3,[R0,#1]      ; Anw03 lädt das nächste Byte an der Adresse von VariableA in R3 (0xbe)
    lsl     R2, #8          ; Anw04 schiebt das Byte in R2 um 8 Positionen nach links vorher 1110 1111 danach 1110 1111 0000 0000
    orr     R2, R3          ; Anw05 1110 1111 0000 0000 or 0000 0000 1011 1110 ergibt 1110 1111 1011 1110 (0xbeef) und speichert es in R2
    strh    R2,[R0]         ; Anw06 speichert den Inhalt von R2 (0xbeef) als Halbwort (16 Bit) an der Adresse von VariableA, überschreibt also den ursprünglichen Wert von VariableA mit 0xbeef. Da VariableA bereits 0xbeef war, bleibt der Wert unverändert.
   
;* const in var
    mov     R5,#ConstByteA  ; Anw07 lädt den Wert von ConstByteA (0xaffe) in R5. Da ConstByteA als Konstante definiert ist, wird der Wert direkt in den Register geladen, ohne dass er aus dem Speicher gelesen werden muss.
    strh    R5,[R0]         ; Anw08 speichert den Inhalt von R5 (0xaffe) als Halbwort (16 Bit) an der Adresse von VariableA, überschreibt also den ursprünglichen Wert von VariableA mit 0xaffe. Da VariableA zuvor 0xbeef war, wird der Wert jetzt auf 0xaffe geändert.
   
;* Change value from x1234 to x4321
    ldr     R1,=VariableB   ; Anw09 lädt die ADRESSE von VariableB in R1
    ldrh    R6,[R1]         ; Anw0A lädt das Halbwort (16 Bit) an der Adresse von VariableB in R6, also den Wert 0x1234. R6 enthält jetzt 0x1234.
    mov     R7, #0x30ED     ; Anw0B lädt den Wert 0x30ED in R7.
    add     R6, R6, R7      ; Anw0C addiert den Wert in R7 (0x30ED) zu dem Wert in R6 (0x1234) und speichert das Ergebnis in R6. D+4 = 17, (gesch. als 0x11) 3+E = 17 (gesch. als 0x110), 2+0 = 2 (gesch. als 0x200), 1+3 = 4 ergibt 0x4 (gesch als 0x4000) also 0x4321
    b .                     ; Anw0E endlosscchleife, damit das Programm nicht weiterläuft und möglicherweise unerwünschte Effekte hat.
   
    ALIGN
    END
