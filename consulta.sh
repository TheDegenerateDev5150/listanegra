#!/usr/bin/env bash
# ============================================================================
# consulta.sh v1.0.0 - Versión simplificada
# Consulta de IPs en listas negras (BlackList) usando dig
# 
# Uso:
#   sh consulta.sh IP
#   sh consulta.sh 192.168.1.1
#   sh consulta.sh -f fichero_ips.txt
#   cat ips.txt | sh consulta.sh -
#
# Basado en listas del fichero listas.txt
# Autor: hackingyseguridad.com
# ============================================================================

VERSION="1.0.0"
FICHERO_LISTAS="listas.txt"
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
consulta.sh v${VERSION}

Uso:
  $0 <IP>
  $0 -f <fichero_con_ips>
  $0 -                              # lee IPs por stdin

Opciones:
  -f FILE   Fichero con una IP por línea
  -h        Muestra esta ayuda
  -V        Muestra la versión

Ejemplos:
  $0 81.41.255.99
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

validar_ip() {
  ip="$1"
  case "$ip" in
    *[!0-9.]*) return 1 ;;
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

# Función para revertir IP (formato para DNS)
revertir_ip() {
  echo "$1" | awk -F. '{print $4"."$3"."$2"."$1}'
}

# Función que consulta una IP en todas las listas
consultar_ip() {
  ip="$1"
  
  if ! validar_ip "$ip"; then
    mensaje="${C_YEL}[INVÁLIDA]${C_RST}  $ip  →  Formato no válido"
    echo "$mensaje"
    echo "$mensaje" >> "$FICHERO_RESULTADO"
    return
  fi

  # Revertir IP para consultas DNS
  ip_rev=$(revertir_ip "$ip")
  
  # Variables para resultados
  ENCONTRADO=0
  LISTAS_ENCONTRADAS=""
  
  # Leer listas del fichero
  while IFS= read -r linea || [ -n "$linea" ]; do
    # Saltar líneas vacías y comentarios
    [ -z "$linea" ] && continue
    [[ "$linea" =~ ^[[:space:]]*# ]] && continue
    
    # Extraer nombre de lista y dominio
    nombre_lista=$(echo "$linea" | awk '{print $1}')
    dominio=$(echo "$linea" | awk '{print $2}')
    
    # Construir consulta DNS
    consulta="${ip_rev}.${dominio}"
    
    # Realizar consulta dig
    resultado=$(dig +short "$consulta" 2>/dev/null)
    
    if [ -n "$resultado" ]; then
      ENCONTRADO=1
      if [ -z "$LISTAS_ENCONTRADAS" ]; then
        LISTAS_ENCONTRADAS="$nombre_lista"
      else
        LISTAS_ENCONTRADAS="$LISTAS_ENCONTRADAS, $nombre_lista"
      fi
    fi
    
  done < "$FICHERO_LISTAS"

  # Mostrar resultado
  if [ "$ENCONTRADO" -eq 1 ]; then
    mensaje="${C_RED}[LISTADA]${C_RST}   $ip  →  $LISTAS_ENCONTRADAS"
    echo "$mensaje"
    echo "$mensaje" >> "$FICHERO_RESULTADO"
    return 1
  else
    mensaje="${C_GRN}[LIMPIA]${C_RST}    $ip  →  No aparece en ninguna lista"
    echo "$mensaje"
    echo "$mensaje" >> "$FICHERO_RESULTADO"
    return 0
  fi
}

# --- Limpiar resultado anterior ---------------------------------------------
> "$FICHERO_RESULTADO"

# --- Comprobaciones ---------------------------------------------------------
if [ ! -r "$FICHERO_LISTAS" ]; then
  echo "[ERROR] No se puede leer el fichero de listas: $FICHERO_LISTAS" >&2
  exit 2
fi

if [ $# -eq 0 ]; then uso; fi

# --- Procesar argumentos ----------------------------------------------------
case "$1" in
  -h|--help) uso ;;
  -V|--version) echo "consulta.sh v${VERSION}"; exit 0 ;;
  -f)
    shift
    FICHERO="$1"
    if [ -z "$FICHERO" ] || [ ! -r "$FICHERO" ]; then
      echo "[ERROR] Fichero inválido o no legible: $FICHERO" >&2
      exit 2
    fi
    while read -r linea; do
      ip=$(echo "$linea" | awk '{print $1}')
      [ -n "$ip" ] && consultar_ip "$ip"
    done < "$FICHERO"
    ;;
  -)
    while read -r linea; do
      ip=$(echo "$linea" | awk '{print $1}')
      [ -n "$ip" ] && consultar_ip "$ip"
    done
    ;;
  *)
    for arg in "$@"; do
      ip=$(echo "$arg" | awk '{print $1}')
      [ -n "$ip" ] && consultar_ip "$ip"
    done
    ;;
esac

echo
echo "Resultados guardados en: $FICHERO_RESULTADO"
