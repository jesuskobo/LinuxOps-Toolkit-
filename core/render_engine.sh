#!/usr/bin/env bash
# LinuxOps Toolkit  - Renderizado En Terminal

# RENDER CPU
render_cpu_screen() {
    local model="$1"
    local cores="$2"
    local load="$3"
    local usage="$4"
    local status="$5"
    local rec="$6"


    # Seleccionar color según estado
    local status_color="${GREEN}"
    if [ "$status" = "WARNING" ]; then
        status_color="${YELLOW}"
    elif [ "$status" = "CRITICAL" ]; then
        status_color="${RED}"
    fi

    # Generar la barra de progreso ASCII (funcion en utils.py)
    local bar
    bar=$(bar_progress_ascii 20 "$usage")

    # Imprimir pantalla maquetada
    printf '====================================================================\n'
    printf ' RESULTADO: Uso actual de CPU\n'
    printf '====================================================================\n\n'
    printf ' Modelo:       %s\n' "$model"
    printf ' Núcleos:      %s\n' "$cores"
    printf ' Carga Media:  %s\n' "$load"
    printf ' Uso Actual:   [%b%s%b] %b%s%%%b (Estado: %b%s%b)\n\n' \
        "$status_color" "$bar" "${NC}" \
        "$status_color" "$usage" "${NC}" \
        "$status_color" "$status" "${NC}"

    if [ "$status" != "OK" ] && [ -n "$rec" ]; then
        printf ' %b Recomendación: %s%b\n\n' "${YELLOW}" "$rec" "${NC}"
    fi

    printf '====================================================================\n'
}

# RENDER MEMORIA RAM

render_memory_screen(){
    local total="$1"
    local usage="$2"
    local available="$3"
    local usage_porcentage="$4"
    local swap="$5"
    local status="$6"
    local rec="$7"


    # Generar la barra de progreso ASCII (funcion en utils.py)
    local bar
    bar=$(bar_progress_ascii 20 "$usage_porcentage")

    # seleccionar color segun estado
    local status_color="${GREEN}"

    # Imprimir pantalla maquetada
    printf '====================================================================\n'
    printf ' RESULTADO: Estado de la Memoria RAM y SWAP\n'
    printf '====================================================================\n'
    printf ' Total RAM:                 %s\n' "$total GB"
    printf ' RAM Usada:                 %s\n' "$usage GB"
    printf ' RAM Disponible:            %s\n' "$available GB"
    printf ' SWAP Usada/SWAP Total:     %s\n\n' "$swap GB"
    printf ' Uso Actual Real:           [%b%s%b] %b%s%%%b (Estado: %b%s%b)\n\n' \
        "$status_color" "$bar" "${NC}" \
        "$status_color" "$usage_porcentage" "${NC}" \
        "$status_color" "$status" "${NC}"
    printf '%bNota: El "Uso Actual Real" excluye el caché del Kernel (buff/cache).%b\n' "${BOLD}" "${NC}"
    printf '====================================================================\n'

    # Condicional recomendaciones
    if [ "$status" != "OK" ] && [ -n "$rec" ]; then
        printf ' %b Recomendación: %s%b\n\n' "${YELLOW}" "$rec" "${NC}"
    fi
}

# RENDER DE DISCO DURO

