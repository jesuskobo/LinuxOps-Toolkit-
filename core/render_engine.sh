#!/usr/bin/env bash
# LinuxOps Toolkit 

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

# "$disk_total" "$disk_usage" "$disk_available" "$disk_usage_porc" "$disk_inode_porc" "$disk_dir_heavy" "$status" "$DISK_REC" 
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

# "$network_target" "$network_ip_local" "$network_ip_public" "$network_internet" "$network_port_listen" "$status"
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