#!/usr/bin/env bash
# LinuxOps Toolkit - Cargar la configuracion en la ruta CONFIG thresholds.conf


APP_NAME="LinuxOps Toolkit"
APP_VERSION="0.1.0"

load_configurations () {
    local ruta_thresh="${PROJECT_ROOT}/config/thresholds.conf"
    local ruta_recom="${PROJECT_ROOT}/config/recommendations.conf"

    # 1. cargar thresholds.conf
    if [ -f "$ruta_thresh" ]; then
        source "${ruta_thresh}"
        log_info "configuracion de umbrales thresholds cargada existosamente"
    else
        log_warn "No se encontró thresholds.conf. Se utilizarán valores por defecto."
    fi

    # 2. Cargar recomendaciones.conf
    if [ -f "$ruta_recom" ]; then
        source "${ruta_recom}"
        log_info "Configuración de recomendaciones cargada exitosamente."
    else
        log_warn "Configuración de recomendaciones cargada exitosamente. Se utilizarán valores por defecto."
    fi


}