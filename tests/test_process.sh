#!/usr/bin/env bash
# LinuxOps Toolkit - Módulo de procesos

test_process_collect() {
    # 1. Consulta única de todos los procesos del sistema.
    local consult_process
    consult_process=$(ps -eo pid,%cpu,%mem,comm,stat --sort=-%cpu)

    # 2. Obtiene los tres procesos con mayor consumo de CPU.
    # Formato: PID CPU% COMANDO
    local top_cpu
    top_cpu=$(echo "$consult_process" |awk 'NR!=1 {print $1, $2, $4}' |head -3|xargs)

    # 3. Obtiene los tres procesos con mayor consumo de memoria RAM.
    # Formato: PID MEM% COMANDO
    local top_mem
    top_mem=$(echo "$consult_process" | LC_NUMERIC=C sort -k3,3rn |awk 'NR!=1 {print $1, $3, $4}' |head -3|xargs)

    # 4. Cuenta la cantidad de procesos en estado Zombie (Z).
    local z_process
    z_process=$(echo "$consult_process" | awk 'NR!=1 && $5 ~ /^Z/ {print $5}' |wc -l)

    # 5. Cuenta los procesos activos.
    # Se excluyen procesos Zombie (Z) y Stopped (T).
    local total_process
    total_process=$(echo "$consult_process" | awk 'NR!=1 && $5 !~ /^[ZT]/ {print $5}' |wc -l)

    # 6. Devuelve todas las métricas separadas por '|'
    echo "${top_cpu}|${top_mem}|${z_process}|${total_process}"

}

test_process_evaluate() {
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
    local zombie_recommendation zombie_recommendation_msg
    zombie_recommendation=$(get_recommendation "$z_code")
    zombie_recommendation_msg=$(get_status_message "$z_code")
    local s_zombie_render="$z_status|$zombie_recommendation"

    # -------------------------------------------------------------------------
    # Salida silenciosa (consumida por la auditoría ejecutiva)
    # -------------------------------------------------------------------------
    if [ "$1" == "--silent" ] || [ "$1" == "-s" ];then
        echo "$z_status|${zombie_recommendation_msg}"
        return 0
    fi

    # -------------------------------------------------------------------------
    #  Evaluación de consumo de CPU
    # -------------------------------------------------------------------------
    local c_status="OK"
    local c_code="NONE"

    local cpu_high=$(echo "$process_cpu" |awk '{print int($2)}' | bc) # COnvertir a decimales y tomar el primer proceso de cpu
    cpu_high="${cpu_high:-0}"
    
    c_code=$(evaluate_threshold \
        "$cpu_high" \
        "$PROCESS_WARN_CPU_THRESHOLD" \
        "$PROCESS_CRIT_CPU_THRESHOLD" \
        "PROCESS_CPU_WARNING" \
        "PROCESS_CPU_CRITICAL")

    case "$c_code" in
        PROCESS_CPU_WARNING)
            c_status="WARNING"
            log_warn "$(get_status_message "$c_code"). Actual: $cpu_high"
        ;;

        PROCESS_CPU_CRITICAL)
            c_status="CRITICAL"
            log_error "$(get_status_message "$c_code"). Actual: $cpu_high"
        ;;
        
    esac

    # Entregas status renderizado
    local cpu_recommendation cpu_recommendation_msg
    cpu_recommendation=$(get_recommendation "$c_code")
    cpu_recommendation_msg=$(get_status_message "$c_code")
    local s_cpu_render="$c_status|$cpu_recommendation"

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
    local mem_recommendation mem_recommendation_msg
    mem_recommendation=$(get_recommendation "$m_code")
    mem_recommendation_msg=$(get_status_message "$m_code")
    local s_mem_render="$m_status|$mem_recommendation"

    # Renderizado del modulo
    render_process_screen "$process_cpu" "$process_mem" "$process_zombie" "$process_total" "$s_cpu_render" "$s_zombie_render" "$s_mem_render"
}
 
evaluate_threshold() {
    local value="$1"        # Valor a evaluar.
    local warn="$2"         # Umbral para estado WARNING.
    local crit="$3"         # Umbral para estado CRITICAL.
    local warn_code="$4"    # Código a devolver si el valor supera WARNING.
    local crit_code="$5"    # Código a devolver si el valor supera CRITICAL.

    # value=30 # Eliminar valor fijo utilizado durante pruebas.

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