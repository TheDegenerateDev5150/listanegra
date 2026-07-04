#!/bin/bash
# check_spamhaus_dns_rotator.sh — Adaptado para Bash 1.0.x
# Lee DNS desde dns.txt, IPs desde ip.txt, guarda en resultado.txt

# Variables
INPUT_IPS="ip.txt"
INPUT_DNS="dns.txt"
OUTPUT_FILE="resultado.txt"
CACHE_FILE="/tmp/cache_spamhaus.txt"

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
echo "=================================================="
echo "   SCRIPT DE CONSULTA SPAMHAUS (Bash 1.0.x)"
echo "=================================================="
echo "Archivo de IPs:   $INPUT_IPS"
echo "Archivo de DNS:   $INPUT_DNS"
echo "Archivo de salida: $OUTPUT_FILE"
echo "Total de IPs a procesar: $TOTAL"
echo "Total de DNS disponibles: $TOTAL_DNS"
echo "=================================================="
echo ""

# Escribir cabecera en el archivo de resultados
echo "==================================================" >> "$OUTPUT_FILE"
echo "   SCRIPT DE CONSULTA SPAMHAUS (Bash 1.0.x)" >> "$OUTPUT_FILE"
echo "   Fecha: `date`" >> "$OUTPUT_FILE"
echo "==================================================" >> "$OUTPUT_FILE"
echo "Servidores DNS utilizados:" >> "$OUTPUT_FILE"

# Mostrar y guardar los DNS utilizados
exec 3< "$INPUT_DNS"
DNS_INDEX=0
while read -r DNS_SERVER <&3; do
  if [ "x$DNS_SERVER" != "x" ]; then
    DNS_INDEX=`expr $DNS_INDEX + 1`
    echo "  $DNS_INDEX) $DNS_SERVER" | tee -a "$OUTPUT_FILE"
  fi
done
exec 3<&-
echo "" >> "$OUTPUT_FILE"

# Escribir cabecera de resultados
echo "" >> "$OUTPUT_FILE"
echo "==================================================" >> "$OUTPUT_FILE"
echo "   RESULTADOS DE CONSULTAS" >> "$OUTPUT_FILE"
echo "==================================================" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Cargar servidores DNS en variables (máximo 50 para evitar problemas)
# Usamos un archivo temporal para almacenar los DNS
TEMP_DNS="/tmp/dns_list_$$.txt"
grep -v '^$' "$INPUT_DNS" > "$TEMP_DNS"
TOTAL_DNS=`wc -l < "$TEMP_DNS"`

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
  # Usamos el módulo del contador para elegir un DNS
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
  
  # Realizar consulta DNS
  RESULT=`dig +short "@$DNS_SERVER" "${REV}.zen.spamhaus.org" A 2>/dev/null | head -1`
  
  # Determinar el estado y mostrar resultado
  if [ ! -z "$RESULT" ]; then
    # Verificar si es código de error (127.255.255.x)
    ERROR_PREFIX=`echo "$RESULT" | awk -F "." '{print $1"."$2"."$3}'`
    if [ "$ERROR_PREFIX" = "127.255.255" ]; then
      # Es un error
      ERRORES=`expr $ERRORES + 1`
      MENSAJE="ERROR  : $IP -> Código $RESULT (DNS: $DNS_SERVER)"
      echo "  $MENSAJE"
      echo "$MENSAJE" >> "$OUTPUT_FILE"
      
      # Guardar en caché
      echo "ERROR $IP -> $RESULT" >> "$CACHE_FILE"
    else
      # Es un listado válido
      LISTADAS=`expr $LISTADAS + 1`
      MENSAJE="LISTADA: $IP -> Código $RESULT (DNS: $DNS_SERVER)"
      echo "  $MENSAJE"
      echo "$MENSAJE" >> "$OUTPUT_FILE"
      
      # Guardar en caché
      echo "LISTED $IP -> $RESULT" >> "$CACHE_FILE"
    fi
  else
    # No hay respuesta -> limpio
    LIMPIAS=`expr $LIMPIAS + 1`
    MENSAJE="LIMPI  : $IP -> No listada (DNS: $DNS_SERVER)"
    echo "  $MENSAJE"
    echo "$MENSAJE" >> "$OUTPUT_FILE"
    
    # Guardar en caché
    echo "CLEAN $IP" >> "$CACHE_FILE"
  fi
  
  # Mostrar progreso cada 10 IPs (para no saturar la pantalla)
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
echo "=================================================="
echo "   RESUMEN FINAL"
echo "=================================================="
echo "Total de IPs procesadas: $PROCESADAS"
echo "IPs LISTADAS (en negra): $LISTADAS"
echo "IPs LIMPIAS (no listadas): $LIMPIAS"
echo "IPs con ERROR en consulta: $ERRORES"
echo "=================================================="
echo ""
echo "Resultados guardados en: $OUTPUT_FILE"

# Escribir resumen en el archivo de resultados
echo "" >> "$OUTPUT_FILE"
echo "==================================================" >> "$OUTPUT_FILE"
echo "   RESUMEN FINAL" >> "$OUTPUT_FILE"
echo "==================================================" >> "$OUTPUT_FILE"
echo "Total de IPs procesadas: $PROCESADAS" >> "$OUTPUT_FILE"
echo "IPs LISTADAS (en negra): $LISTADAS" >> "$OUTPUT_FILE"
echo "IPs LIMPIAS (no listadas): $LIMPIAS" >> "$OUTPUT_FILE"
echo "IPs con ERROR en consulta: $ERRORES" >> "$OUTPUT_FILE"
echo "==================================================" >> "$OUTPUT_FILE"
echo "Fecha de finalización: `date`" >> "$OUTPUT_FILE"
