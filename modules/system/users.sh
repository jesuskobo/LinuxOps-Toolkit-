#!/usr/bin/env bash
# LinuxOps Toolkit - Modulo usuarios


users_collect() {
    #metricas de resumen
    local u_loggers=$(who |awk '{print $1}' |sort -u|paste -sd ';') # usuarios logueados
    local u_activas=$(who |awk  '$2 ~ /tty|pts/ {print $1}'|wc -l) # sesiones activas TTY/PTS
    local u_sudo=$(getent group sudo wheel |cut -d: -f4 |wc -l) # obtener # usuario sudo o wheel
    local u_uid=$(getent passwd |awk -F: '$3==0 {print $3}' |wc -l) # debe esta 1 solo root si hay otro hay un problema de seguridad

    # Metricas de sesiones activas |USUARIO TTY DESDE_(IP) DESDE_CUANDO INACTIVO COMANDO_ACTUAL
    local u_info_sesion=$(PROCPS_USERLEN=20 w -fh |awk '{print $1, $2, $3, $4, $5, $8}' |column -t|paste -sd ';')

    # Usuario con privilegios admin
    u_privi=$({
        getent group | awk -F: '$3==0 {print $1}'
        getent group sudo wheel | awk -F: '{print $4}'
        } | paste -sd ';'
    )

    # Intento fallidos de sesion
    local u_sesion_fail=$(journalctl -u "sshd" --since "1 day ago" |grep -iE "Failed password|authentication failure"|tr 'A-Z' 'a-z')
    local u_log_info=$(format_log "$u_sesion_fail" |paste -sd';')
    
    # servir datos con pipe
    echo "${u_loggers}|${u_activas}|${u_sudo}|${u_uid}|${u_info_sesion}|${u_privi}|${u_log_info}"

}

users_evaluate() {
    local raw_data
    raw_data=$(users_collect)

    # Descomponer datos con que vienen con pipe |
    local user_loggers user_active_count user_admin_count user_uid_count user_info_sessions user_privileged user_log_fail
    IFS='|' read -r user_loggers user_active_count user_admin_count user_uid_count user_info_sessions user_privileged user_log_fail <<< "$raw_data"

    # Estados
    local status="OK"
    local code="NONE"

    # Detectar intentos fallidos / Sesiones activas
    local code=$(count_sesion "$user_log_fail")

    # servir status y generar log
    case "$code" in
        # Setear el status segun el codigo optenido de count_sesion
        USERS_FAILED_LOGINS)
            status="WARNING"
            log_warn "Múltiples intentos fallidos de inicio de sesión detectados."
            
        ;;

        USERS_MANY_SESSIONS)
            status="WARNING"
            log_warn "Alto número de sesiones TTY/PTS abiertas."
            
        ;;

    esac

    # Si hay usuarios con UID que sean diferente a user se pone status critical
    # user_uid_count=10 #debug
    if (( user_uid_count > 1 )); then
        status="CRITICAL"
        code="USERS_UID0"
        
        log_error "Se detectaron cuentas no-root con UID 0"
        # cuentas no-root con UID 0
    fi

    # Obtener recomendación detallada segun codigo enviado
    local recommendation=$(get_recommendation "$code")

    # Obtener recomendacion corta solo mensaje
    local recommendation_msg=$(get_status_message "$code")

    # --- CONTROL DE SALIDA PARALELA PARA manejar status ---
    if [ "$1" == "--silent" ] || [ "$1" == "-s" ];then
        echo "${status}|${recommendation_msg}|$code"
        return 0
    fi

    # servir datos para renderizar
    render_user_screen "$user_loggers" "$user_active_count" "$user_admin_count" "$user_uid_count" "$user_info_sessions" "$user_privileged" "$user_log_fail" "$status" "$recommendation"

}




### FUNCIONES PRIVADAS DEL MODULO
count_sesion() {
    # Logs recibidos desde users_collect().
    local log_fail="$1"

    # Contador de intentos fallidos dentro de la ventanade tiempo configurada (5 minutos).
    local failed=0
    local sesiones # Número de sesiones activas.

    # Fecha/hora actual en formato Epoch (segundos desde 1970). Facilita calcular diferencias de tiempo.
    local now=$(date +%s)

    # El formato recibido es:registro1;registro2;registro3 Se reemplaza ';' por saltos de línea para poder leerun registro a la vez con read.
    while read -r mes dia hora ip usuario motivo; do

        # Convierte:jul 07 11:02:20 a segundos Epoch.
        local fecha=$(date -d "$mes $dia $(date +%Y) $hora" +%s 2>/dev/null)

        # Si la fecha no pudo convertirse, ignorar el registro.
        [[ -z "$fecha" ]] && continue

        # Tiempo transcurrido entre el evento y el momento actual.
        local diferencia=$((now - fecha))

        # Si ocurrió durante los últimos 5 minutos incrementar el contador.
        if (( diferencia <= 300 )); then
            ((failed++))
        fi

    done < <(tr ';' '\n' <<< "$log_fail")

    # Número de sesiones actualmente abiertas.
    sesiones=$(who | wc -l)

    # Posible ataque de fuerza bruta.
    if (( failed >= 5 )); then
        echo "USERS_FAILED_LOGINS" # codigo del status
        
    # Muchas sesiones abiertas.
    elif (( sesiones > 10 )); then
        echo "USERS_MANY_SESSIONS" # codigo del status
        
    # Estado normal.
    else
        echo "NONE" # codigo del status
    fi
}

# Poner authentication failure si se desea
format_log() {
    local log_failed=$1
    while read -r line; do

        # Ignorar líneas vacías de control
        [[ -z "$line" ]] && continue

        if [[ "$line" == *"failed password"* ]];then

            local fecha=$(echo "$line" |awk '{print $1, $2, $3}') # extraer fecha
            local ip=$(echo "$line" |awk -F 'from' '{print $2}' |awk '{print $1}') # extraer ip
            local user=$(echo "$line" |awk -F 'for' '{print $2}' |awk '{print $1}') # extraer  usuario
            user=${user/invalid/invalid_user} # A los usuario invalidos cambiarlos a invalid_user

            local error_user_or_pass=""
            if [[ "$user" == "invalid_user" ]];then
                error_user_or_pass="usuario_incorrecto"
            else
                error_user_or_pass="contraseña_o_usuario_incorrecto"
            fi

            echo "$fecha $ip $user $error_user_or_pass"
        fi
        
    done <<< "$log_failed"
}