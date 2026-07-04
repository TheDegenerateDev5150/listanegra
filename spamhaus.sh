#!/bin/bash
# check_spamhaus_ip.sh — Adaptado para Bash 1.0.x
# Uso: sh check_spamhaus.sh IP
# Ejemplo: sh check_spamhaus.sh 8.8.8.8

# Variables
INPUT_DNS="dns.txt"
OUTPUT_FILE="resultado.txt"
CACHE_FILE="/tmp/cache_spamhaus_detallado.txt"

# Listas a consultar
LISTA_SBL="sbl.spamhaus.org"
LISTA_XBL="xbl.spamhaus.org"
LISTA_PBL="pbl.spamhaus.org"
LISTA_CSS="css.spamhaus.org"

# Contadores
TOTAL_DNS=0

# Verificar que se pasó un argumento (la IP)
if [ $# -ne 1 ]; then
  echo "ERROR: Debes especificar una IP"
  echo "Uso: sh $0 IP"
  echo "Ejemplo: sh $0 8.8.8.8"
  exit 1
fi

IP="$1"

# Validar formato básico de IP (4 números separados por puntos)
VALIDAR_IP=`echo "$IP" | awk -F. '{if (NF==4) print "valido"}'`
if [ "x$VALIDAR_IP" != "xvalido" ]; then
  echo "ERROR: Formato de IP inválido: $IP"
  echo "Debe tener formato: xxx.xxx.xxx.xxx"
  echo "Ejemplo: 8.8.8.8"
  exit 1
fi

# Verificar que existe el archivo de DNS
if [ ! -f "$INPUT_DNS" ]; then
  echo "ERROR: No se encuentra el archivo $INPUT_DNS"
  echo "Crea un archivo con un servidor DNS por línea"
  echo "Ejemplo:"
  echo "  8.8.8.8"
  echo "  1.1.1.1"
  echo "  9.9.9.9"
  exit 1
fi

# Crear directorio de caché si no existe
CACHE_DIR=`echo "$CACHE_FILE" | sed 's/\/[^/]*$//'`
if [ ! -d "$CACHE_DIR" ]; then
  mkdir -p "$CACHE_DIR"
fi

# Contar servidores DNS disponibles
TOTAL_DNS=`grep -v '^$' "$INPUT_DNS" | wc -l`
if [ "x$TOTAL_DNS" = "x" ] || [ $TOTAL_DNS -eq 0 ]; then
  echo "ERROR: No hay servidores DNS válidos en $INPUT_DNS"
  exit 1
fi

# Cargar servidores DNS en un archivo temporal
TEMP_DNS="/tmp/dns_list_$$.txt"
grep -v '^$' "$INPUT_DNS" > "$TEMP_DNS"
TOTAL_DNS=`wc -l < "$TEMP_DNS"`

# Invertir la IP para DNSBL
REV=`echo "$IP" | awk -F "." '{print $4"."$3"."$2"."$1}'`

# Seleccionar servidor DNS (usamos el primero para simplicidad, o rotamos según la IP)
# Para rotar según la IP, usamos el último octeto
ULTIMO_OCTETO=`echo "$IP" | awk -F "." '{print $4}'`
MOD=`expr $ULTIMO_OCTETO % $TOTAL_DNS`
if [ $MOD -eq 0 ]; then
  MOD=$TOTAL_DNS
fi

# Obtener el DNS correspondiente al índice
DNS_SERVER=`sed -n "${MOD}p" "$TEMP_DNS"`

# Si no se pudo obtener, usar el primero
if [ "x$DNS_SERVER" = "x" ]; then
  DNS_SERVER=`head -1 "$TEMP_DNS"`
fi

# Mostrar cabecera
echo "============================================================"
echo "   SCRIPT DE CONSULTA SPAMHAUS (Bash 1.0.x)"
echo "   Consulta SBL, XBL, PBL y CSS por separado"
echo "============================================================"
echo "IP consultada:     $IP"
echo "DNS utilizado:     $DNS_SERVER"
echo "Archivo de salida: $OUTPUT_FILE"
echo "============================================================"
echo ""

# Escribir cabecera en el archivo de resultados
echo "============================================================" >> "$OUTPUT_FILE"
echo "   SCRIPT DE CONSULTA SPAMHAUS (Bash 1.0.x)" >> "$OUTPUT_FILE"
echo "   Consulta SBL, XBL, PBL y CSS por separado" >> "$OUTPUT_FILE"
echo "   Fecha: `date`" >> "$OUTPUT_FILE"
echo "============================================================" >> "$OUTPUT_FILE"
echo "IP consultada: $IP" >> "$OUTPUT_FILE"
echo "DNS utilizado: $DNS_SERVER" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Variable para saber si la IP está listada
ENCONTRADA=0
MENSAJE_RESULTADO=""

echo "Consultando IP: $IP ..."

# -----------------------------------------------------------------
# 1. Consultar SBL (Spamhaus Blocklist)
# -----------------------------------------------------------------
RESULT_SBL=`dig +short "@$DNS_SERVER" "${REV}.${LISTA_SBL}" A 2>/dev/null | head -1`

if [ ! -z "$RESULT_SBL" ]; then
  # Verificar si es código de error
  ERROR_PREFIX=`echo "$RESULT_SBL" | awk -F "." '{print $1"."$2"."$3}'`
  if [ "$ERROR_PREFIX" != "127.255.255" ]; then
    ENCONTRADA=1
    if [ "$RESULT_SBL" = "127.0.0.2" ]; then
      NOMBRE_LISTA="SBL (Spamhaus Blocklist)"
      DESCRIPCION="IP involucrada en spam, phishing o alojamiento malicioso"
    else
      NOMBRE_LISTA="SBL (Spamhaus Blocklist) - Código $RESULT_SBL"
      DESCRIPCION="Listado en SBL con código específico"
    fi
    MENSAJE_RESULTADO="LISTADA en: $NOMBRE_LISTA"
    MENSAJE_RESULTADO="$MENSAJE_RESULTADO (Código: $RESULT_SBL)"
    MENSAJE_RESULTADO="$MENSAJE_RESULTADO - $DESCRIPCION"
  fi
fi

# -----------------------------------------------------------------
# 2. Si no está en SBL, consultar XBL (Exploits Blocklist)
# -----------------------------------------------------------------
if [ $ENCONTRADA -eq 0 ]; then
  RESULT_XBL=`dig +short "@$DNS_SERVER" "${REV}.${LISTA_XBL}" A 2>/dev/null | head -1`
  
  if [ ! -z "$RESULT_XBL" ]; then
    ERROR_PREFIX=`echo "$RESULT_XBL" | awk -F "." '{print $1"."$2"."$3}'`
    if [ "$ERROR_PREFIX" != "127.255.255" ]; then
      ENCONTRADA=1
      if [ "$RESULT_XBL" = "127.0.0.4" ]; then
        NOMBRE_LISTA="XBL (Exploits Blocklist)"
        DESCRIPCION="Equipo comprometido que envía spam o malware"
      else
        NOMBRE_LISTA="XBL (Exploits Blocklist) - Código $RESULT_XBL"
        DESCRIPCION="Listado en XBL con código específico"
      fi
      MENSAJE_RESULTADO="LISTADA en: $NOMBRE_LISTA"
      MENSAJE_RESULTADO="$MENSAJE_RESULTADO (Código: $RESULT_XBL)"
      MENSAJE_RESULTADO="$MENSAJE_RESULTADO - $DESCRIPCION"
    fi
  fi
fi

# -----------------------------------------------------------------
# 3. Si no está en SBL ni XBL, consultar PBL (Policy Blocklist)
# -----------------------------------------------------------------
if [ $ENCONTRADA -eq 0 ]; then
  RESULT_PBL=`dig +short "@$DNS_SERVER" "${REV}.${LISTA_PBL}" A 2>/dev/null | head -1`
  
  if [ ! -z "$RESULT_PBL" ]; then
    ERROR_PREFIX=`echo "$RESULT_PBL" | awk -F "." '{print $1"."$2"."$3}'`
    if [ "$ERROR_PREFIX" != "127.255.255" ]; then
      ENCONTRADA=1
      if [ "$RESULT_PBL" = "127.0.0.10" ] || [ "$RESULT_PBL" = "127.0.0.11" ]; then
        NOMBRE_LISTA="PBL (Policy Blocklist)"
        DESCRIPCION="IP que no debería enviar correo directamente (red residencial/dinámica)"
      else
        NOMBRE_LISTA="PBL (Policy Blocklist) - Código $RESULT_PBL"
        DESCRIPCION="Listado en PBL con código específico"
      fi
      MENSAJE_RESULTADO="LISTADA en: $NOMBRE_LISTA"
      MENSAJE_RESULTADO="$MENSAJE_RESULTADO (Código: $RESULT_PBL)"
      MENSAJE_RESULTADO="$MENSAJE_RESULTADO - $DESCRIPCION"
    fi
  fi
fi

# -----------------------------------------------------------------
# 4. Si no está en SBL, XBL ni PBL, consultar CSS (Combined Spam Sources)
# -----------------------------------------------------------------
if [ $ENCONTRADA -eq 0 ]; then
  RESULT_CSS=`dig +short "@$DNS_SERVER" "${REV}.${LISTA_CSS}" A 2>/dev/null | head -1`
  
  if [ ! -z "$RESULT_CSS" ]; then
    ERROR_PREFIX=`echo "$RESULT_CSS" | awk -F "." '{print $1"."$2"."$3}'`
    if [ "$ERROR_PREFIX" != "127.255.255" ]; then
      ENCONTRADA=1
      if [ "$RESULT_CSS" = "127.0.0.3" ]; then
        NOMBRE_LISTA="CSS (Combined Spam Sources)"
        DESCRIPCION="Correo de baja reputación, sin SPF/DKIM/DMARC"
      else
        NOMBRE_LISTA="CSS (Combined Spam Sources) - Código $RESULT_CSS"
        DESCRIPCION="Listado en CSS con código específico"
      fi
      MENSAJE_RESULTADO="LISTADA en: $NOMBRE_LISTA"
      MENSAJE_RESULTADO="$MENSAJE_RESULTADO (Código: $RESULT_CSS)"
      MENSAJE_RESULTADO="$MENSAJE_RESULTADO - $DESCRIPCION"
    fi
  fi
fi

# -----------------------------------------------------------------
# 5. Mostrar resultado final
# -----------------------------------------------------------------
if [ $ENCONTRADA -eq 1 ]; then
  echo "  $MENSAJE_RESULTADO"
  echo "$MENSAJE_RESULTADO" >> "$OUTPUT_FILE"
  echo "LISTED $IP -> $MENSAJE_RESULTADO" >> "$CACHE_FILE"
else
  # Verificar si hubo errores en las consultas
  HUBO_ERROR=0
  MENSAJE_ERROR=""
  
  # Revisar si algún código de error apareció
  if [ ! -z "$RESULT_SBL" ]; then
    ERROR_PREFIX=`echo "$RESULT_SBL" | awk -F "." '{print $1"."$2"."$3}'`
    if [ "$ERROR_PREFIX" = "127.255.255" ]; then
      HUBO_ERROR=1
      MENSAJE_ERROR="ERROR en SBL: $RESULT_SBL"
    fi
  fi
  
  if [ $HUBO_ERROR -eq 0 ] && [ ! -z "$RESULT_XBL" ]; then
    ERROR_PREFIX=`echo "$RESULT_XBL" | awk -F "." '{print $1"."$2"."$3}'`
    if [ "$ERROR_PREFIX" = "127.255.255" ]; then
      HUBO_ERROR=1
      MENSAJE_ERROR="ERROR en XBL: $RESULT_XBL"
    fi
  fi
  
  if [ $HUBO_ERROR -eq 0 ] && [ ! -z "$RESULT_PBL" ]; then
    ERROR_PREFIX=`echo "$RESULT_PBL" | awk -F "." '{print $1"."$2"."$3}'`
    if [ "$ERROR_PREFIX" = "127.255.255" ]; then
      HUBO_ERROR=1
      MENSAJE_ERROR="ERROR en PBL: $RESULT_PBL"
    fi
  fi
  
  if [ $HUBO_ERROR -eq 0 ] && [ ! -z "$RESULT_CSS" ]; then
    ERROR_PREFIX=`echo "$RESULT_CSS" | awk -F "." '{print $1"."$2"."$3}'`
    if [ "$ERROR_PREFIX" = "127.255.255" ]; then
      HUBO_ERROR=1
      MENSAJE_ERROR="ERROR en CSS: $RESULT_CSS"
    fi
  fi
  
  if [ $HUBO_ERROR -eq 1 ]; then
    echo "  $MENSAJE_ERROR"
    echo "$MENSAJE_ERROR" >> "$OUTPUT_FILE"
    echo "ERROR $IP -> $MENSAJE_ERROR" >> "$CACHE_FILE"
  else
    MENSAJE="LIMPI  : $IP -> No listada en SBL, XBL, PBL ni CSS"
    echo "  $MENSAJE"
    echo "$MENSAJE" >> "$OUTPUT_FILE"
    echo "CLEAN $IP" >> "$CACHE_FILE"
  fi
fi

# Limpiar archivo temporal
rm -f "$TEMP_DNS"

# Mostrar resumen final
echo ""
echo "============================================================"
echo "   RESUMEN"
echo "============================================================"
if [ $ENCONTRADA -eq 1 ]; then
  echo "RESULTADO: IP LISTADA en lista negra"
else
  if [ $HUBO_ERROR -eq 1 ]; then
    echo "RESULTADO: ERROR en la consulta"
  else
    echo "RESULTADO: IP LIMPIA (no listada)"
  fi
fi
echo "============================================================"
echo ""
echo "Resultado guardado en: $OUTPUT_FILE"
