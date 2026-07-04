#!/bin/bash

# check_spamhaus_detallado.sh — Adaptado para Bash 1.0.x
# necesita una lista de DNS en fichero dns.txt 
# Consulta SBL, XBL, PBL y CSS por separado y muestra el nombre exacto

# Variables
INPUT_IPS="ip.txt"
INPUT_DNS="dns.txt"
OUTPUT_FILE="resultado.txt"
CACHE_FILE="/tmp/cache_spamhaus_detallado.txt"

# Listas a consultar (cada una devuelve un código específico)
# Nota: DBL no se incluye porque es para dominios, no para IPs
LISTA_SBL="sbl.spamhaus.org"
LISTA_XBL="xbl.spamhaus.org"
LISTA_PBL="pbl.spamhaus.org"
LISTA_CSS="css.spamhaus.org"

# Contadores
TOTAL=0
PROCESADAS=0
LISTADAS=0
LIMPIAS=0
ERRORES=0
TOTAL_DNS=0

# Verificar que existe el archivo de IPs
if [ ! -f "$INPUT_IPS" ]; then
  echo "ERROR: No se encuentra el archivo $INPUT_IPS"
  echo "Crea un archivo con una IP por línea"
  exit 1
fi

# Verificar que existe el archivo de DNS
if [ ! -f "$INPUT_DNS" ]; then
  echo "ERROR: No se encuentra el archivo $INPUT_DNS"
  echo "Crea un archivo con un servidor DNS por línea"
  exit 1
fi

# Crear directorio de caché si no existe
CACHE_DIR=`echo "$CACHE_FILE" | sed 's/\/[^/]*$//'`
if [ ! -d "$CACHE_DIR" ]; then
  mkdir -p "$CACHE_DIR"
fi

# Vaciar archivo de resultados anterior
> "$OUTPUT_FILE"

# Contar servidores DNS disponibles
TOTAL_DNS=`grep -v '^$' "$INPUT_DNS" | wc -l`
if [ "x$TOTAL_DNS" = "x" ] || [ $TOTAL_DNS -eq 0 ]; then
  echo "ERROR: No hay servidores DNS válidos en $INPUT_DNS"
  exit 1
fi

# Contar total de IPs (ignorando vacías)
TOTAL=`grep -v '^$' "$INPUT_IPS" | wc -l`
if [ "x$TOTAL" = "x" ]; then
  TOTAL=0
fi

# Cabecera en pantalla y archivo
echo "============================================================"
echo "   SCRIPT DE CONSULTA SPAMHAUS (Bash 1.0.x)"
echo "   Consulta SBL, XBL, PBL y CSS por separado"
echo "============================================================"
echo "Archivo de IPs:   $INPUT_IPS"
echo "Archivo de DNS:   $INPUT_DNS"
echo "Archivo de salida: $OUTPUT_FILE"
echo "Total de IPs a procesar: $TOTAL"
echo "============================================================"
echo ""

# Escribir cabecera en el archivo de resultados
echo "============================================================" >> "$OUTPUT_FILE"
echo "   SCRIPT DE CONSULTA SPAMHAUS (Bash 1.0.x)" >> "$OUTPUT_FILE"
echo "   Consulta SBL, XBL, PBL y CSS por separado" >> "$OUTPUT_FILE"
echo "   Fecha: `date`" >> "$OUTPUT_FILE"
echo "============================================================" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Cargar servidores DNS en un archivo temporal
TEMP_DNS="/tmp/dns_list_$$.txt"
grep -v '^$' "$INPUT_DNS" > "$TEMP_DNS"
TOTAL_DNS=`wc -l < "$TEMP_DNS"`

# Función para obtener el nombre de la lista según el código
# (Las funciones no existen en Bash 1.0, así que usamos un case con variables)
# Pero para mantener compatibilidad, usaremos un bloque if-else

