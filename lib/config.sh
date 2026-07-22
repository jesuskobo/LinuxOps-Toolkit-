#!/usr/bin/env bash
# LinuxOps Toolkit - Cargar la configuracion en la ruta CONFIG thresholds.conf


APP_NAME="LinuxOps Toolkit"
APP_VERSION="0.1.0"

load_configurations () {
    local ruta="${PROJECT_ROOT}/config/thresholds.conf"

    if [ -f "$ruta" ]; then
        source "${ruta}"
        log_info "configuracion de umbrales cargada existosamente"
    else
        log_warn "No se encontró thresholds.conf. Se utilizarán valores por defecto."
    fi

}