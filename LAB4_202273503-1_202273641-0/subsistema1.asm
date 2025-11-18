############################################################
# DESAFÍO 1 – Jerarquía Criminal con Secuencia de Collatz
# ---------------------------------------------------------
# Este programa recibe una lista de IDs pertenecientes a
# miembros capturados, calcula su secuencia de Collatz de
# forma recursiva y determina su rango jerárquico según el
# número de pasos necesarios para llegar a 1.
############################################################


# ==========================================================
#                        Settings
# ==========================================================
.data
    # strings precargados para interfaz
    str_ingrese_n:      .asciz "Ingrese cantidad de IDs: "
    str_ingrese_ids:    .asciz "Ingrese los IDs:\n"
    str_id:             .asciz "ID: "
    str_pasos:          .asciz "\nPasos: "
    str_rango:          .asciz "\nRango: "
    str_sep:            .asciz "\n------------------------------------\n"

    # Nombres de rangos
    str_lider:          .asciz "LIDER"
    str_oper:           .asciz "OPERADOR"
    str_infor:          .asciz "INFORMANTE"
    str_peon:           .asciz "PEON"

    # Espacio para almacenar hasta 20 IDs (20 * 4 bytes)
    .align 2
IDs:
    .space 80


# ==========================================================
#                        Main
# ==========================================================
.text
.globl main

main:

    # ------------------- Lectura de n ----------------------
    la a0, str_ingrese_n
    li a7, 4
    ecall

    li a7, 5
    ecall
    mv s0, a0              # s0 = n

    # ------------------- Lectura de IDs --------------------
    la a0, str_ingrese_ids
    li a7, 4
    ecall

    la s1, IDs             # s1 = base del arreglo
    li s2, 0               # índice i = 0

leer_ids:
    bge s2, s0, comenzar_proceso

    li a7, 5
    ecall                  # a0 = ID ingresado

    slli t0, s2, 2         # offset = i * 4
    add t0, s1, t0
    sw a0, 0(t0)           # guardar ID

    addi s2, s2, 1
    j leer_ids


############################################################
# Procesamiento de IDs:
#   Para cada ID del arreglo:
#       - Se calcula su Collatz recursivo
#       - Se imprimen ID y pasos
#       - Se determina y muestra el rango
############################################################
comenzar_proceso:
    li s2, 0

bucle_ids:
    bge s2, s0, fin

    # Cargar ID[i]
    slli t0, s2, 2
    add t0, s1, t0
    lw a1, 0(t0)            # a1 = ID
    mv s3, a1               # guardar ID para imprimirlo

    # ----------- Llamada recursiva a secCollatz ------------
    li a0, 0                # pasos = 0

    addi sp, sp, -4
    sw ra, 0(sp)

    jal ra, secCollatz      # al volver, a0 = pasos totales

    lw ra, 0(sp)
    addi sp, sp, 4

    mv s4, a0               # s4 = pasos del ID

    # ----------- Mostrar ID y pasos ------------------------
    mv a0, s3               # ID
    mv a1, s4               # pasos
    jal ra, imprimir_id_pasos

    # ----------- Clasificación por rango -------------------
    li t0, 20
    blt s4, t0, rango_peon

    li t0, 50
    blt s4, t0, rango_informante

    li t0, 100
    blt s4, t0, rango_operador

    j rango_lider


# ----- Saltos de clasificación -----
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
# imprimir_rango :
#   Imprime el rango del miembro
#
#Parámetros :
#       a0: dirección del texto del rango
#
#Retorno :
#       Nada
############################################################
imprimir_rango:
    mv a1, a0               # guardar texto del rango

    la a0, str_rango        # imprimir "Rango:"
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
# Fin del programa
############################################################
fin:
    li a7, 10
    ecall


############################################################
# secCollatz :
#   Realiza el cálculo recursivo de Collatz:
#	par: n = n / 2
#   	impar: n = 3n + 1
#	n = 1: Se detiene
#
#Parámetros :
#	a0: pasos acumulados
#	a1: valor actual
#
#Retorno :
#	a0: los pasos que se demoro en llegar a 1
############################################################
secCollatz:

    # Caso base: si valor = 1 no se toca el stack
    li t0, 1
    beq a1, t0, retorno_base

    # Caso recursivo: almacenar RA
    addi sp, sp, -4
    sw ra, 0(sp)

    # Determinar si es par o impar
    andi t1, a1, 1
    beq t1, zero, collatz_par

collatz_impar:
    # n = 3*n + 1
    slli t2, a1, 1      # 2n
    add a1, a1, t2      # 3n
    addi a1, a1, 1
    j preparar_llamada

collatz_par:
    # n = n / 2
    srli a1, a1, 1

preparar_llamada:
    addi a0, a0, 1       # Aumentamos pasos en 1

    jal ra, secCollatz  # llamada recursiva

    # Restaurar RA tras volver de recursión
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra

retorno_base:
    jr ra


############################################################
# imprimir_id_pasos :
#   Muestra un ID junto a su cantidad de pasos.
#
#Parámetros :
#       a0: ID
#       a1: pasos
#Retorno
#	Nada
############################################################
imprimir_id_pasos:
    # Guardar ID y pasos en el stack
    addi sp, sp, -8
    sw a0, 0(sp)      # guardar ID
    sw a1, 4(sp)      # guardar pasos

    # Imprimir "ID: "
    la a0, str_id
    li a7, 4
    ecall

    # Recuperar ID e imprimirlo
    lw a0, 0(sp)
    li a7, 1
    ecall

    # Imprimir "\nPasos: "
    la a0, str_pasos
    li a7, 4
    ecall

    # Recuperar pasos e imprimirlos
    lw a0, 4(sp)
    li a7, 1
    ecall

    # Restaurar stack
    addi sp, sp, 8
    jr ra

