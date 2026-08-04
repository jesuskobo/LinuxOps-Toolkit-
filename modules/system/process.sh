#!/usr/bin/env bash
# LinuxOps Toolkit - Módulo de procesos

process_collect() {
    # Consulta única de todos los procesos del sistema.
    local consult_process
    consult_process=$(ps -eo pid,%cpu,%mem,comm,stat --sort=-%cpu)

    # 1. Obtiene los tres procesos con mayor consumo de CPU.
    # Formato: PID CPU% COMANDO
    local top_cpu
    top_cpu=$(echo "$consult_process" |awk 'NR!=1 {print $1, $2, $4}' |head -3|xargs)

    # 2. Obtiene los tres procesos con mayor consumo de memoria RAM.
    # Formato: PID MEM% COMANDO
    local top_mem
    top_mem=$(echo "$consult_process" | LC_NUMERIC=C sort -k3,3rn |awk 'NR!=1 {print $1, $3, $4}' |head -3|xargs)

    # 3. Cuenta la cantidad de procesos en estado Zombie (Z).
    local z_process
    z_process=$(echo "$consult_process" | awk 'NR!=1 && $5 ~ /^Z/ {print $5}' |wc -l)

    # 4. Cuenta los procesos activos.
    # Se excluyen procesos Zombie (Z) y Stopped (T).
    local total_process
    total_process=$(echo "$consult_process" | awk 'NR!=1 && $5 !~ /^[ZT]/ {print $5}' |wc -l)

    # 5. Devuelve todas las métricas separadas por '|'
    echo "${top_cpu}|${top_mem}|${z_process}|${total_process}"

}

process_evaluate() {
    # =======================
    # Recolección de métricas
    # =======================
    local raw_data
    raw_data=$(process_collect)

    # Descomponer datos delimitados por pipe |
    local process_cpu process_mem process_zombie process_total
    IFS='|' read -r process_cpu process_mem process_zombie process_total <<< "$raw_data"

    
    # -------------------------------------------------------------------------
    # Evaluación de procesos Zombie
    # -------------------------------------------------------------------------
    # status por defecto
    local z_status="OK"
    local z_code="NONE"

    # LLmar a la funcion thershold para que evalue 
    z_code=$(evaluate_threshold \
        "$process_zombie" \
        "$PROCESS_WARN_ZOMBIE_THRESHOLD" \
        "$PROCESS_CRIT_ZOMBIE_THRESHOLD" \
        "PROCESS_ZOMBIE_WARNING" \
        "PROCESS_ZOMBIE_CRITICAL")

    case "$z_code" in
        PROCESS_ZOMBIE_WARNING)
            z_status="WARNING"
            log_warn "$(get_status_message "$z_code"). Actual: $process_zombie"
        ;;

        PROCESS_ZOMBIE_CRITICAL)
            z_status="CRITICAL"
            log_error "$(get_status_message "$z_code"). Actual: $process_zombie"
        ;;
        
    esac

    # Obtener recomendación detallada segun codigo enviado Y Obtener recomendacion corta solo mensaje
    local z_recommendation z_recommendation_msg
    z_recommendation=$(get_recommendation "$z_code") # por si se quiere agregar la recomendacion completa
    z_recommendation_msg=$(get_status_message "$z_code")

    # -------------------------------------------------------------------------
    #  Evaluación de consumo de CPU
    # -------------------------------------------------------------------------
    local cpu_status="OK"
    local cpu_code="NONE"

    local cpu_high=$(echo "$process_cpu" |awk '{print int($2)}' | bc) # COnvertir a decimales y tomar el primer proceso de cpu
    cpu_high="${cpu_high:-0}"
    
    cpu_code=$(evaluate_threshold \
        "$cpu_high" \
        "$PROCESS_WARN_CPU_THRESHOLD" \
        "$PROCESS_CRIT_CPU_THRESHOLD" \
        "PROCESS_CPU_WARNING" \
        "PROCESS_CPU_CRITICAL")

    case "$cpu_code" in
        PROCESS_CPU_WARNING)
            cpu_status="WARNING"
            log_warn "$(get_status_message "$cpu_code"). Actual: $cpu_high"
        ;;

        PROCESS_CPU_CRITICAL)
            cpu_status="CRITICAL"
            log_error "$(get_status_message "$cpu_code"). Actual: $cpu_high"
        ;;
        
    esac

    # Entregas status renderizado
    local cpu_recommendation cpu_recommendation_msg
    cpu_recommendation=$(get_recommendation "$cpu_code") # por si se quiere agregar la recomendacion completa
    cpu_recommendation_msg=$(get_status_message "$cpu_code")

    # -------------------------------------------------------------------------
    # Evaluación de consumo de Memoria RAM
    # -------------------------------------------------------------------------
    local m_status="OK"
    local m_code="NONE"

    local mem_high=$(echo "$process_mem" |awk '{print int($2)}' | bc) # COnvertir a decimales y tomar el primer proceso de memoria
    
    m_code=$(evaluate_threshold \
        "$mem_high" \
        "$PROCESS_WARN_MEM_THRESHOLD" \
        "$PROCESS_CRIT_MEM_THRESHOLD" \
        "PROCESS_MEM_WARNING" \
        "PROCESS_MEM_CRITICAL")

    case "$m_code" in
        PROCESS_MEM_WARNING)
            m_status="WARNING"
            log_warn "$(get_status_message "$m_code"). Actual: $mem_high"
        ;;

        PROCESS_MEM_CRITICAL)
            m_status="CRITICAL"
            log_error "$(get_status_message "$m_code"). Actual: $mem_high"
        ;;
        
    esac

    # Entregas status renderizado
    local mem_recommendation m_recommendation_msg
    mem_recommendation=$(get_recommendation "$m_code") # por si se quiere agregar la recomendacion completa
    m_recommendation_msg=$(get_status_message "$m_code")

    # Renderizado del modulo delimitado por pipe |
    echo "${process_cpu}|${process_mem}|${process_zombie}|${process_total}|${z_status}|${z_recommendation_msg}|${z_code}|${cpu_status}|${cpu_recommendation_msg}|${cpu_code}|${m_status}|${m_recommendation_msg}|${m_code}"
}
 
evaluate_threshold() {
    local value="$1"        # Valor a evaluar.
    local warn="$2"         # Umbral para estado WARNING.
    local crit="$3"         # Umbral para estado CRITICAL.
    local warn_code="$4"    # Código a devolver si el valor supera WARNING.
    local crit_code="$5"    # Código a devolver si el valor supera CRITICAL.

    # value=100 # Eliminar valor fijo utilizado durante pruebas.

    # Si valor >= umbral crítico.
    if (( value >= crit )); then
        echo "$crit_code"

    # Si valor >= umbral warning.
    elif (( value >= warn )); then
        echo "$warn_code"

    # Si el valor se encuentra dentro de los límites normales.
    else
        echo "NONE"
    fi

}