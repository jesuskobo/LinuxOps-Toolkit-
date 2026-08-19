#!/usr/bin/env bash
# LinuxOps Toolkit - Modulo backups

# Gestiona la consulta, verifica espacio para backup

# Directorio predeterminado para almacenar respaldos.
BACKUP_DEFAULT_DIR="/var/backups/linuxops"

# RECOLECCION DE INFORMACION
backup_collect() {
    local destiny_rute="$1"
    local space_aval
    local count_backup
    local total_weight
    local latest_backups


    # Si no existe dicha ruta o carpeta se crea
    if [[ ! -d "$destiny_rute" ]];then
        sudo mkdir -p "$destiny_rute"
    fi

    # consultar espacio disponible para hacer el backup en la carpeta
    space_aval=$(df -h "$destiny_rute" |awk 'NR==2 {print $4}')

    # Cuenta cuántos archivos .tar.gz existen en esa carpeta
    count_backup=$(find "$destiny_rute" -maxdepth 1 -type f -name "*.tar.gz" | wc -l)

    # peso total de la carpeta
    total_weight=$(du -sh "$destiny_rute" |awk '{print $1}')

    # Obtener Ultimos backups
    latest_backup=$(latest_file_backup "$destiny_rute")

    # PENDIENTE PONER LAS RUTAS O ARCHIVOS QUE SE VAN A REALIZAR BACKUP

    # Devolver coleccion de valores obtenidos
    # ruta_destino|espacio_disponible|contar-archivos.tar.gz|peso_capeta_detino|ultimos_backup
    echo "${destiny_rute}|${space_aval}|${count_backup}|${total_weight}|${latest_backup}"
}
# AUXILIAR Consultar si hay respaldos en la ruta indicada
latest_file_backup(){
    local latest="$1"
    local backup

    backup=$(find "$destiny_rute" -maxdepth 1 -type f -name "*.tar.gz" -printf '%T@ %f\n' |sort -nr |head -n 5 |cut -d' ' -f2-)

    # Si la variable está vacía, retorna 
    if [[ -z "$backup" ]]; then
        echo "Sin respaldos en la ruta '$latest'."
        return 0
    fi

    # Une las líneas con ';' sin dejar uno al final
    echo "$backup" | paste -sd ';' 
}

# ORQUESTADOR LA INFORMACION
backup_evaluate() {
    
    backup_collect "$BACKUP_DEFAULT_DIR"  
    
}

