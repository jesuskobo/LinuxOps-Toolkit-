#!/usr/bin/env bash
# LinuxOps Toolkit - Script de Desinstalación
# Elimina la instalación global de LinuxOps Toolkit.

set -Eeuo pipefail

# -------------------------------------------------------------------------
# CONFIGURACIÓN
# -------------------------------------------------------------------------

INSTALL_DIR="/opt/linuxops"
BIN_LINK="/usr/local/bin/linuxops"

# Colores
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
NC=$'\033[0m'


# -------------------------------------------------------------------------
# VALIDAR PRIVILEGIOS
# -------------------------------------------------------------------------

check_root() {

    if [[ "$EUID" -ne 0 ]]; then
        printf '%bEste script debe ejecutarse con sudo.%b\n' "$YELLOW" "$NC"
        printf 'Ejemplo: sudo ./uninstall.sh\n'
        exit 1
    fi

}


# -------------------------------------------------------------------------
# CONFIRMAR DESINSTALACIÓN
# -------------------------------------------------------------------------

confirm_uninstall() {

    printf '\n%b=============================================================%b\n' "$RED" "$NC"
    printf '%b              LinuxOps Toolkit Uninstaller%b\n' "$RED" "$NC"
    printf '%b=============================================================%b\n\n' "$RED" "$NC"

    printf 'Se eliminará la instalación ubicada en:\n'
    printf '    %s\n' "$INSTALL_DIR"

    printf '\nTambién se eliminará el enlace:\n'
    printf '    %s\n\n' "$BIN_LINK"

    printf '%bADVERTENCIA: Esto eliminará también logs, configuración y reportes.%b\n\n' \
        "$YELLOW" "$NC"

    read -rp "¿Desea continuar? [s/N]: " confirm

    case "$confirm" in
        s|S)
            return 0
            ;;
        *)
            printf '%bDesinstalación cancelada.%b\n' "$YELLOW" "$NC"
            exit 0
            ;;
    esac
}


# -------------------------------------------------------------------------
# ELIMINAR ENLACE SIMBÓLICO
# -------------------------------------------------------------------------

remove_symlink() {

    if [[ -L "$BIN_LINK" ]]; then

        printf '[+] Eliminando enlace %s...\n' "$BIN_LINK"

        rm -f "$BIN_LINK"

        printf '%b[✓] Enlace eliminado.%b\n' "$GREEN" "$NC"

    elif [[ -e "$BIN_LINK" ]]; then

        printf '%b[!] Existe un archivo en %s pero no es un enlace simbólico.%b\n' \
            "$YELLOW" "$BIN_LINK" "$NC"

        printf '%bNo se eliminará automáticamente por seguridad.%b\n' \
            "$YELLOW" "$NC"

    else

        printf '[i] El enlace no existe.\n'

    fi
}


# -------------------------------------------------------------------------
# ELIMINAR INSTALACIÓN
# -------------------------------------------------------------------------

remove_installation() {

    # Protección contra una ruta incorrecta
    if [[ "$INSTALL_DIR" != "/opt/linuxops" ]]; then
        printf '%bERROR: Ruta de instalación inválida: %s%b\n' \
            "$RED" "$INSTALL_DIR" "$NC"
        exit 1
    fi

    if [[ -d "$INSTALL_DIR" ]]; then

        printf '[+] Eliminando instalación de LinuxOps...\n'

        rm -rf "$INSTALL_DIR"

        printf '%b[✓] Instalación eliminada.%b\n' "$GREEN" "$NC"

    else

        printf '[i] No existe %s.\n' "$INSTALL_DIR"

    fi
}


# -------------------------------------------------------------------------
# EJECUCIÓN PRINCIPAL
# -------------------------------------------------------------------------

main() {

    check_root
    confirm_uninstall
    remove_symlink
    remove_installation

    printf '\n'
    printf '%b✔ LinuxOps Toolkit fue desinstalado correctamente.%b\n' \
        "$GREEN" "$NC"
    printf '\n'
}


main