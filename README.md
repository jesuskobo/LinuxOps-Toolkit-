# 🐧 LinuxOps Toolkit

**LinuxOps Toolkit** es una herramienta CLI modular desarrollada en **Bash** para el diagnóstico, auditoría y administración de sistemas Linux.

Está diseñada con una arquitectura modular que permite consultar el estado del sistema, administrar servicios, realizar respaldos y registrar eventos relacionados con la operación de la herramienta.

> **Estado:** `v0.1.0 — Desarrollo activo`

---

## 🎯 Características

### System

Permite consultar y diagnosticar diferentes componentes del sistema:

- CPU
- Memoria RAM
- Disco
- Red
- Procesos
- Usuarios
- Información general del sistema
- Auditoría completa del sistema

### Admin

Actualmente incluye:

- Gestión y diagnóstico de servicios `systemd`
- Consulta de estado de servicios
- Gestión de servicios: iniciar, detener, reiniciar y recargar
- Consulta de logs de servicios
- Detección de puertos asociados a servicios
- Creación de backups `.tar.gz`
- Backup rápido de `/etc`
- Backups personalizados
- Purga de backups antiguos
- Registro de eventos mediante logs

---

## 🏗️ Arquitectura

LinuxOps utiliza una arquitectura modular para separar la lógica de ejecución, presentación, configuración y funcionalidades.

```text
LinuxOps-Toolkit/
│
├── bin/
│   └── linuxops
│
├── core/
│   ├── router.sh
│   ├── evaluator_engine.sh
│   ├── health_score.sh
│   └── render_engine.sh
│
├── lib/
│   ├── colors.sh
│   ├── config.sh
│   ├── help.sh
│   ├── logger.sh
│   ├── progress.sh
│   ├── recommendations.sh
│   ├── utils.sh
│   └── validator.sh
│
├── modules/
│   ├── system/
│   │   ├── router.sh
│   │   ├── cpu.sh
│   │   ├── memory.sh
│   │   ├── disk.sh
│   │   ├── network.sh
│   │   ├── process.sh
│   │   ├── users.sh
│   │   └── sysinfo.sh
│   │
│   └── admin/
│       ├── router.sh
│       ├── services.sh
│       └── backups.sh
│
├── config/
├── templates/
├── reports/
├── logs/
│
├── install.sh
├── uninstall.sh
└── README.md
```

---

## ⚙️ Requisitos

LinuxOps está diseñado para sistemas Linux que utilicen `systemd`.

### Dependencias

- Bash
- systemd
- `awk`
- `grep`
- `sed`
- `find`
- `tar`
- `journalctl`
- `ps`
- `ss`

Algunas operaciones administrativas requieren privilegios de `sudo`.

---

# 🚀 Instalación

## 1. Clonar el repositorio

```bash
git clone https://github.com/jesuskobo/LinuxOps-Toolkit-.git
cd LinuxOps-Toolkit
```

## 2. Ejecutar el instalador

```bash
sudo ./install.sh
```

El instalador realiza las siguientes acciones:

- Verifica privilegios de administrador.
- Comprueba las dependencias necesarias.
- Instala LinuxOps en `/opt/linuxops`.
- Copia la estructura del proyecto.
- Crea los directorios necesarios.
- Configura los permisos de ejecución.
- Crea un enlace simbólico global.

El enlace global se crea en:

```text
/usr/local/bin/linuxops
```

Después de instalarlo, LinuxOps puede ejecutarse desde cualquier ubicación:

```bash
linuxops
```

---

# 🗑️ Desinstalación

Para eliminar LinuxOps del sistema:

```bash
sudo ./uninstall.sh
```

El proceso elimina la instalación ubicada en:

```text
/opt/linuxops
```

y el enlace simbólico:

```text
/usr/local/bin/linuxops
```

---

# 📖 Uso

## Ayuda general

```bash
linuxops --help
```

## Información del sistema

### CPU

```bash
linuxops system cpu
```

### Memoria

```bash
linuxops system memory
```

### Disco

```bash
linuxops system disk
```

### Red

```bash
linuxops system network
```

### Procesos

```bash
linuxops system process
```

### Usuarios

```bash
linuxops system users
```

### Información general

```bash
linuxops system sysinfo
```

### Auditoría completa

```bash
linuxops system all
```

---

# ⚙️ Administración

## Servicios

LinuxOps permite consultar y administrar servicios `systemd`.

```bash
linuxops admin services
```

Entre las operaciones disponibles se encuentran:

- Consultar estado
- Reiniciar
- Detener
- Recargar
- Consultar logs
- Consultar PID
- Consultar consumo de CPU y memoria
- Consultar tiempo activo
- Detectar puertos asociados al proceso

---

# 💾 Sistema de Backups

