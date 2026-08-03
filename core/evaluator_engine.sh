#!/usr/bin/env bash
# LinuxOps Toolkit - Motor de Priorización de Recomendaciones

# =============================================================================
# Construye una tabla de recomendaciones priorizadas.
#
# Entrada:
#   MODULO|ESTADO|RECOMENDACION;
#   MODULO|ESTADO|RECOMENDACION;
#   ...
#
# Ejemplo:
#   CPU|WARNING|Revisar procesos;
#   MEMORIA|CRITICAL|Liberar memoria;
#   RED|OK|Sin novedades
#
# Salida:
#   🔴 [HIGH]|MEMORIA|Liberar memoria;
#   🟡 [MED]|CPU|Revisar procesos;
#   🟢 [LOW]|RED|Sin novedades
#
# Funcionamiento:
#   1. Divide la tabla en filas.
#   2. Agrega una prioridad numérica temporal para ordenar.
#   3. Ordena de mayor a menor prioridad.
#   4. Elimina la prioridad numérica.
#   5. Reconstruye la tabla usando ';' como separador.
# =============================================================================
build_prioritized_advice() {

    local table="$1"
    local output=""

    local rows
    IFS=';' read -ra rows <<< "$table"

    local row
    for row in "${rows[@]}"; do

        # Ignorar filas vacías
        [[ -z "$row" ]] && continue

        local module status recommendation
        IFS='|' read -r module status recommendation <<< "$row"

        output+="$(decorate_recommendation \
            "$module" \
            "$status" \
            "$recommendation")"$'\n'

    done

    # Ordenar por prioridad y reconstruir la tabla
    local sorted
    sorted=$(
        echo "$output" |
        sort -t'|' -k1,1n |
        cut -d'|' -f2-
    )

    echo "$sorted" | paste -sd';' -
}

# =============================================================================
# Agrega una prioridad a una recomendación.
#
# Parámetros:
#   $1 -> Módulo
#   $2 -> Estado (OK/WARNING/CRITICAL)
#   $3 -> Recomendación
#
# La prioridad numérica sólo se utiliza para ordenar:
#
#   1 -> CRITICAL
#   2 -> WARNING
#   3 -> OK
#   9 -> Desconocido
#
# Salida:
#   PRIORIDAD|LABEL|MODULO|RECOMENDACION
#
# Ejemplo:
#   1|🔴 [HIGH]|CPU|Reducir carga
# =============================================================================
decorate_recommendation() {

    local module="$1"
    local status="$2"
    local recommendation="$3"

    local priority label

    case "$status" in
        CRITICAL)
            priority=1
            label="🔴 [HIGH]"
        ;;
        WARNING)
            priority=2
            label="🟡 [MED]"
        ;;
        OK)
            priority=3
            label="🟢 [LOW]"
        ;;
        *)
            priority=9
            label="⚪ [N/A]"
        ;;
    esac

    echo "$priority|$label|$module|$recommendation"
}