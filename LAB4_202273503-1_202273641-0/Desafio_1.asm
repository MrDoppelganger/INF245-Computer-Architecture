############################################################
# DESAFÍO 1 – Jerarquía Criminal con Secuencia de Collatz
############################################################

#--------------------Settings--------------------------------
.data
    str_ingrese_n:      .asciz "Ingrese cantidad de IDs: "
    str_ingrese_ids:    .asciz "Ingrese los IDs:\n"
    str_id:             .asciz "ID: "
    str_pasos:          .asciz "\nPasos: "
    str_rango:          .asciz "\nRango: "
    str_sep:            .asciz "\n------------------------------------\n"

    str_lider:          .asciz "LIDER"
    str_oper:           .asciz "OPERADOR"
    str_infor:          .asciz "INFORMANTE"
    str_peon:           .asciz "PEON"

    .align 2            # 🔥 ayuda a ordenar
IDs: 
    .space 80           # hasta 20 enteros (20 × 4 bytes)

.text
.globl main

#-----------------------main-------------------------------
main:

    ########################################################
    # 1) Leer n
    ########################################################
    la a0, str_ingrese_n
    li a7, 4
    ecall

    li a7, 5      # read_int
    ecall
    mv s0, a0     # s0 = n

    ########################################################
    # 2) Leer los IDs
    ########################################################
    la a0, str_ingrese_ids
    li a7, 4
    ecall

    la s1, IDs    # base del arreglo
    li s2, 0       # i = 0

leer_ids:
    bge s2, s0, comenzar_proceso

    li a7, 5
    ecall           # a0 = entero leído

    slli t0, s2, 2   # offset = i*4
    add t0, s1, t0
    sw a0, 0(t0)

    addi s2, s2, 1
    j leer_ids

############################################################
# 3) Procesar cada ID
############################################################
comenzar_proceso:
    li s2, 0        # i = 0

bucle_ids:
    bge s2, s0, fin

    # Cargar ID[i]
    slli t0, s2, 2
    add t0, s1, t0
    lw a1, 0(t0)       # a1 = valor
    mv s3, a1          # guardar ID para imprimir

    ########################################################
    # Llamada recursiva: pasos = secCollatz(0, ID)
    ########################################################
    li a0, 0           # pasos = 0
    addi sp, sp, -4
    sw ra, 0(sp)
    jal ra, secCollatz
    lw ra, 0(sp)
    addi sp, sp, 4

    mv s4, a0          # s4 = pasos

    ########################################################
    # Imprimir ID y Pasos
    ########################################################
    mv a0, s3     # ID
    mv a1, s4     # Pasos
    jal ra, imprimir_id_pasos

    ########################################################
    # Clasificar rango
    ########################################################
    li t0, 20
    blt s4, t0, rango_peon

    li t0, 50
    blt s4, t0, rango_informante

    li t0, 100
    blt s4, t0, rango_operador

    j rango_lider

rango_peon:
    la a0, str_peon
    j imprimir_rango

rango_informante:
    la a0, str_infor
    j imprimir_rango

rango_operador:
    la a0, str_oper
    j imprimir_rango

rango_lider:
    la a0, str_lider

############################################################
# Imprimir rango
############################################################
imprimir_rango:
    mv a1, a0               # guardar dirección del nombre de rango

    la a0, str_rango        # "\nRango: "
    li a7, 4
    ecall

    mv a0, a1               # imprimir nombre del rango
    li a7, 4
    ecall

    la a0, str_sep          # imprimir separador
    li a7, 4
    ecall

    addi s2, s2, 1
    j bucle_ids

############################################################
# Fin de programa
############################################################
fin:
    li a7, 10
    ecall


############################################################
# FUNCION RECURSIVA secCollatz(pasos, valor)
# Parámetros:
#   a0 = pasos
#   a1 = valor
# Retorno:
#   a0 = pasos finales
############################################################
secCollatz:

    li t0, 1
    beq a1, t0, retorno_base      # caso base, sin tocar el stack

    ########################################################
    # Caso recursivo → hay que guardar RA
    ########################################################
    addi sp, sp, -4
    sw ra, 0(sp)

    # Paridad
    andi t1, a1, 1
    beq t1, zero, collatz_par

collatz_impar:
    # 3*n + 1
    slli t2, a1, 1     # 2n
    add a1, a1, t2     # 3n
    addi a1, a1, 1
    j preparar_llamada

collatz_par:
    srli a1, a1, 1     # n/2

preparar_llamada:
    addi a0, a0, 1     # pasos++

    jal ra, secCollatz

    # Recuperar RA
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra

retorno_base:
    jr ra


############################################################
# imprimir_id_pasos(ID=a0, pasos=a1)
############################################################
imprimir_id_pasos:
    # "ID: "
    la t0, str_id
    mv a0, t0
    li a7, 4
    ecall

    # valor ID (a0 original está en a0?? NO, lo pasamos de manera explícita)
    mv t0, a0
    mv a0, t0
    li a7, 1
    ecall

    # "\nPasos: "
    la a0, str_pasos
    li a7, 4
    ecall

    # imprimir pasos (a1)
    mv a0, a1
    li a7, 1
    ecall

    jr ra
