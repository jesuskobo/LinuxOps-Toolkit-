#!/usr/bin/env bash
# LinuxOps Toolkit - Funciones para brindar recomendaciones

# SERVIR RECOMENDACIONES LARGAS DE RECOMENDATIONS.CONF Y CORTAS ESCRITAS SEGUN CODIGO ENVIADO
get_recommendation() {

    # Codigo del status recibido
    local codec_info="$1"

    case "$codec_info" in

        # USERS
        USERS_FAILED_LOGINS)
            echo "$USERS_WARNING_FAILED_LOGINS"
        ;;
        USERS_MANY_SESSIONS)
            echo "$USERS_WARNING_SESSIONS"
        ;;
        USERS_UID0)
            echo "$USERS_CRITICAL_UID0"
        ;;

        
        # PROCESS
        PROCESS_ZOMBIE_WARNING)
            echo "$PROCESS_WARNING_ZOMBIE"
        ;;
        PROCESS_ZOMBIE_CRITICAL)
            echo "$PROCESS_CRITICAL_ZOMBIE"
        ;;
        PROCESS_CPU_WARNING)
            echo "$PROCESS_WARNING_CPU"
        ;;
        PROCESS_CPU_CRITICAL)
            echo "$PROCESS_CRITICAL_CPU"
        ;;
        PROCESS_MEM_WARNING)
            echo "$PROCESS_WARNING_MEM"
        ;;
        PROCESS_MEM_CRITICAL)
            echo "$PROCESS_CRITICAL_MEM"
        ;;



        # error o status generales
        *)
            echo "N/A"
        ;;

    esac
}

# Mensaje corto para CLI, dashboard y logs
get_status_message() {

    # Codigo del status recibido
    local code="$1"

    case "$code" in

        # USERS
        USERS_FAILED_LOGINS)
            echo "Múltiples intentos fallidos de sesión"
        ;;
        USERS_MANY_SESSIONS)
            echo "Alto número de sesiones TTY/PTS"
        ;;
        USERS_UID0)
            echo "Cuentas no-root con UID 0"
        ;;

        
        # PROCESS
        PROCESS_ZOMBIE_WARNING)
            echo "Procesos Zombie detectados"
        ;;
        PROCESS_ZOMBIE_CRITICAL)
            echo "Exceso de procesos Zombie"
        ;;
        PROCESS_CPU_WARNING)
            echo "Alto consumo de CPU por un proceso"
        ;;
        PROCESS_CPU_CRITICAL)
            echo "Consumo crítico de CPU por un proceso"
        ;;
        PROCESS_MEM_WARNING)
            echo "Alto consumo de memoria por un proceso"
        ;;
        PROCESS_MEM_CRITICAL)
            echo "Consumo crítico de memoria por un proceso"
        ;;


        # error o status generales
        NONE)
            echo "Todo en orden"
        ;;
        *)
            echo "Estado desconocido"
        ;;

    esac

}