# MENU DE OPCIONES
backup_menu() {

    while true; do

        printf '\n%s''-------------------------------------------------------------------------\n'
        printf 'ACCIONES - BACKUP\n'
        printf '%s\n' '-------------------------------------------------------------------------'
        printf '[1] Crear respaldo rápido de /etc\n'
        printf '[2] Crear respaldo personalizado (otra ruta)\n'
        printf '[3] Purgar respaldos antiguos (> 30 días)\n'
        printf '[4] Salir\n'
        printf '%s\n' '========================================================================='
        read -rp "Seleccione una opción: " option
        printf '%s\n' '========================================================================='
        
        # read -rp "Ingrese ruta destino [Enter = $BACKUP_DEFAULT_DIR]: " route
        case "$option" in
            1)
                read -rp "Ingrese ruta destino [Enter = $BACKUP_DEFAULT_DIR]: " route_destiny
                # si no existe una ruta valida la cual se captura con return 1  de la funcion route_correct, manda nuevamente al inicio
                if ! route_destiny=$(route_correct "$route_destiny"); then
                    read -rp "Presione ENTER para continuar..."
                    backup_refresh_screen
                    continue
                fi

                # route_destiny|etc
                backup_run "${route_destiny}|/etc"
                
                read -rp "Presione ENTER para continuar..."
                backup_refresh_screen
                ;;
            2)  
                # solicitar ruta donde se desea sacar el backup
                read -rp "Ingrese donde se desea sacar el backup: " route_origin
                # Si no existe la ruta manda mensaje y retorna al inicio
                if [[ ! -d "$route_origin" ]];then
                    echo "[!] Ingrese una ruta de origen valida." >&2
                    read -rp "Presione ENTER para continuar..."
                    backup_refresh_screen
                    continue
                fi

                # solicitar ruta donde se desea guardar el backup
                read -rp "Ingrese ruta destino [Enter = $BACKUP_DEFAULT_DIR]: " route_destiny
                # si no existe una ruta valida la cual se captura con return 1  de la funcion route_correct, manda nuevamente al inicio
                if ! route_destiny=$(route_correct "$route_destiny"); then
                    read -rp "Presione ENTER para continuar..."
                    backup_refresh_screen
                    continue
                fi

                # Normalizar rutas si estan iguales pero tienen / adicional
                route_origin=$(normalize_path "$route_origin")
                route_destiny=$(normalize_path "$route_destiny")

                #  Si la rutas Nomralizadas de origin es igual a la ruta de destino manda error y regresa al inicio
                if [[ "$route_origin" == "$route_destiny" ]];then
                    echo "[!] No se permiten rutas iguales." >&2
                    read -rp "Presione ENTER para continuar..."
                    backup_refresh_screen
                    continue
                fi

                # Llama a la funcion para realizar backup y se pasan las rutas normalizadas
                backup_run "${route_destiny}|${route_origin}"

                printf "\n"
                read -rp "Presione ENTER para continuar..."
                printf "\n"
                backup_refresh_screen
                continue

                ;;
            3)
                read -rp "Ingrese ruta donde desea purgar backups: " rute_purge
                # si no existe una ruta valida la cual se captura con return 1 y >&2 de la funcion route_correct, manda nuevamente al inicio
                if ! rute_purge=$(route_correct "$rute_purge"); then
                    read -rp "Presione ENTER para continuar..."
                    backup_refresh_screen
                    continue
                fi

                read -rp "Ingrese con cuántos días de antigüedad desea realizar la purga [30]: " days
                # si viene vacia se pone 30 dias
                [[ -z "$days" ]] && days=30
                if ! backup_run_purge "$rute_purge" "$days";then
                    read -rp "Presione ENTER para continuar..."
                    backup_refresh_screen
                    continue
                fi

                read -rp "Presione ENTER para continuar..."
                backup_refresh_screen
                ;;
            4)
                echo "Hasta prontOPS!"
                return 0
                break
                ;;
            *)
                echo "[!] Opción inválida."
                read -rp "Presione ENTER para continuar..."
                backup_refresh_screen
                ;;
        esac
        
    done
    
}
# AUXILIAR - consulta ruta si existe y si es correcta
route_correct(){
    local route="$1"

    # Si la ruta es vacia se pone una default
    if [[ -z "$route" ]]; then
        echo "$BACKUP_DEFAULT_DIR" |tr -d '\n'
        return 0
    # Si la ruta es correcta se retorna esta
    elif [[ -d "$route" ]]; then
        echo "$route"
        return 0
    fi

    echo "[!] Ingrese una ruta válida." >&2
    return 1
}
# AUXILIAR - refresca la pantalla
backup_refresh_screen() {
    local output
    output=$(backup_evaluate)
    
    if [ $? -eq 0 ]; then
        clear
        render_backup_screen "$output"
    fi
}
# AUXILIAR - normalizar ruta destino y final
normalize_path() {
    local path="$1"

    # Eliminar / finales excepto en la raíz.
    while [[ "$path" != "/" && "$path" == */ ]]; do
        path="${path%/}"
    done

    echo "$path"
}

