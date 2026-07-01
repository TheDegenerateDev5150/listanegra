#!/bin/sh

# Script simple para verificar IP publica listada  en Spamhaus"
# Verifica si una IP esta en Lista Negra, por SAPM de email
# Las IPv4 suelen ser listadas tras el primer envio SPAM
# Las IPv6 raramente son las litadas en BlackList
# (R) hackingyseguridad.com 2026
# @antonio_taboada


#!/usr/bin/env bash

#
# ipcheck.sh
#
# Analiza una dirección IP pública
#
# Funciones:
#   - Whois
#   - PTR
#   - Geolocalización
#   - Shodan InternetDB
#   - Nmap
#   - Traceroute
#   - Comprobación Spamhaus DNSBL (IPv4)
#
# (R) hackingyseguridad.com
#

set -euo pipefail

########################################

RED="\033[31m"
GREEN="\033[32m"
BLUE="\033[36m"
YELLOW="\033[33m"
NC="\033[0m"

########################################

banner(){

echo
echo "========================================"
echo "      IP Public Analyzer"
echo "========================================"
echo

}

########################################

check_cmd(){

command -v "$1" >/dev/null 2>&1 || {
    echo "Falta instalar: $1"
    exit 1
}

}

########################################

for c in whois dig curl host traceroute nmap; do
    check_cmd "$c"
done

########################################

get_public_ip(){

curl -4 -fs https://ifconfig.me

}

########################################

usage(){

echo "Uso:"
echo
echo "  $0 <IP>"
echo "  $0 --self"
echo

exit 1

}

########################################

[[ $# -eq 0 ]] && usage

if [[ "$1" == "--self" ]]; then
    IP=$(get_public_ip)
else
    IP="$1"
fi

########################################

banner

echo -e "${BLUE}Fecha:${NC} $(date)"
echo
echo -e "${BLUE}IP:${NC} $IP"

########################################

echo
echo "========== WHOIS =========="
whois "$IP" || true

########################################

echo
echo "========== PTR =========="
dig +short -x "$IP"

########################################

echo
echo "========== GEOLOCALIZACIÓN =========="
curl -fs "https://ipapi.co/$IP/json/" | jq . || true

########################################

echo
echo "========== SHODAN =========="
curl -fs "https://internetdb.shodan.io/$IP" | jq . || true

########################################

echo
echo "========== NMAP =========="
nmap -Pn -n --top-ports 100 --open "$IP"

########################################

echo
echo "========== TRACEROUTE =========="
traceroute -n -w 2 "$IP" || true

########################################
# Spamhaus (IPv4)

if [[ "$IP" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then

    echo
    echo "========== SPAMHAUS =========="

    REV=$(echo "$IP" | awk -F. '{print $4"."$3"."$2"."$1}')

    LISTS=(
        zen.spamhaus.org
        sbl.spamhaus.org
        xbl.spamhaus.org
        pbl.spamhaus.org
    )

    for L in "${LISTS[@]}"
    do

        if host "$REV.$L" | grep -q "has address"; then
            echo -e "${RED}LISTADA${NC} -> $L"
            host "$REV.$L"
        else
            echo -e "${GREEN}OK${NC} -> $L"
        fi

    done

else

    echo
    echo "Spamhaus DNSBL sólo soporta IPv4."

fi

echo