render_disk_screen() {
    local total="$1"
    local usage="$2"
    local available="$3"
    local usage_porcentage="$4"
    local inode_porcentage="$5"
    local dir_heavy=$6
    local status="$7"
    local rec="$8"

    ## Generar la barra de progreso ASCII (funcion en utils.py)
    local bar
    bar=$(bar_progress_ascii 20 "$usage_porcentage")

    # seleccionar color segun estado 
    local status_color="${GREEN}"

    # Imprimir pantalla maquetada
    printf '====================================================================\n'
    printf ' RESULTADO: Estado del Almacenamiento y Discos\n'
    printf '====================================================================\n\n'
    printf ' Partición (/):          %s | %s | %s \n' "$total GB Totales" "$usage GB Usados" "$available GB Libres"
    printf ' Uso de Disco:           [%b%s%b] %b%s%%%b (Estado: %b%s%b)\n' \
        "$status_color" "$bar" "${NC}" \
        "$status_color" "$usage_porcentage" "${NC}" \
        "$status_color" "$status" "${NC}"

    printf ' Inodos Usados:          %s\n' "$inode_porcentage"
    printf ' Directorio Pesado:      %s\n\n' "$dir_heavy"
    printf '====================================================================\n'

    # Condicional recomendaciones
    if [ "$status" != "OK" ] && [ -n "$rec" ]; then
        printf ' %b Recomendación: %s%b\n\n' "${YELLOW}" "$rec" "${NC}"
    fi
}


# RENDER DE RED
render_network_screen() {
    local network="$1"
    local ip_local="$2"
    local ip_public="$3"
    local internet="$4"
    local port_listen="$5"
    local status="$6"
    local rec="$7"

    # Imprimir pantalla maquetada
    printf '=========================================================================\n'
    printf ' RESULTADO: Estado de la Red e Interfaces\n'
    printf '=========================================================================\n\n'
    printf ' Interfaz Principal:        %s\n' "$network"
    printf ' IP Local (IPv4):           %s\n' "$ip_local"
    printf ' IP Pública:                %s\n' "$ip_public"
    printf ' Conectividad:              %s %s\n\n' "[$internet]" "Estado: $status"
    printf ' Puertos Escuchando:        %s\n\n' "$port_listen (ss -tulnp)"
    printf '=========================================================================\n\n'

    if [ "$status" = "WARNING" ]; then
        printf '%b Recomendación: %s%b\n\n' "${YELLOW}" "${rec}" "${NC}"
    elif [ "$status" = "CRITICAL" ]; then
        printf '%b Recomendación: %s%b\n\n' "${YELLOW}" "${rec}" "${NC}"
    fi
}

# RENDER DE PROCESOS

