#include <stdio.h>
#include <string.h>
#include <ctype.h>

// los valores necesarios, se me ocurrio tarde usar lower o como se escriba
const char especial[] = "!@#$%&*+";
const char mayus[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
const char minus[] = "abcdefghijklmnopqrstuvwxyz";
const char num[] = "0123456789";


int capa1(const char* key) {
    int mayusculas = 0;
    int minusculas = 0;
    int numeros = 0;
    int especiales = 0;
    //cuenta cuantas mayusculas, minusculas, numeros y caracteres esoecuakes hay
    for (int i = 0; i < 16; i++) {
        char c = key[i];

        if (strchr(mayus, c) != NULL) {
                mayusculas++;
        } else if (strchr(minus, c) != NULL) {
                minusculas++;
        } else if (strchr(num, c) != NULL) {
                numeros++;
        } else {
            if (strchr(especial, c) != NULL) {
                especiales++;
            } else {
                return 0;
            }
        }
    }
    //retorna solo si hay 4 de cada cosa
    return (mayusculas == 4 && minusculas == 4 && numeros == 4 && especiales == 4);
}

//comprueba que sean impares, si 3 o mas lo son retorna
int capa2(const char* key) {
    int bloques_impares = 0;
    for (int i = 0; i < 16; i += 4) {
        int checksum = 0;

        for (int j = 0; j < 4; j++) {
            checksum += (int)key[i + j];
        }

        if (checksum % 2 != 0) {
            bloques_impares++;
        }
    }
    return (bloques_impares >= 3);
}

//prueba el hash pedido
int capa3(const char* key) {

    unsigned int hash = 0; 

    for (int i = 0; i < 16; i++) {

        hash = (hash * 31 + (unsigned int)key[i]) % 65536;
    }
    return (hash > 10000);
}


int main() {
    

    printf("ingrese la clave a probar m: ");
    char clave [17];
    scanf("%s", clave);

    if (strlen(clave) != 16) {
        printf("ERROR: La clave debe tener exactamente 16 caracteres.\n");
        return 1;
    }

    if (!capa1(clave)) {
        printf("CLAVE RECHAZADA\n");
        printf("Capa fallida: 1 (ANALISIS DE COMPOSICIN)\n"); 
        return 0;
    }

    
    if (!capa2(clave)) {
        printf("CLAVE RECHAZADA\n");
        printf("Capa fallida: 2 (PARIDAD POSICIONAL)\n"); 
        return 0;
    }

    
    if (!capa3(clave)) {
        printf("CLAVE RECHAZADA\n");
        printf("Capa fallida: 3(HASH DE VERIFICACION)\n"); 
        return 0;
    }

    printf("CLAVE ACEPTADA\n");
    return 0;
}