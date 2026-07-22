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