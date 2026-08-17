#!/usr/bin/env bash
# LinuxOps Toolkit  - Renderizado En Terminal

# 1. RENDER CPU
render_cpu_screen() {
    local raw_data
    raw_data="$1"

    # Descomponer datos enviados desde router.sh que viene con pipe |
    local cpu_model cpu_cores cpu_load cpu_usage cpu_status cpu_rec
    IFS='|' read -r cpu_model cpu_cores cpu_load cpu_usage cpu_status cpu_rec <<< "$raw_data"


    # Seleccionar color según estado
    local status_color="${GREEN}"
    if [ "$cpu_status" = "WARNING" ]; then
        status_color="${YELLOW}"
    elif [ "$cpu_status" = "CRITICAL" ]; then
        status_color="${RED}"
    fi

    # Generar la barra de progreso ASCII (funcion en utils.py)
    local bar
    bar=$(bar_progress_ascii 20 "$cpu_usage")

    # Imprimir pantalla maquetada
    printf '====================================================================\n'
    printf ' RESULTADO: Uso actual de CPU\n'
    printf '====================================================================\n\n'
    printf ' Modelo:       %s\n' "$cpu_model"
    printf ' Núcleos:      %s\n' "$cpu_cores"
    printf ' Carga Media:  %s\n' "$cpu_load"
    printf ' Uso Actual:   [%b%s%b] %b%s%%%b (Estado: %b%s%b)\n\n' \
        "$status_color" "$bar" "${NC}" \
        "$status_color" "$cpu_usage" "${NC}" \
        "$status_color" "$cpu_status" "${NC}"

    if [ "$cpu_status" != "OK" ] && [ -n "$cpu_rec" ]; then
        printf ' %b Recomendación: %s%b\n\n' "${YELLOW}" "$cpu_rec" "${NC}"
    fi

    printf '====================================================================\n'

}

# RENDER MEMORIA RAM

render_memory_screen(){
    local raw_data="$1"

    local m_total m_usage m_available m_usage_porcentage m_swap m_status m_rec
    IFS='|' read -r m_total m_usage m_available m_usage_porcentage m_swap m_status m_rec <<< "$raw_data"


    # Generar la barra de progreso ASCII (funcion en utils.py)
    local bar
    bar=$(bar_progress_ascii 20 "$m_usage_porcentage")

    # seleccionar color segun estado
    local status_color="${GREEN}"

    # Imprimir pantalla maquetada
    printf '====================================================================\n'
    printf ' RESULTADO: Estado de la Memoria RAM y SWAP\n'
    printf '====================================================================\n'
    printf ' Total RAM:                 %s\n' "$m_total GB"
    printf ' RAM Usada:                 %s\n' "$m_usage GB"
    printf ' RAM Disponible:            %s\n' "$m_available GB"
    printf ' SWAP Usada/SWAP Total:     %s\n\n' "$m_swap GB"
    printf ' Uso Actual Real:           [%b%s%b] %b%s%%%b (Estado: %b%s%b)\n\n' \
        "$status_color" "$bar" "${NC}" \
        "$status_color" "$m_usage_porcentage" "${NC}" \
        "$status_color" "$m_status" "${NC}"
    printf '%bNota: El "Uso Actual Real" excluye el caché del Kernel (buff/cache).%b\n' "${BOLD}" "${NC}"
    printf '====================================================================\n'

    # Condicional recomendaciones
    if [ "$m_status" != "OK" ] && [ -n "$m_rec" ]; then
        printf ' %b Recomendación: %s%b\n\n' "${YELLOW}" "$m_rec" "${NC}"
    fi
}

# 3. RENDER DE DISCO DURO

