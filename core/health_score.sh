#!/usr/bin/env bash
# LinuxOps Toolkit  - Motor de puntacion de los estados

calculate_health_score() {
    # Recibe 7 argumentos con la salida limpia de cada evaluate (ej: "OK", "WARNING", "CRITICAL")
    local statuses=("${@}")

    local base_score=100
    local penalty_warning=10
    local penalty_critical=25

    local count_ok=0
    local count_warn=0
    local count_crit=0

    # Realiza calculo para obtener estado
    for estado in "${statuses[@]}";do
        case "$estado" in
            "OK" | "ok")
                ((count_ok++))
                ;;
            "WARNING" | "warning")
                base_score=$((base_score - penalty_warning))
                ((count_warn++))
                ;;  
            "CRITICAL" | "critical")
                base_score=$((base_score - penalty_critical))
                ((count_crit++))
                ;;
        esac
    done

    # Normalizar status que no pase de 0
    if (( base_score < 0 )); then
        base_score=0
    fi

    # Determinar Estado Global del Servidor
    local global_status="OK"
    if (( count_crit > 0 )) || ((base_score < 70));then
        global_status="CRITICAL"

    elif (( count_warn > 0 )) || ((base_score < 90));then
        global_status="WARNING"

    else
        global_status="OK"

    fi

    # Renderizando status
    echo "${base_score}|${global_status}|${count_ok}|${count_warn}|${count_crit}"
}