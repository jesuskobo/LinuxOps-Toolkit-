#!/usr/bin/env bash
# LinuxOps Toolkit - Enrutador Principal de Comandos (Cerebro)

route_command() {
    case "$1" in
        "system" | 1)
            # Funciones dentro de Module/system
            case "$2" in
                "cpu" | 1)                    
                    cpu_evaluate
                    ;;
                "memory" | 2)
                    memory_evaluate
                    ;;
                "disk" | 3)
                    disk_evaluate
                    ;;
                "network" | 4)
                    network_evaluate
                    ;;
                *)
                    printf "${RED}Error: subcomando $2 no reconocido\n"
                    log_error "Error: subcomando $2 no reconocido"
                    exit 1
                    ;;
            esac
            ;;

        # Meter mas opciones


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