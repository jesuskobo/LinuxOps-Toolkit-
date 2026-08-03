#!/usr/bin/env bash
# LinuxOps Toolkit - Módulo de REDES

network_collect() {
    # 1. Consultar interfaz de Red
    local target_red
    target_red=$(ip route show default | awk '{print $5}')
    target_red="${target_red:-N/A}"

    # 2. Consultar Ip Local
    local ip_local
    ip_local=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}')
    ip_local="${ip_local:-N/A}"

    # 3. Consultar Ip publica
    local ip_public
    ip_public=$(timeout 1s curl -s ifconfig.me || echo "N/A")

    # 4. Consultar si hay internet
    local internet
    if (ping -c 1 -W 1 8.8.8.8 || nc -z -w 1 1.1.1.1 53) &>/dev/null; then
        internet="ONLINE"
    else
        internet="OFFLINE"
    fi

    # 5. Verifica puertos abiertos
    local port_listen
    port_listen=$(ss -tuln |awk 'NR!=1{print $2}' |sort |uniq -c|xargs|sed 's/LISTEN/TCP-ESCUCHANDO/g; s/UNCONN/UDP-ABIERTO/g')
    port_listen="${port_listen:-Sin puertos activos}"

    
    echo "${target_red}|${ip_local}|${ip_public}|${internet}|${port_listen}"
}


network_evaluate() {
    local raw_data
    raw_data=$(network_collect)

    # Descomponer los campos delimitados por pipe |
    local network_target network_ip_local network_ip_public network_internet network_port_listen
    IFS='|' read -r network_target network_ip_local network_ip_public network_internet network_port_listen <<< "$raw_data"

    # Determinar estados
    local status="N/A"
    local recommendation_network="NONE" #obtiene valores del archivo config/recommendations.confi

    # 1. Si hay IP local y conectividad a internet
    if [ "$network_ip_local" != "N/A" ] && [ "$network_internet" = "ONLINE" ] >/dev/null; then
        status="OK"
        log_info "Dispositivo $status a través de la interfaz [$network_target]. IP Pública: $network_ip_public"

    # 2. Si hay IP local pero NO responde a internet
    elif [ "$network_ip_local" != "N/A" ] && [ "$network_internet" = "OFFLINE" ];then
        status="WARNING"
        recommendation_network="$NETWORK_WARNING"
        log_warn "Conectado a la red local ($network_ip_local), pero sin salida a internet"
        

    # 3. Si no hay IP local ni interfaz predeterminada
    else
        status="CRITICAL"
        recommendation_network="$NETWORK_CRITICAL"
        log_error "Interfaz desconectada. No hay IP local ni puerta de enlace detectada."
    fi

    # 4. --- CONTROL DE SALIDA PARALELA PARA manejar status ---
    if [ "$1" == "--silent" ] || [ "$1" == "-s" ];then
        echo "${status}|Direccion ip $network_ip_local|${recommendation_network}"
        return 0
    fi


    render_network_screen "$network_target" "$network_ip_local" "$network_ip_public" "$network_internet" "$network_port_listen" "$status" "$recommendation_network"
}