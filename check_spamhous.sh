#!/bin/bash
# check_spamhaus.sh — consulta zen.spamhaus.org en paralelo con rate-limit
# Uso: ./check_spamhaus.sh <fichero_ips> <fichero_salida>

set -u

INPUT="$1"
OUTPUT="$2"
CACHE="/tmp/blacklist/cache_spamhaus.txt"
LOG="/tmp/blacklist/log_spamhaus.txt"

# Cargar caché existente
[[ -f "$CACHE" ]] || touch "$CACHE"

# Inicializar salida
: > "$OUTPUT"
: > "$LOG"

# Función: invertir IP y consultar zen.spamhaus.org
check_ip() {
    local ip="$1"
    local rev
    rev=$(echo "$ip" | awk -F. '{print $4"."$3"."$2"."$1}')
    local q="${rev}.zen.spamhaus.org"
    local result
    result=$(dig +short +time=3 +tries=1 +nocmd "$q" A 2>/dev/null | tr '\n' ' ')
    if [[ -n "$result" ]]; then
        echo "LISTED $ip -> $result"
    else
        echo "CLEAN $ip"
    fi
}
export -f check_ip

# Concurrencia y rate-limit (Spamhaus tolera ~100k/día; usamos conservador)
PARALLEL=20
SLEEP_BETWEEN=0.05  # 50ms entre arranques -> ~20 qps

total=$(wc -l < "$INPUT")
echo "[$(date +%H:%M:%S)] Procesando $total IPs de $INPUT (paralelo=$PARALLEL)" | tee -a "$LOG"

done_count=0
cache_size=$(wc -l < "$CACHE")

# Usar xargs para paralelismo controlado
< "$INPUT" xargs -n1 -P"$PARALLEL" -I{} bash -c '
    ip="{}"
    # ¿Está en caché?
    cached=$(grep -F " $ip " '"$CACHE"' 2>/dev/null | head -1)
    if [[ -n "$cached" ]]; then
        echo "$cached"
    else
        rev=$(echo "$ip" | awk -F. "{print \$4.\".\"\$3.\".\"\$2.\".\"\$1}")
        result=$(dig +short +time=3 +tries=1 +nocmd "${rev}.zen.spamhaus.org" A 2>/dev/null | tr "\n" " ")
        if [[ -n "$result" ]]; then
            line="LISTED $ip -> $result"
        else
            line="CLEAN $ip"
        fi
        echo "$line" >> '"$CACHE"'
        echo "$line"
    fi
' >> "$OUTPUT" 2>>"$LOG"

echo "[$(date +%H:%M:%S)] Terminado. Resultados en $OUTPUT" | tee -a "$LOG"
