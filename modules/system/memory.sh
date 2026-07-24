#!/usr/bin/env bash
# LinuxOps Toolkit - Módulo de Memoria RAM

memory_collect() {
    # 1. Obtener valores crudos reales directamente desde el Kernel (en KB)
    local total_kb=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
    
    # Obtener los KB usados y disponibles desde free
    local usage_kb=$(free | awk 'NR==2 {print $3}')
    local available_kb=$(free | awk 'NR==2 {print $7}')

    # 2. Convertir los valores a GB con decimales usando bc
    local total_gb=$(echo "scale=2; $total_kb / 1024 / 1024" | bc)
    local usage_gb=$(echo "scale=2; $usage_kb / 1024 / 1024" | bc)
    local available_gb=$(echo "scale=2; $available_kb / 1024 / 1024" | bc)

    # 3. CORRECCIÓN DEL PORCENTAJE:
    # Multiplicamos por 100 primero y dejamos que bc calcule el entero sin decimales (scale=0)
    local usage_por=$(echo "scale=0; ($usage_kb * 100) / $total_kb" | bc)

    # 4. MEMORIA SWAP
    # pendiente sacar total memoria swap y total usada

    # 5. Retornar los datos limpios separados por espacios
    echo "$total_gb" "$usage_gb" "$available_gb" "$usage_por"
}

memory_collect