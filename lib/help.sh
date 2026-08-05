#!/usr/bin/env bash
# LinuxOps Toolkit - Biblioteca de ayuda

# AYUDA GENERAL
show_help() {
cat <<EOF
Uso:
    linuxops <comando> <subcomando>

Comandos disponibles:

    system     Información de los distintos sistemas
    admin      Gestion y administracion

Ejemplos:

    linuxops system <subcomando>
    linuxops admin  <subcomando>

Opciones:

    -h, --help      Mostrar esta ayuda

EOF
}

# AYUDA DEL MODULO SYSTEM
show_system_help() {
cat <<EOF
Uso:
    linuxops system <comando>

Comandos disponibles:

    cpu         Información del procesador
    memory      Estado de la memoria RAM
    disk        Uso del almacenamiento
    network     Diagnóstico de red
    process     Procesos del sistema
    users       Auditoría de usuarios
    sysinfo     Información general del sistema
    all         Auditoría completa

Ejemplos:

    linuxops system cpu
    linuxops system memory
    linuxops system disk
    linuxops system network
    linuxops system process
    linuxops system users
    linuxops system sysinfo
    linuxops system all

Opciones:

    -h, --help      Mostrar esta ayuda

EOF
}