#---------Settings-----------
import random

#Creamos una variable random para generar los datos.
random = random.randint

#---------Funciones----------

'''
transformadorBinario :
    cambia de decimal a binario un valor.
***
Entradas :
    int decimal: es el valor decimal que volvera como binario
***
Tipo de Retorno : 
    str bin : el valor transformado a binario
'''
def transformadorBinario(decimal : int):
    bin = ''
    while (decimal > 0):
        bin = str(decimal % 2) + bin
        decimal = decimal // 2 

    return bin

'''
transformadorOctal :
    cambia de decimal a Octal un valor.
***
Entradas :
    int decimal: es el valor decimal que volvera como binario
***
Tipo de Retorno : 
    str octal : el valor transformado a Octal
'''
def TransformadorOctal(decimal : int):
    octal = ''
    while (decimal > 0):
        octal = str(decimal % 8) + octal
        decimal = decimal // 8 

    return octal

'''
transformadorHexa :
    cambia de decimal a hexadecimal un valor.
***
Entradas :
    int decimal: es el valor decimal que volvera como binario
***
Tipo de Retorno : 
    str hexa : el valor transformado a hexadecimal
'''
def transformadorHexa(decimal : int):
    hexa = ''
    while (decimal > 0):
        resto = str(decimal % 16)
        match resto:
            case "10":
                resto = 'A'
            case "11":
                resto = 'B'
            case "12":
                resto = 'C'
            case "13":
                resto = 'D'
            case "14":
                resto = 'E'
            case "15":
                resto = 'F' 
        hexa = resto + hexa
        decimal = decimal // 16 

    return hexa

'''
desencriptador :
    desencripta valores binarios, hexadecimales y octotales  para 
    pasarlos a decimal.
***
Entradas :
    str valor : Es el valor a desencriptar
    int base : es la base en la que estamos
***
Tipo de Retorno : 
    int decimal : el valor desencriptado a decimal
'''
def desencriptador(valor : str, base : int):
    #creamos nuestros iteradores.
    decimal = 0
    contador = len(valor) - 1
    #separamos cada bit del valor y le sunamos su valor al output.
    for bit in valor:
        match bit:
            case 'A':
                decimal += 10 * (base ** contador)
            case 'B':
                decimal += 11 * (base ** contador)
            case 'C':
                decimal += 12 * (base ** contador)
            case 'D':
                decimal += 13 * (base ** contador)
            case 'E':
                decimal += 14 * (base ** contador)
            case 'F':
                decimal += 15 * (base ** contador)
            case _:
                decimal += int(bit) * (base ** contador)
        #disminuimos el contador (ya que vamos de izquierda a derecha).
        contador -= 1
    
    return decimal

