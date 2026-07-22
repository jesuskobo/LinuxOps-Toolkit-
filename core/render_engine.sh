#!/usr/bin/env bash
# LinuxOps Toolkit 

render_status() {
    local component="$1"
    local value="$2"
    local status="$3" #convertir a minusculas
    local recommendation="$4"

    # 1. Seleccionar color según el estado ($status)
    local status_color="${NC}"
    if [ "$status" == "OK" ]; then
        status_color="${GREEN}"
    elif [ "$status" = "WARNING" ]; then
        status_color="${YELLOW}"
    elif [ "$status" = "CRITICAL" ]; then
        status_color="${RED}"
    fi

    # 2. Imprimir en pantalla el reporte estandarizado
    printf '%s\n' "--------------------------------------------------"
    printf "[ %s ] Estado: %b%s%b\n" "$component" "$status_color" "$status" "${NC}"
    printf "Uso actual: %s\n" "$value"

    # 3. Mostrar recomendación solo si el estado es WARNING o CRITICAL
    if [ "$status" != "OK" ] && [ -n "$recommendation" ]; then
        printf "%s💡 Recomendación: %s%s\n" "${YELLOW}" "$recommendation" "${NC}"
    fi
    printf '%s\n' "--------------------------------------------------"

}