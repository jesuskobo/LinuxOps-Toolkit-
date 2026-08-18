#!/usr/bin/env bash
# LinuxOps Toolkit - Enrutador Principal de Comandos (Cerebro)

route_command() {
    case "$1" in
        # GESTION DE MODULO SYSTEM
        "system" | 1)
            # Funciones dentro de Module/system
            route_system "$@"
        ;;

        # GESTION MODULO SERVICICOS
        "admin" | 2)
            route_admin "$2" "$3" "$4"
        ;;
        
        # MANEJO DE HELPER Y ERRORES - lib/help.sh
        "help"|"-h"|"--help")
            show_help
        ;;
        "version"|"-v"|"--version")
            printf "LinuxOps Toolkit v%s\n" "${APP_VERSION:-1.0.0}"
        ;;
        "")
            show_banner
        ;;
        *)
            printf "${RED}Error: Comando $1 no reconocido\n"
            log_error "Error: Comando $1 no reconocido"
            exit 1
        ;;
    esac
}
