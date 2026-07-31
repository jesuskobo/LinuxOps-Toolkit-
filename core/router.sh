#!/usr/bin/env bash
# LinuxOps Toolkit - Enrutador Principal de Comandos (Cerebro)

route_command() {
    case "$1" in
        "system" | 1)
            # Funciones dentro de Module/system
            case "$2" in
                "cpu" | 1)                    
                    cpu_evaluate
                    # cpu_evaluate --silent 
                    ;;
                "memory" | 2)
                    memory_evaluate
                    ;;
                "disk" | 3)
                    echo "Revisando almacenamiento por favor espere.."
                    disk_evaluate
                    ;;
                "network" | 4)
                    network_evaluate
                    ;;
                "process" | 5)
                    process_evaluate
                    ;;
                "users" | 6)
                    users_evaluate
                    ;;
                "sysinfo" | 7)
                    sysinfo_evaluate
                    ;;
                "all" | "audit" | 8)
                    run_full_system_audit
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

run_full_system_audit(){
    echo "Recopilando información del sistema y evaluando el estado..."

    # 1. Ejecutamos cada módulo y guardamos su salida completa en variables
    local res_sysinfo=$(sysinfo_evaluate --silent)
    local res_cpu=$(cpu_evaluate --silent)
    local res_mem=$(memory_evaluate --silent)
    local res_disk=$(disk_evaluate --silent)
    local res_net=$(network_evaluate --silent)
    local res_proc=$(process_evaluate --silent)
    local res_users=$(users_evaluate --silent)

    # 2. Extraemos SOLO el estado (OK / WARNING / CRITICAL) para el cálculo matemático
    local st_sysinfo=$(echo "$res_sysinfo" |cut -d'|' -f1)
    local st_cpu=$(echo "$res_cpu" |cut -d'|' -f1)
    local st_mem=$(echo "$res_mem" |cut -d'|' -f1)
    local st_disk=$(echo "$res_disk" |cut -d'|' -f1)
    local st_net=$(echo "$res_net" |cut -d'|' -f1)
    local st_proc=$(echo "$res_proc" |cut -d'|' -f1)
    local st_users=$(echo "$res_users" |cut -d'|' -f1)

    # 3. Calculamos la salud matemática enviando las 7 palabras de estado
    local health_data=$(calculate_health_score "$st_sysinfo" "$st_cpu" "$st_mem" "$st_disk" "$st_net" "$st_proc" "$st_users")

    # 4. Construimos la recomendacion obtenida
    # pendiente corregir en process.sh y users.shla recomendacion obtenida ya que es muy larga
    local table_recom
    table_recom="SYSINFO|$st_sysinfo|$(echo "$res_sysinfo" | cut -d'|' -f2);"
    table_recom+="CPU|$st_cpu|$(echo $res_cpu | cut -d'|' -f2);"
    table_recom+="MEMORIA|$st_mem|$(echo $res_mem | cut -d'|' -f2);"
    table_recom+="DISCO|$st_disk|$(echo $res_disk | cut -d'|' -f2);"
    table_recom+="RED|$st_net|$(echo $res_net | cut -d'|' -f2);"
    table_recom+="PROCESOS|$st_proc|$(echo $res_proc |cut -d'|' -f2);"
    table_recom+="USUARIOS|$st_users|$(echo $res_users |cut -d'|' -f2)"

    # 4. Renderizamos la pantalla ejecutiva
    render_full_audit_screen "$health_data" "$table_recom"

}
