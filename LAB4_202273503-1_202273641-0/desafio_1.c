#include <stdio.h>
// Funcion encargada de obtener el numero de pasos de una secuencia de Collatz
int secCollatz(int pasos, int valor)
{
    //condicion de salida del bucle
    if(valor == 1)
    {
        return pasos;
    }
    else //De lo contrario avanzamos en el bucle
    {
        //verificación de paridad
        if(valor % 2 == 0)  // es par, asi que debemos usar n / 2
        {
            valor = valor / 2;
        }else               //es impar, asi que usamos 3n + 1
        {
            valor = 3*valor + 1;
        }
        //llamamos de nuevo a nuestra funcion
        return secCollatz(pasos + 1, valor);
    }
}

int main()
{
    //recibimos como entrada el numero de id a analizar (n va a estar entre 5 y 20)
    printf("ingrese la cantidad de id que habra: ");
    int n;
    scanf("%d", &n);
    //Recibimos todo los id y los guardamos en una lista
    int ids[n];
    for(int i = 0; i <  n; i++)
    {
        int id;
        scanf("%d", &id);
        ids[i] = id;
    }

    //ahora categorizamos e imprimimos cada id:
    for(int i = 0; i < n; i++)
    {
        printf("para el ID: %d\n", ids[i]);
        //calculamos el numero de pasos:
        int pasos_id = secCollatz(0, ids[i]);
        printf("    La cantidad de pasos obtenido es: %d\n", pasos_id);
        // vemos que categoria tiene:
        if(pasos_id < 20)
        {
            printf("  La categoria del miembro es: Peon\n");
        } else if (pasos_id < 50)
        {
            printf("  La categoria del miembro es: Informante\n");
        }
        else if (pasos_id < 100)
        {
            printf("  La categoria del miembro es: Operador\n");
        } else
        {
            printf("  La categoria del miembro es: Lider\n");
        }
        printf("------------------------------------\n");
    }
    return 0;
}   