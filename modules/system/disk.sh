#!/usr/bin/env bash
# LinuxOps Toolkit - Módulo de Disco


# Recoleccion de la informacion del sistema
disk_collect() {
    local total_gb=$(df -BG --output=size / | awk 'NR==2' |sed 's/[A-Za-z]//g; s/ //g')   # total disco
    local usage=$(df -BG --output=used / | awk 'NR==2' |sed 's/[A-Za-z]//g; s/ //g')      # disco usado
    local available=$(df -BG --output=avail / | awk 'NR==2' |sed 's/[A-Za-z]//g; s/ //g') # disco disponible
    local usage_porc=$(df -BG --output=pcent / | awk 'NR==2' |sed 's/%//g; s/ //g')       # porcentaje de uso  
    local inode_porc=$(df --output=ipcent / |awk 'NR==2' |sed 's/%//g; s/ //g; s/-/0/g')  # porcentaje de inodos
    local top3=$(du -s /* 2>/dev/null | awk '{printf "%.2f GB\t%s\n", $1 / 1048576, $2}' | sort -rh |head -3) #top 3 carpetas mas pesadas
    local dir_heavy=$(echo "$top3" | awk '{printf "%s %s %s, ", $1, $2, $3}' | sed 's/, $//') #formater carpetas
    
    
    echo "${total_gb}|${usage}|${available}|${usage_porc}|${inode_porc}|${dir_heavy}"

}

disk_evaluate() {
    local raw_data
    raw_data=$(disk_collect)
    
    local disk_total disk_usage disk_available disk_usage_porc disk_inode_porc disk_dir_heavy
    IFS='|' read -r disk_total disk_usage disk_available disk_usage_porc disk_inode_porc disk_dir_heavy <<< "$raw_data"

    #determinar estado segun umbral
    local status="OK"
    if [ "$disk_usage_porc" -ge "$DISK_CRIT_THRESHOLD" ]; then
        status="CRITICAL"
        log_error "Uso crítico de Disco Duro: ${disk_usage_porc}%"
    elif [ "$disk_usage_porc" -ge "$DISK_WARN_THRESHOLD" ]; then
        status="WARNING"
        log_warn "Uso elevado de disco duro ${disk_usage_porc}%"
    fi

    render_disk_screen "$disk_total" "$disk_usage" "$disk_available" "$disk_usage_porc" "$disk_inode_porc" "$disk_dir_heavy" "$status" "$DISK_REC" # Disk viene de recommendations.conf
}
