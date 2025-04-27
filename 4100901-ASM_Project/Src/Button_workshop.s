// --- Ejercicio botón y LED - Versión estructurada -----------------
    .section .text
    .syntax unified
    .thumb

    .global main
    .global init_led
    .global init_boton

// --- Definiciones de registros para LD2 (PA5) ---------------------
    .equ RCC_BASE,       0x40021000         @ Base de RCC
    .equ RCC_AHB2ENR,    RCC_BASE + 0x4C    @ Enable GPIOA clock
    .equ GPIOA_BASE,     0x48000000         @ Base de GPIOA
    .equ GPIOA_MODER,    GPIOA_BASE + 0x00  @ Mode register
    .equ GPIOA_ODR,      GPIOA_BASE + 0x14  @ Output register
    .equ LD2_PIN,        5                  @ Pin del LED LD2

// --- Definiciones de registros para B1 (PC13) ---------------------
    .equ GPIOC_BASE,     0x48000800         @ Base de GPIOC
    .equ GPIOC_MODER,    GPIOC_BASE + 0x00  @ Mode register
    .equ GPIOC_IDR,      GPIOC_BASE + 0x10  @ Input register
    .equ B1_PIN,        13                  @ Pin del Boton B1

// --- Programa principal ------------------------------------------
main:
    bl init_led
    bl init_boton
main_loop:
    @ Verificar estado del botón
    movw r0, #:lower16:GPIOC_IDR
    movt r0, #:upper16:GPIOC_IDR
    ldr  r1, [r0]
    movs r2, #1
    lsl  r2, r2, #B1_PIN
    ands r1, r1, r2
    cmp  r1, #0
    bne  boton_no_presionado
    
    @ Encender LED
    movw r0, #:lower16:GPIOA_ODR
    movt r0, #:upper16:GPIOA_ODR
    ldr  r1, [r0]
    orr  r1, r1, #(1 << LD2_PIN)
    str  r1, [r0]
    
    @ Delay de ~3 segundos
    movw r2, #:lower16:3000000       @ Ajustar este valor
    movt r2, #:upper16:3000000
delay:
    subs r2, r2, #1
    bne  delay
    
    @ Apagar LED
    ldr  r1, [r0]
    bic  r1, r1, #(1 << LD2_PIN)
    str  r1, [r0]
    
boton_no_presionado:
    b main_loop

// --- Inicialización de LED ---------------------------------------
init_led:
    movw r0, #:lower16:RCC_AHB2ENR
    movt r0, #:upper16:RCC_AHB2ENR
    ldr  r1, [r0]
    orr  r1, r1, #(1 << 0)          @ Habilita GPIOA
    str  r1, [r0]

    movw r0, #:lower16:GPIOA_MODER
    movt r0, #:upper16:GPIOA_MODER
    ldr  r1, [r0]
    bic  r1, r1, #(0b11 << (LD2_PIN * 2))
    orr  r1, r1, #(0b01 << (LD2_PIN * 2)) @ Salida
    str  r1, [r0]
    
    @ Apagar LED inicialmente
    movw r0, #:lower16:GPIOA_ODR
    movt r0, #:upper16:GPIOA_ODR
    ldr  r1, [r0]
    bic  r1, r1, #(1 << LD2_PIN)
    str  r1, [r0]
    
    bx lr

// --- Inicialización de Botón -------------------------------------
init_boton:
    movw r0, #:lower16:RCC_AHB2ENR
    movt r0, #:upper16:RCC_AHB2ENR
    ldr  r1, [r0]
    orr  r1, r1, #(1 << 2)          @ Habilita GPIOC
    str  r1, [r0]

    movw r0, #:lower16:GPIOC_MODER
    movt r0, #:upper16:GPIOC_MODER
    ldr  r1, [r0]
    bic  r1, r1, #(0b11 << (B1_PIN * 2)) @ Entrada
    str  r1, [r0]
    
    bx lr
    