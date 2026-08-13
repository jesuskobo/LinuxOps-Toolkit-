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
            case "$action" in
                "status"|"STATUS")
                    service_evaluate "$name_service"
                ;;
                "start"|"START")
                    echo "iniciando servicio"
                ;;
                "stop"|"STOP")
                    echo "Deteniendo servicio"
                ;;
                "reload"|"RELOAD")
                    echo "recargando servicio"
                ;;
                "restart"|"RESTART")
                    echo "reiniciando servicio"
                ;;
                "")
                    echo "Error: subcomando vacio"
                ;;
                *)
                    echo "Error: subcomando '$action' desconocido"
                ;;
            esac
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