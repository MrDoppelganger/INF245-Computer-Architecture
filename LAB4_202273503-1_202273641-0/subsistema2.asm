.data
    # Constantes de caracteres
    especial:   .string "!@#$%&*+"
    mayus:      .string "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    minus:      .string "abcdefghijklmnopqrstuvwxyz"
    num:        .string "0123456789"

    # Mensajes
    prompt:     .string "ingrese la clave a probar: "
    err_len:    .string "ERROR: La clave debe tener exactamente 16 caracteres.\n"
    err_c1:     .string "CLAVE RECHAZADA\nCapa fallida: 1 (ANALISIS DE COMPOSICIN)\n"
    err_c2:     .string "CLAVE RECHAZADA\nCapa fallida: 2 (PARIDAD POSICIONAL)\n"
    err_c3:     .string "CLAVE RECHAZADA\nCapa fallida: 3 (HASH DE VERIFICACION)\n"
    success:    .string "CLAVE ACEPTADA\n"
    newline:    .string "\n"

    # Buffer para la clave (16 chars + 1 null + margen de seguridad)
    clave:      .space 20

.text
.globl main

# -------------------------------------------------------------------
# MAIN
# -------------------------------------------------------------------
main:
    # 1. Imprimir prompt
    li a7, 4            # Syscall print_string
    la a0, prompt
    ecall

    # 2. Leer string (scanf)
    li a7, 8            # Syscall read_string
    la a0, clave        # Buffer address
    li a1, 20           # Max length
    ecall

    # --- Limpieza del input (eliminar \n si existe) ---
    la t0, clave
clean_loop:
    lb t1, 0(t0)
    beqz t1, check_len  # Fin de string
    li t2, 10           # ASCII de \n
    beq t1, t2, remove_nl
    addi t0, t0, 1
    j clean_loop
remove_nl:
    sb zero, 0(t0)      # Reemplazar \n con \0

    # 3. Verificar longitud (strlen)
check_len:
    la a0, clave
    call strlen_custom  # Retorna longitud en a0
    li t1, 16
    bne a0, t1, fail_len

    # 4. Validar Capa 1
    la a0, clave
    call capa1
    beqz a0, fail_capa1 # Si retorna 0, falla

    # 5. Validar Capa 2
    la a0, clave
    call capa2
    beqz a0, fail_capa2

    # 6. Validar Capa 3
    la a0, clave
    call capa3
    beqz a0, fail_capa3

    # 7. Éxito
    li a7, 4
    la a0, success
    ecall
    j exit

# --- Manejo de Errores ---
fail_len:
    li a7, 4
    la a0, err_len
    ecall
    li a0, 1            # Return 1
    j exit_prog

fail_capa1:
    li a7, 4
    la a0, err_c1
    ecall
    j exit_fail

fail_capa2:
    li a7, 4
    la a0, err_c2
    ecall
    j exit_fail

fail_capa3:
    li a7, 4
    la a0, err_c3
    ecall
    j exit_fail

exit_fail:
    li a0, 0            # Return 0 en fallos de lógica
    j exit_prog

exit:
    li a0, 0            # Return 0 éxito

exit_prog:
    li a7, 10           # Syscall exit
    ecall

# -------------------------------------------------------------------
# CAPA 1: Análisis de Composición
# a0 = dirección de clave
# Retorna: a0 = 1 (pasa), 0 (falla)
# -------------------------------------------------------------------
capa1:
    addi sp, sp, -32    # Guardar registros en stack
    sw ra, 28(sp)
    sw s0, 24(sp)       # Puntero clave
    sw s1, 20(sp)       # c_mayus
    sw s2, 16(sp)       # c_minus
    sw s3, 12(sp)       # c_num
    sw s4, 8(sp)        # c_esp
    sw s5, 4(sp)        # iterador i

    mv s0, a0           # s0 = clave
    li s1, 0
    li s2, 0
    li s3, 0
    li s4, 0
    li s5, 0            # i = 0

loop_c1:
    li t0, 16
    bge s5, t0, end_loop_c1

    # Cargar char c = key[i]
    add t0, s0, s5
    lb a1, 0(t0)        # a1 = char actual para pasar a strchr_custom

    # Check Mayus
    la a0, mayus
    call strchr_custom
    bnez a0, inc_mayus

    # Check Minus
    la a0, minus
    # Recuperar char (a1 podría haber cambiado si no seguimos convención, pero strchr la preserva o la restauramos)
    add t0, s0, s5
    lb a1, 0(t0)
    call strchr_custom
    bnez a0, inc_minus

    # Check Num
    la a0, num
    add t0, s0, s5
    lb a1, 0(t0)
    call strchr_custom
    bnez a0, inc_num

    # Check Especial
    la a0, especial
    add t0, s0, s5
    lb a1, 0(t0)
    call strchr_custom
    bnez a0, inc_esp

    # Si llega aquí, es un caracter inválido (else return 0)
    j fail_c1_logic

