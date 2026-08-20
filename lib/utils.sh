#!/usr/bin/env bash
# LinuxOps Toolkit - Funciones de Utilidad Generales

# Obtener nombre nombre de la maquina
get_hostname() {
    hostname 
}

# Obtener tiempo de encendido
get_uptime() {
    uptime -p
}

# saber si usuario es root
get_root() {
    if [ "$EUID" -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

# Banner de inicio del framework
show_banner() {
    # Renderizado del Banner Visual del Framework
    clear
    printf "%b%b" "${BOLD}" "${BLUE}"

    # 2. Imprimimos el nombre con caracteres seguros (sin barras invertidas)
    printf " _      _                    ____             \n"
    printf "| |    (_)                  / __ \            \n"
    printf "| |     _ _ __  _   _  _ _ | |  | |_ __  ___ \n"
    printf "| |    | | '_ \| | | |/ _  | |  | | '_ \/ __|\n"
    printf "| |____| | | | | |_| | (_| | |__| | |_) \__ \ \n"
    printf "|______|__|_| |_|\__,_|\__, \____/| .__/|___/\n"
    printf "                        __/ |     | |        \n"
    printf "                       |___/      |_|        \n"

    # 3. El complemento "Toolkit" abajo para cerrar el diseño de forma elegante
    printf "       » T O O L K I T  |  v%s «\n" "${APP_VERSION:-1.0.0}"
    printf "    Enterprise Linux Audit & Administration\n\n"


    #Bloque de Metadatos Estructurados (Información del Sistema)
    printf "%b--------------------------------------------------%b\n" "${WHITE}" "${NC}"
    printf " %b➔ Core:%b       %s v%s\n" "${WHITE}" "${BLUE}" "${APP_NAME}" "${APP_VERSION}"
    printf " %b➔ Entorno:%b    %s (%s)\n" "${WHITE}" "${BLUE}" "$(get_hostname)" "$(uname -m)"
    printf " %b➔ Usuario:%b    %s \n" "${WHITE}" "${BLUE}" "$USER"
    printf " %b➔ Estado:%b     %b✔ Framework initialized successfully.%b\n" "${WHITE}" "${NC}" "${BLUE}" "${NC}"
    printf "%b--------------------------------------------------%b\n\n" "${WHITE}" "${NC}"
}

# Gestion de status de servicios
action_service() {
    local name_service="$1"
    local action="$2"

    # Condicionales para mostrar accion
    case "$action" in
        start|START)
            printf '%b Iniciando el servicio %s...%b\n' "$GREEN" "$name_service" "$NC"
            log_info "Iniciando el servicio $name_service"
        ;;
        stop|STOP)
            printf '%b Deteniendo el servicio %s...%b\n' "$GREEN" "$name_service"  "$NC"
            log_info "Deteniendo el servicio $name_service"
        ;;
        reload|RELOAD)
            printf '%b Recargando el servicio %s...%b\n' "$GREEN" "$name_service"  "$NC"
            log_info "Recargando el servicio $name_service"
        ;;
        restart|RESTART)
            printf '%b Reiniciando el servicio %s...%b\n' "$GREEN" "$name_service"  "$NC"
            log_info "Reiniciando el servicio $name_service"
        ;;
        *)
            echo "Acción no válida."
            return 1
        ;;
    esac

    if systemctl "$action" "$name_service"; then
        printf '%b[✓] Acción ejecutada correctamente.%b\n' "$GREEN" "$NC"
        log_info "Acción '$action' ejecutada correctamente en '$name_service'"
        read -rp "Presione ENTER para actualizar el estado..."
    else
        printf '%b[✗] Error ejecutando la acción.%b\n' "$RED" "$NC"
        log_error "Error ejecutando acción '$action' en '$name_service'"
        return 1
    fi

}