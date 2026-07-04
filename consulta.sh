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

VERSION="1.0.0"
FUENTE="todas.txt"
FICHERO_RESULTADO="resultado.txt"

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

# Función para escribir en pantalla y en fichero
escribir() {
  echo "$1"
  echo "$1" >> "$FICHERO_RESULTADO"
}

# Función para escribir solo en fichero (sin colores)
escribir_sin_color() {
  echo "$1" >> "$FICHERO_RESULTADO"
}

validar_ip() {
  ip="$1"
  case "$ip" in
    *[!0-9.]*)
      return 1
      ;;
  esac
  
  o1=$(echo "$ip" | cut -d. -f1)
  o2=$(echo "$ip" | cut -d. -f2)
  o3=$(echo "$ip" | cut -d. -f3)
  o4=$(echo "$ip" | cut -d. -f4)
  
  if [ -z "$o1" ] || [ -z "$o2" ] || [ -z "$o3" ] || [ -z "$o4" ]; then
    return 1
  fi
  
  if [ "$o1" -le 255 ] && [ "$o2" -le 255 ] && [ "$o3" -le 255 ] && [ "$o4" -le 255 ]; then
    return 0
  fi
  return 1
}

# --- Limpiar resultado anterior ---------------------------------------------
> "$FICHERO_RESULTADO"

# --- Comprobaciones ---------------------------------------------------------
if [ ! -r "$FUENTE" ]; then
  echo "[ERROR] No se puede leer el fichero fuente: $FUENTE" >&2
  exit 2
fi

if [ $# -eq 0 ]; then uso; fi

# --- Recogida de IPs a consultar -------------------------------------------
LISTA_IPS=""
case "$1" in
  -h|--help) uso ;;
  -V|--version) echo "consulta_blacklist.sh v${VERSION}"; exit 0 ;;
  -f)
    shift
    FICHERO="$1"
    if [ -z "$FICHERO" ] || [ ! -r "$FICHERO" ]; then
      echo "[ERROR] Fichero inválido o no legible: $FICHERO" >&2
      exit 2
    fi
    while read -r linea; do
      ip=$(echo "$linea" | awk '{print $1}')
      if [ -n "$ip" ]; then
        if [ -n "$LISTA_IPS" ]; then
          LISTA_IPS="$LISTA_IPS $ip"
        else
          LISTA_IPS="$ip"
        fi
      fi
    done < "$FICHERO"
    ;;
  -)
    while read -r linea; do
      ip=$(echo "$linea" | awk '{print $1}')
      if [ -n "$ip" ]; then
        if [ -n "$LISTA_IPS" ]; then
          LISTA_IPS="$LISTA_IPS $ip"
        else
          LISTA_IPS="$ip"
        fi
      fi
    done
    ;;
  *)
    for arg in "$@"; do
      ip=$(echo "$arg" | awk '{print $1}')
      if [ -n "$ip" ]; then
        if [ -n "$LISTA_IPS" ]; then
          LISTA_IPS="$LISTA_IPS $ip"
        else
          LISTA_IPS="$ip"
        fi
      fi
    done
    ;;
esac

if [ -z "$LISTA_IPS" ]; then
  echo "[AVISO] No se proporcionaron IPs para consultar." >&2
  exit 1
fi

# --- Cabecera ---------------------------------------------------------------
escribir "=== Consulta de IPs en BlackList ==="
escribir "Fichero fuente : $FUENTE"
escribir "Resultado guardado en: $FICHERO_RESULTADO"
escribir ""

# --- Bucle principal: consulta cada IP --------------------------------------
ENCONTRADAS=0
NO_ENCONTRADAS=0
TOTAL_IPS=0

# Contar IPs
for ip in $LISTA_IPS; do
  TOTAL_IPS=$((TOTAL_IPS + 1))
done

for ip in $LISTA_IPS; do
  if ! validar_ip "$ip"; then
    mensaje="${C_YEL}[INVÁLIDA]${C_RST}  $ip  →  Formato no válido"
    mensaje_sin_color="[INVÁLIDA]  $ip  →  Formato no válido"
    escribir "$mensaje"
    escribir_sin_color "$mensaje_sin_color"
    continue
  fi

  # Busca la IP como inicio de línea seguida de espacio
  ip_escaped=$(echo "$ip" | sed 's/\./\\./g')
  match=$(grep -E "^${ip_escaped}[[:space:]]" "$FUENTE" 2>/dev/null)

  if [ -n "$match" ]; then
    # Extrae los descriptores únicos
    listas=$(echo "$match" | awk -F'#' '{print $2}' | awk '{print $1}' | sort -u | paste -sd',' -)
    num_listas=$(echo "$match" | awk -F'#' '{print $2}' | awk '{print $1}' | sort -u | wc -l)
    
    mensaje="${C_RED}[LISTADA]${C_RST}   $ip  →  $num_listas lista(s): $listas"
    mensaje_sin_color="[LISTADA]   $ip  →  $num_listas lista(s): $listas"
    
    escribir "$mensaje"
    escribir_sin_color "$mensaje_sin_color"
    
    ENCONTRADAS=$((ENCONTRADAS + 1))
  else
    mensaje="${C_GRN}[LIMPIA]${C_RST}    $ip  →  No aparece en ninguna lista"
    mensaje_sin_color="[LIMPIA]    $ip  →  No aparece en ninguna lista"
    
    escribir "$mensaje"
    escribir_sin_color "$mensaje_sin_color"
    
    NO_ENCONTRADAS=$((NO_ENCONTRADAS + 1))
  fi
done

# --- Resumen final ----------------------------------------------------------
echo
escribir "=== Resumen ==="
escribir "IPs listadas en BlackList : $ENCONTRADAS"
escribir "IPs limpias / no listadas : $NO_ENCONTRADAS"
escribir "Total consultadas         : $TOTAL_IPS"
escribir ""
escribir "Resultados guardados en: $FICHERO_RESULTADO"

# Código de salida: 0 si todas limpias, 1 si alguna está listada
if [ "$ENCONTRADAS" -gt 0 ]; then
  exit 1
fi
exit 0
