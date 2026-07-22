#!/usr/bin/env bash
# LinuxOps Toolkit - Validar que todo los programas usados esten instalados.

check_binary() {
    local cmd="$1"

    if ! command -v "$cmd" > /dev/null 2>&1; then
        printf "%sEl ejecutable requerido %s no se encuentra instalado%s\n" "${RED}" "$cmd" "${NC}"
        log_error "El ejecutable requerido $cmd no esta instalado en el sistema"
        return 1
    fi

    return 0
}

check_dependencies() {
    local cmd_list=("lsof" "ip" "sudo" "rsync" "systemctl" "journalctl" "lsof")

    for list in ${cmd_list[@]}; do
        check_binary "$list"
    done
}

check_dependencies 