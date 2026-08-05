#!/usr/bin/env bash
# LinuxOps Toolkit - Enrutador secundario para SYSTEM de Comandos (Cerebro)

# GESTION DE MODULO SYSTEM
route_system(){
    # Funciones dentro de Module/system
    case "$2" in
        "cpu" | 1)  
            # Ejecutar la función de evaluación de CPU y capturar su salida
            local output_cpu
            output_cpu=$(cpu_evaluate)
            # Llamar a la función de renderizado de CPU con la salida capturada
            render_cpu_screen "$output_cpu"
            ;;
        "memory" | 2)
            local output_mem
            output_mem=$(memory_evaluate)
            render_memory_screen "$output_mem"
            ;;
        "disk" | 3)
            echo "Revisando almacenamiento por favor espere.."
            local output_disk
            output_disk=$(disk_evaluate)
            render_disk_screen "$output_disk"
            ;;
        "network" | 4)
            local output_net
            output_net=$(network_evaluate)
            render_network_screen "$output_net"
            ;;
        "process" | 5)
            local output_proc
            output_proc=$(process_evaluate)
            render_process_screen "$output_proc"
            ;;
        "users" | 6)
            local output_users
            output_users=$(users_evaluate)
            render_user_screen "$output_users"
            ;;
        "sysinfo" | 7)
            local output_sysinfo
            output_sysinfo=$(sysinfo_evaluate)
            render_sysinfo_screen "$output_sysinfo"
            ;;
        "all" | "audit" | 8)
            echo "Recopilando información del sistema y evaluando el estado..."
            
            # Descomponer datos que vienen delimitados por - de run_full_system_audit y pasarlos limpios al render
            local output_all
            output_all=$(run_full_system_audit)

            local health_data=$(echo "$output_all"|cut -d'-' -f1)
            local table_recom_msg=$(echo "$output_all"|cut -d'-' -f2)
            local table_recom_long=$(echo "$output_all"|cut -d'-' -f3)

            render_full_audit_screen "$health_data" "$table_recom_msg" "$table_recom_long"
            
            ;;
        "")
            printf "${RED}Error: subcomando vacio ejecute [linuxops system -h] para mas informacion\n"
            log_error "Error: subcomando vacio"
            exit 1
            ;;
        "help"|"-h"|"--help")
            show_system_help
            ;;
        *)
            printf "${RED}Error: subcomando $2 no reconocido ejecute [linuxops system -h] para mas informacion\n"
            log_error "Error: subcomando $2 no reconocido"
            exit 1
            ;;
    esac
}

