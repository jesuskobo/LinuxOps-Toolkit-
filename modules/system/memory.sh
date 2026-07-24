#!/usr/bin/env bash
# LinuxOps Toolkit - Módulo de Memoria RAM

# Recoleccion de la informacion del sistema
memory_collect() {
    # 1. Capturar la salida de free -m una sola vez para evitar múltiples lecturas de disco
    local free_output=$(free -m)

    # 2. Extraer datos de la RAM (Línea 2)
    local total_mb=$(echo "$free_output" | awk 'NR==2 {print $2}')
    local used_mb=$(echo "$free_output" | awk 'NR==2 {print $3}')
    local available_mb=$(echo "$free_output" | awk 'NR==2 {print $7}')

    # Convertir a GB con 2 decimales usando awk (más rápido y seguro que bc)
    local total_gb=$(awk -v t="$total_mb" 'BEGIN {printf "%.2f", t/1024}')
    local usage_gb=$(awk -v u="$used_mb" 'BEGIN {printf "%.2f", u/1024}')
    local available_gb=$(awk -v a="$available_mb" 'BEGIN {printf "%.2f", a/1024}')
    
    # 3. Calcular porcentaje de uso real (Métrica limpia: used / total)
    local usage_por=$(( (total_mb - available_mb) * 100 / total_mb )) 

    # 4. MEMORIA SWAP (Línea 3)
    # Extraemos columna 2 (Total) y columna 3 (Usada)
    local swap_total=$(echo "$free_output" | awk 'NR==3 {printf "%.2f", $2 / 1024}') 
    local swap_used=$(echo "$free_output" | awk 'NR==3 {printf "%.2f", $3 / 1024}') 

    # Formato corregido: Usada / Total
    local swap="${swap_used}/${swap_total}"

    # 5. Retornar datos limpios (Separados por pipe '|' SIN espacios internos corruptos)
    echo "${total_gb}|${usage_gb}|${available_gb}|${usage_por}|${swap}"
}

# Evaluarla y pasarla limpia al render
memory_evaluate() {
    local row_data
    row_data=$(memory_collect)

    # Descomponer los campos delimitados por pipe
    local memory_total memory_usage memory_available memory_porcentage memory_swaps
    IFS='|' read -r memory_total memory_usage memory_available memory_porcentage memory_swaps <<< "$row_data"


    # Determinar estado según umbrales
    local status="OK"

    if [ "$memory_porcentage" -ge "$MEM_CRIT_THRESHOLD" ]; then
        status="CRITICAL"
        log_error "Uso critico de Memoria RAM: $memory_porcentage%"

    elif [ "$memory_porcentage" -ge "$MEM_WARN_THRESHOLD" ]; then
        status="WARNING"
        log_warn "Uso de memoria elevado $memory_porcentage%"

    fi
    
    render_memory_screen "$memory_total" "$memory_usage" "$memory_available" "$memory_porcentage" "$memory_swaps" "$status" "$MEM_REC" # MEM_REC viene de recommendations.conf

}