render_process_screen() {
    local p_cpu="$1"
    local p_mem="$2"
    local p_zombie="$3"
    local p_total="$4"
    local p_status_cpu="$5"
    local p_status_zom="$6"
    local p_status_mem="$7"

    # Descomponer datos delimitados por pipe | de memoria cpu
    local c_status c_rec z_status z_rec m_status m_rec
    IFS='|' read -r c_status c_rec <<< "$p_status_cpu"
    IFS='|' read -r z_status z_rec <<< "$p_status_zom"
    IFS='|' read -r m_status m_rec <<< "$p_status_mem"


    # Imprimir pantalla Maquetada
    local status_color="${GREEN}"

    printf '=========================================================================\n'
    printf 'RESULTADO: Monitoreo de Procesos y Estado del Kernel\n'
    printf '=========================================================================\n\n'
    printf 'Total Procesos Activos:        %s\n' "$p_total"
    printf 'Procesos Zombie:               %s %s\n\n' "$p_zombie" "(Estado: $z_status)"
    printf 'Top Procesos por CPU: \n'
    
    # llamar funcion para agregar procesos de forma escalable
    bucle_render "$p_cpu" "CPU"

    printf '\nTop Procesos por MEMORIA: \n'

    bucle_render "$p_mem" "RAM"

    printf '\n'
    printf '=========================================================================\n\n'
    
    # Recomendaciones si algún estado no es OK
    if [ "$z_status" != "OK" ] && [ "$z_rec" != "N/A" ]; then
        printf '%bRecomendación Zombie: %s%b\n' "${YELLOW}" "$z_rec" "${NC}"
    fi
    if [ "$c_status" != "OK" ] && [ "$c_rec" != "N/A" ]; then
        printf '%bRecomendación CPU: %s%b\n' "${YELLOW}" "$c_rec" "${NC}"
    fi
    if [ "$m_status" != "OK" ] && [ "$z_status" != "N/A" ];then
        printf '%bRecomendación RAM: %s%b\n\n' "${YELLOW}" "$m_rec" "${NC}"
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

# RENDER DE USUARIOS
#"$user_loggers" "$user_active_count" "$user_admin_count" "$user_uid_count" "$user_info_sessions" "$user_privileged" "$user_log_fail" "$status"
render_user_screen() {
    local u_logger="$1"
    local u_active_count="$2"
    local u_admin_count="$3"
    local u_uid_count="$4"
    local u_info_sessions="$5"
    local u_privileged="$6"
    local u_log_fail="$7"
    local status="$8"
    local rec="$9"

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


# RENDER DE SYSINFO
# "$sys_hostname" "$sys_so" "$sys_kernel" "$sys_arquit" "$sys_up_time" "$sys_entorno" "$status"
render_sysinfo_screen(){
    local s_hostname="$1"
    local s_so="$2"
    local s_kernel="$3"
    local s_aquitec="$4"
    local s_up_time="$5"
    local s_around="$6"
    local status="$7"

    # Descomponer status
    local s_status=$(echo "$status" |cut -d'|' -f1)
    local s_rec=$(echo "$status" |cut -d'|' -f2)


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
    printf 'Estado                     : %s\n\n' "$s_status"
    printf '=========================================================================\n\n'

    #Recomendaciones
    if [ "$s_status" != "OK" ] && [ "$s_reco" != "N/A" ]; then
        printf '%bRecomendación: %s%b\n\n' "${YELLOW}" "$s_rec" "${NC}"
    fi
}


# RENDER DE full audit screen
# $base_score" "$global_status" "$count_ok" "$count_warn" "$count_crit"
render_full_audit_screen() {
    local raw_data_status="$1"
    local raw_data_rec="$2"

    # 1. Descomponer datos del status.
    local f_score_global f_global_status f_count_ok f_count_warn f_count_crit
    IFS='|' read -r f_score_global f_global_status f_count_ok f_count_warn f_count_crit <<< "$raw_data_status"

    # 2. Descomponer datos de recomendaciones.


    # 3. Generar la barra de progreso ASCII (funcion en utils.py)
    local bar
    bar=$(bar_progress_ascii 20 "$f_score_global")

    # 4. Manejar colores de los status

    local status_color="${GREEN}"
    if [ "$f_global_status" == "CRITICAL" ]; then
        status_color="${RED}"

    elif [ "$f_global_status" == "WARNING" ]; then
        status_color="${YELLOW}"
    else
        status_color="${GREEN}"
    fi

    # renderizar estado y recomendacion de (ram, disk, cpu etc)
    local format_audit_reco=$( 
    {
        
        while read -r line;do
            local subsistema estado hallazgo
            IFS='|' read -r subsistema estado hallazgo <<< "$line"

            printf "%-15s %-15s %-35s\n" "$subsistema" "$estado" "$hallazgo"

        done < <(tr ';' '\n' <<< "$raw_data_rec")
    }
    )

    # Imprimir pantalla maquetada
    printf '=========================================================================\n'
    printf '        LINUXOPS TOOLKIT - AUDITORÍA EJECUTIVA DEL SISTEMA\n'
    printf '=========================================================================\n\n'
    printf '[+] HEALTH SCORE GLOBAL         : %s %s %s\n' "[$bar]" "$f_score_global %" "(Estado: $f_global_status)"
    printf '[+] RESUMEN DE SALUD            : %s | %s | %s\n\n' "$f_count_ok OK" "$f_count_warn WARNING" "$f_count_crit CRITICAL"
    printf '%s''-------------------------------------------------------------------------\n'
    printf "%-15s %-15s %-35s\n" "SUBSISTEMA" "ESTADO" "HALLAZGO_PRINCIPAL" 
    printf '%s''-------------------------------------------------------------------------\n'
    printf '%s\n' "$format_audit_reco"
    printf '=========================================================================\n'

    
    # echo "$raw_data_rec"
    
}