# Procesar archivo de IPs línea por línea
exec 3< "$INPUT_IPS"
while read -r IP <&3; do
  # Saltar líneas vacías
  if [ "x$IP" = "x" ]; then
    continue
  fi
  
  PROCESADAS=`expr $PROCESADAS + 1`
  
  # Mostrar progreso en pantalla
  echo "[$PROCESADAS/$TOTAL] Consultando IP: $IP ..."
  
  # Invertir la IP para DNSBL
  REV=`echo "$IP" | awk -F "." '{print $4"."$3"."$2"."$1}'`
  
  # Seleccionar servidor DNS de forma rotativa
  MOD=`expr $PROCESADAS % $TOTAL_DNS`
  if [ $MOD -eq 0 ]; then
    MOD=$TOTAL_DNS
  fi
  
  # Obtener el DNS correspondiente al índice
  DNS_SERVER=`sed -n "${MOD}p" "$TEMP_DNS"`
  
  # Si no se pudo obtener, usar el primero
  if [ "x$DNS_SERVER" = "x" ]; then
    DNS_SERVER=`head -1 "$TEMP_DNS"`
  fi
  
  # Variable para saber si la IP está listada
  ENCONTRADA=0
  MENSAJE_RESULTADO=""
  
  # -----------------------------------------------------------------
  # 1. Consultar SBL (Spamhaus Blocklist)
  # -----------------------------------------------------------------
  RESULT_SBL=`dig +short "@$DNS_SERVER" "${REV}.${LISTA_SBL}" A 2>/dev/null | head -1`
  
  if [ ! -z "$RESULT_SBL" ]; then
    # Verificar si es código de error
    ERROR_PREFIX=`echo "$RESULT_SBL" | awk -F "." '{print $1"."$2"."$3}'`
    if [ "$ERROR_PREFIX" != "127.255.255" ]; then
      ENCONTRADA=1
      # Determinar el nombre exacto según el código
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
    LISTADAS=`expr $LISTADAS + 1`
    echo "  $MENSAJE_RESULTADO"
    echo "$MENSAJE_RESULTADO" >> "$OUTPUT_FILE"
    
    # Guardar en caché
    echo "LISTED $IP -> $MENSAJE_RESULTADO" >> "$CACHE_FILE"
  else
    # Verificar si hubo errores en las consultas
    HUBO_ERROR=0
    
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
      ERRORES=`expr $ERRORES + 1`
      echo "  $MENSAJE_ERROR"
      echo "$MENSAJE_ERROR" >> "$OUTPUT_FILE"
      echo "ERROR $IP -> $MENSAJE_ERROR" >> "$CACHE_FILE"
    else
      LIMPIAS=`expr $LIMPIAS + 1`
      MENSAJE="LIMPI  : $IP -> No listada en SBL, XBL, PBL ni CSS"
      echo "  $MENSAJE"
      echo "$MENSAJE" >> "$OUTPUT_FILE"
      echo "CLEAN $IP" >> "$CACHE_FILE"
    fi
  fi
  
  # Mostrar progreso cada 10 IPs
  MOD_PROGRESS=`expr $PROCESADAS % 10`
  if [ $MOD_PROGRESS -eq 0 ]; then
    echo "  [Progreso: $PROCESADAS/$TOTAL - Listadas: $LISTADAS, Limpias: $LIMPIAS, Errores: $ERRORES]"
  fi
  
done

# Cerrar descriptor de archivo
exec 3<&-

# Limpiar archivo temporal
rm -f "$TEMP_DNS"

# Mostrar resumen final en pantalla
echo ""
echo "============================================================"
echo "   RESUMEN FINAL"
echo "============================================================"
echo "Total de IPs procesadas: $PROCESADAS"
echo "IPs LISTADAS (en negra): $LISTADAS"
echo "  - SBL (Spamhaus Blocklist)"
echo "  - XBL (Exploits Blocklist)"
echo "  - PBL (Policy Blocklist)"
echo "  - CSS (Combined Spam Sources)"
echo "IPs LIMPIAS (no listadas): $LIMPIAS"
echo "IPs con ERROR en consulta: $ERRORES"
echo "============================================================"
echo ""
echo "Resultados guardados en: $OUTPUT_FILE"

# Escribir resumen en el archivo de resultados
echo "" >> "$OUTPUT_FILE"
echo "============================================================" >> "$OUTPUT_FILE"
echo "   RESUMEN FINAL" >> "$OUTPUT_FILE"
echo "============================================================" >> "$OUTPUT_FILE"
echo "Total de IPs procesadas: $PROCESADAS" >> "$OUTPUT_FILE"
echo "IPs LISTADAS (en negra): $LISTADAS" >> "$OUTPUT_FILE"
echo "  - SBL (Spamhaus Blocklist)" >> "$OUTPUT_FILE"
echo "  - XBL (Exploits Blocklist)" >> "$OUTPUT_FILE"
echo "  - PBL (Policy Blocklist)" >> "$OUTPUT_FILE"
echo "  - CSS (Combined Spam Sources)" >> "$OUTPUT_FILE"
echo "IPs LIMPIAS (no listadas): $LIMPIAS" >> "$OUTPUT_FILE"
echo "IPs con ERROR en consulta: $ERRORES" >> "$OUTPUT_FILE"
echo "============================================================" >> "$OUTPUT_FILE"
echo "Fecha de finalización: `date`" >> "$OUTPUT_FILE"
