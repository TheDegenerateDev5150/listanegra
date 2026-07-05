#!/bin/bash

# Script de consulta Spamhaus para Bash 1.0.x
# Lee listas negras desde listas.txt
# Uso: sh listanegra.sh [IP]
# Ejemplo: sh listanegra.sh 1.1.1.1

# Variables
INPUT_DNS="dns.txt"
INPUT_LISTAS="listas.txt"
OUTPUT_FILE="resultado.txt"
CACHE_FILE="/tmp/cache_spamhaus.txt"

# Contadores
TOTAL=1
PROCESADAS=0
LISTADAS=0
LIMPIAS=0
ERRORES=0
TOTAL_DNS=0
TOTAL_LISTAS=0

# Verificar que se proporcionó una IP como argumento
if [ $# -lt 1 ]; then
  echo "ERROR: Debes proporcionar una IP como argumento"
  echo "Uso: sh $0 [IP]"
  echo "Ejemplo: sh $0 1.1.1.1"
  exit 1
fi

# Obtener la IP del primer argumento
IP="$1"

# Validar formato de IP (básico)
VALIDAR_IP=`echo "$IP" | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'`
if [ "x$VALIDAR_IP" = "x" ]; then
  echo "ERROR: IP no válida: $IP"
  echo "Formato esperado: xxx.xxx.xxx.xxx"
  exit 1
fi

# Verificar que existe el archivo de DNS
if [ ! -f "$INPUT_DNS" ]; then
  echo "ERROR: No se encuentra el archivo $INPUT_DNS"
  echo "Crea un archivo con un servidor DNS por línea"
  exit 1
fi

# Verificar que existe el archivo de listas negras
if [ ! -f "$INPUT_LISTAS" ]; then
  echo "ERROR: No se encuentra el archivo $INPUT_LISTAS"
  echo "Crea un archivo con el formato: nombre|dominio|descripcion"
  echo "Ejemplo: SBL|sbl.spamhaus.org|Spamhaus Blocklist"
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

# Contar total de listas
TOTAL_LISTAS=`grep -v '^$' "$INPUT_LISTAS" | wc -l`
if [ "x$TOTAL_LISTAS" = "x" ] || [ $TOTAL_LISTAS -eq 0 ]; then
  echo "ERROR: No hay listas definidas en $INPUT_LISTAS"
  exit 1
fi

# Cabecera en pantalla y archivo
echo "============================================================"
echo "   SCRIPT DE CONSULTA SPAMHAUS (Bash 1.0.x)"
echo "   Consulta múltiples listas negras desde listas.txt"
echo "============================================================"
echo "IP a consultar:    $IP"
echo "Archivo de DNS:    $INPUT_DNS"
echo "Archivo de listas: $INPUT_LISTAS"
echo "Archivo de salida: $OUTPUT_FILE"
echo "Total de listas a consultar: $TOTAL_LISTAS"
echo "============================================================"
echo ""

# Mostrar listas cargadas
echo "Listas cargadas:"
grep -v '^$' "$INPUT_LISTAS" | while IFS='|' read NOMBRE DOMINIO DESCRIPCION; do
  echo "  - $NOMBRE ($DOMINIO)"
done
echo "============================================================"
echo ""

# Escribir cabecera en el archivo de resultados
echo "============================================================" >> "$OUTPUT_FILE"
echo "   SCRIPT DE CONSULTA SPAMHAUS (Bash 1.0.x)" >> "$OUTPUT_FILE"
echo "   Consulta múltiples listas negras desde listas.txt" >> "$OUTPUT_FILE"
echo "   Fecha: `date`" >> "$OUTPUT_FILE"
echo "   IP consultada: $IP" >> "$OUTPUT_FILE"
echo "============================================================" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Escribir listas usadas en el archivo
echo "Listas consultadas:" >> "$OUTPUT_FILE"
grep -v '^$' "$INPUT_LISTAS" | while IFS='|' read NOMBRE DOMINIO DESCRIPCION; do
  echo "  - $NOMBRE ($DOMINIO) $DESCRIPCION" >> "$OUTPUT_FILE"
done
echo "" >> "$OUTPUT_FILE"

# Cargar servidores DNS en un archivo temporal
TEMP_DNS="/tmp/dns_list_$$.txt"
grep -v '^$' "$INPUT_DNS" > "$TEMP_DNS"
TOTAL_DNS=`wc -l < "$TEMP_DNS"`

# Cargar listas en un archivo temporal
TEMP_LISTAS="/tmp/listas_$$.txt"
grep -v '^$' "$INPUT_LISTAS" > "$TEMP_LISTAS"
TOTAL_LISTAS=`wc -l < "$TEMP_LISTAS"`

# Procesar la IP
PROCESADAS=`expr $PROCESADAS + 1`

# Mostrar progreso en pantalla
echo "[$PROCESADAS/$TOTAL] Consultando IP: $IP ..."

# Invertir la IP para DNSBL
REV=`echo "$IP" | awk -F "." '{print $4"."$3"."$2"."$1}'`

# Seleccionar servidor DNS (usamos el primero para consistencia)
DNS_SERVER=`head -1 "$TEMP_DNS"`

# Variable para saber si la IP está listada
ENCONTRADA=0
MENSAJE_RESULTADO=""

# Iterar sobre cada lista
LISTA_INDEX=1
while [ $LISTA_INDEX -le $TOTAL_LISTAS ]; do
  LINEA_LISTA=`sed -n "${LISTA_INDEX}p" "$TEMP_LISTAS"`
  
  # Extraer campos de la línea (formato: nombre|dominio|descripcion)
  NOMBRE_LISTA=`echo "$LINEA_LISTA" | cut -d'|' -f1`
  DOMINIO_LISTA=`echo "$LINEA_LISTA" | cut -d'|' -f2`
  DESCRIPCION_LISTA=`echo "$LINEA_LISTA" | cut -d'|' -f3-`
  
  # Verificar que tenemos todos los campos
  if [ "x$NOMBRE_LISTA" != "x" ] && [ "x$DOMINIO_LISTA" != "x" ]; then
    echo "  Consultando $NOMBRE_LISTA ($DOMINIO_LISTA) ..."
    
    # Consultar la lista
    RESULTADO=`dig +short "@$DNS_SERVER" "${REV}.${DOMINIO_LISTA}" A 2>/dev/null | head -1`
    
    if [ ! -z "$RESULTADO" ]; then
      echo "    Respuesta: $RESULTADO"
      
      # Verificar si es código de error
      ERROR_PREFIX=`echo "$RESULTADO" | awk -F "." '{print $1"."$2"."$3}'`
      if [ "$ERROR_PREFIX" != "127.255.255" ]; then
        ENCONTRADA=1
        MENSAJE_RESULTADO="LISTADA en: $NOMBRE_LISTA ($DOMINIO_LISTA)"
        MENSAJE_RESULTADO="$MENSAJE_RESULTADO - Código: $RESULTADO"
        if [ "x$DESCRIPCION_LISTA" != "x" ]; then
          MENSAJE_RESULTADO="$MENSAJE_RESULTADO - $DESCRIPCION_LISTA"
        fi
        break
      fi
    else
      echo "    Sin respuesta (no listada)"
    fi
  fi
  
  LISTA_INDEX=`expr $LISTA_INDEX + 1`
done

# -----------------------------------------------------------------
# Mostrar resultado final
# -----------------------------------------------------------------
echo ""
echo "============================================================"
if [ $ENCONTRADA -eq 1 ]; then
  LISTADAS=`expr $LISTADAS + 1`
  echo "RESULTADO: $MENSAJE_RESULTADO"
  echo "$MENSAJE_RESULTADO" >> "$OUTPUT_FILE"
  echo "LISTED $IP -> $MENSAJE_RESULTADO" >> "$CACHE_FILE"
else
  # Verificar si hubo errores en las consultas
  HUBO_ERROR=0
  MENSAJE_ERROR=""
  
  # Revisar cada lista para ver si hubo error
  LISTA_INDEX=1
  while [ $LISTA_INDEX -le $TOTAL_LISTAS ]; do
    LINEA_LISTA=`sed -n "${LISTA_INDEX}p" "$TEMP_LISTAS"`
    DOMINIO_LISTA=`echo "$LINEA_LISTA" | cut -d'|' -f2`
    
    if [ "x$DOMINIO_LISTA" != "x" ]; then
      RESULTADO=`dig +short "@$DNS_SERVER" "${REV}.${DOMINIO_LISTA}" A 2>/dev/null | head -1`
      if [ ! -z "$RESULTADO" ]; then
        ERROR_PREFIX=`echo "$RESULTADO" | awk -F "." '{print $1"."$2"."$3}'`
        if [ "$ERROR_PREFIX" = "127.255.255" ]; then
          HUBO_ERROR=1
          NOMBRE_LISTA=`echo "$LINEA_LISTA" | cut -d'|' -f1`
          MENSAJE_ERROR="ERROR en $NOMBRE_LISTA: $RESULTADO"
          break
        fi
      fi
    fi
    LISTA_INDEX=`expr $LISTA_INDEX + 1`
  done

  if [ $HUBO_ERROR -eq 1 ]; then
    ERRORES=`expr $ERRORES + 1`
    echo "RESULTADO: $MENSAJE_ERROR"
    echo "$MENSAJE_ERROR" >> "$OUTPUT_FILE"
    echo "ERROR $IP -> $MENSAJE_ERROR" >> "$CACHE_FILE"
  else
    LIMPIAS=`expr $LIMPIAS + 1`
    MENSAJE="LIMPI  : $IP -> No listada en ninguna lista negra"
    echo "RESULTADO: $MENSAJE"
    echo "$MENSAJE" >> "$OUTPUT_FILE"
    echo "CLEAN $IP" >> "$CACHE_FILE"
  fi
fi
echo "============================================================"

# Limpiar archivos temporales
rm -f "$TEMP_DNS" "$TEMP_LISTAS"

# Mostrar resumen final en pantalla
echo ""
echo "============================================================"
echo "   RESUMEN FINAL"
echo "============================================================"
echo "IP consultada: $IP"
echo "IPs LISTADAS (en negra): $LISTADAS"
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
echo "IP consultada: $IP" >> "$OUTPUT_FILE"
echo "IPs LISTADAS (en negra): $LISTADAS" >> "$OUTPUT_FILE"
echo "IPs LIMPIAS (no listadas): $LIMPIAS" >> "$OUTPUT_FILE"
echo "IPs con ERROR en consulta: $ERRORES" >> "$OUTPUT_FILE"
echo "============================================================" >> "$OUTPUT_FILE"
echo "Fecha de finalización: `date`" >> "$OUTPUT_FILE"
