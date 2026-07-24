#!/usr/bin/env bash
# LinuxOps Toolkit 

render_cpu_screen() {
    local model="$1"
    local cores="$2"
    local load="$3"
    local usage="$4"
    local status="$5"
    local rec="$6"

    # Seleccionar color según estado
    local status_color="${GREEN}"
    if [ "$status" = "WARNING" ]; then
        status_color="${YELLOW}"
    elif [ "$status" = "CRITICAL" ]; then
        status_color="${RED}"
    fi

    # Generar la barra de progreso ASCII
    local bar_length=20 # definir ancho de la barra de 20 bloques
    local filled=$(( usage * bar_length / 100 )) #calculo para ver que bloques desben estar llenos
    local empty=$(( bar_length - filled )) #Cálculo de la porción vacía
    local bar=""

    for ((i=0; i<filled; i++)); do bar="${bar}█"; done #concatena de manera iterativa el caracter de bloque sólido (█) tantas veces como indique la variable $filled.
    for ((i=0; i<empty; i++)); do bar="${bar}░"; done #ejecuta inmediatamente después para rellenar los espacios restantes con el caracter sombreado claro (░) tantas veces como indique la variable $empty.

    # Imprimir pantalla maquetada
    printf '====================================================================\n'
    printf ' RESULTADO: Uso actual de CPU\n'
    printf '====================================================================\n\n'
    printf ' Modelo:       %s\n' "$model"
    printf ' Núcleos:      %s\n' "$cores"
    printf ' Carga Media:  %s\n' "$load"
    printf ' Uso Actual:   [%b%s%b] %b%s%%%b (Estado: %b%s%b)\n\n' \
        "$status_color" "$bar" "${NC}" \
        "$status_color" "$usage" "${NC}" \
        "$status_color" "$status" "${NC}"

    if [ "$status" != "OK" ] && [ -n "$rec" ]; then
        printf ' %b Recomendación: %s%b\n\n' "${YELLOW}" "$rec" "${NC}"
    fi

    printf '====================================================================\n'
}