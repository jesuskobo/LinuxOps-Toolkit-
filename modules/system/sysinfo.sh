#!/usr/bin/env bash
# LinuxOps Toolkit - Modulo identidad y estado del server


sysinfo_collect() {
    local s_hostname=$(hostname) # Nombre del host 
    local s_so=$(cat /etc/os-release |grep -i "^version=" |cut -d= -f2|tr -d '"') # version SO
    local s_kernel=$(uname -r) # kernel
    local s_arquit=$(uname -m) # tipo arquitectura 
    local s_up_time=$(uptime -p) # tiempo de uso

    #  Entorno escritorio y tipo de sesion
    local s_entorn=$({
        echo $XDG_CURRENT_DESKTOP
        echo $DESKTOP_SESSION|awk -F/ '{print $NF}'
    } | paste -sd ';'
    )

    # Servir datos mediante pipe
    echo "${s_hostname}|${s_so}|${s_kernel}|$s_arquit|${s_up_time}|${s_entorn}"
}

sysinfo_evaluate() {
    local raw_data
    raw_data=$(sysinfo_collect)

    # Descomponer datos enviados por el collect que viene con pipe
    local sys_hostname sys_so sys_kernel sys_arquit sys_up_time sys_around
    IFS='|' read -r sys_hostname sys_so sys_kernel sys_arquit sys_up_time sys_around <<< "$raw_data" 

    # Obtiene los segundos totales y extrae solo la parte entera
    local segundos=$(cut -d. -f1 /proc/uptime)
    # Obtiene los dias totales
    local days=$((segundos / 86400))

    # Manejo de log  y status
    local status="OK"
    if [ "$days" -ge "$SYS_WARN_UPTIME_180DAYS_THRESHOLD" ];then
        status="WARNING|$SYS_WARNING_UPTIME_180DAYS"
        log_warn "El sistema lleva encendido $days días (Más de 180 días)"
    else
        status="OK|N/A"
    fi

    # --- CONTROL DE SALIDA PARALELA PARA manejar status ---
    if [ "$1" == "--silent" ] || [ "$1" == "-s" ];then
        local status_clean=$(echo "$status" |cut -d'|' -f1)
        echo "$status_clean|$sys_hostname $sys_so"
        return 0
    fi

    render_sysinfo_screen "$sys_hostname" "$sys_so" "$sys_kernel" "$sys_arquit" "$sys_up_time" "$sys_around" "$status"
}