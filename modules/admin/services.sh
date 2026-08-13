#!/usr/bin/env bash
# LinuxOps Toolkit - Modulo admin-servicios

convert_date() {
    local time="$1"
    active_epoch=$(date -d "$time" +%s)
    now_epoch=$(date +%s)

    elapsed=$((now_epoch - active_epoch))

    echo "$((elapsed / 3600))h $(((elapsed % 3600) / 60))m"
}

service_collect() {
    local serv="$1"
    local status=$(systemctl is-active "$serv")
    local pid=$(systemctl show -p MainPID --value "$serv")
    local cpu
    local memory
    local time_down
    local time_up

    if [ "$status" == "active" ] && [ "$pid" -gt 0 ];then
        cpu=$(ps -p "$pid" -o %cpu,%mem --no-headers)
        memory=$(ps -p "$pid" -o %mem --no-headers)
        local date_active=$(systemctl show sshd --value --property=ActiveEnterTimestamp)
        time_up=$(convert_date "$date_active")
        time_down="N/A"

    else
        cpu=0
        memory=0
        local date_inactive=$(systemctl show sshd --value --property=InactiveEnterTimestamp)
        time_down=$(convert_date "$date_inactive")
        time_up="N/A"
    fi

    # PID|status
    echo "${pid}|${status}|${cpu}|${memory}|${time_up}|${time_down}"
}

service_evaluate() {
    local name_service="$1"
    
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


    service_collect "$name_service"
    # opciones="true"
    # while [ "$opciones" == true ] ;do
    #     echo $(service_collect "$name_service")
    #     read -p "desea hacer algo mas: " opcion

    #     opciones="false"
    # done
}

