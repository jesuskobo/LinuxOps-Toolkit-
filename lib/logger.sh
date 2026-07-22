#!/usr/bin/env bash
# LinuxOps Toolkit - Registro Interno de Eventos (Logger)

#definir la ruta absoluta donde se guardar el log
LOG_FILE="${PROJECT_ROOT}/logs/linuxops.log"


#funcion para escribir en un log
log_msg() {
    local nivel=$1
    local message=$2
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")


    #si la carpeta del log no existe por alguna razon la crea
    [[ ! -d "${PROJECT_ROOT}/logs" ]] && mkdir -p "${PROYECT_ROOT}/logs"

    #Se guarda tanto el la hora exacta nivel y mensaje en la ruta del LOG_FILE
    echo "[${timestamp} ${nivel}] $message" >> "$LOG_FILE"

}

#Funciones auxiliares para organizar la entrada del LOG
log_info() { 
    local mensaje="$1"  # Dejamos claro qué es $1
    log_msg "INFO" "$mensaje"
}

log_warn() { 
    local mensaje="$1"
    log_msg "WARN" "$mensaje"
}

log_error() { 
    local mensaje="$1"
    log_msg "ERROR" "$mensaje"
}   
