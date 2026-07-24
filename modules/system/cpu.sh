#!/usr/bin/env bash
# LinuxOps Toolkit - Módulo de CPU

cpu_collect() {
    # 1. Modelo del procesador
    local model
    model=$(grep -m1 "model name" /proc/cpuinfo | awk -F: '{print $2}' | xargs)

    # Si el método 1 falló (quedó vacío), intentamos con el comando 'lscpu'
    if [ -z "$model" ]; then
        model=$(lscpu | grep "Model name:" | awk -F: '{print $2}' | xargs)
    fi

    #Si ambos fallaron, asignamos un texto seguro por defecto
    if [ -z "$model" ]; then
        model="Desconocido / Genérico"
    fi

    # 2. Número de núcleos
    local cores
    cores=$(nproc)

    # 3. Load Average (1m, 5m, 15m)
    local load_avg
    load_avg=$(uptime | awk -F'load average:' '{print $2}' | xargs)

    # 4. Porcentaje de uso entero
    local usage
    usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | cut -d. -f1)

    echo "${model}|${cores}|${load_avg}|${usage}"
}

cpu_evaluate() {
    local raw_data
    raw_data=$(cpu_collect)

    # Descomponer los campos delimitados por pipe
    local cpu_model cpu_cores cpu_load cpu_usage
    IFS='|' read -r cpu_model cpu_cores cpu_load cpu_usage <<< "$raw_data"

    # Determinar estado según umbrales
    local status="OK"
    if [ "$cpu_usage" -ge "$CPU_CRIT_THRESHOLD" ]; then
        status="CRITICAL"
        log_error "Uso crítico de CPU: ${cpu_usage}%"
    elif [ "$cpu_usage" -ge "$CPU_WARN_THRESHOLD" ]; then
        status="WARNING"
        log_warning "Uso elevado de CPU: ${cpu_usage}%"
    fi

    # Renderizar pantalla formateada
    render_cpu_screen "$cpu_model" "$cpu_cores" "$cpu_load" "$cpu_usage" "$status" "$CPU_REC"
}