#---------Modalidades y menu-------------------------
#creamos una lista que almacene los valores de codigos de accesos generados.
codigosAccesoBin = []
codigosAccesoOctal = []
codigosAccesoHexa = []
while(True):
    #Creamos el menu inicial
    print("==========================================\n"
          "|   Bienvenido al desafio de ByteMaster  |\n"
          "|           Seleccione Modo              |\n"
          "==========================================\n"
          "    (1) Generador de codigos de acceso    \n"
          "    (2) Desafio de descifrado              \n"
          "    (3) Salir                             \n")
    opcion = input('Ingrese su opcion: ')

    #OPCION 1: Generador de codigos de acceso.
    if opcion == '1':
        #preguntamos que tipo de codigo de acceso quiere crear.
        print("*************************************\n"
              "|   Seleccione el tipo de sistema   |\n"
              "|           De seguridad            |\n"
              "*************************************\n"
              "    (1)Firewall basico (binario)     \n"
              "    (2)Servidores Unix(Octal)        \n"
              "    (3)Direccion de memoria(hexa)    \n")
        opcion_2 = input('Ingrese su opcion: ')

        #creamos un valor random binario.
        if opcion_2 == '1':
            #numero random de 1 a 63 en binario
            numero_random = random(1, 63)
            bin = transformadorBinario(numero_random)
            #guardamos el codigo de acceso en  nuestro almacen de llaves
            codigosAccesoBin.append(bin)
            #imprimimos el valor binario
            print(f"Se a generado la siguiente clave en binario: {bin}\n")

        #Creamos un valor random octal
        elif opcion_2 == '2':
            #numero random de 1 a 511 en Octal
            numero_random = random(1, 511)
            octal = TransformadorOctal(numero_random)
            #guardamos el codigo de acceso en  nuestro almacen de llaves
            codigosAccesoOctal.append(octal)
            #imprimimos el valor octal
            print(f"Se a generado la siguiente clave en octal: {octal}\n")
        
        #creamos un valor random hexadecimal
        elif opcion_2 == '3':
            #numero random de 1 a 4095 en hexadecimal
            numero_random = random(1, 4095)
            hexa = transformadorHexa(numero_random)
            #guardamos el codigo de acceso en  nuestro almacen de llaves
            codigosAccesoHexa.append(hexa)
            #imprimimos el valor hexadecimal
            print(f"Se a generado la siguiente clave en hexadecimal: {hexa}\n")
        #Caso de entrada no disponible
        else:
            print("Entrada incorrecta, volviendo al menu...\n")
    
    #Opcion 2: Desafio de descifrado
    elif opcion == '2':
        print("*************************************\n"
              "|     MODO Desafio de descifrado    |\n"
              "|  Seleccione el modo de dificultad |\n"
              "*************************************\n"
              "    (1)Firewall basico (binario)     \n"
              "    (2)Servidores Unix(Octal)        \n"
              "    (3)Direccion de memoria(hexa)    \n")
        opcion_2 = input('Ingrese su opcion: ')

        #opcion binario:
        if opcion_2 == '1' :
            #verificamos si hay codigos de acceso binario
            if len(codigosAccesoBin) == 0:
                print("No existen codigos de acceso binario...\n"
                      "Volviendo al menu inicial...\n")
            #Como hay codigos, enviamos el desafio
            else:
                codigo = codigosAccesoBin.pop(0)
                print(f"Numero a descifrar (base binaria): {codigo} \n")
                #creamos  una bandera para crear un subciclo de juego
                flag = True
                while(flag):
                    respuesta = input("Escribe tu respuesta: ")
                    #verificamos si la respuesta es correcta
                    if int(respuesta) == desencriptador(codigo, 2):
                        print("Felicidades!!! resolviste el problema \n"
                              "Tienes lo necesario para subir de nivel!\n" \
                              "volviendo al menu...\n")
                        
                        #Salimos de sub-bucle
                        flag = False
                    #Respuesta incorrecta
                    else:
                        print("Respuesta incorrecta, prueba de nuevo...\n")

        #opcion Octal:
        elif opcion_2 == '2' :
            #verificamos si hay codigos de acceso Octal
            if len(codigosAccesoOctal) == 0:
                print("No existen codigos de acceso Octal...\n"
                      "Volviendo al menu inicial...\n")
            #Como hay codigos, enviamos el desafio
            else:
                codigo = codigosAccesoOctal.pop(0)
                print(f"Numero a descifrar (base Octal): {codigo} \n")
                #creamos  una bandera para crear un subciclo de juego
                flag = True
                while(flag):
                    respuesta = input("Escribe tu respuesta: ")
                    #verificamos si la respuesta es correcta
                    if int(respuesta) == desencriptador(codigo, 8):
                        print("Felicidades!!! resolviste el problema \n"
                              "Tienes lo necesario para subir de nivel!\n" \
                              "volviendo al menu...\n")
                        
                        #Salimos de sub-bucle
                        flag = False
                    #Respuesta incorrecta
                    else:
                        print("Respuesta incorrecta, prueba de nuevo...\n")
        
        #opcion hexadecimal:
        elif opcion_2 == '3' :
            #verificamos si hay codigos de acceso hexadecimal
            if len(codigosAccesoHexa) == 0:
                print("No existen codigos de acceso hexadecimal...\n"
                      "Volviendo al menu inicial...\n")
            #Como hay codigos, enviamos el desafio
            else:
                codigo = codigosAccesoHexa.pop(0)
                print(f"Numero a descifrar (base Hexadecimal): {codigo} \n")
                #creamos  una bandera para crear un subciclo de juego
                flag = True
                while(flag):
                    respuesta = input("Escribe tu respuesta: ")
                    #verificamos si la respuesta es correcta
                    if int(respuesta) == desencriptador(codigo, 16):
                        print("Felicidades!!! resolviste el problema \n"
                              "Tienes lo necesario para subir de nivel!\n" \
                              "volviendo al menu...\n")
                        
                        #Salimos de sub-bucle
                        flag = False
                    #Respuesta incorrecta
                    else:
                        print("Respuesta incorrecta, prueba de nuevo...\n")

        #opcion de respuesta incorrecta
        else:
            print("esa opcion no es valida, volviendo al menu...")
    
    #Opcion de salida
    elif opcion == '3':
        print("Saliendo...")
        #salimos del bucle
        break

    #Opcion no valida
    else:
        print("opcion no valida")