#!/usr/bin/env bash
# LinuxOps Toolkit - Módulo de procesos

process_collect() {
    # 1. Consulta General de procesos
    local consult_process
    consult_process=$(ps -eo pid,%cpu,%mem,comm,stat --sort=-%cpu)

    # 2. Consulta de cpu segun proceso general (pid, cpu, comm)
    local top_cpu
    top_cpu=$(echo "$consult_process" |awk 'NR!=1 {print $1, $2, $4}' |head -3|xargs)

    # 3. Consulta de memoria segun proceso general (pid, mem, comm)
    local top_mem
    top_mem=$(echo "$consult_process" | LC_NUMERIC=C sort -k3,3rn |awk 'NR!=1 {print $1, $3, $4}' |head -3|xargs)

    # 4. zombie procces
    local z_process
    z_process=$(echo "$consult_process" | awk 'NR!=1 && $5 ~ /^Z/ {print $5}' |wc -l)

    # 5. total procesos vivos o activos
    local total_process
    total_process=$(echo "$consult_process" | awk 'NR!=1 && $5 !~ /^[ZT]/ {print $5}' |wc -l)


    echo "${top_cpu}|${top_mem}|${z_process}|${total_process}"

}

process_evaluate() {
    local raw_data
    raw_data=$(process_collect)

    # Descomponer datos delimitados por pipe |
    local process_cpu process_mem process_zombie process_total
    IFS='|' read -r process_cpu process_mem process_zombie process_total <<< "$raw_data"

    # Retorna status de procesos con recomendaciones
    # Manejar estados de procesos zombie
    local warn_msg_zomb="Fuga de procesos zombies detectada"
    local crit_msg_zomb="Fuga de procesos zombies detectada. Riesgo de agotamiento de PIDs"
    local status_zombie
    status_zombie=$(procces_evaluate_status "$process_zombie" "$PROCESS_WARN_ZOMBIE_THRESHOLD" \
    "$PROCESS_CRIT_ZOMBIE_THRESHOLD" "$warn_msg_zomb" "$crit_msg_zomb" "$PROCESS_WARNING_ZOMBIE" "$PROCESS_CRITICAL_ZOMBIE")


    #Manejar estado procesos CPU altos
    local cpu_high=$(echo "$process_cpu" |awk '{print int($2)}' | bc) # COnvertir a decimales y tomar el primer proceso de cpu
    cpu_high="${cpu_high:-0}"
    local warn_msg_cpu="Alta carga detectada en proceso individual"
    local crit_msg_cpu="Saturación crítica de procesamiento"
    local status_cpu
    status_cpu=$(procces_evaluate_status "$cpu_high" "$PROCESS_WARN_CPU_THRESHOLD" \
    "$PROCESS_CRIT_CPU_THRESHOLD" "$warn_msg_cpu" "$crit_msg_cpu" "$PROCESS_WARNING_CPU" "$PROCESS_CRITICAL_CPU")

    # Manejar estado procesos RAM altos
    local mem_high=$(echo "$process_mem" |awk '{print int($2)}' | bc) # COnvertir a decimales y tomar el primer proceso de memoria
    local warn_msg_mem="Consumo elevado de memoria por proceso único. Posible fuga de memoria o carga masiva en caché"
    local crit_msg_mem="Agotamiento crítico de memoria física. Riesgo inminente de ejecución del OOM Killer"
    local status_mem
    status_mem=$(procces_evaluate_status "$mem_high" "$PROCESS_WARN_MEM_THRESHOLD"\
    "$PROCESS_CRIT_MEM_THRESHOLD" "$warn_msg_mem" "$crit_msg_mem" "$PROCESS_WARNING_MEM" "$PROCESS_CRITICAL_MEM")

    # --- CONTROL DE SALIDA PARALELA PARA manejar status ---
    if [ "$1" == "--silent" ] || [ "$1" == "-s" ];then
        echo "$status_zombie"
        return 0
    fi

    render_process_screen "$process_cpu" "$process_mem" "$process_zombie" "$process_total" "$status_cpu" "$status_zombie" "$status_mem"
}
 
procces_evaluate_status() {
    local valor="$1"             # Primer proceso con mas consumo
    local threshold_warn="$2"    # Umbral de warning
    local threshold_critic="$3"  # umbral de critico
    local msg_warn="$4"          # mensaje de log warnin
    local msg_crit="$5"          # mensaje de log critic     
    local msg_rec_warn="$6"      # Recomendaciónes para Warning
    local msg_rec_crit="$7"      # Recomendaciónes para Critical
    local info_extra="$8"        # informacion adicional en blanco por ahora

    if [ "$valor" -ge "$threshold_warn" ] && [ "$valor" -lt "$threshold_critic" ] ; then
        log_warn "$msg_warn. Actual: $valor% (Límite: >$threshold_warn%). $info_extra"
        echo "WARNING|$msg_rec_warn"
    
    elif [[ "$valor" -ge "$threshold_critic" ]]; then
        log_error "$msg_crit. Actual: $valor% (Límite: >$threshold_critic%). $info_extra"
        echo "CRITICAL|$msg_rec_crit"

    else
        echo "OK|N/A"

    fi

}