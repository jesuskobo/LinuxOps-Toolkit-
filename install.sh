#!/usr/bin/env bash
# LinuxOps Toolkit - Script de Instalación Global
# Permite instalar, actualizar y vincular la herramienta en el PATH del sistema.

set -Eeuo pipefail
trap 'echo -e "\n${RED}La instalación falló.${NC}"' ERR

INSTALL_DIR="/opt/linuxops"
BIN_LINK="/usr/local/bin/linuxops"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colores para salida interactiva
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
NC=$'\033[0m' # No Color

# 1. Checker si el usuario que va a realizar instalacion en usuario ROOT
check_root() {
    if [ "${EUID}" -ne 0 ]; then
        echo "${YELLOW}Este script debe ejecutarse con privilegios root o usando sudo: sudo ./install.sh ${NC}"
        exit 1
    fi
}

# 2. Checkear si todas las dependencias solicitadas existen
check_dependencies(){
    local deps=("bash" "awk" "grep" "sed" "getent" "who" "w" "journalctl" "ps" "systemctl" "ss" "find" "du" "date")
    local missing=() # agregar comandos que faltan

    for cmd in "${deps[@]}"; do
        if ! command -v "$cmd" &>/dev/null;then
            missing+=("$cmd")
        fi

    done

    if ((${#missing[@]}> 0 ));then
        echo "${YELLOW}Faltan comandos requeridos en el sistema: ${missing[*]} ${NC}"
        exit 1
    fi

    echo "Todas las dependencias requeridas están presentes"

}

# 3. Copiar o actualizar archivos en /opt/linuxops
install_files() {

    echo "Instalando LinuxOps Toolkit..."

    # Protección contra borrados accidentales
    [[ "$INSTALL_DIR" == "/opt/linuxops" ]] || {
        echo "ERROR: Ruta de instalación inválida: $INSTALL_DIR"
        exit 1
    }

    # Crear estructura base
    mkdir -p "$INSTALL_DIR"

    echo "Actualizando archivos del programa..."

    # -------------------------------------------------------------------------
    # Eliminar únicamente el código de LinuxOps.
    # Nunca borrar configuración, logs ni reportes del usuario.
    # -------------------------------------------------------------------------
    local code_dirs=(
        assets
        bin
        core
        lib
        modules
        templates
    )

    for dir in "${code_dirs[@]}"; do
        rm -rf "${INSTALL_DIR}/${dir}"
    done

    # -------------------------------------------------------------------------
    # Copiar nueva versión del programa
    # -------------------------------------------------------------------------
    for dir in "${code_dirs[@]}"; do
        cp -a "${SOURCE_DIR}/${dir}" "${INSTALL_DIR}/"
    done

    # -------------------------------------------------------------------------
    # Configuración
    # - Si es la primera instalación, se copia todo.
    # - Si ya existe, solo se agregan archivos nuevos sin sobrescribir
    #   la configuración personalizada del usuario.
    # -------------------------------------------------------------------------
    mkdir -p "${INSTALL_DIR}/config"

    cp -an "${SOURCE_DIR}/config/." "${INSTALL_DIR}/config/"

    # -------------------------------------------------------------------------
    # Directorios persistentes
    # -------------------------------------------------------------------------
    mkdir -p "${INSTALL_DIR}/logs"
    mkdir -p "${INSTALL_DIR}/reports"

    # Permitir que el usuario ejecute LinuxOps y escriba logs/reportes
    chown -R "${SUDO_USER}:${SUDO_USER}" "${INSTALL_DIR}/logs" "${INSTALL_DIR}/reports"

    # -------------------------------------------------------------------------
    # Permisos
    # -------------------------------------------------------------------------
    chmod +x "${INSTALL_DIR}/bin/linuxops"

    echo "LinuxOps Toolkit actualizado correctamente."

}

# 4. Crear enlace simbólico en /usr/local/bin
create_symlink() {
    echo "Creando enlace simbólico en ${BIN_LINK}..."

    if [[ -e "$BIN_LINK" || -L "$BIN_LINK" ]]; then
        rm -f "$BIN_LINK"

    fi

    ln -s "${INSTALL_DIR}/bin/linuxops" "$BIN_LINK"
    echo "Enlace simbólico creado correctamente."

}


# Ejecucion todo
main(){

    printf "${GREEN}"
    printf "=============================================================\n"
    printf "               LinuxOps Toolkit Installer\n"
    printf "        Enterprise Linux Audit & Monitoring Toolkit\n"
    printf "=============================================================\n"
    printf "${NC}\n"

    check_root
    check_dependencies
    install_files
    create_symlink

    echo
    printf "${GREEN}✔ Instalación completada correctamente.${NC}\n"
    echo
    echo "Ahora puede ejecutar LinuxOps desde cualquier ubicación:"
    echo
    printf "    ${BLUE}linuxops${NC}\n"
    echo
}

main
