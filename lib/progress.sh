#!/usr/bin/env bash
# LinuxOps Toolkit  - Entrega barra de progreso

bar_progress_ascii(){
    # Generar la barra de progreso ASCII
    local bar_length="$1" # Definir ancho de la barra por lo general poner 20 bloques
    ## Asegura un entero limpio: maneja vacíos, remueve decimales (. o ,) y quita símbolos como %
    local usage=$(echo "${2:-0}" | sed 's/[.,].*//' | tr -dc '0-9') # Uso actual de: (Ram, cpu, disco, etc) 
    
    local filled=$(( usage * bar_length / 100 )) #calculo para ver que bloques desben estar llenos
    local empty=$(( bar_length - filled )) #Cálculo de la porción vacía
    local bar=""

    for ((i=0; i<filled; i++)); do bar="${bar}█"; done #concatena de manera iterativa el caracter de bloque sólido (█) tantas veces como indique la variable $filled.
    for ((i=0; i<empty; i++)); do bar="${bar}░"; done #ejecuta inmediatamente después para rellenar los espacios restantes con el caracter sombreado claro (░) tantas veces como indique la variable $empty.

    printf "$bar"
}