#!/usr/bin/env bash
# LinuxOps Toolkit - Modulo admin-servicios

# Recoloeccion de informacion del sistema
service_collect() {
    local serv="$1"
    local user=$(logname 2>/dev/null || whoami)
    local status_running=$(systemctl is-active "$serv")
    local status_authorization=$(systemctl is-enabled "$serv")
    local pid=$(systemctl show -p MainPID --value "$serv")
    local cpu
    local memory
    local time_down
    local time_up

    if [ "$status_running" == "active" ] && [ "$pid" -gt 0 ];then
        cpu=$(ps -p "$pid" -o %cpu --no-headers)
        memory=$(ps -p "$pid" -o %mem --no-headers)
        local date_active=$(systemctl show "$serv" --value --property=ActiveEnterTimestamp)
        time_up=$(convert_date "$date_active")
        time_down="N/A"

    else
        cpu=0
        memory=0
        local date_inactive=$(systemctl show "$serv" --value --property=InactiveEnterTimestamp)
        time_down=$(convert_date "$date_inactive")
        time_up="N/A"
    fi

    # pendiente desarrollar diagnostico
    local diagnostic=$(service_diagnose)

    # PID|user|status_running|status_authorization|cpu|memoria_ram|tiempo activo|tiempo caido
    echo "${serv}|${pid}|${user}|${status_running}|${status_authorization}|${cpu}|${memory}|${time_up}|${time_down}"
}
convert_date() {
    local time="$1"
    active_epoch=$(date -d "$time" +%s)
    now_epoch=$(date +%s)

    elapsed=$((now_epoch - active_epoch))

    echo "$((elapsed / 3600))h $(((elapsed % 3600) / 60))m"
}

# Diagnosticar sistema
service_diagnose() {
    #Pendiente agregar diagnostico
    echo "diagnostico"

}

# Evaluar informacion y entregarla
service_evaluate() {
    local name_service="$1"
    local action="$2"
    
    # Si no se escribio un  servicio o esta vacio se mensaje y finaliza el programa
    local exist_service=$(systemctl list-unit-files --type=service |awk '{print $1}' |grep -x "$name_service.service")
    
    if [ -z "$exist_service" ] ;then
        if [ -z "$name_service" ];then
            printf "%bError: Ingrese un servicio.%b\n" "$RED" "$NC"
            log_error "Por favor ingrese un servicio a consultar"
            return 1
        else
            printf "%bError: El servicio '%s' no existe.%b\n" "$RED" "$name_service" "$NC"
            log_error "El servicio '$name_service' no existe."
            return 1
        fi
    fi

    if [ "$action" != "N/A" ] && [ "$action" != "status" ];then
        action_service "$name_service" "$action"
    fi

    # PID|user|status_running|status_authorization|cpu|memoria_ram|tiempo activo|tiempo caido
    service_collect "$name_service"
 
}
action_service() {
    local name_service="$1"
    local action="$2"

    # Condicionales para mostrar accion
    if [ "$action" == "start" ];then
        echo "Iniciando el servicio $name_service"
        systemctl "$action" "$name_service"
    elif [ "$action" == "stop" ];then
        echo "Deteniendo el servicio $name_service"
        systemctl "$action" "$name_service"
    elif [ "$action" == "reload" ];then
        echo "Recargando el servicio $name_service"
        systemctl "$action" "$name_service"
    elif [ "$action" == "restart" ];then
        echo "Reiniciando el servicio $name_service"
        systemctl "$action" "$name_service"
    fi

}