inc_mayus:
    addi s1, s1, 1
    j next_iter_c1
inc_minus:
    addi s2, s2, 1
    j next_iter_c1
inc_num:
    addi s3, s3, 1
    j next_iter_c1
inc_esp:
    addi s4, s4, 1
    j next_iter_c1

next_iter_c1:
    addi s5, s5, 1
    j loop_c1

end_loop_c1:
    # Verificar que todos sean exactamente 4
    li t0, 4
    bne s1, t0, fail_c1_logic
    bne s2, t0, fail_c1_logic
    bne s3, t0, fail_c1_logic
    bne s4, t0, fail_c1_logic
    
    li a0, 1            # True
    j exit_c1

fail_c1_logic:
    li a0, 0            # False

exit_c1:
    lw ra, 28(sp)
    lw s0, 24(sp)
    lw s1, 20(sp)
    lw s2, 16(sp)
    lw s3, 12(sp)
    lw s4, 8(sp)
    lw s5, 4(sp)
    addi sp, sp, 32
    ret

# -------------------------------------------------------------------
# CAPA 2: Paridad Posicional (Bloques impares)
# a0 = dirección de clave
# Retorna: a0 = 1 (pasa), 0 (falla)
# -------------------------------------------------------------------
capa2:
    mv t0, a0           # t0 = puntero clave
    li t1, 0            # bloques_impares = 0
    li t2, 0            # i = 0 (iterador de bloques: 0, 4, 8, 12)

loop_c2_outer:
    li t3, 16
    bge t2, t3, end_c2
    
    li t4, 0            # checksum = 0
    li t5, 0            # j = 0 (iterador interno: 0 a 3)

loop_c2_inner:
    li t6, 4
    bge t5, t6, check_block
    
    # Calcular índice real: i + j
    add t6, t2, t5      # offset
    add t6, t0, t6      # address
    lb t6, 0(t6)        # cargar char
    add t4, t4, t6      # checksum += char
    
    addi t5, t5, 1
    j loop_c2_inner

check_block:
    # if (checksum % 2 != 0)
    andi t6, t4, 1      # t6 = checksum % 2
    beqz t6, next_block
    addi t1, t1, 1      # bloques_impares++

next_block:
    addi t2, t2, 4      # i += 4
    j loop_c2_outer

end_c2:
    li t2, 3
    bge t1, t2, pass_c2
    li a0, 0
    ret
pass_c2:
    li a0, 1
    ret

# -------------------------------------------------------------------
# CAPA 3: Hash de Verificación
# a0 = dirección de clave
# Retorna: a0 = 1 (pasa), 0 (falla)
# -------------------------------------------------------------------
capa3:
    mv t0, a0           # t0 = puntero clave
    li t1, 0            # hash = 0
    li t2, 0            # i = 0
    li t3, 31           # constante multiplicadora
    li t4, 65536        # constante modulo (0x10000)

loop_c3:
    li t5, 16
    bge t2, t5, end_c3

    # hash * 31
    mul t1, t1, t3
    
    # + key[i]
    add t6, t0, t2      # address
    lb t6, 0(t6)        # load char
    add t1, t1, t6      # hash += char
    
    # % 65536 (Optimización: AND con 0xFFFF es equivalente a % 65536)
    li t6, 0xFFFF
    and t1, t1, t6      # hash %= 65536

    addi t2, t2, 1
    j loop_c3

end_c3:
    li t2, 10000
    bgt t1, t2, pass_c3
    li a0, 0
    ret
pass_c3:
    li a0, 1
    ret

# -------------------------------------------------------------------
# UTILS
# -------------------------------------------------------------------

# strlen_custom(char* str) -> int length
strlen_custom:
    mv t0, a0
    li t1, 0
len_loop:
    lb t2, 0(t0)
    beqz t2, len_end
    addi t1, t1, 1
    addi t0, t0, 1
    j len_loop
len_end:
    mv a0, t1
    ret

# strchr_custom(char* str_set, char c) -> int found (1 or 0)
# Busca el caracter 'c' (a1) dentro del string 'str_set' (a0)
strchr_custom:
    mv t0, a0           # t0 = puntero al set
search_loop:
    lb t2, 0(t0)
    beqz t2, not_found  # fin de string, no encontrado
    beq t2, a1, found   # encontrado
    addi t0, t0, 1
    j search_loop
found:
    li a0, 1
    ret
not_found:
    li a0, 0
    ret
