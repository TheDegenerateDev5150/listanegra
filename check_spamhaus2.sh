#!/bin/bash
# check_spamhaus_v2.sh — versión mejorada: usa servidores Spamhaus rotados, timeouts largos
# Reanuda desde caché

set -u

CACHE="/tmp/blacklist/cache_spamhaus.txt"
INPUT_IPS="$1"

# Servidores DNS a rotar (Spamhaus recomienda usar los propios)
# Alternativa: usar DNS del ISP del operador
SERVERS=("127.0.0.1" "1.1.1.1" "8.8.8.8" "9.9.9.9" "80.58.61.250" "80.58.61.254")
n_srvs=${#SERVERS[@]}

pending=0
total=$(wc -l < "$INPUT_IPS")
i=0
echo "[$(date +%H:%M:%S)] Reanudando desde caché. Pendientes por procesar: $total"

while read -r ip; do
    i=$((i+1))
    # ¿Está en caché?
    if grep -qE "^(LISTED|CLEAN) $ip " "$CACHE" 2>/dev/null; then
        continue
    fi
    pending=$((pending+1))
    rev=$(echo "$ip" | awk -F. '{print $4"."$3"."$2"."$1}')
    srv=${SERVERS[$((pending % n_srvs))]}
    result=$(dig +short +time=5 +tries=2 "@$srv" "${rev}.zen.spamhaus.org" A 2>/dev/null | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    if [[ -n "$result" ]]; then
        echo "LISTED $ip -> $result" >> "$CACHE"
    else
        echo "CLEAN $ip" >> "$CACHE"
    fi
    if (( i % 100 == 0 )); then
        echo "[$(date +%H:%M:%S)] Procesadas: $i / $total (pendientes: $pending)" >&2
    fi
done < "$INPUT_IPS"

echo "[$(date +%H:%M:%S)] Finalizado. Total nuevas procesadas: $pending" >&2

