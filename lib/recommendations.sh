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

        *)
            echo "N/A"
        ;;

        # PROCESS
        # codigo aqui

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

        NONE)
            echo "Todo en orden"
        ;;

        *)
            echo "Estado desconocido"
        ;;

        # PROCESS
        # codigo aqui

    esac

}