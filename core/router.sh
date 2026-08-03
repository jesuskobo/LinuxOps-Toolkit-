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
    # tabla de recomendacion con su proceso y estado ej: SYSINFO|OK|revisar info del kernel;cpu|warning|revisar consumo cpu
    local table_recom_msg
    table_recom_msg="SYSINFO|$st_sysinfo|$(echo "$res_sysinfo" | cut -d'|' -f2);"
    table_recom_msg+="CPU|$st_cpu|$(echo $res_cpu | cut -d'|' -f2);"
    table_recom_msg+="MEMORIA|$st_mem|$(echo $res_mem | cut -d'|' -f2);"
    table_recom_msg+="DISCO|$st_disk|$(echo $res_disk | cut -d'|' -f2);"
    table_recom_msg+="RED|$st_net|$(echo $res_net | cut -d'|' -f2);"
    table_recom_msg+="PROCESOS|$st_proc|$(echo $res_proc |cut -d'|' -f2);"
    table_recom_msg+="USUARIOS|$st_users|$(echo $res_users |cut -d'|' -f2)"

    # 5. Scaremos MODULOS|ESTADO|RECOMENDACION; para cada modulo, y luego lo pasamos a build_advice_table para que nos devuelva una tabla con el formato:
    # PRIORIDAD|MODULO|RECOMENDACION

    # ATENCION!! para recomendaciones del modulo de procesos y usuarios, toca estraerlo del archivo recommendations.sh 
    # ya que estos modulos no tienen una recomendacion fija, sino que depende del codigo de estado que se genere en la evaluacion de cada modulo
    # para el resto de modulos, la recomendacion es fija y se encuentra en recommendations.conf, por lo que se puede extraer directamente de ahi
    
    
    local table_recom_long
    # Para modulos con recomendacion fija
    table_recom_long="SYSINFO|$st_sysinfo|$(echo "$res_sysinfo"|cut -d'|' -f3);"
    table_recom_long+="CPU|$st_cpu|$(echo "$res_cpu"|cut -d'|' -f3);"
    table_recom_long+="MEMORIA|$st_mem|$(echo "$res_mem"|cut -d'|' -f3);"
    table_recom_long+="DISCO|$st_disk|$(echo "$res_disk"|cut -d'|' -f3);"
    table_recom_long+="RED|$st_net|$(echo "$res_net"|cut -d'|' -f3);"
    # para modulos con recomendacion variable (procesos y usuarios), se obtiene la recomendacion del archivo recommendations.sh
    table_recom_long+="PROCESOS|$st_proc|$(get_recommendation "$(echo "$res_proc"|cut -d'|' -f3)");"
    table_recom_long+="USUARIOS|$st_users|$(get_recommendation "$(echo "$res_users"|cut -d'|' -f3)")"
    

    # llama la funcion build_prioritized_advice para asignar prioridad a cada recomendacion
    table_recom_long=$(build_prioritized_advice "$table_recom_long")

    # echo "DEBUG: $table_recom_long"

    # 6. Renderizamos la pantalla ejecutiva
    render_full_audit_screen "$health_data" "$table_recom_msg" "$table_recom_long"

}
