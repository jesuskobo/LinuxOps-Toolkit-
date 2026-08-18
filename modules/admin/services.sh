#!/usr/bin/env bash
# LinuxOps Toolkit - Modulo admin-servicios

# RECOLECCION DE INFORMACION DEL SISTEMA
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
        cpu=$(ps -p "$pid" -o %cpu --no-headers |tr -d ' ')
        memory=$(ps -p "$pid" -o %mem --no-headers |tr -d ' ')
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

    # Sacar diagnostico del servicio
    local diagnostic=$(service_diagnose "$serv" "$status_running" "$status_authorization" "$pid" |tr '\n' ';')

    # PID|user|status_running|status_authorization|cpu|memoria_ram|tiempo activo|tiempo caido|diagnostico
    echo "${serv}|${pid}|${user}|${status_running}|${status_authorization}|${cpu}|${memory}|${time_up}|${time_down}|${diagnostic}"
}
# convertir fecha a formato entendible
convert_date() {
    local time="$1"

    if [ -z "$time" ]; then
        echo "N/A"
        return
    fi

    local active_epoch
    local now_epoch
    local elapsed

    active_epoch=$(date -d "$time" +%s 2>/dev/null)
    now_epoch=$(date +%s)

    if [ -z "$active_epoch" ]; then
        echo "N/A"
        return
    fi

    elapsed=$((now_epoch - active_epoch))

    echo "$((elapsed / 3600))h $(((elapsed % 3600) / 60))m"
}
# Diagnosticar sistema
service_diagnose() {
    local serv="$1"
    local status_running="$2"
    local status_authorization="$3"
    local pid="$4"

    if [ "$status_running" == "active" ]; then
        echo "[✓] Servicio activo"
    else
        echo "[✗] Servicio no está activo"
    fi

    if [ "$pid" -gt 0 ]; then
        echo "[✓] PID principal encontrado: $pid"
    else
        echo "[✗] No se encontró PID principal"
    fi

    if [ "$status_authorization" == "enabled" ]; then
        echo "[✓] Servicio habilitado al inicio"
    elif [ "$status_authorization" == "disabled" ]; then
        echo "[!] Servicio deshabilitado al inicio"
    else
        echo "[!] Estado de habilitación: $status_authorization"
    fi
}

# EVALUAR INFORMACION Y ENTREGARLA
service_execute() {
    local name_service="$1"
    local action="$2"

    # Validar que se haya ingresado un servicio
    if [ -z "$name_service" ]; then
        printf "%bError: Ingrese un servicio.%b\n" "$RED" "$NC"
        log_error "Por favor ingrese un servicio a consultar"
        return 1
    fi
    
    # Si no se escribio un  servicio o esta vacio se manda mensaje y finaliza el programa
    local exist_service
    exist_service=$(systemctl list-unit-files --type=service |awk '{print $1}' |grep -x "$name_service.service")
    if [ -z "$exist_service" ]; then
        printf "%bError: El servicio '%s' no existe.%b\n" "$RED" "$name_service" "$NC"
        log_error "El servicio '$name_service' no existe."
        return 1
    fi

    # Si la accion es N/A
    if [ "$action" == "N/A" ] || [ "$action" == "status" ]; then
        # PID|user|status_running|status_authorization|cpu|memoria_ram|tiempo activo|tiempo caido|diagnostico
        service_collect "$name_service"
    else
        # Funcion en utils.sh
        action_service "$name_service" "$action"
    fi
 
}

# Menu de servicio y accion a realizar
service_menu() {
    local service_name="$1"
    local option

    while true; do
        printf 'ACCIONES - %s\n' "$service_name"
        printf '%s\n' '-------------------------------------------------------------------------'
        printf '[1] Reiniciar\n'
        printf '[2] Detener\n'
        printf '[3] Recargar\n'
        printf '[4] Ver logs\n'
        printf '[5] Salir\n'
        printf '%s\n' '========================================================================='

        read -rp "Ingrese una opción: " option

        case "$option" in
            1)
                action_service "$service_name" "restart"
                service_refresh_screen "$service_name"
                ;;
            2)
                action_service "$service_name" "stop"
                service_refresh_screen "$service_name"
                ;;
            3)
                action_service "$service_name" "reload"
                service_refresh_screen "$service_name"
                ;;
            4)
                printf "opcion en desarrollo\n"
                # service_logs "$service_name"
                ;;
            5)  
                printf "Hasta pronto!!\n"
                break
                ;;
            *)
                printf '%bOpción inválida.%b\n' "$RED" "$NC"
                ;;
        esac

        # printf '\n'
        # read -rp "Presione ENTER para continuar..."
    done
}

# Refrescar informacion servicio al realizarl alguna accion
service_refresh_screen() {
    local service_name="$1"
    local output

    output=$(service_execute "$service_name" "N/A")

    if [ $? -eq 0 ]; then
        clear
        render_services_screen "$output"
    fi
}