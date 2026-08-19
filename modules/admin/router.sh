#!/usr/bin/env bash
# LinuxOps Toolkit - Enrutador secundario para ADMIN de Comandos (Cerebro)

# GESTION DE MODULO ADMIN
route_admin() {
    # linuxops admin service status sshd
    local type_module="$1"
    local action="$2"
    local name_service="$3"
    
    case "$type_module" in
        # Ingresar a service con sus comandos
        "service" | "services")
            # Verifica si el servicio existe y mostrar informacion pantalla
            # comando: ./bin/linuxops admin service crond
            if [ -n "$action" ] && [ -z "$name_service" ]; then
                if systemctl list-unit-files --type=service |awk '{print $1}' | grep -qx "${action}.service"; then
                    name_service="$action"
                    local output
                    output=$(service_execute "$name_service" "N/A")

                    if [ $? -eq 0 ]; then
                        render_services_screen "$output"
                        service_menu "$name_service"
                    fi
                    return
                fi
            fi

            case "$action" in
                "status"|"STATUS")
                    local output
                    output=$(service_execute "$name_service" "N/A")

                    if [ $? -eq 0 ]; then
                        render_services_screen "$output"
                    fi
                ;;
                "start"|"START"|"stop"|"STOP"|"reload"|"RELOAD"|"restart"|"RESTART")
                    service_execute "$name_service" "$action"
                ;;
                "logs"|"LOGS")
                    printf 'Logs en desarrollo.\n'
                ;;

                "")
                    printf '%bError: Ingrese un servicio.%b\n' "$RED" "$NC"
                    return 1
                ;;

                *)
                    printf '%bError: El servicio "%s" no existe.%b\n' "$RED" "$action" "$NC"
                    return 1
                ;;
            esac
        ;;

        "backup" | "BACKUP")
            local output
            output=$(backup_evaluate)

            render_backup_screen "$output"
            backup_menu
            
        ;;

        "")
            printf "${RED}Error: subcomando vacio ejecute [linuxops admin -h] para mas informacion.\n"
            log_error "Subcomando vacio"
        ;;
        # si se ingresa comando no establecido
        *)
            printf "${RED}Error: Comando '$1' no reconocido\n"
            log_error "Error: Comando '$1' no reconocido"
            exit 1
        ;;
    esac
}