#!/usr/bin/env bash
# LinuxOps Toolkit - Enrutador Principal de Comandos (Cerebro)

route_command() {
    case "$1" in
        "system")
            case "$2" in
                "cpu")                    
                    cpu_evaluate
                    ;;
                "memory")
                    echo "Iniciando memoria"
                    ;;
                *)
                    printf "${RED}Error: subcomando $2 no reconocido\n"
                    log_error "Error: subcomando $2 no reconocido"
                    exit 1
                    ;;
            esac
            ;;

        "")
            show_banner
            ;;
        
        "help"|"-h"|"--help")
            printf "Uso: linuxops [comando]\n"
            ;;
        *)
            printf "${RED}Error: Comando $1 no reconocido\n"
            log_error "Error: Comando $1 no reconocido"
            exit 1
            ;;
        esac
}