render_disk_screen() {
    local raw_data="$1"

    # descomponer los datos enviados desde router.sh que viene con pipe |
    local d_total d_usage d_available d_usage_porcentage d_inode_porcentage d_dir_heavy d_status d_rec
    IFS='|' read -r d_total d_usage d_available d_usage_porcentage d_inode_porcentage d_dir_heavy d_status d_rec <<< "$raw_data"

    ## Generar la barra de progreso ASCII (funcion en utils.py)
    local bar
    bar=$(bar_progress_ascii 20 "$d_usage_porcentage")

    # seleccionar color segun estado 
    local status_color="${GREEN}"

    # Imprimir pantalla maquetada
    printf '====================================================================\n'
    printf ' RESULTADO: Estado del Almacenamiento y Discos\n'
    printf '====================================================================\n\n'
    printf ' Partición (/):          %s | %s | %s \n' "$d_total GB Totales" "$d_usage GB Usados" "$d_available GB Libres"
    printf ' Uso de Disco:           [%b%s%b] %b%s%%%b (Estado: %b%s%b)\n' \
        "$status_color" "$bar" "${NC}" \
        "$status_color" "$d_usage_porcentage" "${NC}" \
        "$status_color" "$d_status" "${NC}"

    printf ' Inodos Usados:          %s\n' "$d_inode_porcentage"
    printf ' Directorio Pesado:      %s\n\n' "$d_dir_heavy"
    printf '====================================================================\n'

    # Condicional recomendaciones
    if [ "$d_status" != "OK" ] && [ -n "$d_rec" ]; then
        printf ' %b Recomendación: %s%b\n\n' "${YELLOW}" "$d_rec" "${NC}"
    fi
}


# 4. RENDER DE RED
render_network_screen() {
    local raw_data="$1"

    local n_network n_ip_local n_ip_public n_internet n_port_listen n_status n_rec
    IFS='|' read -r n_network n_ip_local n_ip_public n_internet n_port_listen n_status n_rec <<< "$raw_data"

    # Imprimir pantalla maquetada
    printf '=========================================================================\n'
    printf ' RESULTADO: Estado de la Red e Interfaces\n'
    printf '=========================================================================\n\n'
    printf ' Interfaz Principal:        %s\n' "$n_network"
    printf ' IP Local (IPv4):           %s\n' "$n_ip_local"
    printf ' IP Pública:                %s\n' "$n_ip_public"
    printf ' Conectividad:              %s %s\n\n' "[$n_internet]" "Estado: $n_status"
    printf ' Puertos Escuchando:        %s\n\n' "$n_port_listen (ss -tulnp)"
    printf '=========================================================================\n\n'

    if [ "$n_status" = "WARNING" ]; then
        printf '%b Recomendación: %s%b\n\n' "${YELLOW}" "${n_rec}" "${NC}"
    elif [ "$n_status" = "CRITICAL" ]; then
        printf '%b Recomendación: %s%b\n\n' "${YELLOW}" "${n_rec}" "${NC}"
    fi
}

# 5. RENDER DE PROCESOS

render_process_screen() {
    # p_ =process z_=zombie c_=cpu m_=memory
    local raw_data="$1"

    local procces_cpu procces_mem procces_zombie procces_total z_status z_recommendation_msg z_code cpu_status cpu_recommendation_msg cpu_code m_status m_recommendation_msg m_code
    IFS='|' read -r procces_cpu procces_mem procces_zombie procces_total z_status z_recommendation_msg z_code cpu_status cpu_recommendation_msg cpu_code m_status m_recommendation_msg m_code <<< "$raw_data"

    # Imprimir pantalla Maquetada
    local status_color="${GREEN}"

    printf '=========================================================================\n'
    printf 'RESULTADO: Monitoreo de Procesos y Estado del Kernel\n'
    printf '=========================================================================\n\n'
    printf 'Total Procesos Activos:        %s\n' "$procces_total"
    printf 'Procesos Zombie:               %s %s\n\n' "$procces_zombie" "(Estado: $z_status)"
    printf 'Top Procesos por CPU: \n'
    
    # llamar funcion para agregar procesos de forma escalable
    bucle_render "$procces_cpu" "CPU"

    printf '\nTop Procesos por MEMORIA: \n'

    bucle_render "$procces_mem" "RAM"

    printf '\n'
    printf '=========================================================================\n\n'
    
    # Recomendaciones si algún estado no es OK
    if [ "$z_status" != "OK" ] && [ "$z_recommendation_msg" != "N/A" ]; then
        printf '%bRecomendación Zombie: %s%b\n' "${YELLOW}" "$z_recommendation_msg" "${NC}"
    fi
    if [ "$cpu_status" != "OK" ] && [ "$cpu_recommendation_msg" != "N/A" ]; then
        printf '%bRecomendación CPU: %s%b\n' "${YELLOW}" "$cpu_recommendation_msg" "${NC}"
    fi
    if [ "$m_status" != "OK" ] && [ "$m_recommendation_msg" != "N/A" ];then
        printf '%bRecomendación RAM: %s%b\n\n' "${YELLOW}" "$m_recommendation_msg" "${NC}"
    fi
}

