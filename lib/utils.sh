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

show_banner() {
    # Renderizado del Banner Visual del Framework
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
    printf "       » T O O L K I T  |  v%s «\n\n" "${APP_VERSION:-1.0.0}"


    #Bloque de Metadatos Estructurados (Información del Sistema)
    printf "%b--------------------------------------------------%b\n" "${WHITE}" "${NC}"
    printf " %b➔ Core:%b       %s v%s\n" "${WHITE}" "${BLUE}" "${APP_NAME}" "${APP_VERSION}"
    printf " %b➔ Entorno:%b    %s (%s)\n" "${WHITE}" "${BLUE}" "$(get_hostname)" "$(uname -m)"
    printf " %b➔ Sesión:%b     %s @ %s\n" "${WHITE}" "${BLUE}" "$USER" "$CURRENT_TIME"
    printf " %b➔ Estado:%b     %b✔ Framework initialized successfully.%b\n" "${WHITE}" "${NC}" "${BLUE}" "${NC}"
    printf "%b--------------------------------------------------%b\n" "${WHITE}" "${NC}"


}