# FUNCION QUE REALIZA LOS BACKUPS
# para poner en readme tanto la ruta destino como la final siempre debe ser la ruta exacta valida
backup_run() {
    local raw_data="$1"
    local filename
    local backup_file
    local size

    # Destino= hacia donde va el archivo
    # origen= cual es el archivo a realizar backup
    local destiny origen
    IFS='|' read -r destiny origen <<< "$raw_data"

    # Asegurar que el destino termine en barra diagonal /
    [[ "$destiny" != */ ]] && destiny="${destiny}/"

    # formatear nombre del backup
    filename="Backup_$(date +%Y-%m-%d_%H%M%S).tar.gz"
    backup_file="${destiny}${filename}"
    
    
    # Aviso creando backup
    printf '[+] Creando backup, por favor espere...\n'
    # aviso en Logs creando backup
    log_info "Iniciando backup: origen='$origen' destino='$backup_file'"
    # Crear backup
    if sudo tar -czf "$backup_file" --checkpoint=100 --checkpoint-action=dot -C "$origen" .; then
        
        # consultar tamalo del backup realizado
        size=$(du -sh "$backup_file" | awk '{print $1}')

        # Informar en logs backup realizado
        log_info "Backup completado: archivo='$backup_file' tamaño='$size'"
        
        # Renderizar salida de backup realizado
        printf '\n%b[✓] Backup realizado exitosamente%b\n' "$GREEN" "$NC"
        printf '    Origen : %s\n' "$origen"
        printf '    Destino: %s\n' "$destiny"
        printf '    archivo: %s\n' "$filename"
        printf '    Tamaño : %s\n' "$size"
        
    else
        log_error "Error al crear backup: origen='$origen' destino='$backup_file'"
        printf '\n%b[✗] Error al realizar el backup%b\n' "$RED" "$NC"
        return 1
    fi
}
# Purgar o borrar backup mayor a cierto tiempo
# para el reame menciona que hace backups con consultando la estructura backup_*.tar.gz
backup_run_purge() {
    local destiny="$1"
    local days="$2"
    local backups

    # Validar que la ruta destino no esté vacía
    if [[ -z "$destiny" ]]; then
        echo "[!] Ruta destino vacía." >&2
        return 1
    fi

    # Validar que los días no estén vacíos y sean un número
    if ! [[ "$days" =~ ^[1-9][0-9]*$ ]]; then
        echo "[!] El número de días debe ser un entero mayor que 0." >&2
        return 1
    fi

    # Buscar backups antiguos
    backups=$(find "$destiny" \
        -maxdepth 1 \
        -type f \
        -iname "backup_*.tar.gz" \
        -mtime +"$days" \
        -printf '%f\n' |
        paste -sd ';')

    # No hay backups para purgar
    if [[ -z "$backups" ]]; then
        printf '[!] No se encontraron respaldos con más de %s días.\n' "$days"
        return 0
    fi

    printf '%b\n[!] Respaldos que serán purgados:%b\n' "$GREEN" "$NC"
    printf '%s\n\n' "$backups" | tr ';' '\n'


    read -rp "¿Está seguro que desea realizar la purga? [s/N]: " confirm
    case "$confirm" in
        s | S)

            # Informar purga y guardar logs
            printf '[+] Purgando respaldos con más de %s días...\n' "$days" 
            log_info "Purga confirmada: ruta='$destiny' antigüedad='${days} días'"

            # Borrar backups encontrados
            find "$destiny" \
                -maxdepth 1 \
                -type f \
                -iname "backup_*.tar.gz" \
                -mtime +"$days" \
                -delete

            printf '%b[✓] Purga realizada exitosamente.%b\n\n' "$GREEN" "$NC"
            log_info "Purga completada: ruta='$destiny' antigüedad='${days} días'"
        ;;
        n |N | "")
            echo "Operacion cancelada" >&2
            log_info "Purga cancelada por el usuario: ruta='$destiny'"
            return 1
        ;;
        *)
            printf '[!] Opción inválida.\n' >&2
            log_error "Ruta de backup inválida: '$route'"
            return 1
        ;;
    esac
}