LinuxOps incluye un módulo para crear y administrar respaldos comprimidos utilizando `tar.gz`.

```bash
linuxops admin backup
```

Actualmente permite:

```text
[1] Crear respaldo rápido de /etc
[2] Crear respaldo personalizado
[3] Purgar respaldos antiguos
[4] Salir
```

## Backup rápido de `/etc`

La opción de backup rápido utiliza `/etc` como origen.

```text
Origen:
    /etc
```

El directorio de destino puede ser seleccionado durante la ejecución.

## Backup personalizado

Permite especificar:

```text
Ruta de origen
Ruta de destino
```

Por ejemplo:

```text
Origen:
    /var/www

Destino:
    /var/backups/linuxops
```

## Formato de los backups

Los archivos generados utilizan el siguiente formato:

```text
Backup_YYYY-MM-DD_HHMMSS.tar.gz
```

Ejemplo:

```text
Backup_2026-08-19_140919.tar.gz
```

## Directorio predeterminado

Los backups se almacenan por defecto en:

```text
/var/backups/linuxops
```

## Purga de backups

LinuxOps permite eliminar backups antiguos según una cantidad de días definida por el usuario.

Por ejemplo:

```text
Purgar respaldos con más de 30 días
```

La purga únicamente considera archivos que coincidan con:

```text
backup_*.tar.gz
```

---

# 📝 Sistema de Logs

LinuxOps incorpora un sistema interno de registro de eventos.

Los logs se almacenan en:

```text
/opt/linuxops/logs/linuxops.log
```

El sistema utiliza diferentes niveles:

```text
INFO
WARN
ERROR
```

Ejemplo:

```text
[2026-08-19 19:30:21 INFO] Framework LinuxOps-Toolkit inicializado
```

Los logs permiten registrar eventos importantes relacionados con:

- Inicialización del framework
- Errores
- Operaciones administrativas
- Acciones sobre servicios
- Eventos relevantes del sistema

---

# 📸 Capturas

Las siguientes capturas muestran algunas de las funcionalidades principales de LinuxOps Toolkit.

## Dashboard

![LinuxOps Dashboard](docs/screenshots/system-all.png)

## Gestión de servicios

![LinuxOps Services](docs/screenshots/services.png)

## Sistema de backups

![LinuxOps Backups](docs/screenshots/backup.png)

> Las capturas se irán actualizando conforme evolucionen los módulos del proyecto.

---

# 🗺️ Roadmap

## v0.1.0 — Core & Administración

- [x] Arquitectura modular
- [x] Sistema de routing
- [x] Health Score
- [x] Sistema de logs
- [x] Módulo `system`
- [x] Gestión de servicios
- [x] Sistema de backups
- [x] Instalador
- [x] Desinstalador
- [x] Sistema de ayuda

## Próximas versiones

### Administración

- [ ] Gestión de archivos
- [ ] Gestión avanzada de procesos

### Seguridad

- [ ] Auditoría de firewall
- [ ] UFW / Firewalld / iptables
- [ ] SSH hardening
- [ ] Auditoría de permisos
- [ ] Detección de binarios SUID/SGID
- [ ] Auditoría de actualizaciones y kernel

### Monitoring

- [ ] Parser de errores de `journalctl` / `syslog`
- [ ] Dashboard de recursos
- [ ] Sistema de monitoreo

### Reportes

- [ ] Exportación JSON
- [ ] Generación automática de reportes
- [ ] Reportes estructurados

### Calidad

- [ ] Tests automatizados
- [ ] Documentación técnica ampliada

---

# 🛠️ Tecnologías

LinuxOps Toolkit está desarrollado principalmente utilizando:

- **Bash**
- **Linux**
- **systemd**
- **Git**
- `tar`
- `awk`
- `sed`
- `grep`
- `find`
- `journalctl`
- `ps`
- `ss`

---

# 🎯 Objetivo del proyecto

LinuxOps Toolkit es un proyecto orientado a la administración y automatización de sistemas Linux mediante una arquitectura CLI modular desarrollada en Bash.

El proyecto busca aplicar conceptos de:

- Administración Linux
- Bash scripting
- Automatización
- Troubleshooting
- Administración de servicios
- Backups
- Observabilidad
- Infraestructura
- DevOps

El roadmap contempla la incorporación progresiva de tecnologías y prácticas relacionadas con:

- Docker
- CI/CD
- Cloud
- Terraform
- Kubernetes

---

# 📄 Licencia

Copyright © 2026 Jesús Rivera. Todos los derechos reservados.

LinuxOps Toolkit es software propietario. El código fuente se publica
con fines de evaluación técnica y portafolio. Cualquier uso, copia,
modificación o distribución requiere autorización previa y expresa
del autor.

---