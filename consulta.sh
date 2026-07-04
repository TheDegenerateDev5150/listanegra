#!/usr/bin/env bash
# ============================================================================
# consulta_blacklist.sh v1.0.0
# Script de consulta de IPs en listas negras (BlackList) a partir de
# ip.txt
#
# Uso:
#   ./consulta_blacklist.sh <IP1> [IP2] [IP3] ...
#   ./consulta_blacklist.sh -f <fichero_con_ips>
#   cat lista_ips.txt | ./consulta_blacklist.sh -
#
# Autor: hackingyseguridad.com
# ============================================================================

set -u

VERSION="1.0.0"
FUENTE="todas.txt"

# --- Colores (si la salida es una TTY) --------------------------------------
if [ -t 1 ]; then
  C_RED='\033[1;31m'
  C_GRN='\033[1;32m'
  C_YEL='\033[1;33m'
  C_CYN='\033[1;36m'
  C_RST='\033[0m'
else
  C_RED=''; C_GRN=''; C_YEL=''; C_CYN=''; C_RST=''
fi

# --- Funciones --------------------------------------------------------------
uso() {
  cat <<EOF
consulta_blacklist.sh v${VERSION}

Uso:
  $0 <IP1> [IP2] [IP3] ...
  $0 -f <fichero_con_ips>
  $0 -                              # lee IPs por stdin

Opciones:
  -f FILE   Fichero con una IP por línea
  -h        Muestra esta ayuda
  -V        Muestra la versión

Ejemplos:
  $0 81.41.255.99
  $0 81.41.255.99 213.4.212.1 5.205.0.1
  $0 -f mis_ips.txt
  echo "81.41.255.99" | $0 -

EOF
  exit 0
}

validar_ip() {
  local ip="$1"
  if [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    local o1 o2 o3 o4
    IFS='.' read -r o1 o2 o3 o4 <<< "$ip"
    if (( o1 <= 255 && o2 <= 255 && o3 <= 255 && o4 <= 255 )); then
      return 0
    fi
  fi
  return 1
}

# --- Comprobaciones ---------------------------------------------------------
if [ ! -r "$FUENTE" ]; then
  echo -e "${C_RED}[ERROR]${C_RST} No se puede leer el fichero fuente: $FUENTE" >&2
  exit 2
fi

if [ $# -eq 0 ]; then uso; fi

# --- Recogida de IPs a consultar -------------------------------------------
LISTA_IPS=()
case "${1:-}" in
  -h|--help) uso ;;
  -V|--version) echo "consulta_blacklist.sh v${VERSION}"; exit 0 ;;
  -f)
    shift
    FICHERO="${1:-}"
    if [ -z "$FICHERO" ] || [ ! -r "$FICHERO" ]; then
      echo -e "${C_RED}[ERROR]${C_RST} Fichero inválido o no legible: $FICHERO" >&2
      exit 2
    fi
    while IFS= read -r linea; do
      ip=$(echo "$linea" | awk '{print $1}')
      [ -n "$ip" ] && LISTA_IPS+=("$ip")
    done < "$FICHERO"
    ;;
  -)
    while IFS= read -r linea; do
      ip=$(echo "$linea" | awk '{print $1}')
      [ -n "$ip" ] && LISTA_IPS+=("$ip")
    done
    ;;
  *)
    for arg in "$@"; do
      ip=$(echo "$arg" | awk '{print $1}')
      [ -n "$ip" ] && LISTA_IPS+=("$ip")
    done
    ;;
esac

if [ ${#LISTA_IPS[@]} -eq 0 ]; then
  echo -e "${C_YEL}[AVISO]${C_RST} No se proporcionaron IPs para consultar." >&2
  exit 1
fi

# --- Construcción del patrón para grep -------------------------------------
# Escapa los puntos para que grep los interprete como literales
PATRON=""
for ip in "${LISTA_IPS[@]}"; do
  esc=$(printf '%s' "$ip" | sed 's/\./\\./g')
  if [ -z "$PATRON" ]; then
    PATRON="^${esc}[[:space:]]"
  else
    PATRON="${PATRON}|^${esc}[[:space:]]"
  fi
done

# --- Cabecera ---------------------------------------------------------------
printf "${C_CYN}=== Consulta de IPs en BlackList ===${C_RST}\n"
printf "Fichero fuente : %s\n" "$FUENTE"
printf "IPs consultadas: %d\n\n" "${#LISTA_IPS[@]}"

# --- Bucle principal: consulta cada IP --------------------------------------
ENCONTRADAS=0
NO_ENCONTRADAS=0
declare -A RESULTADOS

for ip in "${LISTA_IPS[@]}"; do
  if ! validar_ip "$ip"; then
    printf "${C_YEL}[INVÁLIDA]${C_RST}  %-18s  →  Formato no válido\n" "$ip"
    continue
  fi

  # Busca la IP como inicio de línea seguida de espacio
  match=$(grep -E "^${ip//./\\.}[[:space:]]" "$FUENTE" 2>/dev/null)

  if [ -n "$match" ]; then
    # Extrae los descriptores únicos (columna 3 en adelante, separados por #)
    listas=$(echo "$match" | awk -F'#' '{print $2}' | awk '{print $1}' | sort -u | paste -sd',' -)
    num_listas=$(echo "$match" | awk -F'#' '{print $2}' | awk '{print $1}' | sort -u | wc -l)
    printf "${C_RED}[LISTADA]${C_RST}   %-18s  →  %d lista(s): %s\n" "$ip" "$num_listas" "$listas"
    ENCONTRADAS=$((ENCONTRADAS + 1))
  else
    printf "${C_GRN}[LIMPIA]${C_RST}    %-18s  →  No aparece en ninguna lista\n" "$ip"
    NO_ENCONTRADAS=$((NO_ENCONTRADAS + 1))
  fi
done

# --- Resumen final ----------------------------------------------------------
echo
printf "${C_CYN}=== Resumen ===${C_RST}\n"
printf "IPs listadas en BlackList : ${C_RED}%d${C_RST}\n" "$ENCONTRADAS"
printf "IPs limpias / no listadas : ${C_GRN}%d${C_RST}\n" "$NO_ENCONTRADAS"
printf "Total consultadas         : %d\n" "${#LISTA_IPS[@]}"

# Código de salida: 0 si todas limpias, 1 si alguna está listada
if [ "$ENCONTRADAS" -gt 0 ]; then
  exit 1
fi
exit 0