# RECOPILA INFORMACION DEL LOS DISTINTOS MODULOS SE CONSULTA SALUDO y se envia informacion al render
run_full_system_audit(){
    # 1. Ejecutamos cada módulo y guardamos su salida completa en variables

    # 1.1 Descomponer los campos delimitados por pipe para SYSINFO
    local res_sysinfo=$(sysinfo_evaluate)
    local sys_hostname sys_so sys_kernel sys_arquit sys_up_time sys_around sys_status sys_rec
    IFS='|' read -r sys_hostname sys_so sys_kernel sys_arquit sys_up_time sys_around sys_status sys_rec <<< "$res_sysinfo"

    # 1.2 Descomponer los campos delimitados por pipe para CPU
    # "${cpu_model}|${cpu_cores}|${cpu_load}|${cpu_usage}|${status}|${recommendation_cpu}"
    local res_cpu=$(cpu_evaluate)
    local cpu_model cpu_cores cpu_load cpu_usage cpu_status cpu_rec
    IFS='|' read -r cpu_model cpu_cores cpu_load cpu_usage cpu_status cpu_rec <<< "$res_cpu"

    # 1.3 Descomponer los campor delimitados por pipe para MEMORIA RAM
    local res_mem=$(memory_evaluate)
    local memory_total memory_usage memory_available memory_porcentage memory_swaps memory_status memory_rec
    IFS='|' read -r memory_total memory_usage memory_available memory_porcentage memory_swaps memory_status memory_rec <<< "$res_mem"

    # 1.4 Descomponer los campos delimitados por pipe para DISCO
    local res_disk=$(disk_evaluate)
    local disk_total disk_usage disk_available disk_usage_porc disk_inode_porc disk_dir_heavy disk_status disk_rec
    IFS='|' read -r disk_total disk_usage disk_available disk_usage_porc disk_inode_porc disk_dir_heavy disk_status disk_rec <<< "$res_disk"

    # 1.5 Descomponer los campos delimitados por pipe para RED
    local res_net=$(network_evaluate)
    local network_target network_ip_local network_ip_public network_internet network_port_listen net_status net_rec
    IFS='|' read -r network_target network_ip_local network_ip_public network_internet network_port_listen net_status net_rec <<< "$res_net"

    # 1.6 Descomponer los campos delimitados por pipe para PROCESOS
    local res_proc=$(process_evaluate)
    local proc_cpu proc_mem proc_zombie proc_total proc_z_status proc_z_recommendation_msg proc_z_code proc_cpu_status proc_cpu_recommendation_msg proc_cpu_code proc_m_status proc_m_recommendation_msg proc_m_code
    IFS='|' read -r proc_cpu proc_mem proc_zombie proc_total proc_z_status proc_z_recommendation_msg proc_z_code proc_cpu_status proc_cpu_recommendation_msg proc_cpu_code proc_m_status proc_m_recommendation_msg proc_m_code <<< "$res_proc"

    # 1.6.1 Determinar el estado general de los procesos según los estados individuales de CPU, memoria y procesos zombie
    local proc_status="OK"
    if [[ "$proc_z_status" == "CRITICAL" || "$proc_cpu_status" == "CRITICAL" || "$proc_m_status" == "CRITICAL" ]]; then
        proc_status="CRITICAL"
    elif [[ "$proc_z_status" == "WARNING" || "$proc_cpu_status" == "WARNING" || "$proc_m_status" == "WARNING" ]]; then
        proc_status="WARNING"
    fi

    # 1.8 Descomponer los campos delimitados por pipe para USUARIOS
    local res_users=$(users_evaluate)
    local user_loggers user_active_count user_admin_count user_uid_count user_info_sessions user_privileged user_log_fail user_status user_recommendation_msg user_code
    IFS='|' read -r user_loggers user_active_count user_admin_count user_uid_count user_info_sessions user_privileged user_log_fail user_status user_recommendation_msg user_code <<< "$res_users"


    # 2. Calculamos la salud matemática enviando las 7 palabras de estado
    local health_data=$(calculate_health_score "$sys_status" "$cpu_status" "$memory_status" "$disk_status" "$net_status" "$proc_status" "$user_status")

    # 3. Construimos la recomendacion obtenida
    # tabla de recomendacion con su proceso y estado ej: SYSINFO|OK|revisar info del kernel;cpu|warning|revisar consumo cpu
    local table_recom_msg
    table_recom_msg="SYSINFO|$sys_status|$sys_hostname $sys_so;"
    table_recom_msg+="CPU|$cpu_status|uso actual al ${cpu_usage}% (${cpu_cores} núcleos);"
    table_recom_msg+="MEMORIA|$memory_status|RAM usada al $memory_porcentage% ($memory_available GB disponibles);"
    table_recom_msg+="DISCO|$disk_status|Partición root (/) con $disk_usage_porc% de uso;"
    table_recom_msg+="RED|$net_status|Direccion ip $network_ip_local;"
    table_recom_msg+="PROCESOS|$proc_status|$proc_z_recommendation_msg;"
    table_recom_msg+="USUARIOS|$user_status|$user_recommendation_msg"

    # 4. Scaremos MODULOS|ESTADO|RECOMENDACION; para cada modulo, y luego lo pasamos a build_advice_table para que nos devuelva una tabla con el formato:
    # PRIORIDAD|MODULO|RECOMENDACION
    # ATENCION!! para recomendaciones del modulo de procesos y usuarios, toca estraerlo del archivo recommendations.sh 
    # ya que estos modulos no tienen una recomendacion fija, sino que depende del codigo de estado que se genere en la evaluacion de cada modulo
    # para el resto de modulos, la recomendacion es fija y se encuentra en recommendations.conf, por lo que se puede extraer directamente de ahi
    
    local table_recom_long
    # Para modulos con recomendacion fija
    # corregidos
    table_recom_long="SYSINFO|$sys_status|$sys_rec;"
    table_recom_long+="CPU|$cpu_status|$cpu_rec;"
    table_recom_long+="MEMORIA|$memory_status|$memory_rec;"
    table_recom_long+="DISCO|$disk_status|$disk_rec;"
    table_recom_long+="RED|$net_status|$net_rec;"
    # para modulos con recomendacion variable (procesos y usuarios), se obtiene la recomendacion del archivo recommendations.sh
    table_recom_long+="PROCESOS|$proc_status|$(get_recommendation "$proc_z_code");"
    table_recom_long+="USUARIOS|$user_status|$(get_recommendation "$user_code")"
    

    # llama la funcion build_prioritized_advice para asignar MODULO|ESTADO|RECOMENDACION;
    table_recom_long=$(build_prioritized_advice "$table_recom_long")

    # 5. Renderizamos la pantalla ejecutiva
    echo "${health_data}-${table_recom_msg}-${table_recom_long}"

}
