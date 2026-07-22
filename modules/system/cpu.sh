#!/usr/bin/env bash
# LinuxOps Toolkit - Módulo de Monitoreo de CPU

cpu_collect() {
    local usage_cpu=$(top -bn1 |grep "Cpu(s)" |awk '{print 100 - $8}' | cut -d. -f1)
    printf "$usage_cpu"
}

cpu_evaluate() {
    local usage=$(cpu_collect)
    local status="OK"

    if [ "$usage" -ge "$CPU_CRIT_THRESHOLD" ]; then
        status="CRITICAL"


    elif [ "$usage" -ge "$CPU_WARN_THRESHOLD" ]; then
        status="WARNING"

    else
        status="OK"
    fi

    render_status "CPU" "${usage}%" "$status" "$CPU_REC"
}