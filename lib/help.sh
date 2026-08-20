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

# AYUDA DEL MODULO ADMIN
show_admin_help() {

cat <<EOF

LINUXOPS - ADMIN

Uso:
    linuxops admin <comando> [opciones]

Comandos disponibles:

    service     Gestión y diagnóstico de servicios systemd
    backup      Gestión de respaldos del sistema

------------------------------------------------------------------------
SERVICES
------------------------------------------------------------------------

Uso:
    linuxops admin service <acción> <servicio>

Acciones disponibles:

    status <servicio>      Consulta el estado y diagnóstico del servicio
    start <servicio>       Inicia el servicio
    stop <servicio>        Detiene el servicio
    restart <servicio>     Reinicia el servicio
    reload <servicio>      Recarga la configuración del servicio

Ejemplos:

    linuxops admin service sshd
    linuxops admin service status sshd
    linuxops admin service start sshd
    linuxops admin service stop sshd
    linuxops admin service restart sshd
    linuxops admin service reload sshd

Ejemplo de consulta:

    linuxops admin service status sshd

    Muestra:
        - Estado del servicio
        - PID principal
        - CPU
        - Memoria
        - Tiempo activo
        - Inicio automático
        - Puertos en escucha
        - Diagnóstico
        - Menú de acciones


------------------------------------------------------------------------
BACKUPS
------------------------------------------------------------------------

Uso:
    linuxops admin backup

Descripción:

    Abre el menú interactivo de gestión de respaldos.

Funciones disponibles:

    [1] Crear respaldo rápido de /etc
    [2] Crear respaldo personalizado (otra ruta)
    [3] Purgar respaldos antiguos (defecto 30 días)
    [4] Salir

Los respaldos se generan en formato:

    Backup_YYYY-MM-DD_HHMMSS.tar.gz

Directorio predeterminado:

    /var/backups/linuxops


------------------------------------------------------------------------
OPCIONES GENERALES
------------------------------------------------------------------------

    -h, --help      Mostrar esta ayuda

Ejemplos:

    linuxops admin --help
    linuxops admin service --help
    linuxops admin backup

EOF

}