bucle_render() {
    local data="$1"
    local label="$2"
    
    # Convertir el string plano en un Array indexado de Bash
    read -r -a elements <<< "$data"
    local total=${#elements[@]} #Obtener el tamaño total de elementos dentro del array
    local contador=1

    for ((i=0; i<total; i+=3)); do
        local pid="${elements[i]}"
        local val="${elements[i+1]}"
        local comm="${elements[i+2]}"
        
        [[ -z "$pid" ]] && continue

        #Impresión con formato de rejilla fija (Alineación perfecta)
        printf '   %d. %-15s (PID: %-6s) - %s%% %s\n' "$contador" "$comm" "$pid" "$val" "$label"
        ((contador++))
    done
}

# 6. RENDER DE USUARIOS
#"$user_loggers" "$user_active_count" "$user_admin_count" "$user_uid_count" "$user_info_sessions" "$user_privileged" "$user_log_fail" "$status"
render_user_screen() {
    local raw_data="$1"

    local u_logger u_active_count u_admin_count u_uid_count u_info_sessions u_privileged u_log_fail status rec
    IFS='|' read -r u_logger u_active_count u_admin_count u_uid_count u_info_sessions u_privileged u_log_fail status rec <<< "$raw_data"

    # Descomponer elementos
    # 1. Descomponer variable u_logger para contar usuarios y entregar datos formateado o separados por ,
    local format_user=$(echo "$u_logger" |sed 's/;/, /')
    local contar_user=0; while read -r u; do ((contar_user++)); done < <(tr ';' '\n' <<< "$u_logger")

    # 2. Descomponer variable u_info_sessions para mostrar sesiones con saldo de lineas y poner encabezado
    local format_info_sesion=$(
    {
        printf "%-15s %-8s %-15s %-8s %-10s %-30s\n" \
            "USUARIO" "TTY" "DESDE(IP)" "DESDE" "INACTIVO" "COMANDO_ACTUAL"

        tr ';' '\n' <<< "$u_info_sessions"
    } | column -t
    )

    # cambia ; por saltos de lineas y coloca los encabezados
    local format_log_fail=$(
    {
        printf "%-5s %-4s %-8s %-15s %-20s %-35s\n" "MES" "DIA" "HORA" "IP" "USUARIO" "MOTIVO"

        while read -r mes dia hora ip usuario motivo; do
            printf "%-5s %-4s %-8s %-15s %-20s %-35s\n" "$mes" "$dia" "$hora" "$ip" "$usuario" "$motivo"
        done < <(tr ';' '\n' <<< "$u_log_fail")

    } | column -t
    )


    # Imprimir pantalla maquetada
    printf '=====================================================================================\n'
    printf 'RESULTADO: Auditoría de Usuarios y Sesiones del Sistema\n'
    printf '=====================================================================================\n\n'
    printf '[+] RESUMEN GENERAL:\n'
    printf '%s''-------------------------------------------------------------------------------------\n'
    printf 'Usuarios Logueados:        %s %s\n' "$contar_user" "($format_user)"
    printf 'Sesiones Activas:          %s\n' "$u_active_count (TTY/PTS en ejecución)"
    printf 'Usuarios Sudo/Wheel:       %s\n' "$u_admin_count usuarios con privilegios"
    printf 'Auditoría UID 0:           %s\n\n' "$u_uid_count Detectado"
    printf '[+] DETALLE DE SESIONES ACTIVAS:\n'
    printf '%s''-------------------------------------------------------------------------------------\n'
    printf '%s\n\n' "$format_info_sesion"
    printf '[+] USUARIOS CON PRIVILEGIOS DE ADMINISTRADOR (SUDO/WHEEL):\n'
    printf '%s''-------------------------------------------------------------------------------------\n'
    # Formatea salida con saltos de linea y numero de usuario
    contador_user_privi=1
    for usuario in ${u_privileged//;/ }; do
        printf '%s\n' "$contador_user_privi. $usuario"
        ((contador_user_privi++))
    done
    printf '\n[+] INTENTOS DE ACCESO FALLIDOS RECIENTES\n'
    printf '%s''-------------------------------------------------------------------------------------\n'
    printf '%s\n\n' "$format_log_fail"
    printf '=====================================================================================\n\n'

    # RECOMENDACIONES
    if [ "$status" != "OK" ] && [ "$rec" != "N/A" ];then
        printf '%bRecomendación: %s%b\n\n' "${YELLOW}" "$rec" "${NC}"
    fi
}


# 7. RENDER DE SYSINFO 
# "$sys_hostname" "$sys_so" "$sys_kernel" "$sys_arquit" "$sys_up_time" "$sys_entorno" "$status"
render_sysinfo_screen(){
    local raw_data="$1"

    local s_hostname s_so s_kernel s_aquitec s_up_time s_around status rec
    IFS='|' read -r s_hostname s_so s_kernel s_aquitec s_up_time s_around status rec <<< "$raw_data"
    
    # Imprimir pantalla maquetada
    printf '=========================================================================\n'
    printf 'RESULTADO: Información General del Sistema y Kernel\n'
    printf '=========================================================================\n\n'
    printf '[+] DATOS DEL HOST Y SISTEMA OPERATIVO\n'
    printf '%s''-------------------------------------------------------------------------\n'
    printf 'Hostname                   : %s\n' "$s_hostname"
    printf 'Sistema Operativo          : %s\n' "$s_so"
    printf 'Versión del Kernel         : %s\n' "$s_kernel"
    printf 'Arquitectura               : %s\n\n' "$s_aquitec"
    printf '[+] DATOS DEL HOST Y SISTEMA OPERATIVO\n'
    printf '%s''-------------------------------------------------------------------------\n'
    printf 'Uptime (Encendido)         : %s\n' "$s_up_time"
    printf 'Tipo de Entorno            : %s\n' "$s_around"
    printf 'Estado                     : %s\n\n' "$status"
    printf '=========================================================================\n\n'

    #Recomendaciones
    if [ "$status" != "OK" ] && [ "$rec" != "N/A" ]; then
        printf '%bRecomendación: %s%b\n\n' "${YELLOW}" "$rec" "${NC}"
    fi
}


# 8. RENDER DE full audit screen
# $base_score" "$global_status" "$count_ok" "$count_warn" "$count_crit"
render_full_audit_screen() {
    local raw_data_status="$1"
    local raw_data_rec="$2"
    local raw_data_rec_long="$3"

    # 1. Descomponer datos del status.
    local f_score_global f_global_status f_count_ok f_count_warn f_count_crit
    IFS='|' read -r f_score_global f_global_status f_count_ok f_count_warn f_count_crit <<< "$raw_data_status"

    # 2. Generar la barra de progreso ASCII (funcion en utils.py)
    local bar
    bar=$(bar_progress_ascii 20 "$f_score_global")

    # 3. Manejar colores de los status
    local status_color="${GREEN}"
    if [ "$f_global_status" == "CRITICAL" ]; then
        status_color="${RED}"
    elif [ "$f_global_status" == "WARNING" ]; then
        status_color="${YELLOW}"
    else
        status_color="${GREEN}"
    fi

    # 4. renderizar estado y recomendacion de (ram, disk, cpu etc)
    local format_audit_reco=$( 
    {
        
        while read -r line;do
            local subsistema estado hallazgo
            IFS='|' read -r subsistema estado hallazgo <<< "$line"

            printf "%-15s %-15s %-35s\n" "$subsistema" "$estado" "$hallazgo"

        done < <(tr ';' '\n' <<< "$raw_data_rec")
    }
    )

    # 5. Imprimir pantalla maquetada
    printf '=========================================================================\n'
    printf '        LINUXOPS TOOLKIT - AUDITORÍA EJECUTIVA DEL SISTEMA\n'
    printf '=========================================================================\n\n'
    printf '[+] HEALTH SCORE GLOBAL         : %b%s %s %s%b\n' "$status_color" "[$bar]" "$f_score_global %" "(Estado: $f_global_status)" "${NC}"
    printf '[+] RESUMEN DE SALUD            : %s | %s | %s\n\n' "$f_count_ok OK" "$f_count_warn WARNING" "$f_count_crit CRITICAL"
    printf '%s''-------------------------------------------------------------------------\n'
    printf "%-15s %-15s %-35s\n" "SUBSISTEMA" "ESTADO" "HALLAZGO_PRINCIPAL" 
    printf '%s''-------------------------------------------------------------------------\n'
    printf '%s\n' "$format_audit_reco"
    printf '=========================================================================\n'
    
    # 6. RECOMENDACIONES DE SUBSISTEMAS
    # bucle para recorrer cada linea de raw_data_rec_long y mostrar solo las recomendaciones que no sean de prioridad baja (LOW)
    local header_printed=false
    while read -r line;do

        [[ -z "$line" ]] && continue

        local priority module recommendation
        IFS='|' read -r priority module recommendation <<< "$line"
        
        # Omitir recomendaciones LOW
        [[ "$priority" == "🟢 [LOW]" ]] && continue

        # Imprimir encabezado una sola vez
        if [ "$header_printed" = false ]; then
            printf '\n\n[+] RECOMENDACIONES DE SUBSISTEMAS:\n'
            printf '%s\n' '-------------------------------------------------------------------------'
            printf "%-15s %-15s %-35s\n" "SUBSISTEMA" "MODULO" "RECOMENDACION"
            printf '%s\n' '-------------------------------------------------------------------------'

            header_printed=true
        fi

        printf '%b%-15s %-15s %s%b\n\n' "${YELLOW}" "$priority" "$module" "$recommendation" "${NC}"

    done < <(tr ';' '\n' <<<  "$raw_data_rec_long")
}

# 9. RENDER GESTION DE SERVICIO
# PID|user|status|cpu|memoria_ram|tiempo activo|tiempo caido
render_services_screen() {
    local raw_data="$1"
    # Descomponer datos enviados por pipe
    local service_name service_pid service_user service_status_run service_status_Authorization service_cpu service_memory service_time_up service_time_down
    IFS='|' read -r service_name service_pid service_user service_status_run service_status_Authorization service_cpu service_memory service_time_up service_time_down <<< "$raw_data"

    # escoger tiempo activo o inactivo
    local status_time
    if [ "$service_status_run" == "active" ];then
        status_time="$service_time_up"
    else
        status_time="$service_time_down"
    fi

    # si esta habilitado al iniciar
    local starting
    if [ "$service_status_Authorization" == "enabled" ];then
        starting="SI"
    else
        starting="NO"
    fi


    # renderizar en pantalla servicio
    printf '=========================================================================\n'
    printf '        LINUXOPS TOOLKIT - ADMIN > SERVICE > %s\n' "$service_name"
    printf '=========================================================================\n\n'
    printf 'ESTADO DE EJECUCION\n'
    printf 'Estado                  : %s\n' "$service_status_run"
    printf 'PID                     : %s\n' "$service_pid"
    printf 'CPU                     : %s\n' "$service_cpu"
    printf 'MEMORIA                 : %s\n' "$service_memory"
    printf 'UPTIME                  : %s\n\n' "$status_time"
    printf 'ARRANQUE AUTOMÁTICO\n'
    printf 'Al iniciar              : %s\n' "$starting"
    printf 'configuracion           : %s\n\n' "$service_status_Authorization"
    printf '%s''-------------------------------------------------------------------------\n'
    printf "DIAGNÓSTICO\n"
    printf '%s''-------------------------------------------------------------------------\n'


    printf '%s''-------------------------------------------------------------------------\n'
    printf "ACCIONES\n"
    printf '%s''-------------------------------------------------------------------------\n'
    printf '[1] Reiniciar           \n'
    printf '[2] Detener             \n'
    printf '[3] Recargar            \n'
    printf '[4] Ver logs            \n'
    printf '[5] Volver              \n'
    printf '=========================================================================\n'

}
